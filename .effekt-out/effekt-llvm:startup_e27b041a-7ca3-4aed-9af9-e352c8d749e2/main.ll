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



define tailcc void @returnAddress_1(%Pos %v_coe_3391_3455, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %v_coe_3391_3455)
        
        %longLiteral_4459 = add i64 0, 0
        
        
        
        %pureApp_4460 = call ccc %Pos @show_14(i64 %longLiteral_4459)
        
        
        
        %pureApp_4461 = call ccc %Pos @println_1(%Pos %pureApp_4460)
        
        
        
        %stackPointer_3 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_4 = getelementptr %FrameHeader, %StackPointer %stackPointer_3, i64 0, i32 0
        %returnAddress_2 = load %ReturnAddress, ptr %returnAddress_pointer_4, !noalias !2
        musttail call tailcc void %returnAddress_2(%Pos %pureApp_4461, %Stack %stack)
        ret void
}



define ccc void @sharer_5(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_6 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_6)
        ret void
}



define ccc void @eraser_7(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_8 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_8)
        ret void
}



define tailcc void @returnAddress_14(%Pos %returned_4462, %Stack %stack) {
        
    entry:
        
        %stack_15 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_17 = call ccc %StackPointer @stackDeallocate(%Stack %stack_15, i64 24)
        %returnAddress_pointer_18 = getelementptr %FrameHeader, %StackPointer %stackPointer_17, i64 0, i32 0
        %returnAddress_16 = load %ReturnAddress, ptr %returnAddress_pointer_18, !noalias !2
        musttail call tailcc void %returnAddress_16(%Pos %returned_4462, %Stack %stack_15)
        ret void
}



define ccc void @sharer_19(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_20 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_21(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_22 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_22)
        ret void
}



define ccc void @eraser_34(%Environment %environment) {
        
    entry:
        
        %tmp_4412_32_pointer_35 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4412_32 = load %Pos, ptr %tmp_4412_32_pointer_35, !noalias !2
        %acc_3_3_5_169_4278_33_pointer_36 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4278_33 = load %Pos, ptr %acc_3_3_5_169_4278_33_pointer_36, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4412_32)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4278_33)
        ret void
}



