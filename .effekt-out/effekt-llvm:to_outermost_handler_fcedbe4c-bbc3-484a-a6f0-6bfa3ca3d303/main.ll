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



define tailcc void @returnAddress_5(%Pos %v_coe_3493_240_4992, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5353 = call ccc i64 @unboxInt_303(%Pos %v_coe_3493_240_4992)
        
        
        
        %pureApp_5354 = call ccc %Pos @show_14(i64 %pureApp_5353)
        
        
        
        %pureApp_5355 = call ccc %Pos @println_1(%Pos %pureApp_5354)
        
        
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %pureApp_5355, %Stack %stack)
        ret void
}



define ccc void @sharer_9(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_10 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_10)
        ret void
}



define ccc void @eraser_11(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_12 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_12)
        ret void
}



define tailcc void @returnAddress_17(%Pos %returnValue_18, %Stack %stack) {
        
    entry:
        
        %stackPointer_19 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_5291_pointer_20 = getelementptr <{i64}>, %StackPointer %stackPointer_19, i64 0, i32 0
        %tmp_5291 = load i64, ptr %tmp_5291_pointer_20, !noalias !2
        %stackPointer_22 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_23 = getelementptr %FrameHeader, %StackPointer %stackPointer_22, i64 0, i32 0
        %returnAddress_21 = load %ReturnAddress, ptr %returnAddress_pointer_23, !noalias !2
        musttail call tailcc void %returnAddress_21(%Pos %returnValue_18, %Stack %stack)
        ret void
}



define ccc void @sharer_25(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_26 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5291_24_pointer_27 = getelementptr <{i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        %tmp_5291_24 = load i64, ptr %tmp_5291_24_pointer_27, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_26)
        ret void
}



define ccc void @eraser_29(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_30 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5291_28_pointer_31 = getelementptr <{i64}>, %StackPointer %stackPointer_30, i64 0, i32 0
        %tmp_5291_28 = load i64, ptr %tmp_5291_28_pointer_31, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_30)
        ret void
}



define tailcc void @returnAddress_40(%Pos %returnValue_41, %Stack %stack) {
        
    entry:
        
        %stackPointer_42 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2542_5_12_37_82_230_5036_pointer_43 = getelementptr <{i64}>, %StackPointer %stackPointer_42, i64 0, i32 0
        %v_r_2542_5_12_37_82_230_5036 = load i64, ptr %v_r_2542_5_12_37_82_230_5036_pointer_43, !noalias !2
        %stackPointer_45 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_46 = getelementptr %FrameHeader, %StackPointer %stackPointer_45, i64 0, i32 0
        %returnAddress_44 = load %ReturnAddress, ptr %returnAddress_pointer_46, !noalias !2
        musttail call tailcc void %returnAddress_44(%Pos %returnValue_41, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_61(%Pos %__20_6_222_5147, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_62 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_6_96_4991_pointer_63 = getelementptr <{%Reference}>, %StackPointer %stackPointer_62, i64 0, i32 0
        %v_6_96_4991 = load %Reference, ptr %v_6_96_4991_pointer_63, !noalias !2
        call ccc void @erasePositive(%Pos %__20_6_222_5147)
        
        
        musttail call tailcc void @countdown_worker_3_1_7_26_71_209_5099(%Reference %v_6_96_4991, %Stack %stack)
        ret void
}



define ccc void @sharer_65(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_66 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %v_6_96_4991_64_pointer_67 = getelementptr <{%Reference}>, %StackPointer %stackPointer_66, i64 0, i32 0
        %v_6_96_4991_64 = load %Reference, ptr %v_6_96_4991_64_pointer_67, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_66)
        ret void
}



define ccc void @eraser_69(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_70 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %v_6_96_4991_68_pointer_71 = getelementptr <{%Reference}>, %StackPointer %stackPointer_70, i64 0, i32 0
        %v_6_96_4991_68 = load %Reference, ptr %v_6_96_4991_68_pointer_71, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_70)
        ret void
}



define tailcc void @returnAddress_55(i64 %i_4_2_8_27_72_215_4951, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_56 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_6_96_4991_pointer_57 = getelementptr <{%Reference}>, %StackPointer %stackPointer_56, i64 0, i32 0
        %v_6_96_4991 = load %Reference, ptr %v_6_96_4991_pointer_57, !noalias !2
        
        %longLiteral_5364 = add i64 0, 0
        
        %pureApp_5363 = call ccc %Pos @infixEq_72(i64 %i_4_2_8_27_72_215_4951, i64 %longLiteral_5364)
        
        
        
        %tag_58 = extractvalue %Pos %pureApp_5363, 0
        %fields_59 = extractvalue %Pos %pureApp_5363, 1
        switch i64 %tag_58, label %label_60 [i64 0, label %label_83 i64 1, label %label_87]
    
    label_60:
        
        ret void
    
    label_83:
        
        %longLiteral_5366 = add i64 1, 0
        
        %pureApp_5365 = call ccc i64 @infixSub_105(i64 %i_4_2_8_27_72_215_4951, i64 %longLiteral_5366)
        
        
        %stackPointer_72 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %v_6_96_4991_pointer_73 = getelementptr <{%Reference}>, %StackPointer %stackPointer_72, i64 0, i32 0
        store %Reference %v_6_96_4991, ptr %v_6_96_4991_pointer_73, !noalias !2
        %returnAddress_pointer_74 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_72, i64 0, i32 1, i32 0
        %sharer_pointer_75 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_72, i64 0, i32 1, i32 1
        %eraser_pointer_76 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_72, i64 0, i32 1, i32 2
        store ptr @returnAddress_61, ptr %returnAddress_pointer_74, !noalias !2
        store ptr @sharer_65, ptr %sharer_pointer_75, !noalias !2
        store ptr @eraser_69, ptr %eraser_pointer_76, !noalias !2
        
        %v_6_96_4991pointer_77 = call ccc ptr @getVarPointer(%Reference %v_6_96_4991, %Stack %stack)
        %v_6_96_4991_old_78 = load i64, ptr %v_6_96_4991pointer_77, !noalias !2
        store i64 %pureApp_5365, ptr %v_6_96_4991pointer_77, !noalias !2
        
        %put_5367_temporary_79 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5367 = insertvalue %Pos %put_5367_temporary_79, %Object null, 1
        
        %stackPointer_81 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_82 = getelementptr %FrameHeader, %StackPointer %stackPointer_81, i64 0, i32 0
        %returnAddress_80 = load %ReturnAddress, ptr %returnAddress_pointer_82, !noalias !2
        musttail call tailcc void %returnAddress_80(%Pos %put_5367, %Stack %stack)
        ret void
    
    label_87:
        
        %stackPointer_85 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_86 = getelementptr %FrameHeader, %StackPointer %stackPointer_85, i64 0, i32 0
        %returnAddress_84 = load %ReturnAddress, ptr %returnAddress_pointer_86, !noalias !2
        musttail call tailcc void %returnAddress_84(i64 %i_4_2_8_27_72_215_4951, %Stack %stack)
        ret void
}



