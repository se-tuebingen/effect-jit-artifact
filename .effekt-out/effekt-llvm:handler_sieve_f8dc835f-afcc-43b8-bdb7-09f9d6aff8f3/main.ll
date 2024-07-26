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



define ccc i64 @mod_108(i64 %x_106, i64 %y_107) {
    ; declaration extern
    ; variable
    %z = srem %Int %x_106, %y_107 ret %Int %z
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



define tailcc void @Prime_4_4479_clause_2(%Object %closure, i64 %e_5_4486, %Stack %stack) {
        
    entry:
        
        
        %booleanLiteral_4608_temporary_3 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4608 = insertvalue %Pos %booleanLiteral_4608_temporary_3, %Object null, 1
        
        %stackPointer_5 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_6 = getelementptr %FrameHeader, %StackPointer %stackPointer_5, i64 0, i32 0
        %returnAddress_4 = load %ReturnAddress, ptr %returnAddress_pointer_6, !noalias !2
        musttail call tailcc void %returnAddress_4(%Pos %booleanLiteral_4608, %Stack %stack)
        ret void
}


@vtable_7 = private constant [1 x ptr] [ptr @Prime_4_4479_clause_2]


define tailcc void @Prime_15_19_4470_clause_22(%Object %closure, i64 %e_16_20_4483, %Stack %stack) {
        
    entry:
        
        %environment_23 = call ccc %Environment @objectEnvironment(%Object %closure)
        %i_8_12_4480_pointer_24 = getelementptr <{i64, %Neg}>, %Environment %environment_23, i64 0, i32 0
        %i_8_12_4480 = load i64, ptr %i_8_12_4480_pointer_24, !noalias !2
        %Prime_10_14_4475_pointer_25 = getelementptr <{i64, %Neg}>, %Environment %environment_23, i64 0, i32 1
        %Prime_10_14_4475 = load %Neg, ptr %Prime_10_14_4475_pointer_25, !noalias !2
        call ccc void @shareNegative(%Neg %Prime_10_14_4475)
        call ccc void @eraseObject(%Object %closure)
        
        %pureApp_4612 = call ccc i64 @mod_108(i64 %e_16_20_4483, i64 %i_8_12_4480)
        
        
        
        %longLiteral_4614 = add i64 0, 0
        
        %pureApp_4613 = call ccc %Pos @infixEq_72(i64 %pureApp_4612, i64 %longLiteral_4614)
        
        
        
        %tag_26 = extractvalue %Pos %pureApp_4613, 0
        %fields_27 = extractvalue %Pos %pureApp_4613, 1
        switch i64 %tag_26, label %label_28 [i64 0, label %label_33 i64 1, label %label_38]
    
    label_28:
        
        ret void
    
    label_33:
        
        %vtable_29 = extractvalue %Neg %Prime_10_14_4475, 0
        %closure_30 = extractvalue %Neg %Prime_10_14_4475, 1
        %functionPointer_pointer_31 = getelementptr ptr, ptr %vtable_29, i64 0
        %functionPointer_32 = load ptr, ptr %functionPointer_pointer_31, !noalias !2
        musttail call tailcc void %functionPointer_32(%Object %closure_30, i64 %e_16_20_4483, %Stack %stack)
        ret void
    
    label_38:
        call ccc void @eraseNegative(%Neg %Prime_10_14_4475)
        
        %booleanLiteral_4615_temporary_34 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_4615 = insertvalue %Pos %booleanLiteral_4615_temporary_34, %Object null, 1
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_37 = getelementptr %FrameHeader, %StackPointer %stackPointer_36, i64 0, i32 0
        %returnAddress_35 = load %ReturnAddress, ptr %returnAddress_pointer_37, !noalias !2
        musttail call tailcc void %returnAddress_35(%Pos %booleanLiteral_4615, %Stack %stack)
        ret void
}


@vtable_39 = private constant [1 x ptr] [ptr @Prime_15_19_4470_clause_22]


define ccc void @eraser_44(%Environment %environment) {
        
    entry:
        
        %i_8_12_4480_42_pointer_45 = getelementptr <{i64, %Neg}>, %Environment %environment, i64 0, i32 0
        %i_8_12_4480_42 = load i64, ptr %i_8_12_4480_42_pointer_45, !noalias !2
        %Prime_10_14_4475_43_pointer_46 = getelementptr <{i64, %Neg}>, %Environment %environment, i64 0, i32 1
        %Prime_10_14_4475_43 = load %Neg, ptr %Prime_10_14_4475_43_pointer_46, !noalias !2
        call ccc void @eraseNegative(%Neg %Prime_10_14_4475_43)
        ret void
}



define tailcc void @returnAddress_12(%Pos %v_r_2486_12_16_4481, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_13 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %i_8_12_4480_pointer_14 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_13, i64 0, i32 0
        %i_8_12_4480 = load i64, ptr %i_8_12_4480_pointer_14, !noalias !2
        %tmp_4591_pointer_15 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_13, i64 0, i32 1
        %tmp_4591 = load i64, ptr %tmp_4591_pointer_15, !noalias !2
        %a_9_13_4484_pointer_16 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_13, i64 0, i32 2
        %a_9_13_4484 = load i64, ptr %a_9_13_4484_pointer_16, !noalias !2
        %Prime_10_14_4475_pointer_17 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_13, i64 0, i32 3
        %Prime_10_14_4475 = load %Neg, ptr %Prime_10_14_4475_pointer_17, !noalias !2
        
        %tag_18 = extractvalue %Pos %v_r_2486_12_16_4481, 0
        %fields_19 = extractvalue %Pos %v_r_2486_12_16_4481, 1
        switch i64 %tag_18, label %label_20 [i64 0, label %label_21 i64 1, label %label_50]
    
    label_20:
        
        ret void
    
    label_21:
        
        %longLiteral_4611 = add i64 1, 0
        
        %pureApp_4610 = call ccc i64 @infixAdd_96(i64 %i_8_12_4480, i64 %longLiteral_4611)
        
        
        
        
        
        
        
        musttail call tailcc void @primes_worker_6_10_4471(i64 %pureApp_4610, i64 %a_9_13_4484, %Neg %Prime_10_14_4475, i64 %tmp_4591, %Stack %stack)
        ret void
    
    label_50:
        
        %closure_40 = call ccc %Object @newObject(ptr @eraser_44, i64 24)
        %environment_41 = call ccc %Environment @objectEnvironment(%Object %closure_40)
        %i_8_12_4480_pointer_47 = getelementptr <{i64, %Neg}>, %Environment %environment_41, i64 0, i32 0
        store i64 %i_8_12_4480, ptr %i_8_12_4480_pointer_47, !noalias !2
        %Prime_10_14_4475_pointer_48 = getelementptr <{i64, %Neg}>, %Environment %environment_41, i64 0, i32 1
        store %Neg %Prime_10_14_4475, ptr %Prime_10_14_4475_pointer_48, !noalias !2
        %vtable_temporary_49 = insertvalue %Neg zeroinitializer, ptr @vtable_39, 0
        %Prime_15_19_4470 = insertvalue %Neg %vtable_temporary_49, %Object %closure_40, 1
        
        %longLiteral_4617 = add i64 1, 0
        
        %pureApp_4616 = call ccc i64 @infixAdd_96(i64 %i_8_12_4480, i64 %longLiteral_4617)
        
        
        
        %pureApp_4618 = call ccc i64 @infixAdd_96(i64 %a_9_13_4484, i64 %i_8_12_4480)
        
        
        
        
        
        
        
        musttail call tailcc void @primes_worker_6_10_4471(i64 %pureApp_4616, i64 %pureApp_4618, %Neg %Prime_15_19_4470, i64 %tmp_4591, %Stack %stack)
        ret void
}



define ccc void @sharer_55(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_56 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %i_8_12_4480_51_pointer_57 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_56, i64 0, i32 0
        %i_8_12_4480_51 = load i64, ptr %i_8_12_4480_51_pointer_57, !noalias !2
        %tmp_4591_52_pointer_58 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_56, i64 0, i32 1
        %tmp_4591_52 = load i64, ptr %tmp_4591_52_pointer_58, !noalias !2
        %a_9_13_4484_53_pointer_59 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_56, i64 0, i32 2
        %a_9_13_4484_53 = load i64, ptr %a_9_13_4484_53_pointer_59, !noalias !2
        %Prime_10_14_4475_54_pointer_60 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_56, i64 0, i32 3
        %Prime_10_14_4475_54 = load %Neg, ptr %Prime_10_14_4475_54_pointer_60, !noalias !2
        call ccc void @shareNegative(%Neg %Prime_10_14_4475_54)
        call ccc void @shareFrames(%StackPointer %stackPointer_56)
        ret void
}



define ccc void @eraser_65(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_66 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %i_8_12_4480_61_pointer_67 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_66, i64 0, i32 0
        %i_8_12_4480_61 = load i64, ptr %i_8_12_4480_61_pointer_67, !noalias !2
        %tmp_4591_62_pointer_68 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_66, i64 0, i32 1
        %tmp_4591_62 = load i64, ptr %tmp_4591_62_pointer_68, !noalias !2
        %a_9_13_4484_63_pointer_69 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_66, i64 0, i32 2
        %a_9_13_4484_63 = load i64, ptr %a_9_13_4484_63_pointer_69, !noalias !2
        %Prime_10_14_4475_64_pointer_70 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_66, i64 0, i32 3
        %Prime_10_14_4475_64 = load %Neg, ptr %Prime_10_14_4475_64_pointer_70, !noalias !2
        call ccc void @eraseNegative(%Neg %Prime_10_14_4475_64)
        call ccc void @eraseFrames(%StackPointer %stackPointer_66)
        ret void
}



define tailcc void @primes_worker_6_10_4471(i64 %i_8_12_4480, i64 %a_9_13_4484, %Neg %Prime_10_14_4475, i64 %tmp_4591, %Stack %stack) {
        
    entry:
        
        
        %pureApp_4609 = call ccc %Pos @infixGte_187(i64 %i_8_12_4480, i64 %tmp_4591)
        
        
        
        %tag_9 = extractvalue %Pos %pureApp_4609, 0
        %fields_10 = extractvalue %Pos %pureApp_4609, 1
        switch i64 %tag_9, label %label_11 [i64 0, label %label_83 i64 1, label %label_87]
    
    label_11:
        
        ret void
    
    label_83:
        call ccc void @shareNegative(%Neg %Prime_10_14_4475)
        %stackPointer_71 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %i_8_12_4480_pointer_72 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_71, i64 0, i32 0
        store i64 %i_8_12_4480, ptr %i_8_12_4480_pointer_72, !noalias !2
        %tmp_4591_pointer_73 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_71, i64 0, i32 1
        store i64 %tmp_4591, ptr %tmp_4591_pointer_73, !noalias !2
        %a_9_13_4484_pointer_74 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_71, i64 0, i32 2
        store i64 %a_9_13_4484, ptr %a_9_13_4484_pointer_74, !noalias !2
        %Prime_10_14_4475_pointer_75 = getelementptr <{i64, i64, i64, %Neg}>, %StackPointer %stackPointer_71, i64 0, i32 3
        store %Neg %Prime_10_14_4475, ptr %Prime_10_14_4475_pointer_75, !noalias !2
        %returnAddress_pointer_76 = getelementptr <{<{i64, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_71, i64 0, i32 1, i32 0
        %sharer_pointer_77 = getelementptr <{<{i64, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_71, i64 0, i32 1, i32 1
        %eraser_pointer_78 = getelementptr <{<{i64, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_71, i64 0, i32 1, i32 2
        store ptr @returnAddress_12, ptr %returnAddress_pointer_76, !noalias !2
        store ptr @sharer_55, ptr %sharer_pointer_77, !noalias !2
        store ptr @eraser_65, ptr %eraser_pointer_78, !noalias !2
        
        %vtable_79 = extractvalue %Neg %Prime_10_14_4475, 0
        %closure_80 = extractvalue %Neg %Prime_10_14_4475, 1
        %functionPointer_pointer_81 = getelementptr ptr, ptr %vtable_79, i64 0
        %functionPointer_82 = load ptr, ptr %functionPointer_pointer_81, !noalias !2
        musttail call tailcc void %functionPointer_82(%Object %closure_80, i64 %i_8_12_4480, %Stack %stack)
        ret void
    
    label_87:
        call ccc void @eraseNegative(%Neg %Prime_10_14_4475)
        
        %stackPointer_85 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_86 = getelementptr %FrameHeader, %StackPointer %stackPointer_85, i64 0, i32 0
        %returnAddress_84 = load %ReturnAddress, ptr %returnAddress_pointer_86, !noalias !2
        musttail call tailcc void %returnAddress_84(i64 %a_9_13_4484, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_88(i64 %r_2447, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4619 = call ccc %Pos @show_14(i64 %r_2447)
        
        
        
        %pureApp_4620 = call ccc %Pos @println_1(%Pos %pureApp_4619)
        
        
        
        %stackPointer_90 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_91 = getelementptr %FrameHeader, %StackPointer %stackPointer_90, i64 0, i32 0
        %returnAddress_89 = load %ReturnAddress, ptr %returnAddress_pointer_91, !noalias !2
        musttail call tailcc void %returnAddress_89(%Pos %pureApp_4620, %Stack %stack)
        ret void
}



define ccc void @sharer_92(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_93 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_93)
        ret void
}



define ccc void @eraser_94(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_95 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_95)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3433_3497, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4607 = call ccc i64 @unboxInt_303(%Pos %v_coe_3433_3497)
        
        
        
        %vtable_temporary_8 = insertvalue %Neg zeroinitializer, ptr @vtable_7, 0
        %Prime_4_4479 = insertvalue %Neg %vtable_temporary_8, %Object null, 1
        %stackPointer_96 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_97 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_96, i64 0, i32 1, i32 0
        %sharer_pointer_98 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_96, i64 0, i32 1, i32 1
        %eraser_pointer_99 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_96, i64 0, i32 1, i32 2
        store ptr @returnAddress_88, ptr %returnAddress_pointer_97, !noalias !2
        store ptr @sharer_92, ptr %sharer_pointer_98, !noalias !2
        store ptr @eraser_94, ptr %eraser_pointer_99, !noalias !2
        
        %longLiteral_4621 = add i64 2, 0
        
        %longLiteral_4622 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @primes_worker_6_10_4471(i64 %longLiteral_4621, i64 %longLiteral_4622, %Neg %Prime_4_4479, i64 %pureApp_4607, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_105(%Pos %returned_4623, %Stack %stack) {
        
    entry:
        
        %stack_106 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_108 = call ccc %StackPointer @stackDeallocate(%Stack %stack_106, i64 24)
        %returnAddress_pointer_109 = getelementptr %FrameHeader, %StackPointer %stackPointer_108, i64 0, i32 0
        %returnAddress_107 = load %ReturnAddress, ptr %returnAddress_pointer_109, !noalias !2
        musttail call tailcc void %returnAddress_107(%Pos %returned_4623, %Stack %stack_106)
        ret void
}



define ccc void @sharer_110(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_111 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_112(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_113 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_113)
        ret void
}



define ccc void @eraser_125(%Environment %environment) {
        
    entry:
        
        %tmp_4553_123_pointer_126 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4553_123 = load %Pos, ptr %tmp_4553_123_pointer_126, !noalias !2
        %acc_3_3_5_169_4205_124_pointer_127 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4205_124 = load %Pos, ptr %acc_3_3_5_169_4205_124_pointer_127, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4553_123)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4205_124)
        ret void
}



define tailcc void @toList_1_1_3_167_4337(i64 %start_2_2_4_168_4226, %Pos %acc_3_3_5_169_4205, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4625 = add i64 1, 0
        
        %pureApp_4624 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4226, i64 %longLiteral_4625)
        
        
        
        %tag_118 = extractvalue %Pos %pureApp_4624, 0
        %fields_119 = extractvalue %Pos %pureApp_4624, 1
        switch i64 %tag_118, label %label_120 [i64 0, label %label_131 i64 1, label %label_135]
    
    label_120:
        
        ret void
    
    label_131:
        
        %pureApp_4626 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4226)
        
        
        
        %longLiteral_4628 = add i64 1, 0
        
        %pureApp_4627 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4226, i64 %longLiteral_4628)
        
        
        
        %fields_121 = call ccc %Object @newObject(ptr @eraser_125, i64 32)
        %environment_122 = call ccc %Environment @objectEnvironment(%Object %fields_121)
        %tmp_4553_pointer_128 = getelementptr <{%Pos, %Pos}>, %Environment %environment_122, i64 0, i32 0
        store %Pos %pureApp_4626, ptr %tmp_4553_pointer_128, !noalias !2
        %acc_3_3_5_169_4205_pointer_129 = getelementptr <{%Pos, %Pos}>, %Environment %environment_122, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4205, ptr %acc_3_3_5_169_4205_pointer_129, !noalias !2
        %make_4629_temporary_130 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4629 = insertvalue %Pos %make_4629_temporary_130, %Object %fields_121, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4337(i64 %pureApp_4627, %Pos %make_4629, %Stack %stack)
        ret void
    
    label_135:
        
        %stackPointer_133 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_134 = getelementptr %FrameHeader, %StackPointer %stackPointer_133, i64 0, i32 0
        %returnAddress_132 = load %ReturnAddress, ptr %returnAddress_pointer_134, !noalias !2
        musttail call tailcc void %returnAddress_132(%Pos %acc_3_3_5_169_4205, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_146(%Pos %v_r_2592_32_59_223_4216, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_147 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %v_r_2508_30_194_4201_pointer_148 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_147, i64 0, i32 0
        %v_r_2508_30_194_4201 = load %Pos, ptr %v_r_2508_30_194_4201_pointer_148, !noalias !2
        %tmp_4560_pointer_149 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_147, i64 0, i32 1
        %tmp_4560 = load i64, ptr %tmp_4560_pointer_149, !noalias !2
        %acc_8_35_199_4195_pointer_150 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_147, i64 0, i32 2
        %acc_8_35_199_4195 = load i64, ptr %acc_8_35_199_4195_pointer_150, !noalias !2
        %index_7_34_198_4290_pointer_151 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_147, i64 0, i32 3
        %index_7_34_198_4290 = load i64, ptr %index_7_34_198_4290_pointer_151, !noalias !2
        %p_8_9_4095_pointer_152 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_147, i64 0, i32 4
        %p_8_9_4095 = load %Prompt, ptr %p_8_9_4095_pointer_152, !noalias !2
        
        %tag_153 = extractvalue %Pos %v_r_2592_32_59_223_4216, 0
        %fields_154 = extractvalue %Pos %v_r_2592_32_59_223_4216, 1
        switch i64 %tag_153, label %label_155 [i64 1, label %label_178 i64 0, label %label_185]
    
    label_155:
        
        ret void
    
    label_160:
        
        ret void
    
    label_166:
        call ccc void @erasePositive(%Pos %v_r_2508_30_194_4201)
        
        %pair_161 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4095)
        %k_13_14_4_4491 = extractvalue <{%Resumption, %Stack}> %pair_161, 0
        %stack_162 = extractvalue <{%Resumption, %Stack}> %pair_161, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4491)
        
        %longLiteral_4641 = add i64 5, 0
        
        
        
        %pureApp_4642 = call ccc %Pos @boxInt_301(i64 %longLiteral_4641)
        
        
        
        %stackPointer_164 = call ccc %StackPointer @stackDeallocate(%Stack %stack_162, i64 24)
        %returnAddress_pointer_165 = getelementptr %FrameHeader, %StackPointer %stackPointer_164, i64 0, i32 0
        %returnAddress_163 = load %ReturnAddress, ptr %returnAddress_pointer_165, !noalias !2
        musttail call tailcc void %returnAddress_163(%Pos %pureApp_4642, %Stack %stack_162)
        ret void
    
    label_169:
        
        ret void
    
    label_175:
        call ccc void @erasePositive(%Pos %v_r_2508_30_194_4201)
        
        %pair_170 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4095)
        %k_13_14_4_4490 = extractvalue <{%Resumption, %Stack}> %pair_170, 0
        %stack_171 = extractvalue <{%Resumption, %Stack}> %pair_170, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4490)
        
        %longLiteral_4645 = add i64 5, 0
        
        
        
        %pureApp_4646 = call ccc %Pos @boxInt_301(i64 %longLiteral_4645)
        
        
        
        %stackPointer_173 = call ccc %StackPointer @stackDeallocate(%Stack %stack_171, i64 24)
        %returnAddress_pointer_174 = getelementptr %FrameHeader, %StackPointer %stackPointer_173, i64 0, i32 0
        %returnAddress_172 = load %ReturnAddress, ptr %returnAddress_pointer_174, !noalias !2
        musttail call tailcc void %returnAddress_172(%Pos %pureApp_4646, %Stack %stack_171)
        ret void
    
    label_176:
        
        %longLiteral_4648 = add i64 1, 0
        
        %pureApp_4647 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4290, i64 %longLiteral_4648)
        
        
        
        %longLiteral_4650 = add i64 10, 0
        
        %pureApp_4649 = call ccc i64 @infixMul_99(i64 %longLiteral_4650, i64 %acc_8_35_199_4195)
        
        
        
        %pureApp_4651 = call ccc i64 @toInt_2085(i64 %pureApp_4638)
        
        
        
        %pureApp_4652 = call ccc i64 @infixSub_105(i64 %pureApp_4651, i64 %tmp_4560)
        
        
        
        %pureApp_4653 = call ccc i64 @infixAdd_96(i64 %pureApp_4649, i64 %pureApp_4652)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4256(i64 %pureApp_4647, i64 %pureApp_4653, %Pos %v_r_2508_30_194_4201, i64 %tmp_4560, %Prompt %p_8_9_4095, %Stack %stack)
        ret void
    
    label_177:
        
        %intLiteral_4644 = add i64 57, 0
        
        %pureApp_4643 = call ccc %Pos @infixLte_2093(i64 %pureApp_4638, i64 %intLiteral_4644)
        
        
        
        %tag_167 = extractvalue %Pos %pureApp_4643, 0
        %fields_168 = extractvalue %Pos %pureApp_4643, 1
        switch i64 %tag_167, label %label_169 [i64 0, label %label_175 i64 1, label %label_176]
    
    label_178:
        %environment_156 = call ccc %Environment @objectEnvironment(%Object %fields_154)
        %v_coe_3408_46_73_237_4398_pointer_157 = getelementptr <{%Pos}>, %Environment %environment_156, i64 0, i32 0
        %v_coe_3408_46_73_237_4398 = load %Pos, ptr %v_coe_3408_46_73_237_4398_pointer_157, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3408_46_73_237_4398)
        call ccc void @eraseObject(%Object %fields_154)
        
        %pureApp_4638 = call ccc i64 @unboxChar_313(%Pos %v_coe_3408_46_73_237_4398)
        
        
        
        %intLiteral_4640 = add i64 48, 0
        
        %pureApp_4639 = call ccc %Pos @infixGte_2099(i64 %pureApp_4638, i64 %intLiteral_4640)
        
        
        
        %tag_158 = extractvalue %Pos %pureApp_4639, 0
        %fields_159 = extractvalue %Pos %pureApp_4639, 1
        switch i64 %tag_158, label %label_160 [i64 0, label %label_166 i64 1, label %label_177]
    
    label_185:
        %environment_179 = call ccc %Environment @objectEnvironment(%Object %fields_154)
        %v_y_2599_76_103_267_4636_pointer_180 = getelementptr <{%Pos, %Pos}>, %Environment %environment_179, i64 0, i32 0
        %v_y_2599_76_103_267_4636 = load %Pos, ptr %v_y_2599_76_103_267_4636_pointer_180, !noalias !2
        %v_y_2600_77_104_268_4637_pointer_181 = getelementptr <{%Pos, %Pos}>, %Environment %environment_179, i64 0, i32 1
        %v_y_2600_77_104_268_4637 = load %Pos, ptr %v_y_2600_77_104_268_4637_pointer_181, !noalias !2
        call ccc void @eraseObject(%Object %fields_154)
        call ccc void @erasePositive(%Pos %v_r_2508_30_194_4201)
        
        %stackPointer_183 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_184 = getelementptr %FrameHeader, %StackPointer %stackPointer_183, i64 0, i32 0
        %returnAddress_182 = load %ReturnAddress, ptr %returnAddress_pointer_184, !noalias !2
        musttail call tailcc void %returnAddress_182(i64 %acc_8_35_199_4195, %Stack %stack)
        ret void
}



