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



define ccc %Pos @infixEq_72(i64 %x_70, i64 %y_71) {
    ; declaration extern
    ; variable
    
    %z = icmp eq %Int %x_70, %y_71
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
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



define tailcc void @returnAddress_2(i64 %r_2447, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4591 = call ccc %Pos @show_14(i64 %r_2447)
        
        
        
        %pureApp_4592 = call ccc %Pos @println_1(%Pos %pureApp_4591)
        
        
        
        %stackPointer_4 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_5 = getelementptr %FrameHeader, %StackPointer %stackPointer_4, i64 0, i32 0
        %returnAddress_3 = load %ReturnAddress, ptr %returnAddress_pointer_5, !noalias !2
        musttail call tailcc void %returnAddress_3(%Pos %pureApp_4592, %Stack %stack)
        ret void
}



define ccc void @sharer_6(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_7 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_7)
        ret void
}



define ccc void @eraser_8(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_9 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_9)
        ret void
}



define tailcc void @returnAddress_14(i64 %returnValue_15, %Stack %stack) {
        
    entry:
        
        %stackPointer_16 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_4574_pointer_17 = getelementptr <{i64}>, %StackPointer %stackPointer_16, i64 0, i32 0
        %tmp_4574 = load i64, ptr %tmp_4574_pointer_17, !noalias !2
        %stackPointer_19 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_20 = getelementptr %FrameHeader, %StackPointer %stackPointer_19, i64 0, i32 0
        %returnAddress_18 = load %ReturnAddress, ptr %returnAddress_pointer_20, !noalias !2
        musttail call tailcc void %returnAddress_18(i64 %returnValue_15, %Stack %stack)
        ret void
}



define ccc void @sharer_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_4574_21_pointer_24 = getelementptr <{i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %tmp_4574_21 = load i64, ptr %tmp_4574_21_pointer_24, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_23)
        ret void
}



define ccc void @eraser_26(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_27 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_4574_25_pointer_28 = getelementptr <{i64}>, %StackPointer %stackPointer_27, i64 0, i32 0
        %tmp_4574_25 = load i64, ptr %tmp_4574_25_pointer_28, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_27)
        ret void
}



define tailcc void @returnAddress_40(%Pos %__6_32_4476, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_41 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %s_3_4456_pointer_42 = getelementptr <{%Reference}>, %StackPointer %stackPointer_41, i64 0, i32 0
        %s_3_4456 = load %Reference, ptr %s_3_4456_pointer_42, !noalias !2
        call ccc void @erasePositive(%Pos %__6_32_4476)
        
        
        musttail call tailcc void @countdown_worker_5_19_4468(%Reference %s_3_4456, %Stack %stack)
        ret void
}



define ccc void @sharer_44(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_45 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %s_3_4456_43_pointer_46 = getelementptr <{%Reference}>, %StackPointer %stackPointer_45, i64 0, i32 0
        %s_3_4456_43 = load %Reference, ptr %s_3_4456_43_pointer_46, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_45)
        ret void
}



define ccc void @eraser_48(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_49 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %s_3_4456_47_pointer_50 = getelementptr <{%Reference}>, %StackPointer %stackPointer_49, i64 0, i32 0
        %s_3_4456_47 = load %Reference, ptr %s_3_4456_47_pointer_50, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_49)
        ret void
}



define tailcc void @returnAddress_34(i64 %i_6_25_4457, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_35 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %s_3_4456_pointer_36 = getelementptr <{%Reference}>, %StackPointer %stackPointer_35, i64 0, i32 0
        %s_3_4456 = load %Reference, ptr %s_3_4456_pointer_36, !noalias !2
        
        %longLiteral_4595 = add i64 0, 0
        
        %pureApp_4594 = call ccc %Pos @infixEq_72(i64 %i_6_25_4457, i64 %longLiteral_4595)
        
        
        
        %tag_37 = extractvalue %Pos %pureApp_4594, 0
        %fields_38 = extractvalue %Pos %pureApp_4594, 1
        switch i64 %tag_37, label %label_39 [i64 0, label %label_62 i64 1, label %label_66]
    
    label_39:
        
        ret void
    
    label_62:
        
        %longLiteral_4597 = add i64 1, 0
        
        %pureApp_4596 = call ccc i64 @infixSub_105(i64 %i_6_25_4457, i64 %longLiteral_4597)
        
        
        %stackPointer_51 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %s_3_4456_pointer_52 = getelementptr <{%Reference}>, %StackPointer %stackPointer_51, i64 0, i32 0
        store %Reference %s_3_4456, ptr %s_3_4456_pointer_52, !noalias !2
        %returnAddress_pointer_53 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_51, i64 0, i32 1, i32 0
        %sharer_pointer_54 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_51, i64 0, i32 1, i32 1
        %eraser_pointer_55 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_51, i64 0, i32 1, i32 2
        store ptr @returnAddress_40, ptr %returnAddress_pointer_53, !noalias !2
        store ptr @sharer_44, ptr %sharer_pointer_54, !noalias !2
        store ptr @eraser_48, ptr %eraser_pointer_55, !noalias !2
        
        %s_3_4456pointer_56 = call ccc ptr @getVarPointer(%Reference %s_3_4456, %Stack %stack)
        %s_3_4456_old_57 = load i64, ptr %s_3_4456pointer_56, !noalias !2
        store i64 %pureApp_4596, ptr %s_3_4456pointer_56, !noalias !2
        
        %put_4598_temporary_58 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_4598 = insertvalue %Pos %put_4598_temporary_58, %Object null, 1
        
        %stackPointer_60 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_61 = getelementptr %FrameHeader, %StackPointer %stackPointer_60, i64 0, i32 0
        %returnAddress_59 = load %ReturnAddress, ptr %returnAddress_pointer_61, !noalias !2
        musttail call tailcc void %returnAddress_59(%Pos %put_4598, %Stack %stack)
        ret void
    
    label_66:
        
        %stackPointer_64 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_65 = getelementptr %FrameHeader, %StackPointer %stackPointer_64, i64 0, i32 0
        %returnAddress_63 = load %ReturnAddress, ptr %returnAddress_pointer_65, !noalias !2
        musttail call tailcc void %returnAddress_63(i64 %i_6_25_4457, %Stack %stack)
        ret void
}



