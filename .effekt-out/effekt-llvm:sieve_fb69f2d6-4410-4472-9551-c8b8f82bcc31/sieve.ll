; declaration include; Run-Time System

%Evidence = type i64

; Basic types

%Environment = type ptr

; Reference counts
%ReferenceCount = type i64

; Code to share (bump rc) an environment
%Sharer = type ptr

; Code to drop an environment
%Eraser = type ptr

; Every heap object starts with a header
%Header = type {%ReferenceCount, %Eraser}

; A heap object is a pointer to a header followed by payload.
;
;   +--[ Header ]--------------+-------------+
;   | ReferenceCount  | Eraser | Payload ... |
;   +-----------------+--------+-------------+
%Object = type ptr


; A Frame has the following layout
;
;   +-------[ FrameHeader ]------------+--------------+
;   | ReturnAddress  | Sharer | Eraser | Payload ...  |
;   +----------------------------------+--------------+

; A stack pointer points to the top-most frame followed by all other frames.
;
; For example
;
;     +--------------------+   <- Limit
;     :                    :
;     :                    :   <- StackPointer
;     +--------------------+
;     | FrameHeader        |
;     |    z               |
;     |    y               |
;     |    x               |
;     +--------------------+
;     | ... next frame ... |
;     +--------------------+
;     :        ...         :
;     +--------------------+ <- Base
%StackPointer = type ptr
%Base = type %StackPointer
%Limit = type %StackPointer
%ReturnAddress = type ptr
%FrameHeader = type { %ReturnAddress, %Sharer, %Eraser }

; Pointers for a heap allocated stack
%Memory = type { %StackPointer, %Base, %Limit }

; Unique address for each handler.
%Prompt = type ptr

; A Continuation capturing a list of stacks.
; This points to the last element in a cyclic linked list of StackValues
%Resumption = type ptr

; The "meta" stack (a stack of stacks) -- a pointer to a %StackValue
%Stack = type ptr

; Lives in a stable address
%PromptValue = type { %ReferenceCount, %Stack }

; This is used for two purposes:
;   - a refied first-class list of stacks (cyclic linked-list)
;   - as part of an intrusive linked-list of stacks (meta stack)
%StackValue = type { %ReferenceCount, %Memory, %Prompt, %Stack }



; Positive data types consist of a (type-local) tag and a heap object
%Pos = type {i64, %Object}

; Negative types (codata) consist of a vtable and a heap object
%Neg = type {ptr, %Object}

; Reference to a mutable variable (prompt, offset)
%Reference = type { %Prompt, i64 }

; Builtin Types

%Int = type i64
%Double = type double
%Byte = type i8
%Char = type i64
%Bool = type %Pos
%Unit = type %Pos
%String = type %Pos

; Foreign imports

declare ptr @malloc(i64)
declare void @free(ptr)
declare ptr @realloc(ptr, i64)
declare void @memcpy(ptr, ptr, i64)
declare i64 @llvm.ctlz.i64 (i64 , i1)
declare i64 @llvm.fshr.i64(i64, i64, i64)
declare double @llvm.sqrt.f64(double)
declare double @llvm.round.f64(double)
declare double @llvm.ceil.f64(double)
declare double @llvm.floor.f64(double)
declare double @llvm.cos.f64(double)
declare double @llvm.sin.f64(double)
declare double @llvm.log.f64(double)
declare double @llvm.exp.f64(double)
declare double @llvm.pow.f64(double, double)
declare double @log1p(double)
; Intrinsic versions of the following two only added in LLVM 19
declare double @atan(double)
declare double @tan(double)
declare void @print(i64)
declare void @exit(i64)
declare void @llvm.assume(i1)


; Boxing (externs functions, hence ccc)
define ccc %Pos @box(%Neg %input) {
    %vtable = extractvalue %Neg %input, 0
    %heap_obj = extractvalue %Neg %input, 1
    %vtable_as_int = ptrtoint ptr %vtable to i64
    %pos_result = insertvalue %Pos undef, i64 %vtable_as_int, 0
    %pos_result_with_heap = insertvalue %Pos %pos_result, ptr %heap_obj, 1
    ret %Pos %pos_result_with_heap
}

define ccc %Neg @unbox(%Pos %input) {
    %tag = extractvalue %Pos %input, 0
    %heap_obj = extractvalue %Pos %input, 1
    %vtable = inttoptr i64 %tag to ptr
    %neg_result = insertvalue %Neg undef, ptr %vtable, 0
    %neg_result_with_heap = insertvalue %Neg %neg_result, ptr %heap_obj, 1
    ret %Neg %neg_result_with_heap
}


; Prompts

define private %Prompt @currentPrompt(%Stack %stack) {
    %prompt_pointer = getelementptr %StackValue, ptr %stack, i64 0, i32 2
    %prompt = load %Prompt, ptr %prompt_pointer
    ret %Prompt %prompt
}

define private %Prompt @freshPrompt() {
    %promptSize = ptrtoint ptr getelementptr (%PromptValue, ptr null, i64 1) to i64
    %prompt = call %Prompt @malloc(i64 %promptSize)
    store %PromptValue zeroinitializer, %Prompt %prompt
    ret %Prompt %prompt
}

; Garbage collection

define private %Object @newObject(%Eraser %eraser, i64 %environmentSize) alwaysinline {
    %headerSize = ptrtoint ptr getelementptr (%Header, ptr null, i64 1) to i64
    %size = add i64 %environmentSize, %headerSize
    %object = call ptr @malloc(i64 %size)
    %objectReferenceCount = getelementptr %Header, ptr %object, i64 0, i32 0
    %objectEraser = getelementptr %Header, ptr %object, i64 0, i32 1
    store %ReferenceCount 0, ptr %objectReferenceCount
    store %Eraser %eraser, ptr %objectEraser
    ret %Object %object
}

define private %Environment @objectEnvironment(%Object %object) alwaysinline {
    ; Environment is stored right after header
    %environment = getelementptr %Header, ptr %object, i64 1
    ret %Environment %environment
}

define private void @shareObject(%Object %object) alwaysinline {
    %isNull = icmp eq %Object %object, null
    br i1 %isNull, label %done, label %next

    next:
    %objectReferenceCount = getelementptr %Header, ptr %object, i64 0, i32 0
    %referenceCount = load %ReferenceCount, ptr %objectReferenceCount
    %referenceCount.1 = add %ReferenceCount %referenceCount, 1
    store %ReferenceCount %referenceCount.1, ptr %objectReferenceCount
    br label %done

    done:
    ret void
}

define void @sharePositive(%Pos %val) alwaysinline {
    %object = extractvalue %Pos %val, 1
    tail call void @shareObject(%Object %object)
    ret void
}

define void @shareNegative(%Neg %val) alwaysinline {
    %object = extractvalue %Neg %val, 1
    tail call void @shareObject(%Object %object)
    ret void
}

define private void @eraseObject(%Object %object) alwaysinline {
    %isNull = icmp eq %Object %object, null
    br i1 %isNull, label %done, label %next

    next:
    %objectReferenceCount = getelementptr %Header, ptr %object, i64 0, i32 0
    %referenceCount = load %ReferenceCount, ptr %objectReferenceCount
    switch %ReferenceCount %referenceCount, label %decr [%ReferenceCount 0, label %free]

    decr:
    %referenceCount.1 = sub %ReferenceCount %referenceCount, 1
    store %ReferenceCount %referenceCount.1, ptr %objectReferenceCount
    ret void

    free:
    %objectEraser = getelementptr %Header, ptr %object, i64 0, i32 1
    %eraser = load %Eraser, ptr %objectEraser
    %environment = call %Environment @objectEnvironment(%Object %object)
    call void %eraser(%Environment %environment)
    call void @free(%Object %object)
    br label %done

    done:
    ret void
}

define void @erasePositive(%Pos %val) alwaysinline {
    %object = extractvalue %Pos %val, 1
    tail call void @eraseObject(%Object %object)
    ret void
}

define void @eraseNegative(%Neg %val) alwaysinline {
    %object = extractvalue %Neg %val, 1
    tail call void @eraseObject(%Object %object)
    ret void
}


; Arena management

define private %Stack @getStack(%Prompt %prompt) {
    %stack_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 1
    %stack = load %Stack, ptr %stack_pointer
    ret %Stack %stack
}

define private ptr @getVarPointer(%Reference %reference, %Stack %stack) {
    %prompt = extractvalue %Reference %reference, 0
    %offset = extractvalue %Reference %reference, 1

    %targetStack = call %Stack @getStack(%Prompt %prompt)
    %base_pointer = getelementptr %StackValue, %Stack %targetStack, i64 0, i32 1, i32 1
    %base = load %Base, ptr %base_pointer
    %varPointer = getelementptr i8, %Base %base, i64 %offset
    ret ptr %varPointer
}

define private %Reference @newReference(%Stack %stack) alwaysinline {
    %stackPointer_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 0
    %base_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 1

    %stackPointer = load %StackPointer, ptr %stackPointer_pointer
    %base = load %StackPointer, ptr %base_pointer

    %intStack = ptrtoint %StackPointer %stackPointer to i64
    %intBase = ptrtoint %StackPointer %base to i64

    %offset = sub i64 %intStack, %intBase

    %prompt = call %Prompt @currentPrompt(%Stack %stack)

    %reference..1 = insertvalue %Reference undef, %Prompt %prompt, 0
    %reference = insertvalue %Reference %reference..1, i64 %offset, 1

    ret %Reference %reference
}

; Stack management

define private %StackPointer @stackAllocate(%Stack %stack, i64 %n) {
    %stackPointer_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 0
    %limit_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 2

    %currentStackPointer = load %StackPointer, ptr %stackPointer_pointer, !alias.scope !2
    %limit = load %Limit, ptr %limit_pointer, !alias.scope !2
    %nextStackPointer = getelementptr i8, %StackPointer %currentStackPointer, i64 %n
    %isInside = icmp ule %StackPointer %nextStackPointer, %limit
    br i1 %isInside, label %continue, label %realloc

continue:
    store %StackPointer %nextStackPointer, ptr %stackPointer_pointer, !alias.scope !2
    ret %StackPointer %currentStackPointer

realloc:
    %base_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 1
    %base = load %Base, ptr %base_pointer, !alias.scope !2

    %intStackPointer = ptrtoint %StackPointer %currentStackPointer to i64
    %intBase = ptrtoint %Base %base to i64

    %size = sub i64 %intStackPointer, %intBase
    %nextSize = add i64 %size, %n
    %newSize = call i64 @nextPowerOfTwo(i64 %nextSize)

    %newBase = call ptr @realloc(ptr %base, i64 %newSize)
    %newLimit = getelementptr i8, %Base %newBase, i64 %newSize
    %newStackPointer = getelementptr i8, %Base %newBase, i64 %size
    %newNextStackPointer = getelementptr i8, %StackPointer %newStackPointer, i64 %n

    store %StackPointer %newNextStackPointer, ptr %stackPointer_pointer, !alias.scope !2
    store %Base %newBase, ptr %base_pointer, !alias.scope !2
    store %Limit %newLimit, ptr %limit_pointer, !alias.scope !2

    ret %StackPointer %newStackPointer
}

define private %StackPointer @stackDeallocate(%Stack %stack, i64 %n) {
    %stackPointer_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 0
    %stackPointer = load %StackPointer, ptr %stackPointer_pointer, !alias.scope !2

    %limit_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 2
    %limit = load %Limit, ptr %limit_pointer, !alias.scope !2
    %isInside = icmp ule %StackPointer %stackPointer, %limit
    call void @llvm.assume(i1 %isInside)

    %o = sub i64 0, %n
    %newStackPointer = getelementptr i8, %StackPointer %stackPointer, i64 %o
    store %StackPointer %newStackPointer, ptr %stackPointer_pointer, !alias.scope !2

    ret %StackPointer %newStackPointer
}

define private i64 @nextPowerOfTwo(i64 %x) {
    %leadingZeros = call i64 @llvm.ctlz.i64(i64 %x, i1 false)
    %numBits = sub i64 64, %leadingZeros
    %result = shl i64 1, %numBits
    ret i64 %result
}

define private void @assumeFrameHeaderWasPopped(%Stack %stack) alwaysinline {
    %stackPointer_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 0
    %stackPointer = load %StackPointer, ptr %stackPointer_pointer, !alias.scope !2
    %oldStackPointer = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 1

    %limit_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 2
    %limit = load %Limit, ptr %limit_pointer, !alias.scope !2
    %isInside = icmp ule %StackPointer %oldStackPointer, %limit
    call void @llvm.assume(i1 %isInside)
    ret void
}

; Meta-stack management

define private %Memory @newMemory() {
    %size = shl i64 1, 6
    %stackPointer = call %StackPointer @malloc(i64 %size)
    %limit = getelementptr i8, ptr %stackPointer, i64 %size

    %memory.0 = insertvalue %Memory undef, %StackPointer %stackPointer, 0
    %memory.1 = insertvalue %Memory %memory.0, %Base %stackPointer, 1
    %memory.2 = insertvalue %Memory %memory.1, %Limit %limit, 2

    ret %Memory %memory.2
}

define private %Stack @reset(%Stack %oldStack) {

    %prompt = call %Prompt @freshPrompt()

    %size = ptrtoint ptr getelementptr (%StackValue, ptr null, i64 1) to i64
    %stack = call ptr @malloc(i64 %size)


    %stackMemory = call %Memory @newMemory()

    %stack.0 = insertvalue %StackValue zeroinitializer, %Memory %stackMemory, 1
    %stack.1 = insertvalue %StackValue %stack.0, %Prompt %prompt, 2
    %stack.2 = insertvalue %StackValue %stack.1, %Stack %oldStack, 3

    store %StackValue %stack.2, %Stack %stack

    %stack_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 1
    store %Stack %stack, ptr %stack_pointer

    ret %Stack %stack
}

define private void @updatePrompts(%Stack %stack) {
    %prompt_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 2
    %prompt = load %Prompt, ptr %prompt_pointer
    %stack_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 1
    %promptStack = load %Stack, ptr %stack_pointer
    %isThis = icmp eq %Stack %promptStack, %stack
    br i1 %isThis, label %done, label %continue

done:
    ret void

continue:
    %isOccupied = icmp ne %Stack %promptStack, null
    br i1 %isOccupied, label %displace, label %update

displace:
    call void @displace(%Stack %promptStack, %Stack %promptStack)
    br label %update

update:
    store %Stack %stack, ptr %stack_pointer

    %next_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 3
    %next = load %Stack, ptr %next_pointer
    tail call void @updatePrompts(%Stack %next)
    ret void
}

define private void @displace(%Stack %stack, %Stack %end) {
    %prompt_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 2
    %next_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 3
    %prompt = load %Prompt, ptr %prompt_pointer
    %stack_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 1
    store %Stack null, ptr %stack_pointer

    %next = load %Stack, ptr %next_pointer
    %isEnd = icmp eq %Stack %next, %end
    br i1 %isEnd, label %done, label %continue

done:
    ret void

continue:
    tail call void @displace(%Stack %next, %Stack %end)
    ret void
}

