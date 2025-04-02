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



define tailcc void @returnAddress_2(i64 %r_2436, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4496 = call ccc %Pos @show_14(i64 %r_2436)
        
        
        
        %pureApp_4497 = call ccc %Pos @println_1(%Pos %pureApp_4496)
        
        
        
        %stackPointer_4 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_5 = getelementptr %FrameHeader, %StackPointer %stackPointer_4, i64 0, i32 0
        %returnAddress_3 = load %ReturnAddress, ptr %returnAddress_pointer_5, !noalias !2
        musttail call tailcc void %returnAddress_3(%Pos %pureApp_4497, %Stack %stack)
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



define tailcc void @returnAddress_1(%Pos %v_coe_3395_3459, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4495 = call ccc i64 @unboxInt_303(%Pos %v_coe_3395_3459)
        
        
        %stackPointer_10 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 0
        %sharer_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 1
        %eraser_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_11, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_12, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_13, !noalias !2
        
        
        
        musttail call tailcc void @fibonacci_2433(i64 %pureApp_4495, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_19(%Pos %returned_4498, %Stack %stack) {
        
    entry:
        
        %stack_20 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_22 = call ccc %StackPointer @stackDeallocate(%Stack %stack_20, i64 24)
        %returnAddress_pointer_23 = getelementptr %FrameHeader, %StackPointer %stackPointer_22, i64 0, i32 0
        %returnAddress_21 = load %ReturnAddress, ptr %returnAddress_pointer_23, !noalias !2
        musttail call tailcc void %returnAddress_21(%Pos %returned_4498, %Stack %stack_20)
        ret void
}



define ccc void @sharer_24(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_25 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_26(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_27 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_27)
        ret void
}



define ccc void @eraser_39(%Environment %environment) {
        
    entry:
        
        %tmp_4435_37_pointer_40 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4435_37 = load %Pos, ptr %tmp_4435_37_pointer_40, !noalias !2
        %acc_3_3_5_169_4237_38_pointer_41 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4237_38 = load %Pos, ptr %acc_3_3_5_169_4237_38_pointer_41, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4435_37)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4237_38)
        ret void
}



define tailcc void @toList_1_1_3_167_4303(i64 %start_2_2_4_168_4268, %Pos %acc_3_3_5_169_4237, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4500 = add i64 1, 0
        
        %pureApp_4499 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4268, i64 %longLiteral_4500)
        
        
        
        %tag_32 = extractvalue %Pos %pureApp_4499, 0
        %fields_33 = extractvalue %Pos %pureApp_4499, 1
        switch i64 %tag_32, label %label_34 [i64 0, label %label_45 i64 1, label %label_49]
    
    label_34:
        
        ret void
    
    label_45:
        
        %pureApp_4501 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4268)
        
        
        
        %longLiteral_4503 = add i64 1, 0
        
        %pureApp_4502 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4268, i64 %longLiteral_4503)
        
        
        
        %fields_35 = call ccc %Object @newObject(ptr @eraser_39, i64 32)
        %environment_36 = call ccc %Environment @objectEnvironment(%Object %fields_35)
        %tmp_4435_pointer_42 = getelementptr <{%Pos, %Pos}>, %Environment %environment_36, i64 0, i32 0
        store %Pos %pureApp_4501, ptr %tmp_4435_pointer_42, !noalias !2
        %acc_3_3_5_169_4237_pointer_43 = getelementptr <{%Pos, %Pos}>, %Environment %environment_36, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4237, ptr %acc_3_3_5_169_4237_pointer_43, !noalias !2
        %make_4504_temporary_44 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4504 = insertvalue %Pos %make_4504_temporary_44, %Object %fields_35, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4303(i64 %pureApp_4502, %Pos %make_4504, %Stack %stack)
        ret void
    
    label_49:
        
        %stackPointer_47 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_48 = getelementptr %FrameHeader, %StackPointer %stackPointer_47, i64 0, i32 0
        %returnAddress_46 = load %ReturnAddress, ptr %returnAddress_pointer_48, !noalias !2
        musttail call tailcc void %returnAddress_46(%Pos %acc_3_3_5_169_4237, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_60(%Pos %v_r_2552_32_59_223_4122, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_61 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_4442_pointer_62 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_61, i64 0, i32 0
        %tmp_4442 = load i64, ptr %tmp_4442_pointer_62, !noalias !2
        %v_r_2468_30_194_4251_pointer_63 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_61, i64 0, i32 1
        %v_r_2468_30_194_4251 = load %Pos, ptr %v_r_2468_30_194_4251_pointer_63, !noalias !2
        %acc_8_35_199_4265_pointer_64 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_61, i64 0, i32 2
        %acc_8_35_199_4265 = load i64, ptr %acc_8_35_199_4265_pointer_64, !noalias !2
        %index_7_34_198_4037_pointer_65 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_61, i64 0, i32 3
        %index_7_34_198_4037 = load i64, ptr %index_7_34_198_4037_pointer_65, !noalias !2
        %p_8_9_4000_pointer_66 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_61, i64 0, i32 4
        %p_8_9_4000 = load %Prompt, ptr %p_8_9_4000_pointer_66, !noalias !2
        
        %tag_67 = extractvalue %Pos %v_r_2552_32_59_223_4122, 0
        %fields_68 = extractvalue %Pos %v_r_2552_32_59_223_4122, 1
        switch i64 %tag_67, label %label_69 [i64 1, label %label_92 i64 0, label %label_99]
    
    label_69:
        
        ret void
    
    label_74:
        
        ret void
    
    label_80:
        call ccc void @erasePositive(%Pos %v_r_2468_30_194_4251)
        
        %pair_75 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4000)
        %k_13_14_4_4370 = extractvalue <{%Resumption, %Stack}> %pair_75, 0
        %stack_76 = extractvalue <{%Resumption, %Stack}> %pair_75, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4370)
        
        %longLiteral_4516 = add i64 5, 0
        
        
        
        %pureApp_4517 = call ccc %Pos @boxInt_301(i64 %longLiteral_4516)
        
        
        
        %stackPointer_78 = call ccc %StackPointer @stackDeallocate(%Stack %stack_76, i64 24)
        %returnAddress_pointer_79 = getelementptr %FrameHeader, %StackPointer %stackPointer_78, i64 0, i32 0
        %returnAddress_77 = load %ReturnAddress, ptr %returnAddress_pointer_79, !noalias !2
        musttail call tailcc void %returnAddress_77(%Pos %pureApp_4517, %Stack %stack_76)
        ret void
    
    label_83:
        
        ret void
    
    label_89:
        call ccc void @erasePositive(%Pos %v_r_2468_30_194_4251)
        
        %pair_84 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4000)
        %k_13_14_4_4369 = extractvalue <{%Resumption, %Stack}> %pair_84, 0
        %stack_85 = extractvalue <{%Resumption, %Stack}> %pair_84, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4369)
        
        %longLiteral_4520 = add i64 5, 0
        
        
        
        %pureApp_4521 = call ccc %Pos @boxInt_301(i64 %longLiteral_4520)
        
        
        
        %stackPointer_87 = call ccc %StackPointer @stackDeallocate(%Stack %stack_85, i64 24)
        %returnAddress_pointer_88 = getelementptr %FrameHeader, %StackPointer %stackPointer_87, i64 0, i32 0
        %returnAddress_86 = load %ReturnAddress, ptr %returnAddress_pointer_88, !noalias !2
        musttail call tailcc void %returnAddress_86(%Pos %pureApp_4521, %Stack %stack_85)
        ret void
    
    label_90:
        
        %longLiteral_4523 = add i64 1, 0
        
        %pureApp_4522 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4037, i64 %longLiteral_4523)
        
        
        
        %longLiteral_4525 = add i64 10, 0
        
        %pureApp_4524 = call ccc i64 @infixMul_99(i64 %longLiteral_4525, i64 %acc_8_35_199_4265)
        
        
        
        %pureApp_4526 = call ccc i64 @toInt_2085(i64 %pureApp_4513)
        
        
        
        %pureApp_4527 = call ccc i64 @infixSub_105(i64 %pureApp_4526, i64 %tmp_4442)
        
        
        
        %pureApp_4528 = call ccc i64 @infixAdd_96(i64 %pureApp_4524, i64 %pureApp_4527)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4275(i64 %pureApp_4522, i64 %pureApp_4528, i64 %tmp_4442, %Pos %v_r_2468_30_194_4251, %Prompt %p_8_9_4000, %Stack %stack)
        ret void
    
    label_91:
        
        %intLiteral_4519 = add i64 57, 0
        
        %pureApp_4518 = call ccc %Pos @infixLte_2093(i64 %pureApp_4513, i64 %intLiteral_4519)
        
        
        
        %tag_81 = extractvalue %Pos %pureApp_4518, 0
        %fields_82 = extractvalue %Pos %pureApp_4518, 1
        switch i64 %tag_81, label %label_83 [i64 0, label %label_89 i64 1, label %label_90]
    
    label_92:
        %environment_70 = call ccc %Environment @objectEnvironment(%Object %fields_68)
        %v_coe_3370_46_73_237_4080_pointer_71 = getelementptr <{%Pos}>, %Environment %environment_70, i64 0, i32 0
        %v_coe_3370_46_73_237_4080 = load %Pos, ptr %v_coe_3370_46_73_237_4080_pointer_71, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3370_46_73_237_4080)
        call ccc void @eraseObject(%Object %fields_68)
        
        %pureApp_4513 = call ccc i64 @unboxChar_313(%Pos %v_coe_3370_46_73_237_4080)
        
        
        
        %intLiteral_4515 = add i64 48, 0
        
        %pureApp_4514 = call ccc %Pos @infixGte_2099(i64 %pureApp_4513, i64 %intLiteral_4515)
        
        
        
        %tag_72 = extractvalue %Pos %pureApp_4514, 0
        %fields_73 = extractvalue %Pos %pureApp_4514, 1
        switch i64 %tag_72, label %label_74 [i64 0, label %label_80 i64 1, label %label_91]
    
    label_99:
        %environment_93 = call ccc %Environment @objectEnvironment(%Object %fields_68)
        %v_y_2559_76_103_267_4511_pointer_94 = getelementptr <{%Pos, %Pos}>, %Environment %environment_93, i64 0, i32 0
        %v_y_2559_76_103_267_4511 = load %Pos, ptr %v_y_2559_76_103_267_4511_pointer_94, !noalias !2
        %v_y_2560_77_104_268_4512_pointer_95 = getelementptr <{%Pos, %Pos}>, %Environment %environment_93, i64 0, i32 1
        %v_y_2560_77_104_268_4512 = load %Pos, ptr %v_y_2560_77_104_268_4512_pointer_95, !noalias !2
        call ccc void @eraseObject(%Object %fields_68)
        call ccc void @erasePositive(%Pos %v_r_2468_30_194_4251)
        
        %stackPointer_97 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_98 = getelementptr %FrameHeader, %StackPointer %stackPointer_97, i64 0, i32 0
        %returnAddress_96 = load %ReturnAddress, ptr %returnAddress_pointer_98, !noalias !2
        musttail call tailcc void %returnAddress_96(i64 %acc_8_35_199_4265, %Stack %stack)
        ret void
}



