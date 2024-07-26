; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:nbody_f416628e-22e8-4979-a3df-1779f3a655b8/nbody.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:nbody_f416628e-22e8-4979-a3df-1779f3a655b8/nbody.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_1896 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_10166_clause_1881]
@vtable_1927 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_10062_clause_1919]
@utf8StringLiteral_16742.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_16442.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_16444.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_16447.lit = private constant [1 x i8] c"'"

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #0

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) #1

; Function Attrs: mustprogress nounwind willreturn allockind("realloc") allocsize(1) memory(argmem: readwrite, inaccessiblemem: readwrite)
declare noalias noundef ptr @realloc(ptr allocptr nocapture, i64 noundef) local_unnamed_addr #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.sqrt.f64(double) #3

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

declare i64 @c_array_size(%Pos) local_unnamed_addr

declare %Pos @c_array_get(%Pos, i64) local_unnamed_addr

declare %Pos @c_array_set(%Pos, i64, %Pos) local_unnamed_addr

declare i64 @c_bytearray_size(%Pos) local_unnamed_addr

declare %Pos @c_bytearray_construct(i64, ptr) local_unnamed_addr

declare %Pos @c_bytearray_show_Int(i64) local_unnamed_addr

declare %Pos @c_bytearray_show_Double(double) local_unnamed_addr

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