define ccc void @sharer_191(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_192 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_r_2508_30_194_4201_186_pointer_193 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_192, i64 0, i32 0
        %v_r_2508_30_194_4201_186 = load %Pos, ptr %v_r_2508_30_194_4201_186_pointer_193, !noalias !2
        %tmp_4560_187_pointer_194 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_192, i64 0, i32 1
        %tmp_4560_187 = load i64, ptr %tmp_4560_187_pointer_194, !noalias !2
        %acc_8_35_199_4195_188_pointer_195 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_192, i64 0, i32 2
        %acc_8_35_199_4195_188 = load i64, ptr %acc_8_35_199_4195_188_pointer_195, !noalias !2
        %index_7_34_198_4290_189_pointer_196 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_192, i64 0, i32 3
        %index_7_34_198_4290_189 = load i64, ptr %index_7_34_198_4290_189_pointer_196, !noalias !2
        %p_8_9_4095_190_pointer_197 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_192, i64 0, i32 4
        %p_8_9_4095_190 = load %Prompt, ptr %p_8_9_4095_190_pointer_197, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2508_30_194_4201_186)
        call ccc void @shareFrames(%StackPointer %stackPointer_192)
        ret void
}



define ccc void @eraser_203(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_204 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_r_2508_30_194_4201_198_pointer_205 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_204, i64 0, i32 0
        %v_r_2508_30_194_4201_198 = load %Pos, ptr %v_r_2508_30_194_4201_198_pointer_205, !noalias !2
        %tmp_4560_199_pointer_206 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_204, i64 0, i32 1
        %tmp_4560_199 = load i64, ptr %tmp_4560_199_pointer_206, !noalias !2
        %acc_8_35_199_4195_200_pointer_207 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_204, i64 0, i32 2
        %acc_8_35_199_4195_200 = load i64, ptr %acc_8_35_199_4195_200_pointer_207, !noalias !2
        %index_7_34_198_4290_201_pointer_208 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_204, i64 0, i32 3
        %index_7_34_198_4290_201 = load i64, ptr %index_7_34_198_4290_201_pointer_208, !noalias !2
        %p_8_9_4095_202_pointer_209 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_204, i64 0, i32 4
        %p_8_9_4095_202 = load %Prompt, ptr %p_8_9_4095_202_pointer_209, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2508_30_194_4201_198)
        call ccc void @eraseFrames(%StackPointer %stackPointer_204)
        ret void
}



