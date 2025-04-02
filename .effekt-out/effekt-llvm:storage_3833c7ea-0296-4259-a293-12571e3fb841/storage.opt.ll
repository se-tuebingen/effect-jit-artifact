; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:storage_3833c7ea-0296-4259-a293-12571e3fb841/storage.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:storage_3833c7ea-0296-4259-a293-12571e3fb841/storage.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@global = private global { i64, ptr } zeroinitializer
@vtable_194 = private constant [1 x ptr] [ptr @Exception_7_19_46_210_4958_clause_179]
@vtable_225 = private constant [1 x ptr] [ptr @Exception_9_106_133_297_4825_clause_217]
@utf8StringLiteral_5349.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_5234.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_5236.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_5239.lit = private constant [1 x i8] c"'"

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
  store ptr %stack.i2.i, ptr getelementptr inbounds (i8, ptr @global, i64 8), align 8
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
  store ptr %stack.i2.i, ptr getelementptr inbounds (i8, ptr @global, i64 8), align 8
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
  store ptr %stack.i2.i, ptr getelementptr inbounds (i8, ptr @global, i64 8), align 8
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

define %Pos @allocate_2473(i64 %size_2472) local_unnamed_addr {
  %z = tail call %Pos @c_array_new(i64 %size_2472)
  ret %Pos %z
}

