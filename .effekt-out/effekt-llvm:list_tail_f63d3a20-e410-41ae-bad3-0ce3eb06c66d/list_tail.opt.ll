; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:list_tail_f63d3a20-e410-41ae-bad3-0ce3eb06c66d/list_tail.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:list_tail_f63d3a20-e410-41ae-bad3-0ce3eb06c66d/list_tail.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }

@vtable_332 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4451_clause_317]
@vtable_363 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4500_clause_355]
@utf8StringLiteral_4931.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_4862.lit = private constant [6 x i8] c"oh no!"
@utf8StringLiteral_4860.lit = private constant [6 x i8] c"oh no!"
@utf8StringLiteral_4858.lit = private constant [6 x i8] c"oh no!"
@utf8StringLiteral_4835.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_4837.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_4840.lit = private constant [1 x i8] c"'"

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

define tailcc void @returnAddress_29(i64 %v_r_2588_6_4703, ptr %stack) {
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
  %i_6_4695 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_4815_pointer_32 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4815 = load i64, ptr %tmp_4815_pointer_32, align 4, !noalias !0
  %z.i = add i64 %i_6_4695, 1
  musttail call tailcc void @loop_5_4698(i64 %z.i, i64 %tmp_4815, ptr %stack)
  ret void
}

define void @sharer_35(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_41(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_25(%Pos %v_r_2581_5_5_4705, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_4815_pointer_28 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4815 = load i64, ptr %tmp_4815_pointer_28, align 4, !noalias !0
  %i_6_4695 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_4695, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_4815_pointer_47 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %tmp_4815, ptr %tmp_4815_pointer_47, align 4, !noalias !0
  %sharer_pointer_49 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_50 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_29, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_35, ptr %sharer_pointer_49, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_50, align 8, !noalias !0
  musttail call tailcc void @length_2433(%Pos %v_r_2581_5_5_4705, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_19(%Pos %v_r_2580_4_4_4701, ptr %stack) {
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
  %v_r_2578_2_2_4700.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2578_2_2_4700.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_2578_2_2_4700.unpack2 = load ptr, ptr %v_r_2578_2_2_4700.elt1, align 8, !noalias !0
  %i_6_4695_pointer_22 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %i_6_4695 = load i64, ptr %i_6_4695_pointer_22, align 4, !noalias !0
  %tmp_4815_pointer_23 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_4815 = load i64, ptr %tmp_4815_pointer_23, align 4, !noalias !0
  %v_r_2579_3_3_4702_pointer_24 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2579_3_3_4702.unpack = load i64, ptr %v_r_2579_3_3_4702_pointer_24, align 8, !noalias !0
  %v_r_2579_3_3_4702.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2579_3_3_4702.unpack5 = load ptr, ptr %v_r_2579_3_3_4702.elt4, align 8, !noalias !0
  %isInside.not.i = icmp ugt ptr %v_r_2579_3_3_4702.elt4, %limit.i
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
  %newStackPointer.i15 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i15, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %v_r_2579_3_3_4702.elt4, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i15, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_6_4695, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_4815_pointer_57 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_4815, ptr %tmp_4815_pointer_57, align 4, !noalias !0
  %returnAddress_pointer_58 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_59 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_60 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_25, ptr %returnAddress_pointer_58, align 8, !noalias !0
  store ptr @sharer_35, ptr %sharer_pointer_59, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_60, align 8, !noalias !0
  %isNull.i.i8.i = icmp eq ptr %v_r_2578_2_2_4700.unpack2, null
  br i1 %isNull.i.i8.i, label %sharePositive.exit12.i, label %next.i.i9.i

next.i.i9.i:                                      ; preds = %stackAllocate.exit
  %referenceCount.i.i10.i = load i64, ptr %v_r_2578_2_2_4700.unpack2, align 4
  %referenceCount.1.i.i11.i = add i64 %referenceCount.i.i10.i, 1
  store i64 %referenceCount.1.i.i11.i, ptr %v_r_2578_2_2_4700.unpack2, align 4
  br label %sharePositive.exit12.i

sharePositive.exit12.i:                           ; preds = %next.i.i9.i, %stackAllocate.exit
  %isNull.i.i.i = icmp eq ptr %v_r_2579_3_3_4702.unpack5, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %sharePositive.exit12.i
  %referenceCount.i.i.i = load i64, ptr %v_r_2579_3_3_4702.unpack5, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %v_r_2579_3_3_4702.unpack5, align 4
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %sharePositive.exit12.i
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 72
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %sharePositive.exit.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 72
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 72
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %sharePositive.exit.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %sharePositive.exit.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %sharePositive.exit.i ]
  %0 = insertvalue %Pos poison, i64 %v_r_2579_3_3_4702.unpack, 0
  %v_r_2579_3_3_47026 = insertvalue %Pos %0, ptr %v_r_2579_3_3_4702.unpack5, 1
  %1 = insertvalue %Pos poison, i64 %v_r_2578_2_2_4700.unpack, 0
  %v_r_2578_2_2_47003 = insertvalue %Pos %1, ptr %v_r_2578_2_2_4700.unpack2, 1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  %zs_2441.elt.i = extractvalue %Pos %v_r_2580_4_4_4701, 0
  store i64 %zs_2441.elt.i, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_625.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  %zs_2441.elt2.i = extractvalue %Pos %v_r_2580_4_4_4701, 1
  store ptr %zs_2441.elt2.i, ptr %stackPointer_625.repack1.i, align 8, !noalias !0
  %xs_2439_pointer_627.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %v_r_2578_2_2_4700.unpack, ptr %xs_2439_pointer_627.i, align 8, !noalias !0
  %xs_2439_pointer_627.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %v_r_2578_2_2_4700.unpack2, ptr %xs_2439_pointer_627.repack3.i, align 8, !noalias !0
  %ys_2440_pointer_628.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %v_r_2579_3_3_4702.unpack, ptr %ys_2440_pointer_628.i, align 8, !noalias !0
  %ys_2440_pointer_628.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %v_r_2579_3_3_4702.unpack5, ptr %ys_2440_pointer_628.repack5.i, align 8, !noalias !0
  %returnAddress_pointer_629.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %sharer_pointer_630.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  %eraser_pointer_631.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr @returnAddress_478, ptr %returnAddress_pointer_629.i, align 8, !noalias !0
  store ptr @sharer_612, ptr %sharer_pointer_630.i, align 8, !noalias !0
  store ptr @eraser_620, ptr %eraser_pointer_631.i, align 8, !noalias !0
  musttail call tailcc void @isShorterThan_2436(%Pos %v_r_2579_3_3_47026, %Pos %v_r_2578_2_2_47003, ptr nonnull %stack)
  ret void
}

define void @sharer_65(ptr %stackPointer) {
entry:
  %v_r_2578_2_2_4700_61.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_r_2578_2_2_4700_61.unpack2 = load ptr, ptr %v_r_2578_2_2_4700_61.elt1, align 8, !noalias !0
  %v_r_2579_3_3_4702_64.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2579_3_3_4702_64.unpack5 = load ptr, ptr %v_r_2579_3_3_4702_64.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_r_2578_2_2_4700_61.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_r_2578_2_2_4700_61.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %v_r_2578_2_2_4700_61.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %v_r_2579_3_3_4702_64.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %v_r_2579_3_3_4702_64.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2579_3_3_4702_64.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_75(ptr %stackPointer) {
entry:
  %v_r_2578_2_2_4700_71.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_r_2578_2_2_4700_71.unpack2 = load ptr, ptr %v_r_2578_2_2_4700_71.elt1, align 8, !noalias !0
  %v_r_2579_3_3_4702_74.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2579_3_3_4702_74.unpack5 = load ptr, ptr %v_r_2579_3_3_4702_74.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_r_2578_2_2_4700_71.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_r_2578_2_2_4700_71.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %v_r_2578_2_2_4700_71.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %v_r_2578_2_2_4700_71.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %v_r_2578_2_2_4700_71.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %v_r_2578_2_2_4700_71.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %v_r_2579_3_3_4702_74.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_r_2579_3_3_4702_74.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2579_3_3_4702_74.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2579_3_3_4702_74.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2579_3_3_4702_74.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2579_3_3_4702_74.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_14(%Pos %v_r_2579_3_3_4702, ptr %stack) {
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
  %v_r_2578_2_2_4700.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2578_2_2_4700.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2578_2_2_4700.unpack2 = load ptr, ptr %v_r_2578_2_2_4700.elt1, align 8, !noalias !0
  %i_6_4695_pointer_17 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %i_6_4695 = load i64, ptr %i_6_4695_pointer_17, align 4, !noalias !0
  %tmp_4815_pointer_18 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4815 = load i64, ptr %tmp_4815_pointer_18, align 4, !noalias !0
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
  %limit.i.pre.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i16, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_r_2578_2_2_4700.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_81.repack4 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %v_r_2578_2_2_4700.unpack2, ptr %stackPointer_81.repack4, align 8, !noalias !0
  %i_6_4695_pointer_83 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_6_4695, ptr %i_6_4695_pointer_83, align 4, !noalias !0
  %tmp_4815_pointer_84 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_4815, ptr %tmp_4815_pointer_84, align 4, !noalias !0
  %v_r_2579_3_3_4702_pointer_85 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %v_r_2579_3_3_4702.elt = extractvalue %Pos %v_r_2579_3_3_4702, 0
  store i64 %v_r_2579_3_3_4702.elt, ptr %v_r_2579_3_3_4702_pointer_85, align 8, !noalias !0
  %v_r_2579_3_3_4702_pointer_85.repack6 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %v_r_2579_3_3_4702.elt7 = extractvalue %Pos %v_r_2579_3_3_4702, 1
  store ptr %v_r_2579_3_3_4702.elt7, ptr %v_r_2579_3_3_4702_pointer_85.repack6, align 8, !noalias !0
  %returnAddress_pointer_86 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_87 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_88 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_19, ptr %returnAddress_pointer_86, align 8, !noalias !0
  store ptr @sharer_65, ptr %sharer_pointer_87, align 8, !noalias !0
  store ptr @eraser_75, ptr %eraser_pointer_88, align 8, !noalias !0
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  br label %label_661.i

label_661.i:                                      ; preds = %stackAllocate.exit.i, %stackAllocate.exit
  %limit.i.i = phi ptr [ %limit.i.pre.i, %stackAllocate.exit ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %currentStackPointer.i.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %n_2437.tr7.i = phi i64 [ 6, %stackAllocate.exit ], [ %z.i1.i, %stackAllocate.exit.i ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 32
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_661.i
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_661.i
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %label_661.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_661.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_661.i ]
  %z.i1.i = add nsw i64 %n_2437.tr7.i, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %n_2437.tr7.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %returnAddress_pointer_658.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  %sharer_pointer_659.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %eraser_pointer_660.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @returnAddress_635, ptr %returnAddress_pointer_658.i, align 8, !noalias !0
  store ptr @sharer_649, ptr %sharer_pointer_659.i, align 8, !noalias !0
  store ptr @eraser_653, ptr %eraser_pointer_660.i, align 8, !noalias !0
  %z.i.i = icmp eq i64 %z.i1.i, 0
  br i1 %z.i.i, label %label_666.i, label %label_661.i

label_666.i:                                      ; preds = %stackAllocate.exit.i
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i5.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i5.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_663.i = load ptr, ptr %newStackPointer.i5.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_663.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_92(ptr %stackPointer) {
entry:
  %v_r_2578_2_2_4700_89.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2578_2_2_4700_89.unpack2 = load ptr, ptr %v_r_2578_2_2_4700_89.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2578_2_2_4700_89.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2578_2_2_4700_89.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2578_2_2_4700_89.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_100(ptr %stackPointer) {
entry:
  %v_r_2578_2_2_4700_97.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2578_2_2_4700_97.unpack2 = load ptr, ptr %v_r_2578_2_2_4700_97.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2578_2_2_4700_97.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2578_2_2_4700_97.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2578_2_2_4700_97.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2578_2_2_4700_97.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2578_2_2_4700_97.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2578_2_2_4700_97.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_10(%Pos %v_r_2578_2_2_4700, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %i_6_4695 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_4815_pointer_13 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4815 = load i64, ptr %tmp_4815_pointer_13, align 4, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
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
  %newStackPointer.i11 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i11, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i.pre.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i11, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %v_r_2578_2_2_4700.elt = extractvalue %Pos %v_r_2578_2_2_4700, 0
  store i64 %v_r_2578_2_2_4700.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_105.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %v_r_2578_2_2_4700.elt2 = extractvalue %Pos %v_r_2578_2_2_4700, 1
  store ptr %v_r_2578_2_2_4700.elt2, ptr %stackPointer_105.repack1, align 8, !noalias !0
  %i_6_4695_pointer_107 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_6_4695, ptr %i_6_4695_pointer_107, align 4, !noalias !0
  %tmp_4815_pointer_108 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_4815, ptr %tmp_4815_pointer_108, align 4, !noalias !0
  %returnAddress_pointer_109 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_110 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_111 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_14, ptr %returnAddress_pointer_109, align 8, !noalias !0
  store ptr @sharer_92, ptr %sharer_pointer_110, align 8, !noalias !0
  store ptr @eraser_100, ptr %eraser_pointer_111, align 8, !noalias !0
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  br label %label_661.i

label_661.i:                                      ; preds = %stackAllocate.exit.i, %stackAllocate.exit
  %limit.i.i = phi ptr [ %limit.i.pre.i, %stackAllocate.exit ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %currentStackPointer.i.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %n_2437.tr7.i = phi i64 [ 10, %stackAllocate.exit ], [ %z.i1.i, %stackAllocate.exit.i ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 32
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_661.i
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_661.i
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %label_661.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_661.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_661.i ]
  %z.i1.i = add nsw i64 %n_2437.tr7.i, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %n_2437.tr7.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %returnAddress_pointer_658.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  %sharer_pointer_659.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %eraser_pointer_660.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @returnAddress_635, ptr %returnAddress_pointer_658.i, align 8, !noalias !0
  store ptr @sharer_649, ptr %sharer_pointer_659.i, align 8, !noalias !0
  store ptr @eraser_653, ptr %eraser_pointer_660.i, align 8, !noalias !0
  %z.i.i = icmp eq i64 %z.i1.i, 0
  br i1 %z.i.i, label %label_666.i, label %label_661.i

label_666.i:                                      ; preds = %stackAllocate.exit.i
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i5.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i5.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_663.i = load ptr, ptr %newStackPointer.i5.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_663.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @loop_5_4698(i64 %i_6_4695, i64 %tmp_4815, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_4695, %tmp_4815
  %stackPointer_pointer.i1 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_122, label %label_9

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

label_122:                                        ; preds = %entry
  %limit_pointer.i2 = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %limit.i3 = load ptr, ptr %limit_pointer.i2, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i3
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_122
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

stackAllocate.exit:                               ; preds = %label_122, %realloc.i
  %limit.i.pre.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i3, %label_122 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_122 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i4, %realloc.i ], [ %currentStackPointer.i, %label_122 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i1, align 8
  store i64 %i_6_4695, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_4815_pointer_118 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_4815, ptr %tmp_4815_pointer_118, align 4, !noalias !0
  %returnAddress_pointer_119 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_120 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_121 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_119, align 8, !noalias !0
  store ptr @sharer_35, ptr %sharer_pointer_120, align 8, !noalias !0
  store ptr @eraser_41, ptr %eraser_pointer_121, align 8, !noalias !0
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  br label %label_661.i

label_661.i:                                      ; preds = %stackAllocate.exit.i, %stackAllocate.exit
  %limit.i.i = phi ptr [ %limit.i.pre.i, %stackAllocate.exit ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %currentStackPointer.i.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %n_2437.tr7.i = phi i64 [ 15, %stackAllocate.exit ], [ %z.i1.i, %stackAllocate.exit.i ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 32
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_661.i
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
  store ptr %newLimit.i.i, ptr %limit_pointer.i2, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_661.i
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %label_661.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_661.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_661.i ]
  %z.i1.i = add nsw i64 %n_2437.tr7.i, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i1, align 8
  store i64 %n_2437.tr7.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %returnAddress_pointer_658.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  %sharer_pointer_659.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %eraser_pointer_660.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @returnAddress_635, ptr %returnAddress_pointer_658.i, align 8, !noalias !0
  store ptr @sharer_649, ptr %sharer_pointer_659.i, align 8, !noalias !0
  store ptr @eraser_653, ptr %eraser_pointer_660.i, align 8, !noalias !0
  %z.i.i = icmp eq i64 %z.i1.i, 0
  br i1 %z.i.i, label %label_666.i, label %label_661.i

label_666.i:                                      ; preds = %stackAllocate.exit.i
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i5.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i5.i, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %returnAddress_663.i = load ptr, ptr %newStackPointer.i5.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_663.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_133(i64 %r_2457, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2457)
  tail call void @c_io_println_String(%Pos %z.i)
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_134 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_134(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_137(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_139(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_132(%Pos %v_r_2581_5_4709, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_143 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_144 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_133, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_143, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_144, align 8, !noalias !0
  musttail call tailcc void @length_2433(%Pos %v_r_2581_5_4709, ptr %stack)
  ret void
}

define tailcc void @returnAddress_128(%Pos %v_r_2580_4_4707, ptr %stack) {
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
  %v_r_2578_2_4708.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2578_2_4708.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2578_2_4708.unpack2 = load ptr, ptr %v_r_2578_2_4708.elt1, align 8, !noalias !0
  %v_r_2579_3_4711_pointer_131 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2579_3_4711.unpack = load i64, ptr %v_r_2579_3_4711_pointer_131, align 8, !noalias !0
  %v_r_2579_3_4711.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2579_3_4711.unpack5 = load ptr, ptr %v_r_2579_3_4711.elt4, align 8, !noalias !0
  %isInside.not.i = icmp ugt ptr %v_r_2579_3_4711.elt4, %limit.i
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
  %newStackPointer.i15 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i15, i64 24
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %v_r_2579_3_4711.elt4, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i15, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_147 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_148 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_132, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_147, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_148, align 8, !noalias !0
  %isNull.i.i8.i = icmp eq ptr %v_r_2578_2_4708.unpack2, null
  br i1 %isNull.i.i8.i, label %sharePositive.exit12.i, label %next.i.i9.i

next.i.i9.i:                                      ; preds = %stackAllocate.exit
  %referenceCount.i.i10.i = load i64, ptr %v_r_2578_2_4708.unpack2, align 4
  %referenceCount.1.i.i11.i = add i64 %referenceCount.i.i10.i, 1
  store i64 %referenceCount.1.i.i11.i, ptr %v_r_2578_2_4708.unpack2, align 4
  br label %sharePositive.exit12.i

sharePositive.exit12.i:                           ; preds = %next.i.i9.i, %stackAllocate.exit
  %isNull.i.i.i = icmp eq ptr %v_r_2579_3_4711.unpack5, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %sharePositive.exit12.i
  %referenceCount.i.i.i = load i64, ptr %v_r_2579_3_4711.unpack5, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %v_r_2579_3_4711.unpack5, align 4
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %sharePositive.exit12.i
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 72
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %sharePositive.exit.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 72
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 72
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %sharePositive.exit.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %sharePositive.exit.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %sharePositive.exit.i ]
  %0 = insertvalue %Pos poison, i64 %v_r_2579_3_4711.unpack, 0
  %v_r_2579_3_47116 = insertvalue %Pos %0, ptr %v_r_2579_3_4711.unpack5, 1
  %1 = insertvalue %Pos poison, i64 %v_r_2578_2_4708.unpack, 0
  %v_r_2578_2_47083 = insertvalue %Pos %1, ptr %v_r_2578_2_4708.unpack2, 1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  %zs_2441.elt.i = extractvalue %Pos %v_r_2580_4_4707, 0
  store i64 %zs_2441.elt.i, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_625.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  %zs_2441.elt2.i = extractvalue %Pos %v_r_2580_4_4707, 1
  store ptr %zs_2441.elt2.i, ptr %stackPointer_625.repack1.i, align 8, !noalias !0
  %xs_2439_pointer_627.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %v_r_2578_2_4708.unpack, ptr %xs_2439_pointer_627.i, align 8, !noalias !0
  %xs_2439_pointer_627.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %v_r_2578_2_4708.unpack2, ptr %xs_2439_pointer_627.repack3.i, align 8, !noalias !0
  %ys_2440_pointer_628.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %v_r_2579_3_4711.unpack, ptr %ys_2440_pointer_628.i, align 8, !noalias !0
  %ys_2440_pointer_628.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %v_r_2579_3_4711.unpack5, ptr %ys_2440_pointer_628.repack5.i, align 8, !noalias !0
  %returnAddress_pointer_629.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %sharer_pointer_630.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  %eraser_pointer_631.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr @returnAddress_478, ptr %returnAddress_pointer_629.i, align 8, !noalias !0
  store ptr @sharer_612, ptr %sharer_pointer_630.i, align 8, !noalias !0
  store ptr @eraser_620, ptr %eraser_pointer_631.i, align 8, !noalias !0
  musttail call tailcc void @isShorterThan_2436(%Pos %v_r_2579_3_47116, %Pos %v_r_2578_2_47083, ptr nonnull %stack)
  ret void
}

define void @sharer_151(ptr %stackPointer) {
entry:
  %v_r_2578_2_4708_149.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2578_2_4708_149.unpack2 = load ptr, ptr %v_r_2578_2_4708_149.elt1, align 8, !noalias !0
  %v_r_2579_3_4711_150.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2579_3_4711_150.unpack5 = load ptr, ptr %v_r_2579_3_4711_150.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_r_2578_2_4708_149.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_r_2578_2_4708_149.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %v_r_2578_2_4708_149.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %v_r_2579_3_4711_150.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %v_r_2579_3_4711_150.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2579_3_4711_150.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_157(ptr %stackPointer) {
entry:
  %v_r_2578_2_4708_155.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2578_2_4708_155.unpack2 = load ptr, ptr %v_r_2578_2_4708_155.elt1, align 8, !noalias !0
  %v_r_2579_3_4711_156.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2579_3_4711_156.unpack5 = load ptr, ptr %v_r_2579_3_4711_156.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_r_2578_2_4708_155.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_r_2578_2_4708_155.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %v_r_2578_2_4708_155.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %v_r_2578_2_4708_155.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %v_r_2578_2_4708_155.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %v_r_2578_2_4708_155.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %v_r_2579_3_4711_156.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_r_2579_3_4711_156.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2579_3_4711_156.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2579_3_4711_156.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2579_3_4711_156.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2579_3_4711_156.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_125(%Pos %v_r_2579_3_4711, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_r_2578_2_4708.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2578_2_4708.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2578_2_4708.unpack2 = load ptr, ptr %v_r_2578_2_4708.elt1, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
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
  %newStackPointer.i16 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i16, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i.pre.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i16, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_r_2578_2_4708.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_161.repack4 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %v_r_2578_2_4708.unpack2, ptr %stackPointer_161.repack4, align 8, !noalias !0
  %v_r_2579_3_4711_pointer_163 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2579_3_4711.elt = extractvalue %Pos %v_r_2579_3_4711, 0
  store i64 %v_r_2579_3_4711.elt, ptr %v_r_2579_3_4711_pointer_163, align 8, !noalias !0
  %v_r_2579_3_4711_pointer_163.repack6 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %v_r_2579_3_4711.elt7 = extractvalue %Pos %v_r_2579_3_4711, 1
  store ptr %v_r_2579_3_4711.elt7, ptr %v_r_2579_3_4711_pointer_163.repack6, align 8, !noalias !0
  %returnAddress_pointer_164 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_165 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_166 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_128, ptr %returnAddress_pointer_164, align 8, !noalias !0
  store ptr @sharer_151, ptr %sharer_pointer_165, align 8, !noalias !0
  store ptr @eraser_157, ptr %eraser_pointer_166, align 8, !noalias !0
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  br label %label_661.i

label_661.i:                                      ; preds = %stackAllocate.exit.i, %stackAllocate.exit
  %limit.i.i = phi ptr [ %limit.i.pre.i, %stackAllocate.exit ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %currentStackPointer.i.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %n_2437.tr7.i = phi i64 [ 6, %stackAllocate.exit ], [ %z.i1.i, %stackAllocate.exit.i ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 32
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_661.i
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_661.i
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %label_661.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_661.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_661.i ]
  %z.i1.i = add nsw i64 %n_2437.tr7.i, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %n_2437.tr7.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %returnAddress_pointer_658.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  %sharer_pointer_659.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %eraser_pointer_660.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @returnAddress_635, ptr %returnAddress_pointer_658.i, align 8, !noalias !0
  store ptr @sharer_649, ptr %sharer_pointer_659.i, align 8, !noalias !0
  store ptr @eraser_653, ptr %eraser_pointer_660.i, align 8, !noalias !0
  %z.i.i = icmp eq i64 %z.i1.i, 0
  br i1 %z.i.i, label %label_666.i, label %label_661.i

label_666.i:                                      ; preds = %stackAllocate.exit.i
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i5.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i5.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_663.i = load ptr, ptr %newStackPointer.i5.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_663.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_168(ptr %stackPointer) {
entry:
  %v_r_2578_2_4708_167.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2578_2_4708_167.unpack2 = load ptr, ptr %v_r_2578_2_4708_167.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2578_2_4708_167.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2578_2_4708_167.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2578_2_4708_167.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_172(ptr %stackPointer) {
entry:
  %v_r_2578_2_4708_171.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2578_2_4708_171.unpack2 = load ptr, ptr %v_r_2578_2_4708_171.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2578_2_4708_171.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2578_2_4708_171.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2578_2_4708_171.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2578_2_4708_171.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2578_2_4708_171.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2578_2_4708_171.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_124(%Pos %v_r_2578_2_4708, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %stackPointer.i to i64
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
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i.pre.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %stackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %v_r_2578_2_4708.elt = extractvalue %Pos %v_r_2578_2_4708, 0
  store i64 %v_r_2578_2_4708.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_175.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %v_r_2578_2_4708.elt2 = extractvalue %Pos %v_r_2578_2_4708, 1
  store ptr %v_r_2578_2_4708.elt2, ptr %stackPointer_175.repack1, align 8, !noalias !0
  %returnAddress_pointer_177 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_178 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_179 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_125, ptr %returnAddress_pointer_177, align 8, !noalias !0
  store ptr @sharer_168, ptr %sharer_pointer_178, align 8, !noalias !0
  store ptr @eraser_172, ptr %eraser_pointer_179, align 8, !noalias !0
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  br label %label_661.i

label_661.i:                                      ; preds = %stackAllocate.exit.i, %stackAllocate.exit
  %limit.i.i = phi ptr [ %limit.i.pre.i, %stackAllocate.exit ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %currentStackPointer.i.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %n_2437.tr7.i = phi i64 [ 10, %stackAllocate.exit ], [ %z.i1.i, %stackAllocate.exit.i ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 32
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_661.i
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_661.i
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %label_661.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_661.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_661.i ]
  %z.i1.i = add nsw i64 %n_2437.tr7.i, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %n_2437.tr7.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %returnAddress_pointer_658.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  %sharer_pointer_659.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %eraser_pointer_660.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @returnAddress_635, ptr %returnAddress_pointer_658.i, align 8, !noalias !0
  store ptr @sharer_649, ptr %sharer_pointer_659.i, align 8, !noalias !0
  store ptr @eraser_653, ptr %eraser_pointer_660.i, align 8, !noalias !0
  %z.i.i = icmp eq i64 %z.i1.i, 0
  br i1 %z.i.i, label %label_666.i, label %label_661.i

label_666.i:                                      ; preds = %stackAllocate.exit.i
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i5.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i5.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_663.i = load ptr, ptr %newStackPointer.i5.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_663.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_123(%Pos %v_r_2590_4873, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %v_r_2590_4873, 1
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
  %limit.i.pre.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i3, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_182 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_183 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_124, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_182, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_183, align 8, !noalias !0
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  br label %label_661.i

label_661.i:                                      ; preds = %stackAllocate.exit.i, %stackAllocate.exit
  %limit.i.i = phi ptr [ %limit.i.pre.i, %stackAllocate.exit ], [ %limit.i9.i, %stackAllocate.exit.i ]
  %currentStackPointer.i.i = phi ptr [ %nextStackPointer.sink.i, %stackAllocate.exit ], [ %nextStackPointer.sink.i.i, %stackAllocate.exit.i ]
  %n_2437.tr7.i = phi i64 [ 15, %stackAllocate.exit ], [ %z.i1.i, %stackAllocate.exit.i ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 32
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_661.i
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_661.i
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %label_661.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_661.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %label_661.i ]
  %z.i1.i = add nsw i64 %n_2437.tr7.i, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %n_2437.tr7.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %returnAddress_pointer_658.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  %sharer_pointer_659.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %eraser_pointer_660.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @returnAddress_635, ptr %returnAddress_pointer_658.i, align 8, !noalias !0
  store ptr @sharer_649, ptr %sharer_pointer_659.i, align 8, !noalias !0
  store ptr @eraser_653, ptr %eraser_pointer_660.i, align 8, !noalias !0
  %z.i.i = icmp eq i64 %z.i1.i, 0
  br i1 %z.i.i, label %label_666.i, label %label_661.i

label_666.i:                                      ; preds = %stackAllocate.exit.i
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i5.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i5.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_663.i = load ptr, ptr %newStackPointer.i5.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_663.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3532_3596, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3532_3596, 0
  %z.i = add i64 %unboxed.i, -1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_186 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_187 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_123, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_186, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_187, align 8, !noalias !0
  musttail call tailcc void @loop_5_4698(i64 0, i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_193(%Pos %returned_4880, ptr nocapture %stack) {
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
  %returnAddress_195 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_195(%Pos %returned_4880, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_198(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_200(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define void @eraser_213(ptr nocapture readonly %environment) {
entry:
  %tmp_4788_211.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_4788_211.unpack2 = load ptr, ptr %tmp_4788_211.elt1, align 8, !noalias !0
  %acc_3_3_5_169_4544_212.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_4544_212.unpack5 = load ptr, ptr %acc_3_3_5_169_4544_212.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_4788_211.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_4788_211.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_4788_211.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_4788_211.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_4788_211.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_4788_211.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_4544_212.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_4544_212.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_4544_212.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_4544_212.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_4544_212.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_4544_212.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4614(i64 %start_2_2_4_168_4539, %Pos %acc_3_3_5_169_4544, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4539, 1
  br i1 %z.i6, label %label_223, label %label_219

label_219:                                        ; preds = %entry, %label_219
  %acc_3_3_5_169_4544.tr8 = phi %Pos [ %make_4886, %label_219 ], [ %acc_3_3_5_169_4544, %entry ]
  %start_2_2_4_168_4539.tr7 = phi i64 [ %z.i5, %label_219 ], [ %start_2_2_4_168_4539, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4539.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4539.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_213, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_4883.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_4883.elt, ptr %environment.i, align 8, !noalias !0
  %environment_210.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_4883.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_4883.elt2, ptr %environment_210.repack1, align 8, !noalias !0
  %acc_3_3_5_169_4544_pointer_217 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_4544.elt = extractvalue %Pos %acc_3_3_5_169_4544.tr8, 0
  store i64 %acc_3_3_5_169_4544.elt, ptr %acc_3_3_5_169_4544_pointer_217, align 8, !noalias !0
  %acc_3_3_5_169_4544_pointer_217.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_4544.elt4 = extractvalue %Pos %acc_3_3_5_169_4544.tr8, 1
  store ptr %acc_3_3_5_169_4544.elt4, ptr %acc_3_3_5_169_4544_pointer_217.repack3, align 8, !noalias !0
  %make_4886 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4539.tr7, 2
  br i1 %z.i, label %label_223, label %label_219

label_223:                                        ; preds = %label_219, %entry
  %acc_3_3_5_169_4544.tr.lcssa = phi %Pos [ %acc_3_3_5_169_4544, %entry ], [ %make_4886, %label_219 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_220 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_220(%Pos %acc_3_3_5_169_4544.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_234(%Pos %v_r_2671_32_59_223_4627, ptr %stack) {
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
  %p_8_9_4318 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %acc_8_35_199_4478_pointer_237 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %acc_8_35_199_4478 = load i64, ptr %acc_8_35_199_4478_pointer_237, align 4, !noalias !0
  %v_r_2585_30_194_4624_pointer_238 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_r_2585_30_194_4624.unpack = load i64, ptr %v_r_2585_30_194_4624_pointer_238, align 8, !noalias !0
  %v_r_2585_30_194_4624.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2585_30_194_4624.unpack2 = load ptr, ptr %v_r_2585_30_194_4624.elt1, align 8, !noalias !0
  %index_7_34_198_4532_pointer_239 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %index_7_34_198_4532 = load i64, ptr %index_7_34_198_4532_pointer_239, align 4, !noalias !0
  %tmp_4795_pointer_240 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4795 = load i64, ptr %tmp_4795_pointer_240, align 4, !noalias !0
  %tag_241 = extractvalue %Pos %v_r_2671_32_59_223_4627, 0
  %fields_242 = extractvalue %Pos %v_r_2671_32_59_223_4627, 1
  switch i64 %tag_241, label %common.ret [
    i64 1, label %label_266
    i64 0, label %label_273
  ]

common.ret:                                       ; preds = %entry
  ret void

label_254:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2585_30_194_4624.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_254
  %referenceCount.i.i37 = load i64, ptr %v_r_2585_30_194_4624.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2585_30_194_4624.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2585_30_194_4624.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2585_30_194_4624.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4624.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_254, %decr.i.i39, %free.i.i41
  %pair_249 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4318)
  %k_13_14_4_4716 = extractvalue <{ ptr, ptr }> %pair_249, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_4716, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_4716, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_4716, i64 40
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
  %stack_250 = extractvalue <{ ptr, ptr }> %pair_249, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_250, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_250, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_251 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_251(%Pos { i64 10, ptr null }, ptr %stack_250)
  ret void

label_263:                                        ; preds = %label_265
  %isNull.i.i24 = icmp eq ptr %v_r_2585_30_194_4624.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_263
  %referenceCount.i.i26 = load i64, ptr %v_r_2585_30_194_4624.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2585_30_194_4624.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2585_30_194_4624.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2585_30_194_4624.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4624.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_263, %decr.i.i28, %free.i.i30
  %pair_258 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4318)
  %k_13_14_4_4715 = extractvalue <{ ptr, ptr }> %pair_258, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_4715, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_4715, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4715, i64 40
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
  %stack_259 = extractvalue <{ ptr, ptr }> %pair_258, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_259, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_259, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_260 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_260(%Pos { i64 10, ptr null }, ptr %stack_259)
  ret void

label_264:                                        ; preds = %label_265
  %0 = insertvalue %Pos poison, i64 %v_r_2585_30_194_4624.unpack, 0
  %v_r_2585_30_194_46243 = insertvalue %Pos %0, ptr %v_r_2585_30_194_4624.unpack2, 1
  %z.i = add i64 %index_7_34_198_4532, 1
  %z.i108 = mul i64 %acc_8_35_199_4478, 10
  %z.i109 = sub i64 %z.i108, %tmp_4795
  %z.i110 = add i64 %z.i109, %v_coe_3489_46_73_237_4512.unpack
  musttail call tailcc void @go_6_33_197_4620(i64 %z.i, i64 %z.i110, ptr %p_8_9_4318, %Pos %v_r_2585_30_194_46243, i64 %tmp_4795, ptr nonnull %stack)
  ret void

label_265:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3489_46_73_237_4512.unpack, 58
  br i1 %z.i111, label %label_264, label %label_263

label_266:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_242, i64 16
  %v_coe_3489_46_73_237_4512.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3489_46_73_237_4512.elt4 = getelementptr i8, ptr %fields_242, i64 24
  %v_coe_3489_46_73_237_4512.unpack5 = load ptr, ptr %v_coe_3489_46_73_237_4512.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3489_46_73_237_4512.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_266
  %referenceCount.i.i = load i64, ptr %v_coe_3489_46_73_237_4512.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3489_46_73_237_4512.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_266
  %referenceCount.i11 = load i64, ptr %fields_242, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_242, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_242, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_242)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_3489_46_73_237_4512.unpack, 47
  br i1 %z.i112, label %label_265, label %label_254

label_273:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_242, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_273
  %referenceCount.i = load i64, ptr %fields_242, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_242, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_242, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_242, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_242)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_273, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_2585_30_194_4624.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2585_30_194_4624.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2585_30_194_4624.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2585_30_194_4624.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2585_30_194_4624.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4624.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_270 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_270(i64 %acc_8_35_199_4478, ptr nonnull %stack)
  ret void
}

define void @sharer_279(ptr %stackPointer) {
entry:
  %v_r_2585_30_194_4624_276.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2585_30_194_4624_276.unpack2 = load ptr, ptr %v_r_2585_30_194_4624_276.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2585_30_194_4624_276.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2585_30_194_4624_276.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2585_30_194_4624_276.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_291(ptr %stackPointer) {
entry:
  %v_r_2585_30_194_4624_288.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2585_30_194_4624_288.unpack2 = load ptr, ptr %v_r_2585_30_194_4624_288.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2585_30_194_4624_288.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2585_30_194_4624_288.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2585_30_194_4624_288.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2585_30_194_4624_288.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2585_30_194_4624_288.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4624_288.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_308(%Pos %returned_4911, ptr nocapture %stack) {
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
  %returnAddress_310 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_310(%Pos %returned_4911, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_4451_clause_317(ptr %closure, %Pos %exc_8_20_47_211_4578, %Pos %msg_9_21_48_212_4635, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4568 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_320 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4568)
  %k_11_23_50_214_4643 = extractvalue <{ ptr, ptr }> %pair_320, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_4643, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_4643, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_4643, i64 40
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
  %stack_321 = extractvalue <{ ptr, ptr }> %pair_320, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_213, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_4578.elt = extractvalue %Pos %exc_8_20_47_211_4578, 0
  store i64 %exc_8_20_47_211_4578.elt, ptr %environment.i, align 8, !noalias !0
  %environment_323.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_4578.elt2 = extractvalue %Pos %exc_8_20_47_211_4578, 1
  store ptr %exc_8_20_47_211_4578.elt2, ptr %environment_323.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4635_pointer_327 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4635.elt = extractvalue %Pos %msg_9_21_48_212_4635, 0
  store i64 %msg_9_21_48_212_4635.elt, ptr %msg_9_21_48_212_4635_pointer_327, align 8, !noalias !0
  %msg_9_21_48_212_4635_pointer_327.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4635.elt4 = extractvalue %Pos %msg_9_21_48_212_4635, 1
  store ptr %msg_9_21_48_212_4635.elt4, ptr %msg_9_21_48_212_4635_pointer_327.repack3, align 8, !noalias !0
  %make_4912 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_321, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_321, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_329 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_329(%Pos %make_4912, ptr %stack_321)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_336(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_344(ptr nocapture readonly %environment) {
entry:
  %tmp_4797_343.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_4797_343.unpack2 = load ptr, ptr %tmp_4797_343.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_4797_343.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_4797_343.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_4797_343.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_4797_343.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_4797_343.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_4797_343.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_340(i64 %v_coe_3488_6_28_55_219_4466, ptr %stack) {
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
  store ptr @eraser_344, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3488_6_28_55_219_4466, ptr %environment.i, align 8, !noalias !0
  %environment_342.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_342.repack1, align 8, !noalias !0
  %make_4914 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_348 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_348(%Pos %make_4914, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_4620(i64 %index_7_34_198_4532, i64 %acc_8_35_199_4478, ptr %p_8_9_4318, %Pos %v_r_2585_30_194_4624, i64 %tmp_4795, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2585_30_194_4624, 1
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
  store ptr %p_8_9_4318, ptr %common.ret.op.i, align 8, !noalias !0
  %acc_8_35_199_4478_pointer_300 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %acc_8_35_199_4478, ptr %acc_8_35_199_4478_pointer_300, align 4, !noalias !0
  %v_r_2585_30_194_4624_pointer_301 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2585_30_194_4624.elt = extractvalue %Pos %v_r_2585_30_194_4624, 0
  store i64 %v_r_2585_30_194_4624.elt, ptr %v_r_2585_30_194_4624_pointer_301, align 8, !noalias !0
  %v_r_2585_30_194_4624_pointer_301.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i3, ptr %v_r_2585_30_194_4624_pointer_301.repack1, align 8, !noalias !0
  %index_7_34_198_4532_pointer_302 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %index_7_34_198_4532, ptr %index_7_34_198_4532_pointer_302, align 4, !noalias !0
  %tmp_4795_pointer_303 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %tmp_4795, ptr %tmp_4795_pointer_303, align 4, !noalias !0
  %returnAddress_pointer_304 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_305 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_306 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_234, ptr %returnAddress_pointer_304, align 8, !noalias !0
  store ptr @sharer_279, ptr %sharer_pointer_305, align 8, !noalias !0
  store ptr @eraser_291, ptr %eraser_pointer_306, align 8, !noalias !0
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
  %sharer_pointer_315 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_316 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_308, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_198, ptr %sharer_pointer_315, align 8, !noalias !0
  store ptr @eraser_200, ptr %eraser_pointer_316, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_336, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_4451 = insertvalue %Neg { ptr @vtable_332, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_353 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_354 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_340, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_353, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_354, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2585_30_194_4624, i64 %index_7_34_198_4532, %Neg %Exception_7_19_46_210_4451, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_4500_clause_355(ptr %closure, %Pos %exception_10_107_134_298_4915, %Pos %msg_11_108_135_299_4916, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4318 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_4915, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_4916, 1
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
  %pair_358 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4318)
  %k_13_14_4_4774 = extractvalue <{ ptr, ptr }> %pair_358, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_4774, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_4774, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4774, i64 40
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
  %stack_359 = extractvalue <{ ptr, ptr }> %pair_358, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_359, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_359, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_360 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_360(%Pos { i64 10, ptr null }, ptr %stack_359)
  ret void
}

define tailcc void @returnAddress_374(i64 %v_coe_3493_22_131_158_322_4517, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3493_22_131_158_322_4517, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_375 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_375(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_386(i64 %v_r_2685_1_9_20_129_156_320_4630, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2685_1_9_20_129_156_320_4630
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_387 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_387(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_369(i64 %v_r_2684_3_14_123_150_314_4395, ptr %stack) {
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
  %p_8_9_4318 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2585_30_194_4624_pointer_372 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2585_30_194_4624.unpack = load i64, ptr %v_r_2585_30_194_4624_pointer_372, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2585_30_194_4624.unpack, 0
  %v_r_2585_30_194_4624.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2585_30_194_4624.unpack2 = load ptr, ptr %v_r_2585_30_194_4624.elt1, align 8, !noalias !0
  %v_r_2585_30_194_46243 = insertvalue %Pos %0, ptr %v_r_2585_30_194_4624.unpack2, 1
  %tmp_4795_pointer_373 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4795 = load i64, ptr %tmp_4795_pointer_373, align 4, !noalias !0
  %z.i = icmp eq i64 %v_r_2684_3_14_123_150_314_4395, 45
  %isInside.not.i = icmp ugt ptr %tmp_4795_pointer_373, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %tmp_4795_pointer_373, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_380 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_381 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_374, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_380, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_381, align 8, !noalias !0
  br i1 %z.i, label %label_394, label %label_385

label_385:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_4620(i64 0, i64 0, ptr %p_8_9_4318, %Pos %v_r_2585_30_194_46243, i64 %tmp_4795, ptr nonnull %stack)
  ret void

label_394:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_394
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

stackAllocate.exit35:                             ; preds = %label_394, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_394 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_394 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_392 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_393 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_386, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_392, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_393, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_4620(i64 1, i64 0, ptr %p_8_9_4318, %Pos %v_r_2585_30_194_46243, i64 %tmp_4795, ptr nonnull %stack)
  ret void
}

define void @sharer_398(ptr %stackPointer) {
entry:
  %v_r_2585_30_194_4624_396.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2585_30_194_4624_396.unpack2 = load ptr, ptr %v_r_2585_30_194_4624_396.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2585_30_194_4624_396.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2585_30_194_4624_396.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2585_30_194_4624_396.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_406(ptr %stackPointer) {
entry:
  %v_r_2585_30_194_4624_404.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2585_30_194_4624_404.unpack2 = load ptr, ptr %v_r_2585_30_194_4624_404.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2585_30_194_4624_404.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2585_30_194_4624_404.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2585_30_194_4624_404.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2585_30_194_4624_404.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2585_30_194_4624_404.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4624_404.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_231(%Pos %v_r_2585_30_194_4624, ptr %stack) {
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
  %p_8_9_4318 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_336, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4318, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2585_30_194_4624, 1
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
  store ptr %p_8_9_4318, ptr %common.ret.op.i, align 8, !noalias !0
  %v_r_2585_30_194_4624_pointer_413 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_r_2585_30_194_4624.elt = extractvalue %Pos %v_r_2585_30_194_4624, 0
  store i64 %v_r_2585_30_194_4624.elt, ptr %v_r_2585_30_194_4624_pointer_413, align 8, !noalias !0
  %v_r_2585_30_194_4624_pointer_413.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i3, ptr %v_r_2585_30_194_4624_pointer_413.repack1, align 8, !noalias !0
  %tmp_4795_pointer_414 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 48, ptr %tmp_4795_pointer_414, align 4, !noalias !0
  %returnAddress_pointer_415 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_416 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_417 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_369, ptr %returnAddress_pointer_415, align 8, !noalias !0
  store ptr @sharer_398, ptr %sharer_pointer_416, align 8, !noalias !0
  store ptr @eraser_406, ptr %eraser_pointer_417, align 8, !noalias !0
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
  store i64 %v_r_2585_30_194_4624.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_752.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_752.repack1.i, align 8, !noalias !0
  %index_2107_pointer_754.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_754.i, align 4, !noalias !0
  %Exception_2362_pointer_755.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_363, ptr %Exception_2362_pointer_755.i, align 8, !noalias !0
  %Exception_2362_pointer_755.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_755.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_756.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_757.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_758.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_718, ptr %returnAddress_pointer_756.i, align 8, !noalias !0
  store ptr @sharer_739, ptr %sharer_pointer_757.i, align 8, !noalias !0
  store ptr @eraser_747, ptr %eraser_pointer_758.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2585_30_194_4624)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_762.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_762.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_419(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_423(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_228(%Pos %v_r_2584_24_188_4519, ptr %stack) {
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
  %p_8_9_4318 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4318, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_429 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_430 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_231, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_419, ptr %sharer_pointer_429, align 8, !noalias !0
  store ptr @eraser_423, ptr %eraser_pointer_430, align 8, !noalias !0
  %tag_431 = extractvalue %Pos %v_r_2584_24_188_4519, 0
  switch i64 %tag_431, label %label_433 [
    i64 0, label %label_437
    i64 1, label %label_443
  ]

label_433:                                        ; preds = %stackAllocate.exit
  ret void

label_437:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_4931 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_4931.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_434 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_434(%Pos %utf8StringLiteral_4931, ptr nonnull %stack)
  ret void

label_443:                                        ; preds = %stackAllocate.exit
  %fields_432 = extractvalue %Pos %v_r_2584_24_188_4519, 1
  %environment.i = getelementptr i8, ptr %fields_432, i64 16
  %v_y_3315_8_29_193_4558.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3315_8_29_193_4558.elt1 = getelementptr i8, ptr %fields_432, i64 24
  %v_y_3315_8_29_193_4558.unpack2 = load ptr, ptr %v_y_3315_8_29_193_4558.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3315_8_29_193_4558.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_443
  %referenceCount.i.i = load i64, ptr %v_y_3315_8_29_193_4558.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3315_8_29_193_4558.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_443
  %referenceCount.i = load i64, ptr %fields_432, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_432, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_432, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_432)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3315_8_29_193_4558.unpack, 0
  %v_y_3315_8_29_193_45583 = insertvalue %Pos %0, ptr %v_y_3315_8_29_193_4558.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_440 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_440(%Pos %v_y_3315_8_29_193_45583, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_225(%Pos %v_r_2583_13_177_4521, ptr %stack) {
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
  %p_8_9_4318 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4318, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_449 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_450 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_228, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_419, ptr %sharer_pointer_449, align 8, !noalias !0
  store ptr @eraser_423, ptr %eraser_pointer_450, align 8, !noalias !0
  %tag_451 = extractvalue %Pos %v_r_2583_13_177_4521, 0
  switch i64 %tag_451, label %label_453 [
    i64 0, label %label_458
    i64 1, label %label_470
  ]

label_453:                                        ; preds = %stackAllocate.exit
  ret void

label_458:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4318, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_231, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_419, ptr %sharer_pointer_449, align 8, !noalias !0
  store ptr @eraser_423, ptr %eraser_pointer_450, align 8, !noalias !0
  %utf8StringLiteral_4931.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_4931.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_434.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_434.i(%Pos %utf8StringLiteral_4931.i, ptr nonnull %stack)
  ret void

label_470:                                        ; preds = %stackAllocate.exit
  %fields_452 = extractvalue %Pos %v_r_2583_13_177_4521, 1
  %environment.i6 = getelementptr i8, ptr %fields_452, i64 16
  %v_y_2824_10_21_185_4352.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_2824_10_21_185_4352.elt1 = getelementptr i8, ptr %fields_452, i64 24
  %v_y_2824_10_21_185_4352.unpack2 = load ptr, ptr %v_y_2824_10_21_185_4352.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2824_10_21_185_4352.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_470
  %referenceCount.i.i = load i64, ptr %v_y_2824_10_21_185_4352.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2824_10_21_185_4352.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_470
  %referenceCount.i = load i64, ptr %fields_452, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_452, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_452, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_452)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_344, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2824_10_21_185_4352.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_463.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2824_10_21_185_4352.unpack2, ptr %environment_463.repack4, align 8, !noalias !0
  %make_4933 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_467 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_467(%Pos %make_4933, ptr nonnull %stack)
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
  %sharer_pointer_190 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_191 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_190, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_191, align 8, !noalias !0
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
  %sharer_pointer_204 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_205 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_193, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_198, ptr %sharer_pointer_204, align 8, !noalias !0
  store ptr @eraser_200, ptr %eraser_pointer_205, align 8, !noalias !0
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
  %returnAddress_pointer_475 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_476 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_477 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_225, ptr %returnAddress_pointer_475, align 8, !noalias !0
  store ptr @sharer_419, ptr %sharer_pointer_476, align 8, !noalias !0
  store ptr @eraser_423, ptr %eraser_pointer_477, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_223.i, label %label_219.i

label_219.i:                                      ; preds = %stackAllocate.exit46, %label_219.i
  %acc_3_3_5_169_4544.tr8.i = phi %Pos [ %make_4886.i, %label_219.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4539.tr7.i = phi i64 [ %z.i5.i, %label_219.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4539.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4539.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_213, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_4883.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_4883.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_210.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_4883.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_4883.elt2.i, ptr %environment_210.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_4544_pointer_217.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_4544.elt.i = extractvalue %Pos %acc_3_3_5_169_4544.tr8.i, 0
  store i64 %acc_3_3_5_169_4544.elt.i, ptr %acc_3_3_5_169_4544_pointer_217.i, align 8, !noalias !0
  %acc_3_3_5_169_4544_pointer_217.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_4544.elt4.i = extractvalue %Pos %acc_3_3_5_169_4544.tr8.i, 1
  store ptr %acc_3_3_5_169_4544.elt4.i, ptr %acc_3_3_5_169_4544_pointer_217.repack3.i, align 8, !noalias !0
  %make_4886.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4539.tr7.i, 2
  br i1 %z.i.i, label %label_223.i.loopexit, label %label_219.i

label_223.i.loopexit:                             ; preds = %label_219.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_223.i

label_223.i:                                      ; preds = %label_223.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_223.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_223.i.loopexit ]
  %acc_3_3_5_169_4544.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_4886.i, %label_223.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_220.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_220.i(%Pos %acc_3_3_5_169_4544.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_530(%Pos %v_r_2552_6_5_14_33_3970, ptr %stack) {
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
  %v_r_2550_4_3_12_31_3960.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2550_4_3_12_31_3960.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2550_4_3_12_31_3960.unpack2 = load ptr, ptr %v_r_2550_4_3_12_31_3960.elt1, align 8, !noalias !0
  %v_r_2551_5_4_13_32_3976_pointer_533 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2551_5_4_13_32_3976.unpack = load i64, ptr %v_r_2551_5_4_13_32_3976_pointer_533, align 8, !noalias !0
  %v_r_2551_5_4_13_32_3976.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2551_5_4_13_32_3976.unpack5 = load ptr, ptr %v_r_2551_5_4_13_32_3976.elt4, align 8, !noalias !0
  %isNull.i.i8.i = icmp eq ptr %v_r_2550_4_3_12_31_3960.unpack2, null
  br i1 %isNull.i.i8.i, label %sharePositive.exit12.i, label %next.i.i9.i

next.i.i9.i:                                      ; preds = %entry
  %referenceCount.i.i10.i = load i64, ptr %v_r_2550_4_3_12_31_3960.unpack2, align 4
  %referenceCount.1.i.i11.i = add i64 %referenceCount.i.i10.i, 1
  store i64 %referenceCount.1.i.i11.i, ptr %v_r_2550_4_3_12_31_3960.unpack2, align 4
  br label %sharePositive.exit12.i

sharePositive.exit12.i:                           ; preds = %next.i.i9.i, %entry
  %isNull.i.i.i = icmp eq ptr %v_r_2551_5_4_13_32_3976.unpack5, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %sharePositive.exit12.i
  %referenceCount.i.i.i = load i64, ptr %v_r_2551_5_4_13_32_3976.unpack5, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %v_r_2551_5_4_13_32_3976.unpack5, align 4
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %sharePositive.exit12.i
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 72
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %sharePositive.exit.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 72
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 72
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %sharePositive.exit.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %sharePositive.exit.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %sharePositive.exit.i ]
  %0 = insertvalue %Pos poison, i64 %v_r_2551_5_4_13_32_3976.unpack, 0
  %v_r_2551_5_4_13_32_39766 = insertvalue %Pos %0, ptr %v_r_2551_5_4_13_32_3976.unpack5, 1
  %1 = insertvalue %Pos poison, i64 %v_r_2550_4_3_12_31_3960.unpack, 0
  %v_r_2550_4_3_12_31_39603 = insertvalue %Pos %1, ptr %v_r_2550_4_3_12_31_3960.unpack2, 1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  %zs_2441.elt.i = extractvalue %Pos %v_r_2552_6_5_14_33_3970, 0
  store i64 %zs_2441.elt.i, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_625.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  %zs_2441.elt2.i = extractvalue %Pos %v_r_2552_6_5_14_33_3970, 1
  store ptr %zs_2441.elt2.i, ptr %stackPointer_625.repack1.i, align 8, !noalias !0
  %xs_2439_pointer_627.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %v_r_2550_4_3_12_31_3960.unpack, ptr %xs_2439_pointer_627.i, align 8, !noalias !0
  %xs_2439_pointer_627.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %v_r_2550_4_3_12_31_3960.unpack2, ptr %xs_2439_pointer_627.repack3.i, align 8, !noalias !0
  %ys_2440_pointer_628.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %v_r_2551_5_4_13_32_3976.unpack, ptr %ys_2440_pointer_628.i, align 8, !noalias !0
  %ys_2440_pointer_628.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %v_r_2551_5_4_13_32_3976.unpack5, ptr %ys_2440_pointer_628.repack5.i, align 8, !noalias !0
  %returnAddress_pointer_629.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %sharer_pointer_630.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  %eraser_pointer_631.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr @returnAddress_478, ptr %returnAddress_pointer_629.i, align 8, !noalias !0
  store ptr @sharer_612, ptr %sharer_pointer_630.i, align 8, !noalias !0
  store ptr @eraser_620, ptr %eraser_pointer_631.i, align 8, !noalias !0
  musttail call tailcc void @isShorterThan_2436(%Pos %v_r_2551_5_4_13_32_39766, %Pos %v_r_2550_4_3_12_31_39603, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_524(%Pos %v_r_2551_5_4_13_32_3976, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -64
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %ys_2440.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %ys_2440.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %ys_2440.unpack2 = load ptr, ptr %ys_2440.elt1, align 8, !noalias !0
  %v_r_2550_4_3_12_31_3960_pointer_527 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %v_r_2550_4_3_12_31_3960.unpack = load i64, ptr %v_r_2550_4_3_12_31_3960_pointer_527, align 8, !noalias !0
  %v_r_2550_4_3_12_31_3960.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_2550_4_3_12_31_3960.unpack5 = load ptr, ptr %v_r_2550_4_3_12_31_3960.elt4, align 8, !noalias !0
  %xs_2439_pointer_528 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %xs_2439.unpack = load i64, ptr %xs_2439_pointer_528, align 8, !noalias !0
  %xs_2439.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %xs_2439.unpack8 = load ptr, ptr %xs_2439.elt7, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_pointer_529 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_coe_3518_15_4_23_3971.unpack = load i64, ptr %v_coe_3518_15_4_23_3971_pointer_529, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_coe_3518_15_4_23_3971.unpack11 = load ptr, ptr %v_coe_3518_15_4_23_3971.elt10, align 8, !noalias !0
  %isInside.not.i = icmp ugt ptr %v_coe_3518_15_4_23_3971.elt10, %limit.i
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
  %newStackPointer.i25 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i25, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %v_coe_3518_15_4_23_3971.elt10, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i25, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_r_2550_4_3_12_31_3960.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_538.repack13 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %v_r_2550_4_3_12_31_3960.unpack5, ptr %stackPointer_538.repack13, align 8, !noalias !0
  %v_r_2551_5_4_13_32_3976_pointer_540 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2551_5_4_13_32_3976.elt = extractvalue %Pos %v_r_2551_5_4_13_32_3976, 0
  store i64 %v_r_2551_5_4_13_32_3976.elt, ptr %v_r_2551_5_4_13_32_3976_pointer_540, align 8, !noalias !0
  %v_r_2551_5_4_13_32_3976_pointer_540.repack15 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %v_r_2551_5_4_13_32_3976.elt16 = extractvalue %Pos %v_r_2551_5_4_13_32_3976, 1
  store ptr %v_r_2551_5_4_13_32_3976.elt16, ptr %v_r_2551_5_4_13_32_3976_pointer_540.repack15, align 8, !noalias !0
  %returnAddress_pointer_541 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_542 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_543 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_530, ptr %returnAddress_pointer_541, align 8, !noalias !0
  store ptr @sharer_151, ptr %sharer_pointer_542, align 8, !noalias !0
  store ptr @eraser_157, ptr %eraser_pointer_543, align 8, !noalias !0
  %isNull.i.i8.i = icmp eq ptr %v_coe_3518_15_4_23_3971.unpack11, null
  br i1 %isNull.i.i8.i, label %sharePositive.exit12.i, label %next.i.i9.i

next.i.i9.i:                                      ; preds = %stackAllocate.exit
  %referenceCount.i.i10.i = load i64, ptr %v_coe_3518_15_4_23_3971.unpack11, align 4
  %referenceCount.1.i.i11.i = add i64 %referenceCount.i.i10.i, 1
  store i64 %referenceCount.1.i.i11.i, ptr %v_coe_3518_15_4_23_3971.unpack11, align 4
  br label %sharePositive.exit12.i

sharePositive.exit12.i:                           ; preds = %next.i.i9.i, %stackAllocate.exit
  %isNull.i.i.i = icmp eq ptr %xs_2439.unpack8, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %sharePositive.exit12.i
  %referenceCount.i.i.i = load i64, ptr %xs_2439.unpack8, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %xs_2439.unpack8, align 4
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %sharePositive.exit12.i
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 72
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %sharePositive.exit.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 72
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 72
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %sharePositive.exit.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %sharePositive.exit.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %sharePositive.exit.i ]
  %0 = insertvalue %Pos poison, i64 %v_coe_3518_15_4_23_3971.unpack, 0
  %v_coe_3518_15_4_23_397112 = insertvalue %Pos %0, ptr %v_coe_3518_15_4_23_3971.unpack11, 1
  %1 = insertvalue %Pos poison, i64 %xs_2439.unpack, 0
  %xs_24399 = insertvalue %Pos %1, ptr %xs_2439.unpack8, 1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %ys_2440.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_625.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %ys_2440.unpack2, ptr %stackPointer_625.repack1.i, align 8, !noalias !0
  %xs_2439_pointer_627.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %v_coe_3518_15_4_23_3971.unpack, ptr %xs_2439_pointer_627.i, align 8, !noalias !0
  %xs_2439_pointer_627.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %v_coe_3518_15_4_23_3971.unpack11, ptr %xs_2439_pointer_627.repack3.i, align 8, !noalias !0
  %ys_2440_pointer_628.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %xs_2439.unpack, ptr %ys_2440_pointer_628.i, align 8, !noalias !0
  %ys_2440_pointer_628.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %xs_2439.unpack8, ptr %ys_2440_pointer_628.repack5.i, align 8, !noalias !0
  %returnAddress_pointer_629.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %sharer_pointer_630.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  %eraser_pointer_631.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr @returnAddress_478, ptr %returnAddress_pointer_629.i, align 8, !noalias !0
  store ptr @sharer_612, ptr %sharer_pointer_630.i, align 8, !noalias !0
  store ptr @eraser_620, ptr %eraser_pointer_631.i, align 8, !noalias !0
  musttail call tailcc void @isShorterThan_2436(%Pos %xs_24399, %Pos %v_coe_3518_15_4_23_397112, ptr nonnull %stack)
  ret void
}

define void @sharer_548(ptr %stackPointer) {
entry:
  %ys_2440_544.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %ys_2440_544.unpack2 = load ptr, ptr %ys_2440_544.elt1, align 8, !noalias !0
  %v_r_2550_4_3_12_31_3960_545.elt4 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_r_2550_4_3_12_31_3960_545.unpack5 = load ptr, ptr %v_r_2550_4_3_12_31_3960_545.elt4, align 8, !noalias !0
  %xs_2439_546.elt7 = getelementptr i8, ptr %stackPointer, i64 -24
  %xs_2439_546.unpack8 = load ptr, ptr %xs_2439_546.elt7, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_547.elt10 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_coe_3518_15_4_23_3971_547.unpack11 = load ptr, ptr %v_coe_3518_15_4_23_3971_547.elt10, align 8, !noalias !0
  %isNull.i.i23 = icmp eq ptr %ys_2440_544.unpack2, null
  br i1 %isNull.i.i23, label %sharePositive.exit27, label %next.i.i24

next.i.i24:                                       ; preds = %entry
  %referenceCount.i.i25 = load i64, ptr %ys_2440_544.unpack2, align 4
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i25, 1
  store i64 %referenceCount.1.i.i26, ptr %ys_2440_544.unpack2, align 4
  br label %sharePositive.exit27

sharePositive.exit27:                             ; preds = %entry, %next.i.i24
  %isNull.i.i18 = icmp eq ptr %v_r_2550_4_3_12_31_3960_545.unpack5, null
  br i1 %isNull.i.i18, label %sharePositive.exit22, label %next.i.i19

next.i.i19:                                       ; preds = %sharePositive.exit27
  %referenceCount.i.i20 = load i64, ptr %v_r_2550_4_3_12_31_3960_545.unpack5, align 4
  %referenceCount.1.i.i21 = add i64 %referenceCount.i.i20, 1
  store i64 %referenceCount.1.i.i21, ptr %v_r_2550_4_3_12_31_3960_545.unpack5, align 4
  br label %sharePositive.exit22

sharePositive.exit22:                             ; preds = %sharePositive.exit27, %next.i.i19
  %isNull.i.i13 = icmp eq ptr %xs_2439_546.unpack8, null
  br i1 %isNull.i.i13, label %sharePositive.exit17, label %next.i.i14

next.i.i14:                                       ; preds = %sharePositive.exit22
  %referenceCount.i.i15 = load i64, ptr %xs_2439_546.unpack8, align 4
  %referenceCount.1.i.i16 = add i64 %referenceCount.i.i15, 1
  store i64 %referenceCount.1.i.i16, ptr %xs_2439_546.unpack8, align 4
  br label %sharePositive.exit17

sharePositive.exit17:                             ; preds = %sharePositive.exit22, %next.i.i14
  %isNull.i.i = icmp eq ptr %v_coe_3518_15_4_23_3971_547.unpack11, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_coe_3518_15_4_23_3971_547.unpack11, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3518_15_4_23_3971_547.unpack11, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit17, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_558(ptr %stackPointer) {
entry:
  %ys_2440_554.elt1 = getelementptr i8, ptr %stackPointer, i64 -56
  %ys_2440_554.unpack2 = load ptr, ptr %ys_2440_554.elt1, align 8, !noalias !0
  %v_r_2550_4_3_12_31_3960_555.elt4 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_r_2550_4_3_12_31_3960_555.unpack5 = load ptr, ptr %v_r_2550_4_3_12_31_3960_555.elt4, align 8, !noalias !0
  %xs_2439_556.elt7 = getelementptr i8, ptr %stackPointer, i64 -24
  %xs_2439_556.unpack8 = load ptr, ptr %xs_2439_556.elt7, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_557.elt10 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_coe_3518_15_4_23_3971_557.unpack11 = load ptr, ptr %v_coe_3518_15_4_23_3971_557.elt10, align 8, !noalias !0
  %isNull.i.i35 = icmp eq ptr %ys_2440_554.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %entry
  %referenceCount.i.i37 = load i64, ptr %ys_2440_554.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %ys_2440_554.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %ys_2440_554.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %ys_2440_554.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %ys_2440_554.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %entry, %decr.i.i39, %free.i.i41
  %isNull.i.i24 = icmp eq ptr %v_r_2550_4_3_12_31_3960_555.unpack5, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %erasePositive.exit45
  %referenceCount.i.i26 = load i64, ptr %v_r_2550_4_3_12_31_3960_555.unpack5, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2550_4_3_12_31_3960_555.unpack5, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2550_4_3_12_31_3960_555.unpack5, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2550_4_3_12_31_3960_555.unpack5, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2550_4_3_12_31_3960_555.unpack5)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %erasePositive.exit45, %decr.i.i28, %free.i.i30
  %isNull.i.i13 = icmp eq ptr %xs_2439_556.unpack8, null
  br i1 %isNull.i.i13, label %erasePositive.exit23, label %next.i.i14

next.i.i14:                                       ; preds = %erasePositive.exit34
  %referenceCount.i.i15 = load i64, ptr %xs_2439_556.unpack8, align 4
  %cond.i.i16 = icmp eq i64 %referenceCount.i.i15, 0
  br i1 %cond.i.i16, label %free.i.i19, label %decr.i.i17

decr.i.i17:                                       ; preds = %next.i.i14
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i15, -1
  store i64 %referenceCount.1.i.i18, ptr %xs_2439_556.unpack8, align 4
  br label %erasePositive.exit23

free.i.i19:                                       ; preds = %next.i.i14
  %objectEraser.i.i20 = getelementptr i8, ptr %xs_2439_556.unpack8, i64 8
  %eraser.i.i21 = load ptr, ptr %objectEraser.i.i20, align 8
  %environment.i.i.i22 = getelementptr i8, ptr %xs_2439_556.unpack8, i64 16
  tail call void %eraser.i.i21(ptr %environment.i.i.i22)
  tail call void @free(ptr nonnull %xs_2439_556.unpack8)
  br label %erasePositive.exit23

erasePositive.exit23:                             ; preds = %erasePositive.exit34, %decr.i.i17, %free.i.i19
  %isNull.i.i = icmp eq ptr %v_coe_3518_15_4_23_3971_557.unpack11, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit23
  %referenceCount.i.i = load i64, ptr %v_coe_3518_15_4_23_3971_557.unpack11, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3518_15_4_23_3971_557.unpack11, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_coe_3518_15_4_23_3971_557.unpack11, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_coe_3518_15_4_23_3971_557.unpack11, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_coe_3518_15_4_23_3971_557.unpack11)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit23, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -72
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_517(%Pos %v_r_2550_4_3_12_31_3960, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -80
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %zs_2441.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %zs_2441.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -72
  %zs_2441.unpack2 = load ptr, ptr %zs_2441.elt1, align 8, !noalias !0
  %ys_2440_pointer_520 = getelementptr i8, ptr %stackPointer.i, i64 -64
  %ys_2440.unpack = load i64, ptr %ys_2440_pointer_520, align 8, !noalias !0
  %ys_2440.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %ys_2440.unpack5 = load ptr, ptr %ys_2440.elt4, align 8, !noalias !0
  %xs_2439_pointer_521 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %xs_2439.unpack = load i64, ptr %xs_2439_pointer_521, align 8, !noalias !0
  %xs_2439.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %xs_2439.unpack8 = load ptr, ptr %xs_2439.elt7, align 8, !noalias !0
  %v_coe_3521_10_4_3968_pointer_522 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_coe_3521_10_4_3968.unpack = load i64, ptr %v_coe_3521_10_4_3968_pointer_522, align 8, !noalias !0
  %v_coe_3521_10_4_3968.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_coe_3521_10_4_3968.unpack11 = load ptr, ptr %v_coe_3521_10_4_3968.elt10, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_pointer_523 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_coe_3518_15_4_23_3971.unpack = load i64, ptr %v_coe_3518_15_4_23_3971_pointer_523, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971.elt13 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_coe_3518_15_4_23_3971.unpack14 = load ptr, ptr %v_coe_3518_15_4_23_3971.elt13, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %xs_2439.unpack8, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %xs_2439.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %xs_2439.unpack8, align 4
  %currentStackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i31.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %limit.i31 = phi ptr [ %limit.i, %entry ], [ %limit.i31.pre, %next.i.i ]
  %currentStackPointer.i = phi ptr [ %newStackPointer.i, %entry ], [ %currentStackPointer.i.pre, %next.i.i ]
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 88
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i31
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
  %newStackPointer.i32 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i32, i64 88
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i32, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %ys_2440.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_564.repack16 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %ys_2440.unpack5, ptr %stackPointer_564.repack16, align 8, !noalias !0
  %v_r_2550_4_3_12_31_3960_pointer_566 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2550_4_3_12_31_3960.elt = extractvalue %Pos %v_r_2550_4_3_12_31_3960, 0
  store i64 %v_r_2550_4_3_12_31_3960.elt, ptr %v_r_2550_4_3_12_31_3960_pointer_566, align 8, !noalias !0
  %v_r_2550_4_3_12_31_3960_pointer_566.repack18 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %v_r_2550_4_3_12_31_3960.elt19 = extractvalue %Pos %v_r_2550_4_3_12_31_3960, 1
  store ptr %v_r_2550_4_3_12_31_3960.elt19, ptr %v_r_2550_4_3_12_31_3960_pointer_566.repack18, align 8, !noalias !0
  %xs_2439_pointer_567 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %xs_2439.unpack, ptr %xs_2439_pointer_567, align 8, !noalias !0
  %xs_2439_pointer_567.repack20 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %xs_2439.unpack8, ptr %xs_2439_pointer_567.repack20, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_pointer_568 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %v_coe_3518_15_4_23_3971.unpack, ptr %v_coe_3518_15_4_23_3971_pointer_568, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_pointer_568.repack22 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %v_coe_3518_15_4_23_3971.unpack14, ptr %v_coe_3518_15_4_23_3971_pointer_568.repack22, align 8, !noalias !0
  %returnAddress_pointer_569 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %sharer_pointer_570 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %eraser_pointer_571 = getelementptr i8, ptr %common.ret.op.i, i64 80
  store ptr @returnAddress_524, ptr %returnAddress_pointer_569, align 8, !noalias !0
  store ptr @sharer_548, ptr %sharer_pointer_570, align 8, !noalias !0
  store ptr @eraser_558, ptr %eraser_pointer_571, align 8, !noalias !0
  %isNull.i.i8.i = icmp eq ptr %v_coe_3521_10_4_3968.unpack11, null
  br i1 %isNull.i.i8.i, label %sharePositive.exit12.i, label %next.i.i9.i

next.i.i9.i:                                      ; preds = %stackAllocate.exit
  %referenceCount.i.i10.i = load i64, ptr %v_coe_3521_10_4_3968.unpack11, align 4
  %referenceCount.1.i.i11.i = add i64 %referenceCount.i.i10.i, 1
  store i64 %referenceCount.1.i.i11.i, ptr %v_coe_3521_10_4_3968.unpack11, align 4
  br label %sharePositive.exit12.i

sharePositive.exit12.i:                           ; preds = %next.i.i9.i, %stackAllocate.exit
  %isNull.i.i.i = icmp eq ptr %zs_2441.unpack2, null
  br i1 %isNull.i.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %sharePositive.exit12.i
  %referenceCount.i.i.i = load i64, ptr %zs_2441.unpack2, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %zs_2441.unpack2, align 4
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %sharePositive.exit12.i
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 72
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %sharePositive.exit.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 72
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 72
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %sharePositive.exit.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %sharePositive.exit.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %sharePositive.exit.i ]
  %0 = insertvalue %Pos poison, i64 %v_coe_3521_10_4_3968.unpack, 0
  %v_coe_3521_10_4_396812 = insertvalue %Pos %0, ptr %v_coe_3521_10_4_3968.unpack11, 1
  %1 = insertvalue %Pos poison, i64 %zs_2441.unpack, 0
  %zs_24413 = insertvalue %Pos %1, ptr %zs_2441.unpack2, 1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %xs_2439.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_625.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %xs_2439.unpack8, ptr %stackPointer_625.repack1.i, align 8, !noalias !0
  %xs_2439_pointer_627.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %v_coe_3521_10_4_3968.unpack, ptr %xs_2439_pointer_627.i, align 8, !noalias !0
  %xs_2439_pointer_627.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %v_coe_3521_10_4_3968.unpack11, ptr %xs_2439_pointer_627.repack3.i, align 8, !noalias !0
  %ys_2440_pointer_628.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %zs_2441.unpack, ptr %ys_2440_pointer_628.i, align 8, !noalias !0
  %ys_2440_pointer_628.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %zs_2441.unpack2, ptr %ys_2440_pointer_628.repack5.i, align 8, !noalias !0
  %returnAddress_pointer_629.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %sharer_pointer_630.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  %eraser_pointer_631.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr @returnAddress_478, ptr %returnAddress_pointer_629.i, align 8, !noalias !0
  store ptr @sharer_612, ptr %sharer_pointer_630.i, align 8, !noalias !0
  store ptr @eraser_620, ptr %eraser_pointer_631.i, align 8, !noalias !0
  musttail call tailcc void @isShorterThan_2436(%Pos %zs_24413, %Pos %v_coe_3521_10_4_396812, ptr nonnull %stack)
  ret void
}

define void @sharer_577(ptr %stackPointer) {
entry:
  %zs_2441_572.elt1 = getelementptr i8, ptr %stackPointer, i64 -72
  %zs_2441_572.unpack2 = load ptr, ptr %zs_2441_572.elt1, align 8, !noalias !0
  %ys_2440_573.elt4 = getelementptr i8, ptr %stackPointer, i64 -56
  %ys_2440_573.unpack5 = load ptr, ptr %ys_2440_573.elt4, align 8, !noalias !0
  %xs_2439_574.elt7 = getelementptr i8, ptr %stackPointer, i64 -40
  %xs_2439_574.unpack8 = load ptr, ptr %xs_2439_574.elt7, align 8, !noalias !0
  %v_coe_3521_10_4_3968_575.elt10 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_coe_3521_10_4_3968_575.unpack11 = load ptr, ptr %v_coe_3521_10_4_3968_575.elt10, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_576.elt13 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_coe_3518_15_4_23_3971_576.unpack14 = load ptr, ptr %v_coe_3518_15_4_23_3971_576.elt13, align 8, !noalias !0
  %isNull.i.i31 = icmp eq ptr %zs_2441_572.unpack2, null
  br i1 %isNull.i.i31, label %sharePositive.exit35, label %next.i.i32

next.i.i32:                                       ; preds = %entry
  %referenceCount.i.i33 = load i64, ptr %zs_2441_572.unpack2, align 4
  %referenceCount.1.i.i34 = add i64 %referenceCount.i.i33, 1
  store i64 %referenceCount.1.i.i34, ptr %zs_2441_572.unpack2, align 4
  br label %sharePositive.exit35

sharePositive.exit35:                             ; preds = %entry, %next.i.i32
  %isNull.i.i26 = icmp eq ptr %ys_2440_573.unpack5, null
  br i1 %isNull.i.i26, label %sharePositive.exit30, label %next.i.i27

next.i.i27:                                       ; preds = %sharePositive.exit35
  %referenceCount.i.i28 = load i64, ptr %ys_2440_573.unpack5, align 4
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i28, 1
  store i64 %referenceCount.1.i.i29, ptr %ys_2440_573.unpack5, align 4
  br label %sharePositive.exit30

sharePositive.exit30:                             ; preds = %sharePositive.exit35, %next.i.i27
  %isNull.i.i21 = icmp eq ptr %xs_2439_574.unpack8, null
  br i1 %isNull.i.i21, label %sharePositive.exit25, label %next.i.i22

next.i.i22:                                       ; preds = %sharePositive.exit30
  %referenceCount.i.i23 = load i64, ptr %xs_2439_574.unpack8, align 4
  %referenceCount.1.i.i24 = add i64 %referenceCount.i.i23, 1
  store i64 %referenceCount.1.i.i24, ptr %xs_2439_574.unpack8, align 4
  br label %sharePositive.exit25

sharePositive.exit25:                             ; preds = %sharePositive.exit30, %next.i.i22
  %isNull.i.i16 = icmp eq ptr %v_coe_3521_10_4_3968_575.unpack11, null
  br i1 %isNull.i.i16, label %sharePositive.exit20, label %next.i.i17

next.i.i17:                                       ; preds = %sharePositive.exit25
  %referenceCount.i.i18 = load i64, ptr %v_coe_3521_10_4_3968_575.unpack11, align 4
  %referenceCount.1.i.i19 = add i64 %referenceCount.i.i18, 1
  store i64 %referenceCount.1.i.i19, ptr %v_coe_3521_10_4_3968_575.unpack11, align 4
  br label %sharePositive.exit20

sharePositive.exit20:                             ; preds = %sharePositive.exit25, %next.i.i17
  %isNull.i.i = icmp eq ptr %v_coe_3518_15_4_23_3971_576.unpack14, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit20
  %referenceCount.i.i = load i64, ptr %v_coe_3518_15_4_23_3971_576.unpack14, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3518_15_4_23_3971_576.unpack14, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit20, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_589(ptr %stackPointer) {
entry:
  %zs_2441_584.elt1 = getelementptr i8, ptr %stackPointer, i64 -72
  %zs_2441_584.unpack2 = load ptr, ptr %zs_2441_584.elt1, align 8, !noalias !0
  %ys_2440_585.elt4 = getelementptr i8, ptr %stackPointer, i64 -56
  %ys_2440_585.unpack5 = load ptr, ptr %ys_2440_585.elt4, align 8, !noalias !0
  %xs_2439_586.elt7 = getelementptr i8, ptr %stackPointer, i64 -40
  %xs_2439_586.unpack8 = load ptr, ptr %xs_2439_586.elt7, align 8, !noalias !0
  %v_coe_3521_10_4_3968_587.elt10 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_coe_3521_10_4_3968_587.unpack11 = load ptr, ptr %v_coe_3521_10_4_3968_587.elt10, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_588.elt13 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_coe_3518_15_4_23_3971_588.unpack14 = load ptr, ptr %v_coe_3518_15_4_23_3971_588.elt13, align 8, !noalias !0
  %isNull.i.i49 = icmp eq ptr %zs_2441_584.unpack2, null
  br i1 %isNull.i.i49, label %erasePositive.exit59, label %next.i.i50

next.i.i50:                                       ; preds = %entry
  %referenceCount.i.i51 = load i64, ptr %zs_2441_584.unpack2, align 4
  %cond.i.i52 = icmp eq i64 %referenceCount.i.i51, 0
  br i1 %cond.i.i52, label %free.i.i55, label %decr.i.i53

decr.i.i53:                                       ; preds = %next.i.i50
  %referenceCount.1.i.i54 = add i64 %referenceCount.i.i51, -1
  store i64 %referenceCount.1.i.i54, ptr %zs_2441_584.unpack2, align 4
  br label %erasePositive.exit59

free.i.i55:                                       ; preds = %next.i.i50
  %objectEraser.i.i56 = getelementptr i8, ptr %zs_2441_584.unpack2, i64 8
  %eraser.i.i57 = load ptr, ptr %objectEraser.i.i56, align 8
  %environment.i.i.i58 = getelementptr i8, ptr %zs_2441_584.unpack2, i64 16
  tail call void %eraser.i.i57(ptr %environment.i.i.i58)
  tail call void @free(ptr nonnull %zs_2441_584.unpack2)
  br label %erasePositive.exit59

erasePositive.exit59:                             ; preds = %entry, %decr.i.i53, %free.i.i55
  %isNull.i.i38 = icmp eq ptr %ys_2440_585.unpack5, null
  br i1 %isNull.i.i38, label %erasePositive.exit48, label %next.i.i39

next.i.i39:                                       ; preds = %erasePositive.exit59
  %referenceCount.i.i40 = load i64, ptr %ys_2440_585.unpack5, align 4
  %cond.i.i41 = icmp eq i64 %referenceCount.i.i40, 0
  br i1 %cond.i.i41, label %free.i.i44, label %decr.i.i42

decr.i.i42:                                       ; preds = %next.i.i39
  %referenceCount.1.i.i43 = add i64 %referenceCount.i.i40, -1
  store i64 %referenceCount.1.i.i43, ptr %ys_2440_585.unpack5, align 4
  br label %erasePositive.exit48

free.i.i44:                                       ; preds = %next.i.i39
  %objectEraser.i.i45 = getelementptr i8, ptr %ys_2440_585.unpack5, i64 8
  %eraser.i.i46 = load ptr, ptr %objectEraser.i.i45, align 8
  %environment.i.i.i47 = getelementptr i8, ptr %ys_2440_585.unpack5, i64 16
  tail call void %eraser.i.i46(ptr %environment.i.i.i47)
  tail call void @free(ptr nonnull %ys_2440_585.unpack5)
  br label %erasePositive.exit48

erasePositive.exit48:                             ; preds = %erasePositive.exit59, %decr.i.i42, %free.i.i44
  %isNull.i.i27 = icmp eq ptr %xs_2439_586.unpack8, null
  br i1 %isNull.i.i27, label %erasePositive.exit37, label %next.i.i28

next.i.i28:                                       ; preds = %erasePositive.exit48
  %referenceCount.i.i29 = load i64, ptr %xs_2439_586.unpack8, align 4
  %cond.i.i30 = icmp eq i64 %referenceCount.i.i29, 0
  br i1 %cond.i.i30, label %free.i.i33, label %decr.i.i31

decr.i.i31:                                       ; preds = %next.i.i28
  %referenceCount.1.i.i32 = add i64 %referenceCount.i.i29, -1
  store i64 %referenceCount.1.i.i32, ptr %xs_2439_586.unpack8, align 4
  br label %erasePositive.exit37

free.i.i33:                                       ; preds = %next.i.i28
  %objectEraser.i.i34 = getelementptr i8, ptr %xs_2439_586.unpack8, i64 8
  %eraser.i.i35 = load ptr, ptr %objectEraser.i.i34, align 8
  %environment.i.i.i36 = getelementptr i8, ptr %xs_2439_586.unpack8, i64 16
  tail call void %eraser.i.i35(ptr %environment.i.i.i36)
  tail call void @free(ptr nonnull %xs_2439_586.unpack8)
  br label %erasePositive.exit37

erasePositive.exit37:                             ; preds = %erasePositive.exit48, %decr.i.i31, %free.i.i33
  %isNull.i.i16 = icmp eq ptr %v_coe_3521_10_4_3968_587.unpack11, null
  br i1 %isNull.i.i16, label %erasePositive.exit26, label %next.i.i17

next.i.i17:                                       ; preds = %erasePositive.exit37
  %referenceCount.i.i18 = load i64, ptr %v_coe_3521_10_4_3968_587.unpack11, align 4
  %cond.i.i19 = icmp eq i64 %referenceCount.i.i18, 0
  br i1 %cond.i.i19, label %free.i.i22, label %decr.i.i20

decr.i.i20:                                       ; preds = %next.i.i17
  %referenceCount.1.i.i21 = add i64 %referenceCount.i.i18, -1
  store i64 %referenceCount.1.i.i21, ptr %v_coe_3521_10_4_3968_587.unpack11, align 4
  br label %erasePositive.exit26

free.i.i22:                                       ; preds = %next.i.i17
  %objectEraser.i.i23 = getelementptr i8, ptr %v_coe_3521_10_4_3968_587.unpack11, i64 8
  %eraser.i.i24 = load ptr, ptr %objectEraser.i.i23, align 8
  %environment.i.i.i25 = getelementptr i8, ptr %v_coe_3521_10_4_3968_587.unpack11, i64 16
  tail call void %eraser.i.i24(ptr %environment.i.i.i25)
  tail call void @free(ptr nonnull %v_coe_3521_10_4_3968_587.unpack11)
  br label %erasePositive.exit26

erasePositive.exit26:                             ; preds = %erasePositive.exit37, %decr.i.i20, %free.i.i22
  %isNull.i.i = icmp eq ptr %v_coe_3518_15_4_23_3971_588.unpack14, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit26
  %referenceCount.i.i = load i64, ptr %v_coe_3518_15_4_23_3971_588.unpack14, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3518_15_4_23_3971_588.unpack14, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_coe_3518_15_4_23_3971_588.unpack14, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_coe_3518_15_4_23_3971_588.unpack14, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_coe_3518_15_4_23_3971_588.unpack14)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit26, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -104
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -88
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_478(%Pos %v_r_2548_3616, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i274 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i274)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %zs_2441.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %zs_2441.elt3 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %zs_2441.unpack4 = load ptr, ptr %zs_2441.elt3, align 8, !noalias !0
  %xs_2439_pointer_481 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %xs_2439.unpack = load i64, ptr %xs_2439_pointer_481, align 8, !noalias !0
  %xs_2439.elt6 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %xs_2439.unpack7 = load ptr, ptr %xs_2439.elt6, align 8, !noalias !0
  %ys_2440_pointer_482 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %ys_2440.unpack = load i64, ptr %ys_2440_pointer_482, align 8, !noalias !0
  %ys_2440.elt9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %ys_2440.unpack10 = load ptr, ptr %ys_2440.elt9, align 8, !noalias !0
  %tag_483 = extractvalue %Pos %v_r_2548_3616, 0
  switch i64 %tag_483, label %label_485 [
    i64 0, label %label_489
    i64 1, label %label_608
  ]

label_485:                                        ; preds = %entry
  ret void

label_489:                                        ; preds = %entry
  %isNull.i.i259 = icmp eq ptr %xs_2439.unpack7, null
  br i1 %isNull.i.i259, label %erasePositive.exit269, label %next.i.i260

next.i.i260:                                      ; preds = %label_489
  %referenceCount.i.i261 = load i64, ptr %xs_2439.unpack7, align 4
  %cond.i.i262 = icmp eq i64 %referenceCount.i.i261, 0
  br i1 %cond.i.i262, label %free.i.i265, label %decr.i.i263

decr.i.i263:                                      ; preds = %next.i.i260
  %referenceCount.1.i.i264 = add i64 %referenceCount.i.i261, -1
  store i64 %referenceCount.1.i.i264, ptr %xs_2439.unpack7, align 4
  br label %erasePositive.exit269

free.i.i265:                                      ; preds = %next.i.i260
  %objectEraser.i.i266 = getelementptr i8, ptr %xs_2439.unpack7, i64 8
  %eraser.i.i267 = load ptr, ptr %objectEraser.i.i266, align 8
  %environment.i.i.i268 = getelementptr i8, ptr %xs_2439.unpack7, i64 16
  tail call void %eraser.i.i267(ptr %environment.i.i.i268)
  tail call void @free(ptr nonnull %xs_2439.unpack7)
  br label %erasePositive.exit269

erasePositive.exit269:                            ; preds = %label_489, %decr.i.i263, %free.i.i265
  %isNull.i.i248 = icmp eq ptr %ys_2440.unpack10, null
  br i1 %isNull.i.i248, label %erasePositive.exit258, label %next.i.i249

next.i.i249:                                      ; preds = %erasePositive.exit269
  %referenceCount.i.i250 = load i64, ptr %ys_2440.unpack10, align 4
  %cond.i.i251 = icmp eq i64 %referenceCount.i.i250, 0
  br i1 %cond.i.i251, label %free.i.i254, label %decr.i.i252

decr.i.i252:                                      ; preds = %next.i.i249
  %referenceCount.1.i.i253 = add i64 %referenceCount.i.i250, -1
  store i64 %referenceCount.1.i.i253, ptr %ys_2440.unpack10, align 4
  br label %erasePositive.exit258

free.i.i254:                                      ; preds = %next.i.i249
  %objectEraser.i.i255 = getelementptr i8, ptr %ys_2440.unpack10, i64 8
  %eraser.i.i256 = load ptr, ptr %objectEraser.i.i255, align 8
  %environment.i.i.i257 = getelementptr i8, ptr %ys_2440.unpack10, i64 16
  tail call void %eraser.i.i256(ptr %environment.i.i.i257)
  tail call void @free(ptr nonnull %ys_2440.unpack10)
  br label %erasePositive.exit258

erasePositive.exit258:                            ; preds = %erasePositive.exit269, %decr.i.i252, %free.i.i254
  %0 = insertvalue %Pos poison, i64 %zs_2441.unpack, 0
  %zs_24415 = insertvalue %Pos %0, ptr %zs_2441.unpack4, 1
  %stackPointer.i276 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i278 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i279 = icmp ule ptr %stackPointer.i276, %limit.i278
  tail call void @llvm.assume(i1 %isInside.i279)
  %newStackPointer.i280 = getelementptr i8, ptr %stackPointer.i276, i64 -24
  store ptr %newStackPointer.i280, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_486 = load ptr, ptr %newStackPointer.i280, align 8, !noalias !0
  musttail call tailcc void %returnAddress_486(%Pos %zs_24415, ptr nonnull %stack)
  ret void

label_495:                                        ; preds = %sharePositive.exit
  %isNull.i.i237 = icmp eq ptr %ys_2440.unpack10, null
  br i1 %isNull.i.i237, label %erasePositive.exit247, label %next.i.i238

next.i.i238:                                      ; preds = %label_495
  %referenceCount.i.i239 = load i64, ptr %ys_2440.unpack10, align 4
  %cond.i.i240 = icmp eq i64 %referenceCount.i.i239, 0
  br i1 %cond.i.i240, label %free.i.i243, label %decr.i.i241

decr.i.i241:                                      ; preds = %next.i.i238
  %referenceCount.1.i.i242 = add i64 %referenceCount.i.i239, -1
  store i64 %referenceCount.1.i.i242, ptr %ys_2440.unpack10, align 4
  br label %erasePositive.exit247

free.i.i243:                                      ; preds = %next.i.i238
  %objectEraser.i.i244 = getelementptr i8, ptr %ys_2440.unpack10, i64 8
  %eraser.i.i245 = load ptr, ptr %objectEraser.i.i244, align 8
  %environment.i.i.i246 = getelementptr i8, ptr %ys_2440.unpack10, i64 16
  tail call void %eraser.i.i245(ptr %environment.i.i.i246)
  tail call void @free(ptr nonnull %ys_2440.unpack10)
  br label %erasePositive.exit247

erasePositive.exit247:                            ; preds = %label_495, %decr.i.i241, %free.i.i243
  %isNull.i.i226 = icmp eq ptr %zs_2441.unpack4, null
  br i1 %isNull.i.i226, label %erasePositive.exit236, label %next.i.i227

next.i.i227:                                      ; preds = %erasePositive.exit247
  %referenceCount.i.i228 = load i64, ptr %zs_2441.unpack4, align 4
  %cond.i.i229 = icmp eq i64 %referenceCount.i.i228, 0
  br i1 %cond.i.i229, label %free.i.i232, label %decr.i.i230

decr.i.i230:                                      ; preds = %next.i.i227
  %referenceCount.1.i.i231 = add i64 %referenceCount.i.i228, -1
  store i64 %referenceCount.1.i.i231, ptr %zs_2441.unpack4, align 4
  br label %erasePositive.exit236

free.i.i232:                                      ; preds = %next.i.i227
  %objectEraser.i.i233 = getelementptr i8, ptr %zs_2441.unpack4, i64 8
  %eraser.i.i234 = load ptr, ptr %objectEraser.i.i233, align 8
  %environment.i.i.i235 = getelementptr i8, ptr %zs_2441.unpack4, i64 16
  tail call void %eraser.i.i234(ptr %environment.i.i.i235)
  tail call void @free(ptr nonnull %zs_2441.unpack4)
  br label %erasePositive.exit236

erasePositive.exit236:                            ; preds = %erasePositive.exit247, %decr.i.i230, %free.i.i232
  br i1 %isNull.i.i, label %erasePositive.exit214, label %next.i.i216

next.i.i216:                                      ; preds = %erasePositive.exit236
  %referenceCount.i.i217 = load i64, ptr %xs_2439.unpack7, align 4
  %cond.i.i218 = icmp eq i64 %referenceCount.i.i217, 0
  br i1 %cond.i.i218, label %free.i.i221, label %decr.i.i219

decr.i.i219:                                      ; preds = %next.i.i216
  %referenceCount.1.i.i220 = add i64 %referenceCount.i.i217, -1
  store i64 %referenceCount.1.i.i220, ptr %xs_2439.unpack7, align 4
  br label %next.i.i205

free.i.i221:                                      ; preds = %next.i.i216
  %objectEraser.i.i222 = getelementptr i8, ptr %xs_2439.unpack7, i64 8
  %eraser.i.i223 = load ptr, ptr %objectEraser.i.i222, align 8
  %environment.i.i.i224 = getelementptr i8, ptr %xs_2439.unpack7, i64 16
  tail call void %eraser.i.i223(ptr %environment.i.i.i224)
  tail call void @free(ptr nonnull %xs_2439.unpack7)
  %referenceCount.i.i206.pr = load i64, ptr %xs_2439.unpack7, align 4
  br label %next.i.i205

next.i.i205:                                      ; preds = %decr.i.i219, %free.i.i221
  %referenceCount.i.i206 = phi i64 [ %referenceCount.1.i.i220, %decr.i.i219 ], [ %referenceCount.i.i206.pr, %free.i.i221 ]
  %cond.i.i207 = icmp eq i64 %referenceCount.i.i206, 0
  br i1 %cond.i.i207, label %free.i.i210, label %decr.i.i208

decr.i.i208:                                      ; preds = %next.i.i205
  %referenceCount.1.i.i209 = add i64 %referenceCount.i.i206, -1
  store i64 %referenceCount.1.i.i209, ptr %xs_2439.unpack7, align 4
  br label %erasePositive.exit214

free.i.i210:                                      ; preds = %next.i.i205
  %objectEraser.i.i211 = getelementptr i8, ptr %xs_2439.unpack7, i64 8
  %eraser.i.i212 = load ptr, ptr %objectEraser.i.i211, align 8
  %environment.i.i.i213 = getelementptr i8, ptr %xs_2439.unpack7, i64 16
  tail call void %eraser.i.i212(ptr %environment.i.i.i213)
  tail call void @free(ptr nonnull %xs_2439.unpack7)
  br label %erasePositive.exit214

erasePositive.exit214:                            ; preds = %erasePositive.exit236, %decr.i.i208, %free.i.i210
  %utf8StringLiteral_4862 = tail call %Pos @c_bytearray_construct(i64 6, ptr nonnull @utf8StringLiteral_4862.lit)
  tail call void @c_io_println_String(%Pos %utf8StringLiteral_4862)
  tail call void @exit(i32 1)
  %stackPointer.i282 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i284 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i285 = icmp ule ptr %stackPointer.i282, %limit.i284
  tail call void @llvm.assume(i1 %isInside.i285)
  %newStackPointer.i286 = getelementptr i8, ptr %stackPointer.i282, i64 -24
  store ptr %newStackPointer.i286, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_492 = load ptr, ptr %newStackPointer.i286, align 8, !noalias !0
  musttail call tailcc void %returnAddress_492(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_504:                                        ; preds = %sharePositive.exit37
  %isNull.i.i193 = icmp eq ptr %zs_2441.unpack4, null
  br i1 %isNull.i.i193, label %erasePositive.exit203, label %next.i.i194

next.i.i194:                                      ; preds = %label_504
  %referenceCount.i.i195 = load i64, ptr %zs_2441.unpack4, align 4
  %cond.i.i196 = icmp eq i64 %referenceCount.i.i195, 0
  br i1 %cond.i.i196, label %free.i.i199, label %decr.i.i197

decr.i.i197:                                      ; preds = %next.i.i194
  %referenceCount.1.i.i198 = add i64 %referenceCount.i.i195, -1
  store i64 %referenceCount.1.i.i198, ptr %zs_2441.unpack4, align 4
  br label %erasePositive.exit203

free.i.i199:                                      ; preds = %next.i.i194
  %objectEraser.i.i200 = getelementptr i8, ptr %zs_2441.unpack4, i64 8
  %eraser.i.i201 = load ptr, ptr %objectEraser.i.i200, align 8
  %environment.i.i.i202 = getelementptr i8, ptr %zs_2441.unpack4, i64 16
  tail call void %eraser.i.i201(ptr %environment.i.i.i202)
  tail call void @free(ptr nonnull %zs_2441.unpack4)
  br label %erasePositive.exit203

erasePositive.exit203:                            ; preds = %label_504, %decr.i.i197, %free.i.i199
  br i1 %isNull.i.i38, label %erasePositive.exit192, label %next.i.i183

next.i.i183:                                      ; preds = %erasePositive.exit203
  %referenceCount.i.i184 = load i64, ptr %v_coe_3524_5_3909.unpack13, align 4
  %cond.i.i185 = icmp eq i64 %referenceCount.i.i184, 0
  br i1 %cond.i.i185, label %free.i.i188, label %decr.i.i186

decr.i.i186:                                      ; preds = %next.i.i183
  %referenceCount.1.i.i187 = add i64 %referenceCount.i.i184, -1
  store i64 %referenceCount.1.i.i187, ptr %v_coe_3524_5_3909.unpack13, align 4
  br label %erasePositive.exit192

free.i.i188:                                      ; preds = %next.i.i183
  %objectEraser.i.i189 = getelementptr i8, ptr %v_coe_3524_5_3909.unpack13, i64 8
  %eraser.i.i190 = load ptr, ptr %objectEraser.i.i189, align 8
  %environment.i.i.i191 = getelementptr i8, ptr %v_coe_3524_5_3909.unpack13, i64 16
  tail call void %eraser.i.i190(ptr %environment.i.i.i191)
  tail call void @free(ptr nonnull %v_coe_3524_5_3909.unpack13)
  br label %erasePositive.exit192

erasePositive.exit192:                            ; preds = %erasePositive.exit203, %decr.i.i186, %free.i.i188
  br i1 %isNull.i.i33, label %next.i.i161, label %next.i.i172

next.i.i172:                                      ; preds = %erasePositive.exit192
  %referenceCount.i.i173 = load i64, ptr %ys_2440.unpack10, align 4
  %cond.i.i174 = icmp eq i64 %referenceCount.i.i173, 0
  br i1 %cond.i.i174, label %free.i.i177, label %decr.i.i175

decr.i.i175:                                      ; preds = %next.i.i172
  %referenceCount.1.i.i176 = add i64 %referenceCount.i.i173, -1
  store i64 %referenceCount.1.i.i176, ptr %ys_2440.unpack10, align 4
  br label %next.i.i161

free.i.i177:                                      ; preds = %next.i.i172
  %objectEraser.i.i178 = getelementptr i8, ptr %ys_2440.unpack10, i64 8
  %eraser.i.i179 = load ptr, ptr %objectEraser.i.i178, align 8
  %environment.i.i.i180 = getelementptr i8, ptr %ys_2440.unpack10, i64 16
  tail call void %eraser.i.i179(ptr %environment.i.i.i180)
  tail call void @free(ptr nonnull %ys_2440.unpack10)
  br label %next.i.i161

next.i.i161:                                      ; preds = %free.i.i177, %decr.i.i175, %erasePositive.exit192
  %referenceCount.i.i162 = load i64, ptr %xs_2439.unpack7, align 4
  %cond.i.i163 = icmp eq i64 %referenceCount.i.i162, 0
  br i1 %cond.i.i163, label %free.i.i166, label %decr.i.i164

decr.i.i164:                                      ; preds = %next.i.i161
  %referenceCount.1.i.i165 = add i64 %referenceCount.i.i162, -1
  store i64 %referenceCount.1.i.i165, ptr %xs_2439.unpack7, align 4
  br label %erasePositive.exit170

free.i.i166:                                      ; preds = %next.i.i161
  %objectEraser.i.i167 = getelementptr i8, ptr %xs_2439.unpack7, i64 8
  %eraser.i.i168 = load ptr, ptr %objectEraser.i.i167, align 8
  tail call void %eraser.i.i168(ptr %environment.i)
  tail call void @free(ptr nonnull %xs_2439.unpack7)
  br label %erasePositive.exit170

erasePositive.exit170:                            ; preds = %decr.i.i164, %free.i.i166
  br i1 %isNull.i.i33, label %erasePositive.exit159, label %next.i.i150

next.i.i150:                                      ; preds = %erasePositive.exit170
  %referenceCount.i.i151 = load i64, ptr %ys_2440.unpack10, align 4
  %cond.i.i152 = icmp eq i64 %referenceCount.i.i151, 0
  br i1 %cond.i.i152, label %free.i.i155, label %decr.i.i153

decr.i.i153:                                      ; preds = %next.i.i150
  %referenceCount.1.i.i154 = add i64 %referenceCount.i.i151, -1
  store i64 %referenceCount.1.i.i154, ptr %ys_2440.unpack10, align 4
  br label %erasePositive.exit159

free.i.i155:                                      ; preds = %next.i.i150
  %objectEraser.i.i156 = getelementptr i8, ptr %ys_2440.unpack10, i64 8
  %eraser.i.i157 = load ptr, ptr %objectEraser.i.i156, align 8
  %environment.i.i.i158 = getelementptr i8, ptr %ys_2440.unpack10, i64 16
  tail call void %eraser.i.i157(ptr %environment.i.i.i158)
  tail call void @free(ptr nonnull %ys_2440.unpack10)
  br label %erasePositive.exit159

erasePositive.exit159:                            ; preds = %erasePositive.exit170, %decr.i.i153, %free.i.i155
  %utf8StringLiteral_4860 = tail call %Pos @c_bytearray_construct(i64 6, ptr nonnull @utf8StringLiteral_4860.lit)
  tail call void @c_io_println_String(%Pos %utf8StringLiteral_4860)
  tail call void @exit(i32 1)
  %stackPointer.i288 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i290 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i291 = icmp ule ptr %stackPointer.i288, %limit.i290
  tail call void @llvm.assume(i1 %isInside.i291)
  %newStackPointer.i292 = getelementptr i8, ptr %stackPointer.i288, i64 -24
  store ptr %newStackPointer.i292, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_501 = load ptr, ptr %newStackPointer.i292, align 8, !noalias !0
  musttail call tailcc void %returnAddress_501(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

next.i.i139:                                      ; preds = %sharePositive.exit47.thread
  %cond.i.i141 = icmp eq i64 %referenceCount.1.i.i46, 0
  br i1 %cond.i.i141, label %free.i.i144, label %decr.i.i142

decr.i.i142:                                      ; preds = %next.i.i139
  store i64 %referenceCount.i.i45, ptr %zs_2441.unpack4, align 4
  br label %erasePositive.exit148

free.i.i144:                                      ; preds = %next.i.i139
  %objectEraser.i.i145 = getelementptr i8, ptr %zs_2441.unpack4, i64 8
  %eraser.i.i146 = load ptr, ptr %objectEraser.i.i145, align 8
  %environment.i.i.i147 = getelementptr i8, ptr %zs_2441.unpack4, i64 16
  tail call void %eraser.i.i146(ptr %environment.i.i.i147)
  tail call void @free(ptr nonnull %zs_2441.unpack4)
  br label %erasePositive.exit148

erasePositive.exit148:                            ; preds = %sharePositive.exit47, %decr.i.i142, %free.i.i144
  br i1 %isNull.i.i38, label %next.i.i117, label %next.i.i128

next.i.i128:                                      ; preds = %erasePositive.exit148
  %referenceCount.i.i129 = load i64, ptr %v_coe_3524_5_3909.unpack13, align 4
  %cond.i.i130 = icmp eq i64 %referenceCount.i.i129, 0
  br i1 %cond.i.i130, label %free.i.i133, label %decr.i.i131

decr.i.i131:                                      ; preds = %next.i.i128
  %referenceCount.1.i.i132 = add i64 %referenceCount.i.i129, -1
  store i64 %referenceCount.1.i.i132, ptr %v_coe_3524_5_3909.unpack13, align 4
  br label %next.i.i117

free.i.i133:                                      ; preds = %next.i.i128
  %objectEraser.i.i134 = getelementptr i8, ptr %v_coe_3524_5_3909.unpack13, i64 8
  %eraser.i.i135 = load ptr, ptr %objectEraser.i.i134, align 8
  %environment.i.i.i136 = getelementptr i8, ptr %v_coe_3524_5_3909.unpack13, i64 16
  tail call void %eraser.i.i135(ptr %environment.i.i.i136)
  tail call void @free(ptr nonnull %v_coe_3524_5_3909.unpack13)
  br label %next.i.i117

next.i.i117:                                      ; preds = %free.i.i133, %decr.i.i131, %erasePositive.exit148
  %referenceCount.i.i118 = load i64, ptr %ys_2440.unpack10, align 4
  %cond.i.i119 = icmp eq i64 %referenceCount.i.i118, 0
  br i1 %cond.i.i119, label %free.i.i122, label %decr.i.i120

decr.i.i120:                                      ; preds = %next.i.i117
  %referenceCount.1.i.i121 = add i64 %referenceCount.i.i118, -1
  store i64 %referenceCount.1.i.i121, ptr %ys_2440.unpack10, align 4
  br label %next.i.i106

free.i.i122:                                      ; preds = %next.i.i117
  %objectEraser.i.i123 = getelementptr i8, ptr %ys_2440.unpack10, i64 8
  %eraser.i.i124 = load ptr, ptr %objectEraser.i.i123, align 8
  tail call void %eraser.i.i124(ptr %environment.i31)
  tail call void @free(ptr nonnull %ys_2440.unpack10)
  br label %next.i.i106

next.i.i106:                                      ; preds = %free.i.i122, %decr.i.i120
  %referenceCount.i.i107 = load i64, ptr %xs_2439.unpack7, align 4
  %cond.i.i108 = icmp eq i64 %referenceCount.i.i107, 0
  br i1 %cond.i.i108, label %free.i.i111, label %decr.i.i109

decr.i.i109:                                      ; preds = %next.i.i106
  %referenceCount.1.i.i110 = add i64 %referenceCount.i.i107, -1
  store i64 %referenceCount.1.i.i110, ptr %xs_2439.unpack7, align 4
  br label %erasePositive.exit115

free.i.i111:                                      ; preds = %next.i.i106
  %objectEraser.i.i112 = getelementptr i8, ptr %xs_2439.unpack7, i64 8
  %eraser.i.i113 = load ptr, ptr %objectEraser.i.i112, align 8
  tail call void %eraser.i.i113(ptr %environment.i)
  tail call void @free(ptr nonnull %xs_2439.unpack7)
  br label %erasePositive.exit115

erasePositive.exit115:                            ; preds = %decr.i.i109, %free.i.i111
  br i1 %isNull.i.i48, label %erasePositive.exit104, label %next.i.i95

next.i.i95:                                       ; preds = %erasePositive.exit115
  %referenceCount.i.i96 = load i64, ptr %v_coe_3521_10_4_3968.unpack16, align 4
  %cond.i.i97 = icmp eq i64 %referenceCount.i.i96, 0
  br i1 %cond.i.i97, label %free.i.i100, label %decr.i.i98

decr.i.i98:                                       ; preds = %next.i.i95
  %referenceCount.1.i.i99 = add i64 %referenceCount.i.i96, -1
  store i64 %referenceCount.1.i.i99, ptr %v_coe_3521_10_4_3968.unpack16, align 4
  br label %erasePositive.exit104

free.i.i100:                                      ; preds = %next.i.i95
  %objectEraser.i.i101 = getelementptr i8, ptr %v_coe_3521_10_4_3968.unpack16, i64 8
  %eraser.i.i102 = load ptr, ptr %objectEraser.i.i101, align 8
  %environment.i.i.i103 = getelementptr i8, ptr %v_coe_3521_10_4_3968.unpack16, i64 16
  tail call void %eraser.i.i102(ptr %environment.i.i.i103)
  tail call void @free(ptr nonnull %v_coe_3521_10_4_3968.unpack16)
  br label %erasePositive.exit104

erasePositive.exit104:                            ; preds = %erasePositive.exit115, %decr.i.i98, %free.i.i100
  br i1 %isNull.i.i43, label %erasePositive.exit, label %next.i.i91

next.i.i91:                                       ; preds = %erasePositive.exit104
  %referenceCount.i.i92 = load i64, ptr %zs_2441.unpack4, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i92, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i91
  %referenceCount.1.i.i93 = add i64 %referenceCount.i.i92, -1
  store i64 %referenceCount.1.i.i93, ptr %zs_2441.unpack4, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i91
  %objectEraser.i.i = getelementptr i8, ptr %zs_2441.unpack4, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %zs_2441.unpack4, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %zs_2441.unpack4)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit104, %decr.i.i, %free.i.i
  %utf8StringLiteral_4858 = tail call %Pos @c_bytearray_construct(i64 6, ptr nonnull @utf8StringLiteral_4858.lit)
  tail call void @c_io_println_String(%Pos %utf8StringLiteral_4858)
  tail call void @exit(i32 1)
  %stackPointer.i294 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i296 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i297 = icmp ule ptr %stackPointer.i294, %limit.i296
  tail call void @llvm.assume(i1 %isInside.i297)
  %newStackPointer.i298 = getelementptr i8, ptr %stackPointer.i294, i64 -24
  store ptr %newStackPointer.i298, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_510 = load ptr, ptr %newStackPointer.i298, align 8, !noalias !0
  musttail call tailcc void %returnAddress_510(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_605:                                        ; preds = %sharePositive.exit47.thread, %sharePositive.exit47
  %environment.i32 = getelementptr i8, ptr %zs_2441.unpack4, i64 16
  %v_coe_3518_15_4_23_3971_pointer_516 = getelementptr i8, ptr %zs_2441.unpack4, i64 32
  %v_coe_3518_15_4_23_3971.unpack = load i64, ptr %v_coe_3518_15_4_23_3971_pointer_516, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971.elt18 = getelementptr i8, ptr %zs_2441.unpack4, i64 40
  %v_coe_3518_15_4_23_3971.unpack19 = load ptr, ptr %v_coe_3518_15_4_23_3971.elt18, align 8, !noalias !0
  %isNull.i.i63 = icmp eq ptr %v_coe_3518_15_4_23_3971.unpack19, null
  br i1 %isNull.i.i63, label %next.i80, label %next.i.i64

next.i.i64:                                       ; preds = %label_605
  %referenceCount.i.i65 = load i64, ptr %v_coe_3518_15_4_23_3971.unpack19, align 4
  %referenceCount.1.i.i66 = add i64 %referenceCount.i.i65, 1
  store i64 %referenceCount.1.i.i66, ptr %v_coe_3518_15_4_23_3971.unpack19, align 4
  br label %next.i80

next.i80:                                         ; preds = %next.i.i64, %label_605
  %referenceCount.i81 = load i64, ptr %zs_2441.unpack4, align 4
  %cond.i82 = icmp eq i64 %referenceCount.i81, 0
  br i1 %cond.i82, label %free.i85, label %sharePositive.exit57

free.i85:                                         ; preds = %next.i80
  %objectEraser.i86 = getelementptr i8, ptr %zs_2441.unpack4, i64 8
  %eraser.i87 = load ptr, ptr %objectEraser.i86, align 8
  tail call void %eraser.i87(ptr %environment.i32)
  tail call void @free(ptr nonnull %zs_2441.unpack4)
  %referenceCount.i.i60.pre = load i64, ptr %zs_2441.unpack4, align 4
  %1 = add i64 %referenceCount.i.i60.pre, 1
  br label %sharePositive.exit57

sharePositive.exit57:                             ; preds = %next.i80, %free.i85
  %referenceCount.i.i60 = phi i64 [ %1, %free.i85 ], [ %referenceCount.i81, %next.i80 ]
  store i64 %referenceCount.i.i60, ptr %zs_2441.unpack4, align 4
  %referenceCount.i.i55 = load i64, ptr %ys_2440.unpack10, align 4
  %referenceCount.1.i.i56 = add i64 %referenceCount.i.i55, 1
  store i64 %referenceCount.1.i.i56, ptr %ys_2440.unpack10, align 4
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i301 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 104
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i301
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %sharePositive.exit57
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
  %newStackPointer.i302 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i302, i64 104
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit57, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit57 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i302, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit57 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %zs_2441.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_596.repack21 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %zs_2441.unpack4, ptr %stackPointer_596.repack21, align 8, !noalias !0
  %ys_2440_pointer_598 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 1, ptr %ys_2440_pointer_598, align 8, !noalias !0
  %ys_2440_pointer_598.repack23 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %ys_2440.unpack10, ptr %ys_2440_pointer_598.repack23, align 8, !noalias !0
  %xs_2439_pointer_599 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 1, ptr %xs_2439_pointer_599, align 8, !noalias !0
  %xs_2439_pointer_599.repack25 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %xs_2439.unpack7, ptr %xs_2439_pointer_599.repack25, align 8, !noalias !0
  %v_coe_3521_10_4_3968_pointer_600 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %v_coe_3521_10_4_3968.unpack, ptr %v_coe_3521_10_4_3968_pointer_600, align 8, !noalias !0
  %v_coe_3521_10_4_3968_pointer_600.repack27 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr %v_coe_3521_10_4_3968.unpack16, ptr %v_coe_3521_10_4_3968_pointer_600.repack27, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_pointer_601 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store i64 %v_coe_3518_15_4_23_3971.unpack, ptr %v_coe_3518_15_4_23_3971_pointer_601, align 8, !noalias !0
  %v_coe_3518_15_4_23_3971_pointer_601.repack29 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr %v_coe_3518_15_4_23_3971.unpack19, ptr %v_coe_3518_15_4_23_3971_pointer_601.repack29, align 8, !noalias !0
  %returnAddress_pointer_602 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %sharer_pointer_603 = getelementptr i8, ptr %common.ret.op.i, i64 88
  %eraser_pointer_604 = getelementptr i8, ptr %common.ret.op.i, i64 96
  store ptr @returnAddress_517, ptr %returnAddress_pointer_602, align 8, !noalias !0
  store ptr @sharer_577, ptr %sharer_pointer_603, align 8, !noalias !0
  store ptr @eraser_589, ptr %eraser_pointer_604, align 8, !noalias !0
  br i1 %isNull.i.i38, label %sharePositive.exit.i, label %next.i.i9.i

next.i.i9.i:                                      ; preds = %stackAllocate.exit
  %referenceCount.i.i10.i = load i64, ptr %v_coe_3524_5_3909.unpack13, align 4
  %referenceCount.1.i.i11.i = add i64 %referenceCount.i.i10.i, 1
  store i64 %referenceCount.1.i.i11.i, ptr %v_coe_3524_5_3909.unpack13, align 4
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i9.i, %stackAllocate.exit
  %referenceCount.i.i.i = load i64, ptr %ys_2440.unpack10, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %ys_2440.unpack10, align 4
  %currentStackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 72
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %sharePositive.exit.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %currentStackPointer.i.i to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 72
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 72
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %sharePositive.exit.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %sharePositive.exit.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %sharePositive.exit.i ]
  %2 = insertvalue %Pos poison, i64 %v_coe_3524_5_3909.unpack, 0
  %v_coe_3524_5_390914 = insertvalue %Pos %2, ptr %v_coe_3524_5_3909.unpack13, 1
  %ys_244011 = insertvalue %Pos { i64 1, ptr poison }, ptr %ys_2440.unpack10, 1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %zs_2441.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_625.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %zs_2441.unpack4, ptr %stackPointer_625.repack1.i, align 8, !noalias !0
  %xs_2439_pointer_627.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %v_coe_3524_5_3909.unpack, ptr %xs_2439_pointer_627.i, align 8, !noalias !0
  %xs_2439_pointer_627.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %v_coe_3524_5_3909.unpack13, ptr %xs_2439_pointer_627.repack3.i, align 8, !noalias !0
  %ys_2440_pointer_628.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 1, ptr %ys_2440_pointer_628.i, align 8, !noalias !0
  %ys_2440_pointer_628.repack5.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %ys_2440.unpack10, ptr %ys_2440_pointer_628.repack5.i, align 8, !noalias !0
  %returnAddress_pointer_629.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %sharer_pointer_630.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  %eraser_pointer_631.i = getelementptr i8, ptr %common.ret.op.i.i, i64 64
  store ptr @returnAddress_478, ptr %returnAddress_pointer_629.i, align 8, !noalias !0
  store ptr @sharer_612, ptr %sharer_pointer_630.i, align 8, !noalias !0
  store ptr @eraser_620, ptr %eraser_pointer_631.i, align 8, !noalias !0
  musttail call tailcc void @isShorterThan_2436(%Pos %ys_244011, %Pos %v_coe_3524_5_390914, ptr nonnull %stack)
  ret void

label_606:                                        ; preds = %sharePositive.exit37
  %environment.i31 = getelementptr i8, ptr %ys_2440.unpack10, i64 16
  %v_coe_3521_10_4_3968_pointer_507 = getelementptr i8, ptr %ys_2440.unpack10, i64 32
  %v_coe_3521_10_4_3968.unpack = load i64, ptr %v_coe_3521_10_4_3968_pointer_507, align 8, !noalias !0
  %v_coe_3521_10_4_3968.elt15 = getelementptr i8, ptr %ys_2440.unpack10, i64 40
  %v_coe_3521_10_4_3968.unpack16 = load ptr, ptr %v_coe_3521_10_4_3968.elt15, align 8, !noalias !0
  %isNull.i.i48 = icmp eq ptr %v_coe_3521_10_4_3968.unpack16, null
  br i1 %isNull.i.i48, label %next.i69, label %next.i.i49

next.i.i49:                                       ; preds = %label_606
  %referenceCount.i.i50 = load i64, ptr %v_coe_3521_10_4_3968.unpack16, align 4
  %referenceCount.1.i.i51 = add i64 %referenceCount.i.i50, 1
  store i64 %referenceCount.1.i.i51, ptr %v_coe_3521_10_4_3968.unpack16, align 4
  br label %next.i69

next.i69:                                         ; preds = %next.i.i49, %label_606
  %referenceCount.i70 = load i64, ptr %ys_2440.unpack10, align 4
  %cond.i71 = icmp eq i64 %referenceCount.i70, 0
  br i1 %cond.i71, label %free.i74, label %decr.i72

decr.i72:                                         ; preds = %next.i69
  %referenceCount.1.i73 = add i64 %referenceCount.i70, -1
  store i64 %referenceCount.1.i73, ptr %ys_2440.unpack10, align 4
  br label %eraseObject.exit78

free.i74:                                         ; preds = %next.i69
  %objectEraser.i75 = getelementptr i8, ptr %ys_2440.unpack10, i64 8
  %eraser.i76 = load ptr, ptr %objectEraser.i75, align 8
  tail call void %eraser.i76(ptr %environment.i31)
  tail call void @free(ptr nonnull %ys_2440.unpack10)
  br label %eraseObject.exit78

eraseObject.exit78:                               ; preds = %decr.i72, %free.i74
  %isNull.i.i43 = icmp eq ptr %zs_2441.unpack4, null
  br i1 %isNull.i.i43, label %sharePositive.exit47, label %sharePositive.exit47.thread

sharePositive.exit47:                             ; preds = %eraseObject.exit78
  %cond2 = icmp eq i64 %zs_2441.unpack, 1
  br i1 %cond2, label %label_605, label %erasePositive.exit148

sharePositive.exit47.thread:                      ; preds = %eraseObject.exit78
  %referenceCount.i.i45 = load i64, ptr %zs_2441.unpack4, align 4
  %referenceCount.1.i.i46 = add i64 %referenceCount.i.i45, 1
  store i64 %referenceCount.1.i.i46, ptr %zs_2441.unpack4, align 4
  %cond2303 = icmp eq i64 %zs_2441.unpack, 1
  br i1 %cond2303, label %label_605, label %next.i.i139

label_607:                                        ; preds = %sharePositive.exit
  %environment.i = getelementptr i8, ptr %xs_2439.unpack7, i64 16
  %v_coe_3524_5_3909_pointer_498 = getelementptr i8, ptr %xs_2439.unpack7, i64 32
  %v_coe_3524_5_3909.unpack = load i64, ptr %v_coe_3524_5_3909_pointer_498, align 8, !noalias !0
  %v_coe_3524_5_3909.elt12 = getelementptr i8, ptr %xs_2439.unpack7, i64 40
  %v_coe_3524_5_3909.unpack13 = load ptr, ptr %v_coe_3524_5_3909.elt12, align 8, !noalias !0
  %isNull.i.i38 = icmp eq ptr %v_coe_3524_5_3909.unpack13, null
  br i1 %isNull.i.i38, label %next.i, label %next.i.i39

next.i.i39:                                       ; preds = %label_607
  %referenceCount.i.i40 = load i64, ptr %v_coe_3524_5_3909.unpack13, align 4
  %referenceCount.1.i.i41 = add i64 %referenceCount.i.i40, 1
  store i64 %referenceCount.1.i.i41, ptr %v_coe_3524_5_3909.unpack13, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i39, %label_607
  %referenceCount.i = load i64, ptr %xs_2439.unpack7, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %xs_2439.unpack7, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %xs_2439.unpack7, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr %environment.i)
  tail call void @free(ptr nonnull %xs_2439.unpack7)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %isNull.i.i33 = icmp eq ptr %ys_2440.unpack10, null
  br i1 %isNull.i.i33, label %sharePositive.exit37, label %next.i.i34

next.i.i34:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i35 = load i64, ptr %ys_2440.unpack10, align 4
  %referenceCount.1.i.i36 = add i64 %referenceCount.i.i35, 1
  store i64 %referenceCount.1.i.i36, ptr %ys_2440.unpack10, align 4
  br label %sharePositive.exit37

sharePositive.exit37:                             ; preds = %eraseObject.exit, %next.i.i34
  %cond1 = icmp eq i64 %ys_2440.unpack, 1
  br i1 %cond1, label %label_606, label %label_504

label_608:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %xs_2439.unpack7, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %label_608
  %referenceCount.i.i = load i64, ptr %xs_2439.unpack7, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %xs_2439.unpack7, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %label_608, %next.i.i
  %cond = icmp eq i64 %xs_2439.unpack, 1
  br i1 %cond, label %label_607, label %label_495
}

define void @sharer_612(ptr %stackPointer) {
entry:
  %zs_2441_609.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %zs_2441_609.unpack2 = load ptr, ptr %zs_2441_609.elt1, align 8, !noalias !0
  %xs_2439_610.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %xs_2439_610.unpack5 = load ptr, ptr %xs_2439_610.elt4, align 8, !noalias !0
  %ys_2440_611.elt7 = getelementptr i8, ptr %stackPointer, i64 -8
  %ys_2440_611.unpack8 = load ptr, ptr %ys_2440_611.elt7, align 8, !noalias !0
  %isNull.i.i15 = icmp eq ptr %zs_2441_609.unpack2, null
  br i1 %isNull.i.i15, label %sharePositive.exit19, label %next.i.i16

next.i.i16:                                       ; preds = %entry
  %referenceCount.i.i17 = load i64, ptr %zs_2441_609.unpack2, align 4
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i17, 1
  store i64 %referenceCount.1.i.i18, ptr %zs_2441_609.unpack2, align 4
  br label %sharePositive.exit19

sharePositive.exit19:                             ; preds = %entry, %next.i.i16
  %isNull.i.i10 = icmp eq ptr %xs_2439_610.unpack5, null
  br i1 %isNull.i.i10, label %sharePositive.exit14, label %next.i.i11

next.i.i11:                                       ; preds = %sharePositive.exit19
  %referenceCount.i.i12 = load i64, ptr %xs_2439_610.unpack5, align 4
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i12, 1
  store i64 %referenceCount.1.i.i13, ptr %xs_2439_610.unpack5, align 4
  br label %sharePositive.exit14

sharePositive.exit14:                             ; preds = %sharePositive.exit19, %next.i.i11
  %isNull.i.i = icmp eq ptr %ys_2440_611.unpack8, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit14
  %referenceCount.i.i = load i64, ptr %ys_2440_611.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %ys_2440_611.unpack8, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit14, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_620(ptr %stackPointer) {
entry:
  %zs_2441_617.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %zs_2441_617.unpack2 = load ptr, ptr %zs_2441_617.elt1, align 8, !noalias !0
  %xs_2439_618.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %xs_2439_618.unpack5 = load ptr, ptr %xs_2439_618.elt4, align 8, !noalias !0
  %ys_2440_619.elt7 = getelementptr i8, ptr %stackPointer, i64 -8
  %ys_2440_619.unpack8 = load ptr, ptr %ys_2440_619.elt7, align 8, !noalias !0
  %isNull.i.i21 = icmp eq ptr %zs_2441_617.unpack2, null
  br i1 %isNull.i.i21, label %erasePositive.exit31, label %next.i.i22

next.i.i22:                                       ; preds = %entry
  %referenceCount.i.i23 = load i64, ptr %zs_2441_617.unpack2, align 4
  %cond.i.i24 = icmp eq i64 %referenceCount.i.i23, 0
  br i1 %cond.i.i24, label %free.i.i27, label %decr.i.i25

decr.i.i25:                                       ; preds = %next.i.i22
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i23, -1
  store i64 %referenceCount.1.i.i26, ptr %zs_2441_617.unpack2, align 4
  br label %erasePositive.exit31

free.i.i27:                                       ; preds = %next.i.i22
  %objectEraser.i.i28 = getelementptr i8, ptr %zs_2441_617.unpack2, i64 8
  %eraser.i.i29 = load ptr, ptr %objectEraser.i.i28, align 8
  %environment.i.i.i30 = getelementptr i8, ptr %zs_2441_617.unpack2, i64 16
  tail call void %eraser.i.i29(ptr %environment.i.i.i30)
  tail call void @free(ptr nonnull %zs_2441_617.unpack2)
  br label %erasePositive.exit31

erasePositive.exit31:                             ; preds = %entry, %decr.i.i25, %free.i.i27
  %isNull.i.i10 = icmp eq ptr %xs_2439_618.unpack5, null
  br i1 %isNull.i.i10, label %erasePositive.exit20, label %next.i.i11

next.i.i11:                                       ; preds = %erasePositive.exit31
  %referenceCount.i.i12 = load i64, ptr %xs_2439_618.unpack5, align 4
  %cond.i.i13 = icmp eq i64 %referenceCount.i.i12, 0
  br i1 %cond.i.i13, label %free.i.i16, label %decr.i.i14

decr.i.i14:                                       ; preds = %next.i.i11
  %referenceCount.1.i.i15 = add i64 %referenceCount.i.i12, -1
  store i64 %referenceCount.1.i.i15, ptr %xs_2439_618.unpack5, align 4
  br label %erasePositive.exit20

free.i.i16:                                       ; preds = %next.i.i11
  %objectEraser.i.i17 = getelementptr i8, ptr %xs_2439_618.unpack5, i64 8
  %eraser.i.i18 = load ptr, ptr %objectEraser.i.i17, align 8
  %environment.i.i.i19 = getelementptr i8, ptr %xs_2439_618.unpack5, i64 16
  tail call void %eraser.i.i18(ptr %environment.i.i.i19)
  tail call void @free(ptr nonnull %xs_2439_618.unpack5)
  br label %erasePositive.exit20

erasePositive.exit20:                             ; preds = %erasePositive.exit31, %decr.i.i14, %free.i.i16
  %isNull.i.i = icmp eq ptr %ys_2440_619.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit20
  %referenceCount.i.i = load i64, ptr %ys_2440_619.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %ys_2440_619.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %ys_2440_619.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %ys_2440_619.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %ys_2440_619.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit20, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @tail_2442(%Pos %xs_2439, %Pos %ys_2440, %Pos %zs_2441, ptr %stack) local_unnamed_addr {
entry:
  %object.i7 = extractvalue %Pos %xs_2439, 1
  %isNull.i.i8 = icmp eq ptr %object.i7, null
  br i1 %isNull.i.i8, label %sharePositive.exit12, label %next.i.i9

next.i.i9:                                        ; preds = %entry
  %referenceCount.i.i10 = load i64, ptr %object.i7, align 4
  %referenceCount.1.i.i11 = add i64 %referenceCount.i.i10, 1
  store i64 %referenceCount.1.i.i11, ptr %object.i7, align 4
  br label %sharePositive.exit12

sharePositive.exit12:                             ; preds = %entry, %next.i.i9
  %object.i = extractvalue %Pos %ys_2440, 1
  %isNull.i.i = icmp eq ptr %object.i, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit12
  %referenceCount.i.i = load i64, ptr %object.i, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit12, %next.i.i
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
  %zs_2441.elt = extractvalue %Pos %zs_2441, 0
  store i64 %zs_2441.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_625.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %zs_2441.elt2 = extractvalue %Pos %zs_2441, 1
  store ptr %zs_2441.elt2, ptr %stackPointer_625.repack1, align 8, !noalias !0
  %xs_2439_pointer_627 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %xs_2439.elt = extractvalue %Pos %xs_2439, 0
  store i64 %xs_2439.elt, ptr %xs_2439_pointer_627, align 8, !noalias !0
  %xs_2439_pointer_627.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i7, ptr %xs_2439_pointer_627.repack3, align 8, !noalias !0
  %ys_2440_pointer_628 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %ys_2440.elt = extractvalue %Pos %ys_2440, 0
  store i64 %ys_2440.elt, ptr %ys_2440_pointer_628, align 8, !noalias !0
  %ys_2440_pointer_628.repack5 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %object.i, ptr %ys_2440_pointer_628.repack5, align 8, !noalias !0
  %returnAddress_pointer_629 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_630 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_631 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_478, ptr %returnAddress_pointer_629, align 8, !noalias !0
  store ptr @sharer_612, ptr %sharer_pointer_630, align 8, !noalias !0
  store ptr @eraser_620, ptr %eraser_pointer_631, align 8, !noalias !0
  musttail call tailcc void @isShorterThan_2436(%Pos %ys_2440, %Pos %xs_2439, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_635(%Pos %v_r_2546_3602, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i9 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i9)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %n_2437 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_213, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %n_2437, ptr %environment.i, align 8, !noalias !0
  %environment_639.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_639.repack1, align 8, !noalias !0
  %v_r_2546_3602_pointer_643 = getelementptr i8, ptr %object.i, i64 32
  %v_r_2546_3602.elt = extractvalue %Pos %v_r_2546_3602, 0
  store i64 %v_r_2546_3602.elt, ptr %v_r_2546_3602_pointer_643, align 8, !noalias !0
  %v_r_2546_3602_pointer_643.repack3 = getelementptr i8, ptr %object.i, i64 40
  %v_r_2546_3602.elt4 = extractvalue %Pos %v_r_2546_3602, 1
  store ptr %v_r_2546_3602.elt4, ptr %v_r_2546_3602_pointer_643.repack3, align 8, !noalias !0
  %make_4855 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i14 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i14)
  %newStackPointer.i15 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %newStackPointer.i15, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_645 = load ptr, ptr %newStackPointer.i15, align 8, !noalias !0
  musttail call tailcc void %returnAddress_645(%Pos %make_4855, ptr %stack)
  ret void
}

define void @sharer_649(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_653(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @makeList_2438(i64 %n_2437, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp eq i64 %n_2437, 0
  %stackPointer_pointer.i2.phi.trans.insert = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i6, label %entry.label_666_crit_edge, label %label_661.lr.ph

entry.label_666_crit_edge:                        ; preds = %entry
  %stackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8, !alias.scope !0
  %limit_pointer.i3.phi.trans.insert = getelementptr i8, ptr %stack, i64 24
  %limit.i4.pre = load ptr, ptr %limit_pointer.i3.phi.trans.insert, align 8, !alias.scope !0
  br label %label_666

label_661.lr.ph:                                  ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %currentStackPointer.i.pre = load ptr, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8, !alias.scope !0
  %limit.i.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %label_661

label_661:                                        ; preds = %label_661.lr.ph, %stackAllocate.exit
  %limit.i = phi ptr [ %limit.i.pre, %label_661.lr.ph ], [ %limit.i9, %stackAllocate.exit ]
  %currentStackPointer.i = phi ptr [ %currentStackPointer.i.pre, %label_661.lr.ph ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %n_2437.tr7 = phi i64 [ %n_2437, %label_661.lr.ph ], [ %z.i1, %stackAllocate.exit ]
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_661
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

stackAllocate.exit:                               ; preds = %label_661, %realloc.i
  %limit.i9 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_661 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_661 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_661 ]
  %z.i1 = add i64 %n_2437.tr7, -1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i2.phi.trans.insert, align 8
  store i64 %n_2437.tr7, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_658 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_659 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_660 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_635, ptr %returnAddress_pointer_658, align 8, !noalias !0
  store ptr @sharer_649, ptr %sharer_pointer_659, align 8, !noalias !0
  store ptr @eraser_653, ptr %eraser_pointer_660, align 8, !noalias !0
  %z.i = icmp eq i64 %z.i1, 0
  br i1 %z.i, label %label_666, label %label_661

label_666:                                        ; preds = %stackAllocate.exit, %entry.label_666_crit_edge
  %limit.i4 = phi ptr [ %limit.i4.pre, %entry.label_666_crit_edge ], [ %limit.i9, %stackAllocate.exit ]
  %stackPointer.i = phi ptr [ %stackPointer.i.pre, %entry.label_666_crit_edge ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %stackPointer_pointer.i2 = getelementptr i8, ptr %stack, i64 8
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i5 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i5, ptr %stackPointer_pointer.i2, align 8, !alias.scope !0
  %returnAddress_663 = load ptr, ptr %newStackPointer.i5, align 8, !noalias !0
  musttail call tailcc void %returnAddress_663(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @isShorterThan_2436(%Pos %x_2434, %Pos %y_2435, ptr %stack) local_unnamed_addr {
entry:
  br label %tailrecurse

tailrecurse:                                      ; preds = %eraseObject.exit23, %entry
  %x_2434.tr = phi %Pos [ %x_2434, %entry ], [ %v_coe_3512_9_4_38976, %eraseObject.exit23 ]
  %y_2435.tr = phi %Pos [ %y_2435, %entry ], [ %v_coe_3515_4_38793, %eraseObject.exit23 ]
  %tag_667 = extractvalue %Pos %y_2435.tr, 0
  switch i64 %tag_667, label %label_677 [
    i64 0, label %label_682
    i64 1, label %label_698
  ]

common.ret:                                       ; preds = %eraseObject.exit, %erasePositive.exit50
  ret void

label_676:                                        ; preds = %erasePositive.exit50
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_673 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_673(%Pos { i64 1, ptr null }, ptr %stack)
  ret void

label_677:                                        ; preds = %tailrecurse
  %object.i39 = extractvalue %Pos %y_2435.tr, 1
  %isNull.i.i40 = icmp eq ptr %object.i39, null
  br i1 %isNull.i.i40, label %erasePositive.exit50, label %next.i.i41

next.i.i41:                                       ; preds = %label_677
  %referenceCount.i.i42 = load i64, ptr %object.i39, align 4
  %cond.i.i43 = icmp eq i64 %referenceCount.i.i42, 0
  br i1 %cond.i.i43, label %free.i.i46, label %decr.i.i44

decr.i.i44:                                       ; preds = %next.i.i41
  %referenceCount.1.i.i45 = add i64 %referenceCount.i.i42, -1
  store i64 %referenceCount.1.i.i45, ptr %object.i39, align 4
  br label %erasePositive.exit50

free.i.i46:                                       ; preds = %next.i.i41
  %objectEraser.i.i47 = getelementptr i8, ptr %object.i39, i64 8
  %eraser.i.i48 = load ptr, ptr %objectEraser.i.i47, align 8
  %environment.i.i.i49 = getelementptr i8, ptr %object.i39, i64 16
  tail call void %eraser.i.i48(ptr %environment.i.i.i49)
  tail call void @free(ptr nonnull %object.i39)
  br label %erasePositive.exit50

erasePositive.exit50:                             ; preds = %label_677, %decr.i.i44, %free.i.i46
  %tag_669 = extractvalue %Pos %x_2434.tr, 0
  %cond = icmp eq i64 %tag_669, 0
  br i1 %cond, label %label_676, label %common.ret

label_682:                                        ; preds = %tailrecurse
  %object.i = extractvalue %Pos %x_2434.tr, 1
  %isNull.i.i28 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i28, label %erasePositive.exit38, label %next.i.i29

next.i.i29:                                       ; preds = %label_682
  %referenceCount.i.i30 = load i64, ptr %object.i, align 4
  %cond.i.i31 = icmp eq i64 %referenceCount.i.i30, 0
  br i1 %cond.i.i31, label %free.i.i34, label %decr.i.i32

decr.i.i32:                                       ; preds = %next.i.i29
  %referenceCount.1.i.i33 = add i64 %referenceCount.i.i30, -1
  store i64 %referenceCount.1.i.i33, ptr %object.i, align 4
  br label %erasePositive.exit38

free.i.i34:                                       ; preds = %next.i.i29
  %objectEraser.i.i35 = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i36 = load ptr, ptr %objectEraser.i.i35, align 8
  %environment.i.i.i37 = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i36(ptr %environment.i.i.i37)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit38

erasePositive.exit38:                             ; preds = %label_682, %decr.i.i32, %free.i.i34
  %stackPointer_pointer.i51 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i52 = load ptr, ptr %stackPointer_pointer.i51, align 8, !alias.scope !0
  %limit_pointer.i53 = getelementptr i8, ptr %stack, i64 24
  %limit.i54 = load ptr, ptr %limit_pointer.i53, align 8, !alias.scope !0
  %isInside.i55 = icmp ule ptr %stackPointer.i52, %limit.i54
  tail call void @llvm.assume(i1 %isInside.i55)
  %newStackPointer.i56 = getelementptr i8, ptr %stackPointer.i52, i64 -24
  store ptr %newStackPointer.i56, ptr %stackPointer_pointer.i51, align 8, !alias.scope !0
  %returnAddress_679 = load ptr, ptr %newStackPointer.i56, align 8, !noalias !0
  musttail call tailcc void %returnAddress_679(%Pos zeroinitializer, ptr %stack)
  ret void

label_693:                                        ; preds = %eraseObject.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i25

next.i.i25:                                       ; preds = %label_693
  %referenceCount.i.i26 = load i64, ptr %v_coe_3515_4_3879.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i25
  %referenceCount.1.i.i27 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i27, ptr %v_coe_3515_4_3879.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i25
  %objectEraser.i.i = getelementptr i8, ptr %v_coe_3515_4_3879.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_coe_3515_4_3879.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_coe_3515_4_3879.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_693, %decr.i.i, %free.i.i
  %stackPointer_pointer.i57 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i58 = load ptr, ptr %stackPointer_pointer.i57, align 8, !alias.scope !0
  %limit_pointer.i59 = getelementptr i8, ptr %stack, i64 24
  %limit.i60 = load ptr, ptr %limit_pointer.i59, align 8, !alias.scope !0
  %isInside.i61 = icmp ule ptr %stackPointer.i58, %limit.i60
  tail call void @llvm.assume(i1 %isInside.i61)
  %newStackPointer.i62 = getelementptr i8, ptr %stackPointer.i58, i64 -24
  store ptr %newStackPointer.i62, ptr %stackPointer_pointer.i57, align 8, !alias.scope !0
  %returnAddress_690 = load ptr, ptr %newStackPointer.i62, align 8, !noalias !0
  musttail call tailcc void %returnAddress_690(%Pos { i64 1, ptr null }, ptr %stack)
  ret void

label_697:                                        ; preds = %eraseObject.exit
  %fields_687 = extractvalue %Pos %x_2434.tr, 1
  %environment.i7 = getelementptr i8, ptr %fields_687, i64 16
  %v_coe_3512_9_4_3897_pointer_696 = getelementptr i8, ptr %fields_687, i64 32
  %v_coe_3512_9_4_3897.unpack = load i64, ptr %v_coe_3512_9_4_3897_pointer_696, align 8, !noalias !0
  %v_coe_3512_9_4_3897.elt4 = getelementptr i8, ptr %fields_687, i64 40
  %v_coe_3512_9_4_3897.unpack5 = load ptr, ptr %v_coe_3512_9_4_3897.elt4, align 8, !noalias !0
  %isNull.i.i8 = icmp eq ptr %v_coe_3512_9_4_3897.unpack5, null
  br i1 %isNull.i.i8, label %next.i14, label %next.i.i9

next.i.i9:                                        ; preds = %label_697
  %referenceCount.i.i10 = load i64, ptr %v_coe_3512_9_4_3897.unpack5, align 4
  %referenceCount.1.i.i11 = add i64 %referenceCount.i.i10, 1
  store i64 %referenceCount.1.i.i11, ptr %v_coe_3512_9_4_3897.unpack5, align 4
  br label %next.i14

next.i14:                                         ; preds = %next.i.i9, %label_697
  %referenceCount.i15 = load i64, ptr %fields_687, align 4
  %cond.i16 = icmp eq i64 %referenceCount.i15, 0
  br i1 %cond.i16, label %free.i19, label %decr.i17

decr.i17:                                         ; preds = %next.i14
  %referenceCount.1.i18 = add i64 %referenceCount.i15, -1
  store i64 %referenceCount.1.i18, ptr %fields_687, align 4
  br label %eraseObject.exit23

free.i19:                                         ; preds = %next.i14
  %objectEraser.i20 = getelementptr i8, ptr %fields_687, i64 8
  %eraser.i21 = load ptr, ptr %objectEraser.i20, align 8
  tail call void %eraser.i21(ptr %environment.i7)
  tail call void @free(ptr nonnull %fields_687)
  br label %eraseObject.exit23

eraseObject.exit23:                               ; preds = %decr.i17, %free.i19
  %0 = insertvalue %Pos poison, i64 %v_coe_3512_9_4_3897.unpack, 0
  %v_coe_3512_9_4_38976 = insertvalue %Pos %0, ptr %v_coe_3512_9_4_3897.unpack5, 1
  %1 = insertvalue %Pos poison, i64 %v_coe_3515_4_3879.unpack, 0
  %v_coe_3515_4_38793 = insertvalue %Pos %1, ptr %v_coe_3515_4_3879.unpack2, 1
  br label %tailrecurse

label_698:                                        ; preds = %tailrecurse
  %fields_668 = extractvalue %Pos %y_2435.tr, 1
  %environment.i = getelementptr i8, ptr %fields_668, i64 16
  %v_coe_3515_4_3879_pointer_685 = getelementptr i8, ptr %fields_668, i64 32
  %v_coe_3515_4_3879.unpack = load i64, ptr %v_coe_3515_4_3879_pointer_685, align 8, !noalias !0
  %v_coe_3515_4_3879.elt1 = getelementptr i8, ptr %fields_668, i64 40
  %v_coe_3515_4_3879.unpack2 = load ptr, ptr %v_coe_3515_4_3879.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3515_4_3879.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_698
  %referenceCount.i.i = load i64, ptr %v_coe_3515_4_3879.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3515_4_3879.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_698
  %referenceCount.i = load i64, ptr %fields_668, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_668, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_668, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr %environment.i)
  tail call void @free(ptr nonnull %fields_668)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %tag_686 = extractvalue %Pos %x_2434.tr, 0
  switch i64 %tag_686, label %common.ret [
    i64 0, label %label_693
    i64 1, label %label_697
  ]
}

define tailcc void @returnAddress_709(i64 %v_r_2521_3_3_3874, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = add i64 %v_r_2521_3_3_3874, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_710 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_710(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @length_2433(%Pos %xs_2432, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i4 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i5 = getelementptr i8, ptr %stack, i64 24
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  br label %tailrecurse

tailrecurse:                                      ; preds = %stackAllocate.exit, %entry
  %xs_2432.tr = phi %Pos [ %xs_2432, %entry ], [ %v_coe_3509_36443, %stackAllocate.exit ]
  %tag_699 = extractvalue %Pos %xs_2432.tr, 0
  switch i64 %tag_699, label %label_701 [
    i64 0, label %label_705
    i64 1, label %label_717
  ]

label_701:                                        ; preds = %tailrecurse
  ret void

label_705:                                        ; preds = %tailrecurse
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i4, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i5, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i4, align 8, !alias.scope !0
  %returnAddress_702 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_702(i64 0, ptr %stack)
  ret void

label_717:                                        ; preds = %tailrecurse
  %fields_700 = extractvalue %Pos %xs_2432.tr, 1
  %environment.i = getelementptr i8, ptr %fields_700, i64 16
  %v_coe_3509_3644_pointer_708 = getelementptr i8, ptr %fields_700, i64 32
  %v_coe_3509_3644.unpack = load i64, ptr %v_coe_3509_3644_pointer_708, align 8, !noalias !0
  %v_coe_3509_3644.elt1 = getelementptr i8, ptr %fields_700, i64 40
  %v_coe_3509_3644.unpack2 = load ptr, ptr %v_coe_3509_3644.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3509_3644.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_717
  %referenceCount.i.i = load i64, ptr %v_coe_3509_3644.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3509_3644.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_717
  %referenceCount.i = load i64, ptr %fields_700, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_700, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_700, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr %environment.i)
  tail call void @free(ptr nonnull %fields_700)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i4, align 8, !alias.scope !0
  %limit.i6 = load ptr, ptr %limit_pointer.i5, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 24
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i6
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %eraseObject.exit
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
  %newStackPointer.i7 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i7, i64 24
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i5, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %eraseObject.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %eraseObject.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i7, %realloc.i ], [ %currentStackPointer.i, %eraseObject.exit ]
  %0 = insertvalue %Pos poison, i64 %v_coe_3509_3644.unpack, 0
  %v_coe_3509_36443 = insertvalue %Pos %0, ptr %v_coe_3509_3644.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i4, align 8
  %sharer_pointer_715 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_716 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_709, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_137, ptr %sharer_pointer_715, align 8, !noalias !0
  store ptr @eraser_139, ptr %eraser_pointer_716, align 8, !noalias !0
  br label %tailrecurse
}

define tailcc void @returnAddress_718(%Pos %v_r_2753_3563, ptr %stack) {
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
  %index_2107_pointer_721 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_721, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_723 = extractvalue %Pos %v_r_2753_3563, 0
  switch i64 %tag_723, label %label_725 [
    i64 0, label %label_729
    i64 1, label %label_735
  ]

label_725:                                        ; preds = %entry
  ret void

label_729:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_729
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

eraseNegative.exit:                               ; preds = %label_729, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_726 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_726(i64 %x.i, ptr nonnull %stack)
  ret void

label_735:                                        ; preds = %entry
  %Exception_2362_pointer_722 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_722, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_4835 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_4835.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_4835, %Pos %z.i)
  %utf8StringLiteral_4837 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_4837.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_4837)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_4840 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_4840.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_4840)
  %functionPointer_734 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_734(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_739(ptr %stackPointer) {
entry:
  %str_2106_736.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_736.unpack2 = load ptr, ptr %str_2106_736.elt1, align 8, !noalias !0
  %Exception_2362_738.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_738.unpack5 = load ptr, ptr %Exception_2362_738.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_736.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_736.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_736.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_738.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_738.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_738.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_747(ptr %stackPointer) {
entry:
  %str_2106_744.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_744.unpack2 = load ptr, ptr %str_2106_744.elt1, align 8, !noalias !0
  %Exception_2362_746.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_746.unpack5 = load ptr, ptr %Exception_2362_746.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_744.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_744.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_744.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_744.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_744.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_744.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_746.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_746.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_746.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_746.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_746.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_746.unpack5)
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
  %stackPointer_752.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_752.repack1, align 8, !noalias !0
  %index_2107_pointer_754 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_754, align 4, !noalias !0
  %Exception_2362_pointer_755 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_755, align 8, !noalias !0
  %Exception_2362_pointer_755.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_755.repack3, align 8, !noalias !0
  %returnAddress_pointer_756 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_757 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_758 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_718, ptr %returnAddress_pointer_756, align 8, !noalias !0
  store ptr @sharer_739, ptr %sharer_pointer_757, align 8, !noalias !0
  store ptr @eraser_747, ptr %eraser_pointer_758, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_765, label %label_770

label_765:                                        ; preds = %stackAllocate.exit
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
  %returnAddress_762 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_762(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_770:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_770
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

erasePositive.exit:                               ; preds = %label_770, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_767 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_767(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
