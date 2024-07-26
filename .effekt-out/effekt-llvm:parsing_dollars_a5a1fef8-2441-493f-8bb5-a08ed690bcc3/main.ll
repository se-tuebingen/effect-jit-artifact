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



define tailcc void @returnAddress_2(i64 %r_2467, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5404 = call ccc %Pos @show_14(i64 %r_2467)
        
        
        
        %pureApp_5405 = call ccc %Pos @println_1(%Pos %pureApp_5404)
        
        
        
        %stackPointer_4 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_5 = getelementptr %FrameHeader, %StackPointer %stackPointer_4, i64 0, i32 0
        %returnAddress_3 = load %ReturnAddress, ptr %returnAddress_pointer_5, !noalias !2
        musttail call tailcc void %returnAddress_3(%Pos %pureApp_5405, %Stack %stack)
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
        %v_r_2575_3_153_5175_pointer_17 = getelementptr <{i64}>, %StackPointer %stackPointer_16, i64 0, i32 0
        %v_r_2575_3_153_5175 = load i64, ptr %v_r_2575_3_153_5175_pointer_17, !noalias !2
        %stackPointer_19 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_20 = getelementptr %FrameHeader, %StackPointer %stackPointer_19, i64 0, i32 0
        %returnAddress_18 = load %ReturnAddress, ptr %returnAddress_pointer_20, !noalias !2
        musttail call tailcc void %returnAddress_18(i64 %returnValue_15, %Stack %stack)
        ret void
}



define ccc void @sharer_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2575_3_153_5175_21_pointer_24 = getelementptr <{i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %v_r_2575_3_153_5175_21 = load i64, ptr %v_r_2575_3_153_5175_21_pointer_24, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_23)
        ret void
}



define ccc void @eraser_26(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_27 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2575_3_153_5175_25_pointer_28 = getelementptr <{i64}>, %StackPointer %stackPointer_27, i64 0, i32 0
        %v_r_2575_3_153_5175_25 = load i64, ptr %v_r_2575_3_153_5175_25_pointer_28, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_27)
        ret void
}



define tailcc void @returnAddress_34(%Pos %__16_342_5275, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_35 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %s_4_154_5218_pointer_36 = getelementptr <{%Reference}>, %StackPointer %stackPointer_35, i64 0, i32 0
        %s_4_154_5218 = load %Reference, ptr %s_4_154_5218_pointer_36, !noalias !2
        call ccc void @erasePositive(%Pos %__16_342_5275)
        
        %get_5407_pointer_37 = call ccc ptr @getVarPointer(%Reference %s_4_154_5218, %Stack %stack)
        %s_4_154_5218_old_38 = load i64, ptr %get_5407_pointer_37, !noalias !2
        %get_5407 = load i64, ptr %get_5407_pointer_37, !noalias !2
        
        %stackPointer_40 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_41 = getelementptr %FrameHeader, %StackPointer %stackPointer_40, i64 0, i32 0
        %returnAddress_39 = load %ReturnAddress, ptr %returnAddress_pointer_41, !noalias !2
        musttail call tailcc void %returnAddress_39(i64 %get_5407, %Stack %stack)
        ret void
}



define ccc void @sharer_43(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_44 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %s_4_154_5218_42_pointer_45 = getelementptr <{%Reference}>, %StackPointer %stackPointer_44, i64 0, i32 0
        %s_4_154_5218_42 = load %Reference, ptr %s_4_154_5218_42_pointer_45, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_44)
        ret void
}



define ccc void @eraser_47(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_48 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %s_4_154_5218_46_pointer_49 = getelementptr <{%Reference}>, %StackPointer %stackPointer_48, i64 0, i32 0
        %s_4_154_5218_46 = load %Reference, ptr %s_4_154_5218_46_pointer_49, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_48)
        ret void
}



define tailcc void @returnAddress_56(%Pos %returned_5408, %Stack %stack) {
        
    entry:
        
        %stack_57 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_59 = call ccc %StackPointer @stackDeallocate(%Stack %stack_57, i64 24)
        %returnAddress_pointer_60 = getelementptr %FrameHeader, %StackPointer %stackPointer_59, i64 0, i32 0
        %returnAddress_58 = load %ReturnAddress, ptr %returnAddress_pointer_60, !noalias !2
        musttail call tailcc void %returnAddress_58(%Pos %returned_5408, %Stack %stack_57)
        ret void
}



define ccc void @sharer_61(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_62 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_63(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_64 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_64)
        ret void
}



