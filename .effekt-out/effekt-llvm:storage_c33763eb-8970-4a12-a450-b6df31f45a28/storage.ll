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


; declaration include
  declare i32 @clock_gettime(i32, ptr)



define ccc %Pos @allocate_2473(i64 %size_2472) {
    ; declaration extern
    ; variable
    
    %z = call %Pos @c_array_new(%Int %size_2472)
    ret %Pos %z
  
}



define tailcc void @returnAddress_10(i64 %v_r_2970_2_5096, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_11 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_5090_pointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 0
        %i_6_5090 = load i64, ptr %i_6_5090_pointer_12, !noalias !2
        %tmp_5218_pointer_13 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 1
        %tmp_5218 = load i64, ptr %tmp_5218_pointer_13, !noalias !2
        
        %longLiteral_5291 = add i64 1, 0
        
        %pureApp_5290 = call ccc i64 @infixAdd_96(i64 %i_6_5090, i64 %longLiteral_5291)
        
        
        
        
        
        musttail call tailcc void @loop_5_5089(i64 %pureApp_5290, i64 %tmp_5218, %Stack %stack)
        ret void
}



define ccc void @sharer_16(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_17 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5090_14_pointer_18 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 0
        %i_6_5090_14 = load i64, ptr %i_6_5090_14_pointer_18, !noalias !2
        %tmp_5218_15_pointer_19 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 1
        %tmp_5218_15 = load i64, ptr %tmp_5218_15_pointer_19, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_17)
        ret void
}



define ccc void @eraser_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5090_20_pointer_24 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %i_6_5090_20 = load i64, ptr %i_6_5090_20_pointer_24, !noalias !2
        %tmp_5218_21_pointer_25 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 1
        %tmp_5218_21 = load i64, ptr %tmp_5218_21_pointer_25, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_23)
        ret void
}



define tailcc void @loop_5_5089(i64 %i_6_5090, i64 %tmp_5218, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5288 = call ccc %Pos @infixLt_178(i64 %i_6_5090, i64 %tmp_5218)
        
        
        
        %tag_2 = extractvalue %Pos %pureApp_5288, 0
        %fields_3 = extractvalue %Pos %pureApp_5288, 1
        switch i64 %tag_2, label %label_4 [i64 0, label %label_9 i64 1, label %label_32]
    
    label_4:
        
        ret void
    
    label_9:
        
        %unitLiteral_5289_temporary_5 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5289 = insertvalue %Pos %unitLiteral_5289_temporary_5, %Object null, 1
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %unitLiteral_5289, %Stack %stack)
        ret void
    
    label_32:
        %stackPointer_26 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_5090_pointer_27 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        store i64 %i_6_5090, ptr %i_6_5090_pointer_27, !noalias !2
        %tmp_5218_pointer_28 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 1
        store i64 %tmp_5218, ptr %tmp_5218_pointer_28, !noalias !2
        %returnAddress_pointer_29 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 0
        %sharer_pointer_30 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 1
        %eraser_pointer_31 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 2
        store ptr @returnAddress_10, ptr %returnAddress_pointer_29, !noalias !2
        store ptr @sharer_16, ptr %sharer_pointer_30, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_31, !noalias !2
        
        %longLiteral_5292 = add i64 7, 0
        
        
        
        musttail call tailcc void @run_2861(i64 %longLiteral_5292, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_34(i64 %r_2888, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5294 = call ccc %Pos @show_14(i64 %r_2888)
        
        
        
        %pureApp_5295 = call ccc %Pos @println_1(%Pos %pureApp_5294)
        
        
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_37 = getelementptr %FrameHeader, %StackPointer %stackPointer_36, i64 0, i32 0
        %returnAddress_35 = load %ReturnAddress, ptr %returnAddress_pointer_37, !noalias !2
        musttail call tailcc void %returnAddress_35(%Pos %pureApp_5295, %Stack %stack)
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



define tailcc void @returnAddress_33(%Pos %v_r_2972_5293, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %v_r_2972_5293)
        %stackPointer_42 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_43 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 0
        %sharer_pointer_44 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 1
        %eraser_pointer_45 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_43, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_44, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_45, !noalias !2
        
        %longLiteral_5296 = add i64 7, 0
        
        
        
        musttail call tailcc void @run_2861(i64 %longLiteral_5296, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_4006_4070, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5285 = call ccc i64 @unboxInt_303(%Pos %v_coe_4006_4070)
        
        
        
        %longLiteral_5287 = add i64 1, 0
        
        %pureApp_5286 = call ccc i64 @infixSub_105(i64 %pureApp_5285, i64 %longLiteral_5287)
        
        
        %stackPointer_46 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_47 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 0
        %sharer_pointer_48 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 1
        %eraser_pointer_49 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 2
        store ptr @returnAddress_33, ptr %returnAddress_pointer_47, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_48, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_49, !noalias !2
        
        %longLiteral_5297 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_5089(i64 %longLiteral_5297, i64 %pureApp_5286, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_55(%Pos %returned_5298, %Stack %stack) {
        
    entry:
        
        %stack_56 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_58 = call ccc %StackPointer @stackDeallocate(%Stack %stack_56, i64 24)
        %returnAddress_pointer_59 = getelementptr %FrameHeader, %StackPointer %stackPointer_58, i64 0, i32 0
        %returnAddress_57 = load %ReturnAddress, ptr %returnAddress_pointer_59, !noalias !2
        musttail call tailcc void %returnAddress_57(%Pos %returned_5298, %Stack %stack_56)
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
        
        %tmp_5191_73_pointer_76 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5191_73 = load %Pos, ptr %tmp_5191_73_pointer_76, !noalias !2
        %acc_3_3_5_169_4982_74_pointer_77 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4982_74 = load %Pos, ptr %acc_3_3_5_169_4982_74_pointer_77, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5191_73)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4982_74)
        ret void
}



define tailcc void @toList_1_1_3_167_4926(i64 %start_2_2_4_168_4959, %Pos %acc_3_3_5_169_4982, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5300 = add i64 1, 0
        
        %pureApp_5299 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4959, i64 %longLiteral_5300)
        
        
        
        %tag_68 = extractvalue %Pos %pureApp_5299, 0
        %fields_69 = extractvalue %Pos %pureApp_5299, 1
        switch i64 %tag_68, label %label_70 [i64 0, label %label_81 i64 1, label %label_85]
    
    label_70:
        
        ret void
    
    label_81:
        
        %pureApp_5301 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4959)
        
        
        
        %longLiteral_5303 = add i64 1, 0
        
        %pureApp_5302 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4959, i64 %longLiteral_5303)
        
        
        
        %fields_71 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_72 = call ccc %Environment @objectEnvironment(%Object %fields_71)
        %tmp_5191_pointer_78 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 0
        store %Pos %pureApp_5301, ptr %tmp_5191_pointer_78, !noalias !2
        %acc_3_3_5_169_4982_pointer_79 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4982, ptr %acc_3_3_5_169_4982_pointer_79, !noalias !2
        %make_5304_temporary_80 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5304 = insertvalue %Pos %make_5304_temporary_80, %Object %fields_71, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4926(i64 %pureApp_5302, %Pos %make_5304, %Stack %stack)
        ret void
    
    label_85:
        
        %stackPointer_83 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_84 = getelementptr %FrameHeader, %StackPointer %stackPointer_83, i64 0, i32 0
        %returnAddress_82 = load %ReturnAddress, ptr %returnAddress_pointer_84, !noalias !2
        musttail call tailcc void %returnAddress_82(%Pos %acc_3_3_5_169_4982, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_96(%Pos %v_r_3157_32_59_223_4793, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_97 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %v_r_2967_30_194_4829_pointer_98 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 0
        %v_r_2967_30_194_4829 = load %Pos, ptr %v_r_2967_30_194_4829_pointer_98, !noalias !2
        %p_8_9_4719_pointer_99 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 1
        %p_8_9_4719 = load %Prompt, ptr %p_8_9_4719_pointer_99, !noalias !2
        %tmp_5198_pointer_100 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 2
        %tmp_5198 = load i64, ptr %tmp_5198_pointer_100, !noalias !2
        %acc_8_35_199_4795_pointer_101 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 3
        %acc_8_35_199_4795 = load i64, ptr %acc_8_35_199_4795_pointer_101, !noalias !2
        %index_7_34_198_4909_pointer_102 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 4
        %index_7_34_198_4909 = load i64, ptr %index_7_34_198_4909_pointer_102, !noalias !2
        
        %tag_103 = extractvalue %Pos %v_r_3157_32_59_223_4793, 0
        %fields_104 = extractvalue %Pos %v_r_3157_32_59_223_4793, 1
        switch i64 %tag_103, label %label_105 [i64 1, label %label_128 i64 0, label %label_135]
    
    label_105:
        
        ret void
    
    label_110:
        
        ret void
    
    label_116:
        call ccc void @erasePositive(%Pos %v_r_2967_30_194_4829)
        
        %pair_111 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4719)
        %k_13_14_4_5103 = extractvalue <{%Resumption, %Stack}> %pair_111, 0
        %stack_112 = extractvalue <{%Resumption, %Stack}> %pair_111, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5103)
        
        %longLiteral_5316 = add i64 10, 0
        
        
        
        %pureApp_5317 = call ccc %Pos @boxInt_301(i64 %longLiteral_5316)
        
        
        
        %stackPointer_114 = call ccc %StackPointer @stackDeallocate(%Stack %stack_112, i64 24)
        %returnAddress_pointer_115 = getelementptr %FrameHeader, %StackPointer %stackPointer_114, i64 0, i32 0
        %returnAddress_113 = load %ReturnAddress, ptr %returnAddress_pointer_115, !noalias !2
        musttail call tailcc void %returnAddress_113(%Pos %pureApp_5317, %Stack %stack_112)
        ret void
    
    label_119:
        
        ret void
    
    label_125:
        call ccc void @erasePositive(%Pos %v_r_2967_30_194_4829)
        
        %pair_120 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4719)
        %k_13_14_4_5102 = extractvalue <{%Resumption, %Stack}> %pair_120, 0
        %stack_121 = extractvalue <{%Resumption, %Stack}> %pair_120, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5102)
        
        %longLiteral_5320 = add i64 10, 0
        
        
        
        %pureApp_5321 = call ccc %Pos @boxInt_301(i64 %longLiteral_5320)
        
        
        
        %stackPointer_123 = call ccc %StackPointer @stackDeallocate(%Stack %stack_121, i64 24)
        %returnAddress_pointer_124 = getelementptr %FrameHeader, %StackPointer %stackPointer_123, i64 0, i32 0
        %returnAddress_122 = load %ReturnAddress, ptr %returnAddress_pointer_124, !noalias !2
        musttail call tailcc void %returnAddress_122(%Pos %pureApp_5321, %Stack %stack_121)
        ret void
    
    label_126:
        
        %longLiteral_5323 = add i64 1, 0
        
        %pureApp_5322 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4909, i64 %longLiteral_5323)
        
        
        
        %longLiteral_5325 = add i64 10, 0
        
        %pureApp_5324 = call ccc i64 @infixMul_99(i64 %longLiteral_5325, i64 %acc_8_35_199_4795)
        
        
        
        %pureApp_5326 = call ccc i64 @toInt_2085(i64 %pureApp_5313)
        
        
        
        %pureApp_5327 = call ccc i64 @infixSub_105(i64 %pureApp_5326, i64 %tmp_5198)
        
        
        
        %pureApp_5328 = call ccc i64 @infixAdd_96(i64 %pureApp_5324, i64 %pureApp_5327)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4889(i64 %pureApp_5322, i64 %pureApp_5328, %Pos %v_r_2967_30_194_4829, %Prompt %p_8_9_4719, i64 %tmp_5198, %Stack %stack)
        ret void
    
    label_127:
        
        %intLiteral_5319 = add i64 57, 0
        
        %pureApp_5318 = call ccc %Pos @infixLte_2093(i64 %pureApp_5313, i64 %intLiteral_5319)
        
        
        
        %tag_117 = extractvalue %Pos %pureApp_5318, 0
        %fields_118 = extractvalue %Pos %pureApp_5318, 1
        switch i64 %tag_117, label %label_119 [i64 0, label %label_125 i64 1, label %label_126]
    
    label_128:
        %environment_106 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_coe_3975_46_73_237_4981_pointer_107 = getelementptr <{%Pos}>, %Environment %environment_106, i64 0, i32 0
        %v_coe_3975_46_73_237_4981 = load %Pos, ptr %v_coe_3975_46_73_237_4981_pointer_107, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3975_46_73_237_4981)
        call ccc void @eraseObject(%Object %fields_104)
        
        %pureApp_5313 = call ccc i64 @unboxChar_313(%Pos %v_coe_3975_46_73_237_4981)
        
        
        
        %intLiteral_5315 = add i64 48, 0
        
        %pureApp_5314 = call ccc %Pos @infixGte_2099(i64 %pureApp_5313, i64 %intLiteral_5315)
        
        
        
        %tag_108 = extractvalue %Pos %pureApp_5314, 0
        %fields_109 = extractvalue %Pos %pureApp_5314, 1
        switch i64 %tag_108, label %label_110 [i64 0, label %label_116 i64 1, label %label_127]
    
    label_135:
        %environment_129 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_y_3164_76_103_267_5311_pointer_130 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 0
        %v_y_3164_76_103_267_5311 = load %Pos, ptr %v_y_3164_76_103_267_5311_pointer_130, !noalias !2
        %v_y_3165_77_104_268_5312_pointer_131 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 1
        %v_y_3165_77_104_268_5312 = load %Pos, ptr %v_y_3165_77_104_268_5312_pointer_131, !noalias !2
        call ccc void @eraseObject(%Object %fields_104)
        call ccc void @erasePositive(%Pos %v_r_2967_30_194_4829)
        
        %stackPointer_133 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_134 = getelementptr %FrameHeader, %StackPointer %stackPointer_133, i64 0, i32 0
        %returnAddress_132 = load %ReturnAddress, ptr %returnAddress_pointer_134, !noalias !2
        musttail call tailcc void %returnAddress_132(i64 %acc_8_35_199_4795, %Stack %stack)
        ret void
}