define tailcc void @returnAddress_220(%Pos %returned_4654, %Stack %stack) {
        
    entry:
        
        %stack_221 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_223 = call ccc %StackPointer @stackDeallocate(%Stack %stack_221, i64 24)
        %returnAddress_pointer_224 = getelementptr %FrameHeader, %StackPointer %stackPointer_223, i64 0, i32 0
        %returnAddress_222 = load %ReturnAddress, ptr %returnAddress_pointer_224, !noalias !2
        musttail call tailcc void %returnAddress_222(%Pos %returned_4654, %Stack %stack_221)
        ret void
}



define tailcc void @Exception_7_19_46_210_4236_clause_229(%Object %closure, %Pos %exc_8_20_47_211_4274, %Pos %msg_9_21_48_212_4223, %Stack %stack) {
        
    entry:
        
        %environment_230 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4321_pointer_231 = getelementptr <{%Prompt}>, %Environment %environment_230, i64 0, i32 0
        %p_6_18_45_209_4321 = load %Prompt, ptr %p_6_18_45_209_4321_pointer_231, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_232 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4321)
        %k_11_23_50_214_4417 = extractvalue <{%Resumption, %Stack}> %pair_232, 0
        %stack_233 = extractvalue <{%Resumption, %Stack}> %pair_232, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4417)
        
        %fields_234 = call ccc %Object @newObject(ptr @eraser_125, i64 32)
        %environment_235 = call ccc %Environment @objectEnvironment(%Object %fields_234)
        %exc_8_20_47_211_4274_pointer_238 = getelementptr <{%Pos, %Pos}>, %Environment %environment_235, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4274, ptr %exc_8_20_47_211_4274_pointer_238, !noalias !2
        %msg_9_21_48_212_4223_pointer_239 = getelementptr <{%Pos, %Pos}>, %Environment %environment_235, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4223, ptr %msg_9_21_48_212_4223_pointer_239, !noalias !2
        %make_4655_temporary_240 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4655 = insertvalue %Pos %make_4655_temporary_240, %Object %fields_234, 1
        
        
        
        %stackPointer_242 = call ccc %StackPointer @stackDeallocate(%Stack %stack_233, i64 24)
        %returnAddress_pointer_243 = getelementptr %FrameHeader, %StackPointer %stackPointer_242, i64 0, i32 0
        %returnAddress_241 = load %ReturnAddress, ptr %returnAddress_pointer_243, !noalias !2
        musttail call tailcc void %returnAddress_241(%Pos %make_4655, %Stack %stack_233)
        ret void
}


