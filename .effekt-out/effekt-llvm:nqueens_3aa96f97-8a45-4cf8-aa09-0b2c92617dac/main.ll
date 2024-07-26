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



define ccc %Pos @infixNeq_75(i64 %x_73, i64 %y_74) {
    ; declaration extern
    ; variable
    
    %z = icmp ne %Int %x_73, %y_74
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



define tailcc void @returnAddress_2(i64 %r_2458, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5065 = call ccc %Pos @show_14(i64 %r_2458)
        
        
        
        %pureApp_5066 = call ccc %Pos @println_1(%Pos %pureApp_5065)
        
        
        
        %stackPointer_4 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_5 = getelementptr %FrameHeader, %StackPointer %stackPointer_4, i64 0, i32 0
        %returnAddress_3 = load %ReturnAddress, ptr %returnAddress_pointer_5, !noalias !2
        musttail call tailcc void %returnAddress_3(%Pos %pureApp_5066, %Stack %stack)
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



define tailcc void @returnAddress_15(i64 %returned_5067, %Stack %stack) {
        
    entry:
        
        %stack_16 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_18 = call ccc %StackPointer @stackDeallocate(%Stack %stack_16, i64 24)
        %returnAddress_pointer_19 = getelementptr %FrameHeader, %StackPointer %stackPointer_18, i64 0, i32 0
        %returnAddress_17 = load %ReturnAddress, ptr %returnAddress_pointer_19, !noalias !2
        musttail call tailcc void %returnAddress_17(i64 %returned_5067, %Stack %stack_16)
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



define tailcc void @returnAddress_56(%Pos %v_r_2512_28_28_96_104_120_4822, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_57 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %diag_5_13_29_4876_pointer_58 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_57, i64 0, i32 0
        %diag_5_13_29_4876 = load i64, ptr %diag_5_13_29_4876_pointer_58, !noalias !2
        %v_coe_3461_39_47_63_4792_pointer_59 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_57, i64 0, i32 1
        %v_coe_3461_39_47_63_4792 = load %Pos, ptr %v_coe_3461_39_47_63_4792_pointer_59, !noalias !2
        %next_11_27_4896_pointer_60 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_57, i64 0, i32 2
        %next_11_27_4896 = load i64, ptr %next_11_27_4896_pointer_60, !noalias !2
        
        %tag_61 = extractvalue %Pos %v_r_2512_28_28_96_104_120_4822, 0
        %fields_62 = extractvalue %Pos %v_r_2512_28_28_96_104_120_4822, 1
        switch i64 %tag_61, label %label_63 [i64 0, label %label_68 i64 1, label %label_69]
    
    label_63:
        
        ret void
    
    label_68:
        call ccc void @erasePositive(%Pos %v_coe_3461_39_47_63_4792)
        
        %booleanLiteral_5075_temporary_64 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_5075 = insertvalue %Pos %booleanLiteral_5075_temporary_64, %Object null, 1
        
        %stackPointer_66 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_67 = getelementptr %FrameHeader, %StackPointer %stackPointer_66, i64 0, i32 0
        %returnAddress_65 = load %ReturnAddress, ptr %returnAddress_pointer_67, !noalias !2
        musttail call tailcc void %returnAddress_65(%Pos %booleanLiteral_5075, %Stack %stack)
        ret void
    
    label_69:
        
        %longLiteral_5077 = add i64 1, 0
        
        %pureApp_5076 = call ccc i64 @infixAdd_96(i64 %diag_5_13_29_4876, i64 %longLiteral_5077)
        
        
        
        
        
        
        musttail call tailcc void @safe_worker_4_12_28_4809(i64 %pureApp_5076, %Pos %v_coe_3461_39_47_63_4792, i64 %next_11_27_4896, %Stack %stack)
        ret void
}



define ccc void @sharer_73(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_74 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %diag_5_13_29_4876_70_pointer_75 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_74, i64 0, i32 0
        %diag_5_13_29_4876_70 = load i64, ptr %diag_5_13_29_4876_70_pointer_75, !noalias !2
        %v_coe_3461_39_47_63_4792_71_pointer_76 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_74, i64 0, i32 1
        %v_coe_3461_39_47_63_4792_71 = load %Pos, ptr %v_coe_3461_39_47_63_4792_71_pointer_76, !noalias !2
        %next_11_27_4896_72_pointer_77 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_74, i64 0, i32 2
        %next_11_27_4896_72 = load i64, ptr %next_11_27_4896_72_pointer_77, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3461_39_47_63_4792_71)
        call ccc void @shareFrames(%StackPointer %stackPointer_74)
        ret void
}



define ccc void @eraser_81(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_82 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %diag_5_13_29_4876_78_pointer_83 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_82, i64 0, i32 0
        %diag_5_13_29_4876_78 = load i64, ptr %diag_5_13_29_4876_78_pointer_83, !noalias !2
        %v_coe_3461_39_47_63_4792_79_pointer_84 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_82, i64 0, i32 1
        %v_coe_3461_39_47_63_4792_79 = load %Pos, ptr %v_coe_3461_39_47_63_4792_79_pointer_84, !noalias !2
        %next_11_27_4896_80_pointer_85 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_82, i64 0, i32 2
        %next_11_27_4896_80 = load i64, ptr %next_11_27_4896_80_pointer_85, !noalias !2
        call ccc void @erasePositive(%Pos %v_coe_3461_39_47_63_4792_79)
        call ccc void @eraseFrames(%StackPointer %stackPointer_82)
        ret void
}



define tailcc void @returnAddress_50(%Pos %v_r_3387_5_25_25_93_101_117_4827, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_51 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %v_coe_3461_39_47_63_4792_pointer_52 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_51, i64 0, i32 0
        %v_coe_3461_39_47_63_4792 = load %Pos, ptr %v_coe_3461_39_47_63_4792_pointer_52, !noalias !2
        %tmp_5034_pointer_53 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_51, i64 0, i32 1
        %tmp_5034 = load i64, ptr %tmp_5034_pointer_53, !noalias !2
        %diag_5_13_29_4876_pointer_54 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_51, i64 0, i32 2
        %diag_5_13_29_4876 = load i64, ptr %diag_5_13_29_4876_pointer_54, !noalias !2
        %next_11_27_4896_pointer_55 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_51, i64 0, i32 3
        %next_11_27_4896 = load i64, ptr %next_11_27_4896_pointer_55, !noalias !2
        %stackPointer_86 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %diag_5_13_29_4876_pointer_87 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_86, i64 0, i32 0
        store i64 %diag_5_13_29_4876, ptr %diag_5_13_29_4876_pointer_87, !noalias !2
        %v_coe_3461_39_47_63_4792_pointer_88 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_86, i64 0, i32 1
        store %Pos %v_coe_3461_39_47_63_4792, ptr %v_coe_3461_39_47_63_4792_pointer_88, !noalias !2
        %next_11_27_4896_pointer_89 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_86, i64 0, i32 2
        store i64 %next_11_27_4896, ptr %next_11_27_4896_pointer_89, !noalias !2
        %returnAddress_pointer_90 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_86, i64 0, i32 1, i32 0
        %sharer_pointer_91 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_86, i64 0, i32 1, i32 1
        %eraser_pointer_92 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_86, i64 0, i32 1, i32 2
        store ptr @returnAddress_56, ptr %returnAddress_pointer_90, !noalias !2
        store ptr @sharer_73, ptr %sharer_pointer_91, !noalias !2
        store ptr @eraser_81, ptr %eraser_pointer_92, !noalias !2
        
        %tag_93 = extractvalue %Pos %v_r_3387_5_25_25_93_101_117_4827, 0
        %fields_94 = extractvalue %Pos %v_r_3387_5_25_25_93_101_117_4827, 1
        switch i64 %tag_93, label %label_95 [i64 0, label %label_100 i64 1, label %label_104]
    
    label_95:
        
        ret void
    
    label_100:
        
        %booleanLiteral_5078_temporary_96 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_5078 = insertvalue %Pos %booleanLiteral_5078_temporary_96, %Object null, 1
        
        %stackPointer_98 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_99 = getelementptr %FrameHeader, %StackPointer %stackPointer_98, i64 0, i32 0
        %returnAddress_97 = load %ReturnAddress, ptr %returnAddress_pointer_99, !noalias !2
        musttail call tailcc void %returnAddress_97(%Pos %booleanLiteral_5078, %Stack %stack)
        ret void
    
    label_104:
        
        %pureApp_5079 = call ccc i64 @infixSub_105(i64 %tmp_5034, i64 %diag_5_13_29_4876)
        
        
        
        %pureApp_5080 = call ccc %Pos @infixNeq_75(i64 %next_11_27_4896, i64 %pureApp_5079)
        
        
        
        %stackPointer_102 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_103 = getelementptr %FrameHeader, %StackPointer %stackPointer_102, i64 0, i32 0
        %returnAddress_101 = load %ReturnAddress, ptr %returnAddress_pointer_103, !noalias !2
        musttail call tailcc void %returnAddress_101(%Pos %pureApp_5080, %Stack %stack)
        ret void
}



define ccc void @sharer_109(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_110 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %v_coe_3461_39_47_63_4792_105_pointer_111 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_110, i64 0, i32 0
        %v_coe_3461_39_47_63_4792_105 = load %Pos, ptr %v_coe_3461_39_47_63_4792_105_pointer_111, !noalias !2
        %tmp_5034_106_pointer_112 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_110, i64 0, i32 1
        %tmp_5034_106 = load i64, ptr %tmp_5034_106_pointer_112, !noalias !2
        %diag_5_13_29_4876_107_pointer_113 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_110, i64 0, i32 2
        %diag_5_13_29_4876_107 = load i64, ptr %diag_5_13_29_4876_107_pointer_113, !noalias !2
        %next_11_27_4896_108_pointer_114 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_110, i64 0, i32 3
        %next_11_27_4896_108 = load i64, ptr %next_11_27_4896_108_pointer_114, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3461_39_47_63_4792_105)
        call ccc void @shareFrames(%StackPointer %stackPointer_110)
        ret void
}



define ccc void @eraser_119(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_120 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %v_coe_3461_39_47_63_4792_115_pointer_121 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_120, i64 0, i32 0
        %v_coe_3461_39_47_63_4792_115 = load %Pos, ptr %v_coe_3461_39_47_63_4792_115_pointer_121, !noalias !2
        %tmp_5034_116_pointer_122 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_120, i64 0, i32 1
        %tmp_5034_116 = load i64, ptr %tmp_5034_116_pointer_122, !noalias !2
        %diag_5_13_29_4876_117_pointer_123 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_120, i64 0, i32 2
        %diag_5_13_29_4876_117 = load i64, ptr %diag_5_13_29_4876_117_pointer_123, !noalias !2
        %next_11_27_4896_118_pointer_124 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_120, i64 0, i32 3
        %next_11_27_4896_118 = load i64, ptr %next_11_27_4896_118_pointer_124, !noalias !2
        call ccc void @erasePositive(%Pos %v_coe_3461_39_47_63_4792_115)
        call ccc void @eraseFrames(%StackPointer %stackPointer_120)
        ret void
}



define tailcc void @safe_worker_4_12_28_4809(i64 %diag_5_13_29_4876, %Pos %xs_6_14_30_4790, i64 %next_11_27_4896, %Stack %stack) {
        
    entry:
        
        
        %tag_39 = extractvalue %Pos %xs_6_14_30_4790, 0
        %fields_40 = extractvalue %Pos %xs_6_14_30_4790, 1
        switch i64 %tag_39, label %label_41 [i64 0, label %label_46 i64 1, label %label_145]
    
    label_41:
        
        ret void
    
    label_46:
        
        %booleanLiteral_5072_temporary_42 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5072 = insertvalue %Pos %booleanLiteral_5072_temporary_42, %Object null, 1
        
        %stackPointer_44 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_45 = getelementptr %FrameHeader, %StackPointer %stackPointer_44, i64 0, i32 0
        %returnAddress_43 = load %ReturnAddress, ptr %returnAddress_pointer_45, !noalias !2
        musttail call tailcc void %returnAddress_43(%Pos %booleanLiteral_5072, %Stack %stack)
        ret void
    
    label_135:
        
        ret void
    
    label_140:
        
        %booleanLiteral_5081_temporary_136 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_5081 = insertvalue %Pos %booleanLiteral_5081_temporary_136, %Object null, 1
        
        %stackPointer_138 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_139 = getelementptr %FrameHeader, %StackPointer %stackPointer_138, i64 0, i32 0
        %returnAddress_137 = load %ReturnAddress, ptr %returnAddress_pointer_139, !noalias !2
        musttail call tailcc void %returnAddress_137(%Pos %booleanLiteral_5081, %Stack %stack)
        ret void
    
    label_144:
        
        %pureApp_5082 = call ccc i64 @infixAdd_96(i64 %pureApp_5073, i64 %diag_5_13_29_4876)
        
        
        
        %pureApp_5083 = call ccc %Pos @infixNeq_75(i64 %next_11_27_4896, i64 %pureApp_5082)
        
        
        
        %stackPointer_142 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_143 = getelementptr %FrameHeader, %StackPointer %stackPointer_142, i64 0, i32 0
        %returnAddress_141 = load %ReturnAddress, ptr %returnAddress_pointer_143, !noalias !2
        musttail call tailcc void %returnAddress_141(%Pos %pureApp_5083, %Stack %stack)
        ret void
    
    label_145:
        %environment_47 = call ccc %Environment @objectEnvironment(%Object %fields_40)
        %v_coe_3460_38_46_62_4900_pointer_48 = getelementptr <{%Pos, %Pos}>, %Environment %environment_47, i64 0, i32 0
        %v_coe_3460_38_46_62_4900 = load %Pos, ptr %v_coe_3460_38_46_62_4900_pointer_48, !noalias !2
        %v_coe_3461_39_47_63_4792_pointer_49 = getelementptr <{%Pos, %Pos}>, %Environment %environment_47, i64 0, i32 1
        %v_coe_3461_39_47_63_4792 = load %Pos, ptr %v_coe_3461_39_47_63_4792_pointer_49, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3460_38_46_62_4900)
        call ccc void @sharePositive(%Pos %v_coe_3461_39_47_63_4792)
        call ccc void @eraseObject(%Object %fields_40)
        
        %pureApp_5073 = call ccc i64 @unboxInt_303(%Pos %v_coe_3460_38_46_62_4900)
        
        
        
        %pureApp_5074 = call ccc %Pos @infixNeq_75(i64 %next_11_27_4896, i64 %pureApp_5073)
        
        
        %stackPointer_125 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %v_coe_3461_39_47_63_4792_pointer_126 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_125, i64 0, i32 0
        store %Pos %v_coe_3461_39_47_63_4792, ptr %v_coe_3461_39_47_63_4792_pointer_126, !noalias !2
        %tmp_5034_pointer_127 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_125, i64 0, i32 1
        store i64 %pureApp_5073, ptr %tmp_5034_pointer_127, !noalias !2
        %diag_5_13_29_4876_pointer_128 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_125, i64 0, i32 2
        store i64 %diag_5_13_29_4876, ptr %diag_5_13_29_4876_pointer_128, !noalias !2
        %next_11_27_4896_pointer_129 = getelementptr <{%Pos, i64, i64, i64}>, %StackPointer %stackPointer_125, i64 0, i32 3
        store i64 %next_11_27_4896, ptr %next_11_27_4896_pointer_129, !noalias !2
        %returnAddress_pointer_130 = getelementptr <{<{%Pos, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_125, i64 0, i32 1, i32 0
        %sharer_pointer_131 = getelementptr <{<{%Pos, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_125, i64 0, i32 1, i32 1
        %eraser_pointer_132 = getelementptr <{<{%Pos, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_125, i64 0, i32 1, i32 2
        store ptr @returnAddress_50, ptr %returnAddress_pointer_130, !noalias !2
        store ptr @sharer_109, ptr %sharer_pointer_131, !noalias !2
        store ptr @eraser_119, ptr %eraser_pointer_132, !noalias !2
        
        %tag_133 = extractvalue %Pos %pureApp_5074, 0
        %fields_134 = extractvalue %Pos %pureApp_5074, 1
        switch i64 %tag_133, label %label_135 [i64 0, label %label_140 i64 1, label %label_144]
}



define tailcc void @returnAddress_154(%Pos %v_r_2524_109_127_4867, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %tag_155 = extractvalue %Pos %v_r_2524_109_127_4867, 0
        %fields_156 = extractvalue %Pos %v_r_2524_109_127_4867, 1
        switch i64 %tag_155, label %label_157 []
    
    label_157:
        
        ret void
}



define ccc void @eraser_172(%Environment %environment) {
        
    entry:
        
        %tmp_5041_170_pointer_173 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5041_170 = load %Pos, ptr %tmp_5041_170_pointer_173, !noalias !2
        %rest_10_26_4817_171_pointer_174 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %rest_10_26_4817_171 = load %Pos, ptr %rest_10_26_4817_171_pointer_174, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5041_170)
        call ccc void @erasePositive(%Pos %rest_10_26_4817_171)
        ret void
}



define tailcc void @returnAddress_146(%Pos %v_r_2523_106_122_4866, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_147 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_3_4810_pointer_148 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_147, i64 0, i32 0
        %p_3_4810 = load %Prompt, ptr %p_3_4810_pointer_148, !noalias !2
        %next_11_27_4896_pointer_149 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_147, i64 0, i32 1
        %next_11_27_4896 = load i64, ptr %next_11_27_4896_pointer_149, !noalias !2
        %rest_10_26_4817_pointer_150 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_147, i64 0, i32 2
        %rest_10_26_4817 = load %Pos, ptr %rest_10_26_4817_pointer_150, !noalias !2
        
        %tag_151 = extractvalue %Pos %v_r_2523_106_122_4866, 0
        %fields_152 = extractvalue %Pos %v_r_2523_106_122_4866, 1
        switch i64 %tag_151, label %label_153 [i64 0, label %label_167 i64 1, label %label_181]
    
    label_153:
        
        ret void
    
    label_167:
        call ccc void @erasePositive(%Pos %rest_10_26_4817)
        %stackPointer_158 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_159 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_158, i64 0, i32 1, i32 0
        %sharer_pointer_160 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_158, i64 0, i32 1, i32 1
        %eraser_pointer_161 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_158, i64 0, i32 1, i32 2
        store ptr @returnAddress_154, ptr %returnAddress_pointer_159, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_160, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_161, !noalias !2
        
        %pair_162 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_3_4810)
        %k_2_126_5084 = extractvalue <{%Resumption, %Stack}> %pair_162, 0
        %stack_163 = extractvalue <{%Resumption, %Stack}> %pair_162, 1
        call ccc void @eraseResumption(%Resumption %k_2_126_5084)
        
        %longLiteral_5085 = add i64 0, 0
        
        %stackPointer_165 = call ccc %StackPointer @stackDeallocate(%Stack %stack_163, i64 24)
        %returnAddress_pointer_166 = getelementptr %FrameHeader, %StackPointer %stackPointer_165, i64 0, i32 0
        %returnAddress_164 = load %ReturnAddress, ptr %returnAddress_pointer_166, !noalias !2
        musttail call tailcc void %returnAddress_164(i64 %longLiteral_5085, %Stack %stack_163)
        ret void
    
    label_181:
        
        %pureApp_5086 = call ccc %Pos @boxInt_301(i64 %next_11_27_4896)
        
        
        
        %fields_168 = call ccc %Object @newObject(ptr @eraser_172, i64 32)
        %environment_169 = call ccc %Environment @objectEnvironment(%Object %fields_168)
        %tmp_5041_pointer_175 = getelementptr <{%Pos, %Pos}>, %Environment %environment_169, i64 0, i32 0
        store %Pos %pureApp_5086, ptr %tmp_5041_pointer_175, !noalias !2
        %rest_10_26_4817_pointer_176 = getelementptr <{%Pos, %Pos}>, %Environment %environment_169, i64 0, i32 1
        store %Pos %rest_10_26_4817, ptr %rest_10_26_4817_pointer_176, !noalias !2
        %make_5087_temporary_177 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5087 = insertvalue %Pos %make_5087_temporary_177, %Object %fields_168, 1
        
        
        
        %stackPointer_179 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_180 = getelementptr %FrameHeader, %StackPointer %stackPointer_179, i64 0, i32 0
        %returnAddress_178 = load %ReturnAddress, ptr %returnAddress_pointer_180, !noalias !2
        musttail call tailcc void %returnAddress_178(%Pos %make_5087, %Stack %stack)
        ret void
}



define ccc void @sharer_185(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_186 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_3_4810_182_pointer_187 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_186, i64 0, i32 0
        %p_3_4810_182 = load %Prompt, ptr %p_3_4810_182_pointer_187, !noalias !2
        %next_11_27_4896_183_pointer_188 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_186, i64 0, i32 1
        %next_11_27_4896_183 = load i64, ptr %next_11_27_4896_183_pointer_188, !noalias !2
        %rest_10_26_4817_184_pointer_189 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_186, i64 0, i32 2
        %rest_10_26_4817_184 = load %Pos, ptr %rest_10_26_4817_184_pointer_189, !noalias !2
        call ccc void @sharePositive(%Pos %rest_10_26_4817_184)
        call ccc void @shareFrames(%StackPointer %stackPointer_186)
        ret void
}



define ccc void @eraser_193(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_194 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_3_4810_190_pointer_195 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_194, i64 0, i32 0
        %p_3_4810_190 = load %Prompt, ptr %p_3_4810_190_pointer_195, !noalias !2
        %next_11_27_4896_191_pointer_196 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_194, i64 0, i32 1
        %next_11_27_4896_191 = load i64, ptr %next_11_27_4896_191_pointer_196, !noalias !2
        %rest_10_26_4817_192_pointer_197 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_194, i64 0, i32 2
        %rest_10_26_4817_192 = load %Pos, ptr %rest_10_26_4817_192_pointer_197, !noalias !2
        call ccc void @erasePositive(%Pos %rest_10_26_4817_192)
        call ccc void @eraseFrames(%StackPointer %stackPointer_194)
        ret void
}



define tailcc void @returnAddress_35(i64 %next_11_27_4896, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %p_3_4810_pointer_37 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer_36, i64 0, i32 0
        %p_3_4810 = load %Prompt, ptr %p_3_4810_pointer_37, !noalias !2
        %rest_10_26_4817_pointer_38 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer_36, i64 0, i32 1
        %rest_10_26_4817 = load %Pos, ptr %rest_10_26_4817_pointer_38, !noalias !2
        call ccc void @sharePositive(%Pos %rest_10_26_4817)
        %stackPointer_198 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_3_4810_pointer_199 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_198, i64 0, i32 0
        store %Prompt %p_3_4810, ptr %p_3_4810_pointer_199, !noalias !2
        %next_11_27_4896_pointer_200 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_198, i64 0, i32 1
        store i64 %next_11_27_4896, ptr %next_11_27_4896_pointer_200, !noalias !2
        %rest_10_26_4817_pointer_201 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_198, i64 0, i32 2
        store %Pos %rest_10_26_4817, ptr %rest_10_26_4817_pointer_201, !noalias !2
        %returnAddress_pointer_202 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_198, i64 0, i32 1, i32 0
        %sharer_pointer_203 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_198, i64 0, i32 1, i32 1
        %eraser_pointer_204 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_198, i64 0, i32 1, i32 2
        store ptr @returnAddress_146, ptr %returnAddress_pointer_202, !noalias !2
        store ptr @sharer_185, ptr %sharer_pointer_203, !noalias !2
        store ptr @eraser_193, ptr %eraser_pointer_204, !noalias !2
        
        %longLiteral_5088 = add i64 1, 0
        
        
        
        
        musttail call tailcc void @safe_worker_4_12_28_4809(i64 %longLiteral_5088, %Pos %rest_10_26_4817, i64 %next_11_27_4896, %Stack %stack)
        ret void
}



define ccc void @sharer_207(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_208 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_3_4810_205_pointer_209 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer_208, i64 0, i32 0
        %p_3_4810_205 = load %Prompt, ptr %p_3_4810_205_pointer_209, !noalias !2
        %rest_10_26_4817_206_pointer_210 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer_208, i64 0, i32 1
        %rest_10_26_4817_206 = load %Pos, ptr %rest_10_26_4817_206_pointer_210, !noalias !2
        call ccc void @sharePositive(%Pos %rest_10_26_4817_206)
        call ccc void @shareFrames(%StackPointer %stackPointer_208)
        ret void
}



define ccc void @eraser_213(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_214 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_3_4810_211_pointer_215 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer_214, i64 0, i32 0
        %p_3_4810_211 = load %Prompt, ptr %p_3_4810_211_pointer_215, !noalias !2
        %rest_10_26_4817_212_pointer_216 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer_214, i64 0, i32 1
        %rest_10_26_4817_212 = load %Pos, ptr %rest_10_26_4817_212_pointer_216, !noalias !2
        call ccc void @erasePositive(%Pos %rest_10_26_4817_212)
        call ccc void @eraseFrames(%StackPointer %stackPointer_214)
        ret void
}



define tailcc void @returnAddress_228(i64 %v_r_2532_16_10_4979, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_229 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %k_7_3_4978_pointer_230 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_229, i64 0, i32 0
        %k_7_3_4978 = load %Resumption, ptr %k_7_3_4978_pointer_230, !noalias !2
        %a_12_6_4987_pointer_231 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_229, i64 0, i32 1
        %a_12_6_4987 = load i64, ptr %a_12_6_4987_pointer_231, !noalias !2
        %tmp_5048_pointer_232 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_229, i64 0, i32 2
        %tmp_5048 = load i64, ptr %tmp_5048_pointer_232, !noalias !2
        %i_11_5_4981_pointer_233 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_229, i64 0, i32 3
        %i_11_5_4981 = load i64, ptr %i_11_5_4981_pointer_233, !noalias !2
        
        %longLiteral_5091 = add i64 1, 0
        
        %pureApp_5090 = call ccc i64 @infixAdd_96(i64 %i_11_5_4981, i64 %longLiteral_5091)
        
        
        
        %pureApp_5092 = call ccc i64 @infixAdd_96(i64 %a_12_6_4987, i64 %v_r_2532_16_10_4979)
        
        
        
        
        
        
        musttail call tailcc void @loop_10_4_4983(i64 %pureApp_5090, i64 %pureApp_5092, %Resumption %k_7_3_4978, i64 %tmp_5048, %Stack %stack)
        ret void
}



define ccc void @sharer_238(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_239 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %k_7_3_4978_234_pointer_240 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_239, i64 0, i32 0
        %k_7_3_4978_234 = load %Resumption, ptr %k_7_3_4978_234_pointer_240, !noalias !2
        %a_12_6_4987_235_pointer_241 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_239, i64 0, i32 1
        %a_12_6_4987_235 = load i64, ptr %a_12_6_4987_235_pointer_241, !noalias !2
        %tmp_5048_236_pointer_242 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_239, i64 0, i32 2
        %tmp_5048_236 = load i64, ptr %tmp_5048_236_pointer_242, !noalias !2
        %i_11_5_4981_237_pointer_243 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_239, i64 0, i32 3
        %i_11_5_4981_237 = load i64, ptr %i_11_5_4981_237_pointer_243, !noalias !2
        call ccc void @shareResumption(%Resumption %k_7_3_4978_234)
        call ccc void @shareFrames(%StackPointer %stackPointer_239)
        ret void
}



define ccc void @eraser_248(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_249 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %k_7_3_4978_244_pointer_250 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_249, i64 0, i32 0
        %k_7_3_4978_244 = load %Resumption, ptr %k_7_3_4978_244_pointer_250, !noalias !2
        %a_12_6_4987_245_pointer_251 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_249, i64 0, i32 1
        %a_12_6_4987_245 = load i64, ptr %a_12_6_4987_245_pointer_251, !noalias !2
        %tmp_5048_246_pointer_252 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_249, i64 0, i32 2
        %tmp_5048_246 = load i64, ptr %tmp_5048_246_pointer_252, !noalias !2
        %i_11_5_4981_247_pointer_253 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_249, i64 0, i32 3
        %i_11_5_4981_247 = load i64, ptr %i_11_5_4981_247_pointer_253, !noalias !2
        call ccc void @eraseResumption(%Resumption %k_7_3_4978_244)
        call ccc void @eraseFrames(%StackPointer %stackPointer_249)
        ret void
}



define tailcc void @returnAddress_267(i64 %v_r_2531_14_8_4988, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_268 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %a_12_6_4987_pointer_269 = getelementptr <{i64}>, %StackPointer %stackPointer_268, i64 0, i32 0
        %a_12_6_4987 = load i64, ptr %a_12_6_4987_pointer_269, !noalias !2
        
        %pureApp_5093 = call ccc i64 @infixAdd_96(i64 %a_12_6_4987, i64 %v_r_2531_14_8_4988)
        
        
        
        %stackPointer_271 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_272 = getelementptr %FrameHeader, %StackPointer %stackPointer_271, i64 0, i32 0
        %returnAddress_270 = load %ReturnAddress, ptr %returnAddress_pointer_272, !noalias !2
        musttail call tailcc void %returnAddress_270(i64 %pureApp_5093, %Stack %stack)
        ret void
}



define ccc void @sharer_274(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_275 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %a_12_6_4987_273_pointer_276 = getelementptr <{i64}>, %StackPointer %stackPointer_275, i64 0, i32 0
        %a_12_6_4987_273 = load i64, ptr %a_12_6_4987_273_pointer_276, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_275)
        ret void
}



define ccc void @eraser_278(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_279 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %a_12_6_4987_277_pointer_280 = getelementptr <{i64}>, %StackPointer %stackPointer_279, i64 0, i32 0
        %a_12_6_4987_277 = load i64, ptr %a_12_6_4987_277_pointer_280, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_279)
        ret void
}



define tailcc void @loop_10_4_4983(i64 %i_11_5_4981, i64 %a_12_6_4987, %Resumption %k_7_3_4978, i64 %tmp_5048, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5089 = call ccc %Pos @infixEq_72(i64 %i_11_5_4981, i64 %tmp_5048)
        
        
        
        %tag_225 = extractvalue %Pos %pureApp_5089, 0
        %fields_226 = extractvalue %Pos %pureApp_5089, 1
        switch i64 %tag_225, label %label_227 [i64 0, label %label_266 i64 1, label %label_290]
    
    label_227:
        
        ret void
    
    label_266:
        call ccc void @shareResumption(%Resumption %k_7_3_4978)
        %stackPointer_254 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %k_7_3_4978_pointer_255 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_254, i64 0, i32 0
        store %Resumption %k_7_3_4978, ptr %k_7_3_4978_pointer_255, !noalias !2
        %a_12_6_4987_pointer_256 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_254, i64 0, i32 1
        store i64 %a_12_6_4987, ptr %a_12_6_4987_pointer_256, !noalias !2
        %tmp_5048_pointer_257 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_254, i64 0, i32 2
        store i64 %tmp_5048, ptr %tmp_5048_pointer_257, !noalias !2
        %i_11_5_4981_pointer_258 = getelementptr <{%Resumption, i64, i64, i64}>, %StackPointer %stackPointer_254, i64 0, i32 3
        store i64 %i_11_5_4981, ptr %i_11_5_4981_pointer_258, !noalias !2
        %returnAddress_pointer_259 = getelementptr <{<{%Resumption, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_254, i64 0, i32 1, i32 0
        %sharer_pointer_260 = getelementptr <{<{%Resumption, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_254, i64 0, i32 1, i32 1
        %eraser_pointer_261 = getelementptr <{<{%Resumption, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_254, i64 0, i32 1, i32 2
        store ptr @returnAddress_228, ptr %returnAddress_pointer_259, !noalias !2
        store ptr @sharer_238, ptr %sharer_pointer_260, !noalias !2
        store ptr @eraser_248, ptr %eraser_pointer_261, !noalias !2
        
        %stack_262 = call ccc %Stack @resume(%Resumption %k_7_3_4978, %Stack %stack)
        
        %stackPointer_264 = call ccc %StackPointer @stackDeallocate(%Stack %stack_262, i64 24)
        %returnAddress_pointer_265 = getelementptr %FrameHeader, %StackPointer %stackPointer_264, i64 0, i32 0
        %returnAddress_263 = load %ReturnAddress, ptr %returnAddress_pointer_265, !noalias !2
        musttail call tailcc void %returnAddress_263(i64 %i_11_5_4981, %Stack %stack_262)
        ret void
    
    label_290:
        %stackPointer_281 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %a_12_6_4987_pointer_282 = getelementptr <{i64}>, %StackPointer %stackPointer_281, i64 0, i32 0
        store i64 %a_12_6_4987, ptr %a_12_6_4987_pointer_282, !noalias !2
        %returnAddress_pointer_283 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 0
        %sharer_pointer_284 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 1
        %eraser_pointer_285 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 2
        store ptr @returnAddress_267, ptr %returnAddress_pointer_283, !noalias !2
        store ptr @sharer_274, ptr %sharer_pointer_284, !noalias !2
        store ptr @eraser_278, ptr %eraser_pointer_285, !noalias !2
        
        %stack_286 = call ccc %Stack @resume(%Resumption %k_7_3_4978, %Stack %stack)
        
        %stackPointer_288 = call ccc %StackPointer @stackDeallocate(%Stack %stack_286, i64 24)
        %returnAddress_pointer_289 = getelementptr %FrameHeader, %StackPointer %stackPointer_288, i64 0, i32 0
        %returnAddress_287 = load %ReturnAddress, ptr %returnAddress_pointer_289, !noalias !2
        musttail call tailcc void %returnAddress_287(i64 %i_11_5_4981, %Stack %stack_286)
        ret void
}



define tailcc void @returnAddress_31(%Pos %rest_10_26_4817, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_32 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %p_3_4810_pointer_33 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_32, i64 0, i32 0
        %p_3_4810 = load %Prompt, ptr %p_3_4810_pointer_33, !noalias !2
        %tmp_5048_pointer_34 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_32, i64 0, i32 1
        %tmp_5048 = load i64, ptr %tmp_5048_pointer_34, !noalias !2
        %stackPointer_217 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 48)
        %p_3_4810_pointer_218 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer_217, i64 0, i32 0
        store %Prompt %p_3_4810, ptr %p_3_4810_pointer_218, !noalias !2
        %rest_10_26_4817_pointer_219 = getelementptr <{%Prompt, %Pos}>, %StackPointer %stackPointer_217, i64 0, i32 1
        store %Pos %rest_10_26_4817, ptr %rest_10_26_4817_pointer_219, !noalias !2
        %returnAddress_pointer_220 = getelementptr <{<{%Prompt, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_217, i64 0, i32 1, i32 0
        %sharer_pointer_221 = getelementptr <{<{%Prompt, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_217, i64 0, i32 1, i32 1
        %eraser_pointer_222 = getelementptr <{<{%Prompt, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_217, i64 0, i32 1, i32 2
        store ptr @returnAddress_35, ptr %returnAddress_pointer_220, !noalias !2
        store ptr @sharer_207, ptr %sharer_pointer_221, !noalias !2
        store ptr @eraser_213, ptr %eraser_pointer_222, !noalias !2
        
        %pair_223 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_3_4810)
        %k_7_3_4978 = extractvalue <{%Resumption, %Stack}> %pair_223, 0
        %stack_224 = extractvalue <{%Resumption, %Stack}> %pair_223, 1
        
        %longLiteral_5094 = add i64 1, 0
        
        %longLiteral_5095 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @loop_10_4_4983(i64 %longLiteral_5094, i64 %longLiteral_5095, %Resumption %k_7_3_4978, i64 %tmp_5048, %Stack %stack_224)
        ret void
}



define ccc void @sharer_293(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_294 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %p_3_4810_291_pointer_295 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_294, i64 0, i32 0
        %p_3_4810_291 = load %Prompt, ptr %p_3_4810_291_pointer_295, !noalias !2
        %tmp_5048_292_pointer_296 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_294, i64 0, i32 1
        %tmp_5048_292 = load i64, ptr %tmp_5048_292_pointer_296, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_294)
        ret void
}



define ccc void @eraser_299(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_300 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %p_3_4810_297_pointer_301 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_300, i64 0, i32 0
        %p_3_4810_297 = load %Prompt, ptr %p_3_4810_297_pointer_301, !noalias !2
        %tmp_5048_298_pointer_302 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_300, i64 0, i32 1
        %tmp_5048_298 = load i64, ptr %tmp_5048_298_pointer_302, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_300)
        ret void
}



define tailcc void @place_worker_5_21_4856(i64 %column_6_22_4795, i64 %tmp_5048, %Prompt %p_3_4810, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5069 = add i64 0, 0
        
        %pureApp_5068 = call ccc %Pos @infixEq_72(i64 %column_6_22_4795, i64 %longLiteral_5069)
        
        
        
        %tag_28 = extractvalue %Pos %pureApp_5068, 0
        %fields_29 = extractvalue %Pos %pureApp_5068, 1
        switch i64 %tag_28, label %label_30 [i64 0, label %label_309 i64 1, label %label_314]
    
    label_30:
        
        ret void
    
    label_309:
        
        %longLiteral_5071 = add i64 1, 0
        
        %pureApp_5070 = call ccc i64 @infixSub_105(i64 %column_6_22_4795, i64 %longLiteral_5071)
        
        
        %stackPointer_303 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %p_3_4810_pointer_304 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_303, i64 0, i32 0
        store %Prompt %p_3_4810, ptr %p_3_4810_pointer_304, !noalias !2
        %tmp_5048_pointer_305 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_303, i64 0, i32 1
        store i64 %tmp_5048, ptr %tmp_5048_pointer_305, !noalias !2
        %returnAddress_pointer_306 = getelementptr <{<{%Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_303, i64 0, i32 1, i32 0
        %sharer_pointer_307 = getelementptr <{<{%Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_303, i64 0, i32 1, i32 1
        %eraser_pointer_308 = getelementptr <{<{%Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_303, i64 0, i32 1, i32 2
        store ptr @returnAddress_31, ptr %returnAddress_pointer_306, !noalias !2
        store ptr @sharer_293, ptr %sharer_pointer_307, !noalias !2
        store ptr @eraser_299, ptr %eraser_pointer_308, !noalias !2
        
        
        
        musttail call tailcc void @place_worker_5_21_4856(i64 %pureApp_5070, i64 %tmp_5048, %Prompt %p_3_4810, %Stack %stack)
        ret void
    
    label_314:
        
        %make_5096_temporary_310 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5096 = insertvalue %Pos %make_5096_temporary_310, %Object null, 1
        
        
        
        %stackPointer_312 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_313 = getelementptr %FrameHeader, %StackPointer %stackPointer_312, i64 0, i32 0
        %returnAddress_311 = load %ReturnAddress, ptr %returnAddress_pointer_313, !noalias !2
        musttail call tailcc void %returnAddress_311(%Pos %make_5096, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_315(%Pos %__128_4909, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %__128_4909)
        
        %longLiteral_5097 = add i64 1, 0
        
        %stackPointer_317 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_318 = getelementptr %FrameHeader, %StackPointer %stackPointer_317, i64 0, i32 0
        %returnAddress_316 = load %ReturnAddress, ptr %returnAddress_pointer_318, !noalias !2
        musttail call tailcc void %returnAddress_316(i64 %longLiteral_5097, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3469_3533, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5064 = call ccc i64 @unboxInt_303(%Pos %v_coe_3469_3533)
        
        
        %stackPointer_10 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 0
        %sharer_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 1
        %eraser_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_11, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_12, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_13, !noalias !2
        
        %stack_14 = call ccc %Stack @reset(%Stack %stack)
        %p_3_4810 = call ccc %Prompt @currentPrompt(%Stack %stack_14)
        %stackPointer_24 = call ccc %StackPointer @stackAllocate(%Stack %stack_14, i64 24)
        %returnAddress_pointer_25 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 0
        %sharer_pointer_26 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 1
        %eraser_pointer_27 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 2
        store ptr @returnAddress_15, ptr %returnAddress_pointer_25, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_26, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_27, !noalias !2
        %stackPointer_319 = call ccc %StackPointer @stackAllocate(%Stack %stack_14, i64 24)
        %returnAddress_pointer_320 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_319, i64 0, i32 1, i32 0
        %sharer_pointer_321 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_319, i64 0, i32 1, i32 1
        %eraser_pointer_322 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_319, i64 0, i32 1, i32 2
        store ptr @returnAddress_315, ptr %returnAddress_pointer_320, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_321, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_322, !noalias !2
        
        
        
        musttail call tailcc void @place_worker_5_21_4856(i64 %pureApp_5064, i64 %pureApp_5064, %Prompt %p_3_4810, %Stack %stack_14)
        ret void
}



define tailcc void @returnAddress_328(%Pos %returned_5098, %Stack %stack) {
        
    entry:
        
        %stack_329 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_331 = call ccc %StackPointer @stackDeallocate(%Stack %stack_329, i64 24)
        %returnAddress_pointer_332 = getelementptr %FrameHeader, %StackPointer %stackPointer_331, i64 0, i32 0
        %returnAddress_330 = load %ReturnAddress, ptr %returnAddress_pointer_332, !noalias !2
        musttail call tailcc void %returnAddress_330(%Pos %returned_5098, %Stack %stack_329)
        ret void
}



define tailcc void @toList_1_1_3_167_4553(i64 %start_2_2_4_168_4591, %Pos %acc_3_3_5_169_4597, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5100 = add i64 1, 0
        
        %pureApp_5099 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4591, i64 %longLiteral_5100)
        
        
        
        %tag_337 = extractvalue %Pos %pureApp_5099, 0
        %fields_338 = extractvalue %Pos %pureApp_5099, 1
        switch i64 %tag_337, label %label_339 [i64 0, label %label_347 i64 1, label %label_351]
    
    label_339:
        
        ret void
    
    label_347:
        
        %pureApp_5101 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4591)
        
        
        
        %longLiteral_5103 = add i64 1, 0
        
        %pureApp_5102 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4591, i64 %longLiteral_5103)
        
        
        
        %fields_340 = call ccc %Object @newObject(ptr @eraser_172, i64 32)
        %environment_341 = call ccc %Environment @objectEnvironment(%Object %fields_340)
        %tmp_4999_pointer_344 = getelementptr <{%Pos, %Pos}>, %Environment %environment_341, i64 0, i32 0
        store %Pos %pureApp_5101, ptr %tmp_4999_pointer_344, !noalias !2
        %acc_3_3_5_169_4597_pointer_345 = getelementptr <{%Pos, %Pos}>, %Environment %environment_341, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4597, ptr %acc_3_3_5_169_4597_pointer_345, !noalias !2
        %make_5104_temporary_346 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5104 = insertvalue %Pos %make_5104_temporary_346, %Object %fields_340, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4553(i64 %pureApp_5102, %Pos %make_5104, %Stack %stack)
        ret void
    
    label_351:
        
        %stackPointer_349 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_350 = getelementptr %FrameHeader, %StackPointer %stackPointer_349, i64 0, i32 0
        %returnAddress_348 = load %ReturnAddress, ptr %returnAddress_pointer_350, !noalias !2
        musttail call tailcc void %returnAddress_348(%Pos %acc_3_3_5_169_4597, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_362(%Pos %v_r_2625_32_59_223_4593, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_363 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %index_7_34_198_4457_pointer_364 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_363, i64 0, i32 0
        %index_7_34_198_4457 = load i64, ptr %index_7_34_198_4457_pointer_364, !noalias !2
        %tmp_5006_pointer_365 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_363, i64 0, i32 1
        %tmp_5006 = load i64, ptr %tmp_5006_pointer_365, !noalias !2
        %v_r_2542_30_194_4560_pointer_366 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_363, i64 0, i32 2
        %v_r_2542_30_194_4560 = load %Pos, ptr %v_r_2542_30_194_4560_pointer_366, !noalias !2
        %acc_8_35_199_4729_pointer_367 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_363, i64 0, i32 3
        %acc_8_35_199_4729 = load i64, ptr %acc_8_35_199_4729_pointer_367, !noalias !2
        %p_8_9_4421_pointer_368 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_363, i64 0, i32 4
        %p_8_9_4421 = load %Prompt, ptr %p_8_9_4421_pointer_368, !noalias !2
        
        %tag_369 = extractvalue %Pos %v_r_2625_32_59_223_4593, 0
        %fields_370 = extractvalue %Pos %v_r_2625_32_59_223_4593, 1
        switch i64 %tag_369, label %label_371 [i64 1, label %label_394 i64 0, label %label_401]
    
    label_371:
        
        ret void
    
    label_376:
        
        ret void
    
    label_382:
        call ccc void @erasePositive(%Pos %v_r_2542_30_194_4560)
        
        %pair_377 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4421)
        %k_13_14_4_4914 = extractvalue <{%Resumption, %Stack}> %pair_377, 0
        %stack_378 = extractvalue <{%Resumption, %Stack}> %pair_377, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4914)
        
        %longLiteral_5116 = add i64 5, 0
        
        
        
        %pureApp_5117 = call ccc %Pos @boxInt_301(i64 %longLiteral_5116)
        
        
        
        %stackPointer_380 = call ccc %StackPointer @stackDeallocate(%Stack %stack_378, i64 24)
        %returnAddress_pointer_381 = getelementptr %FrameHeader, %StackPointer %stackPointer_380, i64 0, i32 0
        %returnAddress_379 = load %ReturnAddress, ptr %returnAddress_pointer_381, !noalias !2
        musttail call tailcc void %returnAddress_379(%Pos %pureApp_5117, %Stack %stack_378)
        ret void
    
    label_385:
        
        ret void
    
    label_391:
        call ccc void @erasePositive(%Pos %v_r_2542_30_194_4560)
        
        %pair_386 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4421)
        %k_13_14_4_4913 = extractvalue <{%Resumption, %Stack}> %pair_386, 0
        %stack_387 = extractvalue <{%Resumption, %Stack}> %pair_386, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4913)
        
        %longLiteral_5120 = add i64 5, 0
        
        
        
        %pureApp_5121 = call ccc %Pos @boxInt_301(i64 %longLiteral_5120)
        
        
        
        %stackPointer_389 = call ccc %StackPointer @stackDeallocate(%Stack %stack_387, i64 24)
        %returnAddress_pointer_390 = getelementptr %FrameHeader, %StackPointer %stackPointer_389, i64 0, i32 0
        %returnAddress_388 = load %ReturnAddress, ptr %returnAddress_pointer_390, !noalias !2
        musttail call tailcc void %returnAddress_388(%Pos %pureApp_5121, %Stack %stack_387)
        ret void
    
    label_392:
        
        %longLiteral_5123 = add i64 1, 0
        
        %pureApp_5122 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4457, i64 %longLiteral_5123)
        
        
        
        %longLiteral_5125 = add i64 10, 0
        
        %pureApp_5124 = call ccc i64 @infixMul_99(i64 %longLiteral_5125, i64 %acc_8_35_199_4729)
        
        
        
        %pureApp_5126 = call ccc i64 @toInt_2085(i64 %pureApp_5113)
        
        
        
        %pureApp_5127 = call ccc i64 @infixSub_105(i64 %pureApp_5126, i64 %tmp_5006)
        
        
        
        %pureApp_5128 = call ccc i64 @infixAdd_96(i64 %pureApp_5124, i64 %pureApp_5127)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4726(i64 %pureApp_5122, i64 %pureApp_5128, i64 %tmp_5006, %Pos %v_r_2542_30_194_4560, %Prompt %p_8_9_4421, %Stack %stack)
        ret void
    
    label_393:
        
        %intLiteral_5119 = add i64 57, 0
        
        %pureApp_5118 = call ccc %Pos @infixLte_2093(i64 %pureApp_5113, i64 %intLiteral_5119)
        
        
        
        %tag_383 = extractvalue %Pos %pureApp_5118, 0
        %fields_384 = extractvalue %Pos %pureApp_5118, 1
        switch i64 %tag_383, label %label_385 [i64 0, label %label_391 i64 1, label %label_392]
    
    label_394:
        %environment_372 = call ccc %Environment @objectEnvironment(%Object %fields_370)
        %v_coe_3441_46_73_237_4650_pointer_373 = getelementptr <{%Pos}>, %Environment %environment_372, i64 0, i32 0
        %v_coe_3441_46_73_237_4650 = load %Pos, ptr %v_coe_3441_46_73_237_4650_pointer_373, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3441_46_73_237_4650)
        call ccc void @eraseObject(%Object %fields_370)
        
        %pureApp_5113 = call ccc i64 @unboxChar_313(%Pos %v_coe_3441_46_73_237_4650)
        
        
        
        %intLiteral_5115 = add i64 48, 0
        
        %pureApp_5114 = call ccc %Pos @infixGte_2099(i64 %pureApp_5113, i64 %intLiteral_5115)
        
        
        
        %tag_374 = extractvalue %Pos %pureApp_5114, 0
        %fields_375 = extractvalue %Pos %pureApp_5114, 1
        switch i64 %tag_374, label %label_376 [i64 0, label %label_382 i64 1, label %label_393]
    
    label_401:
        %environment_395 = call ccc %Environment @objectEnvironment(%Object %fields_370)
        %v_y_2632_76_103_267_5111_pointer_396 = getelementptr <{%Pos, %Pos}>, %Environment %environment_395, i64 0, i32 0
        %v_y_2632_76_103_267_5111 = load %Pos, ptr %v_y_2632_76_103_267_5111_pointer_396, !noalias !2
        %v_y_2633_77_104_268_5112_pointer_397 = getelementptr <{%Pos, %Pos}>, %Environment %environment_395, i64 0, i32 1
        %v_y_2633_77_104_268_5112 = load %Pos, ptr %v_y_2633_77_104_268_5112_pointer_397, !noalias !2
        call ccc void @eraseObject(%Object %fields_370)
        call ccc void @erasePositive(%Pos %v_r_2542_30_194_4560)
        
        %stackPointer_399 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_400 = getelementptr %FrameHeader, %StackPointer %stackPointer_399, i64 0, i32 0
        %returnAddress_398 = load %ReturnAddress, ptr %returnAddress_pointer_400, !noalias !2
        musttail call tailcc void %returnAddress_398(i64 %acc_8_35_199_4729, %Stack %stack)
        ret void
}



define ccc void @sharer_407(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_408 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_4457_402_pointer_409 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_408, i64 0, i32 0
        %index_7_34_198_4457_402 = load i64, ptr %index_7_34_198_4457_402_pointer_409, !noalias !2
        %tmp_5006_403_pointer_410 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_408, i64 0, i32 1
        %tmp_5006_403 = load i64, ptr %tmp_5006_403_pointer_410, !noalias !2
        %v_r_2542_30_194_4560_404_pointer_411 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_408, i64 0, i32 2
        %v_r_2542_30_194_4560_404 = load %Pos, ptr %v_r_2542_30_194_4560_404_pointer_411, !noalias !2
        %acc_8_35_199_4729_405_pointer_412 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_408, i64 0, i32 3
        %acc_8_35_199_4729_405 = load i64, ptr %acc_8_35_199_4729_405_pointer_412, !noalias !2
        %p_8_9_4421_406_pointer_413 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_408, i64 0, i32 4
        %p_8_9_4421_406 = load %Prompt, ptr %p_8_9_4421_406_pointer_413, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2542_30_194_4560_404)
        call ccc void @shareFrames(%StackPointer %stackPointer_408)
        ret void
}



define ccc void @eraser_419(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_420 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_4457_414_pointer_421 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_420, i64 0, i32 0
        %index_7_34_198_4457_414 = load i64, ptr %index_7_34_198_4457_414_pointer_421, !noalias !2
        %tmp_5006_415_pointer_422 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_420, i64 0, i32 1
        %tmp_5006_415 = load i64, ptr %tmp_5006_415_pointer_422, !noalias !2
        %v_r_2542_30_194_4560_416_pointer_423 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_420, i64 0, i32 2
        %v_r_2542_30_194_4560_416 = load %Pos, ptr %v_r_2542_30_194_4560_416_pointer_423, !noalias !2
        %acc_8_35_199_4729_417_pointer_424 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_420, i64 0, i32 3
        %acc_8_35_199_4729_417 = load i64, ptr %acc_8_35_199_4729_417_pointer_424, !noalias !2
        %p_8_9_4421_418_pointer_425 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_420, i64 0, i32 4
        %p_8_9_4421_418 = load %Prompt, ptr %p_8_9_4421_418_pointer_425, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2542_30_194_4560_416)
        call ccc void @eraseFrames(%StackPointer %stackPointer_420)
        ret void
}



define tailcc void @returnAddress_436(%Pos %returned_5129, %Stack %stack) {
        
    entry:
        
        %stack_437 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_439 = call ccc %StackPointer @stackDeallocate(%Stack %stack_437, i64 24)
        %returnAddress_pointer_440 = getelementptr %FrameHeader, %StackPointer %stackPointer_439, i64 0, i32 0
        %returnAddress_438 = load %ReturnAddress, ptr %returnAddress_pointer_440, !noalias !2
        musttail call tailcc void %returnAddress_438(%Pos %returned_5129, %Stack %stack_437)
        ret void
}



define tailcc void @Exception_7_19_46_210_4643_clause_445(%Object %closure, %Pos %exc_8_20_47_211_4571, %Pos %msg_9_21_48_212_4587, %Stack %stack) {
        
    entry:
        
        %environment_446 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4551_pointer_447 = getelementptr <{%Prompt}>, %Environment %environment_446, i64 0, i32 0
        %p_6_18_45_209_4551 = load %Prompt, ptr %p_6_18_45_209_4551_pointer_447, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_448 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4551)
        %k_11_23_50_214_4743 = extractvalue <{%Resumption, %Stack}> %pair_448, 0
        %stack_449 = extractvalue <{%Resumption, %Stack}> %pair_448, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4743)
        
        %fields_450 = call ccc %Object @newObject(ptr @eraser_172, i64 32)
        %environment_451 = call ccc %Environment @objectEnvironment(%Object %fields_450)
        %exc_8_20_47_211_4571_pointer_454 = getelementptr <{%Pos, %Pos}>, %Environment %environment_451, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4571, ptr %exc_8_20_47_211_4571_pointer_454, !noalias !2
        %msg_9_21_48_212_4587_pointer_455 = getelementptr <{%Pos, %Pos}>, %Environment %environment_451, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4587, ptr %msg_9_21_48_212_4587_pointer_455, !noalias !2
        %make_5130_temporary_456 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5130 = insertvalue %Pos %make_5130_temporary_456, %Object %fields_450, 1
        
        
        
        %stackPointer_458 = call ccc %StackPointer @stackDeallocate(%Stack %stack_449, i64 24)
        %returnAddress_pointer_459 = getelementptr %FrameHeader, %StackPointer %stackPointer_458, i64 0, i32 0
        %returnAddress_457 = load %ReturnAddress, ptr %returnAddress_pointer_459, !noalias !2
        musttail call tailcc void %returnAddress_457(%Pos %make_5130, %Stack %stack_449)
        ret void
}


@vtable_460 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4643_clause_445]


define ccc void @eraser_464(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4551_463_pointer_465 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4551_463 = load %Prompt, ptr %p_6_18_45_209_4551_463_pointer_465, !noalias !2
        ret void
}



define ccc void @eraser_472(%Environment %environment) {
        
    entry:
        
        %tmp_5008_471_pointer_473 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5008_471 = load %Pos, ptr %tmp_5008_471_pointer_473, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5008_471)
        ret void
}



define tailcc void @returnAddress_468(i64 %v_coe_3440_6_28_55_219_4657, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5131 = call ccc %Pos @boxChar_311(i64 %v_coe_3440_6_28_55_219_4657)
        
        
        
        %fields_469 = call ccc %Object @newObject(ptr @eraser_472, i64 16)
        %environment_470 = call ccc %Environment @objectEnvironment(%Object %fields_469)
        %tmp_5008_pointer_474 = getelementptr <{%Pos}>, %Environment %environment_470, i64 0, i32 0
        store %Pos %pureApp_5131, ptr %tmp_5008_pointer_474, !noalias !2
        %make_5132_temporary_475 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5132 = insertvalue %Pos %make_5132_temporary_475, %Object %fields_469, 1
        
        
        
        %stackPointer_477 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_478 = getelementptr %FrameHeader, %StackPointer %stackPointer_477, i64 0, i32 0
        %returnAddress_476 = load %ReturnAddress, ptr %returnAddress_pointer_478, !noalias !2
        musttail call tailcc void %returnAddress_476(%Pos %make_5132, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4726(i64 %index_7_34_198_4457, i64 %acc_8_35_199_4729, i64 %tmp_5006, %Pos %v_r_2542_30_194_4560, %Prompt %p_8_9_4421, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2542_30_194_4560)
        %stackPointer_426 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %index_7_34_198_4457_pointer_427 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_426, i64 0, i32 0
        store i64 %index_7_34_198_4457, ptr %index_7_34_198_4457_pointer_427, !noalias !2
        %tmp_5006_pointer_428 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_426, i64 0, i32 1
        store i64 %tmp_5006, ptr %tmp_5006_pointer_428, !noalias !2
        %v_r_2542_30_194_4560_pointer_429 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_426, i64 0, i32 2
        store %Pos %v_r_2542_30_194_4560, ptr %v_r_2542_30_194_4560_pointer_429, !noalias !2
        %acc_8_35_199_4729_pointer_430 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_426, i64 0, i32 3
        store i64 %acc_8_35_199_4729, ptr %acc_8_35_199_4729_pointer_430, !noalias !2
        %p_8_9_4421_pointer_431 = getelementptr <{i64, i64, %Pos, i64, %Prompt}>, %StackPointer %stackPointer_426, i64 0, i32 4
        store %Prompt %p_8_9_4421, ptr %p_8_9_4421_pointer_431, !noalias !2
        %returnAddress_pointer_432 = getelementptr <{<{i64, i64, %Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 0
        %sharer_pointer_433 = getelementptr <{<{i64, i64, %Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 1
        %eraser_pointer_434 = getelementptr <{<{i64, i64, %Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 2
        store ptr @returnAddress_362, ptr %returnAddress_pointer_432, !noalias !2
        store ptr @sharer_407, ptr %sharer_pointer_433, !noalias !2
        store ptr @eraser_419, ptr %eraser_pointer_434, !noalias !2
        
        %stack_435 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4551 = call ccc %Prompt @currentPrompt(%Stack %stack_435)
        %stackPointer_441 = call ccc %StackPointer @stackAllocate(%Stack %stack_435, i64 24)
        %returnAddress_pointer_442 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_441, i64 0, i32 1, i32 0
        %sharer_pointer_443 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_441, i64 0, i32 1, i32 1
        %eraser_pointer_444 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_441, i64 0, i32 1, i32 2
        store ptr @returnAddress_436, ptr %returnAddress_pointer_442, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_443, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_444, !noalias !2
        
        %closure_461 = call ccc %Object @newObject(ptr @eraser_464, i64 8)
        %environment_462 = call ccc %Environment @objectEnvironment(%Object %closure_461)
        %p_6_18_45_209_4551_pointer_466 = getelementptr <{%Prompt}>, %Environment %environment_462, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4551, ptr %p_6_18_45_209_4551_pointer_466, !noalias !2
        %vtable_temporary_467 = insertvalue %Neg zeroinitializer, ptr @vtable_460, 0
        %Exception_7_19_46_210_4643 = insertvalue %Neg %vtable_temporary_467, %Object %closure_461, 1
        %stackPointer_479 = call ccc %StackPointer @stackAllocate(%Stack %stack_435, i64 24)
        %returnAddress_pointer_480 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_479, i64 0, i32 1, i32 0
        %sharer_pointer_481 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_479, i64 0, i32 1, i32 1
        %eraser_pointer_482 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_479, i64 0, i32 1, i32 2
        store ptr @returnAddress_468, ptr %returnAddress_pointer_480, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_481, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_482, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2542_30_194_4560, i64 %index_7_34_198_4457, %Neg %Exception_7_19_46_210_4643, %Stack %stack_435)
        ret void
}



define tailcc void @Exception_9_106_133_297_4649_clause_483(%Object %closure, %Pos %exception_10_107_134_298_5133, %Pos %msg_11_108_135_299_5134, %Stack %stack) {
        
    entry:
        
        %environment_484 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4421_pointer_485 = getelementptr <{%Prompt}>, %Environment %environment_484, i64 0, i32 0
        %p_8_9_4421 = load %Prompt, ptr %p_8_9_4421_pointer_485, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5133)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5134)
        
        %pair_486 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4421)
        %k_13_14_4_4989 = extractvalue <{%Resumption, %Stack}> %pair_486, 0
        %stack_487 = extractvalue <{%Resumption, %Stack}> %pair_486, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4989)
        
        %longLiteral_5135 = add i64 5, 0
        
        
        
        %pureApp_5136 = call ccc %Pos @boxInt_301(i64 %longLiteral_5135)
        
        
        
        %stackPointer_489 = call ccc %StackPointer @stackDeallocate(%Stack %stack_487, i64 24)
        %returnAddress_pointer_490 = getelementptr %FrameHeader, %StackPointer %stackPointer_489, i64 0, i32 0
        %returnAddress_488 = load %ReturnAddress, ptr %returnAddress_pointer_490, !noalias !2
        musttail call tailcc void %returnAddress_488(%Pos %pureApp_5136, %Stack %stack_487)
        ret void
}


@vtable_491 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4649_clause_483]


define tailcc void @returnAddress_502(i64 %v_coe_3445_22_131_158_322_4478, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5139 = call ccc %Pos @boxInt_301(i64 %v_coe_3445_22_131_158_322_4478)
        
        
        
        
        
        %pureApp_5140 = call ccc i64 @unboxInt_303(%Pos %pureApp_5139)
        
        
        
        %pureApp_5141 = call ccc %Pos @boxInt_301(i64 %pureApp_5140)
        
        
        
        %stackPointer_504 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_505 = getelementptr %FrameHeader, %StackPointer %stackPointer_504, i64 0, i32 0
        %returnAddress_503 = load %ReturnAddress, ptr %returnAddress_pointer_505, !noalias !2
        musttail call tailcc void %returnAddress_503(%Pos %pureApp_5141, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_514(i64 %v_r_2639_1_9_20_129_156_320_4564, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5145 = add i64 0, 0
        
        %pureApp_5144 = call ccc i64 @infixSub_105(i64 %longLiteral_5145, i64 %v_r_2639_1_9_20_129_156_320_4564)
        
        
        
        %stackPointer_516 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_517 = getelementptr %FrameHeader, %StackPointer %stackPointer_516, i64 0, i32 0
        %returnAddress_515 = load %ReturnAddress, ptr %returnAddress_pointer_517, !noalias !2
        musttail call tailcc void %returnAddress_515(i64 %pureApp_5144, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_497(i64 %v_r_2638_3_14_123_150_314_4526, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_498 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_5006_pointer_499 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_498, i64 0, i32 0
        %tmp_5006 = load i64, ptr %tmp_5006_pointer_499, !noalias !2
        %v_r_2542_30_194_4560_pointer_500 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_498, i64 0, i32 1
        %v_r_2542_30_194_4560 = load %Pos, ptr %v_r_2542_30_194_4560_pointer_500, !noalias !2
        %p_8_9_4421_pointer_501 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_498, i64 0, i32 2
        %p_8_9_4421 = load %Prompt, ptr %p_8_9_4421_pointer_501, !noalias !2
        
        %intLiteral_5138 = add i64 45, 0
        
        %pureApp_5137 = call ccc %Pos @infixEq_78(i64 %v_r_2638_3_14_123_150_314_4526, i64 %intLiteral_5138)
        
        
        %stackPointer_506 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_507 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_506, i64 0, i32 1, i32 0
        %sharer_pointer_508 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_506, i64 0, i32 1, i32 1
        %eraser_pointer_509 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_506, i64 0, i32 1, i32 2
        store ptr @returnAddress_502, ptr %returnAddress_pointer_507, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_508, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_509, !noalias !2
        
        %tag_510 = extractvalue %Pos %pureApp_5137, 0
        %fields_511 = extractvalue %Pos %pureApp_5137, 1
        switch i64 %tag_510, label %label_512 [i64 0, label %label_513 i64 1, label %label_522]
    
    label_512:
        
        ret void
    
    label_513:
        
        %longLiteral_5142 = add i64 0, 0
        
        %longLiteral_5143 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4726(i64 %longLiteral_5142, i64 %longLiteral_5143, i64 %tmp_5006, %Pos %v_r_2542_30_194_4560, %Prompt %p_8_9_4421, %Stack %stack)
        ret void
    
    label_522:
        %stackPointer_518 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_519 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_518, i64 0, i32 1, i32 0
        %sharer_pointer_520 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_518, i64 0, i32 1, i32 1
        %eraser_pointer_521 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_518, i64 0, i32 1, i32 2
        store ptr @returnAddress_514, ptr %returnAddress_pointer_519, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_520, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_521, !noalias !2
        
        %longLiteral_5146 = add i64 1, 0
        
        %longLiteral_5147 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4726(i64 %longLiteral_5146, i64 %longLiteral_5147, i64 %tmp_5006, %Pos %v_r_2542_30_194_4560, %Prompt %p_8_9_4421, %Stack %stack)
        ret void
}



define ccc void @sharer_526(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_527 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_5006_523_pointer_528 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_527, i64 0, i32 0
        %tmp_5006_523 = load i64, ptr %tmp_5006_523_pointer_528, !noalias !2
        %v_r_2542_30_194_4560_524_pointer_529 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_527, i64 0, i32 1
        %v_r_2542_30_194_4560_524 = load %Pos, ptr %v_r_2542_30_194_4560_524_pointer_529, !noalias !2
        %p_8_9_4421_525_pointer_530 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_527, i64 0, i32 2
        %p_8_9_4421_525 = load %Prompt, ptr %p_8_9_4421_525_pointer_530, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2542_30_194_4560_524)
        call ccc void @shareFrames(%StackPointer %stackPointer_527)
        ret void
}



define ccc void @eraser_534(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_535 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_5006_531_pointer_536 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_535, i64 0, i32 0
        %tmp_5006_531 = load i64, ptr %tmp_5006_531_pointer_536, !noalias !2
        %v_r_2542_30_194_4560_532_pointer_537 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_535, i64 0, i32 1
        %v_r_2542_30_194_4560_532 = load %Pos, ptr %v_r_2542_30_194_4560_532_pointer_537, !noalias !2
        %p_8_9_4421_533_pointer_538 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_535, i64 0, i32 2
        %p_8_9_4421_533 = load %Prompt, ptr %p_8_9_4421_533_pointer_538, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2542_30_194_4560_532)
        call ccc void @eraseFrames(%StackPointer %stackPointer_535)
        ret void
}



define tailcc void @returnAddress_359(%Pos %v_r_2542_30_194_4560, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_360 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4421_pointer_361 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_360, i64 0, i32 0
        %p_8_9_4421 = load %Prompt, ptr %p_8_9_4421_pointer_361, !noalias !2
        
        %intLiteral_5110 = add i64 48, 0
        
        %pureApp_5109 = call ccc i64 @toInt_2085(i64 %intLiteral_5110)
        
        
        
        %closure_492 = call ccc %Object @newObject(ptr @eraser_464, i64 8)
        %environment_493 = call ccc %Environment @objectEnvironment(%Object %closure_492)
        %p_8_9_4421_pointer_495 = getelementptr <{%Prompt}>, %Environment %environment_493, i64 0, i32 0
        store %Prompt %p_8_9_4421, ptr %p_8_9_4421_pointer_495, !noalias !2
        %vtable_temporary_496 = insertvalue %Neg zeroinitializer, ptr @vtable_491, 0
        %Exception_9_106_133_297_4649 = insertvalue %Neg %vtable_temporary_496, %Object %closure_492, 1
        call ccc void @sharePositive(%Pos %v_r_2542_30_194_4560)
        %stackPointer_539 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_5006_pointer_540 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_539, i64 0, i32 0
        store i64 %pureApp_5109, ptr %tmp_5006_pointer_540, !noalias !2
        %v_r_2542_30_194_4560_pointer_541 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_539, i64 0, i32 1
        store %Pos %v_r_2542_30_194_4560, ptr %v_r_2542_30_194_4560_pointer_541, !noalias !2
        %p_8_9_4421_pointer_542 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_539, i64 0, i32 2
        store %Prompt %p_8_9_4421, ptr %p_8_9_4421_pointer_542, !noalias !2
        %returnAddress_pointer_543 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_539, i64 0, i32 1, i32 0
        %sharer_pointer_544 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_539, i64 0, i32 1, i32 1
        %eraser_pointer_545 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_539, i64 0, i32 1, i32 2
        store ptr @returnAddress_497, ptr %returnAddress_pointer_543, !noalias !2
        store ptr @sharer_526, ptr %sharer_pointer_544, !noalias !2
        store ptr @eraser_534, ptr %eraser_pointer_545, !noalias !2
        
        %longLiteral_5148 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2542_30_194_4560, i64 %longLiteral_5148, %Neg %Exception_9_106_133_297_4649, %Stack %stack)
        ret void
}



define ccc void @sharer_547(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_548 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4421_546_pointer_549 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_548, i64 0, i32 0
        %p_8_9_4421_546 = load %Prompt, ptr %p_8_9_4421_546_pointer_549, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_548)
        ret void
}



define ccc void @eraser_551(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_552 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4421_550_pointer_553 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_552, i64 0, i32 0
        %p_8_9_4421_550 = load %Prompt, ptr %p_8_9_4421_550_pointer_553, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_552)
        ret void
}


@utf8StringLiteral_5149.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_356(%Pos %v_r_2541_24_188_4706, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_357 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4421_pointer_358 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_357, i64 0, i32 0
        %p_8_9_4421 = load %Prompt, ptr %p_8_9_4421_pointer_358, !noalias !2
        %stackPointer_554 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4421_pointer_555 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_554, i64 0, i32 0
        store %Prompt %p_8_9_4421, ptr %p_8_9_4421_pointer_555, !noalias !2
        %returnAddress_pointer_556 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_554, i64 0, i32 1, i32 0
        %sharer_pointer_557 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_554, i64 0, i32 1, i32 1
        %eraser_pointer_558 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_554, i64 0, i32 1, i32 2
        store ptr @returnAddress_359, ptr %returnAddress_pointer_556, !noalias !2
        store ptr @sharer_547, ptr %sharer_pointer_557, !noalias !2
        store ptr @eraser_551, ptr %eraser_pointer_558, !noalias !2
        
        %tag_559 = extractvalue %Pos %v_r_2541_24_188_4706, 0
        %fields_560 = extractvalue %Pos %v_r_2541_24_188_4706, 1
        switch i64 %tag_559, label %label_561 [i64 0, label %label_565 i64 1, label %label_571]
    
    label_561:
        
        ret void
    
    label_565:
        
        %utf8StringLiteral_5149 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5149.lit)
        
        %stackPointer_563 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_564 = getelementptr %FrameHeader, %StackPointer %stackPointer_563, i64 0, i32 0
        %returnAddress_562 = load %ReturnAddress, ptr %returnAddress_pointer_564, !noalias !2
        musttail call tailcc void %returnAddress_562(%Pos %utf8StringLiteral_5149, %Stack %stack)
        ret void
    
    label_571:
        %environment_566 = call ccc %Environment @objectEnvironment(%Object %fields_560)
        %v_y_3267_8_29_193_4556_pointer_567 = getelementptr <{%Pos}>, %Environment %environment_566, i64 0, i32 0
        %v_y_3267_8_29_193_4556 = load %Pos, ptr %v_y_3267_8_29_193_4556_pointer_567, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3267_8_29_193_4556)
        call ccc void @eraseObject(%Object %fields_560)
        
        %stackPointer_569 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_570 = getelementptr %FrameHeader, %StackPointer %stackPointer_569, i64 0, i32 0
        %returnAddress_568 = load %ReturnAddress, ptr %returnAddress_pointer_570, !noalias !2
        musttail call tailcc void %returnAddress_568(%Pos %v_y_3267_8_29_193_4556, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_353(%Pos %v_r_2540_13_177_4622, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_354 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4421_pointer_355 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_354, i64 0, i32 0
        %p_8_9_4421 = load %Prompt, ptr %p_8_9_4421_pointer_355, !noalias !2
        %stackPointer_574 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4421_pointer_575 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_574, i64 0, i32 0
        store %Prompt %p_8_9_4421, ptr %p_8_9_4421_pointer_575, !noalias !2
        %returnAddress_pointer_576 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_574, i64 0, i32 1, i32 0
        %sharer_pointer_577 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_574, i64 0, i32 1, i32 1
        %eraser_pointer_578 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_574, i64 0, i32 1, i32 2
        store ptr @returnAddress_356, ptr %returnAddress_pointer_576, !noalias !2
        store ptr @sharer_547, ptr %sharer_pointer_577, !noalias !2
        store ptr @eraser_551, ptr %eraser_pointer_578, !noalias !2
        
        %tag_579 = extractvalue %Pos %v_r_2540_13_177_4622, 0
        %fields_580 = extractvalue %Pos %v_r_2540_13_177_4622, 1
        switch i64 %tag_579, label %label_581 [i64 0, label %label_586 i64 1, label %label_598]
    
    label_581:
        
        ret void
    
    label_586:
        
        %make_5150_temporary_582 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5150 = insertvalue %Pos %make_5150_temporary_582, %Object null, 1
        
        
        
        %stackPointer_584 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_585 = getelementptr %FrameHeader, %StackPointer %stackPointer_584, i64 0, i32 0
        %returnAddress_583 = load %ReturnAddress, ptr %returnAddress_pointer_585, !noalias !2
        musttail call tailcc void %returnAddress_583(%Pos %make_5150, %Stack %stack)
        ret void
    
    label_598:
        %environment_587 = call ccc %Environment @objectEnvironment(%Object %fields_580)
        %v_y_2776_10_21_185_4500_pointer_588 = getelementptr <{%Pos, %Pos}>, %Environment %environment_587, i64 0, i32 0
        %v_y_2776_10_21_185_4500 = load %Pos, ptr %v_y_2776_10_21_185_4500_pointer_588, !noalias !2
        %v_y_2777_11_22_186_4540_pointer_589 = getelementptr <{%Pos, %Pos}>, %Environment %environment_587, i64 0, i32 1
        %v_y_2777_11_22_186_4540 = load %Pos, ptr %v_y_2777_11_22_186_4540_pointer_589, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2776_10_21_185_4500)
        call ccc void @eraseObject(%Object %fields_580)
        
        %fields_590 = call ccc %Object @newObject(ptr @eraser_472, i64 16)
        %environment_591 = call ccc %Environment @objectEnvironment(%Object %fields_590)
        %v_y_2776_10_21_185_4500_pointer_593 = getelementptr <{%Pos}>, %Environment %environment_591, i64 0, i32 0
        store %Pos %v_y_2776_10_21_185_4500, ptr %v_y_2776_10_21_185_4500_pointer_593, !noalias !2
        %make_5151_temporary_594 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5151 = insertvalue %Pos %make_5151_temporary_594, %Object %fields_590, 1
        
        
        
        %stackPointer_596 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_597 = getelementptr %FrameHeader, %StackPointer %stackPointer_596, i64 0, i32 0
        %returnAddress_595 = load %ReturnAddress, ptr %returnAddress_pointer_597, !noalias !2
        musttail call tailcc void %returnAddress_595(%Pos %make_5151, %Stack %stack)
        ret void
}



define tailcc void @main_2443(%Stack %stack) {
        
    entry:
        
        %stackPointer_323 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_324 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 0
        %sharer_pointer_325 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 1
        %eraser_pointer_326 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_323, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_324, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_325, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_326, !noalias !2
        
        %stack_327 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4421 = call ccc %Prompt @currentPrompt(%Stack %stack_327)
        %stackPointer_333 = call ccc %StackPointer @stackAllocate(%Stack %stack_327, i64 24)
        %returnAddress_pointer_334 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_333, i64 0, i32 1, i32 0
        %sharer_pointer_335 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_333, i64 0, i32 1, i32 1
        %eraser_pointer_336 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_333, i64 0, i32 1, i32 2
        store ptr @returnAddress_328, ptr %returnAddress_pointer_334, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_335, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_336, !noalias !2
        
        %pureApp_5105 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5107 = add i64 1, 0
        
        %pureApp_5106 = call ccc i64 @infixSub_105(i64 %pureApp_5105, i64 %longLiteral_5107)
        
        
        
        %make_5108_temporary_352 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5108 = insertvalue %Pos %make_5108_temporary_352, %Object null, 1
        
        
        %stackPointer_601 = call ccc %StackPointer @stackAllocate(%Stack %stack_327, i64 32)
        %p_8_9_4421_pointer_602 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_601, i64 0, i32 0
        store %Prompt %p_8_9_4421, ptr %p_8_9_4421_pointer_602, !noalias !2
        %returnAddress_pointer_603 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_601, i64 0, i32 1, i32 0
        %sharer_pointer_604 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_601, i64 0, i32 1, i32 1
        %eraser_pointer_605 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_601, i64 0, i32 1, i32 2
        store ptr @returnAddress_353, ptr %returnAddress_pointer_603, !noalias !2
        store ptr @sharer_547, ptr %sharer_pointer_604, !noalias !2
        store ptr @eraser_551, ptr %eraser_pointer_605, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4553(i64 %pureApp_5106, %Pos %make_5108, %Stack %stack_327)
        ret void
}


@utf8StringLiteral_5055.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5057.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5060.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_606(%Pos %v_r_2707_3500, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_607 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_608 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_607, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_608, !noalias !2
        %index_2107_pointer_609 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_607, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_609, !noalias !2
        %Exception_2362_pointer_610 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_607, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_610, !noalias !2
        
        %tag_611 = extractvalue %Pos %v_r_2707_3500, 0
        %fields_612 = extractvalue %Pos %v_r_2707_3500, 1
        switch i64 %tag_611, label %label_613 [i64 0, label %label_617 i64 1, label %label_623]
    
    label_613:
        
        ret void
    
    label_617:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5051 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_615 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_616 = getelementptr %FrameHeader, %StackPointer %stackPointer_615, i64 0, i32 0
        %returnAddress_614 = load %ReturnAddress, ptr %returnAddress_pointer_616, !noalias !2
        musttail call tailcc void %returnAddress_614(i64 %pureApp_5051, %Stack %stack)
        ret void
    
    label_623:
        
        %make_5052_temporary_618 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5052 = insertvalue %Pos %make_5052_temporary_618, %Object null, 1
        
        
        
        %pureApp_5053 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5055 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5055.lit)
        
        %pureApp_5054 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5055, %Pos %pureApp_5053)
        
        
        
        %utf8StringLiteral_5057 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5057.lit)
        
        %pureApp_5056 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5054, %Pos %utf8StringLiteral_5057)
        
        
        
        %pureApp_5058 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5056, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5060 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5060.lit)
        
        %pureApp_5059 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5058, %Pos %utf8StringLiteral_5060)
        
        
        
        %vtable_619 = extractvalue %Neg %Exception_2362, 0
        %closure_620 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_621 = getelementptr ptr, ptr %vtable_619, i64 0
        %functionPointer_622 = load ptr, ptr %functionPointer_pointer_621, !noalias !2
        musttail call tailcc void %functionPointer_622(%Object %closure_620, %Pos %make_5052, %Pos %pureApp_5059, %Stack %stack)
        ret void
}



