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



define ccc %Pos @infixGt_184(i64 %x_182, i64 %y_183) {
    ; declaration extern
    ; variable
    
    %z = icmp sgt %Int %x_182, %y_183
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



define tailcc void @returnAddress_2(i64 %r_2445, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4571 = call ccc %Pos @show_14(i64 %r_2445)
        
        
        
        %pureApp_4572 = call ccc %Pos @println_1(%Pos %pureApp_4571)
        
        
        
        %stackPointer_4 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_5 = getelementptr %FrameHeader, %StackPointer %stackPointer_4, i64 0, i32 0
        %returnAddress_3 = load %ReturnAddress, ptr %returnAddress_pointer_5, !noalias !2
        musttail call tailcc void %returnAddress_3(%Pos %pureApp_4572, %Stack %stack)
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
        %v_r_2487_2_4433_pointer_17 = getelementptr <{i64}>, %StackPointer %stackPointer_16, i64 0, i32 0
        %v_r_2487_2_4433 = load i64, ptr %v_r_2487_2_4433_pointer_17, !noalias !2
        %stackPointer_19 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_20 = getelementptr %FrameHeader, %StackPointer %stackPointer_19, i64 0, i32 0
        %returnAddress_18 = load %ReturnAddress, ptr %returnAddress_pointer_20, !noalias !2
        musttail call tailcc void %returnAddress_18(i64 %returnValue_15, %Stack %stack)
        ret void
}



define ccc void @sharer_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2487_2_4433_21_pointer_24 = getelementptr <{i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %v_r_2487_2_4433_21 = load i64, ptr %v_r_2487_2_4433_21_pointer_24, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_23)
        ret void
}



define ccc void @eraser_26(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_27 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2487_2_4433_25_pointer_28 = getelementptr <{i64}>, %StackPointer %stackPointer_27, i64 0, i32 0
        %v_r_2487_2_4433_25 = load i64, ptr %v_r_2487_2_4433_25_pointer_28, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_27)
        ret void
}



define tailcc void @returnAddress_42(%Pos %__8_24_4452, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_43 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %l_6_16_4443_pointer_44 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_43, i64 0, i32 0
        %l_6_16_4443 = load i64, ptr %l_6_16_4443_pointer_44, !noalias !2
        %s_3_4434_pointer_45 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_43, i64 0, i32 1
        %s_3_4434 = load %Reference, ptr %s_3_4434_pointer_45, !noalias !2
        %tmp_4553_pointer_46 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_43, i64 0, i32 2
        %tmp_4553 = load i64, ptr %tmp_4553_pointer_46, !noalias !2
        call ccc void @erasePositive(%Pos %__8_24_4452)
        
        %longLiteral_4577 = add i64 1, 0
        
        %pureApp_4576 = call ccc i64 @infixAdd_96(i64 %l_6_16_4443, i64 %longLiteral_4577)
        
        
        
        
        
        musttail call tailcc void @range_worker_5_15_4431(i64 %pureApp_4576, %Reference %s_3_4434, i64 %tmp_4553, %Stack %stack)
        ret void
}



define ccc void @sharer_50(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_51 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %l_6_16_4443_47_pointer_52 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_51, i64 0, i32 0
        %l_6_16_4443_47 = load i64, ptr %l_6_16_4443_47_pointer_52, !noalias !2
        %s_3_4434_48_pointer_53 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_51, i64 0, i32 1
        %s_3_4434_48 = load %Reference, ptr %s_3_4434_48_pointer_53, !noalias !2
        %tmp_4553_49_pointer_54 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_51, i64 0, i32 2
        %tmp_4553_49 = load i64, ptr %tmp_4553_49_pointer_54, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_51)
        ret void
}



define ccc void @eraser_58(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_59 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %l_6_16_4443_55_pointer_60 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_59, i64 0, i32 0
        %l_6_16_4443_55 = load i64, ptr %l_6_16_4443_55_pointer_60, !noalias !2
        %s_3_4434_56_pointer_61 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_59, i64 0, i32 1
        %s_3_4434_56 = load %Reference, ptr %s_3_4434_56_pointer_61, !noalias !2
        %tmp_4553_57_pointer_62 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_59, i64 0, i32 2
        %tmp_4553_57 = load i64, ptr %tmp_4553_57_pointer_62, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_59)
        ret void
}



define tailcc void @returnAddress_37(i64 %v_r_2491_6_22_4436, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_38 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %l_6_16_4443_pointer_39 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_38, i64 0, i32 0
        %l_6_16_4443 = load i64, ptr %l_6_16_4443_pointer_39, !noalias !2
        %s_3_4434_pointer_40 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_38, i64 0, i32 1
        %s_3_4434 = load %Reference, ptr %s_3_4434_pointer_40, !noalias !2
        %tmp_4553_pointer_41 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_38, i64 0, i32 2
        %tmp_4553 = load i64, ptr %tmp_4553_pointer_41, !noalias !2
        
        %pureApp_4575 = call ccc i64 @infixAdd_96(i64 %v_r_2491_6_22_4436, i64 %l_6_16_4443)
        
        
        %stackPointer_63 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %l_6_16_4443_pointer_64 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_63, i64 0, i32 0
        store i64 %l_6_16_4443, ptr %l_6_16_4443_pointer_64, !noalias !2
        %s_3_4434_pointer_65 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_63, i64 0, i32 1
        store %Reference %s_3_4434, ptr %s_3_4434_pointer_65, !noalias !2
        %tmp_4553_pointer_66 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_63, i64 0, i32 2
        store i64 %tmp_4553, ptr %tmp_4553_pointer_66, !noalias !2
        %returnAddress_pointer_67 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_63, i64 0, i32 1, i32 0
        %sharer_pointer_68 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_63, i64 0, i32 1, i32 1
        %eraser_pointer_69 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_63, i64 0, i32 1, i32 2
        store ptr @returnAddress_42, ptr %returnAddress_pointer_67, !noalias !2
        store ptr @sharer_50, ptr %sharer_pointer_68, !noalias !2
        store ptr @eraser_58, ptr %eraser_pointer_69, !noalias !2
        
        %s_3_4434pointer_70 = call ccc ptr @getVarPointer(%Reference %s_3_4434, %Stack %stack)
        %s_3_4434_old_71 = load i64, ptr %s_3_4434pointer_70, !noalias !2
        store i64 %pureApp_4575, ptr %s_3_4434pointer_70, !noalias !2
        
        %put_4578_temporary_72 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_4578 = insertvalue %Pos %put_4578_temporary_72, %Object null, 1
        
        %stackPointer_74 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_75 = getelementptr %FrameHeader, %StackPointer %stackPointer_74, i64 0, i32 0
        %returnAddress_73 = load %ReturnAddress, ptr %returnAddress_pointer_75, !noalias !2
        musttail call tailcc void %returnAddress_73(%Pos %put_4578, %Stack %stack)
        ret void
}



