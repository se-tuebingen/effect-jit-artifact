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



define tailcc void @returnAddress_10(%Pos %v_r_3046_2_5758, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_11 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_5754_pointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 0
        %i_6_5754 = load i64, ptr %i_6_5754_pointer_12, !noalias !2
        %tmp_5980_pointer_13 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 1
        %tmp_5980 = load i64, ptr %tmp_5980_pointer_13, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3046_2_5758)
        
        %longLiteral_6174 = add i64 1, 0
        
        %pureApp_6173 = call ccc i64 @infixAdd_96(i64 %i_6_5754, i64 %longLiteral_6174)
        
        
        
        
        
        musttail call tailcc void @loop_5_5751(i64 %pureApp_6173, i64 %tmp_5980, %Stack %stack)
        ret void
}



define ccc void @sharer_16(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_17 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5754_14_pointer_18 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 0
        %i_6_5754_14 = load i64, ptr %i_6_5754_14_pointer_18, !noalias !2
        %tmp_5980_15_pointer_19 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 1
        %tmp_5980_15 = load i64, ptr %tmp_5980_15_pointer_19, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_17)
        ret void
}



define ccc void @eraser_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5754_20_pointer_24 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %i_6_5754_20 = load i64, ptr %i_6_5754_20_pointer_24, !noalias !2
        %tmp_5980_21_pointer_25 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 1
        %tmp_5980_21 = load i64, ptr %tmp_5980_21_pointer_25, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_23)
        ret void
}



define tailcc void @loop_5_5751(i64 %i_6_5754, i64 %tmp_5980, %Stack %stack) {
        
    entry:
        
        
        %pureApp_6171 = call ccc %Pos @infixLt_178(i64 %i_6_5754, i64 %tmp_5980)
        
        
        
        %tag_2 = extractvalue %Pos %pureApp_6171, 0
        %fields_3 = extractvalue %Pos %pureApp_6171, 1
        switch i64 %tag_2, label %label_4 [i64 0, label %label_9 i64 1, label %label_32]
    
    label_4:
        
        ret void
    
    label_9:
        
        %unitLiteral_6172_temporary_5 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6172 = insertvalue %Pos %unitLiteral_6172_temporary_5, %Object null, 1
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %unitLiteral_6172, %Stack %stack)
        ret void
    
    label_32:
        %stackPointer_26 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_5754_pointer_27 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        store i64 %i_6_5754, ptr %i_6_5754_pointer_27, !noalias !2
        %tmp_5980_pointer_28 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 1
        store i64 %tmp_5980, ptr %tmp_5980_pointer_28, !noalias !2
        %returnAddress_pointer_29 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 0
        %sharer_pointer_30 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 1
        %eraser_pointer_31 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 2
        store ptr @returnAddress_10, ptr %returnAddress_pointer_29, !noalias !2
        store ptr @sharer_16, ptr %sharer_pointer_30, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_31, !noalias !2
        
        %longLiteral_6175 = add i64 8, 0
        
        
        
        musttail call tailcc void @run_2855(i64 %longLiteral_6175, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_35(%Pos %v_r_3050_4215, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_6177 = call ccc %Pos @println_1(%Pos %v_r_3050_4215)
        
        
        
        %stackPointer_37 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_38 = getelementptr %FrameHeader, %StackPointer %stackPointer_37, i64 0, i32 0
        %returnAddress_36 = load %ReturnAddress, ptr %returnAddress_pointer_38, !noalias !2
        musttail call tailcc void %returnAddress_36(%Pos %pureApp_6177, %Stack %stack)
        ret void
}



define ccc void @sharer_39(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_40 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_40)
        ret void
}



define ccc void @eraser_41(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_42 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_42)
        ret void
}


@utf8StringLiteral_6178.lit = private constant [5 x i8] c"\46\61\6c\73\65"

@utf8StringLiteral_6179.lit = private constant [4 x i8] c"\54\72\75\65"


define tailcc void @returnAddress_34(%Pos %r_2882, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_43 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_44 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_43, i64 0, i32 1, i32 0
        %sharer_pointer_45 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_43, i64 0, i32 1, i32 1
        %eraser_pointer_46 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_43, i64 0, i32 1, i32 2
        store ptr @returnAddress_35, ptr %returnAddress_pointer_44, !noalias !2
        store ptr @sharer_39, ptr %sharer_pointer_45, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_46, !noalias !2
        
        %tag_47 = extractvalue %Pos %r_2882, 0
        %fields_48 = extractvalue %Pos %r_2882, 1
        switch i64 %tag_47, label %label_49 [i64 0, label %label_53 i64 1, label %label_57]
    
    label_49:
        
        ret void
    
    label_53:
        
        %utf8StringLiteral_6178 = call ccc %Pos @c_bytearray_construct(i64 5, ptr @utf8StringLiteral_6178.lit)
        
        %stackPointer_51 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_52 = getelementptr %FrameHeader, %StackPointer %stackPointer_51, i64 0, i32 0
        %returnAddress_50 = load %ReturnAddress, ptr %returnAddress_pointer_52, !noalias !2
        musttail call tailcc void %returnAddress_50(%Pos %utf8StringLiteral_6178, %Stack %stack)
        ret void
    
    label_57:
        
        %utf8StringLiteral_6179 = call ccc %Pos @c_bytearray_construct(i64 4, ptr @utf8StringLiteral_6179.lit)
        
        %stackPointer_55 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_56 = getelementptr %FrameHeader, %StackPointer %stackPointer_55, i64 0, i32 0
        %returnAddress_54 = load %ReturnAddress, ptr %returnAddress_pointer_56, !noalias !2
        musttail call tailcc void %returnAddress_54(%Pos %utf8StringLiteral_6179, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_33(%Pos %v_r_3048_6176, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %v_r_3048_6176)
        %stackPointer_58 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_59 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_58, i64 0, i32 1, i32 0
        %sharer_pointer_60 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_58, i64 0, i32 1, i32 1
        %eraser_pointer_61 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_58, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_59, !noalias !2
        store ptr @sharer_39, ptr %sharer_pointer_60, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_61, !noalias !2
        
        %longLiteral_6180 = add i64 8, 0
        
        
        
        musttail call tailcc void @run_2855(i64 %longLiteral_6180, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_4081_4145, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_6168 = call ccc i64 @unboxInt_303(%Pos %v_coe_4081_4145)
        
        
        
        %longLiteral_6170 = add i64 1, 0
        
        %pureApp_6169 = call ccc i64 @infixSub_105(i64 %pureApp_6168, i64 %longLiteral_6170)
        
        
        %stackPointer_62 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_63 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_62, i64 0, i32 1, i32 0
        %sharer_pointer_64 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_62, i64 0, i32 1, i32 1
        %eraser_pointer_65 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_62, i64 0, i32 1, i32 2
        store ptr @returnAddress_33, ptr %returnAddress_pointer_63, !noalias !2
        store ptr @sharer_39, ptr %sharer_pointer_64, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_65, !noalias !2
        
        %longLiteral_6181 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_5751(i64 %longLiteral_6181, i64 %pureApp_6169, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_71(%Pos %returned_6182, %Stack %stack) {
        
    entry:
        
        %stack_72 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_74 = call ccc %StackPointer @stackDeallocate(%Stack %stack_72, i64 24)
        %returnAddress_pointer_75 = getelementptr %FrameHeader, %StackPointer %stackPointer_74, i64 0, i32 0
        %returnAddress_73 = load %ReturnAddress, ptr %returnAddress_pointer_75, !noalias !2
        musttail call tailcc void %returnAddress_73(%Pos %returned_6182, %Stack %stack_72)
        ret void
}



define ccc void @sharer_76(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_77 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_78(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_79 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_79)
        ret void
}



define ccc void @eraser_91(%Environment %environment) {
        
    entry:
        
        %tmp_5953_89_pointer_92 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5953_89 = load %Pos, ptr %tmp_5953_89_pointer_92, !noalias !2
        %acc_3_3_5_169_5458_90_pointer_93 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_5458_90 = load %Pos, ptr %acc_3_3_5_169_5458_90_pointer_93, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5953_89)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_5458_90)
        ret void
}



define tailcc void @toList_1_1_3_167_5448(i64 %start_2_2_4_168_5617, %Pos %acc_3_3_5_169_5458, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_6184 = add i64 1, 0
        
        %pureApp_6183 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_5617, i64 %longLiteral_6184)
        
        
        
        %tag_84 = extractvalue %Pos %pureApp_6183, 0
        %fields_85 = extractvalue %Pos %pureApp_6183, 1
        switch i64 %tag_84, label %label_86 [i64 0, label %label_97 i64 1, label %label_101]
    
    label_86:
        
        ret void
    
    label_97:
        
        %pureApp_6185 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_5617)
        
        
        
        %longLiteral_6187 = add i64 1, 0
        
        %pureApp_6186 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_5617, i64 %longLiteral_6187)
        
        
        
        %fields_87 = call ccc %Object @newObject(ptr @eraser_91, i64 32)
        %environment_88 = call ccc %Environment @objectEnvironment(%Object %fields_87)
        %tmp_5953_pointer_94 = getelementptr <{%Pos, %Pos}>, %Environment %environment_88, i64 0, i32 0
        store %Pos %pureApp_6185, ptr %tmp_5953_pointer_94, !noalias !2
        %acc_3_3_5_169_5458_pointer_95 = getelementptr <{%Pos, %Pos}>, %Environment %environment_88, i64 0, i32 1
        store %Pos %acc_3_3_5_169_5458, ptr %acc_3_3_5_169_5458_pointer_95, !noalias !2
        %make_6188_temporary_96 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_6188 = insertvalue %Pos %make_6188_temporary_96, %Object %fields_87, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_5448(i64 %pureApp_6186, %Pos %make_6188, %Stack %stack)
        ret void
    
    label_101:
        
        %stackPointer_99 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_100 = getelementptr %FrameHeader, %StackPointer %stackPointer_99, i64 0, i32 0
        %returnAddress_98 = load %ReturnAddress, ptr %returnAddress_pointer_100, !noalias !2
        musttail call tailcc void %returnAddress_98(%Pos %acc_3_3_5_169_5458, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_112(%Pos %v_r_3234_32_59_223_5441, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_113 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %index_7_34_198_5636_pointer_114 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_113, i64 0, i32 0
        %index_7_34_198_5636 = load i64, ptr %index_7_34_198_5636_pointer_114, !noalias !2
        %acc_8_35_199_5690_pointer_115 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_113, i64 0, i32 1
        %acc_8_35_199_5690 = load i64, ptr %acc_8_35_199_5690_pointer_115, !noalias !2
        %p_8_9_5385_pointer_116 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_113, i64 0, i32 2
        %p_8_9_5385 = load %Prompt, ptr %p_8_9_5385_pointer_116, !noalias !2
        %v_r_3043_30_194_5531_pointer_117 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_113, i64 0, i32 3
        %v_r_3043_30_194_5531 = load %Pos, ptr %v_r_3043_30_194_5531_pointer_117, !noalias !2
        %tmp_5960_pointer_118 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_113, i64 0, i32 4
        %tmp_5960 = load i64, ptr %tmp_5960_pointer_118, !noalias !2
        
        %tag_119 = extractvalue %Pos %v_r_3234_32_59_223_5441, 0
        %fields_120 = extractvalue %Pos %v_r_3234_32_59_223_5441, 1
        switch i64 %tag_119, label %label_121 [i64 1, label %label_144 i64 0, label %label_151]
    
    label_121:
        
        ret void
    
    label_126:
        
        ret void
    
    label_132:
        call ccc void @erasePositive(%Pos %v_r_3043_30_194_5531)
        
        %pair_127 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_5385)
        %k_13_14_4_5762 = extractvalue <{%Resumption, %Stack}> %pair_127, 0
        %stack_128 = extractvalue <{%Resumption, %Stack}> %pair_127, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5762)
        
        %longLiteral_6200 = add i64 10, 0
        
        
        
        %pureApp_6201 = call ccc %Pos @boxInt_301(i64 %longLiteral_6200)
        
        
        
        %stackPointer_130 = call ccc %StackPointer @stackDeallocate(%Stack %stack_128, i64 24)
        %returnAddress_pointer_131 = getelementptr %FrameHeader, %StackPointer %stackPointer_130, i64 0, i32 0
        %returnAddress_129 = load %ReturnAddress, ptr %returnAddress_pointer_131, !noalias !2
        musttail call tailcc void %returnAddress_129(%Pos %pureApp_6201, %Stack %stack_128)
        ret void
    
    label_135:
        
        ret void
    
    label_141:
        call ccc void @erasePositive(%Pos %v_r_3043_30_194_5531)
        
        %pair_136 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_5385)
        %k_13_14_4_5761 = extractvalue <{%Resumption, %Stack}> %pair_136, 0
        %stack_137 = extractvalue <{%Resumption, %Stack}> %pair_136, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5761)
        
        %longLiteral_6204 = add i64 10, 0
        
        
        
        %pureApp_6205 = call ccc %Pos @boxInt_301(i64 %longLiteral_6204)
        
        
        
        %stackPointer_139 = call ccc %StackPointer @stackDeallocate(%Stack %stack_137, i64 24)
        %returnAddress_pointer_140 = getelementptr %FrameHeader, %StackPointer %stackPointer_139, i64 0, i32 0
        %returnAddress_138 = load %ReturnAddress, ptr %returnAddress_pointer_140, !noalias !2
        musttail call tailcc void %returnAddress_138(%Pos %pureApp_6205, %Stack %stack_137)
        ret void
    
    label_142:
        
        %longLiteral_6207 = add i64 1, 0
        
        %pureApp_6206 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_5636, i64 %longLiteral_6207)
        
        
        
        %longLiteral_6209 = add i64 10, 0
        
        %pureApp_6208 = call ccc i64 @infixMul_99(i64 %longLiteral_6209, i64 %acc_8_35_199_5690)
        
        
        
        %pureApp_6210 = call ccc i64 @toInt_2085(i64 %pureApp_6197)
        
        
        
        %pureApp_6211 = call ccc i64 @infixSub_105(i64 %pureApp_6210, i64 %tmp_5960)
        
        
        
        %pureApp_6212 = call ccc i64 @infixAdd_96(i64 %pureApp_6208, i64 %pureApp_6211)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_5691(i64 %pureApp_6206, i64 %pureApp_6212, %Prompt %p_8_9_5385, %Pos %v_r_3043_30_194_5531, i64 %tmp_5960, %Stack %stack)
        ret void
    
    label_143:
        
        %intLiteral_6203 = add i64 57, 0
        
        %pureApp_6202 = call ccc %Pos @infixLte_2093(i64 %pureApp_6197, i64 %intLiteral_6203)
        
        
        
        %tag_133 = extractvalue %Pos %pureApp_6202, 0
        %fields_134 = extractvalue %Pos %pureApp_6202, 1
        switch i64 %tag_133, label %label_135 [i64 0, label %label_141 i64 1, label %label_142]
    
    label_144:
        %environment_122 = call ccc %Environment @objectEnvironment(%Object %fields_120)
        %v_coe_4050_46_73_237_5476_pointer_123 = getelementptr <{%Pos}>, %Environment %environment_122, i64 0, i32 0
        %v_coe_4050_46_73_237_5476 = load %Pos, ptr %v_coe_4050_46_73_237_5476_pointer_123, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_4050_46_73_237_5476)
        call ccc void @eraseObject(%Object %fields_120)
        
        %pureApp_6197 = call ccc i64 @unboxChar_313(%Pos %v_coe_4050_46_73_237_5476)
        
        
        
        %intLiteral_6199 = add i64 48, 0
        
        %pureApp_6198 = call ccc %Pos @infixGte_2099(i64 %pureApp_6197, i64 %intLiteral_6199)
        
        
        
        %tag_124 = extractvalue %Pos %pureApp_6198, 0
        %fields_125 = extractvalue %Pos %pureApp_6198, 1
        switch i64 %tag_124, label %label_126 [i64 0, label %label_132 i64 1, label %label_143]
    
    label_151:
        %environment_145 = call ccc %Environment @objectEnvironment(%Object %fields_120)
        %v_y_3241_76_103_267_6195_pointer_146 = getelementptr <{%Pos, %Pos}>, %Environment %environment_145, i64 0, i32 0
        %v_y_3241_76_103_267_6195 = load %Pos, ptr %v_y_3241_76_103_267_6195_pointer_146, !noalias !2
        %v_y_3242_77_104_268_6196_pointer_147 = getelementptr <{%Pos, %Pos}>, %Environment %environment_145, i64 0, i32 1
        %v_y_3242_77_104_268_6196 = load %Pos, ptr %v_y_3242_77_104_268_6196_pointer_147, !noalias !2
        call ccc void @eraseObject(%Object %fields_120)
        call ccc void @erasePositive(%Pos %v_r_3043_30_194_5531)
        
        %stackPointer_149 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_150 = getelementptr %FrameHeader, %StackPointer %stackPointer_149, i64 0, i32 0
        %returnAddress_148 = load %ReturnAddress, ptr %returnAddress_pointer_150, !noalias !2
        musttail call tailcc void %returnAddress_148(i64 %acc_8_35_199_5690, %Stack %stack)
        ret void
}



define ccc void @sharer_157(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_158 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_5636_152_pointer_159 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_158, i64 0, i32 0
        %index_7_34_198_5636_152 = load i64, ptr %index_7_34_198_5636_152_pointer_159, !noalias !2
        %acc_8_35_199_5690_153_pointer_160 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_158, i64 0, i32 1
        %acc_8_35_199_5690_153 = load i64, ptr %acc_8_35_199_5690_153_pointer_160, !noalias !2
        %p_8_9_5385_154_pointer_161 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_158, i64 0, i32 2
        %p_8_9_5385_154 = load %Prompt, ptr %p_8_9_5385_154_pointer_161, !noalias !2
        %v_r_3043_30_194_5531_155_pointer_162 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_158, i64 0, i32 3
        %v_r_3043_30_194_5531_155 = load %Pos, ptr %v_r_3043_30_194_5531_155_pointer_162, !noalias !2
        %tmp_5960_156_pointer_163 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_158, i64 0, i32 4
        %tmp_5960_156 = load i64, ptr %tmp_5960_156_pointer_163, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3043_30_194_5531_155)
        call ccc void @shareFrames(%StackPointer %stackPointer_158)
        ret void
}



define ccc void @eraser_169(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_170 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_5636_164_pointer_171 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_170, i64 0, i32 0
        %index_7_34_198_5636_164 = load i64, ptr %index_7_34_198_5636_164_pointer_171, !noalias !2
        %acc_8_35_199_5690_165_pointer_172 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_170, i64 0, i32 1
        %acc_8_35_199_5690_165 = load i64, ptr %acc_8_35_199_5690_165_pointer_172, !noalias !2
        %p_8_9_5385_166_pointer_173 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_170, i64 0, i32 2
        %p_8_9_5385_166 = load %Prompt, ptr %p_8_9_5385_166_pointer_173, !noalias !2
        %v_r_3043_30_194_5531_167_pointer_174 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_170, i64 0, i32 3
        %v_r_3043_30_194_5531_167 = load %Pos, ptr %v_r_3043_30_194_5531_167_pointer_174, !noalias !2
        %tmp_5960_168_pointer_175 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_170, i64 0, i32 4
        %tmp_5960_168 = load i64, ptr %tmp_5960_168_pointer_175, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3043_30_194_5531_167)
        call ccc void @eraseFrames(%StackPointer %stackPointer_170)
        ret void
}



define tailcc void @returnAddress_186(%Pos %returned_6213, %Stack %stack) {
        
    entry:
        
        %stack_187 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_189 = call ccc %StackPointer @stackDeallocate(%Stack %stack_187, i64 24)
        %returnAddress_pointer_190 = getelementptr %FrameHeader, %StackPointer %stackPointer_189, i64 0, i32 0
        %returnAddress_188 = load %ReturnAddress, ptr %returnAddress_pointer_190, !noalias !2
        musttail call tailcc void %returnAddress_188(%Pos %returned_6213, %Stack %stack_187)
        ret void
}



define tailcc void @Exception_7_19_46_210_5518_clause_195(%Object %closure, %Pos %exc_8_20_47_211_5521, %Pos %msg_9_21_48_212_5695, %Stack %stack) {
        
    entry:
        
        %environment_196 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_5541_pointer_197 = getelementptr <{%Prompt}>, %Environment %environment_196, i64 0, i32 0
        %p_6_18_45_209_5541 = load %Prompt, ptr %p_6_18_45_209_5541_pointer_197, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_198 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_5541)
        %k_11_23_50_214_5707 = extractvalue <{%Resumption, %Stack}> %pair_198, 0
        %stack_199 = extractvalue <{%Resumption, %Stack}> %pair_198, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_5707)
        
        %fields_200 = call ccc %Object @newObject(ptr @eraser_91, i64 32)
        %environment_201 = call ccc %Environment @objectEnvironment(%Object %fields_200)
        %exc_8_20_47_211_5521_pointer_204 = getelementptr <{%Pos, %Pos}>, %Environment %environment_201, i64 0, i32 0
        store %Pos %exc_8_20_47_211_5521, ptr %exc_8_20_47_211_5521_pointer_204, !noalias !2
        %msg_9_21_48_212_5695_pointer_205 = getelementptr <{%Pos, %Pos}>, %Environment %environment_201, i64 0, i32 1
        store %Pos %msg_9_21_48_212_5695, ptr %msg_9_21_48_212_5695_pointer_205, !noalias !2
        %make_6214_temporary_206 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_6214 = insertvalue %Pos %make_6214_temporary_206, %Object %fields_200, 1
        
        
        
        %stackPointer_208 = call ccc %StackPointer @stackDeallocate(%Stack %stack_199, i64 24)
        %returnAddress_pointer_209 = getelementptr %FrameHeader, %StackPointer %stackPointer_208, i64 0, i32 0
        %returnAddress_207 = load %ReturnAddress, ptr %returnAddress_pointer_209, !noalias !2
        musttail call tailcc void %returnAddress_207(%Pos %make_6214, %Stack %stack_199)
        ret void
}


@vtable_210 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_5518_clause_195]


define ccc void @eraser_214(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_5541_213_pointer_215 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_5541_213 = load %Prompt, ptr %p_6_18_45_209_5541_213_pointer_215, !noalias !2
        ret void
}



define ccc void @eraser_222(%Environment %environment) {
        
    entry:
        
        %tmp_5962_221_pointer_223 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5962_221 = load %Pos, ptr %tmp_5962_221_pointer_223, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5962_221)
        ret void
}



