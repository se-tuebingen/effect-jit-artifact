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



define tailcc void @returnAddress_8(i64 %v_r_2521_50_4581, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_9 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %xs_2_4579_pointer_10 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_9, i64 0, i32 0
        %xs_2_4579 = load %Pos, ptr %xs_2_4579_pointer_10, !noalias !2
        %a_5_4568_pointer_11 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_9, i64 0, i32 1
        %a_5_4568 = load i64, ptr %a_5_4568_pointer_11, !noalias !2
        %i_4_4578_pointer_12 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_9, i64 0, i32 2
        %i_4_4578 = load i64, ptr %i_4_4578_pointer_12, !noalias !2
        
        %longLiteral_4744 = add i64 1, 0
        
        %pureApp_4743 = call ccc i64 @infixSub_105(i64 %i_4_4578, i64 %longLiteral_4744)
        
        
        
        %pureApp_4745 = call ccc i64 @infixAdd_96(i64 %a_5_4568, i64 %v_r_2521_50_4581)
        
        
        
        
        
        
        musttail call tailcc void @loop_3_4599(i64 %pureApp_4743, i64 %pureApp_4745, %Pos %xs_2_4579, %Stack %stack)
        ret void
}



define ccc void @sharer_16(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_17 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %xs_2_4579_13_pointer_18 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 0
        %xs_2_4579_13 = load %Pos, ptr %xs_2_4579_13_pointer_18, !noalias !2
        %a_5_4568_14_pointer_19 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 1
        %a_5_4568_14 = load i64, ptr %a_5_4568_14_pointer_19, !noalias !2
        %i_4_4578_15_pointer_20 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 2
        %i_4_4578_15 = load i64, ptr %i_4_4578_15_pointer_20, !noalias !2
        call ccc void @sharePositive(%Pos %xs_2_4579_13)
        call ccc void @shareFrames(%StackPointer %stackPointer_17)
        ret void
}



define ccc void @eraser_24(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_25 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %xs_2_4579_21_pointer_26 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_25, i64 0, i32 0
        %xs_2_4579_21 = load %Pos, ptr %xs_2_4579_21_pointer_26, !noalias !2
        %a_5_4568_22_pointer_27 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_25, i64 0, i32 1
        %a_5_4568_22 = load i64, ptr %a_5_4568_22_pointer_27, !noalias !2
        %i_4_4578_23_pointer_28 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_25, i64 0, i32 2
        %i_4_4578_23 = load i64, ptr %i_4_4578_23_pointer_28, !noalias !2
        call ccc void @erasePositive(%Pos %xs_2_4579_21)
        call ccc void @eraseFrames(%StackPointer %stackPointer_25)
        ret void
}



define tailcc void @returnAddress_37(i64 %returned_4746, %Stack %stack) {
        
    entry:
        
        %stack_38 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_40 = call ccc %StackPointer @stackDeallocate(%Stack %stack_38, i64 24)
        %returnAddress_pointer_41 = getelementptr %FrameHeader, %StackPointer %stackPointer_40, i64 0, i32 0
        %returnAddress_39 = load %ReturnAddress, ptr %returnAddress_pointer_41, !noalias !2
        musttail call tailcc void %returnAddress_39(i64 %returned_4746, %Stack %stack_38)
        ret void
}



define ccc void @sharer_42(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_43 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_44(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_45 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_45)
        ret void
}



define tailcc void @returnAddress_63(i64 %v_r_2504_7_7_32_43_48_4594, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_64 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_4705_pointer_65 = getelementptr <{i64}>, %StackPointer %stackPointer_64, i64 0, i32 0
        %tmp_4705 = load i64, ptr %tmp_4705_pointer_65, !noalias !2
        
        %pureApp_4751 = call ccc i64 @infixMul_99(i64 %tmp_4705, i64 %v_r_2504_7_7_32_43_48_4594)
        
        
        
        %stackPointer_67 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_68 = getelementptr %FrameHeader, %StackPointer %stackPointer_67, i64 0, i32 0
        %returnAddress_66 = load %ReturnAddress, ptr %returnAddress_pointer_68, !noalias !2
        musttail call tailcc void %returnAddress_66(i64 %pureApp_4751, %Stack %stack)
        ret void
}



define ccc void @sharer_70(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_71 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_4705_69_pointer_72 = getelementptr <{i64}>, %StackPointer %stackPointer_71, i64 0, i32 0
        %tmp_4705_69 = load i64, ptr %tmp_4705_69_pointer_72, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_71)
        ret void
}



define ccc void @eraser_74(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_75 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_4705_73_pointer_76 = getelementptr <{i64}>, %StackPointer %stackPointer_75, i64 0, i32 0
        %tmp_4705_73 = load i64, ptr %tmp_4705_73_pointer_76, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_75)
        ret void
}



define tailcc void @returnAddress_83(%Pos %v_coe_3446_4_4_29_40_45_4588, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4752 = call ccc i64 @unboxInt_303(%Pos %v_coe_3446_4_4_29_40_45_4588)
        
        
        
        %stackPointer_85 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_86 = getelementptr %FrameHeader, %StackPointer %stackPointer_85, i64 0, i32 0
        %returnAddress_84 = load %ReturnAddress, ptr %returnAddress_pointer_86, !noalias !2
        musttail call tailcc void %returnAddress_84(i64 %pureApp_4752, %Stack %stack)
        ret void
}



define ccc void @sharer_87(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_88 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_88)
        ret void
}



define ccc void @eraser_89(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_90 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_90)
        ret void
}



define tailcc void @product_worker_4_9_14_4591(%Pos %xs_5_10_15_4597, %Prompt %p_3_8_4583, %Stack %stack) {
        
    entry:
        
        
        %tag_50 = extractvalue %Pos %xs_5_10_15_4597, 0
        %fields_51 = extractvalue %Pos %xs_5_10_15_4597, 1
        switch i64 %tag_50, label %label_52 [i64 0, label %label_56 i64 1, label %label_101]
    
    label_52:
        
        ret void
    
    label_56:
        
        %longLiteral_4747 = add i64 0, 0
        
        %stackPointer_54 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_55 = getelementptr %FrameHeader, %StackPointer %stackPointer_54, i64 0, i32 0
        %returnAddress_53 = load %ReturnAddress, ptr %returnAddress_pointer_55, !noalias !2
        musttail call tailcc void %returnAddress_53(i64 %longLiteral_4747, %Stack %stack)
        ret void
    
    label_62:
        
        ret void
    
    label_82:
        %stackPointer_77 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_4705_pointer_78 = getelementptr <{i64}>, %StackPointer %stackPointer_77, i64 0, i32 0
        store i64 %pureApp_4748, ptr %tmp_4705_pointer_78, !noalias !2
        %returnAddress_pointer_79 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_77, i64 0, i32 1, i32 0
        %sharer_pointer_80 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_77, i64 0, i32 1, i32 1
        %eraser_pointer_81 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_77, i64 0, i32 1, i32 2
        store ptr @returnAddress_63, ptr %returnAddress_pointer_79, !noalias !2
        store ptr @sharer_70, ptr %sharer_pointer_80, !noalias !2
        store ptr @eraser_74, ptr %eraser_pointer_81, !noalias !2
        
        
        
        musttail call tailcc void @product_worker_4_9_14_4591(%Pos %v_coe_3448_17_24_29_4592, %Prompt %p_3_8_4583, %Stack %stack)
        ret void
    
    label_100:
        call ccc void @erasePositive(%Pos %v_coe_3448_17_24_29_4592)
        %stackPointer_91 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_92 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_91, i64 0, i32 1, i32 0
        %sharer_pointer_93 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_91, i64 0, i32 1, i32 1
        %eraser_pointer_94 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_91, i64 0, i32 1, i32 2
        store ptr @returnAddress_83, ptr %returnAddress_pointer_92, !noalias !2
        store ptr @sharer_87, ptr %sharer_pointer_93, !noalias !2
        store ptr @eraser_89, ptr %eraser_pointer_94, !noalias !2
        
        %pair_95 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_3_8_4583)
        %k_4_39_44_4753 = extractvalue <{%Resumption, %Stack}> %pair_95, 0
        %stack_96 = extractvalue <{%Resumption, %Stack}> %pair_95, 1
        call ccc void @eraseResumption(%Resumption %k_4_39_44_4753)
        
        %longLiteral_4754 = add i64 0, 0
        
        %stackPointer_98 = call ccc %StackPointer @stackDeallocate(%Stack %stack_96, i64 24)
        %returnAddress_pointer_99 = getelementptr %FrameHeader, %StackPointer %stackPointer_98, i64 0, i32 0
        %returnAddress_97 = load %ReturnAddress, ptr %returnAddress_pointer_99, !noalias !2
        musttail call tailcc void %returnAddress_97(i64 %longLiteral_4754, %Stack %stack_96)
        ret void
    
    label_101:
        %environment_57 = call ccc %Environment @objectEnvironment(%Object %fields_51)
        %v_coe_3447_16_23_28_4571_pointer_58 = getelementptr <{%Pos, %Pos}>, %Environment %environment_57, i64 0, i32 0
        %v_coe_3447_16_23_28_4571 = load %Pos, ptr %v_coe_3447_16_23_28_4571_pointer_58, !noalias !2
        %v_coe_3448_17_24_29_4592_pointer_59 = getelementptr <{%Pos, %Pos}>, %Environment %environment_57, i64 0, i32 1
        %v_coe_3448_17_24_29_4592 = load %Pos, ptr %v_coe_3448_17_24_29_4592_pointer_59, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3447_16_23_28_4571)
        call ccc void @sharePositive(%Pos %v_coe_3448_17_24_29_4592)
        call ccc void @eraseObject(%Object %fields_51)
        
        %pureApp_4748 = call ccc i64 @unboxInt_303(%Pos %v_coe_3447_16_23_28_4571)
        
        
        
        %longLiteral_4750 = add i64 0, 0
        
        %pureApp_4749 = call ccc %Pos @infixEq_72(i64 %pureApp_4748, i64 %longLiteral_4750)
        
        
        
        %tag_60 = extractvalue %Pos %pureApp_4749, 0
        %fields_61 = extractvalue %Pos %pureApp_4749, 1
        switch i64 %tag_60, label %label_62 [i64 0, label %label_82 i64 1, label %label_100]
}