define private %Stack @resume(%Resumption %resumption, %Stack %oldStack) {
    %uniqueResumption = call %Resumption @uniqueStack(%Resumption %resumption)
    %rest_pointer = getelementptr %StackValue, %Resumption %uniqueResumption, i64 0, i32 3
    %start = load %Stack, ptr %rest_pointer
    call void @updatePrompts(%Stack %start)

    store %Stack %oldStack, ptr %rest_pointer

    ret %Stack %start
}

define private {%Resumption, %Stack} @shift(%Stack %stack, %Prompt %prompt) {
    %resumpion_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 1
    %resumption = load %Stack, ptr %resumpion_pointer
    %next_pointer = getelementptr %StackValue, %Stack %resumption, i64 0, i32 3
    %next = load %Stack, ptr %next_pointer

    store %Stack %stack, ptr %next_pointer

    %result.0 = insertvalue {%Resumption, %Stack} undef, %Resumption %resumption, 0
    %result = insertvalue {%Resumption, %Stack} %result.0, %Stack %next, 1
    ret {%Resumption, %Stack} %result
}

define private void @eraseMemory(%Memory %memory) {
    %stackPointer = extractvalue %Memory %memory, 0
    call void @free(%StackPointer %stackPointer)
    ret void
}

define private void @erasePrompt(%Prompt %prompt) alwaysinline {
    %referenceCount_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 0
    %referenceCount = load %ReferenceCount, ptr %referenceCount_pointer
    switch %ReferenceCount %referenceCount, label %decrement [%ReferenceCount 0, label %free]

decrement:
    %newReferenceCount = sub %ReferenceCount %referenceCount, 1
    store %ReferenceCount %newReferenceCount, ptr %referenceCount_pointer
    ret void

free:
    call void @free(%Prompt %prompt)
    ret void
}

define private void @sharePrompt(%Prompt %prompt) alwaysinline {
    %referenceCount_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 0
    %referenceCount = load %ReferenceCount, ptr %referenceCount_pointer
    %newReferenceCount = add %ReferenceCount %referenceCount, 1
    store %ReferenceCount %newReferenceCount, ptr %referenceCount_pointer
    ret void
}

define private %Stack @underflowStack(%Stack %stack) {
    %stackMemory = getelementptr %StackValue, %Stack %stack, i64 0, i32 1
    %stackPrompt = getelementptr %StackValue, %Stack %stack, i64 0, i32 2
    %stackRest = getelementptr %StackValue, %Stack %stack, i64 0, i32 3

    %memory = load %Memory, ptr %stackMemory
    %prompt = load %Prompt, ptr %stackPrompt
    %rest = load %Stack, ptr %stackRest

    %promptStack_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 1
    store %Stack null, ptr %promptStack_pointer

    call void @eraseMemory(%Memory %memory)
    call void @erasePrompt(%Prompt %prompt)
    call void @free(%Stack %stack)

    ret %Stack %rest
}

define private void @nop(%Stack %stack) {
    ret void
}

define private %Memory @copyMemory(%Memory %memory) alwaysinline {
    %stackPointer = extractvalue %Memory %memory, 0
    %base = extractvalue %Memory %memory, 1
    %limit = extractvalue %Memory %memory, 2

    %intStackPointer = ptrtoint %StackPointer %stackPointer to i64
    %intBase = ptrtoint %Base %base to i64
    %intLimit = ptrtoint %Limit %limit to i64
    %used = sub i64 %intStackPointer, %intBase
    %size = sub i64 %intLimit, %intBase

    %newBase = call ptr @malloc(i64 %size)
    %intNewBase = ptrtoint %Base %newBase to i64
    %intNewStackPointer = add i64 %intNewBase, %used
    %intNewLimit = add i64 %intNewBase, %size
    %newStackPointer = inttoptr i64 %intNewStackPointer to %StackPointer
    %newLimit = inttoptr i64 %intNewLimit to %Limit

    call void @memcpy(ptr %newBase, ptr %base, i64 %used)

    %memory.0 = insertvalue %Memory undef, %StackPointer %newStackPointer, 0
    %memory.1 = insertvalue %Memory %memory.0, %Base %newBase, 1
    %memory.2 = insertvalue %Memory %memory.1, %Limit %newLimit, 2

    ret %Memory %memory.2
}


define private %Resumption @uniqueStack(%Resumption %resumption) alwaysinline {

entry:
    %referenceCount_pointer = getelementptr %StackValue, %Resumption %resumption, i64 0, i32 0
    %referenceCount = load %ReferenceCount, ptr %referenceCount_pointer
    switch %ReferenceCount %referenceCount, label %copy [%ReferenceCount 0, label %done]

done:
    ret %Resumption %resumption

copy:
    %newOldReferenceCount = sub %ReferenceCount %referenceCount, 1
    store %ReferenceCount %newOldReferenceCount, ptr %referenceCount_pointer
    %stack_pointer = getelementptr %StackValue, %Resumption %resumption, i64 0, i32 3
    %stack = load %Stack, ptr %stack_pointer

    %size = ptrtoint ptr getelementptr (%StackValue, ptr null, i64 1) to i64
    %newHead = call ptr @malloc(i64 %size)

    br label %loop

loop:
    %old = phi %Stack [%stack, %copy], [%rest, %next]
    %newStack = phi %Stack [%newHead, %copy], [%nextNew, %next]

    %stackMemory = getelementptr %StackValue, %Stack %old, i64 0, i32 1
    %stackPrompt = getelementptr %StackValue, %Stack %old, i64 0, i32 2
    %stackRest = getelementptr %StackValue, %Stack %old, i64 0, i32 3

    %memory = load %Memory, ptr %stackMemory
    %prompt = load %Prompt, ptr %stackPrompt
    %rest = load %Stack, ptr %stackRest

    %newStackReferenceCounter = getelementptr %StackValue, %Stack %newStack, i64 0, i32 0
    %newStackMemory = getelementptr %StackValue, %Stack %newStack, i64 0, i32 1
    %newStackPrompt = getelementptr %StackValue, %Stack %newStack, i64 0, i32 2
    %newStackRest = getelementptr %StackValue, %Stack %newStack, i64 0, i32 3

    %newMemory = call %Memory @copyMemory(%Memory %memory)

    %newStackPointer = extractvalue %Memory %newMemory, 0
    call void @shareFrames(%StackPointer %newStackPointer)

    call void @sharePrompt(%Prompt %prompt)

    store %ReferenceCount 0, ptr %newStackReferenceCounter
    store %Memory %newMemory, ptr %newStackMemory
    store %Prompt %prompt, ptr %newStackPrompt

    %isEnd = icmp eq %Stack %old, %resumption
    br i1 %isEnd, label %stop, label %next

next:
    %nextNew = call ptr @malloc(i64 %size)
    store %Stack %nextNew, ptr %newStackRest
    br label %loop

stop:
    store %Stack %newHead, ptr %newStackRest
    ret %Stack %newStack
}

define void @shareResumption(%Resumption %resumption) alwaysinline {
    %referenceCount_pointer = getelementptr %StackValue, %Resumption %resumption, i64 0, i32 0
    %referenceCount = load %ReferenceCount, ptr %referenceCount_pointer
    %referenceCount.1 = add %ReferenceCount %referenceCount, 1
    store %ReferenceCount %referenceCount.1, ptr %referenceCount_pointer
    ret void
}

define void @eraseResumption(%Resumption %resumption) alwaysinline {
    %referenceCount_pointer = getelementptr %StackValue, %Resumption %resumption, i64 0, i32 0
    %referenceCount = load %ReferenceCount, ptr %referenceCount_pointer
    switch %ReferenceCount %referenceCount, label %decr [%ReferenceCount 0, label %free]

    decr:
    %referenceCount.1 = sub %ReferenceCount %referenceCount, 1
    store %ReferenceCount %referenceCount.1, ptr %referenceCount_pointer
    ret void

    free:
    %stack_pointer = getelementptr %StackValue, %Resumption %resumption, i64 0, i32 3
    %stack = load %Stack, ptr %stack_pointer
    store %Stack null, ptr %stack_pointer
    call void @eraseStack(%Stack %stack)
    ret void
}

define void @eraseStack(%Stack %stack) alwaysinline {
    %stackPointer_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 0
    %prompt_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 2
    %rest_pointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 3

    %stackPointer = load %StackPointer, ptr %stackPointer_pointer
    %prompt = load %Stack, ptr %prompt_pointer
    %rest = load %Stack, ptr %rest_pointer

    %promptStack_pointer = getelementptr %PromptValue, %Prompt %prompt, i64 0, i32 1
    %promptStack = load %Stack, ptr %promptStack_pointer
    %isThisStack = icmp eq %Stack %promptStack, %stack
    br i1 %isThisStack, label %clearPrompt, label %free

clearPrompt:
    store %Stack null, ptr %promptStack_pointer
    br label %free

free:
    call void @free(%Stack %stack)
    call void @eraseFrames(%StackPointer %stackPointer)
    call void @erasePrompt(%Prompt %prompt)

    %isNull = icmp eq %Stack %rest, null
    br i1 %isNull, label %done, label %next

next:
    call void @eraseStack(%Stack %rest)
    ret void

done:
    ret void
}

define private void @shareFrames(%StackPointer %stackPointer) alwaysinline {
    %newStackPointer = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 -1
    %stackSharer = getelementptr %FrameHeader, %StackPointer %newStackPointer, i64 0, i32 1
    %sharer = load %Sharer, ptr %stackSharer
    tail call void %sharer(%StackPointer %newStackPointer)
    ret void
}

define private void @eraseFrames(%StackPointer %stackPointer) alwaysinline {
    %newStackPointer = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 -1
    %stackEraser = getelementptr %FrameHeader, %StackPointer %newStackPointer, i64 0, i32 2
    %eraser = load %Eraser, ptr %stackEraser
    tail call void %eraser(%StackPointer %newStackPointer)
    ret void
}

; RTS initialization

define private tailcc void @topLevel(%Pos %val, %Stack %stack) {
    %rest = call %Stack @underflowStack(%Stack %stack)
    ; rest holds global variables
    call void @eraseStack(%Stack %rest)
    ret void
}

define private void @topLevelSharer(%Environment %environment) {
    ; TODO this should never be called
    ret void
}

define private void @topLevelEraser(%Environment %environment) {
    ; TODO this should never be called
    ret void
}

@global = private global { i64, %Stack } { i64 0, %Stack null }

define private %Stack @withEmptyStack() {
    %globals = call %Stack @reset(%Stack null)

    %globalsStackPointer_pointer = getelementptr %StackValue, %Stack %globals, i64 0, i32 1, i32 0
    %globalsStackPointer = load %StackPointer, ptr %globalsStackPointer_pointer

    %returnAddressPointer.0 = getelementptr %FrameHeader, %StackPointer %globalsStackPointer, i64 0, i32 0
    %sharerPointer.0 = getelementptr %FrameHeader, %StackPointer %globalsStackPointer, i64 0, i32 1
    %eraserPointer.0 = getelementptr %FrameHeader, %StackPointer %globalsStackPointer, i64 0, i32 2

    store ptr @nop, ptr %returnAddressPointer.0
    store ptr @nop, ptr %sharerPointer.0
    store ptr @free, ptr %eraserPointer.0

    %globalsStackPointer_2 = getelementptr %FrameHeader, %StackPointer %globalsStackPointer, i64 1
    store %StackPointer %globalsStackPointer_2, ptr %globalsStackPointer_pointer

    %stack = call %Stack @reset(%Stack %globals)

    %globalStack = getelementptr %PromptValue, %Prompt @global, i64 0, i32 1
    store %Stack %stack, ptr %globalStack

    %stackStackPointer = getelementptr %StackValue, %Stack %stack, i64 0, i32 1, i32 0
    %stackPointer = load %StackPointer, ptr %stackStackPointer

    %returnAddressPointer = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 0, i32 0
    %sharerPointer = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 0, i32 1
    %eraserPointer = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 0, i32 2

    store %ReturnAddress @topLevel, ptr %returnAddressPointer
    store %Sharer @topLevelSharer, ptr %sharerPointer
    store %Eraser @topLevelEraser, ptr %eraserPointer

    %stackPointer_2 = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 1
    store %StackPointer %stackPointer_2, ptr %stackStackPointer

    ret %Stack %stack
}

define void @resume_Int(%Stack %stack, %Int %argument) {
    %stackPointer = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
    %returnAddressPointer = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 0, i32 0
    %returnAddress = load %ReturnAddress, ptr %returnAddressPointer
    tail call tailcc void %returnAddress(%Int %argument, %Stack %stack)
    ret void
}

define void @resume_Pos(%Stack %stack, %Pos %argument) {
    %stackPointer = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
    %returnAddressPointer = getelementptr %FrameHeader, %StackPointer %stackPointer, i64 0, i32 0
    %returnAddress = load %ReturnAddress, ptr %returnAddressPointer
    tail call tailcc void %returnAddress(%Pos %argument, %Stack %stack)
    ret void
}

define void @run(%Neg %f) {
    ; fresh stack
    %stack = call %Stack @withEmptyStack()

    ; prepare call
    %arrayPointer = extractvalue %Neg %f, 0
    %object = extractvalue %Neg %f, 1
    %functionPointerPointer = getelementptr ptr, ptr %arrayPointer, i64 0
    %functionPointer = load ptr, ptr %functionPointerPointer

    ; call
    tail call tailcc %Pos %functionPointer(%Object %object, %Stack %stack)
    ret void
}

define void @run_Int(%Neg %f, i64 %argument) {
    ; fresh stack
    %stack = call %Stack @withEmptyStack()

    ; prepare call
    %arrayPointer = extractvalue %Neg %f, 0
    %object = extractvalue %Neg %f, 1
    %functionPointerPointer = getelementptr ptr, ptr %arrayPointer, i64 0
    %functionPointer = load ptr, ptr %functionPointerPointer

    ; call
    tail call tailcc %Pos %functionPointer(%Object %object, %Evidence 0, i64 %argument, %Stack %stack)
    ret void
}

define void @run_Pos(%Neg %f, %Pos %argument) {
    ; fresh stack
    %stack = call %Stack @withEmptyStack()

    ; prepare call
    %arrayPointer = extractvalue %Neg %f, 0
    %object = extractvalue %Neg %f, 1
    %functionPointerPointer = getelementptr ptr, ptr %arrayPointer, i64 0
    %functionPointer = load ptr, ptr %functionPointerPointer

    ; call
    tail call tailcc %Pos %functionPointer(%Object %object, %Evidence 0, %Pos %argument, %Stack %stack)
    ret void
}


; Scope domains
!0 = !{!"types"}

; Scopes
!1 = !{!"stackValues", !0}

; Scope lists
!2 = !{!1}


; declaration include; forward-declared from primitives.c