define ccc void @sharer_105(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_106 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4442_100_pointer_107 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_106, i64 0, i32 0
        %tmp_4442_100 = load i64, ptr %tmp_4442_100_pointer_107, !noalias !2
        %v_r_2468_30_194_4251_101_pointer_108 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_106, i64 0, i32 1
        %v_r_2468_30_194_4251_101 = load %Pos, ptr %v_r_2468_30_194_4251_101_pointer_108, !noalias !2
        %acc_8_35_199_4265_102_pointer_109 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_106, i64 0, i32 2
        %acc_8_35_199_4265_102 = load i64, ptr %acc_8_35_199_4265_102_pointer_109, !noalias !2
        %index_7_34_198_4037_103_pointer_110 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_106, i64 0, i32 3
        %index_7_34_198_4037_103 = load i64, ptr %index_7_34_198_4037_103_pointer_110, !noalias !2
        %p_8_9_4000_104_pointer_111 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_106, i64 0, i32 4
        %p_8_9_4000_104 = load %Prompt, ptr %p_8_9_4000_104_pointer_111, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2468_30_194_4251_101)
        call ccc void @shareFrames(%StackPointer %stackPointer_106)
        ret void
}



define ccc void @eraser_117(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_118 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4442_112_pointer_119 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_118, i64 0, i32 0
        %tmp_4442_112 = load i64, ptr %tmp_4442_112_pointer_119, !noalias !2
        %v_r_2468_30_194_4251_113_pointer_120 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_118, i64 0, i32 1
        %v_r_2468_30_194_4251_113 = load %Pos, ptr %v_r_2468_30_194_4251_113_pointer_120, !noalias !2
        %acc_8_35_199_4265_114_pointer_121 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_118, i64 0, i32 2
        %acc_8_35_199_4265_114 = load i64, ptr %acc_8_35_199_4265_114_pointer_121, !noalias !2
        %index_7_34_198_4037_115_pointer_122 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_118, i64 0, i32 3
        %index_7_34_198_4037_115 = load i64, ptr %index_7_34_198_4037_115_pointer_122, !noalias !2
        %p_8_9_4000_116_pointer_123 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_118, i64 0, i32 4
        %p_8_9_4000_116 = load %Prompt, ptr %p_8_9_4000_116_pointer_123, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2468_30_194_4251_113)
        call ccc void @eraseFrames(%StackPointer %stackPointer_118)
        ret void
}



