; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:triples_49a3ada4-86b2-4943-aefa-8c4899b18852/main.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:triples_49a3ada4-86b2-4943-aefa-8c4899b18852/main.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }

@vtable_547 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4380_clause_532]
@vtable_578 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4336_clause_570]
@utf8StringLiteral_4974.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_4857.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_4859.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_4862.lit = private constant [1 x i8] c"'"

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #0

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) #1

; Function Attrs: mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite)
declare noalias noundef ptr @realloc(ptr allocptr nocapture, i64 noundef) local_unnamed_addr #2

declare void @memcpy(ptr, ptr, i64) local_unnamed_addr

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @box(%Neg %input) local_unnamed_addr #5 {
  %vtable = extractvalue %Neg %input, 0
  %heap_obj = extractvalue %Neg %input, 1
  %vtable_as_int = ptrtoint ptr %vtable to i64
  %pos_result = insertvalue %Pos undef, i64 %vtable_as_int, 0
  %pos_result_with_heap = insertvalue %Pos %pos_result, ptr %heap_obj, 1
  ret %Pos %pos_result_with_heap
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Neg @unbox(%Pos %input) local_unnamed_addr #5 {
  %tag = extractvalue %Pos %input, 0
  %heap_obj = extractvalue %Pos %input, 1
  %vtable = inttoptr i64 %tag to ptr
  %neg_result = insertvalue %Neg undef, ptr %vtable, 0
  %neg_result_with_heap = insertvalue %Neg %neg_result, ptr %heap_obj, 1
  ret %Neg %neg_result_with_heap
}

; Function Attrs: alwaysinline mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none)
define void @sharePositive(%Pos %val) local_unnamed_addr #6 {
  %object = extractvalue %Pos %val, 1
  %isNull.i = icmp eq ptr %object, null
  br i1 %isNull.i, label %shareObject.exit, label %next.i

next.i:                                           ; preds = %0
  %referenceCount.i = load i64, ptr %object, align 4
  %referenceCount.1.i = add i64 %referenceCount.i, 1
  store i64 %referenceCount.1.i, ptr %object, align 4
  br label %shareObject.exit

shareObject.exit:                                 ; preds = %0, %next.i
  ret void
}

; Function Attrs: alwaysinline mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none)
define void @shareNegative(%Neg %val) local_unnamed_addr #6 {
  %object = extractvalue %Neg %val, 1
  %isNull.i = icmp eq ptr %object, null
  br i1 %isNull.i, label %shareObject.exit, label %next.i

next.i:                                           ; preds = %0
  %referenceCount.i = load i64, ptr %object, align 4
  %referenceCount.1.i = add i64 %referenceCount.i, 1
  store i64 %referenceCount.1.i, ptr %object, align 4
  br label %shareObject.exit

shareObject.exit:                                 ; preds = %0, %next.i
  ret void
}

; Function Attrs: alwaysinline
define void @erasePositive(%Pos %val) local_unnamed_addr #7 {
  %object = extractvalue %Pos %val, 1
  %isNull.i = icmp eq ptr %object, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %0
  %referenceCount.i = load i64, ptr %object, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %object, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %object, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %object, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %object)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %0, %decr.i, %free.i
  ret void
}

; Function Attrs: alwaysinline
define void @eraseNegative(%Neg %val) local_unnamed_addr #7 {
  %object = extractvalue %Neg %val, 1
  %isNull.i = icmp eq ptr %object, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %0
  %referenceCount.i = load i64, ptr %object, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %object, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %object, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %object, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %object)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %0, %decr.i, %free.i
  ret void
}

define private fastcc ptr @resume(ptr %resumption, ptr %oldStack) unnamed_addr {
  %referenceCount.i = load i64, ptr %resumption, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %.uniqueStack.exit_crit_edge, label %copy.i

.uniqueStack.exit_crit_edge:                      ; preds = %0
  %rest_pointer.phi.trans.insert = getelementptr i8, ptr %resumption, i64 40
  %start.pre = load ptr, ptr %rest_pointer.phi.trans.insert, align 8
  br label %uniqueStack.exit

copy.i:                                           ; preds = %0
  %newOldReferenceCount.i = add i64 %referenceCount.i, -1
  store i64 %newOldReferenceCount.i, ptr %resumption, align 4
  %stack_pointer.i = getelementptr i8, ptr %resumption, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  %newHead.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  br label %loop.i

loop.i:                                           ; preds = %next.i, %copy.i
  %old.i = phi ptr [ %stack.i, %copy.i ], [ %rest.i, %next.i ]
  %newStack.i = phi ptr [ %newHead.i, %copy.i ], [ %nextNew.i, %next.i ]
  %stackMemory.i = getelementptr i8, ptr %old.i, i64 8
  %stackPrompt.i = getelementptr i8, ptr %old.i, i64 32
  %stackRest.i = getelementptr i8, ptr %old.i, i64 40
  %memory.unpack.i = load ptr, ptr %stackMemory.i, align 8
  %memory.elt1.i = getelementptr i8, ptr %old.i, i64 16
  %memory.unpack2.i = load ptr, ptr %memory.elt1.i, align 8
  %memory.elt3.i = getelementptr i8, ptr %old.i, i64 24
  %memory.unpack4.i = load ptr, ptr %memory.elt3.i, align 8
  %prompt.i = load ptr, ptr %stackPrompt.i, align 8
  %rest.i = load ptr, ptr %stackRest.i, align 8
  %newStackMemory.i = getelementptr i8, ptr %newStack.i, i64 8
  %newStackPrompt.i = getelementptr i8, ptr %newStack.i, i64 32
  %newStackRest.i = getelementptr i8, ptr %newStack.i, i64 40
  %intStackPointer.i.i = ptrtoint ptr %memory.unpack.i to i64
  %intBase.i.i = ptrtoint ptr %memory.unpack2.i to i64
  %intLimit.i.i = ptrtoint ptr %memory.unpack4.i to i64
  %used.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %size.i.i = sub i64 %intLimit.i.i, %intBase.i.i
  %newBase.i.i = tail call ptr @malloc(i64 %size.i.i)
  %intNewBase.i.i = ptrtoint ptr %newBase.i.i to i64
  %intNewStackPointer.i.i = add i64 %used.i.i, %intNewBase.i.i
  %intNewLimit.i.i = add i64 %size.i.i, %intNewBase.i.i
  %newStackPointer.i.i = inttoptr i64 %intNewStackPointer.i.i to ptr
  %newLimit.i.i = inttoptr i64 %intNewLimit.i.i to ptr
  tail call void @memcpy(ptr %newBase.i.i, ptr %memory.unpack2.i, i64 %used.i.i)
  %newStackPointer.i = getelementptr i8, ptr %newStackPointer.i.i, i64 -24
  %stackSharer.i = getelementptr i8, ptr %newStackPointer.i.i, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, 1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  store i64 0, ptr %newStack.i, align 4
  store ptr %newStackPointer.i.i, ptr %newStackMemory.i, align 8
  %newStackMemory.repack6.i = getelementptr i8, ptr %newStack.i, i64 16
  store ptr %newBase.i.i, ptr %newStackMemory.repack6.i, align 8
  %newStackMemory.repack8.i = getelementptr i8, ptr %newStack.i, i64 24
  store ptr %newLimit.i.i, ptr %newStackMemory.repack8.i, align 8
  store ptr %prompt.i, ptr %newStackPrompt.i, align 8
  %isEnd.i = icmp eq ptr %old.i, %resumption
  br i1 %isEnd.i, label %stop.i, label %next.i

next.i:                                           ; preds = %loop.i
  %nextNew.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  store ptr %nextNew.i, ptr %newStackRest.i, align 8
  br label %loop.i

stop.i:                                           ; preds = %loop.i
  store ptr %newHead.i, ptr %newStackRest.i, align 8
  br label %uniqueStack.exit

uniqueStack.exit:                                 ; preds = %.uniqueStack.exit_crit_edge, %stop.i
  %start = phi ptr [ %newHead.i, %stop.i ], [ %start.pre, %.uniqueStack.exit_crit_edge ]
  %common.ret.op.i = phi ptr [ %newStack.i, %stop.i ], [ %resumption, %.uniqueStack.exit_crit_edge ]
  %prompt_pointer1.i = getelementptr i8, ptr %start, i64 32
  %prompt2.i = load ptr, ptr %prompt_pointer1.i, align 8
  %stack_pointer3.i = getelementptr i8, ptr %prompt2.i, i64 8
  %promptStack4.i = load ptr, ptr %stack_pointer3.i, align 8
  %isThis5.i = icmp eq ptr %promptStack4.i, %start
  br i1 %isThis5.i, label %updatePrompts.exit, label %continue.i

continue.i:                                       ; preds = %uniqueStack.exit, %update.i
  %promptStack8.i = phi ptr [ %promptStack.i, %update.i ], [ %promptStack4.i, %uniqueStack.exit ]
  %stack_pointer7.i = phi ptr [ %stack_pointer.i3, %update.i ], [ %stack_pointer3.i, %uniqueStack.exit ]
  %stack.tr6.i = phi ptr [ %next.i1, %update.i ], [ %start, %uniqueStack.exit ]
  %isOccupied.not.i = icmp eq ptr %promptStack8.i, null
  br i1 %isOccupied.not.i, label %update.i, label %tailrecurse.i.i

tailrecurse.i.i:                                  ; preds = %continue.i, %tailrecurse.i.i
  %stack.tr.i.i = phi ptr [ %next.i.i, %tailrecurse.i.i ], [ %promptStack8.i, %continue.i ]
  %prompt_pointer.i.i = getelementptr i8, ptr %stack.tr.i.i, i64 32
  %next_pointer.i.i = getelementptr i8, ptr %stack.tr.i.i, i64 40
  %prompt.i.i = load ptr, ptr %prompt_pointer.i.i, align 8
  %stack_pointer.i.i = getelementptr i8, ptr %prompt.i.i, i64 8
  store ptr null, ptr %stack_pointer.i.i, align 8
  %next.i.i = load ptr, ptr %next_pointer.i.i, align 8
  %isEnd.i.i = icmp eq ptr %next.i.i, %promptStack8.i
  br i1 %isEnd.i.i, label %update.i, label %tailrecurse.i.i

update.i:                                         ; preds = %tailrecurse.i.i, %continue.i
  store ptr %stack.tr6.i, ptr %stack_pointer7.i, align 8
  %next_pointer.i = getelementptr i8, ptr %stack.tr6.i, i64 40
  %next.i1 = load ptr, ptr %next_pointer.i, align 8
  %prompt_pointer.i = getelementptr i8, ptr %next.i1, i64 32
  %prompt.i2 = load ptr, ptr %prompt_pointer.i, align 8
  %stack_pointer.i3 = getelementptr i8, ptr %prompt.i2, i64 8
  %promptStack.i = load ptr, ptr %stack_pointer.i3, align 8
  %isThis.i = icmp eq ptr %promptStack.i, %next.i1
  br i1 %isThis.i, label %updatePrompts.exit, label %continue.i

updatePrompts.exit:                               ; preds = %update.i, %uniqueStack.exit
  %rest_pointer = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %oldStack, ptr %rest_pointer, align 8
  ret ptr %start
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none)
define private { ptr, ptr } @shift(ptr %stack, ptr nocapture readonly %prompt) unnamed_addr #8 {
  %resumpion_pointer = getelementptr i8, ptr %prompt, i64 8
  %resumption = load ptr, ptr %resumpion_pointer, align 8
  %next_pointer = getelementptr i8, ptr %resumption, i64 40
  %next = load ptr, ptr %next_pointer, align 8
  store ptr %stack, ptr %next_pointer, align 8
  %result.0 = insertvalue { ptr, ptr } undef, ptr %resumption, 0
  %result = insertvalue { ptr, ptr } %result.0, ptr %next, 1
  ret { ptr, ptr } %result
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define private void @nop(ptr nocapture readnone %stack) #5 {
  ret void
}

; Function Attrs: alwaysinline mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define void @shareResumption(ptr nocapture %resumption) local_unnamed_addr #9 {
  %referenceCount = load i64, ptr %resumption, align 4
  %referenceCount.1 = add i64 %referenceCount, 1
  store i64 %referenceCount.1, ptr %resumption, align 4
  ret void
}

; Function Attrs: alwaysinline
define void @eraseResumption(ptr nocapture %resumption) local_unnamed_addr #7 {
  %referenceCount = load i64, ptr %resumption, align 4
  %cond = icmp eq i64 %referenceCount, 0
  br i1 %cond, label %free, label %decr

common.ret:                                       ; preds = %erasePrompt.exit.i, %decr
  ret void

decr:                                             ; preds = %0
  %referenceCount.1 = add i64 %referenceCount, -1
  store i64 %referenceCount.1, ptr %resumption, align 4
  br label %common.ret

free:                                             ; preds = %0
  %stack_pointer = getelementptr i8, ptr %resumption, i64 40
  %stack = load ptr, ptr %stack_pointer, align 8
  store ptr null, ptr %stack_pointer, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free
  %stack.tr.i = phi ptr [ %stack, %free ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i

free.i:                                           ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %common.ret, label %tailrecurse.i
}

; Function Attrs: alwaysinline
define void @eraseStack(ptr %stack) local_unnamed_addr #7 {
  br label %tailrecurse

tailrecurse:                                      ; preds = %erasePrompt.exit, %0
  %stack.tr = phi ptr [ %stack, %0 ], [ %rest, %erasePrompt.exit ]
  %stackPointer_pointer = getelementptr i8, ptr %stack.tr, i64 8
  %prompt_pointer = getelementptr i8, ptr %stack.tr, i64 32
  %rest_pointer = getelementptr i8, ptr %stack.tr, i64 40
  %stackPointer = load ptr, ptr %stackPointer_pointer, align 8
  %prompt = load ptr, ptr %prompt_pointer, align 8
  %rest = load ptr, ptr %rest_pointer, align 8
  %promptStack_pointer = getelementptr i8, ptr %prompt, i64 8
  %promptStack = load ptr, ptr %promptStack_pointer, align 8
  %isThisStack = icmp eq ptr %promptStack, %stack.tr
  br i1 %isThisStack, label %clearPrompt, label %free

clearPrompt:                                      ; preds = %tailrecurse
  store ptr null, ptr %promptStack_pointer, align 8
  br label %free

free:                                             ; preds = %clearPrompt, %tailrecurse
  tail call void @free(ptr nonnull %stack.tr)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  %referenceCount.i = load i64, ptr %prompt, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decrement.i

decrement.i:                                      ; preds = %free
  %newReferenceCount.i = add i64 %referenceCount.i, -1
  store i64 %newReferenceCount.i, ptr %prompt, align 4
  br label %erasePrompt.exit

free.i:                                           ; preds = %free
  tail call void @free(ptr nonnull %prompt)
  br label %erasePrompt.exit

erasePrompt.exit:                                 ; preds = %decrement.i, %free.i
  %isNull = icmp eq ptr %rest, null
  br i1 %isNull, label %common.ret, label %tailrecurse

common.ret:                                       ; preds = %erasePrompt.exit
  ret void
}

