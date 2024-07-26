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



define tailcc void @returnAddress_3(i64 %r_2475, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5486 = call ccc %Pos @show_14(i64 %r_2475)
        
        
        
        %pureApp_5487 = call ccc %Pos @println_1(%Pos %pureApp_5486)
        
        
        
        %stackPointer_5 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_6 = getelementptr %FrameHeader, %StackPointer %stackPointer_5, i64 0, i32 0
        %returnAddress_4 = load %ReturnAddress, ptr %returnAddress_pointer_6, !noalias !2
        musttail call tailcc void %returnAddress_4(%Pos %pureApp_5487, %Stack %stack)
        ret void
}



define ccc void @sharer_7(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_8 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @shareFrames(%StackPointer %stackPointer_8)
        ret void
}



define ccc void @eraser_9(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_10 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @eraseFrames(%StackPointer %stackPointer_10)
        ret void
}



define tailcc void @returnAddress_15(i64 %returnValue_16, %Stack %stack) {
        
    entry:
        
        %stackPointer_17 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2551_3_5240_pointer_18 = getelementptr <{i64}>, %StackPointer %stackPointer_17, i64 0, i32 0
        %v_r_2551_3_5240 = load i64, ptr %v_r_2551_3_5240_pointer_18, !noalias !2
        %stackPointer_20 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_21 = getelementptr %FrameHeader, %StackPointer %stackPointer_20, i64 0, i32 0
        %returnAddress_19 = load %ReturnAddress, ptr %returnAddress_pointer_21, !noalias !2
        musttail call tailcc void %returnAddress_19(i64 %returnValue_16, %Stack %stack)
        ret void
}



define ccc void @sharer_23(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_24 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2551_3_5240_22_pointer_25 = getelementptr <{i64}>, %StackPointer %stackPointer_24, i64 0, i32 0
        %v_r_2551_3_5240_22 = load i64, ptr %v_r_2551_3_5240_22_pointer_25, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_24)
        ret void
}



define ccc void @eraser_27(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_28 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2551_3_5240_26_pointer_29 = getelementptr <{i64}>, %StackPointer %stackPointer_28, i64 0, i32 0
        %v_r_2551_3_5240_26 = load i64, ptr %v_r_2551_3_5240_26_pointer_29, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_28)
        ret void
}



define tailcc void @returnAddress_48(%Pos %__359_5312, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_49 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %i_209_5097_pointer_50 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_49, i64 0, i32 0
        %i_209_5097 = load i64, ptr %i_209_5097_pointer_50, !noalias !2
        %state_4_4970_pointer_51 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_49, i64 0, i32 1
        %state_4_4970 = load %Reference, ptr %state_4_4970_pointer_51, !noalias !2
        %tree_2_5241_pointer_52 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_49, i64 0, i32 2
        %tree_2_5241 = load %Pos, ptr %tree_2_5241_pointer_52, !noalias !2
        call ccc void @erasePositive(%Pos %__359_5312)
        
        %longLiteral_5492 = add i64 1, 0
        
        %pureApp_5491 = call ccc i64 @infixSub_105(i64 %i_209_5097, i64 %longLiteral_5492)
        
        
        
        
        
        musttail call tailcc void @loop_208_5045(i64 %pureApp_5491, %Reference %state_4_4970, %Pos %tree_2_5241, %Stack %stack)
        ret void
}



define ccc void @sharer_56(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_57 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %i_209_5097_53_pointer_58 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_57, i64 0, i32 0
        %i_209_5097_53 = load i64, ptr %i_209_5097_53_pointer_58, !noalias !2
        %state_4_4970_54_pointer_59 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_57, i64 0, i32 1
        %state_4_4970_54 = load %Reference, ptr %state_4_4970_54_pointer_59, !noalias !2
        %tree_2_5241_55_pointer_60 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_57, i64 0, i32 2
        %tree_2_5241_55 = load %Pos, ptr %tree_2_5241_55_pointer_60, !noalias !2
        call ccc void @sharePositive(%Pos %tree_2_5241_55)
        call ccc void @shareFrames(%StackPointer %stackPointer_57)
        ret void
}



define ccc void @eraser_64(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_65 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer, i64 -1
        %i_209_5097_61_pointer_66 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_65, i64 0, i32 0
        %i_209_5097_61 = load i64, ptr %i_209_5097_61_pointer_66, !noalias !2
        %state_4_4970_62_pointer_67 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_65, i64 0, i32 1
        %state_4_4970_62 = load %Reference, ptr %state_4_4970_62_pointer_67, !noalias !2
        %tree_2_5241_63_pointer_68 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_65, i64 0, i32 2
        %tree_2_5241_63 = load %Pos, ptr %tree_2_5241_63_pointer_68, !noalias !2
        call ccc void @erasePositive(%Pos %tree_2_5241_63)
        call ccc void @eraseFrames(%StackPointer %stackPointer_65)
        ret void
}



