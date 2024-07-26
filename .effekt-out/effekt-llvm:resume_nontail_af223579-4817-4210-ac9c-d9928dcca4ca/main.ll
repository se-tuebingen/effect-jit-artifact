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



define tailcc void @returnAddress_5(i64 %v_r_2508_39_4507, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_6 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %l_3_4498_pointer_7 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_6, i64 0, i32 0
        %l_3_4498 = load i64, ptr %l_3_4498_pointer_7, !noalias !2
        %tmp_4642_pointer_8 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_6, i64 0, i32 1
        %tmp_4642 = load i64, ptr %tmp_4642_pointer_8, !noalias !2
        
        %longLiteral_4662 = add i64 1, 0
        
        %pureApp_4661 = call ccc i64 @infixSub_105(i64 %l_3_4498, i64 %longLiteral_4662)
        
        
        
        
        
        
        musttail call tailcc void @step_2_4509(i64 %pureApp_4661, i64 %v_r_2508_39_4507, i64 %tmp_4642, %Stack %stack)
        ret void
}



define ccc void @sharer_11(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %l_3_4498_9_pointer_13 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_12, i64 0, i32 0
        %l_3_4498_9 = load i64, ptr %l_3_4498_9_pointer_13, !noalias !2
        %tmp_4642_10_pointer_14 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_12, i64 0, i32 1
        %tmp_4642_10 = load i64, ptr %tmp_4642_10_pointer_14, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_12)
        ret void
}



define ccc void @eraser_17(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_18 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %l_3_4498_15_pointer_19 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_18, i64 0, i32 0
        %l_3_4498_15 = load i64, ptr %l_3_4498_15_pointer_19, !noalias !2
        %tmp_4642_16_pointer_20 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_18, i64 0, i32 1
        %tmp_4642_16 = load i64, ptr %tmp_4642_16_pointer_20, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_18)
        ret void
}



define tailcc void @returnAddress_28(i64 %returned_4663, %Stack %stack) {
        
    entry:
        
        %stack_29 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_31 = call ccc %StackPointer @stackDeallocate(%Stack %stack_29, i64 24)
        %returnAddress_pointer_32 = getelementptr %FrameHeader, %StackPointer %stackPointer_31, i64 0, i32 0
        %returnAddress_30 = load %ReturnAddress, ptr %returnAddress_pointer_32, !noalias !2
        musttail call tailcc void %returnAddress_30(i64 %returned_4663, %Stack %stack_29)
        ret void
}



define ccc void @sharer_33(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_34 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_35(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_36 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_36)
        ret void
}



define tailcc void @returnAddress_44(%Pos %__8_34_37_4528, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_45 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %i_6_20_23_4512_pointer_46 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_45, i64 0, i32 0
        %i_6_20_23_4512 = load i64, ptr %i_6_20_23_4512_pointer_46, !noalias !2
        %s_4_4515_pointer_47 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_45, i64 0, i32 1
        %s_4_4515 = load i64, ptr %s_4_4515_pointer_47, !noalias !2
        %p_4_7_4518_pointer_48 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_45, i64 0, i32 2
        %p_4_7_4518 = load %Prompt, ptr %p_4_7_4518_pointer_48, !noalias !2
        call ccc void @erasePositive(%Pos %__8_34_37_4528)
        
        %longLiteral_4667 = add i64 1, 0
        
        %pureApp_4666 = call ccc i64 @infixSub_105(i64 %i_6_20_23_4512, i64 %longLiteral_4667)
        
        
        
        
        
        musttail call tailcc void @loop_worker_5_19_22_4519(i64 %pureApp_4666, i64 %s_4_4515, %Prompt %p_4_7_4518, %Stack %stack)
        ret void
}



define ccc void @sharer_52(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_53 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %i_6_20_23_4512_49_pointer_54 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_53, i64 0, i32 0
        %i_6_20_23_4512_49 = load i64, ptr %i_6_20_23_4512_49_pointer_54, !noalias !2
        %s_4_4515_50_pointer_55 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_53, i64 0, i32 1
        %s_4_4515_50 = load i64, ptr %s_4_4515_50_pointer_55, !noalias !2
        %p_4_7_4518_51_pointer_56 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_53, i64 0, i32 2
        %p_4_7_4518_51 = load %Prompt, ptr %p_4_7_4518_51_pointer_56, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_53)
        ret void
}



define ccc void @eraser_60(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_61 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %i_6_20_23_4512_57_pointer_62 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_61, i64 0, i32 0
        %i_6_20_23_4512_57 = load i64, ptr %i_6_20_23_4512_57_pointer_62, !noalias !2
        %s_4_4515_58_pointer_63 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_61, i64 0, i32 1
        %s_4_4515_58 = load i64, ptr %s_4_4515_58_pointer_63, !noalias !2
        %p_4_7_4518_59_pointer_64 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_61, i64 0, i32 2
        %p_4_7_4518_59 = load %Prompt, ptr %p_4_7_4518_59_pointer_64, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_61)
        ret void
}



define tailcc void @returnAddress_77(i64 %v_r_2503_12_32_35_4526, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4676 = add i64 1009, 0
        
        %pureApp_4675 = call ccc i64 @mod_108(i64 %v_r_2503_12_32_35_4526, i64 %longLiteral_4676)
        
        
        
        %stackPointer_79 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_80 = getelementptr %FrameHeader, %StackPointer %stackPointer_79, i64 0, i32 0
        %returnAddress_78 = load %ReturnAddress, ptr %returnAddress_pointer_80, !noalias !2
        musttail call tailcc void %returnAddress_78(i64 %pureApp_4675, %Stack %stack)
        ret void
}



define ccc void @sharer_81(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_82 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_82)
        ret void
}



define ccc void @eraser_83(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_84 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_84)
        ret void
}



define tailcc void @returnAddress_74(i64 %y_6_26_29_4495, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_75 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %i_6_20_23_4512_pointer_76 = getelementptr <{i64}>, %StackPointer %stackPointer_75, i64 0, i32 0
        %i_6_20_23_4512 = load i64, ptr %i_6_20_23_4512_pointer_76, !noalias !2
        
        %longLiteral_4669 = add i64 503, 0
        
        %pureApp_4668 = call ccc i64 @infixMul_99(i64 %longLiteral_4669, i64 %y_6_26_29_4495)
        
        
        
        %pureApp_4670 = call ccc i64 @infixSub_105(i64 %i_6_20_23_4512, i64 %pureApp_4668)
        
        
        
        %longLiteral_4672 = add i64 37, 0
        
        %pureApp_4671 = call ccc i64 @infixAdd_96(i64 %pureApp_4670, i64 %longLiteral_4672)
        
        
        
        %longLiteral_4674 = add i64 0, 0
        
        %pureApp_4673 = call ccc %Pos @infixLt_178(i64 %pureApp_4671, i64 %longLiteral_4674)
        
        
        %stackPointer_85 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_86 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_85, i64 0, i32 1, i32 0
        %sharer_pointer_87 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_85, i64 0, i32 1, i32 1
        %eraser_pointer_88 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_85, i64 0, i32 1, i32 2
        store ptr @returnAddress_77, ptr %returnAddress_pointer_86, !noalias !2
        store ptr @sharer_81, ptr %sharer_pointer_87, !noalias !2
        store ptr @eraser_83, ptr %eraser_pointer_88, !noalias !2
        
        %tag_89 = extractvalue %Pos %pureApp_4673, 0
        %fields_90 = extractvalue %Pos %pureApp_4673, 1
        switch i64 %tag_89, label %label_91 [i64 0, label %label_95 i64 1, label %label_99]
    
    label_91:
        
        ret void
    
    label_95:
        
        %stackPointer_93 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_94 = getelementptr %FrameHeader, %StackPointer %stackPointer_93, i64 0, i32 0
        %returnAddress_92 = load %ReturnAddress, ptr %returnAddress_pointer_94, !noalias !2
        musttail call tailcc void %returnAddress_92(i64 %pureApp_4671, %Stack %stack)
        ret void
    
    label_99:
        
        %longLiteral_4678 = add i64 0, 0
        
        %pureApp_4677 = call ccc i64 @infixSub_105(i64 %longLiteral_4678, i64 %pureApp_4671)
        
        
        
        %stackPointer_97 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_98 = getelementptr %FrameHeader, %StackPointer %stackPointer_97, i64 0, i32 0
        %returnAddress_96 = load %ReturnAddress, ptr %returnAddress_pointer_98, !noalias !2
        musttail call tailcc void %returnAddress_96(i64 %pureApp_4677, %Stack %stack)
        ret void
}



