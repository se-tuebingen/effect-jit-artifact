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



define ccc double @infixAdd_111(double %x_109, double %y_110) {
    ; declaration extern
    ; variable
    %z = fadd %Double %x_109, %y_110 ret %Double %z
}



define ccc double @infixMul_114(double %x_112, double %y_113) {
    ; declaration extern
    ; variable
    %z = fmul %Double %x_112, %y_113 ret %Double %z
}



define ccc double @infixSub_117(double %x_115, double %y_116) {
    ; declaration extern
    ; variable
    %z = fsub %Double %x_115, %y_116 ret %Double %z
}



define ccc double @infixDiv_120(double %x_118, double %y_119) {
    ; declaration extern
    ; variable
    %z = fdiv %Double %x_118, %y_119 ret %Double %z
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



define ccc %Pos @infixGt_202(double %x_200, double %y_201) {
    ; declaration extern
    ; variable
    
    %z = fcmp ogt %Double %x_200, %y_201
    %fat_z = zext i1 %z to i64
    %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
    ret %Pos %adt_boolean
  
}



define ccc i64 @bitwiseShl_228(i64 %x_226, i64 %y_227) {
    ; declaration extern
    ; variable
    %z = shl %Int %x_226, %y_227 ret %Int %z
}



define ccc i64 @bitwiseXor_240(i64 %x_238, i64 %y_239) {
    ; declaration extern
    ; variable
    %z = xor %Int %x_238, %y_239 ret %Int %z
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



define tailcc void @returnAddress_2(i64 %r_2489, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5813 = call ccc %Pos @show_14(i64 %r_2489)
        
        
        
        %pureApp_5814 = call ccc %Pos @println_1(%Pos %pureApp_5813)
        
        
        
        %stackPointer_4 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_5 = getelementptr %FrameHeader, %StackPointer %stackPointer_4, i64 0, i32 0
        %returnAddress_3 = load %ReturnAddress, ptr %returnAddress_pointer_5, !noalias !2
        musttail call tailcc void %returnAddress_3(%Pos %pureApp_5814, %Stack %stack)
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
        %v_r_2555_2_2_5347_pointer_17 = getelementptr <{i64}>, %StackPointer %stackPointer_16, i64 0, i32 0
        %v_r_2555_2_2_5347 = load i64, ptr %v_r_2555_2_2_5347_pointer_17, !noalias !2
        %stackPointer_19 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_20 = getelementptr %FrameHeader, %StackPointer %stackPointer_19, i64 0, i32 0
        %returnAddress_18 = load %ReturnAddress, ptr %returnAddress_pointer_20, !noalias !2
        musttail call tailcc void %returnAddress_18(i64 %returnValue_15, %Stack %stack)
        ret void
}



define ccc void @sharer_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2555_2_2_5347_21_pointer_24 = getelementptr <{i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %v_r_2555_2_2_5347_21 = load i64, ptr %v_r_2555_2_2_5347_21_pointer_24, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_23)
        ret void
}



define ccc void @eraser_26(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_27 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2555_2_2_5347_25_pointer_28 = getelementptr <{i64}>, %StackPointer %stackPointer_27, i64 0, i32 0
        %v_r_2555_2_2_5347_25 = load i64, ptr %v_r_2555_2_2_5347_25_pointer_28, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_27)
        ret void
}



define tailcc void @returnAddress_34(i64 %returnValue_35, %Stack %stack) {
        
    entry:
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2556_4_4_5531_pointer_37 = getelementptr <{i64}>, %StackPointer %stackPointer_36, i64 0, i32 0
        %v_r_2556_4_4_5531 = load i64, ptr %v_r_2556_4_4_5531_pointer_37, !noalias !2
        %stackPointer_39 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_40 = getelementptr %FrameHeader, %StackPointer %stackPointer_39, i64 0, i32 0
        %returnAddress_38 = load %ReturnAddress, ptr %returnAddress_pointer_40, !noalias !2
        musttail call tailcc void %returnAddress_38(i64 %returnValue_35, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_48(i64 %returnValue_49, %Stack %stack) {
        
    entry:
        
        %stackPointer_50 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2557_6_6_5291_pointer_51 = getelementptr <{i64}>, %StackPointer %stackPointer_50, i64 0, i32 0
        %v_r_2557_6_6_5291 = load i64, ptr %v_r_2557_6_6_5291_pointer_51, !noalias !2
        %stackPointer_53 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_54 = getelementptr %FrameHeader, %StackPointer %stackPointer_53, i64 0, i32 0
        %returnAddress_52 = load %ReturnAddress, ptr %returnAddress_pointer_54, !noalias !2
        musttail call tailcc void %returnAddress_52(i64 %returnValue_49, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_78(%Pos %__8_173_357_357_5630, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_79 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %i_6_91_275_275_5504_pointer_80 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_79, i64 0, i32 0
        %i_6_91_275_275_5504 = load i64, ptr %i_6_91_275_275_5504_pointer_80, !noalias !2
        %tmp_5795_pointer_81 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_79, i64 0, i32 1
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_81, !noalias !2
        %bitNum_7_7_5558_pointer_82 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_79, i64 0, i32 2
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_82, !noalias !2
        %tmp_5760_pointer_83 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_79, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_83, !noalias !2
        %sum_3_3_5426_pointer_84 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_79, i64 0, i32 4
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_84, !noalias !2
        %byteAcc_5_5_5418_pointer_85 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_79, i64 0, i32 5
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_85, !noalias !2
        call ccc void @erasePositive(%Pos %__8_173_357_357_5630)
        
        %longLiteral_5833 = add i64 1, 0
        
        %pureApp_5832 = call ccc i64 @infixAdd_96(i64 %i_6_91_275_275_5504, i64 %longLiteral_5833)
        
        
        
        
        
        musttail call tailcc void @loop_5_90_274_274_5441(i64 %pureApp_5832, i64 %tmp_5795, %Reference %bitNum_7_7_5558, double %tmp_5760, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, %Stack %stack)
        ret void
}



define ccc void @sharer_92(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_93 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_91_275_275_5504_86_pointer_94 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_93, i64 0, i32 0
        %i_6_91_275_275_5504_86 = load i64, ptr %i_6_91_275_275_5504_86_pointer_94, !noalias !2
        %tmp_5795_87_pointer_95 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_93, i64 0, i32 1
        %tmp_5795_87 = load i64, ptr %tmp_5795_87_pointer_95, !noalias !2
        %bitNum_7_7_5558_88_pointer_96 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_93, i64 0, i32 2
        %bitNum_7_7_5558_88 = load %Reference, ptr %bitNum_7_7_5558_88_pointer_96, !noalias !2
        %tmp_5760_89_pointer_97 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_93, i64 0, i32 3
        %tmp_5760_89 = load double, ptr %tmp_5760_89_pointer_97, !noalias !2
        %sum_3_3_5426_90_pointer_98 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_93, i64 0, i32 4
        %sum_3_3_5426_90 = load %Reference, ptr %sum_3_3_5426_90_pointer_98, !noalias !2
        %byteAcc_5_5_5418_91_pointer_99 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_93, i64 0, i32 5
        %byteAcc_5_5_5418_91 = load %Reference, ptr %byteAcc_5_5_5418_91_pointer_99, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_93)
        ret void
}



define ccc void @eraser_106(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_107 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_91_275_275_5504_100_pointer_108 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_107, i64 0, i32 0
        %i_6_91_275_275_5504_100 = load i64, ptr %i_6_91_275_275_5504_100_pointer_108, !noalias !2
        %tmp_5795_101_pointer_109 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_107, i64 0, i32 1
        %tmp_5795_101 = load i64, ptr %tmp_5795_101_pointer_109, !noalias !2
        %bitNum_7_7_5558_102_pointer_110 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_107, i64 0, i32 2
        %bitNum_7_7_5558_102 = load %Reference, ptr %bitNum_7_7_5558_102_pointer_110, !noalias !2
        %tmp_5760_103_pointer_111 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_107, i64 0, i32 3
        %tmp_5760_103 = load double, ptr %tmp_5760_103_pointer_111, !noalias !2
        %sum_3_3_5426_104_pointer_112 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_107, i64 0, i32 4
        %sum_3_3_5426_104 = load %Reference, ptr %sum_3_3_5426_104_pointer_112, !noalias !2
        %byteAcc_5_5_5418_105_pointer_113 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_107, i64 0, i32 5
        %byteAcc_5_5_5418_105 = load %Reference, ptr %byteAcc_5_5_5418_105_pointer_113, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_107)
        ret void
}



define tailcc void @returnAddress_124(%Pos %returnValue_125, %Stack %stack) {
        
    entry:
        
        %stackPointer_126 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2559_2_93_277_277_5287_pointer_127 = getelementptr <{double}>, %StackPointer %stackPointer_126, i64 0, i32 0
        %v_r_2559_2_93_277_277_5287 = load double, ptr %v_r_2559_2_93_277_277_5287_pointer_127, !noalias !2
        %stackPointer_129 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_130 = getelementptr %FrameHeader, %StackPointer %stackPointer_129, i64 0, i32 0
        %returnAddress_128 = load %ReturnAddress, ptr %returnAddress_pointer_130, !noalias !2
        musttail call tailcc void %returnAddress_128(%Pos %returnValue_125, %Stack %stack)
        ret void
}



define ccc void @sharer_132(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_133 = getelementptr <{double}>, %StackPointer %stackPointer, i64 -1
        %v_r_2559_2_93_277_277_5287_131_pointer_134 = getelementptr <{double}>, %StackPointer %stackPointer_133, i64 0, i32 0
        %v_r_2559_2_93_277_277_5287_131 = load double, ptr %v_r_2559_2_93_277_277_5287_131_pointer_134, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_133)
        ret void
}



define ccc void @eraser_136(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_137 = getelementptr <{double}>, %StackPointer %stackPointer, i64 -1
        %v_r_2559_2_93_277_277_5287_135_pointer_138 = getelementptr <{double}>, %StackPointer %stackPointer_137, i64 0, i32 0
        %v_r_2559_2_93_277_277_5287_135 = load double, ptr %v_r_2559_2_93_277_277_5287_135_pointer_138, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_137)
        ret void
}



