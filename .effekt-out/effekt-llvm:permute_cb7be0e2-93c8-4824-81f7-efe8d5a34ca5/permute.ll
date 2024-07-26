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


; declaration include
  declare i32 @clock_gettime(i32, ptr)



define ccc %Pos @allocate_2473(i64 %size_2472) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_new(%Int %size_2472)
    ret %Pos %z
  
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



define tailcc void @returnAddress_10(i64 %v_r_2943_2_5110, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_11 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_5107_pointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 0
        %i_6_5107 = load i64, ptr %i_6_5107_pointer_12, !noalias !2
        %tmp_5256_pointer_13 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 1
        %tmp_5256 = load i64, ptr %tmp_5256_pointer_13, !noalias !2
        
        %longLiteral_5338 = add i64 1, 0
        
        %pureApp_5337 = call ccc i64 @infixAdd_96(i64 %i_6_5107, i64 %longLiteral_5338)
        
        
        
        
        
        musttail call tailcc void @loop_5_5104(i64 %pureApp_5337, i64 %tmp_5256, %Stack %stack)
        ret void
}



define ccc void @sharer_16(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_17 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5107_14_pointer_18 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 0
        %i_6_5107_14 = load i64, ptr %i_6_5107_14_pointer_18, !noalias !2
        %tmp_5256_15_pointer_19 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 1
        %tmp_5256_15 = load i64, ptr %tmp_5256_15_pointer_19, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_17)
        ret void
}



define ccc void @eraser_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5107_20_pointer_24 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %i_6_5107_20 = load i64, ptr %i_6_5107_20_pointer_24, !noalias !2
        %tmp_5256_21_pointer_25 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 1
        %tmp_5256_21 = load i64, ptr %tmp_5256_21_pointer_25, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_23)
        ret void
}



define tailcc void @loop_5_5104(i64 %i_6_5107, i64 %tmp_5256, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5335 = call ccc %Pos @infixLt_178(i64 %i_6_5107, i64 %tmp_5256)
        
        
        
        %tag_2 = extractvalue %Pos %pureApp_5335, 0
        %fields_3 = extractvalue %Pos %pureApp_5335, 1
        switch i64 %tag_2, label %label_4 [i64 0, label %label_9 i64 1, label %label_32]
    
    label_4:
        
        ret void
    
    label_9:
        
        %unitLiteral_5336_temporary_5 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5336 = insertvalue %Pos %unitLiteral_5336_temporary_5, %Object null, 1
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %unitLiteral_5336, %Stack %stack)
        ret void
    
    label_32:
        %stackPointer_26 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_5107_pointer_27 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        store i64 %i_6_5107, ptr %i_6_5107_pointer_27, !noalias !2
        %tmp_5256_pointer_28 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 1
        store i64 %tmp_5256, ptr %tmp_5256_pointer_28, !noalias !2
        %returnAddress_pointer_29 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 0
        %sharer_pointer_30 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 1
        %eraser_pointer_31 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 2
        store ptr @returnAddress_10, ptr %returnAddress_pointer_29, !noalias !2
        store ptr @sharer_16, ptr %sharer_pointer_30, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_31, !noalias !2
        
        %longLiteral_5339 = add i64 6, 0
        
        
        
        musttail call tailcc void @run_2857(i64 %longLiteral_5339, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_34(i64 %r_2870, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5341 = call ccc %Pos @show_14(i64 %r_2870)
        
        
        
        %pureApp_5342 = call ccc %Pos @println_1(%Pos %pureApp_5341)
        
        
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_37 = getelementptr %FrameHeader, %StackPointer %stackPointer_36, i64 0, i32 0
        %returnAddress_35 = load %ReturnAddress, ptr %returnAddress_pointer_37, !noalias !2
        musttail call tailcc void %returnAddress_35(%Pos %pureApp_5342, %Stack %stack)
        ret void
}



define ccc void @sharer_38(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_39 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_39)
        ret void
}



define ccc void @eraser_40(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_41 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_41)
        ret void
}



define tailcc void @returnAddress_33(%Pos %v_r_2945_5340, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %v_r_2945_5340)
        %stackPointer_42 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_43 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 0
        %sharer_pointer_44 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 1
        %eraser_pointer_45 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_43, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_44, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_45, !noalias !2
        
        %longLiteral_5343 = add i64 6, 0
        
        
        
        musttail call tailcc void @run_2857(i64 %longLiteral_5343, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3979_4043, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5332 = call ccc i64 @unboxInt_303(%Pos %v_coe_3979_4043)
        
        
        
        %longLiteral_5334 = add i64 1, 0
        
        %pureApp_5333 = call ccc i64 @infixSub_105(i64 %pureApp_5332, i64 %longLiteral_5334)
        
        
        %stackPointer_46 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_47 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 0
        %sharer_pointer_48 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 1
        %eraser_pointer_49 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 2
        store ptr @returnAddress_33, ptr %returnAddress_pointer_47, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_48, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_49, !noalias !2
        
        %longLiteral_5344 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_5104(i64 %longLiteral_5344, i64 %pureApp_5333, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_55(%Pos %returned_5345, %Stack %stack) {
        
    entry:
        
        %stack_56 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_58 = call ccc %StackPointer @stackDeallocate(%Stack %stack_56, i64 24)
        %returnAddress_pointer_59 = getelementptr %FrameHeader, %StackPointer %stackPointer_58, i64 0, i32 0
        %returnAddress_57 = load %ReturnAddress, ptr %returnAddress_pointer_59, !noalias !2
        musttail call tailcc void %returnAddress_57(%Pos %returned_5345, %Stack %stack_56)
        ret void
}



define ccc void @sharer_60(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_61 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_62(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_63 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_63)
        ret void
}



define ccc void @eraser_75(%Environment %environment) {
        
    entry:
        
        %tmp_5229_73_pointer_76 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5229_73 = load %Pos, ptr %tmp_5229_73_pointer_76, !noalias !2
        %acc_3_3_5_169_4960_74_pointer_77 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4960_74 = load %Pos, ptr %acc_3_3_5_169_4960_74_pointer_77, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5229_73)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4960_74)
        ret void
}



define tailcc void @toList_1_1_3_167_4865(i64 %start_2_2_4_168_4965, %Pos %acc_3_3_5_169_4960, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5347 = add i64 1, 0
        
        %pureApp_5346 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4965, i64 %longLiteral_5347)
        
        
        
        %tag_68 = extractvalue %Pos %pureApp_5346, 0
        %fields_69 = extractvalue %Pos %pureApp_5346, 1
        switch i64 %tag_68, label %label_70 [i64 0, label %label_81 i64 1, label %label_85]
    
    label_70:
        
        ret void
    
    label_81:
        
        %pureApp_5348 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4965)
        
        
        
        %longLiteral_5350 = add i64 1, 0
        
        %pureApp_5349 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4965, i64 %longLiteral_5350)
        
        
        
        %fields_71 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_72 = call ccc %Environment @objectEnvironment(%Object %fields_71)
        %tmp_5229_pointer_78 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 0
        store %Pos %pureApp_5348, ptr %tmp_5229_pointer_78, !noalias !2
        %acc_3_3_5_169_4960_pointer_79 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4960, ptr %acc_3_3_5_169_4960_pointer_79, !noalias !2
        %make_5351_temporary_80 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5351 = insertvalue %Pos %make_5351_temporary_80, %Object %fields_71, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4865(i64 %pureApp_5349, %Pos %make_5351, %Stack %stack)
        ret void
    
    label_85:
        
        %stackPointer_83 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_84 = getelementptr %FrameHeader, %StackPointer %stackPointer_83, i64 0, i32 0
        %returnAddress_82 = load %ReturnAddress, ptr %returnAddress_pointer_84, !noalias !2
        musttail call tailcc void %returnAddress_82(%Pos %acc_3_3_5_169_4960, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_96(%Pos %v_r_3130_32_59_223_4998, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_97 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %index_7_34_198_4784_pointer_98 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_97, i64 0, i32 0
        %index_7_34_198_4784 = load i64, ptr %index_7_34_198_4784_pointer_98, !noalias !2
        %acc_8_35_199_4771_pointer_99 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_97, i64 0, i32 1
        %acc_8_35_199_4771 = load i64, ptr %acc_8_35_199_4771_pointer_99, !noalias !2
        %p_8_9_4734_pointer_100 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_97, i64 0, i32 2
        %p_8_9_4734 = load %Prompt, ptr %p_8_9_4734_pointer_100, !noalias !2
        %v_r_2940_30_194_4827_pointer_101 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_97, i64 0, i32 3
        %v_r_2940_30_194_4827 = load %Pos, ptr %v_r_2940_30_194_4827_pointer_101, !noalias !2
        %tmp_5236_pointer_102 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_97, i64 0, i32 4
        %tmp_5236 = load i64, ptr %tmp_5236_pointer_102, !noalias !2
        
        %tag_103 = extractvalue %Pos %v_r_3130_32_59_223_4998, 0
        %fields_104 = extractvalue %Pos %v_r_3130_32_59_223_4998, 1
        switch i64 %tag_103, label %label_105 [i64 1, label %label_128 i64 0, label %label_135]
    
    label_105:
        
        ret void
    
    label_110:
        
        ret void
    
    label_116:
        call ccc void @erasePositive(%Pos %v_r_2940_30_194_4827)
        
        %pair_111 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4734)
        %k_13_14_4_5117 = extractvalue <{%Resumption, %Stack}> %pair_111, 0
        %stack_112 = extractvalue <{%Resumption, %Stack}> %pair_111, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5117)
        
        %longLiteral_5363 = add i64 10, 0
        
        
        
        %pureApp_5364 = call ccc %Pos @boxInt_301(i64 %longLiteral_5363)
        
        
        
        %stackPointer_114 = call ccc %StackPointer @stackDeallocate(%Stack %stack_112, i64 24)
        %returnAddress_pointer_115 = getelementptr %FrameHeader, %StackPointer %stackPointer_114, i64 0, i32 0
        %returnAddress_113 = load %ReturnAddress, ptr %returnAddress_pointer_115, !noalias !2
        musttail call tailcc void %returnAddress_113(%Pos %pureApp_5364, %Stack %stack_112)
        ret void
    
    label_119:
        
        ret void
    
    label_125:
        call ccc void @erasePositive(%Pos %v_r_2940_30_194_4827)
        
        %pair_120 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4734)
        %k_13_14_4_5116 = extractvalue <{%Resumption, %Stack}> %pair_120, 0
        %stack_121 = extractvalue <{%Resumption, %Stack}> %pair_120, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5116)
        
        %longLiteral_5367 = add i64 10, 0
        
        
        
        %pureApp_5368 = call ccc %Pos @boxInt_301(i64 %longLiteral_5367)
        
        
        
        %stackPointer_123 = call ccc %StackPointer @stackDeallocate(%Stack %stack_121, i64 24)
        %returnAddress_pointer_124 = getelementptr %FrameHeader, %StackPointer %stackPointer_123, i64 0, i32 0
        %returnAddress_122 = load %ReturnAddress, ptr %returnAddress_pointer_124, !noalias !2
        musttail call tailcc void %returnAddress_122(%Pos %pureApp_5368, %Stack %stack_121)
        ret void
    
    label_126:
        
        %longLiteral_5370 = add i64 1, 0
        
        %pureApp_5369 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4784, i64 %longLiteral_5370)
        
        
        
        %longLiteral_5372 = add i64 10, 0
        
        %pureApp_5371 = call ccc i64 @infixMul_99(i64 %longLiteral_5372, i64 %acc_8_35_199_4771)
        
        
        
        %pureApp_5373 = call ccc i64 @toInt_2085(i64 %pureApp_5360)
        
        
        
        %pureApp_5374 = call ccc i64 @infixSub_105(i64 %pureApp_5373, i64 %tmp_5236)
        
        
        
        %pureApp_5375 = call ccc i64 @infixAdd_96(i64 %pureApp_5371, i64 %pureApp_5374)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4801(i64 %pureApp_5369, i64 %pureApp_5375, %Prompt %p_8_9_4734, %Pos %v_r_2940_30_194_4827, i64 %tmp_5236, %Stack %stack)
        ret void
    
    label_127:
        
        %intLiteral_5366 = add i64 57, 0
        
        %pureApp_5365 = call ccc %Pos @infixLte_2093(i64 %pureApp_5360, i64 %intLiteral_5366)
        
        
        
        %tag_117 = extractvalue %Pos %pureApp_5365, 0
        %fields_118 = extractvalue %Pos %pureApp_5365, 1
        switch i64 %tag_117, label %label_119 [i64 0, label %label_125 i64 1, label %label_126]
    
    label_128:
        %environment_106 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_coe_3948_46_73_237_4993_pointer_107 = getelementptr <{%Pos}>, %Environment %environment_106, i64 0, i32 0
        %v_coe_3948_46_73_237_4993 = load %Pos, ptr %v_coe_3948_46_73_237_4993_pointer_107, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3948_46_73_237_4993)
        call ccc void @eraseObject(%Object %fields_104)
        
        %pureApp_5360 = call ccc i64 @unboxChar_313(%Pos %v_coe_3948_46_73_237_4993)
        
        
        
        %intLiteral_5362 = add i64 48, 0
        
        %pureApp_5361 = call ccc %Pos @infixGte_2099(i64 %pureApp_5360, i64 %intLiteral_5362)
        
        
        
        %tag_108 = extractvalue %Pos %pureApp_5361, 0
        %fields_109 = extractvalue %Pos %pureApp_5361, 1
        switch i64 %tag_108, label %label_110 [i64 0, label %label_116 i64 1, label %label_127]
    
    label_135:
        %environment_129 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_y_3137_76_103_267_5358_pointer_130 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 0
        %v_y_3137_76_103_267_5358 = load %Pos, ptr %v_y_3137_76_103_267_5358_pointer_130, !noalias !2
        %v_y_3138_77_104_268_5359_pointer_131 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 1
        %v_y_3138_77_104_268_5359 = load %Pos, ptr %v_y_3138_77_104_268_5359_pointer_131, !noalias !2
        call ccc void @eraseObject(%Object %fields_104)
        call ccc void @erasePositive(%Pos %v_r_2940_30_194_4827)
        
        %stackPointer_133 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_134 = getelementptr %FrameHeader, %StackPointer %stackPointer_133, i64 0, i32 0
        %returnAddress_132 = load %ReturnAddress, ptr %returnAddress_pointer_134, !noalias !2
        musttail call tailcc void %returnAddress_132(i64 %acc_8_35_199_4771, %Stack %stack)
        ret void
}



