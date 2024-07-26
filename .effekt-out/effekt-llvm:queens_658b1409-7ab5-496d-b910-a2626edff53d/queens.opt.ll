; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:queens_658b1409-7ab5-496d-b910-a2626edff53d/queens.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:queens_658b1409-7ab5-496d-b910-a2626edff53d/queens.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@utf8StringLiteral_6178.lit = private constant [5 x i8] c"False"
@utf8StringLiteral_6179.lit = private constant [4 x i8] c"True"
@vtable_210 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_5518_clause_195]
@vtable_241 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_5449_clause_233]
@utf8StringLiteral_6233.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_5995.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_5997.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_6000.lit = private constant [1 x i8] c"'"

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

define tailcc void @returnAddress_10(%Pos %v_r_3046_2_5758, ptr %stack) {
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
  %i_6_5754 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5980_pointer_13 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5980 = load i64, ptr %tmp_5980_pointer_13, align 4, !noalias !0
  %object.i = extractvalue %Pos %v_r_3046_2_5758, 1
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
  %z.i = add i64 %i_6_5754, 1
  %z.i.i = icmp slt i64 %z.i, %tmp_5980
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i3.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br i1 %z.i.i, label %label_32.i, label %label_9.i

label_9.i:                                        ; preds = %erasePositive.exit
  %isInside.i.i = icmp ule ptr %currentStackPointer.i.i, %limit.i3.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 -24
  store ptr %newStackPointer.i.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_6.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_6.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_32.i:                                       ; preds = %erasePositive.exit
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 40
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i3.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_32.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
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
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i4.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_32.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %z.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %tmp_5980_pointer_28.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %tmp_5980, ptr %tmp_5980_pointer_28.i, align 4, !noalias !0
  %returnAddress_pointer_29.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %sharer_pointer_30.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  %eraser_pointer_31.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29.i, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30.i, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31.i, align 8, !noalias !0
  musttail call tailcc void @run_2855(i64 8, ptr nonnull %stack)
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

define tailcc void @loop_5_5751(i64 %i_6_5754, i64 %tmp_5980, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_5754, %tmp_5980
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
  store i64 %i_6_5754, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5980_pointer_28 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5980, ptr %tmp_5980_pointer_28, align 4, !noalias !0
  %returnAddress_pointer_29 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_30 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_31 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31, align 8, !noalias !0
  musttail call tailcc void @run_2855(i64 8, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_35(%Pos %v_r_3050_4215, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  tail call void @c_io_println_String(%Pos %v_r_3050_4215)
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_36 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_36(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_39(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_41(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_34(%Pos %r_2882, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_45 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_46 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_35, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_45, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_46, align 8, !noalias !0
  %tag_47 = extractvalue %Pos %r_2882, 0
  switch i64 %tag_47, label %label_49 [
    i64 0, label %label_53
    i64 1, label %label_57
  ]

label_49:                                         ; preds = %stackAllocate.exit
  ret void

label_53:                                         ; preds = %stackAllocate.exit
  %utf8StringLiteral_6178 = tail call %Pos @c_bytearray_construct(i64 5, ptr nonnull @utf8StringLiteral_6178.lit)
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_50 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_50(%Pos %utf8StringLiteral_6178, ptr nonnull %stack)
  ret void

label_57:                                         ; preds = %stackAllocate.exit
  %utf8StringLiteral_6179 = tail call %Pos @c_bytearray_construct(i64 4, ptr nonnull @utf8StringLiteral_6179.lit)
  %stackPointer.i11 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i13 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i14 = icmp ule ptr %stackPointer.i11, %limit.i13
  tail call void @llvm.assume(i1 %isInside.i14)
  %newStackPointer.i15 = getelementptr i8, ptr %stackPointer.i11, i64 -24
  store ptr %newStackPointer.i15, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_54 = load ptr, ptr %newStackPointer.i15, align 8, !noalias !0
  musttail call tailcc void %returnAddress_54(%Pos %utf8StringLiteral_6179, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_33(%Pos %v_r_3048_6176, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %v_r_3048_6176, 1
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
  %sharer_pointer_60 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_61 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_34, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_60, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_61, align 8, !noalias !0
  musttail call tailcc void @run_2855(i64 8, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_4081_4145, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_4081_4145, 0
  %z.i = add i64 %unboxed.i, -1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_64 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_65 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_33, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_64, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_65, align 8, !noalias !0
  %z.i.i = icmp sgt i64 %z.i, 0
  br i1 %z.i.i, label %label_32.i, label %stackAllocate.exit.i6

stackAllocate.exit.i6:                            ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr @returnAddress_34, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_64, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_65, align 8, !noalias !0
  musttail call tailcc void @run_2855(i64 8, ptr nonnull %stack)
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
  %tmp_5980_pointer_28.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %z.i, ptr %tmp_5980_pointer_28.i, align 4, !noalias !0
  %returnAddress_pointer_29.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %sharer_pointer_30.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  %eraser_pointer_31.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29.i, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30.i, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31.i, align 8, !noalias !0
  musttail call tailcc void @run_2855(i64 8, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_71(%Pos %returned_6182, ptr nocapture %stack) {
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
  %returnAddress_73 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_73(%Pos %returned_6182, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_76(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_78(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define void @eraser_91(ptr nocapture readonly %environment) {
entry:
  %tmp_5953_89.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5953_89.unpack2 = load ptr, ptr %tmp_5953_89.elt1, align 8, !noalias !0
  %acc_3_3_5_169_5458_90.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_5458_90.unpack5 = load ptr, ptr %acc_3_3_5_169_5458_90.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_5953_89.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_5953_89.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_5953_89.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_5953_89.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_5953_89.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_5953_89.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_5458_90.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_5458_90.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_5458_90.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_5458_90.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_5458_90.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_5458_90.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_5448(i64 %start_2_2_4_168_5617, %Pos %acc_3_3_5_169_5458, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_5617, 1
  br i1 %z.i6, label %label_101, label %label_97

label_97:                                         ; preds = %entry, %label_97
  %acc_3_3_5_169_5458.tr8 = phi %Pos [ %make_6188, %label_97 ], [ %acc_3_3_5_169_5458, %entry ]
  %start_2_2_4_168_5617.tr7 = phi i64 [ %z.i5, %label_97 ], [ %start_2_2_4_168_5617, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_5617.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_5617.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_91, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_6185.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_6185.elt, ptr %environment.i, align 8, !noalias !0
  %environment_88.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_6185.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_6185.elt2, ptr %environment_88.repack1, align 8, !noalias !0
  %acc_3_3_5_169_5458_pointer_95 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_5458.elt = extractvalue %Pos %acc_3_3_5_169_5458.tr8, 0
  store i64 %acc_3_3_5_169_5458.elt, ptr %acc_3_3_5_169_5458_pointer_95, align 8, !noalias !0
  %acc_3_3_5_169_5458_pointer_95.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_5458.elt4 = extractvalue %Pos %acc_3_3_5_169_5458.tr8, 1
  store ptr %acc_3_3_5_169_5458.elt4, ptr %acc_3_3_5_169_5458_pointer_95.repack3, align 8, !noalias !0
  %make_6188 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_5617.tr7, 2
  br i1 %z.i, label %label_101, label %label_97

label_101:                                        ; preds = %label_97, %entry
  %acc_3_3_5_169_5458.tr.lcssa = phi %Pos [ %acc_3_3_5_169_5458, %entry ], [ %make_6188, %label_97 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_98 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_98(%Pos %acc_3_3_5_169_5458.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_112(%Pos %v_r_3234_32_59_223_5441, ptr %stack) {
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
  %index_7_34_198_5636 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %acc_8_35_199_5690_pointer_115 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %acc_8_35_199_5690 = load i64, ptr %acc_8_35_199_5690_pointer_115, align 4, !noalias !0
  %p_8_9_5385_pointer_116 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %p_8_9_5385 = load ptr, ptr %p_8_9_5385_pointer_116, align 8, !noalias !0
  %v_r_3043_30_194_5531_pointer_117 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_3043_30_194_5531.unpack = load i64, ptr %v_r_3043_30_194_5531_pointer_117, align 8, !noalias !0
  %v_r_3043_30_194_5531.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_3043_30_194_5531.unpack2 = load ptr, ptr %v_r_3043_30_194_5531.elt1, align 8, !noalias !0
  %tmp_5960_pointer_118 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5960 = load i64, ptr %tmp_5960_pointer_118, align 4, !noalias !0
  %tag_119 = extractvalue %Pos %v_r_3234_32_59_223_5441, 0
  %fields_120 = extractvalue %Pos %v_r_3234_32_59_223_5441, 1
  switch i64 %tag_119, label %common.ret [
    i64 1, label %label_144
    i64 0, label %label_151
  ]

common.ret:                                       ; preds = %entry
  ret void

label_132:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_3043_30_194_5531.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_132
  %referenceCount.i.i37 = load i64, ptr %v_r_3043_30_194_5531.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_3043_30_194_5531.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_3043_30_194_5531.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_3043_30_194_5531.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_3043_30_194_5531.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_132, %decr.i.i39, %free.i.i41
  %pair_127 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_5385)
  %k_13_14_4_5762 = extractvalue <{ ptr, ptr }> %pair_127, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_5762, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_5762, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_5762, i64 40
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
  %stack_128 = extractvalue <{ ptr, ptr }> %pair_127, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_128, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_128, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_129 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_129(%Pos { i64 10, ptr null }, ptr %stack_128)
  ret void

label_141:                                        ; preds = %label_143
  %isNull.i.i24 = icmp eq ptr %v_r_3043_30_194_5531.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_141
  %referenceCount.i.i26 = load i64, ptr %v_r_3043_30_194_5531.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_3043_30_194_5531.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_3043_30_194_5531.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_3043_30_194_5531.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_3043_30_194_5531.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_141, %decr.i.i28, %free.i.i30
  %pair_136 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_5385)
  %k_13_14_4_5761 = extractvalue <{ ptr, ptr }> %pair_136, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_5761, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_5761, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5761, i64 40
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
  %stack_137 = extractvalue <{ ptr, ptr }> %pair_136, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_137, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_137, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_138 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_138(%Pos { i64 10, ptr null }, ptr %stack_137)
  ret void

label_142:                                        ; preds = %label_143
  %0 = insertvalue %Pos poison, i64 %v_r_3043_30_194_5531.unpack, 0
  %v_r_3043_30_194_55313 = insertvalue %Pos %0, ptr %v_r_3043_30_194_5531.unpack2, 1
  %z.i = add i64 %index_7_34_198_5636, 1
  %z.i108 = mul i64 %acc_8_35_199_5690, 10
  %z.i109 = sub i64 %z.i108, %tmp_5960
  %z.i110 = add i64 %z.i109, %v_coe_4050_46_73_237_5476.unpack
  musttail call tailcc void @go_6_33_197_5691(i64 %z.i, i64 %z.i110, ptr %p_8_9_5385, %Pos %v_r_3043_30_194_55313, i64 %tmp_5960, ptr nonnull %stack)
  ret void

label_143:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_4050_46_73_237_5476.unpack, 58
  br i1 %z.i111, label %label_142, label %label_141

label_144:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_120, i64 16
  %v_coe_4050_46_73_237_5476.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_4050_46_73_237_5476.elt4 = getelementptr i8, ptr %fields_120, i64 24
  %v_coe_4050_46_73_237_5476.unpack5 = load ptr, ptr %v_coe_4050_46_73_237_5476.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_4050_46_73_237_5476.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_144
  %referenceCount.i.i = load i64, ptr %v_coe_4050_46_73_237_5476.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_4050_46_73_237_5476.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_144
  %referenceCount.i11 = load i64, ptr %fields_120, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_120, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_120, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_120)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_4050_46_73_237_5476.unpack, 47
  br i1 %z.i112, label %label_143, label %label_132

label_151:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_120, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_151
  %referenceCount.i = load i64, ptr %fields_120, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_120, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_120, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_120, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_120)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_151, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_3043_30_194_5531.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_3043_30_194_5531.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_3043_30_194_5531.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3043_30_194_5531.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3043_30_194_5531.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3043_30_194_5531.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_148 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_148(i64 %acc_8_35_199_5690, ptr nonnull %stack)
  ret void
}

define void @sharer_157(ptr %stackPointer) {
entry:
  %v_r_3043_30_194_5531_155.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_3043_30_194_5531_155.unpack2 = load ptr, ptr %v_r_3043_30_194_5531_155.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3043_30_194_5531_155.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3043_30_194_5531_155.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3043_30_194_5531_155.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_169(ptr %stackPointer) {
entry:
  %v_r_3043_30_194_5531_167.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_3043_30_194_5531_167.unpack2 = load ptr, ptr %v_r_3043_30_194_5531_167.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3043_30_194_5531_167.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3043_30_194_5531_167.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3043_30_194_5531_167.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3043_30_194_5531_167.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3043_30_194_5531_167.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3043_30_194_5531_167.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_186(%Pos %returned_6213, ptr nocapture %stack) {
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
  %returnAddress_188 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_188(%Pos %returned_6213, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_5518_clause_195(ptr %closure, %Pos %exc_8_20_47_211_5521, %Pos %msg_9_21_48_212_5695, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_5541 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_198 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_5541)
  %k_11_23_50_214_5707 = extractvalue <{ ptr, ptr }> %pair_198, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_5707, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_5707, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_5707, i64 40
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
  %stack_199 = extractvalue <{ ptr, ptr }> %pair_198, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_91, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_5521.elt = extractvalue %Pos %exc_8_20_47_211_5521, 0
  store i64 %exc_8_20_47_211_5521.elt, ptr %environment.i, align 8, !noalias !0
  %environment_201.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_5521.elt2 = extractvalue %Pos %exc_8_20_47_211_5521, 1
  store ptr %exc_8_20_47_211_5521.elt2, ptr %environment_201.repack1, align 8, !noalias !0
  %msg_9_21_48_212_5695_pointer_205 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_5695.elt = extractvalue %Pos %msg_9_21_48_212_5695, 0
  store i64 %msg_9_21_48_212_5695.elt, ptr %msg_9_21_48_212_5695_pointer_205, align 8, !noalias !0
  %msg_9_21_48_212_5695_pointer_205.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_5695.elt4 = extractvalue %Pos %msg_9_21_48_212_5695, 1
  store ptr %msg_9_21_48_212_5695.elt4, ptr %msg_9_21_48_212_5695_pointer_205.repack3, align 8, !noalias !0
  %make_6214 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_199, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_199, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_207 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_207(%Pos %make_6214, ptr %stack_199)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_214(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_222(ptr nocapture readonly %environment) {
entry:
  %tmp_5962_221.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5962_221.unpack2 = load ptr, ptr %tmp_5962_221.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5962_221.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5962_221.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5962_221.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5962_221.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5962_221.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5962_221.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_218(i64 %v_coe_4049_6_28_55_219_5555, ptr %stack) {
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
  store ptr @eraser_222, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_4049_6_28_55_219_5555, ptr %environment.i, align 8, !noalias !0
  %environment_220.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_220.repack1, align 8, !noalias !0
  %make_6216 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_226 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_226(%Pos %make_6216, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_5691(i64 %index_7_34_198_5636, i64 %acc_8_35_199_5690, ptr %p_8_9_5385, %Pos %v_r_3043_30_194_5531, i64 %tmp_5960, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_3043_30_194_5531, 1
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
  store i64 %index_7_34_198_5636, ptr %common.ret.op.i, align 4, !noalias !0
  %acc_8_35_199_5690_pointer_178 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %acc_8_35_199_5690, ptr %acc_8_35_199_5690_pointer_178, align 4, !noalias !0
  %p_8_9_5385_pointer_179 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %p_8_9_5385, ptr %p_8_9_5385_pointer_179, align 8, !noalias !0
  %v_r_3043_30_194_5531_pointer_180 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %v_r_3043_30_194_5531.elt = extractvalue %Pos %v_r_3043_30_194_5531, 0
  store i64 %v_r_3043_30_194_5531.elt, ptr %v_r_3043_30_194_5531_pointer_180, align 8, !noalias !0
  %v_r_3043_30_194_5531_pointer_180.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %object.i3, ptr %v_r_3043_30_194_5531_pointer_180.repack1, align 8, !noalias !0
  %tmp_5960_pointer_181 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_5960, ptr %tmp_5960_pointer_181, align 4, !noalias !0
  %returnAddress_pointer_182 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_183 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_184 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_112, ptr %returnAddress_pointer_182, align 8, !noalias !0
  store ptr @sharer_157, ptr %sharer_pointer_183, align 8, !noalias !0
  store ptr @eraser_169, ptr %eraser_pointer_184, align 8, !noalias !0
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
  %sharer_pointer_193 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_194 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_186, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_76, ptr %sharer_pointer_193, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_194, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_214, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_5518 = insertvalue %Neg { ptr @vtable_210, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_231 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_232 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_218, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_231, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_232, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_3043_30_194_5531, i64 %index_7_34_198_5636, %Neg %Exception_7_19_46_210_5518, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_5449_clause_233(ptr %closure, %Pos %exception_10_107_134_298_6217, %Pos %msg_11_108_135_299_6218, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_5385 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_6217, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_6218, 1
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
  %pair_236 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_5385)
  %k_13_14_4_5878 = extractvalue <{ ptr, ptr }> %pair_236, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_5878, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_5878, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5878, i64 40
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
  %stack_237 = extractvalue <{ ptr, ptr }> %pair_236, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_237, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_237, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_238 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_238(%Pos { i64 10, ptr null }, ptr %stack_237)
  ret void
}

define tailcc void @returnAddress_252(i64 %v_coe_4054_22_131_158_322_5439, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_4054_22_131_158_322_5439, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_253 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_253(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_264(i64 %v_r_3248_1_9_20_129_156_320_5553, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_3248_1_9_20_129_156_320_5553
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_265 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_265(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_247(i64 %v_r_3247_3_14_123_150_314_5622, ptr %stack) {
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
  %p_8_9_5385 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_3043_30_194_5531_pointer_250 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_3043_30_194_5531.unpack = load i64, ptr %v_r_3043_30_194_5531_pointer_250, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_3043_30_194_5531.unpack, 0
  %v_r_3043_30_194_5531.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_3043_30_194_5531.unpack2 = load ptr, ptr %v_r_3043_30_194_5531.elt1, align 8, !noalias !0
  %v_r_3043_30_194_55313 = insertvalue %Pos %0, ptr %v_r_3043_30_194_5531.unpack2, 1
  %tmp_5960_pointer_251 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5960 = load i64, ptr %tmp_5960_pointer_251, align 4, !noalias !0
  %z.i = icmp eq i64 %v_r_3247_3_14_123_150_314_5622, 45
  %isInside.not.i = icmp ugt ptr %tmp_5960_pointer_251, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %tmp_5960_pointer_251, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_258 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_259 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_252, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_258, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_259, align 8, !noalias !0
  br i1 %z.i, label %label_272, label %label_263

label_263:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_5691(i64 0, i64 0, ptr %p_8_9_5385, %Pos %v_r_3043_30_194_55313, i64 %tmp_5960, ptr nonnull %stack)
  ret void

label_272:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_272
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

stackAllocate.exit35:                             ; preds = %label_272, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_272 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_272 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_270 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_271 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_264, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_270, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_271, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_5691(i64 1, i64 0, ptr %p_8_9_5385, %Pos %v_r_3043_30_194_55313, i64 %tmp_5960, ptr nonnull %stack)
  ret void
}

define void @sharer_276(ptr %stackPointer) {
entry:
  %v_r_3043_30_194_5531_274.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_3043_30_194_5531_274.unpack2 = load ptr, ptr %v_r_3043_30_194_5531_274.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3043_30_194_5531_274.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3043_30_194_5531_274.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_3043_30_194_5531_274.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_284(ptr %stackPointer) {
entry:
  %v_r_3043_30_194_5531_282.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_3043_30_194_5531_282.unpack2 = load ptr, ptr %v_r_3043_30_194_5531_282.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3043_30_194_5531_282.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3043_30_194_5531_282.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3043_30_194_5531_282.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3043_30_194_5531_282.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3043_30_194_5531_282.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3043_30_194_5531_282.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_109(%Pos %v_r_3043_30_194_5531, ptr %stack) {
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
  %p_8_9_5385 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_214, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_5385, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_3043_30_194_5531, 1
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
  store ptr %p_8_9_5385, ptr %common.ret.op.i, align 8, !noalias !0
  %v_r_3043_30_194_5531_pointer_291 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_r_3043_30_194_5531.elt = extractvalue %Pos %v_r_3043_30_194_5531, 0
  store i64 %v_r_3043_30_194_5531.elt, ptr %v_r_3043_30_194_5531_pointer_291, align 8, !noalias !0
  %v_r_3043_30_194_5531_pointer_291.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i3, ptr %v_r_3043_30_194_5531_pointer_291.repack1, align 8, !noalias !0
  %tmp_5960_pointer_292 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 48, ptr %tmp_5960_pointer_292, align 4, !noalias !0
  %returnAddress_pointer_293 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_294 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_295 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_247, ptr %returnAddress_pointer_293, align 8, !noalias !0
  store ptr @sharer_276, ptr %sharer_pointer_294, align 8, !noalias !0
  store ptr @eraser_284, ptr %eraser_pointer_295, align 8, !noalias !0
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
  store i64 %v_r_3043_30_194_5531.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_1877.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_1877.repack1.i, align 8, !noalias !0
  %index_2107_pointer_1879.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_1879.i, align 4, !noalias !0
  %Exception_2362_pointer_1880.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_241, ptr %Exception_2362_pointer_1880.i, align 8, !noalias !0
  %Exception_2362_pointer_1880.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_1880.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_1881.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_1882.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_1883.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_1843, ptr %returnAddress_pointer_1881.i, align 8, !noalias !0
  store ptr @sharer_1864, ptr %sharer_pointer_1882.i, align 8, !noalias !0
  store ptr @eraser_1872, ptr %eraser_pointer_1883.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_3043_30_194_5531)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1887.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1887.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_297(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_301(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_106(%Pos %v_r_3042_24_188_5463, ptr %stack) {
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
  %p_8_9_5385 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_5385, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_307 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_308 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_109, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_297, ptr %sharer_pointer_307, align 8, !noalias !0
  store ptr @eraser_301, ptr %eraser_pointer_308, align 8, !noalias !0
  %tag_309 = extractvalue %Pos %v_r_3042_24_188_5463, 0
  switch i64 %tag_309, label %label_311 [
    i64 0, label %label_315
    i64 1, label %label_321
  ]

label_311:                                        ; preds = %stackAllocate.exit
  ret void

label_315:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_6233 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_6233.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_312 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_312(%Pos %utf8StringLiteral_6233, ptr nonnull %stack)
  ret void

label_321:                                        ; preds = %stackAllocate.exit
  %fields_310 = extractvalue %Pos %v_r_3042_24_188_5463, 1
  %environment.i = getelementptr i8, ptr %fields_310, i64 16
  %v_y_3876_8_29_193_5696.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3876_8_29_193_5696.elt1 = getelementptr i8, ptr %fields_310, i64 24
  %v_y_3876_8_29_193_5696.unpack2 = load ptr, ptr %v_y_3876_8_29_193_5696.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3876_8_29_193_5696.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_321
  %referenceCount.i.i = load i64, ptr %v_y_3876_8_29_193_5696.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3876_8_29_193_5696.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_321
  %referenceCount.i = load i64, ptr %fields_310, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_310, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_310, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_310)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3876_8_29_193_5696.unpack, 0
  %v_y_3876_8_29_193_56963 = insertvalue %Pos %0, ptr %v_y_3876_8_29_193_5696.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_318 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_318(%Pos %v_y_3876_8_29_193_56963, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_103(%Pos %v_r_3041_13_177_5510, ptr %stack) {
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
  %p_8_9_5385 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_5385, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_327 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_328 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_106, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_297, ptr %sharer_pointer_327, align 8, !noalias !0
  store ptr @eraser_301, ptr %eraser_pointer_328, align 8, !noalias !0
  %tag_329 = extractvalue %Pos %v_r_3041_13_177_5510, 0
  switch i64 %tag_329, label %label_331 [
    i64 0, label %label_336
    i64 1, label %label_348
  ]

label_331:                                        ; preds = %stackAllocate.exit
  ret void

label_336:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_5385, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_109, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_297, ptr %sharer_pointer_327, align 8, !noalias !0
  store ptr @eraser_301, ptr %eraser_pointer_328, align 8, !noalias !0
  %utf8StringLiteral_6233.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_6233.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_312.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_312.i(%Pos %utf8StringLiteral_6233.i, ptr nonnull %stack)
  ret void

label_348:                                        ; preds = %stackAllocate.exit
  %fields_330 = extractvalue %Pos %v_r_3041_13_177_5510, 1
  %environment.i6 = getelementptr i8, ptr %fields_330, i64 16
  %v_y_3385_10_21_185_5507.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_3385_10_21_185_5507.elt1 = getelementptr i8, ptr %fields_330, i64 24
  %v_y_3385_10_21_185_5507.unpack2 = load ptr, ptr %v_y_3385_10_21_185_5507.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3385_10_21_185_5507.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_348
  %referenceCount.i.i = load i64, ptr %v_y_3385_10_21_185_5507.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3385_10_21_185_5507.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_348
  %referenceCount.i = load i64, ptr %fields_330, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_330, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_330, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_330)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_222, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_3385_10_21_185_5507.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_341.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_3385_10_21_185_5507.unpack2, ptr %environment_341.repack4, align 8, !noalias !0
  %make_6235 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_345 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_345(%Pos %make_6235, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2856(ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_68 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_69 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_68, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_69, align 8, !noalias !0
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
  %sharer_pointer_82 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_83 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_71, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_76, ptr %sharer_pointer_82, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_83, align 8, !noalias !0
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
  %returnAddress_pointer_353 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_354 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_355 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_103, ptr %returnAddress_pointer_353, align 8, !noalias !0
  store ptr @sharer_297, ptr %sharer_pointer_354, align 8, !noalias !0
  store ptr @eraser_301, ptr %eraser_pointer_355, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_101.i, label %label_97.i

label_97.i:                                       ; preds = %stackAllocate.exit46, %label_97.i
  %acc_3_3_5_169_5458.tr8.i = phi %Pos [ %make_6188.i, %label_97.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_5617.tr7.i = phi i64 [ %z.i5.i, %label_97.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_5617.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_5617.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_91, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_6185.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_6185.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_88.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_6185.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_6185.elt2.i, ptr %environment_88.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_5458_pointer_95.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_5458.elt.i = extractvalue %Pos %acc_3_3_5_169_5458.tr8.i, 0
  store i64 %acc_3_3_5_169_5458.elt.i, ptr %acc_3_3_5_169_5458_pointer_95.i, align 8, !noalias !0
  %acc_3_3_5_169_5458_pointer_95.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_5458.elt4.i = extractvalue %Pos %acc_3_3_5_169_5458.tr8.i, 1
  store ptr %acc_3_3_5_169_5458.elt4.i, ptr %acc_3_3_5_169_5458_pointer_95.repack3.i, align 8, !noalias !0
  %make_6188.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_5617.tr7.i, 2
  br i1 %z.i.i, label %label_101.i.loopexit, label %label_97.i

label_101.i.loopexit:                             ; preds = %label_97.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_101.i

label_101.i:                                      ; preds = %label_101.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_101.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_101.i.loopexit ]
  %acc_3_3_5_169_5458.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_6188.i, %label_101.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_98.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_98.i(%Pos %acc_3_3_5_169_5458.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @loop_5_9_4455(i64 %i_6_10_4464, %Pos %tmp_5988, ptr %stack) local_unnamed_addr {
entry:
  %switch.not.not20 = icmp sgt i64 %i_6_10_4464, -1
  %.pre = extractvalue %Pos %tmp_5988, 1
  br i1 %switch.not.not20, label %label_363, label %label_365.lr.ph

label_365.lr.ph:                                  ; preds = %entry
  %isNull.i.i = icmp eq ptr %.pre, null
  br label %label_365

label_363:                                        ; preds = %erasePositive.exit, %entry
  %isNull.i.i7 = icmp eq ptr %.pre, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %label_363
  %referenceCount.i.i9 = load i64, ptr %.pre, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %.pre, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %.pre, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %.pre, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %.pre)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %label_363, %decr.i.i11, %free.i.i13
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_360 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_360(%Pos zeroinitializer, ptr %stack)
  ret void

label_365:                                        ; preds = %label_365.lr.ph, %erasePositive.exit
  %i_6_10_4464.tr21 = phi i64 [ %i_6_10_4464, %label_365.lr.ph ], [ %z.i19, %erasePositive.exit ]
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_365
  %referenceCount.i.i = load i64, ptr %.pre, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %.pre, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_365, %next.i.i
  %z.i18 = tail call %Pos @c_array_set(%Pos %tmp_5988, i64 %i_6_10_4464.tr21, %Pos { i64 1, ptr null })
  %object.i1 = extractvalue %Pos %z.i18, 1
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i2, label %erasePositive.exit, label %next.i.i3

next.i.i3:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i4, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i3
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, -1
  store i64 %referenceCount.1.i.i5, ptr %object.i1, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i3
  %objectEraser.i.i = getelementptr i8, ptr %object.i1, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i1, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i1)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %z.i19 = add nuw nsw i64 %i_6_10_4464.tr21, 1
  %switch.not.not = icmp sgt i64 %i_6_10_4464.tr21, -2
  br i1 %switch.not.not, label %label_363, label %label_365
}

define tailcc void @returnAddress_370(%Pos %returnValue_371, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5988.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5988.unpack2 = load ptr, ptr %tmp_5988.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5988.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5988.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5988.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5988.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5988.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5988.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_374 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_374(%Pos %returnValue_371, ptr nonnull %stack)
  ret void
}

define void @sharer_378(ptr %stackPointer) {
entry:
  %tmp_5988_377.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_5988_377.unpack2 = load ptr, ptr %tmp_5988_377.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5988_377.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5988_377.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5988_377.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_382(ptr %stackPointer) {
entry:
  %tmp_5988_381.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %tmp_5988_381.unpack2 = load ptr, ptr %tmp_5988_381.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5988_381.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5988_381.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5988_381.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5988_381.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5988_381.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5988_381.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_5_9_4470(i64 %i_6_10_4479, %Pos %tmp_5891, ptr %stack) local_unnamed_addr {
entry:
  %switch.not.not20 = icmp sgt i64 %i_6_10_4479, -1
  %.pre = extractvalue %Pos %tmp_5891, 1
  br i1 %switch.not.not20, label %label_397, label %label_399.lr.ph

label_399.lr.ph:                                  ; preds = %entry
  %isNull.i.i = icmp eq ptr %.pre, null
  br label %label_399

label_397:                                        ; preds = %erasePositive.exit, %entry
  %isNull.i.i7 = icmp eq ptr %.pre, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %label_397
  %referenceCount.i.i9 = load i64, ptr %.pre, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %.pre, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %.pre, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %.pre, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %.pre)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %label_397, %decr.i.i11, %free.i.i13
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

label_399:                                        ; preds = %label_399.lr.ph, %erasePositive.exit
  %i_6_10_4479.tr21 = phi i64 [ %i_6_10_4479, %label_399.lr.ph ], [ %z.i19, %erasePositive.exit ]
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_399
  %referenceCount.i.i = load i64, ptr %.pre, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %.pre, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_399, %next.i.i
  %z.i18 = tail call %Pos @c_array_set(%Pos %tmp_5891, i64 %i_6_10_4479.tr21, %Pos { i64 1, ptr null })
  %object.i1 = extractvalue %Pos %z.i18, 1
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i2, label %erasePositive.exit, label %next.i.i3

next.i.i3:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i4, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i3
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, -1
  store i64 %referenceCount.1.i.i5, ptr %object.i1, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i3
  %objectEraser.i.i = getelementptr i8, ptr %object.i1, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i1, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i1)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %z.i19 = add nuw nsw i64 %i_6_10_4479.tr21, 1
  %switch.not.not = icmp sgt i64 %i_6_10_4479.tr21, -2
  br i1 %switch.not.not, label %label_397, label %label_399
}

define tailcc void @returnAddress_405(%Pos %returnValue_406, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5891.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5891.unpack2 = load ptr, ptr %tmp_5891.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5891.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5891.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5891.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5891.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5891.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5891.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_409 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_409(%Pos %returnValue_406, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_9_4485(i64 %i_6_10_4494, %Pos %tmp_5895, ptr %stack) local_unnamed_addr {
entry:
  %switch.not.not20 = icmp sgt i64 %i_6_10_4494, -1
  %.pre = extractvalue %Pos %tmp_5895, 1
  br i1 %switch.not.not20, label %label_426, label %label_428.lr.ph

label_428.lr.ph:                                  ; preds = %entry
  %isNull.i.i = icmp eq ptr %.pre, null
  br label %label_428

label_426:                                        ; preds = %erasePositive.exit, %entry
  %isNull.i.i7 = icmp eq ptr %.pre, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %label_426
  %referenceCount.i.i9 = load i64, ptr %.pre, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %.pre, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %.pre, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %.pre, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %.pre)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %label_426, %decr.i.i11, %free.i.i13
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_423 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_423(%Pos zeroinitializer, ptr %stack)
  ret void

label_428:                                        ; preds = %label_428.lr.ph, %erasePositive.exit
  %i_6_10_4494.tr21 = phi i64 [ %i_6_10_4494, %label_428.lr.ph ], [ %z.i19, %erasePositive.exit ]
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_428
  %referenceCount.i.i = load i64, ptr %.pre, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %.pre, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_428, %next.i.i
  %z.i18 = tail call %Pos @c_array_set(%Pos %tmp_5895, i64 %i_6_10_4494.tr21, %Pos { i64 1, ptr null })
  %object.i1 = extractvalue %Pos %z.i18, 1
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i2, label %erasePositive.exit, label %next.i.i3

next.i.i3:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i4, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i3
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, -1
  store i64 %referenceCount.1.i.i5, ptr %object.i1, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i3
  %objectEraser.i.i = getelementptr i8, ptr %object.i1, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i1, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i1)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %z.i19 = add nuw nsw i64 %i_6_10_4494.tr21, 1
  %switch.not.not = icmp sgt i64 %i_6_10_4494.tr21, -2
  br i1 %switch.not.not, label %label_426, label %label_428
}

define tailcc void @returnAddress_435(%Pos %returnValue_436, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5895.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5895.unpack2 = load ptr, ptr %tmp_5895.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5895.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5895.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5895.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5895.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5895.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5895.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_439 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_439(%Pos %returnValue_436, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_9_4500(i64 %i_6_10_4509, %Pos %tmp_5899, %Pos %tmp_5900, ptr %stack) local_unnamed_addr {
entry:
  %switch.not.not38 = icmp sgt i64 %i_6_10_4509, -1
  %.pre = extractvalue %Pos %tmp_5900, 1
  br i1 %switch.not.not38, label %label_456, label %label_457.lr.ph

label_457.lr.ph:                                  ; preds = %entry
  %isNull.i.i2 = icmp eq ptr %.pre, null
  %object.i = extractvalue %Pos %tmp_5899, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br label %label_457

label_456:                                        ; preds = %erasePositive.exit, %entry
  %isNull.i.i25 = icmp eq ptr %.pre, null
  br i1 %isNull.i.i25, label %erasePositive.exit35, label %next.i.i26

next.i.i26:                                       ; preds = %label_456
  %referenceCount.i.i27 = load i64, ptr %.pre, align 4
  %cond.i.i28 = icmp eq i64 %referenceCount.i.i27, 0
  br i1 %cond.i.i28, label %free.i.i31, label %decr.i.i29

decr.i.i29:                                       ; preds = %next.i.i26
  %referenceCount.1.i.i30 = add i64 %referenceCount.i.i27, -1
  store i64 %referenceCount.1.i.i30, ptr %.pre, align 4
  br label %erasePositive.exit35

free.i.i31:                                       ; preds = %next.i.i26
  %objectEraser.i.i32 = getelementptr i8, ptr %.pre, i64 8
  %eraser.i.i33 = load ptr, ptr %objectEraser.i.i32, align 8
  %environment.i.i.i34 = getelementptr i8, ptr %.pre, i64 16
  tail call void %eraser.i.i33(ptr %environment.i.i.i34)
  tail call void @free(ptr nonnull %.pre)
  br label %erasePositive.exit35

erasePositive.exit35:                             ; preds = %label_456, %decr.i.i29, %free.i.i31
  %object.i12 = extractvalue %Pos %tmp_5899, 1
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
  %returnAddress_453 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_453(%Pos zeroinitializer, ptr %stack)
  ret void

label_457:                                        ; preds = %label_457.lr.ph, %erasePositive.exit
  %i_6_10_4509.tr39 = phi i64 [ %i_6_10_4509, %label_457.lr.ph ], [ %z.i37, %erasePositive.exit ]
  br i1 %isNull.i.i2, label %sharePositive.exit6, label %next.i.i3

next.i.i3:                                        ; preds = %label_457
  %referenceCount.i.i4 = load i64, ptr %.pre, align 4
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, 1
  store i64 %referenceCount.1.i.i5, ptr %.pre, align 4
  br label %sharePositive.exit6

sharePositive.exit6:                              ; preds = %label_457, %next.i.i3
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit6
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit6, %next.i.i
  %z.i36 = tail call %Pos @c_array_set(%Pos %tmp_5900, i64 %i_6_10_4509.tr39, %Pos %tmp_5899)
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
  %z.i37 = add nuw nsw i64 %i_6_10_4509.tr39, 1
  %switch.not.not = icmp sgt i64 %i_6_10_4509.tr39, -2
  br i1 %switch.not.not, label %label_456, label %label_457
}

define tailcc void @returnAddress_465(%Pos %returnValue_466, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5900.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5900.unpack2 = load ptr, ptr %tmp_5900.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5900.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5900.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5900.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5900.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5900.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5900.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_469 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_469(%Pos %returnValue_466, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_480(%Pos %returned_6045, ptr nocapture %stack) {
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
  %returnAddress_482 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_482(%Pos %returned_6045, ptr %rest.i)
  ret void
}

define tailcc void @returnAddress_527(%Pos %__8_4642, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_530 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_530, align 4, !noalias !0
  %i_6_4639_pointer_531 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_531, align 4, !noalias !0
  %p_4194_pointer_532 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_532, align 8, !noalias !0
  %queenRows_2864_pointer_533 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_533, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_534 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_534, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_535 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_535, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_536 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_536, align 4, !noalias !0
  %object.i = extractvalue %Pos %__8_4642, 1
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
  %0 = insertvalue %Reference poison, ptr %freeMaxs_2862.unpack, 0
  %freeMaxs_286212 = insertvalue %Reference %0, i64 %freeMaxs_2862.unpack11, 1
  %1 = insertvalue %Reference poison, ptr %freeMins_2863.unpack, 0
  %freeMins_28639 = insertvalue %Reference %1, i64 %freeMins_2863.unpack8, 1
  %2 = insertvalue %Reference poison, ptr %queenRows_2864.unpack, 0
  %queenRows_28646 = insertvalue %Reference %2, i64 %queenRows_2864.unpack5, 1
  %3 = insertvalue %Reference poison, ptr %freeRows_2861.unpack, 0
  %freeRows_28613 = insertvalue %Reference %3, i64 %freeRows_2861.unpack2, 1
  %z.i = add i64 %i_6_4639, 1
  musttail call tailcc void @loop_5_4636(i64 %z.i, %Reference %freeRows_28613, i64 %c_2872, ptr %p_4194, %Reference %queenRows_28646, %Reference %freeMins_28639, %Reference %freeMaxs_286212, i64 %n_2854, ptr nonnull %stack)
  ret void
}

define void @sharer_545(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -120
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_563(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -120
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -104
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_678(%Pos %v_r_2995_11_77_4684, ptr %stack) {
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
  %c_2872 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %i_6_4639_pointer_681 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_681, align 4, !noalias !0
  %n_2854_pointer_682 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_682, align 4, !noalias !0
  %0 = xor i64 %i_6_4639, -1
  %z.i = add i64 %c_2872, %0
  %z.i7 = add i64 %z.i, %n_2854
  %z.i8 = tail call %Pos @c_array_set(%Pos %v_r_2995_11_77_4684, i64 %z.i7, %Pos { i64 1, ptr null })
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_684 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_684(%Pos %z.i8, ptr %stack)
  ret void
}

define void @sharer_690(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_698(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -32
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_671(%Pos %v_r_2993_7_73_4664, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %c_2872 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %n_2854_pointer_674 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %n_2854 = load i64, ptr %n_2854_pointer_674, align 4, !noalias !0
  %i_6_4639_pointer_675 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_675, align 4, !noalias !0
  %freeMins_2863_pointer_676 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_676, align 8, !noalias !0
  %freeMins_2863.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %freeMins_2863.unpack2 = load i64, ptr %freeMins_2863.elt1, align 8, !noalias !0
  %z.i = add i64 %i_6_4639, %c_2872
  %z.i19 = tail call %Pos @c_array_set(%Pos %v_r_2993_7_73_4664, i64 %z.i, %Pos { i64 1, ptr null })
  %object.i = extractvalue %Pos %z.i19, 1
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
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 48
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i22
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 48
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i23 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i23, i64 48
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i2935 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i22, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i23, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %c_2872, ptr %common.ret.op.i, align 4, !noalias !0
  %i_6_4639_pointer_705 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %i_6_4639, ptr %i_6_4639_pointer_705, align 4, !noalias !0
  %n_2854_pointer_706 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %n_2854, ptr %n_2854_pointer_706, align 4, !noalias !0
  %returnAddress_pointer_707 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %sharer_pointer_708 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %eraser_pointer_709 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr @returnAddress_678, ptr %returnAddress_pointer_707, align 8, !noalias !0
  store ptr @sharer_690, ptr %sharer_pointer_708, align 8, !noalias !0
  store ptr @eraser_698, ptr %eraser_pointer_709, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeMins_2863.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i24 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i25 = load ptr, ptr %base_pointer.i24, align 8
  %varPointer.i = getelementptr i8, ptr %base.i25, i64 %freeMins_2863.unpack2
  %freeMins_2863_old_711.elt4 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeMins_2863_old_711.unpack5 = load ptr, ptr %freeMins_2863_old_711.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeMins_2863_old_711.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeMins_2863_old_711.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeMins_2863_old_711.unpack5, align 4
  %get_6081.unpack8.pre = load ptr, ptr %freeMins_2863_old_711.elt4, align 8, !noalias !0
  %stackPointer.i27.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i29.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i29 = phi ptr [ %limit.i2935, %stackAllocate.exit ], [ %limit.i29.pre, %next.i.i ]
  %stackPointer.i27 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i27.pre, %next.i.i ]
  %get_6081.unpack8 = phi ptr [ null, %stackAllocate.exit ], [ %get_6081.unpack8.pre, %next.i.i ]
  %get_6081.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6081.unpack, 0
  %get_60819 = insertvalue %Pos %0, ptr %get_6081.unpack8, 1
  %isInside.i30 = icmp ule ptr %stackPointer.i27, %limit.i29
  tail call void @llvm.assume(i1 %isInside.i30)
  %newStackPointer.i31 = getelementptr i8, ptr %stackPointer.i27, i64 -24
  store ptr %newStackPointer.i31, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_712 = load ptr, ptr %newStackPointer.i31, align 8, !noalias !0
  musttail call tailcc void %returnAddress_712(%Pos %get_60819, ptr nonnull %stack)
  ret void
}

define void @sharer_719(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_729(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_663(%Pos %v_r_2991_4_70_4649, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %c_2872 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %i_6_4639_pointer_666 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_666, align 4, !noalias !0
  %freeMins_2863_pointer_667 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_667, align 8, !noalias !0
  %freeMins_2863.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack2 = load i64, ptr %freeMins_2863.elt1, align 8, !noalias !0
  %freeMaxs_2862_pointer_668 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_668, align 8, !noalias !0
  %freeMaxs_2862.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack5 = load i64, ptr %freeMaxs_2862.elt4, align 8, !noalias !0
  %n_2854_pointer_669 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_669, align 4, !noalias !0
  %z.i = tail call %Pos @c_array_set(%Pos %v_r_2991_4_70_4649, i64 %i_6_4639, %Pos { i64 1, ptr null })
  %object.i = extractvalue %Pos %z.i, 1
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
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 64
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i26
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
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
  %newStackPointer.i27 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i27, i64 64
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i3339 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i26, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i27, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %c_2872, ptr %common.ret.op.i, align 4, !noalias !0
  %n_2854_pointer_737 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %n_2854, ptr %n_2854_pointer_737, align 4, !noalias !0
  %i_6_4639_pointer_738 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_6_4639, ptr %i_6_4639_pointer_738, align 4, !noalias !0
  %freeMins_2863_pointer_739 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_739, align 8, !noalias !0
  %freeMins_2863_pointer_739.repack7 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %freeMins_2863.unpack2, ptr %freeMins_2863_pointer_739.repack7, align 8, !noalias !0
  %returnAddress_pointer_740 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_741 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_742 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_671, ptr %returnAddress_pointer_740, align 8, !noalias !0
  store ptr @sharer_719, ptr %sharer_pointer_741, align 8, !noalias !0
  store ptr @eraser_729, ptr %eraser_pointer_742, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeMaxs_2862.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i28 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i29 = load ptr, ptr %base_pointer.i28, align 8
  %varPointer.i = getelementptr i8, ptr %base.i29, i64 %freeMaxs_2862.unpack5
  %freeMaxs_2862_old_744.elt9 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeMaxs_2862_old_744.unpack10 = load ptr, ptr %freeMaxs_2862_old_744.elt9, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeMaxs_2862_old_744.unpack10, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeMaxs_2862_old_744.unpack10, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeMaxs_2862_old_744.unpack10, align 4
  %get_6082.unpack13.pre = load ptr, ptr %freeMaxs_2862_old_744.elt9, align 8, !noalias !0
  %stackPointer.i31.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i33.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i33 = phi ptr [ %limit.i3339, %stackAllocate.exit ], [ %limit.i33.pre, %next.i.i ]
  %stackPointer.i31 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i31.pre, %next.i.i ]
  %get_6082.unpack13 = phi ptr [ null, %stackAllocate.exit ], [ %get_6082.unpack13.pre, %next.i.i ]
  %get_6082.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6082.unpack, 0
  %get_608214 = insertvalue %Pos %0, ptr %get_6082.unpack13, 1
  %isInside.i34 = icmp ule ptr %stackPointer.i31, %limit.i33
  tail call void @llvm.assume(i1 %isInside.i34)
  %newStackPointer.i35 = getelementptr i8, ptr %stackPointer.i31, i64 -24
  store ptr %newStackPointer.i35, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_745 = load ptr, ptr %newStackPointer.i35, align 8, !noalias !0
  musttail call tailcc void %returnAddress_745(%Pos %get_608214, ptr nonnull %stack)
  ret void
}

define void @sharer_753(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_765(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_655(%Pos %__69_4724, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_658 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %c_2872 = load i64, ptr %c_2872_pointer_658, align 4, !noalias !0
  %i_6_4639_pointer_659 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_659, align 4, !noalias !0
  %freeMins_2863_pointer_660 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_660, align 8, !noalias !0
  %freeMins_2863.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack5 = load i64, ptr %freeMins_2863.elt4, align 8, !noalias !0
  %freeMaxs_2862_pointer_661 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_661, align 8, !noalias !0
  %freeMaxs_2862.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack8 = load i64, ptr %freeMaxs_2862.elt7, align 8, !noalias !0
  %n_2854_pointer_662 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_662, align 4, !noalias !0
  %object.i = extractvalue %Pos %__69_4724, 1
  %isNull.i.i20 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %entry
  %referenceCount.i.i22 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i31 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 80
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i31
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
  %newStackPointer.i32 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i32, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i3844 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i31, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i32, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %c_2872, ptr %common.ret.op.i, align 4, !noalias !0
  %i_6_4639_pointer_774 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %i_6_4639, ptr %i_6_4639_pointer_774, align 4, !noalias !0
  %freeMins_2863_pointer_775 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_775, align 8, !noalias !0
  %freeMins_2863_pointer_775.repack10 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %freeMins_2863.unpack5, ptr %freeMins_2863_pointer_775.repack10, align 8, !noalias !0
  %freeMaxs_2862_pointer_776 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_776, align 8, !noalias !0
  %freeMaxs_2862_pointer_776.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %freeMaxs_2862.unpack8, ptr %freeMaxs_2862_pointer_776.repack12, align 8, !noalias !0
  %n_2854_pointer_777 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %n_2854, ptr %n_2854_pointer_777, align 4, !noalias !0
  %returnAddress_pointer_778 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_779 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_780 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_663, ptr %returnAddress_pointer_778, align 8, !noalias !0
  store ptr @sharer_753, ptr %sharer_pointer_779, align 8, !noalias !0
  store ptr @eraser_765, ptr %eraser_pointer_780, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeRows_2861.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i33 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i34 = load ptr, ptr %base_pointer.i33, align 8
  %varPointer.i = getelementptr i8, ptr %base.i34, i64 %freeRows_2861.unpack2
  %freeRows_2861_old_782.elt14 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeRows_2861_old_782.unpack15 = load ptr, ptr %freeRows_2861_old_782.elt14, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeRows_2861_old_782.unpack15, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeRows_2861_old_782.unpack15, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeRows_2861_old_782.unpack15, align 4
  %get_6083.unpack18.pre = load ptr, ptr %freeRows_2861_old_782.elt14, align 8, !noalias !0
  %stackPointer.i36.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i38.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i38 = phi ptr [ %limit.i3844, %stackAllocate.exit ], [ %limit.i38.pre, %next.i.i ]
  %stackPointer.i36 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i36.pre, %next.i.i ]
  %get_6083.unpack18 = phi ptr [ null, %stackAllocate.exit ], [ %get_6083.unpack18.pre, %next.i.i ]
  %get_6083.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6083.unpack, 0
  %get_608319 = insertvalue %Pos %0, ptr %get_6083.unpack18, 1
  %isInside.i39 = icmp ule ptr %stackPointer.i36, %limit.i38
  tail call void @llvm.assume(i1 %isInside.i39)
  %newStackPointer.i40 = getelementptr i8, ptr %stackPointer.i36, i64 -24
  store ptr %newStackPointer.i40, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_783 = load ptr, ptr %newStackPointer.i40, align 8, !noalias !0
  musttail call tailcc void %returnAddress_783(%Pos %get_608319, ptr nonnull %stack)
  ret void
}

define void @sharer_792(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_806(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -80
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_646(%Pos %v_r_3016_66_4710, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -80
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_649 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %c_2872 = load i64, ptr %c_2872_pointer_649, align 4, !noalias !0
  %i_6_4639_pointer_650 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_650, align 4, !noalias !0
  %p_4194_pointer_651 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %p_4194 = load ptr, ptr %p_4194_pointer_651, align 8, !noalias !0
  %freeMins_2863_pointer_652 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_652, align 8, !noalias !0
  %freeMins_2863.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack5 = load i64, ptr %freeMins_2863.elt4, align 8, !noalias !0
  %freeMaxs_2862_pointer_653 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_653, align 8, !noalias !0
  %freeMaxs_2862.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack8 = load i64, ptr %freeMaxs_2862.elt7, align 8, !noalias !0
  %n_2854_pointer_654 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_654, align 4, !noalias !0
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
  %newStackPointer.i24 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i24, i64 96
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i28 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i24, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_814.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_814.repack10, align 8, !noalias !0
  %c_2872_pointer_816 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_816, align 4, !noalias !0
  %i_6_4639_pointer_817 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_817, align 4, !noalias !0
  %freeMins_2863_pointer_818 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_818, align 8, !noalias !0
  %freeMins_2863_pointer_818.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %freeMins_2863.unpack5, ptr %freeMins_2863_pointer_818.repack12, align 8, !noalias !0
  %freeMaxs_2862_pointer_819 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_819, align 8, !noalias !0
  %freeMaxs_2862_pointer_819.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %freeMaxs_2862.unpack8, ptr %freeMaxs_2862_pointer_819.repack14, align 8, !noalias !0
  %n_2854_pointer_820 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %n_2854, ptr %n_2854_pointer_820, align 4, !noalias !0
  %returnAddress_pointer_821 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_822 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_823 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_655, ptr %returnAddress_pointer_821, align 8, !noalias !0
  store ptr @sharer_792, ptr %sharer_pointer_822, align 8, !noalias !0
  store ptr @eraser_806, ptr %eraser_pointer_823, align 8, !noalias !0
  %tag_824 = extractvalue %Pos %v_r_3016_66_4710, 0
  switch i64 %tag_824, label %label_826 [
    i64 0, label %label_831
    i64 1, label %label_838
  ]

label_826:                                        ; preds = %stackAllocate.exit
  ret void

label_831:                                        ; preds = %stackAllocate.exit
  %isInside.i29 = icmp ule ptr %nextStackPointer.sink.i, %limit.i28
  tail call void @llvm.assume(i1 %isInside.i29)
  %newStackPointer.i30 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i30, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_828 = load ptr, ptr %newStackPointer.i30, align 8, !noalias !0
  musttail call tailcc void %returnAddress_828(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_838:                                        ; preds = %stackAllocate.exit
  %pair_832 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4194)
  %k_3_68_6085 = extractvalue <{ ptr, ptr }> %pair_832, 0
  %referenceCount.i = load i64, ptr %k_3_68_6085, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %label_838
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_3_68_6085, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %label_838
  %stack_pointer.i = getelementptr i8, ptr %k_3_68_6085, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i31 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i32 = load ptr, ptr %stackPointer_pointer.i31, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i33

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i33

free.i33:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i32, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i32, i64 -8
  %eraser.i.i = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i = load i64, ptr %prompt.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i33
  %newReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i:                                         ; preds = %free.i33
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %stack_833 = extractvalue <{ ptr, ptr }> %pair_832, 1
  %stackPointer_pointer.i34 = getelementptr i8, ptr %stack_833, i64 8
  %stackPointer.i35 = load ptr, ptr %stackPointer_pointer.i34, align 8, !alias.scope !0
  %limit_pointer.i36 = getelementptr i8, ptr %stack_833, i64 24
  %limit.i37 = load ptr, ptr %limit_pointer.i36, align 8, !alias.scope !0
  %isInside.i38 = icmp ule ptr %stackPointer.i35, %limit.i37
  tail call void @llvm.assume(i1 %isInside.i38)
  %newStackPointer.i39 = getelementptr i8, ptr %stackPointer.i35, i64 -24
  store ptr %newStackPointer.i39, ptr %stackPointer_pointer.i34, align 8, !alias.scope !0
  %returnAddress_835 = load ptr, ptr %newStackPointer.i39, align 8, !noalias !0
  musttail call tailcc void %returnAddress_835(%Pos { i64 1, ptr null }, ptr %stack_833)
  ret void
}

define void @sharer_846(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_862(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -88
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_636(%Pos %__64_4723, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_639 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_639, align 4, !noalias !0
  %i_6_4639_pointer_640 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_640, align 4, !noalias !0
  %p_4194_pointer_641 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_641, align 8, !noalias !0
  %queenRows_2864_pointer_642 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_642, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_643 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_643, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_644 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_644, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_645 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_645, align 4, !noalias !0
  %object.i = extractvalue %Pos %__64_4723, 1
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
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 104
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i26
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
  %newStackPointer.i27 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i27, i64 104
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i27, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  %z.i = add i64 %c_2872, 1
  %0 = insertvalue %Reference poison, ptr %freeMaxs_2862.unpack, 0
  %freeMaxs_286212 = insertvalue %Reference %0, i64 %freeMaxs_2862.unpack11, 1
  %1 = insertvalue %Reference poison, ptr %freeMins_2863.unpack, 0
  %freeMins_28639 = insertvalue %Reference %1, i64 %freeMins_2863.unpack8, 1
  %2 = insertvalue %Reference poison, ptr %queenRows_2864.unpack, 0
  %queenRows_28646 = insertvalue %Reference %2, i64 %queenRows_2864.unpack5, 1
  %3 = insertvalue %Reference poison, ptr %freeRows_2861.unpack, 0
  %freeRows_28613 = insertvalue %Reference %3, i64 %freeRows_2861.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_871.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_871.repack13, align 8, !noalias !0
  %c_2872_pointer_873 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_873, align 4, !noalias !0
  %i_6_4639_pointer_874 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_874, align 4, !noalias !0
  %p_4194_pointer_875 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_4194, ptr %p_4194_pointer_875, align 8, !noalias !0
  %freeMins_2863_pointer_876 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_876, align 8, !noalias !0
  %freeMins_2863_pointer_876.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_876.repack15, align 8, !noalias !0
  %freeMaxs_2862_pointer_877 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_877, align 8, !noalias !0
  %freeMaxs_2862_pointer_877.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_877.repack17, align 8, !noalias !0
  %n_2854_pointer_878 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %n_2854, ptr %n_2854_pointer_878, align 4, !noalias !0
  %returnAddress_pointer_879 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %sharer_pointer_880 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %eraser_pointer_881 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr @returnAddress_646, ptr %returnAddress_pointer_879, align 8, !noalias !0
  store ptr @sharer_846, ptr %sharer_pointer_880, align 8, !noalias !0
  store ptr @eraser_862, ptr %eraser_pointer_881, align 8, !noalias !0
  musttail call tailcc void @placeQueen_2873(i64 %z.i, %Reference %freeRows_28613, %Reference %queenRows_28646, %Reference %freeMins_28639, %Reference %freeMaxs_286212, i64 %n_2854, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_625(%Pos %v_r_2995_11_53_4691, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_628 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_628, align 4, !noalias !0
  %i_6_4639_pointer_629 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_629, align 4, !noalias !0
  %p_4194_pointer_630 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_630, align 8, !noalias !0
  %queenRows_2864_pointer_631 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_631, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_632 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_632, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_633 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_633, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_634 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_634, align 4, !noalias !0
  %z.i = sub i64 %c_2872, %i_6_4639
  %z.i26 = add i64 %n_2854, -1
  %z.i27 = add i64 %z.i, %z.i26
  %z.i28 = tail call %Pos @c_array_set(%Pos %v_r_2995_11_53_4691, i64 %z.i27, %Pos zeroinitializer)
  %object.i = extractvalue %Pos %z.i28, 1
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
  %z.i30 = icmp eq i64 %c_2872, %z.i26
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
  %limit.i38 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i33, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i34, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_898.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_898.repack13, align 8, !noalias !0
  %c_2872_pointer_900 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_900, align 4, !noalias !0
  %i_6_4639_pointer_901 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_901, align 4, !noalias !0
  %p_4194_pointer_902 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_4194, ptr %p_4194_pointer_902, align 8, !noalias !0
  %queenRows_2864_pointer_903 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_903, align 8, !noalias !0
  %queenRows_2864_pointer_903.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864_pointer_903.repack15, align 8, !noalias !0
  %freeMins_2863_pointer_904 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_904, align 8, !noalias !0
  %freeMins_2863_pointer_904.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_904.repack17, align 8, !noalias !0
  %freeMaxs_2862_pointer_905 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_905, align 8, !noalias !0
  %freeMaxs_2862_pointer_905.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_905.repack19, align 8, !noalias !0
  %n_2854_pointer_906 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_906, align 4, !noalias !0
  %returnAddress_pointer_907 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_908 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_909 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_636, ptr %returnAddress_pointer_907, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_908, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_909, align 8, !noalias !0
  br i1 %z.i30, label %label_924, label %label_917

label_917:                                        ; preds = %stackAllocate.exit
  %isInside.i39 = icmp ule ptr %nextStackPointer.sink.i, %limit.i38
  tail call void @llvm.assume(i1 %isInside.i39)
  %newStackPointer.i40 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i40, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_914 = load ptr, ptr %newStackPointer.i40, align 8, !noalias !0
  musttail call tailcc void %returnAddress_914(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_924:                                        ; preds = %stackAllocate.exit
  %pair_918 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4194)
  %k_3_63_6088 = extractvalue <{ ptr, ptr }> %pair_918, 0
  %referenceCount.i = load i64, ptr %k_3_63_6088, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %label_924
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %k_3_63_6088, align 4
  br label %eraseResumption.exit

free.i:                                           ; preds = %label_924
  %stack_pointer.i = getelementptr i8, ptr %k_3_63_6088, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i
  %stack.tr.i = phi ptr [ %stack.i, %free.i ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i41 = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i42 = load ptr, ptr %stackPointer_pointer.i41, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i43

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i43

free.i43:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i42, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i42, i64 -8
  %eraser.i.i44 = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i44(ptr %newStackPointer.i.i)
  %referenceCount.i.i45 = load i64, ptr %prompt.i, align 4
  %cond.i.i46 = icmp eq i64 %referenceCount.i.i45, 0
  br i1 %cond.i.i46, label %free.i.i47, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i43
  %newReferenceCount.i.i = add i64 %referenceCount.i.i45, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i47:                                       ; preds = %free.i43
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i47, %decrement.i.i
  %isNull.i = icmp eq ptr %rest.i, null
  br i1 %isNull.i, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i
  %stack_919 = extractvalue <{ ptr, ptr }> %pair_918, 1
  %stackPointer_pointer.i48 = getelementptr i8, ptr %stack_919, i64 8
  %stackPointer.i49 = load ptr, ptr %stackPointer_pointer.i48, align 8, !alias.scope !0
  %limit_pointer.i50 = getelementptr i8, ptr %stack_919, i64 24
  %limit.i51 = load ptr, ptr %limit_pointer.i50, align 8, !alias.scope !0
  %isInside.i52 = icmp ule ptr %stackPointer.i49, %limit.i51
  tail call void @llvm.assume(i1 %isInside.i52)
  %newStackPointer.i53 = getelementptr i8, ptr %stackPointer.i49, i64 -24
  store ptr %newStackPointer.i53, ptr %stackPointer_pointer.i48, align 8, !alias.scope !0
  %returnAddress_921 = load ptr, ptr %newStackPointer.i53, align 8, !noalias !0
  musttail call tailcc void %returnAddress_921(%Pos { i64 1, ptr null }, ptr %stack_919)
  ret void
}

define tailcc void @returnAddress_614(%Pos %v_r_2993_7_49_4709, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_617 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_617, align 4, !noalias !0
  %i_6_4639_pointer_618 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_618, align 4, !noalias !0
  %p_4194_pointer_619 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_619, align 8, !noalias !0
  %queenRows_2864_pointer_620 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_620, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_621 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_621, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_622 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_622, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_623 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_623, align 4, !noalias !0
  %z.i = add i64 %i_6_4639, %c_2872
  %z.i36 = tail call %Pos @c_array_set(%Pos %v_r_2993_7_49_4709, i64 %z.i, %Pos zeroinitializer)
  %object.i = extractvalue %Pos %z.i36, 1
  %isNull.i.i27 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i27, label %erasePositive.exit, label %next.i.i28

next.i.i28:                                       ; preds = %entry
  %referenceCount.i.i29 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i29, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i28
  %referenceCount.1.i.i30 = add i64 %referenceCount.i.i29, -1
  store i64 %referenceCount.1.i.i30, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i28
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i39 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i39
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
  %newStackPointer.i40 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i40, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i4652 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i39, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i40, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_941.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_941.repack13, align 8, !noalias !0
  %c_2872_pointer_943 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_943, align 4, !noalias !0
  %i_6_4639_pointer_944 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_944, align 4, !noalias !0
  %p_4194_pointer_945 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_4194, ptr %p_4194_pointer_945, align 8, !noalias !0
  %queenRows_2864_pointer_946 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_946, align 8, !noalias !0
  %queenRows_2864_pointer_946.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864_pointer_946.repack15, align 8, !noalias !0
  %freeMins_2863_pointer_947 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_947, align 8, !noalias !0
  %freeMins_2863_pointer_947.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_947.repack17, align 8, !noalias !0
  %freeMaxs_2862_pointer_948 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_948, align 8, !noalias !0
  %freeMaxs_2862_pointer_948.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_948.repack19, align 8, !noalias !0
  %n_2854_pointer_949 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_949, align 4, !noalias !0
  %returnAddress_pointer_950 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_951 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_952 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_625, ptr %returnAddress_pointer_950, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_951, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_952, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeMins_2863.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i41 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i42 = load ptr, ptr %base_pointer.i41, align 8
  %varPointer.i = getelementptr i8, ptr %base.i42, i64 %freeMins_2863.unpack8
  %freeMins_2863_old_954.elt21 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeMins_2863_old_954.unpack22 = load ptr, ptr %freeMins_2863_old_954.elt21, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeMins_2863_old_954.unpack22, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeMins_2863_old_954.unpack22, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeMins_2863_old_954.unpack22, align 4
  %get_6090.unpack25.pre = load ptr, ptr %freeMins_2863_old_954.elt21, align 8, !noalias !0
  %stackPointer.i44.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i46.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i46 = phi ptr [ %limit.i4652, %stackAllocate.exit ], [ %limit.i46.pre, %next.i.i ]
  %stackPointer.i44 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i44.pre, %next.i.i ]
  %get_6090.unpack25 = phi ptr [ null, %stackAllocate.exit ], [ %get_6090.unpack25.pre, %next.i.i ]
  %get_6090.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6090.unpack, 0
  %get_609026 = insertvalue %Pos %0, ptr %get_6090.unpack25, 1
  %isInside.i47 = icmp ule ptr %stackPointer.i44, %limit.i46
  tail call void @llvm.assume(i1 %isInside.i47)
  %newStackPointer.i48 = getelementptr i8, ptr %stackPointer.i44, i64 -24
  store ptr %newStackPointer.i48, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_955 = load ptr, ptr %newStackPointer.i48, align 8, !noalias !0
  musttail call tailcc void %returnAddress_955(%Pos %get_609026, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_603(%Pos %v_r_2991_4_46_4699, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_606 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_606, align 4, !noalias !0
  %i_6_4639_pointer_607 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_607, align 4, !noalias !0
  %p_4194_pointer_608 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_608, align 8, !noalias !0
  %queenRows_2864_pointer_609 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_609, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_610 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_610, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_611 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_611, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_612 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_612, align 4, !noalias !0
  %z.i = tail call %Pos @c_array_set(%Pos %v_r_2991_4_46_4699, i64 %i_6_4639, %Pos zeroinitializer)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i27 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i27, label %erasePositive.exit, label %next.i.i28

next.i.i28:                                       ; preds = %entry
  %referenceCount.i.i29 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i29, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i28
  %referenceCount.1.i.i30 = add i64 %referenceCount.i.i29, -1
  store i64 %referenceCount.1.i.i30, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i28
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i38
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
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i4551 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i38, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_974.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_974.repack13, align 8, !noalias !0
  %c_2872_pointer_976 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_976, align 4, !noalias !0
  %i_6_4639_pointer_977 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_977, align 4, !noalias !0
  %p_4194_pointer_978 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_4194, ptr %p_4194_pointer_978, align 8, !noalias !0
  %queenRows_2864_pointer_979 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_979, align 8, !noalias !0
  %queenRows_2864_pointer_979.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864_pointer_979.repack15, align 8, !noalias !0
  %freeMins_2863_pointer_980 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_980, align 8, !noalias !0
  %freeMins_2863_pointer_980.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_980.repack17, align 8, !noalias !0
  %freeMaxs_2862_pointer_981 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_981, align 8, !noalias !0
  %freeMaxs_2862_pointer_981.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_981.repack19, align 8, !noalias !0
  %n_2854_pointer_982 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_982, align 4, !noalias !0
  %returnAddress_pointer_983 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_984 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_985 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_614, ptr %returnAddress_pointer_983, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_984, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_985, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeMaxs_2862.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %freeMaxs_2862.unpack11
  %freeMaxs_2862_old_987.elt21 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeMaxs_2862_old_987.unpack22 = load ptr, ptr %freeMaxs_2862_old_987.elt21, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeMaxs_2862_old_987.unpack22, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeMaxs_2862_old_987.unpack22, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeMaxs_2862_old_987.unpack22, align 4
  %get_6091.unpack25.pre = load ptr, ptr %freeMaxs_2862_old_987.elt21, align 8, !noalias !0
  %stackPointer.i43.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i45.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i45 = phi ptr [ %limit.i4551, %stackAllocate.exit ], [ %limit.i45.pre, %next.i.i ]
  %stackPointer.i43 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i43.pre, %next.i.i ]
  %get_6091.unpack25 = phi ptr [ null, %stackAllocate.exit ], [ %get_6091.unpack25.pre, %next.i.i ]
  %get_6091.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6091.unpack, 0
  %get_609126 = insertvalue %Pos %0, ptr %get_6091.unpack25, 1
  %isInside.i46 = icmp ule ptr %stackPointer.i43, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %stackPointer.i43, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_988 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_988(%Pos %get_609126, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_593(%Pos %v_r_3011_42_4694, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_596 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_596, align 4, !noalias !0
  %i_6_4639_pointer_597 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_597, align 4, !noalias !0
  %p_4194_pointer_598 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_598, align 8, !noalias !0
  %queenRows_2864_pointer_599 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_599, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_600 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_600, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_601 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_601, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_602 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_602, align 4, !noalias !0
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %c_2872, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %z.i = tail call %Pos @c_array_set(%Pos %v_r_3011_42_4694, i64 %i_6_4639, %Pos %boxed2.i)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i27 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i27, label %erasePositive.exit, label %next.i.i28

next.i.i28:                                       ; preds = %entry
  %referenceCount.i.i29 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i29, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i28
  %referenceCount.1.i.i30 = add i64 %referenceCount.i.i29, -1
  store i64 %referenceCount.1.i.i30, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i28
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i38
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
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i4551 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i38, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1007.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1007.repack13, align 8, !noalias !0
  %c_2872_pointer_1009 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_1009, align 4, !noalias !0
  %i_6_4639_pointer_1010 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_1010, align 4, !noalias !0
  %p_4194_pointer_1011 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_4194, ptr %p_4194_pointer_1011, align 8, !noalias !0
  %queenRows_2864_pointer_1012 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1012, align 8, !noalias !0
  %queenRows_2864_pointer_1012.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864_pointer_1012.repack15, align 8, !noalias !0
  %freeMins_2863_pointer_1013 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1013, align 8, !noalias !0
  %freeMins_2863_pointer_1013.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_1013.repack17, align 8, !noalias !0
  %freeMaxs_2862_pointer_1014 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1014, align 8, !noalias !0
  %freeMaxs_2862_pointer_1014.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_1014.repack19, align 8, !noalias !0
  %n_2854_pointer_1015 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_1015, align 4, !noalias !0
  %returnAddress_pointer_1016 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1017 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1018 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_603, ptr %returnAddress_pointer_1016, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_1017, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_1018, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeRows_2861.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %freeRows_2861.unpack2
  %freeRows_2861_old_1020.elt21 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeRows_2861_old_1020.unpack22 = load ptr, ptr %freeRows_2861_old_1020.elt21, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeRows_2861_old_1020.unpack22, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeRows_2861_old_1020.unpack22, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeRows_2861_old_1020.unpack22, align 4
  %get_6092.unpack25.pre = load ptr, ptr %freeRows_2861_old_1020.elt21, align 8, !noalias !0
  %stackPointer.i43.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i45.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i45 = phi ptr [ %limit.i4551, %stackAllocate.exit ], [ %limit.i45.pre, %next.i.i ]
  %stackPointer.i43 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i43.pre, %next.i.i ]
  %get_6092.unpack25 = phi ptr [ null, %stackAllocate.exit ], [ %get_6092.unpack25.pre, %next.i.i ]
  %get_6092.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6092.unpack, 0
  %get_609226 = insertvalue %Pos %0, ptr %get_6092.unpack25, 1
  %isInside.i46 = icmp ule ptr %stackPointer.i43, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %stackPointer.i43, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1021 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1021(%Pos %get_609226, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_517(%Pos %v_r_3010_41_4683, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i39 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i39)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_520 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_520, align 4, !noalias !0
  %i_6_4639_pointer_521 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_521, align 4, !noalias !0
  %p_4194_pointer_522 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_522, align 8, !noalias !0
  %queenRows_2864_pointer_523 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_523, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_524 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_524, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_525 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_525, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_526 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_526, align 4, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  store i64 %freeRows_2861.unpack2, ptr %freeRows_2861.elt1, align 8, !noalias !0
  store i64 %c_2872, ptr %c_2872_pointer_520, align 4, !noalias !0
  store i64 %i_6_4639, ptr %i_6_4639_pointer_521, align 4, !noalias !0
  store ptr %p_4194, ptr %p_4194_pointer_522, align 8, !noalias !0
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_523, align 8, !noalias !0
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864.elt4, align 8, !noalias !0
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_524, align 8, !noalias !0
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863.elt7, align 8, !noalias !0
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_525, align 8, !noalias !0
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  store i64 %n_2854, ptr %n_2854_pointer_526, align 4, !noalias !0
  %sharer_pointer_583 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_584 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_527, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_583, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_584, align 8, !noalias !0
  %tag_585 = extractvalue %Pos %v_r_3010_41_4683, 0
  switch i64 %tag_585, label %label_587 [
    i64 0, label %label_592
    i64 1, label %label_1057
  ]

label_587:                                        ; preds = %stackAllocate.exit
  ret void

label_592:                                        ; preds = %stackAllocate.exit
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %0 = insertvalue %Reference poison, ptr %freeMaxs_2862.unpack, 0
  %freeMaxs_286212.i = insertvalue %Reference %0, i64 %freeMaxs_2862.unpack11, 1
  %1 = insertvalue %Reference poison, ptr %freeMins_2863.unpack, 0
  %freeMins_28639.i = insertvalue %Reference %1, i64 %freeMins_2863.unpack8, 1
  %2 = insertvalue %Reference poison, ptr %queenRows_2864.unpack, 0
  %queenRows_28646.i = insertvalue %Reference %2, i64 %queenRows_2864.unpack5, 1
  %3 = insertvalue %Reference poison, ptr %freeRows_2861.unpack, 0
  %freeRows_28613.i = insertvalue %Reference %3, i64 %freeRows_2861.unpack2, 1
  %z.i.i = add i64 %i_6_4639, 1
  musttail call tailcc void @loop_5_4636(i64 %z.i.i, %Reference %freeRows_28613.i, i64 %c_2872, ptr %p_4194, %Reference %queenRows_28646.i, %Reference %freeMins_28639.i, %Reference %freeMaxs_286212.i, i64 %n_2854, ptr nonnull %stack)
  ret void

label_1057:                                       ; preds = %stackAllocate.exit
  %nextStackPointer.i54 = getelementptr i8, ptr %stackPointer.i, i64 144
  %isInside.not.i55 = icmp ugt ptr %nextStackPointer.i54, %limit.i
  br i1 %isInside.not.i55, label %realloc.i58, label %stackAllocate.exit72

realloc.i58:                                      ; preds = %label_1057
  %base_pointer.i59 = getelementptr i8, ptr %stack, i64 16
  %base.i60 = load ptr, ptr %base_pointer.i59, align 8, !alias.scope !0
  %intStackPointer.i61 = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i62 = ptrtoint ptr %base.i60 to i64
  %size.i63 = sub i64 %intStackPointer.i61, %intBase.i62
  %nextSize.i64 = add i64 %size.i63, 120
  %leadingZeros.i.i65 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i64, i1 false)
  %numBits.i.i66 = sub nuw nsw i64 64, %leadingZeros.i.i65
  %result.i.i67 = shl nuw i64 1, %numBits.i.i66
  %newBase.i68 = tail call ptr @realloc(ptr %base.i60, i64 %result.i.i67)
  %newLimit.i69 = getelementptr i8, ptr %newBase.i68, i64 %result.i.i67
  %newStackPointer.i70 = getelementptr i8, ptr %newBase.i68, i64 %size.i63
  %newNextStackPointer.i71 = getelementptr i8, ptr %newStackPointer.i70, i64 120
  store ptr %newBase.i68, ptr %base_pointer.i59, align 8, !alias.scope !0
  store ptr %newLimit.i69, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit72

stackAllocate.exit72:                             ; preds = %label_1057, %realloc.i58
  %limit.i7884 = phi ptr [ %newLimit.i69, %realloc.i58 ], [ %limit.i, %label_1057 ]
  %nextStackPointer.sink.i56 = phi ptr [ %newNextStackPointer.i71, %realloc.i58 ], [ %nextStackPointer.i54, %label_1057 ]
  %common.ret.op.i57 = phi ptr [ %newStackPointer.i70, %realloc.i58 ], [ %oldStackPointer.i, %label_1057 ]
  store ptr %nextStackPointer.sink.i56, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i57, align 8, !noalias !0
  %stackPointer_1040.repack21 = getelementptr inbounds i8, ptr %common.ret.op.i57, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1040.repack21, align 8, !noalias !0
  %c_2872_pointer_1042 = getelementptr i8, ptr %common.ret.op.i57, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_1042, align 4, !noalias !0
  %i_6_4639_pointer_1043 = getelementptr i8, ptr %common.ret.op.i57, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_1043, align 4, !noalias !0
  %p_4194_pointer_1044 = getelementptr i8, ptr %common.ret.op.i57, i64 32
  store ptr %p_4194, ptr %p_4194_pointer_1044, align 8, !noalias !0
  %queenRows_2864_pointer_1045 = getelementptr i8, ptr %common.ret.op.i57, i64 40
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1045, align 8, !noalias !0
  %queenRows_2864_pointer_1045.repack23 = getelementptr i8, ptr %common.ret.op.i57, i64 48
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864_pointer_1045.repack23, align 8, !noalias !0
  %freeMins_2863_pointer_1046 = getelementptr i8, ptr %common.ret.op.i57, i64 56
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1046, align 8, !noalias !0
  %freeMins_2863_pointer_1046.repack25 = getelementptr i8, ptr %common.ret.op.i57, i64 64
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_1046.repack25, align 8, !noalias !0
  %freeMaxs_2862_pointer_1047 = getelementptr i8, ptr %common.ret.op.i57, i64 72
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1047, align 8, !noalias !0
  %freeMaxs_2862_pointer_1047.repack27 = getelementptr i8, ptr %common.ret.op.i57, i64 80
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_1047.repack27, align 8, !noalias !0
  %n_2854_pointer_1048 = getelementptr i8, ptr %common.ret.op.i57, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_1048, align 4, !noalias !0
  %returnAddress_pointer_1049 = getelementptr i8, ptr %common.ret.op.i57, i64 96
  %sharer_pointer_1050 = getelementptr i8, ptr %common.ret.op.i57, i64 104
  %eraser_pointer_1051 = getelementptr i8, ptr %common.ret.op.i57, i64 112
  store ptr @returnAddress_593, ptr %returnAddress_pointer_1049, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_1050, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_1051, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %queenRows_2864.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i73 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i74 = load ptr, ptr %base_pointer.i73, align 8
  %varPointer.i = getelementptr i8, ptr %base.i74, i64 %queenRows_2864.unpack5
  %queenRows_2864_old_1053.elt29 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %queenRows_2864_old_1053.unpack30 = load ptr, ptr %queenRows_2864_old_1053.elt29, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %queenRows_2864_old_1053.unpack30, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit72
  %referenceCount.i.i = load i64, ptr %queenRows_2864_old_1053.unpack30, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %queenRows_2864_old_1053.unpack30, align 4
  %get_6093.unpack33.pre = load ptr, ptr %queenRows_2864_old_1053.elt29, align 8, !noalias !0
  %stackPointer.i76.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i78.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit72, %next.i.i
  %limit.i78 = phi ptr [ %limit.i7884, %stackAllocate.exit72 ], [ %limit.i78.pre, %next.i.i ]
  %stackPointer.i76 = phi ptr [ %nextStackPointer.sink.i56, %stackAllocate.exit72 ], [ %stackPointer.i76.pre, %next.i.i ]
  %get_6093.unpack33 = phi ptr [ null, %stackAllocate.exit72 ], [ %get_6093.unpack33.pre, %next.i.i ]
  %get_6093.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %4 = insertvalue %Pos poison, i64 %get_6093.unpack, 0
  %get_609334 = insertvalue %Pos %4, ptr %get_6093.unpack33, 1
  %isInside.i79 = icmp ule ptr %stackPointer.i76, %limit.i78
  tail call void @llvm.assume(i1 %isInside.i79)
  %newStackPointer.i80 = getelementptr i8, ptr %stackPointer.i76, i64 -24
  store ptr %newStackPointer.i80, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1054 = load ptr, ptr %newStackPointer.i80, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1054(%Pos %get_609334, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1094(%Pos %v_r_2988_1_37_36_4713, ptr %stack) {
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
  %c_2872 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %i_6_4639_pointer_1097 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_1097, align 4, !noalias !0
  %n_2854_pointer_1098 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1098, align 4, !noalias !0
  %0 = xor i64 %i_6_4639, -1
  %z.i = add i64 %c_2872, %0
  %z.i7 = add i64 %z.i, %n_2854
  %z.i8 = tail call %Pos @c_array_get(%Pos %v_r_2988_1_37_36_4713, i64 %z.i7)
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1099 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1099(%Pos %z.i8, ptr %stack)
  ret void
}

define tailcc void @returnAddress_507(%Pos %v_r_3996_5_36_35_4680, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i31 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  %c_2872_pointer_510 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_510, align 4, !noalias !0
  %i_6_4639_pointer_511 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_511, align 4, !noalias !0
  %freeMins_2863_pointer_514 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_514, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %n_2854_pointer_516 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_516, align 4, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %freeMaxs_2862_pointer_515 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_515, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %queenRows_2864_pointer_513 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_513, align 8, !noalias !0
  %p_4194_pointer_512 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_512, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  store i64 %freeRows_2861.unpack2, ptr %freeRows_2861.elt1, align 8, !noalias !0
  store i64 %c_2872, ptr %c_2872_pointer_510, align 4, !noalias !0
  store i64 %i_6_4639, ptr %i_6_4639_pointer_511, align 4, !noalias !0
  store ptr %p_4194, ptr %p_4194_pointer_512, align 8, !noalias !0
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_513, align 8, !noalias !0
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864.elt4, align 8, !noalias !0
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_514, align 8, !noalias !0
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863.elt7, align 8, !noalias !0
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_515, align 8, !noalias !0
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  store i64 %n_2854, ptr %n_2854_pointer_516, align 4, !noalias !0
  %sharer_pointer_1084 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1085 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_517, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_1084, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_1085, align 8, !noalias !0
  %tag_1086 = extractvalue %Pos %v_r_3996_5_36_35_4680, 0
  switch i64 %tag_1086, label %label_1088 [
    i64 0, label %stackAllocate.exit87
    i64 1, label %label_1120
  ]

label_1088:                                       ; preds = %stackAllocate.exit
  ret void

stackAllocate.exit87:                             ; preds = %stackAllocate.exit
  store i64 %freeRows_2861.unpack2, ptr %freeRows_2861.elt1, align 8, !noalias !0
  store i64 %i_6_4639, ptr %i_6_4639_pointer_511, align 4, !noalias !0
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_513, align 8, !noalias !0
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_514, align 8, !noalias !0
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_515, align 8, !noalias !0
  store i64 %n_2854, ptr %n_2854_pointer_516, align 4, !noalias !0
  store ptr @returnAddress_527, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_1084, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_1085, align 8, !noalias !0
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %0 = insertvalue %Reference poison, ptr %freeRows_2861.unpack, 0
  %freeRows_28613.i = insertvalue %Reference %0, i64 %freeRows_2861.unpack2, 1
  %1 = insertvalue %Reference poison, ptr %queenRows_2864.unpack, 0
  %queenRows_28646.i = insertvalue %Reference %1, i64 %queenRows_2864.unpack5, 1
  %2 = insertvalue %Reference poison, ptr %freeMins_2863.unpack, 0
  %freeMins_28639.i = insertvalue %Reference %2, i64 %freeMins_2863.unpack8, 1
  %3 = insertvalue %Reference poison, ptr %freeMaxs_2862.unpack, 0
  %freeMaxs_286212.i = insertvalue %Reference %3, i64 %freeMaxs_2862.unpack11, 1
  %z.i = add i64 %i_6_4639, 1
  musttail call tailcc void @loop_5_4636(i64 %z.i, %Reference %freeRows_28613.i, i64 %c_2872, ptr %p_4194, %Reference %queenRows_28646.i, %Reference %freeMins_28639.i, %Reference %freeMaxs_286212.i, i64 %n_2854, ptr nonnull %stack)
  ret void

label_1120:                                       ; preds = %stackAllocate.exit
  %nextStackPointer.i46 = getelementptr i8, ptr %stackPointer.i, i64 72
  %isInside.not.i47 = icmp ugt ptr %nextStackPointer.i46, %limit.i
  br i1 %isInside.not.i47, label %realloc.i50, label %stackAllocate.exit64

realloc.i50:                                      ; preds = %label_1120
  %base_pointer.i51 = getelementptr i8, ptr %stack, i64 16
  %base.i52 = load ptr, ptr %base_pointer.i51, align 8, !alias.scope !0
  %intStackPointer.i53 = ptrtoint ptr %oldStackPointer.i to i64
  %intBase.i54 = ptrtoint ptr %base.i52 to i64
  %size.i55 = sub i64 %intStackPointer.i53, %intBase.i54
  %nextSize.i56 = add i64 %size.i55, 48
  %leadingZeros.i.i57 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i56, i1 false)
  %numBits.i.i58 = sub nuw nsw i64 64, %leadingZeros.i.i57
  %result.i.i59 = shl nuw i64 1, %numBits.i.i58
  %newBase.i60 = tail call ptr @realloc(ptr %base.i52, i64 %result.i.i59)
  %newLimit.i61 = getelementptr i8, ptr %newBase.i60, i64 %result.i.i59
  %newStackPointer.i62 = getelementptr i8, ptr %newBase.i60, i64 %size.i55
  %newNextStackPointer.i63 = getelementptr i8, ptr %newStackPointer.i62, i64 48
  store ptr %newBase.i60, ptr %base_pointer.i51, align 8, !alias.scope !0
  store ptr %newLimit.i61, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit64

stackAllocate.exit64:                             ; preds = %label_1120, %realloc.i50
  %limit.i7076 = phi ptr [ %newLimit.i61, %realloc.i50 ], [ %limit.i, %label_1120 ]
  %nextStackPointer.sink.i48 = phi ptr [ %newNextStackPointer.i63, %realloc.i50 ], [ %nextStackPointer.i46, %label_1120 ]
  %common.ret.op.i49 = phi ptr [ %newStackPointer.i62, %realloc.i50 ], [ %oldStackPointer.i, %label_1120 ]
  store ptr %nextStackPointer.sink.i48, ptr %stackPointer_pointer.i, align 8
  store i64 %c_2872, ptr %common.ret.op.i49, align 4, !noalias !0
  %i_6_4639_pointer_1110 = getelementptr i8, ptr %common.ret.op.i49, i64 8
  store i64 %i_6_4639, ptr %i_6_4639_pointer_1110, align 4, !noalias !0
  %n_2854_pointer_1111 = getelementptr i8, ptr %common.ret.op.i49, i64 16
  store i64 %n_2854, ptr %n_2854_pointer_1111, align 4, !noalias !0
  %returnAddress_pointer_1112 = getelementptr i8, ptr %common.ret.op.i49, i64 24
  %sharer_pointer_1113 = getelementptr i8, ptr %common.ret.op.i49, i64 32
  %eraser_pointer_1114 = getelementptr i8, ptr %common.ret.op.i49, i64 40
  store ptr @returnAddress_1094, ptr %returnAddress_pointer_1112, align 8, !noalias !0
  store ptr @sharer_690, ptr %sharer_pointer_1113, align 8, !noalias !0
  store ptr @eraser_698, ptr %eraser_pointer_1114, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeMins_2863.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i65 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i66 = load ptr, ptr %base_pointer.i65, align 8
  %varPointer.i = getelementptr i8, ptr %base.i66, i64 %freeMins_2863.unpack8
  %freeMins_2863_old_1116.elt21 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeMins_2863_old_1116.unpack22 = load ptr, ptr %freeMins_2863_old_1116.elt21, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeMins_2863_old_1116.unpack22, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit64
  %referenceCount.i.i = load i64, ptr %freeMins_2863_old_1116.unpack22, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeMins_2863_old_1116.unpack22, align 4
  %get_6100.unpack25.pre = load ptr, ptr %freeMins_2863_old_1116.elt21, align 8, !noalias !0
  %stackPointer.i68.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i70.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit64, %next.i.i
  %limit.i70 = phi ptr [ %limit.i7076, %stackAllocate.exit64 ], [ %limit.i70.pre, %next.i.i ]
  %stackPointer.i68 = phi ptr [ %nextStackPointer.sink.i48, %stackAllocate.exit64 ], [ %stackPointer.i68.pre, %next.i.i ]
  %get_6100.unpack25 = phi ptr [ null, %stackAllocate.exit64 ], [ %get_6100.unpack25.pre, %next.i.i ]
  %get_6100.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %4 = insertvalue %Pos poison, i64 %get_6100.unpack, 0
  %get_610026 = insertvalue %Pos %4, ptr %get_6100.unpack25, 1
  %isInside.i71 = icmp ule ptr %stackPointer.i68, %limit.i70
  tail call void @llvm.assume(i1 %isInside.i71)
  %newStackPointer.i72 = getelementptr i8, ptr %stackPointer.i68, i64 -24
  store ptr %newStackPointer.i72, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1117 = load ptr, ptr %newStackPointer.i72, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1117(%Pos %get_610026, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1157(%Pos %v_r_2985_1_11_33_32_4668, ptr %stack) {
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
  %c_2872 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %i_6_4639_pointer_1160 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_1160, align 4, !noalias !0
  %z.i = add i64 %i_6_4639, %c_2872
  %z.i6 = tail call %Pos @c_array_get(%Pos %v_r_2985_1_11_33_32_4668, i64 %z.i)
  %stackPointer.i8 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i10 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i11 = icmp ule ptr %stackPointer.i8, %limit.i10
  tail call void @llvm.assume(i1 %isInside.i11)
  %newStackPointer.i12 = getelementptr i8, ptr %stackPointer.i8, i64 -24
  store ptr %newStackPointer.i12, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1161 = load ptr, ptr %newStackPointer.i12, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1161(%Pos %z.i6, ptr %stack)
  ret void
}

define tailcc void @returnAddress_497(%Pos %v_r_2982_1_8_30_29_4660, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i31 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %c_2872_pointer_500 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %c_2872 = load i64, ptr %c_2872_pointer_500, align 4, !noalias !0
  %i_6_4639_pointer_501 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %i_6_4639 = load i64, ptr %i_6_4639_pointer_501, align 4, !noalias !0
  %p_4194_pointer_502 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %p_4194 = load ptr, ptr %p_4194_pointer_502, align 8, !noalias !0
  %queenRows_2864_pointer_503 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_503, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_504 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_504, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_505 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_505, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_506 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_506, align 4, !noalias !0
  %z.i = tail call %Pos @c_array_get(%Pos %v_r_2982_1_8_30_29_4660, i64 %i_6_4639)
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i34 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i34
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
  %newStackPointer.i35 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i35, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i39 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i34, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i35, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1137.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1137.repack13, align 8, !noalias !0
  %c_2872_pointer_1139 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_1139, align 4, !noalias !0
  %i_6_4639_pointer_1140 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_1140, align 4, !noalias !0
  %p_4194_pointer_1141 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_4194, ptr %p_4194_pointer_1141, align 8, !noalias !0
  %queenRows_2864_pointer_1142 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1142, align 8, !noalias !0
  %queenRows_2864_pointer_1142.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864_pointer_1142.repack15, align 8, !noalias !0
  %freeMins_2863_pointer_1143 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1143, align 8, !noalias !0
  %freeMins_2863_pointer_1143.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_1143.repack17, align 8, !noalias !0
  %freeMaxs_2862_pointer_1144 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1144, align 8, !noalias !0
  %freeMaxs_2862_pointer_1144.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_1144.repack19, align 8, !noalias !0
  %n_2854_pointer_1145 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_1145, align 4, !noalias !0
  %returnAddress_pointer_1146 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1147 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1148 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_507, ptr %returnAddress_pointer_1146, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_1147, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_1148, align 8, !noalias !0
  %tag_1149 = extractvalue %Pos %z.i, 0
  switch i64 %tag_1149, label %label_1151 [
    i64 0, label %label_1156
    i64 1, label %label_1179
  ]

label_1151:                                       ; preds = %stackAllocate.exit
  ret void

label_1156:                                       ; preds = %stackAllocate.exit
  %isInside.i40 = icmp ule ptr %nextStackPointer.sink.i, %limit.i39
  tail call void @llvm.assume(i1 %isInside.i40)
  %newStackPointer.i41 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i41, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1153 = load ptr, ptr %newStackPointer.i41, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1153(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_1179:                                       ; preds = %stackAllocate.exit
  %nextStackPointer.i46 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 40
  %isInside.not.i47 = icmp ugt ptr %nextStackPointer.i46, %limit.i39
  br i1 %isInside.not.i47, label %realloc.i50, label %stackAllocate.exit64

realloc.i50:                                      ; preds = %label_1179
  %base_pointer.i51 = getelementptr i8, ptr %stack, i64 16
  %base.i52 = load ptr, ptr %base_pointer.i51, align 8, !alias.scope !0
  %intStackPointer.i53 = ptrtoint ptr %nextStackPointer.sink.i to i64
  %intBase.i54 = ptrtoint ptr %base.i52 to i64
  %size.i55 = sub i64 %intStackPointer.i53, %intBase.i54
  %nextSize.i56 = add i64 %size.i55, 40
  %leadingZeros.i.i57 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i56, i1 false)
  %numBits.i.i58 = sub nuw nsw i64 64, %leadingZeros.i.i57
  %result.i.i59 = shl nuw i64 1, %numBits.i.i58
  %newBase.i60 = tail call ptr @realloc(ptr %base.i52, i64 %result.i.i59)
  %newLimit.i61 = getelementptr i8, ptr %newBase.i60, i64 %result.i.i59
  %newStackPointer.i62 = getelementptr i8, ptr %newBase.i60, i64 %size.i55
  %newNextStackPointer.i63 = getelementptr i8, ptr %newStackPointer.i62, i64 40
  store ptr %newBase.i60, ptr %base_pointer.i51, align 8, !alias.scope !0
  store ptr %newLimit.i61, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit64

stackAllocate.exit64:                             ; preds = %label_1179, %realloc.i50
  %limit.i7077 = phi ptr [ %newLimit.i61, %realloc.i50 ], [ %limit.i39, %label_1179 ]
  %nextStackPointer.sink.i48 = phi ptr [ %newNextStackPointer.i63, %realloc.i50 ], [ %nextStackPointer.i46, %label_1179 ]
  %common.ret.op.i49 = phi ptr [ %newStackPointer.i62, %realloc.i50 ], [ %nextStackPointer.sink.i, %label_1179 ]
  store ptr %nextStackPointer.sink.i48, ptr %stackPointer_pointer.i, align 8
  store i64 %c_2872, ptr %common.ret.op.i49, align 4, !noalias !0
  %i_6_4639_pointer_1170 = getelementptr i8, ptr %common.ret.op.i49, i64 8
  store i64 %i_6_4639, ptr %i_6_4639_pointer_1170, align 4, !noalias !0
  %returnAddress_pointer_1171 = getelementptr i8, ptr %common.ret.op.i49, i64 16
  %sharer_pointer_1172 = getelementptr i8, ptr %common.ret.op.i49, i64 24
  %eraser_pointer_1173 = getelementptr i8, ptr %common.ret.op.i49, i64 32
  store ptr @returnAddress_1157, ptr %returnAddress_pointer_1171, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_1172, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_1173, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeMaxs_2862.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i65 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i66 = load ptr, ptr %base_pointer.i65, align 8
  %varPointer.i = getelementptr i8, ptr %base.i66, i64 %freeMaxs_2862.unpack11
  %freeMaxs_2862_old_1175.elt21 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeMaxs_2862_old_1175.unpack22 = load ptr, ptr %freeMaxs_2862_old_1175.elt21, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeMaxs_2862_old_1175.unpack22, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit64
  %referenceCount.i.i = load i64, ptr %freeMaxs_2862_old_1175.unpack22, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeMaxs_2862_old_1175.unpack22, align 4
  %get_6104.unpack25.pre = load ptr, ptr %freeMaxs_2862_old_1175.elt21, align 8, !noalias !0
  %stackPointer.i68.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i70.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit64, %next.i.i
  %limit.i70 = phi ptr [ %limit.i7077, %stackAllocate.exit64 ], [ %limit.i70.pre, %next.i.i ]
  %stackPointer.i68 = phi ptr [ %nextStackPointer.sink.i48, %stackAllocate.exit64 ], [ %stackPointer.i68.pre, %next.i.i ]
  %get_6104.unpack25 = phi ptr [ null, %stackAllocate.exit64 ], [ %get_6104.unpack25.pre, %next.i.i ]
  %get_6104.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6104.unpack, 0
  %get_610426 = insertvalue %Pos %0, ptr %get_6104.unpack25, 1
  %isInside.i71 = icmp ule ptr %stackPointer.i68, %limit.i70
  tail call void @llvm.assume(i1 %isInside.i71)
  %newStackPointer.i72 = getelementptr i8, ptr %stackPointer.i68, i64 -24
  store ptr %newStackPointer.i72, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1176 = load ptr, ptr %newStackPointer.i72, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1176(%Pos %get_610426, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_4636(i64 %i_6_4639, %Reference %freeRows_2861, i64 %c_2872, ptr %p_4194, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_4639, %n_2854
  %stackPointer_pointer.i15 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_1213, label %label_496

label_496:                                        ; preds = %entry
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %returnAddress_493 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_493(%Pos zeroinitializer, ptr %stack)
  ret void

label_1213:                                       ; preds = %entry
  %limit_pointer.i16 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %limit.i17 = load ptr, ptr %limit_pointer.i16, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i17
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_1213
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
  %newStackPointer.i18 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i18, i64 120
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i16, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_1213, %realloc.i
  %limit.i2430 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i17, %label_1213 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_1213 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i18, %realloc.i ], [ %currentStackPointer.i, %label_1213 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i15, align 8
  %freeRows_2861.elt = extractvalue %Reference %freeRows_2861, 0
  store ptr %freeRows_2861.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1196.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %freeRows_2861.elt2 = extractvalue %Reference %freeRows_2861, 1
  store i64 %freeRows_2861.elt2, ptr %stackPointer_1196.repack1, align 8, !noalias !0
  %c_2872_pointer_1198 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %c_2872, ptr %c_2872_pointer_1198, align 4, !noalias !0
  %i_6_4639_pointer_1199 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_6_4639, ptr %i_6_4639_pointer_1199, align 4, !noalias !0
  %p_4194_pointer_1200 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %p_4194, ptr %p_4194_pointer_1200, align 8, !noalias !0
  %queenRows_2864_pointer_1201 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %queenRows_2864.elt = extractvalue %Reference %queenRows_2864, 0
  store ptr %queenRows_2864.elt, ptr %queenRows_2864_pointer_1201, align 8, !noalias !0
  %queenRows_2864_pointer_1201.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %queenRows_2864.elt4 = extractvalue %Reference %queenRows_2864, 1
  store i64 %queenRows_2864.elt4, ptr %queenRows_2864_pointer_1201.repack3, align 8, !noalias !0
  %freeMins_2863_pointer_1202 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %freeMins_2863.elt = extractvalue %Reference %freeMins_2863, 0
  store ptr %freeMins_2863.elt, ptr %freeMins_2863_pointer_1202, align 8, !noalias !0
  %freeMins_2863_pointer_1202.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %freeMins_2863.elt6 = extractvalue %Reference %freeMins_2863, 1
  store i64 %freeMins_2863.elt6, ptr %freeMins_2863_pointer_1202.repack5, align 8, !noalias !0
  %freeMaxs_2862_pointer_1203 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %freeMaxs_2862.elt = extractvalue %Reference %freeMaxs_2862, 0
  store ptr %freeMaxs_2862.elt, ptr %freeMaxs_2862_pointer_1203, align 8, !noalias !0
  %freeMaxs_2862_pointer_1203.repack7 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %freeMaxs_2862.elt8 = extractvalue %Reference %freeMaxs_2862, 1
  store i64 %freeMaxs_2862.elt8, ptr %freeMaxs_2862_pointer_1203.repack7, align 8, !noalias !0
  %n_2854_pointer_1204 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_1204, align 4, !noalias !0
  %returnAddress_pointer_1205 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1206 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1207 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_497, ptr %returnAddress_pointer_1205, align 8, !noalias !0
  store ptr @sharer_545, ptr %sharer_pointer_1206, align 8, !noalias !0
  store ptr @eraser_563, ptr %eraser_pointer_1207, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeRows_2861.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i19 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i20 = load ptr, ptr %base_pointer.i19, align 8
  %varPointer.i = getelementptr i8, ptr %base.i20, i64 %freeRows_2861.elt2
  %freeRows_2861_old_1209.elt9 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeRows_2861_old_1209.unpack10 = load ptr, ptr %freeRows_2861_old_1209.elt9, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeRows_2861_old_1209.unpack10, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeRows_2861_old_1209.unpack10, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %freeRows_2861_old_1209.unpack10, align 4
  %get_6105.unpack13.pre = load ptr, ptr %freeRows_2861_old_1209.elt9, align 8, !noalias !0
  %stackPointer.i22.pre = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %limit.i24.pre = load ptr, ptr %limit_pointer.i16, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i24 = phi ptr [ %limit.i2430, %stackAllocate.exit ], [ %limit.i24.pre, %next.i.i ]
  %stackPointer.i22 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i22.pre, %next.i.i ]
  %get_6105.unpack13 = phi ptr [ null, %stackAllocate.exit ], [ %get_6105.unpack13.pre, %next.i.i ]
  %get_6105.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6105.unpack, 0
  %get_610514 = insertvalue %Pos %0, ptr %get_6105.unpack13, 1
  %isInside.i25 = icmp ule ptr %stackPointer.i22, %limit.i24
  tail call void @llvm.assume(i1 %isInside.i25)
  %newStackPointer.i26 = getelementptr i8, ptr %stackPointer.i22, i64 -24
  store ptr %newStackPointer.i26, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %returnAddress_1210 = load ptr, ptr %newStackPointer.i26, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1210(%Pos %get_610514, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1214(%Pos %__6106, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %__6106, 1
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
  %returnAddress_1216 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1216(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @placeQueen_2873(i64 %c_2872, %Reference %freeRows_2861, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, ptr %stack) local_unnamed_addr {
entry:
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
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %newBase.i = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 32
  %newNextStackPointer.i = getelementptr i8, ptr %newBase.i, i64 24
  store ptr %newBase.i, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i4 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %base.i11 = phi ptr [ %newBase.i, %realloc.i ], [ %stackPointer.i.i, %entry ]
  %sharer_pointer_487 = getelementptr i8, ptr %base.i11, i64 8
  %eraser_pointer_488 = getelementptr i8, ptr %base.i11, i64 16
  store ptr @returnAddress_480, ptr %base.i11, align 8, !noalias !0
  store ptr @sharer_76, ptr %sharer_pointer_487, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_488, align 8, !noalias !0
  %nextStackPointer.i5 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i6 = icmp ugt ptr %nextStackPointer.i5, %limit.i4
  br i1 %isInside.not.i6, label %realloc.i9, label %stackAllocate.exit23

realloc.i9:                                       ; preds = %stackAllocate.exit
  %intStackPointer.i12 = ptrtoint ptr %nextStackPointer.sink.i to i64
  %intBase.i13 = ptrtoint ptr %base.i11 to i64
  %size.i14 = sub i64 %intStackPointer.i12, %intBase.i13
  %nextSize.i15 = add i64 %size.i14, 24
  %leadingZeros.i.i16 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i15, i1 false)
  %numBits.i.i17 = sub nuw nsw i64 64, %leadingZeros.i.i16
  %result.i.i18 = shl nuw i64 1, %numBits.i.i17
  %newBase.i19 = tail call ptr @realloc(ptr nonnull %base.i11, i64 %result.i.i18)
  %newLimit.i20 = getelementptr i8, ptr %newBase.i19, i64 %result.i.i18
  %newStackPointer.i21 = getelementptr i8, ptr %newBase.i19, i64 %size.i14
  %newNextStackPointer.i22 = getelementptr i8, ptr %newStackPointer.i21, i64 24
  store ptr %newBase.i19, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i20, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit23

stackAllocate.exit23:                             ; preds = %stackAllocate.exit, %realloc.i9
  %nextStackPointer.sink.i7 = phi ptr [ %newNextStackPointer.i22, %realloc.i9 ], [ %nextStackPointer.i5, %stackAllocate.exit ]
  %common.ret.op.i8 = phi ptr [ %newStackPointer.i21, %realloc.i9 ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i7, ptr %stack.repack1.i, align 8
  %sharer_pointer_1221 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_1222 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_1214, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_39, ptr %sharer_pointer_1221, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_1222, align 8, !noalias !0
  musttail call tailcc void @loop_5_4636(i64 0, %Reference %freeRows_2861, i64 %c_2872, ptr nonnull %calloc.i.i, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_1224(%Pos %returnValue_1225, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_r_3034_4162.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_3034_4162.unpack2 = load ptr, ptr %v_r_3034_4162.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_3034_4162.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_3034_4162.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_3034_4162.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_3034_4162.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_3034_4162.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_3034_4162.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i7 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i8 = icmp ule ptr %stackPointer.i5, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i8)
  %newStackPointer.i9 = getelementptr i8, ptr %stackPointer.i5, i64 -24
  store ptr %newStackPointer.i9, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1228 = load ptr, ptr %newStackPointer.i9, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1228(%Pos %returnValue_1225, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1264(%Pos %__8_4919, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %i_6_4916_pointer_1267 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %i_6_4916 = load i64, ptr %i_6_4916_pointer_1267, align 4, !noalias !0
  %j_2878_pointer_1268 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %j_2878.unpack = load ptr, ptr %j_2878_pointer_1268, align 8, !noalias !0
  %j_2878.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %j_2878.unpack5 = load i64, ptr %j_2878.elt4, align 8, !noalias !0
  %queenRows_2864_pointer_1269 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1269, align 8, !noalias !0
  %queenRows_2864.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack8 = load i64, ptr %queenRows_2864.elt7, align 8, !noalias !0
  %freeMins_2863_pointer_1270 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1270, align 8, !noalias !0
  %freeMins_2863.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack11 = load i64, ptr %freeMins_2863.elt10, align 8, !noalias !0
  %freeMaxs_2862_pointer_1271 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1271, align 8, !noalias !0
  %freeMaxs_2862.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack14 = load i64, ptr %freeMaxs_2862.elt13, align 8, !noalias !0
  %n_2854_pointer_1272 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1272, align 4, !noalias !0
  %object.i = extractvalue %Pos %__8_4919, 1
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
  %0 = insertvalue %Reference poison, ptr %freeMaxs_2862.unpack, 0
  %freeMaxs_286215 = insertvalue %Reference %0, i64 %freeMaxs_2862.unpack14, 1
  %1 = insertvalue %Reference poison, ptr %freeMins_2863.unpack, 0
  %freeMins_286312 = insertvalue %Reference %1, i64 %freeMins_2863.unpack11, 1
  %2 = insertvalue %Reference poison, ptr %queenRows_2864.unpack, 0
  %queenRows_28649 = insertvalue %Reference %2, i64 %queenRows_2864.unpack8, 1
  %3 = insertvalue %Reference poison, ptr %j_2878.unpack, 0
  %j_28786 = insertvalue %Reference %3, i64 %j_2878.unpack5, 1
  %4 = insertvalue %Reference poison, ptr %freeRows_2861.unpack, 0
  %freeRows_28613 = insertvalue %Reference %4, i64 %freeRows_2861.unpack2, 1
  %z.i = add i64 %i_6_4916, 1
  musttail call tailcc void @loop_5_4913(i64 %z.i, %Reference %freeRows_28613, %Reference %j_28786, %Reference %queenRows_28649, %Reference %freeMins_286312, %Reference %freeMaxs_286215, i64 %n_2854, ptr nonnull %stack)
  ret void
}

define void @sharer_1280(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -120
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1296(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -120
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -104
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1255(%Pos %v_r_3037_123_5022, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  %n_2854_pointer_1263 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1263, align 4, !noalias !0
  %freeMaxs_2862.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack14 = load i64, ptr %freeMaxs_2862.elt13, align 8, !noalias !0
  %freeMaxs_2862_pointer_1262 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1262, align 8, !noalias !0
  %freeMins_2863.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack11 = load i64, ptr %freeMins_2863.elt10, align 8, !noalias !0
  %freeMins_2863_pointer_1261 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1261, align 8, !noalias !0
  %queenRows_2864.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack8 = load i64, ptr %queenRows_2864.elt7, align 8, !noalias !0
  %queenRows_2864_pointer_1260 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1260, align 8, !noalias !0
  %j_2878.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %j_2878.unpack5 = load i64, ptr %j_2878.elt4, align 8, !noalias !0
  %j_2878_pointer_1259 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %j_2878.unpack = load ptr, ptr %j_2878_pointer_1259, align 8, !noalias !0
  %i_6_4916_pointer_1258 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %i_6_4916 = load i64, ptr %i_6_4916_pointer_1258, align 4, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_1305.repack16 = getelementptr i8, ptr %stackPointer.i, i64 -88
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1305.repack16, align 8, !noalias !0
  %i_6_4916_pointer_1307 = getelementptr i8, ptr %stackPointer.i, i64 -80
  store i64 %i_6_4916, ptr %i_6_4916_pointer_1307, align 4, !noalias !0
  %j_2878_pointer_1308 = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %j_2878.unpack, ptr %j_2878_pointer_1308, align 8, !noalias !0
  %j_2878_pointer_1308.repack18 = getelementptr i8, ptr %stackPointer.i, i64 -64
  store i64 %j_2878.unpack5, ptr %j_2878_pointer_1308.repack18, align 8, !noalias !0
  %queenRows_2864_pointer_1309 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1309, align 8, !noalias !0
  %queenRows_2864_pointer_1309.repack20 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %queenRows_2864.unpack8, ptr %queenRows_2864_pointer_1309.repack20, align 8, !noalias !0
  %freeMins_2863_pointer_1310 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1310, align 8, !noalias !0
  %freeMins_2863_pointer_1310.repack22 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store i64 %freeMins_2863.unpack11, ptr %freeMins_2863_pointer_1310.repack22, align 8, !noalias !0
  %freeMaxs_2862_pointer_1311 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1311, align 8, !noalias !0
  %freeMaxs_2862_pointer_1311.repack24 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %freeMaxs_2862.unpack14, ptr %freeMaxs_2862_pointer_1311.repack24, align 8, !noalias !0
  %n_2854_pointer_1312 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %n_2854, ptr %n_2854_pointer_1312, align 4, !noalias !0
  %sharer_pointer_1314 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1315 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1264, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1280, ptr %sharer_pointer_1314, align 8, !noalias !0
  store ptr @eraser_1296, ptr %eraser_pointer_1315, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %j_2878.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i40 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i41 = load ptr, ptr %base_pointer.i40, align 8
  %varPointer.i = getelementptr i8, ptr %base.i41, i64 %j_2878.unpack5
  %j_2878_old_1317.elt26 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %j_2878_old_1317.unpack27 = load ptr, ptr %j_2878_old_1317.elt26, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %j_2878_old_1317.unpack27, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %j_2878_old_1317.unpack27, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %j_2878_old_1317.unpack27, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %j_2878_old_1317.unpack27, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %j_2878_old_1317.unpack27, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %j_2878_old_1317.unpack27)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %stackAllocate.exit, %decr.i.i, %free.i.i
  %v_r_3037_123_5022.elt = extractvalue %Pos %v_r_3037_123_5022, 0
  store i64 %v_r_3037_123_5022.elt, ptr %varPointer.i, align 8, !noalias !0
  %v_r_3037_123_5022.elt30 = extractvalue %Pos %v_r_3037_123_5022, 1
  store ptr %v_r_3037_123_5022.elt30, ptr %j_2878_old_1317.elt26, align 8, !noalias !0
  %stackPointer.i43 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i45 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i46 = icmp ule ptr %stackPointer.i43, %limit.i45
  tail call void @llvm.assume(i1 %isInside.i46)
  %newStackPointer.i47 = getelementptr i8, ptr %stackPointer.i43, i64 -24
  store ptr %newStackPointer.i47, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1319 = load ptr, ptr %newStackPointer.i47, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1319(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_9_6_6_69_4941(i64 %i_6_10_7_7_70_5009, i64 %n_2854, %Pos %tmp_5933, ptr %stack) local_unnamed_addr {
entry:
  %z.i20 = icmp slt i64 %i_6_10_7_7_70_5009, %n_2854
  %object.i = extractvalue %Pos %tmp_5933, 1
  br i1 %z.i20, label %label_1364.lr.ph, label %label_1362

label_1364.lr.ph:                                 ; preds = %entry
  %isNull.i.i = icmp eq ptr %object.i, null
  br label %label_1364

label_1362:                                       ; preds = %erasePositive.exit, %entry
  %isNull.i.i7 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %label_1362
  %referenceCount.i.i9 = load i64, ptr %object.i, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %object.i, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %label_1362, %decr.i.i11, %free.i.i13
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1359 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1359(%Pos zeroinitializer, ptr %stack)
  ret void

label_1364:                                       ; preds = %label_1364.lr.ph, %erasePositive.exit
  %i_6_10_7_7_70_5009.tr21 = phi i64 [ %i_6_10_7_7_70_5009, %label_1364.lr.ph ], [ %z.i19, %erasePositive.exit ]
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1364
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_1364, %next.i.i
  %z.i18 = tail call %Pos @c_array_set(%Pos %tmp_5933, i64 %i_6_10_7_7_70_5009.tr21, %Pos { i64 1, ptr null })
  %object.i1 = extractvalue %Pos %z.i18, 1
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i2, label %erasePositive.exit, label %next.i.i3

next.i.i3:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i4, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i3
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, -1
  store i64 %referenceCount.1.i.i5, ptr %object.i1, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i3
  %objectEraser.i.i = getelementptr i8, ptr %object.i1, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i1, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i1)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %z.i19 = add nsw i64 %i_6_10_7_7_70_5009.tr21, 1
  %z.i = icmp slt i64 %z.i19, %n_2854
  br i1 %z.i, label %label_1364, label %label_1362
}

define tailcc void @loop_5_9_21_21_84_4931(i64 %i_6_10_22_22_85_4964, %Pos %tmp_5938, i64 %tmp_5937, ptr %stack) local_unnamed_addr {
entry:
  %z.i20 = icmp slt i64 %i_6_10_22_22_85_4964, %tmp_5937
  %object.i = extractvalue %Pos %tmp_5938, 1
  br i1 %z.i20, label %label_1389.lr.ph, label %label_1387

label_1389.lr.ph:                                 ; preds = %entry
  %isNull.i.i = icmp eq ptr %object.i, null
  br label %label_1389

label_1387:                                       ; preds = %erasePositive.exit, %entry
  %isNull.i.i7 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %label_1387
  %referenceCount.i.i9 = load i64, ptr %object.i, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %object.i, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %label_1387, %decr.i.i11, %free.i.i13
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1384 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1384(%Pos zeroinitializer, ptr %stack)
  ret void

label_1389:                                       ; preds = %label_1389.lr.ph, %erasePositive.exit
  %i_6_10_22_22_85_4964.tr21 = phi i64 [ %i_6_10_22_22_85_4964, %label_1389.lr.ph ], [ %z.i19, %erasePositive.exit ]
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1389
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_1389, %next.i.i
  %z.i18 = tail call %Pos @c_array_set(%Pos %tmp_5938, i64 %i_6_10_22_22_85_4964.tr21, %Pos { i64 1, ptr null })
  %object.i1 = extractvalue %Pos %z.i18, 1
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i2, label %erasePositive.exit, label %next.i.i3

next.i.i3:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i4, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i3
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, -1
  store i64 %referenceCount.1.i.i5, ptr %object.i1, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i3
  %objectEraser.i.i = getelementptr i8, ptr %object.i1, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i1, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i1)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %z.i19 = add nsw i64 %i_6_10_22_22_85_4964.tr21, 1
  %z.i = icmp slt i64 %z.i19, %tmp_5937
  br i1 %z.i, label %label_1389, label %label_1387
}

define tailcc void @loop_5_9_36_36_99_4992(i64 %i_6_10_37_37_100_4962, %Pos %tmp_5943, i64 %tmp_5942, ptr %stack) local_unnamed_addr {
entry:
  %z.i20 = icmp slt i64 %i_6_10_37_37_100_4962, %tmp_5942
  %object.i = extractvalue %Pos %tmp_5943, 1
  br i1 %z.i20, label %label_1414.lr.ph, label %label_1412

label_1414.lr.ph:                                 ; preds = %entry
  %isNull.i.i = icmp eq ptr %object.i, null
  br label %label_1414

label_1412:                                       ; preds = %erasePositive.exit, %entry
  %isNull.i.i7 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %label_1412
  %referenceCount.i.i9 = load i64, ptr %object.i, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %object.i, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %label_1412, %decr.i.i11, %free.i.i13
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1409 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1409(%Pos zeroinitializer, ptr %stack)
  ret void

label_1414:                                       ; preds = %label_1414.lr.ph, %erasePositive.exit
  %i_6_10_37_37_100_4962.tr21 = phi i64 [ %i_6_10_37_37_100_4962, %label_1414.lr.ph ], [ %z.i19, %erasePositive.exit ]
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1414
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_1414, %next.i.i
  %z.i18 = tail call %Pos @c_array_set(%Pos %tmp_5943, i64 %i_6_10_37_37_100_4962.tr21, %Pos { i64 1, ptr null })
  %object.i1 = extractvalue %Pos %z.i18, 1
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i2, label %erasePositive.exit, label %next.i.i3

next.i.i3:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i4, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i3
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, -1
  store i64 %referenceCount.1.i.i5, ptr %object.i1, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i3
  %objectEraser.i.i = getelementptr i8, ptr %object.i1, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i1, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i1)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %sharePositive.exit, %decr.i.i, %free.i.i
  %z.i19 = add nsw i64 %i_6_10_37_37_100_4962.tr21, 1
  %z.i = icmp slt i64 %z.i19, %tmp_5942
  br i1 %z.i, label %label_1414, label %label_1412
}

define tailcc void @loop_5_9_51_51_114_4983(i64 %i_6_10_52_52_115_4987, i64 %n_2854, %Pos %tmp_5947, %Pos %tmp_5948, ptr %stack) local_unnamed_addr {
entry:
  %z.i38 = icmp slt i64 %i_6_10_52_52_115_4987, %n_2854
  %object.i1 = extractvalue %Pos %tmp_5948, 1
  br i1 %z.i38, label %label_1438.lr.ph, label %label_1437

label_1438.lr.ph:                                 ; preds = %entry
  %isNull.i.i2 = icmp eq ptr %object.i1, null
  %object.i = extractvalue %Pos %tmp_5947, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br label %label_1438

label_1437:                                       ; preds = %erasePositive.exit, %entry
  %isNull.i.i25 = icmp eq ptr %object.i1, null
  br i1 %isNull.i.i25, label %erasePositive.exit35, label %next.i.i26

next.i.i26:                                       ; preds = %label_1437
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

erasePositive.exit35:                             ; preds = %label_1437, %decr.i.i29, %free.i.i31
  %object.i12 = extractvalue %Pos %tmp_5947, 1
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
  %returnAddress_1434 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1434(%Pos zeroinitializer, ptr %stack)
  ret void

label_1438:                                       ; preds = %label_1438.lr.ph, %erasePositive.exit
  %i_6_10_52_52_115_4987.tr39 = phi i64 [ %i_6_10_52_52_115_4987, %label_1438.lr.ph ], [ %z.i37, %erasePositive.exit ]
  br i1 %isNull.i.i2, label %sharePositive.exit6, label %next.i.i3

next.i.i3:                                        ; preds = %label_1438
  %referenceCount.i.i4 = load i64, ptr %object.i1, align 4
  %referenceCount.1.i.i5 = add i64 %referenceCount.i.i4, 1
  store i64 %referenceCount.1.i.i5, ptr %object.i1, align 4
  br label %sharePositive.exit6

sharePositive.exit6:                              ; preds = %label_1438, %next.i.i3
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit6
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit6, %next.i.i
  %z.i36 = tail call %Pos @c_array_set(%Pos %tmp_5948, i64 %i_6_10_52_52_115_4987.tr39, %Pos %tmp_5947)
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
  %z.i37 = add nsw i64 %i_6_10_52_52_115_4987.tr39, 1
  %z.i = icmp slt i64 %z.i37, %n_2854
  br i1 %z.i, label %label_1438, label %label_1437
}

define tailcc void @returnAddress_1447(%Pos %__59_59_122_5050, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %queenRows_2864_pointer_1450 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1450, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_1451 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1451, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_1452 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1452, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_1453 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1453, align 4, !noalias !0
  %object.i = extractvalue %Pos %__59_59_122_5050, 1
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
  %0 = insertvalue %Reference poison, ptr %freeMaxs_2862.unpack, 0
  %freeMaxs_286212 = insertvalue %Reference %0, i64 %freeMaxs_2862.unpack11, 1
  %1 = insertvalue %Reference poison, ptr %freeMins_2863.unpack, 0
  %freeMins_28639 = insertvalue %Reference %1, i64 %freeMins_2863.unpack8, 1
  %2 = insertvalue %Reference poison, ptr %queenRows_2864.unpack, 0
  %queenRows_28646 = insertvalue %Reference %2, i64 %queenRows_2864.unpack5, 1
  %3 = insertvalue %Reference poison, ptr %freeRows_2861.unpack, 0
  %freeRows_28613 = insertvalue %Reference %3, i64 %freeRows_2861.unpack2, 1
  musttail call tailcc void @placeQueen_2873(i64 0, %Reference %freeRows_28613, %Reference %queenRows_28646, %Reference %freeMins_28639, %Reference %freeMaxs_286212, i64 %n_2854, ptr nonnull %stack)
  ret void
}

define void @sharer_1459(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1471(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -80
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1439(%Pos %v_r_3054_15_57_57_120_5049, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i44 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i44)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %tmp_5948_pointer_1442 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5948.unpack = load i64, ptr %tmp_5948_pointer_1442, align 8, !noalias !0
  %tmp_5948.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_5948.unpack5 = load ptr, ptr %tmp_5948.elt4, align 8, !noalias !0
  %queenRows_2864_pointer_1443 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1443, align 8, !noalias !0
  %queenRows_2864.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack8 = load i64, ptr %queenRows_2864.elt7, align 8, !noalias !0
  %freeMins_2863_pointer_1444 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1444, align 8, !noalias !0
  %freeMins_2863.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack11 = load i64, ptr %freeMins_2863.elt10, align 8, !noalias !0
  %freeMaxs_2862_pointer_1445 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1445, align 8, !noalias !0
  %freeMaxs_2862.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack14 = load i64, ptr %freeMaxs_2862.elt13, align 8, !noalias !0
  %n_2854_pointer_1446 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1446, align 4, !noalias !0
  %object.i = extractvalue %Pos %v_r_3054_15_57_57_120_5049, 1
  %isNull.i.i29 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i29, label %erasePositive.exit39, label %next.i.i30

next.i.i30:                                       ; preds = %entry
  %referenceCount.i.i31 = load i64, ptr %object.i, align 4
  %cond.i.i32 = icmp eq i64 %referenceCount.i.i31, 0
  br i1 %cond.i.i32, label %free.i.i35, label %decr.i.i33

decr.i.i33:                                       ; preds = %next.i.i30
  %referenceCount.1.i.i34 = add i64 %referenceCount.i.i31, -1
  store i64 %referenceCount.1.i.i34, ptr %object.i, align 4
  br label %erasePositive.exit39

free.i.i35:                                       ; preds = %next.i.i30
  %objectEraser.i.i36 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i37 = load ptr, ptr %objectEraser.i.i36, align 8
  %environment.i.i.i38 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i37(ptr %environment.i.i.i38)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit39

erasePositive.exit39:                             ; preds = %entry, %decr.i.i33, %free.i.i35
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i47 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 96
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i47
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit39
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
  %newStackPointer.i48 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i48, i64 96
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit39, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit39 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i48, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit39 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1478.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1478.repack16, align 8, !noalias !0
  %queenRows_2864_pointer_1480 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1480, align 8, !noalias !0
  %queenRows_2864_pointer_1480.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %queenRows_2864.unpack8, ptr %queenRows_2864_pointer_1480.repack18, align 8, !noalias !0
  %freeMins_2863_pointer_1481 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1481, align 8, !noalias !0
  %freeMins_2863_pointer_1481.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %freeMins_2863.unpack11, ptr %freeMins_2863_pointer_1481.repack20, align 8, !noalias !0
  %freeMaxs_2862_pointer_1482 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1482, align 8, !noalias !0
  %freeMaxs_2862_pointer_1482.repack22 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %freeMaxs_2862.unpack14, ptr %freeMaxs_2862_pointer_1482.repack22, align 8, !noalias !0
  %n_2854_pointer_1483 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %n_2854, ptr %n_2854_pointer_1483, align 4, !noalias !0
  %returnAddress_pointer_1484 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_1485 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_1486 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_1447, ptr %returnAddress_pointer_1484, align 8, !noalias !0
  store ptr @sharer_1459, ptr %sharer_pointer_1485, align 8, !noalias !0
  store ptr @eraser_1471, ptr %eraser_pointer_1486, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %queenRows_2864.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i49 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i50 = load ptr, ptr %base_pointer.i49, align 8
  %varPointer.i = getelementptr i8, ptr %base.i50, i64 %queenRows_2864.unpack8
  %queenRows_2864_old_1488.elt24 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %queenRows_2864_old_1488.unpack25 = load ptr, ptr %queenRows_2864_old_1488.elt24, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %queenRows_2864_old_1488.unpack25, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %queenRows_2864_old_1488.unpack25, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %queenRows_2864_old_1488.unpack25, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %queenRows_2864_old_1488.unpack25, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %queenRows_2864_old_1488.unpack25, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %queenRows_2864_old_1488.unpack25)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %stackAllocate.exit, %decr.i.i, %free.i.i
  store i64 %tmp_5948.unpack, ptr %varPointer.i, align 8, !noalias !0
  store ptr %tmp_5948.unpack5, ptr %queenRows_2864_old_1488.elt24, align 8, !noalias !0
  %stackPointer.i52 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i54 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i55 = icmp ule ptr %stackPointer.i52, %limit.i54
  tail call void @llvm.assume(i1 %isInside.i55)
  %newStackPointer.i56 = getelementptr i8, ptr %stackPointer.i52, i64 -24
  store ptr %newStackPointer.i56, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1490 = load ptr, ptr %newStackPointer.i56, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1490(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1499(ptr %stackPointer) {
entry:
  %tmp_5948_1494.elt1 = getelementptr i8, ptr %stackPointer, i64 -64
  %tmp_5948_1494.unpack2 = load ptr, ptr %tmp_5948_1494.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5948_1494.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5948_1494.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5948_1494.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1513(ptr %stackPointer) {
entry:
  %tmp_5948_1508.elt1 = getelementptr i8, ptr %stackPointer, i64 -64
  %tmp_5948_1508.unpack2 = load ptr, ptr %tmp_5948_1508.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5948_1508.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5948_1508.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5948_1508.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5948_1508.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5948_1508.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5948_1508.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -96
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1423(%Pos %__44_44_107_5047, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i32 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %queenRows_2864_pointer_1426 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1426, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_1427 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1427, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_1428 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1428, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_1429 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1429, align 4, !noalias !0
  %object.i23 = extractvalue %Pos %__44_44_107_5047, 1
  %isNull.i.i24 = icmp eq ptr %object.i23, null
  br i1 %isNull.i.i24, label %erasePositive.exit, label %next.i.i25

next.i.i25:                                       ; preds = %entry
  %referenceCount.i.i26 = load i64, ptr %object.i23, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i25
  %referenceCount.1.i.i27 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i27, ptr %object.i23, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i25
  %objectEraser.i.i = getelementptr i8, ptr %object.i23, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i23, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i23)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %z.i = tail call %Pos @c_array_new(i64 %n_2854)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i35 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 112
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i35
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
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
  %newStackPointer.i36 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i36, i64 112
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i36, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1521.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1521.repack13, align 8, !noalias !0
  %tmp_5948_pointer_1523 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %pureApp_6145.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_6145.elt, ptr %tmp_5948_pointer_1523, align 8, !noalias !0
  %tmp_5948_pointer_1523.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i, ptr %tmp_5948_pointer_1523.repack15, align 8, !noalias !0
  %queenRows_2864_pointer_1524 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1524, align 8, !noalias !0
  %queenRows_2864_pointer_1524.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864_pointer_1524.repack17, align 8, !noalias !0
  %freeMins_2863_pointer_1525 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1525, align 8, !noalias !0
  %freeMins_2863_pointer_1525.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_1525.repack19, align 8, !noalias !0
  %freeMaxs_2862_pointer_1526 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1526, align 8, !noalias !0
  %freeMaxs_2862_pointer_1526.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_1526.repack21, align 8, !noalias !0
  %n_2854_pointer_1527 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %n_2854, ptr %n_2854_pointer_1527, align 4, !noalias !0
  %returnAddress_pointer_1528 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %sharer_pointer_1529 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %eraser_pointer_1530 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store ptr @returnAddress_1439, ptr %returnAddress_pointer_1528, align 8, !noalias !0
  store ptr @sharer_1499, ptr %sharer_pointer_1529, align 8, !noalias !0
  store ptr @eraser_1513, ptr %eraser_pointer_1530, align 8, !noalias !0
  musttail call tailcc void @loop_5_9_51_51_114_4983(i64 0, i64 %n_2854, %Pos { i64 -1, ptr null }, %Pos %z.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1415(%Pos %v_r_3054_15_42_42_105_5046, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i44 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i44)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %tmp_5943_pointer_1418 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5943.unpack = load i64, ptr %tmp_5943_pointer_1418, align 8, !noalias !0
  %tmp_5943.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_5943.unpack5 = load ptr, ptr %tmp_5943.elt4, align 8, !noalias !0
  %queenRows_2864_pointer_1419 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1419, align 8, !noalias !0
  %queenRows_2864.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack8 = load i64, ptr %queenRows_2864.elt7, align 8, !noalias !0
  %freeMins_2863_pointer_1420 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1420, align 8, !noalias !0
  %freeMins_2863.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack11 = load i64, ptr %freeMins_2863.elt10, align 8, !noalias !0
  %freeMaxs_2862_pointer_1421 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1421, align 8, !noalias !0
  %freeMaxs_2862.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack14 = load i64, ptr %freeMaxs_2862.elt13, align 8, !noalias !0
  %n_2854_pointer_1422 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1422, align 4, !noalias !0
  %object.i = extractvalue %Pos %v_r_3054_15_42_42_105_5046, 1
  %isNull.i.i29 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i29, label %erasePositive.exit39, label %next.i.i30

next.i.i30:                                       ; preds = %entry
  %referenceCount.i.i31 = load i64, ptr %object.i, align 4
  %cond.i.i32 = icmp eq i64 %referenceCount.i.i31, 0
  br i1 %cond.i.i32, label %free.i.i35, label %decr.i.i33

decr.i.i33:                                       ; preds = %next.i.i30
  %referenceCount.1.i.i34 = add i64 %referenceCount.i.i31, -1
  store i64 %referenceCount.1.i.i34, ptr %object.i, align 4
  br label %erasePositive.exit39

free.i.i35:                                       ; preds = %next.i.i30
  %objectEraser.i.i36 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i37 = load ptr, ptr %objectEraser.i.i36, align 8
  %environment.i.i.i38 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i37(ptr %environment.i.i.i38)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit39

erasePositive.exit39:                             ; preds = %entry, %decr.i.i33, %free.i.i35
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i47 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 96
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i47
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit39
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
  %newStackPointer.i48 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i48, i64 96
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit39, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit39 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i48, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit39 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1541.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1541.repack16, align 8, !noalias !0
  %queenRows_2864_pointer_1543 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1543, align 8, !noalias !0
  %queenRows_2864_pointer_1543.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %queenRows_2864.unpack8, ptr %queenRows_2864_pointer_1543.repack18, align 8, !noalias !0
  %freeMins_2863_pointer_1544 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1544, align 8, !noalias !0
  %freeMins_2863_pointer_1544.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %freeMins_2863.unpack11, ptr %freeMins_2863_pointer_1544.repack20, align 8, !noalias !0
  %freeMaxs_2862_pointer_1545 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1545, align 8, !noalias !0
  %freeMaxs_2862_pointer_1545.repack22 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %freeMaxs_2862.unpack14, ptr %freeMaxs_2862_pointer_1545.repack22, align 8, !noalias !0
  %n_2854_pointer_1546 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %n_2854, ptr %n_2854_pointer_1546, align 4, !noalias !0
  %returnAddress_pointer_1547 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_1548 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_1549 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_1423, ptr %returnAddress_pointer_1547, align 8, !noalias !0
  store ptr @sharer_1459, ptr %sharer_pointer_1548, align 8, !noalias !0
  store ptr @eraser_1471, ptr %eraser_pointer_1549, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeMins_2863.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i49 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i50 = load ptr, ptr %base_pointer.i49, align 8
  %varPointer.i = getelementptr i8, ptr %base.i50, i64 %freeMins_2863.unpack11
  %freeMins_2863_old_1551.elt24 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeMins_2863_old_1551.unpack25 = load ptr, ptr %freeMins_2863_old_1551.elt24, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeMins_2863_old_1551.unpack25, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeMins_2863_old_1551.unpack25, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %freeMins_2863_old_1551.unpack25, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %freeMins_2863_old_1551.unpack25, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %freeMins_2863_old_1551.unpack25, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %freeMins_2863_old_1551.unpack25)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %stackAllocate.exit, %decr.i.i, %free.i.i
  store i64 %tmp_5943.unpack, ptr %varPointer.i, align 8, !noalias !0
  store ptr %tmp_5943.unpack5, ptr %freeMins_2863_old_1551.elt24, align 8, !noalias !0
  %stackPointer.i52 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i54 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i55 = icmp ule ptr %stackPointer.i52, %limit.i54
  tail call void @llvm.assume(i1 %isInside.i55)
  %newStackPointer.i56 = getelementptr i8, ptr %stackPointer.i52, i64 -24
  store ptr %newStackPointer.i56, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1553 = load ptr, ptr %newStackPointer.i56, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1553(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1398(%Pos %__29_29_92_5044, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i32 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %queenRows_2864_pointer_1401 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1401, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_1402 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1402, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_1403 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1403, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_1404 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1404, align 4, !noalias !0
  %object.i23 = extractvalue %Pos %__29_29_92_5044, 1
  %isNull.i.i24 = icmp eq ptr %object.i23, null
  br i1 %isNull.i.i24, label %erasePositive.exit, label %next.i.i25

next.i.i25:                                       ; preds = %entry
  %referenceCount.i.i26 = load i64, ptr %object.i23, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i25
  %referenceCount.1.i.i27 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i27, ptr %object.i23, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i25
  %objectEraser.i.i = getelementptr i8, ptr %object.i23, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i23, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i23)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %z.i = shl i64 %n_2854, 1
  %z.i33 = tail call %Pos @c_array_new(i64 %z.i)
  %object.i = extractvalue %Pos %z.i33, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i36 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 112
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i36
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
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
  %newStackPointer.i37 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i37, i64 112
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i37, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1568.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1568.repack13, align 8, !noalias !0
  %tmp_5943_pointer_1570 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %pureApp_6136.elt = extractvalue %Pos %z.i33, 0
  store i64 %pureApp_6136.elt, ptr %tmp_5943_pointer_1570, align 8, !noalias !0
  %tmp_5943_pointer_1570.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i, ptr %tmp_5943_pointer_1570.repack15, align 8, !noalias !0
  %queenRows_2864_pointer_1571 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1571, align 8, !noalias !0
  %queenRows_2864_pointer_1571.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %queenRows_2864.unpack5, ptr %queenRows_2864_pointer_1571.repack17, align 8, !noalias !0
  %freeMins_2863_pointer_1572 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1572, align 8, !noalias !0
  %freeMins_2863_pointer_1572.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_1572.repack19, align 8, !noalias !0
  %freeMaxs_2862_pointer_1573 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1573, align 8, !noalias !0
  %freeMaxs_2862_pointer_1573.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_1573.repack21, align 8, !noalias !0
  %n_2854_pointer_1574 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %n_2854, ptr %n_2854_pointer_1574, align 4, !noalias !0
  %returnAddress_pointer_1575 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %sharer_pointer_1576 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %eraser_pointer_1577 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store ptr @returnAddress_1415, ptr %returnAddress_pointer_1575, align 8, !noalias !0
  store ptr @sharer_1499, ptr %sharer_pointer_1576, align 8, !noalias !0
  store ptr @eraser_1513, ptr %eraser_pointer_1577, align 8, !noalias !0
  musttail call tailcc void @loop_5_9_36_36_99_4992(i64 0, %Pos %z.i33, i64 %z.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1390(%Pos %v_r_3054_15_27_27_90_5043, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i44 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i44)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %queenRows_2864.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %queenRows_2864.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %queenRows_2864.unpack2 = load i64, ptr %queenRows_2864.elt1, align 8, !noalias !0
  %freeMins_2863_pointer_1393 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1393, align 8, !noalias !0
  %freeMins_2863.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %freeMins_2863.unpack5 = load i64, ptr %freeMins_2863.elt4, align 8, !noalias !0
  %tmp_5938_pointer_1394 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %tmp_5938.unpack = load i64, ptr %tmp_5938_pointer_1394, align 8, !noalias !0
  %tmp_5938.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %tmp_5938.unpack8 = load ptr, ptr %tmp_5938.elt7, align 8, !noalias !0
  %freeRows_2861_pointer_1395 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeRows_2861.unpack = load ptr, ptr %freeRows_2861_pointer_1395, align 8, !noalias !0
  %freeRows_2861.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeRows_2861.unpack11 = load i64, ptr %freeRows_2861.elt10, align 8, !noalias !0
  %freeMaxs_2862_pointer_1396 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1396, align 8, !noalias !0
  %freeMaxs_2862.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack14 = load i64, ptr %freeMaxs_2862.elt13, align 8, !noalias !0
  %n_2854_pointer_1397 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1397, align 4, !noalias !0
  %object.i = extractvalue %Pos %v_r_3054_15_27_27_90_5043, 1
  %isNull.i.i29 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i29, label %erasePositive.exit39, label %next.i.i30

next.i.i30:                                       ; preds = %entry
  %referenceCount.i.i31 = load i64, ptr %object.i, align 4
  %cond.i.i32 = icmp eq i64 %referenceCount.i.i31, 0
  br i1 %cond.i.i32, label %free.i.i35, label %decr.i.i33

decr.i.i33:                                       ; preds = %next.i.i30
  %referenceCount.1.i.i34 = add i64 %referenceCount.i.i31, -1
  store i64 %referenceCount.1.i.i34, ptr %object.i, align 4
  br label %erasePositive.exit39

free.i.i35:                                       ; preds = %next.i.i30
  %objectEraser.i.i36 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i37 = load ptr, ptr %objectEraser.i.i36, align 8
  %environment.i.i.i38 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i37(ptr %environment.i.i.i38)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit39

erasePositive.exit39:                             ; preds = %entry, %decr.i.i33, %free.i.i35
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i47 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 96
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i47
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit39
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
  %newStackPointer.i48 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i48, i64 96
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit39, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit39 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i48, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit39 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1588.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack11, ptr %stackPointer_1588.repack16, align 8, !noalias !0
  %queenRows_2864_pointer_1590 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1590, align 8, !noalias !0
  %queenRows_2864_pointer_1590.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %queenRows_2864.unpack2, ptr %queenRows_2864_pointer_1590.repack18, align 8, !noalias !0
  %freeMins_2863_pointer_1591 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1591, align 8, !noalias !0
  %freeMins_2863_pointer_1591.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %freeMins_2863.unpack5, ptr %freeMins_2863_pointer_1591.repack20, align 8, !noalias !0
  %freeMaxs_2862_pointer_1592 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1592, align 8, !noalias !0
  %freeMaxs_2862_pointer_1592.repack22 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %freeMaxs_2862.unpack14, ptr %freeMaxs_2862_pointer_1592.repack22, align 8, !noalias !0
  %n_2854_pointer_1593 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %n_2854, ptr %n_2854_pointer_1593, align 4, !noalias !0
  %returnAddress_pointer_1594 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_1595 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_1596 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_1398, ptr %returnAddress_pointer_1594, align 8, !noalias !0
  store ptr @sharer_1459, ptr %sharer_pointer_1595, align 8, !noalias !0
  store ptr @eraser_1471, ptr %eraser_pointer_1596, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeMaxs_2862.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i49 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i50 = load ptr, ptr %base_pointer.i49, align 8
  %varPointer.i = getelementptr i8, ptr %base.i50, i64 %freeMaxs_2862.unpack14
  %freeMaxs_2862_old_1598.elt24 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeMaxs_2862_old_1598.unpack25 = load ptr, ptr %freeMaxs_2862_old_1598.elt24, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeMaxs_2862_old_1598.unpack25, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeMaxs_2862_old_1598.unpack25, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %freeMaxs_2862_old_1598.unpack25, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %freeMaxs_2862_old_1598.unpack25, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %freeMaxs_2862_old_1598.unpack25, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %freeMaxs_2862_old_1598.unpack25)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %stackAllocate.exit, %decr.i.i, %free.i.i
  store i64 %tmp_5938.unpack, ptr %varPointer.i, align 8, !noalias !0
  store ptr %tmp_5938.unpack8, ptr %freeMaxs_2862_old_1598.elt24, align 8, !noalias !0
  %stackPointer.i52 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i54 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i55 = icmp ule ptr %stackPointer.i52, %limit.i54
  tail call void @llvm.assume(i1 %isInside.i55)
  %newStackPointer.i56 = getelementptr i8, ptr %stackPointer.i52, i64 -24
  store ptr %newStackPointer.i56, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1600 = load ptr, ptr %newStackPointer.i56, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1600(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1609(ptr %stackPointer) {
entry:
  %tmp_5938_1605.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_5938_1605.unpack2 = load ptr, ptr %tmp_5938_1605.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5938_1605.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5938_1605.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5938_1605.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1623(ptr %stackPointer) {
entry:
  %tmp_5938_1619.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_5938_1619.unpack2 = load ptr, ptr %tmp_5938_1619.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5938_1619.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5938_1619.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5938_1619.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5938_1619.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5938_1619.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5938_1619.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -112
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -96
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1373(%Pos %__14_14_77_5041, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i32 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %queenRows_2864_pointer_1376 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1376, align 8, !noalias !0
  %queenRows_2864.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack5 = load i64, ptr %queenRows_2864.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_1377 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1377, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_1378 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1378, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_1379 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1379, align 4, !noalias !0
  %object.i23 = extractvalue %Pos %__14_14_77_5041, 1
  %isNull.i.i24 = icmp eq ptr %object.i23, null
  br i1 %isNull.i.i24, label %erasePositive.exit, label %next.i.i25

next.i.i25:                                       ; preds = %entry
  %referenceCount.i.i26 = load i64, ptr %object.i23, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i25
  %referenceCount.1.i.i27 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i27, ptr %object.i23, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i25
  %objectEraser.i.i = getelementptr i8, ptr %object.i23, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i23, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i23)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %z.i = shl i64 %n_2854, 1
  %z.i33 = tail call %Pos @c_array_new(i64 %z.i)
  %object.i = extractvalue %Pos %z.i33, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i36 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 112
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i36
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
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
  %newStackPointer.i37 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i37, i64 112
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i37, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %queenRows_2864.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1631.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %queenRows_2864.unpack5, ptr %stackPointer_1631.repack13, align 8, !noalias !0
  %freeMins_2863_pointer_1633 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1633, align 8, !noalias !0
  %freeMins_2863_pointer_1633.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_1633.repack15, align 8, !noalias !0
  %tmp_5938_pointer_1634 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %pureApp_6127.elt = extractvalue %Pos %z.i33, 0
  store i64 %pureApp_6127.elt, ptr %tmp_5938_pointer_1634, align 8, !noalias !0
  %tmp_5938_pointer_1634.repack17 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %object.i, ptr %tmp_5938_pointer_1634.repack17, align 8, !noalias !0
  %freeRows_2861_pointer_1635 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %freeRows_2861.unpack, ptr %freeRows_2861_pointer_1635, align 8, !noalias !0
  %freeRows_2861_pointer_1635.repack19 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %freeRows_2861.unpack2, ptr %freeRows_2861_pointer_1635.repack19, align 8, !noalias !0
  %freeMaxs_2862_pointer_1636 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1636, align 8, !noalias !0
  %freeMaxs_2862_pointer_1636.repack21 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_1636.repack21, align 8, !noalias !0
  %n_2854_pointer_1637 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store i64 %n_2854, ptr %n_2854_pointer_1637, align 4, !noalias !0
  %returnAddress_pointer_1638 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %sharer_pointer_1639 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %eraser_pointer_1640 = getelementptr i8, ptr %common.ret.op.i, i64 104
  store ptr @returnAddress_1390, ptr %returnAddress_pointer_1638, align 8, !noalias !0
  store ptr @sharer_1609, ptr %sharer_pointer_1639, align 8, !noalias !0
  store ptr @eraser_1623, ptr %eraser_pointer_1640, align 8, !noalias !0
  musttail call tailcc void @loop_5_9_21_21_84_4931(i64 0, %Pos %z.i33, i64 %z.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1365(%Pos %v_r_3054_15_12_12_75_5040, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i44 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i44)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -88
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %tmp_5933_pointer_1368 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %tmp_5933.unpack = load i64, ptr %tmp_5933_pointer_1368, align 8, !noalias !0
  %tmp_5933.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %tmp_5933.unpack5 = load ptr, ptr %tmp_5933.elt4, align 8, !noalias !0
  %queenRows_2864_pointer_1369 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1369, align 8, !noalias !0
  %queenRows_2864.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack8 = load i64, ptr %queenRows_2864.elt7, align 8, !noalias !0
  %freeMins_2863_pointer_1370 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1370, align 8, !noalias !0
  %freeMins_2863.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack11 = load i64, ptr %freeMins_2863.elt10, align 8, !noalias !0
  %freeMaxs_2862_pointer_1371 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1371, align 8, !noalias !0
  %freeMaxs_2862.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack14 = load i64, ptr %freeMaxs_2862.elt13, align 8, !noalias !0
  %n_2854_pointer_1372 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1372, align 4, !noalias !0
  %object.i = extractvalue %Pos %v_r_3054_15_12_12_75_5040, 1
  %isNull.i.i29 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i29, label %erasePositive.exit39, label %next.i.i30

next.i.i30:                                       ; preds = %entry
  %referenceCount.i.i31 = load i64, ptr %object.i, align 4
  %cond.i.i32 = icmp eq i64 %referenceCount.i.i31, 0
  br i1 %cond.i.i32, label %free.i.i35, label %decr.i.i33

decr.i.i33:                                       ; preds = %next.i.i30
  %referenceCount.1.i.i34 = add i64 %referenceCount.i.i31, -1
  store i64 %referenceCount.1.i.i34, ptr %object.i, align 4
  br label %erasePositive.exit39

free.i.i35:                                       ; preds = %next.i.i30
  %objectEraser.i.i36 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i37 = load ptr, ptr %objectEraser.i.i36, align 8
  %environment.i.i.i38 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i37(ptr %environment.i.i.i38)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit39

erasePositive.exit39:                             ; preds = %entry, %decr.i.i33, %free.i.i35
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i47 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 96
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i47
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit39
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
  %newStackPointer.i48 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i48, i64 96
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit39, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit39 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i48, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit39 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1651.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1651.repack16, align 8, !noalias !0
  %queenRows_2864_pointer_1653 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1653, align 8, !noalias !0
  %queenRows_2864_pointer_1653.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %queenRows_2864.unpack8, ptr %queenRows_2864_pointer_1653.repack18, align 8, !noalias !0
  %freeMins_2863_pointer_1654 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1654, align 8, !noalias !0
  %freeMins_2863_pointer_1654.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %freeMins_2863.unpack11, ptr %freeMins_2863_pointer_1654.repack20, align 8, !noalias !0
  %freeMaxs_2862_pointer_1655 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1655, align 8, !noalias !0
  %freeMaxs_2862_pointer_1655.repack22 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store i64 %freeMaxs_2862.unpack14, ptr %freeMaxs_2862_pointer_1655.repack22, align 8, !noalias !0
  %n_2854_pointer_1656 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %n_2854, ptr %n_2854_pointer_1656, align 4, !noalias !0
  %returnAddress_pointer_1657 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_1658 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_1659 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_1373, ptr %returnAddress_pointer_1657, align 8, !noalias !0
  store ptr @sharer_1459, ptr %sharer_pointer_1658, align 8, !noalias !0
  store ptr @eraser_1471, ptr %eraser_pointer_1659, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %freeRows_2861.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i49 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i50 = load ptr, ptr %base_pointer.i49, align 8
  %varPointer.i = getelementptr i8, ptr %base.i50, i64 %freeRows_2861.unpack2
  %freeRows_2861_old_1661.elt24 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %freeRows_2861_old_1661.unpack25 = load ptr, ptr %freeRows_2861_old_1661.elt24, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %freeRows_2861_old_1661.unpack25, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %freeRows_2861_old_1661.unpack25, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %freeRows_2861_old_1661.unpack25, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %freeRows_2861_old_1661.unpack25, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %freeRows_2861_old_1661.unpack25, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %freeRows_2861_old_1661.unpack25)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %stackAllocate.exit, %decr.i.i, %free.i.i
  store i64 %tmp_5933.unpack, ptr %varPointer.i, align 8, !noalias !0
  store ptr %tmp_5933.unpack5, ptr %freeRows_2861_old_1661.elt24, align 8, !noalias !0
  %stackPointer.i52 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i54 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i55 = icmp ule ptr %stackPointer.i52, %limit.i54
  tail call void @llvm.assume(i1 %isInside.i55)
  %newStackPointer.i56 = getelementptr i8, ptr %stackPointer.i52, i64 -24
  store ptr %newStackPointer.i56, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1663 = load ptr, ptr %newStackPointer.i56, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1663(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1246(%Pos %v_r_3996_5_63_4929, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i40 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i40)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -96
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -88
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %queenRows_2864_pointer_1251 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %queenRows_2864.unpack = load ptr, ptr %queenRows_2864_pointer_1251, align 8, !noalias !0
  %queenRows_2864.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %queenRows_2864.unpack8 = load i64, ptr %queenRows_2864.elt7, align 8, !noalias !0
  %freeMins_2863_pointer_1252 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_1252, align 8, !noalias !0
  %freeMins_2863.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %freeMins_2863.unpack11 = load i64, ptr %freeMins_2863.elt10, align 8, !noalias !0
  %freeMaxs_2862_pointer_1253 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_1253, align 8, !noalias !0
  %freeMaxs_2862.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %freeMaxs_2862.unpack14 = load i64, ptr %freeMaxs_2862.elt13, align 8, !noalias !0
  %n_2854_pointer_1254 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_1254, align 4, !noalias !0
  %j_2878.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %j_2878.unpack5 = load i64, ptr %j_2878.elt4, align 8, !noalias !0
  %j_2878_pointer_1250 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %j_2878.unpack = load ptr, ptr %j_2878_pointer_1250, align 8, !noalias !0
  %i_6_4916_pointer_1249 = getelementptr i8, ptr %stackPointer.i, i64 -80
  %i_6_4916 = load i64, ptr %i_6_4916_pointer_1249, align 4, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_1336.repack16 = getelementptr i8, ptr %stackPointer.i, i64 -88
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1336.repack16, align 8, !noalias !0
  %i_6_4916_pointer_1338 = getelementptr i8, ptr %stackPointer.i, i64 -80
  store i64 %i_6_4916, ptr %i_6_4916_pointer_1338, align 4, !noalias !0
  %j_2878_pointer_1339 = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %j_2878.unpack, ptr %j_2878_pointer_1339, align 8, !noalias !0
  %j_2878_pointer_1339.repack18 = getelementptr i8, ptr %stackPointer.i, i64 -64
  store i64 %j_2878.unpack5, ptr %j_2878_pointer_1339.repack18, align 8, !noalias !0
  %queenRows_2864_pointer_1340 = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1340, align 8, !noalias !0
  %queenRows_2864_pointer_1340.repack20 = getelementptr i8, ptr %stackPointer.i, i64 -48
  store i64 %queenRows_2864.unpack8, ptr %queenRows_2864_pointer_1340.repack20, align 8, !noalias !0
  %freeMins_2863_pointer_1341 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1341, align 8, !noalias !0
  %freeMins_2863_pointer_1341.repack22 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store i64 %freeMins_2863.unpack11, ptr %freeMins_2863_pointer_1341.repack22, align 8, !noalias !0
  %freeMaxs_2862_pointer_1342 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1342, align 8, !noalias !0
  %freeMaxs_2862_pointer_1342.repack24 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %freeMaxs_2862.unpack14, ptr %freeMaxs_2862_pointer_1342.repack24, align 8, !noalias !0
  %n_2854_pointer_1343 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %n_2854, ptr %n_2854_pointer_1343, align 4, !noalias !0
  %sharer_pointer_1345 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_1346 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_1255, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_1280, ptr %sharer_pointer_1345, align 8, !noalias !0
  store ptr @eraser_1296, ptr %eraser_pointer_1346, align 8, !noalias !0
  %tag_1347 = extractvalue %Pos %v_r_3996_5_63_4929, 0
  switch i64 %tag_1347, label %label_1349 [
    i64 0, label %label_1354
    i64 1, label %label_1688
  ]

label_1349:                                       ; preds = %stackAllocate.exit
  ret void

label_1354:                                       ; preds = %stackAllocate.exit
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  musttail call tailcc void @returnAddress_1255(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_1688:                                       ; preds = %stackAllocate.exit
  %z.i = tail call %Pos @c_array_new(i64 %n_2854)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1688
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_1688, %next.i.i
  %currentStackPointer.i53 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i54 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i55 = getelementptr i8, ptr %currentStackPointer.i53, i64 112
  %isInside.not.i56 = icmp ugt ptr %nextStackPointer.i55, %limit.i54
  br i1 %isInside.not.i56, label %realloc.i59, label %stackAllocate.exit73

realloc.i59:                                      ; preds = %sharePositive.exit
  %base_pointer.i60 = getelementptr i8, ptr %stack, i64 16
  %base.i61 = load ptr, ptr %base_pointer.i60, align 8, !alias.scope !0
  %intStackPointer.i62 = ptrtoint ptr %currentStackPointer.i53 to i64
  %intBase.i63 = ptrtoint ptr %base.i61 to i64
  %size.i64 = sub i64 %intStackPointer.i62, %intBase.i63
  %nextSize.i65 = add i64 %size.i64, 112
  %leadingZeros.i.i66 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i65, i1 false)
  %numBits.i.i67 = sub nuw nsw i64 64, %leadingZeros.i.i66
  %result.i.i68 = shl nuw i64 1, %numBits.i.i67
  %newBase.i69 = tail call ptr @realloc(ptr %base.i61, i64 %result.i.i68)
  %newLimit.i70 = getelementptr i8, ptr %newBase.i69, i64 %result.i.i68
  %newStackPointer.i71 = getelementptr i8, ptr %newBase.i69, i64 %size.i64
  %newNextStackPointer.i72 = getelementptr i8, ptr %newStackPointer.i71, i64 112
  store ptr %newBase.i69, ptr %base_pointer.i60, align 8, !alias.scope !0
  store ptr %newLimit.i70, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit73

stackAllocate.exit73:                             ; preds = %sharePositive.exit, %realloc.i59
  %nextStackPointer.sink.i57 = phi ptr [ %newNextStackPointer.i72, %realloc.i59 ], [ %nextStackPointer.i55, %sharePositive.exit ]
  %common.ret.op.i58 = phi ptr [ %newStackPointer.i71, %realloc.i59 ], [ %currentStackPointer.i53, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i57, ptr %stackPointer_pointer.i, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i58, align 8, !noalias !0
  %stackPointer_1678.repack26 = getelementptr inbounds i8, ptr %common.ret.op.i58, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1678.repack26, align 8, !noalias !0
  %tmp_5933_pointer_1680 = getelementptr i8, ptr %common.ret.op.i58, i64 16
  %pureApp_6118.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_6118.elt, ptr %tmp_5933_pointer_1680, align 8, !noalias !0
  %tmp_5933_pointer_1680.repack28 = getelementptr i8, ptr %common.ret.op.i58, i64 24
  store ptr %object.i, ptr %tmp_5933_pointer_1680.repack28, align 8, !noalias !0
  %queenRows_2864_pointer_1681 = getelementptr i8, ptr %common.ret.op.i58, i64 32
  store ptr %queenRows_2864.unpack, ptr %queenRows_2864_pointer_1681, align 8, !noalias !0
  %queenRows_2864_pointer_1681.repack30 = getelementptr i8, ptr %common.ret.op.i58, i64 40
  store i64 %queenRows_2864.unpack8, ptr %queenRows_2864_pointer_1681.repack30, align 8, !noalias !0
  %freeMins_2863_pointer_1682 = getelementptr i8, ptr %common.ret.op.i58, i64 48
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1682, align 8, !noalias !0
  %freeMins_2863_pointer_1682.repack32 = getelementptr i8, ptr %common.ret.op.i58, i64 56
  store i64 %freeMins_2863.unpack11, ptr %freeMins_2863_pointer_1682.repack32, align 8, !noalias !0
  %freeMaxs_2862_pointer_1683 = getelementptr i8, ptr %common.ret.op.i58, i64 64
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1683, align 8, !noalias !0
  %freeMaxs_2862_pointer_1683.repack34 = getelementptr i8, ptr %common.ret.op.i58, i64 72
  store i64 %freeMaxs_2862.unpack14, ptr %freeMaxs_2862_pointer_1683.repack34, align 8, !noalias !0
  %n_2854_pointer_1684 = getelementptr i8, ptr %common.ret.op.i58, i64 80
  store i64 %n_2854, ptr %n_2854_pointer_1684, align 4, !noalias !0
  %returnAddress_pointer_1685 = getelementptr i8, ptr %common.ret.op.i58, i64 88
  %sharer_pointer_1686 = getelementptr i8, ptr %common.ret.op.i58, i64 96
  %eraser_pointer_1687 = getelementptr i8, ptr %common.ret.op.i58, i64 104
  store ptr @returnAddress_1365, ptr %returnAddress_pointer_1685, align 8, !noalias !0
  store ptr @sharer_1499, ptr %sharer_pointer_1686, align 8, !noalias !0
  store ptr @eraser_1513, ptr %eraser_pointer_1687, align 8, !noalias !0
  musttail call tailcc void @loop_5_9_6_6_69_4941(i64 0, i64 %n_2854, %Pos %z.i, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_4913(i64 %i_6_4916, %Reference %freeRows_2861, %Reference %j_2878, %Reference %queenRows_2864, %Reference %freeMins_2863, %Reference %freeMaxs_2862, i64 %n_2854, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_4916, 10
  %stackPointer_pointer.i17 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_1719, label %label_1245

label_1245:                                       ; preds = %entry
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i17, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i17, align 8, !alias.scope !0
  %returnAddress_1242 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1242(%Pos zeroinitializer, ptr %stack)
  ret void

label_1719:                                       ; preds = %entry
  %limit_pointer.i18 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i17, align 8, !alias.scope !0
  %limit.i19 = load ptr, ptr %limit_pointer.i18, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 120
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i19
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_1719
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

stackAllocate.exit:                               ; preds = %label_1719, %realloc.i
  %limit.i2632 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i19, %label_1719 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_1719 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i20, %realloc.i ], [ %currentStackPointer.i, %label_1719 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i17, align 8
  %freeRows_2861.elt = extractvalue %Reference %freeRows_2861, 0
  store ptr %freeRows_2861.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1703.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %freeRows_2861.elt2 = extractvalue %Reference %freeRows_2861, 1
  store i64 %freeRows_2861.elt2, ptr %stackPointer_1703.repack1, align 8, !noalias !0
  %i_6_4916_pointer_1705 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_6_4916, ptr %i_6_4916_pointer_1705, align 4, !noalias !0
  %j_2878_pointer_1706 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %j_2878.elt = extractvalue %Reference %j_2878, 0
  store ptr %j_2878.elt, ptr %j_2878_pointer_1706, align 8, !noalias !0
  %j_2878_pointer_1706.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %j_2878.elt4 = extractvalue %Reference %j_2878, 1
  store i64 %j_2878.elt4, ptr %j_2878_pointer_1706.repack3, align 8, !noalias !0
  %queenRows_2864_pointer_1707 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %queenRows_2864.elt = extractvalue %Reference %queenRows_2864, 0
  store ptr %queenRows_2864.elt, ptr %queenRows_2864_pointer_1707, align 8, !noalias !0
  %queenRows_2864_pointer_1707.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %queenRows_2864.elt6 = extractvalue %Reference %queenRows_2864, 1
  store i64 %queenRows_2864.elt6, ptr %queenRows_2864_pointer_1707.repack5, align 8, !noalias !0
  %freeMins_2863_pointer_1708 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %freeMins_2863.elt = extractvalue %Reference %freeMins_2863, 0
  store ptr %freeMins_2863.elt, ptr %freeMins_2863_pointer_1708, align 8, !noalias !0
  %freeMins_2863_pointer_1708.repack7 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %freeMins_2863.elt8 = extractvalue %Reference %freeMins_2863, 1
  store i64 %freeMins_2863.elt8, ptr %freeMins_2863_pointer_1708.repack7, align 8, !noalias !0
  %freeMaxs_2862_pointer_1709 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %freeMaxs_2862.elt = extractvalue %Reference %freeMaxs_2862, 0
  store ptr %freeMaxs_2862.elt, ptr %freeMaxs_2862_pointer_1709, align 8, !noalias !0
  %freeMaxs_2862_pointer_1709.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %freeMaxs_2862.elt10 = extractvalue %Reference %freeMaxs_2862, 1
  store i64 %freeMaxs_2862.elt10, ptr %freeMaxs_2862_pointer_1709.repack9, align 8, !noalias !0
  %n_2854_pointer_1710 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_1710, align 4, !noalias !0
  %returnAddress_pointer_1711 = getelementptr i8, ptr %common.ret.op.i, i64 96
  %sharer_pointer_1712 = getelementptr i8, ptr %common.ret.op.i, i64 104
  %eraser_pointer_1713 = getelementptr i8, ptr %common.ret.op.i, i64 112
  store ptr @returnAddress_1246, ptr %returnAddress_pointer_1711, align 8, !noalias !0
  store ptr @sharer_1280, ptr %sharer_pointer_1712, align 8, !noalias !0
  store ptr @eraser_1296, ptr %eraser_pointer_1713, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %j_2878.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i21 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i22 = load ptr, ptr %base_pointer.i21, align 8
  %varPointer.i = getelementptr i8, ptr %base.i22, i64 %j_2878.elt4
  %j_2878_old_1715.elt11 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %j_2878_old_1715.unpack12 = load ptr, ptr %j_2878_old_1715.elt11, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %j_2878_old_1715.unpack12, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %j_2878_old_1715.unpack12, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %j_2878_old_1715.unpack12, align 4
  %get_6160.unpack15.pre = load ptr, ptr %j_2878_old_1715.elt11, align 8, !noalias !0
  %stackPointer.i24.pre = load ptr, ptr %stackPointer_pointer.i17, align 8, !alias.scope !0
  %limit.i26.pre = load ptr, ptr %limit_pointer.i18, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %limit.i26 = phi ptr [ %limit.i2632, %stackAllocate.exit ], [ %limit.i26.pre, %next.i.i ]
  %stackPointer.i24 = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %stackPointer.i24.pre, %next.i.i ]
  %get_6160.unpack15 = phi ptr [ null, %stackAllocate.exit ], [ %get_6160.unpack15.pre, %next.i.i ]
  %get_6160.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6160.unpack, 0
  %get_616016 = insertvalue %Pos %0, ptr %get_6160.unpack15, 1
  %isInside.i27 = icmp ule ptr %stackPointer.i24, %limit.i26
  tail call void @llvm.assume(i1 %isInside.i27)
  %newStackPointer.i28 = getelementptr i8, ptr %stackPointer.i24, i64 -24
  store ptr %newStackPointer.i28, ptr %stackPointer_pointer.i17, align 8, !alias.scope !0
  %returnAddress_1716 = load ptr, ptr %newStackPointer.i28, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1716(%Pos %get_616016, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1720(%Pos %__6161, ptr %stack) {
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
  %j_2878.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %j_2878.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %j_2878.unpack2 = load i64, ptr %j_2878.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__6161, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %j_2878.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %j_2878.unpack2
  %j_2878_old_1724.elt4 = getelementptr inbounds i8, ptr %varPointer.i, i64 8
  %j_2878_old_1724.unpack5 = load ptr, ptr %j_2878_old_1724.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %j_2878_old_1724.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit
  %referenceCount.i.i = load i64, ptr %j_2878_old_1724.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %j_2878_old_1724.unpack5, align 4
  %get_6162.unpack8.pre = load ptr, ptr %j_2878_old_1724.elt4, align 8, !noalias !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %erasePositive.exit, %next.i.i
  %get_6162.unpack8 = phi ptr [ null, %erasePositive.exit ], [ %get_6162.unpack8.pre, %next.i.i ]
  %get_6162.unpack = load i64, ptr %varPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6162.unpack, 0
  %get_61629 = insertvalue %Pos %0, ptr %get_6162.unpack8, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1725 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1725(%Pos %get_61629, ptr nonnull %stack)
  ret void
}

define void @sharer_1729(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1733(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_458(%Pos %v_r_3054_15_4512, ptr %stack) {
entry:
  %stackPointer_pointer.i28 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i29 = load ptr, ptr %stackPointer_pointer.i28, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i29, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i34 = icmp ule ptr %stackPointer.i29, %limit.i
  tail call void @llvm.assume(i1 %isInside.i34)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i29, i64 -72
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i28, align 8, !alias.scope !0
  %freeRows_2861.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %freeRows_2861.elt1 = getelementptr i8, ptr %stackPointer.i29, i64 -64
  %freeRows_2861.unpack2 = load i64, ptr %freeRows_2861.elt1, align 8, !noalias !0
  %tmp_5900_pointer_461 = getelementptr i8, ptr %stackPointer.i29, i64 -56
  %tmp_5900.unpack = load i64, ptr %tmp_5900_pointer_461, align 8, !noalias !0
  %tmp_5900.elt4 = getelementptr i8, ptr %stackPointer.i29, i64 -48
  %tmp_5900.unpack5 = load ptr, ptr %tmp_5900.elt4, align 8, !noalias !0
  %freeMins_2863_pointer_462 = getelementptr i8, ptr %stackPointer.i29, i64 -40
  %freeMins_2863.unpack = load ptr, ptr %freeMins_2863_pointer_462, align 8, !noalias !0
  %freeMins_2863.elt7 = getelementptr i8, ptr %stackPointer.i29, i64 -32
  %freeMins_2863.unpack8 = load i64, ptr %freeMins_2863.elt7, align 8, !noalias !0
  %freeMaxs_2862_pointer_463 = getelementptr i8, ptr %stackPointer.i29, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_463, align 8, !noalias !0
  %freeMaxs_2862.elt10 = getelementptr i8, ptr %stackPointer.i29, i64 -16
  %freeMaxs_2862.unpack11 = load i64, ptr %freeMaxs_2862.elt10, align 8, !noalias !0
  %n_2854_pointer_464 = getelementptr i8, ptr %stackPointer.i29, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_464, align 4, !noalias !0
  %object.i = extractvalue %Pos %v_r_3054_15_4512, 1
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
  %base_pointer.i19 = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i28, align 8
  %base.i21 = load ptr, ptr %base_pointer.i19, align 8
  %intStack.i22 = ptrtoint ptr %stackPointer.i20 to i64
  %intBase.i23 = ptrtoint ptr %base.i21 to i64
  %offset.i24 = sub i64 %intStack.i22, %intBase.i23
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i35 = load ptr, ptr %prompt_pointer.i, align 8
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i20, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i38
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %nextSize.i = add i64 %offset.i24, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i21, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i42 = getelementptr i8, ptr %newBase.i, i64 %offset.i24
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i42, i64 40
  store ptr %newBase.i, ptr %base_pointer.i19, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i48 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i38, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i42, %realloc.i ], [ %stackPointer.i20, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i28, align 8
  store i64 %tmp_5900.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_474.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_5900.unpack5, ptr %stackPointer_474.repack13, align 8, !noalias !0
  %returnAddress_pointer_476 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_477 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_478 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_465, ptr %returnAddress_pointer_476, align 8, !noalias !0
  store ptr @sharer_378, ptr %sharer_pointer_477, align 8, !noalias !0
  store ptr @eraser_382, ptr %eraser_pointer_478, align 8, !noalias !0
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i28, align 8
  %base.i = load ptr, ptr %base_pointer.i19, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt.i44 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i49 = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i50 = icmp ugt ptr %nextStackPointer.i49, %limit.i48
  br i1 %isInside.not.i50, label %realloc.i53, label %stackAllocate.exit67

realloc.i53:                                      ; preds = %stackAllocate.exit
  %nextSize.i59 = add i64 %offset.i, 40
  %leadingZeros.i.i60 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i59, i1 false)
  %numBits.i.i61 = sub nuw nsw i64 64, %leadingZeros.i.i60
  %result.i.i62 = shl nuw i64 1, %numBits.i.i61
  %newBase.i63 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i62)
  %newLimit.i64 = getelementptr i8, ptr %newBase.i63, i64 %result.i.i62
  %newStackPointer.i65 = getelementptr i8, ptr %newBase.i63, i64 %offset.i
  %newNextStackPointer.i66 = getelementptr i8, ptr %newStackPointer.i65, i64 40
  store ptr %newBase.i63, ptr %base_pointer.i19, align 8, !alias.scope !0
  store ptr %newLimit.i64, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit67

stackAllocate.exit67:                             ; preds = %stackAllocate.exit, %realloc.i53
  %limit.i71 = phi ptr [ %newLimit.i64, %realloc.i53 ], [ %limit.i48, %stackAllocate.exit ]
  %nextStackPointer.sink.i51 = phi ptr [ %newNextStackPointer.i66, %realloc.i53 ], [ %nextStackPointer.i49, %stackAllocate.exit ]
  %common.ret.op.i52 = phi ptr [ %newStackPointer.i65, %realloc.i53 ], [ %stackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i51, ptr %stackPointer_pointer.i28, align 8
  store i64 1, ptr %common.ret.op.i52, align 8, !noalias !0
  %stackPointer_1233.repack15 = getelementptr inbounds i8, ptr %common.ret.op.i52, i64 8
  store ptr null, ptr %stackPointer_1233.repack15, align 8, !noalias !0
  %returnAddress_pointer_1235 = getelementptr i8, ptr %common.ret.op.i52, i64 16
  %sharer_pointer_1236 = getelementptr i8, ptr %common.ret.op.i52, i64 24
  %eraser_pointer_1237 = getelementptr i8, ptr %common.ret.op.i52, i64 32
  store ptr @returnAddress_1224, ptr %returnAddress_pointer_1235, align 8, !noalias !0
  store ptr @sharer_378, ptr %sharer_pointer_1236, align 8, !noalias !0
  store ptr @eraser_382, ptr %eraser_pointer_1237, align 8, !noalias !0
  %nextStackPointer.i72 = getelementptr i8, ptr %nextStackPointer.sink.i51, i64 40
  %isInside.not.i73 = icmp ugt ptr %nextStackPointer.i72, %limit.i71
  br i1 %isInside.not.i73, label %realloc.i76, label %stackAllocate.exit90

realloc.i76:                                      ; preds = %stackAllocate.exit67
  %base.i78 = load ptr, ptr %base_pointer.i19, align 8, !alias.scope !0
  %intStackPointer.i79 = ptrtoint ptr %nextStackPointer.sink.i51 to i64
  %intBase.i80 = ptrtoint ptr %base.i78 to i64
  %size.i81 = sub i64 %intStackPointer.i79, %intBase.i80
  %nextSize.i82 = add i64 %size.i81, 40
  %leadingZeros.i.i83 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i82, i1 false)
  %numBits.i.i84 = sub nuw nsw i64 64, %leadingZeros.i.i83
  %result.i.i85 = shl nuw i64 1, %numBits.i.i84
  %newBase.i86 = tail call ptr @realloc(ptr %base.i78, i64 %result.i.i85)
  %newLimit.i87 = getelementptr i8, ptr %newBase.i86, i64 %result.i.i85
  %newStackPointer.i88 = getelementptr i8, ptr %newBase.i86, i64 %size.i81
  %newNextStackPointer.i89 = getelementptr i8, ptr %newStackPointer.i88, i64 40
  store ptr %newBase.i86, ptr %base_pointer.i19, align 8, !alias.scope !0
  store ptr %newLimit.i87, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit90

stackAllocate.exit90:                             ; preds = %stackAllocate.exit67, %realloc.i76
  %limit.i19.i = phi ptr [ %newLimit.i87, %realloc.i76 ], [ %limit.i71, %stackAllocate.exit67 ]
  %nextStackPointer.sink.i74 = phi ptr [ %newNextStackPointer.i89, %realloc.i76 ], [ %nextStackPointer.i72, %stackAllocate.exit67 ]
  %common.ret.op.i75 = phi ptr [ %newStackPointer.i88, %realloc.i76 ], [ %nextStackPointer.sink.i51, %stackAllocate.exit67 ]
  store ptr %nextStackPointer.sink.i74, ptr %stackPointer_pointer.i28, align 8
  store ptr %prompt.i44, ptr %common.ret.op.i75, align 8, !noalias !0
  %stackPointer_1736.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i75, i64 8
  store i64 %offset.i, ptr %stackPointer_1736.repack16, align 8, !noalias !0
  %returnAddress_pointer_1738 = getelementptr i8, ptr %common.ret.op.i75, i64 16
  %sharer_pointer_1739 = getelementptr i8, ptr %common.ret.op.i75, i64 24
  %eraser_pointer_1740 = getelementptr i8, ptr %common.ret.op.i75, i64 32
  store ptr @returnAddress_1720, ptr %returnAddress_pointer_1738, align 8, !noalias !0
  store ptr @sharer_1729, ptr %sharer_pointer_1739, align 8, !noalias !0
  store ptr @eraser_1733, ptr %eraser_pointer_1740, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i74, i64 120
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i19.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit90
  %base.i.i = load ptr, ptr %base_pointer.i19, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i74 to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 120
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i20.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i20.i, i64 120
  store ptr %newBase.i.i, ptr %base_pointer.i19, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit90
  %limit.i2632.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i19.i, %stackAllocate.exit90 ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit90 ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i20.i, %realloc.i.i ], [ %nextStackPointer.sink.i74, %stackAllocate.exit90 ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i28, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_1703.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %freeRows_2861.unpack2, ptr %stackPointer_1703.repack1.i, align 8, !noalias !0
  %i_6_4916_pointer_1705.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 1, ptr %i_6_4916_pointer_1705.i, align 4, !noalias !0
  %j_2878_pointer_1706.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %prompt.i44, ptr %j_2878_pointer_1706.i, align 8, !noalias !0
  %j_2878_pointer_1706.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %offset.i, ptr %j_2878_pointer_1706.repack3.i, align 8, !noalias !0
  %queenRows_2864_pointer_1707.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %prompt.i35, ptr %queenRows_2864_pointer_1707.i, align 8, !noalias !0
  %queenRows_2864_pointer_1707.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store i64 %offset.i24, ptr %queenRows_2864_pointer_1707.repack5.i, align 8, !noalias !0
  %freeMins_2863_pointer_1708.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr %freeMins_2863.unpack, ptr %freeMins_2863_pointer_1708.i, align 8, !noalias !0
  %freeMins_2863_pointer_1708.repack7.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store i64 %freeMins_2863.unpack8, ptr %freeMins_2863_pointer_1708.repack7.i, align 8, !noalias !0
  %freeMaxs_2862_pointer_1709.i = getelementptr i8, ptr %common.ret.op.i.i, i64 72
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1709.i, align 8, !noalias !0
  %freeMaxs_2862_pointer_1709.repack9.i = getelementptr i8, ptr %common.ret.op.i.i, i64 80
  store i64 %freeMaxs_2862.unpack11, ptr %freeMaxs_2862_pointer_1709.repack9.i, align 8, !noalias !0
  %n_2854_pointer_1710.i = getelementptr i8, ptr %common.ret.op.i.i, i64 88
  store i64 %n_2854, ptr %n_2854_pointer_1710.i, align 4, !noalias !0
  %returnAddress_pointer_1711.i = getelementptr i8, ptr %common.ret.op.i.i, i64 96
  %sharer_pointer_1712.i = getelementptr i8, ptr %common.ret.op.i.i, i64 104
  %eraser_pointer_1713.i = getelementptr i8, ptr %common.ret.op.i.i, i64 112
  store ptr @returnAddress_1246, ptr %returnAddress_pointer_1711.i, align 8, !noalias !0
  store ptr @sharer_1280, ptr %sharer_pointer_1712.i, align 8, !noalias !0
  store ptr @eraser_1296, ptr %eraser_pointer_1713.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %prompt.i44, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i21.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i22.i = load ptr, ptr %base_pointer.i21.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i22.i, i64 %offset.i
  %j_2878_old_1715.elt11.i = getelementptr inbounds i8, ptr %varPointer.i.i, i64 8
  %j_2878_old_1715.unpack12.i = load ptr, ptr %j_2878_old_1715.elt11.i, align 8, !noalias !0
  %isNull.i.i.i = icmp eq ptr %j_2878_old_1715.unpack12.i, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit.i
  %referenceCount.i.i.i = load i64, ptr %j_2878_old_1715.unpack12.i, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %j_2878_old_1715.unpack12.i, align 4
  %get_6160.unpack15.pre.i = load ptr, ptr %j_2878_old_1715.elt11.i, align 8, !noalias !0
  %stackPointer.i24.pre.i = load ptr, ptr %stackPointer_pointer.i28, align 8, !alias.scope !0
  %limit.i26.pre.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit.i
  %limit.i26.i = phi ptr [ %limit.i2632.i, %stackAllocate.exit.i ], [ %limit.i26.pre.i, %next.i.i.i ]
  %stackPointer.i24.i = phi ptr [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ], [ %stackPointer.i24.pre.i, %next.i.i.i ]
  %get_6160.unpack15.i = phi ptr [ null, %stackAllocate.exit.i ], [ %get_6160.unpack15.pre.i, %next.i.i.i ]
  %get_6160.unpack.i = load i64, ptr %varPointer.i.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %get_6160.unpack.i, 0
  %get_616016.i = insertvalue %Pos %0, ptr %get_6160.unpack15.i, 1
  %isInside.i27.i = icmp ule ptr %stackPointer.i24.i, %limit.i26.i
  tail call void @llvm.assume(i1 %isInside.i27.i)
  %newStackPointer.i28.i = getelementptr i8, ptr %stackPointer.i24.i, i64 -24
  store ptr %newStackPointer.i28.i, ptr %stackPointer_pointer.i28, align 8, !alias.scope !0
  %returnAddress_1716.i = load ptr, ptr %newStackPointer.i28.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1716.i(%Pos %get_616016.i, ptr nonnull %stack)
  ret void
}

define void @sharer_1746(ptr %stackPointer) {
entry:
  %tmp_5900_1742.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_5900_1742.unpack2 = load ptr, ptr %tmp_5900_1742.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5900_1742.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5900_1742.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5900_1742.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1758(ptr %stackPointer) {
entry:
  %tmp_5900_1754.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_5900_1754.unpack2 = load ptr, ptr %tmp_5900_1754.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5900_1754.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5900_1754.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5900_1754.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5900_1754.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5900_1754.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5900_1754.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -80
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_429(%Pos %v_r_3054_15_4497, ptr %stack) {
entry:
  %stackPointer_pointer.i25 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i26 = load ptr, ptr %stackPointer_pointer.i25, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i26, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i31 = icmp ule ptr %stackPointer.i26, %limit.i
  tail call void @llvm.assume(i1 %isInside.i31)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i26, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i25, align 8, !alias.scope !0
  %tmp_5895.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_5895.elt1 = getelementptr i8, ptr %stackPointer.i26, i64 -48
  %tmp_5895.unpack2 = load ptr, ptr %tmp_5895.elt1, align 8, !noalias !0
  %freeRows_2861_pointer_432 = getelementptr i8, ptr %stackPointer.i26, i64 -40
  %freeRows_2861.unpack = load ptr, ptr %freeRows_2861_pointer_432, align 8, !noalias !0
  %freeRows_2861.elt4 = getelementptr i8, ptr %stackPointer.i26, i64 -32
  %freeRows_2861.unpack5 = load i64, ptr %freeRows_2861.elt4, align 8, !noalias !0
  %freeMaxs_2862_pointer_433 = getelementptr i8, ptr %stackPointer.i26, i64 -24
  %freeMaxs_2862.unpack = load ptr, ptr %freeMaxs_2862_pointer_433, align 8, !noalias !0
  %freeMaxs_2862.elt7 = getelementptr i8, ptr %stackPointer.i26, i64 -16
  %freeMaxs_2862.unpack8 = load i64, ptr %freeMaxs_2862.elt7, align 8, !noalias !0
  %n_2854_pointer_434 = getelementptr i8, ptr %stackPointer.i26, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_434, align 4, !noalias !0
  %object.i20 = extractvalue %Pos %v_r_3054_15_4497, 1
  %isNull.i.i21 = icmp eq ptr %object.i20, null
  br i1 %isNull.i.i21, label %erasePositive.exit, label %next.i.i22

next.i.i22:                                       ; preds = %entry
  %referenceCount.i.i23 = load i64, ptr %object.i20, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i23, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i22
  %referenceCount.1.i.i24 = add i64 %referenceCount.i.i23, -1
  store i64 %referenceCount.1.i.i24, ptr %object.i20, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i22
  %objectEraser.i.i = getelementptr i8, ptr %object.i20, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i20, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i20)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i25, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i32 = load ptr, ptr %prompt_pointer.i, align 8
  %limit.i35 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i35
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %nextSize.i = add i64 %offset.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i39 = getelementptr i8, ptr %newBase.i, i64 %offset.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i39, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i39, %realloc.i ], [ %stackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i25, align 8
  store i64 %tmp_5895.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_444.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_5895.unpack2, ptr %stackPointer_444.repack10, align 8, !noalias !0
  %returnAddress_pointer_446 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_447 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_448 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_435, ptr %returnAddress_pointer_446, align 8, !noalias !0
  store ptr @sharer_378, ptr %sharer_pointer_447, align 8, !noalias !0
  store ptr @eraser_382, ptr %eraser_pointer_448, align 8, !noalias !0
  %z.i = tail call %Pos @c_array_new(i64 0)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %currentStackPointer.i42 = load ptr, ptr %stackPointer_pointer.i25, align 8, !alias.scope !0
  %limit.i43 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i44 = getelementptr i8, ptr %currentStackPointer.i42, i64 96
  %isInside.not.i45 = icmp ugt ptr %nextStackPointer.i44, %limit.i43
  br i1 %isInside.not.i45, label %realloc.i48, label %stackAllocate.exit62

realloc.i48:                                      ; preds = %sharePositive.exit
  %base.i50 = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i51 = ptrtoint ptr %currentStackPointer.i42 to i64
  %intBase.i52 = ptrtoint ptr %base.i50 to i64
  %size.i53 = sub i64 %intStackPointer.i51, %intBase.i52
  %nextSize.i54 = add i64 %size.i53, 96
  %leadingZeros.i.i55 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i54, i1 false)
  %numBits.i.i56 = sub nuw nsw i64 64, %leadingZeros.i.i55
  %result.i.i57 = shl nuw i64 1, %numBits.i.i56
  %newBase.i58 = tail call ptr @realloc(ptr %base.i50, i64 %result.i.i57)
  %newLimit.i59 = getelementptr i8, ptr %newBase.i58, i64 %result.i.i57
  %newStackPointer.i60 = getelementptr i8, ptr %newBase.i58, i64 %size.i53
  %newNextStackPointer.i61 = getelementptr i8, ptr %newStackPointer.i60, i64 96
  store ptr %newBase.i58, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i59, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit62

stackAllocate.exit62:                             ; preds = %sharePositive.exit, %realloc.i48
  %nextStackPointer.sink.i46 = phi ptr [ %newNextStackPointer.i61, %realloc.i48 ], [ %nextStackPointer.i44, %sharePositive.exit ]
  %common.ret.op.i47 = phi ptr [ %newStackPointer.i60, %realloc.i48 ], [ %currentStackPointer.i42, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i46, ptr %stackPointer_pointer.i25, align 8
  store ptr %freeRows_2861.unpack, ptr %common.ret.op.i47, align 8, !noalias !0
  %stackPointer_1765.repack12 = getelementptr inbounds i8, ptr %common.ret.op.i47, i64 8
  store i64 %freeRows_2861.unpack5, ptr %stackPointer_1765.repack12, align 8, !noalias !0
  %tmp_5900_pointer_1767 = getelementptr i8, ptr %common.ret.op.i47, i64 16
  %pureApp_6036.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_6036.elt, ptr %tmp_5900_pointer_1767, align 8, !noalias !0
  %tmp_5900_pointer_1767.repack14 = getelementptr i8, ptr %common.ret.op.i47, i64 24
  store ptr %object.i, ptr %tmp_5900_pointer_1767.repack14, align 8, !noalias !0
  %freeMins_2863_pointer_1768 = getelementptr i8, ptr %common.ret.op.i47, i64 32
  store ptr %prompt.i32, ptr %freeMins_2863_pointer_1768, align 8, !noalias !0
  %freeMins_2863_pointer_1768.repack16 = getelementptr i8, ptr %common.ret.op.i47, i64 40
  store i64 %offset.i, ptr %freeMins_2863_pointer_1768.repack16, align 8, !noalias !0
  %freeMaxs_2862_pointer_1769 = getelementptr i8, ptr %common.ret.op.i47, i64 48
  store ptr %freeMaxs_2862.unpack, ptr %freeMaxs_2862_pointer_1769, align 8, !noalias !0
  %freeMaxs_2862_pointer_1769.repack18 = getelementptr i8, ptr %common.ret.op.i47, i64 56
  store i64 %freeMaxs_2862.unpack8, ptr %freeMaxs_2862_pointer_1769.repack18, align 8, !noalias !0
  %n_2854_pointer_1770 = getelementptr i8, ptr %common.ret.op.i47, i64 64
  store i64 %n_2854, ptr %n_2854_pointer_1770, align 4, !noalias !0
  %returnAddress_pointer_1771 = getelementptr i8, ptr %common.ret.op.i47, i64 72
  %sharer_pointer_1772 = getelementptr i8, ptr %common.ret.op.i47, i64 80
  %eraser_pointer_1773 = getelementptr i8, ptr %common.ret.op.i47, i64 88
  store ptr @returnAddress_458, ptr %returnAddress_pointer_1771, align 8, !noalias !0
  store ptr @sharer_1746, ptr %sharer_pointer_1772, align 8, !noalias !0
  store ptr @eraser_1758, ptr %eraser_pointer_1773, align 8, !noalias !0
  br i1 %isNull.i.i, label %erasePositive.exit35.i, label %next.i.i26.i

next.i.i26.i:                                     ; preds = %stackAllocate.exit62
  %referenceCount.i.i27.i = load i64, ptr %object.i, align 4
  %cond.i.i28.i = icmp eq i64 %referenceCount.i.i27.i, 0
  br i1 %cond.i.i28.i, label %free.i.i31.i, label %decr.i.i29.i

decr.i.i29.i:                                     ; preds = %next.i.i26.i
  %referenceCount.1.i.i30.i = add i64 %referenceCount.i.i27.i, -1
  store i64 %referenceCount.1.i.i30.i, ptr %object.i, align 4
  br label %erasePositive.exit35.i

free.i.i31.i:                                     ; preds = %next.i.i26.i
  %objectEraser.i.i32.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i33.i = load ptr, ptr %objectEraser.i.i32.i, align 8
  %environment.i.i.i34.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i33.i(ptr %environment.i.i.i34.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit35.i

erasePositive.exit35.i:                           ; preds = %free.i.i31.i, %decr.i.i29.i, %stackAllocate.exit62
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i25, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i.i, ptr %stackPointer_pointer.i25, align 8, !alias.scope !0
  %returnAddress_453.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_453.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1778(ptr %stackPointer) {
entry:
  %tmp_5895_1774.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_5895_1774.unpack2 = load ptr, ptr %tmp_5895_1774.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5895_1774.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5895_1774.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5895_1774.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1788(ptr %stackPointer) {
entry:
  %tmp_5895_1784.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %tmp_5895_1784.unpack2 = load ptr, ptr %tmp_5895_1784.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5895_1784.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5895_1784.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5895_1784.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5895_1784.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5895_1784.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5895_1784.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_400(%Pos %v_r_3054_15_4482, ptr %stack) {
entry:
  %stackPointer_pointer.i20 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i21 = load ptr, ptr %stackPointer_pointer.i20, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i21, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i26 = icmp ule ptr %stackPointer.i21, %limit.i
  tail call void @llvm.assume(i1 %isInside.i26)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i21, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i20, align 8, !alias.scope !0
  %tmp_5891.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_5891.elt1 = getelementptr i8, ptr %stackPointer.i21, i64 -32
  %tmp_5891.unpack2 = load ptr, ptr %tmp_5891.elt1, align 8, !noalias !0
  %freeRows_2861_pointer_403 = getelementptr i8, ptr %stackPointer.i21, i64 -24
  %freeRows_2861.unpack = load ptr, ptr %freeRows_2861_pointer_403, align 8, !noalias !0
  %freeRows_2861.elt4 = getelementptr i8, ptr %stackPointer.i21, i64 -16
  %freeRows_2861.unpack5 = load i64, ptr %freeRows_2861.elt4, align 8, !noalias !0
  %n_2854_pointer_404 = getelementptr i8, ptr %stackPointer.i21, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_404, align 4, !noalias !0
  %object.i15 = extractvalue %Pos %v_r_3054_15_4482, 1
  %isNull.i.i16 = icmp eq ptr %object.i15, null
  br i1 %isNull.i.i16, label %erasePositive.exit, label %next.i.i17

next.i.i17:                                       ; preds = %entry
  %referenceCount.i.i18 = load i64, ptr %object.i15, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i18, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i17
  %referenceCount.1.i.i19 = add i64 %referenceCount.i.i18, -1
  store i64 %referenceCount.1.i.i19, ptr %object.i15, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i17
  %objectEraser.i.i = getelementptr i8, ptr %object.i15, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i15, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i15)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i20, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i27 = load ptr, ptr %prompt_pointer.i, align 8
  %limit.i30 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i30
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %nextSize.i = add i64 %offset.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i34 = getelementptr i8, ptr %newBase.i, i64 %offset.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i34, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i34, %realloc.i ], [ %stackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i20, align 8
  store i64 %tmp_5891.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_414.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_5891.unpack2, ptr %stackPointer_414.repack7, align 8, !noalias !0
  %returnAddress_pointer_416 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_417 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_418 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_405, ptr %returnAddress_pointer_416, align 8, !noalias !0
  store ptr @sharer_378, ptr %sharer_pointer_417, align 8, !noalias !0
  store ptr @eraser_382, ptr %eraser_pointer_418, align 8, !noalias !0
  %z.i = tail call %Pos @c_array_new(i64 0)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %currentStackPointer.i37 = load ptr, ptr %stackPointer_pointer.i20, align 8, !alias.scope !0
  %limit.i38 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i39 = getelementptr i8, ptr %currentStackPointer.i37, i64 80
  %isInside.not.i40 = icmp ugt ptr %nextStackPointer.i39, %limit.i38
  br i1 %isInside.not.i40, label %realloc.i43, label %stackAllocate.exit57

realloc.i43:                                      ; preds = %sharePositive.exit
  %base.i45 = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i46 = ptrtoint ptr %currentStackPointer.i37 to i64
  %intBase.i47 = ptrtoint ptr %base.i45 to i64
  %size.i48 = sub i64 %intStackPointer.i46, %intBase.i47
  %nextSize.i49 = add i64 %size.i48, 80
  %leadingZeros.i.i50 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i49, i1 false)
  %numBits.i.i51 = sub nuw nsw i64 64, %leadingZeros.i.i50
  %result.i.i52 = shl nuw i64 1, %numBits.i.i51
  %newBase.i53 = tail call ptr @realloc(ptr %base.i45, i64 %result.i.i52)
  %newLimit.i54 = getelementptr i8, ptr %newBase.i53, i64 %result.i.i52
  %newStackPointer.i55 = getelementptr i8, ptr %newBase.i53, i64 %size.i48
  %newNextStackPointer.i56 = getelementptr i8, ptr %newStackPointer.i55, i64 80
  store ptr %newBase.i53, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i54, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit57

stackAllocate.exit57:                             ; preds = %sharePositive.exit, %realloc.i43
  %nextStackPointer.sink.i41 = phi ptr [ %newNextStackPointer.i56, %realloc.i43 ], [ %nextStackPointer.i39, %sharePositive.exit ]
  %common.ret.op.i42 = phi ptr [ %newStackPointer.i55, %realloc.i43 ], [ %currentStackPointer.i37, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i41, ptr %stackPointer_pointer.i20, align 8
  %pureApp_6024.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_6024.elt, ptr %common.ret.op.i42, align 8, !noalias !0
  %stackPointer_1794.repack9 = getelementptr inbounds i8, ptr %common.ret.op.i42, i64 8
  store ptr %object.i, ptr %stackPointer_1794.repack9, align 8, !noalias !0
  %freeRows_2861_pointer_1796 = getelementptr i8, ptr %common.ret.op.i42, i64 16
  store ptr %freeRows_2861.unpack, ptr %freeRows_2861_pointer_1796, align 8, !noalias !0
  %freeRows_2861_pointer_1796.repack11 = getelementptr i8, ptr %common.ret.op.i42, i64 24
  store i64 %freeRows_2861.unpack5, ptr %freeRows_2861_pointer_1796.repack11, align 8, !noalias !0
  %freeMaxs_2862_pointer_1797 = getelementptr i8, ptr %common.ret.op.i42, i64 32
  store ptr %prompt.i27, ptr %freeMaxs_2862_pointer_1797, align 8, !noalias !0
  %freeMaxs_2862_pointer_1797.repack13 = getelementptr i8, ptr %common.ret.op.i42, i64 40
  store i64 %offset.i, ptr %freeMaxs_2862_pointer_1797.repack13, align 8, !noalias !0
  %n_2854_pointer_1798 = getelementptr i8, ptr %common.ret.op.i42, i64 48
  store i64 %n_2854, ptr %n_2854_pointer_1798, align 4, !noalias !0
  %returnAddress_pointer_1799 = getelementptr i8, ptr %common.ret.op.i42, i64 56
  %sharer_pointer_1800 = getelementptr i8, ptr %common.ret.op.i42, i64 64
  %eraser_pointer_1801 = getelementptr i8, ptr %common.ret.op.i42, i64 72
  store ptr @returnAddress_429, ptr %returnAddress_pointer_1799, align 8, !noalias !0
  store ptr @sharer_1778, ptr %sharer_pointer_1800, align 8, !noalias !0
  store ptr @eraser_1788, ptr %eraser_pointer_1801, align 8, !noalias !0
  br i1 %isNull.i.i, label %erasePositive.exit17.i, label %next.i.i8.i

next.i.i8.i:                                      ; preds = %stackAllocate.exit57
  %referenceCount.i.i9.i = load i64, ptr %object.i, align 4
  %cond.i.i10.i = icmp eq i64 %referenceCount.i.i9.i, 0
  br i1 %cond.i.i10.i, label %free.i.i13.i, label %decr.i.i11.i

decr.i.i11.i:                                     ; preds = %next.i.i8.i
  %referenceCount.1.i.i12.i = add i64 %referenceCount.i.i9.i, -1
  store i64 %referenceCount.1.i.i12.i, ptr %object.i, align 4
  br label %erasePositive.exit17.i

free.i.i13.i:                                     ; preds = %next.i.i8.i
  %objectEraser.i.i14.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i15.i = load ptr, ptr %objectEraser.i.i14.i, align 8
  %environment.i.i.i16.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i15.i(ptr %environment.i.i.i16.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit17.i

erasePositive.exit17.i:                           ; preds = %free.i.i13.i, %decr.i.i11.i, %stackAllocate.exit57
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i20, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i.i, ptr %stackPointer_pointer.i20, align 8, !alias.scope !0
  %returnAddress_423.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_423.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1805(ptr %stackPointer) {
entry:
  %tmp_5891_1802.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_5891_1802.unpack2 = load ptr, ptr %tmp_5891_1802.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5891_1802.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5891_1802.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5891_1802.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1813(ptr %stackPointer) {
entry:
  %tmp_5891_1810.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %tmp_5891_1810.unpack2 = load ptr, ptr %tmp_5891_1810.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5891_1810.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5891_1810.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5891_1810.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5891_1810.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5891_1810.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5891_1810.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_366(%Pos %v_r_3054_15_4467, ptr %stack) {
entry:
  %stackPointer_pointer.i15 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i16 = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i16, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i21 = icmp ule ptr %stackPointer.i16, %limit.i
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i16, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %tmp_5988.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_5988.elt1 = getelementptr i8, ptr %stackPointer.i16, i64 -16
  %tmp_5988.unpack2 = load ptr, ptr %tmp_5988.elt1, align 8, !noalias !0
  %n_2854_pointer_369 = getelementptr i8, ptr %stackPointer.i16, i64 -8
  %n_2854 = load i64, ptr %n_2854_pointer_369, align 4, !noalias !0
  %object.i10 = extractvalue %Pos %v_r_3054_15_4467, 1
  %isNull.i.i11 = icmp eq ptr %object.i10, null
  br i1 %isNull.i.i11, label %erasePositive.exit, label %next.i.i12

next.i.i12:                                       ; preds = %entry
  %referenceCount.i.i13 = load i64, ptr %object.i10, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i13, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i12
  %referenceCount.1.i.i14 = add i64 %referenceCount.i.i13, -1
  store i64 %referenceCount.1.i.i14, ptr %object.i10, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i12
  %objectEraser.i.i = getelementptr i8, ptr %object.i10, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i10, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i10)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i15, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i22 = load ptr, ptr %prompt_pointer.i, align 8
  %limit.i25 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i25
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %erasePositive.exit
  %nextSize.i = add i64 %offset.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i29 = getelementptr i8, ptr %newBase.i, i64 %offset.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i29, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i29, %realloc.i ], [ %stackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i15, align 8
  store i64 %tmp_5988.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_385.repack4 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %tmp_5988.unpack2, ptr %stackPointer_385.repack4, align 8, !noalias !0
  %returnAddress_pointer_387 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_388 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_389 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_370, ptr %returnAddress_pointer_387, align 8, !noalias !0
  store ptr @sharer_378, ptr %sharer_pointer_388, align 8, !noalias !0
  store ptr @eraser_382, ptr %eraser_pointer_389, align 8, !noalias !0
  %z.i = tail call %Pos @c_array_new(i64 0)
  %object.i = extractvalue %Pos %z.i, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %stackAllocate.exit
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %stackAllocate.exit, %next.i.i
  %currentStackPointer.i32 = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %limit.i33 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i34 = getelementptr i8, ptr %currentStackPointer.i32, i64 64
  %isInside.not.i35 = icmp ugt ptr %nextStackPointer.i34, %limit.i33
  br i1 %isInside.not.i35, label %realloc.i38, label %stackAllocate.exit52

realloc.i38:                                      ; preds = %sharePositive.exit
  %base.i40 = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i41 = ptrtoint ptr %currentStackPointer.i32 to i64
  %intBase.i42 = ptrtoint ptr %base.i40 to i64
  %size.i43 = sub i64 %intStackPointer.i41, %intBase.i42
  %nextSize.i44 = add i64 %size.i43, 64
  %leadingZeros.i.i45 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i44, i1 false)
  %numBits.i.i46 = sub nuw nsw i64 64, %leadingZeros.i.i45
  %result.i.i47 = shl nuw i64 1, %numBits.i.i46
  %newBase.i48 = tail call ptr @realloc(ptr %base.i40, i64 %result.i.i47)
  %newLimit.i49 = getelementptr i8, ptr %newBase.i48, i64 %result.i.i47
  %newStackPointer.i50 = getelementptr i8, ptr %newBase.i48, i64 %size.i43
  %newNextStackPointer.i51 = getelementptr i8, ptr %newStackPointer.i50, i64 64
  store ptr %newBase.i48, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i49, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit52

stackAllocate.exit52:                             ; preds = %sharePositive.exit, %realloc.i38
  %nextStackPointer.sink.i36 = phi ptr [ %newNextStackPointer.i51, %realloc.i38 ], [ %nextStackPointer.i34, %sharePositive.exit ]
  %common.ret.op.i37 = phi ptr [ %newStackPointer.i50, %realloc.i38 ], [ %currentStackPointer.i32, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i36, ptr %stackPointer_pointer.i15, align 8
  %pureApp_6014.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_6014.elt, ptr %common.ret.op.i37, align 8, !noalias !0
  %stackPointer_1818.repack6 = getelementptr inbounds i8, ptr %common.ret.op.i37, i64 8
  store ptr %object.i, ptr %stackPointer_1818.repack6, align 8, !noalias !0
  %freeRows_2861_pointer_1820 = getelementptr i8, ptr %common.ret.op.i37, i64 16
  store ptr %prompt.i22, ptr %freeRows_2861_pointer_1820, align 8, !noalias !0
  %freeRows_2861_pointer_1820.repack8 = getelementptr i8, ptr %common.ret.op.i37, i64 24
  store i64 %offset.i, ptr %freeRows_2861_pointer_1820.repack8, align 8, !noalias !0
  %n_2854_pointer_1821 = getelementptr i8, ptr %common.ret.op.i37, i64 32
  store i64 %n_2854, ptr %n_2854_pointer_1821, align 4, !noalias !0
  %returnAddress_pointer_1822 = getelementptr i8, ptr %common.ret.op.i37, i64 40
  %sharer_pointer_1823 = getelementptr i8, ptr %common.ret.op.i37, i64 48
  %eraser_pointer_1824 = getelementptr i8, ptr %common.ret.op.i37, i64 56
  store ptr @returnAddress_400, ptr %returnAddress_pointer_1822, align 8, !noalias !0
  store ptr @sharer_1805, ptr %sharer_pointer_1823, align 8, !noalias !0
  store ptr @eraser_1813, ptr %eraser_pointer_1824, align 8, !noalias !0
  br i1 %isNull.i.i, label %erasePositive.exit17.i, label %next.i.i8.i

next.i.i8.i:                                      ; preds = %stackAllocate.exit52
  %referenceCount.i.i9.i = load i64, ptr %object.i, align 4
  %cond.i.i10.i = icmp eq i64 %referenceCount.i.i9.i, 0
  br i1 %cond.i.i10.i, label %free.i.i13.i, label %decr.i.i11.i

decr.i.i11.i:                                     ; preds = %next.i.i8.i
  %referenceCount.1.i.i12.i = add i64 %referenceCount.i.i9.i, -1
  store i64 %referenceCount.1.i.i12.i, ptr %object.i, align 4
  br label %erasePositive.exit17.i

free.i.i13.i:                                     ; preds = %next.i.i8.i
  %objectEraser.i.i14.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i15.i = load ptr, ptr %objectEraser.i.i14.i, align 8
  %environment.i.i.i16.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i15.i(ptr %environment.i.i.i16.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit17.i

erasePositive.exit17.i:                           ; preds = %free.i.i13.i, %decr.i.i11.i, %stackAllocate.exit52
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i.i, ptr %stackPointer_pointer.i15, align 8, !alias.scope !0
  %returnAddress_394.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_394.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_1827(ptr %stackPointer) {
entry:
  %tmp_5988_1825.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_5988_1825.unpack2 = load ptr, ptr %tmp_5988_1825.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5988_1825.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5988_1825.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %tmp_5988_1825.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1833(ptr %stackPointer) {
entry:
  %tmp_5988_1831.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %tmp_5988_1831.unpack2 = load ptr, ptr %tmp_5988_1831.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5988_1831.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5988_1831.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5988_1831.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5988_1831.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5988_1831.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5988_1831.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -32
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @run_2855(i64 %n_2854, ptr %stack) local_unnamed_addr {
entry:
  %z.i = tail call %Pos @c_array_new(i64 0)
  %object.i = extractvalue %Pos %z.i, 1
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
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 48
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 48
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 48
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %pureApp_6004.elt = extractvalue %Pos %z.i, 0
  store i64 %pureApp_6004.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_1837.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_1837.repack1, align 8, !noalias !0
  %n_2854_pointer_1839 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %n_2854, ptr %n_2854_pointer_1839, align 4, !noalias !0
  %returnAddress_pointer_1840 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %sharer_pointer_1841 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %eraser_pointer_1842 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr @returnAddress_366, ptr %returnAddress_pointer_1840, align 8, !noalias !0
  store ptr @sharer_1827, ptr %sharer_pointer_1841, align 8, !noalias !0
  store ptr @eraser_1833, ptr %eraser_pointer_1842, align 8, !noalias !0
  br i1 %isNull.i.i, label %erasePositive.exit17.i, label %next.i.i8.i

next.i.i8.i:                                      ; preds = %stackAllocate.exit
  %referenceCount.i.i9.i = load i64, ptr %object.i, align 4
  %cond.i.i10.i = icmp eq i64 %referenceCount.i.i9.i, 0
  br i1 %cond.i.i10.i, label %free.i.i13.i, label %decr.i.i11.i

decr.i.i11.i:                                     ; preds = %next.i.i8.i
  %referenceCount.1.i.i12.i = add i64 %referenceCount.i.i9.i, -1
  store i64 %referenceCount.1.i.i12.i, ptr %object.i, align 4
  br label %erasePositive.exit17.i

free.i.i13.i:                                     ; preds = %next.i.i8.i
  %objectEraser.i.i14.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i15.i = load ptr, ptr %objectEraser.i.i14.i, align 8
  %environment.i.i.i16.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i15.i(ptr %environment.i.i.i16.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit17.i

erasePositive.exit17.i:                           ; preds = %free.i.i13.i, %decr.i.i11.i, %stackAllocate.exit
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_360.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_360.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1843(%Pos %v_r_3316_4112, ptr %stack) {
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
  %index_2107_pointer_1846 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_1846, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_1848 = extractvalue %Pos %v_r_3316_4112, 0
  switch i64 %tag_1848, label %label_1850 [
    i64 0, label %label_1854
    i64 1, label %label_1860
  ]

label_1850:                                       ; preds = %entry
  ret void

label_1854:                                       ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_1854
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

eraseNegative.exit:                               ; preds = %label_1854, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1851 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1851(i64 %x.i, ptr nonnull %stack)
  ret void

label_1860:                                       ; preds = %entry
  %Exception_2362_pointer_1847 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_1847, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_5995 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5995.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5995, %Pos %z.i)
  %utf8StringLiteral_5997 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_5997.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5997)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_6000 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_6000.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_6000)
  %functionPointer_1859 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_1859(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_1864(ptr %stackPointer) {
entry:
  %str_2106_1861.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_1861.unpack2 = load ptr, ptr %str_2106_1861.elt1, align 8, !noalias !0
  %Exception_2362_1863.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_1863.unpack5 = load ptr, ptr %Exception_2362_1863.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_1861.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_1861.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_1861.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_1863.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_1863.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_1863.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_1872(ptr %stackPointer) {
entry:
  %str_2106_1869.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_1869.unpack2 = load ptr, ptr %str_2106_1869.elt1, align 8, !noalias !0
  %Exception_2362_1871.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_1871.unpack5 = load ptr, ptr %Exception_2362_1871.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_1869.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_1869.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_1869.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_1869.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_1869.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_1869.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_1871.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_1871.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_1871.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_1871.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_1871.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_1871.unpack5)
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
  %stackPointer_1877.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_1877.repack1, align 8, !noalias !0
  %index_2107_pointer_1879 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_1879, align 4, !noalias !0
  %Exception_2362_pointer_1880 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_1880, align 8, !noalias !0
  %Exception_2362_pointer_1880.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_1880.repack3, align 8, !noalias !0
  %returnAddress_pointer_1881 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_1882 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_1883 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_1843, ptr %returnAddress_pointer_1881, align 8, !noalias !0
  store ptr @sharer_1864, ptr %sharer_pointer_1882, align 8, !noalias !0
  store ptr @eraser_1872, ptr %eraser_pointer_1883, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_1890, label %label_1895

label_1890:                                       ; preds = %stackAllocate.exit
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
  %returnAddress_1887 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1887(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_1895:                                       ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_1895
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

erasePositive.exit:                               ; preds = %label_1895, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_1892 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_1892(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  tail call tailcc void @main_2856(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2856(ptr nonnull %stack.i2.i)
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