define tailcc void @countdown_worker_3_1_7_26_71_209_5099(%Reference %v_6_96_4991, %Stack %stack) {
        
    entry:
        
        %stackPointer_90 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %v_6_96_4991_pointer_91 = getelementptr <{%Reference}>, %StackPointer %stackPointer_90, i64 0, i32 0
        store %Reference %v_6_96_4991, ptr %v_6_96_4991_pointer_91, !noalias !2
        %returnAddress_pointer_92 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_90, i64 0, i32 1, i32 0
        %sharer_pointer_93 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_90, i64 0, i32 1, i32 1
        %eraser_pointer_94 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_90, i64 0, i32 1, i32 2
        store ptr @returnAddress_55, ptr %returnAddress_pointer_92, !noalias !2
        store ptr @sharer_65, ptr %sharer_pointer_93, !noalias !2
        store ptr @eraser_69, ptr %eraser_pointer_94, !noalias !2
        
        %get_5368_pointer_95 = call ccc ptr @getVarPointer(%Reference %v_6_96_4991, %Stack %stack)
        %v_6_96_4991_old_96 = load i64, ptr %get_5368_pointer_95, !noalias !2
        %get_5368 = load i64, ptr %get_5368_pointer_95, !noalias !2
        
        %stackPointer_98 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_99 = getelementptr %FrameHeader, %StackPointer %stackPointer_98, i64 0, i32 0
        %returnAddress_97 = load %ReturnAddress, ptr %returnAddress_pointer_99, !noalias !2
        musttail call tailcc void %returnAddress_97(i64 %get_5368, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_100(i64 %v_coe_3488_12_31_76_224_5060, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5369 = call ccc %Pos @boxInt_301(i64 %v_coe_3488_12_31_76_224_5060)
        
        
        
        %stackPointer_102 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_103 = getelementptr %FrameHeader, %StackPointer %stackPointer_102, i64 0, i32 0
        %returnAddress_101 = load %ReturnAddress, ptr %returnAddress_pointer_103, !noalias !2
        musttail call tailcc void %returnAddress_101(%Pos %pureApp_5369, %Stack %stack)
        ret void
}



define tailcc void @pad_worker_5_17_62_190_5102(i64 %d_6_18_63_191_5004, %Reference %v_6_96_4991, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5358 = add i64 0, 0
        
        %pureApp_5357 = call ccc %Pos @infixEq_72(i64 %d_6_18_63_191_5004, i64 %longLiteral_5358)
        
        
        
        %tag_37 = extractvalue %Pos %pureApp_5357, 0
        %fields_38 = extractvalue %Pos %pureApp_5357, 1
        switch i64 %tag_37, label %label_39 [i64 0, label %label_54 i64 1, label %label_108]
    
    label_39:
        
        ret void
    
    label_54:
        
        %longLiteral_5359 = add i64 -377, 0
        
        
        %v_6_13_38_83_231_5056 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_49 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2542_5_12_37_82_230_5036_pointer_50 = getelementptr <{i64}>, %StackPointer %stackPointer_49, i64 0, i32 0
        store i64 %longLiteral_5359, ptr %v_r_2542_5_12_37_82_230_5036_pointer_50, !noalias !2
        %returnAddress_pointer_51 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 0
        %sharer_pointer_52 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 1
        %eraser_pointer_53 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_49, i64 0, i32 1, i32 2
        store ptr @returnAddress_40, ptr %returnAddress_pointer_51, !noalias !2
        store ptr @sharer_25, ptr %sharer_pointer_52, !noalias !2
        store ptr @eraser_29, ptr %eraser_pointer_53, !noalias !2
        
        %longLiteral_5362 = add i64 1, 0
        
        %pureApp_5361 = call ccc i64 @infixSub_105(i64 %d_6_18_63_191_5004, i64 %longLiteral_5362)
        
        
        
        
        
        musttail call tailcc void @pad_worker_5_17_62_190_5102(i64 %pureApp_5361, %Reference %v_6_96_4991, %Stack %stack)
        ret void
    
    label_108:
        %stackPointer_104 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_105 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_104, i64 0, i32 1, i32 0
        %sharer_pointer_106 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_104, i64 0, i32 1, i32 1
        %eraser_pointer_107 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_104, i64 0, i32 1, i32 2
        store ptr @returnAddress_100, ptr %returnAddress_pointer_105, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_106, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_107, !noalias !2
        
        
        musttail call tailcc void @countdown_worker_3_1_7_26_71_209_5099(%Reference %v_6_96_4991, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_109(%Pos %v_coe_3489_42_87_235_4986, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5370 = call ccc i64 @unboxInt_303(%Pos %v_coe_3489_42_87_235_4986)
        
        
        
        %pureApp_5371 = call ccc %Pos @boxInt_301(i64 %pureApp_5370)
        
        
        
        %stackPointer_111 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_112 = getelementptr %FrameHeader, %StackPointer %stackPointer_111, i64 0, i32 0
        %returnAddress_110 = load %ReturnAddress, ptr %returnAddress_pointer_112, !noalias !2
        musttail call tailcc void %returnAddress_110(%Pos %pureApp_5371, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_2(%Pos %v_coe_3514_3602, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_3 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_5291_pointer_4 = getelementptr <{i64}>, %StackPointer %stackPointer_3, i64 0, i32 0
        %tmp_5291 = load i64, ptr %tmp_5291_pointer_4, !noalias !2
        
        %pureApp_5352 = call ccc i64 @unboxInt_303(%Pos %v_coe_3514_3602)
        
        
        %stackPointer_13 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_14 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_13, i64 0, i32 1, i32 0
        %sharer_pointer_15 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_13, i64 0, i32 1, i32 1
        %eraser_pointer_16 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_13, i64 0, i32 1, i32 2
        store ptr @returnAddress_5, ptr %returnAddress_pointer_14, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_15, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_16, !noalias !2
        %v_6_96_4991 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_32 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_5291_pointer_33 = getelementptr <{i64}>, %StackPointer %stackPointer_32, i64 0, i32 0
        store i64 %tmp_5291, ptr %tmp_5291_pointer_33, !noalias !2
        %returnAddress_pointer_34 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_32, i64 0, i32 1, i32 0
        %sharer_pointer_35 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_32, i64 0, i32 1, i32 1
        %eraser_pointer_36 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_32, i64 0, i32 1, i32 2
        store ptr @returnAddress_17, ptr %returnAddress_pointer_34, !noalias !2
        store ptr @sharer_25, ptr %sharer_pointer_35, !noalias !2
        store ptr @eraser_29, ptr %eraser_pointer_36, !noalias !2
        %stackPointer_113 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_114 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_113, i64 0, i32 1, i32 0
        %sharer_pointer_115 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_113, i64 0, i32 1, i32 1
        %eraser_pointer_116 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_113, i64 0, i32 1, i32 2
        store ptr @returnAddress_109, ptr %returnAddress_pointer_114, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_115, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_116, !noalias !2
        
        
        
        musttail call tailcc void @pad_worker_5_17_62_190_5102(i64 %pureApp_5352, %Reference %v_6_96_4991, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_125(%Pos %returned_5372, %Stack %stack) {
        
    entry:
        
        %stack_126 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_128 = call ccc %StackPointer @stackDeallocate(%Stack %stack_126, i64 24)
        %returnAddress_pointer_129 = getelementptr %FrameHeader, %StackPointer %stackPointer_128, i64 0, i32 0
        %returnAddress_127 = load %ReturnAddress, ptr %returnAddress_pointer_129, !noalias !2
        musttail call tailcc void %returnAddress_127(%Pos %returned_5372, %Stack %stack_126)
        ret void
}



define ccc void @sharer_130(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_131 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_132(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_133 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_133)
        ret void
}



define tailcc void @Exception_9_10_4587_clause_138(%Object %closure, %Pos %exception_10_11_4593, %Pos %msg_11_12_4595, %Stack %stack) {
        
    entry:
        
        %environment_139 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4590_pointer_140 = getelementptr <{%Prompt}>, %Environment %environment_139, i64 0, i32 0
        %p_8_9_4590 = load %Prompt, ptr %p_8_9_4590_pointer_140, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_11_4593)
        call ccc void @erasePositive(%Pos %msg_11_12_4595)
        
        %pair_141 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4590)
        %k_13_14_4596 = extractvalue <{%Resumption, %Stack}> %pair_141, 0
        %stack_142 = extractvalue <{%Resumption, %Stack}> %pair_141, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4596)
        
        %longLiteral_5373 = add i64 10, 0
        
        
        
        %pureApp_5374 = call ccc %Pos @boxInt_301(i64 %longLiteral_5373)
        
        
        
        %stackPointer_144 = call ccc %StackPointer @stackDeallocate(%Stack %stack_142, i64 24)
        %returnAddress_pointer_145 = getelementptr %FrameHeader, %StackPointer %stackPointer_144, i64 0, i32 0
        %returnAddress_143 = load %ReturnAddress, ptr %returnAddress_pointer_145, !noalias !2
        musttail call tailcc void %returnAddress_143(%Pos %pureApp_5374, %Stack %stack_142)
        ret void
}


@vtable_146 = private constant [1 x ptr] [ptr @Exception_9_10_4587_clause_138]


define ccc void @eraser_150(%Environment %environment) {
        
    entry:
        
        %p_8_9_4590_149_pointer_151 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_8_9_4590_149 = load %Prompt, ptr %p_8_9_4590_149_pointer_151, !noalias !2
        ret void
}



define tailcc void @returnAddress_154(%Pos %v_coe_3509_157_317_4763, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5375 = call ccc i64 @unboxInt_303(%Pos %v_coe_3509_157_317_4763)
        
        
        
        %pureApp_5376 = call ccc %Pos @boxInt_301(i64 %pureApp_5375)
        
        
        
        %stackPointer_156 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_157 = getelementptr %FrameHeader, %StackPointer %stackPointer_156, i64 0, i32 0
        %returnAddress_155 = load %ReturnAddress, ptr %returnAddress_pointer_157, !noalias !2
        musttail call tailcc void %returnAddress_155(%Pos %pureApp_5376, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_163(%Pos %returned_5377, %Stack %stack) {
        
    entry:
        
        %stack_164 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_166 = call ccc %StackPointer @stackDeallocate(%Stack %stack_164, i64 24)
        %returnAddress_pointer_167 = getelementptr %FrameHeader, %StackPointer %stackPointer_166, i64 0, i32 0
        %returnAddress_165 = load %ReturnAddress, ptr %returnAddress_pointer_167, !noalias !2
        musttail call tailcc void %returnAddress_165(%Pos %returned_5377, %Stack %stack_164)
        ret void
}



define ccc void @eraser_179(%Environment %environment) {
        
    entry:
        
        %tmp_5263_177_pointer_180 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5263_177 = load %Pos, ptr %tmp_5263_177_pointer_180, !noalias !2
        %acc_3_3_5_37_118_278_4820_178_pointer_181 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_37_118_278_4820_178 = load %Pos, ptr %acc_3_3_5_37_118_278_4820_178_pointer_181, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5263_177)
        call ccc void @erasePositive(%Pos %acc_3_3_5_37_118_278_4820_178)
        ret void
}



define tailcc void @toList_1_1_3_35_116_276_4668(i64 %start_2_2_4_36_117_277_4869, %Pos %acc_3_3_5_37_118_278_4820, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5379 = add i64 1, 0
        
        %pureApp_5378 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_36_117_277_4869, i64 %longLiteral_5379)
        
        
        
        %tag_172 = extractvalue %Pos %pureApp_5378, 0
        %fields_173 = extractvalue %Pos %pureApp_5378, 1
        switch i64 %tag_172, label %label_174 [i64 0, label %label_185 i64 1, label %label_189]
    
    label_174:
        
        ret void
    
    label_185:
        
        %pureApp_5380 = call ccc %Pos @argument_2385(i64 %start_2_2_4_36_117_277_4869)
        
        
        
        %longLiteral_5382 = add i64 1, 0
        
        %pureApp_5381 = call ccc i64 @infixSub_105(i64 %start_2_2_4_36_117_277_4869, i64 %longLiteral_5382)
        
        
        
        %fields_175 = call ccc %Object @newObject(ptr @eraser_179, i64 32)
        %environment_176 = call ccc %Environment @objectEnvironment(%Object %fields_175)
        %tmp_5263_pointer_182 = getelementptr <{%Pos, %Pos}>, %Environment %environment_176, i64 0, i32 0
        store %Pos %pureApp_5380, ptr %tmp_5263_pointer_182, !noalias !2
        %acc_3_3_5_37_118_278_4820_pointer_183 = getelementptr <{%Pos, %Pos}>, %Environment %environment_176, i64 0, i32 1
        store %Pos %acc_3_3_5_37_118_278_4820, ptr %acc_3_3_5_37_118_278_4820_pointer_183, !noalias !2
        %make_5383_temporary_184 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5383 = insertvalue %Pos %make_5383_temporary_184, %Object %fields_175, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_35_116_276_4668(i64 %pureApp_5381, %Pos %make_5383, %Stack %stack)
        ret void
    
    label_189:
        
        %stackPointer_187 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_188 = getelementptr %FrameHeader, %StackPointer %stackPointer_187, i64 0, i32 0
        %returnAddress_186 = load %ReturnAddress, ptr %returnAddress_pointer_188, !noalias !2
        musttail call tailcc void %returnAddress_186(%Pos %acc_3_3_5_37_118_278_4820, %Stack %stack)
        ret void
}



define tailcc void @go_6_14_46_127_287_4683(%Pos %list_7_15_47_128_288_4781, i64 %i_8_16_48_129_289_4727, %Prompt %p_8_9_75_235_4627, %Stack %stack) {
        
    entry:
        
        
        %tag_195 = extractvalue %Pos %list_7_15_47_128_288_4781, 0
        %fields_196 = extractvalue %Pos %list_7_15_47_128_288_4781, 1
        switch i64 %tag_195, label %label_197 [i64 0, label %label_203 i64 1, label %label_215]
    
    label_197:
        
        ret void
    
    label_203:
        
        %pair_198 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_75_235_4627)
        %k_13_14_4_146_306_4907 = extractvalue <{%Resumption, %Stack}> %pair_198, 0
        %stack_199 = extractvalue <{%Resumption, %Stack}> %pair_198, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_146_306_4907)
        
        %longLiteral_5388 = add i64 10, 0
        
        
        
        %pureApp_5389 = call ccc %Pos @boxInt_301(i64 %longLiteral_5388)
        
        
        
        %stackPointer_201 = call ccc %StackPointer @stackDeallocate(%Stack %stack_199, i64 24)
        %returnAddress_pointer_202 = getelementptr %FrameHeader, %StackPointer %stackPointer_201, i64 0, i32 0
        %returnAddress_200 = load %ReturnAddress, ptr %returnAddress_pointer_202, !noalias !2
        musttail call tailcc void %returnAddress_200(%Pos %pureApp_5389, %Stack %stack_199)
        ret void
    
    label_209:
        
        ret void
    
    label_210:
        call ccc void @erasePositive(%Pos %v_y_2824_19_27_59_150_310_4695)
        
        %longLiteral_5393 = add i64 1, 0
        
        %pureApp_5392 = call ccc i64 @infixSub_105(i64 %i_8_16_48_129_289_4727, i64 %longLiteral_5393)
        
        
        
        
        
        
        musttail call tailcc void @go_6_14_46_127_287_4683(%Pos %v_y_2825_20_28_60_151_311_4777, i64 %pureApp_5392, %Prompt %p_8_9_75_235_4627, %Stack %stack)
        ret void
    
    label_214:
        call ccc void @erasePositive(%Pos %v_y_2825_20_28_60_151_311_4777)
        
        %stackPointer_212 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_213 = getelementptr %FrameHeader, %StackPointer %stackPointer_212, i64 0, i32 0
        %returnAddress_211 = load %ReturnAddress, ptr %returnAddress_pointer_213, !noalias !2
        musttail call tailcc void %returnAddress_211(%Pos %v_y_2824_19_27_59_150_310_4695, %Stack %stack)
        ret void
    
    label_215:
        %environment_204 = call ccc %Environment @objectEnvironment(%Object %fields_196)
        %v_y_2824_19_27_59_150_310_4695_pointer_205 = getelementptr <{%Pos, %Pos}>, %Environment %environment_204, i64 0, i32 0
        %v_y_2824_19_27_59_150_310_4695 = load %Pos, ptr %v_y_2824_19_27_59_150_310_4695_pointer_205, !noalias !2
        %v_y_2825_20_28_60_151_311_4777_pointer_206 = getelementptr <{%Pos, %Pos}>, %Environment %environment_204, i64 0, i32 1
        %v_y_2825_20_28_60_151_311_4777 = load %Pos, ptr %v_y_2825_20_28_60_151_311_4777_pointer_206, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2824_19_27_59_150_310_4695)
        call ccc void @sharePositive(%Pos %v_y_2825_20_28_60_151_311_4777)
        call ccc void @eraseObject(%Object %fields_196)
        
        %longLiteral_5391 = add i64 0, 0
        
        %pureApp_5390 = call ccc %Pos @infixEq_72(i64 %i_8_16_48_129_289_4727, i64 %longLiteral_5391)
        
        
        
        %tag_207 = extractvalue %Pos %pureApp_5390, 0
        %fields_208 = extractvalue %Pos %pureApp_5390, 1
        switch i64 %tag_207, label %label_209 [i64 0, label %label_210 i64 1, label %label_214]
}



define tailcc void @returnAddress_219(i64 %v_coe_3507_64_155_315_4863, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5394 = call ccc %Pos @boxInt_301(i64 %v_coe_3507_64_155_315_4863)
        
        
        
        %stackPointer_221 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_222 = getelementptr %FrameHeader, %StackPointer %stackPointer_221, i64 0, i32 0
        %returnAddress_220 = load %ReturnAddress, ptr %returnAddress_pointer_222, !noalias !2
        musttail call tailcc void %returnAddress_220(%Pos %pureApp_5394, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_216(%Pos %v_r_2568_31_63_154_314_4844, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_217 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %Exception_9_10_4587_pointer_218 = getelementptr <{%Neg}>, %StackPointer %stackPointer_217, i64 0, i32 0
        %Exception_9_10_4587 = load %Neg, ptr %Exception_9_10_4587_pointer_218, !noalias !2
        %stackPointer_223 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_224 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_223, i64 0, i32 1, i32 0
        %sharer_pointer_225 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_223, i64 0, i32 1, i32 1
        %eraser_pointer_226 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_223, i64 0, i32 1, i32 2
        store ptr @returnAddress_219, ptr %returnAddress_pointer_224, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_225, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_226, !noalias !2
        
        
        
        
        musttail call tailcc void @toInt_2062(%Pos %v_r_2568_31_63_154_314_4844, %Neg %Exception_9_10_4587, %Stack %stack)
        ret void
}



define ccc void @sharer_228(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_229 = getelementptr <{%Neg}>, %StackPointer %stackPointer, i64 -1
        %Exception_9_10_4587_227_pointer_230 = getelementptr <{%Neg}>, %StackPointer %stackPointer_229, i64 0, i32 0
        %Exception_9_10_4587_227 = load %Neg, ptr %Exception_9_10_4587_227_pointer_230, !noalias !2
        call ccc void @shareNegative(%Neg %Exception_9_10_4587_227)
        call ccc void @shareFrames(%StackPointer %stackPointer_229)
        ret void
}



define ccc void @eraser_232(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_233 = getelementptr <{%Neg}>, %StackPointer %stackPointer, i64 -1
        %Exception_9_10_4587_231_pointer_234 = getelementptr <{%Neg}>, %StackPointer %stackPointer_233, i64 0, i32 0
        %Exception_9_10_4587_231 = load %Neg, ptr %Exception_9_10_4587_231_pointer_234, !noalias !2
        call ccc void @eraseNegative(%Neg %Exception_9_10_4587_231)
        call ccc void @eraseFrames(%StackPointer %stackPointer_233)
        ret void
}



define tailcc void @returnAddress_191(%Pos %v_r_2567_13_45_126_286_4853, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_192 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %Exception_9_10_4587_pointer_193 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_192, i64 0, i32 0
        %Exception_9_10_4587 = load %Neg, ptr %Exception_9_10_4587_pointer_193, !noalias !2
        %p_8_9_75_235_4627_pointer_194 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_192, i64 0, i32 1
        %p_8_9_75_235_4627 = load %Prompt, ptr %p_8_9_75_235_4627_pointer_194, !noalias !2
        %stackPointer_235 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %Exception_9_10_4587_pointer_236 = getelementptr <{%Neg}>, %StackPointer %stackPointer_235, i64 0, i32 0
        store %Neg %Exception_9_10_4587, ptr %Exception_9_10_4587_pointer_236, !noalias !2
        %returnAddress_pointer_237 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_235, i64 0, i32 1, i32 0
        %sharer_pointer_238 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_235, i64 0, i32 1, i32 1
        %eraser_pointer_239 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_235, i64 0, i32 1, i32 2
        store ptr @returnAddress_216, ptr %returnAddress_pointer_237, !noalias !2
        store ptr @sharer_228, ptr %sharer_pointer_238, !noalias !2
        store ptr @eraser_232, ptr %eraser_pointer_239, !noalias !2
        
        %longLiteral_5395 = add i64 1, 0
        
        
        
        
        musttail call tailcc void @go_6_14_46_127_287_4683(%Pos %v_r_2567_13_45_126_286_4853, i64 %longLiteral_5395, %Prompt %p_8_9_75_235_4627, %Stack %stack)
        ret void
}



define ccc void @sharer_242(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_243 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %Exception_9_10_4587_240_pointer_244 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_243, i64 0, i32 0
        %Exception_9_10_4587_240 = load %Neg, ptr %Exception_9_10_4587_240_pointer_244, !noalias !2
        %p_8_9_75_235_4627_241_pointer_245 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_243, i64 0, i32 1
        %p_8_9_75_235_4627_241 = load %Prompt, ptr %p_8_9_75_235_4627_241_pointer_245, !noalias !2
        call ccc void @shareNegative(%Neg %Exception_9_10_4587_240)
        call ccc void @shareFrames(%StackPointer %stackPointer_243)
        ret void
}



define ccc void @eraser_248(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_249 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %Exception_9_10_4587_246_pointer_250 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_249, i64 0, i32 0
        %Exception_9_10_4587_246 = load %Neg, ptr %Exception_9_10_4587_246_pointer_250, !noalias !2
        %p_8_9_75_235_4627_247_pointer_251 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_249, i64 0, i32 1
        %p_8_9_75_235_4627_247 = load %Prompt, ptr %p_8_9_75_235_4627_247_pointer_251, !noalias !2
        call ccc void @eraseNegative(%Neg %Exception_9_10_4587_246)
        call ccc void @eraseFrames(%StackPointer %stackPointer_249)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3500_3578, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5351 = call ccc i64 @unboxInt_303(%Pos %v_coe_3500_3578)
        
        
        %stackPointer_119 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_5291_pointer_120 = getelementptr <{i64}>, %StackPointer %stackPointer_119, i64 0, i32 0
        store i64 %pureApp_5351, ptr %tmp_5291_pointer_120, !noalias !2
        %returnAddress_pointer_121 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_119, i64 0, i32 1, i32 0
        %sharer_pointer_122 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_119, i64 0, i32 1, i32 1
        %eraser_pointer_123 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_119, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_121, !noalias !2
        store ptr @sharer_25, ptr %sharer_pointer_122, !noalias !2
        store ptr @eraser_29, ptr %eraser_pointer_123, !noalias !2
        
        %stack_124 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4590 = call ccc %Prompt @currentPrompt(%Stack %stack_124)
        %stackPointer_134 = call ccc %StackPointer @stackAllocate(%Stack %stack_124, i64 24)
        %returnAddress_pointer_135 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_134, i64 0, i32 1, i32 0
        %sharer_pointer_136 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_134, i64 0, i32 1, i32 1
        %eraser_pointer_137 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_134, i64 0, i32 1, i32 2
        store ptr @returnAddress_125, ptr %returnAddress_pointer_135, !noalias !2
        store ptr @sharer_130, ptr %sharer_pointer_136, !noalias !2
        store ptr @eraser_132, ptr %eraser_pointer_137, !noalias !2
        
        %closure_147 = call ccc %Object @newObject(ptr @eraser_150, i64 8)
        %environment_148 = call ccc %Environment @objectEnvironment(%Object %closure_147)
        %p_8_9_4590_pointer_152 = getelementptr <{%Prompt}>, %Environment %environment_148, i64 0, i32 0
        store %Prompt %p_8_9_4590, ptr %p_8_9_4590_pointer_152, !noalias !2
        %vtable_temporary_153 = insertvalue %Neg zeroinitializer, ptr @vtable_146, 0
        %Exception_9_10_4587 = insertvalue %Neg %vtable_temporary_153, %Object %closure_147, 1
        %stackPointer_158 = call ccc %StackPointer @stackAllocate(%Stack %stack_124, i64 24)
        %returnAddress_pointer_159 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_158, i64 0, i32 1, i32 0
        %sharer_pointer_160 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_158, i64 0, i32 1, i32 1
        %eraser_pointer_161 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_158, i64 0, i32 1, i32 2
        store ptr @returnAddress_154, ptr %returnAddress_pointer_159, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_160, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_161, !noalias !2
        
        %stack_162 = call ccc %Stack @reset(%Stack %stack_124)
        %p_8_9_75_235_4627 = call ccc %Prompt @currentPrompt(%Stack %stack_162)
        %stackPointer_168 = call ccc %StackPointer @stackAllocate(%Stack %stack_162, i64 24)
        %returnAddress_pointer_169 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_168, i64 0, i32 1, i32 0
        %sharer_pointer_170 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_168, i64 0, i32 1, i32 1
        %eraser_pointer_171 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_168, i64 0, i32 1, i32 2
        store ptr @returnAddress_163, ptr %returnAddress_pointer_169, !noalias !2
        store ptr @sharer_130, ptr %sharer_pointer_170, !noalias !2
        store ptr @eraser_132, ptr %eraser_pointer_171, !noalias !2
        
        %pureApp_5384 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5386 = add i64 1, 0
        
        %pureApp_5385 = call ccc i64 @infixSub_105(i64 %pureApp_5384, i64 %longLiteral_5386)
        
        
        
        %make_5387_temporary_190 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5387 = insertvalue %Pos %make_5387_temporary_190, %Object null, 1
        
        
        %stackPointer_252 = call ccc %StackPointer @stackAllocate(%Stack %stack_162, i64 48)
        %Exception_9_10_4587_pointer_253 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_252, i64 0, i32 0
        store %Neg %Exception_9_10_4587, ptr %Exception_9_10_4587_pointer_253, !noalias !2
        %p_8_9_75_235_4627_pointer_254 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_252, i64 0, i32 1
        store %Prompt %p_8_9_75_235_4627, ptr %p_8_9_75_235_4627_pointer_254, !noalias !2
        %returnAddress_pointer_255 = getelementptr <{<{%Neg, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 0
        %sharer_pointer_256 = getelementptr <{<{%Neg, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 1
        %eraser_pointer_257 = getelementptr <{<{%Neg, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 2
        store ptr @returnAddress_191, ptr %returnAddress_pointer_255, !noalias !2
        store ptr @sharer_242, ptr %sharer_pointer_256, !noalias !2
        store ptr @eraser_248, ptr %eraser_pointer_257, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_35_116_276_4668(i64 %pureApp_5385, %Pos %make_5387, %Stack %stack_162)
        ret void
}



define tailcc void @returnAddress_263(%Pos %returned_5396, %Stack %stack) {
        
    entry:
        
        %stack_264 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_266 = call ccc %StackPointer @stackDeallocate(%Stack %stack_264, i64 24)
        %returnAddress_pointer_267 = getelementptr %FrameHeader, %StackPointer %stackPointer_266, i64 0, i32 0
        %returnAddress_265 = load %ReturnAddress, ptr %returnAddress_pointer_267, !noalias !2
        musttail call tailcc void %returnAddress_265(%Pos %returned_5396, %Stack %stack_264)
        ret void
}



define tailcc void @Exception_9_10_4196_clause_272(%Object %closure, %Pos %exception_10_11_4202, %Pos %msg_11_12_4204, %Stack %stack) {
        
    entry:
        
        %environment_273 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4199_pointer_274 = getelementptr <{%Prompt}>, %Environment %environment_273, i64 0, i32 0
        %p_8_9_4199 = load %Prompt, ptr %p_8_9_4199_pointer_274, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_11_4202)
        call ccc void @erasePositive(%Pos %msg_11_12_4204)
        
        %pair_275 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4199)
        %k_13_14_4205 = extractvalue <{%Resumption, %Stack}> %pair_275, 0
        %stack_276 = extractvalue <{%Resumption, %Stack}> %pair_275, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4205)
        
        %longLiteral_5397 = add i64 5, 0
        
        
        
        %pureApp_5398 = call ccc %Pos @boxInt_301(i64 %longLiteral_5397)
        
        
        
        %stackPointer_278 = call ccc %StackPointer @stackDeallocate(%Stack %stack_276, i64 24)
        %returnAddress_pointer_279 = getelementptr %FrameHeader, %StackPointer %stackPointer_278, i64 0, i32 0
        %returnAddress_277 = load %ReturnAddress, ptr %returnAddress_pointer_279, !noalias !2
        musttail call tailcc void %returnAddress_277(%Pos %pureApp_5398, %Stack %stack_276)
        ret void
}


@vtable_280 = private constant [1 x ptr] [ptr @Exception_9_10_4196_clause_272]


define tailcc void @toList_1_1_3_34_4237(i64 %start_2_2_4_35_4220, %Pos %acc_3_3_5_36_4253, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5400 = add i64 1, 0
        
        %pureApp_5399 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_35_4220, i64 %longLiteral_5400)
        
        
        
        %tag_286 = extractvalue %Pos %pureApp_5399, 0
        %fields_287 = extractvalue %Pos %pureApp_5399, 1
        switch i64 %tag_286, label %label_288 [i64 0, label %label_296 i64 1, label %label_300]
    
    label_288:
        
        ret void
    
    label_296:
        
        %pureApp_5401 = call ccc %Pos @argument_2385(i64 %start_2_2_4_35_4220)
        
        
        
        %longLiteral_5403 = add i64 1, 0
        
        %pureApp_5402 = call ccc i64 @infixSub_105(i64 %start_2_2_4_35_4220, i64 %longLiteral_5403)
        
        
        
        %fields_289 = call ccc %Object @newObject(ptr @eraser_179, i64 32)
        %environment_290 = call ccc %Environment @objectEnvironment(%Object %fields_289)
        %tmp_5253_pointer_293 = getelementptr <{%Pos, %Pos}>, %Environment %environment_290, i64 0, i32 0
        store %Pos %pureApp_5401, ptr %tmp_5253_pointer_293, !noalias !2
        %acc_3_3_5_36_4253_pointer_294 = getelementptr <{%Pos, %Pos}>, %Environment %environment_290, i64 0, i32 1
        store %Pos %acc_3_3_5_36_4253, ptr %acc_3_3_5_36_4253_pointer_294, !noalias !2
        %make_5404_temporary_295 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5404 = insertvalue %Pos %make_5404_temporary_295, %Object %fields_289, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_34_4237(i64 %pureApp_5402, %Pos %make_5404, %Stack %stack)
        ret void
    
    label_300:
        
        %stackPointer_298 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_299 = getelementptr %FrameHeader, %StackPointer %stackPointer_298, i64 0, i32 0
        %returnAddress_297 = load %ReturnAddress, ptr %returnAddress_pointer_299, !noalias !2
        musttail call tailcc void %returnAddress_297(%Pos %acc_3_3_5_36_4253, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_311(i64 %v_coe_3498_62_4213, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5409 = call ccc %Pos @boxInt_301(i64 %v_coe_3498_62_4213)
        
        
        
        %stackPointer_313 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_314 = getelementptr %FrameHeader, %StackPointer %stackPointer_313, i64 0, i32 0
        %returnAddress_312 = load %ReturnAddress, ptr %returnAddress_pointer_314, !noalias !2
        musttail call tailcc void %returnAddress_312(%Pos %pureApp_5409, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_308(%Pos %v_r_2564_30_61_4250, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_309 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %Exception_9_10_4196_pointer_310 = getelementptr <{%Neg}>, %StackPointer %stackPointer_309, i64 0, i32 0
        %Exception_9_10_4196 = load %Neg, ptr %Exception_9_10_4196_pointer_310, !noalias !2
        %stackPointer_315 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_316 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_315, i64 0, i32 1, i32 0
        %sharer_pointer_317 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_315, i64 0, i32 1, i32 1
        %eraser_pointer_318 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_315, i64 0, i32 1, i32 2
        store ptr @returnAddress_311, ptr %returnAddress_pointer_316, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_317, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_318, !noalias !2
        
        
        
        
        musttail call tailcc void @toInt_2062(%Pos %v_r_2564_30_61_4250, %Neg %Exception_9_10_4196, %Stack %stack)
        ret void
}


@utf8StringLiteral_5410.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_305(%Pos %v_r_2563_24_55_4258, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_306 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %Exception_9_10_4196_pointer_307 = getelementptr <{%Neg}>, %StackPointer %stackPointer_306, i64 0, i32 0
        %Exception_9_10_4196 = load %Neg, ptr %Exception_9_10_4196_pointer_307, !noalias !2
        %stackPointer_321 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %Exception_9_10_4196_pointer_322 = getelementptr <{%Neg}>, %StackPointer %stackPointer_321, i64 0, i32 0
        store %Neg %Exception_9_10_4196, ptr %Exception_9_10_4196_pointer_322, !noalias !2
        %returnAddress_pointer_323 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_321, i64 0, i32 1, i32 0
        %sharer_pointer_324 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_321, i64 0, i32 1, i32 1
        %eraser_pointer_325 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_321, i64 0, i32 1, i32 2
        store ptr @returnAddress_308, ptr %returnAddress_pointer_323, !noalias !2
        store ptr @sharer_228, ptr %sharer_pointer_324, !noalias !2
        store ptr @eraser_232, ptr %eraser_pointer_325, !noalias !2
        
        %tag_326 = extractvalue %Pos %v_r_2563_24_55_4258, 0
        %fields_327 = extractvalue %Pos %v_r_2563_24_55_4258, 1
        switch i64 %tag_326, label %label_328 [i64 0, label %label_332 i64 1, label %label_338]
    
    label_328:
        
        ret void
    
    label_332:
        
        %utf8StringLiteral_5410 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5410.lit)
        
        %stackPointer_330 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_331 = getelementptr %FrameHeader, %StackPointer %stackPointer_330, i64 0, i32 0
        %returnAddress_329 = load %ReturnAddress, ptr %returnAddress_pointer_331, !noalias !2
        musttail call tailcc void %returnAddress_329(%Pos %utf8StringLiteral_5410, %Stack %stack)
        ret void
    
    label_338:
        %environment_333 = call ccc %Environment @objectEnvironment(%Object %fields_327)
        %v_y_3294_8_29_60_4268_pointer_334 = getelementptr <{%Pos}>, %Environment %environment_333, i64 0, i32 0
        %v_y_3294_8_29_60_4268 = load %Pos, ptr %v_y_3294_8_29_60_4268_pointer_334, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3294_8_29_60_4268)
        call ccc void @eraseObject(%Object %fields_327)
        
        %stackPointer_336 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_337 = getelementptr %FrameHeader, %StackPointer %stackPointer_336, i64 0, i32 0
        %returnAddress_335 = load %ReturnAddress, ptr %returnAddress_pointer_337, !noalias !2
        musttail call tailcc void %returnAddress_335(%Pos %v_y_3294_8_29_60_4268, %Stack %stack)
        ret void
}



define ccc void @eraser_360(%Environment %environment) {
        
    entry:
        
        %v_y_2803_10_21_52_4243_359_pointer_361 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %v_y_2803_10_21_52_4243_359 = load %Pos, ptr %v_y_2803_10_21_52_4243_359_pointer_361, !noalias !2
        call ccc void @erasePositive(%Pos %v_y_2803_10_21_52_4243_359)
        ret void
}



define tailcc void @returnAddress_302(%Pos %v_r_2562_13_44_4249, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_303 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %Exception_9_10_4196_pointer_304 = getelementptr <{%Neg}>, %StackPointer %stackPointer_303, i64 0, i32 0
        %Exception_9_10_4196 = load %Neg, ptr %Exception_9_10_4196_pointer_304, !noalias !2
        %stackPointer_341 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %Exception_9_10_4196_pointer_342 = getelementptr <{%Neg}>, %StackPointer %stackPointer_341, i64 0, i32 0
        store %Neg %Exception_9_10_4196, ptr %Exception_9_10_4196_pointer_342, !noalias !2
        %returnAddress_pointer_343 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_341, i64 0, i32 1, i32 0
        %sharer_pointer_344 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_341, i64 0, i32 1, i32 1
        %eraser_pointer_345 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_341, i64 0, i32 1, i32 2
        store ptr @returnAddress_305, ptr %returnAddress_pointer_343, !noalias !2
        store ptr @sharer_228, ptr %sharer_pointer_344, !noalias !2
        store ptr @eraser_232, ptr %eraser_pointer_345, !noalias !2
        
        %tag_346 = extractvalue %Pos %v_r_2562_13_44_4249, 0
        %fields_347 = extractvalue %Pos %v_r_2562_13_44_4249, 1
        switch i64 %tag_346, label %label_348 [i64 0, label %label_353 i64 1, label %label_367]
    
    label_348:
        
        ret void
    
    label_353:
        
        %make_5411_temporary_349 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5411 = insertvalue %Pos %make_5411_temporary_349, %Object null, 1
        
        
        
        %stackPointer_351 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_352 = getelementptr %FrameHeader, %StackPointer %stackPointer_351, i64 0, i32 0
        %returnAddress_350 = load %ReturnAddress, ptr %returnAddress_pointer_352, !noalias !2
        musttail call tailcc void %returnAddress_350(%Pos %make_5411, %Stack %stack)
        ret void
    
    label_367:
        %environment_354 = call ccc %Environment @objectEnvironment(%Object %fields_347)
        %v_y_2803_10_21_52_4243_pointer_355 = getelementptr <{%Pos, %Pos}>, %Environment %environment_354, i64 0, i32 0
        %v_y_2803_10_21_52_4243 = load %Pos, ptr %v_y_2803_10_21_52_4243_pointer_355, !noalias !2
        %v_y_2804_11_22_53_4247_pointer_356 = getelementptr <{%Pos, %Pos}>, %Environment %environment_354, i64 0, i32 1
        %v_y_2804_11_22_53_4247 = load %Pos, ptr %v_y_2804_11_22_53_4247_pointer_356, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2803_10_21_52_4243)
        call ccc void @eraseObject(%Object %fields_347)
        
        %fields_357 = call ccc %Object @newObject(ptr @eraser_360, i64 16)
        %environment_358 = call ccc %Environment @objectEnvironment(%Object %fields_357)
        %v_y_2803_10_21_52_4243_pointer_362 = getelementptr <{%Pos}>, %Environment %environment_358, i64 0, i32 0
        store %Pos %v_y_2803_10_21_52_4243, ptr %v_y_2803_10_21_52_4243_pointer_362, !noalias !2
        %make_5412_temporary_363 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5412 = insertvalue %Pos %make_5412_temporary_363, %Object %fields_357, 1
        
        
        
        %stackPointer_365 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_366 = getelementptr %FrameHeader, %StackPointer %stackPointer_365, i64 0, i32 0
        %returnAddress_364 = load %ReturnAddress, ptr %returnAddress_pointer_366, !noalias !2
        musttail call tailcc void %returnAddress_364(%Pos %make_5412, %Stack %stack)
        ret void
}



define tailcc void @main_2445(%Stack %stack) {
        
    entry:
        
        %stackPointer_258 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_259 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_258, i64 0, i32 1, i32 0
        %sharer_pointer_260 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_258, i64 0, i32 1, i32 1
        %eraser_pointer_261 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_258, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_259, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_260, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_261, !noalias !2
        
        %stack_262 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4199 = call ccc %Prompt @currentPrompt(%Stack %stack_262)
        %stackPointer_268 = call ccc %StackPointer @stackAllocate(%Stack %stack_262, i64 24)
        %returnAddress_pointer_269 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 0
        %sharer_pointer_270 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 1
        %eraser_pointer_271 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_268, i64 0, i32 1, i32 2
        store ptr @returnAddress_263, ptr %returnAddress_pointer_269, !noalias !2
        store ptr @sharer_130, ptr %sharer_pointer_270, !noalias !2
        store ptr @eraser_132, ptr %eraser_pointer_271, !noalias !2
        
        %closure_281 = call ccc %Object @newObject(ptr @eraser_150, i64 8)
        %environment_282 = call ccc %Environment @objectEnvironment(%Object %closure_281)
        %p_8_9_4199_pointer_284 = getelementptr <{%Prompt}>, %Environment %environment_282, i64 0, i32 0
        store %Prompt %p_8_9_4199, ptr %p_8_9_4199_pointer_284, !noalias !2
        %vtable_temporary_285 = insertvalue %Neg zeroinitializer, ptr @vtable_280, 0
        %Exception_9_10_4196 = insertvalue %Neg %vtable_temporary_285, %Object %closure_281, 1
        
        %pureApp_5405 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5407 = add i64 1, 0
        
        %pureApp_5406 = call ccc i64 @infixSub_105(i64 %pureApp_5405, i64 %longLiteral_5407)
        
        
        
        %make_5408_temporary_301 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5408 = insertvalue %Pos %make_5408_temporary_301, %Object null, 1
        
        
        %stackPointer_370 = call ccc %StackPointer @stackAllocate(%Stack %stack_262, i64 40)
        %Exception_9_10_4196_pointer_371 = getelementptr <{%Neg}>, %StackPointer %stackPointer_370, i64 0, i32 0
        store %Neg %Exception_9_10_4196, ptr %Exception_9_10_4196_pointer_371, !noalias !2
        %returnAddress_pointer_372 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_370, i64 0, i32 1, i32 0
        %sharer_pointer_373 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_370, i64 0, i32 1, i32 1
        %eraser_pointer_374 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_370, i64 0, i32 1, i32 2
        store ptr @returnAddress_302, ptr %returnAddress_pointer_372, !noalias !2
        store ptr @sharer_228, ptr %sharer_pointer_373, !noalias !2
        store ptr @eraser_232, ptr %eraser_pointer_374, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_34_4237(i64 %pureApp_5406, %Pos %make_5408, %Stack %stack_262)
        ret void
}


@utf8StringLiteral_5342.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5344.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5347.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_375(%Pos %v_r_2734_3545, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_376 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_377 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_376, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_377, !noalias !2
        %index_2107_pointer_378 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_376, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_378, !noalias !2
        %Exception_2362_pointer_379 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_376, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_379, !noalias !2
        
        %tag_380 = extractvalue %Pos %v_r_2734_3545, 0
        %fields_381 = extractvalue %Pos %v_r_2734_3545, 1
        switch i64 %tag_380, label %label_382 [i64 0, label %label_386 i64 1, label %label_392]
    
    label_382:
        
        ret void
    
    label_386:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5338 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_384 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_385 = getelementptr %FrameHeader, %StackPointer %stackPointer_384, i64 0, i32 0
        %returnAddress_383 = load %ReturnAddress, ptr %returnAddress_pointer_385, !noalias !2
        musttail call tailcc void %returnAddress_383(i64 %pureApp_5338, %Stack %stack)
        ret void
    
    label_392:
        
        %make_5339_temporary_387 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5339 = insertvalue %Pos %make_5339_temporary_387, %Object null, 1
        
        
        
        %pureApp_5340 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5342 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5342.lit)
        
        %pureApp_5341 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5342, %Pos %pureApp_5340)
        
        
        
        %utf8StringLiteral_5344 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5344.lit)
        
        %pureApp_5343 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5341, %Pos %utf8StringLiteral_5344)
        
        
        
        %pureApp_5345 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5343, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5347 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5347.lit)
        
        %pureApp_5346 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5345, %Pos %utf8StringLiteral_5347)
        
        
        
        %vtable_388 = extractvalue %Neg %Exception_2362, 0
        %closure_389 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_390 = getelementptr ptr, ptr %vtable_388, i64 0
        %functionPointer_391 = load ptr, ptr %functionPointer_pointer_390, !noalias !2
        musttail call tailcc void %functionPointer_391(%Object %closure_389, %Pos %make_5339, %Pos %pureApp_5346, %Stack %stack)
        ret void
}



define ccc void @sharer_396(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_397 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_393_pointer_398 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_397, i64 0, i32 0
        %str_2106_393 = load %Pos, ptr %str_2106_393_pointer_398, !noalias !2
        %index_2107_394_pointer_399 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_397, i64 0, i32 1
        %index_2107_394 = load i64, ptr %index_2107_394_pointer_399, !noalias !2
        %Exception_2362_395_pointer_400 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_397, i64 0, i32 2
        %Exception_2362_395 = load %Neg, ptr %Exception_2362_395_pointer_400, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_393)
        call ccc void @shareNegative(%Neg %Exception_2362_395)
        call ccc void @shareFrames(%StackPointer %stackPointer_397)
        ret void
}