define ccc void @sharer_101(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_102 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_20_23_4512_100_pointer_103 = getelementptr <{i64}>, %StackPointer %stackPointer_102, i64 0, i32 0
        %i_6_20_23_4512_100 = load i64, ptr %i_6_20_23_4512_100_pointer_103, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_102)
        ret void
}



define ccc void @eraser_105(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_106 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_20_23_4512_104_pointer_107 = getelementptr <{i64}>, %StackPointer %stackPointer_106, i64 0, i32 0
        %i_6_20_23_4512_104 = load i64, ptr %i_6_20_23_4512_104_pointer_107, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_106)
        ret void
}



define tailcc void @loop_worker_5_19_22_4519(i64 %i_6_20_23_4512, i64 %s_4_4515, %Prompt %p_4_7_4518, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4665 = add i64 0, 0
        
        %pureApp_4664 = call ccc %Pos @infixEq_72(i64 %i_6_20_23_4512, i64 %longLiteral_4665)
        
        
        
        %tag_41 = extractvalue %Pos %pureApp_4664, 0
        %fields_42 = extractvalue %Pos %pureApp_4664, 1
        switch i64 %tag_41, label %label_43 [i64 0, label %label_118 i64 1, label %label_122]
    
    label_43:
        
        ret void
    
    label_118:
        %stackPointer_65 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 48)
        %i_6_20_23_4512_pointer_66 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_65, i64 0, i32 0
        store i64 %i_6_20_23_4512, ptr %i_6_20_23_4512_pointer_66, !noalias !2
        %s_4_4515_pointer_67 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_65, i64 0, i32 1
        store i64 %s_4_4515, ptr %s_4_4515_pointer_67, !noalias !2
        %p_4_7_4518_pointer_68 = getelementptr <{i64, i64, %Prompt}>, %StackPointer %stackPointer_65, i64 0, i32 2
        store %Prompt %p_4_7_4518, ptr %p_4_7_4518_pointer_68, !noalias !2
        %returnAddress_pointer_69 = getelementptr <{<{i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_65, i64 0, i32 1, i32 0
        %sharer_pointer_70 = getelementptr <{<{i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_65, i64 0, i32 1, i32 1
        %eraser_pointer_71 = getelementptr <{<{i64, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_65, i64 0, i32 1, i32 2
        store ptr @returnAddress_44, ptr %returnAddress_pointer_69, !noalias !2
        store ptr @sharer_52, ptr %sharer_pointer_70, !noalias !2
        store ptr @eraser_60, ptr %eraser_pointer_71, !noalias !2
        
        %pair_72 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_7_4518)
        %k_3_23_26_4513 = extractvalue <{%Resumption, %Stack}> %pair_72, 0
        %stack_73 = extractvalue <{%Resumption, %Stack}> %pair_72, 1
        %stackPointer_108 = call ccc %StackPointer @stackAllocate(%Stack %stack_73, i64 32)
        %i_6_20_23_4512_pointer_109 = getelementptr <{i64}>, %StackPointer %stackPointer_108, i64 0, i32 0
        store i64 %i_6_20_23_4512, ptr %i_6_20_23_4512_pointer_109, !noalias !2
        %returnAddress_pointer_110 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_108, i64 0, i32 1, i32 0
        %sharer_pointer_111 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_108, i64 0, i32 1, i32 1
        %eraser_pointer_112 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_108, i64 0, i32 1, i32 2
        store ptr @returnAddress_74, ptr %returnAddress_pointer_110, !noalias !2
        store ptr @sharer_101, ptr %sharer_pointer_111, !noalias !2
        store ptr @eraser_105, ptr %eraser_pointer_112, !noalias !2
        
        %stack_113 = call ccc %Stack @resume(%Resumption %k_3_23_26_4513, %Stack %stack_73)
        
        %unitLiteral_4679_temporary_114 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_4679 = insertvalue %Pos %unitLiteral_4679_temporary_114, %Object null, 1
        
        %stackPointer_116 = call ccc %StackPointer @stackDeallocate(%Stack %stack_113, i64 24)
        %returnAddress_pointer_117 = getelementptr %FrameHeader, %StackPointer %stackPointer_116, i64 0, i32 0
        %returnAddress_115 = load %ReturnAddress, ptr %returnAddress_pointer_117, !noalias !2
        musttail call tailcc void %returnAddress_115(%Pos %unitLiteral_4679, %Stack %stack_113)
        ret void
    
    label_122:
        
        %stackPointer_120 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_121 = getelementptr %FrameHeader, %StackPointer %stackPointer_120, i64 0, i32 0
        %returnAddress_119 = load %ReturnAddress, ptr %returnAddress_pointer_121, !noalias !2
        musttail call tailcc void %returnAddress_119(i64 %s_4_4515, %Stack %stack)
        ret void
}



define tailcc void @step_2_4509(i64 %l_3_4498, i64 %s_4_4515, i64 %tmp_4642, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4660 = add i64 0, 0
        
        %pureApp_4659 = call ccc %Pos @infixEq_72(i64 %l_3_4498, i64 %longLiteral_4660)
        
        
        
        %tag_2 = extractvalue %Pos %pureApp_4659, 0
        %fields_3 = extractvalue %Pos %pureApp_4659, 1
        switch i64 %tag_2, label %label_4 [i64 0, label %label_123 i64 1, label %label_127]
    
    label_4:
        
        ret void
    
    label_123:
        %stackPointer_21 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %l_3_4498_pointer_22 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_21, i64 0, i32 0
        store i64 %l_3_4498, ptr %l_3_4498_pointer_22, !noalias !2
        %tmp_4642_pointer_23 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_21, i64 0, i32 1
        store i64 %tmp_4642, ptr %tmp_4642_pointer_23, !noalias !2
        %returnAddress_pointer_24 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_21, i64 0, i32 1, i32 0
        %sharer_pointer_25 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_21, i64 0, i32 1, i32 1
        %eraser_pointer_26 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_21, i64 0, i32 1, i32 2
        store ptr @returnAddress_5, ptr %returnAddress_pointer_24, !noalias !2
        store ptr @sharer_11, ptr %sharer_pointer_25, !noalias !2
        store ptr @eraser_17, ptr %eraser_pointer_26, !noalias !2
        
        %stack_27 = call ccc %Stack @reset(%Stack %stack)
        %p_4_7_4518 = call ccc %Prompt @currentPrompt(%Stack %stack_27)
        %stackPointer_37 = call ccc %StackPointer @stackAllocate(%Stack %stack_27, i64 24)
        %returnAddress_pointer_38 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_37, i64 0, i32 1, i32 0
        %sharer_pointer_39 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_37, i64 0, i32 1, i32 1
        %eraser_pointer_40 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_37, i64 0, i32 1, i32 2
        store ptr @returnAddress_28, ptr %returnAddress_pointer_38, !noalias !2
        store ptr @sharer_33, ptr %sharer_pointer_39, !noalias !2
        store ptr @eraser_35, ptr %eraser_pointer_40, !noalias !2
        
        
        
        musttail call tailcc void @loop_worker_5_19_22_4519(i64 %tmp_4642, i64 %s_4_4515, %Prompt %p_4_7_4518, %Stack %stack_27)
        ret void
    
    label_127:
        
        %stackPointer_125 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_126 = getelementptr %FrameHeader, %StackPointer %stackPointer_125, i64 0, i32 0
        %returnAddress_124 = load %ReturnAddress, ptr %returnAddress_pointer_126, !noalias !2
        musttail call tailcc void %returnAddress_124(i64 %s_4_4515, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_128(i64 %r_2453, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4680 = call ccc %Pos @show_14(i64 %r_2453)
        
        
        
        %pureApp_4681 = call ccc %Pos @println_1(%Pos %pureApp_4680)
        
        
        
        %stackPointer_130 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_131 = getelementptr %FrameHeader, %StackPointer %stackPointer_130, i64 0, i32 0
        %returnAddress_129 = load %ReturnAddress, ptr %returnAddress_pointer_131, !noalias !2
        musttail call tailcc void %returnAddress_129(%Pos %pureApp_4681, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3438_3502, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4658 = call ccc i64 @unboxInt_303(%Pos %v_coe_3438_3502)
        
        
        %stackPointer_132 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_133 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_132, i64 0, i32 1, i32 0
        %sharer_pointer_134 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_132, i64 0, i32 1, i32 1
        %eraser_pointer_135 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_132, i64 0, i32 1, i32 2
        store ptr @returnAddress_128, ptr %returnAddress_pointer_133, !noalias !2
        store ptr @sharer_81, ptr %sharer_pointer_134, !noalias !2
        store ptr @eraser_83, ptr %eraser_pointer_135, !noalias !2
        
        %longLiteral_4682 = add i64 1000, 0
        
        %longLiteral_4683 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @step_2_4509(i64 %longLiteral_4682, i64 %longLiteral_4683, i64 %pureApp_4658, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_141(%Pos %returned_4684, %Stack %stack) {
        
    entry:
        
        %stack_142 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_144 = call ccc %StackPointer @stackDeallocate(%Stack %stack_142, i64 24)
        %returnAddress_pointer_145 = getelementptr %FrameHeader, %StackPointer %stackPointer_144, i64 0, i32 0
        %returnAddress_143 = load %ReturnAddress, ptr %returnAddress_pointer_145, !noalias !2
        musttail call tailcc void %returnAddress_143(%Pos %returned_4684, %Stack %stack_142)
        ret void
}



define ccc void @eraser_157(%Environment %environment) {
        
    entry:
        
        %tmp_4600_155_pointer_158 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4600_155 = load %Pos, ptr %tmp_4600_155_pointer_158, !noalias !2
        %acc_3_3_5_169_4161_156_pointer_159 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4161_156 = load %Pos, ptr %acc_3_3_5_169_4161_156_pointer_159, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4600_155)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4161_156)
        ret void
}



define tailcc void @toList_1_1_3_167_4376(i64 %start_2_2_4_168_4297, %Pos %acc_3_3_5_169_4161, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4686 = add i64 1, 0
        
        %pureApp_4685 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4297, i64 %longLiteral_4686)
        
        
        
        %tag_150 = extractvalue %Pos %pureApp_4685, 0
        %fields_151 = extractvalue %Pos %pureApp_4685, 1
        switch i64 %tag_150, label %label_152 [i64 0, label %label_163 i64 1, label %label_167]
    
    label_152:
        
        ret void
    
    label_163:
        
        %pureApp_4687 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4297)
        
        
        
        %longLiteral_4689 = add i64 1, 0
        
        %pureApp_4688 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4297, i64 %longLiteral_4689)
        
        
        
        %fields_153 = call ccc %Object @newObject(ptr @eraser_157, i64 32)
        %environment_154 = call ccc %Environment @objectEnvironment(%Object %fields_153)
        %tmp_4600_pointer_160 = getelementptr <{%Pos, %Pos}>, %Environment %environment_154, i64 0, i32 0
        store %Pos %pureApp_4687, ptr %tmp_4600_pointer_160, !noalias !2
        %acc_3_3_5_169_4161_pointer_161 = getelementptr <{%Pos, %Pos}>, %Environment %environment_154, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4161, ptr %acc_3_3_5_169_4161_pointer_161, !noalias !2
        %make_4690_temporary_162 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4690 = insertvalue %Pos %make_4690_temporary_162, %Object %fields_153, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4376(i64 %pureApp_4688, %Pos %make_4690, %Stack %stack)
        ret void
    
    label_167:
        
        %stackPointer_165 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_166 = getelementptr %FrameHeader, %StackPointer %stackPointer_165, i64 0, i32 0
        %returnAddress_164 = load %ReturnAddress, ptr %returnAddress_pointer_166, !noalias !2
        musttail call tailcc void %returnAddress_164(%Pos %acc_3_3_5_169_4161, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_178(%Pos %v_r_2597_32_59_223_4301, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_179 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %acc_8_35_199_4434_pointer_180 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_179, i64 0, i32 0
        %acc_8_35_199_4434 = load i64, ptr %acc_8_35_199_4434_pointer_180, !noalias !2
        %p_8_9_4126_pointer_181 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_179, i64 0, i32 1
        %p_8_9_4126 = load %Prompt, ptr %p_8_9_4126_pointer_181, !noalias !2
        %index_7_34_198_4242_pointer_182 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_179, i64 0, i32 2
        %index_7_34_198_4242 = load i64, ptr %index_7_34_198_4242_pointer_182, !noalias !2
        %tmp_4607_pointer_183 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_179, i64 0, i32 3
        %tmp_4607 = load i64, ptr %tmp_4607_pointer_183, !noalias !2
        %v_r_2514_30_194_4343_pointer_184 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_179, i64 0, i32 4
        %v_r_2514_30_194_4343 = load %Pos, ptr %v_r_2514_30_194_4343_pointer_184, !noalias !2
        
        %tag_185 = extractvalue %Pos %v_r_2597_32_59_223_4301, 0
        %fields_186 = extractvalue %Pos %v_r_2597_32_59_223_4301, 1
        switch i64 %tag_185, label %label_187 [i64 1, label %label_210 i64 0, label %label_217]
    
    label_187:
        
        ret void
    
    label_192:
        
        ret void
    
    label_198:
        call ccc void @erasePositive(%Pos %v_r_2514_30_194_4343)
        
        %pair_193 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4126)
        %k_13_14_4_4533 = extractvalue <{%Resumption, %Stack}> %pair_193, 0
        %stack_194 = extractvalue <{%Resumption, %Stack}> %pair_193, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4533)
        
        %longLiteral_4702 = add i64 5, 0
        
        
        
        %pureApp_4703 = call ccc %Pos @boxInt_301(i64 %longLiteral_4702)
        
        
        
        %stackPointer_196 = call ccc %StackPointer @stackDeallocate(%Stack %stack_194, i64 24)
        %returnAddress_pointer_197 = getelementptr %FrameHeader, %StackPointer %stackPointer_196, i64 0, i32 0
        %returnAddress_195 = load %ReturnAddress, ptr %returnAddress_pointer_197, !noalias !2
        musttail call tailcc void %returnAddress_195(%Pos %pureApp_4703, %Stack %stack_194)
        ret void
    
    label_201:
        
        ret void
    
    label_207:
        call ccc void @erasePositive(%Pos %v_r_2514_30_194_4343)
        
        %pair_202 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4126)
        %k_13_14_4_4532 = extractvalue <{%Resumption, %Stack}> %pair_202, 0
        %stack_203 = extractvalue <{%Resumption, %Stack}> %pair_202, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4532)
        
        %longLiteral_4706 = add i64 5, 0
        
        
        
        %pureApp_4707 = call ccc %Pos @boxInt_301(i64 %longLiteral_4706)
        
        
        
        %stackPointer_205 = call ccc %StackPointer @stackDeallocate(%Stack %stack_203, i64 24)
        %returnAddress_pointer_206 = getelementptr %FrameHeader, %StackPointer %stackPointer_205, i64 0, i32 0
        %returnAddress_204 = load %ReturnAddress, ptr %returnAddress_pointer_206, !noalias !2
        musttail call tailcc void %returnAddress_204(%Pos %pureApp_4707, %Stack %stack_203)
        ret void
    
    label_208:
        
        %longLiteral_4709 = add i64 1, 0
        
        %pureApp_4708 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4242, i64 %longLiteral_4709)
        
        
        
        %longLiteral_4711 = add i64 10, 0
        
        %pureApp_4710 = call ccc i64 @infixMul_99(i64 %longLiteral_4711, i64 %acc_8_35_199_4434)
        
        
        
        %pureApp_4712 = call ccc i64 @toInt_2085(i64 %pureApp_4699)
        
        
        
        %pureApp_4713 = call ccc i64 @infixSub_105(i64 %pureApp_4712, i64 %tmp_4607)
        
        
        
        %pureApp_4714 = call ccc i64 @infixAdd_96(i64 %pureApp_4710, i64 %pureApp_4713)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4260(i64 %pureApp_4708, i64 %pureApp_4714, %Prompt %p_8_9_4126, i64 %tmp_4607, %Pos %v_r_2514_30_194_4343, %Stack %stack)
        ret void
    
    label_209:
        
        %intLiteral_4705 = add i64 57, 0
        
        %pureApp_4704 = call ccc %Pos @infixLte_2093(i64 %pureApp_4699, i64 %intLiteral_4705)
        
        
        
        %tag_199 = extractvalue %Pos %pureApp_4704, 0
        %fields_200 = extractvalue %Pos %pureApp_4704, 1
        switch i64 %tag_199, label %label_201 [i64 0, label %label_207 i64 1, label %label_208]
    
    label_210:
        %environment_188 = call ccc %Environment @objectEnvironment(%Object %fields_186)
        %v_coe_3413_46_73_237_4189_pointer_189 = getelementptr <{%Pos}>, %Environment %environment_188, i64 0, i32 0
        %v_coe_3413_46_73_237_4189 = load %Pos, ptr %v_coe_3413_46_73_237_4189_pointer_189, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3413_46_73_237_4189)
        call ccc void @eraseObject(%Object %fields_186)
        
        %pureApp_4699 = call ccc i64 @unboxChar_313(%Pos %v_coe_3413_46_73_237_4189)
        
        
        
        %intLiteral_4701 = add i64 48, 0
        
        %pureApp_4700 = call ccc %Pos @infixGte_2099(i64 %pureApp_4699, i64 %intLiteral_4701)
        
        
        
        %tag_190 = extractvalue %Pos %pureApp_4700, 0
        %fields_191 = extractvalue %Pos %pureApp_4700, 1
        switch i64 %tag_190, label %label_192 [i64 0, label %label_198 i64 1, label %label_209]
    
    label_217:
        %environment_211 = call ccc %Environment @objectEnvironment(%Object %fields_186)
        %v_y_2604_76_103_267_4697_pointer_212 = getelementptr <{%Pos, %Pos}>, %Environment %environment_211, i64 0, i32 0
        %v_y_2604_76_103_267_4697 = load %Pos, ptr %v_y_2604_76_103_267_4697_pointer_212, !noalias !2
        %v_y_2605_77_104_268_4698_pointer_213 = getelementptr <{%Pos, %Pos}>, %Environment %environment_211, i64 0, i32 1
        %v_y_2605_77_104_268_4698 = load %Pos, ptr %v_y_2605_77_104_268_4698_pointer_213, !noalias !2
        call ccc void @eraseObject(%Object %fields_186)
        call ccc void @erasePositive(%Pos %v_r_2514_30_194_4343)
        
        %stackPointer_215 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_216 = getelementptr %FrameHeader, %StackPointer %stackPointer_215, i64 0, i32 0
        %returnAddress_214 = load %ReturnAddress, ptr %returnAddress_pointer_216, !noalias !2
        musttail call tailcc void %returnAddress_214(i64 %acc_8_35_199_4434, %Stack %stack)
        ret void
}



