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



define tailcc void @returnAddress_2(i64 %r_2464, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4867 = call ccc %Pos @show_14(i64 %r_2464)
        
        
        
        %pureApp_4868 = call ccc %Pos @println_1(%Pos %pureApp_4867)
        
        
        
        %stackPointer_4 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_5 = getelementptr %FrameHeader, %StackPointer %stackPointer_4, i64 0, i32 0
        %returnAddress_3 = load %ReturnAddress, ptr %returnAddress_pointer_5, !noalias !2
        musttail call tailcc void %returnAddress_3(%Pos %pureApp_4868, %Stack %stack)
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



define tailcc void @returnAddress_15(i64 %returned_4869, %Stack %stack) {
        
    entry:
        
        %stack_16 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_18 = call ccc %StackPointer @stackDeallocate(%Stack %stack_16, i64 24)
        %returnAddress_pointer_19 = getelementptr %FrameHeader, %StackPointer %stackPointer_18, i64 0, i32 0
        %returnAddress_17 = load %ReturnAddress, ptr %returnAddress_pointer_19, !noalias !2
        musttail call tailcc void %returnAddress_17(i64 %returned_4869, %Stack %stack_16)
        ret void
}



define ccc void @sharer_20(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_21 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_22(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_23 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_23)
        ret void
}



define tailcc void @returnAddress_31(%Pos %v_r_2522_10_11_31_4655, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_32 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %n_7_8_18_4688_pointer_33 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_32, i64 0, i32 0
        %n_7_8_18_4688 = load i64, ptr %n_7_8_18_4688_pointer_33, !noalias !2
        %p_4_4684_pointer_34 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_32, i64 0, i32 1
        %p_4_4684 = load %Prompt, ptr %p_4_4684_pointer_34, !noalias !2
        
        %tag_35 = extractvalue %Pos %v_r_2522_10_11_31_4655, 0
        %fields_36 = extractvalue %Pos %v_r_2522_10_11_31_4655, 1
        switch i64 %tag_35, label %label_37 [i64 0, label %label_38 i64 1, label %label_42]
    
    label_37:
        
        ret void
    
    label_38:
        
        %longLiteral_4873 = add i64 1, 0
        
        %pureApp_4872 = call ccc i64 @infixSub_105(i64 %n_7_8_18_4688, i64 %longLiteral_4873)
        
        
        
        
        
        musttail call tailcc void @choice_worker_6_7_17_4702(i64 %pureApp_4872, %Prompt %p_4_4684, %Stack %stack)
        ret void
    
    label_42:
        
        %stackPointer_40 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_41 = getelementptr %FrameHeader, %StackPointer %stackPointer_40, i64 0, i32 0
        %returnAddress_39 = load %ReturnAddress, ptr %returnAddress_pointer_41, !noalias !2
        musttail call tailcc void %returnAddress_39(i64 %n_7_8_18_4688, %Stack %stack)
        ret void
}



define ccc void @sharer_45(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_46 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %n_7_8_18_4688_43_pointer_47 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_46, i64 0, i32 0
        %n_7_8_18_4688_43 = load i64, ptr %n_7_8_18_4688_43_pointer_47, !noalias !2
        %p_4_4684_44_pointer_48 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_46, i64 0, i32 1
        %p_4_4684_44 = load %Prompt, ptr %p_4_4684_44_pointer_48, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_46)
        ret void
}



define ccc void @eraser_51(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_52 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %n_7_8_18_4688_49_pointer_53 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_52, i64 0, i32 0
        %n_7_8_18_4688_49 = load i64, ptr %n_7_8_18_4688_49_pointer_53, !noalias !2
        %p_4_4684_50_pointer_54 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_52, i64 0, i32 1
        %p_4_4684_50 = load %Prompt, ptr %p_4_4684_50_pointer_54, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_52)
        ret void
}



define tailcc void @returnAddress_66(i64 %v_r_2544_6_28_4681, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_67 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2543_5_27_4621_pointer_68 = getelementptr <{i64}>, %StackPointer %stackPointer_67, i64 0, i32 0
        %v_r_2543_5_27_4621 = load i64, ptr %v_r_2543_5_27_4621_pointer_68, !noalias !2
        
        %pureApp_4874 = call ccc i64 @infixAdd_96(i64 %v_r_2543_5_27_4621, i64 %v_r_2544_6_28_4681)
        
        
        
        %longLiteral_4876 = add i64 1000000007, 0
        
        %pureApp_4875 = call ccc i64 @mod_108(i64 %pureApp_4874, i64 %longLiteral_4876)
        
        
        
        %stackPointer_70 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_71 = getelementptr %FrameHeader, %StackPointer %stackPointer_70, i64 0, i32 0
        %returnAddress_69 = load %ReturnAddress, ptr %returnAddress_pointer_71, !noalias !2
        musttail call tailcc void %returnAddress_69(i64 %pureApp_4875, %Stack %stack)
        ret void
}



define ccc void @sharer_73(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_74 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2543_5_27_4621_72_pointer_75 = getelementptr <{i64}>, %StackPointer %stackPointer_74, i64 0, i32 0
        %v_r_2543_5_27_4621_72 = load i64, ptr %v_r_2543_5_27_4621_72_pointer_75, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_74)
        ret void
}



define ccc void @eraser_77(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_78 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %v_r_2543_5_27_4621_76_pointer_79 = getelementptr <{i64}>, %StackPointer %stackPointer_78, i64 0, i32 0
        %v_r_2543_5_27_4621_76 = load i64, ptr %v_r_2543_5_27_4621_76_pointer_79, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_78)
        ret void
}



define tailcc void @returnAddress_63(i64 %v_r_2543_5_27_4621, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_64 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %k_2_24_4698_pointer_65 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_64, i64 0, i32 0
        %k_2_24_4698 = load %Resumption, ptr %k_2_24_4698_pointer_65, !noalias !2
        %stackPointer_80 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2543_5_27_4621_pointer_81 = getelementptr <{i64}>, %StackPointer %stackPointer_80, i64 0, i32 0
        store i64 %v_r_2543_5_27_4621, ptr %v_r_2543_5_27_4621_pointer_81, !noalias !2
        %returnAddress_pointer_82 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_80, i64 0, i32 1, i32 0
        %sharer_pointer_83 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_80, i64 0, i32 1, i32 1
        %eraser_pointer_84 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_80, i64 0, i32 1, i32 2
        store ptr @returnAddress_66, ptr %returnAddress_pointer_82, !noalias !2
        store ptr @sharer_73, ptr %sharer_pointer_83, !noalias !2
        store ptr @eraser_77, ptr %eraser_pointer_84, !noalias !2
        
        %stack_85 = call ccc %Stack @resume(%Resumption %k_2_24_4698, %Stack %stack)
        
        %booleanLiteral_4877_temporary_86 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_4877 = insertvalue %Pos %booleanLiteral_4877_temporary_86, %Object null, 1
        
        %stackPointer_88 = call ccc %StackPointer @stackDeallocate(%Stack %stack_85, i64 24)
        %returnAddress_pointer_89 = getelementptr %FrameHeader, %StackPointer %stackPointer_88, i64 0, i32 0
        %returnAddress_87 = load %ReturnAddress, ptr %returnAddress_pointer_89, !noalias !2
        musttail call tailcc void %returnAddress_87(%Pos %booleanLiteral_4877, %Stack %stack_85)
        ret void
}



define ccc void @sharer_91(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_92 = getelementptr <{%Resumption}>, %StackPointer %stackPointer, i64 -1
        %k_2_24_4698_90_pointer_93 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_92, i64 0, i32 0
        %k_2_24_4698_90 = load %Resumption, ptr %k_2_24_4698_90_pointer_93, !noalias !2
        call ccc void @shareResumption(%Resumption %k_2_24_4698_90)
        call ccc void @shareFrames(%StackPointer %stackPointer_92)
        ret void
}



define ccc void @eraser_95(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_96 = getelementptr <{%Resumption}>, %StackPointer %stackPointer, i64 -1
        %k_2_24_4698_94_pointer_97 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_96, i64 0, i32 0
        %k_2_24_4698_94 = load %Resumption, ptr %k_2_24_4698_94_pointer_97, !noalias !2
        call ccc void @eraseResumption(%Resumption %k_2_24_4698_94)
        call ccc void @eraseFrames(%StackPointer %stackPointer_96)
        ret void
}



define tailcc void @returnAddress_109(%Pos %v_r_2520_9_10_22_4641, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %tag_110 = extractvalue %Pos %v_r_2520_9_10_22_4641, 0
        %fields_111 = extractvalue %Pos %v_r_2520_9_10_22_4641, 1
        switch i64 %tag_110, label %label_112 []
    
    label_112:
        
        ret void
}



define tailcc void @choice_worker_6_7_17_4702(i64 %n_7_8_18_4688, %Prompt %p_4_4684, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4871 = add i64 1, 0
        
        %pureApp_4870 = call ccc %Pos @infixLt_178(i64 %n_7_8_18_4688, i64 %longLiteral_4871)
        
        
        
        %tag_28 = extractvalue %Pos %pureApp_4870, 0
        %fields_29 = extractvalue %Pos %pureApp_4870, 1
        switch i64 %tag_28, label %label_30 [i64 0, label %label_108 i64 1, label %label_122]
    
    label_30:
        
        ret void
    
    label_108:
        %stackPointer_55 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %n_7_8_18_4688_pointer_56 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_55, i64 0, i32 0
        store i64 %n_7_8_18_4688, ptr %n_7_8_18_4688_pointer_56, !noalias !2
        %p_4_4684_pointer_57 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_55, i64 0, i32 1
        store %Prompt %p_4_4684, ptr %p_4_4684_pointer_57, !noalias !2
        %returnAddress_pointer_58 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_55, i64 0, i32 1, i32 0
        %sharer_pointer_59 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_55, i64 0, i32 1, i32 1
        %eraser_pointer_60 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_55, i64 0, i32 1, i32 2
        store ptr @returnAddress_31, ptr %returnAddress_pointer_58, !noalias !2
        store ptr @sharer_45, ptr %sharer_pointer_59, !noalias !2
        store ptr @eraser_51, ptr %eraser_pointer_60, !noalias !2
        
        %pair_61 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_4684)
        %k_2_24_4698 = extractvalue <{%Resumption, %Stack}> %pair_61, 0
        %stack_62 = extractvalue <{%Resumption, %Stack}> %pair_61, 1
        call ccc void @shareResumption(%Resumption %k_2_24_4698)
        %stackPointer_98 = call ccc %StackPointer @stackAllocate(%Stack %stack_62, i64 32)
        %k_2_24_4698_pointer_99 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_98, i64 0, i32 0
        store %Resumption %k_2_24_4698, ptr %k_2_24_4698_pointer_99, !noalias !2
        %returnAddress_pointer_100 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_98, i64 0, i32 1, i32 0
        %sharer_pointer_101 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_98, i64 0, i32 1, i32 1
        %eraser_pointer_102 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_98, i64 0, i32 1, i32 2
        store ptr @returnAddress_63, ptr %returnAddress_pointer_100, !noalias !2
        store ptr @sharer_91, ptr %sharer_pointer_101, !noalias !2
        store ptr @eraser_95, ptr %eraser_pointer_102, !noalias !2
        
        %stack_103 = call ccc %Stack @resume(%Resumption %k_2_24_4698, %Stack %stack_62)
        
        %booleanLiteral_4878_temporary_104 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4878 = insertvalue %Pos %booleanLiteral_4878_temporary_104, %Object null, 1
        
        %stackPointer_106 = call ccc %StackPointer @stackDeallocate(%Stack %stack_103, i64 24)
        %returnAddress_pointer_107 = getelementptr %FrameHeader, %StackPointer %stackPointer_106, i64 0, i32 0
        %returnAddress_105 = load %ReturnAddress, ptr %returnAddress_pointer_107, !noalias !2
        musttail call tailcc void %returnAddress_105(%Pos %booleanLiteral_4878, %Stack %stack_103)
        ret void
    
    label_122:
        %stackPointer_113 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_114 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_113, i64 0, i32 1, i32 0
        %sharer_pointer_115 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_113, i64 0, i32 1, i32 1
        %eraser_pointer_116 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_113, i64 0, i32 1, i32 2
        store ptr @returnAddress_109, ptr %returnAddress_pointer_114, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_115, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_116, !noalias !2
        
        %pair_117 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_4684)
        %k_2_21_4879 = extractvalue <{%Resumption, %Stack}> %pair_117, 0
        %stack_118 = extractvalue <{%Resumption, %Stack}> %pair_117, 1
        call ccc void @eraseResumption(%Resumption %k_2_21_4879)
        
        %longLiteral_4880 = add i64 0, 0
        
        %stackPointer_120 = call ccc %StackPointer @stackDeallocate(%Stack %stack_118, i64 24)
        %returnAddress_pointer_121 = getelementptr %FrameHeader, %StackPointer %stackPointer_120, i64 0, i32 0
        %returnAddress_119 = load %ReturnAddress, ptr %returnAddress_pointer_121, !noalias !2
        musttail call tailcc void %returnAddress_119(i64 %longLiteral_4880, %Stack %stack_118)
        ret void
}