define tailcc void @countdown_worker_5_19_4468(%Reference %s_3_4456, %Stack %stack) {
        
    entry:
        
        %stackPointer_69 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %s_3_4456_pointer_70 = getelementptr <{%Reference}>, %StackPointer %stackPointer_69, i64 0, i32 0
        store %Reference %s_3_4456, ptr %s_3_4456_pointer_70, !noalias !2
        %returnAddress_pointer_71 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_69, i64 0, i32 1, i32 0
        %sharer_pointer_72 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_69, i64 0, i32 1, i32 1
        %eraser_pointer_73 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_69, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_71, !noalias !2
        store ptr @sharer_44, ptr %sharer_pointer_72, !noalias !2
        store ptr @eraser_48, ptr %eraser_pointer_73, !noalias !2
        
        %get_4599_pointer_74 = call ccc ptr @getVarPointer(%Reference %s_3_4456, %Stack %stack)
        %s_3_4456_old_75 = load i64, ptr %get_4599_pointer_74, !noalias !2
        %get_4599 = load i64, ptr %get_4599_pointer_74, !noalias !2
        
        %stackPointer_77 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_78 = getelementptr %FrameHeader, %StackPointer %stackPointer_77, i64 0, i32 0
        %returnAddress_76 = load %ReturnAddress, ptr %returnAddress_pointer_78, !noalias !2
        musttail call tailcc void %returnAddress_76(i64 %get_4599, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3436_3500, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4590 = call ccc i64 @unboxInt_303(%Pos %v_coe_3436_3500)
        
        
        %stackPointer_10 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 0
        %sharer_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 1
        %eraser_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_11, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_12, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_13, !noalias !2
        %s_3_4456 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_29 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_4574_pointer_30 = getelementptr <{i64}>, %StackPointer %stackPointer_29, i64 0, i32 0
        store i64 %pureApp_4590, ptr %tmp_4574_pointer_30, !noalias !2
        %returnAddress_pointer_31 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 0
        %sharer_pointer_32 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 1
        %eraser_pointer_33 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 2
        store ptr @returnAddress_14, ptr %returnAddress_pointer_31, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_32, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_33, !noalias !2
        
        
        musttail call tailcc void @countdown_worker_5_19_4468(%Reference %s_3_4456, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_84(%Pos %returned_4600, %Stack %stack) {
        
    entry:
        
        %stack_85 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_87 = call ccc %StackPointer @stackDeallocate(%Stack %stack_85, i64 24)
        %returnAddress_pointer_88 = getelementptr %FrameHeader, %StackPointer %stackPointer_87, i64 0, i32 0
        %returnAddress_86 = load %ReturnAddress, ptr %returnAddress_pointer_88, !noalias !2
        musttail call tailcc void %returnAddress_86(%Pos %returned_4600, %Stack %stack_85)
        ret void
}



define ccc void @sharer_89(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_90 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_91(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_92 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_92)
        ret void
}



define ccc void @eraser_104(%Environment %environment) {
        
    entry:
        
        %tmp_4540_102_pointer_105 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4540_102 = load %Pos, ptr %tmp_4540_102_pointer_105, !noalias !2
        %acc_3_3_5_169_4392_103_pointer_106 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4392_103 = load %Pos, ptr %acc_3_3_5_169_4392_103_pointer_106, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4540_102)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4392_103)
        ret void
}



define tailcc void @toList_1_1_3_167_4333(i64 %start_2_2_4_168_4210, %Pos %acc_3_3_5_169_4392, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4602 = add i64 1, 0
        
        %pureApp_4601 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4210, i64 %longLiteral_4602)
        
        
        
        %tag_97 = extractvalue %Pos %pureApp_4601, 0
        %fields_98 = extractvalue %Pos %pureApp_4601, 1
        switch i64 %tag_97, label %label_99 [i64 0, label %label_110 i64 1, label %label_114]
    
    label_99:
        
        ret void
    
    label_110:
        
        %pureApp_4603 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4210)
        
        
        
        %longLiteral_4605 = add i64 1, 0
        
        %pureApp_4604 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4210, i64 %longLiteral_4605)
        
        
        
        %fields_100 = call ccc %Object @newObject(ptr @eraser_104, i64 32)
        %environment_101 = call ccc %Environment @objectEnvironment(%Object %fields_100)
        %tmp_4540_pointer_107 = getelementptr <{%Pos, %Pos}>, %Environment %environment_101, i64 0, i32 0
        store %Pos %pureApp_4603, ptr %tmp_4540_pointer_107, !noalias !2
        %acc_3_3_5_169_4392_pointer_108 = getelementptr <{%Pos, %Pos}>, %Environment %environment_101, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4392, ptr %acc_3_3_5_169_4392_pointer_108, !noalias !2
        %make_4606_temporary_109 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4606 = insertvalue %Pos %make_4606_temporary_109, %Object %fields_100, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4333(i64 %pureApp_4604, %Pos %make_4606, %Stack %stack)
        ret void
    
    label_114:
        
        %stackPointer_112 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_113 = getelementptr %FrameHeader, %StackPointer %stackPointer_112, i64 0, i32 0
        %returnAddress_111 = load %ReturnAddress, ptr %returnAddress_pointer_113, !noalias !2
        musttail call tailcc void %returnAddress_111(%Pos %acc_3_3_5_169_4392, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_125(%Pos %v_r_2595_32_59_223_4115, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_126 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_4547_pointer_127 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_126, i64 0, i32 0
        %tmp_4547 = load i64, ptr %tmp_4547_pointer_127, !noalias !2
        %acc_8_35_199_4226_pointer_128 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_126, i64 0, i32 1
        %acc_8_35_199_4226 = load i64, ptr %acc_8_35_199_4226_pointer_128, !noalias !2
        %index_7_34_198_4171_pointer_129 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_126, i64 0, i32 2
        %index_7_34_198_4171 = load i64, ptr %index_7_34_198_4171_pointer_129, !noalias !2
        %v_r_2512_30_194_4323_pointer_130 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_126, i64 0, i32 3
        %v_r_2512_30_194_4323 = load %Pos, ptr %v_r_2512_30_194_4323_pointer_130, !noalias !2
        %p_8_9_4078_pointer_131 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_126, i64 0, i32 4
        %p_8_9_4078 = load %Prompt, ptr %p_8_9_4078_pointer_131, !noalias !2
        
        %tag_132 = extractvalue %Pos %v_r_2595_32_59_223_4115, 0
        %fields_133 = extractvalue %Pos %v_r_2595_32_59_223_4115, 1
        switch i64 %tag_132, label %label_134 [i64 1, label %label_157 i64 0, label %label_164]
    
    label_134:
        
        ret void
    
    label_139:
        
        ret void
    
    label_145:
        call ccc void @erasePositive(%Pos %v_r_2512_30_194_4323)
        
        %pair_140 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4078)
        %k_13_14_4_4482 = extractvalue <{%Resumption, %Stack}> %pair_140, 0
        %stack_141 = extractvalue <{%Resumption, %Stack}> %pair_140, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4482)
        
        %longLiteral_4618 = add i64 5, 0
        
        
        
        %pureApp_4619 = call ccc %Pos @boxInt_301(i64 %longLiteral_4618)
        
        
        
        %stackPointer_143 = call ccc %StackPointer @stackDeallocate(%Stack %stack_141, i64 24)
        %returnAddress_pointer_144 = getelementptr %FrameHeader, %StackPointer %stackPointer_143, i64 0, i32 0
        %returnAddress_142 = load %ReturnAddress, ptr %returnAddress_pointer_144, !noalias !2
        musttail call tailcc void %returnAddress_142(%Pos %pureApp_4619, %Stack %stack_141)
        ret void
    
    label_148:
        
        ret void
    
    label_154:
        call ccc void @erasePositive(%Pos %v_r_2512_30_194_4323)
        
        %pair_149 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4078)
        %k_13_14_4_4481 = extractvalue <{%Resumption, %Stack}> %pair_149, 0
        %stack_150 = extractvalue <{%Resumption, %Stack}> %pair_149, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4481)
        
        %longLiteral_4622 = add i64 5, 0
        
        
        
        %pureApp_4623 = call ccc %Pos @boxInt_301(i64 %longLiteral_4622)
        
        
        
        %stackPointer_152 = call ccc %StackPointer @stackDeallocate(%Stack %stack_150, i64 24)
        %returnAddress_pointer_153 = getelementptr %FrameHeader, %StackPointer %stackPointer_152, i64 0, i32 0
        %returnAddress_151 = load %ReturnAddress, ptr %returnAddress_pointer_153, !noalias !2
        musttail call tailcc void %returnAddress_151(%Pos %pureApp_4623, %Stack %stack_150)
        ret void
    
    label_155:
        
        %longLiteral_4625 = add i64 1, 0
        
        %pureApp_4624 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4171, i64 %longLiteral_4625)
        
        
        
        %longLiteral_4627 = add i64 10, 0
        
        %pureApp_4626 = call ccc i64 @infixMul_99(i64 %longLiteral_4627, i64 %acc_8_35_199_4226)
        
        
        
        %pureApp_4628 = call ccc i64 @toInt_2085(i64 %pureApp_4615)
        
        
        
        %pureApp_4629 = call ccc i64 @infixSub_105(i64 %pureApp_4628, i64 %tmp_4547)
        
        
        
        %pureApp_4630 = call ccc i64 @infixAdd_96(i64 %pureApp_4626, i64 %pureApp_4629)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4216(i64 %pureApp_4624, i64 %pureApp_4630, i64 %tmp_4547, %Pos %v_r_2512_30_194_4323, %Prompt %p_8_9_4078, %Stack %stack)
        ret void
    
    label_156:
        
        %intLiteral_4621 = add i64 57, 0
        
        %pureApp_4620 = call ccc %Pos @infixLte_2093(i64 %pureApp_4615, i64 %intLiteral_4621)
        
        
        
        %tag_146 = extractvalue %Pos %pureApp_4620, 0
        %fields_147 = extractvalue %Pos %pureApp_4620, 1
        switch i64 %tag_146, label %label_148 [i64 0, label %label_154 i64 1, label %label_155]
    
    label_157:
        %environment_135 = call ccc %Environment @objectEnvironment(%Object %fields_133)
        %v_coe_3411_46_73_237_4376_pointer_136 = getelementptr <{%Pos}>, %Environment %environment_135, i64 0, i32 0
        %v_coe_3411_46_73_237_4376 = load %Pos, ptr %v_coe_3411_46_73_237_4376_pointer_136, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3411_46_73_237_4376)
        call ccc void @eraseObject(%Object %fields_133)
        
        %pureApp_4615 = call ccc i64 @unboxChar_313(%Pos %v_coe_3411_46_73_237_4376)
        
        
        
        %intLiteral_4617 = add i64 48, 0
        
        %pureApp_4616 = call ccc %Pos @infixGte_2099(i64 %pureApp_4615, i64 %intLiteral_4617)
        
        
        
        %tag_137 = extractvalue %Pos %pureApp_4616, 0
        %fields_138 = extractvalue %Pos %pureApp_4616, 1
        switch i64 %tag_137, label %label_139 [i64 0, label %label_145 i64 1, label %label_156]
    
    label_164:
        %environment_158 = call ccc %Environment @objectEnvironment(%Object %fields_133)
        %v_y_2602_76_103_267_4613_pointer_159 = getelementptr <{%Pos, %Pos}>, %Environment %environment_158, i64 0, i32 0
        %v_y_2602_76_103_267_4613 = load %Pos, ptr %v_y_2602_76_103_267_4613_pointer_159, !noalias !2
        %v_y_2603_77_104_268_4614_pointer_160 = getelementptr <{%Pos, %Pos}>, %Environment %environment_158, i64 0, i32 1
        %v_y_2603_77_104_268_4614 = load %Pos, ptr %v_y_2603_77_104_268_4614_pointer_160, !noalias !2
        call ccc void @eraseObject(%Object %fields_133)
        call ccc void @erasePositive(%Pos %v_r_2512_30_194_4323)
        
        %stackPointer_162 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_163 = getelementptr %FrameHeader, %StackPointer %stackPointer_162, i64 0, i32 0
        %returnAddress_161 = load %ReturnAddress, ptr %returnAddress_pointer_163, !noalias !2
        musttail call tailcc void %returnAddress_161(i64 %acc_8_35_199_4226, %Stack %stack)
        ret void
}