define tailcc void @loop_3_4599(i64 %i_4_4578, i64 %a_5_4568, %Pos %xs_2_4579, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4742 = add i64 0, 0
        
        %pureApp_4741 = call ccc %Pos @infixEq_72(i64 %i_4_4578, i64 %longLiteral_4742)
        
        
        
        %tag_5 = extractvalue %Pos %pureApp_4741, 0
        %fields_6 = extractvalue %Pos %pureApp_4741, 1
        switch i64 %tag_5, label %label_7 [i64 0, label %label_102 i64 1, label %label_106]
    
    label_7:
        
        ret void
    
    label_102:
        call ccc void @sharePositive(%Pos %xs_2_4579)
        %stackPointer_29 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %xs_2_4579_pointer_30 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_29, i64 0, i32 0
        store %Pos %xs_2_4579, ptr %xs_2_4579_pointer_30, !noalias !2
        %a_5_4568_pointer_31 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_29, i64 0, i32 1
        store i64 %a_5_4568, ptr %a_5_4568_pointer_31, !noalias !2
        %i_4_4578_pointer_32 = getelementptr <{%Pos, i64, i64}>, %StackPointer %stackPointer_29, i64 0, i32 2
        store i64 %i_4_4578, ptr %i_4_4578_pointer_32, !noalias !2
        %returnAddress_pointer_33 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 0
        %sharer_pointer_34 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 1
        %eraser_pointer_35 = getelementptr <{<{%Pos, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_29, i64 0, i32 1, i32 2
        store ptr @returnAddress_8, ptr %returnAddress_pointer_33, !noalias !2
        store ptr @sharer_16, ptr %sharer_pointer_34, !noalias !2
        store ptr @eraser_24, ptr %eraser_pointer_35, !noalias !2
        
        %stack_36 = call ccc %Stack @reset(%Stack %stack)
        %p_3_8_4583 = call ccc %Prompt @currentPrompt(%Stack %stack_36)
        %stackPointer_46 = call ccc %StackPointer @stackAllocate(%Stack %stack_36, i64 24)
        %returnAddress_pointer_47 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 0
        %sharer_pointer_48 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 1
        %eraser_pointer_49 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 2
        store ptr @returnAddress_37, ptr %returnAddress_pointer_47, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_48, !noalias !2
        store ptr @eraser_44, ptr %eraser_pointer_49, !noalias !2
        
        
        
        musttail call tailcc void @product_worker_4_9_14_4591(%Pos %xs_2_4579, %Prompt %p_3_8_4583, %Stack %stack_36)
        ret void
    
    label_106:
        call ccc void @erasePositive(%Pos %xs_2_4579)
        
        %stackPointer_104 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_105 = getelementptr %FrameHeader, %StackPointer %stackPointer_104, i64 0, i32 0
        %returnAddress_103 = load %ReturnAddress, ptr %returnAddress_pointer_105, !noalias !2
        musttail call tailcc void %returnAddress_103(i64 %a_5_4568, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_107(i64 %r_2455, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4755 = call ccc %Pos @show_14(i64 %r_2455)
        
        
        
        %pureApp_4756 = call ccc %Pos @println_1(%Pos %pureApp_4755)
        
        
        
        %stackPointer_109 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_110 = getelementptr %FrameHeader, %StackPointer %stackPointer_109, i64 0, i32 0
        %returnAddress_108 = load %ReturnAddress, ptr %returnAddress_pointer_110, !noalias !2
        musttail call tailcc void %returnAddress_108(%Pos %pureApp_4756, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_2(%Pos %xs_2_4579, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_3 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_4716_pointer_4 = getelementptr <{i64}>, %StackPointer %stackPointer_3, i64 0, i32 0
        %tmp_4716 = load i64, ptr %tmp_4716_pointer_4, !noalias !2
        %stackPointer_111 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_112 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_111, i64 0, i32 1, i32 0
        %sharer_pointer_113 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_111, i64 0, i32 1, i32 1
        %eraser_pointer_114 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_111, i64 0, i32 1, i32 2
        store ptr @returnAddress_107, ptr %returnAddress_pointer_112, !noalias !2
        store ptr @sharer_87, ptr %sharer_pointer_113, !noalias !2
        store ptr @eraser_89, ptr %eraser_pointer_114, !noalias !2
        
        %longLiteral_4757 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @loop_3_4599(i64 %tmp_4716, i64 %longLiteral_4757, %Pos %xs_2_4579, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3456_3520, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4740 = call ccc i64 @unboxInt_303(%Pos %v_coe_3456_3520)
        
        
        %stackPointer_117 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_4716_pointer_118 = getelementptr <{i64}>, %StackPointer %stackPointer_117, i64 0, i32 0
        store i64 %pureApp_4740, ptr %tmp_4716_pointer_118, !noalias !2
        %returnAddress_pointer_119 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_117, i64 0, i32 1, i32 0
        %sharer_pointer_120 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_117, i64 0, i32 1, i32 1
        %eraser_pointer_121 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_117, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_119, !noalias !2
        store ptr @sharer_70, ptr %sharer_pointer_120, !noalias !2
        store ptr @eraser_74, ptr %eraser_pointer_121, !noalias !2
        
        %longLiteral_4758 = add i64 1000, 0
        
        
        
        musttail call tailcc void @enumerate_2436(i64 %longLiteral_4758, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_127(%Pos %returned_4759, %Stack %stack) {
        
    entry:
        
        %stack_128 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_130 = call ccc %StackPointer @stackDeallocate(%Stack %stack_128, i64 24)
        %returnAddress_pointer_131 = getelementptr %FrameHeader, %StackPointer %stackPointer_130, i64 0, i32 0
        %returnAddress_129 = load %ReturnAddress, ptr %returnAddress_pointer_131, !noalias !2
        musttail call tailcc void %returnAddress_129(%Pos %returned_4759, %Stack %stack_128)
        ret void
}



define ccc void @eraser_143(%Environment %environment) {
        
    entry:
        
        %tmp_4677_141_pointer_144 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4677_141 = load %Pos, ptr %tmp_4677_141_pointer_144, !noalias !2
        %acc_3_3_5_169_4460_142_pointer_145 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4460_142 = load %Pos, ptr %acc_3_3_5_169_4460_142_pointer_145, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4677_141)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4460_142)
        ret void
}



define tailcc void @toList_1_1_3_167_4378(i64 %start_2_2_4_168_4276, %Pos %acc_3_3_5_169_4460, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4761 = add i64 1, 0
        
        %pureApp_4760 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4276, i64 %longLiteral_4761)
        
        
        
        %tag_136 = extractvalue %Pos %pureApp_4760, 0
        %fields_137 = extractvalue %Pos %pureApp_4760, 1
        switch i64 %tag_136, label %label_138 [i64 0, label %label_149 i64 1, label %label_153]
    
    label_138:
        
        ret void
    
    label_149:
        
        %pureApp_4762 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4276)
        
        
        
        %longLiteral_4764 = add i64 1, 0
        
        %pureApp_4763 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4276, i64 %longLiteral_4764)
        
        
        
        %fields_139 = call ccc %Object @newObject(ptr @eraser_143, i64 32)
        %environment_140 = call ccc %Environment @objectEnvironment(%Object %fields_139)
        %tmp_4677_pointer_146 = getelementptr <{%Pos, %Pos}>, %Environment %environment_140, i64 0, i32 0
        store %Pos %pureApp_4762, ptr %tmp_4677_pointer_146, !noalias !2
        %acc_3_3_5_169_4460_pointer_147 = getelementptr <{%Pos, %Pos}>, %Environment %environment_140, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4460, ptr %acc_3_3_5_169_4460_pointer_147, !noalias !2
        %make_4765_temporary_148 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4765 = insertvalue %Pos %make_4765_temporary_148, %Object %fields_139, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4378(i64 %pureApp_4763, %Pos %make_4765, %Stack %stack)
        ret void
    
    label_153:
        
        %stackPointer_151 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_152 = getelementptr %FrameHeader, %StackPointer %stackPointer_151, i64 0, i32 0
        %returnAddress_150 = load %ReturnAddress, ptr %returnAddress_pointer_152, !noalias !2
        musttail call tailcc void %returnAddress_150(%Pos %acc_3_3_5_169_4460, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_164(%Pos %v_r_2611_32_59_223_4486, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_165 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %p_8_9_4184_pointer_166 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_165, i64 0, i32 0
        %p_8_9_4184 = load %Prompt, ptr %p_8_9_4184_pointer_166, !noalias !2
        %index_7_34_198_4223_pointer_167 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_165, i64 0, i32 1
        %index_7_34_198_4223 = load i64, ptr %index_7_34_198_4223_pointer_167, !noalias !2
        %acc_8_35_199_4494_pointer_168 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_165, i64 0, i32 2
        %acc_8_35_199_4494 = load i64, ptr %acc_8_35_199_4494_pointer_168, !noalias !2
        %tmp_4684_pointer_169 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_165, i64 0, i32 3
        %tmp_4684 = load i64, ptr %tmp_4684_pointer_169, !noalias !2
        %v_r_2527_30_194_4433_pointer_170 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_165, i64 0, i32 4
        %v_r_2527_30_194_4433 = load %Pos, ptr %v_r_2527_30_194_4433_pointer_170, !noalias !2
        
        %tag_171 = extractvalue %Pos %v_r_2611_32_59_223_4486, 0
        %fields_172 = extractvalue %Pos %v_r_2611_32_59_223_4486, 1
        switch i64 %tag_171, label %label_173 [i64 1, label %label_196 i64 0, label %label_203]
    
    label_173:
        
        ret void
    
    label_178:
        
        ret void
    
    label_184:
        call ccc void @erasePositive(%Pos %v_r_2527_30_194_4433)
        
        %pair_179 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4184)
        %k_13_14_4_4604 = extractvalue <{%Resumption, %Stack}> %pair_179, 0
        %stack_180 = extractvalue <{%Resumption, %Stack}> %pair_179, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4604)
        
        %longLiteral_4777 = add i64 5, 0
        
        
        
        %pureApp_4778 = call ccc %Pos @boxInt_301(i64 %longLiteral_4777)
        
        
        
        %stackPointer_182 = call ccc %StackPointer @stackDeallocate(%Stack %stack_180, i64 24)
        %returnAddress_pointer_183 = getelementptr %FrameHeader, %StackPointer %stackPointer_182, i64 0, i32 0
        %returnAddress_181 = load %ReturnAddress, ptr %returnAddress_pointer_183, !noalias !2
        musttail call tailcc void %returnAddress_181(%Pos %pureApp_4778, %Stack %stack_180)
        ret void
    
    label_187:
        
        ret void
    
    label_193:
        call ccc void @erasePositive(%Pos %v_r_2527_30_194_4433)
        
        %pair_188 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4184)
        %k_13_14_4_4603 = extractvalue <{%Resumption, %Stack}> %pair_188, 0
        %stack_189 = extractvalue <{%Resumption, %Stack}> %pair_188, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4603)
        
        %longLiteral_4781 = add i64 5, 0
        
        
        
        %pureApp_4782 = call ccc %Pos @boxInt_301(i64 %longLiteral_4781)
        
        
        
        %stackPointer_191 = call ccc %StackPointer @stackDeallocate(%Stack %stack_189, i64 24)
        %returnAddress_pointer_192 = getelementptr %FrameHeader, %StackPointer %stackPointer_191, i64 0, i32 0
        %returnAddress_190 = load %ReturnAddress, ptr %returnAddress_pointer_192, !noalias !2
        musttail call tailcc void %returnAddress_190(%Pos %pureApp_4782, %Stack %stack_189)
        ret void
    
    label_194:
        
        %longLiteral_4784 = add i64 1, 0
        
        %pureApp_4783 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4223, i64 %longLiteral_4784)
        
        
        
        %longLiteral_4786 = add i64 10, 0
        
        %pureApp_4785 = call ccc i64 @infixMul_99(i64 %longLiteral_4786, i64 %acc_8_35_199_4494)
        
        
        
        %pureApp_4787 = call ccc i64 @toInt_2085(i64 %pureApp_4774)
        
        
        
        %pureApp_4788 = call ccc i64 @infixSub_105(i64 %pureApp_4787, i64 %tmp_4684)
        
        
        
        %pureApp_4789 = call ccc i64 @infixAdd_96(i64 %pureApp_4785, i64 %pureApp_4788)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4454(i64 %pureApp_4783, i64 %pureApp_4789, %Prompt %p_8_9_4184, i64 %tmp_4684, %Pos %v_r_2527_30_194_4433, %Stack %stack)
        ret void
    
    label_195:
        
        %intLiteral_4780 = add i64 57, 0
        
        %pureApp_4779 = call ccc %Pos @infixLte_2093(i64 %pureApp_4774, i64 %intLiteral_4780)
        
        
        
        %tag_185 = extractvalue %Pos %pureApp_4779, 0
        %fields_186 = extractvalue %Pos %pureApp_4779, 1
        switch i64 %tag_185, label %label_187 [i64 0, label %label_193 i64 1, label %label_194]
    
    label_196:
        %environment_174 = call ccc %Environment @objectEnvironment(%Object %fields_172)
        %v_coe_3427_46_73_237_4233_pointer_175 = getelementptr <{%Pos}>, %Environment %environment_174, i64 0, i32 0
        %v_coe_3427_46_73_237_4233 = load %Pos, ptr %v_coe_3427_46_73_237_4233_pointer_175, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3427_46_73_237_4233)
        call ccc void @eraseObject(%Object %fields_172)
        
        %pureApp_4774 = call ccc i64 @unboxChar_313(%Pos %v_coe_3427_46_73_237_4233)
        
        
        
        %intLiteral_4776 = add i64 48, 0
        
        %pureApp_4775 = call ccc %Pos @infixGte_2099(i64 %pureApp_4774, i64 %intLiteral_4776)
        
        
        
        %tag_176 = extractvalue %Pos %pureApp_4775, 0
        %fields_177 = extractvalue %Pos %pureApp_4775, 1
        switch i64 %tag_176, label %label_178 [i64 0, label %label_184 i64 1, label %label_195]
    
    label_203:
        %environment_197 = call ccc %Environment @objectEnvironment(%Object %fields_172)
        %v_y_2618_76_103_267_4772_pointer_198 = getelementptr <{%Pos, %Pos}>, %Environment %environment_197, i64 0, i32 0
        %v_y_2618_76_103_267_4772 = load %Pos, ptr %v_y_2618_76_103_267_4772_pointer_198, !noalias !2
        %v_y_2619_77_104_268_4773_pointer_199 = getelementptr <{%Pos, %Pos}>, %Environment %environment_197, i64 0, i32 1
        %v_y_2619_77_104_268_4773 = load %Pos, ptr %v_y_2619_77_104_268_4773_pointer_199, !noalias !2
        call ccc void @eraseObject(%Object %fields_172)
        call ccc void @erasePositive(%Pos %v_r_2527_30_194_4433)
        
        %stackPointer_201 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_202 = getelementptr %FrameHeader, %StackPointer %stackPointer_201, i64 0, i32 0
        %returnAddress_200 = load %ReturnAddress, ptr %returnAddress_pointer_202, !noalias !2
        musttail call tailcc void %returnAddress_200(i64 %acc_8_35_199_4494, %Stack %stack)
        ret void
}