@vtable_244 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4236_clause_229]


define ccc void @eraser_248(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4321_247_pointer_249 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4321_247 = load %Prompt, ptr %p_6_18_45_209_4321_247_pointer_249, !noalias !2
        ret void
}



define ccc void @eraser_256(%Environment %environment) {
        
    entry:
        
        %tmp_4562_255_pointer_257 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4562_255 = load %Pos, ptr %tmp_4562_255_pointer_257, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4562_255)
        ret void
}



define tailcc void @returnAddress_252(i64 %v_coe_3407_6_28_55_219_4238, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4656 = call ccc %Pos @boxChar_311(i64 %v_coe_3407_6_28_55_219_4238)
        
        
        
        %fields_253 = call ccc %Object @newObject(ptr @eraser_256, i64 16)
        %environment_254 = call ccc %Environment @objectEnvironment(%Object %fields_253)
        %tmp_4562_pointer_258 = getelementptr <{%Pos}>, %Environment %environment_254, i64 0, i32 0
        store %Pos %pureApp_4656, ptr %tmp_4562_pointer_258, !noalias !2
        %make_4657_temporary_259 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4657 = insertvalue %Pos %make_4657_temporary_259, %Object %fields_253, 1
        
        
        
        %stackPointer_261 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_262 = getelementptr %FrameHeader, %StackPointer %stackPointer_261, i64 0, i32 0
        %returnAddress_260 = load %ReturnAddress, ptr %returnAddress_pointer_262, !noalias !2
        musttail call tailcc void %returnAddress_260(%Pos %make_4657, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4256(i64 %index_7_34_198_4290, i64 %acc_8_35_199_4195, %Pos %v_r_2508_30_194_4201, i64 %tmp_4560, %Prompt %p_8_9_4095, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2508_30_194_4201)
        %stackPointer_210 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %v_r_2508_30_194_4201_pointer_211 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_210, i64 0, i32 0
        store %Pos %v_r_2508_30_194_4201, ptr %v_r_2508_30_194_4201_pointer_211, !noalias !2
        %tmp_4560_pointer_212 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_210, i64 0, i32 1
        store i64 %tmp_4560, ptr %tmp_4560_pointer_212, !noalias !2
        %acc_8_35_199_4195_pointer_213 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_210, i64 0, i32 2
        store i64 %acc_8_35_199_4195, ptr %acc_8_35_199_4195_pointer_213, !noalias !2
        %index_7_34_198_4290_pointer_214 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_210, i64 0, i32 3
        store i64 %index_7_34_198_4290, ptr %index_7_34_198_4290_pointer_214, !noalias !2
        %p_8_9_4095_pointer_215 = getelementptr <{%Pos, i64, i64, i64, %Prompt}>, %StackPointer %stackPointer_210, i64 0, i32 4
        store %Prompt %p_8_9_4095, ptr %p_8_9_4095_pointer_215, !noalias !2
        %returnAddress_pointer_216 = getelementptr <{<{%Pos, i64, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_210, i64 0, i32 1, i32 0
        %sharer_pointer_217 = getelementptr <{<{%Pos, i64, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_210, i64 0, i32 1, i32 1
        %eraser_pointer_218 = getelementptr <{<{%Pos, i64, i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_210, i64 0, i32 1, i32 2
        store ptr @returnAddress_146, ptr %returnAddress_pointer_216, !noalias !2
        store ptr @sharer_191, ptr %sharer_pointer_217, !noalias !2
        store ptr @eraser_203, ptr %eraser_pointer_218, !noalias !2
        
        %stack_219 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4321 = call ccc %Prompt @currentPrompt(%Stack %stack_219)
        %stackPointer_225 = call ccc %StackPointer @stackAllocate(%Stack %stack_219, i64 24)
        %returnAddress_pointer_226 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_225, i64 0, i32 1, i32 0
        %sharer_pointer_227 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_225, i64 0, i32 1, i32 1
        %eraser_pointer_228 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_225, i64 0, i32 1, i32 2
        store ptr @returnAddress_220, ptr %returnAddress_pointer_226, !noalias !2
        store ptr @sharer_110, ptr %sharer_pointer_227, !noalias !2
        store ptr @eraser_112, ptr %eraser_pointer_228, !noalias !2
        
        %closure_245 = call ccc %Object @newObject(ptr @eraser_248, i64 8)
        %environment_246 = call ccc %Environment @objectEnvironment(%Object %closure_245)
        %p_6_18_45_209_4321_pointer_250 = getelementptr <{%Prompt}>, %Environment %environment_246, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4321, ptr %p_6_18_45_209_4321_pointer_250, !noalias !2
        %vtable_temporary_251 = insertvalue %Neg zeroinitializer, ptr @vtable_244, 0
        %Exception_7_19_46_210_4236 = insertvalue %Neg %vtable_temporary_251, %Object %closure_245, 1
        %stackPointer_263 = call ccc %StackPointer @stackAllocate(%Stack %stack_219, i64 24)
        %returnAddress_pointer_264 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_263, i64 0, i32 1, i32 0
        %sharer_pointer_265 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_263, i64 0, i32 1, i32 1
        %eraser_pointer_266 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_263, i64 0, i32 1, i32 2
        store ptr @returnAddress_252, ptr %returnAddress_pointer_264, !noalias !2
        store ptr @sharer_92, ptr %sharer_pointer_265, !noalias !2
        store ptr @eraser_94, ptr %eraser_pointer_266, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2508_30_194_4201, i64 %index_7_34_198_4290, %Neg %Exception_7_19_46_210_4236, %Stack %stack_219)
        ret void
}



define tailcc void @Exception_9_106_133_297_4407_clause_267(%Object %closure, %Pos %exception_10_107_134_298_4658, %Pos %msg_11_108_135_299_4659, %Stack %stack) {
        
    entry:
        
        %environment_268 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4095_pointer_269 = getelementptr <{%Prompt}>, %Environment %environment_268, i64 0, i32 0
        %p_8_9_4095 = load %Prompt, ptr %p_8_9_4095_pointer_269, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4658)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4659)
        
        %pair_270 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4095)
        %k_13_14_4_4543 = extractvalue <{%Resumption, %Stack}> %pair_270, 0
        %stack_271 = extractvalue <{%Resumption, %Stack}> %pair_270, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4543)
        
        %longLiteral_4660 = add i64 5, 0
        
        
        
        %pureApp_4661 = call ccc %Pos @boxInt_301(i64 %longLiteral_4660)
        
        
        
        %stackPointer_273 = call ccc %StackPointer @stackDeallocate(%Stack %stack_271, i64 24)
        %returnAddress_pointer_274 = getelementptr %FrameHeader, %StackPointer %stackPointer_273, i64 0, i32 0
        %returnAddress_272 = load %ReturnAddress, ptr %returnAddress_pointer_274, !noalias !2
        musttail call tailcc void %returnAddress_272(%Pos %pureApp_4661, %Stack %stack_271)
        ret void
}


@vtable_275 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4407_clause_267]


define tailcc void @returnAddress_286(i64 %v_coe_3412_22_131_158_322_4137, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4664 = call ccc %Pos @boxInt_301(i64 %v_coe_3412_22_131_158_322_4137)
        
        
        
        
        
        %pureApp_4665 = call ccc i64 @unboxInt_303(%Pos %pureApp_4664)
        
        
        
        %pureApp_4666 = call ccc %Pos @boxInt_301(i64 %pureApp_4665)
        
        
        
        %stackPointer_288 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_289 = getelementptr %FrameHeader, %StackPointer %stackPointer_288, i64 0, i32 0
        %returnAddress_287 = load %ReturnAddress, ptr %returnAddress_pointer_289, !noalias !2
        musttail call tailcc void %returnAddress_287(%Pos %pureApp_4666, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_298(i64 %v_r_2606_1_9_20_129_156_320_4373, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4670 = add i64 0, 0
        
        %pureApp_4669 = call ccc i64 @infixSub_105(i64 %longLiteral_4670, i64 %v_r_2606_1_9_20_129_156_320_4373)
        
        
        
        %stackPointer_300 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_301 = getelementptr %FrameHeader, %StackPointer %stackPointer_300, i64 0, i32 0
        %returnAddress_299 = load %ReturnAddress, ptr %returnAddress_pointer_301, !noalias !2
        musttail call tailcc void %returnAddress_299(i64 %pureApp_4669, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_281(i64 %v_r_2605_3_14_123_150_314_4146, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_282 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_2508_30_194_4201_pointer_283 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_282, i64 0, i32 0
        %v_r_2508_30_194_4201 = load %Pos, ptr %v_r_2508_30_194_4201_pointer_283, !noalias !2
        %tmp_4560_pointer_284 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_282, i64 0, i32 1
        %tmp_4560 = load i64, ptr %tmp_4560_pointer_284, !noalias !2
        %p_8_9_4095_pointer_285 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_282, i64 0, i32 2
        %p_8_9_4095 = load %Prompt, ptr %p_8_9_4095_pointer_285, !noalias !2
        
        %intLiteral_4663 = add i64 45, 0
        
        %pureApp_4662 = call ccc %Pos @infixEq_78(i64 %v_r_2605_3_14_123_150_314_4146, i64 %intLiteral_4663)
        
        
        %stackPointer_290 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_291 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_290, i64 0, i32 1, i32 0
        %sharer_pointer_292 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_290, i64 0, i32 1, i32 1
        %eraser_pointer_293 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_290, i64 0, i32 1, i32 2
        store ptr @returnAddress_286, ptr %returnAddress_pointer_291, !noalias !2
        store ptr @sharer_92, ptr %sharer_pointer_292, !noalias !2
        store ptr @eraser_94, ptr %eraser_pointer_293, !noalias !2
        
        %tag_294 = extractvalue %Pos %pureApp_4662, 0
        %fields_295 = extractvalue %Pos %pureApp_4662, 1
        switch i64 %tag_294, label %label_296 [i64 0, label %label_297 i64 1, label %label_306]
    
    label_296:
        
        ret void
    
    label_297:
        
        %longLiteral_4667 = add i64 0, 0
        
        %longLiteral_4668 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4256(i64 %longLiteral_4667, i64 %longLiteral_4668, %Pos %v_r_2508_30_194_4201, i64 %tmp_4560, %Prompt %p_8_9_4095, %Stack %stack)
        ret void
    
    label_306:
        %stackPointer_302 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_303 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_302, i64 0, i32 1, i32 0
        %sharer_pointer_304 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_302, i64 0, i32 1, i32 1
        %eraser_pointer_305 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_302, i64 0, i32 1, i32 2
        store ptr @returnAddress_298, ptr %returnAddress_pointer_303, !noalias !2
        store ptr @sharer_92, ptr %sharer_pointer_304, !noalias !2
        store ptr @eraser_94, ptr %eraser_pointer_305, !noalias !2
        
        %longLiteral_4671 = add i64 1, 0
        
        %longLiteral_4672 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4256(i64 %longLiteral_4671, i64 %longLiteral_4672, %Pos %v_r_2508_30_194_4201, i64 %tmp_4560, %Prompt %p_8_9_4095, %Stack %stack)
        ret void
}



define ccc void @sharer_310(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_311 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_r_2508_30_194_4201_307_pointer_312 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_311, i64 0, i32 0
        %v_r_2508_30_194_4201_307 = load %Pos, ptr %v_r_2508_30_194_4201_307_pointer_312, !noalias !2
        %tmp_4560_308_pointer_313 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_311, i64 0, i32 1
        %tmp_4560_308 = load i64, ptr %tmp_4560_308_pointer_313, !noalias !2
        %p_8_9_4095_309_pointer_314 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_311, i64 0, i32 2
        %p_8_9_4095_309 = load %Prompt, ptr %p_8_9_4095_309_pointer_314, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2508_30_194_4201_307)
        call ccc void @shareFrames(%StackPointer %stackPointer_311)
        ret void
}



define ccc void @eraser_318(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_319 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_r_2508_30_194_4201_315_pointer_320 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_319, i64 0, i32 0
        %v_r_2508_30_194_4201_315 = load %Pos, ptr %v_r_2508_30_194_4201_315_pointer_320, !noalias !2
        %tmp_4560_316_pointer_321 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_319, i64 0, i32 1
        %tmp_4560_316 = load i64, ptr %tmp_4560_316_pointer_321, !noalias !2
        %p_8_9_4095_317_pointer_322 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_319, i64 0, i32 2
        %p_8_9_4095_317 = load %Prompt, ptr %p_8_9_4095_317_pointer_322, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2508_30_194_4201_315)
        call ccc void @eraseFrames(%StackPointer %stackPointer_319)
        ret void
}



define tailcc void @returnAddress_143(%Pos %v_r_2508_30_194_4201, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_144 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4095_pointer_145 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_144, i64 0, i32 0
        %p_8_9_4095 = load %Prompt, ptr %p_8_9_4095_pointer_145, !noalias !2
        
        %intLiteral_4635 = add i64 48, 0
        
        %pureApp_4634 = call ccc i64 @toInt_2085(i64 %intLiteral_4635)
        
        
        
        %closure_276 = call ccc %Object @newObject(ptr @eraser_248, i64 8)
        %environment_277 = call ccc %Environment @objectEnvironment(%Object %closure_276)
        %p_8_9_4095_pointer_279 = getelementptr <{%Prompt}>, %Environment %environment_277, i64 0, i32 0
        store %Prompt %p_8_9_4095, ptr %p_8_9_4095_pointer_279, !noalias !2
        %vtable_temporary_280 = insertvalue %Neg zeroinitializer, ptr @vtable_275, 0
        %Exception_9_106_133_297_4407 = insertvalue %Neg %vtable_temporary_280, %Object %closure_276, 1
        call ccc void @sharePositive(%Pos %v_r_2508_30_194_4201)
        %stackPointer_323 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_2508_30_194_4201_pointer_324 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_323, i64 0, i32 0
        store %Pos %v_r_2508_30_194_4201, ptr %v_r_2508_30_194_4201_pointer_324, !noalias !2
        %tmp_4560_pointer_325 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_323, i64 0, i32 1
        store i64 %pureApp_4634, ptr %tmp_4560_pointer_325, !noalias !2
        %p_8_9_4095_pointer_326 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_323, i64 0, i32 2
        store %Prompt %p_8_9_4095, ptr %p_8_9_4095_pointer_326, !noalias !2
        %returnAddress_pointer_327 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 0
        %sharer_pointer_328 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 1
        %eraser_pointer_329 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 2
        store ptr @returnAddress_281, ptr %returnAddress_pointer_327, !noalias !2
        store ptr @sharer_310, ptr %sharer_pointer_328, !noalias !2
        store ptr @eraser_318, ptr %eraser_pointer_329, !noalias !2
        
        %longLiteral_4673 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2508_30_194_4201, i64 %longLiteral_4673, %Neg %Exception_9_106_133_297_4407, %Stack %stack)
        ret void
}



define ccc void @sharer_331(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_332 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4095_330_pointer_333 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_332, i64 0, i32 0
        %p_8_9_4095_330 = load %Prompt, ptr %p_8_9_4095_330_pointer_333, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_332)
        ret void
}



define ccc void @eraser_335(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_336 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4095_334_pointer_337 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_336, i64 0, i32 0
        %p_8_9_4095_334 = load %Prompt, ptr %p_8_9_4095_334_pointer_337, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_336)
        ret void
}