define tailcc void @returnAddress_134(%Pos %returned_4529, %Stack %stack) {
        
    entry:
        
        %stack_135 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_137 = call ccc %StackPointer @stackDeallocate(%Stack %stack_135, i64 24)
        %returnAddress_pointer_138 = getelementptr %FrameHeader, %StackPointer %stackPointer_137, i64 0, i32 0
        %returnAddress_136 = load %ReturnAddress, ptr %returnAddress_pointer_138, !noalias !2
        musttail call tailcc void %returnAddress_136(%Pos %returned_4529, %Stack %stack_135)
        ret void
}



define tailcc void @Exception_7_19_46_210_4317_clause_143(%Object %closure, %Pos %exc_8_20_47_211_4087, %Pos %msg_9_21_48_212_4045, %Stack %stack) {
        
    entry:
        
        %environment_144 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4138_pointer_145 = getelementptr <{%Prompt}>, %Environment %environment_144, i64 0, i32 0
        %p_6_18_45_209_4138 = load %Prompt, ptr %p_6_18_45_209_4138_pointer_145, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_146 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4138)
        %k_11_23_50_214_4325 = extractvalue <{%Resumption, %Stack}> %pair_146, 0
        %stack_147 = extractvalue <{%Resumption, %Stack}> %pair_146, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4325)
        
        %fields_148 = call ccc %Object @newObject(ptr @eraser_39, i64 32)
        %environment_149 = call ccc %Environment @objectEnvironment(%Object %fields_148)
        %exc_8_20_47_211_4087_pointer_152 = getelementptr <{%Pos, %Pos}>, %Environment %environment_149, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4087, ptr %exc_8_20_47_211_4087_pointer_152, !noalias !2
        %msg_9_21_48_212_4045_pointer_153 = getelementptr <{%Pos, %Pos}>, %Environment %environment_149, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4045, ptr %msg_9_21_48_212_4045_pointer_153, !noalias !2
        %make_4530_temporary_154 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4530 = insertvalue %Pos %make_4530_temporary_154, %Object %fields_148, 1
        
        
        
        %stackPointer_156 = call ccc %StackPointer @stackDeallocate(%Stack %stack_147, i64 24)
        %returnAddress_pointer_157 = getelementptr %FrameHeader, %StackPointer %stackPointer_156, i64 0, i32 0
        %returnAddress_155 = load %ReturnAddress, ptr %returnAddress_pointer_157, !noalias !2
        musttail call tailcc void %returnAddress_155(%Pos %make_4530, %Stack %stack_147)
        ret void
}


@vtable_158 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4317_clause_143]


define ccc void @eraser_162(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4138_161_pointer_163 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4138_161 = load %Prompt, ptr %p_6_18_45_209_4138_161_pointer_163, !noalias !2
        ret void
}



define ccc void @eraser_170(%Environment %environment) {
        
    entry:
        
        %tmp_4444_169_pointer_171 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4444_169 = load %Pos, ptr %tmp_4444_169_pointer_171, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4444_169)
        ret void
}