define ccc void @sharer_209(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_210 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4184_204_pointer_211 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_210, i64 0, i32 0
        %p_8_9_4184_204 = load %Prompt, ptr %p_8_9_4184_204_pointer_211, !noalias !2
        %index_7_34_198_4223_205_pointer_212 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_210, i64 0, i32 1
        %index_7_34_198_4223_205 = load i64, ptr %index_7_34_198_4223_205_pointer_212, !noalias !2
        %acc_8_35_199_4494_206_pointer_213 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_210, i64 0, i32 2
        %acc_8_35_199_4494_206 = load i64, ptr %acc_8_35_199_4494_206_pointer_213, !noalias !2
        %tmp_4684_207_pointer_214 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_210, i64 0, i32 3
        %tmp_4684_207 = load i64, ptr %tmp_4684_207_pointer_214, !noalias !2
        %v_r_2527_30_194_4433_208_pointer_215 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_210, i64 0, i32 4
        %v_r_2527_30_194_4433_208 = load %Pos, ptr %v_r_2527_30_194_4433_208_pointer_215, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2527_30_194_4433_208)
        call ccc void @shareFrames(%StackPointer %stackPointer_210)
        ret void
}



define ccc void @eraser_221(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_222 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4184_216_pointer_223 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_222, i64 0, i32 0
        %p_8_9_4184_216 = load %Prompt, ptr %p_8_9_4184_216_pointer_223, !noalias !2
        %index_7_34_198_4223_217_pointer_224 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_222, i64 0, i32 1
        %index_7_34_198_4223_217 = load i64, ptr %index_7_34_198_4223_217_pointer_224, !noalias !2
        %acc_8_35_199_4494_218_pointer_225 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_222, i64 0, i32 2
        %acc_8_35_199_4494_218 = load i64, ptr %acc_8_35_199_4494_218_pointer_225, !noalias !2
        %tmp_4684_219_pointer_226 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_222, i64 0, i32 3
        %tmp_4684_219 = load i64, ptr %tmp_4684_219_pointer_226, !noalias !2
        %v_r_2527_30_194_4433_220_pointer_227 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_222, i64 0, i32 4
        %v_r_2527_30_194_4433_220 = load %Pos, ptr %v_r_2527_30_194_4433_220_pointer_227, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2527_30_194_4433_220)
        call ccc void @eraseFrames(%StackPointer %stackPointer_222)
        ret void
}