define tailcc void @returnAddress_69(%Pos %returnValue_70, %Stack %stack) {
        
    entry:
        
        %stackPointer_71 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2591_6_15_91_275_5158_pointer_72 = getelementptr <{i64}>, %StackPointer %stackPointer_71, i64 0, i32 0
        %v_r_2591_6_15_91_275_5158 = load i64, ptr %v_r_2591_6_15_91_275_5158_pointer_72, !noalias !2
        %stackPointer_74 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_75 = getelementptr %FrameHeader, %StackPointer %stackPointer_74, i64 0, i32 0
        %returnAddress_73 = load %ReturnAddress, ptr %returnAddress_pointer_75, !noalias !2
        musttail call tailcc void %returnAddress_73(%Pos %returnValue_70, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_83(%Pos %returnValue_84, %Stack %stack) {
        
    entry:
        
        %stackPointer_85 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2592_8_17_93_277_5174_pointer_86 = getelementptr <{i64}>, %StackPointer %stackPointer_85, i64 0, i32 0
        %v_r_2592_8_17_93_277_5174 = load i64, ptr %v_r_2592_8_17_93_277_5174_pointer_86, !noalias !2
        %stackPointer_88 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_89 = getelementptr %FrameHeader, %StackPointer %stackPointer_88, i64 0, i32 0
        %returnAddress_87 = load %ReturnAddress, ptr %returnAddress_pointer_89, !noalias !2
        musttail call tailcc void %returnAddress_87(%Pos %returnValue_84, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_134(%Pos %__15_8_338_5273, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_135 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %tmp_5386_pointer_136 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_135, i64 0, i32 0
        %tmp_5386 = load i64, ptr %tmp_5386_pointer_136, !noalias !2
        %j_9_18_94_278_5023_pointer_137 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_135, i64 0, i32 1
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_137, !noalias !2
        %p_4_73_250_5097_pointer_138 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_135, i64 0, i32 2
        %p_4_73_250_5097 = load %Prompt, ptr %p_4_73_250_5097_pointer_138, !noalias !2
        %i_7_16_92_276_5069_pointer_139 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_135, i64 0, i32 3
        %i_7_16_92_276_5069 = load %Reference, ptr %i_7_16_92_276_5069_pointer_139, !noalias !2
        %s_4_154_5218_pointer_140 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_135, i64 0, i32 4
        %s_4_154_5218 = load %Reference, ptr %s_4_154_5218_pointer_140, !noalias !2
        call ccc void @erasePositive(%Pos %__15_8_338_5273)
        
        %longLiteral_5421 = add i64 0, 0
        
        
        
        musttail call tailcc void @parse_worker_8_3_41_119_303_5122(i64 %longLiteral_5421, i64 %tmp_5386, %Reference %j_9_18_94_278_5023, %Prompt %p_4_73_250_5097, %Reference %i_7_16_92_276_5069, %Reference %s_4_154_5218, %Stack %stack)
        ret void
}



define ccc void @sharer_146(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_147 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5386_141_pointer_148 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_147, i64 0, i32 0
        %tmp_5386_141 = load i64, ptr %tmp_5386_141_pointer_148, !noalias !2
        %j_9_18_94_278_5023_142_pointer_149 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_147, i64 0, i32 1
        %j_9_18_94_278_5023_142 = load %Reference, ptr %j_9_18_94_278_5023_142_pointer_149, !noalias !2
        %p_4_73_250_5097_143_pointer_150 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_147, i64 0, i32 2
        %p_4_73_250_5097_143 = load %Prompt, ptr %p_4_73_250_5097_143_pointer_150, !noalias !2
        %i_7_16_92_276_5069_144_pointer_151 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_147, i64 0, i32 3
        %i_7_16_92_276_5069_144 = load %Reference, ptr %i_7_16_92_276_5069_144_pointer_151, !noalias !2
        %s_4_154_5218_145_pointer_152 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_147, i64 0, i32 4
        %s_4_154_5218_145 = load %Reference, ptr %s_4_154_5218_145_pointer_152, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_147)
        ret void
}



define ccc void @eraser_158(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_159 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %tmp_5386_153_pointer_160 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_159, i64 0, i32 0
        %tmp_5386_153 = load i64, ptr %tmp_5386_153_pointer_160, !noalias !2
        %j_9_18_94_278_5023_154_pointer_161 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_159, i64 0, i32 1
        %j_9_18_94_278_5023_154 = load %Reference, ptr %j_9_18_94_278_5023_154_pointer_161, !noalias !2
        %p_4_73_250_5097_155_pointer_162 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_159, i64 0, i32 2
        %p_4_73_250_5097_155 = load %Prompt, ptr %p_4_73_250_5097_155_pointer_162, !noalias !2
        %i_7_16_92_276_5069_156_pointer_163 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_159, i64 0, i32 3
        %i_7_16_92_276_5069_156 = load %Reference, ptr %i_7_16_92_276_5069_156_pointer_163, !noalias !2
        %s_4_154_5218_157_pointer_164 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_159, i64 0, i32 4
        %s_4_154_5218_157 = load %Reference, ptr %s_4_154_5218_157_pointer_164, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_159)
        ret void
}



define tailcc void @returnAddress_126(i64 %v_r_2578_13_6_336_5092, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_127 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %a_9_4_42_120_304_5012_pointer_128 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_127, i64 0, i32 0
        %a_9_4_42_120_304_5012 = load i64, ptr %a_9_4_42_120_304_5012_pointer_128, !noalias !2
        %tmp_5386_pointer_129 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_127, i64 0, i32 1
        %tmp_5386 = load i64, ptr %tmp_5386_pointer_129, !noalias !2
        %j_9_18_94_278_5023_pointer_130 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_127, i64 0, i32 2
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_130, !noalias !2
        %p_4_73_250_5097_pointer_131 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_127, i64 0, i32 3
        %p_4_73_250_5097 = load %Prompt, ptr %p_4_73_250_5097_pointer_131, !noalias !2
        %i_7_16_92_276_5069_pointer_132 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_127, i64 0, i32 4
        %i_7_16_92_276_5069 = load %Reference, ptr %i_7_16_92_276_5069_pointer_132, !noalias !2
        %s_4_154_5218_pointer_133 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_127, i64 0, i32 5
        %s_4_154_5218 = load %Reference, ptr %s_4_154_5218_pointer_133, !noalias !2
        
        %pureApp_5420 = call ccc i64 @infixAdd_96(i64 %v_r_2578_13_6_336_5092, i64 %a_9_4_42_120_304_5012)
        
        
        %stackPointer_165 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %tmp_5386_pointer_166 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_165, i64 0, i32 0
        store i64 %tmp_5386, ptr %tmp_5386_pointer_166, !noalias !2
        %j_9_18_94_278_5023_pointer_167 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_165, i64 0, i32 1
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_167, !noalias !2
        %p_4_73_250_5097_pointer_168 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_165, i64 0, i32 2
        store %Prompt %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_168, !noalias !2
        %i_7_16_92_276_5069_pointer_169 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_165, i64 0, i32 3
        store %Reference %i_7_16_92_276_5069, ptr %i_7_16_92_276_5069_pointer_169, !noalias !2
        %s_4_154_5218_pointer_170 = getelementptr <{i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_165, i64 0, i32 4
        store %Reference %s_4_154_5218, ptr %s_4_154_5218_pointer_170, !noalias !2
        %returnAddress_pointer_171 = getelementptr <{<{i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_165, i64 0, i32 1, i32 0
        %sharer_pointer_172 = getelementptr <{<{i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_165, i64 0, i32 1, i32 1
        %eraser_pointer_173 = getelementptr <{<{i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_165, i64 0, i32 1, i32 2
        store ptr @returnAddress_134, ptr %returnAddress_pointer_171, !noalias !2
        store ptr @sharer_146, ptr %sharer_pointer_172, !noalias !2
        store ptr @eraser_158, ptr %eraser_pointer_173, !noalias !2
        
        %s_4_154_5218pointer_174 = call ccc ptr @getVarPointer(%Reference %s_4_154_5218, %Stack %stack)
        %s_4_154_5218_old_175 = load i64, ptr %s_4_154_5218pointer_174, !noalias !2
        store i64 %pureApp_5420, ptr %s_4_154_5218pointer_174, !noalias !2
        
        %put_5422_temporary_176 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5422 = insertvalue %Pos %put_5422_temporary_176, %Object null, 1
        
        %stackPointer_178 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_179 = getelementptr %FrameHeader, %StackPointer %stackPointer_178, i64 0, i32 0
        %returnAddress_177 = load %ReturnAddress, ptr %returnAddress_pointer_179, !noalias !2
        musttail call tailcc void %returnAddress_177(%Pos %put_5422, %Stack %stack)
        ret void
}



define ccc void @sharer_186(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_187 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %a_9_4_42_120_304_5012_180_pointer_188 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 0
        %a_9_4_42_120_304_5012_180 = load i64, ptr %a_9_4_42_120_304_5012_180_pointer_188, !noalias !2
        %tmp_5386_181_pointer_189 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 1
        %tmp_5386_181 = load i64, ptr %tmp_5386_181_pointer_189, !noalias !2
        %j_9_18_94_278_5023_182_pointer_190 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 2
        %j_9_18_94_278_5023_182 = load %Reference, ptr %j_9_18_94_278_5023_182_pointer_190, !noalias !2
        %p_4_73_250_5097_183_pointer_191 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 3
        %p_4_73_250_5097_183 = load %Prompt, ptr %p_4_73_250_5097_183_pointer_191, !noalias !2
        %i_7_16_92_276_5069_184_pointer_192 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 4
        %i_7_16_92_276_5069_184 = load %Reference, ptr %i_7_16_92_276_5069_184_pointer_192, !noalias !2
        %s_4_154_5218_185_pointer_193 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_187, i64 0, i32 5
        %s_4_154_5218_185 = load %Reference, ptr %s_4_154_5218_185_pointer_193, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_187)
        ret void
}



define ccc void @eraser_200(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_201 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %a_9_4_42_120_304_5012_194_pointer_202 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_201, i64 0, i32 0
        %a_9_4_42_120_304_5012_194 = load i64, ptr %a_9_4_42_120_304_5012_194_pointer_202, !noalias !2
        %tmp_5386_195_pointer_203 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_201, i64 0, i32 1
        %tmp_5386_195 = load i64, ptr %tmp_5386_195_pointer_203, !noalias !2
        %j_9_18_94_278_5023_196_pointer_204 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_201, i64 0, i32 2
        %j_9_18_94_278_5023_196 = load %Reference, ptr %j_9_18_94_278_5023_196_pointer_204, !noalias !2
        %p_4_73_250_5097_197_pointer_205 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_201, i64 0, i32 3
        %p_4_73_250_5097_197 = load %Prompt, ptr %p_4_73_250_5097_197_pointer_205, !noalias !2
        %i_7_16_92_276_5069_198_pointer_206 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_201, i64 0, i32 4
        %i_7_16_92_276_5069_198 = load %Reference, ptr %i_7_16_92_276_5069_198_pointer_206, !noalias !2
        %s_4_154_5218_199_pointer_207 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_201, i64 0, i32 5
        %s_4_154_5218_199 = load %Reference, ptr %s_4_154_5218_199_pointer_207, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_201)
        ret void
}



define tailcc void @returnAddress_105(i64 %c_10_5_62_142_326_5052, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_106 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %a_9_4_42_120_304_5012_pointer_107 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_106, i64 0, i32 0
        %a_9_4_42_120_304_5012 = load i64, ptr %a_9_4_42_120_304_5012_pointer_107, !noalias !2
        %tmp_5386_pointer_108 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_106, i64 0, i32 1
        %tmp_5386 = load i64, ptr %tmp_5386_pointer_108, !noalias !2
        %j_9_18_94_278_5023_pointer_109 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_106, i64 0, i32 2
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_109, !noalias !2
        %p_4_73_250_5097_pointer_110 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_106, i64 0, i32 3
        %p_4_73_250_5097 = load %Prompt, ptr %p_4_73_250_5097_pointer_110, !noalias !2
        %i_7_16_92_276_5069_pointer_111 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_106, i64 0, i32 4
        %i_7_16_92_276_5069 = load %Reference, ptr %i_7_16_92_276_5069_pointer_111, !noalias !2
        %s_4_154_5218_pointer_112 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_106, i64 0, i32 5
        %s_4_154_5218 = load %Reference, ptr %s_4_154_5218_pointer_112, !noalias !2
        
        %longLiteral_5415 = add i64 36, 0
        
        %pureApp_5414 = call ccc %Pos @infixEq_72(i64 %c_10_5_62_142_326_5052, i64 %longLiteral_5415)
        
        
        
        %tag_113 = extractvalue %Pos %pureApp_5414, 0
        %fields_114 = extractvalue %Pos %pureApp_5414, 1
        switch i64 %tag_113, label %label_115 [i64 0, label %label_224 i64 1, label %label_225]
    
    label_115:
        
        ret void
    
    label_118:
        
        ret void
    
    label_125:
        
        %pair_119 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_73_250_5097)
        %k_7_2_150_341_5418 = extractvalue <{%Resumption, %Stack}> %pair_119, 0
        %stack_120 = extractvalue <{%Resumption, %Stack}> %pair_119, 1
        call ccc void @eraseResumption(%Resumption %k_7_2_150_341_5418)
        
        %unitLiteral_5419_temporary_121 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5419 = insertvalue %Pos %unitLiteral_5419_temporary_121, %Object null, 1
        
        %stackPointer_123 = call ccc %StackPointer @stackDeallocate(%Stack %stack_120, i64 24)
        %returnAddress_pointer_124 = getelementptr %FrameHeader, %StackPointer %stackPointer_123, i64 0, i32 0
        %returnAddress_122 = load %ReturnAddress, ptr %returnAddress_pointer_124, !noalias !2
        musttail call tailcc void %returnAddress_122(%Pos %unitLiteral_5419, %Stack %stack_120)
        ret void
    
    label_223:
        %stackPointer_208 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %a_9_4_42_120_304_5012_pointer_209 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_208, i64 0, i32 0
        store i64 %a_9_4_42_120_304_5012, ptr %a_9_4_42_120_304_5012_pointer_209, !noalias !2
        %tmp_5386_pointer_210 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_208, i64 0, i32 1
        store i64 %tmp_5386, ptr %tmp_5386_pointer_210, !noalias !2
        %j_9_18_94_278_5023_pointer_211 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_208, i64 0, i32 2
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_211, !noalias !2
        %p_4_73_250_5097_pointer_212 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_208, i64 0, i32 3
        store %Prompt %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_212, !noalias !2
        %i_7_16_92_276_5069_pointer_213 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_208, i64 0, i32 4
        store %Reference %i_7_16_92_276_5069, ptr %i_7_16_92_276_5069_pointer_213, !noalias !2
        %s_4_154_5218_pointer_214 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_208, i64 0, i32 5
        store %Reference %s_4_154_5218, ptr %s_4_154_5218_pointer_214, !noalias !2
        %returnAddress_pointer_215 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_208, i64 0, i32 1, i32 0
        %sharer_pointer_216 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_208, i64 0, i32 1, i32 1
        %eraser_pointer_217 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_208, i64 0, i32 1, i32 2
        store ptr @returnAddress_126, ptr %returnAddress_pointer_215, !noalias !2
        store ptr @sharer_186, ptr %sharer_pointer_216, !noalias !2
        store ptr @eraser_200, ptr %eraser_pointer_217, !noalias !2
        
        %get_5423_pointer_218 = call ccc ptr @getVarPointer(%Reference %s_4_154_5218, %Stack %stack)
        %s_4_154_5218_old_219 = load i64, ptr %get_5423_pointer_218, !noalias !2
        %get_5423 = load i64, ptr %get_5423_pointer_218, !noalias !2
        
        %stackPointer_221 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_222 = getelementptr %FrameHeader, %StackPointer %stackPointer_221, i64 0, i32 0
        %returnAddress_220 = load %ReturnAddress, ptr %returnAddress_pointer_222, !noalias !2
        musttail call tailcc void %returnAddress_220(i64 %get_5423, %Stack %stack)
        ret void
    
    label_224:
        
        %longLiteral_5417 = add i64 10, 0
        
        %pureApp_5416 = call ccc %Pos @infixEq_72(i64 %c_10_5_62_142_326_5052, i64 %longLiteral_5417)
        
        
        
        %tag_116 = extractvalue %Pos %pureApp_5416, 0
        %fields_117 = extractvalue %Pos %pureApp_5416, 1
        switch i64 %tag_116, label %label_118 [i64 0, label %label_125 i64 1, label %label_223]
    
    label_225:
        
        %longLiteral_5425 = add i64 1, 0
        
        %pureApp_5424 = call ccc i64 @infixAdd_96(i64 %a_9_4_42_120_304_5012, i64 %longLiteral_5425)
        
        
        
        
        
        musttail call tailcc void @parse_worker_8_3_41_119_303_5122(i64 %pureApp_5424, i64 %tmp_5386, %Reference %j_9_18_94_278_5023, %Prompt %p_4_73_250_5097, %Reference %i_7_16_92_276_5069, %Reference %s_4_154_5218, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_261(%Pos %__30_18_60_140_324_5272, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %__30_18_60_140_324_5272)
        
        %longLiteral_5430 = add i64 36, 0
        
        
        
        %stackPointer_263 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_264 = getelementptr %FrameHeader, %StackPointer %stackPointer_263, i64 0, i32 0
        %returnAddress_262 = load %ReturnAddress, ptr %returnAddress_pointer_264, !noalias !2
        musttail call tailcc void %returnAddress_262(i64 %longLiteral_5430, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_258(i64 %v_r_2604_28_16_58_138_322_4998, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_259 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %j_9_18_94_278_5023_pointer_260 = getelementptr <{%Reference}>, %StackPointer %stackPointer_259, i64 0, i32 0
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_260, !noalias !2
        
        %longLiteral_5429 = add i64 1, 0
        
        %pureApp_5428 = call ccc i64 @infixSub_105(i64 %v_r_2604_28_16_58_138_322_4998, i64 %longLiteral_5429)
        
        
        %stackPointer_265 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_266 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_265, i64 0, i32 1, i32 0
        %sharer_pointer_267 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_265, i64 0, i32 1, i32 1
        %eraser_pointer_268 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_265, i64 0, i32 1, i32 2
        store ptr @returnAddress_261, ptr %returnAddress_pointer_266, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_267, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_268, !noalias !2
        
        %j_9_18_94_278_5023pointer_269 = call ccc ptr @getVarPointer(%Reference %j_9_18_94_278_5023, %Stack %stack)
        %j_9_18_94_278_5023_old_270 = load i64, ptr %j_9_18_94_278_5023pointer_269, !noalias !2
        store i64 %pureApp_5428, ptr %j_9_18_94_278_5023pointer_269, !noalias !2
        
        %put_5431_temporary_271 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5431 = insertvalue %Pos %put_5431_temporary_271, %Object null, 1
        
        %stackPointer_273 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_274 = getelementptr %FrameHeader, %StackPointer %stackPointer_273, i64 0, i32 0
        %returnAddress_272 = load %ReturnAddress, ptr %returnAddress_pointer_274, !noalias !2
        musttail call tailcc void %returnAddress_272(%Pos %put_5431, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_299(%Pos %__26_14_56_136_320_5271, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %__26_14_56_136_320_5271)
        
        %longLiteral_5435 = add i64 10, 0
        
        
        
        %stackPointer_301 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_302 = getelementptr %FrameHeader, %StackPointer %stackPointer_301, i64 0, i32 0
        %returnAddress_300 = load %ReturnAddress, ptr %returnAddress_pointer_302, !noalias !2
        musttail call tailcc void %returnAddress_300(i64 %longLiteral_5435, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_296(i64 %v_r_2600_25_13_55_135_319_5050, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_297 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %j_9_18_94_278_5023_pointer_298 = getelementptr <{%Reference}>, %StackPointer %stackPointer_297, i64 0, i32 0
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_298, !noalias !2
        %stackPointer_303 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_304 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_303, i64 0, i32 1, i32 0
        %sharer_pointer_305 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_303, i64 0, i32 1, i32 1
        %eraser_pointer_306 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_303, i64 0, i32 1, i32 2
        store ptr @returnAddress_299, ptr %returnAddress_pointer_304, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_305, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_306, !noalias !2
        
        %j_9_18_94_278_5023pointer_307 = call ccc ptr @getVarPointer(%Reference %j_9_18_94_278_5023, %Stack %stack)
        %j_9_18_94_278_5023_old_308 = load i64, ptr %j_9_18_94_278_5023pointer_307, !noalias !2
        store i64 %v_r_2600_25_13_55_135_319_5050, ptr %j_9_18_94_278_5023pointer_307, !noalias !2
        
        %put_5436_temporary_309 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5436 = insertvalue %Pos %put_5436_temporary_309, %Object null, 1
        
        %stackPointer_311 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_312 = getelementptr %FrameHeader, %StackPointer %stackPointer_311, i64 0, i32 0
        %returnAddress_310 = load %ReturnAddress, ptr %returnAddress_pointer_312, !noalias !2
        musttail call tailcc void %returnAddress_310(%Pos %put_5436, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_292(%Pos %__24_12_54_134_318_5270, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_293 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %j_9_18_94_278_5023_pointer_294 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 0
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_294, !noalias !2
        %i_7_16_92_276_5069_pointer_295 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_293, i64 0, i32 1
        %i_7_16_92_276_5069 = load %Reference, ptr %i_7_16_92_276_5069_pointer_295, !noalias !2
        call ccc void @erasePositive(%Pos %__24_12_54_134_318_5270)
        %stackPointer_315 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %j_9_18_94_278_5023_pointer_316 = getelementptr <{%Reference}>, %StackPointer %stackPointer_315, i64 0, i32 0
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_316, !noalias !2
        %returnAddress_pointer_317 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_315, i64 0, i32 1, i32 0
        %sharer_pointer_318 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_315, i64 0, i32 1, i32 1
        %eraser_pointer_319 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_315, i64 0, i32 1, i32 2
        store ptr @returnAddress_296, ptr %returnAddress_pointer_317, !noalias !2
        store ptr @sharer_43, ptr %sharer_pointer_318, !noalias !2
        store ptr @eraser_47, ptr %eraser_pointer_319, !noalias !2
        
        %get_5437_pointer_320 = call ccc ptr @getVarPointer(%Reference %i_7_16_92_276_5069, %Stack %stack)
        %i_7_16_92_276_5069_old_321 = load i64, ptr %get_5437_pointer_320, !noalias !2
        %get_5437 = load i64, ptr %get_5437_pointer_320, !noalias !2
        
        %stackPointer_323 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_324 = getelementptr %FrameHeader, %StackPointer %stackPointer_323, i64 0, i32 0
        %returnAddress_322 = load %ReturnAddress, ptr %returnAddress_pointer_324, !noalias !2
        musttail call tailcc void %returnAddress_322(i64 %get_5437, %Stack %stack)
        ret void
}



define ccc void @sharer_327(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_328 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %j_9_18_94_278_5023_325_pointer_329 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_328, i64 0, i32 0
        %j_9_18_94_278_5023_325 = load %Reference, ptr %j_9_18_94_278_5023_325_pointer_329, !noalias !2
        %i_7_16_92_276_5069_326_pointer_330 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_328, i64 0, i32 1
        %i_7_16_92_276_5069_326 = load %Reference, ptr %i_7_16_92_276_5069_326_pointer_330, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_328)
        ret void
}



define ccc void @eraser_333(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_334 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %j_9_18_94_278_5023_331_pointer_335 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 0
        %j_9_18_94_278_5023_331 = load %Reference, ptr %j_9_18_94_278_5023_331_pointer_335, !noalias !2
        %i_7_16_92_276_5069_332_pointer_336 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_334, i64 0, i32 1
        %i_7_16_92_276_5069_332 = load %Reference, ptr %i_7_16_92_276_5069_332_pointer_336, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_334)
        ret void
}



define tailcc void @returnAddress_288(i64 %v_r_2598_22_10_52_132_316_5172, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_289 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %j_9_18_94_278_5023_pointer_290 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_289, i64 0, i32 0
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_290, !noalias !2
        %i_7_16_92_276_5069_pointer_291 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_289, i64 0, i32 1
        %i_7_16_92_276_5069 = load %Reference, ptr %i_7_16_92_276_5069_pointer_291, !noalias !2
        
        %longLiteral_5434 = add i64 1, 0
        
        %pureApp_5433 = call ccc i64 @infixAdd_96(i64 %v_r_2598_22_10_52_132_316_5172, i64 %longLiteral_5434)
        
        
        %stackPointer_337 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %j_9_18_94_278_5023_pointer_338 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_337, i64 0, i32 0
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_338, !noalias !2
        %i_7_16_92_276_5069_pointer_339 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_337, i64 0, i32 1
        store %Reference %i_7_16_92_276_5069, ptr %i_7_16_92_276_5069_pointer_339, !noalias !2
        %returnAddress_pointer_340 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_337, i64 0, i32 1, i32 0
        %sharer_pointer_341 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_337, i64 0, i32 1, i32 1
        %eraser_pointer_342 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_337, i64 0, i32 1, i32 2
        store ptr @returnAddress_292, ptr %returnAddress_pointer_340, !noalias !2
        store ptr @sharer_327, ptr %sharer_pointer_341, !noalias !2
        store ptr @eraser_333, ptr %eraser_pointer_342, !noalias !2
        
        %i_7_16_92_276_5069pointer_343 = call ccc ptr @getVarPointer(%Reference %i_7_16_92_276_5069, %Stack %stack)
        %i_7_16_92_276_5069_old_344 = load i64, ptr %i_7_16_92_276_5069pointer_343, !noalias !2
        store i64 %pureApp_5433, ptr %i_7_16_92_276_5069pointer_343, !noalias !2
        
        %put_5438_temporary_345 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5438 = insertvalue %Pos %put_5438_temporary_345, %Object null, 1
        
        %stackPointer_347 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_348 = getelementptr %FrameHeader, %StackPointer %stackPointer_347, i64 0, i32 0
        %returnAddress_346 = load %ReturnAddress, ptr %returnAddress_pointer_348, !noalias !2
        musttail call tailcc void %returnAddress_346(%Pos %put_5438, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_251(i64 %v_r_2597_20_8_50_130_314_5209, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_252 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %j_9_18_94_278_5023_pointer_253 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_252, i64 0, i32 0
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_253, !noalias !2
        %i_7_16_92_276_5069_pointer_254 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_252, i64 0, i32 1
        %i_7_16_92_276_5069 = load %Reference, ptr %i_7_16_92_276_5069_pointer_254, !noalias !2
        
        %longLiteral_5427 = add i64 0, 0
        
        %pureApp_5426 = call ccc %Pos @infixEq_72(i64 %v_r_2597_20_8_50_130_314_5209, i64 %longLiteral_5427)
        
        
        
        %tag_255 = extractvalue %Pos %pureApp_5426, 0
        %fields_256 = extractvalue %Pos %pureApp_5426, 1
        switch i64 %tag_255, label %label_257 [i64 0, label %label_287 i64 1, label %label_364]
    
    label_257:
        
        ret void
    
    label_287:
        %stackPointer_277 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %j_9_18_94_278_5023_pointer_278 = getelementptr <{%Reference}>, %StackPointer %stackPointer_277, i64 0, i32 0
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_278, !noalias !2
        %returnAddress_pointer_279 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_277, i64 0, i32 1, i32 0
        %sharer_pointer_280 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_277, i64 0, i32 1, i32 1
        %eraser_pointer_281 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_277, i64 0, i32 1, i32 2
        store ptr @returnAddress_258, ptr %returnAddress_pointer_279, !noalias !2
        store ptr @sharer_43, ptr %sharer_pointer_280, !noalias !2
        store ptr @eraser_47, ptr %eraser_pointer_281, !noalias !2
        
        %get_5432_pointer_282 = call ccc ptr @getVarPointer(%Reference %j_9_18_94_278_5023, %Stack %stack)
        %j_9_18_94_278_5023_old_283 = load i64, ptr %get_5432_pointer_282, !noalias !2
        %get_5432 = load i64, ptr %get_5432_pointer_282, !noalias !2
        
        %stackPointer_285 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_286 = getelementptr %FrameHeader, %StackPointer %stackPointer_285, i64 0, i32 0
        %returnAddress_284 = load %ReturnAddress, ptr %returnAddress_pointer_286, !noalias !2
        musttail call tailcc void %returnAddress_284(i64 %get_5432, %Stack %stack)
        ret void
    
    label_364:
        %stackPointer_353 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %j_9_18_94_278_5023_pointer_354 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_353, i64 0, i32 0
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_354, !noalias !2
        %i_7_16_92_276_5069_pointer_355 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_353, i64 0, i32 1
        store %Reference %i_7_16_92_276_5069, ptr %i_7_16_92_276_5069_pointer_355, !noalias !2
        %returnAddress_pointer_356 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_353, i64 0, i32 1, i32 0
        %sharer_pointer_357 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_353, i64 0, i32 1, i32 1
        %eraser_pointer_358 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_353, i64 0, i32 1, i32 2
        store ptr @returnAddress_288, ptr %returnAddress_pointer_356, !noalias !2
        store ptr @sharer_327, ptr %sharer_pointer_357, !noalias !2
        store ptr @eraser_333, ptr %eraser_pointer_358, !noalias !2
        
        %get_5439_pointer_359 = call ccc ptr @getVarPointer(%Reference %i_7_16_92_276_5069, %Stack %stack)
        %i_7_16_92_276_5069_old_360 = load i64, ptr %get_5439_pointer_359, !noalias !2
        %get_5439 = load i64, ptr %get_5439_pointer_359, !noalias !2
        
        %stackPointer_362 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_363 = getelementptr %FrameHeader, %StackPointer %stackPointer_362, i64 0, i32 0
        %returnAddress_361 = load %ReturnAddress, ptr %returnAddress_pointer_363, !noalias !2
        musttail call tailcc void %returnAddress_361(i64 %get_5439, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_381(%Pos %v_r_2595_19_7_49_129_313_5118, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %tag_382 = extractvalue %Pos %v_r_2595_19_7_49_129_313_5118, 0
        %fields_383 = extractvalue %Pos %v_r_2595_19_7_49_129_313_5118, 1
        switch i64 %tag_382, label %label_384 []
    
    label_384:
        
        ret void
}



define tailcc void @returnAddress_97(i64 %v_r_2594_17_5_47_125_309_5163, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_98 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %a_9_4_42_120_304_5012_pointer_99 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 0
        %a_9_4_42_120_304_5012 = load i64, ptr %a_9_4_42_120_304_5012_pointer_99, !noalias !2
        %tmp_5386_pointer_100 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 1
        %tmp_5386 = load i64, ptr %tmp_5386_pointer_100, !noalias !2
        %j_9_18_94_278_5023_pointer_101 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 2
        %j_9_18_94_278_5023 = load %Reference, ptr %j_9_18_94_278_5023_pointer_101, !noalias !2
        %p_4_73_250_5097_pointer_102 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 3
        %p_4_73_250_5097 = load %Prompt, ptr %p_4_73_250_5097_pointer_102, !noalias !2
        %i_7_16_92_276_5069_pointer_103 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 4
        %i_7_16_92_276_5069 = load %Reference, ptr %i_7_16_92_276_5069_pointer_103, !noalias !2
        %s_4_154_5218_pointer_104 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_98, i64 0, i32 5
        %s_4_154_5218 = load %Reference, ptr %s_4_154_5218_pointer_104, !noalias !2
        
        %pureApp_5413 = call ccc %Pos @infixGt_184(i64 %v_r_2594_17_5_47_125_309_5163, i64 %tmp_5386)
        
        
        %stackPointer_238 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %a_9_4_42_120_304_5012_pointer_239 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_238, i64 0, i32 0
        store i64 %a_9_4_42_120_304_5012, ptr %a_9_4_42_120_304_5012_pointer_239, !noalias !2
        %tmp_5386_pointer_240 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_238, i64 0, i32 1
        store i64 %tmp_5386, ptr %tmp_5386_pointer_240, !noalias !2
        %j_9_18_94_278_5023_pointer_241 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_238, i64 0, i32 2
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_241, !noalias !2
        %p_4_73_250_5097_pointer_242 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_238, i64 0, i32 3
        store %Prompt %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_242, !noalias !2
        %i_7_16_92_276_5069_pointer_243 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_238, i64 0, i32 4
        store %Reference %i_7_16_92_276_5069, ptr %i_7_16_92_276_5069_pointer_243, !noalias !2
        %s_4_154_5218_pointer_244 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_238, i64 0, i32 5
        store %Reference %s_4_154_5218, ptr %s_4_154_5218_pointer_244, !noalias !2
        %returnAddress_pointer_245 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_238, i64 0, i32 1, i32 0
        %sharer_pointer_246 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_238, i64 0, i32 1, i32 1
        %eraser_pointer_247 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_238, i64 0, i32 1, i32 2
        store ptr @returnAddress_105, ptr %returnAddress_pointer_245, !noalias !2
        store ptr @sharer_186, ptr %sharer_pointer_246, !noalias !2
        store ptr @eraser_200, ptr %eraser_pointer_247, !noalias !2
        
        %tag_248 = extractvalue %Pos %pureApp_5413, 0
        %fields_249 = extractvalue %Pos %pureApp_5413, 1
        switch i64 %tag_248, label %label_250 [i64 0, label %label_380 i64 1, label %label_395]
    
    label_250:
        
        ret void
    
    label_380:
        %stackPointer_369 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %j_9_18_94_278_5023_pointer_370 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_369, i64 0, i32 0
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_370, !noalias !2
        %i_7_16_92_276_5069_pointer_371 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_369, i64 0, i32 1
        store %Reference %i_7_16_92_276_5069, ptr %i_7_16_92_276_5069_pointer_371, !noalias !2
        %returnAddress_pointer_372 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_369, i64 0, i32 1, i32 0
        %sharer_pointer_373 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_369, i64 0, i32 1, i32 1
        %eraser_pointer_374 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_369, i64 0, i32 1, i32 2
        store ptr @returnAddress_251, ptr %returnAddress_pointer_372, !noalias !2
        store ptr @sharer_327, ptr %sharer_pointer_373, !noalias !2
        store ptr @eraser_333, ptr %eraser_pointer_374, !noalias !2
        
        %get_5440_pointer_375 = call ccc ptr @getVarPointer(%Reference %j_9_18_94_278_5023, %Stack %stack)
        %j_9_18_94_278_5023_old_376 = load i64, ptr %get_5440_pointer_375, !noalias !2
        %get_5440 = load i64, ptr %get_5440_pointer_375, !noalias !2
        
        %stackPointer_378 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_379 = getelementptr %FrameHeader, %StackPointer %stackPointer_378, i64 0, i32 0
        %returnAddress_377 = load %ReturnAddress, ptr %returnAddress_pointer_379, !noalias !2
        musttail call tailcc void %returnAddress_377(i64 %get_5440, %Stack %stack)
        ret void
    
    label_395:
        %stackPointer_385 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_386 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 0
        %sharer_pointer_387 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 1
        %eraser_pointer_388 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 2
        store ptr @returnAddress_381, ptr %returnAddress_pointer_386, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_387, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_388, !noalias !2
        
        %pair_389 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_73_250_5097)
        %k_7_2_128_312_5441 = extractvalue <{%Resumption, %Stack}> %pair_389, 0
        %stack_390 = extractvalue <{%Resumption, %Stack}> %pair_389, 1
        call ccc void @eraseResumption(%Resumption %k_7_2_128_312_5441)
        
        %unitLiteral_5442_temporary_391 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5442 = insertvalue %Pos %unitLiteral_5442_temporary_391, %Object null, 1
        
        %stackPointer_393 = call ccc %StackPointer @stackDeallocate(%Stack %stack_390, i64 24)
        %returnAddress_pointer_394 = getelementptr %FrameHeader, %StackPointer %stackPointer_393, i64 0, i32 0
        %returnAddress_392 = load %ReturnAddress, ptr %returnAddress_pointer_394, !noalias !2
        musttail call tailcc void %returnAddress_392(%Pos %unitLiteral_5442, %Stack %stack_390)
        ret void
}



define tailcc void @parse_worker_8_3_41_119_303_5122(i64 %a_9_4_42_120_304_5012, i64 %tmp_5386, %Reference %j_9_18_94_278_5023, %Prompt %p_4_73_250_5097, %Reference %i_7_16_92_276_5069, %Reference %s_4_154_5218, %Stack %stack) {
        
    entry:
        
        %stackPointer_408 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %a_9_4_42_120_304_5012_pointer_409 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_408, i64 0, i32 0
        store i64 %a_9_4_42_120_304_5012, ptr %a_9_4_42_120_304_5012_pointer_409, !noalias !2
        %tmp_5386_pointer_410 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_408, i64 0, i32 1
        store i64 %tmp_5386, ptr %tmp_5386_pointer_410, !noalias !2
        %j_9_18_94_278_5023_pointer_411 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_408, i64 0, i32 2
        store %Reference %j_9_18_94_278_5023, ptr %j_9_18_94_278_5023_pointer_411, !noalias !2
        %p_4_73_250_5097_pointer_412 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_408, i64 0, i32 3
        store %Prompt %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_412, !noalias !2
        %i_7_16_92_276_5069_pointer_413 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_408, i64 0, i32 4
        store %Reference %i_7_16_92_276_5069, ptr %i_7_16_92_276_5069_pointer_413, !noalias !2
        %s_4_154_5218_pointer_414 = getelementptr <{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %StackPointer %stackPointer_408, i64 0, i32 5
        store %Reference %s_4_154_5218, ptr %s_4_154_5218_pointer_414, !noalias !2
        %returnAddress_pointer_415 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_408, i64 0, i32 1, i32 0
        %sharer_pointer_416 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_408, i64 0, i32 1, i32 1
        %eraser_pointer_417 = getelementptr <{<{i64, i64, %Reference, %Prompt, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_408, i64 0, i32 1, i32 2
        store ptr @returnAddress_97, ptr %returnAddress_pointer_415, !noalias !2
        store ptr @sharer_186, ptr %sharer_pointer_416, !noalias !2
        store ptr @eraser_200, ptr %eraser_pointer_417, !noalias !2
        
        %get_5443_pointer_418 = call ccc ptr @getVarPointer(%Reference %i_7_16_92_276_5069, %Stack %stack)
        %i_7_16_92_276_5069_old_419 = load i64, ptr %get_5443_pointer_418, !noalias !2
        %get_5443 = load i64, ptr %get_5443_pointer_418, !noalias !2
        
        %stackPointer_421 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_422 = getelementptr %FrameHeader, %StackPointer %stackPointer_421, i64 0, i32 0
        %returnAddress_420 = load %ReturnAddress, ptr %returnAddress_pointer_422, !noalias !2
        musttail call tailcc void %returnAddress_420(i64 %get_5443, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3544_3608, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5402 = call ccc i64 @unboxInt_303(%Pos %v_coe_3544_3608)
        
        
        
        %longLiteral_5403 = add i64 0, 0
        
        
        %stackPointer_10 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 0
        %sharer_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 1
        %eraser_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_11, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_12, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_13, !noalias !2
        %s_4_154_5218 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_29 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2575_3_153_5175_pointer_30 = getelementptr <{i64}>, %StackPointer %stackPointer_29, i64 0, i32 0
        store i64 %longLiteral_5403, ptr %v_r_2575_3_153_5175_pointer_30, !noalias !2
        %returnAddress_pointer_31 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 0
        %sharer_pointer_32 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 1
        %eraser_pointer_33 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 2
        store ptr @returnAddress_14, ptr %returnAddress_pointer_31, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_32, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_33, !noalias !2
        %stackPointer_50 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %s_4_154_5218_pointer_51 = getelementptr <{%Reference}>, %StackPointer %stackPointer_50, i64 0, i32 0
        store %Reference %s_4_154_5218, ptr %s_4_154_5218_pointer_51, !noalias !2
        %returnAddress_pointer_52 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 0
        %sharer_pointer_53 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 1
        %eraser_pointer_54 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_52, !noalias !2
        store ptr @sharer_43, ptr %sharer_pointer_53, !noalias !2
        store ptr @eraser_47, ptr %eraser_pointer_54, !noalias !2
        
        %stack_55 = call ccc %Stack @reset(%Stack %stack)
        %p_4_73_250_5097 = call ccc %Prompt @currentPrompt(%Stack %stack_55)
        %stackPointer_65 = call ccc %StackPointer @stackAllocate(%Stack %stack_55, i64 24)
        %returnAddress_pointer_66 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_65, i64 0, i32 1, i32 0
        %sharer_pointer_67 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_65, i64 0, i32 1, i32 1
        %eraser_pointer_68 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_65, i64 0, i32 1, i32 2
        store ptr @returnAddress_56, ptr %returnAddress_pointer_66, !noalias !2
        store ptr @sharer_61, ptr %sharer_pointer_67, !noalias !2
        store ptr @eraser_63, ptr %eraser_pointer_68, !noalias !2
        
        %longLiteral_5409 = add i64 0, 0
        
        
        %i_7_16_92_276_5069 = call ccc %Reference @newReference(%Stack %stack_55)
        %stackPointer_78 = call ccc %StackPointer @stackAllocate(%Stack %stack_55, i64 32)
        %v_r_2591_6_15_91_275_5158_pointer_79 = getelementptr <{i64}>, %StackPointer %stackPointer_78, i64 0, i32 0
        store i64 %longLiteral_5409, ptr %v_r_2591_6_15_91_275_5158_pointer_79, !noalias !2
        %returnAddress_pointer_80 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_78, i64 0, i32 1, i32 0
        %sharer_pointer_81 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_78, i64 0, i32 1, i32 1
        %eraser_pointer_82 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_78, i64 0, i32 1, i32 2
        store ptr @returnAddress_69, ptr %returnAddress_pointer_80, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_81, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_82, !noalias !2
        
        %longLiteral_5411 = add i64 0, 0
        
        
        %j_9_18_94_278_5023 = call ccc %Reference @newReference(%Stack %stack_55)
        %stackPointer_92 = call ccc %StackPointer @stackAllocate(%Stack %stack_55, i64 32)
        %v_r_2592_8_17_93_277_5174_pointer_93 = getelementptr <{i64}>, %StackPointer %stackPointer_92, i64 0, i32 0
        store i64 %longLiteral_5411, ptr %v_r_2592_8_17_93_277_5174_pointer_93, !noalias !2
        %returnAddress_pointer_94 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_92, i64 0, i32 1, i32 0
        %sharer_pointer_95 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_92, i64 0, i32 1, i32 1
        %eraser_pointer_96 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_92, i64 0, i32 1, i32 2
        store ptr @returnAddress_83, ptr %returnAddress_pointer_94, !noalias !2
        store ptr @sharer_22, ptr %sharer_pointer_95, !noalias !2
        store ptr @eraser_26, ptr %eraser_pointer_96, !noalias !2
        
        %longLiteral_5444 = add i64 0, 0
        
        
        
        musttail call tailcc void @parse_worker_8_3_41_119_303_5122(i64 %longLiteral_5444, i64 %pureApp_5402, %Reference %j_9_18_94_278_5023, %Prompt %p_4_73_250_5097, %Reference %i_7_16_92_276_5069, %Reference %s_4_154_5218, %Stack %stack_55)
        ret void
}



define tailcc void @returnAddress_428(%Pos %returned_5445, %Stack %stack) {
        
    entry:
        
        %stack_429 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_431 = call ccc %StackPointer @stackDeallocate(%Stack %stack_429, i64 24)
        %returnAddress_pointer_432 = getelementptr %FrameHeader, %StackPointer %stackPointer_431, i64 0, i32 0
        %returnAddress_430 = load %ReturnAddress, ptr %returnAddress_pointer_432, !noalias !2
        musttail call tailcc void %returnAddress_430(%Pos %returned_5445, %Stack %stack_429)
        ret void
}



define ccc void @eraser_444(%Environment %environment) {
        
    entry:
        
        %tmp_5346_442_pointer_445 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5346_442 = load %Pos, ptr %tmp_5346_442_pointer_445, !noalias !2
        %acc_3_3_5_169_4838_443_pointer_446 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4838_443 = load %Pos, ptr %acc_3_3_5_169_4838_443_pointer_446, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5346_442)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4838_443)
        ret void
}



define tailcc void @toList_1_1_3_167_4680(i64 %start_2_2_4_168_4831, %Pos %acc_3_3_5_169_4838, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5447 = add i64 1, 0
        
        %pureApp_5446 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4831, i64 %longLiteral_5447)
        
        
        
        %tag_437 = extractvalue %Pos %pureApp_5446, 0
        %fields_438 = extractvalue %Pos %pureApp_5446, 1
        switch i64 %tag_437, label %label_439 [i64 0, label %label_450 i64 1, label %label_454]
    
    label_439:
        
        ret void
    
    label_450:
        
        %pureApp_5448 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4831)
        
        
        
        %longLiteral_5450 = add i64 1, 0
        
        %pureApp_5449 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4831, i64 %longLiteral_5450)
        
        
        
        %fields_440 = call ccc %Object @newObject(ptr @eraser_444, i64 32)
        %environment_441 = call ccc %Environment @objectEnvironment(%Object %fields_440)
        %tmp_5346_pointer_447 = getelementptr <{%Pos, %Pos}>, %Environment %environment_441, i64 0, i32 0
        store %Pos %pureApp_5448, ptr %tmp_5346_pointer_447, !noalias !2
        %acc_3_3_5_169_4838_pointer_448 = getelementptr <{%Pos, %Pos}>, %Environment %environment_441, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4838, ptr %acc_3_3_5_169_4838_pointer_448, !noalias !2
        %make_5451_temporary_449 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5451 = insertvalue %Pos %make_5451_temporary_449, %Object %fields_440, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4680(i64 %pureApp_5449, %Pos %make_5451, %Stack %stack)
        ret void
    
    label_454:
        
        %stackPointer_452 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_453 = getelementptr %FrameHeader, %StackPointer %stackPointer_452, i64 0, i32 0
        %returnAddress_451 = load %ReturnAddress, ptr %returnAddress_pointer_453, !noalias !2
        musttail call tailcc void %returnAddress_451(%Pos %acc_3_3_5_169_4838, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_465(%Pos %v_r_2703_32_59_223_4725, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_466 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %p_8_9_4572_pointer_467 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_466, i64 0, i32 0
        %p_8_9_4572 = load %Prompt, ptr %p_8_9_4572_pointer_467, !noalias !2
        %acc_8_35_199_4777_pointer_468 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_466, i64 0, i32 1
        %acc_8_35_199_4777 = load i64, ptr %acc_8_35_199_4777_pointer_468, !noalias !2
        %v_r_2620_30_194_4609_pointer_469 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_466, i64 0, i32 2
        %v_r_2620_30_194_4609 = load %Pos, ptr %v_r_2620_30_194_4609_pointer_469, !noalias !2
        %tmp_5353_pointer_470 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_466, i64 0, i32 3
        %tmp_5353 = load i64, ptr %tmp_5353_pointer_470, !noalias !2
        %index_7_34_198_4707_pointer_471 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_466, i64 0, i32 4
        %index_7_34_198_4707 = load i64, ptr %index_7_34_198_4707_pointer_471, !noalias !2
        
        %tag_472 = extractvalue %Pos %v_r_2703_32_59_223_4725, 0
        %fields_473 = extractvalue %Pos %v_r_2703_32_59_223_4725, 1
        switch i64 %tag_472, label %label_474 [i64 1, label %label_497 i64 0, label %label_504]
    
    label_474:
        
        ret void
    
    label_479:
        
        ret void
    
    label_485:
        call ccc void @erasePositive(%Pos %v_r_2620_30_194_4609)
        
        %pair_480 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4572)
        %k_13_14_4_5280 = extractvalue <{%Resumption, %Stack}> %pair_480, 0
        %stack_481 = extractvalue <{%Resumption, %Stack}> %pair_480, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5280)
        
        %longLiteral_5463 = add i64 5, 0
        
        
        
        %pureApp_5464 = call ccc %Pos @boxInt_301(i64 %longLiteral_5463)
        
        
        
        %stackPointer_483 = call ccc %StackPointer @stackDeallocate(%Stack %stack_481, i64 24)
        %returnAddress_pointer_484 = getelementptr %FrameHeader, %StackPointer %stackPointer_483, i64 0, i32 0
        %returnAddress_482 = load %ReturnAddress, ptr %returnAddress_pointer_484, !noalias !2
        musttail call tailcc void %returnAddress_482(%Pos %pureApp_5464, %Stack %stack_481)
        ret void
    
    label_488:
        
        ret void
    
    label_494:
        call ccc void @erasePositive(%Pos %v_r_2620_30_194_4609)
        
        %pair_489 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4572)
        %k_13_14_4_5279 = extractvalue <{%Resumption, %Stack}> %pair_489, 0
        %stack_490 = extractvalue <{%Resumption, %Stack}> %pair_489, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5279)
        
        %longLiteral_5467 = add i64 5, 0
        
        
        
        %pureApp_5468 = call ccc %Pos @boxInt_301(i64 %longLiteral_5467)
        
        
        
        %stackPointer_492 = call ccc %StackPointer @stackDeallocate(%Stack %stack_490, i64 24)
        %returnAddress_pointer_493 = getelementptr %FrameHeader, %StackPointer %stackPointer_492, i64 0, i32 0
        %returnAddress_491 = load %ReturnAddress, ptr %returnAddress_pointer_493, !noalias !2
        musttail call tailcc void %returnAddress_491(%Pos %pureApp_5468, %Stack %stack_490)
        ret void
    
    label_495:
        
        %longLiteral_5470 = add i64 1, 0
        
        %pureApp_5469 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4707, i64 %longLiteral_5470)
        
        
        
        %longLiteral_5472 = add i64 10, 0
        
        %pureApp_5471 = call ccc i64 @infixMul_99(i64 %longLiteral_5472, i64 %acc_8_35_199_4777)
        
        
        
        %pureApp_5473 = call ccc i64 @toInt_2085(i64 %pureApp_5460)
        
        
        
        %pureApp_5474 = call ccc i64 @infixSub_105(i64 %pureApp_5473, i64 %tmp_5353)
        
        
        
        %pureApp_5475 = call ccc i64 @infixAdd_96(i64 %pureApp_5471, i64 %pureApp_5474)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4666(i64 %pureApp_5469, i64 %pureApp_5475, %Prompt %p_8_9_4572, %Pos %v_r_2620_30_194_4609, i64 %tmp_5353, %Stack %stack)
        ret void
    
    label_496:
        
        %intLiteral_5466 = add i64 57, 0
        
        %pureApp_5465 = call ccc %Pos @infixLte_2093(i64 %pureApp_5460, i64 %intLiteral_5466)
        
        
        
        %tag_486 = extractvalue %Pos %pureApp_5465, 0
        %fields_487 = extractvalue %Pos %pureApp_5465, 1
        switch i64 %tag_486, label %label_488 [i64 0, label %label_494 i64 1, label %label_495]
    
    label_497:
        %environment_475 = call ccc %Environment @objectEnvironment(%Object %fields_473)
        %v_coe_3519_46_73_237_4709_pointer_476 = getelementptr <{%Pos}>, %Environment %environment_475, i64 0, i32 0
        %v_coe_3519_46_73_237_4709 = load %Pos, ptr %v_coe_3519_46_73_237_4709_pointer_476, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3519_46_73_237_4709)
        call ccc void @eraseObject(%Object %fields_473)
        
        %pureApp_5460 = call ccc i64 @unboxChar_313(%Pos %v_coe_3519_46_73_237_4709)
        
        
        
        %intLiteral_5462 = add i64 48, 0
        
        %pureApp_5461 = call ccc %Pos @infixGte_2099(i64 %pureApp_5460, i64 %intLiteral_5462)
        
        
        
        %tag_477 = extractvalue %Pos %pureApp_5461, 0
        %fields_478 = extractvalue %Pos %pureApp_5461, 1
        switch i64 %tag_477, label %label_479 [i64 0, label %label_485 i64 1, label %label_496]
    
    label_504:
        %environment_498 = call ccc %Environment @objectEnvironment(%Object %fields_473)
        %v_y_2710_76_103_267_5458_pointer_499 = getelementptr <{%Pos, %Pos}>, %Environment %environment_498, i64 0, i32 0
        %v_y_2710_76_103_267_5458 = load %Pos, ptr %v_y_2710_76_103_267_5458_pointer_499, !noalias !2
        %v_y_2711_77_104_268_5459_pointer_500 = getelementptr <{%Pos, %Pos}>, %Environment %environment_498, i64 0, i32 1
        %v_y_2711_77_104_268_5459 = load %Pos, ptr %v_y_2711_77_104_268_5459_pointer_500, !noalias !2
        call ccc void @eraseObject(%Object %fields_473)
        call ccc void @erasePositive(%Pos %v_r_2620_30_194_4609)
        
        %stackPointer_502 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_503 = getelementptr %FrameHeader, %StackPointer %stackPointer_502, i64 0, i32 0
        %returnAddress_501 = load %ReturnAddress, ptr %returnAddress_pointer_503, !noalias !2
        musttail call tailcc void %returnAddress_501(i64 %acc_8_35_199_4777, %Stack %stack)
        ret void
}



define ccc void @sharer_510(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_511 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4572_505_pointer_512 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_511, i64 0, i32 0
        %p_8_9_4572_505 = load %Prompt, ptr %p_8_9_4572_505_pointer_512, !noalias !2
        %acc_8_35_199_4777_506_pointer_513 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_511, i64 0, i32 1
        %acc_8_35_199_4777_506 = load i64, ptr %acc_8_35_199_4777_506_pointer_513, !noalias !2
        %v_r_2620_30_194_4609_507_pointer_514 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_511, i64 0, i32 2
        %v_r_2620_30_194_4609_507 = load %Pos, ptr %v_r_2620_30_194_4609_507_pointer_514, !noalias !2
        %tmp_5353_508_pointer_515 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_511, i64 0, i32 3
        %tmp_5353_508 = load i64, ptr %tmp_5353_508_pointer_515, !noalias !2
        %index_7_34_198_4707_509_pointer_516 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_511, i64 0, i32 4
        %index_7_34_198_4707_509 = load i64, ptr %index_7_34_198_4707_509_pointer_516, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2620_30_194_4609_507)
        call ccc void @shareFrames(%StackPointer %stackPointer_511)
        ret void
}



define ccc void @eraser_522(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_523 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4572_517_pointer_524 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_523, i64 0, i32 0
        %p_8_9_4572_517 = load %Prompt, ptr %p_8_9_4572_517_pointer_524, !noalias !2
        %acc_8_35_199_4777_518_pointer_525 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_523, i64 0, i32 1
        %acc_8_35_199_4777_518 = load i64, ptr %acc_8_35_199_4777_518_pointer_525, !noalias !2
        %v_r_2620_30_194_4609_519_pointer_526 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_523, i64 0, i32 2
        %v_r_2620_30_194_4609_519 = load %Pos, ptr %v_r_2620_30_194_4609_519_pointer_526, !noalias !2
        %tmp_5353_520_pointer_527 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_523, i64 0, i32 3
        %tmp_5353_520 = load i64, ptr %tmp_5353_520_pointer_527, !noalias !2
        %index_7_34_198_4707_521_pointer_528 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_523, i64 0, i32 4
        %index_7_34_198_4707_521 = load i64, ptr %index_7_34_198_4707_521_pointer_528, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2620_30_194_4609_519)
        call ccc void @eraseFrames(%StackPointer %stackPointer_523)
        ret void
}



define tailcc void @returnAddress_539(%Pos %returned_5476, %Stack %stack) {
        
    entry:
        
        %stack_540 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_542 = call ccc %StackPointer @stackDeallocate(%Stack %stack_540, i64 24)
        %returnAddress_pointer_543 = getelementptr %FrameHeader, %StackPointer %stackPointer_542, i64 0, i32 0
        %returnAddress_541 = load %ReturnAddress, ptr %returnAddress_pointer_543, !noalias !2
        musttail call tailcc void %returnAddress_541(%Pos %returned_5476, %Stack %stack_540)
        ret void
}



define tailcc void @Exception_7_19_46_210_4785_clause_548(%Object %closure, %Pos %exc_8_20_47_211_4711, %Pos %msg_9_21_48_212_4748, %Stack %stack) {
        
    entry:
        
        %environment_549 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4864_pointer_550 = getelementptr <{%Prompt}>, %Environment %environment_549, i64 0, i32 0
        %p_6_18_45_209_4864 = load %Prompt, ptr %p_6_18_45_209_4864_pointer_550, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_551 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4864)
        %k_11_23_50_214_4896 = extractvalue <{%Resumption, %Stack}> %pair_551, 0
        %stack_552 = extractvalue <{%Resumption, %Stack}> %pair_551, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4896)
        
        %fields_553 = call ccc %Object @newObject(ptr @eraser_444, i64 32)
        %environment_554 = call ccc %Environment @objectEnvironment(%Object %fields_553)
        %exc_8_20_47_211_4711_pointer_557 = getelementptr <{%Pos, %Pos}>, %Environment %environment_554, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4711, ptr %exc_8_20_47_211_4711_pointer_557, !noalias !2
        %msg_9_21_48_212_4748_pointer_558 = getelementptr <{%Pos, %Pos}>, %Environment %environment_554, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4748, ptr %msg_9_21_48_212_4748_pointer_558, !noalias !2
        %make_5477_temporary_559 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5477 = insertvalue %Pos %make_5477_temporary_559, %Object %fields_553, 1
        
        
        
        %stackPointer_561 = call ccc %StackPointer @stackDeallocate(%Stack %stack_552, i64 24)
        %returnAddress_pointer_562 = getelementptr %FrameHeader, %StackPointer %stackPointer_561, i64 0, i32 0
        %returnAddress_560 = load %ReturnAddress, ptr %returnAddress_pointer_562, !noalias !2
        musttail call tailcc void %returnAddress_560(%Pos %make_5477, %Stack %stack_552)
        ret void
}


@vtable_563 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4785_clause_548]


define ccc void @eraser_567(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4864_566_pointer_568 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4864_566 = load %Prompt, ptr %p_6_18_45_209_4864_566_pointer_568, !noalias !2
        ret void
}



define ccc void @eraser_575(%Environment %environment) {
        
    entry:
        
        %tmp_5355_574_pointer_576 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5355_574 = load %Pos, ptr %tmp_5355_574_pointer_576, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5355_574)
        ret void
}



define tailcc void @returnAddress_571(i64 %v_coe_3518_6_28_55_219_4778, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5478 = call ccc %Pos @boxChar_311(i64 %v_coe_3518_6_28_55_219_4778)
        
        
        
        %fields_572 = call ccc %Object @newObject(ptr @eraser_575, i64 16)
        %environment_573 = call ccc %Environment @objectEnvironment(%Object %fields_572)
        %tmp_5355_pointer_577 = getelementptr <{%Pos}>, %Environment %environment_573, i64 0, i32 0
        store %Pos %pureApp_5478, ptr %tmp_5355_pointer_577, !noalias !2
        %make_5479_temporary_578 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5479 = insertvalue %Pos %make_5479_temporary_578, %Object %fields_572, 1
        
        
        
        %stackPointer_580 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_581 = getelementptr %FrameHeader, %StackPointer %stackPointer_580, i64 0, i32 0
        %returnAddress_579 = load %ReturnAddress, ptr %returnAddress_pointer_581, !noalias !2
        musttail call tailcc void %returnAddress_579(%Pos %make_5479, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4666(i64 %index_7_34_198_4707, i64 %acc_8_35_199_4777, %Prompt %p_8_9_4572, %Pos %v_r_2620_30_194_4609, i64 %tmp_5353, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2620_30_194_4609)
        %stackPointer_529 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %p_8_9_4572_pointer_530 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_529, i64 0, i32 0
        store %Prompt %p_8_9_4572, ptr %p_8_9_4572_pointer_530, !noalias !2
        %acc_8_35_199_4777_pointer_531 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_529, i64 0, i32 1
        store i64 %acc_8_35_199_4777, ptr %acc_8_35_199_4777_pointer_531, !noalias !2
        %v_r_2620_30_194_4609_pointer_532 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_529, i64 0, i32 2
        store %Pos %v_r_2620_30_194_4609, ptr %v_r_2620_30_194_4609_pointer_532, !noalias !2
        %tmp_5353_pointer_533 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_529, i64 0, i32 3
        store i64 %tmp_5353, ptr %tmp_5353_pointer_533, !noalias !2
        %index_7_34_198_4707_pointer_534 = getelementptr <{%Prompt, i64, %Pos, i64, i64}>, %StackPointer %stackPointer_529, i64 0, i32 4
        store i64 %index_7_34_198_4707, ptr %index_7_34_198_4707_pointer_534, !noalias !2
        %returnAddress_pointer_535 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_529, i64 0, i32 1, i32 0
        %sharer_pointer_536 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_529, i64 0, i32 1, i32 1
        %eraser_pointer_537 = getelementptr <{<{%Prompt, i64, %Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_529, i64 0, i32 1, i32 2
        store ptr @returnAddress_465, ptr %returnAddress_pointer_535, !noalias !2
        store ptr @sharer_510, ptr %sharer_pointer_536, !noalias !2
        store ptr @eraser_522, ptr %eraser_pointer_537, !noalias !2
        
        %stack_538 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4864 = call ccc %Prompt @currentPrompt(%Stack %stack_538)
        %stackPointer_544 = call ccc %StackPointer @stackAllocate(%Stack %stack_538, i64 24)
        %returnAddress_pointer_545 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_544, i64 0, i32 1, i32 0
        %sharer_pointer_546 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_544, i64 0, i32 1, i32 1
        %eraser_pointer_547 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_544, i64 0, i32 1, i32 2
        store ptr @returnAddress_539, ptr %returnAddress_pointer_545, !noalias !2
        store ptr @sharer_61, ptr %sharer_pointer_546, !noalias !2
        store ptr @eraser_63, ptr %eraser_pointer_547, !noalias !2
        
        %closure_564 = call ccc %Object @newObject(ptr @eraser_567, i64 8)
        %environment_565 = call ccc %Environment @objectEnvironment(%Object %closure_564)
        %p_6_18_45_209_4864_pointer_569 = getelementptr <{%Prompt}>, %Environment %environment_565, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4864, ptr %p_6_18_45_209_4864_pointer_569, !noalias !2
        %vtable_temporary_570 = insertvalue %Neg zeroinitializer, ptr @vtable_563, 0
        %Exception_7_19_46_210_4785 = insertvalue %Neg %vtable_temporary_570, %Object %closure_564, 1
        %stackPointer_582 = call ccc %StackPointer @stackAllocate(%Stack %stack_538, i64 24)
        %returnAddress_pointer_583 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_582, i64 0, i32 1, i32 0
        %sharer_pointer_584 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_582, i64 0, i32 1, i32 1
        %eraser_pointer_585 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_582, i64 0, i32 1, i32 2
        store ptr @returnAddress_571, ptr %returnAddress_pointer_583, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_584, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_585, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2620_30_194_4609, i64 %index_7_34_198_4707, %Neg %Exception_7_19_46_210_4785, %Stack %stack_538)
        ret void
}



define tailcc void @Exception_9_106_133_297_4684_clause_586(%Object %closure, %Pos %exception_10_107_134_298_5480, %Pos %msg_11_108_135_299_5481, %Stack %stack) {
        
    entry:
        
        %environment_587 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4572_pointer_588 = getelementptr <{%Prompt}>, %Environment %environment_587, i64 0, i32 0
        %p_8_9_4572 = load %Prompt, ptr %p_8_9_4572_pointer_588, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5480)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5481)
        
        %pair_589 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4572)
        %k_13_14_4_5336 = extractvalue <{%Resumption, %Stack}> %pair_589, 0
        %stack_590 = extractvalue <{%Resumption, %Stack}> %pair_589, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5336)
        
        %longLiteral_5482 = add i64 5, 0
        
        
        
        %pureApp_5483 = call ccc %Pos @boxInt_301(i64 %longLiteral_5482)
        
        
        
        %stackPointer_592 = call ccc %StackPointer @stackDeallocate(%Stack %stack_590, i64 24)
        %returnAddress_pointer_593 = getelementptr %FrameHeader, %StackPointer %stackPointer_592, i64 0, i32 0
        %returnAddress_591 = load %ReturnAddress, ptr %returnAddress_pointer_593, !noalias !2
        musttail call tailcc void %returnAddress_591(%Pos %pureApp_5483, %Stack %stack_590)
        ret void
}


@vtable_594 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4684_clause_586]


define tailcc void @returnAddress_605(i64 %v_coe_3523_22_131_158_322_4827, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5486 = call ccc %Pos @boxInt_301(i64 %v_coe_3523_22_131_158_322_4827)
        
        
        
        
        
        %pureApp_5487 = call ccc i64 @unboxInt_303(%Pos %pureApp_5486)
        
        
        
        %pureApp_5488 = call ccc %Pos @boxInt_301(i64 %pureApp_5487)
        
        
        
        %stackPointer_607 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_608 = getelementptr %FrameHeader, %StackPointer %stackPointer_607, i64 0, i32 0
        %returnAddress_606 = load %ReturnAddress, ptr %returnAddress_pointer_608, !noalias !2
        musttail call tailcc void %returnAddress_606(%Pos %pureApp_5488, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_617(i64 %v_r_2717_1_9_20_129_156_320_4705, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5492 = add i64 0, 0
        
        %pureApp_5491 = call ccc i64 @infixSub_105(i64 %longLiteral_5492, i64 %v_r_2717_1_9_20_129_156_320_4705)
        
        
        
        %stackPointer_619 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_620 = getelementptr %FrameHeader, %StackPointer %stackPointer_619, i64 0, i32 0
        %returnAddress_618 = load %ReturnAddress, ptr %returnAddress_pointer_620, !noalias !2
        musttail call tailcc void %returnAddress_618(i64 %pureApp_5491, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_600(i64 %v_r_2716_3_14_123_150_314_4739, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_601 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_4572_pointer_602 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_601, i64 0, i32 0
        %p_8_9_4572 = load %Prompt, ptr %p_8_9_4572_pointer_602, !noalias !2
        %v_r_2620_30_194_4609_pointer_603 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_601, i64 0, i32 1
        %v_r_2620_30_194_4609 = load %Pos, ptr %v_r_2620_30_194_4609_pointer_603, !noalias !2
        %tmp_5353_pointer_604 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_601, i64 0, i32 2
        %tmp_5353 = load i64, ptr %tmp_5353_pointer_604, !noalias !2
        
        %intLiteral_5485 = add i64 45, 0
        
        %pureApp_5484 = call ccc %Pos @infixEq_78(i64 %v_r_2716_3_14_123_150_314_4739, i64 %intLiteral_5485)
        
        
        %stackPointer_609 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_610 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_609, i64 0, i32 1, i32 0
        %sharer_pointer_611 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_609, i64 0, i32 1, i32 1
        %eraser_pointer_612 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_609, i64 0, i32 1, i32 2
        store ptr @returnAddress_605, ptr %returnAddress_pointer_610, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_611, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_612, !noalias !2
        
        %tag_613 = extractvalue %Pos %pureApp_5484, 0
        %fields_614 = extractvalue %Pos %pureApp_5484, 1
        switch i64 %tag_613, label %label_615 [i64 0, label %label_616 i64 1, label %label_625]
    
    label_615:
        
        ret void
    
    label_616:
        
        %longLiteral_5489 = add i64 0, 0
        
        %longLiteral_5490 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4666(i64 %longLiteral_5489, i64 %longLiteral_5490, %Prompt %p_8_9_4572, %Pos %v_r_2620_30_194_4609, i64 %tmp_5353, %Stack %stack)
        ret void
    
    label_625:
        %stackPointer_621 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_622 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_621, i64 0, i32 1, i32 0
        %sharer_pointer_623 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_621, i64 0, i32 1, i32 1
        %eraser_pointer_624 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_621, i64 0, i32 1, i32 2
        store ptr @returnAddress_617, ptr %returnAddress_pointer_622, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_623, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_624, !noalias !2
        
        %longLiteral_5493 = add i64 1, 0
        
        %longLiteral_5494 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4666(i64 %longLiteral_5493, i64 %longLiteral_5494, %Prompt %p_8_9_4572, %Pos %v_r_2620_30_194_4609, i64 %tmp_5353, %Stack %stack)
        ret void
}



define ccc void @sharer_629(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_630 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4572_626_pointer_631 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_630, i64 0, i32 0
        %p_8_9_4572_626 = load %Prompt, ptr %p_8_9_4572_626_pointer_631, !noalias !2
        %v_r_2620_30_194_4609_627_pointer_632 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_630, i64 0, i32 1
        %v_r_2620_30_194_4609_627 = load %Pos, ptr %v_r_2620_30_194_4609_627_pointer_632, !noalias !2
        %tmp_5353_628_pointer_633 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_630, i64 0, i32 2
        %tmp_5353_628 = load i64, ptr %tmp_5353_628_pointer_633, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2620_30_194_4609_627)
        call ccc void @shareFrames(%StackPointer %stackPointer_630)
        ret void
}



define ccc void @eraser_637(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_638 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4572_634_pointer_639 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_638, i64 0, i32 0
        %p_8_9_4572_634 = load %Prompt, ptr %p_8_9_4572_634_pointer_639, !noalias !2
        %v_r_2620_30_194_4609_635_pointer_640 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_638, i64 0, i32 1
        %v_r_2620_30_194_4609_635 = load %Pos, ptr %v_r_2620_30_194_4609_635_pointer_640, !noalias !2
        %tmp_5353_636_pointer_641 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_638, i64 0, i32 2
        %tmp_5353_636 = load i64, ptr %tmp_5353_636_pointer_641, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2620_30_194_4609_635)
        call ccc void @eraseFrames(%StackPointer %stackPointer_638)
        ret void
}



define tailcc void @returnAddress_462(%Pos %v_r_2620_30_194_4609, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_463 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4572_pointer_464 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_463, i64 0, i32 0
        %p_8_9_4572 = load %Prompt, ptr %p_8_9_4572_pointer_464, !noalias !2
        
        %intLiteral_5457 = add i64 48, 0
        
        %pureApp_5456 = call ccc i64 @toInt_2085(i64 %intLiteral_5457)
        
        
        
        %closure_595 = call ccc %Object @newObject(ptr @eraser_567, i64 8)
        %environment_596 = call ccc %Environment @objectEnvironment(%Object %closure_595)
        %p_8_9_4572_pointer_598 = getelementptr <{%Prompt}>, %Environment %environment_596, i64 0, i32 0
        store %Prompt %p_8_9_4572, ptr %p_8_9_4572_pointer_598, !noalias !2
        %vtable_temporary_599 = insertvalue %Neg zeroinitializer, ptr @vtable_594, 0
        %Exception_9_106_133_297_4684 = insertvalue %Neg %vtable_temporary_599, %Object %closure_595, 1
        call ccc void @sharePositive(%Pos %v_r_2620_30_194_4609)
        %stackPointer_642 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_4572_pointer_643 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_642, i64 0, i32 0
        store %Prompt %p_8_9_4572, ptr %p_8_9_4572_pointer_643, !noalias !2
        %v_r_2620_30_194_4609_pointer_644 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_642, i64 0, i32 1
        store %Pos %v_r_2620_30_194_4609, ptr %v_r_2620_30_194_4609_pointer_644, !noalias !2
        %tmp_5353_pointer_645 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_642, i64 0, i32 2
        store i64 %pureApp_5456, ptr %tmp_5353_pointer_645, !noalias !2
        %returnAddress_pointer_646 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_642, i64 0, i32 1, i32 0
        %sharer_pointer_647 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_642, i64 0, i32 1, i32 1
        %eraser_pointer_648 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_642, i64 0, i32 1, i32 2
        store ptr @returnAddress_600, ptr %returnAddress_pointer_646, !noalias !2
        store ptr @sharer_629, ptr %sharer_pointer_647, !noalias !2
        store ptr @eraser_637, ptr %eraser_pointer_648, !noalias !2
        
        %longLiteral_5495 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2620_30_194_4609, i64 %longLiteral_5495, %Neg %Exception_9_106_133_297_4684, %Stack %stack)
        ret void
}



define ccc void @sharer_650(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_651 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4572_649_pointer_652 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_651, i64 0, i32 0
        %p_8_9_4572_649 = load %Prompt, ptr %p_8_9_4572_649_pointer_652, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_651)
        ret void
}



define ccc void @eraser_654(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_655 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4572_653_pointer_656 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_655, i64 0, i32 0
        %p_8_9_4572_653 = load %Prompt, ptr %p_8_9_4572_653_pointer_656, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_655)
        ret void
}


