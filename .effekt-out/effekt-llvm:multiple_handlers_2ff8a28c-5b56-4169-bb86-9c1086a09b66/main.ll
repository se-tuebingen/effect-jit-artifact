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



define tailcc void @returnAddress_9(i64 %c_188_4863, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_10 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %sqs_66_4920_pointer_11 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_10, i64 0, i32 0
        %sqs_66_4920 = load i64, ptr %sqs_66_4920_pointer_11, !noalias !2
        %s_127_4815_pointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_10, i64 0, i32 1
        %s_127_4815 = load i64, ptr %s_127_4815_pointer_12, !noalias !2
        
        %longLiteral_5128 = add i64 1009, 0
        
        %pureApp_5127 = call ccc i64 @infixMul_99(i64 %sqs_66_4920, i64 %longLiteral_5128)
        
        
        
        %longLiteral_5130 = add i64 103, 0
        
        %pureApp_5129 = call ccc i64 @infixMul_99(i64 %s_127_4815, i64 %longLiteral_5130)
        
        
        
        %pureApp_5131 = call ccc i64 @infixAdd_96(i64 %pureApp_5127, i64 %pureApp_5129)
        
        
        
        %pureApp_5132 = call ccc i64 @infixAdd_96(i64 %pureApp_5131, i64 %c_188_4863)
        
        
        
        %pureApp_5133 = call ccc %Pos @show_14(i64 %pureApp_5132)
        
        
        
        %pureApp_5134 = call ccc %Pos @println_1(%Pos %pureApp_5133)
        
        
        
        %stackPointer_14 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_15 = getelementptr %FrameHeader, %StackPointer %stackPointer_14, i64 0, i32 0
        %returnAddress_13 = load %ReturnAddress, ptr %returnAddress_pointer_15, !noalias !2
        musttail call tailcc void %returnAddress_13(%Pos %pureApp_5134, %Stack %stack)
        ret void
}



define ccc void @sharer_18(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_19 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %sqs_66_4920_16_pointer_20 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_19, i64 0, i32 0
        %sqs_66_4920_16 = load i64, ptr %sqs_66_4920_16_pointer_20, !noalias !2
        %s_127_4815_17_pointer_21 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_19, i64 0, i32 1
        %s_127_4815_17 = load i64, ptr %s_127_4815_17_pointer_21, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_19)
        ret void
}



define ccc void @eraser_24(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_25 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %sqs_66_4920_22_pointer_26 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_25, i64 0, i32 0
        %sqs_66_4920_22 = load i64, ptr %sqs_66_4920_22_pointer_26, !noalias !2
        %s_127_4815_23_pointer_27 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_25, i64 0, i32 1
        %s_127_4815_23 = load i64, ptr %s_127_4815_23_pointer_27, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_25)
        ret void
}



define tailcc void @returnAddress_34(i64 %returnValue_35, %Stack %stack) {
        
    entry:
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2557_3_137_4907_pointer_37 = getelementptr <{i64}>, %StackPointer %stackPointer_36, i64 0, i32 0
        %v_r_2557_3_137_4907 = load i64, ptr %v_r_2557_3_137_4907_pointer_37, !noalias !2
        %stackPointer_39 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_40 = getelementptr %FrameHeader, %StackPointer %stackPointer_39, i64 0, i32 0
        %returnAddress_38 = load %ReturnAddress, ptr %returnAddress_pointer_40, !noalias !2
        musttail call tailcc void %returnAddress_38(i64 %returnValue_35, %Stack %stack)
        ret void
}



define ccc void @sharer_42(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_43 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2557_3_137_4907_41_pointer_44 = getelementptr <{i64}>, %StackPointer %stackPointer_43, i64 0, i32 0
        %v_r_2557_3_137_4907_41 = load i64, ptr %v_r_2557_3_137_4907_41_pointer_44, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_43)
        ret void
}



define ccc void @eraser_46(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_47 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2557_3_137_4907_45_pointer_48 = getelementptr <{i64}>, %StackPointer %stackPointer_47, i64 0, i32 0
        %v_r_2557_3_137_4907_45 = load i64, ptr %v_r_2557_3_137_4907_45_pointer_48, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_47)
        ret void
}



define tailcc void @returnAddress_62(%Pos %__9_27_20_184_4970, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_63 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_5_4_163_4852_pointer_64 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_63, i64 0, i32 0
        %i_5_4_163_4852 = load i64, ptr %i_5_4_163_4852_pointer_64, !noalias !2
        %res_4_138_4924_pointer_65 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_63, i64 0, i32 1
        %res_4_138_4924 = load %Reference, ptr %res_4_138_4924_pointer_65, !noalias !2
        %tmp_5107_pointer_66 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_63, i64 0, i32 2
        %tmp_5107 = load i64, ptr %tmp_5107_pointer_66, !noalias !2
        call ccc void @erasePositive(%Pos %__9_27_20_184_4970)
        
        %longLiteral_5142 = add i64 1, 0
        
        %pureApp_5141 = call ccc i64 @infixAdd_96(i64 %i_5_4_163_4852, i64 %longLiteral_5142)
        
        
        
        
        
        musttail call tailcc void @go_4_3_162_4903(i64 %pureApp_5141, %Reference %res_4_138_4924, i64 %tmp_5107, %Stack %stack)
        ret void
}



define ccc void @sharer_70(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_71 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %i_5_4_163_4852_67_pointer_72 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_71, i64 0, i32 0
        %i_5_4_163_4852_67 = load i64, ptr %i_5_4_163_4852_67_pointer_72, !noalias !2
        %res_4_138_4924_68_pointer_73 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_71, i64 0, i32 1
        %res_4_138_4924_68 = load %Reference, ptr %res_4_138_4924_68_pointer_73, !noalias !2
        %tmp_5107_69_pointer_74 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_71, i64 0, i32 2
        %tmp_5107_69 = load i64, ptr %tmp_5107_69_pointer_74, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_71)
        ret void
}



define ccc void @eraser_78(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_79 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %i_5_4_163_4852_75_pointer_80 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_79, i64 0, i32 0
        %i_5_4_163_4852_75 = load i64, ptr %i_5_4_163_4852_75_pointer_80, !noalias !2
        %res_4_138_4924_76_pointer_81 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_79, i64 0, i32 1
        %res_4_138_4924_76 = load %Reference, ptr %res_4_138_4924_76_pointer_81, !noalias !2
        %tmp_5107_77_pointer_82 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_79, i64 0, i32 2
        %tmp_5107_77 = load i64, ptr %tmp_5107_77_pointer_82, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_79)
        ret void
}



define tailcc void @returnAddress_57(i64 %v_r_2559_6_24_17_181_4839, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_58 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_5_4_163_4852_pointer_59 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_58, i64 0, i32 0
        %i_5_4_163_4852 = load i64, ptr %i_5_4_163_4852_pointer_59, !noalias !2
        %res_4_138_4924_pointer_60 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_58, i64 0, i32 1
        %res_4_138_4924 = load %Reference, ptr %res_4_138_4924_pointer_60, !noalias !2
        %tmp_5107_pointer_61 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_58, i64 0, i32 2
        %tmp_5107 = load i64, ptr %tmp_5107_pointer_61, !noalias !2
        
        %longLiteral_5138 = add i64 1, 0
        
        %pureApp_5137 = call ccc i64 @infixAdd_96(i64 %v_r_2559_6_24_17_181_4839, i64 %longLiteral_5138)
        
        
        
        %longLiteral_5140 = add i64 1009, 0
        
        %pureApp_5139 = call ccc i64 @mod_108(i64 %pureApp_5137, i64 %longLiteral_5140)
        
        
        %stackPointer_83 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_5_4_163_4852_pointer_84 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_83, i64 0, i32 0
        store i64 %i_5_4_163_4852, ptr %i_5_4_163_4852_pointer_84, !noalias !2
        %res_4_138_4924_pointer_85 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_83, i64 0, i32 1
        store %Reference %res_4_138_4924, ptr %res_4_138_4924_pointer_85, !noalias !2
        %tmp_5107_pointer_86 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_83, i64 0, i32 2
        store i64 %tmp_5107, ptr %tmp_5107_pointer_86, !noalias !2
        %returnAddress_pointer_87 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_83, i64 0, i32 1, i32 0
        %sharer_pointer_88 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_83, i64 0, i32 1, i32 1
        %eraser_pointer_89 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_83, i64 0, i32 1, i32 2
        store ptr @returnAddress_62, ptr %returnAddress_pointer_87, !noalias !2
        store ptr @sharer_70, ptr %sharer_pointer_88, !noalias !2
        store ptr @eraser_78, ptr %eraser_pointer_89, !noalias !2
        
        %res_4_138_4924pointer_90 = call ccc ptr @getVarPointer(%Reference %res_4_138_4924, %Stack %stack)
        %res_4_138_4924_old_91 = load i64, ptr %res_4_138_4924pointer_90, !noalias !2
        store i64 %pureApp_5139, ptr %res_4_138_4924pointer_90, !noalias !2
        
        %put_5143_temporary_92 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5143 = insertvalue %Pos %put_5143_temporary_92, %Object null, 1
        
        %stackPointer_94 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_95 = getelementptr %FrameHeader, %StackPointer %stackPointer_94, i64 0, i32 0
        %returnAddress_93 = load %ReturnAddress, ptr %returnAddress_pointer_95, !noalias !2
        musttail call tailcc void %returnAddress_93(%Pos %put_5143, %Stack %stack)
        ret void
}



