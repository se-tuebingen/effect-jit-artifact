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



define ccc %Pos @panic_552(%Pos %msg_551) {
    ; declaration extern
    ; variable
    
    call void @c_io_println_String(%Pos %msg_551)
    call void @exit(i32 1)
    ret %Pos zeroinitializer ; Unit
  
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



define tailcc void @returnAddress_10(i64 %v_r_3004_2_5191, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_11 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %i_6_5187_pointer_12 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 0
        %i_6_5187 = load i64, ptr %i_6_5187_pointer_12, !noalias !2
        %tmp_5370_pointer_13 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_11, i64 0, i32 1
        %tmp_5370 = load i64, ptr %tmp_5370_pointer_13, !noalias !2
        
        %longLiteral_5478 = add i64 1, 0
        
        %pureApp_5477 = call ccc i64 @infixAdd_96(i64 %i_6_5187, i64 %longLiteral_5478)
        
        
        
        
        
        musttail call tailcc void @loop_5_5185(i64 %pureApp_5477, i64 %tmp_5370, %Stack %stack)
        ret void
}



define ccc void @sharer_16(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_17 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5187_14_pointer_18 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 0
        %i_6_5187_14 = load i64, ptr %i_6_5187_14_pointer_18, !noalias !2
        %tmp_5370_15_pointer_19 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_17, i64 0, i32 1
        %tmp_5370_15 = load i64, ptr %tmp_5370_15_pointer_19, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_17)
        ret void
}



define ccc void @eraser_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{i64, i64}>, %StackPointer %stackPointer, i64 -1
        %i_6_5187_20_pointer_24 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 0
        %i_6_5187_20 = load i64, ptr %i_6_5187_20_pointer_24, !noalias !2
        %tmp_5370_21_pointer_25 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_23, i64 0, i32 1
        %tmp_5370_21 = load i64, ptr %tmp_5370_21_pointer_25, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_23)
        ret void
}



define tailcc void @loop_5_5185(i64 %i_6_5187, i64 %tmp_5370, %Stack %stack) {
        
    entry:
        
        
        %pureApp_5475 = call ccc %Pos @infixLt_178(i64 %i_6_5187, i64 %tmp_5370)
        
        
        
        %tag_2 = extractvalue %Pos %pureApp_5475, 0
        %fields_3 = extractvalue %Pos %pureApp_5475, 1
        switch i64 %tag_2, label %label_4 [i64 0, label %label_9 i64 1, label %label_32]
    
    label_4:
        
        ret void
    
    label_9:
        
        %unitLiteral_5476_temporary_5 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5476 = insertvalue %Pos %unitLiteral_5476_temporary_5, %Object null, 1
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %unitLiteral_5476, %Stack %stack)
        ret void
    
    label_32:
        %stackPointer_26 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %i_6_5187_pointer_27 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        store i64 %i_6_5187, ptr %i_6_5187_pointer_27, !noalias !2
        %tmp_5370_pointer_28 = getelementptr <{i64, i64}>, %StackPointer %stackPointer_26, i64 0, i32 1
        store i64 %tmp_5370, ptr %tmp_5370_pointer_28, !noalias !2
        %returnAddress_pointer_29 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 0
        %sharer_pointer_30 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 1
        %eraser_pointer_31 = getelementptr <{<{i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_26, i64 0, i32 1, i32 2
        store ptr @returnAddress_10, ptr %returnAddress_pointer_29, !noalias !2
        store ptr @sharer_16, ptr %sharer_pointer_30, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_31, !noalias !2
        
        %longLiteral_5479 = add i64 13, 0
        
        
        
        musttail call tailcc void @run_2856(i64 %longLiteral_5479, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_34(i64 %r_2886, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5481 = call ccc %Pos @show_14(i64 %r_2886)
        
        
        
        %pureApp_5482 = call ccc %Pos @println_1(%Pos %pureApp_5481)
        
        
        
        %stackPointer_36 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_37 = getelementptr %FrameHeader, %StackPointer %stackPointer_36, i64 0, i32 0
        %returnAddress_35 = load %ReturnAddress, ptr %returnAddress_pointer_37, !noalias !2
        musttail call tailcc void %returnAddress_35(%Pos %pureApp_5482, %Stack %stack)
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



define tailcc void @returnAddress_33(%Pos %v_r_3006_5480, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        call ccc void @erasePositive(%Pos %v_r_3006_5480)
        %stackPointer_42 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_43 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 0
        %sharer_pointer_44 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 1
        %eraser_pointer_45 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_42, i64 0, i32 1, i32 2
        store ptr @returnAddress_34, ptr %returnAddress_pointer_43, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_44, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_45, !noalias !2
        
        %longLiteral_5483 = add i64 13, 0
        
        
        
        musttail call tailcc void @run_2856(i64 %longLiteral_5483, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_4046_4110, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5472 = call ccc i64 @unboxInt_303(%Pos %v_coe_4046_4110)
        
        
        
        %longLiteral_5474 = add i64 1, 0
        
        %pureApp_5473 = call ccc i64 @infixSub_105(i64 %pureApp_5472, i64 %longLiteral_5474)
        
        
        %stackPointer_46 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_47 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 0
        %sharer_pointer_48 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 1
        %eraser_pointer_49 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_46, i64 0, i32 1, i32 2
        store ptr @returnAddress_33, ptr %returnAddress_pointer_47, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_48, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_49, !noalias !2
        
        %longLiteral_5484 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_5185(i64 %longLiteral_5484, i64 %pureApp_5473, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_55(%Pos %returned_5485, %Stack %stack) {
        
    entry:
        
        %stack_56 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_58 = call ccc %StackPointer @stackDeallocate(%Stack %stack_56, i64 24)
        %returnAddress_pointer_59 = getelementptr %FrameHeader, %StackPointer %stackPointer_58, i64 0, i32 0
        %returnAddress_57 = load %ReturnAddress, ptr %returnAddress_pointer_59, !noalias !2
        musttail call tailcc void %returnAddress_57(%Pos %returned_5485, %Stack %stack_56)
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
        
        %tmp_5343_73_pointer_76 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5343_73 = load %Pos, ptr %tmp_5343_73_pointer_76, !noalias !2
        %acc_3_3_5_169_5036_74_pointer_77 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_5036_74 = load %Pos, ptr %acc_3_3_5_169_5036_74_pointer_77, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5343_73)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_5036_74)
        ret void
}



define tailcc void @toList_1_1_3_167_4868(i64 %start_2_2_4_168_4972, %Pos %acc_3_3_5_169_5036, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5487 = add i64 1, 0
        
        %pureApp_5486 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4972, i64 %longLiteral_5487)
        
        
        
        %tag_68 = extractvalue %Pos %pureApp_5486, 0
        %fields_69 = extractvalue %Pos %pureApp_5486, 1
        switch i64 %tag_68, label %label_70 [i64 0, label %label_81 i64 1, label %label_85]
    
    label_70:
        
        ret void
    
    label_81:
        
        %pureApp_5488 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4972)
        
        
        
        %longLiteral_5490 = add i64 1, 0
        
        %pureApp_5489 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4972, i64 %longLiteral_5490)
        
        
        
        %fields_71 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_72 = call ccc %Environment @objectEnvironment(%Object %fields_71)
        %tmp_5343_pointer_78 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 0
        store %Pos %pureApp_5488, ptr %tmp_5343_pointer_78, !noalias !2
        %acc_3_3_5_169_5036_pointer_79 = getelementptr <{%Pos, %Pos}>, %Environment %environment_72, i64 0, i32 1
        store %Pos %acc_3_3_5_169_5036, ptr %acc_3_3_5_169_5036_pointer_79, !noalias !2
        %make_5491_temporary_80 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5491 = insertvalue %Pos %make_5491_temporary_80, %Object %fields_71, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4868(i64 %pureApp_5489, %Pos %make_5491, %Stack %stack)
        ret void
    
    label_85:
        
        %stackPointer_83 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_84 = getelementptr %FrameHeader, %StackPointer %stackPointer_83, i64 0, i32 0
        %returnAddress_82 = load %ReturnAddress, ptr %returnAddress_pointer_84, !noalias !2
        musttail call tailcc void %returnAddress_82(%Pos %acc_3_3_5_169_5036, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_96(%Pos %v_r_3191_32_59_223_4937, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_97 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %acc_8_35_199_4953_pointer_98 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 0
        %acc_8_35_199_4953 = load i64, ptr %acc_8_35_199_4953_pointer_98, !noalias !2
        %v_r_3001_30_194_5122_pointer_99 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 1
        %v_r_3001_30_194_5122 = load %Pos, ptr %v_r_3001_30_194_5122_pointer_99, !noalias !2
        %p_8_9_4817_pointer_100 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 2
        %p_8_9_4817 = load %Prompt, ptr %p_8_9_4817_pointer_100, !noalias !2
        %index_7_34_198_5027_pointer_101 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 3
        %index_7_34_198_5027 = load i64, ptr %index_7_34_198_5027_pointer_101, !noalias !2
        %tmp_5350_pointer_102 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_97, i64 0, i32 4
        %tmp_5350 = load i64, ptr %tmp_5350_pointer_102, !noalias !2
        
        %tag_103 = extractvalue %Pos %v_r_3191_32_59_223_4937, 0
        %fields_104 = extractvalue %Pos %v_r_3191_32_59_223_4937, 1
        switch i64 %tag_103, label %label_105 [i64 1, label %label_128 i64 0, label %label_135]
    
    label_105:
        
        ret void
    
    label_110:
        
        ret void
    
    label_116:
        call ccc void @erasePositive(%Pos %v_r_3001_30_194_5122)
        
        %pair_111 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4817)
        %k_13_14_4_5198 = extractvalue <{%Resumption, %Stack}> %pair_111, 0
        %stack_112 = extractvalue <{%Resumption, %Stack}> %pair_111, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5198)
        
        %longLiteral_5503 = add i64 10, 0
        
        
        
        %pureApp_5504 = call ccc %Pos @boxInt_301(i64 %longLiteral_5503)
        
        
        
        %stackPointer_114 = call ccc %StackPointer @stackDeallocate(%Stack %stack_112, i64 24)
        %returnAddress_pointer_115 = getelementptr %FrameHeader, %StackPointer %stackPointer_114, i64 0, i32 0
        %returnAddress_113 = load %ReturnAddress, ptr %returnAddress_pointer_115, !noalias !2
        musttail call tailcc void %returnAddress_113(%Pos %pureApp_5504, %Stack %stack_112)
        ret void
    
    label_119:
        
        ret void
    
    label_125:
        call ccc void @erasePositive(%Pos %v_r_3001_30_194_5122)
        
        %pair_120 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4817)
        %k_13_14_4_5197 = extractvalue <{%Resumption, %Stack}> %pair_120, 0
        %stack_121 = extractvalue <{%Resumption, %Stack}> %pair_120, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5197)
        
        %longLiteral_5507 = add i64 10, 0
        
        
        
        %pureApp_5508 = call ccc %Pos @boxInt_301(i64 %longLiteral_5507)
        
        
        
        %stackPointer_123 = call ccc %StackPointer @stackDeallocate(%Stack %stack_121, i64 24)
        %returnAddress_pointer_124 = getelementptr %FrameHeader, %StackPointer %stackPointer_123, i64 0, i32 0
        %returnAddress_122 = load %ReturnAddress, ptr %returnAddress_pointer_124, !noalias !2
        musttail call tailcc void %returnAddress_122(%Pos %pureApp_5508, %Stack %stack_121)
        ret void
    
    label_126:
        
        %longLiteral_5510 = add i64 1, 0
        
        %pureApp_5509 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_5027, i64 %longLiteral_5510)
        
        
        
        %longLiteral_5512 = add i64 10, 0
        
        %pureApp_5511 = call ccc i64 @infixMul_99(i64 %longLiteral_5512, i64 %acc_8_35_199_4953)
        
        
        
        %pureApp_5513 = call ccc i64 @toInt_2085(i64 %pureApp_5500)
        
        
        
        %pureApp_5514 = call ccc i64 @infixSub_105(i64 %pureApp_5513, i64 %tmp_5350)
        
        
        
        %pureApp_5515 = call ccc i64 @infixAdd_96(i64 %pureApp_5511, i64 %pureApp_5514)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_5112(i64 %pureApp_5509, i64 %pureApp_5515, %Pos %v_r_3001_30_194_5122, %Prompt %p_8_9_4817, i64 %tmp_5350, %Stack %stack)
        ret void
    
    label_127:
        
        %intLiteral_5506 = add i64 57, 0
        
        %pureApp_5505 = call ccc %Pos @infixLte_2093(i64 %pureApp_5500, i64 %intLiteral_5506)
        
        
        
        %tag_117 = extractvalue %Pos %pureApp_5505, 0
        %fields_118 = extractvalue %Pos %pureApp_5505, 1
        switch i64 %tag_117, label %label_119 [i64 0, label %label_125 i64 1, label %label_126]
    
    label_128:
        %environment_106 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_coe_4009_46_73_237_5107_pointer_107 = getelementptr <{%Pos}>, %Environment %environment_106, i64 0, i32 0
        %v_coe_4009_46_73_237_5107 = load %Pos, ptr %v_coe_4009_46_73_237_5107_pointer_107, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_4009_46_73_237_5107)
        call ccc void @eraseObject(%Object %fields_104)
        
        %pureApp_5500 = call ccc i64 @unboxChar_313(%Pos %v_coe_4009_46_73_237_5107)
        
        
        
        %intLiteral_5502 = add i64 48, 0
        
        %pureApp_5501 = call ccc %Pos @infixGte_2099(i64 %pureApp_5500, i64 %intLiteral_5502)
        
        
        
        %tag_108 = extractvalue %Pos %pureApp_5501, 0
        %fields_109 = extractvalue %Pos %pureApp_5501, 1
        switch i64 %tag_108, label %label_110 [i64 0, label %label_116 i64 1, label %label_127]
    
    label_135:
        %environment_129 = call ccc %Environment @objectEnvironment(%Object %fields_104)
        %v_y_3198_76_103_267_5498_pointer_130 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 0
        %v_y_3198_76_103_267_5498 = load %Pos, ptr %v_y_3198_76_103_267_5498_pointer_130, !noalias !2
        %v_y_3199_77_104_268_5499_pointer_131 = getelementptr <{%Pos, %Pos}>, %Environment %environment_129, i64 0, i32 1
        %v_y_3199_77_104_268_5499 = load %Pos, ptr %v_y_3199_77_104_268_5499_pointer_131, !noalias !2
        call ccc void @eraseObject(%Object %fields_104)
        call ccc void @erasePositive(%Pos %v_r_3001_30_194_5122)
        
        %stackPointer_133 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_134 = getelementptr %FrameHeader, %StackPointer %stackPointer_133, i64 0, i32 0
        %returnAddress_132 = load %ReturnAddress, ptr %returnAddress_pointer_134, !noalias !2
        musttail call tailcc void %returnAddress_132(i64 %acc_8_35_199_4953, %Stack %stack)
        ret void
}



define ccc void @sharer_141(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_142 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %acc_8_35_199_4953_136_pointer_143 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 0
        %acc_8_35_199_4953_136 = load i64, ptr %acc_8_35_199_4953_136_pointer_143, !noalias !2
        %v_r_3001_30_194_5122_137_pointer_144 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 1
        %v_r_3001_30_194_5122_137 = load %Pos, ptr %v_r_3001_30_194_5122_137_pointer_144, !noalias !2
        %p_8_9_4817_138_pointer_145 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 2
        %p_8_9_4817_138 = load %Prompt, ptr %p_8_9_4817_138_pointer_145, !noalias !2
        %index_7_34_198_5027_139_pointer_146 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 3
        %index_7_34_198_5027_139 = load i64, ptr %index_7_34_198_5027_139_pointer_146, !noalias !2
        %tmp_5350_140_pointer_147 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_142, i64 0, i32 4
        %tmp_5350_140 = load i64, ptr %tmp_5350_140_pointer_147, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3001_30_194_5122_137)
        call ccc void @shareFrames(%StackPointer %stackPointer_142)
        ret void
}



define ccc void @eraser_153(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_154 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %acc_8_35_199_4953_148_pointer_155 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 0
        %acc_8_35_199_4953_148 = load i64, ptr %acc_8_35_199_4953_148_pointer_155, !noalias !2
        %v_r_3001_30_194_5122_149_pointer_156 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 1
        %v_r_3001_30_194_5122_149 = load %Pos, ptr %v_r_3001_30_194_5122_149_pointer_156, !noalias !2
        %p_8_9_4817_150_pointer_157 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 2
        %p_8_9_4817_150 = load %Prompt, ptr %p_8_9_4817_150_pointer_157, !noalias !2
        %index_7_34_198_5027_151_pointer_158 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 3
        %index_7_34_198_5027_151 = load i64, ptr %index_7_34_198_5027_151_pointer_158, !noalias !2
        %tmp_5350_152_pointer_159 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_154, i64 0, i32 4
        %tmp_5350_152 = load i64, ptr %tmp_5350_152_pointer_159, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3001_30_194_5122_149)
        call ccc void @eraseFrames(%StackPointer %stackPointer_154)
        ret void
}