define ccc void @sharer_170(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_171 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4547_165_pointer_172 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_171, i64 0, i32 0
        %tmp_4547_165 = load i64, ptr %tmp_4547_165_pointer_172, !noalias !2
        %acc_8_35_199_4226_166_pointer_173 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_171, i64 0, i32 1
        %acc_8_35_199_4226_166 = load i64, ptr %acc_8_35_199_4226_166_pointer_173, !noalias !2
        %index_7_34_198_4171_167_pointer_174 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_171, i64 0, i32 2
        %index_7_34_198_4171_167 = load i64, ptr %index_7_34_198_4171_167_pointer_174, !noalias !2
        %v_r_2512_30_194_4323_168_pointer_175 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_171, i64 0, i32 3
        %v_r_2512_30_194_4323_168 = load %Pos, ptr %v_r_2512_30_194_4323_168_pointer_175, !noalias !2
        %p_8_9_4078_169_pointer_176 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_171, i64 0, i32 4
        %p_8_9_4078_169 = load %Prompt, ptr %p_8_9_4078_169_pointer_176, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2512_30_194_4323_168)
        call ccc void @shareFrames(%StackPointer %stackPointer_171)
        ret void
}



define ccc void @eraser_182(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_183 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4547_177_pointer_184 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_183, i64 0, i32 0
        %tmp_4547_177 = load i64, ptr %tmp_4547_177_pointer_184, !noalias !2
        %acc_8_35_199_4226_178_pointer_185 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_183, i64 0, i32 1
        %acc_8_35_199_4226_178 = load i64, ptr %acc_8_35_199_4226_178_pointer_185, !noalias !2
        %index_7_34_198_4171_179_pointer_186 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_183, i64 0, i32 2
        %index_7_34_198_4171_179 = load i64, ptr %index_7_34_198_4171_179_pointer_186, !noalias !2
        %v_r_2512_30_194_4323_180_pointer_187 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_183, i64 0, i32 3
        %v_r_2512_30_194_4323_180 = load %Pos, ptr %v_r_2512_30_194_4323_180_pointer_187, !noalias !2
        %p_8_9_4078_181_pointer_188 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_183, i64 0, i32 4
        %p_8_9_4078_181 = load %Prompt, ptr %p_8_9_4078_181_pointer_188, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2512_30_194_4323_180)
        call ccc void @eraseFrames(%StackPointer %stackPointer_183)
        ret void
}