define ccc void @sharer_141(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_142 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_4784_136_pointer_143 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_142, i64 0, i32 0
        %index_7_34_198_4784_136 = load i64, ptr %index_7_34_198_4784_136_pointer_143, !noalias !2
        %acc_8_35_199_4771_137_pointer_144 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_142, i64 0, i32 1
        %acc_8_35_199_4771_137 = load i64, ptr %acc_8_35_199_4771_137_pointer_144, !noalias !2
        %p_8_9_4734_138_pointer_145 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_142, i64 0, i32 2
        %p_8_9_4734_138 = load %Prompt, ptr %p_8_9_4734_138_pointer_145, !noalias !2
        %v_r_2940_30_194_4827_139_pointer_146 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_142, i64 0, i32 3
        %v_r_2940_30_194_4827_139 = load %Pos, ptr %v_r_2940_30_194_4827_139_pointer_146, !noalias !2
        %tmp_5236_140_pointer_147 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_142, i64 0, i32 4
        %tmp_5236_140 = load i64, ptr %tmp_5236_140_pointer_147, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2940_30_194_4827_139)
        call ccc void @shareFrames(%StackPointer %stackPointer_142)
        ret void
}



define ccc void @eraser_153(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_154 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_4784_148_pointer_155 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_154, i64 0, i32 0
        %index_7_34_198_4784_148 = load i64, ptr %index_7_34_198_4784_148_pointer_155, !noalias !2
        %acc_8_35_199_4771_149_pointer_156 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_154, i64 0, i32 1
        %acc_8_35_199_4771_149 = load i64, ptr %acc_8_35_199_4771_149_pointer_156, !noalias !2
        %p_8_9_4734_150_pointer_157 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_154, i64 0, i32 2
        %p_8_9_4734_150 = load %Prompt, ptr %p_8_9_4734_150_pointer_157, !noalias !2
        %v_r_2940_30_194_4827_151_pointer_158 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_154, i64 0, i32 3
        %v_r_2940_30_194_4827_151 = load %Pos, ptr %v_r_2940_30_194_4827_151_pointer_158, !noalias !2
        %tmp_5236_152_pointer_159 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_154, i64 0, i32 4
        %tmp_5236_152 = load i64, ptr %tmp_5236_152_pointer_159, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2940_30_194_4827_151)
        call ccc void @eraseFrames(%StackPointer %stackPointer_154)
        ret void
}



define tailcc void @returnAddress_170(%Pos %returned_5376, %Stack %stack) {
        
    entry:
        
        %stack_171 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_173 = call ccc %StackPointer @stackDeallocate(%Stack %stack_171, i64 24)
        %returnAddress_pointer_174 = getelementptr %FrameHeader, %StackPointer %stackPointer_173, i64 0, i32 0
        %returnAddress_172 = load %ReturnAddress, ptr %returnAddress_pointer_174, !noalias !2
        musttail call tailcc void %returnAddress_172(%Pos %returned_5376, %Stack %stack_171)
        ret void
}



define tailcc void @Exception_7_19_46_210_4871_clause_179(%Object %closure, %Pos %exc_8_20_47_211_4861, %Pos %msg_9_21_48_212_4778, %Stack %stack) {
        
    entry:
        
        %environment_180 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4995_pointer_181 = getelementptr <{%Prompt}>, %Environment %environment_180, i64 0, i32 0
        %p_6_18_45_209_4995 = load %Prompt, ptr %p_6_18_45_209_4995_pointer_181, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_182 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4995)
        %k_11_23_50_214_5059 = extractvalue <{%Resumption, %Stack}> %pair_182, 0
        %stack_183 = extractvalue <{%Resumption, %Stack}> %pair_182, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_5059)
        
        %fields_184 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_185 = call ccc %Environment @objectEnvironment(%Object %fields_184)
        %exc_8_20_47_211_4861_pointer_188 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4861, ptr %exc_8_20_47_211_4861_pointer_188, !noalias !2
        %msg_9_21_48_212_4778_pointer_189 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4778, ptr %msg_9_21_48_212_4778_pointer_189, !noalias !2
        %make_5377_temporary_190 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5377 = insertvalue %Pos %make_5377_temporary_190, %Object %fields_184, 1
        
        
        
        %stackPointer_192 = call ccc %StackPointer @stackDeallocate(%Stack %stack_183, i64 24)
        %returnAddress_pointer_193 = getelementptr %FrameHeader, %StackPointer %stackPointer_192, i64 0, i32 0
        %returnAddress_191 = load %ReturnAddress, ptr %returnAddress_pointer_193, !noalias !2
        musttail call tailcc void %returnAddress_191(%Pos %make_5377, %Stack %stack_183)
        ret void
}


@vtable_194 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4871_clause_179]


define ccc void @eraser_198(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4995_197_pointer_199 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4995_197 = load %Prompt, ptr %p_6_18_45_209_4995_197_pointer_199, !noalias !2
        ret void
}



define ccc void @eraser_206(%Environment %environment) {
        
    entry:
        
        %tmp_5238_205_pointer_207 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5238_205 = load %Pos, ptr %tmp_5238_205_pointer_207, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5238_205)
        ret void
}