define tailcc void @returnAddress_170(%Pos %returned_5516, %Stack %stack) {
        
    entry:
        
        %stack_171 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_173 = call ccc %StackPointer @stackDeallocate(%Stack %stack_171, i64 24)
        %returnAddress_pointer_174 = getelementptr %FrameHeader, %StackPointer %stackPointer_173, i64 0, i32 0
        %returnAddress_172 = load %ReturnAddress, ptr %returnAddress_pointer_174, !noalias !2
        musttail call tailcc void %returnAddress_172(%Pos %returned_5516, %Stack %stack_171)
        ret void
}



define tailcc void @Exception_7_19_46_210_5114_clause_179(%Object %closure, %Pos %exc_8_20_47_211_5046, %Pos %msg_9_21_48_212_5033, %Stack %stack) {
        
    entry:
        
        %environment_180 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_5094_pointer_181 = getelementptr <{%Prompt}>, %Environment %environment_180, i64 0, i32 0
        %p_6_18_45_209_5094 = load %Prompt, ptr %p_6_18_45_209_5094_pointer_181, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_182 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_5094)
        %k_11_23_50_214_5140 = extractvalue <{%Resumption, %Stack}> %pair_182, 0
        %stack_183 = extractvalue <{%Resumption, %Stack}> %pair_182, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_5140)
        
        %fields_184 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_185 = call ccc %Environment @objectEnvironment(%Object %fields_184)
        %exc_8_20_47_211_5046_pointer_188 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 0
        store %Pos %exc_8_20_47_211_5046, ptr %exc_8_20_47_211_5046_pointer_188, !noalias !2
        %msg_9_21_48_212_5033_pointer_189 = getelementptr <{%Pos, %Pos}>, %Environment %environment_185, i64 0, i32 1
        store %Pos %msg_9_21_48_212_5033, ptr %msg_9_21_48_212_5033_pointer_189, !noalias !2
        %make_5517_temporary_190 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5517 = insertvalue %Pos %make_5517_temporary_190, %Object %fields_184, 1
        
        
        
        %stackPointer_192 = call ccc %StackPointer @stackDeallocate(%Stack %stack_183, i64 24)
        %returnAddress_pointer_193 = getelementptr %FrameHeader, %StackPointer %stackPointer_192, i64 0, i32 0
        %returnAddress_191 = load %ReturnAddress, ptr %returnAddress_pointer_193, !noalias !2
        musttail call tailcc void %returnAddress_191(%Pos %make_5517, %Stack %stack_183)
        ret void
}


@vtable_194 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_5114_clause_179]


define ccc void @eraser_198(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_5094_197_pointer_199 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_5094_197 = load %Prompt, ptr %p_6_18_45_209_5094_197_pointer_199, !noalias !2
        ret void
}



define ccc void @eraser_206(%Environment %environment) {
        
    entry:
        
        %tmp_5352_205_pointer_207 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5352_205 = load %Pos, ptr %tmp_5352_205_pointer_207, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5352_205)
        ret void
}



define tailcc void @returnAddress_202(i64 %v_coe_4008_6_28_55_219_4988, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5518 = call ccc %Pos @boxChar_311(i64 %v_coe_4008_6_28_55_219_4988)
        
        
        
        %fields_203 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_204 = call ccc %Environment @objectEnvironment(%Object %fields_203)
        %tmp_5352_pointer_208 = getelementptr <{%Pos}>, %Environment %environment_204, i64 0, i32 0
        store %Pos %pureApp_5518, ptr %tmp_5352_pointer_208, !noalias !2
        %make_5519_temporary_209 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5519 = insertvalue %Pos %make_5519_temporary_209, %Object %fields_203, 1
        
        
        
        %stackPointer_211 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_212 = getelementptr %FrameHeader, %StackPointer %stackPointer_211, i64 0, i32 0
        %returnAddress_210 = load %ReturnAddress, ptr %returnAddress_pointer_212, !noalias !2
        musttail call tailcc void %returnAddress_210(%Pos %make_5519, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_5112(i64 %index_7_34_198_5027, i64 %acc_8_35_199_4953, %Pos %v_r_3001_30_194_5122, %Prompt %p_8_9_4817, i64 %tmp_5350, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_3001_30_194_5122)
        %stackPointer_160 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %acc_8_35_199_4953_pointer_161 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 0
        store i64 %acc_8_35_199_4953, ptr %acc_8_35_199_4953_pointer_161, !noalias !2
        %v_r_3001_30_194_5122_pointer_162 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 1
        store %Pos %v_r_3001_30_194_5122, ptr %v_r_3001_30_194_5122_pointer_162, !noalias !2
        %p_8_9_4817_pointer_163 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 2
        store %Prompt %p_8_9_4817, ptr %p_8_9_4817_pointer_163, !noalias !2
        %index_7_34_198_5027_pointer_164 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 3
        store i64 %index_7_34_198_5027, ptr %index_7_34_198_5027_pointer_164, !noalias !2
        %tmp_5350_pointer_165 = getelementptr <{i64, %Pos, %Prompt, i64, i64}>, %StackPointer %stackPointer_160, i64 0, i32 4
        store i64 %tmp_5350, ptr %tmp_5350_pointer_165, !noalias !2
        %returnAddress_pointer_166 = getelementptr <{<{i64, %Pos, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 0
        %sharer_pointer_167 = getelementptr <{<{i64, %Pos, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 1
        %eraser_pointer_168 = getelementptr <{<{i64, %Pos, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_160, i64 0, i32 1, i32 2
        store ptr @returnAddress_96, ptr %returnAddress_pointer_166, !noalias !2
        store ptr @sharer_141, ptr %sharer_pointer_167, !noalias !2
        store ptr @eraser_153, ptr %eraser_pointer_168, !noalias !2
        
        %stack_169 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_5094 = call ccc %Prompt @currentPrompt(%Stack %stack_169)
        %stackPointer_175 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_176 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 0
        %sharer_pointer_177 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 1
        %eraser_pointer_178 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_175, i64 0, i32 1, i32 2
        store ptr @returnAddress_170, ptr %returnAddress_pointer_176, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_177, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_178, !noalias !2
        
        %closure_195 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_196 = call ccc %Environment @objectEnvironment(%Object %closure_195)
        %p_6_18_45_209_5094_pointer_200 = getelementptr <{%Prompt}>, %Environment %environment_196, i64 0, i32 0
        store %Prompt %p_6_18_45_209_5094, ptr %p_6_18_45_209_5094_pointer_200, !noalias !2
        %vtable_temporary_201 = insertvalue %Neg zeroinitializer, ptr @vtable_194, 0
        %Exception_7_19_46_210_5114 = insertvalue %Neg %vtable_temporary_201, %Object %closure_195, 1
        %stackPointer_213 = call ccc %StackPointer @stackAllocate(%Stack %stack_169, i64 24)
        %returnAddress_pointer_214 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 0
        %sharer_pointer_215 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 1
        %eraser_pointer_216 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 2
        store ptr @returnAddress_202, ptr %returnAddress_pointer_214, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_215, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_216, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_3001_30_194_5122, i64 %index_7_34_198_5027, %Neg %Exception_7_19_46_210_5114, %Stack %stack_169)
        ret void
}



define tailcc void @Exception_9_106_133_297_5104_clause_217(%Object %closure, %Pos %exception_10_107_134_298_5520, %Pos %msg_11_108_135_299_5521, %Stack %stack) {
        
    entry:
        
        %environment_218 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4817_pointer_219 = getelementptr <{%Prompt}>, %Environment %environment_218, i64 0, i32 0
        %p_8_9_4817 = load %Prompt, ptr %p_8_9_4817_pointer_219, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5520)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5521)
        
        %pair_220 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4817)
        %k_13_14_4_5303 = extractvalue <{%Resumption, %Stack}> %pair_220, 0
        %stack_221 = extractvalue <{%Resumption, %Stack}> %pair_220, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5303)
        
        %longLiteral_5522 = add i64 10, 0
        
        
        
        %pureApp_5523 = call ccc %Pos @boxInt_301(i64 %longLiteral_5522)
        
        
        
        %stackPointer_223 = call ccc %StackPointer @stackDeallocate(%Stack %stack_221, i64 24)
        %returnAddress_pointer_224 = getelementptr %FrameHeader, %StackPointer %stackPointer_223, i64 0, i32 0
        %returnAddress_222 = load %ReturnAddress, ptr %returnAddress_pointer_224, !noalias !2
        musttail call tailcc void %returnAddress_222(%Pos %pureApp_5523, %Stack %stack_221)
        ret void
}


@vtable_225 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_5104_clause_217]


define tailcc void @returnAddress_236(i64 %v_coe_4013_22_131_158_322_4857, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5526 = call ccc %Pos @boxInt_301(i64 %v_coe_4013_22_131_158_322_4857)
        
        
        
        
        
        %pureApp_5527 = call ccc i64 @unboxInt_303(%Pos %pureApp_5526)
        
        
        
        %pureApp_5528 = call ccc %Pos @boxInt_301(i64 %pureApp_5527)
        
        
        
        %stackPointer_238 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_239 = getelementptr %FrameHeader, %StackPointer %stackPointer_238, i64 0, i32 0
        %returnAddress_237 = load %ReturnAddress, ptr %returnAddress_pointer_239, !noalias !2
        musttail call tailcc void %returnAddress_237(%Pos %pureApp_5528, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_248(i64 %v_r_3205_1_9_20_129_156_320_4893, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5532 = add i64 0, 0
        
        %pureApp_5531 = call ccc i64 @infixSub_105(i64 %longLiteral_5532, i64 %v_r_3205_1_9_20_129_156_320_4893)
        
        
        
        %stackPointer_250 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_251 = getelementptr %FrameHeader, %StackPointer %stackPointer_250, i64 0, i32 0
        %returnAddress_249 = load %ReturnAddress, ptr %returnAddress_pointer_251, !noalias !2
        musttail call tailcc void %returnAddress_249(i64 %pureApp_5531, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_231(i64 %v_r_3204_3_14_123_150_314_5029, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_232 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_3001_30_194_5122_pointer_233 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 0
        %v_r_3001_30_194_5122 = load %Pos, ptr %v_r_3001_30_194_5122_pointer_233, !noalias !2
        %p_8_9_4817_pointer_234 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 1
        %p_8_9_4817 = load %Prompt, ptr %p_8_9_4817_pointer_234, !noalias !2
        %tmp_5350_pointer_235 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_232, i64 0, i32 2
        %tmp_5350 = load i64, ptr %tmp_5350_pointer_235, !noalias !2
        
        %intLiteral_5525 = add i64 45, 0
        
        %pureApp_5524 = call ccc %Pos @infixEq_78(i64 %v_r_3204_3_14_123_150_314_5029, i64 %intLiteral_5525)
        
        
        %stackPointer_240 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_241 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 0
        %sharer_pointer_242 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 1
        %eraser_pointer_243 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_240, i64 0, i32 1, i32 2
        store ptr @returnAddress_236, ptr %returnAddress_pointer_241, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_242, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_243, !noalias !2
        
        %tag_244 = extractvalue %Pos %pureApp_5524, 0
        %fields_245 = extractvalue %Pos %pureApp_5524, 1
        switch i64 %tag_244, label %label_246 [i64 0, label %label_247 i64 1, label %label_256]
    
    label_246:
        
        ret void
    
    label_247:
        
        %longLiteral_5529 = add i64 0, 0
        
        %longLiteral_5530 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_5112(i64 %longLiteral_5529, i64 %longLiteral_5530, %Pos %v_r_3001_30_194_5122, %Prompt %p_8_9_4817, i64 %tmp_5350, %Stack %stack)
        ret void
    
    label_256:
        %stackPointer_252 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_253 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 0
        %sharer_pointer_254 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 1
        %eraser_pointer_255 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_252, i64 0, i32 1, i32 2
        store ptr @returnAddress_248, ptr %returnAddress_pointer_253, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_254, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_255, !noalias !2
        
        %longLiteral_5533 = add i64 1, 0
        
        %longLiteral_5534 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_5112(i64 %longLiteral_5533, i64 %longLiteral_5534, %Pos %v_r_3001_30_194_5122, %Prompt %p_8_9_4817, i64 %tmp_5350, %Stack %stack)
        ret void
}



define ccc void @sharer_260(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_261 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_3001_30_194_5122_257_pointer_262 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 0
        %v_r_3001_30_194_5122_257 = load %Pos, ptr %v_r_3001_30_194_5122_257_pointer_262, !noalias !2
        %p_8_9_4817_258_pointer_263 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 1
        %p_8_9_4817_258 = load %Prompt, ptr %p_8_9_4817_258_pointer_263, !noalias !2
        %tmp_5350_259_pointer_264 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_261, i64 0, i32 2
        %tmp_5350_259 = load i64, ptr %tmp_5350_259_pointer_264, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_3001_30_194_5122_257)
        call ccc void @shareFrames(%StackPointer %stackPointer_261)
        ret void
}



define ccc void @eraser_268(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_269 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_3001_30_194_5122_265_pointer_270 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 0
        %v_r_3001_30_194_5122_265 = load %Pos, ptr %v_r_3001_30_194_5122_265_pointer_270, !noalias !2
        %p_8_9_4817_266_pointer_271 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 1
        %p_8_9_4817_266 = load %Prompt, ptr %p_8_9_4817_266_pointer_271, !noalias !2
        %tmp_5350_267_pointer_272 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_269, i64 0, i32 2
        %tmp_5350_267 = load i64, ptr %tmp_5350_267_pointer_272, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3001_30_194_5122_265)
        call ccc void @eraseFrames(%StackPointer %stackPointer_269)
        ret void
}



define tailcc void @returnAddress_93(%Pos %v_r_3001_30_194_5122, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_94 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4817_pointer_95 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_94, i64 0, i32 0
        %p_8_9_4817 = load %Prompt, ptr %p_8_9_4817_pointer_95, !noalias !2
        
        %intLiteral_5497 = add i64 48, 0
        
        %pureApp_5496 = call ccc i64 @toInt_2085(i64 %intLiteral_5497)
        
        
        
        %closure_226 = call ccc %Object @newObject(ptr @eraser_198, i64 8)
        %environment_227 = call ccc %Environment @objectEnvironment(%Object %closure_226)
        %p_8_9_4817_pointer_229 = getelementptr <{%Prompt}>, %Environment %environment_227, i64 0, i32 0
        store %Prompt %p_8_9_4817, ptr %p_8_9_4817_pointer_229, !noalias !2
        %vtable_temporary_230 = insertvalue %Neg zeroinitializer, ptr @vtable_225, 0
        %Exception_9_106_133_297_5104 = insertvalue %Neg %vtable_temporary_230, %Object %closure_226, 1
        call ccc void @sharePositive(%Pos %v_r_3001_30_194_5122)
        %stackPointer_273 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_3001_30_194_5122_pointer_274 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 0
        store %Pos %v_r_3001_30_194_5122, ptr %v_r_3001_30_194_5122_pointer_274, !noalias !2
        %p_8_9_4817_pointer_275 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 1
        store %Prompt %p_8_9_4817, ptr %p_8_9_4817_pointer_275, !noalias !2
        %tmp_5350_pointer_276 = getelementptr <{%Pos, %Prompt, i64}>, %StackPointer %stackPointer_273, i64 0, i32 2
        store i64 %pureApp_5496, ptr %tmp_5350_pointer_276, !noalias !2
        %returnAddress_pointer_277 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 0
        %sharer_pointer_278 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 1
        %eraser_pointer_279 = getelementptr <{<{%Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_273, i64 0, i32 1, i32 2
        store ptr @returnAddress_231, ptr %returnAddress_pointer_277, !noalias !2
        store ptr @sharer_260, ptr %sharer_pointer_278, !noalias !2
        store ptr @eraser_268, ptr %eraser_pointer_279, !noalias !2
        
        %longLiteral_5535 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_3001_30_194_5122, i64 %longLiteral_5535, %Neg %Exception_9_106_133_297_5104, %Stack %stack)
        ret void
}



define ccc void @sharer_281(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_282 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4817_280_pointer_283 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_282, i64 0, i32 0
        %p_8_9_4817_280 = load %Prompt, ptr %p_8_9_4817_280_pointer_283, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_282)
        ret void
}



define ccc void @eraser_285(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_286 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4817_284_pointer_287 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_286, i64 0, i32 0
        %p_8_9_4817_284 = load %Prompt, ptr %p_8_9_4817_284_pointer_287, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_286)
        ret void
}


@utf8StringLiteral_5536.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_90(%Pos %v_r_3000_24_188_4943, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_91 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4817_pointer_92 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_91, i64 0, i32 0
        %p_8_9_4817 = load %Prompt, ptr %p_8_9_4817_pointer_92, !noalias !2
        %stackPointer_288 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4817_pointer_289 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_288, i64 0, i32 0
        store %Prompt %p_8_9_4817, ptr %p_8_9_4817_pointer_289, !noalias !2
        %returnAddress_pointer_290 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 0
        %sharer_pointer_291 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 1
        %eraser_pointer_292 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_288, i64 0, i32 1, i32 2
        store ptr @returnAddress_93, ptr %returnAddress_pointer_290, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_291, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_292, !noalias !2
        
        %tag_293 = extractvalue %Pos %v_r_3000_24_188_4943, 0
        %fields_294 = extractvalue %Pos %v_r_3000_24_188_4943, 1
        switch i64 %tag_293, label %label_295 [i64 0, label %label_299 i64 1, label %label_305]
    
    label_295:
        
        ret void
    
    label_299:
        
        %utf8StringLiteral_5536 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5536.lit)
        
        %stackPointer_297 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_298 = getelementptr %FrameHeader, %StackPointer %stackPointer_297, i64 0, i32 0
        %returnAddress_296 = load %ReturnAddress, ptr %returnAddress_pointer_298, !noalias !2
        musttail call tailcc void %returnAddress_296(%Pos %utf8StringLiteral_5536, %Stack %stack)
        ret void
    
    label_305:
        %environment_300 = call ccc %Environment @objectEnvironment(%Object %fields_294)
        %v_y_3835_8_29_193_4991_pointer_301 = getelementptr <{%Pos}>, %Environment %environment_300, i64 0, i32 0
        %v_y_3835_8_29_193_4991 = load %Pos, ptr %v_y_3835_8_29_193_4991_pointer_301, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3835_8_29_193_4991)
        call ccc void @eraseObject(%Object %fields_294)
        
        %stackPointer_303 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_304 = getelementptr %FrameHeader, %StackPointer %stackPointer_303, i64 0, i32 0
        %returnAddress_302 = load %ReturnAddress, ptr %returnAddress_pointer_304, !noalias !2
        musttail call tailcc void %returnAddress_302(%Pos %v_y_3835_8_29_193_4991, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_87(%Pos %v_r_2999_13_177_5042, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_88 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4817_pointer_89 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_88, i64 0, i32 0
        %p_8_9_4817 = load %Prompt, ptr %p_8_9_4817_pointer_89, !noalias !2
        %stackPointer_308 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4817_pointer_309 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_308, i64 0, i32 0
        store %Prompt %p_8_9_4817, ptr %p_8_9_4817_pointer_309, !noalias !2
        %returnAddress_pointer_310 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 0
        %sharer_pointer_311 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 1
        %eraser_pointer_312 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_308, i64 0, i32 1, i32 2
        store ptr @returnAddress_90, ptr %returnAddress_pointer_310, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_311, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_312, !noalias !2
        
        %tag_313 = extractvalue %Pos %v_r_2999_13_177_5042, 0
        %fields_314 = extractvalue %Pos %v_r_2999_13_177_5042, 1
        switch i64 %tag_313, label %label_315 [i64 0, label %label_320 i64 1, label %label_332]
    
    label_315:
        
        ret void
    
    label_320:
        
        %make_5537_temporary_316 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5537 = insertvalue %Pos %make_5537_temporary_316, %Object null, 1
        
        
        
        %stackPointer_318 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_319 = getelementptr %FrameHeader, %StackPointer %stackPointer_318, i64 0, i32 0
        %returnAddress_317 = load %ReturnAddress, ptr %returnAddress_pointer_319, !noalias !2
        musttail call tailcc void %returnAddress_317(%Pos %make_5537, %Stack %stack)
        ret void
    
    label_332:
        %environment_321 = call ccc %Environment @objectEnvironment(%Object %fields_314)
        %v_y_3344_10_21_185_4920_pointer_322 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 0
        %v_y_3344_10_21_185_4920 = load %Pos, ptr %v_y_3344_10_21_185_4920_pointer_322, !noalias !2
        %v_y_3345_11_22_186_5078_pointer_323 = getelementptr <{%Pos, %Pos}>, %Environment %environment_321, i64 0, i32 1
        %v_y_3345_11_22_186_5078 = load %Pos, ptr %v_y_3345_11_22_186_5078_pointer_323, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3344_10_21_185_4920)
        call ccc void @eraseObject(%Object %fields_314)
        
        %fields_324 = call ccc %Object @newObject(ptr @eraser_206, i64 16)
        %environment_325 = call ccc %Environment @objectEnvironment(%Object %fields_324)
        %v_y_3344_10_21_185_4920_pointer_327 = getelementptr <{%Pos}>, %Environment %environment_325, i64 0, i32 0
        store %Pos %v_y_3344_10_21_185_4920, ptr %v_y_3344_10_21_185_4920_pointer_327, !noalias !2
        %make_5538_temporary_328 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5538 = insertvalue %Pos %make_5538_temporary_328, %Object %fields_324, 1
        
        
        
        %stackPointer_330 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_331 = getelementptr %FrameHeader, %StackPointer %stackPointer_330, i64 0, i32 0
        %returnAddress_329 = load %ReturnAddress, ptr %returnAddress_pointer_331, !noalias !2
        musttail call tailcc void %returnAddress_329(%Pos %make_5538, %Stack %stack)
        ret void
}



define tailcc void @main_2857(%Stack %stack) {
        
    entry:
        
        %stackPointer_50 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_51 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 0
        %sharer_pointer_52 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 1
        %eraser_pointer_53 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_50, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_51, !noalias !2
        store ptr @sharer_38, ptr %sharer_pointer_52, !noalias !2
        store ptr @eraser_40, ptr %eraser_pointer_53, !noalias !2
        
        %stack_54 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4817 = call ccc %Prompt @currentPrompt(%Stack %stack_54)
        %stackPointer_64 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 24)
        %returnAddress_pointer_65 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 0
        %sharer_pointer_66 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 1
        %eraser_pointer_67 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_64, i64 0, i32 1, i32 2
        store ptr @returnAddress_55, ptr %returnAddress_pointer_65, !noalias !2
        store ptr @sharer_60, ptr %sharer_pointer_66, !noalias !2
        store ptr @eraser_62, ptr %eraser_pointer_67, !noalias !2
        
        %pureApp_5492 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5494 = add i64 1, 0
        
        %pureApp_5493 = call ccc i64 @infixSub_105(i64 %pureApp_5492, i64 %longLiteral_5494)
        
        
        
        %make_5495_temporary_86 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5495 = insertvalue %Pos %make_5495_temporary_86, %Object null, 1
        
        
        %stackPointer_335 = call ccc %StackPointer @stackAllocate(%Stack %stack_54, i64 32)
        %p_8_9_4817_pointer_336 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_335, i64 0, i32 0
        store %Prompt %p_8_9_4817, ptr %p_8_9_4817_pointer_336, !noalias !2
        %returnAddress_pointer_337 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 0
        %sharer_pointer_338 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 1
        %eraser_pointer_339 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_335, i64 0, i32 1, i32 2
        store ptr @returnAddress_87, ptr %returnAddress_pointer_337, !noalias !2
        store ptr @sharer_281, ptr %sharer_pointer_338, !noalias !2
        store ptr @eraser_285, ptr %eraser_pointer_339, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4868(i64 %pureApp_5493, %Pos %make_5495, %Stack %stack_54)
        ret void
}