define tailcc void @returnAddress_144(%Pos %returnValue_145, %Stack %stack) {
        
    entry:
        
        %stackPointer_146 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2560_4_95_279_279_5285_pointer_147 = getelementptr <{double}>, %StackPointer %stackPointer_146, i64 0, i32 0
        %v_r_2560_4_95_279_279_5285 = load double, ptr %v_r_2560_4_95_279_279_5285_pointer_147, !noalias !2
        %stackPointer_149 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_150 = getelementptr %FrameHeader, %StackPointer %stackPointer_149, i64 0, i32 0
        %returnAddress_148 = load %ReturnAddress, ptr %returnAddress_pointer_150, !noalias !2
        musttail call tailcc void %returnAddress_148(%Pos %returnValue_145, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_158(%Pos %returnValue_159, %Stack %stack) {
        
    entry:
        
        %stackPointer_160 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2561_6_97_281_281_5529_pointer_161 = getelementptr <{double}>, %StackPointer %stackPointer_160, i64 0, i32 0
        %v_r_2561_6_97_281_281_5529 = load double, ptr %v_r_2561_6_97_281_281_5529_pointer_161, !noalias !2
        %stackPointer_163 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_164 = getelementptr %FrameHeader, %StackPointer %stackPointer_163, i64 0, i32 0
        %returnAddress_162 = load %ReturnAddress, ptr %returnAddress_pointer_164, !noalias !2
        musttail call tailcc void %returnAddress_162(%Pos %returnValue_159, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_172(%Pos %returnValue_173, %Stack %stack) {
        
    entry:
        
        %stackPointer_174 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2562_14_105_289_289_5541_pointer_175 = getelementptr <{i64}>, %StackPointer %stackPointer_174, i64 0, i32 0
        %v_r_2562_14_105_289_289_5541 = load i64, ptr %v_r_2562_14_105_289_289_5541_pointer_175, !noalias !2
        %stackPointer_177 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_178 = getelementptr %FrameHeader, %StackPointer %stackPointer_177, i64 0, i32 0
        %returnAddress_176 = load %ReturnAddress, ptr %returnAddress_pointer_178, !noalias !2
        musttail call tailcc void %returnAddress_176(%Pos %returnValue_173, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_187(%Pos %returnValue_188, %Stack %stack) {
        
    entry:
        
        %stackPointer_189 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_r_2563_16_107_291_291_5489_pointer_190 = getelementptr <{%Pos}>, %StackPointer %stackPointer_189, i64 0, i32 0
        %v_r_2563_16_107_291_291_5489 = load %Pos, ptr %v_r_2563_16_107_291_291_5489_pointer_190, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2563_16_107_291_291_5489)
        %stackPointer_192 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_193 = getelementptr %FrameHeader, %StackPointer %stackPointer_192, i64 0, i32 0
        %returnAddress_191 = load %ReturnAddress, ptr %returnAddress_pointer_193, !noalias !2
        musttail call tailcc void %returnAddress_191(%Pos %returnValue_188, %Stack %stack)
        ret void
}



define ccc void @sharer_195(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_196 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2563_16_107_291_291_5489_194_pointer_197 = getelementptr <{%Pos}>, %StackPointer %stackPointer_196, i64 0, i32 0
        %v_r_2563_16_107_291_291_5489_194 = load %Pos, ptr %v_r_2563_16_107_291_291_5489_194_pointer_197, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2563_16_107_291_291_5489_194)
        call ccc void @shareFrames(%StackPointer %stackPointer_196)
        ret void
}



define ccc void @eraser_199(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_200 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2563_16_107_291_291_5489_198_pointer_201 = getelementptr <{%Pos}>, %StackPointer %stackPointer_200, i64 0, i32 0
        %v_r_2563_16_107_291_291_5489_198 = load %Pos, ptr %v_r_2563_16_107_291_291_5489_198_pointer_201, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2563_16_107_291_291_5489_198)
        call ccc void @eraseFrames(%StackPointer %stackPointer_200)
        ret void
}



define tailcc void @returnAddress_207(%Pos %returnValue_208, %Stack %stack) {
        
    entry:
        
        %stackPointer_209 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2564_18_109_293_293_5537_pointer_210 = getelementptr <{i64}>, %StackPointer %stackPointer_209, i64 0, i32 0
        %v_r_2564_18_109_293_293_5537 = load i64, ptr %v_r_2564_18_109_293_293_5537_pointer_210, !noalias !2
        %stackPointer_212 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_213 = getelementptr %FrameHeader, %StackPointer %stackPointer_212, i64 0, i32 0
        %returnAddress_211 = load %ReturnAddress, ptr %returnAddress_pointer_213, !noalias !2
        musttail call tailcc void %returnAddress_211(%Pos %returnValue_208, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_374(%Pos %v_whileThen_2581_53_144_328_328_5621, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_375 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_376 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_376, !noalias !2
        %zizi_7_98_282_282_5424_pointer_377 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_377, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_378 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_378, !noalias !2
        %tmp_5760_pointer_379 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_379, !noalias !2
        %notDone_17_108_292_292_5542_pointer_380 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_380, !noalias !2
        %z_15_106_290_290_5374_pointer_381 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_381, !noalias !2
        %zi_5_96_280_280_5410_pointer_382 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_382, !noalias !2
        %escape_19_110_294_294_5368_pointer_383 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_375, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_383, !noalias !2
        call ccc void @erasePositive(%Pos %v_whileThen_2581_53_144_328_328_5621)
        
        
        musttail call tailcc void @b_whileLoop_2565_20_111_295_295_5509(double %tmp_5766, %Reference %zizi_7_98_282_282_5424, %Reference %zrzr_3_94_278_278_5552, double %tmp_5760, %Reference %notDone_17_108_292_292_5542, %Reference %z_15_106_290_290_5374, %Reference %zi_5_96_280_280_5410, %Reference %escape_19_110_294_294_5368, %Stack %stack)
        ret void
}



define ccc void @sharer_392(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_393 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_384_pointer_394 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_393, i64 0, i32 0
        %tmp_5766_384 = load double, ptr %tmp_5766_384_pointer_394, !noalias !2
        %zizi_7_98_282_282_5424_385_pointer_395 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_393, i64 0, i32 1
        %zizi_7_98_282_282_5424_385 = load %Reference, ptr %zizi_7_98_282_282_5424_385_pointer_395, !noalias !2
        %zrzr_3_94_278_278_5552_386_pointer_396 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_393, i64 0, i32 2
        %zrzr_3_94_278_278_5552_386 = load %Reference, ptr %zrzr_3_94_278_278_5552_386_pointer_396, !noalias !2
        %tmp_5760_387_pointer_397 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_393, i64 0, i32 3
        %tmp_5760_387 = load double, ptr %tmp_5760_387_pointer_397, !noalias !2
        %notDone_17_108_292_292_5542_388_pointer_398 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_393, i64 0, i32 4
        %notDone_17_108_292_292_5542_388 = load %Reference, ptr %notDone_17_108_292_292_5542_388_pointer_398, !noalias !2
        %z_15_106_290_290_5374_389_pointer_399 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_393, i64 0, i32 5
        %z_15_106_290_290_5374_389 = load %Reference, ptr %z_15_106_290_290_5374_389_pointer_399, !noalias !2
        %zi_5_96_280_280_5410_390_pointer_400 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_393, i64 0, i32 6
        %zi_5_96_280_280_5410_390 = load %Reference, ptr %zi_5_96_280_280_5410_390_pointer_400, !noalias !2
        %escape_19_110_294_294_5368_391_pointer_401 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_393, i64 0, i32 7
        %escape_19_110_294_294_5368_391 = load %Reference, ptr %escape_19_110_294_294_5368_391_pointer_401, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_393)
        ret void
}



define ccc void @eraser_410(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_411 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_402_pointer_412 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 0
        %tmp_5766_402 = load double, ptr %tmp_5766_402_pointer_412, !noalias !2
        %zizi_7_98_282_282_5424_403_pointer_413 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 1
        %zizi_7_98_282_282_5424_403 = load %Reference, ptr %zizi_7_98_282_282_5424_403_pointer_413, !noalias !2
        %zrzr_3_94_278_278_5552_404_pointer_414 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 2
        %zrzr_3_94_278_278_5552_404 = load %Reference, ptr %zrzr_3_94_278_278_5552_404_pointer_414, !noalias !2
        %tmp_5760_405_pointer_415 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 3
        %tmp_5760_405 = load double, ptr %tmp_5760_405_pointer_415, !noalias !2
        %notDone_17_108_292_292_5542_406_pointer_416 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 4
        %notDone_17_108_292_292_5542_406 = load %Reference, ptr %notDone_17_108_292_292_5542_406_pointer_416, !noalias !2
        %z_15_106_290_290_5374_407_pointer_417 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 5
        %z_15_106_290_290_5374_407 = load %Reference, ptr %z_15_106_290_290_5374_407_pointer_417, !noalias !2
        %zi_5_96_280_280_5410_408_pointer_418 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 6
        %zi_5_96_280_280_5410_408 = load %Reference, ptr %zi_5_96_280_280_5410_408_pointer_418, !noalias !2
        %escape_19_110_294_294_5368_409_pointer_419 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_411, i64 0, i32 7
        %escape_19_110_294_294_5368_409 = load %Reference, ptr %escape_19_110_294_294_5368_409_pointer_419, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_411)
        ret void
}



define tailcc void @returnAddress_364(i64 %v_r_2579_51_142_326_326_5487, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_365 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_366 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_365, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_366, !noalias !2
        %zizi_7_98_282_282_5424_pointer_367 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_365, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_367, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_368 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_365, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_368, !noalias !2
        %tmp_5760_pointer_369 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_365, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_369, !noalias !2
        %notDone_17_108_292_292_5542_pointer_370 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_365, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_370, !noalias !2
        %z_15_106_290_290_5374_pointer_371 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_365, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_371, !noalias !2
        %zi_5_96_280_280_5410_pointer_372 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_365, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_372, !noalias !2
        %escape_19_110_294_294_5368_pointer_373 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_365, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_373, !noalias !2
        
        %longLiteral_5865 = add i64 1, 0
        
        %pureApp_5864 = call ccc i64 @infixAdd_96(i64 %v_r_2579_51_142_326_326_5487, i64 %longLiteral_5865)
        
        
        %stackPointer_420 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_421 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_420, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_421, !noalias !2
        %zizi_7_98_282_282_5424_pointer_422 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_420, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_422, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_423 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_420, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_423, !noalias !2
        %tmp_5760_pointer_424 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_420, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_424, !noalias !2
        %notDone_17_108_292_292_5542_pointer_425 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_420, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_425, !noalias !2
        %z_15_106_290_290_5374_pointer_426 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_420, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_426, !noalias !2
        %zi_5_96_280_280_5410_pointer_427 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_420, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_427, !noalias !2
        %escape_19_110_294_294_5368_pointer_428 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_420, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_428, !noalias !2
        %returnAddress_pointer_429 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_420, i64 0, i32 1, i32 0
        %sharer_pointer_430 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_420, i64 0, i32 1, i32 1
        %eraser_pointer_431 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_420, i64 0, i32 1, i32 2
        store ptr @returnAddress_374, ptr %returnAddress_pointer_429, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_430, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_431, !noalias !2
        
        %z_15_106_290_290_5374pointer_432 = call ccc ptr @getVarPointer(%Reference %z_15_106_290_290_5374, %Stack %stack)
        %z_15_106_290_290_5374_old_433 = load i64, ptr %z_15_106_290_290_5374pointer_432, !noalias !2
        store i64 %pureApp_5864, ptr %z_15_106_290_290_5374pointer_432, !noalias !2
        
        %put_5866_temporary_434 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5866 = insertvalue %Pos %put_5866_temporary_434, %Object null, 1
        
        %stackPointer_436 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_437 = getelementptr %FrameHeader, %StackPointer %stackPointer_436, i64 0, i32 0
        %returnAddress_435 = load %ReturnAddress, ptr %returnAddress_pointer_437, !noalias !2
        musttail call tailcc void %returnAddress_435(%Pos %put_5866, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_354(%Pos %__50_141_325_325_5620, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_355 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_356 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_355, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_356, !noalias !2
        %zizi_7_98_282_282_5424_pointer_357 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_355, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_357, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_358 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_355, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_358, !noalias !2
        %tmp_5760_pointer_359 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_355, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_359, !noalias !2
        %notDone_17_108_292_292_5542_pointer_360 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_355, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_360, !noalias !2
        %z_15_106_290_290_5374_pointer_361 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_355, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_361, !noalias !2
        %zi_5_96_280_280_5410_pointer_362 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_355, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_362, !noalias !2
        %escape_19_110_294_294_5368_pointer_363 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_355, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_363, !noalias !2
        call ccc void @erasePositive(%Pos %__50_141_325_325_5620)
        %stackPointer_454 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_455 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_455, !noalias !2
        %zizi_7_98_282_282_5424_pointer_456 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_456, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_457 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_457, !noalias !2
        %tmp_5760_pointer_458 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_458, !noalias !2
        %notDone_17_108_292_292_5542_pointer_459 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_459, !noalias !2
        %z_15_106_290_290_5374_pointer_460 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_460, !noalias !2
        %zi_5_96_280_280_5410_pointer_461 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_461, !noalias !2
        %escape_19_110_294_294_5368_pointer_462 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_462, !noalias !2
        %returnAddress_pointer_463 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_454, i64 0, i32 1, i32 0
        %sharer_pointer_464 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_454, i64 0, i32 1, i32 1
        %eraser_pointer_465 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_454, i64 0, i32 1, i32 2
        store ptr @returnAddress_364, ptr %returnAddress_pointer_463, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_464, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_465, !noalias !2
        
        %get_5867_pointer_466 = call ccc ptr @getVarPointer(%Reference %z_15_106_290_290_5374, %Stack %stack)
        %z_15_106_290_290_5374_old_467 = load i64, ptr %get_5867_pointer_466, !noalias !2
        %get_5867 = load i64, ptr %get_5867_pointer_466, !noalias !2
        
        %stackPointer_469 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_470 = getelementptr %FrameHeader, %StackPointer %stackPointer_469, i64 0, i32 0
        %returnAddress_468 = load %ReturnAddress, ptr %returnAddress_pointer_470, !noalias !2
        musttail call tailcc void %returnAddress_468(i64 %get_5867, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_507(%Pos %__49_140_324_324_5619, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_508 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %escape_19_110_294_294_5368_pointer_509 = getelementptr <{%Reference}>, %StackPointer %stackPointer_508, i64 0, i32 0
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_509, !noalias !2
        call ccc void @erasePositive(%Pos %__49_140_324_324_5619)
        
        %longLiteral_5870 = add i64 1, 0
        
        %escape_19_110_294_294_5368pointer_510 = call ccc ptr @getVarPointer(%Reference %escape_19_110_294_294_5368, %Stack %stack)
        %escape_19_110_294_294_5368_old_511 = load i64, ptr %escape_19_110_294_294_5368pointer_510, !noalias !2
        store i64 %longLiteral_5870, ptr %escape_19_110_294_294_5368pointer_510, !noalias !2
        
        %put_5869_temporary_512 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5869 = insertvalue %Pos %put_5869_temporary_512, %Object null, 1
        
        %stackPointer_514 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_515 = getelementptr %FrameHeader, %StackPointer %stackPointer_514, i64 0, i32 0
        %returnAddress_513 = load %ReturnAddress, ptr %returnAddress_pointer_515, !noalias !2
        musttail call tailcc void %returnAddress_513(%Pos %put_5869, %Stack %stack)
        ret void
}



define ccc void @sharer_517(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_518 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %escape_19_110_294_294_5368_516_pointer_519 = getelementptr <{%Reference}>, %StackPointer %stackPointer_518, i64 0, i32 0
        %escape_19_110_294_294_5368_516 = load %Reference, ptr %escape_19_110_294_294_5368_516_pointer_519, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_518)
        ret void
}



define ccc void @eraser_521(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_522 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %escape_19_110_294_294_5368_520_pointer_523 = getelementptr <{%Reference}>, %StackPointer %stackPointer_522, i64 0, i32 0
        %escape_19_110_294_294_5368_520 = load %Reference, ptr %escape_19_110_294_294_5368_520_pointer_523, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_522)
        ret void
}



define tailcc void @returnAddress_343(double %v_r_2575_46_137_321_321_5396, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_344 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 120)
        %tmp_5766_pointer_345 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_345, !noalias !2
        %zizi_7_98_282_282_5424_pointer_346 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_346, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_347 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_347, !noalias !2
        %tmp_5760_pointer_348 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_348, !noalias !2
        %notDone_17_108_292_292_5542_pointer_349 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_349, !noalias !2
        %z_15_106_290_290_5374_pointer_350 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_350, !noalias !2
        %v_r_2574_45_136_320_320_5523_pointer_351 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 6
        %v_r_2574_45_136_320_320_5523 = load double, ptr %v_r_2574_45_136_320_320_5523_pointer_351, !noalias !2
        %zi_5_96_280_280_5410_pointer_352 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 7
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_352, !noalias !2
        %escape_19_110_294_294_5368_pointer_353 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_344, i64 0, i32 8
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_353, !noalias !2
        
        %pureApp_5861 = call ccc double @infixAdd_111(double %v_r_2574_45_136_320_320_5523, double %v_r_2575_46_137_321_321_5396)
        
        
        
        %doubleLiteral_5863 = fadd double 4.0, 0.0
        
        %pureApp_5862 = call ccc %Pos @infixGt_202(double %pureApp_5861, double %doubleLiteral_5863)
        
        
        %stackPointer_487 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_488 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_487, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_488, !noalias !2
        %zizi_7_98_282_282_5424_pointer_489 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_487, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_489, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_490 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_487, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_490, !noalias !2
        %tmp_5760_pointer_491 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_487, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_491, !noalias !2
        %notDone_17_108_292_292_5542_pointer_492 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_487, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_492, !noalias !2
        %z_15_106_290_290_5374_pointer_493 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_487, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_493, !noalias !2
        %zi_5_96_280_280_5410_pointer_494 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_487, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_494, !noalias !2
        %escape_19_110_294_294_5368_pointer_495 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_487, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_495, !noalias !2
        %returnAddress_pointer_496 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_487, i64 0, i32 1, i32 0
        %sharer_pointer_497 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_487, i64 0, i32 1, i32 1
        %eraser_pointer_498 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_487, i64 0, i32 1, i32 2
        store ptr @returnAddress_354, ptr %returnAddress_pointer_496, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_497, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_498, !noalias !2
        
        %tag_499 = extractvalue %Pos %pureApp_5862, 0
        %fields_500 = extractvalue %Pos %pureApp_5862, 1
        switch i64 %tag_499, label %label_501 [i64 0, label %label_506 i64 1, label %label_536]
    
    label_501:
        
        ret void
    
    label_506:
        
        %unitLiteral_5868_temporary_502 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5868 = insertvalue %Pos %unitLiteral_5868_temporary_502, %Object null, 1
        
        %stackPointer_504 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_505 = getelementptr %FrameHeader, %StackPointer %stackPointer_504, i64 0, i32 0
        %returnAddress_503 = load %ReturnAddress, ptr %returnAddress_pointer_505, !noalias !2
        musttail call tailcc void %returnAddress_503(%Pos %unitLiteral_5868, %Stack %stack)
        ret void
    
    label_536:
        %stackPointer_524 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %escape_19_110_294_294_5368_pointer_525 = getelementptr <{%Reference}>, %StackPointer %stackPointer_524, i64 0, i32 0
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_525, !noalias !2
        %returnAddress_pointer_526 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_524, i64 0, i32 1, i32 0
        %sharer_pointer_527 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_524, i64 0, i32 1, i32 1
        %eraser_pointer_528 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_524, i64 0, i32 1, i32 2
        store ptr @returnAddress_507, ptr %returnAddress_pointer_526, !noalias !2
        store ptr @sharer_517, ptr %sharer_pointer_527, !noalias !2
        store ptr @eraser_521, ptr %eraser_pointer_528, !noalias !2
        
        %booleanLiteral_5872_temporary_529 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_5872 = insertvalue %Pos %booleanLiteral_5872_temporary_529, %Object null, 1
        
        %notDone_17_108_292_292_5542pointer_530 = call ccc ptr @getVarPointer(%Reference %notDone_17_108_292_292_5542, %Stack %stack)
        %notDone_17_108_292_292_5542_old_531 = load %Pos, ptr %notDone_17_108_292_292_5542pointer_530, !noalias !2
        call ccc void @erasePositive(%Pos %notDone_17_108_292_292_5542_old_531)
        store %Pos %booleanLiteral_5872, ptr %notDone_17_108_292_292_5542pointer_530, !noalias !2
        
        %put_5871_temporary_532 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5871 = insertvalue %Pos %put_5871_temporary_532, %Object null, 1
        
        %stackPointer_534 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_535 = getelementptr %FrameHeader, %StackPointer %stackPointer_534, i64 0, i32 0
        %returnAddress_533 = load %ReturnAddress, ptr %returnAddress_pointer_535, !noalias !2
        musttail call tailcc void %returnAddress_533(%Pos %put_5871, %Stack %stack)
        ret void
}



define ccc void @sharer_546(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_547 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_537_pointer_548 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 0
        %tmp_5766_537 = load double, ptr %tmp_5766_537_pointer_548, !noalias !2
        %zizi_7_98_282_282_5424_538_pointer_549 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 1
        %zizi_7_98_282_282_5424_538 = load %Reference, ptr %zizi_7_98_282_282_5424_538_pointer_549, !noalias !2
        %zrzr_3_94_278_278_5552_539_pointer_550 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 2
        %zrzr_3_94_278_278_5552_539 = load %Reference, ptr %zrzr_3_94_278_278_5552_539_pointer_550, !noalias !2
        %tmp_5760_540_pointer_551 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 3
        %tmp_5760_540 = load double, ptr %tmp_5760_540_pointer_551, !noalias !2
        %notDone_17_108_292_292_5542_541_pointer_552 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 4
        %notDone_17_108_292_292_5542_541 = load %Reference, ptr %notDone_17_108_292_292_5542_541_pointer_552, !noalias !2
        %z_15_106_290_290_5374_542_pointer_553 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 5
        %z_15_106_290_290_5374_542 = load %Reference, ptr %z_15_106_290_290_5374_542_pointer_553, !noalias !2
        %v_r_2574_45_136_320_320_5523_543_pointer_554 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 6
        %v_r_2574_45_136_320_320_5523_543 = load double, ptr %v_r_2574_45_136_320_320_5523_543_pointer_554, !noalias !2
        %zi_5_96_280_280_5410_544_pointer_555 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 7
        %zi_5_96_280_280_5410_544 = load %Reference, ptr %zi_5_96_280_280_5410_544_pointer_555, !noalias !2
        %escape_19_110_294_294_5368_545_pointer_556 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_547, i64 0, i32 8
        %escape_19_110_294_294_5368_545 = load %Reference, ptr %escape_19_110_294_294_5368_545_pointer_556, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_547)
        ret void
}



define ccc void @eraser_566(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_567 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_557_pointer_568 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 0
        %tmp_5766_557 = load double, ptr %tmp_5766_557_pointer_568, !noalias !2
        %zizi_7_98_282_282_5424_558_pointer_569 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 1
        %zizi_7_98_282_282_5424_558 = load %Reference, ptr %zizi_7_98_282_282_5424_558_pointer_569, !noalias !2
        %zrzr_3_94_278_278_5552_559_pointer_570 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 2
        %zrzr_3_94_278_278_5552_559 = load %Reference, ptr %zrzr_3_94_278_278_5552_559_pointer_570, !noalias !2
        %tmp_5760_560_pointer_571 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 3
        %tmp_5760_560 = load double, ptr %tmp_5760_560_pointer_571, !noalias !2
        %notDone_17_108_292_292_5542_561_pointer_572 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 4
        %notDone_17_108_292_292_5542_561 = load %Reference, ptr %notDone_17_108_292_292_5542_561_pointer_572, !noalias !2
        %z_15_106_290_290_5374_562_pointer_573 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 5
        %z_15_106_290_290_5374_562 = load %Reference, ptr %z_15_106_290_290_5374_562_pointer_573, !noalias !2
        %v_r_2574_45_136_320_320_5523_563_pointer_574 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 6
        %v_r_2574_45_136_320_320_5523_563 = load double, ptr %v_r_2574_45_136_320_320_5523_563_pointer_574, !noalias !2
        %zi_5_96_280_280_5410_564_pointer_575 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 7
        %zi_5_96_280_280_5410_564 = load %Reference, ptr %zi_5_96_280_280_5410_564_pointer_575, !noalias !2
        %escape_19_110_294_294_5368_565_pointer_576 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_567, i64 0, i32 8
        %escape_19_110_294_294_5368_565 = load %Reference, ptr %escape_19_110_294_294_5368_565_pointer_576, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_567)
        ret void
}



define tailcc void @returnAddress_333(double %v_r_2574_45_136_320_320_5523, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_334 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_335 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_335, !noalias !2
        %zizi_7_98_282_282_5424_pointer_336 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_336, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_337 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_337, !noalias !2
        %tmp_5760_pointer_338 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_338, !noalias !2
        %notDone_17_108_292_292_5542_pointer_339 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_339, !noalias !2
        %z_15_106_290_290_5374_pointer_340 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_340, !noalias !2
        %zi_5_96_280_280_5410_pointer_341 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_341, !noalias !2
        %escape_19_110_294_294_5368_pointer_342 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_342, !noalias !2
        %stackPointer_577 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 144)
        %tmp_5766_pointer_578 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_578, !noalias !2
        %zizi_7_98_282_282_5424_pointer_579 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_579, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_580 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_580, !noalias !2
        %tmp_5760_pointer_581 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_581, !noalias !2
        %notDone_17_108_292_292_5542_pointer_582 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_582, !noalias !2
        %z_15_106_290_290_5374_pointer_583 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_583, !noalias !2
        %v_r_2574_45_136_320_320_5523_pointer_584 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 6
        store double %v_r_2574_45_136_320_320_5523, ptr %v_r_2574_45_136_320_320_5523_pointer_584, !noalias !2
        %zi_5_96_280_280_5410_pointer_585 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 7
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_585, !noalias !2
        %escape_19_110_294_294_5368_pointer_586 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_577, i64 0, i32 8
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_586, !noalias !2
        %returnAddress_pointer_587 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_577, i64 0, i32 1, i32 0
        %sharer_pointer_588 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_577, i64 0, i32 1, i32 1
        %eraser_pointer_589 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, double, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_577, i64 0, i32 1, i32 2
        store ptr @returnAddress_343, ptr %returnAddress_pointer_587, !noalias !2
        store ptr @sharer_546, ptr %sharer_pointer_588, !noalias !2
        store ptr @eraser_566, ptr %eraser_pointer_589, !noalias !2
        
        %get_5873_pointer_590 = call ccc ptr @getVarPointer(%Reference %zizi_7_98_282_282_5424, %Stack %stack)
        %zizi_7_98_282_282_5424_old_591 = load double, ptr %get_5873_pointer_590, !noalias !2
        %get_5873 = load double, ptr %get_5873_pointer_590, !noalias !2
        
        %stackPointer_593 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_594 = getelementptr %FrameHeader, %StackPointer %stackPointer_593, i64 0, i32 0
        %returnAddress_592 = load %ReturnAddress, ptr %returnAddress_pointer_594, !noalias !2
        musttail call tailcc void %returnAddress_592(double %get_5873, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_323(%Pos %__44_135_319_319_5618, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_324 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_325 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_324, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_325, !noalias !2
        %zizi_7_98_282_282_5424_pointer_326 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_324, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_326, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_327 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_324, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_327, !noalias !2
        %tmp_5760_pointer_328 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_324, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_328, !noalias !2
        %notDone_17_108_292_292_5542_pointer_329 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_324, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_329, !noalias !2
        %z_15_106_290_290_5374_pointer_330 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_324, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_330, !noalias !2
        %zi_5_96_280_280_5410_pointer_331 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_324, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_331, !noalias !2
        %escape_19_110_294_294_5368_pointer_332 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_324, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_332, !noalias !2
        call ccc void @erasePositive(%Pos %__44_135_319_319_5618)
        %stackPointer_611 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_612 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_611, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_612, !noalias !2
        %zizi_7_98_282_282_5424_pointer_613 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_611, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_613, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_614 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_611, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_614, !noalias !2
        %tmp_5760_pointer_615 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_611, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_615, !noalias !2
        %notDone_17_108_292_292_5542_pointer_616 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_611, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_616, !noalias !2
        %z_15_106_290_290_5374_pointer_617 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_611, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_617, !noalias !2
        %zi_5_96_280_280_5410_pointer_618 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_611, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_618, !noalias !2
        %escape_19_110_294_294_5368_pointer_619 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_611, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_619, !noalias !2
        %returnAddress_pointer_620 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_611, i64 0, i32 1, i32 0
        %sharer_pointer_621 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_611, i64 0, i32 1, i32 1
        %eraser_pointer_622 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_611, i64 0, i32 1, i32 2
        store ptr @returnAddress_333, ptr %returnAddress_pointer_620, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_621, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_622, !noalias !2
        
        %get_5874_pointer_623 = call ccc ptr @getVarPointer(%Reference %zrzr_3_94_278_278_5552, %Stack %stack)
        %zrzr_3_94_278_278_5552_old_624 = load double, ptr %get_5874_pointer_623, !noalias !2
        %get_5874 = load double, ptr %get_5874_pointer_623, !noalias !2
        
        %stackPointer_626 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_627 = getelementptr %FrameHeader, %StackPointer %stackPointer_626, i64 0, i32 0
        %returnAddress_625 = load %ReturnAddress, ptr %returnAddress_pointer_627, !noalias !2
        musttail call tailcc void %returnAddress_625(double %get_5874, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_312(double %v_r_2572_42_133_317_317_5311, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_313 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 120)
        %tmp_5766_pointer_314 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_314, !noalias !2
        %zizi_7_98_282_282_5424_pointer_315 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_315, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_316 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_316, !noalias !2
        %v_r_2571_41_132_316_316_5302_pointer_317 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 3
        %v_r_2571_41_132_316_316_5302 = load double, ptr %v_r_2571_41_132_316_316_5302_pointer_317, !noalias !2
        %tmp_5760_pointer_318 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 4
        %tmp_5760 = load double, ptr %tmp_5760_pointer_318, !noalias !2
        %notDone_17_108_292_292_5542_pointer_319 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 5
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_319, !noalias !2
        %z_15_106_290_290_5374_pointer_320 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 6
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_320, !noalias !2
        %zi_5_96_280_280_5410_pointer_321 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 7
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_321, !noalias !2
        %escape_19_110_294_294_5368_pointer_322 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_313, i64 0, i32 8
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_322, !noalias !2
        
        %pureApp_5860 = call ccc double @infixMul_114(double %v_r_2571_41_132_316_316_5302, double %v_r_2572_42_133_317_317_5311)
        
        
        %stackPointer_644 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_645 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_644, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_645, !noalias !2
        %zizi_7_98_282_282_5424_pointer_646 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_644, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_646, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_647 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_644, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_647, !noalias !2
        %tmp_5760_pointer_648 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_644, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_648, !noalias !2
        %notDone_17_108_292_292_5542_pointer_649 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_644, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_649, !noalias !2
        %z_15_106_290_290_5374_pointer_650 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_644, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_650, !noalias !2
        %zi_5_96_280_280_5410_pointer_651 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_644, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_651, !noalias !2
        %escape_19_110_294_294_5368_pointer_652 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_644, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_652, !noalias !2
        %returnAddress_pointer_653 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_644, i64 0, i32 1, i32 0
        %sharer_pointer_654 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_644, i64 0, i32 1, i32 1
        %eraser_pointer_655 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_644, i64 0, i32 1, i32 2
        store ptr @returnAddress_323, ptr %returnAddress_pointer_653, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_654, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_655, !noalias !2
        
        %zizi_7_98_282_282_5424pointer_656 = call ccc ptr @getVarPointer(%Reference %zizi_7_98_282_282_5424, %Stack %stack)
        %zizi_7_98_282_282_5424_old_657 = load double, ptr %zizi_7_98_282_282_5424pointer_656, !noalias !2
        store double %pureApp_5860, ptr %zizi_7_98_282_282_5424pointer_656, !noalias !2
        
        %put_5875_temporary_658 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5875 = insertvalue %Pos %put_5875_temporary_658, %Object null, 1
        
        %stackPointer_660 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_661 = getelementptr %FrameHeader, %StackPointer %stackPointer_660, i64 0, i32 0
        %returnAddress_659 = load %ReturnAddress, ptr %returnAddress_pointer_661, !noalias !2
        musttail call tailcc void %returnAddress_659(%Pos %put_5875, %Stack %stack)
        ret void
}



define ccc void @sharer_671(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_672 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_662_pointer_673 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 0
        %tmp_5766_662 = load double, ptr %tmp_5766_662_pointer_673, !noalias !2
        %zizi_7_98_282_282_5424_663_pointer_674 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 1
        %zizi_7_98_282_282_5424_663 = load %Reference, ptr %zizi_7_98_282_282_5424_663_pointer_674, !noalias !2
        %zrzr_3_94_278_278_5552_664_pointer_675 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 2
        %zrzr_3_94_278_278_5552_664 = load %Reference, ptr %zrzr_3_94_278_278_5552_664_pointer_675, !noalias !2
        %v_r_2571_41_132_316_316_5302_665_pointer_676 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 3
        %v_r_2571_41_132_316_316_5302_665 = load double, ptr %v_r_2571_41_132_316_316_5302_665_pointer_676, !noalias !2
        %tmp_5760_666_pointer_677 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 4
        %tmp_5760_666 = load double, ptr %tmp_5760_666_pointer_677, !noalias !2
        %notDone_17_108_292_292_5542_667_pointer_678 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 5
        %notDone_17_108_292_292_5542_667 = load %Reference, ptr %notDone_17_108_292_292_5542_667_pointer_678, !noalias !2
        %z_15_106_290_290_5374_668_pointer_679 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 6
        %z_15_106_290_290_5374_668 = load %Reference, ptr %z_15_106_290_290_5374_668_pointer_679, !noalias !2
        %zi_5_96_280_280_5410_669_pointer_680 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 7
        %zi_5_96_280_280_5410_669 = load %Reference, ptr %zi_5_96_280_280_5410_669_pointer_680, !noalias !2
        %escape_19_110_294_294_5368_670_pointer_681 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 8
        %escape_19_110_294_294_5368_670 = load %Reference, ptr %escape_19_110_294_294_5368_670_pointer_681, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_672)
        ret void
}



define ccc void @eraser_691(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_692 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_682_pointer_693 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 0
        %tmp_5766_682 = load double, ptr %tmp_5766_682_pointer_693, !noalias !2
        %zizi_7_98_282_282_5424_683_pointer_694 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 1
        %zizi_7_98_282_282_5424_683 = load %Reference, ptr %zizi_7_98_282_282_5424_683_pointer_694, !noalias !2
        %zrzr_3_94_278_278_5552_684_pointer_695 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 2
        %zrzr_3_94_278_278_5552_684 = load %Reference, ptr %zrzr_3_94_278_278_5552_684_pointer_695, !noalias !2
        %v_r_2571_41_132_316_316_5302_685_pointer_696 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 3
        %v_r_2571_41_132_316_316_5302_685 = load double, ptr %v_r_2571_41_132_316_316_5302_685_pointer_696, !noalias !2
        %tmp_5760_686_pointer_697 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 4
        %tmp_5760_686 = load double, ptr %tmp_5760_686_pointer_697, !noalias !2
        %notDone_17_108_292_292_5542_687_pointer_698 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 5
        %notDone_17_108_292_292_5542_687 = load %Reference, ptr %notDone_17_108_292_292_5542_687_pointer_698, !noalias !2
        %z_15_106_290_290_5374_688_pointer_699 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 6
        %z_15_106_290_290_5374_688 = load %Reference, ptr %z_15_106_290_290_5374_688_pointer_699, !noalias !2
        %zi_5_96_280_280_5410_689_pointer_700 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 7
        %zi_5_96_280_280_5410_689 = load %Reference, ptr %zi_5_96_280_280_5410_689_pointer_700, !noalias !2
        %escape_19_110_294_294_5368_690_pointer_701 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_692, i64 0, i32 8
        %escape_19_110_294_294_5368_690 = load %Reference, ptr %escape_19_110_294_294_5368_690_pointer_701, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_692)
        ret void
}



define tailcc void @returnAddress_302(double %v_r_2571_41_132_316_316_5302, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_303 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_304 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_303, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_304, !noalias !2
        %zizi_7_98_282_282_5424_pointer_305 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_303, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_305, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_306 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_303, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_306, !noalias !2
        %tmp_5760_pointer_307 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_303, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_307, !noalias !2
        %notDone_17_108_292_292_5542_pointer_308 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_303, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_308, !noalias !2
        %z_15_106_290_290_5374_pointer_309 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_303, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_309, !noalias !2
        %zi_5_96_280_280_5410_pointer_310 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_303, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_310, !noalias !2
        %escape_19_110_294_294_5368_pointer_311 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_303, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_311, !noalias !2
        %stackPointer_702 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 144)
        %tmp_5766_pointer_703 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_703, !noalias !2
        %zizi_7_98_282_282_5424_pointer_704 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_704, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_705 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_705, !noalias !2
        %v_r_2571_41_132_316_316_5302_pointer_706 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 3
        store double %v_r_2571_41_132_316_316_5302, ptr %v_r_2571_41_132_316_316_5302_pointer_706, !noalias !2
        %tmp_5760_pointer_707 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 4
        store double %tmp_5760, ptr %tmp_5760_pointer_707, !noalias !2
        %notDone_17_108_292_292_5542_pointer_708 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 5
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_708, !noalias !2
        %z_15_106_290_290_5374_pointer_709 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 6
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_709, !noalias !2
        %zi_5_96_280_280_5410_pointer_710 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 7
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_710, !noalias !2
        %escape_19_110_294_294_5368_pointer_711 = getelementptr <{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_702, i64 0, i32 8
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_711, !noalias !2
        %returnAddress_pointer_712 = getelementptr <{<{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_702, i64 0, i32 1, i32 0
        %sharer_pointer_713 = getelementptr <{<{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_702, i64 0, i32 1, i32 1
        %eraser_pointer_714 = getelementptr <{<{double, %Reference, %Reference, double, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_702, i64 0, i32 1, i32 2
        store ptr @returnAddress_312, ptr %returnAddress_pointer_712, !noalias !2
        store ptr @sharer_671, ptr %sharer_pointer_713, !noalias !2
        store ptr @eraser_691, ptr %eraser_pointer_714, !noalias !2
        
        %get_5876_pointer_715 = call ccc ptr @getVarPointer(%Reference %zi_5_96_280_280_5410, %Stack %stack)
        %zi_5_96_280_280_5410_old_716 = load double, ptr %get_5876_pointer_715, !noalias !2
        %get_5876 = load double, ptr %get_5876_pointer_715, !noalias !2
        
        %stackPointer_718 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_719 = getelementptr %FrameHeader, %StackPointer %stackPointer_718, i64 0, i32 0
        %returnAddress_717 = load %ReturnAddress, ptr %returnAddress_pointer_719, !noalias !2
        musttail call tailcc void %returnAddress_717(double %get_5876, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_292(%Pos %__40_131_315_315_5617, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_293 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_294 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_294, !noalias !2
        %zizi_7_98_282_282_5424_pointer_295 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_295, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_296 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_296, !noalias !2
        %tmp_5760_pointer_297 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_297, !noalias !2
        %notDone_17_108_292_292_5542_pointer_298 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_298, !noalias !2
        %z_15_106_290_290_5374_pointer_299 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_299, !noalias !2
        %zi_5_96_280_280_5410_pointer_300 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_300, !noalias !2
        %escape_19_110_294_294_5368_pointer_301 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_301, !noalias !2
        call ccc void @erasePositive(%Pos %__40_131_315_315_5617)
        %stackPointer_736 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_737 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_736, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_737, !noalias !2
        %zizi_7_98_282_282_5424_pointer_738 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_736, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_738, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_739 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_736, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_739, !noalias !2
        %tmp_5760_pointer_740 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_736, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_740, !noalias !2
        %notDone_17_108_292_292_5542_pointer_741 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_736, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_741, !noalias !2
        %z_15_106_290_290_5374_pointer_742 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_736, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_742, !noalias !2
        %zi_5_96_280_280_5410_pointer_743 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_736, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_743, !noalias !2
        %escape_19_110_294_294_5368_pointer_744 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_736, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_744, !noalias !2
        %returnAddress_pointer_745 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_736, i64 0, i32 1, i32 0
        %sharer_pointer_746 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_736, i64 0, i32 1, i32 1
        %eraser_pointer_747 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_736, i64 0, i32 1, i32 2
        store ptr @returnAddress_302, ptr %returnAddress_pointer_745, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_746, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_747, !noalias !2
        
        %get_5877_pointer_748 = call ccc ptr @getVarPointer(%Reference %zi_5_96_280_280_5410, %Stack %stack)
        %zi_5_96_280_280_5410_old_749 = load double, ptr %get_5877_pointer_748, !noalias !2
        %get_5877 = load double, ptr %get_5877_pointer_748, !noalias !2
        
        %stackPointer_751 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_752 = getelementptr %FrameHeader, %StackPointer %stackPointer_751, i64 0, i32 0
        %returnAddress_750 = load %ReturnAddress, ptr %returnAddress_pointer_752, !noalias !2
        musttail call tailcc void %returnAddress_750(double %get_5877, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_281(%Pos %__38_129_313_313_5616, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_282 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 120)
        %tmp_5766_pointer_283 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_283, !noalias !2
        %zizi_7_98_282_282_5424_pointer_284 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_284, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_285 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_285, !noalias !2
        %tmp_5760_pointer_286 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_286, !noalias !2
        %notDone_17_108_292_292_5542_pointer_287 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_287, !noalias !2
        %z_15_106_290_290_5374_pointer_288 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_288, !noalias !2
        %zi_5_96_280_280_5410_pointer_289 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_289, !noalias !2
        %tmp_5769_pointer_290 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 7
        %tmp_5769 = load double, ptr %tmp_5769_pointer_290, !noalias !2
        %escape_19_110_294_294_5368_pointer_291 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_282, i64 0, i32 8
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_291, !noalias !2
        call ccc void @erasePositive(%Pos %__38_129_313_313_5616)
        
        %pureApp_5859 = call ccc double @infixMul_114(double %tmp_5769, double %tmp_5769)
        
        
        %stackPointer_769 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_770 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_769, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_770, !noalias !2
        %zizi_7_98_282_282_5424_pointer_771 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_769, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_771, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_772 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_769, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_772, !noalias !2
        %tmp_5760_pointer_773 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_769, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_773, !noalias !2
        %notDone_17_108_292_292_5542_pointer_774 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_769, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_774, !noalias !2
        %z_15_106_290_290_5374_pointer_775 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_769, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_775, !noalias !2
        %zi_5_96_280_280_5410_pointer_776 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_769, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_776, !noalias !2
        %escape_19_110_294_294_5368_pointer_777 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_769, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_777, !noalias !2
        %returnAddress_pointer_778 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_769, i64 0, i32 1, i32 0
        %sharer_pointer_779 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_769, i64 0, i32 1, i32 1
        %eraser_pointer_780 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_769, i64 0, i32 1, i32 2
        store ptr @returnAddress_292, ptr %returnAddress_pointer_778, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_779, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_780, !noalias !2
        
        %zrzr_3_94_278_278_5552pointer_781 = call ccc ptr @getVarPointer(%Reference %zrzr_3_94_278_278_5552, %Stack %stack)
        %zrzr_3_94_278_278_5552_old_782 = load double, ptr %zrzr_3_94_278_278_5552pointer_781, !noalias !2
        store double %pureApp_5859, ptr %zrzr_3_94_278_278_5552pointer_781, !noalias !2
        
        %put_5878_temporary_783 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5878 = insertvalue %Pos %put_5878_temporary_783, %Object null, 1
        
        %stackPointer_785 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_786 = getelementptr %FrameHeader, %StackPointer %stackPointer_785, i64 0, i32 0
        %returnAddress_784 = load %ReturnAddress, ptr %returnAddress_pointer_786, !noalias !2
        musttail call tailcc void %returnAddress_784(%Pos %put_5878, %Stack %stack)
        ret void
}



define ccc void @sharer_796(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_797 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_787_pointer_798 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 0
        %tmp_5766_787 = load double, ptr %tmp_5766_787_pointer_798, !noalias !2
        %zizi_7_98_282_282_5424_788_pointer_799 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 1
        %zizi_7_98_282_282_5424_788 = load %Reference, ptr %zizi_7_98_282_282_5424_788_pointer_799, !noalias !2
        %zrzr_3_94_278_278_5552_789_pointer_800 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 2
        %zrzr_3_94_278_278_5552_789 = load %Reference, ptr %zrzr_3_94_278_278_5552_789_pointer_800, !noalias !2
        %tmp_5760_790_pointer_801 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 3
        %tmp_5760_790 = load double, ptr %tmp_5760_790_pointer_801, !noalias !2
        %notDone_17_108_292_292_5542_791_pointer_802 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 4
        %notDone_17_108_292_292_5542_791 = load %Reference, ptr %notDone_17_108_292_292_5542_791_pointer_802, !noalias !2
        %z_15_106_290_290_5374_792_pointer_803 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 5
        %z_15_106_290_290_5374_792 = load %Reference, ptr %z_15_106_290_290_5374_792_pointer_803, !noalias !2
        %zi_5_96_280_280_5410_793_pointer_804 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 6
        %zi_5_96_280_280_5410_793 = load %Reference, ptr %zi_5_96_280_280_5410_793_pointer_804, !noalias !2
        %tmp_5769_794_pointer_805 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 7
        %tmp_5769_794 = load double, ptr %tmp_5769_794_pointer_805, !noalias !2
        %escape_19_110_294_294_5368_795_pointer_806 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_797, i64 0, i32 8
        %escape_19_110_294_294_5368_795 = load %Reference, ptr %escape_19_110_294_294_5368_795_pointer_806, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_797)
        ret void
}



define ccc void @eraser_816(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_817 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_807_pointer_818 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 0
        %tmp_5766_807 = load double, ptr %tmp_5766_807_pointer_818, !noalias !2
        %zizi_7_98_282_282_5424_808_pointer_819 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 1
        %zizi_7_98_282_282_5424_808 = load %Reference, ptr %zizi_7_98_282_282_5424_808_pointer_819, !noalias !2
        %zrzr_3_94_278_278_5552_809_pointer_820 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 2
        %zrzr_3_94_278_278_5552_809 = load %Reference, ptr %zrzr_3_94_278_278_5552_809_pointer_820, !noalias !2
        %tmp_5760_810_pointer_821 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 3
        %tmp_5760_810 = load double, ptr %tmp_5760_810_pointer_821, !noalias !2
        %notDone_17_108_292_292_5542_811_pointer_822 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 4
        %notDone_17_108_292_292_5542_811 = load %Reference, ptr %notDone_17_108_292_292_5542_811_pointer_822, !noalias !2
        %z_15_106_290_290_5374_812_pointer_823 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 5
        %z_15_106_290_290_5374_812 = load %Reference, ptr %z_15_106_290_290_5374_812_pointer_823, !noalias !2
        %zi_5_96_280_280_5410_813_pointer_824 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 6
        %zi_5_96_280_280_5410_813 = load %Reference, ptr %zi_5_96_280_280_5410_813_pointer_824, !noalias !2
        %tmp_5769_814_pointer_825 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 7
        %tmp_5769_814 = load double, ptr %tmp_5769_814_pointer_825, !noalias !2
        %escape_19_110_294_294_5368_815_pointer_826 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_817, i64 0, i32 8
        %escape_19_110_294_294_5368_815 = load %Reference, ptr %escape_19_110_294_294_5368_815_pointer_826, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_817)
        ret void
}



define tailcc void @returnAddress_270(double %v_r_2568_34_125_309_309_5432, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_271 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 120)
        %tmp_5766_pointer_272 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_272, !noalias !2
        %zizi_7_98_282_282_5424_pointer_273 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_273, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_274 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_274, !noalias !2
        %tmp_5760_pointer_275 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_275, !noalias !2
        %notDone_17_108_292_292_5542_pointer_276 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_276, !noalias !2
        %z_15_106_290_290_5374_pointer_277 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_277, !noalias !2
        %zi_5_96_280_280_5410_pointer_278 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_278, !noalias !2
        %tmp_5769_pointer_279 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 7
        %tmp_5769 = load double, ptr %tmp_5769_pointer_279, !noalias !2
        %escape_19_110_294_294_5368_pointer_280 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_271, i64 0, i32 8
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_280, !noalias !2
        
        %doubleLiteral_5856 = fadd double 2.0, 0.0
        
        %pureApp_5855 = call ccc double @infixMul_114(double %doubleLiteral_5856, double %tmp_5769)
        
        
        
        %pureApp_5857 = call ccc double @infixMul_114(double %pureApp_5855, double %v_r_2568_34_125_309_309_5432)
        
        
        
        %pureApp_5858 = call ccc double @infixAdd_111(double %pureApp_5857, double %tmp_5760)
        
        
        %stackPointer_827 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 144)
        %tmp_5766_pointer_828 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_828, !noalias !2
        %zizi_7_98_282_282_5424_pointer_829 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_829, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_830 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_830, !noalias !2
        %tmp_5760_pointer_831 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_831, !noalias !2
        %notDone_17_108_292_292_5542_pointer_832 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_832, !noalias !2
        %z_15_106_290_290_5374_pointer_833 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_833, !noalias !2
        %zi_5_96_280_280_5410_pointer_834 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_834, !noalias !2
        %tmp_5769_pointer_835 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 7
        store double %tmp_5769, ptr %tmp_5769_pointer_835, !noalias !2
        %escape_19_110_294_294_5368_pointer_836 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_827, i64 0, i32 8
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_836, !noalias !2
        %returnAddress_pointer_837 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_827, i64 0, i32 1, i32 0
        %sharer_pointer_838 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_827, i64 0, i32 1, i32 1
        %eraser_pointer_839 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_827, i64 0, i32 1, i32 2
        store ptr @returnAddress_281, ptr %returnAddress_pointer_837, !noalias !2
        store ptr @sharer_796, ptr %sharer_pointer_838, !noalias !2
        store ptr @eraser_816, ptr %eraser_pointer_839, !noalias !2
        
        %zi_5_96_280_280_5410pointer_840 = call ccc ptr @getVarPointer(%Reference %zi_5_96_280_280_5410, %Stack %stack)
        %zi_5_96_280_280_5410_old_841 = load double, ptr %zi_5_96_280_280_5410pointer_840, !noalias !2
        store double %pureApp_5858, ptr %zi_5_96_280_280_5410pointer_840, !noalias !2
        
        %put_5879_temporary_842 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5879 = insertvalue %Pos %put_5879_temporary_842, %Object null, 1
        
        %stackPointer_844 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_845 = getelementptr %FrameHeader, %StackPointer %stackPointer_844, i64 0, i32 0
        %returnAddress_843 = load %ReturnAddress, ptr %returnAddress_pointer_845, !noalias !2
        musttail call tailcc void %returnAddress_843(%Pos %put_5879, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_259(double %v_r_2567_30_121_305_305_5293, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_260 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 120)
        %tmp_5766_pointer_261 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_261, !noalias !2
        %zizi_7_98_282_282_5424_pointer_262 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_262, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_263 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_263, !noalias !2
        %tmp_5760_pointer_264 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_264, !noalias !2
        %notDone_17_108_292_292_5542_pointer_265 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_265, !noalias !2
        %z_15_106_290_290_5374_pointer_266 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_266, !noalias !2
        %zi_5_96_280_280_5410_pointer_267 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_267, !noalias !2
        %escape_19_110_294_294_5368_pointer_268 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_268, !noalias !2
        %v_r_2566_29_120_304_304_5353_pointer_269 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_260, i64 0, i32 8
        %v_r_2566_29_120_304_304_5353 = load double, ptr %v_r_2566_29_120_304_304_5353_pointer_269, !noalias !2
        
        %pureApp_5853 = call ccc double @infixSub_117(double %v_r_2566_29_120_304_304_5353, double %v_r_2567_30_121_305_305_5293)
        
        
        
        %pureApp_5854 = call ccc double @infixAdd_111(double %pureApp_5853, double %tmp_5766)
        
        
        %stackPointer_864 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 144)
        %tmp_5766_pointer_865 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_865, !noalias !2
        %zizi_7_98_282_282_5424_pointer_866 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_866, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_867 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_867, !noalias !2
        %tmp_5760_pointer_868 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_868, !noalias !2
        %notDone_17_108_292_292_5542_pointer_869 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_869, !noalias !2
        %z_15_106_290_290_5374_pointer_870 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_870, !noalias !2
        %zi_5_96_280_280_5410_pointer_871 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_871, !noalias !2
        %tmp_5769_pointer_872 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 7
        store double %pureApp_5854, ptr %tmp_5769_pointer_872, !noalias !2
        %escape_19_110_294_294_5368_pointer_873 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_864, i64 0, i32 8
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_873, !noalias !2
        %returnAddress_pointer_874 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_864, i64 0, i32 1, i32 0
        %sharer_pointer_875 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_864, i64 0, i32 1, i32 1
        %eraser_pointer_876 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_864, i64 0, i32 1, i32 2
        store ptr @returnAddress_270, ptr %returnAddress_pointer_874, !noalias !2
        store ptr @sharer_796, ptr %sharer_pointer_875, !noalias !2
        store ptr @eraser_816, ptr %eraser_pointer_876, !noalias !2
        
        %get_5880_pointer_877 = call ccc ptr @getVarPointer(%Reference %zi_5_96_280_280_5410, %Stack %stack)
        %zi_5_96_280_280_5410_old_878 = load double, ptr %get_5880_pointer_877, !noalias !2
        %get_5880 = load double, ptr %get_5880_pointer_877, !noalias !2
        
        %stackPointer_880 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_881 = getelementptr %FrameHeader, %StackPointer %stackPointer_880, i64 0, i32 0
        %returnAddress_879 = load %ReturnAddress, ptr %returnAddress_pointer_881, !noalias !2
        musttail call tailcc void %returnAddress_879(double %get_5880, %Stack %stack)
        ret void
}



define ccc void @sharer_891(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_892 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_882_pointer_893 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 0
        %tmp_5766_882 = load double, ptr %tmp_5766_882_pointer_893, !noalias !2
        %zizi_7_98_282_282_5424_883_pointer_894 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 1
        %zizi_7_98_282_282_5424_883 = load %Reference, ptr %zizi_7_98_282_282_5424_883_pointer_894, !noalias !2
        %zrzr_3_94_278_278_5552_884_pointer_895 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 2
        %zrzr_3_94_278_278_5552_884 = load %Reference, ptr %zrzr_3_94_278_278_5552_884_pointer_895, !noalias !2
        %tmp_5760_885_pointer_896 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 3
        %tmp_5760_885 = load double, ptr %tmp_5760_885_pointer_896, !noalias !2
        %notDone_17_108_292_292_5542_886_pointer_897 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 4
        %notDone_17_108_292_292_5542_886 = load %Reference, ptr %notDone_17_108_292_292_5542_886_pointer_897, !noalias !2
        %z_15_106_290_290_5374_887_pointer_898 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 5
        %z_15_106_290_290_5374_887 = load %Reference, ptr %z_15_106_290_290_5374_887_pointer_898, !noalias !2
        %zi_5_96_280_280_5410_888_pointer_899 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 6
        %zi_5_96_280_280_5410_888 = load %Reference, ptr %zi_5_96_280_280_5410_888_pointer_899, !noalias !2
        %escape_19_110_294_294_5368_889_pointer_900 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 7
        %escape_19_110_294_294_5368_889 = load %Reference, ptr %escape_19_110_294_294_5368_889_pointer_900, !noalias !2
        %v_r_2566_29_120_304_304_5353_890_pointer_901 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_892, i64 0, i32 8
        %v_r_2566_29_120_304_304_5353_890 = load double, ptr %v_r_2566_29_120_304_304_5353_890_pointer_901, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_892)
        ret void
}



define ccc void @eraser_911(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_912 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer, i64 -1
        %tmp_5766_902_pointer_913 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 0
        %tmp_5766_902 = load double, ptr %tmp_5766_902_pointer_913, !noalias !2
        %zizi_7_98_282_282_5424_903_pointer_914 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 1
        %zizi_7_98_282_282_5424_903 = load %Reference, ptr %zizi_7_98_282_282_5424_903_pointer_914, !noalias !2
        %zrzr_3_94_278_278_5552_904_pointer_915 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 2
        %zrzr_3_94_278_278_5552_904 = load %Reference, ptr %zrzr_3_94_278_278_5552_904_pointer_915, !noalias !2
        %tmp_5760_905_pointer_916 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 3
        %tmp_5760_905 = load double, ptr %tmp_5760_905_pointer_916, !noalias !2
        %notDone_17_108_292_292_5542_906_pointer_917 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 4
        %notDone_17_108_292_292_5542_906 = load %Reference, ptr %notDone_17_108_292_292_5542_906_pointer_917, !noalias !2
        %z_15_106_290_290_5374_907_pointer_918 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 5
        %z_15_106_290_290_5374_907 = load %Reference, ptr %z_15_106_290_290_5374_907_pointer_918, !noalias !2
        %zi_5_96_280_280_5410_908_pointer_919 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 6
        %zi_5_96_280_280_5410_908 = load %Reference, ptr %zi_5_96_280_280_5410_908_pointer_919, !noalias !2
        %escape_19_110_294_294_5368_909_pointer_920 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 7
        %escape_19_110_294_294_5368_909 = load %Reference, ptr %escape_19_110_294_294_5368_909_pointer_920, !noalias !2
        %v_r_2566_29_120_304_304_5353_910_pointer_921 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_912, i64 0, i32 8
        %v_r_2566_29_120_304_304_5353_910 = load double, ptr %v_r_2566_29_120_304_304_5353_910_pointer_921, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_912)
        ret void
}



define tailcc void @returnAddress_249(double %v_r_2566_29_120_304_304_5353, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_250 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_251 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_250, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_251, !noalias !2
        %zizi_7_98_282_282_5424_pointer_252 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_250, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_252, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_253 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_250, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_253, !noalias !2
        %tmp_5760_pointer_254 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_250, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_254, !noalias !2
        %notDone_17_108_292_292_5542_pointer_255 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_250, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_255, !noalias !2
        %z_15_106_290_290_5374_pointer_256 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_250, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_256, !noalias !2
        %zi_5_96_280_280_5410_pointer_257 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_250, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_257, !noalias !2
        %escape_19_110_294_294_5368_pointer_258 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_250, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_258, !noalias !2
        %stackPointer_922 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 144)
        %tmp_5766_pointer_923 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_923, !noalias !2
        %zizi_7_98_282_282_5424_pointer_924 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_924, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_925 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_925, !noalias !2
        %tmp_5760_pointer_926 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_926, !noalias !2
        %notDone_17_108_292_292_5542_pointer_927 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_927, !noalias !2
        %z_15_106_290_290_5374_pointer_928 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_928, !noalias !2
        %zi_5_96_280_280_5410_pointer_929 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_929, !noalias !2
        %escape_19_110_294_294_5368_pointer_930 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_930, !noalias !2
        %v_r_2566_29_120_304_304_5353_pointer_931 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %StackPointer %stackPointer_922, i64 0, i32 8
        store double %v_r_2566_29_120_304_304_5353, ptr %v_r_2566_29_120_304_304_5353_pointer_931, !noalias !2
        %returnAddress_pointer_932 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %FrameHeader}>, %StackPointer %stackPointer_922, i64 0, i32 1, i32 0
        %sharer_pointer_933 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %FrameHeader}>, %StackPointer %stackPointer_922, i64 0, i32 1, i32 1
        %eraser_pointer_934 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference, double}>, %FrameHeader}>, %StackPointer %stackPointer_922, i64 0, i32 1, i32 2
        store ptr @returnAddress_259, ptr %returnAddress_pointer_932, !noalias !2
        store ptr @sharer_891, ptr %sharer_pointer_933, !noalias !2
        store ptr @eraser_911, ptr %eraser_pointer_934, !noalias !2
        
        %get_5881_pointer_935 = call ccc ptr @getVarPointer(%Reference %zizi_7_98_282_282_5424, %Stack %stack)
        %zizi_7_98_282_282_5424_old_936 = load double, ptr %get_5881_pointer_935, !noalias !2
        %get_5881 = load double, ptr %get_5881_pointer_935, !noalias !2
        
        %stackPointer_938 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_939 = getelementptr %FrameHeader, %StackPointer %stackPointer_938, i64 0, i32 0
        %returnAddress_937 = load %ReturnAddress, ptr %returnAddress_pointer_939, !noalias !2
        musttail call tailcc void %returnAddress_937(double %get_5881, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_231(%Pos %v_r_2584_28_119_303_303_5530, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_232 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_233 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_232, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_233, !noalias !2
        %zizi_7_98_282_282_5424_pointer_234 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_232, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_234, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_235 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_232, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_235, !noalias !2
        %tmp_5760_pointer_236 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_232, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_236, !noalias !2
        %notDone_17_108_292_292_5542_pointer_237 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_232, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_237, !noalias !2
        %z_15_106_290_290_5374_pointer_238 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_232, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_238, !noalias !2
        %zi_5_96_280_280_5410_pointer_239 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_232, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_239, !noalias !2
        %escape_19_110_294_294_5368_pointer_240 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_232, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_240, !noalias !2
        
        %tag_241 = extractvalue %Pos %v_r_2584_28_119_303_303_5530, 0
        %fields_242 = extractvalue %Pos %v_r_2584_28_119_303_303_5530, 1
        switch i64 %tag_241, label %label_243 [i64 0, label %label_248 i64 1, label %label_973]
    
    label_243:
        
        ret void
    
    label_248:
        
        %unitLiteral_5852_temporary_244 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5852 = insertvalue %Pos %unitLiteral_5852_temporary_244, %Object null, 1
        
        %stackPointer_246 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_247 = getelementptr %FrameHeader, %StackPointer %stackPointer_246, i64 0, i32 0
        %returnAddress_245 = load %ReturnAddress, ptr %returnAddress_pointer_247, !noalias !2
        musttail call tailcc void %returnAddress_245(%Pos %unitLiteral_5852, %Stack %stack)
        ret void
    
    label_973:
        %stackPointer_956 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_957 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_956, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_957, !noalias !2
        %zizi_7_98_282_282_5424_pointer_958 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_956, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_958, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_959 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_956, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_959, !noalias !2
        %tmp_5760_pointer_960 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_956, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_960, !noalias !2
        %notDone_17_108_292_292_5542_pointer_961 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_956, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_961, !noalias !2
        %z_15_106_290_290_5374_pointer_962 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_956, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_962, !noalias !2
        %zi_5_96_280_280_5410_pointer_963 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_956, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_963, !noalias !2
        %escape_19_110_294_294_5368_pointer_964 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_956, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_964, !noalias !2
        %returnAddress_pointer_965 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_956, i64 0, i32 1, i32 0
        %sharer_pointer_966 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_956, i64 0, i32 1, i32 1
        %eraser_pointer_967 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_956, i64 0, i32 1, i32 2
        store ptr @returnAddress_249, ptr %returnAddress_pointer_965, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_966, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_967, !noalias !2
        
        %get_5882_pointer_968 = call ccc ptr @getVarPointer(%Reference %zrzr_3_94_278_278_5552, %Stack %stack)
        %zrzr_3_94_278_278_5552_old_969 = load double, ptr %get_5882_pointer_968, !noalias !2
        %get_5882 = load double, ptr %get_5882_pointer_968, !noalias !2
        
        %stackPointer_971 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_972 = getelementptr %FrameHeader, %StackPointer %stackPointer_971, i64 0, i32 0
        %returnAddress_970 = load %ReturnAddress, ptr %returnAddress_pointer_972, !noalias !2
        musttail call tailcc void %returnAddress_970(double %get_5882, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1010(i64 %v_r_2583_1_26_117_301_301_5555, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5885 = add i64 50, 0
        
        %pureApp_5884 = call ccc %Pos @infixLt_178(i64 %v_r_2583_1_26_117_301_301_5555, i64 %longLiteral_5885)
        
        
        
        %stackPointer_1012 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1013 = getelementptr %FrameHeader, %StackPointer %stackPointer_1012, i64 0, i32 0
        %returnAddress_1011 = load %ReturnAddress, ptr %returnAddress_pointer_1013, !noalias !2
        musttail call tailcc void %returnAddress_1011(%Pos %pureApp_5884, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_221(%Pos %v_r_3474_5_25_116_300_300_5494, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_222 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 112)
        %tmp_5766_pointer_223 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_222, i64 0, i32 0
        %tmp_5766 = load double, ptr %tmp_5766_pointer_223, !noalias !2
        %zizi_7_98_282_282_5424_pointer_224 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_222, i64 0, i32 1
        %zizi_7_98_282_282_5424 = load %Reference, ptr %zizi_7_98_282_282_5424_pointer_224, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_225 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_222, i64 0, i32 2
        %zrzr_3_94_278_278_5552 = load %Reference, ptr %zrzr_3_94_278_278_5552_pointer_225, !noalias !2
        %tmp_5760_pointer_226 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_222, i64 0, i32 3
        %tmp_5760 = load double, ptr %tmp_5760_pointer_226, !noalias !2
        %notDone_17_108_292_292_5542_pointer_227 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_222, i64 0, i32 4
        %notDone_17_108_292_292_5542 = load %Reference, ptr %notDone_17_108_292_292_5542_pointer_227, !noalias !2
        %z_15_106_290_290_5374_pointer_228 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_222, i64 0, i32 5
        %z_15_106_290_290_5374 = load %Reference, ptr %z_15_106_290_290_5374_pointer_228, !noalias !2
        %zi_5_96_280_280_5410_pointer_229 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_222, i64 0, i32 6
        %zi_5_96_280_280_5410 = load %Reference, ptr %zi_5_96_280_280_5410_pointer_229, !noalias !2
        %escape_19_110_294_294_5368_pointer_230 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_222, i64 0, i32 7
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_230, !noalias !2
        %stackPointer_990 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_991 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_990, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_991, !noalias !2
        %zizi_7_98_282_282_5424_pointer_992 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_990, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_992, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_993 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_990, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_993, !noalias !2
        %tmp_5760_pointer_994 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_990, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_994, !noalias !2
        %notDone_17_108_292_292_5542_pointer_995 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_990, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_995, !noalias !2
        %z_15_106_290_290_5374_pointer_996 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_990, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_996, !noalias !2
        %zi_5_96_280_280_5410_pointer_997 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_990, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_997, !noalias !2
        %escape_19_110_294_294_5368_pointer_998 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_990, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_998, !noalias !2
        %returnAddress_pointer_999 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_990, i64 0, i32 1, i32 0
        %sharer_pointer_1000 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_990, i64 0, i32 1, i32 1
        %eraser_pointer_1001 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_990, i64 0, i32 1, i32 2
        store ptr @returnAddress_231, ptr %returnAddress_pointer_999, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_1000, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_1001, !noalias !2
        
        %tag_1002 = extractvalue %Pos %v_r_3474_5_25_116_300_300_5494, 0
        %fields_1003 = extractvalue %Pos %v_r_3474_5_25_116_300_300_5494, 1
        switch i64 %tag_1002, label %label_1004 [i64 0, label %label_1009 i64 1, label %label_1023]
    
    label_1004:
        
        ret void
    
    label_1009:
        
        %booleanLiteral_5883_temporary_1005 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_5883 = insertvalue %Pos %booleanLiteral_5883_temporary_1005, %Object null, 1
        
        %stackPointer_1007 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1008 = getelementptr %FrameHeader, %StackPointer %stackPointer_1007, i64 0, i32 0
        %returnAddress_1006 = load %ReturnAddress, ptr %returnAddress_pointer_1008, !noalias !2
        musttail call tailcc void %returnAddress_1006(%Pos %booleanLiteral_5883, %Stack %stack)
        ret void
    
    label_1023:
        %stackPointer_1014 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1015 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1014, i64 0, i32 1, i32 0
        %sharer_pointer_1016 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1014, i64 0, i32 1, i32 1
        %eraser_pointer_1017 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1014, i64 0, i32 1, i32 2
        store ptr @returnAddress_1010, ptr %returnAddress_pointer_1015, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_1016, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_1017, !noalias !2
        
        %get_5886_pointer_1018 = call ccc ptr @getVarPointer(%Reference %z_15_106_290_290_5374, %Stack %stack)
        %z_15_106_290_290_5374_old_1019 = load i64, ptr %get_5886_pointer_1018, !noalias !2
        %get_5886 = load i64, ptr %get_5886_pointer_1018, !noalias !2
        
        %stackPointer_1021 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1022 = getelementptr %FrameHeader, %StackPointer %stackPointer_1021, i64 0, i32 0
        %returnAddress_1020 = load %ReturnAddress, ptr %returnAddress_pointer_1022, !noalias !2
        musttail call tailcc void %returnAddress_1020(i64 %get_5886, %Stack %stack)
        ret void
}



define tailcc void @b_whileLoop_2565_20_111_295_295_5509(double %tmp_5766, %Reference %zizi_7_98_282_282_5424, %Reference %zrzr_3_94_278_278_5552, double %tmp_5760, %Reference %notDone_17_108_292_292_5542, %Reference %z_15_106_290_290_5374, %Reference %zi_5_96_280_280_5410, %Reference %escape_19_110_294_294_5368, %Stack %stack) {
        
    entry:
        
        %stackPointer_1040 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 136)
        %tmp_5766_pointer_1041 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1040, i64 0, i32 0
        store double %tmp_5766, ptr %tmp_5766_pointer_1041, !noalias !2
        %zizi_7_98_282_282_5424_pointer_1042 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1040, i64 0, i32 1
        store %Reference %zizi_7_98_282_282_5424, ptr %zizi_7_98_282_282_5424_pointer_1042, !noalias !2
        %zrzr_3_94_278_278_5552_pointer_1043 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1040, i64 0, i32 2
        store %Reference %zrzr_3_94_278_278_5552, ptr %zrzr_3_94_278_278_5552_pointer_1043, !noalias !2
        %tmp_5760_pointer_1044 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1040, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_1044, !noalias !2
        %notDone_17_108_292_292_5542_pointer_1045 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1040, i64 0, i32 4
        store %Reference %notDone_17_108_292_292_5542, ptr %notDone_17_108_292_292_5542_pointer_1045, !noalias !2
        %z_15_106_290_290_5374_pointer_1046 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1040, i64 0, i32 5
        store %Reference %z_15_106_290_290_5374, ptr %z_15_106_290_290_5374_pointer_1046, !noalias !2
        %zi_5_96_280_280_5410_pointer_1047 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1040, i64 0, i32 6
        store %Reference %zi_5_96_280_280_5410, ptr %zi_5_96_280_280_5410_pointer_1047, !noalias !2
        %escape_19_110_294_294_5368_pointer_1048 = getelementptr <{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1040, i64 0, i32 7
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_1048, !noalias !2
        %returnAddress_pointer_1049 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1040, i64 0, i32 1, i32 0
        %sharer_pointer_1050 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1040, i64 0, i32 1, i32 1
        %eraser_pointer_1051 = getelementptr <{<{double, %Reference, %Reference, double, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1040, i64 0, i32 1, i32 2
        store ptr @returnAddress_221, ptr %returnAddress_pointer_1049, !noalias !2
        store ptr @sharer_392, ptr %sharer_pointer_1050, !noalias !2
        store ptr @eraser_410, ptr %eraser_pointer_1051, !noalias !2
        
        %get_5887_pointer_1052 = call ccc ptr @getVarPointer(%Reference %notDone_17_108_292_292_5542, %Stack %stack)
        %notDone_17_108_292_292_5542_old_1053 = load %Pos, ptr %get_5887_pointer_1052, !noalias !2
        call ccc void @sharePositive(%Pos %notDone_17_108_292_292_5542_old_1053)
        %get_5887 = load %Pos, ptr %get_5887_pointer_1052, !noalias !2
        
        %stackPointer_1055 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1056 = getelementptr %FrameHeader, %StackPointer %stackPointer_1055, i64 0, i32 0
        %returnAddress_1054 = load %ReturnAddress, ptr %returnAddress_pointer_1056, !noalias !2
        musttail call tailcc void %returnAddress_1054(%Pos %get_5887, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1151(%Pos %__81_172_356_356_5629, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1152 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %bitNum_7_7_5558_pointer_1153 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1152, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1153, !noalias !2
        call ccc void @erasePositive(%Pos %__81_172_356_356_5629)
        
        %longLiteral_5904 = add i64 0, 0
        
        %bitNum_7_7_5558pointer_1154 = call ccc ptr @getVarPointer(%Reference %bitNum_7_7_5558, %Stack %stack)
        %bitNum_7_7_5558_old_1155 = load i64, ptr %bitNum_7_7_5558pointer_1154, !noalias !2
        store i64 %longLiteral_5904, ptr %bitNum_7_7_5558pointer_1154, !noalias !2
        
        %put_5903_temporary_1156 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5903 = insertvalue %Pos %put_5903_temporary_1156, %Object null, 1
        
        %stackPointer_1158 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1159 = getelementptr %FrameHeader, %StackPointer %stackPointer_1158, i64 0, i32 0
        %returnAddress_1157 = load %ReturnAddress, ptr %returnAddress_pointer_1159, !noalias !2
        musttail call tailcc void %returnAddress_1157(%Pos %put_5903, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1147(%Pos %__80_171_355_355_5628, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1148 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %bitNum_7_7_5558_pointer_1149 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1148, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1149, !noalias !2
        %byteAcc_5_5_5418_pointer_1150 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1148, i64 0, i32 1
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1150, !noalias !2
        call ccc void @erasePositive(%Pos %__80_171_355_355_5628)
        %stackPointer_1162 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %bitNum_7_7_5558_pointer_1163 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1162, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1163, !noalias !2
        %returnAddress_pointer_1164 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1162, i64 0, i32 1, i32 0
        %sharer_pointer_1165 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1162, i64 0, i32 1, i32 1
        %eraser_pointer_1166 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1162, i64 0, i32 1, i32 2
        store ptr @returnAddress_1151, ptr %returnAddress_pointer_1164, !noalias !2
        store ptr @sharer_517, ptr %sharer_pointer_1165, !noalias !2
        store ptr @eraser_521, ptr %eraser_pointer_1166, !noalias !2
        
        %longLiteral_5906 = add i64 0, 0
        
        %byteAcc_5_5_5418pointer_1167 = call ccc ptr @getVarPointer(%Reference %byteAcc_5_5_5418, %Stack %stack)
        %byteAcc_5_5_5418_old_1168 = load i64, ptr %byteAcc_5_5_5418pointer_1167, !noalias !2
        store i64 %longLiteral_5906, ptr %byteAcc_5_5_5418pointer_1167, !noalias !2
        
        %put_5905_temporary_1169 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5905 = insertvalue %Pos %put_5905_temporary_1169, %Object null, 1
        
        %stackPointer_1171 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1172 = getelementptr %FrameHeader, %StackPointer %stackPointer_1171, i64 0, i32 0
        %returnAddress_1170 = load %ReturnAddress, ptr %returnAddress_pointer_1172, !noalias !2
        musttail call tailcc void %returnAddress_1170(%Pos %put_5905, %Stack %stack)
        ret void
}



define ccc void @sharer_1175(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1176 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %bitNum_7_7_5558_1173_pointer_1177 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1176, i64 0, i32 0
        %bitNum_7_7_5558_1173 = load %Reference, ptr %bitNum_7_7_5558_1173_pointer_1177, !noalias !2
        %byteAcc_5_5_5418_1174_pointer_1178 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1176, i64 0, i32 1
        %byteAcc_5_5_5418_1174 = load %Reference, ptr %byteAcc_5_5_5418_1174_pointer_1178, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1176)
        ret void
}



define ccc void @eraser_1181(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1182 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %bitNum_7_7_5558_1179_pointer_1183 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1182, i64 0, i32 0
        %bitNum_7_7_5558_1179 = load %Reference, ptr %bitNum_7_7_5558_1179_pointer_1183, !noalias !2
        %byteAcc_5_5_5418_1180_pointer_1184 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1182, i64 0, i32 1
        %byteAcc_5_5_5418_1180 = load %Reference, ptr %byteAcc_5_5_5418_1180_pointer_1184, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1182)
        ret void
}



define tailcc void @returnAddress_1141(i64 %v_r_2601_78_169_353_353_5535, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1142 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %bitNum_7_7_5558_pointer_1143 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1142, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1143, !noalias !2
        %v_r_2600_77_168_352_352_5408_pointer_1144 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1142, i64 0, i32 1
        %v_r_2600_77_168_352_352_5408 = load i64, ptr %v_r_2600_77_168_352_352_5408_pointer_1144, !noalias !2
        %sum_3_3_5426_pointer_1145 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1142, i64 0, i32 2
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1145, !noalias !2
        %byteAcc_5_5_5418_pointer_1146 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1142, i64 0, i32 3
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1146, !noalias !2
        
        %pureApp_5902 = call ccc i64 @bitwiseXor_240(i64 %v_r_2600_77_168_352_352_5408, i64 %v_r_2601_78_169_353_353_5535)
        
        
        %stackPointer_1185 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %bitNum_7_7_5558_pointer_1186 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1185, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1186, !noalias !2
        %byteAcc_5_5_5418_pointer_1187 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1185, i64 0, i32 1
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1187, !noalias !2
        %returnAddress_pointer_1188 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1185, i64 0, i32 1, i32 0
        %sharer_pointer_1189 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1185, i64 0, i32 1, i32 1
        %eraser_pointer_1190 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1185, i64 0, i32 1, i32 2
        store ptr @returnAddress_1147, ptr %returnAddress_pointer_1188, !noalias !2
        store ptr @sharer_1175, ptr %sharer_pointer_1189, !noalias !2
        store ptr @eraser_1181, ptr %eraser_pointer_1190, !noalias !2
        
        %sum_3_3_5426pointer_1191 = call ccc ptr @getVarPointer(%Reference %sum_3_3_5426, %Stack %stack)
        %sum_3_3_5426_old_1192 = load i64, ptr %sum_3_3_5426pointer_1191, !noalias !2
        store i64 %pureApp_5902, ptr %sum_3_3_5426pointer_1191, !noalias !2
        
        %put_5907_temporary_1193 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5907 = insertvalue %Pos %put_5907_temporary_1193, %Object null, 1
        
        %stackPointer_1195 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1196 = getelementptr %FrameHeader, %StackPointer %stackPointer_1195, i64 0, i32 0
        %returnAddress_1194 = load %ReturnAddress, ptr %returnAddress_pointer_1196, !noalias !2
        musttail call tailcc void %returnAddress_1194(%Pos %put_5907, %Stack %stack)
        ret void
}



define ccc void @sharer_1201(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1202 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %bitNum_7_7_5558_1197_pointer_1203 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1202, i64 0, i32 0
        %bitNum_7_7_5558_1197 = load %Reference, ptr %bitNum_7_7_5558_1197_pointer_1203, !noalias !2
        %v_r_2600_77_168_352_352_5408_1198_pointer_1204 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1202, i64 0, i32 1
        %v_r_2600_77_168_352_352_5408_1198 = load i64, ptr %v_r_2600_77_168_352_352_5408_1198_pointer_1204, !noalias !2
        %sum_3_3_5426_1199_pointer_1205 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1202, i64 0, i32 2
        %sum_3_3_5426_1199 = load %Reference, ptr %sum_3_3_5426_1199_pointer_1205, !noalias !2
        %byteAcc_5_5_5418_1200_pointer_1206 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1202, i64 0, i32 3
        %byteAcc_5_5_5418_1200 = load %Reference, ptr %byteAcc_5_5_5418_1200_pointer_1206, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1202)
        ret void
}



define ccc void @eraser_1211(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1212 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %bitNum_7_7_5558_1207_pointer_1213 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1212, i64 0, i32 0
        %bitNum_7_7_5558_1207 = load %Reference, ptr %bitNum_7_7_5558_1207_pointer_1213, !noalias !2
        %v_r_2600_77_168_352_352_5408_1208_pointer_1214 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1212, i64 0, i32 1
        %v_r_2600_77_168_352_352_5408_1208 = load i64, ptr %v_r_2600_77_168_352_352_5408_1208_pointer_1214, !noalias !2
        %sum_3_3_5426_1209_pointer_1215 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1212, i64 0, i32 2
        %sum_3_3_5426_1209 = load %Reference, ptr %sum_3_3_5426_1209_pointer_1215, !noalias !2
        %byteAcc_5_5_5418_1210_pointer_1216 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1212, i64 0, i32 3
        %byteAcc_5_5_5418_1210 = load %Reference, ptr %byteAcc_5_5_5418_1210_pointer_1216, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1212)
        ret void
}



define tailcc void @returnAddress_1136(i64 %v_r_2600_77_168_352_352_5408, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1137 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %bitNum_7_7_5558_pointer_1138 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1137, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1138, !noalias !2
        %sum_3_3_5426_pointer_1139 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1137, i64 0, i32 1
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1139, !noalias !2
        %byteAcc_5_5_5418_pointer_1140 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1137, i64 0, i32 2
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1140, !noalias !2
        %stackPointer_1217 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %bitNum_7_7_5558_pointer_1218 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1217, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1218, !noalias !2
        %v_r_2600_77_168_352_352_5408_pointer_1219 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1217, i64 0, i32 1
        store i64 %v_r_2600_77_168_352_352_5408, ptr %v_r_2600_77_168_352_352_5408_pointer_1219, !noalias !2
        %sum_3_3_5426_pointer_1220 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1217, i64 0, i32 2
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1220, !noalias !2
        %byteAcc_5_5_5418_pointer_1221 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1217, i64 0, i32 3
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1221, !noalias !2
        %returnAddress_pointer_1222 = getelementptr <{<{%Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1217, i64 0, i32 1, i32 0
        %sharer_pointer_1223 = getelementptr <{<{%Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1217, i64 0, i32 1, i32 1
        %eraser_pointer_1224 = getelementptr <{<{%Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1217, i64 0, i32 1, i32 2
        store ptr @returnAddress_1141, ptr %returnAddress_pointer_1222, !noalias !2
        store ptr @sharer_1201, ptr %sharer_pointer_1223, !noalias !2
        store ptr @eraser_1211, ptr %eraser_pointer_1224, !noalias !2
        
        %get_5908_pointer_1225 = call ccc ptr @getVarPointer(%Reference %byteAcc_5_5_5418, %Stack %stack)
        %byteAcc_5_5_5418_old_1226 = load i64, ptr %get_5908_pointer_1225, !noalias !2
        %get_5908 = load i64, ptr %get_5908_pointer_1225, !noalias !2
        
        %stackPointer_1228 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1229 = getelementptr %FrameHeader, %StackPointer %stackPointer_1228, i64 0, i32 0
        %returnAddress_1227 = load %ReturnAddress, ptr %returnAddress_pointer_1229, !noalias !2
        musttail call tailcc void %returnAddress_1227(i64 %get_5908, %Stack %stack)
        ret void
}



define ccc void @sharer_1233(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1234 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %bitNum_7_7_5558_1230_pointer_1235 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1234, i64 0, i32 0
        %bitNum_7_7_5558_1230 = load %Reference, ptr %bitNum_7_7_5558_1230_pointer_1235, !noalias !2
        %sum_3_3_5426_1231_pointer_1236 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1234, i64 0, i32 1
        %sum_3_3_5426_1231 = load %Reference, ptr %sum_3_3_5426_1231_pointer_1236, !noalias !2
        %byteAcc_5_5_5418_1232_pointer_1237 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1234, i64 0, i32 2
        %byteAcc_5_5_5418_1232 = load %Reference, ptr %byteAcc_5_5_5418_1232_pointer_1237, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1234)
        ret void
}



define ccc void @eraser_1241(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1242 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %bitNum_7_7_5558_1238_pointer_1243 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1242, i64 0, i32 0
        %bitNum_7_7_5558_1238 = load %Reference, ptr %bitNum_7_7_5558_1238_pointer_1243, !noalias !2
        %sum_3_3_5426_1239_pointer_1244 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1242, i64 0, i32 1
        %sum_3_3_5426_1239 = load %Reference, ptr %sum_3_3_5426_1239_pointer_1244, !noalias !2
        %byteAcc_5_5_5418_1240_pointer_1245 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1242, i64 0, i32 2
        %byteAcc_5_5_5418_1240 = load %Reference, ptr %byteAcc_5_5_5418_1240_pointer_1245, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1242)
        ret void
}



define tailcc void @returnAddress_1131(%Pos %__76_167_351_351_5627, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1132 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %bitNum_7_7_5558_pointer_1133 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1132, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1133, !noalias !2
        %sum_3_3_5426_pointer_1134 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1132, i64 0, i32 1
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1134, !noalias !2
        %byteAcc_5_5_5418_pointer_1135 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1132, i64 0, i32 2
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1135, !noalias !2
        call ccc void @erasePositive(%Pos %__76_167_351_351_5627)
        %stackPointer_1246 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %bitNum_7_7_5558_pointer_1247 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1246, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1247, !noalias !2
        %sum_3_3_5426_pointer_1248 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1246, i64 0, i32 1
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1248, !noalias !2
        %byteAcc_5_5_5418_pointer_1249 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1246, i64 0, i32 2
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1249, !noalias !2
        %returnAddress_pointer_1250 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1246, i64 0, i32 1, i32 0
        %sharer_pointer_1251 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1246, i64 0, i32 1, i32 1
        %eraser_pointer_1252 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1246, i64 0, i32 1, i32 2
        store ptr @returnAddress_1136, ptr %returnAddress_pointer_1250, !noalias !2
        store ptr @sharer_1233, ptr %sharer_pointer_1251, !noalias !2
        store ptr @eraser_1241, ptr %eraser_pointer_1252, !noalias !2
        
        %get_5909_pointer_1253 = call ccc ptr @getVarPointer(%Reference %sum_3_3_5426, %Stack %stack)
        %sum_3_3_5426_old_1254 = load i64, ptr %get_5909_pointer_1253, !noalias !2
        %get_5909 = load i64, ptr %get_5909_pointer_1253, !noalias !2
        
        %stackPointer_1256 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1257 = getelementptr %FrameHeader, %StackPointer %stackPointer_1256, i64 0, i32 0
        %returnAddress_1255 = load %ReturnAddress, ptr %returnAddress_pointer_1257, !noalias !2
        musttail call tailcc void %returnAddress_1255(i64 %get_5909, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1125(i64 %v_r_2598_73_164_348_348_5453, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1126 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %bitNum_7_7_5558_pointer_1127 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1126, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1127, !noalias !2
        %sum_3_3_5426_pointer_1128 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1126, i64 0, i32 1
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1128, !noalias !2
        %v_r_2597_72_163_347_347_5321_pointer_1129 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1126, i64 0, i32 2
        %v_r_2597_72_163_347_347_5321 = load i64, ptr %v_r_2597_72_163_347_347_5321_pointer_1129, !noalias !2
        %byteAcc_5_5_5418_pointer_1130 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1126, i64 0, i32 3
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1130, !noalias !2
        
        %longLiteral_5900 = add i64 8, 0
        
        %pureApp_5899 = call ccc i64 @infixSub_105(i64 %longLiteral_5900, i64 %v_r_2598_73_164_348_348_5453)
        
        
        
        %pureApp_5901 = call ccc i64 @bitwiseShl_228(i64 %v_r_2597_72_163_347_347_5321, i64 %pureApp_5899)
        
        
        %stackPointer_1264 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %bitNum_7_7_5558_pointer_1265 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1264, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1265, !noalias !2
        %sum_3_3_5426_pointer_1266 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1264, i64 0, i32 1
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1266, !noalias !2
        %byteAcc_5_5_5418_pointer_1267 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1264, i64 0, i32 2
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1267, !noalias !2
        %returnAddress_pointer_1268 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1264, i64 0, i32 1, i32 0
        %sharer_pointer_1269 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1264, i64 0, i32 1, i32 1
        %eraser_pointer_1270 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1264, i64 0, i32 1, i32 2
        store ptr @returnAddress_1131, ptr %returnAddress_pointer_1268, !noalias !2
        store ptr @sharer_1233, ptr %sharer_pointer_1269, !noalias !2
        store ptr @eraser_1241, ptr %eraser_pointer_1270, !noalias !2
        
        %byteAcc_5_5_5418pointer_1271 = call ccc ptr @getVarPointer(%Reference %byteAcc_5_5_5418, %Stack %stack)
        %byteAcc_5_5_5418_old_1272 = load i64, ptr %byteAcc_5_5_5418pointer_1271, !noalias !2
        store i64 %pureApp_5901, ptr %byteAcc_5_5_5418pointer_1271, !noalias !2
        
        %put_5910_temporary_1273 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5910 = insertvalue %Pos %put_5910_temporary_1273, %Object null, 1
        
        %stackPointer_1275 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1276 = getelementptr %FrameHeader, %StackPointer %stackPointer_1275, i64 0, i32 0
        %returnAddress_1274 = load %ReturnAddress, ptr %returnAddress_pointer_1276, !noalias !2
        musttail call tailcc void %returnAddress_1274(%Pos %put_5910, %Stack %stack)
        ret void
}



define ccc void @sharer_1281(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1282 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %bitNum_7_7_5558_1277_pointer_1283 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1282, i64 0, i32 0
        %bitNum_7_7_5558_1277 = load %Reference, ptr %bitNum_7_7_5558_1277_pointer_1283, !noalias !2
        %sum_3_3_5426_1278_pointer_1284 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1282, i64 0, i32 1
        %sum_3_3_5426_1278 = load %Reference, ptr %sum_3_3_5426_1278_pointer_1284, !noalias !2
        %v_r_2597_72_163_347_347_5321_1279_pointer_1285 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1282, i64 0, i32 2
        %v_r_2597_72_163_347_347_5321_1279 = load i64, ptr %v_r_2597_72_163_347_347_5321_1279_pointer_1285, !noalias !2
        %byteAcc_5_5_5418_1280_pointer_1286 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1282, i64 0, i32 3
        %byteAcc_5_5_5418_1280 = load %Reference, ptr %byteAcc_5_5_5418_1280_pointer_1286, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1282)
        ret void
}



define ccc void @eraser_1291(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1292 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %bitNum_7_7_5558_1287_pointer_1293 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1292, i64 0, i32 0
        %bitNum_7_7_5558_1287 = load %Reference, ptr %bitNum_7_7_5558_1287_pointer_1293, !noalias !2
        %sum_3_3_5426_1288_pointer_1294 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1292, i64 0, i32 1
        %sum_3_3_5426_1288 = load %Reference, ptr %sum_3_3_5426_1288_pointer_1294, !noalias !2
        %v_r_2597_72_163_347_347_5321_1289_pointer_1295 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1292, i64 0, i32 2
        %v_r_2597_72_163_347_347_5321_1289 = load i64, ptr %v_r_2597_72_163_347_347_5321_1289_pointer_1295, !noalias !2
        %byteAcc_5_5_5418_1290_pointer_1296 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1292, i64 0, i32 3
        %byteAcc_5_5_5418_1290 = load %Reference, ptr %byteAcc_5_5_5418_1290_pointer_1296, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1292)
        ret void
}



define tailcc void @returnAddress_1120(i64 %v_r_2597_72_163_347_347_5321, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1121 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %bitNum_7_7_5558_pointer_1122 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1121, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1122, !noalias !2
        %sum_3_3_5426_pointer_1123 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1121, i64 0, i32 1
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1123, !noalias !2
        %byteAcc_5_5_5418_pointer_1124 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1121, i64 0, i32 2
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1124, !noalias !2
        %stackPointer_1297 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %bitNum_7_7_5558_pointer_1298 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1297, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1298, !noalias !2
        %sum_3_3_5426_pointer_1299 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1297, i64 0, i32 1
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1299, !noalias !2
        %v_r_2597_72_163_347_347_5321_pointer_1300 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1297, i64 0, i32 2
        store i64 %v_r_2597_72_163_347_347_5321, ptr %v_r_2597_72_163_347_347_5321_pointer_1300, !noalias !2
        %byteAcc_5_5_5418_pointer_1301 = getelementptr <{%Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1297, i64 0, i32 3
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1301, !noalias !2
        %returnAddress_pointer_1302 = getelementptr <{<{%Reference, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1297, i64 0, i32 1, i32 0
        %sharer_pointer_1303 = getelementptr <{<{%Reference, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1297, i64 0, i32 1, i32 1
        %eraser_pointer_1304 = getelementptr <{<{%Reference, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1297, i64 0, i32 1, i32 2
        store ptr @returnAddress_1125, ptr %returnAddress_pointer_1302, !noalias !2
        store ptr @sharer_1281, ptr %sharer_pointer_1303, !noalias !2
        store ptr @eraser_1291, ptr %eraser_pointer_1304, !noalias !2
        
        %get_5911_pointer_1305 = call ccc ptr @getVarPointer(%Reference %bitNum_7_7_5558, %Stack %stack)
        %bitNum_7_7_5558_old_1306 = load i64, ptr %get_5911_pointer_1305, !noalias !2
        %get_5911 = load i64, ptr %get_5911_pointer_1305, !noalias !2
        
        %stackPointer_1308 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1309 = getelementptr %FrameHeader, %StackPointer %stackPointer_1308, i64 0, i32 0
        %returnAddress_1307 = load %ReturnAddress, ptr %returnAddress_pointer_1309, !noalias !2
        musttail call tailcc void %returnAddress_1307(i64 %get_5911, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1345(%Pos %__69_160_344_344_5626, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1346 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %bitNum_7_7_5558_pointer_1347 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1346, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1347, !noalias !2
        call ccc void @erasePositive(%Pos %__69_160_344_344_5626)
        
        %longLiteral_5915 = add i64 0, 0
        
        %bitNum_7_7_5558pointer_1348 = call ccc ptr @getVarPointer(%Reference %bitNum_7_7_5558, %Stack %stack)
        %bitNum_7_7_5558_old_1349 = load i64, ptr %bitNum_7_7_5558pointer_1348, !noalias !2
        store i64 %longLiteral_5915, ptr %bitNum_7_7_5558pointer_1348, !noalias !2
        
        %put_5914_temporary_1350 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5914 = insertvalue %Pos %put_5914_temporary_1350, %Object null, 1
        
        %stackPointer_1352 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1353 = getelementptr %FrameHeader, %StackPointer %stackPointer_1352, i64 0, i32 0
        %returnAddress_1351 = load %ReturnAddress, ptr %returnAddress_pointer_1353, !noalias !2
        musttail call tailcc void %returnAddress_1351(%Pos %put_5914, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1341(%Pos %__68_159_343_343_5625, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1342 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %bitNum_7_7_5558_pointer_1343 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1342, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1343, !noalias !2
        %byteAcc_5_5_5418_pointer_1344 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1342, i64 0, i32 1
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1344, !noalias !2
        call ccc void @erasePositive(%Pos %__68_159_343_343_5625)
        %stackPointer_1356 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %bitNum_7_7_5558_pointer_1357 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1356, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1357, !noalias !2
        %returnAddress_pointer_1358 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1356, i64 0, i32 1, i32 0
        %sharer_pointer_1359 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1356, i64 0, i32 1, i32 1
        %eraser_pointer_1360 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1356, i64 0, i32 1, i32 2
        store ptr @returnAddress_1345, ptr %returnAddress_pointer_1358, !noalias !2
        store ptr @sharer_517, ptr %sharer_pointer_1359, !noalias !2
        store ptr @eraser_521, ptr %eraser_pointer_1360, !noalias !2
        
        %longLiteral_5917 = add i64 0, 0
        
        %byteAcc_5_5_5418pointer_1361 = call ccc ptr @getVarPointer(%Reference %byteAcc_5_5_5418, %Stack %stack)
        %byteAcc_5_5_5418_old_1362 = load i64, ptr %byteAcc_5_5_5418pointer_1361, !noalias !2
        store i64 %longLiteral_5917, ptr %byteAcc_5_5_5418pointer_1361, !noalias !2
        
        %put_5916_temporary_1363 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5916 = insertvalue %Pos %put_5916_temporary_1363, %Object null, 1
        
        %stackPointer_1365 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1366 = getelementptr %FrameHeader, %StackPointer %stackPointer_1365, i64 0, i32 0
        %returnAddress_1364 = load %ReturnAddress, ptr %returnAddress_pointer_1366, !noalias !2
        musttail call tailcc void %returnAddress_1364(%Pos %put_5916, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1335(i64 %v_r_2593_66_157_341_341_5387, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1336 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %bitNum_7_7_5558_pointer_1337 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1336, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1337, !noalias !2
        %v_r_2592_65_156_340_340_5290_pointer_1338 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1336, i64 0, i32 1
        %v_r_2592_65_156_340_340_5290 = load i64, ptr %v_r_2592_65_156_340_340_5290_pointer_1338, !noalias !2
        %sum_3_3_5426_pointer_1339 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1336, i64 0, i32 2
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1339, !noalias !2
        %byteAcc_5_5_5418_pointer_1340 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1336, i64 0, i32 3
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1340, !noalias !2
        
        %pureApp_5913 = call ccc i64 @bitwiseXor_240(i64 %v_r_2592_65_156_340_340_5290, i64 %v_r_2593_66_157_341_341_5387)
        
        
        %stackPointer_1371 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %bitNum_7_7_5558_pointer_1372 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1371, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1372, !noalias !2
        %byteAcc_5_5_5418_pointer_1373 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1371, i64 0, i32 1
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1373, !noalias !2
        %returnAddress_pointer_1374 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1371, i64 0, i32 1, i32 0
        %sharer_pointer_1375 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1371, i64 0, i32 1, i32 1
        %eraser_pointer_1376 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1371, i64 0, i32 1, i32 2
        store ptr @returnAddress_1341, ptr %returnAddress_pointer_1374, !noalias !2
        store ptr @sharer_1175, ptr %sharer_pointer_1375, !noalias !2
        store ptr @eraser_1181, ptr %eraser_pointer_1376, !noalias !2
        
        %sum_3_3_5426pointer_1377 = call ccc ptr @getVarPointer(%Reference %sum_3_3_5426, %Stack %stack)
        %sum_3_3_5426_old_1378 = load i64, ptr %sum_3_3_5426pointer_1377, !noalias !2
        store i64 %pureApp_5913, ptr %sum_3_3_5426pointer_1377, !noalias !2
        
        %put_5918_temporary_1379 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5918 = insertvalue %Pos %put_5918_temporary_1379, %Object null, 1
        
        %stackPointer_1381 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1382 = getelementptr %FrameHeader, %StackPointer %stackPointer_1381, i64 0, i32 0
        %returnAddress_1380 = load %ReturnAddress, ptr %returnAddress_pointer_1382, !noalias !2
        musttail call tailcc void %returnAddress_1380(%Pos %put_5918, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1330(i64 %v_r_2592_65_156_340_340_5290, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1331 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %bitNum_7_7_5558_pointer_1332 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1331, i64 0, i32 0
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1332, !noalias !2
        %sum_3_3_5426_pointer_1333 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1331, i64 0, i32 1
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1333, !noalias !2
        %byteAcc_5_5_5418_pointer_1334 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1331, i64 0, i32 2
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1334, !noalias !2
        %stackPointer_1391 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %bitNum_7_7_5558_pointer_1392 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1391, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1392, !noalias !2
        %v_r_2592_65_156_340_340_5290_pointer_1393 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1391, i64 0, i32 1
        store i64 %v_r_2592_65_156_340_340_5290, ptr %v_r_2592_65_156_340_340_5290_pointer_1393, !noalias !2
        %sum_3_3_5426_pointer_1394 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1391, i64 0, i32 2
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1394, !noalias !2
        %byteAcc_5_5_5418_pointer_1395 = getelementptr <{%Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1391, i64 0, i32 3
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1395, !noalias !2
        %returnAddress_pointer_1396 = getelementptr <{<{%Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1391, i64 0, i32 1, i32 0
        %sharer_pointer_1397 = getelementptr <{<{%Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1391, i64 0, i32 1, i32 1
        %eraser_pointer_1398 = getelementptr <{<{%Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1391, i64 0, i32 1, i32 2
        store ptr @returnAddress_1335, ptr %returnAddress_pointer_1396, !noalias !2
        store ptr @sharer_1201, ptr %sharer_pointer_1397, !noalias !2
        store ptr @eraser_1211, ptr %eraser_pointer_1398, !noalias !2
        
        %get_5919_pointer_1399 = call ccc ptr @getVarPointer(%Reference %byteAcc_5_5_5418, %Stack %stack)
        %byteAcc_5_5_5418_old_1400 = load i64, ptr %get_5919_pointer_1399, !noalias !2
        %get_5919 = load i64, ptr %get_5919_pointer_1399, !noalias !2
        
        %stackPointer_1402 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1403 = getelementptr %FrameHeader, %StackPointer %stackPointer_1402, i64 0, i32 0
        %returnAddress_1401 = load %ReturnAddress, ptr %returnAddress_pointer_1403, !noalias !2
        musttail call tailcc void %returnAddress_1401(i64 %get_5919, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1102(i64 %v_r_2591_63_154_338_338_5359, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1103 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %i_6_91_275_275_5504_pointer_1104 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1103, i64 0, i32 0
        %i_6_91_275_275_5504 = load i64, ptr %i_6_91_275_275_5504_pointer_1104, !noalias !2
        %tmp_5795_pointer_1105 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1103, i64 0, i32 1
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_1105, !noalias !2
        %bitNum_7_7_5558_pointer_1106 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1103, i64 0, i32 2
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1106, !noalias !2
        %sum_3_3_5426_pointer_1107 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1103, i64 0, i32 3
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1107, !noalias !2
        %byteAcc_5_5_5418_pointer_1108 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1103, i64 0, i32 4
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1108, !noalias !2
        
        %longLiteral_5894 = add i64 8, 0
        
        %pureApp_5893 = call ccc %Pos @infixEq_72(i64 %v_r_2591_63_154_338_338_5359, i64 %longLiteral_5894)
        
        
        
        %tag_1109 = extractvalue %Pos %pureApp_5893, 0
        %fields_1110 = extractvalue %Pos %pureApp_5893, 1
        switch i64 %tag_1109, label %label_1111 [i64 0, label %label_1329 i64 1, label %label_1422]
    
    label_1111:
        
        ret void
    
    label_1114:
        
        ret void
    
    label_1119:
        
        %unitLiteral_5898_temporary_1115 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5898 = insertvalue %Pos %unitLiteral_5898_temporary_1115, %Object null, 1
        
        %stackPointer_1117 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1118 = getelementptr %FrameHeader, %StackPointer %stackPointer_1117, i64 0, i32 0
        %returnAddress_1116 = load %ReturnAddress, ptr %returnAddress_pointer_1118, !noalias !2
        musttail call tailcc void %returnAddress_1116(%Pos %unitLiteral_5898, %Stack %stack)
        ret void
    
    label_1328:
        %stackPointer_1316 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %bitNum_7_7_5558_pointer_1317 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1316, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1317, !noalias !2
        %sum_3_3_5426_pointer_1318 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1316, i64 0, i32 1
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1318, !noalias !2
        %byteAcc_5_5_5418_pointer_1319 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1316, i64 0, i32 2
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1319, !noalias !2
        %returnAddress_pointer_1320 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1316, i64 0, i32 1, i32 0
        %sharer_pointer_1321 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1316, i64 0, i32 1, i32 1
        %eraser_pointer_1322 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1316, i64 0, i32 1, i32 2
        store ptr @returnAddress_1120, ptr %returnAddress_pointer_1320, !noalias !2
        store ptr @sharer_1233, ptr %sharer_pointer_1321, !noalias !2
        store ptr @eraser_1241, ptr %eraser_pointer_1322, !noalias !2
        
        %get_5912_pointer_1323 = call ccc ptr @getVarPointer(%Reference %byteAcc_5_5_5418, %Stack %stack)
        %byteAcc_5_5_5418_old_1324 = load i64, ptr %get_5912_pointer_1323, !noalias !2
        %get_5912 = load i64, ptr %get_5912_pointer_1323, !noalias !2
        
        %stackPointer_1326 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1327 = getelementptr %FrameHeader, %StackPointer %stackPointer_1326, i64 0, i32 0
        %returnAddress_1325 = load %ReturnAddress, ptr %returnAddress_pointer_1327, !noalias !2
        musttail call tailcc void %returnAddress_1325(i64 %get_5912, %Stack %stack)
        ret void
    
    label_1329:
        
        %longLiteral_5896 = add i64 1, 0
        
        %pureApp_5895 = call ccc i64 @infixSub_105(i64 %tmp_5795, i64 %longLiteral_5896)
        
        
        
        %pureApp_5897 = call ccc %Pos @infixEq_72(i64 %i_6_91_275_275_5504, i64 %pureApp_5895)
        
        
        
        %tag_1112 = extractvalue %Pos %pureApp_5897, 0
        %fields_1113 = extractvalue %Pos %pureApp_5897, 1
        switch i64 %tag_1112, label %label_1114 [i64 0, label %label_1119 i64 1, label %label_1328]
    
    label_1422:
        %stackPointer_1410 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %bitNum_7_7_5558_pointer_1411 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1410, i64 0, i32 0
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1411, !noalias !2
        %sum_3_3_5426_pointer_1412 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1410, i64 0, i32 1
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1412, !noalias !2
        %byteAcc_5_5_5418_pointer_1413 = getelementptr <{%Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1410, i64 0, i32 2
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1413, !noalias !2
        %returnAddress_pointer_1414 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1410, i64 0, i32 1, i32 0
        %sharer_pointer_1415 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1410, i64 0, i32 1, i32 1
        %eraser_pointer_1416 = getelementptr <{<{%Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1410, i64 0, i32 1, i32 2
        store ptr @returnAddress_1330, ptr %returnAddress_pointer_1414, !noalias !2
        store ptr @sharer_1233, ptr %sharer_pointer_1415, !noalias !2
        store ptr @eraser_1241, ptr %eraser_pointer_1416, !noalias !2
        
        %get_5920_pointer_1417 = call ccc ptr @getVarPointer(%Reference %sum_3_3_5426, %Stack %stack)
        %sum_3_3_5426_old_1418 = load i64, ptr %get_5920_pointer_1417, !noalias !2
        %get_5920 = load i64, ptr %get_5920_pointer_1417, !noalias !2
        
        %stackPointer_1420 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1421 = getelementptr %FrameHeader, %StackPointer %stackPointer_1420, i64 0, i32 0
        %returnAddress_1419 = load %ReturnAddress, ptr %returnAddress_pointer_1421, !noalias !2
        musttail call tailcc void %returnAddress_1419(i64 %get_5920, %Stack %stack)
        ret void
}



define ccc void @sharer_1428(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1429 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_91_275_275_5504_1423_pointer_1430 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1429, i64 0, i32 0
        %i_6_91_275_275_5504_1423 = load i64, ptr %i_6_91_275_275_5504_1423_pointer_1430, !noalias !2
        %tmp_5795_1424_pointer_1431 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1429, i64 0, i32 1
        %tmp_5795_1424 = load i64, ptr %tmp_5795_1424_pointer_1431, !noalias !2
        %bitNum_7_7_5558_1425_pointer_1432 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1429, i64 0, i32 2
        %bitNum_7_7_5558_1425 = load %Reference, ptr %bitNum_7_7_5558_1425_pointer_1432, !noalias !2
        %sum_3_3_5426_1426_pointer_1433 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1429, i64 0, i32 3
        %sum_3_3_5426_1426 = load %Reference, ptr %sum_3_3_5426_1426_pointer_1433, !noalias !2
        %byteAcc_5_5_5418_1427_pointer_1434 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1429, i64 0, i32 4
        %byteAcc_5_5_5418_1427 = load %Reference, ptr %byteAcc_5_5_5418_1427_pointer_1434, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1429)
        ret void
}



define ccc void @eraser_1440(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1441 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_91_275_275_5504_1435_pointer_1442 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1441, i64 0, i32 0
        %i_6_91_275_275_5504_1435 = load i64, ptr %i_6_91_275_275_5504_1435_pointer_1442, !noalias !2
        %tmp_5795_1436_pointer_1443 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1441, i64 0, i32 1
        %tmp_5795_1436 = load i64, ptr %tmp_5795_1436_pointer_1443, !noalias !2
        %bitNum_7_7_5558_1437_pointer_1444 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1441, i64 0, i32 2
        %bitNum_7_7_5558_1437 = load %Reference, ptr %bitNum_7_7_5558_1437_pointer_1444, !noalias !2
        %sum_3_3_5426_1438_pointer_1445 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1441, i64 0, i32 3
        %sum_3_3_5426_1438 = load %Reference, ptr %sum_3_3_5426_1438_pointer_1445, !noalias !2
        %byteAcc_5_5_5418_1439_pointer_1446 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1441, i64 0, i32 4
        %byteAcc_5_5_5418_1439 = load %Reference, ptr %byteAcc_5_5_5418_1439_pointer_1446, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1441)
        ret void
}



define tailcc void @returnAddress_1095(%Pos %__62_153_337_337_5624, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1096 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %i_6_91_275_275_5504_pointer_1097 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1096, i64 0, i32 0
        %i_6_91_275_275_5504 = load i64, ptr %i_6_91_275_275_5504_pointer_1097, !noalias !2
        %tmp_5795_pointer_1098 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1096, i64 0, i32 1
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_1098, !noalias !2
        %bitNum_7_7_5558_pointer_1099 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1096, i64 0, i32 2
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1099, !noalias !2
        %sum_3_3_5426_pointer_1100 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1096, i64 0, i32 3
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1100, !noalias !2
        %byteAcc_5_5_5418_pointer_1101 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1096, i64 0, i32 4
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1101, !noalias !2
        call ccc void @erasePositive(%Pos %__62_153_337_337_5624)
        %stackPointer_1447 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %i_6_91_275_275_5504_pointer_1448 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1447, i64 0, i32 0
        store i64 %i_6_91_275_275_5504, ptr %i_6_91_275_275_5504_pointer_1448, !noalias !2
        %tmp_5795_pointer_1449 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1447, i64 0, i32 1
        store i64 %tmp_5795, ptr %tmp_5795_pointer_1449, !noalias !2
        %bitNum_7_7_5558_pointer_1450 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1447, i64 0, i32 2
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1450, !noalias !2
        %sum_3_3_5426_pointer_1451 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1447, i64 0, i32 3
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1451, !noalias !2
        %byteAcc_5_5_5418_pointer_1452 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1447, i64 0, i32 4
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1452, !noalias !2
        %returnAddress_pointer_1453 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1447, i64 0, i32 1, i32 0
        %sharer_pointer_1454 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1447, i64 0, i32 1, i32 1
        %eraser_pointer_1455 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1447, i64 0, i32 1, i32 2
        store ptr @returnAddress_1102, ptr %returnAddress_pointer_1453, !noalias !2
        store ptr @sharer_1428, ptr %sharer_pointer_1454, !noalias !2
        store ptr @eraser_1440, ptr %eraser_pointer_1455, !noalias !2
        
        %get_5921_pointer_1456 = call ccc ptr @getVarPointer(%Reference %bitNum_7_7_5558, %Stack %stack)
        %bitNum_7_7_5558_old_1457 = load i64, ptr %get_5921_pointer_1456, !noalias !2
        %get_5921 = load i64, ptr %get_5921_pointer_1456, !noalias !2
        
        %stackPointer_1459 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1460 = getelementptr %FrameHeader, %StackPointer %stackPointer_1459, i64 0, i32 0
        %returnAddress_1458 = load %ReturnAddress, ptr %returnAddress_pointer_1460, !noalias !2
        musttail call tailcc void %returnAddress_1458(i64 %get_5921, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1088(i64 %v_r_2589_60_151_335_335_5292, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1089 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %i_6_91_275_275_5504_pointer_1090 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1089, i64 0, i32 0
        %i_6_91_275_275_5504 = load i64, ptr %i_6_91_275_275_5504_pointer_1090, !noalias !2
        %tmp_5795_pointer_1091 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1089, i64 0, i32 1
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_1091, !noalias !2
        %bitNum_7_7_5558_pointer_1092 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1089, i64 0, i32 2
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1092, !noalias !2
        %sum_3_3_5426_pointer_1093 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1089, i64 0, i32 3
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1093, !noalias !2
        %byteAcc_5_5_5418_pointer_1094 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1089, i64 0, i32 4
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1094, !noalias !2
        
        %longLiteral_5892 = add i64 1, 0
        
        %pureApp_5891 = call ccc i64 @infixAdd_96(i64 %v_r_2589_60_151_335_335_5292, i64 %longLiteral_5892)
        
        
        %stackPointer_1471 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %i_6_91_275_275_5504_pointer_1472 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1471, i64 0, i32 0
        store i64 %i_6_91_275_275_5504, ptr %i_6_91_275_275_5504_pointer_1472, !noalias !2
        %tmp_5795_pointer_1473 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1471, i64 0, i32 1
        store i64 %tmp_5795, ptr %tmp_5795_pointer_1473, !noalias !2
        %bitNum_7_7_5558_pointer_1474 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1471, i64 0, i32 2
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1474, !noalias !2
        %sum_3_3_5426_pointer_1475 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1471, i64 0, i32 3
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1475, !noalias !2
        %byteAcc_5_5_5418_pointer_1476 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1471, i64 0, i32 4
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1476, !noalias !2
        %returnAddress_pointer_1477 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1471, i64 0, i32 1, i32 0
        %sharer_pointer_1478 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1471, i64 0, i32 1, i32 1
        %eraser_pointer_1479 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1471, i64 0, i32 1, i32 2
        store ptr @returnAddress_1095, ptr %returnAddress_pointer_1477, !noalias !2
        store ptr @sharer_1428, ptr %sharer_pointer_1478, !noalias !2
        store ptr @eraser_1440, ptr %eraser_pointer_1479, !noalias !2
        
        %bitNum_7_7_5558pointer_1480 = call ccc ptr @getVarPointer(%Reference %bitNum_7_7_5558, %Stack %stack)
        %bitNum_7_7_5558_old_1481 = load i64, ptr %bitNum_7_7_5558pointer_1480, !noalias !2
        store i64 %pureApp_5891, ptr %bitNum_7_7_5558pointer_1480, !noalias !2
        
        %put_5922_temporary_1482 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5922 = insertvalue %Pos %put_5922_temporary_1482, %Object null, 1
        
        %stackPointer_1484 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1485 = getelementptr %FrameHeader, %StackPointer %stackPointer_1484, i64 0, i32 0
        %returnAddress_1483 = load %ReturnAddress, ptr %returnAddress_pointer_1485, !noalias !2
        musttail call tailcc void %returnAddress_1483(%Pos %put_5922, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1081(%Pos %__59_150_334_334_5623, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1082 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %i_6_91_275_275_5504_pointer_1083 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1082, i64 0, i32 0
        %i_6_91_275_275_5504 = load i64, ptr %i_6_91_275_275_5504_pointer_1083, !noalias !2
        %tmp_5795_pointer_1084 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1082, i64 0, i32 1
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_1084, !noalias !2
        %bitNum_7_7_5558_pointer_1085 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1082, i64 0, i32 2
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1085, !noalias !2
        %sum_3_3_5426_pointer_1086 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1082, i64 0, i32 3
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1086, !noalias !2
        %byteAcc_5_5_5418_pointer_1087 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1082, i64 0, i32 4
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1087, !noalias !2
        call ccc void @erasePositive(%Pos %__59_150_334_334_5623)
        %stackPointer_1496 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %i_6_91_275_275_5504_pointer_1497 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1496, i64 0, i32 0
        store i64 %i_6_91_275_275_5504, ptr %i_6_91_275_275_5504_pointer_1497, !noalias !2
        %tmp_5795_pointer_1498 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1496, i64 0, i32 1
        store i64 %tmp_5795, ptr %tmp_5795_pointer_1498, !noalias !2
        %bitNum_7_7_5558_pointer_1499 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1496, i64 0, i32 2
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1499, !noalias !2
        %sum_3_3_5426_pointer_1500 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1496, i64 0, i32 3
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1500, !noalias !2
        %byteAcc_5_5_5418_pointer_1501 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1496, i64 0, i32 4
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1501, !noalias !2
        %returnAddress_pointer_1502 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1496, i64 0, i32 1, i32 0
        %sharer_pointer_1503 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1496, i64 0, i32 1, i32 1
        %eraser_pointer_1504 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1496, i64 0, i32 1, i32 2
        store ptr @returnAddress_1088, ptr %returnAddress_pointer_1502, !noalias !2
        store ptr @sharer_1428, ptr %sharer_pointer_1503, !noalias !2
        store ptr @eraser_1440, ptr %eraser_pointer_1504, !noalias !2
        
        %get_5923_pointer_1505 = call ccc ptr @getVarPointer(%Reference %bitNum_7_7_5558, %Stack %stack)
        %bitNum_7_7_5558_old_1506 = load i64, ptr %get_5923_pointer_1505, !noalias !2
        %get_5923 = load i64, ptr %get_5923_pointer_1505, !noalias !2
        
        %stackPointer_1508 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1509 = getelementptr %FrameHeader, %StackPointer %stackPointer_1508, i64 0, i32 0
        %returnAddress_1507 = load %ReturnAddress, ptr %returnAddress_pointer_1509, !noalias !2
        musttail call tailcc void %returnAddress_1507(i64 %get_5923, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1073(i64 %v_r_2587_56_147_331_331_5317, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1074 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %i_6_91_275_275_5504_pointer_1075 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1074, i64 0, i32 0
        %i_6_91_275_275_5504 = load i64, ptr %i_6_91_275_275_5504_pointer_1075, !noalias !2
        %tmp_5795_pointer_1076 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1074, i64 0, i32 1
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_1076, !noalias !2
        %bitNum_7_7_5558_pointer_1077 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1074, i64 0, i32 2
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1077, !noalias !2
        %sum_3_3_5426_pointer_1078 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1074, i64 0, i32 3
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1078, !noalias !2
        %v_r_2586_55_146_330_330_5536_pointer_1079 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1074, i64 0, i32 4
        %v_r_2586_55_146_330_330_5536 = load i64, ptr %v_r_2586_55_146_330_330_5536_pointer_1079, !noalias !2
        %byteAcc_5_5_5418_pointer_1080 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1074, i64 0, i32 5
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1080, !noalias !2
        
        %longLiteral_5889 = add i64 1, 0
        
        %pureApp_5888 = call ccc i64 @bitwiseShl_228(i64 %v_r_2586_55_146_330_330_5536, i64 %longLiteral_5889)
        
        
        
        %pureApp_5890 = call ccc i64 @infixAdd_96(i64 %pureApp_5888, i64 %v_r_2587_56_147_331_331_5317)
        
        
        %stackPointer_1520 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %i_6_91_275_275_5504_pointer_1521 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1520, i64 0, i32 0
        store i64 %i_6_91_275_275_5504, ptr %i_6_91_275_275_5504_pointer_1521, !noalias !2
        %tmp_5795_pointer_1522 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1520, i64 0, i32 1
        store i64 %tmp_5795, ptr %tmp_5795_pointer_1522, !noalias !2
        %bitNum_7_7_5558_pointer_1523 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1520, i64 0, i32 2
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1523, !noalias !2
        %sum_3_3_5426_pointer_1524 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1520, i64 0, i32 3
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1524, !noalias !2
        %byteAcc_5_5_5418_pointer_1525 = getelementptr <{i64, i64, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1520, i64 0, i32 4
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1525, !noalias !2
        %returnAddress_pointer_1526 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1520, i64 0, i32 1, i32 0
        %sharer_pointer_1527 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1520, i64 0, i32 1, i32 1
        %eraser_pointer_1528 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1520, i64 0, i32 1, i32 2
        store ptr @returnAddress_1081, ptr %returnAddress_pointer_1526, !noalias !2
        store ptr @sharer_1428, ptr %sharer_pointer_1527, !noalias !2
        store ptr @eraser_1440, ptr %eraser_pointer_1528, !noalias !2
        
        %byteAcc_5_5_5418pointer_1529 = call ccc ptr @getVarPointer(%Reference %byteAcc_5_5_5418, %Stack %stack)
        %byteAcc_5_5_5418_old_1530 = load i64, ptr %byteAcc_5_5_5418pointer_1529, !noalias !2
        store i64 %pureApp_5890, ptr %byteAcc_5_5_5418pointer_1529, !noalias !2
        
        %put_5924_temporary_1531 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5924 = insertvalue %Pos %put_5924_temporary_1531, %Object null, 1
        
        %stackPointer_1533 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1534 = getelementptr %FrameHeader, %StackPointer %stackPointer_1533, i64 0, i32 0
        %returnAddress_1532 = load %ReturnAddress, ptr %returnAddress_pointer_1534, !noalias !2
        musttail call tailcc void %returnAddress_1532(%Pos %put_5924, %Stack %stack)
        ret void
}



define ccc void @sharer_1541(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1542 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_91_275_275_5504_1535_pointer_1543 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1542, i64 0, i32 0
        %i_6_91_275_275_5504_1535 = load i64, ptr %i_6_91_275_275_5504_1535_pointer_1543, !noalias !2
        %tmp_5795_1536_pointer_1544 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1542, i64 0, i32 1
        %tmp_5795_1536 = load i64, ptr %tmp_5795_1536_pointer_1544, !noalias !2
        %bitNum_7_7_5558_1537_pointer_1545 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1542, i64 0, i32 2
        %bitNum_7_7_5558_1537 = load %Reference, ptr %bitNum_7_7_5558_1537_pointer_1545, !noalias !2
        %sum_3_3_5426_1538_pointer_1546 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1542, i64 0, i32 3
        %sum_3_3_5426_1538 = load %Reference, ptr %sum_3_3_5426_1538_pointer_1546, !noalias !2
        %v_r_2586_55_146_330_330_5536_1539_pointer_1547 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1542, i64 0, i32 4
        %v_r_2586_55_146_330_330_5536_1539 = load i64, ptr %v_r_2586_55_146_330_330_5536_1539_pointer_1547, !noalias !2
        %byteAcc_5_5_5418_1540_pointer_1548 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1542, i64 0, i32 5
        %byteAcc_5_5_5418_1540 = load %Reference, ptr %byteAcc_5_5_5418_1540_pointer_1548, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1542)
        ret void
}



define ccc void @eraser_1555(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1556 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_91_275_275_5504_1549_pointer_1557 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1556, i64 0, i32 0
        %i_6_91_275_275_5504_1549 = load i64, ptr %i_6_91_275_275_5504_1549_pointer_1557, !noalias !2
        %tmp_5795_1550_pointer_1558 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1556, i64 0, i32 1
        %tmp_5795_1550 = load i64, ptr %tmp_5795_1550_pointer_1558, !noalias !2
        %bitNum_7_7_5558_1551_pointer_1559 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1556, i64 0, i32 2
        %bitNum_7_7_5558_1551 = load %Reference, ptr %bitNum_7_7_5558_1551_pointer_1559, !noalias !2
        %sum_3_3_5426_1552_pointer_1560 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1556, i64 0, i32 3
        %sum_3_3_5426_1552 = load %Reference, ptr %sum_3_3_5426_1552_pointer_1560, !noalias !2
        %v_r_2586_55_146_330_330_5536_1553_pointer_1561 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1556, i64 0, i32 4
        %v_r_2586_55_146_330_330_5536_1553 = load i64, ptr %v_r_2586_55_146_330_330_5536_1553_pointer_1561, !noalias !2
        %byteAcc_5_5_5418_1554_pointer_1562 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1556, i64 0, i32 5
        %byteAcc_5_5_5418_1554 = load %Reference, ptr %byteAcc_5_5_5418_1554_pointer_1562, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1556)
        ret void
}



define tailcc void @returnAddress_1065(i64 %v_r_2586_55_146_330_330_5536, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1066 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 80)
        %i_6_91_275_275_5504_pointer_1067 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1066, i64 0, i32 0
        %i_6_91_275_275_5504 = load i64, ptr %i_6_91_275_275_5504_pointer_1067, !noalias !2
        %tmp_5795_pointer_1068 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1066, i64 0, i32 1
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_1068, !noalias !2
        %bitNum_7_7_5558_pointer_1069 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1066, i64 0, i32 2
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1069, !noalias !2
        %sum_3_3_5426_pointer_1070 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1066, i64 0, i32 3
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1070, !noalias !2
        %byteAcc_5_5_5418_pointer_1071 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1066, i64 0, i32 4
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1071, !noalias !2
        %escape_19_110_294_294_5368_pointer_1072 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1066, i64 0, i32 5
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_1072, !noalias !2
        %stackPointer_1563 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %i_6_91_275_275_5504_pointer_1564 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1563, i64 0, i32 0
        store i64 %i_6_91_275_275_5504, ptr %i_6_91_275_275_5504_pointer_1564, !noalias !2
        %tmp_5795_pointer_1565 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1563, i64 0, i32 1
        store i64 %tmp_5795, ptr %tmp_5795_pointer_1565, !noalias !2
        %bitNum_7_7_5558_pointer_1566 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1563, i64 0, i32 2
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1566, !noalias !2
        %sum_3_3_5426_pointer_1567 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1563, i64 0, i32 3
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1567, !noalias !2
        %v_r_2586_55_146_330_330_5536_pointer_1568 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1563, i64 0, i32 4
        store i64 %v_r_2586_55_146_330_330_5536, ptr %v_r_2586_55_146_330_330_5536_pointer_1568, !noalias !2
        %byteAcc_5_5_5418_pointer_1569 = getelementptr <{i64, i64, %Reference, %Reference, i64, %Reference}>, %StackPointer %stackPointer_1563, i64 0, i32 5
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1569, !noalias !2
        %returnAddress_pointer_1570 = getelementptr <{<{i64, i64, %Reference, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1563, i64 0, i32 1, i32 0
        %sharer_pointer_1571 = getelementptr <{<{i64, i64, %Reference, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1563, i64 0, i32 1, i32 1
        %eraser_pointer_1572 = getelementptr <{<{i64, i64, %Reference, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1563, i64 0, i32 1, i32 2
        store ptr @returnAddress_1073, ptr %returnAddress_pointer_1570, !noalias !2
        store ptr @sharer_1541, ptr %sharer_pointer_1571, !noalias !2
        store ptr @eraser_1555, ptr %eraser_pointer_1572, !noalias !2
        
        %get_5925_pointer_1573 = call ccc ptr @getVarPointer(%Reference %escape_19_110_294_294_5368, %Stack %stack)
        %escape_19_110_294_294_5368_old_1574 = load i64, ptr %get_5925_pointer_1573, !noalias !2
        %get_5925 = load i64, ptr %get_5925_pointer_1573, !noalias !2
        
        %stackPointer_1576 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1577 = getelementptr %FrameHeader, %StackPointer %stackPointer_1576, i64 0, i32 0
        %returnAddress_1575 = load %ReturnAddress, ptr %returnAddress_pointer_1577, !noalias !2
        musttail call tailcc void %returnAddress_1575(i64 %get_5925, %Stack %stack)
        ret void
}



define ccc void @sharer_1584(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1585 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_91_275_275_5504_1578_pointer_1586 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1585, i64 0, i32 0
        %i_6_91_275_275_5504_1578 = load i64, ptr %i_6_91_275_275_5504_1578_pointer_1586, !noalias !2
        %tmp_5795_1579_pointer_1587 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1585, i64 0, i32 1
        %tmp_5795_1579 = load i64, ptr %tmp_5795_1579_pointer_1587, !noalias !2
        %bitNum_7_7_5558_1580_pointer_1588 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1585, i64 0, i32 2
        %bitNum_7_7_5558_1580 = load %Reference, ptr %bitNum_7_7_5558_1580_pointer_1588, !noalias !2
        %sum_3_3_5426_1581_pointer_1589 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1585, i64 0, i32 3
        %sum_3_3_5426_1581 = load %Reference, ptr %sum_3_3_5426_1581_pointer_1589, !noalias !2
        %byteAcc_5_5_5418_1582_pointer_1590 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1585, i64 0, i32 4
        %byteAcc_5_5_5418_1582 = load %Reference, ptr %byteAcc_5_5_5418_1582_pointer_1590, !noalias !2
        %escape_19_110_294_294_5368_1583_pointer_1591 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1585, i64 0, i32 5
        %escape_19_110_294_294_5368_1583 = load %Reference, ptr %escape_19_110_294_294_5368_1583_pointer_1591, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1585)
        ret void
}



define ccc void @eraser_1598(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1599 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_91_275_275_5504_1592_pointer_1600 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1599, i64 0, i32 0
        %i_6_91_275_275_5504_1592 = load i64, ptr %i_6_91_275_275_5504_1592_pointer_1600, !noalias !2
        %tmp_5795_1593_pointer_1601 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1599, i64 0, i32 1
        %tmp_5795_1593 = load i64, ptr %tmp_5795_1593_pointer_1601, !noalias !2
        %bitNum_7_7_5558_1594_pointer_1602 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1599, i64 0, i32 2
        %bitNum_7_7_5558_1594 = load %Reference, ptr %bitNum_7_7_5558_1594_pointer_1602, !noalias !2
        %sum_3_3_5426_1595_pointer_1603 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1599, i64 0, i32 3
        %sum_3_3_5426_1595 = load %Reference, ptr %sum_3_3_5426_1595_pointer_1603, !noalias !2
        %byteAcc_5_5_5418_1596_pointer_1604 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1599, i64 0, i32 4
        %byteAcc_5_5_5418_1596 = load %Reference, ptr %byteAcc_5_5_5418_1596_pointer_1604, !noalias !2
        %escape_19_110_294_294_5368_1597_pointer_1605 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1599, i64 0, i32 5
        %escape_19_110_294_294_5368_1597 = load %Reference, ptr %escape_19_110_294_294_5368_1597_pointer_1605, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1599)
        ret void
}



define tailcc void @returnAddress_1057(%Pos %__54_145_329_329_5622, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1058 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 80)
        %i_6_91_275_275_5504_pointer_1059 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1058, i64 0, i32 0
        %i_6_91_275_275_5504 = load i64, ptr %i_6_91_275_275_5504_pointer_1059, !noalias !2
        %tmp_5795_pointer_1060 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1058, i64 0, i32 1
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_1060, !noalias !2
        %bitNum_7_7_5558_pointer_1061 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1058, i64 0, i32 2
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1061, !noalias !2
        %sum_3_3_5426_pointer_1062 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1058, i64 0, i32 3
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1062, !noalias !2
        %byteAcc_5_5_5418_pointer_1063 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1058, i64 0, i32 4
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1063, !noalias !2
        %escape_19_110_294_294_5368_pointer_1064 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1058, i64 0, i32 5
        %escape_19_110_294_294_5368 = load %Reference, ptr %escape_19_110_294_294_5368_pointer_1064, !noalias !2
        call ccc void @erasePositive(%Pos %__54_145_329_329_5622)
        %stackPointer_1606 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 104)
        %i_6_91_275_275_5504_pointer_1607 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1606, i64 0, i32 0
        store i64 %i_6_91_275_275_5504, ptr %i_6_91_275_275_5504_pointer_1607, !noalias !2
        %tmp_5795_pointer_1608 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1606, i64 0, i32 1
        store i64 %tmp_5795, ptr %tmp_5795_pointer_1608, !noalias !2
        %bitNum_7_7_5558_pointer_1609 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1606, i64 0, i32 2
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1609, !noalias !2
        %sum_3_3_5426_pointer_1610 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1606, i64 0, i32 3
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1610, !noalias !2
        %byteAcc_5_5_5418_pointer_1611 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1606, i64 0, i32 4
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1611, !noalias !2
        %escape_19_110_294_294_5368_pointer_1612 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1606, i64 0, i32 5
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_1612, !noalias !2
        %returnAddress_pointer_1613 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1606, i64 0, i32 1, i32 0
        %sharer_pointer_1614 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1606, i64 0, i32 1, i32 1
        %eraser_pointer_1615 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1606, i64 0, i32 1, i32 2
        store ptr @returnAddress_1065, ptr %returnAddress_pointer_1613, !noalias !2
        store ptr @sharer_1584, ptr %sharer_pointer_1614, !noalias !2
        store ptr @eraser_1598, ptr %eraser_pointer_1615, !noalias !2
        
        %get_5926_pointer_1616 = call ccc ptr @getVarPointer(%Reference %byteAcc_5_5_5418, %Stack %stack)
        %byteAcc_5_5_5418_old_1617 = load i64, ptr %get_5926_pointer_1616, !noalias !2
        %get_5926 = load i64, ptr %get_5926_pointer_1616, !noalias !2
        
        %stackPointer_1619 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1620 = getelementptr %FrameHeader, %StackPointer %stackPointer_1619, i64 0, i32 0
        %returnAddress_1618 = load %ReturnAddress, ptr %returnAddress_pointer_1620, !noalias !2
        musttail call tailcc void %returnAddress_1618(i64 %get_5926, %Stack %stack)
        ret void
}



define tailcc void @loop_5_90_274_274_5441(i64 %i_6_91_275_275_5504, i64 %tmp_5795, %Reference %bitNum_7_7_5558, double %tmp_5760, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5829 = call ccc %Pos @infixLt_178(i64 %i_6_91_275_275_5504, i64 %tmp_5795)
        
        
        
        %tag_70 = extractvalue %Pos %pureApp_5829, 0
        %fields_71 = extractvalue %Pos %pureApp_5829, 1
        switch i64 %tag_70, label %label_72 [i64 0, label %label_77 i64 1, label %label_1643]
    
    label_72:
        
        ret void
    
    label_77:
        
        %unitLiteral_5830_temporary_73 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5830 = insertvalue %Pos %unitLiteral_5830_temporary_73, %Object null, 1
        
        %stackPointer_75 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_76 = getelementptr %FrameHeader, %StackPointer %stackPointer_75, i64 0, i32 0
        %returnAddress_74 = load %ReturnAddress, ptr %returnAddress_pointer_76, !noalias !2
        musttail call tailcc void %returnAddress_74(%Pos %unitLiteral_5830, %Stack %stack)
        ret void
    
    label_1643:
        
        %doubleLiteral_5831 = fadd double 0.0, 0.0
        
        
        %stackPointer_114 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %i_6_91_275_275_5504_pointer_115 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 0
        store i64 %i_6_91_275_275_5504, ptr %i_6_91_275_275_5504_pointer_115, !noalias !2
        %tmp_5795_pointer_116 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 1
        store i64 %tmp_5795, ptr %tmp_5795_pointer_116, !noalias !2
        %bitNum_7_7_5558_pointer_117 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 2
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_117, !noalias !2
        %tmp_5760_pointer_118 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 3
        store double %tmp_5760, ptr %tmp_5760_pointer_118, !noalias !2
        %sum_3_3_5426_pointer_119 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 4
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_119, !noalias !2
        %byteAcc_5_5_5418_pointer_120 = getelementptr <{i64, i64, %Reference, double, %Reference, %Reference}>, %StackPointer %stackPointer_114, i64 0, i32 5
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_120, !noalias !2
        %returnAddress_pointer_121 = getelementptr <{<{i64, i64, %Reference, double, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_114, i64 0, i32 1, i32 0
        %sharer_pointer_122 = getelementptr <{<{i64, i64, %Reference, double, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_114, i64 0, i32 1, i32 1
        %eraser_pointer_123 = getelementptr <{<{i64, i64, %Reference, double, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_114, i64 0, i32 1, i32 2
        store ptr @returnAddress_78, ptr %returnAddress_pointer_121, !noalias !2
        store ptr @sharer_92, ptr %sharer_pointer_122, !noalias !2
        store ptr @eraser_106, ptr %eraser_pointer_123, !noalias !2
        %zrzr_3_94_278_278_5552 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_139 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2559_2_93_277_277_5287_pointer_140 = getelementptr <{double}>, %StackPointer %stackPointer_139, i64 0, i32 0
        store double %doubleLiteral_5831, ptr %v_r_2559_2_93_277_277_5287_pointer_140, !noalias !2
        %returnAddress_pointer_141 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_139, i64 0, i32 1, i32 0
        %sharer_pointer_142 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_139, i64 0, i32 1, i32 1
        %eraser_pointer_143 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_139, i64 0, i32 1, i32 2
        store ptr @returnAddress_124, ptr %returnAddress_pointer_141, !noalias !2
        store ptr @sharer_132, ptr %sharer_pointer_142, !noalias !2
        store ptr @eraser_136, ptr %eraser_pointer_143, !noalias !2
        
        %doubleLiteral_5835 = fadd double 0.0, 0.0
        
        
        %zi_5_96_280_280_5410 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_153 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2560_4_95_279_279_5285_pointer_154 = getelementptr <{double}>, %StackPointer %stackPointer_153, i64 0, i32 0
        store double %doubleLiteral_5835, ptr %v_r_2560_4_95_279_279_5285_pointer_154, !noalias !2
        %returnAddress_pointer_155 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_153, i64 0, i32 1, i32 0
        %sharer_pointer_156 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_153, i64 0, i32 1, i32 1
        %eraser_pointer_157 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_153, i64 0, i32 1, i32 2
        store ptr @returnAddress_144, ptr %returnAddress_pointer_155, !noalias !2
        store ptr @sharer_132, ptr %sharer_pointer_156, !noalias !2
        store ptr @eraser_136, ptr %eraser_pointer_157, !noalias !2
        
        %doubleLiteral_5837 = fadd double 0.0, 0.0
        
        
        %zizi_7_98_282_282_5424 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_167 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2561_6_97_281_281_5529_pointer_168 = getelementptr <{double}>, %StackPointer %stackPointer_167, i64 0, i32 0
        store double %doubleLiteral_5837, ptr %v_r_2561_6_97_281_281_5529_pointer_168, !noalias !2
        %returnAddress_pointer_169 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_167, i64 0, i32 1, i32 0
        %sharer_pointer_170 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_167, i64 0, i32 1, i32 1
        %eraser_pointer_171 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_167, i64 0, i32 1, i32 2
        store ptr @returnAddress_158, ptr %returnAddress_pointer_169, !noalias !2
        store ptr @sharer_132, ptr %sharer_pointer_170, !noalias !2
        store ptr @eraser_136, ptr %eraser_pointer_171, !noalias !2
        
        %pureApp_5839 = call ccc double @toDouble_156(i64 %i_6_91_275_275_5504)
        
        
        
        %doubleLiteral_5841 = fadd double 2.0, 0.0
        
        %pureApp_5840 = call ccc double @infixMul_114(double %doubleLiteral_5841, double %pureApp_5839)
        
        
        
        %pureApp_5842 = call ccc double @toDouble_156(i64 %tmp_5795)
        
        
        
        %pureApp_5843 = call ccc double @infixDiv_120(double %pureApp_5840, double %pureApp_5842)
        
        
        
        %doubleLiteral_5845 = fadd double 1.5, 0.0
        
        %pureApp_5844 = call ccc double @infixSub_117(double %pureApp_5843, double %doubleLiteral_5845)
        
        
        
        %longLiteral_5846 = add i64 0, 0
        
        
        %z_15_106_290_290_5374 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_181 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2562_14_105_289_289_5541_pointer_182 = getelementptr <{i64}>, %StackPointer %stackPointer_181, i64 0, i32 0
        store i64 %longLiteral_5846, ptr %v_r_2562_14_105_289_289_5541_pointer_182, !noalias !2
        %returnAddress_pointer_183 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_181, i64 0, i32 1, i32 0
        %sharer_pointer_184 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_181, i64 0, i32 1, i32 1
        %eraser_pointer_185 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_181, i64 0, i32 1, i32 2
        store ptr @returnAddress_172, ptr %returnAddress_pointer_183, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_184, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_185, !noalias !2
        
        %booleanLiteral_5848_temporary_186 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5848 = insertvalue %Pos %booleanLiteral_5848_temporary_186, %Object null, 1
        
        
        %notDone_17_108_292_292_5542 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_202 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %v_r_2563_16_107_291_291_5489_pointer_203 = getelementptr <{%Pos}>, %StackPointer %stackPointer_202, i64 0, i32 0
        store %Pos %booleanLiteral_5848, ptr %v_r_2563_16_107_291_291_5489_pointer_203, !noalias !2
        %returnAddress_pointer_204 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_202, i64 0, i32 1, i32 0
        %sharer_pointer_205 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_202, i64 0, i32 1, i32 1
        %eraser_pointer_206 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_202, i64 0, i32 1, i32 2
        store ptr @returnAddress_187, ptr %returnAddress_pointer_204, !noalias !2
        store ptr @sharer_195, ptr %sharer_pointer_205, !noalias !2
        store ptr @eraser_199, ptr %eraser_pointer_206, !noalias !2
        
        %longLiteral_5850 = add i64 0, 0
        
        
        %escape_19_110_294_294_5368 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_216 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2564_18_109_293_293_5537_pointer_217 = getelementptr <{i64}>, %StackPointer %stackPointer_216, i64 0, i32 0
        store i64 %longLiteral_5850, ptr %v_r_2564_18_109_293_293_5537_pointer_217, !noalias !2
        %returnAddress_pointer_218 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_216, i64 0, i32 1, i32 0
        %sharer_pointer_219 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_216, i64 0, i32 1, i32 1
        %eraser_pointer_220 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_216, i64 0, i32 1, i32 2
        store ptr @returnAddress_207, ptr %returnAddress_pointer_218, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_219, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_220, !noalias !2
        %stackPointer_1633 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 104)
        %i_6_91_275_275_5504_pointer_1634 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1633, i64 0, i32 0
        store i64 %i_6_91_275_275_5504, ptr %i_6_91_275_275_5504_pointer_1634, !noalias !2
        %tmp_5795_pointer_1635 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1633, i64 0, i32 1
        store i64 %tmp_5795, ptr %tmp_5795_pointer_1635, !noalias !2
        %bitNum_7_7_5558_pointer_1636 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1633, i64 0, i32 2
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1636, !noalias !2
        %sum_3_3_5426_pointer_1637 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1633, i64 0, i32 3
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1637, !noalias !2
        %byteAcc_5_5_5418_pointer_1638 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1633, i64 0, i32 4
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1638, !noalias !2
        %escape_19_110_294_294_5368_pointer_1639 = getelementptr <{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %StackPointer %stackPointer_1633, i64 0, i32 5
        store %Reference %escape_19_110_294_294_5368, ptr %escape_19_110_294_294_5368_pointer_1639, !noalias !2
        %returnAddress_pointer_1640 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1633, i64 0, i32 1, i32 0
        %sharer_pointer_1641 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1633, i64 0, i32 1, i32 1
        %eraser_pointer_1642 = getelementptr <{<{i64, i64, %Reference, %Reference, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1633, i64 0, i32 1, i32 2
        store ptr @returnAddress_1057, ptr %returnAddress_pointer_1640, !noalias !2
        store ptr @sharer_1584, ptr %sharer_pointer_1641, !noalias !2
        store ptr @eraser_1598, ptr %eraser_pointer_1642, !noalias !2
        
        
        musttail call tailcc void @b_whileLoop_2565_20_111_295_295_5509(double %pureApp_5844, %Reference %zizi_7_98_282_282_5424, %Reference %zrzr_3_94_278_278_5552, double %tmp_5760, %Reference %notDone_17_108_292_292_5542, %Reference %z_15_106_290_290_5374, %Reference %zi_5_96_280_280_5410, %Reference %escape_19_110_294_294_5368, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1644(%Pos %__8_359_359_5631, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1645 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %tmp_5795_pointer_1646 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1645, i64 0, i32 0
        %tmp_5795 = load i64, ptr %tmp_5795_pointer_1646, !noalias !2
        %bitNum_7_7_5558_pointer_1647 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1645, i64 0, i32 1
        %bitNum_7_7_5558 = load %Reference, ptr %bitNum_7_7_5558_pointer_1647, !noalias !2
        %i_6_184_184_5319_pointer_1648 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1645, i64 0, i32 2
        %i_6_184_184_5319 = load i64, ptr %i_6_184_184_5319_pointer_1648, !noalias !2
        %sum_3_3_5426_pointer_1649 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1645, i64 0, i32 3
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1649, !noalias !2
        %byteAcc_5_5_5418_pointer_1650 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1645, i64 0, i32 4
        %byteAcc_5_5_5418 = load %Reference, ptr %byteAcc_5_5_5418_pointer_1650, !noalias !2
        call ccc void @erasePositive(%Pos %__8_359_359_5631)
        
        %longLiteral_5928 = add i64 1, 0
        
        %pureApp_5927 = call ccc i64 @infixAdd_96(i64 %i_6_184_184_5319, i64 %longLiteral_5928)
        
        
        
        
        
        musttail call tailcc void @loop_5_183_183_5532(i64 %pureApp_5927, i64 %tmp_5795, %Reference %bitNum_7_7_5558, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, %Stack %stack)
        ret void
}



define ccc void @sharer_1656(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1657 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5795_1651_pointer_1658 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1657, i64 0, i32 0
        %tmp_5795_1651 = load i64, ptr %tmp_5795_1651_pointer_1658, !noalias !2
        %bitNum_7_7_5558_1652_pointer_1659 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1657, i64 0, i32 1
        %bitNum_7_7_5558_1652 = load %Reference, ptr %bitNum_7_7_5558_1652_pointer_1659, !noalias !2
        %i_6_184_184_5319_1653_pointer_1660 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1657, i64 0, i32 2
        %i_6_184_184_5319_1653 = load i64, ptr %i_6_184_184_5319_1653_pointer_1660, !noalias !2
        %sum_3_3_5426_1654_pointer_1661 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1657, i64 0, i32 3
        %sum_3_3_5426_1654 = load %Reference, ptr %sum_3_3_5426_1654_pointer_1661, !noalias !2
        %byteAcc_5_5_5418_1655_pointer_1662 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1657, i64 0, i32 4
        %byteAcc_5_5_5418_1655 = load %Reference, ptr %byteAcc_5_5_5418_1655_pointer_1662, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1657)
        ret void
}



define ccc void @eraser_1668(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1669 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5795_1663_pointer_1670 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1669, i64 0, i32 0
        %tmp_5795_1663 = load i64, ptr %tmp_5795_1663_pointer_1670, !noalias !2
        %bitNum_7_7_5558_1664_pointer_1671 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1669, i64 0, i32 1
        %bitNum_7_7_5558_1664 = load %Reference, ptr %bitNum_7_7_5558_1664_pointer_1671, !noalias !2
        %i_6_184_184_5319_1665_pointer_1672 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1669, i64 0, i32 2
        %i_6_184_184_5319_1665 = load i64, ptr %i_6_184_184_5319_1665_pointer_1672, !noalias !2
        %sum_3_3_5426_1666_pointer_1673 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1669, i64 0, i32 3
        %sum_3_3_5426_1666 = load %Reference, ptr %sum_3_3_5426_1666_pointer_1673, !noalias !2
        %byteAcc_5_5_5418_1667_pointer_1674 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1669, i64 0, i32 4
        %byteAcc_5_5_5418_1667 = load %Reference, ptr %byteAcc_5_5_5418_1667_pointer_1674, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1669)
        ret void
}



define tailcc void @loop_5_183_183_5532(i64 %i_6_184_184_5319, i64 %tmp_5795, %Reference %bitNum_7_7_5558, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5820 = call ccc %Pos @infixLt_178(i64 %i_6_184_184_5319, i64 %tmp_5795)
        
        
        
        %tag_62 = extractvalue %Pos %pureApp_5820, 0
        %fields_63 = extractvalue %Pos %pureApp_5820, 1
        switch i64 %tag_62, label %label_64 [i64 0, label %label_69 i64 1, label %label_1684]
    
    label_64:
        
        ret void
    
    label_69:
        
        %unitLiteral_5821_temporary_65 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5821 = insertvalue %Pos %unitLiteral_5821_temporary_65, %Object null, 1
        
        %stackPointer_67 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_68 = getelementptr %FrameHeader, %StackPointer %stackPointer_67, i64 0, i32 0
        %returnAddress_66 = load %ReturnAddress, ptr %returnAddress_pointer_68, !noalias !2
        musttail call tailcc void %returnAddress_66(%Pos %unitLiteral_5821, %Stack %stack)
        ret void
    
    label_1684:
        
        %pureApp_5822 = call ccc double @toDouble_156(i64 %i_6_184_184_5319)
        
        
        
        %doubleLiteral_5824 = fadd double 2.0, 0.0
        
        %pureApp_5823 = call ccc double @infixMul_114(double %doubleLiteral_5824, double %pureApp_5822)
        
        
        
        %pureApp_5825 = call ccc double @toDouble_156(i64 %tmp_5795)
        
        
        
        %pureApp_5826 = call ccc double @infixDiv_120(double %pureApp_5823, double %pureApp_5825)
        
        
        
        %doubleLiteral_5828 = fadd double 1.0, 0.0
        
        %pureApp_5827 = call ccc double @infixSub_117(double %pureApp_5826, double %doubleLiteral_5828)
        
        
        %stackPointer_1675 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %tmp_5795_pointer_1676 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1675, i64 0, i32 0
        store i64 %tmp_5795, ptr %tmp_5795_pointer_1676, !noalias !2
        %bitNum_7_7_5558_pointer_1677 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1675, i64 0, i32 1
        store %Reference %bitNum_7_7_5558, ptr %bitNum_7_7_5558_pointer_1677, !noalias !2
        %i_6_184_184_5319_pointer_1678 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1675, i64 0, i32 2
        store i64 %i_6_184_184_5319, ptr %i_6_184_184_5319_pointer_1678, !noalias !2
        %sum_3_3_5426_pointer_1679 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1675, i64 0, i32 3
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1679, !noalias !2
        %byteAcc_5_5_5418_pointer_1680 = getelementptr <{i64, %Reference, i64, %Reference, %Reference}>, %StackPointer %stackPointer_1675, i64 0, i32 4
        store %Reference %byteAcc_5_5_5418, ptr %byteAcc_5_5_5418_pointer_1680, !noalias !2
        %returnAddress_pointer_1681 = getelementptr <{<{i64, %Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1675, i64 0, i32 1, i32 0
        %sharer_pointer_1682 = getelementptr <{<{i64, %Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1675, i64 0, i32 1, i32 1
        %eraser_pointer_1683 = getelementptr <{<{i64, %Reference, i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1675, i64 0, i32 1, i32 2
        store ptr @returnAddress_1644, ptr %returnAddress_pointer_1681, !noalias !2
        store ptr @sharer_1656, ptr %sharer_pointer_1682, !noalias !2
        store ptr @eraser_1668, ptr %eraser_pointer_1683, !noalias !2
        
        %longLiteral_5929 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_90_274_274_5441(i64 %longLiteral_5929, i64 %tmp_5795, %Reference %bitNum_7_7_5558, double %pureApp_5827, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1685(%Pos %__361_361_5632, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1686 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %sum_3_3_5426_pointer_1687 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1686, i64 0, i32 0
        %sum_3_3_5426 = load %Reference, ptr %sum_3_3_5426_pointer_1687, !noalias !2
        call ccc void @erasePositive(%Pos %__361_361_5632)
        
        %get_5930_pointer_1688 = call ccc ptr @getVarPointer(%Reference %sum_3_3_5426, %Stack %stack)
        %sum_3_3_5426_old_1689 = load i64, ptr %get_5930_pointer_1688, !noalias !2
        %get_5930 = load i64, ptr %get_5930_pointer_1688, !noalias !2
        
        %stackPointer_1691 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1692 = getelementptr %FrameHeader, %StackPointer %stackPointer_1691, i64 0, i32 0
        %returnAddress_1690 = load %ReturnAddress, ptr %returnAddress_pointer_1692, !noalias !2
        musttail call tailcc void %returnAddress_1690(i64 %get_5930, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3553_3617, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5811 = call ccc i64 @unboxInt_303(%Pos %v_coe_3553_3617)
        
        
        
        %longLiteral_5812 = add i64 0, 0
        
        
        %stackPointer_10 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 0
        %sharer_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 1
        %eraser_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_11, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_12, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_13, !noalias !2
        %sum_3_3_5426 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_29 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2555_2_2_5347_pointer_30 = getelementptr <{i64}>, %StackPointer %stackPointer_29, i64 0, i32 0
        store i64 %longLiteral_5812, ptr %v_r_2555_2_2_5347_pointer_30, !noalias !2
        %returnAddress_pointer_31 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 0
        %sharer_pointer_32 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 1
        %eraser_pointer_33 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 2
        store ptr @returnAddress_14, ptr %returnAddress_pointer_31, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_32, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_33, !noalias !2
        
        %longLiteral_5816 = add i64 0, 0
        
        
        %byteAcc_5_5_5418 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_43 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2556_4_4_5531_pointer_44 = getelementptr <{i64}>, %StackPointer %stackPointer_43, i64 0, i32 0
        store i64 %longLiteral_5816, ptr %v_r_2556_4_4_5531_pointer_44, !noalias !2
        %returnAddress_pointer_45 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_43, i64 0, i32 1, i32 0
        %sharer_pointer_46 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_43, i64 0, i32 1, i32 1
        %eraser_pointer_47 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_43, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_45, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_46, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_47, !noalias !2
        
        %longLiteral_5818 = add i64 0, 0
        
        
        %bitNum_7_7_5558 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_57 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2557_6_6_5291_pointer_58 = getelementptr <{i64}>, %StackPointer %stackPointer_57, i64 0, i32 0
        store i64 %longLiteral_5818, ptr %v_r_2557_6_6_5291_pointer_58, !noalias !2
        %returnAddress_pointer_59 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_57, i64 0, i32 1, i32 0
        %sharer_pointer_60 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_57, i64 0, i32 1, i32 1
        %eraser_pointer_61 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_57, i64 0, i32 1, i32 2
        store ptr @returnAddress_48, ptr %returnAddress_pointer_59, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_60, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_61, !noalias !2
        %stackPointer_1695 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %sum_3_3_5426_pointer_1696 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1695, i64 0, i32 0
        store %Reference %sum_3_3_5426, ptr %sum_3_3_5426_pointer_1696, !noalias !2
        %returnAddress_pointer_1697 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1695, i64 0, i32 1, i32 0
        %sharer_pointer_1698 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1695, i64 0, i32 1, i32 1
        %eraser_pointer_1699 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1695, i64 0, i32 1, i32 2
        store ptr @returnAddress_1685, ptr %returnAddress_pointer_1697, !noalias !2
        store ptr @sharer_517, ptr %sharer_pointer_1698, !noalias !2
        store ptr @eraser_521, ptr %eraser_pointer_1699, !noalias !2
        
        %longLiteral_5931 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_183_183_5532(i64 %longLiteral_5931, i64 %pureApp_5811, %Reference %bitNum_7_7_5558, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1705(%Pos %returned_5932, %Stack %stack) {
        
    entry:
        
        %stack_1706 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_1708 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1706, i64 24)
        %returnAddress_pointer_1709 = getelementptr %FrameHeader, %StackPointer %stackPointer_1708, i64 0, i32 0
        %returnAddress_1707 = load %ReturnAddress, ptr %returnAddress_pointer_1709, !noalias !2
        musttail call tailcc void %returnAddress_1707(%Pos %returned_5932, %Stack %stack_1706)
        ret void
}



define ccc void @sharer_1710(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1711 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_1712(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1713 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_1713)
        ret void
}



define ccc void @eraser_1725(%Environment %environment) {
        
    entry:
        
        %tmp_5728_1723_pointer_1726 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5728_1723 = load %Pos, ptr %tmp_5728_1723_pointer_1726, !noalias !2
        %acc_3_3_5_169_5114_1724_pointer_1727 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_5114_1724 = load %Pos, ptr %acc_3_3_5_169_5114_1724_pointer_1727, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5728_1723)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_5114_1724)
        ret void
}



define tailcc void @toList_1_1_3_167_4973(i64 %start_2_2_4_168_5213, %Pos %acc_3_3_5_169_5114, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5934 = add i64 1, 0
        
        %pureApp_5933 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_5213, i64 %longLiteral_5934)
        
        
        
        %tag_1718 = extractvalue %Pos %pureApp_5933, 0
        %fields_1719 = extractvalue %Pos %pureApp_5933, 1
        switch i64 %tag_1718, label %label_1720 [i64 0, label %label_1731 i64 1, label %label_1735]
    
    label_1720:
        
        ret void
    
    label_1731:
        
        %pureApp_5935 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_5213)
        
        
        
        %longLiteral_5937 = add i64 1, 0
        
        %pureApp_5936 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_5213, i64 %longLiteral_5937)
        
        
        
        %fields_1721 = call ccc %Object @newObject(ptr @eraser_1725, i64 32)
        %environment_1722 = call ccc %Environment @objectEnvironment(%Object %fields_1721)
        %tmp_5728_pointer_1728 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1722, i64 0, i32 0
        store %Pos %pureApp_5935, ptr %tmp_5728_pointer_1728, !noalias !2
        %acc_3_3_5_169_5114_pointer_1729 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1722, i64 0, i32 1
        store %Pos %acc_3_3_5_169_5114, ptr %acc_3_3_5_169_5114_pointer_1729, !noalias !2
        %make_5938_temporary_1730 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5938 = insertvalue %Pos %make_5938_temporary_1730, %Object %fields_1721, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4973(i64 %pureApp_5936, %Pos %make_5938, %Stack %stack)
        ret void
    
    label_1735:
        
        %stackPointer_1733 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1734 = getelementptr %FrameHeader, %StackPointer %stackPointer_1733, i64 0, i32 0
        %returnAddress_1732 = load %ReturnAddress, ptr %returnAddress_pointer_1734, !noalias !2
        musttail call tailcc void %returnAddress_1732(%Pos %acc_3_3_5_169_5114, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1746(%Pos %v_r_2710_32_59_223_5049, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1747 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_5735_pointer_1748 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1747, i64 0, i32 0
        %tmp_5735 = load i64, ptr %tmp_5735_pointer_1748, !noalias !2
        %index_7_34_198_4957_pointer_1749 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1747, i64 0, i32 1
        %index_7_34_198_4957 = load i64, ptr %index_7_34_198_4957_pointer_1749, !noalias !2
        %acc_8_35_199_4956_pointer_1750 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1747, i64 0, i32 2
        %acc_8_35_199_4956 = load i64, ptr %acc_8_35_199_4956_pointer_1750, !noalias !2
        %v_r_2613_30_194_5131_pointer_1751 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1747, i64 0, i32 3
        %v_r_2613_30_194_5131 = load %Pos, ptr %v_r_2613_30_194_5131_pointer_1751, !noalias !2
        %p_8_9_4906_pointer_1752 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1747, i64 0, i32 4
        %p_8_9_4906 = load %Prompt, ptr %p_8_9_4906_pointer_1752, !noalias !2
        
        %tag_1753 = extractvalue %Pos %v_r_2710_32_59_223_5049, 0
        %fields_1754 = extractvalue %Pos %v_r_2710_32_59_223_5049, 1
        switch i64 %tag_1753, label %label_1755 [i64 1, label %label_1778 i64 0, label %label_1785]
    
    label_1755:
        
        ret void
    
    label_1760:
        
        ret void
    
    label_1766:
        call ccc void @erasePositive(%Pos %v_r_2613_30_194_5131)
        
        %pair_1761 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4906)
        %k_13_14_4_5637 = extractvalue <{%Resumption, %Stack}> %pair_1761, 0
        %stack_1762 = extractvalue <{%Resumption, %Stack}> %pair_1761, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5637)
        
        %longLiteral_5950 = add i64 10, 0
        
        
        
        %pureApp_5951 = call ccc %Pos @boxInt_301(i64 %longLiteral_5950)
        
        
        
        %stackPointer_1764 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1762, i64 24)
        %returnAddress_pointer_1765 = getelementptr %FrameHeader, %StackPointer %stackPointer_1764, i64 0, i32 0
        %returnAddress_1763 = load %ReturnAddress, ptr %returnAddress_pointer_1765, !noalias !2
        musttail call tailcc void %returnAddress_1763(%Pos %pureApp_5951, %Stack %stack_1762)
        ret void
    
    label_1769:
        
        ret void
    
    label_1775:
        call ccc void @erasePositive(%Pos %v_r_2613_30_194_5131)
        
        %pair_1770 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4906)
        %k_13_14_4_5636 = extractvalue <{%Resumption, %Stack}> %pair_1770, 0
        %stack_1771 = extractvalue <{%Resumption, %Stack}> %pair_1770, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5636)
        
        %longLiteral_5954 = add i64 10, 0
        
        
        
        %pureApp_5955 = call ccc %Pos @boxInt_301(i64 %longLiteral_5954)
        
        
        
        %stackPointer_1773 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1771, i64 24)
        %returnAddress_pointer_1774 = getelementptr %FrameHeader, %StackPointer %stackPointer_1773, i64 0, i32 0
        %returnAddress_1772 = load %ReturnAddress, ptr %returnAddress_pointer_1774, !noalias !2
        musttail call tailcc void %returnAddress_1772(%Pos %pureApp_5955, %Stack %stack_1771)
        ret void
    
    label_1776:
        
        %longLiteral_5957 = add i64 1, 0
        
        %pureApp_5956 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4957, i64 %longLiteral_5957)
        
        
        
        %longLiteral_5959 = add i64 10, 0
        
        %pureApp_5958 = call ccc i64 @infixMul_99(i64 %longLiteral_5959, i64 %acc_8_35_199_4956)
        
        
        
        %pureApp_5960 = call ccc i64 @toInt_2085(i64 %pureApp_5947)
        
        
        
        %pureApp_5961 = call ccc i64 @infixSub_105(i64 %pureApp_5960, i64 %tmp_5735)
        
        
        
        %pureApp_5962 = call ccc i64 @infixAdd_96(i64 %pureApp_5958, i64 %pureApp_5961)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_5069(i64 %pureApp_5956, i64 %pureApp_5962, i64 %tmp_5735, %Pos %v_r_2613_30_194_5131, %Prompt %p_8_9_4906, %Stack %stack)
        ret void
    
    label_1777:
        
        %intLiteral_5953 = add i64 57, 0
        
        %pureApp_5952 = call ccc %Pos @infixLte_2093(i64 %pureApp_5947, i64 %intLiteral_5953)
        
        
        
        %tag_1767 = extractvalue %Pos %pureApp_5952, 0
        %fields_1768 = extractvalue %Pos %pureApp_5952, 1
        switch i64 %tag_1767, label %label_1769 [i64 0, label %label_1775 i64 1, label %label_1776]
    
    label_1778:
        %environment_1756 = call ccc %Environment @objectEnvironment(%Object %fields_1754)
        %v_coe_3528_46_73_237_5160_pointer_1757 = getelementptr <{%Pos}>, %Environment %environment_1756, i64 0, i32 0
        %v_coe_3528_46_73_237_5160 = load %Pos, ptr %v_coe_3528_46_73_237_5160_pointer_1757, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3528_46_73_237_5160)
        call ccc void @eraseObject(%Object %fields_1754)
        
        %pureApp_5947 = call ccc i64 @unboxChar_313(%Pos %v_coe_3528_46_73_237_5160)
        
        
        
        %intLiteral_5949 = add i64 48, 0
        
        %pureApp_5948 = call ccc %Pos @infixGte_2099(i64 %pureApp_5947, i64 %intLiteral_5949)
        
        
        
        %tag_1758 = extractvalue %Pos %pureApp_5948, 0
        %fields_1759 = extractvalue %Pos %pureApp_5948, 1
        switch i64 %tag_1758, label %label_1760 [i64 0, label %label_1766 i64 1, label %label_1777]
    
    label_1785:
        %environment_1779 = call ccc %Environment @objectEnvironment(%Object %fields_1754)
        %v_y_2717_76_103_267_5945_pointer_1780 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1779, i64 0, i32 0
        %v_y_2717_76_103_267_5945 = load %Pos, ptr %v_y_2717_76_103_267_5945_pointer_1780, !noalias !2
        %v_y_2718_77_104_268_5946_pointer_1781 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1779, i64 0, i32 1
        %v_y_2718_77_104_268_5946 = load %Pos, ptr %v_y_2718_77_104_268_5946_pointer_1781, !noalias !2
        call ccc void @eraseObject(%Object %fields_1754)
        call ccc void @erasePositive(%Pos %v_r_2613_30_194_5131)
        
        %stackPointer_1783 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1784 = getelementptr %FrameHeader, %StackPointer %stackPointer_1783, i64 0, i32 0
        %returnAddress_1782 = load %ReturnAddress, ptr %returnAddress_pointer_1784, !noalias !2
        musttail call tailcc void %returnAddress_1782(i64 %acc_8_35_199_4956, %Stack %stack)
        ret void
}



define ccc void @sharer_1791(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1792 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_5735_1786_pointer_1793 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1792, i64 0, i32 0
        %tmp_5735_1786 = load i64, ptr %tmp_5735_1786_pointer_1793, !noalias !2
        %index_7_34_198_4957_1787_pointer_1794 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1792, i64 0, i32 1
        %index_7_34_198_4957_1787 = load i64, ptr %index_7_34_198_4957_1787_pointer_1794, !noalias !2
        %acc_8_35_199_4956_1788_pointer_1795 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1792, i64 0, i32 2
        %acc_8_35_199_4956_1788 = load i64, ptr %acc_8_35_199_4956_1788_pointer_1795, !noalias !2
        %v_r_2613_30_194_5131_1789_pointer_1796 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1792, i64 0, i32 3
        %v_r_2613_30_194_5131_1789 = load %Pos, ptr %v_r_2613_30_194_5131_1789_pointer_1796, !noalias !2
        %p_8_9_4906_1790_pointer_1797 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1792, i64 0, i32 4
        %p_8_9_4906_1790 = load %Prompt, ptr %p_8_9_4906_1790_pointer_1797, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2613_30_194_5131_1789)
        call ccc void @shareFrames(%StackPointer %stackPointer_1792)
        ret void
}



define ccc void @eraser_1803(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1804 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_5735_1798_pointer_1805 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1804, i64 0, i32 0
        %tmp_5735_1798 = load i64, ptr %tmp_5735_1798_pointer_1805, !noalias !2
        %index_7_34_198_4957_1799_pointer_1806 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1804, i64 0, i32 1
        %index_7_34_198_4957_1799 = load i64, ptr %index_7_34_198_4957_1799_pointer_1806, !noalias !2
        %acc_8_35_199_4956_1800_pointer_1807 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1804, i64 0, i32 2
        %acc_8_35_199_4956_1800 = load i64, ptr %acc_8_35_199_4956_1800_pointer_1807, !noalias !2
        %v_r_2613_30_194_5131_1801_pointer_1808 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1804, i64 0, i32 3
        %v_r_2613_30_194_5131_1801 = load %Pos, ptr %v_r_2613_30_194_5131_1801_pointer_1808, !noalias !2
        %p_8_9_4906_1802_pointer_1809 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1804, i64 0, i32 4
        %p_8_9_4906_1802 = load %Prompt, ptr %p_8_9_4906_1802_pointer_1809, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2613_30_194_5131_1801)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1804)
        ret void
}



define tailcc void @returnAddress_1820(%Pos %returned_5963, %Stack %stack) {
        
    entry:
        
        %stack_1821 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_1823 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1821, i64 24)
        %returnAddress_pointer_1824 = getelementptr %FrameHeader, %StackPointer %stackPointer_1823, i64 0, i32 0
        %returnAddress_1822 = load %ReturnAddress, ptr %returnAddress_pointer_1824, !noalias !2
        musttail call tailcc void %returnAddress_1822(%Pos %returned_5963, %Stack %stack_1821)
        ret void
}



define tailcc void @Exception_7_19_46_210_5086_clause_1829(%Object %closure, %Pos %exc_8_20_47_211_5191, %Pos %msg_9_21_48_212_4945, %Stack %stack) {
        
    entry:
        
        %environment_1830 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4953_pointer_1831 = getelementptr <{%Prompt}>, %Environment %environment_1830, i64 0, i32 0
        %p_6_18_45_209_4953 = load %Prompt, ptr %p_6_18_45_209_4953_pointer_1831, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_1832 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4953)
        %k_11_23_50_214_5231 = extractvalue <{%Resumption, %Stack}> %pair_1832, 0
        %stack_1833 = extractvalue <{%Resumption, %Stack}> %pair_1832, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_5231)
        
        %fields_1834 = call ccc %Object @newObject(ptr @eraser_1725, i64 32)
        %environment_1835 = call ccc %Environment @objectEnvironment(%Object %fields_1834)
        %exc_8_20_47_211_5191_pointer_1838 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1835, i64 0, i32 0
        store %Pos %exc_8_20_47_211_5191, ptr %exc_8_20_47_211_5191_pointer_1838, !noalias !2
        %msg_9_21_48_212_4945_pointer_1839 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1835, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4945, ptr %msg_9_21_48_212_4945_pointer_1839, !noalias !2
        %make_5964_temporary_1840 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5964 = insertvalue %Pos %make_5964_temporary_1840, %Object %fields_1834, 1
        
        
        
        %stackPointer_1842 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1833, i64 24)
        %returnAddress_pointer_1843 = getelementptr %FrameHeader, %StackPointer %stackPointer_1842, i64 0, i32 0
        %returnAddress_1841 = load %ReturnAddress, ptr %returnAddress_pointer_1843, !noalias !2
        musttail call tailcc void %returnAddress_1841(%Pos %make_5964, %Stack %stack_1833)
        ret void
}


@vtable_1844 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_5086_clause_1829]


define ccc void @eraser_1848(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4953_1847_pointer_1849 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4953_1847 = load %Prompt, ptr %p_6_18_45_209_4953_1847_pointer_1849, !noalias !2
        ret void
}



define ccc void @eraser_1856(%Environment %environment) {
        
    entry:
        
        %tmp_5737_1855_pointer_1857 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5737_1855 = load %Pos, ptr %tmp_5737_1855_pointer_1857, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5737_1855)
        ret void
}



define tailcc void @returnAddress_1852(i64 %v_coe_3527_6_28_55_219_5211, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5965 = call ccc %Pos @boxChar_311(i64 %v_coe_3527_6_28_55_219_5211)
        
        
        
        %fields_1853 = call ccc %Object @newObject(ptr @eraser_1856, i64 16)
        %environment_1854 = call ccc %Environment @objectEnvironment(%Object %fields_1853)
        %tmp_5737_pointer_1858 = getelementptr <{%Pos}>, %Environment %environment_1854, i64 0, i32 0
        store %Pos %pureApp_5965, ptr %tmp_5737_pointer_1858, !noalias !2
        %make_5966_temporary_1859 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5966 = insertvalue %Pos %make_5966_temporary_1859, %Object %fields_1853, 1
        
        
        
        %stackPointer_1861 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1862 = getelementptr %FrameHeader, %StackPointer %stackPointer_1861, i64 0, i32 0
        %returnAddress_1860 = load %ReturnAddress, ptr %returnAddress_pointer_1862, !noalias !2
        musttail call tailcc void %returnAddress_1860(%Pos %make_5966, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_5069(i64 %index_7_34_198_4957, i64 %acc_8_35_199_4956, i64 %tmp_5735, %Pos %v_r_2613_30_194_5131, %Prompt %p_8_9_4906, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2613_30_194_5131)
        %stackPointer_1810 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_5735_pointer_1811 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1810, i64 0, i32 0
        store i64 %tmp_5735, ptr %tmp_5735_pointer_1811, !noalias !2
        %index_7_34_198_4957_pointer_1812 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1810, i64 0, i32 1
        store i64 %index_7_34_198_4957, ptr %index_7_34_198_4957_pointer_1812, !noalias !2
        %acc_8_35_199_4956_pointer_1813 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1810, i64 0, i32 2
        store i64 %acc_8_35_199_4956, ptr %acc_8_35_199_4956_pointer_1813, !noalias !2
        %v_r_2613_30_194_5131_pointer_1814 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1810, i64 0, i32 3
        store %Pos %v_r_2613_30_194_5131, ptr %v_r_2613_30_194_5131_pointer_1814, !noalias !2
        %p_8_9_4906_pointer_1815 = getelementptr <{i64, i64, i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1810, i64 0, i32 4
        store %Prompt %p_8_9_4906, ptr %p_8_9_4906_pointer_1815, !noalias !2
        %returnAddress_pointer_1816 = getelementptr <{<{i64, i64, i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1810, i64 0, i32 1, i32 0
        %sharer_pointer_1817 = getelementptr <{<{i64, i64, i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1810, i64 0, i32 1, i32 1
        %eraser_pointer_1818 = getelementptr <{<{i64, i64, i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1810, i64 0, i32 1, i32 2
        store ptr @returnAddress_1746, ptr %returnAddress_pointer_1816, !noalias !2
        store ptr @sharer_1791, ptr %sharer_pointer_1817, !noalias !2
        store ptr @eraser_1803, ptr %eraser_pointer_1818, !noalias !2
        
        %stack_1819 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4953 = call ccc %Prompt @currentPrompt(%Stack %stack_1819)
        %stackPointer_1825 = call ccc %StackPointer @stackAllocate(%Stack %stack_1819, i64 24)
        %returnAddress_pointer_1826 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1825, i64 0, i32 1, i32 0
        %sharer_pointer_1827 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1825, i64 0, i32 1, i32 1
        %eraser_pointer_1828 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1825, i64 0, i32 1, i32 2
        store ptr @returnAddress_1820, ptr %returnAddress_pointer_1826, !noalias !2
        store ptr @sharer_1710, ptr %sharer_pointer_1827, !noalias !2
        store ptr @eraser_1712, ptr %eraser_pointer_1828, !noalias !2
        
        %closure_1845 = call ccc %Object @newObject(ptr @eraser_1848, i64 8)
        %environment_1846 = call ccc %Environment @objectEnvironment(%Object %closure_1845)
        %p_6_18_45_209_4953_pointer_1850 = getelementptr <{%Prompt}>, %Environment %environment_1846, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4953, ptr %p_6_18_45_209_4953_pointer_1850, !noalias !2
        %vtable_temporary_1851 = insertvalue %Neg zeroinitializer, ptr @vtable_1844, 0
        %Exception_7_19_46_210_5086 = insertvalue %Neg %vtable_temporary_1851, %Object %closure_1845, 1
        %stackPointer_1863 = call ccc %StackPointer @stackAllocate(%Stack %stack_1819, i64 24)
        %returnAddress_pointer_1864 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1863, i64 0, i32 1, i32 0
        %sharer_pointer_1865 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1863, i64 0, i32 1, i32 1
        %eraser_pointer_1866 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1863, i64 0, i32 1, i32 2
        store ptr @returnAddress_1852, ptr %returnAddress_pointer_1864, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_1865, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_1866, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2613_30_194_5131, i64 %index_7_34_198_4957, %Neg %Exception_7_19_46_210_5086, %Stack %stack_1819)
        ret void
}



define tailcc void @Exception_9_106_133_297_5189_clause_1867(%Object %closure, %Pos %exception_10_107_134_298_5967, %Pos %msg_11_108_135_299_5968, %Stack %stack) {
        
    entry:
        
        %environment_1868 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4906_pointer_1869 = getelementptr <{%Prompt}>, %Environment %environment_1868, i64 0, i32 0
        %p_8_9_4906 = load %Prompt, ptr %p_8_9_4906_pointer_1869, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5967)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5968)
        
        %pair_1870 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4906)
        %k_13_14_4_5718 = extractvalue <{%Resumption, %Stack}> %pair_1870, 0
        %stack_1871 = extractvalue <{%Resumption, %Stack}> %pair_1870, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5718)
        
        %longLiteral_5969 = add i64 10, 0
        
        
        
        %pureApp_5970 = call ccc %Pos @boxInt_301(i64 %longLiteral_5969)
        
        
        
        %stackPointer_1873 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1871, i64 24)
        %returnAddress_pointer_1874 = getelementptr %FrameHeader, %StackPointer %stackPointer_1873, i64 0, i32 0
        %returnAddress_1872 = load %ReturnAddress, ptr %returnAddress_pointer_1874, !noalias !2
        musttail call tailcc void %returnAddress_1872(%Pos %pureApp_5970, %Stack %stack_1871)
        ret void
}


@vtable_1875 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_5189_clause_1867]


define tailcc void @returnAddress_1886(i64 %v_coe_3532_22_131_158_322_5203, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5973 = call ccc %Pos @boxInt_301(i64 %v_coe_3532_22_131_158_322_5203)
        
        
        
        
        
        %pureApp_5974 = call ccc i64 @unboxInt_303(%Pos %pureApp_5973)
        
        
        
        %pureApp_5975 = call ccc %Pos @boxInt_301(i64 %pureApp_5974)
        
        
        
        %stackPointer_1888 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1889 = getelementptr %FrameHeader, %StackPointer %stackPointer_1888, i64 0, i32 0
        %returnAddress_1887 = load %ReturnAddress, ptr %returnAddress_pointer_1889, !noalias !2
        musttail call tailcc void %returnAddress_1887(%Pos %pureApp_5975, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1898(i64 %v_r_2724_1_9_20_129_156_320_5030, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5979 = add i64 0, 0
        
        %pureApp_5978 = call ccc i64 @infixSub_105(i64 %longLiteral_5979, i64 %v_r_2724_1_9_20_129_156_320_5030)
        
        
        
        %stackPointer_1900 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1901 = getelementptr %FrameHeader, %StackPointer %stackPointer_1900, i64 0, i32 0
        %returnAddress_1899 = load %ReturnAddress, ptr %returnAddress_pointer_1901, !noalias !2
        musttail call tailcc void %returnAddress_1899(i64 %pureApp_5978, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1881(i64 %v_r_2723_3_14_123_150_314_4986, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1882 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_5735_pointer_1883 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1882, i64 0, i32 0
        %tmp_5735 = load i64, ptr %tmp_5735_pointer_1883, !noalias !2
        %v_r_2613_30_194_5131_pointer_1884 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1882, i64 0, i32 1
        %v_r_2613_30_194_5131 = load %Pos, ptr %v_r_2613_30_194_5131_pointer_1884, !noalias !2
        %p_8_9_4906_pointer_1885 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1882, i64 0, i32 2
        %p_8_9_4906 = load %Prompt, ptr %p_8_9_4906_pointer_1885, !noalias !2
        
        %intLiteral_5972 = add i64 45, 0
        
        %pureApp_5971 = call ccc %Pos @infixEq_78(i64 %v_r_2723_3_14_123_150_314_4986, i64 %intLiteral_5972)
        
        
        %stackPointer_1890 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1891 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1890, i64 0, i32 1, i32 0
        %sharer_pointer_1892 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1890, i64 0, i32 1, i32 1
        %eraser_pointer_1893 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1890, i64 0, i32 1, i32 2
        store ptr @returnAddress_1886, ptr %returnAddress_pointer_1891, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_1892, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_1893, !noalias !2
        
        %tag_1894 = extractvalue %Pos %pureApp_5971, 0
        %fields_1895 = extractvalue %Pos %pureApp_5971, 1
        switch i64 %tag_1894, label %label_1896 [i64 0, label %label_1897 i64 1, label %label_1906]
    
    label_1896:
        
        ret void
    
    label_1897:
        
        %longLiteral_5976 = add i64 0, 0
        
        %longLiteral_5977 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_5069(i64 %longLiteral_5976, i64 %longLiteral_5977, i64 %tmp_5735, %Pos %v_r_2613_30_194_5131, %Prompt %p_8_9_4906, %Stack %stack)
        ret void
    
    label_1906:
        %stackPointer_1902 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1903 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1902, i64 0, i32 1, i32 0
        %sharer_pointer_1904 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1902, i64 0, i32 1, i32 1
        %eraser_pointer_1905 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1902, i64 0, i32 1, i32 2
        store ptr @returnAddress_1898, ptr %returnAddress_pointer_1903, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_1904, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_1905, !noalias !2
        
        %longLiteral_5980 = add i64 1, 0
        
        %longLiteral_5981 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_5069(i64 %longLiteral_5980, i64 %longLiteral_5981, i64 %tmp_5735, %Pos %v_r_2613_30_194_5131, %Prompt %p_8_9_4906, %Stack %stack)
        ret void
}



define ccc void @sharer_1910(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1911 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_5735_1907_pointer_1912 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1911, i64 0, i32 0
        %tmp_5735_1907 = load i64, ptr %tmp_5735_1907_pointer_1912, !noalias !2
        %v_r_2613_30_194_5131_1908_pointer_1913 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1911, i64 0, i32 1
        %v_r_2613_30_194_5131_1908 = load %Pos, ptr %v_r_2613_30_194_5131_1908_pointer_1913, !noalias !2
        %p_8_9_4906_1909_pointer_1914 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1911, i64 0, i32 2
        %p_8_9_4906_1909 = load %Prompt, ptr %p_8_9_4906_1909_pointer_1914, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2613_30_194_5131_1908)
        call ccc void @shareFrames(%StackPointer %stackPointer_1911)
        ret void
}



define ccc void @eraser_1918(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1919 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_5735_1915_pointer_1920 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1919, i64 0, i32 0
        %tmp_5735_1915 = load i64, ptr %tmp_5735_1915_pointer_1920, !noalias !2
        %v_r_2613_30_194_5131_1916_pointer_1921 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1919, i64 0, i32 1
        %v_r_2613_30_194_5131_1916 = load %Pos, ptr %v_r_2613_30_194_5131_1916_pointer_1921, !noalias !2
        %p_8_9_4906_1917_pointer_1922 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1919, i64 0, i32 2
        %p_8_9_4906_1917 = load %Prompt, ptr %p_8_9_4906_1917_pointer_1922, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2613_30_194_5131_1916)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1919)
        ret void
}



define tailcc void @returnAddress_1743(%Pos %v_r_2613_30_194_5131, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1744 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4906_pointer_1745 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1744, i64 0, i32 0
        %p_8_9_4906 = load %Prompt, ptr %p_8_9_4906_pointer_1745, !noalias !2
        
        %intLiteral_5944 = add i64 48, 0
        
        %pureApp_5943 = call ccc i64 @toInt_2085(i64 %intLiteral_5944)
        
        
        
        %closure_1876 = call ccc %Object @newObject(ptr @eraser_1848, i64 8)
        %environment_1877 = call ccc %Environment @objectEnvironment(%Object %closure_1876)
        %p_8_9_4906_pointer_1879 = getelementptr <{%Prompt}>, %Environment %environment_1877, i64 0, i32 0
        store %Prompt %p_8_9_4906, ptr %p_8_9_4906_pointer_1879, !noalias !2
        %vtable_temporary_1880 = insertvalue %Neg zeroinitializer, ptr @vtable_1875, 0
        %Exception_9_106_133_297_5189 = insertvalue %Neg %vtable_temporary_1880, %Object %closure_1876, 1
        call ccc void @sharePositive(%Pos %v_r_2613_30_194_5131)
        %stackPointer_1923 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_5735_pointer_1924 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1923, i64 0, i32 0
        store i64 %pureApp_5943, ptr %tmp_5735_pointer_1924, !noalias !2
        %v_r_2613_30_194_5131_pointer_1925 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1923, i64 0, i32 1
        store %Pos %v_r_2613_30_194_5131, ptr %v_r_2613_30_194_5131_pointer_1925, !noalias !2
        %p_8_9_4906_pointer_1926 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_1923, i64 0, i32 2
        store %Prompt %p_8_9_4906, ptr %p_8_9_4906_pointer_1926, !noalias !2
        %returnAddress_pointer_1927 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1923, i64 0, i32 1, i32 0
        %sharer_pointer_1928 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1923, i64 0, i32 1, i32 1
        %eraser_pointer_1929 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1923, i64 0, i32 1, i32 2
        store ptr @returnAddress_1881, ptr %returnAddress_pointer_1927, !noalias !2
        store ptr @sharer_1910, ptr %sharer_pointer_1928, !noalias !2
        store ptr @eraser_1918, ptr %eraser_pointer_1929, !noalias !2
        
        %longLiteral_5982 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2613_30_194_5131, i64 %longLiteral_5982, %Neg %Exception_9_106_133_297_5189, %Stack %stack)
        ret void
}



define ccc void @sharer_1931(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1932 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4906_1930_pointer_1933 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1932, i64 0, i32 0
        %p_8_9_4906_1930 = load %Prompt, ptr %p_8_9_4906_1930_pointer_1933, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1932)
        ret void
}



define ccc void @eraser_1935(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1936 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4906_1934_pointer_1937 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1936, i64 0, i32 0
        %p_8_9_4906_1934 = load %Prompt, ptr %p_8_9_4906_1934_pointer_1937, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1936)
        ret void
}


@utf8StringLiteral_5983.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_1740(%Pos %v_r_2612_24_188_5156, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1741 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4906_pointer_1742 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1741, i64 0, i32 0
        %p_8_9_4906 = load %Prompt, ptr %p_8_9_4906_pointer_1742, !noalias !2
        %stackPointer_1938 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4906_pointer_1939 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1938, i64 0, i32 0
        store %Prompt %p_8_9_4906, ptr %p_8_9_4906_pointer_1939, !noalias !2
        %returnAddress_pointer_1940 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1938, i64 0, i32 1, i32 0
        %sharer_pointer_1941 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1938, i64 0, i32 1, i32 1
        %eraser_pointer_1942 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1938, i64 0, i32 1, i32 2
        store ptr @returnAddress_1743, ptr %returnAddress_pointer_1940, !noalias !2
        store ptr @sharer_1931, ptr %sharer_pointer_1941, !noalias !2
        store ptr @eraser_1935, ptr %eraser_pointer_1942, !noalias !2
        
        %tag_1943 = extractvalue %Pos %v_r_2612_24_188_5156, 0
        %fields_1944 = extractvalue %Pos %v_r_2612_24_188_5156, 1
        switch i64 %tag_1943, label %label_1945 [i64 0, label %label_1949 i64 1, label %label_1955]
    
    label_1945:
        
        ret void
    
    label_1949:
        
        %utf8StringLiteral_5983 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5983.lit)
        
        %stackPointer_1947 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1948 = getelementptr %FrameHeader, %StackPointer %stackPointer_1947, i64 0, i32 0
        %returnAddress_1946 = load %ReturnAddress, ptr %returnAddress_pointer_1948, !noalias !2
        musttail call tailcc void %returnAddress_1946(%Pos %utf8StringLiteral_5983, %Stack %stack)
        ret void
    
    label_1955:
        %environment_1950 = call ccc %Environment @objectEnvironment(%Object %fields_1944)
        %v_y_3354_8_29_193_5090_pointer_1951 = getelementptr <{%Pos}>, %Environment %environment_1950, i64 0, i32 0
        %v_y_3354_8_29_193_5090 = load %Pos, ptr %v_y_3354_8_29_193_5090_pointer_1951, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3354_8_29_193_5090)
        call ccc void @eraseObject(%Object %fields_1944)
        
        %stackPointer_1953 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1954 = getelementptr %FrameHeader, %StackPointer %stackPointer_1953, i64 0, i32 0
        %returnAddress_1952 = load %ReturnAddress, ptr %returnAddress_pointer_1954, !noalias !2
        musttail call tailcc void %returnAddress_1952(%Pos %v_y_3354_8_29_193_5090, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1737(%Pos %v_r_2611_13_177_5054, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1738 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4906_pointer_1739 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1738, i64 0, i32 0
        %p_8_9_4906 = load %Prompt, ptr %p_8_9_4906_pointer_1739, !noalias !2
        %stackPointer_1958 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4906_pointer_1959 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1958, i64 0, i32 0
        store %Prompt %p_8_9_4906, ptr %p_8_9_4906_pointer_1959, !noalias !2
        %returnAddress_pointer_1960 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1958, i64 0, i32 1, i32 0
        %sharer_pointer_1961 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1958, i64 0, i32 1, i32 1
        %eraser_pointer_1962 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1958, i64 0, i32 1, i32 2
        store ptr @returnAddress_1740, ptr %returnAddress_pointer_1960, !noalias !2
        store ptr @sharer_1931, ptr %sharer_pointer_1961, !noalias !2
        store ptr @eraser_1935, ptr %eraser_pointer_1962, !noalias !2
        
        %tag_1963 = extractvalue %Pos %v_r_2611_13_177_5054, 0
        %fields_1964 = extractvalue %Pos %v_r_2611_13_177_5054, 1
        switch i64 %tag_1963, label %label_1965 [i64 0, label %label_1970 i64 1, label %label_1982]
    
    label_1965:
        
        ret void
    
    label_1970:
        
        %make_5984_temporary_1966 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5984 = insertvalue %Pos %make_5984_temporary_1966, %Object null, 1
        
        
        
        %stackPointer_1968 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1969 = getelementptr %FrameHeader, %StackPointer %stackPointer_1968, i64 0, i32 0
        %returnAddress_1967 = load %ReturnAddress, ptr %returnAddress_pointer_1969, !noalias !2
        musttail call tailcc void %returnAddress_1967(%Pos %make_5984, %Stack %stack)
        ret void
    
    label_1982:
        %environment_1971 = call ccc %Environment @objectEnvironment(%Object %fields_1964)
        %v_y_2863_10_21_185_5157_pointer_1972 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1971, i64 0, i32 0
        %v_y_2863_10_21_185_5157 = load %Pos, ptr %v_y_2863_10_21_185_5157_pointer_1972, !noalias !2
        %v_y_2864_11_22_186_5200_pointer_1973 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1971, i64 0, i32 1
        %v_y_2864_11_22_186_5200 = load %Pos, ptr %v_y_2864_11_22_186_5200_pointer_1973, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2863_10_21_185_5157)
        call ccc void @eraseObject(%Object %fields_1964)
        
        %fields_1974 = call ccc %Object @newObject(ptr @eraser_1856, i64 16)
        %environment_1975 = call ccc %Environment @objectEnvironment(%Object %fields_1974)
        %v_y_2863_10_21_185_5157_pointer_1977 = getelementptr <{%Pos}>, %Environment %environment_1975, i64 0, i32 0
        store %Pos %v_y_2863_10_21_185_5157, ptr %v_y_2863_10_21_185_5157_pointer_1977, !noalias !2
        %make_5985_temporary_1978 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5985 = insertvalue %Pos %make_5985_temporary_1978, %Object %fields_1974, 1
        
        
        
        %stackPointer_1980 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1981 = getelementptr %FrameHeader, %StackPointer %stackPointer_1980, i64 0, i32 0
        %returnAddress_1979 = load %ReturnAddress, ptr %returnAddress_pointer_1981, !noalias !2
        musttail call tailcc void %returnAddress_1979(%Pos %make_5985, %Stack %stack)
        ret void
}



define tailcc void @main_2473(%Stack %stack) {
        
    entry:
        
        %stackPointer_1700 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1701 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1700, i64 0, i32 1, i32 0
        %sharer_pointer_1702 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1700, i64 0, i32 1, i32 1
        %eraser_pointer_1703 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1700, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_1701, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_1702, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_1703, !noalias !2
        
        %stack_1704 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4906 = call ccc %Prompt @currentPrompt(%Stack %stack_1704)
        %stackPointer_1714 = call ccc %StackPointer @stackAllocate(%Stack %stack_1704, i64 24)
        %returnAddress_pointer_1715 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1714, i64 0, i32 1, i32 0
        %sharer_pointer_1716 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1714, i64 0, i32 1, i32 1
        %eraser_pointer_1717 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1714, i64 0, i32 1, i32 2
        store ptr @returnAddress_1705, ptr %returnAddress_pointer_1715, !noalias !2
        store ptr @sharer_1710, ptr %sharer_pointer_1716, !noalias !2
        store ptr @eraser_1712, ptr %eraser_pointer_1717, !noalias !2
        
        %pureApp_5939 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5941 = add i64 1, 0
        
        %pureApp_5940 = call ccc i64 @infixSub_105(i64 %pureApp_5939, i64 %longLiteral_5941)
        
        
        
        %make_5942_temporary_1736 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5942 = insertvalue %Pos %make_5942_temporary_1736, %Object null, 1
        
        
        %stackPointer_1985 = call ccc %StackPointer @stackAllocate(%Stack %stack_1704, i64 32)
        %p_8_9_4906_pointer_1986 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1985, i64 0, i32 0
        store %Prompt %p_8_9_4906, ptr %p_8_9_4906_pointer_1986, !noalias !2
        %returnAddress_pointer_1987 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1985, i64 0, i32 1, i32 0
        %sharer_pointer_1988 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1985, i64 0, i32 1, i32 1
        %eraser_pointer_1989 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1985, i64 0, i32 1, i32 2
        store ptr @returnAddress_1737, ptr %returnAddress_pointer_1987, !noalias !2
        store ptr @sharer_1931, ptr %sharer_pointer_1988, !noalias !2
        store ptr @eraser_1935, ptr %eraser_pointer_1989, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4973(i64 %pureApp_5940, %Pos %make_5942, %Stack %stack_1704)
        ret void
}


@utf8StringLiteral_5802.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5804.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5807.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_1990(%Pos %v_r_2792_3584, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1991 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_1992 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1991, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_1992, !noalias !2
        %index_2107_pointer_1993 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1991, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_1993, !noalias !2
        %Exception_2362_pointer_1994 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1991, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_1994, !noalias !2
        
        %tag_1995 = extractvalue %Pos %v_r_2792_3584, 0
        %fields_1996 = extractvalue %Pos %v_r_2792_3584, 1
        switch i64 %tag_1995, label %label_1997 [i64 0, label %label_2001 i64 1, label %label_2007]
    
    label_1997:
        
        ret void
    
    label_2001:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5798 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_1999 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2000 = getelementptr %FrameHeader, %StackPointer %stackPointer_1999, i64 0, i32 0
        %returnAddress_1998 = load %ReturnAddress, ptr %returnAddress_pointer_2000, !noalias !2
        musttail call tailcc void %returnAddress_1998(i64 %pureApp_5798, %Stack %stack)
        ret void
    
    label_2007:
        
        %make_5799_temporary_2002 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5799 = insertvalue %Pos %make_5799_temporary_2002, %Object null, 1
        
        
        
        %pureApp_5800 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5802 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5802.lit)
        
        %pureApp_5801 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5802, %Pos %pureApp_5800)
        
        
        
        %utf8StringLiteral_5804 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5804.lit)
        
        %pureApp_5803 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5801, %Pos %utf8StringLiteral_5804)
        
        
        
        %pureApp_5805 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5803, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5807 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5807.lit)
        
        %pureApp_5806 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5805, %Pos %utf8StringLiteral_5807)
        
        
        
        %vtable_2003 = extractvalue %Neg %Exception_2362, 0
        %closure_2004 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_2005 = getelementptr ptr, ptr %vtable_2003, i64 0
        %functionPointer_2006 = load ptr, ptr %functionPointer_pointer_2005, !noalias !2
        musttail call tailcc void %functionPointer_2006(%Object %closure_2004, %Pos %make_5799, %Pos %pureApp_5806, %Stack %stack)
        ret void
}



define ccc void @sharer_2011(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_2012 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_2008_pointer_2013 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2012, i64 0, i32 0
        %str_2106_2008 = load %Pos, ptr %str_2106_2008_pointer_2013, !noalias !2
        %index_2107_2009_pointer_2014 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2012, i64 0, i32 1
        %index_2107_2009 = load i64, ptr %index_2107_2009_pointer_2014, !noalias !2
        %Exception_2362_2010_pointer_2015 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2012, i64 0, i32 2
        %Exception_2362_2010 = load %Neg, ptr %Exception_2362_2010_pointer_2015, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_2008)
        call ccc void @shareNegative(%Neg %Exception_2362_2010)
        call ccc void @shareFrames(%StackPointer %stackPointer_2012)
        ret void
}



define ccc void @eraser_2019(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_2020 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_2016_pointer_2021 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2020, i64 0, i32 0
        %str_2106_2016 = load %Pos, ptr %str_2106_2016_pointer_2021, !noalias !2
        %index_2107_2017_pointer_2022 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2020, i64 0, i32 1
        %index_2107_2017 = load i64, ptr %index_2107_2017_pointer_2022, !noalias !2
        %Exception_2362_2018_pointer_2023 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2020, i64 0, i32 2
        %Exception_2362_2018 = load %Neg, ptr %Exception_2362_2018_pointer_2023, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_2016)
        call ccc void @eraseNegative(%Neg %Exception_2362_2018)
        call ccc void @eraseFrames(%StackPointer %stackPointer_2020)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5797 = add i64 0, 0
        
        %pureApp_5796 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5797)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_2024 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_2025 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2024, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_2025, !noalias !2
        %index_2107_pointer_2026 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2024, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_2026, !noalias !2
        %Exception_2362_pointer_2027 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2024, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_2027, !noalias !2
        %returnAddress_pointer_2028 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_2024, i64 0, i32 1, i32 0
        %sharer_pointer_2029 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_2024, i64 0, i32 1, i32 1
        %eraser_pointer_2030 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_2024, i64 0, i32 1, i32 2
        store ptr @returnAddress_1990, ptr %returnAddress_pointer_2028, !noalias !2
        store ptr @sharer_2011, ptr %sharer_pointer_2029, !noalias !2
        store ptr @eraser_2019, ptr %eraser_pointer_2030, !noalias !2
        
        %tag_2031 = extractvalue %Pos %pureApp_5796, 0
        %fields_2032 = extractvalue %Pos %pureApp_5796, 1
        switch i64 %tag_2031, label %label_2033 [i64 0, label %label_2037 i64 1, label %label_2042]
    
    label_2033:
        
        ret void
    
    label_2037:
        
        %pureApp_5808 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5809 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5808)
        
        
        
        %stackPointer_2035 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2036 = getelementptr %FrameHeader, %StackPointer %stackPointer_2035, i64 0, i32 0
        %returnAddress_2034 = load %ReturnAddress, ptr %returnAddress_pointer_2036, !noalias !2
        musttail call tailcc void %returnAddress_2034(%Pos %pureApp_5809, %Stack %stack)
        ret void
    
    label_2042:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5810_temporary_2038 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5810 = insertvalue %Pos %booleanLiteral_5810_temporary_2038, %Object null, 1
        
        %stackPointer_2040 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2041 = getelementptr %FrameHeader, %StackPointer %stackPointer_2040, i64 0, i32 0
        %returnAddress_2039 = load %ReturnAddress, ptr %returnAddress_pointer_2041, !noalias !2
        musttail call tailcc void %returnAddress_2039(%Pos %booleanLiteral_5810, %Stack %stack)
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
        
        musttail call tailcc void @main_2473(%Stack %stack)
        ret void
}