define tailcc void @returnAddress_238(%Pos %returned_4790, %Stack %stack) {
        
    entry:
        
        %stack_239 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_241 = call ccc %StackPointer @stackDeallocate(%Stack %stack_239, i64 24)
        %returnAddress_pointer_242 = getelementptr %FrameHeader, %StackPointer %stackPointer_241, i64 0, i32 0
        %returnAddress_240 = load %ReturnAddress, ptr %returnAddress_pointer_242, !noalias !2
        musttail call tailcc void %returnAddress_240(%Pos %returned_4790, %Stack %stack_239)
        ret void
}



define tailcc void @Exception_7_19_46_210_4304_clause_247(%Object %closure, %Pos %exc_8_20_47_211_4428, %Pos %msg_9_21_48_212_4363, %Stack %stack) {
        
    entry:
        
        %environment_248 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4321_pointer_249 = getelementptr <{%Prompt}>, %Environment %environment_248, i64 0, i32 0
        %p_6_18_45_209_4321 = load %Prompt, ptr %p_6_18_45_209_4321_pointer_249, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_250 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4321)
        %k_11_23_50_214_4507 = extractvalue <{%Resumption, %Stack}> %pair_250, 0
        %stack_251 = extractvalue <{%Resumption, %Stack}> %pair_250, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4507)
        
        %fields_252 = call ccc %Object @newObject(ptr @eraser_143, i64 32)
        %environment_253 = call ccc %Environment @objectEnvironment(%Object %fields_252)
        %exc_8_20_47_211_4428_pointer_256 = getelementptr <{%Pos, %Pos}>, %Environment %environment_253, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4428, ptr %exc_8_20_47_211_4428_pointer_256, !noalias !2
        %msg_9_21_48_212_4363_pointer_257 = getelementptr <{%Pos, %Pos}>, %Environment %environment_253, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4363, ptr %msg_9_21_48_212_4363_pointer_257, !noalias !2
        %make_4791_temporary_258 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4791 = insertvalue %Pos %make_4791_temporary_258, %Object %fields_252, 1
        
        
        
        %stackPointer_260 = call ccc %StackPointer @stackDeallocate(%Stack %stack_251, i64 24)
        %returnAddress_pointer_261 = getelementptr %FrameHeader, %StackPointer %stackPointer_260, i64 0, i32 0
        %returnAddress_259 = load %ReturnAddress, ptr %returnAddress_pointer_261, !noalias !2
        musttail call tailcc void %returnAddress_259(%Pos %make_4791, %Stack %stack_251)
        ret void
}


@vtable_262 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4304_clause_247]


define ccc void @eraser_266(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4321_265_pointer_267 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4321_265 = load %Prompt, ptr %p_6_18_45_209_4321_265_pointer_267, !noalias !2
        ret void
}



define ccc void @eraser_274(%Environment %environment) {
        
    entry:
        
        %tmp_4686_273_pointer_275 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4686_273 = load %Pos, ptr %tmp_4686_273_pointer_275, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4686_273)
        ret void
}