define tailcc void @returnAddress_340(i64 %returnValue_341, %Stack %stack) {
        
    entry:
        
        %stackPointer_342 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2949_4116_pointer_343 = getelementptr <{i64}>, %StackPointer %stackPointer_342, i64 0, i32 0
        %v_r_2949_4116 = load i64, ptr %v_r_2949_4116_pointer_343, !noalias !2
        %stackPointer_345 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_346 = getelementptr %FrameHeader, %StackPointer %stackPointer_345, i64 0, i32 0
        %returnAddress_344 = load %ReturnAddress, ptr %returnAddress_pointer_346, !noalias !2
        musttail call tailcc void %returnAddress_344(i64 %returnValue_341, %Stack %stack)
        ret void
}



define ccc void @sharer_348(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_349 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2949_4116_347_pointer_350 = getelementptr <{i64}>, %StackPointer %stackPointer_349, i64 0, i32 0
        %v_r_2949_4116_347 = load i64, ptr %v_r_2949_4116_347_pointer_350, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_349)
        ret void
}



define ccc void @eraser_352(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_353 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2949_4116_351_pointer_354 = getelementptr <{i64}>, %StackPointer %stackPointer_353, i64 0, i32 0
        %v_r_2949_4116_351 = load i64, ptr %v_r_2949_4116_351_pointer_354, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_353)
        ret void
}



define tailcc void @loop_5_9_4412(i64 %i_6_10_4410, %Pos %tmp_5379, %Pos %tmp_5313, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5401 = add i64 3, 0
        
        %pureApp_5400 = call ccc %Pos @infixLt_178(i64 %i_6_10_4410, i64 %longLiteral_5401)
        
        
        
        %tag_361 = extractvalue %Pos %pureApp_5400, 0
        %fields_362 = extractvalue %Pos %pureApp_5400, 1
        switch i64 %tag_361, label %label_363 [i64 0, label %label_368 i64 1, label %label_369]
    
    label_363:
        
        ret void
    
    label_368:
        call ccc void @erasePositive(%Pos %tmp_5313)
        call ccc void @erasePositive(%Pos %tmp_5379)
        
        %unitLiteral_5402_temporary_364 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5402 = insertvalue %Pos %unitLiteral_5402_temporary_364, %Object null, 1
        
        %stackPointer_366 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_367 = getelementptr %FrameHeader, %StackPointer %stackPointer_366, i64 0, i32 0
        %returnAddress_365 = load %ReturnAddress, ptr %returnAddress_pointer_367, !noalias !2
        musttail call tailcc void %returnAddress_365(%Pos %unitLiteral_5402, %Stack %stack)
        ret void
    
    label_369:
        
        call ccc void @sharePositive(%Pos %tmp_5313)
        call ccc void @sharePositive(%Pos %tmp_5379)
        %pureApp_5403 = call ccc %Pos @unsafeSet_2492(%Pos %tmp_5313, i64 %i_6_10_4410, %Pos %tmp_5379)
        call ccc void @erasePositive(%Pos %pureApp_5403)
        
        
        
        %longLiteral_5405 = add i64 1, 0
        
        %pureApp_5404 = call ccc i64 @infixAdd_96(i64 %i_6_10_4410, i64 %longLiteral_5405)
        
        
        
        
        
        musttail call tailcc void @loop_5_9_4412(i64 %pureApp_5404, %Pos %tmp_5379, %Pos %tmp_5313, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_375(i64 %returnValue_376, %Stack %stack) {
        
    entry:
        
        %stackPointer_377 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %tmp_5313_pointer_378 = getelementptr <{%Pos}>, %StackPointer %stackPointer_377, i64 0, i32 0
        %tmp_5313 = load %Pos, ptr %tmp_5313_pointer_378, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5313)
        %stackPointer_380 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_381 = getelementptr %FrameHeader, %StackPointer %stackPointer_380, i64 0, i32 0
        %returnAddress_379 = load %ReturnAddress, ptr %returnAddress_pointer_381, !noalias !2
        musttail call tailcc void %returnAddress_379(i64 %returnValue_376, %Stack %stack)
        ret void
}



define ccc void @sharer_383(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_384 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_5313_382_pointer_385 = getelementptr <{%Pos}>, %StackPointer %stackPointer_384, i64 0, i32 0
        %tmp_5313_382 = load %Pos, ptr %tmp_5313_382_pointer_385, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5313_382)
        call ccc void @shareFrames(%StackPointer %stackPointer_384)
        ret void
}



define ccc void @eraser_387(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_388 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_5313_386_pointer_389 = getelementptr <{%Pos}>, %StackPointer %stackPointer_388, i64 0, i32 0
        %tmp_5313_386 = load %Pos, ptr %tmp_5313_386_pointer_389, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5313_386)
        call ccc void @eraseFrames(%StackPointer %stackPointer_388)
        ret void
}



define tailcc void @returnAddress_406(%Pos %v_r_2964_4136, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_407 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %newTopDiskOnPile_2862_pointer_408 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_407, i64 0, i32 0
        %newTopDiskOnPile_2862 = load i64, ptr %newTopDiskOnPile_2862_pointer_408, !noalias !2
        %tmp_5317_pointer_409 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_407, i64 0, i32 1
        %tmp_5317 = load %Pos, ptr %tmp_5317_pointer_409, !noalias !2
        %pileIdx_2863_pointer_410 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_407, i64 0, i32 2
        %pileIdx_2863 = load i64, ptr %pileIdx_2863_pointer_410, !noalias !2
        
        %pureApp_5409 = call ccc %Pos @boxInt_301(i64 %newTopDiskOnPile_2862)
        
        
        
        %fields_411 = call ccc %Object @newObject(ptr @eraser_75, i64 32)
        %environment_412 = call ccc %Environment @objectEnvironment(%Object %fields_411)
        %tmp_5321_pointer_415 = getelementptr <{%Pos, %Pos}>, %Environment %environment_412, i64 0, i32 0
        store %Pos %pureApp_5409, ptr %tmp_5321_pointer_415, !noalias !2
        %tmp_5317_pointer_416 = getelementptr <{%Pos, %Pos}>, %Environment %environment_412, i64 0, i32 1
        store %Pos %tmp_5317, ptr %tmp_5317_pointer_416, !noalias !2
        %make_5410_temporary_417 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5410 = insertvalue %Pos %make_5410_temporary_417, %Object %fields_411, 1
        
        
        
        %pureApp_5411 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2964_4136, i64 %pileIdx_2863, %Pos %make_5410)
        
        
        
        %stackPointer_419 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_420 = getelementptr %FrameHeader, %StackPointer %stackPointer_419, i64 0, i32 0
        %returnAddress_418 = load %ReturnAddress, ptr %returnAddress_pointer_420, !noalias !2
        musttail call tailcc void %returnAddress_418(%Pos %pureApp_5411, %Stack %stack)
        ret void
}



define ccc void @sharer_424(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_425 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %newTopDiskOnPile_2862_421_pointer_426 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_425, i64 0, i32 0
        %newTopDiskOnPile_2862_421 = load i64, ptr %newTopDiskOnPile_2862_421_pointer_426, !noalias !2
        %tmp_5317_422_pointer_427 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_425, i64 0, i32 1
        %tmp_5317_422 = load %Pos, ptr %tmp_5317_422_pointer_427, !noalias !2
        %pileIdx_2863_423_pointer_428 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_425, i64 0, i32 2
        %pileIdx_2863_423 = load i64, ptr %pileIdx_2863_423_pointer_428, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5317_422)
        call ccc void @shareFrames(%StackPointer %stackPointer_425)
        ret void
}



define ccc void @eraser_432(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_433 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer, i64 -1
        %newTopDiskOnPile_2862_429_pointer_434 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_433, i64 0, i32 0
        %newTopDiskOnPile_2862_429 = load i64, ptr %newTopDiskOnPile_2862_429_pointer_434, !noalias !2
        %tmp_5317_430_pointer_435 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_433, i64 0, i32 1
        %tmp_5317_430 = load %Pos, ptr %tmp_5317_430_pointer_435, !noalias !2
        %pileIdx_2863_431_pointer_436 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_433, i64 0, i32 2
        %pileIdx_2863_431 = load i64, ptr %pileIdx_2863_431_pointer_436, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5317_430)
        call ccc void @eraseFrames(%StackPointer %stackPointer_433)
        ret void
}



