; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:towers_12b1f0e7-445e-4261-b725-65ad12f26a58/towers.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:towers_12b1f0e7-445e-4261-b725-65ad12f26a58/towers.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_194 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_5114_clause_179]
@vtable_225 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_5104_clause_217]
@utf8StringLiteral_5536.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_5417.lit = private constant [40 x i8] c"Cannot put a big disk onto a smaller one"
@utf8StringLiteral_5437.lit = private constant [46 x i8] c"Attempting to remove a disk from an empty pile"
@utf8StringLiteral_5449.lit = private constant [46 x i8] c"Attempting to remove a disk from an empty pile"
@utf8StringLiteral_5386.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_5388.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_5391.lit = private constant [1 x i8] c"'"

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #0

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) #1

; Function Attrs: mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite)
declare noalias noundef ptr @realloc(ptr allocptr nocapture, i64 noundef) local_unnamed_addr #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #3

declare void @exit(i64) local_unnamed_addr

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

declare %Pos @c_array_new(i64) local_unnamed_addr

declare %Pos @c_array_get(%Pos, i64) local_unnamed_addr

declare %Pos @c_array_set(%Pos, i64, %Pos) local_unnamed_addr

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

define %Pos @panic_552(%Pos %msg_551) local_unnamed_addr {
  tail call void @c_io_println_String(%Pos %msg_551)
  tail call void @exit(i32 1)
  ret %Pos zeroinitializer
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

define %Pos @allocate_2473(i64 %size_2472) local_unnamed_addr {
  %z = tail call %Pos @c_array_new(i64 %size_2472)
  ret %Pos %z
}

define %Pos @unsafeGet_2487(%Pos %arr_2485, i64 %index_2486) local_unnamed_addr {
  %z = tail call %Pos @c_array_get(%Pos %arr_2485, i64 %index_2486)
  ret %Pos %z
}

define %Pos @unsafeSet_2492(%Pos %arr_2489, i64 %index_2490, %Pos %value_2491) local_unnamed_addr {
  %z = tail call %Pos @c_array_set(%Pos %arr_2489, i64 %index_2490, %Pos %value_2491)
  ret %Pos %z
}

define tailcc void @returnAddress_10(i64 %v_r_3004_2_5191, ptr %stack) {
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
  %i_6_5187 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5370_pointer_13 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5370 = load i64, ptr %tmp_5370_pointer_13, align 4, !noalias !0
  %z.i = add i64 %i_6_5187, 1
  %z.i.i = icmp slt i64 %z.i, %tmp_5370
  br i1 %z.i.i, label %stackAllocate.exit.i, label %label_9.i

label_9.i:                                        ; preds = %entry
  %isInside.i.i = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_6.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_6.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

stackAllocate.exit.i:                             ; preds = %entry
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %z.i, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5370_pointer_28.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %tmp_5370, ptr %tmp_5370_pointer_28.i, align 4, !noalias !0
  %sharer_pointer_30.i = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_31.i = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_10, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30.i, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31.i, align 8, !noalias !0
  musttail call tailcc void @run_2856(i64 13, ptr nonnull %stack)
  ret void
}

define void @sharer_16(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_22(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_5_5185(i64 %i_6_5187, i64 %tmp_5370, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_5187, %tmp_5370
  %stackPointer_pointer.i1 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_32, label %label_9

label_9:                                          ; preds = %entry
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %returnAddress_6 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_6(%Pos zeroinitializer, ptr %stack)
  ret void

label_32:                                         ; preds = %entry
  %limit_pointer.i2 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %limit.i3 = load ptr, ptr %limit_pointer.i2, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i3
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_32
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
  %newStackPointer.i4 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i4, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i2, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_32, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_32 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i4, %realloc.i ], [ %currentStackPointer.i, %label_32 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i1, align 8
  store i64 %i_6_5187, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5370_pointer_28 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5370, ptr %tmp_5370_pointer_28, align 4, !noalias !0
  %returnAddress_pointer_29 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_30 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_31 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31, align 8, !noalias !0
  musttail call tailcc void @run_2856(i64 13, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_34(i64 %r_2886, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2886)
  tail call void @c_io_println_String(%Pos %z.i)
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_35 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_35(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_38(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_40(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_33(%Pos %v_r_3006_5480, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %v_r_3006_5480, 1
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
  %limit.i3 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 24
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i3
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
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 24
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_44 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_45 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_34, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_44, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_45, align 8, !noalias !0
  musttail call tailcc void @run_2856(i64 13, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_4046_4110, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_4046_4110, 0
  %z.i = add i64 %unboxed.i, -1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_48 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_49 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_33, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_48, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_49, align 8, !noalias !0
  %z.i.i = icmp sgt i64 %z.i, 0
  br i1 %z.i.i, label %label_32.i, label %stackAllocate.exit.i6

stackAllocate.exit.i6:                            ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr @returnAddress_34, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_48, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_49, align 8, !noalias !0
  musttail call tailcc void @run_2856(i64 13, ptr nonnull %stack)
  ret void

label_32.i:                                       ; preds = %stackAllocate.exit
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_32.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 40
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i4.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i4.i, i64 40
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_32.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_32.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i4.i, %realloc.i.i ], [ %oldStackPointer.i, %label_32.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 0, ptr %common.ret.op.i.i, align 4, !noalias !0
  %tmp_5370_pointer_28.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %z.i, ptr %tmp_5370_pointer_28.i, align 4, !noalias !0
  %returnAddress_pointer_29.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %sharer_pointer_30.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  %eraser_pointer_31.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29.i, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30.i, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31.i, align 8, !noalias !0
  musttail call tailcc void @run_2856(i64 13, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_55(%Pos %returned_5485, ptr nocapture %stack) {
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
  %returnAddress_57 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_57(%Pos %returned_5485, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_60(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_62(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define void @eraser_75(ptr nocapture readonly %environment) {
entry:
  %tmp_5343_73.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5343_73.unpack2 = load ptr, ptr %tmp_5343_73.elt1, align 8, !noalias !0
  %acc_3_3_5_169_5036_74.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_5036_74.unpack5 = load ptr, ptr %acc_3_3_5_169_5036_74.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_5343_73.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_5343_73.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_5343_73.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_5343_73.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_5343_73.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_5343_73.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_5036_74.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_5036_74.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_5036_74.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_5036_74.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_5036_74.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_5036_74.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4868(i64 %start_2_2_4_168_4972, %Pos %acc_3_3_5_169_5036, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4972, 1
  br i1 %z.i6, label %label_85, label %label_81

label_81:                                         ; preds = %entry, %label_81
  %acc_3_3_5_169_5036.tr8 = phi %Pos [ %make_5491, %label_81 ], [ %acc_3_3_5_169_5036, %entry ]
  %start_2_2_4_168_4972.tr7 = phi i64 [ %z.i5, %label_81 ], [ %start_2_2_4_168_4972, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4972.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4972.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_75, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5488.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_5488.elt, ptr %environment.i, align 8, !noalias !0
  %environment_72.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5488.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_5488.elt2, ptr %environment_72.repack1, align 8, !noalias !0
  %acc_3_3_5_169_5036_pointer_79 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_5036.elt = extractvalue %Pos %acc_3_3_5_169_5036.tr8, 0
  store i64 %acc_3_3_5_169_5036.elt, ptr %acc_3_3_5_169_5036_pointer_79, align 8, !noalias !0
  %acc_3_3_5_169_5036_pointer_79.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_5036.elt4 = extractvalue %Pos %acc_3_3_5_169_5036.tr8, 1
  store ptr %acc_3_3_5_169_5036.elt4, ptr %acc_3_3_5_169_5036_pointer_79.repack3, align 8, !noalias !0
  %make_5491 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4972.tr7, 2
  br i1 %z.i, label %label_85, label %label_81

label_85:                                         ; preds = %label_81, %entry
  %acc_3_3_5_169_5036.tr.lcssa = phi %Pos [ %acc_3_3_5_169_5036, %entry ], [ %make_5491, %label_81 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_82 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_82(%Pos %acc_3_3_5_169_5036.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_96(%Pos %v_r_3191_32_59_223_4937, ptr %stack) {
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
  %acc_8_35_199_4953 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %v_r_3001_30_194_5122_pointer_99 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_3001_30_194_5122.unpack = load i64, ptr %v_r_3001_30_194_5122_pointer_99, align 8, !noalias !0
  %v_r_3001_30_194_5122.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_r_3001_30_194_5122.unpack2 = load ptr, ptr %v_r_3001_30_194_5122.elt1, align 8, !noalias !0
  %p_8_9_4817_pointer_100 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %p_8_9_4817 = load ptr, ptr %p_8_9_4817_pointer_100, align 8, !noalias !0
  %index_7_34_198_5027_pointer_101 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %index_7_34_198_5027 = load i64, ptr %index_7_34_198_5027_pointer_101, align 4, !noalias !0
  %tmp_5350_pointer_102 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5350 = load i64, ptr %tmp_5350_pointer_102, align 4, !noalias !0
  %tag_103 = extractvalue %Pos %v_r_3191_32_59_223_4937, 0
  %fields_104 = extractvalue %Pos %v_r_3191_32_59_223_4937, 1
  switch i64 %tag_103, label %common.ret [
    i64 1, label %label_128
    i64 0, label %label_135
  ]

common.ret:                                       ; preds = %entry
  ret void

label_116:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_3001_30_194_5122.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_116
  %referenceCount.i.i37 = load i64, ptr %v_r_3001_30_194_5122.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_3001_30_194_5122.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_3001_30_194_5122.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_3001_30_194_5122.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_3001_30_194_5122.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_116, %decr.i.i39, %free.i.i41
  %pair_111 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4817)
  %k_13_14_4_5198 = extractvalue <{ ptr, ptr }> %pair_111, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_5198, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_5198, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_5198, i64 40
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
  %stack_112 = extractvalue <{ ptr, ptr }> %pair_111, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_112, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_112, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_113 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_113(%Pos { i64 10, ptr null }, ptr %stack_112)
  ret void

label_125:                                        ; preds = %label_127
  %isNull.i.i24 = icmp eq ptr %v_r_3001_30_194_5122.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_125
  %referenceCount.i.i26 = load i64, ptr %v_r_3001_30_194_5122.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_3001_30_194_5122.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_3001_30_194_5122.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_3001_30_194_5122.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_3001_30_194_5122.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_125, %decr.i.i28, %free.i.i30
  %pair_120 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4817)
  %k_13_14_4_5197 = extractvalue <{ ptr, ptr }> %pair_120, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_5197, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_5197, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5197, i64 40
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
  %stack_121 = extractvalue <{ ptr, ptr }> %pair_120, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_121, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_121, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_122 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_122(%Pos { i64 10, ptr null }, ptr %stack_121)
  ret void

label_126:                                        ; preds = %label_127
  %0 = insertvalue %Pos poison, i64 %v_r_3001_30_194_5122.unpack, 0
  %v_r_3001_30_194_51223 = insertvalue %Pos %0, ptr %v_r_3001_30_194_5122.unpack2, 1
  %z.i = add i64 %index_7_34_198_5027, 1
  %z.i108 = mul i64 %acc_8_35_199_4953, 10
  %z.i109 = sub i64 %z.i108, %tmp_5350
  %z.i110 = add i64 %z.i109, %v_coe_4009_46_73_237_5107.unpack
  musttail call tailcc void @go_6_33_197_5112(i64 %z.i, i64 %z.i110, %Pos %v_r_3001_30_194_51223, ptr %p_8_9_4817, i64 %tmp_5350, ptr nonnull %stack)
  ret void

label_127:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_4009_46_73_237_5107.unpack, 58
  br i1 %z.i111, label %label_126, label %label_125

label_128:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_104, i64 16
  %v_coe_4009_46_73_237_5107.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_4009_46_73_237_5107.elt4 = getelementptr i8, ptr %fields_104, i64 24
  %v_coe_4009_46_73_237_5107.unpack5 = load ptr, ptr %v_coe_4009_46_73_237_5107.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_4009_46_73_237_5107.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_128
  %referenceCount.i.i = load i64, ptr %v_coe_4009_46_73_237_5107.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_4009_46_73_237_5107.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_128
  %referenceCount.i11 = load i64, ptr %fields_104, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_104, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_104, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_104)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_4009_46_73_237_5107.unpack, 47
  br i1 %z.i112, label %label_127, label %label_116

label_135:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_104, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_135
  %referenceCount.i = load i64, ptr %fields_104, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_104, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_104, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_104, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_104)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_135, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_3001_30_194_5122.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_3001_30_194_5122.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_3001_30_194_5122.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3001_30_194_5122.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3001_30_194_5122.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3001_30_194_5122.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_132 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_132(i64 %acc_8_35_199_4953, ptr nonnull %stack)
  ret void
}

define void @sharer_141(ptr %stackPointer) {
entry:
  %v_r_3001_30_194_5122_137.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %v_r_3001_30_194_5122_137.unpack2 = load ptr, ptr %v_r_3001_30_194_5122_137.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3001_30_194_5122_137.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3001_30_194_5122_137.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3001_30_194_5122_137.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_153(ptr %stackPointer) {
entry:
  %v_r_3001_30_194_5122_149.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %v_r_3001_30_194_5122_149.unpack2 = load ptr, ptr %v_r_3001_30_194_5122_149.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3001_30_194_5122_149.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3001_30_194_5122_149.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3001_30_194_5122_149.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3001_30_194_5122_149.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3001_30_194_5122_149.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3001_30_194_5122_149.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_170(%Pos %returned_5516, ptr nocapture %stack) {
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
  %returnAddress_172 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_172(%Pos %returned_5516, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_5114_clause_179(ptr %closure, %Pos %exc_8_20_47_211_5046, %Pos %msg_9_21_48_212_5033, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_5094 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_182 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_5094)
  %k_11_23_50_214_5140 = extractvalue <{ ptr, ptr }> %pair_182, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_5140, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_5140, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_5140, i64 40
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
  %stack_183 = extractvalue <{ ptr, ptr }> %pair_182, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_75, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_5046.elt = extractvalue %Pos %exc_8_20_47_211_5046, 0
  store i64 %exc_8_20_47_211_5046.elt, ptr %environment.i, align 8, !noalias !0
  %environment_185.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_5046.elt2 = extractvalue %Pos %exc_8_20_47_211_5046, 1
  store ptr %exc_8_20_47_211_5046.elt2, ptr %environment_185.repack1, align 8, !noalias !0
  %msg_9_21_48_212_5033_pointer_189 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_5033.elt = extractvalue %Pos %msg_9_21_48_212_5033, 0
  store i64 %msg_9_21_48_212_5033.elt, ptr %msg_9_21_48_212_5033_pointer_189, align 8, !noalias !0
  %msg_9_21_48_212_5033_pointer_189.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_5033.elt4 = extractvalue %Pos %msg_9_21_48_212_5033, 1
  store ptr %msg_9_21_48_212_5033.elt4, ptr %msg_9_21_48_212_5033_pointer_189.repack3, align 8, !noalias !0
  %make_5517 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_183, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_183, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_191 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_191(%Pos %make_5517, ptr %stack_183)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_198(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_206(ptr nocapture readonly %environment) {
entry:
  %tmp_5352_205.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5352_205.unpack2 = load ptr, ptr %tmp_5352_205.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5352_205.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5352_205.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5352_205.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5352_205.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5352_205.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5352_205.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_202(i64 %v_coe_4008_6_28_55_219_4988, ptr %stack) {
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
  store ptr @eraser_206, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_4008_6_28_55_219_4988, ptr %environment.i, align 8, !noalias !0
  %environment_204.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_204.repack1, align 8, !noalias !0
  %make_5519 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_210 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_210(%Pos %make_5519, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_5112(i64 %index_7_34_198_5027, i64 %acc_8_35_199_4953, %Pos %v_r_3001_30_194_5122, ptr %p_8_9_4817, i64 %tmp_5350, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_3001_30_194_5122, 1
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
  store i64 %acc_8_35_199_4953, ptr %common.ret.op.i, align 4, !noalias !0
  %v_r_3001_30_194_5122_pointer_162 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_r_3001_30_194_5122.elt = extractvalue %Pos %v_r_3001_30_194_5122, 0
  store i64 %v_r_3001_30_194_5122.elt, ptr %v_r_3001_30_194_5122_pointer_162, align 8, !noalias !0
  %v_r_3001_30_194_5122_pointer_162.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i3, ptr %v_r_3001_30_194_5122_pointer_162.repack1, align 8, !noalias !0
  %p_8_9_4817_pointer_163 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %p_8_9_4817, ptr %p_8_9_4817_pointer_163, align 8, !noalias !0
  %index_7_34_198_5027_pointer_164 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %index_7_34_198_5027, ptr %index_7_34_198_5027_pointer_164, align 4, !noalias !0
  %tmp_5350_pointer_165 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_5350, ptr %tmp_5350_pointer_165, align 4, !noalias !0
  %returnAddress_pointer_166 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_167 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_168 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_96, ptr %returnAddress_pointer_166, align 8, !noalias !0
  store ptr @sharer_141, ptr %sharer_pointer_167, align 8, !noalias !0
  store ptr @eraser_153, ptr %eraser_pointer_168, align 8, !noalias !0
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
  %sharer_pointer_177 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_178 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_170, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_60, ptr %sharer_pointer_177, align 8, !noalias !0
  store ptr @eraser_62, ptr %eraser_pointer_178, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_198, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_5114 = insertvalue %Neg { ptr @vtable_194, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_215 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_216 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_202, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_215, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_216, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_3001_30_194_5122, i64 %index_7_34_198_5027, %Neg %Exception_7_19_46_210_5114, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_5104_clause_217(ptr %closure, %Pos %exception_10_107_134_298_5520, %Pos %msg_11_108_135_299_5521, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4817 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_5520, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_5521, 1
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
  %pair_220 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4817)
  %k_13_14_4_5303 = extractvalue <{ ptr, ptr }> %pair_220, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_5303, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_5303, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5303, i64 40
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
  %stack_221 = extractvalue <{ ptr, ptr }> %pair_220, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_221, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_221, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_222 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_222(%Pos { i64 10, ptr null }, ptr %stack_221)
  ret void
}

define tailcc void @returnAddress_236(i64 %v_coe_4013_22_131_158_322_4857, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_4013_22_131_158_322_4857, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_237 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_237(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_248(i64 %v_r_3205_1_9_20_129_156_320_4893, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_3205_1_9_20_129_156_320_4893
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_249 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_249(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_231(i64 %v_r_3204_3_14_123_150_314_5029, ptr %stack) {
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
  %v_r_3001_30_194_5122.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_3001_30_194_5122.unpack, 0
  %v_r_3001_30_194_5122.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_3001_30_194_5122.unpack2 = load ptr, ptr %v_r_3001_30_194_5122.elt1, align 8, !noalias !0
  %v_r_3001_30_194_51223 = insertvalue %Pos %0, ptr %v_r_3001_30_194_5122.unpack2, 1
  %p_8_9_4817_pointer_234 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %p_8_9_4817 = load ptr, ptr %p_8_9_4817_pointer_234, align 8, !noalias !0
  %tmp_5350_pointer_235 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5350 = load i64, ptr %tmp_5350_pointer_235, align 4, !noalias !0
  %z.i = icmp eq i64 %v_r_3204_3_14_123_150_314_5029, 45
  %isInside.not.i = icmp ugt ptr %tmp_5350_pointer_235, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %tmp_5350_pointer_235, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_242 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_243 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_236, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_242, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_243, align 8, !noalias !0
  br i1 %z.i, label %label_256, label %label_247

label_247:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_5112(i64 0, i64 0, %Pos %v_r_3001_30_194_51223, ptr %p_8_9_4817, i64 %tmp_5350, ptr nonnull %stack)
  ret void

label_256:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_256
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

stackAllocate.exit35:                             ; preds = %label_256, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_256 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_256 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_254 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_255 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_248, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_254, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_255, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_5112(i64 1, i64 0, %Pos %v_r_3001_30_194_51223, ptr %p_8_9_4817, i64 %tmp_5350, ptr nonnull %stack)
  ret void
}

define void @sharer_260(ptr %stackPointer) {
entry:
  %v_r_3001_30_194_5122_257.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_3001_30_194_5122_257.unpack2 = load ptr, ptr %v_r_3001_30_194_5122_257.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3001_30_194_5122_257.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3001_30_194_5122_257.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3001_30_194_5122_257.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_268(ptr %stackPointer) {
entry:
  %v_r_3001_30_194_5122_265.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_3001_30_194_5122_265.unpack2 = load ptr, ptr %v_r_3001_30_194_5122_265.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3001_30_194_5122_265.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3001_30_194_5122_265.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3001_30_194_5122_265.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3001_30_194_5122_265.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3001_30_194_5122_265.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3001_30_194_5122_265.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_93(%Pos %v_r_3001_30_194_5122, ptr %stack) {
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
  %p_8_9_4817 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_198, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4817, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_3001_30_194_5122, 1
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
  %v_r_3001_30_194_5122.elt = extractvalue %Pos %v_r_3001_30_194_5122, 0
  store i64 %v_r_3001_30_194_5122.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_273.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i3, ptr %stackPointer_273.repack1, align 8, !noalias !0
  %p_8_9_4817_pointer_275 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %p_8_9_4817, ptr %p_8_9_4817_pointer_275, align 8, !noalias !0
  %tmp_5350_pointer_276 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 48, ptr %tmp_5350_pointer_276, align 4, !noalias !0
  %returnAddress_pointer_277 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_278 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_279 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_231, ptr %returnAddress_pointer_277, align 8, !noalias !0
  store ptr @sharer_260, ptr %sharer_pointer_278, align 8, !noalias !0
  store ptr @eraser_268, ptr %eraser_pointer_279, align 8, !noalias !0
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
  store i64 %v_r_3001_30_194_5122.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_1144.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_1144.repack1.i, align 8, !noalias !0
  %index_2107_pointer_1146.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_1146.i, align 4, !noalias !0
  %Exception_2362_pointer_1147.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_225, ptr %Exception_2362_pointer_1147.i, align 8, !noalias !0
  %Exception_2362_pointer_1147.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_1147.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_1148.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_1149.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_1150.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_1110, ptr %returnAddress_pointer_1148.i, align 8, !noalias !0
  store ptr @sharer_1131, ptr %sharer_pointer_1149.i, align 8, !noalias !0
  store ptr @eraser_1139, ptr %eraser_pointer_1150.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_3001_30_194_5122)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1154.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1154.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_281(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_285(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_90(%Pos %v_r_3000_24_188_4943, ptr %stack) {
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
  %p_8_9_4817 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4817, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_291 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_292 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_93, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_291, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_292, align 8, !noalias !0
  %tag_293 = extractvalue %Pos %v_r_3000_24_188_4943, 0
  switch i64 %tag_293, label %label_295 [
    i64 0, label %label_299
    i64 1, label %label_305
  ]

label_295:                                        ; preds = %stackAllocate.exit
  ret void

label_299:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_5536 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5536.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_296 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_296(%Pos %utf8StringLiteral_5536, ptr nonnull %stack)
  ret void

label_305:                                        ; preds = %stackAllocate.exit
  %fields_294 = extractvalue %Pos %v_r_3000_24_188_4943, 1
  %environment.i = getelementptr i8, ptr %fields_294, i64 16
  %v_y_3835_8_29_193_4991.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3835_8_29_193_4991.elt1 = getelementptr i8, ptr %fields_294, i64 24
  %v_y_3835_8_29_193_4991.unpack2 = load ptr, ptr %v_y_3835_8_29_193_4991.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3835_8_29_193_4991.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_305
  %referenceCount.i.i = load i64, ptr %v_y_3835_8_29_193_4991.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3835_8_29_193_4991.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_305
  %referenceCount.i = load i64, ptr %fields_294, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_294, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_294, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_294)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3835_8_29_193_4991.unpack, 0
  %v_y_3835_8_29_193_49913 = insertvalue %Pos %0, ptr %v_y_3835_8_29_193_4991.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_302 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_302(%Pos %v_y_3835_8_29_193_49913, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_87(%Pos %v_r_2999_13_177_5042, ptr %stack) {
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
  %p_8_9_4817 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4817, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_311 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_312 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_90, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_311, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_312, align 8, !noalias !0
  %tag_313 = extractvalue %Pos %v_r_2999_13_177_5042, 0
  switch i64 %tag_313, label %label_315 [
    i64 0, label %label_320
    i64 1, label %label_332
  ]

label_315:                                        ; preds = %stackAllocate.exit
  ret void

label_320:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4817, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_93, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_311, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_312, align 8, !noalias !0
  %utf8StringLiteral_5536.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5536.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_296.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_296.i(%Pos %utf8StringLiteral_5536.i, ptr nonnull %stack)
  ret void

label_332:                                        ; preds = %stackAllocate.exit
  %fields_314 = extractvalue %Pos %v_r_2999_13_177_5042, 1
  %environment.i6 = getelementptr i8, ptr %fields_314, i64 16
  %v_y_3344_10_21_185_4920.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_3344_10_21_185_4920.elt1 = getelementptr i8, ptr %fields_314, i64 24
  %v_y_3344_10_21_185_4920.unpack2 = load ptr, ptr %v_y_3344_10_21_185_4920.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3344_10_21_185_4920.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_332
  %referenceCount.i.i = load i64, ptr %v_y_3344_10_21_185_4920.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3344_10_21_185_4920.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_332
  %referenceCount.i = load i64, ptr %fields_314, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_314, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_314, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_314)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_206, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_3344_10_21_185_4920.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_325.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_3344_10_21_185_4920.unpack2, ptr %environment_325.repack4, align 8, !noalias !0
  %make_5538 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_329 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_329(%Pos %make_5538, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2857(ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_52 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_53 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_52, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_53, align 8, !noalias !0
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
  %sharer_pointer_66 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_67 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_55, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_60, ptr %sharer_pointer_66, align 8, !noalias !0
  store ptr @eraser_62, ptr %eraser_pointer_67, align 8, !noalias !0
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
  %returnAddress_pointer_337 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_338 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_339 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_87, ptr %returnAddress_pointer_337, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_338, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_339, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_85.i, label %label_81.i

label_81.i:                                       ; preds = %stackAllocate.exit46, %label_81.i
  %acc_3_3_5_169_5036.tr8.i = phi %Pos [ %make_5491.i, %label_81.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4972.tr7.i = phi i64 [ %z.i5.i, %label_81.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4972.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4972.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_75, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_5488.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_5488.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_72.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_5488.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_5488.elt2.i, ptr %environment_72.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_5036_pointer_79.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_5036.elt.i = extractvalue %Pos %acc_3_3_5_169_5036.tr8.i, 0
  store i64 %acc_3_3_5_169_5036.elt.i, ptr %acc_3_3_5_169_5036_pointer_79.i, align 8, !noalias !0
  %acc_3_3_5_169_5036_pointer_79.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_5036.elt4.i = extractvalue %Pos %acc_3_3_5_169_5036.tr8.i, 1
  store ptr %acc_3_3_5_169_5036.elt4.i, ptr %acc_3_3_5_169_5036_pointer_79.repack3.i, align 8, !noalias !0
  %make_5491.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4972.tr7.i, 2
  br i1 %z.i.i, label %label_85.i.loopexit, label %label_81.i

label_85.i.loopexit:                              ; preds = %label_81.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_85.i

label_85.i:                                       ; preds = %label_85.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_85.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_85.i.loopexit ]
  %acc_3_3_5_169_5036.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_5491.i, %label_85.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_82.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_82.i(%Pos %acc_3_3_5_169_5036.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_340(i64 %returnValue_341, ptr %stack) {
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
  %returnAddress_344 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_344(i64 %returnValue_341, ptr %stack)
  ret void
}

define void @sharer_348(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_352(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_5_9_4412(i64 %i_6_10_4410, %Pos %tmp_5379, %Pos %tmp_5313, ptr %stack) local_unnamed_addr {
entry:
  %z.i38 = icmp slt i64 %i_6_10_4410, 3
  %object.i1 = extractvalue %Pos %tmp_5313, 1
  br i1 %z.i38, label %label_369.lr.ph, label %label_368

label_369.lr.ph:                                  ; preds = %entry
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  %object.i = extractvalue %Pos %tmp_5379, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br label %label_369

label_368:                                        ; preds = %erasePositive.exit, %entry
  %isNull.i.i25 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i25, label %erasePositive.exit35, label %next.i.i26

next.i.i26:                                       ; preds = %label_368
  %referenceCount.i.i27 = load i64, ptr %object.i1, align 4
  %cond.i.i28 = icmp eq i64 %referenceCount.i.i27, 0
  br i1 %cond.i.i28, label %free.i.i31, label %decr.i.i29

decr.i.i29:                                       ; preds = %next.i.i26
  %referenceCount.1.i.i30 = add i64 %referenceCount.i.i27, -1
  store i64 %referenceCount.1.i.i30, ptr %object.i1, align 4
  br label %erasePositive.exit35

free.i.i31:                                       ; preds = %next.i.i26
  %objectEraser.i.i32 = getelementptr i8, ptr %object.i1, i64 8
  %eraser.i.i33 = load ptr, ptr %objectEraser.i.i32, align 8
  %environment.i.i.i34 = getelementptr i8, ptr %object.i1, i64 16
  tail call void %eraser.i.i33(ptr %environment.i.i.i34)
  tail call void @free(ptr nonnull %object.i1)
  br label %erasePositive.exit35

erasePositive.exit35:                             ; preds = %label_368, %decr.i.i29, %free.i.i31
  %object.i12 = extractvalue %Pos %tmp_5379, 1
  %isNull.i.i13 = icmp eq ptr %object.i12, null
  br i1 %isNull.i.i13, label %erasePositive.exit23, label %next.i.i14

next.i.i14:                                       ; preds = %erasePositive.exit35
  %referenceCount.i.i15 = load i64, ptr %object.i12, align 4
  %cond.i.i16 = icmp eq i64 %referenceCount.i.i15, 0
  br i1 %cond.i.i16, label %free.i.i19, label %decr.i.i17

decr.i.i17:                                       ; preds = %next.i.i14
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i15, -1
  store i64 %referenceCount.1.i.i18, ptr %object.i12, align 4
  br label %erasePositive.exit23

free.i.i19:                                       ; preds = %next.i.i14
  %objectEraser.i.i20 = getelementptr i8, ptr %object.i12, i64 8
  %eraser.i.i21 = load ptr, ptr %objectEraser.i.i20, align 8
  %environment.i.i.i22 = getelementptr i8, ptr %object.i12, i64 16
  tail call void %eraser.i.i21(ptr %environment.i.i.i22)
  tail call void @free(ptr nonnull %object.i12)
  br label %erasePositive.exit23

erasePositive.exit23:                             ; preds = %erasePositive.exit35, %decr.i.i17, %free.i.i19
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_365 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_365(%Pos zeroinitializer, ptr %stack)
  ret void

label_369:                                        ; preds = %label_369.lr.ph, %erasePositive.exit
  %i_6_10_4410.tr39 = phi i64 [ %i_6_10_4410, %label_369.lr.ph ], [ %z.i37, %erasePositive.exit ]
  br i1 %isNull.i.i2, label %sharePositive.exit6, label %next.i.i3

next.i.i3:                                        ; preds = %label_369
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, 1
  store i64 %referenceCount.1.i.i5, ptr %object.i1, align 4
  br label %sharePositive.exit6

sharePositive.exit6:                              ; preds = %label_369, %next.i.i3
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit6
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit6, %next.i.i
  %z.i36 = tail call %Pos @c_array_set(%Pos %tmp_5313, i64 %i_6_10_4410.tr39, %Pos %tmp_5379)
  %object.i7 = extractvalue %Pos %z.i36, 1
  %isNull.i.i8 = icmp eq ptr %object.i7, null
  br i1 %isNull.i.i8, label %erasePositive.exit, label %next.i.i9

next.i.i9:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i10 = load i64, ptr %object.i7, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i10, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i9
  %referenceCount.1.i.i11 = add i64 %referenceCount.i.i10, -1
  store i64 %referenceCount.1.i.i11, ptr %object.i7, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i9
  %objectEraser.i.i = getelementptr i8, ptr %object.i7, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i7, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i7)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %z.i37 = add nsw i64 %i_6_10_4410.tr39, 1
  %z.i = icmp slt i64 %i_6_10_4410.tr39, 2
  br i1 %z.i, label %label_369, label %label_368
}

define tailcc void @returnAddress_375(i64 %returnValue_376, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5313.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5313.unpack2 = load ptr, ptr %tmp_5313.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5313.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5313.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5313.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5313.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5313.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5313.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_379 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_379(i64 %returnValue_376, ptr nonnull %stack)
  ret void
}

define void @sharer_383(ptr %stackPointer) {
entry:
  %tmp_5313_382.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_5313_382.unpack2 = load ptr, ptr %tmp_5313_382.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5313_382.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5313_382.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5313_382.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_387(ptr %stackPointer) {
entry:
  %tmp_5313_386.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_5313_386.unpack2 = load ptr, ptr %tmp_5313_386.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5313_386.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5313_386.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5313_386.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5313_386.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5313_386.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5313_386.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_406(%Pos %v_r_2964_4136, ptr %stack) {
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
  %newTopDiskOnPile_2862 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5317_pointer_409 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_5317.unpack = load i64, ptr %tmp_5317_pointer_409, align 8, !noalias !0
  %tmp_5317.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5317.unpack2 = load ptr, ptr %tmp_5317.elt1, align 8, !noalias !0
  %pileIdx_2863_pointer_410 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %pileIdx_2863 = load i64, ptr %pileIdx_2863_pointer_410, align 4, !noalias !0
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_75, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %newTopDiskOnPile_2862, ptr %environment.i, align 8, !noalias !0
  %environment_412.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_412.repack4, align 8, !noalias !0
  %tmp_5317_pointer_416 = getelementptr i8, ptr %object.i, i64 32
  store i64 %tmp_5317.unpack, ptr %tmp_5317_pointer_416, align 8, !noalias !0
  %tmp_5317_pointer_416.repack6 = getelementptr i8, ptr %object.i, i64 40
  store ptr %tmp_5317.unpack2, ptr %tmp_5317_pointer_416.repack6, align 8, !noalias !0
  %make_5410 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = tail call %Pos @c_array_set(%Pos %v_r_2964_4136, i64 %pileIdx_2863, %Pos %make_5410)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_418 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_418(%Pos %z.i, ptr %stack)
  ret void
}

define void @sharer_424(ptr %stackPointer) {
entry:
  %tmp_5317_422.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_5317_422.unpack2 = load ptr, ptr %tmp_5317_422.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5317_422.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5317_422.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5317_422.unpack2, align 4
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
  %tmp_5317_430.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_5317_430.unpack2 = load ptr, ptr %tmp_5317_430.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5317_430.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5317_430.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5317_430.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5317_430.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5317_430.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5317_430.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_400(%Pos %v_r_2963_5407, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %newTopDiskOnPile_2862 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5317_pointer_403 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_5317.unpack = load i64, ptr %tmp_5317_pointer_403, align 8, !noalias !0
  %tmp_5317.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_5317.unpack2 = load ptr, ptr %tmp_5317.elt1, align 8, !noalias !0
  %pileIdx_2863_pointer_404 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %pileIdx_2863 = load i64, ptr %pileIdx_2863_pointer_404, align 4, !noalias !0
  %towers_2861_pointer_405 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_405, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %v_r_2963_5407, 1
  %isNull.i.i15 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i15, label %erasePositive.exit, label %next.i.i16

next.i.i16:                                       ; preds = %entry
  %referenceCount.i.i17 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i17, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i16
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i17, -1
  store i64 %referenceCount.1.i.i18, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i16
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i26 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i26
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
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
  %newStackPointer.i27 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i27, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i3339 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i26, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i27, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %newTopDiskOnPile_2862, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5317_pointer_439 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5317.unpack, ptr %tmp_5317_pointer_439, align 8, !noalias !0
  %tmp_5317_pointer_439.repack7 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %tmp_5317.unpack2, ptr %tmp_5317_pointer_439.repack7, align 8, !noalias !0
  %pileIdx_2863_pointer_440 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %pileIdx_2863, ptr %pileIdx_2863_pointer_440, align 4, !noalias !0
  %returnAddress_pointer_441 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_442 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_443 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_406, ptr %returnAddress_pointer_441, align 8, !noalias !0
  store ptr @sharer_424, ptr %sharer_pointer_442, align 8, !noalias !0
  store ptr @eraser_432, ptr %eraser_pointer_443, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %towers_2861.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i28 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i29 = load ptr, ptr %base_pointer.i28, align 8
  %varPointer.i = getelementptr i8, ptr %base.i29, i64 %towers_2861.unpack5
  %towers_2861_old_445.elt9 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %towers_2861_old_445.unpack10 = load ptr, ptr %towers_2861_old_445.elt9, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %towers_2861_old_445.unpack10, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %towers_2861_old_445.unpack10, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %towers_2861_old_445.unpack10, align 4
  %get_5412.unpack13.pre = load ptr, ptr %towers_2861_old_445.elt9, align 8, !noalias !0
  %stackPointer.i31.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i33.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i33 = phi ptr [ %limit.i3339, %stackAllocate.exit ], [ %limit.i33.pre, %next.i.i ]
  %stackPointer.i31 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i31.pre, %next.i.i ]
  %get_5412.unpack13 = phi ptr [ null, %stackAllocate.exit ], [ %get_5412.unpack13.pre, %next.i.i ]
  %get_5412.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5412.unpack, 0
  %get_541214 = insertvalue %Pos %0, ptr %get_5412.unpack13, 1
  %isInside.i34 = icmp ule ptr %stackPointer.i31, %limit.i33
  tail call void @llvm.assume(i1 %isInside.i34)
  %newStackPointer.i35 = getelementptr i8, ptr %stackPointer.i31, i64 -24
  store ptr %newStackPointer.i35, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_446 = load ptr, ptr %newStackPointer.i35, align 8, !noalias !0
  musttail call tailcc void %returnAddress_446(%Pos %get_541214, ptr nonnull %stack)
  ret void
}

define void @sharer_453(ptr %stackPointer) {
entry:
  %tmp_5317_450.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_5317_450.unpack2 = load ptr, ptr %tmp_5317_450.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5317_450.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5317_450.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5317_450.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_463(ptr %stackPointer) {
entry:
  %tmp_5317_460.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_5317_460.unpack2 = load ptr, ptr %tmp_5317_460.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5317_460.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5317_460.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5317_460.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5317_460.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5317_460.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5317_460.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_395(%Pos %v_r_2952_4126, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %pileIdx_2863 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %newTopDiskOnPile_2862_pointer_398 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %newTopDiskOnPile_2862 = load i64, ptr %newTopDiskOnPile_2862_pointer_398, align 4, !noalias !0
  %towers_2861_pointer_399 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_399, align 8, !noalias !0
  %towers_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %towers_2861.unpack2 = load i64, ptr %towers_2861.elt1, align 8, !noalias !0
  %z.i = tail call %Pos @c_array_get(%Pos %v_r_2952_4126, i64 %pileIdx_2863)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i11 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i11, label %sharePositive.exit15, label %next.i.i12

next.i.i12:                                       ; preds = %entry
  %referenceCount.i.i13 = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i14 = add i64 %referenceCount.i.i13, 1
  store i64 %referenceCount.1.i.i14, ptr %object.i, align 4
  br label %sharePositive.exit15

sharePositive.exit15:                             ; preds = %entry, %next.i.i12
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i23 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i23
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit15
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

stackAllocate.exit:                               ; preds = %sharePositive.exit15, %realloc.i
  %limit.i41 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i23, %sharePositive.exit15 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit15 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit15 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %newTopDiskOnPile_2862, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5317_pointer_471 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %pureApp_5408.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_5408.elt, ptr %tmp_5317_pointer_471, align 8, !noalias !0
  %tmp_5317_pointer_471.repack4 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i, ptr %tmp_5317_pointer_471.repack4, align 8, !noalias !0
  %pileIdx_2863_pointer_472 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %pileIdx_2863, ptr %pileIdx_2863_pointer_472, align 4, !noalias !0
  %towers_2861_pointer_473 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_473, align 8, !noalias !0
  %towers_2861_pointer_473.repack6 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %towers_2861.unpack2, ptr %towers_2861_pointer_473.repack6, align 8, !noalias !0
  %returnAddress_pointer_474 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_475 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_476 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_400, ptr %returnAddress_pointer_474, align 8, !noalias !0
  store ptr @sharer_453, ptr %sharer_pointer_475, align 8, !noalias !0
  store ptr @eraser_463, ptr %eraser_pointer_476, align 8, !noalias !0
  switch i64 %pureApp_5408.elt, label %common.ret [
    i64 1, label %label_495
    i64 0, label %label_500
  ]

common.ret:                                       ; preds = %stackAllocate.exit
  ret void

label_490:                                        ; preds = %eraseObject.exit
  %stackPointer.i26 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i28 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i29 = icmp ule ptr %stackPointer.i26, %limit.i28
  tail call void @llvm.assume(i1 %isInside.i29)
  %newStackPointer.i30 = getelementptr i8, ptr %stackPointer.i26, i64 -24
  store ptr %newStackPointer.i30, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_487 = load ptr, ptr %newStackPointer.i30, align 8, !noalias !0
  musttail call tailcc void %returnAddress_487(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_494:                                        ; preds = %eraseObject.exit
  %utf8StringLiteral_5417 = tail call %Pos @c_bytearray_construct(i64 40, ptr nonnull @utf8StringLiteral_5417.lit)
  tail call void @c_io_println_String(%Pos %utf8StringLiteral_5417)
  tail call void @exit(i32 1)
  %stackPointer.i32 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i34 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i35 = icmp ule ptr %stackPointer.i32, %limit.i34
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i36 = getelementptr i8, ptr %stackPointer.i32, i64 -24
  store ptr %newStackPointer.i36, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_491 = load ptr, ptr %newStackPointer.i36, align 8, !noalias !0
  musttail call tailcc void %returnAddress_491(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_495:                                        ; preds = %stackAllocate.exit
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %v_coe_4034_4132.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_coe_4034_4132.elt8 = getelementptr i8, ptr %object.i, i64 24
  %v_coe_4034_4132.unpack9 = load ptr, ptr %v_coe_4034_4132.elt8, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_4034_4132.unpack9, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_495
  %referenceCount.i.i = load i64, ptr %v_coe_4034_4132.unpack9, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_4034_4132.unpack9, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_495
  %referenceCount.i = load i64, ptr %object.i, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %object.i, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %z.i37.not = icmp slt i64 %newTopDiskOnPile_2862, %v_coe_4034_4132.unpack
  br i1 %z.i37.not, label %label_490, label %label_494

label_500:                                        ; preds = %stackAllocate.exit
  %isInside.i42 = icmp ule ptr %nextStackPointer.sink.i, %limit.i41
  tail call void @llvm.assume(i1 %isInside.i42)
  %newStackPointer.i43 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i43, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_497 = load ptr, ptr %newStackPointer.i43, align 8, !noalias !0
  musttail call tailcc void %returnAddress_497(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_504(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_512(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @pushDisk_2864(i64 %newTopDiskOnPile_2862, i64 %pileIdx_2863, %Reference %towers_2861, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
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
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i1318 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %pileIdx_2863, ptr %common.ret.op.i, align 4, !noalias !0
  %newTopDiskOnPile_2862_pointer_519 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %newTopDiskOnPile_2862, ptr %newTopDiskOnPile_2862_pointer_519, align 4, !noalias !0
  %towers_2861_pointer_520 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %towers_2861.elt = extractvalue %Reference %towers_2861, 0
  store ptr %towers_2861.elt, ptr %towers_2861_pointer_520, align 8, !noalias !0
  %towers_2861_pointer_520.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %towers_2861.elt2 = extractvalue %Reference %towers_2861, 1
  store i64 %towers_2861.elt2, ptr %towers_2861_pointer_520.repack1, align 8, !noalias !0
  %returnAddress_pointer_521 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_522 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_523 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_395, ptr %returnAddress_pointer_521, align 8, !noalias !0
  store ptr @sharer_504, ptr %sharer_pointer_522, align 8, !noalias !0
  store ptr @eraser_512, ptr %eraser_pointer_523, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %towers_2861.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i9 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i10 = load ptr, ptr %base_pointer.i9, align 8
  %varPointer.i = getelementptr i8, ptr %base.i10, i64 %towers_2861.elt2
  %towers_2861_old_525.elt3 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %towers_2861_old_525.unpack4 = load ptr, ptr %towers_2861_old_525.elt3, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %towers_2861_old_525.unpack4, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %towers_2861_old_525.unpack4, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %towers_2861_old_525.unpack4, align 4
  %get_5419.unpack7.pre = load ptr, ptr %towers_2861_old_525.elt3, align 8, !noalias !0
  %stackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i13.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i13 = phi ptr [ %limit.i1318, %stackAllocate.exit ], [ %limit.i13.pre, %next.i.i ]
  %stackPointer.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i.pre, %next.i.i ]
  %get_5419.unpack7 = phi ptr [ null, %stackAllocate.exit ], [ %get_5419.unpack7.pre, %next.i.i ]
  %get_5419.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5419.unpack, 0
  %get_54198 = insertvalue %Pos %0, ptr %get_5419.unpack7, 1
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i13
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_526 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_526(%Pos %get_54198, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_569(%Pos %__5420, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %towers_2861_pointer_572 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_572, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %disks_2875_pointer_573 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %disks_2875 = load i64, ptr %disks_2875_pointer_573, align 4, !noalias !0
  %tmp_5332_pointer_574 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5332 = load i64, ptr %tmp_5332_pointer_574, align 4, !noalias !0
  %ontoPile_2877_pointer_575 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_575, align 4, !noalias !0
  %object.i = extractvalue %Pos %__5420, 1
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
  %0 = insertvalue %Reference poison, ptr %towers_2861.unpack, 0
  %towers_28616 = insertvalue %Reference %0, i64 %towers_2861.unpack5, 1
  %1 = insertvalue %Reference poison, ptr %movesDone_2860.unpack, 0
  %movesDone_28603 = insertvalue %Reference %1, i64 %movesDone_2860.unpack2, 1
  %z.i = add i64 %disks_2875, -1
  musttail call tailcc void @moveDisks_2878(i64 %z.i, i64 %tmp_5332, i64 %ontoPile_2877, %Reference %movesDone_28603, %Reference %towers_28616, ptr nonnull %stack)
  ret void
}

define void @sharer_581(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_593(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_562(i64 %v_r_2980_14_5296, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  %ontoPile_2877_pointer_568 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_568, align 4, !noalias !0
  %tmp_5332_pointer_567 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5332 = load i64, ptr %tmp_5332_pointer_567, align 4, !noalias !0
  %disks_2875_pointer_566 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %disks_2875 = load i64, ptr %disks_2875_pointer_566, align 4, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %towers_2861_pointer_565 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_565, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = add i64 %v_r_2980_14_5296, 1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %movesDone_2860.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_600.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %movesDone_2860.unpack2, ptr %stackPointer_600.repack7, align 8, !noalias !0
  %towers_2861_pointer_602 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_602, align 8, !noalias !0
  %towers_2861_pointer_602.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_602.repack9, align 8, !noalias !0
  %disks_2875_pointer_603 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %disks_2875, ptr %disks_2875_pointer_603, align 4, !noalias !0
  %tmp_5332_pointer_604 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %tmp_5332, ptr %tmp_5332_pointer_604, align 4, !noalias !0
  %ontoPile_2877_pointer_605 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_605, align 4, !noalias !0
  %sharer_pointer_607 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_608 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_569, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_581, ptr %sharer_pointer_607, align 8, !noalias !0
  store ptr @eraser_593, ptr %eraser_pointer_608, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %movesDone_2860.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %movesDone_2860.unpack2
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_612 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_612(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_555(%Pos %__13_5302, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i15 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i15)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %towers_2861_pointer_558 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_558, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %disks_2875_pointer_559 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %disks_2875 = load i64, ptr %disks_2875_pointer_559, align 4, !noalias !0
  %tmp_5332_pointer_560 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5332 = load i64, ptr %tmp_5332_pointer_560, align 4, !noalias !0
  %ontoPile_2877_pointer_561 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_561, align 4, !noalias !0
  %object.i = extractvalue %Pos %__13_5302, 1
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
  %limit.i18 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 80
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i18
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
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
  %newStackPointer.i19 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i19, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i25 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i18, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i19, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %movesDone_2860.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_625.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %movesDone_2860.unpack2, ptr %stackPointer_625.repack7, align 8, !noalias !0
  %towers_2861_pointer_627 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_627, align 8, !noalias !0
  %towers_2861_pointer_627.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_627.repack9, align 8, !noalias !0
  %disks_2875_pointer_628 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %disks_2875, ptr %disks_2875_pointer_628, align 4, !noalias !0
  %tmp_5332_pointer_629 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_5332, ptr %tmp_5332_pointer_629, align 4, !noalias !0
  %ontoPile_2877_pointer_630 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_630, align 4, !noalias !0
  %returnAddress_pointer_631 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_632 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_633 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_562, ptr %returnAddress_pointer_631, align 8, !noalias !0
  store ptr @sharer_581, ptr %sharer_pointer_632, align 8, !noalias !0
  store ptr @eraser_593, ptr %eraser_pointer_633, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %movesDone_2860.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %movesDone_2860.unpack2
  %get_5435 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i26 = icmp ule ptr %nextStackPointer.sink.i, %limit.i25
  tail call void @llvm.assume(i1 %isInside.i26)
  %newStackPointer.i27 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i27, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_636 = load ptr, ptr %newStackPointer.i27, align 8, !noalias !0
  musttail call tailcc void %returnAddress_636(i64 %get_5435, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_548(i64 %v_r_2978_12_5299, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  %towers_2861_pointer_551 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_551, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %ontoPile_2877_pointer_554 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_554, align 4, !noalias !0
  %tmp_5332_pointer_553 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5332 = load i64, ptr %tmp_5332_pointer_553, align 4, !noalias !0
  %disks_2875_pointer_552 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %disks_2875 = load i64, ptr %disks_2875_pointer_552, align 4, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %movesDone_2860.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_649.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %movesDone_2860.unpack2, ptr %stackPointer_649.repack7, align 8, !noalias !0
  %towers_2861_pointer_651 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_651, align 8, !noalias !0
  %towers_2861_pointer_651.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_651.repack9, align 8, !noalias !0
  %disks_2875_pointer_652 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %disks_2875, ptr %disks_2875_pointer_652, align 4, !noalias !0
  %tmp_5332_pointer_653 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %tmp_5332, ptr %tmp_5332_pointer_653, align 4, !noalias !0
  %ontoPile_2877_pointer_654 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_654, align 4, !noalias !0
  %sharer_pointer_656 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_657 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_555, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_581, ptr %sharer_pointer_656, align 8, !noalias !0
  store ptr @eraser_593, ptr %eraser_pointer_657, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 80
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 56
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 56
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit
  %limit.i1318.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %oldStackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %ontoPile_2877, ptr %common.ret.op.i.i, align 4, !noalias !0
  %newTopDiskOnPile_2862_pointer_519.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %v_r_2978_12_5299, ptr %newTopDiskOnPile_2862_pointer_519.i, align 4, !noalias !0
  %towers_2861_pointer_520.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_520.i, align 8, !noalias !0
  %towers_2861_pointer_520.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_520.repack1.i, align 8, !noalias !0
  %returnAddress_pointer_521.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  %sharer_pointer_522.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %eraser_pointer_523.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr @returnAddress_395, ptr %returnAddress_pointer_521.i, align 8, !noalias !0
  store ptr @sharer_504, ptr %sharer_pointer_522.i, align 8, !noalias !0
  store ptr @eraser_512, ptr %eraser_pointer_523.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %towers_2861.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i9.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i10.i = load ptr, ptr %base_pointer.i9.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i10.i, i64 %towers_2861.unpack5
  %towers_2861_old_525.elt3.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %towers_2861_old_525.unpack4.i = load ptr, ptr %towers_2861_old_525.elt3.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %towers_2861_old_525.unpack4.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %towers_2861_old_525.unpack4.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %towers_2861_old_525.unpack4.i, align 4
  %get_5419.unpack7.pre.i = load ptr, ptr %towers_2861_old_525.elt3.i, align 8, !noalias !0
  %stackPointer.i.pre.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i13.pre.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i13.i = phi ptr [ %limit.i1318.i, %stackAllocate.exit.i ], [ %limit.i13.pre.i, %next.i.i.i ]
  %stackPointer.i.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i.pre.i, %next.i.i.i ]
  %get_5419.unpack7.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_5419.unpack7.pre.i, %next.i.i.i ]
  %get_5419.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5419.unpack.i, 0
  %get_54198.i = insertvalue %Pos %0, ptr %get_5419.unpack7.i, 1
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i13.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_526.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_526.i(%Pos %get_54198.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_687(%Pos %v_r_2970_3_3_25_10_5295, ptr %stack) {
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
  %fromPile_2876 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %v_coe_4038_17_8_5293_pointer_690 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_coe_4038_17_8_5293.unpack = load i64, ptr %v_coe_4038_17_8_5293_pointer_690, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_coe_4038_17_8_5293.unpack, 0
  %v_coe_4038_17_8_5293.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_coe_4038_17_8_5293.unpack2 = load ptr, ptr %v_coe_4038_17_8_5293.elt1, align 8, !noalias !0
  %v_coe_4038_17_8_52933 = insertvalue %Pos %0, ptr %v_coe_4038_17_8_5293.unpack2, 1
  %tmp_5337_pointer_691 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5337 = load i64, ptr %tmp_5337_pointer_691, align 4, !noalias !0
  %z.i = tail call %Pos @c_array_set(%Pos %v_r_2970_3_3_25_10_5295, i64 %fromPile_2876, %Pos %v_coe_4038_17_8_52933)
  %object.i = extractvalue %Pos %z.i, 1
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
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_692 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_692(i64 %tmp_5337, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_540(%Pos %v_r_2966_2_3_5290, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i39 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i39)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %towers_2861_pointer_543 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_543, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %disks_2875_pointer_544 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %disks_2875 = load i64, ptr %disks_2875_pointer_544, align 4, !noalias !0
  %fromPile_2876_pointer_545 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %fromPile_2876 = load i64, ptr %fromPile_2876_pointer_545, align 4, !noalias !0
  %tmp_5332_pointer_546 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5332 = load i64, ptr %tmp_5332_pointer_546, align 4, !noalias !0
  %ontoPile_2877_pointer_547 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_547, align 4, !noalias !0
  %z.i = tail call %Pos @c_array_get(%Pos %v_r_2966_2_3_5290, i64 %fromPile_2876)
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i42 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 80
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i42
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
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
  %newStackPointer.i43 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i43, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i43, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %movesDone_2860.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_668.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %movesDone_2860.unpack2, ptr %stackPointer_668.repack7, align 8, !noalias !0
  %towers_2861_pointer_670 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_670, align 8, !noalias !0
  %towers_2861_pointer_670.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_670.repack9, align 8, !noalias !0
  %disks_2875_pointer_671 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %disks_2875, ptr %disks_2875_pointer_671, align 4, !noalias !0
  %tmp_5332_pointer_672 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_5332, ptr %tmp_5332_pointer_672, align 4, !noalias !0
  %ontoPile_2877_pointer_673 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_673, align 4, !noalias !0
  %returnAddress_pointer_674 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_675 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_676 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_548, ptr %returnAddress_pointer_674, align 8, !noalias !0
  store ptr @sharer_581, ptr %sharer_pointer_675, align 8, !noalias !0
  store ptr @eraser_593, ptr %eraser_pointer_676, align 8, !noalias !0
  %tag_677 = extractvalue %Pos %z.i, 0
  switch i64 %tag_677, label %label_679 [
    i64 0, label %label_683
    i64 1, label %label_713
  ]

label_679:                                        ; preds = %stackAllocate.exit
  ret void

label_683:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_5437 = tail call %Pos @c_bytearray_construct(i64 46, ptr nonnull @utf8StringLiteral_5437.lit)
  tail call void @c_io_println_String(%Pos %utf8StringLiteral_5437)
  tail call void @exit(i32 1)
  %stackPointer.i45 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i47 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i48 = icmp ule ptr %stackPointer.i45, %limit.i47
  tail call void @llvm.assume(i1 %isInside.i48)
  %newStackPointer.i49 = getelementptr i8, ptr %stackPointer.i45, i64 -24
  store ptr %newStackPointer.i49, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_680 = load ptr, ptr %newStackPointer.i49, align 8, !noalias !0
  musttail call tailcc void %returnAddress_680(i64 0, ptr nonnull %stack)
  ret void

label_713:                                        ; preds = %stackAllocate.exit
  %fields_678 = extractvalue %Pos %z.i, 1
  %environment.i = getelementptr i8, ptr %fields_678, i64 16
  %v_coe_4037_16_7_5294.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_coe_4037_16_7_5294.elt11 = getelementptr i8, ptr %fields_678, i64 24
  %v_coe_4037_16_7_5294.unpack12 = load ptr, ptr %v_coe_4037_16_7_5294.elt11, align 8, !noalias !0
  %v_coe_4038_17_8_5293_pointer_686 = getelementptr i8, ptr %fields_678, i64 32
  %v_coe_4038_17_8_5293.unpack = load i64, ptr %v_coe_4038_17_8_5293_pointer_686, align 8, !noalias !0
  %v_coe_4038_17_8_5293.elt14 = getelementptr i8, ptr %fields_678, i64 40
  %v_coe_4038_17_8_5293.unpack15 = load ptr, ptr %v_coe_4038_17_8_5293.elt14, align 8, !noalias !0
  %isNull.i.i30 = icmp eq ptr %v_coe_4037_16_7_5294.unpack12, null
  br i1 %isNull.i.i30, label %sharePositive.exit34, label %next.i.i31

next.i.i31:                                       ; preds = %label_713
  %referenceCount.i.i32 = load i64, ptr %v_coe_4037_16_7_5294.unpack12, align 4
  %referenceCount.1.i.i33 = add i64 %referenceCount.i.i32, 1
  store i64 %referenceCount.1.i.i33, ptr %v_coe_4037_16_7_5294.unpack12, align 4
  br label %sharePositive.exit34

sharePositive.exit34:                             ; preds = %label_713, %next.i.i31
  %isNull.i.i25 = icmp eq ptr %v_coe_4038_17_8_5293.unpack15, null
  br i1 %isNull.i.i25, label %next.i, label %next.i.i26

next.i.i26:                                       ; preds = %sharePositive.exit34
  %referenceCount.i.i27 = load i64, ptr %v_coe_4038_17_8_5293.unpack15, align 4
  %referenceCount.1.i.i28 = add i64 %referenceCount.i.i27, 1
  store i64 %referenceCount.1.i.i28, ptr %v_coe_4038_17_8_5293.unpack15, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i26, %sharePositive.exit34
  %referenceCount.i = load i64, ptr %fields_678, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_678, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_678, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_678)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %currentStackPointer.i52 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i53 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i54 = getelementptr i8, ptr %currentStackPointer.i52, i64 56
  %isInside.not.i55 = icmp ugt ptr %nextStackPointer.i54, %limit.i53
  br i1 %isInside.not.i55, label %realloc.i58, label %stackAllocate.exit72

realloc.i58:                                      ; preds = %eraseObject.exit
  %base_pointer.i59 = getelementptr i8, ptr %stack, i64 16
  %base.i60 = load ptr, ptr %base_pointer.i59, align 8, !alias.scope !0
  %intStackPointer.i61 = ptrtoint ptr %currentStackPointer.i52 to i64
  %intBase.i62 = ptrtoint ptr %base.i60 to i64
  %size.i63 = sub i64 %intStackPointer.i61, %intBase.i62
  %nextSize.i64 = add i64 %size.i63, 56
  %leadingZeros.i.i65 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i64, i1 false)
  %numBits.i.i66 = sub nuw nsw i64 64, %leadingZeros.i.i65
  %result.i.i67 = shl nuw i64 1, %numBits.i.i66
  %newBase.i68 = tail call ptr @realloc(ptr %base.i60, i64 %result.i.i67)
  %newLimit.i69 = getelementptr i8, ptr %newBase.i68, i64 %result.i.i67
  %newStackPointer.i70 = getelementptr i8, ptr %newBase.i68, i64 %size.i63
  %newNextStackPointer.i71 = getelementptr i8, ptr %newStackPointer.i70, i64 56
  store ptr %newBase.i68, ptr %base_pointer.i59, align 8, !alias.scope !0
  store ptr %newLimit.i69, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit72

stackAllocate.exit72:                             ; preds = %eraseObject.exit, %realloc.i58
  %limit.i7884 = phi ptr [ %newLimit.i69, %realloc.i58 ], [ %limit.i53, %eraseObject.exit ]
  %nextStackPointer.sink.i56 = phi ptr [ %newNextStackPointer.i71, %realloc.i58 ], [ %nextStackPointer.i54, %eraseObject.exit ]
  %common.ret.op.i57 = phi ptr [ %newStackPointer.i70, %realloc.i58 ], [ %currentStackPointer.i52, %eraseObject.exit ]
  store ptr %nextStackPointer.sink.i56, ptr %stackPointer_pointer.i, align 8
  store i64 %fromPile_2876, ptr %common.ret.op.i57, align 4, !noalias !0
  %v_coe_4038_17_8_5293_pointer_703 = getelementptr i8, ptr %common.ret.op.i57, i64 8
  store i64 %v_coe_4038_17_8_5293.unpack, ptr %v_coe_4038_17_8_5293_pointer_703, align 8, !noalias !0
  %v_coe_4038_17_8_5293_pointer_703.repack17 = getelementptr i8, ptr %common.ret.op.i57, i64 16
  store ptr %v_coe_4038_17_8_5293.unpack15, ptr %v_coe_4038_17_8_5293_pointer_703.repack17, align 8, !noalias !0
  %tmp_5337_pointer_704 = getelementptr i8, ptr %common.ret.op.i57, i64 24
  store i64 %v_coe_4037_16_7_5294.unpack, ptr %tmp_5337_pointer_704, align 4, !noalias !0
  %returnAddress_pointer_705 = getelementptr i8, ptr %common.ret.op.i57, i64 32
  %sharer_pointer_706 = getelementptr i8, ptr %common.ret.op.i57, i64 40
  %eraser_pointer_707 = getelementptr i8, ptr %common.ret.op.i57, i64 48
  store ptr @returnAddress_687, ptr %returnAddress_pointer_705, align 8, !noalias !0
  store ptr @sharer_424, ptr %sharer_pointer_706, align 8, !noalias !0
  store ptr @eraser_432, ptr %eraser_pointer_707, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %towers_2861.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i73 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i74 = load ptr, ptr %base_pointer.i73, align 8
  %varPointer.i = getelementptr i8, ptr %base.i74, i64 %towers_2861.unpack5
  %towers_2861_old_709.elt19 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %towers_2861_old_709.unpack20 = load ptr, ptr %towers_2861_old_709.elt19, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %towers_2861_old_709.unpack20, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit72
  %referenceCount.i.i = load i64, ptr %towers_2861_old_709.unpack20, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %towers_2861_old_709.unpack20, align 4
  %get_5441.unpack23.pre = load ptr, ptr %towers_2861_old_709.elt19, align 8, !noalias !0
  %stackPointer.i76.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i78.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit72, %next.i.i
  %limit.i78 = phi ptr [ %limit.i7884, %stackAllocate.exit72 ], [ %limit.i78.pre, %next.i.i ]
  %stackPointer.i76 = phi ptr [ %nextStackPointer.sink.i56, %stackAllocate.exit72 ], [ %stackPointer.i76.pre, %next.i.i ]
  %get_5441.unpack23 = phi ptr [ null, %stackAllocate.exit72 ], [ %get_5441.unpack23.pre, %next.i.i ]
  %get_5441.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5441.unpack, 0
  %get_544124 = insertvalue %Pos %0, ptr %get_5441.unpack23, 1
  %isInside.i79 = icmp ule ptr %stackPointer.i76, %limit.i78
  tail call void @llvm.assume(i1 %isInside.i79)
  %newStackPointer.i80 = getelementptr i8, ptr %stackPointer.i76, i64 -24
  store ptr %newStackPointer.i80, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_710 = load ptr, ptr %newStackPointer.i80, align 8, !noalias !0
  musttail call tailcc void %returnAddress_710(%Pos %get_544124, ptr nonnull %stack)
  ret void
}

define void @sharer_720(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_734(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_532(%Pos %__5421, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %towers_2861_pointer_535 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_535, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %disks_2875_pointer_536 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %disks_2875 = load i64, ptr %disks_2875_pointer_536, align 4, !noalias !0
  %fromPile_2876_pointer_537 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %fromPile_2876 = load i64, ptr %fromPile_2876_pointer_537, align 4, !noalias !0
  %tmp_5332_pointer_538 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5332 = load i64, ptr %tmp_5332_pointer_538, align 4, !noalias !0
  %ontoPile_2877_pointer_539 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_539, align 4, !noalias !0
  %object.i = extractvalue %Pos %__5421, 1
  %isNull.i.i17 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i17, label %erasePositive.exit, label %next.i.i18

next.i.i18:                                       ; preds = %entry
  %referenceCount.i.i19 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i19, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i18
  %referenceCount.1.i.i20 = add i64 %referenceCount.i.i19, -1
  store i64 %referenceCount.1.i.i20, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i18
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i28 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i28
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
  %newStackPointer.i29 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i29, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i3541 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i28, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i29, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %movesDone_2860.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_742.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %movesDone_2860.unpack2, ptr %stackPointer_742.repack7, align 8, !noalias !0
  %towers_2861_pointer_744 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_744, align 8, !noalias !0
  %towers_2861_pointer_744.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_744.repack9, align 8, !noalias !0
  %disks_2875_pointer_745 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %disks_2875, ptr %disks_2875_pointer_745, align 4, !noalias !0
  %fromPile_2876_pointer_746 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %fromPile_2876, ptr %fromPile_2876_pointer_746, align 4, !noalias !0
  %tmp_5332_pointer_747 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %tmp_5332, ptr %tmp_5332_pointer_747, align 4, !noalias !0
  %ontoPile_2877_pointer_748 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_748, align 4, !noalias !0
  %returnAddress_pointer_749 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_750 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_751 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_540, ptr %returnAddress_pointer_749, align 8, !noalias !0
  store ptr @sharer_720, ptr %sharer_pointer_750, align 8, !noalias !0
  store ptr @eraser_734, ptr %eraser_pointer_751, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %towers_2861.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i30 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i31 = load ptr, ptr %base_pointer.i30, align 8
  %varPointer.i = getelementptr i8, ptr %base.i31, i64 %towers_2861.unpack5
  %towers_2861_old_753.elt11 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %towers_2861_old_753.unpack12 = load ptr, ptr %towers_2861_old_753.elt11, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %towers_2861_old_753.unpack12, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %towers_2861_old_753.unpack12, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %towers_2861_old_753.unpack12, align 4
  %get_5442.unpack15.pre = load ptr, ptr %towers_2861_old_753.elt11, align 8, !noalias !0
  %stackPointer.i33.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i35.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i35 = phi ptr [ %limit.i3541, %stackAllocate.exit ], [ %limit.i35.pre, %next.i.i ]
  %stackPointer.i33 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i33.pre, %next.i.i ]
  %get_5442.unpack15 = phi ptr [ null, %stackAllocate.exit ], [ %get_5442.unpack15.pre, %next.i.i ]
  %get_5442.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5442.unpack, 0
  %get_544216 = insertvalue %Pos %0, ptr %get_5442.unpack15, 1
  %isInside.i36 = icmp ule ptr %stackPointer.i33, %limit.i35
  tail call void @llvm.assume(i1 %isInside.i36)
  %newStackPointer.i37 = getelementptr i8, ptr %stackPointer.i33, i64 -24
  store ptr %newStackPointer.i37, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_754 = load ptr, ptr %newStackPointer.i37, align 8, !noalias !0
  musttail call tailcc void %returnAddress_754(%Pos %get_544216, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_794(i64 %v_r_2980_14_5281, ptr %stack) {
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
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %z.i = add i64 %v_r_2980_14_5281, 1
  %stack_pointer.i.i = getelementptr i8, ptr %movesDone_2860.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %movesDone_2860.unpack2
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i13 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_800 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_800(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_804(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_808(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_791(%Pos %__13_5287, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i10 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i10)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__13_5287, 1
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
  %limit.i13 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i13
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
  %newStackPointer.i14 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i14, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i20 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i13, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i14, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %movesDone_2860.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_811.repack4 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %movesDone_2860.unpack2, ptr %stackPointer_811.repack4, align 8, !noalias !0
  %returnAddress_pointer_813 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_814 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_815 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_794, ptr %returnAddress_pointer_813, align 8, !noalias !0
  store ptr @sharer_804, ptr %sharer_pointer_814, align 8, !noalias !0
  store ptr @eraser_808, ptr %eraser_pointer_815, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %movesDone_2860.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i15 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i16 = load ptr, ptr %base_pointer.i15, align 8
  %varPointer.i = getelementptr i8, ptr %base.i16, i64 %movesDone_2860.unpack2
  %get_5447 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i21 = icmp ule ptr %nextStackPointer.sink.i, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_818 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_818(i64 %get_5447, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_786(i64 %v_r_2978_12_5284, ptr %stack) {
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
  %ontoPile_2877_pointer_789 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_789, align 4, !noalias !0
  %towers_2861_pointer_790 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_790, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  store ptr @returnAddress_791, ptr %ontoPile_2877_pointer_789, align 8, !noalias !0
  store ptr @sharer_804, ptr %towers_2861_pointer_790, align 8, !noalias !0
  store ptr @eraser_808, ptr %towers_2861.elt4, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 56
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %entry
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 56
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 56
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %entry
  %limit.i1318.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %entry ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %stackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %ontoPile_2877, ptr %common.ret.op.i.i, align 4, !noalias !0
  %newTopDiskOnPile_2862_pointer_519.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %v_r_2978_12_5284, ptr %newTopDiskOnPile_2862_pointer_519.i, align 4, !noalias !0
  %towers_2861_pointer_520.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_520.i, align 8, !noalias !0
  %towers_2861_pointer_520.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_520.repack1.i, align 8, !noalias !0
  %returnAddress_pointer_521.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  %sharer_pointer_522.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %eraser_pointer_523.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr @returnAddress_395, ptr %returnAddress_pointer_521.i, align 8, !noalias !0
  store ptr @sharer_504, ptr %sharer_pointer_522.i, align 8, !noalias !0
  store ptr @eraser_512, ptr %eraser_pointer_523.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %towers_2861.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i9.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i10.i = load ptr, ptr %base_pointer.i9.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i10.i, i64 %towers_2861.unpack5
  %towers_2861_old_525.elt3.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %towers_2861_old_525.unpack4.i = load ptr, ptr %towers_2861_old_525.elt3.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %towers_2861_old_525.unpack4.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %towers_2861_old_525.unpack4.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %towers_2861_old_525.unpack4.i, align 4
  %get_5419.unpack7.pre.i = load ptr, ptr %towers_2861_old_525.elt3.i, align 8, !noalias !0
  %stackPointer.i.pre.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i13.pre.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i13.i = phi ptr [ %limit.i1318.i, %stackAllocate.exit.i ], [ %limit.i13.pre.i, %next.i.i.i ]
  %stackPointer.i.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i.pre.i, %next.i.i.i ]
  %get_5419.unpack7.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_5419.unpack7.pre.i, %next.i.i.i ]
  %get_5419.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5419.unpack.i, 0
  %get_54198.i = insertvalue %Pos %0, ptr %get_5419.unpack7.i, 1
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i13.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_526.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_526.i(%Pos %get_54198.i, ptr nonnull %stack)
  ret void
}

define void @sharer_831(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_839(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_861(%Pos %v_r_2970_3_3_25_10_5280, ptr %stack) {
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
  %fromPile_2876 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %v_coe_4038_17_8_5278_pointer_864 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_coe_4038_17_8_5278.unpack = load i64, ptr %v_coe_4038_17_8_5278_pointer_864, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_coe_4038_17_8_5278.unpack, 0
  %v_coe_4038_17_8_5278.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_coe_4038_17_8_5278.unpack2 = load ptr, ptr %v_coe_4038_17_8_5278.elt1, align 8, !noalias !0
  %v_coe_4038_17_8_52783 = insertvalue %Pos %0, ptr %v_coe_4038_17_8_5278.unpack2, 1
  %tmp_5328_pointer_865 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5328 = load i64, ptr %tmp_5328_pointer_865, align 4, !noalias !0
  %z.i = tail call %Pos @c_array_set(%Pos %v_r_2970_3_3_25_10_5280, i64 %fromPile_2876, %Pos %v_coe_4038_17_8_52783)
  %object.i = extractvalue %Pos %z.i, 1
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
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_866 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_866(i64 %tmp_5328, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_780(%Pos %v_r_2966_2_3_5275, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i39 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i39)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %towers_2861_pointer_783 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_783, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %fromPile_2876_pointer_784 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %fromPile_2876 = load i64, ptr %fromPile_2876_pointer_784, align 4, !noalias !0
  %ontoPile_2877_pointer_785 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ontoPile_2877 = load i64, ptr %ontoPile_2877_pointer_785, align 4, !noalias !0
  %z.i = tail call %Pos @c_array_get(%Pos %v_r_2966_2_3_5275, i64 %fromPile_2876)
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i42 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 64
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i42
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
  %newStackPointer.i43 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i43, i64 64
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i43, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %movesDone_2860.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_844.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %movesDone_2860.unpack2, ptr %stackPointer_844.repack7, align 8, !noalias !0
  %ontoPile_2877_pointer_846 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %ontoPile_2877, ptr %ontoPile_2877_pointer_846, align 4, !noalias !0
  %towers_2861_pointer_847 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_847, align 8, !noalias !0
  %towers_2861_pointer_847.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_847.repack9, align 8, !noalias !0
  %returnAddress_pointer_848 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_849 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_850 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_786, ptr %returnAddress_pointer_848, align 8, !noalias !0
  store ptr @sharer_831, ptr %sharer_pointer_849, align 8, !noalias !0
  store ptr @eraser_839, ptr %eraser_pointer_850, align 8, !noalias !0
  %tag_851 = extractvalue %Pos %z.i, 0
  switch i64 %tag_851, label %label_853 [
    i64 0, label %label_857
    i64 1, label %label_887
  ]

label_853:                                        ; preds = %stackAllocate.exit
  ret void

label_857:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_5449 = tail call %Pos @c_bytearray_construct(i64 46, ptr nonnull @utf8StringLiteral_5449.lit)
  tail call void @c_io_println_String(%Pos %utf8StringLiteral_5449)
  tail call void @exit(i32 1)
  %stackPointer.i45 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i47 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i48 = icmp ule ptr %stackPointer.i45, %limit.i47
  tail call void @llvm.assume(i1 %isInside.i48)
  %newStackPointer.i49 = getelementptr i8, ptr %stackPointer.i45, i64 -24
  store ptr %newStackPointer.i49, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_854 = load ptr, ptr %newStackPointer.i49, align 8, !noalias !0
  musttail call tailcc void %returnAddress_854(i64 0, ptr nonnull %stack)
  ret void

label_887:                                        ; preds = %stackAllocate.exit
  %fields_852 = extractvalue %Pos %z.i, 1
  %environment.i = getelementptr i8, ptr %fields_852, i64 16
  %v_coe_4037_16_7_5279.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_coe_4037_16_7_5279.elt11 = getelementptr i8, ptr %fields_852, i64 24
  %v_coe_4037_16_7_5279.unpack12 = load ptr, ptr %v_coe_4037_16_7_5279.elt11, align 8, !noalias !0
  %v_coe_4038_17_8_5278_pointer_860 = getelementptr i8, ptr %fields_852, i64 32
  %v_coe_4038_17_8_5278.unpack = load i64, ptr %v_coe_4038_17_8_5278_pointer_860, align 8, !noalias !0
  %v_coe_4038_17_8_5278.elt14 = getelementptr i8, ptr %fields_852, i64 40
  %v_coe_4038_17_8_5278.unpack15 = load ptr, ptr %v_coe_4038_17_8_5278.elt14, align 8, !noalias !0
  %isNull.i.i30 = icmp eq ptr %v_coe_4037_16_7_5279.unpack12, null
  br i1 %isNull.i.i30, label %sharePositive.exit34, label %next.i.i31

next.i.i31:                                       ; preds = %label_887
  %referenceCount.i.i32 = load i64, ptr %v_coe_4037_16_7_5279.unpack12, align 4
  %referenceCount.1.i.i33 = add i64 %referenceCount.i.i32, 1
  store i64 %referenceCount.1.i.i33, ptr %v_coe_4037_16_7_5279.unpack12, align 4
  br label %sharePositive.exit34

sharePositive.exit34:                             ; preds = %label_887, %next.i.i31
  %isNull.i.i25 = icmp eq ptr %v_coe_4038_17_8_5278.unpack15, null
  br i1 %isNull.i.i25, label %next.i, label %next.i.i26

next.i.i26:                                       ; preds = %sharePositive.exit34
  %referenceCount.i.i27 = load i64, ptr %v_coe_4038_17_8_5278.unpack15, align 4
  %referenceCount.1.i.i28 = add i64 %referenceCount.i.i27, 1
  store i64 %referenceCount.1.i.i28, ptr %v_coe_4038_17_8_5278.unpack15, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i26, %sharePositive.exit34
  %referenceCount.i = load i64, ptr %fields_852, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_852, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_852, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_852)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %currentStackPointer.i52 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i53 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i54 = getelementptr i8, ptr %currentStackPointer.i52, i64 56
  %isInside.not.i55 = icmp ugt ptr %nextStackPointer.i54, %limit.i53
  br i1 %isInside.not.i55, label %realloc.i58, label %stackAllocate.exit72

realloc.i58:                                      ; preds = %eraseObject.exit
  %base_pointer.i59 = getelementptr i8, ptr %stack, i64 16
  %base.i60 = load ptr, ptr %base_pointer.i59, align 8, !alias.scope !0
  %intStackPointer.i61 = ptrtoint ptr %currentStackPointer.i52 to i64
  %intBase.i62 = ptrtoint ptr %base.i60 to i64
  %size.i63 = sub i64 %intStackPointer.i61, %intBase.i62
  %nextSize.i64 = add i64 %size.i63, 56
  %leadingZeros.i.i65 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i64, i1 false)
  %numBits.i.i66 = sub nuw nsw i64 64, %leadingZeros.i.i65
  %result.i.i67 = shl nuw i64 1, %numBits.i.i66
  %newBase.i68 = tail call ptr @realloc(ptr %base.i60, i64 %result.i.i67)
  %newLimit.i69 = getelementptr i8, ptr %newBase.i68, i64 %result.i.i67
  %newStackPointer.i70 = getelementptr i8, ptr %newBase.i68, i64 %size.i63
  %newNextStackPointer.i71 = getelementptr i8, ptr %newStackPointer.i70, i64 56
  store ptr %newBase.i68, ptr %base_pointer.i59, align 8, !alias.scope !0
  store ptr %newLimit.i69, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit72

stackAllocate.exit72:                             ; preds = %eraseObject.exit, %realloc.i58
  %limit.i7884 = phi ptr [ %newLimit.i69, %realloc.i58 ], [ %limit.i53, %eraseObject.exit ]
  %nextStackPointer.sink.i56 = phi ptr [ %newNextStackPointer.i71, %realloc.i58 ], [ %nextStackPointer.i54, %eraseObject.exit ]
  %common.ret.op.i57 = phi ptr [ %newStackPointer.i70, %realloc.i58 ], [ %currentStackPointer.i52, %eraseObject.exit ]
  store ptr %nextStackPointer.sink.i56, ptr %stackPointer_pointer.i, align 8
  store i64 %fromPile_2876, ptr %common.ret.op.i57, align 4, !noalias !0
  %v_coe_4038_17_8_5278_pointer_877 = getelementptr i8, ptr %common.ret.op.i57, i64 8
  store i64 %v_coe_4038_17_8_5278.unpack, ptr %v_coe_4038_17_8_5278_pointer_877, align 8, !noalias !0
  %v_coe_4038_17_8_5278_pointer_877.repack17 = getelementptr i8, ptr %common.ret.op.i57, i64 16
  store ptr %v_coe_4038_17_8_5278.unpack15, ptr %v_coe_4038_17_8_5278_pointer_877.repack17, align 8, !noalias !0
  %tmp_5328_pointer_878 = getelementptr i8, ptr %common.ret.op.i57, i64 24
  store i64 %v_coe_4037_16_7_5279.unpack, ptr %tmp_5328_pointer_878, align 4, !noalias !0
  %returnAddress_pointer_879 = getelementptr i8, ptr %common.ret.op.i57, i64 32
  %sharer_pointer_880 = getelementptr i8, ptr %common.ret.op.i57, i64 40
  %eraser_pointer_881 = getelementptr i8, ptr %common.ret.op.i57, i64 48
  store ptr @returnAddress_861, ptr %returnAddress_pointer_879, align 8, !noalias !0
  store ptr @sharer_424, ptr %sharer_pointer_880, align 8, !noalias !0
  store ptr @eraser_432, ptr %eraser_pointer_881, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %towers_2861.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i73 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i74 = load ptr, ptr %base_pointer.i73, align 8
  %varPointer.i = getelementptr i8, ptr %base.i74, i64 %towers_2861.unpack5
  %towers_2861_old_883.elt19 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %towers_2861_old_883.unpack20 = load ptr, ptr %towers_2861_old_883.elt19, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %towers_2861_old_883.unpack20, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit72
  %referenceCount.i.i = load i64, ptr %towers_2861_old_883.unpack20, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %towers_2861_old_883.unpack20, align 4
  %get_5453.unpack23.pre = load ptr, ptr %towers_2861_old_883.elt19, align 8, !noalias !0
  %stackPointer.i76.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i78.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit72, %next.i.i
  %limit.i78 = phi ptr [ %limit.i7884, %stackAllocate.exit72 ], [ %limit.i78.pre, %next.i.i ]
  %stackPointer.i76 = phi ptr [ %nextStackPointer.sink.i56, %stackAllocate.exit72 ], [ %stackPointer.i76.pre, %next.i.i ]
  %get_5453.unpack23 = phi ptr [ null, %stackAllocate.exit72 ], [ %get_5453.unpack23.pre, %next.i.i ]
  %get_5453.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5453.unpack, 0
  %get_545324 = insertvalue %Pos %0, ptr %get_5453.unpack23, 1
  %isInside.i79 = icmp ule ptr %stackPointer.i76, %limit.i78
  tail call void @llvm.assume(i1 %isInside.i79)
  %newStackPointer.i80 = getelementptr i8, ptr %stackPointer.i76, i64 -24
  store ptr %newStackPointer.i80, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_884 = load ptr, ptr %newStackPointer.i80, align 8, !noalias !0
  musttail call tailcc void %returnAddress_884(%Pos %get_545324, ptr nonnull %stack)
  ret void
}

define void @sharer_892(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_902(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @moveDisks_2878(i64 %disks_2875, i64 %fromPile_2876, i64 %ontoPile_2877, %Reference %movesDone_2860, %Reference %towers_2861, ptr %stack) local_unnamed_addr {
entry:
  %z.i49 = icmp eq i64 %disks_2875, 1
  %stackPointer_pointer.i20.phi.trans.insert = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i49, label %entry.label_921_crit_edge, label %label_779.lr.ph

entry.label_921_crit_edge:                        ; preds = %entry
  %currentStackPointer.i22.pre = load ptr, ptr %stackPointer_pointer.i20.phi.trans.insert, align 8, !alias.scope !0
  %limit_pointer.i21.phi.trans.insert = getelementptr i8, ptr %stack, i64 24
  %limit.i23.pre = load ptr, ptr %limit_pointer.i21.phi.trans.insert, align 8, !alias.scope !0
  br label %label_921

label_779.lr.ph:                                  ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %movesDone_2860.elt11 = extractvalue %Reference %movesDone_2860, 0
  %movesDone_2860.elt13 = extractvalue %Reference %movesDone_2860, 1
  %towers_2861.elt14 = extractvalue %Reference %towers_2861, 0
  %towers_2861.elt16 = extractvalue %Reference %towers_2861, 1
  %currentStackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i20.phi.trans.insert, align 8, !alias.scope !0
  %limit.i.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %label_779

label_779:                                        ; preds = %label_779.lr.ph, %stackAllocate.exit
  %limit.i = phi ptr [ %limit.i.pre, %label_779.lr.ph ], [ %limit.i53, %stackAllocate.exit ]
  %currentStackPointer.i = phi ptr [ %currentStackPointer.i.pre, %label_779.lr.ph ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %ontoPile_2877.tr51 = phi i64 [ %ontoPile_2877, %label_779.lr.ph ], [ %z.i18, %stackAllocate.exit ]
  %disks_2875.tr50 = phi i64 [ %disks_2875, %label_779.lr.ph ], [ %z.i19, %stackAllocate.exit ]
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_779
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
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_779, %realloc.i
  %limit.i53 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_779 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_779 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_779 ]
  %z.i19 = add i64 %disks_2875.tr50, -1
  %0 = add i64 %ontoPile_2877.tr51, %fromPile_2876
  %z.i18 = sub i64 3, %0
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i20.phi.trans.insert, align 8
  store ptr %movesDone_2860.elt11, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_769.repack12 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %movesDone_2860.elt13, ptr %stackPointer_769.repack12, align 8, !noalias !0
  %towers_2861_pointer_771 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %towers_2861.elt14, ptr %towers_2861_pointer_771, align 8, !noalias !0
  %towers_2861_pointer_771.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %towers_2861.elt16, ptr %towers_2861_pointer_771.repack15, align 8, !noalias !0
  %disks_2875_pointer_772 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %disks_2875.tr50, ptr %disks_2875_pointer_772, align 4, !noalias !0
  %fromPile_2876_pointer_773 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %fromPile_2876, ptr %fromPile_2876_pointer_773, align 4, !noalias !0
  %tmp_5332_pointer_774 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %z.i18, ptr %tmp_5332_pointer_774, align 4, !noalias !0
  %ontoPile_2877_pointer_775 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %ontoPile_2877.tr51, ptr %ontoPile_2877_pointer_775, align 4, !noalias !0
  %returnAddress_pointer_776 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_777 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_778 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_532, ptr %returnAddress_pointer_776, align 8, !noalias !0
  store ptr @sharer_720, ptr %sharer_pointer_777, align 8, !noalias !0
  store ptr @eraser_734, ptr %eraser_pointer_778, align 8, !noalias !0
  %z.i = icmp eq i64 %z.i19, 1
  br i1 %z.i, label %label_921, label %label_779

label_921:                                        ; preds = %stackAllocate.exit, %entry.label_921_crit_edge
  %limit.i23 = phi ptr [ %limit.i23.pre, %entry.label_921_crit_edge ], [ %limit.i53, %stackAllocate.exit ]
  %currentStackPointer.i22 = phi ptr [ %currentStackPointer.i22.pre, %entry.label_921_crit_edge ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %ontoPile_2877.tr.lcssa = phi i64 [ %ontoPile_2877, %entry.label_921_crit_edge ], [ %z.i18, %stackAllocate.exit ]
  %stackPointer_pointer.i20 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i21 = getelementptr i8, ptr %stack, i64 24
  %nextStackPointer.i24 = getelementptr i8, ptr %currentStackPointer.i22, i64 72
  %isInside.not.i25 = icmp ugt ptr %nextStackPointer.i24, %limit.i23
  br i1 %isInside.not.i25, label %realloc.i28, label %stackAllocate.exit42

realloc.i28:                                      ; preds = %label_921
  %base_pointer.i29 = getelementptr i8, ptr %stack, i64 16
  %base.i30 = load ptr, ptr %base_pointer.i29, align 8, !alias.scope !0
  %intStackPointer.i31 = ptrtoint ptr %currentStackPointer.i22 to i64
  %intBase.i32 = ptrtoint ptr %base.i30 to i64
  %size.i33 = sub i64 %intStackPointer.i31, %intBase.i32
  %nextSize.i34 = add i64 %size.i33, 72
  %leadingZeros.i.i35 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i34, i1 false)
  %numBits.i.i36 = sub nuw nsw i64 64, %leadingZeros.i.i35
  %result.i.i37 = shl nuw i64 1, %numBits.i.i36
  %newBase.i38 = tail call ptr @realloc(ptr %base.i30, i64 %result.i.i37)
  %newLimit.i39 = getelementptr i8, ptr %newBase.i38, i64 %result.i.i37
  %newStackPointer.i40 = getelementptr i8, ptr %newBase.i38, i64 %size.i33
  %newNextStackPointer.i41 = getelementptr i8, ptr %newStackPointer.i40, i64 72
  store ptr %newBase.i38, ptr %base_pointer.i29, align 8, !alias.scope !0
  store ptr %newLimit.i39, ptr %limit_pointer.i21, align 8, !alias.scope !0
  br label %stackAllocate.exit42

stackAllocate.exit42:                             ; preds = %label_921, %realloc.i28
  %nextStackPointer.sink.i26 = phi ptr [ %newNextStackPointer.i41, %realloc.i28 ], [ %nextStackPointer.i24, %label_921 ]
  %common.ret.op.i27 = phi ptr [ %newStackPointer.i40, %realloc.i28 ], [ %currentStackPointer.i22, %label_921 ]
  store ptr %nextStackPointer.sink.i26, ptr %stackPointer_pointer.i20, align 8
  %movesDone_2860.elt = extractvalue %Reference %movesDone_2860, 0
  store ptr %movesDone_2860.elt, ptr %common.ret.op.i27, align 8, !noalias !0
  %stackPointer_908.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i27, i64 8
  %movesDone_2860.elt2 = extractvalue %Reference %movesDone_2860, 1
  store i64 %movesDone_2860.elt2, ptr %stackPointer_908.repack1, align 8, !noalias !0
  %towers_2861_pointer_910 = getelementptr i8, ptr %common.ret.op.i27, i64 16
  %towers_2861.elt = extractvalue %Reference %towers_2861, 0
  store ptr %towers_2861.elt, ptr %towers_2861_pointer_910, align 8, !noalias !0
  %towers_2861_pointer_910.repack3 = getelementptr i8, ptr %common.ret.op.i27, i64 24
  %towers_2861.elt4 = extractvalue %Reference %towers_2861, 1
  store i64 %towers_2861.elt4, ptr %towers_2861_pointer_910.repack3, align 8, !noalias !0
  %fromPile_2876_pointer_911 = getelementptr i8, ptr %common.ret.op.i27, i64 32
  store i64 %fromPile_2876, ptr %fromPile_2876_pointer_911, align 4, !noalias !0
  %ontoPile_2877_pointer_912 = getelementptr i8, ptr %common.ret.op.i27, i64 40
  store i64 %ontoPile_2877.tr.lcssa, ptr %ontoPile_2877_pointer_912, align 4, !noalias !0
  %returnAddress_pointer_913 = getelementptr i8, ptr %common.ret.op.i27, i64 48
  %sharer_pointer_914 = getelementptr i8, ptr %common.ret.op.i27, i64 56
  %eraser_pointer_915 = getelementptr i8, ptr %common.ret.op.i27, i64 64
  store ptr @returnAddress_780, ptr %returnAddress_pointer_913, align 8, !noalias !0
  store ptr @sharer_892, ptr %sharer_pointer_914, align 8, !noalias !0
  store ptr @eraser_902, ptr %eraser_pointer_915, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %towers_2861.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i43 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i44 = load ptr, ptr %base_pointer.i43, align 8
  %varPointer.i = getelementptr i8, ptr %base.i44, i64 %towers_2861.elt4
  %towers_2861_old_917.elt5 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %towers_2861_old_917.unpack6 = load ptr, ptr %towers_2861_old_917.elt5, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %towers_2861_old_917.unpack6, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit42
  %referenceCount.i.i = load i64, ptr %towers_2861_old_917.unpack6, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %towers_2861_old_917.unpack6, align 4
  %get_5454.unpack9.pre = load ptr, ptr %towers_2861_old_917.elt5, align 8, !noalias !0
  %stackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i20, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit42, %next.i.i
  %stackPointer.i = phi ptr [ %nextStackPointer.sink.i26, %stackAllocate.exit42 ], [ %stackPointer.i.pre, %next.i.i ]
  %get_5454.unpack9 = phi ptr [ null, %stackAllocate.exit42 ], [ %get_5454.unpack9.pre, %next.i.i ]
  %get_5454.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %1 = insertvalue %Pos poison, i64 %get_5454.unpack, 0
  %get_545410 = insertvalue %Pos %1, ptr %get_5454.unpack9, 1
  %limit.i47 = load ptr, ptr %limit_pointer.i21, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i47
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i48 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i48, ptr %stackPointer_pointer.i20, align 8, !alias.scope !0
  %returnAddress_918 = load ptr, ptr %newStackPointer.i48, align 8, !noalias !0
  musttail call tailcc void %returnAddress_918(%Pos %get_545410, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_927(%Pos %__5456, ptr %stack) {
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
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__5456, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %movesDone_2860.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %movesDone_2860.unpack2
  %get_5457 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_932 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_932(i64 %get_5457, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_922(%Pos %__5455, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %movesDone_2860.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %movesDone_2860.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %movesDone_2860.unpack2 = load i64, ptr %movesDone_2860.elt1, align 8, !noalias !0
  %towers_2861_pointer_925 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_925, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %n_2855_pointer_926 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2855 = load i64, ptr %n_2855_pointer_926, align 4, !noalias !0
  %object.i = extractvalue %Pos %__5455, 1
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i17, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  %0 = insertvalue %Reference poison, ptr %towers_2861.unpack, 0
  %towers_28616 = insertvalue %Reference %0, i64 %towers_2861.unpack5, 1
  %1 = insertvalue %Reference poison, ptr %movesDone_2860.unpack, 0
  %movesDone_28603 = insertvalue %Reference %1, i64 %movesDone_2860.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %movesDone_2860.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_937.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %movesDone_2860.unpack2, ptr %stackPointer_937.repack7, align 8, !noalias !0
  %returnAddress_pointer_939 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_940 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_941 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_927, ptr %returnAddress_pointer_939, align 8, !noalias !0
  store ptr @sharer_804, ptr %sharer_pointer_940, align 8, !noalias !0
  store ptr @eraser_808, ptr %eraser_pointer_941, align 8, !noalias !0
  musttail call tailcc void @moveDisks_2878(i64 %n_2855, i64 0, i64 1, %Reference %movesDone_28603, %Reference %towers_28616, ptr nonnull %stack)
  ret void
}

define void @sharer_945(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_953(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_965(%Pos %returnValue_966, ptr %stack) {
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
  %returnAddress_969 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_969(%Pos %returnValue_966, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1003(%Pos %v_whileThen_2993_12_4483, ptr %stack) {
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
  %i_4_4474.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %i_4_4474.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_4_4474.unpack2 = load i64, ptr %i_4_4474.elt1, align 8, !noalias !0
  %towers_2861_pointer_1006 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_1006, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %v_whileThen_2993_12_4483, 1
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
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 56
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %erasePositive.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 56
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 56
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %erasePositive.exit
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %erasePositive.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %erasePositive.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store ptr %i_4_4474.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_1076.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %i_4_4474.unpack2, ptr %stackPointer_1076.repack1.i, align 8, !noalias !0
  %towers_2861_pointer_1078.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_1078.i, align 8, !noalias !0
  %towers_2861_pointer_1078.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_1078.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_1079.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  %sharer_pointer_1080.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %eraser_pointer_1081.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr @returnAddress_979, ptr %returnAddress_pointer_1079.i, align 8, !noalias !0
  store ptr @sharer_1009, ptr %sharer_pointer_1080.i, align 8, !noalias !0
  store ptr @eraser_1015, ptr %eraser_pointer_1081.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %i_4_4474.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i5.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i6.i = load ptr, ptr %base_pointer.i5.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i6.i, i64 %i_4_4474.unpack2
  %get_5470.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i10.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i10.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1084.i = load ptr, ptr %newStackPointer.i10.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1084.i(i64 %get_5470.i, ptr nonnull %stack)
  ret void
}

define void @sharer_1009(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1015(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_999(i64 %v_r_2991_10_4476, ptr %stack) {
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
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %towers_2861_pointer_1002 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_1002, align 8, !noalias !0
  %i_4_4474.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_4_4474.unpack2 = load i64, ptr %i_4_4474.elt1, align 8, !noalias !0
  %i_4_4474.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = add i64 %v_r_2991_10_4476, -1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %i_4_4474.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_1019.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %i_4_4474.unpack2, ptr %stackPointer_1019.repack7, align 8, !noalias !0
  %towers_2861_pointer_1021 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_1021, align 8, !noalias !0
  %towers_2861_pointer_1021.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_1021.repack9, align 8, !noalias !0
  %sharer_pointer_1023 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1024 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1003, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1009, ptr %sharer_pointer_1023, align 8, !noalias !0
  store ptr @eraser_1015, ptr %eraser_pointer_1024, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %i_4_4474.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %i_4_4474.unpack2
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1028 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1028(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_995(%Pos %__9_4482, ptr %stack) {
entry:
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
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %i_4_4474.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %i_4_4474.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_4_4474.unpack2 = load i64, ptr %i_4_4474.elt1, align 8, !noalias !0
  %towers_2861_pointer_998 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_998, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__9_4482, 1
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
  %limit.i18 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i18
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
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
  %newStackPointer.i19 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i19, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i25 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i18, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i19, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %i_4_4474.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1035.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %i_4_4474.unpack2, ptr %stackPointer_1035.repack7, align 8, !noalias !0
  %towers_2861_pointer_1037 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_1037, align 8, !noalias !0
  %towers_2861_pointer_1037.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_1037.repack9, align 8, !noalias !0
  %returnAddress_pointer_1038 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_1039 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_1040 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_999, ptr %returnAddress_pointer_1038, align 8, !noalias !0
  store ptr @sharer_1009, ptr %sharer_pointer_1039, align 8, !noalias !0
  store ptr @eraser_1015, ptr %eraser_pointer_1040, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %i_4_4474.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %i_4_4474.unpack2
  %get_5467 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i26 = icmp ule ptr %nextStackPointer.sink.i, %limit.i25
  tail call void @llvm.assume(i1 %isInside.i26)
  %newStackPointer.i27 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i27, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1043 = load ptr, ptr %newStackPointer.i27, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1043(i64 %get_5467, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_991(i64 %v_r_2989_8_4479, ptr %stack) {
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
  %towers_2861_pointer_994 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_994, align 8, !noalias !0
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %i_4_4474.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_4_4474.unpack2 = load i64, ptr %i_4_4474.elt1, align 8, !noalias !0
  %i_4_4474.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %i_4_4474.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_1050.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %i_4_4474.unpack2, ptr %stackPointer_1050.repack7, align 8, !noalias !0
  %towers_2861_pointer_1052 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_1052, align 8, !noalias !0
  %towers_2861_pointer_1052.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_1052.repack9, align 8, !noalias !0
  %sharer_pointer_1054 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1055 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_995, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1009, ptr %sharer_pointer_1054, align 8, !noalias !0
  store ptr @eraser_1015, ptr %eraser_pointer_1055, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 80
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 56
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 56
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit
  %limit.i1318.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %oldStackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 0, ptr %common.ret.op.i.i, align 4, !noalias !0
  %newTopDiskOnPile_2862_pointer_519.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %v_r_2989_8_4479, ptr %newTopDiskOnPile_2862_pointer_519.i, align 4, !noalias !0
  %towers_2861_pointer_520.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_520.i, align 8, !noalias !0
  %towers_2861_pointer_520.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_520.repack1.i, align 8, !noalias !0
  %returnAddress_pointer_521.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  %sharer_pointer_522.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %eraser_pointer_523.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr @returnAddress_395, ptr %returnAddress_pointer_521.i, align 8, !noalias !0
  store ptr @sharer_504, ptr %sharer_pointer_522.i, align 8, !noalias !0
  store ptr @eraser_512, ptr %eraser_pointer_523.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %towers_2861.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i9.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i10.i = load ptr, ptr %base_pointer.i9.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i10.i, i64 %towers_2861.unpack5
  %towers_2861_old_525.elt3.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %towers_2861_old_525.unpack4.i = load ptr, ptr %towers_2861_old_525.elt3.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %towers_2861_old_525.unpack4.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %towers_2861_old_525.unpack4.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %towers_2861_old_525.unpack4.i, align 4
  %get_5419.unpack7.pre.i = load ptr, ptr %towers_2861_old_525.elt3.i, align 8, !noalias !0
  %stackPointer.i.pre.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i13.pre.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i13.i = phi ptr [ %limit.i1318.i, %stackAllocate.exit.i ], [ %limit.i13.pre.i, %next.i.i.i ]
  %stackPointer.i.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i.pre.i, %next.i.i.i ]
  %get_5419.unpack7.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_5419.unpack7.pre.i, %next.i.i.i ]
  %get_5419.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5419.unpack.i, 0
  %get_54198.i = insertvalue %Pos %0, ptr %get_5419.unpack7.i, 1
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i13.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_526.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_526.i(%Pos %get_54198.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_979(i64 %v_r_2994_6_4478, ptr %stack) {
entry:
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
  %z.i = icmp sgt i64 %v_r_2994_6_4478, -1
  br i1 %z.i, label %stackAllocate.exit43, label %label_990

label_990:                                        ; preds = %entry
  %isInside.i20 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i20)
  %newStackPointer.i21 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i21, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_987 = load ptr, ptr %newStackPointer.i21, align 8, !noalias !0
  musttail call tailcc void %returnAddress_987(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

stackAllocate.exit43:                             ; preds = %entry
  %towers_2861.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %towers_2861.unpack5 = load i64, ptr %towers_2861.elt4, align 8, !noalias !0
  %towers_2861_pointer_982 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %towers_2861.unpack = load ptr, ptr %towers_2861_pointer_982, align 8, !noalias !0
  %i_4_4474.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_4_4474.unpack2 = load i64, ptr %i_4_4474.elt1, align 8, !noalias !0
  %i_4_4474.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %i_4_4474.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  store i64 %i_4_4474.unpack2, ptr %i_4_4474.elt1, align 8, !noalias !0
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_982, align 8, !noalias !0
  store i64 %towers_2861.unpack5, ptr %towers_2861.elt4, align 8, !noalias !0
  %sharer_pointer_1064 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1065 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_991, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1009, ptr %sharer_pointer_1064, align 8, !noalias !0
  store ptr @eraser_1015, ptr %eraser_pointer_1065, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %i_4_4474.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i26 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i27 = load ptr, ptr %base_pointer.i26, align 8
  %varPointer.i = getelementptr i8, ptr %base.i27, i64 %i_4_4474.unpack2
  %get_5469 = load i64, ptr %varPointer.i, align 4, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %i_4_4474.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_1050.repack7.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %i_4_4474.unpack2, ptr %stackPointer_1050.repack7.i, align 8, !noalias !0
  %towers_2861_pointer_1052.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_1052.i, align 8, !noalias !0
  %towers_2861_pointer_1052.repack9.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_1052.repack9.i, align 8, !noalias !0
  %sharer_pointer_1054.i = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1055.i = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_995, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1009, ptr %sharer_pointer_1054.i, align 8, !noalias !0
  store ptr @eraser_1015, ptr %eraser_pointer_1055.i, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 80
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit43
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 56
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 56
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit43
  %limit.i1318.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i, %stackAllocate.exit43 ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit43 ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %oldStackPointer.i, %stackAllocate.exit43 ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 0, ptr %common.ret.op.i.i, align 4, !noalias !0
  %newTopDiskOnPile_2862_pointer_519.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %get_5469, ptr %newTopDiskOnPile_2862_pointer_519.i, align 4, !noalias !0
  %towers_2861_pointer_520.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store ptr %towers_2861.unpack, ptr %towers_2861_pointer_520.i, align 8, !noalias !0
  %towers_2861_pointer_520.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %towers_2861.unpack5, ptr %towers_2861_pointer_520.repack1.i, align 8, !noalias !0
  %returnAddress_pointer_521.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  %sharer_pointer_522.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %eraser_pointer_523.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr @returnAddress_395, ptr %returnAddress_pointer_521.i, align 8, !noalias !0
  store ptr @sharer_504, ptr %sharer_pointer_522.i, align 8, !noalias !0
  store ptr @eraser_512, ptr %eraser_pointer_523.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %towers_2861.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i9.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i10.i = load ptr, ptr %base_pointer.i9.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i10.i, i64 %towers_2861.unpack5
  %towers_2861_old_525.elt3.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %towers_2861_old_525.unpack4.i = load ptr, ptr %towers_2861_old_525.elt3.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %towers_2861_old_525.unpack4.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %towers_2861_old_525.unpack4.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %towers_2861_old_525.unpack4.i, align 4
  %get_5419.unpack7.pre.i = load ptr, ptr %towers_2861_old_525.elt3.i, align 8, !noalias !0
  %stackPointer.i.pre.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i13.pre.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i13.i = phi ptr [ %limit.i1318.i, %stackAllocate.exit.i ], [ %limit.i13.pre.i, %next.i.i.i ]
  %stackPointer.i.i37 = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i.pre.i, %next.i.i.i ]
  %get_5419.unpack7.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_5419.unpack7.pre.i, %next.i.i.i ]
  %get_5419.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_5419.unpack.i, 0
  %get_54198.i = insertvalue %Pos %0, ptr %get_5419.unpack7.i, 1
  %isInside.i.i38 = icmp ule ptr %stackPointer.i.i37, %limit.i13.i
  tail call void @llvm.assume(i1 %isInside.i.i38)
  %newStackPointer.i14.i = getelementptr i8, ptr %stackPointer.i.i37, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_526.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_526.i(%Pos %get_54198.i, ptr nonnull %stack)
  ret void
}

define tailcc void @b_whileLoop_2988_5_4473(%Reference %i_4_4474, %Reference %towers_2861, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
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
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i9 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %i_4_4474.elt = extractvalue %Reference %i_4_4474, 0
  store ptr %i_4_4474.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1076.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %i_4_4474.elt2 = extractvalue %Reference %i_4_4474, 1
  store i64 %i_4_4474.elt2, ptr %stackPointer_1076.repack1, align 8, !noalias !0
  %towers_2861_pointer_1078 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %towers_2861.elt = extractvalue %Reference %towers_2861, 0
  store ptr %towers_2861.elt, ptr %towers_2861_pointer_1078, align 8, !noalias !0
  %towers_2861_pointer_1078.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %towers_2861.elt4 = extractvalue %Reference %towers_2861, 1
  store i64 %towers_2861.elt4, ptr %towers_2861_pointer_1078.repack3, align 8, !noalias !0
  %returnAddress_pointer_1079 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_1080 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_1081 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_979, ptr %returnAddress_pointer_1079, align 8, !noalias !0
  store ptr @sharer_1009, ptr %sharer_pointer_1080, align 8, !noalias !0
  store ptr @eraser_1015, ptr %eraser_pointer_1081, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %i_4_4474.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i5 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i6 = load ptr, ptr %base_pointer.i5, align 8
  %varPointer.i = getelementptr i8, ptr %base.i6, i64 %i_4_4474.elt2
  %get_5470 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i = icmp ule ptr %nextStackPointer.sink.i, %limit.i9
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i10 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i10, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1084 = load ptr, ptr %newStackPointer.i10, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1084(i64 %get_5470, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_370(%Pos %v_r_3011_15_4422, ptr %stack) {
entry:
  %stackPointer_pointer.i23 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i24 = load ptr, ptr %stackPointer_pointer.i23, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i24, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i29 = icmp ule ptr %stackPointer.i24, %limit.i
  tail call void @llvm.assume(i1 %isInside.i29)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i24, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i23, align 8, !alias.scope !0
  %tmp_5313.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_5313.elt1 = getelementptr i8, ptr %stackPointer.i24, i64 -32
  %tmp_5313.unpack2 = load ptr, ptr %tmp_5313.elt1, align 8, !noalias !0
  %movesDone_2860_pointer_373 = getelementptr i8, ptr %stackPointer.i24, i64 -24
  %movesDone_2860.unpack = load ptr, ptr %movesDone_2860_pointer_373, align 8, !noalias !0
  %movesDone_2860.elt4 = getelementptr i8, ptr %stackPointer.i24, i64 -16
  %movesDone_2860.unpack5 = load i64, ptr %movesDone_2860.elt4, align 8, !noalias !0
  %n_2855_pointer_374 = getelementptr i8, ptr %stackPointer.i24, i64 -8
  %n_2855 = load i64, ptr %n_2855_pointer_374, align 4, !noalias !0
  %object.i = extractvalue %Pos %v_r_3011_15_4422, 1
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
  %base_pointer.i14 = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i23, align 8
  %base.i16 = load ptr, ptr %base_pointer.i14, align 8
  %intStack.i17 = ptrtoint ptr %stackPointer.i15 to i64
  %intBase.i18 = ptrtoint ptr %base.i16 to i64
  %offset.i19 = sub i64 %intStack.i17, %intBase.i18
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i30 = load ptr, ptr %prompt_pointer.i, align 8
  %limit.i33 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i33
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %nextSize.i = add i64 %offset.i19, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i16, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i37 = getelementptr i8, ptr %newBase.i, i64 %offset.i19
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i37, i64 40
  store ptr %newBase.i, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i41 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i33, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i37, %realloc.i ], [ %stackPointer.i15, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i23, align 8
  store i64 %tmp_5313.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_390.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_5313.unpack2, ptr %stackPointer_390.repack7, align 8, !noalias !0
  %returnAddress_pointer_392 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_393 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_394 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_375, ptr %returnAddress_pointer_392, align 8, !noalias !0
  store ptr @sharer_383, ptr %sharer_pointer_393, align 8, !noalias !0
  store ptr @eraser_387, ptr %eraser_pointer_394, align 8, !noalias !0
  %nextStackPointer.i42 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 64
  %isInside.not.i43 = icmp ugt ptr %nextStackPointer.i42, %limit.i41
  br i1 %isInside.not.i43, label %realloc.i46, label %stackAllocate.exit60

realloc.i46:                                      ; preds = %stackAllocate.exit
  %base.i48 = load ptr, ptr %base_pointer.i14, align 8, !alias.scope !0
  %intStackPointer.i49 = ptrtoint ptr %nextStackPointer.sink.i to i64
  %intBase.i50 = ptrtoint ptr %base.i48 to i64
  %size.i51 = sub i64 %intStackPointer.i49, %intBase.i50
  %nextSize.i52 = add i64 %size.i51, 64
  %leadingZeros.i.i53 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i52, i1 false)
  %numBits.i.i54 = sub nuw nsw i64 64, %leadingZeros.i.i53
  %result.i.i55 = shl nuw i64 1, %numBits.i.i54
  %newBase.i56 = tail call ptr @realloc(ptr %base.i48, i64 %result.i.i55)
  %newLimit.i57 = getelementptr i8, ptr %newBase.i56, i64 %result.i.i55
  %newStackPointer.i58 = getelementptr i8, ptr %newBase.i56, i64 %size.i51
  %newNextStackPointer.i59 = getelementptr i8, ptr %newStackPointer.i58, i64 64
  store ptr %newBase.i56, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i57, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit60

stackAllocate.exit60:                             ; preds = %stackAllocate.exit, %realloc.i46
  %limit.i66 = phi ptr [ %newLimit.i57, %realloc.i46 ], [ %limit.i41, %stackAllocate.exit ]
  %nextStackPointer.sink.i44 = phi ptr [ %newNextStackPointer.i59, %realloc.i46 ], [ %nextStackPointer.i42, %stackAllocate.exit ]
  %common.ret.op.i45 = phi ptr [ %newStackPointer.i58, %realloc.i46 ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i44, ptr %stackPointer_pointer.i23, align 8
  store ptr %movesDone_2860.unpack, ptr %common.ret.op.i45, align 8, !noalias !0
  %stackPointer_958.repack9 = getelementptr inbounds i8, ptr %common.ret.op.i45, i64 8
  store i64 %movesDone_2860.unpack5, ptr %stackPointer_958.repack9, align 8, !noalias !0
  %towers_2861_pointer_960 = getelementptr i8, ptr %common.ret.op.i45, i64 16
  store ptr %prompt.i30, ptr %towers_2861_pointer_960, align 8, !noalias !0
  %towers_2861_pointer_960.repack11 = getelementptr i8, ptr %common.ret.op.i45, i64 24
  store i64 %offset.i19, ptr %towers_2861_pointer_960.repack11, align 8, !noalias !0
  %n_2855_pointer_961 = getelementptr i8, ptr %common.ret.op.i45, i64 32
  store i64 %n_2855, ptr %n_2855_pointer_961, align 4, !noalias !0
  %returnAddress_pointer_962 = getelementptr i8, ptr %common.ret.op.i45, i64 40
  %sharer_pointer_963 = getelementptr i8, ptr %common.ret.op.i45, i64 48
  %eraser_pointer_964 = getelementptr i8, ptr %common.ret.op.i45, i64 56
  store ptr @returnAddress_922, ptr %returnAddress_pointer_962, align 8, !noalias !0
  store ptr @sharer_945, ptr %sharer_pointer_963, align 8, !noalias !0
  store ptr @eraser_953, ptr %eraser_pointer_964, align 8, !noalias !0
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i23, align 8
  %base.i = load ptr, ptr %base_pointer.i14, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt.i62 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i67 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i68 = icmp ugt ptr %nextStackPointer.i67, %limit.i66
  br i1 %isInside.not.i68, label %realloc.i71, label %stackAllocate.exit85

realloc.i71:                                      ; preds = %stackAllocate.exit60
  %nextSize.i77 = add i64 %offset.i, 32
  %leadingZeros.i.i78 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i77, i1 false)
  %numBits.i.i79 = sub nuw nsw i64 64, %leadingZeros.i.i78
  %result.i.i80 = shl nuw i64 1, %numBits.i.i79
  %newBase.i81 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i80)
  %newLimit.i82 = getelementptr i8, ptr %newBase.i81, i64 %result.i.i80
  %newStackPointer.i83 = getelementptr i8, ptr %newBase.i81, i64 %offset.i
  %newNextStackPointer.i84 = getelementptr i8, ptr %newStackPointer.i83, i64 32
  store ptr %newBase.i81, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i82, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit85

stackAllocate.exit85:                             ; preds = %stackAllocate.exit60, %realloc.i71
  %limit.i.i = phi ptr [ %newLimit.i82, %realloc.i71 ], [ %limit.i66, %stackAllocate.exit60 ]
  %nextStackPointer.sink.i69 = phi ptr [ %newNextStackPointer.i84, %realloc.i71 ], [ %nextStackPointer.i67, %stackAllocate.exit60 ]
  %common.ret.op.i70 = phi ptr [ %newStackPointer.i83, %realloc.i71 ], [ %stackPointer.i, %stackAllocate.exit60 ]
  store ptr %nextStackPointer.sink.i69, ptr %stackPointer_pointer.i23, align 8
  store i64 %n_2855, ptr %common.ret.op.i70, align 4, !noalias !0
  %returnAddress_pointer_976 = getelementptr i8, ptr %common.ret.op.i70, i64 8
  %sharer_pointer_977 = getelementptr i8, ptr %common.ret.op.i70, i64 16
  %eraser_pointer_978 = getelementptr i8, ptr %common.ret.op.i70, i64 24
  store ptr @returnAddress_965, ptr %returnAddress_pointer_976, align 8, !noalias !0
  store ptr @sharer_348, ptr %sharer_pointer_977, align 8, !noalias !0
  store ptr @eraser_352, ptr %eraser_pointer_978, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i69, i64 56
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit85
  %base.i.i = load ptr, ptr %base_pointer.i14, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i69 to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 56
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 56
  store ptr %newBase.i.i, ptr %base_pointer.i14, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit85
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %stackAllocate.exit85 ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit85 ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i69, %stackAllocate.exit85 ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i23, align 8
  store ptr %prompt.i62, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_1076.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %offset.i, ptr %stackPointer_1076.repack1.i, align 8, !noalias !0
  %towers_2861_pointer_1078.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store ptr %prompt.i30, ptr %towers_2861_pointer_1078.i, align 8, !noalias !0
  %towers_2861_pointer_1078.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %offset.i19, ptr %towers_2861_pointer_1078.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_1079.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  %sharer_pointer_1080.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %eraser_pointer_1081.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr @returnAddress_979, ptr %returnAddress_pointer_1079.i, align 8, !noalias !0
  store ptr @sharer_1009, ptr %sharer_pointer_1080.i, align 8, !noalias !0
  store ptr @eraser_1015, ptr %eraser_pointer_1081.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %prompt.i62, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i5.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i6.i = load ptr, ptr %base_pointer.i5.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i6.i, i64 %offset.i
  %get_5470.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i10.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i10.i, ptr %stackPointer_pointer.i23, align 8, !alias.scope !0
  %returnAddress_1084.i = load ptr, ptr %newStackPointer.i10.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1084.i(i64 %get_5470.i, ptr nonnull %stack)
  ret void
}

define void @sharer_1090(ptr %stackPointer) {
entry:
  %tmp_5313_1087.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_5313_1087.unpack2 = load ptr, ptr %tmp_5313_1087.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5313_1087.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5313_1087.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5313_1087.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1098(ptr %stackPointer) {
entry:
  %tmp_5313_1095.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_5313_1095.unpack2 = load ptr, ptr %tmp_5313_1095.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5313_1095.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5313_1095.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5313_1095.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5313_1095.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5313_1095.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5313_1095.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @run_2856(i64 %n_2855, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i5 = load ptr, ptr %prompt_pointer.i, align 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %nextSize.i = add i64 %offset.i, 32
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %offset.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 32
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %stackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 0, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_357 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_358 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_359 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_340, ptr %returnAddress_pointer_357, align 8, !noalias !0
  store ptr @sharer_348, ptr %sharer_pointer_358, align 8, !noalias !0
  store ptr @eraser_352, ptr %eraser_pointer_359, align 8, !noalias !0
  %z.i = tail call %Pos @c_array_new(i64 3)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %currentStackPointer.i12 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i13 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i14 = getelementptr i8, ptr %currentStackPointer.i12, i64 64
  %isInside.not.i15 = icmp ugt ptr %nextStackPointer.i14, %limit.i13
  br i1 %isInside.not.i15, label %realloc.i18, label %stackAllocate.exit32

realloc.i18:                                      ; preds = %sharePositive.exit
  %base.i20 = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i21 = ptrtoint ptr %currentStackPointer.i12 to i64
  %intBase.i22 = ptrtoint ptr %base.i20 to i64
  %size.i23 = sub i64 %intStackPointer.i21, %intBase.i22
  %nextSize.i24 = add i64 %size.i23, 64
  %leadingZeros.i.i25 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i24, i1 false)
  %numBits.i.i26 = sub nuw nsw i64 64, %leadingZeros.i.i25
  %result.i.i27 = shl nuw i64 1, %numBits.i.i26
  %newBase.i28 = tail call ptr @realloc(ptr %base.i20, i64 %result.i.i27)
  %newLimit.i29 = getelementptr i8, ptr %newBase.i28, i64 %result.i.i27
  %newStackPointer.i30 = getelementptr i8, ptr %newBase.i28, i64 %size.i23
  %newNextStackPointer.i31 = getelementptr i8, ptr %newStackPointer.i30, i64 64
  store ptr %newBase.i28, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i29, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit32

stackAllocate.exit32:                             ; preds = %sharePositive.exit, %realloc.i18
  %nextStackPointer.sink.i16 = phi ptr [ %newNextStackPointer.i31, %realloc.i18 ], [ %nextStackPointer.i14, %sharePositive.exit ]
  %common.ret.op.i17 = phi ptr [ %newStackPointer.i30, %realloc.i18 ], [ %currentStackPointer.i12, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i16, ptr %stackPointer_pointer.i, align 8
  %pureApp_5398.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_5398.elt, ptr %common.ret.op.i17, align 8, !noalias !0
  %stackPointer_1103.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i17, i64 8
  store ptr %object.i, ptr %stackPointer_1103.repack1, align 8, !noalias !0
  %movesDone_2860_pointer_1105 = getelementptr i8, ptr %common.ret.op.i17, i64 16
  store ptr %prompt.i5, ptr %movesDone_2860_pointer_1105, align 8, !noalias !0
  %movesDone_2860_pointer_1105.repack3 = getelementptr i8, ptr %common.ret.op.i17, i64 24
  store i64 %offset.i, ptr %movesDone_2860_pointer_1105.repack3, align 8, !noalias !0
  %n_2855_pointer_1106 = getelementptr i8, ptr %common.ret.op.i17, i64 32
  store i64 %n_2855, ptr %n_2855_pointer_1106, align 4, !noalias !0
  %returnAddress_pointer_1107 = getelementptr i8, ptr %common.ret.op.i17, i64 40
  %sharer_pointer_1108 = getelementptr i8, ptr %common.ret.op.i17, i64 48
  %eraser_pointer_1109 = getelementptr i8, ptr %common.ret.op.i17, i64 56
  store ptr @returnAddress_370, ptr %returnAddress_pointer_1107, align 8, !noalias !0
  store ptr @sharer_1090, ptr %sharer_pointer_1108, align 8, !noalias !0
  store ptr @eraser_1098, ptr %eraser_pointer_1109, align 8, !noalias !0
  musttail call tailcc void @loop_5_9_4412(i64 0, %Pos zeroinitializer, %Pos %z.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1110(%Pos %v_r_3273_4077, ptr %stack) {
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
  %index_2107_pointer_1113 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_1113, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_1115 = extractvalue %Pos %v_r_3273_4077, 0
  switch i64 %tag_1115, label %label_1117 [
    i64 0, label %label_1121
    i64 1, label %label_1127
  ]

label_1117:                                       ; preds = %entry
  ret void

label_1121:                                       ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1121
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

eraseNegative.exit:                               ; preds = %label_1121, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1118 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1118(i64 %x.i, ptr nonnull %stack)
  ret void

label_1127:                                       ; preds = %entry
  %Exception_2362_pointer_1114 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_1114, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_5386 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5386.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5386, %Pos %z.i)
  %utf8StringLiteral_5388 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_5388.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5388)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_5391 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5391.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_5391)
  %functionPointer_1126 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_1126(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_1131(ptr %stackPointer) {
entry:
  %str_2106_1128.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_1128.unpack2 = load ptr, ptr %str_2106_1128.elt1, align 8, !noalias !0
  %Exception_2362_1130.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_1130.unpack5 = load ptr, ptr %Exception_2362_1130.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_1128.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_1128.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_1128.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_1130.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_1130.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_1130.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1139(ptr %stackPointer) {
entry:
  %str_2106_1136.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_1136.unpack2 = load ptr, ptr %str_2106_1136.elt1, align 8, !noalias !0
  %Exception_2362_1138.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_1138.unpack5 = load ptr, ptr %Exception_2362_1138.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_1136.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_1136.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_1136.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_1136.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_1136.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_1136.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_1138.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_1138.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_1138.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_1138.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_1138.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_1138.unpack5)
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
  %stackPointer_1144.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_1144.repack1, align 8, !noalias !0
  %index_2107_pointer_1146 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_1146, align 4, !noalias !0
  %Exception_2362_pointer_1147 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_1147, align 8, !noalias !0
  %Exception_2362_pointer_1147.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_1147.repack3, align 8, !noalias !0
  %returnAddress_pointer_1148 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_1149 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_1150 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_1110, ptr %returnAddress_pointer_1148, align 8, !noalias !0
  store ptr @sharer_1131, ptr %sharer_pointer_1149, align 8, !noalias !0
  store ptr @eraser_1139, ptr %eraser_pointer_1150, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_1157, label %label_1162

label_1157:                                       ; preds = %stackAllocate.exit
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
  %returnAddress_1154 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1154(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_1162:                                       ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_1162
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

erasePositive.exit:                               ; preds = %label_1162, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1159 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1159(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  tail call tailcc void @main_2857(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2857(ptr nonnull %stack.i2.i)
  ret void
}

; Function Attrs: nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @calloc(i64 noundef, i64 noundef) local_unnamed_addr #11

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
attributes #11 = { nofree nounwind willreturn allockind("alloc,zeroed") allocsize(0,1) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" }

!0 = !{!1}
!1 = !{!"stackValues", !2}
!2 = !{!"types"}