declare i64 @c_get_argc()
declare %Pos @c_get_arg(i64)

declare void @c_io_println_Boolean(%Pos)
declare void @c_io_println_Int(%Int)
declare void @c_io_println_Double(%Double)
declare void @c_io_println_String(%Pos)

declare void @hole()

declare %Pos @c_ref_fresh(%Pos)
declare %Pos @c_ref_get(%Pos)
declare %Pos @c_ref_set(%Pos, %Pos)

declare %Pos @c_array_new(%Int)
declare %Int @c_array_size(%Pos)
declare %Pos @c_array_get(%Pos, %Int)
declare %Pos @c_array_set(%Pos, %Int, %Pos)

declare %Pos @c_bytearray_new(%Int)
declare %Int @c_bytearray_size(%Pos)
declare %Byte @c_bytearray_get(%Pos, %Int)
declare %Pos @c_bytearray_set(%Pos, %Int, %Byte)

declare ptr @c_bytearray_data(%Pos)
declare %Pos @c_bytearray_construct(i64, ptr)

declare %Pos @c_bytearray_from_nullterminated_string(ptr)
declare ptr @c_bytearray_into_nullterminated_string(%Pos)

declare %Pos @c_bytearray_show_Int(i64)
declare %Pos @c_bytearray_show_Char(i32)
declare %Pos @c_bytearray_show_Byte(i8)
declare %Pos @c_bytearray_show_Double(double)

declare %Pos @c_bytearray_concatenate(%Pos, %Pos)
declare %Pos @c_bytearray_equal(%Pos, %Pos)
declare %Int @c_bytearray_compare(%Pos, %Pos)

declare %Pos @c_bytearray_substring(%Pos, i64, i64)
declare %Int @c_bytearray_character_at(%Pos, i64)




define ccc %Pos @println_1(%Pos %value_2) {
    ; declaration extern
    ; variable
    
    call void @c_io_println_String(%Pos %value_2)
    ret %Pos zeroinitializer ; Unit
  
}



define ccc %Pos @show_14(i64 %value_13) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_bytearray_show_Int(%Int %value_13)
    ret %Pos %z
  
}



define ccc %Pos @infixConcat_35(%Pos %s1_33, %Pos %s2_34) {
    ; declaration extern
    ; variable
    
    %spz = call %Pos @c_bytearray_concatenate(%Pos %s1_33, %Pos %s2_34)
    ret %Pos %spz
  
}



define ccc i64 @length_37(%Pos %str_36) {
    ; declaration extern
    ; variable
    
    %x = call %Int @c_bytearray_size(%Pos %str_36)
    ret %Int %x
  
}



define ccc %Pos @infixEq_78(i64 %x_76, i64 %y_77) {
    ; declaration extern
    ; variable
    
    %z = icmp eq %Int %x_76, %y_77
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc i64 @infixAdd_96(i64 %x_94, i64 %y_95) {
    ; declaration extern
    ; variable
    %z = add  %Int %x_94, %y_95 ret %Int %z
}



define ccc i64 @infixMul_99(i64 %x_97, i64 %y_98) {
    ; declaration extern
    ; variable
    %z = mul  %Int %x_97, %y_98 ret %Int %z
}



define ccc i64 @infixSub_105(i64 %x_103, i64 %y_104) {
    ; declaration extern
    ; variable
    %z = sub  %Int %x_103, %y_104 ret %Int %z
}



define ccc %Pos @infixLt_178(i64 %x_176, i64 %y_177) {
    ; declaration extern
    ; variable
    
    %z = icmp slt %Int %x_176, %y_177
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc %Pos @infixLte_181(i64 %x_179, i64 %y_180) {
    ; declaration extern
    ; variable
    
    %z = icmp sle %Int %x_179, %y_180
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc %Pos @infixGte_187(i64 %x_185, i64 %y_186) {
    ; declaration extern
    ; variable
    
    %z = icmp sge %Int %x_185, %y_186
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc %Pos @boxInt_301(i64 %n_300) {
    ; declaration extern
    ; variable
    
        %boxed1 = insertvalue %Pos zeroinitializer, i64 %n_300, 0
        %boxed2 = insertvalue %Pos %boxed1, %Object null, 1
        ret %Pos %boxed2
      
}



define ccc i64 @unboxInt_303(%Pos %b_302) {
    ; declaration extern
    ; variable
    
        %unboxed = extractvalue %Pos %b_302, 0
        ret %Int %unboxed
      
}



define ccc %Pos @boxChar_311(i64 %c_310) {
    ; declaration extern
    ; variable
    
        %boxed1 = insertvalue %Pos zeroinitializer, i64 %c_310, 0
        %boxed2 = insertvalue %Pos %boxed1, %Object null, 1
        ret %Pos %boxed2
      
}



define ccc i64 @unboxChar_313(%Pos %b_312) {
    ; declaration extern
    ; variable
    
        %unboxed = extractvalue %Pos %b_312, 0
        ret %Int %unboxed
      
}



define ccc i64 @toInt_2085(i64 %ch_2084) {
    ; declaration extern
    ; variable
    ret %Int %ch_2084
}



define ccc %Pos @infixLte_2093(i64 %x_2091, i64 %y_2092) {
    ; declaration extern
    ; variable
    
    %z = icmp sle %Int %x_2091, %y_2092
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc %Pos @infixGte_2099(i64 %x_2097, i64 %y_2098) {
    ; declaration extern
    ; variable
    
    %z = icmp sge %Int %x_2097, %y_2098
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc i64 @unsafeCharAt_2111(%Pos %str_2109, i64 %n_2110) {
    ; declaration extern
    ; variable
    
    %x = call %Int @c_bytearray_character_at(%Pos %str_2109, %Int %n_2110)
    ret %Int %x
  
}



define ccc i64 @argCount_2383() {
    ; declaration extern
    ; variable
    
      %c = call %Int @c_get_argc()
      ret %Int %c
    
}



define ccc %Pos @argument_2385(i64 %i_2384) {
    ; declaration extern
    ; variable
    
      %s = call %Pos @c_get_arg(%Int %i_2384)
      ret %Pos %s
    
}


; declaration include
  declare i32 @clock_gettime(i32, ptr)



define ccc %Pos @allocate_2473(i64 %size_2472) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_new(%Int %size_2472)
    ret %Pos %z
  
}



define ccc %Pos @unsafeGet_2487(%Pos %arr_2485, i64 %index_2486) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_get(%Pos %arr_2485, %Int %index_2486)
    ret %Pos %z
  
}



define ccc %Pos @unsafeSet_2492(%Pos %arr_2489, i64 %index_2490, %Pos %value_2491) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_set(%Pos %arr_2489, %Int %index_2490, %Pos %value_2491)
    ret %Pos %z
  
}



define tailcc void @returnAddress_10(i64 %v_r_2929_2_5037, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_11 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_5034_pointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 0
        %i_6_5034 = load i64, ptr %i_6_5034_pointer_12, !noalias !2
        %tmp_5157_pointer_13 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 1
        %tmp_5157 = load i64, ptr %tmp_5157_pointer_13, !noalias !2
        
        %longLiteral_5226 = add i64 1, 0
        
        %pureApp_5225 = call ccc i64 @infixAdd_96(i64 %i_6_5034, i64 %longLiteral_5226)
        
        
        
        
        
        musttail call tailcc void @loop_5_5032(i64 %pureApp_5225, i64 %tmp_5157, %Stack %stack)
        ret void
}



define ccc void @sharer_16(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_17 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5034_14_pointer_18 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 0
        %i_6_5034_14 = load i64, ptr %i_6_5034_14_pointer_18, !noalias !2
        %tmp_5157_15_pointer_19 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 1
        %tmp_5157_15 = load i64, ptr %tmp_5157_15_pointer_19, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_17)
        ret void
}



define ccc void @eraser_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5034_20_pointer_24 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %i_6_5034_20 = load i64, ptr %i_6_5034_20_pointer_24, !noalias !2
        %tmp_5157_21_pointer_25 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 1
        %tmp_5157_21 = load i64, ptr %tmp_5157_21_pointer_25, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_23)
        ret void
}



define tailcc void @loop_5_5032(i64 %i_6_5034, i64 %tmp_5157, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5223 = call ccc %Pos @infixLt_178(i64 %i_6_5034, i64 %tmp_5157)
        
        
        
        %tag_2 = extractvalue %Pos %pureApp_5223, 0
        %fields_3 = extractvalue %Pos %pureApp_5223, 1
        switch i64 %tag_2, label %label_4 [i64 0, label %label_9 i64 1, label %label_32]
    
    label_4:
        
        ret void
    
    label_9:
        
        %unitLiteral_5224_temporary_5 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5224 = insertvalue %Pos %unitLiteral_5224_temporary_5, %Object null, 1
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %unitLiteral_5224, %Stack %stack)
        ret void
    
    label_32:
        %stackPointer_26 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_5034_pointer_27 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        store i64 %i_6_5034, ptr %i_6_5034_pointer_27, !noalias !2
        %tmp_5157_pointer_28 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 1
        store i64 %tmp_5157, ptr %tmp_5157_pointer_28, !noalias !2
        %returnAddress_pointer_29 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 0
        %sharer_pointer_30 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 1
        %eraser_pointer_31 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 2
        store ptr @returnAddress_10, ptr %returnAddress_pointer_29, !noalias !2
        store ptr @sharer_16, ptr %sharer_pointer_30, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_31, !noalias !2
        
        %longLiteral_5227 = add i64 5000, 0
        
        
        
        musttail call tailcc void @run_2853(i64 %longLiteral_5227, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_34(i64 %r_2863, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5229 = call ccc %Pos @show_14(i64 %r_2863)
        
        
        
        %pureApp_5230 = call ccc %Pos @println_1(%Pos %pureApp_5229)
        
        
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_37 = getelementptr %FrameHeader, %StackPointer %stackPointer_36, i64 0, i32 0
        %returnAddress_35 = load %ReturnAddress, ptr %returnAddress_pointer_37, !noalias !2
        musttail call tailcc void %returnAddress_35(%Pos %pureApp_5230, %Stack %stack)
        ret void
}



define ccc void @sharer_38(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_39 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_39)
        ret void
}



define ccc void @eraser_40(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_41 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_41)
        ret void
}



define tailcc void @returnAddress_33(%Pos %v_r_2931_5228, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %v_r_2931_5228)
        %stackPointer_42 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_43 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 0
        %sharer_pointer_44 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 1
        %eraser_pointer_45 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_43, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_44, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_45, !noalias !2
        
        %longLiteral_5231 = add i64 5000, 0
        
        
        
        musttail call tailcc void @run_2853(i64 %longLiteral_5231, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3965_4029, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5220 = call ccc i64 @unboxInt_303(%Pos %v_coe_3965_4029)
        
        
        
        %longLiteral_5222 = add i64 1, 0
        
        %pureApp_5221 = call ccc i64 @infixSub_105(i64 %pureApp_5220, i64 %longLiteral_5222)
        
        
        %stackPointer_46 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_47 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 0
        %sharer_pointer_48 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 1
        %eraser_pointer_49 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 2
        store ptr @returnAddress_33, ptr %returnAddress_pointer_47, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_48, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_49, !noalias !2
        
        %longLiteral_5232 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_5032(i64 %longLiteral_5232, i64 %pureApp_5221, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_55(%Pos %returned_5233, %Stack %stack) {
        
    entry:
        
        %stack_56 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_58 = call ccc %StackPointer @stackDeallocate(%Stack %stack_56, i64 24)
        %returnAddress_pointer_59 = getelementptr %FrameHeader, %StackPointer %stackPointer_58, i64 0, i32 0
        %returnAddress_57 = load %ReturnAddress, ptr %returnAddress_pointer_59, !noalias !2
        musttail call tailcc void %returnAddress_57(%Pos %returned_5233, %Stack %stack_56)
        ret void
}



define ccc void @sharer_60(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_61 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_62(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_63 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_63)
        ret void
}



define ccc void @eraser_75(%Environment %environment) {
        
    entry:
        
        %tmp_5130_73_pointer_76 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5130_73 = load %Pos, ptr %tmp_5130_73_pointer_76, !noalias !2
        %acc_3_3_5_169_4902_74_pointer_77 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4902_74 = load %Pos, ptr %acc_3_3_5_169_4902_74_pointer_77, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5130_73)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4902_74)
        ret void
}