define tailcc void @returnAddress_400(%Pos %v_r_2963_5407, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_401 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %newTopDiskOnPile_2862_pointer_402 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_401, i64 0, i32 0
        %newTopDiskOnPile_2862 = load i64, ptr %newTopDiskOnPile_2862_pointer_402, !noalias !2
        %tmp_5317_pointer_403 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_401, i64 0, i32 1
        %tmp_5317 = load %Pos, ptr %tmp_5317_pointer_403, !noalias !2
        %pileIdx_2863_pointer_404 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_401, i64 0, i32 2
        %pileIdx_2863 = load i64, ptr %pileIdx_2863_pointer_404, !noalias !2
        %towers_2861_pointer_405 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_401, i64 0, i32 3
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_405, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2963_5407)
        %stackPointer_437 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %newTopDiskOnPile_2862_pointer_438 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_437, i64 0, i32 0
        store i64 %newTopDiskOnPile_2862, ptr %newTopDiskOnPile_2862_pointer_438, !noalias !2
        %tmp_5317_pointer_439 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_437, i64 0, i32 1
        store %Pos %tmp_5317, ptr %tmp_5317_pointer_439, !noalias !2
        %pileIdx_2863_pointer_440 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_437, i64 0, i32 2
        store i64 %pileIdx_2863, ptr %pileIdx_2863_pointer_440, !noalias !2
        %returnAddress_pointer_441 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_437, i64 0, i32 1, i32 0
        %sharer_pointer_442 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_437, i64 0, i32 1, i32 1
        %eraser_pointer_443 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_437, i64 0, i32 1, i32 2
        store ptr @returnAddress_406, ptr %returnAddress_pointer_441, !noalias !2
        store ptr @sharer_424, ptr %sharer_pointer_442, !noalias !2
        store ptr @eraser_432, ptr %eraser_pointer_443, !noalias !2
        
        %get_5412_pointer_444 = call ccc ptr @getVarPointer(%Reference %towers_2861, %Stack %stack)
        %towers_2861_old_445 = load %Pos, ptr %get_5412_pointer_444, !noalias !2
        call ccc void @sharePositive(%Pos %towers_2861_old_445)
        %get_5412 = load %Pos, ptr %get_5412_pointer_444, !noalias !2
        
        %stackPointer_447 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_448 = getelementptr %FrameHeader, %StackPointer %stackPointer_447, i64 0, i32 0
        %returnAddress_446 = load %ReturnAddress, ptr %returnAddress_pointer_448, !noalias !2
        musttail call tailcc void %returnAddress_446(%Pos %get_5412, %Stack %stack)
        ret void
}



define ccc void @sharer_453(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_454 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %newTopDiskOnPile_2862_449_pointer_455 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 0
        %newTopDiskOnPile_2862_449 = load i64, ptr %newTopDiskOnPile_2862_449_pointer_455, !noalias !2
        %tmp_5317_450_pointer_456 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 1
        %tmp_5317_450 = load %Pos, ptr %tmp_5317_450_pointer_456, !noalias !2
        %pileIdx_2863_451_pointer_457 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 2
        %pileIdx_2863_451 = load i64, ptr %pileIdx_2863_451_pointer_457, !noalias !2
        %towers_2861_452_pointer_458 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_454, i64 0, i32 3
        %towers_2861_452 = load %Reference, ptr %towers_2861_452_pointer_458, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5317_450)
        call ccc void @shareFrames(%StackPointer %stackPointer_454)
        ret void
}



define ccc void @eraser_463(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_464 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %newTopDiskOnPile_2862_459_pointer_465 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_464, i64 0, i32 0
        %newTopDiskOnPile_2862_459 = load i64, ptr %newTopDiskOnPile_2862_459_pointer_465, !noalias !2
        %tmp_5317_460_pointer_466 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_464, i64 0, i32 1
        %tmp_5317_460 = load %Pos, ptr %tmp_5317_460_pointer_466, !noalias !2
        %pileIdx_2863_461_pointer_467 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_464, i64 0, i32 2
        %pileIdx_2863_461 = load i64, ptr %pileIdx_2863_461_pointer_467, !noalias !2
        %towers_2861_462_pointer_468 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_464, i64 0, i32 3
        %towers_2861_462 = load %Reference, ptr %towers_2861_462_pointer_468, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5317_460)
        call ccc void @eraseFrames(%StackPointer %stackPointer_464)
        ret void
}


@utf8StringLiteral_5417.lit = private constant [40 x i8] c"\43\61\6e\6e\6f\74\20\70\75\74\20\61\20\62\69\67\20\64\69\73\6b\20\6f\6e\74\6f\20\61\20\73\6d\61\6c\6c\65\72\20\6f\6e\65"


