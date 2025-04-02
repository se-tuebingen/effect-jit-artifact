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



define ccc %Pos @panic_552(%Pos %msg_551) {
    ; declaration extern
    ; variable
    
    call void @c_io_println_String(%Pos %msg_551)
    call void @exit(i32 1)
    ret %Pos zeroinitializer ; Unit
  
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



define tailcc void @returnAddress_29(i64 %v_r_2588_6_4703, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_30 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_4695_pointer_31 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_30, i64 0, i32 0
        %i_6_4695 = load i64, ptr %i_6_4695_pointer_31, !noalias !2
        %tmp_4815_pointer_32 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_30, i64 0, i32 1
        %tmp_4815 = load i64, ptr %tmp_4815_pointer_32, !noalias !2
        
        %longLiteral_4869 = add i64 1, 0
        
        %pureApp_4868 = call ccc i64 @infixAdd_96(i64 %i_6_4695, i64 %longLiteral_4869)
        
        
        
        
        
        musttail call tailcc void @loop_5_4698(i64 %pureApp_4868, i64 %tmp_4815, %Stack %stack)
        ret void
}



define ccc void @sharer_35(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_36 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_4695_33_pointer_37 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_36, i64 0, i32 0
        %i_6_4695_33 = load i64, ptr %i_6_4695_33_pointer_37, !noalias !2
        %tmp_4815_34_pointer_38 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_36, i64 0, i32 1
        %tmp_4815_34 = load i64, ptr %tmp_4815_34_pointer_38, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_36)
        ret void
}



define ccc void @eraser_41(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_42 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_4695_39_pointer_43 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_42, i64 0, i32 0
        %i_6_4695_39 = load i64, ptr %i_6_4695_39_pointer_43, !noalias !2
        %tmp_4815_40_pointer_44 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_42, i64 0, i32 1
        %tmp_4815_40 = load i64, ptr %tmp_4815_40_pointer_44, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_42)
        ret void
}



define tailcc void @returnAddress_25(%Pos %v_r_2581_5_5_4705, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_26 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_4695_pointer_27 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        %i_6_4695 = load i64, ptr %i_6_4695_pointer_27, !noalias !2
        %tmp_4815_pointer_28 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 1
        %tmp_4815 = load i64, ptr %tmp_4815_pointer_28, !noalias !2
        %stackPointer_45 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_4695_pointer_46 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_45, i64 0, i32 0
        store i64 %i_6_4695, ptr %i_6_4695_pointer_46, !noalias !2
        %tmp_4815_pointer_47 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_45, i64 0, i32 1
        store i64 %tmp_4815, ptr %tmp_4815_pointer_47, !noalias !2
        %returnAddress_pointer_48 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_45, i64 0, i32 1, i32 0
        %sharer_pointer_49 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_45, i64 0, i32 1, i32 1
        %eraser_pointer_50 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_45, i64 0, i32 1, i32 2
        store ptr @returnAddress_29, ptr %returnAddress_pointer_48, !noalias !2
        store ptr @sharer_35, ptr %sharer_pointer_49, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_50, !noalias !2
        
        
        
        musttail call tailcc void @length_2433(%Pos %v_r_2581_5_5_4705, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_19(%Pos %v_r_2580_4_4_4701, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_20 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %v_r_2578_2_2_4700_pointer_21 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_20, i64 0, i32 0
        %v_r_2578_2_2_4700 = load %Pos, ptr %v_r_2578_2_2_4700_pointer_21, !noalias !2
        %i_6_4695_pointer_22 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_20, i64 0, i32 1
        %i_6_4695 = load i64, ptr %i_6_4695_pointer_22, !noalias !2
        %tmp_4815_pointer_23 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_20, i64 0, i32 2
        %tmp_4815 = load i64, ptr %tmp_4815_pointer_23, !noalias !2
        %v_r_2579_3_3_4702_pointer_24 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_20, i64 0, i32 3
        %v_r_2579_3_3_4702 = load %Pos, ptr %v_r_2579_3_3_4702_pointer_24, !noalias !2
        %stackPointer_55 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_4695_pointer_56 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_55, i64 0, i32 0
        store i64 %i_6_4695, ptr %i_6_4695_pointer_56, !noalias !2
        %tmp_4815_pointer_57 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_55, i64 0, i32 1
        store i64 %tmp_4815, ptr %tmp_4815_pointer_57, !noalias !2
        %returnAddress_pointer_58 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_55, i64 0, i32 1, i32 0
        %sharer_pointer_59 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_55, i64 0, i32 1, i32 1
        %eraser_pointer_60 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_55, i64 0, i32 1, i32 2
        store ptr @returnAddress_25, ptr %returnAddress_pointer_58, !noalias !2
        store ptr @sharer_35, ptr %sharer_pointer_59, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_60, !noalias !2
        
        
        
        
        
        musttail call tailcc void @tail_2442(%Pos %v_r_2578_2_2_4700, %Pos %v_r_2579_3_3_4702, %Pos %v_r_2580_4_4_4701, %Stack %stack)
        ret void
}



define ccc void @sharer_65(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_66 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2578_2_2_4700_61_pointer_67 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_66, i64 0, i32 0
        %v_r_2578_2_2_4700_61 = load %Pos, ptr %v_r_2578_2_2_4700_61_pointer_67, !noalias !2
        %i_6_4695_62_pointer_68 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_66, i64 0, i32 1
        %i_6_4695_62 = load i64, ptr %i_6_4695_62_pointer_68, !noalias !2
        %tmp_4815_63_pointer_69 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_66, i64 0, i32 2
        %tmp_4815_63 = load i64, ptr %tmp_4815_63_pointer_69, !noalias !2
        %v_r_2579_3_3_4702_64_pointer_70 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_66, i64 0, i32 3
        %v_r_2579_3_3_4702_64 = load %Pos, ptr %v_r_2579_3_3_4702_64_pointer_70, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2578_2_2_4700_61)
        call ccc void @sharePositive(%Pos %v_r_2579_3_3_4702_64)
        call ccc void @shareFrames(%StackPointer %stackPointer_66)
        ret void
}



define ccc void @eraser_75(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_76 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2578_2_2_4700_71_pointer_77 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_76, i64 0, i32 0
        %v_r_2578_2_2_4700_71 = load %Pos, ptr %v_r_2578_2_2_4700_71_pointer_77, !noalias !2
        %i_6_4695_72_pointer_78 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_76, i64 0, i32 1
        %i_6_4695_72 = load i64, ptr %i_6_4695_72_pointer_78, !noalias !2
        %tmp_4815_73_pointer_79 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_76, i64 0, i32 2
        %tmp_4815_73 = load i64, ptr %tmp_4815_73_pointer_79, !noalias !2
        %v_r_2579_3_3_4702_74_pointer_80 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_76, i64 0, i32 3
        %v_r_2579_3_3_4702_74 = load %Pos, ptr %v_r_2579_3_3_4702_74_pointer_80, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2578_2_2_4700_71)
        call ccc void @erasePositive(%Pos %v_r_2579_3_3_4702_74)
        call ccc void @eraseFrames(%StackPointer %stackPointer_76)
        ret void
}