define tailcc void @toList_1_1_3_167_4935(i64 %start_2_2_4_168_4774, %Pos %acc_3_3_5_169_4902, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5235 = add i64 1, 0
        
        %pureApp_5234 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4774, i64 %longLiteral_5235)
        
        
        
        %tag_68 = extractvalue %Pos %pureApp_5234, 0
        %fields_69 = extractvalue %Pos %pureApp_5234, 1
        switch i64 %tag_68, label %label_70 [i64 0, label %label_81 i64 1, label %label_85]
    
    label_70:
        
        ret void
    
    label_81:
        
        %pureApp_5236 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4774)
        
        
        
        %longLiteral_5238 = add i64 1, 0
        
        %pureApp_5237 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4774, i64 %longLiteral_5238)
        
        
        
        %fields_71 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_72 = call ccc %Environment @objectEnvironment(%Object %fields_71)
        %tmp_5130_pointer_78 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 0
        store %Pos %pureApp_5236, ptr %tmp_5130_pointer_78, !noalias !2
        %acc_3_3_5_169_4902_pointer_79 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4902, ptr %acc_3_3_5_169_4902_pointer_79, !noalias !2
        %make_5239_temporary_80 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5239 = insertvalue %Pos %make_5239_temporary_80, %Object %fields_71, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4935(i64 %pureApp_5237, %Pos %make_5239, %Stack %stack)
        ret void
    
    label_85:
        
        %stackPointer_83 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_84 = getelementptr %FrameHeader, %StackPointer %stackPointer_83, i64 0, i32 0
        %returnAddress_82 = load %ReturnAddress, ptr %returnAddress_pointer_84, !noalias !2
        musttail call tailcc void %returnAddress_82(%Pos %acc_3_3_5_169_4902, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_96(%Pos %v_r_3116_32_59_223_4903, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_97 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %v_r_2926_30_194_4918_pointer_98 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 0
        %v_r_2926_30_194_4918 = load %Pos, ptr %v_r_2926_30_194_4918_pointer_98, !noalias !2
        %p_8_9_4663_pointer_99 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 1
        %p_8_9_4663 = load %Prompt, ptr %p_8_9_4663_pointer_99, !noalias !2
        %index_7_34_198_4725_pointer_100 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 2
        %index_7_34_198_4725 = load i64, ptr %index_7_34_198_4725_pointer_100, !noalias !2
        %tmp_5137_pointer_101 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 3
        %tmp_5137 = load i64, ptr %tmp_5137_pointer_101, !noalias !2
        %acc_8_35_199_4782_pointer_102 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 4
        %acc_8_35_199_4782 = load i64, ptr %acc_8_35_199_4782_pointer_102, !noalias !2
        
        %tag_103 = extractvalue %Pos %v_r_3116_32_59_223_4903, 0
        %fields_104 = extractvalue %Pos %v_r_3116_32_59_223_4903, 1
        switch i64 %tag_103, label %label_105 [i64 1, label %label_128 i64 0, label %label_135]
    
    label_105:
        
        ret void
    
    label_110:
        
        ret void
    
    label_116:
        call ccc void @erasePositive(%Pos %v_r_2926_30_194_4918)
        
        %pair_111 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4663)
        %k_13_14_4_5044 = extractvalue <{%Resumption, %Stack}> %pair_111, 0
        %stack_112 = extractvalue <{%Resumption, %Stack}> %pair_111, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5044)
        
        %longLiteral_5251 = add i64 10, 0
        
        
        
        %pureApp_5252 = call ccc %Pos @boxInt_301(i64 %longLiteral_5251)
        
        
        
        %stackPointer_114 = call ccc %StackPointer @stackDeallocate(%Stack %stack_112, i64 24)
        %returnAddress_pointer_115 = getelementptr %FrameHeader, %StackPointer %stackPointer_114, i64 0, i32 0
        %returnAddress_113 = load %ReturnAddress, ptr %returnAddress_pointer_115, !noalias !2
        musttail call tailcc void %returnAddress_113(%Pos %pureApp_5252, %Stack %stack_112)
        ret void
    
    label_119:
        
        ret void
    
    label_125:
        call ccc void @erasePositive(%Pos %v_r_2926_30_194_4918)
        
        %pair_120 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4663)
        %k_13_14_4_5043 = extractvalue <{%Resumption, %Stack}> %pair_120, 0
        %stack_121 = extractvalue <{%Resumption, %Stack}> %pair_120, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5043)
        
        %longLiteral_5255 = add i64 10, 0
        
        
        
        %pureApp_5256 = call ccc %Pos @boxInt_301(i64 %longLiteral_5255)
        
        
        
        %stackPointer_123 = call ccc %StackPointer @stackDeallocate(%Stack %stack_121, i64 24)
        %returnAddress_pointer_124 = getelementptr %FrameHeader, %StackPointer %stackPointer_123, i64 0, i32 0
        %returnAddress_122 = load %ReturnAddress, ptr %returnAddress_pointer_124, !noalias !2
        musttail call tailcc void %returnAddress_122(%Pos %pureApp_5256, %Stack %stack_121)
        ret void
    
    label_126:
        
        %longLiteral_5258 = add i64 1, 0
        
        %pureApp_5257 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4725, i64 %longLiteral_5258)
        
        
        
        %longLiteral_5260 = add i64 10, 0
        
        %pureApp_5259 = call ccc i64 @infixMul_99(i64 %longLiteral_5260, i64 %acc_8_35_199_4782)
        
        
        
        %pureApp_5261 = call ccc i64 @toInt_2085(i64 %pureApp_5248)
        
        
        
        %pureApp_5262 = call ccc i64 @infixSub_105(i64 %pureApp_5261, i64 %tmp_5137)
        
        
        
        %pureApp_5263 = call ccc i64 @infixAdd_96(i64 %pureApp_5259, i64 %pureApp_5262)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4742(i64 %pureApp_5257, i64 %pureApp_5263, %Pos %v_r_2926_30_194_4918, %Prompt %p_8_9_4663, i64 %tmp_5137, %Stack %stack)
        ret void
    
    label_127:
        
        %intLiteral_5254 = add i64 57, 0
        
        %pureApp_5253 = call ccc %Pos @infixLte_2093(i64 %pureApp_5248, i64 %intLiteral_5254)
        
        
        
        %tag_117 = extractvalue %Pos %pureApp_5253, 0
        %fields_118 = extractvalue %Pos %pureApp_5253, 1
        switch i64 %tag_117, label %label_119 [i64 0, label %label_125 i64 1, label %label_126]
    
    label_128:
        %environment_106 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_coe_3934_46_73_237_4889_pointer_107 = getelementptr <{%Pos}>, %Environment %environment_106, i64 0, i32 0
        %v_coe_3934_46_73_237_4889 = load %Pos, ptr %v_coe_3934_46_73_237_4889_pointer_107, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3934_46_73_237_4889)
        call ccc void @eraseObject(%Object %fields_104)
        
        %pureApp_5248 = call ccc i64 @unboxChar_313(%Pos %v_coe_3934_46_73_237_4889)
        
        
        
        %intLiteral_5250 = add i64 48, 0
        
        %pureApp_5249 = call ccc %Pos @infixGte_2099(i64 %pureApp_5248, i64 %intLiteral_5250)
        
        
        
        %tag_108 = extractvalue %Pos %pureApp_5249, 0
        %fields_109 = extractvalue %Pos %pureApp_5249, 1
        switch i64 %tag_108, label %label_110 [i64 0, label %label_116 i64 1, label %label_127]
    
    label_135:
        %environment_129 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_y_3123_76_103_267_5246_pointer_130 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 0
        %v_y_3123_76_103_267_5246 = load %Pos, ptr %v_y_3123_76_103_267_5246_pointer_130, !noalias !2
        %v_y_3124_77_104_268_5247_pointer_131 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 1
        %v_y_3124_77_104_268_5247 = load %Pos, ptr %v_y_3124_77_104_268_5247_pointer_131, !noalias !2
        call ccc void @eraseObject(%Object %fields_104)
        call ccc void @erasePositive(%Pos %v_r_2926_30_194_4918)
        
        %stackPointer_133 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_134 = getelementptr %FrameHeader, %StackPointer %stackPointer_133, i64 0, i32 0
        %returnAddress_132 = load %ReturnAddress, ptr %returnAddress_pointer_134, !noalias !2
        musttail call tailcc void %returnAddress_132(i64 %acc_8_35_199_4782, %Stack %stack)
        ret void
}



define ccc void @sharer_141(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_142 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2926_30_194_4918_136_pointer_143 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 0
        %v_r_2926_30_194_4918_136 = load %Pos, ptr %v_r_2926_30_194_4918_136_pointer_143, !noalias !2
        %p_8_9_4663_137_pointer_144 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 1
        %p_8_9_4663_137 = load %Prompt, ptr %p_8_9_4663_137_pointer_144, !noalias !2
        %index_7_34_198_4725_138_pointer_145 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 2
        %index_7_34_198_4725_138 = load i64, ptr %index_7_34_198_4725_138_pointer_145, !noalias !2
        %tmp_5137_139_pointer_146 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 3
        %tmp_5137_139 = load i64, ptr %tmp_5137_139_pointer_146, !noalias !2
        %acc_8_35_199_4782_140_pointer_147 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 4
        %acc_8_35_199_4782_140 = load i64, ptr %acc_8_35_199_4782_140_pointer_147, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2926_30_194_4918_136)
        call ccc void @shareFrames(%StackPointer %stackPointer_142)
        ret void
}



define ccc void @eraser_153(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_154 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2926_30_194_4918_148_pointer_155 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 0
        %v_r_2926_30_194_4918_148 = load %Pos, ptr %v_r_2926_30_194_4918_148_pointer_155, !noalias !2
        %p_8_9_4663_149_pointer_156 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 1
        %p_8_9_4663_149 = load %Prompt, ptr %p_8_9_4663_149_pointer_156, !noalias !2
        %index_7_34_198_4725_150_pointer_157 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 2
        %index_7_34_198_4725_150 = load i64, ptr %index_7_34_198_4725_150_pointer_157, !noalias !2
        %tmp_5137_151_pointer_158 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 3
        %tmp_5137_151 = load i64, ptr %tmp_5137_151_pointer_158, !noalias !2
        %acc_8_35_199_4782_152_pointer_159 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 4
        %acc_8_35_199_4782_152 = load i64, ptr %acc_8_35_199_4782_152_pointer_159, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2926_30_194_4918_148)
        call ccc void @eraseFrames(%StackPointer %stackPointer_154)
        ret void
}



define tailcc void @returnAddress_170(%Pos %returned_5264, %Stack %stack) {
        
    entry:
        
        %stack_171 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_173 = call ccc %StackPointer @stackDeallocate(%Stack %stack_171, i64 24)
        %returnAddress_pointer_174 = getelementptr %FrameHeader, %StackPointer %stackPointer_173, i64 0, i32 0
        %returnAddress_172 = load %ReturnAddress, ptr %returnAddress_pointer_174, !noalias !2
        musttail call tailcc void %returnAddress_172(%Pos %returned_5264, %Stack %stack_171)
        ret void
}



define tailcc void @Exception_7_19_46_210_4867_clause_179(%Object %closure, %Pos %exc_8_20_47_211_4740, %Pos %msg_9_21_48_212_4822, %Stack %stack) {
        
    entry:
        
        %environment_180 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4704_pointer_181 = getelementptr <{%Prompt}>, %Environment %environment_180, i64 0, i32 0
        %p_6_18_45_209_4704 = load %Prompt, ptr %p_6_18_45_209_4704_pointer_181, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_182 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4704)
        %k_11_23_50_214_4986 = extractvalue <{%Resumption, %Stack}> %pair_182, 0
        %stack_183 = extractvalue <{%Resumption, %Stack}> %pair_182, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4986)
        
        %fields_184 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_185 = call ccc %Environment @objectEnvironment(%Object %fields_184)
        %exc_8_20_47_211_4740_pointer_188 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4740, ptr %exc_8_20_47_211_4740_pointer_188, !noalias !2
        %msg_9_21_48_212_4822_pointer_189 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4822, ptr %msg_9_21_48_212_4822_pointer_189, !noalias !2
        %make_5265_temporary_190 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5265 = insertvalue %Pos %make_5265_temporary_190, %Object %fields_184, 1
        
        
        
        %stackPointer_192 = call ccc %StackPointer @stackDeallocate(%Stack %stack_183, i64 24)
        %returnAddress_pointer_193 = getelementptr %FrameHeader, %StackPointer %stackPointer_192, i64 0, i32 0
        %returnAddress_191 = load %ReturnAddress, ptr %returnAddress_pointer_193, !noalias !2
        musttail call tailcc void %returnAddress_191(%Pos %make_5265, %Stack %stack_183)
        ret void
}


@vtable_194 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4867_clause_179]


define ccc void @eraser_198(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4704_197_pointer_199 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4704_197 = load %Prompt, ptr %p_6_18_45_209_4704_197_pointer_199, !noalias !2
        ret void
}



define ccc void @eraser_206(%Environment %environment) {
        
    entry:
        
        %tmp_5139_205_pointer_207 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5139_205 = load %Pos, ptr %tmp_5139_205_pointer_207, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5139_205)
        ret void
}