define tailcc void @returnAddress_218(i64 %v_coe_4049_6_28_55_219_5555, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_6215 = call ccc %Pos @boxChar_311(i64 %v_coe_4049_6_28_55_219_5555)
        
        
        
        %fields_219 = call ccc %Object @newObject(ptr @eraser_222, i64 16)
        %environment_220 = call ccc %Environment @objectEnvironment(%Object %fields_219)
        %tmp_5962_pointer_224 = getelementptr <{%Pos}>, %Environment %environment_220, i64 0, i32 0
        store %Pos %pureApp_6215, ptr %tmp_5962_pointer_224, !noalias !2
        %make_6216_temporary_225 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_6216 = insertvalue %Pos %make_6216_temporary_225, %Object %fields_219, 1
        
        
        
        %stackPointer_227 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_228 = getelementptr %FrameHeader, %StackPointer %stackPointer_227, i64 0, i32 0
        %returnAddress_226 = load %ReturnAddress, ptr %returnAddress_pointer_228, !noalias !2
        musttail call tailcc void %returnAddress_226(%Pos %make_6216, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_5691(i64 %index_7_34_198_5636, i64 %acc_8_35_199_5690, %Prompt %p_8_9_5385, %Pos %v_r_3043_30_194_5531, i64 %tmp_5960, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_3043_30_194_5531)
        %stackPointer_176 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %index_7_34_198_5636_pointer_177 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_176, i64 0, i32 0
        store i64 %index_7_34_198_5636, ptr %index_7_34_198_5636_pointer_177, !noalias !2
        %acc_8_35_199_5690_pointer_178 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_176, i64 0, i32 1
        store i64 %acc_8_35_199_5690, ptr %acc_8_35_199_5690_pointer_178, !noalias !2
        %p_8_9_5385_pointer_179 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_176, i64 0, i32 2
        store %Prompt %p_8_9_5385, ptr %p_8_9_5385_pointer_179, !noalias !2
        %v_r_3043_30_194_5531_pointer_180 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_176, i64 0, i32 3
        store %Pos %v_r_3043_30_194_5531, ptr %v_r_3043_30_194_5531_pointer_180, !noalias !2
        %tmp_5960_pointer_181 = getelementptr <{i64, i64, %Prompt, %Pos, i64}>, %StackPointer %stackPointer_176, i64 0, i32 4
        store i64 %tmp_5960, ptr %tmp_5960_pointer_181, !noalias !2
        %returnAddress_pointer_182 = getelementptr <{<{i64, i64, %Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_176, i64 0, i32 1, i32 0
        %sharer_pointer_183 = getelementptr <{<{i64, i64, %Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_176, i64 0, i32 1, i32 1
        %eraser_pointer_184 = getelementptr <{<{i64, i64, %Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_176, i64 0, i32 1, i32 2
        store ptr @returnAddress_112, ptr %returnAddress_pointer_182, !noalias !2
        store ptr @sharer_157, ptr %sharer_pointer_183, !noalias !2
        store ptr @eraser_169, ptr %eraser_pointer_184, !noalias !2
        
        %stack_185 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_5541 = call ccc %Prompt @currentPrompt(%Stack %stack_185)
        %stackPointer_191 = call ccc %StackPointer @stackAllocate(%Stack %stack_185, i64 24)
        %returnAddress_pointer_192 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_191, i64 0, i32 1, i32 0
        %sharer_pointer_193 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_191, i64 0, i32 1, i32 1
        %eraser_pointer_194 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_191, i64 0, i32 1, i32 2
        store ptr @returnAddress_186, ptr %returnAddress_pointer_192, !noalias !2
        store ptr @sharer_76, ptr %sharer_pointer_193, !noalias !2
        store ptr @eraser_78, ptr %eraser_pointer_194, !noalias !2
        
        %closure_211 = call ccc %Object @newObject(ptr @eraser_214, i64 8)
        %environment_212 = call ccc %Environment @objectEnvironment(%Object %closure_211)
        %p_6_18_45_209_5541_pointer_216 = getelementptr <{%Prompt}>, %Environment %environment_212, i64 0, i32 0
        store %Prompt %p_6_18_45_209_5541, ptr %p_6_18_45_209_5541_pointer_216, !noalias !2
        %vtable_temporary_217 = insertvalue %Neg zeroinitializer, ptr @vtable_210, 0
        %Exception_7_19_46_210_5518 = insertvalue %Neg %vtable_temporary_217, %Object %closure_211, 1
        %stackPointer_229 = call ccc %StackPointer @stackAllocate(%Stack %stack_185, i64 24)
        %returnAddress_pointer_230 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_229, i64 0, i32 1, i32 0
        %sharer_pointer_231 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_229, i64 0, i32 1, i32 1
        %eraser_pointer_232 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_229, i64 0, i32 1, i32 2
        store ptr @returnAddress_218, ptr %returnAddress_pointer_230, !noalias !2
        store ptr @sharer_39, ptr %sharer_pointer_231, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_232, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_3043_30_194_5531, i64 %index_7_34_198_5636, %Neg %Exception_7_19_46_210_5518, %Stack %stack_185)
        ret void
}



define tailcc void @Exception_9_106_133_297_5449_clause_233(%Object %closure, %Pos %exception_10_107_134_298_6217, %Pos %msg_11_108_135_299_6218, %Stack %stack) {
        
    entry:
        
        %environment_234 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_5385_pointer_235 = getelementptr <{%Prompt}>, %Environment %environment_234, i64 0, i32 0
        %p_8_9_5385 = load %Prompt, ptr %p_8_9_5385_pointer_235, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_6217)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_6218)
        
        %pair_236 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_5385)
        %k_13_14_4_5878 = extractvalue <{%Resumption, %Stack}> %pair_236, 0
        %stack_237 = extractvalue <{%Resumption, %Stack}> %pair_236, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5878)
        
        %longLiteral_6219 = add i64 10, 0
        
        
        
        %pureApp_6220 = call ccc %Pos @boxInt_301(i64 %longLiteral_6219)
        
        
        
        %stackPointer_239 = call ccc %StackPointer @stackDeallocate(%Stack %stack_237, i64 24)
        %returnAddress_pointer_240 = getelementptr %FrameHeader, %StackPointer %stackPointer_239, i64 0, i32 0
        %returnAddress_238 = load %ReturnAddress, ptr %returnAddress_pointer_240, !noalias !2
        musttail call tailcc void %returnAddress_238(%Pos %pureApp_6220, %Stack %stack_237)
        ret void
}


@vtable_241 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_5449_clause_233]


define tailcc void @returnAddress_252(i64 %v_coe_4054_22_131_158_322_5439, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_6223 = call ccc %Pos @boxInt_301(i64 %v_coe_4054_22_131_158_322_5439)
        
        
        
        
        
        %pureApp_6224 = call ccc i64 @unboxInt_303(%Pos %pureApp_6223)
        
        
        
        %pureApp_6225 = call ccc %Pos @boxInt_301(i64 %pureApp_6224)
        
        
        
        %stackPointer_254 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_255 = getelementptr %FrameHeader, %StackPointer %stackPointer_254, i64 0, i32 0
        %returnAddress_253 = load %ReturnAddress, ptr %returnAddress_pointer_255, !noalias !2
        musttail call tailcc void %returnAddress_253(%Pos %pureApp_6225, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_264(i64 %v_r_3248_1_9_20_129_156_320_5553, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_6229 = add i64 0, 0
        
        %pureApp_6228 = call ccc i64 @infixSub_105(i64 %longLiteral_6229, i64 %v_r_3248_1_9_20_129_156_320_5553)
        
        
        
        %stackPointer_266 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_267 = getelementptr %FrameHeader, %StackPointer %stackPointer_266, i64 0, i32 0
        %returnAddress_265 = load %ReturnAddress, ptr %returnAddress_pointer_267, !noalias !2
        musttail call tailcc void %returnAddress_265(i64 %pureApp_6228, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_247(i64 %v_r_3247_3_14_123_150_314_5622, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_248 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_5385_pointer_249 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_248, i64 0, i32 0
        %p_8_9_5385 = load %Prompt, ptr %p_8_9_5385_pointer_249, !noalias !2
        %v_r_3043_30_194_5531_pointer_250 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_248, i64 0, i32 1
        %v_r_3043_30_194_5531 = load %Pos, ptr %v_r_3043_30_194_5531_pointer_250, !noalias !2
        %tmp_5960_pointer_251 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_248, i64 0, i32 2
        %tmp_5960 = load i64, ptr %tmp_5960_pointer_251, !noalias !2
        
        %intLiteral_6222 = add i64 45, 0
        
        %pureApp_6221 = call ccc %Pos @infixEq_78(i64 %v_r_3247_3_14_123_150_314_5622, i64 %intLiteral_6222)
        
        
        %stackPointer_256 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_257 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_256, i64 0, i32 1, i32 0
        %sharer_pointer_258 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_256, i64 0, i32 1, i32 1
        %eraser_pointer_259 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_256, i64 0, i32 1, i32 2
        store ptr @returnAddress_252, ptr %returnAddress_pointer_257, !noalias !2
        store ptr @sharer_39, ptr %sharer_pointer_258, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_259, !noalias !2
        
        %tag_260 = extractvalue %Pos %pureApp_6221, 0
        %fields_261 = extractvalue %Pos %pureApp_6221, 1
        switch i64 %tag_260, label %label_262 [i64 0, label %label_263 i64 1, label %label_272]
    
    label_262:
        
        ret void
    
    label_263:
        
        %longLiteral_6226 = add i64 0, 0
        
        %longLiteral_6227 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_5691(i64 %longLiteral_6226, i64 %longLiteral_6227, %Prompt %p_8_9_5385, %Pos %v_r_3043_30_194_5531, i64 %tmp_5960, %Stack %stack)
        ret void
    
    label_272:
        %stackPointer_268 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_269 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 0
        %sharer_pointer_270 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 1
        %eraser_pointer_271 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 2
        store ptr @returnAddress_264, ptr %returnAddress_pointer_269, !noalias !2
        store ptr @sharer_39, ptr %sharer_pointer_270, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_271, !noalias !2
        
        %longLiteral_6230 = add i64 1, 0
        
        %longLiteral_6231 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_5691(i64 %longLiteral_6230, i64 %longLiteral_6231, %Prompt %p_8_9_5385, %Pos %v_r_3043_30_194_5531, i64 %tmp_5960, %Stack %stack)
        ret void
}



define ccc void @sharer_276(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_277 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_5385_273_pointer_278 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_277, i64 0, i32 0
        %p_8_9_5385_273 = load %Prompt, ptr %p_8_9_5385_273_pointer_278, !noalias !2
        %v_r_3043_30_194_5531_274_pointer_279 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_277, i64 0, i32 1
        %v_r_3043_30_194_5531_274 = load %Pos, ptr %v_r_3043_30_194_5531_274_pointer_279, !noalias !2
        %tmp_5960_275_pointer_280 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_277, i64 0, i32 2
        %tmp_5960_275 = load i64, ptr %tmp_5960_275_pointer_280, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3043_30_194_5531_274)
        call ccc void @shareFrames(%StackPointer %stackPointer_277)
        ret void
}



define ccc void @eraser_284(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_285 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_5385_281_pointer_286 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_285, i64 0, i32 0
        %p_8_9_5385_281 = load %Prompt, ptr %p_8_9_5385_281_pointer_286, !noalias !2
        %v_r_3043_30_194_5531_282_pointer_287 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_285, i64 0, i32 1
        %v_r_3043_30_194_5531_282 = load %Pos, ptr %v_r_3043_30_194_5531_282_pointer_287, !noalias !2
        %tmp_5960_283_pointer_288 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_285, i64 0, i32 2
        %tmp_5960_283 = load i64, ptr %tmp_5960_283_pointer_288, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3043_30_194_5531_282)
        call ccc void @eraseFrames(%StackPointer %stackPointer_285)
        ret void
}



define tailcc void @returnAddress_109(%Pos %v_r_3043_30_194_5531, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_110 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_5385_pointer_111 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_110, i64 0, i32 0
        %p_8_9_5385 = load %Prompt, ptr %p_8_9_5385_pointer_111, !noalias !2
        
        %intLiteral_6194 = add i64 48, 0
        
        %pureApp_6193 = call ccc i64 @toInt_2085(i64 %intLiteral_6194)
        
        
        
        %closure_242 = call ccc %Object @newObject(ptr @eraser_214, i64 8)
        %environment_243 = call ccc %Environment @objectEnvironment(%Object %closure_242)
        %p_8_9_5385_pointer_245 = getelementptr <{%Prompt}>, %Environment %environment_243, i64 0, i32 0
        store %Prompt %p_8_9_5385, ptr %p_8_9_5385_pointer_245, !noalias !2
        %vtable_temporary_246 = insertvalue %Neg zeroinitializer, ptr @vtable_241, 0
        %Exception_9_106_133_297_5449 = insertvalue %Neg %vtable_temporary_246, %Object %closure_242, 1
        call ccc void @sharePositive(%Pos %v_r_3043_30_194_5531)
        %stackPointer_289 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_5385_pointer_290 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_289, i64 0, i32 0
        store %Prompt %p_8_9_5385, ptr %p_8_9_5385_pointer_290, !noalias !2
        %v_r_3043_30_194_5531_pointer_291 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_289, i64 0, i32 1
        store %Pos %v_r_3043_30_194_5531, ptr %v_r_3043_30_194_5531_pointer_291, !noalias !2
        %tmp_5960_pointer_292 = getelementptr <{%Prompt, %Pos, i64}>, %StackPointer %stackPointer_289, i64 0, i32 2
        store i64 %pureApp_6193, ptr %tmp_5960_pointer_292, !noalias !2
        %returnAddress_pointer_293 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_289, i64 0, i32 1, i32 0
        %sharer_pointer_294 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_289, i64 0, i32 1, i32 1
        %eraser_pointer_295 = getelementptr <{<{%Prompt, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_289, i64 0, i32 1, i32 2
        store ptr @returnAddress_247, ptr %returnAddress_pointer_293, !noalias !2
        store ptr @sharer_276, ptr %sharer_pointer_294, !noalias !2
        store ptr @eraser_284, ptr %eraser_pointer_295, !noalias !2
        
        %longLiteral_6232 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_3043_30_194_5531, i64 %longLiteral_6232, %Neg %Exception_9_106_133_297_5449, %Stack %stack)
        ret void
}



define ccc void @sharer_297(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_298 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_5385_296_pointer_299 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_298, i64 0, i32 0
        %p_8_9_5385_296 = load %Prompt, ptr %p_8_9_5385_296_pointer_299, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_298)
        ret void
}



define ccc void @eraser_301(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_302 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_5385_300_pointer_303 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_302, i64 0, i32 0
        %p_8_9_5385_300 = load %Prompt, ptr %p_8_9_5385_300_pointer_303, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_302)
        ret void
}


@utf8StringLiteral_6233.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_106(%Pos %v_r_3042_24_188_5463, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_107 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_5385_pointer_108 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_107, i64 0, i32 0
        %p_8_9_5385 = load %Prompt, ptr %p_8_9_5385_pointer_108, !noalias !2
        %stackPointer_304 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_5385_pointer_305 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_304, i64 0, i32 0
        store %Prompt %p_8_9_5385, ptr %p_8_9_5385_pointer_305, !noalias !2
        %returnAddress_pointer_306 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_304, i64 0, i32 1, i32 0
        %sharer_pointer_307 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_304, i64 0, i32 1, i32 1
        %eraser_pointer_308 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_304, i64 0, i32 1, i32 2
        store ptr @returnAddress_109, ptr %returnAddress_pointer_306, !noalias !2
        store ptr @sharer_297, ptr %sharer_pointer_307, !noalias !2
        store ptr @eraser_301, ptr %eraser_pointer_308, !noalias !2
        
        %tag_309 = extractvalue %Pos %v_r_3042_24_188_5463, 0
        %fields_310 = extractvalue %Pos %v_r_3042_24_188_5463, 1
        switch i64 %tag_309, label %label_311 [i64 0, label %label_315 i64 1, label %label_321]
    
    label_311:
        
        ret void
    
    label_315:
        
        %utf8StringLiteral_6233 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_6233.lit)
        
        %stackPointer_313 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_314 = getelementptr %FrameHeader, %StackPointer %stackPointer_313, i64 0, i32 0
        %returnAddress_312 = load %ReturnAddress, ptr %returnAddress_pointer_314, !noalias !2
        musttail call tailcc void %returnAddress_312(%Pos %utf8StringLiteral_6233, %Stack %stack)
        ret void
    
    label_321:
        %environment_316 = call ccc %Environment @objectEnvironment(%Object %fields_310)
        %v_y_3876_8_29_193_5696_pointer_317 = getelementptr <{%Pos}>, %Environment %environment_316, i64 0, i32 0
        %v_y_3876_8_29_193_5696 = load %Pos, ptr %v_y_3876_8_29_193_5696_pointer_317, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3876_8_29_193_5696)
        call ccc void @eraseObject(%Object %fields_310)
        
        %stackPointer_319 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_320 = getelementptr %FrameHeader, %StackPointer %stackPointer_319, i64 0, i32 0
        %returnAddress_318 = load %ReturnAddress, ptr %returnAddress_pointer_320, !noalias !2
        musttail call tailcc void %returnAddress_318(%Pos %v_y_3876_8_29_193_5696, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_103(%Pos %v_r_3041_13_177_5510, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_104 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_5385_pointer_105 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_104, i64 0, i32 0
        %p_8_9_5385 = load %Prompt, ptr %p_8_9_5385_pointer_105, !noalias !2
        %stackPointer_324 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_5385_pointer_325 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_324, i64 0, i32 0
        store %Prompt %p_8_9_5385, ptr %p_8_9_5385_pointer_325, !noalias !2
        %returnAddress_pointer_326 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_324, i64 0, i32 1, i32 0
        %sharer_pointer_327 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_324, i64 0, i32 1, i32 1
        %eraser_pointer_328 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_324, i64 0, i32 1, i32 2
        store ptr @returnAddress_106, ptr %returnAddress_pointer_326, !noalias !2
        store ptr @sharer_297, ptr %sharer_pointer_327, !noalias !2
        store ptr @eraser_301, ptr %eraser_pointer_328, !noalias !2
        
        %tag_329 = extractvalue %Pos %v_r_3041_13_177_5510, 0
        %fields_330 = extractvalue %Pos %v_r_3041_13_177_5510, 1
        switch i64 %tag_329, label %label_331 [i64 0, label %label_336 i64 1, label %label_348]
    
    label_331:
        
        ret void
    
    label_336:
        
        %make_6234_temporary_332 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_6234 = insertvalue %Pos %make_6234_temporary_332, %Object null, 1
        
        
        
        %stackPointer_334 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_335 = getelementptr %FrameHeader, %StackPointer %stackPointer_334, i64 0, i32 0
        %returnAddress_333 = load %ReturnAddress, ptr %returnAddress_pointer_335, !noalias !2
        musttail call tailcc void %returnAddress_333(%Pos %make_6234, %Stack %stack)
        ret void
    
    label_348:
        %environment_337 = call ccc %Environment @objectEnvironment(%Object %fields_330)
        %v_y_3385_10_21_185_5507_pointer_338 = getelementptr <{%Pos, %Pos}>, %Environment %environment_337, i64 0, i32 0
        %v_y_3385_10_21_185_5507 = load %Pos, ptr %v_y_3385_10_21_185_5507_pointer_338, !noalias !2
        %v_y_3386_11_22_186_5683_pointer_339 = getelementptr <{%Pos, %Pos}>, %Environment %environment_337, i64 0, i32 1
        %v_y_3386_11_22_186_5683 = load %Pos, ptr %v_y_3386_11_22_186_5683_pointer_339, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3385_10_21_185_5507)
        call ccc void @eraseObject(%Object %fields_330)
        
        %fields_340 = call ccc %Object @newObject(ptr @eraser_222, i64 16)
        %environment_341 = call ccc %Environment @objectEnvironment(%Object %fields_340)
        %v_y_3385_10_21_185_5507_pointer_343 = getelementptr <{%Pos}>, %Environment %environment_341, i64 0, i32 0
        store %Pos %v_y_3385_10_21_185_5507, ptr %v_y_3385_10_21_185_5507_pointer_343, !noalias !2
        %make_6235_temporary_344 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_6235 = insertvalue %Pos %make_6235_temporary_344, %Object %fields_340, 1
        
        
        
        %stackPointer_346 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_347 = getelementptr %FrameHeader, %StackPointer %stackPointer_346, i64 0, i32 0
        %returnAddress_345 = load %ReturnAddress, ptr %returnAddress_pointer_347, !noalias !2
        musttail call tailcc void %returnAddress_345(%Pos %make_6235, %Stack %stack)
        ret void
}



define tailcc void @main_2856(%Stack %stack) {
        
    entry:
        
        %stackPointer_66 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_67 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_66, i64 0, i32 1, i32 0
        %sharer_pointer_68 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_66, i64 0, i32 1, i32 1
        %eraser_pointer_69 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_66, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_67, !noalias !2
        store ptr @sharer_39, ptr %sharer_pointer_68, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_69, !noalias !2
        
        %stack_70 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_5385 = call ccc %Prompt @currentPrompt(%Stack %stack_70)
        %stackPointer_80 = call ccc %StackPointer @stackAllocate(%Stack %stack_70, i64 24)
        %returnAddress_pointer_81 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_80, i64 0, i32 1, i32 0
        %sharer_pointer_82 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_80, i64 0, i32 1, i32 1
        %eraser_pointer_83 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_80, i64 0, i32 1, i32 2
        store ptr @returnAddress_71, ptr %returnAddress_pointer_81, !noalias !2
        store ptr @sharer_76, ptr %sharer_pointer_82, !noalias !2
        store ptr @eraser_78, ptr %eraser_pointer_83, !noalias !2
        
        %pureApp_6189 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_6191 = add i64 1, 0
        
        %pureApp_6190 = call ccc i64 @infixSub_105(i64 %pureApp_6189, i64 %longLiteral_6191)
        
        
        
        %make_6192_temporary_102 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_6192 = insertvalue %Pos %make_6192_temporary_102, %Object null, 1
        
        
        %stackPointer_351 = call ccc %StackPointer @stackAllocate(%Stack %stack_70, i64 32)
        %p_8_9_5385_pointer_352 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_351, i64 0, i32 0
        store %Prompt %p_8_9_5385, ptr %p_8_9_5385_pointer_352, !noalias !2
        %returnAddress_pointer_353 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_351, i64 0, i32 1, i32 0
        %sharer_pointer_354 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_351, i64 0, i32 1, i32 1
        %eraser_pointer_355 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_351, i64 0, i32 1, i32 2
        store ptr @returnAddress_103, ptr %returnAddress_pointer_353, !noalias !2
        store ptr @sharer_297, ptr %sharer_pointer_354, !noalias !2
        store ptr @eraser_301, ptr %eraser_pointer_355, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_5448(i64 %pureApp_6190, %Pos %make_6192, %Stack %stack_70)
        ret void
}



define tailcc void @loop_5_9_4455(i64 %i_6_10_4464, %Pos %tmp_5988, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_6007 = add i64 0, 0
        
        %pureApp_6006 = call ccc %Pos @infixLt_178(i64 %i_6_10_4464, i64 %longLiteral_6007)
        
        
        
        %tag_356 = extractvalue %Pos %pureApp_6006, 0
        %fields_357 = extractvalue %Pos %pureApp_6006, 1
        switch i64 %tag_356, label %label_358 [i64 0, label %label_363 i64 1, label %label_365]
    
    label_358:
        
        ret void
    
    label_363:
        call ccc void @erasePositive(%Pos %tmp_5988)
        
        %unitLiteral_6008_temporary_359 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6008 = insertvalue %Pos %unitLiteral_6008_temporary_359, %Object null, 1
        
        %stackPointer_361 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_362 = getelementptr %FrameHeader, %StackPointer %stackPointer_361, i64 0, i32 0
        %returnAddress_360 = load %ReturnAddress, ptr %returnAddress_pointer_362, !noalias !2
        musttail call tailcc void %returnAddress_360(%Pos %unitLiteral_6008, %Stack %stack)
        ret void
    
    label_365:
        
        %booleanLiteral_6010_temporary_364 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6010 = insertvalue %Pos %booleanLiteral_6010_temporary_364, %Object null, 1
        
        call ccc void @sharePositive(%Pos %tmp_5988)
        %pureApp_6009 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5988, i64 %i_6_10_4464, %Pos %booleanLiteral_6010)
        call ccc void @erasePositive(%Pos %pureApp_6009)
        
        
        
        %longLiteral_6012 = add i64 1, 0
        
        %pureApp_6011 = call ccc i64 @infixAdd_96(i64 %i_6_10_4464, i64 %longLiteral_6012)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_4455(i64 %pureApp_6011, %Pos %tmp_5988, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_370(%Pos %returnValue_371, %Stack %stack) {
        
    entry:
        
        %stackPointer_372 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %tmp_5988_pointer_373 = getelementptr <{%Pos}>, %StackPointer %stackPointer_372, i64 0, i32 0
        %tmp_5988 = load %Pos, ptr %tmp_5988_pointer_373, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5988)
        %stackPointer_375 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_376 = getelementptr %FrameHeader, %StackPointer %stackPointer_375, i64 0, i32 0
        %returnAddress_374 = load %ReturnAddress, ptr %returnAddress_pointer_376, !noalias !2
        musttail call tailcc void %returnAddress_374(%Pos %returnValue_371, %Stack %stack)
        ret void
}



define ccc void @sharer_378(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_379 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_5988_377_pointer_380 = getelementptr <{%Pos}>, %StackPointer %stackPointer_379, i64 0, i32 0
        %tmp_5988_377 = load %Pos, ptr %tmp_5988_377_pointer_380, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5988_377)
        call ccc void @shareFrames(%StackPointer %stackPointer_379)
        ret void
}



define ccc void @eraser_382(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_383 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_5988_381_pointer_384 = getelementptr <{%Pos}>, %StackPointer %stackPointer_383, i64 0, i32 0
        %tmp_5988_381 = load %Pos, ptr %tmp_5988_381_pointer_384, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5988_381)
        call ccc void @eraseFrames(%StackPointer %stackPointer_383)
        ret void
}