@utf8StringLiteral_4674.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_140(%Pos %v_r_2507_24_188_4352, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_141 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4095_pointer_142 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_141, i64 0, i32 0
        %p_8_9_4095 = load %Prompt, ptr %p_8_9_4095_pointer_142, !noalias !2
        %stackPointer_338 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4095_pointer_339 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_338, i64 0, i32 0
        store %Prompt %p_8_9_4095, ptr %p_8_9_4095_pointer_339, !noalias !2
        %returnAddress_pointer_340 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_338, i64 0, i32 1, i32 0
        %sharer_pointer_341 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_338, i64 0, i32 1, i32 1
        %eraser_pointer_342 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_338, i64 0, i32 1, i32 2
        store ptr @returnAddress_143, ptr %returnAddress_pointer_340, !noalias !2
        store ptr @sharer_331, ptr %sharer_pointer_341, !noalias !2
        store ptr @eraser_335, ptr %eraser_pointer_342, !noalias !2
        
        %tag_343 = extractvalue %Pos %v_r_2507_24_188_4352, 0
        %fields_344 = extractvalue %Pos %v_r_2507_24_188_4352, 1
        switch i64 %tag_343, label %label_345 [i64 0, label %label_349 i64 1, label %label_355]
    
    label_345:
        
        ret void
    
    label_349:
        
        %utf8StringLiteral_4674 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4674.lit)
        
        %stackPointer_347 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_348 = getelementptr %FrameHeader, %StackPointer %stackPointer_347, i64 0, i32 0
        %returnAddress_346 = load %ReturnAddress, ptr %returnAddress_pointer_348, !noalias !2
        musttail call tailcc void %returnAddress_346(%Pos %utf8StringLiteral_4674, %Stack %stack)
        ret void
    
    label_355:
        %environment_350 = call ccc %Environment @objectEnvironment(%Object %fields_344)
        %v_y_3234_8_29_193_4336_pointer_351 = getelementptr <{%Pos}>, %Environment %environment_350, i64 0, i32 0
        %v_y_3234_8_29_193_4336 = load %Pos, ptr %v_y_3234_8_29_193_4336_pointer_351, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3234_8_29_193_4336)
        call ccc void @eraseObject(%Object %fields_344)
        
        %stackPointer_353 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_354 = getelementptr %FrameHeader, %StackPointer %stackPointer_353, i64 0, i32 0
        %returnAddress_352 = load %ReturnAddress, ptr %returnAddress_pointer_354, !noalias !2
        musttail call tailcc void %returnAddress_352(%Pos %v_y_3234_8_29_193_4336, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_137(%Pos %v_r_2506_13_177_4131, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_138 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4095_pointer_139 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_138, i64 0, i32 0
        %p_8_9_4095 = load %Prompt, ptr %p_8_9_4095_pointer_139, !noalias !2
        %stackPointer_358 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4095_pointer_359 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_358, i64 0, i32 0
        store %Prompt %p_8_9_4095, ptr %p_8_9_4095_pointer_359, !noalias !2
        %returnAddress_pointer_360 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_358, i64 0, i32 1, i32 0
        %sharer_pointer_361 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_358, i64 0, i32 1, i32 1
        %eraser_pointer_362 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_358, i64 0, i32 1, i32 2
        store ptr @returnAddress_140, ptr %returnAddress_pointer_360, !noalias !2
        store ptr @sharer_331, ptr %sharer_pointer_361, !noalias !2
        store ptr @eraser_335, ptr %eraser_pointer_362, !noalias !2
        
        %tag_363 = extractvalue %Pos %v_r_2506_13_177_4131, 0
        %fields_364 = extractvalue %Pos %v_r_2506_13_177_4131, 1
        switch i64 %tag_363, label %label_365 [i64 0, label %label_370 i64 1, label %label_382]
    
    label_365:
        
        ret void
    
    label_370:
        
        %make_4675_temporary_366 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4675 = insertvalue %Pos %make_4675_temporary_366, %Object null, 1
        
        
        
        %stackPointer_368 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_369 = getelementptr %FrameHeader, %StackPointer %stackPointer_368, i64 0, i32 0
        %returnAddress_367 = load %ReturnAddress, ptr %returnAddress_pointer_369, !noalias !2
        musttail call tailcc void %returnAddress_367(%Pos %make_4675, %Stack %stack)
        ret void
    
    label_382:
        %environment_371 = call ccc %Environment @objectEnvironment(%Object %fields_364)
        %v_y_2743_10_21_185_4372_pointer_372 = getelementptr <{%Pos, %Pos}>, %Environment %environment_371, i64 0, i32 0
        %v_y_2743_10_21_185_4372 = load %Pos, ptr %v_y_2743_10_21_185_4372_pointer_372, !noalias !2
        %v_y_2744_11_22_186_4278_pointer_373 = getelementptr <{%Pos, %Pos}>, %Environment %environment_371, i64 0, i32 1
        %v_y_2744_11_22_186_4278 = load %Pos, ptr %v_y_2744_11_22_186_4278_pointer_373, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2743_10_21_185_4372)
        call ccc void @eraseObject(%Object %fields_364)
        
        %fields_374 = call ccc %Object @newObject(ptr @eraser_256, i64 16)
        %environment_375 = call ccc %Environment @objectEnvironment(%Object %fields_374)
        %v_y_2743_10_21_185_4372_pointer_377 = getelementptr <{%Pos}>, %Environment %environment_375, i64 0, i32 0
        store %Pos %v_y_2743_10_21_185_4372, ptr %v_y_2743_10_21_185_4372_pointer_377, !noalias !2
        %make_4676_temporary_378 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4676 = insertvalue %Pos %make_4676_temporary_378, %Object %fields_374, 1
        
        
        
        %stackPointer_380 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_381 = getelementptr %FrameHeader, %StackPointer %stackPointer_380, i64 0, i32 0
        %returnAddress_379 = load %ReturnAddress, ptr %returnAddress_pointer_381, !noalias !2
        musttail call tailcc void %returnAddress_379(%Pos %make_4676, %Stack %stack)
        ret void
}