define ccc void @sharer_141(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_142 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2967_30_194_4829_136_pointer_143 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 0
        %v_r_2967_30_194_4829_136 = load %Pos, ptr %v_r_2967_30_194_4829_136_pointer_143, !noalias !2
        %p_8_9_4719_137_pointer_144 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 1
        %p_8_9_4719_137 = load %Prompt, ptr %p_8_9_4719_137_pointer_144, !noalias !2
        %tmp_5198_138_pointer_145 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 2
        %tmp_5198_138 = load i64, ptr %tmp_5198_138_pointer_145, !noalias !2
        %acc_8_35_199_4795_139_pointer_146 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 3
        %acc_8_35_199_4795_139 = load i64, ptr %acc_8_35_199_4795_139_pointer_146, !noalias !2
        %index_7_34_198_4909_140_pointer_147 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 4
        %index_7_34_198_4909_140 = load i64, ptr %index_7_34_198_4909_140_pointer_147, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2967_30_194_4829_136)
        call ccc void @shareFrames(%StackPointer %stackPointer_142)
        ret void
}



define ccc void @eraser_153(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_154 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2967_30_194_4829_148_pointer_155 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 0
        %v_r_2967_30_194_4829_148 = load %Pos, ptr %v_r_2967_30_194_4829_148_pointer_155, !noalias !2
        %p_8_9_4719_149_pointer_156 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 1
        %p_8_9_4719_149 = load %Prompt, ptr %p_8_9_4719_149_pointer_156, !noalias !2
        %tmp_5198_150_pointer_157 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 2
        %tmp_5198_150 = load i64, ptr %tmp_5198_150_pointer_157, !noalias !2
        %acc_8_35_199_4795_151_pointer_158 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 3
        %acc_8_35_199_4795_151 = load i64, ptr %acc_8_35_199_4795_151_pointer_158, !noalias !2
        %index_7_34_198_4909_152_pointer_159 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 4
        %index_7_34_198_4909_152 = load i64, ptr %index_7_34_198_4909_152_pointer_159, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2967_30_194_4829_148)
        call ccc void @eraseFrames(%StackPointer %stackPointer_154)
        ret void
}



define tailcc void @returnAddress_170(%Pos %returned_5329, %Stack %stack) {
        
    entry:
        
        %stack_171 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_173 = call ccc %StackPointer @stackDeallocate(%Stack %stack_171, i64 24)
        %returnAddress_pointer_174 = getelementptr %FrameHeader, %StackPointer %stackPointer_173, i64 0, i32 0
        %returnAddress_172 = load %ReturnAddress, ptr %returnAddress_pointer_174, !noalias !2
        musttail call tailcc void %returnAddress_172(%Pos %returned_5329, %Stack %stack_171)
        ret void
}



define tailcc void @Exception_7_19_46_210_4958_clause_179(%Object %closure, %Pos %exc_8_20_47_211_4893, %Pos %msg_9_21_48_212_4757, %Stack %stack) {
        
    entry:
        
        %environment_180 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4976_pointer_181 = getelementptr <{%Prompt}>, %Environment %environment_180, i64 0, i32 0
        %p_6_18_45_209_4976 = load %Prompt, ptr %p_6_18_45_209_4976_pointer_181, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_182 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4976)
        %k_11_23_50_214_5044 = extractvalue <{%Resumption, %Stack}> %pair_182, 0
        %stack_183 = extractvalue <{%Resumption, %Stack}> %pair_182, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_5044)
        
        %fields_184 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_185 = call ccc %Environment @objectEnvironment(%Object %fields_184)
        %exc_8_20_47_211_4893_pointer_188 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4893, ptr %exc_8_20_47_211_4893_pointer_188, !noalias !2
        %msg_9_21_48_212_4757_pointer_189 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4757, ptr %msg_9_21_48_212_4757_pointer_189, !noalias !2
        %make_5330_temporary_190 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5330 = insertvalue %Pos %make_5330_temporary_190, %Object %fields_184, 1
        
        
        
        %stackPointer_192 = call ccc %StackPointer @stackDeallocate(%Stack %stack_183, i64 24)
        %returnAddress_pointer_193 = getelementptr %FrameHeader, %StackPointer %stackPointer_192, i64 0, i32 0
        %returnAddress_191 = load %ReturnAddress, ptr %returnAddress_pointer_193, !noalias !2
        musttail call tailcc void %returnAddress_191(%Pos %make_5330, %Stack %stack_183)
        ret void
}


@vtable_194 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4958_clause_179]


define ccc void @eraser_198(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4976_197_pointer_199 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4976_197 = load %Prompt, ptr %p_6_18_45_209_4976_197_pointer_199, !noalias !2
        ret void
}



define ccc void @eraser_206(%Environment %environment) {
        
    entry:
        
        %tmp_5200_205_pointer_207 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5200_205 = load %Pos, ptr %tmp_5200_205_pointer_207, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5200_205)
        ret void
}