define tailcc void @loop_5_9_4470(i64 %i_6_10_4479, %Pos %tmp_5891, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_6017 = add i64 0, 0
        
        %pureApp_6016 = call ccc %Pos @infixLt_178(i64 %i_6_10_4479, i64 %longLiteral_6017)
        
        
        
        %tag_390 = extractvalue %Pos %pureApp_6016, 0
        %fields_391 = extractvalue %Pos %pureApp_6016, 1
        switch i64 %tag_390, label %label_392 [i64 0, label %label_397 i64 1, label %label_399]
    
    label_392:
        
        ret void
    
    label_397:
        call ccc void @erasePositive(%Pos %tmp_5891)
        
        %unitLiteral_6018_temporary_393 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6018 = insertvalue %Pos %unitLiteral_6018_temporary_393, %Object null, 1
        
        %stackPointer_395 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_396 = getelementptr %FrameHeader, %StackPointer %stackPointer_395, i64 0, i32 0
        %returnAddress_394 = load %ReturnAddress, ptr %returnAddress_pointer_396, !noalias !2
        musttail call tailcc void %returnAddress_394(%Pos %unitLiteral_6018, %Stack %stack)
        ret void
    
    label_399:
        
        %booleanLiteral_6020_temporary_398 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6020 = insertvalue %Pos %booleanLiteral_6020_temporary_398, %Object null, 1
        
        call ccc void @sharePositive(%Pos %tmp_5891)
        %pureApp_6019 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5891, i64 %i_6_10_4479, %Pos %booleanLiteral_6020)
        call ccc void @erasePositive(%Pos %pureApp_6019)
        
        
        
        %longLiteral_6022 = add i64 1, 0
        
        %pureApp_6021 = call ccc i64 @infixAdd_96(i64 %i_6_10_4479, i64 %longLiteral_6022)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_4470(i64 %pureApp_6021, %Pos %tmp_5891, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_405(%Pos %returnValue_406, %Stack %stack) {
        
    entry:
        
        %stackPointer_407 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %tmp_5891_pointer_408 = getelementptr <{%Pos}>, %StackPointer %stackPointer_407, i64 0, i32 0
        %tmp_5891 = load %Pos, ptr %tmp_5891_pointer_408, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5891)
        %stackPointer_410 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_411 = getelementptr %FrameHeader, %StackPointer %stackPointer_410, i64 0, i32 0
        %returnAddress_409 = load %ReturnAddress, ptr %returnAddress_pointer_411, !noalias !2
        musttail call tailcc void %returnAddress_409(%Pos %returnValue_406, %Stack %stack)
        ret void
}



define tailcc void @loop_5_9_4485(i64 %i_6_10_4494, %Pos %tmp_5895, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_6027 = add i64 0, 0
        
        %pureApp_6026 = call ccc %Pos @infixLt_178(i64 %i_6_10_4494, i64 %longLiteral_6027)
        
        
        
        %tag_419 = extractvalue %Pos %pureApp_6026, 0
        %fields_420 = extractvalue %Pos %pureApp_6026, 1
        switch i64 %tag_419, label %label_421 [i64 0, label %label_426 i64 1, label %label_428]
    
    label_421:
        
        ret void
    
    label_426:
        call ccc void @erasePositive(%Pos %tmp_5895)
        
        %unitLiteral_6028_temporary_422 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6028 = insertvalue %Pos %unitLiteral_6028_temporary_422, %Object null, 1
        
        %stackPointer_424 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_425 = getelementptr %FrameHeader, %StackPointer %stackPointer_424, i64 0, i32 0
        %returnAddress_423 = load %ReturnAddress, ptr %returnAddress_pointer_425, !noalias !2
        musttail call tailcc void %returnAddress_423(%Pos %unitLiteral_6028, %Stack %stack)
        ret void
    
    label_428:
        
        %booleanLiteral_6030_temporary_427 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6030 = insertvalue %Pos %booleanLiteral_6030_temporary_427, %Object null, 1
        
        call ccc void @sharePositive(%Pos %tmp_5895)
        %pureApp_6029 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5895, i64 %i_6_10_4494, %Pos %booleanLiteral_6030)
        call ccc void @erasePositive(%Pos %pureApp_6029)
        
        
        
        %longLiteral_6032 = add i64 1, 0
        
        %pureApp_6031 = call ccc i64 @infixAdd_96(i64 %i_6_10_4494, i64 %longLiteral_6032)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_4485(i64 %pureApp_6031, %Pos %tmp_5895, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_435(%Pos %returnValue_436, %Stack %stack) {
        
    entry:
        
        %stackPointer_437 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %tmp_5895_pointer_438 = getelementptr <{%Pos}>, %StackPointer %stackPointer_437, i64 0, i32 0
        %tmp_5895 = load %Pos, ptr %tmp_5895_pointer_438, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5895)
        %stackPointer_440 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_441 = getelementptr %FrameHeader, %StackPointer %stackPointer_440, i64 0, i32 0
        %returnAddress_439 = load %ReturnAddress, ptr %returnAddress_pointer_441, !noalias !2
        musttail call tailcc void %returnAddress_439(%Pos %returnValue_436, %Stack %stack)
        ret void
}



define tailcc void @loop_5_9_4500(i64 %i_6_10_4509, %Pos %tmp_5899, %Pos %tmp_5900, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_6039 = add i64 0, 0
        
        %pureApp_6038 = call ccc %Pos @infixLt_178(i64 %i_6_10_4509, i64 %longLiteral_6039)
        
        
        
        %tag_449 = extractvalue %Pos %pureApp_6038, 0
        %fields_450 = extractvalue %Pos %pureApp_6038, 1
        switch i64 %tag_449, label %label_451 [i64 0, label %label_456 i64 1, label %label_457]
    
    label_451:
        
        ret void
    
    label_456:
        call ccc void @erasePositive(%Pos %tmp_5900)
        call ccc void @erasePositive(%Pos %tmp_5899)
        
        %unitLiteral_6040_temporary_452 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6040 = insertvalue %Pos %unitLiteral_6040_temporary_452, %Object null, 1
        
        %stackPointer_454 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_455 = getelementptr %FrameHeader, %StackPointer %stackPointer_454, i64 0, i32 0
        %returnAddress_453 = load %ReturnAddress, ptr %returnAddress_pointer_455, !noalias !2
        musttail call tailcc void %returnAddress_453(%Pos %unitLiteral_6040, %Stack %stack)
        ret void
    
    label_457:
        
        call ccc void @sharePositive(%Pos %tmp_5900)
        call ccc void @sharePositive(%Pos %tmp_5899)
        %pureApp_6041 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5900, i64 %i_6_10_4509, %Pos %tmp_5899)
        call ccc void @erasePositive(%Pos %pureApp_6041)
        
        
        
        %longLiteral_6043 = add i64 1, 0
        
        %pureApp_6042 = call ccc i64 @infixAdd_96(i64 %i_6_10_4509, i64 %longLiteral_6043)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_4500(i64 %pureApp_6042, %Pos %tmp_5899, %Pos %tmp_5900, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_465(%Pos %returnValue_466, %Stack %stack) {
        
    entry:
        
        %stackPointer_467 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %tmp_5900_pointer_468 = getelementptr <{%Pos}>, %StackPointer %stackPointer_467, i64 0, i32 0
        %tmp_5900 = load %Pos, ptr %tmp_5900_pointer_468, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5900)
        %stackPointer_470 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_471 = getelementptr %FrameHeader, %StackPointer %stackPointer_470, i64 0, i32 0
        %returnAddress_469 = load %ReturnAddress, ptr %returnAddress_pointer_471, !noalias !2
        musttail call tailcc void %returnAddress_469(%Pos %returnValue_466, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_480(%Pos %returned_6045, %Stack %stack) {
        
    entry:
        
        %stack_481 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_483 = call ccc %StackPointer @stackDeallocate(%Stack %stack_481, i64 24)
        %returnAddress_pointer_484 = getelementptr %FrameHeader, %StackPointer %stackPointer_483, i64 0, i32 0
        %returnAddress_482 = load %ReturnAddress, ptr %returnAddress_pointer_484, !noalias !2
        musttail call tailcc void %returnAddress_482(%Pos %returned_6045, %Stack %stack_481)
        ret void
}



define tailcc void @returnAddress_527(%Pos %__8_4642, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_528 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_529 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_528, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_529, !noalias !2
        %c_2872_pointer_530 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_528, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_530, !noalias !2
        %i_6_4639_pointer_531 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_528, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_531, !noalias !2
        %p_4194_pointer_532 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_528, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_532, !noalias !2
        %queenRows_2864_pointer_533 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_528, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_533, !noalias !2
        %freeMins_2863_pointer_534 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_528, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_534, !noalias !2
        %freeMaxs_2862_pointer_535 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_528, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_535, !noalias !2
        %n_2854_pointer_536 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_528, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_536, !noalias !2
        call ccc void @erasePositive(%Pos %__8_4642)
        
        %longLiteral_6050 = add i64 1, 0
        
        %pureApp_6049 = call ccc i64 @infixAdd_96(i64 %i_6_4639, i64 %longLiteral_6050)
        
        
        
        
        
        musttail call tailcc void @loop_5_4636(i64 %pureApp_6049, %Reference %freeRows_2861, i64 %c_2872, %Prompt %p_4194, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack)
        ret void
}



define ccc void @sharer_545(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_546 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_537_pointer_547 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_546, i64 0, i32 0
        %freeRows_2861_537 = load %Reference, ptr %freeRows_2861_537_pointer_547, !noalias !2
        %c_2872_538_pointer_548 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_546, i64 0, i32 1
        %c_2872_538 = load i64, ptr %c_2872_538_pointer_548, !noalias !2
        %i_6_4639_539_pointer_549 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_546, i64 0, i32 2
        %i_6_4639_539 = load i64, ptr %i_6_4639_539_pointer_549, !noalias !2
        %p_4194_540_pointer_550 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_546, i64 0, i32 3
        %p_4194_540 = load %Prompt, ptr %p_4194_540_pointer_550, !noalias !2
        %queenRows_2864_541_pointer_551 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_546, i64 0, i32 4
        %queenRows_2864_541 = load %Reference, ptr %queenRows_2864_541_pointer_551, !noalias !2
        %freeMins_2863_542_pointer_552 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_546, i64 0, i32 5
        %freeMins_2863_542 = load %Reference, ptr %freeMins_2863_542_pointer_552, !noalias !2
        %freeMaxs_2862_543_pointer_553 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_546, i64 0, i32 6
        %freeMaxs_2862_543 = load %Reference, ptr %freeMaxs_2862_543_pointer_553, !noalias !2
        %n_2854_544_pointer_554 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_546, i64 0, i32 7
        %n_2854_544 = load i64, ptr %n_2854_544_pointer_554, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_546)
        ret void
}



define ccc void @eraser_563(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_564 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_555_pointer_565 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_564, i64 0, i32 0
        %freeRows_2861_555 = load %Reference, ptr %freeRows_2861_555_pointer_565, !noalias !2
        %c_2872_556_pointer_566 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_564, i64 0, i32 1
        %c_2872_556 = load i64, ptr %c_2872_556_pointer_566, !noalias !2
        %i_6_4639_557_pointer_567 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_564, i64 0, i32 2
        %i_6_4639_557 = load i64, ptr %i_6_4639_557_pointer_567, !noalias !2
        %p_4194_558_pointer_568 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_564, i64 0, i32 3
        %p_4194_558 = load %Prompt, ptr %p_4194_558_pointer_568, !noalias !2
        %queenRows_2864_559_pointer_569 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_564, i64 0, i32 4
        %queenRows_2864_559 = load %Reference, ptr %queenRows_2864_559_pointer_569, !noalias !2
        %freeMins_2863_560_pointer_570 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_564, i64 0, i32 5
        %freeMins_2863_560 = load %Reference, ptr %freeMins_2863_560_pointer_570, !noalias !2
        %freeMaxs_2862_561_pointer_571 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_564, i64 0, i32 6
        %freeMaxs_2862_561 = load %Reference, ptr %freeMaxs_2862_561_pointer_571, !noalias !2
        %n_2854_562_pointer_572 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_564, i64 0, i32 7
        %n_2854_562 = load i64, ptr %n_2854_562_pointer_572, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_564)
        ret void
}



define tailcc void @returnAddress_678(%Pos %v_r_2995_11_77_4684, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_679 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %c_2872_pointer_680 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_679, i64 0, i32 0
        %c_2872 = load i64, ptr %c_2872_pointer_680, !noalias !2
        %i_6_4639_pointer_681 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_679, i64 0, i32 1
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_681, !noalias !2
        %n_2854_pointer_682 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_679, i64 0, i32 2
        %n_2854 = load i64, ptr %n_2854_pointer_682, !noalias !2
        
        %pureApp_6075 = call ccc i64 @infixSub_105(i64 %c_2872, i64 %i_6_4639)
        
        
        
        %longLiteral_6077 = add i64 1, 0
        
        %pureApp_6076 = call ccc i64 @infixSub_105(i64 %n_2854, i64 %longLiteral_6077)
        
        
        
        %pureApp_6078 = call ccc i64 @infixAdd_96(i64 %pureApp_6075, i64 %pureApp_6076)
        
        
        
        %booleanLiteral_6080_temporary_683 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6080 = insertvalue %Pos %booleanLiteral_6080_temporary_683, %Object null, 1
        
        %pureApp_6079 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2995_11_77_4684, i64 %pureApp_6078, %Pos %booleanLiteral_6080)
        
        
        
        %stackPointer_685 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_686 = getelementptr %FrameHeader, %StackPointer %stackPointer_685, i64 0, i32 0
        %returnAddress_684 = load %ReturnAddress, ptr %returnAddress_pointer_686, !noalias !2
        musttail call tailcc void %returnAddress_684(%Pos %pureApp_6079, %Stack %stack)
        ret void
}



define ccc void @sharer_690(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_691 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %c_2872_687_pointer_692 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_691, i64 0, i32 0
        %c_2872_687 = load i64, ptr %c_2872_687_pointer_692, !noalias !2
        %i_6_4639_688_pointer_693 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_691, i64 0, i32 1
        %i_6_4639_688 = load i64, ptr %i_6_4639_688_pointer_693, !noalias !2
        %n_2854_689_pointer_694 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_691, i64 0, i32 2
        %n_2854_689 = load i64, ptr %n_2854_689_pointer_694, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_691)
        ret void
}



define ccc void @eraser_698(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_699 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %c_2872_695_pointer_700 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_699, i64 0, i32 0
        %c_2872_695 = load i64, ptr %c_2872_695_pointer_700, !noalias !2
        %i_6_4639_696_pointer_701 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_699, i64 0, i32 1
        %i_6_4639_696 = load i64, ptr %i_6_4639_696_pointer_701, !noalias !2
        %n_2854_697_pointer_702 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_699, i64 0, i32 2
        %n_2854_697 = load i64, ptr %n_2854_697_pointer_702, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_699)
        ret void
}