define tailcc void @toList_1_1_3_167_4088(i64 %start_2_2_4_168_4096, %Pos %acc_3_3_5_169_4278, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4464 = add i64 1, 0
        
        %pureApp_4463 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4096, i64 %longLiteral_4464)
        
        
        
        %tag_27 = extractvalue %Pos %pureApp_4463, 0
        %fields_28 = extractvalue %Pos %pureApp_4463, 1
        switch i64 %tag_27, label %label_29 [i64 0, label %label_40 i64 1, label %label_44]
    
    label_29:
        
        ret void
    
    label_40:
        
        %pureApp_4465 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4096)
        
        
        
        %longLiteral_4467 = add i64 1, 0
        
        %pureApp_4466 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4096, i64 %longLiteral_4467)
        
        
        
        %fields_30 = call ccc %Object @newObject(ptr @eraser_34, i64 32)
        %environment_31 = call ccc %Environment @objectEnvironment(%Object %fields_30)
        %tmp_4412_pointer_37 = getelementptr <{%Pos, %Pos}>, %Environment %environment_31, i64 0, i32 0
        store %Pos %pureApp_4465, ptr %tmp_4412_pointer_37, !noalias !2
        %acc_3_3_5_169_4278_pointer_38 = getelementptr <{%Pos, %Pos}>, %Environment %environment_31, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4278, ptr %acc_3_3_5_169_4278_pointer_38, !noalias !2
        %make_4468_temporary_39 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4468 = insertvalue %Pos %make_4468_temporary_39, %Object %fields_30, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4088(i64 %pureApp_4466, %Pos %make_4468, %Stack %stack)
        ret void
    
    label_44:
        
        %stackPointer_42 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_43 = getelementptr %FrameHeader, %StackPointer %stackPointer_42, i64 0, i32 0
        %returnAddress_41 = load %ReturnAddress, ptr %returnAddress_pointer_43, !noalias !2
        musttail call tailcc void %returnAddress_41(%Pos %acc_3_3_5_169_4278, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_55(%Pos %v_r_2548_32_59_223_4259, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_56 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %acc_8_35_199_4210_pointer_57 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_56, i64 0, i32 0
        %acc_8_35_199_4210 = load i64, ptr %acc_8_35_199_4210_pointer_57, !noalias !2
        %tmp_4419_pointer_58 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_56, i64 0, i32 1
        %tmp_4419 = load i64, ptr %tmp_4419_pointer_58, !noalias !2
        %v_r_2464_30_194_4172_pointer_59 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_56, i64 0, i32 2
        %v_r_2464_30_194_4172 = load %Pos, ptr %v_r_2464_30_194_4172_pointer_59, !noalias !2
        %p_8_9_3988_pointer_60 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_56, i64 0, i32 3
        %p_8_9_3988 = load %Prompt, ptr %p_8_9_3988_pointer_60, !noalias !2
        %index_7_34_198_4062_pointer_61 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_56, i64 0, i32 4
        %index_7_34_198_4062 = load i64, ptr %index_7_34_198_4062_pointer_61, !noalias !2
        
        %tag_62 = extractvalue %Pos %v_r_2548_32_59_223_4259, 0
        %fields_63 = extractvalue %Pos %v_r_2548_32_59_223_4259, 1
        switch i64 %tag_62, label %label_64 [i64 1, label %label_87 i64 0, label %label_94]
    
    label_64:
        
        ret void
    
    label_69:
        
        ret void
    
    label_75:
        call ccc void @erasePositive(%Pos %v_r_2464_30_194_4172)
        
        %pair_70 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_3988)
        %k_13_14_4_4357 = extractvalue <{%Resumption, %Stack}> %pair_70, 0
        %stack_71 = extractvalue <{%Resumption, %Stack}> %pair_70, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4357)
        
        %longLiteral_4480 = add i64 5, 0
        
        
        
        %pureApp_4481 = call ccc %Pos @boxInt_301(i64 %longLiteral_4480)
        
        
        
        %stackPointer_73 = call ccc %StackPointer @stackDeallocate(%Stack %stack_71, i64 24)
        %returnAddress_pointer_74 = getelementptr %FrameHeader, %StackPointer %stackPointer_73, i64 0, i32 0
        %returnAddress_72 = load %ReturnAddress, ptr %returnAddress_pointer_74, !noalias !2
        musttail call tailcc void %returnAddress_72(%Pos %pureApp_4481, %Stack %stack_71)
        ret void
    
    label_78:
        
        ret void
    
    label_84:
        call ccc void @erasePositive(%Pos %v_r_2464_30_194_4172)
        
        %pair_79 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_3988)
        %k_13_14_4_4356 = extractvalue <{%Resumption, %Stack}> %pair_79, 0
        %stack_80 = extractvalue <{%Resumption, %Stack}> %pair_79, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4356)
        
        %longLiteral_4484 = add i64 5, 0
        
        
        
        %pureApp_4485 = call ccc %Pos @boxInt_301(i64 %longLiteral_4484)
        
        
        
        %stackPointer_82 = call ccc %StackPointer @stackDeallocate(%Stack %stack_80, i64 24)
        %returnAddress_pointer_83 = getelementptr %FrameHeader, %StackPointer %stackPointer_82, i64 0, i32 0
        %returnAddress_81 = load %ReturnAddress, ptr %returnAddress_pointer_83, !noalias !2
        musttail call tailcc void %returnAddress_81(%Pos %pureApp_4485, %Stack %stack_80)
        ret void
    
    label_85:
        
        %longLiteral_4487 = add i64 1, 0
        
        %pureApp_4486 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4062, i64 %longLiteral_4487)
        
        
        
        %longLiteral_4489 = add i64 10, 0
        
        %pureApp_4488 = call ccc i64 @infixMul_99(i64 %longLiteral_4489, i64 %acc_8_35_199_4210)
        
        
        
        %pureApp_4490 = call ccc i64 @toInt_2085(i64 %pureApp_4477)
        
        
        
        %pureApp_4491 = call ccc i64 @infixSub_105(i64 %pureApp_4490, i64 %tmp_4419)
        
        
        
        %pureApp_4492 = call ccc i64 @infixAdd_96(i64 %pureApp_4488, i64 %pureApp_4491)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4123(i64 %pureApp_4486, i64 %pureApp_4492, i64 %tmp_4419, %Pos %v_r_2464_30_194_4172, %Prompt %p_8_9_3988, %Stack %stack)
        ret void
    
    label_86:
        
        %intLiteral_4483 = add i64 57, 0
        
        %pureApp_4482 = call ccc %Pos @infixLte_2093(i64 %pureApp_4477, i64 %intLiteral_4483)
        
        
        
        %tag_76 = extractvalue %Pos %pureApp_4482, 0
        %fields_77 = extractvalue %Pos %pureApp_4482, 1
        switch i64 %tag_76, label %label_78 [i64 0, label %label_84 i64 1, label %label_85]
    
    label_87:
        %environment_65 = call ccc %Environment @objectEnvironment(%Object %fields_63)
        %v_coe_3366_46_73_237_4169_pointer_66 = getelementptr <{%Pos}>, %Environment %environment_65, i64 0, i32 0
        %v_coe_3366_46_73_237_4169 = load %Pos, ptr %v_coe_3366_46_73_237_4169_pointer_66, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3366_46_73_237_4169)
        call ccc void @eraseObject(%Object %fields_63)
        
        %pureApp_4477 = call ccc i64 @unboxChar_313(%Pos %v_coe_3366_46_73_237_4169)
        
        
        
        %intLiteral_4479 = add i64 48, 0
        
        %pureApp_4478 = call ccc %Pos @infixGte_2099(i64 %pureApp_4477, i64 %intLiteral_4479)
        
        
        
        %tag_67 = extractvalue %Pos %pureApp_4478, 0
        %fields_68 = extractvalue %Pos %pureApp_4478, 1
        switch i64 %tag_67, label %label_69 [i64 0, label %label_75 i64 1, label %label_86]
    
    label_94:
        %environment_88 = call ccc %Environment @objectEnvironment(%Object %fields_63)
        %v_y_2555_76_103_267_4475_pointer_89 = getelementptr <{%Pos, %Pos}>, %Environment %environment_88, i64 0, i32 0
        %v_y_2555_76_103_267_4475 = load %Pos, ptr %v_y_2555_76_103_267_4475_pointer_89, !noalias !2
        %v_y_2556_77_104_268_4476_pointer_90 = getelementptr <{%Pos, %Pos}>, %Environment %environment_88, i64 0, i32 1
        %v_y_2556_77_104_268_4476 = load %Pos, ptr %v_y_2556_77_104_268_4476_pointer_90, !noalias !2
        call ccc void @eraseObject(%Object %fields_63)
        call ccc void @erasePositive(%Pos %v_r_2464_30_194_4172)
        
        %stackPointer_92 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_93 = getelementptr %FrameHeader, %StackPointer %stackPointer_92, i64 0, i32 0
        %returnAddress_91 = load %ReturnAddress, ptr %returnAddress_pointer_93, !noalias !2
        musttail call tailcc void %returnAddress_91(i64 %acc_8_35_199_4210, %Stack %stack)
        ret void
}



