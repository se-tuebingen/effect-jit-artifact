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



define ccc i64 @mod_108(i64 %x_106, i64 %y_107) {
    ; declaration extern
    ; variable
    %z = srem %Int %x_106, %y_107 ret %Int %z
}



define ccc double @infixAdd_111(double %x_109, double %y_110) {
    ; declaration extern
    ; variable
    %z = fadd %Double %x_109, %y_110 ret %Double %z
}



define ccc double @infixSub_117(double %x_115, double %y_116) {
    ; declaration extern
    ; variable
    %z = fsub %Double %x_115, %y_116 ret %Double %z
}



define ccc double @toDouble_156(i64 %d_155) {
    ; declaration extern
    ; variable
    %z = sitofp i64 %d_155 to double ret double %z
}



define ccc %Pos @infixLt_178(i64 %x_176, i64 %y_177) {
    ; declaration extern
    ; variable
    
    %z = icmp slt %Int %x_176, %y_177
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



define ccc %Pos @infixLt_196(double %x_194, double %y_195) {
    ; declaration extern
    ; variable
    
    %z = fcmp olt %Double %x_194, %y_195
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc %Pos @infixGt_202(double %x_200, double %y_201) {
    ; declaration extern
    ; variable
    
    %z = fcmp ogt %Double %x_200, %y_201
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc i64 @bitwiseAnd_234(i64 %x_232, i64 %y_233) {
    ; declaration extern
    ; variable
    %z = and %Int %x_232, %y_233 ret %Int %z
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



define ccc %Pos @boxDouble_321(double %d_320) {
    ; declaration extern
    ; variable
    
        %n = bitcast double %d_320 to i64
        %boxed1 = insertvalue %Pos zeroinitializer, i64 %n, 0
        %boxed2 = insertvalue %Pos %boxed1, %Object null, 1
        ret %Pos %boxed2
      
}



define ccc double @unboxDouble_323(%Pos %b_322) {
    ; declaration extern
    ; variable
    
        %unboxed = extractvalue %Pos %b_322, 0
        %d = bitcast i64 %unboxed to double
        ret %Double %d
      
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



define ccc %Pos @ref_2475(%Pos %init_2474) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_ref_fresh(%Pos %init_2474)
    ret %Pos %z
  
}



define ccc %Pos @get_2478(%Pos %ref_2477) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_ref_get(%Pos %ref_2477)
    ret %Pos %z
  
}



define ccc %Pos @set_2482(%Pos %ref_2480, %Pos %value_2481) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_ref_set(%Pos %ref_2480, %Pos %value_2481)
    ret %Pos %z
  
}



define ccc %Pos @allocate_2487(i64 %size_2486) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_new(%Int %size_2486)
    ret %Pos %z
  
}



define ccc %Pos @unsafeGet_2501(%Pos %arr_2499, i64 %index_2500) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_get(%Pos %arr_2499, %Int %index_2500)
    ret %Pos %z
  
}



define ccc %Pos @unsafeSet_2506(%Pos %arr_2503, i64 %index_2504, %Pos %value_2505) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_set(%Pos %arr_2503, %Int %index_2504, %Pos %value_2505)
    ret %Pos %z
  
}



define tailcc void @returnAddress_10(i64 %v_r_3074_2_8148, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_11 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_8145_pointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 0
        %i_6_8145 = load i64, ptr %i_6_8145_pointer_12, !noalias !2
        %tmp_8446_pointer_13 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 1
        %tmp_8446 = load i64, ptr %tmp_8446_pointer_13, !noalias !2
        
        %longLiteral_8671 = add i64 1, 0
        
        %pureApp_8670 = call ccc i64 @infixAdd_96(i64 %i_6_8145, i64 %longLiteral_8671)
        
        
        
        
        
        musttail call tailcc void @loop_5_8142(i64 %pureApp_8670, i64 %tmp_8446, %Stack %stack)
        ret void
}



define ccc void @sharer_16(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_17 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_8145_14_pointer_18 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 0
        %i_6_8145_14 = load i64, ptr %i_6_8145_14_pointer_18, !noalias !2
        %tmp_8446_15_pointer_19 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 1
        %tmp_8446_15 = load i64, ptr %tmp_8446_15_pointer_19, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_17)
        ret void
}



define ccc void @eraser_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_8145_20_pointer_24 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %i_6_8145_20 = load i64, ptr %i_6_8145_20_pointer_24, !noalias !2
        %tmp_8446_21_pointer_25 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 1
        %tmp_8446_21 = load i64, ptr %tmp_8446_21_pointer_25, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_23)
        ret void
}



define tailcc void @loop_5_8142(i64 %i_6_8145, i64 %tmp_8446, %Stack %stack) {
        
    entry:
        
        
        %pureApp_8668 = call ccc %Pos @infixLt_178(i64 %i_6_8145, i64 %tmp_8446)
        
        
        
        %tag_2 = extractvalue %Pos %pureApp_8668, 0
        %fields_3 = extractvalue %Pos %pureApp_8668, 1
        switch i64 %tag_2, label %label_4 [i64 0, label %label_9 i64 1, label %label_32]
    
    label_4:
        
        ret void
    
    label_9:
        
        %unitLiteral_8669_temporary_5 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8669 = insertvalue %Pos %unitLiteral_8669_temporary_5, %Object null, 1
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %unitLiteral_8669, %Stack %stack)
        ret void
    
    label_32:
        %stackPointer_26 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_8145_pointer_27 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        store i64 %i_6_8145, ptr %i_6_8145_pointer_27, !noalias !2
        %tmp_8446_pointer_28 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 1
        store i64 %tmp_8446, ptr %tmp_8446_pointer_28, !noalias !2
        %returnAddress_pointer_29 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 0
        %sharer_pointer_30 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 1
        %eraser_pointer_31 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 2
        store ptr @returnAddress_10, ptr %returnAddress_pointer_29, !noalias !2
        store ptr @sharer_16, ptr %sharer_pointer_30, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_31, !noalias !2
        
        %longLiteral_8672 = add i64 50, 0
        
        
        
        musttail call tailcc void @run_2874(i64 %longLiteral_8672, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_34(i64 %r_2902, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_8674 = call ccc %Pos @show_14(i64 %r_2902)
        
        
        
        %pureApp_8675 = call ccc %Pos @println_1(%Pos %pureApp_8674)
        
        
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_37 = getelementptr %FrameHeader, %StackPointer %stackPointer_36, i64 0, i32 0
        %returnAddress_35 = load %ReturnAddress, ptr %returnAddress_pointer_37, !noalias !2
        musttail call tailcc void %returnAddress_35(%Pos %pureApp_8675, %Stack %stack)
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



define tailcc void @returnAddress_33(%Pos %v_r_3076_8673, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %v_r_3076_8673)
        %stackPointer_42 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_43 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 0
        %sharer_pointer_44 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 1
        %eraser_pointer_45 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_43, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_44, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_45, !noalias !2
        
        %longLiteral_8676 = add i64 50, 0
        
        
        
        musttail call tailcc void @run_2874(i64 %longLiteral_8676, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_4115_4179, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_8665 = call ccc i64 @unboxInt_303(%Pos %v_coe_4115_4179)
        
        
        
        %longLiteral_8667 = add i64 1, 0
        
        %pureApp_8666 = call ccc i64 @infixSub_105(i64 %pureApp_8665, i64 %longLiteral_8667)
        
        
        %stackPointer_46 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_47 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 0
        %sharer_pointer_48 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 1
        %eraser_pointer_49 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 2
        store ptr @returnAddress_33, ptr %returnAddress_pointer_47, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_48, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_49, !noalias !2
        
        %longLiteral_8677 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_8142(i64 %longLiteral_8677, i64 %pureApp_8666, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_55(%Pos %returned_8678, %Stack %stack) {
        
    entry:
        
        %stack_56 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_58 = call ccc %StackPointer @stackDeallocate(%Stack %stack_56, i64 24)
        %returnAddress_pointer_59 = getelementptr %FrameHeader, %StackPointer %stackPointer_58, i64 0, i32 0
        %returnAddress_57 = load %ReturnAddress, ptr %returnAddress_pointer_59, !noalias !2
        musttail call tailcc void %returnAddress_57(%Pos %returned_8678, %Stack %stack_56)
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
        
        %tmp_8419_73_pointer_76 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_8419_73 = load %Pos, ptr %tmp_8419_73_pointer_76, !noalias !2
        %acc_3_3_5_169_7910_74_pointer_77 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_7910_74 = load %Pos, ptr %acc_3_3_5_169_7910_74_pointer_77, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8419_73)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_7910_74)
        ret void
}



define tailcc void @toList_1_1_3_167_8011(i64 %start_2_2_4_168_7876, %Pos %acc_3_3_5_169_7910, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_8680 = add i64 1, 0
        
        %pureApp_8679 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_7876, i64 %longLiteral_8680)
        
        
        
        %tag_68 = extractvalue %Pos %pureApp_8679, 0
        %fields_69 = extractvalue %Pos %pureApp_8679, 1
        switch i64 %tag_68, label %label_70 [i64 0, label %label_81 i64 1, label %label_85]
    
    label_70:
        
        ret void
    
    label_81:
        
        %pureApp_8681 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_7876)
        
        
        
        %longLiteral_8683 = add i64 1, 0
        
        %pureApp_8682 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_7876, i64 %longLiteral_8683)
        
        
        
        %fields_71 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_72 = call ccc %Environment @objectEnvironment(%Object %fields_71)
        %tmp_8419_pointer_78 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 0
        store %Pos %pureApp_8681, ptr %tmp_8419_pointer_78, !noalias !2
        %acc_3_3_5_169_7910_pointer_79 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 1
        store %Pos %acc_3_3_5_169_7910, ptr %acc_3_3_5_169_7910_pointer_79, !noalias !2
        %make_8684_temporary_80 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_8684 = insertvalue %Pos %make_8684_temporary_80, %Object %fields_71, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_8011(i64 %pureApp_8682, %Pos %make_8684, %Stack %stack)
        ret void
    
    label_85:
        
        %stackPointer_83 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_84 = getelementptr %FrameHeader, %StackPointer %stackPointer_83, i64 0, i32 0
        %returnAddress_82 = load %ReturnAddress, ptr %returnAddress_pointer_84, !noalias !2
        musttail call tailcc void %returnAddress_82(%Pos %acc_3_3_5_169_7910, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_96(%Pos %v_r_3261_32_59_223_8014, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_97 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %index_7_34_198_8049_pointer_98 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_97, i64 0, i32 0
        %index_7_34_198_8049 = load i64, ptr %index_7_34_198_8049_pointer_98, !noalias !2
        %v_r_3071_30_194_8018_pointer_99 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_97, i64 0, i32 1
        %v_r_3071_30_194_8018 = load %Pos, ptr %v_r_3071_30_194_8018_pointer_99, !noalias !2
        %tmp_8426_pointer_100 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_97, i64 0, i32 2
        %tmp_8426 = load i64, ptr %tmp_8426_pointer_100, !noalias !2
        %acc_8_35_199_7830_pointer_101 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_97, i64 0, i32 3
        %acc_8_35_199_7830 = load i64, ptr %acc_8_35_199_7830_pointer_101, !noalias !2
        %p_8_9_7772_pointer_102 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_97, i64 0, i32 4
        %p_8_9_7772 = load %Prompt, ptr %p_8_9_7772_pointer_102, !noalias !2
        
        %tag_103 = extractvalue %Pos %v_r_3261_32_59_223_8014, 0
        %fields_104 = extractvalue %Pos %v_r_3261_32_59_223_8014, 1
        switch i64 %tag_103, label %label_105 [i64 1, label %label_128 i64 0, label %label_135]
    
    label_105:
        
        ret void
    
    label_110:
        
        ret void
    
    label_116:
        call ccc void @erasePositive(%Pos %v_r_3071_30_194_8018)
        
        %pair_111 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_7772)
        %k_13_14_4_8155 = extractvalue <{%Resumption, %Stack}> %pair_111, 0
        %stack_112 = extractvalue <{%Resumption, %Stack}> %pair_111, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_8155)
        
        %longLiteral_8696 = add i64 5, 0
        
        
        
        %pureApp_8697 = call ccc %Pos @boxInt_301(i64 %longLiteral_8696)
        
        
        
        %stackPointer_114 = call ccc %StackPointer @stackDeallocate(%Stack %stack_112, i64 24)
        %returnAddress_pointer_115 = getelementptr %FrameHeader, %StackPointer %stackPointer_114, i64 0, i32 0
        %returnAddress_113 = load %ReturnAddress, ptr %returnAddress_pointer_115, !noalias !2
        musttail call tailcc void %returnAddress_113(%Pos %pureApp_8697, %Stack %stack_112)
        ret void
    
    label_119:
        
        ret void
    
    label_125:
        call ccc void @erasePositive(%Pos %v_r_3071_30_194_8018)
        
        %pair_120 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_7772)
        %k_13_14_4_8154 = extractvalue <{%Resumption, %Stack}> %pair_120, 0
        %stack_121 = extractvalue <{%Resumption, %Stack}> %pair_120, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_8154)
        
        %longLiteral_8700 = add i64 5, 0
        
        
        
        %pureApp_8701 = call ccc %Pos @boxInt_301(i64 %longLiteral_8700)
        
        
        
        %stackPointer_123 = call ccc %StackPointer @stackDeallocate(%Stack %stack_121, i64 24)
        %returnAddress_pointer_124 = getelementptr %FrameHeader, %StackPointer %stackPointer_123, i64 0, i32 0
        %returnAddress_122 = load %ReturnAddress, ptr %returnAddress_pointer_124, !noalias !2
        musttail call tailcc void %returnAddress_122(%Pos %pureApp_8701, %Stack %stack_121)
        ret void
    
    label_126:
        
        %longLiteral_8703 = add i64 1, 0
        
        %pureApp_8702 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_8049, i64 %longLiteral_8703)
        
        
        
        %longLiteral_8705 = add i64 10, 0
        
        %pureApp_8704 = call ccc i64 @infixMul_99(i64 %longLiteral_8705, i64 %acc_8_35_199_7830)
        
        
        
        %pureApp_8706 = call ccc i64 @toInt_2085(i64 %pureApp_8693)
        
        
        
        %pureApp_8707 = call ccc i64 @infixSub_105(i64 %pureApp_8706, i64 %tmp_8426)
        
        
        
        %pureApp_8708 = call ccc i64 @infixAdd_96(i64 %pureApp_8704, i64 %pureApp_8707)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_7935(i64 %pureApp_8702, i64 %pureApp_8708, %Pos %v_r_3071_30_194_8018, i64 %tmp_8426, %Prompt %p_8_9_7772, %Stack %stack)
        ret void
    
    label_127:
        
        %intLiteral_8699 = add i64 57, 0
        
        %pureApp_8698 = call ccc %Pos @infixLte_2093(i64 %pureApp_8693, i64 %intLiteral_8699)
        
        
        
        %tag_117 = extractvalue %Pos %pureApp_8698, 0
        %fields_118 = extractvalue %Pos %pureApp_8698, 1
        switch i64 %tag_117, label %label_119 [i64 0, label %label_125 i64 1, label %label_126]
    
    label_128:
        %environment_106 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_coe_4079_46_73_237_7921_pointer_107 = getelementptr <{%Pos}>, %Environment %environment_106, i64 0, i32 0
        %v_coe_4079_46_73_237_7921 = load %Pos, ptr %v_coe_4079_46_73_237_7921_pointer_107, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_4079_46_73_237_7921)
        call ccc void @eraseObject(%Object %fields_104)
        
        %pureApp_8693 = call ccc i64 @unboxChar_313(%Pos %v_coe_4079_46_73_237_7921)
        
        
        
        %intLiteral_8695 = add i64 48, 0
        
        %pureApp_8694 = call ccc %Pos @infixGte_2099(i64 %pureApp_8693, i64 %intLiteral_8695)
        
        
        
        %tag_108 = extractvalue %Pos %pureApp_8694, 0
        %fields_109 = extractvalue %Pos %pureApp_8694, 1
        switch i64 %tag_108, label %label_110 [i64 0, label %label_116 i64 1, label %label_127]
    
    label_135:
        %environment_129 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_y_3268_76_103_267_8691_pointer_130 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 0
        %v_y_3268_76_103_267_8691 = load %Pos, ptr %v_y_3268_76_103_267_8691_pointer_130, !noalias !2
        %v_y_3269_77_104_268_8692_pointer_131 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 1
        %v_y_3269_77_104_268_8692 = load %Pos, ptr %v_y_3269_77_104_268_8692_pointer_131, !noalias !2
        call ccc void @eraseObject(%Object %fields_104)
        call ccc void @erasePositive(%Pos %v_r_3071_30_194_8018)
        
        %stackPointer_133 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_134 = getelementptr %FrameHeader, %StackPointer %stackPointer_133, i64 0, i32 0
        %returnAddress_132 = load %ReturnAddress, ptr %returnAddress_pointer_134, !noalias !2
        musttail call tailcc void %returnAddress_132(i64 %acc_8_35_199_7830, %Stack %stack)
        ret void
}



define ccc void @sharer_141(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_142 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_8049_136_pointer_143 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_142, i64 0, i32 0
        %index_7_34_198_8049_136 = load i64, ptr %index_7_34_198_8049_136_pointer_143, !noalias !2
        %v_r_3071_30_194_8018_137_pointer_144 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_142, i64 0, i32 1
        %v_r_3071_30_194_8018_137 = load %Pos, ptr %v_r_3071_30_194_8018_137_pointer_144, !noalias !2
        %tmp_8426_138_pointer_145 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_142, i64 0, i32 2
        %tmp_8426_138 = load i64, ptr %tmp_8426_138_pointer_145, !noalias !2
        %acc_8_35_199_7830_139_pointer_146 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_142, i64 0, i32 3
        %acc_8_35_199_7830_139 = load i64, ptr %acc_8_35_199_7830_139_pointer_146, !noalias !2
        %p_8_9_7772_140_pointer_147 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_142, i64 0, i32 4
        %p_8_9_7772_140 = load %Prompt, ptr %p_8_9_7772_140_pointer_147, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3071_30_194_8018_137)
        call ccc void @shareFrames(%StackPointer %stackPointer_142)
        ret void
}



define ccc void @eraser_153(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_154 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_8049_148_pointer_155 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_154, i64 0, i32 0
        %index_7_34_198_8049_148 = load i64, ptr %index_7_34_198_8049_148_pointer_155, !noalias !2
        %v_r_3071_30_194_8018_149_pointer_156 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_154, i64 0, i32 1
        %v_r_3071_30_194_8018_149 = load %Pos, ptr %v_r_3071_30_194_8018_149_pointer_156, !noalias !2
        %tmp_8426_150_pointer_157 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_154, i64 0, i32 2
        %tmp_8426_150 = load i64, ptr %tmp_8426_150_pointer_157, !noalias !2
        %acc_8_35_199_7830_151_pointer_158 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_154, i64 0, i32 3
        %acc_8_35_199_7830_151 = load i64, ptr %acc_8_35_199_7830_151_pointer_158, !noalias !2
        %p_8_9_7772_152_pointer_159 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_154, i64 0, i32 4
        %p_8_9_7772_152 = load %Prompt, ptr %p_8_9_7772_152_pointer_159, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3071_30_194_8018_149)
        call ccc void @eraseFrames(%StackPointer %stackPointer_154)
        ret void
}



define tailcc void @returnAddress_170(%Pos %returned_8709, %Stack %stack) {
        
    entry:
        
        %stack_171 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_173 = call ccc %StackPointer @stackDeallocate(%Stack %stack_171, i64 24)
        %returnAddress_pointer_174 = getelementptr %FrameHeader, %StackPointer %stackPointer_173, i64 0, i32 0
        %returnAddress_172 = load %ReturnAddress, ptr %returnAddress_pointer_174, !noalias !2
        musttail call tailcc void %returnAddress_172(%Pos %returned_8709, %Stack %stack_171)
        ret void
}



define tailcc void @Exception_7_19_46_210_8077_clause_179(%Object %closure, %Pos %exc_8_20_47_211_8032, %Pos %msg_9_21_48_212_7997, %Stack %stack) {
        
    entry:
        
        %environment_180 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_7946_pointer_181 = getelementptr <{%Prompt}>, %Environment %environment_180, i64 0, i32 0
        %p_6_18_45_209_7946 = load %Prompt, ptr %p_6_18_45_209_7946_pointer_181, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_182 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_7946)
        %k_11_23_50_214_8097 = extractvalue <{%Resumption, %Stack}> %pair_182, 0
        %stack_183 = extractvalue <{%Resumption, %Stack}> %pair_182, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_8097)
        
        %fields_184 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_185 = call ccc %Environment @objectEnvironment(%Object %fields_184)
        %exc_8_20_47_211_8032_pointer_188 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 0
        store %Pos %exc_8_20_47_211_8032, ptr %exc_8_20_47_211_8032_pointer_188, !noalias !2
        %msg_9_21_48_212_7997_pointer_189 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 1
        store %Pos %msg_9_21_48_212_7997, ptr %msg_9_21_48_212_7997_pointer_189, !noalias !2
        %make_8710_temporary_190 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_8710 = insertvalue %Pos %make_8710_temporary_190, %Object %fields_184, 1
        
        
        
        %stackPointer_192 = call ccc %StackPointer @stackDeallocate(%Stack %stack_183, i64 24)
        %returnAddress_pointer_193 = getelementptr %FrameHeader, %StackPointer %stackPointer_192, i64 0, i32 0
        %returnAddress_191 = load %ReturnAddress, ptr %returnAddress_pointer_193, !noalias !2
        musttail call tailcc void %returnAddress_191(%Pos %make_8710, %Stack %stack_183)
        ret void
}


@vtable_194 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_8077_clause_179]