define tailcc void @range_worker_5_15_4431(i64 %l_6_16_4443, %Reference %s_3_4434, i64 %tmp_4553, %Stack %stack) {
        
    entry:
        
        
        %pureApp_4574 = call ccc %Pos @infixGt_184(i64 %l_6_16_4443, i64 %tmp_4553)
        
        
        
        %tag_34 = extractvalue %Pos %pureApp_4574, 0
        %fields_35 = extractvalue %Pos %pureApp_4574, 1
        switch i64 %tag_34, label %label_36 [i64 0, label %label_94 i64 1, label %label_99]
    
    label_36:
        
        ret void
    
    label_94:
        %stackPointer_82 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %l_6_16_4443_pointer_83 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_82, i64 0, i32 0
        store i64 %l_6_16_4443, ptr %l_6_16_4443_pointer_83, !noalias !2
        %s_3_4434_pointer_84 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_82, i64 0, i32 1
        store %Reference %s_3_4434, ptr %s_3_4434_pointer_84, !noalias !2
        %tmp_4553_pointer_85 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_82, i64 0, i32 2
        store i64 %tmp_4553, ptr %tmp_4553_pointer_85, !noalias !2
        %returnAddress_pointer_86 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_82, i64 0, i32 1, i32 0
        %sharer_pointer_87 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_82, i64 0, i32 1, i32 1
        %eraser_pointer_88 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_82, i64 0, i32 1, i32 2
        store ptr @returnAddress_37, ptr %returnAddress_pointer_86, !noalias !2
        store ptr @sharer_50, ptr %sharer_pointer_87, !noalias !2
        store ptr @eraser_58, ptr %eraser_pointer_88, !noalias !2
        
        %get_4579_pointer_89 = call ccc ptr @getVarPointer(%Reference %s_3_4434, %Stack %stack)
        %s_3_4434_old_90 = load i64, ptr %get_4579_pointer_89, !noalias !2
        %get_4579 = load i64, ptr %get_4579_pointer_89, !noalias !2
        
        %stackPointer_92 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_93 = getelementptr %FrameHeader, %StackPointer %stackPointer_92, i64 0, i32 0
        %returnAddress_91 = load %ReturnAddress, ptr %returnAddress_pointer_93, !noalias !2
        musttail call tailcc void %returnAddress_91(i64 %get_4579, %Stack %stack)
        ret void
    
    label_99:
        
        %unitLiteral_4580_temporary_95 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_4580 = insertvalue %Pos %unitLiteral_4580_temporary_95, %Object null, 1
        
        %stackPointer_97 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_98 = getelementptr %FrameHeader, %StackPointer %stackPointer_97, i64 0, i32 0
        %returnAddress_96 = load %ReturnAddress, ptr %returnAddress_pointer_98, !noalias !2
        musttail call tailcc void %returnAddress_96(%Pos %unitLiteral_4580, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_100(%Pos %__27_4454, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_101 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %s_3_4434_pointer_102 = getelementptr <{%Reference}>, %StackPointer %stackPointer_101, i64 0, i32 0
        %s_3_4434 = load %Reference, ptr %s_3_4434_pointer_102, !noalias !2
        call ccc void @erasePositive(%Pos %__27_4454)
        
        %get_4581_pointer_103 = call ccc ptr @getVarPointer(%Reference %s_3_4434, %Stack %stack)
        %s_3_4434_old_104 = load i64, ptr %get_4581_pointer_103, !noalias !2
        %get_4581 = load i64, ptr %get_4581_pointer_103, !noalias !2
        
        %stackPointer_106 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_107 = getelementptr %FrameHeader, %StackPointer %stackPointer_106, i64 0, i32 0
        %returnAddress_105 = load %ReturnAddress, ptr %returnAddress_pointer_107, !noalias !2
        musttail call tailcc void %returnAddress_105(i64 %get_4581, %Stack %stack)
        ret void
}



define ccc void @sharer_109(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_110 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %s_3_4434_108_pointer_111 = getelementptr <{%Reference}>, %StackPointer %stackPointer_110, i64 0, i32 0
        %s_3_4434_108 = load %Reference, ptr %s_3_4434_108_pointer_111, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_110)
        ret void
}



define ccc void @eraser_113(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_114 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %s_3_4434_112_pointer_115 = getelementptr <{%Reference}>, %StackPointer %stackPointer_114, i64 0, i32 0
        %s_3_4434_112 = load %Reference, ptr %s_3_4434_112_pointer_115, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_114)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3426_3490, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4569 = call ccc i64 @unboxInt_303(%Pos %v_coe_3426_3490)
        
        
        
        %longLiteral_4570 = add i64 0, 0
        
        
        %stackPointer_10 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 0
        %sharer_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 1
        %eraser_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_11, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_12, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_13, !noalias !2
        %s_3_4434 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_29 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2487_2_4433_pointer_30 = getelementptr <{i64}>, %StackPointer %stackPointer_29, i64 0, i32 0
        store i64 %longLiteral_4570, ptr %v_r_2487_2_4433_pointer_30, !noalias !2
        %returnAddress_pointer_31 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 0
        %sharer_pointer_32 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 1
        %eraser_pointer_33 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 2
        store ptr @returnAddress_14, ptr %returnAddress_pointer_31, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_32, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_33, !noalias !2
        %stackPointer_116 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %s_3_4434_pointer_117 = getelementptr <{%Reference}>, %StackPointer %stackPointer_116, i64 0, i32 0
        store %Reference %s_3_4434, ptr %s_3_4434_pointer_117, !noalias !2
        %returnAddress_pointer_118 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_116, i64 0, i32 1, i32 0
        %sharer_pointer_119 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_116, i64 0, i32 1, i32 1
        %eraser_pointer_120 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_116, i64 0, i32 1, i32 2
        store ptr @returnAddress_100, ptr %returnAddress_pointer_118, !noalias !2
        store ptr @sharer_109, ptr %sharer_pointer_119, !noalias !2
        store ptr @eraser_113, ptr %eraser_pointer_120, !noalias !2
        
        %longLiteral_4582 = add i64 0, 0
        
        
        
        musttail call tailcc void @range_worker_5_15_4431(i64 %longLiteral_4582, %Reference %s_3_4434, i64 %pureApp_4569, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_126(%Pos %returned_4583, %Stack %stack) {
        
    entry:
        
        %stack_127 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_129 = call ccc %StackPointer @stackDeallocate(%Stack %stack_127, i64 24)
        %returnAddress_pointer_130 = getelementptr %FrameHeader, %StackPointer %stackPointer_129, i64 0, i32 0
        %returnAddress_128 = load %ReturnAddress, ptr %returnAddress_pointer_130, !noalias !2
        musttail call tailcc void %returnAddress_128(%Pos %returned_4583, %Stack %stack_127)
        ret void
}



define ccc void @sharer_131(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_132 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_133(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_134 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_134)
        ret void
}



define ccc void @eraser_146(%Environment %environment) {
        
    entry:
        
        %tmp_4518_144_pointer_147 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4518_144 = load %Pos, ptr %tmp_4518_144_pointer_147, !noalias !2
        %acc_3_3_5_169_4311_145_pointer_148 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4311_145 = load %Pos, ptr %acc_3_3_5_169_4311_145_pointer_148, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4518_144)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4311_145)
        ret void
}