define tailcc void @returnAddress_130(%Pos %v_r_2522_10_19_49_4654, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_131 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %n_7_16_36_4635_pointer_132 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_131, i64 0, i32 0
        %n_7_16_36_4635 = load i64, ptr %n_7_16_36_4635_pointer_132, !noalias !2
        %p_4_4684_pointer_133 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_131, i64 0, i32 1
        %p_4_4684 = load %Prompt, ptr %p_4_4684_pointer_133, !noalias !2
        
        %tag_134 = extractvalue %Pos %v_r_2522_10_19_49_4654, 0
        %fields_135 = extractvalue %Pos %v_r_2522_10_19_49_4654, 1
        switch i64 %tag_134, label %label_136 [i64 0, label %label_137 i64 1, label %label_141]
    
    label_136:
        
        ret void
    
    label_137:
        
        %longLiteral_4886 = add i64 1, 0
        
        %pureApp_4885 = call ccc i64 @infixSub_105(i64 %n_7_16_36_4635, i64 %longLiteral_4886)
        
        
        
        
        
        musttail call tailcc void @choice_worker_6_15_35_4627(i64 %pureApp_4885, %Prompt %p_4_4684, %Stack %stack)
        ret void
    
    label_141:
        
        %stackPointer_139 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_140 = getelementptr %FrameHeader, %StackPointer %stackPointer_139, i64 0, i32 0
        %returnAddress_138 = load %ReturnAddress, ptr %returnAddress_pointer_140, !noalias !2
        musttail call tailcc void %returnAddress_138(i64 %n_7_16_36_4635, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_157(i64 %v_r_2544_6_46_4670, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_158 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2543_5_45_4632_pointer_159 = getelementptr <{i64}>, %StackPointer %stackPointer_158, i64 0, i32 0
        %v_r_2543_5_45_4632 = load i64, ptr %v_r_2543_5_45_4632_pointer_159, !noalias !2
        
        %pureApp_4887 = call ccc i64 @infixAdd_96(i64 %v_r_2543_5_45_4632, i64 %v_r_2544_6_46_4670)
        
        
        
        %longLiteral_4889 = add i64 1000000007, 0
        
        %pureApp_4888 = call ccc i64 @mod_108(i64 %pureApp_4887, i64 %longLiteral_4889)
        
        
        
        %stackPointer_161 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_162 = getelementptr %FrameHeader, %StackPointer %stackPointer_161, i64 0, i32 0
        %returnAddress_160 = load %ReturnAddress, ptr %returnAddress_pointer_162, !noalias !2
        musttail call tailcc void %returnAddress_160(i64 %pureApp_4888, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_154(i64 %v_r_2543_5_45_4632, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_155 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %k_2_42_4669_pointer_156 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_155, i64 0, i32 0
        %k_2_42_4669 = load %Resumption, ptr %k_2_42_4669_pointer_156, !noalias !2
        %stackPointer_165 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2543_5_45_4632_pointer_166 = getelementptr <{i64}>, %StackPointer %stackPointer_165, i64 0, i32 0
        store i64 %v_r_2543_5_45_4632, ptr %v_r_2543_5_45_4632_pointer_166, !noalias !2
        %returnAddress_pointer_167 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_165, i64 0, i32 1, i32 0
        %sharer_pointer_168 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_165, i64 0, i32 1, i32 1
        %eraser_pointer_169 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_165, i64 0, i32 1, i32 2
        store ptr @returnAddress_157, ptr %returnAddress_pointer_167, !noalias !2
        store ptr @sharer_73, ptr %sharer_pointer_168, !noalias !2
        store ptr @eraser_77, ptr %eraser_pointer_169, !noalias !2
        
        %stack_170 = call ccc %Stack @resume(%Resumption %k_2_42_4669, %Stack %stack)
        
        %booleanLiteral_4890_temporary_171 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_4890 = insertvalue %Pos %booleanLiteral_4890_temporary_171, %Object null, 1
        
        %stackPointer_173 = call ccc %StackPointer @stackDeallocate(%Stack %stack_170, i64 24)
        %returnAddress_pointer_174 = getelementptr %FrameHeader, %StackPointer %stackPointer_173, i64 0, i32 0
        %returnAddress_172 = load %ReturnAddress, ptr %returnAddress_pointer_174, !noalias !2
        musttail call tailcc void %returnAddress_172(%Pos %booleanLiteral_4890, %Stack %stack_170)
        ret void
}



define tailcc void @returnAddress_188(%Pos %v_r_2520_9_18_40_4695, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %tag_189 = extractvalue %Pos %v_r_2520_9_18_40_4695, 0
        %fields_190 = extractvalue %Pos %v_r_2520_9_18_40_4695, 1
        switch i64 %tag_189, label %label_191 []
    
    label_191:
        
        ret void
}



define tailcc void @choice_worker_6_15_35_4627(i64 %n_7_16_36_4635, %Prompt %p_4_4684, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4884 = add i64 1, 0
        
        %pureApp_4883 = call ccc %Pos @infixLt_178(i64 %n_7_16_36_4635, i64 %longLiteral_4884)
        
        
        
        %tag_127 = extractvalue %Pos %pureApp_4883, 0
        %fields_128 = extractvalue %Pos %pureApp_4883, 1
        switch i64 %tag_127, label %label_129 [i64 0, label %label_187 i64 1, label %label_201]
    
    label_129:
        
        ret void
    
    label_187:
        %stackPointer_146 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %n_7_16_36_4635_pointer_147 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_146, i64 0, i32 0
        store i64 %n_7_16_36_4635, ptr %n_7_16_36_4635_pointer_147, !noalias !2
        %p_4_4684_pointer_148 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_146, i64 0, i32 1
        store %Prompt %p_4_4684, ptr %p_4_4684_pointer_148, !noalias !2
        %returnAddress_pointer_149 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 0
        %sharer_pointer_150 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 1
        %eraser_pointer_151 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 2
        store ptr @returnAddress_130, ptr %returnAddress_pointer_149, !noalias !2
        store ptr @sharer_45, ptr %sharer_pointer_150, !noalias !2
        store ptr @eraser_51, ptr %eraser_pointer_151, !noalias !2
        
        %pair_152 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_4684)
        %k_2_42_4669 = extractvalue <{%Resumption, %Stack}> %pair_152, 0
        %stack_153 = extractvalue <{%Resumption, %Stack}> %pair_152, 1
        call ccc void @shareResumption(%Resumption %k_2_42_4669)
        %stackPointer_177 = call ccc %StackPointer @stackAllocate(%Stack %stack_153, i64 32)
        %k_2_42_4669_pointer_178 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_177, i64 0, i32 0
        store %Resumption %k_2_42_4669, ptr %k_2_42_4669_pointer_178, !noalias !2
        %returnAddress_pointer_179 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_177, i64 0, i32 1, i32 0
        %sharer_pointer_180 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_177, i64 0, i32 1, i32 1
        %eraser_pointer_181 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_177, i64 0, i32 1, i32 2
        store ptr @returnAddress_154, ptr %returnAddress_pointer_179, !noalias !2
        store ptr @sharer_91, ptr %sharer_pointer_180, !noalias !2
        store ptr @eraser_95, ptr %eraser_pointer_181, !noalias !2
        
        %stack_182 = call ccc %Stack @resume(%Resumption %k_2_42_4669, %Stack %stack_153)
        
        %booleanLiteral_4891_temporary_183 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4891 = insertvalue %Pos %booleanLiteral_4891_temporary_183, %Object null, 1
        
        %stackPointer_185 = call ccc %StackPointer @stackDeallocate(%Stack %stack_182, i64 24)
        %returnAddress_pointer_186 = getelementptr %FrameHeader, %StackPointer %stackPointer_185, i64 0, i32 0
        %returnAddress_184 = load %ReturnAddress, ptr %returnAddress_pointer_186, !noalias !2
        musttail call tailcc void %returnAddress_184(%Pos %booleanLiteral_4891, %Stack %stack_182)
        ret void
    
    label_201:
        %stackPointer_192 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_193 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_192, i64 0, i32 1, i32 0
        %sharer_pointer_194 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_192, i64 0, i32 1, i32 1
        %eraser_pointer_195 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_192, i64 0, i32 1, i32 2
        store ptr @returnAddress_188, ptr %returnAddress_pointer_193, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_194, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_195, !noalias !2
        
        %pair_196 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_4684)
        %k_2_39_4892 = extractvalue <{%Resumption, %Stack}> %pair_196, 0
        %stack_197 = extractvalue <{%Resumption, %Stack}> %pair_196, 1
        call ccc void @eraseResumption(%Resumption %k_2_39_4892)
        
        %longLiteral_4893 = add i64 0, 0
        
        %stackPointer_199 = call ccc %StackPointer @stackDeallocate(%Stack %stack_197, i64 24)
        %returnAddress_pointer_200 = getelementptr %FrameHeader, %StackPointer %stackPointer_199, i64 0, i32 0
        %returnAddress_198 = load %ReturnAddress, ptr %returnAddress_pointer_200, !noalias !2
        musttail call tailcc void %returnAddress_198(i64 %longLiteral_4893, %Stack %stack_197)
        ret void
}



define tailcc void @returnAddress_210(%Pos %v_r_2522_10_27_67_4683, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_211 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %n_7_24_54_4659_pointer_212 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_211, i64 0, i32 0
        %n_7_24_54_4659 = load i64, ptr %n_7_24_54_4659_pointer_212, !noalias !2
        %p_4_4684_pointer_213 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_211, i64 0, i32 1
        %p_4_4684 = load %Prompt, ptr %p_4_4684_pointer_213, !noalias !2
        
        %tag_214 = extractvalue %Pos %v_r_2522_10_27_67_4683, 0
        %fields_215 = extractvalue %Pos %v_r_2522_10_27_67_4683, 1
        switch i64 %tag_214, label %label_216 [i64 0, label %label_217 i64 1, label %label_221]
    
    label_216:
        
        ret void
    
    label_217:
        
        %longLiteral_4899 = add i64 1, 0
        
        %pureApp_4898 = call ccc i64 @infixSub_105(i64 %n_7_24_54_4659, i64 %longLiteral_4899)
        
        
        
        
        
        musttail call tailcc void @choice_worker_6_23_53_4638(i64 %pureApp_4898, %Prompt %p_4_4684, %Stack %stack)
        ret void
    
    label_221:
        
        %stackPointer_219 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_220 = getelementptr %FrameHeader, %StackPointer %stackPointer_219, i64 0, i32 0
        %returnAddress_218 = load %ReturnAddress, ptr %returnAddress_pointer_220, !noalias !2
        musttail call tailcc void %returnAddress_218(i64 %n_7_24_54_4659, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_237(i64 %v_r_2544_6_64_4658, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_238 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %v_r_2543_5_63_4639_pointer_239 = getelementptr <{i64}>, %StackPointer %stackPointer_238, i64 0, i32 0
        %v_r_2543_5_63_4639 = load i64, ptr %v_r_2543_5_63_4639_pointer_239, !noalias !2
        
        %pureApp_4900 = call ccc i64 @infixAdd_96(i64 %v_r_2543_5_63_4639, i64 %v_r_2544_6_64_4658)
        
        
        
        %longLiteral_4902 = add i64 1000000007, 0
        
        %pureApp_4901 = call ccc i64 @mod_108(i64 %pureApp_4900, i64 %longLiteral_4902)
        
        
        
        %stackPointer_241 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_242 = getelementptr %FrameHeader, %StackPointer %stackPointer_241, i64 0, i32 0
        %returnAddress_240 = load %ReturnAddress, ptr %returnAddress_pointer_242, !noalias !2
        musttail call tailcc void %returnAddress_240(i64 %pureApp_4901, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_234(i64 %v_r_2543_5_63_4639, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_235 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %k_2_60_4622_pointer_236 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_235, i64 0, i32 0
        %k_2_60_4622 = load %Resumption, ptr %k_2_60_4622_pointer_236, !noalias !2
        %stackPointer_245 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %v_r_2543_5_63_4639_pointer_246 = getelementptr <{i64}>, %StackPointer %stackPointer_245, i64 0, i32 0
        store i64 %v_r_2543_5_63_4639, ptr %v_r_2543_5_63_4639_pointer_246, !noalias !2
        %returnAddress_pointer_247 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_245, i64 0, i32 1, i32 0
        %sharer_pointer_248 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_245, i64 0, i32 1, i32 1
        %eraser_pointer_249 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_245, i64 0, i32 1, i32 2
        store ptr @returnAddress_237, ptr %returnAddress_pointer_247, !noalias !2
        store ptr @sharer_73, ptr %sharer_pointer_248, !noalias !2
        store ptr @eraser_77, ptr %eraser_pointer_249, !noalias !2
        
        %stack_250 = call ccc %Stack @resume(%Resumption %k_2_60_4622, %Stack %stack)
        
        %booleanLiteral_4903_temporary_251 = insertvalue %Pos zeroinitializer, i64 0, 0
        %booleanLiteral_4903 = insertvalue %Pos %booleanLiteral_4903_temporary_251, %Object null, 1
        
        %stackPointer_253 = call ccc %StackPointer @stackDeallocate(%Stack %stack_250, i64 24)
        %returnAddress_pointer_254 = getelementptr %FrameHeader, %StackPointer %stackPointer_253, i64 0, i32 0
        %returnAddress_252 = load %ReturnAddress, ptr %returnAddress_pointer_254, !noalias !2
        musttail call tailcc void %returnAddress_252(%Pos %booleanLiteral_4903, %Stack %stack_250)
        ret void
}



define tailcc void @returnAddress_268(%Pos %v_r_2520_9_26_58_4679, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %tag_269 = extractvalue %Pos %v_r_2520_9_26_58_4679, 0
        %fields_270 = extractvalue %Pos %v_r_2520_9_26_58_4679, 1
        switch i64 %tag_269, label %label_271 []
    
    label_271:
        
        ret void
}



define tailcc void @choice_worker_6_23_53_4638(i64 %n_7_24_54_4659, %Prompt %p_4_4684, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4897 = add i64 1, 0
        
        %pureApp_4896 = call ccc %Pos @infixLt_178(i64 %n_7_24_54_4659, i64 %longLiteral_4897)
        
        
        
        %tag_207 = extractvalue %Pos %pureApp_4896, 0
        %fields_208 = extractvalue %Pos %pureApp_4896, 1
        switch i64 %tag_207, label %label_209 [i64 0, label %label_267 i64 1, label %label_281]
    
    label_209:
        
        ret void
    
    label_267:
        %stackPointer_226 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %n_7_24_54_4659_pointer_227 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_226, i64 0, i32 0
        store i64 %n_7_24_54_4659, ptr %n_7_24_54_4659_pointer_227, !noalias !2
        %p_4_4684_pointer_228 = getelementptr <{i64, %Prompt}>, %StackPointer %stackPointer_226, i64 0, i32 1
        store %Prompt %p_4_4684, ptr %p_4_4684_pointer_228, !noalias !2
        %returnAddress_pointer_229 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_226, i64 0, i32 1, i32 0
        %sharer_pointer_230 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_226, i64 0, i32 1, i32 1
        %eraser_pointer_231 = getelementptr <{<{i64, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_226, i64 0, i32 1, i32 2
        store ptr @returnAddress_210, ptr %returnAddress_pointer_229, !noalias !2
        store ptr @sharer_45, ptr %sharer_pointer_230, !noalias !2
        store ptr @eraser_51, ptr %eraser_pointer_231, !noalias !2
        
        %pair_232 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_4684)
        %k_2_60_4622 = extractvalue <{%Resumption, %Stack}> %pair_232, 0
        %stack_233 = extractvalue <{%Resumption, %Stack}> %pair_232, 1
        call ccc void @shareResumption(%Resumption %k_2_60_4622)
        %stackPointer_257 = call ccc %StackPointer @stackAllocate(%Stack %stack_233, i64 32)
        %k_2_60_4622_pointer_258 = getelementptr <{%Resumption}>, %StackPointer %stackPointer_257, i64 0, i32 0
        store %Resumption %k_2_60_4622, ptr %k_2_60_4622_pointer_258, !noalias !2
        %returnAddress_pointer_259 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_257, i64 0, i32 1, i32 0
        %sharer_pointer_260 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_257, i64 0, i32 1, i32 1
        %eraser_pointer_261 = getelementptr <{<{%Resumption}>, %FrameHeader}>, %StackPointer %stackPointer_257, i64 0, i32 1, i32 2
        store ptr @returnAddress_234, ptr %returnAddress_pointer_259, !noalias !2
        store ptr @sharer_91, ptr %sharer_pointer_260, !noalias !2
        store ptr @eraser_95, ptr %eraser_pointer_261, !noalias !2
        
        %stack_262 = call ccc %Stack @resume(%Resumption %k_2_60_4622, %Stack %stack_233)
        
        %booleanLiteral_4904_temporary_263 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4904 = insertvalue %Pos %booleanLiteral_4904_temporary_263, %Object null, 1
        
        %stackPointer_265 = call ccc %StackPointer @stackDeallocate(%Stack %stack_262, i64 24)
        %returnAddress_pointer_266 = getelementptr %FrameHeader, %StackPointer %stackPointer_265, i64 0, i32 0
        %returnAddress_264 = load %ReturnAddress, ptr %returnAddress_pointer_266, !noalias !2
        musttail call tailcc void %returnAddress_264(%Pos %booleanLiteral_4904, %Stack %stack_262)
        ret void
    
    label_281:
        %stackPointer_272 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_273 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_272, i64 0, i32 1, i32 0
        %sharer_pointer_274 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_272, i64 0, i32 1, i32 1
        %eraser_pointer_275 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_272, i64 0, i32 1, i32 2
        store ptr @returnAddress_268, ptr %returnAddress_pointer_273, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_274, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_275, !noalias !2
        
        %pair_276 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_4684)
        %k_2_57_4905 = extractvalue <{%Resumption, %Stack}> %pair_276, 0
        %stack_277 = extractvalue <{%Resumption, %Stack}> %pair_276, 1
        call ccc void @eraseResumption(%Resumption %k_2_57_4905)
        
        %longLiteral_4906 = add i64 0, 0
        
        %stackPointer_279 = call ccc %StackPointer @stackDeallocate(%Stack %stack_277, i64 24)
        %returnAddress_pointer_280 = getelementptr %FrameHeader, %StackPointer %stackPointer_279, i64 0, i32 0
        %returnAddress_278 = load %ReturnAddress, ptr %returnAddress_pointer_280, !noalias !2
        musttail call tailcc void %returnAddress_278(i64 %longLiteral_4906, %Stack %stack_277)
        ret void
}



define tailcc void @returnAddress_288(%Pos %v_r_2545_77_4662, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %tag_289 = extractvalue %Pos %v_r_2545_77_4662, 0
        %fields_290 = extractvalue %Pos %v_r_2545_77_4662, 1
        switch i64 %tag_289, label %label_291 [i64 0, label %label_299]
    
    label_291:
        
        ret void
    
    label_299:
        %environment_292 = call ccc %Environment @objectEnvironment(%Object %fields_290)
        %v_y_2533_12_88_4644_pointer_293 = getelementptr <{i64, i64, i64}>, %Environment %environment_292, i64 0, i32 0
        %v_y_2533_12_88_4644 = load i64, ptr %v_y_2533_12_88_4644_pointer_293, !noalias !2
        %v_y_2534_13_89_4700_pointer_294 = getelementptr <{i64, i64, i64}>, %Environment %environment_292, i64 0, i32 1
        %v_y_2534_13_89_4700 = load i64, ptr %v_y_2534_13_89_4700_pointer_294, !noalias !2
        %v_y_2535_14_90_4673_pointer_295 = getelementptr <{i64, i64, i64}>, %Environment %environment_292, i64 0, i32 2
        %v_y_2535_14_90_4673 = load i64, ptr %v_y_2535_14_90_4673_pointer_295, !noalias !2
        call ccc void @eraseObject(%Object %fields_290)
        
        %longLiteral_4911 = add i64 53, 0
        
        %pureApp_4910 = call ccc i64 @infixMul_99(i64 %longLiteral_4911, i64 %v_y_2533_12_88_4644)
        
        
        
        %longLiteral_4913 = add i64 2809, 0
        
        %pureApp_4912 = call ccc i64 @infixMul_99(i64 %longLiteral_4913, i64 %v_y_2534_13_89_4700)
        
        
        
        %pureApp_4914 = call ccc i64 @infixAdd_96(i64 %pureApp_4910, i64 %pureApp_4912)
        
        
        
        %longLiteral_4916 = add i64 148877, 0
        
        %pureApp_4915 = call ccc i64 @infixMul_99(i64 %longLiteral_4916, i64 %v_y_2535_14_90_4673)
        
        
        
        %pureApp_4917 = call ccc i64 @infixAdd_96(i64 %pureApp_4914, i64 %pureApp_4915)
        
        
        
        %longLiteral_4919 = add i64 1000000007, 0
        
        %pureApp_4918 = call ccc i64 @mod_108(i64 %pureApp_4917, i64 %longLiteral_4919)
        
        
        
        %stackPointer_297 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_298 = getelementptr %FrameHeader, %StackPointer %stackPointer_297, i64 0, i32 0
        %returnAddress_296 = load %ReturnAddress, ptr %returnAddress_pointer_298, !noalias !2
        musttail call tailcc void %returnAddress_296(i64 %pureApp_4918, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_307(%Pos %v_r_2529_34_76_4663, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %tag_308 = extractvalue %Pos %v_r_2529_34_76_4663, 0
        %fields_309 = extractvalue %Pos %v_r_2529_34_76_4663, 1
        switch i64 %tag_308, label %label_310 []
    
    label_310:
        
        ret void
}



define ccc void @eraser_326(%Environment %environment) {
        
    entry:
        
        %i_13_33_4677_323_pointer_327 = getelementptr <{i64, i64, i64}>, %Environment %environment, i64 0, i32 0
        %i_13_33_4677_323 = load i64, ptr %i_13_33_4677_323_pointer_327, !noalias !2
        %j_21_51_4672_324_pointer_328 = getelementptr <{i64, i64, i64}>, %Environment %environment, i64 0, i32 1
        %j_21_51_4672_324 = load i64, ptr %j_21_51_4672_324_pointer_328, !noalias !2
        %k_29_69_4646_325_pointer_329 = getelementptr <{i64, i64, i64}>, %Environment %environment, i64 0, i32 2
        %k_29_69_4646_325 = load i64, ptr %k_29_69_4646_325_pointer_329, !noalias !2
        ret void
}



define tailcc void @returnAddress_282(i64 %k_29_69_4646, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_283 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %j_21_51_4672_pointer_284 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_283, i64 0, i32 0
        %j_21_51_4672 = load i64, ptr %j_21_51_4672_pointer_284, !noalias !2
        %p_4_4684_pointer_285 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_283, i64 0, i32 1
        %p_4_4684 = load %Prompt, ptr %p_4_4684_pointer_285, !noalias !2
        %i_13_33_4677_pointer_286 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_283, i64 0, i32 2
        %i_13_33_4677 = load i64, ptr %i_13_33_4677_pointer_286, !noalias !2
        %tmp_4850_pointer_287 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_283, i64 0, i32 3
        %tmp_4850 = load i64, ptr %tmp_4850_pointer_287, !noalias !2
        
        %pureApp_4907 = call ccc i64 @infixAdd_96(i64 %i_13_33_4677, i64 %j_21_51_4672)
        
        
        
        %pureApp_4908 = call ccc i64 @infixAdd_96(i64 %pureApp_4907, i64 %k_29_69_4646)
        
        
        
        %pureApp_4909 = call ccc %Pos @infixEq_72(i64 %pureApp_4908, i64 %tmp_4850)
        
        
        %stackPointer_300 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_301 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_300, i64 0, i32 1, i32 0
        %sharer_pointer_302 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_300, i64 0, i32 1, i32 1
        %eraser_pointer_303 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_300, i64 0, i32 1, i32 2
        store ptr @returnAddress_288, ptr %returnAddress_pointer_301, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_302, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_303, !noalias !2
        
        %tag_304 = extractvalue %Pos %pureApp_4909, 0
        %fields_305 = extractvalue %Pos %pureApp_4909, 1
        switch i64 %tag_304, label %label_306 [i64 0, label %label_320 i64 1, label %label_337]
    
    label_306:
        
        ret void
    
    label_320:
        %stackPointer_311 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_312 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_311, i64 0, i32 1, i32 0
        %sharer_pointer_313 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_311, i64 0, i32 1, i32 1
        %eraser_pointer_314 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_311, i64 0, i32 1, i32 2
        store ptr @returnAddress_307, ptr %returnAddress_pointer_312, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_313, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_314, !noalias !2
        
        %pair_315 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_4_4684)
        %k_2_75_4920 = extractvalue <{%Resumption, %Stack}> %pair_315, 0
        %stack_316 = extractvalue <{%Resumption, %Stack}> %pair_315, 1
        call ccc void @eraseResumption(%Resumption %k_2_75_4920)
        
        %longLiteral_4921 = add i64 0, 0
        
        %stackPointer_318 = call ccc %StackPointer @stackDeallocate(%Stack %stack_316, i64 24)
        %returnAddress_pointer_319 = getelementptr %FrameHeader, %StackPointer %stackPointer_318, i64 0, i32 0
        %returnAddress_317 = load %ReturnAddress, ptr %returnAddress_pointer_319, !noalias !2
        musttail call tailcc void %returnAddress_317(i64 %longLiteral_4921, %Stack %stack_316)
        ret void
    
    label_337:
        
        %fields_321 = call ccc %Object @newObject(ptr @eraser_326, i64 24)
        %environment_322 = call ccc %Environment @objectEnvironment(%Object %fields_321)
        %i_13_33_4677_pointer_330 = getelementptr <{i64, i64, i64}>, %Environment %environment_322, i64 0, i32 0
        store i64 %i_13_33_4677, ptr %i_13_33_4677_pointer_330, !noalias !2
        %j_21_51_4672_pointer_331 = getelementptr <{i64, i64, i64}>, %Environment %environment_322, i64 0, i32 1
        store i64 %j_21_51_4672, ptr %j_21_51_4672_pointer_331, !noalias !2
        %k_29_69_4646_pointer_332 = getelementptr <{i64, i64, i64}>, %Environment %environment_322, i64 0, i32 2
        store i64 %k_29_69_4646, ptr %k_29_69_4646_pointer_332, !noalias !2
        %make_4922_temporary_333 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4922 = insertvalue %Pos %make_4922_temporary_333, %Object %fields_321, 1
        
        
        
        %stackPointer_335 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_336 = getelementptr %FrameHeader, %StackPointer %stackPointer_335, i64 0, i32 0
        %returnAddress_334 = load %ReturnAddress, ptr %returnAddress_pointer_336, !noalias !2
        musttail call tailcc void %returnAddress_334(%Pos %make_4922, %Stack %stack)
        ret void
}



define ccc void @sharer_342(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_343 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %j_21_51_4672_338_pointer_344 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_343, i64 0, i32 0
        %j_21_51_4672_338 = load i64, ptr %j_21_51_4672_338_pointer_344, !noalias !2
        %p_4_4684_339_pointer_345 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_343, i64 0, i32 1
        %p_4_4684_339 = load %Prompt, ptr %p_4_4684_339_pointer_345, !noalias !2
        %i_13_33_4677_340_pointer_346 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_343, i64 0, i32 2
        %i_13_33_4677_340 = load i64, ptr %i_13_33_4677_340_pointer_346, !noalias !2
        %tmp_4850_341_pointer_347 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_343, i64 0, i32 3
        %tmp_4850_341 = load i64, ptr %tmp_4850_341_pointer_347, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_343)
        ret void
}



define ccc void @eraser_352(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_353 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %j_21_51_4672_348_pointer_354 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_353, i64 0, i32 0
        %j_21_51_4672_348 = load i64, ptr %j_21_51_4672_348_pointer_354, !noalias !2
        %p_4_4684_349_pointer_355 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_353, i64 0, i32 1
        %p_4_4684_349 = load %Prompt, ptr %p_4_4684_349_pointer_355, !noalias !2
        %i_13_33_4677_350_pointer_356 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_353, i64 0, i32 2
        %i_13_33_4677_350 = load i64, ptr %i_13_33_4677_350_pointer_356, !noalias !2
        %tmp_4850_351_pointer_357 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_353, i64 0, i32 3
        %tmp_4850_351 = load i64, ptr %tmp_4850_351_pointer_357, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_353)
        ret void
}



define tailcc void @returnAddress_202(i64 %j_21_51_4672, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_203 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %p_4_4684_pointer_204 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_203, i64 0, i32 0
        %p_4_4684 = load %Prompt, ptr %p_4_4684_pointer_204, !noalias !2
        %i_13_33_4677_pointer_205 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_203, i64 0, i32 1
        %i_13_33_4677 = load i64, ptr %i_13_33_4677_pointer_205, !noalias !2
        %tmp_4850_pointer_206 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_203, i64 0, i32 2
        %tmp_4850 = load i64, ptr %tmp_4850_pointer_206, !noalias !2
        
        %longLiteral_4895 = add i64 1, 0
        
        %pureApp_4894 = call ccc i64 @infixSub_105(i64 %j_21_51_4672, i64 %longLiteral_4895)
        
        
        %stackPointer_358 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %j_21_51_4672_pointer_359 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_358, i64 0, i32 0
        store i64 %j_21_51_4672, ptr %j_21_51_4672_pointer_359, !noalias !2
        %p_4_4684_pointer_360 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_358, i64 0, i32 1
        store %Prompt %p_4_4684, ptr %p_4_4684_pointer_360, !noalias !2
        %i_13_33_4677_pointer_361 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_358, i64 0, i32 2
        store i64 %i_13_33_4677, ptr %i_13_33_4677_pointer_361, !noalias !2
        %tmp_4850_pointer_362 = getelementptr <{i64, %Prompt, i64, i64}>, %StackPointer %stackPointer_358, i64 0, i32 3
        store i64 %tmp_4850, ptr %tmp_4850_pointer_362, !noalias !2
        %returnAddress_pointer_363 = getelementptr <{<{i64, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_358, i64 0, i32 1, i32 0
        %sharer_pointer_364 = getelementptr <{<{i64, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_358, i64 0, i32 1, i32 1
        %eraser_pointer_365 = getelementptr <{<{i64, %Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_358, i64 0, i32 1, i32 2
        store ptr @returnAddress_282, ptr %returnAddress_pointer_363, !noalias !2
        store ptr @sharer_342, ptr %sharer_pointer_364, !noalias !2
        store ptr @eraser_352, ptr %eraser_pointer_365, !noalias !2
        
        
        
        musttail call tailcc void @choice_worker_6_23_53_4638(i64 %pureApp_4894, %Prompt %p_4_4684, %Stack %stack)
        ret void
}



define ccc void @sharer_369(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_370 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %p_4_4684_366_pointer_371 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_370, i64 0, i32 0
        %p_4_4684_366 = load %Prompt, ptr %p_4_4684_366_pointer_371, !noalias !2
        %i_13_33_4677_367_pointer_372 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_370, i64 0, i32 1
        %i_13_33_4677_367 = load i64, ptr %i_13_33_4677_367_pointer_372, !noalias !2
        %tmp_4850_368_pointer_373 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_370, i64 0, i32 2
        %tmp_4850_368 = load i64, ptr %tmp_4850_368_pointer_373, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_370)
        ret void
}



define ccc void @eraser_377(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_378 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer, i64 -1
        %p_4_4684_374_pointer_379 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_378, i64 0, i32 0
        %p_4_4684_374 = load %Prompt, ptr %p_4_4684_374_pointer_379, !noalias !2
        %i_13_33_4677_375_pointer_380 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_378, i64 0, i32 1
        %i_13_33_4677_375 = load i64, ptr %i_13_33_4677_375_pointer_380, !noalias !2
        %tmp_4850_376_pointer_381 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_378, i64 0, i32 2
        %tmp_4850_376 = load i64, ptr %tmp_4850_376_pointer_381, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_378)
        ret void
}



define tailcc void @returnAddress_123(i64 %i_13_33_4677, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_124 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %p_4_4684_pointer_125 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_124, i64 0, i32 0
        %p_4_4684 = load %Prompt, ptr %p_4_4684_pointer_125, !noalias !2
        %tmp_4850_pointer_126 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_124, i64 0, i32 1
        %tmp_4850 = load i64, ptr %tmp_4850_pointer_126, !noalias !2
        
        %longLiteral_4882 = add i64 1, 0
        
        %pureApp_4881 = call ccc i64 @infixSub_105(i64 %i_13_33_4677, i64 %longLiteral_4882)
        
        
        %stackPointer_382 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 48)
        %p_4_4684_pointer_383 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_382, i64 0, i32 0
        store %Prompt %p_4_4684, ptr %p_4_4684_pointer_383, !noalias !2
        %i_13_33_4677_pointer_384 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_382, i64 0, i32 1
        store i64 %i_13_33_4677, ptr %i_13_33_4677_pointer_384, !noalias !2
        %tmp_4850_pointer_385 = getelementptr <{%Prompt, i64, i64}>, %StackPointer %stackPointer_382, i64 0, i32 2
        store i64 %tmp_4850, ptr %tmp_4850_pointer_385, !noalias !2
        %returnAddress_pointer_386 = getelementptr <{<{%Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_382, i64 0, i32 1, i32 0
        %sharer_pointer_387 = getelementptr <{<{%Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_382, i64 0, i32 1, i32 1
        %eraser_pointer_388 = getelementptr <{<{%Prompt, i64, i64}>, %FrameHeader}>, %StackPointer %stackPointer_382, i64 0, i32 1, i32 2
        store ptr @returnAddress_202, ptr %returnAddress_pointer_386, !noalias !2
        store ptr @sharer_369, ptr %sharer_pointer_387, !noalias !2
        store ptr @eraser_377, ptr %eraser_pointer_388, !noalias !2
        
        
        
        musttail call tailcc void @choice_worker_6_15_35_4627(i64 %pureApp_4881, %Prompt %p_4_4684, %Stack %stack)
        ret void
}



define ccc void @sharer_391(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_392 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %p_4_4684_389_pointer_393 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_392, i64 0, i32 0
        %p_4_4684_389 = load %Prompt, ptr %p_4_4684_389_pointer_393, !noalias !2
        %tmp_4850_390_pointer_394 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_392, i64 0, i32 1
        %tmp_4850_390 = load i64, ptr %tmp_4850_390_pointer_394, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_392)
        ret void
}



define ccc void @eraser_397(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_398 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer, i64 -1
        %p_4_4684_395_pointer_399 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_398, i64 0, i32 0
        %p_4_4684_395 = load %Prompt, ptr %p_4_4684_395_pointer_399, !noalias !2
        %tmp_4850_396_pointer_400 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_398, i64 0, i32 1
        %tmp_4850_396 = load i64, ptr %tmp_4850_396_pointer_400, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_398)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3477_3541, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4866 = call ccc i64 @unboxInt_303(%Pos %v_coe_3477_3541)
        
        
        %stackPointer_10 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_11 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 0
        %sharer_pointer_12 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 1
        %eraser_pointer_13 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_10, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_11, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_12, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_13, !noalias !2
        
        %stack_14 = call ccc %Stack @reset(%Stack %stack)
        %p_4_4684 = call ccc %Prompt @currentPrompt(%Stack %stack_14)
        %stackPointer_24 = call ccc %StackPointer @stackAllocate(%Stack %stack_14, i64 24)
        %returnAddress_pointer_25 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 0
        %sharer_pointer_26 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 1
        %eraser_pointer_27 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_24, i64 0, i32 1, i32 2
        store ptr @returnAddress_15, ptr %returnAddress_pointer_25, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_26, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_27, !noalias !2
        %stackPointer_401 = call ccc %StackPointer @stackAllocate(%Stack %stack_14, i64 40)
        %p_4_4684_pointer_402 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_401, i64 0, i32 0
        store %Prompt %p_4_4684, ptr %p_4_4684_pointer_402, !noalias !2
        %tmp_4850_pointer_403 = getelementptr <{%Prompt, i64}>, %StackPointer %stackPointer_401, i64 0, i32 1
        store i64 %pureApp_4866, ptr %tmp_4850_pointer_403, !noalias !2
        %returnAddress_pointer_404 = getelementptr <{<{%Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_401, i64 0, i32 1, i32 0
        %sharer_pointer_405 = getelementptr <{<{%Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_401, i64 0, i32 1, i32 1
        %eraser_pointer_406 = getelementptr <{<{%Prompt, i64}>, %FrameHeader}>, %StackPointer %stackPointer_401, i64 0, i32 1, i32 2
        store ptr @returnAddress_123, ptr %returnAddress_pointer_404, !noalias !2
        store ptr @sharer_391, ptr %sharer_pointer_405, !noalias !2
        store ptr @eraser_397, ptr %eraser_pointer_406, !noalias !2
        
        
        
        musttail call tailcc void @choice_worker_6_7_17_4702(i64 %pureApp_4866, %Prompt %p_4_4684, %Stack %stack_14)
        ret void
}



define tailcc void @returnAddress_412(%Pos %returned_4923, %Stack %stack) {
        
    entry:
        
        %stack_413 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_415 = call ccc %StackPointer @stackDeallocate(%Stack %stack_413, i64 24)
        %returnAddress_pointer_416 = getelementptr %FrameHeader, %StackPointer %stackPointer_415, i64 0, i32 0
        %returnAddress_414 = load %ReturnAddress, ptr %returnAddress_pointer_416, !noalias !2
        musttail call tailcc void %returnAddress_414(%Pos %returned_4923, %Stack %stack_413)
        ret void
}



define ccc void @eraser_428(%Environment %environment) {
        
    entry:
        
        %tmp_4794_426_pointer_429 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4794_426 = load %Pos, ptr %tmp_4794_426_pointer_429, !noalias !2
        %acc_3_3_5_169_4445_427_pointer_430 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_169_4445_427 = load %Pos, ptr %acc_3_3_5_169_4445_427_pointer_430, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4794_426)
        call ccc void @erasePositive(%Pos %acc_3_3_5_169_4445_427)
        ret void
}



define tailcc void @toList_1_1_3_167_4539(i64 %start_2_2_4_168_4370, %Pos %acc_3_3_5_169_4445, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4925 = add i64 1, 0
        
        %pureApp_4924 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_168_4370, i64 %longLiteral_4925)
        
        
        
        %tag_421 = extractvalue %Pos %pureApp_4924, 0
        %fields_422 = extractvalue %Pos %pureApp_4924, 1
        switch i64 %tag_421, label %label_423 [i64 0, label %label_434 i64 1, label %label_438]
    
    label_423:
        
        ret void
    
    label_434:
        
        %pureApp_4926 = call ccc %Pos @argument_2385(i64 %start_2_2_4_168_4370)
        
        
        
        %longLiteral_4928 = add i64 1, 0
        
        %pureApp_4927 = call ccc i64 @infixSub_105(i64 %start_2_2_4_168_4370, i64 %longLiteral_4928)
        
        
        
        %fields_424 = call ccc %Object @newObject(ptr @eraser_428, i64 32)
        %environment_425 = call ccc %Environment @objectEnvironment(%Object %fields_424)
        %tmp_4794_pointer_431 = getelementptr <{%Pos, %Pos}>, %Environment %environment_425, i64 0, i32 0
        store %Pos %pureApp_4926, ptr %tmp_4794_pointer_431, !noalias !2
        %acc_3_3_5_169_4445_pointer_432 = getelementptr <{%Pos, %Pos}>, %Environment %environment_425, i64 0, i32 1
        store %Pos %acc_3_3_5_169_4445, ptr %acc_3_3_5_169_4445_pointer_432, !noalias !2
        %make_4929_temporary_433 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4929 = insertvalue %Pos %make_4929_temporary_433, %Object %fields_424, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4539(i64 %pureApp_4927, %Pos %make_4929, %Stack %stack)
        ret void
    
    label_438:
        
        %stackPointer_436 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_437 = getelementptr %FrameHeader, %StackPointer %stackPointer_436, i64 0, i32 0
        %returnAddress_435 = load %ReturnAddress, ptr %returnAddress_pointer_437, !noalias !2
        musttail call tailcc void %returnAddress_435(%Pos %acc_3_3_5_169_4445, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_449(%Pos %v_r_2636_32_59_223_4351, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_450 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 48)
        %index_7_34_198_4430_pointer_451 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_450, i64 0, i32 0
        %index_7_34_198_4430 = load i64, ptr %index_7_34_198_4430_pointer_451, !noalias !2
        %p_8_9_4242_pointer_452 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_450, i64 0, i32 1
        %p_8_9_4242 = load %Prompt, ptr %p_8_9_4242_pointer_452, !noalias !2
        %tmp_4801_pointer_453 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_450, i64 0, i32 2
        %tmp_4801 = load i64, ptr %tmp_4801_pointer_453, !noalias !2
        %acc_8_35_199_4513_pointer_454 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_450, i64 0, i32 3
        %acc_8_35_199_4513 = load i64, ptr %acc_8_35_199_4513_pointer_454, !noalias !2
        %v_r_2552_30_194_4420_pointer_455 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_450, i64 0, i32 4
        %v_r_2552_30_194_4420 = load %Pos, ptr %v_r_2552_30_194_4420_pointer_455, !noalias !2
        
        %tag_456 = extractvalue %Pos %v_r_2636_32_59_223_4351, 0
        %fields_457 = extractvalue %Pos %v_r_2636_32_59_223_4351, 1
        switch i64 %tag_456, label %label_458 [i64 1, label %label_481 i64 0, label %label_488]
    
    label_458:
        
        ret void
    
    label_463:
        
        ret void
    
    label_469:
        call ccc void @erasePositive(%Pos %v_r_2552_30_194_4420)
        
        %pair_464 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4242)
        %k_13_14_4_4707 = extractvalue <{%Resumption, %Stack}> %pair_464, 0
        %stack_465 = extractvalue <{%Resumption, %Stack}> %pair_464, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4707)
        
        %longLiteral_4941 = add i64 5, 0
        
        
        
        %pureApp_4942 = call ccc %Pos @boxInt_301(i64 %longLiteral_4941)
        
        
        
        %stackPointer_467 = call ccc %StackPointer @stackDeallocate(%Stack %stack_465, i64 24)
        %returnAddress_pointer_468 = getelementptr %FrameHeader, %StackPointer %stackPointer_467, i64 0, i32 0
        %returnAddress_466 = load %ReturnAddress, ptr %returnAddress_pointer_468, !noalias !2
        musttail call tailcc void %returnAddress_466(%Pos %pureApp_4942, %Stack %stack_465)
        ret void
    
    label_472:
        
        ret void
    
    label_478:
        call ccc void @erasePositive(%Pos %v_r_2552_30_194_4420)
        
        %pair_473 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4242)
        %k_13_14_4_4706 = extractvalue <{%Resumption, %Stack}> %pair_473, 0
        %stack_474 = extractvalue <{%Resumption, %Stack}> %pair_473, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4706)
        
        %longLiteral_4945 = add i64 5, 0
        
        
        
        %pureApp_4946 = call ccc %Pos @boxInt_301(i64 %longLiteral_4945)
        
        
        
        %stackPointer_476 = call ccc %StackPointer @stackDeallocate(%Stack %stack_474, i64 24)
        %returnAddress_pointer_477 = getelementptr %FrameHeader, %StackPointer %stackPointer_476, i64 0, i32 0
        %returnAddress_475 = load %ReturnAddress, ptr %returnAddress_pointer_477, !noalias !2
        musttail call tailcc void %returnAddress_475(%Pos %pureApp_4946, %Stack %stack_474)
        ret void
    
    label_479:
        
        %longLiteral_4948 = add i64 1, 0
        
        %pureApp_4947 = call ccc i64 @infixAdd_96(i64 %index_7_34_198_4430, i64 %longLiteral_4948)
        
        
        
        %longLiteral_4950 = add i64 10, 0
        
        %pureApp_4949 = call ccc i64 @infixMul_99(i64 %longLiteral_4950, i64 %acc_8_35_199_4513)
        
        
        
        %pureApp_4951 = call ccc i64 @toInt_2085(i64 %pureApp_4938)
        
        
        
        %pureApp_4952 = call ccc i64 @infixSub_105(i64 %pureApp_4951, i64 %tmp_4801)
        
        
        
        %pureApp_4953 = call ccc i64 @infixAdd_96(i64 %pureApp_4949, i64 %pureApp_4952)
        
        
        
        
        
        
        musttail call tailcc void @go_6_33_197_4441(i64 %pureApp_4947, i64 %pureApp_4953, %Prompt %p_8_9_4242, i64 %tmp_4801, %Pos %v_r_2552_30_194_4420, %Stack %stack)
        ret void
    
    label_480:
        
        %intLiteral_4944 = add i64 57, 0
        
        %pureApp_4943 = call ccc %Pos @infixLte_2093(i64 %pureApp_4938, i64 %intLiteral_4944)
        
        
        
        %tag_470 = extractvalue %Pos %pureApp_4943, 0
        %fields_471 = extractvalue %Pos %pureApp_4943, 1
        switch i64 %tag_470, label %label_472 [i64 0, label %label_478 i64 1, label %label_479]
    
    label_481:
        %environment_459 = call ccc %Environment @objectEnvironment(%Object %fields_457)
        %v_coe_3452_46_73_237_4408_pointer_460 = getelementptr <{%Pos}>, %Environment %environment_459, i64 0, i32 0
        %v_coe_3452_46_73_237_4408 = load %Pos, ptr %v_coe_3452_46_73_237_4408_pointer_460, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3452_46_73_237_4408)
        call ccc void @eraseObject(%Object %fields_457)
        
        %pureApp_4938 = call ccc i64 @unboxChar_313(%Pos %v_coe_3452_46_73_237_4408)
        
        
        
        %intLiteral_4940 = add i64 48, 0
        
        %pureApp_4939 = call ccc %Pos @infixGte_2099(i64 %pureApp_4938, i64 %intLiteral_4940)
        
        
        
        %tag_461 = extractvalue %Pos %pureApp_4939, 0
        %fields_462 = extractvalue %Pos %pureApp_4939, 1
        switch i64 %tag_461, label %label_463 [i64 0, label %label_469 i64 1, label %label_480]
    
    label_488:
        %environment_482 = call ccc %Environment @objectEnvironment(%Object %fields_457)
        %v_y_2643_76_103_267_4936_pointer_483 = getelementptr <{%Pos, %Pos}>, %Environment %environment_482, i64 0, i32 0
        %v_y_2643_76_103_267_4936 = load %Pos, ptr %v_y_2643_76_103_267_4936_pointer_483, !noalias !2
        %v_y_2644_77_104_268_4937_pointer_484 = getelementptr <{%Pos, %Pos}>, %Environment %environment_482, i64 0, i32 1
        %v_y_2644_77_104_268_4937 = load %Pos, ptr %v_y_2644_77_104_268_4937_pointer_484, !noalias !2
        call ccc void @eraseObject(%Object %fields_457)
        call ccc void @erasePositive(%Pos %v_r_2552_30_194_4420)
        
        %stackPointer_486 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_487 = getelementptr %FrameHeader, %StackPointer %stackPointer_486, i64 0, i32 0
        %returnAddress_485 = load %ReturnAddress, ptr %returnAddress_pointer_487, !noalias !2
        musttail call tailcc void %returnAddress_485(i64 %acc_8_35_199_4513, %Stack %stack)
        ret void
}



define ccc void @sharer_494(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_495 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_4430_489_pointer_496 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_495, i64 0, i32 0
        %index_7_34_198_4430_489 = load i64, ptr %index_7_34_198_4430_489_pointer_496, !noalias !2
        %p_8_9_4242_490_pointer_497 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_495, i64 0, i32 1
        %p_8_9_4242_490 = load %Prompt, ptr %p_8_9_4242_490_pointer_497, !noalias !2
        %tmp_4801_491_pointer_498 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_495, i64 0, i32 2
        %tmp_4801_491 = load i64, ptr %tmp_4801_491_pointer_498, !noalias !2
        %acc_8_35_199_4513_492_pointer_499 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_495, i64 0, i32 3
        %acc_8_35_199_4513_492 = load i64, ptr %acc_8_35_199_4513_492_pointer_499, !noalias !2
        %v_r_2552_30_194_4420_493_pointer_500 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_495, i64 0, i32 4
        %v_r_2552_30_194_4420_493 = load %Pos, ptr %v_r_2552_30_194_4420_493_pointer_500, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2552_30_194_4420_493)
        call ccc void @shareFrames(%StackPointer %stackPointer_495)
        ret void
}



define ccc void @eraser_506(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_507 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %index_7_34_198_4430_501_pointer_508 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_507, i64 0, i32 0
        %index_7_34_198_4430_501 = load i64, ptr %index_7_34_198_4430_501_pointer_508, !noalias !2
        %p_8_9_4242_502_pointer_509 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_507, i64 0, i32 1
        %p_8_9_4242_502 = load %Prompt, ptr %p_8_9_4242_502_pointer_509, !noalias !2
        %tmp_4801_503_pointer_510 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_507, i64 0, i32 2
        %tmp_4801_503 = load i64, ptr %tmp_4801_503_pointer_510, !noalias !2
        %acc_8_35_199_4513_504_pointer_511 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_507, i64 0, i32 3
        %acc_8_35_199_4513_504 = load i64, ptr %acc_8_35_199_4513_504_pointer_511, !noalias !2
        %v_r_2552_30_194_4420_505_pointer_512 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_507, i64 0, i32 4
        %v_r_2552_30_194_4420_505 = load %Pos, ptr %v_r_2552_30_194_4420_505_pointer_512, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2552_30_194_4420_505)
        call ccc void @eraseFrames(%StackPointer %stackPointer_507)
        ret void
}



define tailcc void @returnAddress_523(%Pos %returned_4954, %Stack %stack) {
        
    entry:
        
        %stack_524 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_526 = call ccc %StackPointer @stackDeallocate(%Stack %stack_524, i64 24)
        %returnAddress_pointer_527 = getelementptr %FrameHeader, %StackPointer %stackPointer_526, i64 0, i32 0
        %returnAddress_525 = load %ReturnAddress, ptr %returnAddress_pointer_527, !noalias !2
        musttail call tailcc void %returnAddress_525(%Pos %returned_4954, %Stack %stack_524)
        ret void
}



define tailcc void @Exception_7_19_46_210_4380_clause_532(%Object %closure, %Pos %exc_8_20_47_211_4317, %Pos %msg_9_21_48_212_4345, %Stack %stack) {
        
    entry:
        
        %environment_533 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_18_45_209_4530_pointer_534 = getelementptr <{%Prompt}>, %Environment %environment_533, i64 0, i32 0
        %p_6_18_45_209_4530 = load %Prompt, ptr %p_6_18_45_209_4530_pointer_534, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_535 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_18_45_209_4530)
        %k_11_23_50_214_4567 = extractvalue <{%Resumption, %Stack}> %pair_535, 0
        %stack_536 = extractvalue <{%Resumption, %Stack}> %pair_535, 1
        call ccc void @eraseResumption(%Resumption %k_11_23_50_214_4567)
        
        %fields_537 = call ccc %Object @newObject(ptr @eraser_428, i64 32)
        %environment_538 = call ccc %Environment @objectEnvironment(%Object %fields_537)
        %exc_8_20_47_211_4317_pointer_541 = getelementptr <{%Pos, %Pos}>, %Environment %environment_538, i64 0, i32 0
        store %Pos %exc_8_20_47_211_4317, ptr %exc_8_20_47_211_4317_pointer_541, !noalias !2
        %msg_9_21_48_212_4345_pointer_542 = getelementptr <{%Pos, %Pos}>, %Environment %environment_538, i64 0, i32 1
        store %Pos %msg_9_21_48_212_4345, ptr %msg_9_21_48_212_4345_pointer_542, !noalias !2
        %make_4955_temporary_543 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4955 = insertvalue %Pos %make_4955_temporary_543, %Object %fields_537, 1
        
        
        
        %stackPointer_545 = call ccc %StackPointer @stackDeallocate(%Stack %stack_536, i64 24)
        %returnAddress_pointer_546 = getelementptr %FrameHeader, %StackPointer %stackPointer_545, i64 0, i32 0
        %returnAddress_544 = load %ReturnAddress, ptr %returnAddress_pointer_546, !noalias !2
        musttail call tailcc void %returnAddress_544(%Pos %make_4955, %Stack %stack_536)
        ret void
}


@vtable_547 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4380_clause_532]


define ccc void @eraser_551(%Environment %environment) {
        
    entry:
        
        %p_6_18_45_209_4530_550_pointer_552 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_6_18_45_209_4530_550 = load %Prompt, ptr %p_6_18_45_209_4530_550_pointer_552, !noalias !2
        ret void
}



define ccc void @eraser_559(%Environment %environment) {
        
    entry:
        
        %tmp_4803_558_pointer_560 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4803_558 = load %Pos, ptr %tmp_4803_558_pointer_560, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4803_558)
        ret void
}



define tailcc void @returnAddress_555(i64 %v_coe_3451_6_28_55_219_4319, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4956 = call ccc %Pos @boxChar_311(i64 %v_coe_3451_6_28_55_219_4319)
        
        
        
        %fields_556 = call ccc %Object @newObject(ptr @eraser_559, i64 16)
        %environment_557 = call ccc %Environment @objectEnvironment(%Object %fields_556)
        %tmp_4803_pointer_561 = getelementptr <{%Pos}>, %Environment %environment_557, i64 0, i32 0
        store %Pos %pureApp_4956, ptr %tmp_4803_pointer_561, !noalias !2
        %make_4957_temporary_562 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4957 = insertvalue %Pos %make_4957_temporary_562, %Object %fields_556, 1
        
        
        
        %stackPointer_564 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_565 = getelementptr %FrameHeader, %StackPointer %stackPointer_564, i64 0, i32 0
        %returnAddress_563 = load %ReturnAddress, ptr %returnAddress_pointer_565, !noalias !2
        musttail call tailcc void %returnAddress_563(%Pos %make_4957, %Stack %stack)
        ret void
}



define tailcc void @go_6_33_197_4441(i64 %index_7_34_198_4430, i64 %acc_8_35_199_4513, %Prompt %p_8_9_4242, i64 %tmp_4801, %Pos %v_r_2552_30_194_4420, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %v_r_2552_30_194_4420)
        %stackPointer_513 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 72)
        %index_7_34_198_4430_pointer_514 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_513, i64 0, i32 0
        store i64 %index_7_34_198_4430, ptr %index_7_34_198_4430_pointer_514, !noalias !2
        %p_8_9_4242_pointer_515 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_513, i64 0, i32 1
        store %Prompt %p_8_9_4242, ptr %p_8_9_4242_pointer_515, !noalias !2
        %tmp_4801_pointer_516 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_513, i64 0, i32 2
        store i64 %tmp_4801, ptr %tmp_4801_pointer_516, !noalias !2
        %acc_8_35_199_4513_pointer_517 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_513, i64 0, i32 3
        store i64 %acc_8_35_199_4513, ptr %acc_8_35_199_4513_pointer_517, !noalias !2
        %v_r_2552_30_194_4420_pointer_518 = getelementptr <{i64, %Prompt, i64, i64, %Pos}>, %StackPointer %stackPointer_513, i64 0, i32 4
        store %Pos %v_r_2552_30_194_4420, ptr %v_r_2552_30_194_4420_pointer_518, !noalias !2
        %returnAddress_pointer_519 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_513, i64 0, i32 1, i32 0
        %sharer_pointer_520 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_513, i64 0, i32 1, i32 1
        %eraser_pointer_521 = getelementptr <{<{i64, %Prompt, i64, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_513, i64 0, i32 1, i32 2
        store ptr @returnAddress_449, ptr %returnAddress_pointer_519, !noalias !2
        store ptr @sharer_494, ptr %sharer_pointer_520, !noalias !2
        store ptr @eraser_506, ptr %eraser_pointer_521, !noalias !2
        
        %stack_522 = call ccc %Stack @reset(%Stack %stack)
        %p_6_18_45_209_4530 = call ccc %Prompt @currentPrompt(%Stack %stack_522)
        %stackPointer_528 = call ccc %StackPointer @stackAllocate(%Stack %stack_522, i64 24)
        %returnAddress_pointer_529 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_528, i64 0, i32 1, i32 0
        %sharer_pointer_530 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_528, i64 0, i32 1, i32 1
        %eraser_pointer_531 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_528, i64 0, i32 1, i32 2
        store ptr @returnAddress_523, ptr %returnAddress_pointer_529, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_530, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_531, !noalias !2
        
        %closure_548 = call ccc %Object @newObject(ptr @eraser_551, i64 8)
        %environment_549 = call ccc %Environment @objectEnvironment(%Object %closure_548)
        %p_6_18_45_209_4530_pointer_553 = getelementptr <{%Prompt}>, %Environment %environment_549, i64 0, i32 0
        store %Prompt %p_6_18_45_209_4530, ptr %p_6_18_45_209_4530_pointer_553, !noalias !2
        %vtable_temporary_554 = insertvalue %Neg zeroinitializer, ptr @vtable_547, 0
        %Exception_7_19_46_210_4380 = insertvalue %Neg %vtable_temporary_554, %Object %closure_548, 1
        %stackPointer_566 = call ccc %StackPointer @stackAllocate(%Stack %stack_522, i64 24)
        %returnAddress_pointer_567 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 0
        %sharer_pointer_568 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 1
        %eraser_pointer_569 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_566, i64 0, i32 1, i32 2
        store ptr @returnAddress_555, ptr %returnAddress_pointer_567, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_568, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_569, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2552_30_194_4420, i64 %index_7_34_198_4430, %Neg %Exception_7_19_46_210_4380, %Stack %stack_522)
        ret void
}



define tailcc void @Exception_9_106_133_297_4336_clause_570(%Object %closure, %Pos %exception_10_107_134_298_4958, %Pos %msg_11_108_135_299_4959, %Stack %stack) {
        
    entry:
        
        %environment_571 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4242_pointer_572 = getelementptr <{%Prompt}>, %Environment %environment_571, i64 0, i32 0
        %p_8_9_4242 = load %Prompt, ptr %p_8_9_4242_pointer_572, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_107_134_298_4958)
        call ccc void @erasePositive(%Pos %msg_11_108_135_299_4959)
        
        %pair_573 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4242)
        %k_13_14_4_4784 = extractvalue <{%Resumption, %Stack}> %pair_573, 0
        %stack_574 = extractvalue <{%Resumption, %Stack}> %pair_573, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_4784)
        
        %longLiteral_4960 = add i64 5, 0
        
        
        
        %pureApp_4961 = call ccc %Pos @boxInt_301(i64 %longLiteral_4960)
        
        
        
        %stackPointer_576 = call ccc %StackPointer @stackDeallocate(%Stack %stack_574, i64 24)
        %returnAddress_pointer_577 = getelementptr %FrameHeader, %StackPointer %stackPointer_576, i64 0, i32 0
        %returnAddress_575 = load %ReturnAddress, ptr %returnAddress_pointer_577, !noalias !2
        musttail call tailcc void %returnAddress_575(%Pos %pureApp_4961, %Stack %stack_574)
        ret void
}