define ccc void @eraser_404(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_405 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_401_pointer_406 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_405, i64 0, i32 0
        %str_2106_401 = load %Pos, ptr %str_2106_401_pointer_406, !noalias !2
        %index_2107_402_pointer_407 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_405, i64 0, i32 1
        %index_2107_402 = load i64, ptr %index_2107_402_pointer_407, !noalias !2
        %Exception_2362_403_pointer_408 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_405, i64 0, i32 2
        %Exception_2362_403 = load %Neg, ptr %Exception_2362_403_pointer_408, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_401)
        call ccc void @eraseNegative(%Neg %Exception_2362_403)
        call ccc void @eraseFrames(%StackPointer %stackPointer_405)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5337 = add i64 0, 0
        
        %pureApp_5336 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5337)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_409 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_410 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_409, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_410, !noalias !2
        %index_2107_pointer_411 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_409, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_411, !noalias !2
        %Exception_2362_pointer_412 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_409, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_412, !noalias !2
        %returnAddress_pointer_413 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_409, i64 0, i32 1, i32 0
        %sharer_pointer_414 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_409, i64 0, i32 1, i32 1
        %eraser_pointer_415 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_409, i64 0, i32 1, i32 2
        store ptr @returnAddress_375, ptr %returnAddress_pointer_413, !noalias !2
        store ptr @sharer_396, ptr %sharer_pointer_414, !noalias !2
        store ptr @eraser_404, ptr %eraser_pointer_415, !noalias !2
        
        %tag_416 = extractvalue %Pos %pureApp_5336, 0
        %fields_417 = extractvalue %Pos %pureApp_5336, 1
        switch i64 %tag_416, label %label_418 [i64 0, label %label_422 i64 1, label %label_427]
    
    label_418:
        
        ret void
    
    label_422:
        
        %pureApp_5348 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5349 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5348)
        
        
        
        %stackPointer_420 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_421 = getelementptr %FrameHeader, %StackPointer %stackPointer_420, i64 0, i32 0
        %returnAddress_419 = load %ReturnAddress, ptr %returnAddress_pointer_421, !noalias !2
        musttail call tailcc void %returnAddress_419(%Pos %pureApp_5349, %Stack %stack)
        ret void
    
    label_427:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5350_temporary_423 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5350 = insertvalue %Pos %booleanLiteral_5350_temporary_423, %Object null, 1
        
        %stackPointer_425 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_426 = getelementptr %FrameHeader, %StackPointer %stackPointer_425, i64 0, i32 0
        %returnAddress_424 = load %ReturnAddress, ptr %returnAddress_pointer_426, !noalias !2
        musttail call tailcc void %returnAddress_424(%Pos %booleanLiteral_5350, %Stack %stack)
        ret void
}


