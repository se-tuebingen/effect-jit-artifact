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



define tailcc void @returnAddress_5(i64 %r_2460, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4997 = call ccc %Pos @show_14(i64 %r_2460)
        
        
        
        %pureApp_4998 = call ccc %Pos @println_1(%Pos %pureApp_4997)
        
        
        
        %stackPointer_7 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_8 = getelementptr %FrameHeader, %StackPointer %stackPointer_7, i64 0, i32 0
        %returnAddress_6 = load %ReturnAddress, ptr %returnAddress_pointer_8, !noalias !2
        musttail call tailcc void %returnAddress_6(%Pos %pureApp_4998, %Stack %stack)
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



define tailcc void @returnAddress_17(i64 %returnValue_18, %Stack %stack) {
        
    entry:
        
        %stackPointer_19 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_4935_pointer_20 = getelementptr <{i64}>, %StackPointer %stackPointer_19, i64 0, i32 0
        %tmp_4935 = load i64, ptr %tmp_4935_pointer_20, !noalias !2
        %stackPointer_22 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_23 = getelementptr %FrameHeader, %StackPointer %stackPointer_22, i64 0, i32 0
        %returnAddress_21 = load %ReturnAddress, ptr %returnAddress_pointer_23, !noalias !2
        musttail call tailcc void %returnAddress_21(i64 %returnValue_18, %Stack %stack)
        ret void
}



define ccc void @sharer_25(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_26 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_4935_24_pointer_27 = getelementptr <{i64}>, %StackPointer %stackPointer_26, i64 0, i32 0
        %tmp_4935_24 = load i64, ptr %tmp_4935_24_pointer_27, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_26)
        ret void
}



define ccc void @eraser_29(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_30 = getelementptr <{i64}>, %StackPointer %stackPointer, i64 -1
        %tmp_4935_28_pointer_31 = getelementptr <{i64}>, %StackPointer %stackPointer_30, i64 0, i32 0
        %tmp_4935_28 = load i64, ptr %tmp_4935_28_pointer_31, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_30)
        ret void
}