define tailcc void @returnAddress_14(%Pos %v_r_2579_3_3_4702, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_15 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_2578_2_2_4700_pointer_16 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_15, i64 0, i32 0
        %v_r_2578_2_2_4700 = load %Pos, ptr %v_r_2578_2_2_4700_pointer_16, !noalias !2
        %i_6_4695_pointer_17 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_15, i64 0, i32 1
        %i_6_4695 = load i64, ptr %i_6_4695_pointer_17, !noalias !2
        %tmp_4815_pointer_18 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_15, i64 0, i32 2
        %tmp_4815 = load i64, ptr %tmp_4815_pointer_18, !noalias !2
        %stackPointer_81 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %v_r_2578_2_2_4700_pointer_82 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_81, i64 0, i32 0
        store %Pos %v_r_2578_2_2_4700, ptr %v_r_2578_2_2_4700_pointer_82, !noalias !2
        %i_6_4695_pointer_83 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_81, i64 0, i32 1
        store i64 %i_6_4695, ptr %i_6_4695_pointer_83, !noalias !2
        %tmp_4815_pointer_84 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_81, i64 0, i32 2
        store i64 %tmp_4815, ptr %tmp_4815_pointer_84, !noalias !2
        %v_r_2579_3_3_4702_pointer_85 = getelementptr <{%Pos, i64, i64, %Pos}>, %StackPointer %stackPointer_81, i64 0, i32 3
        store %Pos %v_r_2579_3_3_4702, ptr %v_r_2579_3_3_4702_pointer_85, !noalias !2
        %returnAddress_pointer_86 = getelementptr <{<{%Pos, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_81, i64 0, i32 1, i32 0
        %sharer_pointer_87 = getelementptr <{<{%Pos, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_81, i64 0, i32 1, i32 1
        %eraser_pointer_88 = getelementptr <{<{%Pos, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_81, i64 0, i32 1, i32 2
        store ptr @returnAddress_19, ptr %returnAddress_pointer_86, !noalias !2
        store ptr @sharer_65, ptr %sharer_pointer_87, !noalias !2
        store ptr @eraser_75, ptr %eraser_pointer_88, !noalias !2
        
        %longLiteral_4870 = add i64 6, 0
        
        
        
        musttail call tailcc void @makeList_2438(i64 %longLiteral_4870, %Stack %stack)
        ret void
}



define ccc void @sharer_92(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_93 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2578_2_2_4700_89_pointer_94 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_93, i64 0, i32 0
        %v_r_2578_2_2_4700_89 = load %Pos, ptr %v_r_2578_2_2_4700_89_pointer_94, !noalias !2
        %i_6_4695_90_pointer_95 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_93, i64 0, i32 1
        %i_6_4695_90 = load i64, ptr %i_6_4695_90_pointer_95, !noalias !2
        %tmp_4815_91_pointer_96 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_93, i64 0, i32 2
        %tmp_4815_91 = load i64, ptr %tmp_4815_91_pointer_96, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2578_2_2_4700_89)
        call ccc void @shareFrames(%StackPointer %stackPointer_93)
        ret void
}



define ccc void @eraser_100(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_101 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2578_2_2_4700_97_pointer_102 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_101, i64 0, i32 0
        %v_r_2578_2_2_4700_97 = load %Pos, ptr %v_r_2578_2_2_4700_97_pointer_102, !noalias !2
        %i_6_4695_98_pointer_103 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_101, i64 0, i32 1
        %i_6_4695_98 = load i64, ptr %i_6_4695_98_pointer_103, !noalias !2
        %tmp_4815_99_pointer_104 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_101, i64 0, i32 2
        %tmp_4815_99 = load i64, ptr %tmp_4815_99_pointer_104, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2578_2_2_4700_97)
        call ccc void @eraseFrames(%StackPointer %stackPointer_101)
        ret void
}



define tailcc void @returnAddress_10(%Pos %v_r_2578_2_2_4700, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_11 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_4695_pointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 0
        %i_6_4695 = load i64, ptr %i_6_4695_pointer_12, !noalias !2
        %tmp_4815_pointer_13 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 1
        %tmp_4815 = load i64, ptr %tmp_4815_pointer_13, !noalias !2
        %stackPointer_105 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_2578_2_2_4700_pointer_106 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_105, i64 0, i32 0
        store %Pos %v_r_2578_2_2_4700, ptr %v_r_2578_2_2_4700_pointer_106, !noalias !2
        %i_6_4695_pointer_107 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_105, i64 0, i32 1
        store i64 %i_6_4695, ptr %i_6_4695_pointer_107, !noalias !2
        %tmp_4815_pointer_108 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_105, i64 0, i32 2
        store i64 %tmp_4815, ptr %tmp_4815_pointer_108, !noalias !2
        %returnAddress_pointer_109 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_105, i64 0, i32 1, i32 0
        %sharer_pointer_110 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_105, i64 0, i32 1, i32 1
        %eraser_pointer_111 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_105, i64 0, i32 1, i32 2
        store ptr @returnAddress_14, ptr %returnAddress_pointer_109, !noalias !2
        store ptr @sharer_92, ptr %sharer_pointer_110, !noalias !2
        store ptr @eraser_100, ptr %eraser_pointer_111, !noalias !2
        
        %longLiteral_4871 = add i64 10, 0
        
        
        
        musttail call tailcc void @makeList_2438(i64 %longLiteral_4871, %Stack %stack)
        ret void
}



define tailcc void @loop_5_4698(i64 %i_6_4695, i64 %tmp_4815, %Stack %stack) {
        
    entry:
        
        
        %pureApp_4866 = call ccc %Pos @infixLt_178(i64 %i_6_4695, i64 %tmp_4815)
        
        
        
        %tag_2 = extractvalue %Pos %pureApp_4866, 0
        %fields_3 = extractvalue %Pos %pureApp_4866, 1
        switch i64 %tag_2, label %label_4 [i64 0, label %label_9 i64 1, label %label_122]
    
    label_4:
        
        ret void
    
    label_9:
        
        %unitLiteral_4867_temporary_5 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_4867 = insertvalue %Pos %unitLiteral_4867_temporary_5, %Object null, 1
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %unitLiteral_4867, %Stack %stack)
        ret void
    
    label_122:
        %stackPointer_116 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_4695_pointer_117 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_116, i64 0, i32 0
        store i64 %i_6_4695, ptr %i_6_4695_pointer_117, !noalias !2
        %tmp_4815_pointer_118 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_116, i64 0, i32 1
        store i64 %tmp_4815, ptr %tmp_4815_pointer_118, !noalias !2
        %returnAddress_pointer_119 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_116, i64 0, i32 1, i32 0
        %sharer_pointer_120 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_116, i64 0, i32 1, i32 1
        %eraser_pointer_121 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_116, i64 0, i32 1, i32 2
        store ptr @returnAddress_10, ptr %returnAddress_pointer_119, !noalias !2
        store ptr @sharer_35, ptr %sharer_pointer_120, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_121, !noalias !2
        
        %longLiteral_4872 = add i64 15, 0
        
        
        
        musttail call tailcc void @makeList_2438(i64 %longLiteral_4872, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_133(i64 %r_2457, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4874 = call ccc %Pos @show_14(i64 %r_2457)
        
        
        
        %pureApp_4875 = call ccc %Pos @println_1(%Pos %pureApp_4874)
        
        
        
        %stackPointer_135 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_136 = getelementptr %FrameHeader, %StackPointer %stackPointer_135, i64 0, i32 0
        %returnAddress_134 = load %ReturnAddress, ptr %returnAddress_pointer_136, !noalias !2
        musttail call tailcc void %returnAddress_134(%Pos %pureApp_4875, %Stack %stack)
        ret void
}



define ccc void @sharer_137(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_138 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_138)
        ret void
}



define ccc void @eraser_139(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_140 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_140)
        ret void
}



define tailcc void @returnAddress_132(%Pos %v_r_2581_5_4709, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_141 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_142 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_141, i64 0, i32 1, i32 0
        %sharer_pointer_143 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_141, i64 0, i32 1, i32 1
        %eraser_pointer_144 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_141, i64 0, i32 1, i32 2
        store ptr @returnAddress_133, ptr %returnAddress_pointer_142, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_143, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_144, !noalias !2
        
        
        
        musttail call tailcc void @length_2433(%Pos %v_r_2581_5_4709, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_128(%Pos %v_r_2580_4_4707, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_129 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_2578_2_4708_pointer_130 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_129, i64 0, i32 0
        %v_r_2578_2_4708 = load %Pos, ptr %v_r_2578_2_4708_pointer_130, !noalias !2
        %v_r_2579_3_4711_pointer_131 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_129, i64 0, i32 1
        %v_r_2579_3_4711 = load %Pos, ptr %v_r_2579_3_4711_pointer_131, !noalias !2
        %stackPointer_145 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_146 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_145, i64 0, i32 1, i32 0
        %sharer_pointer_147 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_145, i64 0, i32 1, i32 1
        %eraser_pointer_148 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_145, i64 0, i32 1, i32 2
        store ptr @returnAddress_132, ptr %returnAddress_pointer_146, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_147, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_148, !noalias !2
        
        
        
        
        
        musttail call tailcc void @tail_2442(%Pos %v_r_2578_2_4708, %Pos %v_r_2579_3_4711, %Pos %v_r_2580_4_4707, %Stack %stack)
        ret void
}



define ccc void @sharer_151(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_152 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2578_2_4708_149_pointer_153 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_152, i64 0, i32 0
        %v_r_2578_2_4708_149 = load %Pos, ptr %v_r_2578_2_4708_149_pointer_153, !noalias !2
        %v_r_2579_3_4711_150_pointer_154 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_152, i64 0, i32 1
        %v_r_2579_3_4711_150 = load %Pos, ptr %v_r_2579_3_4711_150_pointer_154, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2578_2_4708_149)
        call ccc void @sharePositive(%Pos %v_r_2579_3_4711_150)
        call ccc void @shareFrames(%StackPointer %stackPointer_152)
        ret void
}



define ccc void @eraser_157(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_158 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2578_2_4708_155_pointer_159 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_158, i64 0, i32 0
        %v_r_2578_2_4708_155 = load %Pos, ptr %v_r_2578_2_4708_155_pointer_159, !noalias !2
        %v_r_2579_3_4711_156_pointer_160 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_158, i64 0, i32 1
        %v_r_2579_3_4711_156 = load %Pos, ptr %v_r_2579_3_4711_156_pointer_160, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2578_2_4708_155)
        call ccc void @erasePositive(%Pos %v_r_2579_3_4711_156)
        call ccc void @eraseFrames(%StackPointer %stackPointer_158)
        ret void
}



define tailcc void @returnAddress_125(%Pos %v_r_2579_3_4711, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_126 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_r_2578_2_4708_pointer_127 = getelementptr <{%Pos}>, %StackPointer %stackPointer_126, i64 0, i32 0
        %v_r_2578_2_4708 = load %Pos, ptr %v_r_2578_2_4708_pointer_127, !noalias !2
        %stackPointer_161 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_2578_2_4708_pointer_162 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_161, i64 0, i32 0
        store %Pos %v_r_2578_2_4708, ptr %v_r_2578_2_4708_pointer_162, !noalias !2
        %v_r_2579_3_4711_pointer_163 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_161, i64 0, i32 1
        store %Pos %v_r_2579_3_4711, ptr %v_r_2579_3_4711_pointer_163, !noalias !2
        %returnAddress_pointer_164 = getelementptr <{<{%Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_161, i64 0, i32 1, i32 0
        %sharer_pointer_165 = getelementptr <{<{%Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_161, i64 0, i32 1, i32 1
        %eraser_pointer_166 = getelementptr <{<{%Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_161, i64 0, i32 1, i32 2
        store ptr @returnAddress_128, ptr %returnAddress_pointer_164, !noalias !2
        store ptr @sharer_151, ptr %sharer_pointer_165, !noalias !2
        store ptr @eraser_157, ptr %eraser_pointer_166, !noalias !2
        
        %longLiteral_4876 = add i64 6, 0
        
        
        
        musttail call tailcc void @makeList_2438(i64 %longLiteral_4876, %Stack %stack)
        ret void
}



define ccc void @sharer_168(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_169 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2578_2_4708_167_pointer_170 = getelementptr <{%Pos}>, %StackPointer %stackPointer_169, i64 0, i32 0
        %v_r_2578_2_4708_167 = load %Pos, ptr %v_r_2578_2_4708_167_pointer_170, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2578_2_4708_167)
        call ccc void @shareFrames(%StackPointer %stackPointer_169)
        ret void
}



define ccc void @eraser_172(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_173 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2578_2_4708_171_pointer_174 = getelementptr <{%Pos}>, %StackPointer %stackPointer_173, i64 0, i32 0
        %v_r_2578_2_4708_171 = load %Pos, ptr %v_r_2578_2_4708_171_pointer_174, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2578_2_4708_171)
        call ccc void @eraseFrames(%StackPointer %stackPointer_173)
        ret void
}



define tailcc void @returnAddress_124(%Pos %v_r_2578_2_4708, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_175 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %v_r_2578_2_4708_pointer_176 = getelementptr <{%Pos}>, %StackPointer %stackPointer_175, i64 0, i32 0
        store %Pos %v_r_2578_2_4708, ptr %v_r_2578_2_4708_pointer_176, !noalias !2
        %returnAddress_pointer_177 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 0
        %sharer_pointer_178 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 1
        %eraser_pointer_179 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 2
        store ptr @returnAddress_125, ptr %returnAddress_pointer_177, !noalias !2
        store ptr @sharer_168, ptr %sharer_pointer_178, !noalias !2
        store ptr @eraser_172, ptr %eraser_pointer_179, !noalias !2
        
        %longLiteral_4877 = add i64 10, 0
        
        
        
        musttail call tailcc void @makeList_2438(i64 %longLiteral_4877, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_123(%Pos %v_r_2590_4873, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %v_r_2590_4873)
        %stackPointer_180 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_181 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_180, i64 0, i32 1, i32 0
        %sharer_pointer_182 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_180, i64 0, i32 1, i32 1
        %eraser_pointer_183 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_180, i64 0, i32 1, i32 2
        store ptr @returnAddress_124, ptr %returnAddress_pointer_181, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_182, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_183, !noalias !2
        
        %longLiteral_4878 = add i64 15, 0
        
        
        
        musttail call tailcc void @makeList_2438(i64 %longLiteral_4878, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3532_3596, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4863 = call ccc i64 @unboxInt_303(%Pos %v_coe_3532_3596)
        
        
        
        %longLiteral_4865 = add i64 1, 0
        
        %pureApp_4864 = call ccc i64 @infixSub_105(i64 %pureApp_4863, i64 %longLiteral_4865)
        
        
        %stackPointer_184 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_185 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_184, i64 0, i32 1, i32 0
        %sharer_pointer_186 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_184, i64 0, i32 1, i32 1
        %eraser_pointer_187 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_184, i64 0, i32 1, i32 2
        store ptr @returnAddress_123, ptr %returnAddress_pointer_185, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_186, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_187, !noalias !2
        
        %longLiteral_4879 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_4698(i64 %longLiteral_4879, i64 %pureApp_4864, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_193(%Pos %returned_4880, %Stack %stack) {
        
    entry:
        
        %stack_194 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_196 = call ccc %StackPointer @stackDeallocate(%Stack %stack_194, i64 24)
        %returnAddress_pointer_197 = getelementptr %FrameHeader, %StackPointer %stackPointer_196, i64 0, i32 0
        %returnAddress_195 = load %ReturnAddress, ptr %returnAddress_pointer_197, !noalias !2
        musttail call tailcc void %returnAddress_195(%Pos %returned_4880, %Stack %stack_194)
        ret void
}



define ccc void @sharer_198(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_199 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_200(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_201 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_201)
        ret void
}



define ccc void @eraser_213(%Environment %environment) {
        
    entry:
        
        %tmp_4788_211_pointer_214 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4788_211 = load %Pos, ptr %tmp_4788_211_pointer_214, !noalias !2
        %acc_3_3_5_169_4544_212_pointer_215 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4544_212 = load %Pos, ptr %acc_3_3_5_169_4544_212_pointer_215, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4788_211)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4544_212)
        ret void
}



define tailcc void @toList_1_1_3_167_4614(i64 %start_2_2_4_168_4539, %Pos %acc_3_3_5_169_4544, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4882 = add i64 1, 0
        
        %pureApp_4881 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4539, i64 %longLiteral_4882)
        
        
        
        %tag_206 = extractvalue %Pos %pureApp_4881, 0
        %fields_207 = extractvalue %Pos %pureApp_4881, 1
        switch i64 %tag_206, label %label_208 [i64 0, label %label_219 i64 1, label %label_223]
    
    label_208:
        
        ret void
    
    label_219:
        
        %pureApp_4883 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4539)
        
        
        
        %longLiteral_4885 = add i64 1, 0
        
        %pureApp_4884 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4539, i64 %longLiteral_4885)
        
        
        
        %fields_209 = call ccc %Object @newObject(ptr @eraser_213, i64 32)
        %environment_210 = call ccc %Environment @objectEnvironment(%Object %fields_209)
        %tmp_4788_pointer_216 = getelementptr <{%Pos, %Pos}>, %Environment %environment_210, i64 0, i32 0
        store %Pos %pureApp_4883, ptr %tmp_4788_pointer_216, !noalias !2
        %acc_3_3_5_169_4544_pointer_217 = getelementptr <{%Pos, %Pos}>, %Environment %environment_210, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4544, ptr %acc_3_3_5_169_4544_pointer_217, !noalias !2
        %make_4886_temporary_218 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4886 = insertvalue %Pos %make_4886_temporary_218, %Object %fields_209, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4614(i64 %pureApp_4884, %Pos %make_4886, %Stack %stack)
        ret void
    
    label_223:
        
        %stackPointer_221 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_222 = getelementptr %FrameHeader, %StackPointer %stackPointer_221, i64 0, i32 0
        %returnAddress_220 = load %ReturnAddress, ptr %returnAddress_pointer_222, !noalias !2
        musttail call tailcc void %returnAddress_220(%Pos %acc_3_3_5_169_4544, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_234(%Pos %v_r_2671_32_59_223_4627, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_235 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %p_8_9_4318_pointer_236 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_235, i64 0, i32 0
        %p_8_9_4318 = load %Prompt, ptr %p_8_9_4318_pointer_236, !noalias !2
        %acc_8_35_199_4478_pointer_237 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_235, i64 0, i32 1
        %acc_8_35_199_4478 = load i64, ptr %acc_8_35_199_4478_pointer_237, !noalias !2
        %v_r_2585_30_194_4624_pointer_238 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_235, i64 0, i32 2
        %v_r_2585_30_194_4624 = load %Pos, ptr %v_r_2585_30_194_4624_pointer_238, !noalias !2
        %index_7_34_198_4532_pointer_239 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_235, i64 0, i32 3
        %index_7_34_198_4532 = load i64, ptr %index_7_34_198_4532_pointer_239, !noalias !2
        %tmp_4795_pointer_240 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_235, i64 0, i32 4
        %tmp_4795 = load i64, ptr %tmp_4795_pointer_240, !noalias !2
        
        %tag_241 = extractvalue %Pos %v_r_2671_32_59_223_4627, 0
        %fields_242 = extractvalue %Pos %v_r_2671_32_59_223_4627, 1
        switch i64 %tag_241, label %label_243 [i64 1, label %label_266 i64 0, label %label_273]
    
    label_243:
        
        ret void
    
    label_248:
        
        ret void
    
    label_254:
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4624)
        
        %pair_249 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4318)
        %k_13_14_4_4716 = extractvalue <{%Resumption, %Stack}> %pair_249, 0
        %stack_250 = extractvalue <{%Resumption, %Stack}> %pair_249, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4716)
        
        %longLiteral_4898 = add i64 10, 0
        
        
        
        %pureApp_4899 = call ccc %Pos @boxInt_301(i64 %longLiteral_4898)
        
        
        
        %stackPointer_252 = call ccc %StackPointer @stackDeallocate(%Stack %stack_250, i64 24)
        %returnAddress_pointer_253 = getelementptr %FrameHeader, %StackPointer %stackPointer_252, i64 0, i32 0
        %returnAddress_251 = load %ReturnAddress, ptr %returnAddress_pointer_253, !noalias !2
        musttail call tailcc void %returnAddress_251(%Pos %pureApp_4899, %Stack %stack_250)
        ret void
    
    label_257:
        
        ret void
    
    label_263:
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4624)
        
        %pair_258 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4318)
        %k_13_14_4_4715 = extractvalue <{%Resumption, %Stack}> %pair_258, 0
        %stack_259 = extractvalue <{%Resumption, %Stack}> %pair_258, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4715)
        
        %longLiteral_4902 = add i64 10, 0
        
        
        
        %pureApp_4903 = call ccc %Pos @boxInt_301(i64 %longLiteral_4902)
        
        
        
        %stackPointer_261 = call ccc %StackPointer @stackDeallocate(%Stack %stack_259, i64 24)
        %returnAddress_pointer_262 = getelementptr %FrameHeader, %StackPointer %stackPointer_261, i64 0, i32 0
        %returnAddress_260 = load %ReturnAddress, ptr %returnAddress_pointer_262, !noalias !2
        musttail call tailcc void %returnAddress_260(%Pos %pureApp_4903, %Stack %stack_259)
        ret void
    
    label_264:
        
        %longLiteral_4905 = add i64 1, 0
        
        %pureApp_4904 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4532, i64 %longLiteral_4905)
        
        
        
        %longLiteral_4907 = add i64 10, 0
        
        %pureApp_4906 = call ccc i64 @infixMul_99(i64 %longLiteral_4907, i64 %acc_8_35_199_4478)
        
        
        
        %pureApp_4908 = call ccc i64 @toInt_2085(i64 %pureApp_4895)
        
        
        
        %pureApp_4909 = call ccc i64 @infixSub_105(i64 %pureApp_4908, i64 %tmp_4795)
        
        
        
        %pureApp_4910 = call ccc i64 @infixAdd_96(i64 %pureApp_4906, i64 %pureApp_4909)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4620(i64 %pureApp_4904, i64 %pureApp_4910, %Prompt %p_8_9_4318, %Pos %v_r_2585_30_194_4624, i64 %tmp_4795, %Stack %stack)
        ret void
    
    label_265:
        
        %intLiteral_4901 = add i64 57, 0
        
        %pureApp_4900 = call ccc %Pos @infixLte_2093(i64 %pureApp_4895, i64 %intLiteral_4901)
        
        
        
        %tag_255 = extractvalue %Pos %pureApp_4900, 0
        %fields_256 = extractvalue %Pos %pureApp_4900, 1
        switch i64 %tag_255, label %label_257 [i64 0, label %label_263 i64 1, label %label_264]
    
    label_266:
        %environment_244 = call ccc %Environment @objectEnvironment(%Object %fields_242)
        %v_coe_3489_46_73_237_4512_pointer_245 = getelementptr <{%Pos}>, %Environment %environment_244, i64 0, i32 0
        %v_coe_3489_46_73_237_4512 = load %Pos, ptr %v_coe_3489_46_73_237_4512_pointer_245, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3489_46_73_237_4512)
        call ccc void @eraseObject(%Object %fields_242)
        
        %pureApp_4895 = call ccc i64 @unboxChar_313(%Pos %v_coe_3489_46_73_237_4512)
        
        
        
        %intLiteral_4897 = add i64 48, 0
        
        %pureApp_4896 = call ccc %Pos @infixGte_2099(i64 %pureApp_4895, i64 %intLiteral_4897)
        
        
        
        %tag_246 = extractvalue %Pos %pureApp_4896, 0
        %fields_247 = extractvalue %Pos %pureApp_4896, 1
        switch i64 %tag_246, label %label_248 [i64 0, label %label_254 i64 1, label %label_265]
    
    label_273:
        %environment_267 = call ccc %Environment @objectEnvironment(%Object %fields_242)
        %v_y_2678_76_103_267_4893_pointer_268 = getelementptr <{%Pos, %Pos}>, %Environment %environment_267, i64 0, i32 0
        %v_y_2678_76_103_267_4893 = load %Pos, ptr %v_y_2678_76_103_267_4893_pointer_268, !noalias !2
        %v_y_2679_77_104_268_4894_pointer_269 = getelementptr <{%Pos, %Pos}>, %Environment %environment_267, i64 0, i32 1
        %v_y_2679_77_104_268_4894 = load %Pos, ptr %v_y_2679_77_104_268_4894_pointer_269, !noalias !2
        call ccc void @eraseObject(%Object %fields_242)
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4624)
        
        %stackPointer_271 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_272 = getelementptr %FrameHeader, %StackPointer %stackPointer_271, i64 0, i32 0
        %returnAddress_270 = load %ReturnAddress, ptr %returnAddress_pointer_272, !noalias !2
        musttail call tailcc void %returnAddress_270(i64 %acc_8_35_199_4478, %Stack %stack)
        ret void
}