define tailcc void @main_2439(%Stack %stack) {
        
    entry:
        
        %stackPointer_100 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_101 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_100, i64 0, i32 1, i32 0
        %sharer_pointer_102 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_100, i64 0, i32 1, i32 1
        %eraser_pointer_103 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_100, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_101, !noalias !2
        store ptr @sharer_92, ptr %sharer_pointer_102, !noalias !2
        store ptr @eraser_94, ptr %eraser_pointer_103, !noalias !2
        
        %stack_104 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4095 = call ccc %Prompt @currentPrompt(%Stack %stack_104)
        %stackPointer_114 = call ccc %StackPointer @stackAllocate(%Stack %stack_104, i64 24)
        %returnAddress_pointer_115 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_114, i64 0, i32 1, i32 0
        %sharer_pointer_116 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_114, i64 0, i32 1, i32 1
        %eraser_pointer_117 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_114, i64 0, i32 1, i32 2
        store ptr @returnAddress_105, ptr %returnAddress_pointer_115, !noalias !2
        store ptr @sharer_110, ptr %sharer_pointer_116, !noalias !2
        store ptr @eraser_112, ptr %eraser_pointer_117, !noalias !2
        
        %pureApp_4630 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4632 = add i64 1, 0
        
        %pureApp_4631 = call ccc i64 @infixSub_105(i64 %pureApp_4630, i64 %longLiteral_4632)
        
        
        
        %make_4633_temporary_136 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4633 = insertvalue %Pos %make_4633_temporary_136, %Object null, 1
        
        
        %stackPointer_385 = call ccc %StackPointer @stackAllocate(%Stack %stack_104, i64 32)
        %p_8_9_4095_pointer_386 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_385, i64 0, i32 0
        store %Prompt %p_8_9_4095, ptr %p_8_9_4095_pointer_386, !noalias !2
        %returnAddress_pointer_387 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 0
        %sharer_pointer_388 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 1
        %eraser_pointer_389 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 2
        store ptr @returnAddress_137, ptr %returnAddress_pointer_387, !noalias !2
        store ptr @sharer_331, ptr %sharer_pointer_388, !noalias !2
        store ptr @eraser_335, ptr %eraser_pointer_389, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4337(i64 %pureApp_4631, %Pos %make_4633, %Stack %stack_104)
        ret void
}


