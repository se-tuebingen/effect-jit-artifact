; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:tree_explore_e2e5ae56-f3f4-4fe7-85cf-a35d7175985d/main.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:tree_explore_e2e5ae56-f3f4-4fe7-85cf-a35d7175985d/main.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_693 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4744_clause_678]
@vtable_724 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4738_clause_716]
@utf8StringLiteral_5585.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_5466.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_5468.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_5471.lit = private constant [1 x i8] c"'"

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
define %Pos @infixGt_184(i64 %x_182, i64 %y_183) local_unnamed_addr #5 {
  %z = icmp sgt i64 %x_182, %y_183
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

define tailcc void @returnAddress_3(i64 %r_2475, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2475)
  tail call void @c_io_println_String(%Pos %z.i)
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_4 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_4(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_7(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_9(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_15(i64 %returnValue_16, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %isInside.i5 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i6 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i6, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_19 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_19(i64 %returnValue_16, ptr %stack)
  ret void
}

define void @sharer_23(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_27(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_48(%Pos %__359_5312, ptr %stack) {
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
  %i_209_5097 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %state_4_4970_pointer_51 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %state_4_4970.unpack = load ptr, ptr %state_4_4970_pointer_51, align 8, !noalias !0
  %state_4_4970.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %state_4_4970.unpack2 = load i64, ptr %state_4_4970.elt1, align 8, !noalias !0
  %tree_2_5241_pointer_52 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tree_2_5241.unpack = load i64, ptr %tree_2_5241_pointer_52, align 8, !noalias !0
  %tree_2_5241.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tree_2_5241.unpack5 = load ptr, ptr %tree_2_5241.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__359_5312, 1
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
  %0 = insertvalue %Pos poison, i64 %tree_2_5241.unpack, 0
  %tree_2_52416 = insertvalue %Pos %0, ptr %tree_2_5241.unpack5, 1
  %1 = insertvalue %Reference poison, ptr %state_4_4970.unpack, 0
  %state_4_49703 = insertvalue %Reference %1, i64 %state_4_4970.unpack2, 1
  %z.i = add i64 %i_209_5097, -1
  musttail call tailcc void @loop_208_5045(i64 %z.i, %Reference %state_4_49703, %Pos %tree_2_52416, ptr nonnull %stack)
  ret void
}

define void @sharer_56(ptr %stackPointer) {
entry:
  %tree_2_5241_55.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %tree_2_5241_55.unpack2 = load ptr, ptr %tree_2_5241_55.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tree_2_5241_55.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tree_2_5241_55.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tree_2_5241_55.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_64(ptr %stackPointer) {
entry:
  %tree_2_5241_63.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %tree_2_5241_63.unpack2 = load ptr, ptr %tree_2_5241_63.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tree_2_5241_63.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tree_2_5241_63.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tree_2_5241_63.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tree_2_5241_63.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tree_2_5241_63.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tree_2_5241_63.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_43(i64 %v_r_2582_358_5287, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tree_2_5241.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tree_2_5241.unpack5 = load ptr, ptr %tree_2_5241.elt4, align 8, !noalias !0
  %tree_2_5241_pointer_47 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tree_2_5241.unpack = load i64, ptr %tree_2_5241_pointer_47, align 8, !noalias !0
  %state_4_4970.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %state_4_4970.unpack2 = load i64, ptr %state_4_4970.elt1, align 8, !noalias !0
  %state_4_4970_pointer_46 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %state_4_4970.unpack = load ptr, ptr %state_4_4970_pointer_46, align 8, !noalias !0
  %i_209_5097 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_209_5097, ptr %newStackPointer.i, align 4, !noalias !0
  %state_4_4970_pointer_71 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %state_4_4970.unpack, ptr %state_4_4970_pointer_71, align 8, !noalias !0
  %state_4_4970_pointer_71.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %state_4_4970.unpack2, ptr %state_4_4970_pointer_71.repack7, align 8, !noalias !0
  %tree_2_5241_pointer_72 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %tree_2_5241.unpack, ptr %tree_2_5241_pointer_72, align 8, !noalias !0
  %tree_2_5241_pointer_72.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %tree_2_5241.unpack5, ptr %tree_2_5241_pointer_72.repack9, align 8, !noalias !0
  %sharer_pointer_74 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_75 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_48, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_56, ptr %sharer_pointer_74, align 8, !noalias !0
  store ptr @eraser_64, ptr %eraser_pointer_75, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %state_4_4970.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %state_4_4970.unpack2
  store i64 %v_r_2582_358_5287, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_79 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_79(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_38(%Pos %v_r_2581_357_5130, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tree_2_5241.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tree_2_5241.unpack5 = load ptr, ptr %tree_2_5241.elt4, align 8, !noalias !0
  %tree_2_5241_pointer_42 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tree_2_5241.unpack = load i64, ptr %tree_2_5241_pointer_42, align 8, !noalias !0
  %state_4_4970.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %state_4_4970.unpack2 = load i64, ptr %state_4_4970.elt1, align 8, !noalias !0
  %state_4_4970_pointer_41 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %state_4_4970.unpack = load ptr, ptr %state_4_4970_pointer_41, align 8, !noalias !0
  %i_209_5097 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_209_5097, ptr %newStackPointer.i, align 4, !noalias !0
  %state_4_4970_pointer_90 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %state_4_4970.unpack, ptr %state_4_4970_pointer_90, align 8, !noalias !0
  %state_4_4970_pointer_90.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %state_4_4970.unpack2, ptr %state_4_4970_pointer_90.repack7, align 8, !noalias !0
  %tree_2_5241_pointer_91 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %tree_2_5241.unpack, ptr %tree_2_5241_pointer_91, align 8, !noalias !0
  %tree_2_5241_pointer_91.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %tree_2_5241.unpack5, ptr %tree_2_5241_pointer_91.repack9, align 8, !noalias !0
  %sharer_pointer_93 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_94 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_43, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_56, ptr %sharer_pointer_93, align 8, !noalias !0
  store ptr @eraser_64, ptr %eraser_pointer_94, align 8, !noalias !0
  musttail call tailcc void @maximum_2438(%Pos %v_r_2581_357_5130, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_109(%Pos %returned_5494, ptr nocapture %stack) {
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
  %returnAddress_111 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_111(%Pos %returned_5494, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_114(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_116(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define tailcc void @returnAddress_168(i64 %v_r_2547_8_22_53_140_350_5122, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = srem i64 %v_r_2547_8_22_53_140_350_5122, 1009
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_169 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_169(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_165(i64 %v_r_2560_16_47_134_344_5260, ptr %stack) {
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
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_y_2564_33_91_301_5000 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i.neg = mul i64 %v_r_2560_16_47_134_344_5260, -503
  %z.i6 = add i64 %v_y_2564_33_91_301_5000, %z.i.neg
  %z.i7 = add i64 %z.i6, 37
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  %sharer_pointer_174 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_175 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_168, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_7, ptr %sharer_pointer_174, align 8, !noalias !0
  store ptr @eraser_9, ptr %eraser_pointer_175, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %z.i7, -1
  br i1 %switch.not.not, label %label_182, label %label_186

label_182:                                        ; preds = %stackAllocate.exit
  %isInside.i17 = icmp ule ptr %nextStackPointer.sink.i, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_179 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_179(i64 %z.i7, ptr nonnull %stack)
  ret void

label_186:                                        ; preds = %stackAllocate.exit
  %z.i19 = sub nuw i64 -37, %z.i6
  %isInside.i24 = icmp ule ptr %nextStackPointer.sink.i, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i24)
  %newStackPointer.i25 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i25, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_183 = load ptr, ptr %newStackPointer.i25, align 8, !noalias !0
  musttail call tailcc void %returnAddress_183(i64 %z.i19, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_159(%Pos %__15_46_133_343_5311, ptr %stack) {
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
  %v_y_2564_33_91_301_5000 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %next_5_36_123_333_5273_pointer_162 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %next_5_36_123_333_5273.unpack = load i64, ptr %next_5_36_123_333_5273_pointer_162, align 8, !noalias !0
  %next_5_36_123_333_5273.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %next_5_36_123_333_5273.unpack2 = load ptr, ptr %next_5_36_123_333_5273.elt1, align 8, !noalias !0
  %state_4_4970_pointer_163 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %state_4_4970.unpack = load ptr, ptr %state_4_4970_pointer_163, align 8, !noalias !0
  %state_4_4970.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %state_4_4970.unpack5 = load i64, ptr %state_4_4970.elt4, align 8, !noalias !0
  %p_2_212_5152_pointer_164 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_2_212_5152 = load ptr, ptr %p_2_212_5152_pointer_164, align 8, !noalias !0
  %object.i = extractvalue %Pos %__15_46_133_343_5311, 1
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
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i14
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
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
  %newStackPointer.i15 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i15, i64 32
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i15, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  %0 = insertvalue %Reference poison, ptr %state_4_4970.unpack, 0
  %state_4_49706 = insertvalue %Reference %0, i64 %state_4_4970.unpack5, 1
  %1 = insertvalue %Pos poison, i64 %next_5_36_123_333_5273.unpack, 0
  %next_5_36_123_333_52733 = insertvalue %Pos %1, ptr %next_5_36_123_333_5273.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_y_2564_33_91_301_5000, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_191 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_192 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_193 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_165, ptr %returnAddress_pointer_191, align 8, !noalias !0
  store ptr @sharer_23, ptr %sharer_pointer_192, align 8, !noalias !0
  store ptr @eraser_27, ptr %eraser_pointer_193, align 8, !noalias !0
  musttail call tailcc void @explore_worker_4_33_243_4974(%Pos %next_5_36_123_333_52733, %Reference %state_4_49706, ptr %p_2_212_5152, ptr nonnull %stack)
  ret void
}

define void @sharer_198(ptr %stackPointer) {
entry:
  %next_5_36_123_333_5273_195.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %next_5_36_123_333_5273_195.unpack2 = load ptr, ptr %next_5_36_123_333_5273_195.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %next_5_36_123_333_5273_195.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %next_5_36_123_333_5273_195.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %next_5_36_123_333_5273_195.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_208(ptr %stackPointer) {
entry:
  %next_5_36_123_333_5273_205.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %next_5_36_123_333_5273_205.unpack2 = load ptr, ptr %next_5_36_123_333_5273_205.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %next_5_36_123_333_5273_205.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %next_5_36_123_333_5273_205.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %next_5_36_123_333_5273_205.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %next_5_36_123_333_5273_205.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %next_5_36_123_333_5273_205.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %next_5_36_123_333_5273_205.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_153(i64 %v_r_2547_8_12_43_130_340_5268, ptr %stack) local_unnamed_addr {
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
  %v_y_2564_33_91_301_5000_pointer_158 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_158, align 4, !noalias !0
  %p_2_212_5152_pointer_157 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %p_2_212_5152 = load ptr, ptr %p_2_212_5152_pointer_157, align 8, !noalias !0
  %next_5_36_123_333_5273.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %next_5_36_123_333_5273.unpack5 = load ptr, ptr %next_5_36_123_333_5273.elt4, align 8, !noalias !0
  %next_5_36_123_333_5273_pointer_156 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %next_5_36_123_333_5273.unpack = load i64, ptr %next_5_36_123_333_5273_pointer_156, align 8, !noalias !0
  %state_4_4970.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %state_4_4970.unpack2 = load i64, ptr %state_4_4970.elt1, align 8, !noalias !0
  %state_4_4970.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = srem i64 %v_r_2547_8_12_43_130_340_5268, 1009
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_y_2564_33_91_301_5000, ptr %newStackPointer.i, align 4, !noalias !0
  %next_5_36_123_333_5273_pointer_216 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store i64 %next_5_36_123_333_5273.unpack, ptr %next_5_36_123_333_5273_pointer_216, align 8, !noalias !0
  %next_5_36_123_333_5273_pointer_216.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %next_5_36_123_333_5273.unpack5, ptr %next_5_36_123_333_5273_pointer_216.repack7, align 8, !noalias !0
  %state_4_4970_pointer_217 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %state_4_4970.unpack, ptr %state_4_4970_pointer_217, align 8, !noalias !0
  %state_4_4970_pointer_217.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %state_4_4970.unpack2, ptr %state_4_4970_pointer_217.repack9, align 8, !noalias !0
  %p_2_212_5152_pointer_218 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %p_2_212_5152, ptr %p_2_212_5152_pointer_218, align 8, !noalias !0
  %sharer_pointer_220 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_221 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_159, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_198, ptr %sharer_pointer_220, align 8, !noalias !0
  store ptr @eraser_208, ptr %eraser_pointer_221, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %state_4_4970.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %state_4_4970.unpack2
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_225 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_225(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_232(ptr %stackPointer) {
entry:
  %next_5_36_123_333_5273_229.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %next_5_36_123_333_5273_229.unpack2 = load ptr, ptr %next_5_36_123_333_5273_229.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %next_5_36_123_333_5273_229.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %next_5_36_123_333_5273_229.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %next_5_36_123_333_5273_229.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_242(ptr %stackPointer) {
entry:
  %next_5_36_123_333_5273_239.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %next_5_36_123_333_5273_239.unpack2 = load ptr, ptr %next_5_36_123_333_5273_239.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %next_5_36_123_333_5273_239.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %next_5_36_123_333_5273_239.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %next_5_36_123_333_5273_239.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %next_5_36_123_333_5273_239.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %next_5_36_123_333_5273_239.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %next_5_36_123_333_5273_239.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_147(i64 %v_r_2557_6_37_124_334_5038, ptr %stack) {
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
  %v_y_2564_33_91_301_5000_pointer_152 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_152, align 4, !noalias !0
  %z.i.neg = mul i64 %v_y_2564_33_91_301_5000, -503
  %z.i16 = add i64 %z.i.neg, %v_r_2557_6_37_124_334_5038
  %z.i17 = add i64 %z.i16, 37
  %switch.not.not = icmp sgt i64 %z.i17, -1
  %newStackPointer.i85 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %p_2_212_5152_pointer_157.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  %p_2_212_5152.i = load ptr, ptr %p_2_212_5152_pointer_157.i, align 8, !noalias !0
  %next_5_36_123_333_5273.elt4.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  %next_5_36_123_333_5273.unpack5.i = load ptr, ptr %next_5_36_123_333_5273.elt4.i, align 8, !noalias !0
  %next_5_36_123_333_5273_pointer_156.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  %next_5_36_123_333_5273.unpack.i = load i64, ptr %next_5_36_123_333_5273_pointer_156.i, align 8, !noalias !0
  %state_4_4970.elt1.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  %state_4_4970.unpack2.i = load i64, ptr %state_4_4970.elt1.i, align 8, !noalias !0
  %state_4_4970.unpack.i = load ptr, ptr %newStackPointer.i85, align 8, !noalias !0
  br i1 %switch.not.not, label %stackAllocate.exit79, label %stackAllocate.exit119

stackAllocate.exit79:                             ; preds = %stackAllocate.exit
  %z.i127 = urem i64 %z.i17, 1009
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_y_2564_33_91_301_5000, ptr %newStackPointer.i85, align 4, !noalias !0
  %next_5_36_123_333_5273_pointer_216.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store i64 %next_5_36_123_333_5273.unpack.i, ptr %next_5_36_123_333_5273_pointer_216.i, align 8, !noalias !0
  %next_5_36_123_333_5273_pointer_216.repack7.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %next_5_36_123_333_5273.unpack5.i, ptr %next_5_36_123_333_5273_pointer_216.repack7.i, align 8, !noalias !0
  %state_4_4970_pointer_217.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %state_4_4970.unpack.i, ptr %state_4_4970_pointer_217.i, align 8, !noalias !0
  %state_4_4970_pointer_217.repack9.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %state_4_4970.unpack2.i, ptr %state_4_4970_pointer_217.repack9.i, align 8, !noalias !0
  %p_2_212_5152_pointer_218.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %p_2_212_5152.i, ptr %p_2_212_5152_pointer_218.i, align 8, !noalias !0
  %sharer_pointer_220.i = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_221.i = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_159, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_198, ptr %sharer_pointer_220.i, align 8, !noalias !0
  store ptr @eraser_208, ptr %eraser_pointer_221.i, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %state_4_4970.unpack.i, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %state_4_4970.unpack2.i
  store i64 %z.i127, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_225.i = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_225.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

stackAllocate.exit119:                            ; preds = %stackAllocate.exit
  %z.i29 = sub nuw i64 -37, %z.i16
  %z.i120 = srem i64 %z.i29, 1009
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_y_2564_33_91_301_5000, ptr %newStackPointer.i85, align 4, !noalias !0
  %next_5_36_123_333_5273_pointer_216.i57 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store i64 %next_5_36_123_333_5273.unpack.i, ptr %next_5_36_123_333_5273_pointer_216.i57, align 8, !noalias !0
  %next_5_36_123_333_5273_pointer_216.repack7.i58 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %next_5_36_123_333_5273.unpack5.i, ptr %next_5_36_123_333_5273_pointer_216.repack7.i58, align 8, !noalias !0
  %state_4_4970_pointer_217.i59 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %state_4_4970.unpack.i, ptr %state_4_4970_pointer_217.i59, align 8, !noalias !0
  %state_4_4970_pointer_217.repack9.i60 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %state_4_4970.unpack2.i, ptr %state_4_4970_pointer_217.repack9.i60, align 8, !noalias !0
  %p_2_212_5152_pointer_218.i61 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %p_2_212_5152.i, ptr %p_2_212_5152_pointer_218.i61, align 8, !noalias !0
  %sharer_pointer_220.i63 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_221.i64 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_159, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_198, ptr %sharer_pointer_220.i63, align 8, !noalias !0
  store ptr @eraser_208, ptr %eraser_pointer_221.i64, align 8, !noalias !0
  %stack_pointer.i.i92 = getelementptr i8, ptr %state_4_4970.unpack.i, i64 8
  %stack.i.i93 = load ptr, ptr %stack_pointer.i.i92, align 8
  %base_pointer.i94 = getelementptr i8, ptr %stack.i.i93, i64 16
  %base.i95 = load ptr, ptr %base_pointer.i94, align 8
  %varPointer.i96 = getelementptr i8, ptr %base.i95, i64 %state_4_4970.unpack2.i
  store i64 %z.i120, ptr %varPointer.i96, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_225.i67 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_225.i67(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_142(%Pos %next_5_36_123_333_5273, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i12 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i12)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %state_4_4970.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %state_4_4970.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %state_4_4970.unpack2 = load i64, ptr %state_4_4970.elt1, align 8, !noalias !0
  %p_2_212_5152_pointer_145 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %p_2_212_5152 = load ptr, ptr %p_2_212_5152_pointer_145, align 8, !noalias !0
  %v_y_2564_33_91_301_5000_pointer_146 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_146, align 4, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 72
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i16 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i16, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i22 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i16, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %state_4_4970.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_275.repack4 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %state_4_4970.unpack2, ptr %stackPointer_275.repack4, align 8, !noalias !0
  %next_5_36_123_333_5273_pointer_277 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %next_5_36_123_333_5273.elt = extractvalue %Pos %next_5_36_123_333_5273, 0
  store i64 %next_5_36_123_333_5273.elt, ptr %next_5_36_123_333_5273_pointer_277, align 8, !noalias !0
  %next_5_36_123_333_5273_pointer_277.repack6 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %next_5_36_123_333_5273.elt7 = extractvalue %Pos %next_5_36_123_333_5273, 1
  store ptr %next_5_36_123_333_5273.elt7, ptr %next_5_36_123_333_5273_pointer_277.repack6, align 8, !noalias !0
  %p_2_212_5152_pointer_278 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_2_212_5152, ptr %p_2_212_5152_pointer_278, align 8, !noalias !0
  %v_y_2564_33_91_301_5000_pointer_279 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_279, align 4, !noalias !0
  %returnAddress_pointer_280 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_281 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_282 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_147, ptr %returnAddress_pointer_280, align 8, !noalias !0
  store ptr @sharer_232, ptr %sharer_pointer_281, align 8, !noalias !0
  store ptr @eraser_242, ptr %eraser_pointer_282, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %state_4_4970.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i17 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i18 = load ptr, ptr %base_pointer.i17, align 8
  %varPointer.i = getelementptr i8, ptr %base.i18, i64 %state_4_4970.unpack2
  %get_5519 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i23 = icmp ule ptr %nextStackPointer.sink.i, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_285 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_285(i64 %get_5519, ptr nonnull %stack)
  ret void
}

define void @sharer_291(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_299(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_135(%Pos %v_r_2554_4_35_122_332_4963, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i27 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i27)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_y_2563_32_90_300_5006.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_y_2563_32_90_300_5006.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %v_y_2563_32_90_300_5006.unpack2 = load ptr, ptr %v_y_2563_32_90_300_5006.elt1, align 8, !noalias !0
  %state_4_4970_pointer_138 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %state_4_4970.unpack = load ptr, ptr %state_4_4970_pointer_138, align 8, !noalias !0
  %state_4_4970.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %state_4_4970.unpack5 = load i64, ptr %state_4_4970.elt4, align 8, !noalias !0
  %v_y_2565_34_92_302_5148_pointer_139 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_y_2565_34_92_302_5148.unpack = load i64, ptr %v_y_2565_34_92_302_5148_pointer_139, align 8, !noalias !0
  %v_y_2565_34_92_302_5148.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_y_2565_34_92_302_5148.unpack8 = load ptr, ptr %v_y_2565_34_92_302_5148.elt7, align 8, !noalias !0
  %p_2_212_5152_pointer_140 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %p_2_212_5152 = load ptr, ptr %p_2_212_5152_pointer_140, align 8, !noalias !0
  %v_y_2564_33_91_301_5000_pointer_141 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_141, align 4, !noalias !0
  %isInside.not.i = icmp ugt ptr %v_y_2564_33_91_301_5000_pointer_141, %limit.i
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
  %newStackPointer.i31 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i31, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %v_y_2564_33_91_301_5000_pointer_141, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i31, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %state_4_4970.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_304.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %state_4_4970.unpack5, ptr %stackPointer_304.repack10, align 8, !noalias !0
  %p_2_212_5152_pointer_306 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %p_2_212_5152, ptr %p_2_212_5152_pointer_306, align 8, !noalias !0
  %v_y_2564_33_91_301_5000_pointer_307 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_307, align 4, !noalias !0
  %returnAddress_pointer_308 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_309 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_310 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_142, ptr %returnAddress_pointer_308, align 8, !noalias !0
  store ptr @sharer_291, ptr %sharer_pointer_309, align 8, !noalias !0
  store ptr @eraser_299, ptr %eraser_pointer_310, align 8, !noalias !0
  %tag_311 = extractvalue %Pos %v_r_2554_4_35_122_332_4963, 0
  switch i64 %tag_311, label %label_313 [
    i64 0, label %label_317
    i64 1, label %label_321
  ]

label_313:                                        ; preds = %stackAllocate.exit
  ret void

label_317:                                        ; preds = %stackAllocate.exit
  %isNull.i.i12 = icmp eq ptr %v_y_2563_32_90_300_5006.unpack2, null
  br i1 %isNull.i.i12, label %erasePositive.exit22, label %next.i.i13

next.i.i13:                                       ; preds = %label_317
  %referenceCount.i.i14 = load i64, ptr %v_y_2563_32_90_300_5006.unpack2, align 4
  %cond.i.i15 = icmp eq i64 %referenceCount.i.i14, 0
  br i1 %cond.i.i15, label %free.i.i18, label %decr.i.i16

decr.i.i16:                                       ; preds = %next.i.i13
  %referenceCount.1.i.i17 = add i64 %referenceCount.i.i14, -1
  store i64 %referenceCount.1.i.i17, ptr %v_y_2563_32_90_300_5006.unpack2, align 4
  br label %erasePositive.exit22

free.i.i18:                                       ; preds = %next.i.i13
  %objectEraser.i.i19 = getelementptr i8, ptr %v_y_2563_32_90_300_5006.unpack2, i64 8
  %eraser.i.i20 = load ptr, ptr %objectEraser.i.i19, align 8
  %environment.i.i.i21 = getelementptr i8, ptr %v_y_2563_32_90_300_5006.unpack2, i64 16
  tail call void %eraser.i.i20(ptr %environment.i.i.i21)
  tail call void @free(ptr nonnull %v_y_2563_32_90_300_5006.unpack2)
  br label %erasePositive.exit22

erasePositive.exit22:                             ; preds = %label_317, %decr.i.i16, %free.i.i18
  %0 = insertvalue %Pos poison, i64 %v_y_2565_34_92_302_5148.unpack, 0
  %v_y_2565_34_92_302_51489 = insertvalue %Pos %0, ptr %v_y_2565_34_92_302_5148.unpack8, 1
  %stackPointer.i33 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i35 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i36 = icmp ule ptr %stackPointer.i33, %limit.i35
  tail call void @llvm.assume(i1 %isInside.i36)
  %newStackPointer.i37 = getelementptr i8, ptr %stackPointer.i33, i64 -24
  store ptr %newStackPointer.i37, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_314 = load ptr, ptr %newStackPointer.i37, align 8, !noalias !0
  musttail call tailcc void %returnAddress_314(%Pos %v_y_2565_34_92_302_51489, ptr nonnull %stack)
  ret void

label_321:                                        ; preds = %stackAllocate.exit
  %isNull.i.i = icmp eq ptr %v_y_2565_34_92_302_5148.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_321
  %referenceCount.i.i = load i64, ptr %v_y_2565_34_92_302_5148.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_y_2565_34_92_302_5148.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_y_2565_34_92_302_5148.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_y_2565_34_92_302_5148.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_y_2565_34_92_302_5148.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_321, %decr.i.i, %free.i.i
  %1 = insertvalue %Pos poison, i64 %v_y_2563_32_90_300_5006.unpack, 0
  %v_y_2563_32_90_300_50063 = insertvalue %Pos %1, ptr %v_y_2563_32_90_300_5006.unpack2, 1
  %stackPointer.i39 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i41 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i42 = icmp ule ptr %stackPointer.i39, %limit.i41
  tail call void @llvm.assume(i1 %isInside.i42)
  %newStackPointer.i43 = getelementptr i8, ptr %stackPointer.i39, i64 -24
  store ptr %newStackPointer.i43, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_318 = load ptr, ptr %newStackPointer.i43, align 8, !noalias !0
  musttail call tailcc void %returnAddress_318(%Pos %v_y_2563_32_90_300_50063, ptr nonnull %stack)
  ret void
}

define void @sharer_327(ptr %stackPointer) {
entry:
  %v_y_2563_32_90_300_5006_322.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %v_y_2563_32_90_300_5006_322.unpack2 = load ptr, ptr %v_y_2563_32_90_300_5006_322.elt1, align 8, !noalias !0
  %v_y_2565_34_92_302_5148_324.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_y_2565_34_92_302_5148_324.unpack5 = load ptr, ptr %v_y_2565_34_92_302_5148_324.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_y_2563_32_90_300_5006_322.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_y_2563_32_90_300_5006_322.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %v_y_2563_32_90_300_5006_322.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %v_y_2565_34_92_302_5148_324.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %v_y_2565_34_92_302_5148_324.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2565_34_92_302_5148_324.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_339(ptr %stackPointer) {
entry:
  %v_y_2563_32_90_300_5006_334.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %v_y_2563_32_90_300_5006_334.unpack2 = load ptr, ptr %v_y_2563_32_90_300_5006_334.elt1, align 8, !noalias !0
  %v_y_2565_34_92_302_5148_336.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_y_2565_34_92_302_5148_336.unpack5 = load ptr, ptr %v_y_2565_34_92_302_5148_336.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_y_2563_32_90_300_5006_334.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_y_2563_32_90_300_5006_334.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %v_y_2563_32_90_300_5006_334.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %v_y_2563_32_90_300_5006_334.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %v_y_2563_32_90_300_5006_334.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %v_y_2563_32_90_300_5006_334.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %v_y_2565_34_92_302_5148_336.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_y_2565_34_92_302_5148_336.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_y_2565_34_92_302_5148_336.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_y_2565_34_92_302_5148_336.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_y_2565_34_92_302_5148_336.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_y_2565_34_92_302_5148_336.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_364(%Pos %v_r_2990_26_29_121_331_5020, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_r_2573_6_98_308_5209.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2573_6_98_308_5209.unpack, 0
  %v_r_2573_6_98_308_5209.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2573_6_98_308_5209.unpack2 = load ptr, ptr %v_r_2573_6_98_308_5209.elt1, align 8, !noalias !0
  %v_r_2573_6_98_308_52093 = insertvalue %Pos %0, ptr %v_r_2573_6_98_308_5209.unpack2, 1
  musttail call tailcc void @reverseOnto_1019(%Pos %v_r_2990_26_29_121_331_5020, %Pos %v_r_2573_6_98_308_52093, ptr %stack)
  ret void
}

define void @sharer_368(ptr %stackPointer) {
entry:
  %v_r_2573_6_98_308_5209_367.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2573_6_98_308_5209_367.unpack2 = load ptr, ptr %v_r_2573_6_98_308_5209_367.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2573_6_98_308_5209_367.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2573_6_98_308_5209_367.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2573_6_98_308_5209_367.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_372(ptr %stackPointer) {
entry:
  %v_r_2573_6_98_308_5209_371.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2573_6_98_308_5209_371.unpack2 = load ptr, ptr %v_r_2573_6_98_308_5209_371.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2573_6_98_308_5209_371.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2573_6_98_308_5209_371.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2573_6_98_308_5209_371.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2573_6_98_308_5209_371.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2573_6_98_308_5209_371.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2573_6_98_308_5209_371.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_380(%Pos %returnValue_381, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5432.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5432.unpack2 = load ptr, ptr %tmp_5432.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5432.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5432.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5432.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5432.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5432.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5432.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_384 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_384(%Pos %returnValue_381, ptr nonnull %stack)
  ret void
}

define void @eraser_414(ptr nocapture readonly %environment) {
entry:
  %v_y_2855_12_19_20_23_115_325_5151_412.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %v_y_2855_12_19_20_23_115_325_5151_412.unpack2 = load ptr, ptr %v_y_2855_12_19_20_23_115_325_5151_412.elt1, align 8, !noalias !0
  %v_r_2978_2_21_22_25_117_327_5282_413.elt4 = getelementptr i8, ptr %environment, i64 24
  %v_r_2978_2_21_22_25_117_327_5282_413.unpack5 = load ptr, ptr %v_r_2978_2_21_22_25_117_327_5282_413.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_y_2855_12_19_20_23_115_325_5151_412.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_y_2855_12_19_20_23_115_325_5151_412.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %v_y_2855_12_19_20_23_115_325_5151_412.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %v_y_2855_12_19_20_23_115_325_5151_412.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %v_y_2855_12_19_20_23_115_325_5151_412.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %v_y_2855_12_19_20_23_115_325_5151_412.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %v_r_2978_2_21_22_25_117_327_5282_413.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_r_2978_2_21_22_25_117_327_5282_413.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2978_2_21_22_25_117_327_5282_413.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2978_2_21_22_25_117_327_5282_413.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2978_2_21_22_25_117_327_5282_413.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2978_2_21_22_25_117_327_5282_413.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_420(%Pos %__3_14_23_24_27_119_329_5309, ptr %stack) {
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
  %v_y_2856_13_20_21_24_116_326_5051.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_y_2856_13_20_21_24_116_326_5051.unpack2 = load ptr, ptr %v_y_2856_13_20_21_24_116_326_5051.elt1, align 8, !noalias !0
  %res_5_6_9_101_311_5109_pointer_423 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %res_5_6_9_101_311_5109.unpack = load ptr, ptr %res_5_6_9_101_311_5109_pointer_423, align 8, !noalias !0
  %res_5_6_9_101_311_5109.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %res_5_6_9_101_311_5109.unpack5 = load i64, ptr %res_5_6_9_101_311_5109.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__3_14_23_24_27_119_329_5309, 1
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
  %0 = insertvalue %Reference poison, ptr %res_5_6_9_101_311_5109.unpack, 0
  %res_5_6_9_101_311_51096 = insertvalue %Reference %0, i64 %res_5_6_9_101_311_5109.unpack5, 1
  %1 = insertvalue %Pos poison, i64 %v_y_2856_13_20_21_24_116_326_5051.unpack, 0
  %v_y_2856_13_20_21_24_116_326_50513 = insertvalue %Pos %1, ptr %v_y_2856_13_20_21_24_116_326_5051.unpack2, 1
  musttail call tailcc void @foreach_worker_5_10_11_14_106_316_5235(%Pos %v_y_2856_13_20_21_24_116_326_50513, %Reference %res_5_6_9_101_311_51096, ptr nonnull %stack)
  ret void
}

define void @sharer_426(ptr %stackPointer) {
entry:
  %v_y_2856_13_20_21_24_116_326_5051_424.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_y_2856_13_20_21_24_116_326_5051_424.unpack2 = load ptr, ptr %v_y_2856_13_20_21_24_116_326_5051_424.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2856_13_20_21_24_116_326_5051_424.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_y_2856_13_20_21_24_116_326_5051_424.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2856_13_20_21_24_116_326_5051_424.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_432(ptr %stackPointer) {
entry:
  %v_y_2856_13_20_21_24_116_326_5051_430.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_y_2856_13_20_21_24_116_326_5051_430.unpack2 = load ptr, ptr %v_y_2856_13_20_21_24_116_326_5051_430.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2856_13_20_21_24_116_326_5051_430.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_y_2856_13_20_21_24_116_326_5051_430.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_y_2856_13_20_21_24_116_326_5051_430.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_y_2856_13_20_21_24_116_326_5051_430.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_y_2856_13_20_21_24_116_326_5051_430.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_y_2856_13_20_21_24_116_326_5051_430.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_405(%Pos %v_r_2978_2_21_22_25_117_327_5282, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i28 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_y_2855_12_19_20_23_115_325_5151.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_y_2855_12_19_20_23_115_325_5151.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_y_2855_12_19_20_23_115_325_5151.unpack2 = load ptr, ptr %v_y_2855_12_19_20_23_115_325_5151.elt1, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051_pointer_408 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_y_2856_13_20_21_24_116_326_5051.unpack = load i64, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_408, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_y_2856_13_20_21_24_116_326_5051.unpack5 = load ptr, ptr %v_y_2856_13_20_21_24_116_326_5051.elt4, align 8, !noalias !0
  %res_5_6_9_101_311_5109_pointer_409 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %res_5_6_9_101_311_5109.unpack = load ptr, ptr %res_5_6_9_101_311_5109_pointer_409, align 8, !noalias !0
  %res_5_6_9_101_311_5109.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %res_5_6_9_101_311_5109.unpack8 = load i64, ptr %res_5_6_9_101_311_5109.elt7, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_414, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2855_12_19_20_23_115_325_5151.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_411.repack10 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2855_12_19_20_23_115_325_5151.unpack2, ptr %environment_411.repack10, align 8, !noalias !0
  %v_r_2978_2_21_22_25_117_327_5282_pointer_418 = getelementptr i8, ptr %object.i, i64 32
  %v_r_2978_2_21_22_25_117_327_5282.elt = extractvalue %Pos %v_r_2978_2_21_22_25_117_327_5282, 0
  store i64 %v_r_2978_2_21_22_25_117_327_5282.elt, ptr %v_r_2978_2_21_22_25_117_327_5282_pointer_418, align 8, !noalias !0
  %v_r_2978_2_21_22_25_117_327_5282_pointer_418.repack12 = getelementptr i8, ptr %object.i, i64 40
  %v_r_2978_2_21_22_25_117_327_5282.elt13 = extractvalue %Pos %v_r_2978_2_21_22_25_117_327_5282, 1
  store ptr %v_r_2978_2_21_22_25_117_327_5282.elt13, ptr %v_r_2978_2_21_22_25_117_327_5282_pointer_418.repack12, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 8
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
  %newStackPointer.i32 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i32, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i32, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_y_2856_13_20_21_24_116_326_5051.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_436.repack14 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %v_y_2856_13_20_21_24_116_326_5051.unpack5, ptr %stackPointer_436.repack14, align 8, !noalias !0
  %res_5_6_9_101_311_5109_pointer_438 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %res_5_6_9_101_311_5109.unpack, ptr %res_5_6_9_101_311_5109_pointer_438, align 8, !noalias !0
  %res_5_6_9_101_311_5109_pointer_438.repack16 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %res_5_6_9_101_311_5109.unpack8, ptr %res_5_6_9_101_311_5109_pointer_438.repack16, align 8, !noalias !0
  %returnAddress_pointer_439 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_440 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_441 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_420, ptr %returnAddress_pointer_439, align 8, !noalias !0
  store ptr @sharer_426, ptr %sharer_pointer_440, align 8, !noalias !0
  store ptr @eraser_432, ptr %eraser_pointer_441, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %res_5_6_9_101_311_5109.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i33 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i34 = load ptr, ptr %base_pointer.i33, align 8
  %varPointer.i = getelementptr i8, ptr %base.i34, i64 %res_5_6_9_101_311_5109.unpack8
  %res_5_6_9_101_311_5109_old_443.elt18 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %res_5_6_9_101_311_5109_old_443.unpack19 = load ptr, ptr %res_5_6_9_101_311_5109_old_443.elt18, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %res_5_6_9_101_311_5109_old_443.unpack19, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %res_5_6_9_101_311_5109_old_443.unpack19, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %res_5_6_9_101_311_5109_old_443.unpack19, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %res_5_6_9_101_311_5109_old_443.unpack19, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %res_5_6_9_101_311_5109_old_443.unpack19, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %res_5_6_9_101_311_5109_old_443.unpack19)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %stackAllocate.exit, %decr.i.i, %free.i.i
  store i64 1, ptr %varPointer.i, align 8, !noalias !0
  store ptr %object.i, ptr %res_5_6_9_101_311_5109_old_443.elt18, align 8, !noalias !0
  %stackPointer.i36 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i39 = icmp ule ptr %stackPointer.i36, %limit.i38
  tail call void @llvm.assume(i1 %isInside.i39)
  %newStackPointer.i40 = getelementptr i8, ptr %stackPointer.i36, i64 -24
  store ptr %newStackPointer.i40, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_445 = load ptr, ptr %newStackPointer.i40, align 8, !noalias !0
  musttail call tailcc void %returnAddress_445(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_451(ptr %stackPointer) {
entry:
  %v_y_2855_12_19_20_23_115_325_5151_448.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_y_2855_12_19_20_23_115_325_5151_448.unpack2 = load ptr, ptr %v_y_2855_12_19_20_23_115_325_5151_448.elt1, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051_449.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_y_2856_13_20_21_24_116_326_5051_449.unpack5 = load ptr, ptr %v_y_2856_13_20_21_24_116_326_5051_449.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_y_2855_12_19_20_23_115_325_5151_448.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_y_2855_12_19_20_23_115_325_5151_448.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %v_y_2855_12_19_20_23_115_325_5151_448.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %v_y_2856_13_20_21_24_116_326_5051_449.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %v_y_2856_13_20_21_24_116_326_5051_449.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2856_13_20_21_24_116_326_5051_449.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_459(ptr %stackPointer) {
entry:
  %v_y_2855_12_19_20_23_115_325_5151_456.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_y_2855_12_19_20_23_115_325_5151_456.unpack2 = load ptr, ptr %v_y_2855_12_19_20_23_115_325_5151_456.elt1, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051_457.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_y_2856_13_20_21_24_116_326_5051_457.unpack5 = load ptr, ptr %v_y_2856_13_20_21_24_116_326_5051_457.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_y_2855_12_19_20_23_115_325_5151_456.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_y_2855_12_19_20_23_115_325_5151_456.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %v_y_2855_12_19_20_23_115_325_5151_456.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %v_y_2855_12_19_20_23_115_325_5151_456.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %v_y_2855_12_19_20_23_115_325_5151_456.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %v_y_2855_12_19_20_23_115_325_5151_456.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %v_y_2856_13_20_21_24_116_326_5051_457.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_y_2856_13_20_21_24_116_326_5051_457.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_y_2856_13_20_21_24_116_326_5051_457.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_y_2856_13_20_21_24_116_326_5051_457.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_y_2856_13_20_21_24_116_326_5051_457.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_y_2856_13_20_21_24_116_326_5051_457.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @foreach_worker_5_10_11_14_106_316_5235(%Pos %l_6_11_12_15_107_317_5039, %Reference %res_5_6_9_101_311_5109, ptr %stack) local_unnamed_addr {
entry:
  %tag_394 = extractvalue %Pos %l_6_11_12_15_107_317_5039, 0
  switch i64 %tag_394, label %label_396 [
    i64 0, label %label_401
    i64 1, label %label_476
  ]

label_396:                                        ; preds = %entry
  ret void

label_401:                                        ; preds = %entry
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_398 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_398(%Pos zeroinitializer, ptr %stack)
  ret void

label_476:                                        ; preds = %entry
  %fields_395 = extractvalue %Pos %l_6_11_12_15_107_317_5039, 1
  %environment.i = getelementptr i8, ptr %fields_395, i64 16
  %v_y_2855_12_19_20_23_115_325_5151.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_2855_12_19_20_23_115_325_5151.elt1 = getelementptr i8, ptr %fields_395, i64 24
  %v_y_2855_12_19_20_23_115_325_5151.unpack2 = load ptr, ptr %v_y_2855_12_19_20_23_115_325_5151.elt1, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051_pointer_404 = getelementptr i8, ptr %fields_395, i64 32
  %v_y_2856_13_20_21_24_116_326_5051.unpack = load i64, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_404, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051.elt4 = getelementptr i8, ptr %fields_395, i64 40
  %v_y_2856_13_20_21_24_116_326_5051.unpack5 = load ptr, ptr %v_y_2856_13_20_21_24_116_326_5051.elt4, align 8, !noalias !0
  %isNull.i.i24 = icmp eq ptr %v_y_2855_12_19_20_23_115_325_5151.unpack2, null
  br i1 %isNull.i.i24, label %sharePositive.exit28, label %next.i.i25

next.i.i25:                                       ; preds = %label_476
  %referenceCount.i.i26 = load i64, ptr %v_y_2855_12_19_20_23_115_325_5151.unpack2, align 4
  %referenceCount.1.i.i27 = add i64 %referenceCount.i.i26, 1
  store i64 %referenceCount.1.i.i27, ptr %v_y_2855_12_19_20_23_115_325_5151.unpack2, align 4
  br label %sharePositive.exit28

sharePositive.exit28:                             ; preds = %label_476, %next.i.i25
  %isNull.i.i19 = icmp eq ptr %v_y_2856_13_20_21_24_116_326_5051.unpack5, null
  br i1 %isNull.i.i19, label %next.i, label %next.i.i20

next.i.i20:                                       ; preds = %sharePositive.exit28
  %referenceCount.i.i21 = load i64, ptr %v_y_2856_13_20_21_24_116_326_5051.unpack5, align 4
  %referenceCount.1.i.i22 = add i64 %referenceCount.i.i21, 1
  store i64 %referenceCount.1.i.i22, ptr %v_y_2856_13_20_21_24_116_326_5051.unpack5, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i20, %sharePositive.exit28
  %referenceCount.i = load i64, ptr %fields_395, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_395, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_395, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_395)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %stackPointer_pointer.i29 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i30 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i29, align 8, !alias.scope !0
  %limit.i31 = load ptr, ptr %limit_pointer.i30, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i31
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
  %newStackPointer.i32 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i32, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i30, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit, %realloc.i
  %limit.i3844 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i31, %eraseObject.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i32, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i29, align 8
  store i64 %v_y_2855_12_19_20_23_115_325_5151.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_464.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %v_y_2855_12_19_20_23_115_325_5151.unpack2, ptr %stackPointer_464.repack7, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051_pointer_466 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %v_y_2856_13_20_21_24_116_326_5051.unpack, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_466, align 8, !noalias !0
  %v_y_2856_13_20_21_24_116_326_5051_pointer_466.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %v_y_2856_13_20_21_24_116_326_5051.unpack5, ptr %v_y_2856_13_20_21_24_116_326_5051_pointer_466.repack9, align 8, !noalias !0
  %res_5_6_9_101_311_5109_pointer_467 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %res_5_6_9_101_311_5109.elt = extractvalue %Reference %res_5_6_9_101_311_5109, 0
  store ptr %res_5_6_9_101_311_5109.elt, ptr %res_5_6_9_101_311_5109_pointer_467, align 8, !noalias !0
  %res_5_6_9_101_311_5109_pointer_467.repack11 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %res_5_6_9_101_311_5109.elt12 = extractvalue %Reference %res_5_6_9_101_311_5109, 1
  store i64 %res_5_6_9_101_311_5109.elt12, ptr %res_5_6_9_101_311_5109_pointer_467.repack11, align 8, !noalias !0
  %returnAddress_pointer_468 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_469 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_470 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_405, ptr %returnAddress_pointer_468, align 8, !noalias !0
  store ptr @sharer_451, ptr %sharer_pointer_469, align 8, !noalias !0
  store ptr @eraser_459, ptr %eraser_pointer_470, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %res_5_6_9_101_311_5109.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i33 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i34 = load ptr, ptr %base_pointer.i33, align 8
  %varPointer.i = getelementptr i8, ptr %base.i34, i64 %res_5_6_9_101_311_5109.elt12
  %res_5_6_9_101_311_5109_old_472.elt13 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %res_5_6_9_101_311_5109_old_472.unpack14 = load ptr, ptr %res_5_6_9_101_311_5109_old_472.elt13, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %res_5_6_9_101_311_5109_old_472.unpack14, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %res_5_6_9_101_311_5109_old_472.unpack14, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %res_5_6_9_101_311_5109_old_472.unpack14, align 4
  %get_5525.unpack17.pre = load ptr, ptr %res_5_6_9_101_311_5109_old_472.elt13, align 8, !noalias !0
  %stackPointer.i36.pre = load ptr, ptr %stackPointer_pointer.i29, align 8, !alias.scope !0
  %limit.i38.pre = load ptr, ptr %limit_pointer.i30, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i38 = phi ptr [ %limit.i3844, %stackAllocate.exit ], [ %limit.i38.pre, %next.i.i ]
  %stackPointer.i36 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i36.pre, %next.i.i ]
  %get_5525.unpack17 = phi ptr [ null, %stackAllocate.exit ], [ %get_5525.unpack17.pre, %next.i.i ]
  %get_5525.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5525.unpack, 0
  %get_552518 = insertvalue %Pos %0, ptr %get_5525.unpack17, 1
  %isInside.i39 = icmp ule ptr %stackPointer.i36, %limit.i38
  tail call void @llvm.assume(i1 %isInside.i39)
  %newStackPointer.i40 = getelementptr i8, ptr %stackPointer.i36, i64 -24
  store ptr %newStackPointer.i40, ptr %stackPointer_pointer.i29, align 8, !alias.scope !0
  %returnAddress_473 = load ptr, ptr %newStackPointer.i40, align 8, !noalias !0
  musttail call tailcc void %returnAddress_473(%Pos %get_552518, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_477(%Pos %__24_25_28_120_330_5310, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i18 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i18)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %res_5_6_9_101_311_5109.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %res_5_6_9_101_311_5109.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %res_5_6_9_101_311_5109.unpack2 = load i64, ptr %res_5_6_9_101_311_5109.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__24_25_28_120_330_5310, 1
  %isNull.i.i10 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i10, label %erasePositive.exit, label %next.i.i11

next.i.i11:                                       ; preds = %entry
  %referenceCount.i.i12 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i12, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i11
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i12, -1
  store i64 %referenceCount.1.i.i13, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i11
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stack_pointer.i.i = getelementptr i8, ptr %res_5_6_9_101_311_5109.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %res_5_6_9_101_311_5109.unpack2
  %res_5_6_9_101_311_5109_old_481.elt4 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %res_5_6_9_101_311_5109_old_481.unpack5 = load ptr, ptr %res_5_6_9_101_311_5109_old_481.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %res_5_6_9_101_311_5109_old_481.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %res_5_6_9_101_311_5109_old_481.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %res_5_6_9_101_311_5109_old_481.unpack5, align 4
  %get_5526.unpack8.pre = load ptr, ptr %res_5_6_9_101_311_5109_old_481.elt4, align 8, !noalias !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %get_5526.unpack8 = phi ptr [ null, %erasePositive.exit ], [ %get_5526.unpack8.pre, %next.i.i ]
  %get_5526.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5526.unpack, 0
  %get_55269 = insertvalue %Pos %0, ptr %get_5526.unpack8, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_482 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_482(%Pos %get_55269, ptr nonnull %stack)
  ret void
}

define void @sharer_486(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_490(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_360(%Pos %v_r_2573_6_98_308_5209, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i9 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i10, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i15 = icmp ule ptr %stackPointer.i10, %limit.i
  tail call void @llvm.assume(i1 %isInside.i15)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i10, i64 -16
  %v_r_2572_5_97_307_5127.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2572_5_97_307_5127.elt1 = getelementptr i8, ptr %stackPointer.i10, i64 -8
  %v_r_2572_5_97_307_5127.unpack2 = load ptr, ptr %v_r_2572_5_97_307_5127.elt1, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i9, align 8
  %v_r_2573_6_98_308_5209.elt = extractvalue %Pos %v_r_2573_6_98_308_5209, 0
  store i64 %v_r_2573_6_98_308_5209.elt, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_375.repack4 = getelementptr i8, ptr %stackPointer.i10, i64 -8
  %v_r_2573_6_98_308_5209.elt5 = extractvalue %Pos %v_r_2573_6_98_308_5209, 1
  store ptr %v_r_2573_6_98_308_5209.elt5, ptr %stackPointer_375.repack4, align 8, !noalias !0
  %sharer_pointer_378 = getelementptr i8, ptr %stackPointer.i10, i64 8
  %eraser_pointer_379 = getelementptr i8, ptr %stackPointer.i10, i64 16
  store ptr @returnAddress_364, ptr %stackPointer.i10, align 8, !noalias !0
  store ptr @sharer_368, ptr %sharer_pointer_378, align 8, !noalias !0
  store ptr @eraser_372, ptr %eraser_pointer_379, align 8, !noalias !0
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i9, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i23 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i28 = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i29 = icmp ugt ptr %nextStackPointer.i28, %limit.i
  br i1 %isInside.not.i29, label %realloc.i32, label %stackAllocate.exit46

realloc.i32:                                      ; preds = %stackAllocate.exit
  %nextSize.i38 = add i64 %offset.i, 40
  %leadingZeros.i.i39 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i38, i1 false)
  %numBits.i.i40 = sub nuw nsw i64 64, %leadingZeros.i.i39
  %result.i.i41 = shl nuw i64 1, %numBits.i.i40
  %newBase.i42 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i41)
  %newLimit.i43 = getelementptr i8, ptr %newBase.i42, i64 %result.i.i41
  %newStackPointer.i44 = getelementptr i8, ptr %newBase.i42, i64 %offset.i
  %newNextStackPointer.i45 = getelementptr i8, ptr %newStackPointer.i44, i64 40
  store ptr %newBase.i42, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i43, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit46

stackAllocate.exit46:                             ; preds = %stackAllocate.exit, %realloc.i32
  %base.i57 = phi ptr [ %newBase.i42, %realloc.i32 ], [ %base.i, %stackAllocate.exit ]
  %limit.i50 = phi ptr [ %newLimit.i43, %realloc.i32 ], [ %limit.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i30 = phi ptr [ %newNextStackPointer.i45, %realloc.i32 ], [ %nextStackPointer.i28, %stackAllocate.exit ]
  %common.ret.op.i31 = phi ptr [ %newStackPointer.i44, %realloc.i32 ], [ %stackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i30, ptr %stackPointer_pointer.i9, align 8
  %returnAddress_pointer_391 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %sharer_pointer_392 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  %eraser_pointer_393 = getelementptr i8, ptr %common.ret.op.i31, i64 32
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %common.ret.op.i31, i8 0, i64 16, i1 false)
  store ptr @returnAddress_380, ptr %returnAddress_pointer_391, align 8, !noalias !0
  store ptr @sharer_368, ptr %sharer_pointer_392, align 8, !noalias !0
  store ptr @eraser_372, ptr %eraser_pointer_393, align 8, !noalias !0
  %nextStackPointer.i51 = getelementptr i8, ptr %nextStackPointer.sink.i30, i64 40
  %isInside.not.i52 = icmp ugt ptr %nextStackPointer.i51, %limit.i50
  br i1 %isInside.not.i52, label %realloc.i55, label %stackAllocate.exit69

realloc.i55:                                      ; preds = %stackAllocate.exit46
  %intStackPointer.i58 = ptrtoint ptr %nextStackPointer.sink.i30 to i64
  %intBase.i59 = ptrtoint ptr %base.i57 to i64
  %size.i60 = sub i64 %intStackPointer.i58, %intBase.i59
  %nextSize.i61 = add i64 %size.i60, 40
  %leadingZeros.i.i62 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i61, i1 false)
  %numBits.i.i63 = sub nuw nsw i64 64, %leadingZeros.i.i62
  %result.i.i64 = shl nuw i64 1, %numBits.i.i63
  %newBase.i65 = tail call ptr @realloc(ptr %base.i57, i64 %result.i.i64)
  %newLimit.i66 = getelementptr i8, ptr %newBase.i65, i64 %result.i.i64
  %newStackPointer.i67 = getelementptr i8, ptr %newBase.i65, i64 %size.i60
  %newNextStackPointer.i68 = getelementptr i8, ptr %newStackPointer.i67, i64 40
  store ptr %newBase.i65, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i66, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit69

stackAllocate.exit69:                             ; preds = %stackAllocate.exit46, %realloc.i55
  %nextStackPointer.sink.i53 = phi ptr [ %newNextStackPointer.i68, %realloc.i55 ], [ %nextStackPointer.i51, %stackAllocate.exit46 ]
  %common.ret.op.i54 = phi ptr [ %newStackPointer.i67, %realloc.i55 ], [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ]
  %reference..1.i = insertvalue %Reference undef, ptr %prompt.i23, 0
  %reference.i = insertvalue %Reference %reference..1.i, i64 %offset.i, 1
  %0 = insertvalue %Pos poison, i64 %v_r_2572_5_97_307_5127.unpack, 0
  %v_r_2572_5_97_307_51273 = insertvalue %Pos %0, ptr %v_r_2572_5_97_307_5127.unpack2, 1
  store ptr %nextStackPointer.sink.i53, ptr %stackPointer_pointer.i9, align 8
  store ptr %prompt.i23, ptr %common.ret.op.i54, align 8, !noalias !0
  %stackPointer_493.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i54, i64 8
  store i64 %offset.i, ptr %stackPointer_493.repack7, align 8, !noalias !0
  %returnAddress_pointer_495 = getelementptr i8, ptr %common.ret.op.i54, i64 16
  %sharer_pointer_496 = getelementptr i8, ptr %common.ret.op.i54, i64 24
  %eraser_pointer_497 = getelementptr i8, ptr %common.ret.op.i54, i64 32
  store ptr @returnAddress_477, ptr %returnAddress_pointer_495, align 8, !noalias !0
  store ptr @sharer_486, ptr %sharer_pointer_496, align 8, !noalias !0
  store ptr @eraser_490, ptr %eraser_pointer_497, align 8, !noalias !0
  musttail call tailcc void @foreach_worker_5_10_11_14_106_316_5235(%Pos %v_r_2572_5_97_307_51273, %Reference %reference.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_357(%Pos %v_r_2572_5_97_307_5127, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %k_2_94_304_5007 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i11 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i11, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i11, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %v_r_2572_5_97_307_5127.elt = extractvalue %Pos %v_r_2572_5_97_307_5127, 0
  store i64 %v_r_2572_5_97_307_5127.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_500.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %v_r_2572_5_97_307_5127.elt2 = extractvalue %Pos %v_r_2572_5_97_307_5127, 1
  store ptr %v_r_2572_5_97_307_5127.elt2, ptr %stackPointer_500.repack1, align 8, !noalias !0
  %returnAddress_pointer_502 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_503 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_504 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_360, ptr %returnAddress_pointer_502, align 8, !noalias !0
  store ptr @sharer_368, ptr %sharer_pointer_503, align 8, !noalias !0
  store ptr @eraser_372, ptr %eraser_pointer_504, align 8, !noalias !0
  %stack_505 = tail call fastcc ptr @resume(ptr %k_2_94_304_5007, ptr nonnull %stack)
  %stackPointer_pointer.i12 = getelementptr i8, ptr %stack_505, i64 8
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i12, align 8, !alias.scope !0
  %limit_pointer.i14 = getelementptr i8, ptr %stack_505, i64 24
  %limit.i15 = load ptr, ptr %limit_pointer.i14, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i12, align 8, !alias.scope !0
  %returnAddress_507 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_507(%Pos zeroinitializer, ptr %stack_505)
  ret void
}

define void @sharer_511(ptr %stackPointer) {
entry:
  %stackPointer_512 = getelementptr i8, ptr %stackPointer, i64 -8
  %k_2_94_304_5007_510 = load ptr, ptr %stackPointer_512, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %k_2_94_304_5007_510, align 4
  %referenceCount.1.i = add i64 %referenceCount.i, 1
  store i64 %referenceCount.1.i, ptr %k_2_94_304_5007_510, align 4
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_515(ptr %stackPointer) {
entry:
  %stackPointer_516 = getelementptr i8, ptr %stackPointer, i64 -8
  %k_2_94_304_5007_514 = load ptr, ptr %stackPointer_516, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %k_2_94_304_5007_514, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %entry
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_2_94_304_5007_514, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %entry
  %stack_pointer.i = getelementptr i8, ptr %k_2_94_304_5007_514, i64 40
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

define tailcc void @explore_worker_4_33_243_4974(%Pos %t_5_34_244_5104, %Reference %state_4_4970, ptr %p_2_212_5152, ptr %stack) local_unnamed_addr {
entry:
  %tag_122 = extractvalue %Pos %t_5_34_244_5104, 0
  switch i64 %tag_122, label %label_124 [
    i64 0, label %label_130
    i64 1, label %label_528
  ]

label_124:                                        ; preds = %entry
  ret void

label_130:                                        ; preds = %entry
  %prompt.i = extractvalue %Reference %state_4_4970, 0
  %offset.i = extractvalue %Reference %state_4_4970, 1
  %stack_pointer.i.i = getelementptr i8, ptr %prompt.i, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %offset.i
  %get_5495 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_127 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_127(i64 %get_5495, ptr %stack)
  ret void

label_528:                                        ; preds = %entry
  %fields_123 = extractvalue %Pos %t_5_34_244_5104, 1
  %environment.i = getelementptr i8, ptr %fields_123, i64 16
  %v_y_2563_32_90_300_5006.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_2563_32_90_300_5006.elt1 = getelementptr i8, ptr %fields_123, i64 24
  %v_y_2563_32_90_300_5006.unpack2 = load ptr, ptr %v_y_2563_32_90_300_5006.elt1, align 8, !noalias !0
  %v_y_2564_33_91_301_5000_pointer_133 = getelementptr i8, ptr %fields_123, i64 32
  %v_y_2564_33_91_301_5000 = load i64, ptr %v_y_2564_33_91_301_5000_pointer_133, align 4, !noalias !0
  %v_y_2565_34_92_302_5148_pointer_134 = getelementptr i8, ptr %fields_123, i64 40
  %v_y_2565_34_92_302_5148.unpack = load i64, ptr %v_y_2565_34_92_302_5148_pointer_134, align 8, !noalias !0
  %v_y_2565_34_92_302_5148.elt4 = getelementptr i8, ptr %fields_123, i64 48
  %v_y_2565_34_92_302_5148.unpack5 = load ptr, ptr %v_y_2565_34_92_302_5148.elt4, align 8, !noalias !0
  %isNull.i.i13 = icmp eq ptr %v_y_2563_32_90_300_5006.unpack2, null
  br i1 %isNull.i.i13, label %sharePositive.exit17, label %next.i.i14

next.i.i14:                                       ; preds = %label_528
  %referenceCount.i.i15 = load i64, ptr %v_y_2563_32_90_300_5006.unpack2, align 4
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i15, 1
  store i64 %referenceCount.1.i.i16, ptr %v_y_2563_32_90_300_5006.unpack2, align 4
  br label %sharePositive.exit17

sharePositive.exit17:                             ; preds = %label_528, %next.i.i14
  %isNull.i.i = icmp eq ptr %v_y_2565_34_92_302_5148.unpack5, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_y_2565_34_92_302_5148.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2565_34_92_302_5148.unpack5, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %sharePositive.exit17
  %referenceCount.i = load i64, ptr %fields_123, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_123, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_123, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_123)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %stackPointer_pointer.i20 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i21 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i20, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i21, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i22
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit
  %base_pointer.i23 = getelementptr i8, ptr %stack, i64 16
  %base.i24 = load ptr, ptr %base_pointer.i23, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i24 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 88
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i24, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i25 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i25, i64 88
  store ptr %newBase.i, ptr %base_pointer.i23, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i21, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i25, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i20, align 8
  store i64 %v_y_2563_32_90_300_5006.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_346.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %v_y_2563_32_90_300_5006.unpack2, ptr %stackPointer_346.repack7, align 8, !noalias !0
  %state_4_4970_pointer_348 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %state_4_4970.elt = extractvalue %Reference %state_4_4970, 0
  store ptr %state_4_4970.elt, ptr %state_4_4970_pointer_348, align 8, !noalias !0
  %state_4_4970_pointer_348.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %state_4_4970.elt10 = extractvalue %Reference %state_4_4970, 1
  store i64 %state_4_4970.elt10, ptr %state_4_4970_pointer_348.repack9, align 8, !noalias !0
  %v_y_2565_34_92_302_5148_pointer_349 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %v_y_2565_34_92_302_5148.unpack, ptr %v_y_2565_34_92_302_5148_pointer_349, align 8, !noalias !0
  %v_y_2565_34_92_302_5148_pointer_349.repack11 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %v_y_2565_34_92_302_5148.unpack5, ptr %v_y_2565_34_92_302_5148_pointer_349.repack11, align 8, !noalias !0
  %p_2_212_5152_pointer_350 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %p_2_212_5152, ptr %p_2_212_5152_pointer_350, align 8, !noalias !0
  %v_y_2564_33_91_301_5000_pointer_351 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %v_y_2564_33_91_301_5000, ptr %v_y_2564_33_91_301_5000_pointer_351, align 4, !noalias !0
  %returnAddress_pointer_352 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_353 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_354 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_135, ptr %returnAddress_pointer_352, align 8, !noalias !0
  store ptr @sharer_327, ptr %sharer_pointer_353, align 8, !noalias !0
  store ptr @eraser_339, ptr %eraser_pointer_354, align 8, !noalias !0
  %pair_355 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_2_212_5152)
  %k_2_94_304_5007 = extractvalue <{ ptr, ptr }> %pair_355, 0
  %stack_356 = extractvalue <{ ptr, ptr }> %pair_355, 1
  %referenceCount.i18 = load i64, ptr %k_2_94_304_5007, align 4
  %referenceCount.1.i19 = add i64 %referenceCount.i18, 1
  store i64 %referenceCount.1.i19, ptr %k_2_94_304_5007, align 4
  %stackPointer_pointer.i26 = getelementptr i8, ptr %stack_356, i64 8
  %limit_pointer.i27 = getelementptr i8, ptr %stack_356, i64 24
  %currentStackPointer.i28 = load ptr, ptr %stackPointer_pointer.i26, align 8, !alias.scope !0
  %limit.i29 = load ptr, ptr %limit_pointer.i27, align 8, !alias.scope !0
  %nextStackPointer.i30 = getelementptr i8, ptr %currentStackPointer.i28, i64 32
  %isInside.not.i31 = icmp ugt ptr %nextStackPointer.i30, %limit.i29
  br i1 %isInside.not.i31, label %realloc.i34, label %stackAllocate.exit48

realloc.i34:                                      ; preds = %stackAllocate.exit
  %base_pointer.i35 = getelementptr i8, ptr %stack_356, i64 16
  %base.i36 = load ptr, ptr %base_pointer.i35, align 8, !alias.scope !0
  %intStackPointer.i37 = ptrtoint ptr %currentStackPointer.i28 to i64
  %intBase.i38 = ptrtoint ptr %base.i36 to i64
  %size.i39 = sub i64 %intStackPointer.i37, %intBase.i38
  %nextSize.i40 = add i64 %size.i39, 32
  %leadingZeros.i.i41 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i40, i1 false)
  %numBits.i.i42 = sub nuw nsw i64 64, %leadingZeros.i.i41
  %result.i.i43 = shl nuw i64 1, %numBits.i.i42
  %newBase.i44 = tail call ptr @realloc(ptr %base.i36, i64 %result.i.i43)
  %newLimit.i45 = getelementptr i8, ptr %newBase.i44, i64 %result.i.i43
  %newStackPointer.i46 = getelementptr i8, ptr %newBase.i44, i64 %size.i39
  %newNextStackPointer.i47 = getelementptr i8, ptr %newStackPointer.i46, i64 32
  store ptr %newBase.i44, ptr %base_pointer.i35, align 8, !alias.scope !0
  store ptr %newLimit.i45, ptr %limit_pointer.i27, align 8, !alias.scope !0
  br label %stackAllocate.exit48

stackAllocate.exit48:                             ; preds = %stackAllocate.exit, %realloc.i34
  %nextStackPointer.sink.i32 = phi ptr [ %newNextStackPointer.i47, %realloc.i34 ], [ %nextStackPointer.i30, %stackAllocate.exit ]
  %common.ret.op.i33 = phi ptr [ %newStackPointer.i46, %realloc.i34 ], [ %currentStackPointer.i28, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i32, ptr %stackPointer_pointer.i26, align 8
  store ptr %k_2_94_304_5007, ptr %common.ret.op.i33, align 8, !noalias !0
  %returnAddress_pointer_520 = getelementptr i8, ptr %common.ret.op.i33, i64 8
  %sharer_pointer_521 = getelementptr i8, ptr %common.ret.op.i33, i64 16
  %eraser_pointer_522 = getelementptr i8, ptr %common.ret.op.i33, i64 24
  store ptr @returnAddress_357, ptr %returnAddress_pointer_520, align 8, !noalias !0
  store ptr @sharer_511, ptr %sharer_pointer_521, align 8, !noalias !0
  store ptr @eraser_515, ptr %eraser_pointer_522, align 8, !noalias !0
  %stack_523 = tail call fastcc ptr @resume(ptr nonnull %k_2_94_304_5007, ptr nonnull %stack_356)
  %stackPointer_pointer.i49 = getelementptr i8, ptr %stack_523, i64 8
  %stackPointer.i50 = load ptr, ptr %stackPointer_pointer.i49, align 8, !alias.scope !0
  %limit_pointer.i51 = getelementptr i8, ptr %stack_523, i64 24
  %limit.i52 = load ptr, ptr %limit_pointer.i51, align 8, !alias.scope !0
  %isInside.i53 = icmp ule ptr %stackPointer.i50, %limit.i52
  tail call void @llvm.assume(i1 %isInside.i53)
  %newStackPointer.i54 = getelementptr i8, ptr %stackPointer.i50, i64 -24
  store ptr %newStackPointer.i54, ptr %stackPointer_pointer.i49, align 8, !alias.scope !0
  %returnAddress_525 = load ptr, ptr %newStackPointer.i54, align 8, !noalias !0
  musttail call tailcc void %returnAddress_525(%Pos { i64 1, ptr null }, ptr %stack_523)
  ret void
}

define tailcc void @returnAddress_529(i64 %v_r_2577_143_353_5098, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_414, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_r_2577_143_353_5098, ptr %environment.i, align 8, !noalias !0
  %environment_532.repack1 = getelementptr i8, ptr %object.i, i64 24
  %make_5531 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i8 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %environment_532.repack1, i8 0, i64 24, i1 false)
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_538 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_538(%Pos %make_5531, ptr %stack)
  ret void
}

define tailcc void @loop_208_5045(i64 %i_209_5097, %Reference %state_4_4970, %Pos %tree_2_5241, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp eq i64 %i_209_5097, 0
  %object.i5 = extractvalue %Pos %tree_2_5241, 1
  %isNull.i.i6 = icmp eq ptr %object.i5, null
  br i1 %z.i, label %label_551, label %label_545

label_545:                                        ; preds = %entry
  br i1 %isNull.i.i6, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_545
  %referenceCount.i.i = load i64, ptr %object.i5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_545, %next.i.i
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
  store i64 %i_209_5097, ptr %common.ret.op.i, align 4, !noalias !0
  %state_4_4970_pointer_103 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %state_4_4970.elt = extractvalue %Reference %state_4_4970, 0
  store ptr %state_4_4970.elt, ptr %state_4_4970_pointer_103, align 8, !noalias !0
  %state_4_4970_pointer_103.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %state_4_4970.elt2 = extractvalue %Reference %state_4_4970, 1
  store i64 %state_4_4970.elt2, ptr %state_4_4970_pointer_103.repack1, align 8, !noalias !0
  %tree_2_5241_pointer_104 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %tree_2_5241.elt = extractvalue %Pos %tree_2_5241, 0
  store i64 %tree_2_5241.elt, ptr %tree_2_5241_pointer_104, align 8, !noalias !0
  %tree_2_5241_pointer_104.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %object.i5, ptr %tree_2_5241_pointer_104.repack3, align 8, !noalias !0
  %returnAddress_pointer_105 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_106 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_107 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_38, ptr %returnAddress_pointer_105, align 8, !noalias !0
  store ptr @sharer_56, ptr %sharer_pointer_106, align 8, !noalias !0
  store ptr @eraser_64, ptr %eraser_pointer_107, align 8, !noalias !0
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
  %nextStackPointer.i14 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i15 = icmp ugt ptr %nextStackPointer.i14, %limit.i.i
  br i1 %isInside.not.i15, label %realloc.i18, label %stackAllocate.exit32

realloc.i18:                                      ; preds = %stackAllocate.exit
  %newBase.i28 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i29 = getelementptr i8, ptr %newBase.i28, i64 32
  %newNextStackPointer.i31 = getelementptr i8, ptr %newBase.i28, i64 24
  store ptr %newBase.i28, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i29, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit32

stackAllocate.exit32:                             ; preds = %stackAllocate.exit, %realloc.i18
  %limit.i36 = phi ptr [ %newLimit.i29, %realloc.i18 ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i16 = phi ptr [ %newNextStackPointer.i31, %realloc.i18 ], [ %nextStackPointer.i14, %stackAllocate.exit ]
  %base.i43 = phi ptr [ %newBase.i28, %realloc.i18 ], [ %stackPointer.i.i, %stackAllocate.exit ]
  %sharer_pointer_120 = getelementptr i8, ptr %base.i43, i64 8
  %eraser_pointer_121 = getelementptr i8, ptr %base.i43, i64 16
  store ptr @returnAddress_109, ptr %base.i43, align 8, !noalias !0
  store ptr @sharer_114, ptr %sharer_pointer_120, align 8, !noalias !0
  store ptr @eraser_116, ptr %eraser_pointer_121, align 8, !noalias !0
  %nextStackPointer.i37 = getelementptr i8, ptr %nextStackPointer.sink.i16, i64 24
  %isInside.not.i38 = icmp ugt ptr %nextStackPointer.i37, %limit.i36
  br i1 %isInside.not.i38, label %realloc.i41, label %stackAllocate.exit55

realloc.i41:                                      ; preds = %stackAllocate.exit32
  %intStackPointer.i44 = ptrtoint ptr %nextStackPointer.sink.i16 to i64
  %intBase.i45 = ptrtoint ptr %base.i43 to i64
  %size.i46 = sub i64 %intStackPointer.i44, %intBase.i45
  %nextSize.i47 = add i64 %size.i46, 24
  %leadingZeros.i.i48 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i47, i1 false)
  %numBits.i.i49 = sub nuw nsw i64 64, %leadingZeros.i.i48
  %result.i.i50 = shl nuw i64 1, %numBits.i.i49
  %newBase.i51 = tail call ptr @realloc(ptr nonnull %base.i43, i64 %result.i.i50)
  %newLimit.i52 = getelementptr i8, ptr %newBase.i51, i64 %result.i.i50
  %newStackPointer.i53 = getelementptr i8, ptr %newBase.i51, i64 %size.i46
  %newNextStackPointer.i54 = getelementptr i8, ptr %newStackPointer.i53, i64 24
  store ptr %newBase.i51, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i52, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit55

stackAllocate.exit55:                             ; preds = %stackAllocate.exit32, %realloc.i41
  %nextStackPointer.sink.i39 = phi ptr [ %newNextStackPointer.i54, %realloc.i41 ], [ %nextStackPointer.i37, %stackAllocate.exit32 ]
  %common.ret.op.i40 = phi ptr [ %newStackPointer.i53, %realloc.i41 ], [ %nextStackPointer.sink.i16, %stackAllocate.exit32 ]
  store ptr %nextStackPointer.sink.i39, ptr %stack.repack1.i, align 8
  %sharer_pointer_543 = getelementptr i8, ptr %common.ret.op.i40, i64 8
  %eraser_pointer_544 = getelementptr i8, ptr %common.ret.op.i40, i64 16
  store ptr @returnAddress_529, ptr %common.ret.op.i40, align 8, !noalias !0
  store ptr @sharer_7, ptr %sharer_pointer_543, align 8, !noalias !0
  store ptr @eraser_9, ptr %eraser_pointer_544, align 8, !noalias !0
  musttail call tailcc void @explore_worker_4_33_243_4974(%Pos %tree_2_5241, %Reference %state_4_4970, ptr nonnull %calloc.i.i, ptr nonnull %stack.i)
  ret void

label_551:                                        ; preds = %entry
  br i1 %isNull.i.i6, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_551
  %referenceCount.i.i8 = load i64, ptr %object.i5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i8, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i7
  %referenceCount.1.i.i9 = add i64 %referenceCount.i.i8, -1
  store i64 %referenceCount.1.i.i9, ptr %object.i5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i7
  %objectEraser.i.i = getelementptr i8, ptr %object.i5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_551, %decr.i.i, %free.i.i
  %prompt.i56 = extractvalue %Reference %state_4_4970, 0
  %offset.i = extractvalue %Reference %state_4_4970, 1
  %stack_pointer.i.i = getelementptr i8, ptr %prompt.i56, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i57 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i58 = load ptr, ptr %base_pointer.i57, align 8
  %varPointer.i = getelementptr i8, ptr %base.i58, i64 %offset.i
  %get_5532 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer_pointer.i59 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i59, align 8, !alias.scope !0
  %limit_pointer.i60 = getelementptr i8, ptr %stack, i64 24
  %limit.i61 = load ptr, ptr %limit_pointer.i60, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i61
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i62 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i62, ptr %stackPointer_pointer.i59, align 8, !alias.scope !0
  %returnAddress_548 = load ptr, ptr %newStackPointer.i62, align 8, !noalias !0
  musttail call tailcc void %returnAddress_548(i64 %get_5532, ptr %stack)
  ret void
}

define tailcc void @returnAddress_2(%Pos %tree_2_5241, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i1 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i1, align 8
  %sharer_pointer_13 = getelementptr i8, ptr %stackPointer.i2, i64 8
  %eraser_pointer_14 = getelementptr i8, ptr %stackPointer.i2, i64 16
  store ptr @returnAddress_3, ptr %stackPointer.i2, align 8, !noalias !0
  store ptr @sharer_7, ptr %sharer_pointer_13, align 8, !noalias !0
  store ptr @eraser_9, ptr %eraser_pointer_14, align 8, !noalias !0
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i1, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i9 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i14 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i15 = icmp ugt ptr %nextStackPointer.i14, %limit.i
  br i1 %isInside.not.i15, label %realloc.i18, label %stackAllocate.exit32

realloc.i18:                                      ; preds = %stackAllocate.exit
  %nextSize.i24 = add i64 %offset.i, 32
  %leadingZeros.i.i25 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i24, i1 false)
  %numBits.i.i26 = sub nuw nsw i64 64, %leadingZeros.i.i25
  %result.i.i27 = shl nuw i64 1, %numBits.i.i26
  %newBase.i28 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i27)
  %newLimit.i29 = getelementptr i8, ptr %newBase.i28, i64 %result.i.i27
  %newStackPointer.i30 = getelementptr i8, ptr %newBase.i28, i64 %offset.i
  %newNextStackPointer.i31 = getelementptr i8, ptr %newStackPointer.i30, i64 32
  store ptr %newBase.i28, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i29, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit32

stackAllocate.exit32:                             ; preds = %stackAllocate.exit, %realloc.i18
  %nextStackPointer.sink.i16 = phi ptr [ %newNextStackPointer.i31, %realloc.i18 ], [ %nextStackPointer.i14, %stackAllocate.exit ]
  %common.ret.op.i17 = phi ptr [ %newStackPointer.i30, %realloc.i18 ], [ %stackPointer.i, %stackAllocate.exit ]
  %reference..1.i = insertvalue %Reference undef, ptr %prompt.i9, 0
  %reference.i = insertvalue %Reference %reference..1.i, i64 %offset.i, 1
  store ptr %nextStackPointer.sink.i16, ptr %stackPointer_pointer.i1, align 8
  store i64 0, ptr %common.ret.op.i17, align 4, !noalias !0
  %returnAddress_pointer_32 = getelementptr i8, ptr %common.ret.op.i17, i64 8
  %sharer_pointer_33 = getelementptr i8, ptr %common.ret.op.i17, i64 16
  %eraser_pointer_34 = getelementptr i8, ptr %common.ret.op.i17, i64 24
  store ptr @returnAddress_15, ptr %returnAddress_pointer_32, align 8, !noalias !0
  store ptr @sharer_23, ptr %sharer_pointer_33, align 8, !noalias !0
  store ptr @eraser_27, ptr %eraser_pointer_34, align 8, !noalias !0
  musttail call tailcc void @loop_208_5045(i64 10, %Reference %reference.i, %Pos %tree_2_5241, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3516_3580, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3516_3580, 0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_554 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_555 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_2, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_7, ptr %sharer_pointer_554, align 8, !noalias !0
  store ptr @eraser_9, ptr %eraser_pointer_555, align 8, !noalias !0
  %z.i6.i = icmp eq i64 %unboxed.i, 0
  br i1 %z.i6.i, label %label_873.i, label %label_868.lr.ph.i

label_868.lr.ph.i:                                ; preds = %stackAllocate.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  br label %label_868.i

label_868.i:                                      ; preds = %stackAllocate.exit.i, %label_868.lr.ph.i
  %limit.i.i = phi ptr [ %limit.i, %label_868.lr.ph.i ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %currentStackPointer.i.i = phi ptr [ %oldStackPointer.i, %label_868.lr.ph.i ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %n_2444.tr7.i = phi i64 [ %unboxed.i, %label_868.lr.ph.i ], [ %z.i1.i, %stackAllocate.exit.i ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 32
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_868.i
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
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
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_868.i
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %label_868.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_868.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_868.i ]
  %z.i1.i = add i64 %n_2444.tr7.i, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %n_2444.tr7.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %returnAddress_pointer_865.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  %sharer_pointer_866.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %eraser_pointer_867.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @returnAddress_842, ptr %returnAddress_pointer_865.i, align 8, !noalias !0
  store ptr @sharer_23, ptr %sharer_pointer_866.i, align 8, !noalias !0
  store ptr @eraser_27, ptr %eraser_pointer_867.i, align 8, !noalias !0
  %z.i.i = icmp eq i64 %z.i1.i, 0
  br i1 %z.i.i, label %label_873.i, label %label_868.i

label_873.i:                                      ; preds = %stackAllocate.exit.i, %stackAllocate.exit
  %limit.i4.i = phi ptr [ %limit.i, %stackAllocate.exit ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %stackPointer.i.i = phi ptr [ %oldStackPointer.i, %stackAllocate.exit ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i4.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i5.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i5.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_870.i = load ptr, ptr %newStackPointer.i5.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_870.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_561(%Pos %returned_5534, ptr nocapture %stack) {
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
  %returnAddress_563 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_563(%Pos %returned_5534, ptr %rest.i)
  ret void
}

define tailcc void @toList_1_1_3_167_4790(i64 %start_2_2_4_168_4892, %Pos %acc_3_3_5_169_4758, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4892, 1
  br i1 %z.i6, label %label_584, label %label_580

label_580:                                        ; preds = %entry, %label_580
  %acc_3_3_5_169_4758.tr8 = phi %Pos [ %make_5540, %label_580 ], [ %acc_3_3_5_169_4758, %entry ]
  %start_2_2_4_168_4892.tr7 = phi i64 [ %z.i5, %label_580 ], [ %start_2_2_4_168_4892, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4892.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4892.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_414, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5537.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_5537.elt, ptr %environment.i, align 8, !noalias !0
  %environment_574.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5537.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_5537.elt2, ptr %environment_574.repack1, align 8, !noalias !0
  %acc_3_3_5_169_4758_pointer_578 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_4758.elt = extractvalue %Pos %acc_3_3_5_169_4758.tr8, 0
  store i64 %acc_3_3_5_169_4758.elt, ptr %acc_3_3_5_169_4758_pointer_578, align 8, !noalias !0
  %acc_3_3_5_169_4758_pointer_578.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_4758.elt4 = extractvalue %Pos %acc_3_3_5_169_4758.tr8, 1
  store ptr %acc_3_3_5_169_4758.elt4, ptr %acc_3_3_5_169_4758_pointer_578.repack3, align 8, !noalias !0
  %make_5540 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4892.tr7, 2
  br i1 %z.i, label %label_584, label %label_580

label_584:                                        ; preds = %label_580, %entry
  %acc_3_3_5_169_4758.tr.lcssa = phi %Pos [ %acc_3_3_5_169_4758, %entry ], [ %make_5540, %label_580 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_581 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_581(%Pos %acc_3_3_5_169_4758.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_595(%Pos %v_r_2672_32_59_223_4718, ptr %stack) {
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
  %tmp_5411 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %p_8_9_4581_pointer_598 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %p_8_9_4581 = load ptr, ptr %p_8_9_4581_pointer_598, align 8, !noalias !0
  %acc_8_35_199_4876_pointer_599 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %acc_8_35_199_4876 = load i64, ptr %acc_8_35_199_4876_pointer_599, align 4, !noalias !0
  %index_7_34_198_4866_pointer_600 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_7_34_198_4866 = load i64, ptr %index_7_34_198_4866_pointer_600, align 4, !noalias !0
  %v_r_2589_30_194_4665_pointer_601 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2589_30_194_4665.unpack = load i64, ptr %v_r_2589_30_194_4665_pointer_601, align 8, !noalias !0
  %v_r_2589_30_194_4665.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2589_30_194_4665.unpack2 = load ptr, ptr %v_r_2589_30_194_4665.elt1, align 8, !noalias !0
  %tag_602 = extractvalue %Pos %v_r_2672_32_59_223_4718, 0
  %fields_603 = extractvalue %Pos %v_r_2672_32_59_223_4718, 1
  switch i64 %tag_602, label %common.ret [
    i64 1, label %label_627
    i64 0, label %label_634
  ]

common.ret:                                       ; preds = %entry
  ret void

label_615:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2589_30_194_4665.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_615
  %referenceCount.i.i37 = load i64, ptr %v_r_2589_30_194_4665.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2589_30_194_4665.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2589_30_194_4665.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2589_30_194_4665.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2589_30_194_4665.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_615, %decr.i.i39, %free.i.i41
  %pair_610 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4581)
  %k_13_14_4_5317 = extractvalue <{ ptr, ptr }> %pair_610, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_5317, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_5317, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_5317, i64 40
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
  %stack_611 = extractvalue <{ ptr, ptr }> %pair_610, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_611, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_611, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_612 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_612(%Pos { i64 5, ptr null }, ptr %stack_611)
  ret void

label_624:                                        ; preds = %label_626
  %isNull.i.i24 = icmp eq ptr %v_r_2589_30_194_4665.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_624
  %referenceCount.i.i26 = load i64, ptr %v_r_2589_30_194_4665.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2589_30_194_4665.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2589_30_194_4665.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2589_30_194_4665.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2589_30_194_4665.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_624, %decr.i.i28, %free.i.i30
  %pair_619 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4581)
  %k_13_14_4_5316 = extractvalue <{ ptr, ptr }> %pair_619, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_5316, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_5316, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5316, i64 40
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
  %stack_620 = extractvalue <{ ptr, ptr }> %pair_619, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_620, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_620, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_621 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_621(%Pos { i64 5, ptr null }, ptr %stack_620)
  ret void

label_625:                                        ; preds = %label_626
  %0 = insertvalue %Pos poison, i64 %v_r_2589_30_194_4665.unpack, 0
  %v_r_2589_30_194_46653 = insertvalue %Pos %0, ptr %v_r_2589_30_194_4665.unpack2, 1
  %z.i = add i64 %index_7_34_198_4866, 1
  %z.i108 = mul i64 %acc_8_35_199_4876, 10
  %z.i109 = sub i64 %z.i108, %tmp_5411
  %z.i110 = add i64 %z.i109, %v_coe_3488_46_73_237_4803.unpack
  musttail call tailcc void @go_6_33_197_4766(i64 %z.i, i64 %z.i110, %Pos %v_r_2589_30_194_46653, i64 %tmp_5411, ptr %p_8_9_4581, ptr nonnull %stack)
  ret void

label_626:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3488_46_73_237_4803.unpack, 58
  br i1 %z.i111, label %label_625, label %label_624

label_627:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_603, i64 16
  %v_coe_3488_46_73_237_4803.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3488_46_73_237_4803.elt4 = getelementptr i8, ptr %fields_603, i64 24
  %v_coe_3488_46_73_237_4803.unpack5 = load ptr, ptr %v_coe_3488_46_73_237_4803.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3488_46_73_237_4803.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_627
  %referenceCount.i.i = load i64, ptr %v_coe_3488_46_73_237_4803.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3488_46_73_237_4803.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_627
  %referenceCount.i11 = load i64, ptr %fields_603, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_603, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_603, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_603)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_3488_46_73_237_4803.unpack, 47
  br i1 %z.i112, label %label_626, label %label_615

label_634:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_603, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_634
  %referenceCount.i = load i64, ptr %fields_603, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_603, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_603, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_603, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_603)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_634, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_2589_30_194_4665.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2589_30_194_4665.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2589_30_194_4665.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2589_30_194_4665.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2589_30_194_4665.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2589_30_194_4665.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_631 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_631(i64 %acc_8_35_199_4876, ptr nonnull %stack)
  ret void
}

define void @sharer_640(ptr %stackPointer) {
entry:
  %v_r_2589_30_194_4665_639.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2589_30_194_4665_639.unpack2 = load ptr, ptr %v_r_2589_30_194_4665_639.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2589_30_194_4665_639.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2589_30_194_4665_639.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2589_30_194_4665_639.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_652(ptr %stackPointer) {
entry:
  %v_r_2589_30_194_4665_651.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2589_30_194_4665_651.unpack2 = load ptr, ptr %v_r_2589_30_194_4665_651.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2589_30_194_4665_651.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2589_30_194_4665_651.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2589_30_194_4665_651.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2589_30_194_4665_651.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2589_30_194_4665_651.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2589_30_194_4665_651.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_669(%Pos %returned_5565, ptr nocapture %stack) {
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
  %returnAddress_671 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_671(%Pos %returned_5565, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_4744_clause_678(ptr %closure, %Pos %exc_8_20_47_211_4681, %Pos %msg_9_21_48_212_4713, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4620 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_681 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4620)
  %k_11_23_50_214_4903 = extractvalue <{ ptr, ptr }> %pair_681, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_4903, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_4903, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_4903, i64 40
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
  %stack_682 = extractvalue <{ ptr, ptr }> %pair_681, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_414, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_4681.elt = extractvalue %Pos %exc_8_20_47_211_4681, 0
  store i64 %exc_8_20_47_211_4681.elt, ptr %environment.i, align 8, !noalias !0
  %environment_684.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_4681.elt2 = extractvalue %Pos %exc_8_20_47_211_4681, 1
  store ptr %exc_8_20_47_211_4681.elt2, ptr %environment_684.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4713_pointer_688 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4713.elt = extractvalue %Pos %msg_9_21_48_212_4713, 0
  store i64 %msg_9_21_48_212_4713.elt, ptr %msg_9_21_48_212_4713_pointer_688, align 8, !noalias !0
  %msg_9_21_48_212_4713_pointer_688.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4713.elt4 = extractvalue %Pos %msg_9_21_48_212_4713, 1
  store ptr %msg_9_21_48_212_4713.elt4, ptr %msg_9_21_48_212_4713_pointer_688.repack3, align 8, !noalias !0
  %make_5566 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_682, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_682, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_690 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_690(%Pos %make_5566, ptr %stack_682)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_697(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_705(ptr nocapture readonly %environment) {
entry:
  %tmp_5413_704.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5413_704.unpack2 = load ptr, ptr %tmp_5413_704.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5413_704.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5413_704.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5413_704.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5413_704.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5413_704.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5413_704.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_701(i64 %v_coe_3487_6_28_55_219_4791, ptr %stack) {
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
  store ptr @eraser_705, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3487_6_28_55_219_4791, ptr %environment.i, align 8, !noalias !0
  %environment_703.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_703.repack1, align 8, !noalias !0
  %make_5568 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_709 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_709(%Pos %make_5568, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_4766(i64 %index_7_34_198_4866, i64 %acc_8_35_199_4876, %Pos %v_r_2589_30_194_4665, i64 %tmp_5411, ptr %p_8_9_4581, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2589_30_194_4665, 1
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
  store i64 %tmp_5411, ptr %common.ret.op.i, align 4, !noalias !0
  %p_8_9_4581_pointer_661 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_8_9_4581, ptr %p_8_9_4581_pointer_661, align 8, !noalias !0
  %acc_8_35_199_4876_pointer_662 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %acc_8_35_199_4876, ptr %acc_8_35_199_4876_pointer_662, align 4, !noalias !0
  %index_7_34_198_4866_pointer_663 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %index_7_34_198_4866, ptr %index_7_34_198_4866_pointer_663, align 4, !noalias !0
  %v_r_2589_30_194_4665_pointer_664 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %v_r_2589_30_194_4665.elt = extractvalue %Pos %v_r_2589_30_194_4665, 0
  store i64 %v_r_2589_30_194_4665.elt, ptr %v_r_2589_30_194_4665_pointer_664, align 8, !noalias !0
  %v_r_2589_30_194_4665_pointer_664.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %object.i3, ptr %v_r_2589_30_194_4665_pointer_664.repack1, align 8, !noalias !0
  %returnAddress_pointer_665 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_666 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_667 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_595, ptr %returnAddress_pointer_665, align 8, !noalias !0
  store ptr @sharer_640, ptr %sharer_pointer_666, align 8, !noalias !0
  store ptr @eraser_652, ptr %eraser_pointer_667, align 8, !noalias !0
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
  %sharer_pointer_676 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_677 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_669, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_114, ptr %sharer_pointer_676, align 8, !noalias !0
  store ptr @eraser_116, ptr %eraser_pointer_677, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_697, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_4744 = insertvalue %Neg { ptr @vtable_693, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_714 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_715 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_701, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_7, ptr %sharer_pointer_714, align 8, !noalias !0
  store ptr @eraser_9, ptr %eraser_pointer_715, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2589_30_194_4665, i64 %index_7_34_198_4866, %Neg %Exception_7_19_46_210_4744, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_4738_clause_716(ptr %closure, %Pos %exception_10_107_134_298_5569, %Pos %msg_11_108_135_299_5570, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4581 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_5569, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_5570, 1
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
  %pair_719 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4581)
  %k_13_14_4_5390 = extractvalue <{ ptr, ptr }> %pair_719, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_5390, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_5390, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5390, i64 40
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
  %stack_720 = extractvalue <{ ptr, ptr }> %pair_719, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_720, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_720, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_721 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_721(%Pos { i64 5, ptr null }, ptr %stack_720)
  ret void
}

define tailcc void @returnAddress_735(i64 %v_coe_3492_22_131_158_322_4736, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3492_22_131_158_322_4736, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_736 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_736(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_747(i64 %v_r_2686_1_9_20_129_156_320_4709, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2686_1_9_20_129_156_320_4709
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_748 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_748(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_730(i64 %v_r_2685_3_14_123_150_314_4826, ptr %stack) {
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
  %v_r_2589_30_194_4665.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2589_30_194_4665.unpack, 0
  %v_r_2589_30_194_4665.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2589_30_194_4665.unpack2 = load ptr, ptr %v_r_2589_30_194_4665.elt1, align 8, !noalias !0
  %v_r_2589_30_194_46653 = insertvalue %Pos %0, ptr %v_r_2589_30_194_4665.unpack2, 1
  %tmp_5411_pointer_733 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5411 = load i64, ptr %tmp_5411_pointer_733, align 4, !noalias !0
  %p_8_9_4581_pointer_734 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_4581 = load ptr, ptr %p_8_9_4581_pointer_734, align 8, !noalias !0
  %z.i = icmp eq i64 %v_r_2685_3_14_123_150_314_4826, 45
  %isInside.not.i = icmp ugt ptr %p_8_9_4581_pointer_734, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %p_8_9_4581_pointer_734, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_741 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_742 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_735, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_7, ptr %sharer_pointer_741, align 8, !noalias !0
  store ptr @eraser_9, ptr %eraser_pointer_742, align 8, !noalias !0
  br i1 %z.i, label %label_755, label %label_746

label_746:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_4766(i64 0, i64 0, %Pos %v_r_2589_30_194_46653, i64 %tmp_5411, ptr %p_8_9_4581, ptr nonnull %stack)
  ret void

label_755:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_755
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

stackAllocate.exit35:                             ; preds = %label_755, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_755 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_755 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_753 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_754 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_747, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_7, ptr %sharer_pointer_753, align 8, !noalias !0
  store ptr @eraser_9, ptr %eraser_pointer_754, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_4766(i64 1, i64 0, %Pos %v_r_2589_30_194_46653, i64 %tmp_5411, ptr %p_8_9_4581, ptr nonnull %stack)
  ret void
}

define void @sharer_759(ptr %stackPointer) {
entry:
  %v_r_2589_30_194_4665_756.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2589_30_194_4665_756.unpack2 = load ptr, ptr %v_r_2589_30_194_4665_756.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2589_30_194_4665_756.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2589_30_194_4665_756.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2589_30_194_4665_756.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_767(ptr %stackPointer) {
entry:
  %v_r_2589_30_194_4665_764.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2589_30_194_4665_764.unpack2 = load ptr, ptr %v_r_2589_30_194_4665_764.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2589_30_194_4665_764.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2589_30_194_4665_764.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2589_30_194_4665_764.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2589_30_194_4665_764.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2589_30_194_4665_764.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2589_30_194_4665_764.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_592(%Pos %v_r_2589_30_194_4665, ptr %stack) {
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
  %p_8_9_4581 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_697, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4581, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2589_30_194_4665, 1
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
  %v_r_2589_30_194_4665.elt = extractvalue %Pos %v_r_2589_30_194_4665, 0
  store i64 %v_r_2589_30_194_4665.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_772.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i3, ptr %stackPointer_772.repack1, align 8, !noalias !0
  %tmp_5411_pointer_774 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 48, ptr %tmp_5411_pointer_774, align 4, !noalias !0
  %p_8_9_4581_pointer_775 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %p_8_9_4581, ptr %p_8_9_4581_pointer_775, align 8, !noalias !0
  %returnAddress_pointer_776 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_777 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_778 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_730, ptr %returnAddress_pointer_776, align 8, !noalias !0
  store ptr @sharer_759, ptr %sharer_pointer_777, align 8, !noalias !0
  store ptr @eraser_767, ptr %eraser_pointer_778, align 8, !noalias !0
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
  store i64 %v_r_2589_30_194_4665.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_947.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_947.repack1.i, align 8, !noalias !0
  %index_2107_pointer_949.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_949.i, align 4, !noalias !0
  %Exception_2362_pointer_950.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_724, ptr %Exception_2362_pointer_950.i, align 8, !noalias !0
  %Exception_2362_pointer_950.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_950.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_951.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_952.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_953.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_913, ptr %returnAddress_pointer_951.i, align 8, !noalias !0
  store ptr @sharer_934, ptr %sharer_pointer_952.i, align 8, !noalias !0
  store ptr @eraser_942, ptr %eraser_pointer_953.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2589_30_194_4665)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_957.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_957.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_780(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_784(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_589(%Pos %v_r_2588_24_188_4795, ptr %stack) {
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
  %p_8_9_4581 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4581, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_790 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_791 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_592, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_780, ptr %sharer_pointer_790, align 8, !noalias !0
  store ptr @eraser_784, ptr %eraser_pointer_791, align 8, !noalias !0
  %tag_792 = extractvalue %Pos %v_r_2588_24_188_4795, 0
  switch i64 %tag_792, label %label_794 [
    i64 0, label %label_798
    i64 1, label %label_804
  ]

label_794:                                        ; preds = %stackAllocate.exit
  ret void

label_798:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_5585 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5585.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_795 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_795(%Pos %utf8StringLiteral_5585, ptr nonnull %stack)
  ret void

label_804:                                        ; preds = %stackAllocate.exit
  %fields_793 = extractvalue %Pos %v_r_2588_24_188_4795, 1
  %environment.i = getelementptr i8, ptr %fields_793, i64 16
  %v_y_3314_8_29_193_4626.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3314_8_29_193_4626.elt1 = getelementptr i8, ptr %fields_793, i64 24
  %v_y_3314_8_29_193_4626.unpack2 = load ptr, ptr %v_y_3314_8_29_193_4626.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3314_8_29_193_4626.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_804
  %referenceCount.i.i = load i64, ptr %v_y_3314_8_29_193_4626.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3314_8_29_193_4626.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_804
  %referenceCount.i = load i64, ptr %fields_793, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_793, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_793, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_793)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3314_8_29_193_4626.unpack, 0
  %v_y_3314_8_29_193_46263 = insertvalue %Pos %0, ptr %v_y_3314_8_29_193_4626.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_801 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_801(%Pos %v_y_3314_8_29_193_46263, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_586(%Pos %v_r_2587_13_177_4890, ptr %stack) {
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
  %p_8_9_4581 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4581, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_810 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_811 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_589, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_780, ptr %sharer_pointer_810, align 8, !noalias !0
  store ptr @eraser_784, ptr %eraser_pointer_811, align 8, !noalias !0
  %tag_812 = extractvalue %Pos %v_r_2587_13_177_4890, 0
  switch i64 %tag_812, label %label_814 [
    i64 0, label %label_819
    i64 1, label %label_831
  ]

label_814:                                        ; preds = %stackAllocate.exit
  ret void

label_819:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4581, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_592, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_780, ptr %sharer_pointer_810, align 8, !noalias !0
  store ptr @eraser_784, ptr %eraser_pointer_811, align 8, !noalias !0
  %utf8StringLiteral_5585.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5585.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_795.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_795.i(%Pos %utf8StringLiteral_5585.i, ptr nonnull %stack)
  ret void

label_831:                                        ; preds = %stackAllocate.exit
  %fields_813 = extractvalue %Pos %v_r_2587_13_177_4890, 1
  %environment.i6 = getelementptr i8, ptr %fields_813, i64 16
  %v_y_2823_10_21_185_4623.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_2823_10_21_185_4623.elt1 = getelementptr i8, ptr %fields_813, i64 24
  %v_y_2823_10_21_185_4623.unpack2 = load ptr, ptr %v_y_2823_10_21_185_4623.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2823_10_21_185_4623.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_831
  %referenceCount.i.i = load i64, ptr %v_y_2823_10_21_185_4623.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2823_10_21_185_4623.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_831
  %referenceCount.i = load i64, ptr %fields_813, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_813, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_813, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_813)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_705, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2823_10_21_185_4623.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_824.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2823_10_21_185_4623.unpack2, ptr %environment_824.repack4, align 8, !noalias !0
  %make_5587 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_828 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_828(%Pos %make_5587, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2448(ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_558 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_559 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_7, ptr %sharer_pointer_558, align 8, !noalias !0
  store ptr @eraser_9, ptr %eraser_pointer_559, align 8, !noalias !0
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
  %sharer_pointer_568 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_569 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_561, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_114, ptr %sharer_pointer_568, align 8, !noalias !0
  store ptr @eraser_116, ptr %eraser_pointer_569, align 8, !noalias !0
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
  %returnAddress_pointer_836 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_837 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_838 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_586, ptr %returnAddress_pointer_836, align 8, !noalias !0
  store ptr @sharer_780, ptr %sharer_pointer_837, align 8, !noalias !0
  store ptr @eraser_784, ptr %eraser_pointer_838, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_584.i, label %label_580.i

label_580.i:                                      ; preds = %stackAllocate.exit46, %label_580.i
  %acc_3_3_5_169_4758.tr8.i = phi %Pos [ %make_5540.i, %label_580.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4892.tr7.i = phi i64 [ %z.i5.i, %label_580.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4892.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4892.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_414, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_5537.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_5537.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_574.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_5537.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_5537.elt2.i, ptr %environment_574.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_4758_pointer_578.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_4758.elt.i = extractvalue %Pos %acc_3_3_5_169_4758.tr8.i, 0
  store i64 %acc_3_3_5_169_4758.elt.i, ptr %acc_3_3_5_169_4758_pointer_578.i, align 8, !noalias !0
  %acc_3_3_5_169_4758_pointer_578.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_4758.elt4.i = extractvalue %Pos %acc_3_3_5_169_4758.tr8.i, 1
  store ptr %acc_3_3_5_169_4758.elt4.i, ptr %acc_3_3_5_169_4758_pointer_578.repack3.i, align 8, !noalias !0
  %make_5540.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4892.tr7.i, 2
  br i1 %z.i.i, label %label_584.i.loopexit, label %label_580.i

label_584.i.loopexit:                             ; preds = %label_580.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_584.i

label_584.i:                                      ; preds = %label_584.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_584.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_584.i.loopexit ]
  %acc_3_3_5_169_4758.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_5540.i, %label_584.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_581.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_581.i(%Pos %acc_3_3_5_169_4758.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define void @eraser_850(ptr nocapture readonly %environment) {
entry:
  %t_2461_847.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %t_2461_847.unpack2 = load ptr, ptr %t_2461_847.elt1, align 8, !noalias !0
  %t_2461_849.elt4 = getelementptr i8, ptr %environment, i64 32
  %t_2461_849.unpack5 = load ptr, ptr %t_2461_849.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %t_2461_847.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %t_2461_847.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %t_2461_847.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %t_2461_847.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %t_2461_847.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %t_2461_847.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %t_2461_849.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %t_2461_849.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %t_2461_849.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %t_2461_849.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %t_2461_849.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %t_2461_849.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_842(%Pos %t_2461, ptr %stack) {
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
  %n_2444 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %object.i = tail call dereferenceable_or_null(56) ptr @malloc(i64 56)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_850, ptr %objectEraser.i, align 8
  %object.i6 = extractvalue %Pos %t_2461, 1
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
  %t_2461.elt = extractvalue %Pos %t_2461, 0
  store i64 %t_2461.elt, ptr %environment.i, align 8, !noalias !0
  %environment_846.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr %object.i6, ptr %environment_846.repack1, align 8, !noalias !0
  %n_2444_pointer_855 = getelementptr i8, ptr %object.i, i64 32
  store i64 %n_2444, ptr %n_2444_pointer_855, align 4, !noalias !0
  %t_2461_pointer_856 = getelementptr i8, ptr %object.i, i64 40
  store i64 %t_2461.elt, ptr %t_2461_pointer_856, align 8, !noalias !0
  %t_2461_pointer_856.repack4 = getelementptr i8, ptr %object.i, i64 48
  store ptr %object.i6, ptr %t_2461_pointer_856.repack4, align 8, !noalias !0
  %make_5482 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_858 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_858(%Pos %make_5482, ptr nonnull %stack)
  ret void
}

define tailcc void @make_2445(i64 %n_2444, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp eq i64 %n_2444, 0
  %stackPointer_pointer.i2.phi.trans.insert = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i6, label %entry.label_873_crit_edge, label %label_868.lr.ph

entry.label_873_crit_edge:                        ; preds = %entry
  %stackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8, !alias.scope !0
  %limit_pointer.i3.phi.trans.insert = getelementptr i8, ptr %stack, i64 24
  %limit.i4.pre = load ptr, ptr %limit_pointer.i3.phi.trans.insert, align 8, !alias.scope !0
  br label %label_873

label_868.lr.ph:                                  ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %currentStackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8, !alias.scope !0
  %limit.i.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %label_868

label_868:                                        ; preds = %label_868.lr.ph, %stackAllocate.exit
  %limit.i = phi ptr [ %limit.i.pre, %label_868.lr.ph ], [ %limit.i9, %stackAllocate.exit ]
  %currentStackPointer.i = phi ptr [ %currentStackPointer.i.pre, %label_868.lr.ph ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %n_2444.tr7 = phi i64 [ %n_2444, %label_868.lr.ph ], [ %z.i1, %stackAllocate.exit ]
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_868
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

stackAllocate.exit:                               ; preds = %label_868, %realloc.i
  %limit.i9 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_868 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_868 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_868 ]
  %z.i1 = add i64 %n_2444.tr7, -1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8
  store i64 %n_2444.tr7, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_865 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_866 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_867 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_842, ptr %returnAddress_pointer_865, align 8, !noalias !0
  store ptr @sharer_23, ptr %sharer_pointer_866, align 8, !noalias !0
  store ptr @eraser_27, ptr %eraser_pointer_867, align 8, !noalias !0
  %z.i = icmp eq i64 %z.i1, 0
  br i1 %z.i, label %label_873, label %label_868

label_873:                                        ; preds = %stackAllocate.exit, %entry.label_873_crit_edge
  %limit.i4 = phi ptr [ %limit.i4.pre, %entry.label_873_crit_edge ], [ %limit.i9, %stackAllocate.exit ]
  %stackPointer.i = phi ptr [ %stackPointer.i.pre, %entry.label_873_crit_edge ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %stackPointer_pointer.i2 = getelementptr i8, ptr %stack, i64 8
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i5 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i5, ptr %stackPointer_pointer.i2, align 8, !alias.scope !0
  %returnAddress_870 = load ptr, ptr %newStackPointer.i5, align 8, !noalias !0
  musttail call tailcc void %returnAddress_870(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_886(i64 %v_r_2539_3_3_3926, ptr %stack) {
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
  %tmp_5458 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i = icmp sgt i64 %tmp_5458, %v_r_2539_3_3_3926
  %isInside.i16 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_896 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  br i1 %z.i, label %label_899, label %label_895

label_895:                                        ; preds = %entry
  musttail call tailcc void %returnAddress_896(i64 %v_r_2539_3_3_3926, ptr nonnull %stack)
  ret void

label_899:                                        ; preds = %entry
  musttail call tailcc void %returnAddress_896(i64 %tmp_5458, ptr nonnull %stack)
  ret void
}

define tailcc void @maximum_2438(%Pos %l_2437, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i32 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i33 = getelementptr i8, ptr %stack, i64 24
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  br label %tailrecurse

tailrecurse:                                      ; preds = %stackAllocate.exit, %entry
  %l_2437.tr = phi %Pos [ %l_2437, %entry ], [ %v_coe_3508_36346, %stackAllocate.exit ]
  %tag_874 = extractvalue %Pos %l_2437.tr, 0
  switch i64 %tag_874, label %label_876 [
    i64 0, label %label_880
    i64 1, label %label_912
  ]

label_876:                                        ; preds = %tailrecurse
  ret void

label_880:                                        ; preds = %tailrecurse
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i32, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i33, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i32, align 8, !alias.scope !0
  %returnAddress_877 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_877(i64 -1, ptr %stack)
  ret void

next.i.i22:                                       ; preds = %sharePositive.exit.thread
  br i1 %cond.i.i, label %free.i.i27, label %decr.i.i25

decr.i.i25:                                       ; preds = %next.i.i22
  store i64 %referenceCount.i.i, ptr %v_coe_3508_3634.unpack5, align 4
  br label %erasePositive.exit31

free.i.i27:                                       ; preds = %next.i.i22
  %objectEraser.i.i28 = getelementptr i8, ptr %v_coe_3508_3634.unpack5, i64 8
  %eraser.i.i29 = load ptr, ptr %objectEraser.i.i28, align 8
  %environment.i.i.i30 = getelementptr i8, ptr %v_coe_3508_3634.unpack5, i64 16
  tail call void %eraser.i.i29(ptr %environment.i.i.i30)
  tail call void @free(ptr nonnull %v_coe_3508_3634.unpack5)
  br label %erasePositive.exit31

erasePositive.exit31:                             ; preds = %sharePositive.exit, %decr.i.i25, %free.i.i27
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i32, align 8, !alias.scope !0
  %limit.i34 = load ptr, ptr %limit_pointer.i33, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i34
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit31
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
  %newStackPointer.i35 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i35, i64 32
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i33, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit31, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit31 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i35, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit31 ]
  %0 = insertvalue %Pos poison, i64 %v_coe_3508_3634.unpack, 0
  %v_coe_3508_36346 = insertvalue %Pos %0, ptr %v_coe_3508_3634.unpack5, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i32, align 8
  store i64 %v_coe_3507_3633.unpack, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_904 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_905 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_906 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_886, ptr %returnAddress_pointer_904, align 8, !noalias !0
  store ptr @sharer_23, ptr %sharer_pointer_905, align 8, !noalias !0
  store ptr @eraser_27, ptr %eraser_pointer_906, align 8, !noalias !0
  br label %tailrecurse

next.i.i18:                                       ; preds = %sharePositive.exit.thread
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i18
  store i64 %referenceCount.i.i, ptr %v_coe_3508_3634.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i18
  %objectEraser.i.i = getelementptr i8, ptr %v_coe_3508_3634.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_coe_3508_3634.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_coe_3508_3634.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %stackPointer.i37 = load ptr, ptr %stackPointer_pointer.i32, align 8, !alias.scope !0
  %limit.i39 = load ptr, ptr %limit_pointer.i33, align 8, !alias.scope !0
  %isInside.i40 = icmp ule ptr %stackPointer.i37, %limit.i39
  tail call void @llvm.assume(i1 %isInside.i40)
  %newStackPointer.i41 = getelementptr i8, ptr %stackPointer.i37, i64 -24
  store ptr %newStackPointer.i41, ptr %stackPointer_pointer.i32, align 8, !alias.scope !0
  %returnAddress_908 = load ptr, ptr %newStackPointer.i41, align 8, !noalias !0
  musttail call tailcc void %returnAddress_908(i64 %v_coe_3507_3633.unpack, ptr %stack)
  ret void

label_912:                                        ; preds = %tailrecurse
  %fields_875 = extractvalue %Pos %l_2437.tr, 1
  %environment.i = getelementptr i8, ptr %fields_875, i64 16
  %v_coe_3507_3633.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_coe_3507_3633.elt1 = getelementptr i8, ptr %fields_875, i64 24
  %v_coe_3507_3633.unpack2 = load ptr, ptr %v_coe_3507_3633.elt1, align 8, !noalias !0
  %v_coe_3508_3634_pointer_883 = getelementptr i8, ptr %fields_875, i64 32
  %v_coe_3508_3634.unpack = load i64, ptr %v_coe_3508_3634_pointer_883, align 8, !noalias !0
  %v_coe_3508_3634.elt4 = getelementptr i8, ptr %fields_875, i64 40
  %v_coe_3508_3634.unpack5 = load ptr, ptr %v_coe_3508_3634.elt4, align 8, !noalias !0
  %isNull.i.i12 = icmp eq ptr %v_coe_3507_3633.unpack2, null
  br i1 %isNull.i.i12, label %sharePositive.exit16, label %next.i.i13

next.i.i13:                                       ; preds = %label_912
  %referenceCount.i.i14 = load i64, ptr %v_coe_3507_3633.unpack2, align 4
  %referenceCount.1.i.i15 = add i64 %referenceCount.i.i14, 1
  store i64 %referenceCount.1.i.i15, ptr %v_coe_3507_3633.unpack2, align 4
  br label %sharePositive.exit16

sharePositive.exit16:                             ; preds = %label_912, %next.i.i13
  %isNull.i.i7 = icmp eq ptr %v_coe_3508_3634.unpack5, null
  br i1 %isNull.i.i7, label %next.i, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit16
  %referenceCount.i.i9 = load i64, ptr %v_coe_3508_3634.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %v_coe_3508_3634.unpack5, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i8, %sharePositive.exit16
  %referenceCount.i = load i64, ptr %fields_875, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_875, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_875, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_875)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  br i1 %isNull.i.i7, label %sharePositive.exit, label %sharePositive.exit.thread

sharePositive.exit:                               ; preds = %eraseObject.exit
  %cond = icmp eq i64 %v_coe_3508_3634.unpack, 0
  br i1 %cond, label %erasePositive.exit, label %erasePositive.exit31

sharePositive.exit.thread:                        ; preds = %eraseObject.exit
  %referenceCount.i.i = load i64, ptr %v_coe_3508_3634.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3508_3634.unpack5, align 4
  %cond42 = icmp eq i64 %v_coe_3508_3634.unpack, 0
  %cond.i.i = icmp eq i64 %referenceCount.1.i.i, 0
  br i1 %cond42, label %next.i.i18, label %next.i.i22
}

define tailcc void @returnAddress_913(%Pos %v_r_2754_3547, ptr %stack) {
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
  %index_2107_pointer_916 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_916, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_918 = extractvalue %Pos %v_r_2754_3547, 0
  switch i64 %tag_918, label %label_920 [
    i64 0, label %label_924
    i64 1, label %label_930
  ]

label_920:                                        ; preds = %entry
  ret void

label_924:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_924
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

eraseNegative.exit:                               ; preds = %label_924, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_921 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_921(i64 %x.i, ptr nonnull %stack)
  ret void

label_930:                                        ; preds = %entry
  %Exception_2362_pointer_917 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_917, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_5466 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5466.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5466, %Pos %z.i)
  %utf8StringLiteral_5468 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_5468.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5468)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_5471 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5471.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_5471)
  %functionPointer_929 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_929(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_934(ptr %stackPointer) {
entry:
  %str_2106_931.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_931.unpack2 = load ptr, ptr %str_2106_931.elt1, align 8, !noalias !0
  %Exception_2362_933.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_933.unpack5 = load ptr, ptr %Exception_2362_933.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_931.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_931.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_931.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_933.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_933.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_933.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_942(ptr %stackPointer) {
entry:
  %str_2106_939.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_939.unpack2 = load ptr, ptr %str_2106_939.elt1, align 8, !noalias !0
  %Exception_2362_941.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_941.unpack5 = load ptr, ptr %Exception_2362_941.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_939.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_939.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_939.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_939.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_939.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_939.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_941.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_941.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_941.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_941.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_941.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_941.unpack5)
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
  %stackPointer_947.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_947.repack1, align 8, !noalias !0
  %index_2107_pointer_949 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_949, align 4, !noalias !0
  %Exception_2362_pointer_950 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_950, align 8, !noalias !0
  %Exception_2362_pointer_950.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_950.repack3, align 8, !noalias !0
  %returnAddress_pointer_951 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_952 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_953 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_913, ptr %returnAddress_pointer_951, align 8, !noalias !0
  store ptr @sharer_934, ptr %sharer_pointer_952, align 8, !noalias !0
  store ptr @eraser_942, ptr %eraser_pointer_953, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_960, label %label_965

label_960:                                        ; preds = %stackAllocate.exit
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
  %returnAddress_957 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_957(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_965:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_965
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

erasePositive.exit:                               ; preds = %label_965, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_962 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_962(%Pos { i64 1, ptr null }, ptr nonnull %stack)
  ret void
}

define tailcc void @reverseOnto_1019(%Pos %l_1017, %Pos %other_1018, ptr %stack) local_unnamed_addr {
entry:
  br label %tailrecurse

tailrecurse:                                      ; preds = %eraseObject.exit, %entry
  %l_1017.tr = phi %Pos [ %l_1017, %entry ], [ %v_y_2986_29876, %eraseObject.exit ]
  %other_1018.tr = phi %Pos [ %other_1018, %entry ], [ %make_5459, %eraseObject.exit ]
  %tag_966 = extractvalue %Pos %l_1017.tr, 0
  switch i64 %tag_966, label %label_968 [
    i64 0, label %label_972
    i64 1, label %label_983
  ]

label_968:                                        ; preds = %tailrecurse
  ret void

label_972:                                        ; preds = %tailrecurse
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_969 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_969(%Pos %other_1018.tr, ptr %stack)
  ret void

label_983:                                        ; preds = %tailrecurse
  %fields_967 = extractvalue %Pos %l_1017.tr, 1
  %environment.i11 = getelementptr i8, ptr %fields_967, i64 16
  %v_y_2985_2988.unpack = load i64, ptr %environment.i11, align 8, !noalias !0
  %v_y_2985_2988.elt1 = getelementptr i8, ptr %fields_967, i64 24
  %v_y_2985_2988.unpack2 = load ptr, ptr %v_y_2985_2988.elt1, align 8, !noalias !0
  %v_y_2986_2987_pointer_975 = getelementptr i8, ptr %fields_967, i64 32
  %v_y_2986_2987.unpack = load i64, ptr %v_y_2986_2987_pointer_975, align 8, !noalias !0
  %v_y_2986_2987.elt4 = getelementptr i8, ptr %fields_967, i64 40
  %v_y_2986_2987.unpack5 = load ptr, ptr %v_y_2986_2987.elt4, align 8, !noalias !0
  %isNull.i.i14 = icmp eq ptr %v_y_2985_2988.unpack2, null
  br i1 %isNull.i.i14, label %sharePositive.exit18, label %next.i.i15

next.i.i15:                                       ; preds = %label_983
  %referenceCount.i.i16 = load i64, ptr %v_y_2985_2988.unpack2, align 4
  %referenceCount.1.i.i17 = add i64 %referenceCount.i.i16, 1
  store i64 %referenceCount.1.i.i17, ptr %v_y_2985_2988.unpack2, align 4
  br label %sharePositive.exit18

sharePositive.exit18:                             ; preds = %label_983, %next.i.i15
  %isNull.i.i = icmp eq ptr %v_y_2986_2987.unpack5, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit18
  %referenceCount.i.i = load i64, ptr %v_y_2986_2987.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2986_2987.unpack5, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %sharePositive.exit18
  %referenceCount.i = load i64, ptr %fields_967, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_967, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i19 = getelementptr i8, ptr %fields_967, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i19, align 8
  tail call void %eraser.i(ptr nonnull %environment.i11)
  tail call void @free(ptr nonnull %fields_967)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_2986_2987.unpack, 0
  %v_y_2986_29876 = insertvalue %Pos %0, ptr %v_y_2986_2987.unpack5, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_414, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2985_2988.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_977.repack7 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2985_2988.unpack2, ptr %environment_977.repack7, align 8, !noalias !0
  %other_1018_pointer_981 = getelementptr i8, ptr %object.i, i64 32
  %other_1018.elt = extractvalue %Pos %other_1018.tr, 0
  store i64 %other_1018.elt, ptr %other_1018_pointer_981, align 8, !noalias !0
  %other_1018_pointer_981.repack9 = getelementptr i8, ptr %object.i, i64 40
  %other_1018.elt10 = extractvalue %Pos %other_1018.tr, 1
  store ptr %other_1018.elt10, ptr %other_1018_pointer_981.repack9, align 8, !noalias !0
  %make_5459 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  br label %tailrecurse
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
  tail call tailcc void @main_2448(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2448(ptr nonnull %stack.i2.i)
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