define ccc void @sharer_279(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_280 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4318_274_pointer_281 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_280, i64 0, i32 0
        %p_8_9_4318_274 = load %Prompt, ptr %p_8_9_4318_274_pointer_281, !noalias !2
        %acc_8_35_199_4478_275_pointer_282 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_280, i64 0, i32 1
        %acc_8_35_199_4478_275 = load i64, ptr %acc_8_35_199_4478_275_pointer_282, !noalias !2
        %v_r_2585_30_194_4624_276_pointer_283 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_280, i64 0, i32 2
        %v_r_2585_30_194_4624_276 = load %Pos, ptr %v_r_2585_30_194_4624_276_pointer_283, !noalias !2
        %index_7_34_198_4532_277_pointer_284 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_280, i64 0, i32 3
        %index_7_34_198_4532_277 = load i64, ptr %index_7_34_198_4532_277_pointer_284, !noalias !2
        %tmp_4795_278_pointer_285 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_280, i64 0, i32 4
        %tmp_4795_278 = load i64, ptr %tmp_4795_278_pointer_285, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2585_30_194_4624_276)
        call ccc void @shareFrames(%StackPointer %stackPointer_280)
        ret void
}



define ccc void @eraser_291(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_292 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4318_286_pointer_293 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_292, i64 0, i32 0
        %p_8_9_4318_286 = load %Prompt, ptr %p_8_9_4318_286_pointer_293, !noalias !2
        %acc_8_35_199_4478_287_pointer_294 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_292, i64 0, i32 1
        %acc_8_35_199_4478_287 = load i64, ptr %acc_8_35_199_4478_287_pointer_294, !noalias !2
        %v_r_2585_30_194_4624_288_pointer_295 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_292, i64 0, i32 2
        %v_r_2585_30_194_4624_288 = load %Pos, ptr %v_r_2585_30_194_4624_288_pointer_295, !noalias !2
        %index_7_34_198_4532_289_pointer_296 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_292, i64 0, i32 3
        %index_7_34_198_4532_289 = load i64, ptr %index_7_34_198_4532_289_pointer_296, !noalias !2
        %tmp_4795_290_pointer_297 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_292, i64 0, i32 4
        %tmp_4795_290 = load i64, ptr %tmp_4795_290_pointer_297, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4624_288)
        call ccc void @eraseFrames(%StackPointer %stackPointer_292)
        ret void
}



define tailcc void @returnAddress_308(%Pos %returned_4911, %Stack %stack) {
        
    entry:
        
        %stack_309 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_311 = call ccc %StackPointer @stackDeallocate(%Stack %stack_309, i64 24)
        %returnAddress_pointer_312 = getelementptr %FrameHeader, %StackPointer %stackPointer_311, i64 0, i32 0
        %returnAddress_310 = load %ReturnAddress, ptr %returnAddress_pointer_312, !noalias !2
        musttail call tailcc void %returnAddress_310(%Pos %returned_4911, %Stack %stack_309)
        ret void
}



define tailcc void @Exception_7_19_46_210_4451_clause_317(%Object %closure, %Pos %exc_8_20_47_211_4578, %Pos %msg_9_21_48_212_4635, %Stack %stack) {
        
    entry:
        
        %environment_318 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4568_pointer_319 = getelementptr <{%Prompt}>, %Environment %environment_318, i64 0, i32 0
        %p_6_18_45_209_4568 = load %Prompt, ptr %p_6_18_45_209_4568_pointer_319, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_320 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4568)
        %k_11_23_50_214_4643 = extractvalue <{%Resumption, %Stack}> %pair_320, 0
        %stack_321 = extractvalue <{%Resumption, %Stack}> %pair_320, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4643)
        
        %fields_322 = call ccc %Object @newObject(ptr @eraser_213, i64 32)
        %environment_323 = call ccc %Environment @objectEnvironment(%Object %fields_322)
        %exc_8_20_47_211_4578_pointer_326 = getelementptr <{%Pos, %Pos}>, %Environment %environment_323, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4578, ptr %exc_8_20_47_211_4578_pointer_326, !noalias !2
        %msg_9_21_48_212_4635_pointer_327 = getelementptr <{%Pos, %Pos}>, %Environment %environment_323, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4635, ptr %msg_9_21_48_212_4635_pointer_327, !noalias !2
        %make_4912_temporary_328 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4912 = insertvalue %Pos %make_4912_temporary_328, %Object %fields_322, 1
        
        
        
        %stackPointer_330 = call ccc %StackPointer @stackDeallocate(%Stack %stack_321, i64 24)
        %returnAddress_pointer_331 = getelementptr %FrameHeader, %StackPointer %stackPointer_330, i64 0, i32 0
        %returnAddress_329 = load %ReturnAddress, ptr %returnAddress_pointer_331, !noalias !2
        musttail call tailcc void %returnAddress_329(%Pos %make_4912, %Stack %stack_321)
        ret void
}


@vtable_332 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4451_clause_317]


define ccc void @eraser_336(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4568_335_pointer_337 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4568_335 = load %Prompt, ptr %p_6_18_45_209_4568_335_pointer_337, !noalias !2
        ret void
}



define ccc void @eraser_344(%Environment %environment) {
        
    entry:
        
        %tmp_4797_343_pointer_345 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4797_343 = load %Pos, ptr %tmp_4797_343_pointer_345, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4797_343)
        ret void
}