@utf8StringLiteral_4598.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4600.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4603.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_390(%Pos %v_r_2674_3464, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_391 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_392 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_391, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_392, !noalias !2
        %index_2107_pointer_393 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_391, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_393, !noalias !2
        %Exception_2362_pointer_394 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_391, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_394, !noalias !2
        
        %tag_395 = extractvalue %Pos %v_r_2674_3464, 0
        %fields_396 = extractvalue %Pos %v_r_2674_3464, 1
        switch i64 %tag_395, label %label_397 [i64 0, label %label_401 i64 1, label %label_407]
    
    label_397:
        
        ret void
    
    label_401:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4594 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_399 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_400 = getelementptr %FrameHeader, %StackPointer %stackPointer_399, i64 0, i32 0
        %returnAddress_398 = load %ReturnAddress, ptr %returnAddress_pointer_400, !noalias !2
        musttail call tailcc void %returnAddress_398(i64 %pureApp_4594, %Stack %stack)
        ret void
    
    label_407:
        
        %make_4595_temporary_402 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4595 = insertvalue %Pos %make_4595_temporary_402, %Object null, 1
        
        
        
        %pureApp_4596 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4598 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4598.lit)
        
        %pureApp_4597 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4598, %Pos %pureApp_4596)
        
        
        
        %utf8StringLiteral_4600 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4600.lit)
        
        %pureApp_4599 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4597, %Pos %utf8StringLiteral_4600)
        
        
        
        %pureApp_4601 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4599, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4603 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4603.lit)
        
        %pureApp_4602 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4601, %Pos %utf8StringLiteral_4603)
        
        
        
        %vtable_403 = extractvalue %Neg %Exception_2362, 0
        %closure_404 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_405 = getelementptr ptr, ptr %vtable_403, i64 0
        %functionPointer_406 = load ptr, ptr %functionPointer_pointer_405, !noalias !2
        musttail call tailcc void %functionPointer_406(%Object %closure_404, %Pos %make_4595, %Pos %pureApp_4602, %Stack %stack)
        ret void
}