define tailcc void @returnAddress_270(i64 %v_coe_3426_6_28_55_219_4324, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4792 = call ccc %Pos @boxChar_311(i64 %v_coe_3426_6_28_55_219_4324)
        
        
        
        %fields_271 = call ccc %Object @newObject(ptr @eraser_274, i64 16)
        %environment_272 = call ccc %Environment @objectEnvironment(%Object %fields_271)
        %tmp_4686_pointer_276 = getelementptr <{%Pos}>, %Environment %environment_272, i64 0, i32 0
        store %Pos %pureApp_4792, ptr %tmp_4686_pointer_276, !noalias !2
        %make_4793_temporary_277 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4793 = insertvalue %Pos %make_4793_temporary_277, %Object %fields_271, 1
        
        
        
        %stackPointer_279 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_280 = getelementptr %FrameHeader, %StackPointer %stackPointer_279, i64 0, i32 0
        %returnAddress_278 = load %ReturnAddress, ptr %returnAddress_pointer_280, !noalias !2
        musttail call tailcc void %returnAddress_278(%Pos %make_4793, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4454(i64 %index_7_34_198_4223, i64 %acc_8_35_199_4494, %Prompt %p_8_9_4184, i64 %tmp_4684, %Pos %v_r_2527_30_194_4433, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2527_30_194_4433)
        %stackPointer_228 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %p_8_9_4184_pointer_229 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_228, i64 0, i32 0
        store %Prompt %p_8_9_4184, ptr %p_8_9_4184_pointer_229, !noalias !2
        %index_7_34_198_4223_pointer_230 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_228, i64 0, i32 1
        store i64 %index_7_34_198_4223, ptr %index_7_34_198_4223_pointer_230, !noalias !2
        %acc_8_35_199_4494_pointer_231 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_228, i64 0, i32 2
        store i64 %acc_8_35_199_4494, ptr %acc_8_35_199_4494_pointer_231, !noalias !2
        %tmp_4684_pointer_232 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_228, i64 0, i32 3
        store i64 %tmp_4684, ptr %tmp_4684_pointer_232, !noalias !2
        %v_r_2527_30_194_4433_pointer_233 = getelementptr <{%Prompt, i64, i64, i64, %Pos}>, %StackPointer %stackPointer_228, i64 0, i32 4
        store %Pos %v_r_2527_30_194_4433, ptr %v_r_2527_30_194_4433_pointer_233, !noalias !2
        %returnAddress_pointer_234 = getelementptr <{<{%Prompt, i64, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_228, i64 0, i32 1, i32 0
        %sharer_pointer_235 = getelementptr <{<{%Prompt, i64, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_228, i64 0, i32 1, i32 1
        %eraser_pointer_236 = getelementptr <{<{%Prompt, i64, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_228, i64 0, i32 1, i32 2
        store ptr @returnAddress_164, ptr %returnAddress_pointer_234, !noalias !2
        store ptr @sharer_209, ptr %sharer_pointer_235, !noalias !2
        store ptr @eraser_221, ptr %eraser_pointer_236, !noalias !2
        
        %stack_237 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4321 = call ccc %Prompt @currentPrompt(%Stack %stack_237)
        %stackPointer_243 = call ccc %StackPointer @stackAllocate(%Stack %stack_237, i64 24)
        %returnAddress_pointer_244 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_243, i64 0, i32 1, i32 0
        %sharer_pointer_245 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_243, i64 0, i32 1, i32 1
        %eraser_pointer_246 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_243, i64 0, i32 1, i32 2
        store ptr @returnAddress_238, ptr %returnAddress_pointer_244, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_245, !noalias !2
        store ptr @eraser_44, ptr %eraser_pointer_246, !noalias !2
        
        %closure_263 = call ccc %Object @newObject(ptr @eraser_266, i64 8)
        %environment_264 = call ccc %Environment @objectEnvironment(%Object %closure_263)
        %p_6_18_45_209_4321_pointer_268 = getelementptr <{%Prompt}>, %Environment %environment_264, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4321, ptr %p_6_18_45_209_4321_pointer_268, !noalias !2
        %vtable_temporary_269 = insertvalue %Neg zeroinitializer, ptr @vtable_262, 0
        %Exception_7_19_46_210_4304 = insertvalue %Neg %vtable_temporary_269, %Object %closure_263, 1
        %stackPointer_281 = call ccc %StackPointer @stackAllocate(%Stack %stack_237, i64 24)
        %returnAddress_pointer_282 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 0
        %sharer_pointer_283 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 1
        %eraser_pointer_284 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_281, i64 0, i32 1, i32 2
        store ptr @returnAddress_270, ptr %returnAddress_pointer_282, !noalias !2
        store ptr @sharer_87, ptr %sharer_pointer_283, !noalias !2
        store ptr @eraser_89, ptr %eraser_pointer_284, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2527_30_194_4433, i64 %index_7_34_198_4223, %Neg %Exception_7_19_46_210_4304, %Stack %stack_237)
        ret void
}



define tailcc void @Exception_9_106_133_297_4391_clause_285(%Object %closure, %Pos %exception_10_107_134_298_4794, %Pos %msg_11_108_135_299_4795, %Stack %stack) {
        
    entry:
        
        %environment_286 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4184_pointer_287 = getelementptr <{%Prompt}>, %Environment %environment_286, i64 0, i32 0
        %p_8_9_4184 = load %Prompt, ptr %p_8_9_4184_pointer_287, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4794)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4795)
        
        %pair_288 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4184)
        %k_13_14_4_4663 = extractvalue <{%Resumption, %Stack}> %pair_288, 0
        %stack_289 = extractvalue <{%Resumption, %Stack}> %pair_288, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4663)
        
        %longLiteral_4796 = add i64 5, 0
        
        
        
        %pureApp_4797 = call ccc %Pos @boxInt_301(i64 %longLiteral_4796)
        
        
        
        %stackPointer_291 = call ccc %StackPointer @stackDeallocate(%Stack %stack_289, i64 24)
        %returnAddress_pointer_292 = getelementptr %FrameHeader, %StackPointer %stackPointer_291, i64 0, i32 0
        %returnAddress_290 = load %ReturnAddress, ptr %returnAddress_pointer_292, !noalias !2
        musttail call tailcc void %returnAddress_290(%Pos %pureApp_4797, %Stack %stack_289)
        ret void
}


@vtable_293 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4391_clause_285]


define tailcc void @returnAddress_304(i64 %v_coe_3431_22_131_158_322_4225, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4800 = call ccc %Pos @boxInt_301(i64 %v_coe_3431_22_131_158_322_4225)
        
        
        
        
        
        %pureApp_4801 = call ccc i64 @unboxInt_303(%Pos %pureApp_4800)
        
        
        
        %pureApp_4802 = call ccc %Pos @boxInt_301(i64 %pureApp_4801)
        
        
        
        %stackPointer_306 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_307 = getelementptr %FrameHeader, %StackPointer %stackPointer_306, i64 0, i32 0
        %returnAddress_305 = load %ReturnAddress, ptr %returnAddress_pointer_307, !noalias !2
        musttail call tailcc void %returnAddress_305(%Pos %pureApp_4802, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_316(i64 %v_r_2625_1_9_20_129_156_320_4383, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4806 = add i64 0, 0
        
        %pureApp_4805 = call ccc i64 @infixSub_105(i64 %longLiteral_4806, i64 %v_r_2625_1_9_20_129_156_320_4383)
        
        
        
        %stackPointer_318 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_319 = getelementptr %FrameHeader, %StackPointer %stackPointer_318, i64 0, i32 0
        %returnAddress_317 = load %ReturnAddress, ptr %returnAddress_pointer_319, !noalias !2
        musttail call tailcc void %returnAddress_317(i64 %pureApp_4805, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_299(i64 %v_r_2624_3_14_123_150_314_4232, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_300 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_4184_pointer_301 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_300, i64 0, i32 0
        %p_8_9_4184 = load %Prompt, ptr %p_8_9_4184_pointer_301, !noalias !2
        %tmp_4684_pointer_302 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_300, i64 0, i32 1
        %tmp_4684 = load i64, ptr %tmp_4684_pointer_302, !noalias !2
        %v_r_2527_30_194_4433_pointer_303 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_300, i64 0, i32 2
        %v_r_2527_30_194_4433 = load %Pos, ptr %v_r_2527_30_194_4433_pointer_303, !noalias !2
        
        %intLiteral_4799 = add i64 45, 0
        
        %pureApp_4798 = call ccc %Pos @infixEq_78(i64 %v_r_2624_3_14_123_150_314_4232, i64 %intLiteral_4799)
        
        
        %stackPointer_308 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_309 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 0
        %sharer_pointer_310 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 1
        %eraser_pointer_311 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 2
        store ptr @returnAddress_304, ptr %returnAddress_pointer_309, !noalias !2
        store ptr @sharer_87, ptr %sharer_pointer_310, !noalias !2
        store ptr @eraser_89, ptr %eraser_pointer_311, !noalias !2
        
        %tag_312 = extractvalue %Pos %pureApp_4798, 0
        %fields_313 = extractvalue %Pos %pureApp_4798, 1
        switch i64 %tag_312, label %label_314 [i64 0, label %label_315 i64 1, label %label_324]
    
    label_314:
        
        ret void
    
    label_315:
        
        %longLiteral_4803 = add i64 0, 0
        
        %longLiteral_4804 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4454(i64 %longLiteral_4803, i64 %longLiteral_4804, %Prompt %p_8_9_4184, i64 %tmp_4684, %Pos %v_r_2527_30_194_4433, %Stack %stack)
        ret void
    
    label_324:
        %stackPointer_320 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_321 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_320, i64 0, i32 1, i32 0
        %sharer_pointer_322 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_320, i64 0, i32 1, i32 1
        %eraser_pointer_323 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_320, i64 0, i32 1, i32 2
        store ptr @returnAddress_316, ptr %returnAddress_pointer_321, !noalias !2
        store ptr @sharer_87, ptr %sharer_pointer_322, !noalias !2
        store ptr @eraser_89, ptr %eraser_pointer_323, !noalias !2
        
        %longLiteral_4807 = add i64 1, 0
        
        %longLiteral_4808 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4454(i64 %longLiteral_4807, i64 %longLiteral_4808, %Prompt %p_8_9_4184, i64 %tmp_4684, %Pos %v_r_2527_30_194_4433, %Stack %stack)
        ret void
}



define ccc void @sharer_328(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_329 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4184_325_pointer_330 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_329, i64 0, i32 0
        %p_8_9_4184_325 = load %Prompt, ptr %p_8_9_4184_325_pointer_330, !noalias !2
        %tmp_4684_326_pointer_331 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_329, i64 0, i32 1
        %tmp_4684_326 = load i64, ptr %tmp_4684_326_pointer_331, !noalias !2
        %v_r_2527_30_194_4433_327_pointer_332 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_329, i64 0, i32 2
        %v_r_2527_30_194_4433_327 = load %Pos, ptr %v_r_2527_30_194_4433_327_pointer_332, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2527_30_194_4433_327)
        call ccc void @shareFrames(%StackPointer %stackPointer_329)
        ret void
}



define ccc void @eraser_336(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_337 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4184_333_pointer_338 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_337, i64 0, i32 0
        %p_8_9_4184_333 = load %Prompt, ptr %p_8_9_4184_333_pointer_338, !noalias !2
        %tmp_4684_334_pointer_339 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_337, i64 0, i32 1
        %tmp_4684_334 = load i64, ptr %tmp_4684_334_pointer_339, !noalias !2
        %v_r_2527_30_194_4433_335_pointer_340 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_337, i64 0, i32 2
        %v_r_2527_30_194_4433_335 = load %Pos, ptr %v_r_2527_30_194_4433_335_pointer_340, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2527_30_194_4433_335)
        call ccc void @eraseFrames(%StackPointer %stackPointer_337)
        ret void
}



define tailcc void @returnAddress_161(%Pos %v_r_2527_30_194_4433, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_162 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4184_pointer_163 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_162, i64 0, i32 0
        %p_8_9_4184 = load %Prompt, ptr %p_8_9_4184_pointer_163, !noalias !2
        
        %intLiteral_4771 = add i64 48, 0
        
        %pureApp_4770 = call ccc i64 @toInt_2085(i64 %intLiteral_4771)
        
        
        
        %closure_294 = call ccc %Object @newObject(ptr @eraser_266, i64 8)
        %environment_295 = call ccc %Environment @objectEnvironment(%Object %closure_294)
        %p_8_9_4184_pointer_297 = getelementptr <{%Prompt}>, %Environment %environment_295, i64 0, i32 0
        store %Prompt %p_8_9_4184, ptr %p_8_9_4184_pointer_297, !noalias !2
        %vtable_temporary_298 = insertvalue %Neg zeroinitializer, ptr @vtable_293, 0
        %Exception_9_106_133_297_4391 = insertvalue %Neg %vtable_temporary_298, %Object %closure_294, 1
        call ccc void @sharePositive(%Pos %v_r_2527_30_194_4433)
        %stackPointer_341 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_4184_pointer_342 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_341, i64 0, i32 0
        store %Prompt %p_8_9_4184, ptr %p_8_9_4184_pointer_342, !noalias !2
        %tmp_4684_pointer_343 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_341, i64 0, i32 1
        store i64 %pureApp_4770, ptr %tmp_4684_pointer_343, !noalias !2
        %v_r_2527_30_194_4433_pointer_344 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_341, i64 0, i32 2
        store %Pos %v_r_2527_30_194_4433, ptr %v_r_2527_30_194_4433_pointer_344, !noalias !2
        %returnAddress_pointer_345 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_341, i64 0, i32 1, i32 0
        %sharer_pointer_346 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_341, i64 0, i32 1, i32 1
        %eraser_pointer_347 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_341, i64 0, i32 1, i32 2
        store ptr @returnAddress_299, ptr %returnAddress_pointer_345, !noalias !2
        store ptr @sharer_328, ptr %sharer_pointer_346, !noalias !2
        store ptr @eraser_336, ptr %eraser_pointer_347, !noalias !2
        
        %longLiteral_4809 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2527_30_194_4433, i64 %longLiteral_4809, %Neg %Exception_9_106_133_297_4391, %Stack %stack)
        ret void
}



define ccc void @sharer_349(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_350 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4184_348_pointer_351 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_350, i64 0, i32 0
        %p_8_9_4184_348 = load %Prompt, ptr %p_8_9_4184_348_pointer_351, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_350)
        ret void
}



define ccc void @eraser_353(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_354 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4184_352_pointer_355 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_354, i64 0, i32 0
        %p_8_9_4184_352 = load %Prompt, ptr %p_8_9_4184_352_pointer_355, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_354)
        ret void
}