define tailcc void @returnAddress_671(%Pos %v_r_2993_7_73_4664, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_672 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %c_2872_pointer_673 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 0
        %c_2872 = load i64, ptr %c_2872_pointer_673, !noalias !2
        %n_2854_pointer_674 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 1
        %n_2854 = load i64, ptr %n_2854_pointer_674, !noalias !2
        %i_6_4639_pointer_675 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_675, !noalias !2
        %freeMins_2863_pointer_676 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_672, i64 0, i32 3
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_676, !noalias !2
        
        %pureApp_6072 = call ccc i64 @infixAdd_96(i64 %c_2872, i64 %i_6_4639)
        
        
        
        %booleanLiteral_6074_temporary_677 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6074 = insertvalue %Pos %booleanLiteral_6074_temporary_677, %Object null, 1
        
        %pureApp_6073 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2993_7_73_4664, i64 %pureApp_6072, %Pos %booleanLiteral_6074)
        call ccc void @erasePositive(%Pos %pureApp_6073)
        
        
        %stackPointer_703 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 48)
        %c_2872_pointer_704 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_703, i64 0, i32 0
        store i64 %c_2872, ptr %c_2872_pointer_704, !noalias !2
        %i_6_4639_pointer_705 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_703, i64 0, i32 1
        store i64 %i_6_4639, ptr %i_6_4639_pointer_705, !noalias !2
        %n_2854_pointer_706 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_703, i64 0, i32 2
        store i64 %n_2854, ptr %n_2854_pointer_706, !noalias !2
        %returnAddress_pointer_707 = getelementptr <{<{i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_703, i64 0, i32 1, i32 0
        %sharer_pointer_708 = getelementptr <{<{i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_703, i64 0, i32 1, i32 1
        %eraser_pointer_709 = getelementptr <{<{i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_703, i64 0, i32 1, i32 2
        store ptr @returnAddress_678, ptr %returnAddress_pointer_707, !noalias !2
        store ptr @sharer_690, ptr %sharer_pointer_708, !noalias !2
        store ptr @eraser_698, ptr %eraser_pointer_709, !noalias !2
        
        %get_6081_pointer_710 = call ccc ptr @getVarPointer(%Reference %freeMins_2863, %Stack %stack)
        %freeMins_2863_old_711 = load %Pos, ptr %get_6081_pointer_710, !noalias !2
        call ccc void @sharePositive(%Pos %freeMins_2863_old_711)
        %get_6081 = load %Pos, ptr %get_6081_pointer_710, !noalias !2
        
        %stackPointer_713 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_714 = getelementptr %FrameHeader, %StackPointer %stackPointer_713, i64 0, i32 0
        %returnAddress_712 = load %ReturnAddress, ptr %returnAddress_pointer_714, !noalias !2
        musttail call tailcc void %returnAddress_712(%Pos %get_6081, %Stack %stack)
        ret void
}



define ccc void @sharer_719(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_720 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %c_2872_715_pointer_721 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_720, i64 0, i32 0
        %c_2872_715 = load i64, ptr %c_2872_715_pointer_721, !noalias !2
        %n_2854_716_pointer_722 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_720, i64 0, i32 1
        %n_2854_716 = load i64, ptr %n_2854_716_pointer_722, !noalias !2
        %i_6_4639_717_pointer_723 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_720, i64 0, i32 2
        %i_6_4639_717 = load i64, ptr %i_6_4639_717_pointer_723, !noalias !2
        %freeMins_2863_718_pointer_724 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_720, i64 0, i32 3
        %freeMins_2863_718 = load %Reference, ptr %freeMins_2863_718_pointer_724, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_720)
        ret void
}



define ccc void @eraser_729(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_730 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %c_2872_725_pointer_731 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_730, i64 0, i32 0
        %c_2872_725 = load i64, ptr %c_2872_725_pointer_731, !noalias !2
        %n_2854_726_pointer_732 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_730, i64 0, i32 1
        %n_2854_726 = load i64, ptr %n_2854_726_pointer_732, !noalias !2
        %i_6_4639_727_pointer_733 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_730, i64 0, i32 2
        %i_6_4639_727 = load i64, ptr %i_6_4639_727_pointer_733, !noalias !2
        %freeMins_2863_728_pointer_734 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_730, i64 0, i32 3
        %freeMins_2863_728 = load %Reference, ptr %freeMins_2863_728_pointer_734, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_730)
        ret void
}



define tailcc void @returnAddress_663(%Pos %v_r_2991_4_70_4649, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_664 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %c_2872_pointer_665 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_664, i64 0, i32 0
        %c_2872 = load i64, ptr %c_2872_pointer_665, !noalias !2
        %i_6_4639_pointer_666 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_664, i64 0, i32 1
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_666, !noalias !2
        %freeMins_2863_pointer_667 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_664, i64 0, i32 2
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_667, !noalias !2
        %freeMaxs_2862_pointer_668 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_664, i64 0, i32 3
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_668, !noalias !2
        %n_2854_pointer_669 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_664, i64 0, i32 4
        %n_2854 = load i64, ptr %n_2854_pointer_669, !noalias !2
        
        %booleanLiteral_6071_temporary_670 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6071 = insertvalue %Pos %booleanLiteral_6071_temporary_670, %Object null, 1
        
        %pureApp_6070 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2991_4_70_4649, i64 %i_6_4639, %Pos %booleanLiteral_6071)
        call ccc void @erasePositive(%Pos %pureApp_6070)
        
        
        %stackPointer_735 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %c_2872_pointer_736 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 0
        store i64 %c_2872, ptr %c_2872_pointer_736, !noalias !2
        %n_2854_pointer_737 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 1
        store i64 %n_2854, ptr %n_2854_pointer_737, !noalias !2
        %i_6_4639_pointer_738 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_738, !noalias !2
        %freeMins_2863_pointer_739 = getelementptr <{i64, i64, i64, %Reference}>, %StackPointer %stackPointer_735, i64 0, i32 3
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_739, !noalias !2
        %returnAddress_pointer_740 = getelementptr <{<{i64, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_735, i64 0, i32 1, i32 0
        %sharer_pointer_741 = getelementptr <{<{i64, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_735, i64 0, i32 1, i32 1
        %eraser_pointer_742 = getelementptr <{<{i64, i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_735, i64 0, i32 1, i32 2
        store ptr @returnAddress_671, ptr %returnAddress_pointer_740, !noalias !2
        store ptr @sharer_719, ptr %sharer_pointer_741, !noalias !2
        store ptr @eraser_729, ptr %eraser_pointer_742, !noalias !2
        
        %get_6082_pointer_743 = call ccc ptr @getVarPointer(%Reference %freeMaxs_2862, %Stack %stack)
        %freeMaxs_2862_old_744 = load %Pos, ptr %get_6082_pointer_743, !noalias !2
        call ccc void @sharePositive(%Pos %freeMaxs_2862_old_744)
        %get_6082 = load %Pos, ptr %get_6082_pointer_743, !noalias !2
        
        %stackPointer_746 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_747 = getelementptr %FrameHeader, %StackPointer %stackPointer_746, i64 0, i32 0
        %returnAddress_745 = load %ReturnAddress, ptr %returnAddress_pointer_747, !noalias !2
        musttail call tailcc void %returnAddress_745(%Pos %get_6082, %Stack %stack)
        ret void
}



define ccc void @sharer_753(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_754 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %c_2872_748_pointer_755 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_754, i64 0, i32 0
        %c_2872_748 = load i64, ptr %c_2872_748_pointer_755, !noalias !2
        %i_6_4639_749_pointer_756 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_754, i64 0, i32 1
        %i_6_4639_749 = load i64, ptr %i_6_4639_749_pointer_756, !noalias !2
        %freeMins_2863_750_pointer_757 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_754, i64 0, i32 2
        %freeMins_2863_750 = load %Reference, ptr %freeMins_2863_750_pointer_757, !noalias !2
        %freeMaxs_2862_751_pointer_758 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_754, i64 0, i32 3
        %freeMaxs_2862_751 = load %Reference, ptr %freeMaxs_2862_751_pointer_758, !noalias !2
        %n_2854_752_pointer_759 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_754, i64 0, i32 4
        %n_2854_752 = load i64, ptr %n_2854_752_pointer_759, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_754)
        ret void
}



define ccc void @eraser_765(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_766 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %c_2872_760_pointer_767 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_766, i64 0, i32 0
        %c_2872_760 = load i64, ptr %c_2872_760_pointer_767, !noalias !2
        %i_6_4639_761_pointer_768 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_766, i64 0, i32 1
        %i_6_4639_761 = load i64, ptr %i_6_4639_761_pointer_768, !noalias !2
        %freeMins_2863_762_pointer_769 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_766, i64 0, i32 2
        %freeMins_2863_762 = load %Reference, ptr %freeMins_2863_762_pointer_769, !noalias !2
        %freeMaxs_2862_763_pointer_770 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_766, i64 0, i32 3
        %freeMaxs_2862_763 = load %Reference, ptr %freeMaxs_2862_763_pointer_770, !noalias !2
        %n_2854_764_pointer_771 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_766, i64 0, i32 4
        %n_2854_764 = load i64, ptr %n_2854_764_pointer_771, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_766)
        ret void
}



define tailcc void @returnAddress_655(%Pos %__69_4724, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_656 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %freeRows_2861_pointer_657 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_656, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_657, !noalias !2
        %c_2872_pointer_658 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_656, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_658, !noalias !2
        %i_6_4639_pointer_659 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_656, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_659, !noalias !2
        %freeMins_2863_pointer_660 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_656, i64 0, i32 3
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_660, !noalias !2
        %freeMaxs_2862_pointer_661 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_656, i64 0, i32 4
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_661, !noalias !2
        %n_2854_pointer_662 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_656, i64 0, i32 5
        %n_2854 = load i64, ptr %n_2854_pointer_662, !noalias !2
        call ccc void @erasePositive(%Pos %__69_4724)
        %stackPointer_772 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %c_2872_pointer_773 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_772, i64 0, i32 0
        store i64 %c_2872, ptr %c_2872_pointer_773, !noalias !2
        %i_6_4639_pointer_774 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_772, i64 0, i32 1
        store i64 %i_6_4639, ptr %i_6_4639_pointer_774, !noalias !2
        %freeMins_2863_pointer_775 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_772, i64 0, i32 2
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_775, !noalias !2
        %freeMaxs_2862_pointer_776 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_772, i64 0, i32 3
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_776, !noalias !2
        %n_2854_pointer_777 = getelementptr <{i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_772, i64 0, i32 4
        store i64 %n_2854, ptr %n_2854_pointer_777, !noalias !2
        %returnAddress_pointer_778 = getelementptr <{<{i64, i64, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_772, i64 0, i32 1, i32 0
        %sharer_pointer_779 = getelementptr <{<{i64, i64, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_772, i64 0, i32 1, i32 1
        %eraser_pointer_780 = getelementptr <{<{i64, i64, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_772, i64 0, i32 1, i32 2
        store ptr @returnAddress_663, ptr %returnAddress_pointer_778, !noalias !2
        store ptr @sharer_753, ptr %sharer_pointer_779, !noalias !2
        store ptr @eraser_765, ptr %eraser_pointer_780, !noalias !2
        
        %get_6083_pointer_781 = call ccc ptr @getVarPointer(%Reference %freeRows_2861, %Stack %stack)
        %freeRows_2861_old_782 = load %Pos, ptr %get_6083_pointer_781, !noalias !2
        call ccc void @sharePositive(%Pos %freeRows_2861_old_782)
        %get_6083 = load %Pos, ptr %get_6083_pointer_781, !noalias !2
        
        %stackPointer_784 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_785 = getelementptr %FrameHeader, %StackPointer %stackPointer_784, i64 0, i32 0
        %returnAddress_783 = load %ReturnAddress, ptr %returnAddress_pointer_785, !noalias !2
        musttail call tailcc void %returnAddress_783(%Pos %get_6083, %Stack %stack)
        ret void
}



define ccc void @sharer_792(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_793 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_786_pointer_794 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_793, i64 0, i32 0
        %freeRows_2861_786 = load %Reference, ptr %freeRows_2861_786_pointer_794, !noalias !2
        %c_2872_787_pointer_795 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_793, i64 0, i32 1
        %c_2872_787 = load i64, ptr %c_2872_787_pointer_795, !noalias !2
        %i_6_4639_788_pointer_796 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_793, i64 0, i32 2
        %i_6_4639_788 = load i64, ptr %i_6_4639_788_pointer_796, !noalias !2
        %freeMins_2863_789_pointer_797 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_793, i64 0, i32 3
        %freeMins_2863_789 = load %Reference, ptr %freeMins_2863_789_pointer_797, !noalias !2
        %freeMaxs_2862_790_pointer_798 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_793, i64 0, i32 4
        %freeMaxs_2862_790 = load %Reference, ptr %freeMaxs_2862_790_pointer_798, !noalias !2
        %n_2854_791_pointer_799 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_793, i64 0, i32 5
        %n_2854_791 = load i64, ptr %n_2854_791_pointer_799, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_793)
        ret void
}



define ccc void @eraser_806(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_807 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_800_pointer_808 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_807, i64 0, i32 0
        %freeRows_2861_800 = load %Reference, ptr %freeRows_2861_800_pointer_808, !noalias !2
        %c_2872_801_pointer_809 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_807, i64 0, i32 1
        %c_2872_801 = load i64, ptr %c_2872_801_pointer_809, !noalias !2
        %i_6_4639_802_pointer_810 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_807, i64 0, i32 2
        %i_6_4639_802 = load i64, ptr %i_6_4639_802_pointer_810, !noalias !2
        %freeMins_2863_803_pointer_811 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_807, i64 0, i32 3
        %freeMins_2863_803 = load %Reference, ptr %freeMins_2863_803_pointer_811, !noalias !2
        %freeMaxs_2862_804_pointer_812 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_807, i64 0, i32 4
        %freeMaxs_2862_804 = load %Reference, ptr %freeMaxs_2862_804_pointer_812, !noalias !2
        %n_2854_805_pointer_813 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_807, i64 0, i32 5
        %n_2854_805 = load i64, ptr %n_2854_805_pointer_813, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_807)
        ret void
}



define tailcc void @returnAddress_646(%Pos %v_r_3016_66_4710, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_647 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 80)
        %freeRows_2861_pointer_648 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_647, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_648, !noalias !2
        %c_2872_pointer_649 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_647, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_649, !noalias !2
        %i_6_4639_pointer_650 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_647, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_650, !noalias !2
        %p_4194_pointer_651 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_647, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_651, !noalias !2
        %freeMins_2863_pointer_652 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_647, i64 0, i32 4
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_652, !noalias !2
        %freeMaxs_2862_pointer_653 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_647, i64 0, i32 5
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_653, !noalias !2
        %n_2854_pointer_654 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_647, i64 0, i32 6
        %n_2854 = load i64, ptr %n_2854_pointer_654, !noalias !2
        %stackPointer_814 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_815 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_814, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_815, !noalias !2
        %c_2872_pointer_816 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_814, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_816, !noalias !2
        %i_6_4639_pointer_817 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_814, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_817, !noalias !2
        %freeMins_2863_pointer_818 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_814, i64 0, i32 3
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_818, !noalias !2
        %freeMaxs_2862_pointer_819 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_814, i64 0, i32 4
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_819, !noalias !2
        %n_2854_pointer_820 = getelementptr <{%Reference, i64, i64, %Reference, %Reference, i64}>, %StackPointer %stackPointer_814, i64 0, i32 5
        store i64 %n_2854, ptr %n_2854_pointer_820, !noalias !2
        %returnAddress_pointer_821 = getelementptr <{<{%Reference, i64, i64, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_814, i64 0, i32 1, i32 0
        %sharer_pointer_822 = getelementptr <{<{%Reference, i64, i64, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_814, i64 0, i32 1, i32 1
        %eraser_pointer_823 = getelementptr <{<{%Reference, i64, i64, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_814, i64 0, i32 1, i32 2
        store ptr @returnAddress_655, ptr %returnAddress_pointer_821, !noalias !2
        store ptr @sharer_792, ptr %sharer_pointer_822, !noalias !2
        store ptr @eraser_806, ptr %eraser_pointer_823, !noalias !2
        
        %tag_824 = extractvalue %Pos %v_r_3016_66_4710, 0
        %fields_825 = extractvalue %Pos %v_r_3016_66_4710, 1
        switch i64 %tag_824, label %label_826 [i64 0, label %label_831 i64 1, label %label_838]
    
    label_826:
        
        ret void
    
    label_831:
        
        %unitLiteral_6084_temporary_827 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6084 = insertvalue %Pos %unitLiteral_6084_temporary_827, %Object null, 1
        
        %stackPointer_829 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_830 = getelementptr %FrameHeader, %StackPointer %stackPointer_829, i64 0, i32 0
        %returnAddress_828 = load %ReturnAddress, ptr %returnAddress_pointer_830, !noalias !2
        musttail call tailcc void %returnAddress_828(%Pos %unitLiteral_6084, %Stack %stack)
        ret void
    
    label_838:
        
        %pair_832 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4194)
        %k_3_68_6085 = extractvalue <{%Resumption, %Stack}> %pair_832, 0
        %stack_833 = extractvalue <{%Resumption, %Stack}> %pair_832, 1
        call ccc void @eraseResumption(%Resumption %k_3_68_6085)
        
        %booleanLiteral_6086_temporary_834 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6086 = insertvalue %Pos %booleanLiteral_6086_temporary_834, %Object null, 1
        
        %stackPointer_836 = call ccc %StackPointer @stackDeallocate(%Stack %stack_833, i64 24)
        %returnAddress_pointer_837 = getelementptr %FrameHeader, %StackPointer %stackPointer_836, i64 0, i32 0
        %returnAddress_835 = load %ReturnAddress, ptr %returnAddress_pointer_837, !noalias !2
        musttail call tailcc void %returnAddress_835(%Pos %booleanLiteral_6086, %Stack %stack_833)
        ret void
}



define ccc void @sharer_846(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_847 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_839_pointer_848 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_847, i64 0, i32 0
        %freeRows_2861_839 = load %Reference, ptr %freeRows_2861_839_pointer_848, !noalias !2
        %c_2872_840_pointer_849 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_847, i64 0, i32 1
        %c_2872_840 = load i64, ptr %c_2872_840_pointer_849, !noalias !2
        %i_6_4639_841_pointer_850 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_847, i64 0, i32 2
        %i_6_4639_841 = load i64, ptr %i_6_4639_841_pointer_850, !noalias !2
        %p_4194_842_pointer_851 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_847, i64 0, i32 3
        %p_4194_842 = load %Prompt, ptr %p_4194_842_pointer_851, !noalias !2
        %freeMins_2863_843_pointer_852 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_847, i64 0, i32 4
        %freeMins_2863_843 = load %Reference, ptr %freeMins_2863_843_pointer_852, !noalias !2
        %freeMaxs_2862_844_pointer_853 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_847, i64 0, i32 5
        %freeMaxs_2862_844 = load %Reference, ptr %freeMaxs_2862_844_pointer_853, !noalias !2
        %n_2854_845_pointer_854 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_847, i64 0, i32 6
        %n_2854_845 = load i64, ptr %n_2854_845_pointer_854, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_847)
        ret void
}



define ccc void @eraser_862(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_863 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_855_pointer_864 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_863, i64 0, i32 0
        %freeRows_2861_855 = load %Reference, ptr %freeRows_2861_855_pointer_864, !noalias !2
        %c_2872_856_pointer_865 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_863, i64 0, i32 1
        %c_2872_856 = load i64, ptr %c_2872_856_pointer_865, !noalias !2
        %i_6_4639_857_pointer_866 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_863, i64 0, i32 2
        %i_6_4639_857 = load i64, ptr %i_6_4639_857_pointer_866, !noalias !2
        %p_4194_858_pointer_867 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_863, i64 0, i32 3
        %p_4194_858 = load %Prompt, ptr %p_4194_858_pointer_867, !noalias !2
        %freeMins_2863_859_pointer_868 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_863, i64 0, i32 4
        %freeMins_2863_859 = load %Reference, ptr %freeMins_2863_859_pointer_868, !noalias !2
        %freeMaxs_2862_860_pointer_869 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_863, i64 0, i32 5
        %freeMaxs_2862_860 = load %Reference, ptr %freeMaxs_2862_860_pointer_869, !noalias !2
        %n_2854_861_pointer_870 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_863, i64 0, i32 6
        %n_2854_861 = load i64, ptr %n_2854_861_pointer_870, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_863)
        ret void
}



define tailcc void @returnAddress_636(%Pos %__64_4723, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_637 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_638 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_637, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_638, !noalias !2
        %c_2872_pointer_639 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_637, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_639, !noalias !2
        %i_6_4639_pointer_640 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_637, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_640, !noalias !2
        %p_4194_pointer_641 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_637, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_641, !noalias !2
        %queenRows_2864_pointer_642 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_637, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_642, !noalias !2
        %freeMins_2863_pointer_643 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_637, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_643, !noalias !2
        %freeMaxs_2862_pointer_644 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_637, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_644, !noalias !2
        %n_2854_pointer_645 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_637, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_645, !noalias !2
        call ccc void @erasePositive(%Pos %__64_4723)
        
        %longLiteral_6069 = add i64 1, 0
        
        %pureApp_6068 = call ccc i64 @infixAdd_96(i64 %c_2872, i64 %longLiteral_6069)
        
        
        %stackPointer_871 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 104)
        %freeRows_2861_pointer_872 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_871, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_872, !noalias !2
        %c_2872_pointer_873 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_871, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_873, !noalias !2
        %i_6_4639_pointer_874 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_871, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_874, !noalias !2
        %p_4194_pointer_875 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_871, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_875, !noalias !2
        %freeMins_2863_pointer_876 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_871, i64 0, i32 4
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_876, !noalias !2
        %freeMaxs_2862_pointer_877 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_871, i64 0, i32 5
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_877, !noalias !2
        %n_2854_pointer_878 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %StackPointer %stackPointer_871, i64 0, i32 6
        store i64 %n_2854, ptr %n_2854_pointer_878, !noalias !2
        %returnAddress_pointer_879 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_871, i64 0, i32 1, i32 0
        %sharer_pointer_880 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_871, i64 0, i32 1, i32 1
        %eraser_pointer_881 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_871, i64 0, i32 1, i32 2
        store ptr @returnAddress_646, ptr %returnAddress_pointer_879, !noalias !2
        store ptr @sharer_846, ptr %sharer_pointer_880, !noalias !2
        store ptr @eraser_862, ptr %eraser_pointer_881, !noalias !2
        
        
        
        musttail call tailcc void @placeQueen_2873(i64 %pureApp_6068, %Reference %freeRows_2861, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_625(%Pos %v_r_2995_11_53_4691, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_626 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_627 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_626, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_627, !noalias !2
        %c_2872_pointer_628 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_626, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_628, !noalias !2
        %i_6_4639_pointer_629 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_626, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_629, !noalias !2
        %p_4194_pointer_630 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_626, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_630, !noalias !2
        %queenRows_2864_pointer_631 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_626, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_631, !noalias !2
        %freeMins_2863_pointer_632 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_626, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_632, !noalias !2
        %freeMaxs_2862_pointer_633 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_626, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_633, !noalias !2
        %n_2854_pointer_634 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_626, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_634, !noalias !2
        
        %pureApp_6059 = call ccc i64 @infixSub_105(i64 %c_2872, i64 %i_6_4639)
        
        
        
        %longLiteral_6061 = add i64 1, 0
        
        %pureApp_6060 = call ccc i64 @infixSub_105(i64 %n_2854, i64 %longLiteral_6061)
        
        
        
        %pureApp_6062 = call ccc i64 @infixAdd_96(i64 %pureApp_6059, i64 %pureApp_6060)
        
        
        
        %booleanLiteral_6064_temporary_635 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_6064 = insertvalue %Pos %booleanLiteral_6064_temporary_635, %Object null, 1
        
        %pureApp_6063 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2995_11_53_4691, i64 %pureApp_6062, %Pos %booleanLiteral_6064)
        call ccc void @erasePositive(%Pos %pureApp_6063)
        
        
        
        %longLiteral_6066 = add i64 1, 0
        
        %pureApp_6065 = call ccc i64 @infixSub_105(i64 %n_2854, i64 %longLiteral_6066)
        
        
        
        %pureApp_6067 = call ccc %Pos @infixEq_72(i64 %c_2872, i64 %pureApp_6065)
        
        
        %stackPointer_898 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_899 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_898, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_899, !noalias !2
        %c_2872_pointer_900 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_898, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_900, !noalias !2
        %i_6_4639_pointer_901 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_898, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_901, !noalias !2
        %p_4194_pointer_902 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_898, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_902, !noalias !2
        %queenRows_2864_pointer_903 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_898, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_903, !noalias !2
        %freeMins_2863_pointer_904 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_898, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_904, !noalias !2
        %freeMaxs_2862_pointer_905 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_898, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_905, !noalias !2
        %n_2854_pointer_906 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_898, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_906, !noalias !2
        %returnAddress_pointer_907 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_898, i64 0, i32 1, i32 0
        %sharer_pointer_908 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_898, i64 0, i32 1, i32 1
        %eraser_pointer_909 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_898, i64 0, i32 1, i32 2
        store ptr @returnAddress_636, ptr %returnAddress_pointer_907, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_908, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_909, !noalias !2
        
        %tag_910 = extractvalue %Pos %pureApp_6067, 0
        %fields_911 = extractvalue %Pos %pureApp_6067, 1
        switch i64 %tag_910, label %label_912 [i64 0, label %label_917 i64 1, label %label_924]
    
    label_912:
        
        ret void
    
    label_917:
        
        %unitLiteral_6087_temporary_913 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6087 = insertvalue %Pos %unitLiteral_6087_temporary_913, %Object null, 1
        
        %stackPointer_915 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_916 = getelementptr %FrameHeader, %StackPointer %stackPointer_915, i64 0, i32 0
        %returnAddress_914 = load %ReturnAddress, ptr %returnAddress_pointer_916, !noalias !2
        musttail call tailcc void %returnAddress_914(%Pos %unitLiteral_6087, %Stack %stack)
        ret void
    
    label_924:
        
        %pair_918 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4194)
        %k_3_63_6088 = extractvalue <{%Resumption, %Stack}> %pair_918, 0
        %stack_919 = extractvalue <{%Resumption, %Stack}> %pair_918, 1
        call ccc void @eraseResumption(%Resumption %k_3_63_6088)
        
        %booleanLiteral_6089_temporary_920 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6089 = insertvalue %Pos %booleanLiteral_6089_temporary_920, %Object null, 1
        
        %stackPointer_922 = call ccc %StackPointer @stackDeallocate(%Stack %stack_919, i64 24)
        %returnAddress_pointer_923 = getelementptr %FrameHeader, %StackPointer %stackPointer_922, i64 0, i32 0
        %returnAddress_921 = load %ReturnAddress, ptr %returnAddress_pointer_923, !noalias !2
        musttail call tailcc void %returnAddress_921(%Pos %booleanLiteral_6089, %Stack %stack_919)
        ret void
}



define tailcc void @returnAddress_614(%Pos %v_r_2993_7_49_4709, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_615 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_616 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_615, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_616, !noalias !2
        %c_2872_pointer_617 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_615, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_617, !noalias !2
        %i_6_4639_pointer_618 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_615, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_618, !noalias !2
        %p_4194_pointer_619 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_615, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_619, !noalias !2
        %queenRows_2864_pointer_620 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_615, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_620, !noalias !2
        %freeMins_2863_pointer_621 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_615, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_621, !noalias !2
        %freeMaxs_2862_pointer_622 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_615, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_622, !noalias !2
        %n_2854_pointer_623 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_615, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_623, !noalias !2
        
        %pureApp_6056 = call ccc i64 @infixAdd_96(i64 %c_2872, i64 %i_6_4639)
        
        
        
        %booleanLiteral_6058_temporary_624 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_6058 = insertvalue %Pos %booleanLiteral_6058_temporary_624, %Object null, 1
        
        %pureApp_6057 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2993_7_49_4709, i64 %pureApp_6056, %Pos %booleanLiteral_6058)
        call ccc void @erasePositive(%Pos %pureApp_6057)
        
        
        %stackPointer_941 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_942 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_941, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_942, !noalias !2
        %c_2872_pointer_943 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_941, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_943, !noalias !2
        %i_6_4639_pointer_944 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_941, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_944, !noalias !2
        %p_4194_pointer_945 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_941, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_945, !noalias !2
        %queenRows_2864_pointer_946 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_941, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_946, !noalias !2
        %freeMins_2863_pointer_947 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_941, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_947, !noalias !2
        %freeMaxs_2862_pointer_948 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_941, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_948, !noalias !2
        %n_2854_pointer_949 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_941, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_949, !noalias !2
        %returnAddress_pointer_950 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_941, i64 0, i32 1, i32 0
        %sharer_pointer_951 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_941, i64 0, i32 1, i32 1
        %eraser_pointer_952 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_941, i64 0, i32 1, i32 2
        store ptr @returnAddress_625, ptr %returnAddress_pointer_950, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_951, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_952, !noalias !2
        
        %get_6090_pointer_953 = call ccc ptr @getVarPointer(%Reference %freeMins_2863, %Stack %stack)
        %freeMins_2863_old_954 = load %Pos, ptr %get_6090_pointer_953, !noalias !2
        call ccc void @sharePositive(%Pos %freeMins_2863_old_954)
        %get_6090 = load %Pos, ptr %get_6090_pointer_953, !noalias !2
        
        %stackPointer_956 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_957 = getelementptr %FrameHeader, %StackPointer %stackPointer_956, i64 0, i32 0
        %returnAddress_955 = load %ReturnAddress, ptr %returnAddress_pointer_957, !noalias !2
        musttail call tailcc void %returnAddress_955(%Pos %get_6090, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_603(%Pos %v_r_2991_4_46_4699, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_604 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_605 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_604, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_605, !noalias !2
        %c_2872_pointer_606 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_604, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_606, !noalias !2
        %i_6_4639_pointer_607 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_604, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_607, !noalias !2
        %p_4194_pointer_608 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_604, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_608, !noalias !2
        %queenRows_2864_pointer_609 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_604, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_609, !noalias !2
        %freeMins_2863_pointer_610 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_604, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_610, !noalias !2
        %freeMaxs_2862_pointer_611 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_604, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_611, !noalias !2
        %n_2854_pointer_612 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_604, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_612, !noalias !2
        
        %booleanLiteral_6055_temporary_613 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_6055 = insertvalue %Pos %booleanLiteral_6055_temporary_613, %Object null, 1
        
        %pureApp_6054 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2991_4_46_4699, i64 %i_6_4639, %Pos %booleanLiteral_6055)
        call ccc void @erasePositive(%Pos %pureApp_6054)
        
        
        %stackPointer_974 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_975 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_974, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_975, !noalias !2
        %c_2872_pointer_976 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_974, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_976, !noalias !2
        %i_6_4639_pointer_977 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_974, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_977, !noalias !2
        %p_4194_pointer_978 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_974, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_978, !noalias !2
        %queenRows_2864_pointer_979 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_974, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_979, !noalias !2
        %freeMins_2863_pointer_980 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_974, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_980, !noalias !2
        %freeMaxs_2862_pointer_981 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_974, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_981, !noalias !2
        %n_2854_pointer_982 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_974, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_982, !noalias !2
        %returnAddress_pointer_983 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_974, i64 0, i32 1, i32 0
        %sharer_pointer_984 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_974, i64 0, i32 1, i32 1
        %eraser_pointer_985 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_974, i64 0, i32 1, i32 2
        store ptr @returnAddress_614, ptr %returnAddress_pointer_983, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_984, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_985, !noalias !2
        
        %get_6091_pointer_986 = call ccc ptr @getVarPointer(%Reference %freeMaxs_2862, %Stack %stack)
        %freeMaxs_2862_old_987 = load %Pos, ptr %get_6091_pointer_986, !noalias !2
        call ccc void @sharePositive(%Pos %freeMaxs_2862_old_987)
        %get_6091 = load %Pos, ptr %get_6091_pointer_986, !noalias !2
        
        %stackPointer_989 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_990 = getelementptr %FrameHeader, %StackPointer %stackPointer_989, i64 0, i32 0
        %returnAddress_988 = load %ReturnAddress, ptr %returnAddress_pointer_990, !noalias !2
        musttail call tailcc void %returnAddress_988(%Pos %get_6091, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_593(%Pos %v_r_3011_42_4694, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_594 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_595 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_594, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_595, !noalias !2
        %c_2872_pointer_596 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_594, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_596, !noalias !2
        %i_6_4639_pointer_597 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_594, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_597, !noalias !2
        %p_4194_pointer_598 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_594, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_598, !noalias !2
        %queenRows_2864_pointer_599 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_594, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_599, !noalias !2
        %freeMins_2863_pointer_600 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_594, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_600, !noalias !2
        %freeMaxs_2862_pointer_601 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_594, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_601, !noalias !2
        %n_2854_pointer_602 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_594, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_602, !noalias !2
        
        %pureApp_6052 = call ccc %Pos @boxInt_301(i64 %c_2872)
        
        
        
        %pureApp_6053 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_3011_42_4694, i64 %i_6_4639, %Pos %pureApp_6052)
        call ccc void @erasePositive(%Pos %pureApp_6053)
        
        
        %stackPointer_1007 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_1008 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1007, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1008, !noalias !2
        %c_2872_pointer_1009 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1007, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_1009, !noalias !2
        %i_6_4639_pointer_1010 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1007, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_1010, !noalias !2
        %p_4194_pointer_1011 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1007, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_1011, !noalias !2
        %queenRows_2864_pointer_1012 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1007, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1012, !noalias !2
        %freeMins_2863_pointer_1013 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1007, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1013, !noalias !2
        %freeMaxs_2862_pointer_1014 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1007, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1014, !noalias !2
        %n_2854_pointer_1015 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1007, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_1015, !noalias !2
        %returnAddress_pointer_1016 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1007, i64 0, i32 1, i32 0
        %sharer_pointer_1017 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1007, i64 0, i32 1, i32 1
        %eraser_pointer_1018 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1007, i64 0, i32 1, i32 2
        store ptr @returnAddress_603, ptr %returnAddress_pointer_1016, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_1017, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_1018, !noalias !2
        
        %get_6092_pointer_1019 = call ccc ptr @getVarPointer(%Reference %freeRows_2861, %Stack %stack)
        %freeRows_2861_old_1020 = load %Pos, ptr %get_6092_pointer_1019, !noalias !2
        call ccc void @sharePositive(%Pos %freeRows_2861_old_1020)
        %get_6092 = load %Pos, ptr %get_6092_pointer_1019, !noalias !2
        
        %stackPointer_1022 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1023 = getelementptr %FrameHeader, %StackPointer %stackPointer_1022, i64 0, i32 0
        %returnAddress_1021 = load %ReturnAddress, ptr %returnAddress_pointer_1023, !noalias !2
        musttail call tailcc void %returnAddress_1021(%Pos %get_6092, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_517(%Pos %v_r_3010_41_4683, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_518 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_519 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_518, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_519, !noalias !2
        %c_2872_pointer_520 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_518, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_520, !noalias !2
        %i_6_4639_pointer_521 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_518, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_521, !noalias !2
        %p_4194_pointer_522 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_518, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_522, !noalias !2
        %queenRows_2864_pointer_523 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_518, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_523, !noalias !2
        %freeMins_2863_pointer_524 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_518, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_524, !noalias !2
        %freeMaxs_2862_pointer_525 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_518, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_525, !noalias !2
        %n_2854_pointer_526 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_518, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_526, !noalias !2
        %stackPointer_573 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_574 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_573, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_574, !noalias !2
        %c_2872_pointer_575 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_573, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_575, !noalias !2
        %i_6_4639_pointer_576 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_573, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_576, !noalias !2
        %p_4194_pointer_577 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_573, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_577, !noalias !2
        %queenRows_2864_pointer_578 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_573, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_578, !noalias !2
        %freeMins_2863_pointer_579 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_573, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_579, !noalias !2
        %freeMaxs_2862_pointer_580 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_573, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_580, !noalias !2
        %n_2854_pointer_581 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_573, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_581, !noalias !2
        %returnAddress_pointer_582 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_573, i64 0, i32 1, i32 0
        %sharer_pointer_583 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_573, i64 0, i32 1, i32 1
        %eraser_pointer_584 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_573, i64 0, i32 1, i32 2
        store ptr @returnAddress_527, ptr %returnAddress_pointer_582, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_583, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_584, !noalias !2
        
        %tag_585 = extractvalue %Pos %v_r_3010_41_4683, 0
        %fields_586 = extractvalue %Pos %v_r_3010_41_4683, 1
        switch i64 %tag_585, label %label_587 [i64 0, label %label_592 i64 1, label %label_1057]
    
    label_587:
        
        ret void
    
    label_592:
        
        %unitLiteral_6051_temporary_588 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6051 = insertvalue %Pos %unitLiteral_6051_temporary_588, %Object null, 1
        
        %stackPointer_590 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_591 = getelementptr %FrameHeader, %StackPointer %stackPointer_590, i64 0, i32 0
        %returnAddress_589 = load %ReturnAddress, ptr %returnAddress_pointer_591, !noalias !2
        musttail call tailcc void %returnAddress_589(%Pos %unitLiteral_6051, %Stack %stack)
        ret void
    
    label_1057:
        %stackPointer_1040 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_1041 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1040, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1041, !noalias !2
        %c_2872_pointer_1042 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1040, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_1042, !noalias !2
        %i_6_4639_pointer_1043 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1040, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_1043, !noalias !2
        %p_4194_pointer_1044 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1040, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_1044, !noalias !2
        %queenRows_2864_pointer_1045 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1040, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1045, !noalias !2
        %freeMins_2863_pointer_1046 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1040, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1046, !noalias !2
        %freeMaxs_2862_pointer_1047 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1040, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1047, !noalias !2
        %n_2854_pointer_1048 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1040, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_1048, !noalias !2
        %returnAddress_pointer_1049 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1040, i64 0, i32 1, i32 0
        %sharer_pointer_1050 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1040, i64 0, i32 1, i32 1
        %eraser_pointer_1051 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1040, i64 0, i32 1, i32 2
        store ptr @returnAddress_593, ptr %returnAddress_pointer_1049, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_1050, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_1051, !noalias !2
        
        %get_6093_pointer_1052 = call ccc ptr @getVarPointer(%Reference %queenRows_2864, %Stack %stack)
        %queenRows_2864_old_1053 = load %Pos, ptr %get_6093_pointer_1052, !noalias !2
        call ccc void @sharePositive(%Pos %queenRows_2864_old_1053)
        %get_6093 = load %Pos, ptr %get_6093_pointer_1052, !noalias !2
        
        %stackPointer_1055 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1056 = getelementptr %FrameHeader, %StackPointer %stackPointer_1055, i64 0, i32 0
        %returnAddress_1054 = load %ReturnAddress, ptr %returnAddress_pointer_1056, !noalias !2
        musttail call tailcc void %returnAddress_1054(%Pos %get_6093, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1094(%Pos %v_r_2988_1_37_36_4713, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1095 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %c_2872_pointer_1096 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_1095, i64 0, i32 0
        %c_2872 = load i64, ptr %c_2872_pointer_1096, !noalias !2
        %i_6_4639_pointer_1097 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_1095, i64 0, i32 1
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_1097, !noalias !2
        %n_2854_pointer_1098 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_1095, i64 0, i32 2
        %n_2854 = load i64, ptr %n_2854_pointer_1098, !noalias !2
        
        %pureApp_6095 = call ccc i64 @infixSub_105(i64 %c_2872, i64 %i_6_4639)
        
        
        
        %longLiteral_6097 = add i64 1, 0
        
        %pureApp_6096 = call ccc i64 @infixSub_105(i64 %n_2854, i64 %longLiteral_6097)
        
        
        
        %pureApp_6098 = call ccc i64 @infixAdd_96(i64 %pureApp_6095, i64 %pureApp_6096)
        
        
        
        %pureApp_6099 = call ccc %Pos @unsafeGet_2487(%Pos %v_r_2988_1_37_36_4713, i64 %pureApp_6098)
        
        
        
        %stackPointer_1100 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1101 = getelementptr %FrameHeader, %StackPointer %stackPointer_1100, i64 0, i32 0
        %returnAddress_1099 = load %ReturnAddress, ptr %returnAddress_pointer_1101, !noalias !2
        musttail call tailcc void %returnAddress_1099(%Pos %pureApp_6099, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_507(%Pos %v_r_3996_5_36_35_4680, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_508 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_509 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_508, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_509, !noalias !2
        %c_2872_pointer_510 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_508, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_510, !noalias !2
        %i_6_4639_pointer_511 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_508, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_511, !noalias !2
        %p_4194_pointer_512 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_508, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_512, !noalias !2
        %queenRows_2864_pointer_513 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_508, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_513, !noalias !2
        %freeMins_2863_pointer_514 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_508, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_514, !noalias !2
        %freeMaxs_2862_pointer_515 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_508, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_515, !noalias !2
        %n_2854_pointer_516 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_508, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_516, !noalias !2
        %stackPointer_1074 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_1075 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1074, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1075, !noalias !2
        %c_2872_pointer_1076 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1074, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_1076, !noalias !2
        %i_6_4639_pointer_1077 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1074, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_1077, !noalias !2
        %p_4194_pointer_1078 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1074, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_1078, !noalias !2
        %queenRows_2864_pointer_1079 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1074, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1079, !noalias !2
        %freeMins_2863_pointer_1080 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1074, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1080, !noalias !2
        %freeMaxs_2862_pointer_1081 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1074, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1081, !noalias !2
        %n_2854_pointer_1082 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1074, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_1082, !noalias !2
        %returnAddress_pointer_1083 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1074, i64 0, i32 1, i32 0
        %sharer_pointer_1084 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1074, i64 0, i32 1, i32 1
        %eraser_pointer_1085 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1074, i64 0, i32 1, i32 2
        store ptr @returnAddress_517, ptr %returnAddress_pointer_1083, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_1084, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_1085, !noalias !2
        
        %tag_1086 = extractvalue %Pos %v_r_3996_5_36_35_4680, 0
        %fields_1087 = extractvalue %Pos %v_r_3996_5_36_35_4680, 1
        switch i64 %tag_1086, label %label_1088 [i64 0, label %label_1093 i64 1, label %label_1120]
    
    label_1088:
        
        ret void
    
    label_1093:
        
        %booleanLiteral_6094_temporary_1089 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_6094 = insertvalue %Pos %booleanLiteral_6094_temporary_1089, %Object null, 1
        
        %stackPointer_1091 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1092 = getelementptr %FrameHeader, %StackPointer %stackPointer_1091, i64 0, i32 0
        %returnAddress_1090 = load %ReturnAddress, ptr %returnAddress_pointer_1092, !noalias !2
        musttail call tailcc void %returnAddress_1090(%Pos %booleanLiteral_6094, %Stack %stack)
        ret void
    
    label_1120:
        %stackPointer_1108 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 48)
        %c_2872_pointer_1109 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_1108, i64 0, i32 0
        store i64 %c_2872, ptr %c_2872_pointer_1109, !noalias !2
        %i_6_4639_pointer_1110 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_1108, i64 0, i32 1
        store i64 %i_6_4639, ptr %i_6_4639_pointer_1110, !noalias !2
        %n_2854_pointer_1111 = getelementptr <{i64, i64, i64}>, %StackPointer %stackPointer_1108, i64 0, i32 2
        store i64 %n_2854, ptr %n_2854_pointer_1111, !noalias !2
        %returnAddress_pointer_1112 = getelementptr <{<{i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1108, i64 0, i32 1, i32 0
        %sharer_pointer_1113 = getelementptr <{<{i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1108, i64 0, i32 1, i32 1
        %eraser_pointer_1114 = getelementptr <{<{i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1108, i64 0, i32 1, i32 2
        store ptr @returnAddress_1094, ptr %returnAddress_pointer_1112, !noalias !2
        store ptr @sharer_690, ptr %sharer_pointer_1113, !noalias !2
        store ptr @eraser_698, ptr %eraser_pointer_1114, !noalias !2
        
        %get_6100_pointer_1115 = call ccc ptr @getVarPointer(%Reference %freeMins_2863, %Stack %stack)
        %freeMins_2863_old_1116 = load %Pos, ptr %get_6100_pointer_1115, !noalias !2
        call ccc void @sharePositive(%Pos %freeMins_2863_old_1116)
        %get_6100 = load %Pos, ptr %get_6100_pointer_1115, !noalias !2
        
        %stackPointer_1118 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1119 = getelementptr %FrameHeader, %StackPointer %stackPointer_1118, i64 0, i32 0
        %returnAddress_1117 = load %ReturnAddress, ptr %returnAddress_pointer_1119, !noalias !2
        musttail call tailcc void %returnAddress_1117(%Pos %get_6100, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1157(%Pos %v_r_2985_1_11_33_32_4668, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1158 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %c_2872_pointer_1159 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_1158, i64 0, i32 0
        %c_2872 = load i64, ptr %c_2872_pointer_1159, !noalias !2
        %i_6_4639_pointer_1160 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_1158, i64 0, i32 1
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_1160, !noalias !2
        
        %pureApp_6102 = call ccc i64 @infixAdd_96(i64 %c_2872, i64 %i_6_4639)
        
        
        
        %pureApp_6103 = call ccc %Pos @unsafeGet_2487(%Pos %v_r_2985_1_11_33_32_4668, i64 %pureApp_6102)
        
        
        
        %stackPointer_1162 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1163 = getelementptr %FrameHeader, %StackPointer %stackPointer_1162, i64 0, i32 0
        %returnAddress_1161 = load %ReturnAddress, ptr %returnAddress_pointer_1163, !noalias !2
        musttail call tailcc void %returnAddress_1161(%Pos %pureApp_6103, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_497(%Pos %v_r_2982_1_8_30_29_4660, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_498 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_499 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_498, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_499, !noalias !2
        %c_2872_pointer_500 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_498, i64 0, i32 1
        %c_2872 = load i64, ptr %c_2872_pointer_500, !noalias !2
        %i_6_4639_pointer_501 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_498, i64 0, i32 2
        %i_6_4639 = load i64, ptr %i_6_4639_pointer_501, !noalias !2
        %p_4194_pointer_502 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_498, i64 0, i32 3
        %p_4194 = load %Prompt, ptr %p_4194_pointer_502, !noalias !2
        %queenRows_2864_pointer_503 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_498, i64 0, i32 4
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_503, !noalias !2
        %freeMins_2863_pointer_504 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_498, i64 0, i32 5
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_504, !noalias !2
        %freeMaxs_2862_pointer_505 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_498, i64 0, i32 6
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_505, !noalias !2
        %n_2854_pointer_506 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_498, i64 0, i32 7
        %n_2854 = load i64, ptr %n_2854_pointer_506, !noalias !2
        
        %pureApp_6048 = call ccc %Pos @unsafeGet_2487(%Pos %v_r_2982_1_8_30_29_4660, i64 %i_6_4639)
        
        
        %stackPointer_1137 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_1138 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1137, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1138, !noalias !2
        %c_2872_pointer_1139 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1137, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_1139, !noalias !2
        %i_6_4639_pointer_1140 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1137, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_1140, !noalias !2
        %p_4194_pointer_1141 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1137, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_1141, !noalias !2
        %queenRows_2864_pointer_1142 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1137, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1142, !noalias !2
        %freeMins_2863_pointer_1143 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1137, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1143, !noalias !2
        %freeMaxs_2862_pointer_1144 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1137, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1144, !noalias !2
        %n_2854_pointer_1145 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1137, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_1145, !noalias !2
        %returnAddress_pointer_1146 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1137, i64 0, i32 1, i32 0
        %sharer_pointer_1147 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1137, i64 0, i32 1, i32 1
        %eraser_pointer_1148 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1137, i64 0, i32 1, i32 2
        store ptr @returnAddress_507, ptr %returnAddress_pointer_1146, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_1147, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_1148, !noalias !2
        
        %tag_1149 = extractvalue %Pos %pureApp_6048, 0
        %fields_1150 = extractvalue %Pos %pureApp_6048, 1
        switch i64 %tag_1149, label %label_1151 [i64 0, label %label_1156 i64 1, label %label_1179]
    
    label_1151:
        
        ret void
    
    label_1156:
        
        %booleanLiteral_6101_temporary_1152 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_6101 = insertvalue %Pos %booleanLiteral_6101_temporary_1152, %Object null, 1
        
        %stackPointer_1154 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1155 = getelementptr %FrameHeader, %StackPointer %stackPointer_1154, i64 0, i32 0
        %returnAddress_1153 = load %ReturnAddress, ptr %returnAddress_pointer_1155, !noalias !2
        musttail call tailcc void %returnAddress_1153(%Pos %booleanLiteral_6101, %Stack %stack)
        ret void
    
    label_1179:
        %stackPointer_1168 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %c_2872_pointer_1169 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_1168, i64 0, i32 0
        store i64 %c_2872, ptr %c_2872_pointer_1169, !noalias !2
        %i_6_4639_pointer_1170 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_1168, i64 0, i32 1
        store i64 %i_6_4639, ptr %i_6_4639_pointer_1170, !noalias !2
        %returnAddress_pointer_1171 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1168, i64 0, i32 1, i32 0
        %sharer_pointer_1172 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1168, i64 0, i32 1, i32 1
        %eraser_pointer_1173 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1168, i64 0, i32 1, i32 2
        store ptr @returnAddress_1157, ptr %returnAddress_pointer_1171, !noalias !2
        store ptr @sharer_16, ptr %sharer_pointer_1172, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_1173, !noalias !2
        
        %get_6104_pointer_1174 = call ccc ptr @getVarPointer(%Reference %freeMaxs_2862, %Stack %stack)
        %freeMaxs_2862_old_1175 = load %Pos, ptr %get_6104_pointer_1174, !noalias !2
        call ccc void @sharePositive(%Pos %freeMaxs_2862_old_1175)
        %get_6104 = load %Pos, ptr %get_6104_pointer_1174, !noalias !2
        
        %stackPointer_1177 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1178 = getelementptr %FrameHeader, %StackPointer %stackPointer_1177, i64 0, i32 0
        %returnAddress_1176 = load %ReturnAddress, ptr %returnAddress_pointer_1178, !noalias !2
        musttail call tailcc void %returnAddress_1176(%Pos %get_6104, %Stack %stack)
        ret void
}



define tailcc void @loop_5_4636(i64 %i_6_4639, %Reference %freeRows_2861, i64 %c_2872, %Prompt %p_4194, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack) {
        
    entry:
        
        
        %pureApp_6046 = call ccc %Pos @infixLt_178(i64 %i_6_4639, i64 %n_2854)
        
        
        
        %tag_489 = extractvalue %Pos %pureApp_6046, 0
        %fields_490 = extractvalue %Pos %pureApp_6046, 1
        switch i64 %tag_489, label %label_491 [i64 0, label %label_496 i64 1, label %label_1213]
    
    label_491:
        
        ret void
    
    label_496:
        
        %unitLiteral_6047_temporary_492 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6047 = insertvalue %Pos %unitLiteral_6047_temporary_492, %Object null, 1
        
        %stackPointer_494 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_495 = getelementptr %FrameHeader, %StackPointer %stackPointer_494, i64 0, i32 0
        %returnAddress_493 = load %ReturnAddress, ptr %returnAddress_pointer_495, !noalias !2
        musttail call tailcc void %returnAddress_493(%Pos %unitLiteral_6047, %Stack %stack)
        ret void
    
    label_1213:
        %stackPointer_1196 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_1197 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1196, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1197, !noalias !2
        %c_2872_pointer_1198 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1196, i64 0, i32 1
        store i64 %c_2872, ptr %c_2872_pointer_1198, !noalias !2
        %i_6_4639_pointer_1199 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1196, i64 0, i32 2
        store i64 %i_6_4639, ptr %i_6_4639_pointer_1199, !noalias !2
        %p_4194_pointer_1200 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1196, i64 0, i32 3
        store %Prompt %p_4194, ptr %p_4194_pointer_1200, !noalias !2
        %queenRows_2864_pointer_1201 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1196, i64 0, i32 4
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1201, !noalias !2
        %freeMins_2863_pointer_1202 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1196, i64 0, i32 5
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1202, !noalias !2
        %freeMaxs_2862_pointer_1203 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1196, i64 0, i32 6
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1203, !noalias !2
        %n_2854_pointer_1204 = getelementptr <{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1196, i64 0, i32 7
        store i64 %n_2854, ptr %n_2854_pointer_1204, !noalias !2
        %returnAddress_pointer_1205 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1196, i64 0, i32 1, i32 0
        %sharer_pointer_1206 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1196, i64 0, i32 1, i32 1
        %eraser_pointer_1207 = getelementptr <{<{%Reference, i64, i64, %Prompt, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1196, i64 0, i32 1, i32 2
        store ptr @returnAddress_497, ptr %returnAddress_pointer_1205, !noalias !2
        store ptr @sharer_545, ptr %sharer_pointer_1206, !noalias !2
        store ptr @eraser_563, ptr %eraser_pointer_1207, !noalias !2
        
        %get_6105_pointer_1208 = call ccc ptr @getVarPointer(%Reference %freeRows_2861, %Stack %stack)
        %freeRows_2861_old_1209 = load %Pos, ptr %get_6105_pointer_1208, !noalias !2
        call ccc void @sharePositive(%Pos %freeRows_2861_old_1209)
        %get_6105 = load %Pos, ptr %get_6105_pointer_1208, !noalias !2
        
        %stackPointer_1211 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1212 = getelementptr %FrameHeader, %StackPointer %stackPointer_1211, i64 0, i32 0
        %returnAddress_1210 = load %ReturnAddress, ptr %returnAddress_pointer_1212, !noalias !2
        musttail call tailcc void %returnAddress_1210(%Pos %get_6105, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1214(%Pos %__6106, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %__6106)
        
        %booleanLiteral_6107_temporary_1215 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_6107 = insertvalue %Pos %booleanLiteral_6107_temporary_1215, %Object null, 1
        
        %stackPointer_1217 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1218 = getelementptr %FrameHeader, %StackPointer %stackPointer_1217, i64 0, i32 0
        %returnAddress_1216 = load %ReturnAddress, ptr %returnAddress_pointer_1218, !noalias !2
        musttail call tailcc void %returnAddress_1216(%Pos %booleanLiteral_6107, %Stack %stack)
        ret void
}



define tailcc void @placeQueen_2873(i64 %c_2872, %Reference %freeRows_2861, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack) {
        
    entry:
        
        
        %stack_479 = call ccc %Stack @reset(%Stack %stack)
        %p_4194 = call ccc %Prompt @currentPrompt(%Stack %stack_479)
        %stackPointer_485 = call ccc %StackPointer @stackAllocate(%Stack %stack_479, i64 24)
        %returnAddress_pointer_486 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_485, i64 0, i32 1, i32 0
        %sharer_pointer_487 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_485, i64 0, i32 1, i32 1
        %eraser_pointer_488 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_485, i64 0, i32 1, i32 2
        store ptr @returnAddress_480, ptr %returnAddress_pointer_486, !noalias !2
        store ptr @sharer_76, ptr %sharer_pointer_487, !noalias !2
        store ptr @eraser_78, ptr %eraser_pointer_488, !noalias !2
        %stackPointer_1219 = call ccc %StackPointer @stackAllocate(%Stack %stack_479, i64 24)
        %returnAddress_pointer_1220 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1219, i64 0, i32 1, i32 0
        %sharer_pointer_1221 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1219, i64 0, i32 1, i32 1
        %eraser_pointer_1222 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_1219, i64 0, i32 1, i32 2
        store ptr @returnAddress_1214, ptr %returnAddress_pointer_1220, !noalias !2
        store ptr @sharer_39, ptr %sharer_pointer_1221, !noalias !2
        store ptr @eraser_41, ptr %eraser_pointer_1222, !noalias !2
        
        %longLiteral_6108 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_4636(i64 %longLiteral_6108, %Reference %freeRows_2861, i64 %c_2872, %Prompt %p_4194, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack_479)
        ret void
}



define tailcc void @returnAddress_1224(%Pos %returnValue_1225, %Stack %stack) {
        
    entry:
        
        %stackPointer_1226 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_r_3034_4162_pointer_1227 = getelementptr <{%Pos}>, %StackPointer %stackPointer_1226, i64 0, i32 0
        %v_r_3034_4162 = load %Pos, ptr %v_r_3034_4162_pointer_1227, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3034_4162)
        %stackPointer_1229 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1230 = getelementptr %FrameHeader, %StackPointer %stackPointer_1229, i64 0, i32 0
        %returnAddress_1228 = load %ReturnAddress, ptr %returnAddress_pointer_1230, !noalias !2
        musttail call tailcc void %returnAddress_1228(%Pos %returnValue_1225, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1264(%Pos %__8_4919, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1265 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_1266 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1265, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1266, !noalias !2
        %i_6_4916_pointer_1267 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1265, i64 0, i32 1
        %i_6_4916 = load i64, ptr %i_6_4916_pointer_1267, !noalias !2
        %j_2878_pointer_1268 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1265, i64 0, i32 2
        %j_2878 = load %Reference, ptr %j_2878_pointer_1268, !noalias !2
        %queenRows_2864_pointer_1269 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1265, i64 0, i32 3
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1269, !noalias !2
        %freeMins_2863_pointer_1270 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1265, i64 0, i32 4
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1270, !noalias !2
        %freeMaxs_2862_pointer_1271 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1265, i64 0, i32 5
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1271, !noalias !2
        %n_2854_pointer_1272 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1265, i64 0, i32 6
        %n_2854 = load i64, ptr %n_2854_pointer_1272, !noalias !2
        call ccc void @erasePositive(%Pos %__8_4919)
        
        %longLiteral_6115 = add i64 1, 0
        
        %pureApp_6114 = call ccc i64 @infixAdd_96(i64 %i_6_4916, i64 %longLiteral_6115)
        
        
        
        
        
        musttail call tailcc void @loop_5_4913(i64 %pureApp_6114, %Reference %freeRows_2861, %Reference %j_2878, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack)
        ret void
}



define ccc void @sharer_1280(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1281 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_1273_pointer_1282 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1281, i64 0, i32 0
        %freeRows_2861_1273 = load %Reference, ptr %freeRows_2861_1273_pointer_1282, !noalias !2
        %i_6_4916_1274_pointer_1283 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1281, i64 0, i32 1
        %i_6_4916_1274 = load i64, ptr %i_6_4916_1274_pointer_1283, !noalias !2
        %j_2878_1275_pointer_1284 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1281, i64 0, i32 2
        %j_2878_1275 = load %Reference, ptr %j_2878_1275_pointer_1284, !noalias !2
        %queenRows_2864_1276_pointer_1285 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1281, i64 0, i32 3
        %queenRows_2864_1276 = load %Reference, ptr %queenRows_2864_1276_pointer_1285, !noalias !2
        %freeMins_2863_1277_pointer_1286 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1281, i64 0, i32 4
        %freeMins_2863_1277 = load %Reference, ptr %freeMins_2863_1277_pointer_1286, !noalias !2
        %freeMaxs_2862_1278_pointer_1287 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1281, i64 0, i32 5
        %freeMaxs_2862_1278 = load %Reference, ptr %freeMaxs_2862_1278_pointer_1287, !noalias !2
        %n_2854_1279_pointer_1288 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1281, i64 0, i32 6
        %n_2854_1279 = load i64, ptr %n_2854_1279_pointer_1288, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1281)
        ret void
}



define ccc void @eraser_1296(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1297 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_1289_pointer_1298 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1297, i64 0, i32 0
        %freeRows_2861_1289 = load %Reference, ptr %freeRows_2861_1289_pointer_1298, !noalias !2
        %i_6_4916_1290_pointer_1299 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1297, i64 0, i32 1
        %i_6_4916_1290 = load i64, ptr %i_6_4916_1290_pointer_1299, !noalias !2
        %j_2878_1291_pointer_1300 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1297, i64 0, i32 2
        %j_2878_1291 = load %Reference, ptr %j_2878_1291_pointer_1300, !noalias !2
        %queenRows_2864_1292_pointer_1301 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1297, i64 0, i32 3
        %queenRows_2864_1292 = load %Reference, ptr %queenRows_2864_1292_pointer_1301, !noalias !2
        %freeMins_2863_1293_pointer_1302 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1297, i64 0, i32 4
        %freeMins_2863_1293 = load %Reference, ptr %freeMins_2863_1293_pointer_1302, !noalias !2
        %freeMaxs_2862_1294_pointer_1303 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1297, i64 0, i32 5
        %freeMaxs_2862_1294 = load %Reference, ptr %freeMaxs_2862_1294_pointer_1303, !noalias !2
        %n_2854_1295_pointer_1304 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1297, i64 0, i32 6
        %n_2854_1295 = load i64, ptr %n_2854_1295_pointer_1304, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1297)
        ret void
}



define tailcc void @returnAddress_1255(%Pos %v_r_3037_123_5022, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1256 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_1257 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1256, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1257, !noalias !2
        %i_6_4916_pointer_1258 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1256, i64 0, i32 1
        %i_6_4916 = load i64, ptr %i_6_4916_pointer_1258, !noalias !2
        %j_2878_pointer_1259 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1256, i64 0, i32 2
        %j_2878 = load %Reference, ptr %j_2878_pointer_1259, !noalias !2
        %queenRows_2864_pointer_1260 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1256, i64 0, i32 3
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1260, !noalias !2
        %freeMins_2863_pointer_1261 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1256, i64 0, i32 4
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1261, !noalias !2
        %freeMaxs_2862_pointer_1262 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1256, i64 0, i32 5
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1262, !noalias !2
        %n_2854_pointer_1263 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1256, i64 0, i32 6
        %n_2854 = load i64, ptr %n_2854_pointer_1263, !noalias !2
        %stackPointer_1305 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_1306 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1305, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1306, !noalias !2
        %i_6_4916_pointer_1307 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1305, i64 0, i32 1
        store i64 %i_6_4916, ptr %i_6_4916_pointer_1307, !noalias !2
        %j_2878_pointer_1308 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1305, i64 0, i32 2
        store %Reference %j_2878, ptr %j_2878_pointer_1308, !noalias !2
        %queenRows_2864_pointer_1309 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1305, i64 0, i32 3
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1309, !noalias !2
        %freeMins_2863_pointer_1310 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1305, i64 0, i32 4
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1310, !noalias !2
        %freeMaxs_2862_pointer_1311 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1305, i64 0, i32 5
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1311, !noalias !2
        %n_2854_pointer_1312 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1305, i64 0, i32 6
        store i64 %n_2854, ptr %n_2854_pointer_1312, !noalias !2
        %returnAddress_pointer_1313 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1305, i64 0, i32 1, i32 0
        %sharer_pointer_1314 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1305, i64 0, i32 1, i32 1
        %eraser_pointer_1315 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1305, i64 0, i32 1, i32 2
        store ptr @returnAddress_1264, ptr %returnAddress_pointer_1313, !noalias !2
        store ptr @sharer_1280, ptr %sharer_pointer_1314, !noalias !2
        store ptr @eraser_1296, ptr %eraser_pointer_1315, !noalias !2
        
        %j_2878pointer_1316 = call ccc ptr @getVarPointer(%Reference %j_2878, %Stack %stack)
        %j_2878_old_1317 = load %Pos, ptr %j_2878pointer_1316, !noalias !2
        call ccc void @erasePositive(%Pos %j_2878_old_1317)
        store %Pos %v_r_3037_123_5022, ptr %j_2878pointer_1316, !noalias !2
        
        %put_6116_temporary_1318 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_6116 = insertvalue %Pos %put_6116_temporary_1318, %Object null, 1
        
        %stackPointer_1320 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1321 = getelementptr %FrameHeader, %StackPointer %stackPointer_1320, i64 0, i32 0
        %returnAddress_1319 = load %ReturnAddress, ptr %returnAddress_pointer_1321, !noalias !2
        musttail call tailcc void %returnAddress_1319(%Pos %put_6116, %Stack %stack)
        ret void
}



define tailcc void @loop_5_9_6_6_69_4941(i64 %i_6_10_7_7_70_5009, i64 %n_2854, %Pos %tmp_5933, %Stack %stack) {
        
    entry:
        
        
        %pureApp_6119 = call ccc %Pos @infixLt_178(i64 %i_6_10_7_7_70_5009, i64 %n_2854)
        
        
        
        %tag_1355 = extractvalue %Pos %pureApp_6119, 0
        %fields_1356 = extractvalue %Pos %pureApp_6119, 1
        switch i64 %tag_1355, label %label_1357 [i64 0, label %label_1362 i64 1, label %label_1364]
    
    label_1357:
        
        ret void
    
    label_1362:
        call ccc void @erasePositive(%Pos %tmp_5933)
        
        %unitLiteral_6120_temporary_1358 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6120 = insertvalue %Pos %unitLiteral_6120_temporary_1358, %Object null, 1
        
        %stackPointer_1360 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1361 = getelementptr %FrameHeader, %StackPointer %stackPointer_1360, i64 0, i32 0
        %returnAddress_1359 = load %ReturnAddress, ptr %returnAddress_pointer_1361, !noalias !2
        musttail call tailcc void %returnAddress_1359(%Pos %unitLiteral_6120, %Stack %stack)
        ret void
    
    label_1364:
        
        %booleanLiteral_6122_temporary_1363 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6122 = insertvalue %Pos %booleanLiteral_6122_temporary_1363, %Object null, 1
        
        call ccc void @sharePositive(%Pos %tmp_5933)
        %pureApp_6121 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5933, i64 %i_6_10_7_7_70_5009, %Pos %booleanLiteral_6122)
        call ccc void @erasePositive(%Pos %pureApp_6121)
        
        
        
        %longLiteral_6124 = add i64 1, 0
        
        %pureApp_6123 = call ccc i64 @infixAdd_96(i64 %i_6_10_7_7_70_5009, i64 %longLiteral_6124)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_6_6_69_4941(i64 %pureApp_6123, i64 %n_2854, %Pos %tmp_5933, %Stack %stack)
        ret void
}



define tailcc void @loop_5_9_21_21_84_4931(i64 %i_6_10_22_22_85_4964, %Pos %tmp_5938, i64 %tmp_5937, %Stack %stack) {
        
    entry:
        
        
        %pureApp_6128 = call ccc %Pos @infixLt_178(i64 %i_6_10_22_22_85_4964, i64 %tmp_5937)
        
        
        
        %tag_1380 = extractvalue %Pos %pureApp_6128, 0
        %fields_1381 = extractvalue %Pos %pureApp_6128, 1
        switch i64 %tag_1380, label %label_1382 [i64 0, label %label_1387 i64 1, label %label_1389]
    
    label_1382:
        
        ret void
    
    label_1387:
        call ccc void @erasePositive(%Pos %tmp_5938)
        
        %unitLiteral_6129_temporary_1383 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6129 = insertvalue %Pos %unitLiteral_6129_temporary_1383, %Object null, 1
        
        %stackPointer_1385 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1386 = getelementptr %FrameHeader, %StackPointer %stackPointer_1385, i64 0, i32 0
        %returnAddress_1384 = load %ReturnAddress, ptr %returnAddress_pointer_1386, !noalias !2
        musttail call tailcc void %returnAddress_1384(%Pos %unitLiteral_6129, %Stack %stack)
        ret void
    
    label_1389:
        
        %booleanLiteral_6131_temporary_1388 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6131 = insertvalue %Pos %booleanLiteral_6131_temporary_1388, %Object null, 1
        
        call ccc void @sharePositive(%Pos %tmp_5938)
        %pureApp_6130 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5938, i64 %i_6_10_22_22_85_4964, %Pos %booleanLiteral_6131)
        call ccc void @erasePositive(%Pos %pureApp_6130)
        
        
        
        %longLiteral_6133 = add i64 1, 0
        
        %pureApp_6132 = call ccc i64 @infixAdd_96(i64 %i_6_10_22_22_85_4964, i64 %longLiteral_6133)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_21_21_84_4931(i64 %pureApp_6132, %Pos %tmp_5938, i64 %tmp_5937, %Stack %stack)
        ret void
}



define tailcc void @loop_5_9_36_36_99_4992(i64 %i_6_10_37_37_100_4962, %Pos %tmp_5943, i64 %tmp_5942, %Stack %stack) {
        
    entry:
        
        
        %pureApp_6137 = call ccc %Pos @infixLt_178(i64 %i_6_10_37_37_100_4962, i64 %tmp_5942)
        
        
        
        %tag_1405 = extractvalue %Pos %pureApp_6137, 0
        %fields_1406 = extractvalue %Pos %pureApp_6137, 1
        switch i64 %tag_1405, label %label_1407 [i64 0, label %label_1412 i64 1, label %label_1414]
    
    label_1407:
        
        ret void
    
    label_1412:
        call ccc void @erasePositive(%Pos %tmp_5943)
        
        %unitLiteral_6138_temporary_1408 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6138 = insertvalue %Pos %unitLiteral_6138_temporary_1408, %Object null, 1
        
        %stackPointer_1410 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1411 = getelementptr %FrameHeader, %StackPointer %stackPointer_1410, i64 0, i32 0
        %returnAddress_1409 = load %ReturnAddress, ptr %returnAddress_pointer_1411, !noalias !2
        musttail call tailcc void %returnAddress_1409(%Pos %unitLiteral_6138, %Stack %stack)
        ret void
    
    label_1414:
        
        %booleanLiteral_6140_temporary_1413 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6140 = insertvalue %Pos %booleanLiteral_6140_temporary_1413, %Object null, 1
        
        call ccc void @sharePositive(%Pos %tmp_5943)
        %pureApp_6139 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5943, i64 %i_6_10_37_37_100_4962, %Pos %booleanLiteral_6140)
        call ccc void @erasePositive(%Pos %pureApp_6139)
        
        
        
        %longLiteral_6142 = add i64 1, 0
        
        %pureApp_6141 = call ccc i64 @infixAdd_96(i64 %i_6_10_37_37_100_4962, i64 %longLiteral_6142)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_36_36_99_4992(i64 %pureApp_6141, %Pos %tmp_5943, i64 %tmp_5942, %Stack %stack)
        ret void
}



define tailcc void @loop_5_9_51_51_114_4983(i64 %i_6_10_52_52_115_4987, i64 %n_2854, %Pos %tmp_5947, %Pos %tmp_5948, %Stack %stack) {
        
    entry:
        
        
        %pureApp_6146 = call ccc %Pos @infixLt_178(i64 %i_6_10_52_52_115_4987, i64 %n_2854)
        
        
        
        %tag_1430 = extractvalue %Pos %pureApp_6146, 0
        %fields_1431 = extractvalue %Pos %pureApp_6146, 1
        switch i64 %tag_1430, label %label_1432 [i64 0, label %label_1437 i64 1, label %label_1438]
    
    label_1432:
        
        ret void
    
    label_1437:
        call ccc void @erasePositive(%Pos %tmp_5948)
        call ccc void @erasePositive(%Pos %tmp_5947)
        
        %unitLiteral_6147_temporary_1433 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6147 = insertvalue %Pos %unitLiteral_6147_temporary_1433, %Object null, 1
        
        %stackPointer_1435 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1436 = getelementptr %FrameHeader, %StackPointer %stackPointer_1435, i64 0, i32 0
        %returnAddress_1434 = load %ReturnAddress, ptr %returnAddress_pointer_1436, !noalias !2
        musttail call tailcc void %returnAddress_1434(%Pos %unitLiteral_6147, %Stack %stack)
        ret void
    
    label_1438:
        
        call ccc void @sharePositive(%Pos %tmp_5948)
        call ccc void @sharePositive(%Pos %tmp_5947)
        %pureApp_6148 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5948, i64 %i_6_10_52_52_115_4987, %Pos %tmp_5947)
        call ccc void @erasePositive(%Pos %pureApp_6148)
        
        
        
        %longLiteral_6150 = add i64 1, 0
        
        %pureApp_6149 = call ccc i64 @infixAdd_96(i64 %i_6_10_52_52_115_4987, i64 %longLiteral_6150)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_51_51_114_4983(i64 %pureApp_6149, i64 %n_2854, %Pos %tmp_5947, %Pos %tmp_5948, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1447(%Pos %__59_59_122_5050, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1448 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %freeRows_2861_pointer_1449 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1448, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1449, !noalias !2
        %queenRows_2864_pointer_1450 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1448, i64 0, i32 1
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1450, !noalias !2
        %freeMins_2863_pointer_1451 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1448, i64 0, i32 2
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1451, !noalias !2
        %freeMaxs_2862_pointer_1452 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1448, i64 0, i32 3
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1452, !noalias !2
        %n_2854_pointer_1453 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1448, i64 0, i32 4
        %n_2854 = load i64, ptr %n_2854_pointer_1453, !noalias !2
        call ccc void @erasePositive(%Pos %__59_59_122_5050)
        
        %longLiteral_6151 = add i64 0, 0
        
        
        
        musttail call tailcc void @placeQueen_2873(i64 %longLiteral_6151, %Reference %freeRows_2861, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack)
        ret void
}



define ccc void @sharer_1459(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1460 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_1454_pointer_1461 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1460, i64 0, i32 0
        %freeRows_2861_1454 = load %Reference, ptr %freeRows_2861_1454_pointer_1461, !noalias !2
        %queenRows_2864_1455_pointer_1462 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1460, i64 0, i32 1
        %queenRows_2864_1455 = load %Reference, ptr %queenRows_2864_1455_pointer_1462, !noalias !2
        %freeMins_2863_1456_pointer_1463 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1460, i64 0, i32 2
        %freeMins_2863_1456 = load %Reference, ptr %freeMins_2863_1456_pointer_1463, !noalias !2
        %freeMaxs_2862_1457_pointer_1464 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1460, i64 0, i32 3
        %freeMaxs_2862_1457 = load %Reference, ptr %freeMaxs_2862_1457_pointer_1464, !noalias !2
        %n_2854_1458_pointer_1465 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1460, i64 0, i32 4
        %n_2854_1458 = load i64, ptr %n_2854_1458_pointer_1465, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1460)
        ret void
}



define ccc void @eraser_1471(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1472 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_1466_pointer_1473 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1472, i64 0, i32 0
        %freeRows_2861_1466 = load %Reference, ptr %freeRows_2861_1466_pointer_1473, !noalias !2
        %queenRows_2864_1467_pointer_1474 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1472, i64 0, i32 1
        %queenRows_2864_1467 = load %Reference, ptr %queenRows_2864_1467_pointer_1474, !noalias !2
        %freeMins_2863_1468_pointer_1475 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1472, i64 0, i32 2
        %freeMins_2863_1468 = load %Reference, ptr %freeMins_2863_1468_pointer_1475, !noalias !2
        %freeMaxs_2862_1469_pointer_1476 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1472, i64 0, i32 3
        %freeMaxs_2862_1469 = load %Reference, ptr %freeMaxs_2862_1469_pointer_1476, !noalias !2
        %n_2854_1470_pointer_1477 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1472, i64 0, i32 4
        %n_2854_1470 = load i64, ptr %n_2854_1470_pointer_1477, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1472)
        ret void
}



define tailcc void @returnAddress_1439(%Pos %v_r_3054_15_57_57_120_5049, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1440 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 88)
        %freeRows_2861_pointer_1441 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1440, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1441, !noalias !2
        %tmp_5948_pointer_1442 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1440, i64 0, i32 1
        %tmp_5948 = load %Pos, ptr %tmp_5948_pointer_1442, !noalias !2
        %queenRows_2864_pointer_1443 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1440, i64 0, i32 2
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1443, !noalias !2
        %freeMins_2863_pointer_1444 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1440, i64 0, i32 3
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1444, !noalias !2
        %freeMaxs_2862_pointer_1445 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1440, i64 0, i32 4
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1445, !noalias !2
        %n_2854_pointer_1446 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1440, i64 0, i32 5
        %n_2854 = load i64, ptr %n_2854_pointer_1446, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3054_15_57_57_120_5049)
        %stackPointer_1478 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_1479 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1478, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1479, !noalias !2
        %queenRows_2864_pointer_1480 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1478, i64 0, i32 1
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1480, !noalias !2
        %freeMins_2863_pointer_1481 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1478, i64 0, i32 2
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1481, !noalias !2
        %freeMaxs_2862_pointer_1482 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1478, i64 0, i32 3
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1482, !noalias !2
        %n_2854_pointer_1483 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1478, i64 0, i32 4
        store i64 %n_2854, ptr %n_2854_pointer_1483, !noalias !2
        %returnAddress_pointer_1484 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1478, i64 0, i32 1, i32 0
        %sharer_pointer_1485 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1478, i64 0, i32 1, i32 1
        %eraser_pointer_1486 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1478, i64 0, i32 1, i32 2
        store ptr @returnAddress_1447, ptr %returnAddress_pointer_1484, !noalias !2
        store ptr @sharer_1459, ptr %sharer_pointer_1485, !noalias !2
        store ptr @eraser_1471, ptr %eraser_pointer_1486, !noalias !2
        
        %queenRows_2864pointer_1487 = call ccc ptr @getVarPointer(%Reference %queenRows_2864, %Stack %stack)
        %queenRows_2864_old_1488 = load %Pos, ptr %queenRows_2864pointer_1487, !noalias !2
        call ccc void @erasePositive(%Pos %queenRows_2864_old_1488)
        store %Pos %tmp_5948, ptr %queenRows_2864pointer_1487, !noalias !2
        
        %put_6152_temporary_1489 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_6152 = insertvalue %Pos %put_6152_temporary_1489, %Object null, 1
        
        %stackPointer_1491 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1492 = getelementptr %FrameHeader, %StackPointer %stackPointer_1491, i64 0, i32 0
        %returnAddress_1490 = load %ReturnAddress, ptr %returnAddress_pointer_1492, !noalias !2
        musttail call tailcc void %returnAddress_1490(%Pos %put_6152, %Stack %stack)
        ret void
}



define ccc void @sharer_1499(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1500 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_1493_pointer_1501 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1500, i64 0, i32 0
        %freeRows_2861_1493 = load %Reference, ptr %freeRows_2861_1493_pointer_1501, !noalias !2
        %tmp_5948_1494_pointer_1502 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1500, i64 0, i32 1
        %tmp_5948_1494 = load %Pos, ptr %tmp_5948_1494_pointer_1502, !noalias !2
        %queenRows_2864_1495_pointer_1503 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1500, i64 0, i32 2
        %queenRows_2864_1495 = load %Reference, ptr %queenRows_2864_1495_pointer_1503, !noalias !2
        %freeMins_2863_1496_pointer_1504 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1500, i64 0, i32 3
        %freeMins_2863_1496 = load %Reference, ptr %freeMins_2863_1496_pointer_1504, !noalias !2
        %freeMaxs_2862_1497_pointer_1505 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1500, i64 0, i32 4
        %freeMaxs_2862_1497 = load %Reference, ptr %freeMaxs_2862_1497_pointer_1505, !noalias !2
        %n_2854_1498_pointer_1506 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1500, i64 0, i32 5
        %n_2854_1498 = load i64, ptr %n_2854_1498_pointer_1506, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5948_1494)
        call ccc void @shareFrames(%StackPointer %stackPointer_1500)
        ret void
}



define ccc void @eraser_1513(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1514 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_1507_pointer_1515 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1514, i64 0, i32 0
        %freeRows_2861_1507 = load %Reference, ptr %freeRows_2861_1507_pointer_1515, !noalias !2
        %tmp_5948_1508_pointer_1516 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1514, i64 0, i32 1
        %tmp_5948_1508 = load %Pos, ptr %tmp_5948_1508_pointer_1516, !noalias !2
        %queenRows_2864_1509_pointer_1517 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1514, i64 0, i32 2
        %queenRows_2864_1509 = load %Reference, ptr %queenRows_2864_1509_pointer_1517, !noalias !2
        %freeMins_2863_1510_pointer_1518 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1514, i64 0, i32 3
        %freeMins_2863_1510 = load %Reference, ptr %freeMins_2863_1510_pointer_1518, !noalias !2
        %freeMaxs_2862_1511_pointer_1519 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1514, i64 0, i32 4
        %freeMaxs_2862_1511 = load %Reference, ptr %freeMaxs_2862_1511_pointer_1519, !noalias !2
        %n_2854_1512_pointer_1520 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1514, i64 0, i32 5
        %n_2854_1512 = load i64, ptr %n_2854_1512_pointer_1520, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5948_1508)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1514)
        ret void
}



define tailcc void @returnAddress_1423(%Pos %__44_44_107_5047, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1424 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %freeRows_2861_pointer_1425 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1425, !noalias !2
        %queenRows_2864_pointer_1426 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 1
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1426, !noalias !2
        %freeMins_2863_pointer_1427 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 2
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1427, !noalias !2
        %freeMaxs_2862_pointer_1428 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 3
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1428, !noalias !2
        %n_2854_pointer_1429 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1424, i64 0, i32 4
        %n_2854 = load i64, ptr %n_2854_pointer_1429, !noalias !2
        call ccc void @erasePositive(%Pos %__44_44_107_5047)
        
        %longLiteral_6144 = add i64 -1, 0
        
        %pureApp_6143 = call ccc %Pos @boxInt_301(i64 %longLiteral_6144)
        
        
        
        %pureApp_6145 = call ccc %Pos @allocate_2473(i64 %n_2854)
        
        
        call ccc void @sharePositive(%Pos %pureApp_6145)
        %stackPointer_1521 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 112)
        %freeRows_2861_pointer_1522 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1521, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1522, !noalias !2
        %tmp_5948_pointer_1523 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1521, i64 0, i32 1
        store %Pos %pureApp_6145, ptr %tmp_5948_pointer_1523, !noalias !2
        %queenRows_2864_pointer_1524 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1521, i64 0, i32 2
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1524, !noalias !2
        %freeMins_2863_pointer_1525 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1521, i64 0, i32 3
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1525, !noalias !2
        %freeMaxs_2862_pointer_1526 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1521, i64 0, i32 4
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1526, !noalias !2
        %n_2854_pointer_1527 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1521, i64 0, i32 5
        store i64 %n_2854, ptr %n_2854_pointer_1527, !noalias !2
        %returnAddress_pointer_1528 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1521, i64 0, i32 1, i32 0
        %sharer_pointer_1529 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1521, i64 0, i32 1, i32 1
        %eraser_pointer_1530 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1521, i64 0, i32 1, i32 2
        store ptr @returnAddress_1439, ptr %returnAddress_pointer_1528, !noalias !2
        store ptr @sharer_1499, ptr %sharer_pointer_1529, !noalias !2
        store ptr @eraser_1513, ptr %eraser_pointer_1530, !noalias !2
        
        %longLiteral_6153 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_51_51_114_4983(i64 %longLiteral_6153, i64 %n_2854, %Pos %pureApp_6143, %Pos %pureApp_6145, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1415(%Pos %v_r_3054_15_42_42_105_5046, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1416 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 88)
        %freeRows_2861_pointer_1417 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1416, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1417, !noalias !2
        %tmp_5943_pointer_1418 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1416, i64 0, i32 1
        %tmp_5943 = load %Pos, ptr %tmp_5943_pointer_1418, !noalias !2
        %queenRows_2864_pointer_1419 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1416, i64 0, i32 2
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1419, !noalias !2
        %freeMins_2863_pointer_1420 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1416, i64 0, i32 3
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1420, !noalias !2
        %freeMaxs_2862_pointer_1421 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1416, i64 0, i32 4
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1421, !noalias !2
        %n_2854_pointer_1422 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1416, i64 0, i32 5
        %n_2854 = load i64, ptr %n_2854_pointer_1422, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3054_15_42_42_105_5046)
        %stackPointer_1541 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_1542 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1541, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1542, !noalias !2
        %queenRows_2864_pointer_1543 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1541, i64 0, i32 1
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1543, !noalias !2
        %freeMins_2863_pointer_1544 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1541, i64 0, i32 2
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1544, !noalias !2
        %freeMaxs_2862_pointer_1545 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1541, i64 0, i32 3
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1545, !noalias !2
        %n_2854_pointer_1546 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1541, i64 0, i32 4
        store i64 %n_2854, ptr %n_2854_pointer_1546, !noalias !2
        %returnAddress_pointer_1547 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1541, i64 0, i32 1, i32 0
        %sharer_pointer_1548 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1541, i64 0, i32 1, i32 1
        %eraser_pointer_1549 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1541, i64 0, i32 1, i32 2
        store ptr @returnAddress_1423, ptr %returnAddress_pointer_1547, !noalias !2
        store ptr @sharer_1459, ptr %sharer_pointer_1548, !noalias !2
        store ptr @eraser_1471, ptr %eraser_pointer_1549, !noalias !2
        
        %freeMins_2863pointer_1550 = call ccc ptr @getVarPointer(%Reference %freeMins_2863, %Stack %stack)
        %freeMins_2863_old_1551 = load %Pos, ptr %freeMins_2863pointer_1550, !noalias !2
        call ccc void @erasePositive(%Pos %freeMins_2863_old_1551)
        store %Pos %tmp_5943, ptr %freeMins_2863pointer_1550, !noalias !2
        
        %put_6154_temporary_1552 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_6154 = insertvalue %Pos %put_6154_temporary_1552, %Object null, 1
        
        %stackPointer_1554 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1555 = getelementptr %FrameHeader, %StackPointer %stackPointer_1554, i64 0, i32 0
        %returnAddress_1553 = load %ReturnAddress, ptr %returnAddress_pointer_1555, !noalias !2
        musttail call tailcc void %returnAddress_1553(%Pos %put_6154, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1398(%Pos %__29_29_92_5044, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1399 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %freeRows_2861_pointer_1400 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1400, !noalias !2
        %queenRows_2864_pointer_1401 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 1
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1401, !noalias !2
        %freeMins_2863_pointer_1402 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 2
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1402, !noalias !2
        %freeMaxs_2862_pointer_1403 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 3
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1403, !noalias !2
        %n_2854_pointer_1404 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1399, i64 0, i32 4
        %n_2854 = load i64, ptr %n_2854_pointer_1404, !noalias !2
        call ccc void @erasePositive(%Pos %__29_29_92_5044)
        
        %longLiteral_6135 = add i64 2, 0
        
        %pureApp_6134 = call ccc i64 @infixMul_99(i64 %longLiteral_6135, i64 %n_2854)
        
        
        
        %pureApp_6136 = call ccc %Pos @allocate_2473(i64 %pureApp_6134)
        
        
        call ccc void @sharePositive(%Pos %pureApp_6136)
        %stackPointer_1568 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 112)
        %freeRows_2861_pointer_1569 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1568, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1569, !noalias !2
        %tmp_5943_pointer_1570 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1568, i64 0, i32 1
        store %Pos %pureApp_6136, ptr %tmp_5943_pointer_1570, !noalias !2
        %queenRows_2864_pointer_1571 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1568, i64 0, i32 2
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1571, !noalias !2
        %freeMins_2863_pointer_1572 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1568, i64 0, i32 3
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1572, !noalias !2
        %freeMaxs_2862_pointer_1573 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1568, i64 0, i32 4
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1573, !noalias !2
        %n_2854_pointer_1574 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1568, i64 0, i32 5
        store i64 %n_2854, ptr %n_2854_pointer_1574, !noalias !2
        %returnAddress_pointer_1575 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1568, i64 0, i32 1, i32 0
        %sharer_pointer_1576 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1568, i64 0, i32 1, i32 1
        %eraser_pointer_1577 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1568, i64 0, i32 1, i32 2
        store ptr @returnAddress_1415, ptr %returnAddress_pointer_1575, !noalias !2
        store ptr @sharer_1499, ptr %sharer_pointer_1576, !noalias !2
        store ptr @eraser_1513, ptr %eraser_pointer_1577, !noalias !2
        
        %longLiteral_6155 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_36_36_99_4992(i64 %longLiteral_6155, %Pos %pureApp_6136, i64 %pureApp_6134, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1390(%Pos %v_r_3054_15_27_27_90_5043, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1391 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 88)
        %queenRows_2864_pointer_1392 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1391, i64 0, i32 0
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1392, !noalias !2
        %freeMins_2863_pointer_1393 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1391, i64 0, i32 1
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1393, !noalias !2
        %tmp_5938_pointer_1394 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1391, i64 0, i32 2
        %tmp_5938 = load %Pos, ptr %tmp_5938_pointer_1394, !noalias !2
        %freeRows_2861_pointer_1395 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1391, i64 0, i32 3
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1395, !noalias !2
        %freeMaxs_2862_pointer_1396 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1391, i64 0, i32 4
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1396, !noalias !2
        %n_2854_pointer_1397 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1391, i64 0, i32 5
        %n_2854 = load i64, ptr %n_2854_pointer_1397, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3054_15_27_27_90_5043)
        %stackPointer_1588 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_1589 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1588, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1589, !noalias !2
        %queenRows_2864_pointer_1590 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1588, i64 0, i32 1
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1590, !noalias !2
        %freeMins_2863_pointer_1591 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1588, i64 0, i32 2
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1591, !noalias !2
        %freeMaxs_2862_pointer_1592 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1588, i64 0, i32 3
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1592, !noalias !2
        %n_2854_pointer_1593 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1588, i64 0, i32 4
        store i64 %n_2854, ptr %n_2854_pointer_1593, !noalias !2
        %returnAddress_pointer_1594 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1588, i64 0, i32 1, i32 0
        %sharer_pointer_1595 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1588, i64 0, i32 1, i32 1
        %eraser_pointer_1596 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1588, i64 0, i32 1, i32 2
        store ptr @returnAddress_1398, ptr %returnAddress_pointer_1594, !noalias !2
        store ptr @sharer_1459, ptr %sharer_pointer_1595, !noalias !2
        store ptr @eraser_1471, ptr %eraser_pointer_1596, !noalias !2
        
        %freeMaxs_2862pointer_1597 = call ccc ptr @getVarPointer(%Reference %freeMaxs_2862, %Stack %stack)
        %freeMaxs_2862_old_1598 = load %Pos, ptr %freeMaxs_2862pointer_1597, !noalias !2
        call ccc void @erasePositive(%Pos %freeMaxs_2862_old_1598)
        store %Pos %tmp_5938, ptr %freeMaxs_2862pointer_1597, !noalias !2
        
        %put_6156_temporary_1599 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_6156 = insertvalue %Pos %put_6156_temporary_1599, %Object null, 1
        
        %stackPointer_1601 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1602 = getelementptr %FrameHeader, %StackPointer %stackPointer_1601, i64 0, i32 0
        %returnAddress_1600 = load %ReturnAddress, ptr %returnAddress_pointer_1602, !noalias !2
        musttail call tailcc void %returnAddress_1600(%Pos %put_6156, %Stack %stack)
        ret void
}



define ccc void @sharer_1609(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1610 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %queenRows_2864_1603_pointer_1611 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1610, i64 0, i32 0
        %queenRows_2864_1603 = load %Reference, ptr %queenRows_2864_1603_pointer_1611, !noalias !2
        %freeMins_2863_1604_pointer_1612 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1610, i64 0, i32 1
        %freeMins_2863_1604 = load %Reference, ptr %freeMins_2863_1604_pointer_1612, !noalias !2
        %tmp_5938_1605_pointer_1613 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1610, i64 0, i32 2
        %tmp_5938_1605 = load %Pos, ptr %tmp_5938_1605_pointer_1613, !noalias !2
        %freeRows_2861_1606_pointer_1614 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1610, i64 0, i32 3
        %freeRows_2861_1606 = load %Reference, ptr %freeRows_2861_1606_pointer_1614, !noalias !2
        %freeMaxs_2862_1607_pointer_1615 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1610, i64 0, i32 4
        %freeMaxs_2862_1607 = load %Reference, ptr %freeMaxs_2862_1607_pointer_1615, !noalias !2
        %n_2854_1608_pointer_1616 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1610, i64 0, i32 5
        %n_2854_1608 = load i64, ptr %n_2854_1608_pointer_1616, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5938_1605)
        call ccc void @shareFrames(%StackPointer %stackPointer_1610)
        ret void
}



define ccc void @eraser_1623(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1624 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %queenRows_2864_1617_pointer_1625 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1624, i64 0, i32 0
        %queenRows_2864_1617 = load %Reference, ptr %queenRows_2864_1617_pointer_1625, !noalias !2
        %freeMins_2863_1618_pointer_1626 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1624, i64 0, i32 1
        %freeMins_2863_1618 = load %Reference, ptr %freeMins_2863_1618_pointer_1626, !noalias !2
        %tmp_5938_1619_pointer_1627 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1624, i64 0, i32 2
        %tmp_5938_1619 = load %Pos, ptr %tmp_5938_1619_pointer_1627, !noalias !2
        %freeRows_2861_1620_pointer_1628 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1624, i64 0, i32 3
        %freeRows_2861_1620 = load %Reference, ptr %freeRows_2861_1620_pointer_1628, !noalias !2
        %freeMaxs_2862_1621_pointer_1629 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1624, i64 0, i32 4
        %freeMaxs_2862_1621 = load %Reference, ptr %freeMaxs_2862_1621_pointer_1629, !noalias !2
        %n_2854_1622_pointer_1630 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1624, i64 0, i32 5
        %n_2854_1622 = load i64, ptr %n_2854_1622_pointer_1630, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5938_1619)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1624)
        ret void
}



define tailcc void @returnAddress_1373(%Pos %__14_14_77_5041, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1374 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %freeRows_2861_pointer_1375 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1374, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1375, !noalias !2
        %queenRows_2864_pointer_1376 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1374, i64 0, i32 1
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1376, !noalias !2
        %freeMins_2863_pointer_1377 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1374, i64 0, i32 2
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1377, !noalias !2
        %freeMaxs_2862_pointer_1378 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1374, i64 0, i32 3
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1378, !noalias !2
        %n_2854_pointer_1379 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1374, i64 0, i32 4
        %n_2854 = load i64, ptr %n_2854_pointer_1379, !noalias !2
        call ccc void @erasePositive(%Pos %__14_14_77_5041)
        
        %longLiteral_6126 = add i64 2, 0
        
        %pureApp_6125 = call ccc i64 @infixMul_99(i64 %longLiteral_6126, i64 %n_2854)
        
        
        
        %pureApp_6127 = call ccc %Pos @allocate_2473(i64 %pureApp_6125)
        
        
        call ccc void @sharePositive(%Pos %pureApp_6127)
        %stackPointer_1631 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 112)
        %queenRows_2864_pointer_1632 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1631, i64 0, i32 0
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1632, !noalias !2
        %freeMins_2863_pointer_1633 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1631, i64 0, i32 1
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1633, !noalias !2
        %tmp_5938_pointer_1634 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1631, i64 0, i32 2
        store %Pos %pureApp_6127, ptr %tmp_5938_pointer_1634, !noalias !2
        %freeRows_2861_pointer_1635 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1631, i64 0, i32 3
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1635, !noalias !2
        %freeMaxs_2862_pointer_1636 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1631, i64 0, i32 4
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1636, !noalias !2
        %n_2854_pointer_1637 = getelementptr <{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1631, i64 0, i32 5
        store i64 %n_2854, ptr %n_2854_pointer_1637, !noalias !2
        %returnAddress_pointer_1638 = getelementptr <{<{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1631, i64 0, i32 1, i32 0
        %sharer_pointer_1639 = getelementptr <{<{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1631, i64 0, i32 1, i32 1
        %eraser_pointer_1640 = getelementptr <{<{%Reference, %Reference, %Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1631, i64 0, i32 1, i32 2
        store ptr @returnAddress_1390, ptr %returnAddress_pointer_1638, !noalias !2
        store ptr @sharer_1609, ptr %sharer_pointer_1639, !noalias !2
        store ptr @eraser_1623, ptr %eraser_pointer_1640, !noalias !2
        
        %longLiteral_6157 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_21_21_84_4931(i64 %longLiteral_6157, %Pos %pureApp_6127, i64 %pureApp_6125, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1365(%Pos %v_r_3054_15_12_12_75_5040, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1366 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 88)
        %freeRows_2861_pointer_1367 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1366, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1367, !noalias !2
        %tmp_5933_pointer_1368 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1366, i64 0, i32 1
        %tmp_5933 = load %Pos, ptr %tmp_5933_pointer_1368, !noalias !2
        %queenRows_2864_pointer_1369 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1366, i64 0, i32 2
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1369, !noalias !2
        %freeMins_2863_pointer_1370 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1366, i64 0, i32 3
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1370, !noalias !2
        %freeMaxs_2862_pointer_1371 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1366, i64 0, i32 4
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1371, !noalias !2
        %n_2854_pointer_1372 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1366, i64 0, i32 5
        %n_2854 = load i64, ptr %n_2854_pointer_1372, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3054_15_12_12_75_5040)
        %stackPointer_1651 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_1652 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1651, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1652, !noalias !2
        %queenRows_2864_pointer_1653 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1651, i64 0, i32 1
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1653, !noalias !2
        %freeMins_2863_pointer_1654 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1651, i64 0, i32 2
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1654, !noalias !2
        %freeMaxs_2862_pointer_1655 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1651, i64 0, i32 3
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1655, !noalias !2
        %n_2854_pointer_1656 = getelementptr <{%Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1651, i64 0, i32 4
        store i64 %n_2854, ptr %n_2854_pointer_1656, !noalias !2
        %returnAddress_pointer_1657 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1651, i64 0, i32 1, i32 0
        %sharer_pointer_1658 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1651, i64 0, i32 1, i32 1
        %eraser_pointer_1659 = getelementptr <{<{%Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1651, i64 0, i32 1, i32 2
        store ptr @returnAddress_1373, ptr %returnAddress_pointer_1657, !noalias !2
        store ptr @sharer_1459, ptr %sharer_pointer_1658, !noalias !2
        store ptr @eraser_1471, ptr %eraser_pointer_1659, !noalias !2
        
        %freeRows_2861pointer_1660 = call ccc ptr @getVarPointer(%Reference %freeRows_2861, %Stack %stack)
        %freeRows_2861_old_1661 = load %Pos, ptr %freeRows_2861pointer_1660, !noalias !2
        call ccc void @erasePositive(%Pos %freeRows_2861_old_1661)
        store %Pos %tmp_5933, ptr %freeRows_2861pointer_1660, !noalias !2
        
        %put_6158_temporary_1662 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_6158 = insertvalue %Pos %put_6158_temporary_1662, %Object null, 1
        
        %stackPointer_1664 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1665 = getelementptr %FrameHeader, %StackPointer %stackPointer_1664, i64 0, i32 0
        %returnAddress_1663 = load %ReturnAddress, ptr %returnAddress_pointer_1665, !noalias !2
        musttail call tailcc void %returnAddress_1663(%Pos %put_6158, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1246(%Pos %v_r_3996_5_63_4929, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1247 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_1248 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1247, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_1248, !noalias !2
        %i_6_4916_pointer_1249 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1247, i64 0, i32 1
        %i_6_4916 = load i64, ptr %i_6_4916_pointer_1249, !noalias !2
        %j_2878_pointer_1250 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1247, i64 0, i32 2
        %j_2878 = load %Reference, ptr %j_2878_pointer_1250, !noalias !2
        %queenRows_2864_pointer_1251 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1247, i64 0, i32 3
        %queenRows_2864 = load %Reference, ptr %queenRows_2864_pointer_1251, !noalias !2
        %freeMins_2863_pointer_1252 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1247, i64 0, i32 4
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_1252, !noalias !2
        %freeMaxs_2862_pointer_1253 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1247, i64 0, i32 5
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_1253, !noalias !2
        %n_2854_pointer_1254 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1247, i64 0, i32 6
        %n_2854 = load i64, ptr %n_2854_pointer_1254, !noalias !2
        %stackPointer_1336 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_1337 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1337, !noalias !2
        %i_6_4916_pointer_1338 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 1
        store i64 %i_6_4916, ptr %i_6_4916_pointer_1338, !noalias !2
        %j_2878_pointer_1339 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 2
        store %Reference %j_2878, ptr %j_2878_pointer_1339, !noalias !2
        %queenRows_2864_pointer_1340 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 3
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1340, !noalias !2
        %freeMins_2863_pointer_1341 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 4
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1341, !noalias !2
        %freeMaxs_2862_pointer_1342 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 5
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1342, !noalias !2
        %n_2854_pointer_1343 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1336, i64 0, i32 6
        store i64 %n_2854, ptr %n_2854_pointer_1343, !noalias !2
        %returnAddress_pointer_1344 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1336, i64 0, i32 1, i32 0
        %sharer_pointer_1345 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1336, i64 0, i32 1, i32 1
        %eraser_pointer_1346 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1336, i64 0, i32 1, i32 2
        store ptr @returnAddress_1255, ptr %returnAddress_pointer_1344, !noalias !2
        store ptr @sharer_1280, ptr %sharer_pointer_1345, !noalias !2
        store ptr @eraser_1296, ptr %eraser_pointer_1346, !noalias !2
        
        %tag_1347 = extractvalue %Pos %v_r_3996_5_63_4929, 0
        %fields_1348 = extractvalue %Pos %v_r_3996_5_63_4929, 1
        switch i64 %tag_1347, label %label_1349 [i64 0, label %label_1354 i64 1, label %label_1688]
    
    label_1349:
        
        ret void
    
    label_1354:
        
        %booleanLiteral_6117_temporary_1350 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_6117 = insertvalue %Pos %booleanLiteral_6117_temporary_1350, %Object null, 1
        
        %stackPointer_1352 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1353 = getelementptr %FrameHeader, %StackPointer %stackPointer_1352, i64 0, i32 0
        %returnAddress_1351 = load %ReturnAddress, ptr %returnAddress_pointer_1353, !noalias !2
        musttail call tailcc void %returnAddress_1351(%Pos %booleanLiteral_6117, %Stack %stack)
        ret void
    
    label_1688:
        
        %pureApp_6118 = call ccc %Pos @allocate_2473(i64 %n_2854)
        
        
        call ccc void @sharePositive(%Pos %pureApp_6118)
        %stackPointer_1678 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 112)
        %freeRows_2861_pointer_1679 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1678, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1679, !noalias !2
        %tmp_5933_pointer_1680 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1678, i64 0, i32 1
        store %Pos %pureApp_6118, ptr %tmp_5933_pointer_1680, !noalias !2
        %queenRows_2864_pointer_1681 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1678, i64 0, i32 2
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1681, !noalias !2
        %freeMins_2863_pointer_1682 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1678, i64 0, i32 3
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1682, !noalias !2
        %freeMaxs_2862_pointer_1683 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1678, i64 0, i32 4
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1683, !noalias !2
        %n_2854_pointer_1684 = getelementptr <{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1678, i64 0, i32 5
        store i64 %n_2854, ptr %n_2854_pointer_1684, !noalias !2
        %returnAddress_pointer_1685 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1678, i64 0, i32 1, i32 0
        %sharer_pointer_1686 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1678, i64 0, i32 1, i32 1
        %eraser_pointer_1687 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1678, i64 0, i32 1, i32 2
        store ptr @returnAddress_1365, ptr %returnAddress_pointer_1685, !noalias !2
        store ptr @sharer_1499, ptr %sharer_pointer_1686, !noalias !2
        store ptr @eraser_1513, ptr %eraser_pointer_1687, !noalias !2
        
        %longLiteral_6159 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_6_6_69_4941(i64 %longLiteral_6159, i64 %n_2854, %Pos %pureApp_6118, %Stack %stack)
        ret void
}



define tailcc void @loop_5_4913(i64 %i_6_4916, %Reference %freeRows_2861, %Reference %j_2878, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_6112 = add i64 10, 0
        
        %pureApp_6111 = call ccc %Pos @infixLt_178(i64 %i_6_4916, i64 %longLiteral_6112)
        
        
        
        %tag_1238 = extractvalue %Pos %pureApp_6111, 0
        %fields_1239 = extractvalue %Pos %pureApp_6111, 1
        switch i64 %tag_1238, label %label_1240 [i64 0, label %label_1245 i64 1, label %label_1719]
    
    label_1240:
        
        ret void
    
    label_1245:
        
        %unitLiteral_6113_temporary_1241 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_6113 = insertvalue %Pos %unitLiteral_6113_temporary_1241, %Object null, 1
        
        %stackPointer_1243 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1244 = getelementptr %FrameHeader, %StackPointer %stackPointer_1243, i64 0, i32 0
        %returnAddress_1242 = load %ReturnAddress, ptr %returnAddress_pointer_1244, !noalias !2
        musttail call tailcc void %returnAddress_1242(%Pos %unitLiteral_6113, %Stack %stack)
        ret void
    
    label_1719:
        %stackPointer_1703 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 120)
        %freeRows_2861_pointer_1704 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1703, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1704, !noalias !2
        %i_6_4916_pointer_1705 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1703, i64 0, i32 1
        store i64 %i_6_4916, ptr %i_6_4916_pointer_1705, !noalias !2
        %j_2878_pointer_1706 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1703, i64 0, i32 2
        store %Reference %j_2878, ptr %j_2878_pointer_1706, !noalias !2
        %queenRows_2864_pointer_1707 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1703, i64 0, i32 3
        store %Reference %queenRows_2864, ptr %queenRows_2864_pointer_1707, !noalias !2
        %freeMins_2863_pointer_1708 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1703, i64 0, i32 4
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1708, !noalias !2
        %freeMaxs_2862_pointer_1709 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1703, i64 0, i32 5
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1709, !noalias !2
        %n_2854_pointer_1710 = getelementptr <{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1703, i64 0, i32 6
        store i64 %n_2854, ptr %n_2854_pointer_1710, !noalias !2
        %returnAddress_pointer_1711 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1703, i64 0, i32 1, i32 0
        %sharer_pointer_1712 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1703, i64 0, i32 1, i32 1
        %eraser_pointer_1713 = getelementptr <{<{%Reference, i64, %Reference, %Reference, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1703, i64 0, i32 1, i32 2
        store ptr @returnAddress_1246, ptr %returnAddress_pointer_1711, !noalias !2
        store ptr @sharer_1280, ptr %sharer_pointer_1712, !noalias !2
        store ptr @eraser_1296, ptr %eraser_pointer_1713, !noalias !2
        
        %get_6160_pointer_1714 = call ccc ptr @getVarPointer(%Reference %j_2878, %Stack %stack)
        %j_2878_old_1715 = load %Pos, ptr %get_6160_pointer_1714, !noalias !2
        call ccc void @sharePositive(%Pos %j_2878_old_1715)
        %get_6160 = load %Pos, ptr %get_6160_pointer_1714, !noalias !2
        
        %stackPointer_1717 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1718 = getelementptr %FrameHeader, %StackPointer %stackPointer_1717, i64 0, i32 0
        %returnAddress_1716 = load %ReturnAddress, ptr %returnAddress_pointer_1718, !noalias !2
        musttail call tailcc void %returnAddress_1716(%Pos %get_6160, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1720(%Pos %__6161, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1721 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %j_2878_pointer_1722 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1721, i64 0, i32 0
        %j_2878 = load %Reference, ptr %j_2878_pointer_1722, !noalias !2
        call ccc void @erasePositive(%Pos %__6161)
        
        %get_6162_pointer_1723 = call ccc ptr @getVarPointer(%Reference %j_2878, %Stack %stack)
        %j_2878_old_1724 = load %Pos, ptr %get_6162_pointer_1723, !noalias !2
        call ccc void @sharePositive(%Pos %j_2878_old_1724)
        %get_6162 = load %Pos, ptr %get_6162_pointer_1723, !noalias !2
        
        %stackPointer_1726 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1727 = getelementptr %FrameHeader, %StackPointer %stackPointer_1726, i64 0, i32 0
        %returnAddress_1725 = load %ReturnAddress, ptr %returnAddress_pointer_1727, !noalias !2
        musttail call tailcc void %returnAddress_1725(%Pos %get_6162, %Stack %stack)
        ret void
}



define ccc void @sharer_1729(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1730 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %j_2878_1728_pointer_1731 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1730, i64 0, i32 0
        %j_2878_1728 = load %Reference, ptr %j_2878_1728_pointer_1731, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1730)
        ret void
}



define ccc void @eraser_1733(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1734 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %j_2878_1732_pointer_1735 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1734, i64 0, i32 0
        %j_2878_1732 = load %Reference, ptr %j_2878_1732_pointer_1735, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1734)
        ret void
}



define tailcc void @returnAddress_458(%Pos %v_r_3054_15_4512, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_459 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %freeRows_2861_pointer_460 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_459, i64 0, i32 0
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_460, !noalias !2
        %tmp_5900_pointer_461 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_459, i64 0, i32 1
        %tmp_5900 = load %Pos, ptr %tmp_5900_pointer_461, !noalias !2
        %freeMins_2863_pointer_462 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_459, i64 0, i32 2
        %freeMins_2863 = load %Reference, ptr %freeMins_2863_pointer_462, !noalias !2
        %freeMaxs_2862_pointer_463 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_459, i64 0, i32 3
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_463, !noalias !2
        %n_2854_pointer_464 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_459, i64 0, i32 4
        %n_2854 = load i64, ptr %n_2854_pointer_464, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3054_15_4512)
        %queenRows_2864 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_474 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %tmp_5900_pointer_475 = getelementptr <{%Pos}>, %StackPointer %stackPointer_474, i64 0, i32 0
        store %Pos %tmp_5900, ptr %tmp_5900_pointer_475, !noalias !2
        %returnAddress_pointer_476 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_474, i64 0, i32 1, i32 0
        %sharer_pointer_477 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_474, i64 0, i32 1, i32 1
        %eraser_pointer_478 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_474, i64 0, i32 1, i32 2
        store ptr @returnAddress_465, ptr %returnAddress_pointer_476, !noalias !2
        store ptr @sharer_378, ptr %sharer_pointer_477, !noalias !2
        store ptr @eraser_382, ptr %eraser_pointer_478, !noalias !2
        
        %booleanLiteral_6109_temporary_1223 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6109 = insertvalue %Pos %booleanLiteral_6109_temporary_1223, %Object null, 1
        
        
        %j_2878 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_1233 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %v_r_3034_4162_pointer_1234 = getelementptr <{%Pos}>, %StackPointer %stackPointer_1233, i64 0, i32 0
        store %Pos %booleanLiteral_6109, ptr %v_r_3034_4162_pointer_1234, !noalias !2
        %returnAddress_pointer_1235 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1233, i64 0, i32 1, i32 0
        %sharer_pointer_1236 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1233, i64 0, i32 1, i32 1
        %eraser_pointer_1237 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_1233, i64 0, i32 1, i32 2
        store ptr @returnAddress_1224, ptr %returnAddress_pointer_1235, !noalias !2
        store ptr @sharer_378, ptr %sharer_pointer_1236, !noalias !2
        store ptr @eraser_382, ptr %eraser_pointer_1237, !noalias !2
        %stackPointer_1736 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %j_2878_pointer_1737 = getelementptr <{%Reference}>, %StackPointer %stackPointer_1736, i64 0, i32 0
        store %Reference %j_2878, ptr %j_2878_pointer_1737, !noalias !2
        %returnAddress_pointer_1738 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1736, i64 0, i32 1, i32 0
        %sharer_pointer_1739 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1736, i64 0, i32 1, i32 1
        %eraser_pointer_1740 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1736, i64 0, i32 1, i32 2
        store ptr @returnAddress_1720, ptr %returnAddress_pointer_1738, !noalias !2
        store ptr @sharer_1729, ptr %sharer_pointer_1739, !noalias !2
        store ptr @eraser_1733, ptr %eraser_pointer_1740, !noalias !2
        
        %longLiteral_6163 = add i64 1, 0
        
        
        
        musttail call tailcc void @loop_5_4913(i64 %longLiteral_6163, %Reference %freeRows_2861, %Reference %j_2878, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, %Stack %stack)
        ret void
}



define ccc void @sharer_1746(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1747 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_1741_pointer_1748 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1747, i64 0, i32 0
        %freeRows_2861_1741 = load %Reference, ptr %freeRows_2861_1741_pointer_1748, !noalias !2
        %tmp_5900_1742_pointer_1749 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1747, i64 0, i32 1
        %tmp_5900_1742 = load %Pos, ptr %tmp_5900_1742_pointer_1749, !noalias !2
        %freeMins_2863_1743_pointer_1750 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1747, i64 0, i32 2
        %freeMins_2863_1743 = load %Reference, ptr %freeMins_2863_1743_pointer_1750, !noalias !2
        %freeMaxs_2862_1744_pointer_1751 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1747, i64 0, i32 3
        %freeMaxs_2862_1744 = load %Reference, ptr %freeMaxs_2862_1744_pointer_1751, !noalias !2
        %n_2854_1745_pointer_1752 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1747, i64 0, i32 4
        %n_2854_1745 = load i64, ptr %n_2854_1745_pointer_1752, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5900_1742)
        call ccc void @shareFrames(%StackPointer %stackPointer_1747)
        ret void
}



define ccc void @eraser_1758(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1759 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %freeRows_2861_1753_pointer_1760 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1759, i64 0, i32 0
        %freeRows_2861_1753 = load %Reference, ptr %freeRows_2861_1753_pointer_1760, !noalias !2
        %tmp_5900_1754_pointer_1761 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1759, i64 0, i32 1
        %tmp_5900_1754 = load %Pos, ptr %tmp_5900_1754_pointer_1761, !noalias !2
        %freeMins_2863_1755_pointer_1762 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1759, i64 0, i32 2
        %freeMins_2863_1755 = load %Reference, ptr %freeMins_2863_1755_pointer_1762, !noalias !2
        %freeMaxs_2862_1756_pointer_1763 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1759, i64 0, i32 3
        %freeMaxs_2862_1756 = load %Reference, ptr %freeMaxs_2862_1756_pointer_1763, !noalias !2
        %n_2854_1757_pointer_1764 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1759, i64 0, i32 4
        %n_2854_1757 = load i64, ptr %n_2854_1757_pointer_1764, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5900_1754)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1759)
        ret void
}



define tailcc void @returnAddress_429(%Pos %v_r_3054_15_4497, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_430 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %tmp_5895_pointer_431 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_430, i64 0, i32 0
        %tmp_5895 = load %Pos, ptr %tmp_5895_pointer_431, !noalias !2
        %freeRows_2861_pointer_432 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_430, i64 0, i32 1
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_432, !noalias !2
        %freeMaxs_2862_pointer_433 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_430, i64 0, i32 2
        %freeMaxs_2862 = load %Reference, ptr %freeMaxs_2862_pointer_433, !noalias !2
        %n_2854_pointer_434 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_430, i64 0, i32 3
        %n_2854 = load i64, ptr %n_2854_pointer_434, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3054_15_4497)
        %freeMins_2863 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_444 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %tmp_5895_pointer_445 = getelementptr <{%Pos}>, %StackPointer %stackPointer_444, i64 0, i32 0
        store %Pos %tmp_5895, ptr %tmp_5895_pointer_445, !noalias !2
        %returnAddress_pointer_446 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_444, i64 0, i32 1, i32 0
        %sharer_pointer_447 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_444, i64 0, i32 1, i32 1
        %eraser_pointer_448 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_444, i64 0, i32 1, i32 2
        store ptr @returnAddress_435, ptr %returnAddress_pointer_446, !noalias !2
        store ptr @sharer_378, ptr %sharer_pointer_447, !noalias !2
        store ptr @eraser_382, ptr %eraser_pointer_448, !noalias !2
        
        %longLiteral_6035 = add i64 -1, 0
        
        %pureApp_6034 = call ccc %Pos @boxInt_301(i64 %longLiteral_6035)
        
        
        
        %longLiteral_6037 = add i64 0, 0
        
        %pureApp_6036 = call ccc %Pos @allocate_2473(i64 %longLiteral_6037)
        
        
        call ccc void @sharePositive(%Pos %pureApp_6036)
        %stackPointer_1765 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %freeRows_2861_pointer_1766 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1765, i64 0, i32 0
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1766, !noalias !2
        %tmp_5900_pointer_1767 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1765, i64 0, i32 1
        store %Pos %pureApp_6036, ptr %tmp_5900_pointer_1767, !noalias !2
        %freeMins_2863_pointer_1768 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1765, i64 0, i32 2
        store %Reference %freeMins_2863, ptr %freeMins_2863_pointer_1768, !noalias !2
        %freeMaxs_2862_pointer_1769 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1765, i64 0, i32 3
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1769, !noalias !2
        %n_2854_pointer_1770 = getelementptr <{%Reference, %Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1765, i64 0, i32 4
        store i64 %n_2854, ptr %n_2854_pointer_1770, !noalias !2
        %returnAddress_pointer_1771 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1765, i64 0, i32 1, i32 0
        %sharer_pointer_1772 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1765, i64 0, i32 1, i32 1
        %eraser_pointer_1773 = getelementptr <{<{%Reference, %Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1765, i64 0, i32 1, i32 2
        store ptr @returnAddress_458, ptr %returnAddress_pointer_1771, !noalias !2
        store ptr @sharer_1746, ptr %sharer_pointer_1772, !noalias !2
        store ptr @eraser_1758, ptr %eraser_pointer_1773, !noalias !2
        
        %longLiteral_6164 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_4500(i64 %longLiteral_6164, %Pos %pureApp_6034, %Pos %pureApp_6036, %Stack %stack)
        ret void
}



define ccc void @sharer_1778(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1779 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5895_1774_pointer_1780 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1779, i64 0, i32 0
        %tmp_5895_1774 = load %Pos, ptr %tmp_5895_1774_pointer_1780, !noalias !2
        %freeRows_2861_1775_pointer_1781 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1779, i64 0, i32 1
        %freeRows_2861_1775 = load %Reference, ptr %freeRows_2861_1775_pointer_1781, !noalias !2
        %freeMaxs_2862_1776_pointer_1782 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1779, i64 0, i32 2
        %freeMaxs_2862_1776 = load %Reference, ptr %freeMaxs_2862_1776_pointer_1782, !noalias !2
        %n_2854_1777_pointer_1783 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1779, i64 0, i32 3
        %n_2854_1777 = load i64, ptr %n_2854_1777_pointer_1783, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5895_1774)
        call ccc void @shareFrames(%StackPointer %stackPointer_1779)
        ret void
}



define ccc void @eraser_1788(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1789 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5895_1784_pointer_1790 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1789, i64 0, i32 0
        %tmp_5895_1784 = load %Pos, ptr %tmp_5895_1784_pointer_1790, !noalias !2
        %freeRows_2861_1785_pointer_1791 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1789, i64 0, i32 1
        %freeRows_2861_1785 = load %Reference, ptr %freeRows_2861_1785_pointer_1791, !noalias !2
        %freeMaxs_2862_1786_pointer_1792 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1789, i64 0, i32 2
        %freeMaxs_2862_1786 = load %Reference, ptr %freeMaxs_2862_1786_pointer_1792, !noalias !2
        %n_2854_1787_pointer_1793 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1789, i64 0, i32 3
        %n_2854_1787 = load i64, ptr %n_2854_1787_pointer_1793, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5895_1784)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1789)
        ret void
}



define tailcc void @returnAddress_400(%Pos %v_r_3054_15_4482, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_401 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %tmp_5891_pointer_402 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_401, i64 0, i32 0
        %tmp_5891 = load %Pos, ptr %tmp_5891_pointer_402, !noalias !2
        %freeRows_2861_pointer_403 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_401, i64 0, i32 1
        %freeRows_2861 = load %Reference, ptr %freeRows_2861_pointer_403, !noalias !2
        %n_2854_pointer_404 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_401, i64 0, i32 2
        %n_2854 = load i64, ptr %n_2854_pointer_404, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3054_15_4482)
        %freeMaxs_2862 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_414 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %tmp_5891_pointer_415 = getelementptr <{%Pos}>, %StackPointer %stackPointer_414, i64 0, i32 0
        store %Pos %tmp_5891, ptr %tmp_5891_pointer_415, !noalias !2
        %returnAddress_pointer_416 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_414, i64 0, i32 1, i32 0
        %sharer_pointer_417 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_414, i64 0, i32 1, i32 1
        %eraser_pointer_418 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_414, i64 0, i32 1, i32 2
        store ptr @returnAddress_405, ptr %returnAddress_pointer_416, !noalias !2
        store ptr @sharer_378, ptr %sharer_pointer_417, !noalias !2
        store ptr @eraser_382, ptr %eraser_pointer_418, !noalias !2
        
        %longLiteral_6025 = add i64 0, 0
        
        %pureApp_6024 = call ccc %Pos @allocate_2473(i64 %longLiteral_6025)
        
        
        call ccc void @sharePositive(%Pos %pureApp_6024)
        %stackPointer_1794 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %tmp_5895_pointer_1795 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1794, i64 0, i32 0
        store %Pos %pureApp_6024, ptr %tmp_5895_pointer_1795, !noalias !2
        %freeRows_2861_pointer_1796 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1794, i64 0, i32 1
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1796, !noalias !2
        %freeMaxs_2862_pointer_1797 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1794, i64 0, i32 2
        store %Reference %freeMaxs_2862, ptr %freeMaxs_2862_pointer_1797, !noalias !2
        %n_2854_pointer_1798 = getelementptr <{%Pos, %Reference, %Reference, i64}>, %StackPointer %stackPointer_1794, i64 0, i32 3
        store i64 %n_2854, ptr %n_2854_pointer_1798, !noalias !2
        %returnAddress_pointer_1799 = getelementptr <{<{%Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1794, i64 0, i32 1, i32 0
        %sharer_pointer_1800 = getelementptr <{<{%Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1794, i64 0, i32 1, i32 1
        %eraser_pointer_1801 = getelementptr <{<{%Pos, %Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1794, i64 0, i32 1, i32 2
        store ptr @returnAddress_429, ptr %returnAddress_pointer_1799, !noalias !2
        store ptr @sharer_1778, ptr %sharer_pointer_1800, !noalias !2
        store ptr @eraser_1788, ptr %eraser_pointer_1801, !noalias !2
        
        %longLiteral_6165 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_4485(i64 %longLiteral_6165, %Pos %pureApp_6024, %Stack %stack)
        ret void
}



define ccc void @sharer_1805(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1806 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5891_1802_pointer_1807 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1806, i64 0, i32 0
        %tmp_5891_1802 = load %Pos, ptr %tmp_5891_1802_pointer_1807, !noalias !2
        %freeRows_2861_1803_pointer_1808 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1806, i64 0, i32 1
        %freeRows_2861_1803 = load %Reference, ptr %freeRows_2861_1803_pointer_1808, !noalias !2
        %n_2854_1804_pointer_1809 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1806, i64 0, i32 2
        %n_2854_1804 = load i64, ptr %n_2854_1804_pointer_1809, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5891_1802)
        call ccc void @shareFrames(%StackPointer %stackPointer_1806)
        ret void
}



define ccc void @eraser_1813(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1814 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5891_1810_pointer_1815 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1814, i64 0, i32 0
        %tmp_5891_1810 = load %Pos, ptr %tmp_5891_1810_pointer_1815, !noalias !2
        %freeRows_2861_1811_pointer_1816 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1814, i64 0, i32 1
        %freeRows_2861_1811 = load %Reference, ptr %freeRows_2861_1811_pointer_1816, !noalias !2
        %n_2854_1812_pointer_1817 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1814, i64 0, i32 2
        %n_2854_1812 = load i64, ptr %n_2854_1812_pointer_1817, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5891_1810)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1814)
        ret void
}



define tailcc void @returnAddress_366(%Pos %v_r_3054_15_4467, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_367 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %tmp_5988_pointer_368 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer_367, i64 0, i32 0
        %tmp_5988 = load %Pos, ptr %tmp_5988_pointer_368, !noalias !2
        %n_2854_pointer_369 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer_367, i64 0, i32 1
        %n_2854 = load i64, ptr %n_2854_pointer_369, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3054_15_4467)
        %freeRows_2861 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_385 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %tmp_5988_pointer_386 = getelementptr <{%Pos}>, %StackPointer %stackPointer_385, i64 0, i32 0
        store %Pos %tmp_5988, ptr %tmp_5988_pointer_386, !noalias !2
        %returnAddress_pointer_387 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 0
        %sharer_pointer_388 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 1
        %eraser_pointer_389 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_385, i64 0, i32 1, i32 2
        store ptr @returnAddress_370, ptr %returnAddress_pointer_387, !noalias !2
        store ptr @sharer_378, ptr %sharer_pointer_388, !noalias !2
        store ptr @eraser_382, ptr %eraser_pointer_389, !noalias !2
        
        %longLiteral_6015 = add i64 0, 0
        
        %pureApp_6014 = call ccc %Pos @allocate_2473(i64 %longLiteral_6015)
        
        
        call ccc void @sharePositive(%Pos %pureApp_6014)
        %stackPointer_1818 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %tmp_5891_pointer_1819 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1818, i64 0, i32 0
        store %Pos %pureApp_6014, ptr %tmp_5891_pointer_1819, !noalias !2
        %freeRows_2861_pointer_1820 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1818, i64 0, i32 1
        store %Reference %freeRows_2861, ptr %freeRows_2861_pointer_1820, !noalias !2
        %n_2854_pointer_1821 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1818, i64 0, i32 2
        store i64 %n_2854, ptr %n_2854_pointer_1821, !noalias !2
        %returnAddress_pointer_1822 = getelementptr <{<{%Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1818, i64 0, i32 1, i32 0
        %sharer_pointer_1823 = getelementptr <{<{%Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1818, i64 0, i32 1, i32 1
        %eraser_pointer_1824 = getelementptr <{<{%Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1818, i64 0, i32 1, i32 2
        store ptr @returnAddress_400, ptr %returnAddress_pointer_1822, !noalias !2
        store ptr @sharer_1805, ptr %sharer_pointer_1823, !noalias !2
        store ptr @eraser_1813, ptr %eraser_pointer_1824, !noalias !2
        
        %longLiteral_6166 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_4470(i64 %longLiteral_6166, %Pos %pureApp_6014, %Stack %stack)
        ret void
}



define ccc void @sharer_1827(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1828 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5988_1825_pointer_1829 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer_1828, i64 0, i32 0
        %tmp_5988_1825 = load %Pos, ptr %tmp_5988_1825_pointer_1829, !noalias !2
        %n_2854_1826_pointer_1830 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer_1828, i64 0, i32 1
        %n_2854_1826 = load i64, ptr %n_2854_1826_pointer_1830, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5988_1825)
        call ccc void @shareFrames(%StackPointer %stackPointer_1828)
        ret void
}



define ccc void @eraser_1833(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1834 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5988_1831_pointer_1835 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer_1834, i64 0, i32 0
        %tmp_5988_1831 = load %Pos, ptr %tmp_5988_1831_pointer_1835, !noalias !2
        %n_2854_1832_pointer_1836 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer_1834, i64 0, i32 1
        %n_2854_1832 = load i64, ptr %n_2854_1832_pointer_1836, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5988_1831)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1834)
        ret void
}



define tailcc void @run_2855(i64 %n_2854, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_6005 = add i64 0, 0
        
        %pureApp_6004 = call ccc %Pos @allocate_2473(i64 %longLiteral_6005)
        
        
        call ccc void @sharePositive(%Pos %pureApp_6004)
        %stackPointer_1837 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 48)
        %tmp_5988_pointer_1838 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer_1837, i64 0, i32 0
        store %Pos %pureApp_6004, ptr %tmp_5988_pointer_1838, !noalias !2
        %n_2854_pointer_1839 = getelementptr <{%Pos, i64}>, %StackPointer %stackPointer_1837, i64 0, i32 1
        store i64 %n_2854, ptr %n_2854_pointer_1839, !noalias !2
        %returnAddress_pointer_1840 = getelementptr <{<{%Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1837, i64 0, i32 1, i32 0
        %sharer_pointer_1841 = getelementptr <{<{%Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1837, i64 0, i32 1, i32 1
        %eraser_pointer_1842 = getelementptr <{<{%Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1837, i64 0, i32 1, i32 2
        store ptr @returnAddress_366, ptr %returnAddress_pointer_1840, !noalias !2
        store ptr @sharer_1827, ptr %sharer_pointer_1841, !noalias !2
        store ptr @eraser_1833, ptr %eraser_pointer_1842, !noalias !2
        
        %longLiteral_6167 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_4455(i64 %longLiteral_6167, %Pos %pureApp_6004, %Stack %stack)
        ret void
}


@utf8StringLiteral_5995.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5997.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_6000.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_1843(%Pos %v_r_3316_4112, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1844 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_1845 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1844, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_1845, !noalias !2
        %index_2107_pointer_1846 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1844, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_1846, !noalias !2
        %Exception_2362_pointer_1847 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1844, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_1847, !noalias !2
        
        %tag_1848 = extractvalue %Pos %v_r_3316_4112, 0
        %fields_1849 = extractvalue %Pos %v_r_3316_4112, 1
        switch i64 %tag_1848, label %label_1850 [i64 0, label %label_1854 i64 1, label %label_1860]
    
    label_1850:
        
        ret void
    
    label_1854:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5991 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_1852 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1853 = getelementptr %FrameHeader, %StackPointer %stackPointer_1852, i64 0, i32 0
        %returnAddress_1851 = load %ReturnAddress, ptr %returnAddress_pointer_1853, !noalias !2
        musttail call tailcc void %returnAddress_1851(i64 %pureApp_5991, %Stack %stack)
        ret void
    
    label_1860:
        
        %make_5992_temporary_1855 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5992 = insertvalue %Pos %make_5992_temporary_1855, %Object null, 1
        
        
        
        %pureApp_5993 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5995 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5995.lit)
        
        %pureApp_5994 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5995, %Pos %pureApp_5993)
        
        
        
        %utf8StringLiteral_5997 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5997.lit)
        
        %pureApp_5996 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5994, %Pos %utf8StringLiteral_5997)
        
        
        
        %pureApp_5998 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5996, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_6000 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_6000.lit)
        
        %pureApp_5999 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5998, %Pos %utf8StringLiteral_6000)
        
        
        
        %vtable_1856 = extractvalue %Neg %Exception_2362, 0
        %closure_1857 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_1858 = getelementptr ptr, ptr %vtable_1856, i64 0
        %functionPointer_1859 = load ptr, ptr %functionPointer_pointer_1858, !noalias !2
        musttail call tailcc void %functionPointer_1859(%Object %closure_1857, %Pos %make_5992, %Pos %pureApp_5999, %Stack %stack)
        ret void
}



define ccc void @sharer_1864(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1865 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_1861_pointer_1866 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1865, i64 0, i32 0
        %str_2106_1861 = load %Pos, ptr %str_2106_1861_pointer_1866, !noalias !2
        %index_2107_1862_pointer_1867 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1865, i64 0, i32 1
        %index_2107_1862 = load i64, ptr %index_2107_1862_pointer_1867, !noalias !2
        %Exception_2362_1863_pointer_1868 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1865, i64 0, i32 2
        %Exception_2362_1863 = load %Neg, ptr %Exception_2362_1863_pointer_1868, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_1861)
        call ccc void @shareNegative(%Neg %Exception_2362_1863)
        call ccc void @shareFrames(%StackPointer %stackPointer_1865)
        ret void
}



define ccc void @eraser_1872(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1873 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_1869_pointer_1874 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1873, i64 0, i32 0
        %str_2106_1869 = load %Pos, ptr %str_2106_1869_pointer_1874, !noalias !2
        %index_2107_1870_pointer_1875 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1873, i64 0, i32 1
        %index_2107_1870 = load i64, ptr %index_2107_1870_pointer_1875, !noalias !2
        %Exception_2362_1871_pointer_1876 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1873, i64 0, i32 2
        %Exception_2362_1871 = load %Neg, ptr %Exception_2362_1871_pointer_1876, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_1869)
        call ccc void @eraseNegative(%Neg %Exception_2362_1871)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1873)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5990 = add i64 0, 0
        
        %pureApp_5989 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5990)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_1877 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_1878 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1877, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_1878, !noalias !2
        %index_2107_pointer_1879 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1877, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_1879, !noalias !2
        %Exception_2362_pointer_1880 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1877, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_1880, !noalias !2
        %returnAddress_pointer_1881 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1877, i64 0, i32 1, i32 0
        %sharer_pointer_1882 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1877, i64 0, i32 1, i32 1
        %eraser_pointer_1883 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1877, i64 0, i32 1, i32 2
        store ptr @returnAddress_1843, ptr %returnAddress_pointer_1881, !noalias !2
        store ptr @sharer_1864, ptr %sharer_pointer_1882, !noalias !2
        store ptr @eraser_1872, ptr %eraser_pointer_1883, !noalias !2
        
        %tag_1884 = extractvalue %Pos %pureApp_5989, 0
        %fields_1885 = extractvalue %Pos %pureApp_5989, 1
        switch i64 %tag_1884, label %label_1886 [i64 0, label %label_1890 i64 1, label %label_1895]
    
    label_1886:
        
        ret void
    
    label_1890:
        
        %pureApp_6001 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_6002 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_6001)
        
        
        
        %stackPointer_1888 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1889 = getelementptr %FrameHeader, %StackPointer %stackPointer_1888, i64 0, i32 0
        %returnAddress_1887 = load %ReturnAddress, ptr %returnAddress_pointer_1889, !noalias !2
        musttail call tailcc void %returnAddress_1887(%Pos %pureApp_6002, %Stack %stack)
        ret void
    
    label_1895:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_6003_temporary_1891 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_6003 = insertvalue %Pos %booleanLiteral_6003_temporary_1891, %Object null, 1
        
        %stackPointer_1893 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1894 = getelementptr %FrameHeader, %StackPointer %stackPointer_1893, i64 0, i32 0
        %returnAddress_1892 = load %ReturnAddress, ptr %returnAddress_pointer_1894, !noalias !2
        musttail call tailcc void %returnAddress_1892(%Pos %booleanLiteral_6003, %Stack %stack)
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
        
        musttail call tailcc void @main_2856(%Stack %stack)
        ret void
}