define ccc void @eraser_198(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_7946_197_pointer_199 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_7946_197 = load %Prompt, ptr %p_6_18_45_209_7946_197_pointer_199, !noalias !2
        ret void
}



define ccc void @eraser_206(%Environment %environment) {
        
    entry:
        
        %tmp_8428_205_pointer_207 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_8428_205 = load %Pos, ptr %tmp_8428_205_pointer_207, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8428_205)
        ret void
}



define tailcc void @returnAddress_202(i64 %v_coe_4078_6_28_55_219_7833, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_8711 = call ccc %Pos @boxChar_311(i64 %v_coe_4078_6_28_55_219_7833)
        
        
        
        %fields_203 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_204 = call ccc %Environment @objectEnvironment(%Object %fields_203)
        %tmp_8428_pointer_208 = getelementptr <{%Pos}>, %Environment %environment_204, i64 0, i32 0
        store %Pos %pureApp_8711, ptr %tmp_8428_pointer_208, !noalias !2
        %make_8712_temporary_209 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_8712 = insertvalue %Pos %make_8712_temporary_209, %Object %fields_203, 1
        
        
        
        %stackPointer_211 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_212 = getelementptr %FrameHeader, %StackPointer %stackPointer_211, i64 0, i32 0
        %returnAddress_210 = load %ReturnAddress, ptr %returnAddress_pointer_212, !noalias !2
        musttail call tailcc void %returnAddress_210(%Pos %make_8712, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_7935(i64 %index_7_34_198_8049, i64 %acc_8_35_199_7830, %Pos %v_r_3071_30_194_8018, i64 %tmp_8426, %Prompt %p_8_9_7772, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_3071_30_194_8018)
        %stackPointer_160 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %index_7_34_198_8049_pointer_161 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 0
        store i64 %index_7_34_198_8049, ptr %index_7_34_198_8049_pointer_161, !noalias !2
        %v_r_3071_30_194_8018_pointer_162 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 1
        store %Pos %v_r_3071_30_194_8018, ptr %v_r_3071_30_194_8018_pointer_162, !noalias !2
        %tmp_8426_pointer_163 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 2
        store i64 %tmp_8426, ptr %tmp_8426_pointer_163, !noalias !2
        %acc_8_35_199_7830_pointer_164 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 3
        store i64 %acc_8_35_199_7830, ptr %acc_8_35_199_7830_pointer_164, !noalias !2
        %p_8_9_7772_pointer_165 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 4
        store %Prompt %p_8_9_7772, ptr %p_8_9_7772_pointer_165, !noalias !2
        %returnAddress_pointer_166 = getelementptr <{<{i64, %Pos, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 0
        %sharer_pointer_167 = getelementptr <{<{i64, %Pos, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 1
        %eraser_pointer_168 = getelementptr <{<{i64, %Pos, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 2
        store ptr @returnAddress_96, ptr %returnAddress_pointer_166, !noalias !2
        store ptr @sharer_141, ptr %sharer_pointer_167, !noalias !2
        store ptr @eraser_153, ptr %eraser_pointer_168, !noalias !2
        
        %stack_169 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_7946 = call ccc %Prompt @currentPrompt(%Stack %stack_169)
        %stackPointer_175 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_176 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 0
        %sharer_pointer_177 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 1
        %eraser_pointer_178 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 2
        store ptr @returnAddress_170, ptr %returnAddress_pointer_176, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_177, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_178, !noalias !2
        
        %closure_195 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_196 = call ccc %Environment @objectEnvironment(%Object %closure_195)
        %p_6_18_45_209_7946_pointer_200 = getelementptr <{%Prompt}>, %Environment %environment_196, i64 0, i32 0
        store %Prompt %p_6_18_45_209_7946, ptr %p_6_18_45_209_7946_pointer_200, !noalias !2
        %vtable_temporary_201 = insertvalue %Neg zeroinitializer, ptr @vtable_194, 0
        %Exception_7_19_46_210_8077 = insertvalue %Neg %vtable_temporary_201, %Object %closure_195, 1
        %stackPointer_213 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_214 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 0
        %sharer_pointer_215 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 1
        %eraser_pointer_216 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 2
        store ptr @returnAddress_202, ptr %returnAddress_pointer_214, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_215, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_216, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_3071_30_194_8018, i64 %index_7_34_198_8049, %Neg %Exception_7_19_46_210_8077, %Stack %stack_169)
        ret void
}



define tailcc void @Exception_9_106_133_297_7992_clause_217(%Object %closure, %Pos %exception_10_107_134_298_8713, %Pos %msg_11_108_135_299_8714, %Stack %stack) {
        
    entry:
        
        %environment_218 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_7772_pointer_219 = getelementptr <{%Prompt}>, %Environment %environment_218, i64 0, i32 0
        %p_8_9_7772 = load %Prompt, ptr %p_8_9_7772_pointer_219, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_8713)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_8714)
        
        %pair_220 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_7772)
        %k_13_14_4_8308 = extractvalue <{%Resumption, %Stack}> %pair_220, 0
        %stack_221 = extractvalue <{%Resumption, %Stack}> %pair_220, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_8308)
        
        %longLiteral_8715 = add i64 5, 0
        
        
        
        %pureApp_8716 = call ccc %Pos @boxInt_301(i64 %longLiteral_8715)
        
        
        
        %stackPointer_223 = call ccc %StackPointer @stackDeallocate(%Stack %stack_221, i64 24)
        %returnAddress_pointer_224 = getelementptr %FrameHeader, %StackPointer %stackPointer_223, i64 0, i32 0
        %returnAddress_222 = load %ReturnAddress, ptr %returnAddress_pointer_224, !noalias !2
        musttail call tailcc void %returnAddress_222(%Pos %pureApp_8716, %Stack %stack_221)
        ret void
}


@vtable_225 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_7992_clause_217]


define tailcc void @returnAddress_236(i64 %v_coe_4083_22_131_158_322_8003, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_8719 = call ccc %Pos @boxInt_301(i64 %v_coe_4083_22_131_158_322_8003)
        
        
        
        
        
        %pureApp_8720 = call ccc i64 @unboxInt_303(%Pos %pureApp_8719)
        
        
        
        %pureApp_8721 = call ccc %Pos @boxInt_301(i64 %pureApp_8720)
        
        
        
        %stackPointer_238 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_239 = getelementptr %FrameHeader, %StackPointer %stackPointer_238, i64 0, i32 0
        %returnAddress_237 = load %ReturnAddress, ptr %returnAddress_pointer_239, !noalias !2
        musttail call tailcc void %returnAddress_237(%Pos %pureApp_8721, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_248(i64 %v_r_3275_1_9_20_129_156_320_7984, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_8725 = add i64 0, 0
        
        %pureApp_8724 = call ccc i64 @infixSub_105(i64 %longLiteral_8725, i64 %v_r_3275_1_9_20_129_156_320_7984)
        
        
        
        %stackPointer_250 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_251 = getelementptr %FrameHeader, %StackPointer %stackPointer_250, i64 0, i32 0
        %returnAddress_249 = load %ReturnAddress, ptr %returnAddress_pointer_251, !noalias !2
        musttail call tailcc void %returnAddress_249(i64 %pureApp_8724, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_231(i64 %v_r_3274_3_14_123_150_314_7944, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_232 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_3071_30_194_8018_pointer_233 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_232, i64 0, i32 0
        %v_r_3071_30_194_8018 = load %Pos, ptr %v_r_3071_30_194_8018_pointer_233, !noalias !2
        %tmp_8426_pointer_234 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_232, i64 0, i32 1
        %tmp_8426 = load i64, ptr %tmp_8426_pointer_234, !noalias !2
        %p_8_9_7772_pointer_235 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_232, i64 0, i32 2
        %p_8_9_7772 = load %Prompt, ptr %p_8_9_7772_pointer_235, !noalias !2
        
        %intLiteral_8718 = add i64 45, 0
        
        %pureApp_8717 = call ccc %Pos @infixEq_78(i64 %v_r_3274_3_14_123_150_314_7944, i64 %intLiteral_8718)
        
        
        %stackPointer_240 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_241 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 0
        %sharer_pointer_242 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 1
        %eraser_pointer_243 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 2
        store ptr @returnAddress_236, ptr %returnAddress_pointer_241, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_242, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_243, !noalias !2
        
        %tag_244 = extractvalue %Pos %pureApp_8717, 0
        %fields_245 = extractvalue %Pos %pureApp_8717, 1
        switch i64 %tag_244, label %label_246 [i64 0, label %label_247 i64 1, label %label_256]
    
    label_246:
        
        ret void
    
    label_247:
        
        %longLiteral_8722 = add i64 0, 0
        
        %longLiteral_8723 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_7935(i64 %longLiteral_8722, i64 %longLiteral_8723, %Pos %v_r_3071_30_194_8018, i64 %tmp_8426, %Prompt %p_8_9_7772, %Stack %stack)
        ret void
    
    label_256:
        %stackPointer_252 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_253 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 0
        %sharer_pointer_254 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 1
        %eraser_pointer_255 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 2
        store ptr @returnAddress_248, ptr %returnAddress_pointer_253, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_254, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_255, !noalias !2
        
        %longLiteral_8726 = add i64 1, 0
        
        %longLiteral_8727 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_7935(i64 %longLiteral_8726, i64 %longLiteral_8727, %Pos %v_r_3071_30_194_8018, i64 %tmp_8426, %Prompt %p_8_9_7772, %Stack %stack)
        ret void
}



define ccc void @sharer_260(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_261 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_r_3071_30_194_8018_257_pointer_262 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_261, i64 0, i32 0
        %v_r_3071_30_194_8018_257 = load %Pos, ptr %v_r_3071_30_194_8018_257_pointer_262, !noalias !2
        %tmp_8426_258_pointer_263 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_261, i64 0, i32 1
        %tmp_8426_258 = load i64, ptr %tmp_8426_258_pointer_263, !noalias !2
        %p_8_9_7772_259_pointer_264 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_261, i64 0, i32 2
        %p_8_9_7772_259 = load %Prompt, ptr %p_8_9_7772_259_pointer_264, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3071_30_194_8018_257)
        call ccc void @shareFrames(%StackPointer %stackPointer_261)
        ret void
}



define ccc void @eraser_268(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_269 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_r_3071_30_194_8018_265_pointer_270 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_269, i64 0, i32 0
        %v_r_3071_30_194_8018_265 = load %Pos, ptr %v_r_3071_30_194_8018_265_pointer_270, !noalias !2
        %tmp_8426_266_pointer_271 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_269, i64 0, i32 1
        %tmp_8426_266 = load i64, ptr %tmp_8426_266_pointer_271, !noalias !2
        %p_8_9_7772_267_pointer_272 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_269, i64 0, i32 2
        %p_8_9_7772_267 = load %Prompt, ptr %p_8_9_7772_267_pointer_272, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3071_30_194_8018_265)
        call ccc void @eraseFrames(%StackPointer %stackPointer_269)
        ret void
}



define tailcc void @returnAddress_93(%Pos %v_r_3071_30_194_8018, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_94 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_7772_pointer_95 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_94, i64 0, i32 0
        %p_8_9_7772 = load %Prompt, ptr %p_8_9_7772_pointer_95, !noalias !2
        
        %intLiteral_8690 = add i64 48, 0
        
        %pureApp_8689 = call ccc i64 @toInt_2085(i64 %intLiteral_8690)
        
        
        
        %closure_226 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_227 = call ccc %Environment @objectEnvironment(%Object %closure_226)
        %p_8_9_7772_pointer_229 = getelementptr <{%Prompt}>, %Environment %environment_227, i64 0, i32 0
        store %Prompt %p_8_9_7772, ptr %p_8_9_7772_pointer_229, !noalias !2
        %vtable_temporary_230 = insertvalue %Neg zeroinitializer, ptr @vtable_225, 0
        %Exception_9_106_133_297_7992 = insertvalue %Neg %vtable_temporary_230, %Object %closure_226, 1
        call ccc void @sharePositive(%Pos %v_r_3071_30_194_8018)
        %stackPointer_273 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_3071_30_194_8018_pointer_274 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_273, i64 0, i32 0
        store %Pos %v_r_3071_30_194_8018, ptr %v_r_3071_30_194_8018_pointer_274, !noalias !2
        %tmp_8426_pointer_275 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_273, i64 0, i32 1
        store i64 %pureApp_8689, ptr %tmp_8426_pointer_275, !noalias !2
        %p_8_9_7772_pointer_276 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_273, i64 0, i32 2
        store %Prompt %p_8_9_7772, ptr %p_8_9_7772_pointer_276, !noalias !2
        %returnAddress_pointer_277 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 0
        %sharer_pointer_278 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 1
        %eraser_pointer_279 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 2
        store ptr @returnAddress_231, ptr %returnAddress_pointer_277, !noalias !2
        store ptr @sharer_260, ptr %sharer_pointer_278, !noalias !2
        store ptr @eraser_268, ptr %eraser_pointer_279, !noalias !2
        
        %longLiteral_8728 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_3071_30_194_8018, i64 %longLiteral_8728, %Neg %Exception_9_106_133_297_7992, %Stack %stack)
        ret void
}



define ccc void @sharer_281(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_282 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_7772_280_pointer_283 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_282, i64 0, i32 0
        %p_8_9_7772_280 = load %Prompt, ptr %p_8_9_7772_280_pointer_283, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_282)
        ret void
}



define ccc void @eraser_285(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_286 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_7772_284_pointer_287 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_286, i64 0, i32 0
        %p_8_9_7772_284 = load %Prompt, ptr %p_8_9_7772_284_pointer_287, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_286)
        ret void
}


@utf8StringLiteral_8729.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_90(%Pos %v_r_3070_24_188_7925, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_91 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_7772_pointer_92 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_91, i64 0, i32 0
        %p_8_9_7772 = load %Prompt, ptr %p_8_9_7772_pointer_92, !noalias !2
        %stackPointer_288 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_7772_pointer_289 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_288, i64 0, i32 0
        store %Prompt %p_8_9_7772, ptr %p_8_9_7772_pointer_289, !noalias !2
        %returnAddress_pointer_290 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 0
        %sharer_pointer_291 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 1
        %eraser_pointer_292 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 2
        store ptr @returnAddress_93, ptr %returnAddress_pointer_290, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_291, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_292, !noalias !2
        
        %tag_293 = extractvalue %Pos %v_r_3070_24_188_7925, 0
        %fields_294 = extractvalue %Pos %v_r_3070_24_188_7925, 1
        switch i64 %tag_293, label %label_295 [i64 0, label %label_299 i64 1, label %label_305]
    
    label_295:
        
        ret void
    
    label_299:
        
        %utf8StringLiteral_8729 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_8729.lit)
        
        %stackPointer_297 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_298 = getelementptr %FrameHeader, %StackPointer %stackPointer_297, i64 0, i32 0
        %returnAddress_296 = load %ReturnAddress, ptr %returnAddress_pointer_298, !noalias !2
        musttail call tailcc void %returnAddress_296(%Pos %utf8StringLiteral_8729, %Stack %stack)
        ret void
    
    label_305:
        %environment_300 = call ccc %Environment @objectEnvironment(%Object %fields_294)
        %v_y_3905_8_29_193_7969_pointer_301 = getelementptr <{%Pos}>, %Environment %environment_300, i64 0, i32 0
        %v_y_3905_8_29_193_7969 = load %Pos, ptr %v_y_3905_8_29_193_7969_pointer_301, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3905_8_29_193_7969)
        call ccc void @eraseObject(%Object %fields_294)
        
        %stackPointer_303 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_304 = getelementptr %FrameHeader, %StackPointer %stackPointer_303, i64 0, i32 0
        %returnAddress_302 = load %ReturnAddress, ptr %returnAddress_pointer_304, !noalias !2
        musttail call tailcc void %returnAddress_302(%Pos %v_y_3905_8_29_193_7969, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_87(%Pos %v_r_3069_13_177_8087, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_88 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_7772_pointer_89 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_88, i64 0, i32 0
        %p_8_9_7772 = load %Prompt, ptr %p_8_9_7772_pointer_89, !noalias !2
        %stackPointer_308 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_7772_pointer_309 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_308, i64 0, i32 0
        store %Prompt %p_8_9_7772, ptr %p_8_9_7772_pointer_309, !noalias !2
        %returnAddress_pointer_310 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 0
        %sharer_pointer_311 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 1
        %eraser_pointer_312 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 2
        store ptr @returnAddress_90, ptr %returnAddress_pointer_310, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_311, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_312, !noalias !2
        
        %tag_313 = extractvalue %Pos %v_r_3069_13_177_8087, 0
        %fields_314 = extractvalue %Pos %v_r_3069_13_177_8087, 1
        switch i64 %tag_313, label %label_315 [i64 0, label %label_320 i64 1, label %label_332]
    
    label_315:
        
        ret void
    
    label_320:
        
        %make_8730_temporary_316 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_8730 = insertvalue %Pos %make_8730_temporary_316, %Object null, 1
        
        
        
        %stackPointer_318 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_319 = getelementptr %FrameHeader, %StackPointer %stackPointer_318, i64 0, i32 0
        %returnAddress_317 = load %ReturnAddress, ptr %returnAddress_pointer_319, !noalias !2
        musttail call tailcc void %returnAddress_317(%Pos %make_8730, %Stack %stack)
        ret void
    
    label_332:
        %environment_321 = call ccc %Environment @objectEnvironment(%Object %fields_314)
        %v_y_3414_10_21_185_8039_pointer_322 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 0
        %v_y_3414_10_21_185_8039 = load %Pos, ptr %v_y_3414_10_21_185_8039_pointer_322, !noalias !2
        %v_y_3415_11_22_186_8070_pointer_323 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 1
        %v_y_3415_11_22_186_8070 = load %Pos, ptr %v_y_3415_11_22_186_8070_pointer_323, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3414_10_21_185_8039)
        call ccc void @eraseObject(%Object %fields_314)
        
        %fields_324 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_325 = call ccc %Environment @objectEnvironment(%Object %fields_324)
        %v_y_3414_10_21_185_8039_pointer_327 = getelementptr <{%Pos}>, %Environment %environment_325, i64 0, i32 0
        store %Pos %v_y_3414_10_21_185_8039, ptr %v_y_3414_10_21_185_8039_pointer_327, !noalias !2
        %make_8731_temporary_328 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_8731 = insertvalue %Pos %make_8731_temporary_328, %Object %fields_324, 1
        
        
        
        %stackPointer_330 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_331 = getelementptr %FrameHeader, %StackPointer %stackPointer_330, i64 0, i32 0
        %returnAddress_329 = load %ReturnAddress, ptr %returnAddress_pointer_331, !noalias !2
        musttail call tailcc void %returnAddress_329(%Pos %make_8731, %Stack %stack)
        ret void
}



define tailcc void @main_2875(%Stack %stack) {
        
    entry:
        
        %stackPointer_50 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_51 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 0
        %sharer_pointer_52 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 1
        %eraser_pointer_53 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_51, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_52, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_53, !noalias !2
        
        %stack_54 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_7772 = call ccc %Prompt @currentPrompt(%Stack %stack_54)
        %stackPointer_64 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 24)
        %returnAddress_pointer_65 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 0
        %sharer_pointer_66 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 1
        %eraser_pointer_67 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 2
        store ptr @returnAddress_55, ptr %returnAddress_pointer_65, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_66, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_67, !noalias !2
        
        %pureApp_8685 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_8687 = add i64 1, 0
        
        %pureApp_8686 = call ccc i64 @infixSub_105(i64 %pureApp_8685, i64 %longLiteral_8687)
        
        
        
        %make_8688_temporary_86 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_8688 = insertvalue %Pos %make_8688_temporary_86, %Object null, 1
        
        
        %stackPointer_335 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 32)
        %p_8_9_7772_pointer_336 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_335, i64 0, i32 0
        store %Prompt %p_8_9_7772, ptr %p_8_9_7772_pointer_336, !noalias !2
        %returnAddress_pointer_337 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 0
        %sharer_pointer_338 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 1
        %eraser_pointer_339 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 2
        store ptr @returnAddress_87, ptr %returnAddress_pointer_337, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_338, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_339, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_8011(i64 %pureApp_8686, %Pos %make_8688, %Stack %stack_54)
        ret void
}



define tailcc void @returnAddress_340(%Pos %v_coe_4108_4268, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_8474 = call ccc i64 @unboxInt_303(%Pos %v_coe_4108_4268)
        
        
        
        %stackPointer_342 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_343 = getelementptr %FrameHeader, %StackPointer %stackPointer_342, i64 0, i32 0
        %returnAddress_341 = load %ReturnAddress, ptr %returnAddress_pointer_343, !noalias !2
        musttail call tailcc void %returnAddress_341(i64 %pureApp_8474, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_348(%Pos %returnValue_349, %Stack %stack) {
        
    entry:
        
        %stackPointer_350 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_3052_4_5894_pointer_351 = getelementptr <{i64}>, %StackPointer %stackPointer_350, i64 0, i32 0
        %v_r_3052_4_5894 = load i64, ptr %v_r_3052_4_5894_pointer_351, !noalias !2
        %stackPointer_353 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_354 = getelementptr %FrameHeader, %StackPointer %stackPointer_353, i64 0, i32 0
        %returnAddress_352 = load %ReturnAddress, ptr %returnAddress_pointer_354, !noalias !2
        musttail call tailcc void %returnAddress_352(%Pos %returnValue_349, %Stack %stack)
        ret void
}



define ccc void @sharer_356(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_357 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_3052_4_5894_355_pointer_358 = getelementptr <{i64}>, %StackPointer %stackPointer_357, i64 0, i32 0
        %v_r_3052_4_5894_355 = load i64, ptr %v_r_3052_4_5894_355_pointer_358, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_357)
        ret void
}



define ccc void @eraser_360(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_361 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_3052_4_5894_359_pointer_362 = getelementptr <{i64}>, %StackPointer %stackPointer_361, i64 0, i32 0
        %v_r_3052_4_5894_359 = load i64, ptr %v_r_3052_4_5894_359_pointer_362, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_361)
        ret void
}