define private tailcc void @topLevel(%Pos %val, ptr nocapture %stack) {
  %stackMemory.i = getelementptr i8, ptr %stack, i64 8
  %stackPrompt.i = getelementptr i8, ptr %stack, i64 32
  %stackRest.i = getelementptr i8, ptr %stack, i64 40
  %memory.unpack.i = load ptr, ptr %stackMemory.i, align 8
  %prompt.i = load ptr, ptr %stackPrompt.i, align 8
  %rest.i = load ptr, ptr %stackRest.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  store ptr null, ptr %promptStack_pointer.i, align 8
  tail call void @free(ptr %memory.unpack.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %0
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %underflowStack.exit

free.i.i:                                         ; preds = %0
  tail call void @free(ptr nonnull %prompt.i)
  br label %underflowStack.exit

underflowStack.exit:                              ; preds = %decrement.i.i, %free.i.i
  tail call void @free(ptr nonnull %stack)
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %underflowStack.exit
  %stack.tr.i = phi ptr [ %rest.i, %underflowStack.exit ], [ %rest.i2, %erasePrompt.exit.i ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %prompt.i1 = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i2 = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i3 = getelementptr i8, ptr %prompt.i1, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i3, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i3, align 8
  br label %free.i

free.i:                                           ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i4 = load i64, ptr %prompt.i1, align 4
  %cond.i.i5 = icmp eq i64 %referenceCount.i.i4, 0
  br i1 %cond.i.i5, label %free.i.i8, label %decrement.i.i6

decrement.i.i6:                                   ; preds = %free.i
  %newReferenceCount.i.i7 = add i64 %referenceCount.i.i4, -1
  store i64 %newReferenceCount.i.i7, ptr %prompt.i1, align 4
  br label %erasePrompt.exit.i

free.i.i8:                                        ; preds = %free.i
  tail call void @free(ptr nonnull %prompt.i1)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i8, %decrement.i.i6
  %isNull.i = icmp eq ptr %rest.i2, null
  br i1 %isNull.i, label %eraseStack.exit, label %tailrecurse.i

eraseStack.exit:                                  ; preds = %erasePrompt.exit.i
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define private void @topLevelSharer(ptr nocapture readnone %environment) #5 {
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define private void @topLevelEraser(ptr nocapture readnone %environment) #5 {
  ret void
}

define void @resume_Int(ptr %stack, i64 %argument) local_unnamed_addr {
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress = load ptr, ptr %newStackPointer.i, align 8
  tail call tailcc void %returnAddress(i64 %argument, ptr %stack)
  ret void
}

define void @resume_Pos(ptr %stack, %Pos %argument) local_unnamed_addr {
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress = load ptr, ptr %newStackPointer.i, align 8
  tail call tailcc void %returnAddress(%Pos %argument, ptr %stack)
  ret void
}

define void @run(%Neg %f) local_unnamed_addr {
  %calloc.i.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 64
  store i64 0, ptr %stack.i.i, align 8
  %stack.repack1.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 8
  %stack.repack1.repack7.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 16
  store ptr %stackPointer.i.i.i, ptr %stack.repack1.repack7.i.i, align 8
  %stack.repack1.repack9.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 24
  store ptr %limit.i.i.i, ptr %stack.repack1.repack9.i.i, align 8
  %stack.repack3.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 32
  store ptr %calloc.i.i.i, ptr %stack.repack3.i.i, align 8
  %stack.repack5.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 40
  store ptr null, ptr %stack.repack5.i.i, align 8
  %stack_pointer.i.i = getelementptr i8, ptr %calloc.i.i.i, i64 8
  store ptr %stack.i.i, ptr %stack_pointer.i.i, align 8
  %sharerPointer.0.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 8
  %eraserPointer.0.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 16
  store ptr @nop, ptr %stackPointer.i.i.i, align 8
  store ptr @nop, ptr %sharerPointer.0.i, align 8
  store ptr @free, ptr %eraserPointer.0.i, align 8
  %globalsStackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 24
  store ptr %globalsStackPointer_2.i, ptr %stack.repack1.i.i, align 8
  %calloc.i.i1.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i2.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i3.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i4.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 64
  store i64 0, ptr %stack.i2.i, align 8
  %stack.repack1.i5.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 8
  %stack.repack1.repack7.i6.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 16
  store ptr %stackPointer.i.i3.i, ptr %stack.repack1.repack7.i6.i, align 8
  %stack.repack1.repack9.i7.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 24
  store ptr %limit.i.i4.i, ptr %stack.repack1.repack9.i7.i, align 8
  %stack.repack3.i8.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 32
  store ptr %calloc.i.i1.i, ptr %stack.repack3.i8.i, align 8
  %stack.repack5.i9.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 40
  store ptr %stack.i.i, ptr %stack.repack5.i9.i, align 8
  %stack_pointer.i10.i = getelementptr i8, ptr %calloc.i.i1.i, i64 8
  store ptr %stack.i2.i, ptr %stack_pointer.i10.i, align 8
  %sharerPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 8
  %eraserPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 16
  store ptr @topLevel, ptr %stackPointer.i.i3.i, align 8
  store ptr @topLevelSharer, ptr %sharerPointer.i, align 8
  store ptr @topLevelEraser, ptr %eraserPointer.i, align 8
  %stackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 24
  store ptr %stackPointer_2.i, ptr %stack.repack1.i5.i, align 8
  %arrayPointer = extractvalue %Neg %f, 0
  %object = extractvalue %Neg %f, 1
  %functionPointer = load ptr, ptr %arrayPointer, align 8
  %1 = tail call tailcc %Pos %functionPointer(ptr %object, ptr nonnull %stack.i2.i)
  ret void
}

define void @run_Int(%Neg %f, i64 %argument) local_unnamed_addr {
  %calloc.i.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 64
  store i64 0, ptr %stack.i.i, align 8
  %stack.repack1.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 8
  %stack.repack1.repack7.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 16
  store ptr %stackPointer.i.i.i, ptr %stack.repack1.repack7.i.i, align 8
  %stack.repack1.repack9.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 24
  store ptr %limit.i.i.i, ptr %stack.repack1.repack9.i.i, align 8
  %stack.repack3.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 32
  store ptr %calloc.i.i.i, ptr %stack.repack3.i.i, align 8
  %stack.repack5.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 40
  store ptr null, ptr %stack.repack5.i.i, align 8
  %stack_pointer.i.i = getelementptr i8, ptr %calloc.i.i.i, i64 8
  store ptr %stack.i.i, ptr %stack_pointer.i.i, align 8
  %sharerPointer.0.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 8
  %eraserPointer.0.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 16
  store ptr @nop, ptr %stackPointer.i.i.i, align 8
  store ptr @nop, ptr %sharerPointer.0.i, align 8
  store ptr @free, ptr %eraserPointer.0.i, align 8
  %globalsStackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 24
  store ptr %globalsStackPointer_2.i, ptr %stack.repack1.i.i, align 8
  %calloc.i.i1.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i2.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i3.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i4.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 64
  store i64 0, ptr %stack.i2.i, align 8
  %stack.repack1.i5.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 8
  %stack.repack1.repack7.i6.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 16
  store ptr %stackPointer.i.i3.i, ptr %stack.repack1.repack7.i6.i, align 8
  %stack.repack1.repack9.i7.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 24
  store ptr %limit.i.i4.i, ptr %stack.repack1.repack9.i7.i, align 8
  %stack.repack3.i8.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 32
  store ptr %calloc.i.i1.i, ptr %stack.repack3.i8.i, align 8
  %stack.repack5.i9.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 40
  store ptr %stack.i.i, ptr %stack.repack5.i9.i, align 8
  %stack_pointer.i10.i = getelementptr i8, ptr %calloc.i.i1.i, i64 8
  store ptr %stack.i2.i, ptr %stack_pointer.i10.i, align 8
  %sharerPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 8
  %eraserPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 16
  store ptr @topLevel, ptr %stackPointer.i.i3.i, align 8
  store ptr @topLevelSharer, ptr %sharerPointer.i, align 8
  store ptr @topLevelEraser, ptr %eraserPointer.i, align 8
  %stackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 24
  store ptr %stackPointer_2.i, ptr %stack.repack1.i5.i, align 8
  %arrayPointer = extractvalue %Neg %f, 0
  %object = extractvalue %Neg %f, 1
  %functionPointer = load ptr, ptr %arrayPointer, align 8
  %1 = tail call tailcc %Pos %functionPointer(ptr %object, i64 0, i64 %argument, ptr nonnull %stack.i2.i)
  ret void
}

define void @run_Pos(%Neg %f, %Pos %argument) local_unnamed_addr {
  %calloc.i.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 64
  store i64 0, ptr %stack.i.i, align 8
  %stack.repack1.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 8
  %stack.repack1.repack7.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 16
  store ptr %stackPointer.i.i.i, ptr %stack.repack1.repack7.i.i, align 8
  %stack.repack1.repack9.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 24
  store ptr %limit.i.i.i, ptr %stack.repack1.repack9.i.i, align 8
  %stack.repack3.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 32
  store ptr %calloc.i.i.i, ptr %stack.repack3.i.i, align 8
  %stack.repack5.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 40
  store ptr null, ptr %stack.repack5.i.i, align 8
  %stack_pointer.i.i = getelementptr i8, ptr %calloc.i.i.i, i64 8
  store ptr %stack.i.i, ptr %stack_pointer.i.i, align 8
  %sharerPointer.0.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 8
  %eraserPointer.0.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 16
  store ptr @nop, ptr %stackPointer.i.i.i, align 8
  store ptr @nop, ptr %sharerPointer.0.i, align 8
  store ptr @free, ptr %eraserPointer.0.i, align 8
  %globalsStackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 24
  store ptr %globalsStackPointer_2.i, ptr %stack.repack1.i.i, align 8
  %calloc.i.i1.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i2.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i3.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i4.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 64
  store i64 0, ptr %stack.i2.i, align 8
  %stack.repack1.i5.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 8
  %stack.repack1.repack7.i6.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 16
  store ptr %stackPointer.i.i3.i, ptr %stack.repack1.repack7.i6.i, align 8
  %stack.repack1.repack9.i7.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 24
  store ptr %limit.i.i4.i, ptr %stack.repack1.repack9.i7.i, align 8
  %stack.repack3.i8.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 32
  store ptr %calloc.i.i1.i, ptr %stack.repack3.i8.i, align 8
  %stack.repack5.i9.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 40
  store ptr %stack.i.i, ptr %stack.repack5.i9.i, align 8
  %stack_pointer.i10.i = getelementptr i8, ptr %calloc.i.i1.i, i64 8
  store ptr %stack.i2.i, ptr %stack_pointer.i10.i, align 8
  %sharerPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 8
  %eraserPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 16
  store ptr @topLevel, ptr %stackPointer.i.i3.i, align 8
  store ptr @topLevelSharer, ptr %sharerPointer.i, align 8
  store ptr @topLevelEraser, ptr %eraserPointer.i, align 8
  %stackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 24
  store ptr %stackPointer_2.i, ptr %stack.repack1.i5.i, align 8
  %arrayPointer = extractvalue %Neg %f, 0
  %object = extractvalue %Neg %f, 1
  %functionPointer = load ptr, ptr %arrayPointer, align 8
  %1 = tail call tailcc %Pos %functionPointer(ptr %object, i64 0, %Pos %argument, ptr nonnull %stack.i2.i)
  ret void
}

declare i64 @c_get_argc() local_unnamed_addr

declare %Pos @c_get_arg(i64) local_unnamed_addr

declare void @c_io_println_String(%Pos) local_unnamed_addr

declare i64 @c_bytearray_size(%Pos) local_unnamed_addr

declare %Pos @c_bytearray_construct(i64, ptr) local_unnamed_addr

declare %Pos @c_bytearray_show_Int(i64) local_unnamed_addr

declare %Pos @c_bytearray_concatenate(%Pos, %Pos) local_unnamed_addr

declare i64 @c_bytearray_character_at(%Pos, i64) local_unnamed_addr

define %Pos @println_1(%Pos %value_2) local_unnamed_addr {
  tail call void @c_io_println_String(%Pos %value_2)
  ret %Pos zeroinitializer
}

define %Pos @show_14(i64 %value_13) local_unnamed_addr {
  %z = tail call %Pos @c_bytearray_show_Int(i64 %value_13)
  ret %Pos %z
}

define %Pos @infixConcat_35(%Pos %s1_33, %Pos %s2_34) local_unnamed_addr {
  %spz = tail call %Pos @c_bytearray_concatenate(%Pos %s1_33, %Pos %s2_34)
  ret %Pos %spz
}

define i64 @length_37(%Pos %str_36) local_unnamed_addr {
  %x = tail call i64 @c_bytearray_size(%Pos %str_36)
  ret i64 %x
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @infixEq_72(i64 %x_70, i64 %y_71) local_unnamed_addr #5 {
  %z = icmp eq i64 %x_70, %y_71
  %fat_z = zext i1 %z to i64
  %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
  ret %Pos %adt_boolean
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @infixEq_78(i64 %x_76, i64 %y_77) local_unnamed_addr #5 {
  %z = icmp eq i64 %x_76, %y_77
  %fat_z = zext i1 %z to i64
  %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
  ret %Pos %adt_boolean
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @infixAdd_96(i64 %x_94, i64 %y_95) local_unnamed_addr #5 {
  %z = add i64 %y_95, %x_94
  ret i64 %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @infixMul_99(i64 %x_97, i64 %y_98) local_unnamed_addr #5 {
  %z = mul i64 %y_98, %x_97
  ret i64 %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @infixSub_105(i64 %x_103, i64 %y_104) local_unnamed_addr #5 {
  %z = sub i64 %x_103, %y_104
  ret i64 %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @mod_108(i64 %x_106, i64 %y_107) local_unnamed_addr #5 {
  %z = srem i64 %x_106, %y_107
  ret i64 %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @infixLt_178(i64 %x_176, i64 %y_177) local_unnamed_addr #5 {
  %z = icmp slt i64 %x_176, %y_177
  %fat_z = zext i1 %z to i64
  %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
  ret %Pos %adt_boolean
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @infixGte_187(i64 %x_185, i64 %y_186) local_unnamed_addr #5 {
  %z = icmp sge i64 %x_185, %y_186
  %fat_z = zext i1 %z to i64
  %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
  ret %Pos %adt_boolean
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @boxInt_301(i64 %n_300) local_unnamed_addr #5 {
  %boxed1 = insertvalue %Pos zeroinitializer, i64 %n_300, 0
  %boxed2 = insertvalue %Pos %boxed1, ptr null, 1
  ret %Pos %boxed2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @unboxInt_303(%Pos %b_302) local_unnamed_addr #5 {
  %unboxed = extractvalue %Pos %b_302, 0
  ret i64 %unboxed
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @boxChar_311(i64 %c_310) local_unnamed_addr #5 {
  %boxed1 = insertvalue %Pos zeroinitializer, i64 %c_310, 0
  %boxed2 = insertvalue %Pos %boxed1, ptr null, 1
  ret %Pos %boxed2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @unboxChar_313(%Pos %b_312) local_unnamed_addr #5 {
  %unboxed = extractvalue %Pos %b_312, 0
  ret i64 %unboxed
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @toInt_2085(i64 returned %ch_2084) local_unnamed_addr #5 {
  ret i64 %ch_2084
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @infixLte_2093(i64 %x_2091, i64 %y_2092) local_unnamed_addr #5 {
  %z = icmp sle i64 %x_2091, %y_2092
  %fat_z = zext i1 %z to i64
  %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
  ret %Pos %adt_boolean
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define %Pos @infixGte_2099(i64 %x_2097, i64 %y_2098) local_unnamed_addr #5 {
  %z = icmp sge i64 %x_2097, %y_2098
  %fat_z = zext i1 %z to i64
  %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
  ret %Pos %adt_boolean
}

define i64 @unsafeCharAt_2111(%Pos %str_2109, i64 %n_2110) local_unnamed_addr {
  %x = tail call i64 @c_bytearray_character_at(%Pos %str_2109, i64 %n_2110)
  ret i64 %x
}

define i64 @argCount_2383() local_unnamed_addr {
  %c = tail call i64 @c_get_argc()
  ret i64 %c
}

define %Pos @argument_2385(i64 %i_2384) local_unnamed_addr {
  %s = tail call %Pos @c_get_arg(i64 %i_2384)
  ret %Pos %s
}

define tailcc void @returnAddress_2(i64 %r_2464, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2464)
  tail call void @c_io_println_String(%Pos %z.i)
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_3 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_3(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_6(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_8(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_15(i64 %returned_4869, ptr nocapture %stack) {
entry:
  %stackMemory.i = getelementptr i8, ptr %stack, i64 8
  %stackPrompt.i = getelementptr i8, ptr %stack, i64 32
  %stackRest.i = getelementptr i8, ptr %stack, i64 40
  %memory.unpack.i = load ptr, ptr %stackMemory.i, align 8
  %prompt.i = load ptr, ptr %stackPrompt.i, align 8
  %rest.i = load ptr, ptr %stackRest.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  store ptr null, ptr %promptStack_pointer.i, align 8
  tail call void @free(ptr %memory.unpack.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %entry
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %underflowStack.exit

free.i.i:                                         ; preds = %entry
  tail call void @free(ptr nonnull %prompt.i)
  br label %underflowStack.exit

underflowStack.exit:                              ; preds = %decrement.i.i, %free.i.i
  tail call void @free(ptr nonnull %stack)
  %stackPointer_pointer.i = getelementptr i8, ptr %rest.i, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %rest.i, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_17 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_17(i64 %returned_4869, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_20(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_22(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define tailcc void @returnAddress_31(%Pos %v_r_2522_10_11_31_4655, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %n_7_8_18_4688 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tag_35 = extractvalue %Pos %v_r_2522_10_11_31_4655, 0
  switch i64 %tag_35, label %label_37 [
    i64 0, label %label_38
    i64 1, label %label_42
  ]

label_37:                                         ; preds = %entry
  ret void

label_38:                                         ; preds = %entry
  %p_4_4684_pointer_34 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_4_4684 = load ptr, ptr %p_4_4684_pointer_34, align 8, !noalias !0
  %z.i = add i64 %n_7_8_18_4688, -1
  musttail call tailcc void @choice_worker_6_7_17_4702(i64 %z.i, ptr %p_4_4684, ptr nonnull %stack)
  ret void

label_42:                                         ; preds = %entry
  %isInside.i10 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i10)
  %newStackPointer.i11 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i11, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_39 = load ptr, ptr %newStackPointer.i11, align 8, !noalias !0
  musttail call tailcc void %returnAddress_39(i64 %n_7_8_18_4688, ptr nonnull %stack)
  ret void
}

define void @sharer_45(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_51(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_66(i64 %v_r_2544_6_28_4681, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2543_5_27_4621 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i = add i64 %v_r_2543_5_27_4621, %v_r_2544_6_28_4681
  %z.i6 = srem i64 %z.i, 1000000007
  %isInside.i11 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i11)
  %newStackPointer.i12 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i12, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_69 = load ptr, ptr %newStackPointer.i12, align 8, !noalias !0
  musttail call tailcc void %returnAddress_69(i64 %z.i6, ptr %stack)
  ret void
}

define void @sharer_73(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_77(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_63(i64 %v_r_2543_5_27_4621, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %k_2_24_4698 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_r_2543_5_27_4621, ptr %newStackPointer.i, align 4, !noalias !0
  %sharer_pointer_83 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_84 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_66, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_73, ptr %sharer_pointer_83, align 8, !noalias !0
  store ptr @eraser_77, ptr %eraser_pointer_84, align 8, !noalias !0
  %stack_85 = tail call fastcc ptr @resume(ptr %k_2_24_4698, ptr nonnull %stack)
  %stackPointer_pointer.i10 = getelementptr i8, ptr %stack_85, i64 8
  %stackPointer.i11 = load ptr, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %limit_pointer.i12 = getelementptr i8, ptr %stack_85, i64 24
  %limit.i13 = load ptr, ptr %limit_pointer.i12, align 8, !alias.scope !0
  %isInside.i14 = icmp ule ptr %stackPointer.i11, %limit.i13
  tail call void @llvm.assume(i1 %isInside.i14)
  %newStackPointer.i15 = getelementptr i8, ptr %stackPointer.i11, i64 -24
  store ptr %newStackPointer.i15, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %returnAddress_87 = load ptr, ptr %newStackPointer.i15, align 8, !noalias !0
  musttail call tailcc void %returnAddress_87(%Pos zeroinitializer, ptr %stack_85)
  ret void
}

define void @sharer_91(ptr %stackPointer) {
entry:
  %stackPointer_92 = getelementptr i8, ptr %stackPointer, i64 -8
  %k_2_24_4698_90 = load ptr, ptr %stackPointer_92, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %k_2_24_4698_90, align 4
  %referenceCount.1.i = add i64 %referenceCount.i, 1
  store i64 %referenceCount.1.i, ptr %k_2_24_4698_90, align 4
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_95(ptr %stackPointer) {
entry:
  %stackPointer_96 = getelementptr i8, ptr %stackPointer, i64 -8
  %k_2_24_4698_94 = load ptr, ptr %stackPointer_96, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %k_2_24_4698_94, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %entry
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_2_24_4698_94, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %entry
  %stack_pointer.i = getelementptr i8, ptr %k_2_24_4698_94, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i1

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i1

free.i1:                                          ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i1
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i1
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read, inaccessiblemem: write)
define tailcc void @returnAddress_109(%Pos %v_r_2520_9_10_22_4641, ptr nocapture readonly %stack) #11 {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  ret void
}

define tailcc void @choice_worker_6_7_17_4702(i64 %n_7_8_18_4688, ptr %p_4_4684, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %n_7_8_18_4688, 1
  %stackPointer_pointer.i30 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i31 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i32 = load ptr, ptr %stackPointer_pointer.i30, align 8, !alias.scope !0
  %limit.i33 = load ptr, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br i1 %z.i, label %label_122, label %label_108

label_108:                                        ; preds = %entry
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i32, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i33
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_108
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i32 to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_108, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_108 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i32, %label_108 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i30, align 8
  store i64 %n_7_8_18_4688, ptr %common.ret.op.i, align 4, !noalias !0
  %p_4_4684_pointer_57 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_4_4684, ptr %p_4_4684_pointer_57, align 8, !noalias !0
  %returnAddress_pointer_58 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_59 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_60 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_31, ptr %returnAddress_pointer_58, align 8, !noalias !0
  store ptr @sharer_45, ptr %sharer_pointer_59, align 8, !noalias !0
  store ptr @eraser_51, ptr %eraser_pointer_60, align 8, !noalias !0
  %pair_61 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_4684)
  %k_2_24_4698 = extractvalue <{ ptr, ptr }> %pair_61, 0
  %stack_62 = extractvalue <{ ptr, ptr }> %pair_61, 1
  %referenceCount.i = load i64, ptr %k_2_24_4698, align 4
  %referenceCount.1.i = add i64 %referenceCount.i, 1
  store i64 %referenceCount.1.i, ptr %k_2_24_4698, align 4
  %stackPointer_pointer.i3 = getelementptr i8, ptr %stack_62, i64 8
  %limit_pointer.i4 = getelementptr i8, ptr %stack_62, i64 24
  %currentStackPointer.i5 = load ptr, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %limit.i6 = load ptr, ptr %limit_pointer.i4, align 8, !alias.scope !0
  %nextStackPointer.i7 = getelementptr i8, ptr %currentStackPointer.i5, i64 32
  %isInside.not.i8 = icmp ugt ptr %nextStackPointer.i7, %limit.i6
  br i1 %isInside.not.i8, label %realloc.i11, label %stackAllocate.exit25

realloc.i11:                                      ; preds = %stackAllocate.exit
  %base_pointer.i12 = getelementptr i8, ptr %stack_62, i64 16
  %base.i13 = load ptr, ptr %base_pointer.i12, align 8, !alias.scope !0
  %intStackPointer.i14 = ptrtoint ptr %currentStackPointer.i5 to i64
  %intBase.i15 = ptrtoint ptr %base.i13 to i64
  %size.i16 = sub i64 %intStackPointer.i14, %intBase.i15
  %nextSize.i17 = add i64 %size.i16, 32
  %leadingZeros.i.i18 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i17, i1 false)
  %numBits.i.i19 = sub nuw nsw i64 64, %leadingZeros.i.i18
  %result.i.i20 = shl nuw i64 1, %numBits.i.i19
  %newBase.i21 = tail call ptr @realloc(ptr %base.i13, i64 %result.i.i20)
  %newLimit.i22 = getelementptr i8, ptr %newBase.i21, i64 %result.i.i20
  %newStackPointer.i23 = getelementptr i8, ptr %newBase.i21, i64 %size.i16
  %newNextStackPointer.i24 = getelementptr i8, ptr %newStackPointer.i23, i64 32
  store ptr %newBase.i21, ptr %base_pointer.i12, align 8, !alias.scope !0
  store ptr %newLimit.i22, ptr %limit_pointer.i4, align 8, !alias.scope !0
  br label %stackAllocate.exit25

stackAllocate.exit25:                             ; preds = %stackAllocate.exit, %realloc.i11
  %nextStackPointer.sink.i9 = phi ptr [ %newNextStackPointer.i24, %realloc.i11 ], [ %nextStackPointer.i7, %stackAllocate.exit ]
  %common.ret.op.i10 = phi ptr [ %newStackPointer.i23, %realloc.i11 ], [ %currentStackPointer.i5, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i9, ptr %stackPointer_pointer.i3, align 8
  store ptr %k_2_24_4698, ptr %common.ret.op.i10, align 8, !noalias !0
  %returnAddress_pointer_100 = getelementptr i8, ptr %common.ret.op.i10, i64 8
  %sharer_pointer_101 = getelementptr i8, ptr %common.ret.op.i10, i64 16
  %eraser_pointer_102 = getelementptr i8, ptr %common.ret.op.i10, i64 24
  store ptr @returnAddress_63, ptr %returnAddress_pointer_100, align 8, !noalias !0
  store ptr @sharer_91, ptr %sharer_pointer_101, align 8, !noalias !0
  store ptr @eraser_95, ptr %eraser_pointer_102, align 8, !noalias !0
  %stack_103 = tail call fastcc ptr @resume(ptr nonnull %k_2_24_4698, ptr nonnull %stack_62)
  %stackPointer_pointer.i26 = getelementptr i8, ptr %stack_103, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i26, align 8, !alias.scope !0
  %limit_pointer.i27 = getelementptr i8, ptr %stack_103, i64 24
  %limit.i28 = load ptr, ptr %limit_pointer.i27, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i28
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i26, align 8, !alias.scope !0
  %returnAddress_105 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_105(%Pos { i64 1, ptr null }, ptr %stack_103)
  ret void

label_122:                                        ; preds = %entry
  %nextStackPointer.i34 = getelementptr i8, ptr %currentStackPointer.i32, i64 24
  %isInside.not.i35 = icmp ugt ptr %nextStackPointer.i34, %limit.i33
  br i1 %isInside.not.i35, label %realloc.i38, label %stackAllocate.exit52

realloc.i38:                                      ; preds = %label_122
  %base_pointer.i39 = getelementptr i8, ptr %stack, i64 16
  %base.i40 = load ptr, ptr %base_pointer.i39, align 8, !alias.scope !0
  %intStackPointer.i41 = ptrtoint ptr %currentStackPointer.i32 to i64
  %intBase.i42 = ptrtoint ptr %base.i40 to i64
  %size.i43 = sub i64 %intStackPointer.i41, %intBase.i42
  %nextSize.i44 = add i64 %size.i43, 24
  %leadingZeros.i.i45 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i44, i1 false)
  %numBits.i.i46 = sub nuw nsw i64 64, %leadingZeros.i.i45
  %result.i.i47 = shl nuw i64 1, %numBits.i.i46
  %newBase.i48 = tail call ptr @realloc(ptr %base.i40, i64 %result.i.i47)
  %newLimit.i49 = getelementptr i8, ptr %newBase.i48, i64 %result.i.i47
  %newStackPointer.i50 = getelementptr i8, ptr %newBase.i48, i64 %size.i43
  %newNextStackPointer.i51 = getelementptr i8, ptr %newStackPointer.i50, i64 24
  store ptr %newBase.i48, ptr %base_pointer.i39, align 8, !alias.scope !0
  store ptr %newLimit.i49, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br label %stackAllocate.exit52

stackAllocate.exit52:                             ; preds = %label_122, %realloc.i38
  %nextStackPointer.sink.i36 = phi ptr [ %newNextStackPointer.i51, %realloc.i38 ], [ %nextStackPointer.i34, %label_122 ]
  %common.ret.op.i37 = phi ptr [ %newStackPointer.i50, %realloc.i38 ], [ %currentStackPointer.i32, %label_122 ]
  store ptr %nextStackPointer.sink.i36, ptr %stackPointer_pointer.i30, align 8
  %sharer_pointer_115 = getelementptr i8, ptr %common.ret.op.i37, i64 8
  %eraser_pointer_116 = getelementptr i8, ptr %common.ret.op.i37, i64 16
  store ptr @returnAddress_109, ptr %common.ret.op.i37, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_115, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_116, align 8, !noalias !0
  %pair_117 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_4684)
  %k_2_21_4879 = extractvalue <{ ptr, ptr }> %pair_117, 0
  %referenceCount.i1 = load i64, ptr %k_2_21_4879, align 4
  %cond.i = icmp eq i64 %referenceCount.i1, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %stackAllocate.exit52
  %referenceCount.1.i2 = add i64 %referenceCount.i1, -1
  store i64 %referenceCount.1.i2, ptr %k_2_21_4879, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %stackAllocate.exit52
  %stack_pointer.i = getelementptr i8, ptr %k_2_21_4879, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i53 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i54 = load ptr, ptr %stackPointer_pointer.i53, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i55

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i55

free.i55:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i54, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i54, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i55
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i55
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %stack_118 = extractvalue <{ ptr, ptr }> %pair_117, 1
  %stackPointer_pointer.i56 = getelementptr i8, ptr %stack_118, i64 8
  %stackPointer.i57 = load ptr, ptr %stackPointer_pointer.i56, align 8, !alias.scope !0
  %limit_pointer.i58 = getelementptr i8, ptr %stack_118, i64 24
  %limit.i59 = load ptr, ptr %limit_pointer.i58, align 8, !alias.scope !0
  %isInside.i60 = icmp ule ptr %stackPointer.i57, %limit.i59
  tail call void @llvm.assume(i1 %isInside.i60)
  %newStackPointer.i61 = getelementptr i8, ptr %stackPointer.i57, i64 -24
  store ptr %newStackPointer.i61, ptr %stackPointer_pointer.i56, align 8, !alias.scope !0
  %returnAddress_119 = load ptr, ptr %newStackPointer.i61, align 8, !noalias !0
  musttail call tailcc void %returnAddress_119(i64 0, ptr %stack_118)
  ret void
}

define tailcc void @returnAddress_130(%Pos %v_r_2522_10_19_49_4654, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %n_7_16_36_4635 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tag_134 = extractvalue %Pos %v_r_2522_10_19_49_4654, 0
  switch i64 %tag_134, label %label_136 [
    i64 0, label %label_137
    i64 1, label %label_141
  ]

label_136:                                        ; preds = %entry
  ret void

label_137:                                        ; preds = %entry
  %p_4_4684_pointer_133 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_4_4684 = load ptr, ptr %p_4_4684_pointer_133, align 8, !noalias !0
  %z.i = add i64 %n_7_16_36_4635, -1
  musttail call tailcc void @choice_worker_6_15_35_4627(i64 %z.i, ptr %p_4_4684, ptr nonnull %stack)
  ret void

label_141:                                        ; preds = %entry
  %isInside.i10 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i10)
  %newStackPointer.i11 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i11, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_138 = load ptr, ptr %newStackPointer.i11, align 8, !noalias !0
  musttail call tailcc void %returnAddress_138(i64 %n_7_16_36_4635, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_157(i64 %v_r_2544_6_46_4670, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2543_5_45_4632 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i = add i64 %v_r_2543_5_45_4632, %v_r_2544_6_46_4670
  %z.i6 = srem i64 %z.i, 1000000007
  %isInside.i11 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i11)
  %newStackPointer.i12 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i12, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_160 = load ptr, ptr %newStackPointer.i12, align 8, !noalias !0
  musttail call tailcc void %returnAddress_160(i64 %z.i6, ptr %stack)
  ret void
}

define tailcc void @returnAddress_154(i64 %v_r_2543_5_45_4632, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %k_2_42_4669 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_r_2543_5_45_4632, ptr %newStackPointer.i, align 4, !noalias !0
  %sharer_pointer_168 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_169 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_157, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_73, ptr %sharer_pointer_168, align 8, !noalias !0
  store ptr @eraser_77, ptr %eraser_pointer_169, align 8, !noalias !0
  %stack_170 = tail call fastcc ptr @resume(ptr %k_2_42_4669, ptr nonnull %stack)
  %stackPointer_pointer.i10 = getelementptr i8, ptr %stack_170, i64 8
  %stackPointer.i11 = load ptr, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %limit_pointer.i12 = getelementptr i8, ptr %stack_170, i64 24
  %limit.i13 = load ptr, ptr %limit_pointer.i12, align 8, !alias.scope !0
  %isInside.i14 = icmp ule ptr %stackPointer.i11, %limit.i13
  tail call void @llvm.assume(i1 %isInside.i14)
  %newStackPointer.i15 = getelementptr i8, ptr %stackPointer.i11, i64 -24
  store ptr %newStackPointer.i15, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %returnAddress_172 = load ptr, ptr %newStackPointer.i15, align 8, !noalias !0
  musttail call tailcc void %returnAddress_172(%Pos zeroinitializer, ptr %stack_170)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read, inaccessiblemem: write)
define tailcc void @returnAddress_188(%Pos %v_r_2520_9_18_40_4695, ptr nocapture readonly %stack) #11 {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  ret void
}

define tailcc void @choice_worker_6_15_35_4627(i64 %n_7_16_36_4635, ptr %p_4_4684, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %n_7_16_36_4635, 1
  %stackPointer_pointer.i30 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i31 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i32 = load ptr, ptr %stackPointer_pointer.i30, align 8, !alias.scope !0
  %limit.i33 = load ptr, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br i1 %z.i, label %label_201, label %label_187

label_187:                                        ; preds = %entry
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i32, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i33
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_187
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i32 to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_187, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_187 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i32, %label_187 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i30, align 8
  store i64 %n_7_16_36_4635, ptr %common.ret.op.i, align 4, !noalias !0
  %p_4_4684_pointer_148 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_4_4684, ptr %p_4_4684_pointer_148, align 8, !noalias !0
  %returnAddress_pointer_149 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_150 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_151 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_130, ptr %returnAddress_pointer_149, align 8, !noalias !0
  store ptr @sharer_45, ptr %sharer_pointer_150, align 8, !noalias !0
  store ptr @eraser_51, ptr %eraser_pointer_151, align 8, !noalias !0
  %pair_152 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_4684)
  %k_2_42_4669 = extractvalue <{ ptr, ptr }> %pair_152, 0
  %stack_153 = extractvalue <{ ptr, ptr }> %pair_152, 1
  %referenceCount.i = load i64, ptr %k_2_42_4669, align 4
  %referenceCount.1.i = add i64 %referenceCount.i, 1
  store i64 %referenceCount.1.i, ptr %k_2_42_4669, align 4
  %stackPointer_pointer.i3 = getelementptr i8, ptr %stack_153, i64 8
  %limit_pointer.i4 = getelementptr i8, ptr %stack_153, i64 24
  %currentStackPointer.i5 = load ptr, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %limit.i6 = load ptr, ptr %limit_pointer.i4, align 8, !alias.scope !0
  %nextStackPointer.i7 = getelementptr i8, ptr %currentStackPointer.i5, i64 32
  %isInside.not.i8 = icmp ugt ptr %nextStackPointer.i7, %limit.i6
  br i1 %isInside.not.i8, label %realloc.i11, label %stackAllocate.exit25

realloc.i11:                                      ; preds = %stackAllocate.exit
  %base_pointer.i12 = getelementptr i8, ptr %stack_153, i64 16
  %base.i13 = load ptr, ptr %base_pointer.i12, align 8, !alias.scope !0
  %intStackPointer.i14 = ptrtoint ptr %currentStackPointer.i5 to i64
  %intBase.i15 = ptrtoint ptr %base.i13 to i64
  %size.i16 = sub i64 %intStackPointer.i14, %intBase.i15
  %nextSize.i17 = add i64 %size.i16, 32
  %leadingZeros.i.i18 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i17, i1 false)
  %numBits.i.i19 = sub nuw nsw i64 64, %leadingZeros.i.i18
  %result.i.i20 = shl nuw i64 1, %numBits.i.i19
  %newBase.i21 = tail call ptr @realloc(ptr %base.i13, i64 %result.i.i20)
  %newLimit.i22 = getelementptr i8, ptr %newBase.i21, i64 %result.i.i20
  %newStackPointer.i23 = getelementptr i8, ptr %newBase.i21, i64 %size.i16
  %newNextStackPointer.i24 = getelementptr i8, ptr %newStackPointer.i23, i64 32
  store ptr %newBase.i21, ptr %base_pointer.i12, align 8, !alias.scope !0
  store ptr %newLimit.i22, ptr %limit_pointer.i4, align 8, !alias.scope !0
  br label %stackAllocate.exit25

stackAllocate.exit25:                             ; preds = %stackAllocate.exit, %realloc.i11
  %nextStackPointer.sink.i9 = phi ptr [ %newNextStackPointer.i24, %realloc.i11 ], [ %nextStackPointer.i7, %stackAllocate.exit ]
  %common.ret.op.i10 = phi ptr [ %newStackPointer.i23, %realloc.i11 ], [ %currentStackPointer.i5, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i9, ptr %stackPointer_pointer.i3, align 8
  store ptr %k_2_42_4669, ptr %common.ret.op.i10, align 8, !noalias !0
  %returnAddress_pointer_179 = getelementptr i8, ptr %common.ret.op.i10, i64 8
  %sharer_pointer_180 = getelementptr i8, ptr %common.ret.op.i10, i64 16
  %eraser_pointer_181 = getelementptr i8, ptr %common.ret.op.i10, i64 24
  store ptr @returnAddress_154, ptr %returnAddress_pointer_179, align 8, !noalias !0
  store ptr @sharer_91, ptr %sharer_pointer_180, align 8, !noalias !0
  store ptr @eraser_95, ptr %eraser_pointer_181, align 8, !noalias !0
  %stack_182 = tail call fastcc ptr @resume(ptr nonnull %k_2_42_4669, ptr nonnull %stack_153)
  %stackPointer_pointer.i26 = getelementptr i8, ptr %stack_182, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i26, align 8, !alias.scope !0
  %limit_pointer.i27 = getelementptr i8, ptr %stack_182, i64 24
  %limit.i28 = load ptr, ptr %limit_pointer.i27, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i28
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i26, align 8, !alias.scope !0
  %returnAddress_184 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_184(%Pos { i64 1, ptr null }, ptr %stack_182)
  ret void

label_201:                                        ; preds = %entry
  %nextStackPointer.i34 = getelementptr i8, ptr %currentStackPointer.i32, i64 24
  %isInside.not.i35 = icmp ugt ptr %nextStackPointer.i34, %limit.i33
  br i1 %isInside.not.i35, label %realloc.i38, label %stackAllocate.exit52

realloc.i38:                                      ; preds = %label_201
  %base_pointer.i39 = getelementptr i8, ptr %stack, i64 16
  %base.i40 = load ptr, ptr %base_pointer.i39, align 8, !alias.scope !0
  %intStackPointer.i41 = ptrtoint ptr %currentStackPointer.i32 to i64
  %intBase.i42 = ptrtoint ptr %base.i40 to i64
  %size.i43 = sub i64 %intStackPointer.i41, %intBase.i42
  %nextSize.i44 = add i64 %size.i43, 24
  %leadingZeros.i.i45 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i44, i1 false)
  %numBits.i.i46 = sub nuw nsw i64 64, %leadingZeros.i.i45
  %result.i.i47 = shl nuw i64 1, %numBits.i.i46
  %newBase.i48 = tail call ptr @realloc(ptr %base.i40, i64 %result.i.i47)
  %newLimit.i49 = getelementptr i8, ptr %newBase.i48, i64 %result.i.i47
  %newStackPointer.i50 = getelementptr i8, ptr %newBase.i48, i64 %size.i43
  %newNextStackPointer.i51 = getelementptr i8, ptr %newStackPointer.i50, i64 24
  store ptr %newBase.i48, ptr %base_pointer.i39, align 8, !alias.scope !0
  store ptr %newLimit.i49, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br label %stackAllocate.exit52

stackAllocate.exit52:                             ; preds = %label_201, %realloc.i38
  %nextStackPointer.sink.i36 = phi ptr [ %newNextStackPointer.i51, %realloc.i38 ], [ %nextStackPointer.i34, %label_201 ]
  %common.ret.op.i37 = phi ptr [ %newStackPointer.i50, %realloc.i38 ], [ %currentStackPointer.i32, %label_201 ]
  store ptr %nextStackPointer.sink.i36, ptr %stackPointer_pointer.i30, align 8
  %sharer_pointer_194 = getelementptr i8, ptr %common.ret.op.i37, i64 8
  %eraser_pointer_195 = getelementptr i8, ptr %common.ret.op.i37, i64 16
  store ptr @returnAddress_188, ptr %common.ret.op.i37, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_194, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_195, align 8, !noalias !0
  %pair_196 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_4684)
  %k_2_39_4892 = extractvalue <{ ptr, ptr }> %pair_196, 0
  %referenceCount.i1 = load i64, ptr %k_2_39_4892, align 4
  %cond.i = icmp eq i64 %referenceCount.i1, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %stackAllocate.exit52
  %referenceCount.1.i2 = add i64 %referenceCount.i1, -1
  store i64 %referenceCount.1.i2, ptr %k_2_39_4892, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %stackAllocate.exit52
  %stack_pointer.i = getelementptr i8, ptr %k_2_39_4892, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i53 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i54 = load ptr, ptr %stackPointer_pointer.i53, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i55

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i55

free.i55:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i54, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i54, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i55
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i55
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %stack_197 = extractvalue <{ ptr, ptr }> %pair_196, 1
  %stackPointer_pointer.i56 = getelementptr i8, ptr %stack_197, i64 8
  %stackPointer.i57 = load ptr, ptr %stackPointer_pointer.i56, align 8, !alias.scope !0
  %limit_pointer.i58 = getelementptr i8, ptr %stack_197, i64 24
  %limit.i59 = load ptr, ptr %limit_pointer.i58, align 8, !alias.scope !0
  %isInside.i60 = icmp ule ptr %stackPointer.i57, %limit.i59
  tail call void @llvm.assume(i1 %isInside.i60)
  %newStackPointer.i61 = getelementptr i8, ptr %stackPointer.i57, i64 -24
  store ptr %newStackPointer.i61, ptr %stackPointer_pointer.i56, align 8, !alias.scope !0
  %returnAddress_198 = load ptr, ptr %newStackPointer.i61, align 8, !noalias !0
  musttail call tailcc void %returnAddress_198(i64 0, ptr %stack_197)
  ret void
}

define tailcc void @returnAddress_210(%Pos %v_r_2522_10_27_67_4683, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %n_7_24_54_4659 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tag_214 = extractvalue %Pos %v_r_2522_10_27_67_4683, 0
  switch i64 %tag_214, label %label_216 [
    i64 0, label %label_217
    i64 1, label %label_221
  ]

label_216:                                        ; preds = %entry
  ret void

label_217:                                        ; preds = %entry
  %p_4_4684_pointer_213 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_4_4684 = load ptr, ptr %p_4_4684_pointer_213, align 8, !noalias !0
  %z.i = add i64 %n_7_24_54_4659, -1
  musttail call tailcc void @choice_worker_6_23_53_4638(i64 %z.i, ptr %p_4_4684, ptr nonnull %stack)
  ret void

label_221:                                        ; preds = %entry
  %isInside.i10 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i10)
  %newStackPointer.i11 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i11, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_218 = load ptr, ptr %newStackPointer.i11, align 8, !noalias !0
  musttail call tailcc void %returnAddress_218(i64 %n_7_24_54_4659, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_237(i64 %v_r_2544_6_64_4658, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2543_5_63_4639 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i = add i64 %v_r_2543_5_63_4639, %v_r_2544_6_64_4658
  %z.i6 = srem i64 %z.i, 1000000007
  %isInside.i11 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i11)
  %newStackPointer.i12 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i12, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_240 = load ptr, ptr %newStackPointer.i12, align 8, !noalias !0
  musttail call tailcc void %returnAddress_240(i64 %z.i6, ptr %stack)
  ret void
}

define tailcc void @returnAddress_234(i64 %v_r_2543_5_63_4639, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %k_2_60_4622 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_r_2543_5_63_4639, ptr %newStackPointer.i, align 4, !noalias !0
  %sharer_pointer_248 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_249 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_237, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_73, ptr %sharer_pointer_248, align 8, !noalias !0
  store ptr @eraser_77, ptr %eraser_pointer_249, align 8, !noalias !0
  %stack_250 = tail call fastcc ptr @resume(ptr %k_2_60_4622, ptr nonnull %stack)
  %stackPointer_pointer.i10 = getelementptr i8, ptr %stack_250, i64 8
  %stackPointer.i11 = load ptr, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %limit_pointer.i12 = getelementptr i8, ptr %stack_250, i64 24
  %limit.i13 = load ptr, ptr %limit_pointer.i12, align 8, !alias.scope !0
  %isInside.i14 = icmp ule ptr %stackPointer.i11, %limit.i13
  tail call void @llvm.assume(i1 %isInside.i14)
  %newStackPointer.i15 = getelementptr i8, ptr %stackPointer.i11, i64 -24
  store ptr %newStackPointer.i15, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %returnAddress_252 = load ptr, ptr %newStackPointer.i15, align 8, !noalias !0
  musttail call tailcc void %returnAddress_252(%Pos zeroinitializer, ptr %stack_250)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read, inaccessiblemem: write)
define tailcc void @returnAddress_268(%Pos %v_r_2520_9_26_58_4679, ptr nocapture readonly %stack) #11 {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  ret void
}

define tailcc void @choice_worker_6_23_53_4638(i64 %n_7_24_54_4659, ptr %p_4_4684, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %n_7_24_54_4659, 1
  %stackPointer_pointer.i30 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i31 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i32 = load ptr, ptr %stackPointer_pointer.i30, align 8, !alias.scope !0
  %limit.i33 = load ptr, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br i1 %z.i, label %label_281, label %label_267

label_267:                                        ; preds = %entry
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i32, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i33
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_267
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i32 to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_267, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_267 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i32, %label_267 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i30, align 8
  store i64 %n_7_24_54_4659, ptr %common.ret.op.i, align 4, !noalias !0
  %p_4_4684_pointer_228 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_4_4684, ptr %p_4_4684_pointer_228, align 8, !noalias !0
  %returnAddress_pointer_229 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_230 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_231 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_210, ptr %returnAddress_pointer_229, align 8, !noalias !0
  store ptr @sharer_45, ptr %sharer_pointer_230, align 8, !noalias !0
  store ptr @eraser_51, ptr %eraser_pointer_231, align 8, !noalias !0
  %pair_232 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_4684)
  %k_2_60_4622 = extractvalue <{ ptr, ptr }> %pair_232, 0
  %stack_233 = extractvalue <{ ptr, ptr }> %pair_232, 1
  %referenceCount.i = load i64, ptr %k_2_60_4622, align 4
  %referenceCount.1.i = add i64 %referenceCount.i, 1
  store i64 %referenceCount.1.i, ptr %k_2_60_4622, align 4
  %stackPointer_pointer.i3 = getelementptr i8, ptr %stack_233, i64 8
  %limit_pointer.i4 = getelementptr i8, ptr %stack_233, i64 24
  %currentStackPointer.i5 = load ptr, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %limit.i6 = load ptr, ptr %limit_pointer.i4, align 8, !alias.scope !0
  %nextStackPointer.i7 = getelementptr i8, ptr %currentStackPointer.i5, i64 32
  %isInside.not.i8 = icmp ugt ptr %nextStackPointer.i7, %limit.i6
  br i1 %isInside.not.i8, label %realloc.i11, label %stackAllocate.exit25

realloc.i11:                                      ; preds = %stackAllocate.exit
  %base_pointer.i12 = getelementptr i8, ptr %stack_233, i64 16
  %base.i13 = load ptr, ptr %base_pointer.i12, align 8, !alias.scope !0
  %intStackPointer.i14 = ptrtoint ptr %currentStackPointer.i5 to i64
  %intBase.i15 = ptrtoint ptr %base.i13 to i64
  %size.i16 = sub i64 %intStackPointer.i14, %intBase.i15
  %nextSize.i17 = add i64 %size.i16, 32
  %leadingZeros.i.i18 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i17, i1 false)
  %numBits.i.i19 = sub nuw nsw i64 64, %leadingZeros.i.i18
  %result.i.i20 = shl nuw i64 1, %numBits.i.i19
  %newBase.i21 = tail call ptr @realloc(ptr %base.i13, i64 %result.i.i20)
  %newLimit.i22 = getelementptr i8, ptr %newBase.i21, i64 %result.i.i20
  %newStackPointer.i23 = getelementptr i8, ptr %newBase.i21, i64 %size.i16
  %newNextStackPointer.i24 = getelementptr i8, ptr %newStackPointer.i23, i64 32
  store ptr %newBase.i21, ptr %base_pointer.i12, align 8, !alias.scope !0
  store ptr %newLimit.i22, ptr %limit_pointer.i4, align 8, !alias.scope !0
  br label %stackAllocate.exit25

stackAllocate.exit25:                             ; preds = %stackAllocate.exit, %realloc.i11
  %nextStackPointer.sink.i9 = phi ptr [ %newNextStackPointer.i24, %realloc.i11 ], [ %nextStackPointer.i7, %stackAllocate.exit ]
  %common.ret.op.i10 = phi ptr [ %newStackPointer.i23, %realloc.i11 ], [ %currentStackPointer.i5, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i9, ptr %stackPointer_pointer.i3, align 8
  store ptr %k_2_60_4622, ptr %common.ret.op.i10, align 8, !noalias !0
  %returnAddress_pointer_259 = getelementptr i8, ptr %common.ret.op.i10, i64 8
  %sharer_pointer_260 = getelementptr i8, ptr %common.ret.op.i10, i64 16
  %eraser_pointer_261 = getelementptr i8, ptr %common.ret.op.i10, i64 24
  store ptr @returnAddress_234, ptr %returnAddress_pointer_259, align 8, !noalias !0
  store ptr @sharer_91, ptr %sharer_pointer_260, align 8, !noalias !0
  store ptr @eraser_95, ptr %eraser_pointer_261, align 8, !noalias !0
  %stack_262 = tail call fastcc ptr @resume(ptr nonnull %k_2_60_4622, ptr nonnull %stack_233)
  %stackPointer_pointer.i26 = getelementptr i8, ptr %stack_262, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i26, align 8, !alias.scope !0
  %limit_pointer.i27 = getelementptr i8, ptr %stack_262, i64 24
  %limit.i28 = load ptr, ptr %limit_pointer.i27, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i28
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i26, align 8, !alias.scope !0
  %returnAddress_264 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_264(%Pos { i64 1, ptr null }, ptr %stack_262)
  ret void

label_281:                                        ; preds = %entry
  %nextStackPointer.i34 = getelementptr i8, ptr %currentStackPointer.i32, i64 24
  %isInside.not.i35 = icmp ugt ptr %nextStackPointer.i34, %limit.i33
  br i1 %isInside.not.i35, label %realloc.i38, label %stackAllocate.exit52

realloc.i38:                                      ; preds = %label_281
  %base_pointer.i39 = getelementptr i8, ptr %stack, i64 16
  %base.i40 = load ptr, ptr %base_pointer.i39, align 8, !alias.scope !0
  %intStackPointer.i41 = ptrtoint ptr %currentStackPointer.i32 to i64
  %intBase.i42 = ptrtoint ptr %base.i40 to i64
  %size.i43 = sub i64 %intStackPointer.i41, %intBase.i42
  %nextSize.i44 = add i64 %size.i43, 24
  %leadingZeros.i.i45 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i44, i1 false)
  %numBits.i.i46 = sub nuw nsw i64 64, %leadingZeros.i.i45
  %result.i.i47 = shl nuw i64 1, %numBits.i.i46
  %newBase.i48 = tail call ptr @realloc(ptr %base.i40, i64 %result.i.i47)
  %newLimit.i49 = getelementptr i8, ptr %newBase.i48, i64 %result.i.i47
  %newStackPointer.i50 = getelementptr i8, ptr %newBase.i48, i64 %size.i43
  %newNextStackPointer.i51 = getelementptr i8, ptr %newStackPointer.i50, i64 24
  store ptr %newBase.i48, ptr %base_pointer.i39, align 8, !alias.scope !0
  store ptr %newLimit.i49, ptr %limit_pointer.i31, align 8, !alias.scope !0
  br label %stackAllocate.exit52

stackAllocate.exit52:                             ; preds = %label_281, %realloc.i38
  %nextStackPointer.sink.i36 = phi ptr [ %newNextStackPointer.i51, %realloc.i38 ], [ %nextStackPointer.i34, %label_281 ]
  %common.ret.op.i37 = phi ptr [ %newStackPointer.i50, %realloc.i38 ], [ %currentStackPointer.i32, %label_281 ]
  store ptr %nextStackPointer.sink.i36, ptr %stackPointer_pointer.i30, align 8
  %sharer_pointer_274 = getelementptr i8, ptr %common.ret.op.i37, i64 8
  %eraser_pointer_275 = getelementptr i8, ptr %common.ret.op.i37, i64 16
  store ptr @returnAddress_268, ptr %common.ret.op.i37, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_274, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_275, align 8, !noalias !0
  %pair_276 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_4684)
  %k_2_57_4905 = extractvalue <{ ptr, ptr }> %pair_276, 0
  %referenceCount.i1 = load i64, ptr %k_2_57_4905, align 4
  %cond.i = icmp eq i64 %referenceCount.i1, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %stackAllocate.exit52
  %referenceCount.1.i2 = add i64 %referenceCount.i1, -1
  store i64 %referenceCount.1.i2, ptr %k_2_57_4905, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %stackAllocate.exit52
  %stack_pointer.i = getelementptr i8, ptr %k_2_57_4905, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i53 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i54 = load ptr, ptr %stackPointer_pointer.i53, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i55

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i55

free.i55:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i54, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i54, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i55
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i55
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %stack_277 = extractvalue <{ ptr, ptr }> %pair_276, 1
  %stackPointer_pointer.i56 = getelementptr i8, ptr %stack_277, i64 8
  %stackPointer.i57 = load ptr, ptr %stackPointer_pointer.i56, align 8, !alias.scope !0
  %limit_pointer.i58 = getelementptr i8, ptr %stack_277, i64 24
  %limit.i59 = load ptr, ptr %limit_pointer.i58, align 8, !alias.scope !0
  %isInside.i60 = icmp ule ptr %stackPointer.i57, %limit.i59
  tail call void @llvm.assume(i1 %isInside.i60)
  %newStackPointer.i61 = getelementptr i8, ptr %stackPointer.i57, i64 -24
  store ptr %newStackPointer.i61, ptr %stackPointer_pointer.i56, align 8, !alias.scope !0
  %returnAddress_278 = load ptr, ptr %newStackPointer.i61, align 8, !noalias !0
  musttail call tailcc void %returnAddress_278(i64 0, ptr %stack_277)
  ret void
}

define tailcc void @returnAddress_288(%Pos %v_r_2545_77_4662, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %tag_289 = extractvalue %Pos %v_r_2545_77_4662, 0
  %cond = icmp eq i64 %tag_289, 0
  br i1 %cond, label %next.i, label %label_291

label_291:                                        ; preds = %entry
  ret void

next.i:                                           ; preds = %entry
  %fields_290 = extractvalue %Pos %v_r_2545_77_4662, 1
  %environment.i = getelementptr i8, ptr %fields_290, i64 16
  %v_y_2533_12_88_4644 = load i64, ptr %environment.i, align 4, !noalias !0
  %v_y_2534_13_89_4700_pointer_294 = getelementptr i8, ptr %fields_290, i64 24
  %v_y_2534_13_89_4700 = load i64, ptr %v_y_2534_13_89_4700_pointer_294, align 4, !noalias !0
  %v_y_2535_14_90_4673_pointer_295 = getelementptr i8, ptr %fields_290, i64 32
  %v_y_2535_14_90_4673 = load i64, ptr %v_y_2535_14_90_4673_pointer_295, align 4, !noalias !0
  %referenceCount.i = load i64, ptr %fields_290, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_290, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_290, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_290)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %z.i = mul i64 %v_y_2533_12_88_4644, 53
  %z.i1 = mul i64 %v_y_2534_13_89_4700, 2809
  %z.i2 = add i64 %z.i1, %z.i
  %z.i3 = mul i64 %v_y_2535_14_90_4673, 148877
  %z.i4 = add i64 %z.i2, %z.i3
  %z.i5 = srem i64 %z.i4, 1000000007
  %stackPointer.i7 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i9 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i10 = icmp ule ptr %stackPointer.i7, %limit.i9
  tail call void @llvm.assume(i1 %isInside.i10)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i7, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_296 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_296(i64 %z.i5, ptr nonnull %stack)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read, inaccessiblemem: write)