define tailcc void @go_4_3_162_4903(i64 %i_5_4_163_4852, %Reference %res_4_138_4924, i64 %tmp_5107, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5136 = call ccc %Pos @infixGt_184(i64 %i_5_4_163_4852, i64 %tmp_5107)
        
        
        
        %tag_54 = extractvalue %Pos %pureApp_5136, 0
        %fields_55 = extractvalue %Pos %pureApp_5136, 1
        switch i64 %tag_54, label %label_56 [i64 0, label %label_114 i64 1, label %label_119]
    
    label_56:
        
        ret void
    
    label_114:
        %stackPointer_102 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_5_4_163_4852_pointer_103 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_102, i64 0, i32 0
        store i64 %i_5_4_163_4852, ptr %i_5_4_163_4852_pointer_103, !noalias !2
        %res_4_138_4924_pointer_104 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_102, i64 0, i32 1
        store %Reference %res_4_138_4924, ptr %res_4_138_4924_pointer_104, !noalias !2
        %tmp_5107_pointer_105 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_102, i64 0, i32 2
        store i64 %tmp_5107, ptr %tmp_5107_pointer_105, !noalias !2
        %returnAddress_pointer_106 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_102, i64 0, i32 1, i32 0
        %sharer_pointer_107 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_102, i64 0, i32 1, i32 1
        %eraser_pointer_108 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_102, i64 0, i32 1, i32 2
        store ptr @returnAddress_57, ptr %returnAddress_pointer_106, !noalias !2
        store ptr @sharer_70, ptr %sharer_pointer_107, !noalias !2
        store ptr @eraser_78, ptr %eraser_pointer_108, !noalias !2
        
        %get_5144_pointer_109 = call ccc ptr @getVarPointer(%Reference %res_4_138_4924, %Stack %stack)
        %res_4_138_4924_old_110 = load i64, ptr %get_5144_pointer_109, !noalias !2
        %get_5144 = load i64, ptr %get_5144_pointer_109, !noalias !2
        
        %stackPointer_112 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_113 = getelementptr %FrameHeader, %StackPointer %stackPointer_112, i64 0, i32 0
        %returnAddress_111 = load %ReturnAddress, ptr %returnAddress_pointer_113, !noalias !2
        musttail call tailcc void %returnAddress_111(i64 %get_5144, %Stack %stack)
        ret void
    
    label_119:
        
        %unitLiteral_5145_temporary_115 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5145 = insertvalue %Pos %unitLiteral_5145_temporary_115, %Object null, 1
        
        %stackPointer_117 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_118 = getelementptr %FrameHeader, %StackPointer %stackPointer_117, i64 0, i32 0
        %returnAddress_116 = load %ReturnAddress, ptr %returnAddress_pointer_118, !noalias !2
        musttail call tailcc void %returnAddress_116(%Pos %unitLiteral_5145, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_120(%Pos %__28_187_4972, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_121 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %res_4_138_4924_pointer_122 = getelementptr <{%Reference}>, %StackPointer %stackPointer_121, i64 0, i32 0
        %res_4_138_4924 = load %Reference, ptr %res_4_138_4924_pointer_122, !noalias !2
        call ccc void @erasePositive(%Pos %__28_187_4972)
        
        %get_5146_pointer_123 = call ccc ptr @getVarPointer(%Reference %res_4_138_4924, %Stack %stack)
        %res_4_138_4924_old_124 = load i64, ptr %get_5146_pointer_123, !noalias !2
        %get_5146 = load i64, ptr %get_5146_pointer_123, !noalias !2
        
        %stackPointer_126 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_127 = getelementptr %FrameHeader, %StackPointer %stackPointer_126, i64 0, i32 0
        %returnAddress_125 = load %ReturnAddress, ptr %returnAddress_pointer_127, !noalias !2
        musttail call tailcc void %returnAddress_125(i64 %get_5146, %Stack %stack)
        ret void
}



define ccc void @sharer_129(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_130 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %res_4_138_4924_128_pointer_131 = getelementptr <{%Reference}>, %StackPointer %stackPointer_130, i64 0, i32 0
        %res_4_138_4924_128 = load %Reference, ptr %res_4_138_4924_128_pointer_131, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_130)
        ret void
}



define ccc void @eraser_133(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_134 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %res_4_138_4924_132_pointer_135 = getelementptr <{%Reference}>, %StackPointer %stackPointer_134, i64 0, i32 0
        %res_4_138_4924_132 = load %Reference, ptr %res_4_138_4924_132_pointer_135, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_134)
        ret void
}