define tailcc void @returnAddress_40(i64 %v_coe_3507_8_32_55_4777, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5004 = call ccc %Pos @boxInt_301(i64 %v_coe_3507_8_32_55_4777)
        
        
        
        %pureApp_5005 = call ccc i64 @unboxInt_303(%Pos %pureApp_5004)
        
        
        
        %stackPointer_42 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_43 = getelementptr %FrameHeader, %StackPointer %stackPointer_42, i64 0, i32 0
        %returnAddress_41 = load %ReturnAddress, ptr %returnAddress_pointer_43, !noalias !2
        musttail call tailcc void %returnAddress_41(i64 %pureApp_5005, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_55(%Pos %__6_36_4794, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_56 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %s_4_4785_pointer_57 = getelementptr <{%Reference}>, %StackPointer %stackPointer_56, i64 0, i32 0
        %s_4_4785 = load %Reference, ptr %s_4_4785_pointer_57, !noalias !2
        call ccc void @erasePositive(%Pos %__6_36_4794)
        
        
        musttail call tailcc void @countdown_worker_5_10_23_4783(%Reference %s_4_4785, %Stack %stack)
        ret void
}



define ccc void @sharer_59(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_60 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %s_4_4785_58_pointer_61 = getelementptr <{%Reference}>, %StackPointer %stackPointer_60, i64 0, i32 0
        %s_4_4785_58 = load %Reference, ptr %s_4_4785_58_pointer_61, !noalias !2
        call ccc void @shareFrames(%StackPointer %stackPointer_60)
        ret void
}



define ccc void @eraser_63(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_64 = getelementptr <{%Reference}>, %StackPointer %stackPointer, i64 -1
        %s_4_4785_62_pointer_65 = getelementptr <{%Reference}>, %StackPointer %stackPointer_64, i64 0, i32 0
        %s_4_4785_62 = load %Reference, ptr %s_4_4785_62_pointer_65, !noalias !2
        call ccc void @eraseFrames(%StackPointer %stackPointer_64)
        ret void
}



define tailcc void @returnAddress_49(i64 %i_6_11_29_4768, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_50 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %s_4_4785_pointer_51 = getelementptr <{%Reference}>, %StackPointer %stackPointer_50, i64 0, i32 0
        %s_4_4785 = load %Reference, ptr %s_4_4785_pointer_51, !noalias !2
        
        %longLiteral_5007 = add i64 0, 0
        
        %pureApp_5006 = call ccc %Pos @infixEq_72(i64 %i_6_11_29_4768, i64 %longLiteral_5007)
        
        
        
        %tag_52 = extractvalue %Pos %pureApp_5006, 0
        %fields_53 = extractvalue %Pos %pureApp_5006, 1
        switch i64 %tag_52, label %label_54 [i64 0, label %label_77 i64 1, label %label_81]
    
    label_54:
        
        ret void
    
    label_77:
        
        %longLiteral_5009 = add i64 1, 0
        
        %pureApp_5008 = call ccc i64 @infixSub_105(i64 %i_6_11_29_4768, i64 %longLiteral_5009)
        
        
        %stackPointer_66 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %s_4_4785_pointer_67 = getelementptr <{%Reference}>, %StackPointer %stackPointer_66, i64 0, i32 0
        store %Reference %s_4_4785, ptr %s_4_4785_pointer_67, !noalias !2
        %returnAddress_pointer_68 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_66, i64 0, i32 1, i32 0
        %sharer_pointer_69 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_66, i64 0, i32 1, i32 1
        %eraser_pointer_70 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_66, i64 0, i32 1, i32 2
        store ptr @returnAddress_55, ptr %returnAddress_pointer_68, !noalias !2
        store ptr @sharer_59, ptr %sharer_pointer_69, !noalias !2
        store ptr @eraser_63, ptr %eraser_pointer_70, !noalias !2
        
        %s_4_4785pointer_71 = call ccc ptr @getVarPointer(%Reference %s_4_4785, %Stack %stack)
        %s_4_4785_old_72 = load i64, ptr %s_4_4785pointer_71, !noalias !2
        store i64 %pureApp_5008, ptr %s_4_4785pointer_71, !noalias !2
        
        %put_5010_temporary_73 = insertvalue %Pos zeroinitializer, i64 0, 0
        %put_5010 = insertvalue %Pos %put_5010_temporary_73, %Object null, 1
        
        %stackPointer_75 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_76 = getelementptr %FrameHeader, %StackPointer %stackPointer_75, i64 0, i32 0
        %returnAddress_74 = load %ReturnAddress, ptr %returnAddress_pointer_76, !noalias !2
        musttail call tailcc void %returnAddress_74(%Pos %put_5010, %Stack %stack)
        ret void
    
    label_81:
        
        %stackPointer_79 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_80 = getelementptr %FrameHeader, %StackPointer %stackPointer_79, i64 0, i32 0
        %returnAddress_78 = load %ReturnAddress, ptr %returnAddress_pointer_80, !noalias !2
        musttail call tailcc void %returnAddress_78(i64 %i_6_11_29_4768, %Stack %stack)
        ret void
}



define tailcc void @countdown_worker_5_10_23_4783(%Reference %s_4_4785, %Stack %stack) {
        
    entry:
        
        %stackPointer_84 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %s_4_4785_pointer_85 = getelementptr <{%Reference}>, %StackPointer %stackPointer_84, i64 0, i32 0
        store %Reference %s_4_4785, ptr %s_4_4785_pointer_85, !noalias !2
        %returnAddress_pointer_86 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_84, i64 0, i32 1, i32 0
        %sharer_pointer_87 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_84, i64 0, i32 1, i32 1
        %eraser_pointer_88 = getelementptr <{<{%Reference}>, %FrameHeader}>, %StackPointer %stackPointer_84, i64 0, i32 1, i32 2
        store ptr @returnAddress_49, ptr %returnAddress_pointer_86, !noalias !2
        store ptr @sharer_59, ptr %sharer_pointer_87, !noalias !2
        store ptr @eraser_63, ptr %eraser_pointer_88, !noalias !2
        
        %get_5011_pointer_89 = call ccc ptr @getVarPointer(%Reference %s_4_4785, %Stack %stack)
        %s_4_4785_old_90 = load i64, ptr %get_5011_pointer_89, !noalias !2
        %get_5011 = load i64, ptr %get_5011_pointer_89, !noalias !2
        
        %stackPointer_92 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_93 = getelementptr %FrameHeader, %StackPointer %stackPointer_92, i64 0, i32 0
        %returnAddress_91 = load %ReturnAddress, ptr %returnAddress_pointer_93, !noalias !2
        musttail call tailcc void %returnAddress_91(i64 %get_5011, %Stack %stack)
        ret void
}



define tailcc void @handled_worker_7_20_4789(i64 %d_8_21_4764, %Reference %s_4_4785, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5001 = add i64 0, 0
        
        %pureApp_5000 = call ccc %Pos @infixEq_72(i64 %d_8_21_4764, i64 %longLiteral_5001)
        
        
        
        %tag_37 = extractvalue %Pos %pureApp_5000, 0
        %fields_38 = extractvalue %Pos %pureApp_5000, 1
        switch i64 %tag_37, label %label_39 [i64 0, label %label_48 i64 1, label %label_94]
    
    label_39:
        
        ret void
    
    label_48:
        
        %longLiteral_5003 = add i64 1, 0
        
        %pureApp_5002 = call ccc i64 @infixSub_105(i64 %d_8_21_4764, i64 %longLiteral_5003)
        
        
        %stackPointer_44 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_45 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_44, i64 0, i32 1, i32 0
        %sharer_pointer_46 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_44, i64 0, i32 1, i32 1
        %eraser_pointer_47 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_44, i64 0, i32 1, i32 2
        store ptr @returnAddress_40, ptr %returnAddress_pointer_45, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_46, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_47, !noalias !2
        
        
        
        musttail call tailcc void @handled_worker_7_20_4789(i64 %pureApp_5002, %Reference %s_4_4785, %Stack %stack)
        ret void
    
    label_94:
        
        
        musttail call tailcc void @countdown_worker_5_10_23_4783(%Reference %s_4_4785, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_2(%Pos %v_coe_3530_3618, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_3 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 8)
        %tmp_4935_pointer_4 = getelementptr <{i64}>, %StackPointer %stackPointer_3, i64 0, i32 0
        %tmp_4935 = load i64, ptr %tmp_4935_pointer_4, !noalias !2
        
        %pureApp_4996 = call ccc i64 @unboxInt_303(%Pos %v_coe_3530_3618)
        
        
        %stackPointer_13 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_14 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_13, i64 0, i32 1, i32 0
        %sharer_pointer_15 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_13, i64 0, i32 1, i32 1
        %eraser_pointer_16 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_13, i64 0, i32 1, i32 2
        store ptr @returnAddress_5, ptr %returnAddress_pointer_14, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_15, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_16, !noalias !2
        %s_4_4785 = call ccc %Reference @newReference(%Stack %stack)
        %stackPointer_32 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_4935_pointer_33 = getelementptr <{i64}>, %StackPointer %stackPointer_32, i64 0, i32 0
        store i64 %tmp_4935, ptr %tmp_4935_pointer_33, !noalias !2
        %returnAddress_pointer_34 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_32, i64 0, i32 1, i32 0
        %sharer_pointer_35 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_32, i64 0, i32 1, i32 1
        %eraser_pointer_36 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_32, i64 0, i32 1, i32 2
        store ptr @returnAddress_17, ptr %returnAddress_pointer_34, !noalias !2
        store ptr @sharer_25, ptr %sharer_pointer_35, !noalias !2
        store ptr @eraser_29, ptr %eraser_pointer_36, !noalias !2
        
        
        
        musttail call tailcc void @handled_worker_7_20_4789(i64 %pureApp_4996, %Reference %s_4_4785, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_103(%Pos %returned_5012, %Stack %stack) {
        
    entry:
        
        %stack_104 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_106 = call ccc %StackPointer @stackDeallocate(%Stack %stack_104, i64 24)
        %returnAddress_pointer_107 = getelementptr %FrameHeader, %StackPointer %stackPointer_106, i64 0, i32 0
        %returnAddress_105 = load %ReturnAddress, ptr %returnAddress_pointer_107, !noalias !2
        musttail call tailcc void %returnAddress_105(%Pos %returned_5012, %Stack %stack_104)
        ret void
}



define ccc void @sharer_108(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_109 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        ret void
}



define ccc void @eraser_110(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_111 = getelementptr <{}>, %StackPointer %stackPointer, i64 -1
        call ccc void @free(%StackPointer %stackPointer_111)
        ret void
}



define tailcc void @Exception_9_10_4420_clause_116(%Object %closure, %Pos %exception_10_11_4426, %Pos %msg_11_12_4428, %Stack %stack) {
        
    entry:
        
        %environment_117 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4422_pointer_118 = getelementptr <{%Prompt}>, %Environment %environment_117, i64 0, i32 0
        %p_8_9_4422 = load %Prompt, ptr %p_8_9_4422_pointer_118, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_11_4426)
        call ccc void @erasePositive(%Pos %msg_11_12_4428)
        
        %pair_119 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4422)
        %k_13_14_4429 = extractvalue <{%Resumption, %Stack}> %pair_119, 0
        %stack_120 = extractvalue <{%Resumption, %Stack}> %pair_119, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4429)
        
        %longLiteral_5013 = add i64 10, 0
        
        
        
        %pureApp_5014 = call ccc %Pos @boxInt_301(i64 %longLiteral_5013)
        
        
        
        %stackPointer_122 = call ccc %StackPointer @stackDeallocate(%Stack %stack_120, i64 24)
        %returnAddress_pointer_123 = getelementptr %FrameHeader, %StackPointer %stackPointer_122, i64 0, i32 0
        %returnAddress_121 = load %ReturnAddress, ptr %returnAddress_pointer_123, !noalias !2
        musttail call tailcc void %returnAddress_121(%Pos %pureApp_5014, %Stack %stack_120)
        ret void
}


@vtable_124 = private constant [1 x ptr] [ptr @Exception_9_10_4420_clause_116]


define ccc void @eraser_128(%Environment %environment) {
        
    entry:
        
        %p_8_9_4422_127_pointer_129 = getelementptr <{%Prompt}>, %Environment %environment, i64 0, i32 0
        %p_8_9_4422_127 = load %Prompt, ptr %p_8_9_4422_127_pointer_129, !noalias !2
        ret void
}



define tailcc void @returnAddress_132(%Pos %v_coe_3525_157_317_4707, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5015 = call ccc i64 @unboxInt_303(%Pos %v_coe_3525_157_317_4707)
        
        
        
        %pureApp_5016 = call ccc %Pos @boxInt_301(i64 %pureApp_5015)
        
        
        
        %stackPointer_134 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_135 = getelementptr %FrameHeader, %StackPointer %stackPointer_134, i64 0, i32 0
        %returnAddress_133 = load %ReturnAddress, ptr %returnAddress_pointer_135, !noalias !2
        musttail call tailcc void %returnAddress_133(%Pos %pureApp_5016, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_141(%Pos %returned_5017, %Stack %stack) {
        
    entry:
        
        %stack_142 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_144 = call ccc %StackPointer @stackDeallocate(%Stack %stack_142, i64 24)
        %returnAddress_pointer_145 = getelementptr %FrameHeader, %StackPointer %stackPointer_144, i64 0, i32 0
        %returnAddress_143 = load %ReturnAddress, ptr %returnAddress_pointer_145, !noalias !2
        musttail call tailcc void %returnAddress_143(%Pos %returned_5017, %Stack %stack_142)
        ret void
}



define ccc void @eraser_157(%Environment %environment) {
        
    entry:
        
        %tmp_4909_155_pointer_158 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 0
        %tmp_4909_155 = load %Pos, ptr %tmp_4909_155_pointer_158, !noalias !2
        %acc_3_3_5_37_118_278_4632_156_pointer_159 = getelementptr <{%Pos, %Pos}>, %Environment %environment, i64 0, i32 1
        %acc_3_3_5_37_118_278_4632_156 = load %Pos, ptr %acc_3_3_5_37_118_278_4632_156_pointer_159, !noalias !2
        call ccc void @erasePositive(%Pos %tmp_4909_155)
        call ccc void @erasePositive(%Pos %acc_3_3_5_37_118_278_4632_156)
        ret void
}



define tailcc void @toList_1_1_3_35_116_276_4703(i64 %start_2_2_4_36_117_277_4532, %Pos %acc_3_3_5_37_118_278_4632, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5019 = add i64 1, 0
        
        %pureApp_5018 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_36_117_277_4532, i64 %longLiteral_5019)
        
        
        
        %tag_150 = extractvalue %Pos %pureApp_5018, 0
        %fields_151 = extractvalue %Pos %pureApp_5018, 1
        switch i64 %tag_150, label %label_152 [i64 0, label %label_163 i64 1, label %label_167]
    
    label_152:
        
        ret void
    
    label_163:
        
        %pureApp_5020 = call ccc %Pos @argument_2385(i64 %start_2_2_4_36_117_277_4532)
        
        
        
        %longLiteral_5022 = add i64 1, 0
        
        %pureApp_5021 = call ccc i64 @infixSub_105(i64 %start_2_2_4_36_117_277_4532, i64 %longLiteral_5022)
        
        
        
        %fields_153 = call ccc %Object @newObject(ptr @eraser_157, i64 32)
        %environment_154 = call ccc %Environment @objectEnvironment(%Object %fields_153)
        %tmp_4909_pointer_160 = getelementptr <{%Pos, %Pos}>, %Environment %environment_154, i64 0, i32 0
        store %Pos %pureApp_5020, ptr %tmp_4909_pointer_160, !noalias !2
        %acc_3_3_5_37_118_278_4632_pointer_161 = getelementptr <{%Pos, %Pos}>, %Environment %environment_154, i64 0, i32 1
        store %Pos %acc_3_3_5_37_118_278_4632, ptr %acc_3_3_5_37_118_278_4632_pointer_161, !noalias !2
        %make_5023_temporary_162 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5023 = insertvalue %Pos %make_5023_temporary_162, %Object %fields_153, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_35_116_276_4703(i64 %pureApp_5021, %Pos %make_5023, %Stack %stack)
        ret void
    
    label_167:
        
        %stackPointer_165 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_166 = getelementptr %FrameHeader, %StackPointer %stackPointer_165, i64 0, i32 0
        %returnAddress_164 = load %ReturnAddress, ptr %returnAddress_pointer_166, !noalias !2
        musttail call tailcc void %returnAddress_164(%Pos %acc_3_3_5_37_118_278_4632, %Stack %stack)
        ret void
}



define tailcc void @go_6_14_46_127_287_4722(%Pos %list_7_15_47_128_288_4467, i64 %i_8_16_48_129_289_4542, %Prompt %p_8_9_75_235_4691, %Stack %stack) {
        
    entry:
        
        
        %tag_173 = extractvalue %Pos %list_7_15_47_128_288_4467, 0
        %fields_174 = extractvalue %Pos %list_7_15_47_128_288_4467, 1
        switch i64 %tag_173, label %label_175 [i64 0, label %label_181 i64 1, label %label_193]
    
    label_175:
        
        ret void
    
    label_181:
        
        %pair_176 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_75_235_4691)
        %k_13_14_4_146_306_4740 = extractvalue <{%Resumption, %Stack}> %pair_176, 0
        %stack_177 = extractvalue <{%Resumption, %Stack}> %pair_176, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4_146_306_4740)
        
        %longLiteral_5028 = add i64 10, 0
        
        
        
        %pureApp_5029 = call ccc %Pos @boxInt_301(i64 %longLiteral_5028)
        
        
        
        %stackPointer_179 = call ccc %StackPointer @stackDeallocate(%Stack %stack_177, i64 24)
        %returnAddress_pointer_180 = getelementptr %FrameHeader, %StackPointer %stackPointer_179, i64 0, i32 0
        %returnAddress_178 = load %ReturnAddress, ptr %returnAddress_pointer_180, !noalias !2
        musttail call tailcc void %returnAddress_178(%Pos %pureApp_5029, %Stack %stack_177)
        ret void
    
    label_187:
        
        ret void
    
    label_188:
        call ccc void @erasePositive(%Pos %v_y_2842_19_27_59_150_310_4491)
        
        %longLiteral_5033 = add i64 1, 0
        
        %pureApp_5032 = call ccc i64 @infixSub_105(i64 %i_8_16_48_129_289_4542, i64 %longLiteral_5033)
        
        
        
        
        
        
        musttail call tailcc void @go_6_14_46_127_287_4722(%Pos %v_y_2843_20_28_60_151_311_4490, i64 %pureApp_5032, %Prompt %p_8_9_75_235_4691, %Stack %stack)
        ret void
    
    label_192:
        call ccc void @erasePositive(%Pos %v_y_2843_20_28_60_151_311_4490)
        
        %stackPointer_190 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_191 = getelementptr %FrameHeader, %StackPointer %stackPointer_190, i64 0, i32 0
        %returnAddress_189 = load %ReturnAddress, ptr %returnAddress_pointer_191, !noalias !2
        musttail call tailcc void %returnAddress_189(%Pos %v_y_2842_19_27_59_150_310_4491, %Stack %stack)
        ret void
    
    label_193:
        %environment_182 = call ccc %Environment @objectEnvironment(%Object %fields_174)
        %v_y_2842_19_27_59_150_310_4491_pointer_183 = getelementptr <{%Pos, %Pos}>, %Environment %environment_182, i64 0, i32 0
        %v_y_2842_19_27_59_150_310_4491 = load %Pos, ptr %v_y_2842_19_27_59_150_310_4491_pointer_183, !noalias !2
        %v_y_2843_20_28_60_151_311_4490_pointer_184 = getelementptr <{%Pos, %Pos}>, %Environment %environment_182, i64 0, i32 1
        %v_y_2843_20_28_60_151_311_4490 = load %Pos, ptr %v_y_2843_20_28_60_151_311_4490_pointer_184, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2842_19_27_59_150_310_4491)
        call ccc void @sharePositive(%Pos %v_y_2843_20_28_60_151_311_4490)
        call ccc void @eraseObject(%Object %fields_174)
        
        %longLiteral_5031 = add i64 0, 0
        
        %pureApp_5030 = call ccc %Pos @infixEq_72(i64 %i_8_16_48_129_289_4542, i64 %longLiteral_5031)
        
        
        
        %tag_185 = extractvalue %Pos %pureApp_5030, 0
        %fields_186 = extractvalue %Pos %pureApp_5030, 1
        switch i64 %tag_185, label %label_187 [i64 0, label %label_188 i64 1, label %label_192]
}