@utf8StringLiteral_4810.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_158(%Pos %v_r_2526_24_188_4234, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_159 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4184_pointer_160 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_159, i64 0, i32 0
        %p_8_9_4184 = load %Prompt, ptr %p_8_9_4184_pointer_160, !noalias !2
        %stackPointer_356 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4184_pointer_357 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_356, i64 0, i32 0
        store %Prompt %p_8_9_4184, ptr %p_8_9_4184_pointer_357, !noalias !2
        %returnAddress_pointer_358 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_356, i64 0, i32 1, i32 0
        %sharer_pointer_359 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_356, i64 0, i32 1, i32 1
        %eraser_pointer_360 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_356, i64 0, i32 1, i32 2
        store ptr @returnAddress_161, ptr %returnAddress_pointer_358, !noalias !2
        store ptr @sharer_349, ptr %sharer_pointer_359, !noalias !2
        store ptr @eraser_353, ptr %eraser_pointer_360, !noalias !2
        
        %tag_361 = extractvalue %Pos %v_r_2526_24_188_4234, 0
        %fields_362 = extractvalue %Pos %v_r_2526_24_188_4234, 1
        switch i64 %tag_361, label %label_363 [i64 0, label %label_367 i64 1, label %label_373]
    
    label_363:
        
        ret void
    
    label_367:
        
        %utf8StringLiteral_4810 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4810.lit)
        
        %stackPointer_365 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_366 = getelementptr %FrameHeader, %StackPointer %stackPointer_365, i64 0, i32 0
        %returnAddress_364 = load %ReturnAddress, ptr %returnAddress_pointer_366, !noalias !2
        musttail call tailcc void %returnAddress_364(%Pos %utf8StringLiteral_4810, %Stack %stack)
        ret void
    
    label_373:
        %environment_368 = call ccc %Environment @objectEnvironment(%Object %fields_362)
        %v_y_3253_8_29_193_4301_pointer_369 = getelementptr <{%Pos}>, %Environment %environment_368, i64 0, i32 0
        %v_y_3253_8_29_193_4301 = load %Pos, ptr %v_y_3253_8_29_193_4301_pointer_369, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3253_8_29_193_4301)
        call ccc void @eraseObject(%Object %fields_362)
        
        %stackPointer_371 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_372 = getelementptr %FrameHeader, %StackPointer %stackPointer_371, i64 0, i32 0
        %returnAddress_370 = load %ReturnAddress, ptr %returnAddress_pointer_372, !noalias !2
        musttail call tailcc void %returnAddress_370(%Pos %v_y_3253_8_29_193_4301, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_155(%Pos %v_r_2525_13_177_4361, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_156 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4184_pointer_157 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_156, i64 0, i32 0
        %p_8_9_4184 = load %Prompt, ptr %p_8_9_4184_pointer_157, !noalias !2
        %stackPointer_376 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4184_pointer_377 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_376, i64 0, i32 0
        store %Prompt %p_8_9_4184, ptr %p_8_9_4184_pointer_377, !noalias !2
        %returnAddress_pointer_378 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_376, i64 0, i32 1, i32 0
        %sharer_pointer_379 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_376, i64 0, i32 1, i32 1
        %eraser_pointer_380 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_376, i64 0, i32 1, i32 2
        store ptr @returnAddress_158, ptr %returnAddress_pointer_378, !noalias !2
        store ptr @sharer_349, ptr %sharer_pointer_379, !noalias !2
        store ptr @eraser_353, ptr %eraser_pointer_380, !noalias !2
        
        %tag_381 = extractvalue %Pos %v_r_2525_13_177_4361, 0
        %fields_382 = extractvalue %Pos %v_r_2525_13_177_4361, 1
        switch i64 %tag_381, label %label_383 [i64 0, label %label_388 i64 1, label %label_400]
    
    label_383:
        
        ret void
    
    label_388:
        
        %make_4811_temporary_384 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4811 = insertvalue %Pos %make_4811_temporary_384, %Object null, 1
        
        
        
        %stackPointer_386 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_387 = getelementptr %FrameHeader, %StackPointer %stackPointer_386, i64 0, i32 0
        %returnAddress_385 = load %ReturnAddress, ptr %returnAddress_pointer_387, !noalias !2
        musttail call tailcc void %returnAddress_385(%Pos %make_4811, %Stack %stack)
        ret void
    
    label_400:
        %environment_389 = call ccc %Environment @objectEnvironment(%Object %fields_382)
        %v_y_2762_10_21_185_4237_pointer_390 = getelementptr <{%Pos, %Pos}>, %Environment %environment_389, i64 0, i32 0
        %v_y_2762_10_21_185_4237 = load %Pos, ptr %v_y_2762_10_21_185_4237_pointer_390, !noalias !2
        %v_y_2763_11_22_186_4388_pointer_391 = getelementptr <{%Pos, %Pos}>, %Environment %environment_389, i64 0, i32 1
        %v_y_2763_11_22_186_4388 = load %Pos, ptr %v_y_2763_11_22_186_4388_pointer_391, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2762_10_21_185_4237)
        call ccc void @eraseObject(%Object %fields_382)
        
        %fields_392 = call ccc %Object @newObject(ptr @eraser_274, i64 16)
        %environment_393 = call ccc %Environment @objectEnvironment(%Object %fields_392)
        %v_y_2762_10_21_185_4237_pointer_395 = getelementptr <{%Pos}>, %Environment %environment_393, i64 0, i32 0
        store %Pos %v_y_2762_10_21_185_4237, ptr %v_y_2762_10_21_185_4237_pointer_395, !noalias !2
        %make_4812_temporary_396 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4812 = insertvalue %Pos %make_4812_temporary_396, %Object %fields_392, 1
        
        
        
        %stackPointer_398 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_399 = getelementptr %FrameHeader, %StackPointer %stackPointer_398, i64 0, i32 0
        %returnAddress_397 = load %ReturnAddress, ptr %returnAddress_pointer_399, !noalias !2
        musttail call tailcc void %returnAddress_397(%Pos %make_4812, %Stack %stack)
        ret void
}