define tailcc void @returnAddress_307(%Pos %v_r_2529_34_76_4663, ptr nocapture readonly %stack) #11 {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_326(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define tailcc void @returnAddress_282(i64 %k_29_69_4646, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %j_21_51_4672 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %p_4_4684_pointer_285 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %p_4_4684 = load ptr, ptr %p_4_4684_pointer_285, align 8, !noalias !0
  %i_13_33_4677_pointer_286 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_13_33_4677 = load i64, ptr %i_13_33_4677_pointer_286, align 4, !noalias !0
  %tmp_4850_pointer_287 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4850 = load i64, ptr %tmp_4850_pointer_287, align 4, !noalias !0
  %z.i = add i64 %j_21_51_4672, %k_29_69_4646
  %z.i6 = add i64 %z.i, %i_13_33_4677
  %z.i7 = icmp eq i64 %z.i6, %tmp_4850
  %isInside.not.i = icmp ugt ptr %tmp_4850_pointer_287, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 24
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i11 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i11, i64 24
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i47 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %tmp_4850_pointer_287, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i11, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_302 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_303 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_288, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_302, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_303, align 8, !noalias !0
  br i1 %z.i7, label %label_337, label %label_320

label_320:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i16 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i17 = icmp ugt ptr %nextStackPointer.i16, %limit.i47
  br i1 %isInside.not.i17, label %realloc.i20, label %stackAllocate.exit34