define ccc void @sharer_223(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_224 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %acc_8_35_199_4434_218_pointer_225 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_224, i64 0, i32 0
        %acc_8_35_199_4434_218 = load i64, ptr %acc_8_35_199_4434_218_pointer_225, !noalias !2
        %p_8_9_4126_219_pointer_226 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_224, i64 0, i32 1
        %p_8_9_4126_219 = load %Prompt, ptr %p_8_9_4126_219_pointer_226, !noalias !2
        %index_7_34_198_4242_220_pointer_227 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_224, i64 0, i32 2
        %index_7_34_198_4242_220 = load i64, ptr %index_7_34_198_4242_220_pointer_227, !noalias !2
        %tmp_4607_221_pointer_228 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_224, i64 0, i32 3
        %tmp_4607_221 = load i64, ptr %tmp_4607_221_pointer_228, !noalias !2
        %v_r_2514_30_194_4343_222_pointer_229 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_224, i64 0, i32 4
        %v_r_2514_30_194_4343_222 = load %Pos, ptr %v_r_2514_30_194_4343_222_pointer_229, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2514_30_194_4343_222)
        call ccc void @shareFrames(%StackPointer %stackPointer_224)
        ret void
}



define ccc void @eraser_235(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_236 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %acc_8_35_199_4434_230_pointer_237 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_236, i64 0, i32 0
        %acc_8_35_199_4434_230 = load i64, ptr %acc_8_35_199_4434_230_pointer_237, !noalias !2
        %p_8_9_4126_231_pointer_238 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_236, i64 0, i32 1
        %p_8_9_4126_231 = load %Prompt, ptr %p_8_9_4126_231_pointer_238, !noalias !2
        %index_7_34_198_4242_232_pointer_239 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_236, i64 0, i32 2
        %index_7_34_198_4242_232 = load i64, ptr %index_7_34_198_4242_232_pointer_239, !noalias !2
        %tmp_4607_233_pointer_240 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_236, i64 0, i32 3
        %tmp_4607_233 = load i64, ptr %tmp_4607_233_pointer_240, !noalias !2
        %v_r_2514_30_194_4343_234_pointer_241 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_236, i64 0, i32 4
        %v_r_2514_30_194_4343_234 = load %Pos, ptr %v_r_2514_30_194_4343_234_pointer_241, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2514_30_194_4343_234)
        call ccc void @eraseFrames(%StackPointer %stackPointer_236)
        ret void
}