define tailcc void @returnAddress_199(%Pos %returned_4631, %Stack %stack) {
        
    entry:
        
        %stack_200 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_202 = call ccc %StackPointer @stackDeallocate(%Stack %stack_200, i64 24)
        %returnAddress_pointer_203 = getelementptr %FrameHeader, %StackPointer %stackPointer_202, i64 0, i32 0
        %returnAddress_201 = load %ReturnAddress, ptr %returnAddress_pointer_203, !noalias !2
        musttail call tailcc void %returnAddress_201(%Pos %returned_4631, %Stack %stack_200)
        ret void
}



define tailcc void @Exception_7_19_46_210_4169_clause_208(%Object %closure, %Pos %exc_8_20_47_211_4272, %Pos %msg_9_21_48_212_4137, %Stack %stack) {
        
    entry:
        
        %environment_209 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4142_pointer_210 = getelementptr <{%Prompt}>, %Environment %environment_209, i64 0, i32 0
        %p_6_18_45_209_4142 = load %Prompt, ptr %p_6_18_45_209_4142_pointer_210, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_211 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4142)
        %k_11_23_50_214_4403 = extractvalue <{%Resumption, %Stack}> %pair_211, 0
        %stack_212 = extractvalue <{%Resumption, %Stack}> %pair_211, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4403)
        
        %fields_213 = call ccc %Object @newObject(ptr @eraser_104, i64 32)
        %environment_214 = call ccc %Environment @objectEnvironment(%Object %fields_213)
        %exc_8_20_47_211_4272_pointer_217 = getelementptr <{%Pos, %Pos}>, %Environment %environment_214, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4272, ptr %exc_8_20_47_211_4272_pointer_217, !noalias !2
        %msg_9_21_48_212_4137_pointer_218 = getelementptr <{%Pos, %Pos}>, %Environment %environment_214, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4137, ptr %msg_9_21_48_212_4137_pointer_218, !noalias !2
        %make_4632_temporary_219 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4632 = insertvalue %Pos %make_4632_temporary_219, %Object %fields_213, 1
        
        
        
        %stackPointer_221 = call ccc %StackPointer @stackDeallocate(%Stack %stack_212, i64 24)
        %returnAddress_pointer_222 = getelementptr %FrameHeader, %StackPointer %stackPointer_221, i64 0, i32 0
        %returnAddress_220 = load %ReturnAddress, ptr %returnAddress_pointer_222, !noalias !2
        musttail call tailcc void %returnAddress_220(%Pos %make_4632, %Stack %stack_212)
        ret void
}


@vtable_223 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4169_clause_208]


define ccc void @eraser_227(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4142_226_pointer_228 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4142_226 = load %Prompt, ptr %p_6_18_45_209_4142_226_pointer_228, !noalias !2
        ret void
}



define ccc void @eraser_235(%Environment %environment) {
        
    entry:
        
        %tmp_4549_234_pointer_236 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4549_234 = load %Pos, ptr %tmp_4549_234_pointer_236, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4549_234)
        ret void
}