@vtable_578 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4336_clause_570]


define tailcc void @returnAddress_589(i64 %v_coe_3456_22_131_158_322_4402, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4964 = call ccc %Pos @boxInt_301(i64 %v_coe_3456_22_131_158_322_4402)
        
        
        
        
        
        %pureApp_4965 = call ccc i64 @unboxInt_303(%Pos %pureApp_4964)
        
        
        
        %pureApp_4966 = call ccc %Pos @boxInt_301(i64 %pureApp_4965)
        
        
        
        %stackPointer_591 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_592 = getelementptr %FrameHeader, %StackPointer %stackPointer_591, i64 0, i32 0
        %returnAddress_590 = load %ReturnAddress, ptr %returnAddress_pointer_592, !noalias !2
        musttail call tailcc void %returnAddress_590(%Pos %pureApp_4966, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_601(i64 %v_r_2650_1_9_20_129_156_320_4465, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4970 = add i64 0, 0
        
        %pureApp_4969 = call ccc i64 @infixSub_105(i64 %longLiteral_4970, i64 %v_r_2650_1_9_20_129_156_320_4465)
        
        
        
        %stackPointer_603 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_604 = getelementptr %FrameHeader, %StackPointer %stackPointer_603, i64 0, i32 0
        %returnAddress_602 = load %ReturnAddress, ptr %returnAddress_pointer_604, !noalias !2
        musttail call tailcc void %returnAddress_602(i64 %pureApp_4969, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_584(i64 %v_r_2649_3_14_123_150_314_4332, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_585 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 32)
        %p_8_9_4242_pointer_586 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_585, i64 0, i32 0
        %p_8_9_4242 = load %Prompt, ptr %p_8_9_4242_pointer_586, !noalias !2
        %tmp_4801_pointer_587 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_585, i64 0, i32 1
        %tmp_4801 = load i64, ptr %tmp_4801_pointer_587, !noalias !2
        %v_r_2552_30_194_4420_pointer_588 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_585, i64 0, i32 2
        %v_r_2552_30_194_4420 = load %Pos, ptr %v_r_2552_30_194_4420_pointer_588, !noalias !2
        
        %intLiteral_4963 = add i64 45, 0
        
        %pureApp_4962 = call ccc %Pos @infixEq_78(i64 %v_r_2649_3_14_123_150_314_4332, i64 %intLiteral_4963)
        
        
        %stackPointer_593 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_594 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_593, i64 0, i32 1, i32 0
        %sharer_pointer_595 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_593, i64 0, i32 1, i32 1
        %eraser_pointer_596 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_593, i64 0, i32 1, i32 2
        store ptr @returnAddress_589, ptr %returnAddress_pointer_594, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_595, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_596, !noalias !2
        
        %tag_597 = extractvalue %Pos %pureApp_4962, 0
        %fields_598 = extractvalue %Pos %pureApp_4962, 1
        switch i64 %tag_597, label %label_599 [i64 0, label %label_600 i64 1, label %label_609]
    
    label_599:
        
        ret void
    
    label_600:
        
        %longLiteral_4967 = add i64 0, 0
        
        %longLiteral_4968 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4441(i64 %longLiteral_4967, i64 %longLiteral_4968, %Prompt %p_8_9_4242, i64 %tmp_4801, %Pos %v_r_2552_30_194_4420, %Stack %stack)
        ret void
    
    label_609:
        %stackPointer_605 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_606 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 0
        %sharer_pointer_607 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 1
        %eraser_pointer_608 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 2
        store ptr @returnAddress_601, ptr %returnAddress_pointer_606, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_607, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_608, !noalias !2
        
        %longLiteral_4971 = add i64 1, 0
        
        %longLiteral_4972 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_6_33_197_4441(i64 %longLiteral_4971, i64 %longLiteral_4972, %Prompt %p_8_9_4242, i64 %tmp_4801, %Pos %v_r_2552_30_194_4420, %Stack %stack)
        ret void
}



define ccc void @sharer_613(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_614 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4242_610_pointer_615 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_614, i64 0, i32 0
        %p_8_9_4242_610 = load %Prompt, ptr %p_8_9_4242_610_pointer_615, !noalias !2
        %tmp_4801_611_pointer_616 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_614, i64 0, i32 1
        %tmp_4801_611 = load i64, ptr %tmp_4801_611_pointer_616, !noalias !2
        %v_r_2552_30_194_4420_612_pointer_617 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_614, i64 0, i32 2
        %v_r_2552_30_194_4420_612 = load %Pos, ptr %v_r_2552_30_194_4420_612_pointer_617, !noalias !2
        call ccc void @sharePositive(%Pos %v_r_2552_30_194_4420_612)
        call ccc void @shareFrames(%StackPointer %stackPointer_614)
        ret void
}



define ccc void @eraser_621(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_622 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4242_618_pointer_623 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_622, i64 0, i32 0
        %p_8_9_4242_618 = load %Prompt, ptr %p_8_9_4242_618_pointer_623, !noalias !2
        %tmp_4801_619_pointer_624 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_622, i64 0, i32 1
        %tmp_4801_619 = load i64, ptr %tmp_4801_619_pointer_624, !noalias !2
        %v_r_2552_30_194_4420_620_pointer_625 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_622, i64 0, i32 2
        %v_r_2552_30_194_4420_620 = load %Pos, ptr %v_r_2552_30_194_4420_620_pointer_625, !noalias !2
        call ccc void @erasePositive(%Pos %v_r_2552_30_194_4420_620)
        call ccc void @eraseFrames(%StackPointer %stackPointer_622)
        ret void
}



define tailcc void @returnAddress_446(%Pos %v_r_2552_30_194_4420, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_447 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4242_pointer_448 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_447, i64 0, i32 0
        %p_8_9_4242 = load %Prompt, ptr %p_8_9_4242_pointer_448, !noalias !2
        
        %intLiteral_4935 = add i64 48, 0
        
        %pureApp_4934 = call ccc i64 @toInt_2085(i64 %intLiteral_4935)
        
        
        
        %closure_579 = call ccc %Object @newObject(ptr @eraser_551, i64 8)
        %environment_580 = call ccc %Environment @objectEnvironment(%Object %closure_579)
        %p_8_9_4242_pointer_582 = getelementptr <{%Prompt}>, %Environment %environment_580, i64 0, i32 0
        store %Prompt %p_8_9_4242, ptr %p_8_9_4242_pointer_582, !noalias !2
        %vtable_temporary_583 = insertvalue %Neg zeroinitializer, ptr @vtable_578, 0
        %Exception_9_106_133_297_4336 = insertvalue %Neg %vtable_temporary_583, %Object %closure_579, 1
        call ccc void @sharePositive(%Pos %v_r_2552_30_194_4420)
        %stackPointer_626 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 56)
        %p_8_9_4242_pointer_627 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_626, i64 0, i32 0
        store %Prompt %p_8_9_4242, ptr %p_8_9_4242_pointer_627, !noalias !2
        %tmp_4801_pointer_628 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_626, i64 0, i32 1
        store i64 %pureApp_4934, ptr %tmp_4801_pointer_628, !noalias !2
        %v_r_2552_30_194_4420_pointer_629 = getelementptr <{%Prompt, i64, %Pos}>, %StackPointer %stackPointer_626, i64 0, i32 2
        store %Pos %v_r_2552_30_194_4420, ptr %v_r_2552_30_194_4420_pointer_629, !noalias !2
        %returnAddress_pointer_630 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_626, i64 0, i32 1, i32 0
        %sharer_pointer_631 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_626, i64 0, i32 1, i32 1
        %eraser_pointer_632 = getelementptr <{<{%Prompt, i64, %Pos}>, %FrameHeader}>, %StackPointer %stackPointer_626, i64 0, i32 1, i32 2
        store ptr @returnAddress_584, ptr %returnAddress_pointer_630, !noalias !2
        store ptr @sharer_613, ptr %sharer_pointer_631, !noalias !2
        store ptr @eraser_621, ptr %eraser_pointer_632, !noalias !2
        
        %longLiteral_4973 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %v_r_2552_30_194_4420, i64 %longLiteral_4973, %Neg %Exception_9_106_133_297_4336, %Stack %stack)
        ret void
}



define ccc void @sharer_634(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_635 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4242_633_pointer_636 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_635, i64 0, i32 0
        %p_8_9_4242_633 = load %Prompt, ptr %p_8_9_4242_633_pointer_636, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_635)
        ret void
}