define tailcc void @returnAddress_202(i64 %v_coe_3974_6_28_55_219_4987, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5331 = call ccc %Pos @boxChar_311(i64 %v_coe_3974_6_28_55_219_4987)
        
        
        
        %fields_203 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_204 = call ccc %Environment @objectEnvironment(%Object %fields_203)
        %tmp_5200_pointer_208 = getelementptr <{%Pos}>, %Environment %environment_204, i64 0, i32 0
        store %Pos %pureApp_5331, ptr %tmp_5200_pointer_208, !noalias !2
        %make_5332_temporary_209 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5332 = insertvalue %Pos %make_5332_temporary_209, %Object %fields_203, 1
        
        
        
        %stackPointer_211 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_212 = getelementptr %FrameHeader, %StackPointer %stackPointer_211, i64 0, i32 0
        %returnAddress_210 = load %ReturnAddress, ptr %returnAddress_pointer_212, !noalias !2
        musttail call tailcc void %returnAddress_210(%Pos %make_5332, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4889(i64 %index_7_34_198_4909, i64 %acc_8_35_199_4795, %Pos %v_r_2967_30_194_4829, %Prompt %p_8_9_4719, i64 %tmp_5198, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2967_30_194_4829)
        %stackPointer_160 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %v_r_2967_30_194_4829_pointer_161 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 0
        store %Pos %v_r_2967_30_194_4829, ptr %v_r_2967_30_194_4829_pointer_161, !noalias !2
        %p_8_9_4719_pointer_162 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 1
        store %Prompt %p_8_9_4719, ptr %p_8_9_4719_pointer_162, !noalias !2
        %tmp_5198_pointer_163 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 2
        store i64 %tmp_5198, ptr %tmp_5198_pointer_163, !noalias !2
        %acc_8_35_199_4795_pointer_164 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 3
        store i64 %acc_8_35_199_4795, ptr %acc_8_35_199_4795_pointer_164, !noalias !2
        %index_7_34_198_4909_pointer_165 = getelementptr <{%Pos, %Prompt, i64, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 4
        store i64 %index_7_34_198_4909, ptr %index_7_34_198_4909_pointer_165, !noalias !2
        %returnAddress_pointer_166 = getelementptr <{<{%Pos, %Prompt, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 0
        %sharer_pointer_167 = getelementptr <{<{%Pos, %Prompt, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 1
        %eraser_pointer_168 = getelementptr <{<{%Pos, %Prompt, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 2
        store ptr @returnAddress_96, ptr %returnAddress_pointer_166, !noalias !2
        store ptr @sharer_141, ptr %sharer_pointer_167, !noalias !2
        store ptr @eraser_153, ptr %eraser_pointer_168, !noalias !2
        
        %stack_169 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4976 = call ccc %Prompt @currentPrompt(%Stack %stack_169)
        %stackPointer_175 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_176 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 0
        %sharer_pointer_177 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 1
        %eraser_pointer_178 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 2
        store ptr @returnAddress_170, ptr %returnAddress_pointer_176, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_177, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_178, !noalias !2
        
        %closure_195 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_196 = call ccc %Environment @objectEnvironment(%Object %closure_195)
        %p_6_18_45_209_4976_pointer_200 = getelementptr <{%Prompt}>, %Environment %environment_196, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4976, ptr %p_6_18_45_209_4976_pointer_200, !noalias !2
        %vtable_temporary_201 = insertvalue %Neg zeroinitializer, ptr @vtable_194, 0
        %Exception_7_19_46_210_4958 = insertvalue %Neg %vtable_temporary_201, %Object %closure_195, 1
        %stackPointer_213 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_214 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 0
        %sharer_pointer_215 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 1
        %eraser_pointer_216 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 2
        store ptr @returnAddress_202, ptr %returnAddress_pointer_214, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_215, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_216, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2967_30_194_4829, i64 %index_7_34_198_4909, %Neg %Exception_7_19_46_210_4958, %Stack %stack_169)
        ret void
}



define tailcc void @Exception_9_106_133_297_4825_clause_217(%Object %closure, %Pos %exception_10_107_134_298_5333, %Pos %msg_11_108_135_299_5334, %Stack %stack) {
        
    entry:
        
        %environment_218 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4719_pointer_219 = getelementptr <{%Prompt}>, %Environment %environment_218, i64 0, i32 0
        %p_8_9_4719 = load %Prompt, ptr %p_8_9_4719_pointer_219, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5333)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5334)
        
        %pair_220 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4719)
        %k_13_14_4_5167 = extractvalue <{%Resumption, %Stack}> %pair_220, 0
        %stack_221 = extractvalue <{%Resumption, %Stack}> %pair_220, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5167)
        
        %longLiteral_5335 = add i64 10, 0
        
        
        
        %pureApp_5336 = call ccc %Pos @boxInt_301(i64 %longLiteral_5335)
        
        
        
        %stackPointer_223 = call ccc %StackPointer @stackDeallocate(%Stack %stack_221, i64 24)
        %returnAddress_pointer_224 = getelementptr %FrameHeader, %StackPointer %stackPointer_223, i64 0, i32 0
        %returnAddress_222 = load %ReturnAddress, ptr %returnAddress_pointer_224, !noalias !2
        musttail call tailcc void %returnAddress_222(%Pos %pureApp_5336, %Stack %stack_221)
        ret void
}


@vtable_225 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4825_clause_217]


define tailcc void @returnAddress_236(i64 %v_coe_3979_22_131_158_322_4896, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5339 = call ccc %Pos @boxInt_301(i64 %v_coe_3979_22_131_158_322_4896)
        
        
        
        
        
        %pureApp_5340 = call ccc i64 @unboxInt_303(%Pos %pureApp_5339)
        
        
        
        %pureApp_5341 = call ccc %Pos @boxInt_301(i64 %pureApp_5340)
        
        
        
        %stackPointer_238 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_239 = getelementptr %FrameHeader, %StackPointer %stackPointer_238, i64 0, i32 0
        %returnAddress_237 = load %ReturnAddress, ptr %returnAddress_pointer_239, !noalias !2
        musttail call tailcc void %returnAddress_237(%Pos %pureApp_5341, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_248(i64 %v_r_3171_1_9_20_129_156_320_4794, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5345 = add i64 0, 0
        
        %pureApp_5344 = call ccc i64 @infixSub_105(i64 %longLiteral_5345, i64 %v_r_3171_1_9_20_129_156_320_4794)
        
        
        
        %stackPointer_250 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_251 = getelementptr %FrameHeader, %StackPointer %stackPointer_250, i64 0, i32 0
        %returnAddress_249 = load %ReturnAddress, ptr %returnAddress_pointer_251, !noalias !2
        musttail call tailcc void %returnAddress_249(i64 %pureApp_5344, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_231(i64 %v_r_3170_3_14_123_150_314_5007, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_232 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_2967_30_194_4829_pointer_233 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 0
        %v_r_2967_30_194_4829 = load %Pos, ptr %v_r_2967_30_194_4829_pointer_233, !noalias !2
        %p_8_9_4719_pointer_234 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 1
        %p_8_9_4719 = load %Prompt, ptr %p_8_9_4719_pointer_234, !noalias !2
        %tmp_5198_pointer_235 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 2
        %tmp_5198 = load i64, ptr %tmp_5198_pointer_235, !noalias !2
        
        %intLiteral_5338 = add i64 45, 0
        
        %pureApp_5337 = call ccc %Pos @infixEq_78(i64 %v_r_3170_3_14_123_150_314_5007, i64 %intLiteral_5338)
        
        
        %stackPointer_240 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_241 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 0
        %sharer_pointer_242 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 1
        %eraser_pointer_243 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 2
        store ptr @returnAddress_236, ptr %returnAddress_pointer_241, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_242, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_243, !noalias !2
        
        %tag_244 = extractvalue %Pos %pureApp_5337, 0
        %fields_245 = extractvalue %Pos %pureApp_5337, 1
        switch i64 %tag_244, label %label_246 [i64 0, label %label_247 i64 1, label %label_256]
    
    label_246:
        
        ret void
    
    label_247:
        
        %longLiteral_5342 = add i64 0, 0
        
        %longLiteral_5343 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4889(i64 %longLiteral_5342, i64 %longLiteral_5343, %Pos %v_r_2967_30_194_4829, %Prompt %p_8_9_4719, i64 %tmp_5198, %Stack %stack)
        ret void
    
    label_256:
        %stackPointer_252 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_253 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 0
        %sharer_pointer_254 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 1
        %eraser_pointer_255 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 2
        store ptr @returnAddress_248, ptr %returnAddress_pointer_253, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_254, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_255, !noalias !2
        
        %longLiteral_5346 = add i64 1, 0
        
        %longLiteral_5347 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4889(i64 %longLiteral_5346, i64 %longLiteral_5347, %Pos %v_r_2967_30_194_4829, %Prompt %p_8_9_4719, i64 %tmp_5198, %Stack %stack)
        ret void
}



define ccc void @sharer_260(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_261 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2967_30_194_4829_257_pointer_262 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 0
        %v_r_2967_30_194_4829_257 = load %Pos, ptr %v_r_2967_30_194_4829_257_pointer_262, !noalias !2
        %p_8_9_4719_258_pointer_263 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 1
        %p_8_9_4719_258 = load %Prompt, ptr %p_8_9_4719_258_pointer_263, !noalias !2
        %tmp_5198_259_pointer_264 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 2
        %tmp_5198_259 = load i64, ptr %tmp_5198_259_pointer_264, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2967_30_194_4829_257)
        call ccc void @shareFrames(%StackPointer %stackPointer_261)
        ret void
}



define ccc void @eraser_268(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_269 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2967_30_194_4829_265_pointer_270 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 0
        %v_r_2967_30_194_4829_265 = load %Pos, ptr %v_r_2967_30_194_4829_265_pointer_270, !noalias !2
        %p_8_9_4719_266_pointer_271 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 1
        %p_8_9_4719_266 = load %Prompt, ptr %p_8_9_4719_266_pointer_271, !noalias !2
        %tmp_5198_267_pointer_272 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 2
        %tmp_5198_267 = load i64, ptr %tmp_5198_267_pointer_272, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2967_30_194_4829_265)
        call ccc void @eraseFrames(%StackPointer %stackPointer_269)
        ret void
}



define tailcc void @returnAddress_93(%Pos %v_r_2967_30_194_4829, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_94 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4719_pointer_95 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_94, i64 0, i32 0
        %p_8_9_4719 = load %Prompt, ptr %p_8_9_4719_pointer_95, !noalias !2
        
        %intLiteral_5310 = add i64 48, 0
        
        %pureApp_5309 = call ccc i64 @toInt_2085(i64 %intLiteral_5310)
        
        
        
        %closure_226 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_227 = call ccc %Environment @objectEnvironment(%Object %closure_226)
        %p_8_9_4719_pointer_229 = getelementptr <{%Prompt}>, %Environment %environment_227, i64 0, i32 0
        store %Prompt %p_8_9_4719, ptr %p_8_9_4719_pointer_229, !noalias !2
        %vtable_temporary_230 = insertvalue %Neg zeroinitializer, ptr @vtable_225, 0
        %Exception_9_106_133_297_4825 = insertvalue %Neg %vtable_temporary_230, %Object %closure_226, 1
        call ccc void @sharePositive(%Pos %v_r_2967_30_194_4829)
        %stackPointer_273 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_2967_30_194_4829_pointer_274 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 0
        store %Pos %v_r_2967_30_194_4829, ptr %v_r_2967_30_194_4829_pointer_274, !noalias !2
        %p_8_9_4719_pointer_275 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 1
        store %Prompt %p_8_9_4719, ptr %p_8_9_4719_pointer_275, !noalias !2
        %tmp_5198_pointer_276 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 2
        store i64 %pureApp_5309, ptr %tmp_5198_pointer_276, !noalias !2
        %returnAddress_pointer_277 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 0
        %sharer_pointer_278 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 1
        %eraser_pointer_279 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 2
        store ptr @returnAddress_231, ptr %returnAddress_pointer_277, !noalias !2
        store ptr @sharer_260, ptr %sharer_pointer_278, !noalias !2
        store ptr @eraser_268, ptr %eraser_pointer_279, !noalias !2
        
        %longLiteral_5348 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2967_30_194_4829, i64 %longLiteral_5348, %Neg %Exception_9_106_133_297_4825, %Stack %stack)
        ret void
}



define ccc void @sharer_281(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_282 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4719_280_pointer_283 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_282, i64 0, i32 0
        %p_8_9_4719_280 = load %Prompt, ptr %p_8_9_4719_280_pointer_283, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_282)
        ret void
}



define ccc void @eraser_285(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_286 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4719_284_pointer_287 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_286, i64 0, i32 0
        %p_8_9_4719_284 = load %Prompt, ptr %p_8_9_4719_284_pointer_287, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_286)
        ret void
}


@utf8StringLiteral_5349.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_90(%Pos %v_r_2966_24_188_4816, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_91 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4719_pointer_92 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_91, i64 0, i32 0
        %p_8_9_4719 = load %Prompt, ptr %p_8_9_4719_pointer_92, !noalias !2
        %stackPointer_288 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4719_pointer_289 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_288, i64 0, i32 0
        store %Prompt %p_8_9_4719, ptr %p_8_9_4719_pointer_289, !noalias !2
        %returnAddress_pointer_290 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 0
        %sharer_pointer_291 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 1
        %eraser_pointer_292 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 2
        store ptr @returnAddress_93, ptr %returnAddress_pointer_290, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_291, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_292, !noalias !2
        
        %tag_293 = extractvalue %Pos %v_r_2966_24_188_4816, 0
        %fields_294 = extractvalue %Pos %v_r_2966_24_188_4816, 1
        switch i64 %tag_293, label %label_295 [i64 0, label %label_299 i64 1, label %label_305]
    
    label_295:
        
        ret void
    
    label_299:
        
        %utf8StringLiteral_5349 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5349.lit)
        
        %stackPointer_297 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_298 = getelementptr %FrameHeader, %StackPointer %stackPointer_297, i64 0, i32 0
        %returnAddress_296 = load %ReturnAddress, ptr %returnAddress_pointer_298, !noalias !2
        musttail call tailcc void %returnAddress_296(%Pos %utf8StringLiteral_5349, %Stack %stack)
        ret void
    
    label_305:
        %environment_300 = call ccc %Environment @objectEnvironment(%Object %fields_294)
        %v_y_3801_8_29_193_4837_pointer_301 = getelementptr <{%Pos}>, %Environment %environment_300, i64 0, i32 0
        %v_y_3801_8_29_193_4837 = load %Pos, ptr %v_y_3801_8_29_193_4837_pointer_301, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3801_8_29_193_4837)
        call ccc void @eraseObject(%Object %fields_294)
        
        %stackPointer_303 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_304 = getelementptr %FrameHeader, %StackPointer %stackPointer_303, i64 0, i32 0
        %returnAddress_302 = load %ReturnAddress, ptr %returnAddress_pointer_304, !noalias !2
        musttail call tailcc void %returnAddress_302(%Pos %v_y_3801_8_29_193_4837, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_87(%Pos %v_r_2965_13_177_4859, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_88 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4719_pointer_89 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_88, i64 0, i32 0
        %p_8_9_4719 = load %Prompt, ptr %p_8_9_4719_pointer_89, !noalias !2
        %stackPointer_308 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4719_pointer_309 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_308, i64 0, i32 0
        store %Prompt %p_8_9_4719, ptr %p_8_9_4719_pointer_309, !noalias !2
        %returnAddress_pointer_310 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 0
        %sharer_pointer_311 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 1
        %eraser_pointer_312 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 2
        store ptr @returnAddress_90, ptr %returnAddress_pointer_310, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_311, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_312, !noalias !2
        
        %tag_313 = extractvalue %Pos %v_r_2965_13_177_4859, 0
        %fields_314 = extractvalue %Pos %v_r_2965_13_177_4859, 1
        switch i64 %tag_313, label %label_315 [i64 0, label %label_320 i64 1, label %label_332]
    
    label_315:
        
        ret void
    
    label_320:
        
        %make_5350_temporary_316 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5350 = insertvalue %Pos %make_5350_temporary_316, %Object null, 1
        
        
        
        %stackPointer_318 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_319 = getelementptr %FrameHeader, %StackPointer %stackPointer_318, i64 0, i32 0
        %returnAddress_317 = load %ReturnAddress, ptr %returnAddress_pointer_319, !noalias !2
        musttail call tailcc void %returnAddress_317(%Pos %make_5350, %Stack %stack)
        ret void
    
    label_332:
        %environment_321 = call ccc %Environment @objectEnvironment(%Object %fields_314)
        %v_y_3310_10_21_185_4882_pointer_322 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 0
        %v_y_3310_10_21_185_4882 = load %Pos, ptr %v_y_3310_10_21_185_4882_pointer_322, !noalias !2
        %v_y_3311_11_22_186_4905_pointer_323 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 1
        %v_y_3311_11_22_186_4905 = load %Pos, ptr %v_y_3311_11_22_186_4905_pointer_323, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3310_10_21_185_4882)
        call ccc void @eraseObject(%Object %fields_314)
        
        %fields_324 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_325 = call ccc %Environment @objectEnvironment(%Object %fields_324)
        %v_y_3310_10_21_185_4882_pointer_327 = getelementptr <{%Pos}>, %Environment %environment_325, i64 0, i32 0
        store %Pos %v_y_3310_10_21_185_4882, ptr %v_y_3310_10_21_185_4882_pointer_327, !noalias !2
        %make_5351_temporary_328 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5351 = insertvalue %Pos %make_5351_temporary_328, %Object %fields_324, 1
        
        
        
        %stackPointer_330 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_331 = getelementptr %FrameHeader, %StackPointer %stackPointer_330, i64 0, i32 0
        %returnAddress_329 = load %ReturnAddress, ptr %returnAddress_pointer_331, !noalias !2
        musttail call tailcc void %returnAddress_329(%Pos %make_5351, %Stack %stack)
        ret void
}