define tailcc void @returnAddress_368(i64 %v_coe_4106_1556_6453, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_8478 = call ccc %Pos @boxInt_301(i64 %v_coe_4106_1556_6453)
        
        
        
        %stackPointer_370 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_371 = getelementptr %FrameHeader, %StackPointer %stackPointer_370, i64 0, i32 0
        %returnAddress_369 = load %ReturnAddress, ptr %returnAddress_pointer_371, !noalias !2
        musttail call tailcc void %returnAddress_369(%Pos %pureApp_8478, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_376(i64 %returnValue_377, %Stack %stack) {
        
    entry:
        
        %stackPointer_378 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_3057_4_782_6129_pointer_379 = getelementptr <{i64}>, %StackPointer %stackPointer_378, i64 0, i32 0
        %v_r_3057_4_782_6129 = load i64, ptr %v_r_3057_4_782_6129_pointer_379, !noalias !2
        %stackPointer_381 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_382 = getelementptr %FrameHeader, %StackPointer %stackPointer_381, i64 0, i32 0
        %returnAddress_380 = load %ReturnAddress, ptr %returnAddress_pointer_382, !noalias !2
        musttail call tailcc void %returnAddress_380(i64 %returnValue_377, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_495(%Pos %returnValue_496, %Stack %stack) {
        
    entry:
        
        %stackPointer_497 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_r_3024_31_109_649_1427_6600_pointer_498 = getelementptr <{%Pos}>, %StackPointer %stackPointer_497, i64 0, i32 0
        %v_r_3024_31_109_649_1427_6600 = load %Pos, ptr %v_r_3024_31_109_649_1427_6600_pointer_498, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3024_31_109_649_1427_6600)
        %stackPointer_500 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_501 = getelementptr %FrameHeader, %StackPointer %stackPointer_500, i64 0, i32 0
        %returnAddress_499 = load %ReturnAddress, ptr %returnAddress_pointer_501, !noalias !2
        musttail call tailcc void %returnAddress_499(%Pos %returnValue_496, %Stack %stack)
        ret void
}



define ccc void @sharer_503(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_504 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_3024_31_109_649_1427_6600_502_pointer_505 = getelementptr <{%Pos}>, %StackPointer %stackPointer_504, i64 0, i32 0
        %v_r_3024_31_109_649_1427_6600_502 = load %Pos, ptr %v_r_3024_31_109_649_1427_6600_502_pointer_505, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3024_31_109_649_1427_6600_502)
        call ccc void @shareFrames(%StackPointer %stackPointer_504)
        ret void
}



define ccc void @eraser_507(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_508 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_3024_31_109_649_1427_6600_506_pointer_509 = getelementptr <{%Pos}>, %StackPointer %stackPointer_508, i64 0, i32 0
        %v_r_3024_31_109_649_1427_6600_506 = load %Pos, ptr %v_r_3024_31_109_649_1427_6600_506_pointer_509, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3024_31_109_649_1427_6600_506)
        call ccc void @eraseFrames(%StackPointer %stackPointer_508)
        ret void
}



define tailcc void @returnAddress_534(%Pos %__106_184_724_1502_8481, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_535 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %bounced_32_110_650_1428_6047_pointer_536 = getelementptr <{%Reference}>, %StackPointer %stackPointer_535, i64 0, i32 0
        %bounced_32_110_650_1428_6047 = load %Reference, ptr %bounced_32_110_650_1428_6047_pointer_536, !noalias !2
        call ccc void @erasePositive(%Pos %__106_184_724_1502_8481)
        
        %get_8572_pointer_537 = call ccc ptr @getVarPointer(%Reference %bounced_32_110_650_1428_6047, %Stack %stack)
        %bounced_32_110_650_1428_6047_old_538 = load %Pos, ptr %get_8572_pointer_537, !noalias !2
        call ccc void @sharePositive(%Pos %bounced_32_110_650_1428_6047_old_538)
        %get_8572 = load %Pos, ptr %get_8572_pointer_537, !noalias !2
        
        %stackPointer_540 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_541 = getelementptr %FrameHeader, %StackPointer %stackPointer_540, i64 0, i32 0
        %returnAddress_539 = load %ReturnAddress, ptr %returnAddress_pointer_541, !noalias !2
        musttail call tailcc void %returnAddress_539(%Pos %get_8572, %Stack %stack)
        ret void
}



define ccc void @sharer_543(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_544 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %bounced_32_110_650_1428_6047_542_pointer_545 = getelementptr <{%Reference}>, %StackPointer %stackPointer_544, i64 0, i32 0
        %bounced_32_110_650_1428_6047_542 = load %Reference, ptr %bounced_32_110_650_1428_6047_542_pointer_545, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_544)
        ret void
}



define ccc void @eraser_547(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_548 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %bounced_32_110_650_1428_6047_546_pointer_549 = getelementptr <{%Reference}>, %StackPointer %stackPointer_548, i64 0, i32 0
        %bounced_32_110_650_1428_6047_546 = load %Reference, ptr %bounced_32_110_650_1428_6047_546_pointer_549, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_548)
        ret void
}



define tailcc void @returnAddress_563(double %v_r_3048_103_181_721_1499_5964, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_564 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_8348_pointer_565 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_564, i64 0, i32 0
        %tmp_8348 = load %Pos, ptr %tmp_8348_pointer_565, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_566 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_564, i64 0, i32 1
        %bounced_32_110_650_1428_6047 = load %Reference, ptr %bounced_32_110_650_1428_6047_pointer_566, !noalias !2
        
        %pureApp_8582 = call ccc %Pos @boxDouble_321(double %v_r_3048_103_181_721_1499_5964)
        
        
        
        %pureApp_8583 = call ccc %Pos @set_2482(%Pos %tmp_8348, %Pos %pureApp_8582)
        call ccc void @erasePositive(%Pos %pureApp_8583)
        
        
        
        %booleanLiteral_8585_temporary_567 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_8585 = insertvalue %Pos %booleanLiteral_8585_temporary_567, %Object null, 1
        
        %bounced_32_110_650_1428_6047pointer_568 = call ccc ptr @getVarPointer(%Reference %bounced_32_110_650_1428_6047, %Stack %stack)
        %bounced_32_110_650_1428_6047_old_569 = load %Pos, ptr %bounced_32_110_650_1428_6047pointer_568, !noalias !2
        call ccc void @erasePositive(%Pos %bounced_32_110_650_1428_6047_old_569)
        store %Pos %booleanLiteral_8585, ptr %bounced_32_110_650_1428_6047pointer_568, !noalias !2
        
        %put_8584_temporary_570 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8584 = insertvalue %Pos %put_8584_temporary_570, %Object null, 1
        
        %stackPointer_572 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_573 = getelementptr %FrameHeader, %StackPointer %stackPointer_572, i64 0, i32 0
        %returnAddress_571 = load %ReturnAddress, ptr %returnAddress_pointer_573, !noalias !2
        musttail call tailcc void %returnAddress_571(%Pos %put_8584, %Stack %stack)
        ret void
}



define ccc void @sharer_576(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_577 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_8348_574_pointer_578 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 0
        %tmp_8348_574 = load %Pos, ptr %tmp_8348_574_pointer_578, !noalias !2
        %bounced_32_110_650_1428_6047_575_pointer_579 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 1
        %bounced_32_110_650_1428_6047_575 = load %Reference, ptr %bounced_32_110_650_1428_6047_575_pointer_579, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8348_574)
        call ccc void @shareFrames(%StackPointer %stackPointer_577)
        ret void
}



define ccc void @eraser_582(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_583 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_8348_580_pointer_584 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_583, i64 0, i32 0
        %tmp_8348_580 = load %Pos, ptr %tmp_8348_580_pointer_584, !noalias !2
        %bounced_32_110_650_1428_6047_581_pointer_585 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_583, i64 0, i32 1
        %bounced_32_110_650_1428_6047_581 = load %Reference, ptr %bounced_32_110_650_1428_6047_581_pointer_585, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8348_580)
        call ccc void @eraseFrames(%StackPointer %stackPointer_583)
        ret void
}



define tailcc void @returnAddress_529(%Pos %__92_170_710_1488_8482, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_530 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_8332_pointer_531 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_530, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_531, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_532 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_530, i64 0, i32 1
        %bounced_32_110_650_1428_6047 = load %Reference, ptr %bounced_32_110_650_1428_6047_pointer_532, !noalias !2
        %tmp_8348_pointer_533 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_530, i64 0, i32 2
        %tmp_8348 = load %Pos, ptr %tmp_8348_pointer_533, !noalias !2
        call ccc void @erasePositive(%Pos %__92_170_710_1488_8482)
        
        call ccc void @sharePositive(%Pos %tmp_8332)
        %pureApp_8568 = call ccc %Pos @get_2478(%Pos %tmp_8332)
        
        
        
        %pureApp_8569 = call ccc double @unboxDouble_323(%Pos %pureApp_8568)
        
        
        
        %doubleLiteral_8571 = fadd double 0.0, 0.0
        
        %pureApp_8570 = call ccc %Pos @infixLt_196(double %pureApp_8569, double %doubleLiteral_8571)
        
        
        %stackPointer_550 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %bounced_32_110_650_1428_6047_pointer_551 = getelementptr <{%Reference}>, %StackPointer %stackPointer_550, i64 0, i32 0
        store %Reference %bounced_32_110_650_1428_6047, ptr %bounced_32_110_650_1428_6047_pointer_551, !noalias !2
        %returnAddress_pointer_552 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_550, i64 0, i32 1, i32 0
        %sharer_pointer_553 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_550, i64 0, i32 1, i32 1
        %eraser_pointer_554 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_550, i64 0, i32 1, i32 2
        store ptr @returnAddress_534, ptr %returnAddress_pointer_552, !noalias !2
        store ptr @sharer_543, ptr %sharer_pointer_553, !noalias !2
        store ptr @eraser_547, ptr %eraser_pointer_554, !noalias !2
        
        %tag_555 = extractvalue %Pos %pureApp_8570, 0
        %fields_556 = extractvalue %Pos %pureApp_8570, 1
        switch i64 %tag_555, label %label_557 [i64 0, label %label_562 i64 1, label %label_603]
    
    label_557:
        
        ret void
    
    label_562:
        call ccc void @erasePositive(%Pos %tmp_8332)
        call ccc void @erasePositive(%Pos %tmp_8348)
        
        %unitLiteral_8573_temporary_558 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8573 = insertvalue %Pos %unitLiteral_8573_temporary_558, %Object null, 1
        
        %stackPointer_560 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_561 = getelementptr %FrameHeader, %StackPointer %stackPointer_560, i64 0, i32 0
        %returnAddress_559 = load %ReturnAddress, ptr %returnAddress_pointer_561, !noalias !2
        musttail call tailcc void %returnAddress_559(%Pos %unitLiteral_8573, %Stack %stack)
        ret void
    
    label_594:
        
        ret void
    
    label_598:
        
        %stackPointer_596 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_597 = getelementptr %FrameHeader, %StackPointer %stackPointer_596, i64 0, i32 0
        %returnAddress_595 = load %ReturnAddress, ptr %returnAddress_pointer_597, !noalias !2
        musttail call tailcc void %returnAddress_595(double %pureApp_8579, %Stack %stack)
        ret void
    
    label_602:
        
        %stackPointer_600 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_601 = getelementptr %FrameHeader, %StackPointer %stackPointer_600, i64 0, i32 0
        %returnAddress_599 = load %ReturnAddress, ptr %returnAddress_pointer_601, !noalias !2
        musttail call tailcc void %returnAddress_599(double %pureApp_8578, %Stack %stack)
        ret void
    
    label_603:
        
        %doubleLiteral_8575 = fadd double 0.0, 0.0
        
        %pureApp_8574 = call ccc %Pos @boxDouble_321(double %doubleLiteral_8575)
        
        
        
        %pureApp_8576 = call ccc %Pos @set_2482(%Pos %tmp_8332, %Pos %pureApp_8574)
        call ccc void @erasePositive(%Pos %pureApp_8576)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8348)
        %pureApp_8577 = call ccc %Pos @get_2478(%Pos %tmp_8348)
        
        
        
        %pureApp_8578 = call ccc double @unboxDouble_323(%Pos %pureApp_8577)
        
        
        
        %doubleLiteral_8580 = fadd double 0.0, 0.0
        
        %pureApp_8579 = call ccc double @infixSub_117(double %doubleLiteral_8580, double %pureApp_8578)
        
        
        
        %pureApp_8581 = call ccc %Pos @infixGt_202(double %pureApp_8578, double %pureApp_8579)
        
        
        %stackPointer_586 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_8348_pointer_587 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_586, i64 0, i32 0
        store %Pos %tmp_8348, ptr %tmp_8348_pointer_587, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_588 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_586, i64 0, i32 1
        store %Reference %bounced_32_110_650_1428_6047, ptr %bounced_32_110_650_1428_6047_pointer_588, !noalias !2
        %returnAddress_pointer_589 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_586, i64 0, i32 1, i32 0
        %sharer_pointer_590 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_586, i64 0, i32 1, i32 1
        %eraser_pointer_591 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_586, i64 0, i32 1, i32 2
        store ptr @returnAddress_563, ptr %returnAddress_pointer_589, !noalias !2
        store ptr @sharer_576, ptr %sharer_pointer_590, !noalias !2
        store ptr @eraser_582, ptr %eraser_pointer_591, !noalias !2
        
        %tag_592 = extractvalue %Pos %pureApp_8581, 0
        %fields_593 = extractvalue %Pos %pureApp_8581, 1
        switch i64 %tag_592, label %label_594 [i64 0, label %label_598 i64 1, label %label_602]
}



define ccc void @sharer_607(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_608 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_604_pointer_609 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_608, i64 0, i32 0
        %tmp_8332_604 = load %Pos, ptr %tmp_8332_604_pointer_609, !noalias !2
        %bounced_32_110_650_1428_6047_605_pointer_610 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_608, i64 0, i32 1
        %bounced_32_110_650_1428_6047_605 = load %Reference, ptr %bounced_32_110_650_1428_6047_605_pointer_610, !noalias !2
        %tmp_8348_606_pointer_611 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_608, i64 0, i32 2
        %tmp_8348_606 = load %Pos, ptr %tmp_8348_606_pointer_611, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8332_604)
        call ccc void @sharePositive(%Pos %tmp_8348_606)
        call ccc void @shareFrames(%StackPointer %stackPointer_608)
        ret void
}



define ccc void @eraser_615(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_616 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_612_pointer_617 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_616, i64 0, i32 0
        %tmp_8332_612 = load %Pos, ptr %tmp_8332_612_pointer_617, !noalias !2
        %bounced_32_110_650_1428_6047_613_pointer_618 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_616, i64 0, i32 1
        %bounced_32_110_650_1428_6047_613 = load %Reference, ptr %bounced_32_110_650_1428_6047_613_pointer_618, !noalias !2
        %tmp_8348_614_pointer_619 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_616, i64 0, i32 2
        %tmp_8348_614 = load %Pos, ptr %tmp_8348_614_pointer_619, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8332_612)
        call ccc void @erasePositive(%Pos %tmp_8348_614)
        call ccc void @eraseFrames(%StackPointer %stackPointer_616)
        ret void
}