@utf8StringLiteral_5496.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_459(%Pos %v_r_2619_24_188_4803, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_460 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4572_pointer_461 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_460, i64 0, i32 0
        %p_8_9_4572 = load %Prompt, ptr %p_8_9_4572_pointer_461, !noalias !2
        %stackPointer_657 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4572_pointer_658 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_657, i64 0, i32 0
        store %Prompt %p_8_9_4572, ptr %p_8_9_4572_pointer_658, !noalias !2
        %returnAddress_pointer_659 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_657, i64 0, i32 1, i32 0
        %sharer_pointer_660 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_657, i64 0, i32 1, i32 1
        %eraser_pointer_661 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_657, i64 0, i32 1, i32 2
        store ptr @returnAddress_462, ptr %returnAddress_pointer_659, !noalias !2
        store ptr @sharer_650, ptr %sharer_pointer_660, !noalias !2
        store ptr @eraser_654, ptr %eraser_pointer_661, !noalias !2
        
        %tag_662 = extractvalue %Pos %v_r_2619_24_188_4803, 0
        %fields_663 = extractvalue %Pos %v_r_2619_24_188_4803, 1
        switch i64 %tag_662, label %label_664 [i64 0, label %label_668 i64 1, label %label_674]
    
    label_664:
        
        ret void
    
    label_668:
        
        %utf8StringLiteral_5496 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5496.lit)
        
        %stackPointer_666 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_667 = getelementptr %FrameHeader, %StackPointer %stackPointer_666, i64 0, i32 0
        %returnAddress_665 = load %ReturnAddress, ptr %returnAddress_pointer_667, !noalias !2
        musttail call tailcc void %returnAddress_665(%Pos %utf8StringLiteral_5496, %Stack %stack)
        ret void
    
    label_674:
        %environment_669 = call ccc %Environment @objectEnvironment(%Object %fields_663)
        %v_y_3345_8_29_193_4655_pointer_670 = getelementptr <{%Pos}>, %Environment %environment_669, i64 0, i32 0
        %v_y_3345_8_29_193_4655 = load %Pos, ptr %v_y_3345_8_29_193_4655_pointer_670, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3345_8_29_193_4655)
        call ccc void @eraseObject(%Object %fields_663)
        
        %stackPointer_672 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_673 = getelementptr %FrameHeader, %StackPointer %stackPointer_672, i64 0, i32 0
        %returnAddress_671 = load %ReturnAddress, ptr %returnAddress_pointer_673, !noalias !2
        musttail call tailcc void %returnAddress_671(%Pos %v_y_3345_8_29_193_4655, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_456(%Pos %v_r_2618_13_177_4779, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_457 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4572_pointer_458 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_457, i64 0, i32 0
        %p_8_9_4572 = load %Prompt, ptr %p_8_9_4572_pointer_458, !noalias !2
        %stackPointer_677 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4572_pointer_678 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_677, i64 0, i32 0
        store %Prompt %p_8_9_4572, ptr %p_8_9_4572_pointer_678, !noalias !2
        %returnAddress_pointer_679 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_677, i64 0, i32 1, i32 0
        %sharer_pointer_680 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_677, i64 0, i32 1, i32 1
        %eraser_pointer_681 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_677, i64 0, i32 1, i32 2
        store ptr @returnAddress_459, ptr %returnAddress_pointer_679, !noalias !2
        store ptr @sharer_650, ptr %sharer_pointer_680, !noalias !2
        store ptr @eraser_654, ptr %eraser_pointer_681, !noalias !2
        
        %tag_682 = extractvalue %Pos %v_r_2618_13_177_4779, 0
        %fields_683 = extractvalue %Pos %v_r_2618_13_177_4779, 1
        switch i64 %tag_682, label %label_684 [i64 0, label %label_689 i64 1, label %label_701]
    
    label_684:
        
        ret void
    
    label_689:
        
        %make_5497_temporary_685 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5497 = insertvalue %Pos %make_5497_temporary_685, %Object null, 1
        
        
        
        %stackPointer_687 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_688 = getelementptr %FrameHeader, %StackPointer %stackPointer_687, i64 0, i32 0
        %returnAddress_686 = load %ReturnAddress, ptr %returnAddress_pointer_688, !noalias !2
        musttail call tailcc void %returnAddress_686(%Pos %make_5497, %Stack %stack)
        ret void
    
    label_701:
        %environment_690 = call ccc %Environment @objectEnvironment(%Object %fields_683)
        %v_y_2854_10_21_185_4843_pointer_691 = getelementptr <{%Pos, %Pos}>, %Environment %environment_690, i64 0, i32 0
        %v_y_2854_10_21_185_4843 = load %Pos, ptr %v_y_2854_10_21_185_4843_pointer_691, !noalias !2
        %v_y_2855_11_22_186_4728_pointer_692 = getelementptr <{%Pos, %Pos}>, %Environment %environment_690, i64 0, i32 1
        %v_y_2855_11_22_186_4728 = load %Pos, ptr %v_y_2855_11_22_186_4728_pointer_692, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2854_10_21_185_4843)
        call ccc void @eraseObject(%Object %fields_683)
        
        %fields_693 = call ccc %Object @newObject(ptr @eraser_575, i64 16)
        %environment_694 = call ccc %Environment @objectEnvironment(%Object %fields_693)
        %v_y_2854_10_21_185_4843_pointer_696 = getelementptr <{%Pos}>, %Environment %environment_694, i64 0, i32 0
        store %Pos %v_y_2854_10_21_185_4843, ptr %v_y_2854_10_21_185_4843_pointer_696, !noalias !2
        %make_5498_temporary_697 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5498 = insertvalue %Pos %make_5498_temporary_697, %Object %fields_693, 1
        
        
        
        %stackPointer_699 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_700 = getelementptr %FrameHeader, %StackPointer %stackPointer_699, i64 0, i32 0
        %returnAddress_698 = load %ReturnAddress, ptr %returnAddress_pointer_700, !noalias !2
        musttail call tailcc void %returnAddress_698(%Pos %make_5498, %Stack %stack)
        ret void
}