define tailcc void @returnAddress_166(i64 %v_coe_3369_6_28_55_219_4243, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4531 = call ccc %Pos @boxChar_311(i64 %v_coe_3369_6_28_55_219_4243)
        
        
        
        %fields_167 = call ccc %Object @newObject(ptr @eraser_170, i64 16)
        %environment_168 = call ccc %Environment @objectEnvironment(%Object %fields_167)
        %tmp_4444_pointer_172 = getelementptr <{%Pos}>, %Environment %environment_168, i64 0, i32 0
        store %Pos %pureApp_4531, ptr %tmp_4444_pointer_172, !noalias !2
        %make_4532_temporary_173 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4532 = insertvalue %Pos %make_4532_temporary_173, %Object %fields_167, 1
        
        
        
        %stackPointer_175 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_176 = getelementptr %FrameHeader, %StackPointer %stackPointer_175, i64 0, i32 0
        %returnAddress_174 = load %ReturnAddress, ptr %returnAddress_pointer_176, !noalias !2
        musttail call tailcc void %returnAddress_174(%Pos %make_4532, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4275(i64 %index_7_34_198_4037, i64 %acc_8_35_199_4265, i64 %tmp_4442, %Pos %v_r_2468_30_194_4251, %Prompt %p_8_9_4000, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2468_30_194_4251)
        %stackPointer_124 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_4442_pointer_125 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_124, i64 0, i32 0
        store i64 %tmp_4442, ptr %tmp_4442_pointer_125, !noalias !2
        %v_r_2468_30_194_4251_pointer_126 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_124, i64 0, i32 1
        store %Pos %v_r_2468_30_194_4251, ptr %v_r_2468_30_194_4251_pointer_126, !noalias !2
        %acc_8_35_199_4265_pointer_127 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_124, i64 0, i32 2
        store i64 %acc_8_35_199_4265, ptr %acc_8_35_199_4265_pointer_127, !noalias !2
        %index_7_34_198_4037_pointer_128 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_124, i64 0, i32 3
        store i64 %index_7_34_198_4037, ptr %index_7_34_198_4037_pointer_128, !noalias !2
        %p_8_9_4000_pointer_129 = getelementptr <{i64, %Pos, i64, i64, %Prompt}>, %StackPointer %stackPointer_124, i64 0, i32 4
        store %Prompt %p_8_9_4000, ptr %p_8_9_4000_pointer_129, !noalias !2
        %returnAddress_pointer_130 = getelementptr <{<{i64, %Pos, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_124, i64 0, i32 1, i32 0
        %sharer_pointer_131 = getelementptr <{<{i64, %Pos, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_124, i64 0, i32 1, i32 1
        %eraser_pointer_132 = getelementptr <{<{i64, %Pos, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_124, i64 0, i32 1, i32 2
        store ptr @returnAddress_60, ptr %returnAddress_pointer_130, !noalias !2
        store ptr @sharer_105, ptr %sharer_pointer_131, !noalias !2
        store ptr @eraser_117, ptr %eraser_pointer_132, !noalias !2
        
        %stack_133 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4138 = call ccc %Prompt @currentPrompt(%Stack %stack_133)
        %stackPointer_139 = call ccc %StackPointer @stackAllocate(%Stack %stack_133, i64 24)
        %returnAddress_pointer_140 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_139, i64 0, i32 1, i32 0
        %sharer_pointer_141 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_139, i64 0, i32 1, i32 1
        %eraser_pointer_142 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_139, i64 0, i32 1, i32 2
        store ptr @returnAddress_134, ptr %returnAddress_pointer_140, !noalias !2
        store ptr @sharer_24, ptr %sharer_pointer_141, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_142, !noalias !2
        
        %closure_159 = call ccc %Object @newObject(ptr @eraser_162, i64 8)
        %environment_160 = call ccc %Environment @objectEnvironment(%Object %closure_159)
        %p_6_18_45_209_4138_pointer_164 = getelementptr <{%Prompt}>, %Environment %environment_160, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4138, ptr %p_6_18_45_209_4138_pointer_164, !noalias !2
        %vtable_temporary_165 = insertvalue %Neg zeroinitializer, ptr @vtable_158, 0
        %Exception_7_19_46_210_4317 = insertvalue %Neg %vtable_temporary_165, %Object %closure_159, 1
        %stackPointer_177 = call ccc %StackPointer @stackAllocate(%Stack %stack_133, i64 24)
        %returnAddress_pointer_178 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_177, i64 0, i32 1, i32 0
        %sharer_pointer_179 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_177, i64 0, i32 1, i32 1
        %eraser_pointer_180 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_177, i64 0, i32 1, i32 2
        store ptr @returnAddress_166, ptr %returnAddress_pointer_178, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_179, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_180, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2468_30_194_4251, i64 %index_7_34_198_4037, %Neg %Exception_7_19_46_210_4317, %Stack %stack_133)
        ret void
}



define tailcc void @Exception_9_106_133_297_4029_clause_181(%Object %closure, %Pos %exception_10_107_134_298_4533, %Pos %msg_11_108_135_299_4534, %Stack %stack) {
        
    entry:
        
        %environment_182 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4000_pointer_183 = getelementptr <{%Prompt}>, %Environment %environment_182, i64 0, i32 0
        %p_8_9_4000 = load %Prompt, ptr %p_8_9_4000_pointer_183, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4533)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4534)
        
        %pair_184 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4000)
        %k_13_14_4_4421 = extractvalue <{%Resumption, %Stack}> %pair_184, 0
        %stack_185 = extractvalue <{%Resumption, %Stack}> %pair_184, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4421)
        
        %longLiteral_4535 = add i64 5, 0
        
        
        
        %pureApp_4536 = call ccc %Pos @boxInt_301(i64 %longLiteral_4535)
        
        
        
        %stackPointer_187 = call ccc %StackPointer @stackDeallocate(%Stack %stack_185, i64 24)
        %returnAddress_pointer_188 = getelementptr %FrameHeader, %StackPointer %stackPointer_187, i64 0, i32 0
        %returnAddress_186 = load %ReturnAddress, ptr %returnAddress_pointer_188, !noalias !2
        musttail call tailcc void %returnAddress_186(%Pos %pureApp_4536, %Stack %stack_185)
        ret void
}


@vtable_189 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4029_clause_181]


define tailcc void @returnAddress_200(i64 %v_coe_3374_22_131_158_322_4203, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4539 = call ccc %Pos @boxInt_301(i64 %v_coe_3374_22_131_158_322_4203)
        
        
        
        
        
        %pureApp_4540 = call ccc i64 @unboxInt_303(%Pos %pureApp_4539)
        
        
        
        %pureApp_4541 = call ccc %Pos @boxInt_301(i64 %pureApp_4540)
        
        
        
        %stackPointer_202 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_203 = getelementptr %FrameHeader, %StackPointer %stackPointer_202, i64 0, i32 0
        %returnAddress_201 = load %ReturnAddress, ptr %returnAddress_pointer_203, !noalias !2
        musttail call tailcc void %returnAddress_201(%Pos %pureApp_4541, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_212(i64 %v_r_2566_1_9_20_129_156_320_4074, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4545 = add i64 0, 0
        
        %pureApp_4544 = call ccc i64 @infixSub_105(i64 %longLiteral_4545, i64 %v_r_2566_1_9_20_129_156_320_4074)
        
        
        
        %stackPointer_214 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_215 = getelementptr %FrameHeader, %StackPointer %stackPointer_214, i64 0, i32 0
        %returnAddress_213 = load %ReturnAddress, ptr %returnAddress_pointer_215, !noalias !2
        musttail call tailcc void %returnAddress_213(i64 %pureApp_4544, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_195(i64 %v_r_2565_3_14_123_150_314_4306, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_196 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_4442_pointer_197 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_196, i64 0, i32 0
        %tmp_4442 = load i64, ptr %tmp_4442_pointer_197, !noalias !2
        %v_r_2468_30_194_4251_pointer_198 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_196, i64 0, i32 1
        %v_r_2468_30_194_4251 = load %Pos, ptr %v_r_2468_30_194_4251_pointer_198, !noalias !2
        %p_8_9_4000_pointer_199 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_196, i64 0, i32 2
        %p_8_9_4000 = load %Prompt, ptr %p_8_9_4000_pointer_199, !noalias !2
        
        %intLiteral_4538 = add i64 45, 0
        
        %pureApp_4537 = call ccc %Pos @infixEq_78(i64 %v_r_2565_3_14_123_150_314_4306, i64 %intLiteral_4538)
        
        
        %stackPointer_204 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_205 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_204, i64 0, i32 1, i32 0
        %sharer_pointer_206 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_204, i64 0, i32 1, i32 1
        %eraser_pointer_207 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_204, i64 0, i32 1, i32 2
        store ptr @returnAddress_200, ptr %returnAddress_pointer_205, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_206, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_207, !noalias !2
        
        %tag_208 = extractvalue %Pos %pureApp_4537, 0
        %fields_209 = extractvalue %Pos %pureApp_4537, 1
        switch i64 %tag_208, label %label_210 [i64 0, label %label_211 i64 1, label %label_220]
    
    label_210:
        
        ret void
    
    label_211:
        
        %longLiteral_4542 = add i64 0, 0
        
        %longLiteral_4543 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4275(i64 %longLiteral_4542, i64 %longLiteral_4543, i64 %tmp_4442, %Pos %v_r_2468_30_194_4251, %Prompt %p_8_9_4000, %Stack %stack)
        ret void
    
    label_220:
        %stackPointer_216 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_217 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_216, i64 0, i32 1, i32 0
        %sharer_pointer_218 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_216, i64 0, i32 1, i32 1
        %eraser_pointer_219 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_216, i64 0, i32 1, i32 2
        store ptr @returnAddress_212, ptr %returnAddress_pointer_217, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_218, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_219, !noalias !2
        
        %longLiteral_4546 = add i64 1, 0
        
        %longLiteral_4547 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4275(i64 %longLiteral_4546, i64 %longLiteral_4547, i64 %tmp_4442, %Pos %v_r_2468_30_194_4251, %Prompt %p_8_9_4000, %Stack %stack)
        ret void
}



define ccc void @sharer_224(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_225 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4442_221_pointer_226 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_225, i64 0, i32 0
        %tmp_4442_221 = load i64, ptr %tmp_4442_221_pointer_226, !noalias !2
        %v_r_2468_30_194_4251_222_pointer_227 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_225, i64 0, i32 1
        %v_r_2468_30_194_4251_222 = load %Pos, ptr %v_r_2468_30_194_4251_222_pointer_227, !noalias !2
        %p_8_9_4000_223_pointer_228 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_225, i64 0, i32 2
        %p_8_9_4000_223 = load %Prompt, ptr %p_8_9_4000_223_pointer_228, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2468_30_194_4251_222)
        call ccc void @shareFrames(%StackPointer %stackPointer_225)
        ret void
}



define ccc void @eraser_232(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_233 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4442_229_pointer_234 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_233, i64 0, i32 0
        %tmp_4442_229 = load i64, ptr %tmp_4442_229_pointer_234, !noalias !2
        %v_r_2468_30_194_4251_230_pointer_235 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_233, i64 0, i32 1
        %v_r_2468_30_194_4251_230 = load %Pos, ptr %v_r_2468_30_194_4251_230_pointer_235, !noalias !2
        %p_8_9_4000_231_pointer_236 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_233, i64 0, i32 2
        %p_8_9_4000_231 = load %Prompt, ptr %p_8_9_4000_231_pointer_236, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2468_30_194_4251_230)
        call ccc void @eraseFrames(%StackPointer %stackPointer_233)
        ret void
}



define tailcc void @returnAddress_57(%Pos %v_r_2468_30_194_4251, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_58 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4000_pointer_59 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_58, i64 0, i32 0
        %p_8_9_4000 = load %Prompt, ptr %p_8_9_4000_pointer_59, !noalias !2
        
        %intLiteral_4510 = add i64 48, 0
        
        %pureApp_4509 = call ccc i64 @toInt_2085(i64 %intLiteral_4510)
        
        
        
        %closure_190 = call ccc %Object @newObject(ptr @eraser_162, i64 8)
        %environment_191 = call ccc %Environment @objectEnvironment(%Object %closure_190)
        %p_8_9_4000_pointer_193 = getelementptr <{%Prompt}>, %Environment %environment_191, i64 0, i32 0
        store %Prompt %p_8_9_4000, ptr %p_8_9_4000_pointer_193, !noalias !2
        %vtable_temporary_194 = insertvalue %Neg zeroinitializer, ptr @vtable_189, 0
        %Exception_9_106_133_297_4029 = insertvalue %Neg %vtable_temporary_194, %Object %closure_190, 1
        call ccc void @sharePositive(%Pos %v_r_2468_30_194_4251)
        %stackPointer_237 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_4442_pointer_238 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_237, i64 0, i32 0
        store i64 %pureApp_4509, ptr %tmp_4442_pointer_238, !noalias !2
        %v_r_2468_30_194_4251_pointer_239 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_237, i64 0, i32 1
        store %Pos %v_r_2468_30_194_4251, ptr %v_r_2468_30_194_4251_pointer_239, !noalias !2
        %p_8_9_4000_pointer_240 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_237, i64 0, i32 2
        store %Prompt %p_8_9_4000, ptr %p_8_9_4000_pointer_240, !noalias !2
        %returnAddress_pointer_241 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_237, i64 0, i32 1, i32 0
        %sharer_pointer_242 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_237, i64 0, i32 1, i32 1
        %eraser_pointer_243 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_237, i64 0, i32 1, i32 2
        store ptr @returnAddress_195, ptr %returnAddress_pointer_241, !noalias !2
        store ptr @sharer_224, ptr %sharer_pointer_242, !noalias !2
        store ptr @eraser_232, ptr %eraser_pointer_243, !noalias !2
        
        %longLiteral_4548 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2468_30_194_4251, i64 %longLiteral_4548, %Neg %Exception_9_106_133_297_4029, %Stack %stack)
        ret void
}



define ccc void @sharer_245(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_246 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4000_244_pointer_247 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_246, i64 0, i32 0
        %p_8_9_4000_244 = load %Prompt, ptr %p_8_9_4000_244_pointer_247, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_246)
        ret void
}



define ccc void @eraser_249(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_250 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4000_248_pointer_251 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_250, i64 0, i32 0
        %p_8_9_4000_248 = load %Prompt, ptr %p_8_9_4000_248_pointer_251, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_250)
        ret void
}


