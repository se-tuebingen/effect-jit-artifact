; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:multiple_handlers_2fd0b5eb-82d6-45a3-b136-35bd4bd08b21/main.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:multiple_handlers_2fd0b5eb-82d6-45a3-b136-35bd4bd08b21/main.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_508 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4479_clause_493]
@vtable_539 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4545_clause_531]
@utf8StringLiteral_5228.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_5114.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_5116.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_5119.lit = private constant [1 x i8] c"'"

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

define tailcc void @returnAddress_9(i64 %c_188_4863, ptr %stack) {
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
  %sqs_66_4920 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %s_127_4815_pointer_12 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %s_127_4815 = load i64, ptr %s_127_4815_pointer_12, align 4, !noalias !0
  %z.i = mul i64 %sqs_66_4920, 1009
  %z.i6 = mul i64 %s_127_4815, 103
  %z.i7 = add i64 %z.i, %c_188_4863
  %z.i8 = add i64 %z.i7, %z.i6
  %z.i9 = tail call %Pos @c_bytearray_show_Int(i64 %z.i8)
  tail call void @c_io_println_String(%Pos %z.i9)
  %stackPointer.i11 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i13 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i14 = icmp ule ptr %stackPointer.i11, %limit.i13
  tail call void @llvm.assume(i1 %isInside.i14)
  %newStackPointer.i15 = getelementptr i8, ptr %stackPointer.i11, i64 -24
  store ptr %newStackPointer.i15, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_13 = load ptr, ptr %newStackPointer.i15, align 8, !noalias !0
  musttail call tailcc void %returnAddress_13(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_18(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_24(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
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

define void @sharer_42(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_46(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_62(%Pos %__9_27_20_184_4970, ptr %stack) {
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
  %i_5_4_163_4852 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %res_4_138_4924_pointer_65 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %res_4_138_4924.unpack = load ptr, ptr %res_4_138_4924_pointer_65, align 8, !noalias !0
  %res_4_138_4924.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %res_4_138_4924.unpack2 = load i64, ptr %res_4_138_4924.elt1, align 8, !noalias !0
  %tmp_5107_pointer_66 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5107 = load i64, ptr %tmp_5107_pointer_66, align 4, !noalias !0
  %object.i = extractvalue %Pos %__9_27_20_184_4970, 1
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
  %z.i = add i64 %i_5_4_163_4852, 1
  %z.i.i = icmp sgt i64 %z.i, %tmp_5107
  %stackPointer.i10.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br i1 %z.i.i, label %label_119.i, label %label_114.i

label_114.i:                                      ; preds = %erasePositive.exit
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i10.i, i64 56
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i12.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_114.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %stackPointer.i10.i to i64
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_114.i
  %limit.i7.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i12.i, %label_114.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_114.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %stackPointer.i10.i, %label_114.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %z.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %res_4_138_4924_pointer_104.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store ptr %res_4_138_4924.unpack, ptr %res_4_138_4924_pointer_104.i, align 8, !noalias !0
  %res_4_138_4924_pointer_104.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %res_4_138_4924.unpack2, ptr %res_4_138_4924_pointer_104.repack1.i, align 8, !noalias !0
  %tmp_5107_pointer_105.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %tmp_5107, ptr %tmp_5107_pointer_105.i, align 4, !noalias !0
  %returnAddress_pointer_106.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  %sharer_pointer_107.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %eraser_pointer_108.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr @returnAddress_57, ptr %returnAddress_pointer_106.i, align 8, !noalias !0
  store ptr @sharer_70, ptr %sharer_pointer_107.i, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_108.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %res_4_138_4924.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i3.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i4.i = load ptr, ptr %base_pointer.i3.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i4.i, i64 %res_4_138_4924.unpack2
  %get_5144.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i7.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i8.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i8.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_111.i = load ptr, ptr %newStackPointer.i8.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_111.i(i64 %get_5144.i, ptr nonnull %stack)
  ret void

label_119.i:                                      ; preds = %erasePositive.exit
  %isInside.i13.i = icmp ule ptr %stackPointer.i10.i, %limit.i12.i
  tail call void @llvm.assume(i1 %isInside.i13.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %stackPointer.i10.i, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_116.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_116.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_70(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_78(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_57(i64 %v_r_2559_6_24_17_181_4839, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i10 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i10)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -32
  %tmp_5107_pointer_61 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5107 = load i64, ptr %tmp_5107_pointer_61, align 4, !noalias !0
  %res_4_138_4924.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %res_4_138_4924.unpack2 = load i64, ptr %res_4_138_4924.elt1, align 8, !noalias !0
  %res_4_138_4924_pointer_60 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %res_4_138_4924.unpack = load ptr, ptr %res_4_138_4924_pointer_60, align 8, !noalias !0
  %i_5_4_163_4852 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i = add i64 %v_r_2559_6_24_17_181_4839, 1
  %z.i11 = srem i64 %z.i, 1009
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_5_4_163_4852, ptr %newStackPointer.i, align 4, !noalias !0
  %res_4_138_4924_pointer_85 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %res_4_138_4924.unpack, ptr %res_4_138_4924_pointer_85, align 8, !noalias !0
  %res_4_138_4924_pointer_85.repack4 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store i64 %res_4_138_4924.unpack2, ptr %res_4_138_4924_pointer_85.repack4, align 8, !noalias !0
  %tmp_5107_pointer_86 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %tmp_5107, ptr %tmp_5107_pointer_86, align 4, !noalias !0
  %sharer_pointer_88 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_89 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_62, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_70, ptr %sharer_pointer_88, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_89, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_138_4924.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i16 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i17 = load ptr, ptr %base_pointer.i16, align 8
  %varPointer.i = getelementptr i8, ptr %base.i17, i64 %res_4_138_4924.unpack2
  store i64 %z.i11, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_93 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_93(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @go_4_3_162_4903(i64 %i_5_4_163_4852, %Reference %res_4_138_4924, i64 %tmp_5107, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp sgt i64 %i_5_4_163_4852, %tmp_5107
  %stackPointer_pointer.i9 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_119, label %label_114

label_114:                                        ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 56
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_114
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

stackAllocate.exit:                               ; preds = %label_114, %realloc.i
  %limit.i7 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_114 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_114 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_114 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i9, align 8
  store i64 %i_5_4_163_4852, ptr %common.ret.op.i, align 4, !noalias !0
  %res_4_138_4924_pointer_104 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %res_4_138_4924.elt = extractvalue %Reference %res_4_138_4924, 0
  store ptr %res_4_138_4924.elt, ptr %res_4_138_4924_pointer_104, align 8, !noalias !0
  %res_4_138_4924_pointer_104.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %res_4_138_4924.elt2 = extractvalue %Reference %res_4_138_4924, 1
  store i64 %res_4_138_4924.elt2, ptr %res_4_138_4924_pointer_104.repack1, align 8, !noalias !0
  %tmp_5107_pointer_105 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_5107, ptr %tmp_5107_pointer_105, align 4, !noalias !0
  %returnAddress_pointer_106 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_107 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_108 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_57, ptr %returnAddress_pointer_106, align 8, !noalias !0
  store ptr @sharer_70, ptr %sharer_pointer_107, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_108, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_138_4924.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i3 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i4 = load ptr, ptr %base_pointer.i3, align 8
  %varPointer.i = getelementptr i8, ptr %base.i4, i64 %res_4_138_4924.elt2
  %get_5144 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i = icmp ule ptr %nextStackPointer.sink.i, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i8 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i8, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %returnAddress_111 = load ptr, ptr %newStackPointer.i8, align 8, !noalias !0
  musttail call tailcc void %returnAddress_111(i64 %get_5144, ptr nonnull %stack)
  ret void

label_119:                                        ; preds = %entry
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %limit_pointer.i11 = getelementptr i8, ptr %stack, i64 24
  %limit.i12 = load ptr, ptr %limit_pointer.i11, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %returnAddress_116 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_116(%Pos zeroinitializer, ptr %stack)
  ret void
}

define tailcc void @returnAddress_120(%Pos %__28_187_4972, ptr %stack) {
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
  %res_4_138_4924.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %res_4_138_4924.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %res_4_138_4924.unpack2 = load i64, ptr %res_4_138_4924.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__28_187_4972, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_138_4924.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %res_4_138_4924.unpack2
  %get_5146 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_125 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_125(i64 %get_5146, ptr nonnull %stack)
  ret void
}

define void @sharer_129(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_133(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_5(i64 %s_127_4815, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i3 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i4 = load ptr, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i4, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i9 = icmp ule ptr %stackPointer.i4, %limit.i
  tail call void @llvm.assume(i1 %isInside.i9)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i4, i64 -16
  %tmp_5107_pointer_8 = getelementptr i8, ptr %stackPointer.i4, i64 -8
  %tmp_5107 = load i64, ptr %tmp_5107_pointer_8, align 4, !noalias !0
  %sqs_66_4920 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i3, align 8
  store i64 %sqs_66_4920, ptr %newStackPointer.i, align 4, !noalias !0
  %s_127_4815_pointer_30 = getelementptr i8, ptr %stackPointer.i4, i64 -8
  store i64 %s_127_4815, ptr %s_127_4815_pointer_30, align 4, !noalias !0
  %sharer_pointer_32 = getelementptr i8, ptr %stackPointer.i4, i64 8
  %eraser_pointer_33 = getelementptr i8, ptr %stackPointer.i4, i64 16
  store ptr @returnAddress_9, ptr %stackPointer.i4, align 8, !noalias !0
  store ptr @sharer_18, ptr %sharer_pointer_32, align 8, !noalias !0
  store ptr @eraser_24, ptr %eraser_pointer_33, align 8, !noalias !0
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i3, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i17 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i22 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i23 = icmp ugt ptr %nextStackPointer.i22, %limit.i
  br i1 %isInside.not.i23, label %realloc.i26, label %stackAllocate.exit40

realloc.i26:                                      ; preds = %stackAllocate.exit
  %nextSize.i32 = add i64 %offset.i, 32
  %leadingZeros.i.i33 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i32, i1 false)
  %numBits.i.i34 = sub nuw nsw i64 64, %leadingZeros.i.i33
  %result.i.i35 = shl nuw i64 1, %numBits.i.i34
  %newBase.i36 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i35)
  %newLimit.i37 = getelementptr i8, ptr %newBase.i36, i64 %result.i.i35
  %newStackPointer.i38 = getelementptr i8, ptr %newBase.i36, i64 %offset.i
  %newNextStackPointer.i39 = getelementptr i8, ptr %newStackPointer.i38, i64 32
  store ptr %newBase.i36, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i37, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit40

stackAllocate.exit40:                             ; preds = %stackAllocate.exit, %realloc.i26
  %base.i51 = phi ptr [ %newBase.i36, %realloc.i26 ], [ %base.i, %stackAllocate.exit ]
  %limit.i44 = phi ptr [ %newLimit.i37, %realloc.i26 ], [ %limit.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i24 = phi ptr [ %newNextStackPointer.i39, %realloc.i26 ], [ %nextStackPointer.i22, %stackAllocate.exit ]
  %common.ret.op.i25 = phi ptr [ %newStackPointer.i38, %realloc.i26 ], [ %stackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i24, ptr %stackPointer_pointer.i3, align 8
  store i64 0, ptr %common.ret.op.i25, align 4, !noalias !0
  %returnAddress_pointer_51 = getelementptr i8, ptr %common.ret.op.i25, i64 8
  %sharer_pointer_52 = getelementptr i8, ptr %common.ret.op.i25, i64 16
  %eraser_pointer_53 = getelementptr i8, ptr %common.ret.op.i25, i64 24
  store ptr @returnAddress_34, ptr %returnAddress_pointer_51, align 8, !noalias !0
  store ptr @sharer_42, ptr %sharer_pointer_52, align 8, !noalias !0
  store ptr @eraser_46, ptr %eraser_pointer_53, align 8, !noalias !0
  %nextStackPointer.i45 = getelementptr i8, ptr %nextStackPointer.sink.i24, i64 40
  %isInside.not.i46 = icmp ugt ptr %nextStackPointer.i45, %limit.i44
  br i1 %isInside.not.i46, label %realloc.i49, label %stackAllocate.exit63

realloc.i49:                                      ; preds = %stackAllocate.exit40
  %intStackPointer.i52 = ptrtoint ptr %nextStackPointer.sink.i24 to i64
  %intBase.i53 = ptrtoint ptr %base.i51 to i64
  %size.i54 = sub i64 %intStackPointer.i52, %intBase.i53
  %nextSize.i55 = add i64 %size.i54, 40
  %leadingZeros.i.i56 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i55, i1 false)
  %numBits.i.i57 = sub nuw nsw i64 64, %leadingZeros.i.i56
  %result.i.i58 = shl nuw i64 1, %numBits.i.i57
  %newBase.i59 = tail call ptr @realloc(ptr %base.i51, i64 %result.i.i58)
  %newLimit.i60 = getelementptr i8, ptr %newBase.i59, i64 %result.i.i58
  %newStackPointer.i61 = getelementptr i8, ptr %newBase.i59, i64 %size.i54
  %newNextStackPointer.i62 = getelementptr i8, ptr %newStackPointer.i61, i64 40
  store ptr %newBase.i59, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i60, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit63

stackAllocate.exit63:                             ; preds = %stackAllocate.exit40, %realloc.i49
  %base.i.i = phi ptr [ %newBase.i59, %realloc.i49 ], [ %base.i51, %stackAllocate.exit40 ]
  %limit.i12.i = phi ptr [ %newLimit.i60, %realloc.i49 ], [ %limit.i44, %stackAllocate.exit40 ]
  %nextStackPointer.sink.i47 = phi ptr [ %newNextStackPointer.i62, %realloc.i49 ], [ %nextStackPointer.i45, %stackAllocate.exit40 ]
  %common.ret.op.i48 = phi ptr [ %newStackPointer.i61, %realloc.i49 ], [ %nextStackPointer.sink.i24, %stackAllocate.exit40 ]
  store ptr %nextStackPointer.sink.i47, ptr %stackPointer_pointer.i3, align 8
  store ptr %prompt.i17, ptr %common.ret.op.i48, align 8, !noalias !0
  %stackPointer_136.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i48, i64 8
  store i64 %offset.i, ptr %stackPointer_136.repack1, align 8, !noalias !0
  %returnAddress_pointer_138 = getelementptr i8, ptr %common.ret.op.i48, i64 16
  %sharer_pointer_139 = getelementptr i8, ptr %common.ret.op.i48, i64 24
  %eraser_pointer_140 = getelementptr i8, ptr %common.ret.op.i48, i64 32
  store ptr @returnAddress_120, ptr %returnAddress_pointer_138, align 8, !noalias !0
  store ptr @sharer_129, ptr %sharer_pointer_139, align 8, !noalias !0
  store ptr @eraser_133, ptr %eraser_pointer_140, align 8, !noalias !0
  %z.i.i = icmp slt i64 %tmp_5107, 0
  br i1 %z.i.i, label %label_119.i, label %label_114.i

label_114.i:                                      ; preds = %stackAllocate.exit63
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i47, i64 56
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i12.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_114.i
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i47 to i64
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
  store ptr %newBase.i.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_114.i
  %limit.i7.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i12.i, %label_114.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_114.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i47, %label_114.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i3, align 8
  store i64 0, ptr %common.ret.op.i.i, align 4, !noalias !0
  %res_4_138_4924_pointer_104.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store ptr %prompt.i17, ptr %res_4_138_4924_pointer_104.i, align 8, !noalias !0
  %res_4_138_4924_pointer_104.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %offset.i, ptr %res_4_138_4924_pointer_104.repack1.i, align 8, !noalias !0
  %tmp_5107_pointer_105.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %tmp_5107, ptr %tmp_5107_pointer_105.i, align 4, !noalias !0
  %returnAddress_pointer_106.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  %sharer_pointer_107.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %eraser_pointer_108.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  store ptr @returnAddress_57, ptr %returnAddress_pointer_106.i, align 8, !noalias !0
  store ptr @sharer_70, ptr %sharer_pointer_107.i, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_108.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %prompt.i17, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i3.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i4.i = load ptr, ptr %base_pointer.i3.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i4.i, i64 %offset.i
  %get_5144.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i7.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i8.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i8.i, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %returnAddress_111.i = load ptr, ptr %newStackPointer.i8.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_111.i(i64 %get_5144.i, ptr nonnull %stack)
  ret void

label_119.i:                                      ; preds = %stackAllocate.exit63
  %isInside.i13.i = icmp ule ptr %nextStackPointer.sink.i47, %limit.i12.i
  tail call void @llvm.assume(i1 %isInside.i13.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %nextStackPointer.sink.i47, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %returnAddress_116.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_116.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_151(i64 %returnValue_152, ptr %stack) {
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
  %returnAddress_155 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_155(i64 %returnValue_152, ptr %stack)
  ret void
}

define tailcc void @returnAddress_174(%Pos %__9_27_20_123_4961, ptr %stack) {
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
  %i_5_4_102_4930 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %res_4_77_4904_pointer_177 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %res_4_77_4904.unpack = load ptr, ptr %res_4_77_4904_pointer_177, align 8, !noalias !0
  %res_4_77_4904.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %res_4_77_4904.unpack2 = load i64, ptr %res_4_77_4904.elt1, align 8, !noalias !0
  %tmp_5107_pointer_178 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5107 = load i64, ptr %tmp_5107_pointer_178, align 4, !noalias !0
  %object.i = extractvalue %Pos %__9_27_20_123_4961, 1
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
  %z.i = add i64 %i_5_4_102_4930, 1
  %z.i.i = icmp sgt i64 %z.i, %tmp_5107
  %stackPointer.i10.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br i1 %z.i.i, label %label_236.i, label %label_231.i

label_231.i:                                      ; preds = %erasePositive.exit
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i10.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i12.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_231.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %stackPointer.i10.i to i64
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_231.i
  %limit.i7.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i12.i, %label_231.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_231.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %stackPointer.i10.i, %label_231.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store i64 %z.i, ptr %common.ret.op.i.i, align 4, !noalias !0
  %res_4_77_4904_pointer_220.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store ptr %res_4_77_4904.unpack, ptr %res_4_77_4904_pointer_220.i, align 8, !noalias !0
  %res_4_77_4904_pointer_220.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %res_4_77_4904.unpack2, ptr %res_4_77_4904_pointer_220.repack1.i, align 8, !noalias !0
  %tmp_5090_pointer_221.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %z.i, ptr %tmp_5090_pointer_221.i, align 4, !noalias !0
  %tmp_5107_pointer_222.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %tmp_5107, ptr %tmp_5107_pointer_222.i, align 4, !noalias !0
  %returnAddress_pointer_223.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_224.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_225.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_168, ptr %returnAddress_pointer_223.i, align 8, !noalias !0
  store ptr @sharer_202, ptr %sharer_pointer_224.i, align 8, !noalias !0
  store ptr @eraser_212, ptr %eraser_pointer_225.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %res_4_77_4904.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i3.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i4.i = load ptr, ptr %base_pointer.i3.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i4.i, i64 %res_4_77_4904.unpack2
  %get_5158.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i7.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i8.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i8.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_228.i = load ptr, ptr %newStackPointer.i8.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_228.i(i64 %get_5158.i, ptr nonnull %stack)
  ret void

label_236.i:                                      ; preds = %erasePositive.exit
  %isInside.i13.i = icmp ule ptr %stackPointer.i10.i, %limit.i12.i
  tail call void @llvm.assume(i1 %isInside.i13.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %stackPointer.i10.i, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_233.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_233.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_168(i64 %v_r_2548_6_24_17_120_4900, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %i_5_4_102_4930 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %res_4_77_4904_pointer_171 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %res_4_77_4904.unpack = load ptr, ptr %res_4_77_4904_pointer_171, align 8, !noalias !0
  %res_4_77_4904.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %res_4_77_4904.unpack2 = load i64, ptr %res_4_77_4904.elt1, align 8, !noalias !0
  %tmp_5090_pointer_172 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5090 = load i64, ptr %tmp_5090_pointer_172, align 4, !noalias !0
  %tmp_5107_pointer_173 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5107 = load i64, ptr %tmp_5107_pointer_173, align 4, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
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
  %newStackPointer.i15 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i15, i64 56
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i21 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i15, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = add i64 %tmp_5090, %v_r_2548_6_24_17_120_4900
  %z.i11 = srem i64 %z.i, 1009
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_5_4_102_4930, ptr %common.ret.op.i, align 4, !noalias !0
  %res_4_77_4904_pointer_187 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %res_4_77_4904.unpack, ptr %res_4_77_4904_pointer_187, align 8, !noalias !0
  %res_4_77_4904_pointer_187.repack4 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %res_4_77_4904.unpack2, ptr %res_4_77_4904_pointer_187.repack4, align 8, !noalias !0
  %tmp_5107_pointer_188 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_5107, ptr %tmp_5107_pointer_188, align 4, !noalias !0
  %returnAddress_pointer_189 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_190 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_191 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_174, ptr %returnAddress_pointer_189, align 8, !noalias !0
  store ptr @sharer_70, ptr %sharer_pointer_190, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_191, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_77_4904.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i16 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i17 = load ptr, ptr %base_pointer.i16, align 8
  %varPointer.i = getelementptr i8, ptr %base.i17, i64 %res_4_77_4904.unpack2
  store i64 %z.i11, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i22 = icmp ule ptr %nextStackPointer.sink.i, %limit.i21
  tail call void @llvm.assume(i1 %isInside.i22)
  %newStackPointer.i23 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i23, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_195 = load ptr, ptr %newStackPointer.i23, align 8, !noalias !0
  musttail call tailcc void %returnAddress_195(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_202(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_212(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @go_4_3_101_4807(i64 %i_5_4_102_4930, %Reference %res_4_77_4904, i64 %tmp_5107, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp sgt i64 %i_5_4_102_4930, %tmp_5107
  %stackPointer_pointer.i9 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_236, label %label_231

label_231:                                        ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 64
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_231
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

stackAllocate.exit:                               ; preds = %label_231, %realloc.i
  %limit.i7 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_231 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_231 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_231 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i9, align 8
  store i64 %i_5_4_102_4930, ptr %common.ret.op.i, align 4, !noalias !0
  %res_4_77_4904_pointer_220 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %res_4_77_4904.elt = extractvalue %Reference %res_4_77_4904, 0
  store ptr %res_4_77_4904.elt, ptr %res_4_77_4904_pointer_220, align 8, !noalias !0
  %res_4_77_4904_pointer_220.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %res_4_77_4904.elt2 = extractvalue %Reference %res_4_77_4904, 1
  store i64 %res_4_77_4904.elt2, ptr %res_4_77_4904_pointer_220.repack1, align 8, !noalias !0
  %tmp_5090_pointer_221 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_5_4_102_4930, ptr %tmp_5090_pointer_221, align 4, !noalias !0
  %tmp_5107_pointer_222 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %tmp_5107, ptr %tmp_5107_pointer_222, align 4, !noalias !0
  %returnAddress_pointer_223 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_224 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_225 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_168, ptr %returnAddress_pointer_223, align 8, !noalias !0
  store ptr @sharer_202, ptr %sharer_pointer_224, align 8, !noalias !0
  store ptr @eraser_212, ptr %eraser_pointer_225, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_77_4904.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i3 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i4 = load ptr, ptr %base_pointer.i3, align 8
  %varPointer.i = getelementptr i8, ptr %base.i4, i64 %res_4_77_4904.elt2
  %get_5158 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i = icmp ule ptr %nextStackPointer.sink.i, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i8 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i8, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %returnAddress_228 = load ptr, ptr %newStackPointer.i8, align 8, !noalias !0
  musttail call tailcc void %returnAddress_228(i64 %get_5158, ptr nonnull %stack)
  ret void

label_236:                                        ; preds = %entry
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %limit_pointer.i11 = getelementptr i8, ptr %stack, i64 24
  %limit.i12 = load ptr, ptr %limit_pointer.i11, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %returnAddress_233 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_233(%Pos zeroinitializer, ptr %stack)
  ret void
}

define tailcc void @returnAddress_237(%Pos %__28_126_4963, ptr %stack) {
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
  %res_4_77_4904.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %res_4_77_4904.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %res_4_77_4904.unpack2 = load i64, ptr %res_4_77_4904.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__28_126_4963, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_77_4904.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %res_4_77_4904.unpack2
  %get_5160 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_242 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_242(i64 %get_5160, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_2(i64 %sqs_66_4920, ptr %stack) {
entry:
  %stackPointer_pointer.i3 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i4 = load ptr, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i4, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i9 = icmp ule ptr %stackPointer.i4, %limit.i
  tail call void @llvm.assume(i1 %isInside.i9)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i4, i64 -8
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %tmp_5107 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i4, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i13 = getelementptr i8, ptr %stack, i64 16
  %base.i14 = load ptr, ptr %base_pointer.i13, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i15 = ptrtoint ptr %base.i14 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i15
  %nextSize.i = add i64 %size.i, 40
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i14, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i16 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i16, i64 40
  store ptr %newBase.i, ptr %base_pointer.i13, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i21 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i16, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i3, align 8
  store i64 %sqs_66_4920, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5107_pointer_147 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5107, ptr %tmp_5107_pointer_147, align 4, !noalias !0
  %returnAddress_pointer_148 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_149 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_150 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_5, ptr %returnAddress_pointer_148, align 8, !noalias !0
  store ptr @sharer_18, ptr %sharer_pointer_149, align 8, !noalias !0
  store ptr @eraser_24, ptr %eraser_pointer_150, align 8, !noalias !0
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i3, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i17 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i22 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i23 = icmp ugt ptr %nextStackPointer.i22, %limit.i21
  br i1 %isInside.not.i23, label %realloc.i26, label %stackAllocate.exit40

realloc.i26:                                      ; preds = %stackAllocate.exit
  %nextSize.i32 = add i64 %offset.i, 32
  %leadingZeros.i.i33 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i32, i1 false)
  %numBits.i.i34 = sub nuw nsw i64 64, %leadingZeros.i.i33
  %result.i.i35 = shl nuw i64 1, %numBits.i.i34
  %newBase.i36 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i35)
  %newLimit.i37 = getelementptr i8, ptr %newBase.i36, i64 %result.i.i35
  %newStackPointer.i38 = getelementptr i8, ptr %newBase.i36, i64 %offset.i
  %newNextStackPointer.i39 = getelementptr i8, ptr %newStackPointer.i38, i64 32
  store ptr %newBase.i36, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i37, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit40

stackAllocate.exit40:                             ; preds = %stackAllocate.exit, %realloc.i26
  %base.i51 = phi ptr [ %newBase.i36, %realloc.i26 ], [ %base.i, %stackAllocate.exit ]
  %limit.i44 = phi ptr [ %newLimit.i37, %realloc.i26 ], [ %limit.i21, %stackAllocate.exit ]
  %nextStackPointer.sink.i24 = phi ptr [ %newNextStackPointer.i39, %realloc.i26 ], [ %nextStackPointer.i22, %stackAllocate.exit ]
  %common.ret.op.i25 = phi ptr [ %newStackPointer.i38, %realloc.i26 ], [ %stackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i24, ptr %stackPointer_pointer.i3, align 8
  store i64 0, ptr %common.ret.op.i25, align 4, !noalias !0
  %returnAddress_pointer_162 = getelementptr i8, ptr %common.ret.op.i25, i64 8
  %sharer_pointer_163 = getelementptr i8, ptr %common.ret.op.i25, i64 16
  %eraser_pointer_164 = getelementptr i8, ptr %common.ret.op.i25, i64 24
  store ptr @returnAddress_151, ptr %returnAddress_pointer_162, align 8, !noalias !0
  store ptr @sharer_42, ptr %sharer_pointer_163, align 8, !noalias !0
  store ptr @eraser_46, ptr %eraser_pointer_164, align 8, !noalias !0
  %nextStackPointer.i45 = getelementptr i8, ptr %nextStackPointer.sink.i24, i64 40
  %isInside.not.i46 = icmp ugt ptr %nextStackPointer.i45, %limit.i44
  br i1 %isInside.not.i46, label %realloc.i49, label %stackAllocate.exit63

realloc.i49:                                      ; preds = %stackAllocate.exit40
  %intStackPointer.i52 = ptrtoint ptr %nextStackPointer.sink.i24 to i64
  %intBase.i53 = ptrtoint ptr %base.i51 to i64
  %size.i54 = sub i64 %intStackPointer.i52, %intBase.i53
  %nextSize.i55 = add i64 %size.i54, 40
  %leadingZeros.i.i56 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i55, i1 false)
  %numBits.i.i57 = sub nuw nsw i64 64, %leadingZeros.i.i56
  %result.i.i58 = shl nuw i64 1, %numBits.i.i57
  %newBase.i59 = tail call ptr @realloc(ptr %base.i51, i64 %result.i.i58)
  %newLimit.i60 = getelementptr i8, ptr %newBase.i59, i64 %result.i.i58
  %newStackPointer.i61 = getelementptr i8, ptr %newBase.i59, i64 %size.i54
  %newNextStackPointer.i62 = getelementptr i8, ptr %newStackPointer.i61, i64 40
  store ptr %newBase.i59, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i60, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit63

stackAllocate.exit63:                             ; preds = %stackAllocate.exit40, %realloc.i49
  %base.i.i = phi ptr [ %newBase.i59, %realloc.i49 ], [ %base.i51, %stackAllocate.exit40 ]
  %limit.i12.i = phi ptr [ %newLimit.i60, %realloc.i49 ], [ %limit.i44, %stackAllocate.exit40 ]
  %nextStackPointer.sink.i47 = phi ptr [ %newNextStackPointer.i62, %realloc.i49 ], [ %nextStackPointer.i45, %stackAllocate.exit40 ]
  %common.ret.op.i48 = phi ptr [ %newStackPointer.i61, %realloc.i49 ], [ %nextStackPointer.sink.i24, %stackAllocate.exit40 ]
  store ptr %nextStackPointer.sink.i47, ptr %stackPointer_pointer.i3, align 8
  store ptr %prompt.i17, ptr %common.ret.op.i48, align 8, !noalias !0
  %stackPointer_247.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i48, i64 8
  store i64 %offset.i, ptr %stackPointer_247.repack1, align 8, !noalias !0
  %returnAddress_pointer_249 = getelementptr i8, ptr %common.ret.op.i48, i64 16
  %sharer_pointer_250 = getelementptr i8, ptr %common.ret.op.i48, i64 24
  %eraser_pointer_251 = getelementptr i8, ptr %common.ret.op.i48, i64 32
  store ptr @returnAddress_237, ptr %returnAddress_pointer_249, align 8, !noalias !0
  store ptr @sharer_129, ptr %sharer_pointer_250, align 8, !noalias !0
  store ptr @eraser_133, ptr %eraser_pointer_251, align 8, !noalias !0
  %z.i.i = icmp slt i64 %tmp_5107, 0
  br i1 %z.i.i, label %label_236.i, label %label_231.i

label_231.i:                                      ; preds = %stackAllocate.exit63
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i47, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i12.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_231.i
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i47 to i64
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
  store ptr %newBase.i.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_231.i
  %limit.i7.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i12.i, %label_231.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_231.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i47, %label_231.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i3, align 8
  store i64 0, ptr %common.ret.op.i.i, align 4, !noalias !0
  %res_4_77_4904_pointer_220.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store ptr %prompt.i17, ptr %res_4_77_4904_pointer_220.i, align 8, !noalias !0
  %res_4_77_4904_pointer_220.repack1.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %offset.i, ptr %res_4_77_4904_pointer_220.repack1.i, align 8, !noalias !0
  %tmp_5090_pointer_221.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 0, ptr %tmp_5090_pointer_221.i, align 4, !noalias !0
  %tmp_5107_pointer_222.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %tmp_5107, ptr %tmp_5107_pointer_222.i, align 4, !noalias !0
  %returnAddress_pointer_223.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_224.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_225.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_168, ptr %returnAddress_pointer_223.i, align 8, !noalias !0
  store ptr @sharer_202, ptr %sharer_pointer_224.i, align 8, !noalias !0
  store ptr @eraser_212, ptr %eraser_pointer_225.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %prompt.i17, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i3.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i4.i = load ptr, ptr %base_pointer.i3.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i4.i, i64 %offset.i
  %get_5158.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i7.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i8.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i8.i, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %returnAddress_228.i = load ptr, ptr %newStackPointer.i8.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_228.i(i64 %get_5158.i, ptr nonnull %stack)
  ret void

label_236.i:                                      ; preds = %stackAllocate.exit63
  %isInside.i13.i = icmp ule ptr %nextStackPointer.sink.i47, %limit.i12.i
  tail call void @llvm.assume(i1 %isInside.i13.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %nextStackPointer.sink.i47, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %returnAddress_233.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_233.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_259(i64 %returnValue_260, ptr %stack) {
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
  %returnAddress_263 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_263(i64 %returnValue_260, ptr %stack)
  ret void
}

define tailcc void @returnAddress_282(%Pos %__10_29_22_62_4954, ptr %stack) {
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
  %i_5_4_39_4945 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %res_4_12_4909_pointer_285 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %res_4_12_4909.unpack = load ptr, ptr %res_4_12_4909_pointer_285, align 8, !noalias !0
  %res_4_12_4909.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %res_4_12_4909.unpack2 = load i64, ptr %res_4_12_4909.elt1, align 8, !noalias !0
  %tmp_5107_pointer_286 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5107 = load i64, ptr %tmp_5107_pointer_286, align 4, !noalias !0
  %object.i = extractvalue %Pos %__10_29_22_62_4954, 1
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
  %z.i = add i64 %i_5_4_39_4945, 1
  %z.i.i = icmp sgt i64 %z.i, %tmp_5107
  %stackPointer.i10.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br i1 %z.i.i, label %label_344.i, label %label_339.i

label_339.i:                                      ; preds = %erasePositive.exit
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i10.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i12.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_339.i
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %stackPointer.i10.i to i64
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_339.i
  %limit.i7.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i12.i, %label_339.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_339.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %stackPointer.i10.i, %label_339.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store ptr %res_4_12_4909.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_326.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %res_4_12_4909.unpack2, ptr %stackPointer_326.repack1.i, align 8, !noalias !0
  %i_5_4_39_4945_pointer_328.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %z.i, ptr %i_5_4_39_4945_pointer_328.i, align 4, !noalias !0
  %tmp_5083_pointer_329.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store i64 %z.i, ptr %tmp_5083_pointer_329.i, align 4, !noalias !0
  %tmp_5107_pointer_330.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %tmp_5107, ptr %tmp_5107_pointer_330.i, align 4, !noalias !0
  %returnAddress_pointer_331.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_332.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_333.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_276, ptr %returnAddress_pointer_331.i, align 8, !noalias !0
  store ptr @sharer_310, ptr %sharer_pointer_332.i, align 8, !noalias !0
  store ptr @eraser_320, ptr %eraser_pointer_333.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %res_4_12_4909.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i3.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i4.i = load ptr, ptr %base_pointer.i3.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i4.i, i64 %res_4_12_4909.unpack2
  %get_5173.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i7.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i8.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i8.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_336.i = load ptr, ptr %newStackPointer.i8.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_336.i(i64 %get_5173.i, ptr nonnull %stack)
  ret void

label_344.i:                                      ; preds = %erasePositive.exit
  %isInside.i13.i = icmp ule ptr %stackPointer.i10.i, %limit.i12.i
  tail call void @llvm.assume(i1 %isInside.i13.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %stackPointer.i10.i, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_341.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_341.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_276(i64 %v_r_2569_6_25_18_58_4823, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %res_4_12_4909.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %res_4_12_4909.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %res_4_12_4909.unpack2 = load i64, ptr %res_4_12_4909.elt1, align 8, !noalias !0
  %i_5_4_39_4945_pointer_279 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %i_5_4_39_4945 = load i64, ptr %i_5_4_39_4945_pointer_279, align 4, !noalias !0
  %tmp_5083_pointer_280 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %tmp_5083 = load i64, ptr %tmp_5083_pointer_280, align 4, !noalias !0
  %tmp_5107_pointer_281 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5107 = load i64, ptr %tmp_5107_pointer_281, align 4, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
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
  %limit.i22 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i16, %realloc.i ], [ %newStackPointer.i, %entry ]
  %z.i = mul i64 %tmp_5083, %tmp_5083
  %z.i11 = add i64 %z.i, %v_r_2569_6_25_18_58_4823
  %z.i12 = srem i64 %z.i11, 1009
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %i_5_4_39_4945, ptr %common.ret.op.i, align 4, !noalias !0
  %res_4_12_4909_pointer_295 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %res_4_12_4909.unpack, ptr %res_4_12_4909_pointer_295, align 8, !noalias !0
  %res_4_12_4909_pointer_295.repack4 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %res_4_12_4909.unpack2, ptr %res_4_12_4909_pointer_295.repack4, align 8, !noalias !0
  %tmp_5107_pointer_296 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_5107, ptr %tmp_5107_pointer_296, align 4, !noalias !0
  %returnAddress_pointer_297 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_298 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_299 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_282, ptr %returnAddress_pointer_297, align 8, !noalias !0
  store ptr @sharer_70, ptr %sharer_pointer_298, align 8, !noalias !0
  store ptr @eraser_78, ptr %eraser_pointer_299, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_12_4909.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i17 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i18 = load ptr, ptr %base_pointer.i17, align 8
  %varPointer.i = getelementptr i8, ptr %base.i18, i64 %res_4_12_4909.unpack2
  store i64 %z.i12, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i23 = icmp ule ptr %nextStackPointer.sink.i, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_303 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_303(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_310(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_320(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @go_4_3_38_4805(i64 %i_5_4_39_4945, %Reference %res_4_12_4909, i64 %tmp_5107, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp sgt i64 %i_5_4_39_4945, %tmp_5107
  %stackPointer_pointer.i9 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_344, label %label_339

label_339:                                        ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 64
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_339
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

stackAllocate.exit:                               ; preds = %label_339, %realloc.i
  %limit.i7 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_339 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_339 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_339 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i9, align 8
  %res_4_12_4909.elt = extractvalue %Reference %res_4_12_4909, 0
  store ptr %res_4_12_4909.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_326.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %res_4_12_4909.elt2 = extractvalue %Reference %res_4_12_4909, 1
  store i64 %res_4_12_4909.elt2, ptr %stackPointer_326.repack1, align 8, !noalias !0
  %i_5_4_39_4945_pointer_328 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %i_5_4_39_4945, ptr %i_5_4_39_4945_pointer_328, align 4, !noalias !0
  %tmp_5083_pointer_329 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %i_5_4_39_4945, ptr %tmp_5083_pointer_329, align 4, !noalias !0
  %tmp_5107_pointer_330 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %tmp_5107, ptr %tmp_5107_pointer_330, align 4, !noalias !0
  %returnAddress_pointer_331 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_332 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_333 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_276, ptr %returnAddress_pointer_331, align 8, !noalias !0
  store ptr @sharer_310, ptr %sharer_pointer_332, align 8, !noalias !0
  store ptr @eraser_320, ptr %eraser_pointer_333, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_12_4909.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i3 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i4 = load ptr, ptr %base_pointer.i3, align 8
  %varPointer.i = getelementptr i8, ptr %base.i4, i64 %res_4_12_4909.elt2
  %get_5173 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i = icmp ule ptr %nextStackPointer.sink.i, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i8 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i8, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %returnAddress_336 = load ptr, ptr %newStackPointer.i8, align 8, !noalias !0
  musttail call tailcc void %returnAddress_336(i64 %get_5173, ptr nonnull %stack)
  ret void

label_344:                                        ; preds = %entry
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %limit_pointer.i11 = getelementptr i8, ptr %stack, i64 24
  %limit.i12 = load ptr, ptr %limit_pointer.i11, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i9, align 8, !alias.scope !0
  %returnAddress_341 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_341(%Pos zeroinitializer, ptr %stack)
  ret void
}

define tailcc void @returnAddress_345(%Pos %__30_65_4956, ptr %stack) {
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
  %res_4_12_4909.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %res_4_12_4909.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %res_4_12_4909.unpack2 = load i64, ptr %res_4_12_4909.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__30_65_4956, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %res_4_12_4909.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %res_4_12_4909.unpack2
  %get_5175 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_350 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_350(i64 %get_5175, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3515_3579, ptr %stack) {
entry:
  %stackPointer_pointer.i3 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i4 = load ptr, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i4, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3515_3579, 0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i4, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i8 = getelementptr i8, ptr %stack, i64 16
  %base.i9 = load ptr, ptr %base_pointer.i8, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %stackPointer.i4 to i64
  %intBase.i10 = ptrtoint ptr %base.i9 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i10
  %nextSize.i = add i64 %size.i, 32
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i9, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 32
  store ptr %newBase.i, ptr %base_pointer.i8, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i15 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %stackPointer.i4, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i3, align 8
  store i64 %unboxed.i, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_256 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_257 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_258 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_2, ptr %returnAddress_pointer_256, align 8, !noalias !0
  store ptr @sharer_42, ptr %sharer_pointer_257, align 8, !noalias !0
  store ptr @eraser_46, ptr %eraser_pointer_258, align 8, !noalias !0
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i3, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i11 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i16 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i17 = icmp ugt ptr %nextStackPointer.i16, %limit.i15
  br i1 %isInside.not.i17, label %realloc.i20, label %stackAllocate.exit34

realloc.i20:                                      ; preds = %stackAllocate.exit
  %nextSize.i26 = add i64 %offset.i, 32
  %leadingZeros.i.i27 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i26, i1 false)
  %numBits.i.i28 = sub nuw nsw i64 64, %leadingZeros.i.i27
  %result.i.i29 = shl nuw i64 1, %numBits.i.i28
  %newBase.i30 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i29)
  %newLimit.i31 = getelementptr i8, ptr %newBase.i30, i64 %result.i.i29
  %newStackPointer.i32 = getelementptr i8, ptr %newBase.i30, i64 %offset.i
  %newNextStackPointer.i33 = getelementptr i8, ptr %newStackPointer.i32, i64 32
  store ptr %newBase.i30, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i31, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit34

stackAllocate.exit34:                             ; preds = %stackAllocate.exit, %realloc.i20
  %base.i45 = phi ptr [ %newBase.i30, %realloc.i20 ], [ %base.i, %stackAllocate.exit ]
  %limit.i38 = phi ptr [ %newLimit.i31, %realloc.i20 ], [ %limit.i15, %stackAllocate.exit ]
  %nextStackPointer.sink.i18 = phi ptr [ %newNextStackPointer.i33, %realloc.i20 ], [ %nextStackPointer.i16, %stackAllocate.exit ]
  %common.ret.op.i19 = phi ptr [ %newStackPointer.i32, %realloc.i20 ], [ %stackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i18, ptr %stackPointer_pointer.i3, align 8
  store i64 0, ptr %common.ret.op.i19, align 4, !noalias !0
  %returnAddress_pointer_270 = getelementptr i8, ptr %common.ret.op.i19, i64 8
  %sharer_pointer_271 = getelementptr i8, ptr %common.ret.op.i19, i64 16
  %eraser_pointer_272 = getelementptr i8, ptr %common.ret.op.i19, i64 24
  store ptr @returnAddress_259, ptr %returnAddress_pointer_270, align 8, !noalias !0
  store ptr @sharer_42, ptr %sharer_pointer_271, align 8, !noalias !0
  store ptr @eraser_46, ptr %eraser_pointer_272, align 8, !noalias !0
  %nextStackPointer.i39 = getelementptr i8, ptr %nextStackPointer.sink.i18, i64 40
  %isInside.not.i40 = icmp ugt ptr %nextStackPointer.i39, %limit.i38
  br i1 %isInside.not.i40, label %realloc.i43, label %stackAllocate.exit57

realloc.i43:                                      ; preds = %stackAllocate.exit34
  %intStackPointer.i46 = ptrtoint ptr %nextStackPointer.sink.i18 to i64
  %intBase.i47 = ptrtoint ptr %base.i45 to i64
  %size.i48 = sub i64 %intStackPointer.i46, %intBase.i47
  %nextSize.i49 = add i64 %size.i48, 40
  %leadingZeros.i.i50 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i49, i1 false)
  %numBits.i.i51 = sub nuw nsw i64 64, %leadingZeros.i.i50
  %result.i.i52 = shl nuw i64 1, %numBits.i.i51
  %newBase.i53 = tail call ptr @realloc(ptr %base.i45, i64 %result.i.i52)
  %newLimit.i54 = getelementptr i8, ptr %newBase.i53, i64 %result.i.i52
  %newStackPointer.i55 = getelementptr i8, ptr %newBase.i53, i64 %size.i48
  %newNextStackPointer.i56 = getelementptr i8, ptr %newStackPointer.i55, i64 40
  store ptr %newBase.i53, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i54, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit57

stackAllocate.exit57:                             ; preds = %stackAllocate.exit34, %realloc.i43
  %base.i.i = phi ptr [ %newBase.i53, %realloc.i43 ], [ %base.i45, %stackAllocate.exit34 ]
  %limit.i12.i = phi ptr [ %newLimit.i54, %realloc.i43 ], [ %limit.i38, %stackAllocate.exit34 ]
  %nextStackPointer.sink.i41 = phi ptr [ %newNextStackPointer.i56, %realloc.i43 ], [ %nextStackPointer.i39, %stackAllocate.exit34 ]
  %common.ret.op.i42 = phi ptr [ %newStackPointer.i55, %realloc.i43 ], [ %nextStackPointer.sink.i18, %stackAllocate.exit34 ]
  store ptr %nextStackPointer.sink.i41, ptr %stackPointer_pointer.i3, align 8
  store ptr %prompt.i11, ptr %common.ret.op.i42, align 8, !noalias !0
  %stackPointer_355.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i42, i64 8
  store i64 %offset.i, ptr %stackPointer_355.repack1, align 8, !noalias !0
  %returnAddress_pointer_357 = getelementptr i8, ptr %common.ret.op.i42, i64 16
  %sharer_pointer_358 = getelementptr i8, ptr %common.ret.op.i42, i64 24
  %eraser_pointer_359 = getelementptr i8, ptr %common.ret.op.i42, i64 32
  store ptr @returnAddress_345, ptr %returnAddress_pointer_357, align 8, !noalias !0
  store ptr @sharer_129, ptr %sharer_pointer_358, align 8, !noalias !0
  store ptr @eraser_133, ptr %eraser_pointer_359, align 8, !noalias !0
  %z.i.i = icmp slt i64 %unboxed.i, 0
  br i1 %z.i.i, label %label_344.i, label %label_339.i

label_339.i:                                      ; preds = %stackAllocate.exit57
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i41, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i12.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %label_339.i
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i41 to i64
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
  store ptr %newBase.i.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %label_339.i
  %limit.i7.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i12.i, %label_339.i ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %label_339.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i41, %label_339.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i3, align 8
  store ptr %prompt.i11, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_326.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %offset.i, ptr %stackPointer_326.repack1.i, align 8, !noalias !0
  %i_5_4_39_4945_pointer_328.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %tmp_5107_pointer_330.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(16) %i_5_4_39_4945_pointer_328.i, i8 0, i64 16, i1 false)
  store i64 %unboxed.i, ptr %tmp_5107_pointer_330.i, align 4, !noalias !0
  %returnAddress_pointer_331.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_332.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_333.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_276, ptr %returnAddress_pointer_331.i, align 8, !noalias !0
  store ptr @sharer_310, ptr %sharer_pointer_332.i, align 8, !noalias !0
  store ptr @eraser_320, ptr %eraser_pointer_333.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %prompt.i11, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i3.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i4.i = load ptr, ptr %base_pointer.i3.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i4.i, i64 %offset.i
  %get_5173.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i7.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i8.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i8.i, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %returnAddress_336.i = load ptr, ptr %newStackPointer.i8.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_336.i(i64 %get_5173.i, ptr nonnull %stack)
  ret void

label_344.i:                                      ; preds = %stackAllocate.exit57
  %isInside.i13.i = icmp ule ptr %nextStackPointer.sink.i41, %limit.i12.i
  tail call void @llvm.assume(i1 %isInside.i13.i)
  %newStackPointer.i14.i = getelementptr i8, ptr %nextStackPointer.sink.i41, i64 -24
  store ptr %newStackPointer.i14.i, ptr %stackPointer_pointer.i3, align 8, !alias.scope !0
  %returnAddress_341.i = load ptr, ptr %newStackPointer.i14.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_341.i(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define void @sharer_360(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_362(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_369(%Pos %returned_5177, ptr nocapture %stack) {
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
  %returnAddress_371 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_371(%Pos %returned_5177, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_374(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_376(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define void @eraser_389(ptr nocapture readonly %environment) {
entry:
  %tmp_5054_387.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5054_387.unpack2 = load ptr, ptr %tmp_5054_387.elt1, align 8, !noalias !0
  %acc_3_3_5_169_4708_388.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_4708_388.unpack5 = load ptr, ptr %acc_3_3_5_169_4708_388.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_5054_387.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_5054_387.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_5054_387.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_5054_387.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_5054_387.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_5054_387.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_4708_388.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_4708_388.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_4708_388.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_4708_388.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_4708_388.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_4708_388.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4510(i64 %start_2_2_4_168_4583, %Pos %acc_3_3_5_169_4708, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4583, 1
  br i1 %z.i6, label %label_399, label %label_395

label_395:                                        ; preds = %entry, %label_395
  %acc_3_3_5_169_4708.tr8 = phi %Pos [ %make_5183, %label_395 ], [ %acc_3_3_5_169_4708, %entry ]
  %start_2_2_4_168_4583.tr7 = phi i64 [ %z.i5, %label_395 ], [ %start_2_2_4_168_4583, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4583.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4583.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_389, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5180.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_5180.elt, ptr %environment.i, align 8, !noalias !0
  %environment_386.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5180.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_5180.elt2, ptr %environment_386.repack1, align 8, !noalias !0
  %acc_3_3_5_169_4708_pointer_393 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_4708.elt = extractvalue %Pos %acc_3_3_5_169_4708.tr8, 0
  store i64 %acc_3_3_5_169_4708.elt, ptr %acc_3_3_5_169_4708_pointer_393, align 8, !noalias !0
  %acc_3_3_5_169_4708_pointer_393.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_4708.elt4 = extractvalue %Pos %acc_3_3_5_169_4708.tr8, 1
  store ptr %acc_3_3_5_169_4708.elt4, ptr %acc_3_3_5_169_4708_pointer_393.repack3, align 8, !noalias !0
  %make_5183 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4583.tr7, 2
  br i1 %z.i, label %label_399, label %label_395

label_399:                                        ; preds = %label_395, %entry
  %acc_3_3_5_169_4708.tr.lcssa = phi %Pos [ %acc_3_3_5_169_4708, %entry ], [ %make_5183, %label_395 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_396 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_396(%Pos %acc_3_3_5_169_4708.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_410(%Pos %v_r_2668_32_59_223_4542, ptr %stack) {
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
  %tmp_5061 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %v_r_2585_30_194_4492_pointer_413 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_2585_30_194_4492.unpack = load i64, ptr %v_r_2585_30_194_4492_pointer_413, align 8, !noalias !0
  %v_r_2585_30_194_4492.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_r_2585_30_194_4492.unpack2 = load ptr, ptr %v_r_2585_30_194_4492.elt1, align 8, !noalias !0
  %p_8_9_4413_pointer_414 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %p_8_9_4413 = load ptr, ptr %p_8_9_4413_pointer_414, align 8, !noalias !0
  %index_7_34_198_4697_pointer_415 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %index_7_34_198_4697 = load i64, ptr %index_7_34_198_4697_pointer_415, align 4, !noalias !0
  %acc_8_35_199_4468_pointer_416 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %acc_8_35_199_4468 = load i64, ptr %acc_8_35_199_4468_pointer_416, align 4, !noalias !0
  %tag_417 = extractvalue %Pos %v_r_2668_32_59_223_4542, 0
  %fields_418 = extractvalue %Pos %v_r_2668_32_59_223_4542, 1
  switch i64 %tag_417, label %common.ret [
    i64 1, label %label_442
    i64 0, label %label_449
  ]

common.ret:                                       ; preds = %entry
  ret void

label_430:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2585_30_194_4492.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_430
  %referenceCount.i.i37 = load i64, ptr %v_r_2585_30_194_4492.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2585_30_194_4492.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2585_30_194_4492.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2585_30_194_4492.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4492.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_430, %decr.i.i39, %free.i.i41
  %pair_425 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4413)
  %k_13_14_4_4977 = extractvalue <{ ptr, ptr }> %pair_425, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_4977, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_4977, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_4977, i64 40
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
  %stack_426 = extractvalue <{ ptr, ptr }> %pair_425, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_426, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_426, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_427 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_427(%Pos { i64 5, ptr null }, ptr %stack_426)
  ret void

label_439:                                        ; preds = %label_441
  %isNull.i.i24 = icmp eq ptr %v_r_2585_30_194_4492.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_439
  %referenceCount.i.i26 = load i64, ptr %v_r_2585_30_194_4492.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2585_30_194_4492.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2585_30_194_4492.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2585_30_194_4492.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4492.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_439, %decr.i.i28, %free.i.i30
  %pair_434 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4413)
  %k_13_14_4_4976 = extractvalue <{ ptr, ptr }> %pair_434, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_4976, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_4976, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4976, i64 40
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
  %stack_435 = extractvalue <{ ptr, ptr }> %pair_434, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_435, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_435, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_436 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_436(%Pos { i64 5, ptr null }, ptr %stack_435)
  ret void

label_440:                                        ; preds = %label_441
  %0 = insertvalue %Pos poison, i64 %v_r_2585_30_194_4492.unpack, 0
  %v_r_2585_30_194_44923 = insertvalue %Pos %0, ptr %v_r_2585_30_194_4492.unpack2, 1
  %z.i = add i64 %index_7_34_198_4697, 1
  %z.i108 = mul i64 %acc_8_35_199_4468, 10
  %z.i109 = sub i64 %z.i108, %tmp_5061
  %z.i110 = add i64 %z.i109, %v_coe_3484_46_73_237_4722.unpack
  musttail call tailcc void @go_6_33_197_4673(i64 %z.i, i64 %z.i110, i64 %tmp_5061, %Pos %v_r_2585_30_194_44923, ptr %p_8_9_4413, ptr nonnull %stack)
  ret void

label_441:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3484_46_73_237_4722.unpack, 58
  br i1 %z.i111, label %label_440, label %label_439

label_442:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_418, i64 16
  %v_coe_3484_46_73_237_4722.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3484_46_73_237_4722.elt4 = getelementptr i8, ptr %fields_418, i64 24
  %v_coe_3484_46_73_237_4722.unpack5 = load ptr, ptr %v_coe_3484_46_73_237_4722.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3484_46_73_237_4722.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_442
  %referenceCount.i.i = load i64, ptr %v_coe_3484_46_73_237_4722.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3484_46_73_237_4722.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_442
  %referenceCount.i11 = load i64, ptr %fields_418, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_418, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_418, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_418)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_3484_46_73_237_4722.unpack, 47
  br i1 %z.i112, label %label_441, label %label_430

label_449:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_418, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_449
  %referenceCount.i = load i64, ptr %fields_418, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_418, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_418, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_418, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_418)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_449, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_2585_30_194_4492.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2585_30_194_4492.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2585_30_194_4492.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2585_30_194_4492.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2585_30_194_4492.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4492.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_446 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_446(i64 %acc_8_35_199_4468, ptr nonnull %stack)
  ret void
}

define void @sharer_455(ptr %stackPointer) {
entry:
  %v_r_2585_30_194_4492_451.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %v_r_2585_30_194_4492_451.unpack2 = load ptr, ptr %v_r_2585_30_194_4492_451.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2585_30_194_4492_451.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2585_30_194_4492_451.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2585_30_194_4492_451.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_467(ptr %stackPointer) {
entry:
  %v_r_2585_30_194_4492_463.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %v_r_2585_30_194_4492_463.unpack2 = load ptr, ptr %v_r_2585_30_194_4492_463.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2585_30_194_4492_463.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2585_30_194_4492_463.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2585_30_194_4492_463.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2585_30_194_4492_463.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2585_30_194_4492_463.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4492_463.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_484(%Pos %returned_5208, ptr nocapture %stack) {
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
  %returnAddress_486 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_486(%Pos %returned_5208, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_4479_clause_493(ptr %closure, %Pos %exc_8_20_47_211_4695, %Pos %msg_9_21_48_212_4707, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4690 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_496 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4690)
  %k_11_23_50_214_4737 = extractvalue <{ ptr, ptr }> %pair_496, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_4737, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_4737, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_4737, i64 40
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
  %stack_497 = extractvalue <{ ptr, ptr }> %pair_496, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_389, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_4695.elt = extractvalue %Pos %exc_8_20_47_211_4695, 0
  store i64 %exc_8_20_47_211_4695.elt, ptr %environment.i, align 8, !noalias !0
  %environment_499.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_4695.elt2 = extractvalue %Pos %exc_8_20_47_211_4695, 1
  store ptr %exc_8_20_47_211_4695.elt2, ptr %environment_499.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4707_pointer_503 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4707.elt = extractvalue %Pos %msg_9_21_48_212_4707, 0
  store i64 %msg_9_21_48_212_4707.elt, ptr %msg_9_21_48_212_4707_pointer_503, align 8, !noalias !0
  %msg_9_21_48_212_4707_pointer_503.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4707.elt4 = extractvalue %Pos %msg_9_21_48_212_4707, 1
  store ptr %msg_9_21_48_212_4707.elt4, ptr %msg_9_21_48_212_4707_pointer_503.repack3, align 8, !noalias !0
  %make_5209 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_497, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_497, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_505 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_505(%Pos %make_5209, ptr %stack_497)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_512(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_520(ptr nocapture readonly %environment) {
entry:
  %tmp_5063_519.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5063_519.unpack2 = load ptr, ptr %tmp_5063_519.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5063_519.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5063_519.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5063_519.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5063_519.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5063_519.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5063_519.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_516(i64 %v_coe_3483_6_28_55_219_4526, ptr %stack) {
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
  store ptr @eraser_520, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3483_6_28_55_219_4526, ptr %environment.i, align 8, !noalias !0
  %environment_518.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_518.repack1, align 8, !noalias !0
  %make_5211 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_524 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_524(%Pos %make_5211, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_4673(i64 %index_7_34_198_4697, i64 %acc_8_35_199_4468, i64 %tmp_5061, %Pos %v_r_2585_30_194_4492, ptr %p_8_9_4413, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2585_30_194_4492, 1
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
  store i64 %tmp_5061, ptr %common.ret.op.i, align 4, !noalias !0
  %v_r_2585_30_194_4492_pointer_476 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_r_2585_30_194_4492.elt = extractvalue %Pos %v_r_2585_30_194_4492, 0
  store i64 %v_r_2585_30_194_4492.elt, ptr %v_r_2585_30_194_4492_pointer_476, align 8, !noalias !0
  %v_r_2585_30_194_4492_pointer_476.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i3, ptr %v_r_2585_30_194_4492_pointer_476.repack1, align 8, !noalias !0
  %p_8_9_4413_pointer_477 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %p_8_9_4413, ptr %p_8_9_4413_pointer_477, align 8, !noalias !0
  %index_7_34_198_4697_pointer_478 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %index_7_34_198_4697, ptr %index_7_34_198_4697_pointer_478, align 4, !noalias !0
  %acc_8_35_199_4468_pointer_479 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %acc_8_35_199_4468, ptr %acc_8_35_199_4468_pointer_479, align 4, !noalias !0
  %returnAddress_pointer_480 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_481 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_482 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_410, ptr %returnAddress_pointer_480, align 8, !noalias !0
  store ptr @sharer_455, ptr %sharer_pointer_481, align 8, !noalias !0
  store ptr @eraser_467, ptr %eraser_pointer_482, align 8, !noalias !0
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
  %sharer_pointer_491 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_492 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_484, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_374, ptr %sharer_pointer_491, align 8, !noalias !0
  store ptr @eraser_376, ptr %eraser_pointer_492, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_512, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_4479 = insertvalue %Neg { ptr @vtable_508, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_529 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_530 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_516, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_360, ptr %sharer_pointer_529, align 8, !noalias !0
  store ptr @eraser_362, ptr %eraser_pointer_530, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2585_30_194_4492, i64 %index_7_34_198_4697, %Neg %Exception_7_19_46_210_4479, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_4545_clause_531(ptr %closure, %Pos %exception_10_107_134_298_5212, %Pos %msg_11_108_135_299_5213, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4413 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_5212, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_5213, 1
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
  %pair_534 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4413)
  %k_13_14_4_5044 = extractvalue <{ ptr, ptr }> %pair_534, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_5044, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_5044, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5044, i64 40
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
  %stack_535 = extractvalue <{ ptr, ptr }> %pair_534, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_535, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_535, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_536 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_536(%Pos { i64 5, ptr null }, ptr %stack_535)
  ret void
}

define tailcc void @returnAddress_550(i64 %v_coe_3488_22_131_158_322_4684, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3488_22_131_158_322_4684, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_551 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_551(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_562(i64 %v_r_2682_1_9_20_129_156_320_4594, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2682_1_9_20_129_156_320_4594
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_563 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_563(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_545(i64 %v_r_2681_3_14_123_150_314_4641, ptr %stack) {
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
  %tmp_5061 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %v_r_2585_30_194_4492_pointer_548 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2585_30_194_4492.unpack = load i64, ptr %v_r_2585_30_194_4492_pointer_548, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2585_30_194_4492.unpack, 0
  %v_r_2585_30_194_4492.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2585_30_194_4492.unpack2 = load ptr, ptr %v_r_2585_30_194_4492.elt1, align 8, !noalias !0
  %v_r_2585_30_194_44923 = insertvalue %Pos %0, ptr %v_r_2585_30_194_4492.unpack2, 1
  %p_8_9_4413_pointer_549 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_4413 = load ptr, ptr %p_8_9_4413_pointer_549, align 8, !noalias !0
  %z.i = icmp eq i64 %v_r_2681_3_14_123_150_314_4641, 45
  %isInside.not.i = icmp ugt ptr %p_8_9_4413_pointer_549, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %p_8_9_4413_pointer_549, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_556 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_557 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_550, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_360, ptr %sharer_pointer_556, align 8, !noalias !0
  store ptr @eraser_362, ptr %eraser_pointer_557, align 8, !noalias !0
  br i1 %z.i, label %label_570, label %label_561

label_561:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_4673(i64 0, i64 0, i64 %tmp_5061, %Pos %v_r_2585_30_194_44923, ptr %p_8_9_4413, ptr nonnull %stack)
  ret void

label_570:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_570
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

stackAllocate.exit35:                             ; preds = %label_570, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_570 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_570 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_568 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_569 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_562, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_360, ptr %sharer_pointer_568, align 8, !noalias !0
  store ptr @eraser_362, ptr %eraser_pointer_569, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_4673(i64 1, i64 0, i64 %tmp_5061, %Pos %v_r_2585_30_194_44923, ptr %p_8_9_4413, ptr nonnull %stack)
  ret void
}

define void @sharer_574(ptr %stackPointer) {
entry:
  %v_r_2585_30_194_4492_572.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2585_30_194_4492_572.unpack2 = load ptr, ptr %v_r_2585_30_194_4492_572.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2585_30_194_4492_572.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2585_30_194_4492_572.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2585_30_194_4492_572.unpack2, align 4
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
  %v_r_2585_30_194_4492_580.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %v_r_2585_30_194_4492_580.unpack2 = load ptr, ptr %v_r_2585_30_194_4492_580.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2585_30_194_4492_580.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2585_30_194_4492_580.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2585_30_194_4492_580.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2585_30_194_4492_580.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2585_30_194_4492_580.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2585_30_194_4492_580.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_407(%Pos %v_r_2585_30_194_4492, ptr %stack) {
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
  %p_8_9_4413 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_512, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4413, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2585_30_194_4492, 1
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
  %v_r_2585_30_194_4492_pointer_589 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %v_r_2585_30_194_4492.elt = extractvalue %Pos %v_r_2585_30_194_4492, 0
  store i64 %v_r_2585_30_194_4492.elt, ptr %v_r_2585_30_194_4492_pointer_589, align 8, !noalias !0
  %v_r_2585_30_194_4492_pointer_589.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i3, ptr %v_r_2585_30_194_4492_pointer_589.repack1, align 8, !noalias !0
  %p_8_9_4413_pointer_590 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %p_8_9_4413, ptr %p_8_9_4413_pointer_590, align 8, !noalias !0
  %returnAddress_pointer_591 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_592 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_593 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_545, ptr %returnAddress_pointer_591, align 8, !noalias !0
  store ptr @sharer_574, ptr %sharer_pointer_592, align 8, !noalias !0
  store ptr @eraser_582, ptr %eraser_pointer_593, align 8, !noalias !0
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
  store i64 %v_r_2585_30_194_4492.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_688.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_688.repack1.i, align 8, !noalias !0
  %index_2107_pointer_690.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_690.i, align 4, !noalias !0
  %Exception_2362_pointer_691.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_539, ptr %Exception_2362_pointer_691.i, align 8, !noalias !0
  %Exception_2362_pointer_691.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_691.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_692.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_693.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_694.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_654, ptr %returnAddress_pointer_692.i, align 8, !noalias !0
  store ptr @sharer_675, ptr %sharer_pointer_693.i, align 8, !noalias !0
  store ptr @eraser_683, ptr %eraser_pointer_694.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2585_30_194_4492)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_698.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_698.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_595(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_599(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_404(%Pos %v_r_2584_24_188_4452, ptr %stack) {
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
  %p_8_9_4413 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4413, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_605 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_606 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_407, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_595, ptr %sharer_pointer_605, align 8, !noalias !0
  store ptr @eraser_599, ptr %eraser_pointer_606, align 8, !noalias !0
  %tag_607 = extractvalue %Pos %v_r_2584_24_188_4452, 0
  switch i64 %tag_607, label %label_609 [
    i64 0, label %label_613
    i64 1, label %label_619
  ]

label_609:                                        ; preds = %stackAllocate.exit
  ret void

label_613:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_5228 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5228.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_610 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_610(%Pos %utf8StringLiteral_5228, ptr nonnull %stack)
  ret void

label_619:                                        ; preds = %stackAllocate.exit
  %fields_608 = extractvalue %Pos %v_r_2584_24_188_4452, 1
  %environment.i = getelementptr i8, ptr %fields_608, i64 16
  %v_y_3310_8_29_193_4488.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3310_8_29_193_4488.elt1 = getelementptr i8, ptr %fields_608, i64 24
  %v_y_3310_8_29_193_4488.unpack2 = load ptr, ptr %v_y_3310_8_29_193_4488.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3310_8_29_193_4488.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_619
  %referenceCount.i.i = load i64, ptr %v_y_3310_8_29_193_4488.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3310_8_29_193_4488.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_619
  %referenceCount.i = load i64, ptr %fields_608, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_608, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_608, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_608)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3310_8_29_193_4488.unpack, 0
  %v_y_3310_8_29_193_44883 = insertvalue %Pos %0, ptr %v_y_3310_8_29_193_4488.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_616 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_616(%Pos %v_y_3310_8_29_193_44883, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_401(%Pos %v_r_2583_13_177_4596, ptr %stack) {
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
  %p_8_9_4413 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4413, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_625 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_626 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_404, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_595, ptr %sharer_pointer_625, align 8, !noalias !0
  store ptr @eraser_599, ptr %eraser_pointer_626, align 8, !noalias !0
  %tag_627 = extractvalue %Pos %v_r_2583_13_177_4596, 0
  switch i64 %tag_627, label %label_629 [
    i64 0, label %label_634
    i64 1, label %label_646
  ]

label_629:                                        ; preds = %stackAllocate.exit
  ret void

label_634:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4413, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_407, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_595, ptr %sharer_pointer_625, align 8, !noalias !0
  store ptr @eraser_599, ptr %eraser_pointer_626, align 8, !noalias !0
  %utf8StringLiteral_5228.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5228.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_610.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_610.i(%Pos %utf8StringLiteral_5228.i, ptr nonnull %stack)
  ret void

label_646:                                        ; preds = %stackAllocate.exit
  %fields_628 = extractvalue %Pos %v_r_2583_13_177_4596, 1
  %environment.i6 = getelementptr i8, ptr %fields_628, i64 16
  %v_y_2819_10_21_185_4696.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_2819_10_21_185_4696.elt1 = getelementptr i8, ptr %fields_628, i64 24
  %v_y_2819_10_21_185_4696.unpack2 = load ptr, ptr %v_y_2819_10_21_185_4696.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2819_10_21_185_4696.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_646
  %referenceCount.i.i = load i64, ptr %v_y_2819_10_21_185_4696.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2819_10_21_185_4696.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_646
  %referenceCount.i = load i64, ptr %fields_628, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_628, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_628, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_628)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_520, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2819_10_21_185_4696.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_639.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2819_10_21_185_4696.unpack2, ptr %environment_639.repack4, align 8, !noalias !0
  %make_5230 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_643 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_643(%Pos %make_5230, ptr nonnull %stack)
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
  %sharer_pointer_366 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_367 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_360, ptr %sharer_pointer_366, align 8, !noalias !0
  store ptr @eraser_362, ptr %eraser_pointer_367, align 8, !noalias !0
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
  %sharer_pointer_380 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_381 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_369, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_374, ptr %sharer_pointer_380, align 8, !noalias !0
  store ptr @eraser_376, ptr %eraser_pointer_381, align 8, !noalias !0
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
  %returnAddress_pointer_651 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_652 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_653 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_401, ptr %returnAddress_pointer_651, align 8, !noalias !0
  store ptr @sharer_595, ptr %sharer_pointer_652, align 8, !noalias !0
  store ptr @eraser_599, ptr %eraser_pointer_653, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_399.i, label %label_395.i

label_395.i:                                      ; preds = %stackAllocate.exit46, %label_395.i
  %acc_3_3_5_169_4708.tr8.i = phi %Pos [ %make_5183.i, %label_395.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4583.tr7.i = phi i64 [ %z.i5.i, %label_395.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4583.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4583.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_389, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_5180.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_5180.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_386.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_5180.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_5180.elt2.i, ptr %environment_386.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_4708_pointer_393.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_4708.elt.i = extractvalue %Pos %acc_3_3_5_169_4708.tr8.i, 0
  store i64 %acc_3_3_5_169_4708.elt.i, ptr %acc_3_3_5_169_4708_pointer_393.i, align 8, !noalias !0
  %acc_3_3_5_169_4708_pointer_393.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_4708.elt4.i = extractvalue %Pos %acc_3_3_5_169_4708.tr8.i, 1
  store ptr %acc_3_3_5_169_4708.elt4.i, ptr %acc_3_3_5_169_4708_pointer_393.repack3.i, align 8, !noalias !0
  %make_5183.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4583.tr7.i, 2
  br i1 %z.i.i, label %label_399.i.loopexit, label %label_395.i

label_399.i.loopexit:                             ; preds = %label_395.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_399.i

label_399.i:                                      ; preds = %label_399.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_399.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_399.i.loopexit ]
  %acc_3_3_5_169_4708.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_5183.i, %label_399.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_396.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_396.i(%Pos %acc_3_3_5_169_4708.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_654(%Pos %v_r_2750_3546, ptr %stack) {
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
  %index_2107_pointer_657 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_657, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_659 = extractvalue %Pos %v_r_2750_3546, 0
  switch i64 %tag_659, label %label_661 [
    i64 0, label %label_665
    i64 1, label %label_671
  ]

label_661:                                        ; preds = %entry
  ret void

label_665:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_665
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

eraseNegative.exit:                               ; preds = %label_665, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_662 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_662(i64 %x.i, ptr nonnull %stack)
  ret void

label_671:                                        ; preds = %entry
  %Exception_2362_pointer_658 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_658, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_5114 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5114.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5114, %Pos %z.i)
  %utf8StringLiteral_5116 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_5116.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5116)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_5119 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5119.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_5119)
  %functionPointer_670 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_670(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_675(ptr %stackPointer) {
entry:
  %str_2106_672.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_672.unpack2 = load ptr, ptr %str_2106_672.elt1, align 8, !noalias !0
  %Exception_2362_674.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_674.unpack5 = load ptr, ptr %Exception_2362_674.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_672.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_672.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_672.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_674.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_674.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_674.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_683(ptr %stackPointer) {
entry:
  %str_2106_680.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_680.unpack2 = load ptr, ptr %str_2106_680.elt1, align 8, !noalias !0
  %Exception_2362_682.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_682.unpack5 = load ptr, ptr %Exception_2362_682.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_680.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_680.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_680.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_680.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_680.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_680.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_682.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_682.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_682.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_682.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_682.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_682.unpack5)
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
  %stackPointer_688.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_688.repack1, align 8, !noalias !0
  %index_2107_pointer_690 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_690, align 4, !noalias !0
  %Exception_2362_pointer_691 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_691, align 8, !noalias !0
  %Exception_2362_pointer_691.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_691.repack3, align 8, !noalias !0
  %returnAddress_pointer_692 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_693 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_694 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_654, ptr %returnAddress_pointer_692, align 8, !noalias !0
  store ptr @sharer_675, ptr %sharer_pointer_693, align 8, !noalias !0
  store ptr @eraser_683, ptr %eraser_pointer_694, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_701, label %label_706

label_701:                                        ; preds = %stackAllocate.exit
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
  %returnAddress_698 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_698(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_706:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_706
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

erasePositive.exit:                               ; preds = %label_706, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_703 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_703(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
