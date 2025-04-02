; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:parsing_dollars_f7194448-aa80-454d-bb4a-13e495253b94/main.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:parsing_dollars_f7194448-aa80-454d-bb4a-13e495253b94/main.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_563 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4785_clause_548]
@vtable_594 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4684_clause_586]
@utf8StringLiteral_5496.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_5393.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_5395.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_5398.lit = private constant [1 x i8] c"'"

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #0

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) #1

; Function Attrs: mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite)
declare noalias noundef ptr @realloc(ptr allocptr nocapture, i64 noundef) local_unnamed_addr #2

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

define tailcc void @returnAddress_2(i64 %r_2467, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2467)
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

define tailcc void @returnAddress_14(i64 %returnValue_15, ptr %stack) {
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
  %returnAddress_18 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_18(i64 %returnValue_15, ptr %stack)
  ret void
}

define void @sharer_22(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_26(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_34(%Pos %__16_342_5275, ptr %stack) {
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
  %s_4_154_5218.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %s_4_154_5218.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %s_4_154_5218.unpack2 = load i64, ptr %s_4_154_5218.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__16_342_5275, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %s_4_154_5218.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %s_4_154_5218.unpack2
  %get_5407 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_39 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_39(i64 %get_5407, ptr nonnull %stack)
  ret void
}

define void @sharer_43(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_47(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_56(%Pos %returned_5408, ptr nocapture %stack) {
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
  %returnAddress_58 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_58(%Pos %returned_5408, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_61(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_63(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define tailcc void @returnAddress_69(%Pos %returnValue_70, ptr %stack) {
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
  %returnAddress_73 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_73(%Pos %returnValue_70, ptr %stack)
  ret void
}

define tailcc void @returnAddress_83(%Pos %returnValue_84, ptr %stack) {
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
  %returnAddress_87 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_87(%Pos %returnValue_84, ptr %stack)
  ret void
}

define tailcc void @returnAddress_134(%Pos %__15_8_338_5273, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5386 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_137 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %j_9_18_94_278_5023.unpack = load ptr, ptr %j_9_18_94_278_5023_pointer_137, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %p_4_73_250_5097_pointer_138 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %p_4_73_250_5097 = load ptr, ptr %p_4_73_250_5097_pointer_138, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_139 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %i_7_16_92_276_5069.unpack = load ptr, ptr %i_7_16_92_276_5069_pointer_139, align 8, !noalias !0
  %i_7_16_92_276_5069.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_7_16_92_276_5069.unpack5 = load i64, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  %s_4_154_5218_pointer_140 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %s_4_154_5218.unpack = load ptr, ptr %s_4_154_5218_pointer_140, align 8, !noalias !0
  %s_4_154_5218.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %s_4_154_5218.unpack8 = load i64, ptr %s_4_154_5218.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__15_8_338_5273, 1
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
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 96
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %erasePositive.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 96
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 96
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %erasePositive.exit
  %limit.i11.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %erasePositive.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %erasePositive.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 0, ptr %common.ret.op.i.i, align 4, !noalias !0
  %tmp_5386_pointer_410.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %tmp_5386, ptr %tmp_5386_pointer_410.i, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_411.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store ptr %j_9_18_94_278_5023.unpack, ptr %j_9_18_94_278_5023_pointer_411.i, align 8, !noalias !0
  %j_9_18_94_278_5023_pointer_411.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %j_9_18_94_278_5023.unpack2, ptr %j_9_18_94_278_5023_pointer_411.repack1.i, align 8, !noalias !0
  %p_4_73_250_5097_pointer_412.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_412.i, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_413.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_413.i, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_413.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069_pointer_413.repack3.i, align 8, !noalias !0
  %s_4_154_5218_pointer_414.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr %s_4_154_5218.unpack, ptr %s_4_154_5218_pointer_414.i, align 8, !noalias !0
  %s_4_154_5218_pointer_414.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store i64 %s_4_154_5218.unpack8, ptr %s_4_154_5218_pointer_414.repack5.i, align 8, !noalias !0
  %returnAddress_pointer_415.i = getelementptr i8, ptr %common.ret.op.i.i, i64 72
  %sharer_pointer_416.i = getelementptr i8, ptr %common.ret.op.i.i, i64 80
  %eraser_pointer_417.i = getelementptr i8, ptr %common.ret.op.i.i, i64 88
  store ptr @returnAddress_97, ptr %returnAddress_pointer_415.i, align 8, !noalias !0
  store ptr @sharer_186, ptr %sharer_pointer_416.i, align 8, !noalias !0
  store ptr @eraser_200, ptr %eraser_pointer_417.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %i_7_16_92_276_5069.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i7.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i8.i = load ptr, ptr %base_pointer.i7.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i8.i, i64 %i_7_16_92_276_5069.unpack5
  %get_5443.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i11.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i12.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i12.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_420.i = load ptr, ptr %newStackPointer.i12.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_420.i(i64 %get_5443.i, ptr nonnull %stack)
  ret void
}

define void @sharer_146(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_158(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_126(i64 %v_r_2578_13_6_336_5092, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i20 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i20)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %a_9_4_42_120_304_5012 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5386_pointer_129 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_5386 = load i64, ptr %tmp_5386_pointer_129, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_130 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %j_9_18_94_278_5023.unpack = load ptr, ptr %j_9_18_94_278_5023_pointer_130, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %p_4_73_250_5097_pointer_131 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %p_4_73_250_5097 = load ptr, ptr %p_4_73_250_5097_pointer_131, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_132 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %i_7_16_92_276_5069.unpack = load ptr, ptr %i_7_16_92_276_5069_pointer_132, align 8, !noalias !0
  %i_7_16_92_276_5069.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_7_16_92_276_5069.unpack5 = load i64, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  %s_4_154_5218_pointer_133 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %s_4_154_5218.unpack = load ptr, ptr %s_4_154_5218_pointer_133, align 8, !noalias !0
  %s_4_154_5218.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %s_4_154_5218.unpack8 = load i64, ptr %s_4_154_5218.elt7, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 88
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i24 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i24, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i30 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = add i64 %a_9_4_42_120_304_5012, %v_r_2578_13_6_336_5092
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_5386, ptr %common.ret.op.i, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_167 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %j_9_18_94_278_5023.unpack, ptr %j_9_18_94_278_5023_pointer_167, align 8, !noalias !0
  %j_9_18_94_278_5023_pointer_167.repack10 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %j_9_18_94_278_5023.unpack2, ptr %j_9_18_94_278_5023_pointer_167.repack10, align 8, !noalias !0
  %p_4_73_250_5097_pointer_168 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_168, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_169 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_169, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_169.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069_pointer_169.repack12, align 8, !noalias !0
  %s_4_154_5218_pointer_170 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %s_4_154_5218.unpack, ptr %s_4_154_5218_pointer_170, align 8, !noalias !0
  %s_4_154_5218_pointer_170.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %s_4_154_5218.unpack8, ptr %s_4_154_5218_pointer_170.repack14, align 8, !noalias !0
  %returnAddress_pointer_171 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_172 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_173 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_134, ptr %returnAddress_pointer_171, align 8, !noalias !0
  store ptr @sharer_146, ptr %sharer_pointer_172, align 8, !noalias !0
  store ptr @eraser_158, ptr %eraser_pointer_173, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %s_4_154_5218.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %s_4_154_5218.unpack8
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i31 = icmp ule ptr %nextStackPointer.sink.i, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_177 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_177(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_186(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_200(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -80
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_105(i64 %c_10_5_62_142_326_5052, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i21 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %a_9_4_42_120_304_5012 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5386_pointer_108 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_5386 = load i64, ptr %tmp_5386_pointer_108, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_109 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %j_9_18_94_278_5023.unpack = load ptr, ptr %j_9_18_94_278_5023_pointer_109, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %p_4_73_250_5097_pointer_110 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %p_4_73_250_5097 = load ptr, ptr %p_4_73_250_5097_pointer_110, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_111 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %i_7_16_92_276_5069.unpack = load ptr, ptr %i_7_16_92_276_5069_pointer_111, align 8, !noalias !0
  %i_7_16_92_276_5069.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_7_16_92_276_5069.unpack5 = load i64, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  %s_4_154_5218_pointer_112 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %s_4_154_5218.unpack = load ptr, ptr %s_4_154_5218_pointer_112, align 8, !noalias !0
  %s_4_154_5218.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %s_4_154_5218.unpack8 = load i64, ptr %s_4_154_5218.elt7, align 8, !noalias !0
  switch i64 %c_10_5_62_142_326_5052, label %label_125 [
    i64 36, label %stackAllocate.exit.i
    i64 10, label %stackAllocate.exit
  ]

label_125:                                        ; preds = %entry
  %pair_119 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_73_250_5097)
  %k_7_2_150_341_5418 = extractvalue <{ ptr, ptr }> %pair_119, 0
  %referenceCount.i = load i64, ptr %k_7_2_150_341_5418, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %label_125
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_7_2_150_341_5418, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %label_125
  %stack_pointer.i = getelementptr i8, ptr %k_7_2_150_341_5418, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i22 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i23 = load ptr, ptr %stackPointer_pointer.i22, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i24

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i24

free.i24:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i23, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i23, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i24
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i24
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %stack_120 = extractvalue <{ ptr, ptr }> %pair_119, 1
  %stackPointer_pointer.i25 = getelementptr i8, ptr %stack_120, i64 8
  %stackPointer.i26 = load ptr, ptr %stackPointer_pointer.i25, align 8, !alias.scope !0
  %limit_pointer.i27 = getelementptr i8, ptr %stack_120, i64 24
  %limit.i28 = load ptr, ptr %limit_pointer.i27, align 8, !alias.scope !0
  %isInside.i29 = icmp ule ptr %stackPointer.i26, %limit.i28
  tail call void @llvm.assume(i1 %isInside.i29)
  %newStackPointer.i30 = getelementptr i8, ptr %stackPointer.i26, i64 -24
  store ptr %newStackPointer.i30, ptr %stackPointer_pointer.i25, align 8, !alias.scope !0
  %returnAddress_122 = load ptr, ptr %newStackPointer.i30, align 8, !noalias !0
  musttail call tailcc void %returnAddress_122(%Pos zeroinitializer, ptr %stack_120)
  ret void

stackAllocate.exit:                               ; preds = %entry
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %a_9_4_42_120_304_5012, ptr %newStackPointer.i, align 4, !noalias !0
  store i64 %tmp_5386, ptr %tmp_5386_pointer_108, align 4, !noalias !0
  store ptr %j_9_18_94_278_5023.unpack, ptr %j_9_18_94_278_5023_pointer_109, align 8, !noalias !0
  store i64 %j_9_18_94_278_5023.unpack2, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  store ptr %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_110, align 8, !noalias !0
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_111, align 8, !noalias !0
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  store ptr %s_4_154_5218.unpack, ptr %s_4_154_5218_pointer_112, align 8, !noalias !0
  store i64 %s_4_154_5218.unpack8, ptr %s_4_154_5218.elt7, align 8, !noalias !0
  %sharer_pointer_216 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_217 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_126, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_186, ptr %sharer_pointer_216, align 8, !noalias !0
  store ptr @eraser_200, ptr %eraser_pointer_217, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %s_4_154_5218.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i36 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i37 = load ptr, ptr %base_pointer.i36, align 8
  %varPointer.i = getelementptr i8, ptr %base.i37, i64 %s_4_154_5218.unpack8
  %get_5423 = load i64, ptr %varPointer.i, align 4, !noalias !0
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %isInside.not.i = icmp ugt ptr %eraser_pointer_217, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit65

realloc.i:                                        ; preds = %stackAllocate.exit
  %base_pointer.i62 = getelementptr i8, ptr %stack, i64 16
  %base.i63 = load ptr, ptr %base_pointer.i62, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i63 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 88
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i63, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i64 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i64, i64 88
  store ptr %newBase.i, ptr %base_pointer.i62, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit65

stackAllocate.exit65:                             ; preds = %stackAllocate.exit, %realloc.i
  %limit.i52 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %eraser_pointer_217, %stackAllocate.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i64, %realloc.i ], [ %newStackPointer.i, %stackAllocate.exit ]
  %z.i = add i64 %get_5423, %a_9_4_42_120_304_5012
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_5386, ptr %common.ret.op.i, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_167.i = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %j_9_18_94_278_5023.unpack, ptr %j_9_18_94_278_5023_pointer_167.i, align 8, !noalias !0
  %j_9_18_94_278_5023_pointer_167.repack10.i = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %j_9_18_94_278_5023.unpack2, ptr %j_9_18_94_278_5023_pointer_167.repack10.i, align 8, !noalias !0
  %p_4_73_250_5097_pointer_168.i = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_168.i, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_169.i = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_169.i, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_169.repack12.i = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069_pointer_169.repack12.i, align 8, !noalias !0
  %s_4_154_5218_pointer_170.i = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %s_4_154_5218.unpack, ptr %s_4_154_5218_pointer_170.i, align 8, !noalias !0
  %s_4_154_5218_pointer_170.repack14.i = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %s_4_154_5218.unpack8, ptr %s_4_154_5218_pointer_170.repack14.i, align 8, !noalias !0
  %returnAddress_pointer_171.i = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_172.i = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_173.i = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_134, ptr %returnAddress_pointer_171.i, align 8, !noalias !0
  store ptr @sharer_146, ptr %sharer_pointer_172.i, align 8, !noalias !0
  store ptr @eraser_158, ptr %eraser_pointer_173.i, align 8, !noalias !0
  %stack.i.i57 = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i57, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i58 = getelementptr i8, ptr %base.i, i64 %s_4_154_5218.unpack8
  store i64 %z.i, ptr %varPointer.i58, align 4, !noalias !0
  %isInside.i53 = icmp ule ptr %nextStackPointer.sink.i, %limit.i52
  tail call void @llvm.assume(i1 %isInside.i53)
  %newStackPointer.i54 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i54, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_177.i = load ptr, ptr %newStackPointer.i54, align 8, !noalias !0
  musttail call tailcc void %returnAddress_177.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

stackAllocate.exit.i:                             ; preds = %entry
  %z.i47 = add i64 %a_9_4_42_120_304_5012, 1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %z.i47, ptr %newStackPointer.i, align 4, !noalias !0
  store i64 %tmp_5386, ptr %tmp_5386_pointer_108, align 4, !noalias !0
  store ptr %j_9_18_94_278_5023.unpack, ptr %j_9_18_94_278_5023_pointer_109, align 8, !noalias !0
  store i64 %j_9_18_94_278_5023.unpack2, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  store ptr %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_110, align 8, !noalias !0
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_111, align 8, !noalias !0
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  store ptr %s_4_154_5218.unpack, ptr %s_4_154_5218_pointer_112, align 8, !noalias !0
  store i64 %s_4_154_5218.unpack8, ptr %s_4_154_5218.elt7, align 8, !noalias !0
  %sharer_pointer_416.i = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_417.i = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_97, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_186, ptr %sharer_pointer_416.i, align 8, !noalias !0
  store ptr @eraser_200, ptr %eraser_pointer_417.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %i_7_16_92_276_5069.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i7.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i8.i = load ptr, ptr %base_pointer.i7.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i8.i, i64 %i_7_16_92_276_5069.unpack5
  %get_5443.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  musttail call tailcc void @returnAddress_97(i64 %get_5443.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_261(%Pos %__30_18_60_140_324_5272, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %__30_18_60_140_324_5272, 1
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
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_262 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_262(i64 36, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_258(i64 %v_r_2604_28_16_58_138_322_4998, ptr %stack) {
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
  %j_9_18_94_278_5023.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 8
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
  %limit.i18 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = add i64 %v_r_2604_28_16_58_138_322_4998, -1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_267 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_268 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_261, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_267, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_268, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %j_9_18_94_278_5023.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i13 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i14 = load ptr, ptr %base_pointer.i13, align 8
  %varPointer.i = getelementptr i8, ptr %base.i14, i64 %j_9_18_94_278_5023.unpack2
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i19 = icmp ule ptr %nextStackPointer.sink.i, %limit.i18
  tail call void @llvm.assume(i1 %isInside.i19)
  %newStackPointer.i20 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i20, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_272 = load ptr, ptr %newStackPointer.i20, align 8, !noalias !0
  musttail call tailcc void %returnAddress_272(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_299(%Pos %__26_14_56_136_320_5271, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %__26_14_56_136_320_5271, 1
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
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_300 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_300(i64 10, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_296(i64 %v_r_2600_25_13_55_135_319_5050, ptr %stack) {
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
  %j_9_18_94_278_5023.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 8
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
  %limit.i18 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_305 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_306 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_299, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_305, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_306, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %j_9_18_94_278_5023.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i13 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i14 = load ptr, ptr %base_pointer.i13, align 8
  %varPointer.i = getelementptr i8, ptr %base.i14, i64 %j_9_18_94_278_5023.unpack2
  store i64 %v_r_2600_25_13_55_135_319_5050, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i19 = icmp ule ptr %nextStackPointer.sink.i, %limit.i18
  tail call void @llvm.assume(i1 %isInside.i19)
  %newStackPointer.i20 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i20, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_310 = load ptr, ptr %newStackPointer.i20, align 8, !noalias !0
  musttail call tailcc void %returnAddress_310(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_292(%Pos %__24_12_54_134_318_5270, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i13 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %j_9_18_94_278_5023.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_295 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_7_16_92_276_5069.unpack = load ptr, ptr %i_7_16_92_276_5069_pointer_295, align 8, !noalias !0
  %i_7_16_92_276_5069.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_7_16_92_276_5069.unpack5 = load i64, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__24_12_54_134_318_5270, 1
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
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i16
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i17 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i17, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i23 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i16, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i17, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %j_9_18_94_278_5023.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_315.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %j_9_18_94_278_5023.unpack2, ptr %stackPointer_315.repack7, align 8, !noalias !0
  %returnAddress_pointer_317 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_318 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_319 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_296, ptr %returnAddress_pointer_317, align 8, !noalias !0
  store ptr @sharer_43, ptr %sharer_pointer_318, align 8, !noalias !0
  store ptr @eraser_47, ptr %eraser_pointer_319, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %i_7_16_92_276_5069.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i18 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i19 = load ptr, ptr %base_pointer.i18, align 8
  %varPointer.i = getelementptr i8, ptr %base.i19, i64 %i_7_16_92_276_5069.unpack5
  %get_5437 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i24 = icmp ule ptr %nextStackPointer.sink.i, %limit.i23
  tail call void @llvm.assume(i1 %isInside.i24)
  %newStackPointer.i25 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i25, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_322 = load ptr, ptr %newStackPointer.i25, align 8, !noalias !0
  musttail call tailcc void %returnAddress_322(i64 %get_5437, ptr nonnull %stack)
  ret void
}

define void @sharer_327(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_333(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_288(i64 %v_r_2598_22_10_52_132_316_5172, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  %i_7_16_92_276_5069.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_7_16_92_276_5069.unpack5 = load i64, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_291 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_7_16_92_276_5069.unpack = load ptr, ptr %i_7_16_92_276_5069_pointer_291, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %j_9_18_94_278_5023.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = add i64 %v_r_2598_22_10_52_132_316_5172, 1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %j_9_18_94_278_5023.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_337.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %j_9_18_94_278_5023.unpack2, ptr %stackPointer_337.repack7, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_339 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_339, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_339.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069_pointer_339.repack9, align 8, !noalias !0
  %sharer_pointer_341 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_342 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_292, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_327, ptr %sharer_pointer_341, align 8, !noalias !0
  store ptr @eraser_333, ptr %eraser_pointer_342, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %i_7_16_92_276_5069.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %i_7_16_92_276_5069.unpack5
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_346 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_346(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_251(i64 %v_r_2597_20_8_50_130_314_5209, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i17 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %j_9_18_94_278_5023.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %z.i = icmp eq i64 %v_r_2597_20_8_50_130_314_5209, 0
  br i1 %z.i, label %stackAllocate.exit52, label %label_287

label_287:                                        ; preds = %entry
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 8
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_287
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
  %newStackPointer.i21 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i21, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_287, %realloc.i
  %limit.i27 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_287 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_287 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i21, %realloc.i ], [ %newStackPointer.i, %label_287 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %j_9_18_94_278_5023.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_277.repack11 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %j_9_18_94_278_5023.unpack2, ptr %stackPointer_277.repack11, align 8, !noalias !0
  %returnAddress_pointer_279 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_280 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_281 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_258, ptr %returnAddress_pointer_279, align 8, !noalias !0
  store ptr @sharer_43, ptr %sharer_pointer_280, align 8, !noalias !0
  store ptr @eraser_47, ptr %eraser_pointer_281, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %j_9_18_94_278_5023.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i22 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i23 = load ptr, ptr %base_pointer.i22, align 8
  %varPointer.i = getelementptr i8, ptr %base.i23, i64 %j_9_18_94_278_5023.unpack2
  %get_5432 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i28 = icmp ule ptr %nextStackPointer.sink.i, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_284 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_284(i64 %get_5432, ptr nonnull %stack)
  ret void

stackAllocate.exit52:                             ; preds = %entry
  %i_7_16_92_276_5069.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_7_16_92_276_5069.unpack5 = load i64, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_254 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_7_16_92_276_5069.unpack = load ptr, ptr %i_7_16_92_276_5069_pointer_254, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %j_9_18_94_278_5023.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  store i64 %j_9_18_94_278_5023.unpack2, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_254, align 8, !noalias !0
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  %sharer_pointer_357 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_358 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_288, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_327, ptr %sharer_pointer_357, align 8, !noalias !0
  store ptr @eraser_333, ptr %eraser_pointer_358, align 8, !noalias !0
  %stack_pointer.i.i53 = getelementptr i8, ptr %i_7_16_92_276_5069.unpack, i64 8
  %stack.i.i54 = load ptr, ptr %stack_pointer.i.i53, align 8
  %base_pointer.i55 = getelementptr i8, ptr %stack.i.i54, i64 16
  %base.i56 = load ptr, ptr %base_pointer.i55, align 8
  %varPointer.i57 = getelementptr i8, ptr %base.i56, i64 %i_7_16_92_276_5069.unpack5
  %get_5439 = load i64, ptr %varPointer.i57, align 4, !noalias !0
  %z.i.i = add i64 %get_5439, 1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %j_9_18_94_278_5023.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  store i64 %j_9_18_94_278_5023.unpack2, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_254, align 8, !noalias !0
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  store ptr @returnAddress_292, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_327, ptr %sharer_pointer_357, align 8, !noalias !0
  store ptr @eraser_333, ptr %eraser_pointer_358, align 8, !noalias !0
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i53, align 8
  %base_pointer.i20.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i21.i = load ptr, ptr %base_pointer.i20.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i21.i, i64 %i_7_16_92_276_5069.unpack5
  store i64 %z.i.i, ptr %varPointer.i.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_346.i = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_346.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read, inaccessiblemem: write)
define tailcc void @returnAddress_381(%Pos %v_r_2595_19_7_49_129_313_5118, ptr nocapture readonly %stack) #11 {
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

define tailcc void @returnAddress_97(i64 %v_r_2594_17_5_47_125_309_5163, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i24 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i24)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  %j_9_18_94_278_5023_pointer_101 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %j_9_18_94_278_5023.unpack = load ptr, ptr %j_9_18_94_278_5023_pointer_101, align 8, !noalias !0
  %j_9_18_94_278_5023.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %j_9_18_94_278_5023.unpack2 = load i64, ptr %j_9_18_94_278_5023.elt1, align 8, !noalias !0
  %p_4_73_250_5097_pointer_102 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %p_4_73_250_5097 = load ptr, ptr %p_4_73_250_5097_pointer_102, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_103 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %i_7_16_92_276_5069.unpack = load ptr, ptr %i_7_16_92_276_5069_pointer_103, align 8, !noalias !0
  %i_7_16_92_276_5069.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_7_16_92_276_5069.unpack5 = load i64, ptr %i_7_16_92_276_5069.elt4, align 8, !noalias !0
  %tmp_5386_pointer_100 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_5386 = load i64, ptr %tmp_5386_pointer_100, align 4, !noalias !0
  %z.i = icmp slt i64 %tmp_5386, %v_r_2594_17_5_47_125_309_5163
  %s_4_154_5218.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %s_4_154_5218.unpack8 = load i64, ptr %s_4_154_5218.elt7, align 8, !noalias !0
  %s_4_154_5218_pointer_104 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %s_4_154_5218.unpack = load ptr, ptr %s_4_154_5218_pointer_104, align 8, !noalias !0
  %a_9_4_42_120_304_5012 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %a_9_4_42_120_304_5012, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5386_pointer_240 = getelementptr i8, ptr %stackPointer.i, i64 -64
  store i64 %tmp_5386, ptr %tmp_5386_pointer_240, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_241 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %j_9_18_94_278_5023.unpack, ptr %j_9_18_94_278_5023_pointer_241, align 8, !noalias !0
  %j_9_18_94_278_5023_pointer_241.repack10 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %j_9_18_94_278_5023.unpack2, ptr %j_9_18_94_278_5023_pointer_241.repack10, align 8, !noalias !0
  %p_4_73_250_5097_pointer_242 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_242, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_243 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_243, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_243.repack12 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069_pointer_243.repack12, align 8, !noalias !0
  %s_4_154_5218_pointer_244 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %s_4_154_5218.unpack, ptr %s_4_154_5218_pointer_244, align 8, !noalias !0
  %s_4_154_5218_pointer_244.repack14 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %s_4_154_5218.unpack8, ptr %s_4_154_5218_pointer_244.repack14, align 8, !noalias !0
  %sharer_pointer_246 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_247 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_105, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_186, ptr %sharer_pointer_246, align 8, !noalias !0
  store ptr @eraser_200, ptr %eraser_pointer_247, align 8, !noalias !0
  br i1 %z.i, label %label_395, label %label_380

label_380:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i33 = getelementptr i8, ptr %stackPointer.i, i64 80
  %isInside.not.i34 = icmp ugt ptr %nextStackPointer.i33, %limit.i
  br i1 %isInside.not.i34, label %realloc.i37, label %stackAllocate.exit51

realloc.i37:                                      ; preds = %label_380
  %base_pointer.i38 = getelementptr i8, ptr %stack, i64 16
  %base.i39 = load ptr, ptr %base_pointer.i38, align 8, !alias.scope !0
  %intStackPointer.i40 = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i41 = ptrtoint ptr %base.i39 to i64
  %size.i42 = sub i64 %intStackPointer.i40, %intBase.i41
  %nextSize.i43 = add i64 %size.i42, 56
  %leadingZeros.i.i44 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i43, i1 false)
  %numBits.i.i45 = sub nuw nsw i64 64, %leadingZeros.i.i44
  %result.i.i46 = shl nuw i64 1, %numBits.i.i45
  %newBase.i47 = tail call ptr @realloc(ptr %base.i39, i64 %result.i.i46)
  %newLimit.i48 = getelementptr i8, ptr %newBase.i47, i64 %result.i.i46
  %newStackPointer.i49 = getelementptr i8, ptr %newBase.i47, i64 %size.i42
  %newNextStackPointer.i50 = getelementptr i8, ptr %newStackPointer.i49, i64 56
  store ptr %newBase.i47, ptr %base_pointer.i38, align 8, !alias.scope !0
  store ptr %newLimit.i48, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit51

stackAllocate.exit51:                             ; preds = %label_380, %realloc.i37
  %limit.i57 = phi ptr [ %newLimit.i48, %realloc.i37 ], [ %limit.i, %label_380 ]
  %nextStackPointer.sink.i35 = phi ptr [ %newNextStackPointer.i50, %realloc.i37 ], [ %nextStackPointer.i33, %label_380 ]
  %common.ret.op.i36 = phi ptr [ %newStackPointer.i49, %realloc.i37 ], [ %oldStackPointer.i, %label_380 ]
  store ptr %nextStackPointer.sink.i35, ptr %stackPointer_pointer.i, align 8
  store ptr %j_9_18_94_278_5023.unpack, ptr %common.ret.op.i36, align 8, !noalias !0
  %stackPointer_369.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i36, i64 8
  store i64 %j_9_18_94_278_5023.unpack2, ptr %stackPointer_369.repack16, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_371 = getelementptr i8, ptr %common.ret.op.i36, i64 16
  store ptr %i_7_16_92_276_5069.unpack, ptr %i_7_16_92_276_5069_pointer_371, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_371.repack18 = getelementptr i8, ptr %common.ret.op.i36, i64 24
  store i64 %i_7_16_92_276_5069.unpack5, ptr %i_7_16_92_276_5069_pointer_371.repack18, align 8, !noalias !0
  %returnAddress_pointer_372 = getelementptr i8, ptr %common.ret.op.i36, i64 32
  %sharer_pointer_373 = getelementptr i8, ptr %common.ret.op.i36, i64 40
  %eraser_pointer_374 = getelementptr i8, ptr %common.ret.op.i36, i64 48
  store ptr @returnAddress_251, ptr %returnAddress_pointer_372, align 8, !noalias !0
  store ptr @sharer_327, ptr %sharer_pointer_373, align 8, !noalias !0
  store ptr @eraser_333, ptr %eraser_pointer_374, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %j_9_18_94_278_5023.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i52 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i53 = load ptr, ptr %base_pointer.i52, align 8
  %varPointer.i = getelementptr i8, ptr %base.i53, i64 %j_9_18_94_278_5023.unpack2
  %get_5440 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i58 = icmp ule ptr %nextStackPointer.sink.i35, %limit.i57
  tail call void @llvm.assume(i1 %isInside.i58)
  %newStackPointer.i59 = getelementptr i8, ptr %nextStackPointer.sink.i35, i64 -24
  store ptr %newStackPointer.i59, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_377 = load ptr, ptr %newStackPointer.i59, align 8, !noalias !0
  musttail call tailcc void %returnAddress_377(i64 %get_5440, ptr nonnull %stack)
  ret void

label_395:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i64 = getelementptr i8, ptr %stackPointer.i, i64 48
  %isInside.not.i65 = icmp ugt ptr %nextStackPointer.i64, %limit.i
  br i1 %isInside.not.i65, label %realloc.i68, label %stackAllocate.exit82

realloc.i68:                                      ; preds = %label_395
  %base_pointer.i69 = getelementptr i8, ptr %stack, i64 16
  %base.i70 = load ptr, ptr %base_pointer.i69, align 8, !alias.scope !0
  %intStackPointer.i71 = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i72 = ptrtoint ptr %base.i70 to i64
  %size.i73 = sub i64 %intStackPointer.i71, %intBase.i72
  %nextSize.i74 = add i64 %size.i73, 24
  %leadingZeros.i.i75 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i74, i1 false)
  %numBits.i.i76 = sub nuw nsw i64 64, %leadingZeros.i.i75
  %result.i.i77 = shl nuw i64 1, %numBits.i.i76
  %newBase.i78 = tail call ptr @realloc(ptr %base.i70, i64 %result.i.i77)
  %newLimit.i79 = getelementptr i8, ptr %newBase.i78, i64 %result.i.i77
  %newStackPointer.i80 = getelementptr i8, ptr %newBase.i78, i64 %size.i73
  %newNextStackPointer.i81 = getelementptr i8, ptr %newStackPointer.i80, i64 24
  store ptr %newBase.i78, ptr %base_pointer.i69, align 8, !alias.scope !0
  store ptr %newLimit.i79, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit82

stackAllocate.exit82:                             ; preds = %label_395, %realloc.i68
  %nextStackPointer.sink.i66 = phi ptr [ %newNextStackPointer.i81, %realloc.i68 ], [ %nextStackPointer.i64, %label_395 ]
  %common.ret.op.i67 = phi ptr [ %newStackPointer.i80, %realloc.i68 ], [ %oldStackPointer.i, %label_395 ]
  store ptr %nextStackPointer.sink.i66, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_387 = getelementptr i8, ptr %common.ret.op.i67, i64 8
  %eraser_pointer_388 = getelementptr i8, ptr %common.ret.op.i67, i64 16
  store ptr @returnAddress_381, ptr %common.ret.op.i67, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_387, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_388, align 8, !noalias !0
  %pair_389 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_73_250_5097)
  %k_7_2_128_312_5441 = extractvalue <{ ptr, ptr }> %pair_389, 0
  %referenceCount.i = load i64, ptr %k_7_2_128_312_5441, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %stackAllocate.exit82
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_7_2_128_312_5441, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %stackAllocate.exit82
  %stack_pointer.i = getelementptr i8, ptr %k_7_2_128_312_5441, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i83 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i84 = load ptr, ptr %stackPointer_pointer.i83, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i85

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i85

free.i85:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i84, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i84, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i85
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i85
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %stack_390 = extractvalue <{ ptr, ptr }> %pair_389, 1
  %stackPointer_pointer.i86 = getelementptr i8, ptr %stack_390, i64 8
  %stackPointer.i87 = load ptr, ptr %stackPointer_pointer.i86, align 8, !alias.scope !0
  %limit_pointer.i88 = getelementptr i8, ptr %stack_390, i64 24
  %limit.i89 = load ptr, ptr %limit_pointer.i88, align 8, !alias.scope !0
  %isInside.i90 = icmp ule ptr %stackPointer.i87, %limit.i89
  tail call void @llvm.assume(i1 %isInside.i90)
  %newStackPointer.i91 = getelementptr i8, ptr %stackPointer.i87, i64 -24
  store ptr %newStackPointer.i91, ptr %stackPointer_pointer.i86, align 8, !alias.scope !0
  %returnAddress_392 = load ptr, ptr %newStackPointer.i91, align 8, !noalias !0
  musttail call tailcc void %returnAddress_392(%Pos zeroinitializer, ptr %stack_390)
  ret void
}

define tailcc void @parse_worker_8_3_41_119_303_5122(i64 %a_9_4_42_120_304_5012, i64 %tmp_5386, %Reference %j_9_18_94_278_5023, ptr %p_4_73_250_5097, %Reference %i_7_16_92_276_5069, %Reference %s_4_154_5218, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 96
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 96
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 96
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i11 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %a_9_4_42_120_304_5012, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5386_pointer_410 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5386, ptr %tmp_5386_pointer_410, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_411 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %j_9_18_94_278_5023.elt = extractvalue %Reference %j_9_18_94_278_5023, 0
  store ptr %j_9_18_94_278_5023.elt, ptr %j_9_18_94_278_5023_pointer_411, align 8, !noalias !0
  %j_9_18_94_278_5023_pointer_411.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %j_9_18_94_278_5023.elt2 = extractvalue %Reference %j_9_18_94_278_5023, 1
  store i64 %j_9_18_94_278_5023.elt2, ptr %j_9_18_94_278_5023_pointer_411.repack1, align 8, !noalias !0
  %p_4_73_250_5097_pointer_412 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_4_73_250_5097, ptr %p_4_73_250_5097_pointer_412, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_413 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %i_7_16_92_276_5069.elt = extractvalue %Reference %i_7_16_92_276_5069, 0
  store ptr %i_7_16_92_276_5069.elt, ptr %i_7_16_92_276_5069_pointer_413, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_413.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %i_7_16_92_276_5069.elt4 = extractvalue %Reference %i_7_16_92_276_5069, 1
  store i64 %i_7_16_92_276_5069.elt4, ptr %i_7_16_92_276_5069_pointer_413.repack3, align 8, !noalias !0
  %s_4_154_5218_pointer_414 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %s_4_154_5218.elt = extractvalue %Reference %s_4_154_5218, 0
  store ptr %s_4_154_5218.elt, ptr %s_4_154_5218_pointer_414, align 8, !noalias !0
  %s_4_154_5218_pointer_414.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %s_4_154_5218.elt6 = extractvalue %Reference %s_4_154_5218, 1
  store i64 %s_4_154_5218.elt6, ptr %s_4_154_5218_pointer_414.repack5, align 8, !noalias !0
  %returnAddress_pointer_415 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_416 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_417 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_97, ptr %returnAddress_pointer_415, align 8, !noalias !0
  store ptr @sharer_186, ptr %sharer_pointer_416, align 8, !noalias !0
  store ptr @eraser_200, ptr %eraser_pointer_417, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %i_7_16_92_276_5069.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i7 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i8 = load ptr, ptr %base_pointer.i7, align 8
  %varPointer.i = getelementptr i8, ptr %base.i8, i64 %i_7_16_92_276_5069.elt4
  %get_5443 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i = icmp ule ptr %nextStackPointer.sink.i, %limit.i11
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i12 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i12, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_420 = load ptr, ptr %newStackPointer.i12, align 8, !noalias !0
  musttail call tailcc void %returnAddress_420(i64 %get_5443, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3544_3608, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i23 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i24 = load ptr, ptr %stackPointer_pointer.i23, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i24, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i23, align 8
  %sharer_pointer_12 = getelementptr i8, ptr %stackPointer.i24, i64 8
  %eraser_pointer_13 = getelementptr i8, ptr %stackPointer.i24, i64 16
  store ptr @returnAddress_2, ptr %stackPointer.i24, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_12, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_13, align 8, !noalias !0
  %base_pointer.i14 = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i23, align 8
  %base.i16 = load ptr, ptr %base_pointer.i14, align 8
  %intStack.i17 = ptrtoint ptr %stackPointer.i15 to i64
  %intBase.i18 = ptrtoint ptr %base.i16 to i64
  %offset.i19 = sub i64 %intStack.i17, %intBase.i18
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i31 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i36 = getelementptr i8, ptr %stackPointer.i15, i64 32
  %isInside.not.i37 = icmp ugt ptr %nextStackPointer.i36, %limit.i
  br i1 %isInside.not.i37, label %realloc.i40, label %stackAllocate.exit54

realloc.i40:                                      ; preds = %stackAllocate.exit
  %nextSize.i46 = add i64 %offset.i19, 32
  %leadingZeros.i.i47 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i46, i1 false)
  %numBits.i.i48 = sub nuw nsw i64 64, %leadingZeros.i.i47
  %result.i.i49 = shl nuw i64 1, %numBits.i.i48
  %newBase.i50 = tail call ptr @realloc(ptr %base.i16, i64 %result.i.i49)
  %newLimit.i51 = getelementptr i8, ptr %newBase.i50, i64 %result.i.i49
  %newStackPointer.i52 = getelementptr i8, ptr %newBase.i50, i64 %offset.i19
  %newNextStackPointer.i53 = getelementptr i8, ptr %newStackPointer.i52, i64 32
  store ptr %newBase.i50, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i51, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit54

stackAllocate.exit54:                             ; preds = %stackAllocate.exit, %realloc.i40
  %base.i65 = phi ptr [ %newBase.i50, %realloc.i40 ], [ %base.i16, %stackAllocate.exit ]
  %limit.i58 = phi ptr [ %newLimit.i51, %realloc.i40 ], [ %limit.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i38 = phi ptr [ %newNextStackPointer.i53, %realloc.i40 ], [ %nextStackPointer.i36, %stackAllocate.exit ]
  %common.ret.op.i39 = phi ptr [ %newStackPointer.i52, %realloc.i40 ], [ %stackPointer.i15, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i38, ptr %stackPointer_pointer.i23, align 8
  store i64 0, ptr %common.ret.op.i39, align 4, !noalias !0
  %returnAddress_pointer_31 = getelementptr i8, ptr %common.ret.op.i39, i64 8
  %sharer_pointer_32 = getelementptr i8, ptr %common.ret.op.i39, i64 16
  %eraser_pointer_33 = getelementptr i8, ptr %common.ret.op.i39, i64 24
  store ptr @returnAddress_14, ptr %returnAddress_pointer_31, align 8, !noalias !0
  store ptr @sharer_22, ptr %sharer_pointer_32, align 8, !noalias !0
  store ptr @eraser_26, ptr %eraser_pointer_33, align 8, !noalias !0
  %nextStackPointer.i59 = getelementptr i8, ptr %nextStackPointer.sink.i38, i64 40
  %isInside.not.i60 = icmp ugt ptr %nextStackPointer.i59, %limit.i58
  br i1 %isInside.not.i60, label %realloc.i63, label %stackAllocate.exit77

realloc.i63:                                      ; preds = %stackAllocate.exit54
  %intStackPointer.i66 = ptrtoint ptr %nextStackPointer.sink.i38 to i64
  %intBase.i67 = ptrtoint ptr %base.i65 to i64
  %size.i68 = sub i64 %intStackPointer.i66, %intBase.i67
  %nextSize.i69 = add i64 %size.i68, 40
  %leadingZeros.i.i70 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i69, i1 false)
  %numBits.i.i71 = sub nuw nsw i64 64, %leadingZeros.i.i70
  %result.i.i72 = shl nuw i64 1, %numBits.i.i71
  %newBase.i73 = tail call ptr @realloc(ptr %base.i65, i64 %result.i.i72)
  %newLimit.i74 = getelementptr i8, ptr %newBase.i73, i64 %result.i.i72
  %newStackPointer.i75 = getelementptr i8, ptr %newBase.i73, i64 %size.i68
  %newNextStackPointer.i76 = getelementptr i8, ptr %newStackPointer.i75, i64 40
  store ptr %newBase.i73, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i74, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit77

stackAllocate.exit77:                             ; preds = %stackAllocate.exit54, %realloc.i63
  %nextStackPointer.sink.i61 = phi ptr [ %newNextStackPointer.i76, %realloc.i63 ], [ %nextStackPointer.i59, %stackAllocate.exit54 ]
  %common.ret.op.i62 = phi ptr [ %newStackPointer.i75, %realloc.i63 ], [ %nextStackPointer.sink.i38, %stackAllocate.exit54 ]
  store ptr %nextStackPointer.sink.i61, ptr %stackPointer_pointer.i23, align 8
  store ptr %prompt.i31, ptr %common.ret.op.i62, align 8, !noalias !0
  %stackPointer_50.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i62, i64 8
  store i64 %offset.i19, ptr %stackPointer_50.repack1, align 8, !noalias !0
  %returnAddress_pointer_52 = getelementptr i8, ptr %common.ret.op.i62, i64 16
  %sharer_pointer_53 = getelementptr i8, ptr %common.ret.op.i62, i64 24
  %eraser_pointer_54 = getelementptr i8, ptr %common.ret.op.i62, i64 32
  store ptr @returnAddress_34, ptr %returnAddress_pointer_52, align 8, !noalias !0
  store ptr @sharer_43, ptr %sharer_pointer_53, align 8, !noalias !0
  store ptr @eraser_47, ptr %eraser_pointer_54, align 8, !noalias !0
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
  %nextStackPointer.i84 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i85 = icmp ugt ptr %nextStackPointer.i84, %limit.i.i
  br i1 %isInside.not.i85, label %realloc.i88, label %stackAllocate.exit102

realloc.i88:                                      ; preds = %stackAllocate.exit77
  %newBase.i98 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i99 = getelementptr i8, ptr %newBase.i98, i64 32
  %newNextStackPointer.i101 = getelementptr i8, ptr %newBase.i98, i64 24
  store ptr %newBase.i98, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i99, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit102

stackAllocate.exit102:                            ; preds = %stackAllocate.exit77, %realloc.i88
  %limit.i108 = phi ptr [ %newLimit.i99, %realloc.i88 ], [ %limit.i.i, %stackAllocate.exit77 ]
  %nextStackPointer.sink.i86 = phi ptr [ %newNextStackPointer.i101, %realloc.i88 ], [ %nextStackPointer.i84, %stackAllocate.exit77 ]
  %base.i6 = phi ptr [ %newBase.i98, %realloc.i88 ], [ %stackPointer.i.i, %stackAllocate.exit77 ]
  %sharer_pointer_67 = getelementptr i8, ptr %base.i6, i64 8
  %eraser_pointer_68 = getelementptr i8, ptr %base.i6, i64 16
  store ptr @returnAddress_56, ptr %base.i6, align 8, !noalias !0
  store ptr @sharer_61, ptr %sharer_pointer_67, align 8, !noalias !0
  store ptr @eraser_63, ptr %eraser_pointer_68, align 8, !noalias !0
  %intStack.i7 = ptrtoint ptr %nextStackPointer.sink.i86 to i64
  %intBase.i8 = ptrtoint ptr %base.i6 to i64
  %offset.i9 = sub i64 %intStack.i7, %intBase.i8
  %nextStackPointer.i109 = getelementptr i8, ptr %nextStackPointer.sink.i86, i64 32
  %isInside.not.i110 = icmp ugt ptr %nextStackPointer.i109, %limit.i108
  br i1 %isInside.not.i110, label %realloc.i113, label %stackAllocate.exit127

realloc.i113:                                     ; preds = %stackAllocate.exit102
  %nextSize.i119 = add i64 %offset.i9, 32
  %leadingZeros.i.i120 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i119, i1 false)
  %numBits.i.i121 = sub nuw nsw i64 64, %leadingZeros.i.i120
  %result.i.i122 = shl nuw i64 1, %numBits.i.i121
  %newBase.i123 = tail call ptr @realloc(ptr nonnull %base.i6, i64 %result.i.i122)
  %newLimit.i124 = getelementptr i8, ptr %newBase.i123, i64 %result.i.i122
  %newStackPointer.i125 = getelementptr i8, ptr %newBase.i123, i64 %offset.i9
  %newNextStackPointer.i126 = getelementptr i8, ptr %newStackPointer.i125, i64 32
  store ptr %newBase.i123, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i124, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit127

stackAllocate.exit127:                            ; preds = %stackAllocate.exit102, %realloc.i113
  %limit.i133 = phi ptr [ %newLimit.i124, %realloc.i113 ], [ %limit.i108, %stackAllocate.exit102 ]
  %nextStackPointer.sink.i111 = phi ptr [ %newNextStackPointer.i126, %realloc.i113 ], [ %nextStackPointer.i109, %stackAllocate.exit102 ]
  %common.ret.op.i112 = phi ptr [ %newStackPointer.i125, %realloc.i113 ], [ %nextStackPointer.sink.i86, %stackAllocate.exit102 ]
  store ptr %nextStackPointer.sink.i111, ptr %stack.repack1.i, align 8
  store i64 0, ptr %common.ret.op.i112, align 4, !noalias !0
  %returnAddress_pointer_80 = getelementptr i8, ptr %common.ret.op.i112, i64 8
  %sharer_pointer_81 = getelementptr i8, ptr %common.ret.op.i112, i64 16
  %eraser_pointer_82 = getelementptr i8, ptr %common.ret.op.i112, i64 24
  store ptr @returnAddress_69, ptr %returnAddress_pointer_80, align 8, !noalias !0
  store ptr @sharer_22, ptr %sharer_pointer_81, align 8, !noalias !0
  store ptr @eraser_26, ptr %eraser_pointer_82, align 8, !noalias !0
  %stackPointer.i = load ptr, ptr %stack.repack1.i, align 8
  %base.i = load ptr, ptr %stack.repack1.repack7.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt.i129 = load ptr, ptr %stack.repack3.i, align 8
  %nextStackPointer.i134 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i135 = icmp ugt ptr %nextStackPointer.i134, %limit.i133
  br i1 %isInside.not.i135, label %realloc.i138, label %stackAllocate.exit152

realloc.i138:                                     ; preds = %stackAllocate.exit127
  %nextSize.i144 = add i64 %offset.i, 32
  %leadingZeros.i.i145 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i144, i1 false)
  %numBits.i.i146 = sub nuw nsw i64 64, %leadingZeros.i.i145
  %result.i.i147 = shl nuw i64 1, %numBits.i.i146
  %newBase.i148 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i147)
  %newLimit.i149 = getelementptr i8, ptr %newBase.i148, i64 %result.i.i147
  %newStackPointer.i150 = getelementptr i8, ptr %newBase.i148, i64 %offset.i
  %newNextStackPointer.i151 = getelementptr i8, ptr %newStackPointer.i150, i64 32
  store ptr %newBase.i148, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i149, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit152

stackAllocate.exit152:                            ; preds = %stackAllocate.exit127, %realloc.i138
  %limit.i.i153 = phi ptr [ %newLimit.i149, %realloc.i138 ], [ %limit.i133, %stackAllocate.exit127 ]
  %nextStackPointer.sink.i136 = phi ptr [ %newNextStackPointer.i151, %realloc.i138 ], [ %nextStackPointer.i134, %stackAllocate.exit127 ]
  %common.ret.op.i137 = phi ptr [ %newStackPointer.i150, %realloc.i138 ], [ %stackPointer.i, %stackAllocate.exit127 ]
  store ptr %nextStackPointer.sink.i136, ptr %stack.repack1.i, align 8
  store i64 0, ptr %common.ret.op.i137, align 4, !noalias !0
  %returnAddress_pointer_94 = getelementptr i8, ptr %common.ret.op.i137, i64 8
  %sharer_pointer_95 = getelementptr i8, ptr %common.ret.op.i137, i64 16
  %eraser_pointer_96 = getelementptr i8, ptr %common.ret.op.i137, i64 24
  store ptr @returnAddress_83, ptr %returnAddress_pointer_94, align 8, !noalias !0
  store ptr @sharer_22, ptr %sharer_pointer_95, align 8, !noalias !0
  store ptr @eraser_26, ptr %eraser_pointer_96, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i136, i64 96
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i153
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit152
  %base.i.i = load ptr, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i136 to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 96
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 96
  store ptr %newBase.i.i, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit152
  %limit.i11.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i153, %stackAllocate.exit152 ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit152 ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i136, %stackAllocate.exit152 ]
  %unboxed.i = extractvalue %Pos %v_coe_3544_3608, 0
  store ptr %nextStackPointer.sink.i.i, ptr %stack.repack1.i, align 8
  store i64 0, ptr %common.ret.op.i.i, align 4, !noalias !0
  %tmp_5386_pointer_410.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %unboxed.i, ptr %tmp_5386_pointer_410.i, align 4, !noalias !0
  %j_9_18_94_278_5023_pointer_411.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store ptr %prompt.i129, ptr %j_9_18_94_278_5023_pointer_411.i, align 8, !noalias !0
  %j_9_18_94_278_5023_pointer_411.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %offset.i, ptr %j_9_18_94_278_5023_pointer_411.repack1.i, align 8, !noalias !0
  %p_4_73_250_5097_pointer_412.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %calloc.i.i, ptr %p_4_73_250_5097_pointer_412.i, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_413.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %calloc.i.i, ptr %i_7_16_92_276_5069_pointer_413.i, align 8, !noalias !0
  %i_7_16_92_276_5069_pointer_413.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store i64 %offset.i9, ptr %i_7_16_92_276_5069_pointer_413.repack3.i, align 8, !noalias !0
  %s_4_154_5218_pointer_414.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr %prompt.i31, ptr %s_4_154_5218_pointer_414.i, align 8, !noalias !0
  %s_4_154_5218_pointer_414.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store i64 %offset.i19, ptr %s_4_154_5218_pointer_414.repack5.i, align 8, !noalias !0
  %returnAddress_pointer_415.i = getelementptr i8, ptr %common.ret.op.i.i, i64 72
  %sharer_pointer_416.i = getelementptr i8, ptr %common.ret.op.i.i, i64 80
  %eraser_pointer_417.i = getelementptr i8, ptr %common.ret.op.i.i, i64 88
  store ptr @returnAddress_97, ptr %returnAddress_pointer_415.i, align 8, !noalias !0
  store ptr @sharer_186, ptr %sharer_pointer_416.i, align 8, !noalias !0
  store ptr @eraser_200, ptr %eraser_pointer_417.i, align 8, !noalias !0
  %stack.i.i.i = load ptr, ptr %stack_pointer.i, align 8
  %base_pointer.i7.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i8.i = load ptr, ptr %base_pointer.i7.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i8.i, i64 %offset.i9
  %get_5443.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i11.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i12.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i12.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_420.i = load ptr, ptr %newStackPointer.i12.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_420.i(i64 %get_5443.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_428(%Pos %returned_5445, ptr nocapture %stack) {
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
  %returnAddress_430 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_430(%Pos %returned_5445, ptr %rest.i)
  ret void
}

define void @eraser_444(ptr nocapture readonly %environment) {
entry:
  %tmp_5346_442.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5346_442.unpack2 = load ptr, ptr %tmp_5346_442.elt1, align 8, !noalias !0
  %acc_3_3_5_169_4838_443.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_4838_443.unpack5 = load ptr, ptr %acc_3_3_5_169_4838_443.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_5346_442.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_5346_442.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_5346_442.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_5346_442.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_5346_442.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_5346_442.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_4838_443.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_4838_443.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_4838_443.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_4838_443.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_4838_443.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_4838_443.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4680(i64 %start_2_2_4_168_4831, %Pos %acc_3_3_5_169_4838, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4831, 1
  br i1 %z.i6, label %label_454, label %label_450

label_450:                                        ; preds = %entry, %label_450
  %acc_3_3_5_169_4838.tr8 = phi %Pos [ %make_5451, %label_450 ], [ %acc_3_3_5_169_4838, %entry ]
  %start_2_2_4_168_4831.tr7 = phi i64 [ %z.i5, %label_450 ], [ %start_2_2_4_168_4831, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4831.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4831.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_444, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5448.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_5448.elt, ptr %environment.i, align 8, !noalias !0
  %environment_441.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5448.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_5448.elt2, ptr %environment_441.repack1, align 8, !noalias !0
  %acc_3_3_5_169_4838_pointer_448 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_4838.elt = extractvalue %Pos %acc_3_3_5_169_4838.tr8, 0
  store i64 %acc_3_3_5_169_4838.elt, ptr %acc_3_3_5_169_4838_pointer_448, align 8, !noalias !0
  %acc_3_3_5_169_4838_pointer_448.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_4838.elt4 = extractvalue %Pos %acc_3_3_5_169_4838.tr8, 1
  store ptr %acc_3_3_5_169_4838.elt4, ptr %acc_3_3_5_169_4838_pointer_448.repack3, align 8, !noalias !0
  %make_5451 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4831.tr7, 2
  br i1 %z.i, label %label_454, label %label_450

label_454:                                        ; preds = %label_450, %entry
  %acc_3_3_5_169_4838.tr.lcssa = phi %Pos [ %acc_3_3_5_169_4838, %entry ], [ %make_5451, %label_450 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_451 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_451(%Pos %acc_3_3_5_169_4838.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_465(%Pos %v_r_2703_32_59_223_4725, ptr %stack) {
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
  %p_8_9_4572 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %acc_8_35_199_4777_pointer_468 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %acc_8_35_199_4777 = load i64, ptr %acc_8_35_199_4777_pointer_468, align 4, !noalias !0
  %v_r_2620_30_194_4609_pointer_469 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_r_2620_30_194_4609.unpack = load i64, ptr %v_r_2620_30_194_4609_pointer_469, align 8, !noalias !0
  %v_r_2620_30_194_4609.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2620_30_194_4609.unpack2 = load ptr, ptr %v_r_2620_30_194_4609.elt1, align 8, !noalias !0
  %tmp_5353_pointer_470 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5353 = load i64, ptr %tmp_5353_pointer_470, align 4, !noalias !0
  %index_7_34_198_4707_pointer_471 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %index_7_34_198_4707 = load i64, ptr %index_7_34_198_4707_pointer_471, align 4, !noalias !0
  %tag_472 = extractvalue %Pos %v_r_2703_32_59_223_4725, 0
  %fields_473 = extractvalue %Pos %v_r_2703_32_59_223_4725, 1
  switch i64 %tag_472, label %common.ret [
    i64 1, label %label_497
    i64 0, label %label_504
  ]

common.ret:                                       ; preds = %entry
  ret void

label_485:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2620_30_194_4609.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_485
  %referenceCount.i.i37 = load i64, ptr %v_r_2620_30_194_4609.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2620_30_194_4609.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2620_30_194_4609.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2620_30_194_4609.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2620_30_194_4609.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_485, %decr.i.i39, %free.i.i41
  %pair_480 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4572)
  %k_13_14_4_5280 = extractvalue <{ ptr, ptr }> %pair_480, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_5280, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_5280, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_5280, i64 40
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
  %stack_481 = extractvalue <{ ptr, ptr }> %pair_480, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_481, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_481, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_482 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_482(%Pos { i64 5, ptr null }, ptr %stack_481)
  ret void

label_494:                                        ; preds = %label_496
  %isNull.i.i24 = icmp eq ptr %v_r_2620_30_194_4609.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_494
  %referenceCount.i.i26 = load i64, ptr %v_r_2620_30_194_4609.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2620_30_194_4609.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2620_30_194_4609.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2620_30_194_4609.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2620_30_194_4609.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_494, %decr.i.i28, %free.i.i30
  %pair_489 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4572)
  %k_13_14_4_5279 = extractvalue <{ ptr, ptr }> %pair_489, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_5279, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_5279, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5279, i64 40
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
  %stack_490 = extractvalue <{ ptr, ptr }> %pair_489, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_490, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_490, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_491 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_491(%Pos { i64 5, ptr null }, ptr %stack_490)
  ret void

label_495:                                        ; preds = %label_496
  %0 = insertvalue %Pos poison, i64 %v_r_2620_30_194_4609.unpack, 0
  %v_r_2620_30_194_46093 = insertvalue %Pos %0, ptr %v_r_2620_30_194_4609.unpack2, 1
  %z.i = add i64 %index_7_34_198_4707, 1
  %z.i108 = mul i64 %acc_8_35_199_4777, 10
  %z.i109 = sub i64 %z.i108, %tmp_5353
  %z.i110 = add i64 %z.i109, %v_coe_3519_46_73_237_4709.unpack
  musttail call tailcc void @go_6_33_197_4666(i64 %z.i, i64 %z.i110, ptr %p_8_9_4572, %Pos %v_r_2620_30_194_46093, i64 %tmp_5353, ptr nonnull %stack)
  ret void

label_496:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3519_46_73_237_4709.unpack, 58
  br i1 %z.i111, label %label_495, label %label_494

label_497:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_473, i64 16
  %v_coe_3519_46_73_237_4709.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3519_46_73_237_4709.elt4 = getelementptr i8, ptr %fields_473, i64 24
  %v_coe_3519_46_73_237_4709.unpack5 = load ptr, ptr %v_coe_3519_46_73_237_4709.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3519_46_73_237_4709.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_497
  %referenceCount.i.i = load i64, ptr %v_coe_3519_46_73_237_4709.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3519_46_73_237_4709.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_497
  %referenceCount.i11 = load i64, ptr %fields_473, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_473, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_473, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_473)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_3519_46_73_237_4709.unpack, 47
  br i1 %z.i112, label %label_496, label %label_485

label_504:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_473, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_504
  %referenceCount.i = load i64, ptr %fields_473, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_473, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_473, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_473, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_473)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_504, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_2620_30_194_4609.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2620_30_194_4609.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2620_30_194_4609.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2620_30_194_4609.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2620_30_194_4609.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2620_30_194_4609.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_501 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_501(i64 %acc_8_35_199_4777, ptr nonnull %stack)
  ret void
}

define void @sharer_510(ptr %stackPointer) {
entry:
  %v_r_2620_30_194_4609_507.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2620_30_194_4609_507.unpack2 = load ptr, ptr %v_r_2620_30_194_4609_507.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2620_30_194_4609_507.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2620_30_194_4609_507.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2620_30_194_4609_507.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_522(ptr %stackPointer) {
entry:
  %v_r_2620_30_194_4609_519.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2620_30_194_4609_519.unpack2 = load ptr, ptr %v_r_2620_30_194_4609_519.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2620_30_194_4609_519.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2620_30_194_4609_519.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2620_30_194_4609_519.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2620_30_194_4609_519.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2620_30_194_4609_519.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2620_30_194_4609_519.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_539(%Pos %returned_5476, ptr nocapture %stack) {
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
  %returnAddress_541 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_541(%Pos %returned_5476, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_4785_clause_548(ptr %closure, %Pos %exc_8_20_47_211_4711, %Pos %msg_9_21_48_212_4748, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4864 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_551 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4864)
  %k_11_23_50_214_4896 = extractvalue <{ ptr, ptr }> %pair_551, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_4896, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_4896, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_4896, i64 40
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
  %stack_552 = extractvalue <{ ptr, ptr }> %pair_551, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_444, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_4711.elt = extractvalue %Pos %exc_8_20_47_211_4711, 0
  store i64 %exc_8_20_47_211_4711.elt, ptr %environment.i, align 8, !noalias !0
  %environment_554.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_4711.elt2 = extractvalue %Pos %exc_8_20_47_211_4711, 1
  store ptr %exc_8_20_47_211_4711.elt2, ptr %environment_554.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4748_pointer_558 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4748.elt = extractvalue %Pos %msg_9_21_48_212_4748, 0
  store i64 %msg_9_21_48_212_4748.elt, ptr %msg_9_21_48_212_4748_pointer_558, align 8, !noalias !0
  %msg_9_21_48_212_4748_pointer_558.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4748.elt4 = extractvalue %Pos %msg_9_21_48_212_4748, 1
  store ptr %msg_9_21_48_212_4748.elt4, ptr %msg_9_21_48_212_4748_pointer_558.repack3, align 8, !noalias !0
  %make_5477 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_552, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_552, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_560 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_560(%Pos %make_5477, ptr %stack_552)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_567(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_575(ptr nocapture readonly %environment) {
entry:
  %tmp_5355_574.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5355_574.unpack2 = load ptr, ptr %tmp_5355_574.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5355_574.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5355_574.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5355_574.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5355_574.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5355_574.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5355_574.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_571(i64 %v_coe_3518_6_28_55_219_4778, ptr %stack) {
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
  store ptr @eraser_575, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3518_6_28_55_219_4778, ptr %environment.i, align 8, !noalias !0
  %environment_573.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_573.repack1, align 8, !noalias !0
  %make_5479 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_579 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_579(%Pos %make_5479, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_4666(i64 %index_7_34_198_4707, i64 %acc_8_35_199_4777, ptr %p_8_9_4572, %Pos %v_r_2620_30_194_4609, i64 %tmp_5353, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2620_30_194_4609, 1
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
  store ptr %p_8_9_4572, ptr %common.ret.op.i, align 8, !noalias !0
  %acc_8_35_199_4777_pointer_531 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %acc_8_35_199_4777, ptr %acc_8_35_199_4777_pointer_531, align 4, !noalias !0
  %v_r_2620_30_194_4609_pointer_532 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2620_30_194_4609.elt = extractvalue %Pos %v_r_2620_30_194_4609, 0
  store i64 %v_r_2620_30_194_4609.elt, ptr %v_r_2620_30_194_4609_pointer_532, align 8, !noalias !0
  %v_r_2620_30_194_4609_pointer_532.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i3, ptr %v_r_2620_30_194_4609_pointer_532.repack1, align 8, !noalias !0
  %tmp_5353_pointer_533 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %tmp_5353, ptr %tmp_5353_pointer_533, align 4, !noalias !0
  %index_7_34_198_4707_pointer_534 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %index_7_34_198_4707, ptr %index_7_34_198_4707_pointer_534, align 4, !noalias !0
  %returnAddress_pointer_535 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_536 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_537 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_465, ptr %returnAddress_pointer_535, align 8, !noalias !0
  store ptr @sharer_510, ptr %sharer_pointer_536, align 8, !noalias !0
  store ptr @eraser_522, ptr %eraser_pointer_537, align 8, !noalias !0
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
  %sharer_pointer_546 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_547 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_539, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_61, ptr %sharer_pointer_546, align 8, !noalias !0
  store ptr @eraser_63, ptr %eraser_pointer_547, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_567, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_4785 = insertvalue %Neg { ptr @vtable_563, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_584 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_585 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_571, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_584, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_585, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2620_30_194_4609, i64 %index_7_34_198_4707, %Neg %Exception_7_19_46_210_4785, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_4684_clause_586(ptr %closure, %Pos %exception_10_107_134_298_5480, %Pos %msg_11_108_135_299_5481, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4572 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_5480, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_5481, 1
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
  %pair_589 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4572)
  %k_13_14_4_5336 = extractvalue <{ ptr, ptr }> %pair_589, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_5336, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_5336, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5336, i64 40
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
  %stack_590 = extractvalue <{ ptr, ptr }> %pair_589, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_590, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_590, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_591 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_591(%Pos { i64 5, ptr null }, ptr %stack_590)
  ret void
}

define tailcc void @returnAddress_605(i64 %v_coe_3523_22_131_158_322_4827, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3523_22_131_158_322_4827, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_606 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_606(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_617(i64 %v_r_2717_1_9_20_129_156_320_4705, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2717_1_9_20_129_156_320_4705
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_618 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_618(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_600(i64 %v_r_2716_3_14_123_150_314_4739, ptr %stack) {
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
  %p_8_9_4572 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2620_30_194_4609_pointer_603 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2620_30_194_4609.unpack = load i64, ptr %v_r_2620_30_194_4609_pointer_603, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2620_30_194_4609.unpack, 0
  %v_r_2620_30_194_4609.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2620_30_194_4609.unpack2 = load ptr, ptr %v_r_2620_30_194_4609.elt1, align 8, !noalias !0
  %v_r_2620_30_194_46093 = insertvalue %Pos %0, ptr %v_r_2620_30_194_4609.unpack2, 1
  %tmp_5353_pointer_604 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5353 = load i64, ptr %tmp_5353_pointer_604, align 4, !noalias !0
  %z.i = icmp eq i64 %v_r_2716_3_14_123_150_314_4739, 45
  %isInside.not.i = icmp ugt ptr %tmp_5353_pointer_604, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %tmp_5353_pointer_604, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_611 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_612 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_605, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_611, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_612, align 8, !noalias !0
  br i1 %z.i, label %label_625, label %label_616

label_616:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_4666(i64 0, i64 0, ptr %p_8_9_4572, %Pos %v_r_2620_30_194_46093, i64 %tmp_5353, ptr nonnull %stack)
  ret void

label_625:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_625
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

stackAllocate.exit35:                             ; preds = %label_625, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_625 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_625 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_623 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_624 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_617, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_623, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_624, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_4666(i64 1, i64 0, ptr %p_8_9_4572, %Pos %v_r_2620_30_194_46093, i64 %tmp_5353, ptr nonnull %stack)
  ret void
}

define void @sharer_629(ptr %stackPointer) {
entry:
  %v_r_2620_30_194_4609_627.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2620_30_194_4609_627.unpack2 = load ptr, ptr %v_r_2620_30_194_4609_627.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2620_30_194_4609_627.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2620_30_194_4609_627.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2620_30_194_4609_627.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_637(ptr %stackPointer) {
entry:
  %v_r_2620_30_194_4609_635.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2620_30_194_4609_635.unpack2 = load ptr, ptr %v_r_2620_30_194_4609_635.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2620_30_194_4609_635.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2620_30_194_4609_635.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2620_30_194_4609_635.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2620_30_194_4609_635.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2620_30_194_4609_635.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2620_30_194_4609_635.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_462(%Pos %v_r_2620_30_194_4609, ptr %stack) {
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
  %p_8_9_4572 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_567, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4572, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2620_30_194_4609, 1
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
  store ptr %p_8_9_4572, ptr %common.ret.op.i, align 8, !noalias !0
  %v_r_2620_30_194_4609_pointer_644 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_r_2620_30_194_4609.elt = extractvalue %Pos %v_r_2620_30_194_4609, 0
  store i64 %v_r_2620_30_194_4609.elt, ptr %v_r_2620_30_194_4609_pointer_644, align 8, !noalias !0
  %v_r_2620_30_194_4609_pointer_644.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i3, ptr %v_r_2620_30_194_4609_pointer_644.repack1, align 8, !noalias !0
  %tmp_5353_pointer_645 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 48, ptr %tmp_5353_pointer_645, align 4, !noalias !0
  %returnAddress_pointer_646 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_647 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_648 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_600, ptr %returnAddress_pointer_646, align 8, !noalias !0
  store ptr @sharer_629, ptr %sharer_pointer_647, align 8, !noalias !0
  store ptr @eraser_637, ptr %eraser_pointer_648, align 8, !noalias !0
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
  store i64 %v_r_2620_30_194_4609.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_743.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_743.repack1.i, align 8, !noalias !0
  %index_2107_pointer_745.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_745.i, align 4, !noalias !0
  %Exception_2362_pointer_746.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_594, ptr %Exception_2362_pointer_746.i, align 8, !noalias !0
  %Exception_2362_pointer_746.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_746.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_747.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_748.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_749.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_709, ptr %returnAddress_pointer_747.i, align 8, !noalias !0
  store ptr @sharer_730, ptr %sharer_pointer_748.i, align 8, !noalias !0
  store ptr @eraser_738, ptr %eraser_pointer_749.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2620_30_194_4609)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_753.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_753.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_650(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_654(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_459(%Pos %v_r_2619_24_188_4803, ptr %stack) {
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
  %p_8_9_4572 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4572, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_660 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_661 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_462, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_650, ptr %sharer_pointer_660, align 8, !noalias !0
  store ptr @eraser_654, ptr %eraser_pointer_661, align 8, !noalias !0
  %tag_662 = extractvalue %Pos %v_r_2619_24_188_4803, 0
  switch i64 %tag_662, label %label_664 [
    i64 0, label %label_668
    i64 1, label %label_674
  ]

label_664:                                        ; preds = %stackAllocate.exit
  ret void

label_668:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_5496 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5496.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_665 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_665(%Pos %utf8StringLiteral_5496, ptr nonnull %stack)
  ret void

label_674:                                        ; preds = %stackAllocate.exit
  %fields_663 = extractvalue %Pos %v_r_2619_24_188_4803, 1
  %environment.i = getelementptr i8, ptr %fields_663, i64 16
  %v_y_3345_8_29_193_4655.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3345_8_29_193_4655.elt1 = getelementptr i8, ptr %fields_663, i64 24
  %v_y_3345_8_29_193_4655.unpack2 = load ptr, ptr %v_y_3345_8_29_193_4655.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3345_8_29_193_4655.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_674
  %referenceCount.i.i = load i64, ptr %v_y_3345_8_29_193_4655.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3345_8_29_193_4655.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_674
  %referenceCount.i = load i64, ptr %fields_663, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_663, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_663, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_663)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3345_8_29_193_4655.unpack, 0
  %v_y_3345_8_29_193_46553 = insertvalue %Pos %0, ptr %v_y_3345_8_29_193_4655.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_671 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_671(%Pos %v_y_3345_8_29_193_46553, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_456(%Pos %v_r_2618_13_177_4779, ptr %stack) {
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
  %p_8_9_4572 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4572, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_680 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_681 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_459, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_650, ptr %sharer_pointer_680, align 8, !noalias !0
  store ptr @eraser_654, ptr %eraser_pointer_681, align 8, !noalias !0
  %tag_682 = extractvalue %Pos %v_r_2618_13_177_4779, 0
  switch i64 %tag_682, label %label_684 [
    i64 0, label %label_689
    i64 1, label %label_701
  ]

label_684:                                        ; preds = %stackAllocate.exit
  ret void

label_689:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4572, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_462, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_650, ptr %sharer_pointer_680, align 8, !noalias !0
  store ptr @eraser_654, ptr %eraser_pointer_681, align 8, !noalias !0
  %utf8StringLiteral_5496.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5496.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_665.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_665.i(%Pos %utf8StringLiteral_5496.i, ptr nonnull %stack)
  ret void

label_701:                                        ; preds = %stackAllocate.exit
  %fields_683 = extractvalue %Pos %v_r_2618_13_177_4779, 1
  %environment.i6 = getelementptr i8, ptr %fields_683, i64 16
  %v_y_2854_10_21_185_4843.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_2854_10_21_185_4843.elt1 = getelementptr i8, ptr %fields_683, i64 24
  %v_y_2854_10_21_185_4843.unpack2 = load ptr, ptr %v_y_2854_10_21_185_4843.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2854_10_21_185_4843.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_701
  %referenceCount.i.i = load i64, ptr %v_y_2854_10_21_185_4843.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2854_10_21_185_4843.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_701
  %referenceCount.i = load i64, ptr %fields_683, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_683, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_683, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_683)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_575, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2854_10_21_185_4843.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_694.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2854_10_21_185_4843.unpack2, ptr %environment_694.repack4, align 8, !noalias !0
  %make_5498 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_698 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_698(%Pos %make_5498, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2453(ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_425 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_426 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_425, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_426, align 8, !noalias !0
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
  %sharer_pointer_435 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_436 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_428, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_61, ptr %sharer_pointer_435, align 8, !noalias !0
  store ptr @eraser_63, ptr %eraser_pointer_436, align 8, !noalias !0
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
  %returnAddress_pointer_706 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_707 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_708 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_456, ptr %returnAddress_pointer_706, align 8, !noalias !0
  store ptr @sharer_650, ptr %sharer_pointer_707, align 8, !noalias !0
  store ptr @eraser_654, ptr %eraser_pointer_708, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_454.i, label %label_450.i

label_450.i:                                      ; preds = %stackAllocate.exit46, %label_450.i
  %acc_3_3_5_169_4838.tr8.i = phi %Pos [ %make_5451.i, %label_450.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4831.tr7.i = phi i64 [ %z.i5.i, %label_450.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4831.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4831.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_444, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_5448.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_5448.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_441.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_5448.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_5448.elt2.i, ptr %environment_441.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_4838_pointer_448.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_4838.elt.i = extractvalue %Pos %acc_3_3_5_169_4838.tr8.i, 0
  store i64 %acc_3_3_5_169_4838.elt.i, ptr %acc_3_3_5_169_4838_pointer_448.i, align 8, !noalias !0
  %acc_3_3_5_169_4838_pointer_448.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_4838.elt4.i = extractvalue %Pos %acc_3_3_5_169_4838.tr8.i, 1
  store ptr %acc_3_3_5_169_4838.elt4.i, ptr %acc_3_3_5_169_4838_pointer_448.repack3.i, align 8, !noalias !0
  %make_5451.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4831.tr7.i, 2
  br i1 %z.i.i, label %label_454.i.loopexit, label %label_450.i

label_454.i.loopexit:                             ; preds = %label_450.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_454.i

label_454.i:                                      ; preds = %label_454.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_454.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_454.i.loopexit ]
  %acc_3_3_5_169_4838.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_5451.i, %label_454.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_451.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_451.i(%Pos %acc_3_3_5_169_4838.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_709(%Pos %v_r_2785_3575, ptr %stack) {
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
  %index_2107_pointer_712 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_712, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_714 = extractvalue %Pos %v_r_2785_3575, 0
  switch i64 %tag_714, label %label_716 [
    i64 0, label %label_720
    i64 1, label %label_726
  ]

label_716:                                        ; preds = %entry
  ret void

label_720:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_720
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

eraseNegative.exit:                               ; preds = %label_720, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_717 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_717(i64 %x.i, ptr nonnull %stack)
  ret void

label_726:                                        ; preds = %entry
  %Exception_2362_pointer_713 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_713, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_5393 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5393.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5393, %Pos %z.i)
  %utf8StringLiteral_5395 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_5395.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5395)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_5398 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5398.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_5398)
  %functionPointer_725 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_725(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_730(ptr %stackPointer) {
entry:
  %str_2106_727.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_727.unpack2 = load ptr, ptr %str_2106_727.elt1, align 8, !noalias !0
  %Exception_2362_729.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_729.unpack5 = load ptr, ptr %Exception_2362_729.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_727.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_727.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_727.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_729.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_729.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_729.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_738(ptr %stackPointer) {
entry:
  %str_2106_735.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_735.unpack2 = load ptr, ptr %str_2106_735.elt1, align 8, !noalias !0
  %Exception_2362_737.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_737.unpack5 = load ptr, ptr %Exception_2362_737.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_735.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_735.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_735.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_735.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_735.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_735.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_737.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_737.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_737.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_737.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_737.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_737.unpack5)
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
  %stackPointer_743.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_743.repack1, align 8, !noalias !0
  %index_2107_pointer_745 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_745, align 4, !noalias !0
  %Exception_2362_pointer_746 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_746, align 8, !noalias !0
  %Exception_2362_pointer_746.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_746.repack3, align 8, !noalias !0
  %returnAddress_pointer_747 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_748 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_749 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_709, ptr %returnAddress_pointer_747, align 8, !noalias !0
  store ptr @sharer_730, ptr %sharer_pointer_748, align 8, !noalias !0
  store ptr @eraser_738, ptr %eraser_pointer_749, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_756, label %label_761

label_756:                                        ; preds = %stackAllocate.exit
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
  %returnAddress_753 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_753(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_761:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_761
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

erasePositive.exit:                               ; preds = %label_761, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_758 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_758(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  tail call tailcc void @main_2453(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2453(ptr nonnull %stack.i2.i)
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