@utf8StringLiteral_4549.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_54(%Pos %v_r_2467_24_188_4152, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_55 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4000_pointer_56 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_55, i64 0, i32 0
        %p_8_9_4000 = load %Prompt, ptr %p_8_9_4000_pointer_56, !noalias !2
        %stackPointer_252 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4000_pointer_253 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_252, i64 0, i32 0
        store %Prompt %p_8_9_4000, ptr %p_8_9_4000_pointer_253, !noalias !2
        %returnAddress_pointer_254 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 0
        %sharer_pointer_255 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 1
        %eraser_pointer_256 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 2
        store ptr @returnAddress_57, ptr %returnAddress_pointer_254, !noalias !2
        store ptr @sharer_245, ptr %sharer_pointer_255, !noalias !2
        store ptr @eraser_249, ptr %eraser_pointer_256, !noalias !2
        
        %tag_257 = extractvalue %Pos %v_r_2467_24_188_4152, 0
        %fields_258 = extractvalue %Pos %v_r_2467_24_188_4152, 1
        switch i64 %tag_257, label %label_259 [i64 0, label %label_263 i64 1, label %label_269]
    
    label_259:
        
        ret void
    
    label_263:
        
        %utf8StringLiteral_4549 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4549.lit)
        
        %stackPointer_261 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_262 = getelementptr %FrameHeader, %StackPointer %stackPointer_261, i64 0, i32 0
        %returnAddress_260 = load %ReturnAddress, ptr %returnAddress_pointer_262, !noalias !2
        musttail call tailcc void %returnAddress_260(%Pos %utf8StringLiteral_4549, %Stack %stack)
        ret void
    
    label_269:
        %environment_264 = call ccc %Environment @objectEnvironment(%Object %fields_258)
        %v_y_3196_8_29_193_4053_pointer_265 = getelementptr <{%Pos}>, %Environment %environment_264, i64 0, i32 0
        %v_y_3196_8_29_193_4053 = load %Pos, ptr %v_y_3196_8_29_193_4053_pointer_265, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3196_8_29_193_4053)
        call ccc void @eraseObject(%Object %fields_258)
        
        %stackPointer_267 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_268 = getelementptr %FrameHeader, %StackPointer %stackPointer_267, i64 0, i32 0
        %returnAddress_266 = load %ReturnAddress, ptr %returnAddress_pointer_268, !noalias !2
        musttail call tailcc void %returnAddress_266(%Pos %v_y_3196_8_29_193_4053, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_51(%Pos %v_r_2466_13_177_4213, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_52 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4000_pointer_53 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_52, i64 0, i32 0
        %p_8_9_4000 = load %Prompt, ptr %p_8_9_4000_pointer_53, !noalias !2
        %stackPointer_272 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4000_pointer_273 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_272, i64 0, i32 0
        store %Prompt %p_8_9_4000, ptr %p_8_9_4000_pointer_273, !noalias !2
        %returnAddress_pointer_274 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_272, i64 0, i32 1, i32 0
        %sharer_pointer_275 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_272, i64 0, i32 1, i32 1
        %eraser_pointer_276 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_272, i64 0, i32 1, i32 2
        store ptr @returnAddress_54, ptr %returnAddress_pointer_274, !noalias !2
        store ptr @sharer_245, ptr %sharer_pointer_275, !noalias !2
        store ptr @eraser_249, ptr %eraser_pointer_276, !noalias !2
        
        %tag_277 = extractvalue %Pos %v_r_2466_13_177_4213, 0
        %fields_278 = extractvalue %Pos %v_r_2466_13_177_4213, 1
        switch i64 %tag_277, label %label_279 [i64 0, label %label_284 i64 1, label %label_296]
    
    label_279:
        
        ret void
    
    label_284:
        
        %make_4550_temporary_280 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4550 = insertvalue %Pos %make_4550_temporary_280, %Object null, 1
        
        
        
        %stackPointer_282 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_283 = getelementptr %FrameHeader, %StackPointer %stackPointer_282, i64 0, i32 0
        %returnAddress_281 = load %ReturnAddress, ptr %returnAddress_pointer_283, !noalias !2
        musttail call tailcc void %returnAddress_281(%Pos %make_4550, %Stack %stack)
        ret void
    
    label_296:
        %environment_285 = call ccc %Environment @objectEnvironment(%Object %fields_278)
        %v_y_2705_10_21_185_4311_pointer_286 = getelementptr <{%Pos, %Pos}>, %Environment %environment_285, i64 0, i32 0
        %v_y_2705_10_21_185_4311 = load %Pos, ptr %v_y_2705_10_21_185_4311_pointer_286, !noalias !2
        %v_y_2706_11_22_186_4056_pointer_287 = getelementptr <{%Pos, %Pos}>, %Environment %environment_285, i64 0, i32 1
        %v_y_2706_11_22_186_4056 = load %Pos, ptr %v_y_2706_11_22_186_4056_pointer_287, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2705_10_21_185_4311)
        call ccc void @eraseObject(%Object %fields_278)
        
        %fields_288 = call ccc %Object @newObject(ptr @eraser_170, i64 16)
        %environment_289 = call ccc %Environment @objectEnvironment(%Object %fields_288)
        %v_y_2705_10_21_185_4311_pointer_291 = getelementptr <{%Pos}>, %Environment %environment_289, i64 0, i32 0
        store %Pos %v_y_2705_10_21_185_4311, ptr %v_y_2705_10_21_185_4311_pointer_291, !noalias !2
        %make_4551_temporary_292 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4551 = insertvalue %Pos %make_4551_temporary_292, %Object %fields_288, 1
        
        
        
        %stackPointer_294 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_295 = getelementptr %FrameHeader, %StackPointer %stackPointer_294, i64 0, i32 0
        %returnAddress_293 = load %ReturnAddress, ptr %returnAddress_pointer_295, !noalias !2
        musttail call tailcc void %returnAddress_293(%Pos %make_4551, %Stack %stack)
        ret void
}