define tailcc void @returnAddress_231(i64 %v_coe_3410_6_28_55_219_4219, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4633 = call ccc %Pos @boxChar_311(i64 %v_coe_3410_6_28_55_219_4219)
        
        
        
        %fields_232 = call ccc %Object @newObject(ptr @eraser_235, i64 16)
        %environment_233 = call ccc %Environment @objectEnvironment(%Object %fields_232)
        %tmp_4549_pointer_237 = getelementptr <{%Pos}>, %Environment %environment_233, i64 0, i32 0
        store %Pos %pureApp_4633, ptr %tmp_4549_pointer_237, !noalias !2
        %make_4634_temporary_238 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4634 = insertvalue %Pos %make_4634_temporary_238, %Object %fields_232, 1
        
        
        
        %stackPointer_240 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_241 = getelementptr %FrameHeader, %StackPointer %stackPointer_240, i64 0, i32 0
        %returnAddress_239 = load %ReturnAddress, ptr %returnAddress_pointer_241, !noalias !2
        musttail call tailcc void %returnAddress_239(%Pos %make_4634, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4216(i64 %index_7_34_198_4171, i64 %acc_8_35_199_4226, i64 %tmp_4547, %Pos %v_r_2512_30_194_4323, %Prompt %p_8_9_4078, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2512_30_194_4323)
        %stackPointer_189 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_4547_pointer_190 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_189, i64 0, i32 0
        store i64 %tmp_4547, ptr %tmp_4547_pointer_190, !noalias !2
        %acc_8_35_199_4226_pointer_191 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_189, i64 0, i32 1
        store i64 %acc_8_35_199_4226, ptr %acc_8_35_199_4226_pointer_191, !noalias !2
        %index_7_34_198_4171_pointer_192 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_189, i64 0, i32 2
        store i64 %index_7_34_198_4171, ptr %index_7_34_198_4171_pointer_192, !noalias !2
        %v_r_2512_30_194_4323_pointer_193 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_189, i64 0, i32 3
        store %Pos %v_r_2512_30_194_4323, ptr %v_r_2512_30_194_4323_pointer_193, !noalias !2
        %p_8_9_4078_pointer_194 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_189, i64 0, i32 4
        store %Prompt %p_8_9_4078, ptr %p_8_9_4078_pointer_194, !noalias !2
        %returnAddress_pointer_195 = getelementptr <{<{i64, i64, i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_189, i64 0, i32 1, i32 0
        %sharer_pointer_196 = getelementptr <{<{i64, i64, i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_189, i64 0, i32 1, i32 1
        %eraser_pointer_197 = getelementptr <{<{i64, i64, i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_189, i64 0, i32 1, i32 2
        store ptr @returnAddress_125, ptr %returnAddress_pointer_195, !noalias !2
        store ptr @sharer_170, ptr %sharer_pointer_196, !noalias !2
        store ptr @eraser_182, ptr %eraser_pointer_197, !noalias !2
        
        %stack_198 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4142 = call ccc %Prompt @currentPrompt(%Stack %stack_198)
        %stackPointer_204 = call ccc %StackPointer @stackAllocate(%Stack %stack_198, i64 24)
        %returnAddress_pointer_205 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_204, i64 0, i32 1, i32 0
        %sharer_pointer_206 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_204, i64 0, i32 1, i32 1
        %eraser_pointer_207 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_204, i64 0, i32 1, i32 2
        store ptr @returnAddress_199, ptr %returnAddress_pointer_205, !noalias !2
        store ptr @sharer_89, ptr %sharer_pointer_206, !noalias !2
        store ptr @eraser_91, ptr %eraser_pointer_207, !noalias !2
        
        %closure_224 = call ccc %Object @newObject(ptr @eraser_227, i64 8)
        %environment_225 = call ccc %Environment @objectEnvironment(%Object %closure_224)
        %p_6_18_45_209_4142_pointer_229 = getelementptr <{%Prompt}>, %Environment %environment_225, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4142, ptr %p_6_18_45_209_4142_pointer_229, !noalias !2
        %vtable_temporary_230 = insertvalue %Neg zeroinitializer, ptr @vtable_223, 0
        %Exception_7_19_46_210_4169 = insertvalue %Neg %vtable_temporary_230, %Object %closure_224, 1
        %stackPointer_242 = call ccc %StackPointer @stackAllocate(%Stack %stack_198, i64 24)
        %returnAddress_pointer_243 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_242, i64 0, i32 1, i32 0
        %sharer_pointer_244 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_242, i64 0, i32 1, i32 1
        %eraser_pointer_245 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_242, i64 0, i32 1, i32 2
        store ptr @returnAddress_231, ptr %returnAddress_pointer_243, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_244, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_245, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2512_30_194_4323, i64 %index_7_34_198_4171, %Neg %Exception_7_19_46_210_4169, %Stack %stack_198)
        ret void
}



define tailcc void @Exception_9_106_133_297_4118_clause_246(%Object %closure, %Pos %exception_10_107_134_298_4635, %Pos %msg_11_108_135_299_4636, %Stack %stack) {
        
    entry:
        
        %environment_247 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4078_pointer_248 = getelementptr <{%Prompt}>, %Environment %environment_247, i64 0, i32 0
        %p_8_9_4078 = load %Prompt, ptr %p_8_9_4078_pointer_248, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4635)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4636)
        
        %pair_249 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4078)
        %k_13_14_4_4530 = extractvalue <{%Resumption, %Stack}> %pair_249, 0
        %stack_250 = extractvalue <{%Resumption, %Stack}> %pair_249, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4530)
        
        %longLiteral_4637 = add i64 5, 0
        
        
        
        %pureApp_4638 = call ccc %Pos @boxInt_301(i64 %longLiteral_4637)
        
        
        
        %stackPointer_252 = call ccc %StackPointer @stackDeallocate(%Stack %stack_250, i64 24)
        %returnAddress_pointer_253 = getelementptr %FrameHeader, %StackPointer %stackPointer_252, i64 0, i32 0
        %returnAddress_251 = load %ReturnAddress, ptr %returnAddress_pointer_253, !noalias !2
        musttail call tailcc void %returnAddress_251(%Pos %pureApp_4638, %Stack %stack_250)
        ret void
}


@vtable_254 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4118_clause_246]


define tailcc void @returnAddress_265(i64 %v_coe_3415_22_131_158_322_4373, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4641 = call ccc %Pos @boxInt_301(i64 %v_coe_3415_22_131_158_322_4373)
        
        
        
        
        
        %pureApp_4642 = call ccc i64 @unboxInt_303(%Pos %pureApp_4641)
        
        
        
        %pureApp_4643 = call ccc %Pos @boxInt_301(i64 %pureApp_4642)
        
        
        
        %stackPointer_267 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_268 = getelementptr %FrameHeader, %StackPointer %stackPointer_267, i64 0, i32 0
        %returnAddress_266 = load %ReturnAddress, ptr %returnAddress_pointer_268, !noalias !2
        musttail call tailcc void %returnAddress_266(%Pos %pureApp_4643, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_277(i64 %v_r_2609_1_9_20_129_156_320_4369, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4647 = add i64 0, 0
        
        %pureApp_4646 = call ccc i64 @infixSub_105(i64 %longLiteral_4647, i64 %v_r_2609_1_9_20_129_156_320_4369)
        
        
        
        %stackPointer_279 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_280 = getelementptr %FrameHeader, %StackPointer %stackPointer_279, i64 0, i32 0
        %returnAddress_278 = load %ReturnAddress, ptr %returnAddress_pointer_280, !noalias !2
        musttail call tailcc void %returnAddress_278(i64 %pureApp_4646, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_260(i64 %v_r_2608_3_14_123_150_314_4144, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_261 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_4547_pointer_262 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_261, i64 0, i32 0
        %tmp_4547 = load i64, ptr %tmp_4547_pointer_262, !noalias !2
        %v_r_2512_30_194_4323_pointer_263 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_261, i64 0, i32 1
        %v_r_2512_30_194_4323 = load %Pos, ptr %v_r_2512_30_194_4323_pointer_263, !noalias !2
        %p_8_9_4078_pointer_264 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_261, i64 0, i32 2
        %p_8_9_4078 = load %Prompt, ptr %p_8_9_4078_pointer_264, !noalias !2
        
        %intLiteral_4640 = add i64 45, 0
        
        %pureApp_4639 = call ccc %Pos @infixEq_78(i64 %v_r_2608_3_14_123_150_314_4144, i64 %intLiteral_4640)
        
        
        %stackPointer_269 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_270 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_269, i64 0, i32 1, i32 0
        %sharer_pointer_271 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_269, i64 0, i32 1, i32 1
        %eraser_pointer_272 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_269, i64 0, i32 1, i32 2
        store ptr @returnAddress_265, ptr %returnAddress_pointer_270, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_271, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_272, !noalias !2
        
        %tag_273 = extractvalue %Pos %pureApp_4639, 0
        %fields_274 = extractvalue %Pos %pureApp_4639, 1
        switch i64 %tag_273, label %label_275 [i64 0, label %label_276 i64 1, label %label_285]
    
    label_275:
        
        ret void
    
    label_276:
        
        %longLiteral_4644 = add i64 0, 0
        
        %longLiteral_4645 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4216(i64 %longLiteral_4644, i64 %longLiteral_4645, i64 %tmp_4547, %Pos %v_r_2512_30_194_4323, %Prompt %p_8_9_4078, %Stack %stack)
        ret void
    
    label_285:
        %stackPointer_281 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_282 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 0
        %sharer_pointer_283 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 1
        %eraser_pointer_284 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 2
        store ptr @returnAddress_277, ptr %returnAddress_pointer_282, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_283, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_284, !noalias !2
        
        %longLiteral_4648 = add i64 1, 0
        
        %longLiteral_4649 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4216(i64 %longLiteral_4648, i64 %longLiteral_4649, i64 %tmp_4547, %Pos %v_r_2512_30_194_4323, %Prompt %p_8_9_4078, %Stack %stack)
        ret void
}



define ccc void @sharer_289(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_290 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4547_286_pointer_291 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_290, i64 0, i32 0
        %tmp_4547_286 = load i64, ptr %tmp_4547_286_pointer_291, !noalias !2
        %v_r_2512_30_194_4323_287_pointer_292 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_290, i64 0, i32 1
        %v_r_2512_30_194_4323_287 = load %Pos, ptr %v_r_2512_30_194_4323_287_pointer_292, !noalias !2
        %p_8_9_4078_288_pointer_293 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_290, i64 0, i32 2
        %p_8_9_4078_288 = load %Prompt, ptr %p_8_9_4078_288_pointer_293, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2512_30_194_4323_287)
        call ccc void @shareFrames(%StackPointer %stackPointer_290)
        ret void
}



define ccc void @eraser_297(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_298 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4547_294_pointer_299 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_298, i64 0, i32 0
        %tmp_4547_294 = load i64, ptr %tmp_4547_294_pointer_299, !noalias !2
        %v_r_2512_30_194_4323_295_pointer_300 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_298, i64 0, i32 1
        %v_r_2512_30_194_4323_295 = load %Pos, ptr %v_r_2512_30_194_4323_295_pointer_300, !noalias !2
        %p_8_9_4078_296_pointer_301 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_298, i64 0, i32 2
        %p_8_9_4078_296 = load %Prompt, ptr %p_8_9_4078_296_pointer_301, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2512_30_194_4323_295)
        call ccc void @eraseFrames(%StackPointer %stackPointer_298)
        ret void
}



define tailcc void @returnAddress_122(%Pos %v_r_2512_30_194_4323, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_123 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4078_pointer_124 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_123, i64 0, i32 0
        %p_8_9_4078 = load %Prompt, ptr %p_8_9_4078_pointer_124, !noalias !2
        
        %intLiteral_4612 = add i64 48, 0
        
        %pureApp_4611 = call ccc i64 @toInt_2085(i64 %intLiteral_4612)
        
        
        
        %closure_255 = call ccc %Object @newObject(ptr @eraser_227, i64 8)
        %environment_256 = call ccc %Environment @objectEnvironment(%Object %closure_255)
        %p_8_9_4078_pointer_258 = getelementptr <{%Prompt}>, %Environment %environment_256, i64 0, i32 0
        store %Prompt %p_8_9_4078, ptr %p_8_9_4078_pointer_258, !noalias !2
        %vtable_temporary_259 = insertvalue %Neg zeroinitializer, ptr @vtable_254, 0
        %Exception_9_106_133_297_4118 = insertvalue %Neg %vtable_temporary_259, %Object %closure_255, 1
        call ccc void @sharePositive(%Pos %v_r_2512_30_194_4323)
        %stackPointer_302 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_4547_pointer_303 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_302, i64 0, i32 0
        store i64 %pureApp_4611, ptr %tmp_4547_pointer_303, !noalias !2
        %v_r_2512_30_194_4323_pointer_304 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_302, i64 0, i32 1
        store %Pos %v_r_2512_30_194_4323, ptr %v_r_2512_30_194_4323_pointer_304, !noalias !2
        %p_8_9_4078_pointer_305 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_302, i64 0, i32 2
        store %Prompt %p_8_9_4078, ptr %p_8_9_4078_pointer_305, !noalias !2
        %returnAddress_pointer_306 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_302, i64 0, i32 1, i32 0
        %sharer_pointer_307 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_302, i64 0, i32 1, i32 1
        %eraser_pointer_308 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_302, i64 0, i32 1, i32 2
        store ptr @returnAddress_260, ptr %returnAddress_pointer_306, !noalias !2
        store ptr @sharer_289, ptr %sharer_pointer_307, !noalias !2
        store ptr @eraser_297, ptr %eraser_pointer_308, !noalias !2
        
        %longLiteral_4650 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2512_30_194_4323, i64 %longLiteral_4650, %Neg %Exception_9_106_133_297_4118, %Stack %stack)
        ret void
}



define ccc void @sharer_310(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_311 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4078_309_pointer_312 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_311, i64 0, i32 0
        %p_8_9_4078_309 = load %Prompt, ptr %p_8_9_4078_309_pointer_312, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_311)
        ret void
}



define ccc void @eraser_314(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_315 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4078_313_pointer_316 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_315, i64 0, i32 0
        %p_8_9_4078_313 = load %Prompt, ptr %p_8_9_4078_313_pointer_316, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_315)
        ret void
}


