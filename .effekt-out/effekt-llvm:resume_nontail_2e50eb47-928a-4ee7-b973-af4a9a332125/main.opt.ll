; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:resume_nontail_2e50eb47-928a-4ee7-b973-af4a9a332125/main.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:resume_nontail_2e50eb47-928a-4ee7-b973-af4a9a332125/main.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }

@vtable_276 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4312_clause_261]
@vtable_307 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4430_clause_299]
@utf8StringLiteral_4735.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_4649.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_4651.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_4654.lit = private constant [1 x i8] c"'"

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

define tailcc void @returnAddress_5(i64 %v_r_2508_39_4507, ptr %stack) {
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
  %l_3_4498 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_4642_pointer_8 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_4642 = load i64, ptr %tmp_4642_pointer_8, align 4, !noalias !0
  %z.i = add i64 %l_3_4498, -1
  musttail call tailcc void @step_2_4509(i64 %z.i, i64 %v_r_2508_39_4507, i64 %tmp_4642, ptr %stack)
  ret void
}

define void @sharer_11(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_17(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_28(i64 %returned_4663, ptr nocapture %stack) {
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
  %returnAddress_30 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_30(i64 %returned_4663, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_33(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_35(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define tailcc void @returnAddress_44(%Pos %__8_34_37_4528, ptr %stack) {
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
  %i_6_20_23_4512 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %s_4_4515_pointer_47 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %s_4_4515 = load i64, ptr %s_4_4515_pointer_47, align 4, !noalias !0
  %p_4_7_4518_pointer_48 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_4_7_4518 = load ptr, ptr %p_4_7_4518_pointer_48, align 8, !noalias !0
  %object.i = extractvalue %Pos %__8_34_37_4528, 1
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
  %z.i = add i64 %i_6_20_23_4512, -1
  musttail call tailcc void @loop_worker_5_19_22_4519(i64 %z.i, i64 %s_4_4515, ptr %p_4_7_4518, ptr nonnull %stack)
  ret void
}

define void @sharer_52(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_60(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -32
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_77(i64 %v_r_2503_12_32_35_4526, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = srem i64 %v_r_2503_12_32_35_4526, 1009
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_78 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_78(i64 %z.i, ptr %stack)
  ret void
}

define void @sharer_81(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_83(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_74(i64 %y_6_26_29_4495, ptr %stack) {
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
  %i_6_20_23_4512 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %z.i.neg = mul i64 %y_6_26_29_4495, -503
  %z.i6 = add i64 %i_6_20_23_4512, %z.i.neg
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
  %sharer_pointer_87 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_88 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_77, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_81, ptr %sharer_pointer_87, align 8, !noalias !0
  store ptr @eraser_83, ptr %eraser_pointer_88, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %z.i7, -1
  br i1 %switch.not.not, label %label_95, label %label_99

label_95:                                         ; preds = %stackAllocate.exit
  %isInside.i17 = icmp ule ptr %nextStackPointer.sink.i, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_92 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_92(i64 %z.i7, ptr nonnull %stack)
  ret void

label_99:                                         ; preds = %stackAllocate.exit
  %z.i19 = sub nuw i64 -37, %z.i6
  %isInside.i24 = icmp ule ptr %nextStackPointer.sink.i, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i24)
  %newStackPointer.i25 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i25, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_96 = load ptr, ptr %newStackPointer.i25, align 8, !noalias !0
  musttail call tailcc void %returnAddress_96(i64 %z.i19, ptr nonnull %stack)
  ret void
}

define void @sharer_101(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_105(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @loop_worker_5_19_22_4519(i64 %i_6_20_23_4512, i64 %s_4_4515, ptr %p_4_7_4518, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp eq i64 %i_6_20_23_4512, 0
  %stackPointer_pointer.i28 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_122, label %label_118

label_118:                                        ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i28, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 48
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_118
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

stackAllocate.exit:                               ; preds = %label_118, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_118 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_118 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i28, align 8
  store i64 %i_6_20_23_4512, ptr %common.ret.op.i, align 4, !noalias !0
  %s_4_4515_pointer_67 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %s_4_4515, ptr %s_4_4515_pointer_67, align 4, !noalias !0
  %p_4_7_4518_pointer_68 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %p_4_7_4518, ptr %p_4_7_4518_pointer_68, align 8, !noalias !0
  %returnAddress_pointer_69 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %sharer_pointer_70 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %eraser_pointer_71 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr @returnAddress_44, ptr %returnAddress_pointer_69, align 8, !noalias !0
  store ptr @sharer_52, ptr %sharer_pointer_70, align 8, !noalias !0
  store ptr @eraser_60, ptr %eraser_pointer_71, align 8, !noalias !0
  %pair_72 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_4_7_4518)
  %k_3_23_26_4513 = extractvalue <{ ptr, ptr }> %pair_72, 0
  %stack_73 = extractvalue <{ ptr, ptr }> %pair_72, 1
  %stackPointer_pointer.i1 = getelementptr i8, ptr %stack_73, i64 8
  %limit_pointer.i2 = getelementptr i8, ptr %stack_73, i64 24
  %currentStackPointer.i3 = load ptr, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i2, align 8, !alias.scope !0
  %nextStackPointer.i5 = getelementptr i8, ptr %currentStackPointer.i3, i64 32
  %isInside.not.i6 = icmp ugt ptr %nextStackPointer.i5, %limit.i4
  br i1 %isInside.not.i6, label %realloc.i9, label %stackAllocate.exit23

realloc.i9:                                       ; preds = %stackAllocate.exit
  %base_pointer.i10 = getelementptr i8, ptr %stack_73, i64 16
  %base.i11 = load ptr, ptr %base_pointer.i10, align 8, !alias.scope !0
  %intStackPointer.i12 = ptrtoint ptr %currentStackPointer.i3 to i64
  %intBase.i13 = ptrtoint ptr %base.i11 to i64
  %size.i14 = sub i64 %intStackPointer.i12, %intBase.i13
  %nextSize.i15 = add i64 %size.i14, 32
  %leadingZeros.i.i16 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i15, i1 false)
  %numBits.i.i17 = sub nuw nsw i64 64, %leadingZeros.i.i16
  %result.i.i18 = shl nuw i64 1, %numBits.i.i17
  %newBase.i19 = tail call ptr @realloc(ptr %base.i11, i64 %result.i.i18)
  %newLimit.i20 = getelementptr i8, ptr %newBase.i19, i64 %result.i.i18
  %newStackPointer.i21 = getelementptr i8, ptr %newBase.i19, i64 %size.i14
  %newNextStackPointer.i22 = getelementptr i8, ptr %newStackPointer.i21, i64 32
  store ptr %newBase.i19, ptr %base_pointer.i10, align 8, !alias.scope !0
  store ptr %newLimit.i20, ptr %limit_pointer.i2, align 8, !alias.scope !0
  br label %stackAllocate.exit23

stackAllocate.exit23:                             ; preds = %stackAllocate.exit, %realloc.i9
  %nextStackPointer.sink.i7 = phi ptr [ %newNextStackPointer.i22, %realloc.i9 ], [ %nextStackPointer.i5, %stackAllocate.exit ]
  %common.ret.op.i8 = phi ptr [ %newStackPointer.i21, %realloc.i9 ], [ %currentStackPointer.i3, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i7, ptr %stackPointer_pointer.i1, align 8
  store i64 %i_6_20_23_4512, ptr %common.ret.op.i8, align 4, !noalias !0
  %returnAddress_pointer_110 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %sharer_pointer_111 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  %eraser_pointer_112 = getelementptr i8, ptr %common.ret.op.i8, i64 24
  store ptr @returnAddress_74, ptr %returnAddress_pointer_110, align 8, !noalias !0
  store ptr @sharer_101, ptr %sharer_pointer_111, align 8, !noalias !0
  store ptr @eraser_105, ptr %eraser_pointer_112, align 8, !noalias !0
  %referenceCount.i.i = load i64, ptr %k_3_23_26_4513, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %.uniqueStack.exit_crit_edge.i, label %copy.i.i

.uniqueStack.exit_crit_edge.i:                    ; preds = %stackAllocate.exit23
  %rest_pointer.phi.trans.insert.i = getelementptr i8, ptr %k_3_23_26_4513, i64 40
  %start.pre.i = load ptr, ptr %rest_pointer.phi.trans.insert.i, align 8
  br label %uniqueStack.exit.i

copy.i.i:                                         ; preds = %stackAllocate.exit23
  %newOldReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newOldReferenceCount.i.i, ptr %k_3_23_26_4513, align 4
  %stack_pointer.i.i = getelementptr i8, ptr %k_3_23_26_4513, i64 40
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %newHead.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  br label %loop.i.i

loop.i.i:                                         ; preds = %next.i.i, %copy.i.i
  %old.i.i = phi ptr [ %stack.i.i, %copy.i.i ], [ %rest.i.i, %next.i.i ]
  %newStack.i.i = phi ptr [ %newHead.i.i, %copy.i.i ], [ %nextNew.i.i, %next.i.i ]
  %stackMemory.i.i = getelementptr i8, ptr %old.i.i, i64 8
  %stackPrompt.i.i = getelementptr i8, ptr %old.i.i, i64 32
  %stackRest.i.i = getelementptr i8, ptr %old.i.i, i64 40
  %memory.unpack.i.i = load ptr, ptr %stackMemory.i.i, align 8
  %memory.elt1.i.i = getelementptr i8, ptr %old.i.i, i64 16
  %memory.unpack2.i.i = load ptr, ptr %memory.elt1.i.i, align 8
  %memory.elt3.i.i = getelementptr i8, ptr %old.i.i, i64 24
  %memory.unpack4.i.i = load ptr, ptr %memory.elt3.i.i, align 8
  %prompt.i.i = load ptr, ptr %stackPrompt.i.i, align 8
  %rest.i.i = load ptr, ptr %stackRest.i.i, align 8
  %newStackMemory.i.i = getelementptr i8, ptr %newStack.i.i, i64 8
  %newStackPrompt.i.i = getelementptr i8, ptr %newStack.i.i, i64 32
  %newStackRest.i.i = getelementptr i8, ptr %newStack.i.i, i64 40
  %intStackPointer.i.i.i = ptrtoint ptr %memory.unpack.i.i to i64
  %intBase.i.i.i = ptrtoint ptr %memory.unpack2.i.i to i64
  %intLimit.i.i.i = ptrtoint ptr %memory.unpack4.i.i to i64
  %used.i.i.i = sub i64 %intStackPointer.i.i.i, %intBase.i.i.i
  %size.i.i.i = sub i64 %intLimit.i.i.i, %intBase.i.i.i
  %newBase.i.i.i = tail call ptr @malloc(i64 %size.i.i.i)
  %intNewBase.i.i.i = ptrtoint ptr %newBase.i.i.i to i64
  %intNewStackPointer.i.i.i = add i64 %used.i.i.i, %intNewBase.i.i.i
  %intNewLimit.i.i.i = add i64 %size.i.i.i, %intNewBase.i.i.i
  %newStackPointer.i.i.i = inttoptr i64 %intNewStackPointer.i.i.i to ptr
  %newLimit.i.i.i = inttoptr i64 %intNewLimit.i.i.i to ptr
  tail call void @memcpy(ptr %newBase.i.i.i, ptr %memory.unpack2.i.i, i64 %used.i.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i.i, i64 -24
  %stackSharer.i.i = getelementptr i8, ptr %newStackPointer.i.i.i, i64 -16
  %sharer.i.i = load ptr, ptr %stackSharer.i.i, align 8
  tail call void %sharer.i.i(ptr %newStackPointer.i.i)
  %referenceCount.i.i.i = load i64, ptr %prompt.i.i, align 4
  %newReferenceCount.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %newReferenceCount.i.i.i, ptr %prompt.i.i, align 4
  store i64 0, ptr %newStack.i.i, align 4
  store ptr %newStackPointer.i.i.i, ptr %newStackMemory.i.i, align 8
  %newStackMemory.repack6.i.i = getelementptr i8, ptr %newStack.i.i, i64 16
  store ptr %newBase.i.i.i, ptr %newStackMemory.repack6.i.i, align 8
  %newStackMemory.repack8.i.i = getelementptr i8, ptr %newStack.i.i, i64 24
  store ptr %newLimit.i.i.i, ptr %newStackMemory.repack8.i.i, align 8
  store ptr %prompt.i.i, ptr %newStackPrompt.i.i, align 8
  %isEnd.i.i = icmp eq ptr %old.i.i, %k_3_23_26_4513
  br i1 %isEnd.i.i, label %stop.i.i, label %next.i.i

next.i.i:                                         ; preds = %loop.i.i
  %nextNew.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  store ptr %nextNew.i.i, ptr %newStackRest.i.i, align 8
  br label %loop.i.i

stop.i.i:                                         ; preds = %loop.i.i
  store ptr %newHead.i.i, ptr %newStackRest.i.i, align 8
  br label %uniqueStack.exit.i

uniqueStack.exit.i:                               ; preds = %stop.i.i, %.uniqueStack.exit_crit_edge.i
  %start.i = phi ptr [ %newHead.i.i, %stop.i.i ], [ %start.pre.i, %.uniqueStack.exit_crit_edge.i ]
  %common.ret.op.i.i = phi ptr [ %newStack.i.i, %stop.i.i ], [ %k_3_23_26_4513, %.uniqueStack.exit_crit_edge.i ]
  %prompt_pointer1.i.i = getelementptr i8, ptr %start.i, i64 32
  %prompt2.i.i = load ptr, ptr %prompt_pointer1.i.i, align 8
  %stack_pointer3.i.i = getelementptr i8, ptr %prompt2.i.i, i64 8
  %promptStack4.i.i = load ptr, ptr %stack_pointer3.i.i, align 8
  %isThis5.i.i = icmp eq ptr %promptStack4.i.i, %start.i
  br i1 %isThis5.i.i, label %resume.exit, label %continue.i.i

continue.i.i:                                     ; preds = %uniqueStack.exit.i, %update.i.i
  %promptStack8.i.i = phi ptr [ %promptStack.i.i, %update.i.i ], [ %promptStack4.i.i, %uniqueStack.exit.i ]
  %stack_pointer7.i.i = phi ptr [ %stack_pointer.i3.i, %update.i.i ], [ %stack_pointer3.i.i, %uniqueStack.exit.i ]
  %stack.tr6.i.i = phi ptr [ %next.i1.i, %update.i.i ], [ %start.i, %uniqueStack.exit.i ]
  %isOccupied.not.i.i = icmp eq ptr %promptStack8.i.i, null
  br i1 %isOccupied.not.i.i, label %update.i.i, label %tailrecurse.i.i.i

tailrecurse.i.i.i:                                ; preds = %continue.i.i, %tailrecurse.i.i.i
  %stack.tr.i.i.i = phi ptr [ %next.i.i.i, %tailrecurse.i.i.i ], [ %promptStack8.i.i, %continue.i.i ]
  %prompt_pointer.i.i.i = getelementptr i8, ptr %stack.tr.i.i.i, i64 32
  %next_pointer.i.i.i = getelementptr i8, ptr %stack.tr.i.i.i, i64 40
  %prompt.i.i.i = load ptr, ptr %prompt_pointer.i.i.i, align 8
  %stack_pointer.i.i.i = getelementptr i8, ptr %prompt.i.i.i, i64 8
  store ptr null, ptr %stack_pointer.i.i.i, align 8
  %next.i.i.i = load ptr, ptr %next_pointer.i.i.i, align 8
  %isEnd.i.i.i = icmp eq ptr %next.i.i.i, %promptStack8.i.i
  br i1 %isEnd.i.i.i, label %update.i.i, label %tailrecurse.i.i.i

update.i.i:                                       ; preds = %tailrecurse.i.i.i, %continue.i.i
  store ptr %stack.tr6.i.i, ptr %stack_pointer7.i.i, align 8
  %next_pointer.i.i = getelementptr i8, ptr %stack.tr6.i.i, i64 40
  %next.i1.i = load ptr, ptr %next_pointer.i.i, align 8
  %prompt_pointer.i.i = getelementptr i8, ptr %next.i1.i, i64 32
  %prompt.i2.i = load ptr, ptr %prompt_pointer.i.i, align 8
  %stack_pointer.i3.i = getelementptr i8, ptr %prompt.i2.i, i64 8
  %promptStack.i.i = load ptr, ptr %stack_pointer.i3.i, align 8
  %isThis.i.i = icmp eq ptr %promptStack.i.i, %next.i1.i
  br i1 %isThis.i.i, label %resume.exit, label %continue.i.i

resume.exit:                                      ; preds = %update.i.i, %uniqueStack.exit.i
  %rest_pointer.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  store ptr %stack_73, ptr %rest_pointer.i, align 8
  %stackPointer_pointer.i24 = getelementptr i8, ptr %start.i, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i25 = getelementptr i8, ptr %start.i, i64 24
  %limit.i26 = load ptr, ptr %limit_pointer.i25, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i26
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i27 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i27, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_115 = load ptr, ptr %newStackPointer.i27, align 8, !noalias !0
  musttail call tailcc void %returnAddress_115(%Pos zeroinitializer, ptr %start.i)
  ret void

label_122:                                        ; preds = %entry
  %stackPointer.i29 = load ptr, ptr %stackPointer_pointer.i28, align 8, !alias.scope !0
  %limit_pointer.i30 = getelementptr i8, ptr %stack, i64 24
  %limit.i31 = load ptr, ptr %limit_pointer.i30, align 8, !alias.scope !0
  %isInside.i32 = icmp ule ptr %stackPointer.i29, %limit.i31
  tail call void @llvm.assume(i1 %isInside.i32)
  %newStackPointer.i33 = getelementptr i8, ptr %stackPointer.i29, i64 -24
  store ptr %newStackPointer.i33, ptr %stackPointer_pointer.i28, align 8, !alias.scope !0
  %returnAddress_119 = load ptr, ptr %newStackPointer.i33, align 8, !noalias !0
  musttail call tailcc void %returnAddress_119(i64 %s_4_4515, ptr %stack)
  ret void
}

define tailcc void @step_2_4509(i64 %l_3_4498, i64 %s_4_4515, i64 %tmp_4642, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp eq i64 %l_3_4498, 0
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i, label %label_127, label %label_123

label_123:                                        ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_123
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
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_123, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_123 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %label_123 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i24, align 8
  store i64 %l_3_4498, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_4642_pointer_23 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_4642, ptr %tmp_4642_pointer_23, align 4, !noalias !0
  %returnAddress_pointer_24 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_25 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_26 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_5, ptr %returnAddress_pointer_24, align 8, !noalias !0
  store ptr @sharer_11, ptr %sharer_pointer_25, align 8, !noalias !0
  store ptr @eraser_17, ptr %eraser_pointer_26, align 8, !noalias !0
  %calloc.i.i = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i = getelementptr i8, ptr %stackPointer.i.i, i64 64
  store i64 0, ptr %stack.i, align 8
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
  %stack.repack1.i = getelementptr inbounds i8, ptr %stack.i, i64 8
  store ptr %nextStackPointer.sink.i7, ptr %stack.repack1.i, align 8
  %sharer_pointer_39 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_40 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_28, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_33, ptr %sharer_pointer_39, align 8, !noalias !0
  store ptr @eraser_35, ptr %eraser_pointer_40, align 8, !noalias !0
  musttail call tailcc void @loop_worker_5_19_22_4519(i64 %tmp_4642, i64 %s_4_4515, ptr nonnull %calloc.i.i, ptr nonnull %stack.i)
  ret void

label_127:                                        ; preds = %entry
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i25 = getelementptr i8, ptr %stack, i64 24
  %limit.i26 = load ptr, ptr %limit_pointer.i25, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i26
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i27 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i27, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_124 = load ptr, ptr %newStackPointer.i27, align 8, !noalias !0
  musttail call tailcc void %returnAddress_124(i64 %s_4_4515, ptr %stack)
  ret void
}

define tailcc void @returnAddress_128(i64 %r_2453, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2453)
  tail call void @c_io_println_String(%Pos %z.i)
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_129 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_129(%Pos zeroinitializer, ptr %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3438_3502, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3438_3502, 0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_134 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_135 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_128, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_81, ptr %sharer_pointer_134, align 8, !noalias !0
  store ptr @eraser_83, ptr %eraser_pointer_135, align 8, !noalias !0
  musttail call tailcc void @step_2_4509(i64 1000, i64 0, i64 %unboxed.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_141(%Pos %returned_4684, ptr nocapture %stack) {
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
  %returnAddress_143 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_143(%Pos %returned_4684, ptr %rest.i)
  ret void
}

define void @eraser_157(ptr nocapture readonly %environment) {
entry:
  %tmp_4600_155.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_4600_155.unpack2 = load ptr, ptr %tmp_4600_155.elt1, align 8, !noalias !0
  %acc_3_3_5_169_4161_156.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_4161_156.unpack5 = load ptr, ptr %acc_3_3_5_169_4161_156.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_4600_155.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_4600_155.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_4600_155.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_4600_155.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_4600_155.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_4600_155.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_4161_156.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_4161_156.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_4161_156.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_4161_156.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_4161_156.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_4161_156.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4376(i64 %start_2_2_4_168_4297, %Pos %acc_3_3_5_169_4161, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4297, 1
  br i1 %z.i6, label %label_167, label %label_163

label_163:                                        ; preds = %entry, %label_163
  %acc_3_3_5_169_4161.tr8 = phi %Pos [ %make_4690, %label_163 ], [ %acc_3_3_5_169_4161, %entry ]
  %start_2_2_4_168_4297.tr7 = phi i64 [ %z.i5, %label_163 ], [ %start_2_2_4_168_4297, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4297.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4297.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_157, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_4687.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_4687.elt, ptr %environment.i, align 8, !noalias !0
  %environment_154.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_4687.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_4687.elt2, ptr %environment_154.repack1, align 8, !noalias !0
  %acc_3_3_5_169_4161_pointer_161 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_4161.elt = extractvalue %Pos %acc_3_3_5_169_4161.tr8, 0
  store i64 %acc_3_3_5_169_4161.elt, ptr %acc_3_3_5_169_4161_pointer_161, align 8, !noalias !0
  %acc_3_3_5_169_4161_pointer_161.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_4161.elt4 = extractvalue %Pos %acc_3_3_5_169_4161.tr8, 1
  store ptr %acc_3_3_5_169_4161.elt4, ptr %acc_3_3_5_169_4161_pointer_161.repack3, align 8, !noalias !0
  %make_4690 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4297.tr7, 2
  br i1 %z.i, label %label_167, label %label_163

label_167:                                        ; preds = %label_163, %entry
  %acc_3_3_5_169_4161.tr.lcssa = phi %Pos [ %acc_3_3_5_169_4161, %entry ], [ %make_4690, %label_163 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_164 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_164(%Pos %acc_3_3_5_169_4161.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_178(%Pos %v_r_2597_32_59_223_4301, ptr %stack) {
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
  %acc_8_35_199_4434 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %p_8_9_4126_pointer_181 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %p_8_9_4126 = load ptr, ptr %p_8_9_4126_pointer_181, align 8, !noalias !0
  %index_7_34_198_4242_pointer_182 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %index_7_34_198_4242 = load i64, ptr %index_7_34_198_4242_pointer_182, align 4, !noalias !0
  %tmp_4607_pointer_183 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_4607 = load i64, ptr %tmp_4607_pointer_183, align 4, !noalias !0
  %v_r_2514_30_194_4343_pointer_184 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2514_30_194_4343.unpack = load i64, ptr %v_r_2514_30_194_4343_pointer_184, align 8, !noalias !0
  %v_r_2514_30_194_4343.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2514_30_194_4343.unpack2 = load ptr, ptr %v_r_2514_30_194_4343.elt1, align 8, !noalias !0
  %tag_185 = extractvalue %Pos %v_r_2597_32_59_223_4301, 0
  %fields_186 = extractvalue %Pos %v_r_2597_32_59_223_4301, 1
  switch i64 %tag_185, label %common.ret [
    i64 1, label %label_210
    i64 0, label %label_217
  ]

common.ret:                                       ; preds = %entry
  ret void

label_198:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2514_30_194_4343.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_198
  %referenceCount.i.i37 = load i64, ptr %v_r_2514_30_194_4343.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2514_30_194_4343.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2514_30_194_4343.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2514_30_194_4343.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2514_30_194_4343.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_198, %decr.i.i39, %free.i.i41
  %pair_193 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4126)
  %k_13_14_4_4533 = extractvalue <{ ptr, ptr }> %pair_193, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_4533, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_4533, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_4533, i64 40
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
  %stack_194 = extractvalue <{ ptr, ptr }> %pair_193, 1
  %stackPointer_pointer.i72 = getelementptr i8, ptr %stack_194, i64 8
  %stackPointer.i73 = load ptr, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %limit_pointer.i74 = getelementptr i8, ptr %stack_194, i64 24
  %limit.i75 = load ptr, ptr %limit_pointer.i74, align 8, !alias.scope !0
  %isInside.i76 = icmp ule ptr %stackPointer.i73, %limit.i75
  tail call void @llvm.assume(i1 %isInside.i76)
  %newStackPointer.i77 = getelementptr i8, ptr %stackPointer.i73, i64 -24
  store ptr %newStackPointer.i77, ptr %stackPointer_pointer.i72, align 8, !alias.scope !0
  %returnAddress_195 = load ptr, ptr %newStackPointer.i77, align 8, !noalias !0
  musttail call tailcc void %returnAddress_195(%Pos { i64 5, ptr null }, ptr %stack_194)
  ret void

label_207:                                        ; preds = %label_209
  %isNull.i.i24 = icmp eq ptr %v_r_2514_30_194_4343.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_207
  %referenceCount.i.i26 = load i64, ptr %v_r_2514_30_194_4343.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2514_30_194_4343.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2514_30_194_4343.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2514_30_194_4343.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2514_30_194_4343.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_207, %decr.i.i28, %free.i.i30
  %pair_202 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4126)
  %k_13_14_4_4532 = extractvalue <{ ptr, ptr }> %pair_202, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_4532, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_4532, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4532, i64 40
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
  %stack_203 = extractvalue <{ ptr, ptr }> %pair_202, 1
  %stackPointer_pointer.i102 = getelementptr i8, ptr %stack_203, i64 8
  %stackPointer.i103 = load ptr, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %limit_pointer.i104 = getelementptr i8, ptr %stack_203, i64 24
  %limit.i105 = load ptr, ptr %limit_pointer.i104, align 8, !alias.scope !0
  %isInside.i106 = icmp ule ptr %stackPointer.i103, %limit.i105
  tail call void @llvm.assume(i1 %isInside.i106)
  %newStackPointer.i107 = getelementptr i8, ptr %stackPointer.i103, i64 -24
  store ptr %newStackPointer.i107, ptr %stackPointer_pointer.i102, align 8, !alias.scope !0
  %returnAddress_204 = load ptr, ptr %newStackPointer.i107, align 8, !noalias !0
  musttail call tailcc void %returnAddress_204(%Pos { i64 5, ptr null }, ptr %stack_203)
  ret void

label_208:                                        ; preds = %label_209
  %0 = insertvalue %Pos poison, i64 %v_r_2514_30_194_4343.unpack, 0
  %v_r_2514_30_194_43433 = insertvalue %Pos %0, ptr %v_r_2514_30_194_4343.unpack2, 1
  %z.i = add i64 %index_7_34_198_4242, 1
  %z.i108 = mul i64 %acc_8_35_199_4434, 10
  %z.i109 = sub i64 %z.i108, %tmp_4607
  %z.i110 = add i64 %z.i109, %v_coe_3413_46_73_237_4189.unpack
  musttail call tailcc void @go_6_33_197_4260(i64 %z.i, i64 %z.i110, ptr %p_8_9_4126, i64 %tmp_4607, %Pos %v_r_2514_30_194_43433, ptr nonnull %stack)
  ret void

label_209:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3413_46_73_237_4189.unpack, 58
  br i1 %z.i111, label %label_208, label %label_207

label_210:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_186, i64 16
  %v_coe_3413_46_73_237_4189.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3413_46_73_237_4189.elt4 = getelementptr i8, ptr %fields_186, i64 24
  %v_coe_3413_46_73_237_4189.unpack5 = load ptr, ptr %v_coe_3413_46_73_237_4189.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3413_46_73_237_4189.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_210
  %referenceCount.i.i = load i64, ptr %v_coe_3413_46_73_237_4189.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3413_46_73_237_4189.unpack5, align 4
  br label %next.i10

next.i10:                                         ; preds = %next.i.i, %label_210
  %referenceCount.i11 = load i64, ptr %fields_186, align 4
  %cond.i12 = icmp eq i64 %referenceCount.i11, 0
  br i1 %cond.i12, label %free.i15, label %decr.i13

decr.i13:                                         ; preds = %next.i10
  %referenceCount.1.i14 = add i64 %referenceCount.i11, -1
  store i64 %referenceCount.1.i14, ptr %fields_186, align 4
  br label %eraseObject.exit19

free.i15:                                         ; preds = %next.i10
  %objectEraser.i16 = getelementptr i8, ptr %fields_186, i64 8
  %eraser.i17 = load ptr, ptr %objectEraser.i16, align 8
  tail call void %eraser.i17(ptr nonnull %environment.i8)
  tail call void @free(ptr nonnull %fields_186)
  br label %eraseObject.exit19

eraseObject.exit19:                               ; preds = %decr.i13, %free.i15
  %z.i112 = icmp sgt i64 %v_coe_3413_46_73_237_4189.unpack, 47
  br i1 %z.i112, label %label_209, label %label_198

label_217:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_186, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_217
  %referenceCount.i = load i64, ptr %fields_186, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_186, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_186, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_186, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_186)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_217, %decr.i, %free.i
  %isNull.i.i20 = icmp eq ptr %v_r_2514_30_194_4343.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2514_30_194_4343.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2514_30_194_4343.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2514_30_194_4343.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2514_30_194_4343.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2514_30_194_4343.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_214 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_214(i64 %acc_8_35_199_4434, ptr nonnull %stack)
  ret void
}

define void @sharer_223(ptr %stackPointer) {
entry:
  %v_r_2514_30_194_4343_222.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2514_30_194_4343_222.unpack2 = load ptr, ptr %v_r_2514_30_194_4343_222.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2514_30_194_4343_222.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2514_30_194_4343_222.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2514_30_194_4343_222.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_235(ptr %stackPointer) {
entry:
  %v_r_2514_30_194_4343_234.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2514_30_194_4343_234.unpack2 = load ptr, ptr %v_r_2514_30_194_4343_234.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2514_30_194_4343_234.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2514_30_194_4343_234.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2514_30_194_4343_234.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2514_30_194_4343_234.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2514_30_194_4343_234.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2514_30_194_4343_234.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_252(%Pos %returned_4715, ptr nocapture %stack) {
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
  %returnAddress_254 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_254(%Pos %returned_4715, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_4312_clause_261(ptr %closure, %Pos %exc_8_20_47_211_4284, %Pos %msg_9_21_48_212_4240, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4314 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_264 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4314)
  %k_11_23_50_214_4448 = extractvalue <{ ptr, ptr }> %pair_264, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_4448, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_4448, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_4448, i64 40
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
  %stack_265 = extractvalue <{ ptr, ptr }> %pair_264, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_157, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_20_47_211_4284.elt = extractvalue %Pos %exc_8_20_47_211_4284, 0
  store i64 %exc_8_20_47_211_4284.elt, ptr %environment.i, align 8, !noalias !0
  %environment_267.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_4284.elt2 = extractvalue %Pos %exc_8_20_47_211_4284, 1
  store ptr %exc_8_20_47_211_4284.elt2, ptr %environment_267.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4240_pointer_271 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4240.elt = extractvalue %Pos %msg_9_21_48_212_4240, 0
  store i64 %msg_9_21_48_212_4240.elt, ptr %msg_9_21_48_212_4240_pointer_271, align 8, !noalias !0
  %msg_9_21_48_212_4240_pointer_271.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4240.elt4 = extractvalue %Pos %msg_9_21_48_212_4240, 1
  store ptr %msg_9_21_48_212_4240.elt4, ptr %msg_9_21_48_212_4240_pointer_271.repack3, align 8, !noalias !0
  %make_4716 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_265, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_265, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_273 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_273(%Pos %make_4716, ptr %stack_265)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_280(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_288(ptr nocapture readonly %environment) {
entry:
  %tmp_4609_287.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_4609_287.unpack2 = load ptr, ptr %tmp_4609_287.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_4609_287.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_4609_287.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_4609_287.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_4609_287.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_4609_287.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_4609_287.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_284(i64 %v_coe_3412_6_28_55_219_4278, ptr %stack) {
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
  store ptr @eraser_288, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3412_6_28_55_219_4278, ptr %environment.i, align 8, !noalias !0
  %environment_286.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_286.repack1, align 8, !noalias !0
  %make_4718 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_292 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_292(%Pos %make_4718, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_4260(i64 %index_7_34_198_4242, i64 %acc_8_35_199_4434, ptr %p_8_9_4126, i64 %tmp_4607, %Pos %v_r_2514_30_194_4343, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2514_30_194_4343, 1
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
  store i64 %acc_8_35_199_4434, ptr %common.ret.op.i, align 4, !noalias !0
  %p_8_9_4126_pointer_244 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store ptr %p_8_9_4126, ptr %p_8_9_4126_pointer_244, align 8, !noalias !0
  %index_7_34_198_4242_pointer_245 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_7_34_198_4242, ptr %index_7_34_198_4242_pointer_245, align 4, !noalias !0
  %tmp_4607_pointer_246 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_4607, ptr %tmp_4607_pointer_246, align 4, !noalias !0
  %v_r_2514_30_194_4343_pointer_247 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %v_r_2514_30_194_4343.elt = extractvalue %Pos %v_r_2514_30_194_4343, 0
  store i64 %v_r_2514_30_194_4343.elt, ptr %v_r_2514_30_194_4343_pointer_247, align 8, !noalias !0
  %v_r_2514_30_194_4343_pointer_247.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %object.i3, ptr %v_r_2514_30_194_4343_pointer_247.repack1, align 8, !noalias !0
  %returnAddress_pointer_248 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %sharer_pointer_249 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %eraser_pointer_250 = getelementptr i8, ptr %common.ret.op.i, i64 64
  store ptr @returnAddress_178, ptr %returnAddress_pointer_248, align 8, !noalias !0
  store ptr @sharer_223, ptr %sharer_pointer_249, align 8, !noalias !0
  store ptr @eraser_235, ptr %eraser_pointer_250, align 8, !noalias !0
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
  %sharer_pointer_259 = getelementptr i8, ptr %base.i37, i64 8
  %eraser_pointer_260 = getelementptr i8, ptr %base.i37, i64 16
  store ptr @returnAddress_252, ptr %base.i37, align 8, !noalias !0
  store ptr @sharer_33, ptr %sharer_pointer_259, align 8, !noalias !0
  store ptr @eraser_35, ptr %eraser_pointer_260, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_280, ptr %objectEraser.i, align 8
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
  %Exception_7_19_46_210_4312 = insertvalue %Neg { ptr @vtable_276, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_297 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_298 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_284, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_81, ptr %sharer_pointer_297, align 8, !noalias !0
  store ptr @eraser_83, ptr %eraser_pointer_298, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2514_30_194_4343, i64 %index_7_34_198_4242, %Neg %Exception_7_19_46_210_4312, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_4430_clause_299(ptr %closure, %Pos %exception_10_107_134_298_4719, %Pos %msg_11_108_135_299_4720, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4126 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_4719, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_4720, 1
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
  %pair_302 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4126)
  %k_13_14_4_4590 = extractvalue <{ ptr, ptr }> %pair_302, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_4590, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_4590, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_4590, i64 40
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
  %stack_303 = extractvalue <{ ptr, ptr }> %pair_302, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_303, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_303, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_304 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_304(%Pos { i64 5, ptr null }, ptr %stack_303)
  ret void
}

define tailcc void @returnAddress_318(i64 %v_coe_3417_22_131_158_322_4324, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3417_22_131_158_322_4324, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_319 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_319(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_330(i64 %v_r_2611_1_9_20_129_156_320_4421, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2611_1_9_20_129_156_320_4421
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_331 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_331(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_313(i64 %v_r_2610_3_14_123_150_314_4367, ptr %stack) {
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
  %p_8_9_4126 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %tmp_4607_pointer_316 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_4607 = load i64, ptr %tmp_4607_pointer_316, align 4, !noalias !0
  %v_r_2514_30_194_4343_pointer_317 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2514_30_194_4343.unpack = load i64, ptr %v_r_2514_30_194_4343_pointer_317, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2514_30_194_4343.unpack, 0
  %v_r_2514_30_194_4343.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2514_30_194_4343.unpack2 = load ptr, ptr %v_r_2514_30_194_4343.elt1, align 8, !noalias !0
  %v_r_2514_30_194_43433 = insertvalue %Pos %0, ptr %v_r_2514_30_194_4343.unpack2, 1
  %z.i = icmp eq i64 %v_r_2610_3_14_123_150_314_4367, 45
  %isInside.not.i = icmp ugt ptr %v_r_2514_30_194_4343.elt1, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %v_r_2514_30_194_4343.elt1, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_324 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_325 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_318, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_81, ptr %sharer_pointer_324, align 8, !noalias !0
  store ptr @eraser_83, ptr %eraser_pointer_325, align 8, !noalias !0
  br i1 %z.i, label %label_338, label %label_329

label_329:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_4260(i64 0, i64 0, ptr %p_8_9_4126, i64 %tmp_4607, %Pos %v_r_2514_30_194_43433, ptr nonnull %stack)
  ret void

label_338:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i17 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i18 = icmp ugt ptr %nextStackPointer.i17, %limit.i16
  br i1 %isInside.not.i18, label %realloc.i21, label %stackAllocate.exit35

realloc.i21:                                      ; preds = %label_338
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

stackAllocate.exit35:                             ; preds = %label_338, %realloc.i21
  %nextStackPointer.sink.i19 = phi ptr [ %newNextStackPointer.i34, %realloc.i21 ], [ %nextStackPointer.i17, %label_338 ]
  %common.ret.op.i20 = phi ptr [ %newStackPointer.i33, %realloc.i21 ], [ %nextStackPointer.sink.i, %label_338 ]
  store ptr %nextStackPointer.sink.i19, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_336 = getelementptr i8, ptr %common.ret.op.i20, i64 8
  %eraser_pointer_337 = getelementptr i8, ptr %common.ret.op.i20, i64 16
  store ptr @returnAddress_330, ptr %common.ret.op.i20, align 8, !noalias !0
  store ptr @sharer_81, ptr %sharer_pointer_336, align 8, !noalias !0
  store ptr @eraser_83, ptr %eraser_pointer_337, align 8, !noalias !0
  musttail call tailcc void @go_6_33_197_4260(i64 1, i64 0, ptr %p_8_9_4126, i64 %tmp_4607, %Pos %v_r_2514_30_194_43433, ptr nonnull %stack)
  ret void
}

define void @sharer_342(ptr %stackPointer) {
entry:
  %v_r_2514_30_194_4343_341.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2514_30_194_4343_341.unpack2 = load ptr, ptr %v_r_2514_30_194_4343_341.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2514_30_194_4343_341.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2514_30_194_4343_341.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2514_30_194_4343_341.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_350(ptr %stackPointer) {
entry:
  %v_r_2514_30_194_4343_349.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2514_30_194_4343_349.unpack2 = load ptr, ptr %v_r_2514_30_194_4343_349.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2514_30_194_4343_349.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2514_30_194_4343_349.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2514_30_194_4343_349.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2514_30_194_4343_349.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2514_30_194_4343_349.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2514_30_194_4343_349.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_175(%Pos %v_r_2514_30_194_4343, ptr %stack) {
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
  %p_8_9_4126 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_280, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4126, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2514_30_194_4343, 1
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
  store ptr %p_8_9_4126, ptr %common.ret.op.i, align 8, !noalias !0
  %tmp_4607_pointer_357 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 48, ptr %tmp_4607_pointer_357, align 4, !noalias !0
  %v_r_2514_30_194_4343_pointer_358 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %v_r_2514_30_194_4343.elt = extractvalue %Pos %v_r_2514_30_194_4343, 0
  store i64 %v_r_2514_30_194_4343.elt, ptr %v_r_2514_30_194_4343_pointer_358, align 8, !noalias !0
  %v_r_2514_30_194_4343_pointer_358.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %object.i3, ptr %v_r_2514_30_194_4343_pointer_358.repack1, align 8, !noalias !0
  %returnAddress_pointer_359 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %sharer_pointer_360 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %eraser_pointer_361 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store ptr @returnAddress_313, ptr %returnAddress_pointer_359, align 8, !noalias !0
  store ptr @sharer_342, ptr %sharer_pointer_360, align 8, !noalias !0
  store ptr @eraser_350, ptr %eraser_pointer_361, align 8, !noalias !0
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
  store i64 %v_r_2514_30_194_4343.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_456.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_456.repack1.i, align 8, !noalias !0
  %index_2107_pointer_458.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_458.i, align 4, !noalias !0
  %Exception_2362_pointer_459.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_307, ptr %Exception_2362_pointer_459.i, align 8, !noalias !0
  %Exception_2362_pointer_459.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_459.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_460.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_461.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_462.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_422, ptr %returnAddress_pointer_460.i, align 8, !noalias !0
  store ptr @sharer_443, ptr %sharer_pointer_461.i, align 8, !noalias !0
  store ptr @eraser_451, ptr %eraser_pointer_462.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2514_30_194_4343)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_466.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_466.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
  ret void
}

define void @sharer_363(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_367(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_172(%Pos %v_r_2513_24_188_4320, ptr %stack) {
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
  %p_8_9_4126 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4126, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_373 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_374 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_175, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_363, ptr %sharer_pointer_373, align 8, !noalias !0
  store ptr @eraser_367, ptr %eraser_pointer_374, align 8, !noalias !0
  %tag_375 = extractvalue %Pos %v_r_2513_24_188_4320, 0
  switch i64 %tag_375, label %label_377 [
    i64 0, label %label_381
    i64 1, label %label_387
  ]

label_377:                                        ; preds = %stackAllocate.exit
  ret void

label_381:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_4735 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_4735.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_378 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_378(%Pos %utf8StringLiteral_4735, ptr nonnull %stack)
  ret void

label_387:                                        ; preds = %stackAllocate.exit
  %fields_376 = extractvalue %Pos %v_r_2513_24_188_4320, 1
  %environment.i = getelementptr i8, ptr %fields_376, i64 16
  %v_y_3239_8_29_193_4355.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3239_8_29_193_4355.elt1 = getelementptr i8, ptr %fields_376, i64 24
  %v_y_3239_8_29_193_4355.unpack2 = load ptr, ptr %v_y_3239_8_29_193_4355.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3239_8_29_193_4355.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_387
  %referenceCount.i.i = load i64, ptr %v_y_3239_8_29_193_4355.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3239_8_29_193_4355.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_387
  %referenceCount.i = load i64, ptr %fields_376, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_376, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_376, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_376)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3239_8_29_193_4355.unpack, 0
  %v_y_3239_8_29_193_43553 = insertvalue %Pos %0, ptr %v_y_3239_8_29_193_4355.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_384 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_384(%Pos %v_y_3239_8_29_193_43553, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_169(%Pos %v_r_2512_13_177_4372, ptr %stack) {
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
  %p_8_9_4126 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4126, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_393 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_394 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_172, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_363, ptr %sharer_pointer_393, align 8, !noalias !0
  store ptr @eraser_367, ptr %eraser_pointer_394, align 8, !noalias !0
  %tag_395 = extractvalue %Pos %v_r_2512_13_177_4372, 0
  switch i64 %tag_395, label %label_397 [
    i64 0, label %label_402
    i64 1, label %label_414
  ]

label_397:                                        ; preds = %stackAllocate.exit
  ret void

label_402:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4126, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_175, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_363, ptr %sharer_pointer_393, align 8, !noalias !0
  store ptr @eraser_367, ptr %eraser_pointer_394, align 8, !noalias !0
  %utf8StringLiteral_4735.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_4735.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_378.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_378.i(%Pos %utf8StringLiteral_4735.i, ptr nonnull %stack)
  ret void

label_414:                                        ; preds = %stackAllocate.exit
  %fields_396 = extractvalue %Pos %v_r_2512_13_177_4372, 1
  %environment.i6 = getelementptr i8, ptr %fields_396, i64 16
  %v_y_2748_10_21_185_4215.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_2748_10_21_185_4215.elt1 = getelementptr i8, ptr %fields_396, i64 24
  %v_y_2748_10_21_185_4215.unpack2 = load ptr, ptr %v_y_2748_10_21_185_4215.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2748_10_21_185_4215.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_414
  %referenceCount.i.i = load i64, ptr %v_y_2748_10_21_185_4215.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2748_10_21_185_4215.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_414
  %referenceCount.i = load i64, ptr %fields_396, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_396, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i8 = getelementptr i8, ptr %fields_396, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i8, align 8
  tail call void %eraser.i(ptr nonnull %environment.i6)
  tail call void @free(ptr nonnull %fields_396)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_288, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2748_10_21_185_4215.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_407.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2748_10_21_185_4215.unpack2, ptr %environment_407.repack4, align 8, !noalias !0
  %make_4737 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_411 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_411(%Pos %make_4737, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2443(ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_138 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_139 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_81, ptr %sharer_pointer_138, align 8, !noalias !0
  store ptr @eraser_83, ptr %eraser_pointer_139, align 8, !noalias !0
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
  %sharer_pointer_148 = getelementptr i8, ptr %common.ret.op.i8, i64 8
  %eraser_pointer_149 = getelementptr i8, ptr %common.ret.op.i8, i64 16
  store ptr @returnAddress_141, ptr %common.ret.op.i8, align 8, !noalias !0
  store ptr @sharer_33, ptr %sharer_pointer_148, align 8, !noalias !0
  store ptr @eraser_35, ptr %eraser_pointer_149, align 8, !noalias !0
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
  %returnAddress_pointer_419 = getelementptr i8, ptr %common.ret.op.i31, i64 8
  %sharer_pointer_420 = getelementptr i8, ptr %common.ret.op.i31, i64 16
  %eraser_pointer_421 = getelementptr i8, ptr %common.ret.op.i31, i64 24
  store ptr @returnAddress_169, ptr %returnAddress_pointer_419, align 8, !noalias !0
  store ptr @sharer_363, ptr %sharer_pointer_420, align 8, !noalias !0
  store ptr @eraser_367, ptr %eraser_pointer_421, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_167.i, label %label_163.i

label_163.i:                                      ; preds = %stackAllocate.exit46, %label_163.i
  %acc_3_3_5_169_4161.tr8.i = phi %Pos [ %make_4690.i, %label_163.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4297.tr7.i = phi i64 [ %z.i5.i, %label_163.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4297.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4297.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_157, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_4687.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_4687.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_154.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_4687.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_4687.elt2.i, ptr %environment_154.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_4161_pointer_161.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_4161.elt.i = extractvalue %Pos %acc_3_3_5_169_4161.tr8.i, 0
  store i64 %acc_3_3_5_169_4161.elt.i, ptr %acc_3_3_5_169_4161_pointer_161.i, align 8, !noalias !0
  %acc_3_3_5_169_4161_pointer_161.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_4161.elt4.i = extractvalue %Pos %acc_3_3_5_169_4161.tr8.i, 1
  store ptr %acc_3_3_5_169_4161.elt4.i, ptr %acc_3_3_5_169_4161_pointer_161.repack3.i, align 8, !noalias !0
  %make_4690.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4297.tr7.i, 2
  br i1 %z.i.i, label %label_167.i.loopexit, label %label_163.i

label_167.i.loopexit:                             ; preds = %label_163.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_167.i

label_167.i:                                      ; preds = %label_167.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_167.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_167.i.loopexit ]
  %acc_3_3_5_169_4161.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_4690.i, %label_167.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_164.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_164.i(%Pos %acc_3_3_5_169_4161.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_422(%Pos %v_r_2679_3469, ptr %stack) {
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
  %index_2107_pointer_425 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_425, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_427 = extractvalue %Pos %v_r_2679_3469, 0
  switch i64 %tag_427, label %label_429 [
    i64 0, label %label_433
    i64 1, label %label_439
  ]

label_429:                                        ; preds = %entry
  ret void

label_433:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_433
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

eraseNegative.exit:                               ; preds = %label_433, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_430 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_430(i64 %x.i, ptr nonnull %stack)
  ret void

label_439:                                        ; preds = %entry
  %Exception_2362_pointer_426 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_426, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_4649 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_4649.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_4649, %Pos %z.i)
  %utf8StringLiteral_4651 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_4651.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_4651)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_4654 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_4654.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_4654)
  %functionPointer_438 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_438(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_443(ptr %stackPointer) {
entry:
  %str_2106_440.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_440.unpack2 = load ptr, ptr %str_2106_440.elt1, align 8, !noalias !0
  %Exception_2362_442.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_442.unpack5 = load ptr, ptr %Exception_2362_442.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_440.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_440.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_440.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_442.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_442.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_442.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_451(ptr %stackPointer) {
entry:
  %str_2106_448.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_448.unpack2 = load ptr, ptr %str_2106_448.elt1, align 8, !noalias !0
  %Exception_2362_450.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_450.unpack5 = load ptr, ptr %Exception_2362_450.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_448.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_448.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_448.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_448.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_448.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_448.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_450.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_450.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_450.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_450.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_450.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_450.unpack5)
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
  %stackPointer_456.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_456.repack1, align 8, !noalias !0
  %index_2107_pointer_458 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_458, align 4, !noalias !0
  %Exception_2362_pointer_459 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_459, align 8, !noalias !0
  %Exception_2362_pointer_459.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_459.repack3, align 8, !noalias !0
  %returnAddress_pointer_460 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_461 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_462 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_422, ptr %returnAddress_pointer_460, align 8, !noalias !0
  store ptr @sharer_443, ptr %sharer_pointer_461, align 8, !noalias !0
  store ptr @eraser_451, ptr %eraser_pointer_462, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_469, label %label_474

label_469:                                        ; preds = %stackAllocate.exit
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
  %returnAddress_466 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_466(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_474:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_474
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

erasePositive.exit:                               ; preds = %label_474, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_471 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_471(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  tail call tailcc void @main_2443(ptr nonnull %stack.i2.i.i)
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
  musttail call tailcc void @main_2443(ptr nonnull %stack.i2.i)
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