define tailcc void @main_2434(%Stack %stack) {
        
    entry:
        
        %stackPointer_14 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_15 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_14, i64 0, i32 1, i32 0
        %sharer_pointer_16 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_14, i64 0, i32 1, i32 1
        %eraser_pointer_17 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_14, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_15, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_16, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_17, !noalias !2
        
        %stack_18 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4000 = call ccc %Prompt @currentPrompt(%Stack %stack_18)
        %stackPointer_28 = call ccc %StackPointer @stackAllocate(%Stack %stack_18, i64 24)
        %returnAddress_pointer_29 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_28, i64 0, i32 1, i32 0
        %sharer_pointer_30 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_28, i64 0, i32 1, i32 1
        %eraser_pointer_31 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_28, i64 0, i32 1, i32 2
        store ptr @returnAddress_19, ptr %returnAddress_pointer_29, !noalias !2
        store ptr @sharer_24, ptr %sharer_pointer_30, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_31, !noalias !2
        
        %pureApp_4505 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4507 = add i64 1, 0
        
        %pureApp_4506 = call ccc i64 @infixSub_105(i64 %pureApp_4505, i64 %longLiteral_4507)
        
        
        
        %make_4508_temporary_50 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4508 = insertvalue %Pos %make_4508_temporary_50, %Object null, 1
        
        
        %stackPointer_299 = call ccc %StackPointer @stackAllocate(%Stack %stack_18, i64 32)
        %p_8_9_4000_pointer_300 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_299, i64 0, i32 0
        store %Prompt %p_8_9_4000, ptr %p_8_9_4000_pointer_300, !noalias !2
        %returnAddress_pointer_301 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_299, i64 0, i32 1, i32 0
        %sharer_pointer_302 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_299, i64 0, i32 1, i32 1
        %eraser_pointer_303 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_299, i64 0, i32 1, i32 2
        store ptr @returnAddress_51, ptr %returnAddress_pointer_301, !noalias !2
        store ptr @sharer_245, ptr %sharer_pointer_302, !noalias !2
        store ptr @eraser_249, ptr %eraser_pointer_303, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4303(i64 %pureApp_4506, %Pos %make_4508, %Stack %stack_18)
        ret void
}