define tailcc void @returnAddress_252(%Pos %returned_4715, %Stack %stack) {
        
    entry:
        
        %stack_253 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_255 = call ccc %StackPointer @stackDeallocate(%Stack %stack_253, i64 24)
        %returnAddress_pointer_256 = getelementptr %FrameHeader, %StackPointer %stackPointer_255, i64 0, i32 0
        %returnAddress_254 = load %ReturnAddress, ptr %returnAddress_pointer_256, !noalias !2
        musttail call tailcc void %returnAddress_254(%Pos %returned_4715, %Stack %stack_253)
        ret void
}



define tailcc void @Exception_7_19_46_210_4312_clause_261(%Object %closure, %Pos %exc_8_20_47_211_4284, %Pos %msg_9_21_48_212_4240, %Stack %stack) {
        
    entry:
        
        %environment_262 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4314_pointer_263 = getelementptr <{%Prompt}>, %Environment %environment_262, i64 0, i32 0
        %p_6_18_45_209_4314 = load %Prompt, ptr %p_6_18_45_209_4314_pointer_263, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_264 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4314)
        %k_11_23_50_214_4448 = extractvalue <{%Resumption, %Stack}> %pair_264, 0
        %stack_265 = extractvalue <{%Resumption, %Stack}> %pair_264, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4448)
        
        %fields_266 = call ccc %Object @newObject(ptr @eraser_157, i64 32)
        %environment_267 = call ccc %Environment @objectEnvironment(%Object %fields_266)
        %exc_8_20_47_211_4284_pointer_270 = getelementptr <{%Pos, %Pos}>, %Environment %environment_267, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4284, ptr %exc_8_20_47_211_4284_pointer_270, !noalias !2
        %msg_9_21_48_212_4240_pointer_271 = getelementptr <{%Pos, %Pos}>, %Environment %environment_267, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4240, ptr %msg_9_21_48_212_4240_pointer_271, !noalias !2
        %make_4716_temporary_272 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4716 = insertvalue %Pos %make_4716_temporary_272, %Object %fields_266, 1
        
        
        
        %stackPointer_274 = call ccc %StackPointer @stackDeallocate(%Stack %stack_265, i64 24)
        %returnAddress_pointer_275 = getelementptr %FrameHeader, %StackPointer %stackPointer_274, i64 0, i32 0
        %returnAddress_273 = load %ReturnAddress, ptr %returnAddress_pointer_275, !noalias !2
        musttail call tailcc void %returnAddress_273(%Pos %make_4716, %Stack %stack_265)
        ret void
}