@utf8StringLiteral_5298.lit = private constant [21 x i8] c"\4e\6f\74\20\61\20\76\61\6c\69\64\20\6e\75\6d\62\65\72\3a\20\27"

@utf8StringLiteral_5300.lit = private constant [1 x i8] c"\27"

@utf8StringLiteral_5305.lit = private constant [21 x i8] c"\4e\6f\74\20\61\20\76\61\6c\69\64\20\6e\75\6d\62\65\72\3a\20\27"

@utf8StringLiteral_5307.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_428(%Pos %v_r_2652_3561, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_429 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %tmp_5288_pointer_430 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_429, i64 0, i32 0
        %tmp_5288 = load i64, ptr %tmp_5288_pointer_430, !noalias !2
        %str_2061_pointer_431 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_429, i64 0, i32 1
        %str_2061 = load %Pos, ptr %str_2061_pointer_431, !noalias !2
        %index_2146_pointer_432 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_429, i64 0, i32 2
        %index_2146 = load i64, ptr %index_2146_pointer_432, !noalias !2
        %acc_2147_pointer_433 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_429, i64 0, i32 3
        %acc_2147 = load i64, ptr %acc_2147_pointer_433, !noalias !2
        %Exception_2356_pointer_434 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_429, i64 0, i32 4
        %Exception_2356 = load %Neg, ptr %Exception_2356_pointer_434, !noalias !2
        
        %tag_435 = extractvalue %Pos %v_r_2652_3561, 0
        %fields_436 = extractvalue %Pos %v_r_2652_3561, 1
        switch i64 %tag_435, label %label_437 [i64 1, label %label_460 i64 0, label %label_467]
    
    label_437:
        
        ret void
    
    label_442:
        
        ret void
    
    label_448:
        
        %utf8StringLiteral_5298 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5298.lit)
        
        %pureApp_5297 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5298, %Pos %str_2061)
        
        
        
        %utf8StringLiteral_5300 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5300.lit)
        
        %pureApp_5299 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5297, %Pos %utf8StringLiteral_5300)
        
        
        
        %make_5301_temporary_443 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5301 = insertvalue %Pos %make_5301_temporary_443, %Object null, 1
        
        
        
        %vtable_444 = extractvalue %Neg %Exception_2356, 0
        %closure_445 = extractvalue %Neg %Exception_2356, 1
        %functionPointer_pointer_446 = getelementptr ptr, ptr %vtable_444, i64 0
        %functionPointer_447 = load ptr, ptr %functionPointer_pointer_446, !noalias !2
        musttail call tailcc void %functionPointer_447(%Object %closure_445, %Pos %make_5301, %Pos %pureApp_5299, %Stack %stack)
        ret void
    
    label_451:
        
        ret void
    
    label_457:
        
        %utf8StringLiteral_5305 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5305.lit)
        
        %pureApp_5304 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5305, %Pos %str_2061)
        
        
        
        %utf8StringLiteral_5307 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5307.lit)
        
        %pureApp_5306 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5304, %Pos %utf8StringLiteral_5307)
        
        
        
        %make_5308_temporary_452 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5308 = insertvalue %Pos %make_5308_temporary_452, %Object null, 1
        
        
        
        %vtable_453 = extractvalue %Neg %Exception_2356, 0
        %closure_454 = extractvalue %Neg %Exception_2356, 1
        %functionPointer_pointer_455 = getelementptr ptr, ptr %vtable_453, i64 0
        %functionPointer_456 = load ptr, ptr %functionPointer_pointer_455, !noalias !2
        musttail call tailcc void %functionPointer_456(%Object %closure_454, %Pos %make_5308, %Pos %pureApp_5306, %Stack %stack)
        ret void
    
    label_458:
        
        %longLiteral_5310 = add i64 1, 0
        
        %pureApp_5309 = call ccc i64 @infixAdd_96(i64 %index_2146, i64 %longLiteral_5310)
        
        
        
        %longLiteral_5312 = add i64 10, 0
        
        %pureApp_5311 = call ccc i64 @infixMul_99(i64 %longLiteral_5312, i64 %acc_2147)
        
        
        
        %pureApp_5313 = call ccc i64 @toInt_2085(i64 %pureApp_5294)
        
        
        
        %pureApp_5314 = call ccc i64 @infixSub_105(i64 %pureApp_5313, i64 %tmp_5288)
        
        
        
        %pureApp_5315 = call ccc i64 @infixAdd_96(i64 %pureApp_5311, i64 %pureApp_5314)
        
        
        
        
        
        
        musttail call tailcc void @go_2148(i64 %pureApp_5309, i64 %pureApp_5315, i64 %tmp_5288, %Pos %str_2061, %Neg %Exception_2356, %Stack %stack)
        ret void
    
    label_459:
        
        %intLiteral_5303 = add i64 57, 0
        
        %pureApp_5302 = call ccc %Pos @infixLte_2093(i64 %pureApp_5294, i64 %intLiteral_5303)
        
        
        
        %tag_449 = extractvalue %Pos %pureApp_5302, 0
        %fields_450 = extractvalue %Pos %pureApp_5302, 1
        switch i64 %tag_449, label %label_451 [i64 0, label %label_457 i64 1, label %label_458]
    
    label_460:
        %environment_438 = call ccc %Environment @objectEnvironment(%Object %fields_436)
        %v_coe_3468_3566_pointer_439 = getelementptr <{%Pos}>, %Environment %environment_438, i64 0, i32 0
        %v_coe_3468_3566 = load %Pos, ptr %v_coe_3468_3566_pointer_439, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3468_3566)
        call ccc void @eraseObject(%Object %fields_436)
        
        %pureApp_5294 = call ccc i64 @unboxChar_313(%Pos %v_coe_3468_3566)
        
        
        
        %intLiteral_5296 = add i64 48, 0
        
        %pureApp_5295 = call ccc %Pos @infixGte_2099(i64 %pureApp_5294, i64 %intLiteral_5296)
        
        
        
        %tag_440 = extractvalue %Pos %pureApp_5295, 0
        %fields_441 = extractvalue %Pos %pureApp_5295, 1
        switch i64 %tag_440, label %label_442 [i64 0, label %label_448 i64 1, label %label_459]
    
    label_467:
        %environment_461 = call ccc %Environment @objectEnvironment(%Object %fields_436)
        %v_y_2659_2662_pointer_462 = getelementptr <{%Pos, %Pos}>, %Environment %environment_461, i64 0, i32 0
        %v_y_2659_2662 = load %Pos, ptr %v_y_2659_2662_pointer_462, !noalias !2
        %v_y_2660_2661_pointer_463 = getelementptr <{%Pos, %Pos}>, %Environment %environment_461, i64 0, i32 1
        %v_y_2660_2661 = load %Pos, ptr %v_y_2660_2661_pointer_463, !noalias !2
        call ccc void @eraseObject(%Object %fields_436)
        call ccc void @erasePositive(%Pos %str_2061)
        call ccc void @eraseNegative(%Neg %Exception_2356)
        
        %stackPointer_465 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_466 = getelementptr %FrameHeader, %StackPointer %stackPointer_465, i64 0, i32 0
        %returnAddress_464 = load %ReturnAddress, ptr %returnAddress_pointer_466, !noalias !2
        musttail call tailcc void %returnAddress_464(i64 %acc_2147, %Stack %stack)
        ret void
}