define tailcc void @main_2453(%Stack %stack) {
        
    entry:
        
        %stackPointer_423 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_424 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_423, i64 0, i32 1, i32 0
        %sharer_pointer_425 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_423, i64 0, i32 1, i32 1
        %eraser_pointer_426 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_423, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_424, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_425, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_426, !noalias !2
        
        %stack_427 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4572 = call ccc %Prompt @currentPrompt(%Stack %stack_427)
        %stackPointer_433 = call ccc %StackPointer @stackAllocate(%Stack %stack_427, i64 24)
        %returnAddress_pointer_434 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_433, i64 0, i32 1, i32 0
        %sharer_pointer_435 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_433, i64 0, i32 1, i32 1
        %eraser_pointer_436 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_433, i64 0, i32 1, i32 2
        store ptr @returnAddress_428, ptr %returnAddress_pointer_434, !noalias !2
        store ptr @sharer_61, ptr %sharer_pointer_435, !noalias !2
        store ptr @eraser_63, ptr %eraser_pointer_436, !noalias !2
        
        %pureApp_5452 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5454 = add i64 1, 0
        
        %pureApp_5453 = call ccc i64 @infixSub_105(i64 %pureApp_5452, i64 %longLiteral_5454)
        
        
        
        %make_5455_temporary_455 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5455 = insertvalue %Pos %make_5455_temporary_455, %Object null, 1
        
        
        %stackPointer_704 = call ccc %StackPointer @stackAllocate(%Stack %stack_427, i64 32)
        %p_8_9_4572_pointer_705 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_704, i64 0, i32 0
        store %Prompt %p_8_9_4572, ptr %p_8_9_4572_pointer_705, !noalias !2
        %returnAddress_pointer_706 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_704, i64 0, i32 1, i32 0
        %sharer_pointer_707 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_704, i64 0, i32 1, i32 1
        %eraser_pointer_708 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_704, i64 0, i32 1, i32 2
        store ptr @returnAddress_456, ptr %returnAddress_pointer_706, !noalias !2
        store ptr @sharer_650, ptr %sharer_pointer_707, !noalias !2
        store ptr @eraser_654, ptr %eraser_pointer_708, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4680(i64 %pureApp_5453, %Pos %make_5455, %Stack %stack_427)
        ret void
}