define tailcc void @returnAddress_197(i64 %v_coe_3523_64_155_315_4702, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5034 = call ccc %Pos @boxInt_301(i64 %v_coe_3523_64_155_315_4702)
        
        
        
        %stackPointer_199 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_200 = getelementptr %FrameHeader, %StackPointer %stackPointer_199, i64 0, i32 0
        %returnAddress_198 = load %ReturnAddress, ptr %returnAddress_pointer_200, !noalias !2
        musttail call tailcc void %returnAddress_198(%Pos %pureApp_5034, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_194(%Pos %v_r_2586_31_63_154_314_4676, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_195 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %Exception_9_10_4420_pointer_196 = getelementptr <{%Neg}>, %StackPointer %stackPointer_195, i64 0, i32 0
        %Exception_9_10_4420 = load %Neg, ptr %Exception_9_10_4420_pointer_196, !noalias !2
        %stackPointer_201 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_202 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_201, i64 0, i32 1, i32 0
        %sharer_pointer_203 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_201, i64 0, i32 1, i32 1
        %eraser_pointer_204 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_201, i64 0, i32 1, i32 2
        store ptr @returnAddress_197, ptr %returnAddress_pointer_202, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_203, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_204, !noalias !2
        
        
        
        
        musttail call tailcc void @toInt_2062(%Pos %v_r_2586_31_63_154_314_4676, %Neg %Exception_9_10_4420, %Stack %stack)
        ret void
}



define ccc void @sharer_206(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_207 = getelementptr <{%Neg}>, %StackPointer %stackPointer, i64 -1
        %Exception_9_10_4420_205_pointer_208 = getelementptr <{%Neg}>, %StackPointer %stackPointer_207, i64 0, i32 0
        %Exception_9_10_4420_205 = load %Neg, ptr %Exception_9_10_4420_205_pointer_208, !noalias !2
        call ccc void @shareNegative(%Neg %Exception_9_10_4420_205)
        call ccc void @shareFrames(%StackPointer %stackPointer_207)
        ret void
}



define ccc void @eraser_210(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_211 = getelementptr <{%Neg}>, %StackPointer %stackPointer, i64 -1
        %Exception_9_10_4420_209_pointer_212 = getelementptr <{%Neg}>, %StackPointer %stackPointer_211, i64 0, i32 0
        %Exception_9_10_4420_209 = load %Neg, ptr %Exception_9_10_4420_209_pointer_212, !noalias !2
        call ccc void @eraseNegative(%Neg %Exception_9_10_4420_209)
        call ccc void @eraseFrames(%StackPointer %stackPointer_211)
        ret void
}



define tailcc void @returnAddress_169(%Pos %v_r_2585_13_45_126_286_4524, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_170 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %Exception_9_10_4420_pointer_171 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_170, i64 0, i32 0
        %Exception_9_10_4420 = load %Neg, ptr %Exception_9_10_4420_pointer_171, !noalias !2
        %p_8_9_75_235_4691_pointer_172 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_170, i64 0, i32 1
        %p_8_9_75_235_4691 = load %Prompt, ptr %p_8_9_75_235_4691_pointer_172, !noalias !2
        %stackPointer_213 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %Exception_9_10_4420_pointer_214 = getelementptr <{%Neg}>, %StackPointer %stackPointer_213, i64 0, i32 0
        store %Neg %Exception_9_10_4420, ptr %Exception_9_10_4420_pointer_214, !noalias !2
        %returnAddress_pointer_215 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 0
        %sharer_pointer_216 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 1
        %eraser_pointer_217 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_213, i64 0, i32 1, i32 2
        store ptr @returnAddress_194, ptr %returnAddress_pointer_215, !noalias !2
        store ptr @sharer_206, ptr %sharer_pointer_216, !noalias !2
        store ptr @eraser_210, ptr %eraser_pointer_217, !noalias !2
        
        %longLiteral_5035 = add i64 1, 0
        
        
        
        
        musttail call tailcc void @go_6_14_46_127_287_4722(%Pos %v_r_2585_13_45_126_286_4524, i64 %longLiteral_5035, %Prompt %p_8_9_75_235_4691, %Stack %stack)
        ret void
}



define ccc void @sharer_220(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_221 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %Exception_9_10_4420_218_pointer_222 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_221, i64 0, i32 0
        %Exception_9_10_4420_218 = load %Neg, ptr %Exception_9_10_4420_218_pointer_222, !noalias !2
        %p_8_9_75_235_4691_219_pointer_223 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_221, i64 0, i32 1
        %p_8_9_75_235_4691_219 = load %Prompt, ptr %p_8_9_75_235_4691_219_pointer_223, !noalias !2
        call ccc void @shareNegative(%Neg %Exception_9_10_4420_218)
        call ccc void @shareFrames(%StackPointer %stackPointer_221)
        ret void
}



define ccc void @eraser_226(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_227 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer, i64 -1
        %Exception_9_10_4420_224_pointer_228 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_227, i64 0, i32 0
        %Exception_9_10_4420_224 = load %Neg, ptr %Exception_9_10_4420_224_pointer_228, !noalias !2
        %p_8_9_75_235_4691_225_pointer_229 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_227, i64 0, i32 1
        %p_8_9_75_235_4691_225 = load %Prompt, ptr %p_8_9_75_235_4691_225_pointer_229, !noalias !2
        call ccc void @eraseNegative(%Neg %Exception_9_10_4420_224)
        call ccc void @eraseFrames(%StackPointer %stackPointer_227)
        ret void
}



define tailcc void @returnAddress_1(%Pos %v_coe_3516_3594, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4995 = call ccc i64 @unboxInt_303(%Pos %v_coe_3516_3594)
        
        
        %stackPointer_97 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 32)
        %tmp_4935_pointer_98 = getelementptr <{i64}>, %StackPointer %stackPointer_97, i64 0, i32 0
        store i64 %pureApp_4995, ptr %tmp_4935_pointer_98, !noalias !2
        %returnAddress_pointer_99 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_97, i64 0, i32 1, i32 0
        %sharer_pointer_100 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_97, i64 0, i32 1, i32 1
        %eraser_pointer_101 = getelementptr <{<{i64}>, %FrameHeader}>, %StackPointer %stackPointer_97, i64 0, i32 1, i32 2
        store ptr @returnAddress_2, ptr %returnAddress_pointer_99, !noalias !2
        store ptr @sharer_25, ptr %sharer_pointer_100, !noalias !2
        store ptr @eraser_29, ptr %eraser_pointer_101, !noalias !2
        
        %stack_102 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4422 = call ccc %Prompt @currentPrompt(%Stack %stack_102)
        %stackPointer_112 = call ccc %StackPointer @stackAllocate(%Stack %stack_102, i64 24)
        %returnAddress_pointer_113 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_112, i64 0, i32 1, i32 0
        %sharer_pointer_114 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_112, i64 0, i32 1, i32 1
        %eraser_pointer_115 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_112, i64 0, i32 1, i32 2
        store ptr @returnAddress_103, ptr %returnAddress_pointer_113, !noalias !2
        store ptr @sharer_108, ptr %sharer_pointer_114, !noalias !2
        store ptr @eraser_110, ptr %eraser_pointer_115, !noalias !2
        
        %closure_125 = call ccc %Object @newObject(ptr @eraser_128, i64 8)
        %environment_126 = call ccc %Environment @objectEnvironment(%Object %closure_125)
        %p_8_9_4422_pointer_130 = getelementptr <{%Prompt}>, %Environment %environment_126, i64 0, i32 0
        store %Prompt %p_8_9_4422, ptr %p_8_9_4422_pointer_130, !noalias !2
        %vtable_temporary_131 = insertvalue %Neg zeroinitializer, ptr @vtable_124, 0
        %Exception_9_10_4420 = insertvalue %Neg %vtable_temporary_131, %Object %closure_125, 1
        %stackPointer_136 = call ccc %StackPointer @stackAllocate(%Stack %stack_102, i64 24)
        %returnAddress_pointer_137 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 0
        %sharer_pointer_138 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 1
        %eraser_pointer_139 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_136, i64 0, i32 1, i32 2
        store ptr @returnAddress_132, ptr %returnAddress_pointer_137, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_138, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_139, !noalias !2
        
        %stack_140 = call ccc %Stack @reset(%Stack %stack_102)
        %p_8_9_75_235_4691 = call ccc %Prompt @currentPrompt(%Stack %stack_140)
        %stackPointer_146 = call ccc %StackPointer @stackAllocate(%Stack %stack_140, i64 24)
        %returnAddress_pointer_147 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 0
        %sharer_pointer_148 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 1
        %eraser_pointer_149 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_146, i64 0, i32 1, i32 2
        store ptr @returnAddress_141, ptr %returnAddress_pointer_147, !noalias !2
        store ptr @sharer_108, ptr %sharer_pointer_148, !noalias !2
        store ptr @eraser_110, ptr %eraser_pointer_149, !noalias !2
        
        %pureApp_5024 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5026 = add i64 1, 0
        
        %pureApp_5025 = call ccc i64 @infixSub_105(i64 %pureApp_5024, i64 %longLiteral_5026)
        
        
        
        %make_5027_temporary_168 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5027 = insertvalue %Pos %make_5027_temporary_168, %Object null, 1
        
        
        %stackPointer_230 = call ccc %StackPointer @stackAllocate(%Stack %stack_140, i64 48)
        %Exception_9_10_4420_pointer_231 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_230, i64 0, i32 0
        store %Neg %Exception_9_10_4420, ptr %Exception_9_10_4420_pointer_231, !noalias !2
        %p_8_9_75_235_4691_pointer_232 = getelementptr <{%Neg, %Prompt}>, %StackPointer %stackPointer_230, i64 0, i32 1
        store %Prompt %p_8_9_75_235_4691, ptr %p_8_9_75_235_4691_pointer_232, !noalias !2
        %returnAddress_pointer_233 = getelementptr <{<{%Neg, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_230, i64 0, i32 1, i32 0
        %sharer_pointer_234 = getelementptr <{<{%Neg, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_230, i64 0, i32 1, i32 1
        %eraser_pointer_235 = getelementptr <{<{%Neg, %Prompt}>, %FrameHeader}>, %StackPointer %stackPointer_230, i64 0, i32 1, i32 2
        store ptr @returnAddress_169, ptr %returnAddress_pointer_233, !noalias !2
        store ptr @sharer_220, ptr %sharer_pointer_234, !noalias !2
        store ptr @eraser_226, ptr %eraser_pointer_235, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_35_116_276_4703(i64 %pureApp_5025, %Pos %make_5027, %Stack %stack_140)
        ret void
}



define tailcc void @returnAddress_241(%Pos %returned_5036, %Stack %stack) {
        
    entry:
        
        %stack_242 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_244 = call ccc %StackPointer @stackDeallocate(%Stack %stack_242, i64 24)
        %returnAddress_pointer_245 = getelementptr %FrameHeader, %StackPointer %stackPointer_244, i64 0, i32 0
        %returnAddress_243 = load %ReturnAddress, ptr %returnAddress_pointer_245, !noalias !2
        musttail call tailcc void %returnAddress_243(%Pos %returned_5036, %Stack %stack_242)
        ret void
}



define tailcc void @Exception_9_10_4029_clause_250(%Object %closure, %Pos %exception_10_11_4035, %Pos %msg_11_12_4037, %Stack %stack) {
        
    entry:
        
        %environment_251 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_9_4031_pointer_252 = getelementptr <{%Prompt}>, %Environment %environment_251, i64 0, i32 0
        %p_8_9_4031 = load %Prompt, ptr %p_8_9_4031_pointer_252, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_11_4035)
        call ccc void @erasePositive(%Pos %msg_11_12_4037)
        
        %pair_253 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_9_4031)
        %k_13_14_4038 = extractvalue <{%Resumption, %Stack}> %pair_253, 0
        %stack_254 = extractvalue <{%Resumption, %Stack}> %pair_253, 1
        call ccc void @eraseResumption(%Resumption %k_13_14_4038)
        
        %longLiteral_5037 = add i64 5, 0
        
        
        
        %pureApp_5038 = call ccc %Pos @boxInt_301(i64 %longLiteral_5037)
        
        
        
        %stackPointer_256 = call ccc %StackPointer @stackDeallocate(%Stack %stack_254, i64 24)
        %returnAddress_pointer_257 = getelementptr %FrameHeader, %StackPointer %stackPointer_256, i64 0, i32 0
        %returnAddress_255 = load %ReturnAddress, ptr %returnAddress_pointer_257, !noalias !2
        musttail call tailcc void %returnAddress_255(%Pos %pureApp_5038, %Stack %stack_254)
        ret void
}


@vtable_258 = private constant [1 x ptr] [ptr @Exception_9_10_4029_clause_250]


define tailcc void @toList_1_1_3_34_4067(i64 %start_2_2_4_35_4093, %Pos %acc_3_3_5_36_4090, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_5040 = add i64 1, 0
        
        %pureApp_5039 = call ccc %Pos @infixLt_178(i64 %start_2_2_4_35_4093, i64 %longLiteral_5040)
        
        
        
        %tag_264 = extractvalue %Pos %pureApp_5039, 0
        %fields_265 = extractvalue %Pos %pureApp_5039, 1
        switch i64 %tag_264, label %label_266 [i64 0, label %label_274 i64 1, label %label_278]
    
    label_266:
        
        ret void
    
    label_274:
        
        %pureApp_5041 = call ccc %Pos @argument_2385(i64 %start_2_2_4_35_4093)
        
        
        
        %longLiteral_5043 = add i64 1, 0
        
        %pureApp_5042 = call ccc i64 @infixSub_105(i64 %start_2_2_4_35_4093, i64 %longLiteral_5043)
        
        
        
        %fields_267 = call ccc %Object @newObject(ptr @eraser_157, i64 32)
        %environment_268 = call ccc %Environment @objectEnvironment(%Object %fields_267)
        %tmp_4899_pointer_271 = getelementptr <{%Pos, %Pos}>, %Environment %environment_268, i64 0, i32 0
        store %Pos %pureApp_5041, ptr %tmp_4899_pointer_271, !noalias !2
        %acc_3_3_5_36_4090_pointer_272 = getelementptr <{%Pos, %Pos}>, %Environment %environment_268, i64 0, i32 1
        store %Pos %acc_3_3_5_36_4090, ptr %acc_3_3_5_36_4090_pointer_272, !noalias !2
        %make_5044_temporary_273 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5044 = insertvalue %Pos %make_5044_temporary_273, %Object %fields_267, 1
        
        
        
        
        
        
        musttail call tailcc void @toList_1_1_3_34_4067(i64 %pureApp_5042, %Pos %make_5044, %Stack %stack)
        ret void
    
    label_278:
        
        %stackPointer_276 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_277 = getelementptr %FrameHeader, %StackPointer %stackPointer_276, i64 0, i32 0
        %returnAddress_275 = load %ReturnAddress, ptr %returnAddress_pointer_277, !noalias !2
        musttail call tailcc void %returnAddress_275(%Pos %acc_3_3_5_36_4090, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_289(i64 %v_coe_3514_62_4089, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_5049 = call ccc %Pos @boxInt_301(i64 %v_coe_3514_62_4089)
        
        
        
        %stackPointer_291 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_292 = getelementptr %FrameHeader, %StackPointer %stackPointer_291, i64 0, i32 0
        %returnAddress_290 = load %ReturnAddress, ptr %returnAddress_pointer_292, !noalias !2
        musttail call tailcc void %returnAddress_290(%Pos %pureApp_5049, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_286(%Pos %v_r_2582_30_61_4065, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_287 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %Exception_9_10_4029_pointer_288 = getelementptr <{%Neg}>, %StackPointer %stackPointer_287, i64 0, i32 0
        %Exception_9_10_4029 = load %Neg, ptr %Exception_9_10_4029_pointer_288, !noalias !2
        %stackPointer_293 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_294 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_293, i64 0, i32 1, i32 0
        %sharer_pointer_295 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_293, i64 0, i32 1, i32 1
        %eraser_pointer_296 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_293, i64 0, i32 1, i32 2
        store ptr @returnAddress_289, ptr %returnAddress_pointer_294, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_295, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_296, !noalias !2
        
        
        
        
        musttail call tailcc void @toInt_2062(%Pos %v_r_2582_30_61_4065, %Neg %Exception_9_10_4029, %Stack %stack)
        ret void
}


@utf8StringLiteral_5050.lit = private constant [0 x i8] c""


define tailcc void @returnAddress_283(%Pos %v_r_2581_24_55_4096, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_284 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %Exception_9_10_4029_pointer_285 = getelementptr <{%Neg}>, %StackPointer %stackPointer_284, i64 0, i32 0
        %Exception_9_10_4029 = load %Neg, ptr %Exception_9_10_4029_pointer_285, !noalias !2
        %stackPointer_299 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %Exception_9_10_4029_pointer_300 = getelementptr <{%Neg}>, %StackPointer %stackPointer_299, i64 0, i32 0
        store %Neg %Exception_9_10_4029, ptr %Exception_9_10_4029_pointer_300, !noalias !2
        %returnAddress_pointer_301 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_299, i64 0, i32 1, i32 0
        %sharer_pointer_302 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_299, i64 0, i32 1, i32 1
        %eraser_pointer_303 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_299, i64 0, i32 1, i32 2
        store ptr @returnAddress_286, ptr %returnAddress_pointer_301, !noalias !2
        store ptr @sharer_206, ptr %sharer_pointer_302, !noalias !2
        store ptr @eraser_210, ptr %eraser_pointer_303, !noalias !2
        
        %tag_304 = extractvalue %Pos %v_r_2581_24_55_4096, 0
        %fields_305 = extractvalue %Pos %v_r_2581_24_55_4096, 1
        switch i64 %tag_304, label %label_306 [i64 0, label %label_310 i64 1, label %label_316]
    
    label_306:
        
        ret void
    
    label_310:
        
        %utf8StringLiteral_5050 = call ccc %Pos @c_bytearray_construct(i64 0, ptr @utf8StringLiteral_5050.lit)
        
        %stackPointer_308 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_309 = getelementptr %FrameHeader, %StackPointer %stackPointer_308, i64 0, i32 0
        %returnAddress_307 = load %ReturnAddress, ptr %returnAddress_pointer_309, !noalias !2
        musttail call tailcc void %returnAddress_307(%Pos %utf8StringLiteral_5050, %Stack %stack)
        ret void
    
    label_316:
        %environment_311 = call ccc %Environment @objectEnvironment(%Object %fields_305)
        %v_y_3312_8_29_60_4058_pointer_312 = getelementptr <{%Pos}>, %Environment %environment_311, i64 0, i32 0
        %v_y_3312_8_29_60_4058 = load %Pos, ptr %v_y_3312_8_29_60_4058_pointer_312, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_3312_8_29_60_4058)
        call ccc void @eraseObject(%Object %fields_305)
        
        %stackPointer_314 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_315 = getelementptr %FrameHeader, %StackPointer %stackPointer_314, i64 0, i32 0
        %returnAddress_313 = load %ReturnAddress, ptr %returnAddress_pointer_315, !noalias !2
        musttail call tailcc void %returnAddress_313(%Pos %v_y_3312_8_29_60_4058, %Stack %stack)
        ret void
}



define ccc void @eraser_338(%Environment %environment) {
        
    entry:
        
        %v_y_2821_10_21_52_4073_337_pointer_339 = getelementptr <{%Pos}>, %Environment %environment, i64 0, i32 0
        %v_y_2821_10_21_52_4073_337 = load %Pos, ptr %v_y_2821_10_21_52_4073_337_pointer_339, !noalias !2
        call ccc void @erasePositive(%Pos %v_y_2821_10_21_52_4073_337)
        ret void
}



define tailcc void @returnAddress_280(%Pos %v_r_2580_13_44_4057, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_281 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 16)
        %Exception_9_10_4029_pointer_282 = getelementptr <{%Neg}>, %StackPointer %stackPointer_281, i64 0, i32 0
        %Exception_9_10_4029 = load %Neg, ptr %Exception_9_10_4029_pointer_282, !noalias !2
        %stackPointer_319 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 40)
        %Exception_9_10_4029_pointer_320 = getelementptr <{%Neg}>, %StackPointer %stackPointer_319, i64 0, i32 0
        store %Neg %Exception_9_10_4029, ptr %Exception_9_10_4029_pointer_320, !noalias !2
        %returnAddress_pointer_321 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_319, i64 0, i32 1, i32 0
        %sharer_pointer_322 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_319, i64 0, i32 1, i32 1
        %eraser_pointer_323 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_319, i64 0, i32 1, i32 2
        store ptr @returnAddress_283, ptr %returnAddress_pointer_321, !noalias !2
        store ptr @sharer_206, ptr %sharer_pointer_322, !noalias !2
        store ptr @eraser_210, ptr %eraser_pointer_323, !noalias !2
        
        %tag_324 = extractvalue %Pos %v_r_2580_13_44_4057, 0
        %fields_325 = extractvalue %Pos %v_r_2580_13_44_4057, 1
        switch i64 %tag_324, label %label_326 [i64 0, label %label_331 i64 1, label %label_345]
    
    label_326:
        
        ret void
    
    label_331:
        
        %make_5051_temporary_327 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5051 = insertvalue %Pos %make_5051_temporary_327, %Object null, 1
        
        
        
        %stackPointer_329 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_330 = getelementptr %FrameHeader, %StackPointer %stackPointer_329, i64 0, i32 0
        %returnAddress_328 = load %ReturnAddress, ptr %returnAddress_pointer_330, !noalias !2
        musttail call tailcc void %returnAddress_328(%Pos %make_5051, %Stack %stack)
        ret void
    
    label_345:
        %environment_332 = call ccc %Environment @objectEnvironment(%Object %fields_325)
        %v_y_2821_10_21_52_4073_pointer_333 = getelementptr <{%Pos, %Pos}>, %Environment %environment_332, i64 0, i32 0
        %v_y_2821_10_21_52_4073 = load %Pos, ptr %v_y_2821_10_21_52_4073_pointer_333, !noalias !2
        %v_y_2822_11_22_53_4094_pointer_334 = getelementptr <{%Pos, %Pos}>, %Environment %environment_332, i64 0, i32 1
        %v_y_2822_11_22_53_4094 = load %Pos, ptr %v_y_2822_11_22_53_4094_pointer_334, !noalias !2
        call ccc void @sharePositive(%Pos %v_y_2821_10_21_52_4073)
        call ccc void @eraseObject(%Object %fields_325)
        
        %fields_335 = call ccc %Object @newObject(ptr @eraser_338, i64 16)
        %environment_336 = call ccc %Environment @objectEnvironment(%Object %fields_335)
        %v_y_2821_10_21_52_4073_pointer_340 = getelementptr <{%Pos}>, %Environment %environment_336, i64 0, i32 0
        store %Pos %v_y_2821_10_21_52_4073, ptr %v_y_2821_10_21_52_4073_pointer_340, !noalias !2
        %make_5052_temporary_341 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_5052 = insertvalue %Pos %make_5052_temporary_341, %Object %fields_335, 1
        
        
        
        %stackPointer_343 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_344 = getelementptr %FrameHeader, %StackPointer %stackPointer_343, i64 0, i32 0
        %returnAddress_342 = load %ReturnAddress, ptr %returnAddress_pointer_344, !noalias !2
        musttail call tailcc void %returnAddress_342(%Pos %make_5052, %Stack %stack)
        ret void
}



define tailcc void @main_2445(%Stack %stack) {
        
    entry:
        
        %stackPointer_236 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_237 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_236, i64 0, i32 1, i32 0
        %sharer_pointer_238 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_236, i64 0, i32 1, i32 1
        %eraser_pointer_239 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_236, i64 0, i32 1, i32 2
        store ptr @returnAddress_1, ptr %returnAddress_pointer_237, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_238, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_239, !noalias !2
        
        %stack_240 = call ccc %Stack @reset(%Stack %stack)
        %p_8_9_4031 = call ccc %Prompt @currentPrompt(%Stack %stack_240)
        %stackPointer_246 = call ccc %StackPointer @stackAllocate(%Stack %stack_240, i64 24)
        %returnAddress_pointer_247 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_246, i64 0, i32 1, i32 0
        %sharer_pointer_248 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_246, i64 0, i32 1, i32 1
        %eraser_pointer_249 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_246, i64 0, i32 1, i32 2
        store ptr @returnAddress_241, ptr %returnAddress_pointer_247, !noalias !2
        store ptr @sharer_108, ptr %sharer_pointer_248, !noalias !2
        store ptr @eraser_110, ptr %eraser_pointer_249, !noalias !2
        
        %closure_259 = call ccc %Object @newObject(ptr @eraser_128, i64 8)
        %environment_260 = call ccc %Environment @objectEnvironment(%Object %closure_259)
        %p_8_9_4031_pointer_262 = getelementptr <{%Prompt}>, %Environment %environment_260, i64 0, i32 0
        store %Prompt %p_8_9_4031, ptr %p_8_9_4031_pointer_262, !noalias !2
        %vtable_temporary_263 = insertvalue %Neg zeroinitializer, ptr @vtable_258, 0
        %Exception_9_10_4029 = insertvalue %Neg %vtable_temporary_263, %Object %closure_259, 1
        
        %pureApp_5045 = call ccc i64 @argCount_2383()
        
        
        
        %longLiteral_5047 = add i64 1, 0
        
        %pureApp_5046 = call ccc i64 @infixSub_105(i64 %pureApp_5045, i64 %longLiteral_5047)
        
        
        
        %make_5048_temporary_279 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_5048 = insertvalue %Pos %make_5048_temporary_279, %Object null, 1
        
        
        %stackPointer_348 = call ccc %StackPointer @stackAllocate(%Stack %stack_240, i64 40)
        %Exception_9_10_4029_pointer_349 = getelementptr <{%Neg}>, %StackPointer %stackPointer_348, i64 0, i32 0
        store %Neg %Exception_9_10_4029, ptr %Exception_9_10_4029_pointer_349, !noalias !2
        %returnAddress_pointer_350 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_348, i64 0, i32 1, i32 0
        %sharer_pointer_351 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_348, i64 0, i32 1, i32 1
        %eraser_pointer_352 = getelementptr <{<{%Neg}>, %FrameHeader}>, %StackPointer %stackPointer_348, i64 0, i32 1, i32 2
        store ptr @returnAddress_280, ptr %returnAddress_pointer_350, !noalias !2
        store ptr @sharer_206, ptr %sharer_pointer_351, !noalias !2
        store ptr @eraser_210, ptr %eraser_pointer_352, !noalias !2
        
        
        
        
        musttail call tailcc void @toList_1_1_3_34_4067(i64 %pureApp_5046, %Pos %make_5048, %Stack %stack_240)
        ret void
}


@utf8StringLiteral_4986.lit = private constant [21 x i8] c"\49\6e\64\65\78\20\6f\75\74\20\6f\66\20\62\6f\75\6e\64\73\3a\20"

@utf8StringLiteral_4988.lit = private constant [13 x i8] c"\20\69\6e\20\73\74\72\69\6e\67\3a\20\27"

@utf8StringLiteral_4991.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_353(%Pos %v_r_2752_3561, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_354 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %str_2106_pointer_355 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_354, i64 0, i32 0
        %str_2106 = load %Pos, ptr %str_2106_pointer_355, !noalias !2
        %index_2107_pointer_356 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_354, i64 0, i32 1
        %index_2107 = load i64, ptr %index_2107_pointer_356, !noalias !2
        %Exception_2362_pointer_357 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_354, i64 0, i32 2
        %Exception_2362 = load %Neg, ptr %Exception_2362_pointer_357, !noalias !2
        
        %tag_358 = extractvalue %Pos %v_r_2752_3561, 0
        %fields_359 = extractvalue %Pos %v_r_2752_3561, 1
        switch i64 %tag_358, label %label_360 [i64 0, label %label_364 i64 1, label %label_370]
    
    label_360:
        
        ret void
    
    label_364:
        call ccc void @eraseNegative(%Neg %Exception_2362)
        
        %pureApp_4982 = call ccc i64 @unsafeCharAt_2111(%Pos %str_2106, i64 %index_2107)
        
        
        
        %stackPointer_362 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_363 = getelementptr %FrameHeader, %StackPointer %stackPointer_362, i64 0, i32 0
        %returnAddress_361 = load %ReturnAddress, ptr %returnAddress_pointer_363, !noalias !2
        musttail call tailcc void %returnAddress_361(i64 %pureApp_4982, %Stack %stack)
        ret void
    
    label_370:
        
        %make_4983_temporary_365 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4983 = insertvalue %Pos %make_4983_temporary_365, %Object null, 1
        
        
        
        %pureApp_4984 = call ccc %Pos @show_14(i64 %index_2107)
        
        
        
        %utf8StringLiteral_4986 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4986.lit)
        
        %pureApp_4985 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4986, %Pos %pureApp_4984)
        
        
        
        %utf8StringLiteral_4988 = call ccc %Pos @c_bytearray_construct(i64 13, ptr @utf8StringLiteral_4988.lit)
        
        %pureApp_4987 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4985, %Pos %utf8StringLiteral_4988)
        
        
        
        %pureApp_4989 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4987, %Pos %str_2106)
        
        
        
        %utf8StringLiteral_4991 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4991.lit)
        
        %pureApp_4990 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4989, %Pos %utf8StringLiteral_4991)
        
        
        
        %vtable_366 = extractvalue %Neg %Exception_2362, 0
        %closure_367 = extractvalue %Neg %Exception_2362, 1
        %functionPointer_pointer_368 = getelementptr ptr, ptr %vtable_366, i64 0
        %functionPointer_369 = load ptr, ptr %functionPointer_pointer_368, !noalias !2
        musttail call tailcc void %functionPointer_369(%Object %closure_367, %Pos %make_4983, %Pos %pureApp_4990, %Stack %stack)
        ret void
}