define ccc void @sharer_473(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_474 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %tmp_5288_468_pointer_475 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_474, i64 0, i32 0
        %tmp_5288_468 = load i64, ptr %tmp_5288_468_pointer_475, !noalias !2
        %str_2061_469_pointer_476 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_474, i64 0, i32 1
        %str_2061_469 = load %Pos, ptr %str_2061_469_pointer_476, !noalias !2
        %index_2146_470_pointer_477 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_474, i64 0, i32 2
        %index_2146_470 = load i64, ptr %index_2146_470_pointer_477, !noalias !2
        %acc_2147_471_pointer_478 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_474, i64 0, i32 3
        %acc_2147_471 = load i64, ptr %acc_2147_471_pointer_478, !noalias !2
        %Exception_2356_472_pointer_479 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_474, i64 0, i32 4
        %Exception_2356_472 = load %Neg, ptr %Exception_2356_472_pointer_479, !noalias !2
        call ccc void @sharePositive(%Pos %str_2061_469)
        call ccc void @shareNegative(%Neg %Exception_2356_472)
        call ccc void @shareFrames(%StackPointer %stackPointer_474)
        ret void
}



define ccc void @eraser_485(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_486 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %tmp_5288_480_pointer_487 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_486, i64 0, i32 0
        %tmp_5288_480 = load i64, ptr %tmp_5288_480_pointer_487, !noalias !2
        %str_2061_481_pointer_488 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_486, i64 0, i32 1
        %str_2061_481 = load %Pos, ptr %str_2061_481_pointer_488, !noalias !2
        %index_2146_482_pointer_489 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_486, i64 0, i32 2
        %index_2146_482 = load i64, ptr %index_2146_482_pointer_489, !noalias !2
        %acc_2147_483_pointer_490 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_486, i64 0, i32 3
        %acc_2147_483 = load i64, ptr %acc_2147_483_pointer_490, !noalias !2
        %Exception_2356_484_pointer_491 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_486, i64 0, i32 4
        %Exception_2356_484 = load %Neg, ptr %Exception_2356_484_pointer_491, !noalias !2
        call ccc void @erasePositive(%Pos %str_2061_481)
        call ccc void @eraseNegative(%Neg %Exception_2356_484)
        call ccc void @eraseFrames(%StackPointer %stackPointer_486)
        ret void
}