define tailcc void @returnAddress_202(i64 %v_coe_3947_6_28_55_219_4848, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5378 = call ccc %Pos @boxChar_311(i64 %v_coe_3947_6_28_55_219_4848)
        
        
        
        %fields_203 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_204 = call ccc %Environment @objectEnvironment(%Object %fields_203)
        %tmp_5238_pointer_208 = getelementptr <{%Pos}>, %Environment %environment_204, i64 0, i32 0
        store %Pos %pureApp_5378, ptr %tmp_5238_pointer_208, !noalias !2
        %make_5379_temporary_209 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5379 = insertvalue %Pos %make_5379_temporary_209, %Object %fields_203, 1
        
        
        
        %stackPointer_211 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_212 = getelementptr %FrameHeader, %StackPointer %stackPointer_211, i64 0, i32 0
        %returnAddress_210 = load %ReturnAddress, ptr %returnAddress_pointer_212, !noalias !2
        musttail call tailcc void %returnAddress_210(%Pos %make_5379, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4801(i64 %index_7_34_198_4784, i64 %acc_8_35_199_4771, %Prompt %p_8_9_4734, %Pos %v_r_2940_30_194_4827, i64 %tmp_5236, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2940_30_194_4827)
        %stackPointer_160 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %index_7_34_198_4784_pointer_161 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_160, i64 0, i32 0
        store i64 %index_7_34_198_4784, ptr %index_7_34_198_4784_pointer_161, !noalias !2
        %acc_8_35_199_4771_pointer_162 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_160, i64 0, i32 1
        store i64 %acc_8_35_199_4771, ptr %acc_8_35_199_4771_pointer_162, !noalias !2
        %p_8_9_4734_pointer_163 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_160, i64 0, i32 2
        store %Prompt %p_8_9_4734, ptr %p_8_9_4734_pointer_163, !noalias !2
        %v_r_2940_30_194_4827_pointer_164 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_160, i64 0, i32 3
        store %Pos %v_r_2940_30_194_4827, ptr %v_r_2940_30_194_4827_pointer_164, !noalias !2
        %tmp_5236_pointer_165 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_160, i64 0, i32 4
        store i64 %tmp_5236, ptr %tmp_5236_pointer_165, !noalias !2
        %returnAddress_pointer_166 = getelementptr <{<{i64, i64, %Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 0
        %sharer_pointer_167 = getelementptr <{<{i64, i64, %Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 1
        %eraser_pointer_168 = getelementptr <{<{i64, i64, %Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 2
        store ptr @returnAddress_96, ptr %returnAddress_pointer_166, !noalias !2
        store ptr @sharer_141, ptr %sharer_pointer_167, !noalias !2
        store ptr @eraser_153, ptr %eraser_pointer_168, !noalias !2
        
        %stack_169 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4995 = call ccc %Prompt @currentPrompt(%Stack %stack_169)
        %stackPointer_175 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_176 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 0
        %sharer_pointer_177 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 1
        %eraser_pointer_178 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 2
        store ptr @returnAddress_170, ptr %returnAddress_pointer_176, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_177, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_178, !noalias !2
        
        %closure_195 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_196 = call ccc %Environment @objectEnvironment(%Object %closure_195)
        %p_6_18_45_209_4995_pointer_200 = getelementptr <{%Prompt}>, %Environment %environment_196, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4995, ptr %p_6_18_45_209_4995_pointer_200, !noalias !2
        %vtable_temporary_201 = insertvalue %Neg zeroinitializer, ptr @vtable_194, 0
        %Exception_7_19_46_210_4871 = insertvalue %Neg %vtable_temporary_201, %Object %closure_195, 1
        %stackPointer_213 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_214 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 0
        %sharer_pointer_215 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 1
        %eraser_pointer_216 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 2
        store ptr @returnAddress_202, ptr %returnAddress_pointer_214, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_215, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_216, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2940_30_194_4827, i64 %index_7_34_198_4784, %Neg %Exception_7_19_46_210_4871, %Stack %stack_169)
        ret void
}



define tailcc void @Exception_9_106_133_297_4968_clause_217(%Object %closure, %Pos %exception_10_107_134_298_5380, %Pos %msg_11_108_135_299_5381, %Stack %stack) {
        
    entry:
        
        %environment_218 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4734_pointer_219 = getelementptr <{%Prompt}>, %Environment %environment_218, i64 0, i32 0
        %p_8_9_4734 = load %Prompt, ptr %p_8_9_4734_pointer_219, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5380)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5381)
        
        %pair_220 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4734)
        %k_13_14_4_5193 = extractvalue <{%Resumption, %Stack}> %pair_220, 0
        %stack_221 = extractvalue <{%Resumption, %Stack}> %pair_220, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5193)
        
        %longLiteral_5382 = add i64 10, 0
        
        
        
        %pureApp_5383 = call ccc %Pos @boxInt_301(i64 %longLiteral_5382)
        
        
        
        %stackPointer_223 = call ccc %StackPointer @stackDeallocate(%Stack %stack_221, i64 24)
        %returnAddress_pointer_224 = getelementptr %FrameHeader, %StackPointer %stackPointer_223, i64 0, i32 0
        %returnAddress_222 = load %ReturnAddress, ptr %returnAddress_pointer_224, !noalias !2
        musttail call tailcc void %returnAddress_222(%Pos %pureApp_5383, %Stack %stack_221)
        ret void
}


@vtable_225 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4968_clause_217]


define tailcc void @returnAddress_236(i64 %v_coe_3952_22_131_158_322_5018, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5386 = call ccc %Pos @boxInt_301(i64 %v_coe_3952_22_131_158_322_5018)
        
        
        
        
        
        %pureApp_5387 = call ccc i64 @unboxInt_303(%Pos %pureApp_5386)
        
        
        
        %pureApp_5388 = call ccc %Pos @boxInt_301(i64 %pureApp_5387)
        
        
        
        %stackPointer_238 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_239 = getelementptr %FrameHeader, %StackPointer %stackPointer_238, i64 0, i32 0
        %returnAddress_237 = load %ReturnAddress, ptr %returnAddress_pointer_239, !noalias !2
        musttail call tailcc void %returnAddress_237(%Pos %pureApp_5388, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_248(i64 %v_r_3144_1_9_20_129_156_320_4935, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5392 = add i64 0, 0
        
        %pureApp_5391 = call ccc i64 @infixSub_105(i64 %longLiteral_5392, i64 %v_r_3144_1_9_20_129_156_320_4935)
        
        
        
        %stackPointer_250 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_251 = getelementptr %FrameHeader, %StackPointer %stackPointer_250, i64 0, i32 0
        %returnAddress_249 = load %ReturnAddress, ptr %returnAddress_pointer_251, !noalias !2
        musttail call tailcc void %returnAddress_249(i64 %pureApp_5391, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_231(i64 %v_r_3143_3_14_123_150_314_4955, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_232 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_4734_pointer_233 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_232, i64 0, i32 0
        %p_8_9_4734 = load %Prompt, ptr %p_8_9_4734_pointer_233, !noalias !2
        %v_r_2940_30_194_4827_pointer_234 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_232, i64 0, i32 1
        %v_r_2940_30_194_4827 = load %Pos, ptr %v_r_2940_30_194_4827_pointer_234, !noalias !2
        %tmp_5236_pointer_235 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_232, i64 0, i32 2
        %tmp_5236 = load i64, ptr %tmp_5236_pointer_235, !noalias !2
        
        %intLiteral_5385 = add i64 45, 0
        
        %pureApp_5384 = call ccc %Pos @infixEq_78(i64 %v_r_3143_3_14_123_150_314_4955, i64 %intLiteral_5385)
        
        
        %stackPointer_240 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_241 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 0
        %sharer_pointer_242 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 1
        %eraser_pointer_243 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 2
        store ptr @returnAddress_236, ptr %returnAddress_pointer_241, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_242, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_243, !noalias !2
        
        %tag_244 = extractvalue %Pos %pureApp_5384, 0
        %fields_245 = extractvalue %Pos %pureApp_5384, 1
        switch i64 %tag_244, label %label_246 [i64 0, label %label_247 i64 1, label %label_256]
    
    label_246:
        
        ret void
    
    label_247:
        
        %longLiteral_5389 = add i64 0, 0
        
        %longLiteral_5390 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4801(i64 %longLiteral_5389, i64 %longLiteral_5390, %Prompt %p_8_9_4734, %Pos %v_r_2940_30_194_4827, i64 %tmp_5236, %Stack %stack)
        ret void
    
    label_256:
        %stackPointer_252 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_253 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 0
        %sharer_pointer_254 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 1
        %eraser_pointer_255 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 2
        store ptr @returnAddress_248, ptr %returnAddress_pointer_253, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_254, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_255, !noalias !2
        
        %longLiteral_5393 = add i64 1, 0
        
        %longLiteral_5394 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4801(i64 %longLiteral_5393, i64 %longLiteral_5394, %Prompt %p_8_9_4734, %Pos %v_r_2940_30_194_4827, i64 %tmp_5236, %Stack %stack)
        ret void
}



define ccc void @sharer_260(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_261 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4734_257_pointer_262 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_261, i64 0, i32 0
        %p_8_9_4734_257 = load %Prompt, ptr %p_8_9_4734_257_pointer_262, !noalias !2
        %v_r_2940_30_194_4827_258_pointer_263 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_261, i64 0, i32 1
        %v_r_2940_30_194_4827_258 = load %Pos, ptr %v_r_2940_30_194_4827_258_pointer_263, !noalias !2
        %tmp_5236_259_pointer_264 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_261, i64 0, i32 2
        %tmp_5236_259 = load i64, ptr %tmp_5236_259_pointer_264, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2940_30_194_4827_258)
        call ccc void @shareFrames(%StackPointer %stackPointer_261)
        ret void
}



define ccc void @eraser_268(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_269 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4734_265_pointer_270 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_269, i64 0, i32 0
        %p_8_9_4734_265 = load %Prompt, ptr %p_8_9_4734_265_pointer_270, !noalias !2
        %v_r_2940_30_194_4827_266_pointer_271 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_269, i64 0, i32 1
        %v_r_2940_30_194_4827_266 = load %Pos, ptr %v_r_2940_30_194_4827_266_pointer_271, !noalias !2
        %tmp_5236_267_pointer_272 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_269, i64 0, i32 2
        %tmp_5236_267 = load i64, ptr %tmp_5236_267_pointer_272, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2940_30_194_4827_266)
        call ccc void @eraseFrames(%StackPointer %stackPointer_269)
        ret void
}



define tailcc void @returnAddress_93(%Pos %v_r_2940_30_194_4827, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_94 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4734_pointer_95 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_94, i64 0, i32 0
        %p_8_9_4734 = load %Prompt, ptr %p_8_9_4734_pointer_95, !noalias !2
        
        %intLiteral_5357 = add i64 48, 0
        
        %pureApp_5356 = call ccc i64 @toInt_2085(i64 %intLiteral_5357)
        
        
        
        %closure_226 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_227 = call ccc %Environment @objectEnvironment(%Object %closure_226)
        %p_8_9_4734_pointer_229 = getelementptr <{%Prompt}>, %Environment %environment_227, i64 0, i32 0
        store %Prompt %p_8_9_4734, ptr %p_8_9_4734_pointer_229, !noalias !2
        %vtable_temporary_230 = insertvalue %Neg zeroinitializer, ptr @vtable_225, 0
        %Exception_9_106_133_297_4968 = insertvalue %Neg %vtable_temporary_230, %Object %closure_226, 1
        call ccc void @sharePositive(%Pos %v_r_2940_30_194_4827)
        %stackPointer_273 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_4734_pointer_274 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_273, i64 0, i32 0
        store %Prompt %p_8_9_4734, ptr %p_8_9_4734_pointer_274, !noalias !2
        %v_r_2940_30_194_4827_pointer_275 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_273, i64 0, i32 1
        store %Pos %v_r_2940_30_194_4827, ptr %v_r_2940_30_194_4827_pointer_275, !noalias !2
        %tmp_5236_pointer_276 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_273, i64 0, i32 2
        store i64 %pureApp_5356, ptr %tmp_5236_pointer_276, !noalias !2
        %returnAddress_pointer_277 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 0
        %sharer_pointer_278 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 1
        %eraser_pointer_279 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 2
        store ptr @returnAddress_231, ptr %returnAddress_pointer_277, !noalias !2
        store ptr @sharer_260, ptr %sharer_pointer_278, !noalias !2
        store ptr @eraser_268, ptr %eraser_pointer_279, !noalias !2
        
        %longLiteral_5395 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2940_30_194_4827, i64 %longLiteral_5395, %Neg %Exception_9_106_133_297_4968, %Stack %stack)
        ret void
}



define ccc void @sharer_281(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_282 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4734_280_pointer_283 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_282, i64 0, i32 0
        %p_8_9_4734_280 = load %Prompt, ptr %p_8_9_4734_280_pointer_283, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_282)
        ret void
}



define ccc void @eraser_285(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_286 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4734_284_pointer_287 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_286, i64 0, i32 0
        %p_8_9_4734_284 = load %Prompt, ptr %p_8_9_4734_284_pointer_287, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_286)
        ret void
}