define ccc void @sharer_374(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_375 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_371_pointer_376 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_375, i64 0, i32 0
        %str_2106_371 = load %Pos, ptr %str_2106_371_pointer_376, !noalias !2
        %index_2107_372_pointer_377 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_375, i64 0, i32 1
        %index_2107_372 = load i64, ptr %index_2107_372_pointer_377, !noalias !2
        %Exception_2362_373_pointer_378 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_375, i64 0, i32 2
        %Exception_2362_373 = load %Neg, ptr %Exception_2362_373_pointer_378, !noalias !2
        call ccc void @sharePositive(%Pos %str_2106_371)
        call ccc void @shareNegative(%Neg %Exception_2362_373)
        call ccc void @shareFrames(%StackPointer %stackPointer_375)
        ret void
}



define ccc void @eraser_382(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_383 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %str_2106_379_pointer_384 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_383, i64 0, i32 0
        %str_2106_379 = load %Pos, ptr %str_2106_379_pointer_384, !noalias !2
        %index_2107_380_pointer_385 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_383, i64 0, i32 1
        %index_2107_380 = load i64, ptr %index_2107_380_pointer_385, !noalias !2
        %Exception_2362_381_pointer_386 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_383, i64 0, i32 2
        %Exception_2362_381 = load %Neg, ptr %Exception_2362_381_pointer_386, !noalias !2
        call ccc void @erasePositive(%Pos %str_2106_379)
        call ccc void @eraseNegative(%Neg %Exception_2362_381)
        call ccc void @eraseFrames(%StackPointer %stackPointer_383)
        ret void
}