define ccc void @eraser_638(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_639 = getelementptr <{%Prompt}>, %StackPointer %stackPointer, i64 -1
        %p_8_9_4242_637_pointer_640 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_639, i64 0, i32 0
        %p_8_9_4242_637 = load %Prompt, ptr %p_8_9_4242_637_pointer_640, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_639)
        ret void
}


@utf8StringLiteral_4974.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_443(%Pos %v_r_2551_24_188_4350, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_444 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4242_pointer_445 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_444, i64 0, i32 0
        %p_8_9_4242 = load %Prompt, ptr %p_8_9_4242_pointer_445, !noalias !2
        %stackPointer_641 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4242_pointer_642 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_641, i64 0, i32 0
        store %Prompt %p_8_9_4242, ptr %p_8_9_4242_pointer_642, !noalias !2
        %returnAddress_pointer_643 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_641, i64 0, i32 1, i32 0
        %sharer_pointer_644 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_641, i64 0, i32 1, i32 1
        %eraser_pointer_645 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_641, i64 0, i32 1, i32 2
        store ptr @returnAddress_446, ptr %returnAddress_pointer_643, !noalias !2
        store ptr @sharer_634, ptr %sharer_pointer_644, !noalias !2
        store ptr @eraser_638, ptr %eraser_pointer_645, !noalias !2
        
        %tag_646 = extractvalue %Pos %v_r_2551_24_188_4350, 0
        %fields_647 = extractvalue %Pos %v_r_2551_24_188_4350, 1
        switch i64 %tag_646, label %label_648 [i64 0, label %label_652 i64 1, label %label_658]
    
    label_648:
        
        ret void
    
    label_652:
        
        %utf8StringLiteral_4974 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_4974.lit)
        
        %stackPointer_650 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_651 = getelementptr %FrameHeader, %StackPointer %stackPointer_650, i64 0, i32 0
        %returnAddress_649 = load %ReturnAddress, ptr %returnAddress_pointer_651, !noalias !2
        musttail call tailcc void %returnAddress_649(%Pos %utf8StringLiteral_4974, %Stack %stack)
        ret void
    
    label_658:
        %environment_653 = call ccc %Environment @objectEnvironment(%Object %fields_647)
        %v_y_3278_8_29_193_4490_pointer_654 = getelementptr <{%Pos}>, %Environment %environment_653, i64 0, i32 0
        %v_y_3278_8_29_193_4490 = load %Pos, ptr %v_y_3278_8_29_193_4490_pointer_654, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3278_8_29_193_4490)
        call ccc void @eraseObject(%Object %fields_647)
        
        %stackPointer_656 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_657 = getelementptr %FrameHeader, %StackPointer %stackPointer_656, i64 0, i32 0
        %returnAddress_655 = load %ReturnAddress, ptr %returnAddress_pointer_657, !noalias !2
        musttail call tailcc void %returnAddress_655(%Pos %v_y_3278_8_29_193_4490, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_440(%Pos %v_r_2550_13_177_4437, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_441 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %p_8_9_4242_pointer_442 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_441, i64 0, i32 0
        %p_8_9_4242 = load %Prompt, ptr %p_8_9_4242_pointer_442, !noalias !2
        %stackPointer_661 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %p_8_9_4242_pointer_662 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_661, i64 0, i32 0
        store %Prompt %p_8_9_4242, ptr %p_8_9_4242_pointer_662, !noalias !2
        %returnAddress_pointer_663 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_661, i64 0, i32 1, i32 0
        %sharer_pointer_664 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_661, i64 0, i32 1, i32 1
        %eraser_pointer_665 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_661, i64 0, i32 1, i32 2
        store ptr @returnAddress_443, ptr %returnAddress_pointer_663, !noalias !2
        store ptr @sharer_634, ptr %sharer_pointer_664, !noalias !2
        store ptr @eraser_638, ptr %eraser_pointer_665, !noalias !2
        
        %tag_666 = extractvalue %Pos %v_r_2550_13_177_4437, 0
        %fields_667 = extractvalue %Pos %v_r_2550_13_177_4437, 1
        switch i64 %tag_666, label %label_668 [i64 0, label %label_673 i64 1, label %label_685]
    
    label_668:
        
        ret void
    
    label_673:
        
        %make_4975_temporary_669 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4975 = insertvalue %Pos %make_4975_temporary_669, %Object null, 1
        
        
        
        %stackPointer_671 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_672 = getelementptr %FrameHeader, %StackPointer %stackPointer_671, i64 0, i32 0
        %returnAddress_670 = load %ReturnAddress, ptr %returnAddress_pointer_672, !noalias !2
        musttail call tailcc void %returnAddress_670(%Pos %make_4975, %Stack %stack)
        ret void
    
    label_685:
        %environment_674 = call ccc %Environment @objectEnvironment(%Object %fields_667)
        %v_y_2787_10_21_185_4313_pointer_675 = getelementptr <{%Pos, %Pos}>, %Environment %environment_674, i64 0, i32 0
        %v_y_2787_10_21_185_4313 = load %Pos, ptr %v_y_2787_10_21_185_4313_pointer_675, !noalias !2
        %v_y_2788_11_22_186_4321_pointer_676 = getelementptr <{%Pos, %Pos}>, %Environment %environment_674, i64 0, i32 1
        %v_y_2788_11_22_186_4321 = load %Pos, ptr %v_y_2788_11_22_186_4321_pointer_676, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2787_10_21_185_4313)
        call ccc void @eraseObject(%Object %fields_667)
        
        %fields_677 = call ccc %Object @newObject(ptr @eraser_559, i64 16)
        %environment_678 = call ccc %Environment @objectEnvironment(%Object %fields_677)
        %v_y_2787_10_21_185_4313_pointer_680 = getelementptr <{%Pos}>, %Environment %environment_678, i64 0, i32 0
        store %Pos %v_y_2787_10_21_185_4313, ptr %v_y_2787_10_21_185_4313_pointer_680, !noalias !2
        %make_4976_temporary_681 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4976 = insertvalue %Pos %make_4976_temporary_681, %Object %fields_677, 1
        
        
        
        %stackPointer_683 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_684 = getelementptr %FrameHeader, %StackPointer %stackPointer_683, i64 0, i32 0
        %returnAddress_682 = load %ReturnAddress, ptr %returnAddress_pointer_684, !noalias !2
        musttail call tailcc void %returnAddress_682(%Pos %make_4976, %Stack %stack)
        ret void
}