@utf8StringLiteral_4651.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_119(%Pos %v_r_2511_24_188_4331, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_120 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4078_pointer_121 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_120, i64 0, i32 0
        %p_8_9_4078 = load %Prompt, ptr %p_8_9_4078_pointer_121, !noalias !2
        %stackPointer_317 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4078_pointer_318 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_317, i64 0, i32 0
        store %Prompt %p_8_9_4078, ptr %p_8_9_4078_pointer_318, !noalias !2
        %returnAddress_pointer_319 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_317, i64 0, i32 1, i32 0
        %sharer_pointer_320 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_317, i64 0, i32 1, i32 1
        %eraser_pointer_321 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_317, i64 0, i32 1, i32 2
        store ptr @returnAddress_122, ptr %returnAddress_pointer_319, !noalias !2
        store ptr @sharer_310, ptr %sharer_pointer_320, !noalias !2
        store ptr @eraser_314, ptr %eraser_pointer_321, !noalias !2
        
        %tag_322 = extractvalue %Pos %v_r_2511_24_188_4331, 0
        %fields_323 = extractvalue %Pos %v_r_2511_24_188_4331, 1
        switch i64 %tag_322, label %label_324 [i64 0, label %label_328 i64 1, label %label_334]
    
    label_324:
        
        ret void
    
    label_328:
        
        %utf8StringLiteral_4651 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4651.lit)
        
        %stackPointer_326 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_327 = getelementptr %FrameHeader, %StackPointer %stackPointer_326, i64 0, i32 0
        %returnAddress_325 = load %ReturnAddress, ptr %returnAddress_pointer_327, !noalias !2
        musttail call tailcc void %returnAddress_325(%Pos %utf8StringLiteral_4651, %Stack %stack)
        ret void
    
    label_334:
        %environment_329 = call ccc %Environment @objectEnvironment(%Object %fields_323)
        %v_y_3237_8_29_193_4114_pointer_330 = getelementptr <{%Pos}>, %Environment %environment_329, i64 0, i32 0
        %v_y_3237_8_29_193_4114 = load %Pos, ptr %v_y_3237_8_29_193_4114_pointer_330, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3237_8_29_193_4114)
        call ccc void @eraseObject(%Object %fields_323)
        
        %stackPointer_332 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_333 = getelementptr %FrameHeader, %StackPointer %stackPointer_332, i64 0, i32 0
        %returnAddress_331 = load %ReturnAddress, ptr %returnAddress_pointer_333, !noalias !2
        musttail call tailcc void %returnAddress_331(%Pos %v_y_3237_8_29_193_4114, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_116(%Pos %v_r_2510_13_177_4190, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_117 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4078_pointer_118 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_117, i64 0, i32 0
        %p_8_9_4078 = load %Prompt, ptr %p_8_9_4078_pointer_118, !noalias !2
        %stackPointer_337 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4078_pointer_338 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_337, i64 0, i32 0
        store %Prompt %p_8_9_4078, ptr %p_8_9_4078_pointer_338, !noalias !2
        %returnAddress_pointer_339 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_337, i64 0, i32 1, i32 0
        %sharer_pointer_340 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_337, i64 0, i32 1, i32 1
        %eraser_pointer_341 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_337, i64 0, i32 1, i32 2
        store ptr @returnAddress_119, ptr %returnAddress_pointer_339, !noalias !2
        store ptr @sharer_310, ptr %sharer_pointer_340, !noalias !2
        store ptr @eraser_314, ptr %eraser_pointer_341, !noalias !2
        
        %tag_342 = extractvalue %Pos %v_r_2510_13_177_4190, 0
        %fields_343 = extractvalue %Pos %v_r_2510_13_177_4190, 1
        switch i64 %tag_342, label %label_344 [i64 0, label %label_349 i64 1, label %label_361]
    
    label_344:
        
        ret void
    
    label_349:
        
        %make_4652_temporary_345 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4652 = insertvalue %Pos %make_4652_temporary_345, %Object null, 1
        
        
        
        %stackPointer_347 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_348 = getelementptr %FrameHeader, %StackPointer %stackPointer_347, i64 0, i32 0
        %returnAddress_346 = load %ReturnAddress, ptr %returnAddress_pointer_348, !noalias !2
        musttail call tailcc void %returnAddress_346(%Pos %make_4652, %Stack %stack)
        ret void
    
    label_361:
        %environment_350 = call ccc %Environment @objectEnvironment(%Object %fields_343)
        %v_y_2746_10_21_185_4150_pointer_351 = getelementptr <{%Pos, %Pos}>, %Environment %environment_350, i64 0, i32 0
        %v_y_2746_10_21_185_4150 = load %Pos, ptr %v_y_2746_10_21_185_4150_pointer_351, !noalias !2
        %v_y_2747_11_22_186_4213_pointer_352 = getelementptr <{%Pos, %Pos}>, %Environment %environment_350, i64 0, i32 1
        %v_y_2747_11_22_186_4213 = load %Pos, ptr %v_y_2747_11_22_186_4213_pointer_352, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2746_10_21_185_4150)
        call ccc void @eraseObject(%Object %fields_343)
        
        %fields_353 = call ccc %Object @newObject(ptr @eraser_235, i64 16)
        %environment_354 = call ccc %Environment @objectEnvironment(%Object %fields_353)
        %v_y_2746_10_21_185_4150_pointer_356 = getelementptr <{%Pos}>, %Environment %environment_354, i64 0, i32 0
        store %Pos %v_y_2746_10_21_185_4150, ptr %v_y_2746_10_21_185_4150_pointer_356, !noalias !2
        %make_4653_temporary_357 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4653 = insertvalue %Pos %make_4653_temporary_357, %Object %fields_353, 1
        
        
        
        %stackPointer_359 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_360 = getelementptr %FrameHeader, %StackPointer %stackPointer_359, i64 0, i32 0
        %returnAddress_358 = load %ReturnAddress, ptr %returnAddress_pointer_360, !noalias !2
        musttail call tailcc void %returnAddress_358(%Pos %make_4653, %Stack %stack)
        ret void
}