define ccc void @sharer_627(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_628 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_624_pointer_629 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_628, i64 0, i32 0
        %str_2106_624 = load %Pos, ptr %str_2106_624_pointer_629, !noalias !2
        %index_2107_625_pointer_630 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_628, i64 0, i32 1
        %index_2107_625 = load i64, ptr %index_2107_625_pointer_630, !noalias !2
        %Exception_2362_626_pointer_631 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_628, i64 0, i32 2
        %Exception_2362_626 = load %Neg, ptr %Exception_2362_626_pointer_631, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_624)
        call ccc void @shareNegative(%Neg %Exception_2362_626)
        call ccc void @shareFrames(%StackPointer %stackPointer_628)
        ret void
}



define ccc void @eraser_635(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_636 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_632_pointer_637 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_636, i64 0, i32 0
        %str_2106_632 = load %Pos, ptr %str_2106_632_pointer_637, !noalias !2
        %index_2107_633_pointer_638 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_636, i64 0, i32 1
        %index_2107_633 = load i64, ptr %index_2107_633_pointer_638, !noalias !2
        %Exception_2362_634_pointer_639 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_636, i64 0, i32 2
        %Exception_2362_634 = load %Neg, ptr %Exception_2362_634_pointer_639, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_632)
        call ccc void @eraseNegative(%Neg %Exception_2362_634)
        call ccc void @eraseFrames(%StackPointer %stackPointer_636)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5050 = add i64 0, 0
        
        %pureApp_5049 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5050)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_640 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_641 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_640, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_641, !noalias !2
        %index_2107_pointer_642 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_640, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_642, !noalias !2
        %Exception_2362_pointer_643 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_640, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_643, !noalias !2
        %returnAddress_pointer_644 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_640, i64 0, i32 1, i32 0
        %sharer_pointer_645 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_640, i64 0, i32 1, i32 1
        %eraser_pointer_646 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_640, i64 0, i32 1, i32 2
        store ptr @returnAddress_606, ptr %returnAddress_pointer_644, !noalias !2
        store ptr @sharer_627, ptr %sharer_pointer_645, !noalias !2
        store ptr @eraser_635, ptr %eraser_pointer_646, !noalias !2
        
        %tag_647 = extractvalue %Pos %pureApp_5049, 0
        %fields_648 = extractvalue %Pos %pureApp_5049, 1
        switch i64 %tag_647, label %label_649 [i64 0, label %label_653 i64 1, label %label_658]
    
    label_649:
        
        ret void
    
    label_653:
        
        %pureApp_5061 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5062 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5061)
        
        
        
        %stackPointer_651 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_652 = getelementptr %FrameHeader, %StackPointer %stackPointer_651, i64 0, i32 0
        %returnAddress_650 = load %ReturnAddress, ptr %returnAddress_pointer_652, !noalias !2
        musttail call tailcc void %returnAddress_650(%Pos %pureApp_5062, %Stack %stack)
        ret void
    
    label_658:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5063_temporary_654 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5063 = insertvalue %Pos %booleanLiteral_5063_temporary_654, %Object null, 1
        
        %stackPointer_656 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_657 = getelementptr %FrameHeader, %StackPointer %stackPointer_656, i64 0, i32 0
        %returnAddress_655 = load %ReturnAddress, ptr %returnAddress_pointer_657, !noalias !2
        musttail call tailcc void %returnAddress_655(%Pos %booleanLiteral_5063, %Stack %stack)
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
        
        musttail call tailcc void @main_2443(%Stack %stack)
        ret void
}