define tailcc void @main_2441(%Stack %stack) {
        
    entry:
        
        %stackPointer_122 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_123 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_122, i64 0, i32 1, i32 0
        %sharer_pointer_124 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_122, i64 0, i32 1, i32 1
        %eraser_pointer_125 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_122, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_123, !noalias !2
        store ptr @sharer_87, ptr %sharer_pointer_124, !noalias !2
        store ptr @eraser_89, ptr %eraser_pointer_125, !noalias !2
        
        %stack_126 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4184 = call ccc %Prompt @currentPrompt(%Stack %stack_126)
        %stackPointer_132 = call ccc %StackPointer @stackAllocate(%Stack %stack_126, i64 24)
        %returnAddress_pointer_133 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_132, i64 0, i32 1, i32 0
        %sharer_pointer_134 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_132, i64 0, i32 1, i32 1
        %eraser_pointer_135 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_132, i64 0, i32 1, i32 2
        store ptr @returnAddress_127, ptr %returnAddress_pointer_133, !noalias !2
        store ptr @sharer_42, ptr %sharer_pointer_134, !noalias !2
        store ptr @eraser_44, ptr %eraser_pointer_135, !noalias !2
        
        %pureApp_4766 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4768 = add i64 1, 0
        
        %pureApp_4767 = call ccc i64 @infixSub_105(i64 %pureApp_4766, i64 %longLiteral_4768)
        
        
        
        %make_4769_temporary_154 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4769 = insertvalue %Pos %make_4769_temporary_154, %Object null, 1
        
        
        %stackPointer_403 = call ccc %StackPointer @stackAllocate(%Stack %stack_126, i64 32)
        %p_8_9_4184_pointer_404 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_403, i64 0, i32 0
        store %Prompt %p_8_9_4184, ptr %p_8_9_4184_pointer_404, !noalias !2
        %returnAddress_pointer_405 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 0
        %sharer_pointer_406 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 1
        %eraser_pointer_407 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_403, i64 0, i32 1, i32 2
        store ptr @returnAddress_155, ptr %returnAddress_pointer_405, !noalias !2
        store ptr @sharer_349, ptr %sharer_pointer_406, !noalias !2
        store ptr @eraser_353, ptr %eraser_pointer_407, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4378(i64 %pureApp_4767, %Pos %make_4769, %Stack %stack_126)
        ret void
}



define tailcc void @returnAddress_411(%Pos %v_r_2512_3522, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_412 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %i_2435_pointer_413 = getelementptr <{i64}>, %StackPointer %stackPointer_412, i64 0, i32 0
        %i_2435 = load i64, ptr %i_2435_pointer_413, !noalias !2
        
        %pureApp_4737 = call ccc %Pos @boxInt_301(i64 %i_2435)
        
        
        
        %fields_414 = call ccc %Object @newObject(ptr @eraser_143, i64 32)
        %environment_415 = call ccc %Environment @objectEnvironment(%Object %fields_414)
        %tmp_4675_pointer_418 = getelementptr <{%Pos, %Pos}>, %Environment %environment_415, i64 0, i32 0
        store %Pos %pureApp_4737, ptr %tmp_4675_pointer_418, !noalias !2
        %v_r_2512_3522_pointer_419 = getelementptr <{%Pos, %Pos}>, %Environment %environment_415, i64 0, i32 1
        store %Pos %v_r_2512_3522, ptr %v_r_2512_3522_pointer_419, !noalias !2
        %make_4738_temporary_420 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4738 = insertvalue %Pos %make_4738_temporary_420, %Object %fields_414, 1
        
        
        
        %stackPointer_422 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_423 = getelementptr %FrameHeader, %StackPointer %stackPointer_422, i64 0, i32 0
        %returnAddress_421 = load %ReturnAddress, ptr %returnAddress_pointer_423, !noalias !2
        musttail call tailcc void %returnAddress_421(%Pos %make_4738, %Stack %stack)
        ret void
}