define tailcc void @toList_1_1_3_167_4169(i64 %start_2_2_4_168_4283, %Pos %acc_3_3_5_169_4311, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4585 = add i64 1, 0
        
        %pureApp_4584 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4283, i64 %longLiteral_4585)
        
        
        
        %tag_139 = extractvalue %Pos %pureApp_4584, 0
        %fields_140 = extractvalue %Pos %pureApp_4584, 1
        switch i64 %tag_139, label %label_141 [i64 0, label %label_152 i64 1, label %label_156]
    
    label_141:
        
        ret void
    
    label_152:
        
        %pureApp_4586 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4283)
        
        
        
        %longLiteral_4588 = add i64 1, 0
        
        %pureApp_4587 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4283, i64 %longLiteral_4588)
        
        
        
        %fields_142 = call ccc %Object @newObject(ptr @eraser_146, i64 32)
        %environment_143 = call ccc %Environment @objectEnvironment(%Object %fields_142)
        %tmp_4518_pointer_149 = getelementptr <{%Pos, %Pos}>, %Environment %environment_143, i64 0, i32 0
        store %Pos %pureApp_4586, ptr %tmp_4518_pointer_149, !noalias !2
        %acc_3_3_5_169_4311_pointer_150 = getelementptr <{%Pos, %Pos}>, %Environment %environment_143, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4311, ptr %acc_3_3_5_169_4311_pointer_150, !noalias !2
        %make_4589_temporary_151 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4589 = insertvalue %Pos %make_4589_temporary_151, %Object %fields_142, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4169(i64 %pureApp_4587, %Pos %make_4589, %Stack %stack)
        ret void
    
    label_156:
        
        %stackPointer_154 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_155 = getelementptr %FrameHeader, %StackPointer %stackPointer_154, i64 0, i32 0
        %returnAddress_153 = load %ReturnAddress, ptr %returnAddress_pointer_155, !noalias !2
        musttail call tailcc void %returnAddress_153(%Pos %acc_3_3_5_169_4311, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_167(%Pos %v_r_2585_32_59_223_4116, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_168 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %index_7_34_198_4372_pointer_169 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_168, i64 0, i32 0
        %index_7_34_198_4372 = load i64, ptr %index_7_34_198_4372_pointer_169, !noalias !2
        %p_8_9_4061_pointer_170 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_168, i64 0, i32 1
        %p_8_9_4061 = load %Prompt, ptr %p_8_9_4061_pointer_170, !noalias !2
        %acc_8_35_199_4314_pointer_171 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_168, i64 0, i32 2
        %acc_8_35_199_4314 = load i64, ptr %acc_8_35_199_4314_pointer_171, !noalias !2
        %v_r_2502_30_194_4207_pointer_172 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_168, i64 0, i32 3
        %v_r_2502_30_194_4207 = load %Pos, ptr %v_r_2502_30_194_4207_pointer_172, !noalias !2
        %tmp_4525_pointer_173 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_168, i64 0, i32 4
        %tmp_4525 = load i64, ptr %tmp_4525_pointer_173, !noalias !2
        
        %tag_174 = extractvalue %Pos %v_r_2585_32_59_223_4116, 0
        %fields_175 = extractvalue %Pos %v_r_2585_32_59_223_4116, 1
        switch i64 %tag_174, label %label_176 [i64 1, label %label_199 i64 0, label %label_206]
    
    label_176:
        
        ret void
    
    label_181:
        
        ret void
    
    label_187:
        call ccc void @erasePositive(%Pos %v_r_2502_30_194_4207)
        
        %pair_182 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4061)
        %k_13_14_4_4459 = extractvalue <{%Resumption, %Stack}> %pair_182, 0
        %stack_183 = extractvalue <{%Resumption, %Stack}> %pair_182, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4459)
        
        %longLiteral_4601 = add i64 5, 0
        
        
        
        %pureApp_4602 = call ccc %Pos @boxInt_301(i64 %longLiteral_4601)
        
        
        
        %stackPointer_185 = call ccc %StackPointer @stackDeallocate(%Stack %stack_183, i64 24)
        %returnAddress_pointer_186 = getelementptr %FrameHeader, %StackPointer %stackPointer_185, i64 0, i32 0
        %returnAddress_184 = load %ReturnAddress, ptr %returnAddress_pointer_186, !noalias !2
        musttail call tailcc void %returnAddress_184(%Pos %pureApp_4602, %Stack %stack_183)
        ret void
    
    label_190:
        
        ret void
    
    label_196:
        call ccc void @erasePositive(%Pos %v_r_2502_30_194_4207)
        
        %pair_191 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4061)
        %k_13_14_4_4458 = extractvalue <{%Resumption, %Stack}> %pair_191, 0
        %stack_192 = extractvalue <{%Resumption, %Stack}> %pair_191, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4458)
        
        %longLiteral_4605 = add i64 5, 0
        
        
        
        %pureApp_4606 = call ccc %Pos @boxInt_301(i64 %longLiteral_4605)
        
        
        
        %stackPointer_194 = call ccc %StackPointer @stackDeallocate(%Stack %stack_192, i64 24)
        %returnAddress_pointer_195 = getelementptr %FrameHeader, %StackPointer %stackPointer_194, i64 0, i32 0
        %returnAddress_193 = load %ReturnAddress, ptr %returnAddress_pointer_195, !noalias !2
        musttail call tailcc void %returnAddress_193(%Pos %pureApp_4606, %Stack %stack_192)
        ret void
    
    label_197:
        
        %longLiteral_4608 = add i64 1, 0
        
        %pureApp_4607 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4372, i64 %longLiteral_4608)
        
        
        
        %longLiteral_4610 = add i64 10, 0
        
        %pureApp_4609 = call ccc i64 @infixMul_99(i64 %longLiteral_4610, i64 %acc_8_35_199_4314)
        
        
        
        %pureApp_4611 = call ccc i64 @toInt_2085(i64 %pureApp_4598)
        
        
        
        %pureApp_4612 = call ccc i64 @infixSub_105(i64 %pureApp_4611, i64 %tmp_4525)
        
        
        
        %pureApp_4613 = call ccc i64 @infixAdd_96(i64 %pureApp_4609, i64 %pureApp_4612)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4318(i64 %pureApp_4607, i64 %pureApp_4613, %Prompt %p_8_9_4061, %Pos %v_r_2502_30_194_4207, i64 %tmp_4525, %Stack %stack)
        ret void
    
    label_198:
        
        %intLiteral_4604 = add i64 57, 0
        
        %pureApp_4603 = call ccc %Pos @infixLte_2093(i64 %pureApp_4598, i64 %intLiteral_4604)
        
        
        
        %tag_188 = extractvalue %Pos %pureApp_4603, 0
        %fields_189 = extractvalue %Pos %pureApp_4603, 1
        switch i64 %tag_188, label %label_190 [i64 0, label %label_196 i64 1, label %label_197]
    
    label_199:
        %environment_177 = call ccc %Environment @objectEnvironment(%Object %fields_175)
        %v_coe_3401_46_73_237_4111_pointer_178 = getelementptr <{%Pos}>, %Environment %environment_177, i64 0, i32 0
        %v_coe_3401_46_73_237_4111 = load %Pos, ptr %v_coe_3401_46_73_237_4111_pointer_178, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3401_46_73_237_4111)
        call ccc void @eraseObject(%Object %fields_175)
        
        %pureApp_4598 = call ccc i64 @unboxChar_313(%Pos %v_coe_3401_46_73_237_4111)
        
        
        
        %intLiteral_4600 = add i64 48, 0
        
        %pureApp_4599 = call ccc %Pos @infixGte_2099(i64 %pureApp_4598, i64 %intLiteral_4600)
        
        
        
        %tag_179 = extractvalue %Pos %pureApp_4599, 0
        %fields_180 = extractvalue %Pos %pureApp_4599, 1
        switch i64 %tag_179, label %label_181 [i64 0, label %label_187 i64 1, label %label_198]
    
    label_206:
        %environment_200 = call ccc %Environment @objectEnvironment(%Object %fields_175)
        %v_y_2592_76_103_267_4596_pointer_201 = getelementptr <{%Pos, %Pos}>, %Environment %environment_200, i64 0, i32 0
        %v_y_2592_76_103_267_4596 = load %Pos, ptr %v_y_2592_76_103_267_4596_pointer_201, !noalias !2
        %v_y_2593_77_104_268_4597_pointer_202 = getelementptr <{%Pos, %Pos}>, %Environment %environment_200, i64 0, i32 1
        %v_y_2593_77_104_268_4597 = load %Pos, ptr %v_y_2593_77_104_268_4597_pointer_202, !noalias !2
        call ccc void @eraseObject(%Object %fields_175)
        call ccc void @erasePositive(%Pos %v_r_2502_30_194_4207)
        
        %stackPointer_204 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_205 = getelementptr %FrameHeader, %StackPointer %stackPointer_204, i64 0, i32 0
        %returnAddress_203 = load %ReturnAddress, ptr %returnAddress_pointer_205, !noalias !2
        musttail call tailcc void %returnAddress_203(i64 %acc_8_35_199_4314, %Stack %stack)
        ret void
}



