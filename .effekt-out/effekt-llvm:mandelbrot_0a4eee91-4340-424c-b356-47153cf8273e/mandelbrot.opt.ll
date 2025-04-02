; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:mandelbrot_0a4eee91-4340-424c-b356-47153cf8273e/mandelbrot.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:mandelbrot_0a4eee91-4340-424c-b356-47153cf8273e/mandelbrot.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_1844 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_5086_clause_1829]
@vtable_1875 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_5189_clause_1867]
@utf8StringLiteral_5983.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_5802.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_5804.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_5807.lit = private constant [1 x i8] c"'"

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
define double @infixAdd_111(double %x_109, double %y_110) local_unnamed_addr #5 {
  %z = fadd double %x_109, %y_110
  ret double %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define double @infixMul_114(double %x_112, double %y_113) local_unnamed_addr #5 {
  %z = fmul double %x_112, %y_113
  ret double %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define double @infixSub_117(double %x_115, double %y_116) local_unnamed_addr #5 {
  %z = fsub double %x_115, %y_116
  ret double %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define double @infixDiv_120(double %x_118, double %y_119) local_unnamed_addr #5 {
  %z = fdiv double %x_118, %y_119
  ret double %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define double @toDouble_156(i64 %d_155) local_unnamed_addr #5 {
  %z = sitofp i64 %d_155 to double
  ret double %z
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
define %Pos @infixGt_202(double %x_200, double %y_201) local_unnamed_addr #5 {
  %z = fcmp ogt double %x_200, %y_201
  %fat_z = zext i1 %z to i64
  %adt_boolean = insertvalue %Pos zeroinitializer, i64 %fat_z, 0
  ret %Pos %adt_boolean
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @bitwiseShl_228(i64 %x_226, i64 %y_227) local_unnamed_addr #5 {
  %z = shl i64 %x_226, %y_227
  ret i64 %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @bitwiseXor_240(i64 %x_238, i64 %y_239) local_unnamed_addr #5 {
  %z = xor i64 %y_239, %x_238
  ret i64 %z
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

define tailcc void @returnAddress_2(i64 %r_2489, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2489)
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

define tailcc void @returnAddress_34(i64 %returnValue_35, ptr %stack) {
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
  %returnAddress_38 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_38(i64 %returnValue_35, ptr %stack)
  ret void
}

define tailcc void @returnAddress_48(i64 %returnValue_49, ptr %stack) {
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
  %returnAddress_52 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_52(i64 %returnValue_49, ptr %stack)
  ret void
}

define tailcc void @returnAddress_78(%Pos %__8_173_357_357_5630, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %i_6_91_275_275_5504 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5795_pointer_81 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_5795 = load i64, ptr %tmp_5795_pointer_81, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_82 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_82, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %tmp_5760_pointer_83 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_5760 = load double, ptr %tmp_5760_pointer_83, align 8, !noalias !0
  %sum_3_3_5426_pointer_84 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_84, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_85 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_85, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__8_173_357_357_5630, 1
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
  %0 = insertvalue %Reference poison, ptr %byteAcc_5_5_5418.unpack, 0
  %byteAcc_5_5_54189 = insertvalue %Reference %0, i64 %byteAcc_5_5_5418.unpack8, 1
  %1 = insertvalue %Reference poison, ptr %sum_3_3_5426.unpack, 0
  %sum_3_3_54266 = insertvalue %Reference %1, i64 %sum_3_3_5426.unpack5, 1
  %2 = insertvalue %Reference poison, ptr %bitNum_7_7_5558.unpack, 0
  %bitNum_7_7_55583 = insertvalue %Reference %2, i64 %bitNum_7_7_5558.unpack2, 1
  %z.i = add i64 %i_6_91_275_275_5504, 1
  musttail call tailcc void @loop_5_90_274_274_5441(i64 %z.i, i64 %tmp_5795, %Reference %bitNum_7_7_55583, double %tmp_5760, %Reference %sum_3_3_54266, %Reference %byteAcc_5_5_54189, ptr nonnull %stack)
  ret void
}