define tailcc void @enumerate_2436(i64 %i_2435, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4734 = add i64 0, 0
        
        %pureApp_4733 = call ccc %Pos @infixLt_178(i64 %i_2435, i64 %longLiteral_4734)
        
        
        
        %tag_408 = extractvalue %Pos %pureApp_4733, 0
        %fields_409 = extractvalue %Pos %pureApp_4733, 1
        switch i64 %tag_408, label %label_410 [i64 0, label %label_431 i64 1, label %label_436]
    
    label_410:
        
        ret void
    
    label_431:
        
        %longLiteral_4736 = add i64 1, 0
        
        %pureApp_4735 = call ccc i64 @infixSub_105(i64 %i_2435, i64 %longLiteral_4736)
        
        
        %stackPointer_426 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %i_2435_pointer_427 = getelementptr <{i64}>, %StackPointer %stackPointer_426, i64 0, i32 0
        store i64 %i_2435, ptr %i_2435_pointer_427, !noalias !2
        %returnAddress_pointer_428 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 0
        %sharer_pointer_429 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 1
        %eraser_pointer_430 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_426, i64 0, i32 1, i32 2
        store ptr @returnAddress_411, ptr %returnAddress_pointer_428, !noalias !2
        store ptr @sharer_70, ptr %sharer_pointer_429, !noalias !2
        store ptr @eraser_74, ptr %eraser_pointer_430, !noalias !2
        
        
        
        musttail call tailcc void @enumerate_2436(i64 %pureApp_4735, %Stack %stack)
        ret void
    
    label_436:
        
        %make_4739_temporary_432 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4739 = insertvalue %Pos %make_4739_temporary_432, %Object null, 1
        
        
        
        %stackPointer_434 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_435 = getelementptr %FrameHeader, %StackPointer %stackPointer_434, i64 0, i32 0
        %returnAddress_433 = load %ReturnAddress, ptr %returnAddress_pointer_435, !noalias !2
        musttail call tailcc void %returnAddress_433(%Pos %make_4739, %Stack %stack)
        ret void
}


@utf8StringLiteral_4724.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4726.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4729.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_437(%Pos %v_r_2693_3487, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_438 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_439 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_438, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_439, !noalias !2
        %index_2107_pointer_440 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_438, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_440, !noalias !2
        %Exception_2362_pointer_441 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_438, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_441, !noalias !2
        
        %tag_442 = extractvalue %Pos %v_r_2693_3487, 0
        %fields_443 = extractvalue %Pos %v_r_2693_3487, 1
        switch i64 %tag_442, label %label_444 [i64 0, label %label_448 i64 1, label %label_454]
    
    label_444:
        
        ret void
    
    label_448:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4720 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_446 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_447 = getelementptr %FrameHeader, %StackPointer %stackPointer_446, i64 0, i32 0
        %returnAddress_445 = load %ReturnAddress, ptr %returnAddress_pointer_447, !noalias !2
        musttail call tailcc void %returnAddress_445(i64 %pureApp_4720, %Stack %stack)
        ret void
    
    label_454:
        
        %make_4721_temporary_449 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4721 = insertvalue %Pos %make_4721_temporary_449, %Object null, 1
        
        
        
        %pureApp_4722 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4724 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4724.lit)
        
        %pureApp_4723 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4724, %Pos %pureApp_4722)
        
        
        
        %utf8StringLiteral_4726 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4726.lit)
        
        %pureApp_4725 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4723, %Pos %utf8StringLiteral_4726)
        
        
        
        %pureApp_4727 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4725, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4729 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4729.lit)
        
        %pureApp_4728 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4727, %Pos %utf8StringLiteral_4729)
        
        
        
        %vtable_450 = extractvalue %Neg %Exception_2362, 0
        %closure_451 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_452 = getelementptr ptr, ptr %vtable_450, i64 0
        %functionPointer_453 = load ptr, ptr %functionPointer_pointer_452, !noalias !2
        musttail call tailcc void %functionPointer_453(%Object %closure_451, %Pos %make_4721, %Pos %pureApp_4728, %Stack %stack)
        ret void
}



define ccc void @sharer_458(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_459 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_455_pointer_460 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_459, i64 0, i32 0
        %str_2106_455 = load %Pos, ptr %str_2106_455_pointer_460, !noalias !2
        %index_2107_456_pointer_461 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_459, i64 0, i32 1
        %index_2107_456 = load i64, ptr %index_2107_456_pointer_461, !noalias !2
        %Exception_2362_457_pointer_462 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_459, i64 0, i32 2
        %Exception_2362_457 = load %Neg, ptr %Exception_2362_457_pointer_462, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_455)
        call ccc void @shareNegative(%Neg %Exception_2362_457)
        call ccc void @shareFrames(%StackPointer %stackPointer_459)
        ret void
}



define ccc void @eraser_466(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_467 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_463_pointer_468 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_467, i64 0, i32 0
        %str_2106_463 = load %Pos, ptr %str_2106_463_pointer_468, !noalias !2
        %index_2107_464_pointer_469 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_467, i64 0, i32 1
        %index_2107_464 = load i64, ptr %index_2107_464_pointer_469, !noalias !2
        %Exception_2362_465_pointer_470 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_467, i64 0, i32 2
        %Exception_2362_465 = load %Neg, ptr %Exception_2362_465_pointer_470, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_463)
        call ccc void @eraseNegative(%Neg %Exception_2362_465)
        call ccc void @eraseFrames(%StackPointer %stackPointer_467)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4719 = add i64 0, 0
        
        %pureApp_4718 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4719)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_471 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_472 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_471, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_472, !noalias !2
        %index_2107_pointer_473 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_471, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_473, !noalias !2
        %Exception_2362_pointer_474 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_471, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_474, !noalias !2
        %returnAddress_pointer_475 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_471, i64 0, i32 1, i32 0
        %sharer_pointer_476 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_471, i64 0, i32 1, i32 1
        %eraser_pointer_477 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_471, i64 0, i32 1, i32 2
        store ptr @returnAddress_437, ptr %returnAddress_pointer_475, !noalias !2
        store ptr @sharer_458, ptr %sharer_pointer_476, !noalias !2
        store ptr @eraser_466, ptr %eraser_pointer_477, !noalias !2
        
        %tag_478 = extractvalue %Pos %pureApp_4718, 0
        %fields_479 = extractvalue %Pos %pureApp_4718, 1
        switch i64 %tag_478, label %label_480 [i64 0, label %label_484 i64 1, label %label_489]
    
    label_480:
        
        ret void
    
    label_484:
        
        %pureApp_4730 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4731 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4730)
        
        
        
        %stackPointer_482 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_483 = getelementptr %FrameHeader, %StackPointer %stackPointer_482, i64 0, i32 0
        %returnAddress_481 = load %ReturnAddress, ptr %returnAddress_pointer_483, !noalias !2
        musttail call tailcc void %returnAddress_481(%Pos %pureApp_4731, %Stack %stack)
        ret void
    
    label_489:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4732_temporary_485 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4732 = insertvalue %Pos %booleanLiteral_4732_temporary_485, %Object null, 1
        
        %stackPointer_487 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_488 = getelementptr %FrameHeader, %StackPointer %stackPointer_487, i64 0, i32 0
        %returnAddress_486 = load %ReturnAddress, ptr %returnAddress_pointer_488, !noalias !2
        musttail call tailcc void %returnAddress_486(%Pos %booleanLiteral_4732, %Stack %stack)
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
        
        musttail call tailcc void @main_2441(%Stack %stack)
        ret void
}