define ccc void @sharer_212(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_213 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_4372_207_pointer_214 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_213, i64 0, i32 0
        %index_7_34_198_4372_207 = load i64, ptr %index_7_34_198_4372_207_pointer_214, !noalias !2
        %p_8_9_4061_208_pointer_215 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_213, i64 0, i32 1
        %p_8_9_4061_208 = load %Prompt, ptr %p_8_9_4061_208_pointer_215, !noalias !2
        %acc_8_35_199_4314_209_pointer_216 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_213, i64 0, i32 2
        %acc_8_35_199_4314_209 = load i64, ptr %acc_8_35_199_4314_209_pointer_216, !noalias !2
        %v_r_2502_30_194_4207_210_pointer_217 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_213, i64 0, i32 3
        %v_r_2502_30_194_4207_210 = load %Pos, ptr %v_r_2502_30_194_4207_210_pointer_217, !noalias !2
        %tmp_4525_211_pointer_218 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_213, i64 0, i32 4
        %tmp_4525_211 = load i64, ptr %tmp_4525_211_pointer_218, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2502_30_194_4207_210)
        call ccc void @shareFrames(%StackPointer %stackPointer_213)
        ret void
}



define ccc void @eraser_224(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_225 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_4372_219_pointer_226 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_225, i64 0, i32 0
        %index_7_34_198_4372_219 = load i64, ptr %index_7_34_198_4372_219_pointer_226, !noalias !2
        %p_8_9_4061_220_pointer_227 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_225, i64 0, i32 1
        %p_8_9_4061_220 = load %Prompt, ptr %p_8_9_4061_220_pointer_227, !noalias !2
        %acc_8_35_199_4314_221_pointer_228 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_225, i64 0, i32 2
        %acc_8_35_199_4314_221 = load i64, ptr %acc_8_35_199_4314_221_pointer_228, !noalias !2
        %v_r_2502_30_194_4207_222_pointer_229 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_225, i64 0, i32 3
        %v_r_2502_30_194_4207_222 = load %Pos, ptr %v_r_2502_30_194_4207_222_pointer_229, !noalias !2
        %tmp_4525_223_pointer_230 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_225, i64 0, i32 4
        %tmp_4525_223 = load i64, ptr %tmp_4525_223_pointer_230, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2502_30_194_4207_222)
        call ccc void @eraseFrames(%StackPointer %stackPointer_225)
        ret void
}



define tailcc void @returnAddress_241(%Pos %returned_4614, %Stack %stack) {
        
    entry:
        
        %stack_242 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_244 = call ccc %StackPointer @stackDeallocate(%Stack %stack_242, i64 24)
        %returnAddress_pointer_245 = getelementptr %FrameHeader, %StackPointer %stackPointer_244, i64 0, i32 0
        %returnAddress_243 = load %ReturnAddress, ptr %returnAddress_pointer_245, !noalias !2
        musttail call tailcc void %returnAddress_243(%Pos %returned_4614, %Stack %stack_242)
        ret void
}



define tailcc void @Exception_7_19_46_210_4225_clause_250(%Object %closure, %Pos %exc_8_20_47_211_4091, %Pos %msg_9_21_48_212_4193, %Stack %stack) {
        
    entry:
        
        %environment_251 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4234_pointer_252 = getelementptr <{%Prompt}>, %Environment %environment_251, i64 0, i32 0
        %p_6_18_45_209_4234 = load %Prompt, ptr %p_6_18_45_209_4234_pointer_252, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_253 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4234)
        %k_11_23_50_214_4386 = extractvalue <{%Resumption, %Stack}> %pair_253, 0
        %stack_254 = extractvalue <{%Resumption, %Stack}> %pair_253, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4386)
        
        %fields_255 = call ccc %Object @newObject(ptr @eraser_146, i64 32)
        %environment_256 = call ccc %Environment @objectEnvironment(%Object %fields_255)
        %exc_8_20_47_211_4091_pointer_259 = getelementptr <{%Pos, %Pos}>, %Environment %environment_256, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4091, ptr %exc_8_20_47_211_4091_pointer_259, !noalias !2
        %msg_9_21_48_212_4193_pointer_260 = getelementptr <{%Pos, %Pos}>, %Environment %environment_256, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4193, ptr %msg_9_21_48_212_4193_pointer_260, !noalias !2
        %make_4615_temporary_261 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4615 = insertvalue %Pos %make_4615_temporary_261, %Object %fields_255, 1
        
        
        
        %stackPointer_263 = call ccc %StackPointer @stackDeallocate(%Stack %stack_254, i64 24)
        %returnAddress_pointer_264 = getelementptr %FrameHeader, %StackPointer %stackPointer_263, i64 0, i32 0
        %returnAddress_262 = load %ReturnAddress, ptr %returnAddress_pointer_264, !noalias !2
        musttail call tailcc void %returnAddress_262(%Pos %make_4615, %Stack %stack_254)
        ret void
}


@vtable_265 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4225_clause_250]


define ccc void @eraser_269(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4234_268_pointer_270 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4234_268 = load %Prompt, ptr %p_6_18_45_209_4234_268_pointer_270, !noalias !2
        ret void
}