define tailcc void @returnAddress_43(i64 %v_r_2582_358_5287, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_44 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %i_209_5097_pointer_45 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_44, i64 0, i32 0
        %i_209_5097 = load i64, ptr %i_209_5097_pointer_45, !noalias !2
        %state_4_4970_pointer_46 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_44, i64 0, i32 1
        %state_4_4970 = load %Reference, ptr %state_4_4970_pointer_46, !noalias !2
        %tree_2_5241_pointer_47 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_44, i64 0, i32 2
        %tree_2_5241 = load %Pos, ptr %tree_2_5241_pointer_47, !noalias !2
        %stackPointer_69 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %i_209_5097_pointer_70 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_69, i64 0, i32 0
        store i64 %i_209_5097, ptr %i_209_5097_pointer_70, !noalias !2
        %state_4_4970_pointer_71 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_69, i64 0, i32 1
        store %Reference %state_4_4970, ptr %state_4_4970_pointer_71, !noalias !2
        %tree_2_5241_pointer_72 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_69, i64 0, i32 2
        store %Pos %tree_2_5241, ptr %tree_2_5241_pointer_72, !noalias !2
        %returnAddress_pointer_73 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_69, i64 0, i32 1, i32 0
        %sharer_pointer_74 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_69, i64 0, i32 1, i32 1
        %eraser_pointer_75 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_69, i64 0, i32 1, i32 2
        store ptr @returnAddress_48, ptr %returnAddress_pointer_73, !noalias !2
        store ptr @sharer_56, ptr %sharer_pointer_74, !noalias !2
        store ptr @eraser_64, ptr %eraser_pointer_75, !noalias !2
        
        %state_4_4970pointer_76 = call ccc ptr @getVarPointer(%Reference %state_4_4970, %Stack %stack)
        %state_4_4970_old_77 = load i64, ptr %state_4_4970pointer_76, !noalias !2
        store i64 %v_r_2582_358_5287, ptr %state_4_4970pointer_76, !noalias !2
        
        %put_5493_temporary_78 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5493 = insertvalue %Pos %put_5493_temporary_78, %Object null, 1
        
        %stackPointer_80 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_81 = getelementptr %FrameHeader, %StackPointer %stackPointer_80, i64 0, i32 0
        %returnAddress_79 = load %ReturnAddress, ptr %returnAddress_pointer_81, !noalias !2
        musttail call tailcc void %returnAddress_79(%Pos %put_5493, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_38(%Pos %v_r_2581_357_5130, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_39 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %i_209_5097_pointer_40 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_39, i64 0, i32 0
        %i_209_5097 = load i64, ptr %i_209_5097_pointer_40, !noalias !2
        %state_4_4970_pointer_41 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_39, i64 0, i32 1
        %state_4_4970 = load %Reference, ptr %state_4_4970_pointer_41, !noalias !2
        %tree_2_5241_pointer_42 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_39, i64 0, i32 2
        %tree_2_5241 = load %Pos, ptr %tree_2_5241_pointer_42, !noalias !2
        %stackPointer_88 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %i_209_5097_pointer_89 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_88, i64 0, i32 0
        store i64 %i_209_5097, ptr %i_209_5097_pointer_89, !noalias !2
        %state_4_4970_pointer_90 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_88, i64 0, i32 1
        store %Reference %state_4_4970, ptr %state_4_4970_pointer_90, !noalias !2
        %tree_2_5241_pointer_91 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_88, i64 0, i32 2
        store %Pos %tree_2_5241, ptr %tree_2_5241_pointer_91, !noalias !2
        %returnAddress_pointer_92 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_88, i64 0, i32 1, i32 0
        %sharer_pointer_93 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_88, i64 0, i32 1, i32 1
        %eraser_pointer_94 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_88, i64 0, i32 1, i32 2
        store ptr @returnAddress_43, ptr %returnAddress_pointer_92, !noalias !2
        store ptr @sharer_56, ptr %sharer_pointer_93, !noalias !2
        store ptr @eraser_64, ptr %eraser_pointer_94, !noalias !2
        
        
        
        musttail call tailcc void @maximum_2438(%Pos %v_r_2581_357_5130, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_109(%Pos %returned_5494, %Stack %stack) {
        
    entry:
        
        %stack_110 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_112 = call ccc %StackPointer @stackDeallocate(%Stack %stack_110, i64 24)
        %returnAddress_pointer_113 = getelementptr %FrameHeader, %StackPointer %stackPointer_112, i64 0, i32 0
        %returnAddress_111 = load %ReturnAddress, ptr %returnAddress_pointer_113, !noalias !2
        musttail call tailcc void %returnAddress_111(%Pos %returned_5494, %Stack %stack_110)
        ret void
}



define ccc void @sharer_114(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_115 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_116(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_117 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_117)
        ret void
}



define tailcc void @returnAddress_168(i64 %v_r_2547_8_22_53_140_350_5122, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5513 = add i64 1009, 0
        
        %pureApp_5512 = call ccc i64 @mod_108(i64 %v_r_2547_8_22_53_140_350_5122, i64 %longLiteral_5513)
        
        
        
        %stackPointer_170 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_171 = getelementptr %FrameHeader, %StackPointer %stackPointer_170, i64 0, i32 0
        %returnAddress_169 = load %ReturnAddress, ptr %returnAddress_pointer_171, !noalias !2
        musttail call tailcc void %returnAddress_169(i64 %pureApp_5512, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_165(i64 %v_r_2560_16_47_134_344_5260, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_166 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_y_2564_33_91_301_5000_pointer_167 = getelementptr <{i64}>, %StackPointer %stackPointer_166, i64 0, i32 0
        %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_167, !noalias !2
        
        %longLiteral_5506 = add i64 503, 0
        
        %pureApp_5505 = call ccc i64 @infixMul_99(i64 %longLiteral_5506, i64 %v_r_2560_16_47_134_344_5260)
        
        
        
        %pureApp_5507 = call ccc i64 @infixSub_105(i64 %v_y_2564_33_91_301_5000, i64 %pureApp_5505)
        
        
        
        %longLiteral_5509 = add i64 37, 0
        
        %pureApp_5508 = call ccc i64 @infixAdd_96(i64 %pureApp_5507, i64 %longLiteral_5509)
        
        
        
        %longLiteral_5511 = add i64 0, 0
        
        %pureApp_5510 = call ccc %Pos @infixLt_178(i64 %pureApp_5508, i64 %longLiteral_5511)
        
        
        %stackPointer_172 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_173 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_172, i64 0, i32 1, i32 0
        %sharer_pointer_174 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_172, i64 0, i32 1, i32 1
        %eraser_pointer_175 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_172, i64 0, i32 1, i32 2
        store ptr @returnAddress_168, ptr %returnAddress_pointer_173, !noalias !2
        store ptr @sharer_7, ptr %sharer_pointer_174, !noalias !2
        store ptr @eraser_9, ptr %eraser_pointer_175, !noalias !2
        
        %tag_176 = extractvalue %Pos %pureApp_5510, 0
        %fields_177 = extractvalue %Pos %pureApp_5510, 1
        switch i64 %tag_176, label %label_178 [i64 0, label %label_182 i64 1, label %label_186]
    
    label_178:
        
        ret void
    
    label_182:
        
        %stackPointer_180 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_181 = getelementptr %FrameHeader, %StackPointer %stackPointer_180, i64 0, i32 0
        %returnAddress_179 = load %ReturnAddress, ptr %returnAddress_pointer_181, !noalias !2
        musttail call tailcc void %returnAddress_179(i64 %pureApp_5508, %Stack %stack)
        ret void
    
    label_186:
        
        %longLiteral_5515 = add i64 0, 0
        
        %pureApp_5514 = call ccc i64 @infixSub_105(i64 %longLiteral_5515, i64 %pureApp_5508)
        
        
        
        %stackPointer_184 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_185 = getelementptr %FrameHeader, %StackPointer %stackPointer_184, i64 0, i32 0
        %returnAddress_183 = load %ReturnAddress, ptr %returnAddress_pointer_185, !noalias !2
        musttail call tailcc void %returnAddress_183(i64 %pureApp_5514, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_159(%Pos %__15_46_133_343_5311, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_160 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %v_y_2564_33_91_301_5000_pointer_161 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 0
        %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_161, !noalias !2
        %next_5_36_123_333_5273_pointer_162 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 1
        %next_5_36_123_333_5273 = load %Pos, ptr %next_5_36_123_333_5273_pointer_162, !noalias !2
        %state_4_4970_pointer_163 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 2
        %state_4_4970 = load %Reference, ptr %state_4_4970_pointer_163, !noalias !2
        %p_2_212_5152_pointer_164 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_160, i64 0, i32 3
        %p_2_212_5152 = load %Prompt, ptr %p_2_212_5152_pointer_164, !noalias !2
        call ccc void @erasePositive(%Pos %__15_46_133_343_5311)
        %stackPointer_189 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_y_2564_33_91_301_5000_pointer_190 = getelementptr <{i64}>, %StackPointer %stackPointer_189, i64 0, i32 0
        store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_190, !noalias !2
        %returnAddress_pointer_191 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_189, i64 0, i32 1, i32 0
        %sharer_pointer_192 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_189, i64 0, i32 1, i32 1
        %eraser_pointer_193 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_189, i64 0, i32 1, i32 2
        store ptr @returnAddress_165, ptr %returnAddress_pointer_191, !noalias !2
        store ptr @sharer_23, ptr %sharer_pointer_192, !noalias !2
        store ptr @eraser_27, ptr %eraser_pointer_193, !noalias !2
        
        
        
        musttail call tailcc void @explore_worker_4_33_243_4974(%Pos %next_5_36_123_333_5273, %Reference %state_4_4970, %Prompt %p_2_212_5152, %Stack %stack)
        ret void
}



define ccc void @sharer_198(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_199 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_y_2564_33_91_301_5000_194_pointer_200 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_199, i64 0, i32 0
        %v_y_2564_33_91_301_5000_194 = load i64, ptr %v_y_2564_33_91_301_5000_194_pointer_200, !noalias !2
        %next_5_36_123_333_5273_195_pointer_201 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_199, i64 0, i32 1
        %next_5_36_123_333_5273_195 = load %Pos, ptr %next_5_36_123_333_5273_195_pointer_201, !noalias !2
        %state_4_4970_196_pointer_202 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_199, i64 0, i32 2
        %state_4_4970_196 = load %Reference, ptr %state_4_4970_196_pointer_202, !noalias !2
        %p_2_212_5152_197_pointer_203 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_199, i64 0, i32 3
        %p_2_212_5152_197 = load %Prompt, ptr %p_2_212_5152_197_pointer_203, !noalias !2
        call ccc void @sharePositive(%Pos %next_5_36_123_333_5273_195)
        call ccc void @shareFrames(%StackPointer %stackPointer_199)
        ret void
}



define ccc void @eraser_208(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_209 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_y_2564_33_91_301_5000_204_pointer_210 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_209, i64 0, i32 0
        %v_y_2564_33_91_301_5000_204 = load i64, ptr %v_y_2564_33_91_301_5000_204_pointer_210, !noalias !2
        %next_5_36_123_333_5273_205_pointer_211 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_209, i64 0, i32 1
        %next_5_36_123_333_5273_205 = load %Pos, ptr %next_5_36_123_333_5273_205_pointer_211, !noalias !2
        %state_4_4970_206_pointer_212 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_209, i64 0, i32 2
        %state_4_4970_206 = load %Reference, ptr %state_4_4970_206_pointer_212, !noalias !2
        %p_2_212_5152_207_pointer_213 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_209, i64 0, i32 3
        %p_2_212_5152_207 = load %Prompt, ptr %p_2_212_5152_207_pointer_213, !noalias !2
        call ccc void @erasePositive(%Pos %next_5_36_123_333_5273_205)
        call ccc void @eraseFrames(%StackPointer %stackPointer_209)
        ret void
}



define tailcc void @returnAddress_153(i64 %v_r_2547_8_12_43_130_340_5268, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_154 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %state_4_4970_pointer_155 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_154, i64 0, i32 0
        %state_4_4970 = load %Reference, ptr %state_4_4970_pointer_155, !noalias !2
        %next_5_36_123_333_5273_pointer_156 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_154, i64 0, i32 1
        %next_5_36_123_333_5273 = load %Pos, ptr %next_5_36_123_333_5273_pointer_156, !noalias !2
        %p_2_212_5152_pointer_157 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_154, i64 0, i32 2
        %p_2_212_5152 = load %Prompt, ptr %p_2_212_5152_pointer_157, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_158 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_154, i64 0, i32 3
        %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_158, !noalias !2
        
        %longLiteral_5504 = add i64 1009, 0
        
        %pureApp_5503 = call ccc i64 @mod_108(i64 %v_r_2547_8_12_43_130_340_5268, i64 %longLiteral_5504)
        
        
        %stackPointer_214 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %v_y_2564_33_91_301_5000_pointer_215 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_214, i64 0, i32 0
        store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_215, !noalias !2
        %next_5_36_123_333_5273_pointer_216 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_214, i64 0, i32 1
        store %Pos %next_5_36_123_333_5273, ptr %next_5_36_123_333_5273_pointer_216, !noalias !2
        %state_4_4970_pointer_217 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_214, i64 0, i32 2
        store %Reference %state_4_4970, ptr %state_4_4970_pointer_217, !noalias !2
        %p_2_212_5152_pointer_218 = getelementptr <{i64, %Pos, %Reference, %Prompt}>, %StackPointer %stackPointer_214, i64 0, i32 3
        store %Prompt %p_2_212_5152, ptr %p_2_212_5152_pointer_218, !noalias !2
        %returnAddress_pointer_219 = getelementptr <{<{i64, %Pos, %Reference, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_214, i64 0, i32 1, i32 0
        %sharer_pointer_220 = getelementptr <{<{i64, %Pos, %Reference, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_214, i64 0, i32 1, i32 1
        %eraser_pointer_221 = getelementptr <{<{i64, %Pos, %Reference, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_214, i64 0, i32 1, i32 2
        store ptr @returnAddress_159, ptr %returnAddress_pointer_219, !noalias !2
        store ptr @sharer_198, ptr %sharer_pointer_220, !noalias !2
        store ptr @eraser_208, ptr %eraser_pointer_221, !noalias !2
        
        %state_4_4970pointer_222 = call ccc ptr @getVarPointer(%Reference %state_4_4970, %Stack %stack)
        %state_4_4970_old_223 = load i64, ptr %state_4_4970pointer_222, !noalias !2
        store i64 %pureApp_5503, ptr %state_4_4970pointer_222, !noalias !2
        
        %put_5516_temporary_224 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5516 = insertvalue %Pos %put_5516_temporary_224, %Object null, 1
        
        %stackPointer_226 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_227 = getelementptr %FrameHeader, %StackPointer %stackPointer_226, i64 0, i32 0
        %returnAddress_225 = load %ReturnAddress, ptr %returnAddress_pointer_227, !noalias !2
        musttail call tailcc void %returnAddress_225(%Pos %put_5516, %Stack %stack)
        ret void
}



define ccc void @sharer_232(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_233 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %state_4_4970_228_pointer_234 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_233, i64 0, i32 0
        %state_4_4970_228 = load %Reference, ptr %state_4_4970_228_pointer_234, !noalias !2
        %next_5_36_123_333_5273_229_pointer_235 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_233, i64 0, i32 1
        %next_5_36_123_333_5273_229 = load %Pos, ptr %next_5_36_123_333_5273_229_pointer_235, !noalias !2
        %p_2_212_5152_230_pointer_236 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_233, i64 0, i32 2
        %p_2_212_5152_230 = load %Prompt, ptr %p_2_212_5152_230_pointer_236, !noalias !2
        %v_y_2564_33_91_301_5000_231_pointer_237 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_233, i64 0, i32 3
        %v_y_2564_33_91_301_5000_231 = load i64, ptr %v_y_2564_33_91_301_5000_231_pointer_237, !noalias !2
        call ccc void @sharePositive(%Pos %next_5_36_123_333_5273_229)
        call ccc void @shareFrames(%StackPointer %stackPointer_233)
        ret void
}



define ccc void @eraser_242(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_243 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %state_4_4970_238_pointer_244 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_243, i64 0, i32 0
        %state_4_4970_238 = load %Reference, ptr %state_4_4970_238_pointer_244, !noalias !2
        %next_5_36_123_333_5273_239_pointer_245 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_243, i64 0, i32 1
        %next_5_36_123_333_5273_239 = load %Pos, ptr %next_5_36_123_333_5273_239_pointer_245, !noalias !2
        %p_2_212_5152_240_pointer_246 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_243, i64 0, i32 2
        %p_2_212_5152_240 = load %Prompt, ptr %p_2_212_5152_240_pointer_246, !noalias !2
        %v_y_2564_33_91_301_5000_241_pointer_247 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_243, i64 0, i32 3
        %v_y_2564_33_91_301_5000_241 = load i64, ptr %v_y_2564_33_91_301_5000_241_pointer_247, !noalias !2
        call ccc void @erasePositive(%Pos %next_5_36_123_333_5273_239)
        call ccc void @eraseFrames(%StackPointer %stackPointer_243)
        ret void
}



define tailcc void @returnAddress_147(i64 %v_r_2557_6_37_124_334_5038, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_148 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %state_4_4970_pointer_149 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_148, i64 0, i32 0
        %state_4_4970 = load %Reference, ptr %state_4_4970_pointer_149, !noalias !2
        %next_5_36_123_333_5273_pointer_150 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_148, i64 0, i32 1
        %next_5_36_123_333_5273 = load %Pos, ptr %next_5_36_123_333_5273_pointer_150, !noalias !2
        %p_2_212_5152_pointer_151 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_148, i64 0, i32 2
        %p_2_212_5152 = load %Prompt, ptr %p_2_212_5152_pointer_151, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_152 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_148, i64 0, i32 3
        %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_152, !noalias !2
        
        %longLiteral_5497 = add i64 503, 0
        
        %pureApp_5496 = call ccc i64 @infixMul_99(i64 %longLiteral_5497, i64 %v_y_2564_33_91_301_5000)
        
        
        
        %pureApp_5498 = call ccc i64 @infixSub_105(i64 %v_r_2557_6_37_124_334_5038, i64 %pureApp_5496)
        
        
        
        %longLiteral_5500 = add i64 37, 0
        
        %pureApp_5499 = call ccc i64 @infixAdd_96(i64 %pureApp_5498, i64 %longLiteral_5500)
        
        
        
        %longLiteral_5502 = add i64 0, 0
        
        %pureApp_5501 = call ccc %Pos @infixLt_178(i64 %pureApp_5499, i64 %longLiteral_5502)
        
        
        %stackPointer_248 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %state_4_4970_pointer_249 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_248, i64 0, i32 0
        store %Reference %state_4_4970, ptr %state_4_4970_pointer_249, !noalias !2
        %next_5_36_123_333_5273_pointer_250 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_248, i64 0, i32 1
        store %Pos %next_5_36_123_333_5273, ptr %next_5_36_123_333_5273_pointer_250, !noalias !2
        %p_2_212_5152_pointer_251 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_248, i64 0, i32 2
        store %Prompt %p_2_212_5152, ptr %p_2_212_5152_pointer_251, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_252 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_248, i64 0, i32 3
        store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_252, !noalias !2
        %returnAddress_pointer_253 = getelementptr <{<{%Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_248, i64 0, i32 1, i32 0
        %sharer_pointer_254 = getelementptr <{<{%Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_248, i64 0, i32 1, i32 1
        %eraser_pointer_255 = getelementptr <{<{%Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_248, i64 0, i32 1, i32 2
        store ptr @returnAddress_153, ptr %returnAddress_pointer_253, !noalias !2
        store ptr @sharer_232, ptr %sharer_pointer_254, !noalias !2
        store ptr @eraser_242, ptr %eraser_pointer_255, !noalias !2
        
        %tag_256 = extractvalue %Pos %pureApp_5501, 0
        %fields_257 = extractvalue %Pos %pureApp_5501, 1
        switch i64 %tag_256, label %label_258 [i64 0, label %label_262 i64 1, label %label_266]
    
    label_258:
        
        ret void
    
    label_262:
        
        %stackPointer_260 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_261 = getelementptr %FrameHeader, %StackPointer %stackPointer_260, i64 0, i32 0
        %returnAddress_259 = load %ReturnAddress, ptr %returnAddress_pointer_261, !noalias !2
        musttail call tailcc void %returnAddress_259(i64 %pureApp_5499, %Stack %stack)
        ret void
    
    label_266:
        
        %longLiteral_5518 = add i64 0, 0
        
        %pureApp_5517 = call ccc i64 @infixSub_105(i64 %longLiteral_5518, i64 %pureApp_5499)
        
        
        
        %stackPointer_264 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_265 = getelementptr %FrameHeader, %StackPointer %stackPointer_264, i64 0, i32 0
        %returnAddress_263 = load %ReturnAddress, ptr %returnAddress_pointer_265, !noalias !2
        musttail call tailcc void %returnAddress_263(i64 %pureApp_5517, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_142(%Pos %next_5_36_123_333_5273, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_143 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %state_4_4970_pointer_144 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_143, i64 0, i32 0
        %state_4_4970 = load %Reference, ptr %state_4_4970_pointer_144, !noalias !2
        %p_2_212_5152_pointer_145 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_143, i64 0, i32 1
        %p_2_212_5152 = load %Prompt, ptr %p_2_212_5152_pointer_145, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_146 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_143, i64 0, i32 2
        %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_146, !noalias !2
        %stackPointer_275 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %state_4_4970_pointer_276 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_275, i64 0, i32 0
        store %Reference %state_4_4970, ptr %state_4_4970_pointer_276, !noalias !2
        %next_5_36_123_333_5273_pointer_277 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_275, i64 0, i32 1
        store %Pos %next_5_36_123_333_5273, ptr %next_5_36_123_333_5273_pointer_277, !noalias !2
        %p_2_212_5152_pointer_278 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_275, i64 0, i32 2
        store %Prompt %p_2_212_5152, ptr %p_2_212_5152_pointer_278, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_279 = getelementptr <{%Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_275, i64 0, i32 3
        store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_279, !noalias !2
        %returnAddress_pointer_280 = getelementptr <{<{%Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_275, i64 0, i32 1, i32 0
        %sharer_pointer_281 = getelementptr <{<{%Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_275, i64 0, i32 1, i32 1
        %eraser_pointer_282 = getelementptr <{<{%Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_275, i64 0, i32 1, i32 2
        store ptr @returnAddress_147, ptr %returnAddress_pointer_280, !noalias !2
        store ptr @sharer_232, ptr %sharer_pointer_281, !noalias !2
        store ptr @eraser_242, ptr %eraser_pointer_282, !noalias !2
        
        %get_5519_pointer_283 = call ccc ptr @getVarPointer(%Reference %state_4_4970, %Stack %stack)
        %state_4_4970_old_284 = load i64, ptr %get_5519_pointer_283, !noalias !2
        %get_5519 = load i64, ptr %get_5519_pointer_283, !noalias !2
        
        %stackPointer_286 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_287 = getelementptr %FrameHeader, %StackPointer %stackPointer_286, i64 0, i32 0
        %returnAddress_285 = load %ReturnAddress, ptr %returnAddress_pointer_287, !noalias !2
        musttail call tailcc void %returnAddress_285(i64 %get_5519, %Stack %stack)
        ret void
}



define ccc void @sharer_291(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_292 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %state_4_4970_288_pointer_293 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_292, i64 0, i32 0
        %state_4_4970_288 = load %Reference, ptr %state_4_4970_288_pointer_293, !noalias !2
        %p_2_212_5152_289_pointer_294 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_292, i64 0, i32 1
        %p_2_212_5152_289 = load %Prompt, ptr %p_2_212_5152_289_pointer_294, !noalias !2
        %v_y_2564_33_91_301_5000_290_pointer_295 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_292, i64 0, i32 2
        %v_y_2564_33_91_301_5000_290 = load i64, ptr %v_y_2564_33_91_301_5000_290_pointer_295, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_292)
        ret void
}



define ccc void @eraser_299(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_300 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %state_4_4970_296_pointer_301 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_300, i64 0, i32 0
        %state_4_4970_296 = load %Reference, ptr %state_4_4970_296_pointer_301, !noalias !2
        %p_2_212_5152_297_pointer_302 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_300, i64 0, i32 1
        %p_2_212_5152_297 = load %Prompt, ptr %p_2_212_5152_297_pointer_302, !noalias !2
        %v_y_2564_33_91_301_5000_298_pointer_303 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_300, i64 0, i32 2
        %v_y_2564_33_91_301_5000_298 = load i64, ptr %v_y_2564_33_91_301_5000_298_pointer_303, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_300)
        ret void
}



define tailcc void @returnAddress_135(%Pos %v_r_2554_4_35_122_332_4963, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_136 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 64)
        %v_y_2563_32_90_300_5006_pointer_137 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_136, i64 0, i32 0
        %v_y_2563_32_90_300_5006 = load %Pos, ptr %v_y_2563_32_90_300_5006_pointer_137, !noalias !2
        %state_4_4970_pointer_138 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_136, i64 0, i32 1
        %state_4_4970 = load %Reference, ptr %state_4_4970_pointer_138, !noalias !2
        %v_y_2565_34_92_302_5148_pointer_139 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_136, i64 0, i32 2
        %v_y_2565_34_92_302_5148 = load %Pos, ptr %v_y_2565_34_92_302_5148_pointer_139, !noalias !2
        %p_2_212_5152_pointer_140 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_136, i64 0, i32 3
        %p_2_212_5152 = load %Prompt, ptr %p_2_212_5152_pointer_140, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_141 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_136, i64 0, i32 4
        %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_141, !noalias !2
        %stackPointer_304 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %state_4_4970_pointer_305 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_304, i64 0, i32 0
        store %Reference %state_4_4970, ptr %state_4_4970_pointer_305, !noalias !2
        %p_2_212_5152_pointer_306 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_304, i64 0, i32 1
        store %Prompt %p_2_212_5152, ptr %p_2_212_5152_pointer_306, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_307 = getelementptr <{%Reference, %Prompt, i64}>, %StackPointer %stackPointer_304, i64 0, i32 2
        store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_307, !noalias !2
        %returnAddress_pointer_308 = getelementptr <{<{%Reference, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_304, i64 0, i32 1, i32 0
        %sharer_pointer_309 = getelementptr <{<{%Reference, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_304, i64 0, i32 1, i32 1
        %eraser_pointer_310 = getelementptr <{<{%Reference, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_304, i64 0, i32 1, i32 2
        store ptr @returnAddress_142, ptr %returnAddress_pointer_308, !noalias !2
        store ptr @sharer_291, ptr %sharer_pointer_309, !noalias !2
        store ptr @eraser_299, ptr %eraser_pointer_310, !noalias !2
        
        %tag_311 = extractvalue %Pos %v_r_2554_4_35_122_332_4963, 0
        %fields_312 = extractvalue %Pos %v_r_2554_4_35_122_332_4963, 1
        switch i64 %tag_311, label %label_313 [i64 0, label %label_317 i64 1, label %label_321]
    
    label_313:
        
        ret void
    
    label_317:
        call ccc void @erasePositive(%Pos %v_y_2563_32_90_300_5006)
        
        %stackPointer_315 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_316 = getelementptr %FrameHeader, %StackPointer %stackPointer_315, i64 0, i32 0
        %returnAddress_314 = load %ReturnAddress, ptr %returnAddress_pointer_316, !noalias !2
        musttail call tailcc void %returnAddress_314(%Pos %v_y_2565_34_92_302_5148, %Stack %stack)
        ret void
    
    label_321:
        call ccc void @erasePositive(%Pos %v_y_2565_34_92_302_5148)
        
        %stackPointer_319 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_320 = getelementptr %FrameHeader, %StackPointer %stackPointer_319, i64 0, i32 0
        %returnAddress_318 = load %ReturnAddress, ptr %returnAddress_pointer_320, !noalias !2
        musttail call tailcc void %returnAddress_318(%Pos %v_y_2563_32_90_300_5006, %Stack %stack)
        ret void
}



define ccc void @sharer_327(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_328 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %v_y_2563_32_90_300_5006_322_pointer_329 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_328, i64 0, i32 0
        %v_y_2563_32_90_300_5006_322 = load %Pos, ptr %v_y_2563_32_90_300_5006_322_pointer_329, !noalias !2
        %state_4_4970_323_pointer_330 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_328, i64 0, i32 1
        %state_4_4970_323 = load %Reference, ptr %state_4_4970_323_pointer_330, !noalias !2
        %v_y_2565_34_92_302_5148_324_pointer_331 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_328, i64 0, i32 2
        %v_y_2565_34_92_302_5148_324 = load %Pos, ptr %v_y_2565_34_92_302_5148_324_pointer_331, !noalias !2
        %p_2_212_5152_325_pointer_332 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_328, i64 0, i32 3
        %p_2_212_5152_325 = load %Prompt, ptr %p_2_212_5152_325_pointer_332, !noalias !2
        %v_y_2564_33_91_301_5000_326_pointer_333 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_328, i64 0, i32 4
        %v_y_2564_33_91_301_5000_326 = load i64, ptr %v_y_2564_33_91_301_5000_326_pointer_333, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2563_32_90_300_5006_322)
        call ccc void @sharePositive(%Pos %v_y_2565_34_92_302_5148_324)
        call ccc void @shareFrames(%StackPointer %stackPointer_328)
        ret void
}



define ccc void @eraser_339(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_340 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %v_y_2563_32_90_300_5006_334_pointer_341 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_340, i64 0, i32 0
        %v_y_2563_32_90_300_5006_334 = load %Pos, ptr %v_y_2563_32_90_300_5006_334_pointer_341, !noalias !2
        %state_4_4970_335_pointer_342 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_340, i64 0, i32 1
        %state_4_4970_335 = load %Reference, ptr %state_4_4970_335_pointer_342, !noalias !2
        %v_y_2565_34_92_302_5148_336_pointer_343 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_340, i64 0, i32 2
        %v_y_2565_34_92_302_5148_336 = load %Pos, ptr %v_y_2565_34_92_302_5148_336_pointer_343, !noalias !2
        %p_2_212_5152_337_pointer_344 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_340, i64 0, i32 3
        %p_2_212_5152_337 = load %Prompt, ptr %p_2_212_5152_337_pointer_344, !noalias !2
        %v_y_2564_33_91_301_5000_338_pointer_345 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_340, i64 0, i32 4
        %v_y_2564_33_91_301_5000_338 = load i64, ptr %v_y_2564_33_91_301_5000_338_pointer_345, !noalias !2
        call ccc void @erasePositive(%Pos %v_y_2563_32_90_300_5006_334)
        call ccc void @erasePositive(%Pos %v_y_2565_34_92_302_5148_336)
        call ccc void @eraseFrames(%StackPointer %stackPointer_340)
        ret void
}



define tailcc void @returnAddress_364(%Pos %v_r_2990_26_29_121_331_5020, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_365 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_r_2573_6_98_308_5209_pointer_366 = getelementptr <{%Pos}>, %StackPointer %stackPointer_365, i64 0, i32 0
        %v_r_2573_6_98_308_5209 = load %Pos, ptr %v_r_2573_6_98_308_5209_pointer_366, !noalias !2
        
        
        
        
        musttail call tailcc void @reverseOnto_1019(%Pos %v_r_2990_26_29_121_331_5020, %Pos %v_r_2573_6_98_308_5209, %Stack %stack)
        ret void
}



define ccc void @sharer_368(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_369 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2573_6_98_308_5209_367_pointer_370 = getelementptr <{%Pos}>, %StackPointer %stackPointer_369, i64 0, i32 0
        %v_r_2573_6_98_308_5209_367 = load %Pos, ptr %v_r_2573_6_98_308_5209_367_pointer_370, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2573_6_98_308_5209_367)
        call ccc void @shareFrames(%StackPointer %stackPointer_369)
        ret void
}



define ccc void @eraser_372(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_373 = getelementptr <{%Pos}>, %StackPointer %stackPointer, i64 -1
        %v_r_2573_6_98_308_5209_371_pointer_374 = getelementptr <{%Pos}>, %StackPointer %stackPointer_373, i64 0, i32 0
        %v_r_2573_6_98_308_5209_371 = load %Pos, ptr %v_r_2573_6_98_308_5209_371_pointer_374, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2573_6_98_308_5209_371)
        call ccc void @eraseFrames(%StackPointer %stackPointer_373)
        ret void
}



define tailcc void @returnAddress_380(%Pos %returnValue_381, %Stack %stack) {
        
    entry:
        
        %stackPointer_382 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %tmp_5432_pointer_383 = getelementptr <{%Pos}>, %StackPointer %stackPointer_382, i64 0, i32 0
        %tmp_5432 = load %Pos, ptr %tmp_5432_pointer_383, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5432)
        %stackPointer_385 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_386 = getelementptr %FrameHeader, %StackPointer %stackPointer_385, i64 0, i32 0
        %returnAddress_384 = load %ReturnAddress, ptr %returnAddress_pointer_386, !noalias !2
        musttail call tailcc void %returnAddress_384(%Pos %returnValue_381, %Stack %stack)
        ret void
}



define ccc void @eraser_414(%Environment %environment) {
        
    entry:
        
        %v_y_2855_12_19_20_23_115_325_5151_412_pointer_415 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %v_y_2855_12_19_20_23_115_325_5151_412 = load %Pos, ptr %v_y_2855_12_19_20_23_115_325_5151_412_pointer_415, !noalias !2
        %v_r_2978_2_21_22_25_117_327_5282_413_pointer_416 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %v_r_2978_2_21_22_25_117_327_5282_413 = load %Pos, ptr %v_r_2978_2_21_22_25_117_327_5282_413_pointer_416, !noalias !2
        call ccc void @erasePositive(%Pos %v_y_2855_12_19_20_23_115_325_5151_412)
        call ccc void @erasePositive(%Pos %v_r_2978_2_21_22_25_117_327_5282_413)
        ret void
}



define tailcc void @returnAddress_420(%Pos %__3_14_23_24_27_119_329_5309, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_421 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_y_2856_13_20_21_24_116_326_5051_pointer_422 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_421, i64 0, i32 0
        %v_y_2856_13_20_21_24_116_326_5051 = load %Pos, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_422, !noalias !2
        %res_5_6_9_101_311_5109_pointer_423 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_421, i64 0, i32 1
        %res_5_6_9_101_311_5109 = load %Reference, ptr %res_5_6_9_101_311_5109_pointer_423, !noalias !2
        call ccc void @erasePositive(%Pos %__3_14_23_24_27_119_329_5309)
        
        
        
        musttail call tailcc void @foreach_worker_5_10_11_14_106_316_5235(%Pos %v_y_2856_13_20_21_24_116_326_5051, %Reference %res_5_6_9_101_311_5109, %Stack %stack)
        ret void
}



define ccc void @sharer_426(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_427 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_y_2856_13_20_21_24_116_326_5051_424_pointer_428 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_427, i64 0, i32 0
        %v_y_2856_13_20_21_24_116_326_5051_424 = load %Pos, ptr %v_y_2856_13_20_21_24_116_326_5051_424_pointer_428, !noalias !2
        %res_5_6_9_101_311_5109_425_pointer_429 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_427, i64 0, i32 1
        %res_5_6_9_101_311_5109_425 = load %Reference, ptr %res_5_6_9_101_311_5109_425_pointer_429, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2856_13_20_21_24_116_326_5051_424)
        call ccc void @shareFrames(%StackPointer %stackPointer_427)
        ret void
}



define ccc void @eraser_432(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_433 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_y_2856_13_20_21_24_116_326_5051_430_pointer_434 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_433, i64 0, i32 0
        %v_y_2856_13_20_21_24_116_326_5051_430 = load %Pos, ptr %v_y_2856_13_20_21_24_116_326_5051_430_pointer_434, !noalias !2
        %res_5_6_9_101_311_5109_431_pointer_435 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_433, i64 0, i32 1
        %res_5_6_9_101_311_5109_431 = load %Reference, ptr %res_5_6_9_101_311_5109_431_pointer_435, !noalias !2
        call ccc void @erasePositive(%Pos %v_y_2856_13_20_21_24_116_326_5051_430)
        call ccc void @eraseFrames(%StackPointer %stackPointer_433)
        ret void
}



define tailcc void @returnAddress_405(%Pos %v_r_2978_2_21_22_25_117_327_5282, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_406 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %v_y_2855_12_19_20_23_115_325_5151_pointer_407 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_406, i64 0, i32 0
        %v_y_2855_12_19_20_23_115_325_5151 = load %Pos, ptr %v_y_2855_12_19_20_23_115_325_5151_pointer_407, !noalias !2
        %v_y_2856_13_20_21_24_116_326_5051_pointer_408 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_406, i64 0, i32 1
        %v_y_2856_13_20_21_24_116_326_5051 = load %Pos, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_408, !noalias !2
        %res_5_6_9_101_311_5109_pointer_409 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_406, i64 0, i32 2
        %res_5_6_9_101_311_5109 = load %Reference, ptr %res_5_6_9_101_311_5109_pointer_409, !noalias !2
        
        %fields_410 = call ccc %Object @newObject(ptr @eraser_414, i64 32)
        %environment_411 = call ccc %Environment @objectEnvironment(%Object %fields_410)
        %v_y_2855_12_19_20_23_115_325_5151_pointer_417 = getelementptr <{%Pos, %Pos}>, %Environment %environment_411, i64 0, i32 0
        store %Pos %v_y_2855_12_19_20_23_115_325_5151, ptr %v_y_2855_12_19_20_23_115_325_5151_pointer_417, !noalias !2
        %v_r_2978_2_21_22_25_117_327_5282_pointer_418 = getelementptr <{%Pos, %Pos}>, %Environment %environment_411, i64 0, i32 1
        store %Pos %v_r_2978_2_21_22_25_117_327_5282, ptr %v_r_2978_2_21_22_25_117_327_5282_pointer_418, !noalias !2
        %make_5523_temporary_419 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5523 = insertvalue %Pos %make_5523_temporary_419, %Object %fields_410, 1
        
        
        %stackPointer_436 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_y_2856_13_20_21_24_116_326_5051_pointer_437 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_436, i64 0, i32 0
        store %Pos %v_y_2856_13_20_21_24_116_326_5051, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_437, !noalias !2
        %res_5_6_9_101_311_5109_pointer_438 = getelementptr <{%Pos, %Reference}>, %StackPointer %stackPointer_436, i64 0, i32 1
        store %Reference %res_5_6_9_101_311_5109, ptr %res_5_6_9_101_311_5109_pointer_438, !noalias !2
        %returnAddress_pointer_439 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_436, i64 0, i32 1, i32 0
        %sharer_pointer_440 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_436, i64 0, i32 1, i32 1
        %eraser_pointer_441 = getelementptr <{<{%Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_436, i64 0, i32 1, i32 2
        store ptr @returnAddress_420, ptr %returnAddress_pointer_439, !noalias !2
        store ptr @sharer_426, ptr %sharer_pointer_440, !noalias !2
        store ptr @eraser_432, ptr %eraser_pointer_441, !noalias !2
        
        %res_5_6_9_101_311_5109pointer_442 = call ccc ptr @getVarPointer(%Reference %res_5_6_9_101_311_5109, %Stack %stack)
        %res_5_6_9_101_311_5109_old_443 = load %Pos, ptr %res_5_6_9_101_311_5109pointer_442, !noalias !2
        call ccc void @erasePositive(%Pos %res_5_6_9_101_311_5109_old_443)
        store %Pos %make_5523, ptr %res_5_6_9_101_311_5109pointer_442, !noalias !2
        
        %put_5524_temporary_444 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5524 = insertvalue %Pos %put_5524_temporary_444, %Object null, 1
        
        %stackPointer_446 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_447 = getelementptr %FrameHeader, %StackPointer %stackPointer_446, i64 0, i32 0
        %returnAddress_445 = load %ReturnAddress, ptr %returnAddress_pointer_447, !noalias !2
        musttail call tailcc void %returnAddress_445(%Pos %put_5524, %Stack %stack)
        ret void
}



define ccc void @sharer_451(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_452 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_y_2855_12_19_20_23_115_325_5151_448_pointer_453 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_452, i64 0, i32 0
        %v_y_2855_12_19_20_23_115_325_5151_448 = load %Pos, ptr %v_y_2855_12_19_20_23_115_325_5151_448_pointer_453, !noalias !2
        %v_y_2856_13_20_21_24_116_326_5051_449_pointer_454 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_452, i64 0, i32 1
        %v_y_2856_13_20_21_24_116_326_5051_449 = load %Pos, ptr %v_y_2856_13_20_21_24_116_326_5051_449_pointer_454, !noalias !2
        %res_5_6_9_101_311_5109_450_pointer_455 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_452, i64 0, i32 2
        %res_5_6_9_101_311_5109_450 = load %Reference, ptr %res_5_6_9_101_311_5109_450_pointer_455, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2855_12_19_20_23_115_325_5151_448)
        call ccc void @sharePositive(%Pos %v_y_2856_13_20_21_24_116_326_5051_449)
        call ccc void @shareFrames(%StackPointer %stackPointer_452)
        ret void
}



define ccc void @eraser_459(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_460 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer, i64 -1
        %v_y_2855_12_19_20_23_115_325_5151_456_pointer_461 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_460, i64 0, i32 0
        %v_y_2855_12_19_20_23_115_325_5151_456 = load %Pos, ptr %v_y_2855_12_19_20_23_115_325_5151_456_pointer_461, !noalias !2
        %v_y_2856_13_20_21_24_116_326_5051_457_pointer_462 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_460, i64 0, i32 1
        %v_y_2856_13_20_21_24_116_326_5051_457 = load %Pos, ptr %v_y_2856_13_20_21_24_116_326_5051_457_pointer_462, !noalias !2
        %res_5_6_9_101_311_5109_458_pointer_463 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_460, i64 0, i32 2
        %res_5_6_9_101_311_5109_458 = load %Reference, ptr %res_5_6_9_101_311_5109_458_pointer_463, !noalias !2
        call ccc void @erasePositive(%Pos %v_y_2855_12_19_20_23_115_325_5151_456)
        call ccc void @erasePositive(%Pos %v_y_2856_13_20_21_24_116_326_5051_457)
        call ccc void @eraseFrames(%StackPointer %stackPointer_460)
        ret void
}



define tailcc void @foreach_worker_5_10_11_14_106_316_5235(%Pos %l_6_11_12_15_107_317_5039, %Reference %res_5_6_9_101_311_5109, %Stack %stack) {
        
    entry:
        
        
        %tag_394 = extractvalue %Pos %l_6_11_12_15_107_317_5039, 0
        %fields_395 = extractvalue %Pos %l_6_11_12_15_107_317_5039, 1
        switch i64 %tag_394, label %label_396 [i64 0, label %label_401 i64 1, label %label_476]
    
    label_396:
        
        ret void
    
    label_401:
        
        %unitLiteral_5522_temporary_397 = insertvalue %Pos zeroinitializer, i64 0, 0
        %unitLiteral_5522 = insertvalue %Pos %unitLiteral_5522_temporary_397, %Object null, 1
        
        %stackPointer_399 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_400 = getelementptr %FrameHeader, %StackPointer %stackPointer_399, i64 0, i32 0
        %returnAddress_398 = load %ReturnAddress, ptr %returnAddress_pointer_400, !noalias !2
        musttail call tailcc void %returnAddress_398(%Pos %unitLiteral_5522, %Stack %stack)
        ret void
    
    label_476:
        %environment_402 = call ccc %Environment @objectEnvironment(%Object %fields_395)
        %v_y_2855_12_19_20_23_115_325_5151_pointer_403 = getelementptr <{%Pos, %Pos}>, %Environment %environment_402, i64 0, i32 0
        %v_y_2855_12_19_20_23_115_325_5151 = load %Pos, ptr %v_y_2855_12_19_20_23_115_325_5151_pointer_403, !noalias !2
        %v_y_2856_13_20_21_24_116_326_5051_pointer_404 = getelementptr <{%Pos, %Pos}>, %Environment %environment_402, i64 0, i32 1
        %v_y_2856_13_20_21_24_116_326_5051 = load %Pos, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_404, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2855_12_19_20_23_115_325_5151)
        call ccc void @sharePositive(%Pos %v_y_2856_13_20_21_24_116_326_5051)
        call ccc void @eraseObject(%Object %fields_395)
        %stackPointer_464 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %v_y_2855_12_19_20_23_115_325_5151_pointer_465 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_464, i64 0, i32 0
        store %Pos %v_y_2855_12_19_20_23_115_325_5151, ptr %v_y_2855_12_19_20_23_115_325_5151_pointer_465, !noalias !2
        %v_y_2856_13_20_21_24_116_326_5051_pointer_466 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_464, i64 0, i32 1
        store %Pos %v_y_2856_13_20_21_24_116_326_5051, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_466, !noalias !2
        %res_5_6_9_101_311_5109_pointer_467 = getelementptr <{%Pos, %Pos, %Reference}>, %StackPointer %stackPointer_464, i64 0, i32 2
        store %Reference %res_5_6_9_101_311_5109, ptr %res_5_6_9_101_311_5109_pointer_467, !noalias !2
        %returnAddress_pointer_468 = getelementptr <{<{%Pos, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_464, i64 0, i32 1, i32 0
        %sharer_pointer_469 = getelementptr <{<{%Pos, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_464, i64 0, i32 1, i32 1
        %eraser_pointer_470 = getelementptr <{<{%Pos, %Pos, %Reference}>, %FrameHeader}>, %StackPointer %stackPointer_464, i64 0, i32 1, i32 2
        store ptr @returnAddress_405, ptr %returnAddress_pointer_468, !noalias !2
        store ptr @sharer_451, ptr %sharer_pointer_469, !noalias !2
        store ptr @eraser_459, ptr %eraser_pointer_470, !noalias !2
        
        %get_5525_pointer_471 = call ccc ptr @getVarPointer(%Reference %res_5_6_9_101_311_5109, %Stack %stack)
        %res_5_6_9_101_311_5109_old_472 = load %Pos, ptr %get_5525_pointer_471, !noalias !2
        call ccc void @sharePositive(%Pos %res_5_6_9_101_311_5109_old_472)
        %get_5525 = load %Pos, ptr %get_5525_pointer_471, !noalias !2
        
        %stackPointer_474 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_475 = getelementptr %FrameHeader, %StackPointer %stackPointer_474, i64 0, i32 0
        %returnAddress_473 = load %ReturnAddress, ptr %returnAddress_pointer_475, !noalias !2
        musttail call tailcc void %returnAddress_473(%Pos %get_5525, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_477(%Pos %__24_25_28_120_330_5310, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_478 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %res_5_6_9_101_311_5109_pointer_479 = getelementptr <{%Reference}>, %StackPointer %stackPointer_478, i64 0, i32 0
        %res_5_6_9_101_311_5109 = load %Reference, ptr %res_5_6_9_101_311_5109_pointer_479, !noalias !2
        call ccc void @erasePositive(%Pos %__24_25_28_120_330_5310)
        
        %get_5526_pointer_480 = call ccc ptr @getVarPointer(%Reference %res_5_6_9_101_311_5109, %Stack %stack)
        %res_5_6_9_101_311_5109_old_481 = load %Pos, ptr %get_5526_pointer_480, !noalias !2
        call ccc void @sharePositive(%Pos %res_5_6_9_101_311_5109_old_481)
        %get_5526 = load %Pos, ptr %get_5526_pointer_480, !noalias !2
        
        %stackPointer_483 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_484 = getelementptr %FrameHeader, %StackPointer %stackPointer_483, i64 0, i32 0
        %returnAddress_482 = load %ReturnAddress, ptr %returnAddress_pointer_484, !noalias !2
        musttail call tailcc void %returnAddress_482(%Pos %get_5526, %Stack %stack)
        ret void
}



define ccc void @sharer_486(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_487 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %res_5_6_9_101_311_5109_485_pointer_488 = getelementptr <{%Reference}>, %StackPointer %stackPointer_487, i64 0, i32 0
        %res_5_6_9_101_311_5109_485 = load %Reference, ptr %res_5_6_9_101_311_5109_485_pointer_488, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_487)
        ret void
}



define ccc void @eraser_490(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_491 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %res_5_6_9_101_311_5109_489_pointer_492 = getelementptr <{%Reference}>, %StackPointer %stackPointer_491, i64 0, i32 0
        %res_5_6_9_101_311_5109_489 = load %Reference, ptr %res_5_6_9_101_311_5109_489_pointer_492, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_491)
        ret void
}



define tailcc void @returnAddress_360(%Pos %v_r_2573_6_98_308_5209, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_361 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %v_r_2572_5_97_307_5127_pointer_362 = getelementptr <{%Pos}>, %StackPointer %stackPointer_361, i64 0, i32 0
        %v_r_2572_5_97_307_5127 = load %Pos, ptr %v_r_2572_5_97_307_5127_pointer_362, !noalias !2
        
        %make_5520_temporary_363 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5520 = insertvalue %Pos %make_5520_temporary_363, %Object null, 1
        
        
        %stackPointer_375 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %v_r_2573_6_98_308_5209_pointer_376 = getelementptr <{%Pos}>, %StackPointer %stackPointer_375, i64 0, i32 0
        store %Pos %v_r_2573_6_98_308_5209, ptr %v_r_2573_6_98_308_5209_pointer_376, !noalias !2
        %returnAddress_pointer_377 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_375, i64 0, i32 1, i32 0
        %sharer_pointer_378 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_375, i64 0, i32 1, i32 1
        %eraser_pointer_379 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_375, i64 0, i32 1, i32 2
        store ptr @returnAddress_364, ptr %returnAddress_pointer_377, !noalias !2
        store ptr @sharer_368, ptr %sharer_pointer_378, !noalias !2
        store ptr @eraser_372, ptr %eraser_pointer_379, !noalias !2
        %res_5_6_9_101_311_5109 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_389 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %tmp_5432_pointer_390 = getelementptr <{%Pos}>, %StackPointer %stackPointer_389, i64 0, i32 0
        store %Pos %make_5520, ptr %tmp_5432_pointer_390, !noalias !2
        %returnAddress_pointer_391 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_389, i64 0, i32 1, i32 0
        %sharer_pointer_392 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_389, i64 0, i32 1, i32 1
        %eraser_pointer_393 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_389, i64 0, i32 1, i32 2
        store ptr @returnAddress_380, ptr %returnAddress_pointer_391, !noalias !2
        store ptr @sharer_368, ptr %sharer_pointer_392, !noalias !2
        store ptr @eraser_372, ptr %eraser_pointer_393, !noalias !2
        %stackPointer_493 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %res_5_6_9_101_311_5109_pointer_494 = getelementptr <{%Reference}>, %StackPointer %stackPointer_493, i64 0, i32 0
        store %Reference %res_5_6_9_101_311_5109, ptr %res_5_6_9_101_311_5109_pointer_494, !noalias !2
        %returnAddress_pointer_495 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_493, i64 0, i32 1, i32 0
        %sharer_pointer_496 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_493, i64 0, i32 1, i32 1
        %eraser_pointer_497 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_493, i64 0, i32 1, i32 2
        store ptr @returnAddress_477, ptr %returnAddress_pointer_495, !noalias !2
        store ptr @sharer_486, ptr %sharer_pointer_496, !noalias !2
        store ptr @eraser_490, ptr %eraser_pointer_497, !noalias !2
        
        
        
        musttail call tailcc void @foreach_worker_5_10_11_14_106_316_5235(%Pos %v_r_2572_5_97_307_5127, %Reference %res_5_6_9_101_311_5109, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_357(%Pos %v_r_2572_5_97_307_5127, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_358 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %k_2_94_304_5007_pointer_359 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_358, i64 0, i32 0
        %k_2_94_304_5007 = load %Resumption, ptr %k_2_94_304_5007_pointer_359, !noalias !2
        %stackPointer_500 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %v_r_2572_5_97_307_5127_pointer_501 = getelementptr <{%Pos}>, %StackPointer %stackPointer_500, i64 0, i32 0
        store %Pos %v_r_2572_5_97_307_5127, ptr %v_r_2572_5_97_307_5127_pointer_501, !noalias !2
        %returnAddress_pointer_502 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_500, i64 0, i32 1, i32 0
        %sharer_pointer_503 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_500, i64 0, i32 1, i32 1
        %eraser_pointer_504 = getelementptr <{<{%Pos}>, %FrameHeader}>, %StackPointer %stackPointer_500, i64 0, i32 1, i32 2
        store ptr @returnAddress_360, ptr %returnAddress_pointer_502, !noalias !2
        store ptr @sharer_368, ptr %sharer_pointer_503, !noalias !2
        store ptr @eraser_372, ptr %eraser_pointer_504, !noalias !2
        
        %stack_505 = call ccc %Stack @resume(%Resumption %k_2_94_304_5007, %Stack %stack)
        
        %booleanLiteral_5527_temporary_506 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_5527 = insertvalue %Pos %booleanLiteral_5527_temporary_506, %Object null, 1
        
        %stackPointer_508 = call ccc %StackPointer @stackDeallocate(%Stack %stack_505, i64 24)
        %returnAddress_pointer_509 = getelementptr %FrameHeader, %StackPointer %stackPointer_508, i64 0, i32 0
        %returnAddress_507 = load %ReturnAddress, ptr %returnAddress_pointer_509, !noalias !2
        musttail call tailcc void %returnAddress_507(%Pos %booleanLiteral_5527, %Stack %stack_505)
        ret void
}



define ccc void @sharer_511(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_512 = getelementptr <{%Resumption}>, %StackPointer %stackPointer, i64 -1
        %k_2_94_304_5007_510_pointer_513 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_512, i64 0, i32 0
        %k_2_94_304_5007_510 = load %Resumption, ptr %k_2_94_304_5007_510_pointer_513, !noalias !2
        call ccc void @shareResumption(%Resumption %k_2_94_304_5007_510)
        call ccc void @shareFrames(%StackPointer %stackPointer_512)
        ret void
}



define ccc void @eraser_515(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_516 = getelementptr <{%Resumption}>, %StackPointer %stackPointer, i64 -1
        %k_2_94_304_5007_514_pointer_517 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_516, i64 0, i32 0
        %k_2_94_304_5007_514 = load %Resumption, ptr %k_2_94_304_5007_514_pointer_517, !noalias !2
        call ccc void @eraseResumption(%Resumption %k_2_94_304_5007_514)
        call ccc void @eraseFrames(%StackPointer %stackPointer_516)
        ret void
}



define tailcc void @explore_worker_4_33_243_4974(%Pos %t_5_34_244_5104, %Reference %state_4_4970, %Prompt %p_2_212_5152, %Stack %stack) {
        
    entry:
        
        
        %tag_122 = extractvalue %Pos %t_5_34_244_5104, 0
        %fields_123 = extractvalue %Pos %t_5_34_244_5104, 1
        switch i64 %tag_122, label %label_124 [i64 0, label %label_130 i64 1, label %label_528]
    
    label_124:
        
        ret void
    
    label_130:
        
        %get_5495_pointer_125 = call ccc ptr @getVarPointer(%Reference %state_4_4970, %Stack %stack)
        %state_4_4970_old_126 = load i64, ptr %get_5495_pointer_125, !noalias !2
        %get_5495 = load i64, ptr %get_5495_pointer_125, !noalias !2
        
        %stackPointer_128 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_129 = getelementptr %FrameHeader, %StackPointer %stackPointer_128, i64 0, i32 0
        %returnAddress_127 = load %ReturnAddress, ptr %returnAddress_pointer_129, !noalias !2
        musttail call tailcc void %returnAddress_127(i64 %get_5495, %Stack %stack)
        ret void
    
    label_528:
        %environment_131 = call ccc %Environment @objectEnvironment(%Object %fields_123)
        %v_y_2563_32_90_300_5006_pointer_132 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_131, i64 0, i32 0
        %v_y_2563_32_90_300_5006 = load %Pos, ptr %v_y_2563_32_90_300_5006_pointer_132, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_133 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_131, i64 0, i32 1
        %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_133, !noalias !2
        %v_y_2565_34_92_302_5148_pointer_134 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_131, i64 0, i32 2
        %v_y_2565_34_92_302_5148 = load %Pos, ptr %v_y_2565_34_92_302_5148_pointer_134, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2563_32_90_300_5006)
        call ccc void @sharePositive(%Pos %v_y_2565_34_92_302_5148)
        call ccc void @eraseObject(%Object %fields_123)
        %stackPointer_346 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 88)
        %v_y_2563_32_90_300_5006_pointer_347 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_346, i64 0, i32 0
        store %Pos %v_y_2563_32_90_300_5006, ptr %v_y_2563_32_90_300_5006_pointer_347, !noalias !2
        %state_4_4970_pointer_348 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_346, i64 0, i32 1
        store %Reference %state_4_4970, ptr %state_4_4970_pointer_348, !noalias !2
        %v_y_2565_34_92_302_5148_pointer_349 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_346, i64 0, i32 2
        store %Pos %v_y_2565_34_92_302_5148, ptr %v_y_2565_34_92_302_5148_pointer_349, !noalias !2
        %p_2_212_5152_pointer_350 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_346, i64 0, i32 3
        store %Prompt %p_2_212_5152, ptr %p_2_212_5152_pointer_350, !noalias !2
        %v_y_2564_33_91_301_5000_pointer_351 = getelementptr <{%Pos, %Reference, %Pos, %Prompt, i64}>, %StackPointer %stackPointer_346, i64 0, i32 4
        store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_351, !noalias !2
        %returnAddress_pointer_352 = getelementptr <{<{%Pos, %Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_346, i64 0, i32 1, i32 0
        %sharer_pointer_353 = getelementptr <{<{%Pos, %Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_346, i64 0, i32 1, i32 1
        %eraser_pointer_354 = getelementptr <{<{%Pos, %Reference, %Pos, %Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_346, i64 0, i32 1, i32 2
        store ptr @returnAddress_135, ptr %returnAddress_pointer_352, !noalias !2
        store ptr @sharer_327, ptr %sharer_pointer_353, !noalias !2
        store ptr @eraser_339, ptr %eraser_pointer_354, !noalias !2
        
        %pair_355 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_2_212_5152)
        %k_2_94_304_5007 = extractvalue <{%Resumption, %Stack}> %pair_355, 0
        %stack_356 = extractvalue <{%Resumption, %Stack}> %pair_355, 1
        call ccc void @shareResumption(%Resumption %k_2_94_304_5007)
        %stackPointer_518 = call ccc %StackPointer @stackAllocate(%Stack %stack_356, i64 32)
        %k_2_94_304_5007_pointer_519 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_518, i64 0, i32 0
        store %Resumption %k_2_94_304_5007, ptr %k_2_94_304_5007_pointer_519, !noalias !2
        %returnAddress_pointer_520 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_518, i64 0, i32 1, i32 0
        %sharer_pointer_521 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_518, i64 0, i32 1, i32 1
        %eraser_pointer_522 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_518, i64 0, i32 1, i32 2
        store ptr @returnAddress_357, ptr %returnAddress_pointer_520, !noalias !2
        store ptr @sharer_511, ptr %sharer_pointer_521, !noalias !2
        store ptr @eraser_515, ptr %eraser_pointer_522, !noalias !2
        
        %stack_523 = call ccc %Stack @resume(%Resumption %k_2_94_304_5007, %Stack %stack_356)
        
        %booleanLiteral_5528_temporary_524 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5528 = insertvalue %Pos %booleanLiteral_5528_temporary_524, %Object null, 1
        
        %stackPointer_526 = call ccc %StackPointer @stackDeallocate(%Stack %stack_523, i64 24)
        %returnAddress_pointer_527 = getelementptr %FrameHeader, %StackPointer %stackPointer_526, i64 0, i32 0
        %returnAddress_525 = load %ReturnAddress, ptr %returnAddress_pointer_527, !noalias !2
        musttail call tailcc void %returnAddress_525(%Pos %booleanLiteral_5528, %Stack %stack_523)
        ret void
}



define tailcc void @returnAddress_529(i64 %v_r_2577_143_353_5098, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5529 = call ccc %Pos @boxInt_301(i64 %v_r_2577_143_353_5098)
        
        
        
        %make_5530_temporary_530 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5530 = insertvalue %Pos %make_5530_temporary_530, %Object null, 1
        
        
        
        %fields_531 = call ccc %Object @newObject(ptr @eraser_414, i64 32)
        %environment_532 = call ccc %Environment @objectEnvironment(%Object %fields_531)
        %tmp_5446_pointer_535 = getelementptr <{%Pos, %Pos}>, %Environment %environment_532, i64 0, i32 0
        store %Pos %pureApp_5529, ptr %tmp_5446_pointer_535, !noalias !2
        %tmp_5447_pointer_536 = getelementptr <{%Pos, %Pos}>, %Environment %environment_532, i64 0, i32 1
        store %Pos %make_5530, ptr %tmp_5447_pointer_536, !noalias !2
        %make_5531_temporary_537 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5531 = insertvalue %Pos %make_5531_temporary_537, %Object %fields_531, 1
        
        
        
        %stackPointer_539 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_540 = getelementptr %FrameHeader, %StackPointer %stackPointer_539, i64 0, i32 0
        %returnAddress_538 = load %ReturnAddress, ptr %returnAddress_pointer_540, !noalias !2
        musttail call tailcc void %returnAddress_538(%Pos %make_5531, %Stack %stack)
        ret void
}



define tailcc void @loop_208_5045(i64 %i_209_5097, %Reference %state_4_4970, %Pos %tree_2_5241, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5490 = add i64 0, 0
        
        %pureApp_5489 = call ccc %Pos @infixEq_72(i64 %i_209_5097, i64 %longLiteral_5490)
        
        
        
        %tag_35 = extractvalue %Pos %pureApp_5489, 0
        %fields_36 = extractvalue %Pos %pureApp_5489, 1
        switch i64 %tag_35, label %label_37 [i64 0, label %label_545 i64 1, label %label_551]
    
    label_37:
        
        ret void
    
    label_545:
        call ccc void @sharePositive(%Pos %tree_2_5241)
        %stackPointer_101 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %i_209_5097_pointer_102 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_101, i64 0, i32 0
        store i64 %i_209_5097, ptr %i_209_5097_pointer_102, !noalias !2
        %state_4_4970_pointer_103 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_101, i64 0, i32 1
        store %Reference %state_4_4970, ptr %state_4_4970_pointer_103, !noalias !2
        %tree_2_5241_pointer_104 = getelementptr <{i64, %Reference, %Pos}>, %StackPointer %stackPointer_101, i64 0, i32 2
        store %Pos %tree_2_5241, ptr %tree_2_5241_pointer_104, !noalias !2
        %returnAddress_pointer_105 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_101, i64 0, i32 1, i32 0
        %sharer_pointer_106 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_101, i64 0, i32 1, i32 1
        %eraser_pointer_107 = getelementptr <{<{i64, %Reference, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_101, i64 0, i32 1, i32 2
        store ptr @returnAddress_38, ptr %returnAddress_pointer_105, !noalias !2
        store ptr @sharer_56, ptr %sharer_pointer_106, !noalias !2
        store ptr @eraser_64, ptr %eraser_pointer_107, !noalias !2
        
        %stack_108 = call ccc %Stack @reset(%Stack %stack)
        %p_2_212_5152 = call ccc %Prompt @currentPrompt(%Stack %stack_108)
        %stackPointer_118 = call ccc %StackPointer @stackAllocate(%Stack %stack_108, i64 24)
        %returnAddress_pointer_119 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_118, i64 0, i32 1, i32 0
        %sharer_pointer_120 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_118, i64 0, i32 1, i32 1
        %eraser_pointer_121 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_118, i64 0, i32 1, i32 2
        store ptr @returnAddress_109, ptr %returnAddress_pointer_119, !noalias !2
        store ptr @sharer_114, ptr %sharer_pointer_120, !noalias !2
        store ptr @eraser_116, ptr %eraser_pointer_121, !noalias !2
        %stackPointer_541 = call ccc %StackPointer @stackAllocate(%Stack %stack_108, i64 24)
        %returnAddress_pointer_542 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_541, i64 0, i32 1, i32 0
        %sharer_pointer_543 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_541, i64 0, i32 1, i32 1
        %eraser_pointer_544 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_541, i64 0, i32 1, i32 2
        store ptr @returnAddress_529, ptr %returnAddress_pointer_542, !noalias !2
        store ptr @sharer_7, ptr %sharer_pointer_543, !noalias !2
        store ptr @eraser_9, ptr %eraser_pointer_544, !noalias !2
        
        
        
        musttail call tailcc void @explore_worker_4_33_243_4974(%Pos %tree_2_5241, %Reference %state_4_4970, %Prompt %p_2_212_5152, %Stack %stack_108)
        ret void
    
    label_551:
        call ccc void @erasePositive(%Pos %tree_2_5241)
        
        %get_5532_pointer_546 = call ccc ptr @getVarPointer(%Reference %state_4_4970, %Stack %stack)
        %state_4_4970_old_547 = load i64, ptr %get_5532_pointer_546, !noalias !2
        %get_5532 = load i64, ptr %get_5532_pointer_546, !noalias !2
        
        %stackPointer_549 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_550 = getelementptr %FrameHeader, %StackPointer %stackPointer_549, i64 0, i32 0
        %returnAddress_548 = load %ReturnAddress, ptr %returnAddress_pointer_550, !noalias !2
        musttail call tailcc void %returnAddress_548(i64 %get_5532, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_2(%Pos %tree_2_5241, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5485 = add i64 0, 0
        
        
        %stackPointer_11 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_11, i64 0, i32 1, i32 0
        %sharer_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_11, i64 0, i32 1, i32 1
        %eraser_pointer_14 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_11, i64 0, i32 1, i32 2
        store ptr @returnAddress_3, ptr %returnAddress_pointer_12, !noalias !2
        store ptr @sharer_7, ptr %sharer_pointer_13, !noalias !2
        store ptr @eraser_9, ptr %eraser_pointer_14, !noalias !2
        %state_4_4970 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_30 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2551_3_5240_pointer_31 = getelementptr <{i64}>, %StackPointer %stackPointer_30, i64 0, i32 0
        store i64 %longLiteral_5485, ptr %v_r_2551_3_5240_pointer_31, !noalias !2
        %returnAddress_pointer_32 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_30, i64 0, i32 1, i32 0
        %sharer_pointer_33 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_30, i64 0, i32 1, i32 1
        %eraser_pointer_34 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_30, i64 0, i32 1, i32 2
        store ptr @returnAddress_15, ptr %returnAddress_pointer_32, !noalias !2
        store ptr @sharer_23, ptr %sharer_pointer_33, !noalias !2
        store ptr @eraser_27, ptr %eraser_pointer_34, !noalias !2
        
        %longLiteral_5533 = add i64 10, 0
        
        
        
        musttail call tailcc void @loop_208_5045(i64 %longLiteral_5533, %Reference %state_4_4970, %Pos %tree_2_5241, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3516_3580, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5484 = call ccc i64 @unboxInt_303(%Pos %v_coe_3516_3580)
        
        
        %stackPointer_552 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_553 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_552, i64 0, i32 1, i32 0
        %sharer_pointer_554 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_552, i64 0, i32 1, i32 1
        %eraser_pointer_555 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_552, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_553, !noalias !2
        store ptr @sharer_7, ptr %sharer_pointer_554, !noalias !2
        store ptr @eraser_9, ptr %eraser_pointer_555, !noalias !2
        
        
        
        musttail call tailcc void @make_2445(i64 %pureApp_5484, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_561(%Pos %returned_5534, %Stack %stack) {
        
    entry:
        
        %stack_562 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_564 = call ccc %StackPointer @stackDeallocate(%Stack %stack_562, i64 24)
        %returnAddress_pointer_565 = getelementptr %FrameHeader, %StackPointer %stackPointer_564, i64 0, i32 0
        %returnAddress_563 = load %ReturnAddress, ptr %returnAddress_pointer_565, !noalias !2
        musttail call tailcc void %returnAddress_563(%Pos %returned_5534, %Stack %stack_562)
        ret void
}



define tailcc void @toList_1_1_3_167_4790(i64 %start_2_2_4_168_4892, %Pos %acc_3_3_5_169_4758, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5536 = add i64 1, 0
        
        %pureApp_5535 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4892, i64 %longLiteral_5536)
        
        
        
        %tag_570 = extractvalue %Pos %pureApp_5535, 0
        %fields_571 = extractvalue %Pos %pureApp_5535, 1
        switch i64 %tag_570, label %label_572 [i64 0, label %label_580 i64 1, label %label_584]
    
    label_572:
        
        ret void
    
    label_580:
        
        %pureApp_5537 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4892)
        
        
        
        %longLiteral_5539 = add i64 1, 0
        
        %pureApp_5538 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4892, i64 %longLiteral_5539)
        
        
        
        %fields_573 = call ccc %Object @newObject(ptr @eraser_414, i64 32)
        %environment_574 = call ccc %Environment @objectEnvironment(%Object %fields_573)
        %tmp_5404_pointer_577 = getelementptr <{%Pos, %Pos}>, %Environment %environment_574, i64 0, i32 0
        store %Pos %pureApp_5537, ptr %tmp_5404_pointer_577, !noalias !2
        %acc_3_3_5_169_4758_pointer_578 = getelementptr <{%Pos, %Pos}>, %Environment %environment_574, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4758, ptr %acc_3_3_5_169_4758_pointer_578, !noalias !2
        %make_5540_temporary_579 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5540 = insertvalue %Pos %make_5540_temporary_579, %Object %fields_573, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4790(i64 %pureApp_5538, %Pos %make_5540, %Stack %stack)
        ret void
    
    label_584:
        
        %stackPointer_582 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_583 = getelementptr %FrameHeader, %StackPointer %stackPointer_582, i64 0, i32 0
        %returnAddress_581 = load %ReturnAddress, ptr %returnAddress_pointer_583, !noalias !2
        musttail call tailcc void %returnAddress_581(%Pos %acc_3_3_5_169_4758, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_595(%Pos %v_r_2672_32_59_223_4718, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_596 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %tmp_5411_pointer_597 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 0
        %tmp_5411 = load i64, ptr %tmp_5411_pointer_597, !noalias !2
        %p_8_9_4581_pointer_598 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 1
        %p_8_9_4581 = load %Prompt, ptr %p_8_9_4581_pointer_598, !noalias !2
        %acc_8_35_199_4876_pointer_599 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 2
        %acc_8_35_199_4876 = load i64, ptr %acc_8_35_199_4876_pointer_599, !noalias !2
        %index_7_34_198_4866_pointer_600 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 3
        %index_7_34_198_4866 = load i64, ptr %index_7_34_198_4866_pointer_600, !noalias !2
        %v_r_2589_30_194_4665_pointer_601 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_596, i64 0, i32 4
        %v_r_2589_30_194_4665 = load %Pos, ptr %v_r_2589_30_194_4665_pointer_601, !noalias !2
        
        %tag_602 = extractvalue %Pos %v_r_2672_32_59_223_4718, 0
        %fields_603 = extractvalue %Pos %v_r_2672_32_59_223_4718, 1
        switch i64 %tag_602, label %label_604 [i64 1, label %label_627 i64 0, label %label_634]
    
    label_604:
        
        ret void
    
    label_609:
        
        ret void
    
    label_615:
        call ccc void @erasePositive(%Pos %v_r_2589_30_194_4665)
        
        %pair_610 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4581)
        %k_13_14_4_5317 = extractvalue <{%Resumption, %Stack}> %pair_610, 0
        %stack_611 = extractvalue <{%Resumption, %Stack}> %pair_610, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5317)
        
        %longLiteral_5552 = add i64 5, 0
        
        
        
        %pureApp_5553 = call ccc %Pos @boxInt_301(i64 %longLiteral_5552)
        
        
        
        %stackPointer_613 = call ccc %StackPointer @stackDeallocate(%Stack %stack_611, i64 24)
        %returnAddress_pointer_614 = getelementptr %FrameHeader, %StackPointer %stackPointer_613, i64 0, i32 0
        %returnAddress_612 = load %ReturnAddress, ptr %returnAddress_pointer_614, !noalias !2
        musttail call tailcc void %returnAddress_612(%Pos %pureApp_5553, %Stack %stack_611)
        ret void
    
    label_618:
        
        ret void
    
    label_624:
        call ccc void @erasePositive(%Pos %v_r_2589_30_194_4665)
        
        %pair_619 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4581)
        %k_13_14_4_5316 = extractvalue <{%Resumption, %Stack}> %pair_619, 0
        %stack_620 = extractvalue <{%Resumption, %Stack}> %pair_619, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5316)
        
        %longLiteral_5556 = add i64 5, 0
        
        
        
        %pureApp_5557 = call ccc %Pos @boxInt_301(i64 %longLiteral_5556)
        
        
        
        %stackPointer_622 = call ccc %StackPointer @stackDeallocate(%Stack %stack_620, i64 24)
        %returnAddress_pointer_623 = getelementptr %FrameHeader, %StackPointer %stackPointer_622, i64 0, i32 0
        %returnAddress_621 = load %ReturnAddress, ptr %returnAddress_pointer_623, !noalias !2
        musttail call tailcc void %returnAddress_621(%Pos %pureApp_5557, %Stack %stack_620)
        ret void
    
    label_625:
        
        %longLiteral_5559 = add i64 1, 0
        
        %pureApp_5558 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4866, i64 %longLiteral_5559)
        
        
        
        %longLiteral_5561 = add i64 10, 0
        
        %pureApp_5560 = call ccc i64 @infixMul_99(i64 %longLiteral_5561, i64 %acc_8_35_199_4876)
        
        
        
        %pureApp_5562 = call ccc i64 @toInt_2085(i64 %pureApp_5549)
        
        
        
        %pureApp_5563 = call ccc i64 @infixSub_105(i64 %pureApp_5562, i64 %tmp_5411)
        
        
        
        %pureApp_5564 = call ccc i64 @infixAdd_96(i64 %pureApp_5560, i64 %pureApp_5563)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4766(i64 %pureApp_5558, i64 %pureApp_5564, %Pos %v_r_2589_30_194_4665, i64 %tmp_5411, %Prompt %p_8_9_4581, %Stack %stack)
        ret void
    
    label_626:
        
        %intLiteral_5555 = add i64 57, 0
        
        %pureApp_5554 = call ccc %Pos @infixLte_2093(i64 %pureApp_5549, i64 %intLiteral_5555)
        
        
        
        %tag_616 = extractvalue %Pos %pureApp_5554, 0
        %fields_617 = extractvalue %Pos %pureApp_5554, 1
        switch i64 %tag_616, label %label_618 [i64 0, label %label_624 i64 1, label %label_625]
    
    label_627:
        %environment_605 = call ccc %Environment @objectEnvironment(%Object %fields_603)
        %v_coe_3488_46_73_237_4803_pointer_606 = getelementptr <{%Pos}>, %Environment %environment_605, i64 0, i32 0
        %v_coe_3488_46_73_237_4803 = load %Pos, ptr %v_coe_3488_46_73_237_4803_pointer_606, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3488_46_73_237_4803)
        call ccc void @eraseObject(%Object %fields_603)
        
        %pureApp_5549 = call ccc i64 @unboxChar_313(%Pos %v_coe_3488_46_73_237_4803)
        
        
        
        %intLiteral_5551 = add i64 48, 0
        
        %pureApp_5550 = call ccc %Pos @infixGte_2099(i64 %pureApp_5549, i64 %intLiteral_5551)
        
        
        
        %tag_607 = extractvalue %Pos %pureApp_5550, 0
        %fields_608 = extractvalue %Pos %pureApp_5550, 1
        switch i64 %tag_607, label %label_609 [i64 0, label %label_615 i64 1, label %label_626]
    
    label_634:
        %environment_628 = call ccc %Environment @objectEnvironment(%Object %fields_603)
        %v_y_2679_76_103_267_5547_pointer_629 = getelementptr <{%Pos, %Pos}>, %Environment %environment_628, i64 0, i32 0
        %v_y_2679_76_103_267_5547 = load %Pos, ptr %v_y_2679_76_103_267_5547_pointer_629, !noalias !2
        %v_y_2680_77_104_268_5548_pointer_630 = getelementptr <{%Pos, %Pos}>, %Environment %environment_628, i64 0, i32 1
        %v_y_2680_77_104_268_5548 = load %Pos, ptr %v_y_2680_77_104_268_5548_pointer_630, !noalias !2
        call ccc void @eraseObject(%Object %fields_603)
        call ccc void @erasePositive(%Pos %v_r_2589_30_194_4665)
        
        %stackPointer_632 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_633 = getelementptr %FrameHeader, %StackPointer %stackPointer_632, i64 0, i32 0
        %returnAddress_631 = load %ReturnAddress, ptr %returnAddress_pointer_633, !noalias !2
        musttail call tailcc void %returnAddress_631(i64 %acc_8_35_199_4876, %Stack %stack)
        ret void
}



define ccc void @sharer_640(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_641 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_5411_635_pointer_642 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_641, i64 0, i32 0
        %tmp_5411_635 = load i64, ptr %tmp_5411_635_pointer_642, !noalias !2
        %p_8_9_4581_636_pointer_643 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_641, i64 0, i32 1
        %p_8_9_4581_636 = load %Prompt, ptr %p_8_9_4581_636_pointer_643, !noalias !2
        %acc_8_35_199_4876_637_pointer_644 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_641, i64 0, i32 2
        %acc_8_35_199_4876_637 = load i64, ptr %acc_8_35_199_4876_637_pointer_644, !noalias !2
        %index_7_34_198_4866_638_pointer_645 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_641, i64 0, i32 3
        %index_7_34_198_4866_638 = load i64, ptr %index_7_34_198_4866_638_pointer_645, !noalias !2
        %v_r_2589_30_194_4665_639_pointer_646 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_641, i64 0, i32 4
        %v_r_2589_30_194_4665_639 = load %Pos, ptr %v_r_2589_30_194_4665_639_pointer_646, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2589_30_194_4665_639)
        call ccc void @shareFrames(%StackPointer %stackPointer_641)
        ret void
}



define ccc void @eraser_652(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_653 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %tmp_5411_647_pointer_654 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_653, i64 0, i32 0
        %tmp_5411_647 = load i64, ptr %tmp_5411_647_pointer_654, !noalias !2
        %p_8_9_4581_648_pointer_655 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_653, i64 0, i32 1
        %p_8_9_4581_648 = load %Prompt, ptr %p_8_9_4581_648_pointer_655, !noalias !2
        %acc_8_35_199_4876_649_pointer_656 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_653, i64 0, i32 2
        %acc_8_35_199_4876_649 = load i64, ptr %acc_8_35_199_4876_649_pointer_656, !noalias !2
        %index_7_34_198_4866_650_pointer_657 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_653, i64 0, i32 3
        %index_7_34_198_4866_650 = load i64, ptr %index_7_34_198_4866_650_pointer_657, !noalias !2
        %v_r_2589_30_194_4665_651_pointer_658 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_653, i64 0, i32 4
        %v_r_2589_30_194_4665_651 = load %Pos, ptr %v_r_2589_30_194_4665_651_pointer_658, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2589_30_194_4665_651)
        call ccc void @eraseFrames(%StackPointer %stackPointer_653)
        ret void
}



define tailcc void @returnAddress_669(%Pos %returned_5565, %Stack %stack) {
        
    entry:
        
        %stack_670 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_672 = call ccc %StackPointer @stackDeallocate(%Stack %stack_670, i64 24)
        %returnAddress_pointer_673 = getelementptr %FrameHeader, %StackPointer %stackPointer_672, i64 0, i32 0
        %returnAddress_671 = load %ReturnAddress, ptr %returnAddress_pointer_673, !noalias !2
        musttail call tailcc void %returnAddress_671(%Pos %returned_5565, %Stack %stack_670)
        ret void
}



define tailcc void @Exception_7_19_46_210_4744_clause_678(%Object %closure, %Pos %exc_8_20_47_211_4681, %Pos %msg_9_21_48_212_4713, %Stack %stack) {
        
    entry:
        
        %environment_679 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4620_pointer_680 = getelementptr <{%Prompt}>, %Environment %environment_679, i64 0, i32 0
        %p_6_18_45_209_4620 = load %Prompt, ptr %p_6_18_45_209_4620_pointer_680, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_681 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4620)
        %k_11_23_50_214_4903 = extractvalue <{%Resumption, %Stack}> %pair_681, 0
        %stack_682 = extractvalue <{%Resumption, %Stack}> %pair_681, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4903)
        
        %fields_683 = call ccc %Object @newObject(ptr @eraser_414, i64 32)
        %environment_684 = call ccc %Environment @objectEnvironment(%Object %fields_683)
        %exc_8_20_47_211_4681_pointer_687 = getelementptr <{%Pos, %Pos}>, %Environment %environment_684, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4681, ptr %exc_8_20_47_211_4681_pointer_687, !noalias !2
        %msg_9_21_48_212_4713_pointer_688 = getelementptr <{%Pos, %Pos}>, %Environment %environment_684, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4713, ptr %msg_9_21_48_212_4713_pointer_688, !noalias !2
        %make_5566_temporary_689 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5566 = insertvalue %Pos %make_5566_temporary_689, %Object %fields_683, 1
        
        
        
        %stackPointer_691 = call ccc %StackPointer @stackDeallocate(%Stack %stack_682, i64 24)
        %returnAddress_pointer_692 = getelementptr %FrameHeader, %StackPointer %stackPointer_691, i64 0, i32 0
        %returnAddress_690 = load %ReturnAddress, ptr %returnAddress_pointer_692, !noalias !2
        musttail call tailcc void %returnAddress_690(%Pos %make_5566, %Stack %stack_682)
        ret void
}


@vtable_693 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4744_clause_678]


define ccc void @eraser_697(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4620_696_pointer_698 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4620_696 = load %Prompt, ptr %p_6_18_45_209_4620_696_pointer_698, !noalias !2
        ret void
}



define ccc void @eraser_705(%Environment %environment) {
        
    entry:
        
        %tmp_5413_704_pointer_706 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_5413_704 = load %Pos, ptr %tmp_5413_704_pointer_706, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_5413_704)
        ret void
}



define tailcc void @returnAddress_701(i64 %v_coe_3487_6_28_55_219_4791, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5567 = call ccc %Pos @boxChar_311(i64 %v_coe_3487_6_28_55_219_4791)
        
        
        
        %fields_702 = call ccc %Object @newObject(ptr @eraser_705, i64 16)
        %environment_703 = call ccc %Environment @objectEnvironment(%Object %fields_702)
        %tmp_5413_pointer_707 = getelementptr <{%Pos}>, %Environment %environment_703, i64 0, i32 0
        store %Pos %pureApp_5567, ptr %tmp_5413_pointer_707, !noalias !2
        %make_5568_temporary_708 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5568 = insertvalue %Pos %make_5568_temporary_708, %Object %fields_702, 1
        
        
        
        %stackPointer_710 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_711 = getelementptr %FrameHeader, %StackPointer %stackPointer_710, i64 0, i32 0
        %returnAddress_709 = load %ReturnAddress, ptr %returnAddress_pointer_711, !noalias !2
        musttail call tailcc void %returnAddress_709(%Pos %make_5568, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4766(i64 %index_7_34_198_4866, i64 %acc_8_35_199_4876, %Pos %v_r_2589_30_194_4665, i64 %tmp_5411, %Prompt %p_8_9_4581, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2589_30_194_4665)
        %stackPointer_659 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %tmp_5411_pointer_660 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_659, i64 0, i32 0
        store i64 %tmp_5411, ptr %tmp_5411_pointer_660, !noalias !2
        %p_8_9_4581_pointer_661 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_659, i64 0, i32 1
        store %Prompt %p_8_9_4581, ptr %p_8_9_4581_pointer_661, !noalias !2
        %acc_8_35_199_4876_pointer_662 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_659, i64 0, i32 2
        store i64 %acc_8_35_199_4876, ptr %acc_8_35_199_4876_pointer_662, !noalias !2
        %index_7_34_198_4866_pointer_663 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_659, i64 0, i32 3
        store i64 %index_7_34_198_4866, ptr %index_7_34_198_4866_pointer_663, !noalias !2
        %v_r_2589_30_194_4665_pointer_664 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_659, i64 0, i32 4
        store %Pos %v_r_2589_30_194_4665, ptr %v_r_2589_30_194_4665_pointer_664, !noalias !2
        %returnAddress_pointer_665 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_659, i64 0, i32 1, i32 0
        %sharer_pointer_666 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_659, i64 0, i32 1, i32 1
        %eraser_pointer_667 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_659, i64 0, i32 1, i32 2
        store ptr @returnAddress_595, ptr %returnAddress_pointer_665, !noalias !2
        store ptr @sharer_640, ptr %sharer_pointer_666, !noalias !2
        store ptr @eraser_652, ptr %eraser_pointer_667, !noalias !2
        
        %stack_668 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4620 = call ccc %Prompt @currentPrompt(%Stack %stack_668)
        %stackPointer_674 = call ccc %StackPointer @stackAllocate(%Stack %stack_668, i64 24)
        %returnAddress_pointer_675 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_674, i64 0, i32 1, i32 0
        %sharer_pointer_676 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_674, i64 0, i32 1, i32 1
        %eraser_pointer_677 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_674, i64 0, i32 1, i32 2
        store ptr @returnAddress_669, ptr %returnAddress_pointer_675, !noalias !2
        store ptr @sharer_114, ptr %sharer_pointer_676, !noalias !2
        store ptr @eraser_116, ptr %eraser_pointer_677, !noalias !2
        
        %closure_694 = call ccc %Object @newObject(ptr @eraser_697, i64 8)
        %environment_695 = call ccc %Environment @objectEnvironment(%Object %closure_694)
        %p_6_18_45_209_4620_pointer_699 = getelementptr <{%Prompt}>, %Environment %environment_695, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4620, ptr %p_6_18_45_209_4620_pointer_699, !noalias !2
        %vtable_temporary_700 = insertvalue %Neg zeroinitializer, ptr @vtable_693, 0
        %Exception_7_19_46_210_4744 = insertvalue %Neg %vtable_temporary_700, %Object %closure_694, 1
        %stackPointer_712 = call ccc %StackPointer @stackAllocate(%Stack %stack_668, i64 24)
        %returnAddress_pointer_713 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_712, i64 0, i32 1, i32 0
        %sharer_pointer_714 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_712, i64 0, i32 1, i32 1
        %eraser_pointer_715 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_712, i64 0, i32 1, i32 2
        store ptr @returnAddress_701, ptr %returnAddress_pointer_713, !noalias !2
        store ptr @sharer_7, ptr %sharer_pointer_714, !noalias !2
        store ptr @eraser_9, ptr %eraser_pointer_715, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2589_30_194_4665, i64 %index_7_34_198_4866, %Neg %Exception_7_19_46_210_4744, %Stack %stack_668)
        ret void
}



define tailcc void @Exception_9_106_133_297_4738_clause_716(%Object %closure, %Pos %exception_10_107_134_298_5569, %Pos %msg_11_108_135_299_5570, %Stack %stack) {
        
    entry:
        
        %environment_717 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4581_pointer_718 = getelementptr <{%Prompt}>, %Environment %environment_717, i64 0, i32 0
        %p_8_9_4581 = load %Prompt, ptr %p_8_9_4581_pointer_718, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_5569)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_5570)
        
        %pair_719 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4581)
        %k_13_14_4_5390 = extractvalue <{%Resumption, %Stack}> %pair_719, 0
        %stack_720 = extractvalue <{%Resumption, %Stack}> %pair_719, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_5390)
        
        %longLiteral_5571 = add i64 5, 0
        
        
        
        %pureApp_5572 = call ccc %Pos @boxInt_301(i64 %longLiteral_5571)
        
        
        
        %stackPointer_722 = call ccc %StackPointer @stackDeallocate(%Stack %stack_720, i64 24)
        %returnAddress_pointer_723 = getelementptr %FrameHeader, %StackPointer %stackPointer_722, i64 0, i32 0
        %returnAddress_721 = load %ReturnAddress, ptr %returnAddress_pointer_723, !noalias !2
        musttail call tailcc void %returnAddress_721(%Pos %pureApp_5572, %Stack %stack_720)
        ret void
}


@vtable_724 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4738_clause_716]


define tailcc void @returnAddress_735(i64 %v_coe_3492_22_131_158_322_4736, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5575 = call ccc %Pos @boxInt_301(i64 %v_coe_3492_22_131_158_322_4736)
        
        
        
        
        
        %pureApp_5576 = call ccc i64 @unboxInt_303(%Pos %pureApp_5575)
        
        
        
        %pureApp_5577 = call ccc %Pos @boxInt_301(i64 %pureApp_5576)
        
        
        
        %stackPointer_737 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_738 = getelementptr %FrameHeader, %StackPointer %stackPointer_737, i64 0, i32 0
        %returnAddress_736 = load %ReturnAddress, ptr %returnAddress_pointer_738, !noalias !2
        musttail call tailcc void %returnAddress_736(%Pos %pureApp_5577, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_747(i64 %v_r_2686_1_9_20_129_156_320_4709, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_5581 = add i64 0, 0
        
        %pureApp_5580 = call ccc i64 @infixSub_105(i64 %longLiteral_5581, i64 %v_r_2686_1_9_20_129_156_320_4709)
        
        
        
        %stackPointer_749 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_750 = getelementptr %FrameHeader, %StackPointer %stackPointer_749, i64 0, i32 0
        %returnAddress_748 = load %ReturnAddress, ptr %returnAddress_pointer_750, !noalias !2
        musttail call tailcc void %returnAddress_748(i64 %pureApp_5580, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_730(i64 %v_r_2685_3_14_123_150_314_4826, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_731 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %v_r_2589_30_194_4665_pointer_732 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_731, i64 0, i32 0
        %v_r_2589_30_194_4665 = load %Pos, ptr %v_r_2589_30_194_4665_pointer_732, !noalias !2
        %tmp_5411_pointer_733 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_731, i64 0, i32 1
        %tmp_5411 = load i64, ptr %tmp_5411_pointer_733, !noalias !2
        %p_8_9_4581_pointer_734 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_731, i64 0, i32 2
        %p_8_9_4581 = load %Prompt, ptr %p_8_9_4581_pointer_734, !noalias !2
        
        %intLiteral_5574 = add i64 45, 0
        
        %pureApp_5573 = call ccc %Pos @infixEq_78(i64 %v_r_2685_3_14_123_150_314_4826, i64 %intLiteral_5574)
        
        
        %stackPointer_739 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_740 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_739, i64 0, i32 1, i32 0
        %sharer_pointer_741 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_739, i64 0, i32 1, i32 1
        %eraser_pointer_742 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_739, i64 0, i32 1, i32 2
        store ptr @returnAddress_735, ptr %returnAddress_pointer_740, !noalias !2
        store ptr @sharer_7, ptr %sharer_pointer_741, !noalias !2
        store ptr @eraser_9, ptr %eraser_pointer_742, !noalias !2
        
        %tag_743 = extractvalue %Pos %pureApp_5573, 0
        %fields_744 = extractvalue %Pos %pureApp_5573, 1
        switch i64 %tag_743, label %label_745 [i64 0, label %label_746 i64 1, label %label_755]
    
    label_745:
        
        ret void
    
    label_746:
        
        %longLiteral_5578 = add i64 0, 0
        
        %longLiteral_5579 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4766(i64 %longLiteral_5578, i64 %longLiteral_5579, %Pos %v_r_2589_30_194_4665, i64 %tmp_5411, %Prompt %p_8_9_4581, %Stack %stack)
        ret void
    
    label_755:
        %stackPointer_751 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_752 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_751, i64 0, i32 1, i32 0
        %sharer_pointer_753 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_751, i64 0, i32 1, i32 1
        %eraser_pointer_754 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_751, i64 0, i32 1, i32 2
        store ptr @returnAddress_747, ptr %returnAddress_pointer_752, !noalias !2
        store ptr @sharer_7, ptr %sharer_pointer_753, !noalias !2
        store ptr @eraser_9, ptr %eraser_pointer_754, !noalias !2
        
        %longLiteral_5582 = add i64 1, 0
        
        %longLiteral_5583 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4766(i64 %longLiteral_5582, i64 %longLiteral_5583, %Pos %v_r_2589_30_194_4665, i64 %tmp_5411, %Prompt %p_8_9_4581, %Stack %stack)
        ret void
}



define ccc void @sharer_759(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_760 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_r_2589_30_194_4665_756_pointer_761 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_760, i64 0, i32 0
        %v_r_2589_30_194_4665_756 = load %Pos, ptr %v_r_2589_30_194_4665_756_pointer_761, !noalias !2
        %tmp_5411_757_pointer_762 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_760, i64 0, i32 1
        %tmp_5411_757 = load i64, ptr %tmp_5411_757_pointer_762, !noalias !2
        %p_8_9_4581_758_pointer_763 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_760, i64 0, i32 2
        %p_8_9_4581_758 = load %Prompt, ptr %p_8_9_4581_758_pointer_763, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2589_30_194_4665_756)
        call ccc void @shareFrames(%StackPointer %stackPointer_760)
        ret void
}



define ccc void @eraser_767(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_768 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %v_r_2589_30_194_4665_764_pointer_769 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_768, i64 0, i32 0
        %v_r_2589_30_194_4665_764 = load %Pos, ptr %v_r_2589_30_194_4665_764_pointer_769, !noalias !2
        %tmp_5411_765_pointer_770 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_768, i64 0, i32 1
        %tmp_5411_765 = load i64, ptr %tmp_5411_765_pointer_770, !noalias !2
        %p_8_9_4581_766_pointer_771 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_768, i64 0, i32 2
        %p_8_9_4581_766 = load %Prompt, ptr %p_8_9_4581_766_pointer_771, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2589_30_194_4665_764)
        call ccc void @eraseFrames(%StackPointer %stackPointer_768)
        ret void
}



define tailcc void @returnAddress_592(%Pos %v_r_2589_30_194_4665, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_593 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4581_pointer_594 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_593, i64 0, i32 0
        %p_8_9_4581 = load %Prompt, ptr %p_8_9_4581_pointer_594, !noalias !2
        
        %intLiteral_5546 = add i64 48, 0
        
        %pureApp_5545 = call ccc i64 @toInt_2085(i64 %intLiteral_5546)
        
        
        
        %closure_725 = call ccc %Object @newObject(ptr @eraser_697, i64 8)
        %environment_726 = call ccc %Environment @objectEnvironment(%Object %closure_725)
        %p_8_9_4581_pointer_728 = getelementptr <{%Prompt}>, %Environment %environment_726, i64 0, i32 0
        store %Prompt %p_8_9_4581, ptr %p_8_9_4581_pointer_728, !noalias !2
        %vtable_temporary_729 = insertvalue %Neg zeroinitializer, ptr @vtable_724, 0
        %Exception_9_106_133_297_4738 = insertvalue %Neg %vtable_temporary_729, %Object %closure_725, 1
        call ccc void @sharePositive(%Pos %v_r_2589_30_194_4665)
        %stackPointer_772 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %v_r_2589_30_194_4665_pointer_773 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_772, i64 0, i32 0
        store %Pos %v_r_2589_30_194_4665, ptr %v_r_2589_30_194_4665_pointer_773, !noalias !2
        %tmp_5411_pointer_774 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_772, i64 0, i32 1
        store i64 %pureApp_5545, ptr %tmp_5411_pointer_774, !noalias !2
        %p_8_9_4581_pointer_775 = getelementptr <{%Pos, i64, %Prompt}>, %StackPointer %stackPointer_772, i64 0, i32 2
        store %Prompt %p_8_9_4581, ptr %p_8_9_4581_pointer_775, !noalias !2
        %returnAddress_pointer_776 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_772, i64 0, i32 1, i32 0
        %sharer_pointer_777 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_772, i64 0, i32 1, i32 1
        %eraser_pointer_778 = getelementptr <{<{%Pos, i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_772, i64 0, i32 1, i32 2
        store ptr @returnAddress_730, ptr %returnAddress_pointer_776, !noalias !2
        store ptr @sharer_759, ptr %sharer_pointer_777, !noalias !2
        store ptr @eraser_767, ptr %eraser_pointer_778, !noalias !2
        
        %longLiteral_5584 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2589_30_194_4665, i64 %longLiteral_5584, %Neg %Exception_9_106_133_297_4738, %Stack %stack)
        ret void
}



define ccc void @sharer_780(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_781 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4581_779_pointer_782 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_781, i64 0, i32 0
        %p_8_9_4581_779 = load %Prompt, ptr %p_8_9_4581_779_pointer_782, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_781)
        ret void
}



define ccc void @eraser_784(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_785 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4581_783_pointer_786 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_785, i64 0, i32 0
        %p_8_9_4581_783 = load %Prompt, ptr %p_8_9_4581_783_pointer_786, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_785)
        ret void
}


@utf8StringLiteral_5585.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_589(%Pos %v_r_2588_24_188_4795, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_590 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4581_pointer_591 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_590, i64 0, i32 0
        %p_8_9_4581 = load %Prompt, ptr %p_8_9_4581_pointer_591, !noalias !2
        %stackPointer_787 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4581_pointer_788 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_787, i64 0, i32 0
        store %Prompt %p_8_9_4581, ptr %p_8_9_4581_pointer_788, !noalias !2
        %returnAddress_pointer_789 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_787, i64 0, i32 1, i32 0
        %sharer_pointer_790 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_787, i64 0, i32 1, i32 1
        %eraser_pointer_791 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_787, i64 0, i32 1, i32 2
        store ptr @returnAddress_592, ptr %returnAddress_pointer_789, !noalias !2
        store ptr @sharer_780, ptr %sharer_pointer_790, !noalias !2
        store ptr @eraser_784, ptr %eraser_pointer_791, !noalias !2
        
        %tag_792 = extractvalue %Pos %v_r_2588_24_188_4795, 0
        %fields_793 = extractvalue %Pos %v_r_2588_24_188_4795, 1
        switch i64 %tag_792, label %label_794 [i64 0, label %label_798 i64 1, label %label_804]
    
    label_794:
        
        ret void
    
    label_798:
        
        %utf8StringLiteral_5585 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5585.lit)
        
        %stackPointer_796 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_797 = getelementptr %FrameHeader, %StackPointer %stackPointer_796, i64 0, i32 0
        %returnAddress_795 = load %ReturnAddress, ptr %returnAddress_pointer_797, !noalias !2
        musttail call tailcc void %returnAddress_795(%Pos %utf8StringLiteral_5585, %Stack %stack)
        ret void
    
    label_804:
        %environment_799 = call ccc %Environment @objectEnvironment(%Object %fields_793)
        %v_y_3314_8_29_193_4626_pointer_800 = getelementptr <{%Pos}>, %Environment %environment_799, i64 0, i32 0
        %v_y_3314_8_29_193_4626 = load %Pos, ptr %v_y_3314_8_29_193_4626_pointer_800, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3314_8_29_193_4626)
        call ccc void @eraseObject(%Object %fields_793)
        
        %stackPointer_802 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_803 = getelementptr %FrameHeader, %StackPointer %stackPointer_802, i64 0, i32 0
        %returnAddress_801 = load %ReturnAddress, ptr %returnAddress_pointer_803, !noalias !2
        musttail call tailcc void %returnAddress_801(%Pos %v_y_3314_8_29_193_4626, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_586(%Pos %v_r_2587_13_177_4890, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_587 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4581_pointer_588 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_587, i64 0, i32 0
        %p_8_9_4581 = load %Prompt, ptr %p_8_9_4581_pointer_588, !noalias !2
        %stackPointer_807 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4581_pointer_808 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_807, i64 0, i32 0
        store %Prompt %p_8_9_4581, ptr %p_8_9_4581_pointer_808, !noalias !2
        %returnAddress_pointer_809 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_807, i64 0, i32 1, i32 0
        %sharer_pointer_810 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_807, i64 0, i32 1, i32 1
        %eraser_pointer_811 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_807, i64 0, i32 1, i32 2
        store ptr @returnAddress_589, ptr %returnAddress_pointer_809, !noalias !2
        store ptr @sharer_780, ptr %sharer_pointer_810, !noalias !2
        store ptr @eraser_784, ptr %eraser_pointer_811, !noalias !2
        
        %tag_812 = extractvalue %Pos %v_r_2587_13_177_4890, 0
        %fields_813 = extractvalue %Pos %v_r_2587_13_177_4890, 1
        switch i64 %tag_812, label %label_814 [i64 0, label %label_819 i64 1, label %label_831]
    
    label_814:
        
        ret void
    
    label_819:
        
        %make_5586_temporary_815 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5586 = insertvalue %Pos %make_5586_temporary_815, %Object null, 1
        
        
        
        %stackPointer_817 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_818 = getelementptr %FrameHeader, %StackPointer %stackPointer_817, i64 0, i32 0
        %returnAddress_816 = load %ReturnAddress, ptr %returnAddress_pointer_818, !noalias !2
        musttail call tailcc void %returnAddress_816(%Pos %make_5586, %Stack %stack)
        ret void
    
    label_831:
        %environment_820 = call ccc %Environment @objectEnvironment(%Object %fields_813)
        %v_y_2823_10_21_185_4623_pointer_821 = getelementptr <{%Pos, %Pos}>, %Environment %environment_820, i64 0, i32 0
        %v_y_2823_10_21_185_4623 = load %Pos, ptr %v_y_2823_10_21_185_4623_pointer_821, !noalias !2
        %v_y_2824_11_22_186_4674_pointer_822 = getelementptr <{%Pos, %Pos}>, %Environment %environment_820, i64 0, i32 1
        %v_y_2824_11_22_186_4674 = load %Pos, ptr %v_y_2824_11_22_186_4674_pointer_822, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2823_10_21_185_4623)
        call ccc void @eraseObject(%Object %fields_813)
        
        %fields_823 = call ccc %Object @newObject(ptr @eraser_705, i64 16)
        %environment_824 = call ccc %Environment @objectEnvironment(%Object %fields_823)
        %v_y_2823_10_21_185_4623_pointer_826 = getelementptr <{%Pos}>, %Environment %environment_824, i64 0, i32 0
        store %Pos %v_y_2823_10_21_185_4623, ptr %v_y_2823_10_21_185_4623_pointer_826, !noalias !2
        %make_5587_temporary_827 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5587 = insertvalue %Pos %make_5587_temporary_827, %Object %fields_823, 1
        
        
        
        %stackPointer_829 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_830 = getelementptr %FrameHeader, %StackPointer %stackPointer_829, i64 0, i32 0
        %returnAddress_828 = load %ReturnAddress, ptr %returnAddress_pointer_830, !noalias !2
        musttail call tailcc void %returnAddress_828(%Pos %make_5587, %Stack %stack)
        ret void
}



define tailcc void @main_2448(%Stack %stack) {
        
    entry:
        
        %stackPointer_556 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_557 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_556, i64 0, i32 1, i32 0
        %sharer_pointer_558 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_556, i64 0, i32 1, i32 1
        %eraser_pointer_559 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_556, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_557, !noalias !2
        store ptr @sharer_7, ptr %sharer_pointer_558, !noalias !2
        store ptr @eraser_9, ptr %eraser_pointer_559, !noalias !2
        
        %stack_560 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4581 = call ccc %Prompt @currentPrompt(%Stack %stack_560)
        %stackPointer_566 = call ccc %StackPointer @stackAllocate(%Stack %stack_560, i64 24)
        %returnAddress_pointer_567 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 0
        %sharer_pointer_568 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 1
        %eraser_pointer_569 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 2
        store ptr @returnAddress_561, ptr %returnAddress_pointer_567, !noalias !2
        store ptr @sharer_114, ptr %sharer_pointer_568, !noalias !2
        store ptr @eraser_116, ptr %eraser_pointer_569, !noalias !2
        
        %pureApp_5541 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5543 = add i64 1, 0
        
        %pureApp_5542 = call ccc i64 @infixSub_105(i64 %pureApp_5541, i64 %longLiteral_5543)
        
        
        
        %make_5544_temporary_585 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5544 = insertvalue %Pos %make_5544_temporary_585, %Object null, 1
        
        
        %stackPointer_834 = call ccc %StackPointer @stackAllocate(%Stack %stack_560, i64 32)
        %p_8_9_4581_pointer_835 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_834, i64 0, i32 0
        store %Prompt %p_8_9_4581, ptr %p_8_9_4581_pointer_835, !noalias !2
        %returnAddress_pointer_836 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_834, i64 0, i32 1, i32 0
        %sharer_pointer_837 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_834, i64 0, i32 1, i32 1
        %eraser_pointer_838 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_834, i64 0, i32 1, i32 2
        store ptr @returnAddress_586, ptr %returnAddress_pointer_836, !noalias !2
        store ptr @sharer_780, ptr %sharer_pointer_837, !noalias !2
        store ptr @eraser_784, ptr %eraser_pointer_838, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4790(i64 %pureApp_5542, %Pos %make_5544, %Stack %stack_560)
        ret void
}



define ccc void @eraser_850(%Environment %environment) {
        
    entry:
        
        %t_2461_847_pointer_851 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment, i64 0, i32 0
        %t_2461_847 = load %Pos, ptr %t_2461_847_pointer_851, !noalias !2
        %n_2444_848_pointer_852 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment, i64 0, i32 1
        %n_2444_848 = load i64, ptr %n_2444_848_pointer_852, !noalias !2
        %t_2461_849_pointer_853 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment, i64 0, i32 2
        %t_2461_849 = load %Pos, ptr %t_2461_849_pointer_853, !noalias !2
        call ccc void @erasePositive(%Pos %t_2461_847)
        call ccc void @erasePositive(%Pos %t_2461_849)
        ret void
}



define tailcc void @returnAddress_842(%Pos %t_2461, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_843 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %n_2444_pointer_844 = getelementptr <{i64}>, %StackPointer %stackPointer_843, i64 0, i32 0
        %n_2444 = load i64, ptr %n_2444_pointer_844, !noalias !2
        
        %fields_845 = call ccc %Object @newObject(ptr @eraser_850, i64 40)
        %environment_846 = call ccc %Environment @objectEnvironment(%Object %fields_845)
        call ccc void @sharePositive(%Pos %t_2461)
        %t_2461_pointer_854 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_846, i64 0, i32 0
        store %Pos %t_2461, ptr %t_2461_pointer_854, !noalias !2
        %n_2444_pointer_855 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_846, i64 0, i32 1
        store i64 %n_2444, ptr %n_2444_pointer_855, !noalias !2
        %t_2461_pointer_856 = getelementptr <{%Pos, i64, %Pos}>, %Environment %environment_846, i64 0, i32 2
        store %Pos %t_2461, ptr %t_2461_pointer_856, !noalias !2
        %make_5482_temporary_857 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5482 = insertvalue %Pos %make_5482_temporary_857, %Object %fields_845, 1
        
        
        
        %stackPointer_859 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_860 = getelementptr %FrameHeader, %StackPointer %stackPointer_859, i64 0, i32 0
        %returnAddress_858 = load %ReturnAddress, ptr %returnAddress_pointer_860, !noalias !2
        musttail call tailcc void %returnAddress_858(%Pos %make_5482, %Stack %stack)
        ret void
}



define tailcc void @make_2445(i64 %n_2444, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5479 = add i64 0, 0
        
        %pureApp_5478 = call ccc %Pos @infixEq_72(i64 %n_2444, i64 %longLiteral_5479)
        
        
        
        %tag_839 = extractvalue %Pos %pureApp_5478, 0
        %fields_840 = extractvalue %Pos %pureApp_5478, 1
        switch i64 %tag_839, label %label_841 [i64 0, label %label_868 i64 1, label %label_873]
    
    label_841:
        
        ret void
    
    label_868:
        
        %longLiteral_5481 = add i64 1, 0
        
        %pureApp_5480 = call ccc i64 @infixSub_105(i64 %n_2444, i64 %longLiteral_5481)
        
        
        %stackPointer_863 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %n_2444_pointer_864 = getelementptr <{i64}>, %StackPointer %stackPointer_863, i64 0, i32 0
        store i64 %n_2444, ptr %n_2444_pointer_864, !noalias !2
        %returnAddress_pointer_865 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_863, i64 0, i32 1, i32 0
        %sharer_pointer_866 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_863, i64 0, i32 1, i32 1
        %eraser_pointer_867 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_863, i64 0, i32 1, i32 2
        store ptr @returnAddress_842, ptr %returnAddress_pointer_865, !noalias !2
        store ptr @sharer_23, ptr %sharer_pointer_866, !noalias !2
        store ptr @eraser_27, ptr %eraser_pointer_867, !noalias !2
        
        
        
        musttail call tailcc void @make_2445(i64 %pureApp_5480, %Stack %stack)
        ret void
    
    label_873:
        
        %make_5483_temporary_869 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5483 = insertvalue %Pos %make_5483_temporary_869, %Object null, 1
        
        
        
        %stackPointer_871 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_872 = getelementptr %FrameHeader, %StackPointer %stackPointer_871, i64 0, i32 0
        %returnAddress_870 = load %ReturnAddress, ptr %returnAddress_pointer_872, !noalias !2
        musttail call tailcc void %returnAddress_870(%Pos %make_5483, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_886(i64 %v_r_2539_3_3_3926, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_887 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_5458_pointer_888 = getelementptr <{i64}>, %StackPointer %stackPointer_887, i64 0, i32 0
        %tmp_5458 = load i64, ptr %tmp_5458_pointer_888, !noalias !2
        
        %pureApp_5477 = call ccc %Pos @infixGt_184(i64 %tmp_5458, i64 %v_r_2539_3_3_3926)
        
        
        
        %tag_889 = extractvalue %Pos %pureApp_5477, 0
        %fields_890 = extractvalue %Pos %pureApp_5477, 1
        switch i64 %tag_889, label %label_891 [i64 0, label %label_895 i64 1, label %label_899]
    
    label_891:
        
        ret void
    
    label_895:
        
        %stackPointer_893 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_894 = getelementptr %FrameHeader, %StackPointer %stackPointer_893, i64 0, i32 0
        %returnAddress_892 = load %ReturnAddress, ptr %returnAddress_pointer_894, !noalias !2
        musttail call tailcc void %returnAddress_892(i64 %v_r_2539_3_3_3926, %Stack %stack)
        ret void
    
    label_899:
        
        %stackPointer_897 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_898 = getelementptr %FrameHeader, %StackPointer %stackPointer_897, i64 0, i32 0
        %returnAddress_896 = load %ReturnAddress, ptr %returnAddress_pointer_898, !noalias !2
        musttail call tailcc void %returnAddress_896(i64 %tmp_5458, %Stack %stack)
        ret void
}



define tailcc void @maximum_2438(%Pos %l_2437, %Stack %stack) {
        
    entry:
        
        
        %tag_874 = extractvalue %Pos %l_2437, 0
        %fields_875 = extractvalue %Pos %l_2437, 1
        switch i64 %tag_874, label %label_876 [i64 0, label %label_880 i64 1, label %label_912]
    
    label_876:
        
        ret void
    
    label_880:
        
        %longLiteral_5475 = add i64 -1, 0
        
        %stackPointer_878 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_879 = getelementptr %FrameHeader, %StackPointer %stackPointer_878, i64 0, i32 0
        %returnAddress_877 = load %ReturnAddress, ptr %returnAddress_pointer_879, !noalias !2
        musttail call tailcc void %returnAddress_877(i64 %longLiteral_5475, %Stack %stack)
        ret void
    
    label_907:
        call ccc void @erasePositive(%Pos %v_coe_3508_3634)
        %stackPointer_902 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_5458_pointer_903 = getelementptr <{i64}>, %StackPointer %stackPointer_902, i64 0, i32 0
        store i64 %pureApp_5476, ptr %tmp_5458_pointer_903, !noalias !2
        %returnAddress_pointer_904 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_902, i64 0, i32 1, i32 0
        %sharer_pointer_905 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_902, i64 0, i32 1, i32 1
        %eraser_pointer_906 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_902, i64 0, i32 1, i32 2
        store ptr @returnAddress_886, ptr %returnAddress_pointer_904, !noalias !2
        store ptr @sharer_23, ptr %sharer_pointer_905, !noalias !2
        store ptr @eraser_27, ptr %eraser_pointer_906, !noalias !2
        
        
        
        musttail call tailcc void @maximum_2438(%Pos %v_coe_3508_3634, %Stack %stack)
        ret void
    
    label_911:
        call ccc void @erasePositive(%Pos %v_coe_3508_3634)
        
        %stackPointer_909 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_910 = getelementptr %FrameHeader, %StackPointer %stackPointer_909, i64 0, i32 0
        %returnAddress_908 = load %ReturnAddress, ptr %returnAddress_pointer_910, !noalias !2
        musttail call tailcc void %returnAddress_908(i64 %pureApp_5476, %Stack %stack)
        ret void
    
    label_912:
        %environment_881 = call ccc %Environment @objectEnvironment(%Object %fields_875)
        %v_coe_3507_3633_pointer_882 = getelementptr <{%Pos, %Pos}>, %Environment %environment_881, i64 0, i32 0
        %v_coe_3507_3633 = load %Pos, ptr %v_coe_3507_3633_pointer_882, !noalias !2
        %v_coe_3508_3634_pointer_883 = getelementptr <{%Pos, %Pos}>, %Environment %environment_881, i64 0, i32 1
        %v_coe_3508_3634 = load %Pos, ptr %v_coe_3508_3634_pointer_883, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3507_3633)
        call ccc void @sharePositive(%Pos %v_coe_3508_3634)
        call ccc void @eraseObject(%Object %fields_875)
        
        %pureApp_5476 = call ccc i64 @unboxInt_303(%Pos %v_coe_3507_3633)
        
        
        
        call ccc void @sharePositive(%Pos %v_coe_3508_3634)
        %tag_884 = extractvalue %Pos %v_coe_3508_3634, 0
        %fields_885 = extractvalue %Pos %v_coe_3508_3634, 1
        switch i64 %tag_884, label %label_907 [i64 0, label %label_911]
}


@utf8StringLiteral_5466.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_5468.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_5471.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_913(%Pos %v_r_2754_3547, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_914 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_915 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_914, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_915, !noalias !2
        %index_2107_pointer_916 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_914, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_916, !noalias !2
        %Exception_2362_pointer_917 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_914, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_917, !noalias !2
        
        %tag_918 = extractvalue %Pos %v_r_2754_3547, 0
        %fields_919 = extractvalue %Pos %v_r_2754_3547, 1
        switch i64 %tag_918, label %label_920 [i64 0, label %label_924 i64 1, label %label_930]
    
    label_920:
        
        ret void
    
    label_924:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_5462 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_922 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_923 = getelementptr %FrameHeader, %StackPointer %stackPointer_922, i64 0, i32 0
        %returnAddress_921 = load %ReturnAddress, ptr %returnAddress_pointer_923, !noalias !2
        musttail call tailcc void %returnAddress_921(i64 %pureApp_5462, %Stack %stack)
        ret void
    
    label_930:
        
        %make_5463_temporary_925 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5463 = insertvalue %Pos %make_5463_temporary_925, %Object null, 1
        
        
        
        %pureApp_5464 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_5466 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_5466.lit)
        
        %pureApp_5465 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_5466, %Pos %pureApp_5464)
        
        
        
        %utf8StringLiteral_5468 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_5468.lit)
        
        %pureApp_5467 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5465, %Pos %utf8StringLiteral_5468)
        
        
        
        %pureApp_5469 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5467, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_5471 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_5471.lit)
        
        %pureApp_5470 = call ccc %Pos @infixConcat_35(%Pos %pureApp_5469, %Pos %utf8StringLiteral_5471)
        
        
        
        %vtable_926 = extractvalue %Neg %Exception_2362, 0
        %closure_927 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_928 = getelementptr ptr, ptr %vtable_926, i64 0
        %functionPointer_929 = load ptr, ptr %functionPointer_pointer_928, !noalias !2
        musttail call tailcc void %functionPointer_929(%Object %closure_927, %Pos %make_5463, %Pos %pureApp_5470, %Stack %stack)
        ret void
}



define ccc void @sharer_934(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_935 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_931_pointer_936 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_935, i64 0, i32 0
        %str_2106_931 = load %Pos, ptr %str_2106_931_pointer_936, !noalias !2
        %index_2107_932_pointer_937 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_935, i64 0, i32 1
        %index_2107_932 = load i64, ptr %index_2107_932_pointer_937, !noalias !2
        %Exception_2362_933_pointer_938 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_935, i64 0, i32 2
        %Exception_2362_933 = load %Neg, ptr %Exception_2362_933_pointer_938, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_931)
        call ccc void @shareNegative(%Neg %Exception_2362_933)
        call ccc void @shareFrames(%StackPointer %stackPointer_935)
        ret void
}



define ccc void @eraser_942(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_943 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_939_pointer_944 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_943, i64 0, i32 0
        %str_2106_939 = load %Pos, ptr %str_2106_939_pointer_944, !noalias !2
        %index_2107_940_pointer_945 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_943, i64 0, i32 1
        %index_2107_940 = load i64, ptr %index_2107_940_pointer_945, !noalias !2
        %Exception_2362_941_pointer_946 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_943, i64 0, i32 2
        %Exception_2362_941 = load %Neg, ptr %Exception_2362_941_pointer_946, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_939)
        call ccc void @eraseNegative(%Neg %Exception_2362_941)
        call ccc void @eraseFrames(%StackPointer %stackPointer_943)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5461 = add i64 0, 0
        
        %pureApp_5460 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_5461)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_947 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_948 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_947, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_948, !noalias !2
        %index_2107_pointer_949 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_947, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_949, !noalias !2
        %Exception_2362_pointer_950 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_947, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_950, !noalias !2
        %returnAddress_pointer_951 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_947, i64 0, i32 1, i32 0
        %sharer_pointer_952 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_947, i64 0, i32 1, i32 1
        %eraser_pointer_953 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_947, i64 0, i32 1, i32 2
        store ptr @returnAddress_913, ptr %returnAddress_pointer_951, !noalias !2
        store ptr @sharer_934, ptr %sharer_pointer_952, !noalias !2
        store ptr @eraser_942, ptr %eraser_pointer_953, !noalias !2
        
        %tag_954 = extractvalue %Pos %pureApp_5460, 0
        %fields_955 = extractvalue %Pos %pureApp_5460, 1
        switch i64 %tag_954, label %label_956 [i64 0, label %label_960 i64 1, label %label_965]
    
    label_956:
        
        ret void
    
    label_960:
        
        %pureApp_5472 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_5473 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_5472)
        
        
        
        %stackPointer_958 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_959 = getelementptr %FrameHeader, %StackPointer %stackPointer_958, i64 0, i32 0
        %returnAddress_957 = load %ReturnAddress, ptr %returnAddress_pointer_959, !noalias !2
        musttail call tailcc void %returnAddress_957(%Pos %pureApp_5473, %Stack %stack)
        ret void
    
    label_965:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_5474_temporary_961 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_5474 = insertvalue %Pos %booleanLiteral_5474_temporary_961, %Object null, 1
        
        %stackPointer_963 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_964 = getelementptr %FrameHeader, %StackPointer %stackPointer_963, i64 0, i32 0
        %returnAddress_962 = load %ReturnAddress, ptr %returnAddress_pointer_964, !noalias !2
        musttail call tailcc void %returnAddress_962(%Pos %booleanLiteral_5474, %Stack %stack)
        ret void
}



define tailcc void @reverseOnto_1019(%Pos %l_1017, %Pos %other_1018, %Stack %stack) {
        
    entry:
        
        
        %tag_966 = extractvalue %Pos %l_1017, 0
        %fields_967 = extractvalue %Pos %l_1017, 1
        switch i64 %tag_966, label %label_968 [i64 0, label %label_972 i64 1, label %label_983]
    
    label_968:
        
        ret void
    
    label_972:
        
        %stackPointer_970 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_971 = getelementptr %FrameHeader, %StackPointer %stackPointer_970, i64 0, i32 0
        %returnAddress_969 = load %ReturnAddress, ptr %returnAddress_pointer_971, !noalias !2
        musttail call tailcc void %returnAddress_969(%Pos %other_1018, %Stack %stack)
        ret void
    
    label_983:
        %environment_973 = call ccc %Environment @objectEnvironment(%Object %fields_967)
        %v_y_2985_2988_pointer_974 = getelementptr <{%Pos, %Pos}>, %Environment %environment_973, i64 0, i32 0
        %v_y_2985_2988 = load %Pos, ptr %v_y_2985_2988_pointer_974, !noalias !2
        %v_y_2986_2987_pointer_975 = getelementptr <{%Pos, %Pos}>, %Environment %environment_973, i64 0, i32 1
        %v_y_2986_2987 = load %Pos, ptr %v_y_2986_2987_pointer_975, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2985_2988)
        call ccc void @sharePositive(%Pos %v_y_2986_2987)
        call ccc void @eraseObject(%Object %fields_967)
        
        %fields_976 = call ccc %Object @newObject(ptr @eraser_414, i64 32)
        %environment_977 = call ccc %Environment @objectEnvironment(%Object %fields_976)
        %v_y_2985_2988_pointer_980 = getelementptr <{%Pos, %Pos}>, %Environment %environment_977, i64 0, i32 0
        store %Pos %v_y_2985_2988, ptr %v_y_2985_2988_pointer_980, !noalias !2
        %other_1018_pointer_981 = getelementptr <{%Pos, %Pos}>, %Environment %environment_977, i64 0, i32 1
        store %Pos %other_1018, ptr %other_1018_pointer_981, !noalias !2
        %make_5459_temporary_982 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5459 = insertvalue %Pos %make_5459_temporary_982, %Object %fields_976, 1
        
        
        
        
        
        
        musttail call tailcc void @reverseOnto_1019(%Pos %v_y_2986_2987, %Pos %make_5459, %Stack %stack)
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
        
        musttail call tailcc void @main_2448(%Stack %stack)
        ret void
}