define tailcc void @returnAddress_340(i64 %v_coe_3488_6_28_55_219_4466, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4913 = call ccc %Pos @boxChar_311(i64 %v_coe_3488_6_28_55_219_4466)
        
        
        
        %fields_341 = call ccc %Object @newObject(ptr @eraser_344, i64 16)
        %environment_342 = call ccc %Environment @objectEnvironment(%Object %fields_341)
        %tmp_4797_pointer_346 = getelementptr <{%Pos}>, %Environment %environment_342, i64 0, i32 0
        store %Pos %pureApp_4913, ptr %tmp_4797_pointer_346, !noalias !2
        %make_4914_temporary_347 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4914 = insertvalue %Pos %make_4914_temporary_347, %Object %fields_341, 1
        
        
        
        %stackPointer_349 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_350 = getelementptr %FrameHeader, %StackPointer %stackPointer_349, i64 0, i32 0
        %returnAddress_348 = load %ReturnAddress, ptr %returnAddress_pointer_350, !noalias !2
        musttail call tailcc void %returnAddress_348(%Pos %make_4914, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4620(i64 %index_7_34_198_4532, i64 %acc_8_35_199_4478, %Prompt %p_8_9_4318, %Pos %v_r_2585_30_194_4624, i64 %tmp_4795, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2585_30_194_4624)
        %stackPointer_298 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %p_8_9_4318_pointer_299 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_298, i64 0, i32 0
        store %Prompt %p_8_9_4318, ptr %p_8_9_4318_pointer_299, !noalias !2
        %acc_8_35_199_4478_pointer_300 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_298, i64 0, i32 1
        store i64 %acc_8_35_199_4478, ptr %acc_8_35_199_4478_pointer_300, !noalias !2
        %v_r_2585_30_194_4624_pointer_301 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_298, i64 0, i32 2
        store %Pos %v_r_2585_30_194_4624, ptr %v_r_2585_30_194_4624_pointer_301, !noalias !2
        %index_7_34_198_4532_pointer_302 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_298, i64 0, i32 3
        store i64 %index_7_34_198_4532, ptr %index_7_34_198_4532_pointer_302, !noalias !2
        %tmp_4795_pointer_303 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_298, i64 0, i32 4
        store i64 %tmp_4795, ptr %tmp_4795_pointer_303, !noalias !2
        %returnAddress_pointer_304 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_298, i64 0, i32 1, i32 0
        %sharer_pointer_305 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_298, i64 0, i32 1, i32 1
        %eraser_pointer_306 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_298, i64 0, i32 1, i32 2
        store ptr @returnAddress_234, ptr %returnAddress_pointer_304, !noalias !2
        store ptr @sharer_279, ptr %sharer_pointer_305, !noalias !2
        store ptr @eraser_291, ptr %eraser_pointer_306, !noalias !2
        
        %stack_307 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4568 = call ccc %Prompt @currentPrompt(%Stack %stack_307)
        %stackPointer_313 = call ccc %StackPointer @stackAllocate(%Stack %stack_307, i64 24)
        %returnAddress_pointer_314 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_313, i64 0, i32 1, i32 0
        %sharer_pointer_315 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_313, i64 0, i32 1, i32 1
        %eraser_pointer_316 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_313, i64 0, i32 1, i32 2
        store ptr @returnAddress_308, ptr %returnAddress_pointer_314, !noalias !2
        store ptr @sharer_198, ptr %sharer_pointer_315, !noalias !2
        store ptr @eraser_200, ptr %eraser_pointer_316, !noalias !2
        
        %closure_333 = call ccc %Object @newObject(ptr @eraser_336, i64 8)
        %environment_334 = call ccc %Environment @objectEnvironment(%Object %closure_333)
        %p_6_18_45_209_4568_pointer_338 = getelementptr <{%Prompt}>, %Environment %environment_334, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4568, ptr %p_6_18_45_209_4568_pointer_338, !noalias !2
        %vtable_temporary_339 = insertvalue %Neg zeroinitializer, ptr @vtable_332, 0
        %Exception_7_19_46_210_4451 = insertvalue %Neg %vtable_temporary_339, %Object %closure_333, 1
        %stackPointer_351 = call ccc %StackPointer @stackAllocate(%Stack %stack_307, i64 24)
        %returnAddress_pointer_352 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_351, i64 0, i32 1, i32 0
        %sharer_pointer_353 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_351, i64 0, i32 1, i32 1
        %eraser_pointer_354 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_351, i64 0, i32 1, i32 2
        store ptr @returnAddress_340, ptr %returnAddress_pointer_352, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_353, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_354, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2585_30_194_4624, i64 %index_7_34_198_4532, %Neg %Exception_7_19_46_210_4451, %Stack %stack_307)
        ret void
}



define tailcc void @Exception_9_106_133_297_4500_clause_355(%Object %closure, %Pos %exception_10_107_134_298_4915, %Pos %msg_11_108_135_299_4916, %Stack %stack) {
        
    entry:
        
        %environment_356 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4318_pointer_357 = getelementptr <{%Prompt}>, %Environment %environment_356, i64 0, i32 0
        %p_8_9_4318 = load %Prompt, ptr %p_8_9_4318_pointer_357, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4915)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4916)
        
        %pair_358 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4318)
        %k_13_14_4_4774 = extractvalue <{%Resumption, %Stack}> %pair_358, 0
        %stack_359 = extractvalue <{%Resumption, %Stack}> %pair_358, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4774)
        
        %longLiteral_4917 = add i64 10, 0
        
        
        
        %pureApp_4918 = call ccc %Pos @boxInt_301(i64 %longLiteral_4917)
        
        
        
        %stackPointer_361 = call ccc %StackPointer @stackDeallocate(%Stack %stack_359, i64 24)
        %returnAddress_pointer_362 = getelementptr %FrameHeader, %StackPointer %stackPointer_361, i64 0, i32 0
        %returnAddress_360 = load %ReturnAddress, ptr %returnAddress_pointer_362, !noalias !2
        musttail call tailcc void %returnAddress_360(%Pos %pureApp_4918, %Stack %stack_359)
        ret void
}


@vtable_363 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4500_clause_355]


define tailcc void @returnAddress_374(i64 %v_coe_3493_22_131_158_322_4517, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4921 = call ccc %Pos @boxInt_301(i64 %v_coe_3493_22_131_158_322_4517)
        
        
        
        
        
        %pureApp_4922 = call ccc i64 @unboxInt_303(%Pos %pureApp_4921)
        
        
        
        %pureApp_4923 = call ccc %Pos @boxInt_301(i64 %pureApp_4922)
        
        
        
        %stackPointer_376 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_377 = getelementptr %FrameHeader, %StackPointer %stackPointer_376, i64 0, i32 0
        %returnAddress_375 = load %ReturnAddress, ptr %returnAddress_pointer_377, !noalias !2
        musttail call tailcc void %returnAddress_375(%Pos %pureApp_4923, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_386(i64 %v_r_2685_1_9_20_129_156_320_4630, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4927 = add i64 0, 0
        
        %pureApp_4926 = call ccc i64 @infixSub_105(i64 %longLiteral_4927, i64 %v_r_2685_1_9_20_129_156_320_4630)
        
        
        
        %stackPointer_388 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_389 = getelementptr %FrameHeader, %StackPointer %stackPointer_388, i64 0, i32 0
        %returnAddress_387 = load %ReturnAddress, ptr %returnAddress_pointer_389, !noalias !2
        musttail call tailcc void %returnAddress_387(i64 %pureApp_4926, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_369(i64 %v_r_2684_3_14_123_150_314_4395, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_370 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_4318_pointer_371 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_370, i64 0, i32 0
        %p_8_9_4318 = load %Prompt, ptr %p_8_9_4318_pointer_371, !noalias !2
        %v_r_2585_30_194_4624_pointer_372 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_370, i64 0, i32 1
        %v_r_2585_30_194_4624 = load %Pos, ptr %v_r_2585_30_194_4624_pointer_372, !noalias !2
        %tmp_4795_pointer_373 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_370, i64 0, i32 2
        %tmp_4795 = load i64, ptr %tmp_4795_pointer_373, !noalias !2
        
        %intLiteral_4920 = add i64 45, 0
        
        %pureApp_4919 = call ccc %Pos @infixEq_78(i64 %v_r_2684_3_14_123_150_314_4395, i64 %intLiteral_4920)
        
        
        %stackPointer_378 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_379 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_378, i64 0, i32 1, i32 0
        %sharer_pointer_380 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_378, i64 0, i32 1, i32 1
        %eraser_pointer_381 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_378, i64 0, i32 1, i32 2
        store ptr @returnAddress_374, ptr %returnAddress_pointer_379, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_380, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_381, !noalias !2
        
        %tag_382 = extractvalue %Pos %pureApp_4919, 0
        %fields_383 = extractvalue %Pos %pureApp_4919, 1
        switch i64 %tag_382, label %label_384 [i64 0, label %label_385 i64 1, label %label_394]
    
    label_384:
        
        ret void
    
    label_385:
        
        %longLiteral_4924 = add i64 0, 0
        
        %longLiteral_4925 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4620(i64 %longLiteral_4924, i64 %longLiteral_4925, %Prompt %p_8_9_4318, %Pos %v_r_2585_30_194_4624, i64 %tmp_4795, %Stack %stack)
        ret void
    
    label_394:
        %stackPointer_390 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_391 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 0
        %sharer_pointer_392 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 1
        %eraser_pointer_393 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 2
        store ptr @returnAddress_386, ptr %returnAddress_pointer_391, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_392, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_393, !noalias !2
        
        %longLiteral_4928 = add i64 1, 0
        
        %longLiteral_4929 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4620(i64 %longLiteral_4928, i64 %longLiteral_4929, %Prompt %p_8_9_4318, %Pos %v_r_2585_30_194_4624, i64 %tmp_4795, %Stack %stack)
        ret void
}



define ccc void @sharer_398(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_399 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4318_395_pointer_400 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_399, i64 0, i32 0
        %p_8_9_4318_395 = load %Prompt, ptr %p_8_9_4318_395_pointer_400, !noalias !2
        %v_r_2585_30_194_4624_396_pointer_401 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_399, i64 0, i32 1
        %v_r_2585_30_194_4624_396 = load %Pos, ptr %v_r_2585_30_194_4624_396_pointer_401, !noalias !2
        %tmp_4795_397_pointer_402 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_399, i64 0, i32 2
        %tmp_4795_397 = load i64, ptr %tmp_4795_397_pointer_402, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2585_30_194_4624_396)
        call ccc void @shareFrames(%StackPointer %stackPointer_399)
        ret void
}



define ccc void @eraser_406(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_407 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4318_403_pointer_408 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_407, i64 0, i32 0
        %p_8_9_4318_403 = load %Prompt, ptr %p_8_9_4318_403_pointer_408, !noalias !2
        %v_r_2585_30_194_4624_404_pointer_409 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_407, i64 0, i32 1
        %v_r_2585_30_194_4624_404 = load %Pos, ptr %v_r_2585_30_194_4624_404_pointer_409, !noalias !2
        %tmp_4795_405_pointer_410 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_407, i64 0, i32 2
        %tmp_4795_405 = load i64, ptr %tmp_4795_405_pointer_410, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4624_404)
        call ccc void @eraseFrames(%StackPointer %stackPointer_407)
        ret void
}



define tailcc void @returnAddress_231(%Pos %v_r_2585_30_194_4624, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_232 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4318_pointer_233 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_232, i64 0, i32 0
        %p_8_9_4318 = load %Prompt, ptr %p_8_9_4318_pointer_233, !noalias !2
        
        %intLiteral_4892 = add i64 48, 0
        
        %pureApp_4891 = call ccc i64 @toInt_2085(i64 %intLiteral_4892)
        
        
        
        %closure_364 = call ccc %Object @newObject(ptr @eraser_336, i64 8)
        %environment_365 = call ccc %Environment @objectEnvironment(%Object %closure_364)
        %p_8_9_4318_pointer_367 = getelementptr <{%Prompt}>, %Environment %environment_365, i64 0, i32 0
        store %Prompt %p_8_9_4318, ptr %p_8_9_4318_pointer_367, !noalias !2
        %vtable_temporary_368 = insertvalue %Neg zeroinitializer, ptr @vtable_363, 0
        %Exception_9_106_133_297_4500 = insertvalue %Neg %vtable_temporary_368, %Object %closure_364, 1
        call ccc void @sharePositive(%Pos %v_r_2585_30_194_4624)
        %stackPointer_411 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_4318_pointer_412 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_411, i64 0, i32 0
        store %Prompt %p_8_9_4318, ptr %p_8_9_4318_pointer_412, !noalias !2
        %v_r_2585_30_194_4624_pointer_413 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_411, i64 0, i32 1
        store %Pos %v_r_2585_30_194_4624, ptr %v_r_2585_30_194_4624_pointer_413, !noalias !2
        %tmp_4795_pointer_414 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_411, i64 0, i32 2
        store i64 %pureApp_4891, ptr %tmp_4795_pointer_414, !noalias !2
        %returnAddress_pointer_415 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_411, i64 0, i32 1, i32 0
        %sharer_pointer_416 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_411, i64 0, i32 1, i32 1
        %eraser_pointer_417 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_411, i64 0, i32 1, i32 2
        store ptr @returnAddress_369, ptr %returnAddress_pointer_415, !noalias !2
        store ptr @sharer_398, ptr %sharer_pointer_416, !noalias !2
        store ptr @eraser_406, ptr %eraser_pointer_417, !noalias !2
        
        %longLiteral_4930 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2585_30_194_4624, i64 %longLiteral_4930, %Neg %Exception_9_106_133_297_4500, %Stack %stack)
        ret void
}



define ccc void @sharer_419(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_420 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4318_418_pointer_421 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_420, i64 0, i32 0
        %p_8_9_4318_418 = load %Prompt, ptr %p_8_9_4318_418_pointer_421, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_420)
        ret void
}