define tailcc void @main_2437(%Stack %stack) {
        
    entry:
        
        %stackPointer_79 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_80 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_79, i64 0, i32 1, i32 0
        %sharer_pointer_81 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_79, i64 0, i32 1, i32 1
        %eraser_pointer_82 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_79, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_80, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_81, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_82, !noalias !2
        
        %stack_83 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4078 = call ccc %Prompt @currentPrompt(%Stack %stack_83)
        %stackPointer_93 = call ccc %StackPointer @stackAllocate(%Stack %stack_83, i64 24)
        %returnAddress_pointer_94 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_93, i64 0, i32 1, i32 0
        %sharer_pointer_95 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_93, i64 0, i32 1, i32 1
        %eraser_pointer_96 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_93, i64 0, i32 1, i32 2
        store ptr @returnAddress_84, ptr %returnAddress_pointer_94, !noalias !2
        store ptr @sharer_89, ptr %sharer_pointer_95, !noalias !2
        store ptr @eraser_91, ptr %eraser_pointer_96, !noalias !2
        
        %pureApp_4607 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4609 = add i64 1, 0
        
        %pureApp_4608 = call ccc i64 @infixSub_105(i64 %pureApp_4607, i64 %longLiteral_4609)
        
        
        
        %make_4610_temporary_115 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4610 = insertvalue %Pos %make_4610_temporary_115, %Object null, 1
        
        
        %stackPointer_364 = call ccc %StackPointer @stackAllocate(%Stack %stack_83, i64 32)
        %p_8_9_4078_pointer_365 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_364, i64 0, i32 0
        store %Prompt %p_8_9_4078, ptr %p_8_9_4078_pointer_365, !noalias !2
        %returnAddress_pointer_366 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_364, i64 0, i32 1, i32 0
        %sharer_pointer_367 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_364, i64 0, i32 1, i32 1
        %eraser_pointer_368 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_364, i64 0, i32 1, i32 2
        store ptr @returnAddress_116, ptr %returnAddress_pointer_366, !noalias !2
        store ptr @sharer_310, ptr %sharer_pointer_367, !noalias !2
        store ptr @eraser_314, ptr %eraser_pointer_368, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4333(i64 %pureApp_4608, %Pos %make_4610, %Stack %stack_83)
        ret void
}