define tailcc void @returnAddress_202(i64 %v_coe_3933_6_28_55_219_4706, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5266 = call ccc %Pos @boxChar_311(i64 %v_coe_3933_6_28_55_219_4706)
        
        
        
        %fields_203 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_204 = call ccc %Environment @objectEnvironment(%Object %fields_203)
        %tmp_5139_pointer_208 = getelementptr <{%Pos}>, %Environment %environment_204, i64 0, i32 0
        store %Pos %pureApp_5266, ptr %tmp_5139_pointer_208, !noalias !2
        %make_5267_temporary_209 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5267 = insertvalue %Pos %make_5267_temporary_209, %Object %fields_203, 1
        
        
        
        %stackPointer_211 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_212 = getelementptr %FrameHeader, %StackPointer %stackPointer_211, i64 0, i32 0
        %returnAddress_210 = load %ReturnAddress, ptr %returnAddress_pointer_212, !noalias !2
        musttail call tailcc void %returnAddress_210(%Pos %make_5267, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4742(i64 %index_7_34_198_4725, i64 %acc_8_35_199_4782, %Pos %v_r_2926_30_194_4918, %Prompt %p_8_9_4663, i64 %tmp_5137, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2926_30_194_4918)
        %stackPointer_160 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %v_r_2926_30_194_4918_pointer_161 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 0
        store %Pos %v_r_2926_30_194_4918, ptr %v_r_2926_30_194_4918_pointer_161, !noalias !2
        %p_8_9_4663_pointer_162 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 1
        store %Prompt %p_8_9_4663, ptr %p_8_9_4663_pointer_162, !noalias !2
        %index_7_34_198_4725_pointer_163 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 2
        store i64 %index_7_34_198_4725, ptr %index_7_34_198_4725_pointer_163, !noalias !2
        %tmp_5137_pointer_164 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 3
        store i64 %tmp_5137, ptr %tmp_5137_pointer_164, !noalias !2
        %acc_8_35_199_4782_pointer_165 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 4
        store i64 %acc_8_35_199_4782, ptr %acc_8_35_199_4782_pointer_165, !noalias !2
        %returnAddress_pointer_166 = getelementptr <{<{%Pos, %Prompt, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 0
        %sharer_pointer_167 = getelementptr <{<{%Pos, %Prompt, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 1
        %eraser_pointer_168 = getelementptr <{<{%Pos, %Prompt, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 2
        store ptr @returnAddress_96, ptr %returnAddress_pointer_166, !noalias !2
        store ptr @sharer_141, ptr %sharer_pointer_167, !noalias !2
        store ptr @eraser_153, ptr %eraser_pointer_168, !noalias !2
        
        %stack_169 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4704 = call ccc %Prompt @currentPrompt(%Stack %stack_169)
        %stackPointer_175 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_176 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 0
        %sharer_pointer_177 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 1
        %eraser_pointer_178 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 2
        store ptr @returnAddress_170, ptr %returnAddress_pointer_176, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_177, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_178, !noalias !2
        
        %closure_195 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_196 = call ccc %Environment @objectEnvironment(%Object %closure_195)
        %p_6_18_45_209_4704_pointer_200 = getelementptr <{%Prompt}>, %Environment %environment_196, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4704, ptr %p_6_18_45_209_4704_pointer_200, !noalias !2
        %vtable_temporary_201 = insertvalue %Neg zeroinitializer, ptr @vtable_194, 0
        %Exception_7_19_46_210_4867 = insertvalue %Neg %vtable_temporary_201, %Object %closure_195, 1
        %stackPointer_213 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_214 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 0
        %sharer_pointer_215 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 1
        %eraser_pointer_216 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 2
        store ptr @returnAddress_202, ptr %returnAddress_pointer_214, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_215, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_216, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2926_30_194_4918, i64 %index_7_34_198_4725, %Neg %Exception_7_19_46_210_4867, %Stack %stack_169)
        ret void
}



define tailcc void @Exception_9_106_133_297_4908_clause_217(%Object %closure, %Pos %exception_10_107_134_298_5268, %Pos %msg_11_108_135_299_5269, %Stack %stack) {
        
    entry:
        
        %environment_218 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4663_pointer_219 = getelementptr <{%Prompt}>, %Environment %environment_218, i64 0, i32 0
        %p_8_9_4663 = load %Prompt, ptr %p_8_9_4663_pointer_219, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5268)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5269)
        
        %pair_220 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4663)
        %k_13_14_4_5107 = extractvalue <{%Resumption, %Stack}> %pair_220, 0
        %stack_221 = extractvalue <{%Resumption, %Stack}> %pair_220, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5107)
        
        %longLiteral_5270 = add i64 10, 0
        
        
        
        %pureApp_5271 = call ccc %Pos @boxInt_301(i64 %longLiteral_5270)
        
        
        
        %stackPointer_223 = call ccc %StackPointer @stackDeallocate(%Stack %stack_221, i64 24)
        %returnAddress_pointer_224 = getelementptr %FrameHeader, %StackPointer %stackPointer_223, i64 0, i32 0
        %returnAddress_222 = load %ReturnAddress, ptr %returnAddress_pointer_224, !noalias !2
        musttail call tailcc void %returnAddress_222(%Pos %pureApp_5271, %Stack %stack_221)
        ret void
}


@vtable_225 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4908_clause_217]


define tailcc void @returnAddress_236(i64 %v_coe_3938_22_131_158_322_4928, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5274 = call ccc %Pos @boxInt_301(i64 %v_coe_3938_22_131_158_322_4928)
        
        
        
        
        
        %pureApp_5275 = call ccc i64 @unboxInt_303(%Pos %pureApp_5274)
        
        
        
        %pureApp_5276 = call ccc %Pos @boxInt_301(i64 %pureApp_5275)
        
        
        
        %stackPointer_238 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_239 = getelementptr %FrameHeader, %StackPointer %stackPointer_238, i64 0, i32 0
        %returnAddress_237 = load %ReturnAddress, ptr %returnAddress_pointer_239, !noalias !2
        musttail call tailcc void %returnAddress_237(%Pos %pureApp_5276, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_248(i64 %v_r_3130_1_9_20_129_156_320_4762, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5280 = add i64 0, 0
        
        %pureApp_5279 = call ccc i64 @infixSub_105(i64 %longLiteral_5280, i64 %v_r_3130_1_9_20_129_156_320_4762)
        
        
        
        %stackPointer_250 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_251 = getelementptr %FrameHeader, %StackPointer %stackPointer_250, i64 0, i32 0
        %returnAddress_249 = load %ReturnAddress, ptr %returnAddress_pointer_251, !noalias !2
        musttail call tailcc void %returnAddress_249(i64 %pureApp_5279, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_231(i64 %v_r_3129_3_14_123_150_314_4812, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_232 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_2926_30_194_4918_pointer_233 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 0
        %v_r_2926_30_194_4918 = load %Pos, ptr %v_r_2926_30_194_4918_pointer_233, !noalias !2
        %p_8_9_4663_pointer_234 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 1
        %p_8_9_4663 = load %Prompt, ptr %p_8_9_4663_pointer_234, !noalias !2
        %tmp_5137_pointer_235 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 2
        %tmp_5137 = load i64, ptr %tmp_5137_pointer_235, !noalias !2
        
        %intLiteral_5273 = add i64 45, 0
        
        %pureApp_5272 = call ccc %Pos @infixEq_78(i64 %v_r_3129_3_14_123_150_314_4812, i64 %intLiteral_5273)
        
        
        %stackPointer_240 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_241 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 0
        %sharer_pointer_242 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 1
        %eraser_pointer_243 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 2
        store ptr @returnAddress_236, ptr %returnAddress_pointer_241, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_242, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_243, !noalias !2
        
        %tag_244 = extractvalue %Pos %pureApp_5272, 0
        %fields_245 = extractvalue %Pos %pureApp_5272, 1
        switch i64 %tag_244, label %label_246 [i64 0, label %label_247 i64 1, label %label_256]
    
    label_246:
        
        ret void
    
    label_247:
        
        %longLiteral_5277 = add i64 0, 0
        
        %longLiteral_5278 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4742(i64 %longLiteral_5277, i64 %longLiteral_5278, %Pos %v_r_2926_30_194_4918, %Prompt %p_8_9_4663, i64 %tmp_5137, %Stack %stack)
        ret void
    
    label_256:
        %stackPointer_252 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_253 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 0
        %sharer_pointer_254 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 1
        %eraser_pointer_255 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 2
        store ptr @returnAddress_248, ptr %returnAddress_pointer_253, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_254, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_255, !noalias !2
        
        %longLiteral_5281 = add i64 1, 0
        
        %longLiteral_5282 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4742(i64 %longLiteral_5281, i64 %longLiteral_5282, %Pos %v_r_2926_30_194_4918, %Prompt %p_8_9_4663, i64 %tmp_5137, %Stack %stack)
        ret void
}



define ccc void @sharer_260(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_261 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2926_30_194_4918_257_pointer_262 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 0
        %v_r_2926_30_194_4918_257 = load %Pos, ptr %v_r_2926_30_194_4918_257_pointer_262, !noalias !2
        %p_8_9_4663_258_pointer_263 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 1
        %p_8_9_4663_258 = load %Prompt, ptr %p_8_9_4663_258_pointer_263, !noalias !2
        %tmp_5137_259_pointer_264 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 2
        %tmp_5137_259 = load i64, ptr %tmp_5137_259_pointer_264, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2926_30_194_4918_257)
        call ccc void @shareFrames(%StackPointer %stackPointer_261)
        ret void
}



define ccc void @eraser_268(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_269 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2926_30_194_4918_265_pointer_270 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 0
        %v_r_2926_30_194_4918_265 = load %Pos, ptr %v_r_2926_30_194_4918_265_pointer_270, !noalias !2
        %p_8_9_4663_266_pointer_271 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 1
        %p_8_9_4663_266 = load %Prompt, ptr %p_8_9_4663_266_pointer_271, !noalias !2
        %tmp_5137_267_pointer_272 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 2
        %tmp_5137_267 = load i64, ptr %tmp_5137_267_pointer_272, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2926_30_194_4918_265)
        call ccc void @eraseFrames(%StackPointer %stackPointer_269)
        ret void
}



define tailcc void @returnAddress_93(%Pos %v_r_2926_30_194_4918, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_94 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4663_pointer_95 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_94, i64 0, i32 0
        %p_8_9_4663 = load %Prompt, ptr %p_8_9_4663_pointer_95, !noalias !2
        
        %intLiteral_5245 = add i64 48, 0
        
        %pureApp_5244 = call ccc i64 @toInt_2085(i64 %intLiteral_5245)
        
        
        
        %closure_226 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_227 = call ccc %Environment @objectEnvironment(%Object %closure_226)
        %p_8_9_4663_pointer_229 = getelementptr <{%Prompt}>, %Environment %environment_227, i64 0, i32 0
        store %Prompt %p_8_9_4663, ptr %p_8_9_4663_pointer_229, !noalias !2
        %vtable_temporary_230 = insertvalue %Neg zeroinitializer, ptr @vtable_225, 0
        %Exception_9_106_133_297_4908 = insertvalue %Neg %vtable_temporary_230, %Object %closure_226, 1
        call ccc void @sharePositive(%Pos %v_r_2926_30_194_4918)
        %stackPointer_273 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_2926_30_194_4918_pointer_274 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 0
        store %Pos %v_r_2926_30_194_4918, ptr %v_r_2926_30_194_4918_pointer_274, !noalias !2
        %p_8_9_4663_pointer_275 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 1
        store %Prompt %p_8_9_4663, ptr %p_8_9_4663_pointer_275, !noalias !2
        %tmp_5137_pointer_276 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 2
        store i64 %pureApp_5244, ptr %tmp_5137_pointer_276, !noalias !2
        %returnAddress_pointer_277 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 0
        %sharer_pointer_278 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 1
        %eraser_pointer_279 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 2
        store ptr @returnAddress_231, ptr %returnAddress_pointer_277, !noalias !2
        store ptr @sharer_260, ptr %sharer_pointer_278, !noalias !2
        store ptr @eraser_268, ptr %eraser_pointer_279, !noalias !2
        
        %longLiteral_5283 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2926_30_194_4918, i64 %longLiteral_5283, %Neg %Exception_9_106_133_297_4908, %Stack %stack)
        ret void
}



define ccc void @sharer_281(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_282 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4663_280_pointer_283 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_282, i64 0, i32 0
        %p_8_9_4663_280 = load %Prompt, ptr %p_8_9_4663_280_pointer_283, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_282)
        ret void
}



define ccc void @eraser_285(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_286 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4663_284_pointer_287 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_286, i64 0, i32 0
        %p_8_9_4663_284 = load %Prompt, ptr %p_8_9_4663_284_pointer_287, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_286)
        ret void
}


@utf8StringLiteral_5284.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_90(%Pos %v_r_2925_24_188_4973, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_91 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4663_pointer_92 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_91, i64 0, i32 0
        %p_8_9_4663 = load %Prompt, ptr %p_8_9_4663_pointer_92, !noalias !2
        %stackPointer_288 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4663_pointer_289 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_288, i64 0, i32 0
        store %Prompt %p_8_9_4663, ptr %p_8_9_4663_pointer_289, !noalias !2
        %returnAddress_pointer_290 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 0
        %sharer_pointer_291 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 1
        %eraser_pointer_292 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 2
        store ptr @returnAddress_93, ptr %returnAddress_pointer_290, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_291, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_292, !noalias !2
        
        %tag_293 = extractvalue %Pos %v_r_2925_24_188_4973, 0
        %fields_294 = extractvalue %Pos %v_r_2925_24_188_4973, 1
        switch i64 %tag_293, label %label_295 [i64 0, label %label_299 i64 1, label %label_305]
    
    label_295:
        
        ret void
    
    label_299:
        
        %utf8StringLiteral_5284 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5284.lit)
        
        %stackPointer_297 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_298 = getelementptr %FrameHeader, %StackPointer %stackPointer_297, i64 0, i32 0
        %returnAddress_296 = load %ReturnAddress, ptr %returnAddress_pointer_298, !noalias !2
        musttail call tailcc void %returnAddress_296(%Pos %utf8StringLiteral_5284, %Stack %stack)
        ret void
    
    label_305:
        %environment_300 = call ccc %Environment @objectEnvironment(%Object %fields_294)
        %v_y_3760_8_29_193_4741_pointer_301 = getelementptr <{%Pos}>, %Environment %environment_300, i64 0, i32 0
        %v_y_3760_8_29_193_4741 = load %Pos, ptr %v_y_3760_8_29_193_4741_pointer_301, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3760_8_29_193_4741)
        call ccc void @eraseObject(%Object %fields_294)
        
        %stackPointer_303 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_304 = getelementptr %FrameHeader, %StackPointer %stackPointer_303, i64 0, i32 0
        %returnAddress_302 = load %ReturnAddress, ptr %returnAddress_pointer_304, !noalias !2
        musttail call tailcc void %returnAddress_302(%Pos %v_y_3760_8_29_193_4741, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_87(%Pos %v_r_2924_13_177_4857, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_88 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4663_pointer_89 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_88, i64 0, i32 0
        %p_8_9_4663 = load %Prompt, ptr %p_8_9_4663_pointer_89, !noalias !2
        %stackPointer_308 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4663_pointer_309 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_308, i64 0, i32 0
        store %Prompt %p_8_9_4663, ptr %p_8_9_4663_pointer_309, !noalias !2
        %returnAddress_pointer_310 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 0
        %sharer_pointer_311 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 1
        %eraser_pointer_312 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 2
        store ptr @returnAddress_90, ptr %returnAddress_pointer_310, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_311, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_312, !noalias !2
        
        %tag_313 = extractvalue %Pos %v_r_2924_13_177_4857, 0
        %fields_314 = extractvalue %Pos %v_r_2924_13_177_4857, 1
        switch i64 %tag_313, label %label_315 [i64 0, label %label_320 i64 1, label %label_332]
    
    label_315:
        
        ret void
    
    label_320:
        
        %make_5285_temporary_316 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5285 = insertvalue %Pos %make_5285_temporary_316, %Object null, 1
        
        
        
        %stackPointer_318 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_319 = getelementptr %FrameHeader, %StackPointer %stackPointer_318, i64 0, i32 0
        %returnAddress_317 = load %ReturnAddress, ptr %returnAddress_pointer_319, !noalias !2
        musttail call tailcc void %returnAddress_317(%Pos %make_5285, %Stack %stack)
        ret void
    
    label_332:
        %environment_321 = call ccc %Environment @objectEnvironment(%Object %fields_314)
        %v_y_3269_10_21_185_4829_pointer_322 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 0
        %v_y_3269_10_21_185_4829 = load %Pos, ptr %v_y_3269_10_21_185_4829_pointer_322, !noalias !2
        %v_y_3270_11_22_186_4891_pointer_323 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 1
        %v_y_3270_11_22_186_4891 = load %Pos, ptr %v_y_3270_11_22_186_4891_pointer_323, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3269_10_21_185_4829)
        call ccc void @eraseObject(%Object %fields_314)
        
        %fields_324 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_325 = call ccc %Environment @objectEnvironment(%Object %fields_324)
        %v_y_3269_10_21_185_4829_pointer_327 = getelementptr <{%Pos}>, %Environment %environment_325, i64 0, i32 0
        store %Pos %v_y_3269_10_21_185_4829, ptr %v_y_3269_10_21_185_4829_pointer_327, !noalias !2
        %make_5286_temporary_328 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5286 = insertvalue %Pos %make_5286_temporary_328, %Object %fields_324, 1
        
        
        
        %stackPointer_330 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_331 = getelementptr %FrameHeader, %StackPointer %stackPointer_330, i64 0, i32 0
        %returnAddress_329 = load %ReturnAddress, ptr %returnAddress_pointer_331, !noalias !2
        musttail call tailcc void %returnAddress_329(%Pos %make_5286, %Stack %stack)
        ret void
}



define tailcc void @main_2854(%Stack %stack) {
        
    entry:
        
        %stackPointer_50 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_51 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 0
        %sharer_pointer_52 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 1
        %eraser_pointer_53 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_51, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_52, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_53, !noalias !2
        
        %stack_54 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4663 = call ccc %Prompt @currentPrompt(%Stack %stack_54)
        %stackPointer_64 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 24)
        %returnAddress_pointer_65 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 0
        %sharer_pointer_66 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 1
        %eraser_pointer_67 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 2
        store ptr @returnAddress_55, ptr %returnAddress_pointer_65, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_66, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_67, !noalias !2
        
        %pureApp_5240 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5242 = add i64 1, 0
        
        %pureApp_5241 = call ccc i64 @infixSub_105(i64 %pureApp_5240, i64 %longLiteral_5242)
        
        
        
        %make_5243_temporary_86 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5243 = insertvalue %Pos %make_5243_temporary_86, %Object null, 1
        
        
        %stackPointer_335 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 32)
        %p_8_9_4663_pointer_336 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_335, i64 0, i32 0
        store %Prompt %p_8_9_4663, ptr %p_8_9_4663_pointer_336, !noalias !2
        %returnAddress_pointer_337 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 0
        %sharer_pointer_338 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 1
        %eraser_pointer_339 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 2
        store ptr @returnAddress_87, ptr %returnAddress_pointer_337, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_338, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_339, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4935(i64 %pureApp_5241, %Pos %make_5243, %Stack %stack_54)
        ret void
}