define tailcc void @returnAddress_313(i64 %v_r_2463_3462, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_314 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2462_3461_pointer_315 = getelementptr <{i64}>, %StackPointer %stackPointer_314, i64 0, i32 0
        %v_r_2462_3461 = load i64, ptr %v_r_2462_3461_pointer_315, !noalias !2
        
        %pureApp_4492 = call ccc i64 @infixAdd_96(i64 %v_r_2462_3461, i64 %v_r_2463_3462)
        
        
        
        %stackPointer_317 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_318 = getelementptr %FrameHeader, %StackPointer %stackPointer_317, i64 0, i32 0
        %returnAddress_316 = load %ReturnAddress, ptr %returnAddress_pointer_318, !noalias !2
        musttail call tailcc void %returnAddress_316(i64 %pureApp_4492, %Stack %stack)
        ret void
}



define ccc void @sharer_320(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_321 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2462_3461_319_pointer_322 = getelementptr <{i64}>, %StackPointer %stackPointer_321, i64 0, i32 0
        %v_r_2462_3461_319 = load i64, ptr %v_r_2462_3461_319_pointer_322, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_321)
        ret void
}



define ccc void @eraser_324(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_325 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2462_3461_323_pointer_326 = getelementptr <{i64}>, %StackPointer %stackPointer_325, i64 0, i32 0
        %v_r_2462_3461_323 = load i64, ptr %v_r_2462_3461_323_pointer_326, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_325)
        ret void
}



define tailcc void @returnAddress_310(i64 %v_r_2462_3461, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_311 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %n_2432_pointer_312 = getelementptr <{i64}>, %StackPointer %stackPointer_311, i64 0, i32 0
        %n_2432 = load i64, ptr %n_2432_pointer_312, !noalias !2
        
        %longLiteral_4491 = add i64 2, 0
        
        %pureApp_4490 = call ccc i64 @infixSub_105(i64 %n_2432, i64 %longLiteral_4491)
        
        
        %stackPointer_327 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2462_3461_pointer_328 = getelementptr <{i64}>, %StackPointer %stackPointer_327, i64 0, i32 0
        store i64 %v_r_2462_3461, ptr %v_r_2462_3461_pointer_328, !noalias !2
        %returnAddress_pointer_329 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_327, i64 0, i32 1, i32 0
        %sharer_pointer_330 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_327, i64 0, i32 1, i32 1
        %eraser_pointer_331 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_327, i64 0, i32 1, i32 2
        store ptr @returnAddress_313, ptr %returnAddress_pointer_329, !noalias !2
        store ptr @sharer_320, ptr %sharer_pointer_330, !noalias !2
        store ptr @eraser_324, ptr %eraser_pointer_331, !noalias !2
        
        
        
        musttail call tailcc void @fibonacci_2433(i64 %pureApp_4490, %Stack %stack)
        ret void
}



define tailcc void @fibonacci_2433(i64 %n_2432, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4485 = add i64 0, 0
        
        %pureApp_4484 = call ccc %Pos @infixEq_72(i64 %n_2432, i64 %longLiteral_4485)
        
        
        
        %tag_304 = extractvalue %Pos %pureApp_4484, 0
        %fields_305 = extractvalue %Pos %pureApp_4484, 1
        switch i64 %tag_304, label %label_306 [i64 0, label %label_344 i64 1, label %label_348]
    
    label_306:
        
        ret void
    
    label_309:
        
        ret void
    
    label_339:
        
        %longLiteral_4489 = add i64 1, 0
        
        %pureApp_4488 = call ccc i64 @infixSub_105(i64 %n_2432, i64 %longLiteral_4489)
        
        
        %stackPointer_334 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %n_2432_pointer_335 = getelementptr <{i64}>, %StackPointer %stackPointer_334, i64 0, i32 0
        store i64 %n_2432, ptr %n_2432_pointer_335, !noalias !2
        %returnAddress_pointer_336 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_334, i64 0, i32 1, i32 0
        %sharer_pointer_337 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_334, i64 0, i32 1, i32 1
        %eraser_pointer_338 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_334, i64 0, i32 1, i32 2
        store ptr @returnAddress_310, ptr %returnAddress_pointer_336, !noalias !2
        store ptr @sharer_320, ptr %sharer_pointer_337, !noalias !2
        store ptr @eraser_324, ptr %eraser_pointer_338, !noalias !2
        
        
        
        musttail call tailcc void @fibonacci_2433(i64 %pureApp_4488, %Stack %stack)
        ret void
    
    label_343:
        
        %longLiteral_4493 = add i64 1, 0
        
        %stackPointer_341 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_342 = getelementptr %FrameHeader, %StackPointer %stackPointer_341, i64 0, i32 0
        %returnAddress_340 = load %ReturnAddress, ptr %returnAddress_pointer_342, !noalias !2
        musttail call tailcc void %returnAddress_340(i64 %longLiteral_4493, %Stack %stack)
        ret void
    
    label_344:
        
        %longLiteral_4487 = add i64 1, 0
        
        %pureApp_4486 = call ccc %Pos @infixEq_72(i64 %n_2432, i64 %longLiteral_4487)
        
        
        
        %tag_307 = extractvalue %Pos %pureApp_4486, 0
        %fields_308 = extractvalue %Pos %pureApp_4486, 1
        switch i64 %tag_307, label %label_309 [i64 0, label %label_339 i64 1, label %label_343]
    
    label_348:
        
        %longLiteral_4494 = add i64 0, 0
        
        %stackPointer_346 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_347 = getelementptr %FrameHeader, %StackPointer %stackPointer_346, i64 0, i32 0
        %returnAddress_345 = load %ReturnAddress, ptr %returnAddress_pointer_347, !noalias !2
        musttail call tailcc void %returnAddress_345(i64 %longLiteral_4494, %Stack %stack)
        ret void
}


