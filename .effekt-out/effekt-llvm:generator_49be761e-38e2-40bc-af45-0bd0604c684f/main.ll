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



define tailcc void @returnAddress_2(%Pos %v_coe_3507_124_4700, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4909 = call ccc i64 @unboxInt_303(%Pos %v_coe_3507_124_4700)
        
        
        
        %pureApp_4910 = call ccc %Pos @show_14(i64 %pureApp_4909)
        
        
        
        %pureApp_4911 = call ccc %Pos @println_1(%Pos %pureApp_4910)
        
        
        
        %stackPointer_4 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_5 = getelementptr %FrameHeader, %StackPointer %stackPointer_4, i64 0, i32 0
        %returnAddress_3 = load %ReturnAddress, ptr %returnAddress_pointer_5, !noalias !2
        musttail call tailcc void %returnAddress_3(%Pos %pureApp_4911, %Stack %stack)
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



define tailcc void @returnAddress_15(%Pos %returned_4912, %Stack %stack) {
        
    entry:
        
        %stack_16 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_18 = call ccc %StackPointer @stackDeallocate(%Stack %stack_16, i64 24)
        %returnAddress_pointer_19 = getelementptr %FrameHeader, %StackPointer %stackPointer_18, i64 0, i32 0
        %returnAddress_17 = load %ReturnAddress, ptr %returnAddress_pointer_19, !noalias !2
        musttail call tailcc void %returnAddress_17(%Pos %returned_4912, %Stack %stack_16)
        ret void
}



define ccc void @sharer_20(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_21 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_23)
        ret void
}



define tailcc void @returnAddress_34(%Pos %returnValue_35, %Stack %stack) {
        
    entry:
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %tmp_4869_pointer_37 = getelementptr <{%Pos}>, %StackPointer %stackPointer_36, i64 0, i32 0
        %tmp_4869 = load %Pos, ptr %tmp_4869_pointer_37, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4869)
        %stackPointer_39 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_40 = getelementptr %FrameHeader, %StackPointer %stackPointer_39, i64 0, i32 0
        %returnAddress_38 = load %ReturnAddress, ptr %returnAddress_pointer_40, !noalias !2
        musttail call tailcc void %returnAddress_38(%Pos %returnValue_35, %Stack %stack)
        ret void
}



define ccc void @sharer_42(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_43 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_4869_41_pointer_44 = getelementptr <{%Pos}>, %StackPointer %stackPointer_43, i64 0, i32 0
        %tmp_4869_41 = load %Pos, ptr %tmp_4869_41_pointer_44, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_4869_41)
        call ccc void @shareFrames(%StackPointer %stackPointer_43)
        ret void
}



define ccc void @eraser_46(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_47 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_4869_45_pointer_48 = getelementptr <{%Pos}>, %StackPointer %stackPointer_47, i64 0, i32 0
        %tmp_4869_45 = load %Pos, ptr %tmp_4869_45_pointer_48, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4869_45)
        call ccc void @eraseFrames(%StackPointer %stackPointer_47)
        ret void
}



define tailcc void @blockLit_4916_clause_55(%Object %closure, %Stack %stack) {
        
    entry:
        
        
        %unitLiteral_4917_temporary_56 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_4917 = insertvalue %Pos %unitLiteral_4917_temporary_56, %Object null, 1
        
        %stackPointer_58 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_59 = getelementptr %FrameHeader, %StackPointer %stackPointer_58, i64 0, i32 0
        %returnAddress_57 = load %ReturnAddress, ptr %returnAddress_pointer_59, !noalias !2
        musttail call tailcc void %returnAddress_57(%Pos %unitLiteral_4917, %Stack %stack)
        ret void
}


@vtable_60 = private constant [1 x ptr] [ptr @blockLit_4916_clause_55]


define tailcc void @returnAddress_64(%Pos %returnValue_65, %Stack %stack) {
        
    entry:
        
        %stackPointer_66 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %tmp_4870_pointer_67 = getelementptr <{%Pos}>, %StackPointer %stackPointer_66, i64 0, i32 0
        %tmp_4870 = load %Pos, ptr %tmp_4870_pointer_67, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4870)
        %stackPointer_69 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_70 = getelementptr %FrameHeader, %StackPointer %stackPointer_69, i64 0, i32 0
        %returnAddress_68 = load %ReturnAddress, ptr %returnAddress_pointer_70, !noalias !2
        musttail call tailcc void %returnAddress_68(%Pos %returnValue_65, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_103(%Pos %__2_2_120_4761, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_104 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %acc_101_4685_pointer_105 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_104, i64 0, i32 0
        %acc_101_4685 = load i64, ptr %acc_101_4685_pointer_105, !noalias !2
        %tmp_4875_pointer_106 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_104, i64 0, i32 1
        %tmp_4875 = load i64, ptr %tmp_4875_pointer_106, !noalias !2
        %v_7_42_4693_pointer_107 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_104, i64 0, i32 2
        %v_7_42_4693 = load %Reference, ptr %v_7_42_4693_pointer_107, !noalias !2
        %cont_10_45_4721_pointer_108 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_104, i64 0, i32 3
        %cont_10_45_4721 = load %Reference, ptr %cont_10_45_4721_pointer_108, !noalias !2
        call ccc void @erasePositive(%Pos %__2_2_120_4761)
        
        %pureApp_4921 = call ccc i64 @infixAdd_96(i64 %acc_101_4685, i64 %tmp_4875)
        
        
        
        
        
        musttail call tailcc void @consumer_100_4669(i64 %pureApp_4921, %Reference %v_7_42_4693, %Reference %cont_10_45_4721, %Stack %stack)
        ret void
}



define ccc void @sharer_113(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_114 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %acc_101_4685_109_pointer_115 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 0
        %acc_101_4685_109 = load i64, ptr %acc_101_4685_109_pointer_115, !noalias !2
        %tmp_4875_110_pointer_116 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 1
        %tmp_4875_110 = load i64, ptr %tmp_4875_110_pointer_116, !noalias !2
        %v_7_42_4693_111_pointer_117 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 2
        %v_7_42_4693_111 = load %Reference, ptr %v_7_42_4693_111_pointer_117, !noalias !2
        %cont_10_45_4721_112_pointer_118 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 3
        %cont_10_45_4721_112 = load %Reference, ptr %cont_10_45_4721_112_pointer_118, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_114)
        ret void
}



define ccc void @eraser_123(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_124 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %acc_101_4685_119_pointer_125 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_124, i64 0, i32 0
        %acc_101_4685_119 = load i64, ptr %acc_101_4685_119_pointer_125, !noalias !2
        %tmp_4875_120_pointer_126 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_124, i64 0, i32 1
        %tmp_4875_120 = load i64, ptr %tmp_4875_120_pointer_126, !noalias !2
        %v_7_42_4693_121_pointer_127 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_124, i64 0, i32 2
        %v_7_42_4693_121 = load %Reference, ptr %v_7_42_4693_121_pointer_127, !noalias !2
        %cont_10_45_4721_122_pointer_128 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_124, i64 0, i32 3
        %cont_10_45_4721_122 = load %Reference, ptr %cont_10_45_4721_122_pointer_128, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_124)
        ret void
}



