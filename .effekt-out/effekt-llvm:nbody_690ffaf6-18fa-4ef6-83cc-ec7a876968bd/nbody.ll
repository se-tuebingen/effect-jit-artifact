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



define ccc %Pos @show_18(double %value_17) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_bytearray_show_Double(%Double %value_17)
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



define ccc double @sqrt_130(double %x_129) {
    ; declaration extern
    ; variable
    %z = call %Double @llvm.sqrt.f64(double %x_129) ret %Double %z
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


; declaration include
  declare i32 @clock_gettime(i32, ptr)



define ccc %Pos @allocate_2473(i64 %size_2472) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_new(%Int %size_2472)
    ret %Pos %z
  
}



define ccc i64 @size_2483(%Pos %arr_2482) {
    ; declaration extern
    ; variable
    
    %z = call %Int @c_array_size(%Pos %arr_2482)
    ret %Int %z
  
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



define ccc void @eraser_11(%Environment %environment) {
        
    entry:
        
        %doubleLiteral_16466_4_pointer_12 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment, i64 0, i32 0
        %doubleLiteral_16466_4 = load double, ptr %doubleLiteral_16466_4_pointer_12, !noalias !2
        %doubleLiteral_16467_5_pointer_13 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment, i64 0, i32 1
        %doubleLiteral_16467_5 = load double, ptr %doubleLiteral_16467_5_pointer_13, !noalias !2
        %doubleLiteral_16468_6_pointer_14 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment, i64 0, i32 2
        %doubleLiteral_16468_6 = load double, ptr %doubleLiteral_16468_6_pointer_14, !noalias !2
        %tmp_16295_7_pointer_15 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment, i64 0, i32 3
        %tmp_16295_7 = load double, ptr %tmp_16295_7_pointer_15, !noalias !2
        %tmp_16296_8_pointer_16 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment, i64 0, i32 4
        %tmp_16296_8 = load double, ptr %tmp_16296_8_pointer_16, !noalias !2
        %tmp_16297_9_pointer_17 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment, i64 0, i32 5
        %tmp_16297_9 = load double, ptr %tmp_16297_9_pointer_17, !noalias !2
        %tmp_16298_10_pointer_18 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment, i64 0, i32 6
        %tmp_16298_10 = load double, ptr %tmp_16298_10_pointer_18, !noalias !2
        ret void
}



define tailcc void @loop_5_257_775_774_4358_12496(i64 %i_6_258_776_775_4359_12272, i64 %i_6_518_517_4101_11416, i64 %tmp_16349, %Pos %bodies_2361_12198, %Stack %stack) {
        
    entry:
        
        
        %pureApp_16538 = call ccc %Pos @infixLt_178(i64 %i_6_258_776_775_4359_12272, i64 %tmp_16349)
        
        
        
        %tag_114 = extractvalue %Pos %pureApp_16538, 0
        %fields_115 = extractvalue %Pos %pureApp_16538, 1
        switch i64 %tag_114, label %label_116 [i64 0, label %label_121 i64 1, label %label_468]
    
    label_116:
        
        ret void
    
    label_121:
        call ccc void @erasePositive(%Pos %bodies_2361_12198)
        
        %unitLiteral_16539_temporary_117 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_16539 = insertvalue %Pos %unitLiteral_16539_temporary_117, %Object null, 1
        
        %stackPointer_119 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_120 = getelementptr %FrameHeader, %StackPointer %stackPointer_119, i64 0, i32 0
        %returnAddress_118 = load %ReturnAddress, ptr %returnAddress_pointer_120, !noalias !2
        musttail call tailcc void %returnAddress_118(%Pos %unitLiteral_16539, %Stack %stack)
        ret void
    
    label_124:
        
        ret void
    
    label_135:
        
        ret void
    
    label_146:
        
        ret void
    
    label_157:
        
        ret void
    
    label_168:
        
        ret void
    
    label_179:
        
        ret void
    
    label_190:
        
        ret void
    
    label_201:
        
        ret void
    
    label_212:
        
        ret void
    
    label_223:
        
        ret void
    
    label_234:
        
        ret void
    
    label_245:
        
        ret void
    
    label_256:
        
        ret void
    
    label_267:
        
        ret void
    
    label_278:
        
        ret void
    
    label_289:
        
        ret void
    
    label_317:
        
        ret void
    
    label_328:
        
        ret void
    
    label_339:
        
        ret void
    
    label_350:
        
        ret void
    
    label_361:
        
        ret void
    
    label_372:
        
        ret void
    
    label_383:
        
        ret void
    
    label_394:
        
        ret void
    
    label_405:
        
        ret void
    
    label_416:
        
        ret void
    
    label_442:
        %environment_417 = call ccc %Environment @objectEnvironment(%Object %fields_415)
        %__234_492_1010_1009_4593_15415_pointer_418 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_417, i64 0, i32 0
        %__234_492_1010_1009_4593_15415 = load double, ptr %__234_492_1010_1009_4593_15415_pointer_418, !noalias !2
        %__235_493_1011_1010_4594_15416_pointer_419 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_417, i64 0, i32 1
        %__235_493_1011_1010_4594_15416 = load double, ptr %__235_493_1011_1010_4594_15416_pointer_419, !noalias !2
        %__236_494_1012_1011_4595_15417_pointer_420 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_417, i64 0, i32 2
        %__236_494_1012_1011_4595_15417 = load double, ptr %__236_494_1012_1011_4595_15417_pointer_420, !noalias !2
        %__237_495_1013_1012_4596_15418_pointer_421 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_417, i64 0, i32 3
        %__237_495_1013_1012_4596_15418 = load double, ptr %__237_495_1013_1012_4596_15418_pointer_421, !noalias !2
        %__238_496_1014_1013_4597_15419_pointer_422 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_417, i64 0, i32 4
        %__238_496_1014_1013_4597_15419 = load double, ptr %__238_496_1014_1013_4597_15419_pointer_422, !noalias !2
        %__239_497_1015_1014_4598_15420_pointer_423 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_417, i64 0, i32 5
        %__239_497_1015_1014_4598_15420 = load double, ptr %__239_497_1015_1014_4598_15420_pointer_423, !noalias !2
        %x_240_498_1016_1015_4599_12194_pointer_424 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_417, i64 0, i32 6
        %x_240_498_1016_1015_4599_12194 = load double, ptr %x_240_498_1016_1015_4599_12194_pointer_424, !noalias !2
        call ccc void @eraseObject(%Object %fields_415)
        
        %pureApp_16565 = call ccc double @infixMul_114(double %pureApp_16542, double %x_200_458_976_975_4559_11229)
        
        
        
        %pureApp_16566 = call ccc double @infixMul_114(double %pureApp_16565, double %pureApp_16552)
        
        
        
        %pureApp_16567 = call ccc double @infixAdd_111(double %x_189_447_965_964_4548_11223, double %pureApp_16566)
        
        
        
        %pureApp_16568 = call ccc double @infixMul_114(double %pureApp_16543, double %x_216_474_992_991_4575_12110)
        
        
        
        %pureApp_16569 = call ccc double @infixMul_114(double %pureApp_16568, double %pureApp_16552)
        
        
        
        %pureApp_16570 = call ccc double @infixAdd_111(double %x_206_464_982_981_4565_11125, double %pureApp_16569)
        
        
        
        %pureApp_16571 = call ccc double @infixMul_114(double %pureApp_16544, double %x_232_490_1008_1007_4591_10836)
        
        
        
        %pureApp_16572 = call ccc double @infixMul_114(double %pureApp_16571, double %pureApp_16552)
        
        
        
        %pureApp_16573 = call ccc double @infixAdd_111(double %x_223_481_999_998_4582_11211, double %pureApp_16572)
        
        
        
        %fields_425 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_426 = call ccc %Environment @objectEnvironment(%Object %fields_425)
        %x_162_420_938_937_4521_10549_pointer_434 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_426, i64 0, i32 0
        store double %x_162_420_938_937_4521_10549, ptr %x_162_420_938_937_4521_10549_pointer_434, !noalias !2
        %x_171_429_947_946_4530_11288_pointer_435 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_426, i64 0, i32 1
        store double %x_171_429_947_946_4530_11288, ptr %x_171_429_947_946_4530_11288_pointer_435, !noalias !2
        %x_180_438_956_955_4539_11074_pointer_436 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_426, i64 0, i32 2
        store double %x_180_438_956_955_4539_11074, ptr %x_180_438_956_955_4539_11074_pointer_436, !noalias !2
        %tmp_16377_pointer_437 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_426, i64 0, i32 3
        store double %pureApp_16567, ptr %tmp_16377_pointer_437, !noalias !2
        %tmp_16380_pointer_438 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_426, i64 0, i32 4
        store double %pureApp_16570, ptr %tmp_16380_pointer_438, !noalias !2
        %tmp_16383_pointer_439 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_426, i64 0, i32 5
        store double %pureApp_16573, ptr %tmp_16383_pointer_439, !noalias !2
        %x_240_498_1016_1015_4599_12194_pointer_440 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_426, i64 0, i32 6
        store double %x_240_498_1016_1015_4599_12194, ptr %x_240_498_1016_1015_4599_12194_pointer_440, !noalias !2
        %make_16574_temporary_441 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16574 = insertvalue %Pos %make_16574_temporary_441, %Object %fields_425, 1
        
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16575 = call ccc %Pos @unsafeSet_2492(%Pos %bodies_2361_12198, i64 %i_6_258_776_775_4359_12272, %Pos %make_16574)
        call ccc void @erasePositive(%Pos %pureApp_16575)
        
        
        
        %longLiteral_16577 = add i64 1, 0
        
        %pureApp_16576 = call ccc i64 @infixAdd_96(i64 %i_6_258_776_775_4359_12272, i64 %longLiteral_16577)
        
        
        
        
        
        musttail call tailcc void @loop_5_257_775_774_4358_12496(i64 %pureApp_16576, i64 %i_6_518_517_4101_11416, i64 %tmp_16349, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
    
    label_443:
        %environment_406 = call ccc %Environment @objectEnvironment(%Object %fields_404)
        %__226_484_1002_1001_4585_15409_pointer_407 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_406, i64 0, i32 0
        %__226_484_1002_1001_4585_15409 = load double, ptr %__226_484_1002_1001_4585_15409_pointer_407, !noalias !2
        %__227_485_1003_1002_4586_15410_pointer_408 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_406, i64 0, i32 1
        %__227_485_1003_1002_4586_15410 = load double, ptr %__227_485_1003_1002_4586_15410_pointer_408, !noalias !2
        %__228_486_1004_1003_4587_15411_pointer_409 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_406, i64 0, i32 2
        %__228_486_1004_1003_4587_15411 = load double, ptr %__228_486_1004_1003_4587_15411_pointer_409, !noalias !2
        %__229_487_1005_1004_4588_15412_pointer_410 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_406, i64 0, i32 3
        %__229_487_1005_1004_4588_15412 = load double, ptr %__229_487_1005_1004_4588_15412_pointer_410, !noalias !2
        %__230_488_1006_1005_4589_15413_pointer_411 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_406, i64 0, i32 4
        %__230_488_1006_1005_4589_15413 = load double, ptr %__230_488_1006_1005_4589_15413_pointer_411, !noalias !2
        %__231_489_1007_1006_4590_15414_pointer_412 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_406, i64 0, i32 5
        %__231_489_1007_1006_4590_15414 = load double, ptr %__231_489_1007_1006_4590_15414_pointer_412, !noalias !2
        %x_232_490_1008_1007_4591_10836_pointer_413 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_406, i64 0, i32 6
        %x_232_490_1008_1007_4591_10836 = load double, ptr %x_232_490_1008_1007_4591_10836_pointer_413, !noalias !2
        call ccc void @eraseObject(%Object %fields_404)
        
        %tag_414 = extractvalue %Pos %pureApp_16541, 0
        %fields_415 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_414, label %label_416 [i64 0, label %label_442]
    
    label_444:
        %environment_395 = call ccc %Environment @objectEnvironment(%Object %fields_393)
        %__218_476_994_993_4577_15403_pointer_396 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_395, i64 0, i32 0
        %__218_476_994_993_4577_15403 = load double, ptr %__218_476_994_993_4577_15403_pointer_396, !noalias !2
        %__219_477_995_994_4578_15404_pointer_397 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_395, i64 0, i32 1
        %__219_477_995_994_4578_15404 = load double, ptr %__219_477_995_994_4578_15404_pointer_397, !noalias !2
        %__220_478_996_995_4579_15405_pointer_398 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_395, i64 0, i32 2
        %__220_478_996_995_4579_15405 = load double, ptr %__220_478_996_995_4579_15405_pointer_398, !noalias !2
        %__221_479_997_996_4580_15406_pointer_399 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_395, i64 0, i32 3
        %__221_479_997_996_4580_15406 = load double, ptr %__221_479_997_996_4580_15406_pointer_399, !noalias !2
        %__222_480_998_997_4581_15407_pointer_400 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_395, i64 0, i32 4
        %__222_480_998_997_4581_15407 = load double, ptr %__222_480_998_997_4581_15407_pointer_400, !noalias !2
        %x_223_481_999_998_4582_11211_pointer_401 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_395, i64 0, i32 5
        %x_223_481_999_998_4582_11211 = load double, ptr %x_223_481_999_998_4582_11211_pointer_401, !noalias !2
        %__224_482_1000_999_4583_15408_pointer_402 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_395, i64 0, i32 6
        %__224_482_1000_999_4583_15408 = load double, ptr %__224_482_1000_999_4583_15408_pointer_402, !noalias !2
        call ccc void @eraseObject(%Object %fields_393)
        
        %tag_403 = extractvalue %Pos %pureApp_16540, 0
        %fields_404 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_403, label %label_405 [i64 0, label %label_443]
    
    label_445:
        %environment_384 = call ccc %Environment @objectEnvironment(%Object %fields_382)
        %__210_468_986_985_4569_15397_pointer_385 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_384, i64 0, i32 0
        %__210_468_986_985_4569_15397 = load double, ptr %__210_468_986_985_4569_15397_pointer_385, !noalias !2
        %__211_469_987_986_4570_15398_pointer_386 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_384, i64 0, i32 1
        %__211_469_987_986_4570_15398 = load double, ptr %__211_469_987_986_4570_15398_pointer_386, !noalias !2
        %__212_470_988_987_4571_15399_pointer_387 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_384, i64 0, i32 2
        %__212_470_988_987_4571_15399 = load double, ptr %__212_470_988_987_4571_15399_pointer_387, !noalias !2
        %__213_471_989_988_4572_15400_pointer_388 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_384, i64 0, i32 3
        %__213_471_989_988_4572_15400 = load double, ptr %__213_471_989_988_4572_15400_pointer_388, !noalias !2
        %__214_472_990_989_4573_15401_pointer_389 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_384, i64 0, i32 4
        %__214_472_990_989_4573_15401 = load double, ptr %__214_472_990_989_4573_15401_pointer_389, !noalias !2
        %__215_473_991_990_4574_15402_pointer_390 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_384, i64 0, i32 5
        %__215_473_991_990_4574_15402 = load double, ptr %__215_473_991_990_4574_15402_pointer_390, !noalias !2
        %x_216_474_992_991_4575_12110_pointer_391 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_384, i64 0, i32 6
        %x_216_474_992_991_4575_12110 = load double, ptr %x_216_474_992_991_4575_12110_pointer_391, !noalias !2
        call ccc void @eraseObject(%Object %fields_382)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_392 = extractvalue %Pos %pureApp_16541, 0
        %fields_393 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_392, label %label_394 [i64 0, label %label_444]
    
    label_446:
        %environment_373 = call ccc %Environment @objectEnvironment(%Object %fields_371)
        %__202_460_978_977_4561_15391_pointer_374 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_373, i64 0, i32 0
        %__202_460_978_977_4561_15391 = load double, ptr %__202_460_978_977_4561_15391_pointer_374, !noalias !2
        %__203_461_979_978_4562_15392_pointer_375 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_373, i64 0, i32 1
        %__203_461_979_978_4562_15392 = load double, ptr %__203_461_979_978_4562_15392_pointer_375, !noalias !2
        %__204_462_980_979_4563_15393_pointer_376 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_373, i64 0, i32 2
        %__204_462_980_979_4563_15393 = load double, ptr %__204_462_980_979_4563_15393_pointer_376, !noalias !2
        %__205_463_981_980_4564_15394_pointer_377 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_373, i64 0, i32 3
        %__205_463_981_980_4564_15394 = load double, ptr %__205_463_981_980_4564_15394_pointer_377, !noalias !2
        %x_206_464_982_981_4565_11125_pointer_378 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_373, i64 0, i32 4
        %x_206_464_982_981_4565_11125 = load double, ptr %x_206_464_982_981_4565_11125_pointer_378, !noalias !2
        %__207_465_983_982_4566_15395_pointer_379 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_373, i64 0, i32 5
        %__207_465_983_982_4566_15395 = load double, ptr %__207_465_983_982_4566_15395_pointer_379, !noalias !2
        %__208_466_984_983_4567_15396_pointer_380 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_373, i64 0, i32 6
        %__208_466_984_983_4567_15396 = load double, ptr %__208_466_984_983_4567_15396_pointer_380, !noalias !2
        call ccc void @eraseObject(%Object %fields_371)
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_381 = extractvalue %Pos %pureApp_16540, 0
        %fields_382 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_381, label %label_383 [i64 0, label %label_445]
    
    label_447:
        %environment_362 = call ccc %Environment @objectEnvironment(%Object %fields_360)
        %__194_452_970_969_4553_15385_pointer_363 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_362, i64 0, i32 0
        %__194_452_970_969_4553_15385 = load double, ptr %__194_452_970_969_4553_15385_pointer_363, !noalias !2
        %__195_453_971_970_4554_15386_pointer_364 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_362, i64 0, i32 1
        %__195_453_971_970_4554_15386 = load double, ptr %__195_453_971_970_4554_15386_pointer_364, !noalias !2
        %__196_454_972_971_4555_15387_pointer_365 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_362, i64 0, i32 2
        %__196_454_972_971_4555_15387 = load double, ptr %__196_454_972_971_4555_15387_pointer_365, !noalias !2
        %__197_455_973_972_4556_15388_pointer_366 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_362, i64 0, i32 3
        %__197_455_973_972_4556_15388 = load double, ptr %__197_455_973_972_4556_15388_pointer_366, !noalias !2
        %__198_456_974_973_4557_15389_pointer_367 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_362, i64 0, i32 4
        %__198_456_974_973_4557_15389 = load double, ptr %__198_456_974_973_4557_15389_pointer_367, !noalias !2
        %__199_457_975_974_4558_15390_pointer_368 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_362, i64 0, i32 5
        %__199_457_975_974_4558_15390 = load double, ptr %__199_457_975_974_4558_15390_pointer_368, !noalias !2
        %x_200_458_976_975_4559_11229_pointer_369 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_362, i64 0, i32 6
        %x_200_458_976_975_4559_11229 = load double, ptr %x_200_458_976_975_4559_11229_pointer_369, !noalias !2
        call ccc void @eraseObject(%Object %fields_360)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_370 = extractvalue %Pos %pureApp_16541, 0
        %fields_371 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_370, label %label_372 [i64 0, label %label_446]
    
    label_448:
        %environment_351 = call ccc %Environment @objectEnvironment(%Object %fields_349)
        %__186_444_962_961_4545_15379_pointer_352 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_351, i64 0, i32 0
        %__186_444_962_961_4545_15379 = load double, ptr %__186_444_962_961_4545_15379_pointer_352, !noalias !2
        %__187_445_963_962_4546_15380_pointer_353 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_351, i64 0, i32 1
        %__187_445_963_962_4546_15380 = load double, ptr %__187_445_963_962_4546_15380_pointer_353, !noalias !2
        %__188_446_964_963_4547_15381_pointer_354 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_351, i64 0, i32 2
        %__188_446_964_963_4547_15381 = load double, ptr %__188_446_964_963_4547_15381_pointer_354, !noalias !2
        %x_189_447_965_964_4548_11223_pointer_355 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_351, i64 0, i32 3
        %x_189_447_965_964_4548_11223 = load double, ptr %x_189_447_965_964_4548_11223_pointer_355, !noalias !2
        %__190_448_966_965_4549_15382_pointer_356 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_351, i64 0, i32 4
        %__190_448_966_965_4549_15382 = load double, ptr %__190_448_966_965_4549_15382_pointer_356, !noalias !2
        %__191_449_967_966_4550_15383_pointer_357 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_351, i64 0, i32 5
        %__191_449_967_966_4550_15383 = load double, ptr %__191_449_967_966_4550_15383_pointer_357, !noalias !2
        %__192_450_968_967_4551_15384_pointer_358 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_351, i64 0, i32 6
        %__192_450_968_967_4551_15384 = load double, ptr %__192_450_968_967_4551_15384_pointer_358, !noalias !2
        call ccc void @eraseObject(%Object %fields_349)
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_359 = extractvalue %Pos %pureApp_16540, 0
        %fields_360 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_359, label %label_361 [i64 0, label %label_447]
    
    label_449:
        %environment_340 = call ccc %Environment @objectEnvironment(%Object %fields_338)
        %__178_436_954_953_4537_15373_pointer_341 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_340, i64 0, i32 0
        %__178_436_954_953_4537_15373 = load double, ptr %__178_436_954_953_4537_15373_pointer_341, !noalias !2
        %__179_437_955_954_4538_15374_pointer_342 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_340, i64 0, i32 1
        %__179_437_955_954_4538_15374 = load double, ptr %__179_437_955_954_4538_15374_pointer_342, !noalias !2
        %x_180_438_956_955_4539_11074_pointer_343 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_340, i64 0, i32 2
        %x_180_438_956_955_4539_11074 = load double, ptr %x_180_438_956_955_4539_11074_pointer_343, !noalias !2
        %__181_439_957_956_4540_15375_pointer_344 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_340, i64 0, i32 3
        %__181_439_957_956_4540_15375 = load double, ptr %__181_439_957_956_4540_15375_pointer_344, !noalias !2
        %__182_440_958_957_4541_15376_pointer_345 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_340, i64 0, i32 4
        %__182_440_958_957_4541_15376 = load double, ptr %__182_440_958_957_4541_15376_pointer_345, !noalias !2
        %__183_441_959_958_4542_15377_pointer_346 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_340, i64 0, i32 5
        %__183_441_959_958_4542_15377 = load double, ptr %__183_441_959_958_4542_15377_pointer_346, !noalias !2
        %__184_442_960_959_4543_15378_pointer_347 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_340, i64 0, i32 6
        %__184_442_960_959_4543_15378 = load double, ptr %__184_442_960_959_4543_15378_pointer_347, !noalias !2
        call ccc void @eraseObject(%Object %fields_338)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_348 = extractvalue %Pos %pureApp_16541, 0
        %fields_349 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_348, label %label_350 [i64 0, label %label_448]
    
    label_450:
        %environment_329 = call ccc %Environment @objectEnvironment(%Object %fields_327)
        %__170_428_946_945_4529_15367_pointer_330 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_329, i64 0, i32 0
        %__170_428_946_945_4529_15367 = load double, ptr %__170_428_946_945_4529_15367_pointer_330, !noalias !2
        %x_171_429_947_946_4530_11288_pointer_331 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_329, i64 0, i32 1
        %x_171_429_947_946_4530_11288 = load double, ptr %x_171_429_947_946_4530_11288_pointer_331, !noalias !2
        %__172_430_948_947_4531_15368_pointer_332 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_329, i64 0, i32 2
        %__172_430_948_947_4531_15368 = load double, ptr %__172_430_948_947_4531_15368_pointer_332, !noalias !2
        %__173_431_949_948_4532_15369_pointer_333 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_329, i64 0, i32 3
        %__173_431_949_948_4532_15369 = load double, ptr %__173_431_949_948_4532_15369_pointer_333, !noalias !2
        %__174_432_950_949_4533_15370_pointer_334 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_329, i64 0, i32 4
        %__174_432_950_949_4533_15370 = load double, ptr %__174_432_950_949_4533_15370_pointer_334, !noalias !2
        %__175_433_951_950_4534_15371_pointer_335 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_329, i64 0, i32 5
        %__175_433_951_950_4534_15371 = load double, ptr %__175_433_951_950_4534_15371_pointer_335, !noalias !2
        %__176_434_952_951_4535_15372_pointer_336 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_329, i64 0, i32 6
        %__176_434_952_951_4535_15372 = load double, ptr %__176_434_952_951_4535_15372_pointer_336, !noalias !2
        call ccc void @eraseObject(%Object %fields_327)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_337 = extractvalue %Pos %pureApp_16541, 0
        %fields_338 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_337, label %label_339 [i64 0, label %label_449]
    
    label_451:
        %environment_318 = call ccc %Environment @objectEnvironment(%Object %fields_316)
        %x_162_420_938_937_4521_10549_pointer_319 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_318, i64 0, i32 0
        %x_162_420_938_937_4521_10549 = load double, ptr %x_162_420_938_937_4521_10549_pointer_319, !noalias !2
        %__163_421_939_938_4522_15361_pointer_320 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_318, i64 0, i32 1
        %__163_421_939_938_4522_15361 = load double, ptr %__163_421_939_938_4522_15361_pointer_320, !noalias !2
        %__164_422_940_939_4523_15362_pointer_321 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_318, i64 0, i32 2
        %__164_422_940_939_4523_15362 = load double, ptr %__164_422_940_939_4523_15362_pointer_321, !noalias !2
        %__165_423_941_940_4524_15363_pointer_322 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_318, i64 0, i32 3
        %__165_423_941_940_4524_15363 = load double, ptr %__165_423_941_940_4524_15363_pointer_322, !noalias !2
        %__166_424_942_941_4525_15364_pointer_323 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_318, i64 0, i32 4
        %__166_424_942_941_4525_15364 = load double, ptr %__166_424_942_941_4525_15364_pointer_323, !noalias !2
        %__167_425_943_942_4526_15365_pointer_324 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_318, i64 0, i32 5
        %__167_425_943_942_4526_15365 = load double, ptr %__167_425_943_942_4526_15365_pointer_324, !noalias !2
        %__168_426_944_943_4527_15366_pointer_325 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_318, i64 0, i32 6
        %__168_426_944_943_4527_15366 = load double, ptr %__168_426_944_943_4527_15366_pointer_325, !noalias !2
        call ccc void @eraseObject(%Object %fields_316)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_326 = extractvalue %Pos %pureApp_16541, 0
        %fields_327 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_326, label %label_328 [i64 0, label %label_450]
    
    label_452:
        %environment_290 = call ccc %Environment @objectEnvironment(%Object %fields_288)
        %__143_401_919_918_4502_15354_pointer_291 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_290, i64 0, i32 0
        %__143_401_919_918_4502_15354 = load double, ptr %__143_401_919_918_4502_15354_pointer_291, !noalias !2
        %__144_402_920_919_4503_15355_pointer_292 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_290, i64 0, i32 1
        %__144_402_920_919_4503_15355 = load double, ptr %__144_402_920_919_4503_15355_pointer_292, !noalias !2
        %__145_403_921_920_4504_15356_pointer_293 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_290, i64 0, i32 2
        %__145_403_921_920_4504_15356 = load double, ptr %__145_403_921_920_4504_15356_pointer_293, !noalias !2
        %__146_404_922_921_4505_15357_pointer_294 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_290, i64 0, i32 3
        %__146_404_922_921_4505_15357 = load double, ptr %__146_404_922_921_4505_15357_pointer_294, !noalias !2
        %__147_405_923_922_4506_15358_pointer_295 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_290, i64 0, i32 4
        %__147_405_923_922_4506_15358 = load double, ptr %__147_405_923_922_4506_15358_pointer_295, !noalias !2
        %__148_406_924_923_4507_15359_pointer_296 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_290, i64 0, i32 5
        %__148_406_924_923_4507_15359 = load double, ptr %__148_406_924_923_4507_15359_pointer_296, !noalias !2
        %x_149_407_925_924_4508_11283_pointer_297 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_290, i64 0, i32 6
        %x_149_407_925_924_4508_11283 = load double, ptr %x_149_407_925_924_4508_11283_pointer_297, !noalias !2
        call ccc void @eraseObject(%Object %fields_288)
        
        %pureApp_16554 = call ccc double @infixMul_114(double %pureApp_16542, double %x_109_367_885_884_4468_11486)
        
        
        
        %pureApp_16555 = call ccc double @infixMul_114(double %pureApp_16554, double %pureApp_16552)
        
        
        
        %pureApp_16556 = call ccc double @infixSub_117(double %x_98_356_874_873_4457_10609, double %pureApp_16555)
        
        
        
        %pureApp_16557 = call ccc double @infixMul_114(double %pureApp_16543, double %x_125_383_901_900_4484_11124)
        
        
        
        %pureApp_16558 = call ccc double @infixMul_114(double %pureApp_16557, double %pureApp_16552)
        
        
        
        %pureApp_16559 = call ccc double @infixSub_117(double %x_115_373_891_890_4474_11681, double %pureApp_16558)
        
        
        
        %pureApp_16560 = call ccc double @infixMul_114(double %pureApp_16544, double %x_141_399_917_916_4500_11764)
        
        
        
        %pureApp_16561 = call ccc double @infixMul_114(double %pureApp_16560, double %pureApp_16552)
        
        
        
        %pureApp_16562 = call ccc double @infixSub_117(double %x_132_390_908_907_4491_12109, double %pureApp_16561)
        
        
        
        %fields_298 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_299 = call ccc %Environment @objectEnvironment(%Object %fields_298)
        %x_71_329_847_846_4430_12617_pointer_307 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_299, i64 0, i32 0
        store double %x_71_329_847_846_4430_12617, ptr %x_71_329_847_846_4430_12617_pointer_307, !noalias !2
        %x_80_338_856_855_4439_10899_pointer_308 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_299, i64 0, i32 1
        store double %x_80_338_856_855_4439_10899, ptr %x_80_338_856_855_4439_10899_pointer_308, !noalias !2
        %x_89_347_865_864_4448_10598_pointer_309 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_299, i64 0, i32 2
        store double %x_89_347_865_864_4448_10598, ptr %x_89_347_865_864_4448_10598_pointer_309, !noalias !2
        %tmp_16366_pointer_310 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_299, i64 0, i32 3
        store double %pureApp_16556, ptr %tmp_16366_pointer_310, !noalias !2
        %tmp_16369_pointer_311 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_299, i64 0, i32 4
        store double %pureApp_16559, ptr %tmp_16369_pointer_311, !noalias !2
        %tmp_16372_pointer_312 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_299, i64 0, i32 5
        store double %pureApp_16562, ptr %tmp_16372_pointer_312, !noalias !2
        %x_149_407_925_924_4508_11283_pointer_313 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_299, i64 0, i32 6
        store double %x_149_407_925_924_4508_11283, ptr %x_149_407_925_924_4508_11283_pointer_313, !noalias !2
        %make_16563_temporary_314 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16563 = insertvalue %Pos %make_16563_temporary_314, %Object %fields_298, 1
        
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16564 = call ccc %Pos @unsafeSet_2492(%Pos %bodies_2361_12198, i64 %i_6_518_517_4101_11416, %Pos %make_16563)
        call ccc void @erasePositive(%Pos %pureApp_16564)
        
        
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_315 = extractvalue %Pos %pureApp_16541, 0
        %fields_316 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_315, label %label_317 [i64 0, label %label_451]
    
    label_453:
        %environment_279 = call ccc %Environment @objectEnvironment(%Object %fields_277)
        %__135_393_911_910_4494_15348_pointer_280 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_279, i64 0, i32 0
        %__135_393_911_910_4494_15348 = load double, ptr %__135_393_911_910_4494_15348_pointer_280, !noalias !2
        %__136_394_912_911_4495_15349_pointer_281 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_279, i64 0, i32 1
        %__136_394_912_911_4495_15349 = load double, ptr %__136_394_912_911_4495_15349_pointer_281, !noalias !2
        %__137_395_913_912_4496_15350_pointer_282 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_279, i64 0, i32 2
        %__137_395_913_912_4496_15350 = load double, ptr %__137_395_913_912_4496_15350_pointer_282, !noalias !2
        %__138_396_914_913_4497_15351_pointer_283 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_279, i64 0, i32 3
        %__138_396_914_913_4497_15351 = load double, ptr %__138_396_914_913_4497_15351_pointer_283, !noalias !2
        %__139_397_915_914_4498_15352_pointer_284 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_279, i64 0, i32 4
        %__139_397_915_914_4498_15352 = load double, ptr %__139_397_915_914_4498_15352_pointer_284, !noalias !2
        %__140_398_916_915_4499_15353_pointer_285 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_279, i64 0, i32 5
        %__140_398_916_915_4499_15353 = load double, ptr %__140_398_916_915_4499_15353_pointer_285, !noalias !2
        %x_141_399_917_916_4500_11764_pointer_286 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_279, i64 0, i32 6
        %x_141_399_917_916_4500_11764 = load double, ptr %x_141_399_917_916_4500_11764_pointer_286, !noalias !2
        call ccc void @eraseObject(%Object %fields_277)
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_287 = extractvalue %Pos %pureApp_16540, 0
        %fields_288 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_287, label %label_289 [i64 0, label %label_452]
    
    label_454:
        %environment_268 = call ccc %Environment @objectEnvironment(%Object %fields_266)
        %__127_385_903_902_4486_15342_pointer_269 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_268, i64 0, i32 0
        %__127_385_903_902_4486_15342 = load double, ptr %__127_385_903_902_4486_15342_pointer_269, !noalias !2
        %__128_386_904_903_4487_15343_pointer_270 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_268, i64 0, i32 1
        %__128_386_904_903_4487_15343 = load double, ptr %__128_386_904_903_4487_15343_pointer_270, !noalias !2
        %__129_387_905_904_4488_15344_pointer_271 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_268, i64 0, i32 2
        %__129_387_905_904_4488_15344 = load double, ptr %__129_387_905_904_4488_15344_pointer_271, !noalias !2
        %__130_388_906_905_4489_15345_pointer_272 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_268, i64 0, i32 3
        %__130_388_906_905_4489_15345 = load double, ptr %__130_388_906_905_4489_15345_pointer_272, !noalias !2
        %__131_389_907_906_4490_15346_pointer_273 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_268, i64 0, i32 4
        %__131_389_907_906_4490_15346 = load double, ptr %__131_389_907_906_4490_15346_pointer_273, !noalias !2
        %x_132_390_908_907_4491_12109_pointer_274 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_268, i64 0, i32 5
        %x_132_390_908_907_4491_12109 = load double, ptr %x_132_390_908_907_4491_12109_pointer_274, !noalias !2
        %__133_391_909_908_4492_15347_pointer_275 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_268, i64 0, i32 6
        %__133_391_909_908_4492_15347 = load double, ptr %__133_391_909_908_4492_15347_pointer_275, !noalias !2
        call ccc void @eraseObject(%Object %fields_266)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_276 = extractvalue %Pos %pureApp_16541, 0
        %fields_277 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_276, label %label_278 [i64 0, label %label_453]
    
    label_455:
        %environment_257 = call ccc %Environment @objectEnvironment(%Object %fields_255)
        %__119_377_895_894_4478_15336_pointer_258 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_257, i64 0, i32 0
        %__119_377_895_894_4478_15336 = load double, ptr %__119_377_895_894_4478_15336_pointer_258, !noalias !2
        %__120_378_896_895_4479_15337_pointer_259 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_257, i64 0, i32 1
        %__120_378_896_895_4479_15337 = load double, ptr %__120_378_896_895_4479_15337_pointer_259, !noalias !2
        %__121_379_897_896_4480_15338_pointer_260 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_257, i64 0, i32 2
        %__121_379_897_896_4480_15338 = load double, ptr %__121_379_897_896_4480_15338_pointer_260, !noalias !2
        %__122_380_898_897_4481_15339_pointer_261 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_257, i64 0, i32 3
        %__122_380_898_897_4481_15339 = load double, ptr %__122_380_898_897_4481_15339_pointer_261, !noalias !2
        %__123_381_899_898_4482_15340_pointer_262 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_257, i64 0, i32 4
        %__123_381_899_898_4482_15340 = load double, ptr %__123_381_899_898_4482_15340_pointer_262, !noalias !2
        %__124_382_900_899_4483_15341_pointer_263 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_257, i64 0, i32 5
        %__124_382_900_899_4483_15341 = load double, ptr %__124_382_900_899_4483_15341_pointer_263, !noalias !2
        %x_125_383_901_900_4484_11124_pointer_264 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_257, i64 0, i32 6
        %x_125_383_901_900_4484_11124 = load double, ptr %x_125_383_901_900_4484_11124_pointer_264, !noalias !2
        call ccc void @eraseObject(%Object %fields_255)
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_265 = extractvalue %Pos %pureApp_16540, 0
        %fields_266 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_265, label %label_267 [i64 0, label %label_454]
    
    label_456:
        %environment_246 = call ccc %Environment @objectEnvironment(%Object %fields_244)
        %__111_369_887_886_4470_15330_pointer_247 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_246, i64 0, i32 0
        %__111_369_887_886_4470_15330 = load double, ptr %__111_369_887_886_4470_15330_pointer_247, !noalias !2
        %__112_370_888_887_4471_15331_pointer_248 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_246, i64 0, i32 1
        %__112_370_888_887_4471_15331 = load double, ptr %__112_370_888_887_4471_15331_pointer_248, !noalias !2
        %__113_371_889_888_4472_15332_pointer_249 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_246, i64 0, i32 2
        %__113_371_889_888_4472_15332 = load double, ptr %__113_371_889_888_4472_15332_pointer_249, !noalias !2
        %__114_372_890_889_4473_15333_pointer_250 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_246, i64 0, i32 3
        %__114_372_890_889_4473_15333 = load double, ptr %__114_372_890_889_4473_15333_pointer_250, !noalias !2
        %x_115_373_891_890_4474_11681_pointer_251 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_246, i64 0, i32 4
        %x_115_373_891_890_4474_11681 = load double, ptr %x_115_373_891_890_4474_11681_pointer_251, !noalias !2
        %__116_374_892_891_4475_15334_pointer_252 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_246, i64 0, i32 5
        %__116_374_892_891_4475_15334 = load double, ptr %__116_374_892_891_4475_15334_pointer_252, !noalias !2
        %__117_375_893_892_4476_15335_pointer_253 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_246, i64 0, i32 6
        %__117_375_893_892_4476_15335 = load double, ptr %__117_375_893_892_4476_15335_pointer_253, !noalias !2
        call ccc void @eraseObject(%Object %fields_244)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_254 = extractvalue %Pos %pureApp_16541, 0
        %fields_255 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_254, label %label_256 [i64 0, label %label_455]
    
    label_457:
        %environment_235 = call ccc %Environment @objectEnvironment(%Object %fields_233)
        %__103_361_879_878_4462_15324_pointer_236 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_235, i64 0, i32 0
        %__103_361_879_878_4462_15324 = load double, ptr %__103_361_879_878_4462_15324_pointer_236, !noalias !2
        %__104_362_880_879_4463_15325_pointer_237 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_235, i64 0, i32 1
        %__104_362_880_879_4463_15325 = load double, ptr %__104_362_880_879_4463_15325_pointer_237, !noalias !2
        %__105_363_881_880_4464_15326_pointer_238 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_235, i64 0, i32 2
        %__105_363_881_880_4464_15326 = load double, ptr %__105_363_881_880_4464_15326_pointer_238, !noalias !2
        %__106_364_882_881_4465_15327_pointer_239 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_235, i64 0, i32 3
        %__106_364_882_881_4465_15327 = load double, ptr %__106_364_882_881_4465_15327_pointer_239, !noalias !2
        %__107_365_883_882_4466_15328_pointer_240 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_235, i64 0, i32 4
        %__107_365_883_882_4466_15328 = load double, ptr %__107_365_883_882_4466_15328_pointer_240, !noalias !2
        %__108_366_884_883_4467_15329_pointer_241 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_235, i64 0, i32 5
        %__108_366_884_883_4467_15329 = load double, ptr %__108_366_884_883_4467_15329_pointer_241, !noalias !2
        %x_109_367_885_884_4468_11486_pointer_242 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_235, i64 0, i32 6
        %x_109_367_885_884_4468_11486 = load double, ptr %x_109_367_885_884_4468_11486_pointer_242, !noalias !2
        call ccc void @eraseObject(%Object %fields_233)
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_243 = extractvalue %Pos %pureApp_16540, 0
        %fields_244 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_243, label %label_245 [i64 0, label %label_456]
    
    label_458:
        %environment_224 = call ccc %Environment @objectEnvironment(%Object %fields_222)
        %__95_353_871_870_4454_15318_pointer_225 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_224, i64 0, i32 0
        %__95_353_871_870_4454_15318 = load double, ptr %__95_353_871_870_4454_15318_pointer_225, !noalias !2
        %__96_354_872_871_4455_15319_pointer_226 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_224, i64 0, i32 1
        %__96_354_872_871_4455_15319 = load double, ptr %__96_354_872_871_4455_15319_pointer_226, !noalias !2
        %__97_355_873_872_4456_15320_pointer_227 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_224, i64 0, i32 2
        %__97_355_873_872_4456_15320 = load double, ptr %__97_355_873_872_4456_15320_pointer_227, !noalias !2
        %x_98_356_874_873_4457_10609_pointer_228 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_224, i64 0, i32 3
        %x_98_356_874_873_4457_10609 = load double, ptr %x_98_356_874_873_4457_10609_pointer_228, !noalias !2
        %__99_357_875_874_4458_15321_pointer_229 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_224, i64 0, i32 4
        %__99_357_875_874_4458_15321 = load double, ptr %__99_357_875_874_4458_15321_pointer_229, !noalias !2
        %__100_358_876_875_4459_15322_pointer_230 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_224, i64 0, i32 5
        %__100_358_876_875_4459_15322 = load double, ptr %__100_358_876_875_4459_15322_pointer_230, !noalias !2
        %__101_359_877_876_4460_15323_pointer_231 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_224, i64 0, i32 6
        %__101_359_877_876_4460_15323 = load double, ptr %__101_359_877_876_4460_15323_pointer_231, !noalias !2
        call ccc void @eraseObject(%Object %fields_222)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_232 = extractvalue %Pos %pureApp_16541, 0
        %fields_233 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_232, label %label_234 [i64 0, label %label_457]
    
    label_459:
        %environment_213 = call ccc %Environment @objectEnvironment(%Object %fields_211)
        %__87_345_863_862_4446_15312_pointer_214 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_213, i64 0, i32 0
        %__87_345_863_862_4446_15312 = load double, ptr %__87_345_863_862_4446_15312_pointer_214, !noalias !2
        %__88_346_864_863_4447_15313_pointer_215 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_213, i64 0, i32 1
        %__88_346_864_863_4447_15313 = load double, ptr %__88_346_864_863_4447_15313_pointer_215, !noalias !2
        %x_89_347_865_864_4448_10598_pointer_216 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_213, i64 0, i32 2
        %x_89_347_865_864_4448_10598 = load double, ptr %x_89_347_865_864_4448_10598_pointer_216, !noalias !2
        %__90_348_866_865_4449_15314_pointer_217 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_213, i64 0, i32 3
        %__90_348_866_865_4449_15314 = load double, ptr %__90_348_866_865_4449_15314_pointer_217, !noalias !2
        %__91_349_867_866_4450_15315_pointer_218 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_213, i64 0, i32 4
        %__91_349_867_866_4450_15315 = load double, ptr %__91_349_867_866_4450_15315_pointer_218, !noalias !2
        %__92_350_868_867_4451_15316_pointer_219 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_213, i64 0, i32 5
        %__92_350_868_867_4451_15316 = load double, ptr %__92_350_868_867_4451_15316_pointer_219, !noalias !2
        %__93_351_869_868_4452_15317_pointer_220 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_213, i64 0, i32 6
        %__93_351_869_868_4452_15317 = load double, ptr %__93_351_869_868_4452_15317_pointer_220, !noalias !2
        call ccc void @eraseObject(%Object %fields_211)
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_221 = extractvalue %Pos %pureApp_16540, 0
        %fields_222 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_221, label %label_223 [i64 0, label %label_458]
    
    label_460:
        %environment_202 = call ccc %Environment @objectEnvironment(%Object %fields_200)
        %__79_337_855_854_4438_15306_pointer_203 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_202, i64 0, i32 0
        %__79_337_855_854_4438_15306 = load double, ptr %__79_337_855_854_4438_15306_pointer_203, !noalias !2
        %x_80_338_856_855_4439_10899_pointer_204 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_202, i64 0, i32 1
        %x_80_338_856_855_4439_10899 = load double, ptr %x_80_338_856_855_4439_10899_pointer_204, !noalias !2
        %__81_339_857_856_4440_15307_pointer_205 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_202, i64 0, i32 2
        %__81_339_857_856_4440_15307 = load double, ptr %__81_339_857_856_4440_15307_pointer_205, !noalias !2
        %__82_340_858_857_4441_15308_pointer_206 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_202, i64 0, i32 3
        %__82_340_858_857_4441_15308 = load double, ptr %__82_340_858_857_4441_15308_pointer_206, !noalias !2
        %__83_341_859_858_4442_15309_pointer_207 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_202, i64 0, i32 4
        %__83_341_859_858_4442_15309 = load double, ptr %__83_341_859_858_4442_15309_pointer_207, !noalias !2
        %__84_342_860_859_4443_15310_pointer_208 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_202, i64 0, i32 5
        %__84_342_860_859_4443_15310 = load double, ptr %__84_342_860_859_4443_15310_pointer_208, !noalias !2
        %__85_343_861_860_4444_15311_pointer_209 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_202, i64 0, i32 6
        %__85_343_861_860_4444_15311 = load double, ptr %__85_343_861_860_4444_15311_pointer_209, !noalias !2
        call ccc void @eraseObject(%Object %fields_200)
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_210 = extractvalue %Pos %pureApp_16540, 0
        %fields_211 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_210, label %label_212 [i64 0, label %label_459]
    
    label_461:
        %environment_191 = call ccc %Environment @objectEnvironment(%Object %fields_189)
        %x_71_329_847_846_4430_12617_pointer_192 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_191, i64 0, i32 0
        %x_71_329_847_846_4430_12617 = load double, ptr %x_71_329_847_846_4430_12617_pointer_192, !noalias !2
        %__72_330_848_847_4431_15300_pointer_193 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_191, i64 0, i32 1
        %__72_330_848_847_4431_15300 = load double, ptr %__72_330_848_847_4431_15300_pointer_193, !noalias !2
        %__73_331_849_848_4432_15301_pointer_194 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_191, i64 0, i32 2
        %__73_331_849_848_4432_15301 = load double, ptr %__73_331_849_848_4432_15301_pointer_194, !noalias !2
        %__74_332_850_849_4433_15302_pointer_195 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_191, i64 0, i32 3
        %__74_332_850_849_4433_15302 = load double, ptr %__74_332_850_849_4433_15302_pointer_195, !noalias !2
        %__75_333_851_850_4434_15303_pointer_196 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_191, i64 0, i32 4
        %__75_333_851_850_4434_15303 = load double, ptr %__75_333_851_850_4434_15303_pointer_196, !noalias !2
        %__76_334_852_851_4435_15304_pointer_197 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_191, i64 0, i32 5
        %__76_334_852_851_4435_15304 = load double, ptr %__76_334_852_851_4435_15304_pointer_197, !noalias !2
        %__77_335_853_852_4436_15305_pointer_198 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_191, i64 0, i32 6
        %__77_335_853_852_4436_15305 = load double, ptr %__77_335_853_852_4436_15305_pointer_198, !noalias !2
        call ccc void @eraseObject(%Object %fields_189)
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_199 = extractvalue %Pos %pureApp_16540, 0
        %fields_200 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_199, label %label_201 [i64 0, label %label_460]
    
    label_462:
        %environment_180 = call ccc %Environment @objectEnvironment(%Object %fields_178)
        %__50_308_826_825_4409_15294_pointer_181 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_180, i64 0, i32 0
        %__50_308_826_825_4409_15294 = load double, ptr %__50_308_826_825_4409_15294_pointer_181, !noalias !2
        %__51_309_827_826_4410_15295_pointer_182 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_180, i64 0, i32 1
        %__51_309_827_826_4410_15295 = load double, ptr %__51_309_827_826_4410_15295_pointer_182, !noalias !2
        %x_52_310_828_827_4411_11136_pointer_183 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_180, i64 0, i32 2
        %x_52_310_828_827_4411_11136 = load double, ptr %x_52_310_828_827_4411_11136_pointer_183, !noalias !2
        %__53_311_829_828_4412_15296_pointer_184 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_180, i64 0, i32 3
        %__53_311_829_828_4412_15296 = load double, ptr %__53_311_829_828_4412_15296_pointer_184, !noalias !2
        %__54_312_830_829_4413_15297_pointer_185 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_180, i64 0, i32 4
        %__54_312_830_829_4413_15297 = load double, ptr %__54_312_830_829_4413_15297_pointer_185, !noalias !2
        %__55_313_831_830_4414_15298_pointer_186 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_180, i64 0, i32 5
        %__55_313_831_830_4414_15298 = load double, ptr %__55_313_831_830_4414_15298_pointer_186, !noalias !2
        %__56_314_832_831_4415_15299_pointer_187 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_180, i64 0, i32 6
        %__56_314_832_831_4415_15299 = load double, ptr %__56_314_832_831_4415_15299_pointer_187, !noalias !2
        call ccc void @eraseObject(%Object %fields_178)
        
        %pureApp_16544 = call ccc double @infixSub_117(double %x_44_302_820_819_4403_10935, double %x_52_310_828_827_4411_11136)
        
        
        
        %pureApp_16545 = call ccc double @infixMul_114(double %pureApp_16542, double %pureApp_16542)
        
        
        
        %pureApp_16546 = call ccc double @infixMul_114(double %pureApp_16543, double %pureApp_16543)
        
        
        
        %pureApp_16547 = call ccc double @infixAdd_111(double %pureApp_16545, double %pureApp_16546)
        
        
        
        %pureApp_16548 = call ccc double @infixMul_114(double %pureApp_16544, double %pureApp_16544)
        
        
        
        %pureApp_16549 = call ccc double @infixAdd_111(double %pureApp_16547, double %pureApp_16548)
        
        
        
        %pureApp_16550 = call ccc double @sqrt_130(double %pureApp_16549)
        
        
        
        %pureApp_16551 = call ccc double @infixMul_114(double %pureApp_16549, double %pureApp_16550)
        
        
        
        %doubleLiteral_16553 = fadd double 0.01, 0.0
        
        %pureApp_16552 = call ccc double @infixDiv_120(double %doubleLiteral_16553, double %pureApp_16551)
        
        
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_188 = extractvalue %Pos %pureApp_16540, 0
        %fields_189 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_188, label %label_190 [i64 0, label %label_461]
    
    label_463:
        %environment_169 = call ccc %Environment @objectEnvironment(%Object %fields_167)
        %__42_300_818_817_4401_15288_pointer_170 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_169, i64 0, i32 0
        %__42_300_818_817_4401_15288 = load double, ptr %__42_300_818_817_4401_15288_pointer_170, !noalias !2
        %__43_301_819_818_4402_15289_pointer_171 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_169, i64 0, i32 1
        %__43_301_819_818_4402_15289 = load double, ptr %__43_301_819_818_4402_15289_pointer_171, !noalias !2
        %x_44_302_820_819_4403_10935_pointer_172 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_169, i64 0, i32 2
        %x_44_302_820_819_4403_10935 = load double, ptr %x_44_302_820_819_4403_10935_pointer_172, !noalias !2
        %__45_303_821_820_4404_15290_pointer_173 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_169, i64 0, i32 3
        %__45_303_821_820_4404_15290 = load double, ptr %__45_303_821_820_4404_15290_pointer_173, !noalias !2
        %__46_304_822_821_4405_15291_pointer_174 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_169, i64 0, i32 4
        %__46_304_822_821_4405_15291 = load double, ptr %__46_304_822_821_4405_15291_pointer_174, !noalias !2
        %__47_305_823_822_4406_15292_pointer_175 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_169, i64 0, i32 5
        %__47_305_823_822_4406_15292 = load double, ptr %__47_305_823_822_4406_15292_pointer_175, !noalias !2
        %__48_306_824_823_4407_15293_pointer_176 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_169, i64 0, i32 6
        %__48_306_824_823_4407_15293 = load double, ptr %__48_306_824_823_4407_15293_pointer_176, !noalias !2
        call ccc void @eraseObject(%Object %fields_167)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_177 = extractvalue %Pos %pureApp_16541, 0
        %fields_178 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_177, label %label_179 [i64 0, label %label_462]
    
    label_464:
        %environment_158 = call ccc %Environment @objectEnvironment(%Object %fields_156)
        %__32_290_808_807_4391_15282_pointer_159 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_158, i64 0, i32 0
        %__32_290_808_807_4391_15282 = load double, ptr %__32_290_808_807_4391_15282_pointer_159, !noalias !2
        %x_33_291_809_808_4392_10905_pointer_160 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_158, i64 0, i32 1
        %x_33_291_809_808_4392_10905 = load double, ptr %x_33_291_809_808_4392_10905_pointer_160, !noalias !2
        %__34_292_810_809_4393_15283_pointer_161 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_158, i64 0, i32 2
        %__34_292_810_809_4393_15283 = load double, ptr %__34_292_810_809_4393_15283_pointer_161, !noalias !2
        %__35_293_811_810_4394_15284_pointer_162 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_158, i64 0, i32 3
        %__35_293_811_810_4394_15284 = load double, ptr %__35_293_811_810_4394_15284_pointer_162, !noalias !2
        %__36_294_812_811_4395_15285_pointer_163 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_158, i64 0, i32 4
        %__36_294_812_811_4395_15285 = load double, ptr %__36_294_812_811_4395_15285_pointer_163, !noalias !2
        %__37_295_813_812_4396_15286_pointer_164 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_158, i64 0, i32 5
        %__37_295_813_812_4396_15286 = load double, ptr %__37_295_813_812_4396_15286_pointer_164, !noalias !2
        %__38_296_814_813_4397_15287_pointer_165 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_158, i64 0, i32 6
        %__38_296_814_813_4397_15287 = load double, ptr %__38_296_814_813_4397_15287_pointer_165, !noalias !2
        call ccc void @eraseObject(%Object %fields_156)
        
        %pureApp_16543 = call ccc double @infixSub_117(double %x_25_283_801_800_4384_11644, double %x_33_291_809_808_4392_10905)
        
        
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_166 = extractvalue %Pos %pureApp_16540, 0
        %fields_167 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_166, label %label_168 [i64 0, label %label_463]
    
    label_465:
        %environment_147 = call ccc %Environment @objectEnvironment(%Object %fields_145)
        %__24_282_800_799_4383_15276_pointer_148 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_147, i64 0, i32 0
        %__24_282_800_799_4383_15276 = load double, ptr %__24_282_800_799_4383_15276_pointer_148, !noalias !2
        %x_25_283_801_800_4384_11644_pointer_149 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_147, i64 0, i32 1
        %x_25_283_801_800_4384_11644 = load double, ptr %x_25_283_801_800_4384_11644_pointer_149, !noalias !2
        %__26_284_802_801_4385_15277_pointer_150 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_147, i64 0, i32 2
        %__26_284_802_801_4385_15277 = load double, ptr %__26_284_802_801_4385_15277_pointer_150, !noalias !2
        %__27_285_803_802_4386_15278_pointer_151 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_147, i64 0, i32 3
        %__27_285_803_802_4386_15278 = load double, ptr %__27_285_803_802_4386_15278_pointer_151, !noalias !2
        %__28_286_804_803_4387_15279_pointer_152 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_147, i64 0, i32 4
        %__28_286_804_803_4387_15279 = load double, ptr %__28_286_804_803_4387_15279_pointer_152, !noalias !2
        %__29_287_805_804_4388_15280_pointer_153 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_147, i64 0, i32 5
        %__29_287_805_804_4388_15280 = load double, ptr %__29_287_805_804_4388_15280_pointer_153, !noalias !2
        %__30_288_806_805_4389_15281_pointer_154 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_147, i64 0, i32 6
        %__30_288_806_805_4389_15281 = load double, ptr %__30_288_806_805_4389_15281_pointer_154, !noalias !2
        call ccc void @eraseObject(%Object %fields_145)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_155 = extractvalue %Pos %pureApp_16541, 0
        %fields_156 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_155, label %label_157 [i64 0, label %label_464]
    
    label_466:
        %environment_136 = call ccc %Environment @objectEnvironment(%Object %fields_134)
        %x_14_272_790_789_4373_10565_pointer_137 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_136, i64 0, i32 0
        %x_14_272_790_789_4373_10565 = load double, ptr %x_14_272_790_789_4373_10565_pointer_137, !noalias !2
        %__15_273_791_790_4374_15270_pointer_138 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_136, i64 0, i32 1
        %__15_273_791_790_4374_15270 = load double, ptr %__15_273_791_790_4374_15270_pointer_138, !noalias !2
        %__16_274_792_791_4375_15271_pointer_139 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_136, i64 0, i32 2
        %__16_274_792_791_4375_15271 = load double, ptr %__16_274_792_791_4375_15271_pointer_139, !noalias !2
        %__17_275_793_792_4376_15272_pointer_140 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_136, i64 0, i32 3
        %__17_275_793_792_4376_15272 = load double, ptr %__17_275_793_792_4376_15272_pointer_140, !noalias !2
        %__18_276_794_793_4377_15273_pointer_141 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_136, i64 0, i32 4
        %__18_276_794_793_4377_15273 = load double, ptr %__18_276_794_793_4377_15273_pointer_141, !noalias !2
        %__19_277_795_794_4378_15274_pointer_142 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_136, i64 0, i32 5
        %__19_277_795_794_4378_15274 = load double, ptr %__19_277_795_794_4378_15274_pointer_142, !noalias !2
        %__20_278_796_795_4379_15275_pointer_143 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_136, i64 0, i32 6
        %__20_278_796_795_4379_15275 = load double, ptr %__20_278_796_795_4379_15275_pointer_143, !noalias !2
        call ccc void @eraseObject(%Object %fields_134)
        
        %pureApp_16542 = call ccc double @infixSub_117(double %x_6_264_782_781_4365_11604, double %x_14_272_790_789_4373_10565)
        
        
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_144 = extractvalue %Pos %pureApp_16540, 0
        %fields_145 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_144, label %label_146 [i64 0, label %label_465]
    
    label_467:
        %environment_125 = call ccc %Environment @objectEnvironment(%Object %fields_123)
        %x_6_264_782_781_4365_11604_pointer_126 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_125, i64 0, i32 0
        %x_6_264_782_781_4365_11604 = load double, ptr %x_6_264_782_781_4365_11604_pointer_126, !noalias !2
        %__7_265_783_782_4366_15264_pointer_127 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_125, i64 0, i32 1
        %__7_265_783_782_4366_15264 = load double, ptr %__7_265_783_782_4366_15264_pointer_127, !noalias !2
        %__8_266_784_783_4367_15265_pointer_128 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_125, i64 0, i32 2
        %__8_266_784_783_4367_15265 = load double, ptr %__8_266_784_783_4367_15265_pointer_128, !noalias !2
        %__9_267_785_784_4368_15266_pointer_129 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_125, i64 0, i32 3
        %__9_267_785_784_4368_15266 = load double, ptr %__9_267_785_784_4368_15266_pointer_129, !noalias !2
        %__10_268_786_785_4369_15267_pointer_130 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_125, i64 0, i32 4
        %__10_268_786_785_4369_15267 = load double, ptr %__10_268_786_785_4369_15267_pointer_130, !noalias !2
        %__11_269_787_786_4370_15268_pointer_131 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_125, i64 0, i32 5
        %__11_269_787_786_4370_15268 = load double, ptr %__11_269_787_786_4370_15268_pointer_131, !noalias !2
        %__12_270_788_787_4371_15269_pointer_132 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_125, i64 0, i32 6
        %__12_270_788_787_4371_15269 = load double, ptr %__12_270_788_787_4371_15269_pointer_132, !noalias !2
        call ccc void @eraseObject(%Object %fields_123)
        
        call ccc void @sharePositive(%Pos %pureApp_16541)
        %tag_133 = extractvalue %Pos %pureApp_16541, 0
        %fields_134 = extractvalue %Pos %pureApp_16541, 1
        switch i64 %tag_133, label %label_135 [i64 0, label %label_466]
    
    label_468:
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16540 = call ccc %Pos @unsafeGet_2487(%Pos %bodies_2361_12198, i64 %i_6_518_517_4101_11416)
        
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16541 = call ccc %Pos @unsafeGet_2487(%Pos %bodies_2361_12198, i64 %i_6_258_776_775_4359_12272)
        
        
        
        call ccc void @sharePositive(%Pos %pureApp_16540)
        %tag_122 = extractvalue %Pos %pureApp_16540, 0
        %fields_123 = extractvalue %Pos %pureApp_16540, 1
        switch i64 %tag_122, label %label_124 [i64 0, label %label_467]
}



define tailcc void @returnAddress_469(%Pos %__8_1031_1030_4614_15422, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_470 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_6_518_517_4101_11416_pointer_471 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_470, i64 0, i32 0
        %i_6_518_517_4101_11416 = load i64, ptr %i_6_518_517_4101_11416_pointer_471, !noalias !2
        %tmp_16346_pointer_472 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_470, i64 0, i32 1
        %tmp_16346 = load i64, ptr %tmp_16346_pointer_472, !noalias !2
        %bodies_2361_12198_pointer_473 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_470, i64 0, i32 2
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_473, !noalias !2
        call ccc void @erasePositive(%Pos %__8_1031_1030_4614_15422)
        
        %longLiteral_16579 = add i64 1, 0
        
        %pureApp_16578 = call ccc i64 @infixAdd_96(i64 %i_6_518_517_4101_11416, i64 %longLiteral_16579)
        
        
        
        
        
        musttail call tailcc void @loop_5_517_516_4100_11441(i64 %pureApp_16578, i64 %tmp_16346, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
}



define ccc void @sharer_477(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_478 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %i_6_518_517_4101_11416_474_pointer_479 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_478, i64 0, i32 0
        %i_6_518_517_4101_11416_474 = load i64, ptr %i_6_518_517_4101_11416_474_pointer_479, !noalias !2
        %tmp_16346_475_pointer_480 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_478, i64 0, i32 1
        %tmp_16346_475 = load i64, ptr %tmp_16346_475_pointer_480, !noalias !2
        %bodies_2361_12198_476_pointer_481 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_478, i64 0, i32 2
        %bodies_2361_12198_476 = load %Pos, ptr %bodies_2361_12198_476_pointer_481, !noalias !2
        call ccc void @sharePositive(%Pos %bodies_2361_12198_476)
        call ccc void @shareFrames(%StackPointer %stackPointer_478)
        ret void
}



define ccc void @eraser_485(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_486 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %i_6_518_517_4101_11416_482_pointer_487 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_486, i64 0, i32 0
        %i_6_518_517_4101_11416_482 = load i64, ptr %i_6_518_517_4101_11416_482_pointer_487, !noalias !2
        %tmp_16346_483_pointer_488 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_486, i64 0, i32 1
        %tmp_16346_483 = load i64, ptr %tmp_16346_483_pointer_488, !noalias !2
        %bodies_2361_12198_484_pointer_489 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_486, i64 0, i32 2
        %bodies_2361_12198_484 = load %Pos, ptr %bodies_2361_12198_484_pointer_489, !noalias !2
        call ccc void @erasePositive(%Pos %bodies_2361_12198_484)
        call ccc void @eraseFrames(%StackPointer %stackPointer_486)
        ret void
}



define tailcc void @loop_5_517_516_4100_11441(i64 %i_6_518_517_4101_11416, i64 %tmp_16346, %Pos %bodies_2361_12198, %Stack %stack) {
        
    entry:
        
        
        %pureApp_16533 = call ccc %Pos @infixLt_178(i64 %i_6_518_517_4101_11416, i64 %tmp_16346)
        
        
        
        %tag_106 = extractvalue %Pos %pureApp_16533, 0
        %fields_107 = extractvalue %Pos %pureApp_16533, 1
        switch i64 %tag_106, label %label_108 [i64 0, label %label_113 i64 1, label %label_497]
    
    label_108:
        
        ret void
    
    label_113:
        call ccc void @erasePositive(%Pos %bodies_2361_12198)
        
        %unitLiteral_16534_temporary_109 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_16534 = insertvalue %Pos %unitLiteral_16534_temporary_109, %Object null, 1
        
        %stackPointer_111 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_112 = getelementptr %FrameHeader, %StackPointer %stackPointer_111, i64 0, i32 0
        %returnAddress_110 = load %ReturnAddress, ptr %returnAddress_pointer_112, !noalias !2
        musttail call tailcc void %returnAddress_110(%Pos %unitLiteral_16534, %Stack %stack)
        ret void
    
    label_497:
        
        %longLiteral_16536 = add i64 1, 0
        
        %pureApp_16535 = call ccc i64 @infixAdd_96(i64 %i_6_518_517_4101_11416, i64 %longLiteral_16536)
        
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16537 = call ccc i64 @size_2483(%Pos %bodies_2361_12198)
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %stackPointer_490 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_6_518_517_4101_11416_pointer_491 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_490, i64 0, i32 0
        store i64 %i_6_518_517_4101_11416, ptr %i_6_518_517_4101_11416_pointer_491, !noalias !2
        %tmp_16346_pointer_492 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_490, i64 0, i32 1
        store i64 %tmp_16346, ptr %tmp_16346_pointer_492, !noalias !2
        %bodies_2361_12198_pointer_493 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_490, i64 0, i32 2
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_493, !noalias !2
        %returnAddress_pointer_494 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_490, i64 0, i32 1, i32 0
        %sharer_pointer_495 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_490, i64 0, i32 1, i32 1
        %eraser_pointer_496 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_490, i64 0, i32 1, i32 2
        store ptr @returnAddress_469, ptr %returnAddress_pointer_494, !noalias !2
        store ptr @sharer_477, ptr %sharer_pointer_495, !noalias !2
        store ptr @eraser_485, ptr %eraser_pointer_496, !noalias !2
        
        
        
        musttail call tailcc void @loop_5_257_775_774_4358_12496(i64 %pureApp_16535, i64 %i_6_518_517_4101_11416, i64 %pureApp_16537, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
}



define tailcc void @loop_5_1127_1126_4710_11085(i64 %i_6_1128_1127_4711_10526, i64 %tmp_16388, %Pos %bodies_2361_12198, %Stack %stack) {
        
    entry:
        
        
        %pureApp_16581 = call ccc %Pos @infixLt_178(i64 %i_6_1128_1127_4711_10526, i64 %tmp_16388)
        
        
        
        %tag_503 = extractvalue %Pos %pureApp_16581, 0
        %fields_504 = extractvalue %Pos %pureApp_16581, 1
        switch i64 %tag_503, label %label_505 [i64 0, label %label_510 i64 1, label %label_648]
    
    label_505:
        
        ret void
    
    label_510:
        call ccc void @erasePositive(%Pos %bodies_2361_12198)
        
        %unitLiteral_16582_temporary_506 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_16582 = insertvalue %Pos %unitLiteral_16582_temporary_506, %Object null, 1
        
        %stackPointer_508 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_509 = getelementptr %FrameHeader, %StackPointer %stackPointer_508, i64 0, i32 0
        %returnAddress_507 = load %ReturnAddress, ptr %returnAddress_pointer_509, !noalias !2
        musttail call tailcc void %returnAddress_507(%Pos %unitLiteral_16582, %Stack %stack)
        ret void
    
    label_513:
        
        ret void
    
    label_524:
        
        ret void
    
    label_535:
        
        ret void
    
    label_546:
        
        ret void
    
    label_557:
        
        ret void
    
    label_568:
        
        ret void
    
    label_579:
        
        ret void
    
    label_590:
        
        ret void
    
    label_601:
        
        ret void
    
    label_612:
        
        ret void
    
    label_638:
        %environment_613 = call ccc %Environment @objectEnvironment(%Object %fields_611)
        %__76_1204_1203_4787_15538_pointer_614 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_613, i64 0, i32 0
        %__76_1204_1203_4787_15538 = load double, ptr %__76_1204_1203_4787_15538_pointer_614, !noalias !2
        %__77_1205_1204_4788_15539_pointer_615 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_613, i64 0, i32 1
        %__77_1205_1204_4788_15539 = load double, ptr %__77_1205_1204_4788_15539_pointer_615, !noalias !2
        %__78_1206_1205_4789_15540_pointer_616 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_613, i64 0, i32 2
        %__78_1206_1205_4789_15540 = load double, ptr %__78_1206_1205_4789_15540_pointer_616, !noalias !2
        %__79_1207_1206_4790_15541_pointer_617 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_613, i64 0, i32 3
        %__79_1207_1206_4790_15541 = load double, ptr %__79_1207_1206_4790_15541_pointer_617, !noalias !2
        %__80_1208_1207_4791_15542_pointer_618 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_613, i64 0, i32 4
        %__80_1208_1207_4791_15542 = load double, ptr %__80_1208_1207_4791_15542_pointer_618, !noalias !2
        %__81_1209_1208_4792_15543_pointer_619 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_613, i64 0, i32 5
        %__81_1209_1208_4792_15543 = load double, ptr %__81_1209_1208_4792_15543_pointer_619, !noalias !2
        %x_82_1210_1209_4793_11317_pointer_620 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_613, i64 0, i32 6
        %x_82_1210_1209_4793_11317 = load double, ptr %x_82_1210_1209_4793_11317_pointer_620, !noalias !2
        call ccc void @eraseObject(%Object %fields_611)
        
        %doubleLiteral_16585 = fadd double 0.01, 0.0
        
        %pureApp_16584 = call ccc double @infixMul_114(double %doubleLiteral_16585, double %x_15_1143_1142_4726_11722)
        
        
        
        %pureApp_16586 = call ccc double @infixAdd_111(double %x_4_1132_1131_4715_11121, double %pureApp_16584)
        
        
        
        %doubleLiteral_16588 = fadd double 0.01, 0.0
        
        %pureApp_16587 = call ccc double @infixMul_114(double %doubleLiteral_16588, double %x_32_1160_1159_4743_11666)
        
        
        
        %pureApp_16589 = call ccc double @infixAdd_111(double %x_21_1149_1148_4732_11452, double %pureApp_16587)
        
        
        
        %doubleLiteral_16591 = fadd double 0.01, 0.0
        
        %pureApp_16590 = call ccc double @infixMul_114(double %doubleLiteral_16591, double %x_49_1177_1176_4760_12632)
        
        
        
        %pureApp_16592 = call ccc double @infixAdd_111(double %x_38_1166_1165_4749_11418, double %pureApp_16590)
        
        
        
        %fields_621 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_622 = call ccc %Environment @objectEnvironment(%Object %fields_621)
        %tmp_16392_pointer_630 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_622, i64 0, i32 0
        store double %pureApp_16586, ptr %tmp_16392_pointer_630, !noalias !2
        %tmp_16394_pointer_631 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_622, i64 0, i32 1
        store double %pureApp_16589, ptr %tmp_16394_pointer_631, !noalias !2
        %tmp_16396_pointer_632 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_622, i64 0, i32 2
        store double %pureApp_16592, ptr %tmp_16396_pointer_632, !noalias !2
        %x_55_1183_1182_4766_12425_pointer_633 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_622, i64 0, i32 3
        store double %x_55_1183_1182_4766_12425, ptr %x_55_1183_1182_4766_12425_pointer_633, !noalias !2
        %x_64_1192_1191_4775_12652_pointer_634 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_622, i64 0, i32 4
        store double %x_64_1192_1191_4775_12652, ptr %x_64_1192_1191_4775_12652_pointer_634, !noalias !2
        %x_73_1201_1200_4784_10816_pointer_635 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_622, i64 0, i32 5
        store double %x_73_1201_1200_4784_10816, ptr %x_73_1201_1200_4784_10816_pointer_635, !noalias !2
        %x_82_1210_1209_4793_11317_pointer_636 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_622, i64 0, i32 6
        store double %x_82_1210_1209_4793_11317, ptr %x_82_1210_1209_4793_11317_pointer_636, !noalias !2
        %make_16593_temporary_637 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16593 = insertvalue %Pos %make_16593_temporary_637, %Object %fields_621, 1
        
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16594 = call ccc %Pos @unsafeSet_2492(%Pos %bodies_2361_12198, i64 %i_6_1128_1127_4711_10526, %Pos %make_16593)
        call ccc void @erasePositive(%Pos %pureApp_16594)
        
        
        
        %longLiteral_16596 = add i64 1, 0
        
        %pureApp_16595 = call ccc i64 @infixAdd_96(i64 %i_6_1128_1127_4711_10526, i64 %longLiteral_16596)
        
        
        
        
        
        musttail call tailcc void @loop_5_1127_1126_4710_11085(i64 %pureApp_16595, i64 %tmp_16388, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
    
    label_639:
        %environment_602 = call ccc %Environment @objectEnvironment(%Object %fields_600)
        %__68_1196_1195_4779_15532_pointer_603 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_602, i64 0, i32 0
        %__68_1196_1195_4779_15532 = load double, ptr %__68_1196_1195_4779_15532_pointer_603, !noalias !2
        %__69_1197_1196_4780_15533_pointer_604 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_602, i64 0, i32 1
        %__69_1197_1196_4780_15533 = load double, ptr %__69_1197_1196_4780_15533_pointer_604, !noalias !2
        %__70_1198_1197_4781_15534_pointer_605 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_602, i64 0, i32 2
        %__70_1198_1197_4781_15534 = load double, ptr %__70_1198_1197_4781_15534_pointer_605, !noalias !2
        %__71_1199_1198_4782_15535_pointer_606 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_602, i64 0, i32 3
        %__71_1199_1198_4782_15535 = load double, ptr %__71_1199_1198_4782_15535_pointer_606, !noalias !2
        %__72_1200_1199_4783_15536_pointer_607 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_602, i64 0, i32 4
        %__72_1200_1199_4783_15536 = load double, ptr %__72_1200_1199_4783_15536_pointer_607, !noalias !2
        %x_73_1201_1200_4784_10816_pointer_608 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_602, i64 0, i32 5
        %x_73_1201_1200_4784_10816 = load double, ptr %x_73_1201_1200_4784_10816_pointer_608, !noalias !2
        %__74_1202_1201_4785_15537_pointer_609 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_602, i64 0, i32 6
        %__74_1202_1201_4785_15537 = load double, ptr %__74_1202_1201_4785_15537_pointer_609, !noalias !2
        call ccc void @eraseObject(%Object %fields_600)
        
        %tag_610 = extractvalue %Pos %pureApp_16583, 0
        %fields_611 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_610, label %label_612 [i64 0, label %label_638]
    
    label_640:
        %environment_591 = call ccc %Environment @objectEnvironment(%Object %fields_589)
        %__60_1188_1187_4771_15526_pointer_592 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_591, i64 0, i32 0
        %__60_1188_1187_4771_15526 = load double, ptr %__60_1188_1187_4771_15526_pointer_592, !noalias !2
        %__61_1189_1188_4772_15527_pointer_593 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_591, i64 0, i32 1
        %__61_1189_1188_4772_15527 = load double, ptr %__61_1189_1188_4772_15527_pointer_593, !noalias !2
        %__62_1190_1189_4773_15528_pointer_594 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_591, i64 0, i32 2
        %__62_1190_1189_4773_15528 = load double, ptr %__62_1190_1189_4773_15528_pointer_594, !noalias !2
        %__63_1191_1190_4774_15529_pointer_595 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_591, i64 0, i32 3
        %__63_1191_1190_4774_15529 = load double, ptr %__63_1191_1190_4774_15529_pointer_595, !noalias !2
        %x_64_1192_1191_4775_12652_pointer_596 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_591, i64 0, i32 4
        %x_64_1192_1191_4775_12652 = load double, ptr %x_64_1192_1191_4775_12652_pointer_596, !noalias !2
        %__65_1193_1192_4776_15530_pointer_597 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_591, i64 0, i32 5
        %__65_1193_1192_4776_15530 = load double, ptr %__65_1193_1192_4776_15530_pointer_597, !noalias !2
        %__66_1194_1193_4777_15531_pointer_598 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_591, i64 0, i32 6
        %__66_1194_1193_4777_15531 = load double, ptr %__66_1194_1193_4777_15531_pointer_598, !noalias !2
        call ccc void @eraseObject(%Object %fields_589)
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_599 = extractvalue %Pos %pureApp_16583, 0
        %fields_600 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_599, label %label_601 [i64 0, label %label_639]
    
    label_641:
        %environment_580 = call ccc %Environment @objectEnvironment(%Object %fields_578)
        %__52_1180_1179_4763_15520_pointer_581 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_580, i64 0, i32 0
        %__52_1180_1179_4763_15520 = load double, ptr %__52_1180_1179_4763_15520_pointer_581, !noalias !2
        %__53_1181_1180_4764_15521_pointer_582 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_580, i64 0, i32 1
        %__53_1181_1180_4764_15521 = load double, ptr %__53_1181_1180_4764_15521_pointer_582, !noalias !2
        %__54_1182_1181_4765_15522_pointer_583 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_580, i64 0, i32 2
        %__54_1182_1181_4765_15522 = load double, ptr %__54_1182_1181_4765_15522_pointer_583, !noalias !2
        %x_55_1183_1182_4766_12425_pointer_584 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_580, i64 0, i32 3
        %x_55_1183_1182_4766_12425 = load double, ptr %x_55_1183_1182_4766_12425_pointer_584, !noalias !2
        %__56_1184_1183_4767_15523_pointer_585 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_580, i64 0, i32 4
        %__56_1184_1183_4767_15523 = load double, ptr %__56_1184_1183_4767_15523_pointer_585, !noalias !2
        %__57_1185_1184_4768_15524_pointer_586 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_580, i64 0, i32 5
        %__57_1185_1184_4768_15524 = load double, ptr %__57_1185_1184_4768_15524_pointer_586, !noalias !2
        %__58_1186_1185_4769_15525_pointer_587 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_580, i64 0, i32 6
        %__58_1186_1185_4769_15525 = load double, ptr %__58_1186_1185_4769_15525_pointer_587, !noalias !2
        call ccc void @eraseObject(%Object %fields_578)
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_588 = extractvalue %Pos %pureApp_16583, 0
        %fields_589 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_588, label %label_590 [i64 0, label %label_640]
    
    label_642:
        %environment_569 = call ccc %Environment @objectEnvironment(%Object %fields_567)
        %__44_1172_1171_4755_15514_pointer_570 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_569, i64 0, i32 0
        %__44_1172_1171_4755_15514 = load double, ptr %__44_1172_1171_4755_15514_pointer_570, !noalias !2
        %__45_1173_1172_4756_15515_pointer_571 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_569, i64 0, i32 1
        %__45_1173_1172_4756_15515 = load double, ptr %__45_1173_1172_4756_15515_pointer_571, !noalias !2
        %__46_1174_1173_4757_15516_pointer_572 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_569, i64 0, i32 2
        %__46_1174_1173_4757_15516 = load double, ptr %__46_1174_1173_4757_15516_pointer_572, !noalias !2
        %__47_1175_1174_4758_15517_pointer_573 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_569, i64 0, i32 3
        %__47_1175_1174_4758_15517 = load double, ptr %__47_1175_1174_4758_15517_pointer_573, !noalias !2
        %__48_1176_1175_4759_15518_pointer_574 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_569, i64 0, i32 4
        %__48_1176_1175_4759_15518 = load double, ptr %__48_1176_1175_4759_15518_pointer_574, !noalias !2
        %x_49_1177_1176_4760_12632_pointer_575 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_569, i64 0, i32 5
        %x_49_1177_1176_4760_12632 = load double, ptr %x_49_1177_1176_4760_12632_pointer_575, !noalias !2
        %__50_1178_1177_4761_15519_pointer_576 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_569, i64 0, i32 6
        %__50_1178_1177_4761_15519 = load double, ptr %__50_1178_1177_4761_15519_pointer_576, !noalias !2
        call ccc void @eraseObject(%Object %fields_567)
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_577 = extractvalue %Pos %pureApp_16583, 0
        %fields_578 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_577, label %label_579 [i64 0, label %label_641]
    
    label_643:
        %environment_558 = call ccc %Environment @objectEnvironment(%Object %fields_556)
        %__36_1164_1163_4747_15508_pointer_559 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_558, i64 0, i32 0
        %__36_1164_1163_4747_15508 = load double, ptr %__36_1164_1163_4747_15508_pointer_559, !noalias !2
        %__37_1165_1164_4748_15509_pointer_560 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_558, i64 0, i32 1
        %__37_1165_1164_4748_15509 = load double, ptr %__37_1165_1164_4748_15509_pointer_560, !noalias !2
        %x_38_1166_1165_4749_11418_pointer_561 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_558, i64 0, i32 2
        %x_38_1166_1165_4749_11418 = load double, ptr %x_38_1166_1165_4749_11418_pointer_561, !noalias !2
        %__39_1167_1166_4750_15510_pointer_562 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_558, i64 0, i32 3
        %__39_1167_1166_4750_15510 = load double, ptr %__39_1167_1166_4750_15510_pointer_562, !noalias !2
        %__40_1168_1167_4751_15511_pointer_563 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_558, i64 0, i32 4
        %__40_1168_1167_4751_15511 = load double, ptr %__40_1168_1167_4751_15511_pointer_563, !noalias !2
        %__41_1169_1168_4752_15512_pointer_564 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_558, i64 0, i32 5
        %__41_1169_1168_4752_15512 = load double, ptr %__41_1169_1168_4752_15512_pointer_564, !noalias !2
        %__42_1170_1169_4753_15513_pointer_565 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_558, i64 0, i32 6
        %__42_1170_1169_4753_15513 = load double, ptr %__42_1170_1169_4753_15513_pointer_565, !noalias !2
        call ccc void @eraseObject(%Object %fields_556)
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_566 = extractvalue %Pos %pureApp_16583, 0
        %fields_567 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_566, label %label_568 [i64 0, label %label_642]
    
    label_644:
        %environment_547 = call ccc %Environment @objectEnvironment(%Object %fields_545)
        %__28_1156_1155_4739_15502_pointer_548 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_547, i64 0, i32 0
        %__28_1156_1155_4739_15502 = load double, ptr %__28_1156_1155_4739_15502_pointer_548, !noalias !2
        %__29_1157_1156_4740_15503_pointer_549 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_547, i64 0, i32 1
        %__29_1157_1156_4740_15503 = load double, ptr %__29_1157_1156_4740_15503_pointer_549, !noalias !2
        %__30_1158_1157_4741_15504_pointer_550 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_547, i64 0, i32 2
        %__30_1158_1157_4741_15504 = load double, ptr %__30_1158_1157_4741_15504_pointer_550, !noalias !2
        %__31_1159_1158_4742_15505_pointer_551 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_547, i64 0, i32 3
        %__31_1159_1158_4742_15505 = load double, ptr %__31_1159_1158_4742_15505_pointer_551, !noalias !2
        %x_32_1160_1159_4743_11666_pointer_552 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_547, i64 0, i32 4
        %x_32_1160_1159_4743_11666 = load double, ptr %x_32_1160_1159_4743_11666_pointer_552, !noalias !2
        %__33_1161_1160_4744_15506_pointer_553 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_547, i64 0, i32 5
        %__33_1161_1160_4744_15506 = load double, ptr %__33_1161_1160_4744_15506_pointer_553, !noalias !2
        %__34_1162_1161_4745_15507_pointer_554 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_547, i64 0, i32 6
        %__34_1162_1161_4745_15507 = load double, ptr %__34_1162_1161_4745_15507_pointer_554, !noalias !2
        call ccc void @eraseObject(%Object %fields_545)
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_555 = extractvalue %Pos %pureApp_16583, 0
        %fields_556 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_555, label %label_557 [i64 0, label %label_643]
    
    label_645:
        %environment_536 = call ccc %Environment @objectEnvironment(%Object %fields_534)
        %__20_1148_1147_4731_15496_pointer_537 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_536, i64 0, i32 0
        %__20_1148_1147_4731_15496 = load double, ptr %__20_1148_1147_4731_15496_pointer_537, !noalias !2
        %x_21_1149_1148_4732_11452_pointer_538 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_536, i64 0, i32 1
        %x_21_1149_1148_4732_11452 = load double, ptr %x_21_1149_1148_4732_11452_pointer_538, !noalias !2
        %__22_1150_1149_4733_15497_pointer_539 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_536, i64 0, i32 2
        %__22_1150_1149_4733_15497 = load double, ptr %__22_1150_1149_4733_15497_pointer_539, !noalias !2
        %__23_1151_1150_4734_15498_pointer_540 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_536, i64 0, i32 3
        %__23_1151_1150_4734_15498 = load double, ptr %__23_1151_1150_4734_15498_pointer_540, !noalias !2
        %__24_1152_1151_4735_15499_pointer_541 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_536, i64 0, i32 4
        %__24_1152_1151_4735_15499 = load double, ptr %__24_1152_1151_4735_15499_pointer_541, !noalias !2
        %__25_1153_1152_4736_15500_pointer_542 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_536, i64 0, i32 5
        %__25_1153_1152_4736_15500 = load double, ptr %__25_1153_1152_4736_15500_pointer_542, !noalias !2
        %__26_1154_1153_4737_15501_pointer_543 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_536, i64 0, i32 6
        %__26_1154_1153_4737_15501 = load double, ptr %__26_1154_1153_4737_15501_pointer_543, !noalias !2
        call ccc void @eraseObject(%Object %fields_534)
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_544 = extractvalue %Pos %pureApp_16583, 0
        %fields_545 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_544, label %label_546 [i64 0, label %label_644]
    
    label_646:
        %environment_525 = call ccc %Environment @objectEnvironment(%Object %fields_523)
        %__12_1140_1139_4723_15490_pointer_526 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_525, i64 0, i32 0
        %__12_1140_1139_4723_15490 = load double, ptr %__12_1140_1139_4723_15490_pointer_526, !noalias !2
        %__13_1141_1140_4724_15491_pointer_527 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_525, i64 0, i32 1
        %__13_1141_1140_4724_15491 = load double, ptr %__13_1141_1140_4724_15491_pointer_527, !noalias !2
        %__14_1142_1141_4725_15492_pointer_528 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_525, i64 0, i32 2
        %__14_1142_1141_4725_15492 = load double, ptr %__14_1142_1141_4725_15492_pointer_528, !noalias !2
        %x_15_1143_1142_4726_11722_pointer_529 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_525, i64 0, i32 3
        %x_15_1143_1142_4726_11722 = load double, ptr %x_15_1143_1142_4726_11722_pointer_529, !noalias !2
        %__16_1144_1143_4727_15493_pointer_530 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_525, i64 0, i32 4
        %__16_1144_1143_4727_15493 = load double, ptr %__16_1144_1143_4727_15493_pointer_530, !noalias !2
        %__17_1145_1144_4728_15494_pointer_531 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_525, i64 0, i32 5
        %__17_1145_1144_4728_15494 = load double, ptr %__17_1145_1144_4728_15494_pointer_531, !noalias !2
        %__18_1146_1145_4729_15495_pointer_532 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_525, i64 0, i32 6
        %__18_1146_1145_4729_15495 = load double, ptr %__18_1146_1145_4729_15495_pointer_532, !noalias !2
        call ccc void @eraseObject(%Object %fields_523)
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_533 = extractvalue %Pos %pureApp_16583, 0
        %fields_534 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_533, label %label_535 [i64 0, label %label_645]
    
    label_647:
        %environment_514 = call ccc %Environment @objectEnvironment(%Object %fields_512)
        %x_4_1132_1131_4715_11121_pointer_515 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_514, i64 0, i32 0
        %x_4_1132_1131_4715_11121 = load double, ptr %x_4_1132_1131_4715_11121_pointer_515, !noalias !2
        %__5_1133_1132_4716_15484_pointer_516 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_514, i64 0, i32 1
        %__5_1133_1132_4716_15484 = load double, ptr %__5_1133_1132_4716_15484_pointer_516, !noalias !2
        %__6_1134_1133_4717_15485_pointer_517 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_514, i64 0, i32 2
        %__6_1134_1133_4717_15485 = load double, ptr %__6_1134_1133_4717_15485_pointer_517, !noalias !2
        %__7_1135_1134_4718_15486_pointer_518 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_514, i64 0, i32 3
        %__7_1135_1134_4718_15486 = load double, ptr %__7_1135_1134_4718_15486_pointer_518, !noalias !2
        %__8_1136_1135_4719_15487_pointer_519 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_514, i64 0, i32 4
        %__8_1136_1135_4719_15487 = load double, ptr %__8_1136_1135_4719_15487_pointer_519, !noalias !2
        %__9_1137_1136_4720_15488_pointer_520 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_514, i64 0, i32 5
        %__9_1137_1136_4720_15488 = load double, ptr %__9_1137_1136_4720_15488_pointer_520, !noalias !2
        %__10_1138_1137_4721_15489_pointer_521 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_514, i64 0, i32 6
        %__10_1138_1137_4721_15489 = load double, ptr %__10_1138_1137_4721_15489_pointer_521, !noalias !2
        call ccc void @eraseObject(%Object %fields_512)
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_522 = extractvalue %Pos %pureApp_16583, 0
        %fields_523 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_522, label %label_524 [i64 0, label %label_646]
    
    label_648:
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16583 = call ccc %Pos @unsafeGet_2487(%Pos %bodies_2361_12198, i64 %i_6_1128_1127_4711_10526)
        
        
        
        call ccc void @sharePositive(%Pos %pureApp_16583)
        %tag_511 = extractvalue %Pos %pureApp_16583, 0
        %fields_512 = extractvalue %Pos %pureApp_16583, 1
        switch i64 %tag_511, label %label_513 [i64 0, label %label_647]
}



define tailcc void @returnAddress_649(%Pos %__8_4805_15545, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_650 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_6_3584_12359_pointer_651 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_650, i64 0, i32 0
        %i_6_3584_12359 = load i64, ptr %i_6_3584_12359_pointer_651, !noalias !2
        %tmp_16435_pointer_652 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_650, i64 0, i32 1
        %tmp_16435 = load i64, ptr %tmp_16435_pointer_652, !noalias !2
        %bodies_2361_12198_pointer_653 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_650, i64 0, i32 2
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_653, !noalias !2
        call ccc void @erasePositive(%Pos %__8_4805_15545)
        
        %longLiteral_16598 = add i64 1, 0
        
        %pureApp_16597 = call ccc i64 @infixAdd_96(i64 %i_6_3584_12359, i64 %longLiteral_16598)
        
        
        
        
        
        musttail call tailcc void @loop_5_3583_12010(i64 %pureApp_16597, i64 %tmp_16435, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_498(%Pos %v_r_3100_1033_1032_4616_15423, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_499 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %bodies_2361_12198_pointer_500 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_499, i64 0, i32 0
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_500, !noalias !2
        %i_6_3584_12359_pointer_501 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_499, i64 0, i32 1
        %i_6_3584_12359 = load i64, ptr %i_6_3584_12359_pointer_501, !noalias !2
        %tmp_16435_pointer_502 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_499, i64 0, i32 2
        %tmp_16435 = load i64, ptr %tmp_16435_pointer_502, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3100_1033_1032_4616_15423)
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16580 = call ccc i64 @size_2483(%Pos %bodies_2361_12198)
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %stackPointer_660 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_6_3584_12359_pointer_661 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_660, i64 0, i32 0
        store i64 %i_6_3584_12359, ptr %i_6_3584_12359_pointer_661, !noalias !2
        %tmp_16435_pointer_662 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_660, i64 0, i32 1
        store i64 %tmp_16435, ptr %tmp_16435_pointer_662, !noalias !2
        %bodies_2361_12198_pointer_663 = getelementptr <{i64, i64, %Pos}>, %StackPointer %stackPointer_660, i64 0, i32 2
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_663, !noalias !2
        %returnAddress_pointer_664 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_660, i64 0, i32 1, i32 0
        %sharer_pointer_665 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_660, i64 0, i32 1, i32 1
        %eraser_pointer_666 = getelementptr <{<{i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_660, i64 0, i32 1, i32 2
        store ptr @returnAddress_649, ptr %returnAddress_pointer_664, !noalias !2
        store ptr @sharer_477, ptr %sharer_pointer_665, !noalias !2
        store ptr @eraser_485, ptr %eraser_pointer_666, !noalias !2
        
        %longLiteral_16599 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_1127_1126_4710_11085(i64 %longLiteral_16599, i64 %pureApp_16580, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
}



define ccc void @sharer_670(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_671 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %bodies_2361_12198_667_pointer_672 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_671, i64 0, i32 0
        %bodies_2361_12198_667 = load %Pos, ptr %bodies_2361_12198_667_pointer_672, !noalias !2
        %i_6_3584_12359_668_pointer_673 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_671, i64 0, i32 1
        %i_6_3584_12359_668 = load i64, ptr %i_6_3584_12359_668_pointer_673, !noalias !2
        %tmp_16435_669_pointer_674 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_671, i64 0, i32 2
        %tmp_16435_669 = load i64, ptr %tmp_16435_669_pointer_674, !noalias !2
        call ccc void @sharePositive(%Pos %bodies_2361_12198_667)
        call ccc void @shareFrames(%StackPointer %stackPointer_671)
        ret void
}



define ccc void @eraser_678(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_679 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %bodies_2361_12198_675_pointer_680 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_679, i64 0, i32 0
        %bodies_2361_12198_675 = load %Pos, ptr %bodies_2361_12198_675_pointer_680, !noalias !2
        %i_6_3584_12359_676_pointer_681 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_679, i64 0, i32 1
        %i_6_3584_12359_676 = load i64, ptr %i_6_3584_12359_676_pointer_681, !noalias !2
        %tmp_16435_677_pointer_682 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_679, i64 0, i32 2
        %tmp_16435_677 = load i64, ptr %tmp_16435_677_pointer_682, !noalias !2
        call ccc void @erasePositive(%Pos %bodies_2361_12198_675)
        call ccc void @eraseFrames(%StackPointer %stackPointer_679)
        ret void
}



define tailcc void @loop_5_3583_12010(i64 %i_6_3584_12359, i64 %tmp_16435, %Pos %bodies_2361_12198, %Stack %stack) {
        
    entry:
        
        
        %pureApp_16530 = call ccc %Pos @infixLt_178(i64 %i_6_3584_12359, i64 %tmp_16435)
        
        
        
        %tag_98 = extractvalue %Pos %pureApp_16530, 0
        %fields_99 = extractvalue %Pos %pureApp_16530, 1
        switch i64 %tag_98, label %label_100 [i64 0, label %label_105 i64 1, label %label_690]
    
    label_100:
        
        ret void
    
    label_105:
        call ccc void @erasePositive(%Pos %bodies_2361_12198)
        
        %unitLiteral_16531_temporary_101 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_16531 = insertvalue %Pos %unitLiteral_16531_temporary_101, %Object null, 1
        
        %stackPointer_103 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_104 = getelementptr %FrameHeader, %StackPointer %stackPointer_103, i64 0, i32 0
        %returnAddress_102 = load %ReturnAddress, ptr %returnAddress_pointer_104, !noalias !2
        musttail call tailcc void %returnAddress_102(%Pos %unitLiteral_16531, %Stack %stack)
        ret void
    
    label_690:
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16532 = call ccc i64 @size_2483(%Pos %bodies_2361_12198)
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %stackPointer_683 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %bodies_2361_12198_pointer_684 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_683, i64 0, i32 0
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_684, !noalias !2
        %i_6_3584_12359_pointer_685 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_683, i64 0, i32 1
        store i64 %i_6_3584_12359, ptr %i_6_3584_12359_pointer_685, !noalias !2
        %tmp_16435_pointer_686 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_683, i64 0, i32 2
        store i64 %tmp_16435, ptr %tmp_16435_pointer_686, !noalias !2
        %returnAddress_pointer_687 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_683, i64 0, i32 1, i32 0
        %sharer_pointer_688 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_683, i64 0, i32 1, i32 1
        %eraser_pointer_689 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_683, i64 0, i32 1, i32 2
        store ptr @returnAddress_498, ptr %returnAddress_pointer_687, !noalias !2
        store ptr @sharer_670, ptr %sharer_pointer_688, !noalias !2
        store ptr @eraser_678, ptr %eraser_pointer_689, !noalias !2
        
        %longLiteral_16600 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_517_516_4100_11441(i64 %longLiteral_16600, i64 %pureApp_16532, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_694(double %r_2927, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_16602 = call ccc %Pos @show_18(double %r_2927)
        
        
        
        %pureApp_16603 = call ccc %Pos @println_1(%Pos %pureApp_16602)
        
        
        
        %stackPointer_696 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_697 = getelementptr %FrameHeader, %StackPointer %stackPointer_696, i64 0, i32 0
        %returnAddress_695 = load %ReturnAddress, ptr %returnAddress_pointer_697, !noalias !2
        musttail call tailcc void %returnAddress_695(%Pos %pureApp_16603, %Stack %stack)
        ret void
}



define ccc void @sharer_698(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_699 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_699)
        ret void
}



define ccc void @eraser_700(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_701 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_701)
        ret void
}



define tailcc void @returnAddress_706(double %returnValue_707, %Stack %stack) {
        
    entry:
        
        %stackPointer_708 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_3114_2_4808_11101_pointer_709 = getelementptr <{double}>, %StackPointer %stackPointer_708, i64 0, i32 0
        %v_r_3114_2_4808_11101 = load double, ptr %v_r_3114_2_4808_11101_pointer_709, !noalias !2
        %stackPointer_711 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_712 = getelementptr %FrameHeader, %StackPointer %stackPointer_711, i64 0, i32 0
        %returnAddress_710 = load %ReturnAddress, ptr %returnAddress_pointer_712, !noalias !2
        musttail call tailcc void %returnAddress_710(double %returnValue_707, %Stack %stack)
        ret void
}



define ccc void @sharer_714(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_715 = getelementptr <{double}>, %StackPointer %stackPointer, i64 -1
        %v_r_3114_2_4808_11101_713_pointer_716 = getelementptr <{double}>, %StackPointer %stackPointer_715, i64 0, i32 0
        %v_r_3114_2_4808_11101_713 = load double, ptr %v_r_3114_2_4808_11101_713_pointer_716, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_715)
        ret void
}



define ccc void @eraser_718(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_719 = getelementptr <{double}>, %StackPointer %stackPointer, i64 -1
        %v_r_3114_2_4808_11101_717_pointer_720 = getelementptr <{double}>, %StackPointer %stackPointer_719, i64 0, i32 0
        %v_r_3114_2_4808_11101_717 = load double, ptr %v_r_3114_2_4808_11101_717_pointer_720, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_719)
        ret void
}



define tailcc void @returnAddress_930(%Pos %__8_243_494_5300_15826, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_931 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %e_3_4809_11809_pointer_932 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_931, i64 0, i32 0
        %e_3_4809_11809 = load %Reference, ptr %e_3_4809_11809_pointer_932, !noalias !2
        %tmp_16413_pointer_933 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_931, i64 0, i32 1
        %tmp_16413 = load i64, ptr %tmp_16413_pointer_933, !noalias !2
        %tmp_16403_pointer_934 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_931, i64 0, i32 2
        %tmp_16403 = load %Pos, ptr %tmp_16403_pointer_934, !noalias !2
        %i_6_158_409_5215_10944_pointer_935 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_931, i64 0, i32 3
        %i_6_158_409_5215_10944 = load i64, ptr %i_6_158_409_5215_10944_pointer_935, !noalias !2
        %bodies_2361_12198_pointer_936 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_931, i64 0, i32 4
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_936, !noalias !2
        call ccc void @erasePositive(%Pos %__8_243_494_5300_15826)
        
        %longLiteral_16637 = add i64 1, 0
        
        %pureApp_16636 = call ccc i64 @infixAdd_96(i64 %i_6_158_409_5215_10944, i64 %longLiteral_16637)
        
        
        
        
        
        musttail call tailcc void @loop_5_157_408_5214_10531(i64 %pureApp_16636, %Reference %e_3_4809_11809, i64 %tmp_16413, %Pos %tmp_16403, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
}



define ccc void @sharer_942(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_943 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %e_3_4809_11809_937_pointer_944 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_943, i64 0, i32 0
        %e_3_4809_11809_937 = load %Reference, ptr %e_3_4809_11809_937_pointer_944, !noalias !2
        %tmp_16413_938_pointer_945 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_943, i64 0, i32 1
        %tmp_16413_938 = load i64, ptr %tmp_16413_938_pointer_945, !noalias !2
        %tmp_16403_939_pointer_946 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_943, i64 0, i32 2
        %tmp_16403_939 = load %Pos, ptr %tmp_16403_939_pointer_946, !noalias !2
        %i_6_158_409_5215_10944_940_pointer_947 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_943, i64 0, i32 3
        %i_6_158_409_5215_10944_940 = load i64, ptr %i_6_158_409_5215_10944_940_pointer_947, !noalias !2
        %bodies_2361_12198_941_pointer_948 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_943, i64 0, i32 4
        %bodies_2361_12198_941 = load %Pos, ptr %bodies_2361_12198_941_pointer_948, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16403_939)
        call ccc void @sharePositive(%Pos %bodies_2361_12198_941)
        call ccc void @shareFrames(%StackPointer %stackPointer_943)
        ret void
}



define ccc void @eraser_954(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_955 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %e_3_4809_11809_949_pointer_956 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_955, i64 0, i32 0
        %e_3_4809_11809_949 = load %Reference, ptr %e_3_4809_11809_949_pointer_956, !noalias !2
        %tmp_16413_950_pointer_957 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_955, i64 0, i32 1
        %tmp_16413_950 = load i64, ptr %tmp_16413_950_pointer_957, !noalias !2
        %tmp_16403_951_pointer_958 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_955, i64 0, i32 2
        %tmp_16403_951 = load %Pos, ptr %tmp_16403_951_pointer_958, !noalias !2
        %i_6_158_409_5215_10944_952_pointer_959 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_955, i64 0, i32 3
        %i_6_158_409_5215_10944_952 = load i64, ptr %i_6_158_409_5215_10944_952_pointer_959, !noalias !2
        %bodies_2361_12198_953_pointer_960 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_955, i64 0, i32 4
        %bodies_2361_12198_953 = load %Pos, ptr %bodies_2361_12198_953_pointer_960, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16403_951)
        call ccc void @erasePositive(%Pos %bodies_2361_12198_953)
        call ccc void @eraseFrames(%StackPointer %stackPointer_955)
        ret void
}



define tailcc void @returnAddress_899(double %v_r_3132_65_223_474_5280_11617, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_900 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 88)
        %e_3_4809_11809_pointer_901 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_900, i64 0, i32 0
        %e_3_4809_11809 = load %Reference, ptr %e_3_4809_11809_pointer_901, !noalias !2
        %tmp_16413_pointer_902 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_900, i64 0, i32 1
        %tmp_16413 = load i64, ptr %tmp_16413_pointer_902, !noalias !2
        %tmp_16403_pointer_903 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_900, i64 0, i32 2
        %tmp_16403 = load %Pos, ptr %tmp_16403_pointer_903, !noalias !2
        %tmp_16424_pointer_904 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_900, i64 0, i32 3
        %tmp_16424 = load double, ptr %tmp_16424_pointer_904, !noalias !2
        %i_6_158_409_5215_10944_pointer_905 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_900, i64 0, i32 4
        %i_6_158_409_5215_10944 = load i64, ptr %i_6_158_409_5215_10944_pointer_905, !noalias !2
        %tmp_16415_pointer_906 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_900, i64 0, i32 5
        %tmp_16415 = load %Pos, ptr %tmp_16415_pointer_906, !noalias !2
        %bodies_2361_12198_pointer_907 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_900, i64 0, i32 6
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_907, !noalias !2
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_908 = extractvalue %Pos %tmp_16403, 0
        %fields_909 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_908, label %label_910 [i64 0, label %label_977]
    
    label_910:
        
        ret void
    
    label_921:
        
        ret void
    
    label_976:
        %environment_922 = call ccc %Environment @objectEnvironment(%Object %fields_920)
        %__74_232_483_5289_15820_pointer_923 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_922, i64 0, i32 0
        %__74_232_483_5289_15820 = load double, ptr %__74_232_483_5289_15820_pointer_923, !noalias !2
        %__75_233_484_5290_15821_pointer_924 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_922, i64 0, i32 1
        %__75_233_484_5290_15821 = load double, ptr %__75_233_484_5290_15821_pointer_924, !noalias !2
        %__76_234_485_5291_15822_pointer_925 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_922, i64 0, i32 2
        %__76_234_485_5291_15822 = load double, ptr %__76_234_485_5291_15822_pointer_925, !noalias !2
        %__77_235_486_5292_15823_pointer_926 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_922, i64 0, i32 3
        %__77_235_486_5292_15823 = load double, ptr %__77_235_486_5292_15823_pointer_926, !noalias !2
        %__78_236_487_5293_15824_pointer_927 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_922, i64 0, i32 4
        %__78_236_487_5293_15824 = load double, ptr %__78_236_487_5293_15824_pointer_927, !noalias !2
        %__79_237_488_5294_15825_pointer_928 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_922, i64 0, i32 5
        %__79_237_488_5294_15825 = load double, ptr %__79_237_488_5294_15825_pointer_928, !noalias !2
        %x_80_238_489_5295_12152_pointer_929 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_922, i64 0, i32 6
        %x_80_238_489_5295_12152 = load double, ptr %x_80_238_489_5295_12152_pointer_929, !noalias !2
        call ccc void @eraseObject(%Object %fields_920)
        
        %pureApp_16633 = call ccc double @infixMul_114(double %x_72_230_481_5287_12609, double %x_80_238_489_5295_12152)
        
        
        
        %pureApp_16634 = call ccc double @infixDiv_120(double %pureApp_16633, double %tmp_16424)
        
        
        
        %pureApp_16635 = call ccc double @infixSub_117(double %v_r_3132_65_223_474_5280_11617, double %pureApp_16634)
        
        
        %stackPointer_961 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %e_3_4809_11809_pointer_962 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_961, i64 0, i32 0
        store %Reference %e_3_4809_11809, ptr %e_3_4809_11809_pointer_962, !noalias !2
        %tmp_16413_pointer_963 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_961, i64 0, i32 1
        store i64 %tmp_16413, ptr %tmp_16413_pointer_963, !noalias !2
        %tmp_16403_pointer_964 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_961, i64 0, i32 2
        store %Pos %tmp_16403, ptr %tmp_16403_pointer_964, !noalias !2
        %i_6_158_409_5215_10944_pointer_965 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_961, i64 0, i32 3
        store i64 %i_6_158_409_5215_10944, ptr %i_6_158_409_5215_10944_pointer_965, !noalias !2
        %bodies_2361_12198_pointer_966 = getelementptr <{%Reference, i64, %Pos, i64, %Pos}>, %StackPointer %stackPointer_961, i64 0, i32 4
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_966, !noalias !2
        %returnAddress_pointer_967 = getelementptr <{<{%Reference, i64, %Pos, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_961, i64 0, i32 1, i32 0
        %sharer_pointer_968 = getelementptr <{<{%Reference, i64, %Pos, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_961, i64 0, i32 1, i32 1
        %eraser_pointer_969 = getelementptr <{<{%Reference, i64, %Pos, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_961, i64 0, i32 1, i32 2
        store ptr @returnAddress_930, ptr %returnAddress_pointer_967, !noalias !2
        store ptr @sharer_942, ptr %sharer_pointer_968, !noalias !2
        store ptr @eraser_954, ptr %eraser_pointer_969, !noalias !2
        
        %e_3_4809_11809pointer_970 = call ccc ptr @getVarPointer(%Reference %e_3_4809_11809, %Stack %stack)
        %e_3_4809_11809_old_971 = load double, ptr %e_3_4809_11809pointer_970, !noalias !2
        store double %pureApp_16635, ptr %e_3_4809_11809pointer_970, !noalias !2
        
        %put_16638_temporary_972 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_16638 = insertvalue %Pos %put_16638_temporary_972, %Object null, 1
        
        %stackPointer_974 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_975 = getelementptr %FrameHeader, %StackPointer %stackPointer_974, i64 0, i32 0
        %returnAddress_973 = load %ReturnAddress, ptr %returnAddress_pointer_975, !noalias !2
        musttail call tailcc void %returnAddress_973(%Pos %put_16638, %Stack %stack)
        ret void
    
    label_977:
        %environment_911 = call ccc %Environment @objectEnvironment(%Object %fields_909)
        %__66_224_475_5281_15814_pointer_912 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_911, i64 0, i32 0
        %__66_224_475_5281_15814 = load double, ptr %__66_224_475_5281_15814_pointer_912, !noalias !2
        %__67_225_476_5282_15815_pointer_913 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_911, i64 0, i32 1
        %__67_225_476_5282_15815 = load double, ptr %__67_225_476_5282_15815_pointer_913, !noalias !2
        %__68_226_477_5283_15816_pointer_914 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_911, i64 0, i32 2
        %__68_226_477_5283_15816 = load double, ptr %__68_226_477_5283_15816_pointer_914, !noalias !2
        %__69_227_478_5284_15817_pointer_915 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_911, i64 0, i32 3
        %__69_227_478_5284_15817 = load double, ptr %__69_227_478_5284_15817_pointer_915, !noalias !2
        %__70_228_479_5285_15818_pointer_916 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_911, i64 0, i32 4
        %__70_228_479_5285_15818 = load double, ptr %__70_228_479_5285_15818_pointer_916, !noalias !2
        %__71_229_480_5286_15819_pointer_917 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_911, i64 0, i32 5
        %__71_229_480_5286_15819 = load double, ptr %__71_229_480_5286_15819_pointer_917, !noalias !2
        %x_72_230_481_5287_12609_pointer_918 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_911, i64 0, i32 6
        %x_72_230_481_5287_12609 = load double, ptr %x_72_230_481_5287_12609_pointer_918, !noalias !2
        call ccc void @eraseObject(%Object %fields_909)
        
        %tag_919 = extractvalue %Pos %tmp_16415, 0
        %fields_920 = extractvalue %Pos %tmp_16415, 1
        switch i64 %tag_919, label %label_921 [i64 0, label %label_976]
}



define ccc void @sharer_985(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_986 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %e_3_4809_11809_978_pointer_987 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_986, i64 0, i32 0
        %e_3_4809_11809_978 = load %Reference, ptr %e_3_4809_11809_978_pointer_987, !noalias !2
        %tmp_16413_979_pointer_988 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_986, i64 0, i32 1
        %tmp_16413_979 = load i64, ptr %tmp_16413_979_pointer_988, !noalias !2
        %tmp_16403_980_pointer_989 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_986, i64 0, i32 2
        %tmp_16403_980 = load %Pos, ptr %tmp_16403_980_pointer_989, !noalias !2
        %tmp_16424_981_pointer_990 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_986, i64 0, i32 3
        %tmp_16424_981 = load double, ptr %tmp_16424_981_pointer_990, !noalias !2
        %i_6_158_409_5215_10944_982_pointer_991 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_986, i64 0, i32 4
        %i_6_158_409_5215_10944_982 = load i64, ptr %i_6_158_409_5215_10944_982_pointer_991, !noalias !2
        %tmp_16415_983_pointer_992 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_986, i64 0, i32 5
        %tmp_16415_983 = load %Pos, ptr %tmp_16415_983_pointer_992, !noalias !2
        %bodies_2361_12198_984_pointer_993 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_986, i64 0, i32 6
        %bodies_2361_12198_984 = load %Pos, ptr %bodies_2361_12198_984_pointer_993, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16403_980)
        call ccc void @sharePositive(%Pos %tmp_16415_983)
        call ccc void @sharePositive(%Pos %bodies_2361_12198_984)
        call ccc void @shareFrames(%StackPointer %stackPointer_986)
        ret void
}



define ccc void @eraser_1001(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1002 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %e_3_4809_11809_994_pointer_1003 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1002, i64 0, i32 0
        %e_3_4809_11809_994 = load %Reference, ptr %e_3_4809_11809_994_pointer_1003, !noalias !2
        %tmp_16413_995_pointer_1004 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1002, i64 0, i32 1
        %tmp_16413_995 = load i64, ptr %tmp_16413_995_pointer_1004, !noalias !2
        %tmp_16403_996_pointer_1005 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1002, i64 0, i32 2
        %tmp_16403_996 = load %Pos, ptr %tmp_16403_996_pointer_1005, !noalias !2
        %tmp_16424_997_pointer_1006 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1002, i64 0, i32 3
        %tmp_16424_997 = load double, ptr %tmp_16424_997_pointer_1006, !noalias !2
        %i_6_158_409_5215_10944_998_pointer_1007 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1002, i64 0, i32 4
        %i_6_158_409_5215_10944_998 = load i64, ptr %i_6_158_409_5215_10944_998_pointer_1007, !noalias !2
        %tmp_16415_999_pointer_1008 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1002, i64 0, i32 5
        %tmp_16415_999 = load %Pos, ptr %tmp_16415_999_pointer_1008, !noalias !2
        %bodies_2361_12198_1000_pointer_1009 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1002, i64 0, i32 6
        %bodies_2361_12198_1000 = load %Pos, ptr %bodies_2361_12198_1000_pointer_1009, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16403_996)
        call ccc void @erasePositive(%Pos %tmp_16415_999)
        call ccc void @erasePositive(%Pos %bodies_2361_12198_1000)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1002)
        ret void
}



define tailcc void @loop_5_157_408_5214_10531(i64 %i_6_158_409_5215_10944, %Reference %e_3_4809_11809, i64 %tmp_16413, %Pos %tmp_16403, %Pos %bodies_2361_12198, %Stack %stack) {
        
    entry:
        
        
        %pureApp_16621 = call ccc %Pos @infixLt_178(i64 %i_6_158_409_5215_10944, i64 %tmp_16413)
        
        
        
        %tag_825 = extractvalue %Pos %pureApp_16621, 0
        %fields_826 = extractvalue %Pos %pureApp_16621, 1
        switch i64 %tag_825, label %label_827 [i64 0, label %label_832 i64 1, label %label_1032]
    
    label_827:
        
        ret void
    
    label_832:
        call ccc void @erasePositive(%Pos %tmp_16403)
        call ccc void @erasePositive(%Pos %bodies_2361_12198)
        
        %unitLiteral_16622_temporary_828 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_16622 = insertvalue %Pos %unitLiteral_16622_temporary_828, %Object null, 1
        
        %stackPointer_830 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_831 = getelementptr %FrameHeader, %StackPointer %stackPointer_830, i64 0, i32 0
        %returnAddress_829 = load %ReturnAddress, ptr %returnAddress_pointer_831, !noalias !2
        musttail call tailcc void %returnAddress_829(%Pos %unitLiteral_16622, %Stack %stack)
        ret void
    
    label_835:
        
        ret void
    
    label_846:
        
        ret void
    
    label_857:
        
        ret void
    
    label_868:
        
        ret void
    
    label_879:
        
        ret void
    
    label_890:
        
        ret void
    
    label_1026:
        %environment_891 = call ccc %Environment @objectEnvironment(%Object %fields_889)
        %__48_206_457_5263_15808_pointer_892 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_891, i64 0, i32 0
        %__48_206_457_5263_15808 = load double, ptr %__48_206_457_5263_15808_pointer_892, !noalias !2
        %__49_207_458_5264_15809_pointer_893 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_891, i64 0, i32 1
        %__49_207_458_5264_15809 = load double, ptr %__49_207_458_5264_15809_pointer_893, !noalias !2
        %x_50_208_459_5265_12449_pointer_894 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_891, i64 0, i32 2
        %x_50_208_459_5265_12449 = load double, ptr %x_50_208_459_5265_12449_pointer_894, !noalias !2
        %__51_209_460_5266_15810_pointer_895 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_891, i64 0, i32 3
        %__51_209_460_5266_15810 = load double, ptr %__51_209_460_5266_15810_pointer_895, !noalias !2
        %__52_210_461_5267_15811_pointer_896 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_891, i64 0, i32 4
        %__52_210_461_5267_15811 = load double, ptr %__52_210_461_5267_15811_pointer_896, !noalias !2
        %__53_211_462_5268_15812_pointer_897 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_891, i64 0, i32 5
        %__53_211_462_5268_15812 = load double, ptr %__53_211_462_5268_15812_pointer_897, !noalias !2
        %__54_212_463_5269_15813_pointer_898 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_891, i64 0, i32 6
        %__54_212_463_5269_15813 = load double, ptr %__54_212_463_5269_15813_pointer_898, !noalias !2
        call ccc void @eraseObject(%Object %fields_889)
        
        %pureApp_16626 = call ccc double @infixSub_117(double %x_42_200_451_5257_11933, double %x_50_208_459_5265_12449)
        
        
        
        %pureApp_16627 = call ccc double @infixMul_114(double %pureApp_16624, double %pureApp_16624)
        
        
        
        %pureApp_16628 = call ccc double @infixMul_114(double %pureApp_16625, double %pureApp_16625)
        
        
        
        %pureApp_16629 = call ccc double @infixAdd_111(double %pureApp_16627, double %pureApp_16628)
        
        
        
        %pureApp_16630 = call ccc double @infixMul_114(double %pureApp_16626, double %pureApp_16626)
        
        
        
        %pureApp_16631 = call ccc double @infixAdd_111(double %pureApp_16629, double %pureApp_16630)
        
        
        
        %pureApp_16632 = call ccc double @sqrt_130(double %pureApp_16631)
        
        
        %stackPointer_1010 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 112)
        %e_3_4809_11809_pointer_1011 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1010, i64 0, i32 0
        store %Reference %e_3_4809_11809, ptr %e_3_4809_11809_pointer_1011, !noalias !2
        %tmp_16413_pointer_1012 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1010, i64 0, i32 1
        store i64 %tmp_16413, ptr %tmp_16413_pointer_1012, !noalias !2
        %tmp_16403_pointer_1013 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1010, i64 0, i32 2
        store %Pos %tmp_16403, ptr %tmp_16403_pointer_1013, !noalias !2
        %tmp_16424_pointer_1014 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1010, i64 0, i32 3
        store double %pureApp_16632, ptr %tmp_16424_pointer_1014, !noalias !2
        %i_6_158_409_5215_10944_pointer_1015 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1010, i64 0, i32 4
        store i64 %i_6_158_409_5215_10944, ptr %i_6_158_409_5215_10944_pointer_1015, !noalias !2
        %tmp_16415_pointer_1016 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1010, i64 0, i32 5
        store %Pos %pureApp_16623, ptr %tmp_16415_pointer_1016, !noalias !2
        %bodies_2361_12198_pointer_1017 = getelementptr <{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %StackPointer %stackPointer_1010, i64 0, i32 6
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_1017, !noalias !2
        %returnAddress_pointer_1018 = getelementptr <{<{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1010, i64 0, i32 1, i32 0
        %sharer_pointer_1019 = getelementptr <{<{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1010, i64 0, i32 1, i32 1
        %eraser_pointer_1020 = getelementptr <{<{%Reference, i64, %Pos, double, i64, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1010, i64 0, i32 1, i32 2
        store ptr @returnAddress_899, ptr %returnAddress_pointer_1018, !noalias !2
        store ptr @sharer_985, ptr %sharer_pointer_1019, !noalias !2
        store ptr @eraser_1001, ptr %eraser_pointer_1020, !noalias !2
        
        %get_16639_pointer_1021 = call ccc ptr @getVarPointer(%Reference %e_3_4809_11809, %Stack %stack)
        %e_3_4809_11809_old_1022 = load double, ptr %get_16639_pointer_1021, !noalias !2
        %get_16639 = load double, ptr %get_16639_pointer_1021, !noalias !2
        
        %stackPointer_1024 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1025 = getelementptr %FrameHeader, %StackPointer %stackPointer_1024, i64 0, i32 0
        %returnAddress_1023 = load %ReturnAddress, ptr %returnAddress_pointer_1025, !noalias !2
        musttail call tailcc void %returnAddress_1023(double %get_16639, %Stack %stack)
        ret void
    
    label_1027:
        %environment_880 = call ccc %Environment @objectEnvironment(%Object %fields_878)
        %__40_198_449_5255_15802_pointer_881 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_880, i64 0, i32 0
        %__40_198_449_5255_15802 = load double, ptr %__40_198_449_5255_15802_pointer_881, !noalias !2
        %__41_199_450_5256_15803_pointer_882 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_880, i64 0, i32 1
        %__41_199_450_5256_15803 = load double, ptr %__41_199_450_5256_15803_pointer_882, !noalias !2
        %x_42_200_451_5257_11933_pointer_883 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_880, i64 0, i32 2
        %x_42_200_451_5257_11933 = load double, ptr %x_42_200_451_5257_11933_pointer_883, !noalias !2
        %__43_201_452_5258_15804_pointer_884 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_880, i64 0, i32 3
        %__43_201_452_5258_15804 = load double, ptr %__43_201_452_5258_15804_pointer_884, !noalias !2
        %__44_202_453_5259_15805_pointer_885 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_880, i64 0, i32 4
        %__44_202_453_5259_15805 = load double, ptr %__44_202_453_5259_15805_pointer_885, !noalias !2
        %__45_203_454_5260_15806_pointer_886 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_880, i64 0, i32 5
        %__45_203_454_5260_15806 = load double, ptr %__45_203_454_5260_15806_pointer_886, !noalias !2
        %__46_204_455_5261_15807_pointer_887 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_880, i64 0, i32 6
        %__46_204_455_5261_15807 = load double, ptr %__46_204_455_5261_15807_pointer_887, !noalias !2
        call ccc void @eraseObject(%Object %fields_878)
        
        call ccc void @sharePositive(%Pos %pureApp_16623)
        %tag_888 = extractvalue %Pos %pureApp_16623, 0
        %fields_889 = extractvalue %Pos %pureApp_16623, 1
        switch i64 %tag_888, label %label_890 [i64 0, label %label_1026]
    
    label_1028:
        %environment_869 = call ccc %Environment @objectEnvironment(%Object %fields_867)
        %__30_188_439_5245_15796_pointer_870 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_869, i64 0, i32 0
        %__30_188_439_5245_15796 = load double, ptr %__30_188_439_5245_15796_pointer_870, !noalias !2
        %x_31_189_440_5246_11264_pointer_871 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_869, i64 0, i32 1
        %x_31_189_440_5246_11264 = load double, ptr %x_31_189_440_5246_11264_pointer_871, !noalias !2
        %__32_190_441_5247_15797_pointer_872 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_869, i64 0, i32 2
        %__32_190_441_5247_15797 = load double, ptr %__32_190_441_5247_15797_pointer_872, !noalias !2
        %__33_191_442_5248_15798_pointer_873 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_869, i64 0, i32 3
        %__33_191_442_5248_15798 = load double, ptr %__33_191_442_5248_15798_pointer_873, !noalias !2
        %__34_192_443_5249_15799_pointer_874 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_869, i64 0, i32 4
        %__34_192_443_5249_15799 = load double, ptr %__34_192_443_5249_15799_pointer_874, !noalias !2
        %__35_193_444_5250_15800_pointer_875 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_869, i64 0, i32 5
        %__35_193_444_5250_15800 = load double, ptr %__35_193_444_5250_15800_pointer_875, !noalias !2
        %__36_194_445_5251_15801_pointer_876 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_869, i64 0, i32 6
        %__36_194_445_5251_15801 = load double, ptr %__36_194_445_5251_15801_pointer_876, !noalias !2
        call ccc void @eraseObject(%Object %fields_867)
        
        %pureApp_16625 = call ccc double @infixSub_117(double %x_23_181_432_5238_12643, double %x_31_189_440_5246_11264)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_877 = extractvalue %Pos %tmp_16403, 0
        %fields_878 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_877, label %label_879 [i64 0, label %label_1027]
    
    label_1029:
        %environment_858 = call ccc %Environment @objectEnvironment(%Object %fields_856)
        %__22_180_431_5237_15790_pointer_859 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_858, i64 0, i32 0
        %__22_180_431_5237_15790 = load double, ptr %__22_180_431_5237_15790_pointer_859, !noalias !2
        %x_23_181_432_5238_12643_pointer_860 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_858, i64 0, i32 1
        %x_23_181_432_5238_12643 = load double, ptr %x_23_181_432_5238_12643_pointer_860, !noalias !2
        %__24_182_433_5239_15791_pointer_861 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_858, i64 0, i32 2
        %__24_182_433_5239_15791 = load double, ptr %__24_182_433_5239_15791_pointer_861, !noalias !2
        %__25_183_434_5240_15792_pointer_862 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_858, i64 0, i32 3
        %__25_183_434_5240_15792 = load double, ptr %__25_183_434_5240_15792_pointer_862, !noalias !2
        %__26_184_435_5241_15793_pointer_863 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_858, i64 0, i32 4
        %__26_184_435_5241_15793 = load double, ptr %__26_184_435_5241_15793_pointer_863, !noalias !2
        %__27_185_436_5242_15794_pointer_864 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_858, i64 0, i32 5
        %__27_185_436_5242_15794 = load double, ptr %__27_185_436_5242_15794_pointer_864, !noalias !2
        %__28_186_437_5243_15795_pointer_865 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_858, i64 0, i32 6
        %__28_186_437_5243_15795 = load double, ptr %__28_186_437_5243_15795_pointer_865, !noalias !2
        call ccc void @eraseObject(%Object %fields_856)
        
        call ccc void @sharePositive(%Pos %pureApp_16623)
        %tag_866 = extractvalue %Pos %pureApp_16623, 0
        %fields_867 = extractvalue %Pos %pureApp_16623, 1
        switch i64 %tag_866, label %label_868 [i64 0, label %label_1028]
    
    label_1030:
        %environment_847 = call ccc %Environment @objectEnvironment(%Object %fields_845)
        %x_12_170_421_5227_10651_pointer_848 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_847, i64 0, i32 0
        %x_12_170_421_5227_10651 = load double, ptr %x_12_170_421_5227_10651_pointer_848, !noalias !2
        %__13_171_422_5228_15784_pointer_849 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_847, i64 0, i32 1
        %__13_171_422_5228_15784 = load double, ptr %__13_171_422_5228_15784_pointer_849, !noalias !2
        %__14_172_423_5229_15785_pointer_850 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_847, i64 0, i32 2
        %__14_172_423_5229_15785 = load double, ptr %__14_172_423_5229_15785_pointer_850, !noalias !2
        %__15_173_424_5230_15786_pointer_851 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_847, i64 0, i32 3
        %__15_173_424_5230_15786 = load double, ptr %__15_173_424_5230_15786_pointer_851, !noalias !2
        %__16_174_425_5231_15787_pointer_852 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_847, i64 0, i32 4
        %__16_174_425_5231_15787 = load double, ptr %__16_174_425_5231_15787_pointer_852, !noalias !2
        %__17_175_426_5232_15788_pointer_853 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_847, i64 0, i32 5
        %__17_175_426_5232_15788 = load double, ptr %__17_175_426_5232_15788_pointer_853, !noalias !2
        %__18_176_427_5233_15789_pointer_854 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_847, i64 0, i32 6
        %__18_176_427_5233_15789 = load double, ptr %__18_176_427_5233_15789_pointer_854, !noalias !2
        call ccc void @eraseObject(%Object %fields_845)
        
        %pureApp_16624 = call ccc double @infixSub_117(double %x_4_162_413_5219_11895, double %x_12_170_421_5227_10651)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_855 = extractvalue %Pos %tmp_16403, 0
        %fields_856 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_855, label %label_857 [i64 0, label %label_1029]
    
    label_1031:
        %environment_836 = call ccc %Environment @objectEnvironment(%Object %fields_834)
        %x_4_162_413_5219_11895_pointer_837 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_836, i64 0, i32 0
        %x_4_162_413_5219_11895 = load double, ptr %x_4_162_413_5219_11895_pointer_837, !noalias !2
        %__5_163_414_5220_15778_pointer_838 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_836, i64 0, i32 1
        %__5_163_414_5220_15778 = load double, ptr %__5_163_414_5220_15778_pointer_838, !noalias !2
        %__6_164_415_5221_15779_pointer_839 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_836, i64 0, i32 2
        %__6_164_415_5221_15779 = load double, ptr %__6_164_415_5221_15779_pointer_839, !noalias !2
        %__7_165_416_5222_15780_pointer_840 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_836, i64 0, i32 3
        %__7_165_416_5222_15780 = load double, ptr %__7_165_416_5222_15780_pointer_840, !noalias !2
        %__8_166_417_5223_15781_pointer_841 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_836, i64 0, i32 4
        %__8_166_417_5223_15781 = load double, ptr %__8_166_417_5223_15781_pointer_841, !noalias !2
        %__9_167_418_5224_15782_pointer_842 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_836, i64 0, i32 5
        %__9_167_418_5224_15782 = load double, ptr %__9_167_418_5224_15782_pointer_842, !noalias !2
        %__10_168_419_5225_15783_pointer_843 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_836, i64 0, i32 6
        %__10_168_419_5225_15783 = load double, ptr %__10_168_419_5225_15783_pointer_843, !noalias !2
        call ccc void @eraseObject(%Object %fields_834)
        
        call ccc void @sharePositive(%Pos %pureApp_16623)
        %tag_844 = extractvalue %Pos %pureApp_16623, 0
        %fields_845 = extractvalue %Pos %pureApp_16623, 1
        switch i64 %tag_844, label %label_846 [i64 0, label %label_1030]
    
    label_1032:
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16623 = call ccc %Pos @unsafeGet_2487(%Pos %bodies_2361_12198, i64 %i_6_158_409_5215_10944)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_833 = extractvalue %Pos %tmp_16403, 0
        %fields_834 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_833, label %label_835 [i64 0, label %label_1031]
}



define tailcc void @returnAddress_1033(%Pos %__8_496_5302_15827, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1034 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %i_6_251_5057_10640_pointer_1035 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1034, i64 0, i32 0
        %i_6_251_5057_10640 = load i64, ptr %i_6_251_5057_10640_pointer_1035, !noalias !2
        %bodies_2361_12198_pointer_1036 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1034, i64 0, i32 1
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_1036, !noalias !2
        %tmp_16401_pointer_1037 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1034, i64 0, i32 2
        %tmp_16401 = load i64, ptr %tmp_16401_pointer_1037, !noalias !2
        %e_3_4809_11809_pointer_1038 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1034, i64 0, i32 3
        %e_3_4809_11809 = load %Reference, ptr %e_3_4809_11809_pointer_1038, !noalias !2
        call ccc void @erasePositive(%Pos %__8_496_5302_15827)
        
        %longLiteral_16641 = add i64 1, 0
        
        %pureApp_16640 = call ccc i64 @infixAdd_96(i64 %i_6_251_5057_10640, i64 %longLiteral_16641)
        
        
        
        
        
        musttail call tailcc void @loop_5_250_5056_11393(i64 %pureApp_16640, %Pos %bodies_2361_12198, i64 %tmp_16401, %Reference %e_3_4809_11809, %Stack %stack)
        ret void
}



define ccc void @sharer_1043(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1044 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_251_5057_10640_1039_pointer_1045 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1044, i64 0, i32 0
        %i_6_251_5057_10640_1039 = load i64, ptr %i_6_251_5057_10640_1039_pointer_1045, !noalias !2
        %bodies_2361_12198_1040_pointer_1046 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1044, i64 0, i32 1
        %bodies_2361_12198_1040 = load %Pos, ptr %bodies_2361_12198_1040_pointer_1046, !noalias !2
        %tmp_16401_1041_pointer_1047 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1044, i64 0, i32 2
        %tmp_16401_1041 = load i64, ptr %tmp_16401_1041_pointer_1047, !noalias !2
        %e_3_4809_11809_1042_pointer_1048 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1044, i64 0, i32 3
        %e_3_4809_11809_1042 = load %Reference, ptr %e_3_4809_11809_1042_pointer_1048, !noalias !2
        call ccc void @sharePositive(%Pos %bodies_2361_12198_1040)
        call ccc void @shareFrames(%StackPointer %stackPointer_1044)
        ret void
}



define ccc void @eraser_1053(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1054 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_6_251_5057_10640_1049_pointer_1055 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1054, i64 0, i32 0
        %i_6_251_5057_10640_1049 = load i64, ptr %i_6_251_5057_10640_1049_pointer_1055, !noalias !2
        %bodies_2361_12198_1050_pointer_1056 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1054, i64 0, i32 1
        %bodies_2361_12198_1050 = load %Pos, ptr %bodies_2361_12198_1050_pointer_1056, !noalias !2
        %tmp_16401_1051_pointer_1057 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1054, i64 0, i32 2
        %tmp_16401_1051 = load i64, ptr %tmp_16401_1051_pointer_1057, !noalias !2
        %e_3_4809_11809_1052_pointer_1058 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1054, i64 0, i32 3
        %e_3_4809_11809_1052 = load %Reference, ptr %e_3_4809_11809_1052_pointer_1058, !noalias !2
        call ccc void @erasePositive(%Pos %bodies_2361_12198_1050)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1054)
        ret void
}



define tailcc void @returnAddress_818(%Pos %__69_320_5126_15729, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_819 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %tmp_16403_pointer_820 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_819, i64 0, i32 0
        %tmp_16403 = load %Pos, ptr %tmp_16403_pointer_820, !noalias !2
        %i_6_251_5057_10640_pointer_821 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_819, i64 0, i32 1
        %i_6_251_5057_10640 = load i64, ptr %i_6_251_5057_10640_pointer_821, !noalias !2
        %bodies_2361_12198_pointer_822 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_819, i64 0, i32 2
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_822, !noalias !2
        %tmp_16401_pointer_823 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_819, i64 0, i32 3
        %tmp_16401 = load i64, ptr %tmp_16401_pointer_823, !noalias !2
        %e_3_4809_11809_pointer_824 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_819, i64 0, i32 4
        %e_3_4809_11809 = load %Reference, ptr %e_3_4809_11809_pointer_824, !noalias !2
        call ccc void @erasePositive(%Pos %__69_320_5126_15729)
        
        %longLiteral_16619 = add i64 1, 0
        
        %pureApp_16618 = call ccc i64 @infixAdd_96(i64 %i_6_251_5057_10640, i64 %longLiteral_16619)
        
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16620 = call ccc i64 @size_2483(%Pos %bodies_2361_12198)
        
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %stackPointer_1059 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %i_6_251_5057_10640_pointer_1060 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1059, i64 0, i32 0
        store i64 %i_6_251_5057_10640, ptr %i_6_251_5057_10640_pointer_1060, !noalias !2
        %bodies_2361_12198_pointer_1061 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1059, i64 0, i32 1
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_1061, !noalias !2
        %tmp_16401_pointer_1062 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1059, i64 0, i32 2
        store i64 %tmp_16401, ptr %tmp_16401_pointer_1062, !noalias !2
        %e_3_4809_11809_pointer_1063 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1059, i64 0, i32 3
        store %Reference %e_3_4809_11809, ptr %e_3_4809_11809_pointer_1063, !noalias !2
        %returnAddress_pointer_1064 = getelementptr <{<{i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1059, i64 0, i32 1, i32 0
        %sharer_pointer_1065 = getelementptr <{<{i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1059, i64 0, i32 1, i32 1
        %eraser_pointer_1066 = getelementptr <{<{i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1059, i64 0, i32 1, i32 2
        store ptr @returnAddress_1033, ptr %returnAddress_pointer_1064, !noalias !2
        store ptr @sharer_1043, ptr %sharer_pointer_1065, !noalias !2
        store ptr @eraser_1053, ptr %eraser_pointer_1066, !noalias !2
        
        
        
        musttail call tailcc void @loop_5_157_408_5214_10531(i64 %pureApp_16618, %Reference %e_3_4809_11809, i64 %pureApp_16620, %Pos %tmp_16403, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
}



define ccc void @sharer_1072(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1073 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_16403_1067_pointer_1074 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1073, i64 0, i32 0
        %tmp_16403_1067 = load %Pos, ptr %tmp_16403_1067_pointer_1074, !noalias !2
        %i_6_251_5057_10640_1068_pointer_1075 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1073, i64 0, i32 1
        %i_6_251_5057_10640_1068 = load i64, ptr %i_6_251_5057_10640_1068_pointer_1075, !noalias !2
        %bodies_2361_12198_1069_pointer_1076 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1073, i64 0, i32 2
        %bodies_2361_12198_1069 = load %Pos, ptr %bodies_2361_12198_1069_pointer_1076, !noalias !2
        %tmp_16401_1070_pointer_1077 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1073, i64 0, i32 3
        %tmp_16401_1070 = load i64, ptr %tmp_16401_1070_pointer_1077, !noalias !2
        %e_3_4809_11809_1071_pointer_1078 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1073, i64 0, i32 4
        %e_3_4809_11809_1071 = load %Reference, ptr %e_3_4809_11809_1071_pointer_1078, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16403_1067)
        call ccc void @sharePositive(%Pos %bodies_2361_12198_1069)
        call ccc void @shareFrames(%StackPointer %stackPointer_1073)
        ret void
}



define ccc void @eraser_1084(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1085 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_16403_1079_pointer_1086 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1085, i64 0, i32 0
        %tmp_16403_1079 = load %Pos, ptr %tmp_16403_1079_pointer_1086, !noalias !2
        %i_6_251_5057_10640_1080_pointer_1087 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1085, i64 0, i32 1
        %i_6_251_5057_10640_1080 = load i64, ptr %i_6_251_5057_10640_1080_pointer_1087, !noalias !2
        %bodies_2361_12198_1081_pointer_1088 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1085, i64 0, i32 2
        %bodies_2361_12198_1081 = load %Pos, ptr %bodies_2361_12198_1081_pointer_1088, !noalias !2
        %tmp_16401_1082_pointer_1089 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1085, i64 0, i32 3
        %tmp_16401_1082 = load i64, ptr %tmp_16401_1082_pointer_1089, !noalias !2
        %e_3_4809_11809_1083_pointer_1090 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1085, i64 0, i32 4
        %e_3_4809_11809_1083 = load %Reference, ptr %e_3_4809_11809_1083_pointer_1090, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16403_1079)
        call ccc void @erasePositive(%Pos %bodies_2361_12198_1081)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1085)
        ret void
}



define tailcc void @returnAddress_734(double %v_r_3116_4_255_5061_11033, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_735 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %tmp_16403_pointer_736 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 0
        %tmp_16403 = load %Pos, ptr %tmp_16403_pointer_736, !noalias !2
        %i_6_251_5057_10640_pointer_737 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 1
        %i_6_251_5057_10640 = load i64, ptr %i_6_251_5057_10640_pointer_737, !noalias !2
        %bodies_2361_12198_pointer_738 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 2
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_738, !noalias !2
        %tmp_16401_pointer_739 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 3
        %tmp_16401 = load i64, ptr %tmp_16401_pointer_739, !noalias !2
        %e_3_4809_11809_pointer_740 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 4
        %e_3_4809_11809 = load %Reference, ptr %e_3_4809_11809_pointer_740, !noalias !2
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_741 = extractvalue %Pos %tmp_16403, 0
        %fields_742 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_741, label %label_743 [i64 0, label %label_1112]
    
    label_743:
        
        ret void
    
    label_754:
        
        ret void
    
    label_765:
        
        ret void
    
    label_776:
        
        ret void
    
    label_787:
        
        ret void
    
    label_798:
        
        ret void
    
    label_809:
        
        ret void
    
    label_1106:
        %environment_810 = call ccc %Environment @objectEnvironment(%Object %fields_808)
        %__53_304_5110_15723_pointer_811 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_810, i64 0, i32 0
        %__53_304_5110_15723 = load double, ptr %__53_304_5110_15723_pointer_811, !noalias !2
        %__54_305_5111_15724_pointer_812 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_810, i64 0, i32 1
        %__54_305_5111_15724 = load double, ptr %__54_305_5111_15724_pointer_812, !noalias !2
        %__55_306_5112_15725_pointer_813 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_810, i64 0, i32 2
        %__55_306_5112_15725 = load double, ptr %__55_306_5112_15725_pointer_813, !noalias !2
        %__56_307_5113_15726_pointer_814 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_810, i64 0, i32 3
        %__56_307_5113_15726 = load double, ptr %__56_307_5113_15726_pointer_814, !noalias !2
        %__57_308_5114_15727_pointer_815 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_810, i64 0, i32 4
        %__57_308_5114_15727 = load double, ptr %__57_308_5114_15727_pointer_815, !noalias !2
        %x_58_309_5115_12426_pointer_816 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_810, i64 0, i32 5
        %x_58_309_5115_12426 = load double, ptr %x_58_309_5115_12426_pointer_816, !noalias !2
        %__59_310_5116_15728_pointer_817 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_810, i64 0, i32 6
        %__59_310_5116_15728 = load double, ptr %__59_310_5116_15728_pointer_817, !noalias !2
        call ccc void @eraseObject(%Object %fields_808)
        
        %doubleLiteral_16610 = fadd double 0.5, 0.0
        
        %pureApp_16609 = call ccc double @infixMul_114(double %doubleLiteral_16610, double %x_11_262_5068_12517)
        
        
        
        %pureApp_16611 = call ccc double @infixMul_114(double %x_16_267_5073_11114, double %x_24_275_5081_11173)
        
        
        
        %pureApp_16612 = call ccc double @infixMul_114(double %x_33_284_5090_11652, double %x_41_292_5098_10581)
        
        
        
        %pureApp_16613 = call ccc double @infixAdd_111(double %pureApp_16611, double %pureApp_16612)
        
        
        
        %pureApp_16614 = call ccc double @infixMul_114(double %x_50_301_5107_12484, double %x_58_309_5115_12426)
        
        
        
        %pureApp_16615 = call ccc double @infixAdd_111(double %pureApp_16613, double %pureApp_16614)
        
        
        
        %pureApp_16616 = call ccc double @infixMul_114(double %pureApp_16609, double %pureApp_16615)
        
        
        
        %pureApp_16617 = call ccc double @infixAdd_111(double %v_r_3116_4_255_5061_11033, double %pureApp_16616)
        
        
        %stackPointer_1091 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %tmp_16403_pointer_1092 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1091, i64 0, i32 0
        store %Pos %tmp_16403, ptr %tmp_16403_pointer_1092, !noalias !2
        %i_6_251_5057_10640_pointer_1093 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1091, i64 0, i32 1
        store i64 %i_6_251_5057_10640, ptr %i_6_251_5057_10640_pointer_1093, !noalias !2
        %bodies_2361_12198_pointer_1094 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1091, i64 0, i32 2
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_1094, !noalias !2
        %tmp_16401_pointer_1095 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1091, i64 0, i32 3
        store i64 %tmp_16401, ptr %tmp_16401_pointer_1095, !noalias !2
        %e_3_4809_11809_pointer_1096 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1091, i64 0, i32 4
        store %Reference %e_3_4809_11809, ptr %e_3_4809_11809_pointer_1096, !noalias !2
        %returnAddress_pointer_1097 = getelementptr <{<{%Pos, i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1091, i64 0, i32 1, i32 0
        %sharer_pointer_1098 = getelementptr <{<{%Pos, i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1091, i64 0, i32 1, i32 1
        %eraser_pointer_1099 = getelementptr <{<{%Pos, i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1091, i64 0, i32 1, i32 2
        store ptr @returnAddress_818, ptr %returnAddress_pointer_1097, !noalias !2
        store ptr @sharer_1072, ptr %sharer_pointer_1098, !noalias !2
        store ptr @eraser_1084, ptr %eraser_pointer_1099, !noalias !2
        
        %e_3_4809_11809pointer_1100 = call ccc ptr @getVarPointer(%Reference %e_3_4809_11809, %Stack %stack)
        %e_3_4809_11809_old_1101 = load double, ptr %e_3_4809_11809pointer_1100, !noalias !2
        store double %pureApp_16617, ptr %e_3_4809_11809pointer_1100, !noalias !2
        
        %put_16642_temporary_1102 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_16642 = insertvalue %Pos %put_16642_temporary_1102, %Object null, 1
        
        %stackPointer_1104 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1105 = getelementptr %FrameHeader, %StackPointer %stackPointer_1104, i64 0, i32 0
        %returnAddress_1103 = load %ReturnAddress, ptr %returnAddress_pointer_1105, !noalias !2
        musttail call tailcc void %returnAddress_1103(%Pos %put_16642, %Stack %stack)
        ret void
    
    label_1107:
        %environment_799 = call ccc %Environment @objectEnvironment(%Object %fields_797)
        %__45_296_5102_15717_pointer_800 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_799, i64 0, i32 0
        %__45_296_5102_15717 = load double, ptr %__45_296_5102_15717_pointer_800, !noalias !2
        %__46_297_5103_15718_pointer_801 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_799, i64 0, i32 1
        %__46_297_5103_15718 = load double, ptr %__46_297_5103_15718_pointer_801, !noalias !2
        %__47_298_5104_15719_pointer_802 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_799, i64 0, i32 2
        %__47_298_5104_15719 = load double, ptr %__47_298_5104_15719_pointer_802, !noalias !2
        %__48_299_5105_15720_pointer_803 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_799, i64 0, i32 3
        %__48_299_5105_15720 = load double, ptr %__48_299_5105_15720_pointer_803, !noalias !2
        %__49_300_5106_15721_pointer_804 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_799, i64 0, i32 4
        %__49_300_5106_15721 = load double, ptr %__49_300_5106_15721_pointer_804, !noalias !2
        %x_50_301_5107_12484_pointer_805 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_799, i64 0, i32 5
        %x_50_301_5107_12484 = load double, ptr %x_50_301_5107_12484_pointer_805, !noalias !2
        %__51_302_5108_15722_pointer_806 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_799, i64 0, i32 6
        %__51_302_5108_15722 = load double, ptr %__51_302_5108_15722_pointer_806, !noalias !2
        call ccc void @eraseObject(%Object %fields_797)
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_807 = extractvalue %Pos %tmp_16403, 0
        %fields_808 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_807, label %label_809 [i64 0, label %label_1106]
    
    label_1108:
        %environment_788 = call ccc %Environment @objectEnvironment(%Object %fields_786)
        %__37_288_5094_15711_pointer_789 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_788, i64 0, i32 0
        %__37_288_5094_15711 = load double, ptr %__37_288_5094_15711_pointer_789, !noalias !2
        %__38_289_5095_15712_pointer_790 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_788, i64 0, i32 1
        %__38_289_5095_15712 = load double, ptr %__38_289_5095_15712_pointer_790, !noalias !2
        %__39_290_5096_15713_pointer_791 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_788, i64 0, i32 2
        %__39_290_5096_15713 = load double, ptr %__39_290_5096_15713_pointer_791, !noalias !2
        %__40_291_5097_15714_pointer_792 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_788, i64 0, i32 3
        %__40_291_5097_15714 = load double, ptr %__40_291_5097_15714_pointer_792, !noalias !2
        %x_41_292_5098_10581_pointer_793 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_788, i64 0, i32 4
        %x_41_292_5098_10581 = load double, ptr %x_41_292_5098_10581_pointer_793, !noalias !2
        %__42_293_5099_15715_pointer_794 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_788, i64 0, i32 5
        %__42_293_5099_15715 = load double, ptr %__42_293_5099_15715_pointer_794, !noalias !2
        %__43_294_5100_15716_pointer_795 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_788, i64 0, i32 6
        %__43_294_5100_15716 = load double, ptr %__43_294_5100_15716_pointer_795, !noalias !2
        call ccc void @eraseObject(%Object %fields_786)
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_796 = extractvalue %Pos %tmp_16403, 0
        %fields_797 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_796, label %label_798 [i64 0, label %label_1107]
    
    label_1109:
        %environment_777 = call ccc %Environment @objectEnvironment(%Object %fields_775)
        %__29_280_5086_15705_pointer_778 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_777, i64 0, i32 0
        %__29_280_5086_15705 = load double, ptr %__29_280_5086_15705_pointer_778, !noalias !2
        %__30_281_5087_15706_pointer_779 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_777, i64 0, i32 1
        %__30_281_5087_15706 = load double, ptr %__30_281_5087_15706_pointer_779, !noalias !2
        %__31_282_5088_15707_pointer_780 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_777, i64 0, i32 2
        %__31_282_5088_15707 = load double, ptr %__31_282_5088_15707_pointer_780, !noalias !2
        %__32_283_5089_15708_pointer_781 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_777, i64 0, i32 3
        %__32_283_5089_15708 = load double, ptr %__32_283_5089_15708_pointer_781, !noalias !2
        %x_33_284_5090_11652_pointer_782 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_777, i64 0, i32 4
        %x_33_284_5090_11652 = load double, ptr %x_33_284_5090_11652_pointer_782, !noalias !2
        %__34_285_5091_15709_pointer_783 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_777, i64 0, i32 5
        %__34_285_5091_15709 = load double, ptr %__34_285_5091_15709_pointer_783, !noalias !2
        %__35_286_5092_15710_pointer_784 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_777, i64 0, i32 6
        %__35_286_5092_15710 = load double, ptr %__35_286_5092_15710_pointer_784, !noalias !2
        call ccc void @eraseObject(%Object %fields_775)
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_785 = extractvalue %Pos %tmp_16403, 0
        %fields_786 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_785, label %label_787 [i64 0, label %label_1108]
    
    label_1110:
        %environment_766 = call ccc %Environment @objectEnvironment(%Object %fields_764)
        %__21_272_5078_15699_pointer_767 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_766, i64 0, i32 0
        %__21_272_5078_15699 = load double, ptr %__21_272_5078_15699_pointer_767, !noalias !2
        %__22_273_5079_15700_pointer_768 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_766, i64 0, i32 1
        %__22_273_5079_15700 = load double, ptr %__22_273_5079_15700_pointer_768, !noalias !2
        %__23_274_5080_15701_pointer_769 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_766, i64 0, i32 2
        %__23_274_5080_15701 = load double, ptr %__23_274_5080_15701_pointer_769, !noalias !2
        %x_24_275_5081_11173_pointer_770 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_766, i64 0, i32 3
        %x_24_275_5081_11173 = load double, ptr %x_24_275_5081_11173_pointer_770, !noalias !2
        %__25_276_5082_15702_pointer_771 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_766, i64 0, i32 4
        %__25_276_5082_15702 = load double, ptr %__25_276_5082_15702_pointer_771, !noalias !2
        %__26_277_5083_15703_pointer_772 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_766, i64 0, i32 5
        %__26_277_5083_15703 = load double, ptr %__26_277_5083_15703_pointer_772, !noalias !2
        %__27_278_5084_15704_pointer_773 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_766, i64 0, i32 6
        %__27_278_5084_15704 = load double, ptr %__27_278_5084_15704_pointer_773, !noalias !2
        call ccc void @eraseObject(%Object %fields_764)
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_774 = extractvalue %Pos %tmp_16403, 0
        %fields_775 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_774, label %label_776 [i64 0, label %label_1109]
    
    label_1111:
        %environment_755 = call ccc %Environment @objectEnvironment(%Object %fields_753)
        %__13_264_5070_15693_pointer_756 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_755, i64 0, i32 0
        %__13_264_5070_15693 = load double, ptr %__13_264_5070_15693_pointer_756, !noalias !2
        %__14_265_5071_15694_pointer_757 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_755, i64 0, i32 1
        %__14_265_5071_15694 = load double, ptr %__14_265_5071_15694_pointer_757, !noalias !2
        %__15_266_5072_15695_pointer_758 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_755, i64 0, i32 2
        %__15_266_5072_15695 = load double, ptr %__15_266_5072_15695_pointer_758, !noalias !2
        %x_16_267_5073_11114_pointer_759 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_755, i64 0, i32 3
        %x_16_267_5073_11114 = load double, ptr %x_16_267_5073_11114_pointer_759, !noalias !2
        %__17_268_5074_15696_pointer_760 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_755, i64 0, i32 4
        %__17_268_5074_15696 = load double, ptr %__17_268_5074_15696_pointer_760, !noalias !2
        %__18_269_5075_15697_pointer_761 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_755, i64 0, i32 5
        %__18_269_5075_15697 = load double, ptr %__18_269_5075_15697_pointer_761, !noalias !2
        %__19_270_5076_15698_pointer_762 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_755, i64 0, i32 6
        %__19_270_5076_15698 = load double, ptr %__19_270_5076_15698_pointer_762, !noalias !2
        call ccc void @eraseObject(%Object %fields_753)
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_763 = extractvalue %Pos %tmp_16403, 0
        %fields_764 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_763, label %label_765 [i64 0, label %label_1110]
    
    label_1112:
        %environment_744 = call ccc %Environment @objectEnvironment(%Object %fields_742)
        %__5_256_5062_15687_pointer_745 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_744, i64 0, i32 0
        %__5_256_5062_15687 = load double, ptr %__5_256_5062_15687_pointer_745, !noalias !2
        %__6_257_5063_15688_pointer_746 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_744, i64 0, i32 1
        %__6_257_5063_15688 = load double, ptr %__6_257_5063_15688_pointer_746, !noalias !2
        %__7_258_5064_15689_pointer_747 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_744, i64 0, i32 2
        %__7_258_5064_15689 = load double, ptr %__7_258_5064_15689_pointer_747, !noalias !2
        %__8_259_5065_15690_pointer_748 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_744, i64 0, i32 3
        %__8_259_5065_15690 = load double, ptr %__8_259_5065_15690_pointer_748, !noalias !2
        %__9_260_5066_15691_pointer_749 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_744, i64 0, i32 4
        %__9_260_5066_15691 = load double, ptr %__9_260_5066_15691_pointer_749, !noalias !2
        %__10_261_5067_15692_pointer_750 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_744, i64 0, i32 5
        %__10_261_5067_15692 = load double, ptr %__10_261_5067_15692_pointer_750, !noalias !2
        %x_11_262_5068_12517_pointer_751 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_744, i64 0, i32 6
        %x_11_262_5068_12517 = load double, ptr %x_11_262_5068_12517_pointer_751, !noalias !2
        call ccc void @eraseObject(%Object %fields_742)
        
        call ccc void @sharePositive(%Pos %tmp_16403)
        %tag_752 = extractvalue %Pos %tmp_16403, 0
        %fields_753 = extractvalue %Pos %tmp_16403, 1
        switch i64 %tag_752, label %label_754 [i64 0, label %label_1111]
}



define tailcc void @loop_5_250_5056_11393(i64 %i_6_251_5057_10640, %Pos %bodies_2361_12198, i64 %tmp_16401, %Reference %e_3_4809_11809, %Stack %stack) {
        
    entry:
        
        
        %pureApp_16606 = call ccc %Pos @infixLt_178(i64 %i_6_251_5057_10640, i64 %tmp_16401)
        
        
        
        %tag_726 = extractvalue %Pos %pureApp_16606, 0
        %fields_727 = extractvalue %Pos %pureApp_16606, 1
        switch i64 %tag_726, label %label_728 [i64 0, label %label_733 i64 1, label %label_1137]
    
    label_728:
        
        ret void
    
    label_733:
        call ccc void @erasePositive(%Pos %bodies_2361_12198)
        
        %unitLiteral_16607_temporary_729 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_16607 = insertvalue %Pos %unitLiteral_16607_temporary_729, %Object null, 1
        
        %stackPointer_731 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_732 = getelementptr %FrameHeader, %StackPointer %stackPointer_731, i64 0, i32 0
        %returnAddress_730 = load %ReturnAddress, ptr %returnAddress_pointer_732, !noalias !2
        musttail call tailcc void %returnAddress_730(%Pos %unitLiteral_16607, %Stack %stack)
        ret void
    
    label_1137:
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16608 = call ccc %Pos @unsafeGet_2487(%Pos %bodies_2361_12198, i64 %i_6_251_5057_10640)
        
        
        %stackPointer_1123 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %tmp_16403_pointer_1124 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1123, i64 0, i32 0
        store %Pos %pureApp_16608, ptr %tmp_16403_pointer_1124, !noalias !2
        %i_6_251_5057_10640_pointer_1125 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1123, i64 0, i32 1
        store i64 %i_6_251_5057_10640, ptr %i_6_251_5057_10640_pointer_1125, !noalias !2
        %bodies_2361_12198_pointer_1126 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1123, i64 0, i32 2
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_1126, !noalias !2
        %tmp_16401_pointer_1127 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1123, i64 0, i32 3
        store i64 %tmp_16401, ptr %tmp_16401_pointer_1127, !noalias !2
        %e_3_4809_11809_pointer_1128 = getelementptr <{%Pos, i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_1123, i64 0, i32 4
        store %Reference %e_3_4809_11809, ptr %e_3_4809_11809_pointer_1128, !noalias !2
        %returnAddress_pointer_1129 = getelementptr <{<{%Pos, i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1123, i64 0, i32 1, i32 0
        %sharer_pointer_1130 = getelementptr <{<{%Pos, i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1123, i64 0, i32 1, i32 1
        %eraser_pointer_1131 = getelementptr <{<{%Pos, i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1123, i64 0, i32 1, i32 2
        store ptr @returnAddress_734, ptr %returnAddress_pointer_1129, !noalias !2
        store ptr @sharer_1072, ptr %sharer_pointer_1130, !noalias !2
        store ptr @eraser_1084, ptr %eraser_pointer_1131, !noalias !2
        
        %get_16643_pointer_1132 = call ccc ptr @getVarPointer(%Reference %e_3_4809_11809, %Stack %stack)
        %e_3_4809_11809_old_1133 = load double, ptr %get_16643_pointer_1132, !noalias !2
        %get_16643 = load double, ptr %get_16643_pointer_1132, !noalias !2
        
        %stackPointer_1135 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1136 = getelementptr %FrameHeader, %StackPointer %stackPointer_1135, i64 0, i32 0
        %returnAddress_1134 = load %ReturnAddress, ptr %returnAddress_pointer_1136, !noalias !2
        musttail call tailcc void %returnAddress_1134(double %get_16643, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1138(%Pos %__498_5304_15828, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1139 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %e_3_4809_11809_pointer_1140 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1139, i64 0, i32 0
        %e_3_4809_11809 = load %Reference, ptr %e_3_4809_11809_pointer_1140, !noalias !2
        call ccc void @erasePositive(%Pos %__498_5304_15828)
        
        %get_16644_pointer_1141 = call ccc ptr @getVarPointer(%Reference %e_3_4809_11809, %Stack %stack)
        %e_3_4809_11809_old_1142 = load double, ptr %get_16644_pointer_1141, !noalias !2
        %get_16644 = load double, ptr %get_16644_pointer_1141, !noalias !2
        
        %stackPointer_1144 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1145 = getelementptr %FrameHeader, %StackPointer %stackPointer_1144, i64 0, i32 0
        %returnAddress_1143 = load %ReturnAddress, ptr %returnAddress_pointer_1145, !noalias !2
        musttail call tailcc void %returnAddress_1143(double %get_16644, %Stack %stack)
        ret void
}



define ccc void @sharer_1147(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1148 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %e_3_4809_11809_1146_pointer_1149 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1148, i64 0, i32 0
        %e_3_4809_11809_1146 = load %Reference, ptr %e_3_4809_11809_1146_pointer_1149, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1148)
        ret void
}



define ccc void @eraser_1151(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1152 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %e_3_4809_11809_1150_pointer_1153 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1152, i64 0, i32 0
        %e_3_4809_11809_1150 = load %Reference, ptr %e_3_4809_11809_1150_pointer_1153, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1152)
        ret void
}



define tailcc void @returnAddress_691(%Pos %v_r_3141_4807_15546, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_692 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %bodies_2361_12198_pointer_693 = getelementptr <{%Pos}>, %StackPointer %stackPointer_692, i64 0, i32 0
        %bodies_2361_12198 = load %Pos, ptr %bodies_2361_12198_pointer_693, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3141_4807_15546)
        
        %doubleLiteral_16601 = fadd double 0.0, 0.0
        
        
        %stackPointer_702 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_703 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_702, i64 0, i32 1, i32 0
        %sharer_pointer_704 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_702, i64 0, i32 1, i32 1
        %eraser_pointer_705 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_702, i64 0, i32 1, i32 2
        store ptr @returnAddress_694, ptr %returnAddress_pointer_703, !noalias !2
        store ptr @sharer_698, ptr %sharer_pointer_704, !noalias !2
        store ptr @eraser_700, ptr %eraser_pointer_705, !noalias !2
        %e_3_4809_11809 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_721 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_3114_2_4808_11101_pointer_722 = getelementptr <{double}>, %StackPointer %stackPointer_721, i64 0, i32 0
        store double %doubleLiteral_16601, ptr %v_r_3114_2_4808_11101_pointer_722, !noalias !2
        %returnAddress_pointer_723 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_721, i64 0, i32 1, i32 0
        %sharer_pointer_724 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_721, i64 0, i32 1, i32 1
        %eraser_pointer_725 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_721, i64 0, i32 1, i32 2
        store ptr @returnAddress_706, ptr %returnAddress_pointer_723, !noalias !2
        store ptr @sharer_714, ptr %sharer_pointer_724, !noalias !2
        store ptr @eraser_718, ptr %eraser_pointer_725, !noalias !2
        
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %pureApp_16605 = call ccc i64 @size_2483(%Pos %bodies_2361_12198)
        
        
        %stackPointer_1154 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %e_3_4809_11809_pointer_1155 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1154, i64 0, i32 0
        store %Reference %e_3_4809_11809, ptr %e_3_4809_11809_pointer_1155, !noalias !2
        %returnAddress_pointer_1156 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1154, i64 0, i32 1, i32 0
        %sharer_pointer_1157 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1154, i64 0, i32 1, i32 1
        %eraser_pointer_1158 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1154, i64 0, i32 1, i32 2
        store ptr @returnAddress_1138, ptr %returnAddress_pointer_1156, !noalias !2
        store ptr @sharer_1147, ptr %sharer_pointer_1157, !noalias !2
        store ptr @eraser_1151, ptr %eraser_pointer_1158, !noalias !2
        
        %longLiteral_16645 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_250_5056_11393(i64 %longLiteral_16645, %Pos %bodies_2361_12198, i64 %pureApp_16605, %Reference %e_3_4809_11809, %Stack %stack)
        ret void
}



define ccc void @sharer_1160(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1161 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %bodies_2361_12198_1159_pointer_1162 = getelementptr <{%Pos}>, %StackPointer %stackPointer_1161, i64 0, i32 0
        %bodies_2361_12198_1159 = load %Pos, ptr %bodies_2361_12198_1159_pointer_1162, !noalias !2
        call ccc void @sharePositive(%Pos %bodies_2361_12198_1159)
        call ccc void @shareFrames(%StackPointer %stackPointer_1161)
        ret void
}



define ccc void @eraser_1164(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1165 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %bodies_2361_12198_1163_pointer_1166 = getelementptr <{%Pos}>, %StackPointer %stackPointer_1165, i64 0, i32 0
        %bodies_2361_12198_1163 = load %Pos, ptr %bodies_2361_12198_1163_pointer_1166, !noalias !2
        call ccc void @erasePositive(%Pos %bodies_2361_12198_1163)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1165)
        ret void
}



define tailcc void @returnAddress_95(%Pos %bodies_2361_12198, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_96 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_16435_pointer_97 = getelementptr <{i64}>, %StackPointer %stackPointer_96, i64 0, i32 0
        %tmp_16435 = load i64, ptr %tmp_16435_pointer_97, !noalias !2
        call ccc void @sharePositive(%Pos %bodies_2361_12198)
        %stackPointer_1167 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %bodies_2361_12198_pointer_1168 = getelementptr <{%Pos}>, %StackPointer %stackPointer_1167, i64 0, i32 0
        store %Pos %bodies_2361_12198, ptr %bodies_2361_12198_pointer_1168, !noalias !2
        %returnAddress_pointer_1169 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1167, i64 0, i32 1, i32 0
        %sharer_pointer_1170 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1167, i64 0, i32 1, i32 1
        %eraser_pointer_1171 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1167, i64 0, i32 1, i32 2
        store ptr @returnAddress_691, ptr %returnAddress_pointer_1169, !noalias !2
        store ptr @sharer_1160, ptr %sharer_pointer_1170, !noalias !2
        store ptr @eraser_1164, ptr %eraser_pointer_1171, !noalias !2
        
        %longLiteral_16646 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_3583_12010(i64 %longLiteral_16646, i64 %tmp_16435, %Pos %bodies_2361_12198, %Stack %stack)
        ret void
}



define ccc void @sharer_1173(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1174 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_16435_1172_pointer_1175 = getelementptr <{i64}>, %StackPointer %stackPointer_1174, i64 0, i32 0
        %tmp_16435_1172 = load i64, ptr %tmp_16435_1172_pointer_1175, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1174)
        ret void
}



define ccc void @eraser_1177(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1178 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_16435_1176_pointer_1179 = getelementptr <{i64}>, %StackPointer %stackPointer_1178, i64 0, i32 0
        %tmp_16435_1176 = load i64, ptr %tmp_16435_1176_pointer_1179, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1178)
        ret void
}



define tailcc void @returnAddress_1185(%Pos %returnValue_1186, %Stack %stack) {
        
    entry:
        
        %stackPointer_1187 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_3045_8_2076_10770_pointer_1188 = getelementptr <{double}>, %StackPointer %stackPointer_1187, i64 0, i32 0
        %v_r_3045_8_2076_10770 = load double, ptr %v_r_3045_8_2076_10770_pointer_1188, !noalias !2
        %stackPointer_1190 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1191 = getelementptr %FrameHeader, %StackPointer %stackPointer_1190, i64 0, i32 0
        %returnAddress_1189 = load %ReturnAddress, ptr %returnAddress_pointer_1191, !noalias !2
        musttail call tailcc void %returnAddress_1189(%Pos %returnValue_1186, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1199(%Pos %returnValue_1200, %Stack %stack) {
        
    entry:
        
        %stackPointer_1201 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_3046_10_2078_11690_pointer_1202 = getelementptr <{double}>, %StackPointer %stackPointer_1201, i64 0, i32 0
        %v_r_3046_10_2078_11690 = load double, ptr %v_r_3046_10_2078_11690_pointer_1202, !noalias !2
        %stackPointer_1204 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1205 = getelementptr %FrameHeader, %StackPointer %stackPointer_1204, i64 0, i32 0
        %returnAddress_1203 = load %ReturnAddress, ptr %returnAddress_pointer_1205, !noalias !2
        musttail call tailcc void %returnAddress_1203(%Pos %returnValue_1200, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1213(%Pos %returnValue_1214, %Stack %stack) {
        
    entry:
        
        %stackPointer_1215 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_3047_12_2080_10680_pointer_1216 = getelementptr <{double}>, %StackPointer %stackPointer_1215, i64 0, i32 0
        %v_r_3047_12_2080_10680 = load double, ptr %v_r_3047_12_2080_10680_pointer_1216, !noalias !2
        %stackPointer_1218 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1219 = getelementptr %FrameHeader, %StackPointer %stackPointer_1218, i64 0, i32 0
        %returnAddress_1217 = load %ReturnAddress, ptr %returnAddress_pointer_1219, !noalias !2
        musttail call tailcc void %returnAddress_1217(%Pos %returnValue_1214, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1346(%Pos %__8_13_201_2269_13987, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1347 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 80)
        %tmp_16320_pointer_1348 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1347, i64 0, i32 0
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1348, !noalias !2
        %py_11_2079_10749_pointer_1349 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1347, i64 0, i32 1
        %py_11_2079_10749 = load %Reference, ptr %py_11_2079_10749_pointer_1349, !noalias !2
        %pz_13_2081_11683_pointer_1350 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1347, i64 0, i32 2
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1350, !noalias !2
        %tmp_16326_pointer_1351 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1347, i64 0, i32 3
        %tmp_16326 = load i64, ptr %tmp_16326_pointer_1351, !noalias !2
        %px_9_2077_11716_pointer_1352 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1347, i64 0, i32 4
        %px_9_2077_11716 = load %Reference, ptr %px_9_2077_11716_pointer_1352, !noalias !2
        %i_6_10_139_2207_11222_pointer_1353 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1347, i64 0, i32 5
        %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1353, !noalias !2
        call ccc void @erasePositive(%Pos %__8_13_201_2269_13987)
        
        %longLiteral_16663 = add i64 1, 0
        
        %pureApp_16662 = call ccc i64 @infixAdd_96(i64 %i_6_10_139_2207_11222, i64 %longLiteral_16663)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_138_2206_10607(i64 %pureApp_16662, %Pos %tmp_16320, %Reference %py_11_2079_10749, %Reference %pz_13_2081_11683, i64 %tmp_16326, %Reference %px_9_2077_11716, %Stack %stack)
        ret void
}



define ccc void @sharer_1360(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1361 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_16320_1354_pointer_1362 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1361, i64 0, i32 0
        %tmp_16320_1354 = load %Pos, ptr %tmp_16320_1354_pointer_1362, !noalias !2
        %py_11_2079_10749_1355_pointer_1363 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1361, i64 0, i32 1
        %py_11_2079_10749_1355 = load %Reference, ptr %py_11_2079_10749_1355_pointer_1363, !noalias !2
        %pz_13_2081_11683_1356_pointer_1364 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1361, i64 0, i32 2
        %pz_13_2081_11683_1356 = load %Reference, ptr %pz_13_2081_11683_1356_pointer_1364, !noalias !2
        %tmp_16326_1357_pointer_1365 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1361, i64 0, i32 3
        %tmp_16326_1357 = load i64, ptr %tmp_16326_1357_pointer_1365, !noalias !2
        %px_9_2077_11716_1358_pointer_1366 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1361, i64 0, i32 4
        %px_9_2077_11716_1358 = load %Reference, ptr %px_9_2077_11716_1358_pointer_1366, !noalias !2
        %i_6_10_139_2207_11222_1359_pointer_1367 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1361, i64 0, i32 5
        %i_6_10_139_2207_11222_1359 = load i64, ptr %i_6_10_139_2207_11222_1359_pointer_1367, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16320_1354)
        call ccc void @shareFrames(%StackPointer %stackPointer_1361)
        ret void
}



define ccc void @eraser_1374(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1375 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_16320_1368_pointer_1376 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1375, i64 0, i32 0
        %tmp_16320_1368 = load %Pos, ptr %tmp_16320_1368_pointer_1376, !noalias !2
        %py_11_2079_10749_1369_pointer_1377 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1375, i64 0, i32 1
        %py_11_2079_10749_1369 = load %Reference, ptr %py_11_2079_10749_1369_pointer_1377, !noalias !2
        %pz_13_2081_11683_1370_pointer_1378 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1375, i64 0, i32 2
        %pz_13_2081_11683_1370 = load %Reference, ptr %pz_13_2081_11683_1370_pointer_1378, !noalias !2
        %tmp_16326_1371_pointer_1379 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1375, i64 0, i32 3
        %tmp_16326_1371 = load i64, ptr %tmp_16326_1371_pointer_1379, !noalias !2
        %px_9_2077_11716_1372_pointer_1380 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1375, i64 0, i32 4
        %px_9_2077_11716_1372 = load %Reference, ptr %px_9_2077_11716_1372_pointer_1380, !noalias !2
        %i_6_10_139_2207_11222_1373_pointer_1381 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1375, i64 0, i32 5
        %i_6_10_139_2207_11222_1373 = load i64, ptr %i_6_10_139_2207_11222_1373_pointer_1381, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16320_1368)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1375)
        ret void
}



define tailcc void @returnAddress_1315(double %v_r_3056_42_182_2250_10552, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1316 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %tmp_16320_pointer_1317 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1316, i64 0, i32 0
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1317, !noalias !2
        %py_11_2079_10749_pointer_1318 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1316, i64 0, i32 1
        %py_11_2079_10749 = load %Reference, ptr %py_11_2079_10749_pointer_1318, !noalias !2
        %pz_13_2081_11683_pointer_1319 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1316, i64 0, i32 2
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1319, !noalias !2
        %tmp_16326_pointer_1320 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1316, i64 0, i32 3
        %tmp_16326 = load i64, ptr %tmp_16326_pointer_1320, !noalias !2
        %px_9_2077_11716_pointer_1321 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1316, i64 0, i32 4
        %px_9_2077_11716 = load %Reference, ptr %px_9_2077_11716_pointer_1321, !noalias !2
        %tmp_16328_pointer_1322 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1316, i64 0, i32 5
        %tmp_16328 = load %Pos, ptr %tmp_16328_pointer_1322, !noalias !2
        %i_6_10_139_2207_11222_pointer_1323 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1316, i64 0, i32 6
        %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1323, !noalias !2
        
        call ccc void @sharePositive(%Pos %tmp_16328)
        %tag_1324 = extractvalue %Pos %tmp_16328, 0
        %fields_1325 = extractvalue %Pos %tmp_16328, 1
        switch i64 %tag_1324, label %label_1326 [i64 0, label %label_1399]
    
    label_1326:
        
        ret void
    
    label_1337:
        
        ret void
    
    label_1398:
        %environment_1338 = call ccc %Environment @objectEnvironment(%Object %fields_1336)
        %__51_191_2259_13981_pointer_1339 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1338, i64 0, i32 0
        %__51_191_2259_13981 = load double, ptr %__51_191_2259_13981_pointer_1339, !noalias !2
        %__52_192_2260_13982_pointer_1340 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1338, i64 0, i32 1
        %__52_192_2260_13982 = load double, ptr %__52_192_2260_13982_pointer_1340, !noalias !2
        %__53_193_2261_13983_pointer_1341 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1338, i64 0, i32 2
        %__53_193_2261_13983 = load double, ptr %__53_193_2261_13983_pointer_1341, !noalias !2
        %__54_194_2262_13984_pointer_1342 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1338, i64 0, i32 3
        %__54_194_2262_13984 = load double, ptr %__54_194_2262_13984_pointer_1342, !noalias !2
        %__55_195_2263_13985_pointer_1343 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1338, i64 0, i32 4
        %__55_195_2263_13985 = load double, ptr %__55_195_2263_13985_pointer_1343, !noalias !2
        %__56_196_2264_13986_pointer_1344 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1338, i64 0, i32 5
        %__56_196_2264_13986 = load double, ptr %__56_196_2264_13986_pointer_1344, !noalias !2
        %x_57_197_2265_12411_pointer_1345 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1338, i64 0, i32 6
        %x_57_197_2265_12411 = load double, ptr %x_57_197_2265_12411_pointer_1345, !noalias !2
        call ccc void @eraseObject(%Object %fields_1336)
        
        %pureApp_16660 = call ccc double @infixMul_114(double %x_48_188_2256_12440, double %x_57_197_2265_12411)
        
        
        
        %pureApp_16661 = call ccc double @infixAdd_111(double %v_r_3056_42_182_2250_10552, double %pureApp_16660)
        
        
        %stackPointer_1382 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 104)
        %tmp_16320_pointer_1383 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1382, i64 0, i32 0
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1383, !noalias !2
        %py_11_2079_10749_pointer_1384 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1382, i64 0, i32 1
        store %Reference %py_11_2079_10749, ptr %py_11_2079_10749_pointer_1384, !noalias !2
        %pz_13_2081_11683_pointer_1385 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1382, i64 0, i32 2
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1385, !noalias !2
        %tmp_16326_pointer_1386 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1382, i64 0, i32 3
        store i64 %tmp_16326, ptr %tmp_16326_pointer_1386, !noalias !2
        %px_9_2077_11716_pointer_1387 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1382, i64 0, i32 4
        store %Reference %px_9_2077_11716, ptr %px_9_2077_11716_pointer_1387, !noalias !2
        %i_6_10_139_2207_11222_pointer_1388 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %StackPointer %stackPointer_1382, i64 0, i32 5
        store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1388, !noalias !2
        %returnAddress_pointer_1389 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1382, i64 0, i32 1, i32 0
        %sharer_pointer_1390 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1382, i64 0, i32 1, i32 1
        %eraser_pointer_1391 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1382, i64 0, i32 1, i32 2
        store ptr @returnAddress_1346, ptr %returnAddress_pointer_1389, !noalias !2
        store ptr @sharer_1360, ptr %sharer_pointer_1390, !noalias !2
        store ptr @eraser_1374, ptr %eraser_pointer_1391, !noalias !2
        
        %pz_13_2081_11683pointer_1392 = call ccc ptr @getVarPointer(%Reference %pz_13_2081_11683, %Stack %stack)
        %pz_13_2081_11683_old_1393 = load double, ptr %pz_13_2081_11683pointer_1392, !noalias !2
        store double %pureApp_16661, ptr %pz_13_2081_11683pointer_1392, !noalias !2
        
        %put_16664_temporary_1394 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_16664 = insertvalue %Pos %put_16664_temporary_1394, %Object null, 1
        
        %stackPointer_1396 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1397 = getelementptr %FrameHeader, %StackPointer %stackPointer_1396, i64 0, i32 0
        %returnAddress_1395 = load %ReturnAddress, ptr %returnAddress_pointer_1397, !noalias !2
        musttail call tailcc void %returnAddress_1395(%Pos %put_16664, %Stack %stack)
        ret void
    
    label_1399:
        %environment_1327 = call ccc %Environment @objectEnvironment(%Object %fields_1325)
        %__43_183_2251_13975_pointer_1328 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1327, i64 0, i32 0
        %__43_183_2251_13975 = load double, ptr %__43_183_2251_13975_pointer_1328, !noalias !2
        %__44_184_2252_13976_pointer_1329 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1327, i64 0, i32 1
        %__44_184_2252_13976 = load double, ptr %__44_184_2252_13976_pointer_1329, !noalias !2
        %__45_185_2253_13977_pointer_1330 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1327, i64 0, i32 2
        %__45_185_2253_13977 = load double, ptr %__45_185_2253_13977_pointer_1330, !noalias !2
        %__46_186_2254_13978_pointer_1331 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1327, i64 0, i32 3
        %__46_186_2254_13978 = load double, ptr %__46_186_2254_13978_pointer_1331, !noalias !2
        %__47_187_2255_13979_pointer_1332 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1327, i64 0, i32 4
        %__47_187_2255_13979 = load double, ptr %__47_187_2255_13979_pointer_1332, !noalias !2
        %x_48_188_2256_12440_pointer_1333 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1327, i64 0, i32 5
        %x_48_188_2256_12440 = load double, ptr %x_48_188_2256_12440_pointer_1333, !noalias !2
        %__49_189_2257_13980_pointer_1334 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1327, i64 0, i32 6
        %__49_189_2257_13980 = load double, ptr %__49_189_2257_13980_pointer_1334, !noalias !2
        call ccc void @eraseObject(%Object %fields_1325)
        
        %tag_1335 = extractvalue %Pos %tmp_16328, 0
        %fields_1336 = extractvalue %Pos %tmp_16328, 1
        switch i64 %tag_1335, label %label_1337 [i64 0, label %label_1398]
}



define ccc void @sharer_1407(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1408 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_16320_1400_pointer_1409 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1408, i64 0, i32 0
        %tmp_16320_1400 = load %Pos, ptr %tmp_16320_1400_pointer_1409, !noalias !2
        %py_11_2079_10749_1401_pointer_1410 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1408, i64 0, i32 1
        %py_11_2079_10749_1401 = load %Reference, ptr %py_11_2079_10749_1401_pointer_1410, !noalias !2
        %pz_13_2081_11683_1402_pointer_1411 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1408, i64 0, i32 2
        %pz_13_2081_11683_1402 = load %Reference, ptr %pz_13_2081_11683_1402_pointer_1411, !noalias !2
        %tmp_16326_1403_pointer_1412 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1408, i64 0, i32 3
        %tmp_16326_1403 = load i64, ptr %tmp_16326_1403_pointer_1412, !noalias !2
        %px_9_2077_11716_1404_pointer_1413 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1408, i64 0, i32 4
        %px_9_2077_11716_1404 = load %Reference, ptr %px_9_2077_11716_1404_pointer_1413, !noalias !2
        %tmp_16328_1405_pointer_1414 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1408, i64 0, i32 5
        %tmp_16328_1405 = load %Pos, ptr %tmp_16328_1405_pointer_1414, !noalias !2
        %i_6_10_139_2207_11222_1406_pointer_1415 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1408, i64 0, i32 6
        %i_6_10_139_2207_11222_1406 = load i64, ptr %i_6_10_139_2207_11222_1406_pointer_1415, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16320_1400)
        call ccc void @sharePositive(%Pos %tmp_16328_1405)
        call ccc void @shareFrames(%StackPointer %stackPointer_1408)
        ret void
}



define ccc void @eraser_1423(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1424 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_16320_1416_pointer_1425 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 0
        %tmp_16320_1416 = load %Pos, ptr %tmp_16320_1416_pointer_1425, !noalias !2
        %py_11_2079_10749_1417_pointer_1426 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 1
        %py_11_2079_10749_1417 = load %Reference, ptr %py_11_2079_10749_1417_pointer_1426, !noalias !2
        %pz_13_2081_11683_1418_pointer_1427 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 2
        %pz_13_2081_11683_1418 = load %Reference, ptr %pz_13_2081_11683_1418_pointer_1427, !noalias !2
        %tmp_16326_1419_pointer_1428 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 3
        %tmp_16326_1419 = load i64, ptr %tmp_16326_1419_pointer_1428, !noalias !2
        %px_9_2077_11716_1420_pointer_1429 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 4
        %px_9_2077_11716_1420 = load %Reference, ptr %px_9_2077_11716_1420_pointer_1429, !noalias !2
        %tmp_16328_1421_pointer_1430 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 5
        %tmp_16328_1421 = load %Pos, ptr %tmp_16328_1421_pointer_1430, !noalias !2
        %i_6_10_139_2207_11222_1422_pointer_1431 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 6
        %i_6_10_139_2207_11222_1422 = load i64, ptr %i_6_10_139_2207_11222_1422_pointer_1431, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16320_1416)
        call ccc void @erasePositive(%Pos %tmp_16328_1421)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1424)
        ret void
}



define tailcc void @returnAddress_1306(%Pos %__41_181_2249_13974, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1307 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %tmp_16320_pointer_1308 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1307, i64 0, i32 0
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1308, !noalias !2
        %py_11_2079_10749_pointer_1309 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1307, i64 0, i32 1
        %py_11_2079_10749 = load %Reference, ptr %py_11_2079_10749_pointer_1309, !noalias !2
        %pz_13_2081_11683_pointer_1310 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1307, i64 0, i32 2
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1310, !noalias !2
        %tmp_16326_pointer_1311 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1307, i64 0, i32 3
        %tmp_16326 = load i64, ptr %tmp_16326_pointer_1311, !noalias !2
        %px_9_2077_11716_pointer_1312 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1307, i64 0, i32 4
        %px_9_2077_11716 = load %Reference, ptr %px_9_2077_11716_pointer_1312, !noalias !2
        %tmp_16328_pointer_1313 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1307, i64 0, i32 5
        %tmp_16328 = load %Pos, ptr %tmp_16328_pointer_1313, !noalias !2
        %i_6_10_139_2207_11222_pointer_1314 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1307, i64 0, i32 6
        %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1314, !noalias !2
        call ccc void @erasePositive(%Pos %__41_181_2249_13974)
        %stackPointer_1432 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %tmp_16320_pointer_1433 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1432, i64 0, i32 0
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1433, !noalias !2
        %py_11_2079_10749_pointer_1434 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1432, i64 0, i32 1
        store %Reference %py_11_2079_10749, ptr %py_11_2079_10749_pointer_1434, !noalias !2
        %pz_13_2081_11683_pointer_1435 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1432, i64 0, i32 2
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1435, !noalias !2
        %tmp_16326_pointer_1436 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1432, i64 0, i32 3
        store i64 %tmp_16326, ptr %tmp_16326_pointer_1436, !noalias !2
        %px_9_2077_11716_pointer_1437 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1432, i64 0, i32 4
        store %Reference %px_9_2077_11716, ptr %px_9_2077_11716_pointer_1437, !noalias !2
        %tmp_16328_pointer_1438 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1432, i64 0, i32 5
        store %Pos %tmp_16328, ptr %tmp_16328_pointer_1438, !noalias !2
        %i_6_10_139_2207_11222_pointer_1439 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1432, i64 0, i32 6
        store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1439, !noalias !2
        %returnAddress_pointer_1440 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1432, i64 0, i32 1, i32 0
        %sharer_pointer_1441 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1432, i64 0, i32 1, i32 1
        %eraser_pointer_1442 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1432, i64 0, i32 1, i32 2
        store ptr @returnAddress_1315, ptr %returnAddress_pointer_1440, !noalias !2
        store ptr @sharer_1407, ptr %sharer_pointer_1441, !noalias !2
        store ptr @eraser_1423, ptr %eraser_pointer_1442, !noalias !2
        
        %get_16665_pointer_1443 = call ccc ptr @getVarPointer(%Reference %pz_13_2081_11683, %Stack %stack)
        %pz_13_2081_11683_old_1444 = load double, ptr %get_16665_pointer_1443, !noalias !2
        %get_16665 = load double, ptr %get_16665_pointer_1443, !noalias !2
        
        %stackPointer_1446 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1447 = getelementptr %FrameHeader, %StackPointer %stackPointer_1446, i64 0, i32 0
        %returnAddress_1445 = load %ReturnAddress, ptr %returnAddress_pointer_1447, !noalias !2
        musttail call tailcc void %returnAddress_1445(double %get_16665, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1275(double %v_r_3052_22_162_2230_12555, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1276 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %tmp_16320_pointer_1277 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1276, i64 0, i32 0
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1277, !noalias !2
        %py_11_2079_10749_pointer_1278 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1276, i64 0, i32 1
        %py_11_2079_10749 = load %Reference, ptr %py_11_2079_10749_pointer_1278, !noalias !2
        %pz_13_2081_11683_pointer_1279 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1276, i64 0, i32 2
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1279, !noalias !2
        %tmp_16326_pointer_1280 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1276, i64 0, i32 3
        %tmp_16326 = load i64, ptr %tmp_16326_pointer_1280, !noalias !2
        %px_9_2077_11716_pointer_1281 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1276, i64 0, i32 4
        %px_9_2077_11716 = load %Reference, ptr %px_9_2077_11716_pointer_1281, !noalias !2
        %tmp_16328_pointer_1282 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1276, i64 0, i32 5
        %tmp_16328 = load %Pos, ptr %tmp_16328_pointer_1282, !noalias !2
        %i_6_10_139_2207_11222_pointer_1283 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1276, i64 0, i32 6
        %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1283, !noalias !2
        
        call ccc void @sharePositive(%Pos %tmp_16328)
        %tag_1284 = extractvalue %Pos %tmp_16328, 0
        %fields_1285 = extractvalue %Pos %tmp_16328, 1
        switch i64 %tag_1284, label %label_1286 [i64 0, label %label_1480]
    
    label_1286:
        
        ret void
    
    label_1297:
        
        ret void
    
    label_1479:
        %environment_1298 = call ccc %Environment @objectEnvironment(%Object %fields_1296)
        %__31_171_2239_13968_pointer_1299 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1298, i64 0, i32 0
        %__31_171_2239_13968 = load double, ptr %__31_171_2239_13968_pointer_1299, !noalias !2
        %__32_172_2240_13969_pointer_1300 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1298, i64 0, i32 1
        %__32_172_2240_13969 = load double, ptr %__32_172_2240_13969_pointer_1300, !noalias !2
        %__33_173_2241_13970_pointer_1301 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1298, i64 0, i32 2
        %__33_173_2241_13970 = load double, ptr %__33_173_2241_13970_pointer_1301, !noalias !2
        %__34_174_2242_13971_pointer_1302 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1298, i64 0, i32 3
        %__34_174_2242_13971 = load double, ptr %__34_174_2242_13971_pointer_1302, !noalias !2
        %__35_175_2243_13972_pointer_1303 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1298, i64 0, i32 4
        %__35_175_2243_13972 = load double, ptr %__35_175_2243_13972_pointer_1303, !noalias !2
        %__36_176_2244_13973_pointer_1304 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1298, i64 0, i32 5
        %__36_176_2244_13973 = load double, ptr %__36_176_2244_13973_pointer_1304, !noalias !2
        %x_37_177_2245_12311_pointer_1305 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1298, i64 0, i32 6
        %x_37_177_2245_12311 = load double, ptr %x_37_177_2245_12311_pointer_1305, !noalias !2
        call ccc void @eraseObject(%Object %fields_1296)
        
        %pureApp_16658 = call ccc double @infixMul_114(double %x_27_167_2235_11547, double %x_37_177_2245_12311)
        
        
        
        %pureApp_16659 = call ccc double @infixAdd_111(double %v_r_3052_22_162_2230_12555, double %pureApp_16658)
        
        
        %stackPointer_1462 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %tmp_16320_pointer_1463 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1462, i64 0, i32 0
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1463, !noalias !2
        %py_11_2079_10749_pointer_1464 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1462, i64 0, i32 1
        store %Reference %py_11_2079_10749, ptr %py_11_2079_10749_pointer_1464, !noalias !2
        %pz_13_2081_11683_pointer_1465 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1462, i64 0, i32 2
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1465, !noalias !2
        %tmp_16326_pointer_1466 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1462, i64 0, i32 3
        store i64 %tmp_16326, ptr %tmp_16326_pointer_1466, !noalias !2
        %px_9_2077_11716_pointer_1467 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1462, i64 0, i32 4
        store %Reference %px_9_2077_11716, ptr %px_9_2077_11716_pointer_1467, !noalias !2
        %tmp_16328_pointer_1468 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1462, i64 0, i32 5
        store %Pos %tmp_16328, ptr %tmp_16328_pointer_1468, !noalias !2
        %i_6_10_139_2207_11222_pointer_1469 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1462, i64 0, i32 6
        store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1469, !noalias !2
        %returnAddress_pointer_1470 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1462, i64 0, i32 1, i32 0
        %sharer_pointer_1471 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1462, i64 0, i32 1, i32 1
        %eraser_pointer_1472 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1462, i64 0, i32 1, i32 2
        store ptr @returnAddress_1306, ptr %returnAddress_pointer_1470, !noalias !2
        store ptr @sharer_1407, ptr %sharer_pointer_1471, !noalias !2
        store ptr @eraser_1423, ptr %eraser_pointer_1472, !noalias !2
        
        %py_11_2079_10749pointer_1473 = call ccc ptr @getVarPointer(%Reference %py_11_2079_10749, %Stack %stack)
        %py_11_2079_10749_old_1474 = load double, ptr %py_11_2079_10749pointer_1473, !noalias !2
        store double %pureApp_16659, ptr %py_11_2079_10749pointer_1473, !noalias !2
        
        %put_16666_temporary_1475 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_16666 = insertvalue %Pos %put_16666_temporary_1475, %Object null, 1
        
        %stackPointer_1477 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1478 = getelementptr %FrameHeader, %StackPointer %stackPointer_1477, i64 0, i32 0
        %returnAddress_1476 = load %ReturnAddress, ptr %returnAddress_pointer_1478, !noalias !2
        musttail call tailcc void %returnAddress_1476(%Pos %put_16666, %Stack %stack)
        ret void
    
    label_1480:
        %environment_1287 = call ccc %Environment @objectEnvironment(%Object %fields_1285)
        %__23_163_2231_13962_pointer_1288 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1287, i64 0, i32 0
        %__23_163_2231_13962 = load double, ptr %__23_163_2231_13962_pointer_1288, !noalias !2
        %__24_164_2232_13963_pointer_1289 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1287, i64 0, i32 1
        %__24_164_2232_13963 = load double, ptr %__24_164_2232_13963_pointer_1289, !noalias !2
        %__25_165_2233_13964_pointer_1290 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1287, i64 0, i32 2
        %__25_165_2233_13964 = load double, ptr %__25_165_2233_13964_pointer_1290, !noalias !2
        %__26_166_2234_13965_pointer_1291 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1287, i64 0, i32 3
        %__26_166_2234_13965 = load double, ptr %__26_166_2234_13965_pointer_1291, !noalias !2
        %x_27_167_2235_11547_pointer_1292 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1287, i64 0, i32 4
        %x_27_167_2235_11547 = load double, ptr %x_27_167_2235_11547_pointer_1292, !noalias !2
        %__28_168_2236_13966_pointer_1293 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1287, i64 0, i32 5
        %__28_168_2236_13966 = load double, ptr %__28_168_2236_13966_pointer_1293, !noalias !2
        %__29_169_2237_13967_pointer_1294 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1287, i64 0, i32 6
        %__29_169_2237_13967 = load double, ptr %__29_169_2237_13967_pointer_1294, !noalias !2
        call ccc void @eraseObject(%Object %fields_1285)
        
        call ccc void @sharePositive(%Pos %tmp_16328)
        %tag_1295 = extractvalue %Pos %tmp_16328, 0
        %fields_1296 = extractvalue %Pos %tmp_16328, 1
        switch i64 %tag_1295, label %label_1297 [i64 0, label %label_1479]
}



define tailcc void @returnAddress_1266(%Pos %__21_161_2229_13961, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1267 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %tmp_16320_pointer_1268 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1267, i64 0, i32 0
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1268, !noalias !2
        %py_11_2079_10749_pointer_1269 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1267, i64 0, i32 1
        %py_11_2079_10749 = load %Reference, ptr %py_11_2079_10749_pointer_1269, !noalias !2
        %pz_13_2081_11683_pointer_1270 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1267, i64 0, i32 2
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1270, !noalias !2
        %tmp_16326_pointer_1271 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1267, i64 0, i32 3
        %tmp_16326 = load i64, ptr %tmp_16326_pointer_1271, !noalias !2
        %px_9_2077_11716_pointer_1272 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1267, i64 0, i32 4
        %px_9_2077_11716 = load %Reference, ptr %px_9_2077_11716_pointer_1272, !noalias !2
        %tmp_16328_pointer_1273 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1267, i64 0, i32 5
        %tmp_16328 = load %Pos, ptr %tmp_16328_pointer_1273, !noalias !2
        %i_6_10_139_2207_11222_pointer_1274 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1267, i64 0, i32 6
        %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1274, !noalias !2
        call ccc void @erasePositive(%Pos %__21_161_2229_13961)
        %stackPointer_1495 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %tmp_16320_pointer_1496 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1495, i64 0, i32 0
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1496, !noalias !2
        %py_11_2079_10749_pointer_1497 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1495, i64 0, i32 1
        store %Reference %py_11_2079_10749, ptr %py_11_2079_10749_pointer_1497, !noalias !2
        %pz_13_2081_11683_pointer_1498 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1495, i64 0, i32 2
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1498, !noalias !2
        %tmp_16326_pointer_1499 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1495, i64 0, i32 3
        store i64 %tmp_16326, ptr %tmp_16326_pointer_1499, !noalias !2
        %px_9_2077_11716_pointer_1500 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1495, i64 0, i32 4
        store %Reference %px_9_2077_11716, ptr %px_9_2077_11716_pointer_1500, !noalias !2
        %tmp_16328_pointer_1501 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1495, i64 0, i32 5
        store %Pos %tmp_16328, ptr %tmp_16328_pointer_1501, !noalias !2
        %i_6_10_139_2207_11222_pointer_1502 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1495, i64 0, i32 6
        store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1502, !noalias !2
        %returnAddress_pointer_1503 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1495, i64 0, i32 1, i32 0
        %sharer_pointer_1504 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1495, i64 0, i32 1, i32 1
        %eraser_pointer_1505 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1495, i64 0, i32 1, i32 2
        store ptr @returnAddress_1275, ptr %returnAddress_pointer_1503, !noalias !2
        store ptr @sharer_1407, ptr %sharer_pointer_1504, !noalias !2
        store ptr @eraser_1423, ptr %eraser_pointer_1505, !noalias !2
        
        %get_16667_pointer_1506 = call ccc ptr @getVarPointer(%Reference %py_11_2079_10749, %Stack %stack)
        %py_11_2079_10749_old_1507 = load double, ptr %get_16667_pointer_1506, !noalias !2
        %get_16667 = load double, ptr %get_16667_pointer_1506, !noalias !2
        
        %stackPointer_1509 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1510 = getelementptr %FrameHeader, %StackPointer %stackPointer_1509, i64 0, i32 0
        %returnAddress_1508 = load %ReturnAddress, ptr %returnAddress_pointer_1510, !noalias !2
        musttail call tailcc void %returnAddress_1508(double %get_16667, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1235(double %v_r_3048_2_142_2210_12290, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1236 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %tmp_16320_pointer_1237 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1236, i64 0, i32 0
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1237, !noalias !2
        %py_11_2079_10749_pointer_1238 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1236, i64 0, i32 1
        %py_11_2079_10749 = load %Reference, ptr %py_11_2079_10749_pointer_1238, !noalias !2
        %pz_13_2081_11683_pointer_1239 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1236, i64 0, i32 2
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1239, !noalias !2
        %tmp_16326_pointer_1240 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1236, i64 0, i32 3
        %tmp_16326 = load i64, ptr %tmp_16326_pointer_1240, !noalias !2
        %px_9_2077_11716_pointer_1241 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1236, i64 0, i32 4
        %px_9_2077_11716 = load %Reference, ptr %px_9_2077_11716_pointer_1241, !noalias !2
        %tmp_16328_pointer_1242 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1236, i64 0, i32 5
        %tmp_16328 = load %Pos, ptr %tmp_16328_pointer_1242, !noalias !2
        %i_6_10_139_2207_11222_pointer_1243 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1236, i64 0, i32 6
        %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1243, !noalias !2
        
        call ccc void @sharePositive(%Pos %tmp_16328)
        %tag_1244 = extractvalue %Pos %tmp_16328, 0
        %fields_1245 = extractvalue %Pos %tmp_16328, 1
        switch i64 %tag_1244, label %label_1246 [i64 0, label %label_1543]
    
    label_1246:
        
        ret void
    
    label_1257:
        
        ret void
    
    label_1542:
        %environment_1258 = call ccc %Environment @objectEnvironment(%Object %fields_1256)
        %__11_151_2219_13955_pointer_1259 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1258, i64 0, i32 0
        %__11_151_2219_13955 = load double, ptr %__11_151_2219_13955_pointer_1259, !noalias !2
        %__12_152_2220_13956_pointer_1260 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1258, i64 0, i32 1
        %__12_152_2220_13956 = load double, ptr %__12_152_2220_13956_pointer_1260, !noalias !2
        %__13_153_2221_13957_pointer_1261 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1258, i64 0, i32 2
        %__13_153_2221_13957 = load double, ptr %__13_153_2221_13957_pointer_1261, !noalias !2
        %__14_154_2222_13958_pointer_1262 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1258, i64 0, i32 3
        %__14_154_2222_13958 = load double, ptr %__14_154_2222_13958_pointer_1262, !noalias !2
        %__15_155_2223_13959_pointer_1263 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1258, i64 0, i32 4
        %__15_155_2223_13959 = load double, ptr %__15_155_2223_13959_pointer_1263, !noalias !2
        %__16_156_2224_13960_pointer_1264 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1258, i64 0, i32 5
        %__16_156_2224_13960 = load double, ptr %__16_156_2224_13960_pointer_1264, !noalias !2
        %x_17_157_2225_11908_pointer_1265 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1258, i64 0, i32 6
        %x_17_157_2225_11908 = load double, ptr %x_17_157_2225_11908_pointer_1265, !noalias !2
        call ccc void @eraseObject(%Object %fields_1256)
        
        %pureApp_16656 = call ccc double @infixMul_114(double %x_6_146_2214_11598, double %x_17_157_2225_11908)
        
        
        
        %pureApp_16657 = call ccc double @infixAdd_111(double %v_r_3048_2_142_2210_12290, double %pureApp_16656)
        
        
        %stackPointer_1525 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %tmp_16320_pointer_1526 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1525, i64 0, i32 0
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1526, !noalias !2
        %py_11_2079_10749_pointer_1527 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1525, i64 0, i32 1
        store %Reference %py_11_2079_10749, ptr %py_11_2079_10749_pointer_1527, !noalias !2
        %pz_13_2081_11683_pointer_1528 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1525, i64 0, i32 2
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1528, !noalias !2
        %tmp_16326_pointer_1529 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1525, i64 0, i32 3
        store i64 %tmp_16326, ptr %tmp_16326_pointer_1529, !noalias !2
        %px_9_2077_11716_pointer_1530 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1525, i64 0, i32 4
        store %Reference %px_9_2077_11716, ptr %px_9_2077_11716_pointer_1530, !noalias !2
        %tmp_16328_pointer_1531 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1525, i64 0, i32 5
        store %Pos %tmp_16328, ptr %tmp_16328_pointer_1531, !noalias !2
        %i_6_10_139_2207_11222_pointer_1532 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1525, i64 0, i32 6
        store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1532, !noalias !2
        %returnAddress_pointer_1533 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1525, i64 0, i32 1, i32 0
        %sharer_pointer_1534 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1525, i64 0, i32 1, i32 1
        %eraser_pointer_1535 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1525, i64 0, i32 1, i32 2
        store ptr @returnAddress_1266, ptr %returnAddress_pointer_1533, !noalias !2
        store ptr @sharer_1407, ptr %sharer_pointer_1534, !noalias !2
        store ptr @eraser_1423, ptr %eraser_pointer_1535, !noalias !2
        
        %px_9_2077_11716pointer_1536 = call ccc ptr @getVarPointer(%Reference %px_9_2077_11716, %Stack %stack)
        %px_9_2077_11716_old_1537 = load double, ptr %px_9_2077_11716pointer_1536, !noalias !2
        store double %pureApp_16657, ptr %px_9_2077_11716pointer_1536, !noalias !2
        
        %put_16668_temporary_1538 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_16668 = insertvalue %Pos %put_16668_temporary_1538, %Object null, 1
        
        %stackPointer_1540 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1541 = getelementptr %FrameHeader, %StackPointer %stackPointer_1540, i64 0, i32 0
        %returnAddress_1539 = load %ReturnAddress, ptr %returnAddress_pointer_1541, !noalias !2
        musttail call tailcc void %returnAddress_1539(%Pos %put_16668, %Stack %stack)
        ret void
    
    label_1543:
        %environment_1247 = call ccc %Environment @objectEnvironment(%Object %fields_1245)
        %__3_143_2211_13949_pointer_1248 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1247, i64 0, i32 0
        %__3_143_2211_13949 = load double, ptr %__3_143_2211_13949_pointer_1248, !noalias !2
        %__4_144_2212_13950_pointer_1249 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1247, i64 0, i32 1
        %__4_144_2212_13950 = load double, ptr %__4_144_2212_13950_pointer_1249, !noalias !2
        %__5_145_2213_13951_pointer_1250 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1247, i64 0, i32 2
        %__5_145_2213_13951 = load double, ptr %__5_145_2213_13951_pointer_1250, !noalias !2
        %x_6_146_2214_11598_pointer_1251 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1247, i64 0, i32 3
        %x_6_146_2214_11598 = load double, ptr %x_6_146_2214_11598_pointer_1251, !noalias !2
        %__7_147_2215_13952_pointer_1252 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1247, i64 0, i32 4
        %__7_147_2215_13952 = load double, ptr %__7_147_2215_13952_pointer_1252, !noalias !2
        %__8_148_2216_13953_pointer_1253 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1247, i64 0, i32 5
        %__8_148_2216_13953 = load double, ptr %__8_148_2216_13953_pointer_1253, !noalias !2
        %__9_149_2217_13954_pointer_1254 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1247, i64 0, i32 6
        %__9_149_2217_13954 = load double, ptr %__9_149_2217_13954_pointer_1254, !noalias !2
        call ccc void @eraseObject(%Object %fields_1245)
        
        call ccc void @sharePositive(%Pos %tmp_16328)
        %tag_1255 = extractvalue %Pos %tmp_16328, 0
        %fields_1256 = extractvalue %Pos %tmp_16328, 1
        switch i64 %tag_1255, label %label_1257 [i64 0, label %label_1542]
}



define tailcc void @loop_5_9_138_2206_10607(i64 %i_6_10_139_2207_11222, %Pos %tmp_16320, %Reference %py_11_2079_10749, %Reference %pz_13_2081_11683, i64 %tmp_16326, %Reference %px_9_2077_11716, %Stack %stack) {
        
    entry:
        
        
        %pureApp_16653 = call ccc %Pos @infixLt_178(i64 %i_6_10_139_2207_11222, i64 %tmp_16326)
        
        
        
        %tag_1227 = extractvalue %Pos %pureApp_16653, 0
        %fields_1228 = extractvalue %Pos %pureApp_16653, 1
        switch i64 %tag_1227, label %label_1229 [i64 0, label %label_1234 i64 1, label %label_1574]
    
    label_1229:
        
        ret void
    
    label_1234:
        call ccc void @erasePositive(%Pos %tmp_16320)
        
        %unitLiteral_16654_temporary_1230 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_16654 = insertvalue %Pos %unitLiteral_16654_temporary_1230, %Object null, 1
        
        %stackPointer_1232 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1233 = getelementptr %FrameHeader, %StackPointer %stackPointer_1232, i64 0, i32 0
        %returnAddress_1231 = load %ReturnAddress, ptr %returnAddress_pointer_1233, !noalias !2
        musttail call tailcc void %returnAddress_1231(%Pos %unitLiteral_16654, %Stack %stack)
        ret void
    
    label_1574:
        
        call ccc void @sharePositive(%Pos %tmp_16320)
        %pureApp_16655 = call ccc %Pos @unsafeGet_2487(%Pos %tmp_16320, i64 %i_6_10_139_2207_11222)
        
        
        %stackPointer_1558 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %tmp_16320_pointer_1559 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1558, i64 0, i32 0
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1559, !noalias !2
        %py_11_2079_10749_pointer_1560 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1558, i64 0, i32 1
        store %Reference %py_11_2079_10749, ptr %py_11_2079_10749_pointer_1560, !noalias !2
        %pz_13_2081_11683_pointer_1561 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1558, i64 0, i32 2
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1561, !noalias !2
        %tmp_16326_pointer_1562 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1558, i64 0, i32 3
        store i64 %tmp_16326, ptr %tmp_16326_pointer_1562, !noalias !2
        %px_9_2077_11716_pointer_1563 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1558, i64 0, i32 4
        store %Reference %px_9_2077_11716, ptr %px_9_2077_11716_pointer_1563, !noalias !2
        %tmp_16328_pointer_1564 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1558, i64 0, i32 5
        store %Pos %pureApp_16655, ptr %tmp_16328_pointer_1564, !noalias !2
        %i_6_10_139_2207_11222_pointer_1565 = getelementptr <{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %StackPointer %stackPointer_1558, i64 0, i32 6
        store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1565, !noalias !2
        %returnAddress_pointer_1566 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1558, i64 0, i32 1, i32 0
        %sharer_pointer_1567 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1558, i64 0, i32 1, i32 1
        %eraser_pointer_1568 = getelementptr <{<{%Pos, %Reference, %Reference, i64, %Reference, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1558, i64 0, i32 1, i32 2
        store ptr @returnAddress_1235, ptr %returnAddress_pointer_1566, !noalias !2
        store ptr @sharer_1407, ptr %sharer_pointer_1567, !noalias !2
        store ptr @eraser_1423, ptr %eraser_pointer_1568, !noalias !2
        
        %get_16669_pointer_1569 = call ccc ptr @getVarPointer(%Reference %px_9_2077_11716, %Stack %stack)
        %px_9_2077_11716_old_1570 = load double, ptr %get_16669_pointer_1569, !noalias !2
        %get_16669 = load double, ptr %get_16669_pointer_1569, !noalias !2
        
        %stackPointer_1572 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1573 = getelementptr %FrameHeader, %StackPointer %stackPointer_1572, i64 0, i32 0
        %returnAddress_1571 = load %ReturnAddress, ptr %returnAddress_pointer_1573, !noalias !2
        musttail call tailcc void %returnAddress_1571(double %get_16669, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1594(double %v_r_3067_250_2318_11495, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1595 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %tmp_16294_pointer_1596 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1595, i64 0, i32 0
        %tmp_16294 = load double, ptr %tmp_16294_pointer_1596, !noalias !2
        %v_r_3066_249_2317_11242_pointer_1597 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1595, i64 0, i32 1
        %v_r_3066_249_2317_11242 = load double, ptr %v_r_3066_249_2317_11242_pointer_1597, !noalias !2
        %tmp_16320_pointer_1598 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1595, i64 0, i32 2
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1598, !noalias !2
        %v_r_3065_248_2316_11300_pointer_1599 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1595, i64 0, i32 3
        %v_r_3065_248_2316_11300 = load double, ptr %v_r_3065_248_2316_11300_pointer_1599, !noalias !2
        
        %doubleLiteral_16670 = fadd double 0.0, 0.0
        
        
        
        %doubleLiteral_16671 = fadd double 0.0, 0.0
        
        
        
        %doubleLiteral_16672 = fadd double 0.0, 0.0
        
        
        
        %doubleLiteral_16674 = fadd double 1.0, 0.0
        
        %pureApp_16673 = call ccc double @infixMul_114(double %doubleLiteral_16674, double %tmp_16294)
        
        
        
        %pureApp_16675 = call ccc double @infixDiv_120(double %v_r_3065_248_2316_11300, double %tmp_16294)
        
        
        
        %doubleLiteral_16677 = fadd double 0.0, 0.0
        
        %pureApp_16676 = call ccc double @infixSub_117(double %doubleLiteral_16677, double %pureApp_16675)
        
        
        
        %pureApp_16678 = call ccc double @infixDiv_120(double %v_r_3066_249_2317_11242, double %tmp_16294)
        
        
        
        %doubleLiteral_16680 = fadd double 0.0, 0.0
        
        %pureApp_16679 = call ccc double @infixSub_117(double %doubleLiteral_16680, double %pureApp_16678)
        
        
        
        %pureApp_16681 = call ccc double @infixDiv_120(double %v_r_3067_250_2318_11495, double %tmp_16294)
        
        
        
        %doubleLiteral_16683 = fadd double 0.0, 0.0
        
        %pureApp_16682 = call ccc double @infixSub_117(double %doubleLiteral_16683, double %pureApp_16681)
        
        
        
        %fields_1600 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_1601 = call ccc %Environment @objectEnvironment(%Object %fields_1600)
        %v_r_3061_12_258_2326_8_15950_pointer_1609 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1601, i64 0, i32 0
        store double %doubleLiteral_16670, ptr %v_r_3061_12_258_2326_8_15950_pointer_1609, !noalias !2
        %v_r_3062_20_266_2334_16_8_16000_pointer_1610 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1601, i64 0, i32 1
        store double %doubleLiteral_16671, ptr %v_r_3062_20_266_2334_16_8_16000_pointer_1610, !noalias !2
        %v_r_3063_28_274_2342_24_16_8_16031_pointer_1611 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1601, i64 0, i32 2
        store double %doubleLiteral_16672, ptr %v_r_3063_28_274_2342_24_16_8_16031_pointer_1611, !noalias !2
        %tmp_16338_pointer_1612 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1601, i64 0, i32 3
        store double %pureApp_16676, ptr %tmp_16338_pointer_1612, !noalias !2
        %tmp_16340_pointer_1613 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1601, i64 0, i32 4
        store double %pureApp_16679, ptr %tmp_16340_pointer_1613, !noalias !2
        %tmp_16342_pointer_1614 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1601, i64 0, i32 5
        store double %pureApp_16682, ptr %tmp_16342_pointer_1614, !noalias !2
        %tmp_16336_pointer_1615 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_1601, i64 0, i32 6
        store double %pureApp_16673, ptr %tmp_16336_pointer_1615, !noalias !2
        %make_16684_temporary_1616 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16684 = insertvalue %Pos %make_16684_temporary_1616, %Object %fields_1600, 1
        
        
        
        %longLiteral_16686 = add i64 0, 0
        
        call ccc void @sharePositive(%Pos %tmp_16320)
        %pureApp_16685 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_16320, i64 %longLiteral_16686, %Pos %make_16684)
        call ccc void @erasePositive(%Pos %pureApp_16685)
        
        
        
        %stackPointer_1618 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1619 = getelementptr %FrameHeader, %StackPointer %stackPointer_1618, i64 0, i32 0
        %returnAddress_1617 = load %ReturnAddress, ptr %returnAddress_pointer_1619, !noalias !2
        musttail call tailcc void %returnAddress_1617(%Pos %tmp_16320, %Stack %stack)
        ret void
}



define ccc void @sharer_1624(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1625 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer, i64 -1
        %tmp_16294_1620_pointer_1626 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1625, i64 0, i32 0
        %tmp_16294_1620 = load double, ptr %tmp_16294_1620_pointer_1626, !noalias !2
        %v_r_3066_249_2317_11242_1621_pointer_1627 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1625, i64 0, i32 1
        %v_r_3066_249_2317_11242_1621 = load double, ptr %v_r_3066_249_2317_11242_1621_pointer_1627, !noalias !2
        %tmp_16320_1622_pointer_1628 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1625, i64 0, i32 2
        %tmp_16320_1622 = load %Pos, ptr %tmp_16320_1622_pointer_1628, !noalias !2
        %v_r_3065_248_2316_11300_1623_pointer_1629 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1625, i64 0, i32 3
        %v_r_3065_248_2316_11300_1623 = load double, ptr %v_r_3065_248_2316_11300_1623_pointer_1629, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16320_1622)
        call ccc void @shareFrames(%StackPointer %stackPointer_1625)
        ret void
}



define ccc void @eraser_1634(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1635 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer, i64 -1
        %tmp_16294_1630_pointer_1636 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1635, i64 0, i32 0
        %tmp_16294_1630 = load double, ptr %tmp_16294_1630_pointer_1636, !noalias !2
        %v_r_3066_249_2317_11242_1631_pointer_1637 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1635, i64 0, i32 1
        %v_r_3066_249_2317_11242_1631 = load double, ptr %v_r_3066_249_2317_11242_1631_pointer_1637, !noalias !2
        %tmp_16320_1632_pointer_1638 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1635, i64 0, i32 2
        %tmp_16320_1632 = load %Pos, ptr %tmp_16320_1632_pointer_1638, !noalias !2
        %v_r_3065_248_2316_11300_1633_pointer_1639 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1635, i64 0, i32 3
        %v_r_3065_248_2316_11300_1633 = load double, ptr %v_r_3065_248_2316_11300_1633_pointer_1639, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16320_1632)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1635)
        ret void
}



define tailcc void @returnAddress_1588(double %v_r_3066_249_2317_11242, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1589 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %pz_13_2081_11683_pointer_1590 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1589, i64 0, i32 0
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1590, !noalias !2
        %tmp_16294_pointer_1591 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1589, i64 0, i32 1
        %tmp_16294 = load double, ptr %tmp_16294_pointer_1591, !noalias !2
        %tmp_16320_pointer_1592 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1589, i64 0, i32 2
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1592, !noalias !2
        %v_r_3065_248_2316_11300_pointer_1593 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1589, i64 0, i32 3
        %v_r_3065_248_2316_11300 = load double, ptr %v_r_3065_248_2316_11300_pointer_1593, !noalias !2
        %stackPointer_1640 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %tmp_16294_pointer_1641 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1640, i64 0, i32 0
        store double %tmp_16294, ptr %tmp_16294_pointer_1641, !noalias !2
        %v_r_3066_249_2317_11242_pointer_1642 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1640, i64 0, i32 1
        store double %v_r_3066_249_2317_11242, ptr %v_r_3066_249_2317_11242_pointer_1642, !noalias !2
        %tmp_16320_pointer_1643 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1640, i64 0, i32 2
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1643, !noalias !2
        %v_r_3065_248_2316_11300_pointer_1644 = getelementptr <{double, double, %Pos, double}>, %StackPointer %stackPointer_1640, i64 0, i32 3
        store double %v_r_3065_248_2316_11300, ptr %v_r_3065_248_2316_11300_pointer_1644, !noalias !2
        %returnAddress_pointer_1645 = getelementptr <{<{double, double, %Pos, double}>, %FrameHeader}>, %StackPointer %stackPointer_1640, i64 0, i32 1, i32 0
        %sharer_pointer_1646 = getelementptr <{<{double, double, %Pos, double}>, %FrameHeader}>, %StackPointer %stackPointer_1640, i64 0, i32 1, i32 1
        %eraser_pointer_1647 = getelementptr <{<{double, double, %Pos, double}>, %FrameHeader}>, %StackPointer %stackPointer_1640, i64 0, i32 1, i32 2
        store ptr @returnAddress_1594, ptr %returnAddress_pointer_1645, !noalias !2
        store ptr @sharer_1624, ptr %sharer_pointer_1646, !noalias !2
        store ptr @eraser_1634, ptr %eraser_pointer_1647, !noalias !2
        
        %get_16687_pointer_1648 = call ccc ptr @getVarPointer(%Reference %pz_13_2081_11683, %Stack %stack)
        %pz_13_2081_11683_old_1649 = load double, ptr %get_16687_pointer_1648, !noalias !2
        %get_16687 = load double, ptr %get_16687_pointer_1648, !noalias !2
        
        %stackPointer_1651 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1652 = getelementptr %FrameHeader, %StackPointer %stackPointer_1651, i64 0, i32 0
        %returnAddress_1650 = load %ReturnAddress, ptr %returnAddress_pointer_1652, !noalias !2
        musttail call tailcc void %returnAddress_1650(double %get_16687, %Stack %stack)
        ret void
}



define ccc void @sharer_1657(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1658 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer, i64 -1
        %pz_13_2081_11683_1653_pointer_1659 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1658, i64 0, i32 0
        %pz_13_2081_11683_1653 = load %Reference, ptr %pz_13_2081_11683_1653_pointer_1659, !noalias !2
        %tmp_16294_1654_pointer_1660 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1658, i64 0, i32 1
        %tmp_16294_1654 = load double, ptr %tmp_16294_1654_pointer_1660, !noalias !2
        %tmp_16320_1655_pointer_1661 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1658, i64 0, i32 2
        %tmp_16320_1655 = load %Pos, ptr %tmp_16320_1655_pointer_1661, !noalias !2
        %v_r_3065_248_2316_11300_1656_pointer_1662 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1658, i64 0, i32 3
        %v_r_3065_248_2316_11300_1656 = load double, ptr %v_r_3065_248_2316_11300_1656_pointer_1662, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16320_1655)
        call ccc void @shareFrames(%StackPointer %stackPointer_1658)
        ret void
}



define ccc void @eraser_1667(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1668 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer, i64 -1
        %pz_13_2081_11683_1663_pointer_1669 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1668, i64 0, i32 0
        %pz_13_2081_11683_1663 = load %Reference, ptr %pz_13_2081_11683_1663_pointer_1669, !noalias !2
        %tmp_16294_1664_pointer_1670 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1668, i64 0, i32 1
        %tmp_16294_1664 = load double, ptr %tmp_16294_1664_pointer_1670, !noalias !2
        %tmp_16320_1665_pointer_1671 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1668, i64 0, i32 2
        %tmp_16320_1665 = load %Pos, ptr %tmp_16320_1665_pointer_1671, !noalias !2
        %v_r_3065_248_2316_11300_1666_pointer_1672 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1668, i64 0, i32 3
        %v_r_3065_248_2316_11300_1666 = load double, ptr %v_r_3065_248_2316_11300_1666_pointer_1672, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16320_1665)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1668)
        ret void
}



define tailcc void @returnAddress_1582(double %v_r_3065_248_2316_11300, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1583 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %tmp_16320_pointer_1584 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1583, i64 0, i32 0
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1584, !noalias !2
        %py_11_2079_10749_pointer_1585 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1583, i64 0, i32 1
        %py_11_2079_10749 = load %Reference, ptr %py_11_2079_10749_pointer_1585, !noalias !2
        %pz_13_2081_11683_pointer_1586 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1583, i64 0, i32 2
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1586, !noalias !2
        %tmp_16294_pointer_1587 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1583, i64 0, i32 3
        %tmp_16294 = load double, ptr %tmp_16294_pointer_1587, !noalias !2
        %stackPointer_1673 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %pz_13_2081_11683_pointer_1674 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1673, i64 0, i32 0
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1674, !noalias !2
        %tmp_16294_pointer_1675 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1673, i64 0, i32 1
        store double %tmp_16294, ptr %tmp_16294_pointer_1675, !noalias !2
        %tmp_16320_pointer_1676 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1673, i64 0, i32 2
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1676, !noalias !2
        %v_r_3065_248_2316_11300_pointer_1677 = getelementptr <{%Reference, double, %Pos, double}>, %StackPointer %stackPointer_1673, i64 0, i32 3
        store double %v_r_3065_248_2316_11300, ptr %v_r_3065_248_2316_11300_pointer_1677, !noalias !2
        %returnAddress_pointer_1678 = getelementptr <{<{%Reference, double, %Pos, double}>, %FrameHeader}>, %StackPointer %stackPointer_1673, i64 0, i32 1, i32 0
        %sharer_pointer_1679 = getelementptr <{<{%Reference, double, %Pos, double}>, %FrameHeader}>, %StackPointer %stackPointer_1673, i64 0, i32 1, i32 1
        %eraser_pointer_1680 = getelementptr <{<{%Reference, double, %Pos, double}>, %FrameHeader}>, %StackPointer %stackPointer_1673, i64 0, i32 1, i32 2
        store ptr @returnAddress_1588, ptr %returnAddress_pointer_1678, !noalias !2
        store ptr @sharer_1657, ptr %sharer_pointer_1679, !noalias !2
        store ptr @eraser_1667, ptr %eraser_pointer_1680, !noalias !2
        
        %get_16688_pointer_1681 = call ccc ptr @getVarPointer(%Reference %py_11_2079_10749, %Stack %stack)
        %py_11_2079_10749_old_1682 = load double, ptr %get_16688_pointer_1681, !noalias !2
        %get_16688 = load double, ptr %get_16688_pointer_1681, !noalias !2
        
        %stackPointer_1684 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1685 = getelementptr %FrameHeader, %StackPointer %stackPointer_1684, i64 0, i32 0
        %returnAddress_1683 = load %ReturnAddress, ptr %returnAddress_pointer_1685, !noalias !2
        musttail call tailcc void %returnAddress_1683(double %get_16688, %Stack %stack)
        ret void
}



define ccc void @sharer_1690(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1691 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer, i64 -1
        %tmp_16320_1686_pointer_1692 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1691, i64 0, i32 0
        %tmp_16320_1686 = load %Pos, ptr %tmp_16320_1686_pointer_1692, !noalias !2
        %py_11_2079_10749_1687_pointer_1693 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1691, i64 0, i32 1
        %py_11_2079_10749_1687 = load %Reference, ptr %py_11_2079_10749_1687_pointer_1693, !noalias !2
        %pz_13_2081_11683_1688_pointer_1694 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1691, i64 0, i32 2
        %pz_13_2081_11683_1688 = load %Reference, ptr %pz_13_2081_11683_1688_pointer_1694, !noalias !2
        %tmp_16294_1689_pointer_1695 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1691, i64 0, i32 3
        %tmp_16294_1689 = load double, ptr %tmp_16294_1689_pointer_1695, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16320_1686)
        call ccc void @shareFrames(%StackPointer %stackPointer_1691)
        ret void
}



define ccc void @eraser_1700(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1701 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer, i64 -1
        %tmp_16320_1696_pointer_1702 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1701, i64 0, i32 0
        %tmp_16320_1696 = load %Pos, ptr %tmp_16320_1696_pointer_1702, !noalias !2
        %py_11_2079_10749_1697_pointer_1703 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1701, i64 0, i32 1
        %py_11_2079_10749_1697 = load %Reference, ptr %py_11_2079_10749_1697_pointer_1703, !noalias !2
        %pz_13_2081_11683_1698_pointer_1704 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1701, i64 0, i32 2
        %pz_13_2081_11683_1698 = load %Reference, ptr %pz_13_2081_11683_1698_pointer_1704, !noalias !2
        %tmp_16294_1699_pointer_1705 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1701, i64 0, i32 3
        %tmp_16294_1699 = load double, ptr %tmp_16294_1699_pointer_1705, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16320_1696)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1701)
        ret void
}



define tailcc void @returnAddress_1575(%Pos %__203_2271_13988, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1576 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %tmp_16320_pointer_1577 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1576, i64 0, i32 0
        %tmp_16320 = load %Pos, ptr %tmp_16320_pointer_1577, !noalias !2
        %py_11_2079_10749_pointer_1578 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1576, i64 0, i32 1
        %py_11_2079_10749 = load %Reference, ptr %py_11_2079_10749_pointer_1578, !noalias !2
        %pz_13_2081_11683_pointer_1579 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1576, i64 0, i32 2
        %pz_13_2081_11683 = load %Reference, ptr %pz_13_2081_11683_pointer_1579, !noalias !2
        %tmp_16294_pointer_1580 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1576, i64 0, i32 3
        %tmp_16294 = load double, ptr %tmp_16294_pointer_1580, !noalias !2
        %px_9_2077_11716_pointer_1581 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1576, i64 0, i32 4
        %px_9_2077_11716 = load %Reference, ptr %px_9_2077_11716_pointer_1581, !noalias !2
        call ccc void @erasePositive(%Pos %__203_2271_13988)
        %stackPointer_1706 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %tmp_16320_pointer_1707 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1706, i64 0, i32 0
        store %Pos %tmp_16320, ptr %tmp_16320_pointer_1707, !noalias !2
        %py_11_2079_10749_pointer_1708 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1706, i64 0, i32 1
        store %Reference %py_11_2079_10749, ptr %py_11_2079_10749_pointer_1708, !noalias !2
        %pz_13_2081_11683_pointer_1709 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1706, i64 0, i32 2
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1709, !noalias !2
        %tmp_16294_pointer_1710 = getelementptr <{%Pos, %Reference, %Reference, double}>, %StackPointer %stackPointer_1706, i64 0, i32 3
        store double %tmp_16294, ptr %tmp_16294_pointer_1710, !noalias !2
        %returnAddress_pointer_1711 = getelementptr <{<{%Pos, %Reference, %Reference, double}>, %FrameHeader}>, %StackPointer %stackPointer_1706, i64 0, i32 1, i32 0
        %sharer_pointer_1712 = getelementptr <{<{%Pos, %Reference, %Reference, double}>, %FrameHeader}>, %StackPointer %stackPointer_1706, i64 0, i32 1, i32 1
        %eraser_pointer_1713 = getelementptr <{<{%Pos, %Reference, %Reference, double}>, %FrameHeader}>, %StackPointer %stackPointer_1706, i64 0, i32 1, i32 2
        store ptr @returnAddress_1582, ptr %returnAddress_pointer_1711, !noalias !2
        store ptr @sharer_1690, ptr %sharer_pointer_1712, !noalias !2
        store ptr @eraser_1700, ptr %eraser_pointer_1713, !noalias !2
        
        %get_16689_pointer_1714 = call ccc ptr @getVarPointer(%Reference %px_9_2077_11716, %Stack %stack)
        %px_9_2077_11716_old_1715 = load double, ptr %get_16689_pointer_1714, !noalias !2
        %get_16689 = load double, ptr %get_16689_pointer_1714, !noalias !2
        
        %stackPointer_1717 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1718 = getelementptr %FrameHeader, %StackPointer %stackPointer_1717, i64 0, i32 0
        %returnAddress_1716 = load %ReturnAddress, ptr %returnAddress_pointer_1718, !noalias !2
        musttail call tailcc void %returnAddress_1716(double %get_16689, %Stack %stack)
        ret void
}



define ccc void @sharer_1724(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1725 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_16320_1719_pointer_1726 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1725, i64 0, i32 0
        %tmp_16320_1719 = load %Pos, ptr %tmp_16320_1719_pointer_1726, !noalias !2
        %py_11_2079_10749_1720_pointer_1727 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1725, i64 0, i32 1
        %py_11_2079_10749_1720 = load %Reference, ptr %py_11_2079_10749_1720_pointer_1727, !noalias !2
        %pz_13_2081_11683_1721_pointer_1728 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1725, i64 0, i32 2
        %pz_13_2081_11683_1721 = load %Reference, ptr %pz_13_2081_11683_1721_pointer_1728, !noalias !2
        %tmp_16294_1722_pointer_1729 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1725, i64 0, i32 3
        %tmp_16294_1722 = load double, ptr %tmp_16294_1722_pointer_1729, !noalias !2
        %px_9_2077_11716_1723_pointer_1730 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1725, i64 0, i32 4
        %px_9_2077_11716_1723 = load %Reference, ptr %px_9_2077_11716_1723_pointer_1730, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_16320_1719)
        call ccc void @shareFrames(%StackPointer %stackPointer_1725)
        ret void
}



define ccc void @eraser_1736(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1737 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_16320_1731_pointer_1738 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1737, i64 0, i32 0
        %tmp_16320_1731 = load %Pos, ptr %tmp_16320_1731_pointer_1738, !noalias !2
        %py_11_2079_10749_1732_pointer_1739 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1737, i64 0, i32 1
        %py_11_2079_10749_1732 = load %Reference, ptr %py_11_2079_10749_1732_pointer_1739, !noalias !2
        %pz_13_2081_11683_1733_pointer_1740 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1737, i64 0, i32 2
        %pz_13_2081_11683_1733 = load %Reference, ptr %pz_13_2081_11683_1733_pointer_1740, !noalias !2
        %tmp_16294_1734_pointer_1741 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1737, i64 0, i32 3
        %tmp_16294_1734 = load double, ptr %tmp_16294_1734_pointer_1741, !noalias !2
        %px_9_2077_11716_1735_pointer_1742 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1737, i64 0, i32 4
        %px_9_2077_11716_1735 = load %Reference, ptr %px_9_2077_11716_1735_pointer_1742, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16320_1731)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1737)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_4181_4245, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_16451 = call ccc i64 @unboxInt_303(%Pos %v_coe_4181_4245)
        
        
        
        %doubleLiteral_16452 = fadd double 3.141592653589793, 0.0
        
        
        
        %doubleLiteral_16454 = fadd double 4.0, 0.0
        
        %pureApp_16453 = call ccc double @infixMul_114(double %doubleLiteral_16454, double %doubleLiteral_16452)
        
        
        
        %pureApp_16455 = call ccc double @infixMul_114(double %pureApp_16453, double %doubleLiteral_16452)
        
        
        
        %doubleLiteral_16456 = fadd double 365.24, 0.0
        
        
        
        %doubleLiteral_16458 = fadd double 0.001660076642744037, 0.0
        
        %pureApp_16457 = call ccc double @infixMul_114(double %doubleLiteral_16458, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16460 = fadd double 0.007699011184197404, 0.0
        
        %pureApp_16459 = call ccc double @infixMul_114(double %doubleLiteral_16460, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16462 = fadd double -6.90460016972063E-5, 0.0
        
        %pureApp_16461 = call ccc double @infixMul_114(double %doubleLiteral_16462, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16464 = fadd double 9.547919384243266E-4, 0.0
        
        %pureApp_16463 = call ccc double @infixMul_114(double %doubleLiteral_16464, double %pureApp_16455)
        
        
        
        %doubleLiteral_16466 = fadd double 4.841431442464721, 0.0
        
        %doubleLiteral_16467 = fadd double -1.1603200440274284, 0.0
        
        %doubleLiteral_16468 = fadd double -0.10362204447112311, 0.0
        
        %fields_2 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_3 = call ccc %Environment @objectEnvironment(%Object %fields_2)
        %doubleLiteral_16466_pointer_19 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_3, i64 0, i32 0
        store double %doubleLiteral_16466, ptr %doubleLiteral_16466_pointer_19, !noalias !2
        %doubleLiteral_16467_pointer_20 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_3, i64 0, i32 1
        store double %doubleLiteral_16467, ptr %doubleLiteral_16467_pointer_20, !noalias !2
        %doubleLiteral_16468_pointer_21 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_3, i64 0, i32 2
        store double %doubleLiteral_16468, ptr %doubleLiteral_16468_pointer_21, !noalias !2
        %tmp_16295_pointer_22 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_3, i64 0, i32 3
        store double %pureApp_16457, ptr %tmp_16295_pointer_22, !noalias !2
        %tmp_16296_pointer_23 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_3, i64 0, i32 4
        store double %pureApp_16459, ptr %tmp_16296_pointer_23, !noalias !2
        %tmp_16297_pointer_24 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_3, i64 0, i32 5
        store double %pureApp_16461, ptr %tmp_16297_pointer_24, !noalias !2
        %tmp_16298_pointer_25 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_3, i64 0, i32 6
        store double %pureApp_16463, ptr %tmp_16298_pointer_25, !noalias !2
        %make_16465_temporary_26 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16465 = insertvalue %Pos %make_16465_temporary_26, %Object %fields_2, 1
        
        
        
        %doubleLiteral_16470 = fadd double -0.002767425107268624, 0.0
        
        %pureApp_16469 = call ccc double @infixMul_114(double %doubleLiteral_16470, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16472 = fadd double 0.004998528012349172, 0.0
        
        %pureApp_16471 = call ccc double @infixMul_114(double %doubleLiteral_16472, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16474 = fadd double 2.304172975737639E-5, 0.0
        
        %pureApp_16473 = call ccc double @infixMul_114(double %doubleLiteral_16474, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16476 = fadd double 2.858859806661308E-4, 0.0
        
        %pureApp_16475 = call ccc double @infixMul_114(double %doubleLiteral_16476, double %pureApp_16455)
        
        
        
        %doubleLiteral_16478 = fadd double 8.34336671824458, 0.0
        
        %doubleLiteral_16479 = fadd double 4.124798564124305, 0.0
        
        %doubleLiteral_16480 = fadd double -0.4035234171143214, 0.0
        
        %fields_27 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_28 = call ccc %Environment @objectEnvironment(%Object %fields_27)
        %doubleLiteral_16478_pointer_36 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_28, i64 0, i32 0
        store double %doubleLiteral_16478, ptr %doubleLiteral_16478_pointer_36, !noalias !2
        %doubleLiteral_16479_pointer_37 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_28, i64 0, i32 1
        store double %doubleLiteral_16479, ptr %doubleLiteral_16479_pointer_37, !noalias !2
        %doubleLiteral_16480_pointer_38 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_28, i64 0, i32 2
        store double %doubleLiteral_16480, ptr %doubleLiteral_16480_pointer_38, !noalias !2
        %tmp_16300_pointer_39 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_28, i64 0, i32 3
        store double %pureApp_16469, ptr %tmp_16300_pointer_39, !noalias !2
        %tmp_16301_pointer_40 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_28, i64 0, i32 4
        store double %pureApp_16471, ptr %tmp_16301_pointer_40, !noalias !2
        %tmp_16302_pointer_41 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_28, i64 0, i32 5
        store double %pureApp_16473, ptr %tmp_16302_pointer_41, !noalias !2
        %tmp_16303_pointer_42 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_28, i64 0, i32 6
        store double %pureApp_16475, ptr %tmp_16303_pointer_42, !noalias !2
        %make_16477_temporary_43 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16477 = insertvalue %Pos %make_16477_temporary_43, %Object %fields_27, 1
        
        
        
        %doubleLiteral_16482 = fadd double 0.002964601375647616, 0.0
        
        %pureApp_16481 = call ccc double @infixMul_114(double %doubleLiteral_16482, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16484 = fadd double 0.0023784717395948095, 0.0
        
        %pureApp_16483 = call ccc double @infixMul_114(double %doubleLiteral_16484, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16486 = fadd double -2.9658956854023756E-5, 0.0
        
        %pureApp_16485 = call ccc double @infixMul_114(double %doubleLiteral_16486, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16488 = fadd double 4.366244043351563E-5, 0.0
        
        %pureApp_16487 = call ccc double @infixMul_114(double %doubleLiteral_16488, double %pureApp_16455)
        
        
        
        %doubleLiteral_16490 = fadd double 12.89436956213913, 0.0
        
        %doubleLiteral_16491 = fadd double -15.11115140169863, 0.0
        
        %doubleLiteral_16492 = fadd double -0.22330757889265573, 0.0
        
        %fields_44 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_45 = call ccc %Environment @objectEnvironment(%Object %fields_44)
        %doubleLiteral_16490_pointer_53 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_45, i64 0, i32 0
        store double %doubleLiteral_16490, ptr %doubleLiteral_16490_pointer_53, !noalias !2
        %doubleLiteral_16491_pointer_54 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_45, i64 0, i32 1
        store double %doubleLiteral_16491, ptr %doubleLiteral_16491_pointer_54, !noalias !2
        %doubleLiteral_16492_pointer_55 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_45, i64 0, i32 2
        store double %doubleLiteral_16492, ptr %doubleLiteral_16492_pointer_55, !noalias !2
        %tmp_16305_pointer_56 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_45, i64 0, i32 3
        store double %pureApp_16481, ptr %tmp_16305_pointer_56, !noalias !2
        %tmp_16306_pointer_57 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_45, i64 0, i32 4
        store double %pureApp_16483, ptr %tmp_16306_pointer_57, !noalias !2
        %tmp_16307_pointer_58 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_45, i64 0, i32 5
        store double %pureApp_16485, ptr %tmp_16307_pointer_58, !noalias !2
        %tmp_16308_pointer_59 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_45, i64 0, i32 6
        store double %pureApp_16487, ptr %tmp_16308_pointer_59, !noalias !2
        %make_16489_temporary_60 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16489 = insertvalue %Pos %make_16489_temporary_60, %Object %fields_44, 1
        
        
        
        %doubleLiteral_16494 = fadd double 0.002680677724903893, 0.0
        
        %pureApp_16493 = call ccc double @infixMul_114(double %doubleLiteral_16494, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16496 = fadd double 0.001628241700382423, 0.0
        
        %pureApp_16495 = call ccc double @infixMul_114(double %doubleLiteral_16496, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16498 = fadd double -9.515922545197159E-5, 0.0
        
        %pureApp_16497 = call ccc double @infixMul_114(double %doubleLiteral_16498, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16500 = fadd double 5.151389020466115E-5, 0.0
        
        %pureApp_16499 = call ccc double @infixMul_114(double %doubleLiteral_16500, double %pureApp_16455)
        
        
        
        %doubleLiteral_16502 = fadd double 15.379697114850917, 0.0
        
        %doubleLiteral_16503 = fadd double -25.919314609987964, 0.0
        
        %doubleLiteral_16504 = fadd double 0.17925877295037118, 0.0
        
        %fields_61 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_62 = call ccc %Environment @objectEnvironment(%Object %fields_61)
        %doubleLiteral_16502_pointer_70 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_62, i64 0, i32 0
        store double %doubleLiteral_16502, ptr %doubleLiteral_16502_pointer_70, !noalias !2
        %doubleLiteral_16503_pointer_71 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_62, i64 0, i32 1
        store double %doubleLiteral_16503, ptr %doubleLiteral_16503_pointer_71, !noalias !2
        %doubleLiteral_16504_pointer_72 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_62, i64 0, i32 2
        store double %doubleLiteral_16504, ptr %doubleLiteral_16504_pointer_72, !noalias !2
        %tmp_16310_pointer_73 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_62, i64 0, i32 3
        store double %pureApp_16493, ptr %tmp_16310_pointer_73, !noalias !2
        %tmp_16311_pointer_74 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_62, i64 0, i32 4
        store double %pureApp_16495, ptr %tmp_16311_pointer_74, !noalias !2
        %tmp_16312_pointer_75 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_62, i64 0, i32 5
        store double %pureApp_16497, ptr %tmp_16312_pointer_75, !noalias !2
        %tmp_16313_pointer_76 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_62, i64 0, i32 6
        store double %pureApp_16499, ptr %tmp_16313_pointer_76, !noalias !2
        %make_16501_temporary_77 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16501 = insertvalue %Pos %make_16501_temporary_77, %Object %fields_61, 1
        
        
        
        %doubleLiteral_16506 = fadd double 0.0, 0.0
        
        %pureApp_16505 = call ccc double @infixMul_114(double %doubleLiteral_16506, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16508 = fadd double 0.0, 0.0
        
        %pureApp_16507 = call ccc double @infixMul_114(double %doubleLiteral_16508, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16510 = fadd double 0.0, 0.0
        
        %pureApp_16509 = call ccc double @infixMul_114(double %doubleLiteral_16510, double %doubleLiteral_16456)
        
        
        
        %doubleLiteral_16512 = fadd double 1.0, 0.0
        
        %pureApp_16511 = call ccc double @infixMul_114(double %doubleLiteral_16512, double %pureApp_16455)
        
        
        
        %doubleLiteral_16514 = fadd double 0.0, 0.0
        
        %doubleLiteral_16515 = fadd double 0.0, 0.0
        
        %doubleLiteral_16516 = fadd double 0.0, 0.0
        
        %fields_78 = call ccc %Object @newObject(ptr @eraser_11, i64 56)
        %environment_79 = call ccc %Environment @objectEnvironment(%Object %fields_78)
        %doubleLiteral_16514_pointer_87 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_79, i64 0, i32 0
        store double %doubleLiteral_16514, ptr %doubleLiteral_16514_pointer_87, !noalias !2
        %doubleLiteral_16515_pointer_88 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_79, i64 0, i32 1
        store double %doubleLiteral_16515, ptr %doubleLiteral_16515_pointer_88, !noalias !2
        %doubleLiteral_16516_pointer_89 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_79, i64 0, i32 2
        store double %doubleLiteral_16516, ptr %doubleLiteral_16516_pointer_89, !noalias !2
        %tmp_16315_pointer_90 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_79, i64 0, i32 3
        store double %pureApp_16505, ptr %tmp_16315_pointer_90, !noalias !2
        %tmp_16316_pointer_91 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_79, i64 0, i32 4
        store double %pureApp_16507, ptr %tmp_16316_pointer_91, !noalias !2
        %tmp_16317_pointer_92 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_79, i64 0, i32 5
        store double %pureApp_16509, ptr %tmp_16317_pointer_92, !noalias !2
        %tmp_16318_pointer_93 = getelementptr <{double, double, double, double, double, double, double}>, %Environment %environment_79, i64 0, i32 6
        store double %pureApp_16511, ptr %tmp_16318_pointer_93, !noalias !2
        %make_16513_temporary_94 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16513 = insertvalue %Pos %make_16513_temporary_94, %Object %fields_78, 1
        
        
        
        %longLiteral_16518 = add i64 5, 0
        
        %pureApp_16517 = call ccc %Pos @allocate_2473(i64 %longLiteral_16518)
        
        
        
        %longLiteral_16520 = add i64 0, 0
        
        call ccc void @sharePositive(%Pos %pureApp_16517)
        %pureApp_16519 = call ccc %Pos @unsafeSet_2492(%Pos %pureApp_16517, i64 %longLiteral_16520, %Pos %make_16513)
        call ccc void @erasePositive(%Pos %pureApp_16519)
        
        
        
        %longLiteral_16522 = add i64 1, 0
        
        call ccc void @sharePositive(%Pos %pureApp_16517)
        %pureApp_16521 = call ccc %Pos @unsafeSet_2492(%Pos %pureApp_16517, i64 %longLiteral_16522, %Pos %make_16465)
        call ccc void @erasePositive(%Pos %pureApp_16521)
        
        
        
        %longLiteral_16524 = add i64 2, 0
        
        call ccc void @sharePositive(%Pos %pureApp_16517)
        %pureApp_16523 = call ccc %Pos @unsafeSet_2492(%Pos %pureApp_16517, i64 %longLiteral_16524, %Pos %make_16477)
        call ccc void @erasePositive(%Pos %pureApp_16523)
        
        
        
        %longLiteral_16526 = add i64 3, 0
        
        call ccc void @sharePositive(%Pos %pureApp_16517)
        %pureApp_16525 = call ccc %Pos @unsafeSet_2492(%Pos %pureApp_16517, i64 %longLiteral_16526, %Pos %make_16489)
        call ccc void @erasePositive(%Pos %pureApp_16525)
        
        
        
        %longLiteral_16528 = add i64 4, 0
        
        call ccc void @sharePositive(%Pos %pureApp_16517)
        %pureApp_16527 = call ccc %Pos @unsafeSet_2492(%Pos %pureApp_16517, i64 %longLiteral_16528, %Pos %make_16501)
        call ccc void @erasePositive(%Pos %pureApp_16527)
        
        
        
        %doubleLiteral_16529 = fadd double 0.0, 0.0
        
        
        %stackPointer_1180 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_16435_pointer_1181 = getelementptr <{i64}>, %StackPointer %stackPointer_1180, i64 0, i32 0
        store i64 %pureApp_16451, ptr %tmp_16435_pointer_1181, !noalias !2
        %returnAddress_pointer_1182 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_1180, i64 0, i32 1, i32 0
        %sharer_pointer_1183 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_1180, i64 0, i32 1, i32 1
        %eraser_pointer_1184 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_1180, i64 0, i32 1, i32 2
        store ptr @returnAddress_95, ptr %returnAddress_pointer_1182, !noalias !2
        store ptr @sharer_1173, ptr %sharer_pointer_1183, !noalias !2
        store ptr @eraser_1177, ptr %eraser_pointer_1184, !noalias !2
        %px_9_2077_11716 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_1194 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_3045_8_2076_10770_pointer_1195 = getelementptr <{double}>, %StackPointer %stackPointer_1194, i64 0, i32 0
        store double %doubleLiteral_16529, ptr %v_r_3045_8_2076_10770_pointer_1195, !noalias !2
        %returnAddress_pointer_1196 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1194, i64 0, i32 1, i32 0
        %sharer_pointer_1197 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1194, i64 0, i32 1, i32 1
        %eraser_pointer_1198 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1194, i64 0, i32 1, i32 2
        store ptr @returnAddress_1185, ptr %returnAddress_pointer_1196, !noalias !2
        store ptr @sharer_714, ptr %sharer_pointer_1197, !noalias !2
        store ptr @eraser_718, ptr %eraser_pointer_1198, !noalias !2
        
        %doubleLiteral_16648 = fadd double 0.0, 0.0
        
        
        %py_11_2079_10749 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_1208 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_3046_10_2078_11690_pointer_1209 = getelementptr <{double}>, %StackPointer %stackPointer_1208, i64 0, i32 0
        store double %doubleLiteral_16648, ptr %v_r_3046_10_2078_11690_pointer_1209, !noalias !2
        %returnAddress_pointer_1210 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1208, i64 0, i32 1, i32 0
        %sharer_pointer_1211 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1208, i64 0, i32 1, i32 1
        %eraser_pointer_1212 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1208, i64 0, i32 1, i32 2
        store ptr @returnAddress_1199, ptr %returnAddress_pointer_1210, !noalias !2
        store ptr @sharer_714, ptr %sharer_pointer_1211, !noalias !2
        store ptr @eraser_718, ptr %eraser_pointer_1212, !noalias !2
        
        %doubleLiteral_16650 = fadd double 0.0, 0.0
        
        
        %pz_13_2081_11683 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_1222 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_3047_12_2080_10680_pointer_1223 = getelementptr <{double}>, %StackPointer %stackPointer_1222, i64 0, i32 0
        store double %doubleLiteral_16650, ptr %v_r_3047_12_2080_10680_pointer_1223, !noalias !2
        %returnAddress_pointer_1224 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1222, i64 0, i32 1, i32 0
        %sharer_pointer_1225 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1222, i64 0, i32 1, i32 1
        %eraser_pointer_1226 = getelementptr <{<{double}>, %FrameHeader}>, %StackPointer %stackPointer_1222, i64 0, i32 1, i32 2
        store ptr @returnAddress_1213, ptr %returnAddress_pointer_1224, !noalias !2
        store ptr @sharer_714, ptr %sharer_pointer_1225, !noalias !2
        store ptr @eraser_718, ptr %eraser_pointer_1226, !noalias !2
        
        call ccc void @sharePositive(%Pos %pureApp_16517)
        %pureApp_16652 = call ccc i64 @size_2483(%Pos %pureApp_16517)
        
        
        call ccc void @sharePositive(%Pos %pureApp_16517)
        %stackPointer_1743 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %tmp_16320_pointer_1744 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1743, i64 0, i32 0
        store %Pos %pureApp_16517, ptr %tmp_16320_pointer_1744, !noalias !2
        %py_11_2079_10749_pointer_1745 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1743, i64 0, i32 1
        store %Reference %py_11_2079_10749, ptr %py_11_2079_10749_pointer_1745, !noalias !2
        %pz_13_2081_11683_pointer_1746 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1743, i64 0, i32 2
        store %Reference %pz_13_2081_11683, ptr %pz_13_2081_11683_pointer_1746, !noalias !2
        %tmp_16294_pointer_1747 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1743, i64 0, i32 3
        store double %pureApp_16455, ptr %tmp_16294_pointer_1747, !noalias !2
        %px_9_2077_11716_pointer_1748 = getelementptr <{%Pos, %Reference, %Reference, double, %Reference}>, %StackPointer %stackPointer_1743, i64 0, i32 4
        store %Reference %px_9_2077_11716, ptr %px_9_2077_11716_pointer_1748, !noalias !2
        %returnAddress_pointer_1749 = getelementptr <{<{%Pos, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1743, i64 0, i32 1, i32 0
        %sharer_pointer_1750 = getelementptr <{<{%Pos, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1743, i64 0, i32 1, i32 1
        %eraser_pointer_1751 = getelementptr <{<{%Pos, %Reference, %Reference, double, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1743, i64 0, i32 1, i32 2
        store ptr @returnAddress_1575, ptr %returnAddress_pointer_1749, !noalias !2
        store ptr @sharer_1724, ptr %sharer_pointer_1750, !noalias !2
        store ptr @eraser_1736, ptr %eraser_pointer_1751, !noalias !2
        
        %longLiteral_16690 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_138_2206_10607(i64 %longLiteral_16690, %Pos %pureApp_16517, %Reference %py_11_2079_10749, %Reference %pz_13_2081_11683, i64 %pureApp_16652, %Reference %px_9_2077_11716, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1757(%Pos %returned_16691, %Stack %stack) {
        
    entry:
        
        %stack_1758 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_1760 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1758, i64 24)
        %returnAddress_pointer_1761 = getelementptr %FrameHeader, %StackPointer %stackPointer_1760, i64 0, i32 0
        %returnAddress_1759 = load %ReturnAddress, ptr %returnAddress_pointer_1761, !noalias !2
        musttail call tailcc void %returnAddress_1759(%Pos %returned_16691, %Stack %stack_1758)
        ret void
}



define ccc void @sharer_1762(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1763 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_1764(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1765 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_1765)
        ret void
}



define ccc void @eraser_1777(%Environment %environment) {
        
    entry:
        
        %tmp_16266_1775_pointer_1778 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_16266_1775 = load %Pos, ptr %tmp_16266_1775_pointer_1778, !noalias !2
        %acc_3_3_5_169_10111_1776_pointer_1779 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_10111_1776 = load %Pos, ptr %acc_3_3_5_169_10111_1776_pointer_1779, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16266_1775)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_10111_1776)
        ret void
}



define tailcc void @toList_1_1_3_167_10159(i64 %start_2_2_4_168_10110, %Pos %acc_3_3_5_169_10111, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_16693 = add i64 1, 0
        
        %pureApp_16692 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_10110, i64 %longLiteral_16693)
        
        
        
        %tag_1770 = extractvalue %Pos %pureApp_16692, 0
        %fields_1771 = extractvalue %Pos %pureApp_16692, 1
        switch i64 %tag_1770, label %label_1772 [i64 0, label %label_1783 i64 1, label %label_1787]
    
    label_1772:
        
        ret void
    
    label_1783:
        
        %pureApp_16694 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_10110)
        
        
        
        %longLiteral_16696 = add i64 1, 0
        
        %pureApp_16695 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_10110, i64 %longLiteral_16696)
        
        
        
        %fields_1773 = call ccc %Object @newObject(ptr @eraser_1777, i64 32)
        %environment_1774 = call ccc %Environment @objectEnvironment(%Object %fields_1773)
        %tmp_16266_pointer_1780 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1774, i64 0, i32 0
        store %Pos %pureApp_16694, ptr %tmp_16266_pointer_1780, !noalias !2
        %acc_3_3_5_169_10111_pointer_1781 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1774, i64 0, i32 1
        store %Pos %acc_3_3_5_169_10111, ptr %acc_3_3_5_169_10111_pointer_1781, !noalias !2
        %make_16697_temporary_1782 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_16697 = insertvalue %Pos %make_16697_temporary_1782, %Object %fields_1773, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_10159(i64 %pureApp_16695, %Pos %make_16697, %Stack %stack)
        ret void
    
    label_1787:
        
        %stackPointer_1785 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1786 = getelementptr %FrameHeader, %StackPointer %stackPointer_1785, i64 0, i32 0
        %returnAddress_1784 = load %ReturnAddress, ptr %returnAddress_pointer_1786, !noalias !2
        musttail call tailcc void %returnAddress_1784(%Pos %acc_3_3_5_169_10111, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1798(%Pos %v_r_3332_32_59_223_10283, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1799 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %p_8_9_9994_pointer_1800 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1799, i64 0, i32 0
        %p_8_9_9994 = load %Prompt, ptr %p_8_9_9994_pointer_1800, !noalias !2
        %tmp_16273_pointer_1801 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1799, i64 0, i32 1
        %tmp_16273 = load i64, ptr %tmp_16273_pointer_1801, !noalias !2
        %index_7_34_198_10231_pointer_1802 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1799, i64 0, i32 2
        %index_7_34_198_10231 = load i64, ptr %index_7_34_198_10231_pointer_1802, !noalias !2
        %v_r_3145_30_194_10257_pointer_1803 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1799, i64 0, i32 3
        %v_r_3145_30_194_10257 = load %Pos, ptr %v_r_3145_30_194_10257_pointer_1803, !noalias !2
        %acc_8_35_199_10120_pointer_1804 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1799, i64 0, i32 4
        %acc_8_35_199_10120 = load i64, ptr %acc_8_35_199_10120_pointer_1804, !noalias !2
        
        %tag_1805 = extractvalue %Pos %v_r_3332_32_59_223_10283, 0
        %fields_1806 = extractvalue %Pos %v_r_3332_32_59_223_10283, 1
        switch i64 %tag_1805, label %label_1807 [i64 1, label %label_1830 i64 0, label %label_1837]
    
    label_1807:
        
        ret void
    
    label_1812:
        
        ret void
    
    label_1818:
        call ccc void @erasePositive(%Pos %v_r_3145_30_194_10257)
        
        %pair_1813 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_9994)
        %k_13_14_4_16073 = extractvalue <{%Resumption, %Stack}> %pair_1813, 0
        %stack_1814 = extractvalue <{%Resumption, %Stack}> %pair_1813, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_16073)
        
        %longLiteral_16709 = add i64 10, 0
        
        
        
        %pureApp_16710 = call ccc %Pos @boxInt_301(i64 %longLiteral_16709)
        
        
        
        %stackPointer_1816 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1814, i64 24)
        %returnAddress_pointer_1817 = getelementptr %FrameHeader, %StackPointer %stackPointer_1816, i64 0, i32 0
        %returnAddress_1815 = load %ReturnAddress, ptr %returnAddress_pointer_1817, !noalias !2
        musttail call tailcc void %returnAddress_1815(%Pos %pureApp_16710, %Stack %stack_1814)
        ret void
    
    label_1821:
        
        ret void
    
    label_1827:
        call ccc void @erasePositive(%Pos %v_r_3145_30_194_10257)
        
        %pair_1822 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_9994)
        %k_13_14_4_16072 = extractvalue <{%Resumption, %Stack}> %pair_1822, 0
        %stack_1823 = extractvalue <{%Resumption, %Stack}> %pair_1822, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_16072)
        
        %longLiteral_16713 = add i64 10, 0
        
        
        
        %pureApp_16714 = call ccc %Pos @boxInt_301(i64 %longLiteral_16713)
        
        
        
        %stackPointer_1825 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1823, i64 24)
        %returnAddress_pointer_1826 = getelementptr %FrameHeader, %StackPointer %stackPointer_1825, i64 0, i32 0
        %returnAddress_1824 = load %ReturnAddress, ptr %returnAddress_pointer_1826, !noalias !2
        musttail call tailcc void %returnAddress_1824(%Pos %pureApp_16714, %Stack %stack_1823)
        ret void
    
    label_1828:
        
        %longLiteral_16716 = add i64 1, 0
        
        %pureApp_16715 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_10231, i64 %longLiteral_16716)
        
        
        
        %longLiteral_16718 = add i64 10, 0
        
        %pureApp_16717 = call ccc i64 @infixMul_99(i64 %longLiteral_16718, i64 %acc_8_35_199_10120)
        
        
        
        %pureApp_16719 = call ccc i64 @toInt_2085(i64 %pureApp_16706)
        
        
        
        %pureApp_16720 = call ccc i64 @infixSub_105(i64 %pureApp_16719, i64 %tmp_16273)
        
        
        
        %pureApp_16721 = call ccc i64 @infixAdd_96(i64 %pureApp_16717, i64 %pureApp_16720)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_10203(i64 %pureApp_16715, i64 %pureApp_16721, %Prompt %p_8_9_9994, i64 %tmp_16273, %Pos %v_r_3145_30_194_10257, %Stack %stack)
        ret void
    
    label_1829:
        
        %intLiteral_16712 = add i64 57, 0
        
        %pureApp_16711 = call ccc %Pos @infixLte_2093(i64 %pureApp_16706, i64 %intLiteral_16712)
        
        
        
        %tag_1819 = extractvalue %Pos %pureApp_16711, 0
        %fields_1820 = extractvalue %Pos %pureApp_16711, 1
        switch i64 %tag_1819, label %label_1821 [i64 0, label %label_1827 i64 1, label %label_1828]
    
    label_1830:
        %environment_1808 = call ccc %Environment @objectEnvironment(%Object %fields_1806)
        %v_coe_4150_46_73_237_10092_pointer_1809 = getelementptr <{%Pos}>, %Environment %environment_1808, i64 0, i32 0
        %v_coe_4150_46_73_237_10092 = load %Pos, ptr %v_coe_4150_46_73_237_10092_pointer_1809, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_4150_46_73_237_10092)
        call ccc void @eraseObject(%Object %fields_1806)
        
        %pureApp_16706 = call ccc i64 @unboxChar_313(%Pos %v_coe_4150_46_73_237_10092)
        
        
        
        %intLiteral_16708 = add i64 48, 0
        
        %pureApp_16707 = call ccc %Pos @infixGte_2099(i64 %pureApp_16706, i64 %intLiteral_16708)
        
        
        
        %tag_1810 = extractvalue %Pos %pureApp_16707, 0
        %fields_1811 = extractvalue %Pos %pureApp_16707, 1
        switch i64 %tag_1810, label %label_1812 [i64 0, label %label_1818 i64 1, label %label_1829]
    
    label_1837:
        %environment_1831 = call ccc %Environment @objectEnvironment(%Object %fields_1806)
        %v_y_3339_76_103_267_16704_pointer_1832 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1831, i64 0, i32 0
        %v_y_3339_76_103_267_16704 = load %Pos, ptr %v_y_3339_76_103_267_16704_pointer_1832, !noalias !2
        %v_y_3340_77_104_268_16705_pointer_1833 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1831, i64 0, i32 1
        %v_y_3340_77_104_268_16705 = load %Pos, ptr %v_y_3340_77_104_268_16705_pointer_1833, !noalias !2
        call ccc void @eraseObject(%Object %fields_1806)
        call ccc void @erasePositive(%Pos %v_r_3145_30_194_10257)
        
        %stackPointer_1835 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1836 = getelementptr %FrameHeader, %StackPointer %stackPointer_1835, i64 0, i32 0
        %returnAddress_1834 = load %ReturnAddress, ptr %returnAddress_pointer_1836, !noalias !2
        musttail call tailcc void %returnAddress_1834(i64 %acc_8_35_199_10120, %Stack %stack)
        ret void
}



define ccc void @sharer_1843(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1844 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_9994_1838_pointer_1845 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1844, i64 0, i32 0
        %p_8_9_9994_1838 = load %Prompt, ptr %p_8_9_9994_1838_pointer_1845, !noalias !2
        %tmp_16273_1839_pointer_1846 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1844, i64 0, i32 1
        %tmp_16273_1839 = load i64, ptr %tmp_16273_1839_pointer_1846, !noalias !2
        %index_7_34_198_10231_1840_pointer_1847 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1844, i64 0, i32 2
        %index_7_34_198_10231_1840 = load i64, ptr %index_7_34_198_10231_1840_pointer_1847, !noalias !2
        %v_r_3145_30_194_10257_1841_pointer_1848 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1844, i64 0, i32 3
        %v_r_3145_30_194_10257_1841 = load %Pos, ptr %v_r_3145_30_194_10257_1841_pointer_1848, !noalias !2
        %acc_8_35_199_10120_1842_pointer_1849 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1844, i64 0, i32 4
        %acc_8_35_199_10120_1842 = load i64, ptr %acc_8_35_199_10120_1842_pointer_1849, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3145_30_194_10257_1841)
        call ccc void @shareFrames(%StackPointer %stackPointer_1844)
        ret void
}



define ccc void @eraser_1855(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1856 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_9994_1850_pointer_1857 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1856, i64 0, i32 0
        %p_8_9_9994_1850 = load %Prompt, ptr %p_8_9_9994_1850_pointer_1857, !noalias !2
        %tmp_16273_1851_pointer_1858 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1856, i64 0, i32 1
        %tmp_16273_1851 = load i64, ptr %tmp_16273_1851_pointer_1858, !noalias !2
        %index_7_34_198_10231_1852_pointer_1859 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1856, i64 0, i32 2
        %index_7_34_198_10231_1852 = load i64, ptr %index_7_34_198_10231_1852_pointer_1859, !noalias !2
        %v_r_3145_30_194_10257_1853_pointer_1860 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1856, i64 0, i32 3
        %v_r_3145_30_194_10257_1853 = load %Pos, ptr %v_r_3145_30_194_10257_1853_pointer_1860, !noalias !2
        %acc_8_35_199_10120_1854_pointer_1861 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1856, i64 0, i32 4
        %acc_8_35_199_10120_1854 = load i64, ptr %acc_8_35_199_10120_1854_pointer_1861, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3145_30_194_10257_1853)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1856)
        ret void
}



define tailcc void @returnAddress_1872(%Pos %returned_16722, %Stack %stack) {
        
    entry:
        
        %stack_1873 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_1875 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1873, i64 24)
        %returnAddress_pointer_1876 = getelementptr %FrameHeader, %StackPointer %stackPointer_1875, i64 0, i32 0
        %returnAddress_1874 = load %ReturnAddress, ptr %returnAddress_pointer_1876, !noalias !2
        musttail call tailcc void %returnAddress_1874(%Pos %returned_16722, %Stack %stack_1873)
        ret void
}



define tailcc void @Exception_7_19_46_210_10166_clause_1881(%Object %closure, %Pos %exc_8_20_47_211_10187, %Pos %msg_9_21_48_212_10059, %Stack %stack) {
        
    entry:
        
        %environment_1882 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_10310_pointer_1883 = getelementptr <{%Prompt}>, %Environment %environment_1882, i64 0, i32 0
        %p_6_18_45_209_10310 = load %Prompt, ptr %p_6_18_45_209_10310_pointer_1883, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_1884 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_10310)
        %k_11_23_50_214_10319 = extractvalue <{%Resumption, %Stack}> %pair_1884, 0
        %stack_1885 = extractvalue <{%Resumption, %Stack}> %pair_1884, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_10319)
        
        %fields_1886 = call ccc %Object @newObject(ptr @eraser_1777, i64 32)
        %environment_1887 = call ccc %Environment @objectEnvironment(%Object %fields_1886)
        %exc_8_20_47_211_10187_pointer_1890 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1887, i64 0, i32 0
        store %Pos %exc_8_20_47_211_10187, ptr %exc_8_20_47_211_10187_pointer_1890, !noalias !2
        %msg_9_21_48_212_10059_pointer_1891 = getelementptr <{%Pos, %Pos}>, %Environment %environment_1887, i64 0, i32 1
        store %Pos %msg_9_21_48_212_10059, ptr %msg_9_21_48_212_10059_pointer_1891, !noalias !2
        %make_16723_temporary_1892 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16723 = insertvalue %Pos %make_16723_temporary_1892, %Object %fields_1886, 1
        
        
        
        %stackPointer_1894 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1885, i64 24)
        %returnAddress_pointer_1895 = getelementptr %FrameHeader, %StackPointer %stackPointer_1894, i64 0, i32 0
        %returnAddress_1893 = load %ReturnAddress, ptr %returnAddress_pointer_1895, !noalias !2
        musttail call tailcc void %returnAddress_1893(%Pos %make_16723, %Stack %stack_1885)
        ret void
}


@vtable_1896 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_10166_clause_1881]


define ccc void @eraser_1900(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_10310_1899_pointer_1901 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_10310_1899 = load %Prompt, ptr %p_6_18_45_209_10310_1899_pointer_1901, !noalias !2
        ret void
}



define ccc void @eraser_1908(%Environment %environment) {
        
    entry:
        
        %tmp_16275_1907_pointer_1909 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_16275_1907 = load %Pos, ptr %tmp_16275_1907_pointer_1909, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_16275_1907)
        ret void
}



define tailcc void @returnAddress_1904(i64 %v_coe_4149_6_28_55_219_10202, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_16724 = call ccc %Pos @boxChar_311(i64 %v_coe_4149_6_28_55_219_10202)
        
        
        
        %fields_1905 = call ccc %Object @newObject(ptr @eraser_1908, i64 16)
        %environment_1906 = call ccc %Environment @objectEnvironment(%Object %fields_1905)
        %tmp_16275_pointer_1910 = getelementptr <{%Pos}>, %Environment %environment_1906, i64 0, i32 0
        store %Pos %pureApp_16724, ptr %tmp_16275_pointer_1910, !noalias !2
        %make_16725_temporary_1911 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_16725 = insertvalue %Pos %make_16725_temporary_1911, %Object %fields_1905, 1
        
        
        
        %stackPointer_1913 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1914 = getelementptr %FrameHeader, %StackPointer %stackPointer_1913, i64 0, i32 0
        %returnAddress_1912 = load %ReturnAddress, ptr %returnAddress_pointer_1914, !noalias !2
        musttail call tailcc void %returnAddress_1912(%Pos %make_16725, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_10203(i64 %index_7_34_198_10231, i64 %acc_8_35_199_10120, %Prompt %p_8_9_9994, i64 %tmp_16273, %Pos %v_r_3145_30_194_10257, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_3145_30_194_10257)
        %stackPointer_1862 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %p_8_9_9994_pointer_1863 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1862, i64 0, i32 0
        store %Prompt %p_8_9_9994, ptr %p_8_9_9994_pointer_1863, !noalias !2
        %tmp_16273_pointer_1864 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1862, i64 0, i32 1
        store i64 %tmp_16273, ptr %tmp_16273_pointer_1864, !noalias !2
        %index_7_34_198_10231_pointer_1865 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1862, i64 0, i32 2
        store i64 %index_7_34_198_10231, ptr %index_7_34_198_10231_pointer_1865, !noalias !2
        %v_r_3145_30_194_10257_pointer_1866 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1862, i64 0, i32 3
        store %Pos %v_r_3145_30_194_10257, ptr %v_r_3145_30_194_10257_pointer_1866, !noalias !2
        %acc_8_35_199_10120_pointer_1867 = getelementptr <{%Prompt, i64, i64, %Pos, i64}>, %StackPointer %stackPointer_1862, i64 0, i32 4
        store i64 %acc_8_35_199_10120, ptr %acc_8_35_199_10120_pointer_1867, !noalias !2
        %returnAddress_pointer_1868 = getelementptr <{<{%Prompt, i64, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1862, i64 0, i32 1, i32 0
        %sharer_pointer_1869 = getelementptr <{<{%Prompt, i64, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1862, i64 0, i32 1, i32 1
        %eraser_pointer_1870 = getelementptr <{<{%Prompt, i64, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1862, i64 0, i32 1, i32 2
        store ptr @returnAddress_1798, ptr %returnAddress_pointer_1868, !noalias !2
        store ptr @sharer_1843, ptr %sharer_pointer_1869, !noalias !2
        store ptr @eraser_1855, ptr %eraser_pointer_1870, !noalias !2
        
        %stack_1871 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_10310 = call ccc %Prompt @currentPrompt(%Stack %stack_1871)
        %stackPointer_1877 = call ccc %StackPointer @stackAllocate(%Stack %stack_1871, i64 24)
        %returnAddress_pointer_1878 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1877, i64 0, i32 1, i32 0
        %sharer_pointer_1879 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1877, i64 0, i32 1, i32 1
        %eraser_pointer_1880 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1877, i64 0, i32 1, i32 2
        store ptr @returnAddress_1872, ptr %returnAddress_pointer_1878, !noalias !2
        store ptr @sharer_1762, ptr %sharer_pointer_1879, !noalias !2
        store ptr @eraser_1764, ptr %eraser_pointer_1880, !noalias !2
        
        %closure_1897 = call ccc %Object @newObject(ptr @eraser_1900, i64 8)
        %environment_1898 = call ccc %Environment @objectEnvironment(%Object %closure_1897)
        %p_6_18_45_209_10310_pointer_1902 = getelementptr <{%Prompt}>, %Environment %environment_1898, i64 0, i32 0
        store %Prompt %p_6_18_45_209_10310, ptr %p_6_18_45_209_10310_pointer_1902, !noalias !2
        %vtable_temporary_1903 = insertvalue %Neg zeroinitializer, ptr @vtable_1896, 0
        %Exception_7_19_46_210_10166 = insertvalue %Neg %vtable_temporary_1903, %Object %closure_1897, 1
        %stackPointer_1915 = call ccc %StackPointer @stackAllocate(%Stack %stack_1871, i64 24)
        %returnAddress_pointer_1916 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1915, i64 0, i32 1, i32 0
        %sharer_pointer_1917 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1915, i64 0, i32 1, i32 1
        %eraser_pointer_1918 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1915, i64 0, i32 1, i32 2
        store ptr @returnAddress_1904, ptr %returnAddress_pointer_1916, !noalias !2
        store ptr @sharer_698, ptr %sharer_pointer_1917, !noalias !2
        store ptr @eraser_700, ptr %eraser_pointer_1918, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_3145_30_194_10257, i64 %index_7_34_198_10231, %Neg %Exception_7_19_46_210_10166, %Stack %stack_1871)
        ret void
}



define tailcc void @Exception_9_106_133_297_10062_clause_1919(%Object %closure, %Pos %exception_10_107_134_298_16726, %Pos %msg_11_108_135_299_16727, %Stack %stack) {
        
    entry:
        
        %environment_1920 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_9994_pointer_1921 = getelementptr <{%Prompt}>, %Environment %environment_1920, i64 0, i32 0
        %p_8_9_9994 = load %Prompt, ptr %p_8_9_9994_pointer_1921, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_16726)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_16727)
        
        %pair_1922 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_9994)
        %k_13_14_4_16256 = extractvalue <{%Resumption, %Stack}> %pair_1922, 0
        %stack_1923 = extractvalue <{%Resumption, %Stack}> %pair_1922, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_16256)
        
        %longLiteral_16728 = add i64 10, 0
        
        
        
        %pureApp_16729 = call ccc %Pos @boxInt_301(i64 %longLiteral_16728)
        
        
        
        %stackPointer_1925 = call ccc %StackPointer @stackDeallocate(%Stack %stack_1923, i64 24)
        %returnAddress_pointer_1926 = getelementptr %FrameHeader, %StackPointer %stackPointer_1925, i64 0, i32 0
        %returnAddress_1924 = load %ReturnAddress, ptr %returnAddress_pointer_1926, !noalias !2
        musttail call tailcc void %returnAddress_1924(%Pos %pureApp_16729, %Stack %stack_1923)
        ret void
}


@vtable_1927 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_10062_clause_1919]


define tailcc void @returnAddress_1938(i64 %v_coe_4154_22_131_158_322_10096, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_16732 = call ccc %Pos @boxInt_301(i64 %v_coe_4154_22_131_158_322_10096)
        
        
        
        
        
        %pureApp_16733 = call ccc i64 @unboxInt_303(%Pos %pureApp_16732)
        
        
        
        %pureApp_16734 = call ccc %Pos @boxInt_301(i64 %pureApp_16733)
        
        
        
        %stackPointer_1940 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1941 = getelementptr %FrameHeader, %StackPointer %stackPointer_1940, i64 0, i32 0
        %returnAddress_1939 = load %ReturnAddress, ptr %returnAddress_pointer_1941, !noalias !2
        musttail call tailcc void %returnAddress_1939(%Pos %pureApp_16734, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1950(i64 %v_r_3346_1_9_20_129_156_320_10311, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_16738 = add i64 0, 0
        
        %pureApp_16737 = call ccc i64 @infixSub_105(i64 %longLiteral_16738, i64 %v_r_3346_1_9_20_129_156_320_10311)
        
        
        
        %stackPointer_1952 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1953 = getelementptr %FrameHeader, %StackPointer %stackPointer_1952, i64 0, i32 0
        %returnAddress_1951 = load %ReturnAddress, ptr %returnAddress_pointer_1953, !noalias !2
        musttail call tailcc void %returnAddress_1951(i64 %pureApp_16737, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1933(i64 %v_r_3345_3_14_123_150_314_10196, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1934 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_9994_pointer_1935 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1934, i64 0, i32 0
        %p_8_9_9994 = load %Prompt, ptr %p_8_9_9994_pointer_1935, !noalias !2
        %tmp_16273_pointer_1936 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1934, i64 0, i32 1
        %tmp_16273 = load i64, ptr %tmp_16273_pointer_1936, !noalias !2
        %v_r_3145_30_194_10257_pointer_1937 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1934, i64 0, i32 2
        %v_r_3145_30_194_10257 = load %Pos, ptr %v_r_3145_30_194_10257_pointer_1937, !noalias !2
        
        %intLiteral_16731 = add i64 45, 0
        
        %pureApp_16730 = call ccc %Pos @infixEq_78(i64 %v_r_3345_3_14_123_150_314_10196, i64 %intLiteral_16731)
        
        
        %stackPointer_1942 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1943 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1942, i64 0, i32 1, i32 0
        %sharer_pointer_1944 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1942, i64 0, i32 1, i32 1
        %eraser_pointer_1945 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1942, i64 0, i32 1, i32 2
        store ptr @returnAddress_1938, ptr %returnAddress_pointer_1943, !noalias !2
        store ptr @sharer_698, ptr %sharer_pointer_1944, !noalias !2
        store ptr @eraser_700, ptr %eraser_pointer_1945, !noalias !2
        
        %tag_1946 = extractvalue %Pos %pureApp_16730, 0
        %fields_1947 = extractvalue %Pos %pureApp_16730, 1
        switch i64 %tag_1946, label %label_1948 [i64 0, label %label_1949 i64 1, label %label_1958]
    
    label_1948:
        
        ret void
    
    label_1949:
        
        %longLiteral_16735 = add i64 0, 0
        
        %longLiteral_16736 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_10203(i64 %longLiteral_16735, i64 %longLiteral_16736, %Prompt %p_8_9_9994, i64 %tmp_16273, %Pos %v_r_3145_30_194_10257, %Stack %stack)
        ret void
    
    label_1958:
        %stackPointer_1954 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1955 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1954, i64 0, i32 1, i32 0
        %sharer_pointer_1956 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1954, i64 0, i32 1, i32 1
        %eraser_pointer_1957 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1954, i64 0, i32 1, i32 2
        store ptr @returnAddress_1950, ptr %returnAddress_pointer_1955, !noalias !2
        store ptr @sharer_698, ptr %sharer_pointer_1956, !noalias !2
        store ptr @eraser_700, ptr %eraser_pointer_1957, !noalias !2
        
        %longLiteral_16739 = add i64 1, 0
        
        %longLiteral_16740 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_10203(i64 %longLiteral_16739, i64 %longLiteral_16740, %Prompt %p_8_9_9994, i64 %tmp_16273, %Pos %v_r_3145_30_194_10257, %Stack %stack)
        ret void
}



define ccc void @sharer_1962(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1963 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_9994_1959_pointer_1964 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1963, i64 0, i32 0
        %p_8_9_9994_1959 = load %Prompt, ptr %p_8_9_9994_1959_pointer_1964, !noalias !2
        %tmp_16273_1960_pointer_1965 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1963, i64 0, i32 1
        %tmp_16273_1960 = load i64, ptr %tmp_16273_1960_pointer_1965, !noalias !2
        %v_r_3145_30_194_10257_1961_pointer_1966 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1963, i64 0, i32 2
        %v_r_3145_30_194_10257_1961 = load %Pos, ptr %v_r_3145_30_194_10257_1961_pointer_1966, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3145_30_194_10257_1961)
        call ccc void @shareFrames(%StackPointer %stackPointer_1963)
        ret void
}



define ccc void @eraser_1970(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1971 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_9994_1967_pointer_1972 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1971, i64 0, i32 0
        %p_8_9_9994_1967 = load %Prompt, ptr %p_8_9_9994_1967_pointer_1972, !noalias !2
        %tmp_16273_1968_pointer_1973 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1971, i64 0, i32 1
        %tmp_16273_1968 = load i64, ptr %tmp_16273_1968_pointer_1973, !noalias !2
        %v_r_3145_30_194_10257_1969_pointer_1974 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1971, i64 0, i32 2
        %v_r_3145_30_194_10257_1969 = load %Pos, ptr %v_r_3145_30_194_10257_1969_pointer_1974, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3145_30_194_10257_1969)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1971)
        ret void
}



define tailcc void @returnAddress_1795(%Pos %v_r_3145_30_194_10257, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1796 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_9994_pointer_1797 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1796, i64 0, i32 0
        %p_8_9_9994 = load %Prompt, ptr %p_8_9_9994_pointer_1797, !noalias !2
        
        %intLiteral_16703 = add i64 48, 0
        
        %pureApp_16702 = call ccc i64 @toInt_2085(i64 %intLiteral_16703)
        
        
        
        %closure_1928 = call ccc %Object @newObject(ptr @eraser_1900, i64 8)
        %environment_1929 = call ccc %Environment @objectEnvironment(%Object %closure_1928)
        %p_8_9_9994_pointer_1931 = getelementptr <{%Prompt}>, %Environment %environment_1929, i64 0, i32 0
        store %Prompt %p_8_9_9994, ptr %p_8_9_9994_pointer_1931, !noalias !2
        %vtable_temporary_1932 = insertvalue %Neg zeroinitializer, ptr @vtable_1927, 0
        %Exception_9_106_133_297_10062 = insertvalue %Neg %vtable_temporary_1932, %Object %closure_1928, 1
        call ccc void @sharePositive(%Pos %v_r_3145_30_194_10257)
        %stackPointer_1975 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_9994_pointer_1976 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1975, i64 0, i32 0
        store %Prompt %p_8_9_9994, ptr %p_8_9_9994_pointer_1976, !noalias !2
        %tmp_16273_pointer_1977 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1975, i64 0, i32 1
        store i64 %pureApp_16702, ptr %tmp_16273_pointer_1977, !noalias !2
        %v_r_3145_30_194_10257_pointer_1978 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_1975, i64 0, i32 2
        store %Pos %v_r_3145_30_194_10257, ptr %v_r_3145_30_194_10257_pointer_1978, !noalias !2
        %returnAddress_pointer_1979 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1975, i64 0, i32 1, i32 0
        %sharer_pointer_1980 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1975, i64 0, i32 1, i32 1
        %eraser_pointer_1981 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1975, i64 0, i32 1, i32 2
        store ptr @returnAddress_1933, ptr %returnAddress_pointer_1979, !noalias !2
        store ptr @sharer_1962, ptr %sharer_pointer_1980, !noalias !2
        store ptr @eraser_1970, ptr %eraser_pointer_1981, !noalias !2
        
        %longLiteral_16741 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_3145_30_194_10257, i64 %longLiteral_16741, %Neg %Exception_9_106_133_297_10062, %Stack %stack)
        ret void
}



define ccc void @sharer_1983(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1984 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_9994_1982_pointer_1985 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1984, i64 0, i32 0
        %p_8_9_9994_1982 = load %Prompt, ptr %p_8_9_9994_1982_pointer_1985, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1984)
        ret void
}



define ccc void @eraser_1987(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1988 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_9994_1986_pointer_1989 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1988, i64 0, i32 0
        %p_8_9_9994_1986 = load %Prompt, ptr %p_8_9_9994_1986_pointer_1989, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1988)
        ret void
}


@utf8StringLiteral_16742.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_1792(%Pos %v_r_3144_24_188_10108, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1793 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_9994_pointer_1794 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1793, i64 0, i32 0
        %p_8_9_9994 = load %Prompt, ptr %p_8_9_9994_pointer_1794, !noalias !2
        %stackPointer_1990 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_9994_pointer_1991 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1990, i64 0, i32 0
        store %Prompt %p_8_9_9994, ptr %p_8_9_9994_pointer_1991, !noalias !2
        %returnAddress_pointer_1992 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1990, i64 0, i32 1, i32 0
        %sharer_pointer_1993 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1990, i64 0, i32 1, i32 1
        %eraser_pointer_1994 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_1990, i64 0, i32 1, i32 2
        store ptr @returnAddress_1795, ptr %returnAddress_pointer_1992, !noalias !2
        store ptr @sharer_1983, ptr %sharer_pointer_1993, !noalias !2
        store ptr @eraser_1987, ptr %eraser_pointer_1994, !noalias !2
        
        %tag_1995 = extractvalue %Pos %v_r_3144_24_188_10108, 0
        %fields_1996 = extractvalue %Pos %v_r_3144_24_188_10108, 1
        switch i64 %tag_1995, label %label_1997 [i64 0, label %label_2001 i64 1, label %label_2007]
    
    label_1997:
        
        ret void
    
    label_2001:
        
        %utf8StringLiteral_16742 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_16742.lit)
        
        %stackPointer_1999 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2000 = getelementptr %FrameHeader, %StackPointer %stackPointer_1999, i64 0, i32 0
        %returnAddress_1998 = load %ReturnAddress, ptr %returnAddress_pointer_2000, !noalias !2
        musttail call tailcc void %returnAddress_1998(%Pos %utf8StringLiteral_16742, %Stack %stack)
        ret void
    
    label_2007:
        %environment_2002 = call ccc %Environment @objectEnvironment(%Object %fields_1996)
        %v_y_3976_8_29_193_10125_pointer_2003 = getelementptr <{%Pos}>, %Environment %environment_2002, i64 0, i32 0
        %v_y_3976_8_29_193_10125 = load %Pos, ptr %v_y_3976_8_29_193_10125_pointer_2003, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3976_8_29_193_10125)
        call ccc void @eraseObject(%Object %fields_1996)
        
        %stackPointer_2005 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2006 = getelementptr %FrameHeader, %StackPointer %stackPointer_2005, i64 0, i32 0
        %returnAddress_2004 = load %ReturnAddress, ptr %returnAddress_pointer_2006, !noalias !2
        musttail call tailcc void %returnAddress_2004(%Pos %v_y_3976_8_29_193_10125, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1789(%Pos %v_r_3143_13_177_10243, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1790 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_9994_pointer_1791 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_1790, i64 0, i32 0
        %p_8_9_9994 = load %Prompt, ptr %p_8_9_9994_pointer_1791, !noalias !2
        %stackPointer_2010 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_9994_pointer_2011 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_2010, i64 0, i32 0
        store %Prompt %p_8_9_9994, ptr %p_8_9_9994_pointer_2011, !noalias !2
        %returnAddress_pointer_2012 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_2010, i64 0, i32 1, i32 0
        %sharer_pointer_2013 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_2010, i64 0, i32 1, i32 1
        %eraser_pointer_2014 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_2010, i64 0, i32 1, i32 2
        store ptr @returnAddress_1792, ptr %returnAddress_pointer_2012, !noalias !2
        store ptr @sharer_1983, ptr %sharer_pointer_2013, !noalias !2
        store ptr @eraser_1987, ptr %eraser_pointer_2014, !noalias !2
        
        %tag_2015 = extractvalue %Pos %v_r_3143_13_177_10243, 0
        %fields_2016 = extractvalue %Pos %v_r_3143_13_177_10243, 1
        switch i64 %tag_2015, label %label_2017 [i64 0, label %label_2022 i64 1, label %label_2034]
    
    label_2017:
        
        ret void
    
    label_2022:
        
        %make_16743_temporary_2018 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16743 = insertvalue %Pos %make_16743_temporary_2018, %Object null, 1
        
        
        
        %stackPointer_2020 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2021 = getelementptr %FrameHeader, %StackPointer %stackPointer_2020, i64 0, i32 0
        %returnAddress_2019 = load %ReturnAddress, ptr %returnAddress_pointer_2021, !noalias !2
        musttail call tailcc void %returnAddress_2019(%Pos %make_16743, %Stack %stack)
        ret void
    
    label_2034:
        %environment_2023 = call ccc %Environment @objectEnvironment(%Object %fields_2016)
        %v_y_3485_10_21_185_10240_pointer_2024 = getelementptr <{%Pos, %Pos}>, %Environment %environment_2023, i64 0, i32 0
        %v_y_3485_10_21_185_10240 = load %Pos, ptr %v_y_3485_10_21_185_10240_pointer_2024, !noalias !2
        %v_y_3486_11_22_186_10090_pointer_2025 = getelementptr <{%Pos, %Pos}>, %Environment %environment_2023, i64 0, i32 1
        %v_y_3486_11_22_186_10090 = load %Pos, ptr %v_y_3486_11_22_186_10090_pointer_2025, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3485_10_21_185_10240)
        call ccc void @eraseObject(%Object %fields_2016)
        
        %fields_2026 = call ccc %Object @newObject(ptr @eraser_1908, i64 16)
        %environment_2027 = call ccc %Environment @objectEnvironment(%Object %fields_2026)
        %v_y_3485_10_21_185_10240_pointer_2029 = getelementptr <{%Pos}>, %Environment %environment_2027, i64 0, i32 0
        store %Pos %v_y_3485_10_21_185_10240, ptr %v_y_3485_10_21_185_10240_pointer_2029, !noalias !2
        %make_16744_temporary_2030 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_16744 = insertvalue %Pos %make_16744_temporary_2030, %Object %fields_2026, 1
        
        
        
        %stackPointer_2032 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2033 = getelementptr %FrameHeader, %StackPointer %stackPointer_2032, i64 0, i32 0
        %returnAddress_2031 = load %ReturnAddress, ptr %returnAddress_pointer_2033, !noalias !2
        musttail call tailcc void %returnAddress_2031(%Pos %make_16744, %Stack %stack)
        ret void
}



define tailcc void @main_2855(%Stack %stack) {
        
    entry:
        
        %stackPointer_1752 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1753 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1752, i64 0, i32 1, i32 0
        %sharer_pointer_1754 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1752, i64 0, i32 1, i32 1
        %eraser_pointer_1755 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1752, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_1753, !noalias !2
        store ptr @sharer_698, ptr %sharer_pointer_1754, !noalias !2
        store ptr @eraser_700, ptr %eraser_pointer_1755, !noalias !2
        
        %stack_1756 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_9994 = call ccc %Prompt @currentPrompt(%Stack %stack_1756)
        %stackPointer_1766 = call ccc %StackPointer @stackAllocate(%Stack %stack_1756, i64 24)
        %returnAddress_pointer_1767 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1766, i64 0, i32 1, i32 0
        %sharer_pointer_1768 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1766, i64 0, i32 1, i32 1
        %eraser_pointer_1769 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1766, i64 0, i32 1, i32 2
        store ptr @returnAddress_1757, ptr %returnAddress_pointer_1767, !noalias !2
        store ptr @sharer_1762, ptr %sharer_pointer_1768, !noalias !2
        store ptr @eraser_1764, ptr %eraser_pointer_1769, !noalias !2
        
        %pureApp_16698 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_16700 = add i64 1, 0
        
        %pureApp_16699 = call ccc i64 @infixSub_105(i64 %pureApp_16698, i64 %longLiteral_16700)
        
        
        
        %make_16701_temporary_1788 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16701 = insertvalue %Pos %make_16701_temporary_1788, %Object null, 1
        
        
        %stackPointer_2037 = call ccc %StackPointer @stackAllocate(%Stack %stack_1756, i64 32)
        %p_8_9_9994_pointer_2038 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_2037, i64 0, i32 0
        store %Prompt %p_8_9_9994, ptr %p_8_9_9994_pointer_2038, !noalias !2
        %returnAddress_pointer_2039 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_2037, i64 0, i32 1, i32 0
        %sharer_pointer_2040 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_2037, i64 0, i32 1, i32 1
        %eraser_pointer_2041 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_2037, i64 0, i32 1, i32 2
        store ptr @returnAddress_1789, ptr %returnAddress_pointer_2039, !noalias !2
        store ptr @sharer_1983, ptr %sharer_pointer_2040, !noalias !2
        store ptr @eraser_1987, ptr %eraser_pointer_2041, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_10159(i64 %pureApp_16699, %Pos %make_16701, %Stack %stack_1756)
        ret void
}


@utf8StringLiteral_16442.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_16444.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_16447.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_2042(%Pos %v_r_3414_4212, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_2043 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_2044 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2043, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_2044, !noalias !2
        %index_2107_pointer_2045 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2043, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_2045, !noalias !2
        %Exception_2362_pointer_2046 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2043, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_2046, !noalias !2
        
        %tag_2047 = extractvalue %Pos %v_r_3414_4212, 0
        %fields_2048 = extractvalue %Pos %v_r_3414_4212, 1
        switch i64 %tag_2047, label %label_2049 [i64 0, label %label_2053 i64 1, label %label_2059]
    
    label_2049:
        
        ret void
    
    label_2053:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_16438 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_2051 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2052 = getelementptr %FrameHeader, %StackPointer %stackPointer_2051, i64 0, i32 0
        %returnAddress_2050 = load %ReturnAddress, ptr %returnAddress_pointer_2052, !noalias !2
        musttail call tailcc void %returnAddress_2050(i64 %pureApp_16438, %Stack %stack)
        ret void
    
    label_2059:
        
        %make_16439_temporary_2054 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_16439 = insertvalue %Pos %make_16439_temporary_2054, %Object null, 1
        
        
        
        %pureApp_16440 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_16442 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_16442.lit)
        
        %pureApp_16441 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_16442, %Pos %pureApp_16440)
        
        
        
        %utf8StringLiteral_16444 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_16444.lit)
        
        %pureApp_16443 = call ccc %Pos @infixConcat_35(%Pos %pureApp_16441, %Pos %utf8StringLiteral_16444)
        
        
        
        %pureApp_16445 = call ccc %Pos @infixConcat_35(%Pos %pureApp_16443, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_16447 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_16447.lit)
        
        %pureApp_16446 = call ccc %Pos @infixConcat_35(%Pos %pureApp_16445, %Pos %utf8StringLiteral_16447)
        
        
        
        %vtable_2055 = extractvalue %Neg %Exception_2362, 0
        %closure_2056 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_2057 = getelementptr ptr, ptr %vtable_2055, i64 0
        %functionPointer_2058 = load ptr, ptr %functionPointer_pointer_2057, !noalias !2
        musttail call tailcc void %functionPointer_2058(%Object %closure_2056, %Pos %make_16439, %Pos %pureApp_16446, %Stack %stack)
        ret void
}



define ccc void @sharer_2063(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_2064 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_2060_pointer_2065 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2064, i64 0, i32 0
        %str_2106_2060 = load %Pos, ptr %str_2106_2060_pointer_2065, !noalias !2
        %index_2107_2061_pointer_2066 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2064, i64 0, i32 1
        %index_2107_2061 = load i64, ptr %index_2107_2061_pointer_2066, !noalias !2
        %Exception_2362_2062_pointer_2067 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2064, i64 0, i32 2
        %Exception_2362_2062 = load %Neg, ptr %Exception_2362_2062_pointer_2067, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_2060)
        call ccc void @shareNegative(%Neg %Exception_2362_2062)
        call ccc void @shareFrames(%StackPointer %stackPointer_2064)
        ret void
}



define ccc void @eraser_2071(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_2072 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_2068_pointer_2073 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2072, i64 0, i32 0
        %str_2106_2068 = load %Pos, ptr %str_2106_2068_pointer_2073, !noalias !2
        %index_2107_2069_pointer_2074 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2072, i64 0, i32 1
        %index_2107_2069 = load i64, ptr %index_2107_2069_pointer_2074, !noalias !2
        %Exception_2362_2070_pointer_2075 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2072, i64 0, i32 2
        %Exception_2362_2070 = load %Neg, ptr %Exception_2362_2070_pointer_2075, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_2068)
        call ccc void @eraseNegative(%Neg %Exception_2362_2070)
        call ccc void @eraseFrames(%StackPointer %stackPointer_2072)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_16437 = add i64 0, 0
        
        %pureApp_16436 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_16437)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_2076 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_2077 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2076, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_2077, !noalias !2
        %index_2107_pointer_2078 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2076, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_2078, !noalias !2
        %Exception_2362_pointer_2079 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_2076, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_2079, !noalias !2
        %returnAddress_pointer_2080 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_2076, i64 0, i32 1, i32 0
        %sharer_pointer_2081 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_2076, i64 0, i32 1, i32 1
        %eraser_pointer_2082 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_2076, i64 0, i32 1, i32 2
        store ptr @returnAddress_2042, ptr %returnAddress_pointer_2080, !noalias !2
        store ptr @sharer_2063, ptr %sharer_pointer_2081, !noalias !2
        store ptr @eraser_2071, ptr %eraser_pointer_2082, !noalias !2
        
        %tag_2083 = extractvalue %Pos %pureApp_16436, 0
        %fields_2084 = extractvalue %Pos %pureApp_16436, 1
        switch i64 %tag_2083, label %label_2085 [i64 0, label %label_2089 i64 1, label %label_2094]
    
    label_2085:
        
        ret void
    
    label_2089:
        
        %pureApp_16448 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_16449 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_16448)
        
        
        
        %stackPointer_2087 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2088 = getelementptr %FrameHeader, %StackPointer %stackPointer_2087, i64 0, i32 0
        %returnAddress_2086 = load %ReturnAddress, ptr %returnAddress_pointer_2088, !noalias !2
        musttail call tailcc void %returnAddress_2086(%Pos %pureApp_16449, %Stack %stack)
        ret void
    
    label_2094:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_16450_temporary_2090 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_16450 = insertvalue %Pos %booleanLiteral_16450_temporary_2090, %Object null, 1
        
        %stackPointer_2092 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_2093 = getelementptr %FrameHeader, %StackPointer %stackPointer_2092, i64 0, i32 0
        %returnAddress_2091 = load %ReturnAddress, ptr %returnAddress_pointer_2093, !noalias !2
        musttail call tailcc void %returnAddress_2091(%Pos %booleanLiteral_16450, %Stack %stack)
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
        
        musttail call tailcc void @main_2855(%Stack %stack)
        ret void
}