define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, %Stack %stack) {
        
    entry:
        
        
        %longLiteral_4981 = add i64 0, 0
        
        %pureApp_4980 = call ccc %Pos @infixLt_178(i64 %index_2107, i64 %longLiteral_4981)
        
        
        call ccc void @sharePositive(%Pos %str_2106)
        %stackPointer_387 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 64)
        %str_2106_pointer_388 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_387, i64 0, i32 0
        store %Pos %str_2106, ptr %str_2106_pointer_388, !noalias !2
        %index_2107_pointer_389 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_387, i64 0, i32 1
        store i64 %index_2107, ptr %index_2107_pointer_389, !noalias !2
        %Exception_2362_pointer_390 = getelementptr <{%Pos, i64, %Neg}>, %StackPointer %stackPointer_387, i64 0, i32 2
        store %Neg %Exception_2362, ptr %Exception_2362_pointer_390, !noalias !2
        %returnAddress_pointer_391 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_387, i64 0, i32 1, i32 0
        %sharer_pointer_392 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_387, i64 0, i32 1, i32 1
        %eraser_pointer_393 = getelementptr <{<{%Pos, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_387, i64 0, i32 1, i32 2
        store ptr @returnAddress_353, ptr %returnAddress_pointer_391, !noalias !2
        store ptr @sharer_374, ptr %sharer_pointer_392, !noalias !2
        store ptr @eraser_382, ptr %eraser_pointer_393, !noalias !2
        
        %tag_394 = extractvalue %Pos %pureApp_4980, 0
        %fields_395 = extractvalue %Pos %pureApp_4980, 1
        switch i64 %tag_394, label %label_396 [i64 0, label %label_400 i64 1, label %label_405]
    
    label_396:
        
        ret void
    
    label_400:
        
        %pureApp_4992 = call ccc i64 @length_37(%Pos %str_2106)
        
        
        
        %pureApp_4993 = call ccc %Pos @infixGte_187(i64 %index_2107, i64 %pureApp_4992)
        
        
        
        %stackPointer_398 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_399 = getelementptr %FrameHeader, %StackPointer %stackPointer_398, i64 0, i32 0
        %returnAddress_397 = load %ReturnAddress, ptr %returnAddress_pointer_399, !noalias !2
        musttail call tailcc void %returnAddress_397(%Pos %pureApp_4993, %Stack %stack)
        ret void
    
    label_405:
        call ccc void @erasePositive(%Pos %str_2106)
        
        %booleanLiteral_4994_temporary_401 = insertvalue %Pos zeroinitializer, i64 1, 0
        %booleanLiteral_4994 = insertvalue %Pos %booleanLiteral_4994_temporary_401, %Object null, 1
        
        %stackPointer_403 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_404 = getelementptr %FrameHeader, %StackPointer %stackPointer_403, i64 0, i32 0
        %returnAddress_402 = load %ReturnAddress, ptr %returnAddress_pointer_404, !noalias !2
        musttail call tailcc void %returnAddress_402(%Pos %booleanLiteral_4994, %Stack %stack)
        ret void
}


@utf8StringLiteral_4942.lit = private constant [21 x i8] c"\4e\6f\74\20\61\20\76\61\6c\69\64\20\6e\75\6d\62\65\72\3a\20\27"

@utf8StringLiteral_4944.lit = private constant [1 x i8] c"\27"

@utf8StringLiteral_4949.lit = private constant [21 x i8] c"\4e\6f\74\20\61\20\76\61\6c\69\64\20\6e\75\6d\62\65\72\3a\20\27"

@utf8StringLiteral_4951.lit = private constant [1 x i8] c"\27"


define tailcc void @returnAddress_406(%Pos %v_r_2670_3577, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_407 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 56)
        %tmp_4932_pointer_408 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_407, i64 0, i32 0
        %tmp_4932 = load i64, ptr %tmp_4932_pointer_408, !noalias !2
        %str_2061_pointer_409 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_407, i64 0, i32 1
        %str_2061 = load %Pos, ptr %str_2061_pointer_409, !noalias !2
        %index_2146_pointer_410 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_407, i64 0, i32 2
        %index_2146 = load i64, ptr %index_2146_pointer_410, !noalias !2
        %acc_2147_pointer_411 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_407, i64 0, i32 3
        %acc_2147 = load i64, ptr %acc_2147_pointer_411, !noalias !2
        %Exception_2356_pointer_412 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_407, i64 0, i32 4
        %Exception_2356 = load %Neg, ptr %Exception_2356_pointer_412, !noalias !2
        
        %tag_413 = extractvalue %Pos %v_r_2670_3577, 0
        %fields_414 = extractvalue %Pos %v_r_2670_3577, 1
        switch i64 %tag_413, label %label_415 [i64 1, label %label_438 i64 0, label %label_445]
    
    label_415:
        
        ret void
    
    label_420:
        
        ret void
    
    label_426:
        
        %utf8StringLiteral_4942 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4942.lit)
        
        %pureApp_4941 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4942, %Pos %str_2061)
        
        
        
        %utf8StringLiteral_4944 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4944.lit)
        
        %pureApp_4943 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4941, %Pos %utf8StringLiteral_4944)
        
        
        
        %make_4945_temporary_421 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4945 = insertvalue %Pos %make_4945_temporary_421, %Object null, 1
        
        
        
        %vtable_422 = extractvalue %Neg %Exception_2356, 0
        %closure_423 = extractvalue %Neg %Exception_2356, 1
        %functionPointer_pointer_424 = getelementptr ptr, ptr %vtable_422, i64 0
        %functionPointer_425 = load ptr, ptr %functionPointer_pointer_424, !noalias !2
        musttail call tailcc void %functionPointer_425(%Object %closure_423, %Pos %make_4945, %Pos %pureApp_4943, %Stack %stack)
        ret void
    
    label_429:
        
        ret void
    
    label_435:
        
        %utf8StringLiteral_4949 = call ccc %Pos @c_bytearray_construct(i64 21, ptr @utf8StringLiteral_4949.lit)
        
        %pureApp_4948 = call ccc %Pos @infixConcat_35(%Pos %utf8StringLiteral_4949, %Pos %str_2061)
        
        
        
        %utf8StringLiteral_4951 = call ccc %Pos @c_bytearray_construct(i64 1, ptr @utf8StringLiteral_4951.lit)
        
        %pureApp_4950 = call ccc %Pos @infixConcat_35(%Pos %pureApp_4948, %Pos %utf8StringLiteral_4951)
        
        
        
        %make_4952_temporary_430 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4952 = insertvalue %Pos %make_4952_temporary_430, %Object null, 1
        
        
        
        %vtable_431 = extractvalue %Neg %Exception_2356, 0
        %closure_432 = extractvalue %Neg %Exception_2356, 1
        %functionPointer_pointer_433 = getelementptr ptr, ptr %vtable_431, i64 0
        %functionPointer_434 = load ptr, ptr %functionPointer_pointer_433, !noalias !2
        musttail call tailcc void %functionPointer_434(%Object %closure_432, %Pos %make_4952, %Pos %pureApp_4950, %Stack %stack)
        ret void
    
    label_436:
        
        %longLiteral_4954 = add i64 1, 0
        
        %pureApp_4953 = call ccc i64 @infixAdd_96(i64 %index_2146, i64 %longLiteral_4954)
        
        
        
        %longLiteral_4956 = add i64 10, 0
        
        %pureApp_4955 = call ccc i64 @infixMul_99(i64 %longLiteral_4956, i64 %acc_2147)
        
        
        
        %pureApp_4957 = call ccc i64 @toInt_2085(i64 %pureApp_4938)
        
        
        
        %pureApp_4958 = call ccc i64 @infixSub_105(i64 %pureApp_4957, i64 %tmp_4932)
        
        
        
        %pureApp_4959 = call ccc i64 @infixAdd_96(i64 %pureApp_4955, i64 %pureApp_4958)
        
        
        
        
        
        
        musttail call tailcc void @go_2148(i64 %pureApp_4953, i64 %pureApp_4959, i64 %tmp_4932, %Pos %str_2061, %Neg %Exception_2356, %Stack %stack)
        ret void
    
    label_437:
        
        %intLiteral_4947 = add i64 57, 0
        
        %pureApp_4946 = call ccc %Pos @infixLte_2093(i64 %pureApp_4938, i64 %intLiteral_4947)
        
        
        
        %tag_427 = extractvalue %Pos %pureApp_4946, 0
        %fields_428 = extractvalue %Pos %pureApp_4946, 1
        switch i64 %tag_427, label %label_429 [i64 0, label %label_435 i64 1, label %label_436]
    
    label_438:
        %environment_416 = call ccc %Environment @objectEnvironment(%Object %fields_414)
        %v_coe_3486_3582_pointer_417 = getelementptr <{%Pos}>, %Environment %environment_416, i64 0, i32 0
        %v_coe_3486_3582 = load %Pos, ptr %v_coe_3486_3582_pointer_417, !noalias !2
        call ccc void @sharePositive(%Pos %v_coe_3486_3582)
        call ccc void @eraseObject(%Object %fields_414)
        
        %pureApp_4938 = call ccc i64 @unboxChar_313(%Pos %v_coe_3486_3582)
        
        
        
        %intLiteral_4940 = add i64 48, 0
        
        %pureApp_4939 = call ccc %Pos @infixGte_2099(i64 %pureApp_4938, i64 %intLiteral_4940)
        
        
        
        %tag_418 = extractvalue %Pos %pureApp_4939, 0
        %fields_419 = extractvalue %Pos %pureApp_4939, 1
        switch i64 %tag_418, label %label_420 [i64 0, label %label_426 i64 1, label %label_437]
    
    label_445:
        %environment_439 = call ccc %Environment @objectEnvironment(%Object %fields_414)
        %v_y_2677_2680_pointer_440 = getelementptr <{%Pos, %Pos}>, %Environment %environment_439, i64 0, i32 0
        %v_y_2677_2680 = load %Pos, ptr %v_y_2677_2680_pointer_440, !noalias !2
        %v_y_2678_2679_pointer_441 = getelementptr <{%Pos, %Pos}>, %Environment %environment_439, i64 0, i32 1
        %v_y_2678_2679 = load %Pos, ptr %v_y_2678_2679_pointer_441, !noalias !2
        call ccc void @eraseObject(%Object %fields_414)
        call ccc void @erasePositive(%Pos %str_2061)
        call ccc void @eraseNegative(%Neg %Exception_2356)
        
        %stackPointer_443 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_444 = getelementptr %FrameHeader, %StackPointer %stackPointer_443, i64 0, i32 0
        %returnAddress_442 = load %ReturnAddress, ptr %returnAddress_pointer_444, !noalias !2
        musttail call tailcc void %returnAddress_442(i64 %acc_2147, %Stack %stack)
        ret void
}