define ccc void @sharer_100(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_101 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %acc_8_35_199_4210_95_pointer_102 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_101, i64 0, i32 0
        %acc_8_35_199_4210_95 = load i64, ptr %acc_8_35_199_4210_95_pointer_102, !noalias !2
        %tmp_4419_96_pointer_103 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_101, i64 0, i32 1
        %tmp_4419_96 = load i64, ptr %tmp_4419_96_pointer_103, !noalias !2
        %v_r_2464_30_194_4172_97_pointer_104 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_101, i64 0, i32 2
        %v_r_2464_30_194_4172_97 = load %Pos, ptr %v_r_2464_30_194_4172_97_pointer_104, !noalias !2
        %p_8_9_3988_98_pointer_105 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_101, i64 0, i32 3
        %p_8_9_3988_98 = load %Prompt, ptr %p_8_9_3988_98_pointer_105, !noalias !2
        %index_7_34_198_4062_99_pointer_106 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_101, i64 0, i32 4
        %index_7_34_198_4062_99 = load i64, ptr %index_7_34_198_4062_99_pointer_106, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2464_30_194_4172_97)
        call ccc void @shareFrames(%StackPointer %stackPointer_101)
        ret void
}



define ccc void @eraser_112(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_113 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %acc_8_35_199_4210_107_pointer_114 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_113, i64 0, i32 0
        %acc_8_35_199_4210_107 = load i64, ptr %acc_8_35_199_4210_107_pointer_114, !noalias !2
        %tmp_4419_108_pointer_115 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_113, i64 0, i32 1
        %tmp_4419_108 = load i64, ptr %tmp_4419_108_pointer_115, !noalias !2
        %v_r_2464_30_194_4172_109_pointer_116 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_113, i64 0, i32 2
        %v_r_2464_30_194_4172_109 = load %Pos, ptr %v_r_2464_30_194_4172_109_pointer_116, !noalias !2
        %p_8_9_3988_110_pointer_117 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_113, i64 0, i32 3
        %p_8_9_3988_110 = load %Prompt, ptr %p_8_9_3988_110_pointer_117, !noalias !2
        %index_7_34_198_4062_111_pointer_118 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_113, i64 0, i32 4
        %index_7_34_198_4062_111 = load i64, ptr %index_7_34_198_4062_111_pointer_118, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2464_30_194_4172_109)
        call ccc void @eraseFrames(%StackPointer %stackPointer_113)
        ret void
}



define tailcc void @returnAddress_129(%Pos %returned_4493, %Stack %stack) {
        
    entry:
        
        %stack_130 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_132 = call ccc %StackPointer @stackDeallocate(%Stack %stack_130, i64 24)
        %returnAddress_pointer_133 = getelementptr %FrameHeader, %StackPointer %stackPointer_132, i64 0, i32 0
        %returnAddress_131 = load %ReturnAddress, ptr %returnAddress_pointer_133, !noalias !2
        musttail call tailcc void %returnAddress_131(%Pos %returned_4493, %Stack %stack_130)
        ret void
}



define tailcc void @Exception_7_19_46_210_4294_clause_138(%Object %closure, %Pos %exc_8_20_47_211_4262, %Pos %msg_9_21_48_212_4232, %Stack %stack) {
        
    entry:
        
        %environment_139 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4147_pointer_140 = getelementptr <{%Prompt}>, %Environment %environment_139, i64 0, i32 0
        %p_6_18_45_209_4147 = load %Prompt, ptr %p_6_18_45_209_4147_pointer_140, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_141 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4147)
        %k_11_23_50_214_4312 = extractvalue <{%Resumption, %Stack}> %pair_141, 0
        %stack_142 = extractvalue <{%Resumption, %Stack}> %pair_141, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4312)
        
        %fields_143 = call ccc %Object @newObject(ptr @eraser_34, i64 32)
        %environment_144 = call ccc %Environment @objectEnvironment(%Object %fields_143)
        %exc_8_20_47_211_4262_pointer_147 = getelementptr <{%Pos, %Pos}>, %Environment %environment_144, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4262, ptr %exc_8_20_47_211_4262_pointer_147, !noalias !2
        %msg_9_21_48_212_4232_pointer_148 = getelementptr <{%Pos, %Pos}>, %Environment %environment_144, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4232, ptr %msg_9_21_48_212_4232_pointer_148, !noalias !2
        %make_4494_temporary_149 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4494 = insertvalue %Pos %make_4494_temporary_149, %Object %fields_143, 1
        
        
        
        %stackPointer_151 = call ccc %StackPointer @stackDeallocate(%Stack %stack_142, i64 24)
        %returnAddress_pointer_152 = getelementptr %FrameHeader, %StackPointer %stackPointer_151, i64 0, i32 0
        %returnAddress_150 = load %ReturnAddress, ptr %returnAddress_pointer_152, !noalias !2
        musttail call tailcc void %returnAddress_150(%Pos %make_4494, %Stack %stack_142)
        ret void
}


@vtable_153 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4294_clause_138]


define ccc void @eraser_157(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4147_156_pointer_158 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4147_156 = load %Prompt, ptr %p_6_18_45_209_4147_156_pointer_158, !noalias !2
        ret void
}



define ccc void @eraser_165(%Environment %environment) {
        
    entry:
        
        %tmp_4421_164_pointer_166 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4421_164 = load %Pos, ptr %tmp_4421_164_pointer_166, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4421_164)
        ret void
}