realloc.i20:                                      ; preds = %label_320
  %base_pointer.i21 = getelementptr i8, ptr %stack, i64 16
  %base.i22 = load ptr, ptr %base_pointer.i21, align 8, !alias.scope !0
  %intStackPointer.i23 = ptrtoint ptr %nextStackPointer.sink.i to i64
  %intBase.i24 = ptrtoint ptr %base.i22 to i64
  %size.i25 = sub i64 %intStackPointer.i23, %intBase.i24
  %nextSize.i26 = add i64 %size.i25, 24
  %leadingZeros.i.i27 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i26, i1 false)
  %numBits.i.i28 = sub nuw nsw i64 64, %leadingZeros.i.i27
  %result.i.i29 = shl nuw i64 1, %numBits.i.i28
  %newBase.i30 = tail call ptr @realloc(ptr %base.i22, i64 %result.i.i29)
  %newLimit.i31 = getelementptr i8, ptr %newBase.i30, i64 %result.i.i29
  %newStackPointer.i32 = getelementptr i8, ptr %newBase.i30, i64 %size.i25
  %newNextStackPointer.i33 = getelementptr i8, ptr %newStackPointer.i32, i64 24
  store ptr %newBase.i30, ptr %base_pointer.i21, align 8, !alias.scope !0
  store ptr %newLimit.i31, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit34