@utf8StringLiteral_5396.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_90(%Pos %v_r_2939_24_188_4763, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_91 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4734_pointer_92 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_91, i64 0, i32 0
        %p_8_9_4734 = load %Prompt, ptr %p_8_9_4734_pointer_92, !noalias !2
        %stackPointer_288 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4734_pointer_289 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_288, i64 0, i32 0
        store %Prompt %p_8_9_4734, ptr %p_8_9_4734_pointer_289, !noalias !2
        %returnAddress_pointer_290 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 0
        %sharer_pointer_291 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 1
        %eraser_pointer_292 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 2
        store ptr @returnAddress_93, ptr %returnAddress_pointer_290, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_291, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_292, !noalias !2
        
        %tag_293 = extractvalue %Pos %v_r_2939_24_188_4763, 0
        %fields_294 = extractvalue %Pos %v_r_2939_24_188_4763, 1
        switch i64 %tag_293, label %label_295 [i64 0, label %label_299 i64 1, label %label_305]
    
    label_295:
        
        ret void
    
    label_299:
        
        %utf8StringLiteral_5396 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5396.lit)
        
        %stackPointer_297 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_298 = getelementptr %FrameHeader, %StackPointer %stackPointer_297, i64 0, i32 0
        %returnAddress_296 = load %ReturnAddress, ptr %returnAddress_pointer_298, !noalias !2
        musttail call tailcc void %returnAddress_296(%Pos %utf8StringLiteral_5396, %Stack %stack)
        ret void
    
    label_305:
        %environment_300 = call ccc %Environment @objectEnvironment(%Object %fields_294)
        %v_y_3774_8_29_193_5029_pointer_301 = getelementptr <{%Pos}>, %Environment %environment_300, i64 0, i32 0
        %v_y_3774_8_29_193_5029 = load %Pos, ptr %v_y_3774_8_29_193_5029_pointer_301, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3774_8_29_193_5029)
        call ccc void @eraseObject(%Object %fields_294)
        
        %stackPointer_303 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_304 = getelementptr %FrameHeader, %StackPointer %stackPointer_303, i64 0, i32 0
        %returnAddress_302 = load %ReturnAddress, ptr %returnAddress_pointer_304, !noalias !2
        musttail call tailcc void %returnAddress_302(%Pos %v_y_3774_8_29_193_5029, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_87(%Pos %v_r_2938_13_177_4948, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_88 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4734_pointer_89 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_88, i64 0, i32 0
        %p_8_9_4734 = load %Prompt, ptr %p_8_9_4734_pointer_89, !noalias !2
        %stackPointer_308 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4734_pointer_309 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_308, i64 0, i32 0
        store %Prompt %p_8_9_4734, ptr %p_8_9_4734_pointer_309, !noalias !2
        %returnAddress_pointer_310 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 0
        %sharer_pointer_311 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 1
        %eraser_pointer_312 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 2
        store ptr @returnAddress_90, ptr %returnAddress_pointer_310, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_311, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_312, !noalias !2
        
        %tag_313 = extractvalue %Pos %v_r_2938_13_177_4948, 0
        %fields_314 = extractvalue %Pos %v_r_2938_13_177_4948, 1
        switch i64 %tag_313, label %label_315 [i64 0, label %label_320 i64 1, label %label_332]
    
    label_315:
        
        ret void
    
    label_320:
        
        %make_5397_temporary_316 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5397 = insertvalue %Pos %make_5397_temporary_316, %Object null, 1
        
        
        
        %stackPointer_318 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_319 = getelementptr %FrameHeader, %StackPointer %stackPointer_318, i64 0, i32 0
        %returnAddress_317 = load %ReturnAddress, ptr %returnAddress_pointer_319, !noalias !2
        musttail call tailcc void %returnAddress_317(%Pos %make_5397, %Stack %stack)
        ret void
    
    label_332:
        %environment_321 = call ccc %Environment @objectEnvironment(%Object %fields_314)
        %v_y_3283_10_21_185_4933_pointer_322 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 0
        %v_y_3283_10_21_185_4933 = load %Pos, ptr %v_y_3283_10_21_185_4933_pointer_322, !noalias !2
        %v_y_3284_11_22_186_4887_pointer_323 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 1
        %v_y_3284_11_22_186_4887 = load %Pos, ptr %v_y_3284_11_22_186_4887_pointer_323, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3283_10_21_185_4933)
        call ccc void @eraseObject(%Object %fields_314)
        
        %fields_324 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_325 = call ccc %Environment @objectEnvironment(%Object %fields_324)
        %v_y_3283_10_21_185_4933_pointer_327 = getelementptr <{%Pos}>, %Environment %environment_325, i64 0, i32 0
        store %Pos %v_y_3283_10_21_185_4933, ptr %v_y_3283_10_21_185_4933_pointer_327, !noalias !2
        %make_5398_temporary_328 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5398 = insertvalue %Pos %make_5398_temporary_328, %Object %fields_324, 1
        
        
        
        %stackPointer_330 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_331 = getelementptr %FrameHeader, %StackPointer %stackPointer_330, i64 0, i32 0
        %returnAddress_329 = load %ReturnAddress, ptr %returnAddress_pointer_331, !noalias !2
        musttail call tailcc void %returnAddress_329(%Pos %make_5398, %Stack %stack)
        ret void
}



define tailcc void @main_2858(%Stack %stack) {
        
    entry:
        
        %stackPointer_50 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_51 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 0
        %sharer_pointer_52 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 1
        %eraser_pointer_53 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_51, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_52, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_53, !noalias !2
        
        %stack_54 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4734 = call ccc %Prompt @currentPrompt(%Stack %stack_54)
        %stackPointer_64 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 24)
        %returnAddress_pointer_65 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 0
        %sharer_pointer_66 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 1
        %eraser_pointer_67 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 2
        store ptr @returnAddress_55, ptr %returnAddress_pointer_65, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_66, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_67, !noalias !2
        
        %pureApp_5352 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5354 = add i64 1, 0
        
        %pureApp_5353 = call ccc i64 @infixSub_105(i64 %pureApp_5352, i64 %longLiteral_5354)
        
        
        
        %make_5355_temporary_86 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5355 = insertvalue %Pos %make_5355_temporary_86, %Object null, 1
        
        
        %stackPointer_335 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 32)
        %p_8_9_4734_pointer_336 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_335, i64 0, i32 0
        store %Prompt %p_8_9_4734, ptr %p_8_9_4734_pointer_336, !noalias !2
        %returnAddress_pointer_337 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 0
        %sharer_pointer_338 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 1
        %eraser_pointer_339 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 2
        store ptr @returnAddress_87, ptr %returnAddress_pointer_337, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_338, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_339, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4865(i64 %pureApp_5353, %Pos %make_5355, %Stack %stack_54)
        ret void
}



define tailcc void @returnAddress_342(%Pos %returnValue_343, %Stack %stack) {
        
    entry:
        
        %stackPointer_344 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2917_4049_pointer_345 = getelementptr <{i64}>, %StackPointer %stackPointer_344, i64 0, i32 0
        %v_r_2917_4049 = load i64, ptr %v_r_2917_4049_pointer_345, !noalias !2
        %stackPointer_347 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_348 = getelementptr %FrameHeader, %StackPointer %stackPointer_347, i64 0, i32 0
        %returnAddress_346 = load %ReturnAddress, ptr %returnAddress_pointer_348, !noalias !2
        musttail call tailcc void %returnAddress_346(%Pos %returnValue_343, %Stack %stack)
        ret void
}



define ccc void @sharer_350(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_351 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2917_4049_349_pointer_352 = getelementptr <{i64}>, %StackPointer %stackPointer_351, i64 0, i32 0
        %v_r_2917_4049_349 = load i64, ptr %v_r_2917_4049_349_pointer_352, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_351)
        ret void
}



define ccc void @eraser_354(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_355 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2917_4049_353_pointer_356 = getelementptr <{i64}>, %StackPointer %stackPointer_355, i64 0, i32 0
        %v_r_2917_4049_353 = load i64, ptr %v_r_2917_4049_353_pointer_356, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_355)
        ret void
}