define void @sharer_92(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_106(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -80
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_124(%Pos %returnValue_125, ptr %stack) {
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
  %returnAddress_128 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_128(%Pos %returnValue_125, ptr %stack)
  ret void
}

define void @sharer_132(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_136(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_144(%Pos %returnValue_145, ptr %stack) {
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
  %returnAddress_148 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_148(%Pos %returnValue_145, ptr %stack)
  ret void
}

define tailcc void @returnAddress_158(%Pos %returnValue_159, ptr %stack) {
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
  %returnAddress_162 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_162(%Pos %returnValue_159, ptr %stack)
  ret void
}

define tailcc void @returnAddress_172(%Pos %returnValue_173, ptr %stack) {
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
  %returnAddress_176 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_176(%Pos %returnValue_173, ptr %stack)
  ret void
}

define tailcc void @returnAddress_187(%Pos %returnValue_188, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_r_2563_16_107_291_291_5489.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2563_16_107_291_291_5489.unpack2 = load ptr, ptr %v_r_2563_16_107_291_291_5489.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2563_16_107_291_291_5489.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2563_16_107_291_291_5489.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2563_16_107_291_291_5489.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2563_16_107_291_291_5489.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2563_16_107_291_291_5489.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2563_16_107_291_291_5489.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_191 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_191(%Pos %returnValue_188, ptr nonnull %stack)
  ret void
}

define void @sharer_195(ptr %stackPointer) {
entry:
  %v_r_2563_16_107_291_291_5489_194.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2563_16_107_291_291_5489_194.unpack2 = load ptr, ptr %v_r_2563_16_107_291_291_5489_194.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2563_16_107_291_291_5489_194.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2563_16_107_291_291_5489_194.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2563_16_107_291_291_5489_194.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_199(ptr %stackPointer) {
entry:
  %v_r_2563_16_107_291_291_5489_198.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2563_16_107_291_291_5489_198.unpack2 = load ptr, ptr %v_r_2563_16_107_291_291_5489_198.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2563_16_107_291_291_5489_198.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2563_16_107_291_291_5489_198.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2563_16_107_291_291_5489_198.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2563_16_107_291_291_5489_198.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2563_16_107_291_291_5489_198.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2563_16_107_291_291_5489_198.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_207(%Pos %returnValue_208, ptr %stack) {
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
  %returnAddress_211 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_211(%Pos %returnValue_208, ptr %stack)
  ret void
}

define tailcc void @returnAddress_374(%Pos %v_whileThen_2581_53_144_328_328_5621, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_377 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_377, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_378 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_378, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_379 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_379, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_380 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_380, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_381 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_381, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_382 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_382, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_383 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_383, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %object.i = extractvalue %Pos %v_whileThen_2581_53_144_328_328_5621, 1
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
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 136
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %erasePositive.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 136
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 136
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %erasePositive.exit
  %limit.i2328.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %erasePositive.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %erasePositive.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_1042.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_1042.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_1042.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_1042.repack1.i, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_1043.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_1043.i, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_1043.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_1043.repack3.i, align 8, !noalias !0
  %tmp_5760_pointer_1044.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_1044.i, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_1045.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_1045.i, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_1045.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_1045.repack5.i, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_1046.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_1046.i, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_1046.repack7.i = getelementptr i8, ptr %common.ret.op.i.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_1046.repack7.i, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_1047.i = getelementptr i8, ptr %common.ret.op.i.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_1047.i, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_1047.repack9.i = getelementptr i8, ptr %common.ret.op.i.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_1047.repack9.i, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1048.i = getelementptr i8, ptr %common.ret.op.i.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_1048.i, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1048.repack11.i = getelementptr i8, ptr %common.ret.op.i.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_1048.repack11.i, align 8, !noalias !0
  %returnAddress_pointer_1049.i = getelementptr i8, ptr %common.ret.op.i.i, i64 112
  %sharer_pointer_1050.i = getelementptr i8, ptr %common.ret.op.i.i, i64 120
  %eraser_pointer_1051.i = getelementptr i8, ptr %common.ret.op.i.i, i64 128
  store ptr @returnAddress_221, ptr %returnAddress_pointer_1049.i, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_1050.i, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_1051.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %notDone_17_108_292_292_5542.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i19.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i20.i = load ptr, ptr %base_pointer.i19.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i20.i, i64 %notDone_17_108_292_292_5542.unpack8
  %notDone_17_108_292_292_5542_old_1053.elt13.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %notDone_17_108_292_292_5542_old_1053.unpack14.i = load ptr, ptr %notDone_17_108_292_292_5542_old_1053.elt13.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %notDone_17_108_292_292_5542_old_1053.unpack14.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %notDone_17_108_292_292_5542_old_1053.unpack14.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %notDone_17_108_292_292_5542_old_1053.unpack14.i, align 4
  %get_5887.unpack17.pre.i = load ptr, ptr %notDone_17_108_292_292_5542_old_1053.elt13.i, align 8, !noalias !0
  %stackPointer.i.pre.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i23.pre.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i23.i = phi ptr [ %limit.i2328.i, %stackAllocate.exit.i ], [ %limit.i23.pre.i, %next.i.i.i ]
  %stackPointer.i.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i.pre.i, %next.i.i.i ]
  %get_5887.unpack17.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_5887.unpack17.pre.i, %next.i.i.i ]
  %get_5887.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5887.unpack.i, 0
  %get_588718.i = insertvalue %Pos %0, ptr %get_5887.unpack17.i, 1
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i23.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i24.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i24.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1054.i = load ptr, ptr %newStackPointer.i24.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1054.i(%Pos %get_588718.i, ptr nonnull %stack)
  ret void
}

define void @sharer_392(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -136
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -128
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_410(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -136
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -120
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_364(i64 %v_r_2579_51_142_326_326_5487, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_373 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_373, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_372 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_372, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_371 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_371, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_370 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_370, align 8, !noalias !0
  %tmp_5760_pointer_369 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_369, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_368 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_368, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_367 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_367, align 8, !noalias !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = add i64 %v_r_2579_51_142_326_326_5487, 1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_422 = getelementptr i8, ptr %stackPointer.i, i64 -104
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_422, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_422.repack19 = getelementptr i8, ptr %stackPointer.i, i64 -96
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_422.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_423 = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_423, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_423.repack21 = getelementptr i8, ptr %stackPointer.i, i64 -80
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_423.repack21, align 8, !noalias !0
  %tmp_5760_pointer_424 = getelementptr i8, ptr %stackPointer.i, i64 -72
  store double %tmp_5760, ptr %tmp_5760_pointer_424, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_425 = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_425, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_425.repack23 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_425.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_426 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_426, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_426.repack25 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_426.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_427 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_427, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_427.repack27 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_427.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_428 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_428, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_428.repack29 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_428.repack29, align 8, !noalias !0
  %sharer_pointer_430 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_431 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_374, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_430, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_431, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %z_15_106_290_290_5374.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %z_15_106_290_290_5374.unpack11
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_435 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_435(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_354(%Pos %__50_141_325_325_5620, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_357 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_357, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_358 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_358, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_359 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_359, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_360 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_360, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_361 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_361, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_362 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_362, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_363 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_363, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %object.i = extractvalue %Pos %__50_141_325_325_5620, 1
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
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 136
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i38
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 136
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 136
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i45 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i38, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_456 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_456, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_456.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_456.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_457 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_457, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_457.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_457.repack21, align 8, !noalias !0
  %tmp_5760_pointer_458 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_458, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_459 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_459, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_459.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_459.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_460 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_460, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_460.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_460.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_461 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_461, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_461.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_461.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_462 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_462, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_462.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_462.repack29, align 8, !noalias !0
  %returnAddress_pointer_463 = getelementptr i8, ptr %common.ret.op.i, i64 112
  %sharer_pointer_464 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %eraser_pointer_465 = getelementptr i8, ptr %common.ret.op.i, i64 128
  store ptr @returnAddress_364, ptr %returnAddress_pointer_463, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_464, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_465, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %z_15_106_290_290_5374.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %z_15_106_290_290_5374.unpack11
  %get_5867 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i46 = icmp ule ptr %nextStackPointer.sink.i, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_468 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_468(i64 %get_5867, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_507(%Pos %__49_140_324_324_5619, ptr %stack) {
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
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack2 = load i64, ptr %escape_19_110_294_294_5368.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__49_140_324_324_5619, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %escape_19_110_294_294_5368.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %escape_19_110_294_294_5368.unpack2
  store i64 1, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_513 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_513(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_517(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_521(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_343(double %v_r_2575_46_137_321_321_5396, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i41 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i41)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -120
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_346 = getelementptr i8, ptr %stackPointer.i, i64 -112
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_346, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_347 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_347, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_348 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %tmp_5760 = load double, ptr %tmp_5760_pointer_348, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_349 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_349, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_350 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_350, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %v_r_2574_45_136_320_320_5523_pointer_351 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_2574_45_136_320_320_5523 = load double, ptr %v_r_2574_45_136_320_320_5523_pointer_351, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_352 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_352, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_353 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_353, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %z.i = fadd double %v_r_2574_45_136_320_320_5523, %v_r_2575_46_137_321_321_5396
  %z.i42 = fcmp ogt double %z.i, 4.000000e+00
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 136
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i46 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i46, i64 136
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i56 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i46, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_489 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_489, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_489.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_489.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_490 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_490, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_490.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_490.repack21, align 8, !noalias !0
  %tmp_5760_pointer_491 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_491, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_492 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_492, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_492.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_492.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_493 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_493, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_493.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_493.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_494 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_494, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_494.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_494.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_495 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_495, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_495.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_495.repack29, align 8, !noalias !0
  %returnAddress_pointer_496 = getelementptr i8, ptr %common.ret.op.i, i64 112
  %sharer_pointer_497 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %eraser_pointer_498 = getelementptr i8, ptr %common.ret.op.i, i64 128
  store ptr @returnAddress_354, ptr %returnAddress_pointer_496, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_497, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_498, align 8, !noalias !0
  br i1 %z.i42, label %label_536, label %label_506

label_506:                                        ; preds = %stackAllocate.exit
  %isInside.i51 = icmp ule ptr %nextStackPointer.sink.i, %limit.i56
  tail call void @llvm.assume(i1 %isInside.i51)
  %newStackPointer.i52 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i52, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_503 = load ptr, ptr %newStackPointer.i52, align 8, !noalias !0
  musttail call tailcc void %returnAddress_503(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_536:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i57 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 40
  %isInside.not.i58 = icmp ugt ptr %nextStackPointer.i57, %limit.i56
  br i1 %isInside.not.i58, label %realloc.i61, label %stackAllocate.exit75

realloc.i61:                                      ; preds = %label_536
  %base_pointer.i62 = getelementptr i8, ptr %stack, i64 16
  %base.i63 = load ptr, ptr %base_pointer.i62, align 8, !alias.scope !0
  %intStackPointer.i64 = ptrtoint ptr %nextStackPointer.sink.i to i64
  %intBase.i65 = ptrtoint ptr %base.i63 to i64
  %size.i66 = sub i64 %intStackPointer.i64, %intBase.i65
  %nextSize.i67 = add i64 %size.i66, 40
  %leadingZeros.i.i68 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i67, i1 false)
  %numBits.i.i69 = sub nuw nsw i64 64, %leadingZeros.i.i68
  %result.i.i70 = shl nuw i64 1, %numBits.i.i69
  %newBase.i71 = tail call ptr @realloc(ptr %base.i63, i64 %result.i.i70)
  %newLimit.i72 = getelementptr i8, ptr %newBase.i71, i64 %result.i.i70
  %newStackPointer.i73 = getelementptr i8, ptr %newBase.i71, i64 %size.i66
  %newNextStackPointer.i74 = getelementptr i8, ptr %newStackPointer.i73, i64 40
  store ptr %newBase.i71, ptr %base_pointer.i62, align 8, !alias.scope !0
  store ptr %newLimit.i72, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit75

stackAllocate.exit75:                             ; preds = %label_536, %realloc.i61
  %nextStackPointer.sink.i59 = phi ptr [ %newNextStackPointer.i74, %realloc.i61 ], [ %nextStackPointer.i57, %label_536 ]
  %common.ret.op.i60 = phi ptr [ %newStackPointer.i73, %realloc.i61 ], [ %nextStackPointer.sink.i, %label_536 ]
  store ptr %nextStackPointer.sink.i59, ptr %stackPointer_pointer.i, align 8
  store ptr %escape_19_110_294_294_5368.unpack, ptr %common.ret.op.i60, align 8, !noalias !0
  %stackPointer_524.repack31 = getelementptr inbounds i8, ptr %common.ret.op.i60, i64 8
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %stackPointer_524.repack31, align 8, !noalias !0
  %returnAddress_pointer_526 = getelementptr i8, ptr %common.ret.op.i60, i64 16
  %sharer_pointer_527 = getelementptr i8, ptr %common.ret.op.i60, i64 24
  %eraser_pointer_528 = getelementptr i8, ptr %common.ret.op.i60, i64 32
  store ptr @returnAddress_507, ptr %returnAddress_pointer_526, align 8, !noalias !0
  store ptr @sharer_517, ptr %sharer_pointer_527, align 8, !noalias !0
  store ptr @eraser_521, ptr %eraser_pointer_528, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %notDone_17_108_292_292_5542.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i76 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i77 = load ptr, ptr %base_pointer.i76, align 8
  %varPointer.i = getelementptr i8, ptr %base.i77, i64 %notDone_17_108_292_292_5542.unpack8
  %notDone_17_108_292_292_5542_old_531.elt33 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %notDone_17_108_292_292_5542_old_531.unpack34 = load ptr, ptr %notDone_17_108_292_292_5542_old_531.elt33, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %notDone_17_108_292_292_5542_old_531.unpack34, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit75
  %referenceCount.i.i = load i64, ptr %notDone_17_108_292_292_5542_old_531.unpack34, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %notDone_17_108_292_292_5542_old_531.unpack34, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %notDone_17_108_292_292_5542_old_531.unpack34, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %notDone_17_108_292_292_5542_old_531.unpack34, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %notDone_17_108_292_292_5542_old_531.unpack34)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %stackAllocate.exit75, %decr.i.i, %free.i.i
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %varPointer.i, i8 0, i64 16, i1 false)
  %stackPointer.i79 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i81 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i82 = icmp ule ptr %stackPointer.i79, %limit.i81
  tail call void @llvm.assume(i1 %isInside.i82)
  %newStackPointer.i83 = getelementptr i8, ptr %stackPointer.i79, i64 -24
  store ptr %newStackPointer.i83, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_533 = load ptr, ptr %newStackPointer.i83, align 8, !noalias !0
  musttail call tailcc void %returnAddress_533(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_546(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -144
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -136
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_566(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -144
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -128
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_333(double %v_r_2574_45_136_320_320_5523, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_336 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_336, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_337 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_337, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_338 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_338, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_339 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_339, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_340 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_340, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_341 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_341, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_342 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_342, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 144
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 144
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i45 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_579 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_579, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_579.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_579.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_580 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_580, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_580.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_580.repack21, align 8, !noalias !0
  %tmp_5760_pointer_581 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_581, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_582 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_582, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_582.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_582.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_583 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_583, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_583.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_583.repack25, align 8, !noalias !0
  %v_r_2574_45_136_320_320_5523_pointer_584 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store double %v_r_2574_45_136_320_320_5523, ptr %v_r_2574_45_136_320_320_5523_pointer_584, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_585 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_585, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_585.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_585.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_586 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_586, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_586.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_586.repack29, align 8, !noalias !0
  %returnAddress_pointer_587 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %sharer_pointer_588 = getelementptr i8, ptr %common.ret.op.i, i64 128
  %eraser_pointer_589 = getelementptr i8, ptr %common.ret.op.i, i64 136
  store ptr @returnAddress_343, ptr %returnAddress_pointer_587, align 8, !noalias !0
  store ptr @sharer_546, ptr %sharer_pointer_588, align 8, !noalias !0
  store ptr @eraser_566, ptr %eraser_pointer_589, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zizi_7_98_282_282_5424.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %zizi_7_98_282_282_5424.unpack2
  %get_5873 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i46 = icmp ule ptr %nextStackPointer.sink.i, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_592 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_592(double %get_5873, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_323(%Pos %__44_135_319_319_5618, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_326 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_326, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_327 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_327, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_328 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_328, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_329 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_329, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_330 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_330, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_331 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_331, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_332 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_332, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %object.i = extractvalue %Pos %__44_135_319_319_5618, 1
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
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 136
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i38
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 136
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 136
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i45 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i38, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_613 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_613, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_613.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_613.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_614 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_614, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_614.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_614.repack21, align 8, !noalias !0
  %tmp_5760_pointer_615 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_615, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_616 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_616, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_616.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_616.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_617 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_617, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_617.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_617.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_618 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_618, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_618.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_618.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_619 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_619, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_619.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_619.repack29, align 8, !noalias !0
  %returnAddress_pointer_620 = getelementptr i8, ptr %common.ret.op.i, i64 112
  %sharer_pointer_621 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %eraser_pointer_622 = getelementptr i8, ptr %common.ret.op.i, i64 128
  store ptr @returnAddress_333, ptr %returnAddress_pointer_620, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_621, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_622, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zrzr_3_94_278_278_5552.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %zrzr_3_94_278_278_5552.unpack5
  %get_5874 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i46 = icmp ule ptr %nextStackPointer.sink.i, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_625 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_625(double %get_5874, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_312(double %v_r_2572_42_133_317_317_5311, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -120
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_315 = getelementptr i8, ptr %stackPointer.i, i64 -112
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_315, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_316 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_316, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %v_r_2571_41_132_316_316_5302_pointer_317 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %v_r_2571_41_132_316_316_5302 = load double, ptr %v_r_2571_41_132_316_316_5302_pointer_317, align 8, !noalias !0
  %tmp_5760_pointer_318 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_318, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_319 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_319, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_320 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_320, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_321 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_321, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_322 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_322, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 136
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 136
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i45 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = fmul double %v_r_2571_41_132_316_316_5302, %v_r_2572_42_133_317_317_5311
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_646 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_646, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_646.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_646.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_647 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_647, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_647.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_647.repack21, align 8, !noalias !0
  %tmp_5760_pointer_648 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_648, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_649 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_649, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_649.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_649.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_650 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_650, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_650.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_650.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_651 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_651, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_651.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_651.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_652 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_652, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_652.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_652.repack29, align 8, !noalias !0
  %returnAddress_pointer_653 = getelementptr i8, ptr %common.ret.op.i, i64 112
  %sharer_pointer_654 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %eraser_pointer_655 = getelementptr i8, ptr %common.ret.op.i, i64 128
  store ptr @returnAddress_323, ptr %returnAddress_pointer_653, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_654, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_655, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zizi_7_98_282_282_5424.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %zizi_7_98_282_282_5424.unpack2
  store double %z.i, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i46 = icmp ule ptr %nextStackPointer.sink.i, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_659 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_659(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_671(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -144
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -136
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_691(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -144
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -128
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_302(double %v_r_2571_41_132_316_316_5302, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_305 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_305, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_306 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_306, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_307 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_307, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_308 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_308, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_309 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_309, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_310 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_310, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_311 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_311, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 144
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 144
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i45 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_704 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_704, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_704.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_704.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_705 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_705, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_705.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_705.repack21, align 8, !noalias !0
  %v_r_2571_41_132_316_316_5302_pointer_706 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %v_r_2571_41_132_316_316_5302, ptr %v_r_2571_41_132_316_316_5302_pointer_706, align 8, !noalias !0
  %tmp_5760_pointer_707 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store double %tmp_5760, ptr %tmp_5760_pointer_707, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_708 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_708, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_708.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_708.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_709 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_709, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_709.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_709.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_710 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_710, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_710.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_710.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_711 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_711, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_711.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_711.repack29, align 8, !noalias !0
  %returnAddress_pointer_712 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %sharer_pointer_713 = getelementptr i8, ptr %common.ret.op.i, i64 128
  %eraser_pointer_714 = getelementptr i8, ptr %common.ret.op.i, i64 136
  store ptr @returnAddress_312, ptr %returnAddress_pointer_712, align 8, !noalias !0
  store ptr @sharer_671, ptr %sharer_pointer_713, align 8, !noalias !0
  store ptr @eraser_691, ptr %eraser_pointer_714, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zi_5_96_280_280_5410.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %zi_5_96_280_280_5410.unpack14
  %get_5876 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i46 = icmp ule ptr %nextStackPointer.sink.i, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_717 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_717(double %get_5876, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_292(%Pos %__40_131_315_315_5617, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_295 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_295, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_296 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_296, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_297 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_297, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_298 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_298, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_299 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_299, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_300 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_300, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_301 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_301, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %object.i = extractvalue %Pos %__40_131_315_315_5617, 1
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
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 136
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i38
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 136
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 136
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i45 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i38, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_738 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_738, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_738.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_738.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_739 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_739, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_739.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_739.repack21, align 8, !noalias !0
  %tmp_5760_pointer_740 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_740, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_741 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_741, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_741.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_741.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_742 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_742, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_742.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_742.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_743 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_743, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_743.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_743.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_744 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_744, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_744.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_744.repack29, align 8, !noalias !0
  %returnAddress_pointer_745 = getelementptr i8, ptr %common.ret.op.i, i64 112
  %sharer_pointer_746 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %eraser_pointer_747 = getelementptr i8, ptr %common.ret.op.i, i64 128
  store ptr @returnAddress_302, ptr %returnAddress_pointer_745, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_746, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_747, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zi_5_96_280_280_5410.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %zi_5_96_280_280_5410.unpack14
  %get_5877 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i46 = icmp ule ptr %nextStackPointer.sink.i, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_750 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_750(double %get_5877, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_281(%Pos %__38_129_313_313_5616, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -120
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_284 = getelementptr i8, ptr %stackPointer.i, i64 -112
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_284, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_285 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_285, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_286 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %tmp_5760 = load double, ptr %tmp_5760_pointer_286, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_287 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_287, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_288 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_288, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_289 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_289, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %tmp_5769_pointer_290 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_5769 = load double, ptr %tmp_5769_pointer_290, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_291 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_291, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %object.i = extractvalue %Pos %__38_129_313_313_5616, 1
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
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 136
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i38
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 136
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 136
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i45 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i38, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  %z.i = fmul double %tmp_5769, %tmp_5769
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_771 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_771, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_771.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_771.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_772 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_772, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_772.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_772.repack21, align 8, !noalias !0
  %tmp_5760_pointer_773 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_773, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_774 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_774, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_774.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_774.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_775 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_775, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_775.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_775.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_776 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_776, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_776.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_776.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_777 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_777, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_777.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_777.repack29, align 8, !noalias !0
  %returnAddress_pointer_778 = getelementptr i8, ptr %common.ret.op.i, i64 112
  %sharer_pointer_779 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %eraser_pointer_780 = getelementptr i8, ptr %common.ret.op.i, i64 128
  store ptr @returnAddress_292, ptr %returnAddress_pointer_778, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_779, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_780, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zrzr_3_94_278_278_5552.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %zrzr_3_94_278_278_5552.unpack5
  store double %z.i, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i46 = icmp ule ptr %nextStackPointer.sink.i, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_784 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_784(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_796(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -144
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -136
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_816(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -144
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -128
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_270(double %v_r_2568_34_125_309_309_5432, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -120
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_280 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_280, align 8, !noalias !0
  %tmp_5769_pointer_279 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_5769 = load double, ptr %tmp_5769_pointer_279, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_278 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_278, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_277 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_277, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_276 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_276, align 8, !noalias !0
  %tmp_5760_pointer_275 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %tmp_5760 = load double, ptr %tmp_5760_pointer_275, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_274 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_274, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_273 = getelementptr i8, ptr %stackPointer.i, i64 -112
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_273, align 8, !noalias !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = fmul double %tmp_5769, 2.000000e+00
  %z.i36 = fmul double %z.i, %v_r_2568_34_125_309_309_5432
  %z.i37 = fadd double %tmp_5760, %z.i36
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_829 = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_829, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_829.repack19 = getelementptr i8, ptr %stackPointer.i, i64 -104
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_829.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_830 = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_830, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_830.repack21 = getelementptr i8, ptr %stackPointer.i, i64 -88
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_830.repack21, align 8, !noalias !0
  %tmp_5760_pointer_831 = getelementptr i8, ptr %stackPointer.i, i64 -80
  store double %tmp_5760, ptr %tmp_5760_pointer_831, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_832 = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_832, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_832.repack23 = getelementptr i8, ptr %stackPointer.i, i64 -64
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_832.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_833 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_833, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_833.repack25 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_833.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_834 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_834, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_834.repack27 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_834.repack27, align 8, !noalias !0
  %tmp_5769_pointer_835 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store double %tmp_5769, ptr %tmp_5769_pointer_835, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_836 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_836, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_836.repack29 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_836.repack29, align 8, !noalias !0
  %sharer_pointer_838 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_839 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_281, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_796, ptr %sharer_pointer_838, align 8, !noalias !0
  store ptr @eraser_816, ptr %eraser_pointer_839, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zi_5_96_280_280_5410.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i42 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i43 = load ptr, ptr %base_pointer.i42, align 8
  %varPointer.i = getelementptr i8, ptr %base.i43, i64 %zi_5_96_280_280_5410.unpack14
  store double %z.i37, ptr %varPointer.i, align 8, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_843 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_843(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_259(double %v_r_2567_30_121_305_305_5293, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -120
  %v_r_2566_29_120_304_304_5353_pointer_269 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2566_29_120_304_304_5353 = load double, ptr %v_r_2566_29_120_304_304_5353_pointer_269, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_268 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_268, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_267 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_267, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_266 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_266, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_265 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_265, align 8, !noalias !0
  %tmp_5760_pointer_264 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %tmp_5760 = load double, ptr %tmp_5760_pointer_264, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_263 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_263, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_262 = getelementptr i8, ptr %stackPointer.i, i64 -112
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_262, align 8, !noalias !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = fsub double %v_r_2566_29_120_304_304_5353, %v_r_2567_30_121_305_305_5293
  %z.i36 = fadd double %z.i, %tmp_5766
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_262, align 8, !noalias !0
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_263, align 8, !noalias !0
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  store double %tmp_5760, ptr %tmp_5760_pointer_264, align 8, !noalias !0
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_265, align 8, !noalias !0
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_266, align 8, !noalias !0
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_267, align 8, !noalias !0
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  store double %z.i36, ptr %escape_19_110_294_294_5368_pointer_268, align 8, !noalias !0
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %v_r_2566_29_120_304_304_5353_pointer_269, align 8, !noalias !0
  %sharer_pointer_875 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_876 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_270, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_796, ptr %sharer_pointer_875, align 8, !noalias !0
  store ptr @eraser_816, ptr %eraser_pointer_876, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zi_5_96_280_280_5410.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i41 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i42 = load ptr, ptr %base_pointer.i41, align 8
  %varPointer.i = getelementptr i8, ptr %base.i42, i64 %zi_5_96_280_280_5410.unpack14
  %get_5880 = load double, ptr %varPointer.i, align 8, !noalias !0
  %z.i.i = fmul double %z.i36, 2.000000e+00
  %z.i36.i = fmul double %z.i.i, %get_5880
  %z.i37.i = fadd double %tmp_5760, %z.i36.i
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_262, align 8, !noalias !0
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_263, align 8, !noalias !0
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  store double %tmp_5760, ptr %tmp_5760_pointer_264, align 8, !noalias !0
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_265, align 8, !noalias !0
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_266, align 8, !noalias !0
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_267, align 8, !noalias !0
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  store double %z.i36, ptr %escape_19_110_294_294_5368_pointer_268, align 8, !noalias !0
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %v_r_2566_29_120_304_304_5353_pointer_269, align 8, !noalias !0
  store ptr @returnAddress_281, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_796, ptr %sharer_pointer_875, align 8, !noalias !0
  store ptr @eraser_816, ptr %eraser_pointer_876, align 8, !noalias !0
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i42.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i43.i = load ptr, ptr %base_pointer.i42.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i43.i, i64 %zi_5_96_280_280_5410.unpack14
  store double %z.i37.i, ptr %varPointer.i.i, align 8, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_843.i = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_843.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_891(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -144
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -136
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_911(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -144
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -128
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_249(double %v_r_2566_29_120_304_304_5353, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_252 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_252, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_253 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_253, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %tmp_5760_pointer_254 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_254, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_255 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_255, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_256 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_256, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_257 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_257, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_258 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_258, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 144
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 144
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i45 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_924 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_924, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_924.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_924.repack19, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_925 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_925, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_925.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_925.repack21, align 8, !noalias !0
  %tmp_5760_pointer_926 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_926, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_927 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_927, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_927.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_927.repack23, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_928 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_928, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_928.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_928.repack25, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_929 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_929, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_929.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_929.repack27, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_930 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_930, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_930.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_930.repack29, align 8, !noalias !0
  %v_r_2566_29_120_304_304_5353_pointer_931 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store double %v_r_2566_29_120_304_304_5353, ptr %v_r_2566_29_120_304_304_5353_pointer_931, align 8, !noalias !0
  %returnAddress_pointer_932 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %sharer_pointer_933 = getelementptr i8, ptr %common.ret.op.i, i64 128
  %eraser_pointer_934 = getelementptr i8, ptr %common.ret.op.i, i64 136
  store ptr @returnAddress_259, ptr %returnAddress_pointer_932, align 8, !noalias !0
  store ptr @sharer_891, ptr %sharer_pointer_933, align 8, !noalias !0
  store ptr @eraser_911, ptr %eraser_pointer_934, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zizi_7_98_282_282_5424.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %zizi_7_98_282_282_5424.unpack2
  %get_5881 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i46 = icmp ule ptr %nextStackPointer.sink.i, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_937 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_937(double %get_5881, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_231(%Pos %v_r_2584_28_119_303_303_5530, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tag_241 = extractvalue %Pos %v_r_2584_28_119_303_303_5530, 0
  switch i64 %tag_241, label %label_243 [
    i64 0, label %label_248
    i64 1, label %stackAllocate.exit
  ]

label_243:                                        ; preds = %entry
  ret void

label_248:                                        ; preds = %entry
  %isInside.i40 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i40)
  %newStackPointer.i41 = getelementptr i8, ptr %stackPointer.i, i64 -136
  store ptr %newStackPointer.i41, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_245 = load ptr, ptr %newStackPointer.i41, align 8, !noalias !0
  musttail call tailcc void %returnAddress_245(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

stackAllocate.exit:                               ; preds = %entry
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_234 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_234, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_235 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_235, align 8, !noalias !0
  %tmp_5760_pointer_236 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_236, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_237 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_237, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_238 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_238, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_239 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_239, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_240 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_240, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_234, align 8, !noalias !0
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_235, align 8, !noalias !0
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  store double %tmp_5760, ptr %tmp_5760_pointer_236, align 8, !noalias !0
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_237, align 8, !noalias !0
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_238, align 8, !noalias !0
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_239, align 8, !noalias !0
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_240, align 8, !noalias !0
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %sharer_pointer_966 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_967 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_249, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_966, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_967, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %zrzr_3_94_278_278_5552.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i46 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i47 = load ptr, ptr %base_pointer.i46, align 8
  %varPointer.i = getelementptr i8, ptr %base.i47, i64 %zrzr_3_94_278_278_5552.unpack5
  %get_5882 = load double, ptr %varPointer.i, align 8, !noalias !0
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit69

realloc.i:                                        ; preds = %stackAllocate.exit
  %base_pointer.i66 = getelementptr i8, ptr %stack, i64 16
  %base.i67 = load ptr, ptr %base_pointer.i66, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i67 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 144
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i67, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i68 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i68, i64 144
  store ptr %newBase.i, ptr %base_pointer.i66, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit69

stackAllocate.exit69:                             ; preds = %stackAllocate.exit, %realloc.i
  %limit.i57 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %stackAllocate.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i68, %realloc.i ], [ %newStackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_924.i = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_924.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_924.repack19.i = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424_pointer_924.repack19.i, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_925.i = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_925.i, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_925.repack21.i = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552_pointer_925.repack21.i, align 8, !noalias !0
  %tmp_5760_pointer_926.i = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_926.i, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_927.i = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_927.i, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_927.repack23.i = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542_pointer_927.repack23.i, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_928.i = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_928.i, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_928.repack25.i = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374_pointer_928.repack25.i, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_929.i = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_929.i, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_929.repack27.i = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410_pointer_929.repack27.i, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_930.i = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_930.i, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_930.repack29.i = getelementptr i8, ptr %common.ret.op.i, i64 104
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368_pointer_930.repack29.i, align 8, !noalias !0
  %v_r_2566_29_120_304_304_5353_pointer_931.i = getelementptr i8, ptr %common.ret.op.i, i64 112
  store double %get_5882, ptr %v_r_2566_29_120_304_304_5353_pointer_931.i, align 8, !noalias !0
  %returnAddress_pointer_932.i = getelementptr i8, ptr %common.ret.op.i, i64 120
  %sharer_pointer_933.i = getelementptr i8, ptr %common.ret.op.i, i64 128
  %eraser_pointer_934.i = getelementptr i8, ptr %common.ret.op.i, i64 136
  store ptr @returnAddress_259, ptr %returnAddress_pointer_932.i, align 8, !noalias !0
  store ptr @sharer_891, ptr %sharer_pointer_933.i, align 8, !noalias !0
  store ptr @eraser_911, ptr %eraser_pointer_934.i, align 8, !noalias !0
  %stack_pointer.i.i60 = getelementptr i8, ptr %zizi_7_98_282_282_5424.unpack, i64 8
  %stack.i.i61 = load ptr, ptr %stack_pointer.i.i60, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i61, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i62 = getelementptr i8, ptr %base.i, i64 %zizi_7_98_282_282_5424.unpack2
  %get_5881.i = load double, ptr %varPointer.i62, align 8, !noalias !0
  %isInside.i58 = icmp ule ptr %nextStackPointer.sink.i, %limit.i57
  tail call void @llvm.assume(i1 %isInside.i58)
  %newStackPointer.i59 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i59, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_937.i = load ptr, ptr %newStackPointer.i59, align 8, !noalias !0
  musttail call tailcc void %returnAddress_937.i(double %get_5881.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1010(i64 %v_r_2583_1_26_117_301_301_5555, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = icmp slt i64 %v_r_2583_1_26_117_301_301_5555, 50
  %fat_z.i = zext i1 %z.i to i64
  %adt_boolean.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i, 0
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1011 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1011(%Pos %adt_boolean.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_221(%Pos %v_r_3474_5_25_116_300_300_5494, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i35 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -112
  %z_15_106_290_290_5374_pointer_228 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %z_15_106_290_290_5374.unpack = load ptr, ptr %z_15_106_290_290_5374_pointer_228, align 8, !noalias !0
  %z_15_106_290_290_5374.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %z_15_106_290_290_5374.unpack11 = load i64, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt16 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack17 = load i64, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_230 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_230, align 8, !noalias !0
  %zi_5_96_280_280_5410.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %zi_5_96_280_280_5410.unpack14 = load i64, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_229 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %zi_5_96_280_280_5410.unpack = load ptr, ptr %zi_5_96_280_280_5410_pointer_229, align 8, !noalias !0
  %notDone_17_108_292_292_5542.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %notDone_17_108_292_292_5542.unpack8 = load i64, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_227 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %notDone_17_108_292_292_5542.unpack = load ptr, ptr %notDone_17_108_292_292_5542_pointer_227, align 8, !noalias !0
  %tmp_5760_pointer_226 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5760 = load double, ptr %tmp_5760_pointer_226, align 8, !noalias !0
  %zrzr_3_94_278_278_5552.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %zrzr_3_94_278_278_5552.unpack5 = load i64, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_225 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %zrzr_3_94_278_278_5552.unpack = load ptr, ptr %zrzr_3_94_278_278_5552_pointer_225, align 8, !noalias !0
  %zizi_7_98_282_282_5424.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -96
  %zizi_7_98_282_282_5424.unpack2 = load i64, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_224 = getelementptr i8, ptr %stackPointer.i, i64 -104
  %zizi_7_98_282_282_5424.unpack = load ptr, ptr %zizi_7_98_282_282_5424_pointer_224, align 8, !noalias !0
  %tmp_5766 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %zizi_7_98_282_282_5424.unpack, ptr %zizi_7_98_282_282_5424_pointer_224, align 8, !noalias !0
  store i64 %zizi_7_98_282_282_5424.unpack2, ptr %zizi_7_98_282_282_5424.elt1, align 8, !noalias !0
  store ptr %zrzr_3_94_278_278_5552.unpack, ptr %zrzr_3_94_278_278_5552_pointer_225, align 8, !noalias !0
  store i64 %zrzr_3_94_278_278_5552.unpack5, ptr %zrzr_3_94_278_278_5552.elt4, align 8, !noalias !0
  store double %tmp_5760, ptr %tmp_5760_pointer_226, align 8, !noalias !0
  store ptr %notDone_17_108_292_292_5542.unpack, ptr %notDone_17_108_292_292_5542_pointer_227, align 8, !noalias !0
  store i64 %notDone_17_108_292_292_5542.unpack8, ptr %notDone_17_108_292_292_5542.elt7, align 8, !noalias !0
  store ptr %z_15_106_290_290_5374.unpack, ptr %z_15_106_290_290_5374_pointer_228, align 8, !noalias !0
  store i64 %z_15_106_290_290_5374.unpack11, ptr %z_15_106_290_290_5374.elt10, align 8, !noalias !0
  store ptr %zi_5_96_280_280_5410.unpack, ptr %zi_5_96_280_280_5410_pointer_229, align 8, !noalias !0
  store i64 %zi_5_96_280_280_5410.unpack14, ptr %zi_5_96_280_280_5410.elt13, align 8, !noalias !0
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_230, align 8, !noalias !0
  store i64 %escape_19_110_294_294_5368.unpack17, ptr %escape_19_110_294_294_5368.elt16, align 8, !noalias !0
  %sharer_pointer_1000 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1001 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_231, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_1000, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_1001, align 8, !noalias !0
  %tag_1002 = extractvalue %Pos %v_r_3474_5_25_116_300_300_5494, 0
  switch i64 %tag_1002, label %label_1004 [
    i64 0, label %label_1009
    i64 1, label %label_1023
  ]

label_1004:                                       ; preds = %stackAllocate.exit
  ret void

label_1009:                                       ; preds = %stackAllocate.exit
  %isInside.i82 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i82)
  %newStackPointer.i83 = getelementptr i8, ptr %stackPointer.i, i64 -136
  store ptr %newStackPointer.i83, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_245.i = load ptr, ptr %newStackPointer.i83, align 8, !noalias !0
  musttail call tailcc void %returnAddress_245.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_1023:                                       ; preds = %stackAllocate.exit
  %nextStackPointer.i50 = getelementptr i8, ptr %stackPointer.i, i64 48
  %isInside.not.i51 = icmp ugt ptr %nextStackPointer.i50, %limit.i
  br i1 %isInside.not.i51, label %realloc.i54, label %stackAllocate.exit68

realloc.i54:                                      ; preds = %label_1023
  %base_pointer.i55 = getelementptr i8, ptr %stack, i64 16
  %base.i56 = load ptr, ptr %base_pointer.i55, align 8, !alias.scope !0
  %intStackPointer.i57 = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i58 = ptrtoint ptr %base.i56 to i64
  %size.i59 = sub i64 %intStackPointer.i57, %intBase.i58
  %nextSize.i60 = add i64 %size.i59, 24
  %leadingZeros.i.i61 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i60, i1 false)
  %numBits.i.i62 = sub nuw nsw i64 64, %leadingZeros.i.i61
  %result.i.i63 = shl nuw i64 1, %numBits.i.i62
  %newBase.i64 = tail call ptr @realloc(ptr %base.i56, i64 %result.i.i63)
  %newLimit.i65 = getelementptr i8, ptr %newBase.i64, i64 %result.i.i63
  %newStackPointer.i66 = getelementptr i8, ptr %newBase.i64, i64 %size.i59
  %newNextStackPointer.i67 = getelementptr i8, ptr %newStackPointer.i66, i64 24
  store ptr %newBase.i64, ptr %base_pointer.i55, align 8, !alias.scope !0
  store ptr %newLimit.i65, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit68

stackAllocate.exit68:                             ; preds = %label_1023, %realloc.i54
  %limit.i74 = phi ptr [ %newLimit.i65, %realloc.i54 ], [ %limit.i, %label_1023 ]
  %nextStackPointer.sink.i52 = phi ptr [ %newNextStackPointer.i67, %realloc.i54 ], [ %nextStackPointer.i50, %label_1023 ]
  %common.ret.op.i53 = phi ptr [ %newStackPointer.i66, %realloc.i54 ], [ %oldStackPointer.i, %label_1023 ]
  store ptr %nextStackPointer.sink.i52, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_1016 = getelementptr i8, ptr %common.ret.op.i53, i64 8
  %eraser_pointer_1017 = getelementptr i8, ptr %common.ret.op.i53, i64 16
  store ptr @returnAddress_1010, ptr %common.ret.op.i53, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_1016, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_1017, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %z_15_106_290_290_5374.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i69 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i70 = load ptr, ptr %base_pointer.i69, align 8
  %varPointer.i = getelementptr i8, ptr %base.i70, i64 %z_15_106_290_290_5374.unpack11
  %get_5886 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i75 = icmp ule ptr %nextStackPointer.sink.i52, %limit.i74
  tail call void @llvm.assume(i1 %isInside.i75)
  %newStackPointer.i76 = getelementptr i8, ptr %nextStackPointer.sink.i52, i64 -24
  store ptr %newStackPointer.i76, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1020 = load ptr, ptr %newStackPointer.i76, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1020(i64 %get_5886, ptr nonnull %stack)
  ret void
}

define tailcc void @b_whileLoop_2565_20_111_295_295_5509(double %tmp_5766, %Reference %zizi_7_98_282_282_5424, %Reference %zrzr_3_94_278_278_5552, double %tmp_5760, %Reference %notDone_17_108_292_292_5542, %Reference %z_15_106_290_290_5374, %Reference %zi_5_96_280_280_5410, %Reference %escape_19_110_294_294_5368, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 136
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 136
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 136
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i2328 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_5766, ptr %common.ret.op.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_1042 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %zizi_7_98_282_282_5424.elt = extractvalue %Reference %zizi_7_98_282_282_5424, 0
  store ptr %zizi_7_98_282_282_5424.elt, ptr %zizi_7_98_282_282_5424_pointer_1042, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_1042.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %zizi_7_98_282_282_5424.elt2 = extractvalue %Reference %zizi_7_98_282_282_5424, 1
  store i64 %zizi_7_98_282_282_5424.elt2, ptr %zizi_7_98_282_282_5424_pointer_1042.repack1, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_1043 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %zrzr_3_94_278_278_5552.elt = extractvalue %Reference %zrzr_3_94_278_278_5552, 0
  store ptr %zrzr_3_94_278_278_5552.elt, ptr %zrzr_3_94_278_278_5552_pointer_1043, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_1043.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %zrzr_3_94_278_278_5552.elt4 = extractvalue %Reference %zrzr_3_94_278_278_5552, 1
  store i64 %zrzr_3_94_278_278_5552.elt4, ptr %zrzr_3_94_278_278_5552_pointer_1043.repack3, align 8, !noalias !0
  %tmp_5760_pointer_1044 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_1044, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_1045 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %notDone_17_108_292_292_5542.elt = extractvalue %Reference %notDone_17_108_292_292_5542, 0
  store ptr %notDone_17_108_292_292_5542.elt, ptr %notDone_17_108_292_292_5542_pointer_1045, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_1045.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %notDone_17_108_292_292_5542.elt6 = extractvalue %Reference %notDone_17_108_292_292_5542, 1
  store i64 %notDone_17_108_292_292_5542.elt6, ptr %notDone_17_108_292_292_5542_pointer_1045.repack5, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_1046 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %z_15_106_290_290_5374.elt = extractvalue %Reference %z_15_106_290_290_5374, 0
  store ptr %z_15_106_290_290_5374.elt, ptr %z_15_106_290_290_5374_pointer_1046, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_1046.repack7 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %z_15_106_290_290_5374.elt8 = extractvalue %Reference %z_15_106_290_290_5374, 1
  store i64 %z_15_106_290_290_5374.elt8, ptr %z_15_106_290_290_5374_pointer_1046.repack7, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_1047 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %zi_5_96_280_280_5410.elt = extractvalue %Reference %zi_5_96_280_280_5410, 0
  store ptr %zi_5_96_280_280_5410.elt, ptr %zi_5_96_280_280_5410_pointer_1047, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_1047.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %zi_5_96_280_280_5410.elt10 = extractvalue %Reference %zi_5_96_280_280_5410, 1
  store i64 %zi_5_96_280_280_5410.elt10, ptr %zi_5_96_280_280_5410_pointer_1047.repack9, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1048 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %escape_19_110_294_294_5368.elt = extractvalue %Reference %escape_19_110_294_294_5368, 0
  store ptr %escape_19_110_294_294_5368.elt, ptr %escape_19_110_294_294_5368_pointer_1048, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1048.repack11 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %escape_19_110_294_294_5368.elt12 = extractvalue %Reference %escape_19_110_294_294_5368, 1
  store i64 %escape_19_110_294_294_5368.elt12, ptr %escape_19_110_294_294_5368_pointer_1048.repack11, align 8, !noalias !0
  %returnAddress_pointer_1049 = getelementptr i8, ptr %common.ret.op.i, i64 112
  %sharer_pointer_1050 = getelementptr i8, ptr %common.ret.op.i, i64 120
  %eraser_pointer_1051 = getelementptr i8, ptr %common.ret.op.i, i64 128
  store ptr @returnAddress_221, ptr %returnAddress_pointer_1049, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_1050, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_1051, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %notDone_17_108_292_292_5542.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i19 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i20 = load ptr, ptr %base_pointer.i19, align 8
  %varPointer.i = getelementptr i8, ptr %base.i20, i64 %notDone_17_108_292_292_5542.elt6
  %notDone_17_108_292_292_5542_old_1053.elt13 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %notDone_17_108_292_292_5542_old_1053.unpack14 = load ptr, ptr %notDone_17_108_292_292_5542_old_1053.elt13, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %notDone_17_108_292_292_5542_old_1053.unpack14, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %notDone_17_108_292_292_5542_old_1053.unpack14, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %notDone_17_108_292_292_5542_old_1053.unpack14, align 4
  %get_5887.unpack17.pre = load ptr, ptr %notDone_17_108_292_292_5542_old_1053.elt13, align 8, !noalias !0
  %stackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i23.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i23 = phi ptr [ %limit.i2328, %stackAllocate.exit ], [ %limit.i23.pre, %next.i.i ]
  %stackPointer.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i.pre, %next.i.i ]
  %get_5887.unpack17 = phi ptr [ null, %stackAllocate.exit ], [ %get_5887.unpack17.pre, %next.i.i ]
  %get_5887.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5887.unpack, 0
  %get_588718 = insertvalue %Pos %0, ptr %get_5887.unpack17, 1
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i23
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1054 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1054(%Pos %get_588718, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1151(%Pos %__81_172_356_356_5629, ptr %stack) {
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
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__81_172_356_356_5629, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %bitNum_7_7_5558.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bitNum_7_7_5558.unpack2
  store i64 0, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1157 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1157(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1147(%Pos %__80_171_355_355_5628, ptr %stack) {
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
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1150 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1150, align 8, !noalias !0
  %byteAcc_5_5_5418.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack5 = load i64, ptr %byteAcc_5_5_5418.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__80_171_355_355_5628, 1
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
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1162.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1162.repack7, align 8, !noalias !0
  %returnAddress_pointer_1164 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_1165 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_1166 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_1151, ptr %returnAddress_pointer_1164, align 8, !noalias !0
  store ptr @sharer_517, ptr %sharer_pointer_1165, align 8, !noalias !0
  store ptr @eraser_521, ptr %eraser_pointer_1166, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %byteAcc_5_5_5418.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i18 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i19 = load ptr, ptr %base_pointer.i18, align 8
  %varPointer.i = getelementptr i8, ptr %base.i19, i64 %byteAcc_5_5_5418.unpack5
  store i64 0, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i24 = icmp ule ptr %nextStackPointer.sink.i, %limit.i23
  tail call void @llvm.assume(i1 %isInside.i24)
  %newStackPointer.i25 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i25, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1170 = load ptr, ptr %newStackPointer.i25, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1170(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1175(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1181(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1141(i64 %v_r_2601_78_169_353_353_5535, ptr %stack) {
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
  %v_r_2600_77_168_352_352_5408_pointer_1144 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_2600_77_168_352_352_5408 = load i64, ptr %v_r_2600_77_168_352_352_5408_pointer_1144, align 4, !noalias !0
  %sum_3_3_5426_pointer_1145 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1145, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1146 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1146, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %z.i = xor i64 %v_r_2600_77_168_352_352_5408, %v_r_2601_78_169_353_353_5535
  store ptr %byteAcc_5_5_5418.unpack, ptr %v_r_2600_77_168_352_352_5408_pointer_1144, align 8, !noalias !0
  store i64 %byteAcc_5_5_5418.unpack8, ptr %sum_3_3_5426_pointer_1145, align 8, !noalias !0
  store ptr @returnAddress_1147, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  store ptr @sharer_1175, ptr %byteAcc_5_5_5418_pointer_1146, align 8, !noalias !0
  store ptr @eraser_1181, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %sum_3_3_5426.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i23 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i24 = load ptr, ptr %base_pointer.i23, align 8
  %varPointer.i = getelementptr i8, ptr %base.i24, i64 %sum_3_3_5426.unpack5
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %sum_3_3_5426.elt4, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1194 = load ptr, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1194(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1201(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1211(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1136(i64 %v_r_2600_77_168_352_352_5408, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1139 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1139, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1140 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1140, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 80
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i24 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i24, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i30 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1217.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1217.repack10, align 8, !noalias !0
  %v_r_2600_77_168_352_352_5408_pointer_1219 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %v_r_2600_77_168_352_352_5408, ptr %v_r_2600_77_168_352_352_5408_pointer_1219, align 4, !noalias !0
  %sum_3_3_5426_pointer_1220 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1220, align 8, !noalias !0
  %sum_3_3_5426_pointer_1220.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1220.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1221 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1221, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1221.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1221.repack14, align 8, !noalias !0
  %returnAddress_pointer_1222 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_1223 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_1224 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_1141, ptr %returnAddress_pointer_1222, align 8, !noalias !0
  store ptr @sharer_1201, ptr %sharer_pointer_1223, align 8, !noalias !0
  store ptr @eraser_1211, ptr %eraser_pointer_1224, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %byteAcc_5_5_5418.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %byteAcc_5_5_5418.unpack8
  %get_5908 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i31 = icmp ule ptr %nextStackPointer.sink.i, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1227 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1227(i64 %get_5908, ptr nonnull %stack)
  ret void
}

define void @sharer_1233(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1241(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1131(%Pos %__76_167_351_351_5627, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1134 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1134, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1135 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1135, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__76_167_351_351_5627, 1
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
  %limit.i23 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i23
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
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
  %newStackPointer.i24 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i24, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i30 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i23, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1246.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1246.repack10, align 8, !noalias !0
  %sum_3_3_5426_pointer_1248 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1248, align 8, !noalias !0
  %sum_3_3_5426_pointer_1248.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1248.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1249 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1249, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1249.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1249.repack14, align 8, !noalias !0
  %returnAddress_pointer_1250 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1251 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1252 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_1136, ptr %returnAddress_pointer_1250, align 8, !noalias !0
  store ptr @sharer_1233, ptr %sharer_pointer_1251, align 8, !noalias !0
  store ptr @eraser_1241, ptr %eraser_pointer_1252, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %sum_3_3_5426.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %sum_3_3_5426.unpack5
  %get_5909 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i31 = icmp ule ptr %nextStackPointer.sink.i, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1255 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1255(i64 %get_5909, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1125(i64 %v_r_2598_73_164_348_348_5453, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1128 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1128, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %v_r_2597_72_163_347_347_5321_pointer_1129 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2597_72_163_347_347_5321 = load i64, ptr %v_r_2597_72_163_347_347_5321_pointer_1129, align 4, !noalias !0
  %byteAcc_5_5_5418_pointer_1130 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1130, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
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
  %newStackPointer.i25 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i25, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i31 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i25, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = sub i64 8, %v_r_2598_73_164_348_348_5453
  %z.i21 = shl i64 %v_r_2597_72_163_347_347_5321, %z.i
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1264.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1264.repack10, align 8, !noalias !0
  %sum_3_3_5426_pointer_1266 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1266, align 8, !noalias !0
  %sum_3_3_5426_pointer_1266.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1266.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1267 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1267, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1267.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1267.repack14, align 8, !noalias !0
  %returnAddress_pointer_1268 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1269 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1270 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_1131, ptr %returnAddress_pointer_1268, align 8, !noalias !0
  store ptr @sharer_1233, ptr %sharer_pointer_1269, align 8, !noalias !0
  store ptr @eraser_1241, ptr %eraser_pointer_1270, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %byteAcc_5_5_5418.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i26 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i27 = load ptr, ptr %base_pointer.i26, align 8
  %varPointer.i = getelementptr i8, ptr %base.i27, i64 %byteAcc_5_5_5418.unpack8
  store i64 %z.i21, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i32 = icmp ule ptr %nextStackPointer.sink.i, %limit.i31
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i33 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i33, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1274 = load ptr, ptr %newStackPointer.i33, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1274(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1281(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1291(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1120(i64 %v_r_2597_72_163_347_347_5321, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1123 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1123, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1124 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1124, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 80
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i24 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i24, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i30 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1297.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1297.repack10, align 8, !noalias !0
  %sum_3_3_5426_pointer_1299 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1299, align 8, !noalias !0
  %sum_3_3_5426_pointer_1299.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1299.repack12, align 8, !noalias !0
  %v_r_2597_72_163_347_347_5321_pointer_1300 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %v_r_2597_72_163_347_347_5321, ptr %v_r_2597_72_163_347_347_5321_pointer_1300, align 4, !noalias !0
  %byteAcc_5_5_5418_pointer_1301 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1301, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1301.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1301.repack14, align 8, !noalias !0
  %returnAddress_pointer_1302 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_1303 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_1304 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_1125, ptr %returnAddress_pointer_1302, align 8, !noalias !0
  store ptr @sharer_1281, ptr %sharer_pointer_1303, align 8, !noalias !0
  store ptr @eraser_1291, ptr %eraser_pointer_1304, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %bitNum_7_7_5558.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %bitNum_7_7_5558.unpack2
  %get_5911 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i31 = icmp ule ptr %nextStackPointer.sink.i, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1307 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1307(i64 %get_5911, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1345(%Pos %__69_160_344_344_5626, ptr %stack) {
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
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__69_160_344_344_5626, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %bitNum_7_7_5558.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bitNum_7_7_5558.unpack2
  store i64 0, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1351 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1351(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1341(%Pos %__68_159_343_343_5625, ptr %stack) {
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
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1344 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1344, align 8, !noalias !0
  %byteAcc_5_5_5418.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack5 = load i64, ptr %byteAcc_5_5_5418.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__68_159_343_343_5625, 1
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
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1356.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1356.repack7, align 8, !noalias !0
  %returnAddress_pointer_1358 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_1359 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_1360 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_1345, ptr %returnAddress_pointer_1358, align 8, !noalias !0
  store ptr @sharer_517, ptr %sharer_pointer_1359, align 8, !noalias !0
  store ptr @eraser_521, ptr %eraser_pointer_1360, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %byteAcc_5_5_5418.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i18 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i19 = load ptr, ptr %base_pointer.i18, align 8
  %varPointer.i = getelementptr i8, ptr %base.i19, i64 %byteAcc_5_5_5418.unpack5
  store i64 0, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i24 = icmp ule ptr %nextStackPointer.sink.i, %limit.i23
  tail call void @llvm.assume(i1 %isInside.i24)
  %newStackPointer.i25 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i25, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1364 = load ptr, ptr %newStackPointer.i25, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1364(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1335(i64 %v_r_2593_66_157_341_341_5387, ptr %stack) {
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
  %v_r_2592_65_156_340_340_5290_pointer_1338 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_2592_65_156_340_340_5290 = load i64, ptr %v_r_2592_65_156_340_340_5290_pointer_1338, align 4, !noalias !0
  %sum_3_3_5426_pointer_1339 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1339, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1340 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1340, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %z.i = xor i64 %v_r_2592_65_156_340_340_5290, %v_r_2593_66_157_341_341_5387
  store ptr %byteAcc_5_5_5418.unpack, ptr %v_r_2592_65_156_340_340_5290_pointer_1338, align 8, !noalias !0
  store i64 %byteAcc_5_5_5418.unpack8, ptr %sum_3_3_5426_pointer_1339, align 8, !noalias !0
  store ptr @returnAddress_1341, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  store ptr @sharer_1175, ptr %byteAcc_5_5_5418_pointer_1340, align 8, !noalias !0
  store ptr @eraser_1181, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %sum_3_3_5426.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i23 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i24 = load ptr, ptr %base_pointer.i23, align 8
  %varPointer.i = getelementptr i8, ptr %base.i24, i64 %sum_3_3_5426.unpack5
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %sum_3_3_5426.elt4, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1380 = load ptr, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1380(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1330(i64 %v_r_2592_65_156_340_340_5290, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %bitNum_7_7_5558.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1333 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1333, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1334 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1334, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 80
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i24 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i24, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i30 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1391.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1391.repack10, align 8, !noalias !0
  %v_r_2592_65_156_340_340_5290_pointer_1393 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %v_r_2592_65_156_340_340_5290, ptr %v_r_2592_65_156_340_340_5290_pointer_1393, align 4, !noalias !0
  %sum_3_3_5426_pointer_1394 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1394, align 8, !noalias !0
  %sum_3_3_5426_pointer_1394.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1394.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1395 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1395, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1395.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1395.repack14, align 8, !noalias !0
  %returnAddress_pointer_1396 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_1397 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_1398 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_1335, ptr %returnAddress_pointer_1396, align 8, !noalias !0
  store ptr @sharer_1201, ptr %sharer_pointer_1397, align 8, !noalias !0
  store ptr @eraser_1211, ptr %eraser_pointer_1398, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %byteAcc_5_5_5418.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %byteAcc_5_5_5418.unpack8
  %get_5919 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i31 = icmp ule ptr %nextStackPointer.sink.i, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1401 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1401(i64 %get_5919, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1102(i64 %v_r_2591_63_154_338_338_5359, ptr %stack) {
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
  %bitNum_7_7_5558_pointer_1106 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_1106, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1107 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1107, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1108 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1108, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %z.i = icmp eq i64 %v_r_2591_63_154_338_338_5359, 8
  br i1 %z.i, label %label_1422, label %label_1329

label_1119:                                       ; preds = %label_1329
  %isInside.i32 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i33 = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %newStackPointer.i33, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1116 = load ptr, ptr %newStackPointer.i33, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1116(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_1328:                                       ; preds = %label_1329
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 8
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_1328
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
  %newStackPointer.i37 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i37, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_1328, %realloc.i
  %limit.i43 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_1328 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_1328 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i37, %realloc.i ], [ %newStackPointer.i, %label_1328 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1316.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1316.repack16, align 8, !noalias !0
  %sum_3_3_5426_pointer_1318 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1318, align 8, !noalias !0
  %sum_3_3_5426_pointer_1318.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1318.repack18, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1319 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1319, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1319.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1319.repack20, align 8, !noalias !0
  %returnAddress_pointer_1320 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1321 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1322 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_1120, ptr %returnAddress_pointer_1320, align 8, !noalias !0
  store ptr @sharer_1233, ptr %sharer_pointer_1321, align 8, !noalias !0
  store ptr @eraser_1241, ptr %eraser_pointer_1322, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %byteAcc_5_5_5418.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i38 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i39 = load ptr, ptr %base_pointer.i38, align 8
  %varPointer.i = getelementptr i8, ptr %base.i39, i64 %byteAcc_5_5_5418.unpack8
  %get_5912 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i44 = icmp ule ptr %nextStackPointer.sink.i, %limit.i43
  tail call void @llvm.assume(i1 %isInside.i44)
  %newStackPointer.i45 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i45, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1325 = load ptr, ptr %newStackPointer.i45, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1325(i64 %get_5912, ptr nonnull %stack)
  ret void

label_1329:                                       ; preds = %entry
  %tmp_5795_pointer_1105 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_5795 = load i64, ptr %tmp_5795_pointer_1105, align 4, !noalias !0
  %i_6_91_275_275_5504 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i46 = add i64 %tmp_5795, -1
  %z.i47 = icmp eq i64 %i_6_91_275_275_5504, %z.i46
  br i1 %z.i47, label %label_1328, label %label_1119

label_1422:                                       ; preds = %entry
  %nextStackPointer.i54 = getelementptr i8, ptr %stackPointer.i, i64 8
  %isInside.not.i55 = icmp ugt ptr %nextStackPointer.i54, %limit.i
  br i1 %isInside.not.i55, label %realloc.i58, label %stackAllocate.exit72

realloc.i58:                                      ; preds = %label_1422
  %base_pointer.i59 = getelementptr i8, ptr %stack, i64 16
  %base.i60 = load ptr, ptr %base_pointer.i59, align 8, !alias.scope !0
  %intStackPointer.i61 = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i62 = ptrtoint ptr %base.i60 to i64
  %size.i63 = sub i64 %intStackPointer.i61, %intBase.i62
  %nextSize.i64 = add i64 %size.i63, 72
  %leadingZeros.i.i65 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i64, i1 false)
  %numBits.i.i66 = sub nuw nsw i64 64, %leadingZeros.i.i65
  %result.i.i67 = shl nuw i64 1, %numBits.i.i66
  %newBase.i68 = tail call ptr @realloc(ptr %base.i60, i64 %result.i.i67)
  %newLimit.i69 = getelementptr i8, ptr %newBase.i68, i64 %result.i.i67
  %newStackPointer.i70 = getelementptr i8, ptr %newBase.i68, i64 %size.i63
  %newNextStackPointer.i71 = getelementptr i8, ptr %newStackPointer.i70, i64 72
  store ptr %newBase.i68, ptr %base_pointer.i59, align 8, !alias.scope !0
  store ptr %newLimit.i69, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit72

stackAllocate.exit72:                             ; preds = %label_1422, %realloc.i58
  %limit.i81 = phi ptr [ %newLimit.i69, %realloc.i58 ], [ %limit.i, %label_1422 ]
  %nextStackPointer.sink.i56 = phi ptr [ %newNextStackPointer.i71, %realloc.i58 ], [ %nextStackPointer.i54, %label_1422 ]
  %common.ret.op.i57 = phi ptr [ %newStackPointer.i70, %realloc.i58 ], [ %newStackPointer.i, %label_1422 ]
  store ptr %nextStackPointer.sink.i56, ptr %stackPointer_pointer.i, align 8
  store ptr %bitNum_7_7_5558.unpack, ptr %common.ret.op.i57, align 8, !noalias !0
  %stackPointer_1410.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i57, i64 8
  store i64 %bitNum_7_7_5558.unpack2, ptr %stackPointer_1410.repack10, align 8, !noalias !0
  %sum_3_3_5426_pointer_1412 = getelementptr i8, ptr %common.ret.op.i57, i64 16
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1412, align 8, !noalias !0
  %sum_3_3_5426_pointer_1412.repack12 = getelementptr i8, ptr %common.ret.op.i57, i64 24
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1412.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1413 = getelementptr i8, ptr %common.ret.op.i57, i64 32
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1413, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1413.repack14 = getelementptr i8, ptr %common.ret.op.i57, i64 40
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1413.repack14, align 8, !noalias !0
  %returnAddress_pointer_1414 = getelementptr i8, ptr %common.ret.op.i57, i64 48
  %sharer_pointer_1415 = getelementptr i8, ptr %common.ret.op.i57, i64 56
  %eraser_pointer_1416 = getelementptr i8, ptr %common.ret.op.i57, i64 64
  store ptr @returnAddress_1330, ptr %returnAddress_pointer_1414, align 8, !noalias !0
  store ptr @sharer_1233, ptr %sharer_pointer_1415, align 8, !noalias !0
  store ptr @eraser_1241, ptr %eraser_pointer_1416, align 8, !noalias !0
  %stack_pointer.i.i73 = getelementptr i8, ptr %sum_3_3_5426.unpack, i64 8
  %stack.i.i74 = load ptr, ptr %stack_pointer.i.i73, align 8
  %base_pointer.i75 = getelementptr i8, ptr %stack.i.i74, i64 16
  %base.i76 = load ptr, ptr %base_pointer.i75, align 8
  %varPointer.i77 = getelementptr i8, ptr %base.i76, i64 %sum_3_3_5426.unpack5
  %get_5920 = load i64, ptr %varPointer.i77, align 4, !noalias !0
  %isInside.i82 = icmp ule ptr %nextStackPointer.sink.i56, %limit.i81
  tail call void @llvm.assume(i1 %isInside.i82)
  %newStackPointer.i83 = getelementptr i8, ptr %nextStackPointer.sink.i56, i64 -24
  store ptr %newStackPointer.i83, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1419 = load ptr, ptr %newStackPointer.i83, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1419(i64 %get_5920, ptr nonnull %stack)
  ret void
}

define void @sharer_1428(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1440(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1095(%Pos %__62_153_337_337_5624, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %i_6_91_275_275_5504 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5795_pointer_1098 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_5795 = load i64, ptr %tmp_5795_pointer_1098, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1099 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_1099, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1100 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1100, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1101 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1101, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__62_153_337_337_5624, 1
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
  %limit.i23 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i23
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
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
  %newStackPointer.i24 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i24, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i30 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i23, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_91_275_275_5504, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5795_pointer_1449 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5795, ptr %tmp_5795_pointer_1449, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1450 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %bitNum_7_7_5558.unpack, ptr %bitNum_7_7_5558_pointer_1450, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1450.repack10 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %bitNum_7_7_5558.unpack2, ptr %bitNum_7_7_5558_pointer_1450.repack10, align 8, !noalias !0
  %sum_3_3_5426_pointer_1451 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1451, align 8, !noalias !0
  %sum_3_3_5426_pointer_1451.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1451.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1452 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1452, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1452.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1452.repack14, align 8, !noalias !0
  %returnAddress_pointer_1453 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_1454 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_1455 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_1102, ptr %returnAddress_pointer_1453, align 8, !noalias !0
  store ptr @sharer_1428, ptr %sharer_pointer_1454, align 8, !noalias !0
  store ptr @eraser_1440, ptr %eraser_pointer_1455, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %bitNum_7_7_5558.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %bitNum_7_7_5558.unpack2
  %get_5921 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i31 = icmp ule ptr %nextStackPointer.sink.i, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1458 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1458(i64 %get_5921, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1088(i64 %v_r_2589_60_151_335_335_5292, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i20 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i20)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1094 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1094, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %sum_3_3_5426_pointer_1093 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1093, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1092 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_1092, align 8, !noalias !0
  %tmp_5795_pointer_1091 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_5795 = load i64, ptr %tmp_5795_pointer_1091, align 4, !noalias !0
  %i_6_91_275_275_5504 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i = add i64 %v_r_2589_60_151_335_335_5292, 1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_91_275_275_5504, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5795_pointer_1473 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store i64 %tmp_5795, ptr %tmp_5795_pointer_1473, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1474 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %bitNum_7_7_5558.unpack, ptr %bitNum_7_7_5558_pointer_1474, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1474.repack10 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store i64 %bitNum_7_7_5558.unpack2, ptr %bitNum_7_7_5558_pointer_1474.repack10, align 8, !noalias !0
  %sum_3_3_5426_pointer_1475 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1475, align 8, !noalias !0
  %sum_3_3_5426_pointer_1475.repack12 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1475.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1476 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1476, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1476.repack14 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1476.repack14, align 8, !noalias !0
  %sharer_pointer_1478 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1479 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1095, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1428, ptr %sharer_pointer_1478, align 8, !noalias !0
  store ptr @eraser_1440, ptr %eraser_pointer_1479, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %bitNum_7_7_5558.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %bitNum_7_7_5558.unpack2
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1483 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1483(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1081(%Pos %__59_150_334_334_5623, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %i_6_91_275_275_5504 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5795_pointer_1084 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_5795 = load i64, ptr %tmp_5795_pointer_1084, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1085 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_1085, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1086 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1086, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1087 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1087, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__59_150_334_334_5623, 1
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
  %limit.i23 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i23
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
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
  %newStackPointer.i24 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i24, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i30 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i23, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_91_275_275_5504, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5795_pointer_1498 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5795, ptr %tmp_5795_pointer_1498, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1499 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %bitNum_7_7_5558.unpack, ptr %bitNum_7_7_5558_pointer_1499, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1499.repack10 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %bitNum_7_7_5558.unpack2, ptr %bitNum_7_7_5558_pointer_1499.repack10, align 8, !noalias !0
  %sum_3_3_5426_pointer_1500 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1500, align 8, !noalias !0
  %sum_3_3_5426_pointer_1500.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1500.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1501 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1501, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1501.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1501.repack14, align 8, !noalias !0
  %returnAddress_pointer_1502 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_1503 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_1504 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_1088, ptr %returnAddress_pointer_1502, align 8, !noalias !0
  store ptr @sharer_1428, ptr %sharer_pointer_1503, align 8, !noalias !0
  store ptr @eraser_1440, ptr %eraser_pointer_1504, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %bitNum_7_7_5558.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %bitNum_7_7_5558.unpack2
  %get_5923 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i31 = icmp ule ptr %nextStackPointer.sink.i, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1507 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1507(i64 %get_5923, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1073(i64 %v_r_2587_56_147_331_331_5317, ptr %stack) {
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
  %i_6_91_275_275_5504 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5795_pointer_1076 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_5795 = load i64, ptr %tmp_5795_pointer_1076, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1077 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_1077, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1078 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1078, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %v_r_2586_55_146_330_330_5536_pointer_1079 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2586_55_146_330_330_5536 = load i64, ptr %v_r_2586_55_146_330_330_5536_pointer_1079, align 4, !noalias !0
  %byteAcc_5_5_5418_pointer_1080 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1080, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
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
  %newStackPointer.i25 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i25, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i31 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i25, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = shl i64 %v_r_2586_55_146_330_330_5536, 1
  %z.i21 = add i64 %z.i, %v_r_2587_56_147_331_331_5317
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_91_275_275_5504, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5795_pointer_1522 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5795, ptr %tmp_5795_pointer_1522, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1523 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %bitNum_7_7_5558.unpack, ptr %bitNum_7_7_5558_pointer_1523, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1523.repack10 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %bitNum_7_7_5558.unpack2, ptr %bitNum_7_7_5558_pointer_1523.repack10, align 8, !noalias !0
  %sum_3_3_5426_pointer_1524 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1524, align 8, !noalias !0
  %sum_3_3_5426_pointer_1524.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1524.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1525 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1525, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1525.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1525.repack14, align 8, !noalias !0
  %returnAddress_pointer_1526 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_1527 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_1528 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_1081, ptr %returnAddress_pointer_1526, align 8, !noalias !0
  store ptr @sharer_1428, ptr %sharer_pointer_1527, align 8, !noalias !0
  store ptr @eraser_1440, ptr %eraser_pointer_1528, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %byteAcc_5_5_5418.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i26 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i27 = load ptr, ptr %base_pointer.i26, align 8
  %varPointer.i = getelementptr i8, ptr %base.i27, i64 %byteAcc_5_5_5418.unpack8
  store i64 %z.i21, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i32 = icmp ule ptr %nextStackPointer.sink.i, %limit.i31
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i33 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i33, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1532 = load ptr, ptr %newStackPointer.i33, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1532(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1541(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1555(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -80
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1065(i64 %v_r_2586_55_146_330_330_5536, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -80
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %i_6_91_275_275_5504 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5795_pointer_1068 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5795 = load i64, ptr %tmp_5795_pointer_1068, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1069 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_1069, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1070 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1070, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1071 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1071, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1072 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_1072, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack11 = load i64, ptr %escape_19_110_294_294_5368.elt10, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 96
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i27 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i27, i64 96
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i33 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i27, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_91_275_275_5504, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5795_pointer_1565 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5795, ptr %tmp_5795_pointer_1565, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1566 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %bitNum_7_7_5558.unpack, ptr %bitNum_7_7_5558_pointer_1566, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1566.repack13 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %bitNum_7_7_5558.unpack2, ptr %bitNum_7_7_5558_pointer_1566.repack13, align 8, !noalias !0
  %sum_3_3_5426_pointer_1567 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1567, align 8, !noalias !0
  %sum_3_3_5426_pointer_1567.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1567.repack15, align 8, !noalias !0
  %v_r_2586_55_146_330_330_5536_pointer_1568 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %v_r_2586_55_146_330_330_5536, ptr %v_r_2586_55_146_330_330_5536_pointer_1568, align 4, !noalias !0
  %byteAcc_5_5_5418_pointer_1569 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1569, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1569.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1569.repack17, align 8, !noalias !0
  %returnAddress_pointer_1570 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_1571 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_1572 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_1073, ptr %returnAddress_pointer_1570, align 8, !noalias !0
  store ptr @sharer_1541, ptr %sharer_pointer_1571, align 8, !noalias !0
  store ptr @eraser_1555, ptr %eraser_pointer_1572, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %escape_19_110_294_294_5368.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i28 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i29 = load ptr, ptr %base_pointer.i28, align 8
  %varPointer.i = getelementptr i8, ptr %base.i29, i64 %escape_19_110_294_294_5368.unpack11
  %get_5925 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i34 = icmp ule ptr %nextStackPointer.sink.i, %limit.i33
  tail call void @llvm.assume(i1 %isInside.i34)
  %newStackPointer.i35 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i35, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1575 = load ptr, ptr %newStackPointer.i35, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1575(i64 %get_5925, ptr nonnull %stack)
  ret void
}

define void @sharer_1584(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1598(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -88
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1057(%Pos %__54_145_329_329_5622, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i25 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i25)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -80
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %i_6_91_275_275_5504 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5795_pointer_1060 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5795 = load i64, ptr %tmp_5795_pointer_1060, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1061 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_1061, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %sum_3_3_5426_pointer_1062 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1062, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1063 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1063, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1064 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %escape_19_110_294_294_5368.unpack = load ptr, ptr %escape_19_110_294_294_5368_pointer_1064, align 8, !noalias !0
  %escape_19_110_294_294_5368.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %escape_19_110_294_294_5368.unpack11 = load i64, ptr %escape_19_110_294_294_5368.elt10, align 8, !noalias !0
  %object.i = extractvalue %Pos %__54_145_329_329_5622, 1
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
  %limit.i28 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 104
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i28
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 104
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i29 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i29, i64 104
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i35 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i28, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i29, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_91_275_275_5504, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5795_pointer_1608 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5795, ptr %tmp_5795_pointer_1608, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1609 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %bitNum_7_7_5558.unpack, ptr %bitNum_7_7_5558_pointer_1609, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1609.repack13 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %bitNum_7_7_5558.unpack2, ptr %bitNum_7_7_5558_pointer_1609.repack13, align 8, !noalias !0
  %sum_3_3_5426_pointer_1610 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %sum_3_3_5426.unpack, ptr %sum_3_3_5426_pointer_1610, align 8, !noalias !0
  %sum_3_3_5426_pointer_1610.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %sum_3_3_5426.unpack5, ptr %sum_3_3_5426_pointer_1610.repack15, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1611 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %byteAcc_5_5_5418.unpack, ptr %byteAcc_5_5_5418_pointer_1611, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1611.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %byteAcc_5_5_5418.unpack8, ptr %byteAcc_5_5_5418_pointer_1611.repack17, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1612 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %escape_19_110_294_294_5368.unpack, ptr %escape_19_110_294_294_5368_pointer_1612, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1612.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %escape_19_110_294_294_5368.unpack11, ptr %escape_19_110_294_294_5368_pointer_1612.repack19, align 8, !noalias !0
  %returnAddress_pointer_1613 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %sharer_pointer_1614 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %eraser_pointer_1615 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr @returnAddress_1065, ptr %returnAddress_pointer_1613, align 8, !noalias !0
  store ptr @sharer_1584, ptr %sharer_pointer_1614, align 8, !noalias !0
  store ptr @eraser_1598, ptr %eraser_pointer_1615, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %byteAcc_5_5_5418.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i30 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i31 = load ptr, ptr %base_pointer.i30, align 8
  %varPointer.i = getelementptr i8, ptr %base.i31, i64 %byteAcc_5_5_5418.unpack8
  %get_5926 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i36 = icmp ule ptr %nextStackPointer.sink.i, %limit.i35
  tail call void @llvm.assume(i1 %isInside.i36)
  %newStackPointer.i37 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i37, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1618 = load ptr, ptr %newStackPointer.i37, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1618(i64 %get_5926, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_90_274_274_5441(i64 %i_6_91_275_275_5504, i64 %tmp_5795, %Reference %bitNum_7_7_5558, double %tmp_5760, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_91_275_275_5504, %tmp_5795
  %stackPointer_pointer.i71 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_1643, label %label_77

label_77:                                         ; preds = %entry
  %stackPointer.i70 = load ptr, ptr %stackPointer_pointer.i71, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i70, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i70, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i71, align 8, !alias.scope !0
  %returnAddress_74 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_74(%Pos zeroinitializer, ptr %stack)
  ret void

label_1643:                                       ; preds = %entry
  %limit_pointer.i72 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i71, align 8, !alias.scope !0
  %limit.i73 = load ptr, ptr %limit_pointer.i72, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 96
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i73
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_1643
  %base_pointer.i74 = getelementptr i8, ptr %stack, i64 16
  %base.i75 = load ptr, ptr %base_pointer.i74, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i76 = ptrtoint ptr %base.i75 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i76
  %nextSize.i = add i64 %size.i, 96
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i75, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i77 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i77, i64 96
  store ptr %newBase.i, ptr %base_pointer.i74, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_1643, %realloc.i
  %limit.i82 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i73, %label_1643 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_1643 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i77, %realloc.i ], [ %currentStackPointer.i, %label_1643 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i71, align 8
  store i64 %i_6_91_275_275_5504, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5795_pointer_116 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5795, ptr %tmp_5795_pointer_116, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_117 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %bitNum_7_7_5558.elt = extractvalue %Reference %bitNum_7_7_5558, 0
  store ptr %bitNum_7_7_5558.elt, ptr %bitNum_7_7_5558_pointer_117, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_117.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %bitNum_7_7_5558.elt2 = extractvalue %Reference %bitNum_7_7_5558, 1
  store i64 %bitNum_7_7_5558.elt2, ptr %bitNum_7_7_5558_pointer_117.repack1, align 8, !noalias !0
  %tmp_5760_pointer_118 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store double %tmp_5760, ptr %tmp_5760_pointer_118, align 8, !noalias !0
  %sum_3_3_5426_pointer_119 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sum_3_3_5426.elt = extractvalue %Reference %sum_3_3_5426, 0
  store ptr %sum_3_3_5426.elt, ptr %sum_3_3_5426_pointer_119, align 8, !noalias !0
  %sum_3_3_5426_pointer_119.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sum_3_3_5426.elt4 = extractvalue %Reference %sum_3_3_5426, 1
  store i64 %sum_3_3_5426.elt4, ptr %sum_3_3_5426_pointer_119.repack3, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_120 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %byteAcc_5_5_5418.elt = extractvalue %Reference %byteAcc_5_5_5418, 0
  store ptr %byteAcc_5_5_5418.elt, ptr %byteAcc_5_5_5418_pointer_120, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_120.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %byteAcc_5_5_5418.elt6 = extractvalue %Reference %byteAcc_5_5_5418, 1
  store i64 %byteAcc_5_5_5418.elt6, ptr %byteAcc_5_5_5418_pointer_120.repack5, align 8, !noalias !0
  %returnAddress_pointer_121 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_122 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_123 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_78, ptr %returnAddress_pointer_121, align 8, !noalias !0
  store ptr @sharer_92, ptr %sharer_pointer_122, align 8, !noalias !0
  store ptr @eraser_106, ptr %eraser_pointer_123, align 8, !noalias !0
  %base_pointer.i60 = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i61 = load ptr, ptr %stackPointer_pointer.i71, align 8
  %base.i62 = load ptr, ptr %base_pointer.i60, align 8
  %intStack.i63 = ptrtoint ptr %stackPointer.i61 to i64
  %intBase.i64 = ptrtoint ptr %base.i62 to i64
  %offset.i65 = sub i64 %intStack.i63, %intBase.i64
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i78 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i83 = getelementptr i8, ptr %stackPointer.i61, i64 32
  %isInside.not.i84 = icmp ugt ptr %nextStackPointer.i83, %limit.i82
  br i1 %isInside.not.i84, label %realloc.i87, label %stackAllocate.exit101

realloc.i87:                                      ; preds = %stackAllocate.exit
  %nextSize.i93 = add i64 %offset.i65, 32
  %leadingZeros.i.i94 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i93, i1 false)
  %numBits.i.i95 = sub nuw nsw i64 64, %leadingZeros.i.i94
  %result.i.i96 = shl nuw i64 1, %numBits.i.i95
  %newBase.i97 = tail call ptr @realloc(ptr %base.i62, i64 %result.i.i96)
  %newLimit.i98 = getelementptr i8, ptr %newBase.i97, i64 %result.i.i96
  %newStackPointer.i99 = getelementptr i8, ptr %newBase.i97, i64 %offset.i65
  %newNextStackPointer.i100 = getelementptr i8, ptr %newStackPointer.i99, i64 32
  store ptr %newBase.i97, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i98, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit101

stackAllocate.exit101:                            ; preds = %stackAllocate.exit, %realloc.i87
  %limit.i107 = phi ptr [ %newLimit.i98, %realloc.i87 ], [ %limit.i82, %stackAllocate.exit ]
  %nextStackPointer.sink.i85 = phi ptr [ %newNextStackPointer.i100, %realloc.i87 ], [ %nextStackPointer.i83, %stackAllocate.exit ]
  %common.ret.op.i86 = phi ptr [ %newStackPointer.i99, %realloc.i87 ], [ %stackPointer.i61, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i85, ptr %stackPointer_pointer.i71, align 8
  store double 0.000000e+00, ptr %common.ret.op.i86, align 8, !noalias !0
  %returnAddress_pointer_141 = getelementptr i8, ptr %common.ret.op.i86, i64 8
  %sharer_pointer_142 = getelementptr i8, ptr %common.ret.op.i86, i64 16
  %eraser_pointer_143 = getelementptr i8, ptr %common.ret.op.i86, i64 24
  store ptr @returnAddress_124, ptr %returnAddress_pointer_141, align 8, !noalias !0
  store ptr @sharer_132, ptr %sharer_pointer_142, align 8, !noalias !0
  store ptr @eraser_136, ptr %eraser_pointer_143, align 8, !noalias !0
  %stackPointer.i51 = load ptr, ptr %stackPointer_pointer.i71, align 8
  %base.i52 = load ptr, ptr %base_pointer.i60, align 8
  %intStack.i53 = ptrtoint ptr %stackPointer.i51 to i64
  %intBase.i54 = ptrtoint ptr %base.i52 to i64
  %offset.i55 = sub i64 %intStack.i53, %intBase.i54
  %prompt.i103 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i108 = getelementptr i8, ptr %stackPointer.i51, i64 32
  %isInside.not.i109 = icmp ugt ptr %nextStackPointer.i108, %limit.i107
  br i1 %isInside.not.i109, label %realloc.i112, label %stackAllocate.exit126

realloc.i112:                                     ; preds = %stackAllocate.exit101
  %nextSize.i118 = add i64 %offset.i55, 32
  %leadingZeros.i.i119 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i118, i1 false)
  %numBits.i.i120 = sub nuw nsw i64 64, %leadingZeros.i.i119
  %result.i.i121 = shl nuw i64 1, %numBits.i.i120
  %newBase.i122 = tail call ptr @realloc(ptr %base.i52, i64 %result.i.i121)
  %newLimit.i123 = getelementptr i8, ptr %newBase.i122, i64 %result.i.i121
  %newStackPointer.i124 = getelementptr i8, ptr %newBase.i122, i64 %offset.i55
  %newNextStackPointer.i125 = getelementptr i8, ptr %newStackPointer.i124, i64 32
  store ptr %newBase.i122, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i123, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit126

stackAllocate.exit126:                            ; preds = %stackAllocate.exit101, %realloc.i112
  %limit.i132 = phi ptr [ %newLimit.i123, %realloc.i112 ], [ %limit.i107, %stackAllocate.exit101 ]
  %nextStackPointer.sink.i110 = phi ptr [ %newNextStackPointer.i125, %realloc.i112 ], [ %nextStackPointer.i108, %stackAllocate.exit101 ]
  %common.ret.op.i111 = phi ptr [ %newStackPointer.i124, %realloc.i112 ], [ %stackPointer.i51, %stackAllocate.exit101 ]
  store ptr %nextStackPointer.sink.i110, ptr %stackPointer_pointer.i71, align 8
  store double 0.000000e+00, ptr %common.ret.op.i111, align 8, !noalias !0
  %returnAddress_pointer_155 = getelementptr i8, ptr %common.ret.op.i111, i64 8
  %sharer_pointer_156 = getelementptr i8, ptr %common.ret.op.i111, i64 16
  %eraser_pointer_157 = getelementptr i8, ptr %common.ret.op.i111, i64 24
  store ptr @returnAddress_144, ptr %returnAddress_pointer_155, align 8, !noalias !0
  store ptr @sharer_132, ptr %sharer_pointer_156, align 8, !noalias !0
  store ptr @eraser_136, ptr %eraser_pointer_157, align 8, !noalias !0
  %stackPointer.i41 = load ptr, ptr %stackPointer_pointer.i71, align 8
  %base.i42 = load ptr, ptr %base_pointer.i60, align 8
  %intStack.i43 = ptrtoint ptr %stackPointer.i41 to i64
  %intBase.i44 = ptrtoint ptr %base.i42 to i64
  %offset.i45 = sub i64 %intStack.i43, %intBase.i44
  %prompt.i128 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i133 = getelementptr i8, ptr %stackPointer.i41, i64 32
  %isInside.not.i134 = icmp ugt ptr %nextStackPointer.i133, %limit.i132
  br i1 %isInside.not.i134, label %realloc.i137, label %stackAllocate.exit151

realloc.i137:                                     ; preds = %stackAllocate.exit126
  %nextSize.i143 = add i64 %offset.i45, 32
  %leadingZeros.i.i144 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i143, i1 false)
  %numBits.i.i145 = sub nuw nsw i64 64, %leadingZeros.i.i144
  %result.i.i146 = shl nuw i64 1, %numBits.i.i145
  %newBase.i147 = tail call ptr @realloc(ptr %base.i42, i64 %result.i.i146)
  %newLimit.i148 = getelementptr i8, ptr %newBase.i147, i64 %result.i.i146
  %newStackPointer.i149 = getelementptr i8, ptr %newBase.i147, i64 %offset.i45
  %newNextStackPointer.i150 = getelementptr i8, ptr %newStackPointer.i149, i64 32
  store ptr %newBase.i147, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i148, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit151

stackAllocate.exit151:                            ; preds = %stackAllocate.exit126, %realloc.i137
  %limit.i162 = phi ptr [ %newLimit.i148, %realloc.i137 ], [ %limit.i132, %stackAllocate.exit126 ]
  %nextStackPointer.sink.i135 = phi ptr [ %newNextStackPointer.i150, %realloc.i137 ], [ %nextStackPointer.i133, %stackAllocate.exit126 ]
  %common.ret.op.i136 = phi ptr [ %newStackPointer.i149, %realloc.i137 ], [ %stackPointer.i41, %stackAllocate.exit126 ]
  store ptr %nextStackPointer.sink.i135, ptr %stackPointer_pointer.i71, align 8
  store double 0.000000e+00, ptr %common.ret.op.i136, align 8, !noalias !0
  %returnAddress_pointer_169 = getelementptr i8, ptr %common.ret.op.i136, i64 8
  %sharer_pointer_170 = getelementptr i8, ptr %common.ret.op.i136, i64 16
  %eraser_pointer_171 = getelementptr i8, ptr %common.ret.op.i136, i64 24
  store ptr @returnAddress_158, ptr %returnAddress_pointer_169, align 8, !noalias !0
  store ptr @sharer_132, ptr %sharer_pointer_170, align 8, !noalias !0
  store ptr @eraser_136, ptr %eraser_pointer_171, align 8, !noalias !0
  %z.i152 = sitofp i64 %i_6_91_275_275_5504 to double
  %z.i153 = fmul double %z.i152, 2.000000e+00
  %z.i154 = sitofp i64 %tmp_5795 to double
  %z.i155 = fdiv double %z.i153, %z.i154
  %z.i156 = fadd double %z.i155, -1.500000e+00
  %stackPointer.i31 = load ptr, ptr %stackPointer_pointer.i71, align 8
  %base.i32 = load ptr, ptr %base_pointer.i60, align 8
  %intStack.i33 = ptrtoint ptr %stackPointer.i31 to i64
  %intBase.i34 = ptrtoint ptr %base.i32 to i64
  %offset.i35 = sub i64 %intStack.i33, %intBase.i34
  %prompt.i158 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i163 = getelementptr i8, ptr %stackPointer.i31, i64 32
  %isInside.not.i164 = icmp ugt ptr %nextStackPointer.i163, %limit.i162
  br i1 %isInside.not.i164, label %realloc.i167, label %stackAllocate.exit181

realloc.i167:                                     ; preds = %stackAllocate.exit151
  %nextSize.i173 = add i64 %offset.i35, 32
  %leadingZeros.i.i174 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i173, i1 false)
  %numBits.i.i175 = sub nuw nsw i64 64, %leadingZeros.i.i174
  %result.i.i176 = shl nuw i64 1, %numBits.i.i175
  %newBase.i177 = tail call ptr @realloc(ptr %base.i32, i64 %result.i.i176)
  %newLimit.i178 = getelementptr i8, ptr %newBase.i177, i64 %result.i.i176
  %newStackPointer.i179 = getelementptr i8, ptr %newBase.i177, i64 %offset.i35
  %newNextStackPointer.i180 = getelementptr i8, ptr %newStackPointer.i179, i64 32
  store ptr %newBase.i177, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i178, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit181

stackAllocate.exit181:                            ; preds = %stackAllocate.exit151, %realloc.i167
  %limit.i187 = phi ptr [ %newLimit.i178, %realloc.i167 ], [ %limit.i162, %stackAllocate.exit151 ]
  %nextStackPointer.sink.i165 = phi ptr [ %newNextStackPointer.i180, %realloc.i167 ], [ %nextStackPointer.i163, %stackAllocate.exit151 ]
  %common.ret.op.i166 = phi ptr [ %newStackPointer.i179, %realloc.i167 ], [ %stackPointer.i31, %stackAllocate.exit151 ]
  store ptr %nextStackPointer.sink.i165, ptr %stackPointer_pointer.i71, align 8
  store i64 0, ptr %common.ret.op.i166, align 4, !noalias !0
  %returnAddress_pointer_183 = getelementptr i8, ptr %common.ret.op.i166, i64 8
  %sharer_pointer_184 = getelementptr i8, ptr %common.ret.op.i166, i64 16
  %eraser_pointer_185 = getelementptr i8, ptr %common.ret.op.i166, i64 24
  store ptr @returnAddress_172, ptr %returnAddress_pointer_183, align 8, !noalias !0
  store ptr @sharer_22, ptr %sharer_pointer_184, align 8, !noalias !0
  store ptr @eraser_26, ptr %eraser_pointer_185, align 8, !noalias !0
  %stackPointer.i21 = load ptr, ptr %stackPointer_pointer.i71, align 8
  %base.i22 = load ptr, ptr %base_pointer.i60, align 8
  %intStack.i23 = ptrtoint ptr %stackPointer.i21 to i64
  %intBase.i24 = ptrtoint ptr %base.i22 to i64
  %offset.i25 = sub i64 %intStack.i23, %intBase.i24
  %prompt.i183 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i188 = getelementptr i8, ptr %stackPointer.i21, i64 40
  %isInside.not.i189 = icmp ugt ptr %nextStackPointer.i188, %limit.i187
  br i1 %isInside.not.i189, label %realloc.i192, label %stackAllocate.exit206

realloc.i192:                                     ; preds = %stackAllocate.exit181
  %nextSize.i198 = add i64 %offset.i25, 40
  %leadingZeros.i.i199 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i198, i1 false)
  %numBits.i.i200 = sub nuw nsw i64 64, %leadingZeros.i.i199
  %result.i.i201 = shl nuw i64 1, %numBits.i.i200
  %newBase.i202 = tail call ptr @realloc(ptr %base.i22, i64 %result.i.i201)
  %newLimit.i203 = getelementptr i8, ptr %newBase.i202, i64 %result.i.i201
  %newStackPointer.i204 = getelementptr i8, ptr %newBase.i202, i64 %offset.i25
  %newNextStackPointer.i205 = getelementptr i8, ptr %newStackPointer.i204, i64 40
  store ptr %newBase.i202, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i203, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit206

stackAllocate.exit206:                            ; preds = %stackAllocate.exit181, %realloc.i192
  %limit.i212 = phi ptr [ %newLimit.i203, %realloc.i192 ], [ %limit.i187, %stackAllocate.exit181 ]
  %nextStackPointer.sink.i190 = phi ptr [ %newNextStackPointer.i205, %realloc.i192 ], [ %nextStackPointer.i188, %stackAllocate.exit181 ]
  %common.ret.op.i191 = phi ptr [ %newStackPointer.i204, %realloc.i192 ], [ %stackPointer.i21, %stackAllocate.exit181 ]
  store ptr %nextStackPointer.sink.i190, ptr %stackPointer_pointer.i71, align 8
  store i64 1, ptr %common.ret.op.i191, align 8, !noalias !0
  %stackPointer_202.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i191, i64 8
  store ptr null, ptr %stackPointer_202.repack7, align 8, !noalias !0
  %returnAddress_pointer_204 = getelementptr i8, ptr %common.ret.op.i191, i64 16
  %sharer_pointer_205 = getelementptr i8, ptr %common.ret.op.i191, i64 24
  %eraser_pointer_206 = getelementptr i8, ptr %common.ret.op.i191, i64 32
  store ptr @returnAddress_187, ptr %returnAddress_pointer_204, align 8, !noalias !0
  store ptr @sharer_195, ptr %sharer_pointer_205, align 8, !noalias !0
  store ptr @eraser_199, ptr %eraser_pointer_206, align 8, !noalias !0
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i71, align 8
  %base.i = load ptr, ptr %base_pointer.i60, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt.i208 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i213 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i214 = icmp ugt ptr %nextStackPointer.i213, %limit.i212
  br i1 %isInside.not.i214, label %realloc.i217, label %stackAllocate.exit231

realloc.i217:                                     ; preds = %stackAllocate.exit206
  %nextSize.i223 = add i64 %offset.i, 32
  %leadingZeros.i.i224 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i223, i1 false)
  %numBits.i.i225 = sub nuw nsw i64 64, %leadingZeros.i.i224
  %result.i.i226 = shl nuw i64 1, %numBits.i.i225
  %newBase.i227 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i226)
  %newLimit.i228 = getelementptr i8, ptr %newBase.i227, i64 %result.i.i226
  %newStackPointer.i229 = getelementptr i8, ptr %newBase.i227, i64 %offset.i
  %newNextStackPointer.i230 = getelementptr i8, ptr %newStackPointer.i229, i64 32
  store ptr %newBase.i227, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i228, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit231

stackAllocate.exit231:                            ; preds = %stackAllocate.exit206, %realloc.i217
  %base.i242 = phi ptr [ %newBase.i227, %realloc.i217 ], [ %base.i, %stackAllocate.exit206 ]
  %limit.i235 = phi ptr [ %newLimit.i228, %realloc.i217 ], [ %limit.i212, %stackAllocate.exit206 ]
  %nextStackPointer.sink.i215 = phi ptr [ %newNextStackPointer.i230, %realloc.i217 ], [ %nextStackPointer.i213, %stackAllocate.exit206 ]
  %common.ret.op.i216 = phi ptr [ %newStackPointer.i229, %realloc.i217 ], [ %stackPointer.i, %stackAllocate.exit206 ]
  store ptr %nextStackPointer.sink.i215, ptr %stackPointer_pointer.i71, align 8
  store i64 0, ptr %common.ret.op.i216, align 4, !noalias !0
  %returnAddress_pointer_218 = getelementptr i8, ptr %common.ret.op.i216, i64 8
  %sharer_pointer_219 = getelementptr i8, ptr %common.ret.op.i216, i64 16
  %eraser_pointer_220 = getelementptr i8, ptr %common.ret.op.i216, i64 24
  store ptr @returnAddress_207, ptr %returnAddress_pointer_218, align 8, !noalias !0
  store ptr @sharer_22, ptr %sharer_pointer_219, align 8, !noalias !0
  store ptr @eraser_26, ptr %eraser_pointer_220, align 8, !noalias !0
  %nextStackPointer.i236 = getelementptr i8, ptr %nextStackPointer.sink.i215, i64 104
  %isInside.not.i237 = icmp ugt ptr %nextStackPointer.i236, %limit.i235
  br i1 %isInside.not.i237, label %realloc.i240, label %stackAllocate.exit254

realloc.i240:                                     ; preds = %stackAllocate.exit231
  %intStackPointer.i243 = ptrtoint ptr %nextStackPointer.sink.i215 to i64
  %intBase.i244 = ptrtoint ptr %base.i242 to i64
  %size.i245 = sub i64 %intStackPointer.i243, %intBase.i244
  %nextSize.i246 = add i64 %size.i245, 104
  %leadingZeros.i.i247 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i246, i1 false)
  %numBits.i.i248 = sub nuw nsw i64 64, %leadingZeros.i.i247
  %result.i.i249 = shl nuw i64 1, %numBits.i.i248
  %newBase.i250 = tail call ptr @realloc(ptr %base.i242, i64 %result.i.i249)
  %newLimit.i251 = getelementptr i8, ptr %newBase.i250, i64 %result.i.i249
  %newStackPointer.i252 = getelementptr i8, ptr %newBase.i250, i64 %size.i245
  %newNextStackPointer.i253 = getelementptr i8, ptr %newStackPointer.i252, i64 104
  store ptr %newBase.i250, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i251, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit254

stackAllocate.exit254:                            ; preds = %stackAllocate.exit231, %realloc.i240
  %base.i.i = phi ptr [ %newBase.i250, %realloc.i240 ], [ %base.i242, %stackAllocate.exit231 ]
  %limit.i.i = phi ptr [ %newLimit.i251, %realloc.i240 ], [ %limit.i235, %stackAllocate.exit231 ]
  %nextStackPointer.sink.i238 = phi ptr [ %newNextStackPointer.i253, %realloc.i240 ], [ %nextStackPointer.i236, %stackAllocate.exit231 ]
  %common.ret.op.i239 = phi ptr [ %newStackPointer.i252, %realloc.i240 ], [ %nextStackPointer.sink.i215, %stackAllocate.exit231 ]
  store ptr %nextStackPointer.sink.i238, ptr %stackPointer_pointer.i71, align 8
  store i64 %i_6_91_275_275_5504, ptr %common.ret.op.i239, align 4, !noalias !0
  %tmp_5795_pointer_1635 = getelementptr i8, ptr %common.ret.op.i239, i64 8
  store i64 %tmp_5795, ptr %tmp_5795_pointer_1635, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1636 = getelementptr i8, ptr %common.ret.op.i239, i64 16
  store ptr %bitNum_7_7_5558.elt, ptr %bitNum_7_7_5558_pointer_1636, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1636.repack9 = getelementptr i8, ptr %common.ret.op.i239, i64 24
  store i64 %bitNum_7_7_5558.elt2, ptr %bitNum_7_7_5558_pointer_1636.repack9, align 8, !noalias !0
  %sum_3_3_5426_pointer_1637 = getelementptr i8, ptr %common.ret.op.i239, i64 32
  store ptr %sum_3_3_5426.elt, ptr %sum_3_3_5426_pointer_1637, align 8, !noalias !0
  %sum_3_3_5426_pointer_1637.repack12 = getelementptr i8, ptr %common.ret.op.i239, i64 40
  store i64 %sum_3_3_5426.elt4, ptr %sum_3_3_5426_pointer_1637.repack12, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1638 = getelementptr i8, ptr %common.ret.op.i239, i64 48
  store ptr %byteAcc_5_5_5418.elt, ptr %byteAcc_5_5_5418_pointer_1638, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1638.repack15 = getelementptr i8, ptr %common.ret.op.i239, i64 56
  store i64 %byteAcc_5_5_5418.elt6, ptr %byteAcc_5_5_5418_pointer_1638.repack15, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1639 = getelementptr i8, ptr %common.ret.op.i239, i64 64
  store ptr %prompt.i208, ptr %escape_19_110_294_294_5368_pointer_1639, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1639.repack17 = getelementptr i8, ptr %common.ret.op.i239, i64 72
  store i64 %offset.i, ptr %escape_19_110_294_294_5368_pointer_1639.repack17, align 8, !noalias !0
  %returnAddress_pointer_1640 = getelementptr i8, ptr %common.ret.op.i239, i64 80
  %sharer_pointer_1641 = getelementptr i8, ptr %common.ret.op.i239, i64 88
  %eraser_pointer_1642 = getelementptr i8, ptr %common.ret.op.i239, i64 96
  store ptr @returnAddress_1057, ptr %returnAddress_pointer_1640, align 8, !noalias !0
  store ptr @sharer_1584, ptr %sharer_pointer_1641, align 8, !noalias !0
  store ptr @eraser_1598, ptr %eraser_pointer_1642, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i238, i64 136
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit254
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i238 to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 136
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 136
  store ptr %newBase.i.i, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit254
  %limit.i2328.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %stackAllocate.exit254 ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit254 ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i238, %stackAllocate.exit254 ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i71, align 8
  store double %z.i156, ptr %common.ret.op.i.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_1042.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store ptr %prompt.i128, ptr %zizi_7_98_282_282_5424_pointer_1042.i, align 8, !noalias !0
  %zizi_7_98_282_282_5424_pointer_1042.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %offset.i45, ptr %zizi_7_98_282_282_5424_pointer_1042.repack1.i, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_1043.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %prompt.i78, ptr %zrzr_3_94_278_278_5552_pointer_1043.i, align 8, !noalias !0
  %zrzr_3_94_278_278_5552_pointer_1043.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %offset.i65, ptr %zrzr_3_94_278_278_5552_pointer_1043.repack3.i, align 8, !noalias !0
  %tmp_5760_pointer_1044.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store double %tmp_5760, ptr %tmp_5760_pointer_1044.i, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_1045.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr %prompt.i183, ptr %notDone_17_108_292_292_5542_pointer_1045.i, align 8, !noalias !0
  %notDone_17_108_292_292_5542_pointer_1045.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store i64 %offset.i25, ptr %notDone_17_108_292_292_5542_pointer_1045.repack5.i, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_1046.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr %prompt.i158, ptr %z_15_106_290_290_5374_pointer_1046.i, align 8, !noalias !0
  %z_15_106_290_290_5374_pointer_1046.repack7.i = getelementptr i8, ptr %common.ret.op.i.i, i64 72
  store i64 %offset.i35, ptr %z_15_106_290_290_5374_pointer_1046.repack7.i, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_1047.i = getelementptr i8, ptr %common.ret.op.i.i, i64 80
  store ptr %prompt.i103, ptr %zi_5_96_280_280_5410_pointer_1047.i, align 8, !noalias !0
  %zi_5_96_280_280_5410_pointer_1047.repack9.i = getelementptr i8, ptr %common.ret.op.i.i, i64 88
  store i64 %offset.i55, ptr %zi_5_96_280_280_5410_pointer_1047.repack9.i, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1048.i = getelementptr i8, ptr %common.ret.op.i.i, i64 96
  store ptr %prompt.i208, ptr %escape_19_110_294_294_5368_pointer_1048.i, align 8, !noalias !0
  %escape_19_110_294_294_5368_pointer_1048.repack11.i = getelementptr i8, ptr %common.ret.op.i.i, i64 104
  store i64 %offset.i, ptr %escape_19_110_294_294_5368_pointer_1048.repack11.i, align 8, !noalias !0
  %returnAddress_pointer_1049.i = getelementptr i8, ptr %common.ret.op.i.i, i64 112
  %sharer_pointer_1050.i = getelementptr i8, ptr %common.ret.op.i.i, i64 120
  %eraser_pointer_1051.i = getelementptr i8, ptr %common.ret.op.i.i, i64 128
  store ptr @returnAddress_221, ptr %returnAddress_pointer_1049.i, align 8, !noalias !0
  store ptr @sharer_392, ptr %sharer_pointer_1050.i, align 8, !noalias !0
  store ptr @eraser_410, ptr %eraser_pointer_1051.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %prompt.i183, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i19.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i20.i = load ptr, ptr %base_pointer.i19.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i20.i, i64 %offset.i25
  %notDone_17_108_292_292_5542_old_1053.elt13.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %notDone_17_108_292_292_5542_old_1053.unpack14.i = load ptr, ptr %notDone_17_108_292_292_5542_old_1053.elt13.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %notDone_17_108_292_292_5542_old_1053.unpack14.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %notDone_17_108_292_292_5542_old_1053.unpack14.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %notDone_17_108_292_292_5542_old_1053.unpack14.i, align 4
  %get_5887.unpack17.pre.i = load ptr, ptr %notDone_17_108_292_292_5542_old_1053.elt13.i, align 8, !noalias !0
  %stackPointer.i.pre.i = load ptr, ptr %stackPointer_pointer.i71, align 8, !alias.scope !0
  %limit.i23.pre.i = load ptr, ptr %limit_pointer.i72, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i23.i = phi ptr [ %limit.i2328.i, %stackAllocate.exit.i ], [ %limit.i23.pre.i, %next.i.i.i ]
  %stackPointer.i.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i.pre.i, %next.i.i.i ]
  %get_5887.unpack17.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_5887.unpack17.pre.i, %next.i.i.i ]
  %get_5887.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5887.unpack.i, 0
  %get_588718.i = insertvalue %Pos %0, ptr %get_5887.unpack17.i, 1
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i23.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i24.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i24.i, ptr %stackPointer_pointer.i71, align 8, !alias.scope !0
  %returnAddress_1054.i = load ptr, ptr %newStackPointer.i24.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1054.i(%Pos %get_588718.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1644(%Pos %__8_359_359_5631, ptr %stack) {
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
  %tmp_5795 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1647 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %bitNum_7_7_5558.unpack = load ptr, ptr %bitNum_7_7_5558_pointer_1647, align 8, !noalias !0
  %bitNum_7_7_5558.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bitNum_7_7_5558.unpack2 = load i64, ptr %bitNum_7_7_5558.elt1, align 8, !noalias !0
  %i_6_184_184_5319_pointer_1648 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %i_6_184_184_5319 = load i64, ptr %i_6_184_184_5319_pointer_1648, align 4, !noalias !0
  %sum_3_3_5426_pointer_1649 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %sum_3_3_5426.unpack = load ptr, ptr %sum_3_3_5426_pointer_1649, align 8, !noalias !0
  %sum_3_3_5426.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %sum_3_3_5426.unpack5 = load i64, ptr %sum_3_3_5426.elt4, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1650 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %byteAcc_5_5_5418.unpack = load ptr, ptr %byteAcc_5_5_5418_pointer_1650, align 8, !noalias !0
  %byteAcc_5_5_5418.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %byteAcc_5_5_5418.unpack8 = load i64, ptr %byteAcc_5_5_5418.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__8_359_359_5631, 1
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
  %0 = insertvalue %Reference poison, ptr %byteAcc_5_5_5418.unpack, 0
  %byteAcc_5_5_54189 = insertvalue %Reference %0, i64 %byteAcc_5_5_5418.unpack8, 1
  %1 = insertvalue %Reference poison, ptr %sum_3_3_5426.unpack, 0
  %sum_3_3_54266 = insertvalue %Reference %1, i64 %sum_3_3_5426.unpack5, 1
  %2 = insertvalue %Reference poison, ptr %bitNum_7_7_5558.unpack, 0
  %bitNum_7_7_55583 = insertvalue %Reference %2, i64 %bitNum_7_7_5558.unpack2, 1
  %z.i = add i64 %i_6_184_184_5319, 1
  musttail call tailcc void @loop_5_183_183_5532(i64 %z.i, i64 %tmp_5795, %Reference %bitNum_7_7_55583, %Reference %sum_3_3_54266, %Reference %byteAcc_5_5_54189, ptr nonnull %stack)
  ret void
}

define void @sharer_1656(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1668(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_5_183_183_5532(i64 %i_6_184_184_5319, i64 %tmp_5795, %Reference %bitNum_7_7_5558, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_184_184_5319, %tmp_5795
  %stackPointer_pointer.i12 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_1684, label %label_69

label_69:                                         ; preds = %entry
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i12, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i12, align 8, !alias.scope !0
  %returnAddress_66 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_66(%Pos zeroinitializer, ptr %stack)
  ret void

label_1684:                                       ; preds = %entry
  %limit_pointer.i13 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i12, align 8, !alias.scope !0
  %limit.i14 = load ptr, ptr %limit_pointer.i13, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i14
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_1684
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
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
  %newStackPointer.i15 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i15, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i13, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_1684, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_1684 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i15, %realloc.i ], [ %currentStackPointer.i, %label_1684 ]
  %z.i7 = sitofp i64 %i_6_184_184_5319 to double
  %z.i8 = fmul double %z.i7, 2.000000e+00
  %z.i9 = sitofp i64 %tmp_5795 to double
  %z.i10 = fdiv double %z.i8, %z.i9
  %z.i11 = fadd double %z.i10, -1.000000e+00
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i12, align 8
  store i64 %tmp_5795, ptr %common.ret.op.i, align 4, !noalias !0
  %bitNum_7_7_5558_pointer_1677 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %bitNum_7_7_5558.elt = extractvalue %Reference %bitNum_7_7_5558, 0
  store ptr %bitNum_7_7_5558.elt, ptr %bitNum_7_7_5558_pointer_1677, align 8, !noalias !0
  %bitNum_7_7_5558_pointer_1677.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %bitNum_7_7_5558.elt2 = extractvalue %Reference %bitNum_7_7_5558, 1
  store i64 %bitNum_7_7_5558.elt2, ptr %bitNum_7_7_5558_pointer_1677.repack1, align 8, !noalias !0
  %i_6_184_184_5319_pointer_1678 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_184_184_5319, ptr %i_6_184_184_5319_pointer_1678, align 4, !noalias !0
  %sum_3_3_5426_pointer_1679 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sum_3_3_5426.elt = extractvalue %Reference %sum_3_3_5426, 0
  store ptr %sum_3_3_5426.elt, ptr %sum_3_3_5426_pointer_1679, align 8, !noalias !0
  %sum_3_3_5426_pointer_1679.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sum_3_3_5426.elt4 = extractvalue %Reference %sum_3_3_5426, 1
  store i64 %sum_3_3_5426.elt4, ptr %sum_3_3_5426_pointer_1679.repack3, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1680 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %byteAcc_5_5_5418.elt = extractvalue %Reference %byteAcc_5_5_5418, 0
  store ptr %byteAcc_5_5_5418.elt, ptr %byteAcc_5_5_5418_pointer_1680, align 8, !noalias !0
  %byteAcc_5_5_5418_pointer_1680.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %byteAcc_5_5_5418.elt6 = extractvalue %Reference %byteAcc_5_5_5418, 1
  store i64 %byteAcc_5_5_5418.elt6, ptr %byteAcc_5_5_5418_pointer_1680.repack5, align 8, !noalias !0
  %returnAddress_pointer_1681 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_1682 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_1683 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_1644, ptr %returnAddress_pointer_1681, align 8, !noalias !0
  store ptr @sharer_1656, ptr %sharer_pointer_1682, align 8, !noalias !0
  store ptr @eraser_1668, ptr %eraser_pointer_1683, align 8, !noalias !0
  musttail call tailcc void @loop_5_90_274_274_5441(i64 0, i64 %tmp_5795, %Reference %bitNum_7_7_5558, double %z.i11, %Reference %sum_3_3_5426, %Reference %byteAcc_5_5_5418, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1685(%Pos %__361_361_5632, ptr %stack) {
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
  %sum_3_3_5426.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %sum_3_3_5426.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %sum_3_3_5426.unpack2 = load i64, ptr %sum_3_3_5426.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__361_361_5632, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %sum_3_3_5426.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %sum_3_3_5426.unpack2
  %get_5930 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1690 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1690(i64 %get_5930, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3553_3617, ptr %stack) {
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
  %limit.i60 = phi ptr [ %newLimit.i51, %realloc.i40 ], [ %limit.i, %stackAllocate.exit ]
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
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i23, align 8
  %base.i6 = load ptr, ptr %base_pointer.i14, align 8
  %intStack.i7 = ptrtoint ptr %stackPointer.i5 to i64
  %intBase.i8 = ptrtoint ptr %base.i6 to i64
  %offset.i9 = sub i64 %intStack.i7, %intBase.i8
  %prompt.i56 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i61 = getelementptr i8, ptr %stackPointer.i5, i64 32
  %isInside.not.i62 = icmp ugt ptr %nextStackPointer.i61, %limit.i60
  br i1 %isInside.not.i62, label %realloc.i65, label %stackAllocate.exit79

realloc.i65:                                      ; preds = %stackAllocate.exit54
  %nextSize.i71 = add i64 %offset.i9, 32
  %leadingZeros.i.i72 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i71, i1 false)
  %numBits.i.i73 = sub nuw nsw i64 64, %leadingZeros.i.i72
  %result.i.i74 = shl nuw i64 1, %numBits.i.i73
  %newBase.i75 = tail call ptr @realloc(ptr %base.i6, i64 %result.i.i74)
  %newLimit.i76 = getelementptr i8, ptr %newBase.i75, i64 %result.i.i74
  %newStackPointer.i77 = getelementptr i8, ptr %newBase.i75, i64 %offset.i9
  %newNextStackPointer.i78 = getelementptr i8, ptr %newStackPointer.i77, i64 32
  store ptr %newBase.i75, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i76, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit79

stackAllocate.exit79:                             ; preds = %stackAllocate.exit54, %realloc.i65
  %limit.i85 = phi ptr [ %newLimit.i76, %realloc.i65 ], [ %limit.i60, %stackAllocate.exit54 ]
  %nextStackPointer.sink.i63 = phi ptr [ %newNextStackPointer.i78, %realloc.i65 ], [ %nextStackPointer.i61, %stackAllocate.exit54 ]
  %common.ret.op.i64 = phi ptr [ %newStackPointer.i77, %realloc.i65 ], [ %stackPointer.i5, %stackAllocate.exit54 ]
  store ptr %nextStackPointer.sink.i63, ptr %stackPointer_pointer.i23, align 8
  store i64 0, ptr %common.ret.op.i64, align 4, !noalias !0
  %returnAddress_pointer_45 = getelementptr i8, ptr %common.ret.op.i64, i64 8
  %sharer_pointer_46 = getelementptr i8, ptr %common.ret.op.i64, i64 16
  %eraser_pointer_47 = getelementptr i8, ptr %common.ret.op.i64, i64 24
  store ptr @returnAddress_34, ptr %returnAddress_pointer_45, align 8, !noalias !0
  store ptr @sharer_22, ptr %sharer_pointer_46, align 8, !noalias !0
  store ptr @eraser_26, ptr %eraser_pointer_47, align 8, !noalias !0
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i23, align 8
  %base.i = load ptr, ptr %base_pointer.i14, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt.i81 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i86 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i87 = icmp ugt ptr %nextStackPointer.i86, %limit.i85
  br i1 %isInside.not.i87, label %realloc.i90, label %stackAllocate.exit104

realloc.i90:                                      ; preds = %stackAllocate.exit79
  %nextSize.i96 = add i64 %offset.i, 32
  %leadingZeros.i.i97 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i96, i1 false)
  %numBits.i.i98 = sub nuw nsw i64 64, %leadingZeros.i.i97
  %result.i.i99 = shl nuw i64 1, %numBits.i.i98
  %newBase.i100 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i99)
  %newLimit.i101 = getelementptr i8, ptr %newBase.i100, i64 %result.i.i99
  %newStackPointer.i102 = getelementptr i8, ptr %newBase.i100, i64 %offset.i
  %newNextStackPointer.i103 = getelementptr i8, ptr %newStackPointer.i102, i64 32
  store ptr %newBase.i100, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i101, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit104

stackAllocate.exit104:                            ; preds = %stackAllocate.exit79, %realloc.i90
  %base.i115 = phi ptr [ %newBase.i100, %realloc.i90 ], [ %base.i, %stackAllocate.exit79 ]
  %limit.i108 = phi ptr [ %newLimit.i101, %realloc.i90 ], [ %limit.i85, %stackAllocate.exit79 ]
  %nextStackPointer.sink.i88 = phi ptr [ %newNextStackPointer.i103, %realloc.i90 ], [ %nextStackPointer.i86, %stackAllocate.exit79 ]
  %common.ret.op.i89 = phi ptr [ %newStackPointer.i102, %realloc.i90 ], [ %stackPointer.i, %stackAllocate.exit79 ]
  store ptr %nextStackPointer.sink.i88, ptr %stackPointer_pointer.i23, align 8
  store i64 0, ptr %common.ret.op.i89, align 4, !noalias !0
  %returnAddress_pointer_59 = getelementptr i8, ptr %common.ret.op.i89, i64 8
  %sharer_pointer_60 = getelementptr i8, ptr %common.ret.op.i89, i64 16
  %eraser_pointer_61 = getelementptr i8, ptr %common.ret.op.i89, i64 24
  store ptr @returnAddress_48, ptr %returnAddress_pointer_59, align 8, !noalias !0
  store ptr @sharer_22, ptr %sharer_pointer_60, align 8, !noalias !0
  store ptr @eraser_26, ptr %eraser_pointer_61, align 8, !noalias !0
  %nextStackPointer.i109 = getelementptr i8, ptr %nextStackPointer.sink.i88, i64 40
  %isInside.not.i110 = icmp ugt ptr %nextStackPointer.i109, %limit.i108
  br i1 %isInside.not.i110, label %realloc.i113, label %stackAllocate.exit127

realloc.i113:                                     ; preds = %stackAllocate.exit104
  %intStackPointer.i116 = ptrtoint ptr %nextStackPointer.sink.i88 to i64
  %intBase.i117 = ptrtoint ptr %base.i115 to i64
  %size.i118 = sub i64 %intStackPointer.i116, %intBase.i117
  %nextSize.i119 = add i64 %size.i118, 40
  %leadingZeros.i.i120 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i119, i1 false)
  %numBits.i.i121 = sub nuw nsw i64 64, %leadingZeros.i.i120
  %result.i.i122 = shl nuw i64 1, %numBits.i.i121
  %newBase.i123 = tail call ptr @realloc(ptr %base.i115, i64 %result.i.i122)
  %newLimit.i124 = getelementptr i8, ptr %newBase.i123, i64 %result.i.i122
  %newStackPointer.i125 = getelementptr i8, ptr %newBase.i123, i64 %size.i118
  %newNextStackPointer.i126 = getelementptr i8, ptr %newStackPointer.i125, i64 40
  store ptr %newBase.i123, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i124, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit127

stackAllocate.exit127:                            ; preds = %stackAllocate.exit104, %realloc.i113
  %nextStackPointer.sink.i111 = phi ptr [ %newNextStackPointer.i126, %realloc.i113 ], [ %nextStackPointer.i109, %stackAllocate.exit104 ]
  %common.ret.op.i112 = phi ptr [ %newStackPointer.i125, %realloc.i113 ], [ %nextStackPointer.sink.i88, %stackAllocate.exit104 ]
  %reference..1.i = insertvalue %Reference undef, ptr %prompt.i81, 0
  %reference.i = insertvalue %Reference %reference..1.i, i64 %offset.i, 1
  %reference..1.i11 = insertvalue %Reference undef, ptr %prompt.i56, 0
  %reference.i12 = insertvalue %Reference %reference..1.i11, i64 %offset.i9, 1
  %reference..1.i21 = insertvalue %Reference undef, ptr %prompt.i31, 0
  %reference.i22 = insertvalue %Reference %reference..1.i21, i64 %offset.i19, 1
  %unboxed.i = extractvalue %Pos %v_coe_3553_3617, 0
  store ptr %nextStackPointer.sink.i111, ptr %stackPointer_pointer.i23, align 8
  store ptr %prompt.i31, ptr %common.ret.op.i112, align 8, !noalias !0
  %stackPointer_1695.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i112, i64 8
  store i64 %offset.i19, ptr %stackPointer_1695.repack1, align 8, !noalias !0
  %returnAddress_pointer_1697 = getelementptr i8, ptr %common.ret.op.i112, i64 16
  %sharer_pointer_1698 = getelementptr i8, ptr %common.ret.op.i112, i64 24
  %eraser_pointer_1699 = getelementptr i8, ptr %common.ret.op.i112, i64 32
  store ptr @returnAddress_1685, ptr %returnAddress_pointer_1697, align 8, !noalias !0
  store ptr @sharer_517, ptr %sharer_pointer_1698, align 8, !noalias !0
  store ptr @eraser_521, ptr %eraser_pointer_1699, align 8, !noalias !0
  musttail call tailcc void @loop_5_183_183_5532(i64 0, i64 %unboxed.i, %Reference %reference.i, %Reference %reference.i22, %Reference %reference.i12, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1705(%Pos %returned_5932, ptr nocapture %stack) {
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
  %returnAddress_1707 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1707(%Pos %returned_5932, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_1710(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_1712(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define void @eraser_1725(ptr nocapture readonly %environment) {
entry:
  %tmp_5728_1723.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5728_1723.unpack2 = load ptr, ptr %tmp_5728_1723.elt1, align 8, !noalias !0
  %acc_3_3_5_169_5114_1724.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_5114_1724.unpack5 = load ptr, ptr %acc_3_3_5_169_5114_1724.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_5728_1723.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_5728_1723.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_5728_1723.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_5728_1723.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_5728_1723.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_5728_1723.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_5114_1724.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_5114_1724.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_5114_1724.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_5114_1724.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_5114_1724.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_5114_1724.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4973(i64 %start_2_2_4_168_5213, %Pos %acc_3_3_5_169_5114, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_5213, 1
  br i1 %z.i6, label %label_1735, label %label_1731

label_1731:                                       ; preds = %entry, %label_1731
  %acc_3_3_5_169_5114.tr8 = phi %Pos [ %make_5938, %label_1731 ], [ %acc_3_3_5_169_5114, %entry ]
  %start_2_2_4_168_5213.tr7 = phi i64 [ %z.i5, %label_1731 ], [ %start_2_2_4_168_5213, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_5213.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_5213.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1725, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5935.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_5935.elt, ptr %environment.i, align 8, !noalias !0
  %environment_1722.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5935.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_5935.elt2, ptr %environment_1722.repack1, align 8, !noalias !0
  %acc_3_3_5_169_5114_pointer_1729 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_5114.elt = extractvalue %Pos %acc_3_3_5_169_5114.tr8, 0
  store i64 %acc_3_3_5_169_5114.elt, ptr %acc_3_3_5_169_5114_pointer_1729, align 8, !noalias !0
  %acc_3_3_5_169_5114_pointer_1729.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_5114.elt4 = extractvalue %Pos %acc_3_3_5_169_5114.tr8, 1
  store ptr %acc_3_3_5_169_5114.elt4, ptr %acc_3_3_5_169_5114_pointer_1729.repack3, align 8, !noalias !0
  %make_5938 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_5213.tr7, 2
  br i1 %z.i, label %label_1735, label %label_1731

label_1735:                                       ; preds = %label_1731, %entry
  %acc_3_3_5_169_5114.tr.lcssa = phi %Pos [ %acc_3_3_5_169_5114, %entry ], [ %make_5938, %label_1731 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1732 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1732(%Pos %acc_3_3_5_169_5114.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1746(%Pos %v_r_2710_32_59_223_5049, ptr %stack) {
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
  %tmp_5735 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %index_7_34_198_4957_pointer_1749 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %index_7_34_198_4957 = load i64, ptr %index_7_34_198_4957_pointer_1749, align 4, !noalias !0
  %acc_8_35_199_4956_pointer_1750 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %acc_8_35_199_4956 = load i64, ptr %acc_8_35_199_4956_pointer_1750, align 4, !noalias !0
  %v_r_2613_30_194_5131_pointer_1751 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2613_30_194_5131.unpack = load i64, ptr %v_r_2613_30_194_5131_pointer_1751, align 8, !noalias !0
  %v_r_2613_30_194_5131.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2613_30_194_5131.unpack2 = load ptr, ptr %v_r_2613_30_194_5131.elt1, align 8, !noalias !0
  %p_8_9_4906_pointer_1752 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_4906 = load ptr, ptr %p_8_9_4906_pointer_1752, align 8, !noalias !0
  %tag_1753 = extractvalue %Pos %v_r_2710_32_59_223_5049, 0
  %fields_1754 = extractvalue %Pos %v_r_2710_32_59_223_5049, 1
  switch i64 %tag_1753, label %common.ret [
    i64 1, label %label_1778
    i64 0, label %label_1785
  ]

common.ret:                                       ; preds = %entry
  ret void

label_1766:                                       ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2613_30_194_5131.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_1766
  %referenceCount.i.i37 = load i64, ptr %v_r_2613_30_194_5131.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2613_30_194_5131.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2613_30_194_5131.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2613_30_194_5131.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2613_30_194_5131.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_1766, %decr.i.i39, %free.i.i41
  %pair_1761 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4906)
  %k_13_14_4_5637 = extractvalue <{ ptr, ptr }> %pair_1761, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_5637, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_5637, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_5637, i64 40
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
  %stack_1762 = extractvalue <{ ptr, ptr }> %pair_1761, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_1762, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_1762, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_1763 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1763(%Pos { i64 10, ptr null }, ptr %stack_1762)
  ret void

label_1775:                                       ; preds = %label_1777
  %isNull.i.i24 = icmp eq ptr %v_r_2613_30_194_5131.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_1775
  %referenceCount.i.i26 = load i64, ptr %v_r_2613_30_194_5131.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2613_30_194_5131.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2613_30_194_5131.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2613_30_194_5131.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2613_30_194_5131.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_1775, %decr.i.i28, %free.i.i30
  %pair_1770 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4906)
  %k_13_14_4_5636 = extractvalue <{ ptr, ptr }> %pair_1770, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_5636, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_5636, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5636, i64 40
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
  %stack_1771 = extractvalue <{ ptr, ptr }> %pair_1770, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_1771, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_1771, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_1772 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1772(%Pos { i64 10, ptr null }, ptr %stack_1771)
  ret void

label_1776:                                       ; preds = %label_1777
  %0 = insertvalue %Pos poison, i64 %v_r_2613_30_194_5131.unpack, 0
  %v_r_2613_30_194_51313 = insertvalue %Pos %0, ptr %v_r_2613_30_194_5131.unpack2, 1
  %z.i = add i64 %index_7_34_198_4957, 1
  %z.i108 = mul i64 %acc_8_35_199_4956, 10
  %z.i109 = sub i64 %z.i108, %tmp_5735
  %z.i110 = add i64 %z.i109, %v_coe_3528_46_73_237_5160.unpack
  musttail call tailcc void @go_6_33_197_5069(i64 %z.i, i64 %z.i110, i64 %tmp_5735, %Pos %v_r_2613_30_194_51313, ptr %p_8_9_4906, ptr nonnull %stack)
  ret void

label_1777:                                       ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3528_46_73_237_5160.unpack, 58
  br i1 %z.i111, label %label_1776, label %label_1775

label_1778:                                       ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_1754, i64 16
  %v_coe_3528_46_73_237_5160.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3528_46_73_237_5160.elt4 = getelementptr i8, ptr %fields_1754, i64 24
  %v_coe_3528_46_73_237_5160.unpack5 = load ptr, ptr %v_coe_3528_46_73_237_5160.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3528_46_73_237_5160.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_1778
  %referenceCount.i.i = load i64, ptr %v_coe_3528_46_73_237_5160.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3528_46_73_237_5160.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_1778
  %referenceCount.i11 = load i64, ptr %fields_1754, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_1754, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_1754, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_1754)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_3528_46_73_237_5160.unpack, 47
  br i1 %z.i112, label %label_1777, label %label_1766

label_1785:                                       ; preds = %entry
  %isNull.i = icmp eq ptr %fields_1754, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_1785
  %referenceCount.i = load i64, ptr %fields_1754, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_1754, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_1754, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_1754, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_1754)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_1785, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_2613_30_194_5131.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2613_30_194_5131.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2613_30_194_5131.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2613_30_194_5131.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2613_30_194_5131.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2613_30_194_5131.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1782 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1782(i64 %acc_8_35_199_4956, ptr nonnull %stack)
  ret void
}

define void @sharer_1791(ptr %stackPointer) {
entry:
  %v_r_2613_30_194_5131_1789.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2613_30_194_5131_1789.unpack2 = load ptr, ptr %v_r_2613_30_194_5131_1789.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2613_30_194_5131_1789.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2613_30_194_5131_1789.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2613_30_194_5131_1789.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1803(ptr %stackPointer) {
entry:
  %v_r_2613_30_194_5131_1801.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2613_30_194_5131_1801.unpack2 = load ptr, ptr %v_r_2613_30_194_5131_1801.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2613_30_194_5131_1801.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2613_30_194_5131_1801.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2613_30_194_5131_1801.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2613_30_194_5131_1801.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2613_30_194_5131_1801.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2613_30_194_5131_1801.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1820(%Pos %returned_5963, ptr nocapture %stack) {
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
  %returnAddress_1822 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1822(%Pos %returned_5963, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_5086_clause_1829(ptr %closure, %Pos %exc_8_20_47_211_5191, %Pos %msg_9_21_48_212_4945, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4953 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_1832 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4953)
  %k_11_23_50_214_5231 = extractvalue <{ ptr, ptr }> %pair_1832, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_5231, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_5231, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_5231, i64 40
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
  %stack_1833 = extractvalue <{ ptr, ptr }> %pair_1832, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1725, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_5191.elt = extractvalue %Pos %exc_8_20_47_211_5191, 0
  store i64 %exc_8_20_47_211_5191.elt, ptr %environment.i, align 8, !noalias !0
  %environment_1835.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_5191.elt2 = extractvalue %Pos %exc_8_20_47_211_5191, 1
  store ptr %exc_8_20_47_211_5191.elt2, ptr %environment_1835.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4945_pointer_1839 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4945.elt = extractvalue %Pos %msg_9_21_48_212_4945, 0
  store i64 %msg_9_21_48_212_4945.elt, ptr %msg_9_21_48_212_4945_pointer_1839, align 8, !noalias !0
  %msg_9_21_48_212_4945_pointer_1839.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4945.elt4 = extractvalue %Pos %msg_9_21_48_212_4945, 1
  store ptr %msg_9_21_48_212_4945.elt4, ptr %msg_9_21_48_212_4945_pointer_1839.repack3, align 8, !noalias !0
  %make_5964 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_1833, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_1833, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_1841 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1841(%Pos %make_5964, ptr %stack_1833)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_1848(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_1856(ptr nocapture readonly %environment) {
entry:
  %tmp_5737_1855.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5737_1855.unpack2 = load ptr, ptr %tmp_5737_1855.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5737_1855.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5737_1855.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5737_1855.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5737_1855.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5737_1855.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5737_1855.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_1852(i64 %v_coe_3527_6_28_55_219_5211, ptr %stack) {
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
  store ptr @eraser_1856, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3527_6_28_55_219_5211, ptr %environment.i, align 8, !noalias !0
  %environment_1854.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_1854.repack1, align 8, !noalias !0
  %make_5966 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1860 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1860(%Pos %make_5966, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_5069(i64 %index_7_34_198_4957, i64 %acc_8_35_199_4956, i64 %tmp_5735, %Pos %v_r_2613_30_194_5131, ptr %p_8_9_4906, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2613_30_194_5131, 1
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
  store i64 %tmp_5735, ptr %common.ret.op.i, align 4, !noalias !0
  %index_7_34_198_4957_pointer_1812 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %index_7_34_198_4957, ptr %index_7_34_198_4957_pointer_1812, align 4, !noalias !0
  %acc_8_35_199_4956_pointer_1813 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %acc_8_35_199_4956, ptr %acc_8_35_199_4956_pointer_1813, align 4, !noalias !0
  %v_r_2613_30_194_5131_pointer_1814 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %v_r_2613_30_194_5131.elt = extractvalue %Pos %v_r_2613_30_194_5131, 0
  store i64 %v_r_2613_30_194_5131.elt, ptr %v_r_2613_30_194_5131_pointer_1814, align 8, !noalias !0
  %v_r_2613_30_194_5131_pointer_1814.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %object.i3, ptr %v_r_2613_30_194_5131_pointer_1814.repack1, align 8, !noalias !0
  %p_8_9_4906_pointer_1815 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %p_8_9_4906, ptr %p_8_9_4906_pointer_1815, align 8, !noalias !0
  %returnAddress_pointer_1816 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1817 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1818 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_1746, ptr %returnAddress_pointer_1816, align 8, !noalias !0
  store ptr @sharer_1791, ptr %sharer_pointer_1817, align 8, !noalias !0
  store ptr @eraser_1803, ptr %eraser_pointer_1818, align 8, !noalias !0
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
  %sharer_pointer_1827 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_1828 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_1820, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_1710, ptr %sharer_pointer_1827, align 8, !noalias !0
  store ptr @eraser_1712, ptr %eraser_pointer_1828, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1848, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_5086 = insertvalue %Neg { ptr @vtable_1844, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_1865 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_1866 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_1852, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_1865, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_1866, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2613_30_194_5131, i64 %index_7_34_198_4957, %Neg %Exception_7_19_46_210_5086, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_5189_clause_1867(ptr %closure, %Pos %exception_10_107_134_298_5967, %Pos %msg_11_108_135_299_5968, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4906 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_5967, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_5968, 1
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
  %pair_1870 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4906)
  %k_13_14_4_5718 = extractvalue <{ ptr, ptr }> %pair_1870, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_5718, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_5718, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5718, i64 40
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
  %stack_1871 = extractvalue <{ ptr, ptr }> %pair_1870, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_1871, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_1871, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_1872 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1872(%Pos { i64 10, ptr null }, ptr %stack_1871)
  ret void
}

define tailcc void @returnAddress_1886(i64 %v_coe_3532_22_131_158_322_5203, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3532_22_131_158_322_5203, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1887 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1887(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1898(i64 %v_r_2724_1_9_20_129_156_320_5030, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2724_1_9_20_129_156_320_5030
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1899 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1899(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1881(i64 %v_r_2723_3_14_123_150_314_4986, ptr %stack) {
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
  %tmp_5735 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %v_r_2613_30_194_5131_pointer_1884 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2613_30_194_5131.unpack = load i64, ptr %v_r_2613_30_194_5131_pointer_1884, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2613_30_194_5131.unpack, 0
  %v_r_2613_30_194_5131.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2613_30_194_5131.unpack2 = load ptr, ptr %v_r_2613_30_194_5131.elt1, align 8, !noalias !0
  %v_r_2613_30_194_51313 = insertvalue %Pos %0, ptr %v_r_2613_30_194_5131.unpack2, 1
  %p_8_9_4906_pointer_1885 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_4906 = load ptr, ptr %p_8_9_4906_pointer_1885, align 8, !noalias !0
  %z.i = icmp eq i64 %v_r_2723_3_14_123_150_314_4986, 45
  %isInside.not.i = icmp ugt ptr %p_8_9_4906_pointer_1885, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %p_8_9_4906_pointer_1885, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_1892 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_1893 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1886, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_1892, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_1893, align 8, !noalias !0
  br i1 %z.i, label %label_1906, label %label_1897

label_1897:                                       ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_5069(i64 0, i64 0, i64 %tmp_5735, %Pos %v_r_2613_30_194_51313, ptr %p_8_9_4906, ptr nonnull %stack)
  ret void

label_1906:                                       ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_1906
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

stackAllocate.exit35:                             ; preds = %label_1906, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_1906 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_1906 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_1904 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_1905 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_1898, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_1904, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_1905, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_5069(i64 1, i64 0, i64 %tmp_5735, %Pos %v_r_2613_30_194_51313, ptr %p_8_9_4906, ptr nonnull %stack)
  ret void
}

define void @sharer_1910(ptr %stackPointer) {
entry:
  %v_r_2613_30_194_5131_1908.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2613_30_194_5131_1908.unpack2 = load ptr, ptr %v_r_2613_30_194_5131_1908.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2613_30_194_5131_1908.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2613_30_194_5131_1908.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2613_30_194_5131_1908.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1918(ptr %stackPointer) {
entry:
  %v_r_2613_30_194_5131_1916.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2613_30_194_5131_1916.unpack2 = load ptr, ptr %v_r_2613_30_194_5131_1916.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2613_30_194_5131_1916.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2613_30_194_5131_1916.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2613_30_194_5131_1916.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2613_30_194_5131_1916.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2613_30_194_5131_1916.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2613_30_194_5131_1916.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1743(%Pos %v_r_2613_30_194_5131, ptr %stack) {
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
  %p_8_9_4906 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1848, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4906, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2613_30_194_5131, 1
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
  %v_r_2613_30_194_5131_pointer_1925 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_r_2613_30_194_5131.elt = extractvalue %Pos %v_r_2613_30_194_5131, 0
  store i64 %v_r_2613_30_194_5131.elt, ptr %v_r_2613_30_194_5131_pointer_1925, align 8, !noalias !0
  %v_r_2613_30_194_5131_pointer_1925.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i3, ptr %v_r_2613_30_194_5131_pointer_1925.repack1, align 8, !noalias !0
  %p_8_9_4906_pointer_1926 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %p_8_9_4906, ptr %p_8_9_4906_pointer_1926, align 8, !noalias !0
  %returnAddress_pointer_1927 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_1928 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_1929 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_1881, ptr %returnAddress_pointer_1927, align 8, !noalias !0
  store ptr @sharer_1910, ptr %sharer_pointer_1928, align 8, !noalias !0
  store ptr @eraser_1918, ptr %eraser_pointer_1929, align 8, !noalias !0
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
  store i64 %v_r_2613_30_194_5131.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_2024.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_2024.repack1.i, align 8, !noalias !0
  %index_2107_pointer_2026.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_2026.i, align 4, !noalias !0
  %Exception_2362_pointer_2027.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_1875, ptr %Exception_2362_pointer_2027.i, align 8, !noalias !0
  %Exception_2362_pointer_2027.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_2027.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_2028.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_2029.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_2030.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_1990, ptr %returnAddress_pointer_2028.i, align 8, !noalias !0
  store ptr @sharer_2011, ptr %sharer_pointer_2029.i, align 8, !noalias !0
  store ptr @eraser_2019, ptr %eraser_pointer_2030.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2613_30_194_5131)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_2034.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2034.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_1931(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1935(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1740(%Pos %v_r_2612_24_188_5156, ptr %stack) {
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
  %p_8_9_4906 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4906, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_1941 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1942 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1743, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1931, ptr %sharer_pointer_1941, align 8, !noalias !0
  store ptr @eraser_1935, ptr %eraser_pointer_1942, align 8, !noalias !0
  %tag_1943 = extractvalue %Pos %v_r_2612_24_188_5156, 0
  switch i64 %tag_1943, label %label_1945 [
    i64 0, label %label_1949
    i64 1, label %label_1955
  ]

label_1945:                                       ; preds = %stackAllocate.exit
  ret void

label_1949:                                       ; preds = %stackAllocate.exit
  %utf8StringLiteral_5983 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5983.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1946 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1946(%Pos %utf8StringLiteral_5983, ptr nonnull %stack)
  ret void

label_1955:                                       ; preds = %stackAllocate.exit
  %fields_1944 = extractvalue %Pos %v_r_2612_24_188_5156, 1
  %environment.i = getelementptr i8, ptr %fields_1944, i64 16
  %v_y_3354_8_29_193_5090.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3354_8_29_193_5090.elt1 = getelementptr i8, ptr %fields_1944, i64 24
  %v_y_3354_8_29_193_5090.unpack2 = load ptr, ptr %v_y_3354_8_29_193_5090.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3354_8_29_193_5090.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_1955
  %referenceCount.i.i = load i64, ptr %v_y_3354_8_29_193_5090.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3354_8_29_193_5090.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_1955
  %referenceCount.i = load i64, ptr %fields_1944, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_1944, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_1944, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_1944)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3354_8_29_193_5090.unpack, 0
  %v_y_3354_8_29_193_50903 = insertvalue %Pos %0, ptr %v_y_3354_8_29_193_5090.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1952 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1952(%Pos %v_y_3354_8_29_193_50903, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1737(%Pos %v_r_2611_13_177_5054, ptr %stack) {
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
  %p_8_9_4906 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4906, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_1961 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1962 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1740, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1931, ptr %sharer_pointer_1961, align 8, !noalias !0
  store ptr @eraser_1935, ptr %eraser_pointer_1962, align 8, !noalias !0
  %tag_1963 = extractvalue %Pos %v_r_2611_13_177_5054, 0
  switch i64 %tag_1963, label %label_1965 [
    i64 0, label %label_1970
    i64 1, label %label_1982
  ]

label_1965:                                       ; preds = %stackAllocate.exit
  ret void

label_1970:                                       ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4906, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_1743, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1931, ptr %sharer_pointer_1961, align 8, !noalias !0
  store ptr @eraser_1935, ptr %eraser_pointer_1962, align 8, !noalias !0
  %utf8StringLiteral_5983.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5983.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1946.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1946.i(%Pos %utf8StringLiteral_5983.i, ptr nonnull %stack)
  ret void

label_1982:                                       ; preds = %stackAllocate.exit
  %fields_1964 = extractvalue %Pos %v_r_2611_13_177_5054, 1
  %environment.i6 = getelementptr i8, ptr %fields_1964, i64 16
  %v_y_2863_10_21_185_5157.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_2863_10_21_185_5157.elt1 = getelementptr i8, ptr %fields_1964, i64 24
  %v_y_2863_10_21_185_5157.unpack2 = load ptr, ptr %v_y_2863_10_21_185_5157.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2863_10_21_185_5157.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_1982
  %referenceCount.i.i = load i64, ptr %v_y_2863_10_21_185_5157.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2863_10_21_185_5157.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_1982
  %referenceCount.i = load i64, ptr %fields_1964, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_1964, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_1964, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_1964)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1856, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2863_10_21_185_5157.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_1975.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2863_10_21_185_5157.unpack2, ptr %environment_1975.repack4, align 8, !noalias !0
  %make_5985 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1979 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1979(%Pos %make_5985, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2473(ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_1702 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_1703 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_6, ptr %sharer_pointer_1702, align 8, !noalias !0
  store ptr @eraser_8, ptr %eraser_pointer_1703, align 8, !noalias !0
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
  %sharer_pointer_1716 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_1717 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_1705, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_1710, ptr %sharer_pointer_1716, align 8, !noalias !0
  store ptr @eraser_1712, ptr %eraser_pointer_1717, align 8, !noalias !0
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
  %returnAddress_pointer_1987 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_1988 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_1989 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_1737, ptr %returnAddress_pointer_1987, align 8, !noalias !0
  store ptr @sharer_1931, ptr %sharer_pointer_1988, align 8, !noalias !0
  store ptr @eraser_1935, ptr %eraser_pointer_1989, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_1735.i, label %label_1731.i

label_1731.i:                                     ; preds = %stackAllocate.exit46, %label_1731.i
  %acc_3_3_5_169_5114.tr8.i = phi %Pos [ %make_5938.i, %label_1731.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_5213.tr7.i = phi i64 [ %z.i5.i, %label_1731.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_5213.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_5213.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_1725, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_5935.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_5935.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_1722.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_5935.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_5935.elt2.i, ptr %environment_1722.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_5114_pointer_1729.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_5114.elt.i = extractvalue %Pos %acc_3_3_5_169_5114.tr8.i, 0
  store i64 %acc_3_3_5_169_5114.elt.i, ptr %acc_3_3_5_169_5114_pointer_1729.i, align 8, !noalias !0
  %acc_3_3_5_169_5114_pointer_1729.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_5114.elt4.i = extractvalue %Pos %acc_3_3_5_169_5114.tr8.i, 1
  store ptr %acc_3_3_5_169_5114.elt4.i, ptr %acc_3_3_5_169_5114_pointer_1729.repack3.i, align 8, !noalias !0
  %make_5938.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_5213.tr7.i, 2
  br i1 %z.i.i, label %label_1735.i.loopexit, label %label_1731.i

label_1735.i.loopexit:                            ; preds = %label_1731.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_1735.i

label_1735.i:                                     ; preds = %label_1735.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_1735.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_1735.i.loopexit ]
  %acc_3_3_5_169_5114.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_5938.i, %label_1735.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_1732.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1732.i(%Pos %acc_3_3_5_169_5114.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_1990(%Pos %v_r_2792_3584, ptr %stack) {
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
  %index_2107_pointer_1993 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_1993, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_1995 = extractvalue %Pos %v_r_2792_3584, 0
  switch i64 %tag_1995, label %label_1997 [
    i64 0, label %label_2001
    i64 1, label %label_2007
  ]

label_1997:                                       ; preds = %entry
  ret void

label_2001:                                       ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_2001
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

eraseNegative.exit:                               ; preds = %label_2001, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1998 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1998(i64 %x.i, ptr nonnull %stack)
  ret void

label_2007:                                       ; preds = %entry
  %Exception_2362_pointer_1994 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_1994, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_5802 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5802.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5802, %Pos %z.i)
  %utf8StringLiteral_5804 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_5804.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5804)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_5807 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5807.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_5807)
  %functionPointer_2006 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_2006(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_2011(ptr %stackPointer) {
entry:
  %str_2106_2008.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_2008.unpack2 = load ptr, ptr %str_2106_2008.elt1, align 8, !noalias !0
  %Exception_2362_2010.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_2010.unpack5 = load ptr, ptr %Exception_2362_2010.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_2008.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_2008.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_2008.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_2010.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_2010.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_2010.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_2019(ptr %stackPointer) {
entry:
  %str_2106_2016.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_2016.unpack2 = load ptr, ptr %str_2106_2016.elt1, align 8, !noalias !0
  %Exception_2362_2018.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_2018.unpack5 = load ptr, ptr %Exception_2362_2018.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_2016.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_2016.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_2016.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_2016.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_2016.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_2016.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_2018.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_2018.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_2018.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_2018.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_2018.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_2018.unpack5)
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
  %stackPointer_2024.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_2024.repack1, align 8, !noalias !0
  %index_2107_pointer_2026 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_2026, align 4, !noalias !0
  %Exception_2362_pointer_2027 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_2027, align 8, !noalias !0
  %Exception_2362_pointer_2027.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_2027.repack3, align 8, !noalias !0
  %returnAddress_pointer_2028 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_2029 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_2030 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_1990, ptr %returnAddress_pointer_2028, align 8, !noalias !0
  store ptr @sharer_2011, ptr %sharer_pointer_2029, align 8, !noalias !0
  store ptr @eraser_2019, ptr %eraser_pointer_2030, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_2037, label %label_2042

label_2037:                                       ; preds = %stackAllocate.exit
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
  %returnAddress_2034 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2034(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_2042:                                       ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_2042
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

erasePositive.exit:                               ; preds = %label_2042, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_2039 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2039(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  tail call tailcc void @main_2473(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2473(ptr nonnull %stack.i2.i)
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