define tailcc void @returnAddress_97(%Pos %v_r_2558_26_1_118_4686, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_98 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %acc_101_4685_pointer_99 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 0
        %acc_101_4685 = load i64, ptr %acc_101_4685_pointer_99, !noalias !2
        %v_7_42_4693_pointer_100 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 1
        %v_7_42_4693 = load %Reference, ptr %v_7_42_4693_pointer_100, !noalias !2
        %tmp_4875_pointer_101 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 2
        %tmp_4875 = load i64, ptr %tmp_4875_pointer_101, !noalias !2
        %cont_10_45_4721_pointer_102 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 3
        %cont_10_45_4721 = load %Reference, ptr %cont_10_45_4721_pointer_102, !noalias !2
        
        %tmp_4876 = call ccc %Neg @unbox(%Pos %v_r_2558_26_1_118_4686)
        %stackPointer_129 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %acc_101_4685_pointer_130 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_129, i64 0, i32 0
        store i64 %acc_101_4685, ptr %acc_101_4685_pointer_130, !noalias !2
        %tmp_4875_pointer_131 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_129, i64 0, i32 1
        store i64 %tmp_4875, ptr %tmp_4875_pointer_131, !noalias !2
        %v_7_42_4693_pointer_132 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_129, i64 0, i32 2
        store %Reference %v_7_42_4693, ptr %v_7_42_4693_pointer_132, !noalias !2
        %cont_10_45_4721_pointer_133 = getelementptr <{i64, i64, %Reference, %Reference}>, %StackPointer %stackPointer_129, i64 0, i32 3
        store %Reference %cont_10_45_4721, ptr %cont_10_45_4721_pointer_133, !noalias !2
        %returnAddress_pointer_134 = getelementptr <{<{i64, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_129, i64 0, i32 1, i32 0
        %sharer_pointer_135 = getelementptr <{<{i64, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_129, i64 0, i32 1, i32 1
        %eraser_pointer_136 = getelementptr <{<{i64, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_129, i64 0, i32 1, i32 2
        store ptr @returnAddress_103, ptr %returnAddress_pointer_134, !noalias !2
        store ptr @sharer_113, ptr %sharer_pointer_135, !noalias !2
        store ptr @eraser_123, ptr %eraser_pointer_136, !noalias !2
        
        %vtable_137 = extractvalue %Neg %tmp_4876, 0
        %closure_138 = extractvalue %Neg %tmp_4876, 1
        %functionPointer_pointer_139 = getelementptr ptr, ptr %vtable_137, i64 0
        %functionPointer_140 = load ptr, ptr %functionPointer_pointer_139, !noalias !2
        musttail call tailcc void %functionPointer_140(%Object %closure_138, %Stack %stack)
        ret void
}



define ccc void @sharer_145(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_146 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %acc_101_4685_141_pointer_147 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_146, i64 0, i32 0
        %acc_101_4685_141 = load i64, ptr %acc_101_4685_141_pointer_147, !noalias !2
        %v_7_42_4693_142_pointer_148 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_146, i64 0, i32 1
        %v_7_42_4693_142 = load %Reference, ptr %v_7_42_4693_142_pointer_148, !noalias !2
        %tmp_4875_143_pointer_149 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_146, i64 0, i32 2
        %tmp_4875_143 = load i64, ptr %tmp_4875_143_pointer_149, !noalias !2
        %cont_10_45_4721_144_pointer_150 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_146, i64 0, i32 3
        %cont_10_45_4721_144 = load %Reference, ptr %cont_10_45_4721_144_pointer_150, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_146)
        ret void
}



define ccc void @eraser_155(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_156 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %acc_101_4685_151_pointer_157 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_156, i64 0, i32 0
        %acc_101_4685_151 = load i64, ptr %acc_101_4685_151_pointer_157, !noalias !2
        %v_7_42_4693_152_pointer_158 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_156, i64 0, i32 1
        %v_7_42_4693_152 = load %Reference, ptr %v_7_42_4693_152_pointer_158, !noalias !2
        %tmp_4875_153_pointer_159 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_156, i64 0, i32 2
        %tmp_4875_153 = load i64, ptr %tmp_4875_153_pointer_159, !noalias !2
        %cont_10_45_4721_154_pointer_160 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_156, i64 0, i32 3
        %cont_10_45_4721_154 = load %Reference, ptr %cont_10_45_4721_154_pointer_160, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_156)
        ret void
}



define tailcc void @returnAddress_83(%Pos %v_r_2575_102_4672, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_84 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %acc_101_4685_pointer_85 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_84, i64 0, i32 0
        %acc_101_4685 = load i64, ptr %acc_101_4685_pointer_85, !noalias !2
        %v_7_42_4693_pointer_86 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_84, i64 0, i32 1
        %v_7_42_4693 = load %Reference, ptr %v_7_42_4693_pointer_86, !noalias !2
        %cont_10_45_4721_pointer_87 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_84, i64 0, i32 2
        %cont_10_45_4721 = load %Reference, ptr %cont_10_45_4721_pointer_87, !noalias !2
        
        %tag_88 = extractvalue %Pos %v_r_2575_102_4672, 0
        %fields_89 = extractvalue %Pos %v_r_2575_102_4672, 1
        switch i64 %tag_88, label %label_90 [i64 0, label %label_94 i64 1, label %label_174]
    
    label_90:
        
        ret void
    
    label_94:
        
        %stackPointer_92 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_93 = getelementptr %FrameHeader, %StackPointer %stackPointer_92, i64 0, i32 0
        %returnAddress_91 = load %ReturnAddress, ptr %returnAddress_pointer_93, !noalias !2
        musttail call tailcc void %returnAddress_91(i64 %acc_101_4685, %Stack %stack)
        ret void
    
    label_174:
        %environment_95 = call ccc %Environment @objectEnvironment(%Object %fields_89)
        %v_coe_3504_110_4684_pointer_96 = getelementptr <{%Pos}>, %Environment %environment_95, i64 0, i32 0
        %v_coe_3504_110_4684 = load %Pos, ptr %v_coe_3504_110_4684_pointer_96, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3504_110_4684)
        call ccc void @eraseObject(%Object %fields_89)
        
        %pureApp_4920 = call ccc i64 @unboxInt_303(%Pos %v_coe_3504_110_4684)
        
        
        %stackPointer_161 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %acc_101_4685_pointer_162 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_161, i64 0, i32 0
        store i64 %acc_101_4685, ptr %acc_101_4685_pointer_162, !noalias !2
        %v_7_42_4693_pointer_163 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_161, i64 0, i32 1
        store %Reference %v_7_42_4693, ptr %v_7_42_4693_pointer_163, !noalias !2
        %tmp_4875_pointer_164 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_161, i64 0, i32 2
        store i64 %pureApp_4920, ptr %tmp_4875_pointer_164, !noalias !2
        %cont_10_45_4721_pointer_165 = getelementptr <{i64, %Reference, i64, %Reference}>, %StackPointer %stackPointer_161, i64 0, i32 3
        store %Reference %cont_10_45_4721, ptr %cont_10_45_4721_pointer_165, !noalias !2
        %returnAddress_pointer_166 = getelementptr <{<{i64, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_161, i64 0, i32 1, i32 0
        %sharer_pointer_167 = getelementptr <{<{i64, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_161, i64 0, i32 1, i32 1
        %eraser_pointer_168 = getelementptr <{<{i64, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_161, i64 0, i32 1, i32 2
        store ptr @returnAddress_97, ptr %returnAddress_pointer_166, !noalias !2
        store ptr @sharer_145, ptr %sharer_pointer_167, !noalias !2
        store ptr @eraser_155, ptr %eraser_pointer_168, !noalias !2
        
        %get_4922_pointer_169 = call ccc ptr @getVarPointer(%Reference %cont_10_45_4721, %Stack %stack)
        %cont_10_45_4721_old_170 = load %Pos, ptr %get_4922_pointer_169, !noalias !2
        call ccc void @sharePositive(%Pos %cont_10_45_4721_old_170)
        %get_4922 = load %Pos, ptr %get_4922_pointer_169, !noalias !2
        
        %stackPointer_172 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_173 = getelementptr %FrameHeader, %StackPointer %stackPointer_172, i64 0, i32 0
        %returnAddress_171 = load %ReturnAddress, ptr %returnAddress_pointer_173, !noalias !2
        musttail call tailcc void %returnAddress_171(%Pos %get_4922, %Stack %stack)
        ret void
}



define ccc void @sharer_178(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_179 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %acc_101_4685_175_pointer_180 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_179, i64 0, i32 0
        %acc_101_4685_175 = load i64, ptr %acc_101_4685_175_pointer_180, !noalias !2
        %v_7_42_4693_176_pointer_181 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_179, i64 0, i32 1
        %v_7_42_4693_176 = load %Reference, ptr %v_7_42_4693_176_pointer_181, !noalias !2
        %cont_10_45_4721_177_pointer_182 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_179, i64 0, i32 2
        %cont_10_45_4721_177 = load %Reference, ptr %cont_10_45_4721_177_pointer_182, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_179)
        ret void
}



define ccc void @eraser_186(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_187 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %acc_101_4685_183_pointer_188 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 0
        %acc_101_4685_183 = load i64, ptr %acc_101_4685_183_pointer_188, !noalias !2
        %v_7_42_4693_184_pointer_189 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 1
        %v_7_42_4693_184 = load %Reference, ptr %v_7_42_4693_184_pointer_189, !noalias !2
        %cont_10_45_4721_185_pointer_190 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 2
        %cont_10_45_4721_185 = load %Reference, ptr %cont_10_45_4721_185_pointer_190, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_187)
        ret void
}



define tailcc void @consumer_100_4669(i64 %acc_101_4685, %Reference %v_7_42_4693, %Reference %cont_10_45_4721, %Stack %stack) {
        
    entry:
        
        %stackPointer_191 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %acc_101_4685_pointer_192 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_191, i64 0, i32 0
        store i64 %acc_101_4685, ptr %acc_101_4685_pointer_192, !noalias !2
        %v_7_42_4693_pointer_193 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_191, i64 0, i32 1
        store %Reference %v_7_42_4693, ptr %v_7_42_4693_pointer_193, !noalias !2
        %cont_10_45_4721_pointer_194 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_191, i64 0, i32 2
        store %Reference %cont_10_45_4721, ptr %cont_10_45_4721_pointer_194, !noalias !2
        %returnAddress_pointer_195 = getelementptr <{<{i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_191, i64 0, i32 1, i32 0
        %sharer_pointer_196 = getelementptr <{<{i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_191, i64 0, i32 1, i32 1
        %eraser_pointer_197 = getelementptr <{<{i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_191, i64 0, i32 1, i32 2
        store ptr @returnAddress_83, ptr %returnAddress_pointer_195, !noalias !2
        store ptr @sharer_178, ptr %sharer_pointer_196, !noalias !2
        store ptr @eraser_186, ptr %eraser_pointer_197, !noalias !2
        
        %get_4923_pointer_198 = call ccc ptr @getVarPointer(%Reference %v_7_42_4693, %Stack %stack)
        %v_7_42_4693_old_199 = load %Pos, ptr %get_4923_pointer_198, !noalias !2
        call ccc void @sharePositive(%Pos %v_7_42_4693_old_199)
        %get_4923 = load %Pos, ptr %get_4923_pointer_198, !noalias !2
        
        %stackPointer_201 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_202 = getelementptr %FrameHeader, %StackPointer %stackPointer_201, i64 0, i32 0
        %returnAddress_200 = load %ReturnAddress, ptr %returnAddress_pointer_202, !noalias !2
        musttail call tailcc void %returnAddress_200(%Pos %get_4923, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_203(i64 %v_coe_3506_122_4676, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4924 = call ccc %Pos @boxInt_301(i64 %v_coe_3506_122_4676)
        
        
        
        %stackPointer_205 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_206 = getelementptr %FrameHeader, %StackPointer %stackPointer_205, i64 0, i32 0
        %returnAddress_204 = load %ReturnAddress, ptr %returnAddress_pointer_206, !noalias !2
        musttail call tailcc void %returnAddress_204(%Pos %pureApp_4924, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_79(%Pos %__25_90_4756, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_80 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_7_42_4693_pointer_81 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_80, i64 0, i32 0
        %v_7_42_4693 = load %Reference, ptr %v_7_42_4693_pointer_81, !noalias !2
        %cont_10_45_4721_pointer_82 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_80, i64 0, i32 1
        %cont_10_45_4721 = load %Reference, ptr %cont_10_45_4721_pointer_82, !noalias !2
        call ccc void @erasePositive(%Pos %__25_90_4756)
        %stackPointer_207 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_208 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_207, i64 0, i32 1, i32 0
        %sharer_pointer_209 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_207, i64 0, i32 1, i32 1
        %eraser_pointer_210 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_207, i64 0, i32 1, i32 2
        store ptr @returnAddress_203, ptr %returnAddress_pointer_208, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_209, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_210, !noalias !2
        
        %longLiteral_4925 = add i64 0, 0
        
        
        
        musttail call tailcc void @consumer_100_4669(i64 %longLiteral_4925, %Reference %v_7_42_4693, %Reference %cont_10_45_4721, %Stack %stack)
        ret void
}



define ccc void @sharer_213(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_214 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_7_42_4693_211_pointer_215 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_214, i64 0, i32 0
        %v_7_42_4693_211 = load %Reference, ptr %v_7_42_4693_211_pointer_215, !noalias !2
        %cont_10_45_4721_212_pointer_216 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_214, i64 0, i32 1
        %cont_10_45_4721_212 = load %Reference, ptr %cont_10_45_4721_212_pointer_216, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_214)
        ret void
}



define ccc void @eraser_219(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_220 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_7_42_4693_217_pointer_221 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_220, i64 0, i32 0
        %v_7_42_4693_217 = load %Reference, ptr %v_7_42_4693_217_pointer_221, !noalias !2
        %cont_10_45_4721_218_pointer_222 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_220, i64 0, i32 1
        %cont_10_45_4721_218 = load %Reference, ptr %cont_10_45_4721_218_pointer_222, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_220)
        ret void
}



define tailcc void @returnAddress_230(%Pos %returned_4926, %Stack %stack) {
        
    entry:
        
        %stack_231 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_233 = call ccc %StackPointer @stackDeallocate(%Stack %stack_231, i64 24)
        %returnAddress_pointer_234 = getelementptr %FrameHeader, %StackPointer %stackPointer_233, i64 0, i32 0
        %returnAddress_232 = load %ReturnAddress, ptr %returnAddress_pointer_234, !noalias !2
        musttail call tailcc void %returnAddress_232(%Pos %returned_4926, %Stack %stack_231)
        ret void
}



define tailcc void @returnAddress_258(%Pos %__5_17_16_87_4754, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_259 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %v_y_2568_15_14_77_4690_pointer_260 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_259, i64 0, i32 0
        %v_y_2568_15_14_77_4690 = load %Pos, ptr %v_y_2568_15_14_77_4690_pointer_260, !noalias !2
        %v_7_42_4693_pointer_261 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_259, i64 0, i32 1
        %v_7_42_4693 = load %Reference, ptr %v_7_42_4693_pointer_261, !noalias !2
        %p_12_47_4709_pointer_262 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_259, i64 0, i32 2
        %p_12_47_4709 = load %Prompt, ptr %p_12_47_4709_pointer_262, !noalias !2
        %cont_10_45_4721_pointer_263 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_259, i64 0, i32 3
        %cont_10_45_4721 = load %Reference, ptr %cont_10_45_4721_pointer_263, !noalias !2
        call ccc void @erasePositive(%Pos %__5_17_16_87_4754)
        
        
        
        musttail call tailcc void @iterate_worker_4_3_58_4667(%Pos %v_y_2568_15_14_77_4690, %Reference %v_7_42_4693, %Prompt %p_12_47_4709, %Reference %cont_10_45_4721, %Stack %stack)
        ret void
}



define ccc void @sharer_268(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_269 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_y_2568_15_14_77_4690_264_pointer_270 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_269, i64 0, i32 0
        %v_y_2568_15_14_77_4690_264 = load %Pos, ptr %v_y_2568_15_14_77_4690_264_pointer_270, !noalias !2
        %v_7_42_4693_265_pointer_271 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_269, i64 0, i32 1
        %v_7_42_4693_265 = load %Reference, ptr %v_7_42_4693_265_pointer_271, !noalias !2
        %p_12_47_4709_266_pointer_272 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_269, i64 0, i32 2
        %p_12_47_4709_266 = load %Prompt, ptr %p_12_47_4709_266_pointer_272, !noalias !2
        %cont_10_45_4721_267_pointer_273 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_269, i64 0, i32 3
        %cont_10_45_4721_267 = load %Reference, ptr %cont_10_45_4721_267_pointer_273, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2568_15_14_77_4690_264)
        call ccc void @shareFrames(%StackPointer %stackPointer_269)
        ret void
}



define ccc void @eraser_278(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_279 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_y_2568_15_14_77_4690_274_pointer_280 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_279, i64 0, i32 0
        %v_y_2568_15_14_77_4690_274 = load %Pos, ptr %v_y_2568_15_14_77_4690_274_pointer_280, !noalias !2
        %v_7_42_4693_275_pointer_281 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_279, i64 0, i32 1
        %v_7_42_4693_275 = load %Reference, ptr %v_7_42_4693_275_pointer_281, !noalias !2
        %p_12_47_4709_276_pointer_282 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_279, i64 0, i32 2
        %p_12_47_4709_276 = load %Prompt, ptr %p_12_47_4709_276_pointer_282, !noalias !2
        %cont_10_45_4721_277_pointer_283 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_279, i64 0, i32 3
        %cont_10_45_4721_277 = load %Reference, ptr %cont_10_45_4721_277_pointer_283, !noalias !2
        call ccc void @erasePositive(%Pos %v_y_2568_15_14_77_4690_274)
        call ccc void @eraseFrames(%StackPointer %stackPointer_279)
        ret void
}



define ccc void @eraser_297(%Environment %environment) {
        
    entry:
        
        %tmp_4871_296_pointer_298 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4871_296 = load %Pos, ptr %tmp_4871_296_pointer_298, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4871_296)
        ret void
}



define tailcc void @blockLit_4930_clause_305(%Object %closure, %Stack %stack) {
        
    entry:
        
        %environment_306 = call ccc %Environment @objectEnvironment(%Object %closure)
        %k_16_3_80_4712_pointer_307 = getelementptr <{%Resumption}>, %Environment %environment_306, i64 0, i32 0
        %k_16_3_80_4712 = load %Resumption, ptr %k_16_3_80_4712_pointer_307, !noalias !2
        call ccc void @shareResumption(%Resumption %k_16_3_80_4712)
        call ccc void @eraseObject(%Object %closure)
        
        %stack_308 = call ccc %Stack @resume(%Resumption %k_16_3_80_4712, %Stack %stack)
        
        %unitLiteral_4931_temporary_309 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_4931 = insertvalue %Pos %unitLiteral_4931_temporary_309, %Object null, 1
        
        %stackPointer_311 = call ccc %StackPointer @stackDeallocate(%Stack %stack_308, i64 24)
        %returnAddress_pointer_312 = getelementptr %FrameHeader, %StackPointer %stackPointer_311, i64 0, i32 0
        %returnAddress_310 = load %ReturnAddress, ptr %returnAddress_pointer_312, !noalias !2
        musttail call tailcc void %returnAddress_310(%Pos %unitLiteral_4931, %Stack %stack_308)
        ret void
}


@vtable_313 = private constant [1 x ptr] [ptr @blockLit_4930_clause_305]


define ccc void @eraser_317(%Environment %environment) {
        
    entry:
        
        %k_16_3_80_4712_316_pointer_318 = getelementptr <{%Resumption}>, %Environment %environment, i64 0, i32 0
        %k_16_3_80_4712_316 = load %Resumption, ptr %k_16_3_80_4712_316_pointer_318, !noalias !2
        call ccc void @eraseResumption(%Resumption %k_16_3_80_4712_316)
        ret void
}



define tailcc void @returnAddress_301(%Pos %__21_8_85_4753, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_302 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %k_16_3_80_4712_pointer_303 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer_302, i64 0, i32 0
        %k_16_3_80_4712 = load %Resumption, ptr %k_16_3_80_4712_pointer_303, !noalias !2
        %cont_10_45_4721_pointer_304 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer_302, i64 0, i32 1
        %cont_10_45_4721 = load %Reference, ptr %cont_10_45_4721_pointer_304, !noalias !2
        call ccc void @erasePositive(%Pos %__21_8_85_4753)
        
        %closure_314 = call ccc %Object @newObject(ptr @eraser_317, i64 8)
        %environment_315 = call ccc %Environment @objectEnvironment(%Object %closure_314)
        %k_16_3_80_4712_pointer_319 = getelementptr <{%Resumption}>, %Environment %environment_315, i64 0, i32 0
        store %Resumption %k_16_3_80_4712, ptr %k_16_3_80_4712_pointer_319, !noalias !2
        %vtable_temporary_320 = insertvalue %Neg zeroinitializer, ptr @vtable_313, 0
        %blockLit_4930 = insertvalue %Neg %vtable_temporary_320, %Object %closure_314, 1
        
        %blockLit_4930_4932 = call ccc %Pos @box(%Neg %blockLit_4930)
        
        
        
        %cont_10_45_4721pointer_321 = call ccc ptr @getVarPointer(%Reference %cont_10_45_4721, %Stack %stack)
        %cont_10_45_4721_old_322 = load %Pos, ptr %cont_10_45_4721pointer_321, !noalias !2
        call ccc void @erasePositive(%Pos %cont_10_45_4721_old_322)
        store %Pos %blockLit_4930_4932, ptr %cont_10_45_4721pointer_321, !noalias !2
        
        %put_4933_temporary_323 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_4933 = insertvalue %Pos %put_4933_temporary_323, %Object null, 1
        
        %stackPointer_325 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_326 = getelementptr %FrameHeader, %StackPointer %stackPointer_325, i64 0, i32 0
        %returnAddress_324 = load %ReturnAddress, ptr %returnAddress_pointer_326, !noalias !2
        musttail call tailcc void %returnAddress_324(%Pos %put_4933, %Stack %stack)
        ret void
}



define ccc void @sharer_329(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_330 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer, i64 -1
        %k_16_3_80_4712_327_pointer_331 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer_330, i64 0, i32 0
        %k_16_3_80_4712_327 = load %Resumption, ptr %k_16_3_80_4712_327_pointer_331, !noalias !2
        %cont_10_45_4721_328_pointer_332 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer_330, i64 0, i32 1
        %cont_10_45_4721_328 = load %Reference, ptr %cont_10_45_4721_328_pointer_332, !noalias !2
        call ccc void @shareResumption(%Resumption %k_16_3_80_4712_327)
        call ccc void @shareFrames(%StackPointer %stackPointer_330)
        ret void
}



define ccc void @eraser_335(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_336 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer, i64 -1
        %k_16_3_80_4712_333_pointer_337 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer_336, i64 0, i32 0
        %k_16_3_80_4712_333 = load %Resumption, ptr %k_16_3_80_4712_333_pointer_337, !noalias !2
        %cont_10_45_4721_334_pointer_338 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer_336, i64 0, i32 1
        %cont_10_45_4721_334 = load %Reference, ptr %cont_10_45_4721_334_pointer_338, !noalias !2
        call ccc void @eraseResumption(%Resumption %k_16_3_80_4712_333)
        call ccc void @eraseFrames(%StackPointer %stackPointer_336)
        ret void
}



define tailcc void @returnAddress_251(%Pos %__4_16_15_78_4752, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_252 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %v_y_2567_14_13_76_4679_pointer_253 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_252, i64 0, i32 0
        %v_y_2567_14_13_76_4679 = load i64, ptr %v_y_2567_14_13_76_4679_pointer_253, !noalias !2
        %p_12_47_4709_pointer_254 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_252, i64 0, i32 1
        %p_12_47_4709 = load %Prompt, ptr %p_12_47_4709_pointer_254, !noalias !2
        %cont_10_45_4721_pointer_255 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_252, i64 0, i32 2
        %cont_10_45_4721 = load %Reference, ptr %cont_10_45_4721_pointer_255, !noalias !2
        %v_y_2568_15_14_77_4690_pointer_256 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_252, i64 0, i32 3
        %v_y_2568_15_14_77_4690 = load %Pos, ptr %v_y_2568_15_14_77_4690_pointer_256, !noalias !2
        %v_7_42_4693_pointer_257 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_252, i64 0, i32 4
        %v_7_42_4693 = load %Reference, ptr %v_7_42_4693_pointer_257, !noalias !2
        call ccc void @erasePositive(%Pos %__4_16_15_78_4752)
        %stackPointer_284 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %v_y_2568_15_14_77_4690_pointer_285 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_284, i64 0, i32 0
        store %Pos %v_y_2568_15_14_77_4690, ptr %v_y_2568_15_14_77_4690_pointer_285, !noalias !2
        %v_7_42_4693_pointer_286 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_284, i64 0, i32 1
        store %Reference %v_7_42_4693, ptr %v_7_42_4693_pointer_286, !noalias !2
        %p_12_47_4709_pointer_287 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_284, i64 0, i32 2
        store %Prompt %p_12_47_4709, ptr %p_12_47_4709_pointer_287, !noalias !2
        %cont_10_45_4721_pointer_288 = getelementptr <{%Pos, %Reference, %Prompt, %Reference}>, %StackPointer %stackPointer_284, i64 0, i32 3
        store %Reference %cont_10_45_4721, ptr %cont_10_45_4721_pointer_288, !noalias !2
        %returnAddress_pointer_289 = getelementptr <{<{%Pos, %Reference, %Prompt, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_284, i64 0, i32 1, i32 0
        %sharer_pointer_290 = getelementptr <{<{%Pos, %Reference, %Prompt, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_284, i64 0, i32 1, i32 1
        %eraser_pointer_291 = getelementptr <{<{%Pos, %Reference, %Prompt, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_284, i64 0, i32 1, i32 2
        store ptr @returnAddress_258, ptr %returnAddress_pointer_289, !noalias !2
        store ptr @sharer_268, ptr %sharer_pointer_290, !noalias !2
        store ptr @eraser_278, ptr %eraser_pointer_291, !noalias !2
        
        %pair_292 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_12_47_4709)
        %k_16_3_80_4712 = extractvalue <{%Resumption, %Stack}> %pair_292, 0
        %stack_293 = extractvalue <{%Resumption, %Stack}> %pair_292, 1
        
        %pureApp_4928 = call ccc %Pos @boxInt_301(i64 %v_y_2567_14_13_76_4679)
        
        
        
        %fields_294 = call ccc %Object @newObject(ptr @eraser_297, i64 16)
        %environment_295 = call ccc %Environment @objectEnvironment(%Object %fields_294)
        %tmp_4871_pointer_299 = getelementptr <{%Pos}>, %Environment %environment_295, i64 0, i32 0
        store %Pos %pureApp_4928, ptr %tmp_4871_pointer_299, !noalias !2
        %make_4929_temporary_300 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4929 = insertvalue %Pos %make_4929_temporary_300, %Object %fields_294, 1
        
        
        %stackPointer_339 = call ccc %StackPointer @stackAllocate(%Stack %stack_293, i64 48)
        %k_16_3_80_4712_pointer_340 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer_339, i64 0, i32 0
        store %Resumption %k_16_3_80_4712, ptr %k_16_3_80_4712_pointer_340, !noalias !2
        %cont_10_45_4721_pointer_341 = getelementptr <{%Resumption, %Reference}>, %StackPointer %stackPointer_339, i64 0, i32 1
        store %Reference %cont_10_45_4721, ptr %cont_10_45_4721_pointer_341, !noalias !2
        %returnAddress_pointer_342 = getelementptr <{<{%Resumption, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_339, i64 0, i32 1, i32 0
        %sharer_pointer_343 = getelementptr <{<{%Resumption, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_339, i64 0, i32 1, i32 1
        %eraser_pointer_344 = getelementptr <{<{%Resumption, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_339, i64 0, i32 1, i32 2
        store ptr @returnAddress_301, ptr %returnAddress_pointer_342, !noalias !2
        store ptr @sharer_329, ptr %sharer_pointer_343, !noalias !2
        store ptr @eraser_335, ptr %eraser_pointer_344, !noalias !2
        
        %v_7_42_4693pointer_345 = call ccc ptr @getVarPointer(%Reference %v_7_42_4693, %Stack %stack_293)
        %v_7_42_4693_old_346 = load %Pos, ptr %v_7_42_4693pointer_345, !noalias !2
        call ccc void @erasePositive(%Pos %v_7_42_4693_old_346)
        store %Pos %make_4929, ptr %v_7_42_4693pointer_345, !noalias !2
        
        %put_4934_temporary_347 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_4934 = insertvalue %Pos %put_4934_temporary_347, %Object null, 1
        
        %stackPointer_349 = call ccc %StackPointer @stackDeallocate(%Stack %stack_293, i64 24)
        %returnAddress_pointer_350 = getelementptr %FrameHeader, %StackPointer %stackPointer_349, i64 0, i32 0
        %returnAddress_348 = load %ReturnAddress, ptr %returnAddress_pointer_350, !noalias !2
        musttail call tailcc void %returnAddress_348(%Pos %put_4934, %Stack %stack_293)
        ret void
}



define ccc void @sharer_356(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_357 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_y_2567_14_13_76_4679_351_pointer_358 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_357, i64 0, i32 0
        %v_y_2567_14_13_76_4679_351 = load i64, ptr %v_y_2567_14_13_76_4679_351_pointer_358, !noalias !2
        %p_12_47_4709_352_pointer_359 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_357, i64 0, i32 1
        %p_12_47_4709_352 = load %Prompt, ptr %p_12_47_4709_352_pointer_359, !noalias !2
        %cont_10_45_4721_353_pointer_360 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_357, i64 0, i32 2
        %cont_10_45_4721_353 = load %Reference, ptr %cont_10_45_4721_353_pointer_360, !noalias !2
        %v_y_2568_15_14_77_4690_354_pointer_361 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_357, i64 0, i32 3
        %v_y_2568_15_14_77_4690_354 = load %Pos, ptr %v_y_2568_15_14_77_4690_354_pointer_361, !noalias !2
        %v_7_42_4693_355_pointer_362 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_357, i64 0, i32 4
        %v_7_42_4693_355 = load %Reference, ptr %v_7_42_4693_355_pointer_362, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2568_15_14_77_4690_354)
        call ccc void @shareFrames(%StackPointer %stackPointer_357)
        ret void
}



define ccc void @eraser_368(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_369 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_y_2567_14_13_76_4679_363_pointer_370 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_369, i64 0, i32 0
        %v_y_2567_14_13_76_4679_363 = load i64, ptr %v_y_2567_14_13_76_4679_363_pointer_370, !noalias !2
        %p_12_47_4709_364_pointer_371 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_369, i64 0, i32 1
        %p_12_47_4709_364 = load %Prompt, ptr %p_12_47_4709_364_pointer_371, !noalias !2
        %cont_10_45_4721_365_pointer_372 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_369, i64 0, i32 2
        %cont_10_45_4721_365 = load %Reference, ptr %cont_10_45_4721_365_pointer_372, !noalias !2
        %v_y_2568_15_14_77_4690_366_pointer_373 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_369, i64 0, i32 3
        %v_y_2568_15_14_77_4690_366 = load %Pos, ptr %v_y_2568_15_14_77_4690_366_pointer_373, !noalias !2
        %v_7_42_4693_367_pointer_374 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_369, i64 0, i32 4
        %v_7_42_4693_367 = load %Reference, ptr %v_7_42_4693_367_pointer_374, !noalias !2
        call ccc void @erasePositive(%Pos %v_y_2568_15_14_77_4690_366)
        call ccc void @eraseFrames(%StackPointer %stackPointer_369)
        ret void
}



define tailcc void @iterate_worker_4_3_58_4667(%Pos %tree_5_4_59_4654, %Reference %v_7_42_4693, %Prompt %p_12_47_4709, %Reference %cont_10_45_4721, %Stack %stack) {
        
    entry:
        
        
        %tag_239 = extractvalue %Pos %tree_5_4_59_4654, 0
        %fields_240 = extractvalue %Pos %tree_5_4_59_4654, 1
        switch i64 %tag_239, label %label_241 [i64 0, label %label_246 i64 1, label %label_384]
    
    label_241:
        
        ret void
    
    label_246:
        
        %unitLiteral_4927_temporary_242 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_4927 = insertvalue %Pos %unitLiteral_4927_temporary_242, %Object null, 1
        
        %stackPointer_244 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_245 = getelementptr %FrameHeader, %StackPointer %stackPointer_244, i64 0, i32 0
        %returnAddress_243 = load %ReturnAddress, ptr %returnAddress_pointer_245, !noalias !2
        musttail call tailcc void %returnAddress_243(%Pos %unitLiteral_4927, %Stack %stack)
        ret void
    
    label_384:
        %environment_247 = call ccc %Environment @objectEnvironment(%Object %fields_240)
        %v_y_2566_13_12_75_4731_pointer_248 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_247, i64 0, i32 0
        %v_y_2566_13_12_75_4731 = load %Pos, ptr %v_y_2566_13_12_75_4731_pointer_248, !noalias !2
        %v_y_2567_14_13_76_4679_pointer_249 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_247, i64 0, i32 1
        %v_y_2567_14_13_76_4679 = load i64, ptr %v_y_2567_14_13_76_4679_pointer_249, !noalias !2
        %v_y_2568_15_14_77_4690_pointer_250 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_247, i64 0, i32 2
        %v_y_2568_15_14_77_4690 = load %Pos, ptr %v_y_2568_15_14_77_4690_pointer_250, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2566_13_12_75_4731)
        call ccc void @sharePositive(%Pos %v_y_2568_15_14_77_4690)
        call ccc void @eraseObject(%Object %fields_240)
        %stackPointer_375 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %v_y_2567_14_13_76_4679_pointer_376 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 0
        store i64 %v_y_2567_14_13_76_4679, ptr %v_y_2567_14_13_76_4679_pointer_376, !noalias !2
        %p_12_47_4709_pointer_377 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 1
        store %Prompt %p_12_47_4709, ptr %p_12_47_4709_pointer_377, !noalias !2
        %cont_10_45_4721_pointer_378 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 2
        store %Reference %cont_10_45_4721, ptr %cont_10_45_4721_pointer_378, !noalias !2
        %v_y_2568_15_14_77_4690_pointer_379 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 3
        store %Pos %v_y_2568_15_14_77_4690, ptr %v_y_2568_15_14_77_4690_pointer_379, !noalias !2
        %v_7_42_4693_pointer_380 = getelementptr <{i64, %Prompt, %Reference, %Pos, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 4
        store %Reference %v_7_42_4693, ptr %v_7_42_4693_pointer_380, !noalias !2
        %returnAddress_pointer_381 = getelementptr <{<{i64, %Prompt, %Reference, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_375, i64 0, i32 1, i32 0
        %sharer_pointer_382 = getelementptr <{<{i64, %Prompt, %Reference, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_375, i64 0, i32 1, i32 1
        %eraser_pointer_383 = getelementptr <{<{i64, %Prompt, %Reference, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_375, i64 0, i32 1, i32 2
        store ptr @returnAddress_251, ptr %returnAddress_pointer_381, !noalias !2
        store ptr @sharer_356, ptr %sharer_pointer_382, !noalias !2
        store ptr @eraser_368, ptr %eraser_pointer_383, !noalias !2
        
        
        
        musttail call tailcc void @iterate_worker_4_3_58_4667(%Pos %v_y_2566_13_12_75_4731, %Reference %v_7_42_4693, %Prompt %p_12_47_4709, %Reference %cont_10_45_4721, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_385(%Pos %__23_88_4755, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_386 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_7_42_4693_pointer_387 = getelementptr <{%Reference}>, %StackPointer %stackPointer_386, i64 0, i32 0
        %v_7_42_4693 = load %Reference, ptr %v_7_42_4693_pointer_387, !noalias !2
        call ccc void @erasePositive(%Pos %__23_88_4755)
        
        %make_4935_temporary_388 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4935 = insertvalue %Pos %make_4935_temporary_388, %Object null, 1
        
        
        
        %v_7_42_4693pointer_389 = call ccc ptr @getVarPointer(%Reference %v_7_42_4693, %Stack %stack)
        %v_7_42_4693_old_390 = load %Pos, ptr %v_7_42_4693pointer_389, !noalias !2
        call ccc void @erasePositive(%Pos %v_7_42_4693_old_390)
        store %Pos %make_4935, ptr %v_7_42_4693pointer_389, !noalias !2
        
        %put_4936_temporary_391 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_4936 = insertvalue %Pos %put_4936_temporary_391, %Object null, 1
        
        %stackPointer_393 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_394 = getelementptr %FrameHeader, %StackPointer %stackPointer_393, i64 0, i32 0
        %returnAddress_392 = load %ReturnAddress, ptr %returnAddress_pointer_394, !noalias !2
        musttail call tailcc void %returnAddress_392(%Pos %put_4936, %Stack %stack)
        ret void
}



define ccc void @sharer_396(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_397 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %v_7_42_4693_395_pointer_398 = getelementptr <{%Reference}>, %StackPointer %stackPointer_397, i64 0, i32 0
        %v_7_42_4693_395 = load %Reference, ptr %v_7_42_4693_395_pointer_398, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_397)
        ret void
}



define ccc void @eraser_400(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_401 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %v_7_42_4693_399_pointer_402 = getelementptr <{%Reference}>, %StackPointer %stackPointer_401, i64 0, i32 0
        %v_7_42_4693_399 = load %Reference, ptr %v_7_42_4693_399_pointer_402, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_401)
        ret void
}



define tailcc void @returnAddress_28(%Pos %tree_4_4688, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_29 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %r_3_4645_pointer_30 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_29, i64 0, i32 0
        %r_3_4645 = load %Prompt, ptr %r_3_4645_pointer_30, !noalias !2
        
        %make_4913_temporary_31 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4913 = insertvalue %Pos %make_4913_temporary_31, %Object null, 1
        
        
        
        %pair_32 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %r_3_4645)
        %temporaryStack_4914 = extractvalue <{%Resumption, %Stack}> %pair_32, 0
        %stack_33 = extractvalue <{%Resumption, %Stack}> %pair_32, 1
        %v_7_42_4693 = call ccc %Reference @newReference(%Stack %stack_33)
        %stackPointer_49 = call ccc %StackPointer @stackAllocate(%Stack %stack_33, i64 40)
        %tmp_4869_pointer_50 = getelementptr <{%Pos}>, %StackPointer %stackPointer_49, i64 0, i32 0
        store %Pos %make_4913, ptr %tmp_4869_pointer_50, !noalias !2
        %returnAddress_pointer_51 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 0
        %sharer_pointer_52 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 1
        %eraser_pointer_53 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_51, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_52, !noalias !2
        store ptr @eraser_46, ptr %eraser_pointer_53, !noalias !2
        
        %stack_54 = call ccc %Stack @resume(%Resumption %temporaryStack_4914, %Stack %stack_33)
        
        %vtable_temporary_61 = insertvalue %Neg zeroinitializer, ptr @vtable_60, 0
        %blockLit_4916 = insertvalue %Neg %vtable_temporary_61, %Object null, 1
        
        %blockLit_4916_4918 = call ccc %Pos @box(%Neg %blockLit_4916)
        
        
        
        %pair_62 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack_54, %Prompt %r_3_4645)
        %temporaryStack_4919 = extractvalue <{%Resumption, %Stack}> %pair_62, 0
        %stack_63 = extractvalue <{%Resumption, %Stack}> %pair_62, 1
        %cont_10_45_4721 = call ccc %Reference @newReference(%Stack %stack_63)
        %stackPointer_73 = call ccc %StackPointer @stackAllocate(%Stack %stack_63, i64 40)
        %tmp_4870_pointer_74 = getelementptr <{%Pos}>, %StackPointer %stackPointer_73, i64 0, i32 0
        store %Pos %blockLit_4916_4918, ptr %tmp_4870_pointer_74, !noalias !2
        %returnAddress_pointer_75 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_73, i64 0, i32 1, i32 0
        %sharer_pointer_76 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_73, i64 0, i32 1, i32 1
        %eraser_pointer_77 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_73, i64 0, i32 1, i32 2
        store ptr @returnAddress_64, ptr %returnAddress_pointer_75, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_76, !noalias !2
        store ptr @eraser_46, ptr %eraser_pointer_77, !noalias !2
        
        %stack_78 = call ccc %Stack @resume(%Resumption %temporaryStack_4919, %Stack %stack_63)
        %stackPointer_223 = call ccc %StackPointer @stackAllocate(%Stack %stack_78, i64 56)
        %v_7_42_4693_pointer_224 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_223, i64 0, i32 0
        store %Reference %v_7_42_4693, ptr %v_7_42_4693_pointer_224, !noalias !2
        %cont_10_45_4721_pointer_225 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_223, i64 0, i32 1
        store %Reference %cont_10_45_4721, ptr %cont_10_45_4721_pointer_225, !noalias !2
        %returnAddress_pointer_226 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_223, i64 0, i32 1, i32 0
        %sharer_pointer_227 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_223, i64 0, i32 1, i32 1
        %eraser_pointer_228 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_223, i64 0, i32 1, i32 2
        store ptr @returnAddress_79, ptr %returnAddress_pointer_226, !noalias !2
        store ptr @sharer_213, ptr %sharer_pointer_227, !noalias !2
        store ptr @eraser_219, ptr %eraser_pointer_228, !noalias !2
        
        %stack_229 = call ccc %Stack @reset(%Stack %stack_78)
        %p_12_47_4709 = call ccc %Prompt @currentPrompt(%Stack %stack_229)
        %stackPointer_235 = call ccc %StackPointer @stackAllocate(%Stack %stack_229, i64 24)
        %returnAddress_pointer_236 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_235, i64 0, i32 1, i32 0
        %sharer_pointer_237 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_235, i64 0, i32 1, i32 1
        %eraser_pointer_238 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_235, i64 0, i32 1, i32 2
        store ptr @returnAddress_230, ptr %returnAddress_pointer_236, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_237, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_238, !noalias !2
        %stackPointer_403 = call ccc %StackPointer @stackAllocate(%Stack %stack_229, i64 40)
        %v_7_42_4693_pointer_404 = getelementptr <{%Reference}>, %StackPointer %stackPointer_403, i64 0, i32 0
        store %Reference %v_7_42_4693, ptr %v_7_42_4693_pointer_404, !noalias !2
        %returnAddress_pointer_405 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 0
        %sharer_pointer_406 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 1
        %eraser_pointer_407 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 2
        store ptr @returnAddress_385, ptr %returnAddress_pointer_405, !noalias !2
        store ptr @sharer_396, ptr %sharer_pointer_406, !noalias !2
        store ptr @eraser_400, ptr %eraser_pointer_407, !noalias !2
        
        
        
        musttail call tailcc void @iterate_worker_4_3_58_4667(%Pos %tree_4_4688, %Reference %v_7_42_4693, %Prompt %p_12_47_4709, %Reference %cont_10_45_4721, %Stack %stack_229)
        ret void
}



define ccc void @sharer_409(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_410 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %r_3_4645_408_pointer_411 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_410, i64 0, i32 0
        %r_3_4645_408 = load %Prompt, ptr %r_3_4645_408_pointer_411, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_410)
        ret void
}



define ccc void @eraser_413(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_414 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %r_3_4645_412_pointer_415 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_414, i64 0, i32 0
        %r_3_4645_412 = load %Prompt, ptr %r_3_4645_412_pointer_415, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_414)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3514_3578, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4908 = call ccc i64 @unboxInt_303(%Pos %v_coe_3514_3578)
        
        
        %stackPointer_10 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 0
        %sharer_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 1
        %eraser_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_11, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_12, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_13, !noalias !2
        
        %stack_14 = call ccc %Stack @reset(%Stack %stack)
        %r_3_4645 = call ccc %Prompt @currentPrompt(%Stack %stack_14)
        %stackPointer_24 = call ccc %StackPointer @stackAllocate(%Stack %stack_14, i64 24)
        %returnAddress_pointer_25 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 0
        %sharer_pointer_26 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 1
        %eraser_pointer_27 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 2
        store ptr @returnAddress_15, ptr %returnAddress_pointer_25, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_26, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_27, !noalias !2
        %stackPointer_416 = call ccc %StackPointer @stackAllocate(%Stack %stack_14, i64 32)
        %r_3_4645_pointer_417 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_416, i64 0, i32 0
        store %Prompt %r_3_4645, ptr %r_3_4645_pointer_417, !noalias !2
        %returnAddress_pointer_418 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_416, i64 0, i32 1, i32 0
        %sharer_pointer_419 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_416, i64 0, i32 1, i32 1
        %eraser_pointer_420 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_416, i64 0, i32 1, i32 2
        store ptr @returnAddress_28, ptr %returnAddress_pointer_418, !noalias !2
        store ptr @sharer_409, ptr %sharer_pointer_419, !noalias !2
        store ptr @eraser_413, ptr %eraser_pointer_420, !noalias !2
        
        
        
        musttail call tailcc void @makeTree_2436(i64 %pureApp_4908, %Stack %stack_14)
        ret void
}



define tailcc void @returnAddress_426(%Pos %returned_4937, %Stack %stack) {
        
    entry:
        
        %stack_427 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_429 = call ccc %StackPointer @stackDeallocate(%Stack %stack_427, i64 24)
        %returnAddress_pointer_430 = getelementptr %FrameHeader, %StackPointer %stackPointer_429, i64 0, i32 0
        %returnAddress_428 = load %ReturnAddress, ptr %returnAddress_pointer_430, !noalias !2
        musttail call tailcc void %returnAddress_428(%Pos %returned_4937, %Stack %stack_427)
        ret void
}



define ccc void @eraser_442(%Environment %environment) {
        
    entry:
        
        %tmp_4842_440_pointer_443 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4842_440 = load %Pos, ptr %tmp_4842_440_pointer_443, !noalias !2
        %acc_3_3_5_169_4322_441_pointer_444 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4322_441 = load %Pos, ptr %acc_3_3_5_169_4322_441_pointer_444, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4842_440)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4322_441)
        ret void
}



define tailcc void @toList_1_1_3_167_4541(i64 %start_2_2_4_168_4417, %Pos %acc_3_3_5_169_4322, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4939 = add i64 1, 0
        
        %pureApp_4938 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4417, i64 %longLiteral_4939)
        
        
        
        %tag_435 = extractvalue %Pos %pureApp_4938, 0
        %fields_436 = extractvalue %Pos %pureApp_4938, 1
        switch i64 %tag_435, label %label_437 [i64 0, label %label_448 i64 1, label %label_452]
    
    label_437:
        
        ret void
    
    label_448:
        
        %pureApp_4940 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4417)
        
        
        
        %longLiteral_4942 = add i64 1, 0
        
        %pureApp_4941 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4417, i64 %longLiteral_4942)
        
        
        
        %fields_438 = call ccc %Object @newObject(ptr @eraser_442, i64 32)
        %environment_439 = call ccc %Environment @objectEnvironment(%Object %fields_438)
        %tmp_4842_pointer_445 = getelementptr <{%Pos, %Pos}>, %Environment %environment_439, i64 0, i32 0
        store %Pos %pureApp_4940, ptr %tmp_4842_pointer_445, !noalias !2
        %acc_3_3_5_169_4322_pointer_446 = getelementptr <{%Pos, %Pos}>, %Environment %environment_439, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4322, ptr %acc_3_3_5_169_4322_pointer_446, !noalias !2
        %make_4943_temporary_447 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4943 = insertvalue %Pos %make_4943_temporary_447, %Object %fields_438, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4541(i64 %pureApp_4941, %Pos %make_4943, %Stack %stack)
        ret void
    
    label_452:
        
        %stackPointer_450 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_451 = getelementptr %FrameHeader, %StackPointer %stackPointer_450, i64 0, i32 0
        %returnAddress_449 = load %ReturnAddress, ptr %returnAddress_pointer_451, !noalias !2
        musttail call tailcc void %returnAddress_449(%Pos %acc_3_3_5_169_4322, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_463(%Pos %v_r_2669_32_59_223_4452, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_464 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %p_8_9_4270_pointer_465 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_464, i64 0, i32 0
        %p_8_9_4270 = load %Prompt, ptr %p_8_9_4270_pointer_465, !noalias !2
        %acc_8_35_199_4301_pointer_466 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_464, i64 0, i32 1
        %acc_8_35_199_4301 = load i64, ptr %acc_8_35_199_4301_pointer_466, !noalias !2
        %v_r_2586_30_194_4436_pointer_467 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_464, i64 0, i32 2
        %v_r_2586_30_194_4436 = load %Pos, ptr %v_r_2586_30_194_4436_pointer_467, !noalias !2
        %tmp_4849_pointer_468 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_464, i64 0, i32 3
        %tmp_4849 = load i64, ptr %tmp_4849_pointer_468, !noalias !2
        %index_7_34_198_4472_pointer_469 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_464, i64 0, i32 4
        %index_7_34_198_4472 = load i64, ptr %index_7_34_198_4472_pointer_469, !noalias !2
        
        %tag_470 = extractvalue %Pos %v_r_2669_32_59_223_4452, 0
        %fields_471 = extractvalue %Pos %v_r_2669_32_59_223_4452, 1
        switch i64 %tag_470, label %label_472 [i64 1, label %label_495 i64 0, label %label_502]
    
    label_472:
        
        ret void
    
    label_477:
        
        ret void
    
    label_483:
        call ccc void @erasePositive(%Pos %v_r_2586_30_194_4436)
        
        %pair_478 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4270)
        %k_13_14_4_4768 = extractvalue <{%Resumption, %Stack}> %pair_478, 0
        %stack_479 = extractvalue <{%Resumption, %Stack}> %pair_478, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4768)
        
        %longLiteral_4955 = add i64 10, 0
        
        
        
        %pureApp_4956 = call ccc %Pos @boxInt_301(i64 %longLiteral_4955)
        
        
        
        %stackPointer_481 = call ccc %StackPointer @stackDeallocate(%Stack %stack_479, i64 24)
        %returnAddress_pointer_482 = getelementptr %FrameHeader, %StackPointer %stackPointer_481, i64 0, i32 0
        %returnAddress_480 = load %ReturnAddress, ptr %returnAddress_pointer_482, !noalias !2
        musttail call tailcc void %returnAddress_480(%Pos %pureApp_4956, %Stack %stack_479)
        ret void
    
    label_486:
        
        ret void
    
    label_492:
        call ccc void @erasePositive(%Pos %v_r_2586_30_194_4436)
        
        %pair_487 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4270)
        %k_13_14_4_4767 = extractvalue <{%Resumption, %Stack}> %pair_487, 0
        %stack_488 = extractvalue <{%Resumption, %Stack}> %pair_487, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4767)
        
        %longLiteral_4959 = add i64 10, 0
        
        
        
        %pureApp_4960 = call ccc %Pos @boxInt_301(i64 %longLiteral_4959)
        
        
        
        %stackPointer_490 = call ccc %StackPointer @stackDeallocate(%Stack %stack_488, i64 24)
        %returnAddress_pointer_491 = getelementptr %FrameHeader, %StackPointer %stackPointer_490, i64 0, i32 0
        %returnAddress_489 = load %ReturnAddress, ptr %returnAddress_pointer_491, !noalias !2
        musttail call tailcc void %returnAddress_489(%Pos %pureApp_4960, %Stack %stack_488)
        ret void
    
    label_493:
        
        %longLiteral_4962 = add i64 1, 0
        
        %pureApp_4961 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4472, i64 %longLiteral_4962)
        
        
        
        %longLiteral_4964 = add i64 10, 0
        
        %pureApp_4963 = call ccc i64 @infixMul_99(i64 %longLiteral_4964, i64 %acc_8_35_199_4301)
        
        
        
        %pureApp_4965 = call ccc i64 @toInt_2085(i64 %pureApp_4952)
        
        
        
        %pureApp_4966 = call ccc i64 @infixSub_105(i64 %pureApp_4965, i64 %tmp_4849)
        
        
        
        %pureApp_4967 = call ccc i64 @infixAdd_96(i64 %pureApp_4963, i64 %pureApp_4966)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4427(i64 %pureApp_4961, i64 %pureApp_4967, i64 %tmp_4849, %Prompt %p_8_9_4270, %Pos %v_r_2586_30_194_4436, %Stack %stack)
        ret void
    
    label_494:
        
        %intLiteral_4958 = add i64 57, 0
        
        %pureApp_4957 = call ccc %Pos @infixLte_2093(i64 %pureApp_4952, i64 %intLiteral_4958)
        
        
        
        %tag_484 = extractvalue %Pos %pureApp_4957, 0
        %fields_485 = extractvalue %Pos %pureApp_4957, 1
        switch i64 %tag_484, label %label_486 [i64 0, label %label_492 i64 1, label %label_493]
    
    label_495:
        %environment_473 = call ccc %Environment @objectEnvironment(%Object %fields_471)
        %v_coe_3485_46_73_237_4466_pointer_474 = getelementptr <{%Pos}>, %Environment %environment_473, i64 0, i32 0
        %v_coe_3485_46_73_237_4466 = load %Pos, ptr %v_coe_3485_46_73_237_4466_pointer_474, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3485_46_73_237_4466)
        call ccc void @eraseObject(%Object %fields_471)
        
        %pureApp_4952 = call ccc i64 @unboxChar_313(%Pos %v_coe_3485_46_73_237_4466)
        
        
        
        %intLiteral_4954 = add i64 48, 0
        
        %pureApp_4953 = call ccc %Pos @infixGte_2099(i64 %pureApp_4952, i64 %intLiteral_4954)
        
        
        
        %tag_475 = extractvalue %Pos %pureApp_4953, 0
        %fields_476 = extractvalue %Pos %pureApp_4953, 1
        switch i64 %tag_475, label %label_477 [i64 0, label %label_483 i64 1, label %label_494]
    
    label_502:
        %environment_496 = call ccc %Environment @objectEnvironment(%Object %fields_471)
        %v_y_2676_76_103_267_4950_pointer_497 = getelementptr <{%Pos, %Pos}>, %Environment %environment_496, i64 0, i32 0
        %v_y_2676_76_103_267_4950 = load %Pos, ptr %v_y_2676_76_103_267_4950_pointer_497, !noalias !2
        %v_y_2677_77_104_268_4951_pointer_498 = getelementptr <{%Pos, %Pos}>, %Environment %environment_496, i64 0, i32 1
        %v_y_2677_77_104_268_4951 = load %Pos, ptr %v_y_2677_77_104_268_4951_pointer_498, !noalias !2
        call ccc void @eraseObject(%Object %fields_471)
        call ccc void @erasePositive(%Pos %v_r_2586_30_194_4436)
        
        %stackPointer_500 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_501 = getelementptr %FrameHeader, %StackPointer %stackPointer_500, i64 0, i32 0
        %returnAddress_499 = load %ReturnAddress, ptr %returnAddress_pointer_501, !noalias !2
        musttail call tailcc void %returnAddress_499(i64 %acc_8_35_199_4301, %Stack %stack)
        ret void
}



define ccc void @sharer_508(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_509 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4270_503_pointer_510 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_509, i64 0, i32 0
        %p_8_9_4270_503 = load %Prompt, ptr %p_8_9_4270_503_pointer_510, !noalias !2
        %acc_8_35_199_4301_504_pointer_511 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_509, i64 0, i32 1
        %acc_8_35_199_4301_504 = load i64, ptr %acc_8_35_199_4301_504_pointer_511, !noalias !2
        %v_r_2586_30_194_4436_505_pointer_512 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_509, i64 0, i32 2
        %v_r_2586_30_194_4436_505 = load %Pos, ptr %v_r_2586_30_194_4436_505_pointer_512, !noalias !2
        %tmp_4849_506_pointer_513 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_509, i64 0, i32 3
        %tmp_4849_506 = load i64, ptr %tmp_4849_506_pointer_513, !noalias !2
        %index_7_34_198_4472_507_pointer_514 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_509, i64 0, i32 4
        %index_7_34_198_4472_507 = load i64, ptr %index_7_34_198_4472_507_pointer_514, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2586_30_194_4436_505)
        call ccc void @shareFrames(%StackPointer %stackPointer_509)
        ret void
}



define ccc void @eraser_520(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_521 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4270_515_pointer_522 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_521, i64 0, i32 0
        %p_8_9_4270_515 = load %Prompt, ptr %p_8_9_4270_515_pointer_522, !noalias !2
        %acc_8_35_199_4301_516_pointer_523 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_521, i64 0, i32 1
        %acc_8_35_199_4301_516 = load i64, ptr %acc_8_35_199_4301_516_pointer_523, !noalias !2
        %v_r_2586_30_194_4436_517_pointer_524 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_521, i64 0, i32 2
        %v_r_2586_30_194_4436_517 = load %Pos, ptr %v_r_2586_30_194_4436_517_pointer_524, !noalias !2
        %tmp_4849_518_pointer_525 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_521, i64 0, i32 3
        %tmp_4849_518 = load i64, ptr %tmp_4849_518_pointer_525, !noalias !2
        %index_7_34_198_4472_519_pointer_526 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_521, i64 0, i32 4
        %index_7_34_198_4472_519 = load i64, ptr %index_7_34_198_4472_519_pointer_526, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2586_30_194_4436_517)
        call ccc void @eraseFrames(%StackPointer %stackPointer_521)
        ret void
}



define tailcc void @returnAddress_537(%Pos %returned_4968, %Stack %stack) {
        
    entry:
        
        %stack_538 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_540 = call ccc %StackPointer @stackDeallocate(%Stack %stack_538, i64 24)
        %returnAddress_pointer_541 = getelementptr %FrameHeader, %StackPointer %stackPointer_540, i64 0, i32 0
        %returnAddress_539 = load %ReturnAddress, ptr %returnAddress_pointer_541, !noalias !2
        musttail call tailcc void %returnAddress_539(%Pos %returned_4968, %Stack %stack_538)
        ret void
}



define tailcc void @Exception_7_19_46_210_4423_clause_546(%Object %closure, %Pos %exc_8_20_47_211_4382, %Pos %msg_9_21_48_212_4576, %Stack %stack) {
        
    entry:
        
        %environment_547 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4505_pointer_548 = getelementptr <{%Prompt}>, %Environment %environment_547, i64 0, i32 0
        %p_6_18_45_209_4505 = load %Prompt, ptr %p_6_18_45_209_4505_pointer_548, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_549 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4505)
        %k_11_23_50_214_4593 = extractvalue <{%Resumption, %Stack}> %pair_549, 0
        %stack_550 = extractvalue <{%Resumption, %Stack}> %pair_549, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4593)
        
        %fields_551 = call ccc %Object @newObject(ptr @eraser_442, i64 32)
        %environment_552 = call ccc %Environment @objectEnvironment(%Object %fields_551)
        %exc_8_20_47_211_4382_pointer_555 = getelementptr <{%Pos, %Pos}>, %Environment %environment_552, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4382, ptr %exc_8_20_47_211_4382_pointer_555, !noalias !2
        %msg_9_21_48_212_4576_pointer_556 = getelementptr <{%Pos, %Pos}>, %Environment %environment_552, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4576, ptr %msg_9_21_48_212_4576_pointer_556, !noalias !2
        %make_4969_temporary_557 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4969 = insertvalue %Pos %make_4969_temporary_557, %Object %fields_551, 1
        
        
        
        %stackPointer_559 = call ccc %StackPointer @stackDeallocate(%Stack %stack_550, i64 24)
        %returnAddress_pointer_560 = getelementptr %FrameHeader, %StackPointer %stackPointer_559, i64 0, i32 0
        %returnAddress_558 = load %ReturnAddress, ptr %returnAddress_pointer_560, !noalias !2
        musttail call tailcc void %returnAddress_558(%Pos %make_4969, %Stack %stack_550)
        ret void
}


@vtable_561 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4423_clause_546]


define ccc void @eraser_565(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4505_564_pointer_566 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4505_564 = load %Prompt, ptr %p_6_18_45_209_4505_564_pointer_566, !noalias !2
        ret void
}



define tailcc void @returnAddress_569(i64 %v_coe_3484_6_28_55_219_4344, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4970 = call ccc %Pos @boxChar_311(i64 %v_coe_3484_6_28_55_219_4344)
        
        
        
        %fields_570 = call ccc %Object @newObject(ptr @eraser_297, i64 16)
        %environment_571 = call ccc %Environment @objectEnvironment(%Object %fields_570)
        %tmp_4851_pointer_573 = getelementptr <{%Pos}>, %Environment %environment_571, i64 0, i32 0
        store %Pos %pureApp_4970, ptr %tmp_4851_pointer_573, !noalias !2
        %make_4971_temporary_574 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4971 = insertvalue %Pos %make_4971_temporary_574, %Object %fields_570, 1
        
        
        
        %stackPointer_576 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_577 = getelementptr %FrameHeader, %StackPointer %stackPointer_576, i64 0, i32 0
        %returnAddress_575 = load %ReturnAddress, ptr %returnAddress_pointer_577, !noalias !2
        musttail call tailcc void %returnAddress_575(%Pos %make_4971, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4427(i64 %index_7_34_198_4472, i64 %acc_8_35_199_4301, i64 %tmp_4849, %Prompt %p_8_9_4270, %Pos %v_r_2586_30_194_4436, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2586_30_194_4436)
        %stackPointer_527 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %p_8_9_4270_pointer_528 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_527, i64 0, i32 0
        store %Prompt %p_8_9_4270, ptr %p_8_9_4270_pointer_528, !noalias !2
        %acc_8_35_199_4301_pointer_529 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_527, i64 0, i32 1
        store i64 %acc_8_35_199_4301, ptr %acc_8_35_199_4301_pointer_529, !noalias !2
        %v_r_2586_30_194_4436_pointer_530 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_527, i64 0, i32 2
        store %Pos %v_r_2586_30_194_4436, ptr %v_r_2586_30_194_4436_pointer_530, !noalias !2
        %tmp_4849_pointer_531 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_527, i64 0, i32 3
        store i64 %tmp_4849, ptr %tmp_4849_pointer_531, !noalias !2
        %index_7_34_198_4472_pointer_532 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_527, i64 0, i32 4
        store i64 %index_7_34_198_4472, ptr %index_7_34_198_4472_pointer_532, !noalias !2
        %returnAddress_pointer_533 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 0
        %sharer_pointer_534 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 1
        %eraser_pointer_535 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 2
        store ptr @returnAddress_463, ptr %returnAddress_pointer_533, !noalias !2
        store ptr @sharer_508, ptr %sharer_pointer_534, !noalias !2
        store ptr @eraser_520, ptr %eraser_pointer_535, !noalias !2
        
        %stack_536 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4505 = call ccc %Prompt @currentPrompt(%Stack %stack_536)
        %stackPointer_542 = call ccc %StackPointer @stackAllocate(%Stack %stack_536, i64 24)
        %returnAddress_pointer_543 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_542, i64 0, i32 1, i32 0
        %sharer_pointer_544 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_542, i64 0, i32 1, i32 1
        %eraser_pointer_545 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_542, i64 0, i32 1, i32 2
        store ptr @returnAddress_537, ptr %returnAddress_pointer_543, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_544, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_545, !noalias !2
        
        %closure_562 = call ccc %Object @newObject(ptr @eraser_565, i64 8)
        %environment_563 = call ccc %Environment @objectEnvironment(%Object %closure_562)
        %p_6_18_45_209_4505_pointer_567 = getelementptr <{%Prompt}>, %Environment %environment_563, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4505, ptr %p_6_18_45_209_4505_pointer_567, !noalias !2
        %vtable_temporary_568 = insertvalue %Neg zeroinitializer, ptr @vtable_561, 0
        %Exception_7_19_46_210_4423 = insertvalue %Neg %vtable_temporary_568, %Object %closure_562, 1
        %stackPointer_578 = call ccc %StackPointer @stackAllocate(%Stack %stack_536, i64 24)
        %returnAddress_pointer_579 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_578, i64 0, i32 1, i32 0
        %sharer_pointer_580 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_578, i64 0, i32 1, i32 1
        %eraser_pointer_581 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_578, i64 0, i32 1, i32 2
        store ptr @returnAddress_569, ptr %returnAddress_pointer_579, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_580, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_581, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2586_30_194_4436, i64 %index_7_34_198_4472, %Neg %Exception_7_19_46_210_4423, %Stack %stack_536)
        ret void
}



define tailcc void @Exception_9_106_133_297_4455_clause_582(%Object %closure, %Pos %exception_10_107_134_298_4972, %Pos %msg_11_108_135_299_4973, %Stack %stack) {
        
    entry:
        
        %environment_583 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4270_pointer_584 = getelementptr <{%Prompt}>, %Environment %environment_583, i64 0, i32 0
        %p_8_9_4270 = load %Prompt, ptr %p_8_9_4270_pointer_584, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4972)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4973)
        
        %pair_585 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4270)
        %k_13_14_4_4829 = extractvalue <{%Resumption, %Stack}> %pair_585, 0
        %stack_586 = extractvalue <{%Resumption, %Stack}> %pair_585, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4829)
        
        %longLiteral_4974 = add i64 10, 0
        
        
        
        %pureApp_4975 = call ccc %Pos @boxInt_301(i64 %longLiteral_4974)
        
        
        
        %stackPointer_588 = call ccc %StackPointer @stackDeallocate(%Stack %stack_586, i64 24)
        %returnAddress_pointer_589 = getelementptr %FrameHeader, %StackPointer %stackPointer_588, i64 0, i32 0
        %returnAddress_587 = load %ReturnAddress, ptr %returnAddress_pointer_589, !noalias !2
        musttail call tailcc void %returnAddress_587(%Pos %pureApp_4975, %Stack %stack_586)
        ret void
}


@vtable_590 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4455_clause_582]


define tailcc void @returnAddress_601(i64 %v_coe_3489_22_131_158_322_4465, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4978 = call ccc %Pos @boxInt_301(i64 %v_coe_3489_22_131_158_322_4465)
        
        
        
        
        
        %pureApp_4979 = call ccc i64 @unboxInt_303(%Pos %pureApp_4978)
        
        
        
        %pureApp_4980 = call ccc %Pos @boxInt_301(i64 %pureApp_4979)
        
        
        
        %stackPointer_603 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_604 = getelementptr %FrameHeader, %StackPointer %stackPointer_603, i64 0, i32 0
        %returnAddress_602 = load %ReturnAddress, ptr %returnAddress_pointer_604, !noalias !2
        musttail call tailcc void %returnAddress_602(%Pos %pureApp_4980, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_613(i64 %v_r_2683_1_9_20_129_156_320_4543, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4984 = add i64 0, 0
        
        %pureApp_4983 = call ccc i64 @infixSub_105(i64 %longLiteral_4984, i64 %v_r_2683_1_9_20_129_156_320_4543)
        
        
        
        %stackPointer_615 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_616 = getelementptr %FrameHeader, %StackPointer %stackPointer_615, i64 0, i32 0
        %returnAddress_614 = load %ReturnAddress, ptr %returnAddress_pointer_616, !noalias !2
        musttail call tailcc void %returnAddress_614(i64 %pureApp_4983, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_596(i64 %v_r_2682_3_14_123_150_314_4403, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_597 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_4849_pointer_598 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_597, i64 0, i32 0
        %tmp_4849 = load i64, ptr %tmp_4849_pointer_598, !noalias !2
        %p_8_9_4270_pointer_599 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_597, i64 0, i32 1
        %p_8_9_4270 = load %Prompt, ptr %p_8_9_4270_pointer_599, !noalias !2
        %v_r_2586_30_194_4436_pointer_600 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_597, i64 0, i32 2
        %v_r_2586_30_194_4436 = load %Pos, ptr %v_r_2586_30_194_4436_pointer_600, !noalias !2
        
        %intLiteral_4977 = add i64 45, 0
        
        %pureApp_4976 = call ccc %Pos @infixEq_78(i64 %v_r_2682_3_14_123_150_314_4403, i64 %intLiteral_4977)
        
        
        %stackPointer_605 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_606 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 0
        %sharer_pointer_607 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 1
        %eraser_pointer_608 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 2
        store ptr @returnAddress_601, ptr %returnAddress_pointer_606, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_607, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_608, !noalias !2
        
        %tag_609 = extractvalue %Pos %pureApp_4976, 0
        %fields_610 = extractvalue %Pos %pureApp_4976, 1
        switch i64 %tag_609, label %label_611 [i64 0, label %label_612 i64 1, label %label_621]
    
    label_611:
        
        ret void
    
    label_612:
        
        %longLiteral_4981 = add i64 0, 0
        
        %longLiteral_4982 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4427(i64 %longLiteral_4981, i64 %longLiteral_4982, i64 %tmp_4849, %Prompt %p_8_9_4270, %Pos %v_r_2586_30_194_4436, %Stack %stack)
        ret void
    
    label_621:
        %stackPointer_617 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_618 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_617, i64 0, i32 1, i32 0
        %sharer_pointer_619 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_617, i64 0, i32 1, i32 1
        %eraser_pointer_620 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_617, i64 0, i32 1, i32 2
        store ptr @returnAddress_613, ptr %returnAddress_pointer_618, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_619, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_620, !noalias !2
        
        %longLiteral_4985 = add i64 1, 0
        
        %longLiteral_4986 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4427(i64 %longLiteral_4985, i64 %longLiteral_4986, i64 %tmp_4849, %Prompt %p_8_9_4270, %Pos %v_r_2586_30_194_4436, %Stack %stack)
        ret void
}



define ccc void @sharer_625(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_626 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_4849_622_pointer_627 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_626, i64 0, i32 0
        %tmp_4849_622 = load i64, ptr %tmp_4849_622_pointer_627, !noalias !2
        %p_8_9_4270_623_pointer_628 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_626, i64 0, i32 1
        %p_8_9_4270_623 = load %Prompt, ptr %p_8_9_4270_623_pointer_628, !noalias !2
        %v_r_2586_30_194_4436_624_pointer_629 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_626, i64 0, i32 2
        %v_r_2586_30_194_4436_624 = load %Pos, ptr %v_r_2586_30_194_4436_624_pointer_629, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2586_30_194_4436_624)
        call ccc void @shareFrames(%StackPointer %stackPointer_626)
        ret void
}



define ccc void @eraser_633(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_634 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_4849_630_pointer_635 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_634, i64 0, i32 0
        %tmp_4849_630 = load i64, ptr %tmp_4849_630_pointer_635, !noalias !2
        %p_8_9_4270_631_pointer_636 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_634, i64 0, i32 1
        %p_8_9_4270_631 = load %Prompt, ptr %p_8_9_4270_631_pointer_636, !noalias !2
        %v_r_2586_30_194_4436_632_pointer_637 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_634, i64 0, i32 2
        %v_r_2586_30_194_4436_632 = load %Pos, ptr %v_r_2586_30_194_4436_632_pointer_637, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2586_30_194_4436_632)
        call ccc void @eraseFrames(%StackPointer %stackPointer_634)
        ret void
}



define tailcc void @returnAddress_460(%Pos %v_r_2586_30_194_4436, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_461 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4270_pointer_462 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_461, i64 0, i32 0
        %p_8_9_4270 = load %Prompt, ptr %p_8_9_4270_pointer_462, !noalias !2
        
        %intLiteral_4949 = add i64 48, 0
        
        %pureApp_4948 = call ccc i64 @toInt_2085(i64 %intLiteral_4949)
        
        
        
        %closure_591 = call ccc %Object @newObject(ptr @eraser_565, i64 8)
        %environment_592 = call ccc %Environment @objectEnvironment(%Object %closure_591)
        %p_8_9_4270_pointer_594 = getelementptr <{%Prompt}>, %Environment %environment_592, i64 0, i32 0
        store %Prompt %p_8_9_4270, ptr %p_8_9_4270_pointer_594, !noalias !2
        %vtable_temporary_595 = insertvalue %Neg zeroinitializer, ptr @vtable_590, 0
        %Exception_9_106_133_297_4455 = insertvalue %Neg %vtable_temporary_595, %Object %closure_591, 1
        call ccc void @sharePositive(%Pos %v_r_2586_30_194_4436)
        %stackPointer_638 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_4849_pointer_639 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_638, i64 0, i32 0
        store i64 %pureApp_4948, ptr %tmp_4849_pointer_639, !noalias !2
        %p_8_9_4270_pointer_640 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_638, i64 0, i32 1
        store %Prompt %p_8_9_4270, ptr %p_8_9_4270_pointer_640, !noalias !2
        %v_r_2586_30_194_4436_pointer_641 = getelementptr <{i64, %Prompt, %Pos}>, %StackPointer %stackPointer_638, i64 0, i32 2
        store %Pos %v_r_2586_30_194_4436, ptr %v_r_2586_30_194_4436_pointer_641, !noalias !2
        %returnAddress_pointer_642 = getelementptr <{<{i64, %Prompt, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_638, i64 0, i32 1, i32 0
        %sharer_pointer_643 = getelementptr <{<{i64, %Prompt, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_638, i64 0, i32 1, i32 1
        %eraser_pointer_644 = getelementptr <{<{i64, %Prompt, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_638, i64 0, i32 1, i32 2
        store ptr @returnAddress_596, ptr %returnAddress_pointer_642, !noalias !2
        store ptr @sharer_625, ptr %sharer_pointer_643, !noalias !2
        store ptr @eraser_633, ptr %eraser_pointer_644, !noalias !2
        
        %longLiteral_4987 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2586_30_194_4436, i64 %longLiteral_4987, %Neg %Exception_9_106_133_297_4455, %Stack %stack)
        ret void
}


@utf8StringLiteral_4988.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_457(%Pos %v_r_2585_24_188_4338, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_458 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4270_pointer_459 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_458, i64 0, i32 0
        %p_8_9_4270 = load %Prompt, ptr %p_8_9_4270_pointer_459, !noalias !2
        %stackPointer_647 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4270_pointer_648 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_647, i64 0, i32 0
        store %Prompt %p_8_9_4270, ptr %p_8_9_4270_pointer_648, !noalias !2
        %returnAddress_pointer_649 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_647, i64 0, i32 1, i32 0
        %sharer_pointer_650 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_647, i64 0, i32 1, i32 1
        %eraser_pointer_651 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_647, i64 0, i32 1, i32 2
        store ptr @returnAddress_460, ptr %returnAddress_pointer_649, !noalias !2
        store ptr @sharer_409, ptr %sharer_pointer_650, !noalias !2
        store ptr @eraser_413, ptr %eraser_pointer_651, !noalias !2
        
        %tag_652 = extractvalue %Pos %v_r_2585_24_188_4338, 0
        %fields_653 = extractvalue %Pos %v_r_2585_24_188_4338, 1
        switch i64 %tag_652, label %label_654 [i64 0, label %label_658 i64 1, label %label_664]
    
    label_654:
        
        ret void
    
    label_658:
        
        %utf8StringLiteral_4988 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4988.lit)
        
        %stackPointer_656 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_657 = getelementptr %FrameHeader, %StackPointer %stackPointer_656, i64 0, i32 0
        %returnAddress_655 = load %ReturnAddress, ptr %returnAddress_pointer_657, !noalias !2
        musttail call tailcc void %returnAddress_655(%Pos %utf8StringLiteral_4988, %Stack %stack)
        ret void
    
    label_664:
        %environment_659 = call ccc %Environment @objectEnvironment(%Object %fields_653)
        %v_y_3311_8_29_193_4488_pointer_660 = getelementptr <{%Pos}>, %Environment %environment_659, i64 0, i32 0
        %v_y_3311_8_29_193_4488 = load %Pos, ptr %v_y_3311_8_29_193_4488_pointer_660, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3311_8_29_193_4488)
        call ccc void @eraseObject(%Object %fields_653)
        
        %stackPointer_662 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_663 = getelementptr %FrameHeader, %StackPointer %stackPointer_662, i64 0, i32 0
        %returnAddress_661 = load %ReturnAddress, ptr %returnAddress_pointer_663, !noalias !2
        musttail call tailcc void %returnAddress_661(%Pos %v_y_3311_8_29_193_4488, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_454(%Pos %v_r_2584_13_177_4413, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_455 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4270_pointer_456 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_455, i64 0, i32 0
        %p_8_9_4270 = load %Prompt, ptr %p_8_9_4270_pointer_456, !noalias !2
        %stackPointer_667 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4270_pointer_668 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_667, i64 0, i32 0
        store %Prompt %p_8_9_4270, ptr %p_8_9_4270_pointer_668, !noalias !2
        %returnAddress_pointer_669 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_667, i64 0, i32 1, i32 0
        %sharer_pointer_670 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_667, i64 0, i32 1, i32 1
        %eraser_pointer_671 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_667, i64 0, i32 1, i32 2
        store ptr @returnAddress_457, ptr %returnAddress_pointer_669, !noalias !2
        store ptr @sharer_409, ptr %sharer_pointer_670, !noalias !2
        store ptr @eraser_413, ptr %eraser_pointer_671, !noalias !2
        
        %tag_672 = extractvalue %Pos %v_r_2584_13_177_4413, 0
        %fields_673 = extractvalue %Pos %v_r_2584_13_177_4413, 1
        switch i64 %tag_672, label %label_674 [i64 0, label %label_679 i64 1, label %label_691]
    
    label_674:
        
        ret void
    
    label_679:
        
        %make_4989_temporary_675 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4989 = insertvalue %Pos %make_4989_temporary_675, %Object null, 1
        
        
        
        %stackPointer_677 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_678 = getelementptr %FrameHeader, %StackPointer %stackPointer_677, i64 0, i32 0
        %returnAddress_676 = load %ReturnAddress, ptr %returnAddress_pointer_678, !noalias !2
        musttail call tailcc void %returnAddress_676(%Pos %make_4989, %Stack %stack)
        ret void
    
    label_691:
        %environment_680 = call ccc %Environment @objectEnvironment(%Object %fields_673)
        %v_y_2820_10_21_185_4433_pointer_681 = getelementptr <{%Pos, %Pos}>, %Environment %environment_680, i64 0, i32 0
        %v_y_2820_10_21_185_4433 = load %Pos, ptr %v_y_2820_10_21_185_4433_pointer_681, !noalias !2
        %v_y_2821_11_22_186_4580_pointer_682 = getelementptr <{%Pos, %Pos}>, %Environment %environment_680, i64 0, i32 1
        %v_y_2821_11_22_186_4580 = load %Pos, ptr %v_y_2821_11_22_186_4580_pointer_682, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2820_10_21_185_4433)
        call ccc void @eraseObject(%Object %fields_673)
        
        %fields_683 = call ccc %Object @newObject(ptr @eraser_297, i64 16)
        %environment_684 = call ccc %Environment @objectEnvironment(%Object %fields_683)
        %v_y_2820_10_21_185_4433_pointer_686 = getelementptr <{%Pos}>, %Environment %environment_684, i64 0, i32 0
        store %Pos %v_y_2820_10_21_185_4433, ptr %v_y_2820_10_21_185_4433_pointer_686, !noalias !2
        %make_4990_temporary_687 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4990 = insertvalue %Pos %make_4990_temporary_687, %Object %fields_683, 1
        
        
        
        %stackPointer_689 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_690 = getelementptr %FrameHeader, %StackPointer %stackPointer_689, i64 0, i32 0
        %returnAddress_688 = load %ReturnAddress, ptr %returnAddress_pointer_690, !noalias !2
        musttail call tailcc void %returnAddress_688(%Pos %make_4990, %Stack %stack)
        ret void
}



define tailcc void @main_2444(%Stack %stack) {
        
    entry:
        
        %stackPointer_421 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_422 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_421, i64 0, i32 1, i32 0
        %sharer_pointer_423 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_421, i64 0, i32 1, i32 1
        %eraser_pointer_424 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_421, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_422, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_423, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_424, !noalias !2
        
        %stack_425 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4270 = call ccc %Prompt @currentPrompt(%Stack %stack_425)
        %stackPointer_431 = call ccc %StackPointer @stackAllocate(%Stack %stack_425, i64 24)
        %returnAddress_pointer_432 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_431, i64 0, i32 1, i32 0
        %sharer_pointer_433 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_431, i64 0, i32 1, i32 1
        %eraser_pointer_434 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_431, i64 0, i32 1, i32 2
        store ptr @returnAddress_426, ptr %returnAddress_pointer_432, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_433, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_434, !noalias !2
        
        %pureApp_4944 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4946 = add i64 1, 0
        
        %pureApp_4945 = call ccc i64 @infixSub_105(i64 %pureApp_4944, i64 %longLiteral_4946)
        
        
        
        %make_4947_temporary_453 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4947 = insertvalue %Pos %make_4947_temporary_453, %Object null, 1
        
        
        %stackPointer_694 = call ccc %StackPointer @stackAllocate(%Stack %stack_425, i64 32)
        %p_8_9_4270_pointer_695 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_694, i64 0, i32 0
        store %Prompt %p_8_9_4270, ptr %p_8_9_4270_pointer_695, !noalias !2
        %returnAddress_pointer_696 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_694, i64 0, i32 1, i32 0
        %sharer_pointer_697 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_694, i64 0, i32 1, i32 1
        %eraser_pointer_698 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_694, i64 0, i32 1, i32 2
        store ptr @returnAddress_454, ptr %returnAddress_pointer_696, !noalias !2
        store ptr @sharer_409, ptr %sharer_pointer_697, !noalias !2
        store ptr @eraser_413, ptr %eraser_pointer_698, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4541(i64 %pureApp_4945, %Pos %make_4947, %Stack %stack_425)
        ret void
}



define ccc void @eraser_710(%Environment %environment) {
        
    entry:
        
        %sub_2457_707_pointer_711 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment, i64 0, i32 0
        %sub_2457_707 = load %Pos, ptr %sub_2457_707_pointer_711, !noalias !2
        %n_2435_708_pointer_712 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment, i64 0, i32 1
        %n_2435_708 = load i64, ptr %n_2435_708_pointer_712, !noalias !2
        %sub_2457_709_pointer_713 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment, i64 0, i32 2
        %sub_2457_709 = load %Pos, ptr %sub_2457_709_pointer_713, !noalias !2
        call ccc void @erasePositive(%Pos %sub_2457_707)
        call ccc void @erasePositive(%Pos %sub_2457_709)
        ret void
}



define tailcc void @returnAddress_702(%Pos %sub_2457, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_703 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %n_2435_pointer_704 = getelementptr <{i64}>, %StackPointer %stackPointer_703, i64 0, i32 0
        %n_2435 = load i64, ptr %n_2435_pointer_704, !noalias !2
        
        %fields_705 = call ccc %Object @newObject(ptr @eraser_710, i64 40)
        %environment_706 = call ccc %Environment @objectEnvironment(%Object %fields_705)
        call ccc void @sharePositive(%Pos %sub_2457)
        %sub_2457_pointer_714 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_706, i64 0, i32 0
        store %Pos %sub_2457, ptr %sub_2457_pointer_714, !noalias !2
        %n_2435_pointer_715 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_706, i64 0, i32 1
        store i64 %n_2435, ptr %n_2435_pointer_715, !noalias !2
        %sub_2457_pointer_716 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_706, i64 0, i32 2
        store %Pos %sub_2457, ptr %sub_2457_pointer_716, !noalias !2
        %make_4906_temporary_717 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4906 = insertvalue %Pos %make_4906_temporary_717, %Object %fields_705, 1
        
        
        
        %stackPointer_719 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_720 = getelementptr %FrameHeader, %StackPointer %stackPointer_719, i64 0, i32 0
        %returnAddress_718 = load %ReturnAddress, ptr %returnAddress_pointer_720, !noalias !2
        musttail call tailcc void %returnAddress_718(%Pos %make_4906, %Stack %stack)
        ret void
}



define ccc void @sharer_722(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_723 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %n_2435_721_pointer_724 = getelementptr <{i64}>, %StackPointer %stackPointer_723, i64 0, i32 0
        %n_2435_721 = load i64, ptr %n_2435_721_pointer_724, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_723)
        ret void
}



define ccc void @eraser_726(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_727 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %n_2435_725_pointer_728 = getelementptr <{i64}>, %StackPointer %stackPointer_727, i64 0, i32 0
        %n_2435_725 = load i64, ptr %n_2435_725_pointer_728, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_727)
        ret void
}



define tailcc void @makeTree_2436(i64 %n_2435, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4903 = add i64 0, 0
        
        %pureApp_4902 = call ccc %Pos @infixEq_72(i64 %n_2435, i64 %longLiteral_4903)
        
        
        
        %tag_699 = extractvalue %Pos %pureApp_4902, 0
        %fields_700 = extractvalue %Pos %pureApp_4902, 1
        switch i64 %tag_699, label %label_701 [i64 0, label %label_734 i64 1, label %label_739]
    
    label_701:
        
        ret void
    
    label_734:
        
        %longLiteral_4905 = add i64 1, 0
        
        %pureApp_4904 = call ccc i64 @infixSub_105(i64 %n_2435, i64 %longLiteral_4905)
        
        
        %stackPointer_729 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %n_2435_pointer_730 = getelementptr <{i64}>, %StackPointer %stackPointer_729, i64 0, i32 0
        store i64 %n_2435, ptr %n_2435_pointer_730, !noalias !2
        %returnAddress_pointer_731 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_729, i64 0, i32 1, i32 0
        %sharer_pointer_732 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_729, i64 0, i32 1, i32 1
        %eraser_pointer_733 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_729, i64 0, i32 1, i32 2
        store ptr @returnAddress_702, ptr %returnAddress_pointer_731, !noalias !2
        store ptr @sharer_722, ptr %sharer_pointer_732, !noalias !2
        store ptr @eraser_726, ptr %eraser_pointer_733, !noalias !2
        
        
        
        musttail call tailcc void @makeTree_2436(i64 %pureApp_4904, %Stack %stack)
        ret void
    
    label_739:
        
        %make_4907_temporary_735 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4907 = insertvalue %Pos %make_4907_temporary_735, %Object null, 1
        
        
        
        %stackPointer_737 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_738 = getelementptr %FrameHeader, %StackPointer %stackPointer_737, i64 0, i32 0
        %returnAddress_736 = load %ReturnAddress, ptr %returnAddress_pointer_738, !noalias !2
        musttail call tailcc void %returnAddress_736(%Pos %make_4907, %Stack %stack)
        ret void
}


@utf8StringLiteral_4893.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4895.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4898.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_740(%Pos %v_r_2751_3545, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_741 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_742 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_741, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_742, !noalias !2
        %index_2107_pointer_743 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_741, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_743, !noalias !2
        %Exception_2362_pointer_744 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_741, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_744, !noalias !2
        
        %tag_745 = extractvalue %Pos %v_r_2751_3545, 0
        %fields_746 = extractvalue %Pos %v_r_2751_3545, 1
        switch i64 %tag_745, label %label_747 [i64 0, label %label_751 i64 1, label %label_757]
    
    label_747:
        
        ret void
    
    label_751:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4889 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_749 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_750 = getelementptr %FrameHeader, %StackPointer %stackPointer_749, i64 0, i32 0
        %returnAddress_748 = load %ReturnAddress, ptr %returnAddress_pointer_750, !noalias !2
        musttail call tailcc void %returnAddress_748(i64 %pureApp_4889, %Stack %stack)
        ret void
    
    label_757:
        
        %make_4890_temporary_752 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4890 = insertvalue %Pos %make_4890_temporary_752, %Object null, 1
        
        
        
        %pureApp_4891 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4893 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4893.lit)
        
        %pureApp_4892 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4893, %Pos %pureApp_4891)
        
        
        
        %utf8StringLiteral_4895 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4895.lit)
        
        %pureApp_4894 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4892, %Pos %utf8StringLiteral_4895)
        
        
        
        %pureApp_4896 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4894, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4898 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4898.lit)
        
        %pureApp_4897 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4896, %Pos %utf8StringLiteral_4898)
        
        
        
        %vtable_753 = extractvalue %Neg %Exception_2362, 0
        %closure_754 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_755 = getelementptr ptr, ptr %vtable_753, i64 0
        %functionPointer_756 = load ptr, ptr %functionPointer_pointer_755, !noalias !2
        musttail call tailcc void %functionPointer_756(%Object %closure_754, %Pos %make_4890, %Pos %pureApp_4897, %Stack %stack)
        ret void
}



define ccc void @sharer_761(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_762 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_758_pointer_763 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_762, i64 0, i32 0
        %str_2106_758 = load %Pos, ptr %str_2106_758_pointer_763, !noalias !2
        %index_2107_759_pointer_764 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_762, i64 0, i32 1
        %index_2107_759 = load i64, ptr %index_2107_759_pointer_764, !noalias !2
        %Exception_2362_760_pointer_765 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_762, i64 0, i32 2
        %Exception_2362_760 = load %Neg, ptr %Exception_2362_760_pointer_765, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_758)
        call ccc void @shareNegative(%Neg %Exception_2362_760)
        call ccc void @shareFrames(%StackPointer %stackPointer_762)
        ret void
}



define ccc void @eraser_769(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_770 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_766_pointer_771 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_770, i64 0, i32 0
        %str_2106_766 = load %Pos, ptr %str_2106_766_pointer_771, !noalias !2
        %index_2107_767_pointer_772 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_770, i64 0, i32 1
        %index_2107_767 = load i64, ptr %index_2107_767_pointer_772, !noalias !2
        %Exception_2362_768_pointer_773 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_770, i64 0, i32 2
        %Exception_2362_768 = load %Neg, ptr %Exception_2362_768_pointer_773, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_766)
        call ccc void @eraseNegative(%Neg %Exception_2362_768)
        call ccc void @eraseFrames(%StackPointer %stackPointer_770)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4888 = add i64 0, 0
        
        %pureApp_4887 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4888)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_774 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_775 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_774, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_775, !noalias !2
        %index_2107_pointer_776 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_774, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_776, !noalias !2
        %Exception_2362_pointer_777 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_774, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_777, !noalias !2
        %returnAddress_pointer_778 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_774, i64 0, i32 1, i32 0
        %sharer_pointer_779 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_774, i64 0, i32 1, i32 1
        %eraser_pointer_780 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_774, i64 0, i32 1, i32 2
        store ptr @returnAddress_740, ptr %returnAddress_pointer_778, !noalias !2
        store ptr @sharer_761, ptr %sharer_pointer_779, !noalias !2
        store ptr @eraser_769, ptr %eraser_pointer_780, !noalias !2
        
        %tag_781 = extractvalue %Pos %pureApp_4887, 0
        %fields_782 = extractvalue %Pos %pureApp_4887, 1
        switch i64 %tag_781, label %label_783 [i64 0, label %label_787 i64 1, label %label_792]
    
    label_783:
        
        ret void
    
    label_787:
        
        %pureApp_4899 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4900 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4899)
        
        
        
        %stackPointer_785 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_786 = getelementptr %FrameHeader, %StackPointer %stackPointer_785, i64 0, i32 0
        %returnAddress_784 = load %ReturnAddress, ptr %returnAddress_pointer_786, !noalias !2
        musttail call tailcc void %returnAddress_784(%Pos %pureApp_4900, %Stack %stack)
        ret void
    
    label_792:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4901_temporary_788 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4901 = insertvalue %Pos %booleanLiteral_4901_temporary_788, %Object null, 1
        
        %stackPointer_790 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_791 = getelementptr %FrameHeader, %StackPointer %stackPointer_790, i64 0, i32 0
        %returnAddress_789 = load %ReturnAddress, ptr %returnAddress_pointer_791, !noalias !2
        musttail call tailcc void %returnAddress_789(%Pos %booleanLiteral_4901, %Stack %stack)
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
        
        musttail call tailcc void @main_2444(%Stack %stack)
        ret void
}