define tailcc void @loop_5_9_4345(i64 %i_6_10_4344, i64 %n_2856, %Pos %tmp_5203, %Pos %tmp_5265, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5286 = call ccc %Pos @infixLt_178(i64 %i_6_10_4344, i64 %n_2856)
        
        
        
        %tag_363 = extractvalue %Pos %pureApp_5286, 0
        %fields_364 = extractvalue %Pos %pureApp_5286, 1
        switch i64 %tag_363, label %label_365 [i64 0, label %label_370 i64 1, label %label_371]
    
    label_365:
        
        ret void
    
    label_370:
        call ccc void @erasePositive(%Pos %tmp_5203)
        call ccc void @erasePositive(%Pos %tmp_5265)
        
        %unitLiteral_5287_temporary_366 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5287 = insertvalue %Pos %unitLiteral_5287_temporary_366, %Object null, 1
        
        %stackPointer_368 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_369 = getelementptr %FrameHeader, %StackPointer %stackPointer_368, i64 0, i32 0
        %returnAddress_367 = load %ReturnAddress, ptr %returnAddress_pointer_369, !noalias !2
        musttail call tailcc void %returnAddress_367(%Pos %unitLiteral_5287, %Stack %stack)
        ret void
    
    label_371:
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        call ccc void @sharePositive(%Pos %tmp_5265)
        %pureApp_5288 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5203, i64 %i_6_10_4344, %Pos %tmp_5265)
        call ccc void @erasePositive(%Pos %pureApp_5288)
        
        
        
        %longLiteral_5290 = add i64 1, 0
        
        %pureApp_5289 = call ccc i64 @infixAdd_96(i64 %i_6_10_4344, i64 %longLiteral_5290)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_4345(i64 %pureApp_5289, i64 %n_2856, %Pos %tmp_5203, %Pos %tmp_5265, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_401(%Pos %returnValue_402, %Stack %stack) {
        
    entry:
        
        %stackPointer_403 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_5210_pointer_404 = getelementptr <{i64}>, %StackPointer %stackPointer_403, i64 0, i32 0
        %tmp_5210 = load i64, ptr %tmp_5210_pointer_404, !noalias !2
        %stackPointer_406 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_407 = getelementptr %FrameHeader, %StackPointer %stackPointer_406, i64 0, i32 0
        %returnAddress_405 = load %ReturnAddress, ptr %returnAddress_pointer_407, !noalias !2
        musttail call tailcc void %returnAddress_405(%Pos %returnValue_402, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_453(%Pos %v_whileThen_2930_44_4402, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_454 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %count_2862_pointer_455 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_454, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_455, !noalias !2
        %tmp_5203_pointer_456 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_454, i64 0, i32 1
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_456, !noalias !2
        %i_13_4364_pointer_457 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_454, i64 0, i32 2
        %i_13_4364 = load %Reference, ptr %i_13_4364_pointer_457, !noalias !2
        %tmp_5209_pointer_458 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_454, i64 0, i32 3
        %tmp_5209 = load i64, ptr %tmp_5209_pointer_458, !noalias !2
        call ccc void @erasePositive(%Pos %v_whileThen_2930_44_4402)
        
        
        musttail call tailcc void @b_whileLoop_2922_14_4366(%Reference %count_2862, %Pos %tmp_5203, %Reference %i_13_4364, i64 %tmp_5209, %Stack %stack)
        ret void
}



define ccc void @sharer_463(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_464 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %count_2862_459_pointer_465 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_464, i64 0, i32 0
        %count_2862_459 = load %Reference, ptr %count_2862_459_pointer_465, !noalias !2
        %tmp_5203_460_pointer_466 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_464, i64 0, i32 1
        %tmp_5203_460 = load %Pos, ptr %tmp_5203_460_pointer_466, !noalias !2
        %i_13_4364_461_pointer_467 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_464, i64 0, i32 2
        %i_13_4364_461 = load %Reference, ptr %i_13_4364_461_pointer_467, !noalias !2
        %tmp_5209_462_pointer_468 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_464, i64 0, i32 3
        %tmp_5209_462 = load i64, ptr %tmp_5209_462_pointer_468, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5203_460)
        call ccc void @shareFrames(%StackPointer %stackPointer_464)
        ret void
}



define ccc void @eraser_473(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_474 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %count_2862_469_pointer_475 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_474, i64 0, i32 0
        %count_2862_469 = load %Reference, ptr %count_2862_469_pointer_475, !noalias !2
        %tmp_5203_470_pointer_476 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_474, i64 0, i32 1
        %tmp_5203_470 = load %Pos, ptr %tmp_5203_470_pointer_476, !noalias !2
        %i_13_4364_471_pointer_477 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_474, i64 0, i32 2
        %i_13_4364_471 = load %Reference, ptr %i_13_4364_471_pointer_477, !noalias !2
        %tmp_5209_472_pointer_478 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_474, i64 0, i32 3
        %tmp_5209_472 = load i64, ptr %tmp_5209_472_pointer_478, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5203_470)
        call ccc void @eraseFrames(%StackPointer %stackPointer_474)
        ret void
}



define tailcc void @returnAddress_447(i64 %v_r_2928_42_4371, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_448 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %count_2862_pointer_449 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_448, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_449, !noalias !2
        %tmp_5203_pointer_450 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_448, i64 0, i32 1
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_450, !noalias !2
        %i_13_4364_pointer_451 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_448, i64 0, i32 2
        %i_13_4364 = load %Reference, ptr %i_13_4364_pointer_451, !noalias !2
        %tmp_5209_pointer_452 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_448, i64 0, i32 3
        %tmp_5209 = load i64, ptr %tmp_5209_pointer_452, !noalias !2
        
        %longLiteral_5321 = add i64 1, 0
        
        %pureApp_5320 = call ccc i64 @infixSub_105(i64 %v_r_2928_42_4371, i64 %longLiteral_5321)
        
        
        %stackPointer_479 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %count_2862_pointer_480 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_479, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_480, !noalias !2
        %tmp_5203_pointer_481 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_479, i64 0, i32 1
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_481, !noalias !2
        %i_13_4364_pointer_482 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_479, i64 0, i32 2
        store %Reference %i_13_4364, ptr %i_13_4364_pointer_482, !noalias !2
        %tmp_5209_pointer_483 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_479, i64 0, i32 3
        store i64 %tmp_5209, ptr %tmp_5209_pointer_483, !noalias !2
        %returnAddress_pointer_484 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_479, i64 0, i32 1, i32 0
        %sharer_pointer_485 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_479, i64 0, i32 1, i32 1
        %eraser_pointer_486 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_479, i64 0, i32 1, i32 2
        store ptr @returnAddress_453, ptr %returnAddress_pointer_484, !noalias !2
        store ptr @sharer_463, ptr %sharer_pointer_485, !noalias !2
        store ptr @eraser_473, ptr %eraser_pointer_486, !noalias !2
        
        %i_13_4364pointer_487 = call ccc ptr @getVarPointer(%Reference %i_13_4364, %Stack %stack)
        %i_13_4364_old_488 = load i64, ptr %i_13_4364pointer_487, !noalias !2
        store i64 %pureApp_5320, ptr %i_13_4364pointer_487, !noalias !2
        
        %put_5322_temporary_489 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5322 = insertvalue %Pos %put_5322_temporary_489, %Object null, 1
        
        %stackPointer_491 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_492 = getelementptr %FrameHeader, %StackPointer %stackPointer_491, i64 0, i32 0
        %returnAddress_490 = load %ReturnAddress, ptr %returnAddress_pointer_492, !noalias !2
        musttail call tailcc void %returnAddress_490(%Pos %put_5322, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_441(i64 %v_r_2926_30_4376, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_442 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %count_2862_pointer_443 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_442, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_443, !noalias !2
        %tmp_5203_pointer_444 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_442, i64 0, i32 1
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_444, !noalias !2
        %i_13_4364_pointer_445 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_442, i64 0, i32 2
        %i_13_4364 = load %Reference, ptr %i_13_4364_pointer_445, !noalias !2
        %tmp_5209_pointer_446 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_442, i64 0, i32 3
        %tmp_5209 = load i64, ptr %tmp_5209_pointer_446, !noalias !2
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %pureApp_5312 = call ccc %Pos @unsafeGet_2487(%Pos %tmp_5203, i64 %tmp_5209)
        
        
        
        %pureApp_5313 = call ccc i64 @unboxInt_303(%Pos %pureApp_5312)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %pureApp_5314 = call ccc %Pos @unsafeGet_2487(%Pos %tmp_5203, i64 %v_r_2926_30_4376)
        
        
        
        %pureApp_5315 = call ccc i64 @unboxInt_303(%Pos %pureApp_5314)
        
        
        
        %pureApp_5316 = call ccc %Pos @boxInt_301(i64 %pureApp_5315)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %pureApp_5317 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5203, i64 %tmp_5209, %Pos %pureApp_5316)
        call ccc void @erasePositive(%Pos %pureApp_5317)
        
        
        
        %pureApp_5318 = call ccc %Pos @boxInt_301(i64 %pureApp_5313)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %pureApp_5319 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5203, i64 %v_r_2926_30_4376, %Pos %pureApp_5318)
        call ccc void @erasePositive(%Pos %pureApp_5319)
        
        
        %stackPointer_501 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %count_2862_pointer_502 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_501, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_502, !noalias !2
        %tmp_5203_pointer_503 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_501, i64 0, i32 1
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_503, !noalias !2
        %i_13_4364_pointer_504 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_501, i64 0, i32 2
        store %Reference %i_13_4364, ptr %i_13_4364_pointer_504, !noalias !2
        %tmp_5209_pointer_505 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_501, i64 0, i32 3
        store i64 %tmp_5209, ptr %tmp_5209_pointer_505, !noalias !2
        %returnAddress_pointer_506 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_501, i64 0, i32 1, i32 0
        %sharer_pointer_507 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_501, i64 0, i32 1, i32 1
        %eraser_pointer_508 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_501, i64 0, i32 1, i32 2
        store ptr @returnAddress_447, ptr %returnAddress_pointer_506, !noalias !2
        store ptr @sharer_463, ptr %sharer_pointer_507, !noalias !2
        store ptr @eraser_473, ptr %eraser_pointer_508, !noalias !2
        
        %get_5323_pointer_509 = call ccc ptr @getVarPointer(%Reference %i_13_4364, %Stack %stack)
        %i_13_4364_old_510 = load i64, ptr %get_5323_pointer_509, !noalias !2
        %get_5323 = load i64, ptr %get_5323_pointer_509, !noalias !2
        
        %stackPointer_512 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_513 = getelementptr %FrameHeader, %StackPointer %stackPointer_512, i64 0, i32 0
        %returnAddress_511 = load %ReturnAddress, ptr %returnAddress_pointer_513, !noalias !2
        musttail call tailcc void %returnAddress_511(i64 %get_5323, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_435(%Pos %v_r_2925_29_4399, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_436 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %count_2862_pointer_437 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_436, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_437, !noalias !2
        %tmp_5203_pointer_438 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_436, i64 0, i32 1
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_438, !noalias !2
        %i_13_4364_pointer_439 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_436, i64 0, i32 2
        %i_13_4364 = load %Reference, ptr %i_13_4364_pointer_439, !noalias !2
        %tmp_5209_pointer_440 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_436, i64 0, i32 3
        %tmp_5209 = load i64, ptr %tmp_5209_pointer_440, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2925_29_4399)
        %stackPointer_522 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %count_2862_pointer_523 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_522, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_523, !noalias !2
        %tmp_5203_pointer_524 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_522, i64 0, i32 1
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_524, !noalias !2
        %i_13_4364_pointer_525 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_522, i64 0, i32 2
        store %Reference %i_13_4364, ptr %i_13_4364_pointer_525, !noalias !2
        %tmp_5209_pointer_526 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_522, i64 0, i32 3
        store i64 %tmp_5209, ptr %tmp_5209_pointer_526, !noalias !2
        %returnAddress_pointer_527 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_522, i64 0, i32 1, i32 0
        %sharer_pointer_528 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_522, i64 0, i32 1, i32 1
        %eraser_pointer_529 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_522, i64 0, i32 1, i32 2
        store ptr @returnAddress_441, ptr %returnAddress_pointer_527, !noalias !2
        store ptr @sharer_463, ptr %sharer_pointer_528, !noalias !2
        store ptr @eraser_473, ptr %eraser_pointer_529, !noalias !2
        
        %get_5324_pointer_530 = call ccc ptr @getVarPointer(%Reference %i_13_4364, %Stack %stack)
        %i_13_4364_old_531 = load i64, ptr %get_5324_pointer_530, !noalias !2
        %get_5324 = load i64, ptr %get_5324_pointer_530, !noalias !2
        
        %stackPointer_533 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_534 = getelementptr %FrameHeader, %StackPointer %stackPointer_533, i64 0, i32 0
        %returnAddress_532 = load %ReturnAddress, ptr %returnAddress_pointer_534, !noalias !2
        musttail call tailcc void %returnAddress_532(i64 %get_5324, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_429(i64 %v_r_2923_17_4361, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_430 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %count_2862_pointer_431 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_430, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_431, !noalias !2
        %tmp_5203_pointer_432 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_430, i64 0, i32 1
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_432, !noalias !2
        %i_13_4364_pointer_433 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_430, i64 0, i32 2
        %i_13_4364 = load %Reference, ptr %i_13_4364_pointer_433, !noalias !2
        %tmp_5209_pointer_434 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_430, i64 0, i32 3
        %tmp_5209 = load i64, ptr %tmp_5209_pointer_434, !noalias !2
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %pureApp_5304 = call ccc %Pos @unsafeGet_2487(%Pos %tmp_5203, i64 %tmp_5209)
        
        
        
        %pureApp_5305 = call ccc i64 @unboxInt_303(%Pos %pureApp_5304)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %pureApp_5306 = call ccc %Pos @unsafeGet_2487(%Pos %tmp_5203, i64 %v_r_2923_17_4361)
        
        
        
        %pureApp_5307 = call ccc i64 @unboxInt_303(%Pos %pureApp_5306)
        
        
        
        %pureApp_5308 = call ccc %Pos @boxInt_301(i64 %pureApp_5307)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %pureApp_5309 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5203, i64 %tmp_5209, %Pos %pureApp_5308)
        call ccc void @erasePositive(%Pos %pureApp_5309)
        
        
        
        %pureApp_5310 = call ccc %Pos @boxInt_301(i64 %pureApp_5305)
        
        
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %pureApp_5311 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5203, i64 %v_r_2923_17_4361, %Pos %pureApp_5310)
        call ccc void @erasePositive(%Pos %pureApp_5311)
        
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %stackPointer_543 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %count_2862_pointer_544 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_543, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_544, !noalias !2
        %tmp_5203_pointer_545 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_543, i64 0, i32 1
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_545, !noalias !2
        %i_13_4364_pointer_546 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_543, i64 0, i32 2
        store %Reference %i_13_4364, ptr %i_13_4364_pointer_546, !noalias !2
        %tmp_5209_pointer_547 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_543, i64 0, i32 3
        store i64 %tmp_5209, ptr %tmp_5209_pointer_547, !noalias !2
        %returnAddress_pointer_548 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_543, i64 0, i32 1, i32 0
        %sharer_pointer_549 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_543, i64 0, i32 1, i32 1
        %eraser_pointer_550 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_543, i64 0, i32 1, i32 2
        store ptr @returnAddress_435, ptr %returnAddress_pointer_548, !noalias !2
        store ptr @sharer_463, ptr %sharer_pointer_549, !noalias !2
        store ptr @eraser_473, ptr %eraser_pointer_550, !noalias !2
        
        
        
        musttail call tailcc void @permute_worker_3_4377(i64 %tmp_5209, %Reference %count_2862, %Pos %tmp_5203, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_415(i64 %v_r_2931_15_4359, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_416 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %count_2862_pointer_417 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_416, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_417, !noalias !2
        %tmp_5203_pointer_418 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_416, i64 0, i32 1
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_418, !noalias !2
        %i_13_4364_pointer_419 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_416, i64 0, i32 2
        %i_13_4364 = load %Reference, ptr %i_13_4364_pointer_419, !noalias !2
        %tmp_5209_pointer_420 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_416, i64 0, i32 3
        %tmp_5209 = load i64, ptr %tmp_5209_pointer_420, !noalias !2
        
        %longLiteral_5302 = add i64 0, 0
        
        %pureApp_5301 = call ccc %Pos @infixGte_187(i64 %v_r_2931_15_4359, i64 %longLiteral_5302)
        
        
        
        %tag_421 = extractvalue %Pos %pureApp_5301, 0
        %fields_422 = extractvalue %Pos %pureApp_5301, 1
        switch i64 %tag_421, label %label_423 [i64 0, label %label_428 i64 1, label %label_572]
    
    label_423:
        
        ret void
    
    label_428:
        call ccc void @erasePositive(%Pos %tmp_5203)
        
        %unitLiteral_5303_temporary_424 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5303 = insertvalue %Pos %unitLiteral_5303_temporary_424, %Object null, 1
        
        %stackPointer_426 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_427 = getelementptr %FrameHeader, %StackPointer %stackPointer_426, i64 0, i32 0
        %returnAddress_425 = load %ReturnAddress, ptr %returnAddress_pointer_427, !noalias !2
        musttail call tailcc void %returnAddress_425(%Pos %unitLiteral_5303, %Stack %stack)
        ret void
    
    label_572:
        %stackPointer_559 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %count_2862_pointer_560 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_559, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_560, !noalias !2
        %tmp_5203_pointer_561 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_559, i64 0, i32 1
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_561, !noalias !2
        %i_13_4364_pointer_562 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_559, i64 0, i32 2
        store %Reference %i_13_4364, ptr %i_13_4364_pointer_562, !noalias !2
        %tmp_5209_pointer_563 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_559, i64 0, i32 3
        store i64 %tmp_5209, ptr %tmp_5209_pointer_563, !noalias !2
        %returnAddress_pointer_564 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_559, i64 0, i32 1, i32 0
        %sharer_pointer_565 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_559, i64 0, i32 1, i32 1
        %eraser_pointer_566 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_559, i64 0, i32 1, i32 2
        store ptr @returnAddress_429, ptr %returnAddress_pointer_564, !noalias !2
        store ptr @sharer_463, ptr %sharer_pointer_565, !noalias !2
        store ptr @eraser_473, ptr %eraser_pointer_566, !noalias !2
        
        %get_5325_pointer_567 = call ccc ptr @getVarPointer(%Reference %i_13_4364, %Stack %stack)
        %i_13_4364_old_568 = load i64, ptr %get_5325_pointer_567, !noalias !2
        %get_5325 = load i64, ptr %get_5325_pointer_567, !noalias !2
        
        %stackPointer_570 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_571 = getelementptr %FrameHeader, %StackPointer %stackPointer_570, i64 0, i32 0
        %returnAddress_569 = load %ReturnAddress, ptr %returnAddress_pointer_571, !noalias !2
        musttail call tailcc void %returnAddress_569(i64 %get_5325, %Stack %stack)
        ret void
}



define tailcc void @b_whileLoop_2922_14_4366(%Reference %count_2862, %Pos %tmp_5203, %Reference %i_13_4364, i64 %tmp_5209, %Stack %stack) {
        
    entry:
        
        %stackPointer_581 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %count_2862_pointer_582 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_581, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_582, !noalias !2
        %tmp_5203_pointer_583 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_581, i64 0, i32 1
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_583, !noalias !2
        %i_13_4364_pointer_584 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_581, i64 0, i32 2
        store %Reference %i_13_4364, ptr %i_13_4364_pointer_584, !noalias !2
        %tmp_5209_pointer_585 = getelementptr <{%Reference, %Pos, %Reference, i64}>, %StackPointer %stackPointer_581, i64 0, i32 3
        store i64 %tmp_5209, ptr %tmp_5209_pointer_585, !noalias !2
        %returnAddress_pointer_586 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_581, i64 0, i32 1, i32 0
        %sharer_pointer_587 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_581, i64 0, i32 1, i32 1
        %eraser_pointer_588 = getelementptr <{<{%Reference, %Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_581, i64 0, i32 1, i32 2
        store ptr @returnAddress_415, ptr %returnAddress_pointer_586, !noalias !2
        store ptr @sharer_463, ptr %sharer_pointer_587, !noalias !2
        store ptr @eraser_473, ptr %eraser_pointer_588, !noalias !2
        
        %get_5326_pointer_589 = call ccc ptr @getVarPointer(%Reference %i_13_4364, %Stack %stack)
        %i_13_4364_old_590 = load i64, ptr %get_5326_pointer_589, !noalias !2
        %get_5326 = load i64, ptr %get_5326_pointer_589, !noalias !2
        
        %stackPointer_592 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_593 = getelementptr %FrameHeader, %StackPointer %stackPointer_592, i64 0, i32 0
        %returnAddress_591 = load %ReturnAddress, ptr %returnAddress_pointer_593, !noalias !2
        musttail call tailcc void %returnAddress_591(i64 %get_5326, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_395(%Pos %v_r_2920_11_4396, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_396 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %count_2862_pointer_397 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_396, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_397, !noalias !2
        %n_4_4391_pointer_398 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_396, i64 0, i32 1
        %n_4_4391 = load i64, ptr %n_4_4391_pointer_398, !noalias !2
        %tmp_5203_pointer_399 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_396, i64 0, i32 2
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_399, !noalias !2
        %tmp_5209_pointer_400 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_396, i64 0, i32 3
        %tmp_5209 = load i64, ptr %tmp_5209_pointer_400, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2920_11_4396)
        
        %longLiteral_5299 = add i64 1, 0
        
        %pureApp_5298 = call ccc i64 @infixSub_105(i64 %n_4_4391, i64 %longLiteral_5299)
        
        
        %i_13_4364 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_410 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_5210_pointer_411 = getelementptr <{i64}>, %StackPointer %stackPointer_410, i64 0, i32 0
        store i64 %pureApp_5298, ptr %tmp_5210_pointer_411, !noalias !2
        %returnAddress_pointer_412 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_410, i64 0, i32 1, i32 0
        %sharer_pointer_413 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_410, i64 0, i32 1, i32 1
        %eraser_pointer_414 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_410, i64 0, i32 1, i32 2
        store ptr @returnAddress_401, ptr %returnAddress_pointer_412, !noalias !2
        store ptr @sharer_350, ptr %sharer_pointer_413, !noalias !2
        store ptr @eraser_354, ptr %eraser_pointer_414, !noalias !2
        
        
        musttail call tailcc void @b_whileLoop_2922_14_4366(%Reference %count_2862, %Pos %tmp_5203, %Reference %i_13_4364, i64 %tmp_5209, %Stack %stack)
        ret void
}



define ccc void @sharer_598(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_599 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %count_2862_594_pointer_600 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_599, i64 0, i32 0
        %count_2862_594 = load %Reference, ptr %count_2862_594_pointer_600, !noalias !2
        %n_4_4391_595_pointer_601 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_599, i64 0, i32 1
        %n_4_4391_595 = load i64, ptr %n_4_4391_595_pointer_601, !noalias !2
        %tmp_5203_596_pointer_602 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_599, i64 0, i32 2
        %tmp_5203_596 = load %Pos, ptr %tmp_5203_596_pointer_602, !noalias !2
        %tmp_5209_597_pointer_603 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_599, i64 0, i32 3
        %tmp_5209_597 = load i64, ptr %tmp_5209_597_pointer_603, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5203_596)
        call ccc void @shareFrames(%StackPointer %stackPointer_599)
        ret void
}



define ccc void @eraser_608(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_609 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %count_2862_604_pointer_610 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_609, i64 0, i32 0
        %count_2862_604 = load %Reference, ptr %count_2862_604_pointer_610, !noalias !2
        %n_4_4391_605_pointer_611 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_609, i64 0, i32 1
        %n_4_4391_605 = load i64, ptr %n_4_4391_605_pointer_611, !noalias !2
        %tmp_5203_606_pointer_612 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_609, i64 0, i32 2
        %tmp_5203_606 = load %Pos, ptr %tmp_5203_606_pointer_612, !noalias !2
        %tmp_5209_607_pointer_613 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_609, i64 0, i32 3
        %tmp_5209_607 = load i64, ptr %tmp_5209_607_pointer_613, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5203_606)
        call ccc void @eraseFrames(%StackPointer %stackPointer_609)
        ret void
}



define tailcc void @returnAddress_382(%Pos %v_r_2919_7_4395, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_383 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %n_4_4391_pointer_384 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_383, i64 0, i32 0
        %n_4_4391 = load i64, ptr %n_4_4391_pointer_384, !noalias !2
        %count_2862_pointer_385 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_383, i64 0, i32 1
        %count_2862 = load %Reference, ptr %count_2862_pointer_385, !noalias !2
        %tmp_5203_pointer_386 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_383, i64 0, i32 2
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_386, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2919_7_4395)
        
        %longLiteral_5294 = add i64 0, 0
        
        %pureApp_5293 = call ccc %Pos @infixNeq_75(i64 %n_4_4391, i64 %longLiteral_5294)
        
        
        
        %tag_387 = extractvalue %Pos %pureApp_5293, 0
        %fields_388 = extractvalue %Pos %pureApp_5293, 1
        switch i64 %tag_387, label %label_389 [i64 0, label %label_394 i64 1, label %label_622]
    
    label_389:
        
        ret void
    
    label_394:
        call ccc void @erasePositive(%Pos %tmp_5203)
        
        %unitLiteral_5295_temporary_390 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5295 = insertvalue %Pos %unitLiteral_5295_temporary_390, %Object null, 1
        
        %stackPointer_392 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_393 = getelementptr %FrameHeader, %StackPointer %stackPointer_392, i64 0, i32 0
        %returnAddress_391 = load %ReturnAddress, ptr %returnAddress_pointer_393, !noalias !2
        musttail call tailcc void %returnAddress_391(%Pos %unitLiteral_5295, %Stack %stack)
        ret void
    
    label_622:
        
        %longLiteral_5297 = add i64 1, 0
        
        %pureApp_5296 = call ccc i64 @infixSub_105(i64 %n_4_4391, i64 %longLiteral_5297)
        
        
        call ccc void @sharePositive(%Pos %tmp_5203)
        %stackPointer_614 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %count_2862_pointer_615 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_614, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_615, !noalias !2
        %n_4_4391_pointer_616 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_614, i64 0, i32 1
        store i64 %n_4_4391, ptr %n_4_4391_pointer_616, !noalias !2
        %tmp_5203_pointer_617 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_614, i64 0, i32 2
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_617, !noalias !2
        %tmp_5209_pointer_618 = getelementptr <{%Reference, i64, %Pos, i64}>, %StackPointer %stackPointer_614, i64 0, i32 3
        store i64 %pureApp_5296, ptr %tmp_5209_pointer_618, !noalias !2
        %returnAddress_pointer_619 = getelementptr <{<{%Reference, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_614, i64 0, i32 1, i32 0
        %sharer_pointer_620 = getelementptr <{<{%Reference, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_614, i64 0, i32 1, i32 1
        %eraser_pointer_621 = getelementptr <{<{%Reference, i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_614, i64 0, i32 1, i32 2
        store ptr @returnAddress_395, ptr %returnAddress_pointer_619, !noalias !2
        store ptr @sharer_598, ptr %sharer_pointer_620, !noalias !2
        store ptr @eraser_608, ptr %eraser_pointer_621, !noalias !2
        
        
        
        musttail call tailcc void @permute_worker_3_4377(i64 %pureApp_5296, %Reference %count_2862, %Pos %tmp_5203, %Stack %stack)
        ret void
}



define ccc void @sharer_626(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_627 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %n_4_4391_623_pointer_628 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_627, i64 0, i32 0
        %n_4_4391_623 = load i64, ptr %n_4_4391_623_pointer_628, !noalias !2
        %count_2862_624_pointer_629 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_627, i64 0, i32 1
        %count_2862_624 = load %Reference, ptr %count_2862_624_pointer_629, !noalias !2
        %tmp_5203_625_pointer_630 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_627, i64 0, i32 2
        %tmp_5203_625 = load %Pos, ptr %tmp_5203_625_pointer_630, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5203_625)
        call ccc void @shareFrames(%StackPointer %stackPointer_627)
        ret void
}



define ccc void @eraser_634(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_635 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %n_4_4391_631_pointer_636 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_635, i64 0, i32 0
        %n_4_4391_631 = load i64, ptr %n_4_4391_631_pointer_636, !noalias !2
        %count_2862_632_pointer_637 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_635, i64 0, i32 1
        %count_2862_632 = load %Reference, ptr %count_2862_632_pointer_637, !noalias !2
        %tmp_5203_633_pointer_638 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_635, i64 0, i32 2
        %tmp_5203_633 = load %Pos, ptr %tmp_5203_633_pointer_638, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5203_633)
        call ccc void @eraseFrames(%StackPointer %stackPointer_635)
        ret void
}



define tailcc void @returnAddress_377(i64 %v_r_2918_5_4374, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_378 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %count_2862_pointer_379 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_378, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_379, !noalias !2
        %n_4_4391_pointer_380 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_378, i64 0, i32 1
        %n_4_4391 = load i64, ptr %n_4_4391_pointer_380, !noalias !2
        %tmp_5203_pointer_381 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_378, i64 0, i32 2
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_381, !noalias !2
        
        %longLiteral_5292 = add i64 1, 0
        
        %pureApp_5291 = call ccc i64 @infixAdd_96(i64 %v_r_2918_5_4374, i64 %longLiteral_5292)
        
        
        %stackPointer_639 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %n_4_4391_pointer_640 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_639, i64 0, i32 0
        store i64 %n_4_4391, ptr %n_4_4391_pointer_640, !noalias !2
        %count_2862_pointer_641 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_639, i64 0, i32 1
        store %Reference %count_2862, ptr %count_2862_pointer_641, !noalias !2
        %tmp_5203_pointer_642 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_639, i64 0, i32 2
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_642, !noalias !2
        %returnAddress_pointer_643 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_639, i64 0, i32 1, i32 0
        %sharer_pointer_644 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_639, i64 0, i32 1, i32 1
        %eraser_pointer_645 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_639, i64 0, i32 1, i32 2
        store ptr @returnAddress_382, ptr %returnAddress_pointer_643, !noalias !2
        store ptr @sharer_626, ptr %sharer_pointer_644, !noalias !2
        store ptr @eraser_634, ptr %eraser_pointer_645, !noalias !2
        
        %count_2862pointer_646 = call ccc ptr @getVarPointer(%Reference %count_2862, %Stack %stack)
        %count_2862_old_647 = load i64, ptr %count_2862pointer_646, !noalias !2
        store i64 %pureApp_5291, ptr %count_2862pointer_646, !noalias !2
        
        %put_5327_temporary_648 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5327 = insertvalue %Pos %put_5327_temporary_648, %Object null, 1
        
        %stackPointer_650 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_651 = getelementptr %FrameHeader, %StackPointer %stackPointer_650, i64 0, i32 0
        %returnAddress_649 = load %ReturnAddress, ptr %returnAddress_pointer_651, !noalias !2
        musttail call tailcc void %returnAddress_649(%Pos %put_5327, %Stack %stack)
        ret void
}



define ccc void @sharer_655(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_656 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %count_2862_652_pointer_657 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_656, i64 0, i32 0
        %count_2862_652 = load %Reference, ptr %count_2862_652_pointer_657, !noalias !2
        %n_4_4391_653_pointer_658 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_656, i64 0, i32 1
        %n_4_4391_653 = load i64, ptr %n_4_4391_653_pointer_658, !noalias !2
        %tmp_5203_654_pointer_659 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_656, i64 0, i32 2
        %tmp_5203_654 = load %Pos, ptr %tmp_5203_654_pointer_659, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5203_654)
        call ccc void @shareFrames(%StackPointer %stackPointer_656)
        ret void
}



define ccc void @eraser_663(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_664 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %count_2862_660_pointer_665 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_664, i64 0, i32 0
        %count_2862_660 = load %Reference, ptr %count_2862_660_pointer_665, !noalias !2
        %n_4_4391_661_pointer_666 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_664, i64 0, i32 1
        %n_4_4391_661 = load i64, ptr %n_4_4391_661_pointer_666, !noalias !2
        %tmp_5203_662_pointer_667 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_664, i64 0, i32 2
        %tmp_5203_662 = load %Pos, ptr %tmp_5203_662_pointer_667, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5203_662)
        call ccc void @eraseFrames(%StackPointer %stackPointer_664)
        ret void
}



define tailcc void @permute_worker_3_4377(i64 %n_4_4391, %Reference %count_2862, %Pos %tmp_5203, %Stack %stack) {
        
    entry:
        
        %stackPointer_668 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %count_2862_pointer_669 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_668, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_669, !noalias !2
        %n_4_4391_pointer_670 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_668, i64 0, i32 1
        store i64 %n_4_4391, ptr %n_4_4391_pointer_670, !noalias !2
        %tmp_5203_pointer_671 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_668, i64 0, i32 2
        store %Pos %tmp_5203, ptr %tmp_5203_pointer_671, !noalias !2
        %returnAddress_pointer_672 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_668, i64 0, i32 1, i32 0
        %sharer_pointer_673 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_668, i64 0, i32 1, i32 1
        %eraser_pointer_674 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_668, i64 0, i32 1, i32 2
        store ptr @returnAddress_377, ptr %returnAddress_pointer_672, !noalias !2
        store ptr @sharer_655, ptr %sharer_pointer_673, !noalias !2
        store ptr @eraser_663, ptr %eraser_pointer_674, !noalias !2
        
        %get_5328_pointer_675 = call ccc ptr @getVarPointer(%Reference %count_2862, %Stack %stack)
        %count_2862_old_676 = load i64, ptr %get_5328_pointer_675, !noalias !2
        %get_5328 = load i64, ptr %get_5328_pointer_675, !noalias !2
        
        %stackPointer_678 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_679 = getelementptr %FrameHeader, %StackPointer %stackPointer_678, i64 0, i32 0
        %returnAddress_677 = load %ReturnAddress, ptr %returnAddress_pointer_679, !noalias !2
        musttail call tailcc void %returnAddress_677(i64 %get_5328, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_680(%Pos %v_r_2935_5329, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_681 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %count_2862_pointer_682 = getelementptr <{%Reference}>, %StackPointer %stackPointer_681, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_682, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2935_5329)
        
        %get_5330_pointer_683 = call ccc ptr @getVarPointer(%Reference %count_2862, %Stack %stack)
        %count_2862_old_684 = load i64, ptr %get_5330_pointer_683, !noalias !2
        %get_5330 = load i64, ptr %get_5330_pointer_683, !noalias !2
        
        %stackPointer_686 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_687 = getelementptr %FrameHeader, %StackPointer %stackPointer_686, i64 0, i32 0
        %returnAddress_685 = load %ReturnAddress, ptr %returnAddress_pointer_687, !noalias !2
        musttail call tailcc void %returnAddress_685(i64 %get_5330, %Stack %stack)
        ret void
}



define ccc void @sharer_689(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_690 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %count_2862_688_pointer_691 = getelementptr <{%Reference}>, %StackPointer %stackPointer_690, i64 0, i32 0
        %count_2862_688 = load %Reference, ptr %count_2862_688_pointer_691, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_690)
        ret void
}



define ccc void @eraser_693(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_694 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %count_2862_692_pointer_695 = getelementptr <{%Reference}>, %StackPointer %stackPointer_694, i64 0, i32 0
        %count_2862_692 = load %Reference, ptr %count_2862_692_pointer_695, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_694)
        ret void
}



define tailcc void @returnAddress_372(%Pos %v_r_2950_15_4354, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_373 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %count_2862_pointer_374 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_373, i64 0, i32 0
        %count_2862 = load %Reference, ptr %count_2862_pointer_374, !noalias !2
        %n_2856_pointer_375 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_373, i64 0, i32 1
        %n_2856 = load i64, ptr %n_2856_pointer_375, !noalias !2
        %tmp_5203_pointer_376 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_373, i64 0, i32 2
        %tmp_5203 = load %Pos, ptr %tmp_5203_pointer_376, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2950_15_4354)
        %stackPointer_696 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %count_2862_pointer_697 = getelementptr <{%Reference}>, %StackPointer %stackPointer_696, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_697, !noalias !2
        %returnAddress_pointer_698 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_696, i64 0, i32 1, i32 0
        %sharer_pointer_699 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_696, i64 0, i32 1, i32 1
        %eraser_pointer_700 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_696, i64 0, i32 1, i32 2
        store ptr @returnAddress_680, ptr %returnAddress_pointer_698, !noalias !2
        store ptr @sharer_689, ptr %sharer_pointer_699, !noalias !2
        store ptr @eraser_693, ptr %eraser_pointer_700, !noalias !2
        
        
        
        musttail call tailcc void @permute_worker_3_4377(i64 %n_2856, %Reference %count_2862, %Pos %tmp_5203, %Stack %stack)
        ret void
}



define tailcc void @run_2857(i64 %n_2856, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5281 = add i64 0, 0
        
        
        
        %pair_340 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, ptr @global)
        %temporaryStack_5282 = extractvalue <{%Resumption, %Stack}> %pair_340, 0
        %stack_341 = extractvalue <{%Resumption, %Stack}> %pair_340, 1
        %count_2862 = call ccc %Reference @newReference(%Stack %stack_341)
        %stackPointer_357 = call ccc %StackPointer @stackAllocate(%Stack %stack_341, i64 32)
        %v_r_2917_4049_pointer_358 = getelementptr <{i64}>, %StackPointer %stackPointer_357, i64 0, i32 0
        store i64 %longLiteral_5281, ptr %v_r_2917_4049_pointer_358, !noalias !2
        %returnAddress_pointer_359 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_357, i64 0, i32 1, i32 0
        %sharer_pointer_360 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_357, i64 0, i32 1, i32 1
        %eraser_pointer_361 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_357, i64 0, i32 1, i32 2
        store ptr @returnAddress_342, ptr %returnAddress_pointer_359, !noalias !2
        store ptr @sharer_350, ptr %sharer_pointer_360, !noalias !2
        store ptr @eraser_354, ptr %eraser_pointer_361, !noalias !2
        
        %stack_362 = call ccc %Stack @resume(%Resumption %temporaryStack_5282, %Stack %stack_341)
        
        %longLiteral_5284 = add i64 0, 0
        
        %pureApp_5283 = call ccc %Pos @boxInt_301(i64 %longLiteral_5284)
        
        
        
        %pureApp_5285 = call ccc %Pos @allocate_2473(i64 %n_2856)
        
        
        call ccc void @sharePositive(%Pos %pureApp_5285)
        %stackPointer_707 = call ccc %StackPointer @stackAllocate(%Stack %stack_362, i64 64)
        %count_2862_pointer_708 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_707, i64 0, i32 0
        store %Reference %count_2862, ptr %count_2862_pointer_708, !noalias !2
        %n_2856_pointer_709 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_707, i64 0, i32 1
        store i64 %n_2856, ptr %n_2856_pointer_709, !noalias !2
        %tmp_5203_pointer_710 = getelementptr <{%Reference, i64, %Pos}>, %StackPointer %stackPointer_707, i64 0, i32 2
        store %Pos %pureApp_5285, ptr %tmp_5203_pointer_710, !noalias !2
        %returnAddress_pointer_711 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_707, i64 0, i32 1, i32 0
        %sharer_pointer_712 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_707, i64 0, i32 1, i32 1
        %eraser_pointer_713 = getelementptr <{<{%Reference, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_707, i64 0, i32 1, i32 2
        store ptr @returnAddress_372, ptr %returnAddress_pointer_711, !noalias !2
        store ptr @sharer_655, ptr %sharer_pointer_712, !noalias !2
        store ptr @eraser_663, ptr %eraser_pointer_713, !noalias !2
        
        %longLiteral_5331 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_4345(i64 %longLiteral_5331, i64 %n_2856, %Pos %pureApp_5285, %Pos %pureApp_5283, %Stack %stack_362)
        ret void
}


@utf8StringLiteral_5272.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5274.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5277.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_714(%Pos %v_r_3212_4010, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_715 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_716 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_715, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_716, !noalias !2
        %index_2107_pointer_717 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_715, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_717, !noalias !2
        %Exception_2362_pointer_718 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_715, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_718, !noalias !2
        
        %tag_719 = extractvalue %Pos %v_r_3212_4010, 0
        %fields_720 = extractvalue %Pos %v_r_3212_4010, 1
        switch i64 %tag_719, label %label_721 [i64 0, label %label_725 i64 1, label %label_731]
    
    label_721:
        
        ret void
    
    label_725:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5268 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_723 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_724 = getelementptr %FrameHeader, %StackPointer %stackPointer_723, i64 0, i32 0
        %returnAddress_722 = load %ReturnAddress, ptr %returnAddress_pointer_724, !noalias !2
        musttail call tailcc void %returnAddress_722(i64 %pureApp_5268, %Stack %stack)
        ret void
    
    label_731:
        
        %make_5269_temporary_726 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5269 = insertvalue %Pos %make_5269_temporary_726, %Object null, 1
        
        
        
        %pureApp_5270 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5272 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5272.lit)
        
        %pureApp_5271 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5272, %Pos %pureApp_5270)
        
        
        
        %utf8StringLiteral_5274 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5274.lit)
        
        %pureApp_5273 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5271, %Pos %utf8StringLiteral_5274)
        
        
        
        %pureApp_5275 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5273, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5277 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5277.lit)
        
        %pureApp_5276 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5275, %Pos %utf8StringLiteral_5277)
        
        
        
        %vtable_727 = extractvalue %Neg %Exception_2362, 0
        %closure_728 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_729 = getelementptr ptr, ptr %vtable_727, i64 0
        %functionPointer_730 = load ptr, ptr %functionPointer_pointer_729, !noalias !2
        musttail call tailcc void %functionPointer_730(%Object %closure_728, %Pos %make_5269, %Pos %pureApp_5276, %Stack %stack)
        ret void
}