define tailcc void @main_2445(%Stack %stack) {
        
    entry:
        
        %stackPointer_407 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_408 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_407, i64 0, i32 1, i32 0
        %sharer_pointer_409 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_407, i64 0, i32 1, i32 1
        %eraser_pointer_410 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_407, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_408, !noalias !2
        store ptr @sharer_6, ptr %sharer_pointer_409, !noalias !2
        store ptr @eraser_8, ptr %eraser_pointer_410, !noalias !2
        
        %stack_411 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4242 = call ccc %Prompt @currentPrompt(%Stack %stack_411)
        %stackPointer_417 = call ccc %StackPointer @stackAllocate(%Stack %stack_411, i64 24)
        %returnAddress_pointer_418 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_417, i64 0, i32 1, i32 0
        %sharer_pointer_419 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_417, i64 0, i32 1, i32 1
        %eraser_pointer_420 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_417, i64 0, i32 1, i32 2
        store ptr @returnAddress_412, ptr %returnAddress_pointer_418, !noalias !2
        store ptr @sharer_20, ptr %sharer_pointer_419, !noalias !2
        store ptr @eraser_22, ptr %eraser_pointer_420, !noalias !2
        
        %pureApp_4930 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_4932 = add i64 1, 0
        
        %pureApp_4931 = call ccc i64 @infixSub_105(i64 %pureApp_4930, i64 %longLiteral_4932)
        
        
        
        %make_4933_temporary_439 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4933 = insertvalue %Pos %make_4933_temporary_439, %Object null, 1
        
        
        %stackPointer_688 = call ccc %StackPointer @stackAllocate(%Stack %stack_411, i64 32)
        %p_8_9_4242_pointer_689 = getelementptr <{%Prompt}>, %StackPointer %stackPointer_688, i64 0, i32 0
        store %Prompt %p_8_9_4242, ptr %p_8_9_4242_pointer_689, !noalias !2
        %returnAddress_pointer_690 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 0
        %sharer_pointer_691 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 1
        %eraser_pointer_692 = getelementptr <{<{%Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_688, i64 0, i32 1, i32 2
        store ptr @returnAddress_440, ptr %returnAddress_pointer_690, !noalias !2
        store ptr @sharer_634, ptr %sharer_pointer_691, !noalias !2
        store ptr @eraser_638, ptr %eraser_pointer_692, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_167_4539(i64 %pureApp_4931, %Pos %make_4933, %Stack %stack_411)
        ret void
}


@utf8StringLiteral_4857.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4859.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4862.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_693(%Pos %v_r_2718_3508, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_694 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_695 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_694, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_695, !noalias !2
        %index_2107_pointer_696 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_694, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_696, !noalias !2
        %Exception_2362_pointer_697 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_694, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_697, !noalias !2
        
        %tag_698 = extractvalue %Pos %v_r_2718_3508, 0
        %fields_699 = extractvalue %Pos %v_r_2718_3508, 1
        switch i64 %tag_698, label %label_700 [i64 0, label %label_704 i64 1, label %label_710]
    
    label_700:
        
        ret void
    
    label_704:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4853 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_702 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_703 = getelementptr %FrameHeader, %StackPointer %stackPointer_702, i64 0, i32 0
        %returnAddress_701 = load %ReturnAddress, ptr %returnAddress_pointer_703, !noalias !2
        musttail call tailcc void %returnAddress_701(i64 %pureApp_4853, %Stack %stack)
        ret void
    
    label_710:
        
        %make_4854_temporary_705 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4854 = insertvalue %Pos %make_4854_temporary_705, %Object null, 1
        
        
        
        %pureApp_4855 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4857 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4857.lit)
        
        %pureApp_4856 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4857, %Pos %pureApp_4855)
        
        
        
        %utf8StringLiteral_4859 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4859.lit)
        
        %pureApp_4858 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4856, %Pos %utf8StringLiteral_4859)
        
        
        
        %pureApp_4860 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4858, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4862 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4862.lit)
        
        %pureApp_4861 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4860, %Pos %utf8StringLiteral_4862)
        
        
        
        %vtable_706 = extractvalue %Neg %Exception_2362, 0
        %closure_707 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_708 = getelementptr ptr, ptr %vtable_706, i64 0
        %functionPointer_709 = load ptr, ptr %functionPointer_pointer_708, !noalias !2
        musttail call tailcc void %functionPointer_709(%Object %closure_707, %Pos %make_4854, %Pos %pureApp_4861, %Stack %stack)
        ret void
}