define ccc void @sharer_411(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_412 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_408_pointer_413 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_412, i64 0, i32 0
        %str_2106_408 = load %Pos, ptr %str_2106_408_pointer_413, !noalias !2
        %index_2107_409_pointer_414 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_412, i64 0, i32 1
        %index_2107_409 = load i64, ptr %index_2107_409_pointer_414, !noalias !2
        %Exception_2362_410_pointer_415 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_412, i64 0, i32 2
        %Exception_2362_410 = load %Neg, ptr %Exception_2362_410_pointer_415, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_408)
        call ccc void @shareNegative(%Neg %Exception_2362_410)
        call ccc void @shareFrames(%StackPointer %stackPointer_412)
        ret void
}



define ccc void @eraser_419(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_420 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_416_pointer_421 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_420, i64 0, i32 0
        %str_2106_416 = load %Pos, ptr %str_2106_416_pointer_421, !noalias !2
        %index_2107_417_pointer_422 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_420, i64 0, i32 1
        %index_2107_417 = load i64, ptr %index_2107_417_pointer_422, !noalias !2
        %Exception_2362_418_pointer_423 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_420, i64 0, i32 2
        %Exception_2362_418 = load %Neg, ptr %Exception_2362_418_pointer_423, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_416)
        call ccc void @eraseNegative(%Neg %Exception_2362_418)
        call ccc void @eraseFrames(%StackPointer %stackPointer_420)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4593 = add i64 0, 0
        
        %pureApp_4592 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4593)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_424 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_425 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_424, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_425, !noalias !2
        %index_2107_pointer_426 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_424, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_426, !noalias !2
        %Exception_2362_pointer_427 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_424, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_427, !noalias !2
        %returnAddress_pointer_428 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_424, i64 0, i32 1, i32 0
        %sharer_pointer_429 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_424, i64 0, i32 1, i32 1
        %eraser_pointer_430 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_424, i64 0, i32 1, i32 2
        store ptr @returnAddress_390, ptr %returnAddress_pointer_428, !noalias !2
        store ptr @sharer_411, ptr %sharer_pointer_429, !noalias !2
        store ptr @eraser_419, ptr %eraser_pointer_430, !noalias !2
        
        %tag_431 = extractvalue %Pos %pureApp_4592, 0
        %fields_432 = extractvalue %Pos %pureApp_4592, 1
        switch i64 %tag_431, label %label_433 [i64 0, label %label_437 i64 1, label %label_442]
    
    label_433:
        
        ret void
    
    label_437:
        
        %pureApp_4604 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4605 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4604)
        
        
        
        %stackPointer_435 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_436 = getelementptr %FrameHeader, %StackPointer %stackPointer_435, i64 0, i32 0
        %returnAddress_434 = load %ReturnAddress, ptr %returnAddress_pointer_436, !noalias !2
        musttail call tailcc void %returnAddress_434(%Pos %pureApp_4605, %Stack %stack)
        ret void
    
    label_442:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4606_temporary_438 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4606 = insertvalue %Pos %booleanLiteral_4606_temporary_438, %Object null, 1
        
        %stackPointer_440 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_441 = getelementptr %FrameHeader, %StackPointer %stackPointer_440, i64 0, i32 0
        %returnAddress_439 = load %ReturnAddress, ptr %returnAddress_pointer_441, !noalias !2
        musttail call tailcc void %returnAddress_439(%Pos %booleanLiteral_4606, %Stack %stack)
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
        
        musttail call tailcc void @main_2439(%Stack %stack)
        ret void
}
