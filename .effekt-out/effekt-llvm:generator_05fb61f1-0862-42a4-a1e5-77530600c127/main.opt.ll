; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:generator_05fb61f1-0862-42a4-a1e5-77530600c127/main.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:generator_05fb61f1-0862-42a4-a1e5-77530600c127/main.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_60 = private constant [1 x ptr] [ptr @blockLit_4916_clause_55]
@vtable_313 = private constant [1 x ptr] [ptr @blockLit_4930_clause_305]
@vtable_561 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4423_clause_546]
@vtable_590 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4455_clause_582]
@utf8StringLiteral_4988.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_4893.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_4895.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_4898.lit = private constant [1 x i8] c"'"

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

define tailcc void @returnAddress_2(%Pos %v_coe_3507_124_4700, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3507_124_4700, 0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %unboxed.i)
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

define tailcc void @returnAddress_15(%Pos %returned_4912, ptr nocapture %stack) {
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
  musttail call tailcc void %returnAddress_17(%Pos %returned_4912, ptr %rest.i)
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

define tailcc void @returnAddress_34(%Pos %returnValue_35, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_4869.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4869.unpack2 = load ptr, ptr %tmp_4869.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_4869.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_4869.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_4869.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_4869.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_4869.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_4869.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_38 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_38(%Pos %returnValue_35, ptr nonnull %stack)
  ret void
}

define void @sharer_42(ptr %stackPointer) {
entry:
  %tmp_4869_41.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_4869_41.unpack2 = load ptr, ptr %tmp_4869_41.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_4869_41.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_4869_41.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_4869_41.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_46(ptr %stackPointer) {
entry:
  %tmp_4869_45.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_4869_45.unpack2 = load ptr, ptr %tmp_4869_45.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_4869_45.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_4869_45.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_4869_45.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_4869_45.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_4869_45.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_4869_45.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @blockLit_4916_clause_55(ptr nocapture readnone %closure, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_57 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_57(%Pos zeroinitializer, ptr %stack)
  ret void
}

define tailcc void @returnAddress_64(%Pos %returnValue_65, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_4870.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4870.unpack2 = load ptr, ptr %tmp_4870.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_4870.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_4870.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_4870.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_4870.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_4870.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_4870.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_68 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_68(%Pos %returnValue_65, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_103(%Pos %__2_2_120_4761, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %acc_101_4685 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_4875_pointer_106 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_4875 = load i64, ptr %tmp_4875_pointer_106, align 4, !noalias !0
  %v_7_42_4693_pointer_107 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_7_42_4693.unpack = load ptr, ptr %v_7_42_4693_pointer_107, align 8, !noalias !0
  %v_7_42_4693.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_7_42_4693.unpack2 = load i64, ptr %v_7_42_4693.elt1, align 8, !noalias !0
  %cont_10_45_4721_pointer_108 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %cont_10_45_4721.unpack = load ptr, ptr %cont_10_45_4721_pointer_108, align 8, !noalias !0
  %cont_10_45_4721.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %cont_10_45_4721.unpack5 = load i64, ptr %cont_10_45_4721.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__2_2_120_4761, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
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

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %z.i = add i64 %tmp_4875, %acc_101_4685
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %erasePositive.exit
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %erasePositive.exit
  %limit.i1520.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %erasePositive.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %erasePositive.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %z.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %v_7_42_4693_pointer_193.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store ptr %v_7_42_4693.unpack, ptr %v_7_42_4693_pointer_193.i, align 8, !noalias !0
  %v_7_42_4693_pointer_193.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %v_7_42_4693.unpack2, ptr %v_7_42_4693_pointer_193.repack1.i, align 8, !noalias !0
  %cont_10_45_4721_pointer_194.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %cont_10_45_4721.unpack, ptr %cont_10_45_4721_pointer_194.i, align 8, !noalias !0
  %cont_10_45_4721_pointer_194.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %cont_10_45_4721.unpack5, ptr %cont_10_45_4721_pointer_194.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_195.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_196.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_197.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_83, ptr %returnAddress_pointer_195.i, align 8, !noalias !0
  store ptr @sharer_178, ptr %sharer_pointer_196.i, align 8, !noalias !0
  store ptr @eraser_186, ptr %eraser_pointer_197.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %v_7_42_4693.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i11.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i12.i = load ptr, ptr %base_pointer.i11.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i12.i, i64 %v_7_42_4693.unpack2
  %v_7_42_4693_old_199.elt5.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %v_7_42_4693_old_199.unpack6.i = load ptr, ptr %v_7_42_4693_old_199.elt5.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %v_7_42_4693_old_199.unpack6.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %v_7_42_4693_old_199.unpack6.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %v_7_42_4693_old_199.unpack6.i, align 4
  %get_4923.unpack9.pre.i = load ptr, ptr %v_7_42_4693_old_199.elt5.i, align 8, !noalias !0
  %stackPointer.i.pre.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.pre.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i15.i = phi ptr [ %limit.i1520.i, %stackAllocate.exit.i ], [ %limit.i15.pre.i, %next.i.i.i ]
  %stackPointer.i.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i.pre.i, %next.i.i.i ]
  %get_4923.unpack9.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_4923.unpack9.pre.i, %next.i.i.i ]
  %get_4923.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_4923.unpack.i, 0
  %get_492310.i = insertvalue %Pos %0, ptr %get_4923.unpack9.i, 1
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_200.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_200.i(%Pos %get_492310.i, ptr nonnull %stack)
  ret void
}

define void @sharer_113(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_123(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_97(%Pos %v_r_2558_26_1_118_4686, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i15 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i15)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  %cont_10_45_4721.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %cont_10_45_4721.unpack5 = load i64, ptr %cont_10_45_4721.elt4, align 8, !noalias !0
  %cont_10_45_4721_pointer_102 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %cont_10_45_4721.unpack = load ptr, ptr %cont_10_45_4721_pointer_102, align 8, !noalias !0
  %tmp_4875_pointer_101 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_4875 = load i64, ptr %tmp_4875_pointer_101, align 4, !noalias !0
  %v_7_42_4693.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_7_42_4693.unpack2 = load i64, ptr %v_7_42_4693.elt1, align 8, !noalias !0
  %v_7_42_4693_pointer_100 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_7_42_4693.unpack = load ptr, ptr %v_7_42_4693_pointer_100, align 8, !noalias !0
  %acc_101_4685 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tag.i = extractvalue %Pos %v_r_2558_26_1_118_4686, 0
  %vtable.i = inttoptr i64 %tag.i to ptr
  %heap_obj.i = extractvalue %Pos %v_r_2558_26_1_118_4686, 1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %acc_101_4685, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_4875_pointer_131 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store i64 %tmp_4875, ptr %tmp_4875_pointer_131, align 4, !noalias !0
  %v_7_42_4693_pointer_132 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %v_7_42_4693.unpack, ptr %v_7_42_4693_pointer_132, align 8, !noalias !0
  %v_7_42_4693_pointer_132.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %v_7_42_4693.unpack2, ptr %v_7_42_4693_pointer_132.repack7, align 8, !noalias !0
  %cont_10_45_4721_pointer_133 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %cont_10_45_4721.unpack, ptr %cont_10_45_4721_pointer_133, align 8, !noalias !0
  %cont_10_45_4721_pointer_133.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %cont_10_45_4721.unpack5, ptr %cont_10_45_4721_pointer_133.repack9, align 8, !noalias !0
  %sharer_pointer_135 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_136 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_103, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_113, ptr %sharer_pointer_135, align 8, !noalias !0
  store ptr @eraser_123, ptr %eraser_pointer_136, align 8, !noalias !0
  %functionPointer_140 = load ptr, ptr %vtable.i, align 8, !noalias !0
  musttail call tailcc void %functionPointer_140(ptr %heap_obj.i, ptr nonnull %stack)
  ret void
}

define void @sharer_145(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_155(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_83(%Pos %v_r_2575_102_4672, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i29 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i29)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %acc_101_4685 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tag_88 = extractvalue %Pos %v_r_2575_102_4672, 0
  switch i64 %tag_88, label %label_90 [
    i64 0, label %label_94
    i64 1, label %label_174
  ]

label_90:                                         ; preds = %entry
  ret void

label_94:                                         ; preds = %entry
  %isInside.i34 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i34)
  %newStackPointer.i35 = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i35, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_91 = load ptr, ptr %newStackPointer.i35, align 8, !noalias !0
  musttail call tailcc void %returnAddress_91(i64 %acc_101_4685, ptr nonnull %stack)
  ret void

label_174:                                        ; preds = %entry
  %fields_89 = extractvalue %Pos %v_r_2575_102_4672, 1
  %cont_10_45_4721_pointer_87 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %cont_10_45_4721.unpack = load ptr, ptr %cont_10_45_4721_pointer_87, align 8, !noalias !0
  %cont_10_45_4721.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %cont_10_45_4721.unpack5 = load i64, ptr %cont_10_45_4721.elt4, align 8, !noalias !0
  %v_7_42_4693_pointer_86 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_7_42_4693.unpack = load ptr, ptr %v_7_42_4693_pointer_86, align 8, !noalias !0
  %v_7_42_4693.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_7_42_4693.unpack2 = load i64, ptr %v_7_42_4693.elt1, align 8, !noalias !0
  %environment.i = getelementptr i8, ptr %fields_89, i64 16
  %v_coe_3504_110_4684.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_coe_3504_110_4684.elt7 = getelementptr i8, ptr %fields_89, i64 24
  %v_coe_3504_110_4684.unpack8 = load ptr, ptr %v_coe_3504_110_4684.elt7, align 8, !noalias !0
  %isNull.i.i20 = icmp eq ptr %v_coe_3504_110_4684.unpack8, null
  br i1 %isNull.i.i20, label %next.i, label %next.i.i21

next.i.i21:                                       ; preds = %label_174
  %referenceCount.i.i22 = load i64, ptr %v_coe_3504_110_4684.unpack8, align 4
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, 1
  store i64 %referenceCount.1.i.i23, ptr %v_coe_3504_110_4684.unpack8, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i21, %label_174
  %referenceCount.i = load i64, ptr %fields_89, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_89, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_89, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_89)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i38
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit
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
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit, %realloc.i
  %limit.i4551 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i38, %eraseObject.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %acc_101_4685, ptr %common.ret.op.i, align 4, !noalias !0
  %v_7_42_4693_pointer_163 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %v_7_42_4693.unpack, ptr %v_7_42_4693_pointer_163, align 8, !noalias !0
  %v_7_42_4693_pointer_163.repack10 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %v_7_42_4693.unpack2, ptr %v_7_42_4693_pointer_163.repack10, align 8, !noalias !0
  %tmp_4875_pointer_164 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %v_coe_3504_110_4684.unpack, ptr %tmp_4875_pointer_164, align 4, !noalias !0
  %cont_10_45_4721_pointer_165 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %cont_10_45_4721.unpack, ptr %cont_10_45_4721_pointer_165, align 8, !noalias !0
  %cont_10_45_4721_pointer_165.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %cont_10_45_4721.unpack5, ptr %cont_10_45_4721_pointer_165.repack12, align 8, !noalias !0
  %returnAddress_pointer_166 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_167 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_168 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_97, ptr %returnAddress_pointer_166, align 8, !noalias !0
  store ptr @sharer_145, ptr %sharer_pointer_167, align 8, !noalias !0
  store ptr @eraser_155, ptr %eraser_pointer_168, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %cont_10_45_4721.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %cont_10_45_4721.unpack5
  %cont_10_45_4721_old_170.elt14 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %cont_10_45_4721_old_170.unpack15 = load ptr, ptr %cont_10_45_4721_old_170.elt14, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %cont_10_45_4721_old_170.unpack15, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %cont_10_45_4721_old_170.unpack15, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %cont_10_45_4721_old_170.unpack15, align 4
  %get_4922.unpack18.pre = load ptr, ptr %cont_10_45_4721_old_170.elt14, align 8, !noalias !0
  %stackPointer.i43.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i45.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i45 = phi ptr [ %limit.i4551, %stackAllocate.exit ], [ %limit.i45.pre, %next.i.i ]
  %stackPointer.i43 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i43.pre, %next.i.i ]
  %get_4922.unpack18 = phi ptr [ null, %stackAllocate.exit ], [ %get_4922.unpack18.pre, %next.i.i ]
  %get_4922.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_4922.unpack, 0
  %get_492219 = insertvalue %Pos %0, ptr %get_4922.unpack18, 1
  %isInside.i46 = icmp ule ptr %stackPointer.i43, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %stackPointer.i43, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_171 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_171(%Pos %get_492219, ptr nonnull %stack)
  ret void
}

define void @sharer_178(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_186(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @consumer_100_4669(i64 %acc_101_4685, %Reference %v_7_42_4693, %Reference %cont_10_45_4721, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 64
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
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

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i1520 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %acc_101_4685, ptr %common.ret.op.i, align 4, !noalias !0
  %v_7_42_4693_pointer_193 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_7_42_4693.elt = extractvalue %Reference %v_7_42_4693, 0
  store ptr %v_7_42_4693.elt, ptr %v_7_42_4693_pointer_193, align 8, !noalias !0
  %v_7_42_4693_pointer_193.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_7_42_4693.elt2 = extractvalue %Reference %v_7_42_4693, 1
  store i64 %v_7_42_4693.elt2, ptr %v_7_42_4693_pointer_193.repack1, align 8, !noalias !0
  %cont_10_45_4721_pointer_194 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %cont_10_45_4721.elt = extractvalue %Reference %cont_10_45_4721, 0
  store ptr %cont_10_45_4721.elt, ptr %cont_10_45_4721_pointer_194, align 8, !noalias !0
  %cont_10_45_4721_pointer_194.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %cont_10_45_4721.elt4 = extractvalue %Reference %cont_10_45_4721, 1
  store i64 %cont_10_45_4721.elt4, ptr %cont_10_45_4721_pointer_194.repack3, align 8, !noalias !0
  %returnAddress_pointer_195 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_196 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_197 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_83, ptr %returnAddress_pointer_195, align 8, !noalias !0
  store ptr @sharer_178, ptr %sharer_pointer_196, align 8, !noalias !0
  store ptr @eraser_186, ptr %eraser_pointer_197, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %v_7_42_4693.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i11 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i12 = load ptr, ptr %base_pointer.i11, align 8
  %varPointer.i = getelementptr i8, ptr %base.i12, i64 %v_7_42_4693.elt2
  %v_7_42_4693_old_199.elt5 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %v_7_42_4693_old_199.unpack6 = load ptr, ptr %v_7_42_4693_old_199.elt5, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_7_42_4693_old_199.unpack6, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %v_7_42_4693_old_199.unpack6, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_7_42_4693_old_199.unpack6, align 4
  %get_4923.unpack9.pre = load ptr, ptr %v_7_42_4693_old_199.elt5, align 8, !noalias !0
  %stackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i15 = phi ptr [ %limit.i1520, %stackAllocate.exit ], [ %limit.i15.pre, %next.i.i ]
  %stackPointer.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i.pre, %next.i.i ]
  %get_4923.unpack9 = phi ptr [ null, %stackAllocate.exit ], [ %get_4923.unpack9.pre, %next.i.i ]
  %get_4923.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_4923.unpack, 0
  %get_492310 = insertvalue %Pos %0, ptr %get_4923.unpack9, 1
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i16 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i16, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_200 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_200(%Pos %get_492310, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_203(i64 %v_coe_3506_122_4676, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3506_122_4676, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_204 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_204(%Pos %boxed2.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_79(%Pos %__25_90_4756, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_7_42_4693.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %v_7_42_4693.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_7_42_4693.unpack2 = load i64, ptr %v_7_42_4693.elt1, align 8, !noalias !0
  %cont_10_45_4721_pointer_82 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %cont_10_45_4721.unpack = load ptr, ptr %cont_10_45_4721_pointer_82, align 8, !noalias !0
  %cont_10_45_4721.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %cont_10_45_4721.unpack5 = load i64, ptr %cont_10_45_4721.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__25_90_4756, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
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

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i14 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 24
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i14
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
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
  %newStackPointer.i15 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i15, i64 24
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i14, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i15, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_209 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_210 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_203, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_209, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_210, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i to i64
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit
  %limit.i1520.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 0, ptr %common.ret.op.i.i, align 4, !noalias !0
  %v_7_42_4693_pointer_193.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store ptr %v_7_42_4693.unpack, ptr %v_7_42_4693_pointer_193.i, align 8, !noalias !0
  %v_7_42_4693_pointer_193.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %v_7_42_4693.unpack2, ptr %v_7_42_4693_pointer_193.repack1.i, align 8, !noalias !0
  %cont_10_45_4721_pointer_194.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %cont_10_45_4721.unpack, ptr %cont_10_45_4721_pointer_194.i, align 8, !noalias !0
  %cont_10_45_4721_pointer_194.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %cont_10_45_4721.unpack5, ptr %cont_10_45_4721_pointer_194.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_195.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_196.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_197.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_83, ptr %returnAddress_pointer_195.i, align 8, !noalias !0
  store ptr @sharer_178, ptr %sharer_pointer_196.i, align 8, !noalias !0
  store ptr @eraser_186, ptr %eraser_pointer_197.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %v_7_42_4693.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i11.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i12.i = load ptr, ptr %base_pointer.i11.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i12.i, i64 %v_7_42_4693.unpack2
  %v_7_42_4693_old_199.elt5.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %v_7_42_4693_old_199.unpack6.i = load ptr, ptr %v_7_42_4693_old_199.elt5.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %v_7_42_4693_old_199.unpack6.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %v_7_42_4693_old_199.unpack6.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %v_7_42_4693_old_199.unpack6.i, align 4
  %get_4923.unpack9.pre.i = load ptr, ptr %v_7_42_4693_old_199.elt5.i, align 8, !noalias !0
  %stackPointer.i.pre.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.pre.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i15.i = phi ptr [ %limit.i1520.i, %stackAllocate.exit.i ], [ %limit.i15.pre.i, %next.i.i.i ]
  %stackPointer.i.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i.pre.i, %next.i.i.i ]
  %get_4923.unpack9.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_4923.unpack9.pre.i, %next.i.i.i ]
  %get_4923.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_4923.unpack.i, 0
  %get_492310.i = insertvalue %Pos %0, ptr %get_4923.unpack9.i, 1
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_200.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_200.i(%Pos %get_492310.i, ptr nonnull %stack)
  ret void
}

define void @sharer_213(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_219(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_230(%Pos %returned_4926, ptr nocapture %stack) {
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
  %returnAddress_232 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_232(%Pos %returned_4926, ptr %rest.i)
  ret void
}

define tailcc void @returnAddress_258(%Pos %__5_17_16_87_4754, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i14 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i14)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_y_2568_15_14_77_4690.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_y_2568_15_14_77_4690.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %v_y_2568_15_14_77_4690.unpack2 = load ptr, ptr %v_y_2568_15_14_77_4690.elt1, align 8, !noalias !0
  %v_7_42_4693_pointer_261 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_7_42_4693.unpack = load ptr, ptr %v_7_42_4693_pointer_261, align 8, !noalias !0
  %v_7_42_4693.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_7_42_4693.unpack5 = load i64, ptr %v_7_42_4693.elt4, align 8, !noalias !0
  %p_12_47_4709_pointer_262 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %p_12_47_4709 = load ptr, ptr %p_12_47_4709_pointer_262, align 8, !noalias !0
  %cont_10_45_4721_pointer_263 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %cont_10_45_4721.unpack = load ptr, ptr %cont_10_45_4721_pointer_263, align 8, !noalias !0
  %cont_10_45_4721.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %cont_10_45_4721.unpack8 = load i64, ptr %cont_10_45_4721.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__5_17_16_87_4754, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
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

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %0 = insertvalue %Reference poison, ptr %cont_10_45_4721.unpack, 0
  %cont_10_45_47219 = insertvalue %Reference %0, i64 %cont_10_45_4721.unpack8, 1
  %1 = insertvalue %Reference poison, ptr %v_7_42_4693.unpack, 0
  %v_7_42_46936 = insertvalue %Reference %1, i64 %v_7_42_4693.unpack5, 1
  %2 = insertvalue %Pos poison, i64 %v_y_2568_15_14_77_4690.unpack, 0
  %v_y_2568_15_14_77_46903 = insertvalue %Pos %2, ptr %v_y_2568_15_14_77_4690.unpack2, 1
  musttail call tailcc void @iterate_worker_4_3_58_4667(%Pos %v_y_2568_15_14_77_46903, %Reference %v_7_42_46936, ptr %p_12_47_4709, %Reference %cont_10_45_47219, ptr nonnull %stack)
  ret void
}

define void @sharer_268(ptr %stackPointer) {
entry:
  %v_y_2568_15_14_77_4690_264.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %v_y_2568_15_14_77_4690_264.unpack2 = load ptr, ptr %v_y_2568_15_14_77_4690_264.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2568_15_14_77_4690_264.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_y_2568_15_14_77_4690_264.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2568_15_14_77_4690_264.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_278(ptr %stackPointer) {
entry:
  %v_y_2568_15_14_77_4690_274.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %v_y_2568_15_14_77_4690_274.unpack2 = load ptr, ptr %v_y_2568_15_14_77_4690_274.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2568_15_14_77_4690_274.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_y_2568_15_14_77_4690_274.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_y_2568_15_14_77_4690_274.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_y_2568_15_14_77_4690_274.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_y_2568_15_14_77_4690_274.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_y_2568_15_14_77_4690_274.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_297(ptr nocapture readonly %environment) {
entry:
  %tmp_4871_296.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_4871_296.unpack2 = load ptr, ptr %tmp_4871_296.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_4871_296.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_4871_296.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_4871_296.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_4871_296.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_4871_296.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_4871_296.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @blockLit_4930_clause_305(ptr %closure, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %k_16_3_80_4712 = load ptr, ptr %environment.i, align 8, !noalias !0
  %referenceCount.i1 = load i64, ptr %k_16_3_80_4712, align 4
  %referenceCount.1.i2 = add i64 %referenceCount.i1, 1
  store i64 %referenceCount.1.i2, ptr %k_16_3_80_4712, align 4
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
  %stack_308 = tail call fastcc ptr @resume(ptr nonnull %k_16_3_80_4712, ptr %stack)
  %stackPointer_pointer.i = getelementptr i8, ptr %stack_308, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_308, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_310 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_310(%Pos zeroinitializer, ptr %stack_308)
  ret void
}

define void @eraser_317(ptr nocapture readonly %environment) {
entry:
  %k_16_3_80_4712_316 = load ptr, ptr %environment, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %k_16_3_80_4712_316, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %entry
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_16_3_80_4712_316, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %entry
  %stack_pointer.i = getelementptr i8, ptr %k_16_3_80_4712_316, i64 40
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
  ret void
}

define tailcc void @returnAddress_301(%Pos %__21_8_85_4753, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i26 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i26)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %k_16_3_80_4712 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %cont_10_45_4721_pointer_304 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %cont_10_45_4721.unpack = load ptr, ptr %cont_10_45_4721_pointer_304, align 8, !noalias !0
  %cont_10_45_4721.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %cont_10_45_4721.unpack2 = load i64, ptr %cont_10_45_4721.elt1, align 8, !noalias !0
  %object.i10 = extractvalue %Pos %__21_8_85_4753, 1
  %isNull.i.i11 = icmp eq ptr %object.i10, null
  br i1 %isNull.i.i11, label %erasePositive.exit21, label %next.i.i12

next.i.i12:                                       ; preds = %entry
  %referenceCount.i.i13 = load i64, ptr %object.i10, align 4
  %cond.i.i14 = icmp eq i64 %referenceCount.i.i13, 0
  br i1 %cond.i.i14, label %free.i.i17, label %decr.i.i15

decr.i.i15:                                       ; preds = %next.i.i12
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i13, -1
  store i64 %referenceCount.1.i.i16, ptr %object.i10, align 4
  br label %erasePositive.exit21

free.i.i17:                                       ; preds = %next.i.i12
  %objectEraser.i.i18 = getelementptr i8, ptr %object.i10, i64 8
  %eraser.i.i19 = load ptr, ptr %objectEraser.i.i18, align 8
  %environment.i.i.i20 = getelementptr i8, ptr %object.i10, i64 16
  tail call void %eraser.i.i19(ptr %environment.i.i.i20)
  tail call void @free(ptr nonnull %object.i10)
  br label %erasePositive.exit21

erasePositive.exit21:                             ; preds = %entry, %decr.i.i15, %free.i.i17
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_317, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %k_16_3_80_4712, ptr %environment.i, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %cont_10_45_4721.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %cont_10_45_4721.unpack2
  %cont_10_45_4721_old_322.elt4 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %cont_10_45_4721_old_322.unpack5 = load ptr, ptr %cont_10_45_4721_old_322.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %cont_10_45_4721_old_322.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit21
  %referenceCount.i.i = load i64, ptr %cont_10_45_4721_old_322.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %cont_10_45_4721_old_322.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %cont_10_45_4721_old_322.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %cont_10_45_4721_old_322.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %cont_10_45_4721_old_322.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit21, %decr.i.i, %free.i.i
  store i64 ptrtoint (ptr @vtable_313 to i64), ptr %varPointer.i, align 8, !noalias !0
  store ptr %object.i, ptr %cont_10_45_4721_old_322.elt4, align 8, !noalias !0
  %stackPointer.i28 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i30 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i31 = icmp ule ptr %stackPointer.i28, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %stackPointer.i28, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_324 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_324(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_329(ptr %stackPointer) {
entry:
  %stackPointer_330 = getelementptr i8, ptr %stackPointer, i64 -24
  %k_16_3_80_4712_327 = load ptr, ptr %stackPointer_330, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %k_16_3_80_4712_327, align 4
  %referenceCount.1.i = add i64 %referenceCount.i, 1
  store i64 %referenceCount.1.i, ptr %k_16_3_80_4712_327, align 4
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_335(ptr %stackPointer) {
entry:
  %stackPointer_336 = getelementptr i8, ptr %stackPointer, i64 -24
  %k_16_3_80_4712_333 = load ptr, ptr %stackPointer_336, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %k_16_3_80_4712_333, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %entry
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_16_3_80_4712_333, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %entry
  %stack_pointer.i = getelementptr i8, ptr %k_16_3_80_4712_333, i64 40
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -32
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_251(%Pos %__4_16_15_78_4752, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i42 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i42)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_y_2567_14_13_76_4679 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %p_12_47_4709_pointer_254 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %p_12_47_4709 = load ptr, ptr %p_12_47_4709_pointer_254, align 8, !noalias !0
  %cont_10_45_4721_pointer_255 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %cont_10_45_4721.unpack = load ptr, ptr %cont_10_45_4721_pointer_255, align 8, !noalias !0
  %cont_10_45_4721.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %cont_10_45_4721.unpack2 = load i64, ptr %cont_10_45_4721.elt1, align 8, !noalias !0
  %v_y_2568_15_14_77_4690_pointer_256 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_y_2568_15_14_77_4690.unpack = load i64, ptr %v_y_2568_15_14_77_4690_pointer_256, align 8, !noalias !0
  %v_y_2568_15_14_77_4690.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_y_2568_15_14_77_4690.unpack5 = load ptr, ptr %v_y_2568_15_14_77_4690.elt4, align 8, !noalias !0
  %v_7_42_4693_pointer_257 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_7_42_4693.unpack = load ptr, ptr %v_7_42_4693_pointer_257, align 8, !noalias !0
  %v_7_42_4693.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_7_42_4693.unpack8 = load i64, ptr %v_7_42_4693.elt7, align 8, !noalias !0
  %object.i26 = extractvalue %Pos %__4_16_15_78_4752, 1
  %isNull.i.i27 = icmp eq ptr %object.i26, null
  br i1 %isNull.i.i27, label %erasePositive.exit37, label %next.i.i28

next.i.i28:                                       ; preds = %entry
  %referenceCount.i.i29 = load i64, ptr %object.i26, align 4
  %cond.i.i30 = icmp eq i64 %referenceCount.i.i29, 0
  br i1 %cond.i.i30, label %free.i.i33, label %decr.i.i31

decr.i.i31:                                       ; preds = %next.i.i28
  %referenceCount.1.i.i32 = add i64 %referenceCount.i.i29, -1
  store i64 %referenceCount.1.i.i32, ptr %object.i26, align 4
  br label %erasePositive.exit37

free.i.i33:                                       ; preds = %next.i.i28
  %objectEraser.i.i34 = getelementptr i8, ptr %object.i26, i64 8
  %eraser.i.i35 = load ptr, ptr %objectEraser.i.i34, align 8
  %environment.i.i.i36 = getelementptr i8, ptr %object.i26, i64 16
  tail call void %eraser.i.i35(ptr %environment.i.i.i36)
  tail call void @free(ptr nonnull %object.i26)
  br label %erasePositive.exit37

erasePositive.exit37:                             ; preds = %entry, %decr.i.i31, %free.i.i33
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i45 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 80
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i45
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit37
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 80
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i46 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i46, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit37, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit37 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i46, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit37 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_y_2568_15_14_77_4690.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_284.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %v_y_2568_15_14_77_4690.unpack5, ptr %stackPointer_284.repack10, align 8, !noalias !0
  %v_7_42_4693_pointer_286 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %v_7_42_4693.unpack, ptr %v_7_42_4693_pointer_286, align 8, !noalias !0
  %v_7_42_4693_pointer_286.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %v_7_42_4693.unpack8, ptr %v_7_42_4693_pointer_286.repack12, align 8, !noalias !0
  %p_12_47_4709_pointer_287 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_12_47_4709, ptr %p_12_47_4709_pointer_287, align 8, !noalias !0
  %cont_10_45_4721_pointer_288 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %cont_10_45_4721.unpack, ptr %cont_10_45_4721_pointer_288, align 8, !noalias !0
  %cont_10_45_4721_pointer_288.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %cont_10_45_4721.unpack2, ptr %cont_10_45_4721_pointer_288.repack14, align 8, !noalias !0
  %returnAddress_pointer_289 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_290 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_291 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_258, ptr %returnAddress_pointer_289, align 8, !noalias !0
  store ptr @sharer_268, ptr %sharer_pointer_290, align 8, !noalias !0
  store ptr @eraser_278, ptr %eraser_pointer_291, align 8, !noalias !0
  %pair_292 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_12_47_4709)
  %k_16_3_80_4712 = extractvalue <{ ptr, ptr }> %pair_292, 0
  %stack_293 = extractvalue <{ ptr, ptr }> %pair_292, 1
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_297, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2567_14_13_76_4679, ptr %environment.i, align 8, !noalias !0
  %environment_295.repack16 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_295.repack16, align 8, !noalias !0
  %stackPointer_pointer.i47 = getelementptr i8, ptr %stack_293, i64 8
  %limit_pointer.i48 = getelementptr i8, ptr %stack_293, i64 24
  %currentStackPointer.i49 = load ptr, ptr %stackPointer_pointer.i47, align 8, !alias.scope !0
  %limit.i50 = load ptr, ptr %limit_pointer.i48, align 8, !alias.scope !0
  %nextStackPointer.i51 = getelementptr i8, ptr %currentStackPointer.i49, i64 48
  %isInside.not.i52 = icmp ugt ptr %nextStackPointer.i51, %limit.i50
  br i1 %isInside.not.i52, label %realloc.i55, label %stackAllocate.exit69

realloc.i55:                                      ; preds = %stackAllocate.exit
  %base_pointer.i56 = getelementptr i8, ptr %stack_293, i64 16
  %base.i57 = load ptr, ptr %base_pointer.i56, align 8, !alias.scope !0
  %intStackPointer.i58 = ptrtoint ptr %currentStackPointer.i49 to i64
  %intBase.i59 = ptrtoint ptr %base.i57 to i64
  %size.i60 = sub i64 %intStackPointer.i58, %intBase.i59
  %nextSize.i61 = add i64 %size.i60, 48
  %leadingZeros.i.i62 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i61, i1 false)
  %numBits.i.i63 = sub nuw nsw i64 64, %leadingZeros.i.i62
  %result.i.i64 = shl nuw i64 1, %numBits.i.i63
  %newBase.i65 = tail call ptr @realloc(ptr %base.i57, i64 %result.i.i64)
  %newLimit.i66 = getelementptr i8, ptr %newBase.i65, i64 %result.i.i64
  %newStackPointer.i67 = getelementptr i8, ptr %newBase.i65, i64 %size.i60
  %newNextStackPointer.i68 = getelementptr i8, ptr %newStackPointer.i67, i64 48
  store ptr %newBase.i65, ptr %base_pointer.i56, align 8, !alias.scope !0
  store ptr %newLimit.i66, ptr %limit_pointer.i48, align 8, !alias.scope !0
  br label %stackAllocate.exit69

stackAllocate.exit69:                             ; preds = %stackAllocate.exit, %realloc.i55
  %nextStackPointer.sink.i53 = phi ptr [ %newNextStackPointer.i68, %realloc.i55 ], [ %nextStackPointer.i51, %stackAllocate.exit ]
  %common.ret.op.i54 = phi ptr [ %newStackPointer.i67, %realloc.i55 ], [ %currentStackPointer.i49, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i53, ptr %stackPointer_pointer.i47, align 8
  store ptr %k_16_3_80_4712, ptr %common.ret.op.i54, align 8, !noalias !0
  %cont_10_45_4721_pointer_341 = getelementptr i8, ptr %common.ret.op.i54, i64 8
  store ptr %cont_10_45_4721.unpack, ptr %cont_10_45_4721_pointer_341, align 8, !noalias !0
  %cont_10_45_4721_pointer_341.repack18 = getelementptr i8, ptr %common.ret.op.i54, i64 16
  store i64 %cont_10_45_4721.unpack2, ptr %cont_10_45_4721_pointer_341.repack18, align 8, !noalias !0
  %returnAddress_pointer_342 = getelementptr i8, ptr %common.ret.op.i54, i64 24
  %sharer_pointer_343 = getelementptr i8, ptr %common.ret.op.i54, i64 32
  %eraser_pointer_344 = getelementptr i8, ptr %common.ret.op.i54, i64 40
  store ptr @returnAddress_301, ptr %returnAddress_pointer_342, align 8, !noalias !0
  store ptr @sharer_329, ptr %sharer_pointer_343, align 8, !noalias !0
  store ptr @eraser_335, ptr %eraser_pointer_344, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %v_7_42_4693.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i70 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i71 = load ptr, ptr %base_pointer.i70, align 8
  %varPointer.i = getelementptr i8, ptr %base.i71, i64 %v_7_42_4693.unpack8
  %v_7_42_4693_old_346.elt20 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %v_7_42_4693_old_346.unpack21 = load ptr, ptr %v_7_42_4693_old_346.elt20, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_7_42_4693_old_346.unpack21, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit69
  %referenceCount.i.i = load i64, ptr %v_7_42_4693_old_346.unpack21, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_7_42_4693_old_346.unpack21, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_7_42_4693_old_346.unpack21, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_7_42_4693_old_346.unpack21, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_7_42_4693_old_346.unpack21)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %stackAllocate.exit69, %decr.i.i, %free.i.i
  store i64 1, ptr %varPointer.i, align 8, !noalias !0
  store ptr %object.i, ptr %v_7_42_4693_old_346.elt20, align 8, !noalias !0
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i47, align 8, !alias.scope !0
  %limit.i75 = load ptr, ptr %limit_pointer.i48, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i47, align 8, !alias.scope !0
  %returnAddress_348 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_348(%Pos zeroinitializer, ptr nonnull %stack_293)
  ret void
}

define void @sharer_356(ptr %stackPointer) {
entry:
  %v_y_2568_15_14_77_4690_354.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_y_2568_15_14_77_4690_354.unpack2 = load ptr, ptr %v_y_2568_15_14_77_4690_354.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2568_15_14_77_4690_354.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_y_2568_15_14_77_4690_354.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2568_15_14_77_4690_354.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_368(ptr %stackPointer) {
entry:
  %v_y_2568_15_14_77_4690_366.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_y_2568_15_14_77_4690_366.unpack2 = load ptr, ptr %v_y_2568_15_14_77_4690_366.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2568_15_14_77_4690_366.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_y_2568_15_14_77_4690_366.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_y_2568_15_14_77_4690_366.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_y_2568_15_14_77_4690_366.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_y_2568_15_14_77_4690_366.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_y_2568_15_14_77_4690_366.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @iterate_worker_4_3_58_4667(%Pos %tree_5_4_59_4654, %Reference %v_7_42_4693, ptr %p_12_47_4709, %Reference %cont_10_45_4721, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i18 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i19 = getelementptr i8, ptr %stack, i64 24
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %cont_10_45_4721.elt = extractvalue %Reference %cont_10_45_4721, 0
  %cont_10_45_4721.elt8 = extractvalue %Reference %cont_10_45_4721, 1
  %v_7_42_4693.elt = extractvalue %Reference %v_7_42_4693, 0
  %v_7_42_4693.elt12 = extractvalue %Reference %v_7_42_4693, 1
  br label %tailrecurse

tailrecurse:                                      ; preds = %stackAllocate.exit, %entry
  %tree_5_4_59_4654.tr = phi %Pos [ %tree_5_4_59_4654, %entry ], [ %v_y_2566_13_12_75_47313, %stackAllocate.exit ]
  %tag_239 = extractvalue %Pos %tree_5_4_59_4654.tr, 0
  switch i64 %tag_239, label %label_241 [
    i64 0, label %label_246
    i64 1, label %label_384
  ]

label_241:                                        ; preds = %tailrecurse
  ret void

label_246:                                        ; preds = %tailrecurse
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i18, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i19, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i18, align 8, !alias.scope !0
  %returnAddress_243 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_243(%Pos zeroinitializer, ptr %stack)
  ret void

label_384:                                        ; preds = %tailrecurse
  %fields_240 = extractvalue %Pos %tree_5_4_59_4654.tr, 1
  %environment.i = getelementptr i8, ptr %fields_240, i64 16
  %v_y_2566_13_12_75_4731.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_2566_13_12_75_4731.elt1 = getelementptr i8, ptr %fields_240, i64 24
  %v_y_2566_13_12_75_4731.unpack2 = load ptr, ptr %v_y_2566_13_12_75_4731.elt1, align 8, !noalias !0
  %v_y_2567_14_13_76_4679_pointer_249 = getelementptr i8, ptr %fields_240, i64 32
  %v_y_2567_14_13_76_4679 = load i64, ptr %v_y_2567_14_13_76_4679_pointer_249, align 4, !noalias !0
  %v_y_2568_15_14_77_4690_pointer_250 = getelementptr i8, ptr %fields_240, i64 40
  %v_y_2568_15_14_77_4690.unpack = load i64, ptr %v_y_2568_15_14_77_4690_pointer_250, align 8, !noalias !0
  %v_y_2568_15_14_77_4690.elt4 = getelementptr i8, ptr %fields_240, i64 48
  %v_y_2568_15_14_77_4690.unpack5 = load ptr, ptr %v_y_2568_15_14_77_4690.elt4, align 8, !noalias !0
  %isNull.i.i13 = icmp eq ptr %v_y_2566_13_12_75_4731.unpack2, null
  br i1 %isNull.i.i13, label %sharePositive.exit17, label %next.i.i14

next.i.i14:                                       ; preds = %label_384
  %referenceCount.i.i15 = load i64, ptr %v_y_2566_13_12_75_4731.unpack2, align 4
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i15, 1
  store i64 %referenceCount.1.i.i16, ptr %v_y_2566_13_12_75_4731.unpack2, align 4
  br label %sharePositive.exit17

sharePositive.exit17:                             ; preds = %label_384, %next.i.i14
  %isNull.i.i = icmp eq ptr %v_y_2568_15_14_77_4690.unpack5, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_y_2568_15_14_77_4690.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2568_15_14_77_4690.unpack5, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %sharePositive.exit17
  %referenceCount.i = load i64, ptr %fields_240, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_240, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_240, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_240)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i18, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i19, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i20
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 88
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i21 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i21, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i19, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i21, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit ]
  %0 = insertvalue %Pos poison, i64 %v_y_2566_13_12_75_4731.unpack, 0
  %v_y_2566_13_12_75_47313 = insertvalue %Pos %0, ptr %v_y_2566_13_12_75_4731.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i18, align 8
  store i64 %v_y_2567_14_13_76_4679, ptr %common.ret.op.i, align 4, !noalias !0
  %p_12_47_4709_pointer_377 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_12_47_4709, ptr %p_12_47_4709_pointer_377, align 8, !noalias !0
  %cont_10_45_4721_pointer_378 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %cont_10_45_4721.elt, ptr %cont_10_45_4721_pointer_378, align 8, !noalias !0
  %cont_10_45_4721_pointer_378.repack7 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %cont_10_45_4721.elt8, ptr %cont_10_45_4721_pointer_378.repack7, align 8, !noalias !0
  %v_y_2568_15_14_77_4690_pointer_379 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %v_y_2568_15_14_77_4690.unpack, ptr %v_y_2568_15_14_77_4690_pointer_379, align 8, !noalias !0
  %v_y_2568_15_14_77_4690_pointer_379.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %v_y_2568_15_14_77_4690.unpack5, ptr %v_y_2568_15_14_77_4690_pointer_379.repack9, align 8, !noalias !0
  %v_7_42_4693_pointer_380 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %v_7_42_4693.elt, ptr %v_7_42_4693_pointer_380, align 8, !noalias !0
  %v_7_42_4693_pointer_380.repack11 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %v_7_42_4693.elt12, ptr %v_7_42_4693_pointer_380.repack11, align 8, !noalias !0
  %returnAddress_pointer_381 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_382 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_383 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_251, ptr %returnAddress_pointer_381, align 8, !noalias !0
  store ptr @sharer_356, ptr %sharer_pointer_382, align 8, !noalias !0
  store ptr @eraser_368, ptr %eraser_pointer_383, align 8, !noalias !0
  br label %tailrecurse
}

define tailcc void @returnAddress_385(%Pos %__23_88_4755, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i23 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_7_42_4693.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %v_7_42_4693.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_7_42_4693.unpack2 = load i64, ptr %v_7_42_4693.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__23_88_4755, 1
  %isNull.i.i8 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i8, label %erasePositive.exit18, label %next.i.i9

next.i.i9:                                        ; preds = %entry
  %referenceCount.i.i10 = load i64, ptr %object.i, align 4
  %cond.i.i11 = icmp eq i64 %referenceCount.i.i10, 0
  br i1 %cond.i.i11, label %free.i.i14, label %decr.i.i12

decr.i.i12:                                       ; preds = %next.i.i9
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i10, -1
  store i64 %referenceCount.1.i.i13, ptr %object.i, align 4
  br label %erasePositive.exit18

free.i.i14:                                       ; preds = %next.i.i9
  %objectEraser.i.i15 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i16 = load ptr, ptr %objectEraser.i.i15, align 8
  %environment.i.i.i17 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i16(ptr %environment.i.i.i17)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit18

erasePositive.exit18:                             ; preds = %entry, %decr.i.i12, %free.i.i14
  %stack_pointer.i.i = getelementptr i8, ptr %v_7_42_4693.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %v_7_42_4693.unpack2
  %v_7_42_4693_old_390.elt4 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %v_7_42_4693_old_390.unpack5 = load ptr, ptr %v_7_42_4693_old_390.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_7_42_4693_old_390.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit18
  %referenceCount.i.i = load i64, ptr %v_7_42_4693_old_390.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_7_42_4693_old_390.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_7_42_4693_old_390.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_7_42_4693_old_390.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_7_42_4693_old_390.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit18, %decr.i.i, %free.i.i
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %varPointer.i, i8 0, i64 16, i1 false)
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_392 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_392(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_396(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_400(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_28(%Pos %tree_4_4688, ptr %stack) {
entry:
  %stackPointer_pointer.i21 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i22 = load ptr, ptr %stackPointer_pointer.i21, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i22, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i27 = icmp ule ptr %stackPointer.i22, %limit.i
  tail call void @llvm.assume(i1 %isInside.i27)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i22, i64 -8
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i21, align 8, !alias.scope !0
  %r_3_4645 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %pair_32 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %r_3_4645)
  %temporaryStack_4914 = extractvalue <{ ptr, ptr }> %pair_32, 0
  %stack_33 = extractvalue <{ ptr, ptr }> %pair_32, 1
  %stackPointer_pointer.i11 = getelementptr i8, ptr %stack_33, i64 8
  %base_pointer.i12 = getelementptr i8, ptr %stack_33, i64 16
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i11, align 8
  %base.i14 = load ptr, ptr %base_pointer.i12, align 8
  %intStack.i15 = ptrtoint ptr %stackPointer.i13 to i64
  %intBase.i16 = ptrtoint ptr %base.i14 to i64
  %offset.i17 = sub i64 %intStack.i15, %intBase.i16
  %prompt_pointer.i = getelementptr i8, ptr %stack_33, i64 32
  %prompt.i28 = load ptr, ptr %prompt_pointer.i, align 8
  %limit_pointer.i30 = getelementptr i8, ptr %stack_33, i64 24
  %limit.i31 = load ptr, ptr %limit_pointer.i30, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i13, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i31
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %nextSize.i = add i64 %offset.i17, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i14, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i35 = getelementptr i8, ptr %newBase.i, i64 %offset.i17
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i35, i64 40
  store ptr %newBase.i, ptr %base_pointer.i12, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i30, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i35, %realloc.i ], [ %stackPointer.i13, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i11, align 8
  %returnAddress_pointer_51 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_52 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_53 = getelementptr i8, ptr %common.ret.op.i, i64 32
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %common.ret.op.i, i8 0, i64 16, i1 false)
  store ptr @returnAddress_34, ptr %returnAddress_pointer_51, align 8, !noalias !0
  store ptr @sharer_42, ptr %sharer_pointer_52, align 8, !noalias !0
  store ptr @eraser_46, ptr %eraser_pointer_53, align 8, !noalias !0
  %stack_54 = tail call fastcc ptr @resume(ptr %temporaryStack_4914, ptr nonnull %stack_33)
  %pair_62 = tail call <{ ptr, ptr }> @shift(ptr %stack_54, ptr %r_3_4645)
  %temporaryStack_4919 = extractvalue <{ ptr, ptr }> %pair_62, 0
  %stack_63 = extractvalue <{ ptr, ptr }> %pair_62, 1
  %stackPointer_pointer.i = getelementptr i8, ptr %stack_63, i64 8
  %base_pointer.i = getelementptr i8, ptr %stack_63, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i36 = getelementptr i8, ptr %stack_63, i64 32
  %prompt.i37 = load ptr, ptr %prompt_pointer.i36, align 8
  %limit_pointer.i39 = getelementptr i8, ptr %stack_63, i64 24
  %limit.i41 = load ptr, ptr %limit_pointer.i39, align 8, !alias.scope !0
  %nextStackPointer.i42 = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i43 = icmp ugt ptr %nextStackPointer.i42, %limit.i41
  br i1 %isInside.not.i43, label %realloc.i46, label %stackAllocate.exit60

realloc.i46:                                      ; preds = %stackAllocate.exit
  %nextSize.i52 = add i64 %offset.i, 40
  %leadingZeros.i.i53 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i52, i1 false)
  %numBits.i.i54 = sub nuw nsw i64 64, %leadingZeros.i.i53
  %result.i.i55 = shl nuw i64 1, %numBits.i.i54
  %newBase.i56 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i55)
  %newLimit.i57 = getelementptr i8, ptr %newBase.i56, i64 %result.i.i55
  %newStackPointer.i58 = getelementptr i8, ptr %newBase.i56, i64 %offset.i
  %newNextStackPointer.i59 = getelementptr i8, ptr %newStackPointer.i58, i64 40
  store ptr %newBase.i56, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i57, ptr %limit_pointer.i39, align 8, !alias.scope !0
  br label %stackAllocate.exit60

stackAllocate.exit60:                             ; preds = %stackAllocate.exit, %realloc.i46
  %nextStackPointer.sink.i44 = phi ptr [ %newNextStackPointer.i59, %realloc.i46 ], [ %nextStackPointer.i42, %stackAllocate.exit ]
  %common.ret.op.i45 = phi ptr [ %newStackPointer.i58, %realloc.i46 ], [ %stackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i44, ptr %stackPointer_pointer.i, align 8
  store i64 ptrtoint (ptr @vtable_60 to i64), ptr %common.ret.op.i45, align 8, !noalias !0
  %stackPointer_73.repack2 = getelementptr inbounds i8, ptr %common.ret.op.i45, i64 8
  store ptr null, ptr %stackPointer_73.repack2, align 8, !noalias !0
  %returnAddress_pointer_75 = getelementptr i8, ptr %common.ret.op.i45, i64 16
  %sharer_pointer_76 = getelementptr i8, ptr %common.ret.op.i45, i64 24
  %eraser_pointer_77 = getelementptr i8, ptr %common.ret.op.i45, i64 32
  store ptr @returnAddress_64, ptr %returnAddress_pointer_75, align 8, !noalias !0
  store ptr @sharer_42, ptr %sharer_pointer_76, align 8, !noalias !0
  store ptr @eraser_46, ptr %eraser_pointer_77, align 8, !noalias !0
  %stack_78 = tail call fastcc ptr @resume(ptr %temporaryStack_4919, ptr nonnull %stack_63)
  %stackPointer_pointer.i61 = getelementptr i8, ptr %stack_78, i64 8
  %limit_pointer.i62 = getelementptr i8, ptr %stack_78, i64 24
  %currentStackPointer.i63 = load ptr, ptr %stackPointer_pointer.i61, align 8, !alias.scope !0
  %limit.i64 = load ptr, ptr %limit_pointer.i62, align 8, !alias.scope !0
  %nextStackPointer.i65 = getelementptr i8, ptr %currentStackPointer.i63, i64 56
  %isInside.not.i66 = icmp ugt ptr %nextStackPointer.i65, %limit.i64
  br i1 %isInside.not.i66, label %realloc.i69, label %stackAllocate.exit83

realloc.i69:                                      ; preds = %stackAllocate.exit60
  %base_pointer.i70 = getelementptr i8, ptr %stack_78, i64 16
  %base.i71 = load ptr, ptr %base_pointer.i70, align 8, !alias.scope !0
  %intStackPointer.i72 = ptrtoint ptr %currentStackPointer.i63 to i64
  %intBase.i73 = ptrtoint ptr %base.i71 to i64
  %size.i74 = sub i64 %intStackPointer.i72, %intBase.i73
  %nextSize.i75 = add i64 %size.i74, 56
  %leadingZeros.i.i76 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i75, i1 false)
  %numBits.i.i77 = sub nuw nsw i64 64, %leadingZeros.i.i76
  %result.i.i78 = shl nuw i64 1, %numBits.i.i77
  %newBase.i79 = tail call ptr @realloc(ptr %base.i71, i64 %result.i.i78)
  %newLimit.i80 = getelementptr i8, ptr %newBase.i79, i64 %result.i.i78
  %newStackPointer.i81 = getelementptr i8, ptr %newBase.i79, i64 %size.i74
  %newNextStackPointer.i82 = getelementptr i8, ptr %newStackPointer.i81, i64 56
  store ptr %newBase.i79, ptr %base_pointer.i70, align 8, !alias.scope !0
  store ptr %newLimit.i80, ptr %limit_pointer.i62, align 8, !alias.scope !0
  br label %stackAllocate.exit83

stackAllocate.exit83:                             ; preds = %stackAllocate.exit60, %realloc.i69
  %nextStackPointer.sink.i67 = phi ptr [ %newNextStackPointer.i82, %realloc.i69 ], [ %nextStackPointer.i65, %stackAllocate.exit60 ]
  %common.ret.op.i68 = phi ptr [ %newStackPointer.i81, %realloc.i69 ], [ %currentStackPointer.i63, %stackAllocate.exit60 ]
  store ptr %nextStackPointer.sink.i67, ptr %stackPointer_pointer.i61, align 8
  store ptr %prompt.i28, ptr %common.ret.op.i68, align 8, !noalias !0
  %stackPointer_223.repack4 = getelementptr inbounds i8, ptr %common.ret.op.i68, i64 8
  store i64 %offset.i17, ptr %stackPointer_223.repack4, align 8, !noalias !0
  %cont_10_45_4721_pointer_225 = getelementptr i8, ptr %common.ret.op.i68, i64 16
  store ptr %prompt.i37, ptr %cont_10_45_4721_pointer_225, align 8, !noalias !0
  %cont_10_45_4721_pointer_225.repack6 = getelementptr i8, ptr %common.ret.op.i68, i64 24
  store i64 %offset.i, ptr %cont_10_45_4721_pointer_225.repack6, align 8, !noalias !0
  %returnAddress_pointer_226 = getelementptr i8, ptr %common.ret.op.i68, i64 32
  %sharer_pointer_227 = getelementptr i8, ptr %common.ret.op.i68, i64 40
  %eraser_pointer_228 = getelementptr i8, ptr %common.ret.op.i68, i64 48
  store ptr @returnAddress_79, ptr %returnAddress_pointer_226, align 8, !noalias !0
  store ptr @sharer_213, ptr %sharer_pointer_227, align 8, !noalias !0
  store ptr @eraser_219, ptr %eraser_pointer_228, align 8, !noalias !0
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
  store ptr %stack_78, ptr %stack.repack5.i, align 8
  %stack_pointer.i = getelementptr i8, ptr %calloc.i.i, i64 8
  store ptr %stack.i, ptr %stack_pointer.i, align 8
  %nextStackPointer.i89 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i90 = icmp ugt ptr %nextStackPointer.i89, %limit.i.i
  br i1 %isInside.not.i90, label %realloc.i93, label %stackAllocate.exit107

realloc.i93:                                      ; preds = %stackAllocate.exit83
  %newBase.i103 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i104 = getelementptr i8, ptr %newBase.i103, i64 32
  %newNextStackPointer.i106 = getelementptr i8, ptr %newBase.i103, i64 24
  store ptr %newBase.i103, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i104, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit107

stackAllocate.exit107:                            ; preds = %stackAllocate.exit83, %realloc.i93
  %limit.i111 = phi ptr [ %newLimit.i104, %realloc.i93 ], [ %limit.i.i, %stackAllocate.exit83 ]
  %nextStackPointer.sink.i91 = phi ptr [ %newNextStackPointer.i106, %realloc.i93 ], [ %nextStackPointer.i89, %stackAllocate.exit83 ]
  %base.i118 = phi ptr [ %newBase.i103, %realloc.i93 ], [ %stackPointer.i.i, %stackAllocate.exit83 ]
  %sharer_pointer_237 = getelementptr i8, ptr %base.i118, i64 8
  %eraser_pointer_238 = getelementptr i8, ptr %base.i118, i64 16
  store ptr @returnAddress_230, ptr %base.i118, align 8, !noalias !0
  store ptr @sharer_20, ptr %sharer_pointer_237, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_238, align 8, !noalias !0
  %nextStackPointer.i112 = getelementptr i8, ptr %nextStackPointer.sink.i91, i64 40
  %isInside.not.i113 = icmp ugt ptr %nextStackPointer.i112, %limit.i111
  br i1 %isInside.not.i113, label %realloc.i116, label %stackAllocate.exit130

realloc.i116:                                     ; preds = %stackAllocate.exit107
  %intStackPointer.i119 = ptrtoint ptr %nextStackPointer.sink.i91 to i64
  %intBase.i120 = ptrtoint ptr %base.i118 to i64
  %size.i121 = sub i64 %intStackPointer.i119, %intBase.i120
  %nextSize.i122 = add i64 %size.i121, 40
  %leadingZeros.i.i123 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i122, i1 false)
  %numBits.i.i124 = sub nuw nsw i64 64, %leadingZeros.i.i123
  %result.i.i125 = shl nuw i64 1, %numBits.i.i124
  %newBase.i126 = tail call ptr @realloc(ptr nonnull %base.i118, i64 %result.i.i125)
  %newLimit.i127 = getelementptr i8, ptr %newBase.i126, i64 %result.i.i125
  %newStackPointer.i128 = getelementptr i8, ptr %newBase.i126, i64 %size.i121
  %newNextStackPointer.i129 = getelementptr i8, ptr %newStackPointer.i128, i64 40
  store ptr %newBase.i126, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i127, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit130

stackAllocate.exit130:                            ; preds = %stackAllocate.exit107, %realloc.i116
  %nextStackPointer.sink.i114 = phi ptr [ %newNextStackPointer.i129, %realloc.i116 ], [ %nextStackPointer.i112, %stackAllocate.exit107 ]
  %common.ret.op.i115 = phi ptr [ %newStackPointer.i128, %realloc.i116 ], [ %nextStackPointer.sink.i91, %stackAllocate.exit107 ]
  %reference..1.i = insertvalue %Reference undef, ptr %prompt.i37, 0
  %reference.i = insertvalue %Reference %reference..1.i, i64 %offset.i, 1
  %reference..1.i19 = insertvalue %Reference undef, ptr %prompt.i28, 0
  %reference.i20 = insertvalue %Reference %reference..1.i19, i64 %offset.i17, 1
  store ptr %nextStackPointer.sink.i114, ptr %stack.repack1.i, align 8
  store ptr %prompt.i28, ptr %common.ret.op.i115, align 8, !noalias !0
  %stackPointer_403.repack9 = getelementptr inbounds i8, ptr %common.ret.op.i115, i64 8
  store i64 %offset.i17, ptr %stackPointer_403.repack9, align 8, !noalias !0
  %returnAddress_pointer_405 = getelementptr i8, ptr %common.ret.op.i115, i64 16
  %sharer_pointer_406 = getelementptr i8, ptr %common.ret.op.i115, i64 24
  %eraser_pointer_407 = getelementptr i8, ptr %common.ret.op.i115, i64 32
  store ptr @returnAddress_385, ptr %returnAddress_pointer_405, align 8, !noalias !0
  store ptr @sharer_396, ptr %sharer_pointer_406, align 8, !noalias !0
  store ptr @eraser_400, ptr %eraser_pointer_407, align 8, !noalias !0
  musttail call tailcc void @iterate_worker_4_3_58_4667(%Pos %tree_4_4688, %Reference %reference.i20, ptr nonnull %calloc.i.i, %Reference %reference.i, ptr nonnull %stack.i)
  ret void
}

define void @sharer_409(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_413(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3514_3578, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3514_3578, 0
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
  %nextStackPointer.i31 = getelementptr i8, ptr %nextStackPointer.sink.i10, i64 32
  %isInside.not.i32 = icmp ugt ptr %nextStackPointer.i31, %limit.i30
  br i1 %isInside.not.i32, label %realloc.i35, label %stackAllocate.exit49

realloc.i35:                                      ; preds = %stackAllocate.exit26
  %intStackPointer.i38 = ptrtoint ptr %nextStackPointer.sink.i10 to i64
  %intBase.i39 = ptrtoint ptr %base.i37 to i64
  %size.i40 = sub i64 %intStackPointer.i38, %intBase.i39
  %nextSize.i41 = add i64 %size.i40, 32
  %leadingZeros.i.i42 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i41, i1 false)
  %numBits.i.i43 = sub nuw nsw i64 64, %leadingZeros.i.i42
  %result.i.i44 = shl nuw i64 1, %numBits.i.i43
  %newBase.i45 = tail call ptr @realloc(ptr nonnull %base.i37, i64 %result.i.i44)
  %newLimit.i46 = getelementptr i8, ptr %newBase.i45, i64 %result.i.i44
  %newStackPointer.i47 = getelementptr i8, ptr %newBase.i45, i64 %size.i40
  %newNextStackPointer.i48 = getelementptr i8, ptr %newStackPointer.i47, i64 32
  store ptr %newBase.i45, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i46, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit49

stackAllocate.exit49:                             ; preds = %stackAllocate.exit26, %realloc.i35
  %base.i.i56 = phi ptr [ %newBase.i45, %realloc.i35 ], [ %base.i37, %stackAllocate.exit26 ]
  %limit.i4.pre.i = phi ptr [ %newLimit.i46, %realloc.i35 ], [ %limit.i30, %stackAllocate.exit26 ]
  %nextStackPointer.sink.i33 = phi ptr [ %newNextStackPointer.i48, %realloc.i35 ], [ %nextStackPointer.i31, %stackAllocate.exit26 ]
  %common.ret.op.i34 = phi ptr [ %newStackPointer.i47, %realloc.i35 ], [ %nextStackPointer.sink.i10, %stackAllocate.exit26 ]
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  store ptr %calloc.i.i, ptr %common.ret.op.i34, align 8, !noalias !0
  %returnAddress_pointer_418 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %sharer_pointer_419 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  %eraser_pointer_420 = getelementptr i8, ptr %common.ret.op.i34, i64 24
  store ptr @returnAddress_28, ptr %returnAddress_pointer_418, align 8, !noalias !0
  store ptr @sharer_409, ptr %sharer_pointer_419, align 8, !noalias !0
  store ptr @eraser_413, ptr %eraser_pointer_420, align 8, !noalias !0
  %z.i6.i = icmp eq i64 %unboxed.i, 0
  br i1 %z.i6.i, label %label_739.i, label %label_734.i

label_734.i:                                      ; preds = %stackAllocate.exit49, %stackAllocate.exit.i
  %base.i.i = phi ptr [ %base.i.i55, %stackAllocate.exit.i ], [ %base.i.i56, %stackAllocate.exit49 ]
  %limit.i.i50 = phi ptr [ %limit.i9.i, %stackAllocate.exit.i ], [ %limit.i4.pre.i, %stackAllocate.exit49 ]
  %currentStackPointer.i.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %nextStackPointer.sink.i33, %stackAllocate.exit49 ]
  %n_2435.tr7.i = phi i64 [ %z.i1.i, %stackAllocate.exit.i ], [ %unboxed.i, %stackAllocate.exit49 ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 32
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i50
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_734.i
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 32
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 32
  store ptr %newBase.i.i, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_734.i
  %base.i.i55 = phi ptr [ %newBase.i.i, %realloc.i.i ], [ %base.i.i, %label_734.i ]
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i50, %label_734.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_734.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_734.i ]
  %z.i1.i = add i64 %n_2435.tr7.i, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stack.repack1.i, align 8
  store i64 %n_2435.tr7.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %returnAddress_pointer_731.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  %sharer_pointer_732.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %eraser_pointer_733.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @returnAddress_702, ptr %returnAddress_pointer_731.i, align 8, !noalias !0
  store ptr @sharer_722, ptr %sharer_pointer_732.i, align 8, !noalias !0
  store ptr @eraser_726, ptr %eraser_pointer_733.i, align 8, !noalias !0
  %z.i.i = icmp eq i64 %z.i1.i, 0
  br i1 %z.i.i, label %label_739.i, label %label_734.i

label_739.i:                                      ; preds = %stackAllocate.exit.i, %stackAllocate.exit49
  %limit.i4.i = phi ptr [ %limit.i4.pre.i, %stackAllocate.exit49 ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %stackPointer.i.i51 = phi ptr [ %nextStackPointer.sink.i33, %stackAllocate.exit49 ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i51, %limit.i4.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i5.i = getelementptr i8, ptr %stackPointer.i.i51, i64 -24
  store ptr %newStackPointer.i5.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_736.i = load ptr, ptr %newStackPointer.i5.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_736.i(%Pos zeroinitializer, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_426(%Pos %returned_4937, ptr nocapture %stack) {
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
  %returnAddress_428 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_428(%Pos %returned_4937, ptr %rest.i)
  ret void
}

define void @eraser_442(ptr nocapture readonly %environment) {
entry:
  %tmp_4842_440.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_4842_440.unpack2 = load ptr, ptr %tmp_4842_440.elt1, align 8, !noalias !0
  %acc_3_3_5_169_4322_441.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_4322_441.unpack5 = load ptr, ptr %acc_3_3_5_169_4322_441.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_4842_440.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_4842_440.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_4842_440.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_4842_440.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_4842_440.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_4842_440.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_4322_441.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_4322_441.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_4322_441.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_4322_441.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_4322_441.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_4322_441.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4541(i64 %start_2_2_4_168_4417, %Pos %acc_3_3_5_169_4322, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4417, 1
  br i1 %z.i6, label %label_452, label %label_448

label_448:                                        ; preds = %entry, %label_448
  %acc_3_3_5_169_4322.tr8 = phi %Pos [ %make_4943, %label_448 ], [ %acc_3_3_5_169_4322, %entry ]
  %start_2_2_4_168_4417.tr7 = phi i64 [ %z.i5, %label_448 ], [ %start_2_2_4_168_4417, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4417.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4417.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_442, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_4940.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_4940.elt, ptr %environment.i, align 8, !noalias !0
  %environment_439.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_4940.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_4940.elt2, ptr %environment_439.repack1, align 8, !noalias !0
  %acc_3_3_5_169_4322_pointer_446 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_4322.elt = extractvalue %Pos %acc_3_3_5_169_4322.tr8, 0
  store i64 %acc_3_3_5_169_4322.elt, ptr %acc_3_3_5_169_4322_pointer_446, align 8, !noalias !0
  %acc_3_3_5_169_4322_pointer_446.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_4322.elt4 = extractvalue %Pos %acc_3_3_5_169_4322.tr8, 1
  store ptr %acc_3_3_5_169_4322.elt4, ptr %acc_3_3_5_169_4322_pointer_446.repack3, align 8, !noalias !0
  %make_4943 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4417.tr7, 2
  br i1 %z.i, label %label_452, label %label_448

label_452:                                        ; preds = %label_448, %entry
  %acc_3_3_5_169_4322.tr.lcssa = phi %Pos [ %acc_3_3_5_169_4322, %entry ], [ %make_4943, %label_448 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_449 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_449(%Pos %acc_3_3_5_169_4322.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_463(%Pos %v_r_2669_32_59_223_4452, ptr %stack) {
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
  %p_8_9_4270 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %acc_8_35_199_4301_pointer_466 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %acc_8_35_199_4301 = load i64, ptr %acc_8_35_199_4301_pointer_466, align 4, !noalias !0
  %v_r_2586_30_194_4436_pointer_467 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_r_2586_30_194_4436.unpack = load i64, ptr %v_r_2586_30_194_4436_pointer_467, align 8, !noalias !0
  %v_r_2586_30_194_4436.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2586_30_194_4436.unpack2 = load ptr, ptr %v_r_2586_30_194_4436.elt1, align 8, !noalias !0
  %tmp_4849_pointer_468 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_4849 = load i64, ptr %tmp_4849_pointer_468, align 4, !noalias !0
  %index_7_34_198_4472_pointer_469 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %index_7_34_198_4472 = load i64, ptr %index_7_34_198_4472_pointer_469, align 4, !noalias !0
  %tag_470 = extractvalue %Pos %v_r_2669_32_59_223_4452, 0
  %fields_471 = extractvalue %Pos %v_r_2669_32_59_223_4452, 1
  switch i64 %tag_470, label %common.ret [
    i64 1, label %label_495
    i64 0, label %label_502
  ]

common.ret:                                       ; preds = %entry
  ret void

label_483:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2586_30_194_4436.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_483
  %referenceCount.i.i37 = load i64, ptr %v_r_2586_30_194_4436.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2586_30_194_4436.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2586_30_194_4436.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2586_30_194_4436.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2586_30_194_4436.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_483, %decr.i.i39, %free.i.i41
  %pair_478 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4270)
  %k_13_14_4_4768 = extractvalue <{ ptr, ptr }> %pair_478, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_4768, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_4768, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_4768, i64 40
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
  %stack_479 = extractvalue <{ ptr, ptr }> %pair_478, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_479, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_479, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_480 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_480(%Pos { i64 10, ptr null }, ptr %stack_479)
  ret void

label_492:                                        ; preds = %label_494
  %isNull.i.i24 = icmp eq ptr %v_r_2586_30_194_4436.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_492
  %referenceCount.i.i26 = load i64, ptr %v_r_2586_30_194_4436.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2586_30_194_4436.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2586_30_194_4436.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2586_30_194_4436.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2586_30_194_4436.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_492, %decr.i.i28, %free.i.i30
  %pair_487 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4270)
  %k_13_14_4_4767 = extractvalue <{ ptr, ptr }> %pair_487, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_4767, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_4767, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4767, i64 40
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
  %stack_488 = extractvalue <{ ptr, ptr }> %pair_487, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_488, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_488, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_489 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_489(%Pos { i64 10, ptr null }, ptr %stack_488)
  ret void

label_493:                                        ; preds = %label_494
  %0 = insertvalue %Pos poison, i64 %v_r_2586_30_194_4436.unpack, 0
  %v_r_2586_30_194_44363 = insertvalue %Pos %0, ptr %v_r_2586_30_194_4436.unpack2, 1
  %z.i = add i64 %index_7_34_198_4472, 1
  %z.i108 = mul i64 %acc_8_35_199_4301, 10
  %z.i109 = sub i64 %z.i108, %tmp_4849
  %z.i110 = add i64 %z.i109, %v_coe_3485_46_73_237_4466.unpack
  musttail call tailcc void @go_6_33_197_4427(i64 %z.i, i64 %z.i110, i64 %tmp_4849, ptr %p_8_9_4270, %Pos %v_r_2586_30_194_44363, ptr nonnull %stack)
  ret void

label_494:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3485_46_73_237_4466.unpack, 58
  br i1 %z.i111, label %label_493, label %label_492

label_495:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_471, i64 16
  %v_coe_3485_46_73_237_4466.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3485_46_73_237_4466.elt4 = getelementptr i8, ptr %fields_471, i64 24
  %v_coe_3485_46_73_237_4466.unpack5 = load ptr, ptr %v_coe_3485_46_73_237_4466.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3485_46_73_237_4466.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_495
  %referenceCount.i.i = load i64, ptr %v_coe_3485_46_73_237_4466.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3485_46_73_237_4466.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_495
  %referenceCount.i11 = load i64, ptr %fields_471, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_471, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_471, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_471)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_3485_46_73_237_4466.unpack, 47
  br i1 %z.i112, label %label_494, label %label_483

label_502:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_471, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_502
  %referenceCount.i = load i64, ptr %fields_471, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_471, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_471, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_471, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_471)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_502, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_2586_30_194_4436.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2586_30_194_4436.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2586_30_194_4436.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2586_30_194_4436.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2586_30_194_4436.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2586_30_194_4436.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_499 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_499(i64 %acc_8_35_199_4301, ptr nonnull %stack)
  ret void
}

define void @sharer_508(ptr %stackPointer) {
entry:
  %v_r_2586_30_194_4436_505.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2586_30_194_4436_505.unpack2 = load ptr, ptr %v_r_2586_30_194_4436_505.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2586_30_194_4436_505.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2586_30_194_4436_505.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2586_30_194_4436_505.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_520(ptr %stackPointer) {
entry:
  %v_r_2586_30_194_4436_517.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2586_30_194_4436_517.unpack2 = load ptr, ptr %v_r_2586_30_194_4436_517.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2586_30_194_4436_517.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2586_30_194_4436_517.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2586_30_194_4436_517.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2586_30_194_4436_517.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2586_30_194_4436_517.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2586_30_194_4436_517.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_537(%Pos %returned_4968, ptr nocapture %stack) {
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
  %returnAddress_539 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_539(%Pos %returned_4968, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_4423_clause_546(ptr %closure, %Pos %exc_8_20_47_211_4382, %Pos %msg_9_21_48_212_4576, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4505 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_549 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4505)
  %k_11_23_50_214_4593 = extractvalue <{ ptr, ptr }> %pair_549, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_4593, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_4593, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_4593, i64 40
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
  %stack_550 = extractvalue <{ ptr, ptr }> %pair_549, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_442, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_4382.elt = extractvalue %Pos %exc_8_20_47_211_4382, 0
  store i64 %exc_8_20_47_211_4382.elt, ptr %environment.i, align 8, !noalias !0
  %environment_552.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_4382.elt2 = extractvalue %Pos %exc_8_20_47_211_4382, 1
  store ptr %exc_8_20_47_211_4382.elt2, ptr %environment_552.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4576_pointer_556 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4576.elt = extractvalue %Pos %msg_9_21_48_212_4576, 0
  store i64 %msg_9_21_48_212_4576.elt, ptr %msg_9_21_48_212_4576_pointer_556, align 8, !noalias !0
  %msg_9_21_48_212_4576_pointer_556.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4576.elt4 = extractvalue %Pos %msg_9_21_48_212_4576, 1
  store ptr %msg_9_21_48_212_4576.elt4, ptr %msg_9_21_48_212_4576_pointer_556.repack3, align 8, !noalias !0
  %make_4969 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_550, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_550, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_558 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_558(%Pos %make_4969, ptr %stack_550)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_565(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define tailcc void @returnAddress_569(i64 %v_coe_3484_6_28_55_219_4344, ptr %stack) {
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
  store ptr @eraser_297, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3484_6_28_55_219_4344, ptr %environment.i, align 8, !noalias !0
  %environment_571.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_571.repack1, align 8, !noalias !0
  %make_4971 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_575 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_575(%Pos %make_4971, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_4427(i64 %index_7_34_198_4472, i64 %acc_8_35_199_4301, i64 %tmp_4849, ptr %p_8_9_4270, %Pos %v_r_2586_30_194_4436, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2586_30_194_4436, 1
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
  store ptr %p_8_9_4270, ptr %common.ret.op.i, align 8, !noalias !0
  %acc_8_35_199_4301_pointer_529 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %acc_8_35_199_4301, ptr %acc_8_35_199_4301_pointer_529, align 4, !noalias !0
  %v_r_2586_30_194_4436_pointer_530 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2586_30_194_4436.elt = extractvalue %Pos %v_r_2586_30_194_4436, 0
  store i64 %v_r_2586_30_194_4436.elt, ptr %v_r_2586_30_194_4436_pointer_530, align 8, !noalias !0
  %v_r_2586_30_194_4436_pointer_530.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i3, ptr %v_r_2586_30_194_4436_pointer_530.repack1, align 8, !noalias !0
  %tmp_4849_pointer_531 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %tmp_4849, ptr %tmp_4849_pointer_531, align 4, !noalias !0
  %index_7_34_198_4472_pointer_532 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %index_7_34_198_4472, ptr %index_7_34_198_4472_pointer_532, align 4, !noalias !0
  %returnAddress_pointer_533 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_534 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_535 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_463, ptr %returnAddress_pointer_533, align 8, !noalias !0
  store ptr @sharer_508, ptr %sharer_pointer_534, align 8, !noalias !0
  store ptr @eraser_520, ptr %eraser_pointer_535, align 8, !noalias !0
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
  %sharer_pointer_544 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_545 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_537, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_20, ptr %sharer_pointer_544, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_545, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_565, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_4423 = insertvalue %Neg { ptr @vtable_561, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_580 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_581 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_569, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_580, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_581, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2586_30_194_4436, i64 %index_7_34_198_4472, %Neg %Exception_7_19_46_210_4423, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_4455_clause_582(ptr %closure, %Pos %exception_10_107_134_298_4972, %Pos %msg_11_108_135_299_4973, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4270 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_4972, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_4973, 1
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
  %pair_585 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4270)
  %k_13_14_4_4829 = extractvalue <{ ptr, ptr }> %pair_585, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_4829, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_4829, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4829, i64 40
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
  %stack_586 = extractvalue <{ ptr, ptr }> %pair_585, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_586, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_586, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_587 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_587(%Pos { i64 10, ptr null }, ptr %stack_586)
  ret void
}

define tailcc void @returnAddress_601(i64 %v_coe_3489_22_131_158_322_4465, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3489_22_131_158_322_4465, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_602 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_602(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_613(i64 %v_r_2683_1_9_20_129_156_320_4543, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2683_1_9_20_129_156_320_4543
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_614 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_614(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_596(i64 %v_r_2682_3_14_123_150_314_4403, ptr %stack) {
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
  %tmp_4849 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %p_8_9_4270_pointer_599 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %p_8_9_4270 = load ptr, ptr %p_8_9_4270_pointer_599, align 8, !noalias !0
  %v_r_2586_30_194_4436_pointer_600 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2586_30_194_4436.unpack = load i64, ptr %v_r_2586_30_194_4436_pointer_600, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2586_30_194_4436.unpack, 0
  %v_r_2586_30_194_4436.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2586_30_194_4436.unpack2 = load ptr, ptr %v_r_2586_30_194_4436.elt1, align 8, !noalias !0
  %v_r_2586_30_194_44363 = insertvalue %Pos %0, ptr %v_r_2586_30_194_4436.unpack2, 1
  %z.i = icmp eq i64 %v_r_2682_3_14_123_150_314_4403, 45
  %isInside.not.i = icmp ugt ptr %v_r_2586_30_194_4436.elt1, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %v_r_2586_30_194_4436.elt1, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_607 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_608 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_601, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_607, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_608, align 8, !noalias !0
  br i1 %z.i, label %label_621, label %label_612

label_612:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_4427(i64 0, i64 0, i64 %tmp_4849, ptr %p_8_9_4270, %Pos %v_r_2586_30_194_44363, ptr nonnull %stack)
  ret void

label_621:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_621
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

stackAllocate.exit35:                             ; preds = %label_621, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_621 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_621 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_619 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_620 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_613, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_619, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_620, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_4427(i64 1, i64 0, i64 %tmp_4849, ptr %p_8_9_4270, %Pos %v_r_2586_30_194_44363, ptr nonnull %stack)
  ret void
}

define void @sharer_625(ptr %stackPointer) {
entry:
  %v_r_2586_30_194_4436_624.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2586_30_194_4436_624.unpack2 = load ptr, ptr %v_r_2586_30_194_4436_624.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2586_30_194_4436_624.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2586_30_194_4436_624.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2586_30_194_4436_624.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_633(ptr %stackPointer) {
entry:
  %v_r_2586_30_194_4436_632.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2586_30_194_4436_632.unpack2 = load ptr, ptr %v_r_2586_30_194_4436_632.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2586_30_194_4436_632.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2586_30_194_4436_632.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2586_30_194_4436_632.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2586_30_194_4436_632.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2586_30_194_4436_632.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2586_30_194_4436_632.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_460(%Pos %v_r_2586_30_194_4436, ptr %stack) {
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
  %p_8_9_4270 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_565, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4270, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2586_30_194_4436, 1
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
  store i64 48, ptr %common.ret.op.i, align 4, !noalias !0
  %p_8_9_4270_pointer_640 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_8_9_4270, ptr %p_8_9_4270_pointer_640, align 8, !noalias !0
  %v_r_2586_30_194_4436_pointer_641 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2586_30_194_4436.elt = extractvalue %Pos %v_r_2586_30_194_4436, 0
  store i64 %v_r_2586_30_194_4436.elt, ptr %v_r_2586_30_194_4436_pointer_641, align 8, !noalias !0
  %v_r_2586_30_194_4436_pointer_641.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i3, ptr %v_r_2586_30_194_4436_pointer_641.repack1, align 8, !noalias !0
  %returnAddress_pointer_642 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_643 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_644 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_596, ptr %returnAddress_pointer_642, align 8, !noalias !0
  store ptr @sharer_625, ptr %sharer_pointer_643, align 8, !noalias !0
  store ptr @eraser_633, ptr %eraser_pointer_644, align 8, !noalias !0
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
  store i64 %v_r_2586_30_194_4436.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_774.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_774.repack1.i, align 8, !noalias !0
  %index_2107_pointer_776.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_776.i, align 4, !noalias !0
  %Exception_2362_pointer_777.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_590, ptr %Exception_2362_pointer_777.i, align 8, !noalias !0
  %Exception_2362_pointer_777.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_777.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_778.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_779.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_780.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_740, ptr %returnAddress_pointer_778.i, align 8, !noalias !0
  store ptr @sharer_761, ptr %sharer_pointer_779.i, align 8, !noalias !0
  store ptr @eraser_769, ptr %eraser_pointer_780.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2586_30_194_4436)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_784.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_784.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_457(%Pos %v_r_2585_24_188_4338, ptr %stack) {
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
  %p_8_9_4270 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4270, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_650 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_651 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_460, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_409, ptr %sharer_pointer_650, align 8, !noalias !0
  store ptr @eraser_413, ptr %eraser_pointer_651, align 8, !noalias !0
  %tag_652 = extractvalue %Pos %v_r_2585_24_188_4338, 0
  switch i64 %tag_652, label %label_654 [
    i64 0, label %label_658
    i64 1, label %label_664
  ]

label_654:                                        ; preds = %stackAllocate.exit
  ret void

label_658:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_4988 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_4988.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_655 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655(%Pos %utf8StringLiteral_4988, ptr nonnull %stack)
  ret void

label_664:                                        ; preds = %stackAllocate.exit
  %fields_653 = extractvalue %Pos %v_r_2585_24_188_4338, 1
  %environment.i = getelementptr i8, ptr %fields_653, i64 16
  %v_y_3311_8_29_193_4488.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3311_8_29_193_4488.elt1 = getelementptr i8, ptr %fields_653, i64 24
  %v_y_3311_8_29_193_4488.unpack2 = load ptr, ptr %v_y_3311_8_29_193_4488.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3311_8_29_193_4488.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_664
  %referenceCount.i.i = load i64, ptr %v_y_3311_8_29_193_4488.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3311_8_29_193_4488.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_664
  %referenceCount.i = load i64, ptr %fields_653, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_653, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_653, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_653)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3311_8_29_193_4488.unpack, 0
  %v_y_3311_8_29_193_44883 = insertvalue %Pos %0, ptr %v_y_3311_8_29_193_4488.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_661 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_661(%Pos %v_y_3311_8_29_193_44883, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_454(%Pos %v_r_2584_13_177_4413, ptr %stack) {
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
  %p_8_9_4270 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4270, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_670 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_671 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_457, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_409, ptr %sharer_pointer_670, align 8, !noalias !0
  store ptr @eraser_413, ptr %eraser_pointer_671, align 8, !noalias !0
  %tag_672 = extractvalue %Pos %v_r_2584_13_177_4413, 0
  switch i64 %tag_672, label %label_674 [
    i64 0, label %label_679
    i64 1, label %label_691
  ]

label_674:                                        ; preds = %stackAllocate.exit
  ret void

label_679:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4270, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_460, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_409, ptr %sharer_pointer_670, align 8, !noalias !0
  store ptr @eraser_413, ptr %eraser_pointer_671, align 8, !noalias !0
  %utf8StringLiteral_4988.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_4988.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_655.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655.i(%Pos %utf8StringLiteral_4988.i, ptr nonnull %stack)
  ret void

label_691:                                        ; preds = %stackAllocate.exit
  %fields_673 = extractvalue %Pos %v_r_2584_13_177_4413, 1
  %environment.i6 = getelementptr i8, ptr %fields_673, i64 16
  %v_y_2820_10_21_185_4433.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_2820_10_21_185_4433.elt1 = getelementptr i8, ptr %fields_673, i64 24
  %v_y_2820_10_21_185_4433.unpack2 = load ptr, ptr %v_y_2820_10_21_185_4433.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2820_10_21_185_4433.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_691
  %referenceCount.i.i = load i64, ptr %v_y_2820_10_21_185_4433.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2820_10_21_185_4433.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_691
  %referenceCount.i = load i64, ptr %fields_673, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_673, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_673, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_673)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_297, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2820_10_21_185_4433.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_684.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2820_10_21_185_4433.unpack2, ptr %environment_684.repack4, align 8, !noalias !0
  %make_4990 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_688 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_688(%Pos %make_4990, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2444(ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_423 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_424 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_423, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_424, align 8, !noalias !0
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
  %sharer_pointer_433 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_434 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_426, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_20, ptr %sharer_pointer_433, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_434, align 8, !noalias !0
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
  %returnAddress_pointer_696 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_697 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_698 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_454, ptr %returnAddress_pointer_696, align 8, !noalias !0
  store ptr @sharer_409, ptr %sharer_pointer_697, align 8, !noalias !0
  store ptr @eraser_413, ptr %eraser_pointer_698, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_452.i, label %label_448.i

label_448.i:                                      ; preds = %stackAllocate.exit46, %label_448.i
  %acc_3_3_5_169_4322.tr8.i = phi %Pos [ %make_4943.i, %label_448.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4417.tr7.i = phi i64 [ %z.i5.i, %label_448.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4417.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4417.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_442, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_4940.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_4940.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_439.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_4940.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_4940.elt2.i, ptr %environment_439.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_4322_pointer_446.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_4322.elt.i = extractvalue %Pos %acc_3_3_5_169_4322.tr8.i, 0
  store i64 %acc_3_3_5_169_4322.elt.i, ptr %acc_3_3_5_169_4322_pointer_446.i, align 8, !noalias !0
  %acc_3_3_5_169_4322_pointer_446.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_4322.elt4.i = extractvalue %Pos %acc_3_3_5_169_4322.tr8.i, 1
  store ptr %acc_3_3_5_169_4322.elt4.i, ptr %acc_3_3_5_169_4322_pointer_446.repack3.i, align 8, !noalias !0
  %make_4943.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4417.tr7.i, 2
  br i1 %z.i.i, label %label_452.i.loopexit, label %label_448.i

label_452.i.loopexit:                             ; preds = %label_448.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_452.i

label_452.i:                                      ; preds = %label_452.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_452.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_452.i.loopexit ]
  %acc_3_3_5_169_4322.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_4943.i, %label_452.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_449.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_449.i(%Pos %acc_3_3_5_169_4322.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define void @eraser_710(ptr nocapture readonly %environment) {
entry:
  %sub_2457_707.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %sub_2457_707.unpack2 = load ptr, ptr %sub_2457_707.elt1, align 8, !noalias !0
  %sub_2457_709.elt4 = getelementptr i8, ptr %environment, i64 32
  %sub_2457_709.unpack5 = load ptr, ptr %sub_2457_709.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %sub_2457_707.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %sub_2457_707.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %sub_2457_707.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %sub_2457_707.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %sub_2457_707.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %sub_2457_707.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %sub_2457_709.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %sub_2457_709.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %sub_2457_709.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %sub_2457_709.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %sub_2457_709.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %sub_2457_709.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_702(%Pos %sub_2457, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %n_2435 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %object.i = tail call dereferenceable_or_null(56) ptr @malloc(i64 56)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_710, ptr %objectEraser.i, align 8
  %object.i6 = extractvalue %Pos %sub_2457, 1
  %isNull.i.i = icmp eq ptr %object.i6, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %object.i6, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i6, align 4
  %stackPointer.i13.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %limit.i15 = phi ptr [ %limit.i, %entry ], [ %limit.i15.pre, %next.i.i ]
  %stackPointer.i13 = phi ptr [ %newStackPointer.i, %entry ], [ %stackPointer.i13.pre, %next.i.i ]
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %sub_2457.elt = extractvalue %Pos %sub_2457, 0
  store i64 %sub_2457.elt, ptr %environment.i, align 8, !noalias !0
  %environment_706.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr %object.i6, ptr %environment_706.repack1, align 8, !noalias !0
  %n_2435_pointer_715 = getelementptr i8, ptr %object.i, i64 32
  store i64 %n_2435, ptr %n_2435_pointer_715, align 4, !noalias !0
  %sub_2457_pointer_716 = getelementptr i8, ptr %object.i, i64 40
  store i64 %sub_2457.elt, ptr %sub_2457_pointer_716, align 8, !noalias !0
  %sub_2457_pointer_716.repack4 = getelementptr i8, ptr %object.i, i64 48
  store ptr %object.i6, ptr %sub_2457_pointer_716.repack4, align 8, !noalias !0
  %make_4906 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_718 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_718(%Pos %make_4906, ptr nonnull %stack)
  ret void
}

define void @sharer_722(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_726(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @makeTree_2436(i64 %n_2435, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp eq i64 %n_2435, 0
  %stackPointer_pointer.i2.phi.trans.insert = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i6, label %entry.label_739_crit_edge, label %label_734.lr.ph

entry.label_739_crit_edge:                        ; preds = %entry
  %stackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8, !alias.scope !0
  %limit_pointer.i3.phi.trans.insert = getelementptr i8, ptr %stack, i64 24
  %limit.i4.pre = load ptr, ptr %limit_pointer.i3.phi.trans.insert, align 8, !alias.scope !0
  br label %label_739

label_734.lr.ph:                                  ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %currentStackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8, !alias.scope !0
  %limit.i.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %label_734

label_734:                                        ; preds = %label_734.lr.ph, %stackAllocate.exit
  %limit.i = phi ptr [ %limit.i.pre, %label_734.lr.ph ], [ %limit.i9, %stackAllocate.exit ]
  %currentStackPointer.i = phi ptr [ %currentStackPointer.i.pre, %label_734.lr.ph ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %n_2435.tr7 = phi i64 [ %n_2435, %label_734.lr.ph ], [ %z.i1, %stackAllocate.exit ]
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_734
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 32
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 32
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_734, %realloc.i
  %limit.i9 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_734 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_734 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_734 ]
  %z.i1 = add i64 %n_2435.tr7, -1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8
  store i64 %n_2435.tr7, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_731 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_732 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_733 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_702, ptr %returnAddress_pointer_731, align 8, !noalias !0
  store ptr @sharer_722, ptr %sharer_pointer_732, align 8, !noalias !0
  store ptr @eraser_726, ptr %eraser_pointer_733, align 8, !noalias !0
  %z.i = icmp eq i64 %z.i1, 0
  br i1 %z.i, label %label_739, label %label_734

label_739:                                        ; preds = %stackAllocate.exit, %entry.label_739_crit_edge
  %limit.i4 = phi ptr [ %limit.i4.pre, %entry.label_739_crit_edge ], [ %limit.i9, %stackAllocate.exit ]
  %stackPointer.i = phi ptr [ %stackPointer.i.pre, %entry.label_739_crit_edge ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %stackPointer_pointer.i2 = getelementptr i8, ptr %stack, i64 8
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i5 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i5, ptr %stackPointer_pointer.i2, align 8, !alias.scope !0
  %returnAddress_736 = load ptr, ptr %newStackPointer.i5, align 8, !noalias !0
  musttail call tailcc void %returnAddress_736(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_740(%Pos %v_r_2751_3545, ptr %stack) {
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
  %index_2107_pointer_743 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_743, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_745 = extractvalue %Pos %v_r_2751_3545, 0
  switch i64 %tag_745, label %label_747 [
    i64 0, label %label_751
    i64 1, label %label_757
  ]

label_747:                                        ; preds = %entry
  ret void

label_751:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_751
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

eraseNegative.exit:                               ; preds = %label_751, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_748 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_748(i64 %x.i, ptr nonnull %stack)
  ret void

label_757:                                        ; preds = %entry
  %Exception_2362_pointer_744 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_744, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_4893 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_4893.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_4893, %Pos %z.i)
  %utf8StringLiteral_4895 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_4895.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_4895)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_4898 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_4898.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_4898)
  %functionPointer_756 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_756(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_761(ptr %stackPointer) {
entry:
  %str_2106_758.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_758.unpack2 = load ptr, ptr %str_2106_758.elt1, align 8, !noalias !0
  %Exception_2362_760.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_760.unpack5 = load ptr, ptr %Exception_2362_760.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_758.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_758.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_758.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_760.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_760.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_760.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_769(ptr %stackPointer) {
entry:
  %str_2106_766.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_766.unpack2 = load ptr, ptr %str_2106_766.elt1, align 8, !noalias !0
  %Exception_2362_768.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_768.unpack5 = load ptr, ptr %Exception_2362_768.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_766.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_766.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_766.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_766.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_766.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_766.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_768.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_768.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_768.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_768.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_768.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_768.unpack5)
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
  %stackPointer_774.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_774.repack1, align 8, !noalias !0
  %index_2107_pointer_776 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_776, align 4, !noalias !0
  %Exception_2362_pointer_777 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_777, align 8, !noalias !0
  %Exception_2362_pointer_777.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_777.repack3, align 8, !noalias !0
  %returnAddress_pointer_778 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_779 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_780 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_740, ptr %returnAddress_pointer_778, align 8, !noalias !0
  store ptr @sharer_761, ptr %sharer_pointer_779, align 8, !noalias !0
  store ptr @eraser_769, ptr %eraser_pointer_780, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_787, label %label_792

label_787:                                        ; preds = %stackAllocate.exit
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
  %returnAddress_784 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_784(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_792:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_792
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

erasePositive.exit:                               ; preds = %label_792, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_789 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_789(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  tail call tailcc void @main_2444(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2444(ptr nonnull %stack.i2.i)
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #11

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
attributes #11 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #12 = { nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" }

!0 = !{!1}
!1 = !{!"stackValues", !2}
!2 = !{!"types"}
