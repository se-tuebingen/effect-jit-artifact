; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:bounce_87820433-f31f-420f-9320-495d76d7a218/bounce.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:bounce_87820433-f31f-420f-9320-495d76d7a218/bounce.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_194 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_8077_clause_179]
@vtable_225 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_7992_clause_217]
@utf8StringLiteral_8729.lit = private constant [0 x i8] zeroinitializer
@vtable_816 = private constant [1 x ptr] [ptr @new_8539_clause_488]
@utf8StringLiteral_8464.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_8466.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_8469.lit = private constant [1 x i8] c"'"

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

declare %Pos @c_ref_fresh(%Pos) local_unnamed_addr

declare %Pos @c_ref_get(%Pos) local_unnamed_addr

declare %Pos @c_ref_set(%Pos, %Pos) local_unnamed_addr

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
define double @infixAdd_111(double %x_109, double %y_110) local_unnamed_addr #5 {
  %z = fadd double %x_109, %y_110
  ret double %z
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define double @infixSub_117(double %x_115, double %y_116) local_unnamed_addr #5 {
  %z = fsub double %x_115, %y_116
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
define %Pos @infixLt_196(double %x_194, double %y_195) local_unnamed_addr #5 {
  %z = fcmp olt double %x_194, %y_195
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
define i64 @bitwiseAnd_234(i64 %x_232, i64 %y_233) local_unnamed_addr #5 {
  %z = and i64 %y_233, %x_232
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
define %Pos @boxDouble_321(double %d_320) local_unnamed_addr #5 {
  %n = bitcast double %d_320 to i64
  %boxed1 = insertvalue %Pos zeroinitializer, i64 %n, 0
  %boxed2 = insertvalue %Pos %boxed1, ptr null, 1
  ret %Pos %boxed2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define double @unboxDouble_323(%Pos %b_322) local_unnamed_addr #5 {
  %unboxed = extractvalue %Pos %b_322, 0
  %d = bitcast i64 %unboxed to double
  ret double %d
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

define %Pos @ref_2475(%Pos %init_2474) local_unnamed_addr {
  %z = tail call %Pos @c_ref_fresh(%Pos %init_2474)
  ret %Pos %z
}

define %Pos @get_2478(%Pos %ref_2477) local_unnamed_addr {
  %z = tail call %Pos @c_ref_get(%Pos %ref_2477)
  ret %Pos %z
}

define %Pos @set_2482(%Pos %ref_2480, %Pos %value_2481) local_unnamed_addr {
  %z = tail call %Pos @c_ref_set(%Pos %ref_2480, %Pos %value_2481)
  ret %Pos %z
}

define %Pos @allocate_2487(i64 %size_2486) local_unnamed_addr {
  %z = tail call %Pos @c_array_new(i64 %size_2486)
  ret %Pos %z
}

define %Pos @unsafeGet_2501(%Pos %arr_2499, i64 %index_2500) local_unnamed_addr {
  %z = tail call %Pos @c_array_get(%Pos %arr_2499, i64 %index_2500)
  ret %Pos %z
}

define %Pos @unsafeSet_2506(%Pos %arr_2503, i64 %index_2504, %Pos %value_2505) local_unnamed_addr {
  %z = tail call %Pos @c_array_set(%Pos %arr_2503, i64 %index_2504, %Pos %value_2505)
  ret %Pos %z
}