define ccc void @sharer_451(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_452 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %tmp_4932_446_pointer_453 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_452, i64 0, i32 0
        %tmp_4932_446 = load i64, ptr %tmp_4932_446_pointer_453, !noalias !2
        %str_2061_447_pointer_454 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_452, i64 0, i32 1
        %str_2061_447 = load %Pos, ptr %str_2061_447_pointer_454, !noalias !2
        %index_2146_448_pointer_455 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_452, i64 0, i32 2
        %index_2146_448 = load i64, ptr %index_2146_448_pointer_455, !noalias !2
        %acc_2147_449_pointer_456 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_452, i64 0, i32 3
        %acc_2147_449 = load i64, ptr %acc_2147_449_pointer_456, !noalias !2
        %Exception_2356_450_pointer_457 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_452, i64 0, i32 4
        %Exception_2356_450 = load %Neg, ptr %Exception_2356_450_pointer_457, !noalias !2
        call ccc void @sharePositive(%Pos %str_2061_447)
        call ccc void @shareNegative(%Neg %Exception_2356_450)
        call ccc void @shareFrames(%StackPointer %stackPointer_452)
        ret void
}



define ccc void @eraser_463(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_464 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer, i64 -1
        %tmp_4932_458_pointer_465 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_464, i64 0, i32 0
        %tmp_4932_458 = load i64, ptr %tmp_4932_458_pointer_465, !noalias !2
        %str_2061_459_pointer_466 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_464, i64 0, i32 1
        %str_2061_459 = load %Pos, ptr %str_2061_459_pointer_466, !noalias !2
        %index_2146_460_pointer_467 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_464, i64 0, i32 2
        %index_2146_460 = load i64, ptr %index_2146_460_pointer_467, !noalias !2
        %acc_2147_461_pointer_468 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_464, i64 0, i32 3
        %acc_2147_461 = load i64, ptr %acc_2147_461_pointer_468, !noalias !2
        %Exception_2356_462_pointer_469 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_464, i64 0, i32 4
        %Exception_2356_462 = load %Neg, ptr %Exception_2356_462_pointer_469, !noalias !2
        call ccc void @erasePositive(%Pos %str_2061_459)
        call ccc void @eraseNegative(%Neg %Exception_2356_462)
        call ccc void @eraseFrames(%StackPointer %stackPointer_464)
        ret void
}