define ccc void @eraser_277(%Environment %environment) {
        
    entry:
        
        %tmp_4527_276_pointer_278 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4527_276 = load %Pos, ptr %tmp_4527_276_pointer_278, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4527_276)
        ret void
}



define tailcc void @returnAddress_273(i64 %v_coe_3400_6_28_55_219_4336, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4616 = call ccc %Pos @boxChar_311(i64 %v_coe_3400_6_28_55_219_4336)
        
        
        
        %fields_274 = call ccc %Object @newObject(ptr @eraser_277, i64 16)
        %environment_275 = call ccc %Environment @objectEnvironment(%Object %fields_274)
        %tmp_4527_pointer_279 = getelementptr <{%Pos}>, %Environment %environment_275, i64 0, i32 0
        store %Pos %pureApp_4616, ptr %tmp_4527_pointer_279, !noalias !2
        %make_4617_temporary_280 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4617 = insertvalue %Pos %make_4617_temporary_280, %Object %fields_274, 1
        
        
        
        %stackPointer_282 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_283 = getelementptr %FrameHeader, %StackPointer %stackPointer_282, i64 0, i32 0
        %returnAddress_281 = load %ReturnAddress, ptr %returnAddress_pointer_283, !noalias !2
        musttail call tailcc void %returnAddress_281(%Pos %make_4617, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4318(i64 %index_7_34_198_4372, i64 %acc_8_35_199_4314, %Prompt %p_8_9_4061, %Pos %v_r_2502_30_194_4207, i64 %tmp_4525, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2502_30_194_4207)
        %stackPointer_231 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %index_7_34_198_4372_pointer_232 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_231, i64 0, i32 0
        store i64 %index_7_34_198_4372, ptr %index_7_34_198_4372_pointer_232, !noalias !2
        %p_8_9_4061_pointer_233 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_231, i64 0, i32 1
        store %Prompt %p_8_9_4061, ptr %p_8_9_4061_pointer_233, !noalias !2
        %acc_8_35_199_4314_pointer_234 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_231, i64 0, i32 2
        store i64 %acc_8_35_199_4314, ptr %acc_8_35_199_4314_pointer_234, !noalias !2
        %v_r_2502_30_194_4207_pointer_235 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_231, i64 0, i32 3
        store %Pos %v_r_2502_30_194_4207, ptr %v_r_2502_30_194_4207_pointer_235, !noalias !2
        %tmp_4525_pointer_236 = getelementptr <{i64, %Prompt, i64, %Pos, i64}>, %StackPointer %stackPointer_231, i64 0, i32 4
        store i64 %tmp_4525, ptr %tmp_4525_pointer_236, !noalias !2
        %returnAddress_pointer_237 = getelementptr <{<{i64, %Prompt, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_231, i64 0, i32 1, i32 0
        %sharer_pointer_238 = getelementptr <{<{i64, %Prompt, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_231, i64 0, i32 1, i32 1
        %eraser_pointer_239 = getelementptr <{<{i64, %Prompt, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_231, i64 0, i32 1, i32 2
        store ptr @returnAddress_167, ptr %returnAddress_pointer_237, !noalias !2
        store ptr @sharer_212, ptr %sharer_pointer_238, !noalias !2
        store ptr @eraser_224, ptr %eraser_pointer_239, !noalias !2
        
        %stack_240 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4234 = call ccc %Prompt @currentPrompt(%Stack %stack_240)
        %stackPointer_246 = call ccc %StackPointer @stackAllocate(%Stack %stack_240, i64 24)
        %returnAddress_pointer_247 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_246, i64 0, i32 1, i32 0
        %sharer_pointer_248 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_246, i64 0, i32 1, i32 1
        %eraser_pointer_249 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_246, i64 0, i32 1, i32 2
        store ptr @returnAddress_241, ptr %returnAddress_pointer_247, !noalias !2
        store ptr @sharer_131, ptr %sharer_pointer_248, !noalias !2
        store ptr @eraser_133, ptr %eraser_pointer_249, !noalias !2
        
        %closure_266 = call ccc %Object @newObject(ptr @eraser_269, i64 8)
        %environment_267 = call ccc %Environment @objectEnvironment(%Object %closure_266)
        %p_6_18_45_209_4234_pointer_271 = getelementptr <{%Prompt}>, %Environment %environment_267, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4234, ptr %p_6_18_45_209_4234_pointer_271, !noalias !2
        %vtable_temporary_272 = insertvalue %Neg zeroinitializer, ptr @vtable_265, 0
        %Exception_7_19_46_210_4225 = insertvalue %Neg %vtable_temporary_272, %Object %closure_266, 1
        %stackPointer_284 = call ccc %StackPointer @stackAllocate(%Stack %stack_240, i64 24)
        %returnAddress_pointer_285 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_284, i64 0, i32 1, i32 0
        %sharer_pointer_286 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_284, i64 0, i32 1, i32 1
        %eraser_pointer_287 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_284, i64 0, i32 1, i32 2
        store ptr @returnAddress_273, ptr %returnAddress_pointer_285, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_286, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_287, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2502_30_194_4207, i64 %index_7_34_198_4372, %Neg %Exception_7_19_46_210_4225, %Stack %stack_240)
        ret void
}



define tailcc void @Exception_9_106_133_297_4176_clause_288(%Object %closure, %Pos %exception_10_107_134_298_4618, %Pos %msg_11_108_135_299_4619, %Stack %stack) {
        
    entry:
        
        %environment_289 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4061_pointer_290 = getelementptr <{%Prompt}>, %Environment %environment_289, i64 0, i32 0
        %p_8_9_4061 = load %Prompt, ptr %p_8_9_4061_pointer_290, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4618)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4619)
        
        %pair_291 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4061)
        %k_13_14_4_4508 = extractvalue <{%Resumption, %Stack}> %pair_291, 0
        %stack_292 = extractvalue <{%Resumption, %Stack}> %pair_291, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4508)
        
        %longLiteral_4620 = add i64 5, 0
        
        
        
        %pureApp_4621 = call ccc %Pos @boxInt_301(i64 %longLiteral_4620)
        
        
        
        %stackPointer_294 = call ccc %StackPointer @stackDeallocate(%Stack %stack_292, i64 24)
        %returnAddress_pointer_295 = getelementptr %FrameHeader, %StackPointer %stackPointer_294, i64 0, i32 0
        %returnAddress_293 = load %ReturnAddress, ptr %returnAddress_pointer_295, !noalias !2
        musttail call tailcc void %returnAddress_293(%Pos %pureApp_4621, %Stack %stack_292)
        ret void
}


@vtable_296 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4176_clause_288]


define tailcc void @returnAddress_307(i64 %v_coe_3405_22_131_158_322_4295, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4624 = call ccc %Pos @boxInt_301(i64 %v_coe_3405_22_131_158_322_4295)
        
        
        
        
        
        %pureApp_4625 = call ccc i64 @unboxInt_303(%Pos %pureApp_4624)
        
        
        
        %pureApp_4626 = call ccc %Pos @boxInt_301(i64 %pureApp_4625)
        
        
        
        %stackPointer_309 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_310 = getelementptr %FrameHeader, %StackPointer %stackPointer_309, i64 0, i32 0
        %returnAddress_308 = load %ReturnAddress, ptr %returnAddress_pointer_310, !noalias !2
        musttail call tailcc void %returnAddress_308(%Pos %pureApp_4626, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_319(i64 %v_r_2599_1_9_20_129_156_320_4319, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4630 = add i64 0, 0
        
        %pureApp_4629 = call ccc i64 @infixSub_105(i64 %longLiteral_4630, i64 %v_r_2599_1_9_20_129_156_320_4319)
        
        
        
        %stackPointer_321 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_322 = getelementptr %FrameHeader, %StackPointer %stackPointer_321, i64 0, i32 0
        %returnAddress_320 = load %ReturnAddress, ptr %returnAddress_pointer_322, !noalias !2
        musttail call tailcc void %returnAddress_320(i64 %pureApp_4629, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_302(i64 %v_r_2598_3_14_123_150_314_4151, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_303 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_4061_pointer_304 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_303, i64 0, i32 0
        %p_8_9_4061 = load %Prompt, ptr %p_8_9_4061_pointer_304, !noalias !2
        %v_r_2502_30_194_4207_pointer_305 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_303, i64 0, i32 1
        %v_r_2502_30_194_4207 = load %Pos, ptr %v_r_2502_30_194_4207_pointer_305, !noalias !2
        %tmp_4525_pointer_306 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_303, i64 0, i32 2
        %tmp_4525 = load i64, ptr %tmp_4525_pointer_306, !noalias !2
        
        %intLiteral_4623 = add i64 45, 0
        
        %pureApp_4622 = call ccc %Pos @infixEq_78(i64 %v_r_2598_3_14_123_150_314_4151, i64 %intLiteral_4623)
        
        
        %stackPointer_311 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_312 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_311, i64 0, i32 1, i32 0
        %sharer_pointer_313 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_311, i64 0, i32 1, i32 1
        %eraser_pointer_314 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_311, i64 0, i32 1, i32 2
        store ptr @returnAddress_307, ptr %returnAddress_pointer_312, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_313, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_314, !noalias !2
        
        %tag_315 = extractvalue %Pos %pureApp_4622, 0
        %fields_316 = extractvalue %Pos %pureApp_4622, 1
        switch i64 %tag_315, label %label_317 [i64 0, label %label_318 i64 1, label %label_327]
    
    label_317:
        
        ret void
    
    label_318:
        
        %longLiteral_4627 = add i64 0, 0
        
        %longLiteral_4628 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4318(i64 %longLiteral_4627, i64 %longLiteral_4628, %Prompt %p_8_9_4061, %Pos %v_r_2502_30_194_4207, i64 %tmp_4525, %Stack %stack)
        ret void
    
    label_327:
        %stackPointer_323 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_324 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 0
        %sharer_pointer_325 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 1
        %eraser_pointer_326 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 2
        store ptr @returnAddress_319, ptr %returnAddress_pointer_324, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_325, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_326, !noalias !2
        
        %longLiteral_4631 = add i64 1, 0
        
        %longLiteral_4632 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4318(i64 %longLiteral_4631, i64 %longLiteral_4632, %Prompt %p_8_9_4061, %Pos %v_r_2502_30_194_4207, i64 %tmp_4525, %Stack %stack)
        ret void
}



define ccc void @sharer_331(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_332 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4061_328_pointer_333 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_332, i64 0, i32 0
        %p_8_9_4061_328 = load %Prompt, ptr %p_8_9_4061_328_pointer_333, !noalias !2
        %v_r_2502_30_194_4207_329_pointer_334 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_332, i64 0, i32 1
        %v_r_2502_30_194_4207_329 = load %Pos, ptr %v_r_2502_30_194_4207_329_pointer_334, !noalias !2
        %tmp_4525_330_pointer_335 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_332, i64 0, i32 2
        %tmp_4525_330 = load i64, ptr %tmp_4525_330_pointer_335, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2502_30_194_4207_329)
        call ccc void @shareFrames(%StackPointer %stackPointer_332)
        ret void
}



define ccc void @eraser_339(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_340 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4061_336_pointer_341 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_340, i64 0, i32 0
        %p_8_9_4061_336 = load %Prompt, ptr %p_8_9_4061_336_pointer_341, !noalias !2
        %v_r_2502_30_194_4207_337_pointer_342 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_340, i64 0, i32 1
        %v_r_2502_30_194_4207_337 = load %Pos, ptr %v_r_2502_30_194_4207_337_pointer_342, !noalias !2
        %tmp_4525_338_pointer_343 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_340, i64 0, i32 2
        %tmp_4525_338 = load i64, ptr %tmp_4525_338_pointer_343, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2502_30_194_4207_337)
        call ccc void @eraseFrames(%StackPointer %stackPointer_340)
        ret void
}



define tailcc void @returnAddress_164(%Pos %v_r_2502_30_194_4207, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_165 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4061_pointer_166 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_165, i64 0, i32 0
        %p_8_9_4061 = load %Prompt, ptr %p_8_9_4061_pointer_166, !noalias !2
        
        %intLiteral_4595 = add i64 48, 0
        
        %pureApp_4594 = call ccc i64 @toInt_2085(i64 %intLiteral_4595)
        
        
        
        %closure_297 = call ccc %Object @newObject(ptr @eraser_269, i64 8)
        %environment_298 = call ccc %Environment @objectEnvironment(%Object %closure_297)
        %p_8_9_4061_pointer_300 = getelementptr <{%Prompt}>, %Environment %environment_298, i64 0, i32 0
        store %Prompt %p_8_9_4061, ptr %p_8_9_4061_pointer_300, !noalias !2
        %vtable_temporary_301 = insertvalue %Neg zeroinitializer, ptr @vtable_296, 0
        %Exception_9_106_133_297_4176 = insertvalue %Neg %vtable_temporary_301, %Object %closure_297, 1
        call ccc void @sharePositive(%Pos %v_r_2502_30_194_4207)
        %stackPointer_344 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_4061_pointer_345 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_344, i64 0, i32 0
        store %Prompt %p_8_9_4061, ptr %p_8_9_4061_pointer_345, !noalias !2
        %v_r_2502_30_194_4207_pointer_346 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_344, i64 0, i32 1
        store %Pos %v_r_2502_30_194_4207, ptr %v_r_2502_30_194_4207_pointer_346, !noalias !2
        %tmp_4525_pointer_347 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_344, i64 0, i32 2
        store i64 %pureApp_4594, ptr %tmp_4525_pointer_347, !noalias !2
        %returnAddress_pointer_348 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_344, i64 0, i32 1, i32 0
        %sharer_pointer_349 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_344, i64 0, i32 1, i32 1
        %eraser_pointer_350 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_344, i64 0, i32 1, i32 2
        store ptr @returnAddress_302, ptr %returnAddress_pointer_348, !noalias !2
        store ptr @sharer_331, ptr %sharer_pointer_349, !noalias !2
        store ptr @eraser_339, ptr %eraser_pointer_350, !noalias !2
        
        %longLiteral_4633 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2502_30_194_4207, i64 %longLiteral_4633, %Neg %Exception_9_106_133_297_4176, %Stack %stack)
        ret void
}



define ccc void @sharer_352(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_353 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4061_351_pointer_354 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_353, i64 0, i32 0
        %p_8_9_4061_351 = load %Prompt, ptr %p_8_9_4061_351_pointer_354, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_353)
        ret void
}



define ccc void @eraser_356(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_357 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4061_355_pointer_358 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_357, i64 0, i32 0
        %p_8_9_4061_355 = load %Prompt, ptr %p_8_9_4061_355_pointer_358, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_357)
        ret void
}