define tailcc void @returnAddress_340(i64 %returnValue_341, %Stack %stack) {
        
    entry:
        
        %stackPointer_342 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2906_4035_pointer_343 = getelementptr <{i64}>, %StackPointer %stackPointer_342, i64 0, i32 0
        %v_r_2906_4035 = load i64, ptr %v_r_2906_4035_pointer_343, !noalias !2
        %stackPointer_345 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_346 = getelementptr %FrameHeader, %StackPointer %stackPointer_345, i64 0, i32 0
        %returnAddress_344 = load %ReturnAddress, ptr %returnAddress_pointer_346, !noalias !2
        musttail call tailcc void %returnAddress_344(i64 %returnValue_341, %Stack %stack)
        ret void
}



define ccc void @sharer_348(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_349 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2906_4035_347_pointer_350 = getelementptr <{i64}>, %StackPointer %stackPointer_349, i64 0, i32 0
        %v_r_2906_4035_347 = load i64, ptr %v_r_2906_4035_347_pointer_350, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_349)
        ret void
}



define ccc void @eraser_352(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_353 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2906_4035_351_pointer_354 = getelementptr <{i64}>, %StackPointer %stackPointer_353, i64 0, i32 0
        %v_r_2906_4035_351 = load i64, ptr %v_r_2906_4035_351_pointer_354, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_353)
        ret void
}



define tailcc void @loop_5_9_4293(i64 %i_6_10_4286, i64 %size_2852, %Pos %tmp_5166, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5185 = call ccc %Pos @infixLt_178(i64 %i_6_10_4286, i64 %size_2852)
        
        
        
        %tag_360 = extractvalue %Pos %pureApp_5185, 0
        %fields_361 = extractvalue %Pos %pureApp_5185, 1
        switch i64 %tag_360, label %label_362 [i64 0, label %label_367 i64 1, label %label_369]
    
    label_362:
        
        ret void
    
    label_367:
        call ccc void @erasePositive(%Pos %tmp_5166)
        
        %unitLiteral_5186_temporary_363 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5186 = insertvalue %Pos %unitLiteral_5186_temporary_363, %Object null, 1
        
        %stackPointer_365 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_366 = getelementptr %FrameHeader, %StackPointer %stackPointer_365, i64 0, i32 0
        %returnAddress_364 = load %ReturnAddress, ptr %returnAddress_pointer_366, !noalias !2
        musttail call tailcc void %returnAddress_364(%Pos %unitLiteral_5186, %Stack %stack)
        ret void
    
    label_369:
        
        %booleanLiteral_5188_temporary_368 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5188 = insertvalue %Pos %booleanLiteral_5188_temporary_368, %Object null, 1
        
        call ccc void @sharePositive(%Pos %tmp_5166)
        %pureApp_5187 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5166, i64 %i_6_10_4286, %Pos %booleanLiteral_5188)
        call ccc void @erasePositive(%Pos %pureApp_5187)
        
        
        
        %longLiteral_5190 = add i64 1, 0
        
        %pureApp_5189 = call ccc i64 @infixAdd_96(i64 %i_6_10_4286, i64 %longLiteral_5190)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_4293(i64 %pureApp_5189, i64 %size_2852, %Pos %tmp_5166, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_383(%Pos %__8_4308, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_384 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %i_6_4306_pointer_385 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_384, i64 0, i32 0
        %i_6_4306 = load i64, ptr %i_6_4306_pointer_385, !noalias !2
        %size_2852_pointer_386 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_384, i64 0, i32 1
        %size_2852 = load i64, ptr %size_2852_pointer_386, !noalias !2
        %tmp_5166_pointer_387 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_384, i64 0, i32 2
        %tmp_5166 = load %Pos, ptr %tmp_5166_pointer_387, !noalias !2
        %primeCount_2857_pointer_388 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_384, i64 0, i32 3
        %primeCount_2857 = load %Reference, ptr %primeCount_2857_pointer_388, !noalias !2
        call ccc void @erasePositive(%Pos %__8_4308)
        
        %longLiteral_5197 = add i64 1, 0
        
        %pureApp_5196 = call ccc i64 @infixAdd_96(i64 %i_6_4306, i64 %longLiteral_5197)
        
        
        
        
        
        musttail call tailcc void @loop_5_4304(i64 %pureApp_5196, i64 %size_2852, %Pos %tmp_5166, %Reference %primeCount_2857, %Stack %stack)
        ret void
}



define ccc void @sharer_393(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_394 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_4306_389_pointer_395 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_394, i64 0, i32 0
        %i_6_4306_389 = load i64, ptr %i_6_4306_389_pointer_395, !noalias !2
        %size_2852_390_pointer_396 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_394, i64 0, i32 1
        %size_2852_390 = load i64, ptr %size_2852_390_pointer_396, !noalias !2
        %tmp_5166_391_pointer_397 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_394, i64 0, i32 2
        %tmp_5166_391 = load %Pos, ptr %tmp_5166_391_pointer_397, !noalias !2
        %primeCount_2857_392_pointer_398 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_394, i64 0, i32 3
        %primeCount_2857_392 = load %Reference, ptr %primeCount_2857_392_pointer_398, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5166_391)
        call ccc void @shareFrames(%StackPointer %stackPointer_394)
        ret void
}



define ccc void @eraser_403(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_404 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_4306_399_pointer_405 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_404, i64 0, i32 0
        %i_6_4306_399 = load i64, ptr %i_6_4306_399_pointer_405, !noalias !2
        %size_2852_400_pointer_406 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_404, i64 0, i32 1
        %size_2852_400 = load i64, ptr %size_2852_400_pointer_406, !noalias !2
        %tmp_5166_401_pointer_407 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_404, i64 0, i32 2
        %tmp_5166_401 = load %Pos, ptr %tmp_5166_401_pointer_407, !noalias !2
        %primeCount_2857_402_pointer_408 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_404, i64 0, i32 3
        %primeCount_2857_402 = load %Reference, ptr %primeCount_2857_402_pointer_408, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5166_401)
        call ccc void @eraseFrames(%StackPointer %stackPointer_404)
        ret void
}



define tailcc void @returnAddress_436(%Pos %returnValue_437, %Stack %stack) {
        
    entry:
        
        %stackPointer_438 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_5124_pointer_439 = getelementptr <{i64}>, %StackPointer %stackPointer_438, i64 0, i32 0
        %tmp_5124 = load i64, ptr %tmp_5124_pointer_439, !noalias !2
        %stackPointer_441 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_442 = getelementptr %FrameHeader, %StackPointer %stackPointer_441, i64 0, i32 0
        %returnAddress_440 = load %ReturnAddress, ptr %returnAddress_pointer_442, !noalias !2
        musttail call tailcc void %returnAddress_440(%Pos %returnValue_437, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_477(%Pos %v_whileThen_2918_19_4329, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_478 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %i_6_4306_pointer_479 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_478, i64 0, i32 0
        %i_6_4306 = load i64, ptr %i_6_4306_pointer_479, !noalias !2
        %size_2852_pointer_480 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_478, i64 0, i32 1
        %size_2852 = load i64, ptr %size_2852_pointer_480, !noalias !2
        %k_9_4325_pointer_481 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_478, i64 0, i32 2
        %k_9_4325 = load %Reference, ptr %k_9_4325_pointer_481, !noalias !2
        %tmp_5166_pointer_482 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_478, i64 0, i32 3
        %tmp_5166 = load %Pos, ptr %tmp_5166_pointer_482, !noalias !2
        call ccc void @erasePositive(%Pos %v_whileThen_2918_19_4329)
        
        
        musttail call tailcc void @b_whileLoop_2913_10_4314(i64 %i_6_4306, i64 %size_2852, %Reference %k_9_4325, %Pos %tmp_5166, %Stack %stack)
        ret void
}



define ccc void @sharer_487(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_488 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %i_6_4306_483_pointer_489 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_488, i64 0, i32 0
        %i_6_4306_483 = load i64, ptr %i_6_4306_483_pointer_489, !noalias !2
        %size_2852_484_pointer_490 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_488, i64 0, i32 1
        %size_2852_484 = load i64, ptr %size_2852_484_pointer_490, !noalias !2
        %k_9_4325_485_pointer_491 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_488, i64 0, i32 2
        %k_9_4325_485 = load %Reference, ptr %k_9_4325_485_pointer_491, !noalias !2
        %tmp_5166_486_pointer_492 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_488, i64 0, i32 3
        %tmp_5166_486 = load %Pos, ptr %tmp_5166_486_pointer_492, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5166_486)
        call ccc void @shareFrames(%StackPointer %stackPointer_488)
        ret void
}



define ccc void @eraser_497(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_498 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %i_6_4306_493_pointer_499 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_498, i64 0, i32 0
        %i_6_4306_493 = load i64, ptr %i_6_4306_493_pointer_499, !noalias !2
        %size_2852_494_pointer_500 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_498, i64 0, i32 1
        %size_2852_494 = load i64, ptr %size_2852_494_pointer_500, !noalias !2
        %k_9_4325_495_pointer_501 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_498, i64 0, i32 2
        %k_9_4325_495 = load %Reference, ptr %k_9_4325_495_pointer_501, !noalias !2
        %tmp_5166_496_pointer_502 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_498, i64 0, i32 3
        %tmp_5166_496 = load %Pos, ptr %tmp_5166_496_pointer_502, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5166_496)
        call ccc void @eraseFrames(%StackPointer %stackPointer_498)
        ret void
}