define ccc void @sharer_714(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_715 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_711_pointer_716 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_715, i64 0, i32 0
        %str_2106_711 = load %Pos, ptr %str_2106_711_pointer_716, !noalias !2
        %index_2107_712_pointer_717 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_715, i64 0, i32 1
        %index_2107_712 = load i64, ptr %index_2107_712_pointer_717, !noalias !2
        %Exception_2362_713_pointer_718 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_715, i64 0, i32 2
        %Exception_2362_713 = load %Neg, ptr %Exception_2362_713_pointer_718, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_711)
        call ccc void @shareNegative(%Neg %Exception_2362_713)
        call ccc void @shareFrames(%StackPointer %stackPointer_715)
        ret void
}



define ccc void @eraser_722(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_723 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_719_pointer_724 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_723, i64 0, i32 0
        %str_2106_719 = load %Pos, ptr %str_2106_719_pointer_724, !noalias !2
        %index_2107_720_pointer_725 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_723, i64 0, i32 1
        %index_2107_720 = load i64, ptr %index_2107_720_pointer_725, !noalias !2
        %Exception_2362_721_pointer_726 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_723, i64 0, i32 2
        %Exception_2362_721 = load %Neg, ptr %Exception_2362_721_pointer_726, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_719)
        call ccc void @eraseNegative(%Neg %Exception_2362_721)
        call ccc void @eraseFrames(%StackPointer %stackPointer_723)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4852 = add i64 0, 0
        
        %pureApp_4851 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4852)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_727 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_728 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_727, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_728, !noalias !2
        %index_2107_pointer_729 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_727, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_729, !noalias !2
        %Exception_2362_pointer_730 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_727, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_730, !noalias !2
        %returnAddress_pointer_731 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_727, i64 0, i32 1, i32 0
        %sharer_pointer_732 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_727, i64 0, i32 1, i32 1
        %eraser_pointer_733 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_727, i64 0, i32 1, i32 2
        store ptr @returnAddress_693, ptr %returnAddress_pointer_731, !noalias !2
        store ptr @sharer_714, ptr %sharer_pointer_732, !noalias !2
        store ptr @eraser_722, ptr %eraser_pointer_733, !noalias !2
        
        %tag_734 = extractvalue %Pos %pureApp_4851, 0
        %fields_735 = extractvalue %Pos %pureApp_4851, 1
        switch i64 %tag_734, label %label_736 [i64 0, label %label_740 i64 1, label %label_745]
    
    label_736:
        
        ret void
    
    label_740:
        
        %pureApp_4863 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4864 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4863)
        
        
        
        %stackPointer_738 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_739 = getelementptr %FrameHeader, %StackPointer %stackPointer_738, i64 0, i32 0
        %returnAddress_737 = load %ReturnAddress, ptr %returnAddress_pointer_739, !noalias !2
        musttail call tailcc void %returnAddress_737(%Pos %pureApp_4864, %Stack %stack)
        ret void
    
    label_745:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4865_temporary_741 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4865 = insertvalue %Pos %booleanLiteral_4865_temporary_741, %Object null, 1
        
        %stackPointer_743 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_744 = getelementptr %FrameHeader, %StackPointer %stackPointer_743, i64 0, i32 0
        %returnAddress_742 = load %ReturnAddress, ptr %returnAddress_pointer_744, !noalias !2
        musttail call tailcc void %returnAddress_742(%Pos %booleanLiteral_4865, %Stack %stack)
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