@utf8StringLiteral_4634.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_161(%Pos %v_r_2501_24_188_4298, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_162 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4061_pointer_163 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_162, i64 0, i32 0
        %p_8_9_4061 = load %Prompt, ptr %p_8_9_4061_pointer_163, !noalias !2
        %stackPointer_359 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4061_pointer_360 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_359, i64 0, i32 0
        store %Prompt %p_8_9_4061, ptr %p_8_9_4061_pointer_360, !noalias !2
        %returnAddress_pointer_361 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_359, i64 0, i32 1, i32 0
        %sharer_pointer_362 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_359, i64 0, i32 1, i32 1
        %eraser_pointer_363 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_359, i64 0, i32 1, i32 2
        store ptr @returnAddress_164, ptr %returnAddress_pointer_361, !noalias !2
        store ptr @sharer_352, ptr %sharer_pointer_362, !noalias !2
        store ptr @eraser_356, ptr %eraser_pointer_363, !noalias !2
        
        %tag_364 = extractvalue %Pos %v_r_2501_24_188_4298, 0
        %fields_365 = extractvalue %Pos %v_r_2501_24_188_4298, 1
        switch i64 %tag_364, label %label_366 [i64 0, label %label_370 i64 1, label %label_376]
    
    label_366:
        
        ret void
    
    label_370:
        
        %utf8StringLiteral_4634 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4634.lit)
        
        %stackPointer_368 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_369 = getelementptr %FrameHeader, %StackPointer %stackPointer_368, i64 0, i32 0
        %returnAddress_367 = load %ReturnAddress, ptr %returnAddress_pointer_369, !noalias !2
        musttail call tailcc void %returnAddress_367(%Pos %utf8StringLiteral_4634, %Stack %stack)
        ret void
    
    label_376:
        %environment_371 = call ccc %Environment @objectEnvironment(%Object %fields_365)
        %v_y_3227_8_29_193_4359_pointer_372 = getelementptr <{%Pos}>, %Environment %environment_371, i64 0, i32 0
        %v_y_3227_8_29_193_4359 = load %Pos, ptr %v_y_3227_8_29_193_4359_pointer_372, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3227_8_29_193_4359)
        call ccc void @eraseObject(%Object %fields_365)
        
        %stackPointer_374 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_375 = getelementptr %FrameHeader, %StackPointer %stackPointer_374, i64 0, i32 0
        %returnAddress_373 = load %ReturnAddress, ptr %returnAddress_pointer_375, !noalias !2
        musttail call tailcc void %returnAddress_373(%Pos %v_y_3227_8_29_193_4359, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_158(%Pos %v_r_2500_13_177_4142, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_159 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4061_pointer_160 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_159, i64 0, i32 0
        %p_8_9_4061 = load %Prompt, ptr %p_8_9_4061_pointer_160, !noalias !2
        %stackPointer_379 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4061_pointer_380 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_379, i64 0, i32 0
        store %Prompt %p_8_9_4061, ptr %p_8_9_4061_pointer_380, !noalias !2
        %returnAddress_pointer_381 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_379, i64 0, i32 1, i32 0
        %sharer_pointer_382 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_379, i64 0, i32 1, i32 1
        %eraser_pointer_383 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_379, i64 0, i32 1, i32 2
        store ptr @returnAddress_161, ptr %returnAddress_pointer_381, !noalias !2
        store ptr @sharer_352, ptr %sharer_pointer_382, !noalias !2
        store ptr @eraser_356, ptr %eraser_pointer_383, !noalias !2
        
        %tag_384 = extractvalue %Pos %v_r_2500_13_177_4142, 0
        %fields_385 = extractvalue %Pos %v_r_2500_13_177_4142, 1
        switch i64 %tag_384, label %label_386 [i64 0, label %label_391 i64 1, label %label_403]
    
    label_386:
        
        ret void
    
    label_391:
        
        %make_4635_temporary_387 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4635 = insertvalue %Pos %make_4635_temporary_387, %Object null, 1
        
        
        
        %stackPointer_389 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_390 = getelementptr %FrameHeader, %StackPointer %stackPointer_389, i64 0, i32 0
        %returnAddress_388 = load %ReturnAddress, ptr %returnAddress_pointer_390, !noalias !2
        musttail call tailcc void %returnAddress_388(%Pos %make_4635, %Stack %stack)
        ret void
    
    label_403:
        %environment_392 = call ccc %Environment @objectEnvironment(%Object %fields_385)
        %v_y_2736_10_21_185_4327_pointer_393 = getelementptr <{%Pos, %Pos}>, %Environment %environment_392, i64 0, i32 0
        %v_y_2736_10_21_185_4327 = load %Pos, ptr %v_y_2736_10_21_185_4327_pointer_393, !noalias !2
        %v_y_2737_11_22_186_4214_pointer_394 = getelementptr <{%Pos, %Pos}>, %Environment %environment_392, i64 0, i32 1
        %v_y_2737_11_22_186_4214 = load %Pos, ptr %v_y_2737_11_22_186_4214_pointer_394, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2736_10_21_185_4327)
        call ccc void @eraseObject(%Object %fields_385)
        
        %fields_395 = call ccc %Object @newObject(ptr @eraser_277, i64 16)
        %environment_396 = call ccc %Environment @objectEnvironment(%Object %fields_395)
        %v_y_2736_10_21_185_4327_pointer_398 = getelementptr <{%Pos}>, %Environment %environment_396, i64 0, i32 0
        store %Pos %v_y_2736_10_21_185_4327, ptr %v_y_2736_10_21_185_4327_pointer_398, !noalias !2
        %make_4636_temporary_399 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4636 = insertvalue %Pos %make_4636_temporary_399, %Object %fields_395, 1
        
        
        
        %stackPointer_401 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_402 = getelementptr %FrameHeader, %StackPointer %stackPointer_401, i64 0, i32 0
        %returnAddress_400 = load %ReturnAddress, ptr %returnAddress_pointer_402, !noalias !2
        musttail call tailcc void %returnAddress_400(%Pos %make_4636, %Stack %stack)
        ret void
}