define tailcc void @returnAddress_480(%Pos %returned_4960, %Stack %stack) {
        
    entry:
        
        %stack_481 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_483 = call ccc %StackPointer @stackDeallocate(%Stack %stack_481, i64 24)
        %returnAddress_pointer_484 = getelementptr %FrameHeader, %StackPointer %stackPointer_483, i64 0, i32 0
        %returnAddress_482 = load %ReturnAddress, ptr %returnAddress_pointer_484, !noalias !2
        musttail call tailcc void %returnAddress_482(%Pos %returned_4960, %Stack %stack_481)
        ret void
}



define tailcc void @Exception_7_3756_clause_489(%Object %closure, %Pos %exc_8_3754, %Pos %msg_9_3759, %Stack %stack) {
        
    entry:
        
        %environment_490 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_6_3755_pointer_491 = getelementptr <{%Prompt}>, %Environment %environment_490, i64 0, i32 0
        %p_6_3755 = load %Prompt, ptr %p_6_3755_pointer_491, !noalias !2
        call ccc void @eraseObject(%Object %closure)
        
        %pair_492 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_6_3755)
        %k_11_3765 = extractvalue <{%Resumption, %Stack}> %pair_492, 0
        %stack_493 = extractvalue <{%Resumption, %Stack}> %pair_492, 1
        call ccc void @eraseResumption(%Resumption %k_11_3765)
        
        %fields_494 = call ccc %Object @newObject(ptr @eraser_157, i64 32)
        %environment_495 = call ccc %Environment @objectEnvironment(%Object %fields_494)
        %exc_8_3754_pointer_498 = getelementptr <{%Pos, %Pos}>, %Environment %environment_495, i64 0, i32 0
        store %Pos %exc_8_3754, ptr %exc_8_3754_pointer_498, !noalias !2
        %msg_9_3759_pointer_499 = getelementptr <{%Pos, %Pos}>, %Environment %environment_495, i64 0, i32 1
        store %Pos %msg_9_3759, ptr %msg_9_3759_pointer_499, !noalias !2
        %make_4961_temporary_500 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4961 = insertvalue %Pos %make_4961_temporary_500, %Object %fields_494, 1
        
        
        
        %stackPointer_502 = call ccc %StackPointer @stackDeallocate(%Stack %stack_493, i64 24)
        %returnAddress_pointer_503 = getelementptr %FrameHeader, %StackPointer %stackPointer_502, i64 0, i32 0
        %returnAddress_501 = load %ReturnAddress, ptr %returnAddress_pointer_503, !noalias !2
        musttail call tailcc void %returnAddress_501(%Pos %make_4961, %Stack %stack_493)
        ret void
}


@vtable_504 = private constant [1 x ptr] [ptr @Exception_7_3756_clause_489]


define tailcc void @returnAddress_510(i64 %v_coe_3485_6_3767, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4962 = call ccc %Pos @boxChar_311(i64 %v_coe_3485_6_3767)
        
        
        
        %fields_511 = call ccc %Object @newObject(ptr @eraser_338, i64 16)
        %environment_512 = call ccc %Environment @objectEnvironment(%Object %fields_511)
        %tmp_4869_pointer_514 = getelementptr <{%Pos}>, %Environment %environment_512, i64 0, i32 0
        store %Pos %pureApp_4962, ptr %tmp_4869_pointer_514, !noalias !2
        %make_4963_temporary_515 = insertvalue %Pos zeroinitializer, i64 1, 0
        %make_4963 = insertvalue %Pos %make_4963_temporary_515, %Object %fields_511, 1
        
        
        
        %stackPointer_517 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_518 = getelementptr %FrameHeader, %StackPointer %stackPointer_517, i64 0, i32 0
        %returnAddress_516 = load %ReturnAddress, ptr %returnAddress_pointer_518, !noalias !2
        musttail call tailcc void %returnAddress_516(%Pos %make_4963, %Stack %stack)
        ret void
}