@vtable_276 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4312_clause_261]


define ccc void @eraser_280(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4314_279_pointer_281 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4314_279 = load %Prompt, ptr %p_6_18_45_209_4314_279_pointer_281, !noalias !2
        ret void
}



define ccc void @eraser_288(%Environment %environment) {
        
    entry:
        
        %tmp_4609_287_pointer_289 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4609_287 = load %Pos, ptr %tmp_4609_287_pointer_289, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4609_287)
        ret void
}



define tailcc void @returnAddress_284(i64 %v_coe_3412_6_28_55_219_4278, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4717 = call ccc %Pos @boxChar_311(i64 %v_coe_3412_6_28_55_219_4278)
        
        
        
        %fields_285 = call ccc %Object @newObject(ptr @eraser_288, i64 16)
        %environment_286 = call ccc %Environment @objectEnvironment(%Object %fields_285)
        %tmp_4609_pointer_290 = getelementptr <{%Pos}>, %Environment %environment_286, i64 0, i32 0
        store %Pos %pureApp_4717, ptr %tmp_4609_pointer_290, !noalias !2
        %make_4718_temporary_291 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4718 = insertvalue %Pos %make_4718_temporary_291, %Object %fields_285, 1
        
        
        
        %stackPointer_293 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_294 = getelementptr %FrameHeader, %StackPointer %stackPointer_293, i64 0, i32 0
        %returnAddress_292 = load %ReturnAddress, ptr %returnAddress_pointer_294, !noalias !2
        musttail call tailcc void %returnAddress_292(%Pos %make_4718, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4260(i64 %index_7_34_198_4242, i64 %acc_8_35_199_4434, %Prompt %p_8_9_4126, i64 %tmp_4607, %Pos %v_r_2514_30_194_4343, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2514_30_194_4343)
        %stackPointer_242 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %acc_8_35_199_4434_pointer_243 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_242, i64 0, i32 0
        store i64 %acc_8_35_199_4434, ptr %acc_8_35_199_4434_pointer_243, !noalias !2
        %p_8_9_4126_pointer_244 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_242, i64 0, i32 1
        store %Prompt %p_8_9_4126, ptr %p_8_9_4126_pointer_244, !noalias !2
        %index_7_34_198_4242_pointer_245 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_242, i64 0, i32 2
        store i64 %index_7_34_198_4242, ptr %index_7_34_198_4242_pointer_245, !noalias !2
        %tmp_4607_pointer_246 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_242, i64 0, i32 3
        store i64 %tmp_4607, ptr %tmp_4607_pointer_246, !noalias !2
        %v_r_2514_30_194_4343_pointer_247 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_242, i64 0, i32 4
        store %Pos %v_r_2514_30_194_4343, ptr %v_r_2514_30_194_4343_pointer_247, !noalias !2
        %returnAddress_pointer_248 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_242, i64 0, i32 1, i32 0
        %sharer_pointer_249 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_242, i64 0, i32 1, i32 1
        %eraser_pointer_250 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_242, i64 0, i32 1, i32 2
        store ptr @returnAddress_178, ptr %returnAddress_pointer_248, !noalias !2
        store ptr @sharer_223, ptr %sharer_pointer_249, !noalias !2
        store ptr @eraser_235, ptr %eraser_pointer_250, !noalias !2
        
        %stack_251 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4314 = call ccc %Prompt @currentPrompt(%Stack %stack_251)
        %stackPointer_257 = call ccc %StackPointer @stackAllocate(%Stack %stack_251, i64 24)
        %returnAddress_pointer_258 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_257, i64 0, i32 1, i32 0
        %sharer_pointer_259 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_257, i64 0, i32 1, i32 1
        %eraser_pointer_260 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_257, i64 0, i32 1, i32 2
        store ptr @returnAddress_252, ptr %returnAddress_pointer_258, !noalias !2
        store ptr @sharer_33, ptr %sharer_pointer_259, !noalias !2
        store ptr @eraser_35, ptr %eraser_pointer_260, !noalias !2
        
        %closure_277 = call ccc %Object @newObject(ptr @eraser_280, i64 8)
        %environment_278 = call ccc %Environment @objectEnvironment(%Object %closure_277)
        %p_6_18_45_209_4314_pointer_282 = getelementptr <{%Prompt}>, %Environment %environment_278, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4314, ptr %p_6_18_45_209_4314_pointer_282, !noalias !2
        %vtable_temporary_283 = insertvalue %Neg zeroinitializer, ptr @vtable_276, 0
        %Exception_7_19_46_210_4312 = insertvalue %Neg %vtable_temporary_283, %Object %closure_277, 1
        %stackPointer_295 = call ccc %StackPointer @stackAllocate(%Stack %stack_251, i64 24)
        %returnAddress_pointer_296 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_295, i64 0, i32 1, i32 0
        %sharer_pointer_297 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_295, i64 0, i32 1, i32 1
        %eraser_pointer_298 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_295, i64 0, i32 1, i32 2
        store ptr @returnAddress_284, ptr %returnAddress_pointer_296, !noalias !2
        store ptr @sharer_81, ptr %sharer_pointer_297, !noalias !2
        store ptr @eraser_83, ptr %eraser_pointer_298, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2514_30_194_4343, i64 %index_7_34_198_4242, %Neg %Exception_7_19_46_210_4312, %Stack %stack_251)
        ret void
}