define tailcc void @main_2438(%Stack %stack) {
        
    entry:
        
        %stackPointer_121 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_122 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_121, i64 0, i32 1, i32 0
        %sharer_pointer_123 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_121, i64 0, i32 1, i32 1
        %eraser_pointer_124 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_121, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_122, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_123, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_124, !noalias !2
        
        %stack_125 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4061 = call ccc %Prompt @currentPrompt(%Stack %stack_125)
        %stackPointer_135 = call ccc %StackPointer @stackAllocate(%Stack %stack_125, i64 24)
        %returnAddress_pointer_136 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_135, i64 0, i32 1, i32 0
        %sharer_pointer_137 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_135, i64 0, i32 1, i32 1
        %eraser_pointer_138 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_135, i64 0, i32 1, i32 2
        store ptr @returnAddress_126, ptr %returnAddress_pointer_136, !noalias !2
        store ptr @sharer_131, ptr %sharer_pointer_137, !noalias !2
        store ptr @eraser_133, ptr %eraser_pointer_138, !noalias !2
        
        %pureApp_4590 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4592 = add i64 1, 0
        
        %pureApp_4591 = call ccc i64 @infixSub_105(i64 %pureApp_4590, i64 %longLiteral_4592)
        
        
        
        %make_4593_temporary_157 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4593 = insertvalue %Pos %make_4593_temporary_157, %Object null, 1
        
        
        %stackPointer_406 = call ccc %StackPointer @stackAllocate(%Stack %stack_125, i64 32)
        %p_8_9_4061_pointer_407 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_406, i64 0, i32 0
        store %Prompt %p_8_9_4061, ptr %p_8_9_4061_pointer_407, !noalias !2
        %returnAddress_pointer_408 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_406, i64 0, i32 1, i32 0
        %sharer_pointer_409 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_406, i64 0, i32 1, i32 1
        %eraser_pointer_410 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_406, i64 0, i32 1, i32 2
        store ptr @returnAddress_158, ptr %returnAddress_pointer_408, !noalias !2
        store ptr @sharer_352, ptr %sharer_pointer_409, !noalias !2
        store ptr @eraser_356, ptr %eraser_pointer_410, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4169(i64 %pureApp_4591, %Pos %make_4593, %Stack %stack_125)
        ret void
}