define ccc void @eraser_423(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_424 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4318_422_pointer_425 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_424, i64 0, i32 0
        %p_8_9_4318_422 = load %Prompt, ptr %p_8_9_4318_422_pointer_425, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_424)
        ret void
}


@utf8StringLiteral_4931.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_228(%Pos %v_r_2584_24_188_4519, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_229 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4318_pointer_230 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_229, i64 0, i32 0
        %p_8_9_4318 = load %Prompt, ptr %p_8_9_4318_pointer_230, !noalias !2
        %stackPointer_426 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4318_pointer_427 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_426, i64 0, i32 0
        store %Prompt %p_8_9_4318, ptr %p_8_9_4318_pointer_427, !noalias !2
        %returnAddress_pointer_428 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 0
        %sharer_pointer_429 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 1
        %eraser_pointer_430 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 2
        store ptr @returnAddress_231, ptr %returnAddress_pointer_428, !noalias !2
        store ptr @sharer_419, ptr %sharer_pointer_429, !noalias !2
        store ptr @eraser_423, ptr %eraser_pointer_430, !noalias !2
        
        %tag_431 = extractvalue %Pos %v_r_2584_24_188_4519, 0
        %fields_432 = extractvalue %Pos %v_r_2584_24_188_4519, 1
        switch i64 %tag_431, label %label_433 [i64 0, label %label_437 i64 1, label %label_443]
    
    label_433:
        
        ret void
    
    label_437:
        
        %utf8StringLiteral_4931 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4931.lit)
        
        %stackPointer_435 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_436 = getelementptr %FrameHeader, %StackPointer %stackPointer_435, i64 0, i32 0
        %returnAddress_434 = load %ReturnAddress, ptr %returnAddress_pointer_436, !noalias !2
        musttail call tailcc void %returnAddress_434(%Pos %utf8StringLiteral_4931, %Stack %stack)
        ret void
    
    label_443:
        %environment_438 = call ccc %Environment @objectEnvironment(%Object %fields_432)
        %v_y_3315_8_29_193_4558_pointer_439 = getelementptr <{%Pos}>, %Environment %environment_438, i64 0, i32 0
        %v_y_3315_8_29_193_4558 = load %Pos, ptr %v_y_3315_8_29_193_4558_pointer_439, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3315_8_29_193_4558)
        call ccc void @eraseObject(%Object %fields_432)
        
        %stackPointer_441 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_442 = getelementptr %FrameHeader, %StackPointer %stackPointer_441, i64 0, i32 0
        %returnAddress_440 = load %ReturnAddress, ptr %returnAddress_pointer_442, !noalias !2
        musttail call tailcc void %returnAddress_440(%Pos %v_y_3315_8_29_193_4558, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_225(%Pos %v_r_2583_13_177_4521, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_226 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4318_pointer_227 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_226, i64 0, i32 0
        %p_8_9_4318 = load %Prompt, ptr %p_8_9_4318_pointer_227, !noalias !2
        %stackPointer_446 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4318_pointer_447 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_446, i64 0, i32 0
        store %Prompt %p_8_9_4318, ptr %p_8_9_4318_pointer_447, !noalias !2
        %returnAddress_pointer_448 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_446, i64 0, i32 1, i32 0
        %sharer_pointer_449 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_446, i64 0, i32 1, i32 1
        %eraser_pointer_450 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_446, i64 0, i32 1, i32 2
        store ptr @returnAddress_228, ptr %returnAddress_pointer_448, !noalias !2
        store ptr @sharer_419, ptr %sharer_pointer_449, !noalias !2
        store ptr @eraser_423, ptr %eraser_pointer_450, !noalias !2
        
        %tag_451 = extractvalue %Pos %v_r_2583_13_177_4521, 0
        %fields_452 = extractvalue %Pos %v_r_2583_13_177_4521, 1
        switch i64 %tag_451, label %label_453 [i64 0, label %label_458 i64 1, label %label_470]
    
    label_453:
        
        ret void
    
    label_458:
        
        %make_4932_temporary_454 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4932 = insertvalue %Pos %make_4932_temporary_454, %Object null, 1
        
        
        
        %stackPointer_456 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_457 = getelementptr %FrameHeader, %StackPointer %stackPointer_456, i64 0, i32 0
        %returnAddress_455 = load %ReturnAddress, ptr %returnAddress_pointer_457, !noalias !2
        musttail call tailcc void %returnAddress_455(%Pos %make_4932, %Stack %stack)
        ret void
    
    label_470:
        %environment_459 = call ccc %Environment @objectEnvironment(%Object %fields_452)
        %v_y_2824_10_21_185_4352_pointer_460 = getelementptr <{%Pos, %Pos}>, %Environment %environment_459, i64 0, i32 0
        %v_y_2824_10_21_185_4352 = load %Pos, ptr %v_y_2824_10_21_185_4352_pointer_460, !noalias !2
        %v_y_2825_11_22_186_4417_pointer_461 = getelementptr <{%Pos, %Pos}>, %Environment %environment_459, i64 0, i32 1
        %v_y_2825_11_22_186_4417 = load %Pos, ptr %v_y_2825_11_22_186_4417_pointer_461, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2824_10_21_185_4352)
        call ccc void @eraseObject(%Object %fields_452)
        
        %fields_462 = call ccc %Object @newObject(ptr @eraser_344, i64 16)
        %environment_463 = call ccc %Environment @objectEnvironment(%Object %fields_462)
        %v_y_2824_10_21_185_4352_pointer_465 = getelementptr <{%Pos}>, %Environment %environment_463, i64 0, i32 0
        store %Pos %v_y_2824_10_21_185_4352, ptr %v_y_2824_10_21_185_4352_pointer_465, !noalias !2
        %make_4933_temporary_466 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4933 = insertvalue %Pos %make_4933_temporary_466, %Object %fields_462, 1
        
        
        
        %stackPointer_468 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_469 = getelementptr %FrameHeader, %StackPointer %stackPointer_468, i64 0, i32 0
        %returnAddress_467 = load %ReturnAddress, ptr %returnAddress_pointer_469, !noalias !2
        musttail call tailcc void %returnAddress_467(%Pos %make_4933, %Stack %stack)
        ret void
}



define tailcc void @main_2445(%Stack %stack) {
        
    entry:
        
        %stackPointer_188 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_189 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_188, i64 0, i32 1, i32 0
        %sharer_pointer_190 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_188, i64 0, i32 1, i32 1
        %eraser_pointer_191 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_188, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_189, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_190, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_191, !noalias !2
        
        %stack_192 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4318 = call ccc %Prompt @currentPrompt(%Stack %stack_192)
        %stackPointer_202 = call ccc %StackPointer @stackAllocate(%Stack %stack_192, i64 24)
        %returnAddress_pointer_203 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_202, i64 0, i32 1, i32 0
        %sharer_pointer_204 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_202, i64 0, i32 1, i32 1
        %eraser_pointer_205 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_202, i64 0, i32 1, i32 2
        store ptr @returnAddress_193, ptr %returnAddress_pointer_203, !noalias !2
        store ptr @sharer_198, ptr %sharer_pointer_204, !noalias !2
        store ptr @eraser_200, ptr %eraser_pointer_205, !noalias !2
        
        %pureApp_4887 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4889 = add i64 1, 0
        
        %pureApp_4888 = call ccc i64 @infixSub_105(i64 %pureApp_4887, i64 %longLiteral_4889)
        
        
        
        %make_4890_temporary_224 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4890 = insertvalue %Pos %make_4890_temporary_224, %Object null, 1
        
        
        %stackPointer_473 = call ccc %StackPointer @stackAllocate(%Stack %stack_192, i64 32)
        %p_8_9_4318_pointer_474 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_473, i64 0, i32 0
        store %Prompt %p_8_9_4318, ptr %p_8_9_4318_pointer_474, !noalias !2
        %returnAddress_pointer_475 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_473, i64 0, i32 1, i32 0
        %sharer_pointer_476 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_473, i64 0, i32 1, i32 1
        %eraser_pointer_477 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_473, i64 0, i32 1, i32 2
        store ptr @returnAddress_225, ptr %returnAddress_pointer_475, !noalias !2
        store ptr @sharer_419, ptr %sharer_pointer_476, !noalias !2
        store ptr @eraser_423, ptr %eraser_pointer_477, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4614(i64 %pureApp_4888, %Pos %make_4890, %Stack %stack_192)
        ret void
}


@utf8StringLiteral_4862.lit = private constant [6 x i8] c"\6f\68\20\6e\6f\21"

@utf8StringLiteral_4860.lit = private constant [6 x i8] c"\6f\68\20\6e\6f\21"

@utf8StringLiteral_4858.lit = private constant [6 x i8] c"\6f\68\20\6e\6f\21"