define tailcc void @returnAddress_502(%Pos %returned_5316, %Stack %stack) {
        
    entry:
        
        %stack_503 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_505 = call ccc %StackPointer @stackDeallocate(%Stack %stack_503, i64 24)
        %returnAddress_pointer_506 = getelementptr %FrameHeader, %StackPointer %stackPointer_505, i64 0, i32 0
        %returnAddress_504 = load %ReturnAddress, ptr %returnAddress_pointer_506, !noalias !2
        musttail call tailcc void %returnAddress_504(%Pos %returned_5316, %Stack %stack_503)
        ret void
}



define tailcc void @Exception_7_3739_clause_511(%Object %closure, %Pos %exc_8_3737, %Pos %msg_9_3743, %Stack %stack) {
        
    entry:
        
        %environment_512 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_3740_pointer_513 = getelementptr <{%Prompt}>, %Environment %environment_512, i64 0, i32 0
        %p_6_3740 = load %Prompt, ptr %p_6_3740_pointer_513, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_514 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_3740)
        %k_11_3748 = extractvalue <{%Resumption, %Stack}> %pair_514, 0
        %stack_515 = extractvalue <{%Resumption, %Stack}> %pair_514, 1
        call ccc void @eraseResumption(%Resumption %k_11_3748)
        
        %fields_516 = call ccc %Object @newObject(ptr @eraser_179, i64 32)
        %environment_517 = call ccc %Environment @objectEnvironment(%Object %fields_516)
        %exc_8_3737_pointer_520 = getelementptr <{%Pos, %Pos}>, %Environment %environment_517, i64 0, i32 0
        store %Pos %exc_8_3737, ptr %exc_8_3737_pointer_520, !noalias !2
        %msg_9_3743_pointer_521 = getelementptr <{%Pos, %Pos}>, %Environment %environment_517, i64 0, i32 1
        store %Pos %msg_9_3743, ptr %msg_9_3743_pointer_521, !noalias !2
        %make_5317_temporary_522 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5317 = insertvalue %Pos %make_5317_temporary_522, %Object %fields_516, 1
        
        
        
        %stackPointer_524 = call ccc %StackPointer @stackDeallocate(%Stack %stack_515, i64 24)
        %returnAddress_pointer_525 = getelementptr %FrameHeader, %StackPointer %stackPointer_524, i64 0, i32 0
        %returnAddress_523 = load %ReturnAddress, ptr %returnAddress_pointer_525, !noalias !2
        musttail call tailcc void %returnAddress_523(%Pos %make_5317, %Stack %stack_515)
        ret void
}