define tailcc void @go_2148(i64 %index_2146, i64 %acc_2147, i64 %tmp_4932, %Pos %str_2061, %Neg %Exception_2356, %Stack %stack) {
        
    entry:
        
        call ccc void @sharePositive(%Pos %str_2061)
        %stackPointer_470 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 80)
        %tmp_4932_pointer_471 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_470, i64 0, i32 0
        store i64 %tmp_4932, ptr %tmp_4932_pointer_471, !noalias !2
        %str_2061_pointer_472 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_470, i64 0, i32 1
        store %Pos %str_2061, ptr %str_2061_pointer_472, !noalias !2
        %index_2146_pointer_473 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_470, i64 0, i32 2
        store i64 %index_2146, ptr %index_2146_pointer_473, !noalias !2
        %acc_2147_pointer_474 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_470, i64 0, i32 3
        store i64 %acc_2147, ptr %acc_2147_pointer_474, !noalias !2
        %Exception_2356_pointer_475 = getelementptr <{i64, %Pos, i64, i64, %Neg}>, %StackPointer %stackPointer_470, i64 0, i32 4
        store %Neg %Exception_2356, ptr %Exception_2356_pointer_475, !noalias !2
        %returnAddress_pointer_476 = getelementptr <{<{i64, %Pos, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_470, i64 0, i32 1, i32 0
        %sharer_pointer_477 = getelementptr <{<{i64, %Pos, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_470, i64 0, i32 1, i32 1
        %eraser_pointer_478 = getelementptr <{<{i64, %Pos, i64, i64, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_470, i64 0, i32 1, i32 2
        store ptr @returnAddress_406, ptr %returnAddress_pointer_476, !noalias !2
        store ptr @sharer_451, ptr %sharer_pointer_477, !noalias !2
        store ptr @eraser_463, ptr %eraser_pointer_478, !noalias !2
        
        %stack_479 = call ccc %Stack @reset(%Stack %stack)
        %p_6_3755 = call ccc %Prompt @currentPrompt(%Stack %stack_479)
        %stackPointer_485 = call ccc %StackPointer @stackAllocate(%Stack %stack_479, i64 24)
        %returnAddress_pointer_486 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_485, i64 0, i32 1, i32 0
        %sharer_pointer_487 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_485, i64 0, i32 1, i32 1
        %eraser_pointer_488 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_485, i64 0, i32 1, i32 2
        store ptr @returnAddress_480, ptr %returnAddress_pointer_486, !noalias !2
        store ptr @sharer_108, ptr %sharer_pointer_487, !noalias !2
        store ptr @eraser_110, ptr %eraser_pointer_488, !noalias !2
        
        %closure_505 = call ccc %Object @newObject(ptr @eraser_128, i64 8)
        %environment_506 = call ccc %Environment @objectEnvironment(%Object %closure_505)
        %p_6_3755_pointer_508 = getelementptr <{%Prompt}>, %Environment %environment_506, i64 0, i32 0
        store %Prompt %p_6_3755, ptr %p_6_3755_pointer_508, !noalias !2
        %vtable_temporary_509 = insertvalue %Neg zeroinitializer, ptr @vtable_504, 0
        %Exception_7_3756 = insertvalue %Neg %vtable_temporary_509, %Object %closure_505, 1
        %stackPointer_519 = call ccc %StackPointer @stackAllocate(%Stack %stack_479, i64 24)
        %returnAddress_pointer_520 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_519, i64 0, i32 1, i32 0
        %sharer_pointer_521 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_519, i64 0, i32 1, i32 1
        %eraser_pointer_522 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_519, i64 0, i32 1, i32 2
        store ptr @returnAddress_510, ptr %returnAddress_pointer_520, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_521, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_522, !noalias !2
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %str_2061, i64 %index_2146, %Neg %Exception_7_3756, %Stack %stack_479)
        ret void
}



define tailcc void @returnAddress_523(%Pos %v_coe_3492_3588, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4964 = call ccc i64 @unboxInt_303(%Pos %v_coe_3492_3588)
        
        
        
        %stackPointer_525 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_526 = getelementptr %FrameHeader, %StackPointer %stackPointer_525, i64 0, i32 0
        %returnAddress_524 = load %ReturnAddress, ptr %returnAddress_pointer_526, !noalias !2
        musttail call tailcc void %returnAddress_524(i64 %pureApp_4964, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_532(%Pos %returned_4965, %Stack %stack) {
        
    entry:
        
        %stack_533 = call ccc %Stack @underflowStack(%Stack %stack)
        
        %stackPointer_535 = call ccc %StackPointer @stackDeallocate(%Stack %stack_533, i64 24)
        %returnAddress_pointer_536 = getelementptr %FrameHeader, %StackPointer %stackPointer_535, i64 0, i32 0
        %returnAddress_534 = load %ReturnAddress, ptr %returnAddress_pointer_536, !noalias !2
        musttail call tailcc void %returnAddress_534(%Pos %returned_4965, %Stack %stack_533)
        ret void
}


@utf8StringLiteral_4969.lit = private constant [34 x i8] c"\45\6d\70\74\79\20\73\74\72\69\6e\67\20\69\73\20\6e\6f\74\20\61\20\76\61\6c\69\64\20\6e\75\6d\62\65\72"


define tailcc void @Exception_9_3828_clause_541(%Object %closure, %Pos %exception_10_4966, %Pos %msg_11_4967, %Stack %stack) {
        
    entry:
        
        %environment_542 = call ccc %Environment @objectEnvironment(%Object %closure)
        %p_8_3827_pointer_543 = getelementptr <{%Prompt, %Neg}>, %Environment %environment_542, i64 0, i32 0
        %p_8_3827 = load %Prompt, ptr %p_8_3827_pointer_543, !noalias !2
        %Exception_2356_pointer_544 = getelementptr <{%Prompt, %Neg}>, %Environment %environment_542, i64 0, i32 1
        %Exception_2356 = load %Neg, ptr %Exception_2356_pointer_544, !noalias !2
        call ccc void @shareNegative(%Neg %Exception_2356)
        call ccc void @eraseObject(%Object %closure)
        call ccc void @erasePositive(%Pos %exception_10_4966)
        call ccc void @erasePositive(%Pos %msg_11_4967)
        
        %pair_545 = call ccc <{%Resumption, %Stack}> @shift(%Stack %stack, %Prompt %p_8_3827)
        %k_13_3832 = extractvalue <{%Resumption, %Stack}> %pair_545, 0
        %stack_546 = extractvalue <{%Resumption, %Stack}> %pair_545, 1
        call ccc void @eraseResumption(%Resumption %k_13_3832)
        
        %make_4968_temporary_547 = insertvalue %Pos zeroinitializer, i64 0, 0
        %make_4968 = insertvalue %Pos %make_4968_temporary_547, %Object null, 1
        
        
        
        %utf8StringLiteral_4969 = call ccc %Pos @c_bytearray_construct(i64 34, ptr @utf8StringLiteral_4969.lit)
        
        %vtable_548 = extractvalue %Neg %Exception_2356, 0
        %closure_549 = extractvalue %Neg %Exception_2356, 1
        %functionPointer_pointer_550 = getelementptr ptr, ptr %vtable_548, i64 0
        %functionPointer_551 = load ptr, ptr %functionPointer_pointer_550, !noalias !2
        musttail call tailcc void %functionPointer_551(%Object %closure_549, %Pos %make_4968, %Pos %utf8StringLiteral_4969, %Stack %stack_546)
        ret void
}


@vtable_552 = private constant [1 x ptr] [ptr @Exception_9_3828_clause_541]


define ccc void @eraser_557(%Environment %environment) {
        
    entry:
        
        %p_8_3827_555_pointer_558 = getelementptr <{%Prompt, %Neg}>, %Environment %environment, i64 0, i32 0
        %p_8_3827_555 = load %Prompt, ptr %p_8_3827_555_pointer_558, !noalias !2
        %Exception_2356_556_pointer_559 = getelementptr <{%Prompt, %Neg}>, %Environment %environment, i64 0, i32 1
        %Exception_2356_556 = load %Neg, ptr %Exception_2356_556_pointer_559, !noalias !2
        call ccc void @eraseNegative(%Neg %Exception_2356_556)
        ret void
}



define tailcc void @returnAddress_568(i64 %v_coe_3490_22_3849, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %pureApp_4972 = call ccc %Pos @boxInt_301(i64 %v_coe_3490_22_3849)
        
        
        
        %stackPointer_570 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_571 = getelementptr %FrameHeader, %StackPointer %stackPointer_570, i64 0, i32 0
        %returnAddress_569 = load %ReturnAddress, ptr %returnAddress_pointer_571, !noalias !2
        musttail call tailcc void %returnAddress_569(%Pos %pureApp_4972, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_580(i64 %v_r_2684_1_9_20_3847, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        
        %longLiteral_4976 = add i64 0, 0
        
        %pureApp_4975 = call ccc i64 @infixSub_105(i64 %longLiteral_4976, i64 %v_r_2684_1_9_20_3847)
        
        
        
        %stackPointer_582 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 24)
        %returnAddress_pointer_583 = getelementptr %FrameHeader, %StackPointer %stackPointer_582, i64 0, i32 0
        %returnAddress_581 = load %ReturnAddress, ptr %returnAddress_pointer_583, !noalias !2
        musttail call tailcc void %returnAddress_581(i64 %pureApp_4975, %Stack %stack)
        ret void
}



define tailcc void @returnAddress_563(i64 %v_r_2683_3_14_3837, %Stack %stack) {
        
    entry:
        
        call ccc void @assumeFrameHeaderWasPopped(%Stack %stack)
        %stackPointer_564 = call ccc %StackPointer @stackDeallocate(%Stack %stack, i64 40)
        %tmp_4932_pointer_565 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_564, i64 0, i32 0
        %tmp_4932 = load i64, ptr %tmp_4932_pointer_565, !noalias !2
        %str_2061_pointer_566 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_564, i64 0, i32 1
        %str_2061 = load %Pos, ptr %str_2061_pointer_566, !noalias !2
        %Exception_2356_pointer_567 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_564, i64 0, i32 2
        %Exception_2356 = load %Neg, ptr %Exception_2356_pointer_567, !noalias !2
        
        %intLiteral_4971 = add i64 45, 0
        
        %pureApp_4970 = call ccc %Pos @infixEq_78(i64 %v_r_2683_3_14_3837, i64 %intLiteral_4971)
        
        
        %stackPointer_572 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_573 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_572, i64 0, i32 1, i32 0
        %sharer_pointer_574 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_572, i64 0, i32 1, i32 1
        %eraser_pointer_575 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_572, i64 0, i32 1, i32 2
        store ptr @returnAddress_568, ptr %returnAddress_pointer_573, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_574, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_575, !noalias !2
        
        %tag_576 = extractvalue %Pos %pureApp_4970, 0
        %fields_577 = extractvalue %Pos %pureApp_4970, 1
        switch i64 %tag_576, label %label_578 [i64 0, label %label_579 i64 1, label %label_588]
    
    label_578:
        
        ret void
    
    label_579:
        
        %longLiteral_4973 = add i64 0, 0
        
        %longLiteral_4974 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_2148(i64 %longLiteral_4973, i64 %longLiteral_4974, i64 %tmp_4932, %Pos %str_2061, %Neg %Exception_2356, %Stack %stack)
        ret void
    
    label_588:
        %stackPointer_584 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_585 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_584, i64 0, i32 1, i32 0
        %sharer_pointer_586 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_584, i64 0, i32 1, i32 1
        %eraser_pointer_587 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_584, i64 0, i32 1, i32 2
        store ptr @returnAddress_580, ptr %returnAddress_pointer_585, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_586, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_587, !noalias !2
        
        %longLiteral_4977 = add i64 1, 0
        
        %longLiteral_4978 = add i64 0, 0
        
        
        
        
        musttail call tailcc void @go_2148(i64 %longLiteral_4977, i64 %longLiteral_4978, i64 %tmp_4932, %Pos %str_2061, %Neg %Exception_2356, %Stack %stack)
        ret void
}



define ccc void @sharer_592(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_593 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer, i64 -1
        %tmp_4932_589_pointer_594 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_593, i64 0, i32 0
        %tmp_4932_589 = load i64, ptr %tmp_4932_589_pointer_594, !noalias !2
        %str_2061_590_pointer_595 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_593, i64 0, i32 1
        %str_2061_590 = load %Pos, ptr %str_2061_590_pointer_595, !noalias !2
        %Exception_2356_591_pointer_596 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_593, i64 0, i32 2
        %Exception_2356_591 = load %Neg, ptr %Exception_2356_591_pointer_596, !noalias !2
        call ccc void @sharePositive(%Pos %str_2061_590)
        call ccc void @shareNegative(%Neg %Exception_2356_591)
        call ccc void @shareFrames(%StackPointer %stackPointer_593)
        ret void
}



define ccc void @eraser_600(%StackPointer %stackPointer) {
        
    entry:
        
        %stackPointer_601 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer, i64 -1
        %tmp_4932_597_pointer_602 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_601, i64 0, i32 0
        %tmp_4932_597 = load i64, ptr %tmp_4932_597_pointer_602, !noalias !2
        %str_2061_598_pointer_603 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_601, i64 0, i32 1
        %str_2061_598 = load %Pos, ptr %str_2061_598_pointer_603, !noalias !2
        %Exception_2356_599_pointer_604 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_601, i64 0, i32 2
        %Exception_2356_599 = load %Neg, ptr %Exception_2356_599_pointer_604, !noalias !2
        call ccc void @erasePositive(%Pos %str_2061_598)
        call ccc void @eraseNegative(%Neg %Exception_2356_599)
        call ccc void @eraseFrames(%StackPointer %stackPointer_601)
        ret void
}



define tailcc void @toInt_2062(%Pos %str_2061, %Neg %Exception_2356, %Stack %stack) {
        
    entry:
        
        
        %intLiteral_4937 = add i64 48, 0
        
        %pureApp_4936 = call ccc i64 @toInt_2085(i64 %intLiteral_4937)
        
        
        %stackPointer_527 = call ccc %StackPointer @stackAllocate(%Stack %stack, i64 24)
        %returnAddress_pointer_528 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 0
        %sharer_pointer_529 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 1
        %eraser_pointer_530 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_527, i64 0, i32 1, i32 2
        store ptr @returnAddress_523, ptr %returnAddress_pointer_528, !noalias !2
        store ptr @sharer_9, ptr %sharer_pointer_529, !noalias !2
        store ptr @eraser_11, ptr %eraser_pointer_530, !noalias !2
        
        %stack_531 = call ccc %Stack @reset(%Stack %stack)
        %p_8_3827 = call ccc %Prompt @currentPrompt(%Stack %stack_531)
        %stackPointer_537 = call ccc %StackPointer @stackAllocate(%Stack %stack_531, i64 24)
        %returnAddress_pointer_538 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_537, i64 0, i32 1, i32 0
        %sharer_pointer_539 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_537, i64 0, i32 1, i32 1
        %eraser_pointer_540 = getelementptr <{<{}>, %FrameHeader}>, %StackPointer %stackPointer_537, i64 0, i32 1, i32 2
        store ptr @returnAddress_532, ptr %returnAddress_pointer_538, !noalias !2
        store ptr @sharer_108, ptr %sharer_pointer_539, !noalias !2
        store ptr @eraser_110, ptr %eraser_pointer_540, !noalias !2
        
        %closure_553 = call ccc %Object @newObject(ptr @eraser_557, i64 24)
        %environment_554 = call ccc %Environment @objectEnvironment(%Object %closure_553)
        call ccc void @shareNegative(%Neg %Exception_2356)
        %p_8_3827_pointer_560 = getelementptr <{%Prompt, %Neg}>, %Environment %environment_554, i64 0, i32 0
        store %Prompt %p_8_3827, ptr %p_8_3827_pointer_560, !noalias !2
        %Exception_2356_pointer_561 = getelementptr <{%Prompt, %Neg}>, %Environment %environment_554, i64 0, i32 1
        store %Neg %Exception_2356, ptr %Exception_2356_pointer_561, !noalias !2
        %vtable_temporary_562 = insertvalue %Neg zeroinitializer, ptr @vtable_552, 0
        %Exception_9_3828 = insertvalue %Neg %vtable_temporary_562, %Object %closure_553, 1
        call ccc void @sharePositive(%Pos %str_2061)
        %stackPointer_605 = call ccc %StackPointer @stackAllocate(%Stack %stack_531, i64 64)
        %tmp_4932_pointer_606 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_605, i64 0, i32 0
        store i64 %pureApp_4936, ptr %tmp_4932_pointer_606, !noalias !2
        %str_2061_pointer_607 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_605, i64 0, i32 1
        store %Pos %str_2061, ptr %str_2061_pointer_607, !noalias !2
        %Exception_2356_pointer_608 = getelementptr <{i64, %Pos, %Neg}>, %StackPointer %stackPointer_605, i64 0, i32 2
        store %Neg %Exception_2356, ptr %Exception_2356_pointer_608, !noalias !2
        %returnAddress_pointer_609 = getelementptr <{<{i64, %Pos, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 0
        %sharer_pointer_610 = getelementptr <{<{i64, %Pos, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 1
        %eraser_pointer_611 = getelementptr <{<{i64, %Pos, %Neg}>, %FrameHeader}>, %StackPointer %stackPointer_605, i64 0, i32 1, i32 2
        store ptr @returnAddress_563, ptr %returnAddress_pointer_609, !noalias !2
        store ptr @sharer_592, ptr %sharer_pointer_610, !noalias !2
        store ptr @eraser_600, ptr %eraser_pointer_611, !noalias !2
        
        %longLiteral_4979 = add i64 0, 0
        
        
        
        
        
        musttail call tailcc void @charAt_2108(%Pos %str_2061, i64 %longLiteral_4979, %Neg %Exception_9_3828, %Stack %stack_531)
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