@utf8StringLiteral_4560.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4562.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4565.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_411(%Pos %v_r_2667_3457, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_412 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_413 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_412, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_413, !noalias !2
        %index_2107_pointer_414 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_412, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_414, !noalias !2
        %Exception_2362_pointer_415 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_412, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_415, !noalias !2
        
        %tag_416 = extractvalue %Pos %v_r_2667_3457, 0
        %fields_417 = extractvalue %Pos %v_r_2667_3457, 1
        switch i64 %tag_416, label %label_418 [i64 0, label %label_422 i64 1, label %label_428]
    
    label_418:
        
        ret void
    
    label_422:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4556 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_420 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_421 = getelementptr %FrameHeader, %StackPointer %stackPointer_420, i64 0, i32 0
        %returnAddress_419 = load %ReturnAddress, ptr %returnAddress_pointer_421, !noalias !2
        musttail call tailcc void %returnAddress_419(i64 %pureApp_4556, %Stack %stack)
        ret void
    
    label_428:
        
        %make_4557_temporary_423 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4557 = insertvalue %Pos %make_4557_temporary_423, %Object null, 1
        
        
        
        %pureApp_4558 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4560 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4560.lit)
        
        %pureApp_4559 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4560, %Pos %pureApp_4558)
        
        
        
        %utf8StringLiteral_4562 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4562.lit)
        
        %pureApp_4561 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4559, %Pos %utf8StringLiteral_4562)
        
        
        
        %pureApp_4563 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4561, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4565 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4565.lit)
        
        %pureApp_4564 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4563, %Pos %utf8StringLiteral_4565)
        
        
        
        %vtable_424 = extractvalue %Neg %Exception_2362, 0
        %closure_425 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_426 = getelementptr ptr, ptr %vtable_424, i64 0
        %functionPointer_427 = load ptr, ptr %functionPointer_pointer_426, !noalias !2
        musttail call tailcc void %functionPointer_427(%Object %closure_425, %Pos %make_4557, %Pos %pureApp_4564, %Stack %stack)
        ret void
}



define ccc void @sharer_432(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_433 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_429_pointer_434 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_433, i64 0, i32 0
        %str_2106_429 = load %Pos, ptr %str_2106_429_pointer_434, !noalias !2
        %index_2107_430_pointer_435 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_433, i64 0, i32 1
        %index_2107_430 = load i64, ptr %index_2107_430_pointer_435, !noalias !2
        %Exception_2362_431_pointer_436 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_433, i64 0, i32 2
        %Exception_2362_431 = load %Neg, ptr %Exception_2362_431_pointer_436, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_429)
        call ccc void @shareNegative(%Neg %Exception_2362_431)
        call ccc void @shareFrames(%StackPointer %stackPointer_433)
        ret void
}



define ccc void @eraser_440(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_441 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_437_pointer_442 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_441, i64 0, i32 0
        %str_2106_437 = load %Pos, ptr %str_2106_437_pointer_442, !noalias !2
        %index_2107_438_pointer_443 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_441, i64 0, i32 1
        %index_2107_438 = load i64, ptr %index_2107_438_pointer_443, !noalias !2
        %Exception_2362_439_pointer_444 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_441, i64 0, i32 2
        %Exception_2362_439 = load %Neg, ptr %Exception_2362_439_pointer_444, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_437)
        call ccc void @eraseNegative(%Neg %Exception_2362_439)
        call ccc void @eraseFrames(%StackPointer %stackPointer_441)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4555 = add i64 0, 0
        
        %pureApp_4554 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4555)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_445 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_446 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_445, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_446, !noalias !2
        %index_2107_pointer_447 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_445, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_447, !noalias !2
        %Exception_2362_pointer_448 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_445, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_448, !noalias !2
        %returnAddress_pointer_449 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_445, i64 0, i32 1, i32 0
        %sharer_pointer_450 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_445, i64 0, i32 1, i32 1
        %eraser_pointer_451 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_445, i64 0, i32 1, i32 2
        store ptr @returnAddress_411, ptr %returnAddress_pointer_449, !noalias !2
        store ptr @sharer_432, ptr %sharer_pointer_450, !noalias !2
        store ptr @eraser_440, ptr %eraser_pointer_451, !noalias !2
        
        %tag_452 = extractvalue %Pos %pureApp_4554, 0
        %fields_453 = extractvalue %Pos %pureApp_4554, 1
        switch i64 %tag_452, label %label_454 [i64 0, label %label_458 i64 1, label %label_463]
    
    label_454:
        
        ret void
    
    label_458:
        
        %pureApp_4566 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4567 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4566)
        
        
        
        %stackPointer_456 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_457 = getelementptr %FrameHeader, %StackPointer %stackPointer_456, i64 0, i32 0
        %returnAddress_455 = load %ReturnAddress, ptr %returnAddress_pointer_457, !noalias !2
        musttail call tailcc void %returnAddress_455(%Pos %pureApp_4567, %Stack %stack)
        ret void
    
    label_463:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4568_temporary_459 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4568 = insertvalue %Pos %booleanLiteral_4568_temporary_459, %Object null, 1
        
        %stackPointer_461 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_462 = getelementptr %FrameHeader, %StackPointer %stackPointer_461, i64 0, i32 0
        %returnAddress_460 = load %ReturnAddress, ptr %returnAddress_pointer_462, !noalias !2
        musttail call tailcc void %returnAddress_460(%Pos %booleanLiteral_4568, %Stack %stack)
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
        
        musttail call tailcc void @main_2438(%Stack %stack)
        ret void
}