@utf8StringLiteral_4581.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4583.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4586.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_369(%Pos %v_r_2677_3467, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_370 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_371 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_370, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_371, !noalias !2
        %index_2107_pointer_372 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_370, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_372, !noalias !2
        %Exception_2362_pointer_373 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_370, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_373, !noalias !2
        
        %tag_374 = extractvalue %Pos %v_r_2677_3467, 0
        %fields_375 = extractvalue %Pos %v_r_2677_3467, 1
        switch i64 %tag_374, label %label_376 [i64 0, label %label_380 i64 1, label %label_386]
    
    label_376:
        
        ret void
    
    label_380:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4577 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_378 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_379 = getelementptr %FrameHeader, %StackPointer %stackPointer_378, i64 0, i32 0
        %returnAddress_377 = load %ReturnAddress, ptr %returnAddress_pointer_379, !noalias !2
        musttail call tailcc void %returnAddress_377(i64 %pureApp_4577, %Stack %stack)
        ret void
    
    label_386:
        
        %make_4578_temporary_381 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4578 = insertvalue %Pos %make_4578_temporary_381, %Object null, 1
        
        
        
        %pureApp_4579 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4581 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4581.lit)
        
        %pureApp_4580 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4581, %Pos %pureApp_4579)
        
        
        
        %utf8StringLiteral_4583 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4583.lit)
        
        %pureApp_4582 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4580, %Pos %utf8StringLiteral_4583)
        
        
        
        %pureApp_4584 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4582, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4586 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4586.lit)
        
        %pureApp_4585 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4584, %Pos %utf8StringLiteral_4586)
        
        
        
        %vtable_382 = extractvalue %Neg %Exception_2362, 0
        %closure_383 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_384 = getelementptr ptr, ptr %vtable_382, i64 0
        %functionPointer_385 = load ptr, ptr %functionPointer_pointer_384, !noalias !2
        musttail call tailcc void %functionPointer_385(%Object %closure_383, %Pos %make_4578, %Pos %pureApp_4585, %Stack %stack)
        ret void
}



define ccc void @sharer_390(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_391 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_387_pointer_392 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_391, i64 0, i32 0
        %str_2106_387 = load %Pos, ptr %str_2106_387_pointer_392, !noalias !2
        %index_2107_388_pointer_393 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_391, i64 0, i32 1
        %index_2107_388 = load i64, ptr %index_2107_388_pointer_393, !noalias !2
        %Exception_2362_389_pointer_394 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_391, i64 0, i32 2
        %Exception_2362_389 = load %Neg, ptr %Exception_2362_389_pointer_394, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_387)
        call ccc void @shareNegative(%Neg %Exception_2362_389)
        call ccc void @shareFrames(%StackPointer %stackPointer_391)
        ret void
}



define ccc void @eraser_398(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_399 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_395_pointer_400 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_399, i64 0, i32 0
        %str_2106_395 = load %Pos, ptr %str_2106_395_pointer_400, !noalias !2
        %index_2107_396_pointer_401 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_399, i64 0, i32 1
        %index_2107_396 = load i64, ptr %index_2107_396_pointer_401, !noalias !2
        %Exception_2362_397_pointer_402 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_399, i64 0, i32 2
        %Exception_2362_397 = load %Neg, ptr %Exception_2362_397_pointer_402, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_395)
        call ccc void @eraseNegative(%Neg %Exception_2362_397)
        call ccc void @eraseFrames(%StackPointer %stackPointer_399)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4576 = add i64 0, 0
        
        %pureApp_4575 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4576)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_403 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_404 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_403, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_404, !noalias !2
        %index_2107_pointer_405 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_403, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_405, !noalias !2
        %Exception_2362_pointer_406 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_403, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_406, !noalias !2
        %returnAddress_pointer_407 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 0
        %sharer_pointer_408 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 1
        %eraser_pointer_409 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 2
        store ptr @returnAddress_369, ptr %returnAddress_pointer_407, !noalias !2
        store ptr @sharer_390, ptr %sharer_pointer_408, !noalias !2
        store ptr @eraser_398, ptr %eraser_pointer_409, !noalias !2
        
        %tag_410 = extractvalue %Pos %pureApp_4575, 0
        %fields_411 = extractvalue %Pos %pureApp_4575, 1
        switch i64 %tag_410, label %label_412 [i64 0, label %label_416 i64 1, label %label_421]
    
    label_412:
        
        ret void
    
    label_416:
        
        %pureApp_4587 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4588 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4587)
        
        
        
        %stackPointer_414 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_415 = getelementptr %FrameHeader, %StackPointer %stackPointer_414, i64 0, i32 0
        %returnAddress_413 = load %ReturnAddress, ptr %returnAddress_pointer_415, !noalias !2
        musttail call tailcc void %returnAddress_413(%Pos %pureApp_4588, %Stack %stack)
        ret void
    
    label_421:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4589_temporary_417 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4589 = insertvalue %Pos %booleanLiteral_4589_temporary_417, %Object null, 1
        
        %stackPointer_419 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_420 = getelementptr %FrameHeader, %StackPointer %stackPointer_419, i64 0, i32 0
        %returnAddress_418 = load %ReturnAddress, ptr %returnAddress_pointer_420, !noalias !2
        musttail call tailcc void %returnAddress_418(%Pos %booleanLiteral_4589, %Stack %stack)
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
        
        musttail call tailcc void @main_2437(%Stack %stack)
        ret void
}