@vtable_526 = private constant [1 x ptr] [ptr @Exception_7_3739_clause_511]


define tailcc void @returnAddress_532(i64 %v_coe_3467_6_3750, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5318 = call ccc %Pos @boxChar_311(i64 %v_coe_3467_6_3750)
        
        
        
        %fields_533 = call ccc %Object @newObject(ptr @eraser_360, i64 16)
        %environment_534 = call ccc %Environment @objectEnvironment(%Object %fields_533)
        %tmp_5223_pointer_536 = getelementptr <{%Pos}>, %Environment %environment_534, i64 0, i32 0
        store %Pos %pureApp_5318, ptr %tmp_5223_pointer_536, !noalias !2
        %make_5319_temporary_537 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5319 = insertvalue %Pos %make_5319_temporary_537, %Object %fields_533, 1
        
        
        
        %stackPointer_539 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_540 = getelementptr %FrameHeader, %StackPointer %stackPointer_539, i64 0, i32 0
        %returnAddress_538 = load %ReturnAddress, ptr %returnAddress_pointer_540, !noalias !2
        musttail call tailcc void %returnAddress_538(%Pos %make_5319, %Stack %stack)
        ret void
}



define tailcc void @go_2148(i64 %index_2146, i64 %acc_2147, i64 %tmp_5288, %Pos %str_2061, %Neg %Exception_2356, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %str_2061)
        %stackPointer_492 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %tmp_5288_pointer_493 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_492, i64 0, i32 0
        store i64 %tmp_5288, ptr %tmp_5288_pointer_493, !noalias !2
        %str_2061_pointer_494 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_492, i64 0, i32 1
        store %Pos %str_2061, ptr %str_2061_pointer_494, !noalias !2
        %index_2146_pointer_495 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_492, i64 0, i32 2
        store i64 %index_2146, ptr %index_2146_pointer_495, !noalias !2
        %acc_2147_pointer_496 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_492, i64 0, i32 3
        store i64 %acc_2147, ptr %acc_2147_pointer_496, !noalias !2
        %Exception_2356_pointer_497 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_492, i64 0, i32 4
        store %Neg %Exception_2356, ptr %Exception_2356_pointer_497, !noalias !2
        %returnAddress_pointer_498 = getelementptr <{<{i64, %Pos, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_492, i64 0, i32 1, i32 0
        %sharer_pointer_499 = getelementptr <{<{i64, %Pos, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_492, i64 0, i32 1, i32 1
        %eraser_pointer_500 = getelementptr <{<{i64, %Pos, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_492, i64 0, i32 1, i32 2
        store ptr @returnAddress_428, ptr %returnAddress_pointer_498, !noalias !2
        store ptr @sharer_473, ptr %sharer_pointer_499, !noalias !2
        store ptr @eraser_485, ptr %eraser_pointer_500, !noalias !2
        
        %stack_501 = call ccc %Stack @reset(%Stack %stack)
        %p_6_3740 = call ccc %Prompt @currentPrompt(%Stack %stack_501)
        %stackPointer_507 = call ccc %StackPointer @stackAllocate(%Stack %stack_501, i64 24)
        %returnAddress_pointer_508 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_507, i64 0, i32 1, i32 0
        %sharer_pointer_509 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_507, i64 0, i32 1, i32 1
        %eraser_pointer_510 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_507, i64 0, i32 1, i32 2
        store ptr @returnAddress_502, ptr %returnAddress_pointer_508, !noalias !2
        store ptr @sharer_130, ptr %sharer_pointer_509, !noalias !2
        store ptr @eraser_132, ptr %eraser_pointer_510, !noalias !2
        
        %closure_527 = call ccc %Object @newObject(ptr @eraser_150, i64 8)
        %environment_528 = call ccc %Environment @objectEnvironment(%Object %closure_527)
        %p_6_3740_pointer_530 = getelementptr <{%Prompt}>, %Environment %environment_528, i64 0, i32 0
        store %Prompt %p_6_3740, ptr %p_6_3740_pointer_530, !noalias !2
        %vtable_temporary_531 = insertvalue %Neg zeroinitializer, ptr @vtable_526, 0
        %Exception_7_3739 = insertvalue %Neg %vtable_temporary_531, %Object %closure_527, 1
        %stackPointer_541 = call ccc %StackPointer @stackAllocate(%Stack %stack_501, i64 24)
        %returnAddress_pointer_542 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_541, i64 0, i32 1, i32 0
        %sharer_pointer_543 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_541, i64 0, i32 1, i32 1
        %eraser_pointer_544 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_541, i64 0, i32 1, i32 2
        store ptr @returnAddress_532, ptr %returnAddress_pointer_542, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_543, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_544, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %str_2061, i64 %index_2146, %Neg %Exception_7_3739, %Stack %stack_501)
        ret void
}



define tailcc void @returnAddress_545(%Pos %v_coe_3474_3572, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5320 = call ccc i64 @unboxInt_303(%Pos %v_coe_3474_3572)
        
        
        
        %stackPointer_547 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_548 = getelementptr %FrameHeader, %StackPointer %stackPointer_547, i64 0, i32 0
        %returnAddress_546 = load %ReturnAddress, ptr %returnAddress_pointer_548, !noalias !2
        musttail call tailcc void %returnAddress_546(i64 %pureApp_5320, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_554(%Pos %returned_5321, %Stack %stack) {
        
    entry:
        
        %stack_555 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_557 = call ccc %StackPointer @stackDeallocate(%Stack %stack_555, i64 24)
        %returnAddress_pointer_558 = getelementptr %FrameHeader, %StackPointer %stackPointer_557, i64 0, i32 0
        %returnAddress_556 = load %ReturnAddress, ptr %returnAddress_pointer_558, !noalias !2
        musttail call tailcc void %returnAddress_556(%Pos %returned_5321, %Stack %stack_555)
        ret void
}


@utf8StringLiteral_5325.lit = private constant [34 x i8] c"\45\6d\70\74\79\20\73\74\72\69\6e\67\20\69\73\20\6e\6f\74\20\61\20\76\61\6c\69\64\20\6e\75\6d\62\65\72"


define tailcc void @Exception_9_3810_clause_563(%Object %closure, %Pos %exception_10_5322, %Pos %msg_11_5323, %Stack %stack) {
        
    entry:
        
        %environment_564 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_3812_pointer_565 = getelementptr <{%Prompt, %Neg}>, %Environment %environment_564, i64 0, i32 0
        %p_8_3812 = load %Prompt, ptr %p_8_3812_pointer_565, !noalias !2
        %Exception_2356_pointer_566 = getelementptr <{%Prompt, %Neg}>, %Environment %environment_564, i64 0, i32 1
        %Exception_2356 = load %Neg, ptr %Exception_2356_pointer_566, !noalias !2
        call ccc void @shareNegative(%Neg %Exception_2356)
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_5322)
        call ccc void @erasePositive(%Pos %msg_11_5323)
        
        %pair_567 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_3812)
        %k_13_3815 = extractvalue <{%Resumption, %Stack}> %pair_567, 0
        %stack_568 = extractvalue <{%Resumption, %Stack}> %pair_567, 1
        call ccc void @eraseResumption(%Resumption %k_13_3815)
        
        %make_5324_temporary_569 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5324 = insertvalue %Pos %make_5324_temporary_569, %Object null, 1
        
        
        
        %utf8StringLiteral_5325 = call ccc %Pos @c_bytearray_construct(i64 34, ptr @utf8StringLiteral_5325.lit)
        
        %vtable_570 = extractvalue %Neg %Exception_2356, 0
        %closure_571 = extractvalue %Neg %Exception_2356, 1
        %functionPointer_pointer_572 = getelementptr ptr, ptr %vtable_570, i64 0
        %functionPointer_573 = load ptr, ptr %functionPointer_pointer_572, !noalias !2
        musttail call tailcc void %functionPointer_573(%Object %closure_571, %Pos %make_5324, %Pos %utf8StringLiteral_5325, %Stack %stack_568)
        ret void
}


@vtable_574 = private constant [1 x ptr] [ptr @Exception_9_3810_clause_563]


define ccc void @eraser_579(%Environment %environment) {
        
    entry:
        
        %p_8_3812_577_pointer_580 = getelementptr <{%Prompt, %Neg}>, %Environment %environment, i64 0, i32 0
        %p_8_3812_577 = load %Prompt, ptr %p_8_3812_577_pointer_580, !noalias !2
        %Exception_2356_578_pointer_581 = getelementptr <{%Prompt, %Neg}>, %Environment %environment, i64 0, i32 1
        %Exception_2356_578 = load %Neg, ptr %Exception_2356_578_pointer_581, !noalias !2
        call ccc void @eraseNegative(%Neg %Exception_2356_578)
        ret void
}



define tailcc void @returnAddress_590(i64 %v_coe_3472_22_3826, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5328 = call ccc %Pos @boxInt_301(i64 %v_coe_3472_22_3826)
        
        
        
        %stackPointer_592 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_593 = getelementptr %FrameHeader, %StackPointer %stackPointer_592, i64 0, i32 0
        %returnAddress_591 = load %ReturnAddress, ptr %returnAddress_pointer_593, !noalias !2
        musttail call tailcc void %returnAddress_591(%Pos %pureApp_5328, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_602(i64 %v_r_2666_1_9_20_3830, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5332 = add i64 0, 0
        
        %pureApp_5331 = call ccc i64 @infixSub_105(i64 %longLiteral_5332, i64 %v_r_2666_1_9_20_3830)
        
        
        
        %stackPointer_604 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_605 = getelementptr %FrameHeader, %StackPointer %stackPointer_604, i64 0, i32 0
        %returnAddress_603 = load %ReturnAddress, ptr %returnAddress_pointer_605, !noalias !2
        musttail call tailcc void %returnAddress_603(i64 %pureApp_5331, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_585(i64 %v_r_2665_3_14_3838, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_586 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %tmp_5288_pointer_587 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_586, i64 0, i32 0
        %tmp_5288 = load i64, ptr %tmp_5288_pointer_587, !noalias !2
        %str_2061_pointer_588 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_586, i64 0, i32 1
        %str_2061 = load %Pos, ptr %str_2061_pointer_588, !noalias !2
        %Exception_2356_pointer_589 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_586, i64 0, i32 2
        %Exception_2356 = load %Neg, ptr %Exception_2356_pointer_589, !noalias !2
        
        %intLiteral_5327 = add i64 45, 0
        
        %pureApp_5326 = call ccc %Pos @infixEq_78(i64 %v_r_2665_3_14_3838, i64 %intLiteral_5327)
        
        
        %stackPointer_594 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_595 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_594, i64 0, i32 1, i32 0
        %sharer_pointer_596 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_594, i64 0, i32 1, i32 1
        %eraser_pointer_597 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_594, i64 0, i32 1, i32 2
        store ptr @returnAddress_590, ptr %returnAddress_pointer_595, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_596, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_597, !noalias !2
        
        %tag_598 = extractvalue %Pos %pureApp_5326, 0
        %fields_599 = extractvalue %Pos %pureApp_5326, 1
        switch i64 %tag_598, label %label_600 [i64 0, label %label_601 i64 1, label %label_610]
    
    label_600:
        
        ret void
    
    label_601:
        
        %longLiteral_5329 = add i64 0, 0
        
        %longLiteral_5330 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_2148(i64 %longLiteral_5329, i64 %longLiteral_5330, i64 %tmp_5288, %Pos %str_2061, %Neg %Exception_2356, %Stack %stack)
        ret void
    
    label_610:
        %stackPointer_606 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_607 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_606, i64 0, i32 1, i32 0
        %sharer_pointer_608 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_606, i64 0, i32 1, i32 1
        %eraser_pointer_609 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_606, i64 0, i32 1, i32 2
        store ptr @returnAddress_602, ptr %returnAddress_pointer_607, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_608, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_609, !noalias !2
        
        %longLiteral_5333 = add i64 1, 0
        
        %longLiteral_5334 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_2148(i64 %longLiteral_5333, i64 %longLiteral_5334, i64 %tmp_5288, %Pos %str_2061, %Neg %Exception_2356, %Stack %stack)
        ret void
}



define ccc void @sharer_614(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_615 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer, i64 -1
        %tmp_5288_611_pointer_616 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_615, i64 0, i32 0
        %tmp_5288_611 = load i64, ptr %tmp_5288_611_pointer_616, !noalias !2
        %str_2061_612_pointer_617 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_615, i64 0, i32 1
        %str_2061_612 = load %Pos, ptr %str_2061_612_pointer_617, !noalias !2
        %Exception_2356_613_pointer_618 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_615, i64 0, i32 2
        %Exception_2356_613 = load %Neg, ptr %Exception_2356_613_pointer_618, !noalias !2
        call ccc void @sharePositive(%Pos %str_2061_612)
        call ccc void @shareNegative(%Neg %Exception_2356_613)
        call ccc void @shareFrames(%StackPointer %stackPointer_615)
        ret void
}



define ccc void @eraser_622(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_623 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer, i64 -1
        %tmp_5288_619_pointer_624 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_623, i64 0, i32 0
        %tmp_5288_619 = load i64, ptr %tmp_5288_619_pointer_624, !noalias !2
        %str_2061_620_pointer_625 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_623, i64 0, i32 1
        %str_2061_620 = load %Pos, ptr %str_2061_620_pointer_625, !noalias !2
        %Exception_2356_621_pointer_626 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_623, i64 0, i32 2
        %Exception_2356_621 = load %Neg, ptr %Exception_2356_621_pointer_626, !noalias !2
        call ccc void @erasePositive(%Pos %str_2061_620)
        call ccc void @eraseNegative(%Neg %Exception_2356_621)
        call ccc void @eraseFrames(%StackPointer %stackPointer_623)
        ret void
}



define tailcc void @toInt_2062(%Pos %str_2061, %Neg %Exception_2356, %Stack %stack) {
        
    entry:
        
        
        %intLiteral_5293 = add i64 48, 0
        
        %pureApp_5292 = call ccc i64 @toInt_2085(i64 %intLiteral_5293)
        
        
        %stackPointer_549 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_550 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_549, i64 0, i32 1, i32 0
        %sharer_pointer_551 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_549, i64 0, i32 1, i32 1
        %eraser_pointer_552 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_549, i64 0, i32 1, i32 2
        store ptr @returnAddress_545, ptr %returnAddress_pointer_550, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_551, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_552, !noalias !2
        
        %stack_553 = call ccc %Stack @reset(%Stack %stack)
        %p_8_3812 = call ccc %Prompt @currentPrompt(%Stack %stack_553)
        %stackPointer_559 = call ccc %StackPointer @stackAllocate(%Stack %stack_553, i64 24)
        %returnAddress_pointer_560 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_559, i64 0, i32 1, i32 0
        %sharer_pointer_561 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_559, i64 0, i32 1, i32 1
        %eraser_pointer_562 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_559, i64 0, i32 1, i32 2
        store ptr @returnAddress_554, ptr %returnAddress_pointer_560, !noalias !2
        store ptr @sharer_130, ptr %sharer_pointer_561, !noalias !2
        store ptr @eraser_132, ptr %eraser_pointer_562, !noalias !2
        
        %closure_575 = call ccc %Object @newObject(ptr @eraser_579, i64 24)
        %environment_576 = call ccc %Environment @objectEnvironment(%Object %closure_575)
        call ccc void @shareNegative(%Neg %Exception_2356)
        %p_8_3812_pointer_582 = getelementptr <{%Prompt, %Neg}>, %Environment %environment_576, i64 0, i32 0
        store %Prompt %p_8_3812, ptr %p_8_3812_pointer_582, !noalias !2
        %Exception_2356_pointer_583 = getelementptr <{%Prompt, %Neg}>, %Environment %environment_576, i64 0, i32 1
        store %Neg %Exception_2356, ptr %Exception_2356_pointer_583, !noalias !2
        %vtable_temporary_584 = insertvalue %Neg zeroinitializer, ptr @vtable_574, 0
        %Exception_9_3810 = insertvalue %Neg %vtable_temporary_584, %Object %closure_575, 1
        call ccc void @sharePositive(%Pos %str_2061)
        %stackPointer_627 = call ccc %StackPointer @stackAllocate(%Stack %stack_553, i64 64)
        %tmp_5288_pointer_628 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_627, i64 0, i32 0
        store i64 %pureApp_5292, ptr %tmp_5288_pointer_628, !noalias !2
        %str_2061_pointer_629 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_627, i64 0, i32 1
        store %Pos %str_2061, ptr %str_2061_pointer_629, !noalias !2
        %Exception_2356_pointer_630 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_627, i64 0, i32 2
        store %Neg %Exception_2356, ptr %Exception_2356_pointer_630, !noalias !2
        %returnAddress_pointer_631 = getelementptr <{<{i64, %Pos, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_627, i64 0, i32 1, i32 0
        %sharer_pointer_632 = getelementptr <{<{i64, %Pos, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_627, i64 0, i32 1, i32 1
        %eraser_pointer_633 = getelementptr <{<{i64, %Pos, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_627, i64 0, i32 1, i32 2
        store ptr @returnAddress_585, ptr %returnAddress_pointer_631, !noalias !2
        store ptr @sharer_614, ptr %sharer_pointer_632, !noalias !2
        store ptr @eraser_622, ptr %eraser_pointer_633, !noalias !2
        
        %longLiteral_5335 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %str_2061, i64 %longLiteral_5335, %Neg %Exception_9_3810, %Stack %stack_553)
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
        
        musttail call tailcc void @main_2445(%Stack %stack)
        ret void
}