define tailcc void @Exception_9_106_133_297_4430_clause_299(%Object %closure, %Pos %exception_10_107_134_298_4719, %Pos %msg_11_108_135_299_4720, %Stack %stack) {
        
    entry:
        
        %environment_300 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4126_pointer_301 = getelementptr <{%Prompt}>, %Environment %environment_300, i64 0, i32 0
        %p_8_9_4126 = load %Prompt, ptr %p_8_9_4126_pointer_301, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4719)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4720)
        
        %pair_302 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4126)
        %k_13_14_4_4590 = extractvalue <{%Resumption, %Stack}> %pair_302, 0
        %stack_303 = extractvalue <{%Resumption, %Stack}> %pair_302, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4590)
        
        %longLiteral_4721 = add i64 5, 0
        
        
        
        %pureApp_4722 = call ccc %Pos @boxInt_301(i64 %longLiteral_4721)
        
        
        
        %stackPointer_305 = call ccc %StackPointer @stackDeallocate(%Stack %stack_303, i64 24)
        %returnAddress_pointer_306 = getelementptr %FrameHeader, %StackPointer %stackPointer_305, i64 0, i32 0
        %returnAddress_304 = load %ReturnAddress, ptr %returnAddress_pointer_306, !noalias !2
        musttail call tailcc void %returnAddress_304(%Pos %pureApp_4722, %Stack %stack_303)
        ret void
}


@vtable_307 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4430_clause_299]


define tailcc void @returnAddress_318(i64 %v_coe_3417_22_131_158_322_4324, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4725 = call ccc %Pos @boxInt_301(i64 %v_coe_3417_22_131_158_322_4324)
        
        
        
        
        
        %pureApp_4726 = call ccc i64 @unboxInt_303(%Pos %pureApp_4725)
        
        
        
        %pureApp_4727 = call ccc %Pos @boxInt_301(i64 %pureApp_4726)
        
        
        
        %stackPointer_320 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_321 = getelementptr %FrameHeader, %StackPointer %stackPointer_320, i64 0, i32 0
        %returnAddress_319 = load %ReturnAddress, ptr %returnAddress_pointer_321, !noalias !2
        musttail call tailcc void %returnAddress_319(%Pos %pureApp_4727, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_330(i64 %v_r_2611_1_9_20_129_156_320_4421, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4731 = add i64 0, 0
        
        %pureApp_4730 = call ccc i64 @infixSub_105(i64 %longLiteral_4731, i64 %v_r_2611_1_9_20_129_156_320_4421)
        
        
        
        %stackPointer_332 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_333 = getelementptr %FrameHeader, %StackPointer %stackPointer_332, i64 0, i32 0
        %returnAddress_331 = load %ReturnAddress, ptr %returnAddress_pointer_333, !noalias !2
        musttail call tailcc void %returnAddress_331(i64 %pureApp_4730, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_313(i64 %v_r_2610_3_14_123_150_314_4367, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_314 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_4126_pointer_315 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_314, i64 0, i32 0
        %p_8_9_4126 = load %Prompt, ptr %p_8_9_4126_pointer_315, !noalias !2
        %tmp_4607_pointer_316 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_314, i64 0, i32 1
        %tmp_4607 = load i64, ptr %tmp_4607_pointer_316, !noalias !2
        %v_r_2514_30_194_4343_pointer_317 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_314, i64 0, i32 2
        %v_r_2514_30_194_4343 = load %Pos, ptr %v_r_2514_30_194_4343_pointer_317, !noalias !2
        
        %intLiteral_4724 = add i64 45, 0
        
        %pureApp_4723 = call ccc %Pos @infixEq_78(i64 %v_r_2610_3_14_123_150_314_4367, i64 %intLiteral_4724)
        
        
        %stackPointer_322 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_323 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_322, i64 0, i32 1, i32 0
        %sharer_pointer_324 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_322, i64 0, i32 1, i32 1
        %eraser_pointer_325 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_322, i64 0, i32 1, i32 2
        store ptr @returnAddress_318, ptr %returnAddress_pointer_323, !noalias !2
        store ptr @sharer_81, ptr %sharer_pointer_324, !noalias !2
        store ptr @eraser_83, ptr %eraser_pointer_325, !noalias !2
        
        %tag_326 = extractvalue %Pos %pureApp_4723, 0
        %fields_327 = extractvalue %Pos %pureApp_4723, 1
        switch i64 %tag_326, label %label_328 [i64 0, label %label_329 i64 1, label %label_338]
    
    label_328:
        
        ret void
    
    label_329:
        
        %longLiteral_4728 = add i64 0, 0
        
        %longLiteral_4729 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4260(i64 %longLiteral_4728, i64 %longLiteral_4729, %Prompt %p_8_9_4126, i64 %tmp_4607, %Pos %v_r_2514_30_194_4343, %Stack %stack)
        ret void
    
    label_338:
        %stackPointer_334 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_335 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_334, i64 0, i32 1, i32 0
        %sharer_pointer_336 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_334, i64 0, i32 1, i32 1
        %eraser_pointer_337 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_334, i64 0, i32 1, i32 2
        store ptr @returnAddress_330, ptr %returnAddress_pointer_335, !noalias !2
        store ptr @sharer_81, ptr %sharer_pointer_336, !noalias !2
        store ptr @eraser_83, ptr %eraser_pointer_337, !noalias !2
        
        %longLiteral_4732 = add i64 1, 0
        
        %longLiteral_4733 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4260(i64 %longLiteral_4732, i64 %longLiteral_4733, %Prompt %p_8_9_4126, i64 %tmp_4607, %Pos %v_r_2514_30_194_4343, %Stack %stack)
        ret void
}



define ccc void @sharer_342(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_343 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4126_339_pointer_344 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_343, i64 0, i32 0
        %p_8_9_4126_339 = load %Prompt, ptr %p_8_9_4126_339_pointer_344, !noalias !2
        %tmp_4607_340_pointer_345 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_343, i64 0, i32 1
        %tmp_4607_340 = load i64, ptr %tmp_4607_340_pointer_345, !noalias !2
        %v_r_2514_30_194_4343_341_pointer_346 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_343, i64 0, i32 2
        %v_r_2514_30_194_4343_341 = load %Pos, ptr %v_r_2514_30_194_4343_341_pointer_346, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2514_30_194_4343_341)
        call ccc void @shareFrames(%StackPointer %stackPointer_343)
        ret void
}



define ccc void @eraser_350(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_351 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4126_347_pointer_352 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_351, i64 0, i32 0
        %p_8_9_4126_347 = load %Prompt, ptr %p_8_9_4126_347_pointer_352, !noalias !2
        %tmp_4607_348_pointer_353 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_351, i64 0, i32 1
        %tmp_4607_348 = load i64, ptr %tmp_4607_348_pointer_353, !noalias !2
        %v_r_2514_30_194_4343_349_pointer_354 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_351, i64 0, i32 2
        %v_r_2514_30_194_4343_349 = load %Pos, ptr %v_r_2514_30_194_4343_349_pointer_354, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2514_30_194_4343_349)
        call ccc void @eraseFrames(%StackPointer %stackPointer_351)
        ret void
}



define tailcc void @returnAddress_175(%Pos %v_r_2514_30_194_4343, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_176 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4126_pointer_177 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_176, i64 0, i32 0
        %p_8_9_4126 = load %Prompt, ptr %p_8_9_4126_pointer_177, !noalias !2
        
        %intLiteral_4696 = add i64 48, 0
        
        %pureApp_4695 = call ccc i64 @toInt_2085(i64 %intLiteral_4696)
        
        
        
        %closure_308 = call ccc %Object @newObject(ptr @eraser_280, i64 8)
        %environment_309 = call ccc %Environment @objectEnvironment(%Object %closure_308)
        %p_8_9_4126_pointer_311 = getelementptr <{%Prompt}>, %Environment %environment_309, i64 0, i32 0
        store %Prompt %p_8_9_4126, ptr %p_8_9_4126_pointer_311, !noalias !2
        %vtable_temporary_312 = insertvalue %Neg zeroinitializer, ptr @vtable_307, 0
        %Exception_9_106_133_297_4430 = insertvalue %Neg %vtable_temporary_312, %Object %closure_308, 1
        call ccc void @sharePositive(%Pos %v_r_2514_30_194_4343)
        %stackPointer_355 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_4126_pointer_356 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_355, i64 0, i32 0
        store %Prompt %p_8_9_4126, ptr %p_8_9_4126_pointer_356, !noalias !2
        %tmp_4607_pointer_357 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_355, i64 0, i32 1
        store i64 %pureApp_4695, ptr %tmp_4607_pointer_357, !noalias !2
        %v_r_2514_30_194_4343_pointer_358 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_355, i64 0, i32 2
        store %Pos %v_r_2514_30_194_4343, ptr %v_r_2514_30_194_4343_pointer_358, !noalias !2
        %returnAddress_pointer_359 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 0
        %sharer_pointer_360 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 1
        %eraser_pointer_361 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 2
        store ptr @returnAddress_313, ptr %returnAddress_pointer_359, !noalias !2
        store ptr @sharer_342, ptr %sharer_pointer_360, !noalias !2
        store ptr @eraser_350, ptr %eraser_pointer_361, !noalias !2
        
        %longLiteral_4734 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2514_30_194_4343, i64 %longLiteral_4734, %Neg %Exception_9_106_133_297_4430, %Stack %stack)
        ret void
}



define ccc void @sharer_363(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_364 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4126_362_pointer_365 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_364, i64 0, i32 0
        %p_8_9_4126_362 = load %Prompt, ptr %p_8_9_4126_362_pointer_365, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_364)
        ret void
}