define tailcc void @main_2862(%Stack %stack) {
        
    entry:
        
        %stackPointer_50 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_51 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 0
        %sharer_pointer_52 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 1
        %eraser_pointer_53 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_51, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_52, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_53, !noalias !2
        
        %stack_54 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4719 = call ccc %Prompt @currentPrompt(%Stack %stack_54)
        %stackPointer_64 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 24)
        %returnAddress_pointer_65 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 0
        %sharer_pointer_66 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 1
        %eraser_pointer_67 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 2
        store ptr @returnAddress_55, ptr %returnAddress_pointer_65, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_66, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_67, !noalias !2
        
        %pureApp_5305 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5307 = add i64 1, 0
        
        %pureApp_5306 = call ccc i64 @infixSub_105(i64 %pureApp_5305, i64 %longLiteral_5307)
        
        
        
        %make_5308_temporary_86 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5308 = insertvalue %Pos %make_5308_temporary_86, %Object null, 1
        
        
        %stackPointer_335 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 32)
        %p_8_9_4719_pointer_336 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_335, i64 0, i32 0
        store %Prompt %p_8_9_4719, ptr %p_8_9_4719_pointer_336, !noalias !2
        %returnAddress_pointer_337 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 0
        %sharer_pointer_338 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 1
        %eraser_pointer_339 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 2
        store ptr @returnAddress_87, ptr %returnAddress_pointer_337, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_338, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_339, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4926(i64 %pureApp_5306, %Pos %make_5308, %Stack %stack_54)
        ret void
}



define tailcc void @returnAddress_342(%Pos %returnValue_343, %Stack %stack) {
        
    entry:
        
        %stackPointer_344 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2951_4076_pointer_345 = getelementptr <{i64}>, %StackPointer %stackPointer_344, i64 0, i32 0
        %v_r_2951_4076 = load i64, ptr %v_r_2951_4076_pointer_345, !noalias !2
        %stackPointer_347 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_348 = getelementptr %FrameHeader, %StackPointer %stackPointer_347, i64 0, i32 0
        %returnAddress_346 = load %ReturnAddress, ptr %returnAddress_pointer_348, !noalias !2
        musttail call tailcc void %returnAddress_346(%Pos %returnValue_343, %Stack %stack)
        ret void
}



define ccc void @sharer_350(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_351 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2951_4076_349_pointer_352 = getelementptr <{i64}>, %StackPointer %stackPointer_351, i64 0, i32 0
        %v_r_2951_4076_349 = load i64, ptr %v_r_2951_4076_349_pointer_352, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_351)
        ret void
}



define ccc void @eraser_354(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_355 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2951_4076_353_pointer_356 = getelementptr <{i64}>, %StackPointer %stackPointer_355, i64 0, i32 0
        %v_r_2951_4076_353 = load i64, ptr %v_r_2951_4076_353_pointer_356, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_355)
        ret void
}



define tailcc void @returnAddress_363(%Pos %v_r_2962_5246, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_364 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %count_2881_pointer_365 = getelementptr <{%Reference}>, %StackPointer %stackPointer_364, i64 0, i32 0
        %count_2881 = load %Reference, ptr %count_2881_pointer_365, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2962_5246)
        
        %get_5247_pointer_366 = call ccc ptr @getVarPointer(%Reference %count_2881, %Stack %stack)
        %count_2881_old_367 = load i64, ptr %get_5247_pointer_366, !noalias !2
        %get_5247 = load i64, ptr %get_5247_pointer_366, !noalias !2
        
        %stackPointer_369 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_370 = getelementptr %FrameHeader, %StackPointer %stackPointer_369, i64 0, i32 0
        %returnAddress_368 = load %ReturnAddress, ptr %returnAddress_pointer_370, !noalias !2
        musttail call tailcc void %returnAddress_368(i64 %get_5247, %Stack %stack)
        ret void
}



define ccc void @sharer_372(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_373 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %count_2881_371_pointer_374 = getelementptr <{%Reference}>, %StackPointer %stackPointer_373, i64 0, i32 0
        %count_2881_371 = load %Reference, ptr %count_2881_371_pointer_374, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_373)
        ret void
}



define ccc void @eraser_376(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_377 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %count_2881_375_pointer_378 = getelementptr <{%Reference}>, %StackPointer %stackPointer_377, i64 0, i32 0
        %count_2881_375 = load %Reference, ptr %count_2881_375_pointer_378, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_377)
        ret void
}



define tailcc void @returnAddress_384(%Pos %returnValue_385, %Stack %stack) {
        
    entry:
        
        %stackPointer_386 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2944_4_4353_pointer_387 = getelementptr <{i64}>, %StackPointer %stackPointer_386, i64 0, i32 0
        %v_r_2944_4_4353 = load i64, ptr %v_r_2944_4_4353_pointer_387, !noalias !2
        %stackPointer_389 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_390 = getelementptr %FrameHeader, %StackPointer %stackPointer_389, i64 0, i32 0
        %returnAddress_388 = load %ReturnAddress, ptr %returnAddress_pointer_390, !noalias !2
        musttail call tailcc void %returnAddress_388(%Pos %returnValue_385, %Stack %stack)
        ret void
}



define ccc void @eraser_440(%Environment %environment) {
        
    entry:
        
        %v_r_2956_16_15_4365_436_pointer_441 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %v_r_2956_16_15_4365_436 = load %Pos, ptr %v_r_2956_16_15_4365_436_pointer_441, !noalias !2
        %v_r_2957_18_17_4377_437_pointer_442 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %v_r_2957_18_17_4377_437 = load %Pos, ptr %v_r_2957_18_17_4377_437_pointer_442, !noalias !2
        %v_r_2958_20_19_4372_438_pointer_443 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment, i64 0, i32 2
        %v_r_2958_20_19_4372_438 = load %Pos, ptr %v_r_2958_20_19_4372_438_pointer_443, !noalias !2
        %v_r_2959_22_21_4364_439_pointer_444 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment, i64 0, i32 3
        %v_r_2959_22_21_4364_439 = load %Pos, ptr %v_r_2959_22_21_4364_439_pointer_444, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2956_16_15_4365_436)
        call ccc void @erasePositive(%Pos %v_r_2957_18_17_4377_437)
        call ccc void @erasePositive(%Pos %v_r_2958_20_19_4372_438)
        call ccc void @erasePositive(%Pos %v_r_2959_22_21_4364_439)
        ret void
}