define tailcc void @returnAddress_10(i64 %v_r_2970_2_5096, ptr %stack) {
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
  %i_6_5090 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %tmp_5218_pointer_13 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5218 = load i64, ptr %tmp_5218_pointer_13, align 4, !noalias !0
  %z.i = add i64 %i_6_5090, 1
  %z.i.i = icmp slt i64 %z.i, %tmp_5218
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
  %tmp_5218_pointer_28.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %tmp_5218, ptr %tmp_5218_pointer_28.i, align 4, !noalias !0
  %sharer_pointer_30.i = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_31.i = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_10, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30.i, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31.i, align 8, !noalias !0
  musttail call tailcc void @run_2861(i64 7, ptr nonnull %stack)
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

define tailcc void @loop_5_5089(i64 %i_6_5090, i64 %tmp_5218, ptr %stack) local_unnamed_addr {
entry:
  %z.i = icmp slt i64 %i_6_5090, %tmp_5218
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
  store i64 %i_6_5090, ptr %common.ret.op.i, align 4, !noalias !0
  %tmp_5218_pointer_28 = getelementptr i8, ptr %common.ret.op.i, i64 8
  store i64 %tmp_5218, ptr %tmp_5218_pointer_28, align 4, !noalias !0
  %returnAddress_pointer_29 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_30 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_31 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31, align 8, !noalias !0
  musttail call tailcc void @run_2861(i64 7, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_34(i64 %r_2888, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %r_2888)
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

define tailcc void @returnAddress_33(%Pos %v_r_2972_5293, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %v_r_2972_5293, 1
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
  musttail call tailcc void @run_2861(i64 7, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_4006_4070, ptr %stack) {
stackAllocate.exit:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_4006_4070, 0
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
  musttail call tailcc void @run_2861(i64 7, ptr nonnull %stack)
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
  %tmp_5218_pointer_28.i = getelementptr i8, ptr %common.ret.op.i.i, i64 8
  store i64 %z.i, ptr %tmp_5218_pointer_28.i, align 4, !noalias !0
  %returnAddress_pointer_29.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %sharer_pointer_30.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  %eraser_pointer_31.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr @returnAddress_10, ptr %returnAddress_pointer_29.i, align 8, !noalias !0
  store ptr @sharer_16, ptr %sharer_pointer_30.i, align 8, !noalias !0
  store ptr @eraser_22, ptr %eraser_pointer_31.i, align 8, !noalias !0
  musttail call tailcc void @run_2861(i64 7, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_55(%Pos %returned_5298, ptr nocapture %stack) {
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
  musttail call tailcc void %returnAddress_57(%Pos %returned_5298, ptr %rest.i)
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
  %tmp_5191_73.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5191_73.unpack2 = load ptr, ptr %tmp_5191_73.elt1, align 8, !noalias !0
  %acc_3_3_5_169_4982_74.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_169_4982_74.unpack5 = load ptr, ptr %acc_3_3_5_169_4982_74.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_5191_73.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_5191_73.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_5191_73.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_5191_73.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_5191_73.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_5191_73.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_169_4982_74.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_169_4982_74.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_169_4982_74.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_169_4982_74.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_169_4982_74.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_169_4982_74.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_167_4926(i64 %start_2_2_4_168_4959, %Pos %acc_3_3_5_169_4982, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_168_4959, 1
  br i1 %z.i6, label %label_85, label %label_81

label_81:                                         ; preds = %entry, %label_81
  %acc_3_3_5_169_4982.tr8 = phi %Pos [ %make_5304, %label_81 ], [ %acc_3_3_5_169_4982, %entry ]
  %start_2_2_4_168_4959.tr7 = phi i64 [ %z.i5, %label_81 ], [ %start_2_2_4_168_4959, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4959.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_168_4959.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_75, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5301.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_5301.elt, ptr %environment.i, align 8, !noalias !0
  %environment_72.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5301.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_5301.elt2, ptr %environment_72.repack1, align 8, !noalias !0
  %acc_3_3_5_169_4982_pointer_79 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_169_4982.elt = extractvalue %Pos %acc_3_3_5_169_4982.tr8, 0
  store i64 %acc_3_3_5_169_4982.elt, ptr %acc_3_3_5_169_4982_pointer_79, align 8, !noalias !0
  %acc_3_3_5_169_4982_pointer_79.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_169_4982.elt4 = extractvalue %Pos %acc_3_3_5_169_4982.tr8, 1
  store ptr %acc_3_3_5_169_4982.elt4, ptr %acc_3_3_5_169_4982_pointer_79.repack3, align 8, !noalias !0
  %make_5304 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_168_4959.tr7, 2
  br i1 %z.i, label %label_85, label %label_81

label_85:                                         ; preds = %label_81, %entry
  %acc_3_3_5_169_4982.tr.lcssa = phi %Pos [ %acc_3_3_5_169_4982, %entry ], [ %make_5304, %label_81 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_82 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_82(%Pos %acc_3_3_5_169_4982.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_96(%Pos %v_r_3157_32_59_223_4793, ptr %stack) {
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
  %v_r_2967_30_194_4829.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2967_30_194_4829.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_2967_30_194_4829.unpack2 = load ptr, ptr %v_r_2967_30_194_4829.elt1, align 8, !noalias !0
  %p_8_9_4719_pointer_99 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %p_8_9_4719 = load ptr, ptr %p_8_9_4719_pointer_99, align 8, !noalias !0
  %tmp_5198_pointer_100 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %tmp_5198 = load i64, ptr %tmp_5198_pointer_100, align 4, !noalias !0
  %acc_8_35_199_4795_pointer_101 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %acc_8_35_199_4795 = load i64, ptr %acc_8_35_199_4795_pointer_101, align 4, !noalias !0
  %index_7_34_198_4909_pointer_102 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %index_7_34_198_4909 = load i64, ptr %index_7_34_198_4909_pointer_102, align 4, !noalias !0
  %tag_103 = extractvalue %Pos %v_r_3157_32_59_223_4793, 0
  %fields_104 = extractvalue %Pos %v_r_3157_32_59_223_4793, 1
  switch i64 %tag_103, label %common.ret [
    i64 1, label %label_128
    i64 0, label %label_135
  ]

common.ret:                                       ; preds = %entry
  ret void

label_116:                                        ; preds = %eraseObject.exit19
  %isNull.i.i35 = icmp eq ptr %v_r_2967_30_194_4829.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %label_116
  %referenceCount.i.i37 = load i64, ptr %v_r_2967_30_194_4829.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2967_30_194_4829.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2967_30_194_4829.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2967_30_194_4829.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2967_30_194_4829.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %label_116, %decr.i.i39, %free.i.i41
  %pair_111 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4719)
  %k_13_14_4_5103 = extractvalue <{ ptr, ptr }> %pair_111, 0
  %referenceCount.i51 = load i64, ptr %k_13_14_4_5103, align 4
  %cond.i52 = icmp eq i64 %referenceCount.i51, 0
  br i1 %cond.i52, label %free.i55, label %decr.i53

decr.i53:                                         ; preds = %erasePositive.exit45
  %referenceCount.1.i54 = add i64 %referenceCount.i51, -1
  store i64 %referenceCount.1.i54, ptr %k_13_14_4_5103, align 4
  br label %eraseResumption.exit58

free.i55:                                         ; preds = %erasePositive.exit45
  %stack_pointer.i56 = getelementptr i8, ptr %k_13_14_4_5103, i64 40
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
  %isNull.i.i24 = icmp eq ptr %v_r_2967_30_194_4829.unpack2, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %label_125
  %referenceCount.i.i26 = load i64, ptr %v_r_2967_30_194_4829.unpack2, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2967_30_194_4829.unpack2, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2967_30_194_4829.unpack2, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2967_30_194_4829.unpack2, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2967_30_194_4829.unpack2)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %label_125, %decr.i.i28, %free.i.i30
  %pair_120 = tail call <{ ptr, ptr }> @shift(ptr nonnull %stack, ptr %p_8_9_4719)
  %k_13_14_4_5102 = extractvalue <{ ptr, ptr }> %pair_120, 0
  %referenceCount.i46 = load i64, ptr %k_13_14_4_5102, align 4
  %cond.i47 = icmp eq i64 %referenceCount.i46, 0
  br i1 %cond.i47, label %free.i50, label %decr.i48

decr.i48:                                         ; preds = %erasePositive.exit34
  %referenceCount.1.i49 = add i64 %referenceCount.i46, -1
  store i64 %referenceCount.1.i49, ptr %k_13_14_4_5102, align 4
  br label %eraseResumption.exit

free.i50:                                         ; preds = %erasePositive.exit34
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5102, i64 40
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
  %0 = insertvalue %Pos poison, i64 %v_r_2967_30_194_4829.unpack, 0
  %v_r_2967_30_194_48293 = insertvalue %Pos %0, ptr %v_r_2967_30_194_4829.unpack2, 1
  %z.i = add i64 %index_7_34_198_4909, 1
  %z.i108 = mul i64 %acc_8_35_199_4795, 10
  %z.i109 = sub i64 %z.i108, %tmp_5198
  %z.i110 = add i64 %z.i109, %v_coe_3975_46_73_237_4981.unpack
  musttail call tailcc void @go_6_33_197_4889(i64 %z.i, i64 %z.i110, %Pos %v_r_2967_30_194_48293, ptr %p_8_9_4719, i64 %tmp_5198, ptr nonnull %stack)
  ret void

label_127:                                        ; preds = %eraseObject.exit19
  %z.i111 = icmp ult i64 %v_coe_3975_46_73_237_4981.unpack, 58
  br i1 %z.i111, label %label_126, label %label_125

label_128:                                        ; preds = %entry
  %environment.i8 = getelementptr i8, ptr %fields_104, i64 16
  %v_coe_3975_46_73_237_4981.unpack = load i64, ptr %environment.i8, align 8, !noalias !0
  %v_coe_3975_46_73_237_4981.elt4 = getelementptr i8, ptr %fields_104, i64 24
  %v_coe_3975_46_73_237_4981.unpack5 = load ptr, ptr %v_coe_3975_46_73_237_4981.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3975_46_73_237_4981.unpack5, null
  br i1 %isNull.i.i, label %next.i10, label %next.i.i

next.i.i:                                         ; preds = %label_128
  %referenceCount.i.i = load i64, ptr %v_coe_3975_46_73_237_4981.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3975_46_73_237_4981.unpack5, align 4
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
  %z.i112 = icmp sgt i64 %v_coe_3975_46_73_237_4981.unpack, 47
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
  %isNull.i.i20 = icmp eq ptr %v_r_2967_30_194_4829.unpack2, null
  br i1 %isNull.i.i20, label %erasePositive.exit, label %next.i.i21

next.i.i21:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i22 = load i64, ptr %v_r_2967_30_194_4829.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i22, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i21
  %referenceCount.1.i.i23 = add i64 %referenceCount.i.i22, -1
  store i64 %referenceCount.1.i.i23, ptr %v_r_2967_30_194_4829.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i21
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2967_30_194_4829.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2967_30_194_4829.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2967_30_194_4829.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %stackPointer.i116 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i118 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i119 = icmp ule ptr %stackPointer.i116, %limit.i118
  tail call void @llvm.assume(i1 %isInside.i119)
  %newStackPointer.i120 = getelementptr i8, ptr %stackPointer.i116, i64 -24
  store ptr %newStackPointer.i120, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_132 = load ptr, ptr %newStackPointer.i120, align 8, !noalias !0
  musttail call tailcc void %returnAddress_132(i64 %acc_8_35_199_4795, ptr nonnull %stack)
  ret void
}

define void @sharer_141(ptr %stackPointer) {
entry:
  %v_r_2967_30_194_4829_136.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_r_2967_30_194_4829_136.unpack2 = load ptr, ptr %v_r_2967_30_194_4829_136.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2967_30_194_4829_136.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2967_30_194_4829_136.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2967_30_194_4829_136.unpack2, align 4
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
  %v_r_2967_30_194_4829_148.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_r_2967_30_194_4829_148.unpack2 = load ptr, ptr %v_r_2967_30_194_4829_148.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2967_30_194_4829_148.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2967_30_194_4829_148.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2967_30_194_4829_148.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2967_30_194_4829_148.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2967_30_194_4829_148.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2967_30_194_4829_148.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_170(%Pos %returned_5329, ptr nocapture %stack) {
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
  musttail call tailcc void %returnAddress_172(%Pos %returned_5329, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_19_46_210_4958_clause_179(ptr %closure, %Pos %exc_8_20_47_211_4893, %Pos %msg_9_21_48_212_4757, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_18_45_209_4976 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_182 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_18_45_209_4976)
  %k_11_23_50_214_5044 = extractvalue <{ ptr, ptr }> %pair_182, 0
  %referenceCount.i7 = load i64, ptr %k_11_23_50_214_5044, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_23_50_214_5044, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_23_50_214_5044, i64 40
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
  %exc_8_20_47_211_4893.elt = extractvalue %Pos %exc_8_20_47_211_4893, 0
  store i64 %exc_8_20_47_211_4893.elt, ptr %environment.i, align 8, !noalias !0
  %environment_185.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_20_47_211_4893.elt2 = extractvalue %Pos %exc_8_20_47_211_4893, 1
  store ptr %exc_8_20_47_211_4893.elt2, ptr %environment_185.repack1, align 8, !noalias !0
  %msg_9_21_48_212_4757_pointer_189 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_21_48_212_4757.elt = extractvalue %Pos %msg_9_21_48_212_4757, 0
  store i64 %msg_9_21_48_212_4757.elt, ptr %msg_9_21_48_212_4757_pointer_189, align 8, !noalias !0
  %msg_9_21_48_212_4757_pointer_189.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_21_48_212_4757.elt4 = extractvalue %Pos %msg_9_21_48_212_4757, 1
  store ptr %msg_9_21_48_212_4757.elt4, ptr %msg_9_21_48_212_4757_pointer_189.repack3, align 8, !noalias !0
  %make_5330 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_183, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_183, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_191 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_191(%Pos %make_5330, ptr %stack_183)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_198(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define void @eraser_206(ptr nocapture readonly %environment) {
entry:
  %tmp_5200_205.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5200_205.unpack2 = load ptr, ptr %tmp_5200_205.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %tmp_5200_205.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %tmp_5200_205.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %tmp_5200_205.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %tmp_5200_205.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %tmp_5200_205.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %tmp_5200_205.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_202(i64 %v_coe_3974_6_28_55_219_4987, ptr %stack) {
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
  store i64 %v_coe_3974_6_28_55_219_4987, ptr %environment.i, align 8, !noalias !0
  %environment_204.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_204.repack1, align 8, !noalias !0
  %make_5332 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_210 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_210(%Pos %make_5332, ptr %stack)
  ret void
}

define tailcc void @go_6_33_197_4889(i64 %index_7_34_198_4909, i64 %acc_8_35_199_4795, %Pos %v_r_2967_30_194_4829, ptr %p_8_9_4719, i64 %tmp_5198, ptr %stack) local_unnamed_addr {
entry:
  %object.i3 = extractvalue %Pos %v_r_2967_30_194_4829, 1
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
  %v_r_2967_30_194_4829.elt = extractvalue %Pos %v_r_2967_30_194_4829, 0
  store i64 %v_r_2967_30_194_4829.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_160.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i3, ptr %stackPointer_160.repack1, align 8, !noalias !0
  %p_8_9_4719_pointer_162 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %p_8_9_4719, ptr %p_8_9_4719_pointer_162, align 8, !noalias !0
  %tmp_5198_pointer_163 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %tmp_5198, ptr %tmp_5198_pointer_163, align 4, !noalias !0
  %acc_8_35_199_4795_pointer_164 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %acc_8_35_199_4795, ptr %acc_8_35_199_4795_pointer_164, align 4, !noalias !0
  %index_7_34_198_4909_pointer_165 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store i64 %index_7_34_198_4909, ptr %index_7_34_198_4909_pointer_165, align 4, !noalias !0
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
  %Exception_7_19_46_210_4958 = insertvalue %Neg { ptr @vtable_194, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i33, ptr %stack.repack1.i, align 8
  %sharer_pointer_215 = getelementptr i8, ptr %common.ret.op.i34, i64 8
  %eraser_pointer_216 = getelementptr i8, ptr %common.ret.op.i34, i64 16
  store ptr @returnAddress_202, ptr %common.ret.op.i34, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_215, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_216, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %v_r_2967_30_194_4829, i64 %index_7_34_198_4909, %Neg %Exception_7_19_46_210_4958, ptr nonnull %stack.i)
  ret void
}

define tailcc void @Exception_9_106_133_297_4825_clause_217(ptr %closure, %Pos %exception_10_107_134_298_5333, %Pos %msg_11_108_135_299_5334, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4719 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_107_134_298_5333, 1
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
  %object.i = extractvalue %Pos %msg_11_108_135_299_5334, 1
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
  %pair_220 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4719)
  %k_13_14_4_5167 = extractvalue <{ ptr, ptr }> %pair_220, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4_5167, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4_5167, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_5167, i64 40
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

define tailcc void @returnAddress_236(i64 %v_coe_3979_22_131_158_322_4896, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3979_22_131_158_322_4896, 0
  %boxed2.i2 = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_237 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_237(%Pos %boxed2.i2, ptr %stack)
  ret void
}

define tailcc void @returnAddress_248(i64 %v_r_3171_1_9_20_129_156_320_4794, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_3171_1_9_20_129_156_320_4794
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_249 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_249(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_231(i64 %v_r_3170_3_14_123_150_314_5007, ptr %stack) {
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
  %v_r_2967_30_194_4829.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %v_r_2967_30_194_4829.unpack, 0
  %v_r_2967_30_194_4829.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2967_30_194_4829.unpack2 = load ptr, ptr %v_r_2967_30_194_4829.elt1, align 8, !noalias !0
  %v_r_2967_30_194_48293 = insertvalue %Pos %0, ptr %v_r_2967_30_194_4829.unpack2, 1
  %p_8_9_4719_pointer_234 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %p_8_9_4719 = load ptr, ptr %p_8_9_4719_pointer_234, align 8, !noalias !0
  %tmp_5198_pointer_235 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %tmp_5198 = load i64, ptr %tmp_5198_pointer_235, align 4, !noalias !0
  %z.i = icmp eq i64 %v_r_3170_3_14_123_150_314_5007, 45
  %isInside.not.i = icmp ugt ptr %tmp_5198_pointer_235, %limit.i
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %tmp_5198_pointer_235, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_242 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_243 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_236, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_242, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_243, align 8, !noalias !0
  br i1 %z.i, label %label_256, label %label_247

label_247:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_6_33_197_4889(i64 0, i64 0, %Pos %v_r_2967_30_194_48293, ptr %p_8_9_4719, i64 %tmp_5198, ptr nonnull %stack)
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
  musttail call tailcc void @go_6_33_197_4889(i64 1, i64 0, %Pos %v_r_2967_30_194_48293, ptr %p_8_9_4719, i64 %tmp_5198, ptr nonnull %stack)
  ret void
}

define void @sharer_260(ptr %stackPointer) {
entry:
  %v_r_2967_30_194_4829_257.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2967_30_194_4829_257.unpack2 = load ptr, ptr %v_r_2967_30_194_4829_257.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2967_30_194_4829_257.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2967_30_194_4829_257.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2967_30_194_4829_257.unpack2, align 4
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
  %v_r_2967_30_194_4829_265.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2967_30_194_4829_265.unpack2 = load ptr, ptr %v_r_2967_30_194_4829_265.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2967_30_194_4829_265.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2967_30_194_4829_265.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2967_30_194_4829_265.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2967_30_194_4829_265.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2967_30_194_4829_265.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2967_30_194_4829_265.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -40
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_93(%Pos %v_r_2967_30_194_4829, ptr %stack) {
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
  %p_8_9_4719 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_198, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %p_8_9_4719, ptr %environment.i, align 8, !noalias !0
  %object.i3 = extractvalue %Pos %v_r_2967_30_194_4829, 1
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
  %v_r_2967_30_194_4829.elt = extractvalue %Pos %v_r_2967_30_194_4829, 0
  store i64 %v_r_2967_30_194_4829.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_273.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i3, ptr %stackPointer_273.repack1, align 8, !noalias !0
  %p_8_9_4719_pointer_275 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %p_8_9_4719, ptr %p_8_9_4719_pointer_275, align 8, !noalias !0
  %tmp_5198_pointer_276 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 48, ptr %tmp_5198_pointer_276, align 4, !noalias !0
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
  store i64 %v_r_2967_30_194_4829.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_701.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i3, ptr %stackPointer_701.repack1.i, align 8, !noalias !0
  %index_2107_pointer_703.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_703.i, align 4, !noalias !0
  %Exception_2362_pointer_704.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_225, ptr %Exception_2362_pointer_704.i, align 8, !noalias !0
  %Exception_2362_pointer_704.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_704.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_705.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_706.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_707.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_667, ptr %returnAddress_pointer_705.i, align 8, !noalias !0
  store ptr @sharer_688, ptr %sharer_pointer_706.i, align 8, !noalias !0
  store ptr @eraser_696, ptr %eraser_pointer_707.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %v_r_2967_30_194_4829)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_711.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_711.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack)
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

define tailcc void @returnAddress_90(%Pos %v_r_2966_24_188_4816, ptr %stack) {
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
  %p_8_9_4719 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4719, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_291 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_292 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_93, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_291, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_292, align 8, !noalias !0
  %tag_293 = extractvalue %Pos %v_r_2966_24_188_4816, 0
  switch i64 %tag_293, label %label_295 [
    i64 0, label %label_299
    i64 1, label %label_305
  ]

label_295:                                        ; preds = %stackAllocate.exit
  ret void

label_299:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_5349 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5349.lit)
  %stackPointer.i14 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17 = icmp ule ptr %stackPointer.i14, %limit.i16
  tail call void @llvm.assume(i1 %isInside.i17)
  %newStackPointer.i18 = getelementptr i8, ptr %stackPointer.i14, i64 -24
  store ptr %newStackPointer.i18, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_296 = load ptr, ptr %newStackPointer.i18, align 8, !noalias !0
  musttail call tailcc void %returnAddress_296(%Pos %utf8StringLiteral_5349, ptr nonnull %stack)
  ret void

label_305:                                        ; preds = %stackAllocate.exit
  %fields_294 = extractvalue %Pos %v_r_2966_24_188_4816, 1
  %environment.i = getelementptr i8, ptr %fields_294, i64 16
  %v_y_3801_8_29_193_4837.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3801_8_29_193_4837.elt1 = getelementptr i8, ptr %fields_294, i64 24
  %v_y_3801_8_29_193_4837.unpack2 = load ptr, ptr %v_y_3801_8_29_193_4837.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3801_8_29_193_4837.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_305
  %referenceCount.i.i = load i64, ptr %v_y_3801_8_29_193_4837.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3801_8_29_193_4837.unpack2, align 4
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
  %0 = insertvalue %Pos poison, i64 %v_y_3801_8_29_193_4837.unpack, 0
  %v_y_3801_8_29_193_48373 = insertvalue %Pos %0, ptr %v_y_3801_8_29_193_4837.unpack2, 1
  %stackPointer.i20 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i22 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i23 = icmp ule ptr %stackPointer.i20, %limit.i22
  tail call void @llvm.assume(i1 %isInside.i23)
  %newStackPointer.i24 = getelementptr i8, ptr %stackPointer.i20, i64 -24
  store ptr %newStackPointer.i24, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_302 = load ptr, ptr %newStackPointer.i24, align 8, !noalias !0
  musttail call tailcc void %returnAddress_302(%Pos %v_y_3801_8_29_193_48373, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_87(%Pos %v_r_2965_13_177_4859, ptr %stack) {
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
  %p_8_9_4719 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4719, ptr %newStackPointer.i, align 8, !noalias !0
  %sharer_pointer_311 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_312 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_90, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_311, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_312, align 8, !noalias !0
  %tag_313 = extractvalue %Pos %v_r_2965_13_177_4859, 0
  switch i64 %tag_313, label %label_315 [
    i64 0, label %label_320
    i64 1, label %label_332
  ]

label_315:                                        ; preds = %stackAllocate.exit
  ret void

label_320:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %p_8_9_4719, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr @returnAddress_93, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_281, ptr %sharer_pointer_311, align 8, !noalias !0
  store ptr @eraser_285, ptr %eraser_pointer_312, align 8, !noalias !0
  %utf8StringLiteral_5349.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5349.lit)
  %stackPointer.i14.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i16.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i17.i = icmp ule ptr %stackPointer.i14.i, %limit.i16.i
  tail call void @llvm.assume(i1 %isInside.i17.i)
  %newStackPointer.i18.i = getelementptr i8, ptr %stackPointer.i14.i, i64 -24
  store ptr %newStackPointer.i18.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_296.i = load ptr, ptr %newStackPointer.i18.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_296.i(%Pos %utf8StringLiteral_5349.i, ptr nonnull %stack)
  ret void

label_332:                                        ; preds = %stackAllocate.exit
  %fields_314 = extractvalue %Pos %v_r_2965_13_177_4859, 1
  %environment.i6 = getelementptr i8, ptr %fields_314, i64 16
  %v_y_3310_10_21_185_4882.unpack = load i64, ptr %environment.i6, align 8, !noalias !0
  %v_y_3310_10_21_185_4882.elt1 = getelementptr i8, ptr %fields_314, i64 24
  %v_y_3310_10_21_185_4882.unpack2 = load ptr, ptr %v_y_3310_10_21_185_4882.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3310_10_21_185_4882.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_332
  %referenceCount.i.i = load i64, ptr %v_y_3310_10_21_185_4882.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3310_10_21_185_4882.unpack2, align 4
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
  store i64 %v_y_3310_10_21_185_4882.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_325.repack4 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_3310_10_21_185_4882.unpack2, ptr %environment_325.repack4, align 8, !noalias !0
  %make_5351 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_329 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_329(%Pos %make_5351, ptr nonnull %stack)
  ret void
}

define tailcc void @main_2862(ptr %stack) local_unnamed_addr {
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
  %acc_3_3_5_169_4982.tr8.i = phi %Pos [ %make_5304.i, %label_81.i ], [ zeroinitializer, %stackAllocate.exit46 ]
  %start_2_2_4_168_4959.tr7.i = phi i64 [ %z.i5.i, %label_81.i ], [ %z.i, %stackAllocate.exit46 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_168_4959.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_168_4959.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_75, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_5301.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_5301.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_72.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_5301.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_5301.elt2.i, ptr %environment_72.repack1.i, align 8, !noalias !0
  %acc_3_3_5_169_4982_pointer_79.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_169_4982.elt.i = extractvalue %Pos %acc_3_3_5_169_4982.tr8.i, 0
  store i64 %acc_3_3_5_169_4982.elt.i, ptr %acc_3_3_5_169_4982_pointer_79.i, align 8, !noalias !0
  %acc_3_3_5_169_4982_pointer_79.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_169_4982.elt4.i = extractvalue %Pos %acc_3_3_5_169_4982.tr8.i, 1
  store ptr %acc_3_3_5_169_4982.elt4.i, ptr %acc_3_3_5_169_4982_pointer_79.repack3.i, align 8, !noalias !0
  %make_5304.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_168_4959.tr7.i, 2
  br i1 %z.i.i, label %label_85.i.loopexit, label %label_81.i

label_85.i.loopexit:                              ; preds = %label_81.i
  %stackPointer.i.i47.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i48.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_85.i

label_85.i:                                       ; preds = %label_85.i.loopexit, %stackAllocate.exit46
  %limit.i.i48 = phi ptr [ %limit.i.i4851, %stackAllocate.exit46 ], [ %limit.i.i48.pre, %label_85.i.loopexit ]
  %stackPointer.i.i47 = phi ptr [ %nextStackPointer.sink.i30, %stackAllocate.exit46 ], [ %stackPointer.i.i47.pre, %label_85.i.loopexit ]
  %acc_3_3_5_169_4982.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit46 ], [ %make_5304.i, %label_85.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i47, %limit.i.i48
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i47, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_82.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_82.i(%Pos %acc_3_3_5_169_4982.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_342(%Pos %returnValue_343, ptr %stack) {
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
  %returnAddress_346 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_346(%Pos %returnValue_343, ptr %stack)
  ret void
}

define void @sharer_350(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_354(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_363(%Pos %v_r_2962_5246, ptr %stack) {
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
  %count_2881.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %count_2881.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %count_2881.unpack2 = load i64, ptr %count_2881.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %v_r_2962_5246, 1
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
  %stack_pointer.i.i = getelementptr i8, ptr %count_2881.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %varPointer.i = getelementptr i8, ptr %base.i, i64 %count_2881.unpack2
  %get_5247 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %stackPointer.i10 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i12 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i13 = icmp ule ptr %stackPointer.i10, %limit.i12
  tail call void @llvm.assume(i1 %isInside.i13)
  %newStackPointer.i14 = getelementptr i8, ptr %stackPointer.i10, i64 -24
  store ptr %newStackPointer.i14, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_368 = load ptr, ptr %newStackPointer.i14, align 8, !noalias !0
  musttail call tailcc void %returnAddress_368(i64 %get_5247, ptr nonnull %stack)
  ret void
}

define void @sharer_372(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_376(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_384(%Pos %returnValue_385, ptr %stack) {
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
  %returnAddress_388 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_388(%Pos %returnValue_385, ptr %stack)
  ret void
}

define void @eraser_440(ptr nocapture readonly %environment) {
entry:
  %v_r_2956_16_15_4365_436.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %v_r_2956_16_15_4365_436.unpack2 = load ptr, ptr %v_r_2956_16_15_4365_436.elt1, align 8, !noalias !0
  %v_r_2957_18_17_4377_437.elt4 = getelementptr i8, ptr %environment, i64 24
  %v_r_2957_18_17_4377_437.unpack5 = load ptr, ptr %v_r_2957_18_17_4377_437.elt4, align 8, !noalias !0
  %v_r_2958_20_19_4372_438.elt7 = getelementptr i8, ptr %environment, i64 40
  %v_r_2958_20_19_4372_438.unpack8 = load ptr, ptr %v_r_2958_20_19_4372_438.elt7, align 8, !noalias !0
  %v_r_2959_22_21_4364_439.elt10 = getelementptr i8, ptr %environment, i64 56
  %v_r_2959_22_21_4364_439.unpack11 = load ptr, ptr %v_r_2959_22_21_4364_439.elt10, align 8, !noalias !0
  %isNull.i.i35 = icmp eq ptr %v_r_2956_16_15_4365_436.unpack2, null
  br i1 %isNull.i.i35, label %erasePositive.exit45, label %next.i.i36

next.i.i36:                                       ; preds = %entry
  %referenceCount.i.i37 = load i64, ptr %v_r_2956_16_15_4365_436.unpack2, align 4
  %cond.i.i38 = icmp eq i64 %referenceCount.i.i37, 0
  br i1 %cond.i.i38, label %free.i.i41, label %decr.i.i39

decr.i.i39:                                       ; preds = %next.i.i36
  %referenceCount.1.i.i40 = add i64 %referenceCount.i.i37, -1
  store i64 %referenceCount.1.i.i40, ptr %v_r_2956_16_15_4365_436.unpack2, align 4
  br label %erasePositive.exit45

free.i.i41:                                       ; preds = %next.i.i36
  %objectEraser.i.i42 = getelementptr i8, ptr %v_r_2956_16_15_4365_436.unpack2, i64 8
  %eraser.i.i43 = load ptr, ptr %objectEraser.i.i42, align 8
  %environment.i.i.i44 = getelementptr i8, ptr %v_r_2956_16_15_4365_436.unpack2, i64 16
  tail call void %eraser.i.i43(ptr %environment.i.i.i44)
  tail call void @free(ptr nonnull %v_r_2956_16_15_4365_436.unpack2)
  br label %erasePositive.exit45

erasePositive.exit45:                             ; preds = %entry, %decr.i.i39, %free.i.i41
  %isNull.i.i24 = icmp eq ptr %v_r_2957_18_17_4377_437.unpack5, null
  br i1 %isNull.i.i24, label %erasePositive.exit34, label %next.i.i25

next.i.i25:                                       ; preds = %erasePositive.exit45
  %referenceCount.i.i26 = load i64, ptr %v_r_2957_18_17_4377_437.unpack5, align 4
  %cond.i.i27 = icmp eq i64 %referenceCount.i.i26, 0
  br i1 %cond.i.i27, label %free.i.i30, label %decr.i.i28

decr.i.i28:                                       ; preds = %next.i.i25
  %referenceCount.1.i.i29 = add i64 %referenceCount.i.i26, -1
  store i64 %referenceCount.1.i.i29, ptr %v_r_2957_18_17_4377_437.unpack5, align 4
  br label %erasePositive.exit34

free.i.i30:                                       ; preds = %next.i.i25
  %objectEraser.i.i31 = getelementptr i8, ptr %v_r_2957_18_17_4377_437.unpack5, i64 8
  %eraser.i.i32 = load ptr, ptr %objectEraser.i.i31, align 8
  %environment.i.i.i33 = getelementptr i8, ptr %v_r_2957_18_17_4377_437.unpack5, i64 16
  tail call void %eraser.i.i32(ptr %environment.i.i.i33)
  tail call void @free(ptr nonnull %v_r_2957_18_17_4377_437.unpack5)
  br label %erasePositive.exit34

erasePositive.exit34:                             ; preds = %erasePositive.exit45, %decr.i.i28, %free.i.i30
  %isNull.i.i13 = icmp eq ptr %v_r_2958_20_19_4372_438.unpack8, null
  br i1 %isNull.i.i13, label %erasePositive.exit23, label %next.i.i14

next.i.i14:                                       ; preds = %erasePositive.exit34
  %referenceCount.i.i15 = load i64, ptr %v_r_2958_20_19_4372_438.unpack8, align 4
  %cond.i.i16 = icmp eq i64 %referenceCount.i.i15, 0
  br i1 %cond.i.i16, label %free.i.i19, label %decr.i.i17

decr.i.i17:                                       ; preds = %next.i.i14
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i15, -1
  store i64 %referenceCount.1.i.i18, ptr %v_r_2958_20_19_4372_438.unpack8, align 4
  br label %erasePositive.exit23

free.i.i19:                                       ; preds = %next.i.i14
  %objectEraser.i.i20 = getelementptr i8, ptr %v_r_2958_20_19_4372_438.unpack8, i64 8
  %eraser.i.i21 = load ptr, ptr %objectEraser.i.i20, align 8
  %environment.i.i.i22 = getelementptr i8, ptr %v_r_2958_20_19_4372_438.unpack8, i64 16
  tail call void %eraser.i.i21(ptr %environment.i.i.i22)
  tail call void @free(ptr nonnull %v_r_2958_20_19_4372_438.unpack8)
  br label %erasePositive.exit23

erasePositive.exit23:                             ; preds = %erasePositive.exit34, %decr.i.i17, %free.i.i19
  %isNull.i.i = icmp eq ptr %v_r_2959_22_21_4364_439.unpack11, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit23
  %referenceCount.i.i = load i64, ptr %v_r_2959_22_21_4364_439.unpack11, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2959_22_21_4364_439.unpack11, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2959_22_21_4364_439.unpack11, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2959_22_21_4364_439.unpack11, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2959_22_21_4364_439.unpack11)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit23, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_429(%Pos %v_r_2959_22_21_4364, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -48
  %v_r_2956_16_15_4365.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2956_16_15_4365.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %v_r_2956_16_15_4365.unpack2 = load ptr, ptr %v_r_2956_16_15_4365.elt1, align 8, !noalias !0
  %v_r_2957_18_17_4377_pointer_432 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %v_r_2957_18_17_4377.unpack = load i64, ptr %v_r_2957_18_17_4377_pointer_432, align 8, !noalias !0
  %v_r_2957_18_17_4377.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %v_r_2957_18_17_4377.unpack5 = load ptr, ptr %v_r_2957_18_17_4377.elt4, align 8, !noalias !0
  %v_r_2958_20_19_4372_pointer_433 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2958_20_19_4372.unpack = load i64, ptr %v_r_2958_20_19_4372_pointer_433, align 8, !noalias !0
  %v_r_2958_20_19_4372.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2958_20_19_4372.unpack8 = load ptr, ptr %v_r_2958_20_19_4372.elt7, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(80) ptr @malloc(i64 80)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_440, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_r_2956_16_15_4365.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_435.repack10 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_r_2956_16_15_4365.unpack2, ptr %environment_435.repack10, align 8, !noalias !0
  %v_r_2957_18_17_4377_pointer_446 = getelementptr i8, ptr %object.i, i64 32
  store i64 %v_r_2957_18_17_4377.unpack, ptr %v_r_2957_18_17_4377_pointer_446, align 8, !noalias !0
  %v_r_2957_18_17_4377_pointer_446.repack12 = getelementptr i8, ptr %object.i, i64 40
  store ptr %v_r_2957_18_17_4377.unpack5, ptr %v_r_2957_18_17_4377_pointer_446.repack12, align 8, !noalias !0
  %v_r_2958_20_19_4372_pointer_447 = getelementptr i8, ptr %object.i, i64 48
  store i64 %v_r_2958_20_19_4372.unpack, ptr %v_r_2958_20_19_4372_pointer_447, align 8, !noalias !0
  %v_r_2958_20_19_4372_pointer_447.repack14 = getelementptr i8, ptr %object.i, i64 56
  store ptr %v_r_2958_20_19_4372.unpack8, ptr %v_r_2958_20_19_4372_pointer_447.repack14, align 8, !noalias !0
  %v_r_2959_22_21_4364_pointer_448 = getelementptr i8, ptr %object.i, i64 64
  %v_r_2959_22_21_4364.elt = extractvalue %Pos %v_r_2959_22_21_4364, 0
  store i64 %v_r_2959_22_21_4364.elt, ptr %v_r_2959_22_21_4364_pointer_448, align 8, !noalias !0
  %v_r_2959_22_21_4364_pointer_448.repack16 = getelementptr i8, ptr %object.i, i64 72
  %v_r_2959_22_21_4364.elt17 = extractvalue %Pos %v_r_2959_22_21_4364, 1
  store ptr %v_r_2959_22_21_4364.elt17, ptr %v_r_2959_22_21_4364_pointer_448.repack16, align 8, !noalias !0
  %make_5263 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i27 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i27)
  %newStackPointer.i28 = getelementptr i8, ptr %stackPointer.i, i64 -72
  store ptr %newStackPointer.i28, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_450 = load ptr, ptr %newStackPointer.i28, align 8, !noalias !0
  musttail call tailcc void %returnAddress_450(%Pos %make_5263, ptr %stack)
  ret void
}

define void @sharer_456(ptr %stackPointer) {
entry:
  %v_r_2956_16_15_4365_453.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_r_2956_16_15_4365_453.unpack2 = load ptr, ptr %v_r_2956_16_15_4365_453.elt1, align 8, !noalias !0
  %v_r_2957_18_17_4377_454.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2957_18_17_4377_454.unpack5 = load ptr, ptr %v_r_2957_18_17_4377_454.elt4, align 8, !noalias !0
  %v_r_2958_20_19_4372_455.elt7 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2958_20_19_4372_455.unpack8 = load ptr, ptr %v_r_2958_20_19_4372_455.elt7, align 8, !noalias !0
  %isNull.i.i15 = icmp eq ptr %v_r_2956_16_15_4365_453.unpack2, null
  br i1 %isNull.i.i15, label %sharePositive.exit19, label %next.i.i16

next.i.i16:                                       ; preds = %entry
  %referenceCount.i.i17 = load i64, ptr %v_r_2956_16_15_4365_453.unpack2, align 4
  %referenceCount.1.i.i18 = add i64 %referenceCount.i.i17, 1
  store i64 %referenceCount.1.i.i18, ptr %v_r_2956_16_15_4365_453.unpack2, align 4
  br label %sharePositive.exit19

sharePositive.exit19:                             ; preds = %entry, %next.i.i16
  %isNull.i.i10 = icmp eq ptr %v_r_2957_18_17_4377_454.unpack5, null
  br i1 %isNull.i.i10, label %sharePositive.exit14, label %next.i.i11

next.i.i11:                                       ; preds = %sharePositive.exit19
  %referenceCount.i.i12 = load i64, ptr %v_r_2957_18_17_4377_454.unpack5, align 4
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i12, 1
  store i64 %referenceCount.1.i.i13, ptr %v_r_2957_18_17_4377_454.unpack5, align 4
  br label %sharePositive.exit14

sharePositive.exit14:                             ; preds = %sharePositive.exit19, %next.i.i11
  %isNull.i.i = icmp eq ptr %v_r_2958_20_19_4372_455.unpack8, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit14
  %referenceCount.i.i = load i64, ptr %v_r_2958_20_19_4372_455.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2958_20_19_4372_455.unpack8, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit14, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_464(ptr %stackPointer) {
entry:
  %v_r_2956_16_15_4365_461.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %v_r_2956_16_15_4365_461.unpack2 = load ptr, ptr %v_r_2956_16_15_4365_461.elt1, align 8, !noalias !0
  %v_r_2957_18_17_4377_462.elt4 = getelementptr i8, ptr %stackPointer, i64 -24
  %v_r_2957_18_17_4377_462.unpack5 = load ptr, ptr %v_r_2957_18_17_4377_462.elt4, align 8, !noalias !0
  %v_r_2958_20_19_4372_463.elt7 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2958_20_19_4372_463.unpack8 = load ptr, ptr %v_r_2958_20_19_4372_463.elt7, align 8, !noalias !0
  %isNull.i.i21 = icmp eq ptr %v_r_2956_16_15_4365_461.unpack2, null
  br i1 %isNull.i.i21, label %erasePositive.exit31, label %next.i.i22

next.i.i22:                                       ; preds = %entry
  %referenceCount.i.i23 = load i64, ptr %v_r_2956_16_15_4365_461.unpack2, align 4
  %cond.i.i24 = icmp eq i64 %referenceCount.i.i23, 0
  br i1 %cond.i.i24, label %free.i.i27, label %decr.i.i25

decr.i.i25:                                       ; preds = %next.i.i22
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i23, -1
  store i64 %referenceCount.1.i.i26, ptr %v_r_2956_16_15_4365_461.unpack2, align 4
  br label %erasePositive.exit31

free.i.i27:                                       ; preds = %next.i.i22
  %objectEraser.i.i28 = getelementptr i8, ptr %v_r_2956_16_15_4365_461.unpack2, i64 8
  %eraser.i.i29 = load ptr, ptr %objectEraser.i.i28, align 8
  %environment.i.i.i30 = getelementptr i8, ptr %v_r_2956_16_15_4365_461.unpack2, i64 16
  tail call void %eraser.i.i29(ptr %environment.i.i.i30)
  tail call void @free(ptr nonnull %v_r_2956_16_15_4365_461.unpack2)
  br label %erasePositive.exit31

erasePositive.exit31:                             ; preds = %entry, %decr.i.i25, %free.i.i27
  %isNull.i.i10 = icmp eq ptr %v_r_2957_18_17_4377_462.unpack5, null
  br i1 %isNull.i.i10, label %erasePositive.exit20, label %next.i.i11

next.i.i11:                                       ; preds = %erasePositive.exit31
  %referenceCount.i.i12 = load i64, ptr %v_r_2957_18_17_4377_462.unpack5, align 4
  %cond.i.i13 = icmp eq i64 %referenceCount.i.i12, 0
  br i1 %cond.i.i13, label %free.i.i16, label %decr.i.i14

decr.i.i14:                                       ; preds = %next.i.i11
  %referenceCount.1.i.i15 = add i64 %referenceCount.i.i12, -1
  store i64 %referenceCount.1.i.i15, ptr %v_r_2957_18_17_4377_462.unpack5, align 4
  br label %erasePositive.exit20

free.i.i16:                                       ; preds = %next.i.i11
  %objectEraser.i.i17 = getelementptr i8, ptr %v_r_2957_18_17_4377_462.unpack5, i64 8
  %eraser.i.i18 = load ptr, ptr %objectEraser.i.i17, align 8
  %environment.i.i.i19 = getelementptr i8, ptr %v_r_2957_18_17_4377_462.unpack5, i64 16
  tail call void %eraser.i.i18(ptr %environment.i.i.i19)
  tail call void @free(ptr nonnull %v_r_2957_18_17_4377_462.unpack5)
  br label %erasePositive.exit20

erasePositive.exit20:                             ; preds = %erasePositive.exit31, %decr.i.i14, %free.i.i16
  %isNull.i.i = icmp eq ptr %v_r_2958_20_19_4372_463.unpack8, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit20
  %referenceCount.i.i = load i64, ptr %v_r_2958_20_19_4372_463.unpack8, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2958_20_19_4372_463.unpack8, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2958_20_19_4372_463.unpack8, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2958_20_19_4372_463.unpack8, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2958_20_19_4372_463.unpack8)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit20, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -56
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_422(%Pos %v_r_2958_20_19_4372, ptr %stack) {
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
  %seed_5_4357_pointer_425 = getelementptr i8, ptr %stackPointer.i, i64 -56
  %seed_5_4357.unpack = load ptr, ptr %seed_5_4357_pointer_425, align 8, !noalias !0
  %seed_5_4357.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %seed_5_4357.unpack5 = load i64, ptr %seed_5_4357.elt4, align 8, !noalias !0
  %depth_5_4_4366_pointer_426 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_426, align 4, !noalias !0
  %count_2881_pointer_427 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %count_2881.unpack = load ptr, ptr %count_2881_pointer_427, align 8, !noalias !0
  %count_2881.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %count_2881.unpack8 = load i64, ptr %count_2881.elt7, align 8, !noalias !0
  %v_r_2957_18_17_4377_pointer_428 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %v_r_2957_18_17_4377.unpack = load i64, ptr %v_r_2957_18_17_4377_pointer_428, align 8, !noalias !0
  %v_r_2957_18_17_4377.elt10 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_r_2957_18_17_4377.unpack11 = load ptr, ptr %v_r_2957_18_17_4377.elt10, align 8, !noalias !0
  store i64 %v_r_2957_18_17_4377.unpack, ptr %seed_5_4357_pointer_425, align 8, !noalias !0
  store ptr %v_r_2957_18_17_4377.unpack11, ptr %seed_5_4357.elt4, align 8, !noalias !0
  %v_r_2958_20_19_4372.elt = extractvalue %Pos %v_r_2958_20_19_4372, 0
  store i64 %v_r_2958_20_19_4372.elt, ptr %depth_5_4_4366_pointer_426, align 8, !noalias !0
  %v_r_2958_20_19_4372.elt18 = extractvalue %Pos %v_r_2958_20_19_4372, 1
  store ptr %v_r_2958_20_19_4372.elt18, ptr %count_2881_pointer_427, align 8, !noalias !0
  store ptr @returnAddress_429, ptr %count_2881.elt7, align 8, !noalias !0
  store ptr @sharer_456, ptr %v_r_2957_18_17_4377_pointer_428, align 8, !noalias !0
  store ptr @eraser_464, ptr %v_r_2957_18_17_4377.elt10, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %entry
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %stackPointer.i to i64
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %entry
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %entry ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %stackPointer.i, %entry ]
  %z.i = add i64 %depth_5_4_4366, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store ptr %seed_5_4357.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_646.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %seed_5_4357.unpack5, ptr %stackPointer_646.repack1.i, align 8, !noalias !0
  %depth_5_4_4366_pointer_648.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %z.i, ptr %depth_5_4_4366_pointer_648.i, align 4, !noalias !0
  %count_2881_pointer_649.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %count_2881.unpack, ptr %count_2881_pointer_649.i, align 8, !noalias !0
  %count_2881_pointer_649.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %count_2881.unpack8, ptr %count_2881_pointer_649.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_650.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_651.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_652.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_398, ptr %returnAddress_pointer_650.i, align 8, !noalias !0
  store ptr @sharer_540, ptr %sharer_pointer_651.i, align 8, !noalias !0
  store ptr @eraser_548, ptr %eraser_pointer_652.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %count_2881.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i5.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i6.i = load ptr, ptr %base_pointer.i5.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i6.i, i64 %count_2881.unpack8
  %get_5282.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i10.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i10.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_655.i = load ptr, ptr %newStackPointer.i10.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655.i(i64 %get_5282.i, ptr nonnull %stack)
  ret void
}

define void @sharer_481(ptr %stackPointer) {
entry:
  %v_r_2956_16_15_4365_476.elt1 = getelementptr i8, ptr %stackPointer, i64 -64
  %v_r_2956_16_15_4365_476.unpack2 = load ptr, ptr %v_r_2956_16_15_4365_476.elt1, align 8, !noalias !0
  %v_r_2957_18_17_4377_480.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2957_18_17_4377_480.unpack5 = load ptr, ptr %v_r_2957_18_17_4377_480.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_r_2956_16_15_4365_476.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_r_2956_16_15_4365_476.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %v_r_2956_16_15_4365_476.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %entry, %next.i.i8
  %isNull.i.i = icmp eq ptr %v_r_2957_18_17_4377_480.unpack5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %v_r_2957_18_17_4377_480.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2957_18_17_4377_480.unpack5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %sharePositive.exit11, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -88
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_493(ptr %stackPointer) {
entry:
  %v_r_2956_16_15_4365_488.elt1 = getelementptr i8, ptr %stackPointer, i64 -64
  %v_r_2956_16_15_4365_488.unpack2 = load ptr, ptr %v_r_2956_16_15_4365_488.elt1, align 8, !noalias !0
  %v_r_2957_18_17_4377_492.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %v_r_2957_18_17_4377_492.unpack5 = load ptr, ptr %v_r_2957_18_17_4377_492.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_r_2956_16_15_4365_488.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %v_r_2956_16_15_4365_488.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %v_r_2956_16_15_4365_488.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %v_r_2956_16_15_4365_488.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %v_r_2956_16_15_4365_488.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %v_r_2956_16_15_4365_488.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %v_r_2957_18_17_4377_492.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %v_r_2957_18_17_4377_492.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2957_18_17_4377_492.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2957_18_17_4377_492.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2957_18_17_4377_492.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2957_18_17_4377_492.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -96
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -80
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_416(%Pos %v_r_2957_18_17_4377, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %v_r_2956_16_15_4365.unpack = load i64, ptr %newStackPointer.i, align 8, !noalias !0
  %v_r_2956_16_15_4365.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %v_r_2956_16_15_4365.unpack2 = load ptr, ptr %v_r_2956_16_15_4365.elt1, align 8, !noalias !0
  %seed_5_4357_pointer_419 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %seed_5_4357.unpack = load ptr, ptr %seed_5_4357_pointer_419, align 8, !noalias !0
  %seed_5_4357.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_4357.unpack5 = load i64, ptr %seed_5_4357.elt4, align 8, !noalias !0
  %depth_5_4_4366_pointer_420 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_420, align 4, !noalias !0
  %count_2881_pointer_421 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %count_2881.unpack = load ptr, ptr %count_2881_pointer_421, align 8, !noalias !0
  %count_2881.elt7 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %count_2881.unpack8 = load i64, ptr %count_2881.elt7, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
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
  %newStackPointer.i26 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i26, i64 96
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i26, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %v_r_2956_16_15_4365.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_500.repack10 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %v_r_2956_16_15_4365.unpack2, ptr %stackPointer_500.repack10, align 8, !noalias !0
  %seed_5_4357_pointer_502 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %seed_5_4357.unpack, ptr %seed_5_4357_pointer_502, align 8, !noalias !0
  %seed_5_4357_pointer_502.repack12 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %seed_5_4357.unpack5, ptr %seed_5_4357_pointer_502.repack12, align 8, !noalias !0
  %depth_5_4_4366_pointer_503 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_503, align 4, !noalias !0
  %count_2881_pointer_504 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %count_2881.unpack, ptr %count_2881_pointer_504, align 8, !noalias !0
  %count_2881_pointer_504.repack14 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %count_2881.unpack8, ptr %count_2881_pointer_504.repack14, align 8, !noalias !0
  %v_r_2957_18_17_4377_pointer_505 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %v_r_2957_18_17_4377.elt = extractvalue %Pos %v_r_2957_18_17_4377, 0
  store i64 %v_r_2957_18_17_4377.elt, ptr %v_r_2957_18_17_4377_pointer_505, align 8, !noalias !0
  %v_r_2957_18_17_4377_pointer_505.repack16 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %v_r_2957_18_17_4377.elt17 = extractvalue %Pos %v_r_2957_18_17_4377, 1
  store ptr %v_r_2957_18_17_4377.elt17, ptr %v_r_2957_18_17_4377_pointer_505.repack16, align 8, !noalias !0
  %returnAddress_pointer_506 = getelementptr i8, ptr %common.ret.op.i, i64 72
  %sharer_pointer_507 = getelementptr i8, ptr %common.ret.op.i, i64 80
  %eraser_pointer_508 = getelementptr i8, ptr %common.ret.op.i, i64 88
  store ptr @returnAddress_422, ptr %returnAddress_pointer_506, align 8, !noalias !0
  store ptr @sharer_481, ptr %sharer_pointer_507, align 8, !noalias !0
  store ptr @eraser_493, ptr %eraser_pointer_508, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i to i64
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %z.i = add i64 %depth_5_4_4366, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store ptr %seed_5_4357.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_646.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %seed_5_4357.unpack5, ptr %stackPointer_646.repack1.i, align 8, !noalias !0
  %depth_5_4_4366_pointer_648.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %z.i, ptr %depth_5_4_4366_pointer_648.i, align 4, !noalias !0
  %count_2881_pointer_649.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %count_2881.unpack, ptr %count_2881_pointer_649.i, align 8, !noalias !0
  %count_2881_pointer_649.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %count_2881.unpack8, ptr %count_2881_pointer_649.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_650.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_651.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_652.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_398, ptr %returnAddress_pointer_650.i, align 8, !noalias !0
  store ptr @sharer_540, ptr %sharer_pointer_651.i, align 8, !noalias !0
  store ptr @eraser_548, ptr %eraser_pointer_652.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %count_2881.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i5.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i6.i = load ptr, ptr %base_pointer.i5.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i6.i, i64 %count_2881.unpack8
  %get_5282.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i10.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i10.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_655.i = load ptr, ptr %newStackPointer.i10.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655.i(i64 %get_5282.i, ptr nonnull %stack)
  ret void
}

define void @sharer_513(ptr %stackPointer) {
entry:
  %v_r_2956_16_15_4365_509.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %v_r_2956_16_15_4365_509.unpack2 = load ptr, ptr %v_r_2956_16_15_4365_509.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2956_16_15_4365_509.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2956_16_15_4365_509.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_r_2956_16_15_4365_509.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_523(ptr %stackPointer) {
entry:
  %v_r_2956_16_15_4365_519.elt1 = getelementptr i8, ptr %stackPointer, i64 -48
  %v_r_2956_16_15_4365_519.unpack2 = load ptr, ptr %v_r_2956_16_15_4365_519.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_r_2956_16_15_4365_519.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_r_2956_16_15_4365_519.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_r_2956_16_15_4365_519.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_r_2956_16_15_4365_519.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_r_2956_16_15_4365_519.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_r_2956_16_15_4365_519.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_411(%Pos %v_r_2956_16_15_4365, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %seed_5_4357.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %seed_5_4357.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_4357.unpack2 = load i64, ptr %seed_5_4357.elt1, align 8, !noalias !0
  %depth_5_4_4366_pointer_414 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_414, align 4, !noalias !0
  %count_2881_pointer_415 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %count_2881.unpack = load ptr, ptr %count_2881_pointer_415, align 8, !noalias !0
  %count_2881.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %count_2881.unpack5 = load i64, ptr %count_2881.elt4, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 40
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
  %newStackPointer.i21 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i21, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i21, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %v_r_2956_16_15_4365.elt = extractvalue %Pos %v_r_2956_16_15_4365, 0
  store i64 %v_r_2956_16_15_4365.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_529.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %v_r_2956_16_15_4365.elt8 = extractvalue %Pos %v_r_2956_16_15_4365, 1
  store ptr %v_r_2956_16_15_4365.elt8, ptr %stackPointer_529.repack7, align 8, !noalias !0
  %seed_5_4357_pointer_531 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %seed_5_4357.unpack, ptr %seed_5_4357_pointer_531, align 8, !noalias !0
  %seed_5_4357_pointer_531.repack9 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %seed_5_4357.unpack2, ptr %seed_5_4357_pointer_531.repack9, align 8, !noalias !0
  %depth_5_4_4366_pointer_532 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_532, align 4, !noalias !0
  %count_2881_pointer_533 = getelementptr i8, ptr %common.ret.op.i, i64 40
  store ptr %count_2881.unpack, ptr %count_2881_pointer_533, align 8, !noalias !0
  %count_2881_pointer_533.repack11 = getelementptr i8, ptr %common.ret.op.i, i64 48
  store i64 %count_2881.unpack5, ptr %count_2881_pointer_533.repack11, align 8, !noalias !0
  %returnAddress_pointer_534 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_535 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_536 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_416, ptr %returnAddress_pointer_534, align 8, !noalias !0
  store ptr @sharer_513, ptr %sharer_pointer_535, align 8, !noalias !0
  store ptr @eraser_523, ptr %eraser_pointer_536, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i to i64
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %z.i = add i64 %depth_5_4_4366, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store ptr %seed_5_4357.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_646.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %seed_5_4357.unpack2, ptr %stackPointer_646.repack1.i, align 8, !noalias !0
  %depth_5_4_4366_pointer_648.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %z.i, ptr %depth_5_4_4366_pointer_648.i, align 4, !noalias !0
  %count_2881_pointer_649.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %count_2881.unpack, ptr %count_2881_pointer_649.i, align 8, !noalias !0
  %count_2881_pointer_649.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %count_2881.unpack5, ptr %count_2881_pointer_649.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_650.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_651.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_652.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_398, ptr %returnAddress_pointer_650.i, align 8, !noalias !0
  store ptr @sharer_540, ptr %sharer_pointer_651.i, align 8, !noalias !0
  store ptr @eraser_548, ptr %eraser_pointer_652.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %count_2881.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i5.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i6.i = load ptr, ptr %base_pointer.i5.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i6.i, i64 %count_2881.unpack5
  %get_5282.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i10.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i10.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_655.i = load ptr, ptr %newStackPointer.i10.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655.i(i64 %get_5282.i, ptr nonnull %stack)
  ret void
}

define void @sharer_540(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_548(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_567(i64 %v_r_2954_10_9_4361, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = srem i64 %v_r_2954_10_9_4361, 10
  %z.i3 = add nsw i64 %z.i, 1
  %z.i4 = tail call %Pos @c_array_new(i64 %z.i3)
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_206, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5276.elt = extractvalue %Pos %z.i4, 0
  store i64 %pureApp_5276.elt, ptr %environment.i, align 8, !noalias !0
  %environment_569.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5276.elt2 = extractvalue %Pos %z.i4, 1
  store ptr %pureApp_5276.elt2, ptr %environment_569.repack1, align 8, !noalias !0
  %make_5277 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer.i6 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i8 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i9 = icmp ule ptr %stackPointer.i6, %limit.i8
  tail call void @llvm.assume(i1 %isInside.i9)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i6, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_573 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_573(%Pos %make_5277, ptr %stack)
  ret void
}

define tailcc void @returnAddress_564(%Pos %__13_7_5249, ptr %stack) {
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
  %seed_5_4357.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %seed_5_4357.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %seed_5_4357.unpack2 = load i64, ptr %seed_5_4357.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__13_7_5249, 1
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
  %limit.i11 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 24
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i11
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
  %newStackPointer.i12 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i12, i64 24
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %erasePositive.exit, %realloc.i
  %limit.i18 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i11, %erasePositive.exit ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %erasePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %currentStackPointer.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_578 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_579 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_567, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_578, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_579, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_4357.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i13 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i14 = load ptr, ptr %base_pointer.i13, align 8
  %varPointer.i = getelementptr i8, ptr %base.i14, i64 %seed_5_4357.unpack2
  %get_5278 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i19 = icmp ule ptr %nextStackPointer.sink.i, %limit.i18
  tail call void @llvm.assume(i1 %isInside.i19)
  %newStackPointer.i20 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i20, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_582 = load ptr, ptr %newStackPointer.i20, align 8, !noalias !0
  musttail call tailcc void %returnAddress_582(i64 %get_5278, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_561(i64 %v_r_2946_7_1_4385, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  %seed_5_4357.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %seed_5_4357.unpack2 = load i64, ptr %seed_5_4357.elt1, align 8, !noalias !0
  %seed_5_4357.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = mul i64 %v_r_2946_7_1_4385, 1309
  %z.i11 = add i64 %z.i, 13849
  %z.i12 = srem i64 %z.i11, 65536
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %seed_5_4357.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_587.repack4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %seed_5_4357.unpack2, ptr %stackPointer_587.repack4, align 8, !noalias !0
  %sharer_pointer_590 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_591 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_564, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_372, ptr %sharer_pointer_590, align 8, !noalias !0
  store ptr @eraser_376, ptr %eraser_pointer_591, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_4357.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i17 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i18 = load ptr, ptr %base_pointer.i17, align 8
  %varPointer.i = getelementptr i8, ptr %base.i18, i64 %seed_5_4357.unpack2
  store i64 %z.i12, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_595 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_595(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_403(%Pos %v_r_2953_8_7_5250, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %depth_5_4_4366 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %seed_5_4357_pointer_406 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_4357.unpack = load ptr, ptr %seed_5_4357_pointer_406, align 8, !noalias !0
  %seed_5_4357.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %seed_5_4357.unpack2 = load i64, ptr %seed_5_4357.elt1, align 8, !noalias !0
  %count_2881_pointer_407 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %count_2881.unpack = load ptr, ptr %count_2881_pointer_407, align 8, !noalias !0
  %count_2881.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %count_2881.unpack5 = load i64, ptr %count_2881.elt4, align 8, !noalias !0
  %object.i = extractvalue %Pos %v_r_2953_8_7_5250, 1
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
  %z.i = icmp eq i64 %depth_5_4_4366, 1
  %currentStackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i26 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br i1 %z.i, label %label_610, label %label_560

label_560:                                        ; preds = %erasePositive.exit
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i25, i64 64
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i26
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_560
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %currentStackPointer.i25 to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i
  %nextSize.i = add i64 %size.i, 64
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i22 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i22, i64 64
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %label_560, %realloc.i
  %limit.i.i = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i26, %label_560 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_560 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i22, %realloc.i ], [ %currentStackPointer.i25, %label_560 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %seed_5_4357.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_553.repack9 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store i64 %seed_5_4357.unpack2, ptr %stackPointer_553.repack9, align 8, !noalias !0
  %depth_5_4_4366_pointer_555 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_555, align 4, !noalias !0
  %count_2881_pointer_556 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr %count_2881.unpack, ptr %count_2881_pointer_556, align 8, !noalias !0
  %count_2881_pointer_556.repack11 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %count_2881.unpack5, ptr %count_2881_pointer_556.repack11, align 8, !noalias !0
  %returnAddress_pointer_557 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_558 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_559 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_411, ptr %returnAddress_pointer_557, align 8, !noalias !0
  store ptr @sharer_540, ptr %sharer_pointer_558, align 8, !noalias !0
  store ptr @eraser_548, ptr %eraser_pointer_559, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i to i64
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

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %z.i18 = add i64 %depth_5_4_4366, -1
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store ptr %seed_5_4357.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_646.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %seed_5_4357.unpack2, ptr %stackPointer_646.repack1.i, align 8, !noalias !0
  %depth_5_4_4366_pointer_648.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 %z.i18, ptr %depth_5_4_4366_pointer_648.i, align 4, !noalias !0
  %count_2881_pointer_649.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr %count_2881.unpack, ptr %count_2881_pointer_649.i, align 8, !noalias !0
  %count_2881_pointer_649.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store i64 %count_2881.unpack5, ptr %count_2881_pointer_649.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_650.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_651.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_652.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_398, ptr %returnAddress_pointer_650.i, align 8, !noalias !0
  store ptr @sharer_540, ptr %sharer_pointer_651.i, align 8, !noalias !0
  store ptr @eraser_548, ptr %eraser_pointer_652.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %count_2881.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i5.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i6.i = load ptr, ptr %base_pointer.i5.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i6.i, i64 %count_2881.unpack5
  %get_5282.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i10.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i10.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_655.i = load ptr, ptr %newStackPointer.i10.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655.i(i64 %get_5282.i, ptr nonnull %stack)
  ret void

label_610:                                        ; preds = %erasePositive.exit
  %nextStackPointer.i27 = getelementptr i8, ptr %currentStackPointer.i25, i64 40
  %isInside.not.i28 = icmp ugt ptr %nextStackPointer.i27, %limit.i26
  br i1 %isInside.not.i28, label %realloc.i31, label %stackAllocate.exit45

realloc.i31:                                      ; preds = %label_610
  %base_pointer.i32 = getelementptr i8, ptr %stack, i64 16
  %base.i33 = load ptr, ptr %base_pointer.i32, align 8, !alias.scope !0
  %intStackPointer.i34 = ptrtoint ptr %currentStackPointer.i25 to i64
  %intBase.i35 = ptrtoint ptr %base.i33 to i64
  %size.i36 = sub i64 %intStackPointer.i34, %intBase.i35
  %nextSize.i37 = add i64 %size.i36, 40
  %leadingZeros.i.i38 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i37, i1 false)
  %numBits.i.i39 = sub nuw nsw i64 64, %leadingZeros.i.i38
  %result.i.i40 = shl nuw i64 1, %numBits.i.i39
  %newBase.i41 = tail call ptr @realloc(ptr %base.i33, i64 %result.i.i40)
  %newLimit.i42 = getelementptr i8, ptr %newBase.i41, i64 %result.i.i40
  %newStackPointer.i43 = getelementptr i8, ptr %newBase.i41, i64 %size.i36
  %newNextStackPointer.i44 = getelementptr i8, ptr %newStackPointer.i43, i64 40
  store ptr %newBase.i41, ptr %base_pointer.i32, align 8, !alias.scope !0
  store ptr %newLimit.i42, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit45

stackAllocate.exit45:                             ; preds = %label_610, %realloc.i31
  %limit.i51 = phi ptr [ %newLimit.i42, %realloc.i31 ], [ %limit.i26, %label_610 ]
  %nextStackPointer.sink.i29 = phi ptr [ %newNextStackPointer.i44, %realloc.i31 ], [ %nextStackPointer.i27, %label_610 ]
  %common.ret.op.i30 = phi ptr [ %newStackPointer.i43, %realloc.i31 ], [ %currentStackPointer.i25, %label_610 ]
  store ptr %nextStackPointer.sink.i29, ptr %stackPointer_pointer.i, align 8
  store ptr %seed_5_4357.unpack, ptr %common.ret.op.i30, align 8, !noalias !0
  %stackPointer_600.repack7 = getelementptr inbounds i8, ptr %common.ret.op.i30, i64 8
  store i64 %seed_5_4357.unpack2, ptr %stackPointer_600.repack7, align 8, !noalias !0
  %returnAddress_pointer_602 = getelementptr i8, ptr %common.ret.op.i30, i64 16
  %sharer_pointer_603 = getelementptr i8, ptr %common.ret.op.i30, i64 24
  %eraser_pointer_604 = getelementptr i8, ptr %common.ret.op.i30, i64 32
  store ptr @returnAddress_561, ptr %returnAddress_pointer_602, align 8, !noalias !0
  store ptr @sharer_372, ptr %sharer_pointer_603, align 8, !noalias !0
  store ptr @eraser_376, ptr %eraser_pointer_604, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %seed_5_4357.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i46 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i47 = load ptr, ptr %base_pointer.i46, align 8
  %varPointer.i = getelementptr i8, ptr %base.i47, i64 %seed_5_4357.unpack2
  %get_5280 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i52 = icmp ule ptr %nextStackPointer.sink.i29, %limit.i51
  tail call void @llvm.assume(i1 %isInside.i52)
  %newStackPointer.i53 = getelementptr i8, ptr %nextStackPointer.sink.i29, i64 -24
  store ptr %newStackPointer.i53, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_607 = load ptr, ptr %newStackPointer.i53, align 8, !noalias !0
  musttail call tailcc void %returnAddress_607(i64 %get_5280, ptr nonnull %stack)
  ret void
}

define void @sharer_614(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_622(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_398(i64 %v_r_2952_6_5_4362, ptr %stack) {
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
  %count_2881.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %count_2881.unpack5 = load i64, ptr %count_2881.elt4, align 8, !noalias !0
  %count_2881_pointer_402 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %count_2881.unpack = load ptr, ptr %count_2881_pointer_402, align 8, !noalias !0
  %depth_5_4_4366_pointer_401 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %depth_5_4_4366 = load i64, ptr %depth_5_4_4366_pointer_401, align 4, !noalias !0
  %seed_5_4357.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %seed_5_4357.unpack2 = load i64, ptr %seed_5_4357.elt1, align 8, !noalias !0
  %seed_5_4357.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i = add i64 %v_r_2952_6_5_4362, 1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store i64 %depth_5_4_4366, ptr %newStackPointer.i, align 4, !noalias !0
  %seed_5_4357_pointer_629 = getelementptr i8, ptr %stackPointer.i, i64 -32
  store ptr %seed_5_4357.unpack, ptr %seed_5_4357_pointer_629, align 8, !noalias !0
  %seed_5_4357_pointer_629.repack7 = getelementptr i8, ptr %stackPointer.i, i64 -24
  store i64 %seed_5_4357.unpack2, ptr %seed_5_4357_pointer_629.repack7, align 8, !noalias !0
  %count_2881_pointer_630 = getelementptr i8, ptr %stackPointer.i, i64 -16
  store ptr %count_2881.unpack, ptr %count_2881_pointer_630, align 8, !noalias !0
  %count_2881_pointer_630.repack9 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %count_2881.unpack5, ptr %count_2881_pointer_630.repack9, align 8, !noalias !0
  %sharer_pointer_632 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_633 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_403, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_614, ptr %sharer_pointer_632, align 8, !noalias !0
  store ptr @eraser_622, ptr %eraser_pointer_633, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %count_2881.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i20 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i21 = load ptr, ptr %base_pointer.i20, align 8
  %varPointer.i = getelementptr i8, ptr %base.i21, i64 %count_2881.unpack5
  store i64 %z.i, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_637 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_637(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @buildTreeDepth_worker_4_3_4373(i64 %depth_5_4_4366, %Reference %seed_5_4357, %Reference %count_2881, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 64
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
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
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 64
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i9 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %seed_5_4357.elt = extractvalue %Reference %seed_5_4357, 0
  store ptr %seed_5_4357.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_646.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %seed_5_4357.elt2 = extractvalue %Reference %seed_5_4357, 1
  store i64 %seed_5_4357.elt2, ptr %stackPointer_646.repack1, align 8, !noalias !0
  %depth_5_4_4366_pointer_648 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %depth_5_4_4366, ptr %depth_5_4_4366_pointer_648, align 4, !noalias !0
  %count_2881_pointer_649 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %count_2881.elt = extractvalue %Reference %count_2881, 0
  store ptr %count_2881.elt, ptr %count_2881_pointer_649, align 8, !noalias !0
  %count_2881_pointer_649.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %count_2881.elt4 = extractvalue %Reference %count_2881, 1
  store i64 %count_2881.elt4, ptr %count_2881_pointer_649.repack3, align 8, !noalias !0
  %returnAddress_pointer_650 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_651 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_652 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_398, ptr %returnAddress_pointer_650, align 8, !noalias !0
  store ptr @sharer_540, ptr %sharer_pointer_651, align 8, !noalias !0
  store ptr @eraser_548, ptr %eraser_pointer_652, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %count_2881.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i5 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i6 = load ptr, ptr %base_pointer.i5, align 8
  %varPointer.i = getelementptr i8, ptr %base.i6, i64 %count_2881.elt4
  %get_5282 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i = icmp ule ptr %nextStackPointer.sink.i, %limit.i9
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i10 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i10, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_655 = load ptr, ptr %newStackPointer.i10, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655(i64 %get_5282, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_658(%Pos %__23_5283, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %object.i = extractvalue %Pos %__23_5283, 1
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
  %returnAddress_660 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_660(%Pos zeroinitializer, ptr nonnull %stack)
  ret void
}

define tailcc void @run_2861(i64 %n_2860, ptr %stack) local_unnamed_addr {
entry:
  %pair_340 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr nonnull @global)
  %temporaryStack_5244 = extractvalue <{ ptr, ptr }> %pair_340, 0
  %stack_341 = extractvalue <{ ptr, ptr }> %pair_340, 1
  %stackPointer_pointer.i3 = getelementptr i8, ptr %stack_341, i64 8
  %base_pointer.i4 = getelementptr i8, ptr %stack_341, i64 16
  %stackPointer.i5 = load ptr, ptr %stackPointer_pointer.i3, align 8
  %base.i6 = load ptr, ptr %base_pointer.i4, align 8
  %intStack.i7 = ptrtoint ptr %stackPointer.i5 to i64
  %intBase.i8 = ptrtoint ptr %base.i6 to i64
  %offset.i9 = sub i64 %intStack.i7, %intBase.i8
  %prompt_pointer.i = getelementptr i8, ptr %stack_341, i64 32
  %prompt.i13 = load ptr, ptr %prompt_pointer.i, align 8
  %limit_pointer.i = getelementptr i8, ptr %stack_341, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i5, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %nextSize.i = add i64 %offset.i9, 32
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i6, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %offset.i9
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 32
  store ptr %newBase.i, ptr %base_pointer.i4, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %stackPointer.i5, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i3, align 8
  store i64 0, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_359 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_360 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_361 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_342, ptr %returnAddress_pointer_359, align 8, !noalias !0
  store ptr @sharer_350, ptr %sharer_pointer_360, align 8, !noalias !0
  store ptr @eraser_354, ptr %eraser_pointer_361, align 8, !noalias !0
  %referenceCount.i.i = load i64, ptr %temporaryStack_5244, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %.uniqueStack.exit_crit_edge.i, label %copy.i.i

.uniqueStack.exit_crit_edge.i:                    ; preds = %stackAllocate.exit
  %rest_pointer.phi.trans.insert.i = getelementptr i8, ptr %temporaryStack_5244, i64 40
  %start.pre.i = load ptr, ptr %rest_pointer.phi.trans.insert.i, align 8
  br label %uniqueStack.exit.i

copy.i.i:                                         ; preds = %stackAllocate.exit
  %newOldReferenceCount.i.i = add i64 %referenceCount.i.i, -1
  store i64 %newOldReferenceCount.i.i, ptr %temporaryStack_5244, align 4
  %stack_pointer.i.i = getelementptr i8, ptr %temporaryStack_5244, i64 40
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
  %isEnd.i.i = icmp eq ptr %old.i.i, %temporaryStack_5244
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
  %common.ret.op.i.i = phi ptr [ %newStack.i.i, %stop.i.i ], [ %temporaryStack_5244, %.uniqueStack.exit_crit_edge.i ]
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
  store ptr %stack_341, ptr %rest_pointer.i, align 8
  %stackPointer_pointer.i18 = getelementptr i8, ptr %start.i, i64 8
  %limit_pointer.i19 = getelementptr i8, ptr %start.i, i64 24
  %currentStackPointer.i20 = load ptr, ptr %stackPointer_pointer.i18, align 8, !alias.scope !0
  %limit.i21 = load ptr, ptr %limit_pointer.i19, align 8, !alias.scope !0
  %nextStackPointer.i22 = getelementptr i8, ptr %currentStackPointer.i20, i64 40
  %isInside.not.i23 = icmp ugt ptr %nextStackPointer.i22, %limit.i21
  br i1 %isInside.not.i23, label %realloc.i26, label %stackAllocate.exit40

realloc.i26:                                      ; preds = %resume.exit
  %base_pointer.i27 = getelementptr i8, ptr %start.i, i64 16
  %base.i28 = load ptr, ptr %base_pointer.i27, align 8, !alias.scope !0
  %intStackPointer.i29 = ptrtoint ptr %currentStackPointer.i20 to i64
  %intBase.i30 = ptrtoint ptr %base.i28 to i64
  %size.i31 = sub i64 %intStackPointer.i29, %intBase.i30
  %nextSize.i32 = add i64 %size.i31, 40
  %leadingZeros.i.i33 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i32, i1 false)
  %numBits.i.i34 = sub nuw nsw i64 64, %leadingZeros.i.i33
  %result.i.i35 = shl nuw i64 1, %numBits.i.i34
  %newBase.i36 = tail call ptr @realloc(ptr %base.i28, i64 %result.i.i35)
  %newLimit.i37 = getelementptr i8, ptr %newBase.i36, i64 %result.i.i35
  %newStackPointer.i38 = getelementptr i8, ptr %newBase.i36, i64 %size.i31
  %newNextStackPointer.i39 = getelementptr i8, ptr %newStackPointer.i38, i64 40
  store ptr %newBase.i36, ptr %base_pointer.i27, align 8, !alias.scope !0
  store ptr %newLimit.i37, ptr %limit_pointer.i19, align 8, !alias.scope !0
  br label %stackAllocate.exit40

stackAllocate.exit40:                             ; preds = %resume.exit, %realloc.i26
  %limit.i46 = phi ptr [ %newLimit.i37, %realloc.i26 ], [ %limit.i21, %resume.exit ]
  %nextStackPointer.sink.i24 = phi ptr [ %newNextStackPointer.i39, %realloc.i26 ], [ %nextStackPointer.i22, %resume.exit ]
  %common.ret.op.i25 = phi ptr [ %newStackPointer.i38, %realloc.i26 ], [ %currentStackPointer.i20, %resume.exit ]
  store ptr %nextStackPointer.sink.i24, ptr %stackPointer_pointer.i18, align 8
  store ptr %prompt.i13, ptr %common.ret.op.i25, align 8, !noalias !0
  %stackPointer_379.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i25, i64 8
  store i64 %offset.i9, ptr %stackPointer_379.repack1, align 8, !noalias !0
  %returnAddress_pointer_381 = getelementptr i8, ptr %common.ret.op.i25, i64 16
  %sharer_pointer_382 = getelementptr i8, ptr %common.ret.op.i25, i64 24
  %eraser_pointer_383 = getelementptr i8, ptr %common.ret.op.i25, i64 32
  store ptr @returnAddress_363, ptr %returnAddress_pointer_381, align 8, !noalias !0
  store ptr @sharer_372, ptr %sharer_pointer_382, align 8, !noalias !0
  store ptr @eraser_376, ptr %eraser_pointer_383, align 8, !noalias !0
  %base_pointer.i = getelementptr i8, ptr %start.i, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i18, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt.i42 = load ptr, ptr %prompt_pointer1.i.i, align 8
  %nextStackPointer.i47 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i48 = icmp ugt ptr %nextStackPointer.i47, %limit.i46
  br i1 %isInside.not.i48, label %realloc.i51, label %stackAllocate.exit65

realloc.i51:                                      ; preds = %stackAllocate.exit40
  %nextSize.i57 = add i64 %offset.i, 32
  %leadingZeros.i.i58 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i57, i1 false)
  %numBits.i.i59 = sub nuw nsw i64 64, %leadingZeros.i.i58
  %result.i.i60 = shl nuw i64 1, %numBits.i.i59
  %newBase.i61 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i60)
  %newLimit.i62 = getelementptr i8, ptr %newBase.i61, i64 %result.i.i60
  %newStackPointer.i63 = getelementptr i8, ptr %newBase.i61, i64 %offset.i
  %newNextStackPointer.i64 = getelementptr i8, ptr %newStackPointer.i63, i64 32
  store ptr %newBase.i61, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i62, ptr %limit_pointer.i19, align 8, !alias.scope !0
  br label %stackAllocate.exit65

stackAllocate.exit65:                             ; preds = %stackAllocate.exit40, %realloc.i51
  %base.i76 = phi ptr [ %newBase.i61, %realloc.i51 ], [ %base.i, %stackAllocate.exit40 ]
  %limit.i69 = phi ptr [ %newLimit.i62, %realloc.i51 ], [ %limit.i46, %stackAllocate.exit40 ]
  %nextStackPointer.sink.i49 = phi ptr [ %newNextStackPointer.i64, %realloc.i51 ], [ %nextStackPointer.i47, %stackAllocate.exit40 ]
  %common.ret.op.i50 = phi ptr [ %newStackPointer.i63, %realloc.i51 ], [ %stackPointer.i, %stackAllocate.exit40 ]
  store ptr %nextStackPointer.sink.i49, ptr %stackPointer_pointer.i18, align 8
  store i64 74755, ptr %common.ret.op.i50, align 4, !noalias !0
  %returnAddress_pointer_395 = getelementptr i8, ptr %common.ret.op.i50, i64 8
  %sharer_pointer_396 = getelementptr i8, ptr %common.ret.op.i50, i64 16
  %eraser_pointer_397 = getelementptr i8, ptr %common.ret.op.i50, i64 24
  store ptr @returnAddress_384, ptr %returnAddress_pointer_395, align 8, !noalias !0
  store ptr @sharer_350, ptr %sharer_pointer_396, align 8, !noalias !0
  store ptr @eraser_354, ptr %eraser_pointer_397, align 8, !noalias !0
  %nextStackPointer.i70 = getelementptr i8, ptr %nextStackPointer.sink.i49, i64 24
  %isInside.not.i71 = icmp ugt ptr %nextStackPointer.i70, %limit.i69
  br i1 %isInside.not.i71, label %realloc.i74, label %stackAllocate.exit88

realloc.i74:                                      ; preds = %stackAllocate.exit65
  %intStackPointer.i77 = ptrtoint ptr %nextStackPointer.sink.i49 to i64
  %intBase.i78 = ptrtoint ptr %base.i76 to i64
  %size.i79 = sub i64 %intStackPointer.i77, %intBase.i78
  %nextSize.i80 = add i64 %size.i79, 24
  %leadingZeros.i.i81 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i80, i1 false)
  %numBits.i.i82 = sub nuw nsw i64 64, %leadingZeros.i.i81
  %result.i.i83 = shl nuw i64 1, %numBits.i.i82
  %newBase.i84 = tail call ptr @realloc(ptr %base.i76, i64 %result.i.i83)
  %newLimit.i85 = getelementptr i8, ptr %newBase.i84, i64 %result.i.i83
  %newStackPointer.i86 = getelementptr i8, ptr %newBase.i84, i64 %size.i79
  %newNextStackPointer.i87 = getelementptr i8, ptr %newStackPointer.i86, i64 24
  store ptr %newBase.i84, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i85, ptr %limit_pointer.i19, align 8, !alias.scope !0
  br label %stackAllocate.exit88

stackAllocate.exit88:                             ; preds = %stackAllocate.exit65, %realloc.i74
  %base.i.i = phi ptr [ %newBase.i84, %realloc.i74 ], [ %base.i76, %stackAllocate.exit65 ]
  %limit.i.i = phi ptr [ %newLimit.i85, %realloc.i74 ], [ %limit.i69, %stackAllocate.exit65 ]
  %nextStackPointer.sink.i72 = phi ptr [ %newNextStackPointer.i87, %realloc.i74 ], [ %nextStackPointer.i70, %stackAllocate.exit65 ]
  %common.ret.op.i73 = phi ptr [ %newStackPointer.i86, %realloc.i74 ], [ %nextStackPointer.sink.i49, %stackAllocate.exit65 ]
  store ptr %nextStackPointer.sink.i72, ptr %stackPointer_pointer.i18, align 8
  %sharer_pointer_665 = getelementptr i8, ptr %common.ret.op.i73, i64 8
  %eraser_pointer_666 = getelementptr i8, ptr %common.ret.op.i73, i64 16
  store ptr @returnAddress_658, ptr %common.ret.op.i73, align 8, !noalias !0
  store ptr @sharer_38, ptr %sharer_pointer_665, align 8, !noalias !0
  store ptr @eraser_40, ptr %eraser_pointer_666, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i72, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit88
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i72 to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 64
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i91 = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i91, i64 64
  store ptr %newBase.i.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i19, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit88
  %limit.i9.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %stackAllocate.exit88 ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit88 ]
  %common.ret.op.i.i89 = phi ptr [ %newStackPointer.i.i91, %realloc.i.i ], [ %nextStackPointer.sink.i72, %stackAllocate.exit88 ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i18, align 8
  store ptr %prompt.i42, ptr %common.ret.op.i.i89, align 8, !noalias !0
  %stackPointer_646.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i89, i64 8
  store i64 %offset.i, ptr %stackPointer_646.repack1.i, align 8, !noalias !0
  %depth_5_4_4366_pointer_648.i = getelementptr i8, ptr %common.ret.op.i.i89, i64 16
  store i64 %n_2860, ptr %depth_5_4_4366_pointer_648.i, align 4, !noalias !0
  %count_2881_pointer_649.i = getelementptr i8, ptr %common.ret.op.i.i89, i64 24
  store ptr %prompt.i13, ptr %count_2881_pointer_649.i, align 8, !noalias !0
  %count_2881_pointer_649.repack3.i = getelementptr i8, ptr %common.ret.op.i.i89, i64 32
  store i64 %offset.i9, ptr %count_2881_pointer_649.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_650.i = getelementptr i8, ptr %common.ret.op.i.i89, i64 40
  %sharer_pointer_651.i = getelementptr i8, ptr %common.ret.op.i.i89, i64 48
  %eraser_pointer_652.i = getelementptr i8, ptr %common.ret.op.i.i89, i64 56
  store ptr @returnAddress_398, ptr %returnAddress_pointer_650.i, align 8, !noalias !0
  store ptr @sharer_540, ptr %sharer_pointer_651.i, align 8, !noalias !0
  store ptr @eraser_548, ptr %eraser_pointer_652.i, align 8, !noalias !0
  %stack_pointer.i.i.i90 = getelementptr i8, ptr %prompt.i13, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i90, align 8
  %base_pointer.i5.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i6.i = load ptr, ptr %base_pointer.i5.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i6.i, i64 %offset.i9
  %get_5282.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i9.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i10.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i10.i, ptr %stackPointer_pointer.i18, align 8, !alias.scope !0
  %returnAddress_655.i = load ptr, ptr %newStackPointer.i10.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_655.i(i64 %get_5282.i, ptr nonnull %start.i)
  ret void
}

define tailcc void @returnAddress_667(%Pos %v_r_3239_4037, ptr %stack) {
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
  %index_2107_pointer_670 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_670, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_672 = extractvalue %Pos %v_r_3239_4037, 0
  switch i64 %tag_672, label %label_674 [
    i64 0, label %label_678
    i64 1, label %label_684
  ]

label_674:                                        ; preds = %entry
  ret void

label_678:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_678
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

eraseNegative.exit:                               ; preds = %label_678, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_675 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_675(i64 %x.i, ptr nonnull %stack)
  ret void

label_684:                                        ; preds = %entry
  %Exception_2362_pointer_671 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_671, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_5234 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5234.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5234, %Pos %z.i)
  %utf8StringLiteral_5236 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_5236.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5236)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_5239 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5239.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_5239)
  %functionPointer_683 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_683(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_688(ptr %stackPointer) {
entry:
  %str_2106_685.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_685.unpack2 = load ptr, ptr %str_2106_685.elt1, align 8, !noalias !0
  %Exception_2362_687.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_687.unpack5 = load ptr, ptr %Exception_2362_687.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_685.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_685.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_685.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_687.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_687.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_687.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_696(ptr %stackPointer) {
entry:
  %str_2106_693.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_693.unpack2 = load ptr, ptr %str_2106_693.elt1, align 8, !noalias !0
  %Exception_2362_695.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_695.unpack5 = load ptr, ptr %Exception_2362_695.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_693.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_693.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_693.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_693.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_693.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_693.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_695.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_695.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_695.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_695.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_695.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_695.unpack5)
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
  %stackPointer_701.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_701.repack1, align 8, !noalias !0
  %index_2107_pointer_703 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_703, align 4, !noalias !0
  %Exception_2362_pointer_704 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_704, align 8, !noalias !0
  %Exception_2362_pointer_704.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_704.repack3, align 8, !noalias !0
  %returnAddress_pointer_705 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_706 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_707 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_667, ptr %returnAddress_pointer_705, align 8, !noalias !0
  store ptr @sharer_688, ptr %sharer_pointer_706, align 8, !noalias !0
  store ptr @eraser_696, ptr %eraser_pointer_707, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_714, label %label_719

label_714:                                        ; preds = %stackAllocate.exit
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
  %returnAddress_711 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_711(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_719:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_719
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

erasePositive.exit:                               ; preds = %label_719, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_716 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_716(%Pos { i64 1, ptr null }, ptr nonnull %stack)
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
  store ptr %stack.i2.i.i, ptr getelementptr inbounds (i8, ptr @global, i64 8), align 8
  %sharerPointer.i.i = getelementptr i8, ptr %stackPointer.i.i3.i.i, i64 8
  %eraserPointer.i.i = getelementptr i8, ptr %stackPointer.i.i3.i.i, i64 16
  store ptr @topLevel, ptr %stackPointer.i.i3.i.i, align 8
  store ptr @topLevelSharer, ptr %sharerPointer.i.i, align 8
  store ptr @topLevelEraser, ptr %eraserPointer.i.i, align 8
  %stackPointer_2.i.i = getelementptr i8, ptr %stackPointer.i.i3.i.i, i64 24
  store ptr %stackPointer_2.i.i, ptr %stack.repack1.i5.i.i, align 8
  tail call tailcc void @main_2862(ptr nonnull %stack.i2.i.i)
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
  store ptr %stack.i2.i, ptr getelementptr inbounds (i8, ptr @global, i64 8), align 8
  %sharerPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 8
  %eraserPointer.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 16
  store ptr @topLevel, ptr %stackPointer.i.i3.i, align 8
  store ptr @topLevelSharer, ptr %sharerPointer.i, align 8
  store ptr @topLevelEraser, ptr %eraserPointer.i, align 8
  %stackPointer_2.i = getelementptr i8, ptr %stackPointer.i.i3.i, i64 24
  store ptr %stackPointer_2.i, ptr %stack.repack1.i5.i, align 8
  musttail call tailcc void @main_2862(ptr nonnull %stack.i2.i)
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