define tailcc void @returnAddress_10(i64 %v_r_3074_2_8148, ptr %stack) {
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
  %i_6_8145 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_8446_pointer_13 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_8446 = load i64, ptr %tmp_8446_pointer_13, align 4, !noalias !0
  %z.i = add i64 %i_6_8145, 1
  %z.i.i = icmp slt i64 %z.i, %tmp_8446
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
  %tmp_8446_pointer_28.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %tmp_8446, ptr %tmp_8446_pointer_28.i, align 4, !noalias !0
  %sharer_pointer_30.i = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_31.i = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_10, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30.i, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31.i, align 8, !noalias !0
  musttail call tailcc void @run_2874(i64 50, ptr nonnull %stack)
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

define tailcc void @loop_5_8142(i64 %i_6_8145, i64 %tmp_8446, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_8145, %tmp_8446
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
  store i64 %i_6_8145, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_8446_pointer_28 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_8446, ptr %tmp_8446_pointer_28, align 4, !noalias !0
  %returnAddress_pointer_29 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_30 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_31 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31, align 8, !noalias !0
  musttail call tailcc void @run_2874(i64 50, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_34(i64 %r_2902, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2902)
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

define tailcc void @returnAddress_33(%Pos %v_r_3076_8673, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %v_r_3076_8673, 1
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
  musttail call tailcc void @run_2874(i64 50, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_4115_4179, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_4115_4179, 0
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
  musttail call tailcc void @run_2874(i64 50, ptr nonnull %stack)
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
  %tmp_8446_pointer_28.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %z.i, ptr %tmp_8446_pointer_28.i, align 4, !noalias !0
  %returnAddress_pointer_29.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %sharer_pointer_30.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  %eraser_pointer_31.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29.i, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30.i, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31.i, align 8, !noalias !0
  musttail call tailcc void @run_2874(i64 50, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_55(%Pos %returned_8678, ptr nocapture %stack) {
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
  musttail call tailcc void %returnAddress_57(%Pos %returned_8678, ptr %rest.i)
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
  %tmp_8419_73.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_8419_73.unpack2 = load ptr, ptr %tmp_8419_73.elt1, align 8, !noalias !0
  %acc_3_3_5_169_7910_74.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_7910_74.unpack5 = load ptr, ptr %acc_3_3_5_169_7910_74.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_8419_73.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_8419_73.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_8419_73.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_8419_73.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_8419_73.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_8419_73.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_7910_74.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_7910_74.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_7910_74.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_7910_74.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_7910_74.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_7910_74.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_8011(i64 %start_2_2_4_168_7876, %Pos %acc_3_3_5_169_7910, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_7876, 1
  br i1 %z.i6, label %label_85, label %label_81

label_81:                                         ; preds = %entry, %label_81
  %acc_3_3_5_169_7910.tr8 = phi %Pos [ %make_8684, %label_81 ], [ %acc_3_3_5_169_7910, %entry ]
  %start_2_2_4_168_7876.tr7 = phi i64 [ %z.i5, %label_81 ], [ %start_2_2_4_168_7876, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_7876.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_7876.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_75, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_8681.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_8681.elt, ptr %environment.i, align 8, !noalias !0
  %environment_72.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_8681.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_8681.elt2, ptr %environment_72.repack1, align 8, !noalias !0
  %acc_3_3_5_169_7910_pointer_79 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_7910.elt = extractvalue %Pos %acc_3_3_5_169_7910.tr8, 0
  store i64 %acc_3_3_5_169_7910.elt, ptr %acc_3_3_5_169_7910_pointer_79, align 8, !noalias !0
  %acc_3_3_5_169_7910_pointer_79.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_7910.elt4 = extractvalue %Pos %acc_3_3_5_169_7910.tr8, 1
  store ptr %acc_3_3_5_169_7910.elt4, ptr %acc_3_3_5_169_7910_pointer_79.repack3, align 8, !noalias !0
  %make_8684 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_7876.tr7, 2
  br i1 %z.i, label %label_85, label %label_81

label_85:                                         ; preds = %label_81, %entry
  %acc_3_3_5_169_7910.tr.lcssa = phi %Pos [ %acc_3_3_5_169_7910, %entry ], [ %make_8684, %label_81 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_82 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_82(%Pos %acc_3_3_5_169_7910.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_96(%Pos %v_r_3261_32_59_223_8014, ptr %stack) {
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
  %index_7_34_198_8049 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %v_r_3071_30_194_8018_pointer_99 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_3071_30_194_8018.unpack = load i64, ptr %v_r_3071_30_194_8018_pointer_99, align 8, !noalias !0
  %v_r_3071_30_194_8018.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_r_3071_30_194_8018.unpack2 = load ptr, ptr %v_r_3071_30_194_8018.elt1, align 8, !noalias !0
  %tmp_8426_pointer_100 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8426 = load i64, ptr %tmp_8426_pointer_100, align 4, !noalias !0
  %acc_8_35_199_7830_pointer_101 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %acc_8_35_199_7830 = load i64, ptr %acc_8_35_199_7830_pointer_101, align 4, !noalias !0
  %p_8_9_7772_pointer_102 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_7772 = load ptr, ptr %p_8_9_7772_pointer_102, align 8, !noalias !0
  %tag_103 = extractvalue %Pos %v_r_3261_32_59_223_8014, 0
  %fields_104 = extractvalue %Pos %v_r_3261_32_59_223_8014, 1
  switch i64 %tag_103, label %common.ret [
    i64 1, label %label_128
    i64 0, label %label_135
  ]

common.ret:                                       ; preds = %entry
  ret void

label_116:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_3071_30_194_8018.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_116
  %referenceCount.i.i37 = load i64, ptr %v_r_3071_30_194_8018.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_3071_30_194_8018.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_3071_30_194_8018.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_3071_30_194_8018.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_3071_30_194_8018.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_116, %decr.i.i39, %free.i.i41
  %pair_111 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_7772)
  %k_13_14_4_8155 = extractvalue <{ ptr, ptr }> %pair_111, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_8155, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_8155, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_8155, i64 40
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
  musttail call tailcc void %returnAddress_113(%Pos { i64 5, ptr null }, ptr %stack_112)
  ret void

label_125:                                        ; preds = %label_127
  %isNull.i.i24 = icmp eq ptr %v_r_3071_30_194_8018.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_125
  %referenceCount.i.i26 = load i64, ptr %v_r_3071_30_194_8018.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_3071_30_194_8018.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_3071_30_194_8018.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_3071_30_194_8018.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_3071_30_194_8018.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_125, %decr.i.i28, %free.i.i30
  %pair_120 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_7772)
  %k_13_14_4_8154 = extractvalue <{ ptr, ptr }> %pair_120, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_8154, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_8154, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_8154, i64 40
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
  musttail call tailcc void %returnAddress_122(%Pos { i64 5, ptr null }, ptr %stack_121)
  ret void

label_126:                                        ; preds = %label_127
  %0 = insertvalue %Pos poison, i64 %v_r_3071_30_194_8018.unpack, 0
  %v_r_3071_30_194_80183 = insertvalue %Pos %0, ptr %v_r_3071_30_194_8018.unpack2, 1
  %z.i = add i64 %index_7_34_198_8049, 1
  %z.i108 = mul i64 %acc_8_35_199_7830, 10
  %z.i109 = sub i64 %z.i108, %tmp_8426
  %z.i110 = add i64 %z.i109, %v_coe_4079_46_73_237_7921.unpack
  musttail call tailcc void @go_6_33_197_7935(i64 %z.i, i64 %z.i110, %Pos %v_r_3071_30_194_80183, i64 %tmp_8426, ptr %p_8_9_7772, ptr nonnull %stack)
  ret void

label_127:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_4079_46_73_237_7921.unpack, 58
  br i1 %z.i111, label %label_126, label %label_125

label_128:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_104, i64 16
  %v_coe_4079_46_73_237_7921.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_4079_46_73_237_7921.elt4 = getelementptr i8, ptr %fields_104, i64 24
  %v_coe_4079_46_73_237_7921.unpack5 = load ptr, ptr %v_coe_4079_46_73_237_7921.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_4079_46_73_237_7921.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_128
  %referenceCount.i.i = load i64, ptr %v_coe_4079_46_73_237_7921.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_4079_46_73_237_7921.unpack5, align 4
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
  %z.i112 = icmp sgt i64 %v_coe_4079_46_73_237_7921.unpack, 47
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
  %isNull.i.i20 = icmp eq ptr %v_r_3071_30_194_8018.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_3071_30_194_8018.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_3071_30_194_8018.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3071_30_194_8018.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3071_30_194_8018.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3071_30_194_8018.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_132 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_132(i64 %acc_8_35_199_7830, ptr nonnull %stack)
  ret void
}

define void @sharer_141(ptr %stackPointer) {
entry:
  %v_r_3071_30_194_8018_137.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %v_r_3071_30_194_8018_137.unpack2 = load ptr, ptr %v_r_3071_30_194_8018_137.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3071_30_194_8018_137.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3071_30_194_8018_137.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3071_30_194_8018_137.unpack2, align 4
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
  %v_r_3071_30_194_8018_149.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %v_r_3071_30_194_8018_149.unpack2 = load ptr, ptr %v_r_3071_30_194_8018_149.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3071_30_194_8018_149.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3071_30_194_8018_149.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3071_30_194_8018_149.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3071_30_194_8018_149.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3071_30_194_8018_149.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3071_30_194_8018_149.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_170(%Pos %returned_8709, ptr nocapture %stack) {
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
  musttail call tailcc void %returnAddress_172(%Pos %returned_8709, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_8077_clause_179(ptr %closure, %Pos %exc_8_20_47_211_8032, %Pos %msg_9_21_48_212_7997, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_7946 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_182 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_7946)
  %k_11_23_50_214_8097 = extractvalue <{ ptr, ptr }> %pair_182, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_8097, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_8097, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_8097, i64 40
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
  %exc_8_20_47_211_8032.elt = extractvalue %Pos %exc_8_20_47_211_8032, 0
  store i64 %exc_8_20_47_211_8032.elt, ptr %environment.i, align 8, !noalias !0
  %environment_185.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_8032.elt2 = extractvalue %Pos %exc_8_20_47_211_8032, 1
  store ptr %exc_8_20_47_211_8032.elt2, ptr %environment_185.repack1, align 8, !noalias !0
  %msg_9_21_48_212_7997_pointer_189 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_7997.elt = extractvalue %Pos %msg_9_21_48_212_7997, 0
  store i64 %msg_9_21_48_212_7997.elt, ptr %msg_9_21_48_212_7997_pointer_189, align 8, !noalias !0
  %msg_9_21_48_212_7997_pointer_189.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_7997.elt4 = extractvalue %Pos %msg_9_21_48_212_7997, 1
  store ptr %msg_9_21_48_212_7997.elt4, ptr %msg_9_21_48_212_7997_pointer_189.repack3, align 8, !noalias !0
  %make_8710 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_183, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_183, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_191 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_191(%Pos %make_8710, ptr %stack_183)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_198(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_206(ptr nocapture readonly %environment) {
entry:
  %tmp_8428_205.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_8428_205.unpack2 = load ptr, ptr %tmp_8428_205.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8428_205.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8428_205.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8428_205.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8428_205.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8428_205.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8428_205.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_202(i64 %v_coe_4078_6_28_55_219_7833, ptr %stack) {
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
  store i64 %v_coe_4078_6_28_55_219_7833, ptr %environment.i, align 8, !noalias !0
  %environment_204.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_204.repack1, align 8, !noalias !0
  %make_8712 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_210 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_210(%Pos %make_8712, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_7935(i64 %index_7_34_198_8049, i64 %acc_8_35_199_7830, %Pos %v_r_3071_30_194_8018, i64 %tmp_8426, ptr %p_8_9_7772, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_3071_30_194_8018, 1
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
  store i64 %index_7_34_198_8049, ptr %common.ret.op.i, align 4, !noalias !0
  %v_r_3071_30_194_8018_pointer_162 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_r_3071_30_194_8018.elt = extractvalue %Pos %v_r_3071_30_194_8018, 0
  store i64 %v_r_3071_30_194_8018.elt, ptr %v_r_3071_30_194_8018_pointer_162, align 8, !noalias !0
  %v_r_3071_30_194_8018_pointer_162.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i3, ptr %v_r_3071_30_194_8018_pointer_162.repack1, align 8, !noalias !0
  %tmp_8426_pointer_163 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_8426, ptr %tmp_8426_pointer_163, align 4, !noalias !0
  %acc_8_35_199_7830_pointer_164 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %acc_8_35_199_7830, ptr %acc_8_35_199_7830_pointer_164, align 4, !noalias !0
  %p_8_9_7772_pointer_165 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %p_8_9_7772, ptr %p_8_9_7772_pointer_165, align 8, !noalias !0
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
  %Exception_7_19_46_210_8077 = insertvalue %Neg { ptr @vtable_194, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_215 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_216 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_202, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_215, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_216, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_3071_30_194_8018, i64 %index_7_34_198_8049, %Neg %Exception_7_19_46_210_8077, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_7992_clause_217(ptr %closure, %Pos %exception_10_107_134_298_8713, %Pos %msg_11_108_135_299_8714, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_7772 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_8713, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_8714, 1
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
  %pair_220 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_7772)
  %k_13_14_4_8308 = extractvalue <{ ptr, ptr }> %pair_220, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_8308, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_8308, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_8308, i64 40
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
  musttail call tailcc void %returnAddress_222(%Pos { i64 5, ptr null }, ptr %stack_221)
  ret void
}

define tailcc void @returnAddress_236(i64 %v_coe_4083_22_131_158_322_8003, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_4083_22_131_158_322_8003, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_237 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_237(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_248(i64 %v_r_3275_1_9_20_129_156_320_7984, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_3275_1_9_20_129_156_320_7984
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_249 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_249(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_231(i64 %v_r_3274_3_14_123_150_314_7944, ptr %stack) {
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
  %v_r_3071_30_194_8018.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_3071_30_194_8018.unpack, 0
  %v_r_3071_30_194_8018.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_3071_30_194_8018.unpack2 = load ptr, ptr %v_r_3071_30_194_8018.elt1, align 8, !noalias !0
  %v_r_3071_30_194_80183 = insertvalue %Pos %0, ptr %v_r_3071_30_194_8018.unpack2, 1
  %tmp_8426_pointer_234 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8426 = load i64, ptr %tmp_8426_pointer_234, align 4, !noalias !0
  %p_8_9_7772_pointer_235 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_7772 = load ptr, ptr %p_8_9_7772_pointer_235, align 8, !noalias !0
  %z.i = icmp eq i64 %v_r_3274_3_14_123_150_314_7944, 45
  %isInside.not.i = icmp ugt ptr %p_8_9_7772_pointer_235, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %p_8_9_7772_pointer_235, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_242 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_243 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_236, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_242, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_243, align 8, !noalias !0
  br i1 %z.i, label %label_256, label %label_247

label_247:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_7935(i64 0, i64 0, %Pos %v_r_3071_30_194_80183, i64 %tmp_8426, ptr %p_8_9_7772, ptr nonnull %stack)
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
  musttail call tailcc void @go_6_33_197_7935(i64 1, i64 0, %Pos %v_r_3071_30_194_80183, i64 %tmp_8426, ptr %p_8_9_7772, ptr nonnull %stack)
  ret void
}

define void @sharer_260(ptr %stackPointer) {
entry:
  %v_r_3071_30_194_8018_257.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_3071_30_194_8018_257.unpack2 = load ptr, ptr %v_r_3071_30_194_8018_257.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3071_30_194_8018_257.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3071_30_194_8018_257.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3071_30_194_8018_257.unpack2, align 4
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
  %v_r_3071_30_194_8018_265.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_3071_30_194_8018_265.unpack2 = load ptr, ptr %v_r_3071_30_194_8018_265.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3071_30_194_8018_265.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3071_30_194_8018_265.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3071_30_194_8018_265.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3071_30_194_8018_265.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3071_30_194_8018_265.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3071_30_194_8018_265.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_93(%Pos %v_r_3071_30_194_8018, ptr %stack) {
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
  %p_8_9_7772 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_198, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_7772, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_3071_30_194_8018, 1
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
  %v_r_3071_30_194_8018.elt = extractvalue %Pos %v_r_3071_30_194_8018, 0
  store i64 %v_r_3071_30_194_8018.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_273.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i3, ptr %stackPointer_273.repack1, align 8, !noalias !0
  %tmp_8426_pointer_275 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 48, ptr %tmp_8426_pointer_275, align 4, !noalias !0
  %p_8_9_7772_pointer_276 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %p_8_9_7772, ptr %p_8_9_7772_pointer_276, align 8, !noalias !0
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
  store i64 %v_r_3071_30_194_8018.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_1441.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_1441.repack1.i, align 8, !noalias !0
  %index_2107_pointer_1443.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_1443.i, align 4, !noalias !0
  %Exception_2362_pointer_1444.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_225, ptr %Exception_2362_pointer_1444.i, align 8, !noalias !0
  %Exception_2362_pointer_1444.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_1444.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_1445.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_1446.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_1447.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_1407, ptr %returnAddress_pointer_1445.i, align 8, !noalias !0
  store ptr @sharer_1428, ptr %sharer_pointer_1446.i, align 8, !noalias !0
  store ptr @eraser_1436, ptr %eraser_pointer_1447.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_3071_30_194_8018)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1451.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1451.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
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

define tailcc void @returnAddress_90(%Pos %v_r_3070_24_188_7925, ptr %stack) {
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
  %p_8_9_7772 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_7772, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_291 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_292 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_93, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_291, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_292, align 8, !noalias !0
  %tag_293 = extractvalue %Pos %v_r_3070_24_188_7925, 0
  switch i64 %tag_293, label %label_295 [
    i64 0, label %label_299
    i64 1, label %label_305
  ]

label_295:                                        ; preds = %stackAllocate.exit
  ret void

label_299:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_8729 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_8729.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_296 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_296(%Pos %utf8StringLiteral_8729, ptr nonnull %stack)
  ret void

label_305:                                        ; preds = %stackAllocate.exit
  %fields_294 = extractvalue %Pos %v_r_3070_24_188_7925, 1
  %environment.i = getelementptr i8, ptr %fields_294, i64 16
  %v_y_3905_8_29_193_7969.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3905_8_29_193_7969.elt1 = getelementptr i8, ptr %fields_294, i64 24
  %v_y_3905_8_29_193_7969.unpack2 = load ptr, ptr %v_y_3905_8_29_193_7969.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3905_8_29_193_7969.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_305
  %referenceCount.i.i = load i64, ptr %v_y_3905_8_29_193_7969.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3905_8_29_193_7969.unpack2, align 4
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
  %0 = insertvalue %Pos poison, i64 %v_y_3905_8_29_193_7969.unpack, 0
  %v_y_3905_8_29_193_79693 = insertvalue %Pos %0, ptr %v_y_3905_8_29_193_7969.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_302 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_302(%Pos %v_y_3905_8_29_193_79693, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_87(%Pos %v_r_3069_13_177_8087, ptr %stack) {
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
  %p_8_9_7772 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_7772, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_311 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_312 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_90, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_311, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_312, align 8, !noalias !0
  %tag_313 = extractvalue %Pos %v_r_3069_13_177_8087, 0
  switch i64 %tag_313, label %label_315 [
    i64 0, label %label_320
    i64 1, label %label_332
  ]

label_315:                                        ; preds = %stackAllocate.exit
  ret void

label_320:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_7772, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_93, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_311, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_312, align 8, !noalias !0
  %utf8StringLiteral_8729.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_8729.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_296.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_296.i(%Pos %utf8StringLiteral_8729.i, ptr nonnull %stack)
  ret void

label_332:                                        ; preds = %stackAllocate.exit
  %fields_314 = extractvalue %Pos %v_r_3069_13_177_8087, 1
  %environment.i6 = getelementptr i8, ptr %fields_314, i64 16
  %v_y_3414_10_21_185_8039.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_3414_10_21_185_8039.elt1 = getelementptr i8, ptr %fields_314, i64 24
  %v_y_3414_10_21_185_8039.unpack2 = load ptr, ptr %v_y_3414_10_21_185_8039.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3414_10_21_185_8039.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_332
  %referenceCount.i.i = load i64, ptr %v_y_3414_10_21_185_8039.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3414_10_21_185_8039.unpack2, align 4
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
  store i64 %v_y_3414_10_21_185_8039.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_325.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_3414_10_21_185_8039.unpack2, ptr %environment_325.repack4, align 8, !noalias !0
  %make_8731 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_329 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_329(%Pos %make_8731, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2875(ptr %stack) local_unnamed_addr {
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
  %acc_3_3_5_169_7910.tr8.i = phi %Pos [ %make_8684.i, %label_81.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_7876.tr7.i = phi i64 [ %z.i5.i, %label_81.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_7876.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_7876.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_75, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_8681.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_8681.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_72.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_8681.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_8681.elt2.i, ptr %environment_72.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_7910_pointer_79.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_7910.elt.i = extractvalue %Pos %acc_3_3_5_169_7910.tr8.i, 0
  store i64 %acc_3_3_5_169_7910.elt.i, ptr %acc_3_3_5_169_7910_pointer_79.i, align 8, !noalias !0
  %acc_3_3_5_169_7910_pointer_79.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_7910.elt4.i = extractvalue %Pos %acc_3_3_5_169_7910.tr8.i, 1
  store ptr %acc_3_3_5_169_7910.elt4.i, ptr %acc_3_3_5_169_7910_pointer_79.repack3.i, align 8, !noalias !0
  %make_8684.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_7876.tr7.i, 2
  br i1 %z.i.i, label %label_85.i.loopexit, label %label_81.i

label_85.i.loopexit:                              ; preds = %label_81.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_85.i

label_85.i:                                       ; preds = %label_85.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_85.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_85.i.loopexit ]
  %acc_3_3_5_169_7910.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_8684.i, %label_85.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_82.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_82.i(%Pos %acc_3_3_5_169_7910.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_340(%Pos %v_coe_4108_4268, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_4108_4268, 0
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_341 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_341(i64 %unboxed.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_348(%Pos %returnValue_349, ptr %stack) {
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
  %returnAddress_352 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_352(%Pos %returnValue_349, ptr %stack)
  ret void
}

define void @sharer_356(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_360(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_368(i64 %v_coe_4106_1556_6453, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_4106_1556_6453, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_369 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_369(%Pos %boxed2.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_376(i64 %returnValue_377, ptr %stack) {
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
  %returnAddress_380 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_380(i64 %returnValue_377, ptr %stack)
  ret void
}

define tailcc void @returnAddress_495(%Pos %returnValue_496, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_r_3024_31_109_649_1427_6600.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_3024_31_109_649_1427_6600.unpack2 = load ptr, ptr %v_r_3024_31_109_649_1427_6600.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3024_31_109_649_1427_6600.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3024_31_109_649_1427_6600.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3024_31_109_649_1427_6600.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3024_31_109_649_1427_6600.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3024_31_109_649_1427_6600.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3024_31_109_649_1427_6600.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_499 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_499(%Pos %returnValue_496, ptr nonnull %stack)
  ret void
}

define void @sharer_503(ptr %stackPointer) {
entry:
  %v_r_3024_31_109_649_1427_6600_502.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_3024_31_109_649_1427_6600_502.unpack2 = load ptr, ptr %v_r_3024_31_109_649_1427_6600_502.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3024_31_109_649_1427_6600_502.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3024_31_109_649_1427_6600_502.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3024_31_109_649_1427_6600_502.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_507(ptr %stackPointer) {
entry:
  %v_r_3024_31_109_649_1427_6600_506.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_3024_31_109_649_1427_6600_506.unpack2 = load ptr, ptr %v_r_3024_31_109_649_1427_6600_506.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3024_31_109_649_1427_6600_506.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3024_31_109_649_1427_6600_506.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3024_31_109_649_1427_6600_506.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3024_31_109_649_1427_6600_506.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3024_31_109_649_1427_6600_506.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3024_31_109_649_1427_6600_506.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_534(%Pos %__106_184_724_1502_8481, ptr %stack) {
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
  %bounced_32_110_650_1428_6047.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bounced_32_110_650_1428_6047.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bounced_32_110_650_1428_6047.unpack2 = load i64, ptr %bounced_32_110_650_1428_6047.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__106_184_724_1502_8481, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bounced_32_110_650_1428_6047.unpack2
  %bounced_32_110_650_1428_6047_old_538.elt4 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %bounced_32_110_650_1428_6047_old_538.unpack5 = load ptr, ptr %bounced_32_110_650_1428_6047_old_538.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bounced_32_110_650_1428_6047_old_538.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %bounced_32_110_650_1428_6047_old_538.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %bounced_32_110_650_1428_6047_old_538.unpack5, align 4
  %get_8572.unpack8.pre = load ptr, ptr %bounced_32_110_650_1428_6047_old_538.elt4, align 8, !noalias !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %get_8572.unpack8 = phi ptr [ null, %erasePositive.exit ], [ %get_8572.unpack8.pre, %next.i.i ]
  %get_8572.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_8572.unpack, 0
  %get_85729 = insertvalue %Pos %0, ptr %get_8572.unpack8, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_539 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_539(%Pos %get_85729, ptr nonnull %stack)
  ret void
}

define void @sharer_543(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_547(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_563(double %v_r_3048_103_181_721_1499_5964, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8348.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8348.unpack, 0
  %tmp_8348.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8348.unpack2 = load ptr, ptr %tmp_8348.elt1, align 8, !noalias !0
  %tmp_83483 = insertvalue %Pos %0, ptr %tmp_8348.unpack2, 1
  %bounced_32_110_650_1428_6047_pointer_566 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bounced_32_110_650_1428_6047.unpack = load ptr, ptr %bounced_32_110_650_1428_6047_pointer_566, align 8, !noalias !0
  %bounced_32_110_650_1428_6047.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bounced_32_110_650_1428_6047.unpack5 = load i64, ptr %bounced_32_110_650_1428_6047.elt4, align 8, !noalias !0
  %n.i = bitcast double %v_r_3048_103_181_721_1499_5964 to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i = tail call %Pos @c_ref_set(%Pos %tmp_83483, %Pos %boxed2.i)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i11 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i11, label %erasePositive.exit21, label %next.i.i12

next.i.i12:                                       ; preds = %entry
  %referenceCount.i.i13 = load i64, ptr %object.i, align 4
  %cond.i.i14 = icmp eq i64 %referenceCount.i.i13, 0
  br i1 %cond.i.i14, label %free.i.i17, label %decr.i.i15

decr.i.i15:                                       ; preds = %next.i.i12
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i13, -1
  store i64 %referenceCount.1.i.i16, ptr %object.i, align 4
  br label %erasePositive.exit21

free.i.i17:                                       ; preds = %next.i.i12
  %objectEraser.i.i18 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i19 = load ptr, ptr %objectEraser.i.i18, align 8
  %environment.i.i.i20 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i19(ptr %environment.i.i.i20)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit21

erasePositive.exit21:                             ; preds = %entry, %decr.i.i15, %free.i.i17
  %stack_pointer.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bounced_32_110_650_1428_6047.unpack5
  %bounced_32_110_650_1428_6047_old_569.elt7 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %bounced_32_110_650_1428_6047_old_569.unpack8 = load ptr, ptr %bounced_32_110_650_1428_6047_old_569.elt7, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bounced_32_110_650_1428_6047_old_569.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit21
  %referenceCount.i.i = load i64, ptr %bounced_32_110_650_1428_6047_old_569.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bounced_32_110_650_1428_6047_old_569.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047_old_569.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047_old_569.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bounced_32_110_650_1428_6047_old_569.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit21, %decr.i.i, %free.i.i
  store i64 1, ptr %varPointer.i, align 8, !noalias !0
  store ptr null, ptr %bounced_32_110_650_1428_6047_old_569.elt7, align 8, !noalias !0
  %stackPointer.i28 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i30 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i31 = icmp ule ptr %stackPointer.i28, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %stackPointer.i28, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_571 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_571(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_576(ptr %stackPointer) {
entry:
  %tmp_8348_574.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %tmp_8348_574.unpack2 = load ptr, ptr %tmp_8348_574.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8348_574.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8348_574.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8348_574.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_582(ptr %stackPointer) {
entry:
  %tmp_8348_580.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %tmp_8348_580.unpack2 = load ptr, ptr %tmp_8348_580.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8348_580.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8348_580.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8348_580.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8348_580.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8348_580.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8348_580.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_529(%Pos %__92_170_710_1488_8482, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i66 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i66)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8332.unpack, 0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_83323 = insertvalue %Pos %0, ptr %tmp_8332.unpack2, 1
  %bounced_32_110_650_1428_6047_pointer_532 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %bounced_32_110_650_1428_6047.unpack = load ptr, ptr %bounced_32_110_650_1428_6047_pointer_532, align 8, !noalias !0
  %bounced_32_110_650_1428_6047.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %bounced_32_110_650_1428_6047.unpack5 = load i64, ptr %bounced_32_110_650_1428_6047.elt4, align 8, !noalias !0
  %tmp_8348_pointer_533 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8348.unpack = load i64, ptr %tmp_8348_pointer_533, align 8, !noalias !0
  %1 = insertvalue %Pos poison, i64 %tmp_8348.unpack, 0
  %tmp_8348.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_8348.unpack8 = load ptr, ptr %tmp_8348.elt7, align 8, !noalias !0
  %tmp_83489 = insertvalue %Pos %1, ptr %tmp_8348.unpack8, 1
  %object.i50 = extractvalue %Pos %__92_170_710_1488_8482, 1
  %isNull.i.i51 = icmp eq ptr %object.i50, null
  br i1 %isNull.i.i51, label %erasePositive.exit61, label %next.i.i52

next.i.i52:                                       ; preds = %entry
  %referenceCount.i.i53 = load i64, ptr %object.i50, align 4
  %cond.i.i54 = icmp eq i64 %referenceCount.i.i53, 0
  br i1 %cond.i.i54, label %free.i.i57, label %decr.i.i55

decr.i.i55:                                       ; preds = %next.i.i52
  %referenceCount.1.i.i56 = add i64 %referenceCount.i.i53, -1
  store i64 %referenceCount.1.i.i56, ptr %object.i50, align 4
  br label %erasePositive.exit61

free.i.i57:                                       ; preds = %next.i.i52
  %objectEraser.i.i58 = getelementptr i8, ptr %object.i50, i64 8
  %eraser.i.i59 = load ptr, ptr %objectEraser.i.i58, align 8
  %environment.i.i.i60 = getelementptr i8, ptr %object.i50, i64 16
  tail call void %eraser.i.i59(ptr %environment.i.i.i60)
  tail call void @free(ptr nonnull %object.i50)
  br label %erasePositive.exit61

erasePositive.exit61:                             ; preds = %entry, %decr.i.i55, %free.i.i57
  %isNull.i.i17 = icmp eq ptr %tmp_8332.unpack2, null
  br i1 %isNull.i.i17, label %sharePositive.exit21, label %next.i.i18

next.i.i18:                                       ; preds = %erasePositive.exit61
  %referenceCount.i.i19 = load i64, ptr %tmp_8332.unpack2, align 4
  %referenceCount.1.i.i20 = add i64 %referenceCount.i.i19, 1
  store i64 %referenceCount.1.i.i20, ptr %tmp_8332.unpack2, align 4
  br label %sharePositive.exit21

sharePositive.exit21:                             ; preds = %erasePositive.exit61, %next.i.i18
  %z.i = tail call %Pos @c_ref_get(%Pos %tmp_83323)
  %unboxed.i = extractvalue %Pos %z.i, 0
  %d.i = bitcast i64 %unboxed.i to double
  %z.i67 = fcmp olt double %d.i, 0.000000e+00
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i70 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i70
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit21
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
  %newStackPointer.i71 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i71, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit21, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit21 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i71, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit21 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bounced_32_110_650_1428_6047.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_550.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bounced_32_110_650_1428_6047.unpack5, ptr %stackPointer_550.repack10, align 8, !noalias !0
  %returnAddress_pointer_552 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_553 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_554 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_534, ptr %returnAddress_pointer_552, align 8, !noalias !0
  store ptr @sharer_543, ptr %sharer_pointer_553, align 8, !noalias !0
  store ptr @eraser_547, ptr %eraser_pointer_554, align 8, !noalias !0
  br i1 %z.i67, label %label_603, label %label_562

label_562:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i17, label %erasePositive.exit49, label %next.i.i40

next.i.i40:                                       ; preds = %label_562
  %referenceCount.i.i41 = load i64, ptr %tmp_8332.unpack2, align 4
  %cond.i.i42 = icmp eq i64 %referenceCount.i.i41, 0
  br i1 %cond.i.i42, label %free.i.i45, label %decr.i.i43

decr.i.i43:                                       ; preds = %next.i.i40
  %referenceCount.1.i.i44 = add i64 %referenceCount.i.i41, -1
  store i64 %referenceCount.1.i.i44, ptr %tmp_8332.unpack2, align 4
  br label %erasePositive.exit49

free.i.i45:                                       ; preds = %next.i.i40
  %objectEraser.i.i46 = getelementptr i8, ptr %tmp_8332.unpack2, i64 8
  %eraser.i.i47 = load ptr, ptr %objectEraser.i.i46, align 8
  %environment.i.i.i48 = getelementptr i8, ptr %tmp_8332.unpack2, i64 16
  tail call void %eraser.i.i47(ptr %environment.i.i.i48)
  tail call void @free(ptr nonnull %tmp_8332.unpack2)
  br label %erasePositive.exit49

erasePositive.exit49:                             ; preds = %label_562, %decr.i.i43, %free.i.i45
  %isNull.i.i27 = icmp eq ptr %tmp_8348.unpack8, null
  br i1 %isNull.i.i27, label %erasePositive.exit37, label %next.i.i28

next.i.i28:                                       ; preds = %erasePositive.exit49
  %referenceCount.i.i29 = load i64, ptr %tmp_8348.unpack8, align 4
  %cond.i.i30 = icmp eq i64 %referenceCount.i.i29, 0
  br i1 %cond.i.i30, label %free.i.i33, label %decr.i.i31

decr.i.i31:                                       ; preds = %next.i.i28
  %referenceCount.1.i.i32 = add i64 %referenceCount.i.i29, -1
  store i64 %referenceCount.1.i.i32, ptr %tmp_8348.unpack8, align 4
  br label %erasePositive.exit37

free.i.i33:                                       ; preds = %next.i.i28
  %objectEraser.i.i34 = getelementptr i8, ptr %tmp_8348.unpack8, i64 8
  %eraser.i.i35 = load ptr, ptr %objectEraser.i.i34, align 8
  %environment.i.i.i36 = getelementptr i8, ptr %tmp_8348.unpack8, i64 16
  tail call void %eraser.i.i35(ptr %environment.i.i.i36)
  tail call void @free(ptr nonnull %tmp_8348.unpack8)
  br label %erasePositive.exit37

erasePositive.exit37:                             ; preds = %erasePositive.exit49, %decr.i.i31, %free.i.i33
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i75 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_559 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_559(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_598:                                        ; preds = %stackAllocate.exit120
  musttail call tailcc void %returnAddress_599(double %z.i94, ptr nonnull %stack)
  ret void

label_602:                                        ; preds = %stackAllocate.exit120
  musttail call tailcc void %returnAddress_599(double %d.i93, ptr nonnull %stack)
  ret void

label_603:                                        ; preds = %stackAllocate.exit
  %z.i90 = tail call %Pos @c_ref_set(%Pos %tmp_83323, %Pos zeroinitializer)
  %object.i = extractvalue %Pos %z.i90, 1
  %isNull.i.i22 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i22, label %erasePositive.exit, label %next.i.i23

next.i.i23:                                       ; preds = %label_603
  %referenceCount.i.i24 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i24, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i23
  %referenceCount.1.i.i25 = add i64 %referenceCount.i.i24, -1
  store i64 %referenceCount.1.i.i25, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i23
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_603, %decr.i.i, %free.i.i
  %isNull.i.i = icmp eq ptr %tmp_8348.unpack8, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %tmp_8348.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8348.unpack8, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %z.i91 = tail call %Pos @c_ref_get(%Pos %tmp_83489)
  %unboxed.i92 = extractvalue %Pos %z.i91, 0
  %d.i93 = bitcast i64 %unboxed.i92 to double
  %z.i94 = fsub double 0.000000e+00, %d.i93
  %z.i95 = fcmp olt double %z.i94, %d.i93
  %currentStackPointer.i100 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i101 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i102 = getelementptr i8, ptr %currentStackPointer.i100, i64 56
  %isInside.not.i103 = icmp ugt ptr %nextStackPointer.i102, %limit.i101
  br i1 %isInside.not.i103, label %realloc.i106, label %stackAllocate.exit120

realloc.i106:                                     ; preds = %sharePositive.exit
  %base_pointer.i107 = getelementptr i8, ptr %stack, i64 16
  %base.i108 = load ptr, ptr %base_pointer.i107, align 8, !alias.scope !0
  %intStackPointer.i109 = ptrtoint ptr %currentStackPointer.i100 to i64
  %intBase.i110 = ptrtoint ptr %base.i108 to i64
  %size.i111 = sub i64 %intStackPointer.i109, %intBase.i110
  %nextSize.i112 = add i64 %size.i111, 56
  %leadingZeros.i.i113 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i112, i1 false)
  %numBits.i.i114 = sub nuw nsw i64 64, %leadingZeros.i.i113
  %result.i.i115 = shl nuw i64 1, %numBits.i.i114
  %newBase.i116 = tail call ptr @realloc(ptr %base.i108, i64 %result.i.i115)
  %newLimit.i117 = getelementptr i8, ptr %newBase.i116, i64 %result.i.i115
  %newStackPointer.i118 = getelementptr i8, ptr %newBase.i116, i64 %size.i111
  %newNextStackPointer.i119 = getelementptr i8, ptr %newStackPointer.i118, i64 56
  store ptr %newBase.i116, ptr %base_pointer.i107, align 8, !alias.scope !0
  store ptr %newLimit.i117, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit120

stackAllocate.exit120:                            ; preds = %sharePositive.exit, %realloc.i106
  %limit.i87 = phi ptr [ %newLimit.i117, %realloc.i106 ], [ %limit.i101, %sharePositive.exit ]
  %nextStackPointer.sink.i104 = phi ptr [ %newNextStackPointer.i119, %realloc.i106 ], [ %nextStackPointer.i102, %sharePositive.exit ]
  %common.ret.op.i105 = phi ptr [ %newStackPointer.i118, %realloc.i106 ], [ %currentStackPointer.i100, %sharePositive.exit ]
  store i64 %tmp_8348.unpack, ptr %common.ret.op.i105, align 8, !noalias !0
  %stackPointer_586.repack12 = getelementptr inbounds i8, ptr %common.ret.op.i105, i64 8
  store ptr %tmp_8348.unpack8, ptr %stackPointer_586.repack12, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_588 = getelementptr i8, ptr %common.ret.op.i105, i64 16
  store ptr %bounced_32_110_650_1428_6047.unpack, ptr %bounced_32_110_650_1428_6047_pointer_588, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_588.repack14 = getelementptr i8, ptr %common.ret.op.i105, i64 24
  store i64 %bounced_32_110_650_1428_6047.unpack5, ptr %bounced_32_110_650_1428_6047_pointer_588.repack14, align 8, !noalias !0
  %returnAddress_pointer_589 = getelementptr i8, ptr %common.ret.op.i105, i64 32
  %sharer_pointer_590 = getelementptr i8, ptr %common.ret.op.i105, i64 40
  %eraser_pointer_591 = getelementptr i8, ptr %common.ret.op.i105, i64 48
  store ptr @returnAddress_563, ptr %returnAddress_pointer_589, align 8, !noalias !0
  store ptr @sharer_576, ptr %sharer_pointer_590, align 8, !noalias !0
  store ptr @eraser_582, ptr %eraser_pointer_591, align 8, !noalias !0
  %isInside.i88 = icmp ule ptr %nextStackPointer.sink.i104, %limit.i87
  tail call void @llvm.assume(i1 %isInside.i88)
  %newStackPointer.i89 = getelementptr i8, ptr %nextStackPointer.sink.i104, i64 -24
  store ptr %newStackPointer.i89, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_599 = load ptr, ptr %newStackPointer.i89, align 8, !noalias !0
  br i1 %z.i95, label %label_602, label %label_598
}

define void @sharer_607(ptr %stackPointer) {
entry:
  %tmp_8332_604.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %tmp_8332_604.unpack2 = load ptr, ptr %tmp_8332_604.elt1, align 8, !noalias !0
  %tmp_8348_606.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_8348_606.unpack5 = load ptr, ptr %tmp_8348_606.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_8332_604.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_8332_604.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %tmp_8332_604.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %tmp_8348_606.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %tmp_8348_606.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8348_606.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_615(ptr %stackPointer) {
entry:
  %tmp_8332_612.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %tmp_8332_612.unpack2 = load ptr, ptr %tmp_8332_612.elt1, align 8, !noalias !0
  %tmp_8348_614.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_8348_614.unpack5 = load ptr, ptr %tmp_8348_614.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_8332_612.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_8332_612.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_8332_612.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_8332_612.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_8332_612.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_8332_612.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %tmp_8348_614.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %tmp_8348_614.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8348_614.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8348_614.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8348_614.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8348_614.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_635(double %v_r_3042_87_165_705_1483_6070, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8348.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8348.unpack, 0
  %tmp_8348.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8348.unpack2 = load ptr, ptr %tmp_8348.elt1, align 8, !noalias !0
  %tmp_83483 = insertvalue %Pos %0, ptr %tmp_8348.unpack2, 1
  %bounced_32_110_650_1428_6047_pointer_638 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bounced_32_110_650_1428_6047.unpack = load ptr, ptr %bounced_32_110_650_1428_6047_pointer_638, align 8, !noalias !0
  %bounced_32_110_650_1428_6047.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bounced_32_110_650_1428_6047.unpack5 = load i64, ptr %bounced_32_110_650_1428_6047.elt4, align 8, !noalias !0
  %z.i = fsub double 0.000000e+00, %v_r_3042_87_165_705_1483_6070
  %n.i = bitcast double %z.i to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i27 = tail call %Pos @c_ref_set(%Pos %tmp_83483, %Pos %boxed2.i)
  %object.i = extractvalue %Pos %z.i27, 1
  %isNull.i.i11 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i11, label %erasePositive.exit21, label %next.i.i12

next.i.i12:                                       ; preds = %entry
  %referenceCount.i.i13 = load i64, ptr %object.i, align 4
  %cond.i.i14 = icmp eq i64 %referenceCount.i.i13, 0
  br i1 %cond.i.i14, label %free.i.i17, label %decr.i.i15

decr.i.i15:                                       ; preds = %next.i.i12
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i13, -1
  store i64 %referenceCount.1.i.i16, ptr %object.i, align 4
  br label %erasePositive.exit21

free.i.i17:                                       ; preds = %next.i.i12
  %objectEraser.i.i18 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i19 = load ptr, ptr %objectEraser.i.i18, align 8
  %environment.i.i.i20 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i19(ptr %environment.i.i.i20)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit21

erasePositive.exit21:                             ; preds = %entry, %decr.i.i15, %free.i.i17
  %stack_pointer.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bounced_32_110_650_1428_6047.unpack5
  %bounced_32_110_650_1428_6047_old_641.elt7 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %bounced_32_110_650_1428_6047_old_641.unpack8 = load ptr, ptr %bounced_32_110_650_1428_6047_old_641.elt7, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bounced_32_110_650_1428_6047_old_641.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit21
  %referenceCount.i.i = load i64, ptr %bounced_32_110_650_1428_6047_old_641.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bounced_32_110_650_1428_6047_old_641.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047_old_641.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047_old_641.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bounced_32_110_650_1428_6047_old_641.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit21, %decr.i.i, %free.i.i
  store i64 1, ptr %varPointer.i, align 8, !noalias !0
  store ptr null, ptr %bounced_32_110_650_1428_6047_old_641.elt7, align 8, !noalias !0
  %stackPointer.i29 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i31 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i32 = icmp ule ptr %stackPointer.i29, %limit.i31
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i33 = getelementptr i8, ptr %stackPointer.i29, i64 -24
  store ptr %newStackPointer.i33, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_643 = load ptr, ptr %newStackPointer.i33, align 8, !noalias !0
  musttail call tailcc void %returnAddress_643(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_523(%Pos %__76_154_694_1472_8483, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i80 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i80)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8332.unpack, 0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_83323 = insertvalue %Pos %0, ptr %tmp_8332.unpack2, 1
  %yLimit_30_108_648_1426_6506_pointer_526 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %yLimit_30_108_648_1426_6506 = load double, ptr %yLimit_30_108_648_1426_6506_pointer_526, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_527 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %bounced_32_110_650_1428_6047.unpack = load ptr, ptr %bounced_32_110_650_1428_6047_pointer_527, align 8, !noalias !0
  %bounced_32_110_650_1428_6047.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %bounced_32_110_650_1428_6047.unpack5 = load i64, ptr %bounced_32_110_650_1428_6047.elt4, align 8, !noalias !0
  %tmp_8348_pointer_528 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8348.unpack = load i64, ptr %tmp_8348_pointer_528, align 8, !noalias !0
  %1 = insertvalue %Pos poison, i64 %tmp_8348.unpack, 0
  %tmp_8348.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_8348.unpack8 = load ptr, ptr %tmp_8348.elt7, align 8, !noalias !0
  %tmp_83489 = insertvalue %Pos %1, ptr %tmp_8348.unpack8, 1
  %object.i64 = extractvalue %Pos %__76_154_694_1472_8483, 1
  %isNull.i.i65 = icmp eq ptr %object.i64, null
  br i1 %isNull.i.i65, label %erasePositive.exit75, label %next.i.i66

next.i.i66:                                       ; preds = %entry
  %referenceCount.i.i67 = load i64, ptr %object.i64, align 4
  %cond.i.i68 = icmp eq i64 %referenceCount.i.i67, 0
  br i1 %cond.i.i68, label %free.i.i71, label %decr.i.i69

decr.i.i69:                                       ; preds = %next.i.i66
  %referenceCount.1.i.i70 = add i64 %referenceCount.i.i67, -1
  store i64 %referenceCount.1.i.i70, ptr %object.i64, align 4
  br label %erasePositive.exit75

free.i.i71:                                       ; preds = %next.i.i66
  %objectEraser.i.i72 = getelementptr i8, ptr %object.i64, i64 8
  %eraser.i.i73 = load ptr, ptr %objectEraser.i.i72, align 8
  %environment.i.i.i74 = getelementptr i8, ptr %object.i64, i64 16
  tail call void %eraser.i.i73(ptr %environment.i.i.i74)
  tail call void @free(ptr nonnull %object.i64)
  br label %erasePositive.exit75

erasePositive.exit75:                             ; preds = %entry, %decr.i.i69, %free.i.i71
  %isNull.i.i31 = icmp eq ptr %tmp_8332.unpack2, null
  br i1 %isNull.i.i31, label %sharePositive.exit35.thread, label %next.i.i27

sharePositive.exit35.thread:                      ; preds = %erasePositive.exit75
  %z.i136 = tail call %Pos @c_ref_get(%Pos %tmp_83323)
  br label %sharePositive.exit30

next.i.i27:                                       ; preds = %erasePositive.exit75
  %referenceCount.i.i33 = load i64, ptr %tmp_8332.unpack2, align 4
  %referenceCount.1.i.i34 = add i64 %referenceCount.i.i33, 1
  store i64 %referenceCount.1.i.i34, ptr %tmp_8332.unpack2, align 4
  %z.i = tail call %Pos @c_ref_get(%Pos %tmp_83323)
  %referenceCount.i.i28 = load i64, ptr %tmp_8332.unpack2, align 4
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i28, 1
  store i64 %referenceCount.1.i.i29, ptr %tmp_8332.unpack2, align 4
  br label %sharePositive.exit30

sharePositive.exit30:                             ; preds = %sharePositive.exit35.thread, %next.i.i27
  %z.i136.pn = phi %Pos [ %z.i136, %sharePositive.exit35.thread ], [ %z.i, %next.i.i27 ]
  %d.i138.pn.in = extractvalue %Pos %z.i136.pn, 0
  %d.i138.pn = bitcast i64 %d.i138.pn.in to double
  %z.i81140 = fcmp olt double %yLimit_30_108_648_1426_6506, %d.i138.pn
  %isNull.i.i21 = icmp eq ptr %tmp_8348.unpack8, null
  br i1 %isNull.i.i21, label %sharePositive.exit25, label %next.i.i22

next.i.i22:                                       ; preds = %sharePositive.exit30
  %referenceCount.i.i23 = load i64, ptr %tmp_8348.unpack8, align 4
  %referenceCount.1.i.i24 = add i64 %referenceCount.i.i23, 1
  store i64 %referenceCount.1.i.i24, ptr %tmp_8348.unpack8, align 4
  br label %sharePositive.exit25

sharePositive.exit25:                             ; preds = %sharePositive.exit30, %next.i.i22
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i84 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i84
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit25
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
  %newStackPointer.i85 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i85, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit25, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit25 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i85, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit25 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8332.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_620.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_8332.unpack2, ptr %stackPointer_620.repack10, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_622 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %bounced_32_110_650_1428_6047.unpack, ptr %bounced_32_110_650_1428_6047_pointer_622, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_622.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %bounced_32_110_650_1428_6047.unpack5, ptr %bounced_32_110_650_1428_6047_pointer_622.repack12, align 8, !noalias !0
  %tmp_8348_pointer_623 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %tmp_8348.unpack, ptr %tmp_8348_pointer_623, align 8, !noalias !0
  %tmp_8348_pointer_623.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %tmp_8348.unpack8, ptr %tmp_8348_pointer_623.repack14, align 8, !noalias !0
  %returnAddress_pointer_624 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_625 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_626 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_529, ptr %returnAddress_pointer_624, align 8, !noalias !0
  store ptr @sharer_607, ptr %sharer_pointer_625, align 8, !noalias !0
  store ptr @eraser_615, ptr %eraser_pointer_626, align 8, !noalias !0
  br i1 %z.i81140, label %label_667, label %label_634

label_634:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i31, label %erasePositive.exit63, label %next.i.i54

next.i.i54:                                       ; preds = %label_634
  %referenceCount.i.i55 = load i64, ptr %tmp_8332.unpack2, align 4
  %cond.i.i56 = icmp eq i64 %referenceCount.i.i55, 0
  br i1 %cond.i.i56, label %free.i.i59, label %decr.i.i57

decr.i.i57:                                       ; preds = %next.i.i54
  %referenceCount.1.i.i58 = add i64 %referenceCount.i.i55, -1
  store i64 %referenceCount.1.i.i58, ptr %tmp_8332.unpack2, align 4
  br label %erasePositive.exit63

free.i.i59:                                       ; preds = %next.i.i54
  %objectEraser.i.i60 = getelementptr i8, ptr %tmp_8332.unpack2, i64 8
  %eraser.i.i61 = load ptr, ptr %objectEraser.i.i60, align 8
  %environment.i.i.i62 = getelementptr i8, ptr %tmp_8332.unpack2, i64 16
  tail call void %eraser.i.i61(ptr %environment.i.i.i62)
  tail call void @free(ptr nonnull %tmp_8332.unpack2)
  br label %erasePositive.exit63

erasePositive.exit63:                             ; preds = %label_634, %decr.i.i57, %free.i.i59
  br i1 %isNull.i.i21, label %erasePositive.exit51, label %next.i.i42

next.i.i42:                                       ; preds = %erasePositive.exit63
  %referenceCount.i.i43 = load i64, ptr %tmp_8348.unpack8, align 4
  %cond.i.i44 = icmp eq i64 %referenceCount.i.i43, 0
  br i1 %cond.i.i44, label %free.i.i47, label %decr.i.i45

decr.i.i45:                                       ; preds = %next.i.i42
  %referenceCount.1.i.i46 = add i64 %referenceCount.i.i43, -1
  store i64 %referenceCount.1.i.i46, ptr %tmp_8348.unpack8, align 4
  br label %erasePositive.exit51

free.i.i47:                                       ; preds = %next.i.i42
  %objectEraser.i.i48 = getelementptr i8, ptr %tmp_8348.unpack8, i64 8
  %eraser.i.i49 = load ptr, ptr %objectEraser.i.i48, align 8
  %environment.i.i.i50 = getelementptr i8, ptr %tmp_8348.unpack8, i64 16
  tail call void %eraser.i.i49(ptr %environment.i.i.i50)
  tail call void @free(ptr nonnull %tmp_8348.unpack8)
  br label %erasePositive.exit51

erasePositive.exit51:                             ; preds = %erasePositive.exit63, %decr.i.i45, %free.i.i47
  %stackPointer.i87 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i89 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i90 = icmp ule ptr %stackPointer.i87, %limit.i89
  tail call void @llvm.assume(i1 %isInside.i90)
  %newStackPointer.i91 = getelementptr i8, ptr %stackPointer.i87, i64 -24
  store ptr %newStackPointer.i91, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_631 = load ptr, ptr %newStackPointer.i91, align 8, !noalias !0
  musttail call tailcc void %returnAddress_631(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_662:                                        ; preds = %stackAllocate.exit134
  musttail call tailcc void %returnAddress_663(double %z.i108, ptr nonnull %stack)
  ret void

label_666:                                        ; preds = %stackAllocate.exit134
  musttail call tailcc void %returnAddress_663(double %d.i107, ptr nonnull %stack)
  ret void

label_667:                                        ; preds = %stackAllocate.exit
  %n.i = bitcast double %yLimit_30_108_648_1426_6506 to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i104 = tail call %Pos @c_ref_set(%Pos %tmp_83323, %Pos %boxed2.i)
  %object.i = extractvalue %Pos %z.i104, 1
  %isNull.i.i36 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i36, label %erasePositive.exit, label %next.i.i37

next.i.i37:                                       ; preds = %label_667
  %referenceCount.i.i38 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i38, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i37
  %referenceCount.1.i.i39 = add i64 %referenceCount.i.i38, -1
  store i64 %referenceCount.1.i.i39, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i37
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_667, %decr.i.i, %free.i.i
  br i1 %isNull.i.i21, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %tmp_8348.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8348.unpack8, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %z.i105 = tail call %Pos @c_ref_get(%Pos %tmp_83489)
  %unboxed.i106 = extractvalue %Pos %z.i105, 0
  %d.i107 = bitcast i64 %unboxed.i106 to double
  %z.i108 = fsub double 0.000000e+00, %d.i107
  %z.i109 = fcmp olt double %z.i108, %d.i107
  %currentStackPointer.i114 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i115 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i116 = getelementptr i8, ptr %currentStackPointer.i114, i64 56
  %isInside.not.i117 = icmp ugt ptr %nextStackPointer.i116, %limit.i115
  br i1 %isInside.not.i117, label %realloc.i120, label %stackAllocate.exit134

realloc.i120:                                     ; preds = %sharePositive.exit
  %base_pointer.i121 = getelementptr i8, ptr %stack, i64 16
  %base.i122 = load ptr, ptr %base_pointer.i121, align 8, !alias.scope !0
  %intStackPointer.i123 = ptrtoint ptr %currentStackPointer.i114 to i64
  %intBase.i124 = ptrtoint ptr %base.i122 to i64
  %size.i125 = sub i64 %intStackPointer.i123, %intBase.i124
  %nextSize.i126 = add i64 %size.i125, 56
  %leadingZeros.i.i127 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i126, i1 false)
  %numBits.i.i128 = sub nuw nsw i64 64, %leadingZeros.i.i127
  %result.i.i129 = shl nuw i64 1, %numBits.i.i128
  %newBase.i130 = tail call ptr @realloc(ptr %base.i122, i64 %result.i.i129)
  %newLimit.i131 = getelementptr i8, ptr %newBase.i130, i64 %result.i.i129
  %newStackPointer.i132 = getelementptr i8, ptr %newBase.i130, i64 %size.i125
  %newNextStackPointer.i133 = getelementptr i8, ptr %newStackPointer.i132, i64 56
  store ptr %newBase.i130, ptr %base_pointer.i121, align 8, !alias.scope !0
  store ptr %newLimit.i131, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit134

stackAllocate.exit134:                            ; preds = %sharePositive.exit, %realloc.i120
  %limit.i101 = phi ptr [ %newLimit.i131, %realloc.i120 ], [ %limit.i115, %sharePositive.exit ]
  %nextStackPointer.sink.i118 = phi ptr [ %newNextStackPointer.i133, %realloc.i120 ], [ %nextStackPointer.i116, %sharePositive.exit ]
  %common.ret.op.i119 = phi ptr [ %newStackPointer.i132, %realloc.i120 ], [ %currentStackPointer.i114, %sharePositive.exit ]
  store i64 %tmp_8348.unpack, ptr %common.ret.op.i119, align 8, !noalias !0
  %stackPointer_650.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i119, i64 8
  store ptr %tmp_8348.unpack8, ptr %stackPointer_650.repack16, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_652 = getelementptr i8, ptr %common.ret.op.i119, i64 16
  store ptr %bounced_32_110_650_1428_6047.unpack, ptr %bounced_32_110_650_1428_6047_pointer_652, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_652.repack18 = getelementptr i8, ptr %common.ret.op.i119, i64 24
  store i64 %bounced_32_110_650_1428_6047.unpack5, ptr %bounced_32_110_650_1428_6047_pointer_652.repack18, align 8, !noalias !0
  %returnAddress_pointer_653 = getelementptr i8, ptr %common.ret.op.i119, i64 32
  %sharer_pointer_654 = getelementptr i8, ptr %common.ret.op.i119, i64 40
  %eraser_pointer_655 = getelementptr i8, ptr %common.ret.op.i119, i64 48
  store ptr @returnAddress_635, ptr %returnAddress_pointer_653, align 8, !noalias !0
  store ptr @sharer_576, ptr %sharer_pointer_654, align 8, !noalias !0
  store ptr @eraser_582, ptr %eraser_pointer_655, align 8, !noalias !0
  %isInside.i102 = icmp ule ptr %nextStackPointer.sink.i118, %limit.i101
  tail call void @llvm.assume(i1 %isInside.i102)
  %newStackPointer.i103 = getelementptr i8, ptr %nextStackPointer.sink.i118, i64 -24
  store ptr %newStackPointer.i103, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_663 = load ptr, ptr %newStackPointer.i103, align 8, !noalias !0
  br i1 %z.i109, label %label_666, label %label_662
}

define void @sharer_672(ptr %stackPointer) {
entry:
  %tmp_8332_668.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_8332_668.unpack2 = load ptr, ptr %tmp_8332_668.elt1, align 8, !noalias !0
  %tmp_8348_671.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_8348_671.unpack5 = load ptr, ptr %tmp_8348_671.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_8332_668.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_8332_668.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %tmp_8332_668.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %tmp_8348_671.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %tmp_8348_671.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8348_671.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_682(ptr %stackPointer) {
entry:
  %tmp_8332_678.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_8332_678.unpack2 = load ptr, ptr %tmp_8332_678.elt1, align 8, !noalias !0
  %tmp_8348_681.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_8348_681.unpack5 = load ptr, ptr %tmp_8348_681.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_8332_678.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_8332_678.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_8332_678.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_8332_678.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_8332_678.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_8332_678.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %tmp_8348_681.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %tmp_8348_681.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8348_681.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8348_681.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8348_681.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8348_681.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_704(double %v_r_3037_73_151_691_1469_6469, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8340.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8340.unpack, 0
  %tmp_8340.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8340.unpack2 = load ptr, ptr %tmp_8340.elt1, align 8, !noalias !0
  %tmp_83403 = insertvalue %Pos %0, ptr %tmp_8340.unpack2, 1
  %bounced_32_110_650_1428_6047_pointer_707 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bounced_32_110_650_1428_6047.unpack = load ptr, ptr %bounced_32_110_650_1428_6047_pointer_707, align 8, !noalias !0
  %bounced_32_110_650_1428_6047.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bounced_32_110_650_1428_6047.unpack5 = load i64, ptr %bounced_32_110_650_1428_6047.elt4, align 8, !noalias !0
  %n.i = bitcast double %v_r_3037_73_151_691_1469_6469 to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i = tail call %Pos @c_ref_set(%Pos %tmp_83403, %Pos %boxed2.i)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i11 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i11, label %erasePositive.exit21, label %next.i.i12

next.i.i12:                                       ; preds = %entry
  %referenceCount.i.i13 = load i64, ptr %object.i, align 4
  %cond.i.i14 = icmp eq i64 %referenceCount.i.i13, 0
  br i1 %cond.i.i14, label %free.i.i17, label %decr.i.i15

decr.i.i15:                                       ; preds = %next.i.i12
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i13, -1
  store i64 %referenceCount.1.i.i16, ptr %object.i, align 4
  br label %erasePositive.exit21

free.i.i17:                                       ; preds = %next.i.i12
  %objectEraser.i.i18 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i19 = load ptr, ptr %objectEraser.i.i18, align 8
  %environment.i.i.i20 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i19(ptr %environment.i.i.i20)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit21

erasePositive.exit21:                             ; preds = %entry, %decr.i.i15, %free.i.i17
  %stack_pointer.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bounced_32_110_650_1428_6047.unpack5
  %bounced_32_110_650_1428_6047_old_710.elt7 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %bounced_32_110_650_1428_6047_old_710.unpack8 = load ptr, ptr %bounced_32_110_650_1428_6047_old_710.elt7, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bounced_32_110_650_1428_6047_old_710.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit21
  %referenceCount.i.i = load i64, ptr %bounced_32_110_650_1428_6047_old_710.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bounced_32_110_650_1428_6047_old_710.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047_old_710.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047_old_710.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bounced_32_110_650_1428_6047_old_710.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit21, %decr.i.i, %free.i.i
  store i64 1, ptr %varPointer.i, align 8, !noalias !0
  store ptr null, ptr %bounced_32_110_650_1428_6047_old_710.elt7, align 8, !noalias !0
  %stackPointer.i28 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i30 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i31 = icmp ule ptr %stackPointer.i28, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %stackPointer.i28, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_712 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_712(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_515(%Pos %__62_140_680_1458_8484, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i76 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %yLimit_30_108_648_1426_6506_pointer_518 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %yLimit_30_108_648_1426_6506 = load double, ptr %yLimit_30_108_648_1426_6506_pointer_518, align 8, !noalias !0
  %tmp_8348_pointer_519 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_8348.unpack = load i64, ptr %tmp_8348_pointer_519, align 8, !noalias !0
  %tmp_8348.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_8348.unpack5 = load ptr, ptr %tmp_8348.elt4, align 8, !noalias !0
  %tmp_8340_pointer_520 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_8340.unpack = load i64, ptr %tmp_8340_pointer_520, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8340.unpack, 0
  %tmp_8340.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_8340.unpack8 = load ptr, ptr %tmp_8340.elt7, align 8, !noalias !0
  %tmp_83409 = insertvalue %Pos %0, ptr %tmp_8340.unpack8, 1
  %tmp_8325_pointer_521 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_521, align 8, !noalias !0
  %1 = insertvalue %Pos poison, i64 %tmp_8325.unpack, 0
  %tmp_8325.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack11 = load ptr, ptr %tmp_8325.elt10, align 8, !noalias !0
  %tmp_832512 = insertvalue %Pos %1, ptr %tmp_8325.unpack11, 1
  %bounced_32_110_650_1428_6047_pointer_522 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bounced_32_110_650_1428_6047.unpack = load ptr, ptr %bounced_32_110_650_1428_6047_pointer_522, align 8, !noalias !0
  %bounced_32_110_650_1428_6047.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bounced_32_110_650_1428_6047.unpack14 = load i64, ptr %bounced_32_110_650_1428_6047.elt13, align 8, !noalias !0
  %object.i60 = extractvalue %Pos %__62_140_680_1458_8484, 1
  %isNull.i.i61 = icmp eq ptr %object.i60, null
  br i1 %isNull.i.i61, label %erasePositive.exit71, label %next.i.i62

next.i.i62:                                       ; preds = %entry
  %referenceCount.i.i63 = load i64, ptr %object.i60, align 4
  %cond.i.i64 = icmp eq i64 %referenceCount.i.i63, 0
  br i1 %cond.i.i64, label %free.i.i67, label %decr.i.i65

decr.i.i65:                                       ; preds = %next.i.i62
  %referenceCount.1.i.i66 = add i64 %referenceCount.i.i63, -1
  store i64 %referenceCount.1.i.i66, ptr %object.i60, align 4
  br label %erasePositive.exit71

free.i.i67:                                       ; preds = %next.i.i62
  %objectEraser.i.i68 = getelementptr i8, ptr %object.i60, i64 8
  %eraser.i.i69 = load ptr, ptr %objectEraser.i.i68, align 8
  %environment.i.i.i70 = getelementptr i8, ptr %object.i60, i64 16
  tail call void %eraser.i.i69(ptr %environment.i.i.i70)
  tail call void @free(ptr nonnull %object.i60)
  br label %erasePositive.exit71

erasePositive.exit71:                             ; preds = %entry, %decr.i.i65, %free.i.i67
  %isNull.i.i27 = icmp eq ptr %tmp_8325.unpack11, null
  br i1 %isNull.i.i27, label %sharePositive.exit31, label %next.i.i28

next.i.i28:                                       ; preds = %erasePositive.exit71
  %referenceCount.i.i29 = load i64, ptr %tmp_8325.unpack11, align 4
  %referenceCount.1.i.i30 = add i64 %referenceCount.i.i29, 1
  store i64 %referenceCount.1.i.i30, ptr %tmp_8325.unpack11, align 4
  br label %sharePositive.exit31

sharePositive.exit31:                             ; preds = %erasePositive.exit71, %next.i.i28
  %z.i = tail call %Pos @c_ref_get(%Pos %tmp_832512)
  %unboxed.i = extractvalue %Pos %z.i, 0
  %d.i = bitcast i64 %unboxed.i to double
  %z.i77 = fcmp olt double %d.i, 0.000000e+00
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i80 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 80
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i80
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit31
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
  %newStackPointer.i81 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i81, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit31, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit31 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i81, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit31 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8332.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_688.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_8332.unpack2, ptr %stackPointer_688.repack16, align 8, !noalias !0
  %yLimit_30_108_648_1426_6506_pointer_690 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store double %yLimit_30_108_648_1426_6506, ptr %yLimit_30_108_648_1426_6506_pointer_690, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_691 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %bounced_32_110_650_1428_6047.unpack, ptr %bounced_32_110_650_1428_6047_pointer_691, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_691.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %bounced_32_110_650_1428_6047.unpack14, ptr %bounced_32_110_650_1428_6047_pointer_691.repack18, align 8, !noalias !0
  %tmp_8348_pointer_692 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_8348.unpack, ptr %tmp_8348_pointer_692, align 8, !noalias !0
  %tmp_8348_pointer_692.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %tmp_8348.unpack5, ptr %tmp_8348_pointer_692.repack20, align 8, !noalias !0
  %returnAddress_pointer_693 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_694 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_695 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_523, ptr %returnAddress_pointer_693, align 8, !noalias !0
  store ptr @sharer_672, ptr %sharer_pointer_694, align 8, !noalias !0
  store ptr @eraser_682, ptr %eraser_pointer_695, align 8, !noalias !0
  br i1 %z.i77, label %label_736, label %label_703

label_703:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i27, label %erasePositive.exit59, label %next.i.i50

next.i.i50:                                       ; preds = %label_703
  %referenceCount.i.i51 = load i64, ptr %tmp_8325.unpack11, align 4
  %cond.i.i52 = icmp eq i64 %referenceCount.i.i51, 0
  br i1 %cond.i.i52, label %free.i.i55, label %decr.i.i53

decr.i.i53:                                       ; preds = %next.i.i50
  %referenceCount.1.i.i54 = add i64 %referenceCount.i.i51, -1
  store i64 %referenceCount.1.i.i54, ptr %tmp_8325.unpack11, align 4
  br label %erasePositive.exit59

free.i.i55:                                       ; preds = %next.i.i50
  %objectEraser.i.i56 = getelementptr i8, ptr %tmp_8325.unpack11, i64 8
  %eraser.i.i57 = load ptr, ptr %objectEraser.i.i56, align 8
  %environment.i.i.i58 = getelementptr i8, ptr %tmp_8325.unpack11, i64 16
  tail call void %eraser.i.i57(ptr %environment.i.i.i58)
  tail call void @free(ptr nonnull %tmp_8325.unpack11)
  br label %erasePositive.exit59

erasePositive.exit59:                             ; preds = %label_703, %decr.i.i53, %free.i.i55
  %isNull.i.i37 = icmp eq ptr %tmp_8340.unpack8, null
  br i1 %isNull.i.i37, label %erasePositive.exit47, label %next.i.i38

next.i.i38:                                       ; preds = %erasePositive.exit59
  %referenceCount.i.i39 = load i64, ptr %tmp_8340.unpack8, align 4
  %cond.i.i40 = icmp eq i64 %referenceCount.i.i39, 0
  br i1 %cond.i.i40, label %free.i.i43, label %decr.i.i41

decr.i.i41:                                       ; preds = %next.i.i38
  %referenceCount.1.i.i42 = add i64 %referenceCount.i.i39, -1
  store i64 %referenceCount.1.i.i42, ptr %tmp_8340.unpack8, align 4
  br label %erasePositive.exit47

free.i.i43:                                       ; preds = %next.i.i38
  %objectEraser.i.i44 = getelementptr i8, ptr %tmp_8340.unpack8, i64 8
  %eraser.i.i45 = load ptr, ptr %objectEraser.i.i44, align 8
  %environment.i.i.i46 = getelementptr i8, ptr %tmp_8340.unpack8, i64 16
  tail call void %eraser.i.i45(ptr %environment.i.i.i46)
  tail call void @free(ptr nonnull %tmp_8340.unpack8)
  br label %erasePositive.exit47

erasePositive.exit47:                             ; preds = %erasePositive.exit59, %decr.i.i41, %free.i.i43
  %stackPointer.i83 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i85 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i86 = icmp ule ptr %stackPointer.i83, %limit.i85
  tail call void @llvm.assume(i1 %isInside.i86)
  %newStackPointer.i87 = getelementptr i8, ptr %stackPointer.i83, i64 -24
  store ptr %newStackPointer.i87, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_700 = load ptr, ptr %newStackPointer.i87, align 8, !noalias !0
  musttail call tailcc void %returnAddress_700(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_731:                                        ; preds = %stackAllocate.exit130
  musttail call tailcc void %returnAddress_732(double %z.i104, ptr nonnull %stack)
  ret void

label_735:                                        ; preds = %stackAllocate.exit130
  musttail call tailcc void %returnAddress_732(double %d.i103, ptr nonnull %stack)
  ret void

label_736:                                        ; preds = %stackAllocate.exit
  %z.i100 = tail call %Pos @c_ref_set(%Pos %tmp_832512, %Pos zeroinitializer)
  %object.i = extractvalue %Pos %z.i100, 1
  %isNull.i.i32 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i32, label %erasePositive.exit, label %next.i.i33

next.i.i33:                                       ; preds = %label_736
  %referenceCount.i.i34 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i34, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i33
  %referenceCount.1.i.i35 = add i64 %referenceCount.i.i34, -1
  store i64 %referenceCount.1.i.i35, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i33
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_736, %decr.i.i, %free.i.i
  %isNull.i.i = icmp eq ptr %tmp_8340.unpack8, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %tmp_8340.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8340.unpack8, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %z.i101 = tail call %Pos @c_ref_get(%Pos %tmp_83409)
  %unboxed.i102 = extractvalue %Pos %z.i101, 0
  %d.i103 = bitcast i64 %unboxed.i102 to double
  %z.i104 = fsub double 0.000000e+00, %d.i103
  %z.i105 = fcmp olt double %z.i104, %d.i103
  %currentStackPointer.i110 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i111 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i112 = getelementptr i8, ptr %currentStackPointer.i110, i64 56
  %isInside.not.i113 = icmp ugt ptr %nextStackPointer.i112, %limit.i111
  br i1 %isInside.not.i113, label %realloc.i116, label %stackAllocate.exit130

realloc.i116:                                     ; preds = %sharePositive.exit
  %base_pointer.i117 = getelementptr i8, ptr %stack, i64 16
  %base.i118 = load ptr, ptr %base_pointer.i117, align 8, !alias.scope !0
  %intStackPointer.i119 = ptrtoint ptr %currentStackPointer.i110 to i64
  %intBase.i120 = ptrtoint ptr %base.i118 to i64
  %size.i121 = sub i64 %intStackPointer.i119, %intBase.i120
  %nextSize.i122 = add i64 %size.i121, 56
  %leadingZeros.i.i123 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i122, i1 false)
  %numBits.i.i124 = sub nuw nsw i64 64, %leadingZeros.i.i123
  %result.i.i125 = shl nuw i64 1, %numBits.i.i124
  %newBase.i126 = tail call ptr @realloc(ptr %base.i118, i64 %result.i.i125)
  %newLimit.i127 = getelementptr i8, ptr %newBase.i126, i64 %result.i.i125
  %newStackPointer.i128 = getelementptr i8, ptr %newBase.i126, i64 %size.i121
  %newNextStackPointer.i129 = getelementptr i8, ptr %newStackPointer.i128, i64 56
  store ptr %newBase.i126, ptr %base_pointer.i117, align 8, !alias.scope !0
  store ptr %newLimit.i127, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit130

stackAllocate.exit130:                            ; preds = %sharePositive.exit, %realloc.i116
  %limit.i97 = phi ptr [ %newLimit.i127, %realloc.i116 ], [ %limit.i111, %sharePositive.exit ]
  %nextStackPointer.sink.i114 = phi ptr [ %newNextStackPointer.i129, %realloc.i116 ], [ %nextStackPointer.i112, %sharePositive.exit ]
  %common.ret.op.i115 = phi ptr [ %newStackPointer.i128, %realloc.i116 ], [ %currentStackPointer.i110, %sharePositive.exit ]
  store i64 %tmp_8340.unpack, ptr %common.ret.op.i115, align 8, !noalias !0
  %stackPointer_719.repack22 = getelementptr inbounds i8, ptr %common.ret.op.i115, i64 8
  store ptr %tmp_8340.unpack8, ptr %stackPointer_719.repack22, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_721 = getelementptr i8, ptr %common.ret.op.i115, i64 16
  store ptr %bounced_32_110_650_1428_6047.unpack, ptr %bounced_32_110_650_1428_6047_pointer_721, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_721.repack24 = getelementptr i8, ptr %common.ret.op.i115, i64 24
  store i64 %bounced_32_110_650_1428_6047.unpack14, ptr %bounced_32_110_650_1428_6047_pointer_721.repack24, align 8, !noalias !0
  %returnAddress_pointer_722 = getelementptr i8, ptr %common.ret.op.i115, i64 32
  %sharer_pointer_723 = getelementptr i8, ptr %common.ret.op.i115, i64 40
  %eraser_pointer_724 = getelementptr i8, ptr %common.ret.op.i115, i64 48
  store ptr @returnAddress_704, ptr %returnAddress_pointer_722, align 8, !noalias !0
  store ptr @sharer_576, ptr %sharer_pointer_723, align 8, !noalias !0
  store ptr @eraser_582, ptr %eraser_pointer_724, align 8, !noalias !0
  %isInside.i98 = icmp ule ptr %nextStackPointer.sink.i114, %limit.i97
  tail call void @llvm.assume(i1 %isInside.i98)
  %newStackPointer.i99 = getelementptr i8, ptr %nextStackPointer.sink.i114, i64 -24
  store ptr %newStackPointer.i99, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_732 = load ptr, ptr %newStackPointer.i99, align 8, !noalias !0
  br i1 %z.i105, label %label_735, label %label_731
}

define void @sharer_743(ptr %stackPointer) {
entry:
  %tmp_8332_737.elt1 = getelementptr i8, ptr %stackPointer, i64 -80
  %tmp_8332_737.unpack2 = load ptr, ptr %tmp_8332_737.elt1, align 8, !noalias !0
  %tmp_8348_739.elt4 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_8348_739.unpack5 = load ptr, ptr %tmp_8348_739.elt4, align 8, !noalias !0
  %tmp_8340_740.elt7 = getelementptr i8, ptr %stackPointer, i64 -40
  %tmp_8340_740.unpack8 = load ptr, ptr %tmp_8340_740.elt7, align 8, !noalias !0
  %tmp_8325_741.elt10 = getelementptr i8, ptr %stackPointer, i64 -24
  %tmp_8325_741.unpack11 = load ptr, ptr %tmp_8325_741.elt10, align 8, !noalias !0
  %isNull.i.i23 = icmp eq ptr %tmp_8332_737.unpack2, null
  br i1 %isNull.i.i23, label %sharePositive.exit27, label %next.i.i24

next.i.i24:                                       ; preds = %entry
  %referenceCount.i.i25 = load i64, ptr %tmp_8332_737.unpack2, align 4
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i25, 1
  store i64 %referenceCount.1.i.i26, ptr %tmp_8332_737.unpack2, align 4
  br label %sharePositive.exit27

sharePositive.exit27:                             ; preds = %entry, %next.i.i24
  %isNull.i.i18 = icmp eq ptr %tmp_8348_739.unpack5, null
  br i1 %isNull.i.i18, label %sharePositive.exit22, label %next.i.i19

next.i.i19:                                       ; preds = %sharePositive.exit27
  %referenceCount.i.i20 = load i64, ptr %tmp_8348_739.unpack5, align 4
  %referenceCount.1.i.i21 = add i64 %referenceCount.i.i20, 1
  store i64 %referenceCount.1.i.i21, ptr %tmp_8348_739.unpack5, align 4
  br label %sharePositive.exit22

sharePositive.exit22:                             ; preds = %sharePositive.exit27, %next.i.i19
  %isNull.i.i13 = icmp eq ptr %tmp_8340_740.unpack8, null
  br i1 %isNull.i.i13, label %sharePositive.exit17, label %next.i.i14

next.i.i14:                                       ; preds = %sharePositive.exit22
  %referenceCount.i.i15 = load i64, ptr %tmp_8340_740.unpack8, align 4
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i15, 1
  store i64 %referenceCount.1.i.i16, ptr %tmp_8340_740.unpack8, align 4
  br label %sharePositive.exit17

sharePositive.exit17:                             ; preds = %sharePositive.exit22, %next.i.i14
  %isNull.i.i = icmp eq ptr %tmp_8325_741.unpack11, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit17
  %referenceCount.i.i = load i64, ptr %tmp_8325_741.unpack11, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8325_741.unpack11, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit17, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_757(ptr %stackPointer) {
entry:
  %tmp_8332_751.elt1 = getelementptr i8, ptr %stackPointer, i64 -80
  %tmp_8332_751.unpack2 = load ptr, ptr %tmp_8332_751.elt1, align 8, !noalias !0
  %tmp_8348_753.elt4 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_8348_753.unpack5 = load ptr, ptr %tmp_8348_753.elt4, align 8, !noalias !0
  %tmp_8340_754.elt7 = getelementptr i8, ptr %stackPointer, i64 -40
  %tmp_8340_754.unpack8 = load ptr, ptr %tmp_8340_754.elt7, align 8, !noalias !0
  %tmp_8325_755.elt10 = getelementptr i8, ptr %stackPointer, i64 -24
  %tmp_8325_755.unpack11 = load ptr, ptr %tmp_8325_755.elt10, align 8, !noalias !0
  %isNull.i.i35 = icmp eq ptr %tmp_8332_751.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %entry
  %referenceCount.i.i37 = load i64, ptr %tmp_8332_751.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %tmp_8332_751.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %tmp_8332_751.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %tmp_8332_751.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %tmp_8332_751.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %entry, %decr.i.i39, %free.i.i41
  %isNull.i.i24 = icmp eq ptr %tmp_8348_753.unpack5, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %erasePositive.exit45
  %referenceCount.i.i26 = load i64, ptr %tmp_8348_753.unpack5, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %tmp_8348_753.unpack5, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %tmp_8348_753.unpack5, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %tmp_8348_753.unpack5, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %tmp_8348_753.unpack5)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %erasePositive.exit45, %decr.i.i28, %free.i.i30
  %isNull.i.i13 = icmp eq ptr %tmp_8340_754.unpack8, null
  br i1 %isNull.i.i13, label %erasePositive.exit23, label %next.i.i14

next.i.i14:                                       ; preds = %erasePositive.exit34
  %referenceCount.i.i15 = load i64, ptr %tmp_8340_754.unpack8, align 4
  %cond.i.i16 = icmp eq i64 %referenceCount.i.i15, 0
  br i1 %cond.i.i16, label %free.i.i19, label %decr.i.i17

decr.i.i17:                                       ; preds = %next.i.i14
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i15, -1
  store i64 %referenceCount.1.i.i18, ptr %tmp_8340_754.unpack8, align 4
  br label %erasePositive.exit23

free.i.i19:                                       ; preds = %next.i.i14
  %objectEraser.i.i20 = getelementptr i8, ptr %tmp_8340_754.unpack8, i64 8
  %eraser.i.i21 = load ptr, ptr %objectEraser.i.i20, align 8
  %environment.i.i.i22 = getelementptr i8, ptr %tmp_8340_754.unpack8, i64 16
  tail call void %eraser.i.i21(ptr %environment.i.i.i22)
  tail call void @free(ptr nonnull %tmp_8340_754.unpack8)
  br label %erasePositive.exit23

erasePositive.exit23:                             ; preds = %erasePositive.exit34, %decr.i.i17, %free.i.i19
  %isNull.i.i = icmp eq ptr %tmp_8325_755.unpack11, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit23
  %referenceCount.i.i = load i64, ptr %tmp_8325_755.unpack11, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8325_755.unpack11, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8325_755.unpack11, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8325_755.unpack11, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8325_755.unpack11)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit23, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -96
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_783(double %v_r_3031_57_135_675_1453_6285, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8340.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8340.unpack, 0
  %tmp_8340.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8340.unpack2 = load ptr, ptr %tmp_8340.elt1, align 8, !noalias !0
  %tmp_83403 = insertvalue %Pos %0, ptr %tmp_8340.unpack2, 1
  %bounced_32_110_650_1428_6047_pointer_786 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %bounced_32_110_650_1428_6047.unpack = load ptr, ptr %bounced_32_110_650_1428_6047_pointer_786, align 8, !noalias !0
  %bounced_32_110_650_1428_6047.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bounced_32_110_650_1428_6047.unpack5 = load i64, ptr %bounced_32_110_650_1428_6047.elt4, align 8, !noalias !0
  %z.i = fsub double 0.000000e+00, %v_r_3031_57_135_675_1453_6285
  %n.i = bitcast double %z.i to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i27 = tail call %Pos @c_ref_set(%Pos %tmp_83403, %Pos %boxed2.i)
  %object.i = extractvalue %Pos %z.i27, 1
  %isNull.i.i11 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i11, label %erasePositive.exit21, label %next.i.i12

next.i.i12:                                       ; preds = %entry
  %referenceCount.i.i13 = load i64, ptr %object.i, align 4
  %cond.i.i14 = icmp eq i64 %referenceCount.i.i13, 0
  br i1 %cond.i.i14, label %free.i.i17, label %decr.i.i15

decr.i.i15:                                       ; preds = %next.i.i12
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i13, -1
  store i64 %referenceCount.1.i.i16, ptr %object.i, align 4
  br label %erasePositive.exit21

free.i.i17:                                       ; preds = %next.i.i12
  %objectEraser.i.i18 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i19 = load ptr, ptr %objectEraser.i.i18, align 8
  %environment.i.i.i20 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i19(ptr %environment.i.i.i20)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit21

erasePositive.exit21:                             ; preds = %entry, %decr.i.i15, %free.i.i17
  %stack_pointer.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bounced_32_110_650_1428_6047.unpack5
  %bounced_32_110_650_1428_6047_old_789.elt7 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %bounced_32_110_650_1428_6047_old_789.unpack8 = load ptr, ptr %bounced_32_110_650_1428_6047_old_789.elt7, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %bounced_32_110_650_1428_6047_old_789.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit21
  %referenceCount.i.i = load i64, ptr %bounced_32_110_650_1428_6047_old_789.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %bounced_32_110_650_1428_6047_old_789.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047_old_789.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %bounced_32_110_650_1428_6047_old_789.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %bounced_32_110_650_1428_6047_old_789.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit21, %decr.i.i, %free.i.i
  store i64 1, ptr %varPointer.i, align 8, !noalias !0
  store ptr null, ptr %bounced_32_110_650_1428_6047_old_789.elt7, align 8, !noalias !0
  %stackPointer.i29 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i31 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i32 = icmp ule ptr %stackPointer.i29, %limit.i31
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i33 = getelementptr i8, ptr %stackPointer.i29, i64 -24
  store ptr %newStackPointer.i33, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_791 = load ptr, ptr %newStackPointer.i33, align 8, !noalias !0
  musttail call tailcc void %returnAddress_791(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @new_8539_clause_488(ptr %closure, ptr %stack) {
entry:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %tmp_8332.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8332.unpack, 0
  %tmp_8332.elt1 = getelementptr i8, ptr %closure, i64 24
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_83323 = insertvalue %Pos %0, ptr %tmp_8332.unpack2, 1
  %tmp_8325_pointer_491 = getelementptr i8, ptr %closure, i64 32
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_491, align 8, !noalias !0
  %1 = insertvalue %Pos poison, i64 %tmp_8325.unpack, 0
  %tmp_8325.elt4 = getelementptr i8, ptr %closure, i64 40
  %tmp_8325.unpack5 = load ptr, ptr %tmp_8325.elt4, align 8, !noalias !0
  %tmp_83256 = insertvalue %Pos %1, ptr %tmp_8325.unpack5, 1
  %tmp_8348_pointer_492 = getelementptr i8, ptr %closure, i64 48
  %tmp_8348.unpack = load i64, ptr %tmp_8348_pointer_492, align 8, !noalias !0
  %2 = insertvalue %Pos poison, i64 %tmp_8348.unpack, 0
  %tmp_8348.elt7 = getelementptr i8, ptr %closure, i64 56
  %tmp_8348.unpack8 = load ptr, ptr %tmp_8348.elt7, align 8, !noalias !0
  %tmp_83489 = insertvalue %Pos %2, ptr %tmp_8348.unpack8, 1
  %tmp_8340_pointer_493 = getelementptr i8, ptr %closure, i64 64
  %tmp_8340.unpack = load i64, ptr %tmp_8340_pointer_493, align 8, !noalias !0
  %3 = insertvalue %Pos poison, i64 %tmp_8340.unpack, 0
  %tmp_8340.elt10 = getelementptr i8, ptr %closure, i64 72
  %tmp_8340.unpack11 = load ptr, ptr %tmp_8340.elt10, align 8, !noalias !0
  %tmp_834012 = insertvalue %Pos %3, ptr %tmp_8340.unpack11, 1
  %isNull.i.i90 = icmp eq ptr %tmp_8332.unpack2, null
  br i1 %isNull.i.i90, label %sharePositive.exit94, label %next.i.i91

next.i.i91:                                       ; preds = %entry
  %referenceCount.i.i92 = load i64, ptr %tmp_8332.unpack2, align 4
  %referenceCount.1.i.i93 = add i64 %referenceCount.i.i92, 1
  store i64 %referenceCount.1.i.i93, ptr %tmp_8332.unpack2, align 4
  br label %sharePositive.exit94

sharePositive.exit94:                             ; preds = %entry, %next.i.i91
  %isNull.i.i85 = icmp eq ptr %tmp_8325.unpack5, null
  br i1 %isNull.i.i85, label %sharePositive.exit89, label %next.i.i86

next.i.i86:                                       ; preds = %sharePositive.exit94
  %referenceCount.i.i87 = load i64, ptr %tmp_8325.unpack5, align 4
  %referenceCount.1.i.i88 = add i64 %referenceCount.i.i87, 1
  store i64 %referenceCount.1.i.i88, ptr %tmp_8325.unpack5, align 4
  br label %sharePositive.exit89

sharePositive.exit89:                             ; preds = %sharePositive.exit94, %next.i.i86
  %isNull.i.i80 = icmp eq ptr %tmp_8348.unpack8, null
  br i1 %isNull.i.i80, label %sharePositive.exit84, label %next.i.i81

next.i.i81:                                       ; preds = %sharePositive.exit89
  %referenceCount.i.i82 = load i64, ptr %tmp_8348.unpack8, align 4
  %referenceCount.1.i.i83 = add i64 %referenceCount.i.i82, 1
  store i64 %referenceCount.1.i.i83, ptr %tmp_8348.unpack8, align 4
  br label %sharePositive.exit84

sharePositive.exit84:                             ; preds = %sharePositive.exit89, %next.i.i81
  %isNull.i.i75 = icmp eq ptr %tmp_8340.unpack11, null
  br i1 %isNull.i.i75, label %next.i, label %next.i.i76

next.i.i76:                                       ; preds = %sharePositive.exit84
  %referenceCount.i.i77 = load i64, ptr %tmp_8340.unpack11, align 4
  %referenceCount.1.i.i78 = add i64 %referenceCount.i.i77, 1
  store i64 %referenceCount.1.i.i78, ptr %tmp_8340.unpack11, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i76, %sharePositive.exit84
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
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i147 = load ptr, ptr %prompt_pointer.i, align 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit
  %nextSize.i = add i64 %offset.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %offset.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %stackPointer.i, %eraseObject.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %returnAddress_pointer_512 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_513 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_514 = getelementptr i8, ptr %common.ret.op.i, i64 32
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %common.ret.op.i, i8 0, i64 16, i1 false)
  store ptr @returnAddress_495, ptr %returnAddress_pointer_512, align 8, !noalias !0
  store ptr @sharer_503, ptr %sharer_pointer_513, align 8, !noalias !0
  store ptr @eraser_507, ptr %eraser_pointer_514, align 8, !noalias !0
  br i1 %isNull.i.i85, label %sharePositive.exit74, label %next.i.i71

next.i.i71:                                       ; preds = %stackAllocate.exit
  %referenceCount.i.i72 = load i64, ptr %tmp_8325.unpack5, align 4
  %referenceCount.1.i.i73 = add i64 %referenceCount.i.i72, 1
  store i64 %referenceCount.1.i.i73, ptr %tmp_8325.unpack5, align 4
  br label %sharePositive.exit74

sharePositive.exit74:                             ; preds = %stackAllocate.exit, %next.i.i71
  %z.i = tail call %Pos @c_ref_get(%Pos %tmp_83256)
  %unboxed.i = extractvalue %Pos %z.i, 0
  %d.i = bitcast i64 %unboxed.i to double
  br i1 %isNull.i.i75, label %sharePositive.exit69, label %next.i.i66

next.i.i66:                                       ; preds = %sharePositive.exit74
  %referenceCount.i.i67 = load i64, ptr %tmp_8340.unpack11, align 4
  %referenceCount.1.i.i68 = add i64 %referenceCount.i.i67, 1
  store i64 %referenceCount.1.i.i68, ptr %tmp_8340.unpack11, align 4
  br label %sharePositive.exit69

sharePositive.exit69:                             ; preds = %sharePositive.exit74, %next.i.i66
  %z.i152 = tail call %Pos @c_ref_get(%Pos %tmp_834012)
  %unboxed.i153 = extractvalue %Pos %z.i152, 0
  %d.i154 = bitcast i64 %unboxed.i153 to double
  %z.i155 = fadd double %d.i, %d.i154
  %n.i = bitcast double %z.i155 to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  br i1 %isNull.i.i85, label %sharePositive.exit64, label %next.i.i61

next.i.i61:                                       ; preds = %sharePositive.exit69
  %referenceCount.i.i62 = load i64, ptr %tmp_8325.unpack5, align 4
  %referenceCount.1.i.i63 = add i64 %referenceCount.i.i62, 1
  store i64 %referenceCount.1.i.i63, ptr %tmp_8325.unpack5, align 4
  br label %sharePositive.exit64

sharePositive.exit64:                             ; preds = %sharePositive.exit69, %next.i.i61
  %z.i156 = tail call %Pos @c_ref_set(%Pos %tmp_83256, %Pos %boxed2.i)
  %object.i135 = extractvalue %Pos %z.i156, 1
  %isNull.i.i136 = icmp eq ptr %object.i135, null
  br i1 %isNull.i.i136, label %erasePositive.exit146, label %next.i.i137

next.i.i137:                                      ; preds = %sharePositive.exit64
  %referenceCount.i.i138 = load i64, ptr %object.i135, align 4
  %cond.i.i139 = icmp eq i64 %referenceCount.i.i138, 0
  br i1 %cond.i.i139, label %free.i.i142, label %decr.i.i140

decr.i.i140:                                      ; preds = %next.i.i137
  %referenceCount.1.i.i141 = add i64 %referenceCount.i.i138, -1
  store i64 %referenceCount.1.i.i141, ptr %object.i135, align 4
  br label %erasePositive.exit146

free.i.i142:                                      ; preds = %next.i.i137
  %objectEraser.i.i143 = getelementptr i8, ptr %object.i135, i64 8
  %eraser.i.i144 = load ptr, ptr %objectEraser.i.i143, align 8
  %environment.i.i.i145 = getelementptr i8, ptr %object.i135, i64 16
  tail call void %eraser.i.i144(ptr %environment.i.i.i145)
  tail call void @free(ptr nonnull %object.i135)
  br label %erasePositive.exit146

erasePositive.exit146:                            ; preds = %sharePositive.exit64, %decr.i.i140, %free.i.i142
  br i1 %isNull.i.i90, label %sharePositive.exit59, label %next.i.i56

next.i.i56:                                       ; preds = %erasePositive.exit146
  %referenceCount.i.i57 = load i64, ptr %tmp_8332.unpack2, align 4
  %referenceCount.1.i.i58 = add i64 %referenceCount.i.i57, 1
  store i64 %referenceCount.1.i.i58, ptr %tmp_8332.unpack2, align 4
  br label %sharePositive.exit59

sharePositive.exit59:                             ; preds = %erasePositive.exit146, %next.i.i56
  %z.i157 = tail call %Pos @c_ref_get(%Pos %tmp_83323)
  %unboxed.i158 = extractvalue %Pos %z.i157, 0
  %d.i159 = bitcast i64 %unboxed.i158 to double
  br i1 %isNull.i.i80, label %sharePositive.exit54, label %next.i.i51

next.i.i51:                                       ; preds = %sharePositive.exit59
  %referenceCount.i.i52 = load i64, ptr %tmp_8348.unpack8, align 4
  %referenceCount.1.i.i53 = add i64 %referenceCount.i.i52, 1
  store i64 %referenceCount.1.i.i53, ptr %tmp_8348.unpack8, align 4
  br label %sharePositive.exit54

sharePositive.exit54:                             ; preds = %sharePositive.exit59, %next.i.i51
  %z.i160 = tail call %Pos @c_ref_get(%Pos %tmp_83489)
  %unboxed.i161 = extractvalue %Pos %z.i160, 0
  %d.i162 = bitcast i64 %unboxed.i161 to double
  %z.i163 = fadd double %d.i159, %d.i162
  %n.i164 = bitcast double %z.i163 to i64
  %boxed1.i165 = insertvalue %Pos zeroinitializer, i64 %n.i164, 0
  %boxed2.i166 = insertvalue %Pos %boxed1.i165, ptr null, 1
  br i1 %isNull.i.i90, label %sharePositive.exit49, label %next.i.i46

next.i.i46:                                       ; preds = %sharePositive.exit54
  %referenceCount.i.i47 = load i64, ptr %tmp_8332.unpack2, align 4
  %referenceCount.1.i.i48 = add i64 %referenceCount.i.i47, 1
  store i64 %referenceCount.1.i.i48, ptr %tmp_8332.unpack2, align 4
  br label %sharePositive.exit49

sharePositive.exit49:                             ; preds = %sharePositive.exit54, %next.i.i46
  %z.i167 = tail call %Pos @c_ref_set(%Pos %tmp_83323, %Pos %boxed2.i166)
  %object.i123 = extractvalue %Pos %z.i167, 1
  %isNull.i.i124 = icmp eq ptr %object.i123, null
  br i1 %isNull.i.i124, label %erasePositive.exit134, label %next.i.i125

next.i.i125:                                      ; preds = %sharePositive.exit49
  %referenceCount.i.i126 = load i64, ptr %object.i123, align 4
  %cond.i.i127 = icmp eq i64 %referenceCount.i.i126, 0
  br i1 %cond.i.i127, label %free.i.i130, label %decr.i.i128

decr.i.i128:                                      ; preds = %next.i.i125
  %referenceCount.1.i.i129 = add i64 %referenceCount.i.i126, -1
  store i64 %referenceCount.1.i.i129, ptr %object.i123, align 4
  br label %erasePositive.exit134

free.i.i130:                                      ; preds = %next.i.i125
  %objectEraser.i.i131 = getelementptr i8, ptr %object.i123, i64 8
  %eraser.i.i132 = load ptr, ptr %objectEraser.i.i131, align 8
  %environment.i.i.i133 = getelementptr i8, ptr %object.i123, i64 16
  tail call void %eraser.i.i132(ptr %environment.i.i.i133)
  tail call void @free(ptr nonnull %object.i123)
  br label %erasePositive.exit134

erasePositive.exit134:                            ; preds = %sharePositive.exit49, %decr.i.i128, %free.i.i130
  br i1 %isNull.i.i85, label %sharePositive.exit44, label %next.i.i41

next.i.i41:                                       ; preds = %erasePositive.exit134
  %referenceCount.i.i42 = load i64, ptr %tmp_8325.unpack5, align 4
  %referenceCount.1.i.i43 = add i64 %referenceCount.i.i42, 1
  store i64 %referenceCount.1.i.i43, ptr %tmp_8325.unpack5, align 4
  br label %sharePositive.exit44

sharePositive.exit44:                             ; preds = %erasePositive.exit134, %next.i.i41
  %z.i168 = tail call %Pos @c_ref_get(%Pos %tmp_83256)
  %unboxed.i169 = extractvalue %Pos %z.i168, 0
  %d.i170 = bitcast i64 %unboxed.i169 to double
  %z.i171 = fcmp ogt double %d.i170, 5.000000e+02
  br i1 %isNull.i.i75, label %sharePositive.exit39, label %next.i.i36

next.i.i36:                                       ; preds = %sharePositive.exit44
  %referenceCount.i.i37 = load i64, ptr %tmp_8340.unpack11, align 4
  %referenceCount.1.i.i38 = add i64 %referenceCount.i.i37, 1
  store i64 %referenceCount.1.i.i38, ptr %tmp_8340.unpack11, align 4
  br label %sharePositive.exit39

sharePositive.exit39:                             ; preds = %sharePositive.exit44, %next.i.i36
  br i1 %isNull.i.i85, label %sharePositive.exit34, label %next.i.i31

next.i.i31:                                       ; preds = %sharePositive.exit39
  %referenceCount.i.i32 = load i64, ptr %tmp_8325.unpack5, align 4
  %referenceCount.1.i.i33 = add i64 %referenceCount.i.i32, 1
  store i64 %referenceCount.1.i.i33, ptr %tmp_8325.unpack5, align 4
  br label %sharePositive.exit34

sharePositive.exit34:                             ; preds = %sharePositive.exit39, %next.i.i31
  %currentStackPointer.i174 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i175 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i176 = getelementptr i8, ptr %currentStackPointer.i174, i64 112
  %isInside.not.i177 = icmp ugt ptr %nextStackPointer.i176, %limit.i175
  br i1 %isInside.not.i177, label %realloc.i180, label %stackAllocate.exit194

realloc.i180:                                     ; preds = %sharePositive.exit34
  %base.i182 = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i183 = ptrtoint ptr %currentStackPointer.i174 to i64
  %intBase.i184 = ptrtoint ptr %base.i182 to i64
  %size.i185 = sub i64 %intStackPointer.i183, %intBase.i184
  %nextSize.i186 = add i64 %size.i185, 112
  %leadingZeros.i.i187 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i186, i1 false)
  %numBits.i.i188 = sub nuw nsw i64 64, %leadingZeros.i.i187
  %result.i.i189 = shl nuw i64 1, %numBits.i.i188
  %newBase.i190 = tail call ptr @realloc(ptr %base.i182, i64 %result.i.i189)
  %newLimit.i191 = getelementptr i8, ptr %newBase.i190, i64 %result.i.i189
  %newStackPointer.i192 = getelementptr i8, ptr %newBase.i190, i64 %size.i185
  %newNextStackPointer.i193 = getelementptr i8, ptr %newStackPointer.i192, i64 112
  store ptr %newBase.i190, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i191, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit194

stackAllocate.exit194:                            ; preds = %sharePositive.exit34, %realloc.i180
  %nextStackPointer.sink.i178 = phi ptr [ %newNextStackPointer.i193, %realloc.i180 ], [ %nextStackPointer.i176, %sharePositive.exit34 ]
  %common.ret.op.i179 = phi ptr [ %newStackPointer.i192, %realloc.i180 ], [ %currentStackPointer.i174, %sharePositive.exit34 ]
  store ptr %nextStackPointer.sink.i178, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8332.unpack, ptr %common.ret.op.i179, align 8, !noalias !0
  %stackPointer_765.repack14 = getelementptr inbounds i8, ptr %common.ret.op.i179, i64 8
  store ptr %tmp_8332.unpack2, ptr %stackPointer_765.repack14, align 8, !noalias !0
  %yLimit_30_108_648_1426_6506_pointer_767 = getelementptr i8, ptr %common.ret.op.i179, i64 16
  store double 5.000000e+02, ptr %yLimit_30_108_648_1426_6506_pointer_767, align 8, !noalias !0
  %tmp_8348_pointer_768 = getelementptr i8, ptr %common.ret.op.i179, i64 24
  store i64 %tmp_8348.unpack, ptr %tmp_8348_pointer_768, align 8, !noalias !0
  %tmp_8348_pointer_768.repack16 = getelementptr i8, ptr %common.ret.op.i179, i64 32
  store ptr %tmp_8348.unpack8, ptr %tmp_8348_pointer_768.repack16, align 8, !noalias !0
  %tmp_8340_pointer_769 = getelementptr i8, ptr %common.ret.op.i179, i64 40
  store i64 %tmp_8340.unpack, ptr %tmp_8340_pointer_769, align 8, !noalias !0
  %tmp_8340_pointer_769.repack18 = getelementptr i8, ptr %common.ret.op.i179, i64 48
  store ptr %tmp_8340.unpack11, ptr %tmp_8340_pointer_769.repack18, align 8, !noalias !0
  %tmp_8325_pointer_770 = getelementptr i8, ptr %common.ret.op.i179, i64 56
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_770, align 8, !noalias !0
  %tmp_8325_pointer_770.repack20 = getelementptr i8, ptr %common.ret.op.i179, i64 64
  store ptr %tmp_8325.unpack5, ptr %tmp_8325_pointer_770.repack20, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_771 = getelementptr i8, ptr %common.ret.op.i179, i64 72
  store ptr %prompt.i147, ptr %bounced_32_110_650_1428_6047_pointer_771, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_771.repack22 = getelementptr i8, ptr %common.ret.op.i179, i64 80
  store i64 %offset.i, ptr %bounced_32_110_650_1428_6047_pointer_771.repack22, align 8, !noalias !0
  %returnAddress_pointer_772 = getelementptr i8, ptr %common.ret.op.i179, i64 88
  %sharer_pointer_773 = getelementptr i8, ptr %common.ret.op.i179, i64 96
  %eraser_pointer_774 = getelementptr i8, ptr %common.ret.op.i179, i64 104
  store ptr @returnAddress_515, ptr %returnAddress_pointer_772, align 8, !noalias !0
  store ptr @sharer_743, ptr %sharer_pointer_773, align 8, !noalias !0
  store ptr @eraser_757, ptr %eraser_pointer_774, align 8, !noalias !0
  br i1 %z.i171, label %label_815, label %label_782

label_782:                                        ; preds = %stackAllocate.exit194
  br i1 %isNull.i.i85, label %erasePositive.exit122, label %next.i.i113

next.i.i113:                                      ; preds = %label_782
  %referenceCount.i.i114 = load i64, ptr %tmp_8325.unpack5, align 4
  %cond.i.i115 = icmp eq i64 %referenceCount.i.i114, 0
  br i1 %cond.i.i115, label %free.i.i118, label %decr.i.i116

decr.i.i116:                                      ; preds = %next.i.i113
  %referenceCount.1.i.i117 = add i64 %referenceCount.i.i114, -1
  store i64 %referenceCount.1.i.i117, ptr %tmp_8325.unpack5, align 4
  br label %erasePositive.exit122

free.i.i118:                                      ; preds = %next.i.i113
  %objectEraser.i.i119 = getelementptr i8, ptr %tmp_8325.unpack5, i64 8
  %eraser.i.i120 = load ptr, ptr %objectEraser.i.i119, align 8
  %environment.i.i.i121 = getelementptr i8, ptr %tmp_8325.unpack5, i64 16
  tail call void %eraser.i.i120(ptr %environment.i.i.i121)
  tail call void @free(ptr nonnull %tmp_8325.unpack5)
  br label %erasePositive.exit122

erasePositive.exit122:                            ; preds = %label_782, %decr.i.i116, %free.i.i118
  br i1 %isNull.i.i75, label %erasePositive.exit110, label %next.i.i101

next.i.i101:                                      ; preds = %erasePositive.exit122
  %referenceCount.i.i102 = load i64, ptr %tmp_8340.unpack11, align 4
  %cond.i.i103 = icmp eq i64 %referenceCount.i.i102, 0
  br i1 %cond.i.i103, label %free.i.i106, label %decr.i.i104

decr.i.i104:                                      ; preds = %next.i.i101
  %referenceCount.1.i.i105 = add i64 %referenceCount.i.i102, -1
  store i64 %referenceCount.1.i.i105, ptr %tmp_8340.unpack11, align 4
  br label %erasePositive.exit110

free.i.i106:                                      ; preds = %next.i.i101
  %objectEraser.i.i107 = getelementptr i8, ptr %tmp_8340.unpack11, i64 8
  %eraser.i.i108 = load ptr, ptr %objectEraser.i.i107, align 8
  %environment.i.i.i109 = getelementptr i8, ptr %tmp_8340.unpack11, i64 16
  tail call void %eraser.i.i108(ptr %environment.i.i.i109)
  tail call void @free(ptr nonnull %tmp_8340.unpack11)
  br label %erasePositive.exit110

erasePositive.exit110:                            ; preds = %erasePositive.exit122, %decr.i.i104, %free.i.i106
  %stackPointer.i196 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i198 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i196, %limit.i198
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i199 = getelementptr i8, ptr %stackPointer.i196, i64 -24
  store ptr %newStackPointer.i199, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_779 = load ptr, ptr %newStackPointer.i199, align 8, !noalias !0
  musttail call tailcc void %returnAddress_779(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_810:                                        ; preds = %stackAllocate.exit242
  musttail call tailcc void %returnAddress_811(double %z.i216, ptr nonnull %stack)
  ret void

label_814:                                        ; preds = %stackAllocate.exit242
  musttail call tailcc void %returnAddress_811(double %d.i215, ptr nonnull %stack)
  ret void

label_815:                                        ; preds = %stackAllocate.exit194
  %z.i212 = tail call %Pos @c_ref_set(%Pos %tmp_83256, %Pos { i64 4647503709213818880, ptr null })
  %object.i = extractvalue %Pos %z.i212, 1
  %isNull.i.i95 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i95, label %erasePositive.exit, label %next.i.i96

next.i.i96:                                       ; preds = %label_815
  %referenceCount.i.i97 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i97, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i96
  %referenceCount.1.i.i98 = add i64 %referenceCount.i.i97, -1
  store i64 %referenceCount.1.i.i98, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i96
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_815, %decr.i.i, %free.i.i
  br i1 %isNull.i.i75, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %tmp_8340.unpack11, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8340.unpack11, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %z.i213 = tail call %Pos @c_ref_get(%Pos %tmp_834012)
  %unboxed.i214 = extractvalue %Pos %z.i213, 0
  %d.i215 = bitcast i64 %unboxed.i214 to double
  %z.i216 = fsub double 0.000000e+00, %d.i215
  %z.i217 = fcmp olt double %z.i216, %d.i215
  %currentStackPointer.i222 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i223 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i224 = getelementptr i8, ptr %currentStackPointer.i222, i64 56
  %isInside.not.i225 = icmp ugt ptr %nextStackPointer.i224, %limit.i223
  br i1 %isInside.not.i225, label %realloc.i228, label %stackAllocate.exit242

realloc.i228:                                     ; preds = %sharePositive.exit
  %base.i230 = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i231 = ptrtoint ptr %currentStackPointer.i222 to i64
  %intBase.i232 = ptrtoint ptr %base.i230 to i64
  %size.i233 = sub i64 %intStackPointer.i231, %intBase.i232
  %nextSize.i234 = add i64 %size.i233, 56
  %leadingZeros.i.i235 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i234, i1 false)
  %numBits.i.i236 = sub nuw nsw i64 64, %leadingZeros.i.i235
  %result.i.i237 = shl nuw i64 1, %numBits.i.i236
  %newBase.i238 = tail call ptr @realloc(ptr %base.i230, i64 %result.i.i237)
  %newLimit.i239 = getelementptr i8, ptr %newBase.i238, i64 %result.i.i237
  %newStackPointer.i240 = getelementptr i8, ptr %newBase.i238, i64 %size.i233
  %newNextStackPointer.i241 = getelementptr i8, ptr %newStackPointer.i240, i64 56
  store ptr %newBase.i238, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i239, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit242

stackAllocate.exit242:                            ; preds = %sharePositive.exit, %realloc.i228
  %limit.i209 = phi ptr [ %newLimit.i239, %realloc.i228 ], [ %limit.i223, %sharePositive.exit ]
  %nextStackPointer.sink.i226 = phi ptr [ %newNextStackPointer.i241, %realloc.i228 ], [ %nextStackPointer.i224, %sharePositive.exit ]
  %common.ret.op.i227 = phi ptr [ %newStackPointer.i240, %realloc.i228 ], [ %currentStackPointer.i222, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i226, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8340.unpack, ptr %common.ret.op.i227, align 8, !noalias !0
  %stackPointer_798.repack24 = getelementptr inbounds i8, ptr %common.ret.op.i227, i64 8
  store ptr %tmp_8340.unpack11, ptr %stackPointer_798.repack24, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_800 = getelementptr i8, ptr %common.ret.op.i227, i64 16
  store ptr %prompt.i147, ptr %bounced_32_110_650_1428_6047_pointer_800, align 8, !noalias !0
  %bounced_32_110_650_1428_6047_pointer_800.repack27 = getelementptr i8, ptr %common.ret.op.i227, i64 24
  store i64 %offset.i, ptr %bounced_32_110_650_1428_6047_pointer_800.repack27, align 8, !noalias !0
  %returnAddress_pointer_801 = getelementptr i8, ptr %common.ret.op.i227, i64 32
  %sharer_pointer_802 = getelementptr i8, ptr %common.ret.op.i227, i64 40
  %eraser_pointer_803 = getelementptr i8, ptr %common.ret.op.i227, i64 48
  store ptr @returnAddress_783, ptr %returnAddress_pointer_801, align 8, !noalias !0
  store ptr @sharer_576, ptr %sharer_pointer_802, align 8, !noalias !0
  store ptr @eraser_582, ptr %eraser_pointer_803, align 8, !noalias !0
  %isInside.i210 = icmp ule ptr %nextStackPointer.sink.i226, %limit.i209
  tail call void @llvm.assume(i1 %isInside.i210)
  %newStackPointer.i211 = getelementptr i8, ptr %nextStackPointer.sink.i226, i64 -24
  store ptr %newStackPointer.i211, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_811 = load ptr, ptr %newStackPointer.i211, align 8, !noalias !0
  br i1 %z.i217, label %label_814, label %label_810
}

define void @eraser_823(ptr nocapture readonly %environment) {
entry:
  %tmp_8332_819.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_8332_819.unpack2 = load ptr, ptr %tmp_8332_819.elt1, align 8, !noalias !0
  %tmp_8325_820.elt4 = getelementptr i8, ptr %environment, i64 24
  %tmp_8325_820.unpack5 = load ptr, ptr %tmp_8325_820.elt4, align 8, !noalias !0
  %tmp_8348_821.elt7 = getelementptr i8, ptr %environment, i64 40
  %tmp_8348_821.unpack8 = load ptr, ptr %tmp_8348_821.elt7, align 8, !noalias !0
  %tmp_8340_822.elt10 = getelementptr i8, ptr %environment, i64 56
  %tmp_8340_822.unpack11 = load ptr, ptr %tmp_8340_822.elt10, align 8, !noalias !0
  %isNull.i.i35 = icmp eq ptr %tmp_8332_819.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %entry
  %referenceCount.i.i37 = load i64, ptr %tmp_8332_819.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %tmp_8332_819.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %tmp_8332_819.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %tmp_8332_819.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %tmp_8332_819.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %entry, %decr.i.i39, %free.i.i41
  %isNull.i.i24 = icmp eq ptr %tmp_8325_820.unpack5, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %erasePositive.exit45
  %referenceCount.i.i26 = load i64, ptr %tmp_8325_820.unpack5, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %tmp_8325_820.unpack5, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %tmp_8325_820.unpack5, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %tmp_8325_820.unpack5, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %tmp_8325_820.unpack5)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %erasePositive.exit45, %decr.i.i28, %free.i.i30
  %isNull.i.i13 = icmp eq ptr %tmp_8348_821.unpack8, null
  br i1 %isNull.i.i13, label %erasePositive.exit23, label %next.i.i14

next.i.i14:                                       ; preds = %erasePositive.exit34
  %referenceCount.i.i15 = load i64, ptr %tmp_8348_821.unpack8, align 4
  %cond.i.i16 = icmp eq i64 %referenceCount.i.i15, 0
  br i1 %cond.i.i16, label %free.i.i19, label %decr.i.i17

decr.i.i17:                                       ; preds = %next.i.i14
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i15, -1
  store i64 %referenceCount.1.i.i18, ptr %tmp_8348_821.unpack8, align 4
  br label %erasePositive.exit23

free.i.i19:                                       ; preds = %next.i.i14
  %objectEraser.i.i20 = getelementptr i8, ptr %tmp_8348_821.unpack8, i64 8
  %eraser.i.i21 = load ptr, ptr %objectEraser.i.i20, align 8
  %environment.i.i.i22 = getelementptr i8, ptr %tmp_8348_821.unpack8, i64 16
  tail call void %eraser.i.i21(ptr %environment.i.i.i22)
  tail call void @free(ptr nonnull %tmp_8348_821.unpack8)
  br label %erasePositive.exit23

erasePositive.exit23:                             ; preds = %erasePositive.exit34, %decr.i.i17, %free.i.i19
  %isNull.i.i = icmp eq ptr %tmp_8340_822.unpack11, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit23
  %referenceCount.i.i = load i64, ptr %tmp_8340_822.unpack11, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8340_822.unpack11, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8340_822.unpack11, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8340_822.unpack11, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8340_822.unpack11)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit23, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_479(i64 %v_r_3022_22_21_482_1260_6255, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i34 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i34)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_8455_pointer_482 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_482, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %tmp_8455.unpack, 0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %tmp_84556 = insertvalue %Pos %0, ptr %tmp_8455.unpack5, 1
  %ballCount_3_781_6265_pointer_483 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_483, align 4, !noalias !0
  %seed_5_5892_pointer_484 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_484, align 8, !noalias !0
  %seed_5_5892.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %seed_5_5892.unpack8 = load i64, ptr %seed_5_5892.elt7, align 8, !noalias !0
  %tmp_8340_pointer_485 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_8340.unpack = load i64, ptr %tmp_8340_pointer_485, align 8, !noalias !0
  %tmp_8340.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_8340.unpack11 = load ptr, ptr %tmp_8340.elt10, align 8, !noalias !0
  %tmp_8325_pointer_486 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_486, align 8, !noalias !0
  %tmp_8325.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack14 = load ptr, ptr %tmp_8325.elt13, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_487 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_487, align 4, !noalias !0
  %z.i = srem i64 %v_r_3022_22_21_482_1260_6255, 300
  %z.i35 = add nsw i64 %z.i, -150
  %z.i36 = sitofp i64 %z.i35 to double
  %n.i = bitcast double %z.i36 to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i37 = tail call %Pos @c_ref_fresh(%Pos %boxed2.i)
  %object.i = tail call dereferenceable_or_null(80) ptr @malloc(i64 80)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_823, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %tmp_8332.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_818.repack16 = getelementptr i8, ptr %object.i, i64 24
  store ptr %tmp_8332.unpack2, ptr %environment_818.repack16, align 8, !noalias !0
  %tmp_8325_pointer_829 = getelementptr i8, ptr %object.i, i64 32
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_829, align 8, !noalias !0
  %tmp_8325_pointer_829.repack18 = getelementptr i8, ptr %object.i, i64 40
  store ptr %tmp_8325.unpack14, ptr %tmp_8325_pointer_829.repack18, align 8, !noalias !0
  %tmp_8348_pointer_830 = getelementptr i8, ptr %object.i, i64 48
  %pureApp_8538.elt = extractvalue %Pos %z.i37, 0
  store i64 %pureApp_8538.elt, ptr %tmp_8348_pointer_830, align 8, !noalias !0
  %tmp_8348_pointer_830.repack20 = getelementptr i8, ptr %object.i, i64 56
  %pureApp_8538.elt21 = extractvalue %Pos %z.i37, 1
  store ptr %pureApp_8538.elt21, ptr %tmp_8348_pointer_830.repack20, align 8, !noalias !0
  %tmp_8340_pointer_831 = getelementptr i8, ptr %object.i, i64 64
  store i64 %tmp_8340.unpack, ptr %tmp_8340_pointer_831, align 8, !noalias !0
  %tmp_8340_pointer_831.repack22 = getelementptr i8, ptr %object.i, i64 72
  store ptr %tmp_8340.unpack11, ptr %tmp_8340_pointer_831.repack22, align 8, !noalias !0
  %pos_result_with_heap.i = insertvalue %Pos { i64 ptrtoint (ptr @vtable_816 to i64), ptr undef }, ptr %object.i, 1
  %isNull.i.i = icmp eq ptr %tmp_8455.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %z.i38 = tail call %Pos @c_array_set(%Pos %tmp_84556, i64 %i_6_12_461_1239_6395, %Pos %pos_result_with_heap.i)
  %object.i25 = extractvalue %Pos %z.i38, 1
  %isNull.i.i26 = icmp eq ptr %object.i25, null
  br i1 %isNull.i.i26, label %erasePositive.exit, label %next.i.i27

next.i.i27:                                       ; preds = %sharePositive.exit
  %referenceCount.i.i28 = load i64, ptr %object.i25, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i28, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i27
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i28, -1
  store i64 %referenceCount.1.i.i29, ptr %object.i25, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i27
  %objectEraser.i.i = getelementptr i8, ptr %object.i25, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i25, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i25)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %1 = insertvalue %Reference poison, ptr %seed_5_5892.unpack, 0
  %seed_5_58929 = insertvalue %Reference %1, i64 %seed_5_5892.unpack8, 1
  %z.i39 = add i64 %i_6_12_461_1239_6395, 1
  musttail call tailcc void @loop_5_11_460_1238_6021(i64 %z.i39, %Pos %tmp_84556, i64 %ballCount_3_781_6265, %Reference %seed_5_58929, ptr nonnull %stack)
  ret void
}

define void @sharer_840(ptr %stackPointer) {
entry:
  %tmp_8332_833.elt1 = getelementptr i8, ptr %stackPointer, i64 -88
  %tmp_8332_833.unpack2 = load ptr, ptr %tmp_8332_833.elt1, align 8, !noalias !0
  %tmp_8455_834.elt4 = getelementptr i8, ptr %stackPointer, i64 -72
  %tmp_8455_834.unpack5 = load ptr, ptr %tmp_8455_834.elt4, align 8, !noalias !0
  %tmp_8340_837.elt7 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_8340_837.unpack8 = load ptr, ptr %tmp_8340_837.elt7, align 8, !noalias !0
  %tmp_8325_838.elt10 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8325_838.unpack11 = load ptr, ptr %tmp_8325_838.elt10, align 8, !noalias !0
  %isNull.i.i23 = icmp eq ptr %tmp_8332_833.unpack2, null
  br i1 %isNull.i.i23, label %sharePositive.exit27, label %next.i.i24

next.i.i24:                                       ; preds = %entry
  %referenceCount.i.i25 = load i64, ptr %tmp_8332_833.unpack2, align 4
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i25, 1
  store i64 %referenceCount.1.i.i26, ptr %tmp_8332_833.unpack2, align 4
  br label %sharePositive.exit27

sharePositive.exit27:                             ; preds = %entry, %next.i.i24
  %isNull.i.i18 = icmp eq ptr %tmp_8455_834.unpack5, null
  br i1 %isNull.i.i18, label %sharePositive.exit22, label %next.i.i19

next.i.i19:                                       ; preds = %sharePositive.exit27
  %referenceCount.i.i20 = load i64, ptr %tmp_8455_834.unpack5, align 4
  %referenceCount.1.i.i21 = add i64 %referenceCount.i.i20, 1
  store i64 %referenceCount.1.i.i21, ptr %tmp_8455_834.unpack5, align 4
  br label %sharePositive.exit22

sharePositive.exit22:                             ; preds = %sharePositive.exit27, %next.i.i19
  %isNull.i.i13 = icmp eq ptr %tmp_8340_837.unpack8, null
  br i1 %isNull.i.i13, label %sharePositive.exit17, label %next.i.i14

next.i.i14:                                       ; preds = %sharePositive.exit22
  %referenceCount.i.i15 = load i64, ptr %tmp_8340_837.unpack8, align 4
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i15, 1
  store i64 %referenceCount.1.i.i16, ptr %tmp_8340_837.unpack8, align 4
  br label %sharePositive.exit17

sharePositive.exit17:                             ; preds = %sharePositive.exit22, %next.i.i14
  %isNull.i.i = icmp eq ptr %tmp_8325_838.unpack11, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit17
  %referenceCount.i.i = load i64, ptr %tmp_8325_838.unpack11, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8325_838.unpack11, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit17, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -120
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_856(ptr %stackPointer) {
entry:
  %tmp_8332_849.elt1 = getelementptr i8, ptr %stackPointer, i64 -88
  %tmp_8332_849.unpack2 = load ptr, ptr %tmp_8332_849.elt1, align 8, !noalias !0
  %tmp_8455_850.elt4 = getelementptr i8, ptr %stackPointer, i64 -72
  %tmp_8455_850.unpack5 = load ptr, ptr %tmp_8455_850.elt4, align 8, !noalias !0
  %tmp_8340_853.elt7 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_8340_853.unpack8 = load ptr, ptr %tmp_8340_853.elt7, align 8, !noalias !0
  %tmp_8325_854.elt10 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8325_854.unpack11 = load ptr, ptr %tmp_8325_854.elt10, align 8, !noalias !0
  %isNull.i.i35 = icmp eq ptr %tmp_8332_849.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %entry
  %referenceCount.i.i37 = load i64, ptr %tmp_8332_849.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %tmp_8332_849.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %tmp_8332_849.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %tmp_8332_849.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %tmp_8332_849.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %entry, %decr.i.i39, %free.i.i41
  %isNull.i.i24 = icmp eq ptr %tmp_8455_850.unpack5, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %erasePositive.exit45
  %referenceCount.i.i26 = load i64, ptr %tmp_8455_850.unpack5, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %tmp_8455_850.unpack5, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %tmp_8455_850.unpack5, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %tmp_8455_850.unpack5, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %tmp_8455_850.unpack5)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %erasePositive.exit45, %decr.i.i28, %free.i.i30
  %isNull.i.i13 = icmp eq ptr %tmp_8340_853.unpack8, null
  br i1 %isNull.i.i13, label %erasePositive.exit23, label %next.i.i14

next.i.i14:                                       ; preds = %erasePositive.exit34
  %referenceCount.i.i15 = load i64, ptr %tmp_8340_853.unpack8, align 4
  %cond.i.i16 = icmp eq i64 %referenceCount.i.i15, 0
  br i1 %cond.i.i16, label %free.i.i19, label %decr.i.i17

decr.i.i17:                                       ; preds = %next.i.i14
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i15, -1
  store i64 %referenceCount.1.i.i18, ptr %tmp_8340_853.unpack8, align 4
  br label %erasePositive.exit23

free.i.i19:                                       ; preds = %next.i.i14
  %objectEraser.i.i20 = getelementptr i8, ptr %tmp_8340_853.unpack8, i64 8
  %eraser.i.i21 = load ptr, ptr %objectEraser.i.i20, align 8
  %environment.i.i.i22 = getelementptr i8, ptr %tmp_8340_853.unpack8, i64 16
  tail call void %eraser.i.i21(ptr %environment.i.i.i22)
  tail call void @free(ptr nonnull %tmp_8340_853.unpack8)
  br label %erasePositive.exit23

erasePositive.exit23:                             ; preds = %erasePositive.exit34, %decr.i.i17, %free.i.i19
  %isNull.i.i = icmp eq ptr %tmp_8325_854.unpack11, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit23
  %referenceCount.i.i = load i64, ptr %tmp_8325_854.unpack11, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8325_854.unpack11, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8325_854.unpack11, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8325_854.unpack11, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8325_854.unpack11)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit23, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -120
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -104
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_470(%Pos %__11_5_8485, ptr %stack) {
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
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_8455_pointer_473 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_473, align 8, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_474 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_474, align 4, !noalias !0
  %seed_5_5892_pointer_475 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_475, align 8, !noalias !0
  %seed_5_5892.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %seed_5_5892.unpack8 = load i64, ptr %seed_5_5892.elt7, align 8, !noalias !0
  %tmp_8340_pointer_476 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_8340.unpack = load i64, ptr %tmp_8340_pointer_476, align 8, !noalias !0
  %tmp_8340.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_8340.unpack11 = load ptr, ptr %tmp_8340.elt10, align 8, !noalias !0
  %tmp_8325_pointer_477 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_477, align 8, !noalias !0
  %tmp_8325.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack14 = load ptr, ptr %tmp_8325.elt13, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_478 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_478, align 4, !noalias !0
  %object.i = extractvalue %Pos %__11_5_8485, 1
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
  store i64 %tmp_8332.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_865.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_8332.unpack2, ptr %stackPointer_865.repack16, align 8, !noalias !0
  %tmp_8455_pointer_867 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_8455.unpack, ptr %tmp_8455_pointer_867, align 8, !noalias !0
  %tmp_8455_pointer_867.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %tmp_8455.unpack5, ptr %tmp_8455_pointer_867.repack18, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_868 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_868, align 4, !noalias !0
  %seed_5_5892_pointer_869 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_869, align 8, !noalias !0
  %seed_5_5892_pointer_869.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %seed_5_5892.unpack8, ptr %seed_5_5892_pointer_869.repack20, align 8, !noalias !0
  %tmp_8340_pointer_870 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %tmp_8340.unpack, ptr %tmp_8340_pointer_870, align 8, !noalias !0
  %tmp_8340_pointer_870.repack22 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %tmp_8340.unpack11, ptr %tmp_8340_pointer_870.repack22, align 8, !noalias !0
  %tmp_8325_pointer_871 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_871, align 8, !noalias !0
  %tmp_8325_pointer_871.repack24 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %tmp_8325.unpack14, ptr %tmp_8325_pointer_871.repack24, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_872 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_872, align 4, !noalias !0
  %returnAddress_pointer_873 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_874 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_875 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_479, ptr %returnAddress_pointer_873, align 8, !noalias !0
  store ptr @sharer_840, ptr %sharer_pointer_874, align 8, !noalias !0
  store ptr @eraser_856, ptr %eraser_pointer_875, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i35 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i36 = load ptr, ptr %base_pointer.i35, align 8
  %varPointer.i = getelementptr i8, ptr %base.i36, i64 %seed_5_5892.unpack8
  %get_8631 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i41 = icmp ule ptr %nextStackPointer.sink.i, %limit.i40
  tail call void @llvm.assume(i1 %isInside.i41)
  %newStackPointer.i42 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i42, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_878 = load ptr, ptr %newStackPointer.i42, align 8, !noalias !0
  musttail call tailcc void %returnAddress_878(i64 %get_8631, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_461(i64 %v_r_3053_7_1_7290, ptr %stack) {
stackAllocate.exit:
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
  %i_6_12_461_1239_6395_pointer_469 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_469, align 4, !noalias !0
  %tmp_8325.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack14 = load ptr, ptr %tmp_8325.elt13, align 8, !noalias !0
  %tmp_8325_pointer_468 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_468, align 8, !noalias !0
  %tmp_8340.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_8340.unpack11 = load ptr, ptr %tmp_8340.elt10, align 8, !noalias !0
  %tmp_8340_pointer_467 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_8340.unpack = load i64, ptr %tmp_8340_pointer_467, align 8, !noalias !0
  %seed_5_5892.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %seed_5_5892.unpack8 = load i64, ptr %seed_5_5892.elt7, align 8, !noalias !0
  %seed_5_5892_pointer_466 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_466, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_465 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_465, align 4, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %tmp_8455_pointer_464 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_464, align 8, !noalias !0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = mul i64 %v_r_3053_7_1_7290, 1309
  %z.i31 = add i64 %z.i, 13849
  %z.i32 = and i64 %z.i31, 65535
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8332.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_895.repack16 = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %tmp_8332.unpack2, ptr %stackPointer_895.repack16, align 8, !noalias !0
  %tmp_8455_pointer_897 = getelementptr i8, ptr %stackPointer.i, i64 -80
  store i64 %tmp_8455.unpack, ptr %tmp_8455_pointer_897, align 8, !noalias !0
  %tmp_8455_pointer_897.repack18 = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %tmp_8455.unpack5, ptr %tmp_8455_pointer_897.repack18, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_898 = getelementptr i8, ptr %stackPointer.i, i64 -64
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_898, align 4, !noalias !0
  %seed_5_5892_pointer_899 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_899, align 8, !noalias !0
  %seed_5_5892_pointer_899.repack20 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %seed_5_5892.unpack8, ptr %seed_5_5892_pointer_899.repack20, align 8, !noalias !0
  %tmp_8340_pointer_900 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store i64 %tmp_8340.unpack, ptr %tmp_8340_pointer_900, align 8, !noalias !0
  %tmp_8340_pointer_900.repack22 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %tmp_8340.unpack11, ptr %tmp_8340_pointer_900.repack22, align 8, !noalias !0
  %tmp_8325_pointer_901 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_901, align 8, !noalias !0
  %tmp_8325_pointer_901.repack24 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %tmp_8325.unpack14, ptr %tmp_8325_pointer_901.repack24, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_902 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_902, align 4, !noalias !0
  %sharer_pointer_904 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_905 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_470, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_840, ptr %sharer_pointer_904, align 8, !noalias !0
  store ptr @eraser_856, ptr %eraser_pointer_905, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i37 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i38 = load ptr, ptr %base_pointer.i37, align 8
  %varPointer.i = getelementptr i8, ptr %base.i38, i64 %seed_5_5892.unpack8
  store i64 %z.i32, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_909 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_909(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_453(i64 %v_r_3020_15_14_475_1253_6127, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -80
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_8455_pointer_456 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_456, align 8, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_457 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_457, align 4, !noalias !0
  %seed_5_5892_pointer_458 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_458, align 8, !noalias !0
  %seed_5_5892.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_5892.unpack8 = load i64, ptr %seed_5_5892.elt7, align 8, !noalias !0
  %tmp_8325_pointer_459 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_459, align 8, !noalias !0
  %tmp_8325.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack11 = load ptr, ptr %tmp_8325.elt10, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_460 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_460, align 4, !noalias !0
  %z.i = srem i64 %v_r_3020_15_14_475_1253_6127, 300
  %z.i28 = add nsw i64 %z.i, -150
  %z.i29 = sitofp i64 %z.i28 to double
  %n.i = bitcast double %z.i29 to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i30 = tail call %Pos @c_ref_fresh(%Pos %boxed2.i)
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i33 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i33
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
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

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i40 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i33, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i34, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8332.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_926.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_8332.unpack2, ptr %stackPointer_926.repack13, align 8, !noalias !0
  %tmp_8455_pointer_928 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_8455.unpack, ptr %tmp_8455_pointer_928, align 8, !noalias !0
  %tmp_8455_pointer_928.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %tmp_8455.unpack5, ptr %tmp_8455_pointer_928.repack15, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_929 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_929, align 4, !noalias !0
  %seed_5_5892_pointer_930 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_930, align 8, !noalias !0
  %seed_5_5892_pointer_930.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %seed_5_5892.unpack8, ptr %seed_5_5892_pointer_930.repack17, align 8, !noalias !0
  %tmp_8340_pointer_931 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %pureApp_8525.elt = extractvalue %Pos %z.i30, 0
  store i64 %pureApp_8525.elt, ptr %tmp_8340_pointer_931, align 8, !noalias !0
  %tmp_8340_pointer_931.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %pureApp_8525.elt20 = extractvalue %Pos %z.i30, 1
  store ptr %pureApp_8525.elt20, ptr %tmp_8340_pointer_931.repack19, align 8, !noalias !0
  %tmp_8325_pointer_932 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_932, align 8, !noalias !0
  %tmp_8325_pointer_932.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr %tmp_8325.unpack11, ptr %tmp_8325_pointer_932.repack21, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_933 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_933, align 4, !noalias !0
  %returnAddress_pointer_934 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_935 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_936 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_461, ptr %returnAddress_pointer_934, align 8, !noalias !0
  store ptr @sharer_840, ptr %sharer_pointer_935, align 8, !noalias !0
  store ptr @eraser_856, ptr %eraser_pointer_936, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i35 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i36 = load ptr, ptr %base_pointer.i35, align 8
  %varPointer.i = getelementptr i8, ptr %base.i36, i64 %seed_5_5892.unpack8
  %get_8633 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i41 = icmp ule ptr %nextStackPointer.sink.i, %limit.i40
  tail call void @llvm.assume(i1 %isInside.i41)
  %newStackPointer.i42 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i42, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_939 = load ptr, ptr %newStackPointer.i42, align 8, !noalias !0
  musttail call tailcc void %returnAddress_939(i64 %get_8633, ptr nonnull %stack)
  ret void
}

define void @sharer_948(ptr %stackPointer) {
entry:
  %tmp_8332_942.elt1 = getelementptr i8, ptr %stackPointer, i64 -72
  %tmp_8332_942.unpack2 = load ptr, ptr %tmp_8332_942.elt1, align 8, !noalias !0
  %tmp_8455_943.elt4 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_8455_943.unpack5 = load ptr, ptr %tmp_8455_943.elt4, align 8, !noalias !0
  %tmp_8325_946.elt7 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8325_946.unpack8 = load ptr, ptr %tmp_8325_946.elt7, align 8, !noalias !0
  %isNull.i.i15 = icmp eq ptr %tmp_8332_942.unpack2, null
  br i1 %isNull.i.i15, label %sharePositive.exit19, label %next.i.i16

next.i.i16:                                       ; preds = %entry
  %referenceCount.i.i17 = load i64, ptr %tmp_8332_942.unpack2, align 4
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i17, 1
  store i64 %referenceCount.1.i.i18, ptr %tmp_8332_942.unpack2, align 4
  br label %sharePositive.exit19

sharePositive.exit19:                             ; preds = %entry, %next.i.i16
  %isNull.i.i10 = icmp eq ptr %tmp_8455_943.unpack5, null
  br i1 %isNull.i.i10, label %sharePositive.exit14, label %next.i.i11

next.i.i11:                                       ; preds = %sharePositive.exit19
  %referenceCount.i.i12 = load i64, ptr %tmp_8455_943.unpack5, align 4
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i12, 1
  store i64 %referenceCount.1.i.i13, ptr %tmp_8455_943.unpack5, align 4
  br label %sharePositive.exit14

sharePositive.exit14:                             ; preds = %sharePositive.exit19, %next.i.i11
  %isNull.i.i = icmp eq ptr %tmp_8325_946.unpack8, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit14
  %referenceCount.i.i = load i64, ptr %tmp_8325_946.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8325_946.unpack8, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit14, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_962(ptr %stackPointer) {
entry:
  %tmp_8332_956.elt1 = getelementptr i8, ptr %stackPointer, i64 -72
  %tmp_8332_956.unpack2 = load ptr, ptr %tmp_8332_956.elt1, align 8, !noalias !0
  %tmp_8455_957.elt4 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_8455_957.unpack5 = load ptr, ptr %tmp_8455_957.elt4, align 8, !noalias !0
  %tmp_8325_960.elt7 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8325_960.unpack8 = load ptr, ptr %tmp_8325_960.elt7, align 8, !noalias !0
  %isNull.i.i21 = icmp eq ptr %tmp_8332_956.unpack2, null
  br i1 %isNull.i.i21, label %erasePositive.exit31, label %next.i.i22

next.i.i22:                                       ; preds = %entry
  %referenceCount.i.i23 = load i64, ptr %tmp_8332_956.unpack2, align 4
  %cond.i.i24 = icmp eq i64 %referenceCount.i.i23, 0
  br i1 %cond.i.i24, label %free.i.i27, label %decr.i.i25

decr.i.i25:                                       ; preds = %next.i.i22
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i23, -1
  store i64 %referenceCount.1.i.i26, ptr %tmp_8332_956.unpack2, align 4
  br label %erasePositive.exit31

free.i.i27:                                       ; preds = %next.i.i22
  %objectEraser.i.i28 = getelementptr i8, ptr %tmp_8332_956.unpack2, i64 8
  %eraser.i.i29 = load ptr, ptr %objectEraser.i.i28, align 8
  %environment.i.i.i30 = getelementptr i8, ptr %tmp_8332_956.unpack2, i64 16
  tail call void %eraser.i.i29(ptr %environment.i.i.i30)
  tail call void @free(ptr nonnull %tmp_8332_956.unpack2)
  br label %erasePositive.exit31

erasePositive.exit31:                             ; preds = %entry, %decr.i.i25, %free.i.i27
  %isNull.i.i10 = icmp eq ptr %tmp_8455_957.unpack5, null
  br i1 %isNull.i.i10, label %erasePositive.exit20, label %next.i.i11

next.i.i11:                                       ; preds = %erasePositive.exit31
  %referenceCount.i.i12 = load i64, ptr %tmp_8455_957.unpack5, align 4
  %cond.i.i13 = icmp eq i64 %referenceCount.i.i12, 0
  br i1 %cond.i.i13, label %free.i.i16, label %decr.i.i14

decr.i.i14:                                       ; preds = %next.i.i11
  %referenceCount.1.i.i15 = add i64 %referenceCount.i.i12, -1
  store i64 %referenceCount.1.i.i15, ptr %tmp_8455_957.unpack5, align 4
  br label %erasePositive.exit20

free.i.i16:                                       ; preds = %next.i.i11
  %objectEraser.i.i17 = getelementptr i8, ptr %tmp_8455_957.unpack5, i64 8
  %eraser.i.i18 = load ptr, ptr %objectEraser.i.i17, align 8
  %environment.i.i.i19 = getelementptr i8, ptr %tmp_8455_957.unpack5, i64 16
  tail call void %eraser.i.i18(ptr %environment.i.i.i19)
  tail call void @free(ptr nonnull %tmp_8455_957.unpack5)
  br label %erasePositive.exit20

erasePositive.exit20:                             ; preds = %erasePositive.exit31, %decr.i.i14, %free.i.i16
  %isNull.i.i = icmp eq ptr %tmp_8325_960.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit20
  %referenceCount.i.i = load i64, ptr %tmp_8325_960.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8325_960.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8325_960.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8325_960.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8325_960.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit20, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -88
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_445(%Pos %__11_5_8486, ptr %stack) {
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
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_8455_pointer_448 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_448, align 8, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_449 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_449, align 4, !noalias !0
  %seed_5_5892_pointer_450 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_450, align 8, !noalias !0
  %seed_5_5892.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_5892.unpack8 = load i64, ptr %seed_5_5892.elt7, align 8, !noalias !0
  %tmp_8325_pointer_451 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_451, align 8, !noalias !0
  %tmp_8325.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack11 = load ptr, ptr %tmp_8325.elt10, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_452 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_452, align 4, !noalias !0
  %object.i = extractvalue %Pos %__11_5_8486, 1
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
  store i64 %tmp_8332.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_970.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_8332.unpack2, ptr %stackPointer_970.repack13, align 8, !noalias !0
  %tmp_8455_pointer_972 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_8455.unpack, ptr %tmp_8455_pointer_972, align 8, !noalias !0
  %tmp_8455_pointer_972.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %tmp_8455.unpack5, ptr %tmp_8455_pointer_972.repack15, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_973 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_973, align 4, !noalias !0
  %seed_5_5892_pointer_974 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_974, align 8, !noalias !0
  %seed_5_5892_pointer_974.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %seed_5_5892.unpack8, ptr %seed_5_5892_pointer_974.repack17, align 8, !noalias !0
  %tmp_8325_pointer_975 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_975, align 8, !noalias !0
  %tmp_8325_pointer_975.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %tmp_8325.unpack11, ptr %tmp_8325_pointer_975.repack19, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_976 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_976, align 4, !noalias !0
  %returnAddress_pointer_977 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %sharer_pointer_978 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %eraser_pointer_979 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr @returnAddress_453, ptr %returnAddress_pointer_977, align 8, !noalias !0
  store ptr @sharer_948, ptr %sharer_pointer_978, align 8, !noalias !0
  store ptr @eraser_962, ptr %eraser_pointer_979, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i30 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i31 = load ptr, ptr %base_pointer.i30, align 8
  %varPointer.i = getelementptr i8, ptr %base.i31, i64 %seed_5_5892.unpack8
  %get_8634 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i36 = icmp ule ptr %nextStackPointer.sink.i, %limit.i35
  tail call void @llvm.assume(i1 %isInside.i36)
  %newStackPointer.i37 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i37, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_982 = load ptr, ptr %newStackPointer.i37, align 8, !noalias !0
  musttail call tailcc void %returnAddress_982(i64 %get_8634, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_437(i64 %v_r_3053_7_1_7286, ptr %stack) {
stackAllocate.exit:
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
  %i_6_12_461_1239_6395_pointer_444 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_444, align 4, !noalias !0
  %tmp_8325.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack11 = load ptr, ptr %tmp_8325.elt10, align 8, !noalias !0
  %tmp_8325_pointer_443 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_443, align 8, !noalias !0
  %seed_5_5892.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_5892.unpack8 = load i64, ptr %seed_5_5892.elt7, align 8, !noalias !0
  %seed_5_5892_pointer_442 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_442, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_441 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_441, align 4, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %tmp_8455_pointer_440 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_440, align 8, !noalias !0
  %tmp_8332.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_8332.unpack2 = load ptr, ptr %tmp_8332.elt1, align 8, !noalias !0
  %tmp_8332.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = mul i64 %v_r_3053_7_1_7286, 1309
  %z.i26 = add i64 %z.i, 13849
  %z.i27 = and i64 %z.i26, 65535
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8332.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_997.repack13 = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %tmp_8332.unpack2, ptr %stackPointer_997.repack13, align 8, !noalias !0
  %tmp_8455_pointer_999 = getelementptr i8, ptr %stackPointer.i, i64 -64
  store i64 %tmp_8455.unpack, ptr %tmp_8455_pointer_999, align 8, !noalias !0
  %tmp_8455_pointer_999.repack15 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %tmp_8455.unpack5, ptr %tmp_8455_pointer_999.repack15, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1000 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1000, align 4, !noalias !0
  %seed_5_5892_pointer_1001 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_1001, align 8, !noalias !0
  %seed_5_5892_pointer_1001.repack17 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store i64 %seed_5_5892.unpack8, ptr %seed_5_5892_pointer_1001.repack17, align 8, !noalias !0
  %tmp_8325_pointer_1002 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_1002, align 8, !noalias !0
  %tmp_8325_pointer_1002.repack19 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %tmp_8325.unpack11, ptr %tmp_8325_pointer_1002.repack19, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_1003 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1003, align 4, !noalias !0
  %sharer_pointer_1005 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1006 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_445, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_948, ptr %sharer_pointer_1005, align 8, !noalias !0
  store ptr @eraser_962, ptr %eraser_pointer_1006, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i32 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i33 = load ptr, ptr %base_pointer.i32, align 8
  %varPointer.i = getelementptr i8, ptr %base.i33, i64 %seed_5_5892.unpack8
  store i64 %z.i27, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1010 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1010(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_430(i64 %v_r_3018_9_8_469_1247_6492, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i22 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i22)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8455.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8455.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_8455.unpack2 = load ptr, ptr %tmp_8455.elt1, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_433 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_433, align 4, !noalias !0
  %seed_5_5892_pointer_434 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_434, align 8, !noalias !0
  %seed_5_5892.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_5892.unpack5 = load i64, ptr %seed_5_5892.elt4, align 8, !noalias !0
  %tmp_8325_pointer_435 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_435, align 8, !noalias !0
  %tmp_8325.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack8 = load ptr, ptr %tmp_8325.elt7, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_436 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_436, align 4, !noalias !0
  %z.i = srem i64 %v_r_3018_9_8_469_1247_6492, 500
  %z.i23 = sitofp i64 %z.i to double
  %n.i = bitcast double %z.i23 to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i24 = tail call %Pos @c_ref_fresh(%Pos %boxed2.i)
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 104
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i27
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
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
  %newStackPointer.i28 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i28, i64 104
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i34 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i27, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i28, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %pureApp_8512.elt = extractvalue %Pos %z.i24, 0
  store i64 %pureApp_8512.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1025.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %pureApp_8512.elt11 = extractvalue %Pos %z.i24, 1
  store ptr %pureApp_8512.elt11, ptr %stackPointer_1025.repack10, align 8, !noalias !0
  %tmp_8455_pointer_1027 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %tmp_8455.unpack, ptr %tmp_8455_pointer_1027, align 8, !noalias !0
  %tmp_8455_pointer_1027.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %tmp_8455.unpack2, ptr %tmp_8455_pointer_1027.repack12, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1028 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1028, align 4, !noalias !0
  %seed_5_5892_pointer_1029 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_1029, align 8, !noalias !0
  %seed_5_5892_pointer_1029.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %seed_5_5892.unpack5, ptr %seed_5_5892_pointer_1029.repack14, align 8, !noalias !0
  %tmp_8325_pointer_1030 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_1030, align 8, !noalias !0
  %tmp_8325_pointer_1030.repack16 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %tmp_8325.unpack8, ptr %tmp_8325_pointer_1030.repack16, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_1031 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1031, align 4, !noalias !0
  %returnAddress_pointer_1032 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %sharer_pointer_1033 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %eraser_pointer_1034 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr @returnAddress_437, ptr %returnAddress_pointer_1032, align 8, !noalias !0
  store ptr @sharer_948, ptr %sharer_pointer_1033, align 8, !noalias !0
  store ptr @eraser_962, ptr %eraser_pointer_1034, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i29 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i30 = load ptr, ptr %base_pointer.i29, align 8
  %varPointer.i = getelementptr i8, ptr %base.i30, i64 %seed_5_5892.unpack5
  %get_8636 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i35 = icmp ule ptr %nextStackPointer.sink.i, %limit.i34
  tail call void @llvm.assume(i1 %isInside.i35)
  %newStackPointer.i36 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i36, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1037 = load ptr, ptr %newStackPointer.i36, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1037(i64 %get_8636, ptr nonnull %stack)
  ret void
}

define void @sharer_1045(ptr %stackPointer) {
entry:
  %tmp_8455_1040.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_8455_1040.unpack2 = load ptr, ptr %tmp_8455_1040.elt1, align 8, !noalias !0
  %tmp_8325_1043.elt4 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8325_1043.unpack5 = load ptr, ptr %tmp_8325_1043.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_8455_1040.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_8455_1040.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %tmp_8455_1040.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %tmp_8325_1043.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %tmp_8325_1043.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8325_1043.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1057(ptr %stackPointer) {
entry:
  %tmp_8455_1052.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %tmp_8455_1052.unpack2 = load ptr, ptr %tmp_8455_1052.elt1, align 8, !noalias !0
  %tmp_8325_1055.elt4 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8325_1055.unpack5 = load ptr, ptr %tmp_8325_1055.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_8455_1052.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_8455_1052.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_8455_1052.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_8455_1052.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_8455_1052.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_8455_1052.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %tmp_8325_1055.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %tmp_8325_1055.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8325_1055.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8325_1055.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8325_1055.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8325_1055.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_423(%Pos %__11_5_8487, ptr %stack) {
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
  %tmp_8455.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8455.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_8455.unpack2 = load ptr, ptr %tmp_8455.elt1, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_426 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_426, align 4, !noalias !0
  %seed_5_5892_pointer_427 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_427, align 8, !noalias !0
  %seed_5_5892.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_5892.unpack5 = load i64, ptr %seed_5_5892.elt4, align 8, !noalias !0
  %tmp_8325_pointer_428 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_428, align 8, !noalias !0
  %tmp_8325.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack8 = load ptr, ptr %tmp_8325.elt7, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_429 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_429, align 4, !noalias !0
  %object.i = extractvalue %Pos %__11_5_8487, 1
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
  store i64 %tmp_8455.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1064.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_8455.unpack2, ptr %stackPointer_1064.repack10, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1066 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1066, align 4, !noalias !0
  %seed_5_5892_pointer_1067 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_1067, align 8, !noalias !0
  %seed_5_5892_pointer_1067.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %seed_5_5892.unpack5, ptr %seed_5_5892_pointer_1067.repack12, align 8, !noalias !0
  %tmp_8325_pointer_1068 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_1068, align 8, !noalias !0
  %tmp_8325_pointer_1068.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %tmp_8325.unpack8, ptr %tmp_8325_pointer_1068.repack14, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_1069 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1069, align 4, !noalias !0
  %returnAddress_pointer_1070 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_1071 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_1072 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_430, ptr %returnAddress_pointer_1070, align 8, !noalias !0
  store ptr @sharer_1045, ptr %sharer_pointer_1071, align 8, !noalias !0
  store ptr @eraser_1057, ptr %eraser_pointer_1072, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i25 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8
  %varPointer.i = getelementptr i8, ptr %base.i26, i64 %seed_5_5892.unpack5
  %get_8637 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i31 = icmp ule ptr %nextStackPointer.sink.i, %limit.i30
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i32 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i32, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1075 = load ptr, ptr %newStackPointer.i32, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1075(i64 %get_8637, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_416(i64 %v_r_3053_7_1_7282, ptr %stack) {
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
  %i_6_12_461_1239_6395_pointer_422 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_422, align 4, !noalias !0
  %tmp_8325.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8325.unpack8 = load ptr, ptr %tmp_8325.elt7, align 8, !noalias !0
  %tmp_8325_pointer_421 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8325.unpack = load i64, ptr %tmp_8325_pointer_421, align 8, !noalias !0
  %seed_5_5892.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_5892.unpack5 = load i64, ptr %seed_5_5892.elt4, align 8, !noalias !0
  %seed_5_5892_pointer_420 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_420, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_419 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_419, align 4, !noalias !0
  %tmp_8455.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_8455.unpack2 = load ptr, ptr %tmp_8455.elt1, align 8, !noalias !0
  %tmp_8455.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = mul i64 %v_r_3053_7_1_7282, 1309
  %z.i21 = add i64 %z.i, 13849
  %z.i22 = and i64 %z.i21, 65535
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8455.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_1088.repack10 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %tmp_8455.unpack2, ptr %stackPointer_1088.repack10, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1090 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1090, align 4, !noalias !0
  %seed_5_5892_pointer_1091 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_1091, align 8, !noalias !0
  %seed_5_5892_pointer_1091.repack12 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store i64 %seed_5_5892.unpack5, ptr %seed_5_5892_pointer_1091.repack12, align 8, !noalias !0
  %tmp_8325_pointer_1092 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %tmp_8325.unpack, ptr %tmp_8325_pointer_1092, align 8, !noalias !0
  %tmp_8325_pointer_1092.repack14 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %tmp_8325.unpack8, ptr %tmp_8325_pointer_1092.repack14, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_1093 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1093, align 4, !noalias !0
  %sharer_pointer_1095 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1096 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_423, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1045, ptr %sharer_pointer_1095, align 8, !noalias !0
  store ptr @eraser_1057, ptr %eraser_pointer_1096, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i27 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i28 = load ptr, ptr %base_pointer.i27, align 8
  %varPointer.i = getelementptr i8, ptr %base.i28, i64 %seed_5_5892.unpack5
  store i64 %z.i22, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1100 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1100(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_410(i64 %v_r_3015_3_2_463_1241_6495, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8455.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8455.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_8455.unpack2 = load ptr, ptr %tmp_8455.elt1, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_413 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_413, align 4, !noalias !0
  %i_6_12_461_1239_6395_pointer_414 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_414, align 4, !noalias !0
  %seed_5_5892_pointer_415 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_415, align 8, !noalias !0
  %seed_5_5892.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %seed_5_5892.unpack5 = load i64, ptr %seed_5_5892.elt4, align 8, !noalias !0
  %z.i = srem i64 %v_r_3015_3_2_463_1241_6495, 500
  %z.i18 = sitofp i64 %z.i to double
  %n.i = bitcast double %z.i18 to i64
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %n.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i19 = tail call %Pos @c_ref_fresh(%Pos %boxed2.i)
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i22
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
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
  %newStackPointer.i23 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i23, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i29 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i22, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i23, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8455.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1113.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_8455.unpack2, ptr %stackPointer_1113.repack7, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1115 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1115, align 4, !noalias !0
  %seed_5_5892_pointer_1116 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_1116, align 8, !noalias !0
  %seed_5_5892_pointer_1116.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %seed_5_5892.unpack5, ptr %seed_5_5892_pointer_1116.repack9, align 8, !noalias !0
  %tmp_8325_pointer_1117 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %pureApp_8501.elt = extractvalue %Pos %z.i19, 0
  store i64 %pureApp_8501.elt, ptr %tmp_8325_pointer_1117, align 8, !noalias !0
  %tmp_8325_pointer_1117.repack11 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %pureApp_8501.elt12 = extractvalue %Pos %z.i19, 1
  store ptr %pureApp_8501.elt12, ptr %tmp_8325_pointer_1117.repack11, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_1118 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1118, align 4, !noalias !0
  %returnAddress_pointer_1119 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_1120 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_1121 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_416, ptr %returnAddress_pointer_1119, align 8, !noalias !0
  store ptr @sharer_1045, ptr %sharer_pointer_1120, align 8, !noalias !0
  store ptr @eraser_1057, ptr %eraser_pointer_1121, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i24 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i25 = load ptr, ptr %base_pointer.i24, align 8
  %varPointer.i = getelementptr i8, ptr %base.i25, i64 %seed_5_5892.unpack5
  %get_8639 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i30 = icmp ule ptr %nextStackPointer.sink.i, %limit.i29
  tail call void @llvm.assume(i1 %isInside.i30)
  %newStackPointer.i31 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i31, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1124 = load ptr, ptr %newStackPointer.i31, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1124(i64 %get_8639, ptr nonnull %stack)
  ret void
}

define void @sharer_1131(ptr %stackPointer) {
entry:
  %tmp_8455_1127.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %tmp_8455_1127.unpack2 = load ptr, ptr %tmp_8455_1127.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8455_1127.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455_1127.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455_1127.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1141(ptr %stackPointer) {
entry:
  %tmp_8455_1137.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %tmp_8455_1137.unpack2 = load ptr, ptr %tmp_8455_1137.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8455_1137.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455_1137.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455_1137.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8455_1137.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8455_1137.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8455_1137.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_404(%Pos %__11_5_8488, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_8455.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_8455.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_8455.unpack2 = load ptr, ptr %tmp_8455.elt1, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_407 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_407, align 4, !noalias !0
  %i_6_12_461_1239_6395_pointer_408 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_408, align 4, !noalias !0
  %seed_5_5892_pointer_409 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_409, align 8, !noalias !0
  %seed_5_5892.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %seed_5_5892.unpack5 = load i64, ptr %seed_5_5892.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %__11_5_8488, 1
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
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i18
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
  %newStackPointer.i19 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i19, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i25 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i18, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i19, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8455.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1147.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_8455.unpack2, ptr %stackPointer_1147.repack7, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1149 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1149, align 4, !noalias !0
  %i_6_12_461_1239_6395_pointer_1150 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1150, align 4, !noalias !0
  %seed_5_5892_pointer_1151 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_1151, align 8, !noalias !0
  %seed_5_5892_pointer_1151.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %seed_5_5892.unpack5, ptr %seed_5_5892_pointer_1151.repack9, align 8, !noalias !0
  %returnAddress_pointer_1152 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1153 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1154 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_410, ptr %returnAddress_pointer_1152, align 8, !noalias !0
  store ptr @sharer_1131, ptr %sharer_pointer_1153, align 8, !noalias !0
  store ptr @eraser_1141, ptr %eraser_pointer_1154, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %seed_5_5892.unpack5
  %get_8640 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i26 = icmp ule ptr %nextStackPointer.sink.i, %limit.i25
  tail call void @llvm.assume(i1 %isInside.i26)
  %newStackPointer.i27 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i27, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1157 = load ptr, ptr %newStackPointer.i27, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1157(i64 %get_8640, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_398(i64 %v_r_3053_7_1_7278, ptr %stack) {
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
  %seed_5_5892.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %seed_5_5892.unpack5 = load i64, ptr %seed_5_5892.elt4, align 8, !noalias !0
  %seed_5_5892_pointer_403 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %seed_5_5892.unpack = load ptr, ptr %seed_5_5892_pointer_403, align 8, !noalias !0
  %i_6_12_461_1239_6395_pointer_402 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_6_12_461_1239_6395 = load i64, ptr %i_6_12_461_1239_6395_pointer_402, align 4, !noalias !0
  %ballCount_3_781_6265_pointer_401 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_401, align 4, !noalias !0
  %tmp_8455.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %tmp_8455.unpack2 = load ptr, ptr %tmp_8455.elt1, align 8, !noalias !0
  %tmp_8455.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = mul i64 %v_r_3053_7_1_7278, 1309
  %z.i16 = add i64 %z.i, 13849
  %z.i17 = and i64 %z.i16, 65535
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_8455.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_1168.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %tmp_8455.unpack2, ptr %stackPointer_1168.repack7, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1170 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1170, align 4, !noalias !0
  %i_6_12_461_1239_6395_pointer_1171 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1171, align 4, !noalias !0
  %seed_5_5892_pointer_1172 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %seed_5_5892.unpack, ptr %seed_5_5892_pointer_1172, align 8, !noalias !0
  %seed_5_5892_pointer_1172.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %seed_5_5892.unpack5, ptr %seed_5_5892_pointer_1172.repack9, align 8, !noalias !0
  %sharer_pointer_1174 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1175 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_404, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1131, ptr %sharer_pointer_1174, align 8, !noalias !0
  store ptr @eraser_1141, ptr %eraser_pointer_1175, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i22 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i23 = load ptr, ptr %base_pointer.i22, align 8
  %varPointer.i = getelementptr i8, ptr %base.i23, i64 %seed_5_5892.unpack5
  store i64 %z.i17, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1179 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1179(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_11_460_1238_6021(i64 %i_6_12_461_1239_6395, %Pos %tmp_8455, i64 %ballCount_3_781_6265, %Reference %seed_5_5892, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_12_461_1239_6395, %ballCount_3_781_6265
  br i1 %z.i, label %label_1203, label %label_397

label_397:                                        ; preds = %entry
  %object.i = extractvalue %Pos %tmp_8455, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_397
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

erasePositive.exit:                               ; preds = %label_397, %decr.i.i, %free.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_394 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_394(%Pos zeroinitializer, ptr %stack)
  ret void

label_1203:                                       ; preds = %entry
  %stackPointer_pointer.i5 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i6 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i5, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i6, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i7
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_1203
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
  %newStackPointer.i8 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i8, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i6, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_1203, %realloc.i
  %limit.i14 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i7, %label_1203 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_1203 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i8, %realloc.i ], [ %currentStackPointer.i, %label_1203 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i5, align 8
  %tmp_8455.elt = extractvalue %Pos %tmp_8455, 0
  store i64 %tmp_8455.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1190.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %tmp_8455.elt2 = extractvalue %Pos %tmp_8455, 1
  store ptr %tmp_8455.elt2, ptr %stackPointer_1190.repack1, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1192 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1192, align 4, !noalias !0
  %i_6_12_461_1239_6395_pointer_1193 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_12_461_1239_6395, ptr %i_6_12_461_1239_6395_pointer_1193, align 4, !noalias !0
  %seed_5_5892_pointer_1194 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %seed_5_5892.elt = extractvalue %Reference %seed_5_5892, 0
  store ptr %seed_5_5892.elt, ptr %seed_5_5892_pointer_1194, align 8, !noalias !0
  %seed_5_5892_pointer_1194.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %seed_5_5892.elt4 = extractvalue %Reference %seed_5_5892, 1
  store i64 %seed_5_5892.elt4, ptr %seed_5_5892_pointer_1194.repack3, align 8, !noalias !0
  %returnAddress_pointer_1195 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1196 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1197 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_398, ptr %returnAddress_pointer_1195, align 8, !noalias !0
  store ptr @sharer_1131, ptr %sharer_pointer_1196, align 8, !noalias !0
  store ptr @eraser_1141, ptr %eraser_pointer_1197, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_5892.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i9 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i10 = load ptr, ptr %base_pointer.i9, align 8
  %varPointer.i = getelementptr i8, ptr %base.i10, i64 %seed_5_5892.elt4
  %get_8642 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i15 = icmp ule ptr %nextStackPointer.sink.i, %limit.i14
  tail call void @llvm.assume(i1 %isInside.i15)
  %newStackPointer.i16 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i16, ptr %stackPointer_pointer.i5, align 8, !alias.scope !0
  %returnAddress_1200 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1200(i64 %get_8642, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1232(%Pos %__8_19_773_1551_8644, ptr %stack) {
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
  %bounces_5_783_6504.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bounces_5_783_6504.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bounces_5_783_6504.unpack2 = load i64, ptr %bounces_5_783_6504.elt1, align 8, !noalias !0
  %tmp_8455_pointer_1235 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_1235, align 8, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1236 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_1236, align 4, !noalias !0
  %i_6_11_765_1543_6618_pointer_1237 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_11_765_1543_6618 = load i64, ptr %i_6_11_765_1543_6618_pointer_1237, align 4, !noalias !0
  %object.i = extractvalue %Pos %__8_19_773_1551_8644, 1
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
  %0 = insertvalue %Pos poison, i64 %tmp_8455.unpack, 0
  %tmp_84556 = insertvalue %Pos %0, ptr %tmp_8455.unpack5, 1
  %1 = insertvalue %Reference poison, ptr %bounces_5_783_6504.unpack, 0
  %bounces_5_783_65043 = insertvalue %Reference %1, i64 %bounces_5_783_6504.unpack2, 1
  %z.i = add i64 %i_6_11_765_1543_6618, 1
  musttail call tailcc void @loop_5_10_764_1542_6061(i64 %z.i, %Reference %bounces_5_783_65043, %Pos %tmp_84556, i64 %ballCount_3_781_6265, ptr nonnull %stack)
  ret void
}

define void @sharer_1242(ptr %stackPointer) {
entry:
  %tmp_8455_1239.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %tmp_8455_1239.unpack2 = load ptr, ptr %tmp_8455_1239.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8455_1239.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455_1239.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455_1239.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1252(ptr %stackPointer) {
entry:
  %tmp_8455_1249.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %tmp_8455_1249.unpack2 = load ptr, ptr %tmp_8455_1249.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8455_1249.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455_1249.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455_1249.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8455_1249.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8455_1249.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8455_1249.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1274(i64 %v_r_3062_6_17_771_1549_6222, ptr %stack) {
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
  %bounces_5_783_6504.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bounces_5_783_6504.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bounces_5_783_6504.unpack2 = load i64, ptr %bounces_5_783_6504.elt1, align 8, !noalias !0
  %z.i = add i64 %v_r_3062_6_17_771_1549_6222, 1
  %stack_pointer.i.i = getelementptr i8, ptr %bounces_5_783_6504.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bounces_5_783_6504.unpack2
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i13 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1280 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1280(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_1284(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1288(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1226(%Pos %didBounce_5_16_770_1548_6602, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i17 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  %bounces_5_783_6504.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bounces_5_783_6504.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bounces_5_783_6504.unpack2 = load i64, ptr %bounces_5_783_6504.elt1, align 8, !noalias !0
  %i_6_11_765_1543_6618_pointer_1231 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_11_765_1543_6618 = load i64, ptr %i_6_11_765_1543_6618_pointer_1231, align 4, !noalias !0
  %ballCount_3_781_6265_pointer_1230 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_1230, align 4, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %tmp_8455_pointer_1229 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_1229, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bounces_5_783_6504.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  store i64 %bounces_5_783_6504.unpack2, ptr %bounces_5_783_6504.elt1, align 8, !noalias !0
  store i64 %tmp_8455.unpack, ptr %tmp_8455_pointer_1229, align 8, !noalias !0
  store ptr %tmp_8455.unpack5, ptr %tmp_8455.elt4, align 8, !noalias !0
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1230, align 4, !noalias !0
  store i64 %i_6_11_765_1543_6618, ptr %i_6_11_765_1543_6618_pointer_1231, align 4, !noalias !0
  %sharer_pointer_1264 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1265 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1232, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1242, ptr %sharer_pointer_1264, align 8, !noalias !0
  store ptr @eraser_1252, ptr %eraser_pointer_1265, align 8, !noalias !0
  %tag_1266 = extractvalue %Pos %didBounce_5_16_770_1548_6602, 0
  switch i64 %tag_1266, label %label_1268 [
    i64 0, label %label_1273
    i64 1, label %label_1301
  ]

label_1268:                                       ; preds = %stackAllocate.exit
  ret void

label_1273:                                       ; preds = %stackAllocate.exit
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %0 = insertvalue %Reference poison, ptr %bounces_5_783_6504.unpack, 0
  %bounces_5_783_65043.i = insertvalue %Reference %0, i64 %bounces_5_783_6504.unpack2, 1
  %1 = insertvalue %Pos poison, i64 %tmp_8455.unpack, 0
  %tmp_84556.i = insertvalue %Pos %1, ptr %tmp_8455.unpack5, 1
  %z.i = add i64 %i_6_11_765_1543_6618, 1
  musttail call tailcc void @loop_5_10_764_1542_6061(i64 %z.i, %Reference %bounces_5_783_65043.i, %Pos %tmp_84556.i, i64 %ballCount_3_781_6265, ptr nonnull %stack)
  ret void

label_1301:                                       ; preds = %stackAllocate.exit
  %nextStackPointer.i32 = getelementptr i8, ptr %stackPointer.i, i64 64
  %isInside.not.i33 = icmp ugt ptr %nextStackPointer.i32, %limit.i
  br i1 %isInside.not.i33, label %realloc.i36, label %stackAllocate.exit50

realloc.i36:                                      ; preds = %label_1301
  %base_pointer.i37 = getelementptr i8, ptr %stack, i64 16
  %base.i38 = load ptr, ptr %base_pointer.i37, align 8, !alias.scope !0
  %intStackPointer.i39 = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i40 = ptrtoint ptr %base.i38 to i64
  %size.i41 = sub i64 %intStackPointer.i39, %intBase.i40
  %nextSize.i42 = add i64 %size.i41, 40
  %leadingZeros.i.i43 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i42, i1 false)
  %numBits.i.i44 = sub nuw nsw i64 64, %leadingZeros.i.i43
  %result.i.i45 = shl nuw i64 1, %numBits.i.i44
  %newBase.i46 = tail call ptr @realloc(ptr %base.i38, i64 %result.i.i45)
  %newLimit.i47 = getelementptr i8, ptr %newBase.i46, i64 %result.i.i45
  %newStackPointer.i48 = getelementptr i8, ptr %newBase.i46, i64 %size.i41
  %newNextStackPointer.i49 = getelementptr i8, ptr %newStackPointer.i48, i64 40
  store ptr %newBase.i46, ptr %base_pointer.i37, align 8, !alias.scope !0
  store ptr %newLimit.i47, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit50

stackAllocate.exit50:                             ; preds = %label_1301, %realloc.i36
  %limit.i56 = phi ptr [ %newLimit.i47, %realloc.i36 ], [ %limit.i, %label_1301 ]
  %nextStackPointer.sink.i34 = phi ptr [ %newNextStackPointer.i49, %realloc.i36 ], [ %nextStackPointer.i32, %label_1301 ]
  %common.ret.op.i35 = phi ptr [ %newStackPointer.i48, %realloc.i36 ], [ %oldStackPointer.i, %label_1301 ]
  store ptr %nextStackPointer.sink.i34, ptr %stackPointer_pointer.i, align 8
  store ptr %bounces_5_783_6504.unpack, ptr %common.ret.op.i35, align 8, !noalias !0
  %stackPointer_1291.repack11 = getelementptr inbounds i8, ptr %common.ret.op.i35, i64 8
  store i64 %bounces_5_783_6504.unpack2, ptr %stackPointer_1291.repack11, align 8, !noalias !0
  %returnAddress_pointer_1293 = getelementptr i8, ptr %common.ret.op.i35, i64 16
  %sharer_pointer_1294 = getelementptr i8, ptr %common.ret.op.i35, i64 24
  %eraser_pointer_1295 = getelementptr i8, ptr %common.ret.op.i35, i64 32
  store ptr @returnAddress_1274, ptr %returnAddress_pointer_1293, align 8, !noalias !0
  store ptr @sharer_1284, ptr %sharer_pointer_1294, align 8, !noalias !0
  store ptr @eraser_1288, ptr %eraser_pointer_1295, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %bounces_5_783_6504.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i51 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i52 = load ptr, ptr %base_pointer.i51, align 8
  %varPointer.i = getelementptr i8, ptr %base.i52, i64 %bounces_5_783_6504.unpack2
  %get_8657 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i57 = icmp ule ptr %nextStackPointer.sink.i34, %limit.i56
  tail call void @llvm.assume(i1 %isInside.i57)
  %newStackPointer.i58 = getelementptr i8, ptr %nextStackPointer.sink.i34, i64 -24
  store ptr %newStackPointer.i58, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1298 = load ptr, ptr %newStackPointer.i58, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1298(i64 %get_8657, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_10_764_1542_6061(i64 %i_6_11_765_1543_6618, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_11_765_1543_6618, %ballCount_3_781_6265
  %object.i = extractvalue %Pos %tmp_8455, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %z.i, label %label_1322, label %label_1225

label_1225:                                       ; preds = %entry
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_1225
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

erasePositive.exit:                               ; preds = %label_1225, %decr.i.i, %free.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1222 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1222(%Pos zeroinitializer, ptr %stack)
  ret void

label_1322:                                       ; preds = %entry
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1322
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_1322, %next.i.i
  %z.i10 = tail call %Pos @c_array_get(%Pos %tmp_8455, i64 %i_6_11_765_1543_6618)
  %stackPointer_pointer.i11 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i12 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i11, align 8, !alias.scope !0
  %limit.i13 = load ptr, ptr %limit_pointer.i12, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 72
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i13
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
  %newStackPointer.i14 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i14, i64 72
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i12, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i14, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  %tag.i = extractvalue %Pos %z.i10, 0
  %vtable.i = inttoptr i64 %tag.i to ptr
  %heap_obj.i = extractvalue %Pos %z.i10, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i11, align 8
  %bounces_5_783_6504.elt = extractvalue %Reference %bounces_5_783_6504, 0
  store ptr %bounces_5_783_6504.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1310.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %bounces_5_783_6504.elt2 = extractvalue %Reference %bounces_5_783_6504, 1
  store i64 %bounces_5_783_6504.elt2, ptr %stackPointer_1310.repack1, align 8, !noalias !0
  %tmp_8455_pointer_1312 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %tmp_8455.elt = extractvalue %Pos %tmp_8455, 0
  store i64 %tmp_8455.elt, ptr %tmp_8455_pointer_1312, align 8, !noalias !0
  %tmp_8455_pointer_1312.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i, ptr %tmp_8455_pointer_1312.repack3, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1313 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1313, align 4, !noalias !0
  %i_6_11_765_1543_6618_pointer_1314 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %i_6_11_765_1543_6618, ptr %i_6_11_765_1543_6618_pointer_1314, align 4, !noalias !0
  %returnAddress_pointer_1315 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_1316 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_1317 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_1226, ptr %returnAddress_pointer_1315, align 8, !noalias !0
  store ptr @sharer_1242, ptr %sharer_pointer_1316, align 8, !noalias !0
  store ptr @eraser_1252, ptr %eraser_pointer_1317, align 8, !noalias !0
  %functionPointer_1321 = load ptr, ptr %vtable.i, align 8, !noalias !0
  musttail call tailcc void %functionPointer_1321(ptr %heap_obj.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1323(%Pos %__8_775_1553_8645, ptr %stack) {
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
  %i_6_754_1532_6113 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %n_2873_pointer_1326 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %n_2873 = load i64, ptr %n_2873_pointer_1326, align 4, !noalias !0
  %bounces_5_783_6504_pointer_1327 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bounces_5_783_6504.unpack = load ptr, ptr %bounces_5_783_6504_pointer_1327, align 8, !noalias !0
  %bounces_5_783_6504.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %bounces_5_783_6504.unpack2 = load i64, ptr %bounces_5_783_6504.elt1, align 8, !noalias !0
  %tmp_8455_pointer_1328 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_1328, align 8, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1329 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_1329, align 4, !noalias !0
  %object.i = extractvalue %Pos %__8_775_1553_8645, 1
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
  %0 = insertvalue %Pos poison, i64 %tmp_8455.unpack, 0
  %tmp_84556 = insertvalue %Pos %0, ptr %tmp_8455.unpack5, 1
  %1 = insertvalue %Reference poison, ptr %bounces_5_783_6504.unpack, 0
  %bounces_5_783_65043 = insertvalue %Reference %1, i64 %bounces_5_783_6504.unpack2, 1
  %z.i = add i64 %i_6_754_1532_6113, 1
  musttail call tailcc void @loop_5_753_1531_6134(i64 %z.i, i64 %n_2873, %Reference %bounces_5_783_65043, %Pos %tmp_84556, i64 %ballCount_3_781_6265, ptr nonnull %stack)
  ret void
}

define void @sharer_1335(ptr %stackPointer) {
entry:
  %tmp_8455_1333.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8455_1333.unpack2 = load ptr, ptr %tmp_8455_1333.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8455_1333.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455_1333.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455_1333.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1347(ptr %stackPointer) {
entry:
  %tmp_8455_1345.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8455_1345.unpack2 = load ptr, ptr %tmp_8455_1345.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8455_1345.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455_1345.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455_1345.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8455_1345.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8455_1345.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8455_1345.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_5_753_1531_6134(i64 %i_6_754_1532_6113, i64 %n_2873, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_754_1532_6113, %n_2873
  %object.i = extractvalue %Pos %tmp_8455, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %z.i, label %label_1363, label %label_1217

label_1217:                                       ; preds = %entry
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_1217
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

erasePositive.exit:                               ; preds = %label_1217, %decr.i.i, %free.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1214 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1214(%Pos zeroinitializer, ptr %stack)
  ret void

label_1363:                                       ; preds = %entry
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1363
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_1363, %next.i.i
  %stackPointer_pointer.i10 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i11 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i10, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i11, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 80
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i12
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
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
  %newStackPointer.i13 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i13, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i11, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i13, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i10, align 8
  store i64 %i_6_754_1532_6113, ptr %common.ret.op.i, align 4, !noalias !0
  %n_2873_pointer_1356 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %n_2873, ptr %n_2873_pointer_1356, align 4, !noalias !0
  %bounces_5_783_6504_pointer_1357 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %bounces_5_783_6504.elt = extractvalue %Reference %bounces_5_783_6504, 0
  store ptr %bounces_5_783_6504.elt, ptr %bounces_5_783_6504_pointer_1357, align 8, !noalias !0
  %bounces_5_783_6504_pointer_1357.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %bounces_5_783_6504.elt2 = extractvalue %Reference %bounces_5_783_6504, 1
  store i64 %bounces_5_783_6504.elt2, ptr %bounces_5_783_6504_pointer_1357.repack1, align 8, !noalias !0
  %tmp_8455_pointer_1358 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %tmp_8455.elt = extractvalue %Pos %tmp_8455, 0
  store i64 %tmp_8455.elt, ptr %tmp_8455_pointer_1358, align 8, !noalias !0
  %tmp_8455_pointer_1358.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %object.i, ptr %tmp_8455_pointer_1358.repack3, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1359 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %ballCount_3_781_6265, ptr %ballCount_3_781_6265_pointer_1359, align 4, !noalias !0
  %returnAddress_pointer_1360 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_1361 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_1362 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_1323, ptr %returnAddress_pointer_1360, align 8, !noalias !0
  store ptr @sharer_1335, ptr %sharer_pointer_1361, align 8, !noalias !0
  store ptr @eraser_1347, ptr %eraser_pointer_1362, align 8, !noalias !0
  musttail call tailcc void @loop_5_10_764_1542_6061(i64 0, %Reference %bounces_5_783_6504, %Pos %tmp_8455, i64 %ballCount_3_781_6265, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1364(%Pos %__777_1555_8661, ptr %stack) {
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
  %bounces_5_783_6504.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bounces_5_783_6504.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %bounces_5_783_6504.unpack2 = load i64, ptr %bounces_5_783_6504.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__777_1555_8661, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %bounces_5_783_6504.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %bounces_5_783_6504.unpack2
  %get_8662 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1369 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1369(i64 %get_8662, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1204(%Pos %__18_729_1507_8643, ptr %stack) {
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
  %bounces_5_783_6504.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %bounces_5_783_6504.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %bounces_5_783_6504.unpack2 = load i64, ptr %bounces_5_783_6504.elt1, align 8, !noalias !0
  %n_2873_pointer_1207 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %n_2873 = load i64, ptr %n_2873_pointer_1207, align 4, !noalias !0
  %tmp_8455_pointer_1208 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_8455.unpack = load i64, ptr %tmp_8455_pointer_1208, align 8, !noalias !0
  %tmp_8455.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_8455.unpack5 = load ptr, ptr %tmp_8455.elt4, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1209 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ballCount_3_781_6265 = load i64, ptr %ballCount_3_781_6265_pointer_1209, align 4, !noalias !0
  %object.i = extractvalue %Pos %__18_729_1507_8643, 1
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
  %0 = insertvalue %Pos poison, i64 %tmp_8455.unpack, 0
  %tmp_84556 = insertvalue %Pos %0, ptr %tmp_8455.unpack5, 1
  %1 = insertvalue %Reference poison, ptr %bounces_5_783_6504.unpack, 0
  %bounces_5_783_65043 = insertvalue %Reference %1, i64 %bounces_5_783_6504.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %bounces_5_783_6504.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1374.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %bounces_5_783_6504.unpack2, ptr %stackPointer_1374.repack7, align 8, !noalias !0
  %returnAddress_pointer_1376 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_1377 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_1378 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_1364, ptr %returnAddress_pointer_1376, align 8, !noalias !0
  store ptr @sharer_1284, ptr %sharer_pointer_1377, align 8, !noalias !0
  store ptr @eraser_1288, ptr %eraser_pointer_1378, align 8, !noalias !0
  musttail call tailcc void @loop_5_753_1531_6134(i64 0, i64 %n_2873, %Reference %bounces_5_783_65043, %Pos %tmp_84556, i64 %ballCount_3_781_6265, ptr nonnull %stack)
  ret void
}

define void @sharer_1383(ptr %stackPointer) {
entry:
  %tmp_8455_1381.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8455_1381.unpack2 = load ptr, ptr %tmp_8455_1381.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8455_1381.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455_1381.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455_1381.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1393(ptr %stackPointer) {
entry:
  %tmp_8455_1391.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_8455_1391.unpack2 = load ptr, ptr %tmp_8455_1391.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_8455_1391.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_8455_1391.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_8455_1391.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_8455_1391.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_8455_1391.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_8455_1391.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @run_2874(i64 %n_2873, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i15 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 24
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i16 = getelementptr i8, ptr %stack, i64 16
  %base.i17 = load ptr, ptr %base_pointer.i16, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i18 = ptrtoint ptr %base.i17 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i18
  %nextSize.i = add i64 %size.i, 24
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i17, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 24
  store ptr %newBase.i, ptr %base_pointer.i16, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i23 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i15, align 8
  %sharer_pointer_346 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_347 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_340, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_346, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_347, align 8, !noalias !0
  %base_pointer.i6 = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i7 = load ptr, ptr %stackPointer_pointer.i15, align 8
  %base.i8 = load ptr, ptr %base_pointer.i6, align 8
  %intStack.i9 = ptrtoint ptr %stackPointer.i7 to i64
  %intBase.i10 = ptrtoint ptr %base.i8 to i64
  %offset.i11 = sub i64 %intStack.i9, %intBase.i10
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i19 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i24 = getelementptr i8, ptr %stackPointer.i7, i64 32
  %isInside.not.i25 = icmp ugt ptr %nextStackPointer.i24, %limit.i23
  br i1 %isInside.not.i25, label %realloc.i28, label %stackAllocate.exit42

realloc.i28:                                      ; preds = %stackAllocate.exit
  %nextSize.i34 = add i64 %offset.i11, 32
  %leadingZeros.i.i35 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i34, i1 false)
  %numBits.i.i36 = sub nuw nsw i64 64, %leadingZeros.i.i35
  %result.i.i37 = shl nuw i64 1, %numBits.i.i36
  %newBase.i38 = tail call ptr @realloc(ptr %base.i8, i64 %result.i.i37)
  %newLimit.i39 = getelementptr i8, ptr %newBase.i38, i64 %result.i.i37
  %newStackPointer.i40 = getelementptr i8, ptr %newBase.i38, i64 %offset.i11
  %newNextStackPointer.i41 = getelementptr i8, ptr %newStackPointer.i40, i64 32
  store ptr %newBase.i38, ptr %base_pointer.i6, align 8, !alias.scope !0
  store ptr %newLimit.i39, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit42

stackAllocate.exit42:                             ; preds = %stackAllocate.exit, %realloc.i28
  %base.i53 = phi ptr [ %newBase.i38, %realloc.i28 ], [ %base.i8, %stackAllocate.exit ]
  %limit.i46 = phi ptr [ %newLimit.i39, %realloc.i28 ], [ %limit.i23, %stackAllocate.exit ]
  %nextStackPointer.sink.i26 = phi ptr [ %newNextStackPointer.i41, %realloc.i28 ], [ %nextStackPointer.i24, %stackAllocate.exit ]
  %common.ret.op.i27 = phi ptr [ %newStackPointer.i40, %realloc.i28 ], [ %stackPointer.i7, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i26, ptr %stackPointer_pointer.i15, align 8
  store i64 74755, ptr %common.ret.op.i27, align 4, !noalias !0
  %returnAddress_pointer_365 = getelementptr i8, ptr %common.ret.op.i27, i64 8
  %sharer_pointer_366 = getelementptr i8, ptr %common.ret.op.i27, i64 16
  %eraser_pointer_367 = getelementptr i8, ptr %common.ret.op.i27, i64 24
  store ptr @returnAddress_348, ptr %returnAddress_pointer_365, align 8, !noalias !0
  store ptr @sharer_356, ptr %sharer_pointer_366, align 8, !noalias !0
  store ptr @eraser_360, ptr %eraser_pointer_367, align 8, !noalias !0
  %nextStackPointer.i47 = getelementptr i8, ptr %nextStackPointer.sink.i26, i64 24
  %isInside.not.i48 = icmp ugt ptr %nextStackPointer.i47, %limit.i46
  br i1 %isInside.not.i48, label %realloc.i51, label %stackAllocate.exit65

realloc.i51:                                      ; preds = %stackAllocate.exit42
  %intStackPointer.i54 = ptrtoint ptr %nextStackPointer.sink.i26 to i64
  %intBase.i55 = ptrtoint ptr %base.i53 to i64
  %size.i56 = sub i64 %intStackPointer.i54, %intBase.i55
  %nextSize.i57 = add i64 %size.i56, 24
  %leadingZeros.i.i58 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i57, i1 false)
  %numBits.i.i59 = sub nuw nsw i64 64, %leadingZeros.i.i58
  %result.i.i60 = shl nuw i64 1, %numBits.i.i59
  %newBase.i61 = tail call ptr @realloc(ptr %base.i53, i64 %result.i.i60)
  %newLimit.i62 = getelementptr i8, ptr %newBase.i61, i64 %result.i.i60
  %newStackPointer.i63 = getelementptr i8, ptr %newBase.i61, i64 %size.i56
  %newNextStackPointer.i64 = getelementptr i8, ptr %newStackPointer.i63, i64 24
  store ptr %newBase.i61, ptr %base_pointer.i6, align 8, !alias.scope !0
  store ptr %newLimit.i62, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit65

stackAllocate.exit65:                             ; preds = %stackAllocate.exit42, %realloc.i51
  %limit.i71 = phi ptr [ %newLimit.i62, %realloc.i51 ], [ %limit.i46, %stackAllocate.exit42 ]
  %nextStackPointer.sink.i49 = phi ptr [ %newNextStackPointer.i64, %realloc.i51 ], [ %nextStackPointer.i47, %stackAllocate.exit42 ]
  %common.ret.op.i50 = phi ptr [ %newStackPointer.i63, %realloc.i51 ], [ %nextStackPointer.sink.i26, %stackAllocate.exit42 ]
  store ptr %nextStackPointer.sink.i49, ptr %stackPointer_pointer.i15, align 8
  %sharer_pointer_374 = getelementptr i8, ptr %common.ret.op.i50, i64 8
  %eraser_pointer_375 = getelementptr i8, ptr %common.ret.op.i50, i64 16
  store ptr @returnAddress_368, ptr %common.ret.op.i50, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_374, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_375, align 8, !noalias !0
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i15, align 8
  %base.i = load ptr, ptr %base_pointer.i6, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt.i67 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i72 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i73 = icmp ugt ptr %nextStackPointer.i72, %limit.i71
  br i1 %isInside.not.i73, label %realloc.i76, label %stackAllocate.exit90

realloc.i76:                                      ; preds = %stackAllocate.exit65
  %nextSize.i82 = add i64 %offset.i, 32
  %leadingZeros.i.i83 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i82, i1 false)
  %numBits.i.i84 = sub nuw nsw i64 64, %leadingZeros.i.i83
  %result.i.i85 = shl nuw i64 1, %numBits.i.i84
  %newBase.i86 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i85)
  %newLimit.i87 = getelementptr i8, ptr %newBase.i86, i64 %result.i.i85
  %newStackPointer.i88 = getelementptr i8, ptr %newBase.i86, i64 %offset.i
  %newNextStackPointer.i89 = getelementptr i8, ptr %newStackPointer.i88, i64 32
  store ptr %newBase.i86, ptr %base_pointer.i6, align 8, !alias.scope !0
  store ptr %newLimit.i87, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit90

stackAllocate.exit90:                             ; preds = %stackAllocate.exit65, %realloc.i76
  %nextStackPointer.sink.i74 = phi ptr [ %newNextStackPointer.i89, %realloc.i76 ], [ %nextStackPointer.i72, %stackAllocate.exit65 ]
  %common.ret.op.i75 = phi ptr [ %newStackPointer.i88, %realloc.i76 ], [ %stackPointer.i, %stackAllocate.exit65 ]
  store ptr %nextStackPointer.sink.i74, ptr %stackPointer_pointer.i15, align 8
  store i64 0, ptr %common.ret.op.i75, align 4, !noalias !0
  %returnAddress_pointer_387 = getelementptr i8, ptr %common.ret.op.i75, i64 8
  %sharer_pointer_388 = getelementptr i8, ptr %common.ret.op.i75, i64 16
  %eraser_pointer_389 = getelementptr i8, ptr %common.ret.op.i75, i64 24
  store ptr @returnAddress_376, ptr %returnAddress_pointer_387, align 8, !noalias !0
  store ptr @sharer_356, ptr %sharer_pointer_388, align 8, !noalias !0
  store ptr @eraser_360, ptr %eraser_pointer_389, align 8, !noalias !0
  %z.i = tail call %Pos @c_array_new(i64 100)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit90
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit90, %next.i.i
  %currentStackPointer.i93 = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %limit.i94 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i95 = getelementptr i8, ptr %currentStackPointer.i93, i64 72
  %isInside.not.i96 = icmp ugt ptr %nextStackPointer.i95, %limit.i94
  br i1 %isInside.not.i96, label %realloc.i99, label %stackAllocate.exit113

realloc.i99:                                      ; preds = %sharePositive.exit
  %base.i101 = load ptr, ptr %base_pointer.i6, align 8, !alias.scope !0
  %intStackPointer.i102 = ptrtoint ptr %currentStackPointer.i93 to i64
  %intBase.i103 = ptrtoint ptr %base.i101 to i64
  %size.i104 = sub i64 %intStackPointer.i102, %intBase.i103
  %nextSize.i105 = add i64 %size.i104, 72
  %leadingZeros.i.i106 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i105, i1 false)
  %numBits.i.i107 = sub nuw nsw i64 64, %leadingZeros.i.i106
  %result.i.i108 = shl nuw i64 1, %numBits.i.i107
  %newBase.i109 = tail call ptr @realloc(ptr %base.i101, i64 %result.i.i108)
  %newLimit.i110 = getelementptr i8, ptr %newBase.i109, i64 %result.i.i108
  %newStackPointer.i111 = getelementptr i8, ptr %newBase.i109, i64 %size.i104
  %newNextStackPointer.i112 = getelementptr i8, ptr %newStackPointer.i111, i64 72
  store ptr %newBase.i109, ptr %base_pointer.i6, align 8, !alias.scope !0
  store ptr %newLimit.i110, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit113

stackAllocate.exit113:                            ; preds = %sharePositive.exit, %realloc.i99
  %limit.i7.i = phi ptr [ %newLimit.i110, %realloc.i99 ], [ %limit.i94, %sharePositive.exit ]
  %nextStackPointer.sink.i97 = phi ptr [ %newNextStackPointer.i112, %realloc.i99 ], [ %nextStackPointer.i95, %sharePositive.exit ]
  %common.ret.op.i98 = phi ptr [ %newStackPointer.i111, %realloc.i99 ], [ %currentStackPointer.i93, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i97, ptr %stackPointer_pointer.i15, align 8
  store ptr %prompt.i67, ptr %common.ret.op.i98, align 8, !noalias !0
  %stackPointer_1399.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i98, i64 8
  store i64 %offset.i, ptr %stackPointer_1399.repack1, align 8, !noalias !0
  %n_2873_pointer_1401 = getelementptr i8, ptr %common.ret.op.i98, i64 16
  store i64 %n_2873, ptr %n_2873_pointer_1401, align 4, !noalias !0
  %tmp_8455_pointer_1402 = getelementptr i8, ptr %common.ret.op.i98, i64 24
  %pureApp_8480.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_8480.elt, ptr %tmp_8455_pointer_1402, align 8, !noalias !0
  %tmp_8455_pointer_1402.repack3 = getelementptr i8, ptr %common.ret.op.i98, i64 32
  store ptr %object.i, ptr %tmp_8455_pointer_1402.repack3, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1403 = getelementptr i8, ptr %common.ret.op.i98, i64 40
  store i64 100, ptr %ballCount_3_781_6265_pointer_1403, align 4, !noalias !0
  %returnAddress_pointer_1404 = getelementptr i8, ptr %common.ret.op.i98, i64 48
  %sharer_pointer_1405 = getelementptr i8, ptr %common.ret.op.i98, i64 56
  %eraser_pointer_1406 = getelementptr i8, ptr %common.ret.op.i98, i64 64
  store ptr @returnAddress_1204, ptr %returnAddress_pointer_1404, align 8, !noalias !0
  store ptr @sharer_1383, ptr %sharer_pointer_1405, align 8, !noalias !0
  store ptr @eraser_1393, ptr %eraser_pointer_1406, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i97, i64 72
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i7.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit113
  %base.i.i = load ptr, ptr %base_pointer.i6, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i97 to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 72
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i8.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i8.i, i64 72
  store ptr %newBase.i.i, ptr %base_pointer.i6, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit113
  %limit.i14.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i7.i, %stackAllocate.exit113 ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit113 ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i8.i, %realloc.i.i ], [ %nextStackPointer.sink.i97, %stackAllocate.exit113 ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i15, align 8
  store i64 %pureApp_8480.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_1190.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i, ptr %stackPointer_1190.repack1.i, align 8, !noalias !0
  %ballCount_3_781_6265_pointer_1192.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 100, ptr %ballCount_3_781_6265_pointer_1192.i, align 4, !noalias !0
  %i_6_12_461_1239_6395_pointer_1193.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 0, ptr %i_6_12_461_1239_6395_pointer_1193.i, align 4, !noalias !0
  %seed_5_5892_pointer_1194.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %prompt.i19, ptr %seed_5_5892_pointer_1194.i, align 8, !noalias !0
  %seed_5_5892_pointer_1194.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store i64 %offset.i11, ptr %seed_5_5892_pointer_1194.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_1195.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %sharer_pointer_1196.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  %eraser_pointer_1197.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr @returnAddress_398, ptr %returnAddress_pointer_1195.i, align 8, !noalias !0
  store ptr @sharer_1131, ptr %sharer_pointer_1196.i, align 8, !noalias !0
  store ptr @eraser_1141, ptr %eraser_pointer_1197.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %prompt.i19, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i9.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i10.i = load ptr, ptr %base_pointer.i9.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i10.i, i64 %offset.i11
  %get_8642.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i15.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i14.i
  tail call void @llvm.assume(i1 %isInside.i15.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %returnAddress_1200.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1200.i(i64 %get_8642.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1407(%Pos %v_r_3343_4146, ptr %stack) {
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
  %index_2107_pointer_1410 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_1410, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_1412 = extractvalue %Pos %v_r_3343_4146, 0
  switch i64 %tag_1412, label %label_1414 [
    i64 0, label %label_1418
    i64 1, label %label_1424
  ]

label_1414:                                       ; preds = %entry
  ret void

label_1418:                                       ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1418
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

eraseNegative.exit:                               ; preds = %label_1418, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1415 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1415(i64 %x.i, ptr nonnull %stack)
  ret void

label_1424:                                       ; preds = %entry
  %Exception_2362_pointer_1411 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_1411, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_8464 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_8464.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_8464, %Pos %z.i)
  %utf8StringLiteral_8466 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_8466.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_8466)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_8469 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_8469.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_8469)
  %functionPointer_1423 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_1423(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_1428(ptr %stackPointer) {
entry:
  %str_2106_1425.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_1425.unpack2 = load ptr, ptr %str_2106_1425.elt1, align 8, !noalias !0
  %Exception_2362_1427.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_1427.unpack5 = load ptr, ptr %Exception_2362_1427.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_1425.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_1425.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_1425.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_1427.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_1427.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_1427.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1436(ptr %stackPointer) {
entry:
  %str_2106_1433.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_1433.unpack2 = load ptr, ptr %str_2106_1433.elt1, align 8, !noalias !0
  %Exception_2362_1435.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_1435.unpack5 = load ptr, ptr %Exception_2362_1435.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_1433.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_1433.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_1433.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_1433.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_1433.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_1433.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_1435.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_1435.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_1435.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_1435.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_1435.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_1435.unpack5)
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
  %stackPointer_1441.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_1441.repack1, align 8, !noalias !0
  %index_2107_pointer_1443 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_1443, align 4, !noalias !0
  %Exception_2362_pointer_1444 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_1444, align 8, !noalias !0
  %Exception_2362_pointer_1444.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_1444.repack3, align 8, !noalias !0
  %returnAddress_pointer_1445 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_1446 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_1447 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_1407, ptr %returnAddress_pointer_1445, align 8, !noalias !0
  store ptr @sharer_1428, ptr %sharer_pointer_1446, align 8, !noalias !0
  store ptr @eraser_1436, ptr %eraser_pointer_1447, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_1454, label %label_1459

label_1454:                                       ; preds = %stackAllocate.exit
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
  %returnAddress_1451 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1451(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_1459:                                       ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_1459
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

erasePositive.exit:                               ; preds = %label_1459, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1456 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1456(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  tail call tailcc void @main_2875(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2875(ptr nonnull %stack.i2.i)
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