define ccc void @eraser_367(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_368 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4126_366_pointer_369 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_368, i64 0, i32 0
        %p_8_9_4126_366 = load %Prompt, ptr %p_8_9_4126_366_pointer_369, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_368)
        ret void
}


@utf8StringLiteral_4735.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_172(%Pos %v_r_2513_24_188_4320, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_173 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4126_pointer_174 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_173, i64 0, i32 0
        %p_8_9_4126 = load %Prompt, ptr %p_8_9_4126_pointer_174, !noalias !2
        %stackPointer_370 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4126_pointer_371 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_370, i64 0, i32 0
        store %Prompt %p_8_9_4126, ptr %p_8_9_4126_pointer_371, !noalias !2
        %returnAddress_pointer_372 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_370, i64 0, i32 1, i32 0
        %sharer_pointer_373 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_370, i64 0, i32 1, i32 1
        %eraser_pointer_374 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_370, i64 0, i32 1, i32 2
        store ptr @returnAddress_175, ptr %returnAddress_pointer_372, !noalias !2
        store ptr @sharer_363, ptr %sharer_pointer_373, !noalias !2
        store ptr @eraser_367, ptr %eraser_pointer_374, !noalias !2
        
        %tag_375 = extractvalue %Pos %v_r_2513_24_188_4320, 0
        %fields_376 = extractvalue %Pos %v_r_2513_24_188_4320, 1
        switch i64 %tag_375, label %label_377 [i64 0, label %label_381 i64 1, label %label_387]
    
    label_377:
        
        ret void
    
    label_381:
        
        %utf8StringLiteral_4735 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4735.lit)
        
        %stackPointer_379 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_380 = getelementptr %FrameHeader, %StackPointer %stackPointer_379, i64 0, i32 0
        %returnAddress_378 = load %ReturnAddress, ptr %returnAddress_pointer_380, !noalias !2
        musttail call tailcc void %returnAddress_378(%Pos %utf8StringLiteral_4735, %Stack %stack)
        ret void
    
    label_387:
        %environment_382 = call ccc %Environment @objectEnvironment(%Object %fields_376)
        %v_y_3239_8_29_193_4355_pointer_383 = getelementptr <{%Pos}>, %Environment %environment_382, i64 0, i32 0
        %v_y_3239_8_29_193_4355 = load %Pos, ptr %v_y_3239_8_29_193_4355_pointer_383, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3239_8_29_193_4355)
        call ccc void @eraseObject(%Object %fields_376)
        
        %stackPointer_385 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_386 = getelementptr %FrameHeader, %StackPointer %stackPointer_385, i64 0, i32 0
        %returnAddress_384 = load %ReturnAddress, ptr %returnAddress_pointer_386, !noalias !2
        musttail call tailcc void %returnAddress_384(%Pos %v_y_3239_8_29_193_4355, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_169(%Pos %v_r_2512_13_177_4372, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_170 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4126_pointer_171 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_170, i64 0, i32 0
        %p_8_9_4126 = load %Prompt, ptr %p_8_9_4126_pointer_171, !noalias !2
        %stackPointer_390 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4126_pointer_391 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_390, i64 0, i32 0
        store %Prompt %p_8_9_4126, ptr %p_8_9_4126_pointer_391, !noalias !2
        %returnAddress_pointer_392 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 0
        %sharer_pointer_393 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 1
        %eraser_pointer_394 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 2
        store ptr @returnAddress_172, ptr %returnAddress_pointer_392, !noalias !2
        store ptr @sharer_363, ptr %sharer_pointer_393, !noalias !2
        store ptr @eraser_367, ptr %eraser_pointer_394, !noalias !2
        
        %tag_395 = extractvalue %Pos %v_r_2512_13_177_4372, 0
        %fields_396 = extractvalue %Pos %v_r_2512_13_177_4372, 1
        switch i64 %tag_395, label %label_397 [i64 0, label %label_402 i64 1, label %label_414]
    
    label_397:
        
        ret void
    
    label_402:
        
        %make_4736_temporary_398 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4736 = insertvalue %Pos %make_4736_temporary_398, %Object null, 1
        
        
        
        %stackPointer_400 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_401 = getelementptr %FrameHeader, %StackPointer %stackPointer_400, i64 0, i32 0
        %returnAddress_399 = load %ReturnAddress, ptr %returnAddress_pointer_401, !noalias !2
        musttail call tailcc void %returnAddress_399(%Pos %make_4736, %Stack %stack)
        ret void
    
    label_414:
        %environment_403 = call ccc %Environment @objectEnvironment(%Object %fields_396)
        %v_y_2748_10_21_185_4215_pointer_404 = getelementptr <{%Pos, %Pos}>, %Environment %environment_403, i64 0, i32 0
        %v_y_2748_10_21_185_4215 = load %Pos, ptr %v_y_2748_10_21_185_4215_pointer_404, !noalias !2
        %v_y_2749_11_22_186_4397_pointer_405 = getelementptr <{%Pos, %Pos}>, %Environment %environment_403, i64 0, i32 1
        %v_y_2749_11_22_186_4397 = load %Pos, ptr %v_y_2749_11_22_186_4397_pointer_405, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2748_10_21_185_4215)
        call ccc void @eraseObject(%Object %fields_396)
        
        %fields_406 = call ccc %Object @newObject(ptr @eraser_288, i64 16)
        %environment_407 = call ccc %Environment @objectEnvironment(%Object %fields_406)
        %v_y_2748_10_21_185_4215_pointer_409 = getelementptr <{%Pos}>, %Environment %environment_407, i64 0, i32 0
        store %Pos %v_y_2748_10_21_185_4215, ptr %v_y_2748_10_21_185_4215_pointer_409, !noalias !2
        %make_4737_temporary_410 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4737 = insertvalue %Pos %make_4737_temporary_410, %Object %fields_406, 1
        
        
        
        %stackPointer_412 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_413 = getelementptr %FrameHeader, %StackPointer %stackPointer_412, i64 0, i32 0
        %returnAddress_411 = load %ReturnAddress, ptr %returnAddress_pointer_413, !noalias !2
        musttail call tailcc void %returnAddress_411(%Pos %make_4737, %Stack %stack)
        ret void
}