define tailcc void @returnAddress_635(double %v_r_3042_87_165_705_1483_6070, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_636 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_8348_pointer_637 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_636, i64 0, i32 0
        %tmp_8348 = load %Pos, ptr %tmp_8348_pointer_637, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_638 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_636, i64 0, i32 1
        %bounced_32_110_650_1428_6047 = load %Reference, ptr %bounced_32_110_650_1428_6047_pointer_638, !noalias !2
        
        %doubleLiteral_8595 = fadd double 0.0, 0.0
        
        %pureApp_8594 = call ccc double @infixSub_117(double %doubleLiteral_8595, double %v_r_3042_87_165_705_1483_6070)
        
        
        
        %pureApp_8596 = call ccc %Pos @boxDouble_321(double %pureApp_8594)
        
        
        
        %pureApp_8597 = call ccc %Pos @set_2482(%Pos %tmp_8348, %Pos %pureApp_8596)
        call ccc void @erasePositive(%Pos %pureApp_8597)
        
        
        
        %booleanLiteral_8599_temporary_639 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_8599 = insertvalue %Pos %booleanLiteral_8599_temporary_639, %Object null, 1
        
        %bounced_32_110_650_1428_6047pointer_640 = call ccc ptr @getVarPointer(%Reference %bounced_32_110_650_1428_6047, %Stack %stack)
        %bounced_32_110_650_1428_6047_old_641 = load %Pos, ptr %bounced_32_110_650_1428_6047pointer_640, !noalias !2
        call ccc void @erasePositive(%Pos %bounced_32_110_650_1428_6047_old_641)
        store %Pos %booleanLiteral_8599, ptr %bounced_32_110_650_1428_6047pointer_640, !noalias !2
        
        %put_8598_temporary_642 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8598 = insertvalue %Pos %put_8598_temporary_642, %Object null, 1
        
        %stackPointer_644 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_645 = getelementptr %FrameHeader, %StackPointer %stackPointer_644, i64 0, i32 0
        %returnAddress_643 = load %ReturnAddress, ptr %returnAddress_pointer_645, !noalias !2
        musttail call tailcc void %returnAddress_643(%Pos %put_8598, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_523(%Pos %__76_154_694_1472_8483, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_524 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %tmp_8332_pointer_525 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_524, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_525, !noalias !2
        %yLimit_30_108_648_1426_6506_pointer_526 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_524, i64 0, i32 1
        %yLimit_30_108_648_1426_6506 = load double, ptr %yLimit_30_108_648_1426_6506_pointer_526, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_527 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_524, i64 0, i32 2
        %bounced_32_110_650_1428_6047 = load %Reference, ptr %bounced_32_110_650_1428_6047_pointer_527, !noalias !2
        %tmp_8348_pointer_528 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_524, i64 0, i32 3
        %tmp_8348 = load %Pos, ptr %tmp_8348_pointer_528, !noalias !2
        call ccc void @erasePositive(%Pos %__76_154_694_1472_8483)
        
        call ccc void @sharePositive(%Pos %tmp_8332)
        %pureApp_8565 = call ccc %Pos @get_2478(%Pos %tmp_8332)
        
        
        
        %pureApp_8566 = call ccc double @unboxDouble_323(%Pos %pureApp_8565)
        
        
        
        %pureApp_8567 = call ccc %Pos @infixGt_202(double %pureApp_8566, double %yLimit_30_108_648_1426_6506)
        
        
        call ccc void @sharePositive(%Pos %tmp_8332)
        call ccc void @sharePositive(%Pos %tmp_8348)
        %stackPointer_620 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_8332_pointer_621 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_620, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_621, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_622 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_620, i64 0, i32 1
        store %Reference %bounced_32_110_650_1428_6047, ptr %bounced_32_110_650_1428_6047_pointer_622, !noalias !2
        %tmp_8348_pointer_623 = getelementptr <{%Pos, %Reference, %Pos}>, %StackPointer %stackPointer_620, i64 0, i32 2
        store %Pos %tmp_8348, ptr %tmp_8348_pointer_623, !noalias !2
        %returnAddress_pointer_624 = getelementptr <{<{%Pos, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_620, i64 0, i32 1, i32 0
        %sharer_pointer_625 = getelementptr <{<{%Pos, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_620, i64 0, i32 1, i32 1
        %eraser_pointer_626 = getelementptr <{<{%Pos, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_620, i64 0, i32 1, i32 2
        store ptr @returnAddress_529, ptr %returnAddress_pointer_624, !noalias !2
        store ptr @sharer_607, ptr %sharer_pointer_625, !noalias !2
        store ptr @eraser_615, ptr %eraser_pointer_626, !noalias !2
        
        %tag_627 = extractvalue %Pos %pureApp_8567, 0
        %fields_628 = extractvalue %Pos %pureApp_8567, 1
        switch i64 %tag_627, label %label_629 [i64 0, label %label_634 i64 1, label %label_667]
    
    label_629:
        
        ret void
    
    label_634:
        call ccc void @erasePositive(%Pos %tmp_8332)
        call ccc void @erasePositive(%Pos %tmp_8348)
        
        %unitLiteral_8586_temporary_630 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8586 = insertvalue %Pos %unitLiteral_8586_temporary_630, %Object null, 1
        
        %stackPointer_632 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_633 = getelementptr %FrameHeader, %StackPointer %stackPointer_632, i64 0, i32 0
        %returnAddress_631 = load %ReturnAddress, ptr %returnAddress_pointer_633, !noalias !2
        musttail call tailcc void %returnAddress_631(%Pos %unitLiteral_8586, %Stack %stack)
        ret void
    
    label_658:
        
        ret void
    
    label_662:
        
        %stackPointer_660 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_661 = getelementptr %FrameHeader, %StackPointer %stackPointer_660, i64 0, i32 0
        %returnAddress_659 = load %ReturnAddress, ptr %returnAddress_pointer_661, !noalias !2
        musttail call tailcc void %returnAddress_659(double %pureApp_8591, %Stack %stack)
        ret void
    
    label_666:
        
        %stackPointer_664 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_665 = getelementptr %FrameHeader, %StackPointer %stackPointer_664, i64 0, i32 0
        %returnAddress_663 = load %ReturnAddress, ptr %returnAddress_pointer_665, !noalias !2
        musttail call tailcc void %returnAddress_663(double %pureApp_8590, %Stack %stack)
        ret void
    
    label_667:
        
        %pureApp_8587 = call ccc %Pos @boxDouble_321(double %yLimit_30_108_648_1426_6506)
        
        
        
        %pureApp_8588 = call ccc %Pos @set_2482(%Pos %tmp_8332, %Pos %pureApp_8587)
        call ccc void @erasePositive(%Pos %pureApp_8588)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8348)
        %pureApp_8589 = call ccc %Pos @get_2478(%Pos %tmp_8348)
        
        
        
        %pureApp_8590 = call ccc double @unboxDouble_323(%Pos %pureApp_8589)
        
        
        
        %doubleLiteral_8592 = fadd double 0.0, 0.0
        
        %pureApp_8591 = call ccc double @infixSub_117(double %doubleLiteral_8592, double %pureApp_8590)
        
        
        
        %pureApp_8593 = call ccc %Pos @infixGt_202(double %pureApp_8590, double %pureApp_8591)
        
        
        %stackPointer_650 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_8348_pointer_651 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_650, i64 0, i32 0
        store %Pos %tmp_8348, ptr %tmp_8348_pointer_651, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_652 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_650, i64 0, i32 1
        store %Reference %bounced_32_110_650_1428_6047, ptr %bounced_32_110_650_1428_6047_pointer_652, !noalias !2
        %returnAddress_pointer_653 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_650, i64 0, i32 1, i32 0
        %sharer_pointer_654 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_650, i64 0, i32 1, i32 1
        %eraser_pointer_655 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_650, i64 0, i32 1, i32 2
        store ptr @returnAddress_635, ptr %returnAddress_pointer_653, !noalias !2
        store ptr @sharer_576, ptr %sharer_pointer_654, !noalias !2
        store ptr @eraser_582, ptr %eraser_pointer_655, !noalias !2
        
        %tag_656 = extractvalue %Pos %pureApp_8593, 0
        %fields_657 = extractvalue %Pos %pureApp_8593, 1
        switch i64 %tag_656, label %label_658 [i64 0, label %label_662 i64 1, label %label_666]
}



define ccc void @sharer_672(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_673 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_668_pointer_674 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_673, i64 0, i32 0
        %tmp_8332_668 = load %Pos, ptr %tmp_8332_668_pointer_674, !noalias !2
        %yLimit_30_108_648_1426_6506_669_pointer_675 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_673, i64 0, i32 1
        %yLimit_30_108_648_1426_6506_669 = load double, ptr %yLimit_30_108_648_1426_6506_669_pointer_675, !noalias !2
        %bounced_32_110_650_1428_6047_670_pointer_676 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_673, i64 0, i32 2
        %bounced_32_110_650_1428_6047_670 = load %Reference, ptr %bounced_32_110_650_1428_6047_670_pointer_676, !noalias !2
        %tmp_8348_671_pointer_677 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_673, i64 0, i32 3
        %tmp_8348_671 = load %Pos, ptr %tmp_8348_671_pointer_677, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8332_668)
        call ccc void @sharePositive(%Pos %tmp_8348_671)
        call ccc void @shareFrames(%StackPointer %stackPointer_673)
        ret void
}



define ccc void @eraser_682(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_683 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_678_pointer_684 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_683, i64 0, i32 0
        %tmp_8332_678 = load %Pos, ptr %tmp_8332_678_pointer_684, !noalias !2
        %yLimit_30_108_648_1426_6506_679_pointer_685 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_683, i64 0, i32 1
        %yLimit_30_108_648_1426_6506_679 = load double, ptr %yLimit_30_108_648_1426_6506_679_pointer_685, !noalias !2
        %bounced_32_110_650_1428_6047_680_pointer_686 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_683, i64 0, i32 2
        %bounced_32_110_650_1428_6047_680 = load %Reference, ptr %bounced_32_110_650_1428_6047_680_pointer_686, !noalias !2
        %tmp_8348_681_pointer_687 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_683, i64 0, i32 3
        %tmp_8348_681 = load %Pos, ptr %tmp_8348_681_pointer_687, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8332_678)
        call ccc void @erasePositive(%Pos %tmp_8348_681)
        call ccc void @eraseFrames(%StackPointer %stackPointer_683)
        ret void
}



define tailcc void @returnAddress_704(double %v_r_3037_73_151_691_1469_6469, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_705 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_8340_pointer_706 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_705, i64 0, i32 0
        %tmp_8340 = load %Pos, ptr %tmp_8340_pointer_706, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_707 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_705, i64 0, i32 1
        %bounced_32_110_650_1428_6047 = load %Reference, ptr %bounced_32_110_650_1428_6047_pointer_707, !noalias !2
        
        %pureApp_8609 = call ccc %Pos @boxDouble_321(double %v_r_3037_73_151_691_1469_6469)
        
        
        
        %pureApp_8610 = call ccc %Pos @set_2482(%Pos %tmp_8340, %Pos %pureApp_8609)
        call ccc void @erasePositive(%Pos %pureApp_8610)
        
        
        
        %booleanLiteral_8612_temporary_708 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_8612 = insertvalue %Pos %booleanLiteral_8612_temporary_708, %Object null, 1
        
        %bounced_32_110_650_1428_6047pointer_709 = call ccc ptr @getVarPointer(%Reference %bounced_32_110_650_1428_6047, %Stack %stack)
        %bounced_32_110_650_1428_6047_old_710 = load %Pos, ptr %bounced_32_110_650_1428_6047pointer_709, !noalias !2
        call ccc void @erasePositive(%Pos %bounced_32_110_650_1428_6047_old_710)
        store %Pos %booleanLiteral_8612, ptr %bounced_32_110_650_1428_6047pointer_709, !noalias !2
        
        %put_8611_temporary_711 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8611 = insertvalue %Pos %put_8611_temporary_711, %Object null, 1
        
        %stackPointer_713 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_714 = getelementptr %FrameHeader, %StackPointer %stackPointer_713, i64 0, i32 0
        %returnAddress_712 = load %ReturnAddress, ptr %returnAddress_pointer_714, !noalias !2
        musttail call tailcc void %returnAddress_712(%Pos %put_8611, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_515(%Pos %__62_140_680_1458_8484, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_516 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 88)
        %tmp_8332_pointer_517 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_516, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_517, !noalias !2
        %yLimit_30_108_648_1426_6506_pointer_518 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_516, i64 0, i32 1
        %yLimit_30_108_648_1426_6506 = load double, ptr %yLimit_30_108_648_1426_6506_pointer_518, !noalias !2
        %tmp_8348_pointer_519 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_516, i64 0, i32 2
        %tmp_8348 = load %Pos, ptr %tmp_8348_pointer_519, !noalias !2
        %tmp_8340_pointer_520 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_516, i64 0, i32 3
        %tmp_8340 = load %Pos, ptr %tmp_8340_pointer_520, !noalias !2
        %tmp_8325_pointer_521 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_516, i64 0, i32 4
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_521, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_522 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_516, i64 0, i32 5
        %bounced_32_110_650_1428_6047 = load %Reference, ptr %bounced_32_110_650_1428_6047_pointer_522, !noalias !2
        call ccc void @erasePositive(%Pos %__62_140_680_1458_8484)
        
        call ccc void @sharePositive(%Pos %tmp_8325)
        %pureApp_8561 = call ccc %Pos @get_2478(%Pos %tmp_8325)
        
        
        
        %pureApp_8562 = call ccc double @unboxDouble_323(%Pos %pureApp_8561)
        
        
        
        %doubleLiteral_8564 = fadd double 0.0, 0.0
        
        %pureApp_8563 = call ccc %Pos @infixLt_196(double %pureApp_8562, double %doubleLiteral_8564)
        
        
        %stackPointer_688 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %tmp_8332_pointer_689 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_688, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_689, !noalias !2
        %yLimit_30_108_648_1426_6506_pointer_690 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_688, i64 0, i32 1
        store double %yLimit_30_108_648_1426_6506, ptr %yLimit_30_108_648_1426_6506_pointer_690, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_691 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_688, i64 0, i32 2
        store %Reference %bounced_32_110_650_1428_6047, ptr %bounced_32_110_650_1428_6047_pointer_691, !noalias !2
        %tmp_8348_pointer_692 = getelementptr <{%Pos, double, %Reference, %Pos}>, %StackPointer %stackPointer_688, i64 0, i32 3
        store %Pos %tmp_8348, ptr %tmp_8348_pointer_692, !noalias !2
        %returnAddress_pointer_693 = getelementptr <{<{%Pos, double, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 0
        %sharer_pointer_694 = getelementptr <{<{%Pos, double, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 1
        %eraser_pointer_695 = getelementptr <{<{%Pos, double, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 2
        store ptr @returnAddress_523, ptr %returnAddress_pointer_693, !noalias !2
        store ptr @sharer_672, ptr %sharer_pointer_694, !noalias !2
        store ptr @eraser_682, ptr %eraser_pointer_695, !noalias !2
        
        %tag_696 = extractvalue %Pos %pureApp_8563, 0
        %fields_697 = extractvalue %Pos %pureApp_8563, 1
        switch i64 %tag_696, label %label_698 [i64 0, label %label_703 i64 1, label %label_736]
    
    label_698:
        
        ret void
    
    label_703:
        call ccc void @erasePositive(%Pos %tmp_8325)
        call ccc void @erasePositive(%Pos %tmp_8340)
        
        %unitLiteral_8600_temporary_699 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8600 = insertvalue %Pos %unitLiteral_8600_temporary_699, %Object null, 1
        
        %stackPointer_701 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_702 = getelementptr %FrameHeader, %StackPointer %stackPointer_701, i64 0, i32 0
        %returnAddress_700 = load %ReturnAddress, ptr %returnAddress_pointer_702, !noalias !2
        musttail call tailcc void %returnAddress_700(%Pos %unitLiteral_8600, %Stack %stack)
        ret void
    
    label_727:
        
        ret void
    
    label_731:
        
        %stackPointer_729 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_730 = getelementptr %FrameHeader, %StackPointer %stackPointer_729, i64 0, i32 0
        %returnAddress_728 = load %ReturnAddress, ptr %returnAddress_pointer_730, !noalias !2
        musttail call tailcc void %returnAddress_728(double %pureApp_8606, %Stack %stack)
        ret void
    
    label_735:
        
        %stackPointer_733 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_734 = getelementptr %FrameHeader, %StackPointer %stackPointer_733, i64 0, i32 0
        %returnAddress_732 = load %ReturnAddress, ptr %returnAddress_pointer_734, !noalias !2
        musttail call tailcc void %returnAddress_732(double %pureApp_8605, %Stack %stack)
        ret void
    
    label_736:
        
        %doubleLiteral_8602 = fadd double 0.0, 0.0
        
        %pureApp_8601 = call ccc %Pos @boxDouble_321(double %doubleLiteral_8602)
        
        
        
        %pureApp_8603 = call ccc %Pos @set_2482(%Pos %tmp_8325, %Pos %pureApp_8601)
        call ccc void @erasePositive(%Pos %pureApp_8603)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8340)
        %pureApp_8604 = call ccc %Pos @get_2478(%Pos %tmp_8340)
        
        
        
        %pureApp_8605 = call ccc double @unboxDouble_323(%Pos %pureApp_8604)
        
        
        
        %doubleLiteral_8607 = fadd double 0.0, 0.0
        
        %pureApp_8606 = call ccc double @infixSub_117(double %doubleLiteral_8607, double %pureApp_8605)
        
        
        
        %pureApp_8608 = call ccc %Pos @infixGt_202(double %pureApp_8605, double %pureApp_8606)
        
        
        %stackPointer_719 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_8340_pointer_720 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_719, i64 0, i32 0
        store %Pos %tmp_8340, ptr %tmp_8340_pointer_720, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_721 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_719, i64 0, i32 1
        store %Reference %bounced_32_110_650_1428_6047, ptr %bounced_32_110_650_1428_6047_pointer_721, !noalias !2
        %returnAddress_pointer_722 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_719, i64 0, i32 1, i32 0
        %sharer_pointer_723 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_719, i64 0, i32 1, i32 1
        %eraser_pointer_724 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_719, i64 0, i32 1, i32 2
        store ptr @returnAddress_704, ptr %returnAddress_pointer_722, !noalias !2
        store ptr @sharer_576, ptr %sharer_pointer_723, !noalias !2
        store ptr @eraser_582, ptr %eraser_pointer_724, !noalias !2
        
        %tag_725 = extractvalue %Pos %pureApp_8608, 0
        %fields_726 = extractvalue %Pos %pureApp_8608, 1
        switch i64 %tag_725, label %label_727 [i64 0, label %label_731 i64 1, label %label_735]
}



define ccc void @sharer_743(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_744 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_737_pointer_745 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_744, i64 0, i32 0
        %tmp_8332_737 = load %Pos, ptr %tmp_8332_737_pointer_745, !noalias !2
        %yLimit_30_108_648_1426_6506_738_pointer_746 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_744, i64 0, i32 1
        %yLimit_30_108_648_1426_6506_738 = load double, ptr %yLimit_30_108_648_1426_6506_738_pointer_746, !noalias !2
        %tmp_8348_739_pointer_747 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_744, i64 0, i32 2
        %tmp_8348_739 = load %Pos, ptr %tmp_8348_739_pointer_747, !noalias !2
        %tmp_8340_740_pointer_748 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_744, i64 0, i32 3
        %tmp_8340_740 = load %Pos, ptr %tmp_8340_740_pointer_748, !noalias !2
        %tmp_8325_741_pointer_749 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_744, i64 0, i32 4
        %tmp_8325_741 = load %Pos, ptr %tmp_8325_741_pointer_749, !noalias !2
        %bounced_32_110_650_1428_6047_742_pointer_750 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_744, i64 0, i32 5
        %bounced_32_110_650_1428_6047_742 = load %Reference, ptr %bounced_32_110_650_1428_6047_742_pointer_750, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8332_737)
        call ccc void @sharePositive(%Pos %tmp_8348_739)
        call ccc void @sharePositive(%Pos %tmp_8340_740)
        call ccc void @sharePositive(%Pos %tmp_8325_741)
        call ccc void @shareFrames(%StackPointer %stackPointer_744)
        ret void
}



define ccc void @eraser_757(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_758 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_751_pointer_759 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_758, i64 0, i32 0
        %tmp_8332_751 = load %Pos, ptr %tmp_8332_751_pointer_759, !noalias !2
        %yLimit_30_108_648_1426_6506_752_pointer_760 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_758, i64 0, i32 1
        %yLimit_30_108_648_1426_6506_752 = load double, ptr %yLimit_30_108_648_1426_6506_752_pointer_760, !noalias !2
        %tmp_8348_753_pointer_761 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_758, i64 0, i32 2
        %tmp_8348_753 = load %Pos, ptr %tmp_8348_753_pointer_761, !noalias !2
        %tmp_8340_754_pointer_762 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_758, i64 0, i32 3
        %tmp_8340_754 = load %Pos, ptr %tmp_8340_754_pointer_762, !noalias !2
        %tmp_8325_755_pointer_763 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_758, i64 0, i32 4
        %tmp_8325_755 = load %Pos, ptr %tmp_8325_755_pointer_763, !noalias !2
        %bounced_32_110_650_1428_6047_756_pointer_764 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_758, i64 0, i32 5
        %bounced_32_110_650_1428_6047_756 = load %Reference, ptr %bounced_32_110_650_1428_6047_756_pointer_764, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8332_751)
        call ccc void @erasePositive(%Pos %tmp_8348_753)
        call ccc void @erasePositive(%Pos %tmp_8340_754)
        call ccc void @erasePositive(%Pos %tmp_8325_755)
        call ccc void @eraseFrames(%StackPointer %stackPointer_758)
        ret void
}



define tailcc void @returnAddress_783(double %v_r_3031_57_135_675_1453_6285, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_784 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_8340_pointer_785 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_784, i64 0, i32 0
        %tmp_8340 = load %Pos, ptr %tmp_8340_pointer_785, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_786 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_784, i64 0, i32 1
        %bounced_32_110_650_1428_6047 = load %Reference, ptr %bounced_32_110_650_1428_6047_pointer_786, !noalias !2
        
        %doubleLiteral_8622 = fadd double 0.0, 0.0
        
        %pureApp_8621 = call ccc double @infixSub_117(double %doubleLiteral_8622, double %v_r_3031_57_135_675_1453_6285)
        
        
        
        %pureApp_8623 = call ccc %Pos @boxDouble_321(double %pureApp_8621)
        
        
        
        %pureApp_8624 = call ccc %Pos @set_2482(%Pos %tmp_8340, %Pos %pureApp_8623)
        call ccc void @erasePositive(%Pos %pureApp_8624)
        
        
        
        %booleanLiteral_8626_temporary_787 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_8626 = insertvalue %Pos %booleanLiteral_8626_temporary_787, %Object null, 1
        
        %bounced_32_110_650_1428_6047pointer_788 = call ccc ptr @getVarPointer(%Reference %bounced_32_110_650_1428_6047, %Stack %stack)
        %bounced_32_110_650_1428_6047_old_789 = load %Pos, ptr %bounced_32_110_650_1428_6047pointer_788, !noalias !2
        call ccc void @erasePositive(%Pos %bounced_32_110_650_1428_6047_old_789)
        store %Pos %booleanLiteral_8626, ptr %bounced_32_110_650_1428_6047pointer_788, !noalias !2
        
        %put_8625_temporary_790 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8625 = insertvalue %Pos %put_8625_temporary_790, %Object null, 1
        
        %stackPointer_792 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_793 = getelementptr %FrameHeader, %StackPointer %stackPointer_792, i64 0, i32 0
        %returnAddress_791 = load %ReturnAddress, ptr %returnAddress_pointer_793, !noalias !2
        musttail call tailcc void %returnAddress_791(%Pos %put_8625, %Stack %stack)
        ret void
}



define tailcc void @new_8539_clause_488(%Object %closure, %Stack %stack) {
        
    entry:
        
        %environment_489 = call ccc %Environment @objectEnvironment(%Object %closure)
        %tmp_8332_pointer_490 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_489, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_490, !noalias !2
        %tmp_8325_pointer_491 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_489, i64 0, i32 1
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_491, !noalias !2
        %tmp_8348_pointer_492 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_489, i64 0, i32 2
        %tmp_8348 = load %Pos, ptr %tmp_8348_pointer_492, !noalias !2
        %tmp_8340_pointer_493 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_489, i64 0, i32 3
        %tmp_8340 = load %Pos, ptr %tmp_8340_pointer_493, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8332)
        call ccc void @sharePositive(%Pos %tmp_8325)
        call ccc void @sharePositive(%Pos %tmp_8348)
        call ccc void @sharePositive(%Pos %tmp_8340)
        call ccc void @eraseObject(%Object %closure)
        
        %doubleLiteral_8540 = fadd double 500.0, 0.0
        
        
        
        %doubleLiteral_8541 = fadd double 500.0, 0.0
        
        
        
        %booleanLiteral_8542_temporary_494 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_8542 = insertvalue %Pos %booleanLiteral_8542_temporary_494, %Object null, 1
        
        
        %bounced_32_110_650_1428_6047 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_510 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %v_r_3024_31_109_649_1427_6600_pointer_511 = getelementptr <{%Pos}>, %StackPointer %stackPointer_510, i64 0, i32 0
        store %Pos %booleanLiteral_8542, ptr %v_r_3024_31_109_649_1427_6600_pointer_511, !noalias !2
        %returnAddress_pointer_512 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_510, i64 0, i32 1, i32 0
        %sharer_pointer_513 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_510, i64 0, i32 1, i32 1
        %eraser_pointer_514 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_510, i64 0, i32 1, i32 2
        store ptr @returnAddress_495, ptr %returnAddress_pointer_512, !noalias !2
        store ptr @sharer_503, ptr %sharer_pointer_513, !noalias !2
        store ptr @eraser_507, ptr %eraser_pointer_514, !noalias !2
        
        call ccc void @sharePositive(%Pos %tmp_8325)
        %pureApp_8544 = call ccc %Pos @get_2478(%Pos %tmp_8325)
        
        
        
        %pureApp_8545 = call ccc double @unboxDouble_323(%Pos %pureApp_8544)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8340)
        %pureApp_8546 = call ccc %Pos @get_2478(%Pos %tmp_8340)
        
        
        
        %pureApp_8547 = call ccc double @unboxDouble_323(%Pos %pureApp_8546)
        
        
        
        %pureApp_8548 = call ccc double @infixAdd_111(double %pureApp_8545, double %pureApp_8547)
        
        
        
        %pureApp_8549 = call ccc %Pos @boxDouble_321(double %pureApp_8548)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8325)
        %pureApp_8550 = call ccc %Pos @set_2482(%Pos %tmp_8325, %Pos %pureApp_8549)
        call ccc void @erasePositive(%Pos %pureApp_8550)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8332)
        %pureApp_8551 = call ccc %Pos @get_2478(%Pos %tmp_8332)
        
        
        
        %pureApp_8552 = call ccc double @unboxDouble_323(%Pos %pureApp_8551)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8348)
        %pureApp_8553 = call ccc %Pos @get_2478(%Pos %tmp_8348)
        
        
        
        %pureApp_8554 = call ccc double @unboxDouble_323(%Pos %pureApp_8553)
        
        
        
        %pureApp_8555 = call ccc double @infixAdd_111(double %pureApp_8552, double %pureApp_8554)
        
        
        
        %pureApp_8556 = call ccc %Pos @boxDouble_321(double %pureApp_8555)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8332)
        %pureApp_8557 = call ccc %Pos @set_2482(%Pos %tmp_8332, %Pos %pureApp_8556)
        call ccc void @erasePositive(%Pos %pureApp_8557)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8325)
        %pureApp_8558 = call ccc %Pos @get_2478(%Pos %tmp_8325)
        
        
        
        %pureApp_8559 = call ccc double @unboxDouble_323(%Pos %pureApp_8558)
        
        
        
        %pureApp_8560 = call ccc %Pos @infixGt_202(double %pureApp_8559, double %doubleLiteral_8540)
        
        
        call ccc void @sharePositive(%Pos %tmp_8340)
        call ccc void @sharePositive(%Pos %tmp_8325)
        %stackPointer_765 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 112)
        %tmp_8332_pointer_766 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_765, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_766, !noalias !2
        %yLimit_30_108_648_1426_6506_pointer_767 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_765, i64 0, i32 1
        store double %doubleLiteral_8541, ptr %yLimit_30_108_648_1426_6506_pointer_767, !noalias !2
        %tmp_8348_pointer_768 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_765, i64 0, i32 2
        store %Pos %tmp_8348, ptr %tmp_8348_pointer_768, !noalias !2
        %tmp_8340_pointer_769 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_765, i64 0, i32 3
        store %Pos %tmp_8340, ptr %tmp_8340_pointer_769, !noalias !2
        %tmp_8325_pointer_770 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_765, i64 0, i32 4
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_770, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_771 = getelementptr <{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %StackPointer %stackPointer_765, i64 0, i32 5
        store %Reference %bounced_32_110_650_1428_6047, ptr %bounced_32_110_650_1428_6047_pointer_771, !noalias !2
        %returnAddress_pointer_772 = getelementptr <{<{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_765, i64 0, i32 1, i32 0
        %sharer_pointer_773 = getelementptr <{<{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_765, i64 0, i32 1, i32 1
        %eraser_pointer_774 = getelementptr <{<{%Pos, double, %Pos, %Pos, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_765, i64 0, i32 1, i32 2
        store ptr @returnAddress_515, ptr %returnAddress_pointer_772, !noalias !2
        store ptr @sharer_743, ptr %sharer_pointer_773, !noalias !2
        store ptr @eraser_757, ptr %eraser_pointer_774, !noalias !2
        
        %tag_775 = extractvalue %Pos %pureApp_8560, 0
        %fields_776 = extractvalue %Pos %pureApp_8560, 1
        switch i64 %tag_775, label %label_777 [i64 0, label %label_782 i64 1, label %label_815]
    
    label_777:
        
        ret void
    
    label_782:
        call ccc void @erasePositive(%Pos %tmp_8325)
        call ccc void @erasePositive(%Pos %tmp_8340)
        
        %unitLiteral_8613_temporary_778 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8613 = insertvalue %Pos %unitLiteral_8613_temporary_778, %Object null, 1
        
        %stackPointer_780 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_781 = getelementptr %FrameHeader, %StackPointer %stackPointer_780, i64 0, i32 0
        %returnAddress_779 = load %ReturnAddress, ptr %returnAddress_pointer_781, !noalias !2
        musttail call tailcc void %returnAddress_779(%Pos %unitLiteral_8613, %Stack %stack)
        ret void
    
    label_806:
        
        ret void
    
    label_810:
        
        %stackPointer_808 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_809 = getelementptr %FrameHeader, %StackPointer %stackPointer_808, i64 0, i32 0
        %returnAddress_807 = load %ReturnAddress, ptr %returnAddress_pointer_809, !noalias !2
        musttail call tailcc void %returnAddress_807(double %pureApp_8618, %Stack %stack)
        ret void
    
    label_814:
        
        %stackPointer_812 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_813 = getelementptr %FrameHeader, %StackPointer %stackPointer_812, i64 0, i32 0
        %returnAddress_811 = load %ReturnAddress, ptr %returnAddress_pointer_813, !noalias !2
        musttail call tailcc void %returnAddress_811(double %pureApp_8617, %Stack %stack)
        ret void
    
    label_815:
        
        %pureApp_8614 = call ccc %Pos @boxDouble_321(double %doubleLiteral_8540)
        
        
        
        %pureApp_8615 = call ccc %Pos @set_2482(%Pos %tmp_8325, %Pos %pureApp_8614)
        call ccc void @erasePositive(%Pos %pureApp_8615)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8340)
        %pureApp_8616 = call ccc %Pos @get_2478(%Pos %tmp_8340)
        
        
        
        %pureApp_8617 = call ccc double @unboxDouble_323(%Pos %pureApp_8616)
        
        
        
        %doubleLiteral_8619 = fadd double 0.0, 0.0
        
        %pureApp_8618 = call ccc double @infixSub_117(double %doubleLiteral_8619, double %pureApp_8617)
        
        
        
        %pureApp_8620 = call ccc %Pos @infixGt_202(double %pureApp_8617, double %pureApp_8618)
        
        
        %stackPointer_798 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_8340_pointer_799 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_798, i64 0, i32 0
        store %Pos %tmp_8340, ptr %tmp_8340_pointer_799, !noalias !2
        %bounced_32_110_650_1428_6047_pointer_800 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_798, i64 0, i32 1
        store %Reference %bounced_32_110_650_1428_6047, ptr %bounced_32_110_650_1428_6047_pointer_800, !noalias !2
        %returnAddress_pointer_801 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_798, i64 0, i32 1, i32 0
        %sharer_pointer_802 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_798, i64 0, i32 1, i32 1
        %eraser_pointer_803 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_798, i64 0, i32 1, i32 2
        store ptr @returnAddress_783, ptr %returnAddress_pointer_801, !noalias !2
        store ptr @sharer_576, ptr %sharer_pointer_802, !noalias !2
        store ptr @eraser_582, ptr %eraser_pointer_803, !noalias !2
        
        %tag_804 = extractvalue %Pos %pureApp_8620, 0
        %fields_805 = extractvalue %Pos %pureApp_8620, 1
        switch i64 %tag_804, label %label_806 [i64 0, label %label_810 i64 1, label %label_814]
}


@vtable_816 = private constant [1 x ptr] [ptr @new_8539_clause_488]


define ccc void @eraser_823(%Environment %environment) {
        
    entry:
        
        %tmp_8332_819_pointer_824 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_8332_819 = load %Pos, ptr %tmp_8332_819_pointer_824, !noalias !2
        %tmp_8325_820_pointer_825 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %tmp_8325_820 = load %Pos, ptr %tmp_8325_820_pointer_825, !noalias !2
        %tmp_8348_821_pointer_826 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment, i64 0, i32 2
        %tmp_8348_821 = load %Pos, ptr %tmp_8348_821_pointer_826, !noalias !2
        %tmp_8340_822_pointer_827 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment, i64 0, i32 3
        %tmp_8340_822 = load %Pos, ptr %tmp_8340_822_pointer_827, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8332_819)
        call ccc void @erasePositive(%Pos %tmp_8325_820)
        call ccc void @erasePositive(%Pos %tmp_8348_821)
        call ccc void @erasePositive(%Pos %tmp_8340_822)
        ret void
}



define tailcc void @returnAddress_479(i64 %v_r_3022_22_21_482_1260_6255, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_480 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %tmp_8332_pointer_481 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_480, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_481, !noalias !2
        %tmp_8455_pointer_482 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_480, i64 0, i32 1
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_482, !noalias !2
        %ballCount_3_781_6265_pointer_483 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_480, i64 0, i32 2
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_483, !noalias !2
        %seed_5_5892_pointer_484 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_480, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_484, !noalias !2
        %tmp_8340_pointer_485 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_480, i64 0, i32 4
        %tmp_8340 = load %Pos, ptr %tmp_8340_pointer_485, !noalias !2
        %tmp_8325_pointer_486 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_480, i64 0, i32 5
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_486, !noalias !2
        %i_6_12_461_1239_6395_pointer_487 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_480, i64 0, i32 6
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_487, !noalias !2
        
        %longLiteral_8533 = add i64 300, 0
        
        %pureApp_8532 = call ccc i64 @mod_108(i64 %v_r_3022_22_21_482_1260_6255, i64 %longLiteral_8533)
        
        
        
        %longLiteral_8535 = add i64 150, 0
        
        %pureApp_8534 = call ccc i64 @infixSub_105(i64 %pureApp_8532, i64 %longLiteral_8535)
        
        
        
        %pureApp_8536 = call ccc double @toDouble_156(i64 %pureApp_8534)
        
        
        
        %pureApp_8537 = call ccc %Pos @boxDouble_321(double %pureApp_8536)
        
        
        
        %pureApp_8538 = call ccc %Pos @ref_2475(%Pos %pureApp_8537)
        
        
        
        %closure_817 = call ccc %Object @newObject(ptr @eraser_823, i64 64)
        %environment_818 = call ccc %Environment @objectEnvironment(%Object %closure_817)
        %tmp_8332_pointer_828 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_818, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_828, !noalias !2
        %tmp_8325_pointer_829 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_818, i64 0, i32 1
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_829, !noalias !2
        %tmp_8348_pointer_830 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_818, i64 0, i32 2
        store %Pos %pureApp_8538, ptr %tmp_8348_pointer_830, !noalias !2
        %tmp_8340_pointer_831 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_818, i64 0, i32 3
        store %Pos %tmp_8340, ptr %tmp_8340_pointer_831, !noalias !2
        %vtable_temporary_832 = insertvalue %Neg zeroinitializer, ptr @vtable_816, 0
        %new_8539 = insertvalue %Neg %vtable_temporary_832, %Object %closure_817, 1
        
        %new_8539_8627 = call ccc %Pos @box(%Neg %new_8539)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_8455)
        %pureApp_8628 = call ccc %Pos @unsafeSet_2506(%Pos %tmp_8455, i64 %i_6_12_461_1239_6395, %Pos %new_8539_8627)
        call ccc void @erasePositive(%Pos %pureApp_8628)
        
        
        
        %longLiteral_8630 = add i64 1, 0
        
        %pureApp_8629 = call ccc i64 @infixAdd_96(i64 %i_6_12_461_1239_6395, i64 %longLiteral_8630)
        
        
        
        
        
        musttail call tailcc void @loop_5_11_460_1238_6021(i64 %pureApp_8629, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Reference %seed_5_5892, %Stack %stack)
        ret void
}



define ccc void @sharer_840(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_841 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_833_pointer_842 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_841, i64 0, i32 0
        %tmp_8332_833 = load %Pos, ptr %tmp_8332_833_pointer_842, !noalias !2
        %tmp_8455_834_pointer_843 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_841, i64 0, i32 1
        %tmp_8455_834 = load %Pos, ptr %tmp_8455_834_pointer_843, !noalias !2
        %ballCount_3_781_6265_835_pointer_844 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_841, i64 0, i32 2
        %ballCount_3_781_6265_835 = load i64, ptr %ballCount_3_781_6265_835_pointer_844, !noalias !2
        %seed_5_5892_836_pointer_845 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_841, i64 0, i32 3
        %seed_5_5892_836 = load %Reference, ptr %seed_5_5892_836_pointer_845, !noalias !2
        %tmp_8340_837_pointer_846 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_841, i64 0, i32 4
        %tmp_8340_837 = load %Pos, ptr %tmp_8340_837_pointer_846, !noalias !2
        %tmp_8325_838_pointer_847 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_841, i64 0, i32 5
        %tmp_8325_838 = load %Pos, ptr %tmp_8325_838_pointer_847, !noalias !2
        %i_6_12_461_1239_6395_839_pointer_848 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_841, i64 0, i32 6
        %i_6_12_461_1239_6395_839 = load i64, ptr %i_6_12_461_1239_6395_839_pointer_848, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8332_833)
        call ccc void @sharePositive(%Pos %tmp_8455_834)
        call ccc void @sharePositive(%Pos %tmp_8340_837)
        call ccc void @sharePositive(%Pos %tmp_8325_838)
        call ccc void @shareFrames(%StackPointer %stackPointer_841)
        ret void
}



define ccc void @eraser_856(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_857 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_849_pointer_858 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_857, i64 0, i32 0
        %tmp_8332_849 = load %Pos, ptr %tmp_8332_849_pointer_858, !noalias !2
        %tmp_8455_850_pointer_859 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_857, i64 0, i32 1
        %tmp_8455_850 = load %Pos, ptr %tmp_8455_850_pointer_859, !noalias !2
        %ballCount_3_781_6265_851_pointer_860 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_857, i64 0, i32 2
        %ballCount_3_781_6265_851 = load i64, ptr %ballCount_3_781_6265_851_pointer_860, !noalias !2
        %seed_5_5892_852_pointer_861 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_857, i64 0, i32 3
        %seed_5_5892_852 = load %Reference, ptr %seed_5_5892_852_pointer_861, !noalias !2
        %tmp_8340_853_pointer_862 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_857, i64 0, i32 4
        %tmp_8340_853 = load %Pos, ptr %tmp_8340_853_pointer_862, !noalias !2
        %tmp_8325_854_pointer_863 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_857, i64 0, i32 5
        %tmp_8325_854 = load %Pos, ptr %tmp_8325_854_pointer_863, !noalias !2
        %i_6_12_461_1239_6395_855_pointer_864 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_857, i64 0, i32 6
        %i_6_12_461_1239_6395_855 = load i64, ptr %i_6_12_461_1239_6395_855_pointer_864, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8332_849)
        call ccc void @erasePositive(%Pos %tmp_8455_850)
        call ccc void @erasePositive(%Pos %tmp_8340_853)
        call ccc void @erasePositive(%Pos %tmp_8325_854)
        call ccc void @eraseFrames(%StackPointer %stackPointer_857)
        ret void
}



define tailcc void @returnAddress_470(%Pos %__11_5_8485, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_471 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %tmp_8332_pointer_472 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_471, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_472, !noalias !2
        %tmp_8455_pointer_473 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_471, i64 0, i32 1
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_473, !noalias !2
        %ballCount_3_781_6265_pointer_474 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_471, i64 0, i32 2
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_474, !noalias !2
        %seed_5_5892_pointer_475 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_471, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_475, !noalias !2
        %tmp_8340_pointer_476 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_471, i64 0, i32 4
        %tmp_8340 = load %Pos, ptr %tmp_8340_pointer_476, !noalias !2
        %tmp_8325_pointer_477 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_471, i64 0, i32 5
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_477, !noalias !2
        %i_6_12_461_1239_6395_pointer_478 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_471, i64 0, i32 6
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_478, !noalias !2
        call ccc void @erasePositive(%Pos %__11_5_8485)
        %stackPointer_865 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %tmp_8332_pointer_866 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_865, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_866, !noalias !2
        %tmp_8455_pointer_867 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_865, i64 0, i32 1
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_867, !noalias !2
        %ballCount_3_781_6265_pointer_868 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_865, i64 0, i32 2
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_868, !noalias !2
        %seed_5_5892_pointer_869 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_865, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_869, !noalias !2
        %tmp_8340_pointer_870 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_865, i64 0, i32 4
        store %Pos %tmp_8340, ptr %tmp_8340_pointer_870, !noalias !2
        %tmp_8325_pointer_871 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_865, i64 0, i32 5
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_871, !noalias !2
        %i_6_12_461_1239_6395_pointer_872 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_865, i64 0, i32 6
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_872, !noalias !2
        %returnAddress_pointer_873 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_865, i64 0, i32 1, i32 0
        %sharer_pointer_874 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_865, i64 0, i32 1, i32 1
        %eraser_pointer_875 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_865, i64 0, i32 1, i32 2
        store ptr @returnAddress_479, ptr %returnAddress_pointer_873, !noalias !2
        store ptr @sharer_840, ptr %sharer_pointer_874, !noalias !2
        store ptr @eraser_856, ptr %eraser_pointer_875, !noalias !2
        
        %get_8631_pointer_876 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_877 = load i64, ptr %get_8631_pointer_876, !noalias !2
        %get_8631 = load i64, ptr %get_8631_pointer_876, !noalias !2
        
        %stackPointer_879 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_880 = getelementptr %FrameHeader, %StackPointer %stackPointer_879, i64 0, i32 0
        %returnAddress_878 = load %ReturnAddress, ptr %returnAddress_pointer_880, !noalias !2
        musttail call tailcc void %returnAddress_878(i64 %get_8631, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_461(i64 %v_r_3053_7_1_7290, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_462 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %tmp_8332_pointer_463 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_462, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_463, !noalias !2
        %tmp_8455_pointer_464 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_462, i64 0, i32 1
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_464, !noalias !2
        %ballCount_3_781_6265_pointer_465 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_462, i64 0, i32 2
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_465, !noalias !2
        %seed_5_5892_pointer_466 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_462, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_466, !noalias !2
        %tmp_8340_pointer_467 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_462, i64 0, i32 4
        %tmp_8340 = load %Pos, ptr %tmp_8340_pointer_467, !noalias !2
        %tmp_8325_pointer_468 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_462, i64 0, i32 5
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_468, !noalias !2
        %i_6_12_461_1239_6395_pointer_469 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_462, i64 0, i32 6
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_469, !noalias !2
        
        %longLiteral_8527 = add i64 1309, 0
        
        %pureApp_8526 = call ccc i64 @infixMul_99(i64 %v_r_3053_7_1_7290, i64 %longLiteral_8527)
        
        
        
        %longLiteral_8529 = add i64 13849, 0
        
        %pureApp_8528 = call ccc i64 @infixAdd_96(i64 %pureApp_8526, i64 %longLiteral_8529)
        
        
        
        %longLiteral_8531 = add i64 65535, 0
        
        %pureApp_8530 = call ccc i64 @bitwiseAnd_234(i64 %pureApp_8528, i64 %longLiteral_8531)
        
        
        %stackPointer_895 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %tmp_8332_pointer_896 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_895, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_896, !noalias !2
        %tmp_8455_pointer_897 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_895, i64 0, i32 1
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_897, !noalias !2
        %ballCount_3_781_6265_pointer_898 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_895, i64 0, i32 2
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_898, !noalias !2
        %seed_5_5892_pointer_899 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_895, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_899, !noalias !2
        %tmp_8340_pointer_900 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_895, i64 0, i32 4
        store %Pos %tmp_8340, ptr %tmp_8340_pointer_900, !noalias !2
        %tmp_8325_pointer_901 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_895, i64 0, i32 5
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_901, !noalias !2
        %i_6_12_461_1239_6395_pointer_902 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_895, i64 0, i32 6
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_902, !noalias !2
        %returnAddress_pointer_903 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_895, i64 0, i32 1, i32 0
        %sharer_pointer_904 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_895, i64 0, i32 1, i32 1
        %eraser_pointer_905 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_895, i64 0, i32 1, i32 2
        store ptr @returnAddress_470, ptr %returnAddress_pointer_903, !noalias !2
        store ptr @sharer_840, ptr %sharer_pointer_904, !noalias !2
        store ptr @eraser_856, ptr %eraser_pointer_905, !noalias !2
        
        %seed_5_5892pointer_906 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_907 = load i64, ptr %seed_5_5892pointer_906, !noalias !2
        store i64 %pureApp_8530, ptr %seed_5_5892pointer_906, !noalias !2
        
        %put_8632_temporary_908 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8632 = insertvalue %Pos %put_8632_temporary_908, %Object null, 1
        
        %stackPointer_910 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_911 = getelementptr %FrameHeader, %StackPointer %stackPointer_910, i64 0, i32 0
        %returnAddress_909 = load %ReturnAddress, ptr %returnAddress_pointer_911, !noalias !2
        musttail call tailcc void %returnAddress_909(%Pos %put_8632, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_453(i64 %v_r_3020_15_14_475_1253_6127, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_454 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 80)
        %tmp_8332_pointer_455 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_454, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_455, !noalias !2
        %tmp_8455_pointer_456 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_454, i64 0, i32 1
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_456, !noalias !2
        %ballCount_3_781_6265_pointer_457 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_454, i64 0, i32 2
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_457, !noalias !2
        %seed_5_5892_pointer_458 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_454, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_458, !noalias !2
        %tmp_8325_pointer_459 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_454, i64 0, i32 4
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_459, !noalias !2
        %i_6_12_461_1239_6395_pointer_460 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_454, i64 0, i32 5
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_460, !noalias !2
        
        %longLiteral_8520 = add i64 300, 0
        
        %pureApp_8519 = call ccc i64 @mod_108(i64 %v_r_3020_15_14_475_1253_6127, i64 %longLiteral_8520)
        
        
        
        %longLiteral_8522 = add i64 150, 0
        
        %pureApp_8521 = call ccc i64 @infixSub_105(i64 %pureApp_8519, i64 %longLiteral_8522)
        
        
        
        %pureApp_8523 = call ccc double @toDouble_156(i64 %pureApp_8521)
        
        
        
        %pureApp_8524 = call ccc %Pos @boxDouble_321(double %pureApp_8523)
        
        
        
        %pureApp_8525 = call ccc %Pos @ref_2475(%Pos %pureApp_8524)
        
        
        %stackPointer_926 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %tmp_8332_pointer_927 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_926, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_927, !noalias !2
        %tmp_8455_pointer_928 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_926, i64 0, i32 1
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_928, !noalias !2
        %ballCount_3_781_6265_pointer_929 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_926, i64 0, i32 2
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_929, !noalias !2
        %seed_5_5892_pointer_930 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_926, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_930, !noalias !2
        %tmp_8340_pointer_931 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_926, i64 0, i32 4
        store %Pos %pureApp_8525, ptr %tmp_8340_pointer_931, !noalias !2
        %tmp_8325_pointer_932 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_926, i64 0, i32 5
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_932, !noalias !2
        %i_6_12_461_1239_6395_pointer_933 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %StackPointer %stackPointer_926, i64 0, i32 6
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_933, !noalias !2
        %returnAddress_pointer_934 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_926, i64 0, i32 1, i32 0
        %sharer_pointer_935 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_926, i64 0, i32 1, i32 1
        %eraser_pointer_936 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_926, i64 0, i32 1, i32 2
        store ptr @returnAddress_461, ptr %returnAddress_pointer_934, !noalias !2
        store ptr @sharer_840, ptr %sharer_pointer_935, !noalias !2
        store ptr @eraser_856, ptr %eraser_pointer_936, !noalias !2
        
        %get_8633_pointer_937 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_938 = load i64, ptr %get_8633_pointer_937, !noalias !2
        %get_8633 = load i64, ptr %get_8633_pointer_937, !noalias !2
        
        %stackPointer_940 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_941 = getelementptr %FrameHeader, %StackPointer %stackPointer_940, i64 0, i32 0
        %returnAddress_939 = load %ReturnAddress, ptr %returnAddress_pointer_941, !noalias !2
        musttail call tailcc void %returnAddress_939(i64 %get_8633, %Stack %stack)
        ret void
}



define ccc void @sharer_948(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_949 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_942_pointer_950 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_949, i64 0, i32 0
        %tmp_8332_942 = load %Pos, ptr %tmp_8332_942_pointer_950, !noalias !2
        %tmp_8455_943_pointer_951 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_949, i64 0, i32 1
        %tmp_8455_943 = load %Pos, ptr %tmp_8455_943_pointer_951, !noalias !2
        %ballCount_3_781_6265_944_pointer_952 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_949, i64 0, i32 2
        %ballCount_3_781_6265_944 = load i64, ptr %ballCount_3_781_6265_944_pointer_952, !noalias !2
        %seed_5_5892_945_pointer_953 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_949, i64 0, i32 3
        %seed_5_5892_945 = load %Reference, ptr %seed_5_5892_945_pointer_953, !noalias !2
        %tmp_8325_946_pointer_954 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_949, i64 0, i32 4
        %tmp_8325_946 = load %Pos, ptr %tmp_8325_946_pointer_954, !noalias !2
        %i_6_12_461_1239_6395_947_pointer_955 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_949, i64 0, i32 5
        %i_6_12_461_1239_6395_947 = load i64, ptr %i_6_12_461_1239_6395_947_pointer_955, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8332_942)
        call ccc void @sharePositive(%Pos %tmp_8455_943)
        call ccc void @sharePositive(%Pos %tmp_8325_946)
        call ccc void @shareFrames(%StackPointer %stackPointer_949)
        ret void
}



define ccc void @eraser_962(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_963 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_8332_956_pointer_964 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_963, i64 0, i32 0
        %tmp_8332_956 = load %Pos, ptr %tmp_8332_956_pointer_964, !noalias !2
        %tmp_8455_957_pointer_965 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_963, i64 0, i32 1
        %tmp_8455_957 = load %Pos, ptr %tmp_8455_957_pointer_965, !noalias !2
        %ballCount_3_781_6265_958_pointer_966 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_963, i64 0, i32 2
        %ballCount_3_781_6265_958 = load i64, ptr %ballCount_3_781_6265_958_pointer_966, !noalias !2
        %seed_5_5892_959_pointer_967 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_963, i64 0, i32 3
        %seed_5_5892_959 = load %Reference, ptr %seed_5_5892_959_pointer_967, !noalias !2
        %tmp_8325_960_pointer_968 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_963, i64 0, i32 4
        %tmp_8325_960 = load %Pos, ptr %tmp_8325_960_pointer_968, !noalias !2
        %i_6_12_461_1239_6395_961_pointer_969 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_963, i64 0, i32 5
        %i_6_12_461_1239_6395_961 = load i64, ptr %i_6_12_461_1239_6395_961_pointer_969, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8332_956)
        call ccc void @erasePositive(%Pos %tmp_8455_957)
        call ccc void @erasePositive(%Pos %tmp_8325_960)
        call ccc void @eraseFrames(%StackPointer %stackPointer_963)
        ret void
}



define tailcc void @returnAddress_445(%Pos %__11_5_8486, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_446 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 80)
        %tmp_8332_pointer_447 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_446, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_447, !noalias !2
        %tmp_8455_pointer_448 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_446, i64 0, i32 1
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_448, !noalias !2
        %ballCount_3_781_6265_pointer_449 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_446, i64 0, i32 2
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_449, !noalias !2
        %seed_5_5892_pointer_450 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_446, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_450, !noalias !2
        %tmp_8325_pointer_451 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_446, i64 0, i32 4
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_451, !noalias !2
        %i_6_12_461_1239_6395_pointer_452 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_446, i64 0, i32 5
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_452, !noalias !2
        call ccc void @erasePositive(%Pos %__11_5_8486)
        %stackPointer_970 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 104)
        %tmp_8332_pointer_971 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_970, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_971, !noalias !2
        %tmp_8455_pointer_972 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_970, i64 0, i32 1
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_972, !noalias !2
        %ballCount_3_781_6265_pointer_973 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_970, i64 0, i32 2
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_973, !noalias !2
        %seed_5_5892_pointer_974 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_970, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_974, !noalias !2
        %tmp_8325_pointer_975 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_970, i64 0, i32 4
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_975, !noalias !2
        %i_6_12_461_1239_6395_pointer_976 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_970, i64 0, i32 5
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_976, !noalias !2
        %returnAddress_pointer_977 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_970, i64 0, i32 1, i32 0
        %sharer_pointer_978 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_970, i64 0, i32 1, i32 1
        %eraser_pointer_979 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_970, i64 0, i32 1, i32 2
        store ptr @returnAddress_453, ptr %returnAddress_pointer_977, !noalias !2
        store ptr @sharer_948, ptr %sharer_pointer_978, !noalias !2
        store ptr @eraser_962, ptr %eraser_pointer_979, !noalias !2
        
        %get_8634_pointer_980 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_981 = load i64, ptr %get_8634_pointer_980, !noalias !2
        %get_8634 = load i64, ptr %get_8634_pointer_980, !noalias !2
        
        %stackPointer_983 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_984 = getelementptr %FrameHeader, %StackPointer %stackPointer_983, i64 0, i32 0
        %returnAddress_982 = load %ReturnAddress, ptr %returnAddress_pointer_984, !noalias !2
        musttail call tailcc void %returnAddress_982(i64 %get_8634, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_437(i64 %v_r_3053_7_1_7286, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_438 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 80)
        %tmp_8332_pointer_439 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_438, i64 0, i32 0
        %tmp_8332 = load %Pos, ptr %tmp_8332_pointer_439, !noalias !2
        %tmp_8455_pointer_440 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_438, i64 0, i32 1
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_440, !noalias !2
        %ballCount_3_781_6265_pointer_441 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_438, i64 0, i32 2
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_441, !noalias !2
        %seed_5_5892_pointer_442 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_438, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_442, !noalias !2
        %tmp_8325_pointer_443 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_438, i64 0, i32 4
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_443, !noalias !2
        %i_6_12_461_1239_6395_pointer_444 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_438, i64 0, i32 5
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_444, !noalias !2
        
        %longLiteral_8514 = add i64 1309, 0
        
        %pureApp_8513 = call ccc i64 @infixMul_99(i64 %v_r_3053_7_1_7286, i64 %longLiteral_8514)
        
        
        
        %longLiteral_8516 = add i64 13849, 0
        
        %pureApp_8515 = call ccc i64 @infixAdd_96(i64 %pureApp_8513, i64 %longLiteral_8516)
        
        
        
        %longLiteral_8518 = add i64 65535, 0
        
        %pureApp_8517 = call ccc i64 @bitwiseAnd_234(i64 %pureApp_8515, i64 %longLiteral_8518)
        
        
        %stackPointer_997 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 104)
        %tmp_8332_pointer_998 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_997, i64 0, i32 0
        store %Pos %tmp_8332, ptr %tmp_8332_pointer_998, !noalias !2
        %tmp_8455_pointer_999 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_997, i64 0, i32 1
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_999, !noalias !2
        %ballCount_3_781_6265_pointer_1000 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_997, i64 0, i32 2
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1000, !noalias !2
        %seed_5_5892_pointer_1001 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_997, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_1001, !noalias !2
        %tmp_8325_pointer_1002 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_997, i64 0, i32 4
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_1002, !noalias !2
        %i_6_12_461_1239_6395_pointer_1003 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_997, i64 0, i32 5
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1003, !noalias !2
        %returnAddress_pointer_1004 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_997, i64 0, i32 1, i32 0
        %sharer_pointer_1005 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_997, i64 0, i32 1, i32 1
        %eraser_pointer_1006 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_997, i64 0, i32 1, i32 2
        store ptr @returnAddress_445, ptr %returnAddress_pointer_1004, !noalias !2
        store ptr @sharer_948, ptr %sharer_pointer_1005, !noalias !2
        store ptr @eraser_962, ptr %eraser_pointer_1006, !noalias !2
        
        %seed_5_5892pointer_1007 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_1008 = load i64, ptr %seed_5_5892pointer_1007, !noalias !2
        store i64 %pureApp_8517, ptr %seed_5_5892pointer_1007, !noalias !2
        
        %put_8635_temporary_1009 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8635 = insertvalue %Pos %put_8635_temporary_1009, %Object null, 1
        
        %stackPointer_1011 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1012 = getelementptr %FrameHeader, %StackPointer %stackPointer_1011, i64 0, i32 0
        %returnAddress_1010 = load %ReturnAddress, ptr %returnAddress_pointer_1012, !noalias !2
        musttail call tailcc void %returnAddress_1010(%Pos %put_8635, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_430(i64 %v_r_3018_9_8_469_1247_6492, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_431 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %tmp_8455_pointer_432 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_431, i64 0, i32 0
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_432, !noalias !2
        %ballCount_3_781_6265_pointer_433 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_431, i64 0, i32 1
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_433, !noalias !2
        %seed_5_5892_pointer_434 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_431, i64 0, i32 2
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_434, !noalias !2
        %tmp_8325_pointer_435 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_431, i64 0, i32 3
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_435, !noalias !2
        %i_6_12_461_1239_6395_pointer_436 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_431, i64 0, i32 4
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_436, !noalias !2
        
        %longLiteral_8509 = add i64 500, 0
        
        %pureApp_8508 = call ccc i64 @mod_108(i64 %v_r_3018_9_8_469_1247_6492, i64 %longLiteral_8509)
        
        
        
        %pureApp_8510 = call ccc double @toDouble_156(i64 %pureApp_8508)
        
        
        
        %pureApp_8511 = call ccc %Pos @boxDouble_321(double %pureApp_8510)
        
        
        
        %pureApp_8512 = call ccc %Pos @ref_2475(%Pos %pureApp_8511)
        
        
        %stackPointer_1025 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 104)
        %tmp_8332_pointer_1026 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1025, i64 0, i32 0
        store %Pos %pureApp_8512, ptr %tmp_8332_pointer_1026, !noalias !2
        %tmp_8455_pointer_1027 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1025, i64 0, i32 1
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1027, !noalias !2
        %ballCount_3_781_6265_pointer_1028 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1025, i64 0, i32 2
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1028, !noalias !2
        %seed_5_5892_pointer_1029 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1025, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_1029, !noalias !2
        %tmp_8325_pointer_1030 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1025, i64 0, i32 4
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_1030, !noalias !2
        %i_6_12_461_1239_6395_pointer_1031 = getelementptr <{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1025, i64 0, i32 5
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1031, !noalias !2
        %returnAddress_pointer_1032 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1025, i64 0, i32 1, i32 0
        %sharer_pointer_1033 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1025, i64 0, i32 1, i32 1
        %eraser_pointer_1034 = getelementptr <{<{%Pos, %Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1025, i64 0, i32 1, i32 2
        store ptr @returnAddress_437, ptr %returnAddress_pointer_1032, !noalias !2
        store ptr @sharer_948, ptr %sharer_pointer_1033, !noalias !2
        store ptr @eraser_962, ptr %eraser_pointer_1034, !noalias !2
        
        %get_8636_pointer_1035 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_1036 = load i64, ptr %get_8636_pointer_1035, !noalias !2
        %get_8636 = load i64, ptr %get_8636_pointer_1035, !noalias !2
        
        %stackPointer_1038 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1039 = getelementptr %FrameHeader, %StackPointer %stackPointer_1038, i64 0, i32 0
        %returnAddress_1037 = load %ReturnAddress, ptr %returnAddress_pointer_1039, !noalias !2
        musttail call tailcc void %returnAddress_1037(i64 %get_8636, %Stack %stack)
        ret void
}



define ccc void @sharer_1045(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1046 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_8455_1040_pointer_1047 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1046, i64 0, i32 0
        %tmp_8455_1040 = load %Pos, ptr %tmp_8455_1040_pointer_1047, !noalias !2
        %ballCount_3_781_6265_1041_pointer_1048 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1046, i64 0, i32 1
        %ballCount_3_781_6265_1041 = load i64, ptr %ballCount_3_781_6265_1041_pointer_1048, !noalias !2
        %seed_5_5892_1042_pointer_1049 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1046, i64 0, i32 2
        %seed_5_5892_1042 = load %Reference, ptr %seed_5_5892_1042_pointer_1049, !noalias !2
        %tmp_8325_1043_pointer_1050 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1046, i64 0, i32 3
        %tmp_8325_1043 = load %Pos, ptr %tmp_8325_1043_pointer_1050, !noalias !2
        %i_6_12_461_1239_6395_1044_pointer_1051 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1046, i64 0, i32 4
        %i_6_12_461_1239_6395_1044 = load i64, ptr %i_6_12_461_1239_6395_1044_pointer_1051, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8455_1040)
        call ccc void @sharePositive(%Pos %tmp_8325_1043)
        call ccc void @shareFrames(%StackPointer %stackPointer_1046)
        ret void
}



define ccc void @eraser_1057(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1058 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_8455_1052_pointer_1059 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1058, i64 0, i32 0
        %tmp_8455_1052 = load %Pos, ptr %tmp_8455_1052_pointer_1059, !noalias !2
        %ballCount_3_781_6265_1053_pointer_1060 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1058, i64 0, i32 1
        %ballCount_3_781_6265_1053 = load i64, ptr %ballCount_3_781_6265_1053_pointer_1060, !noalias !2
        %seed_5_5892_1054_pointer_1061 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1058, i64 0, i32 2
        %seed_5_5892_1054 = load %Reference, ptr %seed_5_5892_1054_pointer_1061, !noalias !2
        %tmp_8325_1055_pointer_1062 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1058, i64 0, i32 3
        %tmp_8325_1055 = load %Pos, ptr %tmp_8325_1055_pointer_1062, !noalias !2
        %i_6_12_461_1239_6395_1056_pointer_1063 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1058, i64 0, i32 4
        %i_6_12_461_1239_6395_1056 = load i64, ptr %i_6_12_461_1239_6395_1056_pointer_1063, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8455_1052)
        call ccc void @erasePositive(%Pos %tmp_8325_1055)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1058)
        ret void
}



define tailcc void @returnAddress_423(%Pos %__11_5_8487, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_424 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %tmp_8455_pointer_425 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_424, i64 0, i32 0
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_425, !noalias !2
        %ballCount_3_781_6265_pointer_426 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_424, i64 0, i32 1
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_426, !noalias !2
        %seed_5_5892_pointer_427 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_424, i64 0, i32 2
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_427, !noalias !2
        %tmp_8325_pointer_428 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_424, i64 0, i32 3
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_428, !noalias !2
        %i_6_12_461_1239_6395_pointer_429 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_424, i64 0, i32 4
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_429, !noalias !2
        call ccc void @erasePositive(%Pos %__11_5_8487)
        %stackPointer_1064 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %tmp_8455_pointer_1065 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1064, i64 0, i32 0
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1065, !noalias !2
        %ballCount_3_781_6265_pointer_1066 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1064, i64 0, i32 1
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1066, !noalias !2
        %seed_5_5892_pointer_1067 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1064, i64 0, i32 2
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_1067, !noalias !2
        %tmp_8325_pointer_1068 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1064, i64 0, i32 3
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_1068, !noalias !2
        %i_6_12_461_1239_6395_pointer_1069 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1064, i64 0, i32 4
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1069, !noalias !2
        %returnAddress_pointer_1070 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1064, i64 0, i32 1, i32 0
        %sharer_pointer_1071 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1064, i64 0, i32 1, i32 1
        %eraser_pointer_1072 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1064, i64 0, i32 1, i32 2
        store ptr @returnAddress_430, ptr %returnAddress_pointer_1070, !noalias !2
        store ptr @sharer_1045, ptr %sharer_pointer_1071, !noalias !2
        store ptr @eraser_1057, ptr %eraser_pointer_1072, !noalias !2
        
        %get_8637_pointer_1073 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_1074 = load i64, ptr %get_8637_pointer_1073, !noalias !2
        %get_8637 = load i64, ptr %get_8637_pointer_1073, !noalias !2
        
        %stackPointer_1076 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1077 = getelementptr %FrameHeader, %StackPointer %stackPointer_1076, i64 0, i32 0
        %returnAddress_1075 = load %ReturnAddress, ptr %returnAddress_pointer_1077, !noalias !2
        musttail call tailcc void %returnAddress_1075(i64 %get_8637, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_416(i64 %v_r_3053_7_1_7282, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_417 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %tmp_8455_pointer_418 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_417, i64 0, i32 0
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_418, !noalias !2
        %ballCount_3_781_6265_pointer_419 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_417, i64 0, i32 1
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_419, !noalias !2
        %seed_5_5892_pointer_420 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_417, i64 0, i32 2
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_420, !noalias !2
        %tmp_8325_pointer_421 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_417, i64 0, i32 3
        %tmp_8325 = load %Pos, ptr %tmp_8325_pointer_421, !noalias !2
        %i_6_12_461_1239_6395_pointer_422 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_417, i64 0, i32 4
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_422, !noalias !2
        
        %longLiteral_8503 = add i64 1309, 0
        
        %pureApp_8502 = call ccc i64 @infixMul_99(i64 %v_r_3053_7_1_7282, i64 %longLiteral_8503)
        
        
        
        %longLiteral_8505 = add i64 13849, 0
        
        %pureApp_8504 = call ccc i64 @infixAdd_96(i64 %pureApp_8502, i64 %longLiteral_8505)
        
        
        
        %longLiteral_8507 = add i64 65535, 0
        
        %pureApp_8506 = call ccc i64 @bitwiseAnd_234(i64 %pureApp_8504, i64 %longLiteral_8507)
        
        
        %stackPointer_1088 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %tmp_8455_pointer_1089 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1088, i64 0, i32 0
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1089, !noalias !2
        %ballCount_3_781_6265_pointer_1090 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1088, i64 0, i32 1
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1090, !noalias !2
        %seed_5_5892_pointer_1091 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1088, i64 0, i32 2
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_1091, !noalias !2
        %tmp_8325_pointer_1092 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1088, i64 0, i32 3
        store %Pos %tmp_8325, ptr %tmp_8325_pointer_1092, !noalias !2
        %i_6_12_461_1239_6395_pointer_1093 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1088, i64 0, i32 4
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1093, !noalias !2
        %returnAddress_pointer_1094 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1088, i64 0, i32 1, i32 0
        %sharer_pointer_1095 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1088, i64 0, i32 1, i32 1
        %eraser_pointer_1096 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1088, i64 0, i32 1, i32 2
        store ptr @returnAddress_423, ptr %returnAddress_pointer_1094, !noalias !2
        store ptr @sharer_1045, ptr %sharer_pointer_1095, !noalias !2
        store ptr @eraser_1057, ptr %eraser_pointer_1096, !noalias !2
        
        %seed_5_5892pointer_1097 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_1098 = load i64, ptr %seed_5_5892pointer_1097, !noalias !2
        store i64 %pureApp_8506, ptr %seed_5_5892pointer_1097, !noalias !2
        
        %put_8638_temporary_1099 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8638 = insertvalue %Pos %put_8638_temporary_1099, %Object null, 1
        
        %stackPointer_1101 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1102 = getelementptr %FrameHeader, %StackPointer %stackPointer_1101, i64 0, i32 0
        %returnAddress_1100 = load %ReturnAddress, ptr %returnAddress_pointer_1102, !noalias !2
        musttail call tailcc void %returnAddress_1100(%Pos %put_8638, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_410(i64 %v_r_3015_3_2_463_1241_6495, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_411 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_8455_pointer_412 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 0
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_412, !noalias !2
        %ballCount_3_781_6265_pointer_413 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 1
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_413, !noalias !2
        %i_6_12_461_1239_6395_pointer_414 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 2
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_414, !noalias !2
        %seed_5_5892_pointer_415 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_415, !noalias !2
        
        %longLiteral_8498 = add i64 500, 0
        
        %pureApp_8497 = call ccc i64 @mod_108(i64 %v_r_3015_3_2_463_1241_6495, i64 %longLiteral_8498)
        
        
        
        %pureApp_8499 = call ccc double @toDouble_156(i64 %pureApp_8497)
        
        
        
        %pureApp_8500 = call ccc %Pos @boxDouble_321(double %pureApp_8499)
        
        
        
        %pureApp_8501 = call ccc %Pos @ref_2475(%Pos %pureApp_8500)
        
        
        %stackPointer_1113 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %tmp_8455_pointer_1114 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1113, i64 0, i32 0
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1114, !noalias !2
        %ballCount_3_781_6265_pointer_1115 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1113, i64 0, i32 1
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1115, !noalias !2
        %seed_5_5892_pointer_1116 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1113, i64 0, i32 2
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_1116, !noalias !2
        %tmp_8325_pointer_1117 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1113, i64 0, i32 3
        store %Pos %pureApp_8501, ptr %tmp_8325_pointer_1117, !noalias !2
        %i_6_12_461_1239_6395_pointer_1118 = getelementptr <{%Pos, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1113, i64 0, i32 4
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1118, !noalias !2
        %returnAddress_pointer_1119 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1113, i64 0, i32 1, i32 0
        %sharer_pointer_1120 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1113, i64 0, i32 1, i32 1
        %eraser_pointer_1121 = getelementptr <{<{%Pos, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1113, i64 0, i32 1, i32 2
        store ptr @returnAddress_416, ptr %returnAddress_pointer_1119, !noalias !2
        store ptr @sharer_1045, ptr %sharer_pointer_1120, !noalias !2
        store ptr @eraser_1057, ptr %eraser_pointer_1121, !noalias !2
        
        %get_8639_pointer_1122 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_1123 = load i64, ptr %get_8639_pointer_1122, !noalias !2
        %get_8639 = load i64, ptr %get_8639_pointer_1122, !noalias !2
        
        %stackPointer_1125 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1126 = getelementptr %FrameHeader, %StackPointer %stackPointer_1125, i64 0, i32 0
        %returnAddress_1124 = load %ReturnAddress, ptr %returnAddress_pointer_1126, !noalias !2
        musttail call tailcc void %returnAddress_1124(i64 %get_8639, %Stack %stack)
        ret void
}



define ccc void @sharer_1131(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1132 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_8455_1127_pointer_1133 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1132, i64 0, i32 0
        %tmp_8455_1127 = load %Pos, ptr %tmp_8455_1127_pointer_1133, !noalias !2
        %ballCount_3_781_6265_1128_pointer_1134 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1132, i64 0, i32 1
        %ballCount_3_781_6265_1128 = load i64, ptr %ballCount_3_781_6265_1128_pointer_1134, !noalias !2
        %i_6_12_461_1239_6395_1129_pointer_1135 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1132, i64 0, i32 2
        %i_6_12_461_1239_6395_1129 = load i64, ptr %i_6_12_461_1239_6395_1129_pointer_1135, !noalias !2
        %seed_5_5892_1130_pointer_1136 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1132, i64 0, i32 3
        %seed_5_5892_1130 = load %Reference, ptr %seed_5_5892_1130_pointer_1136, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8455_1127)
        call ccc void @shareFrames(%StackPointer %stackPointer_1132)
        ret void
}



define ccc void @eraser_1141(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1142 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_8455_1137_pointer_1143 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1142, i64 0, i32 0
        %tmp_8455_1137 = load %Pos, ptr %tmp_8455_1137_pointer_1143, !noalias !2
        %ballCount_3_781_6265_1138_pointer_1144 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1142, i64 0, i32 1
        %ballCount_3_781_6265_1138 = load i64, ptr %ballCount_3_781_6265_1138_pointer_1144, !noalias !2
        %i_6_12_461_1239_6395_1139_pointer_1145 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1142, i64 0, i32 2
        %i_6_12_461_1239_6395_1139 = load i64, ptr %i_6_12_461_1239_6395_1139_pointer_1145, !noalias !2
        %seed_5_5892_1140_pointer_1146 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1142, i64 0, i32 3
        %seed_5_5892_1140 = load %Reference, ptr %seed_5_5892_1140_pointer_1146, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8455_1137)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1142)
        ret void
}



define tailcc void @returnAddress_404(%Pos %__11_5_8488, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_405 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_8455_pointer_406 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_405, i64 0, i32 0
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_406, !noalias !2
        %ballCount_3_781_6265_pointer_407 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_405, i64 0, i32 1
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_407, !noalias !2
        %i_6_12_461_1239_6395_pointer_408 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_405, i64 0, i32 2
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_408, !noalias !2
        %seed_5_5892_pointer_409 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_405, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_409, !noalias !2
        call ccc void @erasePositive(%Pos %__11_5_8488)
        %stackPointer_1147 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_8455_pointer_1148 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1147, i64 0, i32 0
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1148, !noalias !2
        %ballCount_3_781_6265_pointer_1149 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1147, i64 0, i32 1
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1149, !noalias !2
        %i_6_12_461_1239_6395_pointer_1150 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1147, i64 0, i32 2
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1150, !noalias !2
        %seed_5_5892_pointer_1151 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1147, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_1151, !noalias !2
        %returnAddress_pointer_1152 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1147, i64 0, i32 1, i32 0
        %sharer_pointer_1153 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1147, i64 0, i32 1, i32 1
        %eraser_pointer_1154 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1147, i64 0, i32 1, i32 2
        store ptr @returnAddress_410, ptr %returnAddress_pointer_1152, !noalias !2
        store ptr @sharer_1131, ptr %sharer_pointer_1153, !noalias !2
        store ptr @eraser_1141, ptr %eraser_pointer_1154, !noalias !2
        
        %get_8640_pointer_1155 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_1156 = load i64, ptr %get_8640_pointer_1155, !noalias !2
        %get_8640 = load i64, ptr %get_8640_pointer_1155, !noalias !2
        
        %stackPointer_1158 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1159 = getelementptr %FrameHeader, %StackPointer %stackPointer_1158, i64 0, i32 0
        %returnAddress_1157 = load %ReturnAddress, ptr %returnAddress_pointer_1159, !noalias !2
        musttail call tailcc void %returnAddress_1157(i64 %get_8640, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_398(i64 %v_r_3053_7_1_7278, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_399 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_8455_pointer_400 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_399, i64 0, i32 0
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_400, !noalias !2
        %ballCount_3_781_6265_pointer_401 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_399, i64 0, i32 1
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_401, !noalias !2
        %i_6_12_461_1239_6395_pointer_402 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_399, i64 0, i32 2
        %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_402, !noalias !2
        %seed_5_5892_pointer_403 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_399, i64 0, i32 3
        %seed_5_5892 = load %Reference, ptr %seed_5_5892_pointer_403, !noalias !2
        
        %longLiteral_8492 = add i64 1309, 0
        
        %pureApp_8491 = call ccc i64 @infixMul_99(i64 %v_r_3053_7_1_7278, i64 %longLiteral_8492)
        
        
        
        %longLiteral_8494 = add i64 13849, 0
        
        %pureApp_8493 = call ccc i64 @infixAdd_96(i64 %pureApp_8491, i64 %longLiteral_8494)
        
        
        
        %longLiteral_8496 = add i64 65535, 0
        
        %pureApp_8495 = call ccc i64 @bitwiseAnd_234(i64 %pureApp_8493, i64 %longLiteral_8496)
        
        
        %stackPointer_1168 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_8455_pointer_1169 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1168, i64 0, i32 0
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1169, !noalias !2
        %ballCount_3_781_6265_pointer_1170 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1168, i64 0, i32 1
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1170, !noalias !2
        %i_6_12_461_1239_6395_pointer_1171 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1168, i64 0, i32 2
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1171, !noalias !2
        %seed_5_5892_pointer_1172 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1168, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_1172, !noalias !2
        %returnAddress_pointer_1173 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1168, i64 0, i32 1, i32 0
        %sharer_pointer_1174 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1168, i64 0, i32 1, i32 1
        %eraser_pointer_1175 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1168, i64 0, i32 1, i32 2
        store ptr @returnAddress_404, ptr %returnAddress_pointer_1173, !noalias !2
        store ptr @sharer_1131, ptr %sharer_pointer_1174, !noalias !2
        store ptr @eraser_1141, ptr %eraser_pointer_1175, !noalias !2
        
        %seed_5_5892pointer_1176 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_1177 = load i64, ptr %seed_5_5892pointer_1176, !noalias !2
        store i64 %pureApp_8495, ptr %seed_5_5892pointer_1176, !noalias !2
        
        %put_8641_temporary_1178 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8641 = insertvalue %Pos %put_8641_temporary_1178, %Object null, 1
        
        %stackPointer_1180 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1181 = getelementptr %FrameHeader, %StackPointer %stackPointer_1180, i64 0, i32 0
        %returnAddress_1179 = load %ReturnAddress, ptr %returnAddress_pointer_1181, !noalias !2
        musttail call tailcc void %returnAddress_1179(%Pos %put_8641, %Stack %stack)
        ret void
}



define tailcc void @loop_5_11_460_1238_6021(i64 %i_6_12_461_1239_6395, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Reference %seed_5_5892, %Stack %stack) {
        
    entry:
        
        
        %pureApp_8489 = call ccc %Pos @infixLt_178(i64 %i_6_12_461_1239_6395, i64 %ballCount_3_781_6265)
        
        
        
        %tag_390 = extractvalue %Pos %pureApp_8489, 0
        %fields_391 = extractvalue %Pos %pureApp_8489, 1
        switch i64 %tag_390, label %label_392 [i64 0, label %label_397 i64 1, label %label_1203]
    
    label_392:
        
        ret void
    
    label_397:
        call ccc void @erasePositive(%Pos %tmp_8455)
        
        %unitLiteral_8490_temporary_393 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8490 = insertvalue %Pos %unitLiteral_8490_temporary_393, %Object null, 1
        
        %stackPointer_395 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_396 = getelementptr %FrameHeader, %StackPointer %stackPointer_395, i64 0, i32 0
        %returnAddress_394 = load %ReturnAddress, ptr %returnAddress_pointer_396, !noalias !2
        musttail call tailcc void %returnAddress_394(%Pos %unitLiteral_8490, %Stack %stack)
        ret void
    
    label_1203:
        %stackPointer_1190 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_8455_pointer_1191 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1190, i64 0, i32 0
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1191, !noalias !2
        %ballCount_3_781_6265_pointer_1192 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1190, i64 0, i32 1
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1192, !noalias !2
        %i_6_12_461_1239_6395_pointer_1193 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1190, i64 0, i32 2
        store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1193, !noalias !2
        %seed_5_5892_pointer_1194 = getelementptr <{%Pos, i64, i64, %Reference}>, %StackPointer %stackPointer_1190, i64 0, i32 3
        store %Reference %seed_5_5892, ptr %seed_5_5892_pointer_1194, !noalias !2
        %returnAddress_pointer_1195 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1190, i64 0, i32 1, i32 0
        %sharer_pointer_1196 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1190, i64 0, i32 1, i32 1
        %eraser_pointer_1197 = getelementptr <{<{%Pos, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1190, i64 0, i32 1, i32 2
        store ptr @returnAddress_398, ptr %returnAddress_pointer_1195, !noalias !2
        store ptr @sharer_1131, ptr %sharer_pointer_1196, !noalias !2
        store ptr @eraser_1141, ptr %eraser_pointer_1197, !noalias !2
        
        %get_8642_pointer_1198 = call ccc ptr @getVarPointer(%Reference %seed_5_5892, %Stack %stack)
        %seed_5_5892_old_1199 = load i64, ptr %get_8642_pointer_1198, !noalias !2
        %get_8642 = load i64, ptr %get_8642_pointer_1198, !noalias !2
        
        %stackPointer_1201 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1202 = getelementptr %FrameHeader, %StackPointer %stackPointer_1201, i64 0, i32 0
        %returnAddress_1200 = load %ReturnAddress, ptr %returnAddress_pointer_1202, !noalias !2
        musttail call tailcc void %returnAddress_1200(i64 %get_8642, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1232(%Pos %__8_19_773_1551_8644, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1233 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %bounces_5_783_6504_pointer_1234 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1233, i64 0, i32 0
        %bounces_5_783_6504 = load %Reference, ptr %bounces_5_783_6504_pointer_1234, !noalias !2
        %tmp_8455_pointer_1235 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1233, i64 0, i32 1
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_1235, !noalias !2
        %ballCount_3_781_6265_pointer_1236 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1233, i64 0, i32 2
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_1236, !noalias !2
        %i_6_11_765_1543_6618_pointer_1237 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1233, i64 0, i32 3
        %i_6_11_765_1543_6618 = load i64, ptr %i_6_11_765_1543_6618_pointer_1237, !noalias !2
        call ccc void @erasePositive(%Pos %__8_19_773_1551_8644)
        
        %longLiteral_8652 = add i64 1, 0
        
        %pureApp_8651 = call ccc i64 @infixAdd_96(i64 %i_6_11_765_1543_6618, i64 %longLiteral_8652)
        
        
        
        
        
        musttail call tailcc void @loop_5_10_764_1542_6061(i64 %pureApp_8651, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Stack %stack)
        ret void
}



define ccc void @sharer_1242(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1243 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %bounces_5_783_6504_1238_pointer_1244 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1243, i64 0, i32 0
        %bounces_5_783_6504_1238 = load %Reference, ptr %bounces_5_783_6504_1238_pointer_1244, !noalias !2
        %tmp_8455_1239_pointer_1245 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1243, i64 0, i32 1
        %tmp_8455_1239 = load %Pos, ptr %tmp_8455_1239_pointer_1245, !noalias !2
        %ballCount_3_781_6265_1240_pointer_1246 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1243, i64 0, i32 2
        %ballCount_3_781_6265_1240 = load i64, ptr %ballCount_3_781_6265_1240_pointer_1246, !noalias !2
        %i_6_11_765_1543_6618_1241_pointer_1247 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1243, i64 0, i32 3
        %i_6_11_765_1543_6618_1241 = load i64, ptr %i_6_11_765_1543_6618_1241_pointer_1247, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8455_1239)
        call ccc void @shareFrames(%StackPointer %stackPointer_1243)
        ret void
}



define ccc void @eraser_1252(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1253 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %bounces_5_783_6504_1248_pointer_1254 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1253, i64 0, i32 0
        %bounces_5_783_6504_1248 = load %Reference, ptr %bounces_5_783_6504_1248_pointer_1254, !noalias !2
        %tmp_8455_1249_pointer_1255 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1253, i64 0, i32 1
        %tmp_8455_1249 = load %Pos, ptr %tmp_8455_1249_pointer_1255, !noalias !2
        %ballCount_3_781_6265_1250_pointer_1256 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1253, i64 0, i32 2
        %ballCount_3_781_6265_1250 = load i64, ptr %ballCount_3_781_6265_1250_pointer_1256, !noalias !2
        %i_6_11_765_1543_6618_1251_pointer_1257 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1253, i64 0, i32 3
        %i_6_11_765_1543_6618_1251 = load i64, ptr %i_6_11_765_1543_6618_1251_pointer_1257, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8455_1249)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1253)
        ret void
}



define tailcc void @returnAddress_1274(i64 %v_r_3062_6_17_771_1549_6222, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1275 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %bounces_5_783_6504_pointer_1276 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1275, i64 0, i32 0
        %bounces_5_783_6504 = load %Reference, ptr %bounces_5_783_6504_pointer_1276, !noalias !2
        
        %longLiteral_8655 = add i64 1, 0
        
        %pureApp_8654 = call ccc i64 @infixAdd_96(i64 %v_r_3062_6_17_771_1549_6222, i64 %longLiteral_8655)
        
        
        
        %bounces_5_783_6504pointer_1277 = call ccc ptr @getVarPointer(%Reference %bounces_5_783_6504, %Stack %stack)
        %bounces_5_783_6504_old_1278 = load i64, ptr %bounces_5_783_6504pointer_1277, !noalias !2
        store i64 %pureApp_8654, ptr %bounces_5_783_6504pointer_1277, !noalias !2
        
        %put_8656_temporary_1279 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_8656 = insertvalue %Pos %put_8656_temporary_1279, %Object null, 1
        
        %stackPointer_1281 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1282 = getelementptr %FrameHeader, %StackPointer %stackPointer_1281, i64 0, i32 0
        %returnAddress_1280 = load %ReturnAddress, ptr %returnAddress_pointer_1282, !noalias !2
        musttail call tailcc void %returnAddress_1280(%Pos %put_8656, %Stack %stack)
        ret void
}



define ccc void @sharer_1284(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1285 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %bounces_5_783_6504_1283_pointer_1286 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1285, i64 0, i32 0
        %bounces_5_783_6504_1283 = load %Reference, ptr %bounces_5_783_6504_1283_pointer_1286, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1285)
        ret void
}



define ccc void @eraser_1288(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1289 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %bounces_5_783_6504_1287_pointer_1290 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1289, i64 0, i32 0
        %bounces_5_783_6504_1287 = load %Reference, ptr %bounces_5_783_6504_1287_pointer_1290, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1289)
        ret void
}



define tailcc void @returnAddress_1226(%Pos %didBounce_5_16_770_1548_6602, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1227 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %bounces_5_783_6504_pointer_1228 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1227, i64 0, i32 0
        %bounces_5_783_6504 = load %Reference, ptr %bounces_5_783_6504_pointer_1228, !noalias !2
        %tmp_8455_pointer_1229 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1227, i64 0, i32 1
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_1229, !noalias !2
        %ballCount_3_781_6265_pointer_1230 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1227, i64 0, i32 2
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_1230, !noalias !2
        %i_6_11_765_1543_6618_pointer_1231 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1227, i64 0, i32 3
        %i_6_11_765_1543_6618 = load i64, ptr %i_6_11_765_1543_6618_pointer_1231, !noalias !2
        %stackPointer_1258 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %bounces_5_783_6504_pointer_1259 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1258, i64 0, i32 0
        store %Reference %bounces_5_783_6504, ptr %bounces_5_783_6504_pointer_1259, !noalias !2
        %tmp_8455_pointer_1260 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1258, i64 0, i32 1
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1260, !noalias !2
        %ballCount_3_781_6265_pointer_1261 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1258, i64 0, i32 2
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1261, !noalias !2
        %i_6_11_765_1543_6618_pointer_1262 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1258, i64 0, i32 3
        store i64 %i_6_11_765_1543_6618, ptr %i_6_11_765_1543_6618_pointer_1262, !noalias !2
        %returnAddress_pointer_1263 = getelementptr <{<{%Reference, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1258, i64 0, i32 1, i32 0
        %sharer_pointer_1264 = getelementptr <{<{%Reference, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1258, i64 0, i32 1, i32 1
        %eraser_pointer_1265 = getelementptr <{<{%Reference, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1258, i64 0, i32 1, i32 2
        store ptr @returnAddress_1232, ptr %returnAddress_pointer_1263, !noalias !2
        store ptr @sharer_1242, ptr %sharer_pointer_1264, !noalias !2
        store ptr @eraser_1252, ptr %eraser_pointer_1265, !noalias !2
        
        %tag_1266 = extractvalue %Pos %didBounce_5_16_770_1548_6602, 0
        %fields_1267 = extractvalue %Pos %didBounce_5_16_770_1548_6602, 1
        switch i64 %tag_1266, label %label_1268 [i64 0, label %label_1273 i64 1, label %label_1301]
    
    label_1268:
        
        ret void
    
    label_1273:
        
        %unitLiteral_8653_temporary_1269 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8653 = insertvalue %Pos %unitLiteral_8653_temporary_1269, %Object null, 1
        
        %stackPointer_1271 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1272 = getelementptr %FrameHeader, %StackPointer %stackPointer_1271, i64 0, i32 0
        %returnAddress_1270 = load %ReturnAddress, ptr %returnAddress_pointer_1272, !noalias !2
        musttail call tailcc void %returnAddress_1270(%Pos %unitLiteral_8653, %Stack %stack)
        ret void
    
    label_1301:
        %stackPointer_1291 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %bounces_5_783_6504_pointer_1292 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1291, i64 0, i32 0
        store %Reference %bounces_5_783_6504, ptr %bounces_5_783_6504_pointer_1292, !noalias !2
        %returnAddress_pointer_1293 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1291, i64 0, i32 1, i32 0
        %sharer_pointer_1294 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1291, i64 0, i32 1, i32 1
        %eraser_pointer_1295 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1291, i64 0, i32 1, i32 2
        store ptr @returnAddress_1274, ptr %returnAddress_pointer_1293, !noalias !2
        store ptr @sharer_1284, ptr %sharer_pointer_1294, !noalias !2
        store ptr @eraser_1288, ptr %eraser_pointer_1295, !noalias !2
        
        %get_8657_pointer_1296 = call ccc ptr @getVarPointer(%Reference %bounces_5_783_6504, %Stack %stack)
        %bounces_5_783_6504_old_1297 = load i64, ptr %get_8657_pointer_1296, !noalias !2
        %get_8657 = load i64, ptr %get_8657_pointer_1296, !noalias !2
        
        %stackPointer_1299 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1300 = getelementptr %FrameHeader, %StackPointer %stackPointer_1299, i64 0, i32 0
        %returnAddress_1298 = load %ReturnAddress, ptr %returnAddress_pointer_1300, !noalias !2
        musttail call tailcc void %returnAddress_1298(i64 %get_8657, %Stack %stack)
        ret void
}



define tailcc void @loop_5_10_764_1542_6061(i64 %i_6_11_765_1543_6618, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Stack %stack) {
        
    entry:
        
        
        %pureApp_8648 = call ccc %Pos @infixLt_178(i64 %i_6_11_765_1543_6618, i64 %ballCount_3_781_6265)
        
        
        
        %tag_1218 = extractvalue %Pos %pureApp_8648, 0
        %fields_1219 = extractvalue %Pos %pureApp_8648, 1
        switch i64 %tag_1218, label %label_1220 [i64 0, label %label_1225 i64 1, label %label_1322]
    
    label_1220:
        
        ret void
    
    label_1225:
        call ccc void @erasePositive(%Pos %tmp_8455)
        
        %unitLiteral_8649_temporary_1221 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8649 = insertvalue %Pos %unitLiteral_8649_temporary_1221, %Object null, 1
        
        %stackPointer_1223 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1224 = getelementptr %FrameHeader, %StackPointer %stackPointer_1223, i64 0, i32 0
        %returnAddress_1222 = load %ReturnAddress, ptr %returnAddress_pointer_1224, !noalias !2
        musttail call tailcc void %returnAddress_1222(%Pos %unitLiteral_8649, %Stack %stack)
        ret void
    
    label_1322:
        
        call ccc void @sharePositive(%Pos %tmp_8455)
        %pureApp_8650 = call ccc %Pos @unsafeGet_2501(%Pos %tmp_8455, i64 %i_6_11_765_1543_6618)
        
        
        
        %tmp_8415 = call ccc %Neg @unbox(%Pos %pureApp_8650)
        %stackPointer_1310 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %bounces_5_783_6504_pointer_1311 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1310, i64 0, i32 0
        store %Reference %bounces_5_783_6504, ptr %bounces_5_783_6504_pointer_1311, !noalias !2
        %tmp_8455_pointer_1312 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1310, i64 0, i32 1
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1312, !noalias !2
        %ballCount_3_781_6265_pointer_1313 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1310, i64 0, i32 2
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1313, !noalias !2
        %i_6_11_765_1543_6618_pointer_1314 = getelementptr <{%Reference, %Pos, i64, i64}>, %StackPointer %stackPointer_1310, i64 0, i32 3
        store i64 %i_6_11_765_1543_6618, ptr %i_6_11_765_1543_6618_pointer_1314, !noalias !2
        %returnAddress_pointer_1315 = getelementptr <{<{%Reference, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1310, i64 0, i32 1, i32 0
        %sharer_pointer_1316 = getelementptr <{<{%Reference, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1310, i64 0, i32 1, i32 1
        %eraser_pointer_1317 = getelementptr <{<{%Reference, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1310, i64 0, i32 1, i32 2
        store ptr @returnAddress_1226, ptr %returnAddress_pointer_1315, !noalias !2
        store ptr @sharer_1242, ptr %sharer_pointer_1316, !noalias !2
        store ptr @eraser_1252, ptr %eraser_pointer_1317, !noalias !2
        
        %vtable_1318 = extractvalue %Neg %tmp_8415, 0
        %closure_1319 = extractvalue %Neg %tmp_8415, 1
        %functionPointer_pointer_1320 = getelementptr ptr, ptr %vtable_1318, i64 0
        %functionPointer_1321 = load ptr, ptr %functionPointer_pointer_1320, !noalias !2
        musttail call tailcc void %functionPointer_1321(%Object %closure_1319, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1323(%Pos %__8_775_1553_8645, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1324 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %i_6_754_1532_6113_pointer_1325 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1324, i64 0, i32 0
        %i_6_754_1532_6113 = load i64, ptr %i_6_754_1532_6113_pointer_1325, !noalias !2
        %n_2873_pointer_1326 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1324, i64 0, i32 1
        %n_2873 = load i64, ptr %n_2873_pointer_1326, !noalias !2
        %bounces_5_783_6504_pointer_1327 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1324, i64 0, i32 2
        %bounces_5_783_6504 = load %Reference, ptr %bounces_5_783_6504_pointer_1327, !noalias !2
        %tmp_8455_pointer_1328 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1324, i64 0, i32 3
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_1328, !noalias !2
        %ballCount_3_781_6265_pointer_1329 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1324, i64 0, i32 4
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_1329, !noalias !2
        call ccc void @erasePositive(%Pos %__8_775_1553_8645)
        
        %longLiteral_8659 = add i64 1, 0
        
        %pureApp_8658 = call ccc i64 @infixAdd_96(i64 %i_6_754_1532_6113, i64 %longLiteral_8659)
        
        
        
        
        
        musttail call tailcc void @loop_5_753_1531_6134(i64 %pureApp_8658, i64 %n_2873, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Stack %stack)
        ret void
}



define ccc void @sharer_1335(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1336 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_754_1532_6113_1330_pointer_1337 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 0
        %i_6_754_1532_6113_1330 = load i64, ptr %i_6_754_1532_6113_1330_pointer_1337, !noalias !2
        %n_2873_1331_pointer_1338 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 1
        %n_2873_1331 = load i64, ptr %n_2873_1331_pointer_1338, !noalias !2
        %bounces_5_783_6504_1332_pointer_1339 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 2
        %bounces_5_783_6504_1332 = load %Reference, ptr %bounces_5_783_6504_1332_pointer_1339, !noalias !2
        %tmp_8455_1333_pointer_1340 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 3
        %tmp_8455_1333 = load %Pos, ptr %tmp_8455_1333_pointer_1340, !noalias !2
        %ballCount_3_781_6265_1334_pointer_1341 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 4
        %ballCount_3_781_6265_1334 = load i64, ptr %ballCount_3_781_6265_1334_pointer_1341, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8455_1333)
        call ccc void @shareFrames(%StackPointer %stackPointer_1336)
        ret void
}



define ccc void @eraser_1347(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1348 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_754_1532_6113_1342_pointer_1349 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1348, i64 0, i32 0
        %i_6_754_1532_6113_1342 = load i64, ptr %i_6_754_1532_6113_1342_pointer_1349, !noalias !2
        %n_2873_1343_pointer_1350 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1348, i64 0, i32 1
        %n_2873_1343 = load i64, ptr %n_2873_1343_pointer_1350, !noalias !2
        %bounces_5_783_6504_1344_pointer_1351 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1348, i64 0, i32 2
        %bounces_5_783_6504_1344 = load %Reference, ptr %bounces_5_783_6504_1344_pointer_1351, !noalias !2
        %tmp_8455_1345_pointer_1352 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1348, i64 0, i32 3
        %tmp_8455_1345 = load %Pos, ptr %tmp_8455_1345_pointer_1352, !noalias !2
        %ballCount_3_781_6265_1346_pointer_1353 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1348, i64 0, i32 4
        %ballCount_3_781_6265_1346 = load i64, ptr %ballCount_3_781_6265_1346_pointer_1353, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8455_1345)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1348)
        ret void
}



define tailcc void @loop_5_753_1531_6134(i64 %i_6_754_1532_6113, i64 %n_2873, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Stack %stack) {
        
    entry:
        
        
        %pureApp_8646 = call ccc %Pos @infixLt_178(i64 %i_6_754_1532_6113, i64 %n_2873)
        
        
        
        %tag_1210 = extractvalue %Pos %pureApp_8646, 0
        %fields_1211 = extractvalue %Pos %pureApp_8646, 1
        switch i64 %tag_1210, label %label_1212 [i64 0, label %label_1217 i64 1, label %label_1363]
    
    label_1212:
        
        ret void
    
    label_1217:
        call ccc void @erasePositive(%Pos %tmp_8455)
        
        %unitLiteral_8647_temporary_1213 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_8647 = insertvalue %Pos %unitLiteral_8647_temporary_1213, %Object null, 1
        
        %stackPointer_1215 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1216 = getelementptr %FrameHeader, %StackPointer %stackPointer_1215, i64 0, i32 0
        %returnAddress_1214 = load %ReturnAddress, ptr %returnAddress_pointer_1216, !noalias !2
        musttail call tailcc void %returnAddress_1214(%Pos %unitLiteral_8647, %Stack %stack)
        ret void
    
    label_1363:
        call ccc void @sharePositive(%Pos %tmp_8455)
        %stackPointer_1354 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %i_6_754_1532_6113_pointer_1355 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1354, i64 0, i32 0
        store i64 %i_6_754_1532_6113, ptr %i_6_754_1532_6113_pointer_1355, !noalias !2
        %n_2873_pointer_1356 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1354, i64 0, i32 1
        store i64 %n_2873, ptr %n_2873_pointer_1356, !noalias !2
        %bounces_5_783_6504_pointer_1357 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1354, i64 0, i32 2
        store %Reference %bounces_5_783_6504, ptr %bounces_5_783_6504_pointer_1357, !noalias !2
        %tmp_8455_pointer_1358 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1354, i64 0, i32 3
        store %Pos %tmp_8455, ptr %tmp_8455_pointer_1358, !noalias !2
        %ballCount_3_781_6265_pointer_1359 = getelementptr <{i64, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1354, i64 0, i32 4
        store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1359, !noalias !2
        %returnAddress_pointer_1360 = getelementptr <{<{i64, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1354, i64 0, i32 1, i32 0
        %sharer_pointer_1361 = getelementptr <{<{i64, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1354, i64 0, i32 1, i32 1
        %eraser_pointer_1362 = getelementptr <{<{i64, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1354, i64 0, i32 1, i32 2
        store ptr @returnAddress_1323, ptr %returnAddress_pointer_1360, !noalias !2
        store ptr @sharer_1335, ptr %sharer_pointer_1361, !noalias !2
        store ptr @eraser_1347, ptr %eraser_pointer_1362, !noalias !2
        
        %longLiteral_8660 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_10_764_1542_6061(i64 %longLiteral_8660, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1364(%Pos %__777_1555_8661, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1365 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %bounces_5_783_6504_pointer_1366 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1365, i64 0, i32 0
        %bounces_5_783_6504 = load %Reference, ptr %bounces_5_783_6504_pointer_1366, !noalias !2
        call ccc void @erasePositive(%Pos %__777_1555_8661)
        
        %get_8662_pointer_1367 = call ccc ptr @getVarPointer(%Reference %bounces_5_783_6504, %Stack %stack)
        %bounces_5_783_6504_old_1368 = load i64, ptr %get_8662_pointer_1367, !noalias !2
        %get_8662 = load i64, ptr %get_8662_pointer_1367, !noalias !2
        
        %stackPointer_1370 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1371 = getelementptr %FrameHeader, %StackPointer %stackPointer_1370, i64 0, i32 0
        %returnAddress_1369 = load %ReturnAddress, ptr %returnAddress_pointer_1371, !noalias !2
        musttail call tailcc void %returnAddress_1369(i64 %get_8662, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1204(%Pos %__18_729_1507_8643, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1205 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %bounces_5_783_6504_pointer_1206 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1205, i64 0, i32 0
        %bounces_5_783_6504 = load %Reference, ptr %bounces_5_783_6504_pointer_1206, !noalias !2
        %n_2873_pointer_1207 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1205, i64 0, i32 1
        %n_2873 = load i64, ptr %n_2873_pointer_1207, !noalias !2
        %tmp_8455_pointer_1208 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1205, i64 0, i32 2
        %tmp_8455 = load %Pos, ptr %tmp_8455_pointer_1208, !noalias !2
        %ballCount_3_781_6265_pointer_1209 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1205, i64 0, i32 3
        %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_1209, !noalias !2
        call ccc void @erasePositive(%Pos %__18_729_1507_8643)
        %stackPointer_1374 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %bounces_5_783_6504_pointer_1375 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1374, i64 0, i32 0
        store %Reference %bounces_5_783_6504, ptr %bounces_5_783_6504_pointer_1375, !noalias !2
        %returnAddress_pointer_1376 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1374, i64 0, i32 1, i32 0
        %sharer_pointer_1377 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1374, i64 0, i32 1, i32 1
        %eraser_pointer_1378 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1374, i64 0, i32 1, i32 2
        store ptr @returnAddress_1364, ptr %returnAddress_pointer_1376, !noalias !2
        store ptr @sharer_1284, ptr %sharer_pointer_1377, !noalias !2
        store ptr @eraser_1288, ptr %eraser_pointer_1378, !noalias !2
        
        %longLiteral_8663 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_753_1531_6134(i64 %longLiteral_8663, i64 %n_2873, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Stack %stack)
        ret void
}



define ccc void @sharer_1383(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1384 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %bounces_5_783_6504_1379_pointer_1385 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1384, i64 0, i32 0
        %bounces_5_783_6504_1379 = load %Reference, ptr %bounces_5_783_6504_1379_pointer_1385, !noalias !2
        %n_2873_1380_pointer_1386 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1384, i64 0, i32 1
        %n_2873_1380 = load i64, ptr %n_2873_1380_pointer_1386, !noalias !2
        %tmp_8455_1381_pointer_1387 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1384, i64 0, i32 2
        %tmp_8455_1381 = load %Pos, ptr %tmp_8455_1381_pointer_1387, !noalias !2
        %ballCount_3_781_6265_1382_pointer_1388 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1384, i64 0, i32 3
        %ballCount_3_781_6265_1382 = load i64, ptr %ballCount_3_781_6265_1382_pointer_1388, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_8455_1381)
        call ccc void @shareFrames(%StackPointer %stackPointer_1384)
        ret void
}



define ccc void @eraser_1393(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1394 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %bounces_5_783_6504_1389_pointer_1395 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1394, i64 0, i32 0
        %bounces_5_783_6504_1389 = load %Reference, ptr %bounces_5_783_6504_1389_pointer_1395, !noalias !2
        %n_2873_1390_pointer_1396 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1394, i64 0, i32 1
        %n_2873_1390 = load i64, ptr %n_2873_1390_pointer_1396, !noalias !2
        %tmp_8455_1391_pointer_1397 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1394, i64 0, i32 2
        %tmp_8455_1391 = load %Pos, ptr %tmp_8455_1391_pointer_1397, !noalias !2
        %ballCount_3_781_6265_1392_pointer_1398 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1394, i64 0, i32 3
        %ballCount_3_781_6265_1392 = load i64, ptr %ballCount_3_781_6265_1392_pointer_1398, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_8455_1391)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1394)
        ret void
}



define tailcc void @run_2874(i64 %n_2873, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_8473 = add i64 74755, 0
        
        
        %stackPointer_344 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_345 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_344, i64 0, i32 1, i32 0
        %sharer_pointer_346 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_344, i64 0, i32 1, i32 1
        %eraser_pointer_347 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_344, i64 0, i32 1, i32 2
        store ptr @returnAddress_340, ptr %returnAddress_pointer_345, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_346, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_347, !noalias !2
        %seed_5_5892 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_363 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_3052_4_5894_pointer_364 = getelementptr <{i64}>, %StackPointer %stackPointer_363, i64 0, i32 0
        store i64 %longLiteral_8473, ptr %v_r_3052_4_5894_pointer_364, !noalias !2
        %returnAddress_pointer_365 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_363, i64 0, i32 1, i32 0
        %sharer_pointer_366 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_363, i64 0, i32 1, i32 1
        %eraser_pointer_367 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_363, i64 0, i32 1, i32 2
        store ptr @returnAddress_348, ptr %returnAddress_pointer_365, !noalias !2
        store ptr @sharer_356, ptr %sharer_pointer_366, !noalias !2
        store ptr @eraser_360, ptr %eraser_pointer_367, !noalias !2
        
        %longLiteral_8476 = add i64 100, 0
        
        
        
        %longLiteral_8477 = add i64 0, 0
        
        
        %stackPointer_372 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_373 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_372, i64 0, i32 1, i32 0
        %sharer_pointer_374 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_372, i64 0, i32 1, i32 1
        %eraser_pointer_375 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_372, i64 0, i32 1, i32 2
        store ptr @returnAddress_368, ptr %returnAddress_pointer_373, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_374, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_375, !noalias !2
        %bounces_5_783_6504 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_385 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_3057_4_782_6129_pointer_386 = getelementptr <{i64}>, %StackPointer %stackPointer_385, i64 0, i32 0
        store i64 %longLiteral_8477, ptr %v_r_3057_4_782_6129_pointer_386, !noalias !2
        %returnAddress_pointer_387 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 0
        %sharer_pointer_388 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 1
        %eraser_pointer_389 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 2
        store ptr @returnAddress_376, ptr %returnAddress_pointer_387, !noalias !2
        store ptr @sharer_356, ptr %sharer_pointer_388, !noalias !2
        store ptr @eraser_360, ptr %eraser_pointer_389, !noalias !2
        
        %pureApp_8480 = call ccc %Pos @allocate_2487(i64 %longLiteral_8476)
        
        
        call ccc void @sharePositive(%Pos %pureApp_8480)
        %stackPointer_1399 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %bounces_5_783_6504_pointer_1400 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 0
        store %Reference %bounces_5_783_6504, ptr %bounces_5_783_6504_pointer_1400, !noalias !2
        %n_2873_pointer_1401 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 1
        store i64 %n_2873, ptr %n_2873_pointer_1401, !noalias !2
        %tmp_8455_pointer_1402 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 2
        store %Pos %pureApp_8480, ptr %tmp_8455_pointer_1402, !noalias !2
        %ballCount_3_781_6265_pointer_1403 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 3
        store i64 %longLiteral_8476, ptr %ballCount_3_781_6265_pointer_1403, !noalias !2
        %returnAddress_pointer_1404 = getelementptr <{<{%Reference, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1399, i64 0, i32 1, i32 0
        %sharer_pointer_1405 = getelementptr <{<{%Reference, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1399, i64 0, i32 1, i32 1
        %eraser_pointer_1406 = getelementptr <{<{%Reference, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1399, i64 0, i32 1, i32 2
        store ptr @returnAddress_1204, ptr %returnAddress_pointer_1404, !noalias !2
        store ptr @sharer_1383, ptr %sharer_pointer_1405, !noalias !2
        store ptr @eraser_1393, ptr %eraser_pointer_1406, !noalias !2
        
        %longLiteral_8664 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_11_460_1238_6021(i64 %longLiteral_8664, %Pos %pureApp_8480, i64 %longLiteral_8476, %Reference %seed_5_5892, %Stack %stack)
        ret void
}


@utf8StringLiteral_8464.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_8466.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_8469.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_1407(%Pos %v_r_3343_4146, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1408 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_1409 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1408, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_1409, !noalias !2
        %index_2107_pointer_1410 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1408, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_1410, !noalias !2
        %Exception_2362_pointer_1411 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1408, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_1411, !noalias !2
        
        %tag_1412 = extractvalue %Pos %v_r_3343_4146, 0
        %fields_1413 = extractvalue %Pos %v_r_3343_4146, 1
        switch i64 %tag_1412, label %label_1414 [i64 0, label %label_1418 i64 1, label %label_1424]
    
    label_1414:
        
        ret void
    
    label_1418:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_8460 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_1416 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1417 = getelementptr %FrameHeader, %StackPointer %stackPointer_1416, i64 0, i32 0
        %returnAddress_1415 = load %ReturnAddress, ptr %returnAddress_pointer_1417, !noalias !2
        musttail call tailcc void %returnAddress_1415(i64 %pureApp_8460, %Stack %stack)
        ret void
    
    label_1424:
        
        %make_8461_temporary_1419 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_8461 = insertvalue %Pos %make_8461_temporary_1419, %Object null, 1
        
        
        
        %pureApp_8462 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_8464 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_8464.lit)
        
        %pureApp_8463 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_8464, %Pos %pureApp_8462)
        
        
        
        %utf8StringLiteral_8466 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_8466.lit)
        
        %pureApp_8465 = call ccc %Pos @infixConcat_35(%Pos %pureApp_8463, %Pos %utf8StringLiteral_8466)
        
        
        
        %pureApp_8467 = call ccc %Pos @infixConcat_35(%Pos %pureApp_8465, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_8469 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_8469.lit)
        
        %pureApp_8468 = call ccc %Pos @infixConcat_35(%Pos %pureApp_8467, %Pos %utf8StringLiteral_8469)
        
        
        
        %vtable_1420 = extractvalue %Neg %Exception_2362, 0
        %closure_1421 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_1422 = getelementptr ptr, ptr %vtable_1420, i64 0
        %functionPointer_1423 = load ptr, ptr %functionPointer_pointer_1422, !noalias !2
        musttail call tailcc void %functionPointer_1423(%Object %closure_1421, %Pos %make_8461, %Pos %pureApp_8468, %Stack %stack)
        ret void
}



define ccc void @sharer_1428(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1429 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_1425_pointer_1430 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1429, i64 0, i32 0
        %str_2106_1425 = load %Pos, ptr %str_2106_1425_pointer_1430, !noalias !2
        %index_2107_1426_pointer_1431 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1429, i64 0, i32 1
        %index_2107_1426 = load i64, ptr %index_2107_1426_pointer_1431, !noalias !2
        %Exception_2362_1427_pointer_1432 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1429, i64 0, i32 2
        %Exception_2362_1427 = load %Neg, ptr %Exception_2362_1427_pointer_1432, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_1425)
        call ccc void @shareNegative(%Neg %Exception_2362_1427)
        call ccc void @shareFrames(%StackPointer %stackPointer_1429)
        ret void
}



define ccc void @eraser_1436(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1437 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_1433_pointer_1438 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1437, i64 0, i32 0
        %str_2106_1433 = load %Pos, ptr %str_2106_1433_pointer_1438, !noalias !2
        %index_2107_1434_pointer_1439 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1437, i64 0, i32 1
        %index_2107_1434 = load i64, ptr %index_2107_1434_pointer_1439, !noalias !2
        %Exception_2362_1435_pointer_1440 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1437, i64 0, i32 2
        %Exception_2362_1435 = load %Neg, ptr %Exception_2362_1435_pointer_1440, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_1433)
        call ccc void @eraseNegative(%Neg %Exception_2362_1435)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1437)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_8459 = add i64 0, 0
        
        %pureApp_8458 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_8459)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_1441 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_1442 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1441, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_1442, !noalias !2
        %index_2107_pointer_1443 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1441, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_1443, !noalias !2
        %Exception_2362_pointer_1444 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1441, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_1444, !noalias !2
        %returnAddress_pointer_1445 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1441, i64 0, i32 1, i32 0
        %sharer_pointer_1446 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1441, i64 0, i32 1, i32 1
        %eraser_pointer_1447 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1441, i64 0, i32 1, i32 2
        store ptr @returnAddress_1407, ptr %returnAddress_pointer_1445, !noalias !2
        store ptr @sharer_1428, ptr %sharer_pointer_1446, !noalias !2
        store ptr @eraser_1436, ptr %eraser_pointer_1447, !noalias !2
        
        %tag_1448 = extractvalue %Pos %pureApp_8458, 0
        %fields_1449 = extractvalue %Pos %pureApp_8458, 1
        switch i64 %tag_1448, label %label_1450 [i64 0, label %label_1454 i64 1, label %label_1459]
    
    label_1450:
        
        ret void
    
    label_1454:
        
        %pureApp_8470 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_8471 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_8470)
        
        
        
        %stackPointer_1452 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1453 = getelementptr %FrameHeader, %StackPointer %stackPointer_1452, i64 0, i32 0
        %returnAddress_1451 = load %ReturnAddress, ptr %returnAddress_pointer_1453, !noalias !2
        musttail call tailcc void %returnAddress_1451(%Pos %pureApp_8471, %Stack %stack)
        ret void
    
    label_1459:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_8472_temporary_1455 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_8472 = insertvalue %Pos %booleanLiteral_8472_temporary_1455, %Object null, 1
        
        %stackPointer_1457 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1458 = getelementptr %FrameHeader, %StackPointer %stackPointer_1457, i64 0, i32 0
        %returnAddress_1456 = load %ReturnAddress, ptr %returnAddress_pointer_1458, !noalias !2
        musttail call tailcc void %returnAddress_1456(%Pos %booleanLiteral_8472, %Stack %stack)
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
        
        musttail call tailcc void @main_2875(%Stack %stack)
        ret void
}