define tailcc void @returnAddress_161(i64 %v_coe_3365_6_28_55_219_4031, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4495 = call ccc %Pos @boxChar_311(i64 %v_coe_3365_6_28_55_219_4031)
        
        
        
        %fields_162 = call ccc %Object @newObject(ptr @eraser_165, i64 16)
        %environment_163 = call ccc %Environment @objectEnvironment(%Object %fields_162)
        %tmp_4421_pointer_167 = getelementptr <{%Pos}>, %Environment %environment_163, i64 0, i32 0
        store %Pos %pureApp_4495, ptr %tmp_4421_pointer_167, !noalias !2
        %make_4496_temporary_168 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4496 = insertvalue %Pos %make_4496_temporary_168, %Object %fields_162, 1
        
        
        
        %stackPointer_170 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_171 = getelementptr %FrameHeader, %StackPointer %stackPointer_170, i64 0, i32 0
        %returnAddress_169 = load %ReturnAddress, ptr %returnAddress_pointer_171, !noalias !2
        musttail call tailcc void %returnAddress_169(%Pos %make_4496, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4123(i64 %index_7_34_198_4062, i64 %acc_8_35_199_4210, i64 %tmp_4419, %Pos %v_r_2464_30_194_4172, %Prompt %p_8_9_3988, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2464_30_194_4172)
        %stackPointer_119 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %acc_8_35_199_4210_pointer_120 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_119, i64 0, i32 0
        store i64 %acc_8_35_199_4210, ptr %acc_8_35_199_4210_pointer_120, !noalias !2
        %tmp_4419_pointer_121 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_119, i64 0, i32 1
        store i64 %tmp_4419, ptr %tmp_4419_pointer_121, !noalias !2
        %v_r_2464_30_194_4172_pointer_122 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_119, i64 0, i32 2
        store %Pos %v_r_2464_30_194_4172, ptr %v_r_2464_30_194_4172_pointer_122, !noalias !2
        %p_8_9_3988_pointer_123 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_119, i64 0, i32 3
        store %Prompt %p_8_9_3988, ptr %p_8_9_3988_pointer_123, !noalias !2
        %index_7_34_198_4062_pointer_124 = getelementptr <{i64, i64, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_119, i64 0, i32 4
        store i64 %index_7_34_198_4062, ptr %index_7_34_198_4062_pointer_124, !noalias !2
        %returnAddress_pointer_125 = getelementptr <{<{i64, i64, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_119, i64 0, i32 1, i32 0
        %sharer_pointer_126 = getelementptr <{<{i64, i64, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_119, i64 0, i32 1, i32 1
        %eraser_pointer_127 = getelementptr <{<{i64, i64, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_119, i64 0, i32 1, i32 2
        store ptr @returnAddress_55, ptr %returnAddress_pointer_125, !noalias !2
        store ptr @sharer_100, ptr %sharer_pointer_126, !noalias !2
        store ptr @eraser_112, ptr %eraser_pointer_127, !noalias !2
        
        %stack_128 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4147 = call ccc %Prompt @currentPrompt(%Stack %stack_128)
        %stackPointer_134 = call ccc %StackPointer @stackAllocate(%Stack %stack_128, i64 24)
        %returnAddress_pointer_135 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_134, i64 0, i32 1, i32 0
        %sharer_pointer_136 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_134, i64 0, i32 1, i32 1
        %eraser_pointer_137 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_134, i64 0, i32 1, i32 2
        store ptr @returnAddress_129, ptr %returnAddress_pointer_135, !noalias !2
        store ptr @sharer_19, ptr %sharer_pointer_136, !noalias !2
        store ptr @eraser_21, ptr %eraser_pointer_137, !noalias !2
        
        %closure_154 = call ccc %Object @newObject(ptr @eraser_157, i64 8)
        %environment_155 = call ccc %Environment @objectEnvironment(%Object %closure_154)
        %p_6_18_45_209_4147_pointer_159 = getelementptr <{%Prompt}>, %Environment %environment_155, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4147, ptr %p_6_18_45_209_4147_pointer_159, !noalias !2
        %vtable_temporary_160 = insertvalue %Neg zeroinitializer, ptr @vtable_153, 0
        %Exception_7_19_46_210_4294 = insertvalue %Neg %vtable_temporary_160, %Object %closure_154, 1
        %stackPointer_172 = call ccc %StackPointer @stackAllocate(%Stack %stack_128, i64 24)
        %returnAddress_pointer_173 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_172, i64 0, i32 1, i32 0
        %sharer_pointer_174 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_172, i64 0, i32 1, i32 1
        %eraser_pointer_175 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_172, i64 0, i32 1, i32 2
        store ptr @returnAddress_161, ptr %returnAddress_pointer_173, !noalias !2
        store ptr @sharer_5, ptr %sharer_pointer_174, !noalias !2
        store ptr @eraser_7, ptr %eraser_pointer_175, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2464_30_194_4172, i64 %index_7_34_198_4062, %Neg %Exception_7_19_46_210_4294, %Stack %stack_128)
        ret void
}



define tailcc void @Exception_9_106_133_297_4223_clause_176(%Object %closure, %Pos %exception_10_107_134_298_4497, %Pos %msg_11_108_135_299_4498, %Stack %stack) {
        
    entry:
        
        %environment_177 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_3988_pointer_178 = getelementptr <{%Prompt}>, %Environment %environment_177, i64 0, i32 0
        %p_8_9_3988 = load %Prompt, ptr %p_8_9_3988_pointer_178, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4497)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4498)
        
        %pair_179 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_3988)
        %k_13_14_4_4402 = extractvalue <{%Resumption, %Stack}> %pair_179, 0
        %stack_180 = extractvalue <{%Resumption, %Stack}> %pair_179, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4402)
        
        %longLiteral_4499 = add i64 5, 0
        
        
        
        %pureApp_4500 = call ccc %Pos @boxInt_301(i64 %longLiteral_4499)
        
        
        
        %stackPointer_182 = call ccc %StackPointer @stackDeallocate(%Stack %stack_180, i64 24)
        %returnAddress_pointer_183 = getelementptr %FrameHeader, %StackPointer %stackPointer_182, i64 0, i32 0
        %returnAddress_181 = load %ReturnAddress, ptr %returnAddress_pointer_183, !noalias !2
        musttail call tailcc void %returnAddress_181(%Pos %pureApp_4500, %Stack %stack_180)
        ret void
}


@vtable_184 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4223_clause_176]


define tailcc void @returnAddress_195(i64 %v_coe_3370_22_131_158_322_4240, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4503 = call ccc %Pos @boxInt_301(i64 %v_coe_3370_22_131_158_322_4240)
        
        
        
        
        
        %pureApp_4504 = call ccc i64 @unboxInt_303(%Pos %pureApp_4503)
        
        
        
        %pureApp_4505 = call ccc %Pos @boxInt_301(i64 %pureApp_4504)
        
        
        
        %stackPointer_197 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_198 = getelementptr %FrameHeader, %StackPointer %stackPointer_197, i64 0, i32 0
        %returnAddress_196 = load %ReturnAddress, ptr %returnAddress_pointer_198, !noalias !2
        musttail call tailcc void %returnAddress_196(%Pos %pureApp_4505, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_207(i64 %v_r_2562_1_9_20_129_156_320_4149, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4509 = add i64 0, 0
        
        %pureApp_4508 = call ccc i64 @infixSub_105(i64 %longLiteral_4509, i64 %v_r_2562_1_9_20_129_156_320_4149)
        
        
        
        %stackPointer_209 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_210 = getelementptr %FrameHeader, %StackPointer %stackPointer_209, i64 0, i32 0
        %returnAddress_208 = load %ReturnAddress, ptr %returnAddress_pointer_210, !noalias !2
        musttail call tailcc void %returnAddress_208(i64 %pureApp_4508, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_190(i64 %v_r_2561_3_14_123_150_314_4063, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_191 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %tmp_4419_pointer_192 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_191, i64 0, i32 0
        %tmp_4419 = load i64, ptr %tmp_4419_pointer_192, !noalias !2
        %v_r_2464_30_194_4172_pointer_193 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_191, i64 0, i32 1
        %v_r_2464_30_194_4172 = load %Pos, ptr %v_r_2464_30_194_4172_pointer_193, !noalias !2
        %p_8_9_3988_pointer_194 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_191, i64 0, i32 2
        %p_8_9_3988 = load %Prompt, ptr %p_8_9_3988_pointer_194, !noalias !2
        
        %intLiteral_4502 = add i64 45, 0
        
        %pureApp_4501 = call ccc %Pos @infixEq_78(i64 %v_r_2561_3_14_123_150_314_4063, i64 %intLiteral_4502)
        
        
        %stackPointer_199 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_200 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_199, i64 0, i32 1, i32 0
        %sharer_pointer_201 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_199, i64 0, i32 1, i32 1
        %eraser_pointer_202 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_199, i64 0, i32 1, i32 2
        store ptr @returnAddress_195, ptr %returnAddress_pointer_200, !noalias !2
        store ptr @sharer_5, ptr %sharer_pointer_201, !noalias !2
        store ptr @eraser_7, ptr %eraser_pointer_202, !noalias !2
        
        %tag_203 = extractvalue %Pos %pureApp_4501, 0
        %fields_204 = extractvalue %Pos %pureApp_4501, 1
        switch i64 %tag_203, label %label_205 [i64 0, label %label_206 i64 1, label %label_215]
    
    label_205:
        
        ret void
    
    label_206:
        
        %longLiteral_4506 = add i64 0, 0
        
        %longLiteral_4507 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4123(i64 %longLiteral_4506, i64 %longLiteral_4507, i64 %tmp_4419, %Pos %v_r_2464_30_194_4172, %Prompt %p_8_9_3988, %Stack %stack)
        ret void
    
    label_215:
        %stackPointer_211 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_212 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_211, i64 0, i32 1, i32 0
        %sharer_pointer_213 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_211, i64 0, i32 1, i32 1
        %eraser_pointer_214 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_211, i64 0, i32 1, i32 2
        store ptr @returnAddress_207, ptr %returnAddress_pointer_212, !noalias !2
        store ptr @sharer_5, ptr %sharer_pointer_213, !noalias !2
        store ptr @eraser_7, ptr %eraser_pointer_214, !noalias !2
        
        %longLiteral_4510 = add i64 1, 0
        
        %longLiteral_4511 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4123(i64 %longLiteral_4510, i64 %longLiteral_4511, i64 %tmp_4419, %Pos %v_r_2464_30_194_4172, %Prompt %p_8_9_3988, %Stack %stack)
        ret void
}



define ccc void @sharer_219(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_220 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4419_216_pointer_221 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_220, i64 0, i32 0
        %tmp_4419_216 = load i64, ptr %tmp_4419_216_pointer_221, !noalias !2
        %v_r_2464_30_194_4172_217_pointer_222 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_220, i64 0, i32 1
        %v_r_2464_30_194_4172_217 = load %Pos, ptr %v_r_2464_30_194_4172_217_pointer_222, !noalias !2
        %p_8_9_3988_218_pointer_223 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_220, i64 0, i32 2
        %p_8_9_3988_218 = load %Prompt, ptr %p_8_9_3988_218_pointer_223, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2464_30_194_4172_217)
        call ccc void @shareFrames(%StackPointer %stackPointer_220)
        ret void
}



define ccc void @eraser_227(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_228 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %tmp_4419_224_pointer_229 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_228, i64 0, i32 0
        %tmp_4419_224 = load i64, ptr %tmp_4419_224_pointer_229, !noalias !2
        %v_r_2464_30_194_4172_225_pointer_230 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_228, i64 0, i32 1
        %v_r_2464_30_194_4172_225 = load %Pos, ptr %v_r_2464_30_194_4172_225_pointer_230, !noalias !2
        %p_8_9_3988_226_pointer_231 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_228, i64 0, i32 2
        %p_8_9_3988_226 = load %Prompt, ptr %p_8_9_3988_226_pointer_231, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2464_30_194_4172_225)
        call ccc void @eraseFrames(%StackPointer %stackPointer_228)
        ret void
}



define tailcc void @returnAddress_52(%Pos %v_r_2464_30_194_4172, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_53 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_3988_pointer_54 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_53, i64 0, i32 0
        %p_8_9_3988 = load %Prompt, ptr %p_8_9_3988_pointer_54, !noalias !2
        
        %intLiteral_4474 = add i64 48, 0
        
        %pureApp_4473 = call ccc i64 @toInt_2085(i64 %intLiteral_4474)
        
        
        
        %closure_185 = call ccc %Object @newObject(ptr @eraser_157, i64 8)
        %environment_186 = call ccc %Environment @objectEnvironment(%Object %closure_185)
        %p_8_9_3988_pointer_188 = getelementptr <{%Prompt}>, %Environment %environment_186, i64 0, i32 0
        store %Prompt %p_8_9_3988, ptr %p_8_9_3988_pointer_188, !noalias !2
        %vtable_temporary_189 = insertvalue %Neg zeroinitializer, ptr @vtable_184, 0
        %Exception_9_106_133_297_4223 = insertvalue %Neg %vtable_temporary_189, %Object %closure_185, 1
        call ccc void @sharePositive(%Pos %v_r_2464_30_194_4172)
        %stackPointer_232 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %tmp_4419_pointer_233 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_232, i64 0, i32 0
        store i64 %pureApp_4473, ptr %tmp_4419_pointer_233, !noalias !2
        %v_r_2464_30_194_4172_pointer_234 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_232, i64 0, i32 1
        store %Pos %v_r_2464_30_194_4172, ptr %v_r_2464_30_194_4172_pointer_234, !noalias !2
        %p_8_9_3988_pointer_235 = getelementptr <{i64, %Pos, %Prompt}>, %StackPointer %stackPointer_232, i64 0, i32 2
        store %Prompt %p_8_9_3988, ptr %p_8_9_3988_pointer_235, !noalias !2
        %returnAddress_pointer_236 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_232, i64 0, i32 1, i32 0
        %sharer_pointer_237 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_232, i64 0, i32 1, i32 1
        %eraser_pointer_238 = getelementptr <{<{i64, %Pos, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_232, i64 0, i32 1, i32 2
        store ptr @returnAddress_190, ptr %returnAddress_pointer_236, !noalias !2
        store ptr @sharer_219, ptr %sharer_pointer_237, !noalias !2
        store ptr @eraser_227, ptr %eraser_pointer_238, !noalias !2
        
        %longLiteral_4512 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2464_30_194_4172, i64 %longLiteral_4512, %Neg %Exception_9_106_133_297_4223, %Stack %stack)
        ret void
}



define ccc void @sharer_240(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_241 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_3988_239_pointer_242 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_241, i64 0, i32 0
        %p_8_9_3988_239 = load %Prompt, ptr %p_8_9_3988_239_pointer_242, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_241)
        ret void
}



define ccc void @eraser_244(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_245 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_3988_243_pointer_246 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_245, i64 0, i32 0
        %p_8_9_3988_243 = load %Prompt, ptr %p_8_9_3988_243_pointer_246, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_245)
        ret void
}


@utf8StringLiteral_4513.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_49(%Pos %v_r_2463_24_188_4130, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_50 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_3988_pointer_51 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_50, i64 0, i32 0
        %p_8_9_3988 = load %Prompt, ptr %p_8_9_3988_pointer_51, !noalias !2
        %stackPointer_247 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_3988_pointer_248 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_247, i64 0, i32 0
        store %Prompt %p_8_9_3988, ptr %p_8_9_3988_pointer_248, !noalias !2
        %returnAddress_pointer_249 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_247, i64 0, i32 1, i32 0
        %sharer_pointer_250 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_247, i64 0, i32 1, i32 1
        %eraser_pointer_251 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_247, i64 0, i32 1, i32 2
        store ptr @returnAddress_52, ptr %returnAddress_pointer_249, !noalias !2
        store ptr @sharer_240, ptr %sharer_pointer_250, !noalias !2
        store ptr @eraser_244, ptr %eraser_pointer_251, !noalias !2
        
        %tag_252 = extractvalue %Pos %v_r_2463_24_188_4130, 0
        %fields_253 = extractvalue %Pos %v_r_2463_24_188_4130, 1
        switch i64 %tag_252, label %label_254 [i64 0, label %label_258 i64 1, label %label_264]
    
    label_254:
        
        ret void
    
    label_258:
        
        %utf8StringLiteral_4513 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4513.lit)
        
        %stackPointer_256 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_257 = getelementptr %FrameHeader, %StackPointer %stackPointer_256, i64 0, i32 0
        %returnAddress_255 = load %ReturnAddress, ptr %returnAddress_pointer_257, !noalias !2
        musttail call tailcc void %returnAddress_255(%Pos %utf8StringLiteral_4513, %Stack %stack)
        ret void
    
    label_264:
        %environment_259 = call ccc %Environment @objectEnvironment(%Object %fields_253)
        %v_y_3192_8_29_193_4040_pointer_260 = getelementptr <{%Pos}>, %Environment %environment_259, i64 0, i32 0
        %v_y_3192_8_29_193_4040 = load %Pos, ptr %v_y_3192_8_29_193_4040_pointer_260, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3192_8_29_193_4040)
        call ccc void @eraseObject(%Object %fields_253)
        
        %stackPointer_262 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_263 = getelementptr %FrameHeader, %StackPointer %stackPointer_262, i64 0, i32 0
        %returnAddress_261 = load %ReturnAddress, ptr %returnAddress_pointer_263, !noalias !2
        musttail call tailcc void %returnAddress_261(%Pos %v_y_3192_8_29_193_4040, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_46(%Pos %v_r_2462_13_177_4109, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_47 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_3988_pointer_48 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_47, i64 0, i32 0
        %p_8_9_3988 = load %Prompt, ptr %p_8_9_3988_pointer_48, !noalias !2
        %stackPointer_267 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_3988_pointer_268 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_267, i64 0, i32 0
        store %Prompt %p_8_9_3988, ptr %p_8_9_3988_pointer_268, !noalias !2
        %returnAddress_pointer_269 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_267, i64 0, i32 1, i32 0
        %sharer_pointer_270 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_267, i64 0, i32 1, i32 1
        %eraser_pointer_271 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_267, i64 0, i32 1, i32 2
        store ptr @returnAddress_49, ptr %returnAddress_pointer_269, !noalias !2
        store ptr @sharer_240, ptr %sharer_pointer_270, !noalias !2
        store ptr @eraser_244, ptr %eraser_pointer_271, !noalias !2
        
        %tag_272 = extractvalue %Pos %v_r_2462_13_177_4109, 0
        %fields_273 = extractvalue %Pos %v_r_2462_13_177_4109, 1
        switch i64 %tag_272, label %label_274 [i64 0, label %label_279 i64 1, label %label_291]
    
    label_274:
        
        ret void
    
    label_279:
        
        %make_4514_temporary_275 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4514 = insertvalue %Pos %make_4514_temporary_275, %Object null, 1
        
        
        
        %stackPointer_277 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_278 = getelementptr %FrameHeader, %StackPointer %stackPointer_277, i64 0, i32 0
        %returnAddress_276 = load %ReturnAddress, ptr %returnAddress_pointer_278, !noalias !2
        musttail call tailcc void %returnAddress_276(%Pos %make_4514, %Stack %stack)
        ret void
    
    label_291:
        %environment_280 = call ccc %Environment @objectEnvironment(%Object %fields_273)
        %v_y_2701_10_21_185_4024_pointer_281 = getelementptr <{%Pos, %Pos}>, %Environment %environment_280, i64 0, i32 0
        %v_y_2701_10_21_185_4024 = load %Pos, ptr %v_y_2701_10_21_185_4024_pointer_281, !noalias !2
        %v_y_2702_11_22_186_4281_pointer_282 = getelementptr <{%Pos, %Pos}>, %Environment %environment_280, i64 0, i32 1
        %v_y_2702_11_22_186_4281 = load %Pos, ptr %v_y_2702_11_22_186_4281_pointer_282, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2701_10_21_185_4024)
        call ccc void @eraseObject(%Object %fields_273)
        
        %fields_283 = call ccc %Object @newObject(ptr @eraser_165, i64 16)
        %environment_284 = call ccc %Environment @objectEnvironment(%Object %fields_283)
        %v_y_2701_10_21_185_4024_pointer_286 = getelementptr <{%Pos}>, %Environment %environment_284, i64 0, i32 0
        store %Pos %v_y_2701_10_21_185_4024, ptr %v_y_2701_10_21_185_4024_pointer_286, !noalias !2
        %make_4515_temporary_287 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4515 = insertvalue %Pos %make_4515_temporary_287, %Object %fields_283, 1
        
        
        
        %stackPointer_289 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_290 = getelementptr %FrameHeader, %StackPointer %stackPointer_289, i64 0, i32 0
        %returnAddress_288 = load %ReturnAddress, ptr %returnAddress_pointer_290, !noalias !2
        musttail call tailcc void %returnAddress_288(%Pos %make_4515, %Stack %stack)
        ret void
}



define tailcc void @main_2434(%Stack %stack) {
        
    entry:
        
        %stackPointer_9 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_10 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_9, i64 0, i32 1, i32 0
        %sharer_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_9, i64 0, i32 1, i32 1
        %eraser_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_9, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_10, !noalias !2
        store ptr @sharer_5, ptr %sharer_pointer_11, !noalias !2
        store ptr @eraser_7, ptr %eraser_pointer_12, !noalias !2
        
        %stack_13 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_3988 = call ccc %Prompt @currentPrompt(%Stack %stack_13)
        %stackPointer_23 = call ccc %StackPointer @stackAllocate(%Stack %stack_13, i64 24)
        %returnAddress_pointer_24 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_23, i64 0, i32 1, i32 0
        %sharer_pointer_25 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_23, i64 0, i32 1, i32 1
        %eraser_pointer_26 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_23, i64 0, i32 1, i32 2
        store ptr @returnAddress_14, ptr %returnAddress_pointer_24, !noalias !2
        store ptr @sharer_19, ptr %sharer_pointer_25, !noalias !2
        store ptr @eraser_21, ptr %eraser_pointer_26, !noalias !2
        
        %pureApp_4469 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4471 = add i64 1, 0
        
        %pureApp_4470 = call ccc i64 @infixSub_105(i64 %pureApp_4469, i64 %longLiteral_4471)
        
        
        
        %make_4472_temporary_45 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4472 = insertvalue %Pos %make_4472_temporary_45, %Object null, 1
        
        
        %stackPointer_294 = call ccc %StackPointer @stackAllocate(%Stack %stack_13, i64 32)
        %p_8_9_3988_pointer_295 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_294, i64 0, i32 0
        store %Prompt %p_8_9_3988, ptr %p_8_9_3988_pointer_295, !noalias !2
        %returnAddress_pointer_296 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_294, i64 0, i32 1, i32 0
        %sharer_pointer_297 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_294, i64 0, i32 1, i32 1
        %eraser_pointer_298 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_294, i64 0, i32 1, i32 2
        store ptr @returnAddress_46, ptr %returnAddress_pointer_296, !noalias !2
        store ptr @sharer_240, ptr %sharer_pointer_297, !noalias !2
        store ptr @eraser_244, ptr %eraser_pointer_298, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4088(i64 %pureApp_4470, %Pos %make_4472, %Stack %stack_13)
        ret void
}


@utf8StringLiteral_4450.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4452.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4455.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_299(%Pos %v_r_2630_3422, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_300 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_301 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_300, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_301, !noalias !2
        %index_2107_pointer_302 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_300, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_302, !noalias !2
        %Exception_2362_pointer_303 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_300, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_303, !noalias !2
        
        %tag_304 = extractvalue %Pos %v_r_2630_3422, 0
        %fields_305 = extractvalue %Pos %v_r_2630_3422, 1
        switch i64 %tag_304, label %label_306 [i64 0, label %label_310 i64 1, label %label_316]
    
    label_306:
        
        ret void
    
    label_310:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4446 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_308 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_309 = getelementptr %FrameHeader, %StackPointer %stackPointer_308, i64 0, i32 0
        %returnAddress_307 = load %ReturnAddress, ptr %returnAddress_pointer_309, !noalias !2
        musttail call tailcc void %returnAddress_307(i64 %pureApp_4446, %Stack %stack)
        ret void
    
    label_316:
        
        %make_4447_temporary_311 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4447 = insertvalue %Pos %make_4447_temporary_311, %Object null, 1
        
        
        
        %pureApp_4448 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4450 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4450.lit)
        
        %pureApp_4449 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4450, %Pos %pureApp_4448)
        
        
        
        %utf8StringLiteral_4452 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4452.lit)
        
        %pureApp_4451 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4449, %Pos %utf8StringLiteral_4452)
        
        
        
        %pureApp_4453 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4451, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4455 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4455.lit)
        
        %pureApp_4454 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4453, %Pos %utf8StringLiteral_4455)
        
        
        
        %vtable_312 = extractvalue %Neg %Exception_2362, 0
        %closure_313 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_314 = getelementptr ptr, ptr %vtable_312, i64 0
        %functionPointer_315 = load ptr, ptr %functionPointer_pointer_314, !noalias !2
        musttail call tailcc void %functionPointer_315(%Object %closure_313, %Pos %make_4447, %Pos %pureApp_4454, %Stack %stack)
        ret void
}