define tailcc void @returnAddress_5(i64 %s_127_4815, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_6 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %sqs_66_4920_pointer_7 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_6, i64 0, i32 0
        %sqs_66_4920 = load i64, ptr %sqs_66_4920_pointer_7, !noalias !2
        %tmp_5107_pointer_8 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_6, i64 0, i32 1
        %tmp_5107 = load i64, ptr %tmp_5107_pointer_8, !noalias !2
        
        %longLiteral_5126 = add i64 0, 0
        
        
        %stackPointer_28 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %sqs_66_4920_pointer_29 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_28, i64 0, i32 0
        store i64 %sqs_66_4920, ptr %sqs_66_4920_pointer_29, !noalias !2
        %s_127_4815_pointer_30 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_28, i64 0, i32 1
        store i64 %s_127_4815, ptr %s_127_4815_pointer_30, !noalias !2
        %returnAddress_pointer_31 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_28, i64 0, i32 1, i32 0
        %sharer_pointer_32 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_28, i64 0, i32 1, i32 1
        %eraser_pointer_33 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_28, i64 0, i32 1, i32 2
        store ptr @returnAddress_9, ptr %returnAddress_pointer_31, !noalias !2
        store ptr @sharer_18, ptr %sharer_pointer_32, !noalias !2
        store ptr @eraser_24, ptr %eraser_pointer_33, !noalias !2
        %res_4_138_4924 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_49 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2557_3_137_4907_pointer_50 = getelementptr <{i64}>, %StackPointer %stackPointer_49, i64 0, i32 0
        store i64 %longLiteral_5126, ptr %v_r_2557_3_137_4907_pointer_50, !noalias !2
        %returnAddress_pointer_51 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 0
        %sharer_pointer_52 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 1
        %eraser_pointer_53 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_51, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_52, !noalias !2
        store ptr @eraser_46, ptr %eraser_pointer_53, !noalias !2
        %stackPointer_136 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %res_4_138_4924_pointer_137 = getelementptr <{%Reference}>, %StackPointer %stackPointer_136, i64 0, i32 0
        store %Reference %res_4_138_4924, ptr %res_4_138_4924_pointer_137, !noalias !2
        %returnAddress_pointer_138 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 0
        %sharer_pointer_139 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 1
        %eraser_pointer_140 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 2
        store ptr @returnAddress_120, ptr %returnAddress_pointer_138, !noalias !2
        store ptr @sharer_129, ptr %sharer_pointer_139, !noalias !2
        store ptr @eraser_133, ptr %eraser_pointer_140, !noalias !2
        
        %longLiteral_5147 = add i64 0, 0
        
        
        
        musttail call tailcc void @go_4_3_162_4903(i64 %longLiteral_5147, %Reference %res_4_138_4924, i64 %tmp_5107, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_151(i64 %returnValue_152, %Stack %stack) {
        
    entry:
        
        %stackPointer_153 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2545_3_76_4851_pointer_154 = getelementptr <{i64}>, %StackPointer %stackPointer_153, i64 0, i32 0
        %v_r_2545_3_76_4851 = load i64, ptr %v_r_2545_3_76_4851_pointer_154, !noalias !2
        %stackPointer_156 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_157 = getelementptr %FrameHeader, %StackPointer %stackPointer_156, i64 0, i32 0
        %returnAddress_155 = load %ReturnAddress, ptr %returnAddress_pointer_157, !noalias !2
        musttail call tailcc void %returnAddress_155(i64 %returnValue_152, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_174(%Pos %__9_27_20_123_4961, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_175 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_5_4_102_4930_pointer_176 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_175, i64 0, i32 0
        %i_5_4_102_4930 = load i64, ptr %i_5_4_102_4930_pointer_176, !noalias !2
        %res_4_77_4904_pointer_177 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_175, i64 0, i32 1
        %res_4_77_4904 = load %Reference, ptr %res_4_77_4904_pointer_177, !noalias !2
        %tmp_5107_pointer_178 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_175, i64 0, i32 2
        %tmp_5107 = load i64, ptr %tmp_5107_pointer_178, !noalias !2
        call ccc void @erasePositive(%Pos %__9_27_20_123_4961)
        
        %longLiteral_5156 = add i64 1, 0
        
        %pureApp_5155 = call ccc i64 @infixAdd_96(i64 %i_5_4_102_4930, i64 %longLiteral_5156)
        
        
        
        
        
        musttail call tailcc void @go_4_3_101_4807(i64 %pureApp_5155, %Reference %res_4_77_4904, i64 %tmp_5107, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_168(i64 %v_r_2548_6_24_17_120_4900, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_169 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %i_5_4_102_4930_pointer_170 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_169, i64 0, i32 0
        %i_5_4_102_4930 = load i64, ptr %i_5_4_102_4930_pointer_170, !noalias !2
        %res_4_77_4904_pointer_171 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_169, i64 0, i32 1
        %res_4_77_4904 = load %Reference, ptr %res_4_77_4904_pointer_171, !noalias !2
        %tmp_5090_pointer_172 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_169, i64 0, i32 2
        %tmp_5090 = load i64, ptr %tmp_5090_pointer_172, !noalias !2
        %tmp_5107_pointer_173 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_169, i64 0, i32 3
        %tmp_5107 = load i64, ptr %tmp_5107_pointer_173, !noalias !2
        
        %pureApp_5152 = call ccc i64 @infixAdd_96(i64 %v_r_2548_6_24_17_120_4900, i64 %tmp_5090)
        
        
        
        %longLiteral_5154 = add i64 1009, 0
        
        %pureApp_5153 = call ccc i64 @mod_108(i64 %pureApp_5152, i64 %longLiteral_5154)
        
        
        %stackPointer_185 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_5_4_102_4930_pointer_186 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_185, i64 0, i32 0
        store i64 %i_5_4_102_4930, ptr %i_5_4_102_4930_pointer_186, !noalias !2
        %res_4_77_4904_pointer_187 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_185, i64 0, i32 1
        store %Reference %res_4_77_4904, ptr %res_4_77_4904_pointer_187, !noalias !2
        %tmp_5107_pointer_188 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_185, i64 0, i32 2
        store i64 %tmp_5107, ptr %tmp_5107_pointer_188, !noalias !2
        %returnAddress_pointer_189 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_185, i64 0, i32 1, i32 0
        %sharer_pointer_190 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_185, i64 0, i32 1, i32 1
        %eraser_pointer_191 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_185, i64 0, i32 1, i32 2
        store ptr @returnAddress_174, ptr %returnAddress_pointer_189, !noalias !2
        store ptr @sharer_70, ptr %sharer_pointer_190, !noalias !2
        store ptr @eraser_78, ptr %eraser_pointer_191, !noalias !2
        
        %res_4_77_4904pointer_192 = call ccc ptr @getVarPointer(%Reference %res_4_77_4904, %Stack %stack)
        %res_4_77_4904_old_193 = load i64, ptr %res_4_77_4904pointer_192, !noalias !2
        store i64 %pureApp_5153, ptr %res_4_77_4904pointer_192, !noalias !2
        
        %put_5157_temporary_194 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5157 = insertvalue %Pos %put_5157_temporary_194, %Object null, 1
        
        %stackPointer_196 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_197 = getelementptr %FrameHeader, %StackPointer %stackPointer_196, i64 0, i32 0
        %returnAddress_195 = load %ReturnAddress, ptr %returnAddress_pointer_197, !noalias !2
        musttail call tailcc void %returnAddress_195(%Pos %put_5157, %Stack %stack)
        ret void
}



define ccc void @sharer_202(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_203 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_5_4_102_4930_198_pointer_204 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_203, i64 0, i32 0
        %i_5_4_102_4930_198 = load i64, ptr %i_5_4_102_4930_198_pointer_204, !noalias !2
        %res_4_77_4904_199_pointer_205 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_203, i64 0, i32 1
        %res_4_77_4904_199 = load %Reference, ptr %res_4_77_4904_199_pointer_205, !noalias !2
        %tmp_5090_200_pointer_206 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_203, i64 0, i32 2
        %tmp_5090_200 = load i64, ptr %tmp_5090_200_pointer_206, !noalias !2
        %tmp_5107_201_pointer_207 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_203, i64 0, i32 3
        %tmp_5107_201 = load i64, ptr %tmp_5107_201_pointer_207, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_203)
        ret void
}



define ccc void @eraser_212(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_213 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_5_4_102_4930_208_pointer_214 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_213, i64 0, i32 0
        %i_5_4_102_4930_208 = load i64, ptr %i_5_4_102_4930_208_pointer_214, !noalias !2
        %res_4_77_4904_209_pointer_215 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_213, i64 0, i32 1
        %res_4_77_4904_209 = load %Reference, ptr %res_4_77_4904_209_pointer_215, !noalias !2
        %tmp_5090_210_pointer_216 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_213, i64 0, i32 2
        %tmp_5090_210 = load i64, ptr %tmp_5090_210_pointer_216, !noalias !2
        %tmp_5107_211_pointer_217 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_213, i64 0, i32 3
        %tmp_5107_211 = load i64, ptr %tmp_5107_211_pointer_217, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_213)
        ret void
}



define tailcc void @go_4_3_101_4807(i64 %i_5_4_102_4930, %Reference %res_4_77_4904, i64 %tmp_5107, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5149 = call ccc %Pos @infixGt_184(i64 %i_5_4_102_4930, i64 %tmp_5107)
        
        
        
        %tag_165 = extractvalue %Pos %pureApp_5149, 0
        %fields_166 = extractvalue %Pos %pureApp_5149, 1
        switch i64 %tag_165, label %label_167 [i64 0, label %label_231 i64 1, label %label_236]
    
    label_167:
        
        ret void
    
    label_231:
        
        %pureApp_5150 = call ccc %Pos @boxInt_301(i64 %i_5_4_102_4930)
        
        
        
        %pureApp_5151 = call ccc i64 @unboxInt_303(%Pos %pureApp_5150)
        
        
        %stackPointer_218 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %i_5_4_102_4930_pointer_219 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_218, i64 0, i32 0
        store i64 %i_5_4_102_4930, ptr %i_5_4_102_4930_pointer_219, !noalias !2
        %res_4_77_4904_pointer_220 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_218, i64 0, i32 1
        store %Reference %res_4_77_4904, ptr %res_4_77_4904_pointer_220, !noalias !2
        %tmp_5090_pointer_221 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_218, i64 0, i32 2
        store i64 %pureApp_5151, ptr %tmp_5090_pointer_221, !noalias !2
        %tmp_5107_pointer_222 = getelementptr <{i64, %Reference, i64, i64}>, %StackPointer %stackPointer_218, i64 0, i32 3
        store i64 %tmp_5107, ptr %tmp_5107_pointer_222, !noalias !2
        %returnAddress_pointer_223 = getelementptr <{<{i64, %Reference, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_218, i64 0, i32 1, i32 0
        %sharer_pointer_224 = getelementptr <{<{i64, %Reference, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_218, i64 0, i32 1, i32 1
        %eraser_pointer_225 = getelementptr <{<{i64, %Reference, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_218, i64 0, i32 1, i32 2
        store ptr @returnAddress_168, ptr %returnAddress_pointer_223, !noalias !2
        store ptr @sharer_202, ptr %sharer_pointer_224, !noalias !2
        store ptr @eraser_212, ptr %eraser_pointer_225, !noalias !2
        
        %get_5158_pointer_226 = call ccc ptr @getVarPointer(%Reference %res_4_77_4904, %Stack %stack)
        %res_4_77_4904_old_227 = load i64, ptr %get_5158_pointer_226, !noalias !2
        %get_5158 = load i64, ptr %get_5158_pointer_226, !noalias !2
        
        %stackPointer_229 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_230 = getelementptr %FrameHeader, %StackPointer %stackPointer_229, i64 0, i32 0
        %returnAddress_228 = load %ReturnAddress, ptr %returnAddress_pointer_230, !noalias !2
        musttail call tailcc void %returnAddress_228(i64 %get_5158, %Stack %stack)
        ret void
    
    label_236:
        
        %unitLiteral_5159_temporary_232 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5159 = insertvalue %Pos %unitLiteral_5159_temporary_232, %Object null, 1
        
        %stackPointer_234 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_235 = getelementptr %FrameHeader, %StackPointer %stackPointer_234, i64 0, i32 0
        %returnAddress_233 = load %ReturnAddress, ptr %returnAddress_pointer_235, !noalias !2
        musttail call tailcc void %returnAddress_233(%Pos %unitLiteral_5159, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_237(%Pos %__28_126_4963, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_238 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %res_4_77_4904_pointer_239 = getelementptr <{%Reference}>, %StackPointer %stackPointer_238, i64 0, i32 0
        %res_4_77_4904 = load %Reference, ptr %res_4_77_4904_pointer_239, !noalias !2
        call ccc void @erasePositive(%Pos %__28_126_4963)
        
        %get_5160_pointer_240 = call ccc ptr @getVarPointer(%Reference %res_4_77_4904, %Stack %stack)
        %res_4_77_4904_old_241 = load i64, ptr %get_5160_pointer_240, !noalias !2
        %get_5160 = load i64, ptr %get_5160_pointer_240, !noalias !2
        
        %stackPointer_243 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_244 = getelementptr %FrameHeader, %StackPointer %stackPointer_243, i64 0, i32 0
        %returnAddress_242 = load %ReturnAddress, ptr %returnAddress_pointer_244, !noalias !2
        musttail call tailcc void %returnAddress_242(i64 %get_5160, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_2(i64 %sqs_66_4920, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_3 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_5107_pointer_4 = getelementptr <{i64}>, %StackPointer %stackPointer_3, i64 0, i32 0
        %tmp_5107 = load i64, ptr %tmp_5107_pointer_4, !noalias !2
        
        %longLiteral_5125 = add i64 0, 0
        
        
        %stackPointer_145 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %sqs_66_4920_pointer_146 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_145, i64 0, i32 0
        store i64 %sqs_66_4920, ptr %sqs_66_4920_pointer_146, !noalias !2
        %tmp_5107_pointer_147 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_145, i64 0, i32 1
        store i64 %tmp_5107, ptr %tmp_5107_pointer_147, !noalias !2
        %returnAddress_pointer_148 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_145, i64 0, i32 1, i32 0
        %sharer_pointer_149 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_145, i64 0, i32 1, i32 1
        %eraser_pointer_150 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_145, i64 0, i32 1, i32 2
        store ptr @returnAddress_5, ptr %returnAddress_pointer_148, !noalias !2
        store ptr @sharer_18, ptr %sharer_pointer_149, !noalias !2
        store ptr @eraser_24, ptr %eraser_pointer_150, !noalias !2
        %res_4_77_4904 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_160 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2545_3_76_4851_pointer_161 = getelementptr <{i64}>, %StackPointer %stackPointer_160, i64 0, i32 0
        store i64 %longLiteral_5125, ptr %v_r_2545_3_76_4851_pointer_161, !noalias !2
        %returnAddress_pointer_162 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 0
        %sharer_pointer_163 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 1
        %eraser_pointer_164 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 2
        store ptr @returnAddress_151, ptr %returnAddress_pointer_162, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_163, !noalias !2
        store ptr @eraser_46, ptr %eraser_pointer_164, !noalias !2
        %stackPointer_247 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %res_4_77_4904_pointer_248 = getelementptr <{%Reference}>, %StackPointer %stackPointer_247, i64 0, i32 0
        store %Reference %res_4_77_4904, ptr %res_4_77_4904_pointer_248, !noalias !2
        %returnAddress_pointer_249 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_247, i64 0, i32 1, i32 0
        %sharer_pointer_250 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_247, i64 0, i32 1, i32 1
        %eraser_pointer_251 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_247, i64 0, i32 1, i32 2
        store ptr @returnAddress_237, ptr %returnAddress_pointer_249, !noalias !2
        store ptr @sharer_129, ptr %sharer_pointer_250, !noalias !2
        store ptr @eraser_133, ptr %eraser_pointer_251, !noalias !2
        
        %longLiteral_5161 = add i64 0, 0
        
        
        
        musttail call tailcc void @go_4_3_101_4807(i64 %longLiteral_5161, %Reference %res_4_77_4904, i64 %tmp_5107, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_259(i64 %returnValue_260, %Stack %stack) {
        
    entry:
        
        %stackPointer_261 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2567_3_11_4811_pointer_262 = getelementptr <{i64}>, %StackPointer %stackPointer_261, i64 0, i32 0
        %v_r_2567_3_11_4811 = load i64, ptr %v_r_2567_3_11_4811_pointer_262, !noalias !2
        %stackPointer_264 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_265 = getelementptr %FrameHeader, %StackPointer %stackPointer_264, i64 0, i32 0
        %returnAddress_263 = load %ReturnAddress, ptr %returnAddress_pointer_265, !noalias !2
        musttail call tailcc void %returnAddress_263(i64 %returnValue_260, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_282(%Pos %__10_29_22_62_4954, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_283 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_5_4_39_4945_pointer_284 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_283, i64 0, i32 0
        %i_5_4_39_4945 = load i64, ptr %i_5_4_39_4945_pointer_284, !noalias !2
        %res_4_12_4909_pointer_285 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_283, i64 0, i32 1
        %res_4_12_4909 = load %Reference, ptr %res_4_12_4909_pointer_285, !noalias !2
        %tmp_5107_pointer_286 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_283, i64 0, i32 2
        %tmp_5107 = load i64, ptr %tmp_5107_pointer_286, !noalias !2
        call ccc void @erasePositive(%Pos %__10_29_22_62_4954)
        
        %longLiteral_5171 = add i64 1, 0
        
        %pureApp_5170 = call ccc i64 @infixAdd_96(i64 %i_5_4_39_4945, i64 %longLiteral_5171)
        
        
        
        
        
        musttail call tailcc void @go_4_3_38_4805(i64 %pureApp_5170, %Reference %res_4_12_4909, i64 %tmp_5107, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_276(i64 %v_r_2569_6_25_18_58_4823, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_277 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %res_4_12_4909_pointer_278 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_277, i64 0, i32 0
        %res_4_12_4909 = load %Reference, ptr %res_4_12_4909_pointer_278, !noalias !2
        %i_5_4_39_4945_pointer_279 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_277, i64 0, i32 1
        %i_5_4_39_4945 = load i64, ptr %i_5_4_39_4945_pointer_279, !noalias !2
        %tmp_5083_pointer_280 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_277, i64 0, i32 2
        %tmp_5083 = load i64, ptr %tmp_5083_pointer_280, !noalias !2
        %tmp_5107_pointer_281 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_277, i64 0, i32 3
        %tmp_5107 = load i64, ptr %tmp_5107_pointer_281, !noalias !2
        
        %pureApp_5166 = call ccc i64 @infixMul_99(i64 %tmp_5083, i64 %tmp_5083)
        
        
        
        %pureApp_5167 = call ccc i64 @infixAdd_96(i64 %v_r_2569_6_25_18_58_4823, i64 %pureApp_5166)
        
        
        
        %longLiteral_5169 = add i64 1009, 0
        
        %pureApp_5168 = call ccc i64 @mod_108(i64 %pureApp_5167, i64 %longLiteral_5169)
        
        
        %stackPointer_293 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_5_4_39_4945_pointer_294 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_293, i64 0, i32 0
        store i64 %i_5_4_39_4945, ptr %i_5_4_39_4945_pointer_294, !noalias !2
        %res_4_12_4909_pointer_295 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_293, i64 0, i32 1
        store %Reference %res_4_12_4909, ptr %res_4_12_4909_pointer_295, !noalias !2
        %tmp_5107_pointer_296 = getelementptr <{i64, %Reference, i64}>, %StackPointer %stackPointer_293, i64 0, i32 2
        store i64 %tmp_5107, ptr %tmp_5107_pointer_296, !noalias !2
        %returnAddress_pointer_297 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_293, i64 0, i32 1, i32 0
        %sharer_pointer_298 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_293, i64 0, i32 1, i32 1
        %eraser_pointer_299 = getelementptr <{<{i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_293, i64 0, i32 1, i32 2
        store ptr @returnAddress_282, ptr %returnAddress_pointer_297, !noalias !2
        store ptr @sharer_70, ptr %sharer_pointer_298, !noalias !2
        store ptr @eraser_78, ptr %eraser_pointer_299, !noalias !2
        
        %res_4_12_4909pointer_300 = call ccc ptr @getVarPointer(%Reference %res_4_12_4909, %Stack %stack)
        %res_4_12_4909_old_301 = load i64, ptr %res_4_12_4909pointer_300, !noalias !2
        store i64 %pureApp_5168, ptr %res_4_12_4909pointer_300, !noalias !2
        
        %put_5172_temporary_302 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5172 = insertvalue %Pos %put_5172_temporary_302, %Object null, 1
        
        %stackPointer_304 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_305 = getelementptr %FrameHeader, %StackPointer %stackPointer_304, i64 0, i32 0
        %returnAddress_303 = load %ReturnAddress, ptr %returnAddress_pointer_305, !noalias !2
        musttail call tailcc void %returnAddress_303(%Pos %put_5172, %Stack %stack)
        ret void
}



define ccc void @sharer_310(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_311 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %res_4_12_4909_306_pointer_312 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_311, i64 0, i32 0
        %res_4_12_4909_306 = load %Reference, ptr %res_4_12_4909_306_pointer_312, !noalias !2
        %i_5_4_39_4945_307_pointer_313 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_311, i64 0, i32 1
        %i_5_4_39_4945_307 = load i64, ptr %i_5_4_39_4945_307_pointer_313, !noalias !2
        %tmp_5083_308_pointer_314 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_311, i64 0, i32 2
        %tmp_5083_308 = load i64, ptr %tmp_5083_308_pointer_314, !noalias !2
        %tmp_5107_309_pointer_315 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_311, i64 0, i32 3
        %tmp_5107_309 = load i64, ptr %tmp_5107_309_pointer_315, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_311)
        ret void
}



define ccc void @eraser_320(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_321 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %res_4_12_4909_316_pointer_322 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_321, i64 0, i32 0
        %res_4_12_4909_316 = load %Reference, ptr %res_4_12_4909_316_pointer_322, !noalias !2
        %i_5_4_39_4945_317_pointer_323 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_321, i64 0, i32 1
        %i_5_4_39_4945_317 = load i64, ptr %i_5_4_39_4945_317_pointer_323, !noalias !2
        %tmp_5083_318_pointer_324 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_321, i64 0, i32 2
        %tmp_5083_318 = load i64, ptr %tmp_5083_318_pointer_324, !noalias !2
        %tmp_5107_319_pointer_325 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_321, i64 0, i32 3
        %tmp_5107_319 = load i64, ptr %tmp_5107_319_pointer_325, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_321)
        ret void
}



define tailcc void @go_4_3_38_4805(i64 %i_5_4_39_4945, %Reference %res_4_12_4909, i64 %tmp_5107, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5163 = call ccc %Pos @infixGt_184(i64 %i_5_4_39_4945, i64 %tmp_5107)
        
        
        
        %tag_273 = extractvalue %Pos %pureApp_5163, 0
        %fields_274 = extractvalue %Pos %pureApp_5163, 1
        switch i64 %tag_273, label %label_275 [i64 0, label %label_339 i64 1, label %label_344]
    
    label_275:
        
        ret void
    
    label_339:
        
        %pureApp_5164 = call ccc %Pos @boxInt_301(i64 %i_5_4_39_4945)
        
        
        
        %pureApp_5165 = call ccc i64 @unboxInt_303(%Pos %pureApp_5164)
        
        
        %stackPointer_326 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %res_4_12_4909_pointer_327 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_326, i64 0, i32 0
        store %Reference %res_4_12_4909, ptr %res_4_12_4909_pointer_327, !noalias !2
        %i_5_4_39_4945_pointer_328 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_326, i64 0, i32 1
        store i64 %i_5_4_39_4945, ptr %i_5_4_39_4945_pointer_328, !noalias !2
        %tmp_5083_pointer_329 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_326, i64 0, i32 2
        store i64 %pureApp_5165, ptr %tmp_5083_pointer_329, !noalias !2
        %tmp_5107_pointer_330 = getelementptr <{%Reference, i64, i64, i64}>, %StackPointer %stackPointer_326, i64 0, i32 3
        store i64 %tmp_5107, ptr %tmp_5107_pointer_330, !noalias !2
        %returnAddress_pointer_331 = getelementptr <{<{%Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_326, i64 0, i32 1, i32 0
        %sharer_pointer_332 = getelementptr <{<{%Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_326, i64 0, i32 1, i32 1
        %eraser_pointer_333 = getelementptr <{<{%Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_326, i64 0, i32 1, i32 2
        store ptr @returnAddress_276, ptr %returnAddress_pointer_331, !noalias !2
        store ptr @sharer_310, ptr %sharer_pointer_332, !noalias !2
        store ptr @eraser_320, ptr %eraser_pointer_333, !noalias !2
        
        %get_5173_pointer_334 = call ccc ptr @getVarPointer(%Reference %res_4_12_4909, %Stack %stack)
        %res_4_12_4909_old_335 = load i64, ptr %get_5173_pointer_334, !noalias !2
        %get_5173 = load i64, ptr %get_5173_pointer_334, !noalias !2
        
        %stackPointer_337 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_338 = getelementptr %FrameHeader, %StackPointer %stackPointer_337, i64 0, i32 0
        %returnAddress_336 = load %ReturnAddress, ptr %returnAddress_pointer_338, !noalias !2
        musttail call tailcc void %returnAddress_336(i64 %get_5173, %Stack %stack)
        ret void
    
    label_344:
        
        %unitLiteral_5174_temporary_340 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5174 = insertvalue %Pos %unitLiteral_5174_temporary_340, %Object null, 1
        
        %stackPointer_342 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_343 = getelementptr %FrameHeader, %StackPointer %stackPointer_342, i64 0, i32 0
        %returnAddress_341 = load %ReturnAddress, ptr %returnAddress_pointer_343, !noalias !2
        musttail call tailcc void %returnAddress_341(%Pos %unitLiteral_5174, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_345(%Pos %__30_65_4956, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_346 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %res_4_12_4909_pointer_347 = getelementptr <{%Reference}>, %StackPointer %stackPointer_346, i64 0, i32 0
        %res_4_12_4909 = load %Reference, ptr %res_4_12_4909_pointer_347, !noalias !2
        call ccc void @erasePositive(%Pos %__30_65_4956)
        
        %get_5175_pointer_348 = call ccc ptr @getVarPointer(%Reference %res_4_12_4909, %Stack %stack)
        %res_4_12_4909_old_349 = load i64, ptr %get_5175_pointer_348, !noalias !2
        %get_5175 = load i64, ptr %get_5175_pointer_348, !noalias !2
        
        %stackPointer_351 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_352 = getelementptr %FrameHeader, %StackPointer %stackPointer_351, i64 0, i32 0
        %returnAddress_350 = load %ReturnAddress, ptr %returnAddress_pointer_352, !noalias !2
        musttail call tailcc void %returnAddress_350(i64 %get_5175, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3515_3579, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5123 = call ccc i64 @unboxInt_303(%Pos %v_coe_3515_3579)
        
        
        
        %longLiteral_5124 = add i64 0, 0
        
        
        %stackPointer_254 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_5107_pointer_255 = getelementptr <{i64}>, %StackPointer %stackPointer_254, i64 0, i32 0
        store i64 %pureApp_5123, ptr %tmp_5107_pointer_255, !noalias !2
        %returnAddress_pointer_256 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_254, i64 0, i32 1, i32 0
        %sharer_pointer_257 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_254, i64 0, i32 1, i32 1
        %eraser_pointer_258 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_254, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_256, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_257, !noalias !2
        store ptr @eraser_46, ptr %eraser_pointer_258, !noalias !2
        %res_4_12_4909 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_268 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2567_3_11_4811_pointer_269 = getelementptr <{i64}>, %StackPointer %stackPointer_268, i64 0, i32 0
        store i64 %longLiteral_5124, ptr %v_r_2567_3_11_4811_pointer_269, !noalias !2
        %returnAddress_pointer_270 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 0
        %sharer_pointer_271 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 1
        %eraser_pointer_272 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 2
        store ptr @returnAddress_259, ptr %returnAddress_pointer_270, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_271, !noalias !2
        store ptr @eraser_46, ptr %eraser_pointer_272, !noalias !2
        %stackPointer_355 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %res_4_12_4909_pointer_356 = getelementptr <{%Reference}>, %StackPointer %stackPointer_355, i64 0, i32 0
        store %Reference %res_4_12_4909, ptr %res_4_12_4909_pointer_356, !noalias !2
        %returnAddress_pointer_357 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 0
        %sharer_pointer_358 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 1
        %eraser_pointer_359 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 2
        store ptr @returnAddress_345, ptr %returnAddress_pointer_357, !noalias !2
        store ptr @sharer_129, ptr %sharer_pointer_358, !noalias !2
        store ptr @eraser_133, ptr %eraser_pointer_359, !noalias !2
        
        %longLiteral_5176 = add i64 0, 0
        
        
        
        musttail call tailcc void @go_4_3_38_4805(i64 %longLiteral_5176, %Reference %res_4_12_4909, i64 %pureApp_5123, %Stack %stack)
        ret void
}



define ccc void @sharer_360(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_361 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_361)
        ret void
}



define ccc void @eraser_362(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_363 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_363)
        ret void
}



define tailcc void @returnAddress_369(%Pos %returned_5177, %Stack %stack) {
        
    entry:
        
        %stack_370 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_372 = call ccc %StackPointer @stackDeallocate(%Stack %stack_370, i64 24)
        %returnAddress_pointer_373 = getelementptr %FrameHeader, %StackPointer %stackPointer_372, i64 0, i32 0
        %returnAddress_371 = load %ReturnAddress, ptr %returnAddress_pointer_373, !noalias !2
        musttail call tailcc void %returnAddress_371(%Pos %returned_5177, %Stack %stack_370)
        ret void
}



define ccc void @sharer_374(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_375 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_376(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_377 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_377)
        ret void
}



define ccc void @eraser_389(%Environment %environment) {
        
    entry:
        
        %tmp_5054_387_pointer_390 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5054_387 = load %Pos, ptr %tmp_5054_387_pointer_390, !noalias !2
        %acc_3_3_5_169_4708_388_pointer_391 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4708_388 = load %Pos, ptr %acc_3_3_5_169_4708_388_pointer_391, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5054_387)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4708_388)
        ret void
}



define tailcc void @toList_1_1_3_167_4510(i64 %start_2_2_4_168_4583, %Pos %acc_3_3_5_169_4708, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5179 = add i64 1, 0
        
        %pureApp_5178 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4583, i64 %longLiteral_5179)
        
        
        
        %tag_382 = extractvalue %Pos %pureApp_5178, 0
        %fields_383 = extractvalue %Pos %pureApp_5178, 1
        switch i64 %tag_382, label %label_384 [i64 0, label %label_395 i64 1, label %label_399]
    
    label_384:
        
        ret void
    
    label_395:
        
        %pureApp_5180 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4583)
        
        
        
        %longLiteral_5182 = add i64 1, 0
        
        %pureApp_5181 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4583, i64 %longLiteral_5182)
        
        
        
        %fields_385 = call ccc %Object @newObject(ptr @eraser_389, i64 32)
        %environment_386 = call ccc %Environment @objectEnvironment(%Object %fields_385)
        %tmp_5054_pointer_392 = getelementptr <{%Pos, %Pos}>, %Environment %environment_386, i64 0, i32 0
        store %Pos %pureApp_5180, ptr %tmp_5054_pointer_392, !noalias !2
        %acc_3_3_5_169_4708_pointer_393 = getelementptr <{%Pos, %Pos}>, %Environment %environment_386, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4708, ptr %acc_3_3_5_169_4708_pointer_393, !noalias !2
        %make_5183_temporary_394 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5183 = insertvalue %Pos %make_5183_temporary_394, %Object %fields_385, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4510(i64 %pureApp_5181, %Pos %make_5183, %Stack %stack)
        ret void
    
    label_399:
        
        %stackPointer_397 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_398 = getelementptr %FrameHeader, %StackPointer %stackPointer_397, i64 0, i32 0
        %returnAddress_396 = load %ReturnAddress, ptr %returnAddress_pointer_398, !noalias !2
        musttail call tailcc void %returnAddress_396(%Pos %acc_3_3_5_169_4708, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_410(%Pos %v_r_2668_32_59_223_4542, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_411 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_5061_pointer_412 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_411, i64 0, i32 0
        %tmp_5061 = load i64, ptr %tmp_5061_pointer_412, !noalias !2
        %v_r_2585_30_194_4492_pointer_413 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_411, i64 0, i32 1
        %v_r_2585_30_194_4492 = load %Pos, ptr %v_r_2585_30_194_4492_pointer_413, !noalias !2
        %p_8_9_4413_pointer_414 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_411, i64 0, i32 2
        %p_8_9_4413 = load %Prompt, ptr %p_8_9_4413_pointer_414, !noalias !2
        %index_7_34_198_4697_pointer_415 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_411, i64 0, i32 3
        %index_7_34_198_4697 = load i64, ptr %index_7_34_198_4697_pointer_415, !noalias !2
        %acc_8_35_199_4468_pointer_416 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_411, i64 0, i32 4
        %acc_8_35_199_4468 = load i64, ptr %acc_8_35_199_4468_pointer_416, !noalias !2
        
        %tag_417 = extractvalue %Pos %v_r_2668_32_59_223_4542, 0
        %fields_418 = extractvalue %Pos %v_r_2668_32_59_223_4542, 1
        switch i64 %tag_417, label %label_419 [i64 1, label %label_442 i64 0, label %label_449]
    
    label_419:
        
        ret void
    
    label_424:
        
        ret void
    
    label_430:
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4492)
        
        %pair_425 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4413)
        %k_13_14_4_4977 = extractvalue <{%Resumption, %Stack}> %pair_425, 0
        %stack_426 = extractvalue <{%Resumption, %Stack}> %pair_425, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4977)
        
        %longLiteral_5195 = add i64 5, 0
        
        
        
        %pureApp_5196 = call ccc %Pos @boxInt_301(i64 %longLiteral_5195)
        
        
        
        %stackPointer_428 = call ccc %StackPointer @stackDeallocate(%Stack %stack_426, i64 24)
        %returnAddress_pointer_429 = getelementptr %FrameHeader, %StackPointer %stackPointer_428, i64 0, i32 0
        %returnAddress_427 = load %ReturnAddress, ptr %returnAddress_pointer_429, !noalias !2
        musttail call tailcc void %returnAddress_427(%Pos %pureApp_5196, %Stack %stack_426)
        ret void
    
    label_433:
        
        ret void
    
    label_439:
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4492)
        
        %pair_434 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4413)
        %k_13_14_4_4976 = extractvalue <{%Resumption, %Stack}> %pair_434, 0
        %stack_435 = extractvalue <{%Resumption, %Stack}> %pair_434, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4976)
        
        %longLiteral_5199 = add i64 5, 0
        
        
        
        %pureApp_5200 = call ccc %Pos @boxInt_301(i64 %longLiteral_5199)
        
        
        
        %stackPointer_437 = call ccc %StackPointer @stackDeallocate(%Stack %stack_435, i64 24)
        %returnAddress_pointer_438 = getelementptr %FrameHeader, %StackPointer %stackPointer_437, i64 0, i32 0
        %returnAddress_436 = load %ReturnAddress, ptr %returnAddress_pointer_438, !noalias !2
        musttail call tailcc void %returnAddress_436(%Pos %pureApp_5200, %Stack %stack_435)
        ret void
    
    label_440:
        
        %longLiteral_5202 = add i64 1, 0
        
        %pureApp_5201 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4697, i64 %longLiteral_5202)
        
        
        
        %longLiteral_5204 = add i64 10, 0
        
        %pureApp_5203 = call ccc i64 @infixMul_99(i64 %longLiteral_5204, i64 %acc_8_35_199_4468)
        
        
        
        %pureApp_5205 = call ccc i64 @toInt_2085(i64 %pureApp_5192)
        
        
        
        %pureApp_5206 = call ccc i64 @infixSub_105(i64 %pureApp_5205, i64 %tmp_5061)
        
        
        
        %pureApp_5207 = call ccc i64 @infixAdd_96(i64 %pureApp_5203, i64 %pureApp_5206)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4673(i64 %pureApp_5201, i64 %pureApp_5207, i64 %tmp_5061, %Pos %v_r_2585_30_194_4492, %Prompt %p_8_9_4413, %Stack %stack)
        ret void
    
    label_441:
        
        %intLiteral_5198 = add i64 57, 0
        
        %pureApp_5197 = call ccc %Pos @infixLte_2093(i64 %pureApp_5192, i64 %intLiteral_5198)
        
        
        
        %tag_431 = extractvalue %Pos %pureApp_5197, 0
        %fields_432 = extractvalue %Pos %pureApp_5197, 1
        switch i64 %tag_431, label %label_433 [i64 0, label %label_439 i64 1, label %label_440]
    
    label_442:
        %environment_420 = call ccc %Environment @objectEnvironment(%Object %fields_418)
        %v_coe_3484_46_73_237_4722_pointer_421 = getelementptr <{%Pos}>, %Environment %environment_420, i64 0, i32 0
        %v_coe_3484_46_73_237_4722 = load %Pos, ptr %v_coe_3484_46_73_237_4722_pointer_421, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3484_46_73_237_4722)
        call ccc void @eraseObject(%Object %fields_418)
        
        %pureApp_5192 = call ccc i64 @unboxChar_313(%Pos %v_coe_3484_46_73_237_4722)
        
        
        
        %intLiteral_5194 = add i64 48, 0
        
        %pureApp_5193 = call ccc %Pos @infixGte_2099(i64 %pureApp_5192, i64 %intLiteral_5194)
        
        
        
        %tag_422 = extractvalue %Pos %pureApp_5193, 0
        %fields_423 = extractvalue %Pos %pureApp_5193, 1
        switch i64 %tag_422, label %label_424 [i64 0, label %label_430 i64 1, label %label_441]
    
    label_449:
        %environment_443 = call ccc %Environment @objectEnvironment(%Object %fields_418)
        %v_y_2675_76_103_267_5190_pointer_444 = getelementptr <{%Pos, %Pos}>, %Environment %environment_443, i64 0, i32 0
        %v_y_2675_76_103_267_5190 = load %Pos, ptr %v_y_2675_76_103_267_5190_pointer_444, !noalias !2
        %v_y_2676_77_104_268_5191_pointer_445 = getelementptr <{%Pos, %Pos}>, %Environment %environment_443, i64 0, i32 1
        %v_y_2676_77_104_268_5191 = load %Pos, ptr %v_y_2676_77_104_268_5191_pointer_445, !noalias !2
        call ccc void @eraseObject(%Object %fields_418)
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4492)
        
        %stackPointer_447 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_448 = getelementptr %FrameHeader, %StackPointer %stackPointer_447, i64 0, i32 0
        %returnAddress_446 = load %ReturnAddress, ptr %returnAddress_pointer_448, !noalias !2
        musttail call tailcc void %returnAddress_446(i64 %acc_8_35_199_4468, %Stack %stack)
        ret void
}



define ccc void @sharer_455(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_456 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5061_450_pointer_457 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_456, i64 0, i32 0
        %tmp_5061_450 = load i64, ptr %tmp_5061_450_pointer_457, !noalias !2
        %v_r_2585_30_194_4492_451_pointer_458 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_456, i64 0, i32 1
        %v_r_2585_30_194_4492_451 = load %Pos, ptr %v_r_2585_30_194_4492_451_pointer_458, !noalias !2
        %p_8_9_4413_452_pointer_459 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_456, i64 0, i32 2
        %p_8_9_4413_452 = load %Prompt, ptr %p_8_9_4413_452_pointer_459, !noalias !2
        %index_7_34_198_4697_453_pointer_460 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_456, i64 0, i32 3
        %index_7_34_198_4697_453 = load i64, ptr %index_7_34_198_4697_453_pointer_460, !noalias !2
        %acc_8_35_199_4468_454_pointer_461 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_456, i64 0, i32 4
        %acc_8_35_199_4468_454 = load i64, ptr %acc_8_35_199_4468_454_pointer_461, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2585_30_194_4492_451)
        call ccc void @shareFrames(%StackPointer %stackPointer_456)
        ret void
}



define ccc void @eraser_467(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_468 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5061_462_pointer_469 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_468, i64 0, i32 0
        %tmp_5061_462 = load i64, ptr %tmp_5061_462_pointer_469, !noalias !2
        %v_r_2585_30_194_4492_463_pointer_470 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_468, i64 0, i32 1
        %v_r_2585_30_194_4492_463 = load %Pos, ptr %v_r_2585_30_194_4492_463_pointer_470, !noalias !2
        %p_8_9_4413_464_pointer_471 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_468, i64 0, i32 2
        %p_8_9_4413_464 = load %Prompt, ptr %p_8_9_4413_464_pointer_471, !noalias !2
        %index_7_34_198_4697_465_pointer_472 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_468, i64 0, i32 3
        %index_7_34_198_4697_465 = load i64, ptr %index_7_34_198_4697_465_pointer_472, !noalias !2
        %acc_8_35_199_4468_466_pointer_473 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_468, i64 0, i32 4
        %acc_8_35_199_4468_466 = load i64, ptr %acc_8_35_199_4468_466_pointer_473, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4492_463)
        call ccc void @eraseFrames(%StackPointer %stackPointer_468)
        ret void
}



define tailcc void @returnAddress_484(%Pos %returned_5208, %Stack %stack) {
        
    entry:
        
        %stack_485 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_487 = call ccc %StackPointer @stackDeallocate(%Stack %stack_485, i64 24)
        %returnAddress_pointer_488 = getelementptr %FrameHeader, %StackPointer %stackPointer_487, i64 0, i32 0
        %returnAddress_486 = load %ReturnAddress, ptr %returnAddress_pointer_488, !noalias !2
        musttail call tailcc void %returnAddress_486(%Pos %returned_5208, %Stack %stack_485)
        ret void
}



define tailcc void @Exception_7_19_46_210_4479_clause_493(%Object %closure, %Pos %exc_8_20_47_211_4695, %Pos %msg_9_21_48_212_4707, %Stack %stack) {
        
    entry:
        
        %environment_494 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4690_pointer_495 = getelementptr <{%Prompt}>, %Environment %environment_494, i64 0, i32 0
        %p_6_18_45_209_4690 = load %Prompt, ptr %p_6_18_45_209_4690_pointer_495, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_496 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4690)
        %k_11_23_50_214_4737 = extractvalue <{%Resumption, %Stack}> %pair_496, 0
        %stack_497 = extractvalue <{%Resumption, %Stack}> %pair_496, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4737)
        
        %fields_498 = call ccc %Object @newObject(ptr @eraser_389, i64 32)
        %environment_499 = call ccc %Environment @objectEnvironment(%Object %fields_498)
        %exc_8_20_47_211_4695_pointer_502 = getelementptr <{%Pos, %Pos}>, %Environment %environment_499, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4695, ptr %exc_8_20_47_211_4695_pointer_502, !noalias !2
        %msg_9_21_48_212_4707_pointer_503 = getelementptr <{%Pos, %Pos}>, %Environment %environment_499, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4707, ptr %msg_9_21_48_212_4707_pointer_503, !noalias !2
        %make_5209_temporary_504 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5209 = insertvalue %Pos %make_5209_temporary_504, %Object %fields_498, 1
        
        
        
        %stackPointer_506 = call ccc %StackPointer @stackDeallocate(%Stack %stack_497, i64 24)
        %returnAddress_pointer_507 = getelementptr %FrameHeader, %StackPointer %stackPointer_506, i64 0, i32 0
        %returnAddress_505 = load %ReturnAddress, ptr %returnAddress_pointer_507, !noalias !2
        musttail call tailcc void %returnAddress_505(%Pos %make_5209, %Stack %stack_497)
        ret void
}


@vtable_508 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4479_clause_493]


define ccc void @eraser_512(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4690_511_pointer_513 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4690_511 = load %Prompt, ptr %p_6_18_45_209_4690_511_pointer_513, !noalias !2
        ret void
}



define ccc void @eraser_520(%Environment %environment) {
        
    entry:
        
        %tmp_5063_519_pointer_521 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5063_519 = load %Pos, ptr %tmp_5063_519_pointer_521, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5063_519)
        ret void
}



define tailcc void @returnAddress_516(i64 %v_coe_3483_6_28_55_219_4526, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5210 = call ccc %Pos @boxChar_311(i64 %v_coe_3483_6_28_55_219_4526)
        
        
        
        %fields_517 = call ccc %Object @newObject(ptr @eraser_520, i64 16)
        %environment_518 = call ccc %Environment @objectEnvironment(%Object %fields_517)
        %tmp_5063_pointer_522 = getelementptr <{%Pos}>, %Environment %environment_518, i64 0, i32 0
        store %Pos %pureApp_5210, ptr %tmp_5063_pointer_522, !noalias !2
        %make_5211_temporary_523 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5211 = insertvalue %Pos %make_5211_temporary_523, %Object %fields_517, 1
        
        
        
        %stackPointer_525 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_526 = getelementptr %FrameHeader, %StackPointer %stackPointer_525, i64 0, i32 0
        %returnAddress_524 = load %ReturnAddress, ptr %returnAddress_pointer_526, !noalias !2
        musttail call tailcc void %returnAddress_524(%Pos %make_5211, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4673(i64 %index_7_34_198_4697, i64 %acc_8_35_199_4468, i64 %tmp_5061, %Pos %v_r_2585_30_194_4492, %Prompt %p_8_9_4413, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2585_30_194_4492)
        %stackPointer_474 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_5061_pointer_475 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_474, i64 0, i32 0
        store i64 %tmp_5061, ptr %tmp_5061_pointer_475, !noalias !2
        %v_r_2585_30_194_4492_pointer_476 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_474, i64 0, i32 1
        store %Pos %v_r_2585_30_194_4492, ptr %v_r_2585_30_194_4492_pointer_476, !noalias !2
        %p_8_9_4413_pointer_477 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_474, i64 0, i32 2
        store %Prompt %p_8_9_4413, ptr %p_8_9_4413_pointer_477, !noalias !2
        %index_7_34_198_4697_pointer_478 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_474, i64 0, i32 3
        store i64 %index_7_34_198_4697, ptr %index_7_34_198_4697_pointer_478, !noalias !2
        %acc_8_35_199_4468_pointer_479 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_474, i64 0, i32 4
        store i64 %acc_8_35_199_4468, ptr %acc_8_35_199_4468_pointer_479, !noalias !2
        %returnAddress_pointer_480 = getelementptr <{<{i64, %Pos, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_474, i64 0, i32 1, i32 0
        %sharer_pointer_481 = getelementptr <{<{i64, %Pos, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_474, i64 0, i32 1, i32 1
        %eraser_pointer_482 = getelementptr <{<{i64, %Pos, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_474, i64 0, i32 1, i32 2
        store ptr @returnAddress_410, ptr %returnAddress_pointer_480, !noalias !2
        store ptr @sharer_455, ptr %sharer_pointer_481, !noalias !2
        store ptr @eraser_467, ptr %eraser_pointer_482, !noalias !2
        
        %stack_483 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4690 = call ccc %Prompt @currentPrompt(%Stack %stack_483)
        %stackPointer_489 = call ccc %StackPointer @stackAllocate(%Stack %stack_483, i64 24)
        %returnAddress_pointer_490 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_489, i64 0, i32 1, i32 0
        %sharer_pointer_491 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_489, i64 0, i32 1, i32 1
        %eraser_pointer_492 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_489, i64 0, i32 1, i32 2
        store ptr @returnAddress_484, ptr %returnAddress_pointer_490, !noalias !2
        store ptr @sharer_374, ptr %sharer_pointer_491, !noalias !2
        store ptr @eraser_376, ptr %eraser_pointer_492, !noalias !2
        
        %closure_509 = call ccc %Object @newObject(ptr @eraser_512, i64 8)
        %environment_510 = call ccc %Environment @objectEnvironment(%Object %closure_509)
        %p_6_18_45_209_4690_pointer_514 = getelementptr <{%Prompt}>, %Environment %environment_510, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4690, ptr %p_6_18_45_209_4690_pointer_514, !noalias !2
        %vtable_temporary_515 = insertvalue %Neg zeroinitializer, ptr @vtable_508, 0
        %Exception_7_19_46_210_4479 = insertvalue %Neg %vtable_temporary_515, %Object %closure_509, 1
        %stackPointer_527 = call ccc %StackPointer @stackAllocate(%Stack %stack_483, i64 24)
        %returnAddress_pointer_528 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 0
        %sharer_pointer_529 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 1
        %eraser_pointer_530 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 2
        store ptr @returnAddress_516, ptr %returnAddress_pointer_528, !noalias !2
        store ptr @sharer_360, ptr %sharer_pointer_529, !noalias !2
        store ptr @eraser_362, ptr %eraser_pointer_530, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2585_30_194_4492, i64 %index_7_34_198_4697, %Neg %Exception_7_19_46_210_4479, %Stack %stack_483)
        ret void
}



define tailcc void @Exception_9_106_133_297_4545_clause_531(%Object %closure, %Pos %exception_10_107_134_298_5212, %Pos %msg_11_108_135_299_5213, %Stack %stack) {
        
    entry:
        
        %environment_532 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4413_pointer_533 = getelementptr <{%Prompt}>, %Environment %environment_532, i64 0, i32 0
        %p_8_9_4413 = load %Prompt, ptr %p_8_9_4413_pointer_533, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5212)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5213)
        
        %pair_534 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4413)
        %k_13_14_4_5044 = extractvalue <{%Resumption, %Stack}> %pair_534, 0
        %stack_535 = extractvalue <{%Resumption, %Stack}> %pair_534, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5044)
        
        %longLiteral_5214 = add i64 5, 0
        
        
        
        %pureApp_5215 = call ccc %Pos @boxInt_301(i64 %longLiteral_5214)
        
        
        
        %stackPointer_537 = call ccc %StackPointer @stackDeallocate(%Stack %stack_535, i64 24)
        %returnAddress_pointer_538 = getelementptr %FrameHeader, %StackPointer %stackPointer_537, i64 0, i32 0
        %returnAddress_536 = load %ReturnAddress, ptr %returnAddress_pointer_538, !noalias !2
        musttail call tailcc void %returnAddress_536(%Pos %pureApp_5215, %Stack %stack_535)
        ret void
}


@vtable_539 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4545_clause_531]


define tailcc void @returnAddress_550(i64 %v_coe_3488_22_131_158_322_4684, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5218 = call ccc %Pos @boxInt_301(i64 %v_coe_3488_22_131_158_322_4684)
        
        
        
        
        
        %pureApp_5219 = call ccc i64 @unboxInt_303(%Pos %pureApp_5218)
        
        
        
        %pureApp_5220 = call ccc %Pos @boxInt_301(i64 %pureApp_5219)
        
        
        
        %stackPointer_552 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_553 = getelementptr %FrameHeader, %StackPointer %stackPointer_552, i64 0, i32 0
        %returnAddress_551 = load %ReturnAddress, ptr %returnAddress_pointer_553, !noalias !2
        musttail call tailcc void %returnAddress_551(%Pos %pureApp_5220, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_562(i64 %v_r_2682_1_9_20_129_156_320_4594, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5224 = add i64 0, 0
        
        %pureApp_5223 = call ccc i64 @infixSub_105(i64 %longLiteral_5224, i64 %v_r_2682_1_9_20_129_156_320_4594)
        
        
        
        %stackPointer_564 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_565 = getelementptr %FrameHeader, %StackPointer %stackPointer_564, i64 0, i32 0
        %returnAddress_563 = load %ReturnAddress, ptr %returnAddress_pointer_565, !noalias !2
        musttail call tailcc void %returnAddress_563(i64 %pureApp_5223, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_545(i64 %v_r_2681_3_14_123_150_314_4641, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_546 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_5061_pointer_547 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_546, i64 0, i32 0
        %tmp_5061 = load i64, ptr %tmp_5061_pointer_547, !noalias !2
        %v_r_2585_30_194_4492_pointer_548 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_546, i64 0, i32 1
        %v_r_2585_30_194_4492 = load %Pos, ptr %v_r_2585_30_194_4492_pointer_548, !noalias !2
        %p_8_9_4413_pointer_549 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_546, i64 0, i32 2
        %p_8_9_4413 = load %Prompt, ptr %p_8_9_4413_pointer_549, !noalias !2
        
        %intLiteral_5217 = add i64 45, 0
        
        %pureApp_5216 = call ccc %Pos @infixEq_78(i64 %v_r_2681_3_14_123_150_314_4641, i64 %intLiteral_5217)
        
        
        %stackPointer_554 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_555 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_554, i64 0, i32 1, i32 0
        %sharer_pointer_556 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_554, i64 0, i32 1, i32 1
        %eraser_pointer_557 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_554, i64 0, i32 1, i32 2
        store ptr @returnAddress_550, ptr %returnAddress_pointer_555, !noalias !2
        store ptr @sharer_360, ptr %sharer_pointer_556, !noalias !2
        store ptr @eraser_362, ptr %eraser_pointer_557, !noalias !2
        
        %tag_558 = extractvalue %Pos %pureApp_5216, 0
        %fields_559 = extractvalue %Pos %pureApp_5216, 1
        switch i64 %tag_558, label %label_560 [i64 0, label %label_561 i64 1, label %label_570]
    
    label_560:
        
        ret void
    
    label_561:
        
        %longLiteral_5221 = add i64 0, 0
        
        %longLiteral_5222 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4673(i64 %longLiteral_5221, i64 %longLiteral_5222, i64 %tmp_5061, %Pos %v_r_2585_30_194_4492, %Prompt %p_8_9_4413, %Stack %stack)
        ret void
    
    label_570:
        %stackPointer_566 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_567 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 0
        %sharer_pointer_568 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 1
        %eraser_pointer_569 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 2
        store ptr @returnAddress_562, ptr %returnAddress_pointer_567, !noalias !2
        store ptr @sharer_360, ptr %sharer_pointer_568, !noalias !2
        store ptr @eraser_362, ptr %eraser_pointer_569, !noalias !2
        
        %longLiteral_5225 = add i64 1, 0
        
        %longLiteral_5226 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4673(i64 %longLiteral_5225, i64 %longLiteral_5226, i64 %tmp_5061, %Pos %v_r_2585_30_194_4492, %Prompt %p_8_9_4413, %Stack %stack)
        ret void
}



define ccc void @sharer_574(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_575 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_5061_571_pointer_576 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_575, i64 0, i32 0
        %tmp_5061_571 = load i64, ptr %tmp_5061_571_pointer_576, !noalias !2
        %v_r_2585_30_194_4492_572_pointer_577 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_575, i64 0, i32 1
        %v_r_2585_30_194_4492_572 = load %Pos, ptr %v_r_2585_30_194_4492_572_pointer_577, !noalias !2
        %p_8_9_4413_573_pointer_578 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_575, i64 0, i32 2
        %p_8_9_4413_573 = load %Prompt, ptr %p_8_9_4413_573_pointer_578, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2585_30_194_4492_572)
        call ccc void @shareFrames(%StackPointer %stackPointer_575)
        ret void
}



define ccc void @eraser_582(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_583 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_5061_579_pointer_584 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_583, i64 0, i32 0
        %tmp_5061_579 = load i64, ptr %tmp_5061_579_pointer_584, !noalias !2
        %v_r_2585_30_194_4492_580_pointer_585 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_583, i64 0, i32 1
        %v_r_2585_30_194_4492_580 = load %Pos, ptr %v_r_2585_30_194_4492_580_pointer_585, !noalias !2
        %p_8_9_4413_581_pointer_586 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_583, i64 0, i32 2
        %p_8_9_4413_581 = load %Prompt, ptr %p_8_9_4413_581_pointer_586, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2585_30_194_4492_580)
        call ccc void @eraseFrames(%StackPointer %stackPointer_583)
        ret void
}



define tailcc void @returnAddress_407(%Pos %v_r_2585_30_194_4492, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_408 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4413_pointer_409 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_408, i64 0, i32 0
        %p_8_9_4413 = load %Prompt, ptr %p_8_9_4413_pointer_409, !noalias !2
        
        %intLiteral_5189 = add i64 48, 0
        
        %pureApp_5188 = call ccc i64 @toInt_2085(i64 %intLiteral_5189)
        
        
        
        %closure_540 = call ccc %Object @newObject(ptr @eraser_512, i64 8)
        %environment_541 = call ccc %Environment @objectEnvironment(%Object %closure_540)
        %p_8_9_4413_pointer_543 = getelementptr <{%Prompt}>, %Environment %environment_541, i64 0, i32 0
        store %Prompt %p_8_9_4413, ptr %p_8_9_4413_pointer_543, !noalias !2
        %vtable_temporary_544 = insertvalue %Neg zeroinitializer, ptr @vtable_539, 0
        %Exception_9_106_133_297_4545 = insertvalue %Neg %vtable_temporary_544, %Object %closure_540, 1
        call ccc void @sharePositive(%Pos %v_r_2585_30_194_4492)
        %stackPointer_587 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_5061_pointer_588 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_587, i64 0, i32 0
        store i64 %pureApp_5188, ptr %tmp_5061_pointer_588, !noalias !2
        %v_r_2585_30_194_4492_pointer_589 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_587, i64 0, i32 1
        store %Pos %v_r_2585_30_194_4492, ptr %v_r_2585_30_194_4492_pointer_589, !noalias !2
        %p_8_9_4413_pointer_590 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_587, i64 0, i32 2
        store %Prompt %p_8_9_4413, ptr %p_8_9_4413_pointer_590, !noalias !2
        %returnAddress_pointer_591 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_587, i64 0, i32 1, i32 0
        %sharer_pointer_592 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_587, i64 0, i32 1, i32 1
        %eraser_pointer_593 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_587, i64 0, i32 1, i32 2
        store ptr @returnAddress_545, ptr %returnAddress_pointer_591, !noalias !2
        store ptr @sharer_574, ptr %sharer_pointer_592, !noalias !2
        store ptr @eraser_582, ptr %eraser_pointer_593, !noalias !2
        
        %longLiteral_5227 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2585_30_194_4492, i64 %longLiteral_5227, %Neg %Exception_9_106_133_297_4545, %Stack %stack)
        ret void
}



define ccc void @sharer_595(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_596 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4413_594_pointer_597 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_596, i64 0, i32 0
        %p_8_9_4413_594 = load %Prompt, ptr %p_8_9_4413_594_pointer_597, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_596)
        ret void
}



define ccc void @eraser_599(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_600 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4413_598_pointer_601 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_600, i64 0, i32 0
        %p_8_9_4413_598 = load %Prompt, ptr %p_8_9_4413_598_pointer_601, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_600)
        ret void
}


@utf8StringLiteral_5228.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_404(%Pos %v_r_2584_24_188_4452, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_405 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4413_pointer_406 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_405, i64 0, i32 0
        %p_8_9_4413 = load %Prompt, ptr %p_8_9_4413_pointer_406, !noalias !2
        %stackPointer_602 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4413_pointer_603 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_602, i64 0, i32 0
        store %Prompt %p_8_9_4413, ptr %p_8_9_4413_pointer_603, !noalias !2
        %returnAddress_pointer_604 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_602, i64 0, i32 1, i32 0
        %sharer_pointer_605 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_602, i64 0, i32 1, i32 1
        %eraser_pointer_606 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_602, i64 0, i32 1, i32 2
        store ptr @returnAddress_407, ptr %returnAddress_pointer_604, !noalias !2
        store ptr @sharer_595, ptr %sharer_pointer_605, !noalias !2
        store ptr @eraser_599, ptr %eraser_pointer_606, !noalias !2
        
        %tag_607 = extractvalue %Pos %v_r_2584_24_188_4452, 0
        %fields_608 = extractvalue %Pos %v_r_2584_24_188_4452, 1
        switch i64 %tag_607, label %label_609 [i64 0, label %label_613 i64 1, label %label_619]
    
    label_609:
        
        ret void
    
    label_613:
        
        %utf8StringLiteral_5228 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5228.lit)
        
        %stackPointer_611 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_612 = getelementptr %FrameHeader, %StackPointer %stackPointer_611, i64 0, i32 0
        %returnAddress_610 = load %ReturnAddress, ptr %returnAddress_pointer_612, !noalias !2
        musttail call tailcc void %returnAddress_610(%Pos %utf8StringLiteral_5228, %Stack %stack)
        ret void
    
    label_619:
        %environment_614 = call ccc %Environment @objectEnvironment(%Object %fields_608)
        %v_y_3310_8_29_193_4488_pointer_615 = getelementptr <{%Pos}>, %Environment %environment_614, i64 0, i32 0
        %v_y_3310_8_29_193_4488 = load %Pos, ptr %v_y_3310_8_29_193_4488_pointer_615, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3310_8_29_193_4488)
        call ccc void @eraseObject(%Object %fields_608)
        
        %stackPointer_617 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_618 = getelementptr %FrameHeader, %StackPointer %stackPointer_617, i64 0, i32 0
        %returnAddress_616 = load %ReturnAddress, ptr %returnAddress_pointer_618, !noalias !2
        musttail call tailcc void %returnAddress_616(%Pos %v_y_3310_8_29_193_4488, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_401(%Pos %v_r_2583_13_177_4596, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_402 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4413_pointer_403 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_402, i64 0, i32 0
        %p_8_9_4413 = load %Prompt, ptr %p_8_9_4413_pointer_403, !noalias !2
        %stackPointer_622 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4413_pointer_623 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_622, i64 0, i32 0
        store %Prompt %p_8_9_4413, ptr %p_8_9_4413_pointer_623, !noalias !2
        %returnAddress_pointer_624 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_622, i64 0, i32 1, i32 0
        %sharer_pointer_625 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_622, i64 0, i32 1, i32 1
        %eraser_pointer_626 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_622, i64 0, i32 1, i32 2
        store ptr @returnAddress_404, ptr %returnAddress_pointer_624, !noalias !2
        store ptr @sharer_595, ptr %sharer_pointer_625, !noalias !2
        store ptr @eraser_599, ptr %eraser_pointer_626, !noalias !2
        
        %tag_627 = extractvalue %Pos %v_r_2583_13_177_4596, 0
        %fields_628 = extractvalue %Pos %v_r_2583_13_177_4596, 1
        switch i64 %tag_627, label %label_629 [i64 0, label %label_634 i64 1, label %label_646]
    
    label_629:
        
        ret void
    
    label_634:
        
        %make_5229_temporary_630 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5229 = insertvalue %Pos %make_5229_temporary_630, %Object null, 1
        
        
        
        %stackPointer_632 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_633 = getelementptr %FrameHeader, %StackPointer %stackPointer_632, i64 0, i32 0
        %returnAddress_631 = load %ReturnAddress, ptr %returnAddress_pointer_633, !noalias !2
        musttail call tailcc void %returnAddress_631(%Pos %make_5229, %Stack %stack)
        ret void
    
    label_646:
        %environment_635 = call ccc %Environment @objectEnvironment(%Object %fields_628)
        %v_y_2819_10_21_185_4696_pointer_636 = getelementptr <{%Pos, %Pos}>, %Environment %environment_635, i64 0, i32 0
        %v_y_2819_10_21_185_4696 = load %Pos, ptr %v_y_2819_10_21_185_4696_pointer_636, !noalias !2
        %v_y_2820_11_22_186_4556_pointer_637 = getelementptr <{%Pos, %Pos}>, %Environment %environment_635, i64 0, i32 1
        %v_y_2820_11_22_186_4556 = load %Pos, ptr %v_y_2820_11_22_186_4556_pointer_637, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2819_10_21_185_4696)
        call ccc void @eraseObject(%Object %fields_628)
        
        %fields_638 = call ccc %Object @newObject(ptr @eraser_520, i64 16)
        %environment_639 = call ccc %Environment @objectEnvironment(%Object %fields_638)
        %v_y_2819_10_21_185_4696_pointer_641 = getelementptr <{%Pos}>, %Environment %environment_639, i64 0, i32 0
        store %Pos %v_y_2819_10_21_185_4696, ptr %v_y_2819_10_21_185_4696_pointer_641, !noalias !2
        %make_5230_temporary_642 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5230 = insertvalue %Pos %make_5230_temporary_642, %Object %fields_638, 1
        
        
        
        %stackPointer_644 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_645 = getelementptr %FrameHeader, %StackPointer %stackPointer_644, i64 0, i32 0
        %returnAddress_643 = load %ReturnAddress, ptr %returnAddress_pointer_645, !noalias !2
        musttail call tailcc void %returnAddress_643(%Pos %make_5230, %Stack %stack)
        ret void
}



define tailcc void @main_2444(%Stack %stack) {
        
    entry:
        
        %stackPointer_364 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_365 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_364, i64 0, i32 1, i32 0
        %sharer_pointer_366 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_364, i64 0, i32 1, i32 1
        %eraser_pointer_367 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_364, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_365, !noalias !2
        store ptr @sharer_360, ptr %sharer_pointer_366, !noalias !2
        store ptr @eraser_362, ptr %eraser_pointer_367, !noalias !2
        
        %stack_368 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4413 = call ccc %Prompt @currentPrompt(%Stack %stack_368)
        %stackPointer_378 = call ccc %StackPointer @stackAllocate(%Stack %stack_368, i64 24)
        %returnAddress_pointer_379 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_378, i64 0, i32 1, i32 0
        %sharer_pointer_380 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_378, i64 0, i32 1, i32 1
        %eraser_pointer_381 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_378, i64 0, i32 1, i32 2
        store ptr @returnAddress_369, ptr %returnAddress_pointer_379, !noalias !2
        store ptr @sharer_374, ptr %sharer_pointer_380, !noalias !2
        store ptr @eraser_376, ptr %eraser_pointer_381, !noalias !2
        
        %pureApp_5184 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5186 = add i64 1, 0
        
        %pureApp_5185 = call ccc i64 @infixSub_105(i64 %pureApp_5184, i64 %longLiteral_5186)
        
        
        
        %make_5187_temporary_400 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5187 = insertvalue %Pos %make_5187_temporary_400, %Object null, 1
        
        
        %stackPointer_649 = call ccc %StackPointer @stackAllocate(%Stack %stack_368, i64 32)
        %p_8_9_4413_pointer_650 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_649, i64 0, i32 0
        store %Prompt %p_8_9_4413, ptr %p_8_9_4413_pointer_650, !noalias !2
        %returnAddress_pointer_651 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 0
        %sharer_pointer_652 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 1
        %eraser_pointer_653 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 2
        store ptr @returnAddress_401, ptr %returnAddress_pointer_651, !noalias !2
        store ptr @sharer_595, ptr %sharer_pointer_652, !noalias !2
        store ptr @eraser_599, ptr %eraser_pointer_653, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4510(i64 %pureApp_5185, %Pos %make_5187, %Stack %stack_368)
        ret void
}


@utf8StringLiteral_5114.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5116.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5119.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_654(%Pos %v_r_2750_3546, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_655 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_656 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_655, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_656, !noalias !2
        %index_2107_pointer_657 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_655, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_657, !noalias !2
        %Exception_2362_pointer_658 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_655, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_658, !noalias !2
        
        %tag_659 = extractvalue %Pos %v_r_2750_3546, 0
        %fields_660 = extractvalue %Pos %v_r_2750_3546, 1
        switch i64 %tag_659, label %label_661 [i64 0, label %label_665 i64 1, label %label_671]
    
    label_661:
        
        ret void
    
    label_665:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5110 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_663 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_664 = getelementptr %FrameHeader, %StackPointer %stackPointer_663, i64 0, i32 0
        %returnAddress_662 = load %ReturnAddress, ptr %returnAddress_pointer_664, !noalias !2
        musttail call tailcc void %returnAddress_662(i64 %pureApp_5110, %Stack %stack)
        ret void
    
    label_671:
        
        %make_5111_temporary_666 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5111 = insertvalue %Pos %make_5111_temporary_666, %Object null, 1
        
        
        
        %pureApp_5112 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5114 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5114.lit)
        
        %pureApp_5113 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5114, %Pos %pureApp_5112)
        
        
        
        %utf8StringLiteral_5116 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5116.lit)
        
        %pureApp_5115 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5113, %Pos %utf8StringLiteral_5116)
        
        
        
        %pureApp_5117 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5115, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5119 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5119.lit)
        
        %pureApp_5118 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5117, %Pos %utf8StringLiteral_5119)
        
        
        
        %vtable_667 = extractvalue %Neg %Exception_2362, 0
        %closure_668 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_669 = getelementptr ptr, ptr %vtable_667, i64 0
        %functionPointer_670 = load ptr, ptr %functionPointer_pointer_669, !noalias !2
        musttail call tailcc void %functionPointer_670(%Object %closure_668, %Pos %make_5111, %Pos %pureApp_5118, %Stack %stack)
        ret void
}



define ccc void @sharer_675(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_676 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_672_pointer_677 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_676, i64 0, i32 0
        %str_2106_672 = load %Pos, ptr %str_2106_672_pointer_677, !noalias !2
        %index_2107_673_pointer_678 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_676, i64 0, i32 1
        %index_2107_673 = load i64, ptr %index_2107_673_pointer_678, !noalias !2
        %Exception_2362_674_pointer_679 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_676, i64 0, i32 2
        %Exception_2362_674 = load %Neg, ptr %Exception_2362_674_pointer_679, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_672)
        call ccc void @shareNegative(%Neg %Exception_2362_674)
        call ccc void @shareFrames(%StackPointer %stackPointer_676)
        ret void
}



define ccc void @eraser_683(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_684 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_680_pointer_685 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_684, i64 0, i32 0
        %str_2106_680 = load %Pos, ptr %str_2106_680_pointer_685, !noalias !2
        %index_2107_681_pointer_686 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_684, i64 0, i32 1
        %index_2107_681 = load i64, ptr %index_2107_681_pointer_686, !noalias !2
        %Exception_2362_682_pointer_687 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_684, i64 0, i32 2
        %Exception_2362_682 = load %Neg, ptr %Exception_2362_682_pointer_687, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_680)
        call ccc void @eraseNegative(%Neg %Exception_2362_682)
        call ccc void @eraseFrames(%StackPointer %stackPointer_684)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5109 = add i64 0, 0
        
        %pureApp_5108 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5109)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_688 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_689 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_688, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_689, !noalias !2
        %index_2107_pointer_690 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_688, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_690, !noalias !2
        %Exception_2362_pointer_691 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_688, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_691, !noalias !2
        %returnAddress_pointer_692 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 0
        %sharer_pointer_693 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 1
        %eraser_pointer_694 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 2
        store ptr @returnAddress_654, ptr %returnAddress_pointer_692, !noalias !2
        store ptr @sharer_675, ptr %sharer_pointer_693, !noalias !2
        store ptr @eraser_683, ptr %eraser_pointer_694, !noalias !2
        
        %tag_695 = extractvalue %Pos %pureApp_5108, 0
        %fields_696 = extractvalue %Pos %pureApp_5108, 1
        switch i64 %tag_695, label %label_697 [i64 0, label %label_701 i64 1, label %label_706]
    
    label_697:
        
        ret void
    
    label_701:
        
        %pureApp_5120 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5121 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5120)
        
        
        
        %stackPointer_699 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_700 = getelementptr %FrameHeader, %StackPointer %stackPointer_699, i64 0, i32 0
        %returnAddress_698 = load %ReturnAddress, ptr %returnAddress_pointer_700, !noalias !2
        musttail call tailcc void %returnAddress_698(%Pos %pureApp_5121, %Stack %stack)
        ret void
    
    label_706:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5122_temporary_702 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5122 = insertvalue %Pos %booleanLiteral_5122_temporary_702, %Object null, 1
        
        %stackPointer_704 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_705 = getelementptr %FrameHeader, %StackPointer %stackPointer_704, i64 0, i32 0
        %returnAddress_703 = load %ReturnAddress, ptr %returnAddress_pointer_705, !noalias !2
        musttail call tailcc void %returnAddress_703(%Pos %booleanLiteral_5122, %Stack %stack)
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