define tailcc void @returnAddress_471(i64 %v_r_2916_17_4319, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_472 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %i_6_4306_pointer_473 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_472, i64 0, i32 0
        %i_6_4306 = load i64, ptr %i_6_4306_pointer_473, !noalias !2
        %size_2852_pointer_474 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_472, i64 0, i32 1
        %size_2852 = load i64, ptr %size_2852_pointer_474, !noalias !2
        %k_9_4325_pointer_475 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_472, i64 0, i32 2
        %k_9_4325 = load %Reference, ptr %k_9_4325_pointer_475, !noalias !2
        %tmp_5166_pointer_476 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_472, i64 0, i32 3
        %tmp_5166 = load %Pos, ptr %tmp_5166_pointer_476, !noalias !2
        
        %pureApp_5209 = call ccc i64 @infixAdd_96(i64 %v_r_2916_17_4319, i64 %i_6_4306)
        
        
        %stackPointer_503 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %i_6_4306_pointer_504 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_503, i64 0, i32 0
        store i64 %i_6_4306, ptr %i_6_4306_pointer_504, !noalias !2
        %size_2852_pointer_505 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_503, i64 0, i32 1
        store i64 %size_2852, ptr %size_2852_pointer_505, !noalias !2
        %k_9_4325_pointer_506 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_503, i64 0, i32 2
        store %Reference %k_9_4325, ptr %k_9_4325_pointer_506, !noalias !2
        %tmp_5166_pointer_507 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_503, i64 0, i32 3
        store %Pos %tmp_5166, ptr %tmp_5166_pointer_507, !noalias !2
        %returnAddress_pointer_508 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_503, i64 0, i32 1, i32 0
        %sharer_pointer_509 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_503, i64 0, i32 1, i32 1
        %eraser_pointer_510 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_503, i64 0, i32 1, i32 2
        store ptr @returnAddress_477, ptr %returnAddress_pointer_508, !noalias !2
        store ptr @sharer_487, ptr %sharer_pointer_509, !noalias !2
        store ptr @eraser_497, ptr %eraser_pointer_510, !noalias !2
        
        %k_9_4325pointer_511 = call ccc ptr @getVarPointer(%Reference %k_9_4325, %Stack %stack)
        %k_9_4325_old_512 = load i64, ptr %k_9_4325pointer_511, !noalias !2
        store i64 %pureApp_5209, ptr %k_9_4325pointer_511, !noalias !2
        
        %put_5210_temporary_513 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5210 = insertvalue %Pos %put_5210_temporary_513, %Object null, 1
        
        %stackPointer_515 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_516 = getelementptr %FrameHeader, %StackPointer %stackPointer_515, i64 0, i32 0
        %returnAddress_514 = load %ReturnAddress, ptr %returnAddress_pointer_516, !noalias !2
        musttail call tailcc void %returnAddress_514(%Pos %put_5210, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_464(i64 %v_r_2914_13_4313, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_465 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %i_6_4306_pointer_466 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_465, i64 0, i32 0
        %i_6_4306 = load i64, ptr %i_6_4306_pointer_466, !noalias !2
        %size_2852_pointer_467 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_465, i64 0, i32 1
        %size_2852 = load i64, ptr %size_2852_pointer_467, !noalias !2
        %k_9_4325_pointer_468 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_465, i64 0, i32 2
        %k_9_4325 = load %Reference, ptr %k_9_4325_pointer_468, !noalias !2
        %tmp_5166_pointer_469 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_465, i64 0, i32 3
        %tmp_5166 = load %Pos, ptr %tmp_5166_pointer_469, !noalias !2
        
        %longLiteral_5206 = add i64 1, 0
        
        %pureApp_5205 = call ccc i64 @infixSub_105(i64 %v_r_2914_13_4313, i64 %longLiteral_5206)
        
        
        
        %booleanLiteral_5208_temporary_470 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_5208 = insertvalue %Pos %booleanLiteral_5208_temporary_470, %Object null, 1
        
        call ccc void @sharePositive(%Pos %tmp_5166)
        %pureApp_5207 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5166, i64 %pureApp_5205, %Pos %booleanLiteral_5208)
        call ccc void @erasePositive(%Pos %pureApp_5207)
        
        
        %stackPointer_525 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %i_6_4306_pointer_526 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_525, i64 0, i32 0
        store i64 %i_6_4306, ptr %i_6_4306_pointer_526, !noalias !2
        %size_2852_pointer_527 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_525, i64 0, i32 1
        store i64 %size_2852, ptr %size_2852_pointer_527, !noalias !2
        %k_9_4325_pointer_528 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_525, i64 0, i32 2
        store %Reference %k_9_4325, ptr %k_9_4325_pointer_528, !noalias !2
        %tmp_5166_pointer_529 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_525, i64 0, i32 3
        store %Pos %tmp_5166, ptr %tmp_5166_pointer_529, !noalias !2
        %returnAddress_pointer_530 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_525, i64 0, i32 1, i32 0
        %sharer_pointer_531 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_525, i64 0, i32 1, i32 1
        %eraser_pointer_532 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_525, i64 0, i32 1, i32 2
        store ptr @returnAddress_471, ptr %returnAddress_pointer_530, !noalias !2
        store ptr @sharer_487, ptr %sharer_pointer_531, !noalias !2
        store ptr @eraser_497, ptr %eraser_pointer_532, !noalias !2
        
        %get_5211_pointer_533 = call ccc ptr @getVarPointer(%Reference %k_9_4325, %Stack %stack)
        %k_9_4325_old_534 = load i64, ptr %get_5211_pointer_533, !noalias !2
        %get_5211 = load i64, ptr %get_5211_pointer_533, !noalias !2
        
        %stackPointer_536 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_537 = getelementptr %FrameHeader, %StackPointer %stackPointer_536, i64 0, i32 0
        %returnAddress_535 = load %ReturnAddress, ptr %returnAddress_pointer_537, !noalias !2
        musttail call tailcc void %returnAddress_535(i64 %get_5211, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_450(i64 %v_r_2919_11_4316, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_451 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %i_6_4306_pointer_452 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_451, i64 0, i32 0
        %i_6_4306 = load i64, ptr %i_6_4306_pointer_452, !noalias !2
        %size_2852_pointer_453 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_451, i64 0, i32 1
        %size_2852 = load i64, ptr %size_2852_pointer_453, !noalias !2
        %k_9_4325_pointer_454 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_451, i64 0, i32 2
        %k_9_4325 = load %Reference, ptr %k_9_4325_pointer_454, !noalias !2
        %tmp_5166_pointer_455 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_451, i64 0, i32 3
        %tmp_5166 = load %Pos, ptr %tmp_5166_pointer_455, !noalias !2
        
        %pureApp_5203 = call ccc %Pos @infixLte_181(i64 %v_r_2919_11_4316, i64 %size_2852)
        
        
        
        %tag_456 = extractvalue %Pos %pureApp_5203, 0
        %fields_457 = extractvalue %Pos %pureApp_5203, 1
        switch i64 %tag_456, label %label_458 [i64 0, label %label_463 i64 1, label %label_559]
    
    label_458:
        
        ret void
    
    label_463:
        call ccc void @erasePositive(%Pos %tmp_5166)
        
        %unitLiteral_5204_temporary_459 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5204 = insertvalue %Pos %unitLiteral_5204_temporary_459, %Object null, 1
        
        %stackPointer_461 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_462 = getelementptr %FrameHeader, %StackPointer %stackPointer_461, i64 0, i32 0
        %returnAddress_460 = load %ReturnAddress, ptr %returnAddress_pointer_462, !noalias !2
        musttail call tailcc void %returnAddress_460(%Pos %unitLiteral_5204, %Stack %stack)
        ret void
    
    label_559:
        %stackPointer_546 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %i_6_4306_pointer_547 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_546, i64 0, i32 0
        store i64 %i_6_4306, ptr %i_6_4306_pointer_547, !noalias !2
        %size_2852_pointer_548 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_546, i64 0, i32 1
        store i64 %size_2852, ptr %size_2852_pointer_548, !noalias !2
        %k_9_4325_pointer_549 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_546, i64 0, i32 2
        store %Reference %k_9_4325, ptr %k_9_4325_pointer_549, !noalias !2
        %tmp_5166_pointer_550 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_546, i64 0, i32 3
        store %Pos %tmp_5166, ptr %tmp_5166_pointer_550, !noalias !2
        %returnAddress_pointer_551 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_546, i64 0, i32 1, i32 0
        %sharer_pointer_552 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_546, i64 0, i32 1, i32 1
        %eraser_pointer_553 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_546, i64 0, i32 1, i32 2
        store ptr @returnAddress_464, ptr %returnAddress_pointer_551, !noalias !2
        store ptr @sharer_487, ptr %sharer_pointer_552, !noalias !2
        store ptr @eraser_497, ptr %eraser_pointer_553, !noalias !2
        
        %get_5212_pointer_554 = call ccc ptr @getVarPointer(%Reference %k_9_4325, %Stack %stack)
        %k_9_4325_old_555 = load i64, ptr %get_5212_pointer_554, !noalias !2
        %get_5212 = load i64, ptr %get_5212_pointer_554, !noalias !2
        
        %stackPointer_557 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_558 = getelementptr %FrameHeader, %StackPointer %stackPointer_557, i64 0, i32 0
        %returnAddress_556 = load %ReturnAddress, ptr %returnAddress_pointer_558, !noalias !2
        musttail call tailcc void %returnAddress_556(i64 %get_5212, %Stack %stack)
        ret void
}



define tailcc void @b_whileLoop_2913_10_4314(i64 %i_6_4306, i64 %size_2852, %Reference %k_9_4325, %Pos %tmp_5166, %Stack %stack) {
        
    entry:
        
        %stackPointer_568 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %i_6_4306_pointer_569 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_568, i64 0, i32 0
        store i64 %i_6_4306, ptr %i_6_4306_pointer_569, !noalias !2
        %size_2852_pointer_570 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_568, i64 0, i32 1
        store i64 %size_2852, ptr %size_2852_pointer_570, !noalias !2
        %k_9_4325_pointer_571 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_568, i64 0, i32 2
        store %Reference %k_9_4325, ptr %k_9_4325_pointer_571, !noalias !2
        %tmp_5166_pointer_572 = getelementptr <{i64, i64, %Reference, %Pos}>, %StackPointer %stackPointer_568, i64 0, i32 3
        store %Pos %tmp_5166, ptr %tmp_5166_pointer_572, !noalias !2
        %returnAddress_pointer_573 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_568, i64 0, i32 1, i32 0
        %sharer_pointer_574 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_568, i64 0, i32 1, i32 1
        %eraser_pointer_575 = getelementptr <{<{i64, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_568, i64 0, i32 1, i32 2
        store ptr @returnAddress_450, ptr %returnAddress_pointer_573, !noalias !2
        store ptr @sharer_487, ptr %sharer_pointer_574, !noalias !2
        store ptr @eraser_497, ptr %eraser_pointer_575, !noalias !2
        
        %get_5213_pointer_576 = call ccc ptr @getVarPointer(%Reference %k_9_4325, %Stack %stack)
        %k_9_4325_old_577 = load i64, ptr %get_5213_pointer_576, !noalias !2
        %get_5213 = load i64, ptr %get_5213_pointer_576, !noalias !2
        
        %stackPointer_579 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_580 = getelementptr %FrameHeader, %StackPointer %stackPointer_579, i64 0, i32 0
        %returnAddress_578 = load %ReturnAddress, ptr %returnAddress_pointer_580, !noalias !2
        musttail call tailcc void %returnAddress_578(i64 %get_5213, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_431(%Pos %__6_4327, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_432 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_6_4306_pointer_433 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_432, i64 0, i32 0
        %i_6_4306 = load i64, ptr %i_6_4306_pointer_433, !noalias !2
        %size_2852_pointer_434 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_432, i64 0, i32 1
        %size_2852 = load i64, ptr %size_2852_pointer_434, !noalias !2
        %tmp_5166_pointer_435 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_432, i64 0, i32 2
        %tmp_5166 = load %Pos, ptr %tmp_5166_pointer_435, !noalias !2
        call ccc void @erasePositive(%Pos %__6_4327)
        
        %pureApp_5201 = call ccc i64 @infixAdd_96(i64 %i_6_4306, i64 %i_6_4306)
        
        
        %k_9_4325 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_445 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_5124_pointer_446 = getelementptr <{i64}>, %StackPointer %stackPointer_445, i64 0, i32 0
        store i64 %pureApp_5201, ptr %tmp_5124_pointer_446, !noalias !2
        %returnAddress_pointer_447 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_445, i64 0, i32 1, i32 0
        %sharer_pointer_448 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_445, i64 0, i32 1, i32 1
        %eraser_pointer_449 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_445, i64 0, i32 1, i32 2
        store ptr @returnAddress_436, ptr %returnAddress_pointer_447, !noalias !2
        store ptr @sharer_348, ptr %sharer_pointer_448, !noalias !2
        store ptr @eraser_352, ptr %eraser_pointer_449, !noalias !2
        
        
        musttail call tailcc void @b_whileLoop_2913_10_4314(i64 %i_6_4306, i64 %size_2852, %Reference %k_9_4325, %Pos %tmp_5166, %Stack %stack)
        ret void
}



define ccc void @sharer_584(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_585 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %i_6_4306_581_pointer_586 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_585, i64 0, i32 0
        %i_6_4306_581 = load i64, ptr %i_6_4306_581_pointer_586, !noalias !2
        %size_2852_582_pointer_587 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_585, i64 0, i32 1
        %size_2852_582 = load i64, ptr %size_2852_582_pointer_587, !noalias !2
        %tmp_5166_583_pointer_588 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_585, i64 0, i32 2
        %tmp_5166_583 = load %Pos, ptr %tmp_5166_583_pointer_588, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5166_583)
        call ccc void @shareFrames(%StackPointer %stackPointer_585)
        ret void
}



define ccc void @eraser_592(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_593 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %i_6_4306_589_pointer_594 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_593, i64 0, i32 0
        %i_6_4306_589 = load i64, ptr %i_6_4306_589_pointer_594, !noalias !2
        %size_2852_590_pointer_595 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_593, i64 0, i32 1
        %size_2852_590 = load i64, ptr %size_2852_590_pointer_595, !noalias !2
        %tmp_5166_591_pointer_596 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_593, i64 0, i32 2
        %tmp_5166_591 = load %Pos, ptr %tmp_5166_591_pointer_596, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5166_591)
        call ccc void @eraseFrames(%StackPointer %stackPointer_593)
        ret void
}



define tailcc void @returnAddress_425(i64 %v_r_2910_4_4321, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_426 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %i_6_4306_pointer_427 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_426, i64 0, i32 0
        %i_6_4306 = load i64, ptr %i_6_4306_pointer_427, !noalias !2
        %size_2852_pointer_428 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_426, i64 0, i32 1
        %size_2852 = load i64, ptr %size_2852_pointer_428, !noalias !2
        %tmp_5166_pointer_429 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_426, i64 0, i32 2
        %tmp_5166 = load %Pos, ptr %tmp_5166_pointer_429, !noalias !2
        %primeCount_2857_pointer_430 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_426, i64 0, i32 3
        %primeCount_2857 = load %Reference, ptr %primeCount_2857_pointer_430, !noalias !2
        
        %longLiteral_5200 = add i64 1, 0
        
        %pureApp_5199 = call ccc i64 @infixAdd_96(i64 %v_r_2910_4_4321, i64 %longLiteral_5200)
        
        
        %stackPointer_597 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_6_4306_pointer_598 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_597, i64 0, i32 0
        store i64 %i_6_4306, ptr %i_6_4306_pointer_598, !noalias !2
        %size_2852_pointer_599 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_597, i64 0, i32 1
        store i64 %size_2852, ptr %size_2852_pointer_599, !noalias !2
        %tmp_5166_pointer_600 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_597, i64 0, i32 2
        store %Pos %tmp_5166, ptr %tmp_5166_pointer_600, !noalias !2
        %returnAddress_pointer_601 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_597, i64 0, i32 1, i32 0
        %sharer_pointer_602 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_597, i64 0, i32 1, i32 1
        %eraser_pointer_603 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_597, i64 0, i32 1, i32 2
        store ptr @returnAddress_431, ptr %returnAddress_pointer_601, !noalias !2
        store ptr @sharer_584, ptr %sharer_pointer_602, !noalias !2
        store ptr @eraser_592, ptr %eraser_pointer_603, !noalias !2
        
        %primeCount_2857pointer_604 = call ccc ptr @getVarPointer(%Reference %primeCount_2857, %Stack %stack)
        %primeCount_2857_old_605 = load i64, ptr %primeCount_2857pointer_604, !noalias !2
        store i64 %pureApp_5199, ptr %primeCount_2857pointer_604, !noalias !2
        
        %put_5214_temporary_606 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5214 = insertvalue %Pos %put_5214_temporary_606, %Object null, 1
        
        %stackPointer_608 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_609 = getelementptr %FrameHeader, %StackPointer %stackPointer_608, i64 0, i32 0
        %returnAddress_607 = load %ReturnAddress, ptr %returnAddress_pointer_609, !noalias !2
        musttail call tailcc void %returnAddress_607(%Pos %put_5214, %Stack %stack)
        ret void
}



define tailcc void @loop_5_4304(i64 %i_6_4306, i64 %size_2852, %Pos %tmp_5166, %Reference %primeCount_2857, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5191 = call ccc %Pos @infixLt_178(i64 %i_6_4306, i64 %size_2852)
        
        
        
        %tag_375 = extractvalue %Pos %pureApp_5191, 0
        %fields_376 = extractvalue %Pos %pureApp_5191, 1
        switch i64 %tag_375, label %label_377 [i64 0, label %label_382 i64 1, label %label_632]
    
    label_377:
        
        ret void
    
    label_382:
        call ccc void @erasePositive(%Pos %tmp_5166)
        
        %unitLiteral_5192_temporary_378 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5192 = insertvalue %Pos %unitLiteral_5192_temporary_378, %Object null, 1
        
        %stackPointer_380 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_381 = getelementptr %FrameHeader, %StackPointer %stackPointer_380, i64 0, i32 0
        %returnAddress_379 = load %ReturnAddress, ptr %returnAddress_pointer_381, !noalias !2
        musttail call tailcc void %returnAddress_379(%Pos %unitLiteral_5192, %Stack %stack)
        ret void
    
    label_419:
        
        ret void
    
    label_424:
        call ccc void @erasePositive(%Pos %tmp_5166)
        
        %unitLiteral_5198_temporary_420 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5198 = insertvalue %Pos %unitLiteral_5198_temporary_420, %Object null, 1
        
        %stackPointer_422 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_423 = getelementptr %FrameHeader, %StackPointer %stackPointer_422, i64 0, i32 0
        %returnAddress_421 = load %ReturnAddress, ptr %returnAddress_pointer_423, !noalias !2
        musttail call tailcc void %returnAddress_421(%Pos %unitLiteral_5198, %Stack %stack)
        ret void
    
    label_631:
        %stackPointer_618 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %i_6_4306_pointer_619 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_618, i64 0, i32 0
        store i64 %i_6_4306, ptr %i_6_4306_pointer_619, !noalias !2
        %size_2852_pointer_620 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_618, i64 0, i32 1
        store i64 %size_2852, ptr %size_2852_pointer_620, !noalias !2
        %tmp_5166_pointer_621 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_618, i64 0, i32 2
        store %Pos %tmp_5166, ptr %tmp_5166_pointer_621, !noalias !2
        %primeCount_2857_pointer_622 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_618, i64 0, i32 3
        store %Reference %primeCount_2857, ptr %primeCount_2857_pointer_622, !noalias !2
        %returnAddress_pointer_623 = getelementptr <{<{i64, i64, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_618, i64 0, i32 1, i32 0
        %sharer_pointer_624 = getelementptr <{<{i64, i64, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_618, i64 0, i32 1, i32 1
        %eraser_pointer_625 = getelementptr <{<{i64, i64, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_618, i64 0, i32 1, i32 2
        store ptr @returnAddress_425, ptr %returnAddress_pointer_623, !noalias !2
        store ptr @sharer_393, ptr %sharer_pointer_624, !noalias !2
        store ptr @eraser_403, ptr %eraser_pointer_625, !noalias !2
        
        %get_5215_pointer_626 = call ccc ptr @getVarPointer(%Reference %primeCount_2857, %Stack %stack)
        %primeCount_2857_old_627 = load i64, ptr %get_5215_pointer_626, !noalias !2
        %get_5215 = load i64, ptr %get_5215_pointer_626, !noalias !2
        
        %stackPointer_629 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_630 = getelementptr %FrameHeader, %StackPointer %stackPointer_629, i64 0, i32 0
        %returnAddress_628 = load %ReturnAddress, ptr %returnAddress_pointer_630, !noalias !2
        musttail call tailcc void %returnAddress_628(i64 %get_5215, %Stack %stack)
        ret void
    
    label_632:
        
        %longLiteral_5194 = add i64 1, 0
        
        %pureApp_5193 = call ccc i64 @infixSub_105(i64 %i_6_4306, i64 %longLiteral_5194)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_5166)
        %pureApp_5195 = call ccc %Pos @unsafeGet_2487(%Pos %tmp_5166, i64 %pureApp_5193)
        
        
        call ccc void @sharePositive(%Pos %tmp_5166)
        %stackPointer_409 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %i_6_4306_pointer_410 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_409, i64 0, i32 0
        store i64 %i_6_4306, ptr %i_6_4306_pointer_410, !noalias !2
        %size_2852_pointer_411 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_409, i64 0, i32 1
        store i64 %size_2852, ptr %size_2852_pointer_411, !noalias !2
        %tmp_5166_pointer_412 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_409, i64 0, i32 2
        store %Pos %tmp_5166, ptr %tmp_5166_pointer_412, !noalias !2
        %primeCount_2857_pointer_413 = getelementptr <{i64, i64, %Pos, %Reference}>, %StackPointer %stackPointer_409, i64 0, i32 3
        store %Reference %primeCount_2857, ptr %primeCount_2857_pointer_413, !noalias !2
        %returnAddress_pointer_414 = getelementptr <{<{i64, i64, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_409, i64 0, i32 1, i32 0
        %sharer_pointer_415 = getelementptr <{<{i64, i64, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_409, i64 0, i32 1, i32 1
        %eraser_pointer_416 = getelementptr <{<{i64, i64, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_409, i64 0, i32 1, i32 2
        store ptr @returnAddress_383, ptr %returnAddress_pointer_414, !noalias !2
        store ptr @sharer_393, ptr %sharer_pointer_415, !noalias !2
        store ptr @eraser_403, ptr %eraser_pointer_416, !noalias !2
        
        %tag_417 = extractvalue %Pos %pureApp_5195, 0
        %fields_418 = extractvalue %Pos %pureApp_5195, 1
        switch i64 %tag_417, label %label_419 [i64 0, label %label_424 i64 1, label %label_631]
}



define tailcc void @returnAddress_633(%Pos %__5216, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_634 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %primeCount_2857_pointer_635 = getelementptr <{%Reference}>, %StackPointer %stackPointer_634, i64 0, i32 0
        %primeCount_2857 = load %Reference, ptr %primeCount_2857_pointer_635, !noalias !2
        call ccc void @erasePositive(%Pos %__5216)
        
        %get_5217_pointer_636 = call ccc ptr @getVarPointer(%Reference %primeCount_2857, %Stack %stack)
        %primeCount_2857_old_637 = load i64, ptr %get_5217_pointer_636, !noalias !2
        %get_5217 = load i64, ptr %get_5217_pointer_636, !noalias !2
        
        %stackPointer_639 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_640 = getelementptr %FrameHeader, %StackPointer %stackPointer_639, i64 0, i32 0
        %returnAddress_638 = load %ReturnAddress, ptr %returnAddress_pointer_640, !noalias !2
        musttail call tailcc void %returnAddress_638(i64 %get_5217, %Stack %stack)
        ret void
}



define ccc void @sharer_642(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_643 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %primeCount_2857_641_pointer_644 = getelementptr <{%Reference}>, %StackPointer %stackPointer_643, i64 0, i32 0
        %primeCount_2857_641 = load %Reference, ptr %primeCount_2857_641_pointer_644, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_643)
        ret void
}



define ccc void @eraser_646(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_647 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %primeCount_2857_645_pointer_648 = getelementptr <{%Reference}>, %StackPointer %stackPointer_647, i64 0, i32 0
        %primeCount_2857_645 = load %Reference, ptr %primeCount_2857_645_pointer_648, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_647)
        ret void
}



define tailcc void @returnAddress_370(%Pos %v_r_2936_15_4297, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_371 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %primeCount_2857_pointer_372 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_371, i64 0, i32 0
        %primeCount_2857 = load %Reference, ptr %primeCount_2857_pointer_372, !noalias !2
        %size_2852_pointer_373 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_371, i64 0, i32 1
        %size_2852 = load i64, ptr %size_2852_pointer_373, !noalias !2
        %tmp_5166_pointer_374 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_371, i64 0, i32 2
        %tmp_5166 = load %Pos, ptr %tmp_5166_pointer_374, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2936_15_4297)
        %stackPointer_649 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %primeCount_2857_pointer_650 = getelementptr <{%Reference}>, %StackPointer %stackPointer_649, i64 0, i32 0
        store %Reference %primeCount_2857, ptr %primeCount_2857_pointer_650, !noalias !2
        %returnAddress_pointer_651 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 0
        %sharer_pointer_652 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 1
        %eraser_pointer_653 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 2
        store ptr @returnAddress_633, ptr %returnAddress_pointer_651, !noalias !2
        store ptr @sharer_642, ptr %sharer_pointer_652, !noalias !2
        store ptr @eraser_646, ptr %eraser_pointer_653, !noalias !2
        
        %longLiteral_5218 = add i64 2, 0
        
        
        
        musttail call tailcc void @loop_5_4304(i64 %longLiteral_5218, i64 %size_2852, %Pos %tmp_5166, %Reference %primeCount_2857, %Stack %stack)
        ret void
}



define ccc void @sharer_657(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_658 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %primeCount_2857_654_pointer_659 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_658, i64 0, i32 0
        %primeCount_2857_654 = load %Reference, ptr %primeCount_2857_654_pointer_659, !noalias !2
        %size_2852_655_pointer_660 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_658, i64 0, i32 1
        %size_2852_655 = load i64, ptr %size_2852_655_pointer_660, !noalias !2
        %tmp_5166_656_pointer_661 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_658, i64 0, i32 2
        %tmp_5166_656 = load %Pos, ptr %tmp_5166_656_pointer_661, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5166_656)
        call ccc void @shareFrames(%StackPointer %stackPointer_658)
        ret void
}



define ccc void @eraser_665(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_666 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %primeCount_2857_662_pointer_667 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_666, i64 0, i32 0
        %primeCount_2857_662 = load %Reference, ptr %primeCount_2857_662_pointer_667, !noalias !2
        %size_2852_663_pointer_668 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_666, i64 0, i32 1
        %size_2852_663 = load i64, ptr %size_2852_663_pointer_668, !noalias !2
        %tmp_5166_664_pointer_669 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_666, i64 0, i32 2
        %tmp_5166_664 = load %Pos, ptr %tmp_5166_664_pointer_669, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5166_664)
        call ccc void @eraseFrames(%StackPointer %stackPointer_666)
        ret void
}



define tailcc void @run_2853(i64 %size_2852, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5182 = add i64 0, 0
        
        
        %primeCount_2857 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_355 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2906_4035_pointer_356 = getelementptr <{i64}>, %StackPointer %stackPointer_355, i64 0, i32 0
        store i64 %longLiteral_5182, ptr %v_r_2906_4035_pointer_356, !noalias !2
        %returnAddress_pointer_357 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 0
        %sharer_pointer_358 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 1
        %eraser_pointer_359 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 2
        store ptr @returnAddress_340, ptr %returnAddress_pointer_357, !noalias !2
        store ptr @sharer_348, ptr %sharer_pointer_358, !noalias !2
        store ptr @eraser_352, ptr %eraser_pointer_359, !noalias !2
        
        %pureApp_5184 = call ccc %Pos @allocate_2473(i64 %size_2852)
        
        
        call ccc void @sharePositive(%Pos %pureApp_5184)
        %stackPointer_670 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %primeCount_2857_pointer_671 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_670, i64 0, i32 0
        store %Reference %primeCount_2857, ptr %primeCount_2857_pointer_671, !noalias !2
        %size_2852_pointer_672 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_670, i64 0, i32 1
        store i64 %size_2852, ptr %size_2852_pointer_672, !noalias !2
        %tmp_5166_pointer_673 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_670, i64 0, i32 2
        store %Pos %pureApp_5184, ptr %tmp_5166_pointer_673, !noalias !2
        %returnAddress_pointer_674 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_670, i64 0, i32 1, i32 0
        %sharer_pointer_675 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_670, i64 0, i32 1, i32 1
        %eraser_pointer_676 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_670, i64 0, i32 1, i32 2
        store ptr @returnAddress_370, ptr %returnAddress_pointer_674, !noalias !2
        store ptr @sharer_657, ptr %sharer_pointer_675, !noalias !2
        store ptr @eraser_665, ptr %eraser_pointer_676, !noalias !2
        
        %longLiteral_5219 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_4293(i64 %longLiteral_5219, i64 %size_2852, %Pos %pureApp_5184, %Stack %stack)
        ret void
}


@utf8StringLiteral_5173.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5175.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5178.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_677(%Pos %v_r_3198_3996, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_678 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_679 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_678, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_679, !noalias !2
        %index_2107_pointer_680 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_678, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_680, !noalias !2
        %Exception_2362_pointer_681 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_678, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_681, !noalias !2
        
        %tag_682 = extractvalue %Pos %v_r_3198_3996, 0
        %fields_683 = extractvalue %Pos %v_r_3198_3996, 1
        switch i64 %tag_682, label %label_684 [i64 0, label %label_688 i64 1, label %label_694]
    
    label_684:
        
        ret void
    
    label_688:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5169 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_686 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_687 = getelementptr %FrameHeader, %StackPointer %stackPointer_686, i64 0, i32 0
        %returnAddress_685 = load %ReturnAddress, ptr %returnAddress_pointer_687, !noalias !2
        musttail call tailcc void %returnAddress_685(i64 %pureApp_5169, %Stack %stack)
        ret void
    
    label_694:
        
        %make_5170_temporary_689 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5170 = insertvalue %Pos %make_5170_temporary_689, %Object null, 1
        
        
        
        %pureApp_5171 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5173 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5173.lit)
        
        %pureApp_5172 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5173, %Pos %pureApp_5171)
        
        
        
        %utf8StringLiteral_5175 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5175.lit)
        
        %pureApp_5174 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5172, %Pos %utf8StringLiteral_5175)
        
        
        
        %pureApp_5176 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5174, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5178 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5178.lit)
        
        %pureApp_5177 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5176, %Pos %utf8StringLiteral_5178)
        
        
        
        %vtable_690 = extractvalue %Neg %Exception_2362, 0
        %closure_691 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_692 = getelementptr ptr, ptr %vtable_690, i64 0
        %functionPointer_693 = load ptr, ptr %functionPointer_pointer_692, !noalias !2
        musttail call tailcc void %functionPointer_693(%Object %closure_691, %Pos %make_5170, %Pos %pureApp_5177, %Stack %stack)
        ret void
}



define ccc void @sharer_698(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_699 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_695_pointer_700 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_699, i64 0, i32 0
        %str_2106_695 = load %Pos, ptr %str_2106_695_pointer_700, !noalias !2
        %index_2107_696_pointer_701 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_699, i64 0, i32 1
        %index_2107_696 = load i64, ptr %index_2107_696_pointer_701, !noalias !2
        %Exception_2362_697_pointer_702 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_699, i64 0, i32 2
        %Exception_2362_697 = load %Neg, ptr %Exception_2362_697_pointer_702, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_695)
        call ccc void @shareNegative(%Neg %Exception_2362_697)
        call ccc void @shareFrames(%StackPointer %stackPointer_699)
        ret void
}



define ccc void @eraser_706(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_707 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_703_pointer_708 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_707, i64 0, i32 0
        %str_2106_703 = load %Pos, ptr %str_2106_703_pointer_708, !noalias !2
        %index_2107_704_pointer_709 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_707, i64 0, i32 1
        %index_2107_704 = load i64, ptr %index_2107_704_pointer_709, !noalias !2
        %Exception_2362_705_pointer_710 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_707, i64 0, i32 2
        %Exception_2362_705 = load %Neg, ptr %Exception_2362_705_pointer_710, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_703)
        call ccc void @eraseNegative(%Neg %Exception_2362_705)
        call ccc void @eraseFrames(%StackPointer %stackPointer_707)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5168 = add i64 0, 0
        
        %pureApp_5167 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5168)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_711 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_712 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_711, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_712, !noalias !2
        %index_2107_pointer_713 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_711, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_713, !noalias !2
        %Exception_2362_pointer_714 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_711, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_714, !noalias !2
        %returnAddress_pointer_715 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_711, i64 0, i32 1, i32 0
        %sharer_pointer_716 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_711, i64 0, i32 1, i32 1
        %eraser_pointer_717 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_711, i64 0, i32 1, i32 2
        store ptr @returnAddress_677, ptr %returnAddress_pointer_715, !noalias !2
        store ptr @sharer_698, ptr %sharer_pointer_716, !noalias !2
        store ptr @eraser_706, ptr %eraser_pointer_717, !noalias !2
        
        %tag_718 = extractvalue %Pos %pureApp_5167, 0
        %fields_719 = extractvalue %Pos %pureApp_5167, 1
        switch i64 %tag_718, label %label_720 [i64 0, label %label_724 i64 1, label %label_729]
    
    label_720:
        
        ret void
    
    label_724:
        
        %pureApp_5179 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5180 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5179)
        
        
        
        %stackPointer_722 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_723 = getelementptr %FrameHeader, %StackPointer %stackPointer_722, i64 0, i32 0
        %returnAddress_721 = load %ReturnAddress, ptr %returnAddress_pointer_723, !noalias !2
        musttail call tailcc void %returnAddress_721(%Pos %pureApp_5180, %Stack %stack)
        ret void
    
    label_729:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5181_temporary_725 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5181 = insertvalue %Pos %booleanLiteral_5181_temporary_725, %Object null, 1
        
        %stackPointer_727 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_728 = getelementptr %FrameHeader, %StackPointer %stackPointer_727, i64 0, i32 0
        %returnAddress_726 = load %ReturnAddress, ptr %returnAddress_pointer_728, !noalias !2
        musttail call tailcc void %returnAddress_726(%Pos %booleanLiteral_5181, %Stack %stack)
        ret void
}



define ccc void @effektMain() {
        
    transition:
        call tailcc void @effektMainTailcc()
        ret void
}



define tailcc void @effektMainTailcc() {
        
    entry:
        
        %stack = call ccc %Stack @withEmptyStack()
        
        musttail call tailcc void @main_2854(%Stack %stack)
        ret void
}