define ccc void @sharer_735(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_736 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_732_pointer_737 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_736, i64 0, i32 0
        %str_2106_732 = load %Pos, ptr %str_2106_732_pointer_737, !noalias !2
        %index_2107_733_pointer_738 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_736, i64 0, i32 1
        %index_2107_733 = load i64, ptr %index_2107_733_pointer_738, !noalias !2
        %Exception_2362_734_pointer_739 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_736, i64 0, i32 2
        %Exception_2362_734 = load %Neg, ptr %Exception_2362_734_pointer_739, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_732)
        call ccc void @shareNegative(%Neg %Exception_2362_734)
        call ccc void @shareFrames(%StackPointer %stackPointer_736)
        ret void
}



define ccc void @eraser_743(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_744 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_740_pointer_745 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_744, i64 0, i32 0
        %str_2106_740 = load %Pos, ptr %str_2106_740_pointer_745, !noalias !2
        %index_2107_741_pointer_746 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_744, i64 0, i32 1
        %index_2107_741 = load i64, ptr %index_2107_741_pointer_746, !noalias !2
        %Exception_2362_742_pointer_747 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_744, i64 0, i32 2
        %Exception_2362_742 = load %Neg, ptr %Exception_2362_742_pointer_747, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_740)
        call ccc void @eraseNegative(%Neg %Exception_2362_742)
        call ccc void @eraseFrames(%StackPointer %stackPointer_744)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5267 = add i64 0, 0
        
        %pureApp_5266 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5267)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_748 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_749 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_748, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_749, !noalias !2
        %index_2107_pointer_750 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_748, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_750, !noalias !2
        %Exception_2362_pointer_751 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_748, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_751, !noalias !2
        %returnAddress_pointer_752 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_748, i64 0, i32 1, i32 0
        %sharer_pointer_753 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_748, i64 0, i32 1, i32 1
        %eraser_pointer_754 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_748, i64 0, i32 1, i32 2
        store ptr @returnAddress_714, ptr %returnAddress_pointer_752, !noalias !2
        store ptr @sharer_735, ptr %sharer_pointer_753, !noalias !2
        store ptr @eraser_743, ptr %eraser_pointer_754, !noalias !2
        
        %tag_755 = extractvalue %Pos %pureApp_5266, 0
        %fields_756 = extractvalue %Pos %pureApp_5266, 1
        switch i64 %tag_755, label %label_757 [i64 0, label %label_761 i64 1, label %label_766]
    
    label_757:
        
        ret void
    
    label_761:
        
        %pureApp_5278 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5279 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5278)
        
        
        
        %stackPointer_759 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_760 = getelementptr %FrameHeader, %StackPointer %stackPointer_759, i64 0, i32 0
        %returnAddress_758 = load %ReturnAddress, ptr %returnAddress_pointer_760, !noalias !2
        musttail call tailcc void %returnAddress_758(%Pos %pureApp_5279, %Stack %stack)
        ret void
    
    label_766:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5280_temporary_762 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5280 = insertvalue %Pos %booleanLiteral_5280_temporary_762, %Object null, 1
        
        %stackPointer_764 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_765 = getelementptr %FrameHeader, %StackPointer %stackPointer_764, i64 0, i32 0
        %returnAddress_763 = load %ReturnAddress, ptr %returnAddress_pointer_765, !noalias !2
        musttail call tailcc void %returnAddress_763(%Pos %booleanLiteral_5280, %Stack %stack)
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
        
        musttail call tailcc void @main_2858(%Stack %stack)
        ret void
}