stackAllocate.exit34:                             ; preds = %label_320, %realloc.i20
  %nextStackPointer.sink.i18 = phi ptr [ %newNextStackPointer.i33, %realloc.i20 ], [ %nextStackPointer.i16, %label_320 ]
  %common.ret.op.i19 = phi ptr [ %newStackPointer.i32, %realloc.i20 ], [ %nextStackPointer.sink.i, %label_320 ]
  store ptr %nextStackPointer.sink.i18, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_313 = getelementptr i8, ptr %common.ret.op.i19, i64 8
  %eraser_pointer_314 = getelementptr i8, ptr %common.ret.op.i19, i64 16
  store ptr @returnAddress_307, ptr %common.ret.op.i19, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_313, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_314, align 8, !noalias !0
  %pair_315 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_4684)
  %k_2_75_4920 = extractvalue <{ ptr, ptr }> %pair_315, 0
  %referenceCount.i = load i64, ptr %k_2_75_4920, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %stackAllocate.exit34
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_2_75_4920, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %stackAllocate.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_2_75_4920, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i35 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i36 = load ptr, ptr %stackPointer_pointer.i35, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i37

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i37

free.i37:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i36, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i36, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i37
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i37
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %stack_316 = extractvalue <{ ptr, ptr }> %pair_315, 1
  %stackPointer_pointer.i38 = getelementptr i8, ptr %stack_316, i64 8
  %stackPointer.i39 = load ptr, ptr %stackPointer_pointer.i38, align 8, !alias.scope !0
  %limit_pointer.i40 = getelementptr i8, ptr %stack_316, i64 24
  %limit.i41 = load ptr, ptr %limit_pointer.i40, align 8, !alias.scope !0
  %isInside.i42 = icmp ule ptr %stackPointer.i39, %limit.i41
  tail call void @llvm.assume(i1 %isInside.i42)
  %newStackPointer.i43 = getelementptr i8, ptr %stackPointer.i39, i64 -24
  store ptr %newStackPointer.i43, ptr %stackPointer_pointer.i38, align 8, !alias.scope !0
  %returnAddress_317 = load ptr, ptr %newStackPointer.i43, align 8, !noalias !0
  musttail call tailcc void %returnAddress_317(i64 0, ptr %stack_316)
  ret void

label_337:                                        ; preds = %stackAllocate.exit
  %object.i = tail call dereferenceable_or_null(40) ptr @malloc(i64 40)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_326, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %i_13_33_4677, ptr %environment.i, align 4, !noalias !0
  %j_21_51_4672_pointer_331 = getelementptr i8, ptr %object.i, i64 24
  store i64 %j_21_51_4672, ptr %j_21_51_4672_pointer_331, align 4, !noalias !0
  %k_29_69_4646_pointer_332 = getelementptr i8, ptr %object.i, i64 32
  store i64 %k_29_69_4646, ptr %k_29_69_4646_pointer_332, align 4, !noalias !0
  %make_4922 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %isInside.i48 = icmp ule ptr %nextStackPointer.sink.i, %limit.i47
  tail call void @llvm.assume(i1 %isInside.i48)
  %newStackPointer.i49 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i49, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_334 = load ptr, ptr %newStackPointer.i49, align 8, !noalias !0
  musttail call tailcc void %returnAddress_334(%Pos %make_4922, ptr nonnull %stack)
  ret void
}