define %Pos @show_18(double %value_17) local_unnamed_addr {
  %z = tail call %Pos @c_bytearray_show_Double(double %value_17)
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
define double @sqrt_130(double %x_129) local_unnamed_addr #5 {
  %z = tail call double @llvm.sqrt.f64(double %x_129)
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

define %Pos @allocate_2473(i64 %size_2472) local_unnamed_addr {
  %z = tail call %Pos @c_array_new(i64 %size_2472)
  ret %Pos %z
}

define i64 @size_2483(%Pos %arr_2482) local_unnamed_addr {
  %z = tail call i64 @c_array_size(%Pos %arr_2482)
  ret i64 %z
}

define %Pos @unsafeGet_2487(%Pos %arr_2485, i64 %index_2486) local_unnamed_addr {
  %z = tail call %Pos @c_array_get(%Pos %arr_2485, i64 %index_2486)
  ret %Pos %z
}

define %Pos @unsafeSet_2492(%Pos %arr_2489, i64 %index_2490, %Pos %value_2491) local_unnamed_addr {
  %z = tail call %Pos @c_array_set(%Pos %arr_2489, i64 %index_2490, %Pos %value_2491)
  ret %Pos %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_11(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define tailcc void @loop_5_257_775_774_4358_12496(i64 %i_6_258_776_775_4359_12272, i64 %i_6_518_517_4101_11416, i64 %tmp_16349, %Pos %bodies_2361_12198, ptr %stack) local_unnamed_addr {
entry:
  %z.i559 = icmp slt i64 %i_6_258_776_775_4359_12272, %tmp_16349
  %object.i62 = extractvalue %Pos %bodies_2361_12198, 1
  br i1 %z.i559, label %label_468.lr.ph, label %label_121

label_468.lr.ph:                                  ; preds = %entry
  %isNull.i.i63 = icmp eq ptr %object.i62, null
  br label %label_468

common.ret:                                       ; preds = %sharePositive.exit73, %sharePositive.exit
  ret void

label_121:                                        ; preds = %erasePositive.exit510, %entry
  %isNull.i.i512 = icmp eq ptr %object.i62, null
  br i1 %isNull.i.i512, label %erasePositive.exit522, label %next.i.i513

next.i.i513:                                      ; preds = %label_121
  %referenceCount.i.i514 = load i64, ptr %object.i62, align 4
  %cond.i.i515 = icmp eq i64 %referenceCount.i.i514, 0
  br i1 %cond.i.i515, label %free.i.i518, label %decr.i.i516

decr.i.i516:                                      ; preds = %next.i.i513
  %referenceCount.1.i.i517 = add i64 %referenceCount.i.i514, -1
  store i64 %referenceCount.1.i.i517, ptr %object.i62, align 4
  br label %erasePositive.exit522

free.i.i518:                                      ; preds = %next.i.i513
  %objectEraser.i.i519 = getelementptr i8, ptr %object.i62, i64 8
  %eraser.i.i520 = load ptr, ptr %objectEraser.i.i519, align 8
  %environment.i.i.i521 = getelementptr i8, ptr %object.i62, i64 16
  tail call void %eraser.i.i520(ptr %environment.i.i.i521)
  tail call void @free(ptr nonnull %object.i62)
  br label %erasePositive.exit522

erasePositive.exit522:                            ; preds = %label_121, %decr.i.i516, %free.i.i518
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_118 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_118(%Pos zeroinitializer, ptr %stack)
  ret void

next.i220:                                        ; preds = %sharePositive.exit73
  %environment.i28 = getelementptr i8, ptr %object.i68, i64 16
  %x_14_272_790_789_4373_10565 = load double, ptr %environment.i28, align 8, !noalias !0
  %referenceCount.i221 = load i64, ptr %object.i68, align 4
  %cond.i222 = icmp eq i64 %referenceCount.i221, 0
  br i1 %cond.i222, label %free.i225, label %decr.i223

decr.i223:                                        ; preds = %next.i220
  %referenceCount.1.i224 = add i64 %referenceCount.i221, -1
  store i64 %referenceCount.1.i224, ptr %object.i68, align 4
  br label %next.i231

free.i225:                                        ; preds = %next.i220
  %objectEraser.i226 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i227 = load ptr, ptr %objectEraser.i226, align 8
  tail call void %eraser.i227(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i231

next.i231:                                        ; preds = %decr.i223, %free.i225
  %z.i523 = fsub double %x_6_264_782_781_4365_11604, %x_14_272_790_789_4373_10565
  %referenceCount.i.i77 = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i78 = add i64 %referenceCount.i.i77, 1
  store i64 %referenceCount.1.i.i78, ptr %object.i55, align 4
  %x_25_283_801_800_4384_11644_pointer_149 = getelementptr i8, ptr %object.i55, i64 24
  %x_25_283_801_800_4384_11644 = load double, ptr %x_25_283_801_800_4384_11644_pointer_149, align 8, !noalias !0
  %cond.i233 = icmp eq i64 %referenceCount.1.i.i78, 0
  br i1 %cond.i233, label %free.i236, label %decr.i234

decr.i234:                                        ; preds = %next.i231
  store i64 %referenceCount.i.i77, ptr %object.i55, align 4
  br label %next.i242

free.i236:                                        ; preds = %next.i231
  %objectEraser.i237 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i238 = load ptr, ptr %objectEraser.i237, align 8
  tail call void %eraser.i238(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %next.i242

next.i242:                                        ; preds = %free.i236, %decr.i234
  %referenceCount.i.i83 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i84 = add i64 %referenceCount.i.i83, 1
  store i64 %referenceCount.1.i.i84, ptr %object.i68, align 4
  %x_33_291_809_808_4392_10905_pointer_160 = getelementptr i8, ptr %object.i68, i64 24
  %x_33_291_809_808_4392_10905 = load double, ptr %x_33_291_809_808_4392_10905_pointer_160, align 8, !noalias !0
  %cond.i244 = icmp eq i64 %referenceCount.1.i.i84, 0
  br i1 %cond.i244, label %free.i247, label %decr.i245

decr.i245:                                        ; preds = %next.i242
  store i64 %referenceCount.i.i83, ptr %object.i68, align 4
  br label %next.i253

free.i247:                                        ; preds = %next.i242
  %objectEraser.i248 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i249 = load ptr, ptr %objectEraser.i248, align 8
  tail call void %eraser.i249(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i253

next.i253:                                        ; preds = %free.i247, %decr.i245
  %z.i524 = fsub double %x_25_283_801_800_4384_11644, %x_33_291_809_808_4392_10905
  %referenceCount.i.i89 = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i90 = add i64 %referenceCount.i.i89, 1
  store i64 %referenceCount.1.i.i90, ptr %object.i55, align 4
  %x_44_302_820_819_4403_10935_pointer_172 = getelementptr i8, ptr %object.i55, i64 32
  %x_44_302_820_819_4403_10935 = load double, ptr %x_44_302_820_819_4403_10935_pointer_172, align 8, !noalias !0
  %cond.i255 = icmp eq i64 %referenceCount.1.i.i90, 0
  br i1 %cond.i255, label %free.i258, label %decr.i256

decr.i256:                                        ; preds = %next.i253
  store i64 %referenceCount.i.i89, ptr %object.i55, align 4
  br label %next.i264

free.i258:                                        ; preds = %next.i253
  %objectEraser.i259 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i260 = load ptr, ptr %objectEraser.i259, align 8
  tail call void %eraser.i260(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %next.i264

next.i264:                                        ; preds = %free.i258, %decr.i256
  %referenceCount.i.i95 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i96 = add i64 %referenceCount.i.i95, 1
  store i64 %referenceCount.1.i.i96, ptr %object.i68, align 4
  %x_52_310_828_827_4411_11136_pointer_183 = getelementptr i8, ptr %object.i68, i64 32
  %x_52_310_828_827_4411_11136 = load double, ptr %x_52_310_828_827_4411_11136_pointer_183, align 8, !noalias !0
  %cond.i266 = icmp eq i64 %referenceCount.1.i.i96, 0
  br i1 %cond.i266, label %free.i269, label %decr.i267

decr.i267:                                        ; preds = %next.i264
  store i64 %referenceCount.i.i95, ptr %object.i68, align 4
  br label %next.i275

free.i269:                                        ; preds = %next.i264
  %objectEraser.i270 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i271 = load ptr, ptr %objectEraser.i270, align 8
  tail call void %eraser.i271(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i275

next.i275:                                        ; preds = %free.i269, %decr.i267
  %z.i525 = fsub double %x_44_302_820_819_4403_10935, %x_52_310_828_827_4411_11136
  %z.i526 = fmul double %z.i523, %z.i523
  %z.i527 = fmul double %z.i524, %z.i524
  %z.i528 = fadd double %z.i526, %z.i527
  %z.i529 = fmul double %z.i525, %z.i525
  %z.i530 = fadd double %z.i528, %z.i529
  %z.i531 = tail call double @llvm.sqrt.f64(double %z.i530)
  %z.i532 = fmul double %z.i530, %z.i531
  %z.i533 = fdiv double 1.000000e-02, %z.i532
  %referenceCount.i.i101 = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i102 = add i64 %referenceCount.i.i101, 1
  store i64 %referenceCount.1.i.i102, ptr %object.i55, align 4
  %x_71_329_847_846_4430_12617 = load double, ptr %environment.i, align 8, !noalias !0
  %cond.i277 = icmp eq i64 %referenceCount.1.i.i102, 0
  br i1 %cond.i277, label %free.i280, label %next.i286

free.i280:                                        ; preds = %next.i275
  %objectEraser.i281 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i282 = load ptr, ptr %objectEraser.i281, align 8
  tail call void %eraser.i282(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  %referenceCount.i.i107.pre = load i64, ptr %object.i55, align 4
  br label %next.i286

next.i286:                                        ; preds = %next.i275, %free.i280
  %referenceCount.i.i107 = phi i64 [ %referenceCount.i.i107.pre, %free.i280 ], [ %referenceCount.i.i101, %next.i275 ]
  %referenceCount.1.i.i108 = add i64 %referenceCount.i.i107, 1
  store i64 %referenceCount.1.i.i108, ptr %object.i55, align 4
  %x_80_338_856_855_4439_10899 = load double, ptr %x_25_283_801_800_4384_11644_pointer_149, align 8, !noalias !0
  %cond.i288 = icmp eq i64 %referenceCount.1.i.i108, 0
  br i1 %cond.i288, label %free.i291, label %next.i297

free.i291:                                        ; preds = %next.i286
  %objectEraser.i292 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i293 = load ptr, ptr %objectEraser.i292, align 8
  tail call void %eraser.i293(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  %referenceCount.i.i113.pre = load i64, ptr %object.i55, align 4
  br label %next.i297

next.i297:                                        ; preds = %next.i286, %free.i291
  %referenceCount.i.i113 = phi i64 [ %referenceCount.i.i113.pre, %free.i291 ], [ %referenceCount.i.i107, %next.i286 ]
  %referenceCount.1.i.i114 = add i64 %referenceCount.i.i113, 1
  store i64 %referenceCount.1.i.i114, ptr %object.i55, align 4
  %x_89_347_865_864_4448_10598 = load double, ptr %x_44_302_820_819_4403_10935_pointer_172, align 8, !noalias !0
  %cond.i299 = icmp eq i64 %referenceCount.1.i.i114, 0
  br i1 %cond.i299, label %free.i302, label %next.i308

free.i302:                                        ; preds = %next.i297
  %objectEraser.i303 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i304 = load ptr, ptr %objectEraser.i303, align 8
  tail call void %eraser.i304(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  %referenceCount.i.i119.pre = load i64, ptr %object.i55, align 4
  br label %next.i308

next.i308:                                        ; preds = %next.i297, %free.i302
  %referenceCount.i.i119 = phi i64 [ %referenceCount.i.i119.pre, %free.i302 ], [ %referenceCount.i.i113, %next.i297 ]
  %referenceCount.1.i.i120 = add i64 %referenceCount.i.i119, 1
  store i64 %referenceCount.1.i.i120, ptr %object.i55, align 4
  %x_98_356_874_873_4457_10609_pointer_228 = getelementptr i8, ptr %object.i55, i64 40
  %x_98_356_874_873_4457_10609 = load double, ptr %x_98_356_874_873_4457_10609_pointer_228, align 8, !noalias !0
  %cond.i310 = icmp eq i64 %referenceCount.1.i.i120, 0
  br i1 %cond.i310, label %free.i313, label %decr.i311

decr.i311:                                        ; preds = %next.i308
  store i64 %referenceCount.i.i119, ptr %object.i55, align 4
  br label %next.i319

free.i313:                                        ; preds = %next.i308
  %objectEraser.i314 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i315 = load ptr, ptr %objectEraser.i314, align 8
  tail call void %eraser.i315(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %next.i319

next.i319:                                        ; preds = %free.i313, %decr.i311
  %referenceCount.i.i125 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i126 = add i64 %referenceCount.i.i125, 1
  store i64 %referenceCount.1.i.i126, ptr %object.i68, align 4
  %x_109_367_885_884_4468_11486_pointer_242 = getelementptr i8, ptr %object.i68, i64 64
  %x_109_367_885_884_4468_11486 = load double, ptr %x_109_367_885_884_4468_11486_pointer_242, align 8, !noalias !0
  %cond.i321 = icmp eq i64 %referenceCount.1.i.i126, 0
  br i1 %cond.i321, label %free.i324, label %decr.i322

decr.i322:                                        ; preds = %next.i319
  store i64 %referenceCount.i.i125, ptr %object.i68, align 4
  br label %next.i330

free.i324:                                        ; preds = %next.i319
  %objectEraser.i325 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i326 = load ptr, ptr %objectEraser.i325, align 8
  tail call void %eraser.i326(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i330

next.i330:                                        ; preds = %free.i324, %decr.i322
  %referenceCount.i.i131 = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i132 = add i64 %referenceCount.i.i131, 1
  store i64 %referenceCount.1.i.i132, ptr %object.i55, align 4
  %x_115_373_891_890_4474_11681_pointer_251 = getelementptr i8, ptr %object.i55, i64 48
  %x_115_373_891_890_4474_11681 = load double, ptr %x_115_373_891_890_4474_11681_pointer_251, align 8, !noalias !0
  %cond.i332 = icmp eq i64 %referenceCount.1.i.i132, 0
  br i1 %cond.i332, label %free.i335, label %decr.i333

decr.i333:                                        ; preds = %next.i330
  store i64 %referenceCount.i.i131, ptr %object.i55, align 4
  br label %next.i341

free.i335:                                        ; preds = %next.i330
  %objectEraser.i336 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i337 = load ptr, ptr %objectEraser.i336, align 8
  tail call void %eraser.i337(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %next.i341

next.i341:                                        ; preds = %free.i335, %decr.i333
  %referenceCount.i.i137 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i138 = add i64 %referenceCount.i.i137, 1
  store i64 %referenceCount.1.i.i138, ptr %object.i68, align 4
  %x_125_383_901_900_4484_11124 = load double, ptr %x_109_367_885_884_4468_11486_pointer_242, align 8, !noalias !0
  %cond.i343 = icmp eq i64 %referenceCount.1.i.i138, 0
  br i1 %cond.i343, label %free.i346, label %decr.i344

decr.i344:                                        ; preds = %next.i341
  store i64 %referenceCount.i.i137, ptr %object.i68, align 4
  br label %next.i352

free.i346:                                        ; preds = %next.i341
  %objectEraser.i347 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i348 = load ptr, ptr %objectEraser.i347, align 8
  tail call void %eraser.i348(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i352

next.i352:                                        ; preds = %free.i346, %decr.i344
  %referenceCount.i.i143 = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i144 = add i64 %referenceCount.i.i143, 1
  store i64 %referenceCount.1.i.i144, ptr %object.i55, align 4
  %x_132_390_908_907_4491_12109_pointer_274 = getelementptr i8, ptr %object.i55, i64 56
  %x_132_390_908_907_4491_12109 = load double, ptr %x_132_390_908_907_4491_12109_pointer_274, align 8, !noalias !0
  %cond.i354 = icmp eq i64 %referenceCount.1.i.i144, 0
  br i1 %cond.i354, label %free.i357, label %decr.i355

decr.i355:                                        ; preds = %next.i352
  store i64 %referenceCount.i.i143, ptr %object.i55, align 4
  br label %next.i363

free.i357:                                        ; preds = %next.i352
  %objectEraser.i358 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i359 = load ptr, ptr %objectEraser.i358, align 8
  tail call void %eraser.i359(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %next.i363

next.i363:                                        ; preds = %free.i357, %decr.i355
  %referenceCount.i.i149 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i150 = add i64 %referenceCount.i.i149, 1
  store i64 %referenceCount.1.i.i150, ptr %object.i68, align 4
  %x_141_399_917_916_4500_11764 = load double, ptr %x_109_367_885_884_4468_11486_pointer_242, align 8, !noalias !0
  %cond.i365 = icmp eq i64 %referenceCount.1.i.i150, 0
  br i1 %cond.i365, label %free.i368, label %decr.i366

decr.i366:                                        ; preds = %next.i363
  store i64 %referenceCount.i.i149, ptr %object.i68, align 4
  br label %next.i374

free.i368:                                        ; preds = %next.i363
  %objectEraser.i369 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i370 = load ptr, ptr %objectEraser.i369, align 8
  tail call void %eraser.i370(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i374

next.i374:                                        ; preds = %free.i368, %decr.i366
  %referenceCount.i.i155 = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i156 = add i64 %referenceCount.i.i155, 1
  store i64 %referenceCount.1.i.i156, ptr %object.i55, align 4
  %x_149_407_925_924_4508_11283_pointer_297 = getelementptr i8, ptr %object.i55, i64 64
  %x_149_407_925_924_4508_11283 = load double, ptr %x_149_407_925_924_4508_11283_pointer_297, align 8, !noalias !0
  %cond.i376 = icmp eq i64 %referenceCount.1.i.i156, 0
  br i1 %cond.i376, label %free.i379, label %decr.i377

decr.i377:                                        ; preds = %next.i374
  store i64 %referenceCount.i.i155, ptr %object.i55, align 4
  br label %eraseObject.exit383

free.i379:                                        ; preds = %next.i374
  %objectEraser.i380 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i381 = load ptr, ptr %objectEraser.i380, align 8
  tail call void %eraser.i381(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %eraseObject.exit383

eraseObject.exit383:                              ; preds = %decr.i377, %free.i379
  %z.i534 = fmul double %z.i523, %x_109_367_885_884_4468_11486
  %z.i535 = fmul double %z.i533, %z.i534
  %z.i536 = fsub double %x_98_356_874_873_4457_10609, %z.i535
  %z.i537 = fmul double %z.i524, %x_125_383_901_900_4484_11124
  %z.i538 = fmul double %z.i533, %z.i537
  %z.i539 = fsub double %x_115_373_891_890_4474_11681, %z.i538
  %z.i540 = fmul double %z.i525, %x_141_399_917_916_4500_11764
  %z.i541 = fmul double %z.i533, %z.i540
  %z.i542 = fsub double %x_132_390_908_907_4491_12109, %z.i541
  %object.i = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_11, ptr %objectEraser.i, align 8
  %environment.i42 = getelementptr i8, ptr %object.i, i64 16
  store double %x_71_329_847_846_4430_12617, ptr %environment.i42, align 8, !noalias !0
  %x_80_338_856_855_4439_10899_pointer_308 = getelementptr i8, ptr %object.i, i64 24
  store double %x_80_338_856_855_4439_10899, ptr %x_80_338_856_855_4439_10899_pointer_308, align 8, !noalias !0
  %x_89_347_865_864_4448_10598_pointer_309 = getelementptr i8, ptr %object.i, i64 32
  store double %x_89_347_865_864_4448_10598, ptr %x_89_347_865_864_4448_10598_pointer_309, align 8, !noalias !0
  %tmp_16366_pointer_310 = getelementptr i8, ptr %object.i, i64 40
  store double %z.i536, ptr %tmp_16366_pointer_310, align 8, !noalias !0
  %tmp_16369_pointer_311 = getelementptr i8, ptr %object.i, i64 48
  store double %z.i539, ptr %tmp_16369_pointer_311, align 8, !noalias !0
  %tmp_16372_pointer_312 = getelementptr i8, ptr %object.i, i64 56
  store double %z.i542, ptr %tmp_16372_pointer_312, align 8, !noalias !0
  %x_149_407_925_924_4508_11283_pointer_313 = getelementptr i8, ptr %object.i, i64 64
  store double %x_149_407_925_924_4508_11283, ptr %x_149_407_925_924_4508_11283_pointer_313, align 8, !noalias !0
  %make_16563 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  br i1 %isNull.i.i63, label %sharePositive.exit169, label %next.i.i166

next.i.i166:                                      ; preds = %eraseObject.exit383
  %referenceCount.i.i167 = load i64, ptr %object.i62, align 4
  %referenceCount.1.i.i168 = add i64 %referenceCount.i.i167, 1
  store i64 %referenceCount.1.i.i168, ptr %object.i62, align 4
  br label %sharePositive.exit169

sharePositive.exit169:                            ; preds = %eraseObject.exit383, %next.i.i166
  %z.i543 = tail call %Pos @c_array_set(%Pos %bodies_2361_12198, i64 %i_6_518_517_4101_11416, %Pos %make_16563)
  %object.i494 = extractvalue %Pos %z.i543, 1
  %isNull.i.i495 = icmp eq ptr %object.i494, null
  br i1 %isNull.i.i495, label %next.i385, label %next.i.i496

next.i.i496:                                      ; preds = %sharePositive.exit169
  %referenceCount.i.i497 = load i64, ptr %object.i494, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i497, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i496
  %referenceCount.1.i.i498 = add i64 %referenceCount.i.i497, -1
  store i64 %referenceCount.1.i.i498, ptr %object.i494, align 4
  br label %next.i385

free.i.i:                                         ; preds = %next.i.i496
  %objectEraser.i.i = getelementptr i8, ptr %object.i494, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i494, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i494)
  br label %next.i385

next.i385:                                        ; preds = %free.i.i, %decr.i.i, %sharePositive.exit169
  %referenceCount.i.i161 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i162 = add i64 %referenceCount.i.i161, 1
  store i64 %referenceCount.1.i.i162, ptr %object.i68, align 4
  %x_162_420_938_937_4521_10549 = load double, ptr %environment.i28, align 8, !noalias !0
  %cond.i387 = icmp eq i64 %referenceCount.1.i.i162, 0
  br i1 %cond.i387, label %free.i390, label %next.i396

free.i390:                                        ; preds = %next.i385
  %objectEraser.i391 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i392 = load ptr, ptr %objectEraser.i391, align 8
  tail call void %eraser.i392(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  %referenceCount.i.i173.pre = load i64, ptr %object.i68, align 4
  br label %next.i396

next.i396:                                        ; preds = %next.i385, %free.i390
  %referenceCount.i.i173 = phi i64 [ %referenceCount.i.i173.pre, %free.i390 ], [ %referenceCount.i.i161, %next.i385 ]
  %referenceCount.1.i.i174 = add i64 %referenceCount.i.i173, 1
  store i64 %referenceCount.1.i.i174, ptr %object.i68, align 4
  %x_171_429_947_946_4530_11288 = load double, ptr %x_33_291_809_808_4392_10905_pointer_160, align 8, !noalias !0
  %cond.i398 = icmp eq i64 %referenceCount.1.i.i174, 0
  br i1 %cond.i398, label %free.i401, label %next.i407

free.i401:                                        ; preds = %next.i396
  %objectEraser.i402 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i403 = load ptr, ptr %objectEraser.i402, align 8
  tail call void %eraser.i403(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  %referenceCount.i.i179.pre = load i64, ptr %object.i68, align 4
  br label %next.i407

next.i407:                                        ; preds = %next.i396, %free.i401
  %referenceCount.i.i179 = phi i64 [ %referenceCount.i.i179.pre, %free.i401 ], [ %referenceCount.i.i173, %next.i396 ]
  %referenceCount.1.i.i180 = add i64 %referenceCount.i.i179, 1
  store i64 %referenceCount.1.i.i180, ptr %object.i68, align 4
  %x_180_438_956_955_4539_11074 = load double, ptr %x_52_310_828_827_4411_11136_pointer_183, align 8, !noalias !0
  %cond.i409 = icmp eq i64 %referenceCount.1.i.i180, 0
  br i1 %cond.i409, label %free.i412, label %next.i418

free.i412:                                        ; preds = %next.i407
  %objectEraser.i413 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i414 = load ptr, ptr %objectEraser.i413, align 8
  tail call void %eraser.i414(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  %referenceCount.i.i185.pre = load i64, ptr %object.i68, align 4
  br label %next.i418

next.i418:                                        ; preds = %next.i407, %free.i412
  %referenceCount.i.i185 = phi i64 [ %referenceCount.i.i185.pre, %free.i412 ], [ %referenceCount.i.i179, %next.i407 ]
  %referenceCount.1.i.i186 = add i64 %referenceCount.i.i185, 1
  store i64 %referenceCount.1.i.i186, ptr %object.i68, align 4
  %x_189_447_965_964_4548_11223_pointer_355 = getelementptr i8, ptr %object.i68, i64 40
  %x_189_447_965_964_4548_11223 = load double, ptr %x_189_447_965_964_4548_11223_pointer_355, align 8, !noalias !0
  %cond.i420 = icmp eq i64 %referenceCount.1.i.i186, 0
  br i1 %cond.i420, label %free.i423, label %decr.i421

decr.i421:                                        ; preds = %next.i418
  store i64 %referenceCount.i.i185, ptr %object.i68, align 4
  br label %next.i429

free.i423:                                        ; preds = %next.i418
  %objectEraser.i424 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i425 = load ptr, ptr %objectEraser.i424, align 8
  tail call void %eraser.i425(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i429

next.i429:                                        ; preds = %free.i423, %decr.i421
  %referenceCount.i.i191 = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i192 = add i64 %referenceCount.i.i191, 1
  store i64 %referenceCount.1.i.i192, ptr %object.i55, align 4
  %x_200_458_976_975_4559_11229 = load double, ptr %x_149_407_925_924_4508_11283_pointer_297, align 8, !noalias !0
  %cond.i431 = icmp eq i64 %referenceCount.1.i.i192, 0
  br i1 %cond.i431, label %free.i434, label %decr.i432

decr.i432:                                        ; preds = %next.i429
  store i64 %referenceCount.i.i191, ptr %object.i55, align 4
  br label %next.i440

free.i434:                                        ; preds = %next.i429
  %objectEraser.i435 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i436 = load ptr, ptr %objectEraser.i435, align 8
  tail call void %eraser.i436(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %next.i440

next.i440:                                        ; preds = %free.i434, %decr.i432
  %referenceCount.i.i197 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i198 = add i64 %referenceCount.i.i197, 1
  store i64 %referenceCount.1.i.i198, ptr %object.i68, align 4
  %x_206_464_982_981_4565_11125_pointer_378 = getelementptr i8, ptr %object.i68, i64 48
  %x_206_464_982_981_4565_11125 = load double, ptr %x_206_464_982_981_4565_11125_pointer_378, align 8, !noalias !0
  %cond.i442 = icmp eq i64 %referenceCount.1.i.i198, 0
  br i1 %cond.i442, label %free.i445, label %decr.i443

decr.i443:                                        ; preds = %next.i440
  store i64 %referenceCount.i.i197, ptr %object.i68, align 4
  br label %next.i451

free.i445:                                        ; preds = %next.i440
  %objectEraser.i446 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i447 = load ptr, ptr %objectEraser.i446, align 8
  tail call void %eraser.i447(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i451

next.i451:                                        ; preds = %free.i445, %decr.i443
  %referenceCount.i.i203 = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i204 = add i64 %referenceCount.i.i203, 1
  store i64 %referenceCount.1.i.i204, ptr %object.i55, align 4
  %x_216_474_992_991_4575_12110 = load double, ptr %x_149_407_925_924_4508_11283_pointer_297, align 8, !noalias !0
  %cond.i453 = icmp eq i64 %referenceCount.1.i.i204, 0
  br i1 %cond.i453, label %free.i456, label %decr.i454

decr.i454:                                        ; preds = %next.i451
  store i64 %referenceCount.i.i203, ptr %object.i55, align 4
  br label %next.i462

free.i456:                                        ; preds = %next.i451
  %objectEraser.i457 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i458 = load ptr, ptr %objectEraser.i457, align 8
  tail call void %eraser.i458(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %next.i462

next.i462:                                        ; preds = %free.i456, %decr.i454
  %referenceCount.i.i209 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i210 = add i64 %referenceCount.i.i209, 1
  store i64 %referenceCount.1.i.i210, ptr %object.i68, align 4
  %x_223_481_999_998_4582_11211_pointer_401 = getelementptr i8, ptr %object.i68, i64 56
  %x_223_481_999_998_4582_11211 = load double, ptr %x_223_481_999_998_4582_11211_pointer_401, align 8, !noalias !0
  %cond.i464 = icmp eq i64 %referenceCount.1.i.i210, 0
  br i1 %cond.i464, label %free.i467, label %decr.i465

decr.i465:                                        ; preds = %next.i462
  store i64 %referenceCount.i.i209, ptr %object.i68, align 4
  br label %next.i473

free.i467:                                        ; preds = %next.i462
  %objectEraser.i468 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i469 = load ptr, ptr %objectEraser.i468, align 8
  tail call void %eraser.i469(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %next.i473

next.i473:                                        ; preds = %free.i467, %decr.i465
  %x_232_490_1008_1007_4591_10836 = load double, ptr %x_149_407_925_924_4508_11283_pointer_297, align 8, !noalias !0
  %referenceCount.i474 = load i64, ptr %object.i55, align 4
  %cond.i475 = icmp eq i64 %referenceCount.i474, 0
  br i1 %cond.i475, label %free.i478, label %decr.i476

decr.i476:                                        ; preds = %next.i473
  %referenceCount.1.i477 = add i64 %referenceCount.i474, -1
  store i64 %referenceCount.1.i477, ptr %object.i55, align 4
  br label %next.i484

free.i478:                                        ; preds = %next.i473
  %objectEraser.i479 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i480 = load ptr, ptr %objectEraser.i479, align 8
  tail call void %eraser.i480(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %next.i484

next.i484:                                        ; preds = %free.i478, %decr.i476
  %x_240_498_1016_1015_4599_12194 = load double, ptr %x_109_367_885_884_4468_11486_pointer_242, align 8, !noalias !0
  %referenceCount.i485 = load i64, ptr %object.i68, align 4
  %cond.i486 = icmp eq i64 %referenceCount.i485, 0
  br i1 %cond.i486, label %free.i489, label %decr.i487

decr.i487:                                        ; preds = %next.i484
  %referenceCount.1.i488 = add i64 %referenceCount.i485, -1
  store i64 %referenceCount.1.i488, ptr %object.i68, align 4
  br label %eraseObject.exit493

free.i489:                                        ; preds = %next.i484
  %objectEraser.i490 = getelementptr i8, ptr %object.i68, i64 8
  %eraser.i491 = load ptr, ptr %objectEraser.i490, align 8
  tail call void %eraser.i491(ptr nonnull %environment.i28)
  tail call void @free(ptr nonnull %object.i68)
  br label %eraseObject.exit493

eraseObject.exit493:                              ; preds = %decr.i487, %free.i489
  %z.i544 = fmul double %z.i523, %x_200_458_976_975_4559_11229
  %z.i545 = fmul double %z.i533, %z.i544
  %z.i546 = fadd double %x_189_447_965_964_4548_11223, %z.i545
  %z.i547 = fmul double %z.i524, %x_216_474_992_991_4575_12110
  %z.i548 = fmul double %z.i533, %z.i547
  %z.i549 = fadd double %x_206_464_982_981_4565_11125, %z.i548
  %z.i550 = fmul double %z.i525, %x_232_490_1008_1007_4591_10836
  %z.i551 = fmul double %z.i533, %z.i550
  %z.i552 = fadd double %x_223_481_999_998_4582_11211, %z.i551
  %object.i26 = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i27 = getelementptr i8, ptr %object.i26, i64 8
  store i64 0, ptr %object.i26, align 4
  store ptr @eraser_11, ptr %objectEraser.i27, align 8
  %environment.i53 = getelementptr i8, ptr %object.i26, i64 16
  store double %x_162_420_938_937_4521_10549, ptr %environment.i53, align 8, !noalias !0
  %x_171_429_947_946_4530_11288_pointer_435 = getelementptr i8, ptr %object.i26, i64 24
  store double %x_171_429_947_946_4530_11288, ptr %x_171_429_947_946_4530_11288_pointer_435, align 8, !noalias !0
  %x_180_438_956_955_4539_11074_pointer_436 = getelementptr i8, ptr %object.i26, i64 32
  store double %x_180_438_956_955_4539_11074, ptr %x_180_438_956_955_4539_11074_pointer_436, align 8, !noalias !0
  %tmp_16377_pointer_437 = getelementptr i8, ptr %object.i26, i64 40
  store double %z.i546, ptr %tmp_16377_pointer_437, align 8, !noalias !0
  %tmp_16380_pointer_438 = getelementptr i8, ptr %object.i26, i64 48
  store double %z.i549, ptr %tmp_16380_pointer_438, align 8, !noalias !0
  %tmp_16383_pointer_439 = getelementptr i8, ptr %object.i26, i64 56
  store double %z.i552, ptr %tmp_16383_pointer_439, align 8, !noalias !0
  %x_240_498_1016_1015_4599_12194_pointer_440 = getelementptr i8, ptr %object.i26, i64 64
  store double %x_240_498_1016_1015_4599_12194, ptr %x_240_498_1016_1015_4599_12194_pointer_440, align 8, !noalias !0
  %make_16574 = insertvalue %Pos zeroinitializer, ptr %object.i26, 1
  br i1 %isNull.i.i63, label %sharePositive.exit217, label %next.i.i214

next.i.i214:                                      ; preds = %eraseObject.exit493
  %referenceCount.i.i215 = load i64, ptr %object.i62, align 4
  %referenceCount.1.i.i216 = add i64 %referenceCount.i.i215, 1
  store i64 %referenceCount.1.i.i216, ptr %object.i62, align 4
  br label %sharePositive.exit217

sharePositive.exit217:                            ; preds = %eraseObject.exit493, %next.i.i214
  %z.i553 = tail call %Pos @c_array_set(%Pos %bodies_2361_12198, i64 %i_6_258_776_775_4359_12272.tr560, %Pos %make_16574)
  %object.i499 = extractvalue %Pos %z.i553, 1
  %isNull.i.i500 = icmp eq ptr %object.i499, null
  br i1 %isNull.i.i500, label %erasePositive.exit510, label %next.i.i501

next.i.i501:                                      ; preds = %sharePositive.exit217
  %referenceCount.i.i502 = load i64, ptr %object.i499, align 4
  %cond.i.i503 = icmp eq i64 %referenceCount.i.i502, 0
  br i1 %cond.i.i503, label %free.i.i506, label %decr.i.i504

decr.i.i504:                                      ; preds = %next.i.i501
  %referenceCount.1.i.i505 = add i64 %referenceCount.i.i502, -1
  store i64 %referenceCount.1.i.i505, ptr %object.i499, align 4
  br label %erasePositive.exit510

free.i.i506:                                      ; preds = %next.i.i501
  %objectEraser.i.i507 = getelementptr i8, ptr %object.i499, i64 8
  %eraser.i.i508 = load ptr, ptr %objectEraser.i.i507, align 8
  %environment.i.i.i509 = getelementptr i8, ptr %object.i499, i64 16
  tail call void %eraser.i.i508(ptr %environment.i.i.i509)
  tail call void @free(ptr nonnull %object.i499)
  br label %erasePositive.exit510

erasePositive.exit510:                            ; preds = %sharePositive.exit217, %decr.i.i504, %free.i.i506
  %z.i554 = add nsw i64 %i_6_258_776_775_4359_12272.tr560, 1
  %z.i = icmp slt i64 %z.i554, %tmp_16349
  br i1 %z.i, label %label_468, label %label_121

next.i:                                           ; preds = %sharePositive.exit
  %environment.i = getelementptr i8, ptr %object.i55, i64 16
  %x_6_264_782_781_4365_11604 = load double, ptr %environment.i, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %object.i55, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %object.i55, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i218 = getelementptr i8, ptr %object.i55, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i218, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i55)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i68 = extractvalue %Pos %z.i556, 1
  %isNull.i.i69 = icmp eq ptr %object.i68, null
  br i1 %isNull.i.i69, label %sharePositive.exit73, label %next.i.i70

next.i.i70:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i71 = load i64, ptr %object.i68, align 4
  %referenceCount.1.i.i72 = add i64 %referenceCount.i.i71, 1
  store i64 %referenceCount.1.i.i72, ptr %object.i68, align 4
  br label %sharePositive.exit73

sharePositive.exit73:                             ; preds = %eraseObject.exit, %next.i.i70
  %tag_133 = extractvalue %Pos %z.i556, 0
  %cond1 = icmp eq i64 %tag_133, 0
  br i1 %cond1, label %next.i220, label %common.ret

label_468:                                        ; preds = %label_468.lr.ph, %erasePositive.exit510
  %i_6_258_776_775_4359_12272.tr560 = phi i64 [ %i_6_258_776_775_4359_12272, %label_468.lr.ph ], [ %z.i554, %erasePositive.exit510 ]
  br i1 %isNull.i.i63, label %sharePositive.exit67.thread, label %next.i.i58

sharePositive.exit67.thread:                      ; preds = %label_468
  %z.i555557 = tail call %Pos @c_array_get(%Pos %bodies_2361_12198, i64 %i_6_518_517_4101_11416)
  br label %sharePositive.exit61

next.i.i58:                                       ; preds = %label_468
  %referenceCount.i.i65 = load i64, ptr %object.i62, align 4
  %referenceCount.1.i.i66 = add i64 %referenceCount.i.i65, 1
  store i64 %referenceCount.1.i.i66, ptr %object.i62, align 4
  %z.i555 = tail call %Pos @c_array_get(%Pos %bodies_2361_12198, i64 %i_6_518_517_4101_11416)
  %referenceCount.i.i59 = load i64, ptr %object.i62, align 4
  %referenceCount.1.i.i60 = add i64 %referenceCount.i.i59, 1
  store i64 %referenceCount.1.i.i60, ptr %object.i62, align 4
  br label %sharePositive.exit61

sharePositive.exit61:                             ; preds = %sharePositive.exit67.thread, %next.i.i58
  %z.i555558 = phi %Pos [ %z.i555557, %sharePositive.exit67.thread ], [ %z.i555, %next.i.i58 ]
  %z.i556 = tail call %Pos @c_array_get(%Pos %bodies_2361_12198, i64 %i_6_258_776_775_4359_12272.tr560)
  %object.i55 = extractvalue %Pos %z.i555558, 1
  %isNull.i.i = icmp eq ptr %object.i55, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit61
  %referenceCount.i.i = load i64, ptr %object.i55, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i55, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit61, %next.i.i
  %tag_122 = extractvalue %Pos %z.i555558, 0
  %cond = icmp eq i64 %tag_122, 0
  br i1 %cond, label %next.i, label %common.ret
}

define tailcc void @returnAddress_469(%Pos %__8_1031_1030_4614_15422, ptr %stack) {
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
  %i_6_518_517_4101_11416 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_16346_pointer_472 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16346 = load i64, ptr %tmp_16346_pointer_472, align 4, !noalias !0
  %bodies_2361_12198_pointer_473 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bodies_2361_12198.unpack = load i64, ptr %bodies_2361_12198_pointer_473, align 8, !noalias !0
  %bodies_2361_12198.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bodies_2361_12198.unpack2 = load ptr, ptr %bodies_2361_12198.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__8_1031_1030_4614_15422, 1
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
  %0 = insertvalue %Pos poison, i64 %bodies_2361_12198.unpack, 0
  %bodies_2361_121983 = insertvalue %Pos %0, ptr %bodies_2361_12198.unpack2, 1
  %z.i = add i64 %i_6_518_517_4101_11416, 1
  musttail call tailcc void @loop_5_517_516_4100_11441(i64 %z.i, i64 %tmp_16346, %Pos %bodies_2361_121983, ptr nonnull %stack)
  ret void
}

define void @sharer_477(ptr %stackPointer) {
entry:
  %bodies_2361_12198_476.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %bodies_2361_12198_476.unpack2 = load ptr, ptr %bodies_2361_12198_476.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_476.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_476.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_476.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_485(ptr %stackPointer) {
entry:
  %bodies_2361_12198_484.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %bodies_2361_12198_484.unpack2 = load ptr, ptr %bodies_2361_12198_484.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_484.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_484.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_484.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bodies_2361_12198_484.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bodies_2361_12198_484.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bodies_2361_12198_484.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_5_517_516_4100_11441(i64 %i_6_518_517_4101_11416, i64 %tmp_16346, %Pos %bodies_2361_12198, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_518_517_4101_11416, %tmp_16346
  %object.i3 = extractvalue %Pos %bodies_2361_12198, 1
  %isNull.i.i4 = icmp eq ptr %object.i3, null
  br i1 %z.i, label %label_497, label %label_113

label_113:                                        ; preds = %entry
  br i1 %isNull.i.i4, label %erasePositive.exit, label %next.i.i11

next.i.i11:                                       ; preds = %label_113
  %referenceCount.i.i12 = load i64, ptr %object.i3, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i12, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i11
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i12, -1
  store i64 %referenceCount.1.i.i13, ptr %object.i3, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i11
  %objectEraser.i.i = getelementptr i8, ptr %object.i3, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i3, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i3)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_113, %decr.i.i, %free.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_110 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_110(%Pos zeroinitializer, ptr %stack)
  ret void

label_497:                                        ; preds = %entry
  br i1 %isNull.i.i4, label %sharePositive.exit8.thread, label %next.i.i

sharePositive.exit8.thread:                       ; preds = %label_497
  %z.i1520 = tail call i64 @c_array_size(%Pos %bodies_2361_12198)
  br label %sharePositive.exit

next.i.i:                                         ; preds = %label_497
  %referenceCount.i.i6 = load i64, ptr %object.i3, align 4
  %referenceCount.1.i.i7 = add i64 %referenceCount.i.i6, 1
  store i64 %referenceCount.1.i.i7, ptr %object.i3, align 4
  %z.i15 = tail call i64 @c_array_size(%Pos %bodies_2361_12198)
  %referenceCount.i.i = load i64, ptr %object.i3, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i3, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit8.thread, %next.i.i
  %z.i1521 = phi i64 [ %z.i1520, %sharePositive.exit8.thread ], [ %z.i15, %next.i.i ]
  %stackPointer_pointer.i16 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i17 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i16, align 8, !alias.scope !0
  %limit.i18 = load ptr, ptr %limit_pointer.i17, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i18
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
  %newStackPointer.i19 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i19, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i17, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i19, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  %z.i14 = add nsw i64 %i_6_518_517_4101_11416, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i16, align 8
  store i64 %i_6_518_517_4101_11416, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_16346_pointer_492 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_16346, ptr %tmp_16346_pointer_492, align 4, !noalias !0
  %bodies_2361_12198_pointer_493 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %bodies_2361_12198.elt = extractvalue %Pos %bodies_2361_12198, 0
  store i64 %bodies_2361_12198.elt, ptr %bodies_2361_12198_pointer_493, align 8, !noalias !0
  %bodies_2361_12198_pointer_493.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i3, ptr %bodies_2361_12198_pointer_493.repack1, align 8, !noalias !0
  %returnAddress_pointer_494 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_495 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_496 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_469, ptr %returnAddress_pointer_494, align 8, !noalias !0
  store ptr @sharer_477, ptr %sharer_pointer_495, align 8, !noalias !0
  store ptr @eraser_485, ptr %eraser_pointer_496, align 8, !noalias !0
  musttail call tailcc void @loop_5_257_775_774_4358_12496(i64 %z.i14, i64 %i_6_518_517_4101_11416, i64 %z.i1521, %Pos %bodies_2361_12198, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_1127_1126_4710_11085(i64 %i_6_1128_1127_4711_10526, i64 %tmp_16388, %Pos %bodies_2361_12198, ptr %stack) local_unnamed_addr {
entry:
  %z.i207 = icmp slt i64 %i_6_1128_1127_4711_10526, %tmp_16388
  %object.i21 = extractvalue %Pos %bodies_2361_12198, 1
  br i1 %z.i207, label %label_648.lr.ph, label %label_510

label_648.lr.ph:                                  ; preds = %entry
  %isNull.i.i22 = icmp eq ptr %object.i21, null
  br label %label_648

common.ret:                                       ; preds = %sharePositive.exit
  ret void

label_510:                                        ; preds = %erasePositive.exit, %entry
  %isNull.i.i187 = icmp eq ptr %object.i21, null
  br i1 %isNull.i.i187, label %erasePositive.exit197, label %next.i.i188

next.i.i188:                                      ; preds = %label_510
  %referenceCount.i.i189 = load i64, ptr %object.i21, align 4
  %cond.i.i190 = icmp eq i64 %referenceCount.i.i189, 0
  br i1 %cond.i.i190, label %free.i.i193, label %decr.i.i191

decr.i.i191:                                      ; preds = %next.i.i188
  %referenceCount.1.i.i192 = add i64 %referenceCount.i.i189, -1
  store i64 %referenceCount.1.i.i192, ptr %object.i21, align 4
  br label %erasePositive.exit197

free.i.i193:                                      ; preds = %next.i.i188
  %objectEraser.i.i194 = getelementptr i8, ptr %object.i21, i64 8
  %eraser.i.i195 = load ptr, ptr %objectEraser.i.i194, align 8
  %environment.i.i.i196 = getelementptr i8, ptr %object.i21, i64 16
  tail call void %eraser.i.i195(ptr %environment.i.i.i196)
  tail call void @free(ptr nonnull %object.i21)
  br label %erasePositive.exit197

erasePositive.exit197:                            ; preds = %label_510, %decr.i.i191, %free.i.i193
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_507 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_507(%Pos zeroinitializer, ptr %stack)
  ret void

next.i:                                           ; preds = %sharePositive.exit
  %environment.i = getelementptr i8, ptr %object.i20, i64 16
  %x_4_1132_1131_4715_11121 = load double, ptr %environment.i, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %object.i20, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  br label %next.i83

free.i:                                           ; preds = %next.i
  %objectEraser.i81 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i81, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i.i30.pre = load i64, ptr %object.i20, align 4
  br label %next.i83

next.i83:                                         ; preds = %free.i, %decr.i
  %referenceCount.i.i30 = phi i64 [ %referenceCount.i.i30.pre, %free.i ], [ %referenceCount.1.i, %decr.i ]
  %referenceCount.1.i.i31 = add i64 %referenceCount.i.i30, 1
  store i64 %referenceCount.1.i.i31, ptr %object.i20, align 4
  %x_15_1143_1142_4726_11722_pointer_529 = getelementptr i8, ptr %object.i20, i64 40
  %x_15_1143_1142_4726_11722 = load double, ptr %x_15_1143_1142_4726_11722_pointer_529, align 8, !noalias !0
  %cond.i85 = icmp eq i64 %referenceCount.1.i.i31, 0
  br i1 %cond.i85, label %free.i88, label %next.i94

free.i88:                                         ; preds = %next.i83
  %objectEraser.i89 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i90 = load ptr, ptr %objectEraser.i89, align 8
  tail call void %eraser.i90(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i.i36.pre = load i64, ptr %object.i20, align 4
  br label %next.i94

next.i94:                                         ; preds = %next.i83, %free.i88
  %referenceCount.i.i36 = phi i64 [ %referenceCount.i.i36.pre, %free.i88 ], [ %referenceCount.i.i30, %next.i83 ]
  %referenceCount.1.i.i37 = add i64 %referenceCount.i.i36, 1
  store i64 %referenceCount.1.i.i37, ptr %object.i20, align 4
  %x_21_1149_1148_4732_11452_pointer_538 = getelementptr i8, ptr %object.i20, i64 24
  %x_21_1149_1148_4732_11452 = load double, ptr %x_21_1149_1148_4732_11452_pointer_538, align 8, !noalias !0
  %cond.i96 = icmp eq i64 %referenceCount.1.i.i37, 0
  br i1 %cond.i96, label %free.i99, label %next.i105

free.i99:                                         ; preds = %next.i94
  %objectEraser.i100 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i101 = load ptr, ptr %objectEraser.i100, align 8
  tail call void %eraser.i101(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i.i42.pre = load i64, ptr %object.i20, align 4
  br label %next.i105

next.i105:                                        ; preds = %next.i94, %free.i99
  %referenceCount.i.i42 = phi i64 [ %referenceCount.i.i42.pre, %free.i99 ], [ %referenceCount.i.i36, %next.i94 ]
  %referenceCount.1.i.i43 = add i64 %referenceCount.i.i42, 1
  store i64 %referenceCount.1.i.i43, ptr %object.i20, align 4
  %x_32_1160_1159_4743_11666_pointer_552 = getelementptr i8, ptr %object.i20, i64 48
  %x_32_1160_1159_4743_11666 = load double, ptr %x_32_1160_1159_4743_11666_pointer_552, align 8, !noalias !0
  %cond.i107 = icmp eq i64 %referenceCount.1.i.i43, 0
  br i1 %cond.i107, label %free.i110, label %next.i116

free.i110:                                        ; preds = %next.i105
  %objectEraser.i111 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i112 = load ptr, ptr %objectEraser.i111, align 8
  tail call void %eraser.i112(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i.i48.pre = load i64, ptr %object.i20, align 4
  br label %next.i116

next.i116:                                        ; preds = %next.i105, %free.i110
  %referenceCount.i.i48 = phi i64 [ %referenceCount.i.i48.pre, %free.i110 ], [ %referenceCount.i.i42, %next.i105 ]
  %referenceCount.1.i.i49 = add i64 %referenceCount.i.i48, 1
  store i64 %referenceCount.1.i.i49, ptr %object.i20, align 4
  %x_38_1166_1165_4749_11418_pointer_561 = getelementptr i8, ptr %object.i20, i64 32
  %x_38_1166_1165_4749_11418 = load double, ptr %x_38_1166_1165_4749_11418_pointer_561, align 8, !noalias !0
  %cond.i118 = icmp eq i64 %referenceCount.1.i.i49, 0
  br i1 %cond.i118, label %free.i121, label %next.i127

free.i121:                                        ; preds = %next.i116
  %objectEraser.i122 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i123 = load ptr, ptr %objectEraser.i122, align 8
  tail call void %eraser.i123(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i.i54.pre = load i64, ptr %object.i20, align 4
  br label %next.i127

next.i127:                                        ; preds = %next.i116, %free.i121
  %referenceCount.i.i54 = phi i64 [ %referenceCount.i.i54.pre, %free.i121 ], [ %referenceCount.i.i48, %next.i116 ]
  %referenceCount.1.i.i55 = add i64 %referenceCount.i.i54, 1
  store i64 %referenceCount.1.i.i55, ptr %object.i20, align 4
  %x_49_1177_1176_4760_12632_pointer_575 = getelementptr i8, ptr %object.i20, i64 56
  %x_49_1177_1176_4760_12632 = load double, ptr %x_49_1177_1176_4760_12632_pointer_575, align 8, !noalias !0
  %cond.i129 = icmp eq i64 %referenceCount.1.i.i55, 0
  br i1 %cond.i129, label %free.i132, label %next.i138

free.i132:                                        ; preds = %next.i127
  %objectEraser.i133 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i134 = load ptr, ptr %objectEraser.i133, align 8
  tail call void %eraser.i134(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i.i60.pre = load i64, ptr %object.i20, align 4
  br label %next.i138

next.i138:                                        ; preds = %next.i127, %free.i132
  %referenceCount.i.i60 = phi i64 [ %referenceCount.i.i60.pre, %free.i132 ], [ %referenceCount.i.i54, %next.i127 ]
  %referenceCount.1.i.i61 = add i64 %referenceCount.i.i60, 1
  store i64 %referenceCount.1.i.i61, ptr %object.i20, align 4
  %x_55_1183_1182_4766_12425 = load double, ptr %x_15_1143_1142_4726_11722_pointer_529, align 8, !noalias !0
  %cond.i140 = icmp eq i64 %referenceCount.1.i.i61, 0
  br i1 %cond.i140, label %free.i143, label %next.i149

free.i143:                                        ; preds = %next.i138
  %objectEraser.i144 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i145 = load ptr, ptr %objectEraser.i144, align 8
  tail call void %eraser.i145(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i.i66.pre = load i64, ptr %object.i20, align 4
  br label %next.i149

next.i149:                                        ; preds = %next.i138, %free.i143
  %referenceCount.i.i66 = phi i64 [ %referenceCount.i.i66.pre, %free.i143 ], [ %referenceCount.i.i60, %next.i138 ]
  %referenceCount.1.i.i67 = add i64 %referenceCount.i.i66, 1
  store i64 %referenceCount.1.i.i67, ptr %object.i20, align 4
  %x_64_1192_1191_4775_12652 = load double, ptr %x_32_1160_1159_4743_11666_pointer_552, align 8, !noalias !0
  %cond.i151 = icmp eq i64 %referenceCount.1.i.i67, 0
  br i1 %cond.i151, label %free.i154, label %next.i160

free.i154:                                        ; preds = %next.i149
  %objectEraser.i155 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i156 = load ptr, ptr %objectEraser.i155, align 8
  tail call void %eraser.i156(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i.i72.pre = load i64, ptr %object.i20, align 4
  br label %next.i160

next.i160:                                        ; preds = %next.i149, %free.i154
  %referenceCount.i.i72 = phi i64 [ %referenceCount.i.i72.pre, %free.i154 ], [ %referenceCount.i.i66, %next.i149 ]
  %referenceCount.1.i.i73 = add i64 %referenceCount.i.i72, 1
  store i64 %referenceCount.1.i.i73, ptr %object.i20, align 4
  %x_73_1201_1200_4784_10816 = load double, ptr %x_49_1177_1176_4760_12632_pointer_575, align 8, !noalias !0
  %cond.i162 = icmp eq i64 %referenceCount.1.i.i73, 0
  br i1 %cond.i162, label %free.i165, label %decr.i163

decr.i163:                                        ; preds = %next.i160
  store i64 %referenceCount.i.i72, ptr %object.i20, align 4
  br label %next.i171

free.i165:                                        ; preds = %next.i160
  %objectEraser.i166 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i167 = load ptr, ptr %objectEraser.i166, align 8
  tail call void %eraser.i167(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  %referenceCount.i172.pr = load i64, ptr %object.i20, align 4
  br label %next.i171

next.i171:                                        ; preds = %free.i165, %decr.i163
  %referenceCount.i172 = phi i64 [ %referenceCount.i172.pr, %free.i165 ], [ %referenceCount.i.i72, %decr.i163 ]
  %x_82_1210_1209_4793_11317_pointer_620 = getelementptr i8, ptr %object.i20, i64 64
  %x_82_1210_1209_4793_11317 = load double, ptr %x_82_1210_1209_4793_11317_pointer_620, align 8, !noalias !0
  %cond.i173 = icmp eq i64 %referenceCount.i172, 0
  br i1 %cond.i173, label %free.i176, label %decr.i174

decr.i174:                                        ; preds = %next.i171
  %referenceCount.1.i175 = add i64 %referenceCount.i172, -1
  store i64 %referenceCount.1.i175, ptr %object.i20, align 4
  br label %eraseObject.exit180

free.i176:                                        ; preds = %next.i171
  %objectEraser.i177 = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i178 = load ptr, ptr %objectEraser.i177, align 8
  tail call void %eraser.i178(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i20)
  br label %eraseObject.exit180

eraseObject.exit180:                              ; preds = %decr.i174, %free.i176
  %z.i198 = fmul double %x_15_1143_1142_4726_11722, 1.000000e-02
  %z.i199 = fadd double %x_4_1132_1131_4715_11121, %z.i198
  %z.i200 = fmul double %x_32_1160_1159_4743_11666, 1.000000e-02
  %z.i201 = fadd double %x_21_1149_1148_4732_11452, %z.i200
  %z.i202 = fmul double %x_49_1177_1176_4760_12632, 1.000000e-02
  %z.i203 = fadd double %x_38_1166_1165_4749_11418, %z.i202
  %object.i = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_11, ptr %objectEraser.i, align 8
  %environment.i18 = getelementptr i8, ptr %object.i, i64 16
  store double %z.i199, ptr %environment.i18, align 8, !noalias !0
  %tmp_16394_pointer_631 = getelementptr i8, ptr %object.i, i64 24
  store double %z.i201, ptr %tmp_16394_pointer_631, align 8, !noalias !0
  %tmp_16396_pointer_632 = getelementptr i8, ptr %object.i, i64 32
  store double %z.i203, ptr %tmp_16396_pointer_632, align 8, !noalias !0
  %x_55_1183_1182_4766_12425_pointer_633 = getelementptr i8, ptr %object.i, i64 40
  store double %x_55_1183_1182_4766_12425, ptr %x_55_1183_1182_4766_12425_pointer_633, align 8, !noalias !0
  %x_64_1192_1191_4775_12652_pointer_634 = getelementptr i8, ptr %object.i, i64 48
  store double %x_64_1192_1191_4775_12652, ptr %x_64_1192_1191_4775_12652_pointer_634, align 8, !noalias !0
  %x_73_1201_1200_4784_10816_pointer_635 = getelementptr i8, ptr %object.i, i64 56
  store double %x_73_1201_1200_4784_10816, ptr %x_73_1201_1200_4784_10816_pointer_635, align 8, !noalias !0
  %x_82_1210_1209_4793_11317_pointer_636 = getelementptr i8, ptr %object.i, i64 64
  store double %x_82_1210_1209_4793_11317, ptr %x_82_1210_1209_4793_11317_pointer_636, align 8, !noalias !0
  %make_16593 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  br i1 %isNull.i.i22, label %sharePositive.exit80, label %next.i.i77

next.i.i77:                                       ; preds = %eraseObject.exit180
  %referenceCount.i.i78 = load i64, ptr %object.i21, align 4
  %referenceCount.1.i.i79 = add i64 %referenceCount.i.i78, 1
  store i64 %referenceCount.1.i.i79, ptr %object.i21, align 4
  br label %sharePositive.exit80

sharePositive.exit80:                             ; preds = %eraseObject.exit180, %next.i.i77
  %z.i204 = tail call %Pos @c_array_set(%Pos %bodies_2361_12198, i64 %i_6_1128_1127_4711_10526.tr208, %Pos %make_16593)
  %object.i181 = extractvalue %Pos %z.i204, 1
  %isNull.i.i182 = icmp eq ptr %object.i181, null
  br i1 %isNull.i.i182, label %erasePositive.exit, label %next.i.i183

next.i.i183:                                      ; preds = %sharePositive.exit80
  %referenceCount.i.i184 = load i64, ptr %object.i181, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i184, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i183
  %referenceCount.1.i.i185 = add i64 %referenceCount.i.i184, -1
  store i64 %referenceCount.1.i.i185, ptr %object.i181, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i183
  %objectEraser.i.i = getelementptr i8, ptr %object.i181, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i181, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i181)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit80, %decr.i.i, %free.i.i
  %z.i205 = add nsw i64 %i_6_1128_1127_4711_10526.tr208, 1
  %z.i = icmp slt i64 %z.i205, %tmp_16388
  br i1 %z.i, label %label_648, label %label_510

label_648:                                        ; preds = %label_648.lr.ph, %erasePositive.exit
  %i_6_1128_1127_4711_10526.tr208 = phi i64 [ %i_6_1128_1127_4711_10526, %label_648.lr.ph ], [ %z.i205, %erasePositive.exit ]
  br i1 %isNull.i.i22, label %sharePositive.exit26, label %next.i.i23

next.i.i23:                                       ; preds = %label_648
  %referenceCount.i.i24 = load i64, ptr %object.i21, align 4
  %referenceCount.1.i.i25 = add i64 %referenceCount.i.i24, 1
  store i64 %referenceCount.1.i.i25, ptr %object.i21, align 4
  br label %sharePositive.exit26

sharePositive.exit26:                             ; preds = %label_648, %next.i.i23
  %z.i206 = tail call %Pos @c_array_get(%Pos %bodies_2361_12198, i64 %i_6_1128_1127_4711_10526.tr208)
  %object.i20 = extractvalue %Pos %z.i206, 1
  %isNull.i.i = icmp eq ptr %object.i20, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit26
  %referenceCount.i.i = load i64, ptr %object.i20, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i20, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit26, %next.i.i
  %tag_511 = extractvalue %Pos %z.i206, 0
  %cond = icmp eq i64 %tag_511, 0
  br i1 %cond, label %next.i, label %common.ret
}

define tailcc void @returnAddress_649(%Pos %__8_4805_15545, ptr %stack) {
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
  %i_6_3584_12359 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_16435_pointer_652 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16435 = load i64, ptr %tmp_16435_pointer_652, align 4, !noalias !0
  %bodies_2361_12198_pointer_653 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bodies_2361_12198.unpack = load i64, ptr %bodies_2361_12198_pointer_653, align 8, !noalias !0
  %bodies_2361_12198.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bodies_2361_12198.unpack2 = load ptr, ptr %bodies_2361_12198.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__8_4805_15545, 1
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
  %0 = insertvalue %Pos poison, i64 %bodies_2361_12198.unpack, 0
  %bodies_2361_121983 = insertvalue %Pos %0, ptr %bodies_2361_12198.unpack2, 1
  %z.i = add i64 %i_6_3584_12359, 1
  musttail call tailcc void @loop_5_3583_12010(i64 %z.i, i64 %tmp_16435, %Pos %bodies_2361_121983, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_498(%Pos %v_r_3100_1033_1032_4616_15423, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i19 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i19)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %bodies_2361_12198.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %bodies_2361_12198.unpack, 0
  %bodies_2361_12198.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %bodies_2361_12198.unpack2 = load ptr, ptr %bodies_2361_12198.elt1, align 8, !noalias !0
  %bodies_2361_121983 = insertvalue %Pos %0, ptr %bodies_2361_12198.unpack2, 1
  %i_6_3584_12359_pointer_501 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_6_3584_12359 = load i64, ptr %i_6_3584_12359_pointer_501, align 4, !noalias !0
  %tmp_16435_pointer_502 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_16435 = load i64, ptr %tmp_16435_pointer_502, align 4, !noalias !0
  %object.i = extractvalue %Pos %v_r_3100_1033_1032_4616_15423, 1
  %isNull.i.i11 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i11, label %erasePositive.exit, label %next.i.i12

next.i.i12:                                       ; preds = %entry
  %referenceCount.i.i13 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i13, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i12
  %referenceCount.1.i.i14 = add i64 %referenceCount.i.i13, -1
  store i64 %referenceCount.1.i.i14, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i12
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i6 = icmp eq ptr %bodies_2361_12198.unpack2, null
  br i1 %isNull.i.i6, label %sharePositive.exit10.thread, label %next.i.i

sharePositive.exit10.thread:                      ; preds = %erasePositive.exit
  %z.i24 = tail call i64 @c_array_size(%Pos %bodies_2361_121983)
  br label %sharePositive.exit

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i8 = load i64, ptr %bodies_2361_12198.unpack2, align 4
  %referenceCount.1.i.i9 = add i64 %referenceCount.i.i8, 1
  store i64 %referenceCount.1.i.i9, ptr %bodies_2361_12198.unpack2, align 4
  %z.i = tail call i64 @c_array_size(%Pos %bodies_2361_121983)
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit10.thread, %next.i.i
  %z.i25 = phi i64 [ %z.i24, %sharePositive.exit10.thread ], [ %z.i, %next.i.i ]
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i22
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
  %newStackPointer.i23 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i23, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i23, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_3584_12359, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_16435_pointer_662 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_16435, ptr %tmp_16435_pointer_662, align 4, !noalias !0
  %bodies_2361_12198_pointer_663 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %bodies_2361_12198.unpack, ptr %bodies_2361_12198_pointer_663, align 8, !noalias !0
  %bodies_2361_12198_pointer_663.repack4 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %bodies_2361_12198.unpack2, ptr %bodies_2361_12198_pointer_663.repack4, align 8, !noalias !0
  %returnAddress_pointer_664 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_665 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_666 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_649, ptr %returnAddress_pointer_664, align 8, !noalias !0
  store ptr @sharer_477, ptr %sharer_pointer_665, align 8, !noalias !0
  store ptr @eraser_485, ptr %eraser_pointer_666, align 8, !noalias !0
  musttail call tailcc void @loop_5_1127_1126_4710_11085(i64 0, i64 %z.i25, %Pos %bodies_2361_121983, ptr nonnull %stack)
  ret void
}

define void @sharer_670(ptr %stackPointer) {
entry:
  %bodies_2361_12198_667.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %bodies_2361_12198_667.unpack2 = load ptr, ptr %bodies_2361_12198_667.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_667.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_667.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_667.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_678(ptr %stackPointer) {
entry:
  %bodies_2361_12198_675.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %bodies_2361_12198_675.unpack2 = load ptr, ptr %bodies_2361_12198_675.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_675.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_675.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_675.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bodies_2361_12198_675.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bodies_2361_12198_675.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bodies_2361_12198_675.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_5_3583_12010(i64 %i_6_3584_12359, i64 %tmp_16435, %Pos %bodies_2361_12198, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_3584_12359, %tmp_16435
  %object.i3 = extractvalue %Pos %bodies_2361_12198, 1
  %isNull.i.i4 = icmp eq ptr %object.i3, null
  br i1 %z.i, label %label_690, label %label_105

label_105:                                        ; preds = %entry
  br i1 %isNull.i.i4, label %erasePositive.exit, label %next.i.i11

next.i.i11:                                       ; preds = %label_105
  %referenceCount.i.i12 = load i64, ptr %object.i3, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i12, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i11
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i12, -1
  store i64 %referenceCount.1.i.i13, ptr %object.i3, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i11
  %objectEraser.i.i = getelementptr i8, ptr %object.i3, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i3, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i3)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_105, %decr.i.i, %free.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_102 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_102(%Pos zeroinitializer, ptr %stack)
  ret void

label_690:                                        ; preds = %entry
  br i1 %isNull.i.i4, label %sharePositive.exit8.thread, label %next.i.i

sharePositive.exit8.thread:                       ; preds = %label_690
  %z.i1419 = tail call i64 @c_array_size(%Pos %bodies_2361_12198)
  br label %sharePositive.exit

next.i.i:                                         ; preds = %label_690
  %referenceCount.i.i6 = load i64, ptr %object.i3, align 4
  %referenceCount.1.i.i7 = add i64 %referenceCount.i.i6, 1
  store i64 %referenceCount.1.i.i7, ptr %object.i3, align 4
  %z.i14 = tail call i64 @c_array_size(%Pos %bodies_2361_12198)
  %referenceCount.i.i = load i64, ptr %object.i3, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i3, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit8.thread, %next.i.i
  %z.i1420 = phi i64 [ %z.i1419, %sharePositive.exit8.thread ], [ %z.i14, %next.i.i ]
  %stackPointer_pointer.i15 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i16 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %limit.i17 = load ptr, ptr %limit_pointer.i16, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i17
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
  %newStackPointer.i18 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i18, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i16, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i18, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i15, align 8
  %bodies_2361_12198.elt = extractvalue %Pos %bodies_2361_12198, 0
  store i64 %bodies_2361_12198.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_683.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i3, ptr %stackPointer_683.repack1, align 8, !noalias !0
  %i_6_3584_12359_pointer_685 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_6_3584_12359, ptr %i_6_3584_12359_pointer_685, align 4, !noalias !0
  %tmp_16435_pointer_686 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_16435, ptr %tmp_16435_pointer_686, align 4, !noalias !0
  %returnAddress_pointer_687 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_688 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_689 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_498, ptr %returnAddress_pointer_687, align 8, !noalias !0
  store ptr @sharer_670, ptr %sharer_pointer_688, align 8, !noalias !0
  store ptr @eraser_678, ptr %eraser_pointer_689, align 8, !noalias !0
  musttail call tailcc void @loop_5_517_516_4100_11441(i64 0, i64 %z.i1420, %Pos %bodies_2361_12198, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_694(double %r_2927, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Double(double %r_2927)
  tail call void @c_io_println_String(%Pos %z.i)
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_695 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_695(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_698(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_700(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_706(double %returnValue_707, ptr %stack) {
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
  %returnAddress_710 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_710(double %returnValue_707, ptr %stack)
  ret void
}

define void @sharer_714(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_718(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_930(%Pos %__8_243_494_5300_15826, ptr %stack) {
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
  %e_3_4809_11809.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %e_3_4809_11809.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %e_3_4809_11809.unpack2 = load i64, ptr %e_3_4809_11809.elt1, align 8, !noalias !0
  %tmp_16413_pointer_933 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_16413 = load i64, ptr %tmp_16413_pointer_933, align 4, !noalias !0
  %tmp_16403_pointer_934 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_16403.unpack = load i64, ptr %tmp_16403_pointer_934, align 8, !noalias !0
  %tmp_16403.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_16403.unpack5 = load ptr, ptr %tmp_16403.elt4, align 8, !noalias !0
  %i_6_158_409_5215_10944_pointer_935 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_6_158_409_5215_10944 = load i64, ptr %i_6_158_409_5215_10944_pointer_935, align 4, !noalias !0
  %bodies_2361_12198_pointer_936 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bodies_2361_12198.unpack = load i64, ptr %bodies_2361_12198_pointer_936, align 8, !noalias !0
  %bodies_2361_12198.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bodies_2361_12198.unpack8 = load ptr, ptr %bodies_2361_12198.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__8_243_494_5300_15826, 1
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
  %0 = insertvalue %Pos poison, i64 %bodies_2361_12198.unpack, 0
  %bodies_2361_121989 = insertvalue %Pos %0, ptr %bodies_2361_12198.unpack8, 1
  %1 = insertvalue %Pos poison, i64 %tmp_16403.unpack, 0
  %tmp_164036 = insertvalue %Pos %1, ptr %tmp_16403.unpack5, 1
  %2 = insertvalue %Reference poison, ptr %e_3_4809_11809.unpack, 0
  %e_3_4809_118093 = insertvalue %Reference %2, i64 %e_3_4809_11809.unpack2, 1
  %z.i = add i64 %i_6_158_409_5215_10944, 1
  musttail call tailcc void @loop_5_157_408_5214_10531(i64 %z.i, %Reference %e_3_4809_118093, i64 %tmp_16413, %Pos %tmp_164036, %Pos %bodies_2361_121989, ptr nonnull %stack)
  ret void
}

define void @sharer_942(ptr %stackPointer) {
entry:
  %tmp_16403_939.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_16403_939.unpack2 = load ptr, ptr %tmp_16403_939.elt1, align 8, !noalias !0
  %bodies_2361_12198_941.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %bodies_2361_12198_941.unpack5 = load ptr, ptr %bodies_2361_12198_941.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_16403_939.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_16403_939.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %tmp_16403_939.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_941.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_941.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_941.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_954(ptr %stackPointer) {
entry:
  %tmp_16403_951.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_16403_951.unpack2 = load ptr, ptr %tmp_16403_951.elt1, align 8, !noalias !0
  %bodies_2361_12198_953.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %bodies_2361_12198_953.unpack5 = load ptr, ptr %bodies_2361_12198_953.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_16403_951.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_16403_951.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_16403_951.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_16403_951.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_16403_951.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_16403_951.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_953.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_953.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_953.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bodies_2361_12198_953.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bodies_2361_12198_953.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bodies_2361_12198_953.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_899(double %v_r_3132_65_223_474_5280_11617, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i36 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i36)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %e_3_4809_11809.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %e_3_4809_11809.elt2 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %e_3_4809_11809.unpack3 = load i64, ptr %e_3_4809_11809.elt2, align 8, !noalias !0
  %tmp_16413_pointer_902 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_16413 = load i64, ptr %tmp_16413_pointer_902, align 4, !noalias !0
  %tmp_16403_pointer_903 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_16403.unpack = load i64, ptr %tmp_16403_pointer_903, align 8, !noalias !0
  %tmp_16403.elt5 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_16403.unpack6 = load ptr, ptr %tmp_16403.elt5, align 8, !noalias !0
  %tmp_16424_pointer_904 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_16424 = load double, ptr %tmp_16424_pointer_904, align 8, !noalias !0
  %i_6_158_409_5215_10944_pointer_905 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %i_6_158_409_5215_10944 = load i64, ptr %i_6_158_409_5215_10944_pointer_905, align 4, !noalias !0
  %tmp_16415_pointer_906 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_16415.unpack = load i64, ptr %tmp_16415_pointer_906, align 8, !noalias !0
  %tmp_16415.elt8 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16415.unpack9 = load ptr, ptr %tmp_16415.elt8, align 8, !noalias !0
  %bodies_2361_12198_pointer_907 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bodies_2361_12198.unpack = load i64, ptr %bodies_2361_12198_pointer_907, align 8, !noalias !0
  %bodies_2361_12198.elt11 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bodies_2361_12198.unpack12 = load ptr, ptr %bodies_2361_12198.elt11, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16403.unpack6, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16403.unpack6, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16403.unpack6, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %cond = icmp eq i64 %tmp_16403.unpack, 0
  br i1 %cond, label %next.i, label %common.ret

common.ret:                                       ; preds = %eraseObject.exit, %sharePositive.exit
  ret void

next.i22:                                         ; preds = %eraseObject.exit
  %x_80_238_489_5295_12152_pointer_929 = getelementptr i8, ptr %tmp_16415.unpack9, i64 64
  %x_80_238_489_5295_12152 = load double, ptr %x_80_238_489_5295_12152_pointer_929, align 8, !noalias !0
  %referenceCount.i23 = load i64, ptr %tmp_16415.unpack9, align 4
  %cond.i24 = icmp eq i64 %referenceCount.i23, 0
  br i1 %cond.i24, label %free.i27, label %decr.i25

decr.i25:                                         ; preds = %next.i22
  %referenceCount.1.i26 = add i64 %referenceCount.i23, -1
  store i64 %referenceCount.1.i26, ptr %tmp_16415.unpack9, align 4
  br label %eraseObject.exit31

free.i27:                                         ; preds = %next.i22
  %environment.i20 = getelementptr i8, ptr %tmp_16415.unpack9, i64 16
  %objectEraser.i28 = getelementptr i8, ptr %tmp_16415.unpack9, i64 8
  %eraser.i29 = load ptr, ptr %objectEraser.i28, align 8
  tail call void %eraser.i29(ptr %environment.i20)
  tail call void @free(ptr nonnull %tmp_16415.unpack9)
  br label %eraseObject.exit31

eraseObject.exit31:                               ; preds = %decr.i25, %free.i27
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i41 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i41
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit31
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
  %newStackPointer.i42 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i42, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit31, %realloc.i
  %limit.i48 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i41, %eraseObject.exit31 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit31 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i42, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit31 ]
  %z.i = fmul double %x_72_230_481_5287_12609, %x_80_238_489_5295_12152
  %z.i37 = fdiv double %z.i, %tmp_16424
  %z.i38 = fsub double %v_r_3132_65_223_474_5280_11617, %z.i37
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %e_3_4809_11809.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_961.repack14 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %e_3_4809_11809.unpack3, ptr %stackPointer_961.repack14, align 8, !noalias !0
  %tmp_16413_pointer_963 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_16413, ptr %tmp_16413_pointer_963, align 4, !noalias !0
  %tmp_16403_pointer_964 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 0, ptr %tmp_16403_pointer_964, align 8, !noalias !0
  %tmp_16403_pointer_964.repack16 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %tmp_16403.unpack6, ptr %tmp_16403_pointer_964.repack16, align 8, !noalias !0
  %i_6_158_409_5215_10944_pointer_965 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %i_6_158_409_5215_10944, ptr %i_6_158_409_5215_10944_pointer_965, align 4, !noalias !0
  %bodies_2361_12198_pointer_966 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %bodies_2361_12198.unpack, ptr %bodies_2361_12198_pointer_966, align 8, !noalias !0
  %bodies_2361_12198_pointer_966.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %bodies_2361_12198.unpack12, ptr %bodies_2361_12198_pointer_966.repack18, align 8, !noalias !0
  %returnAddress_pointer_967 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_968 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_969 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_930, ptr %returnAddress_pointer_967, align 8, !noalias !0
  store ptr @sharer_942, ptr %sharer_pointer_968, align 8, !noalias !0
  store ptr @eraser_954, ptr %eraser_pointer_969, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %e_3_4809_11809.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i43 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i44 = load ptr, ptr %base_pointer.i43, align 8
  %varPointer.i = getelementptr i8, ptr %base.i44, i64 %e_3_4809_11809.unpack3
  store double %z.i38, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i49 = icmp ule ptr %nextStackPointer.sink.i, %limit.i48
  tail call void @llvm.assume(i1 %isInside.i49)
  %newStackPointer.i50 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i50, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_973 = load ptr, ptr %newStackPointer.i50, align 8, !noalias !0
  musttail call tailcc void %returnAddress_973(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

next.i:                                           ; preds = %sharePositive.exit
  %x_72_230_481_5287_12609_pointer_918 = getelementptr i8, ptr %tmp_16403.unpack6, i64 64
  %x_72_230_481_5287_12609 = load double, ptr %x_72_230_481_5287_12609_pointer_918, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %tmp_16403.unpack6, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %tmp_16403.unpack6, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %environment.i = getelementptr i8, ptr %tmp_16403.unpack6, i64 16
  %objectEraser.i = getelementptr i8, ptr %tmp_16403.unpack6, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16403.unpack6)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %cond1 = icmp eq i64 %tmp_16415.unpack, 0
  br i1 %cond1, label %next.i22, label %common.ret
}

define void @sharer_985(ptr %stackPointer) {
entry:
  %tmp_16403_980.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_16403_980.unpack2 = load ptr, ptr %tmp_16403_980.elt1, align 8, !noalias !0
  %tmp_16415_983.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %tmp_16415_983.unpack5 = load ptr, ptr %tmp_16415_983.elt4, align 8, !noalias !0
  %bodies_2361_12198_984.elt7 = getelementptr i8, ptr %stackPointer, i64 -8
  %bodies_2361_12198_984.unpack8 = load ptr, ptr %bodies_2361_12198_984.elt7, align 8, !noalias !0
  %isNull.i.i15 = icmp eq ptr %tmp_16403_980.unpack2, null
  br i1 %isNull.i.i15, label %sharePositive.exit19, label %next.i.i16

next.i.i16:                                       ; preds = %entry
  %referenceCount.i.i17 = load i64, ptr %tmp_16403_980.unpack2, align 4
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i17, 1
  store i64 %referenceCount.1.i.i18, ptr %tmp_16403_980.unpack2, align 4
  br label %sharePositive.exit19

sharePositive.exit19:                             ; preds = %entry, %next.i.i16
  %isNull.i.i10 = icmp eq ptr %tmp_16415_983.unpack5, null
  br i1 %isNull.i.i10, label %sharePositive.exit14, label %next.i.i11

next.i.i11:                                       ; preds = %sharePositive.exit19
  %referenceCount.i.i12 = load i64, ptr %tmp_16415_983.unpack5, align 4
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i12, 1
  store i64 %referenceCount.1.i.i13, ptr %tmp_16415_983.unpack5, align 4
  br label %sharePositive.exit14

sharePositive.exit14:                             ; preds = %sharePositive.exit19, %next.i.i11
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_984.unpack8, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit14
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_984.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_984.unpack8, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit14, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1001(ptr %stackPointer) {
entry:
  %tmp_16403_996.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_16403_996.unpack2 = load ptr, ptr %tmp_16403_996.elt1, align 8, !noalias !0
  %tmp_16415_999.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %tmp_16415_999.unpack5 = load ptr, ptr %tmp_16415_999.elt4, align 8, !noalias !0
  %bodies_2361_12198_1000.elt7 = getelementptr i8, ptr %stackPointer, i64 -8
  %bodies_2361_12198_1000.unpack8 = load ptr, ptr %bodies_2361_12198_1000.elt7, align 8, !noalias !0
  %isNull.i.i21 = icmp eq ptr %tmp_16403_996.unpack2, null
  br i1 %isNull.i.i21, label %erasePositive.exit31, label %next.i.i22

next.i.i22:                                       ; preds = %entry
  %referenceCount.i.i23 = load i64, ptr %tmp_16403_996.unpack2, align 4
  %cond.i.i24 = icmp eq i64 %referenceCount.i.i23, 0
  br i1 %cond.i.i24, label %free.i.i27, label %decr.i.i25

decr.i.i25:                                       ; preds = %next.i.i22
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i23, -1
  store i64 %referenceCount.1.i.i26, ptr %tmp_16403_996.unpack2, align 4
  br label %erasePositive.exit31

free.i.i27:                                       ; preds = %next.i.i22
  %objectEraser.i.i28 = getelementptr i8, ptr %tmp_16403_996.unpack2, i64 8
  %eraser.i.i29 = load ptr, ptr %objectEraser.i.i28, align 8
  %environment.i.i.i30 = getelementptr i8, ptr %tmp_16403_996.unpack2, i64 16
  tail call void %eraser.i.i29(ptr %environment.i.i.i30)
  tail call void @free(ptr nonnull %tmp_16403_996.unpack2)
  br label %erasePositive.exit31

erasePositive.exit31:                             ; preds = %entry, %decr.i.i25, %free.i.i27
  %isNull.i.i10 = icmp eq ptr %tmp_16415_999.unpack5, null
  br i1 %isNull.i.i10, label %erasePositive.exit20, label %next.i.i11

next.i.i11:                                       ; preds = %erasePositive.exit31
  %referenceCount.i.i12 = load i64, ptr %tmp_16415_999.unpack5, align 4
  %cond.i.i13 = icmp eq i64 %referenceCount.i.i12, 0
  br i1 %cond.i.i13, label %free.i.i16, label %decr.i.i14

decr.i.i14:                                       ; preds = %next.i.i11
  %referenceCount.1.i.i15 = add i64 %referenceCount.i.i12, -1
  store i64 %referenceCount.1.i.i15, ptr %tmp_16415_999.unpack5, align 4
  br label %erasePositive.exit20

free.i.i16:                                       ; preds = %next.i.i11
  %objectEraser.i.i17 = getelementptr i8, ptr %tmp_16415_999.unpack5, i64 8
  %eraser.i.i18 = load ptr, ptr %objectEraser.i.i17, align 8
  %environment.i.i.i19 = getelementptr i8, ptr %tmp_16415_999.unpack5, i64 16
  tail call void %eraser.i.i18(ptr %environment.i.i.i19)
  tail call void @free(ptr nonnull %tmp_16415_999.unpack5)
  br label %erasePositive.exit20

erasePositive.exit20:                             ; preds = %erasePositive.exit31, %decr.i.i14, %free.i.i16
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_1000.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit20
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_1000.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_1000.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bodies_2361_12198_1000.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bodies_2361_12198_1000.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bodies_2361_12198_1000.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit20, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -96
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_5_157_408_5214_10531(i64 %i_6_158_409_5215_10944, %Reference %e_3_4809_11809, i64 %tmp_16413, %Pos %tmp_16403, %Pos %bodies_2361_12198, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_158_409_5215_10944, %tmp_16413
  br i1 %z.i, label %label_1032, label %label_832

common.ret:                                       ; preds = %sharePositive.exit30, %sharePositive.exit
  ret void

label_832:                                        ; preds = %entry
  %object.i115 = extractvalue %Pos %tmp_16403, 1
  %isNull.i.i116 = icmp eq ptr %object.i115, null
  br i1 %isNull.i.i116, label %erasePositive.exit126, label %next.i.i117

next.i.i117:                                      ; preds = %label_832
  %referenceCount.i.i118 = load i64, ptr %object.i115, align 4
  %cond.i.i119 = icmp eq i64 %referenceCount.i.i118, 0
  br i1 %cond.i.i119, label %free.i.i122, label %decr.i.i120

decr.i.i120:                                      ; preds = %next.i.i117
  %referenceCount.1.i.i121 = add i64 %referenceCount.i.i118, -1
  store i64 %referenceCount.1.i.i121, ptr %object.i115, align 4
  br label %erasePositive.exit126

free.i.i122:                                      ; preds = %next.i.i117
  %objectEraser.i.i123 = getelementptr i8, ptr %object.i115, i64 8
  %eraser.i.i124 = load ptr, ptr %objectEraser.i.i123, align 8
  %environment.i.i.i125 = getelementptr i8, ptr %object.i115, i64 16
  tail call void %eraser.i.i124(ptr %environment.i.i.i125)
  tail call void @free(ptr nonnull %object.i115)
  br label %erasePositive.exit126

erasePositive.exit126:                            ; preds = %label_832, %decr.i.i120, %free.i.i122
  %object.i110 = extractvalue %Pos %bodies_2361_12198, 1
  %isNull.i.i111 = icmp eq ptr %object.i110, null
  br i1 %isNull.i.i111, label %erasePositive.exit, label %next.i.i112

next.i.i112:                                      ; preds = %erasePositive.exit126
  %referenceCount.i.i113 = load i64, ptr %object.i110, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i113, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i112
  %referenceCount.1.i.i114 = add i64 %referenceCount.i.i113, -1
  store i64 %referenceCount.1.i.i114, ptr %object.i110, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i112
  %objectEraser.i.i = getelementptr i8, ptr %object.i110, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i110, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i110)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit126, %decr.i.i, %free.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_829 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_829(%Pos zeroinitializer, ptr %stack)
  ret void

next.i56:                                         ; preds = %sharePositive.exit30
  %environment.i14 = getelementptr i8, ptr %object.i25, i64 16
  %x_12_170_421_5227_10651 = load double, ptr %environment.i14, align 8, !noalias !0
  %referenceCount.i57 = load i64, ptr %object.i25, align 4
  %cond.i58 = icmp eq i64 %referenceCount.i57, 0
  br i1 %cond.i58, label %free.i61, label %decr.i59

decr.i59:                                         ; preds = %next.i56
  %referenceCount.1.i60 = add i64 %referenceCount.i57, -1
  store i64 %referenceCount.1.i60, ptr %object.i25, align 4
  br label %next.i67

free.i61:                                         ; preds = %next.i56
  %objectEraser.i62 = getelementptr i8, ptr %object.i25, i64 8
  %eraser.i63 = load ptr, ptr %objectEraser.i62, align 8
  tail call void %eraser.i63(ptr nonnull %environment.i14)
  tail call void @free(ptr nonnull %object.i25)
  br label %next.i67

next.i67:                                         ; preds = %decr.i59, %free.i61
  %referenceCount.i.i34 = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i35 = add i64 %referenceCount.i.i34, 1
  store i64 %referenceCount.1.i.i35, ptr %object.i, align 4
  %x_23_181_432_5238_12643_pointer_860 = getelementptr i8, ptr %object.i, i64 24
  %x_23_181_432_5238_12643 = load double, ptr %x_23_181_432_5238_12643_pointer_860, align 8, !noalias !0
  %cond.i69 = icmp eq i64 %referenceCount.1.i.i35, 0
  br i1 %cond.i69, label %free.i72, label %decr.i70

decr.i70:                                         ; preds = %next.i67
  store i64 %referenceCount.i.i34, ptr %object.i, align 4
  br label %next.i78

free.i72:                                         ; preds = %next.i67
  %objectEraser.i73 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i74 = load ptr, ptr %objectEraser.i73, align 8
  tail call void %eraser.i74(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i)
  br label %next.i78

next.i78:                                         ; preds = %free.i72, %decr.i70
  %referenceCount.i.i40 = load i64, ptr %object.i25, align 4
  %referenceCount.1.i.i41 = add i64 %referenceCount.i.i40, 1
  store i64 %referenceCount.1.i.i41, ptr %object.i25, align 4
  %x_31_189_440_5246_11264_pointer_871 = getelementptr i8, ptr %object.i25, i64 24
  %x_31_189_440_5246_11264 = load double, ptr %x_31_189_440_5246_11264_pointer_871, align 8, !noalias !0
  %cond.i80 = icmp eq i64 %referenceCount.1.i.i41, 0
  br i1 %cond.i80, label %free.i83, label %decr.i81

decr.i81:                                         ; preds = %next.i78
  store i64 %referenceCount.i.i40, ptr %object.i25, align 4
  br label %next.i89

free.i83:                                         ; preds = %next.i78
  %objectEraser.i84 = getelementptr i8, ptr %object.i25, i64 8
  %eraser.i85 = load ptr, ptr %objectEraser.i84, align 8
  tail call void %eraser.i85(ptr nonnull %environment.i14)
  tail call void @free(ptr nonnull %object.i25)
  br label %next.i89

next.i89:                                         ; preds = %free.i83, %decr.i81
  %referenceCount.i.i46 = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i47 = add i64 %referenceCount.i.i46, 1
  store i64 %referenceCount.1.i.i47, ptr %object.i, align 4
  %x_42_200_451_5257_11933_pointer_883 = getelementptr i8, ptr %object.i, i64 32
  %x_42_200_451_5257_11933 = load double, ptr %x_42_200_451_5257_11933_pointer_883, align 8, !noalias !0
  %cond.i91 = icmp eq i64 %referenceCount.1.i.i47, 0
  br i1 %cond.i91, label %free.i94, label %decr.i92

decr.i92:                                         ; preds = %next.i89
  store i64 %referenceCount.i.i46, ptr %object.i, align 4
  br label %next.i100

free.i94:                                         ; preds = %next.i89
  %objectEraser.i95 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i96 = load ptr, ptr %objectEraser.i95, align 8
  tail call void %eraser.i96(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %object.i)
  br label %next.i100

next.i100:                                        ; preds = %free.i94, %decr.i92
  %referenceCount.i.i52 = load i64, ptr %object.i25, align 4
  %referenceCount.1.i.i53 = add i64 %referenceCount.i.i52, 1
  store i64 %referenceCount.1.i.i53, ptr %object.i25, align 4
  %x_50_208_459_5265_12449_pointer_894 = getelementptr i8, ptr %object.i25, i64 32
  %x_50_208_459_5265_12449 = load double, ptr %x_50_208_459_5265_12449_pointer_894, align 8, !noalias !0
  %cond.i102 = icmp eq i64 %referenceCount.1.i.i53, 0
  br i1 %cond.i102, label %free.i105, label %decr.i103

decr.i103:                                        ; preds = %next.i100
  store i64 %referenceCount.i.i52, ptr %object.i25, align 4
  br label %eraseObject.exit109

free.i105:                                        ; preds = %next.i100
  %objectEraser.i106 = getelementptr i8, ptr %object.i25, i64 8
  %eraser.i107 = load ptr, ptr %objectEraser.i106, align 8
  tail call void %eraser.i107(ptr nonnull %environment.i14)
  tail call void @free(ptr nonnull %object.i25)
  br label %eraseObject.exit109

eraseObject.exit109:                              ; preds = %decr.i103, %free.i105
  %stackPointer_pointer.i136 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i137 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i136, align 8, !alias.scope !0
  %limit.i138 = load ptr, ptr %limit_pointer.i137, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 112
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i138
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit109
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 112
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i139 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i139, i64 112
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i137, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit109, %realloc.i
  %limit.i145 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i138, %eraseObject.exit109 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit109 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i139, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit109 ]
  %z.i127 = fsub double %x_4_162_413_5219_11895, %x_12_170_421_5227_10651
  %z.i130 = fmul double %z.i127, %z.i127
  %z.i128 = fsub double %x_23_181_432_5238_12643, %x_31_189_440_5246_11264
  %z.i131 = fmul double %z.i128, %z.i128
  %z.i132 = fadd double %z.i130, %z.i131
  %z.i129 = fsub double %x_42_200_451_5257_11933, %x_50_208_459_5265_12449
  %z.i133 = fmul double %z.i129, %z.i129
  %z.i134 = fadd double %z.i132, %z.i133
  %z.i135 = tail call double @llvm.sqrt.f64(double %z.i134)
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i136, align 8
  %e_3_4809_11809.elt = extractvalue %Reference %e_3_4809_11809, 0
  store ptr %e_3_4809_11809.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1010.repack6 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %e_3_4809_11809.elt7 = extractvalue %Reference %e_3_4809_11809, 1
  store i64 %e_3_4809_11809.elt7, ptr %stackPointer_1010.repack6, align 8, !noalias !0
  %tmp_16413_pointer_1012 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_16413, ptr %tmp_16413_pointer_1012, align 4, !noalias !0
  %tmp_16403_pointer_1013 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 0, ptr %tmp_16403_pointer_1013, align 8, !noalias !0
  %tmp_16403_pointer_1013.repack8 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %object.i, ptr %tmp_16403_pointer_1013.repack8, align 8, !noalias !0
  %tmp_16424_pointer_1014 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %z.i135, ptr %tmp_16424_pointer_1014, align 8, !noalias !0
  %i_6_158_409_5215_10944_pointer_1015 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %i_6_158_409_5215_10944, ptr %i_6_158_409_5215_10944_pointer_1015, align 4, !noalias !0
  %tmp_16415_pointer_1016 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 0, ptr %tmp_16415_pointer_1016, align 8, !noalias !0
  %tmp_16415_pointer_1016.repack10 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %object.i25, ptr %tmp_16415_pointer_1016.repack10, align 8, !noalias !0
  %bodies_2361_12198_pointer_1017 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %bodies_2361_12198.elt = extractvalue %Pos %bodies_2361_12198, 0
  store i64 %bodies_2361_12198.elt, ptr %bodies_2361_12198_pointer_1017, align 8, !noalias !0
  %bodies_2361_12198_pointer_1017.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %object.i19, ptr %bodies_2361_12198_pointer_1017.repack12, align 8, !noalias !0
  %returnAddress_pointer_1018 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %sharer_pointer_1019 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %eraser_pointer_1020 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store ptr @returnAddress_899, ptr %returnAddress_pointer_1018, align 8, !noalias !0
  store ptr @sharer_985, ptr %sharer_pointer_1019, align 8, !noalias !0
  store ptr @eraser_1001, ptr %eraser_pointer_1020, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %e_3_4809_11809.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i140 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i141 = load ptr, ptr %base_pointer.i140, align 8
  %varPointer.i = getelementptr i8, ptr %base.i141, i64 %e_3_4809_11809.elt7
  %get_16639 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i146 = icmp ule ptr %nextStackPointer.sink.i, %limit.i145
  tail call void @llvm.assume(i1 %isInside.i146)
  %newStackPointer.i147 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i147, ptr %stackPointer_pointer.i136, align 8, !alias.scope !0
  %returnAddress_1023 = load ptr, ptr %newStackPointer.i147, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1023(double %get_16639, ptr nonnull %stack)
  ret void

next.i:                                           ; preds = %sharePositive.exit
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %x_4_162_413_5219_11895 = load double, ptr %environment.i, align 8, !noalias !0
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
  %object.i25 = extractvalue %Pos %z.i148, 1
  %isNull.i.i26 = icmp eq ptr %object.i25, null
  br i1 %isNull.i.i26, label %sharePositive.exit30, label %next.i.i27

next.i.i27:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i28 = load i64, ptr %object.i25, align 4
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i28, 1
  store i64 %referenceCount.1.i.i29, ptr %object.i25, align 4
  br label %sharePositive.exit30

sharePositive.exit30:                             ; preds = %eraseObject.exit, %next.i.i27
  %tag_844 = extractvalue %Pos %z.i148, 0
  %cond1 = icmp eq i64 %tag_844, 0
  br i1 %cond1, label %next.i56, label %common.ret

label_1032:                                       ; preds = %entry
  %object.i19 = extractvalue %Pos %bodies_2361_12198, 1
  %isNull.i.i20 = icmp eq ptr %object.i19, null
  br i1 %isNull.i.i20, label %sharePositive.exit24, label %next.i.i21

next.i.i21:                                       ; preds = %label_1032
  %referenceCount.i.i22 = load i64, ptr %object.i19, align 4
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, 1
  store i64 %referenceCount.1.i.i23, ptr %object.i19, align 4
  br label %sharePositive.exit24

sharePositive.exit24:                             ; preds = %label_1032, %next.i.i21
  %z.i148 = tail call %Pos @c_array_get(%Pos %bodies_2361_12198, i64 %i_6_158_409_5215_10944)
  %object.i = extractvalue %Pos %tmp_16403, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit24
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit24, %next.i.i
  %tag_833 = extractvalue %Pos %tmp_16403, 0
  %cond = icmp eq i64 %tag_833, 0
  br i1 %cond, label %next.i, label %common.ret
}

define tailcc void @returnAddress_1033(%Pos %__8_496_5302_15827, ptr %stack) {
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
  %i_6_251_5057_10640 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %bodies_2361_12198_pointer_1036 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bodies_2361_12198.unpack = load i64, ptr %bodies_2361_12198_pointer_1036, align 8, !noalias !0
  %bodies_2361_12198.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %bodies_2361_12198.unpack2 = load ptr, ptr %bodies_2361_12198.elt1, align 8, !noalias !0
  %tmp_16401_pointer_1037 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16401 = load i64, ptr %tmp_16401_pointer_1037, align 4, !noalias !0
  %e_3_4809_11809_pointer_1038 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %e_3_4809_11809.unpack = load ptr, ptr %e_3_4809_11809_pointer_1038, align 8, !noalias !0
  %e_3_4809_11809.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %e_3_4809_11809.unpack5 = load i64, ptr %e_3_4809_11809.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__8_496_5302_15827, 1
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
  %0 = insertvalue %Reference poison, ptr %e_3_4809_11809.unpack, 0
  %e_3_4809_118096 = insertvalue %Reference %0, i64 %e_3_4809_11809.unpack5, 1
  %1 = insertvalue %Pos poison, i64 %bodies_2361_12198.unpack, 0
  %bodies_2361_121983 = insertvalue %Pos %1, ptr %bodies_2361_12198.unpack2, 1
  %z.i = add i64 %i_6_251_5057_10640, 1
  musttail call tailcc void @loop_5_250_5056_11393(i64 %z.i, %Pos %bodies_2361_121983, i64 %tmp_16401, %Reference %e_3_4809_118096, ptr nonnull %stack)
  ret void
}

define void @sharer_1043(ptr %stackPointer) {
entry:
  %bodies_2361_12198_1040.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %bodies_2361_12198_1040.unpack2 = load ptr, ptr %bodies_2361_12198_1040.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_1040.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_1040.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_1040.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1053(ptr %stackPointer) {
entry:
  %bodies_2361_12198_1050.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %bodies_2361_12198_1050.unpack2 = load ptr, ptr %bodies_2361_12198_1050.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_1050.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_1050.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_1050.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bodies_2361_12198_1050.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bodies_2361_12198_1050.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bodies_2361_12198_1050.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_818(%Pos %__69_320_5126_15729, ptr %stack) {
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
  %tmp_16403.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16403.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_16403.unpack2 = load ptr, ptr %tmp_16403.elt1, align 8, !noalias !0
  %i_6_251_5057_10640_pointer_821 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %i_6_251_5057_10640 = load i64, ptr %i_6_251_5057_10640_pointer_821, align 4, !noalias !0
  %bodies_2361_12198_pointer_822 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bodies_2361_12198.unpack = load i64, ptr %bodies_2361_12198_pointer_822, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %bodies_2361_12198.unpack, 0
  %bodies_2361_12198.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %bodies_2361_12198.unpack5 = load ptr, ptr %bodies_2361_12198.elt4, align 8, !noalias !0
  %bodies_2361_121986 = insertvalue %Pos %0, ptr %bodies_2361_12198.unpack5, 1
  %tmp_16401_pointer_823 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16401 = load i64, ptr %tmp_16401_pointer_823, align 4, !noalias !0
  %e_3_4809_11809_pointer_824 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %e_3_4809_11809.unpack = load ptr, ptr %e_3_4809_11809_pointer_824, align 8, !noalias !0
  %e_3_4809_11809.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %e_3_4809_11809.unpack8 = load i64, ptr %e_3_4809_11809.elt7, align 8, !noalias !0
  %object.i = extractvalue %Pos %__69_320_5126_15729, 1
  %isNull.i.i19 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i19, label %erasePositive.exit, label %next.i.i20

next.i.i20:                                       ; preds = %entry
  %referenceCount.i.i21 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i21, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i20
  %referenceCount.1.i.i22 = add i64 %referenceCount.i.i21, -1
  store i64 %referenceCount.1.i.i22, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i20
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i14 = icmp eq ptr %bodies_2361_12198.unpack5, null
  br i1 %isNull.i.i14, label %sharePositive.exit18.thread, label %next.i.i

sharePositive.exit18.thread:                      ; preds = %erasePositive.exit
  %z.i2833 = tail call i64 @c_array_size(%Pos %bodies_2361_121986)
  br label %sharePositive.exit

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i16 = load i64, ptr %bodies_2361_12198.unpack5, align 4
  %referenceCount.1.i.i17 = add i64 %referenceCount.i.i16, 1
  store i64 %referenceCount.1.i.i17, ptr %bodies_2361_12198.unpack5, align 4
  %z.i28 = tail call i64 @c_array_size(%Pos %bodies_2361_121986)
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit18.thread, %next.i.i
  %z.i2834 = phi i64 [ %z.i2833, %sharePositive.exit18.thread ], [ %z.i28, %next.i.i ]
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i31 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i31
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
  %newStackPointer.i32 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i32, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i32, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  %z.i = add i64 %i_6_251_5057_10640, 1
  %1 = insertvalue %Reference poison, ptr %e_3_4809_11809.unpack, 0
  %e_3_4809_118099 = insertvalue %Reference %1, i64 %e_3_4809_11809.unpack8, 1
  %2 = insertvalue %Pos poison, i64 %tmp_16403.unpack, 0
  %tmp_164033 = insertvalue %Pos %2, ptr %tmp_16403.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_251_5057_10640, ptr %common.ret.op.i, align 4, !noalias !0
  %bodies_2361_12198_pointer_1061 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %bodies_2361_12198.unpack, ptr %bodies_2361_12198_pointer_1061, align 8, !noalias !0
  %bodies_2361_12198_pointer_1061.repack10 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %bodies_2361_12198.unpack5, ptr %bodies_2361_12198_pointer_1061.repack10, align 8, !noalias !0
  %tmp_16401_pointer_1062 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_16401, ptr %tmp_16401_pointer_1062, align 4, !noalias !0
  %e_3_4809_11809_pointer_1063 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %e_3_4809_11809.unpack, ptr %e_3_4809_11809_pointer_1063, align 8, !noalias !0
  %e_3_4809_11809_pointer_1063.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %e_3_4809_11809.unpack8, ptr %e_3_4809_11809_pointer_1063.repack12, align 8, !noalias !0
  %returnAddress_pointer_1064 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1065 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1066 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_1033, ptr %returnAddress_pointer_1064, align 8, !noalias !0
  store ptr @sharer_1043, ptr %sharer_pointer_1065, align 8, !noalias !0
  store ptr @eraser_1053, ptr %eraser_pointer_1066, align 8, !noalias !0
  musttail call tailcc void @loop_5_157_408_5214_10531(i64 %z.i, %Reference %e_3_4809_118099, i64 %z.i2834, %Pos %tmp_164033, %Pos %bodies_2361_121986, ptr nonnull %stack)
  ret void
}

define void @sharer_1072(ptr %stackPointer) {
entry:
  %tmp_16403_1067.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_16403_1067.unpack2 = load ptr, ptr %tmp_16403_1067.elt1, align 8, !noalias !0
  %bodies_2361_12198_1069.elt4 = getelementptr i8, ptr %stackPointer, i64 -32
  %bodies_2361_12198_1069.unpack5 = load ptr, ptr %bodies_2361_12198_1069.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_16403_1067.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_16403_1067.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %tmp_16403_1067.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_1069.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_1069.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_1069.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1084(ptr %stackPointer) {
entry:
  %tmp_16403_1079.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_16403_1079.unpack2 = load ptr, ptr %tmp_16403_1079.elt1, align 8, !noalias !0
  %bodies_2361_12198_1081.elt4 = getelementptr i8, ptr %stackPointer, i64 -32
  %bodies_2361_12198_1081.unpack5 = load ptr, ptr %bodies_2361_12198_1081.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_16403_1079.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_16403_1079.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_16403_1079.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_16403_1079.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_16403_1079.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_16403_1079.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_1081.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_1081.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_1081.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bodies_2361_12198_1081.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bodies_2361_12198_1081.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bodies_2361_12198_1081.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_734(double %v_r_3116_4_255_5061_11033, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i128 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i128)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16403.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16403.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_16403.unpack8 = load ptr, ptr %tmp_16403.elt7, align 8, !noalias !0
  %i_6_251_5057_10640_pointer_737 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %i_6_251_5057_10640 = load i64, ptr %i_6_251_5057_10640_pointer_737, align 4, !noalias !0
  %bodies_2361_12198_pointer_738 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bodies_2361_12198.unpack = load i64, ptr %bodies_2361_12198_pointer_738, align 8, !noalias !0
  %bodies_2361_12198.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %bodies_2361_12198.unpack11 = load ptr, ptr %bodies_2361_12198.elt10, align 8, !noalias !0
  %tmp_16401_pointer_739 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16401 = load i64, ptr %tmp_16401_pointer_739, align 4, !noalias !0
  %e_3_4809_11809_pointer_740 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %e_3_4809_11809.unpack = load ptr, ptr %e_3_4809_11809_pointer_740, align 8, !noalias !0
  %e_3_4809_11809.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %e_3_4809_11809.unpack14 = load i64, ptr %e_3_4809_11809.elt13, align 8, !noalias !0
  %isNull.i.i53 = icmp eq ptr %tmp_16403.unpack8, null
  br i1 %isNull.i.i53, label %sharePositive.exit57, label %next.i.i54

next.i.i54:                                       ; preds = %entry
  %referenceCount.i.i55 = load i64, ptr %tmp_16403.unpack8, align 4
  %referenceCount.1.i.i56 = add i64 %referenceCount.i.i55, 1
  store i64 %referenceCount.1.i.i56, ptr %tmp_16403.unpack8, align 4
  br label %sharePositive.exit57

sharePositive.exit57:                             ; preds = %entry, %next.i.i54
  %cond = icmp eq i64 %tmp_16403.unpack, 0
  br i1 %cond, label %next.i, label %common.ret

common.ret:                                       ; preds = %sharePositive.exit57
  ret void

next.i:                                           ; preds = %sharePositive.exit57
  %environment.i = getelementptr i8, ptr %tmp_16403.unpack8, i64 16
  %x_11_262_5068_12517_pointer_751 = getelementptr i8, ptr %tmp_16403.unpack8, i64 64
  %x_11_262_5068_12517 = load double, ptr %x_11_262_5068_12517_pointer_751, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %tmp_16403.unpack8, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  br label %next.i59

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %tmp_16403.unpack8, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16403.unpack8)
  %referenceCount.i.i.pre = load i64, ptr %tmp_16403.unpack8, align 4
  br label %next.i59

next.i59:                                         ; preds = %free.i, %decr.i
  %referenceCount.i.i = phi i64 [ %referenceCount.i.i.pre, %free.i ], [ %referenceCount.1.i, %decr.i ]
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16403.unpack8, align 4
  %x_16_267_5073_11114_pointer_759 = getelementptr i8, ptr %tmp_16403.unpack8, i64 40
  %x_16_267_5073_11114 = load double, ptr %x_16_267_5073_11114_pointer_759, align 8, !noalias !0
  %cond.i61 = icmp eq i64 %referenceCount.1.i.i, 0
  br i1 %cond.i61, label %free.i64, label %next.i70

free.i64:                                         ; preds = %next.i59
  %objectEraser.i65 = getelementptr i8, ptr %tmp_16403.unpack8, i64 8
  %eraser.i66 = load ptr, ptr %objectEraser.i65, align 8
  tail call void %eraser.i66(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16403.unpack8)
  %referenceCount.i.i30.pre = load i64, ptr %tmp_16403.unpack8, align 4
  %x_24_275_5081_11173.pre = load double, ptr %x_16_267_5073_11114_pointer_759, align 8, !noalias !0
  br label %next.i70

next.i70:                                         ; preds = %next.i59, %free.i64
  %x_24_275_5081_11173 = phi double [ %x_24_275_5081_11173.pre, %free.i64 ], [ %x_16_267_5073_11114, %next.i59 ]
  %referenceCount.i.i30 = phi i64 [ %referenceCount.i.i30.pre, %free.i64 ], [ %referenceCount.i.i, %next.i59 ]
  %referenceCount.1.i.i31 = add i64 %referenceCount.i.i30, 1
  store i64 %referenceCount.1.i.i31, ptr %tmp_16403.unpack8, align 4
  %cond.i72 = icmp eq i64 %referenceCount.1.i.i31, 0
  br i1 %cond.i72, label %free.i75, label %next.i81

free.i75:                                         ; preds = %next.i70
  %objectEraser.i76 = getelementptr i8, ptr %tmp_16403.unpack8, i64 8
  %eraser.i77 = load ptr, ptr %objectEraser.i76, align 8
  tail call void %eraser.i77(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16403.unpack8)
  %referenceCount.i.i35.pre = load i64, ptr %tmp_16403.unpack8, align 4
  br label %next.i81

next.i81:                                         ; preds = %next.i70, %free.i75
  %referenceCount.i.i35 = phi i64 [ %referenceCount.i.i35.pre, %free.i75 ], [ %referenceCount.i.i30, %next.i70 ]
  %referenceCount.1.i.i36 = add i64 %referenceCount.i.i35, 1
  store i64 %referenceCount.1.i.i36, ptr %tmp_16403.unpack8, align 4
  %x_33_284_5090_11652_pointer_782 = getelementptr i8, ptr %tmp_16403.unpack8, i64 48
  %x_33_284_5090_11652 = load double, ptr %x_33_284_5090_11652_pointer_782, align 8, !noalias !0
  %cond.i83 = icmp eq i64 %referenceCount.1.i.i36, 0
  br i1 %cond.i83, label %free.i86, label %next.i92

free.i86:                                         ; preds = %next.i81
  %objectEraser.i87 = getelementptr i8, ptr %tmp_16403.unpack8, i64 8
  %eraser.i88 = load ptr, ptr %objectEraser.i87, align 8
  tail call void %eraser.i88(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16403.unpack8)
  %referenceCount.i.i40.pre = load i64, ptr %tmp_16403.unpack8, align 4
  %x_41_292_5098_10581.pre = load double, ptr %x_33_284_5090_11652_pointer_782, align 8, !noalias !0
  br label %next.i92

next.i92:                                         ; preds = %next.i81, %free.i86
  %x_41_292_5098_10581 = phi double [ %x_41_292_5098_10581.pre, %free.i86 ], [ %x_33_284_5090_11652, %next.i81 ]
  %referenceCount.i.i40 = phi i64 [ %referenceCount.i.i40.pre, %free.i86 ], [ %referenceCount.i.i35, %next.i81 ]
  %referenceCount.1.i.i41 = add i64 %referenceCount.i.i40, 1
  store i64 %referenceCount.1.i.i41, ptr %tmp_16403.unpack8, align 4
  %cond.i94 = icmp eq i64 %referenceCount.1.i.i41, 0
  br i1 %cond.i94, label %free.i97, label %next.i103

free.i97:                                         ; preds = %next.i92
  %objectEraser.i98 = getelementptr i8, ptr %tmp_16403.unpack8, i64 8
  %eraser.i99 = load ptr, ptr %objectEraser.i98, align 8
  tail call void %eraser.i99(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16403.unpack8)
  %referenceCount.i.i45.pre = load i64, ptr %tmp_16403.unpack8, align 4
  br label %next.i103

next.i103:                                        ; preds = %next.i92, %free.i97
  %referenceCount.i.i45 = phi i64 [ %referenceCount.i.i45.pre, %free.i97 ], [ %referenceCount.i.i40, %next.i92 ]
  %referenceCount.1.i.i46 = add i64 %referenceCount.i.i45, 1
  store i64 %referenceCount.1.i.i46, ptr %tmp_16403.unpack8, align 4
  %x_50_301_5107_12484_pointer_805 = getelementptr i8, ptr %tmp_16403.unpack8, i64 56
  %x_50_301_5107_12484 = load double, ptr %x_50_301_5107_12484_pointer_805, align 8, !noalias !0
  %cond.i105 = icmp eq i64 %referenceCount.1.i.i46, 0
  br i1 %cond.i105, label %free.i108, label %next.i114

free.i108:                                        ; preds = %next.i103
  %objectEraser.i109 = getelementptr i8, ptr %tmp_16403.unpack8, i64 8
  %eraser.i110 = load ptr, ptr %objectEraser.i109, align 8
  tail call void %eraser.i110(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16403.unpack8)
  %referenceCount.i.i50.pre = load i64, ptr %tmp_16403.unpack8, align 4
  %x_58_309_5115_12426.pre = load double, ptr %x_50_301_5107_12484_pointer_805, align 8, !noalias !0
  br label %next.i114

next.i114:                                        ; preds = %next.i103, %free.i108
  %x_58_309_5115_12426 = phi double [ %x_58_309_5115_12426.pre, %free.i108 ], [ %x_50_301_5107_12484, %next.i103 ]
  %referenceCount.i.i50 = phi i64 [ %referenceCount.i.i50.pre, %free.i108 ], [ %referenceCount.i.i45, %next.i103 ]
  %referenceCount.1.i.i51 = add i64 %referenceCount.i.i50, 1
  store i64 %referenceCount.1.i.i51, ptr %tmp_16403.unpack8, align 4
  %cond.i116 = icmp eq i64 %referenceCount.1.i.i51, 0
  br i1 %cond.i116, label %free.i119, label %decr.i117

decr.i117:                                        ; preds = %next.i114
  store i64 %referenceCount.i.i50, ptr %tmp_16403.unpack8, align 4
  br label %eraseObject.exit123

free.i119:                                        ; preds = %next.i114
  %objectEraser.i120 = getelementptr i8, ptr %tmp_16403.unpack8, i64 8
  %eraser.i121 = load ptr, ptr %objectEraser.i120, align 8
  tail call void %eraser.i121(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16403.unpack8)
  br label %eraseObject.exit123

eraseObject.exit123:                              ; preds = %decr.i117, %free.i119
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i138 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i138
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit123
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
  %newStackPointer.i139 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i139, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit123, %realloc.i
  %limit.i145 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i138, %eraseObject.exit123 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit123 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i139, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit123 ]
  %z.i = fmul double %x_11_262_5068_12517, 5.000000e-01
  %z.i129 = fmul double %x_16_267_5073_11114, %x_24_275_5081_11173
  %z.i130 = fmul double %x_33_284_5090_11652, %x_41_292_5098_10581
  %z.i131 = fadd double %z.i129, %z.i130
  %z.i132 = fmul double %x_50_301_5107_12484, %x_58_309_5115_12426
  %z.i133 = fadd double %z.i131, %z.i132
  %z.i134 = fmul double %z.i, %z.i133
  %z.i135 = fadd double %z.i134, %v_r_3116_4_255_5061_11033
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 0, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1091.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_16403.unpack8, ptr %stackPointer_1091.repack16, align 8, !noalias !0
  %i_6_251_5057_10640_pointer_1093 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_6_251_5057_10640, ptr %i_6_251_5057_10640_pointer_1093, align 4, !noalias !0
  %bodies_2361_12198_pointer_1094 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %bodies_2361_12198.unpack, ptr %bodies_2361_12198_pointer_1094, align 8, !noalias !0
  %bodies_2361_12198_pointer_1094.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %bodies_2361_12198.unpack11, ptr %bodies_2361_12198_pointer_1094.repack18, align 8, !noalias !0
  %tmp_16401_pointer_1095 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_16401, ptr %tmp_16401_pointer_1095, align 4, !noalias !0
  %e_3_4809_11809_pointer_1096 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %e_3_4809_11809.unpack, ptr %e_3_4809_11809_pointer_1096, align 8, !noalias !0
  %e_3_4809_11809_pointer_1096.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %e_3_4809_11809.unpack14, ptr %e_3_4809_11809_pointer_1096.repack20, align 8, !noalias !0
  %returnAddress_pointer_1097 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_1098 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_1099 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_818, ptr %returnAddress_pointer_1097, align 8, !noalias !0
  store ptr @sharer_1072, ptr %sharer_pointer_1098, align 8, !noalias !0
  store ptr @eraser_1084, ptr %eraser_pointer_1099, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %e_3_4809_11809.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i140 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i141 = load ptr, ptr %base_pointer.i140, align 8
  %varPointer.i = getelementptr i8, ptr %base.i141, i64 %e_3_4809_11809.unpack14
  store double %z.i135, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i146 = icmp ule ptr %nextStackPointer.sink.i, %limit.i145
  tail call void @llvm.assume(i1 %isInside.i146)
  %newStackPointer.i147 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i147, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1103 = load ptr, ptr %newStackPointer.i147, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1103(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_250_5056_11393(i64 %i_6_251_5057_10640, %Pos %bodies_2361_12198, i64 %tmp_16401, %Reference %e_3_4809_11809, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_251_5057_10640, %tmp_16401
  %object.i = extractvalue %Pos %bodies_2361_12198, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %z.i, label %label_1137, label %label_733

label_733:                                        ; preds = %entry
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i9

next.i.i9:                                        ; preds = %label_733
  %referenceCount.i.i10 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i10, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i9
  %referenceCount.1.i.i11 = add i64 %referenceCount.i.i10, -1
  store i64 %referenceCount.1.i.i11, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i9
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_733, %decr.i.i, %free.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_730 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_730(%Pos zeroinitializer, ptr %stack)
  ret void

label_1137:                                       ; preds = %entry
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1137
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_1137, %next.i.i
  %z.i12 = tail call %Pos @c_array_get(%Pos %bodies_2361_12198, i64 %i_6_251_5057_10640)
  %stackPointer_pointer.i13 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i14 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i13, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i14, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i15
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
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
  %newStackPointer.i16 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i16, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i14, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %limit.i22 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i15, %sharePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i16, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i13, align 8
  %pureApp_16608.elt = extractvalue %Pos %z.i12, 0
  store i64 %pureApp_16608.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1123.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %pureApp_16608.elt2 = extractvalue %Pos %z.i12, 1
  store ptr %pureApp_16608.elt2, ptr %stackPointer_1123.repack1, align 8, !noalias !0
  %i_6_251_5057_10640_pointer_1125 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_6_251_5057_10640, ptr %i_6_251_5057_10640_pointer_1125, align 4, !noalias !0
  %bodies_2361_12198_pointer_1126 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %bodies_2361_12198.elt = extractvalue %Pos %bodies_2361_12198, 0
  store i64 %bodies_2361_12198.elt, ptr %bodies_2361_12198_pointer_1126, align 8, !noalias !0
  %bodies_2361_12198_pointer_1126.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %object.i, ptr %bodies_2361_12198_pointer_1126.repack3, align 8, !noalias !0
  %tmp_16401_pointer_1127 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_16401, ptr %tmp_16401_pointer_1127, align 4, !noalias !0
  %e_3_4809_11809_pointer_1128 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %e_3_4809_11809.elt = extractvalue %Reference %e_3_4809_11809, 0
  store ptr %e_3_4809_11809.elt, ptr %e_3_4809_11809_pointer_1128, align 8, !noalias !0
  %e_3_4809_11809_pointer_1128.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %e_3_4809_11809.elt6 = extractvalue %Reference %e_3_4809_11809, 1
  store i64 %e_3_4809_11809.elt6, ptr %e_3_4809_11809_pointer_1128.repack5, align 8, !noalias !0
  %returnAddress_pointer_1129 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_1130 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_1131 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_734, ptr %returnAddress_pointer_1129, align 8, !noalias !0
  store ptr @sharer_1072, ptr %sharer_pointer_1130, align 8, !noalias !0
  store ptr @eraser_1084, ptr %eraser_pointer_1131, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %e_3_4809_11809.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i17 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i18 = load ptr, ptr %base_pointer.i17, align 8
  %varPointer.i = getelementptr i8, ptr %base.i18, i64 %e_3_4809_11809.elt6
  %get_16643 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i23 = icmp ule ptr %nextStackPointer.sink.i, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i13, align 8, !alias.scope !0
  %returnAddress_1134 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1134(double %get_16643, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1138(%Pos %__498_5304_15828, ptr %stack) {
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
  %e_3_4809_11809.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %e_3_4809_11809.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %e_3_4809_11809.unpack2 = load i64, ptr %e_3_4809_11809.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__498_5304_15828, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %e_3_4809_11809.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %e_3_4809_11809.unpack2
  %get_16644 = load double, ptr %varPointer.i, align 8, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1143 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1143(double %get_16644, ptr nonnull %stack)
  ret void
}

define void @sharer_1147(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1151(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_691(%Pos %v_r_3141_4807_15546, ptr %stack) {
entry:
  %stackPointer_pointer.i10 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i11 = load ptr, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i11, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i16 = icmp ule ptr %stackPointer.i11, %limit.i
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i11, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %bodies_2361_12198.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %bodies_2361_12198.unpack, 0
  %bodies_2361_12198.elt1 = getelementptr i8, ptr %stackPointer.i11, i64 -8
  %bodies_2361_12198.unpack2 = load ptr, ptr %bodies_2361_12198.elt1, align 8, !noalias !0
  %bodies_2361_121983 = insertvalue %Pos %0, ptr %bodies_2361_12198.unpack2, 1
  %object.i = extractvalue %Pos %v_r_3141_4807_15546, 1
  %isNull.i.i6 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i6, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %entry
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

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %limit.i19 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 24
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i19
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i20 = getelementptr i8, ptr %stack, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i22 = ptrtoint ptr %base.i21 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i22
  %nextSize.i = add i64 %size.i, 24
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i21, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i23 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i23, i64 24
  store ptr %newBase.i, ptr %base_pointer.i20, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i28 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i19, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i23, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i10, align 8
  %sharer_pointer_704 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_705 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_694, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_698, ptr %sharer_pointer_704, align 8, !noalias !0
  store ptr @eraser_700, ptr %eraser_pointer_705, align 8, !noalias !0
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i10, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i24 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i29 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i30 = icmp ugt ptr %nextStackPointer.i29, %limit.i28
  br i1 %isInside.not.i30, label %realloc.i33, label %stackAllocate.exit47

realloc.i33:                                      ; preds = %stackAllocate.exit
  %nextSize.i39 = add i64 %offset.i, 32
  %leadingZeros.i.i40 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i39, i1 false)
  %numBits.i.i41 = sub nuw nsw i64 64, %leadingZeros.i.i40
  %result.i.i42 = shl nuw i64 1, %numBits.i.i41
  %newBase.i43 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i42)
  %newLimit.i44 = getelementptr i8, ptr %newBase.i43, i64 %result.i.i42
  %newStackPointer.i45 = getelementptr i8, ptr %newBase.i43, i64 %offset.i
  %newNextStackPointer.i46 = getelementptr i8, ptr %newStackPointer.i45, i64 32
  store ptr %newBase.i43, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i44, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit47

stackAllocate.exit47:                             ; preds = %stackAllocate.exit, %realloc.i33
  %nextStackPointer.sink.i31 = phi ptr [ %newNextStackPointer.i46, %realloc.i33 ], [ %nextStackPointer.i29, %stackAllocate.exit ]
  %common.ret.op.i32 = phi ptr [ %newStackPointer.i45, %realloc.i33 ], [ %stackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i31, ptr %stackPointer_pointer.i10, align 8
  store double 0.000000e+00, ptr %common.ret.op.i32, align 8, !noalias !0
  %returnAddress_pointer_723 = getelementptr i8, ptr %common.ret.op.i32, i64 8
  %sharer_pointer_724 = getelementptr i8, ptr %common.ret.op.i32, i64 16
  %eraser_pointer_725 = getelementptr i8, ptr %common.ret.op.i32, i64 24
  store ptr @returnAddress_706, ptr %returnAddress_pointer_723, align 8, !noalias !0
  store ptr @sharer_714, ptr %sharer_pointer_724, align 8, !noalias !0
  store ptr @eraser_718, ptr %eraser_pointer_725, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit47
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit47, %next.i.i
  %z.i = tail call i64 @c_array_size(%Pos %bodies_2361_121983)
  %currentStackPointer.i50 = load ptr, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %limit.i51 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i52 = getelementptr i8, ptr %currentStackPointer.i50, i64 40
  %isInside.not.i53 = icmp ugt ptr %nextStackPointer.i52, %limit.i51
  br i1 %isInside.not.i53, label %realloc.i56, label %stackAllocate.exit70

realloc.i56:                                      ; preds = %sharePositive.exit
  %base.i58 = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i59 = ptrtoint ptr %currentStackPointer.i50 to i64
  %intBase.i60 = ptrtoint ptr %base.i58 to i64
  %size.i61 = sub i64 %intStackPointer.i59, %intBase.i60
  %nextSize.i62 = add i64 %size.i61, 40
  %leadingZeros.i.i63 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i62, i1 false)
  %numBits.i.i64 = sub nuw nsw i64 64, %leadingZeros.i.i63
  %result.i.i65 = shl nuw i64 1, %numBits.i.i64
  %newBase.i66 = tail call ptr @realloc(ptr %base.i58, i64 %result.i.i65)
  %newLimit.i67 = getelementptr i8, ptr %newBase.i66, i64 %result.i.i65
  %newStackPointer.i68 = getelementptr i8, ptr %newBase.i66, i64 %size.i61
  %newNextStackPointer.i69 = getelementptr i8, ptr %newStackPointer.i68, i64 40
  store ptr %newBase.i66, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i67, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit70

stackAllocate.exit70:                             ; preds = %sharePositive.exit, %realloc.i56
  %nextStackPointer.sink.i54 = phi ptr [ %newNextStackPointer.i69, %realloc.i56 ], [ %nextStackPointer.i52, %sharePositive.exit ]
  %common.ret.op.i55 = phi ptr [ %newStackPointer.i68, %realloc.i56 ], [ %currentStackPointer.i50, %sharePositive.exit ]
  %reference..1.i = insertvalue %Reference undef, ptr %prompt.i24, 0
  %reference.i = insertvalue %Reference %reference..1.i, i64 %offset.i, 1
  store ptr %nextStackPointer.sink.i54, ptr %stackPointer_pointer.i10, align 8
  store ptr %prompt.i24, ptr %common.ret.op.i55, align 8, !noalias !0
  %stackPointer_1154.repack4 = getelementptr inbounds i8, ptr %common.ret.op.i55, i64 8
  store i64 %offset.i, ptr %stackPointer_1154.repack4, align 8, !noalias !0
  %returnAddress_pointer_1156 = getelementptr i8, ptr %common.ret.op.i55, i64 16
  %sharer_pointer_1157 = getelementptr i8, ptr %common.ret.op.i55, i64 24
  %eraser_pointer_1158 = getelementptr i8, ptr %common.ret.op.i55, i64 32
  store ptr @returnAddress_1138, ptr %returnAddress_pointer_1156, align 8, !noalias !0
  store ptr @sharer_1147, ptr %sharer_pointer_1157, align 8, !noalias !0
  store ptr @eraser_1151, ptr %eraser_pointer_1158, align 8, !noalias !0
  musttail call tailcc void @loop_5_250_5056_11393(i64 0, %Pos %bodies_2361_121983, i64 %z.i, %Reference %reference.i, ptr nonnull %stack)
  ret void
}

define void @sharer_1160(ptr %stackPointer) {
entry:
  %bodies_2361_12198_1159.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %bodies_2361_12198_1159.unpack2 = load ptr, ptr %bodies_2361_12198_1159.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_1159.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_1159.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_1159.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1164(ptr %stackPointer) {
entry:
  %bodies_2361_12198_1163.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %bodies_2361_12198_1163.unpack2 = load ptr, ptr %bodies_2361_12198_1163.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bodies_2361_12198_1163.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %bodies_2361_12198_1163.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bodies_2361_12198_1163.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bodies_2361_12198_1163.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bodies_2361_12198_1163.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bodies_2361_12198_1163.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_95(%Pos %bodies_2361_12198, ptr %stack) {
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
  %tmp_16435 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %object.i = extractvalue %Pos %bodies_2361_12198, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  %currentStackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i10.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %limit.i10 = phi ptr [ %limit.i, %entry ], [ %limit.i10.pre, %next.i.i ]
  %currentStackPointer.i = phi ptr [ %newStackPointer.i, %entry ], [ %currentStackPointer.i.pre, %next.i.i ]
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i10
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
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
  %newStackPointer.i11 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i11, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i11, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %bodies_2361_12198.elt = extractvalue %Pos %bodies_2361_12198, 0
  store i64 %bodies_2361_12198.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1167.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_1167.repack1, align 8, !noalias !0
  %returnAddress_pointer_1169 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_1170 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_1171 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_691, ptr %returnAddress_pointer_1169, align 8, !noalias !0
  store ptr @sharer_1160, ptr %sharer_pointer_1170, align 8, !noalias !0
  store ptr @eraser_1164, ptr %eraser_pointer_1171, align 8, !noalias !0
  musttail call tailcc void @loop_5_3583_12010(i64 0, i64 %tmp_16435, %Pos %bodies_2361_12198, ptr nonnull %stack)
  ret void
}

define void @sharer_1173(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1177(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1185(%Pos %returnValue_1186, ptr %stack) {
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
  %returnAddress_1189 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1189(%Pos %returnValue_1186, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1199(%Pos %returnValue_1200, ptr %stack) {
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
  %returnAddress_1203 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1203(%Pos %returnValue_1200, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1213(%Pos %returnValue_1214, ptr %stack) {
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
  %returnAddress_1217 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1217(%Pos %returnValue_1214, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1346(%Pos %__8_13_201_2269_13987, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -80
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16320.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16320.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_16320.unpack2 = load ptr, ptr %tmp_16320.elt1, align 8, !noalias !0
  %py_11_2079_10749_pointer_1349 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %py_11_2079_10749.unpack = load ptr, ptr %py_11_2079_10749_pointer_1349, align 8, !noalias !0
  %py_11_2079_10749.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %py_11_2079_10749.unpack5 = load i64, ptr %py_11_2079_10749.elt4, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1350 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %pz_13_2081_11683.unpack = load ptr, ptr %pz_13_2081_11683_pointer_1350, align 8, !noalias !0
  %pz_13_2081_11683.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %pz_13_2081_11683.unpack8 = load i64, ptr %pz_13_2081_11683.elt7, align 8, !noalias !0
  %tmp_16326_pointer_1351 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_16326 = load i64, ptr %tmp_16326_pointer_1351, align 4, !noalias !0
  %px_9_2077_11716_pointer_1352 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %px_9_2077_11716.unpack = load ptr, ptr %px_9_2077_11716_pointer_1352, align 8, !noalias !0
  %px_9_2077_11716.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %px_9_2077_11716.unpack11 = load i64, ptr %px_9_2077_11716.elt10, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1353 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1353, align 4, !noalias !0
  %object.i = extractvalue %Pos %__8_13_201_2269_13987, 1
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
  %0 = insertvalue %Reference poison, ptr %px_9_2077_11716.unpack, 0
  %px_9_2077_1171612 = insertvalue %Reference %0, i64 %px_9_2077_11716.unpack11, 1
  %1 = insertvalue %Reference poison, ptr %pz_13_2081_11683.unpack, 0
  %pz_13_2081_116839 = insertvalue %Reference %1, i64 %pz_13_2081_11683.unpack8, 1
  %2 = insertvalue %Reference poison, ptr %py_11_2079_10749.unpack, 0
  %py_11_2079_107496 = insertvalue %Reference %2, i64 %py_11_2079_10749.unpack5, 1
  %3 = insertvalue %Pos poison, i64 %tmp_16320.unpack, 0
  %tmp_163203 = insertvalue %Pos %3, ptr %tmp_16320.unpack2, 1
  %z.i = add i64 %i_6_10_139_2207_11222, 1
  musttail call tailcc void @loop_5_9_138_2206_10607(i64 %z.i, %Pos %tmp_163203, %Reference %py_11_2079_107496, %Reference %pz_13_2081_116839, i64 %tmp_16326, %Reference %px_9_2077_1171612, ptr nonnull %stack)
  ret void
}

define void @sharer_1360(ptr %stackPointer) {
entry:
  %tmp_16320_1354.elt1 = getelementptr i8, ptr %stackPointer, i64 -72
  %tmp_16320_1354.unpack2 = load ptr, ptr %tmp_16320_1354.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1354.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1354.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1354.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1374(ptr %stackPointer) {
entry:
  %tmp_16320_1368.elt1 = getelementptr i8, ptr %stackPointer, i64 -72
  %tmp_16320_1368.unpack2 = load ptr, ptr %tmp_16320_1368.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1368.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1368.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1368.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_16320_1368.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_16320_1368.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_16320_1368.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -88
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1315(double %v_r_3056_42_182_2250_10552, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16320.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16320.elt2 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %tmp_16320.unpack3 = load ptr, ptr %tmp_16320.elt2, align 8, !noalias !0
  %py_11_2079_10749_pointer_1318 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %py_11_2079_10749.unpack = load ptr, ptr %py_11_2079_10749_pointer_1318, align 8, !noalias !0
  %py_11_2079_10749.elt5 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %py_11_2079_10749.unpack6 = load i64, ptr %py_11_2079_10749.elt5, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1319 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %pz_13_2081_11683.unpack = load ptr, ptr %pz_13_2081_11683_pointer_1319, align 8, !noalias !0
  %pz_13_2081_11683.elt8 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %pz_13_2081_11683.unpack9 = load i64, ptr %pz_13_2081_11683.elt8, align 8, !noalias !0
  %tmp_16326_pointer_1320 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_16326 = load i64, ptr %tmp_16326_pointer_1320, align 4, !noalias !0
  %px_9_2077_11716_pointer_1321 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %px_9_2077_11716.unpack = load ptr, ptr %px_9_2077_11716_pointer_1321, align 8, !noalias !0
  %px_9_2077_11716.elt11 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %px_9_2077_11716.unpack12 = load i64, ptr %px_9_2077_11716.elt11, align 8, !noalias !0
  %tmp_16328_pointer_1322 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16328.unpack = load i64, ptr %tmp_16328_pointer_1322, align 8, !noalias !0
  %tmp_16328.elt14 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_16328.unpack15 = load ptr, ptr %tmp_16328.elt14, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1323 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1323, align 4, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16328.unpack15, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16328.unpack15, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16328.unpack15, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %cond = icmp eq i64 %tmp_16328.unpack, 0
  br i1 %cond, label %next.i, label %common.ret

common.ret:                                       ; preds = %sharePositive.exit
  ret void

next.i:                                           ; preds = %sharePositive.exit
  %environment.i = getelementptr i8, ptr %tmp_16328.unpack15, i64 16
  %x_48_188_2256_12440_pointer_1333 = getelementptr i8, ptr %tmp_16328.unpack15, i64 56
  %x_48_188_2256_12440 = load double, ptr %x_48_188_2256_12440_pointer_1333, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %tmp_16328.unpack15, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %tmp_16328.unpack15, align 4
  br label %next.i27

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %tmp_16328.unpack15, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16328.unpack15)
  %referenceCount.i28.pr = load i64, ptr %tmp_16328.unpack15, align 4
  br label %next.i27

next.i27:                                         ; preds = %free.i, %decr.i
  %referenceCount.i28 = phi i64 [ %referenceCount.i28.pr, %free.i ], [ %referenceCount.1.i, %decr.i ]
  %x_57_197_2265_12411_pointer_1345 = getelementptr i8, ptr %tmp_16328.unpack15, i64 64
  %x_57_197_2265_12411 = load double, ptr %x_57_197_2265_12411_pointer_1345, align 8, !noalias !0
  %cond.i29 = icmp eq i64 %referenceCount.i28, 0
  br i1 %cond.i29, label %free.i32, label %decr.i30

decr.i30:                                         ; preds = %next.i27
  %referenceCount.1.i31 = add i64 %referenceCount.i28, -1
  store i64 %referenceCount.1.i31, ptr %tmp_16328.unpack15, align 4
  br label %eraseObject.exit36

free.i32:                                         ; preds = %next.i27
  %objectEraser.i33 = getelementptr i8, ptr %tmp_16328.unpack15, i64 8
  %eraser.i34 = load ptr, ptr %objectEraser.i33, align 8
  tail call void %eraser.i34(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16328.unpack15)
  br label %eraseObject.exit36

eraseObject.exit36:                               ; preds = %decr.i30, %free.i32
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i45 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 104
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i45
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit36
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
  %newStackPointer.i46 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i46, i64 104
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit36, %realloc.i
  %limit.i52 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i45, %eraseObject.exit36 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit36 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i46, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit36 ]
  %z.i = fmul double %x_48_188_2256_12440, %x_57_197_2265_12411
  %z.i42 = fadd double %z.i, %v_r_3056_42_182_2250_10552
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_16320.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1382.repack17 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_16320.unpack3, ptr %stackPointer_1382.repack17, align 8, !noalias !0
  %py_11_2079_10749_pointer_1384 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %py_11_2079_10749.unpack, ptr %py_11_2079_10749_pointer_1384, align 8, !noalias !0
  %py_11_2079_10749_pointer_1384.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %py_11_2079_10749.unpack6, ptr %py_11_2079_10749_pointer_1384.repack19, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1385 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %pz_13_2081_11683.unpack, ptr %pz_13_2081_11683_pointer_1385, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1385.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %pz_13_2081_11683.unpack9, ptr %pz_13_2081_11683_pointer_1385.repack21, align 8, !noalias !0
  %tmp_16326_pointer_1386 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %tmp_16326, ptr %tmp_16326_pointer_1386, align 4, !noalias !0
  %px_9_2077_11716_pointer_1387 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %px_9_2077_11716.unpack, ptr %px_9_2077_11716_pointer_1387, align 8, !noalias !0
  %px_9_2077_11716_pointer_1387.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %px_9_2077_11716.unpack12, ptr %px_9_2077_11716_pointer_1387.repack23, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1388 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1388, align 4, !noalias !0
  %returnAddress_pointer_1389 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %sharer_pointer_1390 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %eraser_pointer_1391 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr @returnAddress_1346, ptr %returnAddress_pointer_1389, align 8, !noalias !0
  store ptr @sharer_1360, ptr %sharer_pointer_1390, align 8, !noalias !0
  store ptr @eraser_1374, ptr %eraser_pointer_1391, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %pz_13_2081_11683.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i47 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i48 = load ptr, ptr %base_pointer.i47, align 8
  %varPointer.i = getelementptr i8, ptr %base.i48, i64 %pz_13_2081_11683.unpack9
  store double %z.i42, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i53 = icmp ule ptr %nextStackPointer.sink.i, %limit.i52
  tail call void @llvm.assume(i1 %isInside.i53)
  %newStackPointer.i54 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i54, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1395 = load ptr, ptr %newStackPointer.i54, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1395(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1407(ptr %stackPointer) {
entry:
  %tmp_16320_1400.elt1 = getelementptr i8, ptr %stackPointer, i64 -88
  %tmp_16320_1400.unpack2 = load ptr, ptr %tmp_16320_1400.elt1, align 8, !noalias !0
  %tmp_16328_1405.elt4 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_16328_1405.unpack5 = load ptr, ptr %tmp_16328_1405.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_16320_1400.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_16320_1400.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %tmp_16320_1400.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %tmp_16328_1405.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %tmp_16328_1405.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16328_1405.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -120
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1423(ptr %stackPointer) {
entry:
  %tmp_16320_1416.elt1 = getelementptr i8, ptr %stackPointer, i64 -88
  %tmp_16320_1416.unpack2 = load ptr, ptr %tmp_16320_1416.elt1, align 8, !noalias !0
  %tmp_16328_1421.elt4 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_16328_1421.unpack5 = load ptr, ptr %tmp_16328_1421.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_16320_1416.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_16320_1416.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_16320_1416.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_16320_1416.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_16320_1416.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_16320_1416.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %tmp_16328_1421.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %tmp_16328_1421.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_16328_1421.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_16328_1421.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_16328_1421.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_16328_1421.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -120
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -104
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1306(%Pos %__41_181_2249_13974, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i30 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i30)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16320.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16320.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %tmp_16320.unpack2 = load ptr, ptr %tmp_16320.elt1, align 8, !noalias !0
  %py_11_2079_10749_pointer_1309 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %py_11_2079_10749.unpack = load ptr, ptr %py_11_2079_10749_pointer_1309, align 8, !noalias !0
  %py_11_2079_10749.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %py_11_2079_10749.unpack5 = load i64, ptr %py_11_2079_10749.elt4, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1310 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %pz_13_2081_11683.unpack = load ptr, ptr %pz_13_2081_11683_pointer_1310, align 8, !noalias !0
  %pz_13_2081_11683.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %pz_13_2081_11683.unpack8 = load i64, ptr %pz_13_2081_11683.elt7, align 8, !noalias !0
  %tmp_16326_pointer_1311 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_16326 = load i64, ptr %tmp_16326_pointer_1311, align 4, !noalias !0
  %px_9_2077_11716_pointer_1312 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %px_9_2077_11716.unpack = load ptr, ptr %px_9_2077_11716_pointer_1312, align 8, !noalias !0
  %px_9_2077_11716.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %px_9_2077_11716.unpack11 = load i64, ptr %px_9_2077_11716.elt10, align 8, !noalias !0
  %tmp_16328_pointer_1313 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16328.unpack = load i64, ptr %tmp_16328_pointer_1313, align 8, !noalias !0
  %tmp_16328.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_16328.unpack14 = load ptr, ptr %tmp_16328.elt13, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1314 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1314, align 4, !noalias !0
  %object.i = extractvalue %Pos %__41_181_2249_13974, 1
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
  %limit.i33 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i33
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 120
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i34 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i34, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i40 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i33, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i34, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_16320.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1432.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_16320.unpack2, ptr %stackPointer_1432.repack16, align 8, !noalias !0
  %py_11_2079_10749_pointer_1434 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %py_11_2079_10749.unpack, ptr %py_11_2079_10749_pointer_1434, align 8, !noalias !0
  %py_11_2079_10749_pointer_1434.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %py_11_2079_10749.unpack5, ptr %py_11_2079_10749_pointer_1434.repack18, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1435 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %pz_13_2081_11683.unpack, ptr %pz_13_2081_11683_pointer_1435, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1435.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %pz_13_2081_11683.unpack8, ptr %pz_13_2081_11683_pointer_1435.repack20, align 8, !noalias !0
  %tmp_16326_pointer_1436 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %tmp_16326, ptr %tmp_16326_pointer_1436, align 4, !noalias !0
  %px_9_2077_11716_pointer_1437 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %px_9_2077_11716.unpack, ptr %px_9_2077_11716_pointer_1437, align 8, !noalias !0
  %px_9_2077_11716_pointer_1437.repack22 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %px_9_2077_11716.unpack11, ptr %px_9_2077_11716_pointer_1437.repack22, align 8, !noalias !0
  %tmp_16328_pointer_1438 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %tmp_16328.unpack, ptr %tmp_16328_pointer_1438, align 8, !noalias !0
  %tmp_16328_pointer_1438.repack24 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %tmp_16328.unpack14, ptr %tmp_16328_pointer_1438.repack24, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1439 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1439, align 4, !noalias !0
  %returnAddress_pointer_1440 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1441 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1442 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_1315, ptr %returnAddress_pointer_1440, align 8, !noalias !0
  store ptr @sharer_1407, ptr %sharer_pointer_1441, align 8, !noalias !0
  store ptr @eraser_1423, ptr %eraser_pointer_1442, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %pz_13_2081_11683.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i35 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i36 = load ptr, ptr %base_pointer.i35, align 8
  %varPointer.i = getelementptr i8, ptr %base.i36, i64 %pz_13_2081_11683.unpack8
  %get_16665 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i41 = icmp ule ptr %nextStackPointer.sink.i, %limit.i40
  tail call void @llvm.assume(i1 %isInside.i41)
  %newStackPointer.i42 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i42, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1445 = load ptr, ptr %newStackPointer.i42, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1445(double %get_16665, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1275(double %v_r_3052_22_162_2230_12555, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i48 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i48)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16320.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16320.elt2 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %tmp_16320.unpack3 = load ptr, ptr %tmp_16320.elt2, align 8, !noalias !0
  %py_11_2079_10749_pointer_1278 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %py_11_2079_10749.unpack = load ptr, ptr %py_11_2079_10749_pointer_1278, align 8, !noalias !0
  %py_11_2079_10749.elt5 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %py_11_2079_10749.unpack6 = load i64, ptr %py_11_2079_10749.elt5, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1279 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %pz_13_2081_11683.unpack = load ptr, ptr %pz_13_2081_11683_pointer_1279, align 8, !noalias !0
  %pz_13_2081_11683.elt8 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %pz_13_2081_11683.unpack9 = load i64, ptr %pz_13_2081_11683.elt8, align 8, !noalias !0
  %tmp_16326_pointer_1280 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_16326 = load i64, ptr %tmp_16326_pointer_1280, align 4, !noalias !0
  %px_9_2077_11716_pointer_1281 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %px_9_2077_11716.unpack = load ptr, ptr %px_9_2077_11716_pointer_1281, align 8, !noalias !0
  %px_9_2077_11716.elt11 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %px_9_2077_11716.unpack12 = load i64, ptr %px_9_2077_11716.elt11, align 8, !noalias !0
  %tmp_16328_pointer_1282 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16328.unpack = load i64, ptr %tmp_16328_pointer_1282, align 8, !noalias !0
  %tmp_16328.elt14 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_16328.unpack15 = load ptr, ptr %tmp_16328.elt14, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1283 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1283, align 4, !noalias !0
  %isNull.i.i28 = icmp eq ptr %tmp_16328.unpack15, null
  br i1 %isNull.i.i28, label %sharePositive.exit32, label %next.i.i29

next.i.i29:                                       ; preds = %entry
  %referenceCount.i.i30 = load i64, ptr %tmp_16328.unpack15, align 4
  %referenceCount.1.i.i31 = add i64 %referenceCount.i.i30, 1
  store i64 %referenceCount.1.i.i31, ptr %tmp_16328.unpack15, align 4
  br label %sharePositive.exit32

sharePositive.exit32:                             ; preds = %entry, %next.i.i29
  %cond = icmp eq i64 %tmp_16328.unpack, 0
  br i1 %cond, label %next.i, label %common.ret

common.ret:                                       ; preds = %sharePositive.exit32
  ret void

next.i:                                           ; preds = %sharePositive.exit32
  %environment.i = getelementptr i8, ptr %tmp_16328.unpack15, i64 16
  %x_27_167_2235_11547_pointer_1292 = getelementptr i8, ptr %tmp_16328.unpack15, i64 48
  %x_27_167_2235_11547 = load double, ptr %x_27_167_2235_11547_pointer_1292, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %tmp_16328.unpack15, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  br label %next.i34

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %tmp_16328.unpack15, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16328.unpack15)
  %referenceCount.i.i.pre = load i64, ptr %tmp_16328.unpack15, align 4
  br label %next.i34

next.i34:                                         ; preds = %free.i, %decr.i
  %referenceCount.i.i = phi i64 [ %referenceCount.i.i.pre, %free.i ], [ %referenceCount.1.i, %decr.i ]
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16328.unpack15, align 4
  %x_37_177_2245_12311_pointer_1305 = getelementptr i8, ptr %tmp_16328.unpack15, i64 64
  %x_37_177_2245_12311 = load double, ptr %x_37_177_2245_12311_pointer_1305, align 8, !noalias !0
  %cond.i36 = icmp eq i64 %referenceCount.1.i.i, 0
  br i1 %cond.i36, label %free.i39, label %decr.i37

decr.i37:                                         ; preds = %next.i34
  store i64 %referenceCount.i.i, ptr %tmp_16328.unpack15, align 4
  br label %eraseObject.exit43

free.i39:                                         ; preds = %next.i34
  %objectEraser.i40 = getelementptr i8, ptr %tmp_16328.unpack15, i64 8
  %eraser.i41 = load ptr, ptr %objectEraser.i40, align 8
  tail call void %eraser.i41(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16328.unpack15)
  br label %eraseObject.exit43

eraseObject.exit43:                               ; preds = %decr.i37, %free.i39
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i52 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i52
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit43
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 120
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i53 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i53, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit43, %realloc.i
  %limit.i59 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i52, %eraseObject.exit43 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit43 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i53, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit43 ]
  %z.i = fmul double %x_27_167_2235_11547, %x_37_177_2245_12311
  %z.i49 = fadd double %z.i, %v_r_3052_22_162_2230_12555
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_16320.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1462.repack17 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_16320.unpack3, ptr %stackPointer_1462.repack17, align 8, !noalias !0
  %py_11_2079_10749_pointer_1464 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %py_11_2079_10749.unpack, ptr %py_11_2079_10749_pointer_1464, align 8, !noalias !0
  %py_11_2079_10749_pointer_1464.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %py_11_2079_10749.unpack6, ptr %py_11_2079_10749_pointer_1464.repack19, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1465 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %pz_13_2081_11683.unpack, ptr %pz_13_2081_11683_pointer_1465, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1465.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %pz_13_2081_11683.unpack9, ptr %pz_13_2081_11683_pointer_1465.repack21, align 8, !noalias !0
  %tmp_16326_pointer_1466 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %tmp_16326, ptr %tmp_16326_pointer_1466, align 4, !noalias !0
  %px_9_2077_11716_pointer_1467 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %px_9_2077_11716.unpack, ptr %px_9_2077_11716_pointer_1467, align 8, !noalias !0
  %px_9_2077_11716_pointer_1467.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %px_9_2077_11716.unpack12, ptr %px_9_2077_11716_pointer_1467.repack23, align 8, !noalias !0
  %tmp_16328_pointer_1468 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 0, ptr %tmp_16328_pointer_1468, align 8, !noalias !0
  %tmp_16328_pointer_1468.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %tmp_16328.unpack15, ptr %tmp_16328_pointer_1468.repack25, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1469 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1469, align 4, !noalias !0
  %returnAddress_pointer_1470 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1471 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1472 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_1306, ptr %returnAddress_pointer_1470, align 8, !noalias !0
  store ptr @sharer_1407, ptr %sharer_pointer_1471, align 8, !noalias !0
  store ptr @eraser_1423, ptr %eraser_pointer_1472, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %py_11_2079_10749.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i54 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i55 = load ptr, ptr %base_pointer.i54, align 8
  %varPointer.i = getelementptr i8, ptr %base.i55, i64 %py_11_2079_10749.unpack6
  store double %z.i49, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i60 = icmp ule ptr %nextStackPointer.sink.i, %limit.i59
  tail call void @llvm.assume(i1 %isInside.i60)
  %newStackPointer.i61 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i61, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1476 = load ptr, ptr %newStackPointer.i61, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1476(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1266(%Pos %__21_161_2229_13961, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i30 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i30)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16320.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16320.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %tmp_16320.unpack2 = load ptr, ptr %tmp_16320.elt1, align 8, !noalias !0
  %py_11_2079_10749_pointer_1269 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %py_11_2079_10749.unpack = load ptr, ptr %py_11_2079_10749_pointer_1269, align 8, !noalias !0
  %py_11_2079_10749.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %py_11_2079_10749.unpack5 = load i64, ptr %py_11_2079_10749.elt4, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1270 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %pz_13_2081_11683.unpack = load ptr, ptr %pz_13_2081_11683_pointer_1270, align 8, !noalias !0
  %pz_13_2081_11683.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %pz_13_2081_11683.unpack8 = load i64, ptr %pz_13_2081_11683.elt7, align 8, !noalias !0
  %tmp_16326_pointer_1271 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_16326 = load i64, ptr %tmp_16326_pointer_1271, align 4, !noalias !0
  %px_9_2077_11716_pointer_1272 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %px_9_2077_11716.unpack = load ptr, ptr %px_9_2077_11716_pointer_1272, align 8, !noalias !0
  %px_9_2077_11716.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %px_9_2077_11716.unpack11 = load i64, ptr %px_9_2077_11716.elt10, align 8, !noalias !0
  %tmp_16328_pointer_1273 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16328.unpack = load i64, ptr %tmp_16328_pointer_1273, align 8, !noalias !0
  %tmp_16328.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_16328.unpack14 = load ptr, ptr %tmp_16328.elt13, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1274 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1274, align 4, !noalias !0
  %object.i = extractvalue %Pos %__21_161_2229_13961, 1
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
  %limit.i33 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i33
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 120
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i34 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i34, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i40 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i33, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i34, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_16320.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1495.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_16320.unpack2, ptr %stackPointer_1495.repack16, align 8, !noalias !0
  %py_11_2079_10749_pointer_1497 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %py_11_2079_10749.unpack, ptr %py_11_2079_10749_pointer_1497, align 8, !noalias !0
  %py_11_2079_10749_pointer_1497.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %py_11_2079_10749.unpack5, ptr %py_11_2079_10749_pointer_1497.repack18, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1498 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %pz_13_2081_11683.unpack, ptr %pz_13_2081_11683_pointer_1498, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1498.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %pz_13_2081_11683.unpack8, ptr %pz_13_2081_11683_pointer_1498.repack20, align 8, !noalias !0
  %tmp_16326_pointer_1499 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %tmp_16326, ptr %tmp_16326_pointer_1499, align 4, !noalias !0
  %px_9_2077_11716_pointer_1500 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %px_9_2077_11716.unpack, ptr %px_9_2077_11716_pointer_1500, align 8, !noalias !0
  %px_9_2077_11716_pointer_1500.repack22 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %px_9_2077_11716.unpack11, ptr %px_9_2077_11716_pointer_1500.repack22, align 8, !noalias !0
  %tmp_16328_pointer_1501 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %tmp_16328.unpack, ptr %tmp_16328_pointer_1501, align 8, !noalias !0
  %tmp_16328_pointer_1501.repack24 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %tmp_16328.unpack14, ptr %tmp_16328_pointer_1501.repack24, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1502 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1502, align 4, !noalias !0
  %returnAddress_pointer_1503 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1504 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1505 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_1275, ptr %returnAddress_pointer_1503, align 8, !noalias !0
  store ptr @sharer_1407, ptr %sharer_pointer_1504, align 8, !noalias !0
  store ptr @eraser_1423, ptr %eraser_pointer_1505, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %py_11_2079_10749.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i35 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i36 = load ptr, ptr %base_pointer.i35, align 8
  %varPointer.i = getelementptr i8, ptr %base.i36, i64 %py_11_2079_10749.unpack5
  %get_16667 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i41 = icmp ule ptr %nextStackPointer.sink.i, %limit.i40
  tail call void @llvm.assume(i1 %isInside.i41)
  %newStackPointer.i42 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i42, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1508 = load ptr, ptr %newStackPointer.i42, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1508(double %get_16667, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1235(double %v_r_3048_2_142_2210_12290, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i48 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i48)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16320.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16320.elt2 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %tmp_16320.unpack3 = load ptr, ptr %tmp_16320.elt2, align 8, !noalias !0
  %py_11_2079_10749_pointer_1238 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %py_11_2079_10749.unpack = load ptr, ptr %py_11_2079_10749_pointer_1238, align 8, !noalias !0
  %py_11_2079_10749.elt5 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %py_11_2079_10749.unpack6 = load i64, ptr %py_11_2079_10749.elt5, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1239 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %pz_13_2081_11683.unpack = load ptr, ptr %pz_13_2081_11683_pointer_1239, align 8, !noalias !0
  %pz_13_2081_11683.elt8 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %pz_13_2081_11683.unpack9 = load i64, ptr %pz_13_2081_11683.elt8, align 8, !noalias !0
  %tmp_16326_pointer_1240 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_16326 = load i64, ptr %tmp_16326_pointer_1240, align 4, !noalias !0
  %px_9_2077_11716_pointer_1241 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %px_9_2077_11716.unpack = load ptr, ptr %px_9_2077_11716_pointer_1241, align 8, !noalias !0
  %px_9_2077_11716.elt11 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %px_9_2077_11716.unpack12 = load i64, ptr %px_9_2077_11716.elt11, align 8, !noalias !0
  %tmp_16328_pointer_1242 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16328.unpack = load i64, ptr %tmp_16328_pointer_1242, align 8, !noalias !0
  %tmp_16328.elt14 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_16328.unpack15 = load ptr, ptr %tmp_16328.elt14, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1243 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_10_139_2207_11222 = load i64, ptr %i_6_10_139_2207_11222_pointer_1243, align 4, !noalias !0
  %isNull.i.i28 = icmp eq ptr %tmp_16328.unpack15, null
  br i1 %isNull.i.i28, label %sharePositive.exit32, label %next.i.i29

next.i.i29:                                       ; preds = %entry
  %referenceCount.i.i30 = load i64, ptr %tmp_16328.unpack15, align 4
  %referenceCount.1.i.i31 = add i64 %referenceCount.i.i30, 1
  store i64 %referenceCount.1.i.i31, ptr %tmp_16328.unpack15, align 4
  br label %sharePositive.exit32

sharePositive.exit32:                             ; preds = %entry, %next.i.i29
  %cond = icmp eq i64 %tmp_16328.unpack, 0
  br i1 %cond, label %next.i, label %common.ret

common.ret:                                       ; preds = %sharePositive.exit32
  ret void

next.i:                                           ; preds = %sharePositive.exit32
  %environment.i = getelementptr i8, ptr %tmp_16328.unpack15, i64 16
  %x_6_146_2214_11598_pointer_1251 = getelementptr i8, ptr %tmp_16328.unpack15, i64 40
  %x_6_146_2214_11598 = load double, ptr %x_6_146_2214_11598_pointer_1251, align 8, !noalias !0
  %referenceCount.i = load i64, ptr %tmp_16328.unpack15, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  br label %next.i34

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %tmp_16328.unpack15, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16328.unpack15)
  %referenceCount.i.i.pre = load i64, ptr %tmp_16328.unpack15, align 4
  br label %next.i34

next.i34:                                         ; preds = %free.i, %decr.i
  %referenceCount.i.i = phi i64 [ %referenceCount.i.i.pre, %free.i ], [ %referenceCount.1.i, %decr.i ]
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16328.unpack15, align 4
  %x_17_157_2225_11908_pointer_1265 = getelementptr i8, ptr %tmp_16328.unpack15, i64 64
  %x_17_157_2225_11908 = load double, ptr %x_17_157_2225_11908_pointer_1265, align 8, !noalias !0
  %cond.i36 = icmp eq i64 %referenceCount.1.i.i, 0
  br i1 %cond.i36, label %free.i39, label %decr.i37

decr.i37:                                         ; preds = %next.i34
  store i64 %referenceCount.i.i, ptr %tmp_16328.unpack15, align 4
  br label %eraseObject.exit43

free.i39:                                         ; preds = %next.i34
  %objectEraser.i40 = getelementptr i8, ptr %tmp_16328.unpack15, i64 8
  %eraser.i41 = load ptr, ptr %objectEraser.i40, align 8
  tail call void %eraser.i41(ptr %environment.i)
  tail call void @free(ptr nonnull %tmp_16328.unpack15)
  br label %eraseObject.exit43

eraseObject.exit43:                               ; preds = %decr.i37, %free.i39
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i52 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i52
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit43
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 120
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i53 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i53, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit43, %realloc.i
  %limit.i59 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i52, %eraseObject.exit43 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit43 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i53, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit43 ]
  %z.i = fmul double %x_6_146_2214_11598, %x_17_157_2225_11908
  %z.i49 = fadd double %z.i, %v_r_3048_2_142_2210_12290
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_16320.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1525.repack17 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_16320.unpack3, ptr %stackPointer_1525.repack17, align 8, !noalias !0
  %py_11_2079_10749_pointer_1527 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %py_11_2079_10749.unpack, ptr %py_11_2079_10749_pointer_1527, align 8, !noalias !0
  %py_11_2079_10749_pointer_1527.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %py_11_2079_10749.unpack6, ptr %py_11_2079_10749_pointer_1527.repack19, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1528 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %pz_13_2081_11683.unpack, ptr %pz_13_2081_11683_pointer_1528, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1528.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %pz_13_2081_11683.unpack9, ptr %pz_13_2081_11683_pointer_1528.repack21, align 8, !noalias !0
  %tmp_16326_pointer_1529 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %tmp_16326, ptr %tmp_16326_pointer_1529, align 4, !noalias !0
  %px_9_2077_11716_pointer_1530 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %px_9_2077_11716.unpack, ptr %px_9_2077_11716_pointer_1530, align 8, !noalias !0
  %px_9_2077_11716_pointer_1530.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %px_9_2077_11716.unpack12, ptr %px_9_2077_11716_pointer_1530.repack23, align 8, !noalias !0
  %tmp_16328_pointer_1531 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 0, ptr %tmp_16328_pointer_1531, align 8, !noalias !0
  %tmp_16328_pointer_1531.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %tmp_16328.unpack15, ptr %tmp_16328_pointer_1531.repack25, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1532 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1532, align 4, !noalias !0
  %returnAddress_pointer_1533 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1534 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1535 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_1266, ptr %returnAddress_pointer_1533, align 8, !noalias !0
  store ptr @sharer_1407, ptr %sharer_pointer_1534, align 8, !noalias !0
  store ptr @eraser_1423, ptr %eraser_pointer_1535, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %px_9_2077_11716.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i54 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i55 = load ptr, ptr %base_pointer.i54, align 8
  %varPointer.i = getelementptr i8, ptr %base.i55, i64 %px_9_2077_11716.unpack12
  store double %z.i49, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i60 = icmp ule ptr %nextStackPointer.sink.i, %limit.i59
  tail call void @llvm.assume(i1 %isInside.i60)
  %newStackPointer.i61 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i61, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1539 = load ptr, ptr %newStackPointer.i61, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1539(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_9_138_2206_10607(i64 %i_6_10_139_2207_11222, %Pos %tmp_16320, %Reference %py_11_2079_10749, %Reference %pz_13_2081_11683, i64 %tmp_16326, %Reference %px_9_2077_11716, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_10_139_2207_11222, %tmp_16326
  %object.i = extractvalue %Pos %tmp_16320, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %z.i, label %label_1574, label %label_1234

label_1234:                                       ; preds = %entry
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i13

next.i.i13:                                       ; preds = %label_1234
  %referenceCount.i.i14 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i14, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i13
  %referenceCount.1.i.i15 = add i64 %referenceCount.i.i14, -1
  store i64 %referenceCount.1.i.i15, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i13
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_1234, %decr.i.i, %free.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1231 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1231(%Pos zeroinitializer, ptr %stack)
  ret void

label_1574:                                       ; preds = %entry
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1574
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_1574, %next.i.i
  %z.i16 = tail call %Pos @c_array_get(%Pos %tmp_16320, i64 %i_6_10_139_2207_11222)
  %stackPointer_pointer.i17 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i18 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i17, align 8, !alias.scope !0
  %limit.i19 = load ptr, ptr %limit_pointer.i18, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i19
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 120
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i20 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i20, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i18, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %limit.i26 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i19, %sharePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i20, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i17, align 8
  %tmp_16320.elt = extractvalue %Pos %tmp_16320, 0
  store i64 %tmp_16320.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1558.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_1558.repack1, align 8, !noalias !0
  %py_11_2079_10749_pointer_1560 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %py_11_2079_10749.elt = extractvalue %Reference %py_11_2079_10749, 0
  store ptr %py_11_2079_10749.elt, ptr %py_11_2079_10749_pointer_1560, align 8, !noalias !0
  %py_11_2079_10749_pointer_1560.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %py_11_2079_10749.elt4 = extractvalue %Reference %py_11_2079_10749, 1
  store i64 %py_11_2079_10749.elt4, ptr %py_11_2079_10749_pointer_1560.repack3, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1561 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %pz_13_2081_11683.elt = extractvalue %Reference %pz_13_2081_11683, 0
  store ptr %pz_13_2081_11683.elt, ptr %pz_13_2081_11683_pointer_1561, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1561.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %pz_13_2081_11683.elt6 = extractvalue %Reference %pz_13_2081_11683, 1
  store i64 %pz_13_2081_11683.elt6, ptr %pz_13_2081_11683_pointer_1561.repack5, align 8, !noalias !0
  %tmp_16326_pointer_1562 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %tmp_16326, ptr %tmp_16326_pointer_1562, align 4, !noalias !0
  %px_9_2077_11716_pointer_1563 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %px_9_2077_11716.elt = extractvalue %Reference %px_9_2077_11716, 0
  store ptr %px_9_2077_11716.elt, ptr %px_9_2077_11716_pointer_1563, align 8, !noalias !0
  %px_9_2077_11716_pointer_1563.repack7 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %px_9_2077_11716.elt8 = extractvalue %Reference %px_9_2077_11716, 1
  store i64 %px_9_2077_11716.elt8, ptr %px_9_2077_11716_pointer_1563.repack7, align 8, !noalias !0
  %tmp_16328_pointer_1564 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %pureApp_16655.elt = extractvalue %Pos %z.i16, 0
  store i64 %pureApp_16655.elt, ptr %tmp_16328_pointer_1564, align 8, !noalias !0
  %tmp_16328_pointer_1564.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %pureApp_16655.elt10 = extractvalue %Pos %z.i16, 1
  store ptr %pureApp_16655.elt10, ptr %tmp_16328_pointer_1564.repack9, align 8, !noalias !0
  %i_6_10_139_2207_11222_pointer_1565 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %i_6_10_139_2207_11222, ptr %i_6_10_139_2207_11222_pointer_1565, align 4, !noalias !0
  %returnAddress_pointer_1566 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1567 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1568 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_1235, ptr %returnAddress_pointer_1566, align 8, !noalias !0
  store ptr @sharer_1407, ptr %sharer_pointer_1567, align 8, !noalias !0
  store ptr @eraser_1423, ptr %eraser_pointer_1568, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %px_9_2077_11716.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i21 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i22 = load ptr, ptr %base_pointer.i21, align 8
  %varPointer.i = getelementptr i8, ptr %base.i22, i64 %px_9_2077_11716.elt8
  %get_16669 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i27 = icmp ule ptr %nextStackPointer.sink.i, %limit.i26
  tail call void @llvm.assume(i1 %isInside.i27)
  %newStackPointer.i28 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i28, ptr %stackPointer_pointer.i17, align 8, !alias.scope !0
  %returnAddress_1571 = load ptr, ptr %newStackPointer.i28, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1571(double %get_16669, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1594(double %v_r_3067_250_2318_11495, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16294 = load double, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_3066_249_2317_11242_pointer_1597 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_r_3066_249_2317_11242 = load double, ptr %v_r_3066_249_2317_11242_pointer_1597, align 8, !noalias !0
  %tmp_16320_pointer_1598 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16320.unpack = load i64, ptr %tmp_16320_pointer_1598, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_16320.unpack, 0
  %tmp_16320.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_16320.unpack2 = load ptr, ptr %tmp_16320.elt1, align 8, !noalias !0
  %tmp_163203 = insertvalue %Pos %0, ptr %tmp_16320.unpack2, 1
  %v_r_3065_248_2316_11300_pointer_1599 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_3065_248_2316_11300 = load double, ptr %v_r_3065_248_2316_11300_pointer_1599, align 8, !noalias !0
  %z.i = fdiv double %v_r_3065_248_2316_11300, %tmp_16294
  %z.i15 = fsub double 0.000000e+00, %z.i
  %z.i16 = fdiv double %v_r_3066_249_2317_11242, %tmp_16294
  %z.i17 = fsub double 0.000000e+00, %z.i16
  %z.i18 = fdiv double %v_r_3067_250_2318_11495, %tmp_16294
  %z.i19 = fsub double 0.000000e+00, %z.i18
  %object.i = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_11, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %tmp_16338_pointer_1612 = getelementptr i8, ptr %object.i, i64 40
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %environment.i, i8 0, i64 24, i1 false)
  store double %z.i15, ptr %tmp_16338_pointer_1612, align 8, !noalias !0
  %tmp_16340_pointer_1613 = getelementptr i8, ptr %object.i, i64 48
  store double %z.i17, ptr %tmp_16340_pointer_1613, align 8, !noalias !0
  %tmp_16342_pointer_1614 = getelementptr i8, ptr %object.i, i64 56
  store double %z.i19, ptr %tmp_16342_pointer_1614, align 8, !noalias !0
  %tmp_16336_pointer_1615 = getelementptr i8, ptr %object.i, i64 64
  store double %tmp_16294, ptr %tmp_16336_pointer_1615, align 8, !noalias !0
  %make_16684 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %isNull.i.i = icmp eq ptr %tmp_16320.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %z.i20 = tail call %Pos @c_array_set(%Pos %tmp_163203, i64 0, %Pos %make_16684)
  %object.i5 = extractvalue %Pos %z.i20, 1
  %isNull.i.i6 = icmp eq ptr %object.i5, null
  br i1 %isNull.i.i6, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %sharePositive.exit
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

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %stackPointer.i22 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i24 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i25 = icmp ule ptr %stackPointer.i22, %limit.i24
  tail call void @llvm.assume(i1 %isInside.i25)
  %newStackPointer.i26 = getelementptr i8, ptr %stackPointer.i22, i64 -24
  store ptr %newStackPointer.i26, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1617 = load ptr, ptr %newStackPointer.i26, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1617(%Pos %tmp_163203, ptr nonnull %stack)
  ret void
}

define void @sharer_1624(ptr %stackPointer) {
entry:
  %tmp_16320_1622.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_16320_1622.unpack2 = load ptr, ptr %tmp_16320_1622.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1622.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1622.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1622.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1634(ptr %stackPointer) {
entry:
  %tmp_16320_1632.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_16320_1632.unpack2 = load ptr, ptr %tmp_16320_1632.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1632.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1632.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1632.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_16320_1632.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_16320_1632.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_16320_1632.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1588(double %v_r_3066_249_2317_11242, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %pz_13_2081_11683.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %pz_13_2081_11683.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %pz_13_2081_11683.unpack2 = load i64, ptr %pz_13_2081_11683.elt1, align 8, !noalias !0
  %tmp_16294_pointer_1591 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_16294 = load double, ptr %tmp_16294_pointer_1591, align 8, !noalias !0
  %tmp_16320_pointer_1592 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16320.unpack = load i64, ptr %tmp_16320_pointer_1592, align 8, !noalias !0
  %tmp_16320.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_16320.unpack5 = load ptr, ptr %tmp_16320.elt4, align 8, !noalias !0
  %v_r_3065_248_2316_11300_pointer_1593 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_3065_248_2316_11300 = load double, ptr %v_r_3065_248_2316_11300_pointer_1593, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 64
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i17 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i17, i64 64
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i23 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i17, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store double %tmp_16294, ptr %common.ret.op.i, align 8, !noalias !0
  %v_r_3066_249_2317_11242_pointer_1642 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store double %v_r_3066_249_2317_11242, ptr %v_r_3066_249_2317_11242_pointer_1642, align 8, !noalias !0
  %tmp_16320_pointer_1643 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_16320.unpack, ptr %tmp_16320_pointer_1643, align 8, !noalias !0
  %tmp_16320_pointer_1643.repack7 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %tmp_16320.unpack5, ptr %tmp_16320_pointer_1643.repack7, align 8, !noalias !0
  %v_r_3065_248_2316_11300_pointer_1644 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store double %v_r_3065_248_2316_11300, ptr %v_r_3065_248_2316_11300_pointer_1644, align 8, !noalias !0
  %returnAddress_pointer_1645 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_1646 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_1647 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_1594, ptr %returnAddress_pointer_1645, align 8, !noalias !0
  store ptr @sharer_1624, ptr %sharer_pointer_1646, align 8, !noalias !0
  store ptr @eraser_1634, ptr %eraser_pointer_1647, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %pz_13_2081_11683.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i18 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i19 = load ptr, ptr %base_pointer.i18, align 8
  %varPointer.i = getelementptr i8, ptr %base.i19, i64 %pz_13_2081_11683.unpack2
  %get_16687 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i24 = icmp ule ptr %nextStackPointer.sink.i, %limit.i23
  tail call void @llvm.assume(i1 %isInside.i24)
  %newStackPointer.i25 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i25, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1650 = load ptr, ptr %newStackPointer.i25, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1650(double %get_16687, ptr nonnull %stack)
  ret void
}

define void @sharer_1657(ptr %stackPointer) {
entry:
  %tmp_16320_1655.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_16320_1655.unpack2 = load ptr, ptr %tmp_16320_1655.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1655.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1655.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1655.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1667(ptr %stackPointer) {
entry:
  %tmp_16320_1665.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_16320_1665.unpack2 = load ptr, ptr %tmp_16320_1665.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1665.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1665.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1665.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_16320_1665.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_16320_1665.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_16320_1665.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1582(double %v_r_3065_248_2316_11300, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16320.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16320.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_16320.unpack2 = load ptr, ptr %tmp_16320.elt1, align 8, !noalias !0
  %py_11_2079_10749_pointer_1585 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %py_11_2079_10749.unpack = load ptr, ptr %py_11_2079_10749_pointer_1585, align 8, !noalias !0
  %py_11_2079_10749.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %py_11_2079_10749.unpack5 = load i64, ptr %py_11_2079_10749.elt4, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1586 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %pz_13_2081_11683.unpack = load ptr, ptr %pz_13_2081_11683_pointer_1586, align 8, !noalias !0
  %pz_13_2081_11683.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %pz_13_2081_11683.unpack8 = load i64, ptr %pz_13_2081_11683.elt7, align 8, !noalias !0
  %tmp_16294_pointer_1587 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_16294 = load double, ptr %tmp_16294_pointer_1587, align 8, !noalias !0
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
  %newStackPointer.i22 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i22, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i28 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i22, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %pz_13_2081_11683.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1673.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %pz_13_2081_11683.unpack8, ptr %stackPointer_1673.repack10, align 8, !noalias !0
  %tmp_16294_pointer_1675 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store double %tmp_16294, ptr %tmp_16294_pointer_1675, align 8, !noalias !0
  %tmp_16320_pointer_1676 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_16320.unpack, ptr %tmp_16320_pointer_1676, align 8, !noalias !0
  %tmp_16320_pointer_1676.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %tmp_16320.unpack2, ptr %tmp_16320_pointer_1676.repack12, align 8, !noalias !0
  %v_r_3065_248_2316_11300_pointer_1677 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store double %v_r_3065_248_2316_11300, ptr %v_r_3065_248_2316_11300_pointer_1677, align 8, !noalias !0
  %returnAddress_pointer_1678 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1679 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1680 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_1588, ptr %returnAddress_pointer_1678, align 8, !noalias !0
  store ptr @sharer_1657, ptr %sharer_pointer_1679, align 8, !noalias !0
  store ptr @eraser_1667, ptr %eraser_pointer_1680, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %py_11_2079_10749.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i23 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i24 = load ptr, ptr %base_pointer.i23, align 8
  %varPointer.i = getelementptr i8, ptr %base.i24, i64 %py_11_2079_10749.unpack5
  %get_16688 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i29 = icmp ule ptr %nextStackPointer.sink.i, %limit.i28
  tail call void @llvm.assume(i1 %isInside.i29)
  %newStackPointer.i30 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i30, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1683 = load ptr, ptr %newStackPointer.i30, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1683(double %get_16688, ptr nonnull %stack)
  ret void
}

define void @sharer_1690(ptr %stackPointer) {
entry:
  %tmp_16320_1686.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_16320_1686.unpack2 = load ptr, ptr %tmp_16320_1686.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1686.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1686.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1686.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1700(ptr %stackPointer) {
entry:
  %tmp_16320_1696.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_16320_1696.unpack2 = load ptr, ptr %tmp_16320_1696.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1696.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1696.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1696.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_16320_1696.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_16320_1696.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_16320_1696.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1575(%Pos %__203_2271_13988, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_16320.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16320.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_16320.unpack2 = load ptr, ptr %tmp_16320.elt1, align 8, !noalias !0
  %py_11_2079_10749_pointer_1578 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %py_11_2079_10749.unpack = load ptr, ptr %py_11_2079_10749_pointer_1578, align 8, !noalias !0
  %py_11_2079_10749.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %py_11_2079_10749.unpack5 = load i64, ptr %py_11_2079_10749.elt4, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1579 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %pz_13_2081_11683.unpack = load ptr, ptr %pz_13_2081_11683_pointer_1579, align 8, !noalias !0
  %pz_13_2081_11683.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %pz_13_2081_11683.unpack8 = load i64, ptr %pz_13_2081_11683.elt7, align 8, !noalias !0
  %tmp_16294_pointer_1580 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16294 = load double, ptr %tmp_16294_pointer_1580, align 8, !noalias !0
  %px_9_2077_11716_pointer_1581 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %px_9_2077_11716.unpack = load ptr, ptr %px_9_2077_11716_pointer_1581, align 8, !noalias !0
  %px_9_2077_11716.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %px_9_2077_11716.unpack11 = load i64, ptr %px_9_2077_11716.elt10, align 8, !noalias !0
  %object.i = extractvalue %Pos %__203_2271_13988, 1
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
  %limit.i26 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 80
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i26
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
  %newStackPointer.i27 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i27, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i33 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i26, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i27, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_16320.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1706.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_16320.unpack2, ptr %stackPointer_1706.repack13, align 8, !noalias !0
  %py_11_2079_10749_pointer_1708 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %py_11_2079_10749.unpack, ptr %py_11_2079_10749_pointer_1708, align 8, !noalias !0
  %py_11_2079_10749_pointer_1708.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %py_11_2079_10749.unpack5, ptr %py_11_2079_10749_pointer_1708.repack15, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1709 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %pz_13_2081_11683.unpack, ptr %pz_13_2081_11683_pointer_1709, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1709.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %pz_13_2081_11683.unpack8, ptr %pz_13_2081_11683_pointer_1709.repack17, align 8, !noalias !0
  %tmp_16294_pointer_1710 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store double %tmp_16294, ptr %tmp_16294_pointer_1710, align 8, !noalias !0
  %returnAddress_pointer_1711 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_1712 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_1713 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_1582, ptr %returnAddress_pointer_1711, align 8, !noalias !0
  store ptr @sharer_1690, ptr %sharer_pointer_1712, align 8, !noalias !0
  store ptr @eraser_1700, ptr %eraser_pointer_1713, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %px_9_2077_11716.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i28 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i29 = load ptr, ptr %base_pointer.i28, align 8
  %varPointer.i = getelementptr i8, ptr %base.i29, i64 %px_9_2077_11716.unpack11
  %get_16689 = load double, ptr %varPointer.i, align 8, !noalias !0
  %isInside.i34 = icmp ule ptr %nextStackPointer.sink.i, %limit.i33
  tail call void @llvm.assume(i1 %isInside.i34)
  %newStackPointer.i35 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i35, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1716 = load ptr, ptr %newStackPointer.i35, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1716(double %get_16689, ptr nonnull %stack)
  ret void
}

define void @sharer_1724(ptr %stackPointer) {
entry:
  %tmp_16320_1719.elt1 = getelementptr i8, ptr %stackPointer, i64 -64
  %tmp_16320_1719.unpack2 = load ptr, ptr %tmp_16320_1719.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1719.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1719.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1719.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1736(ptr %stackPointer) {
entry:
  %tmp_16320_1731.elt1 = getelementptr i8, ptr %stackPointer, i64 -64
  %tmp_16320_1731.unpack2 = load ptr, ptr %tmp_16320_1731.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16320_1731.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16320_1731.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_16320_1731.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_16320_1731.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_16320_1731.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_16320_1731.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -80
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_4181_4245, ptr %stack) {
entry:
  %stackPointer_pointer.i131 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i132 = load ptr, ptr %stackPointer_pointer.i131, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i132, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_4181_4245, 0
  %object.i15 = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i16 = getelementptr i8, ptr %object.i15, i64 8
  store i64 0, ptr %object.i15, align 4
  store ptr @eraser_11, ptr %objectEraser.i16, align 8
  %environment.i20 = getelementptr i8, ptr %object.i15, i64 16
  store double 0x40135DA0343CD92C, ptr %environment.i20, align 8, !noalias !0
  %doubleLiteral_16467_pointer_20 = getelementptr i8, ptr %object.i15, i64 24
  store double 0xBFF290ABC01FDB7C, ptr %doubleLiteral_16467_pointer_20, align 8, !noalias !0
  %doubleLiteral_16468_pointer_21 = getelementptr i8, ptr %object.i15, i64 32
  store double 0xBFBA86F96C25EBF0, ptr %doubleLiteral_16468_pointer_21, align 8, !noalias !0
  %tmp_16295_pointer_22 = getelementptr i8, ptr %object.i15, i64 40
  store double 0x3FE367069B93CCBC, ptr %tmp_16295_pointer_22, align 8, !noalias !0
  %tmp_16296_pointer_23 = getelementptr i8, ptr %object.i15, i64 48
  store double 0x40067EF2F57D949B, ptr %tmp_16296_pointer_23, align 8, !noalias !0
  %tmp_16297_pointer_24 = getelementptr i8, ptr %object.i15, i64 56
  store double 0xBF99D2D79A5A0715, ptr %tmp_16297_pointer_24, align 8, !noalias !0
  %tmp_16298_pointer_25 = getelementptr i8, ptr %object.i15, i64 64
  store double 0x3FA34C95D9AB33D8, ptr %tmp_16298_pointer_25, align 8, !noalias !0
  %make_16465 = insertvalue %Pos zeroinitializer, ptr %object.i15, 1
  %object.i13 = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i14 = getelementptr i8, ptr %object.i13, i64 8
  store i64 0, ptr %object.i13, align 4
  store ptr @eraser_11, ptr %objectEraser.i14, align 8
  %environment.i19 = getelementptr i8, ptr %object.i13, i64 16
  store double 0x4020AFCDC332CA67, ptr %environment.i19, align 8, !noalias !0
  %doubleLiteral_16479_pointer_37 = getelementptr i8, ptr %object.i13, i64 24
  store double 0x40107FCB31DE01B0, ptr %doubleLiteral_16479_pointer_37, align 8, !noalias !0
  %doubleLiteral_16480_pointer_38 = getelementptr i8, ptr %object.i13, i64 32
  store double 0xBFD9D353E1EB467C, ptr %doubleLiteral_16480_pointer_38, align 8, !noalias !0
  %tmp_16300_pointer_39 = getelementptr i8, ptr %object.i13, i64 40
  store double 0xBFF02C21B8879442, ptr %tmp_16300_pointer_39, align 8, !noalias !0
  %tmp_16301_pointer_40 = getelementptr i8, ptr %object.i13, i64 48
  store double 0x3FFD35E9BF1F8F13, ptr %tmp_16301_pointer_40, align 8, !noalias !0
  %tmp_16302_pointer_41 = getelementptr i8, ptr %object.i13, i64 56
  store double 0x3F813C485F1123B4, ptr %tmp_16302_pointer_41, align 8, !noalias !0
  %tmp_16303_pointer_42 = getelementptr i8, ptr %object.i13, i64 64
  store double 0x3F871D490D07C637, ptr %tmp_16303_pointer_42, align 8, !noalias !0
  %make_16477 = insertvalue %Pos zeroinitializer, ptr %object.i13, 1
  %object.i11 = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i12 = getelementptr i8, ptr %object.i11, i64 8
  store i64 0, ptr %object.i11, align 4
  store ptr @eraser_11, ptr %objectEraser.i12, align 8
  %environment.i18 = getelementptr i8, ptr %object.i11, i64 16
  store double 0x4029C9EACEA7D9CE, ptr %environment.i18, align 8, !noalias !0
  %doubleLiteral_16491_pointer_54 = getelementptr i8, ptr %object.i11, i64 24
  store double 0xC02E38E8D626667D, ptr %doubleLiteral_16491_pointer_54, align 8, !noalias !0
  %doubleLiteral_16492_pointer_55 = getelementptr i8, ptr %object.i11, i64 32
  store double 0xBFCC9557BE257DA0, ptr %doubleLiteral_16492_pointer_55, align 8, !noalias !0
  %tmp_16305_pointer_56 = getelementptr i8, ptr %object.i11, i64 40
  store double 0x3FF1531CA9911BEF, ptr %tmp_16305_pointer_56, align 8, !noalias !0
  %tmp_16306_pointer_57 = getelementptr i8, ptr %object.i11, i64 48
  store double 0x3FEBCC7F3E54BBC5, ptr %tmp_16306_pointer_57, align 8, !noalias !0
  %tmp_16307_pointer_58 = getelementptr i8, ptr %object.i11, i64 56
  store double 0xBF862F6BFAF23E7C, ptr %tmp_16307_pointer_58, align 8, !noalias !0
  %tmp_16308_pointer_59 = getelementptr i8, ptr %object.i11, i64 64
  store double 0x3F5C3DD29CF41EB3, ptr %tmp_16308_pointer_59, align 8, !noalias !0
  %make_16489 = insertvalue %Pos zeroinitializer, ptr %object.i11, 1
  %object.i9 = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i10 = getelementptr i8, ptr %object.i9, i64 8
  store i64 0, ptr %object.i9, align 4
  store ptr @eraser_11, ptr %objectEraser.i10, align 8
  %environment.i17 = getelementptr i8, ptr %object.i9, i64 16
  store double 0x402EC267A905572A, ptr %environment.i17, align 8, !noalias !0
  %doubleLiteral_16503_pointer_71 = getelementptr i8, ptr %object.i9, i64 24
  store double 0xC039EB5833C8A220, ptr %doubleLiteral_16503_pointer_71, align 8, !noalias !0
  %doubleLiteral_16504_pointer_72 = getelementptr i8, ptr %object.i9, i64 32
  store double 0x3FC6F1F393ABE540, ptr %doubleLiteral_16504_pointer_72, align 8, !noalias !0
  %tmp_16310_pointer_73 = getelementptr i8, ptr %object.i9, i64 40
  store double 0x3FEF54B61659BC49, ptr %tmp_16310_pointer_73, align 8, !noalias !0
  %tmp_16311_pointer_74 = getelementptr i8, ptr %object.i9, i64 48
  store double 0x3FE307C631C4FBA3, ptr %tmp_16311_pointer_74, align 8, !noalias !0
  %tmp_16312_pointer_75 = getelementptr i8, ptr %object.i9, i64 56
  store double 0xBFA1CB88587665F6, ptr %tmp_16312_pointer_75, align 8, !noalias !0
  %tmp_16313_pointer_76 = getelementptr i8, ptr %object.i9, i64 64
  store double 0x3F60A8F3531799AD, ptr %tmp_16313_pointer_76, align 8, !noalias !0
  %make_16501 = insertvalue %Pos zeroinitializer, ptr %object.i9, 1
  %object.i = tail call dereferenceable_or_null(72) ptr @malloc(i64 72)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_11, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %tmp_16318_pointer_93 = getelementptr i8, ptr %object.i, i64 64
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(48) %environment.i, i8 0, i64 48, i1 false)
  store double 0x4043BD3CC9BE45DE, ptr %tmp_16318_pointer_93, align 8, !noalias !0
  %make_16513 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %z.i = tail call %Pos @c_array_new(i64 5)
  %object.i52 = extractvalue %Pos %z.i, 1
  %isNull.i.i53 = icmp eq ptr %object.i52, null
  br i1 %isNull.i.i53, label %sharePositive.exit57, label %next.i.i54

next.i.i54:                                       ; preds = %entry
  %referenceCount.i.i55 = load i64, ptr %object.i52, align 4
  %referenceCount.1.i.i56 = add i64 %referenceCount.i.i55, 1
  store i64 %referenceCount.1.i.i56, ptr %object.i52, align 4
  br label %sharePositive.exit57

sharePositive.exit57:                             ; preds = %entry, %next.i.i54
  %z.i133 = tail call %Pos @c_array_set(%Pos %z.i, i64 0, %Pos %make_16513)
  %object.i99 = extractvalue %Pos %z.i133, 1
  %isNull.i.i100 = icmp eq ptr %object.i99, null
  br i1 %isNull.i.i100, label %erasePositive.exit110, label %next.i.i101

next.i.i101:                                      ; preds = %sharePositive.exit57
  %referenceCount.i.i102 = load i64, ptr %object.i99, align 4
  %cond.i.i103 = icmp eq i64 %referenceCount.i.i102, 0
  br i1 %cond.i.i103, label %free.i.i106, label %decr.i.i104

decr.i.i104:                                      ; preds = %next.i.i101
  %referenceCount.1.i.i105 = add i64 %referenceCount.i.i102, -1
  store i64 %referenceCount.1.i.i105, ptr %object.i99, align 4
  br label %erasePositive.exit110

free.i.i106:                                      ; preds = %next.i.i101
  %objectEraser.i.i107 = getelementptr i8, ptr %object.i99, i64 8
  %eraser.i.i108 = load ptr, ptr %objectEraser.i.i107, align 8
  %environment.i.i.i109 = getelementptr i8, ptr %object.i99, i64 16
  tail call void %eraser.i.i108(ptr %environment.i.i.i109)
  tail call void @free(ptr nonnull %object.i99)
  br label %erasePositive.exit110

erasePositive.exit110:                            ; preds = %sharePositive.exit57, %decr.i.i104, %free.i.i106
  br i1 %isNull.i.i53, label %sharePositive.exit51, label %next.i.i48

next.i.i48:                                       ; preds = %erasePositive.exit110
  %referenceCount.i.i49 = load i64, ptr %object.i52, align 4
  %referenceCount.1.i.i50 = add i64 %referenceCount.i.i49, 1
  store i64 %referenceCount.1.i.i50, ptr %object.i52, align 4
  br label %sharePositive.exit51

sharePositive.exit51:                             ; preds = %erasePositive.exit110, %next.i.i48
  %z.i134 = tail call %Pos @c_array_set(%Pos %z.i, i64 1, %Pos %make_16465)
  %object.i87 = extractvalue %Pos %z.i134, 1
  %isNull.i.i88 = icmp eq ptr %object.i87, null
  br i1 %isNull.i.i88, label %erasePositive.exit98, label %next.i.i89

next.i.i89:                                       ; preds = %sharePositive.exit51
  %referenceCount.i.i90 = load i64, ptr %object.i87, align 4
  %cond.i.i91 = icmp eq i64 %referenceCount.i.i90, 0
  br i1 %cond.i.i91, label %free.i.i94, label %decr.i.i92

decr.i.i92:                                       ; preds = %next.i.i89
  %referenceCount.1.i.i93 = add i64 %referenceCount.i.i90, -1
  store i64 %referenceCount.1.i.i93, ptr %object.i87, align 4
  br label %erasePositive.exit98

free.i.i94:                                       ; preds = %next.i.i89
  %objectEraser.i.i95 = getelementptr i8, ptr %object.i87, i64 8
  %eraser.i.i96 = load ptr, ptr %objectEraser.i.i95, align 8
  %environment.i.i.i97 = getelementptr i8, ptr %object.i87, i64 16
  tail call void %eraser.i.i96(ptr %environment.i.i.i97)
  tail call void @free(ptr nonnull %object.i87)
  br label %erasePositive.exit98

erasePositive.exit98:                             ; preds = %sharePositive.exit51, %decr.i.i92, %free.i.i94
  br i1 %isNull.i.i53, label %sharePositive.exit45, label %next.i.i42

next.i.i42:                                       ; preds = %erasePositive.exit98
  %referenceCount.i.i43 = load i64, ptr %object.i52, align 4
  %referenceCount.1.i.i44 = add i64 %referenceCount.i.i43, 1
  store i64 %referenceCount.1.i.i44, ptr %object.i52, align 4
  br label %sharePositive.exit45

sharePositive.exit45:                             ; preds = %erasePositive.exit98, %next.i.i42
  %z.i135 = tail call %Pos @c_array_set(%Pos %z.i, i64 2, %Pos %make_16477)
  %object.i75 = extractvalue %Pos %z.i135, 1
  %isNull.i.i76 = icmp eq ptr %object.i75, null
  br i1 %isNull.i.i76, label %erasePositive.exit86, label %next.i.i77

next.i.i77:                                       ; preds = %sharePositive.exit45
  %referenceCount.i.i78 = load i64, ptr %object.i75, align 4
  %cond.i.i79 = icmp eq i64 %referenceCount.i.i78, 0
  br i1 %cond.i.i79, label %free.i.i82, label %decr.i.i80

decr.i.i80:                                       ; preds = %next.i.i77
  %referenceCount.1.i.i81 = add i64 %referenceCount.i.i78, -1
  store i64 %referenceCount.1.i.i81, ptr %object.i75, align 4
  br label %erasePositive.exit86

free.i.i82:                                       ; preds = %next.i.i77
  %objectEraser.i.i83 = getelementptr i8, ptr %object.i75, i64 8
  %eraser.i.i84 = load ptr, ptr %objectEraser.i.i83, align 8
  %environment.i.i.i85 = getelementptr i8, ptr %object.i75, i64 16
  tail call void %eraser.i.i84(ptr %environment.i.i.i85)
  tail call void @free(ptr nonnull %object.i75)
  br label %erasePositive.exit86

erasePositive.exit86:                             ; preds = %sharePositive.exit45, %decr.i.i80, %free.i.i82
  br i1 %isNull.i.i53, label %sharePositive.exit39, label %next.i.i36

next.i.i36:                                       ; preds = %erasePositive.exit86
  %referenceCount.i.i37 = load i64, ptr %object.i52, align 4
  %referenceCount.1.i.i38 = add i64 %referenceCount.i.i37, 1
  store i64 %referenceCount.1.i.i38, ptr %object.i52, align 4
  br label %sharePositive.exit39

sharePositive.exit39:                             ; preds = %erasePositive.exit86, %next.i.i36
  %z.i136 = tail call %Pos @c_array_set(%Pos %z.i, i64 3, %Pos %make_16489)
  %object.i63 = extractvalue %Pos %z.i136, 1
  %isNull.i.i64 = icmp eq ptr %object.i63, null
  br i1 %isNull.i.i64, label %erasePositive.exit74, label %next.i.i65

next.i.i65:                                       ; preds = %sharePositive.exit39
  %referenceCount.i.i66 = load i64, ptr %object.i63, align 4
  %cond.i.i67 = icmp eq i64 %referenceCount.i.i66, 0
  br i1 %cond.i.i67, label %free.i.i70, label %decr.i.i68

decr.i.i68:                                       ; preds = %next.i.i65
  %referenceCount.1.i.i69 = add i64 %referenceCount.i.i66, -1
  store i64 %referenceCount.1.i.i69, ptr %object.i63, align 4
  br label %erasePositive.exit74

free.i.i70:                                       ; preds = %next.i.i65
  %objectEraser.i.i71 = getelementptr i8, ptr %object.i63, i64 8
  %eraser.i.i72 = load ptr, ptr %objectEraser.i.i71, align 8
  %environment.i.i.i73 = getelementptr i8, ptr %object.i63, i64 16
  tail call void %eraser.i.i72(ptr %environment.i.i.i73)
  tail call void @free(ptr nonnull %object.i63)
  br label %erasePositive.exit74

erasePositive.exit74:                             ; preds = %sharePositive.exit39, %decr.i.i68, %free.i.i70
  br i1 %isNull.i.i53, label %sharePositive.exit33, label %next.i.i30

next.i.i30:                                       ; preds = %erasePositive.exit74
  %referenceCount.i.i31 = load i64, ptr %object.i52, align 4
  %referenceCount.1.i.i32 = add i64 %referenceCount.i.i31, 1
  store i64 %referenceCount.1.i.i32, ptr %object.i52, align 4
  br label %sharePositive.exit33

sharePositive.exit33:                             ; preds = %erasePositive.exit74, %next.i.i30
  %z.i137 = tail call %Pos @c_array_set(%Pos %z.i, i64 4, %Pos %make_16501)
  %object.i58 = extractvalue %Pos %z.i137, 1
  %isNull.i.i59 = icmp eq ptr %object.i58, null
  br i1 %isNull.i.i59, label %erasePositive.exit, label %next.i.i60

next.i.i60:                                       ; preds = %sharePositive.exit33
  %referenceCount.i.i61 = load i64, ptr %object.i58, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i61, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i60
  %referenceCount.1.i.i62 = add i64 %referenceCount.i.i61, -1
  store i64 %referenceCount.1.i.i62, ptr %object.i58, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i60
  %objectEraser.i.i = getelementptr i8, ptr %object.i58, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i58, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i58)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit33, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i131, align 8, !alias.scope !0
  %limit.i140 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i140
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i141 = getelementptr i8, ptr %stack, i64 16
  %base.i142 = load ptr, ptr %base_pointer.i141, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i143 = ptrtoint ptr %base.i142 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i143
  %nextSize.i = add i64 %size.i, 32
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i142, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 32
  store ptr %newBase.i, ptr %base_pointer.i141, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i148 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i140, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i131, align 8
  store i64 %unboxed.i, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_1182 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_1183 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_1184 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_95, ptr %returnAddress_pointer_1182, align 8, !noalias !0
  store ptr @sharer_1173, ptr %sharer_pointer_1183, align 8, !noalias !0
  store ptr @eraser_1177, ptr %eraser_pointer_1184, align 8, !noalias !0
  %base_pointer.i122 = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i123 = load ptr, ptr %stackPointer_pointer.i131, align 8
  %base.i124 = load ptr, ptr %base_pointer.i122, align 8
  %intStack.i125 = ptrtoint ptr %stackPointer.i123 to i64
  %intBase.i126 = ptrtoint ptr %base.i124 to i64
  %offset.i127 = sub i64 %intStack.i125, %intBase.i126
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i144 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i149 = getelementptr i8, ptr %stackPointer.i123, i64 32
  %isInside.not.i150 = icmp ugt ptr %nextStackPointer.i149, %limit.i148
  br i1 %isInside.not.i150, label %realloc.i153, label %stackAllocate.exit167

realloc.i153:                                     ; preds = %stackAllocate.exit
  %nextSize.i159 = add i64 %offset.i127, 32
  %leadingZeros.i.i160 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i159, i1 false)
  %numBits.i.i161 = sub nuw nsw i64 64, %leadingZeros.i.i160
  %result.i.i162 = shl nuw i64 1, %numBits.i.i161
  %newBase.i163 = tail call ptr @realloc(ptr %base.i124, i64 %result.i.i162)
  %newLimit.i164 = getelementptr i8, ptr %newBase.i163, i64 %result.i.i162
  %newStackPointer.i165 = getelementptr i8, ptr %newBase.i163, i64 %offset.i127
  %newNextStackPointer.i166 = getelementptr i8, ptr %newStackPointer.i165, i64 32
  store ptr %newBase.i163, ptr %base_pointer.i122, align 8, !alias.scope !0
  store ptr %newLimit.i164, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit167

stackAllocate.exit167:                            ; preds = %stackAllocate.exit, %realloc.i153
  %limit.i173 = phi ptr [ %newLimit.i164, %realloc.i153 ], [ %limit.i148, %stackAllocate.exit ]
  %nextStackPointer.sink.i151 = phi ptr [ %newNextStackPointer.i166, %realloc.i153 ], [ %nextStackPointer.i149, %stackAllocate.exit ]
  %common.ret.op.i152 = phi ptr [ %newStackPointer.i165, %realloc.i153 ], [ %stackPointer.i123, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i151, ptr %stackPointer_pointer.i131, align 8
  store double 0.000000e+00, ptr %common.ret.op.i152, align 8, !noalias !0
  %returnAddress_pointer_1196 = getelementptr i8, ptr %common.ret.op.i152, i64 8
  %sharer_pointer_1197 = getelementptr i8, ptr %common.ret.op.i152, i64 16
  %eraser_pointer_1198 = getelementptr i8, ptr %common.ret.op.i152, i64 24
  store ptr @returnAddress_1185, ptr %returnAddress_pointer_1196, align 8, !noalias !0
  store ptr @sharer_714, ptr %sharer_pointer_1197, align 8, !noalias !0
  store ptr @eraser_718, ptr %eraser_pointer_1198, align 8, !noalias !0
  %stackPointer.i113 = load ptr, ptr %stackPointer_pointer.i131, align 8
  %base.i114 = load ptr, ptr %base_pointer.i122, align 8
  %intStack.i115 = ptrtoint ptr %stackPointer.i113 to i64
  %intBase.i116 = ptrtoint ptr %base.i114 to i64
  %offset.i117 = sub i64 %intStack.i115, %intBase.i116
  %prompt.i169 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i174 = getelementptr i8, ptr %stackPointer.i113, i64 32
  %isInside.not.i175 = icmp ugt ptr %nextStackPointer.i174, %limit.i173
  br i1 %isInside.not.i175, label %realloc.i178, label %stackAllocate.exit192

realloc.i178:                                     ; preds = %stackAllocate.exit167
  %nextSize.i184 = add i64 %offset.i117, 32
  %leadingZeros.i.i185 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i184, i1 false)
  %numBits.i.i186 = sub nuw nsw i64 64, %leadingZeros.i.i185
  %result.i.i187 = shl nuw i64 1, %numBits.i.i186
  %newBase.i188 = tail call ptr @realloc(ptr %base.i114, i64 %result.i.i187)
  %newLimit.i189 = getelementptr i8, ptr %newBase.i188, i64 %result.i.i187
  %newStackPointer.i190 = getelementptr i8, ptr %newBase.i188, i64 %offset.i117
  %newNextStackPointer.i191 = getelementptr i8, ptr %newStackPointer.i190, i64 32
  store ptr %newBase.i188, ptr %base_pointer.i122, align 8, !alias.scope !0
  store ptr %newLimit.i189, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit192

stackAllocate.exit192:                            ; preds = %stackAllocate.exit167, %realloc.i178
  %limit.i198 = phi ptr [ %newLimit.i189, %realloc.i178 ], [ %limit.i173, %stackAllocate.exit167 ]
  %nextStackPointer.sink.i176 = phi ptr [ %newNextStackPointer.i191, %realloc.i178 ], [ %nextStackPointer.i174, %stackAllocate.exit167 ]
  %common.ret.op.i177 = phi ptr [ %newStackPointer.i190, %realloc.i178 ], [ %stackPointer.i113, %stackAllocate.exit167 ]
  store ptr %nextStackPointer.sink.i176, ptr %stackPointer_pointer.i131, align 8
  store double 0.000000e+00, ptr %common.ret.op.i177, align 8, !noalias !0
  %returnAddress_pointer_1210 = getelementptr i8, ptr %common.ret.op.i177, i64 8
  %sharer_pointer_1211 = getelementptr i8, ptr %common.ret.op.i177, i64 16
  %eraser_pointer_1212 = getelementptr i8, ptr %common.ret.op.i177, i64 24
  store ptr @returnAddress_1199, ptr %returnAddress_pointer_1210, align 8, !noalias !0
  store ptr @sharer_714, ptr %sharer_pointer_1211, align 8, !noalias !0
  store ptr @eraser_718, ptr %eraser_pointer_1212, align 8, !noalias !0
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i131, align 8
  %base.i = load ptr, ptr %base_pointer.i122, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt.i194 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i199 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i200 = icmp ugt ptr %nextStackPointer.i199, %limit.i198
  br i1 %isInside.not.i200, label %realloc.i203, label %stackAllocate.exit217

realloc.i203:                                     ; preds = %stackAllocate.exit192
  %nextSize.i209 = add i64 %offset.i, 32
  %leadingZeros.i.i210 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i209, i1 false)
  %numBits.i.i211 = sub nuw nsw i64 64, %leadingZeros.i.i210
  %result.i.i212 = shl nuw i64 1, %numBits.i.i211
  %newBase.i213 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i212)
  %newLimit.i214 = getelementptr i8, ptr %newBase.i213, i64 %result.i.i212
  %newStackPointer.i215 = getelementptr i8, ptr %newBase.i213, i64 %offset.i
  %newNextStackPointer.i216 = getelementptr i8, ptr %newStackPointer.i215, i64 32
  store ptr %newBase.i213, ptr %base_pointer.i122, align 8, !alias.scope !0
  store ptr %newLimit.i214, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit217

stackAllocate.exit217:                            ; preds = %stackAllocate.exit192, %realloc.i203
  %nextStackPointer.sink.i201 = phi ptr [ %newNextStackPointer.i216, %realloc.i203 ], [ %nextStackPointer.i199, %stackAllocate.exit192 ]
  %common.ret.op.i202 = phi ptr [ %newStackPointer.i215, %realloc.i203 ], [ %stackPointer.i, %stackAllocate.exit192 ]
  store ptr %nextStackPointer.sink.i201, ptr %stackPointer_pointer.i131, align 8
  store double 0.000000e+00, ptr %common.ret.op.i202, align 8, !noalias !0
  %returnAddress_pointer_1224 = getelementptr i8, ptr %common.ret.op.i202, i64 8
  %sharer_pointer_1225 = getelementptr i8, ptr %common.ret.op.i202, i64 16
  %eraser_pointer_1226 = getelementptr i8, ptr %common.ret.op.i202, i64 24
  store ptr @returnAddress_1213, ptr %returnAddress_pointer_1224, align 8, !noalias !0
  store ptr @sharer_714, ptr %sharer_pointer_1225, align 8, !noalias !0
  store ptr @eraser_718, ptr %eraser_pointer_1226, align 8, !noalias !0
  br i1 %isNull.i.i53, label %sharePositive.exit27.thread, label %next.i.i

sharePositive.exit27.thread:                      ; preds = %stackAllocate.exit217
  %z.i218242 = tail call i64 @c_array_size(%Pos %z.i)
  br label %sharePositive.exit

next.i.i:                                         ; preds = %stackAllocate.exit217
  %referenceCount.i.i25 = load i64, ptr %object.i52, align 4
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i25, 1
  store i64 %referenceCount.1.i.i26, ptr %object.i52, align 4
  %z.i218 = tail call i64 @c_array_size(%Pos %z.i)
  %referenceCount.i.i = load i64, ptr %object.i52, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i52, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit27.thread, %next.i.i
  %z.i218243 = phi i64 [ %z.i218242, %sharePositive.exit27.thread ], [ %z.i218, %next.i.i ]
  %currentStackPointer.i221 = load ptr, ptr %stackPointer_pointer.i131, align 8, !alias.scope !0
  %limit.i222 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i223 = getelementptr i8, ptr %currentStackPointer.i221, i64 96
  %isInside.not.i224 = icmp ugt ptr %nextStackPointer.i223, %limit.i222
  br i1 %isInside.not.i224, label %realloc.i227, label %stackAllocate.exit241

realloc.i227:                                     ; preds = %sharePositive.exit
  %base.i229 = load ptr, ptr %base_pointer.i122, align 8, !alias.scope !0
  %intStackPointer.i230 = ptrtoint ptr %currentStackPointer.i221 to i64
  %intBase.i231 = ptrtoint ptr %base.i229 to i64
  %size.i232 = sub i64 %intStackPointer.i230, %intBase.i231
  %nextSize.i233 = add i64 %size.i232, 96
  %leadingZeros.i.i234 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i233, i1 false)
  %numBits.i.i235 = sub nuw nsw i64 64, %leadingZeros.i.i234
  %result.i.i236 = shl nuw i64 1, %numBits.i.i235
  %newBase.i237 = tail call ptr @realloc(ptr %base.i229, i64 %result.i.i236)
  %newLimit.i238 = getelementptr i8, ptr %newBase.i237, i64 %result.i.i236
  %newStackPointer.i239 = getelementptr i8, ptr %newBase.i237, i64 %size.i232
  %newNextStackPointer.i240 = getelementptr i8, ptr %newStackPointer.i239, i64 96
  store ptr %newBase.i237, ptr %base_pointer.i122, align 8, !alias.scope !0
  store ptr %newLimit.i238, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit241

stackAllocate.exit241:                            ; preds = %sharePositive.exit, %realloc.i227
  %nextStackPointer.sink.i225 = phi ptr [ %newNextStackPointer.i240, %realloc.i227 ], [ %nextStackPointer.i223, %sharePositive.exit ]
  %common.ret.op.i226 = phi ptr [ %newStackPointer.i239, %realloc.i227 ], [ %currentStackPointer.i221, %sharePositive.exit ]
  %reference..1.i = insertvalue %Reference undef, ptr %prompt.i194, 0
  %reference.i = insertvalue %Reference %reference..1.i, i64 %offset.i, 1
  %reference..1.i119 = insertvalue %Reference undef, ptr %prompt.i169, 0
  %reference.i120 = insertvalue %Reference %reference..1.i119, i64 %offset.i117, 1
  %reference..1.i129 = insertvalue %Reference undef, ptr %prompt.i144, 0
  %reference.i130 = insertvalue %Reference %reference..1.i129, i64 %offset.i127, 1
  store ptr %nextStackPointer.sink.i225, ptr %stackPointer_pointer.i131, align 8
  %pureApp_16517.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_16517.elt, ptr %common.ret.op.i226, align 8, !noalias !0
  %stackPointer_1743.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i226, i64 8
  store ptr %object.i52, ptr %stackPointer_1743.repack1, align 8, !noalias !0
  %py_11_2079_10749_pointer_1745 = getelementptr i8, ptr %common.ret.op.i226, i64 16
  store ptr %prompt.i169, ptr %py_11_2079_10749_pointer_1745, align 8, !noalias !0
  %py_11_2079_10749_pointer_1745.repack3 = getelementptr i8, ptr %common.ret.op.i226, i64 24
  store i64 %offset.i117, ptr %py_11_2079_10749_pointer_1745.repack3, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1746 = getelementptr i8, ptr %common.ret.op.i226, i64 32
  store ptr %prompt.i194, ptr %pz_13_2081_11683_pointer_1746, align 8, !noalias !0
  %pz_13_2081_11683_pointer_1746.repack5 = getelementptr i8, ptr %common.ret.op.i226, i64 40
  store i64 %offset.i, ptr %pz_13_2081_11683_pointer_1746.repack5, align 8, !noalias !0
  %tmp_16294_pointer_1747 = getelementptr i8, ptr %common.ret.op.i226, i64 48
  store double 0x4043BD3CC9BE45DE, ptr %tmp_16294_pointer_1747, align 8, !noalias !0
  %px_9_2077_11716_pointer_1748 = getelementptr i8, ptr %common.ret.op.i226, i64 56
  store ptr %prompt.i144, ptr %px_9_2077_11716_pointer_1748, align 8, !noalias !0
  %px_9_2077_11716_pointer_1748.repack7 = getelementptr i8, ptr %common.ret.op.i226, i64 64
  store i64 %offset.i127, ptr %px_9_2077_11716_pointer_1748.repack7, align 8, !noalias !0
  %returnAddress_pointer_1749 = getelementptr i8, ptr %common.ret.op.i226, i64 72
  %sharer_pointer_1750 = getelementptr i8, ptr %common.ret.op.i226, i64 80
  %eraser_pointer_1751 = getelementptr i8, ptr %common.ret.op.i226, i64 88
  store ptr @returnAddress_1575, ptr %returnAddress_pointer_1749, align 8, !noalias !0
  store ptr @sharer_1724, ptr %sharer_pointer_1750, align 8, !noalias !0
  store ptr @eraser_1736, ptr %eraser_pointer_1751, align 8, !noalias !0
  musttail call tailcc void @loop_5_9_138_2206_10607(i64 0, %Pos %z.i, %Reference %reference.i120, %Reference %reference.i, i64 %z.i218243, %Reference %reference.i130, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1757(%Pos %returned_16691, ptr nocapture %stack) {
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
  %returnAddress_1759 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1759(%Pos %returned_16691, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_1762(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_1764(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define void @eraser_1777(ptr nocapture readonly %environment) {
entry:
  %tmp_16266_1775.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_16266_1775.unpack2 = load ptr, ptr %tmp_16266_1775.elt1, align 8, !noalias !0
  %acc_3_3_5_169_10111_1776.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_10111_1776.unpack5 = load ptr, ptr %acc_3_3_5_169_10111_1776.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_16266_1775.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_16266_1775.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_16266_1775.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_16266_1775.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_16266_1775.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_16266_1775.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_10111_1776.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_10111_1776.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_10111_1776.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_10111_1776.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_10111_1776.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_10111_1776.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_10159(i64 %start_2_2_4_168_10110, %Pos %acc_3_3_5_169_10111, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_10110, 1
  br i1 %z.i6, label %label_1787, label %label_1783

label_1783:                                       ; preds = %entry, %label_1783
  %acc_3_3_5_169_10111.tr8 = phi %Pos [ %make_16697, %label_1783 ], [ %acc_3_3_5_169_10111, %entry ]
  %start_2_2_4_168_10110.tr7 = phi i64 [ %z.i5, %label_1783 ], [ %start_2_2_4_168_10110, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_10110.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_10110.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1777, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_16694.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_16694.elt, ptr %environment.i, align 8, !noalias !0
  %environment_1774.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_16694.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_16694.elt2, ptr %environment_1774.repack1, align 8, !noalias !0
  %acc_3_3_5_169_10111_pointer_1781 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_10111.elt = extractvalue %Pos %acc_3_3_5_169_10111.tr8, 0
  store i64 %acc_3_3_5_169_10111.elt, ptr %acc_3_3_5_169_10111_pointer_1781, align 8, !noalias !0
  %acc_3_3_5_169_10111_pointer_1781.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_10111.elt4 = extractvalue %Pos %acc_3_3_5_169_10111.tr8, 1
  store ptr %acc_3_3_5_169_10111.elt4, ptr %acc_3_3_5_169_10111_pointer_1781.repack3, align 8, !noalias !0
  %make_16697 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_10110.tr7, 2
  br i1 %z.i, label %label_1787, label %label_1783

label_1787:                                       ; preds = %label_1783, %entry
  %acc_3_3_5_169_10111.tr.lcssa = phi %Pos [ %acc_3_3_5_169_10111, %entry ], [ %make_16697, %label_1783 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1784 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1784(%Pos %acc_3_3_5_169_10111.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1798(%Pos %v_r_3332_32_59_223_10283, ptr %stack) {
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
  %p_8_9_9994 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16273_pointer_1801 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_16273 = load i64, ptr %tmp_16273_pointer_1801, align 4, !noalias !0
  %index_7_34_198_10231_pointer_1802 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %index_7_34_198_10231 = load i64, ptr %index_7_34_198_10231_pointer_1802, align 4, !noalias !0
  %v_r_3145_30_194_10257_pointer_1803 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_3145_30_194_10257.unpack = load i64, ptr %v_r_3145_30_194_10257_pointer_1803, align 8, !noalias !0
  %v_r_3145_30_194_10257.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_3145_30_194_10257.unpack2 = load ptr, ptr %v_r_3145_30_194_10257.elt1, align 8, !noalias !0
  %acc_8_35_199_10120_pointer_1804 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %acc_8_35_199_10120 = load i64, ptr %acc_8_35_199_10120_pointer_1804, align 4, !noalias !0
  %tag_1805 = extractvalue %Pos %v_r_3332_32_59_223_10283, 0
  %fields_1806 = extractvalue %Pos %v_r_3332_32_59_223_10283, 1
  switch i64 %tag_1805, label %common.ret [
    i64 1, label %label_1830
    i64 0, label %label_1837
  ]

common.ret:                                       ; preds = %entry
  ret void

label_1818:                                       ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_3145_30_194_10257.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_1818
  %referenceCount.i.i37 = load i64, ptr %v_r_3145_30_194_10257.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_3145_30_194_10257.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_3145_30_194_10257.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_3145_30_194_10257.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_3145_30_194_10257.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_1818, %decr.i.i39, %free.i.i41
  %pair_1813 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_9994)
  %k_13_14_4_16073 = extractvalue <{ ptr, ptr }> %pair_1813, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_16073, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_16073, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_16073, i64 40
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
  %stack_1814 = extractvalue <{ ptr, ptr }> %pair_1813, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_1814, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_1814, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_1815 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1815(%Pos { i64 10, ptr null }, ptr %stack_1814)
  ret void

label_1827:                                       ; preds = %label_1829
  %isNull.i.i24 = icmp eq ptr %v_r_3145_30_194_10257.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_1827
  %referenceCount.i.i26 = load i64, ptr %v_r_3145_30_194_10257.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_3145_30_194_10257.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_3145_30_194_10257.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_3145_30_194_10257.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_3145_30_194_10257.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_1827, %decr.i.i28, %free.i.i30
  %pair_1822 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_9994)
  %k_13_14_4_16072 = extractvalue <{ ptr, ptr }> %pair_1822, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_16072, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_16072, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_16072, i64 40
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
  %stack_1823 = extractvalue <{ ptr, ptr }> %pair_1822, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_1823, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_1823, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_1824 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1824(%Pos { i64 10, ptr null }, ptr %stack_1823)
  ret void

label_1828:                                       ; preds = %label_1829
  %0 = insertvalue %Pos poison, i64 %v_r_3145_30_194_10257.unpack, 0
  %v_r_3145_30_194_102573 = insertvalue %Pos %0, ptr %v_r_3145_30_194_10257.unpack2, 1
  %z.i = add i64 %index_7_34_198_10231, 1
  %z.i108 = mul i64 %acc_8_35_199_10120, 10
  %z.i109 = sub i64 %z.i108, %tmp_16273
  %z.i110 = add i64 %z.i109, %v_coe_4150_46_73_237_10092.unpack
  musttail call tailcc void @go_6_33_197_10203(i64 %z.i, i64 %z.i110, ptr %p_8_9_9994, i64 %tmp_16273, %Pos %v_r_3145_30_194_102573, ptr nonnull %stack)
  ret void

label_1829:                                       ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_4150_46_73_237_10092.unpack, 58
  br i1 %z.i111, label %label_1828, label %label_1827

label_1830:                                       ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_1806, i64 16
  %v_coe_4150_46_73_237_10092.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_4150_46_73_237_10092.elt4 = getelementptr i8, ptr %fields_1806, i64 24
  %v_coe_4150_46_73_237_10092.unpack5 = load ptr, ptr %v_coe_4150_46_73_237_10092.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_4150_46_73_237_10092.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_1830
  %referenceCount.i.i = load i64, ptr %v_coe_4150_46_73_237_10092.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_4150_46_73_237_10092.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_1830
  %referenceCount.i11 = load i64, ptr %fields_1806, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_1806, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_1806, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_1806)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_4150_46_73_237_10092.unpack, 47
  br i1 %z.i112, label %label_1829, label %label_1818

label_1837:                                       ; preds = %entry
  %isNull.i = icmp eq ptr %fields_1806, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_1837
  %referenceCount.i = load i64, ptr %fields_1806, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_1806, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_1806, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_1806, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_1806)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_1837, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_3145_30_194_10257.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_3145_30_194_10257.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_3145_30_194_10257.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3145_30_194_10257.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3145_30_194_10257.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3145_30_194_10257.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1834 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1834(i64 %acc_8_35_199_10120, ptr nonnull %stack)
  ret void
}

define void @sharer_1843(ptr %stackPointer) {
entry:
  %v_r_3145_30_194_10257_1841.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_3145_30_194_10257_1841.unpack2 = load ptr, ptr %v_r_3145_30_194_10257_1841.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3145_30_194_10257_1841.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3145_30_194_10257_1841.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3145_30_194_10257_1841.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1855(ptr %stackPointer) {
entry:
  %v_r_3145_30_194_10257_1853.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_3145_30_194_10257_1853.unpack2 = load ptr, ptr %v_r_3145_30_194_10257_1853.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3145_30_194_10257_1853.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3145_30_194_10257_1853.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3145_30_194_10257_1853.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3145_30_194_10257_1853.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3145_30_194_10257_1853.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3145_30_194_10257_1853.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1872(%Pos %returned_16722, ptr nocapture %stack) {
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
  %returnAddress_1874 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1874(%Pos %returned_16722, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_10166_clause_1881(ptr %closure, %Pos %exc_8_20_47_211_10187, %Pos %msg_9_21_48_212_10059, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_10310 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_1884 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_10310)
  %k_11_23_50_214_10319 = extractvalue <{ ptr, ptr }> %pair_1884, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_10319, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_10319, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_10319, i64 40
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
  %stack_1885 = extractvalue <{ ptr, ptr }> %pair_1884, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1777, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_10187.elt = extractvalue %Pos %exc_8_20_47_211_10187, 0
  store i64 %exc_8_20_47_211_10187.elt, ptr %environment.i, align 8, !noalias !0
  %environment_1887.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_10187.elt2 = extractvalue %Pos %exc_8_20_47_211_10187, 1
  store ptr %exc_8_20_47_211_10187.elt2, ptr %environment_1887.repack1, align 8, !noalias !0
  %msg_9_21_48_212_10059_pointer_1891 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_10059.elt = extractvalue %Pos %msg_9_21_48_212_10059, 0
  store i64 %msg_9_21_48_212_10059.elt, ptr %msg_9_21_48_212_10059_pointer_1891, align 8, !noalias !0
  %msg_9_21_48_212_10059_pointer_1891.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_10059.elt4 = extractvalue %Pos %msg_9_21_48_212_10059, 1
  store ptr %msg_9_21_48_212_10059.elt4, ptr %msg_9_21_48_212_10059_pointer_1891.repack3, align 8, !noalias !0
  %make_16723 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_1885, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_1885, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_1893 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1893(%Pos %make_16723, ptr %stack_1885)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_1900(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_1908(ptr nocapture readonly %environment) {
entry:
  %tmp_16275_1907.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_16275_1907.unpack2 = load ptr, ptr %tmp_16275_1907.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_16275_1907.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_16275_1907.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_16275_1907.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_16275_1907.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_16275_1907.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_16275_1907.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_1904(i64 %v_coe_4149_6_28_55_219_10202, ptr %stack) {
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
  store ptr @eraser_1908, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_4149_6_28_55_219_10202, ptr %environment.i, align 8, !noalias !0
  %environment_1906.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_1906.repack1, align 8, !noalias !0
  %make_16725 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1912 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1912(%Pos %make_16725, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_10203(i64 %index_7_34_198_10231, i64 %acc_8_35_199_10120, ptr %p_8_9_9994, i64 %tmp_16273, %Pos %v_r_3145_30_194_10257, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_3145_30_194_10257, 1
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
  store ptr %p_8_9_9994, ptr %common.ret.op.i, align 8, !noalias !0
  %tmp_16273_pointer_1864 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_16273, ptr %tmp_16273_pointer_1864, align 4, !noalias !0
  %index_7_34_198_10231_pointer_1865 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_7_34_198_10231, ptr %index_7_34_198_10231_pointer_1865, align 4, !noalias !0
  %v_r_3145_30_194_10257_pointer_1866 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %v_r_3145_30_194_10257.elt = extractvalue %Pos %v_r_3145_30_194_10257, 0
  store i64 %v_r_3145_30_194_10257.elt, ptr %v_r_3145_30_194_10257_pointer_1866, align 8, !noalias !0
  %v_r_3145_30_194_10257_pointer_1866.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %object.i3, ptr %v_r_3145_30_194_10257_pointer_1866.repack1, align 8, !noalias !0
  %acc_8_35_199_10120_pointer_1867 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %acc_8_35_199_10120, ptr %acc_8_35_199_10120_pointer_1867, align 4, !noalias !0
  %returnAddress_pointer_1868 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1869 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1870 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_1798, ptr %returnAddress_pointer_1868, align 8, !noalias !0
  store ptr @sharer_1843, ptr %sharer_pointer_1869, align 8, !noalias !0
  store ptr @eraser_1855, ptr %eraser_pointer_1870, align 8, !noalias !0
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
  %sharer_pointer_1879 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_1880 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_1872, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_1762, ptr %sharer_pointer_1879, align 8, !noalias !0
  store ptr @eraser_1764, ptr %eraser_pointer_1880, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1900, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_10166 = insertvalue %Neg { ptr @vtable_1896, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_1917 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_1918 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_1904, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_698, ptr %sharer_pointer_1917, align 8, !noalias !0
  store ptr @eraser_700, ptr %eraser_pointer_1918, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_3145_30_194_10257, i64 %index_7_34_198_10231, %Neg %Exception_7_19_46_210_10166, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_10062_clause_1919(ptr %closure, %Pos %exception_10_107_134_298_16726, %Pos %msg_11_108_135_299_16727, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_9994 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_16726, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_16727, 1
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
  %pair_1922 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_9994)
  %k_13_14_4_16256 = extractvalue <{ ptr, ptr }> %pair_1922, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_16256, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_16256, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_16256, i64 40
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
  %stack_1923 = extractvalue <{ ptr, ptr }> %pair_1922, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_1923, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_1923, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_1924 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1924(%Pos { i64 10, ptr null }, ptr %stack_1923)
  ret void
}

define tailcc void @returnAddress_1938(i64 %v_coe_4154_22_131_158_322_10096, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_4154_22_131_158_322_10096, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1939 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1939(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1950(i64 %v_r_3346_1_9_20_129_156_320_10311, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_3346_1_9_20_129_156_320_10311
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1951 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1951(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1933(i64 %v_r_3345_3_14_123_150_314_10196, ptr %stack) {
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
  %p_8_9_9994 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_16273_pointer_1936 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_16273 = load i64, ptr %tmp_16273_pointer_1936, align 4, !noalias !0
  %v_r_3145_30_194_10257_pointer_1937 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_3145_30_194_10257.unpack = load i64, ptr %v_r_3145_30_194_10257_pointer_1937, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_3145_30_194_10257.unpack, 0
  %v_r_3145_30_194_10257.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_3145_30_194_10257.unpack2 = load ptr, ptr %v_r_3145_30_194_10257.elt1, align 8, !noalias !0
  %v_r_3145_30_194_102573 = insertvalue %Pos %0, ptr %v_r_3145_30_194_10257.unpack2, 1
  %z.i = icmp eq i64 %v_r_3345_3_14_123_150_314_10196, 45
  %isInside.not.i = icmp ugt ptr %v_r_3145_30_194_10257.elt1, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %v_r_3145_30_194_10257.elt1, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_1944 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_1945 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1938, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_698, ptr %sharer_pointer_1944, align 8, !noalias !0
  store ptr @eraser_700, ptr %eraser_pointer_1945, align 8, !noalias !0
  br i1 %z.i, label %label_1958, label %label_1949

label_1949:                                       ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_10203(i64 0, i64 0, ptr %p_8_9_9994, i64 %tmp_16273, %Pos %v_r_3145_30_194_102573, ptr nonnull %stack)
  ret void

label_1958:                                       ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_1958
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

stackAllocate.exit35:                             ; preds = %label_1958, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_1958 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_1958 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_1956 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_1957 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_1950, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_698, ptr %sharer_pointer_1956, align 8, !noalias !0
  store ptr @eraser_700, ptr %eraser_pointer_1957, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_10203(i64 1, i64 0, ptr %p_8_9_9994, i64 %tmp_16273, %Pos %v_r_3145_30_194_102573, ptr nonnull %stack)
  ret void
}

define void @sharer_1962(ptr %stackPointer) {
entry:
  %v_r_3145_30_194_10257_1961.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_3145_30_194_10257_1961.unpack2 = load ptr, ptr %v_r_3145_30_194_10257_1961.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3145_30_194_10257_1961.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3145_30_194_10257_1961.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3145_30_194_10257_1961.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1970(ptr %stackPointer) {
entry:
  %v_r_3145_30_194_10257_1969.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_3145_30_194_10257_1969.unpack2 = load ptr, ptr %v_r_3145_30_194_10257_1969.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3145_30_194_10257_1969.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3145_30_194_10257_1969.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3145_30_194_10257_1969.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3145_30_194_10257_1969.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3145_30_194_10257_1969.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3145_30_194_10257_1969.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1795(%Pos %v_r_3145_30_194_10257, ptr %stack) {
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
  %p_8_9_9994 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1900, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_9994, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_3145_30_194_10257, 1
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
  store ptr %p_8_9_9994, ptr %common.ret.op.i, align 8, !noalias !0
  %tmp_16273_pointer_1977 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 48, ptr %tmp_16273_pointer_1977, align 4, !noalias !0
  %v_r_3145_30_194_10257_pointer_1978 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_3145_30_194_10257.elt = extractvalue %Pos %v_r_3145_30_194_10257, 0
  store i64 %v_r_3145_30_194_10257.elt, ptr %v_r_3145_30_194_10257_pointer_1978, align 8, !noalias !0
  %v_r_3145_30_194_10257_pointer_1978.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i3, ptr %v_r_3145_30_194_10257_pointer_1978.repack1, align 8, !noalias !0
  %returnAddress_pointer_1979 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_1980 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_1981 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_1933, ptr %returnAddress_pointer_1979, align 8, !noalias !0
  store ptr @sharer_1962, ptr %sharer_pointer_1980, align 8, !noalias !0
  store ptr @eraser_1970, ptr %eraser_pointer_1981, align 8, !noalias !0
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
  store i64 %v_r_3145_30_194_10257.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_2076.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_2076.repack1.i, align 8, !noalias !0
  %index_2107_pointer_2078.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_2078.i, align 4, !noalias !0
  %Exception_2362_pointer_2079.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_1927, ptr %Exception_2362_pointer_2079.i, align 8, !noalias !0
  %Exception_2362_pointer_2079.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_2079.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_2080.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_2081.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_2082.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_2042, ptr %returnAddress_pointer_2080.i, align 8, !noalias !0
  store ptr @sharer_2063, ptr %sharer_pointer_2081.i, align 8, !noalias !0
  store ptr @eraser_2071, ptr %eraser_pointer_2082.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_3145_30_194_10257)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_2086.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2086.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_1983(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1987(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1792(%Pos %v_r_3144_24_188_10108, ptr %stack) {
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
  %p_8_9_9994 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_9994, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_1993 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1994 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1795, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1983, ptr %sharer_pointer_1993, align 8, !noalias !0
  store ptr @eraser_1987, ptr %eraser_pointer_1994, align 8, !noalias !0
  %tag_1995 = extractvalue %Pos %v_r_3144_24_188_10108, 0
  switch i64 %tag_1995, label %label_1997 [
    i64 0, label %label_2001
    i64 1, label %label_2007
  ]

label_1997:                                       ; preds = %stackAllocate.exit
  ret void

label_2001:                                       ; preds = %stackAllocate.exit
  %utf8StringLiteral_16742 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_16742.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1998 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1998(%Pos %utf8StringLiteral_16742, ptr nonnull %stack)
  ret void

label_2007:                                       ; preds = %stackAllocate.exit
  %fields_1996 = extractvalue %Pos %v_r_3144_24_188_10108, 1
  %environment.i = getelementptr i8, ptr %fields_1996, i64 16
  %v_y_3976_8_29_193_10125.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3976_8_29_193_10125.elt1 = getelementptr i8, ptr %fields_1996, i64 24
  %v_y_3976_8_29_193_10125.unpack2 = load ptr, ptr %v_y_3976_8_29_193_10125.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3976_8_29_193_10125.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_2007
  %referenceCount.i.i = load i64, ptr %v_y_3976_8_29_193_10125.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3976_8_29_193_10125.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_2007
  %referenceCount.i = load i64, ptr %fields_1996, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_1996, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_1996, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_1996)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3976_8_29_193_10125.unpack, 0
  %v_y_3976_8_29_193_101253 = insertvalue %Pos %0, ptr %v_y_3976_8_29_193_10125.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_2004 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2004(%Pos %v_y_3976_8_29_193_101253, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1789(%Pos %v_r_3143_13_177_10243, ptr %stack) {
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
  %p_8_9_9994 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_9994, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_2013 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_2014 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1792, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1983, ptr %sharer_pointer_2013, align 8, !noalias !0
  store ptr @eraser_1987, ptr %eraser_pointer_2014, align 8, !noalias !0
  %tag_2015 = extractvalue %Pos %v_r_3143_13_177_10243, 0
  switch i64 %tag_2015, label %label_2017 [
    i64 0, label %label_2022
    i64 1, label %label_2034
  ]

label_2017:                                       ; preds = %stackAllocate.exit
  ret void

label_2022:                                       ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_9994, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_1795, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1983, ptr %sharer_pointer_2013, align 8, !noalias !0
  store ptr @eraser_1987, ptr %eraser_pointer_2014, align 8, !noalias !0
  %utf8StringLiteral_16742.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_16742.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1998.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1998.i(%Pos %utf8StringLiteral_16742.i, ptr nonnull %stack)
  ret void

label_2034:                                       ; preds = %stackAllocate.exit
  %fields_2016 = extractvalue %Pos %v_r_3143_13_177_10243, 1
  %environment.i6 = getelementptr i8, ptr %fields_2016, i64 16
  %v_y_3485_10_21_185_10240.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_3485_10_21_185_10240.elt1 = getelementptr i8, ptr %fields_2016, i64 24
  %v_y_3485_10_21_185_10240.unpack2 = load ptr, ptr %v_y_3485_10_21_185_10240.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3485_10_21_185_10240.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_2034
  %referenceCount.i.i = load i64, ptr %v_y_3485_10_21_185_10240.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3485_10_21_185_10240.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_2034
  %referenceCount.i = load i64, ptr %fields_2016, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_2016, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_2016, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_2016)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_1908, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_3485_10_21_185_10240.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_2027.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_3485_10_21_185_10240.unpack2, ptr %environment_2027.repack4, align 8, !noalias !0
  %make_16744 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_2031 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2031(%Pos %make_16744, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2855(ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_1754 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_1755 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_698, ptr %sharer_pointer_1754, align 8, !noalias !0
  store ptr @eraser_700, ptr %eraser_pointer_1755, align 8, !noalias !0
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
  %sharer_pointer_1768 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_1769 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_1757, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_1762, ptr %sharer_pointer_1768, align 8, !noalias !0
  store ptr @eraser_1764, ptr %eraser_pointer_1769, align 8, !noalias !0
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
  %returnAddress_pointer_2039 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_2040 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_2041 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_1789, ptr %returnAddress_pointer_2039, align 8, !noalias !0
  store ptr @sharer_1983, ptr %sharer_pointer_2040, align 8, !noalias !0
  store ptr @eraser_1987, ptr %eraser_pointer_2041, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_1787.i, label %label_1783.i

label_1783.i:                                     ; preds = %stackAllocate.exit46, %label_1783.i
  %acc_3_3_5_169_10111.tr8.i = phi %Pos [ %make_16697.i, %label_1783.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_10110.tr7.i = phi i64 [ %z.i5.i, %label_1783.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_10110.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_10110.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_1777, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_16694.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_16694.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_1774.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_16694.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_16694.elt2.i, ptr %environment_1774.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_10111_pointer_1781.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_10111.elt.i = extractvalue %Pos %acc_3_3_5_169_10111.tr8.i, 0
  store i64 %acc_3_3_5_169_10111.elt.i, ptr %acc_3_3_5_169_10111_pointer_1781.i, align 8, !noalias !0
  %acc_3_3_5_169_10111_pointer_1781.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_10111.elt4.i = extractvalue %Pos %acc_3_3_5_169_10111.tr8.i, 1
  store ptr %acc_3_3_5_169_10111.elt4.i, ptr %acc_3_3_5_169_10111_pointer_1781.repack3.i, align 8, !noalias !0
  %make_16697.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_10110.tr7.i, 2
  br i1 %z.i.i, label %label_1787.i.loopexit, label %label_1783.i

label_1787.i.loopexit:                            ; preds = %label_1783.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_1787.i

label_1787.i:                                     ; preds = %label_1787.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_1787.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_1787.i.loopexit ]
  %acc_3_3_5_169_10111.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_16697.i, %label_1787.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_1784.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1784.i(%Pos %acc_3_3_5_169_10111.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_2042(%Pos %v_r_3414_4212, ptr %stack) {
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
  %index_2107_pointer_2045 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_2045, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_2047 = extractvalue %Pos %v_r_3414_4212, 0
  switch i64 %tag_2047, label %label_2049 [
    i64 0, label %label_2053
    i64 1, label %label_2059
  ]

label_2049:                                       ; preds = %entry
  ret void

label_2053:                                       ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_2053
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

eraseNegative.exit:                               ; preds = %label_2053, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_2050 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2050(i64 %x.i, ptr nonnull %stack)
  ret void

label_2059:                                       ; preds = %entry
  %Exception_2362_pointer_2046 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_2046, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_16442 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_16442.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_16442, %Pos %z.i)
  %utf8StringLiteral_16444 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_16444.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_16444)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_16447 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_16447.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_16447)
  %functionPointer_2058 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_2058(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_2063(ptr %stackPointer) {
entry:
  %str_2106_2060.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_2060.unpack2 = load ptr, ptr %str_2106_2060.elt1, align 8, !noalias !0
  %Exception_2362_2062.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_2062.unpack5 = load ptr, ptr %Exception_2362_2062.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_2060.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_2060.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_2060.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_2062.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_2062.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_2062.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_2071(ptr %stackPointer) {
entry:
  %str_2106_2068.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_2068.unpack2 = load ptr, ptr %str_2106_2068.elt1, align 8, !noalias !0
  %Exception_2362_2070.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_2070.unpack5 = load ptr, ptr %Exception_2362_2070.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_2068.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_2068.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_2068.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_2068.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_2068.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_2068.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_2070.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_2070.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_2070.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_2070.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_2070.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_2070.unpack5)
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
  %stackPointer_2076.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_2076.repack1, align 8, !noalias !0
  %index_2107_pointer_2078 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_2078, align 4, !noalias !0
  %Exception_2362_pointer_2079 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_2079, align 8, !noalias !0
  %Exception_2362_pointer_2079.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_2079.repack3, align 8, !noalias !0
  %returnAddress_pointer_2080 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_2081 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_2082 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_2042, ptr %returnAddress_pointer_2080, align 8, !noalias !0
  store ptr @sharer_2063, ptr %sharer_pointer_2081, align 8, !noalias !0
  store ptr @eraser_2071, ptr %eraser_pointer_2082, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_2089, label %label_2094

label_2089:                                       ; preds = %stackAllocate.exit
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
  %returnAddress_2086 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2086(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_2094:                                       ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_2094
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

erasePositive.exit:                               ; preds = %label_2094, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_2091 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_2091(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  tail call tailcc void @main_2855(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2855(ptr nonnull %stack.i2.i)
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