define tailcc void @main_2443(%Stack %stack) {
        
    entry:
        
        %stackPointer_136 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_137 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 0
        %sharer_pointer_138 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 1
        %eraser_pointer_139 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_137, !noalias !2
        store ptr @sharer_81, ptr %sharer_pointer_138, !noalias !2
        store ptr @eraser_83, ptr %eraser_pointer_139, !noalias !2
        
        %stack_140 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4126 = call ccc %Prompt @currentPrompt(%Stack %stack_140)
        %stackPointer_146 = call ccc %StackPointer @stackAllocate(%Stack %stack_140, i64 24)
        %returnAddress_pointer_147 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 0
        %sharer_pointer_148 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 1
        %eraser_pointer_149 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 2
        store ptr @returnAddress_141, ptr %returnAddress_pointer_147, !noalias !2
        store ptr @sharer_33, ptr %sharer_pointer_148, !noalias !2
        store ptr @eraser_35, ptr %eraser_pointer_149, !noalias !2
        
        %pureApp_4691 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4693 = add i64 1, 0
        
        %pureApp_4692 = call ccc i64 @infixSub_105(i64 %pureApp_4691, i64 %longLiteral_4693)
        
        
        
        %make_4694_temporary_168 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4694 = insertvalue %Pos %make_4694_temporary_168, %Object null, 1
        
        
        %stackPointer_417 = call ccc %StackPointer @stackAllocate(%Stack %stack_140, i64 32)
        %p_8_9_4126_pointer_418 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_417, i64 0, i32 0
        store %Prompt %p_8_9_4126, ptr %p_8_9_4126_pointer_418, !noalias !2
        %returnAddress_pointer_419 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_417, i64 0, i32 1, i32 0
        %sharer_pointer_420 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_417, i64 0, i32 1, i32 1
        %eraser_pointer_421 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_417, i64 0, i32 1, i32 2
        store ptr @returnAddress_169, ptr %returnAddress_pointer_419, !noalias !2
        store ptr @sharer_363, ptr %sharer_pointer_420, !noalias !2
        store ptr @eraser_367, ptr %eraser_pointer_421, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4376(i64 %pureApp_4692, %Pos %make_4694, %Stack %stack_140)
        ret void
}


@utf8StringLiteral_4649.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4651.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4654.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_422(%Pos %v_r_2679_3469, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_423 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_424 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_423, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_424, !noalias !2
        %index_2107_pointer_425 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_423, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_425, !noalias !2
        %Exception_2362_pointer_426 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_423, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_426, !noalias !2
        
        %tag_427 = extractvalue %Pos %v_r_2679_3469, 0
        %fields_428 = extractvalue %Pos %v_r_2679_3469, 1
        switch i64 %tag_427, label %label_429 [i64 0, label %label_433 i64 1, label %label_439]
    
    label_429:
        
        ret void
    
    label_433:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4645 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_431 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_432 = getelementptr %FrameHeader, %StackPointer %stackPointer_431, i64 0, i32 0
        %returnAddress_430 = load %ReturnAddress, ptr %returnAddress_pointer_432, !noalias !2
        musttail call tailcc void %returnAddress_430(i64 %pureApp_4645, %Stack %stack)
        ret void
    
    label_439:
        
        %make_4646_temporary_434 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4646 = insertvalue %Pos %make_4646_temporary_434, %Object null, 1
        
        
        
        %pureApp_4647 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4649 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4649.lit)
        
        %pureApp_4648 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4649, %Pos %pureApp_4647)
        
        
        
        %utf8StringLiteral_4651 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4651.lit)
        
        %pureApp_4650 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4648, %Pos %utf8StringLiteral_4651)
        
        
        
        %pureApp_4652 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4650, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4654 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4654.lit)
        
        %pureApp_4653 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4652, %Pos %utf8StringLiteral_4654)
        
        
        
        %vtable_435 = extractvalue %Neg %Exception_2362, 0
        %closure_436 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_437 = getelementptr ptr, ptr %vtable_435, i64 0
        %functionPointer_438 = load ptr, ptr %functionPointer_pointer_437, !noalias !2
        musttail call tailcc void %functionPointer_438(%Object %closure_436, %Pos %make_4646, %Pos %pureApp_4653, %Stack %stack)
        ret void
}



define ccc void @sharer_443(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_444 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_440_pointer_445 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_444, i64 0, i32 0
        %str_2106_440 = load %Pos, ptr %str_2106_440_pointer_445, !noalias !2
        %index_2107_441_pointer_446 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_444, i64 0, i32 1
        %index_2107_441 = load i64, ptr %index_2107_441_pointer_446, !noalias !2
        %Exception_2362_442_pointer_447 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_444, i64 0, i32 2
        %Exception_2362_442 = load %Neg, ptr %Exception_2362_442_pointer_447, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_440)
        call ccc void @shareNegative(%Neg %Exception_2362_442)
        call ccc void @shareFrames(%StackPointer %stackPointer_444)
        ret void
}



define ccc void @eraser_451(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_452 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_448_pointer_453 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_452, i64 0, i32 0
        %str_2106_448 = load %Pos, ptr %str_2106_448_pointer_453, !noalias !2
        %index_2107_449_pointer_454 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_452, i64 0, i32 1
        %index_2107_449 = load i64, ptr %index_2107_449_pointer_454, !noalias !2
        %Exception_2362_450_pointer_455 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_452, i64 0, i32 2
        %Exception_2362_450 = load %Neg, ptr %Exception_2362_450_pointer_455, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_448)
        call ccc void @eraseNegative(%Neg %Exception_2362_450)
        call ccc void @eraseFrames(%StackPointer %stackPointer_452)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4644 = add i64 0, 0
        
        %pureApp_4643 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4644)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_456 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_457 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_456, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_457, !noalias !2
        %index_2107_pointer_458 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_456, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_458, !noalias !2
        %Exception_2362_pointer_459 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_456, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_459, !noalias !2
        %returnAddress_pointer_460 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_456, i64 0, i32 1, i32 0
        %sharer_pointer_461 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_456, i64 0, i32 1, i32 1
        %eraser_pointer_462 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_456, i64 0, i32 1, i32 2
        store ptr @returnAddress_422, ptr %returnAddress_pointer_460, !noalias !2
        store ptr @sharer_443, ptr %sharer_pointer_461, !noalias !2
        store ptr @eraser_451, ptr %eraser_pointer_462, !noalias !2
        
        %tag_463 = extractvalue %Pos %pureApp_4643, 0
        %fields_464 = extractvalue %Pos %pureApp_4643, 1
        switch i64 %tag_463, label %label_465 [i64 0, label %label_469 i64 1, label %label_474]
    
    label_465:
        
        ret void
    
    label_469:
        
        %pureApp_4655 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4656 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4655)
        
        
        
        %stackPointer_467 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_468 = getelementptr %FrameHeader, %StackPointer %stackPointer_467, i64 0, i32 0
        %returnAddress_466 = load %ReturnAddress, ptr %returnAddress_pointer_468, !noalias !2
        musttail call tailcc void %returnAddress_466(%Pos %pureApp_4656, %Stack %stack)
        ret void
    
    label_474:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4657_temporary_470 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4657 = insertvalue %Pos %booleanLiteral_4657_temporary_470, %Object null, 1
        
        %stackPointer_472 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_473 = getelementptr %FrameHeader, %StackPointer %stackPointer_472, i64 0, i32 0
        %returnAddress_471 = load %ReturnAddress, ptr %returnAddress_pointer_473, !noalias !2
        musttail call tailcc void %returnAddress_471(%Pos %booleanLiteral_4657, %Stack %stack)
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