define tailcc void @returnAddress_395(%Pos %v_r_2952_4126, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_396 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %pileIdx_2863_pointer_397 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_396, i64 0, i32 0
        %pileIdx_2863 = load i64, ptr %pileIdx_2863_pointer_397, !noalias !2
        %newTopDiskOnPile_2862_pointer_398 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_396, i64 0, i32 1
        %newTopDiskOnPile_2862 = load i64, ptr %newTopDiskOnPile_2862_pointer_398, !noalias !2
        %towers_2861_pointer_399 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_396, i64 0, i32 2
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_399, !noalias !2
        
        %pureApp_5408 = call ccc %Pos @unsafeGet_2487(%Pos %v_r_2952_4126, i64 %pileIdx_2863)
        
        
        call ccc void @sharePositive(%Pos %pureApp_5408)
        %stackPointer_469 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %newTopDiskOnPile_2862_pointer_470 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_469, i64 0, i32 0
        store i64 %newTopDiskOnPile_2862, ptr %newTopDiskOnPile_2862_pointer_470, !noalias !2
        %tmp_5317_pointer_471 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_469, i64 0, i32 1
        store %Pos %pureApp_5408, ptr %tmp_5317_pointer_471, !noalias !2
        %pileIdx_2863_pointer_472 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_469, i64 0, i32 2
        store i64 %pileIdx_2863, ptr %pileIdx_2863_pointer_472, !noalias !2
        %towers_2861_pointer_473 = getelementptr <{i64, %Pos, i64, %Reference}>, %StackPointer %stackPointer_469, i64 0, i32 3
        store %Reference %towers_2861, ptr %towers_2861_pointer_473, !noalias !2
        %returnAddress_pointer_474 = getelementptr <{<{i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_469, i64 0, i32 1, i32 0
        %sharer_pointer_475 = getelementptr <{<{i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_469, i64 0, i32 1, i32 1
        %eraser_pointer_476 = getelementptr <{<{i64, %Pos, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_469, i64 0, i32 1, i32 2
        store ptr @returnAddress_400, ptr %returnAddress_pointer_474, !noalias !2
        store ptr @sharer_453, ptr %sharer_pointer_475, !noalias !2
        store ptr @eraser_463, ptr %eraser_pointer_476, !noalias !2
        
        %tag_477 = extractvalue %Pos %pureApp_5408, 0
        %fields_478 = extractvalue %Pos %pureApp_5408, 1
        switch i64 %tag_477, label %label_479 [i64 1, label %label_495 i64 0, label %label_500]
    
    label_479:
        
        ret void
    
    label_485:
        
        ret void
    
    label_490:
        
        %unitLiteral_5415_temporary_486 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5415 = insertvalue %Pos %unitLiteral_5415_temporary_486, %Object null, 1
        
        %stackPointer_488 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_489 = getelementptr %FrameHeader, %StackPointer %stackPointer_488, i64 0, i32 0
        %returnAddress_487 = load %ReturnAddress, ptr %returnAddress_pointer_489, !noalias !2
        musttail call tailcc void %returnAddress_487(%Pos %unitLiteral_5415, %Stack %stack)
        ret void
    
    label_494:
        
        %utf8StringLiteral_5417 = call ccc %Pos @c_bytearray_construct(i64 40, ptr @utf8StringLiteral_5417.lit)
        
        %pureApp_5416 = call ccc %Pos @panic_552(%Pos %utf8StringLiteral_5417)
        
        
        
        %stackPointer_492 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_493 = getelementptr %FrameHeader, %StackPointer %stackPointer_492, i64 0, i32 0
        %returnAddress_491 = load %ReturnAddress, ptr %returnAddress_pointer_493, !noalias !2
        musttail call tailcc void %returnAddress_491(%Pos %pureApp_5416, %Stack %stack)
        ret void
    
    label_495:
        %environment_480 = call ccc %Environment @objectEnvironment(%Object %fields_478)
        %v_coe_4034_4132_pointer_481 = getelementptr <{%Pos, %Pos}>, %Environment %environment_480, i64 0, i32 0
        %v_coe_4034_4132 = load %Pos, ptr %v_coe_4034_4132_pointer_481, !noalias !2
        %v_coe_4035_4133_pointer_482 = getelementptr <{%Pos, %Pos}>, %Environment %environment_480, i64 0, i32 1
        %v_coe_4035_4133 = load %Pos, ptr %v_coe_4035_4133_pointer_482, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_4034_4132)
        call ccc void @eraseObject(%Object %fields_478)
        
        %pureApp_5413 = call ccc i64 @unboxInt_303(%Pos %v_coe_4034_4132)
        
        
        
        %pureApp_5414 = call ccc %Pos @infixGte_187(i64 %newTopDiskOnPile_2862, i64 %pureApp_5413)
        
        
        
        %tag_483 = extractvalue %Pos %pureApp_5414, 0
        %fields_484 = extractvalue %Pos %pureApp_5414, 1
        switch i64 %tag_483, label %label_485 [i64 0, label %label_490 i64 1, label %label_494]
    
    label_500:
        
        %unitLiteral_5418_temporary_496 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5418 = insertvalue %Pos %unitLiteral_5418_temporary_496, %Object null, 1
        
        %stackPointer_498 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_499 = getelementptr %FrameHeader, %StackPointer %stackPointer_498, i64 0, i32 0
        %returnAddress_497 = load %ReturnAddress, ptr %returnAddress_pointer_499, !noalias !2
        musttail call tailcc void %returnAddress_497(%Pos %unitLiteral_5418, %Stack %stack)
        ret void
}



define ccc void @sharer_504(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_505 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %pileIdx_2863_501_pointer_506 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_505, i64 0, i32 0
        %pileIdx_2863_501 = load i64, ptr %pileIdx_2863_501_pointer_506, !noalias !2
        %newTopDiskOnPile_2862_502_pointer_507 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_505, i64 0, i32 1
        %newTopDiskOnPile_2862_502 = load i64, ptr %newTopDiskOnPile_2862_502_pointer_507, !noalias !2
        %towers_2861_503_pointer_508 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_505, i64 0, i32 2
        %towers_2861_503 = load %Reference, ptr %towers_2861_503_pointer_508, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_505)
        ret void
}



define ccc void @eraser_512(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_513 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %pileIdx_2863_509_pointer_514 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_513, i64 0, i32 0
        %pileIdx_2863_509 = load i64, ptr %pileIdx_2863_509_pointer_514, !noalias !2
        %newTopDiskOnPile_2862_510_pointer_515 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_513, i64 0, i32 1
        %newTopDiskOnPile_2862_510 = load i64, ptr %newTopDiskOnPile_2862_510_pointer_515, !noalias !2
        %towers_2861_511_pointer_516 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_513, i64 0, i32 2
        %towers_2861_511 = load %Reference, ptr %towers_2861_511_pointer_516, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_513)
        ret void
}



define tailcc void @pushDisk_2864(i64 %newTopDiskOnPile_2862, i64 %pileIdx_2863, %Reference %towers_2861, %Stack %stack) {
        
    entry:
        
        %stackPointer_517 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %pileIdx_2863_pointer_518 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_517, i64 0, i32 0
        store i64 %pileIdx_2863, ptr %pileIdx_2863_pointer_518, !noalias !2
        %newTopDiskOnPile_2862_pointer_519 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_517, i64 0, i32 1
        store i64 %newTopDiskOnPile_2862, ptr %newTopDiskOnPile_2862_pointer_519, !noalias !2
        %towers_2861_pointer_520 = getelementptr <{i64, i64, %Reference}>, %StackPointer %stackPointer_517, i64 0, i32 2
        store %Reference %towers_2861, ptr %towers_2861_pointer_520, !noalias !2
        %returnAddress_pointer_521 = getelementptr <{<{i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_517, i64 0, i32 1, i32 0
        %sharer_pointer_522 = getelementptr <{<{i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_517, i64 0, i32 1, i32 1
        %eraser_pointer_523 = getelementptr <{<{i64, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_517, i64 0, i32 1, i32 2
        store ptr @returnAddress_395, ptr %returnAddress_pointer_521, !noalias !2
        store ptr @sharer_504, ptr %sharer_pointer_522, !noalias !2
        store ptr @eraser_512, ptr %eraser_pointer_523, !noalias !2
        
        %get_5419_pointer_524 = call ccc ptr @getVarPointer(%Reference %towers_2861, %Stack %stack)
        %towers_2861_old_525 = load %Pos, ptr %get_5419_pointer_524, !noalias !2
        call ccc void @sharePositive(%Pos %towers_2861_old_525)
        %get_5419 = load %Pos, ptr %get_5419_pointer_524, !noalias !2
        
        %stackPointer_527 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_528 = getelementptr %FrameHeader, %StackPointer %stackPointer_527, i64 0, i32 0
        %returnAddress_526 = load %ReturnAddress, ptr %returnAddress_pointer_528, !noalias !2
        musttail call tailcc void %returnAddress_526(%Pos %get_5419, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_569(%Pos %__5420, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_570 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %movesDone_2860_pointer_571 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_570, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_571, !noalias !2
        %towers_2861_pointer_572 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_570, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_572, !noalias !2
        %disks_2875_pointer_573 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_570, i64 0, i32 2
        %disks_2875 = load i64, ptr %disks_2875_pointer_573, !noalias !2
        %tmp_5332_pointer_574 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_570, i64 0, i32 3
        %tmp_5332 = load i64, ptr %tmp_5332_pointer_574, !noalias !2
        %ontoPile_2877_pointer_575 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_570, i64 0, i32 4
        %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_575, !noalias !2
        call ccc void @erasePositive(%Pos %__5420)
        
        %longLiteral_5433 = add i64 1, 0
        
        %pureApp_5432 = call ccc i64 @infixSub_105(i64 %disks_2875, i64 %longLiteral_5433)
        
        
        
        
        
        
        
        musttail call tailcc void @moveDisks_2878(i64 %pureApp_5432, i64 %tmp_5332, i64 %ontoPile_2877, %Reference %movesDone_2860, %Reference %towers_2861, %Stack %stack)
        ret void
}



define ccc void @sharer_581(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_582 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_576_pointer_583 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_582, i64 0, i32 0
        %movesDone_2860_576 = load %Reference, ptr %movesDone_2860_576_pointer_583, !noalias !2
        %towers_2861_577_pointer_584 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_582, i64 0, i32 1
        %towers_2861_577 = load %Reference, ptr %towers_2861_577_pointer_584, !noalias !2
        %disks_2875_578_pointer_585 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_582, i64 0, i32 2
        %disks_2875_578 = load i64, ptr %disks_2875_578_pointer_585, !noalias !2
        %tmp_5332_579_pointer_586 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_582, i64 0, i32 3
        %tmp_5332_579 = load i64, ptr %tmp_5332_579_pointer_586, !noalias !2
        %ontoPile_2877_580_pointer_587 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_582, i64 0, i32 4
        %ontoPile_2877_580 = load i64, ptr %ontoPile_2877_580_pointer_587, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_582)
        ret void
}



define ccc void @eraser_593(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_594 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_588_pointer_595 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_594, i64 0, i32 0
        %movesDone_2860_588 = load %Reference, ptr %movesDone_2860_588_pointer_595, !noalias !2
        %towers_2861_589_pointer_596 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_594, i64 0, i32 1
        %towers_2861_589 = load %Reference, ptr %towers_2861_589_pointer_596, !noalias !2
        %disks_2875_590_pointer_597 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_594, i64 0, i32 2
        %disks_2875_590 = load i64, ptr %disks_2875_590_pointer_597, !noalias !2
        %tmp_5332_591_pointer_598 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_594, i64 0, i32 3
        %tmp_5332_591 = load i64, ptr %tmp_5332_591_pointer_598, !noalias !2
        %ontoPile_2877_592_pointer_599 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_594, i64 0, i32 4
        %ontoPile_2877_592 = load i64, ptr %ontoPile_2877_592_pointer_599, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_594)
        ret void
}



define tailcc void @returnAddress_562(i64 %v_r_2980_14_5296, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_563 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %movesDone_2860_pointer_564 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_563, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_564, !noalias !2
        %towers_2861_pointer_565 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_563, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_565, !noalias !2
        %disks_2875_pointer_566 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_563, i64 0, i32 2
        %disks_2875 = load i64, ptr %disks_2875_pointer_566, !noalias !2
        %tmp_5332_pointer_567 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_563, i64 0, i32 3
        %tmp_5332 = load i64, ptr %tmp_5332_pointer_567, !noalias !2
        %ontoPile_2877_pointer_568 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_563, i64 0, i32 4
        %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_568, !noalias !2
        
        %longLiteral_5431 = add i64 1, 0
        
        %pureApp_5430 = call ccc i64 @infixAdd_96(i64 %v_r_2980_14_5296, i64 %longLiteral_5431)
        
        
        %stackPointer_600 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %movesDone_2860_pointer_601 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_600, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_601, !noalias !2
        %towers_2861_pointer_602 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_600, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_602, !noalias !2
        %disks_2875_pointer_603 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_600, i64 0, i32 2
        store i64 %disks_2875, ptr %disks_2875_pointer_603, !noalias !2
        %tmp_5332_pointer_604 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_600, i64 0, i32 3
        store i64 %tmp_5332, ptr %tmp_5332_pointer_604, !noalias !2
        %ontoPile_2877_pointer_605 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_600, i64 0, i32 4
        store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_605, !noalias !2
        %returnAddress_pointer_606 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_600, i64 0, i32 1, i32 0
        %sharer_pointer_607 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_600, i64 0, i32 1, i32 1
        %eraser_pointer_608 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_600, i64 0, i32 1, i32 2
        store ptr @returnAddress_569, ptr %returnAddress_pointer_606, !noalias !2
        store ptr @sharer_581, ptr %sharer_pointer_607, !noalias !2
        store ptr @eraser_593, ptr %eraser_pointer_608, !noalias !2
        
        %movesDone_2860pointer_609 = call ccc ptr @getVarPointer(%Reference %movesDone_2860, %Stack %stack)
        %movesDone_2860_old_610 = load i64, ptr %movesDone_2860pointer_609, !noalias !2
        store i64 %pureApp_5430, ptr %movesDone_2860pointer_609, !noalias !2
        
        %put_5434_temporary_611 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5434 = insertvalue %Pos %put_5434_temporary_611, %Object null, 1
        
        %stackPointer_613 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_614 = getelementptr %FrameHeader, %StackPointer %stackPointer_613, i64 0, i32 0
        %returnAddress_612 = load %ReturnAddress, ptr %returnAddress_pointer_614, !noalias !2
        musttail call tailcc void %returnAddress_612(%Pos %put_5434, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_555(%Pos %__13_5302, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_556 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %movesDone_2860_pointer_557 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_556, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_557, !noalias !2
        %towers_2861_pointer_558 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_556, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_558, !noalias !2
        %disks_2875_pointer_559 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_556, i64 0, i32 2
        %disks_2875 = load i64, ptr %disks_2875_pointer_559, !noalias !2
        %tmp_5332_pointer_560 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_556, i64 0, i32 3
        %tmp_5332 = load i64, ptr %tmp_5332_pointer_560, !noalias !2
        %ontoPile_2877_pointer_561 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_556, i64 0, i32 4
        %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_561, !noalias !2
        call ccc void @erasePositive(%Pos %__13_5302)
        %stackPointer_625 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %movesDone_2860_pointer_626 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_625, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_626, !noalias !2
        %towers_2861_pointer_627 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_625, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_627, !noalias !2
        %disks_2875_pointer_628 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_625, i64 0, i32 2
        store i64 %disks_2875, ptr %disks_2875_pointer_628, !noalias !2
        %tmp_5332_pointer_629 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_625, i64 0, i32 3
        store i64 %tmp_5332, ptr %tmp_5332_pointer_629, !noalias !2
        %ontoPile_2877_pointer_630 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_625, i64 0, i32 4
        store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_630, !noalias !2
        %returnAddress_pointer_631 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_625, i64 0, i32 1, i32 0
        %sharer_pointer_632 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_625, i64 0, i32 1, i32 1
        %eraser_pointer_633 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_625, i64 0, i32 1, i32 2
        store ptr @returnAddress_562, ptr %returnAddress_pointer_631, !noalias !2
        store ptr @sharer_581, ptr %sharer_pointer_632, !noalias !2
        store ptr @eraser_593, ptr %eraser_pointer_633, !noalias !2
        
        %get_5435_pointer_634 = call ccc ptr @getVarPointer(%Reference %movesDone_2860, %Stack %stack)
        %movesDone_2860_old_635 = load i64, ptr %get_5435_pointer_634, !noalias !2
        %get_5435 = load i64, ptr %get_5435_pointer_634, !noalias !2
        
        %stackPointer_637 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_638 = getelementptr %FrameHeader, %StackPointer %stackPointer_637, i64 0, i32 0
        %returnAddress_636 = load %ReturnAddress, ptr %returnAddress_pointer_638, !noalias !2
        musttail call tailcc void %returnAddress_636(i64 %get_5435, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_548(i64 %v_r_2978_12_5299, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_549 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %movesDone_2860_pointer_550 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_549, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_550, !noalias !2
        %towers_2861_pointer_551 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_549, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_551, !noalias !2
        %disks_2875_pointer_552 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_549, i64 0, i32 2
        %disks_2875 = load i64, ptr %disks_2875_pointer_552, !noalias !2
        %tmp_5332_pointer_553 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_549, i64 0, i32 3
        %tmp_5332 = load i64, ptr %tmp_5332_pointer_553, !noalias !2
        %ontoPile_2877_pointer_554 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_549, i64 0, i32 4
        %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_554, !noalias !2
        %stackPointer_649 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %movesDone_2860_pointer_650 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_649, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_650, !noalias !2
        %towers_2861_pointer_651 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_649, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_651, !noalias !2
        %disks_2875_pointer_652 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_649, i64 0, i32 2
        store i64 %disks_2875, ptr %disks_2875_pointer_652, !noalias !2
        %tmp_5332_pointer_653 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_649, i64 0, i32 3
        store i64 %tmp_5332, ptr %tmp_5332_pointer_653, !noalias !2
        %ontoPile_2877_pointer_654 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_649, i64 0, i32 4
        store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_654, !noalias !2
        %returnAddress_pointer_655 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 0
        %sharer_pointer_656 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 1
        %eraser_pointer_657 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_649, i64 0, i32 1, i32 2
        store ptr @returnAddress_555, ptr %returnAddress_pointer_655, !noalias !2
        store ptr @sharer_581, ptr %sharer_pointer_656, !noalias !2
        store ptr @eraser_593, ptr %eraser_pointer_657, !noalias !2
        
        
        
        
        musttail call tailcc void @pushDisk_2864(i64 %v_r_2978_12_5299, i64 %ontoPile_2877, %Reference %towers_2861, %Stack %stack)
        ret void
}


@utf8StringLiteral_5437.lit = private constant [46 x i8] c"\41\74\74\65\6d\70\74\69\6e\67\20\74\6f\20\72\65\6d\6f\76\65\20\61\20\64\69\73\6b\20\66\72\6f\6d\20\61\6e\20\65\6d\70\74\79\20\70\69\6c\65"


define tailcc void @returnAddress_687(%Pos %v_r_2970_3_3_25_10_5295, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_688 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %fromPile_2876_pointer_689 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_688, i64 0, i32 0
        %fromPile_2876 = load i64, ptr %fromPile_2876_pointer_689, !noalias !2
        %v_coe_4038_17_8_5293_pointer_690 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_688, i64 0, i32 1
        %v_coe_4038_17_8_5293 = load %Pos, ptr %v_coe_4038_17_8_5293_pointer_690, !noalias !2
        %tmp_5337_pointer_691 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_688, i64 0, i32 2
        %tmp_5337 = load i64, ptr %tmp_5337_pointer_691, !noalias !2
        
        %pureApp_5440 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2970_3_3_25_10_5295, i64 %fromPile_2876, %Pos %v_coe_4038_17_8_5293)
        call ccc void @erasePositive(%Pos %pureApp_5440)
        
        
        
        %stackPointer_693 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_694 = getelementptr %FrameHeader, %StackPointer %stackPointer_693, i64 0, i32 0
        %returnAddress_692 = load %ReturnAddress, ptr %returnAddress_pointer_694, !noalias !2
        musttail call tailcc void %returnAddress_692(i64 %tmp_5337, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_540(%Pos %v_r_2966_2_3_5290, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_541 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %movesDone_2860_pointer_542 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_541, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_542, !noalias !2
        %towers_2861_pointer_543 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_541, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_543, !noalias !2
        %disks_2875_pointer_544 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_541, i64 0, i32 2
        %disks_2875 = load i64, ptr %disks_2875_pointer_544, !noalias !2
        %fromPile_2876_pointer_545 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_541, i64 0, i32 3
        %fromPile_2876 = load i64, ptr %fromPile_2876_pointer_545, !noalias !2
        %tmp_5332_pointer_546 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_541, i64 0, i32 4
        %tmp_5332 = load i64, ptr %tmp_5332_pointer_546, !noalias !2
        %ontoPile_2877_pointer_547 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_541, i64 0, i32 5
        %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_547, !noalias !2
        
        %pureApp_5429 = call ccc %Pos @unsafeGet_2487(%Pos %v_r_2966_2_3_5290, i64 %fromPile_2876)
        
        
        %stackPointer_668 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %movesDone_2860_pointer_669 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_668, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_669, !noalias !2
        %towers_2861_pointer_670 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_668, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_670, !noalias !2
        %disks_2875_pointer_671 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_668, i64 0, i32 2
        store i64 %disks_2875, ptr %disks_2875_pointer_671, !noalias !2
        %tmp_5332_pointer_672 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_668, i64 0, i32 3
        store i64 %tmp_5332, ptr %tmp_5332_pointer_672, !noalias !2
        %ontoPile_2877_pointer_673 = getelementptr <{%Reference, %Reference, i64, i64, i64}>, %StackPointer %stackPointer_668, i64 0, i32 4
        store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_673, !noalias !2
        %returnAddress_pointer_674 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_668, i64 0, i32 1, i32 0
        %sharer_pointer_675 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_668, i64 0, i32 1, i32 1
        %eraser_pointer_676 = getelementptr <{<{%Reference, %Reference, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_668, i64 0, i32 1, i32 2
        store ptr @returnAddress_548, ptr %returnAddress_pointer_674, !noalias !2
        store ptr @sharer_581, ptr %sharer_pointer_675, !noalias !2
        store ptr @eraser_593, ptr %eraser_pointer_676, !noalias !2
        
        %tag_677 = extractvalue %Pos %pureApp_5429, 0
        %fields_678 = extractvalue %Pos %pureApp_5429, 1
        switch i64 %tag_677, label %label_679 [i64 0, label %label_683 i64 1, label %label_713]
    
    label_679:
        
        ret void
    
    label_683:
        
        %utf8StringLiteral_5437 = call ccc %Pos @c_bytearray_construct(i64 46, ptr @utf8StringLiteral_5437.lit)
        
        %pureApp_5436 = call ccc %Pos @panic_552(%Pos %utf8StringLiteral_5437)
        
        
        
        %pureApp_5438 = call ccc i64 @unboxInt_303(%Pos %pureApp_5436)
        
        
        
        %stackPointer_681 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_682 = getelementptr %FrameHeader, %StackPointer %stackPointer_681, i64 0, i32 0
        %returnAddress_680 = load %ReturnAddress, ptr %returnAddress_pointer_682, !noalias !2
        musttail call tailcc void %returnAddress_680(i64 %pureApp_5438, %Stack %stack)
        ret void
    
    label_713:
        %environment_684 = call ccc %Environment @objectEnvironment(%Object %fields_678)
        %v_coe_4037_16_7_5294_pointer_685 = getelementptr <{%Pos, %Pos}>, %Environment %environment_684, i64 0, i32 0
        %v_coe_4037_16_7_5294 = load %Pos, ptr %v_coe_4037_16_7_5294_pointer_685, !noalias !2
        %v_coe_4038_17_8_5293_pointer_686 = getelementptr <{%Pos, %Pos}>, %Environment %environment_684, i64 0, i32 1
        %v_coe_4038_17_8_5293 = load %Pos, ptr %v_coe_4038_17_8_5293_pointer_686, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_4037_16_7_5294)
        call ccc void @sharePositive(%Pos %v_coe_4038_17_8_5293)
        call ccc void @eraseObject(%Object %fields_678)
        
        %pureApp_5439 = call ccc i64 @unboxInt_303(%Pos %v_coe_4037_16_7_5294)
        
        
        %stackPointer_701 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %fromPile_2876_pointer_702 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_701, i64 0, i32 0
        store i64 %fromPile_2876, ptr %fromPile_2876_pointer_702, !noalias !2
        %v_coe_4038_17_8_5293_pointer_703 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_701, i64 0, i32 1
        store %Pos %v_coe_4038_17_8_5293, ptr %v_coe_4038_17_8_5293_pointer_703, !noalias !2
        %tmp_5337_pointer_704 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_701, i64 0, i32 2
        store i64 %pureApp_5439, ptr %tmp_5337_pointer_704, !noalias !2
        %returnAddress_pointer_705 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_701, i64 0, i32 1, i32 0
        %sharer_pointer_706 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_701, i64 0, i32 1, i32 1
        %eraser_pointer_707 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_701, i64 0, i32 1, i32 2
        store ptr @returnAddress_687, ptr %returnAddress_pointer_705, !noalias !2
        store ptr @sharer_424, ptr %sharer_pointer_706, !noalias !2
        store ptr @eraser_432, ptr %eraser_pointer_707, !noalias !2
        
        %get_5441_pointer_708 = call ccc ptr @getVarPointer(%Reference %towers_2861, %Stack %stack)
        %towers_2861_old_709 = load %Pos, ptr %get_5441_pointer_708, !noalias !2
        call ccc void @sharePositive(%Pos %towers_2861_old_709)
        %get_5441 = load %Pos, ptr %get_5441_pointer_708, !noalias !2
        
        %stackPointer_711 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_712 = getelementptr %FrameHeader, %StackPointer %stackPointer_711, i64 0, i32 0
        %returnAddress_710 = load %ReturnAddress, ptr %returnAddress_pointer_712, !noalias !2
        musttail call tailcc void %returnAddress_710(%Pos %get_5441, %Stack %stack)
        ret void
}



define ccc void @sharer_720(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_721 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_714_pointer_722 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_721, i64 0, i32 0
        %movesDone_2860_714 = load %Reference, ptr %movesDone_2860_714_pointer_722, !noalias !2
        %towers_2861_715_pointer_723 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_721, i64 0, i32 1
        %towers_2861_715 = load %Reference, ptr %towers_2861_715_pointer_723, !noalias !2
        %disks_2875_716_pointer_724 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_721, i64 0, i32 2
        %disks_2875_716 = load i64, ptr %disks_2875_716_pointer_724, !noalias !2
        %fromPile_2876_717_pointer_725 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_721, i64 0, i32 3
        %fromPile_2876_717 = load i64, ptr %fromPile_2876_717_pointer_725, !noalias !2
        %tmp_5332_718_pointer_726 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_721, i64 0, i32 4
        %tmp_5332_718 = load i64, ptr %tmp_5332_718_pointer_726, !noalias !2
        %ontoPile_2877_719_pointer_727 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_721, i64 0, i32 5
        %ontoPile_2877_719 = load i64, ptr %ontoPile_2877_719_pointer_727, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_721)
        ret void
}



define ccc void @eraser_734(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_735 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_728_pointer_736 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_735, i64 0, i32 0
        %movesDone_2860_728 = load %Reference, ptr %movesDone_2860_728_pointer_736, !noalias !2
        %towers_2861_729_pointer_737 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_735, i64 0, i32 1
        %towers_2861_729 = load %Reference, ptr %towers_2861_729_pointer_737, !noalias !2
        %disks_2875_730_pointer_738 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_735, i64 0, i32 2
        %disks_2875_730 = load i64, ptr %disks_2875_730_pointer_738, !noalias !2
        %fromPile_2876_731_pointer_739 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_735, i64 0, i32 3
        %fromPile_2876_731 = load i64, ptr %fromPile_2876_731_pointer_739, !noalias !2
        %tmp_5332_732_pointer_740 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_735, i64 0, i32 4
        %tmp_5332_732 = load i64, ptr %tmp_5332_732_pointer_740, !noalias !2
        %ontoPile_2877_733_pointer_741 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_735, i64 0, i32 5
        %ontoPile_2877_733 = load i64, ptr %ontoPile_2877_733_pointer_741, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_735)
        ret void
}



define tailcc void @returnAddress_532(%Pos %__5421, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_533 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %movesDone_2860_pointer_534 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_533, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_534, !noalias !2
        %towers_2861_pointer_535 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_533, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_535, !noalias !2
        %disks_2875_pointer_536 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_533, i64 0, i32 2
        %disks_2875 = load i64, ptr %disks_2875_pointer_536, !noalias !2
        %fromPile_2876_pointer_537 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_533, i64 0, i32 3
        %fromPile_2876 = load i64, ptr %fromPile_2876_pointer_537, !noalias !2
        %tmp_5332_pointer_538 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_533, i64 0, i32 4
        %tmp_5332 = load i64, ptr %tmp_5332_pointer_538, !noalias !2
        %ontoPile_2877_pointer_539 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_533, i64 0, i32 5
        %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_539, !noalias !2
        call ccc void @erasePositive(%Pos %__5421)
        %stackPointer_742 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %movesDone_2860_pointer_743 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_742, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_743, !noalias !2
        %towers_2861_pointer_744 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_742, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_744, !noalias !2
        %disks_2875_pointer_745 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_742, i64 0, i32 2
        store i64 %disks_2875, ptr %disks_2875_pointer_745, !noalias !2
        %fromPile_2876_pointer_746 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_742, i64 0, i32 3
        store i64 %fromPile_2876, ptr %fromPile_2876_pointer_746, !noalias !2
        %tmp_5332_pointer_747 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_742, i64 0, i32 4
        store i64 %tmp_5332, ptr %tmp_5332_pointer_747, !noalias !2
        %ontoPile_2877_pointer_748 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_742, i64 0, i32 5
        store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_748, !noalias !2
        %returnAddress_pointer_749 = getelementptr <{<{%Reference, %Reference, i64, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_742, i64 0, i32 1, i32 0
        %sharer_pointer_750 = getelementptr <{<{%Reference, %Reference, i64, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_742, i64 0, i32 1, i32 1
        %eraser_pointer_751 = getelementptr <{<{%Reference, %Reference, i64, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_742, i64 0, i32 1, i32 2
        store ptr @returnAddress_540, ptr %returnAddress_pointer_749, !noalias !2
        store ptr @sharer_720, ptr %sharer_pointer_750, !noalias !2
        store ptr @eraser_734, ptr %eraser_pointer_751, !noalias !2
        
        %get_5442_pointer_752 = call ccc ptr @getVarPointer(%Reference %towers_2861, %Stack %stack)
        %towers_2861_old_753 = load %Pos, ptr %get_5442_pointer_752, !noalias !2
        call ccc void @sharePositive(%Pos %towers_2861_old_753)
        %get_5442 = load %Pos, ptr %get_5442_pointer_752, !noalias !2
        
        %stackPointer_755 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_756 = getelementptr %FrameHeader, %StackPointer %stackPointer_755, i64 0, i32 0
        %returnAddress_754 = load %ReturnAddress, ptr %returnAddress_pointer_756, !noalias !2
        musttail call tailcc void %returnAddress_754(%Pos %get_5442, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_794(i64 %v_r_2980_14_5281, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_795 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %movesDone_2860_pointer_796 = getelementptr <{%Reference}>, %StackPointer %stackPointer_795, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_796, !noalias !2
        
        %longLiteral_5445 = add i64 1, 0
        
        %pureApp_5444 = call ccc i64 @infixAdd_96(i64 %v_r_2980_14_5281, i64 %longLiteral_5445)
        
        
        
        %movesDone_2860pointer_797 = call ccc ptr @getVarPointer(%Reference %movesDone_2860, %Stack %stack)
        %movesDone_2860_old_798 = load i64, ptr %movesDone_2860pointer_797, !noalias !2
        store i64 %pureApp_5444, ptr %movesDone_2860pointer_797, !noalias !2
        
        %put_5446_temporary_799 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5446 = insertvalue %Pos %put_5446_temporary_799, %Object null, 1
        
        %stackPointer_801 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_802 = getelementptr %FrameHeader, %StackPointer %stackPointer_801, i64 0, i32 0
        %returnAddress_800 = load %ReturnAddress, ptr %returnAddress_pointer_802, !noalias !2
        musttail call tailcc void %returnAddress_800(%Pos %put_5446, %Stack %stack)
        ret void
}



define ccc void @sharer_804(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_805 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_803_pointer_806 = getelementptr <{%Reference}>, %StackPointer %stackPointer_805, i64 0, i32 0
        %movesDone_2860_803 = load %Reference, ptr %movesDone_2860_803_pointer_806, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_805)
        ret void
}



define ccc void @eraser_808(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_809 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_807_pointer_810 = getelementptr <{%Reference}>, %StackPointer %stackPointer_809, i64 0, i32 0
        %movesDone_2860_807 = load %Reference, ptr %movesDone_2860_807_pointer_810, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_809)
        ret void
}



define tailcc void @returnAddress_791(%Pos %__13_5287, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_792 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %movesDone_2860_pointer_793 = getelementptr <{%Reference}>, %StackPointer %stackPointer_792, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_793, !noalias !2
        call ccc void @erasePositive(%Pos %__13_5287)
        %stackPointer_811 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %movesDone_2860_pointer_812 = getelementptr <{%Reference}>, %StackPointer %stackPointer_811, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_812, !noalias !2
        %returnAddress_pointer_813 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_811, i64 0, i32 1, i32 0
        %sharer_pointer_814 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_811, i64 0, i32 1, i32 1
        %eraser_pointer_815 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_811, i64 0, i32 1, i32 2
        store ptr @returnAddress_794, ptr %returnAddress_pointer_813, !noalias !2
        store ptr @sharer_804, ptr %sharer_pointer_814, !noalias !2
        store ptr @eraser_808, ptr %eraser_pointer_815, !noalias !2
        
        %get_5447_pointer_816 = call ccc ptr @getVarPointer(%Reference %movesDone_2860, %Stack %stack)
        %movesDone_2860_old_817 = load i64, ptr %get_5447_pointer_816, !noalias !2
        %get_5447 = load i64, ptr %get_5447_pointer_816, !noalias !2
        
        %stackPointer_819 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_820 = getelementptr %FrameHeader, %StackPointer %stackPointer_819, i64 0, i32 0
        %returnAddress_818 = load %ReturnAddress, ptr %returnAddress_pointer_820, !noalias !2
        musttail call tailcc void %returnAddress_818(i64 %get_5447, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_786(i64 %v_r_2978_12_5284, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_787 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %movesDone_2860_pointer_788 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_787, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_788, !noalias !2
        %ontoPile_2877_pointer_789 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_787, i64 0, i32 1
        %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_789, !noalias !2
        %towers_2861_pointer_790 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_787, i64 0, i32 2
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_790, !noalias !2
        %stackPointer_823 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %movesDone_2860_pointer_824 = getelementptr <{%Reference}>, %StackPointer %stackPointer_823, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_824, !noalias !2
        %returnAddress_pointer_825 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_823, i64 0, i32 1, i32 0
        %sharer_pointer_826 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_823, i64 0, i32 1, i32 1
        %eraser_pointer_827 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_823, i64 0, i32 1, i32 2
        store ptr @returnAddress_791, ptr %returnAddress_pointer_825, !noalias !2
        store ptr @sharer_804, ptr %sharer_pointer_826, !noalias !2
        store ptr @eraser_808, ptr %eraser_pointer_827, !noalias !2
        
        
        
        
        musttail call tailcc void @pushDisk_2864(i64 %v_r_2978_12_5284, i64 %ontoPile_2877, %Reference %towers_2861, %Stack %stack)
        ret void
}



define ccc void @sharer_831(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_832 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_828_pointer_833 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_832, i64 0, i32 0
        %movesDone_2860_828 = load %Reference, ptr %movesDone_2860_828_pointer_833, !noalias !2
        %ontoPile_2877_829_pointer_834 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_832, i64 0, i32 1
        %ontoPile_2877_829 = load i64, ptr %ontoPile_2877_829_pointer_834, !noalias !2
        %towers_2861_830_pointer_835 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_832, i64 0, i32 2
        %towers_2861_830 = load %Reference, ptr %towers_2861_830_pointer_835, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_832)
        ret void
}



define ccc void @eraser_839(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_840 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_836_pointer_841 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_840, i64 0, i32 0
        %movesDone_2860_836 = load %Reference, ptr %movesDone_2860_836_pointer_841, !noalias !2
        %ontoPile_2877_837_pointer_842 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_840, i64 0, i32 1
        %ontoPile_2877_837 = load i64, ptr %ontoPile_2877_837_pointer_842, !noalias !2
        %towers_2861_838_pointer_843 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_840, i64 0, i32 2
        %towers_2861_838 = load %Reference, ptr %towers_2861_838_pointer_843, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_840)
        ret void
}


@utf8StringLiteral_5449.lit = private constant [46 x i8] c"\41\74\74\65\6d\70\74\69\6e\67\20\74\6f\20\72\65\6d\6f\76\65\20\61\20\64\69\73\6b\20\66\72\6f\6d\20\61\6e\20\65\6d\70\74\79\20\70\69\6c\65"


define tailcc void @returnAddress_861(%Pos %v_r_2970_3_3_25_10_5280, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_862 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %fromPile_2876_pointer_863 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_862, i64 0, i32 0
        %fromPile_2876 = load i64, ptr %fromPile_2876_pointer_863, !noalias !2
        %v_coe_4038_17_8_5278_pointer_864 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_862, i64 0, i32 1
        %v_coe_4038_17_8_5278 = load %Pos, ptr %v_coe_4038_17_8_5278_pointer_864, !noalias !2
        %tmp_5328_pointer_865 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_862, i64 0, i32 2
        %tmp_5328 = load i64, ptr %tmp_5328_pointer_865, !noalias !2
        
        %pureApp_5452 = call ccc %Pos @unsafeSet_2492(%Pos %v_r_2970_3_3_25_10_5280, i64 %fromPile_2876, %Pos %v_coe_4038_17_8_5278)
        call ccc void @erasePositive(%Pos %pureApp_5452)
        
        
        
        %stackPointer_867 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_868 = getelementptr %FrameHeader, %StackPointer %stackPointer_867, i64 0, i32 0
        %returnAddress_866 = load %ReturnAddress, ptr %returnAddress_pointer_868, !noalias !2
        musttail call tailcc void %returnAddress_866(i64 %tmp_5328, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_780(%Pos %v_r_2966_2_3_5275, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_781 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %movesDone_2860_pointer_782 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_781, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_782, !noalias !2
        %towers_2861_pointer_783 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_781, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_783, !noalias !2
        %fromPile_2876_pointer_784 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_781, i64 0, i32 2
        %fromPile_2876 = load i64, ptr %fromPile_2876_pointer_784, !noalias !2
        %ontoPile_2877_pointer_785 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_781, i64 0, i32 3
        %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_785, !noalias !2
        
        %pureApp_5443 = call ccc %Pos @unsafeGet_2487(%Pos %v_r_2966_2_3_5275, i64 %fromPile_2876)
        
        
        %stackPointer_844 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %movesDone_2860_pointer_845 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_844, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_845, !noalias !2
        %ontoPile_2877_pointer_846 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_844, i64 0, i32 1
        store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_846, !noalias !2
        %towers_2861_pointer_847 = getelementptr <{%Reference, i64, %Reference}>, %StackPointer %stackPointer_844, i64 0, i32 2
        store %Reference %towers_2861, ptr %towers_2861_pointer_847, !noalias !2
        %returnAddress_pointer_848 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_844, i64 0, i32 1, i32 0
        %sharer_pointer_849 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_844, i64 0, i32 1, i32 1
        %eraser_pointer_850 = getelementptr <{<{%Reference, i64, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_844, i64 0, i32 1, i32 2
        store ptr @returnAddress_786, ptr %returnAddress_pointer_848, !noalias !2
        store ptr @sharer_831, ptr %sharer_pointer_849, !noalias !2
        store ptr @eraser_839, ptr %eraser_pointer_850, !noalias !2
        
        %tag_851 = extractvalue %Pos %pureApp_5443, 0
        %fields_852 = extractvalue %Pos %pureApp_5443, 1
        switch i64 %tag_851, label %label_853 [i64 0, label %label_857 i64 1, label %label_887]
    
    label_853:
        
        ret void
    
    label_857:
        
        %utf8StringLiteral_5449 = call ccc %Pos @c_bytearray_construct(i64 46, ptr @utf8StringLiteral_5449.lit)
        
        %pureApp_5448 = call ccc %Pos @panic_552(%Pos %utf8StringLiteral_5449)
        
        
        
        %pureApp_5450 = call ccc i64 @unboxInt_303(%Pos %pureApp_5448)
        
        
        
        %stackPointer_855 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_856 = getelementptr %FrameHeader, %StackPointer %stackPointer_855, i64 0, i32 0
        %returnAddress_854 = load %ReturnAddress, ptr %returnAddress_pointer_856, !noalias !2
        musttail call tailcc void %returnAddress_854(i64 %pureApp_5450, %Stack %stack)
        ret void
    
    label_887:
        %environment_858 = call ccc %Environment @objectEnvironment(%Object %fields_852)
        %v_coe_4037_16_7_5279_pointer_859 = getelementptr <{%Pos, %Pos}>, %Environment %environment_858, i64 0, i32 0
        %v_coe_4037_16_7_5279 = load %Pos, ptr %v_coe_4037_16_7_5279_pointer_859, !noalias !2
        %v_coe_4038_17_8_5278_pointer_860 = getelementptr <{%Pos, %Pos}>, %Environment %environment_858, i64 0, i32 1
        %v_coe_4038_17_8_5278 = load %Pos, ptr %v_coe_4038_17_8_5278_pointer_860, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_4037_16_7_5279)
        call ccc void @sharePositive(%Pos %v_coe_4038_17_8_5278)
        call ccc void @eraseObject(%Object %fields_852)
        
        %pureApp_5451 = call ccc i64 @unboxInt_303(%Pos %v_coe_4037_16_7_5279)
        
        
        %stackPointer_875 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %fromPile_2876_pointer_876 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_875, i64 0, i32 0
        store i64 %fromPile_2876, ptr %fromPile_2876_pointer_876, !noalias !2
        %v_coe_4038_17_8_5278_pointer_877 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_875, i64 0, i32 1
        store %Pos %v_coe_4038_17_8_5278, ptr %v_coe_4038_17_8_5278_pointer_877, !noalias !2
        %tmp_5328_pointer_878 = getelementptr <{i64, %Pos, i64}>, %StackPointer %stackPointer_875, i64 0, i32 2
        store i64 %pureApp_5451, ptr %tmp_5328_pointer_878, !noalias !2
        %returnAddress_pointer_879 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_875, i64 0, i32 1, i32 0
        %sharer_pointer_880 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_875, i64 0, i32 1, i32 1
        %eraser_pointer_881 = getelementptr <{<{i64, %Pos, i64}>, %FrameHeader}>, %StackPointer %stackPointer_875, i64 0, i32 1, i32 2
        store ptr @returnAddress_861, ptr %returnAddress_pointer_879, !noalias !2
        store ptr @sharer_424, ptr %sharer_pointer_880, !noalias !2
        store ptr @eraser_432, ptr %eraser_pointer_881, !noalias !2
        
        %get_5453_pointer_882 = call ccc ptr @getVarPointer(%Reference %towers_2861, %Stack %stack)
        %towers_2861_old_883 = load %Pos, ptr %get_5453_pointer_882, !noalias !2
        call ccc void @sharePositive(%Pos %towers_2861_old_883)
        %get_5453 = load %Pos, ptr %get_5453_pointer_882, !noalias !2
        
        %stackPointer_885 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_886 = getelementptr %FrameHeader, %StackPointer %stackPointer_885, i64 0, i32 0
        %returnAddress_884 = load %ReturnAddress, ptr %returnAddress_pointer_886, !noalias !2
        musttail call tailcc void %returnAddress_884(%Pos %get_5453, %Stack %stack)
        ret void
}



define ccc void @sharer_892(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_893 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_888_pointer_894 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_893, i64 0, i32 0
        %movesDone_2860_888 = load %Reference, ptr %movesDone_2860_888_pointer_894, !noalias !2
        %towers_2861_889_pointer_895 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_893, i64 0, i32 1
        %towers_2861_889 = load %Reference, ptr %towers_2861_889_pointer_895, !noalias !2
        %fromPile_2876_890_pointer_896 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_893, i64 0, i32 2
        %fromPile_2876_890 = load i64, ptr %fromPile_2876_890_pointer_896, !noalias !2
        %ontoPile_2877_891_pointer_897 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_893, i64 0, i32 3
        %ontoPile_2877_891 = load i64, ptr %ontoPile_2877_891_pointer_897, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_893)
        ret void
}



define ccc void @eraser_902(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_903 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_898_pointer_904 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_903, i64 0, i32 0
        %movesDone_2860_898 = load %Reference, ptr %movesDone_2860_898_pointer_904, !noalias !2
        %towers_2861_899_pointer_905 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_903, i64 0, i32 1
        %towers_2861_899 = load %Reference, ptr %towers_2861_899_pointer_905, !noalias !2
        %fromPile_2876_900_pointer_906 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_903, i64 0, i32 2
        %fromPile_2876_900 = load i64, ptr %fromPile_2876_900_pointer_906, !noalias !2
        %ontoPile_2877_901_pointer_907 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_903, i64 0, i32 3
        %ontoPile_2877_901 = load i64, ptr %ontoPile_2877_901_pointer_907, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_903)
        ret void
}



define tailcc void @moveDisks_2878(i64 %disks_2875, i64 %fromPile_2876, i64 %ontoPile_2877, %Reference %movesDone_2860, %Reference %towers_2861, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5423 = add i64 1, 0
        
        %pureApp_5422 = call ccc %Pos @infixEq_72(i64 %disks_2875, i64 %longLiteral_5423)
        
        
        
        %tag_529 = extractvalue %Pos %pureApp_5422, 0
        %fields_530 = extractvalue %Pos %pureApp_5422, 1
        switch i64 %tag_529, label %label_531 [i64 0, label %label_779 i64 1, label %label_921]
    
    label_531:
        
        ret void
    
    label_779:
        
        %longLiteral_5425 = add i64 3, 0
        
        %pureApp_5424 = call ccc i64 @infixSub_105(i64 %longLiteral_5425, i64 %fromPile_2876)
        
        
        
        %pureApp_5426 = call ccc i64 @infixSub_105(i64 %pureApp_5424, i64 %ontoPile_2877)
        
        
        
        %longLiteral_5428 = add i64 1, 0
        
        %pureApp_5427 = call ccc i64 @infixSub_105(i64 %disks_2875, i64 %longLiteral_5428)
        
        
        %stackPointer_769 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %movesDone_2860_pointer_770 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_769, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_770, !noalias !2
        %towers_2861_pointer_771 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_769, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_771, !noalias !2
        %disks_2875_pointer_772 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_769, i64 0, i32 2
        store i64 %disks_2875, ptr %disks_2875_pointer_772, !noalias !2
        %fromPile_2876_pointer_773 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_769, i64 0, i32 3
        store i64 %fromPile_2876, ptr %fromPile_2876_pointer_773, !noalias !2
        %tmp_5332_pointer_774 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_769, i64 0, i32 4
        store i64 %pureApp_5426, ptr %tmp_5332_pointer_774, !noalias !2
        %ontoPile_2877_pointer_775 = getelementptr <{%Reference, %Reference, i64, i64, i64, i64}>, %StackPointer %stackPointer_769, i64 0, i32 5
        store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_775, !noalias !2
        %returnAddress_pointer_776 = getelementptr <{<{%Reference, %Reference, i64, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_769, i64 0, i32 1, i32 0
        %sharer_pointer_777 = getelementptr <{<{%Reference, %Reference, i64, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_769, i64 0, i32 1, i32 1
        %eraser_pointer_778 = getelementptr <{<{%Reference, %Reference, i64, i64, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_769, i64 0, i32 1, i32 2
        store ptr @returnAddress_532, ptr %returnAddress_pointer_776, !noalias !2
        store ptr @sharer_720, ptr %sharer_pointer_777, !noalias !2
        store ptr @eraser_734, ptr %eraser_pointer_778, !noalias !2
        
        
        
        
        
        musttail call tailcc void @moveDisks_2878(i64 %pureApp_5427, i64 %fromPile_2876, i64 %pureApp_5426, %Reference %movesDone_2860, %Reference %towers_2861, %Stack %stack)
        ret void
    
    label_921:
        %stackPointer_908 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %movesDone_2860_pointer_909 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_908, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_909, !noalias !2
        %towers_2861_pointer_910 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_908, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_910, !noalias !2
        %fromPile_2876_pointer_911 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_908, i64 0, i32 2
        store i64 %fromPile_2876, ptr %fromPile_2876_pointer_911, !noalias !2
        %ontoPile_2877_pointer_912 = getelementptr <{%Reference, %Reference, i64, i64}>, %StackPointer %stackPointer_908, i64 0, i32 3
        store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_912, !noalias !2
        %returnAddress_pointer_913 = getelementptr <{<{%Reference, %Reference, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_908, i64 0, i32 1, i32 0
        %sharer_pointer_914 = getelementptr <{<{%Reference, %Reference, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_908, i64 0, i32 1, i32 1
        %eraser_pointer_915 = getelementptr <{<{%Reference, %Reference, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_908, i64 0, i32 1, i32 2
        store ptr @returnAddress_780, ptr %returnAddress_pointer_913, !noalias !2
        store ptr @sharer_892, ptr %sharer_pointer_914, !noalias !2
        store ptr @eraser_902, ptr %eraser_pointer_915, !noalias !2
        
        %get_5454_pointer_916 = call ccc ptr @getVarPointer(%Reference %towers_2861, %Stack %stack)
        %towers_2861_old_917 = load %Pos, ptr %get_5454_pointer_916, !noalias !2
        call ccc void @sharePositive(%Pos %towers_2861_old_917)
        %get_5454 = load %Pos, ptr %get_5454_pointer_916, !noalias !2
        
        %stackPointer_919 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_920 = getelementptr %FrameHeader, %StackPointer %stackPointer_919, i64 0, i32 0
        %returnAddress_918 = load %ReturnAddress, ptr %returnAddress_pointer_920, !noalias !2
        musttail call tailcc void %returnAddress_918(%Pos %get_5454, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_927(%Pos %__5456, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_928 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %movesDone_2860_pointer_929 = getelementptr <{%Reference}>, %StackPointer %stackPointer_928, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_929, !noalias !2
        call ccc void @erasePositive(%Pos %__5456)
        
        %get_5457_pointer_930 = call ccc ptr @getVarPointer(%Reference %movesDone_2860, %Stack %stack)
        %movesDone_2860_old_931 = load i64, ptr %get_5457_pointer_930, !noalias !2
        %get_5457 = load i64, ptr %get_5457_pointer_930, !noalias !2
        
        %stackPointer_933 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_934 = getelementptr %FrameHeader, %StackPointer %stackPointer_933, i64 0, i32 0
        %returnAddress_932 = load %ReturnAddress, ptr %returnAddress_pointer_934, !noalias !2
        musttail call tailcc void %returnAddress_932(i64 %get_5457, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_922(%Pos %__5455, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_923 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %movesDone_2860_pointer_924 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_923, i64 0, i32 0
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_924, !noalias !2
        %towers_2861_pointer_925 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_923, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_925, !noalias !2
        %n_2855_pointer_926 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_923, i64 0, i32 2
        %n_2855 = load i64, ptr %n_2855_pointer_926, !noalias !2
        call ccc void @erasePositive(%Pos %__5455)
        %stackPointer_937 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %movesDone_2860_pointer_938 = getelementptr <{%Reference}>, %StackPointer %stackPointer_937, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_938, !noalias !2
        %returnAddress_pointer_939 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_937, i64 0, i32 1, i32 0
        %sharer_pointer_940 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_937, i64 0, i32 1, i32 1
        %eraser_pointer_941 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_937, i64 0, i32 1, i32 2
        store ptr @returnAddress_927, ptr %returnAddress_pointer_939, !noalias !2
        store ptr @sharer_804, ptr %sharer_pointer_940, !noalias !2
        store ptr @eraser_808, ptr %eraser_pointer_941, !noalias !2
        
        %longLiteral_5458 = add i64 0, 0
        
        %longLiteral_5459 = add i64 1, 0
        
        
        
        
        
        musttail call tailcc void @moveDisks_2878(i64 %n_2855, i64 %longLiteral_5458, i64 %longLiteral_5459, %Reference %movesDone_2860, %Reference %towers_2861, %Stack %stack)
        ret void
}



define ccc void @sharer_945(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_946 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_942_pointer_947 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_946, i64 0, i32 0
        %movesDone_2860_942 = load %Reference, ptr %movesDone_2860_942_pointer_947, !noalias !2
        %towers_2861_943_pointer_948 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_946, i64 0, i32 1
        %towers_2861_943 = load %Reference, ptr %towers_2861_943_pointer_948, !noalias !2
        %n_2855_944_pointer_949 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_946, i64 0, i32 2
        %n_2855_944 = load i64, ptr %n_2855_944_pointer_949, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_946)
        ret void
}



define ccc void @eraser_953(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_954 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %movesDone_2860_950_pointer_955 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_954, i64 0, i32 0
        %movesDone_2860_950 = load %Reference, ptr %movesDone_2860_950_pointer_955, !noalias !2
        %towers_2861_951_pointer_956 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_954, i64 0, i32 1
        %towers_2861_951 = load %Reference, ptr %towers_2861_951_pointer_956, !noalias !2
        %n_2855_952_pointer_957 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_954, i64 0, i32 2
        %n_2855_952 = load i64, ptr %n_2855_952_pointer_957, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_954)
        ret void
}



define tailcc void @returnAddress_965(%Pos %returnValue_966, %Stack %stack) {
        
    entry:
        
        %stackPointer_967 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %n_2855_pointer_968 = getelementptr <{i64}>, %StackPointer %stackPointer_967, i64 0, i32 0
        %n_2855 = load i64, ptr %n_2855_pointer_968, !noalias !2
        %stackPointer_970 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_971 = getelementptr %FrameHeader, %StackPointer %stackPointer_970, i64 0, i32 0
        %returnAddress_969 = load %ReturnAddress, ptr %returnAddress_pointer_971, !noalias !2
        musttail call tailcc void %returnAddress_969(%Pos %returnValue_966, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1003(%Pos %v_whileThen_2993_12_4483, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1004 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_4_4474_pointer_1005 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1004, i64 0, i32 0
        %i_4_4474 = load %Reference, ptr %i_4_4474_pointer_1005, !noalias !2
        %towers_2861_pointer_1006 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1004, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_1006, !noalias !2
        call ccc void @erasePositive(%Pos %v_whileThen_2993_12_4483)
        
        
        musttail call tailcc void @b_whileLoop_2988_5_4473(%Reference %i_4_4474, %Reference %towers_2861, %Stack %stack)
        ret void
}



define ccc void @sharer_1009(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1010 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_4_4474_1007_pointer_1011 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1010, i64 0, i32 0
        %i_4_4474_1007 = load %Reference, ptr %i_4_4474_1007_pointer_1011, !noalias !2
        %towers_2861_1008_pointer_1012 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1010, i64 0, i32 1
        %towers_2861_1008 = load %Reference, ptr %towers_2861_1008_pointer_1012, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_1010)
        ret void
}



define ccc void @eraser_1015(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1016 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer, i64 -1
        %i_4_4474_1013_pointer_1017 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1016, i64 0, i32 0
        %i_4_4474_1013 = load %Reference, ptr %i_4_4474_1013_pointer_1017, !noalias !2
        %towers_2861_1014_pointer_1018 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1016, i64 0, i32 1
        %towers_2861_1014 = load %Reference, ptr %towers_2861_1014_pointer_1018, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_1016)
        ret void
}



define tailcc void @returnAddress_999(i64 %v_r_2991_10_4476, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1000 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_4_4474_pointer_1001 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1000, i64 0, i32 0
        %i_4_4474 = load %Reference, ptr %i_4_4474_pointer_1001, !noalias !2
        %towers_2861_pointer_1002 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1000, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_1002, !noalias !2
        
        %longLiteral_5465 = add i64 1, 0
        
        %pureApp_5464 = call ccc i64 @infixSub_105(i64 %v_r_2991_10_4476, i64 %longLiteral_5465)
        
        
        %stackPointer_1019 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_4_4474_pointer_1020 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1019, i64 0, i32 0
        store %Reference %i_4_4474, ptr %i_4_4474_pointer_1020, !noalias !2
        %towers_2861_pointer_1021 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1019, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_1021, !noalias !2
        %returnAddress_pointer_1022 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1019, i64 0, i32 1, i32 0
        %sharer_pointer_1023 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1019, i64 0, i32 1, i32 1
        %eraser_pointer_1024 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1019, i64 0, i32 1, i32 2
        store ptr @returnAddress_1003, ptr %returnAddress_pointer_1022, !noalias !2
        store ptr @sharer_1009, ptr %sharer_pointer_1023, !noalias !2
        store ptr @eraser_1015, ptr %eraser_pointer_1024, !noalias !2
        
        %i_4_4474pointer_1025 = call ccc ptr @getVarPointer(%Reference %i_4_4474, %Stack %stack)
        %i_4_4474_old_1026 = load i64, ptr %i_4_4474pointer_1025, !noalias !2
        store i64 %pureApp_5464, ptr %i_4_4474pointer_1025, !noalias !2
        
        %put_5466_temporary_1027 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5466 = insertvalue %Pos %put_5466_temporary_1027, %Object null, 1
        
        %stackPointer_1029 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1030 = getelementptr %FrameHeader, %StackPointer %stackPointer_1029, i64 0, i32 0
        %returnAddress_1028 = load %ReturnAddress, ptr %returnAddress_pointer_1030, !noalias !2
        musttail call tailcc void %returnAddress_1028(%Pos %put_5466, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_995(%Pos %__9_4482, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_996 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_4_4474_pointer_997 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_996, i64 0, i32 0
        %i_4_4474 = load %Reference, ptr %i_4_4474_pointer_997, !noalias !2
        %towers_2861_pointer_998 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_996, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_998, !noalias !2
        call ccc void @erasePositive(%Pos %__9_4482)
        %stackPointer_1035 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_4_4474_pointer_1036 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1035, i64 0, i32 0
        store %Reference %i_4_4474, ptr %i_4_4474_pointer_1036, !noalias !2
        %towers_2861_pointer_1037 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1035, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_1037, !noalias !2
        %returnAddress_pointer_1038 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1035, i64 0, i32 1, i32 0
        %sharer_pointer_1039 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1035, i64 0, i32 1, i32 1
        %eraser_pointer_1040 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1035, i64 0, i32 1, i32 2
        store ptr @returnAddress_999, ptr %returnAddress_pointer_1038, !noalias !2
        store ptr @sharer_1009, ptr %sharer_pointer_1039, !noalias !2
        store ptr @eraser_1015, ptr %eraser_pointer_1040, !noalias !2
        
        %get_5467_pointer_1041 = call ccc ptr @getVarPointer(%Reference %i_4_4474, %Stack %stack)
        %i_4_4474_old_1042 = load i64, ptr %get_5467_pointer_1041, !noalias !2
        %get_5467 = load i64, ptr %get_5467_pointer_1041, !noalias !2
        
        %stackPointer_1044 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1045 = getelementptr %FrameHeader, %StackPointer %stackPointer_1044, i64 0, i32 0
        %returnAddress_1043 = load %ReturnAddress, ptr %returnAddress_pointer_1045, !noalias !2
        musttail call tailcc void %returnAddress_1043(i64 %get_5467, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_991(i64 %v_r_2989_8_4479, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_992 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_4_4474_pointer_993 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_992, i64 0, i32 0
        %i_4_4474 = load %Reference, ptr %i_4_4474_pointer_993, !noalias !2
        %towers_2861_pointer_994 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_992, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_994, !noalias !2
        %stackPointer_1050 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_4_4474_pointer_1051 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1050, i64 0, i32 0
        store %Reference %i_4_4474, ptr %i_4_4474_pointer_1051, !noalias !2
        %towers_2861_pointer_1052 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1050, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_1052, !noalias !2
        %returnAddress_pointer_1053 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1050, i64 0, i32 1, i32 0
        %sharer_pointer_1054 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1050, i64 0, i32 1, i32 1
        %eraser_pointer_1055 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1050, i64 0, i32 1, i32 2
        store ptr @returnAddress_995, ptr %returnAddress_pointer_1053, !noalias !2
        store ptr @sharer_1009, ptr %sharer_pointer_1054, !noalias !2
        store ptr @eraser_1015, ptr %eraser_pointer_1055, !noalias !2
        
        %longLiteral_5468 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @pushDisk_2864(i64 %v_r_2989_8_4479, i64 %longLiteral_5468, %Reference %towers_2861, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_979(i64 %v_r_2994_6_4478, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_980 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %i_4_4474_pointer_981 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_980, i64 0, i32 0
        %i_4_4474 = load %Reference, ptr %i_4_4474_pointer_981, !noalias !2
        %towers_2861_pointer_982 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_980, i64 0, i32 1
        %towers_2861 = load %Reference, ptr %towers_2861_pointer_982, !noalias !2
        
        %longLiteral_5462 = add i64 0, 0
        
        %pureApp_5461 = call ccc %Pos @infixGte_187(i64 %v_r_2994_6_4478, i64 %longLiteral_5462)
        
        
        
        %tag_983 = extractvalue %Pos %pureApp_5461, 0
        %fields_984 = extractvalue %Pos %pureApp_5461, 1
        switch i64 %tag_983, label %label_985 [i64 0, label %label_990 i64 1, label %label_1071]
    
    label_985:
        
        ret void
    
    label_990:
        
        %unitLiteral_5463_temporary_986 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5463 = insertvalue %Pos %unitLiteral_5463_temporary_986, %Object null, 1
        
        %stackPointer_988 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_989 = getelementptr %FrameHeader, %StackPointer %stackPointer_988, i64 0, i32 0
        %returnAddress_987 = load %ReturnAddress, ptr %returnAddress_pointer_989, !noalias !2
        musttail call tailcc void %returnAddress_987(%Pos %unitLiteral_5463, %Stack %stack)
        ret void
    
    label_1071:
        %stackPointer_1060 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_4_4474_pointer_1061 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1060, i64 0, i32 0
        store %Reference %i_4_4474, ptr %i_4_4474_pointer_1061, !noalias !2
        %towers_2861_pointer_1062 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1060, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_1062, !noalias !2
        %returnAddress_pointer_1063 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1060, i64 0, i32 1, i32 0
        %sharer_pointer_1064 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1060, i64 0, i32 1, i32 1
        %eraser_pointer_1065 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1060, i64 0, i32 1, i32 2
        store ptr @returnAddress_991, ptr %returnAddress_pointer_1063, !noalias !2
        store ptr @sharer_1009, ptr %sharer_pointer_1064, !noalias !2
        store ptr @eraser_1015, ptr %eraser_pointer_1065, !noalias !2
        
        %get_5469_pointer_1066 = call ccc ptr @getVarPointer(%Reference %i_4_4474, %Stack %stack)
        %i_4_4474_old_1067 = load i64, ptr %get_5469_pointer_1066, !noalias !2
        %get_5469 = load i64, ptr %get_5469_pointer_1066, !noalias !2
        
        %stackPointer_1069 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1070 = getelementptr %FrameHeader, %StackPointer %stackPointer_1069, i64 0, i32 0
        %returnAddress_1068 = load %ReturnAddress, ptr %returnAddress_pointer_1070, !noalias !2
        musttail call tailcc void %returnAddress_1068(i64 %get_5469, %Stack %stack)
        ret void
}



define tailcc void @b_whileLoop_2988_5_4473(%Reference %i_4_4474, %Reference %towers_2861, %Stack %stack) {
        
    entry:
        
        %stackPointer_1076 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %i_4_4474_pointer_1077 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1076, i64 0, i32 0
        store %Reference %i_4_4474, ptr %i_4_4474_pointer_1077, !noalias !2
        %towers_2861_pointer_1078 = getelementptr <{%Reference, %Reference}>, %StackPointer %stackPointer_1076, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_1078, !noalias !2
        %returnAddress_pointer_1079 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1076, i64 0, i32 1, i32 0
        %sharer_pointer_1080 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1076, i64 0, i32 1, i32 1
        %eraser_pointer_1081 = getelementptr <{<{%Reference, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_1076, i64 0, i32 1, i32 2
        store ptr @returnAddress_979, ptr %returnAddress_pointer_1079, !noalias !2
        store ptr @sharer_1009, ptr %sharer_pointer_1080, !noalias !2
        store ptr @eraser_1015, ptr %eraser_pointer_1081, !noalias !2
        
        %get_5470_pointer_1082 = call ccc ptr @getVarPointer(%Reference %i_4_4474, %Stack %stack)
        %i_4_4474_old_1083 = load i64, ptr %get_5470_pointer_1082, !noalias !2
        %get_5470 = load i64, ptr %get_5470_pointer_1082, !noalias !2
        
        %stackPointer_1085 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1086 = getelementptr %FrameHeader, %StackPointer %stackPointer_1085, i64 0, i32 0
        %returnAddress_1084 = load %ReturnAddress, ptr %returnAddress_pointer_1086, !noalias !2
        musttail call tailcc void %returnAddress_1084(i64 %get_5470, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_370(%Pos %v_r_3011_15_4422, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_371 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %tmp_5313_pointer_372 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_371, i64 0, i32 0
        %tmp_5313 = load %Pos, ptr %tmp_5313_pointer_372, !noalias !2
        %movesDone_2860_pointer_373 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_371, i64 0, i32 1
        %movesDone_2860 = load %Reference, ptr %movesDone_2860_pointer_373, !noalias !2
        %n_2855_pointer_374 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_371, i64 0, i32 2
        %n_2855 = load i64, ptr %n_2855_pointer_374, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_3011_15_4422)
        %towers_2861 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_390 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %tmp_5313_pointer_391 = getelementptr <{%Pos}>, %StackPointer %stackPointer_390, i64 0, i32 0
        store %Pos %tmp_5313, ptr %tmp_5313_pointer_391, !noalias !2
        %returnAddress_pointer_392 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 0
        %sharer_pointer_393 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 1
        %eraser_pointer_394 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_390, i64 0, i32 1, i32 2
        store ptr @returnAddress_375, ptr %returnAddress_pointer_392, !noalias !2
        store ptr @sharer_383, ptr %sharer_pointer_393, !noalias !2
        store ptr @eraser_387, ptr %eraser_pointer_394, !noalias !2
        %stackPointer_958 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %movesDone_2860_pointer_959 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_958, i64 0, i32 0
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_959, !noalias !2
        %towers_2861_pointer_960 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_958, i64 0, i32 1
        store %Reference %towers_2861, ptr %towers_2861_pointer_960, !noalias !2
        %n_2855_pointer_961 = getelementptr <{%Reference, %Reference, i64}>, %StackPointer %stackPointer_958, i64 0, i32 2
        store i64 %n_2855, ptr %n_2855_pointer_961, !noalias !2
        %returnAddress_pointer_962 = getelementptr <{<{%Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_958, i64 0, i32 1, i32 0
        %sharer_pointer_963 = getelementptr <{<{%Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_958, i64 0, i32 1, i32 1
        %eraser_pointer_964 = getelementptr <{<{%Reference, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_958, i64 0, i32 1, i32 2
        store ptr @returnAddress_922, ptr %returnAddress_pointer_962, !noalias !2
        store ptr @sharer_945, ptr %sharer_pointer_963, !noalias !2
        store ptr @eraser_953, ptr %eraser_pointer_964, !noalias !2
        %i_4_4474 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_974 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %n_2855_pointer_975 = getelementptr <{i64}>, %StackPointer %stackPointer_974, i64 0, i32 0
        store i64 %n_2855, ptr %n_2855_pointer_975, !noalias !2
        %returnAddress_pointer_976 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_974, i64 0, i32 1, i32 0
        %sharer_pointer_977 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_974, i64 0, i32 1, i32 1
        %eraser_pointer_978 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_974, i64 0, i32 1, i32 2
        store ptr @returnAddress_965, ptr %returnAddress_pointer_976, !noalias !2
        store ptr @sharer_348, ptr %sharer_pointer_977, !noalias !2
        store ptr @eraser_352, ptr %eraser_pointer_978, !noalias !2
        
        
        musttail call tailcc void @b_whileLoop_2988_5_4473(%Reference %i_4_4474, %Reference %towers_2861, %Stack %stack)
        ret void
}



define ccc void @sharer_1090(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1091 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5313_1087_pointer_1092 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1091, i64 0, i32 0
        %tmp_5313_1087 = load %Pos, ptr %tmp_5313_1087_pointer_1092, !noalias !2
        %movesDone_2860_1088_pointer_1093 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1091, i64 0, i32 1
        %movesDone_2860_1088 = load %Reference, ptr %movesDone_2860_1088_pointer_1093, !noalias !2
        %n_2855_1089_pointer_1094 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1091, i64 0, i32 2
        %n_2855_1089 = load i64, ptr %n_2855_1089_pointer_1094, !noalias !2
        call ccc void @sharePositive(%Pos %tmp_5313_1087)
        call ccc void @shareFrames(%StackPointer %stackPointer_1091)
        ret void
}



define ccc void @eraser_1098(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1099 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_5313_1095_pointer_1100 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1099, i64 0, i32 0
        %tmp_5313_1095 = load %Pos, ptr %tmp_5313_1095_pointer_1100, !noalias !2
        %movesDone_2860_1096_pointer_1101 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1099, i64 0, i32 1
        %movesDone_2860_1096 = load %Reference, ptr %movesDone_2860_1096_pointer_1101, !noalias !2
        %n_2855_1097_pointer_1102 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1099, i64 0, i32 2
        %n_2855_1097 = load i64, ptr %n_2855_1097_pointer_1102, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5313_1095)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1099)
        ret void
}



define tailcc void @run_2856(i64 %n_2855, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5395 = add i64 0, 0
        
        
        %movesDone_2860 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_355 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2949_4116_pointer_356 = getelementptr <{i64}>, %StackPointer %stackPointer_355, i64 0, i32 0
        store i64 %longLiteral_5395, ptr %v_r_2949_4116_pointer_356, !noalias !2
        %returnAddress_pointer_357 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 0
        %sharer_pointer_358 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 1
        %eraser_pointer_359 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_355, i64 0, i32 1, i32 2
        store ptr @returnAddress_340, ptr %returnAddress_pointer_357, !noalias !2
        store ptr @sharer_348, ptr %sharer_pointer_358, !noalias !2
        store ptr @eraser_352, ptr %eraser_pointer_359, !noalias !2
        
        %make_5397_temporary_360 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5397 = insertvalue %Pos %make_5397_temporary_360, %Object null, 1
        
        
        
        %longLiteral_5399 = add i64 3, 0
        
        %pureApp_5398 = call ccc %Pos @allocate_2473(i64 %longLiteral_5399)
        
        
        call ccc void @sharePositive(%Pos %pureApp_5398)
        %stackPointer_1103 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %tmp_5313_pointer_1104 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1103, i64 0, i32 0
        store %Pos %pureApp_5398, ptr %tmp_5313_pointer_1104, !noalias !2
        %movesDone_2860_pointer_1105 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1103, i64 0, i32 1
        store %Reference %movesDone_2860, ptr %movesDone_2860_pointer_1105, !noalias !2
        %n_2855_pointer_1106 = getelementptr <{%Pos, %Reference, i64}>, %StackPointer %stackPointer_1103, i64 0, i32 2
        store i64 %n_2855, ptr %n_2855_pointer_1106, !noalias !2
        %returnAddress_pointer_1107 = getelementptr <{<{%Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1103, i64 0, i32 1, i32 0
        %sharer_pointer_1108 = getelementptr <{<{%Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1103, i64 0, i32 1, i32 1
        %eraser_pointer_1109 = getelementptr <{<{%Pos, %Reference, i64}>, %FrameHeader}>, %StackPointer %stackPointer_1103, i64 0, i32 1, i32 2
        store ptr @returnAddress_370, ptr %returnAddress_pointer_1107, !noalias !2
        store ptr @sharer_1090, ptr %sharer_pointer_1108, !noalias !2
        store ptr @eraser_1098, ptr %eraser_pointer_1109, !noalias !2
        
        %longLiteral_5471 = add i64 0, 0
        
        
        
        musttail call tailcc void @loop_5_9_4412(i64 %longLiteral_5471, %Pos %make_5397, %Pos %pureApp_5398, %Stack %stack)
        ret void
}


@utf8StringLiteral_5386.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5388.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5391.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_1110(%Pos %v_r_3273_4077, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_1111 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_1112 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1111, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_1112, !noalias !2
        %index_2107_pointer_1113 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1111, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_1113, !noalias !2
        %Exception_2362_pointer_1114 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1111, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_1114, !noalias !2
        
        %tag_1115 = extractvalue %Pos %v_r_3273_4077, 0
        %fields_1116 = extractvalue %Pos %v_r_3273_4077, 1
        switch i64 %tag_1115, label %label_1117 [i64 0, label %label_1121 i64 1, label %label_1127]
    
    label_1117:
        
        ret void
    
    label_1121:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5382 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_1119 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1120 = getelementptr %FrameHeader, %StackPointer %stackPointer_1119, i64 0, i32 0
        %returnAddress_1118 = load %ReturnAddress, ptr %returnAddress_pointer_1120, !noalias !2
        musttail call tailcc void %returnAddress_1118(i64 %pureApp_5382, %Stack %stack)
        ret void
    
    label_1127:
        
        %make_5383_temporary_1122 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5383 = insertvalue %Pos %make_5383_temporary_1122, %Object null, 1
        
        
        
        %pureApp_5384 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5386 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5386.lit)
        
        %pureApp_5385 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5386, %Pos %pureApp_5384)
        
        
        
        %utf8StringLiteral_5388 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5388.lit)
        
        %pureApp_5387 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5385, %Pos %utf8StringLiteral_5388)
        
        
        
        %pureApp_5389 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5387, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5391 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5391.lit)
        
        %pureApp_5390 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5389, %Pos %utf8StringLiteral_5391)
        
        
        
        %vtable_1123 = extractvalue %Neg %Exception_2362, 0
        %closure_1124 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_1125 = getelementptr ptr, ptr %vtable_1123, i64 0
        %functionPointer_1126 = load ptr, ptr %functionPointer_pointer_1125, !noalias !2
        musttail call tailcc void %functionPointer_1126(%Object %closure_1124, %Pos %make_5383, %Pos %pureApp_5390, %Stack %stack)
        ret void
}



define ccc void @sharer_1131(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1132 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_1128_pointer_1133 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1132, i64 0, i32 0
        %str_2106_1128 = load %Pos, ptr %str_2106_1128_pointer_1133, !noalias !2
        %index_2107_1129_pointer_1134 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1132, i64 0, i32 1
        %index_2107_1129 = load i64, ptr %index_2107_1129_pointer_1134, !noalias !2
        %Exception_2362_1130_pointer_1135 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1132, i64 0, i32 2
        %Exception_2362_1130 = load %Neg, ptr %Exception_2362_1130_pointer_1135, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_1128)
        call ccc void @shareNegative(%Neg %Exception_2362_1130)
        call ccc void @shareFrames(%StackPointer %stackPointer_1132)
        ret void
}



define ccc void @eraser_1139(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_1140 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_1136_pointer_1141 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1140, i64 0, i32 0
        %str_2106_1136 = load %Pos, ptr %str_2106_1136_pointer_1141, !noalias !2
        %index_2107_1137_pointer_1142 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1140, i64 0, i32 1
        %index_2107_1137 = load i64, ptr %index_2107_1137_pointer_1142, !noalias !2
        %Exception_2362_1138_pointer_1143 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1140, i64 0, i32 2
        %Exception_2362_1138 = load %Neg, ptr %Exception_2362_1138_pointer_1143, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_1136)
        call ccc void @eraseNegative(%Neg %Exception_2362_1138)
        call ccc void @eraseFrames(%StackPointer %stackPointer_1140)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5381 = add i64 0, 0
        
        %pureApp_5380 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5381)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_1144 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_1145 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1144, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_1145, !noalias !2
        %index_2107_pointer_1146 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1144, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_1146, !noalias !2
        %Exception_2362_pointer_1147 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_1144, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_1147, !noalias !2
        %returnAddress_pointer_1148 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1144, i64 0, i32 1, i32 0
        %sharer_pointer_1149 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1144, i64 0, i32 1, i32 1
        %eraser_pointer_1150 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_1144, i64 0, i32 1, i32 2
        store ptr @returnAddress_1110, ptr %returnAddress_pointer_1148, !noalias !2
        store ptr @sharer_1131, ptr %sharer_pointer_1149, !noalias !2
        store ptr @eraser_1139, ptr %eraser_pointer_1150, !noalias !2
        
        %tag_1151 = extractvalue %Pos %pureApp_5380, 0
        %fields_1152 = extractvalue %Pos %pureApp_5380, 1
        switch i64 %tag_1151, label %label_1153 [i64 0, label %label_1157 i64 1, label %label_1162]
    
    label_1153:
        
        ret void
    
    label_1157:
        
        %pureApp_5392 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5393 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5392)
        
        
        
        %stackPointer_1155 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1156 = getelementptr %FrameHeader, %StackPointer %stackPointer_1155, i64 0, i32 0
        %returnAddress_1154 = load %ReturnAddress, ptr %returnAddress_pointer_1156, !noalias !2
        musttail call tailcc void %returnAddress_1154(%Pos %pureApp_5393, %Stack %stack)
        ret void
    
    label_1162:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5394_temporary_1158 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5394 = insertvalue %Pos %booleanLiteral_5394_temporary_1158, %Object null, 1
        
        %stackPointer_1160 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_1161 = getelementptr %FrameHeader, %StackPointer %stackPointer_1160, i64 0, i32 0
        %returnAddress_1159 = load %ReturnAddress, ptr %returnAddress_pointer_1161, !noalias !2
        musttail call tailcc void %returnAddress_1159(%Pos %booleanLiteral_5394, %Stack %stack)
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
        
        musttail call tailcc void @main_2857(%Stack %stack)
        ret void
}