@utf8StringLiteral_4475.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4477.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4480.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_349(%Pos %v_r_2634_3426, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_350 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_351 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_350, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_351, !noalias !2
        %index_2107_pointer_352 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_350, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_352, !noalias !2
        %Exception_2362_pointer_353 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_350, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_353, !noalias !2
        
        %tag_354 = extractvalue %Pos %v_r_2634_3426, 0
        %fields_355 = extractvalue %Pos %v_r_2634_3426, 1
        switch i64 %tag_354, label %label_356 [i64 0, label %label_360 i64 1, label %label_366]
    
    label_356:
        
        ret void
    
    label_360:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4471 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_358 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_359 = getelementptr %FrameHeader, %StackPointer %stackPointer_358, i64 0, i32 0
        %returnAddress_357 = load %ReturnAddress, ptr %returnAddress_pointer_359, !noalias !2
        musttail call tailcc void %returnAddress_357(i64 %pureApp_4471, %Stack %stack)
        ret void
    
    label_366:
        
        %make_4472_temporary_361 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4472 = insertvalue %Pos %make_4472_temporary_361, %Object null, 1
        
        
        
        %pureApp_4473 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4475 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4475.lit)
        
        %pureApp_4474 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4475, %Pos %pureApp_4473)
        
        
        
        %utf8StringLiteral_4477 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4477.lit)
        
        %pureApp_4476 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4474, %Pos %utf8StringLiteral_4477)
        
        
        
        %pureApp_4478 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4476, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4480 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4480.lit)
        
        %pureApp_4479 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4478, %Pos %utf8StringLiteral_4480)
        
        
        
        %vtable_362 = extractvalue %Neg %Exception_2362, 0
        %closure_363 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_364 = getelementptr ptr, ptr %vtable_362, i64 0
        %functionPointer_365 = load ptr, ptr %functionPointer_pointer_364, !noalias !2
        musttail call tailcc void %functionPointer_365(%Object %closure_363, %Pos %make_4472, %Pos %pureApp_4479, %Stack %stack)
        ret void
}



define ccc void @sharer_370(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_371 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_367_pointer_372 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_371, i64 0, i32 0
        %str_2106_367 = load %Pos, ptr %str_2106_367_pointer_372, !noalias !2
        %index_2107_368_pointer_373 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_371, i64 0, i32 1
        %index_2107_368 = load i64, ptr %index_2107_368_pointer_373, !noalias !2
        %Exception_2362_369_pointer_374 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_371, i64 0, i32 2
        %Exception_2362_369 = load %Neg, ptr %Exception_2362_369_pointer_374, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_367)
        call ccc void @shareNegative(%Neg %Exception_2362_369)
        call ccc void @shareFrames(%StackPointer %stackPointer_371)
        ret void
}



define ccc void @eraser_378(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_379 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_375_pointer_380 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_379, i64 0, i32 0
        %str_2106_375 = load %Pos, ptr %str_2106_375_pointer_380, !noalias !2
        %index_2107_376_pointer_381 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_379, i64 0, i32 1
        %index_2107_376 = load i64, ptr %index_2107_376_pointer_381, !noalias !2
        %Exception_2362_377_pointer_382 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_379, i64 0, i32 2
        %Exception_2362_377 = load %Neg, ptr %Exception_2362_377_pointer_382, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_375)
        call ccc void @eraseNegative(%Neg %Exception_2362_377)
        call ccc void @eraseFrames(%StackPointer %stackPointer_379)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4470 = add i64 0, 0
        
        %pureApp_4469 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4470)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_383 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_384 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_383, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_384, !noalias !2
        %index_2107_pointer_385 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_383, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_385, !noalias !2
        %Exception_2362_pointer_386 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_383, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_386, !noalias !2
        %returnAddress_pointer_387 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_383, i64 0, i32 1, i32 0
        %sharer_pointer_388 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_383, i64 0, i32 1, i32 1
        %eraser_pointer_389 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_383, i64 0, i32 1, i32 2
        store ptr @returnAddress_349, ptr %returnAddress_pointer_387, !noalias !2
        store ptr @sharer_370, ptr %sharer_pointer_388, !noalias !2
        store ptr @eraser_378, ptr %eraser_pointer_389, !noalias !2
        
        %tag_390 = extractvalue %Pos %pureApp_4469, 0
        %fields_391 = extractvalue %Pos %pureApp_4469, 1
        switch i64 %tag_390, label %label_392 [i64 0, label %label_396 i64 1, label %label_401]
    
    label_392:
        
        ret void
    
    label_396:
        
        %pureApp_4481 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4482 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4481)
        
        
        
        %stackPointer_394 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_395 = getelementptr %FrameHeader, %StackPointer %stackPointer_394, i64 0, i32 0
        %returnAddress_393 = load %ReturnAddress, ptr %returnAddress_pointer_395, !noalias !2
        musttail call tailcc void %returnAddress_393(%Pos %pureApp_4482, %Stack %stack)
        ret void
    
    label_401:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4483_temporary_397 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4483 = insertvalue %Pos %booleanLiteral_4483_temporary_397, %Object null, 1
        
        %stackPointer_399 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_400 = getelementptr %FrameHeader, %StackPointer %stackPointer_399, i64 0, i32 0
        %returnAddress_398 = load %ReturnAddress, ptr %returnAddress_pointer_400, !noalias !2
        musttail call tailcc void %returnAddress_398(%Pos %booleanLiteral_4483, %Stack %stack)
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
        
        musttail call tailcc void @main_2434(%Stack %stack)
        ret void
}