define tailcc void @returnAddress_429(%Pos %v_r_2959_22_21_4364, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_430 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %v_r_2956_16_15_4365_pointer_431 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_430, i64 0, i32 0
        %v_r_2956_16_15_4365 = load %Pos, ptr %v_r_2956_16_15_4365_pointer_431, !noalias !2
        %v_r_2957_18_17_4377_pointer_432 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_430, i64 0, i32 1
        %v_r_2957_18_17_4377 = load %Pos, ptr %v_r_2957_18_17_4377_pointer_432, !noalias !2
        %v_r_2958_20_19_4372_pointer_433 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_430, i64 0, i32 2
        %v_r_2958_20_19_4372 = load %Pos, ptr %v_r_2958_20_19_4372_pointer_433, !noalias !2
        
        %fields_434 = call ccc %Object @newObject(ptr @eraser_440, i64 64)
        %environment_435 = call ccc %Environment @objectEnvironment(%Object %fields_434)
        %v_r_2956_16_15_4365_pointer_445 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_435, i64 0, i32 0
        store %Pos %v_r_2956_16_15_4365, ptr %v_r_2956_16_15_4365_pointer_445, !noalias !2
        %v_r_2957_18_17_4377_pointer_446 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_435, i64 0, i32 1
        store %Pos %v_r_2957_18_17_4377, ptr %v_r_2957_18_17_4377_pointer_446, !noalias !2
        %v_r_2958_20_19_4372_pointer_447 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_435, i64 0, i32 2
        store %Pos %v_r_2958_20_19_4372, ptr %v_r_2958_20_19_4372_pointer_447, !noalias !2
        %v_r_2959_22_21_4364_pointer_448 = getelementptr <{%Pos, %Pos, %Pos, %Pos}>, %Environment %environment_435, i64 0, i32 3
        store %Pos %v_r_2959_22_21_4364, ptr %v_r_2959_22_21_4364_pointer_448, !noalias !2
        %make_5263_temporary_449 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5263 = insertvalue %Pos %make_5263_temporary_449, %Object %fields_434, 1
        
        
        
        %stackPointer_451 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_452 = getelementptr %FrameHeader, %StackPointer %stackPointer_451, i64 0, i32 0
        %returnAddress_450 = load %ReturnAddress, ptr %returnAddress_pointer_452, !noalias !2
        musttail call tailcc void %returnAddress_450(%Pos %make_5263, %Stack %stack)
        ret void
}



define ccc void @sharer_456(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_457 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2956_16_15_4365_453_pointer_458 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_457, i64 0, i32 0
        %v_r_2956_16_15_4365_453 = load %Pos, ptr %v_r_2956_16_15_4365_453_pointer_458, !noalias !2
        %v_r_2957_18_17_4377_454_pointer_459 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_457, i64 0, i32 1
        %v_r_2957_18_17_4377_454 = load %Pos, ptr %v_r_2957_18_17_4377_454_pointer_459, !noalias !2
        %v_r_2958_20_19_4372_455_pointer_460 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_457, i64 0, i32 2
        %v_r_2958_20_19_4372_455 = load %Pos, ptr %v_r_2958_20_19_4372_455_pointer_460, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2956_16_15_4365_453)
        call ccc void @sharePositive(%Pos %v_r_2957_18_17_4377_454)
        call ccc void @sharePositive(%Pos %v_r_2958_20_19_4372_455)
        call ccc void @shareFrames(%StackPointer %stackPointer_457)
        ret void
}



define ccc void @eraser_464(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_465 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2956_16_15_4365_461_pointer_466 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_465, i64 0, i32 0
        %v_r_2956_16_15_4365_461 = load %Pos, ptr %v_r_2956_16_15_4365_461_pointer_466, !noalias !2
        %v_r_2957_18_17_4377_462_pointer_467 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_465, i64 0, i32 1
        %v_r_2957_18_17_4377_462 = load %Pos, ptr %v_r_2957_18_17_4377_462_pointer_467, !noalias !2
        %v_r_2958_20_19_4372_463_pointer_468 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_465, i64 0, i32 2
        %v_r_2958_20_19_4372_463 = load %Pos, ptr %v_r_2958_20_19_4372_463_pointer_468, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2956_16_15_4365_461)
        call ccc void @erasePositive(%Pos %v_r_2957_18_17_4377_462)
        call ccc void @erasePositive(%Pos %v_r_2958_20_19_4372_463)
        call ccc void @eraseFrames(%StackPointer %stackPointer_465)
        ret void
}