define void @sharer_342(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_352(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_202(i64 %j_21_51_4672, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %p_4_4684 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %i_13_33_4677_pointer_205 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_13_33_4677 = load i64, ptr %i_13_33_4677_pointer_205, align 4, !noalias !0
  %tmp_4850_pointer_206 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4850 = load i64, ptr %tmp_4850_pointer_206, align 4, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 56
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i9 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i9, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i9, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = add i64 %j_21_51_4672, -1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %j_21_51_4672, ptr %common.ret.op.i, align 4, !noalias !0
  %p_4_4684_pointer_360 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_4_4684, ptr %p_4_4684_pointer_360, align 8, !noalias !0
  %i_13_33_4677_pointer_361 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_13_33_4677, ptr %i_13_33_4677_pointer_361, align 4, !noalias !0
  %tmp_4850_pointer_362 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_4850, ptr %tmp_4850_pointer_362, align 4, !noalias !0
  %returnAddress_pointer_363 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_364 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_365 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_282, ptr %returnAddress_pointer_363, align 8, !noalias !0
  store ptr @sharer_342, ptr %sharer_pointer_364, align 8, !noalias !0
  store ptr @eraser_352, ptr %eraser_pointer_365, align 8, !noalias !0
  musttail call tailcc void @choice_worker_6_23_53_4638(i64 %z.i, ptr %p_4_4684, ptr nonnull %stack)
  ret void
}

define void @sharer_369(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_377(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -32
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_123(i64 %i_13_33_4677, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %p_4_4684 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_4850_pointer_126 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4850 = load i64, ptr %tmp_4850_pointer_126, align 4, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 48
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i9 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i9, i64 48
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i9, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = add i64 %i_13_33_4677, -1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_4_4684, ptr %common.ret.op.i, align 8, !noalias !0
  %i_13_33_4677_pointer_384 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %i_13_33_4677, ptr %i_13_33_4677_pointer_384, align 4, !noalias !0
  %tmp_4850_pointer_385 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_4850, ptr %tmp_4850_pointer_385, align 4, !noalias !0
  %returnAddress_pointer_386 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %sharer_pointer_387 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %eraser_pointer_388 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr @returnAddress_202, ptr %returnAddress_pointer_386, align 8, !noalias !0
  store ptr @sharer_369, ptr %sharer_pointer_387, align 8, !noalias !0
  store ptr @eraser_377, ptr %eraser_pointer_388, align 8, !noalias !0
  musttail call tailcc void @choice_worker_6_15_35_4627(i64 %z.i, ptr %p_4_4684, ptr nonnull %stack)
  ret void
}

define void @sharer_391(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_397(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3477_3541, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_12 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_13 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_2, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_12, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_13, align 8, !noalias !0
  %calloc.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i = getelementptr i8, ptr %stackPointer.i.i, i64 64
  store i64 0, ptr %stack.i, align 8
  %stack.repack1.i = getelementptr inbounds i8, ptr %stack.i, i64 8
  store ptr %stackPointer.i.i, ptr %stack.repack1.i, align 8
  %stack.repack1.repack7.i = getelementptr inbounds i8, ptr %stack.i, i64 16
  store ptr %stackPointer.i.i, ptr %stack.repack1.repack7.i, align 8
  %stack.repack1.repack9.i = getelementptr inbounds i8, ptr %stack.i, i64 24
  store ptr %limit.i.i, ptr %stack.repack1.repack9.i, align 8
  %stack.repack3.i = getelementptr inbounds i8, ptr %stack.i, i64 32
  store ptr %calloc.i.i, ptr %stack.repack3.i, align 8
  %stack.repack5.i = getelementptr inbounds i8, ptr %stack.i, i64 40
  store ptr %stack, ptr %stack.repack5.i, align 8
  %stack_pointer.i = getelementptr i8, ptr %calloc.i.i, i64 8
  store ptr %stack.i, ptr %stack_pointer.i, align 8
  %nextStackPointer.i8 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i9 = icmp ugt ptr %nextStackPointer.i8, %limit.i.i
  br i1 %isInside.not.i9, label %realloc.i12, label %stackAllocate.exit26

realloc.i12:                                      ; preds = %stackAllocate.exit
  %newBase.i22 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i23 = getelementptr i8, ptr %newBase.i22, i64 32
  %newNextStackPointer.i25 = getelementptr i8, ptr %newBase.i22, i64 24
  store ptr %newBase.i22, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i23, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit26

stackAllocate.exit26:                             ; preds = %stackAllocate.exit, %realloc.i12
  %limit.i30 = phi ptr [ %newLimit.i23, %realloc.i12 ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i10 = phi ptr [ %newNextStackPointer.i25, %realloc.i12 ], [ %nextStackPointer.i8, %stackAllocate.exit ]
  %base.i37 = phi ptr [ %newBase.i22, %realloc.i12 ], [ %stackPointer.i.i, %stackAllocate.exit ]
  %sharer_pointer_26 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_27 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_15, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_20, ptr %sharer_pointer_26, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_27, align 8, !noalias !0
  %nextStackPointer.i31 = getelementptr i8, ptr %nextStackPointer.sink.i10, i64 40
  %isInside.not.i32 = icmp ugt ptr %nextStackPointer.i31, %limit.i30
  br i1 %isInside.not.i32, label %realloc.i35, label %stackAllocate.exit49

realloc.i35:                                      ; preds = %stackAllocate.exit26
  %intStackPointer.i38 = ptrtoint ptr %nextStackPointer.sink.i10 to i64
  %intBase.i39 = ptrtoint ptr %base.i37 to i64
  %size.i40 = sub i64 %intStackPointer.i38, %intBase.i39
  %nextSize.i41 = add i64 %size.i40, 40
  %leadingZeros.i.i42 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i41, i1 false)
  %numBits.i.i43 = sub nuw nsw i64 64, %leadingZeros.i.i42
  %result.i.i44 = shl nuw i64 1, %numBits.i.i43
  %newBase.i45 = tail call ptr @realloc(ptr nonnull %base.i37, i64 %result.i.i44)
  %newLimit.i46 = getelementptr i8, ptr %newBase.i45, i64 %result.i.i44
  %newStackPointer.i47 = getelementptr i8, ptr %newBase.i45, i64 %size.i40
  %newNextStackPointer.i48 = getelementptr i8, ptr %newStackPointer.i47, i64 40
  store ptr %newBase.i45, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i46, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit49

stackAllocate.exit49:                             ; preds = %stackAllocate.exit26, %realloc.i35
  %nextStackPointer.sink.i33 = phi ptr [ %newNextStackPointer.i48, %realloc.i35 ], [ %nextStackPointer.i31, %stackAllocate.exit26 ]
  %common.ret.op.i34 = phi ptr [ %newStackPointer.i47, %realloc.i35 ], [ %nextStackPointer.sink.i10, %stackAllocate.exit26 ]
  %unboxed.i = extractvalue %Pos %v_coe_3477_3541, 0
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  store ptr %calloc.i.i, ptr %common.ret.op.i34, align 8, !noalias !0
  %tmp_4850_pointer_403 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  store i64 %unboxed.i, ptr %tmp_4850_pointer_403, align 4, !noalias !0
  %returnAddress_pointer_404 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  %sharer_pointer_405 = getelementptr i8, ptr %common.ret.op.i34, i64 24
  %eraser_pointer_406 = getelementptr i8, ptr %common.ret.op.i34, i64 32
  store ptr @returnAddress_123, ptr %returnAddress_pointer_404, align 8, !noalias !0
  store ptr @sharer_391, ptr %sharer_pointer_405, align 8, !noalias !0
  store ptr @eraser_397, ptr %eraser_pointer_406, align 8, !noalias !0
  musttail call tailcc void @choice_worker_6_7_17_4702(i64 %unboxed.i, ptr nonnull %calloc.i.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_412(%Pos %returned_4923, ptr nocapture %stack) {
entry:
  %stackMemory.i = getelementptr i8, ptr %stack, i64 8
  %stackPrompt.i = getelementptr i8, ptr %stack, i64 32
  %stackRest.i = getelementptr i8, ptr %stack, i64 40
  %memory.unpack.i = load ptr, ptr %stackMemory.i, align 8
  %prompt.i = load ptr, ptr %stackPrompt.i, align 8
  %rest.i = load ptr, ptr %stackRest.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  store ptr null, ptr %promptStack_pointer.i, align 8
  tail call void @free(ptr %memory.unpack.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %entry
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %underflowStack.exit

free.i.i:                                         ; preds = %entry
  tail call void @free(ptr nonnull %prompt.i)
  br label %underflowStack.exit

underflowStack.exit:                              ; preds = %decrement.i.i, %free.i.i
  tail call void @free(ptr nonnull %stack)
  %stackPointer_pointer.i = getelementptr i8, ptr %rest.i, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %rest.i, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_414 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_414(%Pos %returned_4923, ptr %rest.i)
  ret void
}

define void @eraser_428(ptr nocapture readonly %environment) {
entry:
  %tmp_4794_426.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_4794_426.unpack2 = load ptr, ptr %tmp_4794_426.elt1, align 8, !noalias !0
  %acc_3_3_5_169_4445_427.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_4445_427.unpack5 = load ptr, ptr %acc_3_3_5_169_4445_427.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_4794_426.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_4794_426.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_4794_426.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_4794_426.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_4794_426.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_4794_426.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_4445_427.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_4445_427.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_4445_427.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_4445_427.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_4445_427.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_4445_427.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4539(i64 %start_2_2_4_168_4370, %Pos %acc_3_3_5_169_4445, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4370, 1
  br i1 %z.i6, label %label_438, label %label_434

label_434:                                        ; preds = %entry, %label_434
  %acc_3_3_5_169_4445.tr8 = phi %Pos [ %make_4929, %label_434 ], [ %acc_3_3_5_169_4445, %entry ]
  %start_2_2_4_168_4370.tr7 = phi i64 [ %z.i5, %label_434 ], [ %start_2_2_4_168_4370, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4370.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4370.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_428, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_4926.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_4926.elt, ptr %environment.i, align 8, !noalias !0
  %environment_425.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_4926.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_4926.elt2, ptr %environment_425.repack1, align 8, !noalias !0
  %acc_3_3_5_169_4445_pointer_432 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_4445.elt = extractvalue %Pos %acc_3_3_5_169_4445.tr8, 0
  store i64 %acc_3_3_5_169_4445.elt, ptr %acc_3_3_5_169_4445_pointer_432, align 8, !noalias !0
  %acc_3_3_5_169_4445_pointer_432.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_4445.elt4 = extractvalue %Pos %acc_3_3_5_169_4445.tr8, 1
  store ptr %acc_3_3_5_169_4445.elt4, ptr %acc_3_3_5_169_4445_pointer_432.repack3, align 8, !noalias !0
  %make_4929 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4370.tr7, 2
  br i1 %z.i, label %label_438, label %label_434

label_438:                                        ; preds = %label_434, %entry
  %acc_3_3_5_169_4445.tr.lcssa = phi %Pos [ %acc_3_3_5_169_4445, %entry ], [ %make_4929, %label_434 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_435 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_435(%Pos %acc_3_3_5_169_4445.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_449(%Pos %v_r_2636_32_59_223_4351, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i63 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i63)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %index_7_34_198_4430 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %p_8_9_4242_pointer_452 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %p_8_9_4242 = load ptr, ptr %p_8_9_4242_pointer_452, align 8, !noalias !0
  %tmp_4801_pointer_453 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_4801 = load i64, ptr %tmp_4801_pointer_453, align 4, !noalias !0
  %acc_8_35_199_4513_pointer_454 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %acc_8_35_199_4513 = load i64, ptr %acc_8_35_199_4513_pointer_454, align 4, !noalias !0
  %v_r_2552_30_194_4420_pointer_455 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2552_30_194_4420.unpack = load i64, ptr %v_r_2552_30_194_4420_pointer_455, align 8, !noalias !0
  %v_r_2552_30_194_4420.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2552_30_194_4420.unpack2 = load ptr, ptr %v_r_2552_30_194_4420.elt1, align 8, !noalias !0
  %tag_456 = extractvalue %Pos %v_r_2636_32_59_223_4351, 0
  %fields_457 = extractvalue %Pos %v_r_2636_32_59_223_4351, 1
  switch i64 %tag_456, label %common.ret [
    i64 1, label %label_481
    i64 0, label %label_488
  ]

common.ret:                                       ; preds = %entry
  ret void

label_469:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2552_30_194_4420.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_469
  %referenceCount.i.i37 = load i64, ptr %v_r_2552_30_194_4420.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2552_30_194_4420.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2552_30_194_4420.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2552_30_194_4420.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2552_30_194_4420.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_469, %decr.i.i39, %free.i.i41
  %pair_464 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4242)
  %k_13_14_4_4707 = extractvalue <{ ptr, ptr }> %pair_464, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_4707, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_4707, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_4707, i64 40
  %stack.i57 = load ptr, ptr %stack_pointer.i56, align 8
  store ptr null, ptr %stack_pointer.i56, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i55
  %stack.tr.i = phi ptr [ %stack.i57, %free.i55 ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i64 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i65 = load ptr, ptr %stackPointer_pointer.i64, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i66

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i66

free.i66:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i65, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i65, i64 -8
  %eraser.i.i67 = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i67(ptr %newStackPointer.i.i)
  %referenceCount.i.i68 = load i64, ptr %prompt.i, align 4
  %cond.i.i69 = icmp eq i64 %referenceCount.i.i68, 0
  br i1 %cond.i.i69, label %free.i.i71, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i66
  %newReferenceCount.i.i = add i64 %referenceCount.i.i68, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i71:                                       ; preds = %free.i66
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i71, %decrement.i.i
  %isNull.i70 = icmp eq ptr %rest.i, null
  br i1 %isNull.i70, label %eraseResumption.exit58, label %tailrecurse.i

eraseResumption.exit58:                           ; preds = %erasePrompt.exit.i, %decr.i53
  %stack_465 = extractvalue <{ ptr, ptr }> %pair_464, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_465, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_465, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_466 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_466(%Pos { i64 5, ptr null }, ptr %stack_465)
  ret void

label_478:                                        ; preds = %label_480
  %isNull.i.i24 = icmp eq ptr %v_r_2552_30_194_4420.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_478
  %referenceCount.i.i26 = load i64, ptr %v_r_2552_30_194_4420.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2552_30_194_4420.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2552_30_194_4420.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2552_30_194_4420.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2552_30_194_4420.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_478, %decr.i.i28, %free.i.i30
  %pair_473 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4242)
  %k_13_14_4_4706 = extractvalue <{ ptr, ptr }> %pair_473, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_4706, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_4706, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4706, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i78

tailrecurse.i78:                                  ; preds = %erasePrompt.exit.i97, %free.i50
  %stack.tr.i79 = phi ptr [ %stack.i, %free.i50 ], [ %rest.i85, %erasePrompt.exit.i97 ]
  %stackPointer_pointer.i80 = getelementptr i8, ptr %stack.tr.i79, i64 8
  %prompt_pointer.i81 = getelementptr i8, ptr %stack.tr.i79, i64 32
  %rest_pointer.i82 = getelementptr i8, ptr %stack.tr.i79, i64 40
  %stackPointer.i83 = load ptr, ptr %stackPointer_pointer.i80, align 8
  %prompt.i84 = load ptr, ptr %prompt_pointer.i81, align 8
  %rest.i85 = load ptr, ptr %rest_pointer.i82, align 8
  %promptStack_pointer.i86 = getelementptr i8, ptr %prompt.i84, i64 8
  %promptStack.i87 = load ptr, ptr %promptStack_pointer.i86, align 8
  %isThisStack.i88 = icmp eq ptr %promptStack.i87, %stack.tr.i79
  br i1 %isThisStack.i88, label %clearPrompt.i100, label %free.i89

clearPrompt.i100:                                 ; preds = %tailrecurse.i78
  store ptr null, ptr %promptStack_pointer.i86, align 8
  br label %free.i89

free.i89:                                         ; preds = %clearPrompt.i100, %tailrecurse.i78
  tail call void @free(ptr nonnull %stack.tr.i79)
  %newStackPointer.i.i90 = getelementptr i8, ptr %stackPointer.i83, i64 -24
  %stackEraser.i.i91 = getelementptr i8, ptr %stackPointer.i83, i64 -8
  %eraser.i.i92 = load ptr, ptr %stackEraser.i.i91, align 8
  tail call void %eraser.i.i92(ptr %newStackPointer.i.i90)
  %referenceCount.i.i93 = load i64, ptr %prompt.i84, align 4
  %cond.i.i94 = icmp eq i64 %referenceCount.i.i93, 0
  br i1 %cond.i.i94, label %free.i.i99, label %decrement.i.i95

decrement.i.i95:                                  ; preds = %free.i89
  %newReferenceCount.i.i96 = add i64 %referenceCount.i.i93, -1
  store i64 %newReferenceCount.i.i96, ptr %prompt.i84, align 4
  br label %erasePrompt.exit.i97

free.i.i99:                                       ; preds = %free.i89
  tail call void @free(ptr nonnull %prompt.i84)
  br label %erasePrompt.exit.i97

erasePrompt.exit.i97:                             ; preds = %free.i.i99, %decrement.i.i95
  %isNull.i98 = icmp eq ptr %rest.i85, null
  br i1 %isNull.i98, label %eraseResumption.exit, label %tailrecurse.i78

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i97, %decr.i48
  %stack_474 = extractvalue <{ ptr, ptr }> %pair_473, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_474, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_474, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_475 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_475(%Pos { i64 5, ptr null }, ptr %stack_474)
  ret void

label_479:                                        ; preds = %label_480
  %0 = insertvalue %Pos poison, i64 %v_r_2552_30_194_4420.unpack, 0
  %v_r_2552_30_194_44203 = insertvalue %Pos %0, ptr %v_r_2552_30_194_4420.unpack2, 1
  %z.i = add i64 %index_7_34_198_4430, 1
  %z.i108 = mul i64 %acc_8_35_199_4513, 10
  %z.i109 = sub i64 %z.i108, %tmp_4801
  %z.i110 = add i64 %z.i109, %v_coe_3452_46_73_237_4408.unpack
  musttail call tailcc void @go_6_33_197_4441(i64 %z.i, i64 %z.i110, ptr %p_8_9_4242, i64 %tmp_4801, %Pos %v_r_2552_30_194_44203, ptr nonnull %stack)
  ret void

label_480:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3452_46_73_237_4408.unpack, 58
  br i1 %z.i111, label %label_479, label %label_478

label_481:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_457, i64 16
  %v_coe_3452_46_73_237_4408.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3452_46_73_237_4408.elt4 = getelementptr i8, ptr %fields_457, i64 24
  %v_coe_3452_46_73_237_4408.unpack5 = load ptr, ptr %v_coe_3452_46_73_237_4408.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3452_46_73_237_4408.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_481
  %referenceCount.i.i = load i64, ptr %v_coe_3452_46_73_237_4408.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3452_46_73_237_4408.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_481
  %referenceCount.i11 = load i64, ptr %fields_457, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_457, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_457, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_457)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_3452_46_73_237_4408.unpack, 47
  br i1 %z.i112, label %label_480, label %label_469

label_488:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_457, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_488
  %referenceCount.i = load i64, ptr %fields_457, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_457, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_457, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_457, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_457)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_488, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_2552_30_194_4420.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2552_30_194_4420.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2552_30_194_4420.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2552_30_194_4420.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2552_30_194_4420.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2552_30_194_4420.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_485 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_485(i64 %acc_8_35_199_4513, ptr nonnull %stack)
  ret void
}

define void @sharer_494(ptr %stackPointer) {
entry:
  %v_r_2552_30_194_4420_493.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2552_30_194_4420_493.unpack2 = load ptr, ptr %v_r_2552_30_194_4420_493.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2552_30_194_4420_493.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2552_30_194_4420_493.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2552_30_194_4420_493.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_506(ptr %stackPointer) {
entry:
  %v_r_2552_30_194_4420_505.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2552_30_194_4420_505.unpack2 = load ptr, ptr %v_r_2552_30_194_4420_505.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2552_30_194_4420_505.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2552_30_194_4420_505.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2552_30_194_4420_505.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2552_30_194_4420_505.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2552_30_194_4420_505.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2552_30_194_4420_505.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_523(%Pos %returned_4954, ptr nocapture %stack) {
entry:
  %stackMemory.i = getelementptr i8, ptr %stack, i64 8
  %stackPrompt.i = getelementptr i8, ptr %stack, i64 32
  %stackRest.i = getelementptr i8, ptr %stack, i64 40
  %memory.unpack.i = load ptr, ptr %stackMemory.i, align 8
  %prompt.i = load ptr, ptr %stackPrompt.i, align 8
  %rest.i = load ptr, ptr %stackRest.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  store ptr null, ptr %promptStack_pointer.i, align 8
  tail call void @free(ptr %memory.unpack.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %entry
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %underflowStack.exit

free.i.i:                                         ; preds = %entry
  tail call void @free(ptr nonnull %prompt.i)
  br label %underflowStack.exit

underflowStack.exit:                              ; preds = %decrement.i.i, %free.i.i
  tail call void @free(ptr nonnull %stack)
  %stackPointer_pointer.i = getelementptr i8, ptr %rest.i, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %rest.i, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_525 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_525(%Pos %returned_4954, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_4380_clause_532(ptr %closure, %Pos %exc_8_20_47_211_4317, %Pos %msg_9_21_48_212_4345, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4530 = load ptr, ptr %environment.i5, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %closure, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %closure, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i6 = getelementptr i8, ptr %closure, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i6, align 8
  tail call void %eraser.i(ptr nonnull %environment.i5)
  tail call void @free(ptr nonnull %closure)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %pair_535 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4530)
  %k_11_23_50_214_4567 = extractvalue <{ ptr, ptr }> %pair_535, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_4567, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_4567, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_4567, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i11
  %stack.tr.i = phi ptr [ %stack.i, %free.i11 ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i12

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i12

free.i12:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i12
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i12
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i13 = icmp eq ptr %rest.i, null
  br i1 %isNull.i13, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i9
  %stack_536 = extractvalue <{ ptr, ptr }> %pair_535, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_428, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_4317.elt = extractvalue %Pos %exc_8_20_47_211_4317, 0
  store i64 %exc_8_20_47_211_4317.elt, ptr %environment.i, align 8, !noalias !0
  %environment_538.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_4317.elt2 = extractvalue %Pos %exc_8_20_47_211_4317, 1
  store ptr %exc_8_20_47_211_4317.elt2, ptr %environment_538.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4345_pointer_542 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4345.elt = extractvalue %Pos %msg_9_21_48_212_4345, 0
  store i64 %msg_9_21_48_212_4345.elt, ptr %msg_9_21_48_212_4345_pointer_542, align 8, !noalias !0
  %msg_9_21_48_212_4345_pointer_542.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4345.elt4 = extractvalue %Pos %msg_9_21_48_212_4345, 1
  store ptr %msg_9_21_48_212_4345.elt4, ptr %msg_9_21_48_212_4345_pointer_542.repack3, align 8, !noalias !0
  %make_4955 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_536, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_536, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_544 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_544(%Pos %make_4955, ptr %stack_536)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_551(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_559(ptr nocapture readonly %environment) {
entry:
  %tmp_4803_558.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_4803_558.unpack2 = load ptr, ptr %tmp_4803_558.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_4803_558.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_4803_558.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_4803_558.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_4803_558.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_4803_558.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_4803_558.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_555(i64 %v_coe_3451_6_28_55_219_4319, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_559, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3451_6_28_55_219_4319, ptr %environment.i, align 8, !noalias !0
  %environment_557.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_557.repack1, align 8, !noalias !0
  %make_4957 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_563 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_563(%Pos %make_4957, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_4441(i64 %index_7_34_198_4430, i64 %acc_8_35_199_4513, ptr %p_8_9_4242, i64 %tmp_4801, %Pos %v_r_2552_30_194_4420, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2552_30_194_4420, 1
  %isNull.i.i = icmp eq ptr %object.i3, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %object.i3, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i3, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 72
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %index_7_34_198_4430, ptr %common.ret.op.i, align 4, !noalias !0
  %p_8_9_4242_pointer_515 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_8_9_4242, ptr %p_8_9_4242_pointer_515, align 8, !noalias !0
  %tmp_4801_pointer_516 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_4801, ptr %tmp_4801_pointer_516, align 4, !noalias !0
  %acc_8_35_199_4513_pointer_517 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %acc_8_35_199_4513, ptr %acc_8_35_199_4513_pointer_517, align 4, !noalias !0
  %v_r_2552_30_194_4420_pointer_518 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %v_r_2552_30_194_4420.elt = extractvalue %Pos %v_r_2552_30_194_4420, 0
  store i64 %v_r_2552_30_194_4420.elt, ptr %v_r_2552_30_194_4420_pointer_518, align 8, !noalias !0
  %v_r_2552_30_194_4420_pointer_518.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %object.i3, ptr %v_r_2552_30_194_4420_pointer_518.repack1, align 8, !noalias !0
  %returnAddress_pointer_519 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_520 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_521 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_449, ptr %returnAddress_pointer_519, align 8, !noalias !0
  store ptr @sharer_494, ptr %sharer_pointer_520, align 8, !noalias !0
  store ptr @eraser_506, ptr %eraser_pointer_521, align 8, !noalias !0
  %calloc.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i = getelementptr i8, ptr %stackPointer.i.i, i64 64
  store i64 0, ptr %stack.i, align 8
  %stack.repack1.i = getelementptr inbounds i8, ptr %stack.i, i64 8
  store ptr %stackPointer.i.i, ptr %stack.repack1.i, align 8
  %stack.repack1.repack7.i = getelementptr inbounds i8, ptr %stack.i, i64 16
  store ptr %stackPointer.i.i, ptr %stack.repack1.repack7.i, align 8
  %stack.repack1.repack9.i = getelementptr inbounds i8, ptr %stack.i, i64 24
  store ptr %limit.i.i, ptr %stack.repack1.repack9.i, align 8
  %stack.repack3.i = getelementptr inbounds i8, ptr %stack.i, i64 32
  store ptr %calloc.i.i, ptr %stack.repack3.i, align 8
  %stack.repack5.i = getelementptr inbounds i8, ptr %stack.i, i64 40
  store ptr %stack, ptr %stack.repack5.i, align 8
  %stack_pointer.i = getelementptr i8, ptr %calloc.i.i, i64 8
  store ptr %stack.i, ptr %stack_pointer.i, align 8
  %nextStackPointer.i8 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i9 = icmp ugt ptr %nextStackPointer.i8, %limit.i.i
  br i1 %isInside.not.i9, label %realloc.i12, label %stackAllocate.exit26

realloc.i12:                                      ; preds = %stackAllocate.exit
  %newBase.i22 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i23 = getelementptr i8, ptr %newBase.i22, i64 32
  %newNextStackPointer.i25 = getelementptr i8, ptr %newBase.i22, i64 24
  store ptr %newBase.i22, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i23, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit26

stackAllocate.exit26:                             ; preds = %stackAllocate.exit, %realloc.i12
  %limit.i30 = phi ptr [ %newLimit.i23, %realloc.i12 ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i10 = phi ptr [ %newNextStackPointer.i25, %realloc.i12 ], [ %nextStackPointer.i8, %stackAllocate.exit ]
  %base.i37 = phi ptr [ %newBase.i22, %realloc.i12 ], [ %stackPointer.i.i, %stackAllocate.exit ]
  %sharer_pointer_530 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_531 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_523, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_20, ptr %sharer_pointer_530, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_531, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_551, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %calloc.i.i, ptr %environment.i, align 8, !noalias !0
  %nextStackPointer.i31 = getelementptr i8, ptr %nextStackPointer.sink.i10, i64 24
  %isInside.not.i32 = icmp ugt ptr %nextStackPointer.i31, %limit.i30
  br i1 %isInside.not.i32, label %realloc.i35, label %stackAllocate.exit49

realloc.i35:                                      ; preds = %stackAllocate.exit26
  %intStackPointer.i38 = ptrtoint ptr %nextStackPointer.sink.i10 to i64
  %intBase.i39 = ptrtoint ptr %base.i37 to i64
  %size.i40 = sub i64 %intStackPointer.i38, %intBase.i39
  %nextSize.i41 = add i64 %size.i40, 24
  %leadingZeros.i.i42 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i41, i1 false)
  %numBits.i.i43 = sub nuw nsw i64 64, %leadingZeros.i.i42
  %result.i.i44 = shl nuw i64 1, %numBits.i.i43
  %newBase.i45 = tail call ptr @realloc(ptr nonnull %base.i37, i64 %result.i.i44)
  %newLimit.i46 = getelementptr i8, ptr %newBase.i45, i64 %result.i.i44
  %newStackPointer.i47 = getelementptr i8, ptr %newBase.i45, i64 %size.i40
  %newNextStackPointer.i48 = getelementptr i8, ptr %newStackPointer.i47, i64 24
  store ptr %newBase.i45, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i46, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit49

stackAllocate.exit49:                             ; preds = %stackAllocate.exit26, %realloc.i35
  %nextStackPointer.sink.i33 = phi ptr [ %newNextStackPointer.i48, %realloc.i35 ], [ %nextStackPointer.i31, %stackAllocate.exit26 ]
  %common.ret.op.i34 = phi ptr [ %newStackPointer.i47, %realloc.i35 ], [ %nextStackPointer.sink.i10, %stackAllocate.exit26 ]
  %Exception_7_19_46_210_4380 = insertvalue %Neg { ptr @vtable_547, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_568 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_569 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_555, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_568, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_569, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2552_30_194_4420, i64 %index_7_34_198_4430, %Neg %Exception_7_19_46_210_4380, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_4336_clause_570(ptr %closure, %Pos %exception_10_107_134_298_4958, %Pos %msg_11_108_135_299_4959, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4242 = load ptr, ptr %environment.i, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %closure, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %closure, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %closure, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %closure)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_4958, 1
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i2, label %erasePositive.exit12, label %next.i.i3

next.i.i3:                                        ; preds = %eraseObject.exit
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %cond.i.i5 = icmp eq i64 %referenceCount.i.i4, 0
  br i1 %cond.i.i5, label %free.i.i8, label %decr.i.i6

decr.i.i6:                                        ; preds = %next.i.i3
  %referenceCount.1.i.i7 = add i64 %referenceCount.i.i4, -1
  store i64 %referenceCount.1.i.i7, ptr %object.i1, align 4
  br label %erasePositive.exit12

free.i.i8:                                        ; preds = %next.i.i3
  %objectEraser.i.i9 = getelementptr i8, ptr %object.i1, i64 8
  %eraser.i.i10 = load ptr, ptr %objectEraser.i.i9, align 8
  %environment.i.i.i11 = getelementptr i8, ptr %object.i1, i64 16
  tail call void %eraser.i.i10(ptr %environment.i.i.i11)
  tail call void @free(ptr nonnull %object.i1)
  br label %erasePositive.exit12

erasePositive.exit12:                             ; preds = %eraseObject.exit, %decr.i.i6, %free.i.i8
  %object.i = extractvalue %Pos %msg_11_108_135_299_4959, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit12
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit12, %decr.i.i, %free.i.i
  %pair_573 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4242)
  %k_13_14_4_4784 = extractvalue <{ ptr, ptr }> %pair_573, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_4784, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_4784, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4784, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i17
  %stack.tr.i = phi ptr [ %stack.i, %free.i17 ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i18

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i18

free.i18:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %eraser.i.i19 = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i19(ptr %newStackPointer.i.i)
  %referenceCount.i.i20 = load i64, ptr %prompt.i, align 4
  %cond.i.i21 = icmp eq i64 %referenceCount.i.i20, 0
  br i1 %cond.i.i21, label %free.i.i23, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i18
  %newReferenceCount.i.i = add i64 %referenceCount.i.i20, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i23:                                       ; preds = %free.i18
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i23, %decrement.i.i
  %isNull.i22 = icmp eq ptr %rest.i, null
  br i1 %isNull.i22, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i15
  %stack_574 = extractvalue <{ ptr, ptr }> %pair_573, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_574, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_574, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_575 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_575(%Pos { i64 5, ptr null }, ptr %stack_574)
  ret void
}

define tailcc void @returnAddress_589(i64 %v_coe_3456_22_131_158_322_4402, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3456_22_131_158_322_4402, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_590 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_590(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_601(i64 %v_r_2650_1_9_20_129_156_320_4465, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2650_1_9_20_129_156_320_4465
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_602 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_602(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_584(i64 %v_r_2649_3_14_123_150_314_4332, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i8 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %p_8_9_4242 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_4801_pointer_587 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_4801 = load i64, ptr %tmp_4801_pointer_587, align 4, !noalias !0
  %v_r_2552_30_194_4420_pointer_588 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2552_30_194_4420.unpack = load i64, ptr %v_r_2552_30_194_4420_pointer_588, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2552_30_194_4420.unpack, 0
  %v_r_2552_30_194_4420.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2552_30_194_4420.unpack2 = load ptr, ptr %v_r_2552_30_194_4420.elt1, align 8, !noalias !0
  %v_r_2552_30_194_44203 = insertvalue %Pos %0, ptr %v_r_2552_30_194_4420.unpack2, 1
  %z.i = icmp eq i64 %v_r_2649_3_14_123_150_314_4332, 45
  %isInside.not.i = icmp ugt ptr %v_r_2552_30_194_4420.elt1, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 24
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i12 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i12, i64 24
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i16 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %v_r_2552_30_194_4420.elt1, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_595 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_596 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_589, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_595, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_596, align 8, !noalias !0
  br i1 %z.i, label %label_609, label %label_600

label_600:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_4441(i64 0, i64 0, ptr %p_8_9_4242, i64 %tmp_4801, %Pos %v_r_2552_30_194_44203, ptr nonnull %stack)
  ret void

label_609:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_609
  %base_pointer.i22 = getelementptr i8, ptr %stack, i64 16
  %base.i23 = load ptr, ptr %base_pointer.i22, align 8, !alias.scope !0
  %intStackPointer.i24 = ptrtoint ptr %nextStackPointer.sink.i to i64
  %intBase.i25 = ptrtoint ptr %base.i23 to i64
  %size.i26 = sub i64 %intStackPointer.i24, %intBase.i25
  %nextSize.i27 = add i64 %size.i26, 24
  %leadingZeros.i.i28 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i27, i1 false)
  %numBits.i.i29 = sub nuw nsw i64 64, %leadingZeros.i.i28
  %result.i.i30 = shl nuw i64 1, %numBits.i.i29
  %newBase.i31 = tail call ptr @realloc(ptr %base.i23, i64 %result.i.i30)
  %newLimit.i32 = getelementptr i8, ptr %newBase.i31, i64 %result.i.i30
  %newStackPointer.i33 = getelementptr i8, ptr %newBase.i31, i64 %size.i26
  %newNextStackPointer.i34 = getelementptr i8, ptr %newStackPointer.i33, i64 24
  store ptr %newBase.i31, ptr %base_pointer.i22, align 8, !alias.scope !0
  store ptr %newLimit.i32, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit35

stackAllocate.exit35:                             ; preds = %label_609, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_609 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_609 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_607 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_608 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_601, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_607, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_608, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_4441(i64 1, i64 0, ptr %p_8_9_4242, i64 %tmp_4801, %Pos %v_r_2552_30_194_44203, ptr nonnull %stack)
  ret void
}

define void @sharer_613(ptr %stackPointer) {
entry:
  %v_r_2552_30_194_4420_612.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2552_30_194_4420_612.unpack2 = load ptr, ptr %v_r_2552_30_194_4420_612.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2552_30_194_4420_612.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2552_30_194_4420_612.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2552_30_194_4420_612.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_621(ptr %stackPointer) {
entry:
  %v_r_2552_30_194_4420_620.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2552_30_194_4420_620.unpack2 = load ptr, ptr %v_r_2552_30_194_4420_620.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2552_30_194_4420_620.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2552_30_194_4420_620.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2552_30_194_4420_620.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2552_30_194_4420_620.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2552_30_194_4420_620.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2552_30_194_4420_620.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_446(%Pos %v_r_2552_30_194_4420, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i8 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %p_8_9_4242 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_551, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4242, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2552_30_194_4420, 1
  %isNull.i.i = icmp eq ptr %object.i3, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %object.i3, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i3, align 4
  %currentStackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i11.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %limit.i11 = phi ptr [ %limit.i, %entry ], [ %limit.i11.pre, %next.i.i ]
  %currentStackPointer.i = phi ptr [ %newStackPointer.i, %entry ], [ %currentStackPointer.i.pre, %next.i.i ]
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i11
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 56
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i12 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i12, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %limit.i.i17 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i11, %sharePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4242, ptr %common.ret.op.i, align 8, !noalias !0
  %tmp_4801_pointer_628 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 48, ptr %tmp_4801_pointer_628, align 4, !noalias !0
  %v_r_2552_30_194_4420_pointer_629 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2552_30_194_4420.elt = extractvalue %Pos %v_r_2552_30_194_4420, 0
  store i64 %v_r_2552_30_194_4420.elt, ptr %v_r_2552_30_194_4420_pointer_629, align 8, !noalias !0
  %v_r_2552_30_194_4420_pointer_629.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i3, ptr %v_r_2552_30_194_4420_pointer_629.repack1, align 8, !noalias !0
  %returnAddress_pointer_630 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_631 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_632 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_584, ptr %returnAddress_pointer_630, align 8, !noalias !0
  store ptr @sharer_613, ptr %sharer_pointer_631, align 8, !noalias !0
  store ptr @eraser_621, ptr %eraser_pointer_632, align 8, !noalias !0
  br i1 %isNull.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit
  %referenceCount.i.i.i = load i64, ptr %object.i3, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %object.i3, align 4
  %currentStackPointer.i.i.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit
  %limit.i.i = phi ptr [ %limit.i.i.pre, %next.i.i.i ], [ %limit.i.i17, %stackAllocate.exit ]
  %currentStackPointer.i.i = phi ptr [ %currentStackPointer.i.i.pre, %next.i.i.i ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %sharePositive.exit.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 64
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 64
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %sharePositive.exit.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %sharePositive.exit.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %sharePositive.exit.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_r_2552_30_194_4420.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_727.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_727.repack1.i, align 8, !noalias !0
  %index_2107_pointer_729.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_729.i, align 4, !noalias !0
  %Exception_2362_pointer_730.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_578, ptr %Exception_2362_pointer_730.i, align 8, !noalias !0
  %Exception_2362_pointer_730.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_730.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_731.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_732.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_733.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_693, ptr %returnAddress_pointer_731.i, align 8, !noalias !0
  store ptr @sharer_714, ptr %sharer_pointer_732.i, align 8, !noalias !0
  store ptr @eraser_722, ptr %eraser_pointer_733.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2552_30_194_4420)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_737.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_737.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_634(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_638(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_443(%Pos %v_r_2551_24_188_4350, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i8 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_4242 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4242, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_644 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_645 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_446, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_634, ptr %sharer_pointer_644, align 8, !noalias !0
  store ptr @eraser_638, ptr %eraser_pointer_645, align 8, !noalias !0
  %tag_646 = extractvalue %Pos %v_r_2551_24_188_4350, 0
  switch i64 %tag_646, label %label_648 [
    i64 0, label %label_652
    i64 1, label %label_658
  ]

label_648:                                        ; preds = %stackAllocate.exit
  ret void

label_652:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_4974 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_4974.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_649 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_649(%Pos %utf8StringLiteral_4974, ptr nonnull %stack)
  ret void

label_658:                                        ; preds = %stackAllocate.exit
  %fields_647 = extractvalue %Pos %v_r_2551_24_188_4350, 1
  %environment.i = getelementptr i8, ptr %fields_647, i64 16
  %v_y_3278_8_29_193_4490.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3278_8_29_193_4490.elt1 = getelementptr i8, ptr %fields_647, i64 24
  %v_y_3278_8_29_193_4490.unpack2 = load ptr, ptr %v_y_3278_8_29_193_4490.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3278_8_29_193_4490.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_658
  %referenceCount.i.i = load i64, ptr %v_y_3278_8_29_193_4490.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3278_8_29_193_4490.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_658
  %referenceCount.i = load i64, ptr %fields_647, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_647, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_647, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_647)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3278_8_29_193_4490.unpack, 0
  %v_y_3278_8_29_193_44903 = insertvalue %Pos %0, ptr %v_y_3278_8_29_193_4490.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_655 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655(%Pos %v_y_3278_8_29_193_44903, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_440(%Pos %v_r_2550_13_177_4437, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i13 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_4242 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4242, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_664 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_665 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_443, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_634, ptr %sharer_pointer_664, align 8, !noalias !0
  store ptr @eraser_638, ptr %eraser_pointer_665, align 8, !noalias !0
  %tag_666 = extractvalue %Pos %v_r_2550_13_177_4437, 0
  switch i64 %tag_666, label %label_668 [
    i64 0, label %label_673
    i64 1, label %label_685
  ]

label_668:                                        ; preds = %stackAllocate.exit
  ret void

label_673:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4242, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_446, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_634, ptr %sharer_pointer_664, align 8, !noalias !0
  store ptr @eraser_638, ptr %eraser_pointer_665, align 8, !noalias !0
  %utf8StringLiteral_4974.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_4974.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_649.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_649.i(%Pos %utf8StringLiteral_4974.i, ptr nonnull %stack)
  ret void

label_685:                                        ; preds = %stackAllocate.exit
  %fields_667 = extractvalue %Pos %v_r_2550_13_177_4437, 1
  %environment.i6 = getelementptr i8, ptr %fields_667, i64 16
  %v_y_2787_10_21_185_4313.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_2787_10_21_185_4313.elt1 = getelementptr i8, ptr %fields_667, i64 24
  %v_y_2787_10_21_185_4313.unpack2 = load ptr, ptr %v_y_2787_10_21_185_4313.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2787_10_21_185_4313.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_685
  %referenceCount.i.i = load i64, ptr %v_y_2787_10_21_185_4313.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2787_10_21_185_4313.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_685
  %referenceCount.i = load i64, ptr %fields_667, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_667, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_667, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_667)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_559, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2787_10_21_185_4313.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_678.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2787_10_21_185_4313.unpack2, ptr %environment_678.repack4, align 8, !noalias !0
  %make_4976 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_682 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_682(%Pos %make_4976, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2445(ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 24
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 24
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 24
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_409 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_410 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_409, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_410, align 8, !noalias !0
  %calloc.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i = getelementptr i8, ptr %stackPointer.i.i, i64 64
  store i64 0, ptr %stack.i, align 8
  %stack.repack1.i = getelementptr inbounds i8, ptr %stack.i, i64 8
  %stack.repack1.repack7.i = getelementptr inbounds i8, ptr %stack.i, i64 16
  store ptr %stackPointer.i.i, ptr %stack.repack1.repack7.i, align 8
  %stack.repack1.repack9.i = getelementptr inbounds i8, ptr %stack.i, i64 24
  store ptr %limit.i.i, ptr %stack.repack1.repack9.i, align 8
  %stack.repack3.i = getelementptr inbounds i8, ptr %stack.i, i64 32
  store ptr %calloc.i.i, ptr %stack.repack3.i, align 8
  %stack.repack5.i = getelementptr inbounds i8, ptr %stack.i, i64 40
  store ptr %stack, ptr %stack.repack5.i, align 8
  %stack_pointer.i = getelementptr i8, ptr %calloc.i.i, i64 8
  store ptr %stack.i, ptr %stack_pointer.i, align 8
  %nextStackPointer.i5 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i6 = icmp ugt ptr %nextStackPointer.i5, %limit.i.i
  br i1 %isInside.not.i6, label %realloc.i9, label %stackAllocate.exit23

realloc.i9:                                       ; preds = %stackAllocate.exit
  %newBase.i19 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i20 = getelementptr i8, ptr %newBase.i19, i64 32
  %newNextStackPointer.i22 = getelementptr i8, ptr %newBase.i19, i64 24
  store ptr %newBase.i19, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i20, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit23

stackAllocate.exit23:                             ; preds = %stackAllocate.exit, %realloc.i9
  %nextStackPointer.sink.i7 = phi ptr [ %newNextStackPointer.i22, %realloc.i9 ], [ %nextStackPointer.i5, %stackAllocate.exit ]
  %common.ret.op.i8 = phi ptr [ %newBase.i19, %realloc.i9 ], [ %stackPointer.i.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i7, ptr %stack.repack1.i, align 8
  %sharer_pointer_419 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_420 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_412, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_20, ptr %sharer_pointer_419, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_420, align 8, !noalias !0
  %c.i = tail call i64 @c_get_argc()
  %z.i = add i64 %c.i, -1
  %currentStackPointer.i26 = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  %nextStackPointer.i28 = getelementptr i8, ptr %currentStackPointer.i26, i64 32
  %isInside.not.i29 = icmp ugt ptr %nextStackPointer.i28, %limit.i27
  br i1 %isInside.not.i29, label %realloc.i32, label %stackAllocate.exit46

realloc.i32:                                      ; preds = %stackAllocate.exit23
  %base.i34 = load ptr, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  %intStackPointer.i35 = ptrtoint ptr %currentStackPointer.i26 to i64
  %intBase.i36 = ptrtoint ptr %base.i34 to i64
  %size.i37 = sub i64 %intStackPointer.i35, %intBase.i36
  %nextSize.i38 = add i64 %size.i37, 32
  %leadingZeros.i.i39 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i38, i1 false)
  %numBits.i.i40 = sub nuw nsw i64 64, %leadingZeros.i.i39
  %result.i.i41 = shl nuw i64 1, %numBits.i.i40
  %newBase.i42 = tail call ptr @realloc(ptr %base.i34, i64 %result.i.i41)
  %newLimit.i43 = getelementptr i8, ptr %newBase.i42, i64 %result.i.i41
  %newStackPointer.i44 = getelementptr i8, ptr %newBase.i42, i64 %size.i37
  %newNextStackPointer.i45 = getelementptr i8, ptr %newStackPointer.i44, i64 32
  store ptr %newBase.i42, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i43, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit46

stackAllocate.exit46:                             ; preds = %stackAllocate.exit23, %realloc.i32
  %limit.i.i4851 = phi ptr [ %newLimit.i43, %realloc.i32 ], [ %limit.i27, %stackAllocate.exit23 ]
  %nextStackPointer.sink.i30 = phi ptr [ %newNextStackPointer.i45, %realloc.i32 ], [ %nextStackPointer.i28, %stackAllocate.exit23 ]
  %common.ret.op.i31 = phi ptr [ %newStackPointer.i44, %realloc.i32 ], [ %currentStackPointer.i26, %stackAllocate.exit23 ]
  store ptr %nextStackPointer.sink.i30, ptr %stack.repack1.i, align 8
  store ptr %calloc.i.i, ptr %common.ret.op.i31, align 8, !noalias !0
  %returnAddress_pointer_690 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_691 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_692 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_440, ptr %returnAddress_pointer_690, align 8, !noalias !0
  store ptr @sharer_634, ptr %sharer_pointer_691, align 8, !noalias !0
  store ptr @eraser_638, ptr %eraser_pointer_692, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_438.i, label %label_434.i

label_434.i:                                      ; preds = %stackAllocate.exit46, %label_434.i
  %acc_3_3_5_169_4445.tr8.i = phi %Pos [ %make_4929.i, %label_434.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4370.tr7.i = phi i64 [ %z.i5.i, %label_434.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4370.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4370.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_428, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_4926.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_4926.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_425.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_4926.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_4926.elt2.i, ptr %environment_425.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_4445_pointer_432.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_4445.elt.i = extractvalue %Pos %acc_3_3_5_169_4445.tr8.i, 0
  store i64 %acc_3_3_5_169_4445.elt.i, ptr %acc_3_3_5_169_4445_pointer_432.i, align 8, !noalias !0
  %acc_3_3_5_169_4445_pointer_432.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_4445.elt4.i = extractvalue %Pos %acc_3_3_5_169_4445.tr8.i, 1
  store ptr %acc_3_3_5_169_4445.elt4.i, ptr %acc_3_3_5_169_4445_pointer_432.repack3.i, align 8, !noalias !0
  %make_4929.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4370.tr7.i, 2
  br i1 %z.i.i, label %label_438.i.loopexit, label %label_434.i

label_438.i.loopexit:                             ; preds = %label_434.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_438.i

label_438.i:                                      ; preds = %label_438.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_438.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_438.i.loopexit ]
  %acc_3_3_5_169_4445.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_4929.i, %label_438.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_435.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_435.i(%Pos %acc_3_3_5_169_4445.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_693(%Pos %v_r_2718_3508, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i11 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i11)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %str_2106.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %str_2106.unpack, 0
  %str_2106.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %str_2106.unpack2 = load ptr, ptr %str_2106.elt1, align 8, !noalias !0
  %str_21063 = insertvalue %Pos %0, ptr %str_2106.unpack2, 1
  %index_2107_pointer_696 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_696, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_698 = extractvalue %Pos %v_r_2718_3508, 0
  switch i64 %tag_698, label %label_700 [
    i64 0, label %label_704
    i64 1, label %label_710
  ]

label_700:                                        ; preds = %entry
  ret void

label_704:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_704
  %referenceCount.i.i = load i64, ptr %Exception_2362.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %Exception_2362.unpack5, align 4
  br label %eraseNegative.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %Exception_2362.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %Exception_2362.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %Exception_2362.unpack5)
  br label %eraseNegative.exit

eraseNegative.exit:                               ; preds = %label_704, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_701 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_701(i64 %x.i, ptr nonnull %stack)
  ret void

label_710:                                        ; preds = %entry
  %Exception_2362_pointer_697 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_697, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_4857 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_4857.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_4857, %Pos %z.i)
  %utf8StringLiteral_4859 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_4859.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_4859)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_4862 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_4862.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_4862)
  %functionPointer_709 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_709(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_714(ptr %stackPointer) {
entry:
  %str_2106_711.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_711.unpack2 = load ptr, ptr %str_2106_711.elt1, align 8, !noalias !0
  %Exception_2362_713.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_713.unpack5 = load ptr, ptr %Exception_2362_713.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_711.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_711.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_711.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_713.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_713.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_713.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_722(ptr %stackPointer) {
entry:
  %str_2106_719.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_719.unpack2 = load ptr, ptr %str_2106_719.elt1, align 8, !noalias !0
  %Exception_2362_721.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_721.unpack5 = load ptr, ptr %Exception_2362_721.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_719.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_719.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_719.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_719.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_719.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_719.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_721.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_721.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_721.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_721.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_721.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_721.unpack5)
  br label %eraseNegative.exit

eraseNegative.exit:                               ; preds = %erasePositive.exit, %decr.i.i11, %free.i.i13
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @charAt_2108(%Pos %str_2106, i64 %index_2107, %Neg %Exception_2362, ptr %stack) local_unnamed_addr {
entry:
  %object.i = extractvalue %Pos %str_2106, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 64
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 64
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 64
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %str_2106.elt = extractvalue %Pos %str_2106, 0
  store i64 %str_2106.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_727.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_727.repack1, align 8, !noalias !0
  %index_2107_pointer_729 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_729, align 4, !noalias !0
  %Exception_2362_pointer_730 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_730, align 8, !noalias !0
  %Exception_2362_pointer_730.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_730.repack3, align 8, !noalias !0
  %returnAddress_pointer_731 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_732 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_733 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_693, ptr %returnAddress_pointer_731, align 8, !noalias !0
  store ptr @sharer_714, ptr %sharer_pointer_732, align 8, !noalias !0
  store ptr @eraser_722, ptr %eraser_pointer_733, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_740, label %label_745

label_740:                                        ; preds = %stackAllocate.exit
  %x.i = tail call i64 @c_bytearray_size(%Pos %str_2106)
  %z.i10 = icmp sle i64 %x.i, %index_2107
  %fat_z.i11 = zext i1 %z.i10 to i64
  %adt_boolean.i12 = insertvalue %Pos zeroinitializer, i64 %fat_z.i11, 0
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i16 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i16, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_737 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_737(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_745:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_745
  %referenceCount.i.i8 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i8, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i7
  %referenceCount.1.i.i9 = add i64 %referenceCount.i.i8, -1
  store i64 %referenceCount.1.i.i9, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i7
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_745, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_742 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_742(%Pos { i64 1, ptr null }, ptr nonnull %stack)
  ret void
}

define void @effektMain() local_unnamed_addr {
transition:
  %calloc.i.i.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i.i.i = getelementptr i8, ptr %stackPointer.i.i.i.i, i64 64
  store i64 0, ptr %stack.i.i.i, align 8
  %stack.repack1.i.i.i = getelementptr inbounds i8, ptr %stack.i.i.i, i64 8
  %stack.repack1.repack7.i.i.i = getelementptr inbounds i8, ptr %stack.i.i.i, i64 16
  store ptr %stackPointer.i.i.i.i, ptr %stack.repack1.repack7.i.i.i, align 8
  %stack.repack1.repack9.i.i.i = getelementptr inbounds i8, ptr %stack.i.i.i, i64 24
  store ptr %limit.i.i.i.i, ptr %stack.repack1.repack9.i.i.i, align 8
  %stack.repack3.i.i.i = getelementptr inbounds i8, ptr %stack.i.i.i, i64 32
  store ptr %calloc.i.i.i.i, ptr %stack.repack3.i.i.i, align 8
  %stack.repack5.i.i.i = getelementptr inbounds i8, ptr %stack.i.i.i, i64 40
  store ptr null, ptr %stack.repack5.i.i.i, align 8
  %stack_pointer.i.i.i = getelementptr i8, ptr %calloc.i.i.i.i, i64 8
  store ptr %stack.i.i.i, ptr %stack_pointer.i.i.i, align 8
  %sharerPointer.0.i.i = getelementptr i8, ptr %stackPointer.i.i.i.i, i64 8
  %eraserPointer.0.i.i = getelementptr i8, ptr %stackPointer.i.i.i.i, i64 16
  store ptr @nop, ptr %stackPointer.i.i.i.i, align 8
  store ptr @nop, ptr %sharerPointer.0.i.i, align 8
  store ptr @free, ptr %eraserPointer.0.i.i, align 8
  %globalsStackPointer_2.i.i = getelementptr i8, ptr %stackPointer.i.i.i.i, i64 24
  store ptr %globalsStackPointer_2.i.i, ptr %stack.repack1.i.i.i, align 8
  %calloc.i.i1.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i2.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i3.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i4.i.i = getelementptr i8, ptr %stackPointer.i.i3.i.i, i64 64
  store i64 0, ptr %stack.i2.i.i, align 8
  %stack.repack1.i5.i.i = getelementptr inbounds i8, ptr %stack.i2.i.i, i64 8
  %stack.repack1.repack7.i6.i.i = getelementptr inbounds i8, ptr %stack.i2.i.i, i64 16
  store ptr %stackPointer.i.i3.i.i, ptr %stack.repack1.repack7.i6.i.i, align 8
  %stack.repack1.repack9.i7.i.i = getelementptr inbounds i8, ptr %stack.i2.i.i, i64 24
  store ptr %limit.i.i4.i.i, ptr %stack.repack1.repack9.i7.i.i, align 8
  %stack.repack3.i8.i.i = getelementptr inbounds i8, ptr %stack.i2.i.i, i64 32
  store ptr %calloc.i.i1.i.i, ptr %stack.repack3.i8.i.i, align 8
  %stack.repack5.i9.i.i = getelementptr inbounds i8, ptr %stack.i2.i.i, i64 40
  store ptr %stack.i.i.i, ptr %stack.repack5.i9.i.i, align 8
  %stack_pointer.i10.i.i = getelementptr i8, ptr %calloc.i.i1.i.i, i64 8
  store ptr %stack.i2.i.i, ptr %stack_pointer.i10.i.i, align 8
  %sharerPointer.i.i = getelementptr i8, ptr %stackPointer.i.i3.i.i, i64 8
  %eraserPointer.i.i = getelementptr i8, ptr %stackPointer.i.i3.i.i, i64 16
  store ptr @topLevel, ptr %stackPointer.i.i3.i.i, align 8
  store ptr @topLevelSharer, ptr %sharerPointer.i.i, align 8
  store ptr @topLevelEraser, ptr %eraserPointer.i.i, align 8
  %stackPointer_2.i.i = getelementptr i8, ptr %stackPointer.i.i3.i.i, i64 24
  store ptr %stackPointer_2.i.i, ptr %stack.repack1.i5.i.i, align 8
  tail call tailcc void @main_2445(ptr nonnull %stack.i2.i.i)
  ret void
}

define tailcc void @effektMainTailcc() local_unnamed_addr {
entry:
  %calloc.i.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 64
  store i64 0, ptr %stack.i.i, align 8
  %stack.repack1.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 8
  %stack.repack1.repack7.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 16
  store ptr %stackPointer.i.i.i, ptr %stack.repack1.repack7.i.i, align 8
  %stack.repack1.repack9.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 24
  store ptr %limit.i.i.i, ptr %stack.repack1.repack9.i.i, align 8
  %stack.repack3.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 32
  store ptr %calloc.i.i.i, ptr %stack.repack3.i.i, align 8
  %stack.repack5.i.i = getelementptr inbounds i8, ptr %stack.i.i, i64 40
  store ptr null, ptr %stack.repack5.i.i, align 8
  %stack_pointer.i.i = getelementptr i8, ptr %calloc.i.i.i, i64 8
  store ptr %stack.i.i, ptr %stack_pointer.i.i, align 8
  %sharerPointer.0.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 8
  %eraserPointer.0.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 16
  store ptr @nop, ptr %stackPointer.i.i.i, align 8
  store ptr @nop, ptr %sharerPointer.0.i, align 8
  store ptr @free, ptr %eraserPointer.0.i, align 8
  %globalsStackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i.i, i64 24
  store ptr %globalsStackPointer_2.i, ptr %stack.repack1.i.i, align 8
  %calloc.i.i1.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i2.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i3.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i4.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 64
  store i64 0, ptr %stack.i2.i, align 8
  %stack.repack1.i5.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 8
  %stack.repack1.repack7.i6.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 16
  store ptr %stackPointer.i.i3.i, ptr %stack.repack1.repack7.i6.i, align 8
  %stack.repack1.repack9.i7.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 24
  store ptr %limit.i.i4.i, ptr %stack.repack1.repack9.i7.i, align 8
  %stack.repack3.i8.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 32
  store ptr %calloc.i.i1.i, ptr %stack.repack3.i8.i, align 8
  %stack.repack5.i9.i = getelementptr inbounds i8, ptr %stack.i2.i, i64 40
  store ptr %stack.i.i, ptr %stack.repack5.i9.i, align 8
  %stack_pointer.i10.i = getelementptr i8, ptr %calloc.i.i1.i, i64 8
  store ptr %stack.i2.i, ptr %stack_pointer.i10.i, align 8
  %sharerPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 8
  %eraserPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 16
  store ptr @topLevel, ptr %stackPointer.i.i3.i, align 8
  store ptr @topLevelSharer, ptr %sharerPointer.i, align 8
  store ptr @topLevelEraser, ptr %eraserPointer.i, align 8
  %stackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 24
  store ptr %stackPointer_2.i, ptr %stack.repack1.i5.i, align 8
  musttail call tailcc void @main_2445(ptr nonnull %stack.i2.i)
  ret void
}

; Function Attrs: nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @calloc(i64 noundef, i64 noundef) local_unnamed_addr #12

attributes #0 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" }
attributes #1 = { mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" }
attributes #2 = { mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" }
attributes #3 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #5 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) }
attributes #6 = { alwaysinline mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) }
attributes #7 = { alwaysinline }
attributes #8 = { mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none) }
attributes #9 = { alwaysinline mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) }
attributes #10 = { mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite) }
attributes #11 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read, inaccessiblemem: write) }
attributes #12 = { nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" }

!0 = !{!1}
!1 = !{!"stackValues", !2}
!2 = !{!"types"}