@utf8StringLiteral_5393.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5395.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5398.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_709(%Pos %v_r_2785_3575, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_710 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_711 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_710, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_711, !noalias !2
        %index_2107_pointer_712 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_710, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_712, !noalias !2
        %Exception_2362_pointer_713 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_710, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_713, !noalias !2
        
        %tag_714 = extractvalue %Pos %v_r_2785_3575, 0
        %fields_715 = extractvalue %Pos %v_r_2785_3575, 1
        switch i64 %tag_714, label %label_716 [i64 0, label %label_720 i64 1, label %label_726]
    
    label_716:
        
        ret void
    
    label_720:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5389 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_718 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_719 = getelementptr %FrameHeader, %StackPointer %stackPointer_718, i64 0, i32 0
        %returnAddress_717 = load %ReturnAddress, ptr %returnAddress_pointer_719, !noalias !2
        musttail call tailcc void %returnAddress_717(i64 %pureApp_5389, %Stack %stack)
        ret void
    
    label_726:
        
        %make_5390_temporary_721 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5390 = insertvalue %Pos %make_5390_temporary_721, %Object null, 1
        
        
        
        %pureApp_5391 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5393 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5393.lit)
        
        %pureApp_5392 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5393, %Pos %pureApp_5391)
        
        
        
        %utf8StringLiteral_5395 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5395.lit)
        
        %pureApp_5394 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5392, %Pos %utf8StringLiteral_5395)
        
        
        
        %pureApp_5396 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5394, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5398 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5398.lit)
        
        %pureApp_5397 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5396, %Pos %utf8StringLiteral_5398)
        
        
        
        %vtable_722 = extractvalue %Neg %Exception_2362, 0
        %closure_723 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_724 = getelementptr ptr, ptr %vtable_722, i64 0
        %functionPointer_725 = load ptr, ptr %functionPointer_pointer_724, !noalias !2
        musttail call tailcc void %functionPointer_725(%Object %closure_723, %Pos %make_5390, %Pos %pureApp_5397, %Stack %stack)
        ret void
}