define tailcc void @returnAddress_422(%Pos %v_r_2958_20_19_4372, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_423 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 72)
        %v_r_2956_16_15_4365_pointer_424 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_423, i64 0, i32 0
        %v_r_2956_16_15_4365 = load %Pos, ptr %v_r_2956_16_15_4365_pointer_424, !noalias !2
        %seed_5_4357_pointer_425 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_423, i64 0, i32 1
        %seed_5_4357 = load %Reference, ptr %seed_5_4357_pointer_425, !noalias !2
        %depth_5_4_4366_pointer_426 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_423, i64 0, i32 2
        %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_426, !noalias !2
        %count_2881_pointer_427 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_423, i64 0, i32 3
        %count_2881 = load %Reference, ptr %count_2881_pointer_427, !noalias !2
        %v_r_2957_18_17_4377_pointer_428 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_423, i64 0, i32 4
        %v_r_2957_18_17_4377 = load %Pos, ptr %v_r_2957_18_17_4377_pointer_428, !noalias !2
        
        %longLiteral_5262 = add i64 1, 0
        
        %pureApp_5261 = call ccc i64 @infixSub_105(i64 %depth_5_4_4366, i64 %longLiteral_5262)
        
        
        %stackPointer_469 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %v_r_2956_16_15_4365_pointer_470 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_469, i64 0, i32 0
        store %Pos %v_r_2956_16_15_4365, ptr %v_r_2956_16_15_4365_pointer_470, !noalias !2
        %v_r_2957_18_17_4377_pointer_471 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_469, i64 0, i32 1
        store %Pos %v_r_2957_18_17_4377, ptr %v_r_2957_18_17_4377_pointer_471, !noalias !2
        %v_r_2958_20_19_4372_pointer_472 = getelementptr <{%Pos, %Pos, %Pos}>, %StackPointer %stackPointer_469, i64 0, i32 2
        store %Pos %v_r_2958_20_19_4372, ptr %v_r_2958_20_19_4372_pointer_472, !noalias !2
        %returnAddress_pointer_473 = getelementptr <{<{%Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_469, i64 0, i32 1, i32 0
        %sharer_pointer_474 = getelementptr <{<{%Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_469, i64 0, i32 1, i32 1
        %eraser_pointer_475 = getelementptr <{<{%Pos, %Pos, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_469, i64 0, i32 1, i32 2
        store ptr @returnAddress_429, ptr %returnAddress_pointer_473, !noalias !2
        store ptr @sharer_456, ptr %sharer_pointer_474, !noalias !2
        store ptr @eraser_464, ptr %eraser_pointer_475, !noalias !2
        
        
        
        musttail call tailcc void @buildTreeDepth_worker_4_3_4373(i64 %pureApp_5261, %Reference %seed_5_4357, %Reference %count_2881, %Stack %stack)
        ret void
}



define ccc void @sharer_481(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_482 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2956_16_15_4365_476_pointer_483 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_482, i64 0, i32 0
        %v_r_2956_16_15_4365_476 = load %Pos, ptr %v_r_2956_16_15_4365_476_pointer_483, !noalias !2
        %seed_5_4357_477_pointer_484 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_482, i64 0, i32 1
        %seed_5_4357_477 = load %Reference, ptr %seed_5_4357_477_pointer_484, !noalias !2
        %depth_5_4_4366_478_pointer_485 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_482, i64 0, i32 2
        %depth_5_4_4366_478 = load i64, ptr %depth_5_4_4366_478_pointer_485, !noalias !2
        %count_2881_479_pointer_486 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_482, i64 0, i32 3
        %count_2881_479 = load %Reference, ptr %count_2881_479_pointer_486, !noalias !2
        %v_r_2957_18_17_4377_480_pointer_487 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_482, i64 0, i32 4
        %v_r_2957_18_17_4377_480 = load %Pos, ptr %v_r_2957_18_17_4377_480_pointer_487, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2956_16_15_4365_476)
        call ccc void @sharePositive(%Pos %v_r_2957_18_17_4377_480)
        call ccc void @shareFrames(%StackPointer %stackPointer_482)
        ret void
}



define ccc void @eraser_493(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_494 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2956_16_15_4365_488_pointer_495 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_494, i64 0, i32 0
        %v_r_2956_16_15_4365_488 = load %Pos, ptr %v_r_2956_16_15_4365_488_pointer_495, !noalias !2
        %seed_5_4357_489_pointer_496 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_494, i64 0, i32 1
        %seed_5_4357_489 = load %Reference, ptr %seed_5_4357_489_pointer_496, !noalias !2
        %depth_5_4_4366_490_pointer_497 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_494, i64 0, i32 2
        %depth_5_4_4366_490 = load i64, ptr %depth_5_4_4366_490_pointer_497, !noalias !2
        %count_2881_491_pointer_498 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_494, i64 0, i32 3
        %count_2881_491 = load %Reference, ptr %count_2881_491_pointer_498, !noalias !2
        %v_r_2957_18_17_4377_492_pointer_499 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_494, i64 0, i32 4
        %v_r_2957_18_17_4377_492 = load %Pos, ptr %v_r_2957_18_17_4377_492_pointer_499, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2956_16_15_4365_488)
        call ccc void @erasePositive(%Pos %v_r_2957_18_17_4377_492)
        call ccc void @eraseFrames(%StackPointer %stackPointer_494)
        ret void
}



define tailcc void @returnAddress_416(%Pos %v_r_2957_18_17_4377, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_417 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %v_r_2956_16_15_4365_pointer_418 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_417, i64 0, i32 0
        %v_r_2956_16_15_4365 = load %Pos, ptr %v_r_2956_16_15_4365_pointer_418, !noalias !2
        %seed_5_4357_pointer_419 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_417, i64 0, i32 1
        %seed_5_4357 = load %Reference, ptr %seed_5_4357_pointer_419, !noalias !2
        %depth_5_4_4366_pointer_420 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_417, i64 0, i32 2
        %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_420, !noalias !2
        %count_2881_pointer_421 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_417, i64 0, i32 3
        %count_2881 = load %Reference, ptr %count_2881_pointer_421, !noalias !2
        
        %longLiteral_5260 = add i64 1, 0
        
        %pureApp_5259 = call ccc i64 @infixSub_105(i64 %depth_5_4_4366, i64 %longLiteral_5260)
        
        
        %stackPointer_500 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 96)
        %v_r_2956_16_15_4365_pointer_501 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_500, i64 0, i32 0
        store %Pos %v_r_2956_16_15_4365, ptr %v_r_2956_16_15_4365_pointer_501, !noalias !2
        %seed_5_4357_pointer_502 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_500, i64 0, i32 1
        store %Reference %seed_5_4357, ptr %seed_5_4357_pointer_502, !noalias !2
        %depth_5_4_4366_pointer_503 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_500, i64 0, i32 2
        store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_503, !noalias !2
        %count_2881_pointer_504 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_500, i64 0, i32 3
        store %Reference %count_2881, ptr %count_2881_pointer_504, !noalias !2
        %v_r_2957_18_17_4377_pointer_505 = getelementptr <{%Pos, %Reference, i64, %Reference, %Pos}>, %StackPointer %stackPointer_500, i64 0, i32 4
        store %Pos %v_r_2957_18_17_4377, ptr %v_r_2957_18_17_4377_pointer_505, !noalias !2
        %returnAddress_pointer_506 = getelementptr <{<{%Pos, %Reference, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_500, i64 0, i32 1, i32 0
        %sharer_pointer_507 = getelementptr <{<{%Pos, %Reference, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_500, i64 0, i32 1, i32 1
        %eraser_pointer_508 = getelementptr <{<{%Pos, %Reference, i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_500, i64 0, i32 1, i32 2
        store ptr @returnAddress_422, ptr %returnAddress_pointer_506, !noalias !2
        store ptr @sharer_481, ptr %sharer_pointer_507, !noalias !2
        store ptr @eraser_493, ptr %eraser_pointer_508, !noalias !2
        
        
        
        musttail call tailcc void @buildTreeDepth_worker_4_3_4373(i64 %pureApp_5259, %Reference %seed_5_4357, %Reference %count_2881, %Stack %stack)
        ret void
}



define ccc void @sharer_513(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_514 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_r_2956_16_15_4365_509_pointer_515 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_514, i64 0, i32 0
        %v_r_2956_16_15_4365_509 = load %Pos, ptr %v_r_2956_16_15_4365_509_pointer_515, !noalias !2
        %seed_5_4357_510_pointer_516 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_514, i64 0, i32 1
        %seed_5_4357_510 = load %Reference, ptr %seed_5_4357_510_pointer_516, !noalias !2
        %depth_5_4_4366_511_pointer_517 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_514, i64 0, i32 2
        %depth_5_4_4366_511 = load i64, ptr %depth_5_4_4366_511_pointer_517, !noalias !2
        %count_2881_512_pointer_518 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_514, i64 0, i32 3
        %count_2881_512 = load %Reference, ptr %count_2881_512_pointer_518, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2956_16_15_4365_509)
        call ccc void @shareFrames(%StackPointer %stackPointer_514)
        ret void
}



define ccc void @eraser_523(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_524 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_r_2956_16_15_4365_519_pointer_525 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_524, i64 0, i32 0
        %v_r_2956_16_15_4365_519 = load %Pos, ptr %v_r_2956_16_15_4365_519_pointer_525, !noalias !2
        %seed_5_4357_520_pointer_526 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_524, i64 0, i32 1
        %seed_5_4357_520 = load %Reference, ptr %seed_5_4357_520_pointer_526, !noalias !2
        %depth_5_4_4366_521_pointer_527 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_524, i64 0, i32 2
        %depth_5_4_4366_521 = load i64, ptr %depth_5_4_4366_521_pointer_527, !noalias !2
        %count_2881_522_pointer_528 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_524, i64 0, i32 3
        %count_2881_522 = load %Reference, ptr %count_2881_522_pointer_528, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2956_16_15_4365_519)
        call ccc void @eraseFrames(%StackPointer %stackPointer_524)
        ret void
}



define tailcc void @returnAddress_411(%Pos %v_r_2956_16_15_4365, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_412 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %seed_5_4357_pointer_413 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_412, i64 0, i32 0
        %seed_5_4357 = load %Reference, ptr %seed_5_4357_pointer_413, !noalias !2
        %depth_5_4_4366_pointer_414 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_412, i64 0, i32 1
        %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_414, !noalias !2
        %count_2881_pointer_415 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_412, i64 0, i32 2
        %count_2881 = load %Reference, ptr %count_2881_pointer_415, !noalias !2
        
        %longLiteral_5258 = add i64 1, 0
        
        %pureApp_5257 = call ccc i64 @infixSub_105(i64 %depth_5_4_4366, i64 %longLiteral_5258)
        
        
        %stackPointer_529 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %v_r_2956_16_15_4365_pointer_530 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_529, i64 0, i32 0
        store %Pos %v_r_2956_16_15_4365, ptr %v_r_2956_16_15_4365_pointer_530, !noalias !2
        %seed_5_4357_pointer_531 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_529, i64 0, i32 1
        store %Reference %seed_5_4357, ptr %seed_5_4357_pointer_531, !noalias !2
        %depth_5_4_4366_pointer_532 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_529, i64 0, i32 2
        store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_532, !noalias !2
        %count_2881_pointer_533 = getelementptr <{%Pos, %Reference, i64, %Reference}>, %StackPointer %stackPointer_529, i64 0, i32 3
        store %Reference %count_2881, ptr %count_2881_pointer_533, !noalias !2
        %returnAddress_pointer_534 = getelementptr <{<{%Pos, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_529, i64 0, i32 1, i32 0
        %sharer_pointer_535 = getelementptr <{<{%Pos, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_529, i64 0, i32 1, i32 1
        %eraser_pointer_536 = getelementptr <{<{%Pos, %Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_529, i64 0, i32 1, i32 2
        store ptr @returnAddress_416, ptr %returnAddress_pointer_534, !noalias !2
        store ptr @sharer_513, ptr %sharer_pointer_535, !noalias !2
        store ptr @eraser_523, ptr %eraser_pointer_536, !noalias !2
        
        
        
        musttail call tailcc void @buildTreeDepth_worker_4_3_4373(i64 %pureApp_5257, %Reference %seed_5_4357, %Reference %count_2881, %Stack %stack)
        ret void
}



define ccc void @sharer_540(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_541 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %seed_5_4357_537_pointer_542 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_541, i64 0, i32 0
        %seed_5_4357_537 = load %Reference, ptr %seed_5_4357_537_pointer_542, !noalias !2
        %depth_5_4_4366_538_pointer_543 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_541, i64 0, i32 1
        %depth_5_4_4366_538 = load i64, ptr %depth_5_4_4366_538_pointer_543, !noalias !2
        %count_2881_539_pointer_544 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_541, i64 0, i32 2
        %count_2881_539 = load %Reference, ptr %count_2881_539_pointer_544, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_541)
        ret void
}



define ccc void @eraser_548(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_549 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %seed_5_4357_545_pointer_550 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_549, i64 0, i32 0
        %seed_5_4357_545 = load %Reference, ptr %seed_5_4357_545_pointer_550, !noalias !2
        %depth_5_4_4366_546_pointer_551 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_549, i64 0, i32 1
        %depth_5_4_4366_546 = load i64, ptr %depth_5_4_4366_546_pointer_551, !noalias !2
        %count_2881_547_pointer_552 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_549, i64 0, i32 2
        %count_2881_547 = load %Reference, ptr %count_2881_547_pointer_552, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_549)
        ret void
}



define tailcc void @returnAddress_567(i64 %v_r_2954_10_9_4361, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5273 = add i64 10, 0
        
        %pureApp_5272 = call ccc i64 @mod_108(i64 %v_r_2954_10_9_4361, i64 %longLiteral_5273)
        
        
        
        %longLiteral_5275 = add i64 1, 0
        
        %pureApp_5274 = call ccc i64 @infixAdd_96(i64 %pureApp_5272, i64 %longLiteral_5275)
        
        
        
        %pureApp_5276 = call ccc %Pos @allocate_2473(i64 %pureApp_5274)
        
        
        
        %fields_568 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_569 = call ccc %Environment @objectEnvironment(%Object %fields_568)
        %tmp_5184_pointer_571 = getelementptr <{%Pos}>, %Environment %environment_569, i64 0, i32 0
        store %Pos %pureApp_5276, ptr %tmp_5184_pointer_571, !noalias !2
        %make_5277_temporary_572 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5277 = insertvalue %Pos %make_5277_temporary_572, %Object %fields_568, 1
        
        
        
        %stackPointer_574 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_575 = getelementptr %FrameHeader, %StackPointer %stackPointer_574, i64 0, i32 0
        %returnAddress_573 = load %ReturnAddress, ptr %returnAddress_pointer_575, !noalias !2
        musttail call tailcc void %returnAddress_573(%Pos %make_5277, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_564(%Pos %__13_7_5249, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_565 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %seed_5_4357_pointer_566 = getelementptr <{%Reference}>, %StackPointer %stackPointer_565, i64 0, i32 0
        %seed_5_4357 = load %Reference, ptr %seed_5_4357_pointer_566, !noalias !2
        call ccc void @erasePositive(%Pos %__13_7_5249)
        %stackPointer_576 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_577 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_576, i64 0, i32 1, i32 0
        %sharer_pointer_578 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_576, i64 0, i32 1, i32 1
        %eraser_pointer_579 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_576, i64 0, i32 1, i32 2
        store ptr @returnAddress_567, ptr %returnAddress_pointer_577, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_578, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_579, !noalias !2
        
        %get_5278_pointer_580 = call ccc ptr @getVarPointer(%Reference %seed_5_4357, %Stack %stack)
        %seed_5_4357_old_581 = load i64, ptr %get_5278_pointer_580, !noalias !2
        %get_5278 = load i64, ptr %get_5278_pointer_580, !noalias !2
        
        %stackPointer_583 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_584 = getelementptr %FrameHeader, %StackPointer %stackPointer_583, i64 0, i32 0
        %returnAddress_582 = load %ReturnAddress, ptr %returnAddress_pointer_584, !noalias !2
        musttail call tailcc void %returnAddress_582(i64 %get_5278, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_561(i64 %v_r_2946_7_1_4385, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_562 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %seed_5_4357_pointer_563 = getelementptr <{%Reference}>, %StackPointer %stackPointer_562, i64 0, i32 0
        %seed_5_4357 = load %Reference, ptr %seed_5_4357_pointer_563, !noalias !2
        
        %longLiteral_5265 = add i64 1309, 0
        
        %pureApp_5264 = call ccc i64 @infixMul_99(i64 %v_r_2946_7_1_4385, i64 %longLiteral_5265)
        
        
        
        %longLiteral_5267 = add i64 13849, 0
        
        %pureApp_5266 = call ccc i64 @infixAdd_96(i64 %pureApp_5264, i64 %longLiteral_5267)
        
        
        
        %longLiteral_5269 = add i64 65535, 0
        
        %longLiteral_5270 = add i64 1, 0
        
        %pureApp_5268 = call ccc i64 @infixAdd_96(i64 %longLiteral_5269, i64 %longLiteral_5270)
        
        
        
        %pureApp_5271 = call ccc i64 @mod_108(i64 %pureApp_5266, i64 %pureApp_5268)
        
        
        %stackPointer_587 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %seed_5_4357_pointer_588 = getelementptr <{%Reference}>, %StackPointer %stackPointer_587, i64 0, i32 0
        store %Reference %seed_5_4357, ptr %seed_5_4357_pointer_588, !noalias !2
        %returnAddress_pointer_589 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_587, i64 0, i32 1, i32 0
        %sharer_pointer_590 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_587, i64 0, i32 1, i32 1
        %eraser_pointer_591 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_587, i64 0, i32 1, i32 2
        store ptr @returnAddress_564, ptr %returnAddress_pointer_589, !noalias !2
        store ptr @sharer_372, ptr %sharer_pointer_590, !noalias !2
        store ptr @eraser_376, ptr %eraser_pointer_591, !noalias !2
        
        %seed_5_4357pointer_592 = call ccc ptr @getVarPointer(%Reference %seed_5_4357, %Stack %stack)
        %seed_5_4357_old_593 = load i64, ptr %seed_5_4357pointer_592, !noalias !2
        store i64 %pureApp_5271, ptr %seed_5_4357pointer_592, !noalias !2
        
        %put_5279_temporary_594 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5279 = insertvalue %Pos %put_5279_temporary_594, %Object null, 1
        
        %stackPointer_596 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_597 = getelementptr %FrameHeader, %StackPointer %stackPointer_596, i64 0, i32 0
        %returnAddress_595 = load %ReturnAddress, ptr %returnAddress_pointer_597, !noalias !2
        musttail call tailcc void %returnAddress_595(%Pos %put_5279, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_403(%Pos %v_r_2953_8_7_5250, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_404 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %depth_5_4_4366_pointer_405 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_404, i64 0, i32 0
        %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_405, !noalias !2
        %seed_5_4357_pointer_406 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_404, i64 0, i32 1
        %seed_5_4357 = load %Reference, ptr %seed_5_4357_pointer_406, !noalias !2
        %count_2881_pointer_407 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_404, i64 0, i32 2
        %count_2881 = load %Reference, ptr %count_2881_pointer_407, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2953_8_7_5250)
        
        %longLiteral_5254 = add i64 1, 0
        
        %pureApp_5253 = call ccc %Pos @infixEq_72(i64 %depth_5_4_4366, i64 %longLiteral_5254)
        
        
        
        %tag_408 = extractvalue %Pos %pureApp_5253, 0
        %fields_409 = extractvalue %Pos %pureApp_5253, 1
        switch i64 %tag_408, label %label_410 [i64 0, label %label_560 i64 1, label %label_610]
    
    label_410:
        
        ret void
    
    label_560:
        
        %longLiteral_5256 = add i64 1, 0
        
        %pureApp_5255 = call ccc i64 @infixSub_105(i64 %depth_5_4_4366, i64 %longLiteral_5256)
        
        
        %stackPointer_553 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %seed_5_4357_pointer_554 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_553, i64 0, i32 0
        store %Reference %seed_5_4357, ptr %seed_5_4357_pointer_554, !noalias !2
        %depth_5_4_4366_pointer_555 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_553, i64 0, i32 1
        store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_555, !noalias !2
        %count_2881_pointer_556 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_553, i64 0, i32 2
        store %Reference %count_2881, ptr %count_2881_pointer_556, !noalias !2
        %returnAddress_pointer_557 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_553, i64 0, i32 1, i32 0
        %sharer_pointer_558 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_553, i64 0, i32 1, i32 1
        %eraser_pointer_559 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_553, i64 0, i32 1, i32 2
        store ptr @returnAddress_411, ptr %returnAddress_pointer_557, !noalias !2
        store ptr @sharer_540, ptr %sharer_pointer_558, !noalias !2
        store ptr @eraser_548, ptr %eraser_pointer_559, !noalias !2
        
        
        
        musttail call tailcc void @buildTreeDepth_worker_4_3_4373(i64 %pureApp_5255, %Reference %seed_5_4357, %Reference %count_2881, %Stack %stack)
        ret void
    
    label_610:
        %stackPointer_600 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %seed_5_4357_pointer_601 = getelementptr <{%Reference}>, %StackPointer %stackPointer_600, i64 0, i32 0
        store %Reference %seed_5_4357, ptr %seed_5_4357_pointer_601, !noalias !2
        %returnAddress_pointer_602 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_600, i64 0, i32 1, i32 0
        %sharer_pointer_603 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_600, i64 0, i32 1, i32 1
        %eraser_pointer_604 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_600, i64 0, i32 1, i32 2
        store ptr @returnAddress_561, ptr %returnAddress_pointer_602, !noalias !2
        store ptr @sharer_372, ptr %sharer_pointer_603, !noalias !2
        store ptr @eraser_376, ptr %eraser_pointer_604, !noalias !2
        
        %get_5280_pointer_605 = call ccc ptr @getVarPointer(%Reference %seed_5_4357, %Stack %stack)
        %seed_5_4357_old_606 = load i64, ptr %get_5280_pointer_605, !noalias !2
        %get_5280 = load i64, ptr %get_5280_pointer_605, !noalias !2
        
        %stackPointer_608 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_609 = getelementptr %FrameHeader, %StackPointer %stackPointer_608, i64 0, i32 0
        %returnAddress_607 = load %ReturnAddress, ptr %returnAddress_pointer_609, !noalias !2
        musttail call tailcc void %returnAddress_607(i64 %get_5280, %Stack %stack)
        ret void
}



define ccc void @sharer_614(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_615 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %depth_5_4_4366_611_pointer_616 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_615, i64 0, i32 0
        %depth_5_4_4366_611 = load i64, ptr %depth_5_4_4366_611_pointer_616, !noalias !2
        %seed_5_4357_612_pointer_617 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_615, i64 0, i32 1
        %seed_5_4357_612 = load %Reference, ptr %seed_5_4357_612_pointer_617, !noalias !2
        %count_2881_613_pointer_618 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_615, i64 0, i32 2
        %count_2881_613 = load %Reference, ptr %count_2881_613_pointer_618, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_615)
        ret void
}



define ccc void @eraser_622(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_623 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %depth_5_4_4366_619_pointer_624 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_623, i64 0, i32 0
        %depth_5_4_4366_619 = load i64, ptr %depth_5_4_4366_619_pointer_624, !noalias !2
        %seed_5_4357_620_pointer_625 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_623, i64 0, i32 1
        %seed_5_4357_620 = load %Reference, ptr %seed_5_4357_620_pointer_625, !noalias !2
        %count_2881_621_pointer_626 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_623, i64 0, i32 2
        %count_2881_621 = load %Reference, ptr %count_2881_621_pointer_626, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_623)
        ret void
}



define tailcc void @returnAddress_398(i64 %v_r_2952_6_5_4362, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_399 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %seed_5_4357_pointer_400 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_399, i64 0, i32 0
        %seed_5_4357 = load %Reference, ptr %seed_5_4357_pointer_400, !noalias !2
        %depth_5_4_4366_pointer_401 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_399, i64 0, i32 1
        %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_401, !noalias !2
        %count_2881_pointer_402 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_399, i64 0, i32 2
        %count_2881 = load %Reference, ptr %count_2881_pointer_402, !noalias !2
        
        %longLiteral_5252 = add i64 1, 0
        
        %pureApp_5251 = call ccc i64 @infixAdd_96(i64 %v_r_2952_6_5_4362, i64 %longLiteral_5252)
        
        
        %stackPointer_627 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %depth_5_4_4366_pointer_628 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_627, i64 0, i32 0
        store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_628, !noalias !2
        %seed_5_4357_pointer_629 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_627, i64 0, i32 1
        store %Reference %seed_5_4357, ptr %seed_5_4357_pointer_629, !noalias !2
        %count_2881_pointer_630 = getelementptr <{i64, %Reference, %Reference}>, %StackPointer %stackPointer_627, i64 0, i32 2
        store %Reference %count_2881, ptr %count_2881_pointer_630, !noalias !2
        %returnAddress_pointer_631 = getelementptr <{<{i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_627, i64 0, i32 1, i32 0
        %sharer_pointer_632 = getelementptr <{<{i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_627, i64 0, i32 1, i32 1
        %eraser_pointer_633 = getelementptr <{<{i64, %Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_627, i64 0, i32 1, i32 2
        store ptr @returnAddress_403, ptr %returnAddress_pointer_631, !noalias !2
        store ptr @sharer_614, ptr %sharer_pointer_632, !noalias !2
        store ptr @eraser_622, ptr %eraser_pointer_633, !noalias !2
        
        %count_2881pointer_634 = call ccc ptr @getVarPointer(%Reference %count_2881, %Stack %stack)
        %count_2881_old_635 = load i64, ptr %count_2881pointer_634, !noalias !2
        store i64 %pureApp_5251, ptr %count_2881pointer_634, !noalias !2
        
        %put_5281_temporary_636 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5281 = insertvalue %Pos %put_5281_temporary_636, %Object null, 1
        
        %stackPointer_638 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_639 = getelementptr %FrameHeader, %StackPointer %stackPointer_638, i64 0, i32 0
        %returnAddress_637 = load %ReturnAddress, ptr %returnAddress_pointer_639, !noalias !2
        musttail call tailcc void %returnAddress_637(%Pos %put_5281, %Stack %stack)
        ret void
}



define tailcc void @buildTreeDepth_worker_4_3_4373(i64 %depth_5_4_4366, %Reference %seed_5_4357, %Reference %count_2881, %Stack %stack) {
        
    entry:
        
        %stackPointer_646 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %seed_5_4357_pointer_647 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_646, i64 0, i32 0
        store %Reference %seed_5_4357, ptr %seed_5_4357_pointer_647, !noalias !2
        %depth_5_4_4366_pointer_648 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_646, i64 0, i32 1
        store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_648, !noalias !2
        %count_2881_pointer_649 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_646, i64 0, i32 2
        store %Reference %count_2881, ptr %count_2881_pointer_649, !noalias !2
        %returnAddress_pointer_650 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_646, i64 0, i32 1, i32 0
        %sharer_pointer_651 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_646, i64 0, i32 1, i32 1
        %eraser_pointer_652 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_646, i64 0, i32 1, i32 2
        store ptr @returnAddress_398, ptr %returnAddress_pointer_650, !noalias !2
        store ptr @sharer_540, ptr %sharer_pointer_651, !noalias !2
        store ptr @eraser_548, ptr %eraser_pointer_652, !noalias !2
        
        %get_5282_pointer_653 = call ccc ptr @getVarPointer(%Reference %count_2881, %Stack %stack)
        %count_2881_old_654 = load i64, ptr %get_5282_pointer_653, !noalias !2
        %get_5282 = load i64, ptr %get_5282_pointer_653, !noalias !2
        
        %stackPointer_656 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_657 = getelementptr %FrameHeader, %StackPointer %stackPointer_656, i64 0, i32 0
        %returnAddress_655 = load %ReturnAddress, ptr %returnAddress_pointer_657, !noalias !2
        musttail call tailcc void %returnAddress_655(i64 %get_5282, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_658(%Pos %__23_5283, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %__23_5283)
        
        %unitLiteral_5284_temporary_659 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5284 = insertvalue %Pos %unitLiteral_5284_temporary_659, %Object null, 1
        
        %stackPointer_661 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_662 = getelementptr %FrameHeader, %StackPointer %stackPointer_661, i64 0, i32 0
        %returnAddress_660 = load %ReturnAddress, ptr %returnAddress_pointer_662, !noalias !2
        musttail call tailcc void %returnAddress_660(%Pos %unitLiteral_5284, %Stack %stack)
        ret void
}



define tailcc void @run_2861(i64 %n_2860, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5243 = add i64 0, 0
        
        
        
        %pair_340 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, ptr @global)
        %temporaryStack_5244 = extractvalue <{%Resumption, %Stack}> %pair_340, 0
        %stack_341 = extractvalue <{%Resumption, %Stack}> %pair_340, 1
        %count_2881 = call ccc %Reference @newReference(%Stack %stack_341)
        %stackPointer_357 = call ccc %StackPointer @stackAllocate(%Stack %stack_341, i64 32)
        %v_r_2951_4076_pointer_358 = getelementptr <{i64}>, %StackPointer %stackPointer_357, i64 0, i32 0
        store i64 %longLiteral_5243, ptr %v_r_2951_4076_pointer_358, !noalias !2
        %returnAddress_pointer_359 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_357, i64 0, i32 1, i32 0
        %sharer_pointer_360 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_357, i64 0, i32 1, i32 1
        %eraser_pointer_361 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_357, i64 0, i32 1, i32 2
        store ptr @returnAddress_342, ptr %returnAddress_pointer_359, !noalias !2
        store ptr @sharer_350, ptr %sharer_pointer_360, !noalias !2
        store ptr @eraser_354, ptr %eraser_pointer_361, !noalias !2
        
        %stack_362 = call ccc %Stack @resume(%Resumption %temporaryStack_5244, %Stack %stack_341)
        
        %longLiteral_5245 = add i64 74755, 0
        
        
        %stackPointer_379 = call ccc %StackPointer @stackAllocate(%Stack %stack_362, i64 40)
        %count_2881_pointer_380 = getelementptr <{%Reference}>, %StackPointer %stackPointer_379, i64 0, i32 0
        store %Reference %count_2881, ptr %count_2881_pointer_380, !noalias !2
        %returnAddress_pointer_381 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_379, i64 0, i32 1, i32 0
        %sharer_pointer_382 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_379, i64 0, i32 1, i32 1
        %eraser_pointer_383 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_379, i64 0, i32 1, i32 2
        store ptr @returnAddress_363, ptr %returnAddress_pointer_381, !noalias !2
        store ptr @sharer_372, ptr %sharer_pointer_382, !noalias !2
        store ptr @eraser_376, ptr %eraser_pointer_383, !noalias !2
        %seed_5_4357 = call ccc %Reference @newReference(%Stack %stack_362)
        %stackPointer_393 = call ccc %StackPointer @stackAllocate(%Stack %stack_362, i64 32)
        %v_r_2944_4_4353_pointer_394 = getelementptr <{i64}>, %StackPointer %stackPointer_393, i64 0, i32 0
        store i64 %longLiteral_5245, ptr %v_r_2944_4_4353_pointer_394, !noalias !2
        %returnAddress_pointer_395 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_393, i64 0, i32 1, i32 0
        %sharer_pointer_396 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_393, i64 0, i32 1, i32 1
        %eraser_pointer_397 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_393, i64 0, i32 1, i32 2
        store ptr @returnAddress_384, ptr %returnAddress_pointer_395, !noalias !2
        store ptr @sharer_350, ptr %sharer_pointer_396, !noalias !2
        store ptr @eraser_354, ptr %eraser_pointer_397, !noalias !2
        %stackPointer_663 = call ccc %StackPointer @stackAllocate(%Stack %stack_362, i64 24)
        %returnAddress_pointer_664 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_663, i64 0, i32 1, i32 0
        %sharer_pointer_665 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_663, i64 0, i32 1, i32 1
        %eraser_pointer_666 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_663, i64 0, i32 1, i32 2
        store ptr @returnAddress_658, ptr %returnAddress_pointer_664, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_665, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_666, !noalias !2
        
        
        
        musttail call tailcc void @buildTreeDepth_worker_4_3_4373(i64 %n_2860, %Reference %seed_5_4357, %Reference %count_2881, %Stack %stack_362)
        ret void
}


@utf8StringLiteral_5234.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5236.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5239.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_667(%Pos %v_r_3239_4037, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_668 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_669 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_668, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_669, !noalias !2
        %index_2107_pointer_670 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_668, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_670, !noalias !2
        %Exception_2362_pointer_671 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_668, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_671, !noalias !2
        
        %tag_672 = extractvalue %Pos %v_r_3239_4037, 0
        %fields_673 = extractvalue %Pos %v_r_3239_4037, 1
        switch i64 %tag_672, label %label_674 [i64 0, label %label_678 i64 1, label %label_684]
    
    label_674:
        
        ret void
    
    label_678:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5230 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_676 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_677 = getelementptr %FrameHeader, %StackPointer %stackPointer_676, i64 0, i32 0
        %returnAddress_675 = load %ReturnAddress, ptr %returnAddress_pointer_677, !noalias !2
        musttail call tailcc void %returnAddress_675(i64 %pureApp_5230, %Stack %stack)
        ret void
    
    label_684:
        
        %make_5231_temporary_679 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5231 = insertvalue %Pos %make_5231_temporary_679, %Object null, 1
        
        
        
        %pureApp_5232 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5234 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5234.lit)
        
        %pureApp_5233 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5234, %Pos %pureApp_5232)
        
        
        
        %utf8StringLiteral_5236 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5236.lit)
        
        %pureApp_5235 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5233, %Pos %utf8StringLiteral_5236)
        
        
        
        %pureApp_5237 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5235, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5239 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5239.lit)
        
        %pureApp_5238 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5237, %Pos %utf8StringLiteral_5239)
        
        
        
        %vtable_680 = extractvalue %Neg %Exception_2362, 0
        %closure_681 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_682 = getelementptr ptr, ptr %vtable_680, i64 0
        %functionPointer_683 = load ptr, ptr %functionPointer_pointer_682, !noalias !2
        musttail call tailcc void %functionPointer_683(%Object %closure_681, %Pos %make_5231, %Pos %pureApp_5238, %Stack %stack)
        ret void
}



define ccc void @sharer_688(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_689 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_685_pointer_690 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_689, i64 0, i32 0
        %str_2106_685 = load %Pos, ptr %str_2106_685_pointer_690, !noalias !2
        %index_2107_686_pointer_691 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_689, i64 0, i32 1
        %index_2107_686 = load i64, ptr %index_2107_686_pointer_691, !noalias !2
        %Exception_2362_687_pointer_692 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_689, i64 0, i32 2
        %Exception_2362_687 = load %Neg, ptr %Exception_2362_687_pointer_692, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_685)
        call ccc void @shareNegative(%Neg %Exception_2362_687)
        call ccc void @shareFrames(%StackPointer %stackPointer_689)
        ret void
}



define ccc void @eraser_696(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_697 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_693_pointer_698 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_697, i64 0, i32 0
        %str_2106_693 = load %Pos, ptr %str_2106_693_pointer_698, !noalias !2
        %index_2107_694_pointer_699 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_697, i64 0, i32 1
        %index_2107_694 = load i64, ptr %index_2107_694_pointer_699, !noalias !2
        %Exception_2362_695_pointer_700 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_697, i64 0, i32 2
        %Exception_2362_695 = load %Neg, ptr %Exception_2362_695_pointer_700, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_693)
        call ccc void @eraseNegative(%Neg %Exception_2362_695)
        call ccc void @eraseFrames(%StackPointer %stackPointer_697)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5229 = add i64 0, 0
        
        %pureApp_5228 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5229)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_701 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_702 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_701, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_702, !noalias !2
        %index_2107_pointer_703 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_701, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_703, !noalias !2
        %Exception_2362_pointer_704 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_701, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_704, !noalias !2
        %returnAddress_pointer_705 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_701, i64 0, i32 1, i32 0
        %sharer_pointer_706 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_701, i64 0, i32 1, i32 1
        %eraser_pointer_707 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_701, i64 0, i32 1, i32 2
        store ptr @returnAddress_667, ptr %returnAddress_pointer_705, !noalias !2
        store ptr @sharer_688, ptr %sharer_pointer_706, !noalias !2
        store ptr @eraser_696, ptr %eraser_pointer_707, !noalias !2
        
        %tag_708 = extractvalue %Pos %pureApp_5228, 0
        %fields_709 = extractvalue %Pos %pureApp_5228, 1
        switch i64 %tag_708, label %label_710 [i64 0, label %label_714 i64 1, label %label_719]
    
    label_710:
        
        ret void
    
    label_714:
        
        %pureApp_5240 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5241 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5240)
        
        
        
        %stackPointer_712 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_713 = getelementptr %FrameHeader, %StackPointer %stackPointer_712, i64 0, i32 0
        %returnAddress_711 = load %ReturnAddress, ptr %returnAddress_pointer_713, !noalias !2
        musttail call tailcc void %returnAddress_711(%Pos %pureApp_5241, %Stack %stack)
        ret void
    
    label_719:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5242_temporary_715 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5242 = insertvalue %Pos %booleanLiteral_5242_temporary_715, %Object null, 1
        
        %stackPointer_717 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_718 = getelementptr %FrameHeader, %StackPointer %stackPointer_717, i64 0, i32 0
        %returnAddress_716 = load %ReturnAddress, ptr %returnAddress_pointer_718, !noalias !2
        musttail call tailcc void %returnAddress_716(%Pos %booleanLiteral_5242, %Stack %stack)
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
        
        musttail call tailcc void @main_2862(%Stack %stack)
        ret void
}