define tailcc void @returnAddress_530(%Pos %v_r_2552_6_5_14_33_3970, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_531 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_2550_4_3_12_31_3960_pointer_532 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_531, i64 0, i32 0
        %v_r_2550_4_3_12_31_3960 = load %Pos, ptr %v_r_2550_4_3_12_31_3960_pointer_532, !noalias !2
        %v_r_2551_5_4_13_32_3976_pointer_533 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_531, i64 0, i32 1
        %v_r_2551_5_4_13_32_3976 = load %Pos, ptr %v_r_2551_5_4_13_32_3976_pointer_533, !noalias !2
        
        
        
        
        
        musttail call tailcc void @tail_2442(%Pos %v_r_2550_4_3_12_31_3960, %Pos %v_r_2551_5_4_13_32_3976, %Pos %v_r_2552_6_5_14_33_3970, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_524(%Pos %v_r_2551_5_4_13_32_3976, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_525 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %ys_2440_pointer_526 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_525, i64 0, i32 0
        %ys_2440 = load %Pos, ptr %ys_2440_pointer_526, !noalias !2
        %v_r_2550_4_3_12_31_3960_pointer_527 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_525, i64 0, i32 1
        %v_r_2550_4_3_12_31_3960 = load %Pos, ptr %v_r_2550_4_3_12_31_3960_pointer_527, !noalias !2
        %xs_2439_pointer_528 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_525, i64 0, i32 2
        %xs_2439 = load %Pos, ptr %xs_2439_pointer_528, !noalias !2
        %v_coe_3518_15_4_23_3971_pointer_529 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_525, i64 0, i32 3
        %v_coe_3518_15_4_23_3971 = load %Pos, ptr %v_coe_3518_15_4_23_3971_pointer_529, !noalias !2
        %stackPointer_538 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_2550_4_3_12_31_3960_pointer_539 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_538, i64 0, i32 0
        store %Pos %v_r_2550_4_3_12_31_3960, ptr %v_r_2550_4_3_12_31_3960_pointer_539, !noalias !2
        %v_r_2551_5_4_13_32_3976_pointer_540 = getelementptr <{%Pos, %Pos}>, %StackPointer %stackPointer_538, i64 0, i32 1
        store %Pos %v_r_2551_5_4_13_32_3976, ptr %v_r_2551_5_4_13_32_3976_pointer_540, !noalias !2
        %returnAddress_pointer_541 = getelementptr <{<{%Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_538, i64 0, i32 1, i32 0
        %sharer_pointer_542 = getelementptr <{<{%Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_538, i64 0, i32 1, i32 1
        %eraser_pointer_543 = getelementptr <{<{%Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_538, i64 0, i32 1, i32 2
        store ptr @returnAddress_530, ptr %returnAddress_pointer_541, !noalias !2
        store ptr @sharer_151, ptr %sharer_pointer_542, !noalias !2
        store ptr @eraser_157, ptr %eraser_pointer_543, !noalias !2
        
        
        
        
        
        musttail call tailcc void @tail_2442(%Pos %v_coe_3518_15_4_23_3971, %Pos %xs_2439, %Pos %ys_2440, %Stack %stack)
        ret void
}



define ccc void @sharer_548(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_549 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %ys_2440_544_pointer_550 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_549, i64 0, i32 0
        %ys_2440_544 = load %Pos, ptr %ys_2440_544_pointer_550, !noalias !2
        %v_r_2550_4_3_12_31_3960_545_pointer_551 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_549, i64 0, i32 1
        %v_r_2550_4_3_12_31_3960_545 = load %Pos, ptr %v_r_2550_4_3_12_31_3960_545_pointer_551, !noalias !2
        %xs_2439_546_pointer_552 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_549, i64 0, i32 2
        %xs_2439_546 = load %Pos, ptr %xs_2439_546_pointer_552, !noalias !2
        %v_coe_3518_15_4_23_3971_547_pointer_553 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_549, i64 0, i32 3
        %v_coe_3518_15_4_23_3971_547 = load %Pos, ptr %v_coe_3518_15_4_23_3971_547_pointer_553, !noalias !2
        call ccc void @sharePositive(%Pos %ys_2440_544)
        call ccc void @sharePositive(%Pos %v_r_2550_4_3_12_31_3960_545)
        call ccc void @sharePositive(%Pos %xs_2439_546)
        call ccc void @sharePositive(%Pos %v_coe_3518_15_4_23_3971_547)
        call ccc void @shareFrames(%StackPointer %stackPointer_549)
        ret void
}



define ccc void @eraser_558(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_559 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %ys_2440_554_pointer_560 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_559, i64 0, i32 0
        %ys_2440_554 = load %Pos, ptr %ys_2440_554_pointer_560, !noalias !2
        %v_r_2550_4_3_12_31_3960_555_pointer_561 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_559, i64 0, i32 1
        %v_r_2550_4_3_12_31_3960_555 = load %Pos, ptr %v_r_2550_4_3_12_31_3960_555_pointer_561, !noalias !2
        %xs_2439_556_pointer_562 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_559, i64 0, i32 2
        %xs_2439_556 = load %Pos, ptr %xs_2439_556_pointer_562, !noalias !2
        %v_coe_3518_15_4_23_3971_557_pointer_563 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_559, i64 0, i32 3
        %v_coe_3518_15_4_23_3971_557 = load %Pos, ptr %v_coe_3518_15_4_23_3971_557_pointer_563, !noalias !2
        call ccc void @erasePositive(%Pos %ys_2440_554)
        call ccc void @erasePositive(%Pos %v_r_2550_4_3_12_31_3960_555)
        call ccc void @erasePositive(%Pos %xs_2439_556)
        call ccc void @erasePositive(%Pos %v_coe_3518_15_4_23_3971_557)
        call ccc void @eraseFrames(%StackPointer %stackPointer_559)
        ret void
}



define tailcc void @returnAddress_517(%Pos %v_r_2550_4_3_12_31_3960, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_518 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 80)
        %zs_2441_pointer_519 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_518, i64 0, i32 0
        %zs_2441 = load %Pos, ptr %zs_2441_pointer_519, !noalias !2
        %ys_2440_pointer_520 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_518, i64 0, i32 1
        %ys_2440 = load %Pos, ptr %ys_2440_pointer_520, !noalias !2
        %xs_2439_pointer_521 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_518, i64 0, i32 2
        %xs_2439 = load %Pos, ptr %xs_2439_pointer_521, !noalias !2
        %v_coe_3521_10_4_3968_pointer_522 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_518, i64 0, i32 3
        %v_coe_3521_10_4_3968 = load %Pos, ptr %v_coe_3521_10_4_3968_pointer_522, !noalias !2
        %v_coe_3518_15_4_23_3971_pointer_523 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_518, i64 0, i32 4
        %v_coe_3518_15_4_23_3971 = load %Pos, ptr %v_coe_3518_15_4_23_3971_pointer_523, !noalias !2
        call ccc void @sharePositive(%Pos %xs_2439)
        %stackPointer_564 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %ys_2440_pointer_565 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_564, i64 0, i32 0
        store %Pos %ys_2440, ptr %ys_2440_pointer_565, !noalias !2
        %v_r_2550_4_3_12_31_3960_pointer_566 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_564, i64 0, i32 1
        store %Pos %v_r_2550_4_3_12_31_3960, ptr %v_r_2550_4_3_12_31_3960_pointer_566, !noalias !2
        %xs_2439_pointer_567 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_564, i64 0, i32 2
        store %Pos %xs_2439, ptr %xs_2439_pointer_567, !noalias !2
        %v_coe_3518_15_4_23_3971_pointer_568 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_564, i64 0, i32 3
        store %Pos %v_coe_3518_15_4_23_3971, ptr %v_coe_3518_15_4_23_3971_pointer_568, !noalias !2
        %returnAddress_pointer_569 = getelementptr <{<{%Pos, %Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_564, i64 0, i32 1, i32 0
        %sharer_pointer_570 = getelementptr <{<{%Pos, %Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_564, i64 0, i32 1, i32 1
        %eraser_pointer_571 = getelementptr <{<{%Pos, %Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_564, i64 0, i32 1, i32 2
        store ptr @returnAddress_524, ptr %returnAddress_pointer_569, !noalias !2
        store ptr @sharer_548, ptr %sharer_pointer_570, !noalias !2
        store ptr @eraser_558, ptr %eraser_pointer_571, !noalias !2
        
        
        
        
        
        musttail call tailcc void @tail_2442(%Pos %v_coe_3521_10_4_3968, %Pos %zs_2441, %Pos %xs_2439, %Stack %stack)
        ret void
}



define ccc void @sharer_577(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_578 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %zs_2441_572_pointer_579 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_578, i64 0, i32 0
        %zs_2441_572 = load %Pos, ptr %zs_2441_572_pointer_579, !noalias !2
        %ys_2440_573_pointer_580 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_578, i64 0, i32 1
        %ys_2440_573 = load %Pos, ptr %ys_2440_573_pointer_580, !noalias !2
        %xs_2439_574_pointer_581 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_578, i64 0, i32 2
        %xs_2439_574 = load %Pos, ptr %xs_2439_574_pointer_581, !noalias !2
        %v_coe_3521_10_4_3968_575_pointer_582 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_578, i64 0, i32 3
        %v_coe_3521_10_4_3968_575 = load %Pos, ptr %v_coe_3521_10_4_3968_575_pointer_582, !noalias !2
        %v_coe_3518_15_4_23_3971_576_pointer_583 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_578, i64 0, i32 4
        %v_coe_3518_15_4_23_3971_576 = load %Pos, ptr %v_coe_3518_15_4_23_3971_576_pointer_583, !noalias !2
        call ccc void @sharePositive(%Pos %zs_2441_572)
        call ccc void @sharePositive(%Pos %ys_2440_573)
        call ccc void @sharePositive(%Pos %xs_2439_574)
        call ccc void @sharePositive(%Pos %v_coe_3521_10_4_3968_575)
        call ccc void @sharePositive(%Pos %v_coe_3518_15_4_23_3971_576)
        call ccc void @shareFrames(%StackPointer %stackPointer_578)
        ret void
}



define ccc void @eraser_589(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_590 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %zs_2441_584_pointer_591 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_590, i64 0, i32 0
        %zs_2441_584 = load %Pos, ptr %zs_2441_584_pointer_591, !noalias !2
        %ys_2440_585_pointer_592 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_590, i64 0, i32 1
        %ys_2440_585 = load %Pos, ptr %ys_2440_585_pointer_592, !noalias !2
        %xs_2439_586_pointer_593 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_590, i64 0, i32 2
        %xs_2439_586 = load %Pos, ptr %xs_2439_586_pointer_593, !noalias !2
        %v_coe_3521_10_4_3968_587_pointer_594 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_590, i64 0, i32 3
        %v_coe_3521_10_4_3968_587 = load %Pos, ptr %v_coe_3521_10_4_3968_587_pointer_594, !noalias !2
        %v_coe_3518_15_4_23_3971_588_pointer_595 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_590, i64 0, i32 4
        %v_coe_3518_15_4_23_3971_588 = load %Pos, ptr %v_coe_3518_15_4_23_3971_588_pointer_595, !noalias !2
        call ccc void @erasePositive(%Pos %zs_2441_584)
        call ccc void @erasePositive(%Pos %ys_2440_585)
        call ccc void @erasePositive(%Pos %xs_2439_586)
        call ccc void @erasePositive(%Pos %v_coe_3521_10_4_3968_587)
        call ccc void @erasePositive(%Pos %v_coe_3518_15_4_23_3971_588)
        call ccc void @eraseFrames(%StackPointer %stackPointer_590)
        ret void
}



define tailcc void @returnAddress_478(%Pos %v_r_2548_3616, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_479 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %zs_2441_pointer_480 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_479, i64 0, i32 0
        %zs_2441 = load %Pos, ptr %zs_2441_pointer_480, !noalias !2
        %xs_2439_pointer_481 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_479, i64 0, i32 1
        %xs_2439 = load %Pos, ptr %xs_2439_pointer_481, !noalias !2
        %ys_2440_pointer_482 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_479, i64 0, i32 2
        %ys_2440 = load %Pos, ptr %ys_2440_pointer_482, !noalias !2
        
        %tag_483 = extractvalue %Pos %v_r_2548_3616, 0
        %fields_484 = extractvalue %Pos %v_r_2548_3616, 1
        switch i64 %tag_483, label %label_485 [i64 0, label %label_489 i64 1, label %label_608]
    
    label_485:
        
        ret void
    
    label_489:
        call ccc void @erasePositive(%Pos %xs_2439)
        call ccc void @erasePositive(%Pos %ys_2440)
        
        %stackPointer_487 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_488 = getelementptr %FrameHeader, %StackPointer %stackPointer_487, i64 0, i32 0
        %returnAddress_486 = load %ReturnAddress, ptr %returnAddress_pointer_488, !noalias !2
        musttail call tailcc void %returnAddress_486(%Pos %zs_2441, %Stack %stack)
        ret void
    
    label_495:
        call ccc void @erasePositive(%Pos %ys_2440)
        call ccc void @erasePositive(%Pos %zs_2441)
        call ccc void @erasePositive(%Pos %xs_2439)
        call ccc void @erasePositive(%Pos %xs_2439)
        
        %utf8StringLiteral_4862 = call ccc %Pos @c_bytearray_construct(i64 6, ptr @utf8StringLiteral_4862.lit)
        
        %pureApp_4861 = call ccc %Pos @panic_552(%Pos %utf8StringLiteral_4862)
        
        
        
        %stackPointer_493 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_494 = getelementptr %FrameHeader, %StackPointer %stackPointer_493, i64 0, i32 0
        %returnAddress_492 = load %ReturnAddress, ptr %returnAddress_pointer_494, !noalias !2
        musttail call tailcc void %returnAddress_492(%Pos %pureApp_4861, %Stack %stack)
        ret void
    
    label_504:
        call ccc void @erasePositive(%Pos %zs_2441)
        call ccc void @erasePositive(%Pos %v_coe_3524_5_3909)
        call ccc void @erasePositive(%Pos %ys_2440)
        call ccc void @erasePositive(%Pos %xs_2439)
        call ccc void @erasePositive(%Pos %ys_2440)
        
        %utf8StringLiteral_4860 = call ccc %Pos @c_bytearray_construct(i64 6, ptr @utf8StringLiteral_4860.lit)
        
        %pureApp_4859 = call ccc %Pos @panic_552(%Pos %utf8StringLiteral_4860)
        
        
        
        %stackPointer_502 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_503 = getelementptr %FrameHeader, %StackPointer %stackPointer_502, i64 0, i32 0
        %returnAddress_501 = load %ReturnAddress, ptr %returnAddress_pointer_503, !noalias !2
        musttail call tailcc void %returnAddress_501(%Pos %pureApp_4859, %Stack %stack)
        ret void
    
    label_513:
        call ccc void @erasePositive(%Pos %zs_2441)
        call ccc void @erasePositive(%Pos %v_coe_3524_5_3909)
        call ccc void @erasePositive(%Pos %ys_2440)
        call ccc void @erasePositive(%Pos %xs_2439)
        call ccc void @erasePositive(%Pos %v_coe_3521_10_4_3968)
        call ccc void @erasePositive(%Pos %zs_2441)
        
        %utf8StringLiteral_4858 = call ccc %Pos @c_bytearray_construct(i64 6, ptr @utf8StringLiteral_4858.lit)
        
        %pureApp_4857 = call ccc %Pos @panic_552(%Pos %utf8StringLiteral_4858)
        
        
        
        %stackPointer_511 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_512 = getelementptr %FrameHeader, %StackPointer %stackPointer_511, i64 0, i32 0
        %returnAddress_510 = load %ReturnAddress, ptr %returnAddress_pointer_512, !noalias !2
        musttail call tailcc void %returnAddress_510(%Pos %pureApp_4857, %Stack %stack)
        ret void
    
    label_605:
        %environment_514 = call ccc %Environment @objectEnvironment(%Object %fields_509)
        %v_coe_3517_14_3_22_3978_pointer_515 = getelementptr <{%Pos, %Pos}>, %Environment %environment_514, i64 0, i32 0
        %v_coe_3517_14_3_22_3978 = load %Pos, ptr %v_coe_3517_14_3_22_3978_pointer_515, !noalias !2
        %v_coe_3518_15_4_23_3971_pointer_516 = getelementptr <{%Pos, %Pos}>, %Environment %environment_514, i64 0, i32 1
        %v_coe_3518_15_4_23_3971 = load %Pos, ptr %v_coe_3518_15_4_23_3971_pointer_516, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3518_15_4_23_3971)
        call ccc void @eraseObject(%Object %fields_509)
        call ccc void @sharePositive(%Pos %zs_2441)
        call ccc void @sharePositive(%Pos %ys_2440)
        %stackPointer_596 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 104)
        %zs_2441_pointer_597 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 0
        store %Pos %zs_2441, ptr %zs_2441_pointer_597, !noalias !2
        %ys_2440_pointer_598 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 1
        store %Pos %ys_2440, ptr %ys_2440_pointer_598, !noalias !2
        %xs_2439_pointer_599 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 2
        store %Pos %xs_2439, ptr %xs_2439_pointer_599, !noalias !2
        %v_coe_3521_10_4_3968_pointer_600 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 3
        store %Pos %v_coe_3521_10_4_3968, ptr %v_coe_3521_10_4_3968_pointer_600, !noalias !2
        %v_coe_3518_15_4_23_3971_pointer_601 = getelementptr <{%Pos, %Pos, %Pos, %Pos, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 4
        store %Pos %v_coe_3518_15_4_23_3971, ptr %v_coe_3518_15_4_23_3971_pointer_601, !noalias !2
        %returnAddress_pointer_602 = getelementptr <{<{%Pos, %Pos, %Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_596, i64 0, i32 1, i32 0
        %sharer_pointer_603 = getelementptr <{<{%Pos, %Pos, %Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_596, i64 0, i32 1, i32 1
        %eraser_pointer_604 = getelementptr <{<{%Pos, %Pos, %Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_596, i64 0, i32 1, i32 2
        store ptr @returnAddress_517, ptr %returnAddress_pointer_602, !noalias !2
        store ptr @sharer_577, ptr %sharer_pointer_603, !noalias !2
        store ptr @eraser_589, ptr %eraser_pointer_604, !noalias !2
        
        
        
        
        
        musttail call tailcc void @tail_2442(%Pos %v_coe_3524_5_3909, %Pos %ys_2440, %Pos %zs_2441, %Stack %stack)
        ret void
    
    label_606:
        %environment_505 = call ccc %Environment @objectEnvironment(%Object %fields_500)
        %v_coe_3520_9_3_3966_pointer_506 = getelementptr <{%Pos, %Pos}>, %Environment %environment_505, i64 0, i32 0
        %v_coe_3520_9_3_3966 = load %Pos, ptr %v_coe_3520_9_3_3966_pointer_506, !noalias !2
        %v_coe_3521_10_4_3968_pointer_507 = getelementptr <{%Pos, %Pos}>, %Environment %environment_505, i64 0, i32 1
        %v_coe_3521_10_4_3968 = load %Pos, ptr %v_coe_3521_10_4_3968_pointer_507, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3521_10_4_3968)
        call ccc void @eraseObject(%Object %fields_500)
        
        call ccc void @sharePositive(%Pos %zs_2441)
        %tag_508 = extractvalue %Pos %zs_2441, 0
        %fields_509 = extractvalue %Pos %zs_2441, 1
        switch i64 %tag_508, label %label_513 [i64 1, label %label_605]
    
    label_607:
        %environment_496 = call ccc %Environment @objectEnvironment(%Object %fields_491)
        %v_coe_3523_4_3905_pointer_497 = getelementptr <{%Pos, %Pos}>, %Environment %environment_496, i64 0, i32 0
        %v_coe_3523_4_3905 = load %Pos, ptr %v_coe_3523_4_3905_pointer_497, !noalias !2
        %v_coe_3524_5_3909_pointer_498 = getelementptr <{%Pos, %Pos}>, %Environment %environment_496, i64 0, i32 1
        %v_coe_3524_5_3909 = load %Pos, ptr %v_coe_3524_5_3909_pointer_498, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3524_5_3909)
        call ccc void @eraseObject(%Object %fields_491)
        
        call ccc void @sharePositive(%Pos %ys_2440)
        %tag_499 = extractvalue %Pos %ys_2440, 0
        %fields_500 = extractvalue %Pos %ys_2440, 1
        switch i64 %tag_499, label %label_504 [i64 1, label %label_606]
    
    label_608:
        
        call ccc void @sharePositive(%Pos %xs_2439)
        %tag_490 = extractvalue %Pos %xs_2439, 0
        %fields_491 = extractvalue %Pos %xs_2439, 1
        switch i64 %tag_490, label %label_495 [i64 1, label %label_607]
}



define ccc void @sharer_612(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_613 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %zs_2441_609_pointer_614 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_613, i64 0, i32 0
        %zs_2441_609 = load %Pos, ptr %zs_2441_609_pointer_614, !noalias !2
        %xs_2439_610_pointer_615 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_613, i64 0, i32 1
        %xs_2439_610 = load %Pos, ptr %xs_2439_610_pointer_615, !noalias !2
        %ys_2440_611_pointer_616 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_613, i64 0, i32 2
        %ys_2440_611 = load %Pos, ptr %ys_2440_611_pointer_616, !noalias !2
        call ccc void @sharePositive(%Pos %zs_2441_609)
        call ccc void @sharePositive(%Pos %xs_2439_610)
        call ccc void @sharePositive(%Pos %ys_2440_611)
        call ccc void @shareFrames(%StackPointer %stackPointer_613)
        ret void
}



define ccc void @eraser_620(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_621 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %zs_2441_617_pointer_622 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_621, i64 0, i32 0
        %zs_2441_617 = load %Pos, ptr %zs_2441_617_pointer_622, !noalias !2
        %xs_2439_618_pointer_623 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_621, i64 0, i32 1
        %xs_2439_618 = load %Pos, ptr %xs_2439_618_pointer_623, !noalias !2
        %ys_2440_619_pointer_624 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_621, i64 0, i32 2
        %ys_2440_619 = load %Pos, ptr %ys_2440_619_pointer_624, !noalias !2
        call ccc void @erasePositive(%Pos %zs_2441_617)
        call ccc void @erasePositive(%Pos %xs_2439_618)
        call ccc void @erasePositive(%Pos %ys_2440_619)
        call ccc void @eraseFrames(%StackPointer %stackPointer_621)
        ret void
}



define tailcc void @tail_2442(%Pos %xs_2439, %Pos %ys_2440, %Pos %zs_2441, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %xs_2439)
        call ccc void @sharePositive(%Pos %ys_2440)
        %stackPointer_625 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %zs_2441_pointer_626 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_625, i64 0, i32 0
        store %Pos %zs_2441, ptr %zs_2441_pointer_626, !noalias !2
        %xs_2439_pointer_627 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_625, i64 0, i32 1
        store %Pos %xs_2439, ptr %xs_2439_pointer_627, !noalias !2
        %ys_2440_pointer_628 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_625, i64 0, i32 2
        store %Pos %ys_2440, ptr %ys_2440_pointer_628, !noalias !2
        %returnAddress_pointer_629 = getelementptr <{<{%Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_625, i64 0, i32 1, i32 0
        %sharer_pointer_630 = getelementptr <{<{%Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_625, i64 0, i32 1, i32 1
        %eraser_pointer_631 = getelementptr <{<{%Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_625, i64 0, i32 1, i32 2
        store ptr @returnAddress_478, ptr %returnAddress_pointer_629, !noalias !2
        store ptr @sharer_612, ptr %sharer_pointer_630, !noalias !2
        store ptr @eraser_620, ptr %eraser_pointer_631, !noalias !2
        
        
        
        
        musttail call tailcc void @isShorterThan_2436(%Pos %ys_2440, %Pos %xs_2439, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_635(%Pos %v_r_2546_3602, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_636 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %n_2437_pointer_637 = getelementptr <{i64}>, %StackPointer %stackPointer_636, i64 0, i32 0
        %n_2437 = load i64, ptr %n_2437_pointer_637, !noalias !2
        
        %pureApp_4854 = call ccc %Pos @boxInt_301(i64 %n_2437)
        
        
        
        %fields_638 = call ccc %Object @newObject(ptr @eraser_213, i64 32)
        %environment_639 = call ccc %Environment @objectEnvironment(%Object %fields_638)
        %tmp_4786_pointer_642 = getelementptr <{%Pos, %Pos}>, %Environment %environment_639, i64 0, i32 0
        store %Pos %pureApp_4854, ptr %tmp_4786_pointer_642, !noalias !2
        %v_r_2546_3602_pointer_643 = getelementptr <{%Pos, %Pos}>, %Environment %environment_639, i64 0, i32 1
        store %Pos %v_r_2546_3602, ptr %v_r_2546_3602_pointer_643, !noalias !2
        %make_4855_temporary_644 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4855 = insertvalue %Pos %make_4855_temporary_644, %Object %fields_638, 1
        
        
        
        %stackPointer_646 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_647 = getelementptr %FrameHeader, %StackPointer %stackPointer_646, i64 0, i32 0
        %returnAddress_645 = load %ReturnAddress, ptr %returnAddress_pointer_647, !noalias !2
        musttail call tailcc void %returnAddress_645(%Pos %make_4855, %Stack %stack)
        ret void
}



define ccc void @sharer_649(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_650 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %n_2437_648_pointer_651 = getelementptr <{i64}>, %StackPointer %stackPointer_650, i64 0, i32 0
        %n_2437_648 = load i64, ptr %n_2437_648_pointer_651, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_650)
        ret void
}



define ccc void @eraser_653(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_654 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %n_2437_652_pointer_655 = getelementptr <{i64}>, %StackPointer %stackPointer_654, i64 0, i32 0
        %n_2437_652 = load i64, ptr %n_2437_652_pointer_655, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_654)
        ret void
}



define tailcc void @makeList_2438(i64 %n_2437, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4851 = add i64 0, 0
        
        %pureApp_4850 = call ccc %Pos @infixEq_72(i64 %n_2437, i64 %longLiteral_4851)
        
        
        
        %tag_632 = extractvalue %Pos %pureApp_4850, 0
        %fields_633 = extractvalue %Pos %pureApp_4850, 1
        switch i64 %tag_632, label %label_634 [i64 0, label %label_661 i64 1, label %label_666]
    
    label_634:
        
        ret void
    
    label_661:
        
        %longLiteral_4853 = add i64 1, 0
        
        %pureApp_4852 = call ccc i64 @infixSub_105(i64 %n_2437, i64 %longLiteral_4853)
        
        
        %stackPointer_656 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %n_2437_pointer_657 = getelementptr <{i64}>, %StackPointer %stackPointer_656, i64 0, i32 0
        store i64 %n_2437, ptr %n_2437_pointer_657, !noalias !2
        %returnAddress_pointer_658 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_656, i64 0, i32 1, i32 0
        %sharer_pointer_659 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_656, i64 0, i32 1, i32 1
        %eraser_pointer_660 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_656, i64 0, i32 1, i32 2
        store ptr @returnAddress_635, ptr %returnAddress_pointer_658, !noalias !2
        store ptr @sharer_649, ptr %sharer_pointer_659, !noalias !2
        store ptr @eraser_653, ptr %eraser_pointer_660, !noalias !2
        
        
        
        musttail call tailcc void @makeList_2438(i64 %pureApp_4852, %Stack %stack)
        ret void
    
    label_666:
        
        %make_4856_temporary_662 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4856 = insertvalue %Pos %make_4856_temporary_662, %Object null, 1
        
        
        
        %stackPointer_664 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_665 = getelementptr %FrameHeader, %StackPointer %stackPointer_664, i64 0, i32 0
        %returnAddress_663 = load %ReturnAddress, ptr %returnAddress_pointer_665, !noalias !2
        musttail call tailcc void %returnAddress_663(%Pos %make_4856, %Stack %stack)
        ret void
}



define tailcc void @isShorterThan_2436(%Pos %x_2434, %Pos %y_2435, %Stack %stack) {
        
    entry:
        
        
        %tag_667 = extractvalue %Pos %y_2435, 0
        %fields_668 = extractvalue %Pos %y_2435, 1
        switch i64 %tag_667, label %label_677 [i64 0, label %label_682 i64 1, label %label_698]
    
    label_671:
        
        ret void
    
    label_676:
        
        %booleanLiteral_4849_temporary_672 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4849 = insertvalue %Pos %booleanLiteral_4849_temporary_672, %Object null, 1
        
        %stackPointer_674 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_675 = getelementptr %FrameHeader, %StackPointer %stackPointer_674, i64 0, i32 0
        %returnAddress_673 = load %ReturnAddress, ptr %returnAddress_pointer_675, !noalias !2
        musttail call tailcc void %returnAddress_673(%Pos %booleanLiteral_4849, %Stack %stack)
        ret void
    
    label_677:
        call ccc void @erasePositive(%Pos %y_2435)
        
        %tag_669 = extractvalue %Pos %x_2434, 0
        %fields_670 = extractvalue %Pos %x_2434, 1
        switch i64 %tag_669, label %label_671 [i64 0, label %label_676]
    
    label_682:
        call ccc void @erasePositive(%Pos %x_2434)
        
        %booleanLiteral_4847_temporary_678 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_4847 = insertvalue %Pos %booleanLiteral_4847_temporary_678, %Object null, 1
        
        %stackPointer_680 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_681 = getelementptr %FrameHeader, %StackPointer %stackPointer_680, i64 0, i32 0
        %returnAddress_679 = load %ReturnAddress, ptr %returnAddress_pointer_681, !noalias !2
        musttail call tailcc void %returnAddress_679(%Pos %booleanLiteral_4847, %Stack %stack)
        ret void
    
    label_688:
        
        ret void
    
    label_693:
        call ccc void @erasePositive(%Pos %v_coe_3515_4_3879)
        
        %booleanLiteral_4848_temporary_689 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4848 = insertvalue %Pos %booleanLiteral_4848_temporary_689, %Object null, 1
        
        %stackPointer_691 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_692 = getelementptr %FrameHeader, %StackPointer %stackPointer_691, i64 0, i32 0
        %returnAddress_690 = load %ReturnAddress, ptr %returnAddress_pointer_692, !noalias !2
        musttail call tailcc void %returnAddress_690(%Pos %booleanLiteral_4848, %Stack %stack)
        ret void
    
    label_697:
        %environment_694 = call ccc %Environment @objectEnvironment(%Object %fields_687)
        %v_coe_3511_8_3_3899_pointer_695 = getelementptr <{%Pos, %Pos}>, %Environment %environment_694, i64 0, i32 0
        %v_coe_3511_8_3_3899 = load %Pos, ptr %v_coe_3511_8_3_3899_pointer_695, !noalias !2
        %v_coe_3512_9_4_3897_pointer_696 = getelementptr <{%Pos, %Pos}>, %Environment %environment_694, i64 0, i32 1
        %v_coe_3512_9_4_3897 = load %Pos, ptr %v_coe_3512_9_4_3897_pointer_696, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3512_9_4_3897)
        call ccc void @eraseObject(%Object %fields_687)
        
        
        
        
        musttail call tailcc void @isShorterThan_2436(%Pos %v_coe_3512_9_4_3897, %Pos %v_coe_3515_4_3879, %Stack %stack)
        ret void
    
    label_698:
        %environment_683 = call ccc %Environment @objectEnvironment(%Object %fields_668)
        %v_coe_3514_3_3882_pointer_684 = getelementptr <{%Pos, %Pos}>, %Environment %environment_683, i64 0, i32 0
        %v_coe_3514_3_3882 = load %Pos, ptr %v_coe_3514_3_3882_pointer_684, !noalias !2
        %v_coe_3515_4_3879_pointer_685 = getelementptr <{%Pos, %Pos}>, %Environment %environment_683, i64 0, i32 1
        %v_coe_3515_4_3879 = load %Pos, ptr %v_coe_3515_4_3879_pointer_685, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3515_4_3879)
        call ccc void @eraseObject(%Object %fields_668)
        
        %tag_686 = extractvalue %Pos %x_2434, 0
        %fields_687 = extractvalue %Pos %x_2434, 1
        switch i64 %tag_686, label %label_688 [i64 0, label %label_693 i64 1, label %label_697]
}



define tailcc void @returnAddress_709(i64 %v_r_2521_3_3_3874, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4846 = add i64 1, 0
        
        %pureApp_4845 = call ccc i64 @infixAdd_96(i64 %longLiteral_4846, i64 %v_r_2521_3_3_3874)
        
        
        
        %stackPointer_711 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_712 = getelementptr %FrameHeader, %StackPointer %stackPointer_711, i64 0, i32 0
        %returnAddress_710 = load %ReturnAddress, ptr %returnAddress_pointer_712, !noalias !2
        musttail call tailcc void %returnAddress_710(i64 %pureApp_4845, %Stack %stack)
        ret void
}



define tailcc void @length_2433(%Pos %xs_2432, %Stack %stack) {
        
    entry:
        
        
        %tag_699 = extractvalue %Pos %xs_2432, 0
        %fields_700 = extractvalue %Pos %xs_2432, 1
        switch i64 %tag_699, label %label_701 [i64 0, label %label_705 i64 1, label %label_717]
    
    label_701:
        
        ret void
    
    label_705:
        
        %longLiteral_4844 = add i64 0, 0
        
        %stackPointer_703 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_704 = getelementptr %FrameHeader, %StackPointer %stackPointer_703, i64 0, i32 0
        %returnAddress_702 = load %ReturnAddress, ptr %returnAddress_pointer_704, !noalias !2
        musttail call tailcc void %returnAddress_702(i64 %longLiteral_4844, %Stack %stack)
        ret void
    
    label_717:
        %environment_706 = call ccc %Environment @objectEnvironment(%Object %fields_700)
        %v_coe_3508_3643_pointer_707 = getelementptr <{%Pos, %Pos}>, %Environment %environment_706, i64 0, i32 0
        %v_coe_3508_3643 = load %Pos, ptr %v_coe_3508_3643_pointer_707, !noalias !2
        %v_coe_3509_3644_pointer_708 = getelementptr <{%Pos, %Pos}>, %Environment %environment_706, i64 0, i32 1
        %v_coe_3509_3644 = load %Pos, ptr %v_coe_3509_3644_pointer_708, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3509_3644)
        call ccc void @eraseObject(%Object %fields_700)
        %stackPointer_713 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_714 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_713, i64 0, i32 1, i32 0
        %sharer_pointer_715 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_713, i64 0, i32 1, i32 1
        %eraser_pointer_716 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_713, i64 0, i32 1, i32 2
        store ptr @returnAddress_709, ptr %returnAddress_pointer_714, !noalias !2
        store ptr @sharer_137, ptr %sharer_pointer_715, !noalias !2
        store ptr @eraser_139, ptr %eraser_pointer_716, !noalias !2
        
        
        
        musttail call tailcc void @length_2433(%Pos %v_coe_3509_3644, %Stack %stack)
        ret void
}


@utf8StringLiteral_4835.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4837.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4840.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_718(%Pos %v_r_2753_3563, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_719 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_720 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_719, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_720, !noalias !2
        %index_2107_pointer_721 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_719, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_721, !noalias !2
        %Exception_2362_pointer_722 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_719, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_722, !noalias !2
        
        %tag_723 = extractvalue %Pos %v_r_2753_3563, 0
        %fields_724 = extractvalue %Pos %v_r_2753_3563, 1
        switch i64 %tag_723, label %label_725 [i64 0, label %label_729 i64 1, label %label_735]
    
    label_725:
        
        ret void
    
    label_729:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4831 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_727 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_728 = getelementptr %FrameHeader, %StackPointer %stackPointer_727, i64 0, i32 0
        %returnAddress_726 = load %ReturnAddress, ptr %returnAddress_pointer_728, !noalias !2
        musttail call tailcc void %returnAddress_726(i64 %pureApp_4831, %Stack %stack)
        ret void
    
    label_735:
        
        %make_4832_temporary_730 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4832 = insertvalue %Pos %make_4832_temporary_730, %Object null, 1
        
        
        
        %pureApp_4833 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4835 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4835.lit)
        
        %pureApp_4834 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4835, %Pos %pureApp_4833)
        
        
        
        %utf8StringLiteral_4837 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4837.lit)
        
        %pureApp_4836 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4834, %Pos %utf8StringLiteral_4837)
        
        
        
        %pureApp_4838 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4836, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4840 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4840.lit)
        
        %pureApp_4839 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4838, %Pos %utf8StringLiteral_4840)
        
        
        
        %vtable_731 = extractvalue %Neg %Exception_2362, 0
        %closure_732 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_733 = getelementptr ptr, ptr %vtable_731, i64 0
        %functionPointer_734 = load ptr, ptr %functionPointer_pointer_733, !noalias !2
        musttail call tailcc void %functionPointer_734(%Object %closure_732, %Pos %make_4832, %Pos %pureApp_4839, %Stack %stack)
        ret void
}



define ccc void @sharer_739(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_740 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_736_pointer_741 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_740, i64 0, i32 0
        %str_2106_736 = load %Pos, ptr %str_2106_736_pointer_741, !noalias !2
        %index_2107_737_pointer_742 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_740, i64 0, i32 1
        %index_2107_737 = load i64, ptr %index_2107_737_pointer_742, !noalias !2
        %Exception_2362_738_pointer_743 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_740, i64 0, i32 2
        %Exception_2362_738 = load %Neg, ptr %Exception_2362_738_pointer_743, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_736)
        call ccc void @shareNegative(%Neg %Exception_2362_738)
        call ccc void @shareFrames(%StackPointer %stackPointer_740)
        ret void
}



define ccc void @eraser_747(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_748 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_744_pointer_749 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_748, i64 0, i32 0
        %str_2106_744 = load %Pos, ptr %str_2106_744_pointer_749, !noalias !2
        %index_2107_745_pointer_750 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_748, i64 0, i32 1
        %index_2107_745 = load i64, ptr %index_2107_745_pointer_750, !noalias !2
        %Exception_2362_746_pointer_751 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_748, i64 0, i32 2
        %Exception_2362_746 = load %Neg, ptr %Exception_2362_746_pointer_751, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_744)
        call ccc void @eraseNegative(%Neg %Exception_2362_746)
        call ccc void @eraseFrames(%StackPointer %stackPointer_748)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4830 = add i64 0, 0
        
        %pureApp_4829 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4830)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_752 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_753 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_752, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_753, !noalias !2
        %index_2107_pointer_754 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_752, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_754, !noalias !2
        %Exception_2362_pointer_755 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_752, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_755, !noalias !2
        %returnAddress_pointer_756 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_752, i64 0, i32 1, i32 0
        %sharer_pointer_757 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_752, i64 0, i32 1, i32 1
        %eraser_pointer_758 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_752, i64 0, i32 1, i32 2
        store ptr @returnAddress_718, ptr %returnAddress_pointer_756, !noalias !2
        store ptr @sharer_739, ptr %sharer_pointer_757, !noalias !2
        store ptr @eraser_747, ptr %eraser_pointer_758, !noalias !2
        
        %tag_759 = extractvalue %Pos %pureApp_4829, 0
        %fields_760 = extractvalue %Pos %pureApp_4829, 1
        switch i64 %tag_759, label %label_761 [i64 0, label %label_765 i64 1, label %label_770]
    
    label_761:
        
        ret void
    
    label_765:
        
        %pureApp_4841 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4842 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4841)
        
        
        
        %stackPointer_763 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_764 = getelementptr %FrameHeader, %StackPointer %stackPointer_763, i64 0, i32 0
        %returnAddress_762 = load %ReturnAddress, ptr %returnAddress_pointer_764, !noalias !2
        musttail call tailcc void %returnAddress_762(%Pos %pureApp_4842, %Stack %stack)
        ret void
    
    label_770:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4843_temporary_766 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4843 = insertvalue %Pos %booleanLiteral_4843_temporary_766, %Object null, 1
        
        %stackPointer_768 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_769 = getelementptr %FrameHeader, %StackPointer %stackPointer_768, i64 0, i32 0
        %returnAddress_767 = load %ReturnAddress, ptr %returnAddress_pointer_769, !noalias !2
        musttail call tailcc void %returnAddress_767(%Pos %booleanLiteral_4843, %Stack %stack)
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
        
        musttail call tailcc void @main_2445(%Stack %stack)
        ret void
}