define ccc void @sharer_320(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_321 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_317_pointer_322 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_321, i64 0, i32 0
        %str_2106_317 = load %Pos, ptr %str_2106_317_pointer_322, !noalias !2
        %index_2107_318_pointer_323 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_321, i64 0, i32 1
        %index_2107_318 = load i64, ptr %index_2107_318_pointer_323, !noalias !2
        %Exception_2362_319_pointer_324 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_321, i64 0, i32 2
        %Exception_2362_319 = load %Neg, ptr %Exception_2362_319_pointer_324, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_317)
        call ccc void @shareNegative(%Neg %Exception_2362_319)
        call ccc void @shareFrames(%StackPointer %stackPointer_321)
        ret void
}



define ccc void @eraser_328(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_329 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_325_pointer_330 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_329, i64 0, i32 0
        %str_2106_325 = load %Pos, ptr %str_2106_325_pointer_330, !noalias !2
        %index_2107_326_pointer_331 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_329, i64 0, i32 1
        %index_2107_326 = load i64, ptr %index_2107_326_pointer_331, !noalias !2
        %Exception_2362_327_pointer_332 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_329, i64 0, i32 2
        %Exception_2362_327 = load %Neg, ptr %Exception_2362_327_pointer_332, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_325)
        call ccc void @eraseNegative(%Neg %Exception_2362_327)
        call ccc void @eraseFrames(%StackPointer %stackPointer_329)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4445 = add i64 0, 0
        
        %pureApp_4444 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4445)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_333 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_334 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_333, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_334, !noalias !2
        %index_2107_pointer_335 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_333, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_335, !noalias !2
        %Exception_2362_pointer_336 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_333, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_336, !noalias !2
        %returnAddress_pointer_337 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_333, i64 0, i32 1, i32 0
        %sharer_pointer_338 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_333, i64 0, i32 1, i32 1
        %eraser_pointer_339 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_333, i64 0, i32 1, i32 2
        store ptr @returnAddress_299, ptr %returnAddress_pointer_337, !noalias !2
        store ptr @sharer_320, ptr %sharer_pointer_338, !noalias !2
        store ptr @eraser_328, ptr %eraser_pointer_339, !noalias !2
        
        %tag_340 = extractvalue %Pos %pureApp_4444, 0
        %fields_341 = extractvalue %Pos %pureApp_4444, 1
        switch i64 %tag_340, label %label_342 [i64 0, label %label_346 i64 1, label %label_351]
    
    label_342:
        
        ret void
    
    label_346:
        
        %pureApp_4456 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4457 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4456)
        
        
        
        %stackPointer_344 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_345 = getelementptr %FrameHeader, %StackPointer %stackPointer_344, i64 0, i32 0
        %returnAddress_343 = load %ReturnAddress, ptr %returnAddress_pointer_345, !noalias !2
        musttail call tailcc void %returnAddress_343(%Pos %pureApp_4457, %Stack %stack)
        ret void
    
    label_351:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4458_temporary_347 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4458 = insertvalue %Pos %booleanLiteral_4458_temporary_347, %Object null, 1
        
        %stackPointer_349 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_350 = getelementptr %FrameHeader, %StackPointer %stackPointer_349, i64 0, i32 0
        %returnAddress_348 = load %ReturnAddress, ptr %returnAddress_pointer_350, !noalias !2
        musttail call tailcc void %returnAddress_348(%Pos %booleanLiteral_4458, %Stack %stack)
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
        
        musttail call tailcc void @main_2434(%Stack %stack)
        ret void
}