define ccc void @sharer_730(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_731 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_727_pointer_732 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_731, i64 0, i32 0
        %str_2106_727 = load %Pos, ptr %str_2106_727_pointer_732, !noalias !2
        %index_2107_728_pointer_733 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_731, i64 0, i32 1
        %index_2107_728 = load i64, ptr %index_2107_728_pointer_733, !noalias !2
        %Exception_2362_729_pointer_734 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_731, i64 0, i32 2
        %Exception_2362_729 = load %Neg, ptr %Exception_2362_729_pointer_734, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_727)
        call ccc void @shareNegative(%Neg %Exception_2362_729)
        call ccc void @shareFrames(%StackPointer %stackPointer_731)
        ret void
}



define ccc void @eraser_738(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_739 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_735_pointer_740 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_739, i64 0, i32 0
        %str_2106_735 = load %Pos, ptr %str_2106_735_pointer_740, !noalias !2
        %index_2107_736_pointer_741 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_739, i64 0, i32 1
        %index_2107_736 = load i64, ptr %index_2107_736_pointer_741, !noalias !2
        %Exception_2362_737_pointer_742 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_739, i64 0, i32 2
        %Exception_2362_737 = load %Neg, ptr %Exception_2362_737_pointer_742, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_735)
        call ccc void @eraseNegative(%Neg %Exception_2362_737)
        call ccc void @eraseFrames(%StackPointer %stackPointer_739)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5388 = add i64 0, 0
        
        %pureApp_5387 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5388)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_743 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_744 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_743, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_744, !noalias !2
        %index_2107_pointer_745 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_743, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_745, !noalias !2
        %Exception_2362_pointer_746 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_743, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_746, !noalias !2
        %returnAddress_pointer_747 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_743, i64 0, i32 1, i32 0
        %sharer_pointer_748 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_743, i64 0, i32 1, i32 1
        %eraser_pointer_749 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_743, i64 0, i32 1, i32 2
        store ptr @returnAddress_709, ptr %returnAddress_pointer_747, !noalias !2
        store ptr @sharer_730, ptr %sharer_pointer_748, !noalias !2
        store ptr @eraser_738, ptr %eraser_pointer_749, !noalias !2
        
        %tag_750 = extractvalue %Pos %pureApp_5387, 0
        %fields_751 = extractvalue %Pos %pureApp_5387, 1
        switch i64 %tag_750, label %label_752 [i64 0, label %label_756 i64 1, label %label_761]
    
    label_752:
        
        ret void
    
    label_756:
        
        %pureApp_5399 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5400 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5399)
        
        
        
        %stackPointer_754 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_755 = getelementptr %FrameHeader, %StackPointer %stackPointer_754, i64 0, i32 0
        %returnAddress_753 = load %ReturnAddress, ptr %returnAddress_pointer_755, !noalias !2
        musttail call tailcc void %returnAddress_753(%Pos %pureApp_5400, %Stack %stack)
        ret void
    
    label_761:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5401_temporary_757 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5401 = insertvalue %Pos %booleanLiteral_5401_temporary_757, %Object null, 1
        
        %stackPointer_759 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_760 = getelementptr %FrameHeader, %StackPointer %stackPointer_759, i64 0, i32 0
        %returnAddress_758 = load %ReturnAddress, ptr %returnAddress_pointer_760, !noalias !2
        musttail call tailcc void %returnAddress_758(%Pos %booleanLiteral_5401, %Stack %stack)
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
        
        musttail call tailcc void @main_2453(%Stack %stack)
        ret void
}
