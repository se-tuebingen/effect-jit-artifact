; ModuleID = '/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:to_outermost_handler_80274a87-7575-40e0-b4a1-04ef877fc8bf/main.ll'
source_filename = "/Users/gaisseml/dev/effect-jit/.effekt-out/effekt-llvm:to_outermost_handler_80274a87-7575-40e0-b4a1-04ef877fc8bf/main.ll"

%Pos = type { i64, ptr }
%Neg = type { ptr, ptr }
%Reference = type { ptr, i64 }

@vtable_146 = private constant [1 x ptr] [ptr @Exception_9_10_4587_clause_138]
@vtable_280 = private constant [1 x ptr] [ptr @Exception_9_10_4196_clause_272]
@utf8StringLiteral_5410.lit = private constant [0 x i8] zeroinitializer
@utf8StringLiteral_5342.lit = private constant [21 x i8] c"Index out of bounds: "
@utf8StringLiteral_5344.lit = private constant [13 x i8] c" in string: '"
@utf8StringLiteral_5347.lit = private constant [1 x i8] c"'"
@utf8StringLiteral_5298.lit = private constant [21 x i8] c"Not a valid number: '"
@utf8StringLiteral_5300.lit = private constant [1 x i8] c"'"
@utf8StringLiteral_5305.lit = private constant [21 x i8] c"Not a valid number: '"
@utf8StringLiteral_5307.lit = private constant [1 x i8] c"'"
@vtable_526 = private constant [1 x ptr] [ptr @Exception_7_3739_clause_511]
@utf8StringLiteral_5325.lit = private constant [34 x i8] c"Empty string is not a valid number"
@vtable_574 = private constant [1 x ptr] [ptr @Exception_9_3810_clause_563]

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

define tailcc void @returnAddress_5(%Pos %v_coe_3493_240_4992, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3493_240_4992, 0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %unboxed.i)
  tail call void @c_io_println_String(%Pos %z.i)
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i4 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i5 = icmp ule ptr %stackPointer.i2, %limit.i4
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_6 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_6(%Pos zeroinitializer, ptr %stack)
  ret void
}

define void @sharer_9(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -16
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_11(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -8
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_17(%Pos %returnValue_18, ptr %stack) {
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
  %returnAddress_21 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_21(%Pos %returnValue_18, ptr %stack)
  ret void
}

define void @sharer_25(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -24
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_29(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -16
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_40(%Pos %returnValue_41, ptr %stack) {
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
  %returnAddress_44 = load ptr, ptr %newStackPointer.i6, align 8, !noalias !0
  musttail call tailcc void %returnAddress_44(%Pos %returnValue_41, ptr %stack)
  ret void
}

define tailcc void @returnAddress_61(%Pos %__20_6_222_5147, ptr %stack) {
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
  %v_6_96_4991.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %v_6_96_4991.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_6_96_4991.unpack2 = load i64, ptr %v_6_96_4991.elt1, align 8, !noalias !0
  %object.i = extractvalue %Pos %__20_6_222_5147, 1
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
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 40
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %erasePositive.exit
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
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 40
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %erasePositive.exit
  %limit.i7.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %erasePositive.exit ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %erasePositive.exit ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %erasePositive.exit ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i, align 8
  store ptr %v_6_96_4991.unpack, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_90.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store i64 %v_6_96_4991.unpack2, ptr %stackPointer_90.repack1.i, align 8, !noalias !0
  %returnAddress_pointer_92.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %sharer_pointer_93.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  %eraser_pointer_94.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr @returnAddress_55, ptr %returnAddress_pointer_92.i, align 8, !noalias !0
  store ptr @sharer_65, ptr %sharer_pointer_93.i, align 8, !noalias !0
  store ptr @eraser_69, ptr %eraser_pointer_94.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %v_6_96_4991.unpack, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i3.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i4.i = load ptr, ptr %base_pointer.i3.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i4.i, i64 %v_6_96_4991.unpack2
  %get_5368.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i7.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i8.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i8.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_97.i = load ptr, ptr %newStackPointer.i8.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_97.i(i64 %get_5368.i, ptr nonnull %stack)
  ret void
}

define void @sharer_65(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_69(ptr %stackPointer) {
entry:
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_55(i64 %i_4_2_8_27_72_215_4951, ptr %stack) {
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
  %z.i = icmp eq i64 %i_4_2_8_27_72_215_4951, 0
  br i1 %z.i, label %label_87, label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry
  %v_6_96_4991.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %v_6_96_4991.unpack2 = load i64, ptr %v_6_96_4991.elt1, align 8, !noalias !0
  %v_6_96_4991.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %z.i11 = add i64 %i_4_2_8_27_72_215_4951, -1
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %v_6_96_4991.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_72.repack4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store i64 %v_6_96_4991.unpack2, ptr %stackPointer_72.repack4, align 8, !noalias !0
  %sharer_pointer_75 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_76 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_61, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_65, ptr %sharer_pointer_75, align 8, !noalias !0
  store ptr @eraser_69, ptr %eraser_pointer_76, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %v_6_96_4991.unpack, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i16 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i17 = load ptr, ptr %base_pointer.i16, align 8
  %varPointer.i = getelementptr i8, ptr %base.i17, i64 %v_6_96_4991.unpack2
  store i64 %z.i11, ptr %varPointer.i, align 4, !noalias !0
  store ptr %stackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_80 = load ptr, ptr %stackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_80(%Pos zeroinitializer, ptr nonnull %stack)
  ret void

label_87:                                         ; preds = %entry
  %isInside.i28 = icmp ule ptr %newStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i, i64 -40
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_84 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_84(i64 0, ptr nonnull %stack)
  ret void
}

define tailcc void @countdown_worker_3_1_7_26_71_209_5099(%Reference %v_6_96_4991, ptr %stack) local_unnamed_addr {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 40
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
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

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i7 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %v_6_96_4991.elt = extractvalue %Reference %v_6_96_4991, 0
  store ptr %v_6_96_4991.elt, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_90.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  %v_6_96_4991.elt2 = extractvalue %Reference %v_6_96_4991, 1
  store i64 %v_6_96_4991.elt2, ptr %stackPointer_90.repack1, align 8, !noalias !0
  %returnAddress_pointer_92 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_93 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_94 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_55, ptr %returnAddress_pointer_92, align 8, !noalias !0
  store ptr @sharer_65, ptr %sharer_pointer_93, align 8, !noalias !0
  store ptr @eraser_69, ptr %eraser_pointer_94, align 8, !noalias !0
  %stack_pointer.i.i = getelementptr i8, ptr %v_6_96_4991.elt, i64 8
  %stack.i.i = load ptr, ptr %stack_pointer.i.i, align 8
  %base_pointer.i3 = getelementptr i8, ptr %stack.i.i, i64 16
  %base.i4 = load ptr, ptr %base_pointer.i3, align 8
  %varPointer.i = getelementptr i8, ptr %base.i4, i64 %v_6_96_4991.elt2
  %get_5368 = load i64, ptr %varPointer.i, align 4, !noalias !0
  %isInside.i = icmp ule ptr %nextStackPointer.sink.i, %limit.i7
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i8 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 -24
  store ptr %newStackPointer.i8, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_97 = load ptr, ptr %newStackPointer.i8, align 8, !noalias !0
  musttail call tailcc void %returnAddress_97(i64 %get_5368, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_100(i64 %v_coe_3488_12_31_76_224_5060, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3488_12_31_76_224_5060, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_101 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_101(%Pos %boxed2.i, ptr %stack)
  ret void
}

define tailcc void @pad_worker_5_17_62_190_5102(i64 %d_6_18_63_191_5004, %Reference %v_6_96_4991, ptr %stack) local_unnamed_addr {
entry:
  %z.i30 = icmp eq i64 %d_6_18_63_191_5004, 0
  %stackPointer_pointer.i7.phi.trans.insert = getelementptr i8, ptr %stack, i64 8
  br i1 %z.i30, label %entry.label_108_crit_edge, label %label_54.lr.ph

entry.label_108_crit_edge:                        ; preds = %entry
  %currentStackPointer.i9.pre = load ptr, ptr %stackPointer_pointer.i7.phi.trans.insert, align 8, !alias.scope !0
  %limit_pointer.i8.phi.trans.insert = getelementptr i8, ptr %stack, i64 24
  %limit.i10.pre = load ptr, ptr %limit_pointer.i8.phi.trans.insert, align 8, !alias.scope !0
  br label %label_108

label_54.lr.ph:                                   ; preds = %entry
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %limit.i.pre = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %label_54

label_54:                                         ; preds = %label_54.lr.ph, %stackAllocate.exit
  %limit.i = phi ptr [ %limit.i.pre, %label_54.lr.ph ], [ %limit.i32, %stackAllocate.exit ]
  %d_6_18_63_191_5004.tr31 = phi i64 [ %d_6_18_63_191_5004, %label_54.lr.ph ], [ %z.i6, %stackAllocate.exit ]
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i7.phi.trans.insert, align 8
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %label_54
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
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

stackAllocate.exit:                               ; preds = %label_54, %realloc.i
  %limit.i32 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %label_54 ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %label_54 ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %stackPointer.i, %label_54 ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i7.phi.trans.insert, align 8
  store i64 -377, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_51 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_52 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_53 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_40, ptr %returnAddress_pointer_51, align 8, !noalias !0
  store ptr @sharer_25, ptr %sharer_pointer_52, align 8, !noalias !0
  store ptr @eraser_29, ptr %eraser_pointer_53, align 8, !noalias !0
  %z.i6 = add i64 %d_6_18_63_191_5004.tr31, -1
  %z.i = icmp eq i64 %z.i6, 0
  br i1 %z.i, label %label_108, label %label_54

label_108:                                        ; preds = %stackAllocate.exit, %entry.label_108_crit_edge
  %limit.i.i.pre = phi ptr [ %limit.i10.pre, %entry.label_108_crit_edge ], [ %limit.i32, %stackAllocate.exit ]
  %currentStackPointer.i9 = phi ptr [ %currentStackPointer.i9.pre, %entry.label_108_crit_edge ], [ %nextStackPointer.sink.i, %stackAllocate.exit ]
  %stackPointer_pointer.i7 = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i8 = getelementptr i8, ptr %stack, i64 24
  %nextStackPointer.i11 = getelementptr i8, ptr %currentStackPointer.i9, i64 24
  %isInside.not.i12 = icmp ugt ptr %nextStackPointer.i11, %limit.i.i.pre
  br i1 %isInside.not.i12, label %realloc.i15, label %stackAllocate.exit29

realloc.i15:                                      ; preds = %label_108
  %base_pointer.i16 = getelementptr i8, ptr %stack, i64 16
  %base.i17 = load ptr, ptr %base_pointer.i16, align 8, !alias.scope !0
  %intStackPointer.i18 = ptrtoint ptr %currentStackPointer.i9 to i64
  %intBase.i19 = ptrtoint ptr %base.i17 to i64
  %size.i20 = sub i64 %intStackPointer.i18, %intBase.i19
  %nextSize.i21 = add i64 %size.i20, 24
  %leadingZeros.i.i22 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i21, i1 false)
  %numBits.i.i23 = sub nuw nsw i64 64, %leadingZeros.i.i22
  %result.i.i24 = shl nuw i64 1, %numBits.i.i23
  %newBase.i25 = tail call ptr @realloc(ptr %base.i17, i64 %result.i.i24)
  %newLimit.i26 = getelementptr i8, ptr %newBase.i25, i64 %result.i.i24
  %newStackPointer.i27 = getelementptr i8, ptr %newBase.i25, i64 %size.i20
  %newNextStackPointer.i28 = getelementptr i8, ptr %newStackPointer.i27, i64 24
  store ptr %newBase.i25, ptr %base_pointer.i16, align 8, !alias.scope !0
  store ptr %newLimit.i26, ptr %limit_pointer.i8, align 8, !alias.scope !0
  br label %stackAllocate.exit29

stackAllocate.exit29:                             ; preds = %label_108, %realloc.i15
  %limit.i.i = phi ptr [ %newLimit.i26, %realloc.i15 ], [ %limit.i.i.pre, %label_108 ]
  %nextStackPointer.sink.i13 = phi ptr [ %newNextStackPointer.i28, %realloc.i15 ], [ %nextStackPointer.i11, %label_108 ]
  %common.ret.op.i14 = phi ptr [ %newStackPointer.i27, %realloc.i15 ], [ %currentStackPointer.i9, %label_108 ]
  store ptr %nextStackPointer.sink.i13, ptr %stackPointer_pointer.i7, align 8
  %sharer_pointer_106 = getelementptr i8, ptr %common.ret.op.i14, i64 8
  %eraser_pointer_107 = getelementptr i8, ptr %common.ret.op.i14, i64 16
  store ptr @returnAddress_100, ptr %common.ret.op.i14, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_106, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_107, align 8, !noalias !0
  %nextStackPointer.i.i = getelementptr i8, ptr %nextStackPointer.sink.i13, i64 40
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %stackAllocate.exit29
  %base_pointer.i.i = getelementptr i8, ptr %stack, i64 16
  %base.i.i = load ptr, ptr %base_pointer.i.i, align 8, !alias.scope !0
  %intStackPointer.i.i = ptrtoint ptr %nextStackPointer.sink.i13 to i64
  %intBase.i.i = ptrtoint ptr %base.i.i to i64
  %size.i.i = sub i64 %intStackPointer.i.i, %intBase.i.i
  %nextSize.i.i = add i64 %size.i.i, 40
  %leadingZeros.i.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i.i, i1 false)
  %numBits.i.i.i = sub nuw nsw i64 64, %leadingZeros.i.i.i
  %result.i.i.i = shl nuw i64 1, %numBits.i.i.i
  %newBase.i.i = tail call ptr @realloc(ptr %base.i.i, i64 %result.i.i.i)
  %newLimit.i.i = getelementptr i8, ptr %newBase.i.i, i64 %result.i.i.i
  %newStackPointer.i.i = getelementptr i8, ptr %newBase.i.i, i64 %size.i.i
  %newNextStackPointer.i.i = getelementptr i8, ptr %newStackPointer.i.i, i64 40
  store ptr %newBase.i.i, ptr %base_pointer.i.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %limit_pointer.i8, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %stackAllocate.exit29
  %limit.i7.i = phi ptr [ %newLimit.i.i, %realloc.i.i ], [ %limit.i.i, %stackAllocate.exit29 ]
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %stackAllocate.exit29 ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.sink.i13, %stackAllocate.exit29 ]
  store ptr %nextStackPointer.sink.i.i, ptr %stackPointer_pointer.i7, align 8
  %v_6_96_4991.elt.i = extractvalue %Reference %v_6_96_4991, 0
  store ptr %v_6_96_4991.elt.i, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_90.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  %v_6_96_4991.elt2.i = extractvalue %Reference %v_6_96_4991, 1
  store i64 %v_6_96_4991.elt2.i, ptr %stackPointer_90.repack1.i, align 8, !noalias !0
  %returnAddress_pointer_92.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  %sharer_pointer_93.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  %eraser_pointer_94.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr @returnAddress_55, ptr %returnAddress_pointer_92.i, align 8, !noalias !0
  store ptr @sharer_65, ptr %sharer_pointer_93.i, align 8, !noalias !0
  store ptr @eraser_69, ptr %eraser_pointer_94.i, align 8, !noalias !0
  %stack_pointer.i.i.i = getelementptr i8, ptr %v_6_96_4991.elt.i, i64 8
  %stack.i.i.i = load ptr, ptr %stack_pointer.i.i.i, align 8
  %base_pointer.i3.i = getelementptr i8, ptr %stack.i.i.i, i64 16
  %base.i4.i = load ptr, ptr %base_pointer.i3.i, align 8
  %varPointer.i.i = getelementptr i8, ptr %base.i4.i, i64 %v_6_96_4991.elt2.i
  %get_5368.i = load i64, ptr %varPointer.i.i, align 4, !noalias !0
  %isInside.i.i = icmp ule ptr %nextStackPointer.sink.i.i, %limit.i7.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i8.i = getelementptr i8, ptr %nextStackPointer.sink.i.i, i64 -24
  store ptr %newStackPointer.i8.i, ptr %stackPointer_pointer.i7, align 8, !alias.scope !0
  %returnAddress_97.i = load ptr, ptr %newStackPointer.i8.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_97.i(i64 %get_5368.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_109(%Pos %v_coe_3489_42_87_235_4986, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3489_42_87_235_4986, 0
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %unboxed.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_110 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_110(%Pos %boxed2.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_2(%Pos %v_coe_3514_3602, ptr %stack) {
entry:
  %stackPointer_pointer.i1 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i2 = load ptr, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %isInside.i7 = icmp ule ptr %stackPointer.i2, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 -8
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i1, align 8, !alias.scope !0
  %tmp_5291 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i2, i64 16
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i11 = getelementptr i8, ptr %stack, i64 16
  %base.i12 = load ptr, ptr %base_pointer.i11, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %newStackPointer.i to i64
  %intBase.i13 = ptrtoint ptr %base.i12 to i64
  %size.i = sub i64 %intStackPointer.i, %intBase.i13
  %nextSize.i = add i64 %size.i, 24
  %leadingZeros.i.i = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i, i1 false)
  %numBits.i.i = sub nuw nsw i64 64, %leadingZeros.i.i
  %result.i.i = shl nuw i64 1, %numBits.i.i
  %newBase.i = tail call ptr @realloc(ptr %base.i12, i64 %result.i.i)
  %newLimit.i = getelementptr i8, ptr %newBase.i, i64 %result.i.i
  %newStackPointer.i14 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i14, i64 24
  store ptr %newBase.i, ptr %base_pointer.i11, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %limit.i19 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i14, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i1, align 8
  %sharer_pointer_15 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_16 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_5, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_15, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_16, align 8, !noalias !0
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i1, align 8
  %base.i = load ptr, ptr %base_pointer.i, align 8
  %intStack.i = ptrtoint ptr %stackPointer.i to i64
  %intBase.i = ptrtoint ptr %base.i to i64
  %offset.i = sub i64 %intStack.i, %intBase.i
  %prompt_pointer.i = getelementptr i8, ptr %stack, i64 32
  %prompt.i15 = load ptr, ptr %prompt_pointer.i, align 8
  %nextStackPointer.i20 = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i21 = icmp ugt ptr %nextStackPointer.i20, %limit.i19
  br i1 %isInside.not.i21, label %realloc.i24, label %stackAllocate.exit38

realloc.i24:                                      ; preds = %stackAllocate.exit
  %nextSize.i30 = add i64 %offset.i, 32
  %leadingZeros.i.i31 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i30, i1 false)
  %numBits.i.i32 = sub nuw nsw i64 64, %leadingZeros.i.i31
  %result.i.i33 = shl nuw i64 1, %numBits.i.i32
  %newBase.i34 = tail call ptr @realloc(ptr %base.i, i64 %result.i.i33)
  %newLimit.i35 = getelementptr i8, ptr %newBase.i34, i64 %result.i.i33
  %newStackPointer.i36 = getelementptr i8, ptr %newBase.i34, i64 %offset.i
  %newNextStackPointer.i37 = getelementptr i8, ptr %newStackPointer.i36, i64 32
  store ptr %newBase.i34, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i35, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit38

stackAllocate.exit38:                             ; preds = %stackAllocate.exit, %realloc.i24
  %base.i49 = phi ptr [ %newBase.i34, %realloc.i24 ], [ %base.i, %stackAllocate.exit ]
  %limit.i42 = phi ptr [ %newLimit.i35, %realloc.i24 ], [ %limit.i19, %stackAllocate.exit ]
  %nextStackPointer.sink.i22 = phi ptr [ %newNextStackPointer.i37, %realloc.i24 ], [ %nextStackPointer.i20, %stackAllocate.exit ]
  %common.ret.op.i23 = phi ptr [ %newStackPointer.i36, %realloc.i24 ], [ %stackPointer.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i22, ptr %stackPointer_pointer.i1, align 8
  store i64 %tmp_5291, ptr %common.ret.op.i23, align 4, !noalias !0
  %returnAddress_pointer_34 = getelementptr i8, ptr %common.ret.op.i23, i64 8
  %sharer_pointer_35 = getelementptr i8, ptr %common.ret.op.i23, i64 16
  %eraser_pointer_36 = getelementptr i8, ptr %common.ret.op.i23, i64 24
  store ptr @returnAddress_17, ptr %returnAddress_pointer_34, align 8, !noalias !0
  store ptr @sharer_25, ptr %sharer_pointer_35, align 8, !noalias !0
  store ptr @eraser_29, ptr %eraser_pointer_36, align 8, !noalias !0
  %nextStackPointer.i43 = getelementptr i8, ptr %nextStackPointer.sink.i22, i64 24
  %isInside.not.i44 = icmp ugt ptr %nextStackPointer.i43, %limit.i42
  br i1 %isInside.not.i44, label %realloc.i47, label %stackAllocate.exit61

realloc.i47:                                      ; preds = %stackAllocate.exit38
  %intStackPointer.i50 = ptrtoint ptr %nextStackPointer.sink.i22 to i64
  %intBase.i51 = ptrtoint ptr %base.i49 to i64
  %size.i52 = sub i64 %intStackPointer.i50, %intBase.i51
  %nextSize.i53 = add i64 %size.i52, 24
  %leadingZeros.i.i54 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i53, i1 false)
  %numBits.i.i55 = sub nuw nsw i64 64, %leadingZeros.i.i54
  %result.i.i56 = shl nuw i64 1, %numBits.i.i55
  %newBase.i57 = tail call ptr @realloc(ptr %base.i49, i64 %result.i.i56)
  %newLimit.i58 = getelementptr i8, ptr %newBase.i57, i64 %result.i.i56
  %newStackPointer.i59 = getelementptr i8, ptr %newBase.i57, i64 %size.i52
  %newNextStackPointer.i60 = getelementptr i8, ptr %newStackPointer.i59, i64 24
  store ptr %newBase.i57, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i58, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit61

stackAllocate.exit61:                             ; preds = %stackAllocate.exit38, %realloc.i47
  %nextStackPointer.sink.i45 = phi ptr [ %newNextStackPointer.i60, %realloc.i47 ], [ %nextStackPointer.i43, %stackAllocate.exit38 ]
  %common.ret.op.i46 = phi ptr [ %newStackPointer.i59, %realloc.i47 ], [ %nextStackPointer.sink.i22, %stackAllocate.exit38 ]
  %reference..1.i = insertvalue %Reference undef, ptr %prompt.i15, 0
  %reference.i = insertvalue %Reference %reference..1.i, i64 %offset.i, 1
  %unboxed.i = extractvalue %Pos %v_coe_3514_3602, 0
  store ptr %nextStackPointer.sink.i45, ptr %stackPointer_pointer.i1, align 8
  %sharer_pointer_115 = getelementptr i8, ptr %common.ret.op.i46, i64 8
  %eraser_pointer_116 = getelementptr i8, ptr %common.ret.op.i46, i64 16
  store ptr @returnAddress_109, ptr %common.ret.op.i46, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_115, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_116, align 8, !noalias !0
  musttail call tailcc void @pad_worker_5_17_62_190_5102(i64 %unboxed.i, %Reference %reference.i, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_125(%Pos %returned_5372, ptr nocapture %stack) {
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
  %returnAddress_127 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_127(%Pos %returned_5372, ptr %rest.i)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @sharer_130(ptr nocapture readnone %stackPointer) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
define void @eraser_132(ptr nocapture %stackPointer) #10 {
entry:
  tail call void @free(ptr %stackPointer)
  ret void
}

define tailcc void @Exception_9_10_4587_clause_138(ptr %closure, %Pos %exception_10_11_4593, %Pos %msg_11_12_4595, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4590 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_11_4593, 1
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
  %object.i = extractvalue %Pos %msg_11_12_4595, 1
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
  %pair_141 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4590)
  %k_13_14_4596 = extractvalue <{ ptr, ptr }> %pair_141, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4596, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4596, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4596, i64 40
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
  %stack_142 = extractvalue <{ ptr, ptr }> %pair_141, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_142, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_142, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_143 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_143(%Pos { i64 10, ptr null }, ptr %stack_142)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define void @eraser_150(ptr nocapture readnone %environment) #5 {
entry:
  ret void
}

define tailcc void @returnAddress_154(%Pos %v_coe_3509_157_317_4763, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3509_157_317_4763, 0
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %unboxed.i, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_155 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_155(%Pos %boxed2.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_163(%Pos %returned_5377, ptr nocapture %stack) {
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
  %returnAddress_165 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_165(%Pos %returned_5377, ptr %rest.i)
  ret void
}

define void @eraser_179(ptr nocapture readonly %environment) {
entry:
  %tmp_5263_177.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %tmp_5263_177.unpack2 = load ptr, ptr %tmp_5263_177.elt1, align 8, !noalias !0
  %acc_3_3_5_37_118_278_4820_178.elt4 = getelementptr i8, ptr %environment, i64 24
  %acc_3_3_5_37_118_278_4820_178.unpack5 = load ptr, ptr %acc_3_3_5_37_118_278_4820_178.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %tmp_5263_177.unpack2, null
  br i1 %isNull.i.i7, label %erasePositive.exit17, label %next.i.i8

next.i.i8:                                        ; preds = %entry
  %referenceCount.i.i9 = load i64, ptr %tmp_5263_177.unpack2, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %tmp_5263_177.unpack2, align 4
  br label %erasePositive.exit17

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %tmp_5263_177.unpack2, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %tmp_5263_177.unpack2, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %tmp_5263_177.unpack2)
  br label %erasePositive.exit17

erasePositive.exit17:                             ; preds = %entry, %decr.i.i11, %free.i.i13
  %isNull.i.i = icmp eq ptr %acc_3_3_5_37_118_278_4820_178.unpack5, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %erasePositive.exit17
  %referenceCount.i.i = load i64, ptr %acc_3_3_5_37_118_278_4820_178.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %acc_3_3_5_37_118_278_4820_178.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %acc_3_3_5_37_118_278_4820_178.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %acc_3_3_5_37_118_278_4820_178.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %acc_3_3_5_37_118_278_4820_178.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit17, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @toList_1_1_3_35_116_276_4668(i64 %start_2_2_4_36_117_277_4869, %Pos %acc_3_3_5_37_118_278_4820, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_36_117_277_4869, 1
  br i1 %z.i6, label %label_189, label %label_185

label_185:                                        ; preds = %entry, %label_185
  %acc_3_3_5_37_118_278_4820.tr8 = phi %Pos [ %make_5383, %label_185 ], [ %acc_3_3_5_37_118_278_4820, %entry ]
  %start_2_2_4_36_117_277_4869.tr7 = phi i64 [ %z.i5, %label_185 ], [ %start_2_2_4_36_117_277_4869, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_36_117_277_4869.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_36_117_277_4869.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_179, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5380.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_5380.elt, ptr %environment.i, align 8, !noalias !0
  %environment_176.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5380.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_5380.elt2, ptr %environment_176.repack1, align 8, !noalias !0
  %acc_3_3_5_37_118_278_4820_pointer_183 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_37_118_278_4820.elt = extractvalue %Pos %acc_3_3_5_37_118_278_4820.tr8, 0
  store i64 %acc_3_3_5_37_118_278_4820.elt, ptr %acc_3_3_5_37_118_278_4820_pointer_183, align 8, !noalias !0
  %acc_3_3_5_37_118_278_4820_pointer_183.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_37_118_278_4820.elt4 = extractvalue %Pos %acc_3_3_5_37_118_278_4820.tr8, 1
  store ptr %acc_3_3_5_37_118_278_4820.elt4, ptr %acc_3_3_5_37_118_278_4820_pointer_183.repack3, align 8, !noalias !0
  %make_5383 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_36_117_277_4869.tr7, 2
  br i1 %z.i, label %label_189, label %label_185

label_189:                                        ; preds = %label_185, %entry
  %acc_3_3_5_37_118_278_4820.tr.lcssa = phi %Pos [ %acc_3_3_5_37_118_278_4820, %entry ], [ %make_5383, %label_185 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_186 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_186(%Pos %acc_3_3_5_37_118_278_4820.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @go_6_14_46_127_287_4683(%Pos %list_7_15_47_128_288_4781, i64 %i_8_16_48_129_289_4727, ptr %p_8_9_75_235_4627, ptr %stack) local_unnamed_addr {
entry:
  br label %tailrecurse

tailrecurse:                                      ; preds = %erasePositive.exit26, %entry
  %list_7_15_47_128_288_4781.tr = phi %Pos [ %list_7_15_47_128_288_4781, %entry ], [ %v_y_2825_20_28_60_151_311_47776, %erasePositive.exit26 ]
  %i_8_16_48_129_289_4727.tr = phi i64 [ %i_8_16_48_129_289_4727, %entry ], [ %z.i, %erasePositive.exit26 ]
  %tag_195 = extractvalue %Pos %list_7_15_47_128_288_4781.tr, 0
  switch i64 %tag_195, label %common.ret [
    i64 0, label %label_203
    i64 1, label %label_215
  ]

common.ret:                                       ; preds = %tailrecurse
  ret void

label_203:                                        ; preds = %tailrecurse
  %pair_198 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_75_235_4627)
  %k_13_14_4_146_306_4907 = extractvalue <{ ptr, ptr }> %pair_198, 0
  %referenceCount.i27 = load i64, ptr %k_13_14_4_146_306_4907, align 4
  %cond.i28 = icmp eq i64 %referenceCount.i27, 0
  br i1 %cond.i28, label %free.i31, label %decr.i29

decr.i29:                                         ; preds = %label_203
  %referenceCount.1.i30 = add i64 %referenceCount.i27, -1
  store i64 %referenceCount.1.i30, ptr %k_13_14_4_146_306_4907, align 4
  br label %eraseResumption.exit

free.i31:                                         ; preds = %label_203
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4_146_306_4907, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i31
  %stack.tr.i = phi ptr [ %stack.i, %free.i31 ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i32

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i32

free.i32:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %eraser.i.i33 = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i33(ptr %newStackPointer.i.i)
  %referenceCount.i.i34 = load i64, ptr %prompt.i, align 4
  %cond.i.i35 = icmp eq i64 %referenceCount.i.i34, 0
  br i1 %cond.i.i35, label %free.i.i37, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i32
  %newReferenceCount.i.i = add i64 %referenceCount.i.i34, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i37:                                       ; preds = %free.i32
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i37, %decrement.i.i
  %isNull.i36 = icmp eq ptr %rest.i, null
  br i1 %isNull.i36, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i29
  %stack_199 = extractvalue <{ ptr, ptr }> %pair_198, 1
  %stackPointer_pointer.i38 = getelementptr i8, ptr %stack_199, i64 8
  %stackPointer.i39 = load ptr, ptr %stackPointer_pointer.i38, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_199, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i39, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i39, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i38, align 8, !alias.scope !0
  %returnAddress_200 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_200(%Pos { i64 10, ptr null }, ptr %stack_199)
  ret void

label_210:                                        ; preds = %eraseObject.exit
  br i1 %isNull.i.i7, label %erasePositive.exit26, label %next.i.i17

next.i.i17:                                       ; preds = %label_210
  %referenceCount.i.i18 = load i64, ptr %v_y_2824_19_27_59_150_310_4695.unpack2, align 4
  %cond.i.i19 = icmp eq i64 %referenceCount.i.i18, 0
  br i1 %cond.i.i19, label %free.i.i22, label %decr.i.i20

decr.i.i20:                                       ; preds = %next.i.i17
  %referenceCount.1.i.i21 = add i64 %referenceCount.i.i18, -1
  store i64 %referenceCount.1.i.i21, ptr %v_y_2824_19_27_59_150_310_4695.unpack2, align 4
  br label %erasePositive.exit26

free.i.i22:                                       ; preds = %next.i.i17
  %objectEraser.i.i23 = getelementptr i8, ptr %v_y_2824_19_27_59_150_310_4695.unpack2, i64 8
  %eraser.i.i24 = load ptr, ptr %objectEraser.i.i23, align 8
  %environment.i.i.i25 = getelementptr i8, ptr %v_y_2824_19_27_59_150_310_4695.unpack2, i64 16
  tail call void %eraser.i.i24(ptr %environment.i.i.i25)
  tail call void @free(ptr nonnull %v_y_2824_19_27_59_150_310_4695.unpack2)
  br label %erasePositive.exit26

erasePositive.exit26:                             ; preds = %label_210, %decr.i.i20, %free.i.i22
  %0 = insertvalue %Pos poison, i64 %v_y_2825_20_28_60_151_311_4777.unpack, 0
  %v_y_2825_20_28_60_151_311_47776 = insertvalue %Pos %0, ptr %v_y_2825_20_28_60_151_311_4777.unpack5, 1
  %z.i = add i64 %i_8_16_48_129_289_4727.tr, -1
  br label %tailrecurse

label_214:                                        ; preds = %eraseObject.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i13

next.i.i13:                                       ; preds = %label_214
  %referenceCount.i.i14 = load i64, ptr %v_y_2825_20_28_60_151_311_4777.unpack5, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i14, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i13
  %referenceCount.1.i.i15 = add i64 %referenceCount.i.i14, -1
  store i64 %referenceCount.1.i.i15, ptr %v_y_2825_20_28_60_151_311_4777.unpack5, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i13
  %objectEraser.i.i = getelementptr i8, ptr %v_y_2825_20_28_60_151_311_4777.unpack5, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_y_2825_20_28_60_151_311_4777.unpack5, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_y_2825_20_28_60_151_311_4777.unpack5)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %label_214, %decr.i.i, %free.i.i
  %1 = insertvalue %Pos poison, i64 %v_y_2824_19_27_59_150_310_4695.unpack, 0
  %v_y_2824_19_27_59_150_310_46953 = insertvalue %Pos %1, ptr %v_y_2824_19_27_59_150_310_4695.unpack2, 1
  %stackPointer_pointer.i40 = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i41 = load ptr, ptr %stackPointer_pointer.i40, align 8, !alias.scope !0
  %limit_pointer.i42 = getelementptr i8, ptr %stack, i64 24
  %limit.i43 = load ptr, ptr %limit_pointer.i42, align 8, !alias.scope !0
  %isInside.i44 = icmp ule ptr %stackPointer.i41, %limit.i43
  tail call void @llvm.assume(i1 %isInside.i44)
  %newStackPointer.i45 = getelementptr i8, ptr %stackPointer.i41, i64 -24
  store ptr %newStackPointer.i45, ptr %stackPointer_pointer.i40, align 8, !alias.scope !0
  %returnAddress_211 = load ptr, ptr %newStackPointer.i45, align 8, !noalias !0
  musttail call tailcc void %returnAddress_211(%Pos %v_y_2824_19_27_59_150_310_46953, ptr %stack)
  ret void

label_215:                                        ; preds = %tailrecurse
  %fields_196 = extractvalue %Pos %list_7_15_47_128_288_4781.tr, 1
  %environment.i = getelementptr i8, ptr %fields_196, i64 16
  %v_y_2824_19_27_59_150_310_4695.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_2824_19_27_59_150_310_4695.elt1 = getelementptr i8, ptr %fields_196, i64 24
  %v_y_2824_19_27_59_150_310_4695.unpack2 = load ptr, ptr %v_y_2824_19_27_59_150_310_4695.elt1, align 8, !noalias !0
  %v_y_2825_20_28_60_151_311_4777_pointer_206 = getelementptr i8, ptr %fields_196, i64 32
  %v_y_2825_20_28_60_151_311_4777.unpack = load i64, ptr %v_y_2825_20_28_60_151_311_4777_pointer_206, align 8, !noalias !0
  %v_y_2825_20_28_60_151_311_4777.elt4 = getelementptr i8, ptr %fields_196, i64 40
  %v_y_2825_20_28_60_151_311_4777.unpack5 = load ptr, ptr %v_y_2825_20_28_60_151_311_4777.elt4, align 8, !noalias !0
  %isNull.i.i7 = icmp eq ptr %v_y_2824_19_27_59_150_310_4695.unpack2, null
  br i1 %isNull.i.i7, label %sharePositive.exit11, label %next.i.i8

next.i.i8:                                        ; preds = %label_215
  %referenceCount.i.i9 = load i64, ptr %v_y_2824_19_27_59_150_310_4695.unpack2, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %v_y_2824_19_27_59_150_310_4695.unpack2, align 4
  br label %sharePositive.exit11

sharePositive.exit11:                             ; preds = %label_215, %next.i.i8
  %isNull.i.i = icmp eq ptr %v_y_2825_20_28_60_151_311_4777.unpack5, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %sharePositive.exit11
  %referenceCount.i.i = load i64, ptr %v_y_2825_20_28_60_151_311_4777.unpack5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2825_20_28_60_151_311_4777.unpack5, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %sharePositive.exit11
  %referenceCount.i = load i64, ptr %fields_196, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_196, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_196, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_196)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %z.i46 = icmp eq i64 %i_8_16_48_129_289_4727.tr, 0
  br i1 %z.i46, label %label_214, label %label_210
}

define tailcc void @returnAddress_219(i64 %v_coe_3507_64_155_315_4863, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3507_64_155_315_4863, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_220 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_220(%Pos %boxed2.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_216(%Pos %v_r_2568_31_63_154_314_4844, ptr %stack) {
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
  %Exception_9_10_4587.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %Exception_9_10_4587.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_9_10_4587.unpack2 = load ptr, ptr %Exception_9_10_4587.elt1, align 8, !noalias !0
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  %0 = insertvalue %Neg poison, ptr %Exception_9_10_4587.unpack, 0
  %Exception_9_10_45873 = insertvalue %Neg %0, ptr %Exception_9_10_4587.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_225 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_226 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_219, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_225, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_226, align 8, !noalias !0
  musttail call tailcc void @toInt_2062(%Pos %v_r_2568_31_63_154_314_4844, %Neg %Exception_9_10_45873, ptr nonnull %stack)
  ret void
}

define void @sharer_228(ptr %stackPointer) {
entry:
  %Exception_9_10_4587_227.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_9_10_4587_227.unpack2 = load ptr, ptr %Exception_9_10_4587_227.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %Exception_9_10_4587_227.unpack2, null
  br i1 %isNull.i.i, label %shareNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %Exception_9_10_4587_227.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %Exception_9_10_4587_227.unpack2, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -32
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_232(ptr %stackPointer) {
entry:
  %Exception_9_10_4587_231.elt1 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_9_10_4587_231.unpack2 = load ptr, ptr %Exception_9_10_4587_231.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %Exception_9_10_4587_231.unpack2, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %Exception_9_10_4587_231.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %Exception_9_10_4587_231.unpack2, align 4
  br label %eraseNegative.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %Exception_9_10_4587_231.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %Exception_9_10_4587_231.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %Exception_9_10_4587_231.unpack2)
  br label %eraseNegative.exit

eraseNegative.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -24
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_191(%Pos %v_r_2567_13_45_126_286_4853, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %Exception_9_10_4587.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %Exception_9_10_4587.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_9_10_4587.unpack2 = load ptr, ptr %Exception_9_10_4587.elt1, align 8, !noalias !0
  %p_8_9_75_235_4627_pointer_194 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %p_8_9_75_235_4627 = load ptr, ptr %p_8_9_75_235_4627_pointer_194, align 8, !noalias !0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 16
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
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
  %newStackPointer.i14 = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i14, i64 40
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i14, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store ptr %Exception_9_10_4587.unpack, ptr %common.ret.op.i, align 8, !noalias !0
  %stackPointer_235.repack4 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %Exception_9_10_4587.unpack2, ptr %stackPointer_235.repack4, align 8, !noalias !0
  %returnAddress_pointer_237 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %sharer_pointer_238 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %eraser_pointer_239 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store ptr @returnAddress_216, ptr %returnAddress_pointer_237, align 8, !noalias !0
  store ptr @sharer_228, ptr %sharer_pointer_238, align 8, !noalias !0
  store ptr @eraser_232, ptr %eraser_pointer_239, align 8, !noalias !0
  musttail call tailcc void @go_6_14_46_127_287_4683(%Pos %v_r_2567_13_45_126_286_4853, i64 1, ptr %p_8_9_75_235_4627, ptr nonnull %stack)
  ret void
}

define void @sharer_242(ptr %stackPointer) {
entry:
  %Exception_9_10_4587_240.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %Exception_9_10_4587_240.unpack2 = load ptr, ptr %Exception_9_10_4587_240.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %Exception_9_10_4587_240.unpack2, null
  br i1 %isNull.i.i, label %shareNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %Exception_9_10_4587_240.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %Exception_9_10_4587_240.unpack2, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %entry, %next.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -40
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_248(ptr %stackPointer) {
entry:
  %Exception_9_10_4587_246.elt1 = getelementptr i8, ptr %stackPointer, i64 -16
  %Exception_9_10_4587_246.unpack2 = load ptr, ptr %Exception_9_10_4587_246.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %Exception_9_10_4587_246.unpack2, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %Exception_9_10_4587_246.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %Exception_9_10_4587_246.unpack2, align 4
  br label %eraseNegative.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %Exception_9_10_4587_246.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %Exception_9_10_4587_246.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %Exception_9_10_4587_246.unpack2)
  br label %eraseNegative.exit

eraseNegative.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -48
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -32
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_1(%Pos %v_coe_3500_3578, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3500_3578, 0
  %nextStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 32
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
  br i1 %isInside.not.i, label %realloc.i, label %stackAllocate.exit

realloc.i:                                        ; preds = %entry
  %base_pointer.i = getelementptr i8, ptr %stack, i64 16
  %base.i = load ptr, ptr %base_pointer.i, align 8, !alias.scope !0
  %intStackPointer.i = ptrtoint ptr %stackPointer.i to i64
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

stackAllocate.exit:                               ; preds = %entry, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %stackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %unboxed.i, ptr %common.ret.op.i, align 4, !noalias !0
  %returnAddress_pointer_121 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %sharer_pointer_122 = getelementptr i8, ptr %common.ret.op.i, i64 16
  %eraser_pointer_123 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store ptr @returnAddress_2, ptr %returnAddress_pointer_121, align 8, !noalias !0
  store ptr @sharer_25, ptr %sharer_pointer_122, align 8, !noalias !0
  store ptr @eraser_29, ptr %eraser_pointer_123, align 8, !noalias !0
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
  %nextStackPointer.i10 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i11 = icmp ugt ptr %nextStackPointer.i10, %limit.i.i
  br i1 %isInside.not.i11, label %realloc.i14, label %stackAllocate.exit28

realloc.i14:                                      ; preds = %stackAllocate.exit
  %newBase.i24 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i25 = getelementptr i8, ptr %newBase.i24, i64 32
  %newNextStackPointer.i27 = getelementptr i8, ptr %newBase.i24, i64 24
  store ptr %newBase.i24, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i25, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit28

stackAllocate.exit28:                             ; preds = %stackAllocate.exit, %realloc.i14
  %limit.i32 = phi ptr [ %newLimit.i25, %realloc.i14 ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i12 = phi ptr [ %newNextStackPointer.i27, %realloc.i14 ], [ %nextStackPointer.i10, %stackAllocate.exit ]
  %base.i39 = phi ptr [ %newBase.i24, %realloc.i14 ], [ %stackPointer.i.i, %stackAllocate.exit ]
  %sharer_pointer_136 = getelementptr i8, ptr %base.i39, i64 8
  %eraser_pointer_137 = getelementptr i8, ptr %base.i39, i64 16
  store ptr @returnAddress_125, ptr %base.i39, align 8, !noalias !0
  store ptr @sharer_130, ptr %sharer_pointer_136, align 8, !noalias !0
  store ptr @eraser_132, ptr %eraser_pointer_137, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_150, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %calloc.i.i, ptr %environment.i, align 8, !noalias !0
  %nextStackPointer.i33 = getelementptr i8, ptr %nextStackPointer.sink.i12, i64 24
  %isInside.not.i34 = icmp ugt ptr %nextStackPointer.i33, %limit.i32
  br i1 %isInside.not.i34, label %realloc.i37, label %stackAllocate.exit51

realloc.i37:                                      ; preds = %stackAllocate.exit28
  %intStackPointer.i40 = ptrtoint ptr %nextStackPointer.sink.i12 to i64
  %intBase.i41 = ptrtoint ptr %base.i39 to i64
  %size.i42 = sub i64 %intStackPointer.i40, %intBase.i41
  %nextSize.i43 = add i64 %size.i42, 24
  %leadingZeros.i.i44 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i43, i1 false)
  %numBits.i.i45 = sub nuw nsw i64 64, %leadingZeros.i.i44
  %result.i.i46 = shl nuw i64 1, %numBits.i.i45
  %newBase.i47 = tail call ptr @realloc(ptr nonnull %base.i39, i64 %result.i.i46)
  %newLimit.i48 = getelementptr i8, ptr %newBase.i47, i64 %result.i.i46
  %newStackPointer.i49 = getelementptr i8, ptr %newBase.i47, i64 %size.i42
  %newNextStackPointer.i50 = getelementptr i8, ptr %newStackPointer.i49, i64 24
  store ptr %newBase.i47, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i48, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit51

stackAllocate.exit51:                             ; preds = %stackAllocate.exit28, %realloc.i37
  %nextStackPointer.sink.i35 = phi ptr [ %newNextStackPointer.i50, %realloc.i37 ], [ %nextStackPointer.i33, %stackAllocate.exit28 ]
  %common.ret.op.i36 = phi ptr [ %newStackPointer.i49, %realloc.i37 ], [ %nextStackPointer.sink.i12, %stackAllocate.exit28 ]
  store ptr %nextStackPointer.sink.i35, ptr %stack.repack1.i, align 8
  %sharer_pointer_160 = getelementptr i8, ptr %common.ret.op.i36, i64 8
  %eraser_pointer_161 = getelementptr i8, ptr %common.ret.op.i36, i64 16
  store ptr @returnAddress_154, ptr %common.ret.op.i36, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_160, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_161, align 8, !noalias !0
  %calloc.i.i52 = tail call noalias noundef dereferenceable_or_null(16) ptr @calloc(i64 1, i64 16)
  %stack.i53 = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %stackPointer.i.i54 = tail call dereferenceable_or_null(64) ptr @malloc(i64 64)
  %limit.i.i55 = getelementptr i8, ptr %stackPointer.i.i54, i64 64
  store i64 0, ptr %stack.i53, align 8
  %stack.repack1.i56 = getelementptr inbounds i8, ptr %stack.i53, i64 8
  %stack.repack1.repack7.i57 = getelementptr inbounds i8, ptr %stack.i53, i64 16
  store ptr %stackPointer.i.i54, ptr %stack.repack1.repack7.i57, align 8
  %stack.repack1.repack9.i58 = getelementptr inbounds i8, ptr %stack.i53, i64 24
  store ptr %limit.i.i55, ptr %stack.repack1.repack9.i58, align 8
  %stack.repack3.i59 = getelementptr inbounds i8, ptr %stack.i53, i64 32
  store ptr %calloc.i.i52, ptr %stack.repack3.i59, align 8
  %stack.repack5.i60 = getelementptr inbounds i8, ptr %stack.i53, i64 40
  store ptr %stack.i, ptr %stack.repack5.i60, align 8
  %stack_pointer.i61 = getelementptr i8, ptr %calloc.i.i52, i64 8
  store ptr %stack.i53, ptr %stack_pointer.i61, align 8
  %nextStackPointer.i68 = getelementptr i8, ptr %stackPointer.i.i54, i64 24
  %isInside.not.i69 = icmp ugt ptr %nextStackPointer.i68, %limit.i.i55
  br i1 %isInside.not.i69, label %realloc.i72, label %stackAllocate.exit86

realloc.i72:                                      ; preds = %stackAllocate.exit51
  %newBase.i82 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i54, i64 32)
  %newLimit.i83 = getelementptr i8, ptr %newBase.i82, i64 32
  %newNextStackPointer.i85 = getelementptr i8, ptr %newBase.i82, i64 24
  store ptr %newBase.i82, ptr %stack.repack1.repack7.i57, align 8, !alias.scope !0
  store ptr %newLimit.i83, ptr %stack.repack1.repack9.i58, align 8, !alias.scope !0
  br label %stackAllocate.exit86

stackAllocate.exit86:                             ; preds = %stackAllocate.exit51, %realloc.i72
  %nextStackPointer.sink.i70 = phi ptr [ %newNextStackPointer.i85, %realloc.i72 ], [ %nextStackPointer.i68, %stackAllocate.exit51 ]
  %common.ret.op.i71 = phi ptr [ %newBase.i82, %realloc.i72 ], [ %stackPointer.i.i54, %stackAllocate.exit51 ]
  store ptr %nextStackPointer.sink.i70, ptr %stack.repack1.i56, align 8
  %sharer_pointer_170 = getelementptr i8, ptr %common.ret.op.i71, i64 8
  %eraser_pointer_171 = getelementptr i8, ptr %common.ret.op.i71, i64 16
  store ptr @returnAddress_163, ptr %common.ret.op.i71, align 8, !noalias !0
  store ptr @sharer_130, ptr %sharer_pointer_170, align 8, !noalias !0
  store ptr @eraser_132, ptr %eraser_pointer_171, align 8, !noalias !0
  %c.i = tail call i64 @c_get_argc()
  %z.i = add i64 %c.i, -1
  %currentStackPointer.i89 = load ptr, ptr %stack.repack1.i56, align 8, !alias.scope !0
  %limit.i90 = load ptr, ptr %stack.repack1.repack9.i58, align 8, !alias.scope !0
  %nextStackPointer.i91 = getelementptr i8, ptr %currentStackPointer.i89, i64 48
  %isInside.not.i92 = icmp ugt ptr %nextStackPointer.i91, %limit.i90
  br i1 %isInside.not.i92, label %realloc.i95, label %stackAllocate.exit109

realloc.i95:                                      ; preds = %stackAllocate.exit86
  %base.i97 = load ptr, ptr %stack.repack1.repack7.i57, align 8, !alias.scope !0
  %intStackPointer.i98 = ptrtoint ptr %currentStackPointer.i89 to i64
  %intBase.i99 = ptrtoint ptr %base.i97 to i64
  %size.i100 = sub i64 %intStackPointer.i98, %intBase.i99
  %nextSize.i101 = add i64 %size.i100, 48
  %leadingZeros.i.i102 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i101, i1 false)
  %numBits.i.i103 = sub nuw nsw i64 64, %leadingZeros.i.i102
  %result.i.i104 = shl nuw i64 1, %numBits.i.i103
  %newBase.i105 = tail call ptr @realloc(ptr %base.i97, i64 %result.i.i104)
  %newLimit.i106 = getelementptr i8, ptr %newBase.i105, i64 %result.i.i104
  %newStackPointer.i107 = getelementptr i8, ptr %newBase.i105, i64 %size.i100
  %newNextStackPointer.i108 = getelementptr i8, ptr %newStackPointer.i107, i64 48
  store ptr %newBase.i105, ptr %stack.repack1.repack7.i57, align 8, !alias.scope !0
  store ptr %newLimit.i106, ptr %stack.repack1.repack9.i58, align 8, !alias.scope !0
  br label %stackAllocate.exit109

stackAllocate.exit109:                            ; preds = %stackAllocate.exit86, %realloc.i95
  %limit.i.i111115 = phi ptr [ %newLimit.i106, %realloc.i95 ], [ %limit.i90, %stackAllocate.exit86 ]
  %nextStackPointer.sink.i93 = phi ptr [ %newNextStackPointer.i108, %realloc.i95 ], [ %nextStackPointer.i91, %stackAllocate.exit86 ]
  %common.ret.op.i94 = phi ptr [ %newStackPointer.i107, %realloc.i95 ], [ %currentStackPointer.i89, %stackAllocate.exit86 ]
  store ptr %nextStackPointer.sink.i93, ptr %stack.repack1.i56, align 8
  store ptr @vtable_146, ptr %common.ret.op.i94, align 8, !noalias !0
  %stackPointer_252.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i94, i64 8
  store ptr %object.i, ptr %stackPointer_252.repack1, align 8, !noalias !0
  %p_8_9_75_235_4627_pointer_254 = getelementptr i8, ptr %common.ret.op.i94, i64 16
  store ptr %calloc.i.i52, ptr %p_8_9_75_235_4627_pointer_254, align 8, !noalias !0
  %returnAddress_pointer_255 = getelementptr i8, ptr %common.ret.op.i94, i64 24
  %sharer_pointer_256 = getelementptr i8, ptr %common.ret.op.i94, i64 32
  %eraser_pointer_257 = getelementptr i8, ptr %common.ret.op.i94, i64 40
  store ptr @returnAddress_191, ptr %returnAddress_pointer_255, align 8, !noalias !0
  store ptr @sharer_242, ptr %sharer_pointer_256, align 8, !noalias !0
  store ptr @eraser_248, ptr %eraser_pointer_257, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_189.i, label %label_185.i

label_185.i:                                      ; preds = %stackAllocate.exit109, %label_185.i
  %acc_3_3_5_37_118_278_4820.tr8.i = phi %Pos [ %make_5383.i, %label_185.i ], [ zeroinitializer, %stackAllocate.exit109 ]
  %start_2_2_4_36_117_277_4869.tr7.i = phi i64 [ %z.i5.i, %label_185.i ], [ %z.i, %stackAllocate.exit109 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_36_117_277_4869.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_36_117_277_4869.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_179, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_5380.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_5380.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_176.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_5380.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_5380.elt2.i, ptr %environment_176.repack1.i, align 8, !noalias !0
  %acc_3_3_5_37_118_278_4820_pointer_183.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_37_118_278_4820.elt.i = extractvalue %Pos %acc_3_3_5_37_118_278_4820.tr8.i, 0
  store i64 %acc_3_3_5_37_118_278_4820.elt.i, ptr %acc_3_3_5_37_118_278_4820_pointer_183.i, align 8, !noalias !0
  %acc_3_3_5_37_118_278_4820_pointer_183.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_37_118_278_4820.elt4.i = extractvalue %Pos %acc_3_3_5_37_118_278_4820.tr8.i, 1
  store ptr %acc_3_3_5_37_118_278_4820.elt4.i, ptr %acc_3_3_5_37_118_278_4820_pointer_183.repack3.i, align 8, !noalias !0
  %make_5383.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_36_117_277_4869.tr7.i, 2
  br i1 %z.i.i, label %label_189.i.loopexit, label %label_185.i

label_189.i.loopexit:                             ; preds = %label_185.i
  %stackPointer.i.i110.pre = load ptr, ptr %stack.repack1.i56, align 8, !alias.scope !0
  %limit.i.i111.pre = load ptr, ptr %stack.repack1.repack9.i58, align 8, !alias.scope !0
  br label %label_189.i

label_189.i:                                      ; preds = %label_189.i.loopexit, %stackAllocate.exit109
  %limit.i.i111 = phi ptr [ %limit.i.i111115, %stackAllocate.exit109 ], [ %limit.i.i111.pre, %label_189.i.loopexit ]
  %stackPointer.i.i110 = phi ptr [ %nextStackPointer.sink.i93, %stackAllocate.exit109 ], [ %stackPointer.i.i110.pre, %label_189.i.loopexit ]
  %acc_3_3_5_37_118_278_4820.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit109 ], [ %make_5383.i, %label_189.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i110, %limit.i.i111
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i110, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i56, align 8, !alias.scope !0
  %returnAddress_186.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_186.i(%Pos %acc_3_3_5_37_118_278_4820.tr.lcssa.i, ptr nonnull %stack.i53)
  ret void
}

define tailcc void @returnAddress_263(%Pos %returned_5396, ptr nocapture %stack) {
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
  %returnAddress_265 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_265(%Pos %returned_5396, ptr %rest.i)
  ret void
}

define tailcc void @Exception_9_10_4196_clause_272(ptr %closure, %Pos %exception_10_11_4202, %Pos %msg_11_12_4204, ptr %stack) {
next.i:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_9_4199 = load ptr, ptr %environment.i, align 8, !noalias !0
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
  %object.i1 = extractvalue %Pos %exception_10_11_4202, 1
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
  %object.i = extractvalue %Pos %msg_11_12_4204, 1
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
  %pair_275 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_9_4199)
  %k_13_14_4205 = extractvalue <{ ptr, ptr }> %pair_275, 0
  %referenceCount.i13 = load i64, ptr %k_13_14_4205, align 4
  %cond.i14 = icmp eq i64 %referenceCount.i13, 0
  br i1 %cond.i14, label %free.i17, label %decr.i15

decr.i15:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i16 = add i64 %referenceCount.i13, -1
  store i64 %referenceCount.1.i16, ptr %k_13_14_4205, align 4
  br label %eraseResumption.exit

free.i17:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_14_4205, i64 40
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
  %stack_276 = extractvalue <{ ptr, ptr }> %pair_275, 1
  %stackPointer_pointer.i24 = getelementptr i8, ptr %stack_276, i64 8
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_276, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i25, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i24, align 8, !alias.scope !0
  %returnAddress_277 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_277(%Pos { i64 5, ptr null }, ptr %stack_276)
  ret void
}

define tailcc void @toList_1_1_3_34_4237(i64 %start_2_2_4_35_4220, %Pos %acc_3_3_5_36_4253, ptr %stack) local_unnamed_addr {
entry:
  %z.i6 = icmp slt i64 %start_2_2_4_35_4220, 1
  br i1 %z.i6, label %label_300, label %label_296

label_296:                                        ; preds = %entry, %label_296
  %acc_3_3_5_36_4253.tr8 = phi %Pos [ %make_5404, %label_296 ], [ %acc_3_3_5_36_4253, %entry ]
  %start_2_2_4_35_4220.tr7 = phi i64 [ %z.i5, %label_296 ], [ %start_2_2_4_35_4220, %entry ]
  %s.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_35_4220.tr7)
  %z.i5 = add nsw i64 %start_2_2_4_35_4220.tr7, -1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_179, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %pureApp_5401.elt = extractvalue %Pos %s.i, 0
  store i64 %pureApp_5401.elt, ptr %environment.i, align 8, !noalias !0
  %environment_290.repack1 = getelementptr i8, ptr %object.i, i64 24
  %pureApp_5401.elt2 = extractvalue %Pos %s.i, 1
  store ptr %pureApp_5401.elt2, ptr %environment_290.repack1, align 8, !noalias !0
  %acc_3_3_5_36_4253_pointer_294 = getelementptr i8, ptr %object.i, i64 32
  %acc_3_3_5_36_4253.elt = extractvalue %Pos %acc_3_3_5_36_4253.tr8, 0
  store i64 %acc_3_3_5_36_4253.elt, ptr %acc_3_3_5_36_4253_pointer_294, align 8, !noalias !0
  %acc_3_3_5_36_4253_pointer_294.repack3 = getelementptr i8, ptr %object.i, i64 40
  %acc_3_3_5_36_4253.elt4 = extractvalue %Pos %acc_3_3_5_36_4253.tr8, 1
  store ptr %acc_3_3_5_36_4253.elt4, ptr %acc_3_3_5_36_4253_pointer_294.repack3, align 8, !noalias !0
  %make_5404 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %z.i = icmp ult i64 %start_2_2_4_35_4220.tr7, 2
  br i1 %z.i, label %label_300, label %label_296

label_300:                                        ; preds = %label_296, %entry
  %acc_3_3_5_36_4253.tr.lcssa = phi %Pos [ %acc_3_3_5_36_4253, %entry ], [ %make_5404, %label_296 ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_297 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_297(%Pos %acc_3_3_5_36_4253.tr.lcssa, ptr %stack)
  ret void
}

define tailcc void @returnAddress_311(i64 %v_coe_3498_62_4213, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3498_62_4213, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_312 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_312(%Pos %boxed2.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_308(%Pos %v_r_2564_30_61_4250, ptr %stack) {
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
  %Exception_9_10_4196.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  %Exception_9_10_4196.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_9_10_4196.unpack2 = load ptr, ptr %Exception_9_10_4196.elt1, align 8, !noalias !0
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
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i12, %realloc.i ], [ %newStackPointer.i, %entry ]
  %0 = insertvalue %Neg poison, ptr %Exception_9_10_4196.unpack, 0
  %Exception_9_10_41963 = insertvalue %Neg %0, ptr %Exception_9_10_4196.unpack2, 1
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_317 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_318 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_311, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_317, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_318, align 8, !noalias !0
  musttail call tailcc void @toInt_2062(%Pos %v_r_2564_30_61_4250, %Neg %Exception_9_10_41963, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_305(%Pos %v_r_2563_24_55_4258, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_9_10_4196.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_9_10_4196.unpack2 = load ptr, ptr %Exception_9_10_4196.elt1, align 8, !noalias !0
  %Exception_9_10_4196.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %Exception_9_10_4196.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  %stackPointer_321.repack4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  store ptr %Exception_9_10_4196.unpack2, ptr %stackPointer_321.repack4, align 8, !noalias !0
  %sharer_pointer_324 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_325 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_308, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_228, ptr %sharer_pointer_324, align 8, !noalias !0
  store ptr @eraser_232, ptr %eraser_pointer_325, align 8, !noalias !0
  %tag_326 = extractvalue %Pos %v_r_2563_24_55_4258, 0
  switch i64 %tag_326, label %label_328 [
    i64 0, label %label_332
    i64 1, label %label_338
  ]

label_328:                                        ; preds = %stackAllocate.exit
  ret void

label_332:                                        ; preds = %stackAllocate.exit
  %utf8StringLiteral_5410 = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5410.lit)
  %stackPointer.i19 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i21 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i22 = icmp ule ptr %stackPointer.i19, %limit.i21
  tail call void @llvm.assume(i1 %isInside.i22)
  %newStackPointer.i23 = getelementptr i8, ptr %stackPointer.i19, i64 -24
  store ptr %newStackPointer.i23, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_329 = load ptr, ptr %newStackPointer.i23, align 8, !noalias !0
  musttail call tailcc void %returnAddress_329(%Pos %utf8StringLiteral_5410, ptr nonnull %stack)
  ret void

label_338:                                        ; preds = %stackAllocate.exit
  %fields_327 = extractvalue %Pos %v_r_2563_24_55_4258, 1
  %environment.i = getelementptr i8, ptr %fields_327, i64 16
  %v_y_3294_8_29_60_4268.unpack = load i64, ptr %environment.i, align 8, !noalias !0
  %v_y_3294_8_29_60_4268.elt6 = getelementptr i8, ptr %fields_327, i64 24
  %v_y_3294_8_29_60_4268.unpack7 = load ptr, ptr %v_y_3294_8_29_60_4268.elt6, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_3294_8_29_60_4268.unpack7, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_338
  %referenceCount.i.i = load i64, ptr %v_y_3294_8_29_60_4268.unpack7, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_3294_8_29_60_4268.unpack7, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_338
  %referenceCount.i = load i64, ptr %fields_327, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_327, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_327, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  tail call void %eraser.i(ptr nonnull %environment.i)
  tail call void @free(ptr nonnull %fields_327)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %0 = insertvalue %Pos poison, i64 %v_y_3294_8_29_60_4268.unpack, 0
  %v_y_3294_8_29_60_42688 = insertvalue %Pos %0, ptr %v_y_3294_8_29_60_4268.unpack7, 1
  %stackPointer.i25 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i27 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i28 = icmp ule ptr %stackPointer.i25, %limit.i27
  tail call void @llvm.assume(i1 %isInside.i28)
  %newStackPointer.i29 = getelementptr i8, ptr %stackPointer.i25, i64 -24
  store ptr %newStackPointer.i29, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_335 = load ptr, ptr %newStackPointer.i29, align 8, !noalias !0
  musttail call tailcc void %returnAddress_335(%Pos %v_y_3294_8_29_60_42688, ptr nonnull %stack)
  ret void
}

define void @eraser_360(ptr nocapture readonly %environment) {
entry:
  %v_y_2803_10_21_52_4243_359.elt1 = getelementptr inbounds i8, ptr %environment, i64 8
  %v_y_2803_10_21_52_4243_359.unpack2 = load ptr, ptr %v_y_2803_10_21_52_4243_359.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2803_10_21_52_4243_359.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %v_y_2803_10_21_52_4243_359.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %v_y_2803_10_21_52_4243_359.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %v_y_2803_10_21_52_4243_359.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %v_y_2803_10_21_52_4243_359.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %v_y_2803_10_21_52_4243_359.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_302(%Pos %v_r_2562_13_44_4249, ptr %stack) {
stackAllocate.exit:
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
  %Exception_9_10_4196.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_9_10_4196.unpack2 = load ptr, ptr %Exception_9_10_4196.elt1, align 8, !noalias !0
  %Exception_9_10_4196.unpack = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %Exception_9_10_4196.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %Exception_9_10_4196.unpack2, ptr %Exception_9_10_4196.elt1, align 8, !noalias !0
  %sharer_pointer_344 = getelementptr i8, ptr %stackPointer.i, i64 8
  %eraser_pointer_345 = getelementptr i8, ptr %stackPointer.i, i64 16
  store ptr @returnAddress_305, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_228, ptr %sharer_pointer_344, align 8, !noalias !0
  store ptr @eraser_232, ptr %eraser_pointer_345, align 8, !noalias !0
  %tag_346 = extractvalue %Pos %v_r_2562_13_44_4249, 0
  switch i64 %tag_346, label %label_348 [
    i64 0, label %label_353
    i64 1, label %label_367
  ]

label_348:                                        ; preds = %stackAllocate.exit
  ret void

label_353:                                        ; preds = %stackAllocate.exit
  store ptr %oldStackPointer.i, ptr %stackPointer_pointer.i, align 8
  store ptr %Exception_9_10_4196.unpack, ptr %newStackPointer.i, align 8, !noalias !0
  store ptr %Exception_9_10_4196.unpack2, ptr %Exception_9_10_4196.elt1, align 8, !noalias !0
  store ptr @returnAddress_308, ptr %stackPointer.i, align 8, !noalias !0
  store ptr @sharer_228, ptr %sharer_pointer_344, align 8, !noalias !0
  store ptr @eraser_232, ptr %eraser_pointer_345, align 8, !noalias !0
  %utf8StringLiteral_5410.i = tail call %Pos @c_bytearray_construct(i64 0, ptr nonnull @utf8StringLiteral_5410.lit)
  %stackPointer.i19.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i21.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i22.i = icmp ule ptr %stackPointer.i19.i, %limit.i21.i
  tail call void @llvm.assume(i1 %isInside.i22.i)
  %newStackPointer.i23.i = getelementptr i8, ptr %stackPointer.i19.i, i64 -24
  store ptr %newStackPointer.i23.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_329.i = load ptr, ptr %newStackPointer.i23.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_329.i(%Pos %utf8StringLiteral_5410.i, ptr nonnull %stack)
  ret void

label_367:                                        ; preds = %stackAllocate.exit
  %fields_347 = extractvalue %Pos %v_r_2562_13_44_4249, 1
  %environment.i11 = getelementptr i8, ptr %fields_347, i64 16
  %v_y_2803_10_21_52_4243.unpack = load i64, ptr %environment.i11, align 8, !noalias !0
  %v_y_2803_10_21_52_4243.elt6 = getelementptr i8, ptr %fields_347, i64 24
  %v_y_2803_10_21_52_4243.unpack7 = load ptr, ptr %v_y_2803_10_21_52_4243.elt6, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_y_2803_10_21_52_4243.unpack7, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %label_367
  %referenceCount.i.i = load i64, ptr %v_y_2803_10_21_52_4243.unpack7, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_y_2803_10_21_52_4243.unpack7, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %label_367
  %referenceCount.i = load i64, ptr %fields_347, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_347, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i13 = getelementptr i8, ptr %fields_347, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i13, align 8
  tail call void %eraser.i(ptr nonnull %environment.i11)
  tail call void @free(ptr nonnull %fields_347)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %decr.i, %free.i
  %object.i = tail call dereferenceable_or_null(32) ptr @malloc(i64 32)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_360, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_y_2803_10_21_52_4243.unpack, ptr %environment.i, align 8, !noalias !0
  %environment_358.repack9 = getelementptr i8, ptr %object.i, i64 24
  store ptr %v_y_2803_10_21_52_4243.unpack7, ptr %environment_358.repack9, align 8, !noalias !0
  %make_5412 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %stackPointer.i30 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i32 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i33 = icmp ule ptr %stackPointer.i30, %limit.i32
  tail call void @llvm.assume(i1 %isInside.i33)
  %newStackPointer.i34 = getelementptr i8, ptr %stackPointer.i30, i64 -24
  store ptr %newStackPointer.i34, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_364 = load ptr, ptr %newStackPointer.i34, align 8, !noalias !0
  musttail call tailcc void %returnAddress_364(%Pos %make_5412, ptr nonnull %stack)
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
  %sharer_pointer_260 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_261 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_1, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_260, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_261, align 8, !noalias !0
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
  %nextStackPointer.i7 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i8 = icmp ugt ptr %nextStackPointer.i7, %limit.i.i
  br i1 %isInside.not.i8, label %realloc.i11, label %stackAllocate.exit25

realloc.i11:                                      ; preds = %stackAllocate.exit
  %newBase.i21 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i22 = getelementptr i8, ptr %newBase.i21, i64 32
  %newNextStackPointer.i24 = getelementptr i8, ptr %newBase.i21, i64 24
  store ptr %newBase.i21, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i22, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit25

stackAllocate.exit25:                             ; preds = %stackAllocate.exit, %realloc.i11
  %nextStackPointer.sink.i9 = phi ptr [ %newNextStackPointer.i24, %realloc.i11 ], [ %nextStackPointer.i7, %stackAllocate.exit ]
  %common.ret.op.i10 = phi ptr [ %newBase.i21, %realloc.i11 ], [ %stackPointer.i.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i9, ptr %stack.repack1.i, align 8
  %sharer_pointer_270 = getelementptr i8, ptr %common.ret.op.i10, i64 8
  %eraser_pointer_271 = getelementptr i8, ptr %common.ret.op.i10, i64 16
  store ptr @returnAddress_263, ptr %common.ret.op.i10, align 8, !noalias !0
  store ptr @sharer_130, ptr %sharer_pointer_270, align 8, !noalias !0
  store ptr @eraser_132, ptr %eraser_pointer_271, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_150, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %calloc.i.i, ptr %environment.i, align 8, !noalias !0
  %c.i = tail call i64 @c_get_argc()
  %z.i = add i64 %c.i, -1
  %currentStackPointer.i28 = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i29 = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  %nextStackPointer.i30 = getelementptr i8, ptr %currentStackPointer.i28, i64 40
  %isInside.not.i31 = icmp ugt ptr %nextStackPointer.i30, %limit.i29
  br i1 %isInside.not.i31, label %realloc.i34, label %stackAllocate.exit48

realloc.i34:                                      ; preds = %stackAllocate.exit25
  %base.i36 = load ptr, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  %intStackPointer.i37 = ptrtoint ptr %currentStackPointer.i28 to i64
  %intBase.i38 = ptrtoint ptr %base.i36 to i64
  %size.i39 = sub i64 %intStackPointer.i37, %intBase.i38
  %nextSize.i40 = add i64 %size.i39, 40
  %leadingZeros.i.i41 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i40, i1 false)
  %numBits.i.i42 = sub nuw nsw i64 64, %leadingZeros.i.i41
  %result.i.i43 = shl nuw i64 1, %numBits.i.i42
  %newBase.i44 = tail call ptr @realloc(ptr %base.i36, i64 %result.i.i43)
  %newLimit.i45 = getelementptr i8, ptr %newBase.i44, i64 %result.i.i43
  %newStackPointer.i46 = getelementptr i8, ptr %newBase.i44, i64 %size.i39
  %newNextStackPointer.i47 = getelementptr i8, ptr %newStackPointer.i46, i64 40
  store ptr %newBase.i44, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i45, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit48

stackAllocate.exit48:                             ; preds = %stackAllocate.exit25, %realloc.i34
  %limit.i.i5053 = phi ptr [ %newLimit.i45, %realloc.i34 ], [ %limit.i29, %stackAllocate.exit25 ]
  %nextStackPointer.sink.i32 = phi ptr [ %newNextStackPointer.i47, %realloc.i34 ], [ %nextStackPointer.i30, %stackAllocate.exit25 ]
  %common.ret.op.i33 = phi ptr [ %newStackPointer.i46, %realloc.i34 ], [ %currentStackPointer.i28, %stackAllocate.exit25 ]
  store ptr %nextStackPointer.sink.i32, ptr %stack.repack1.i, align 8
  store ptr @vtable_280, ptr %common.ret.op.i33, align 8, !noalias !0
  %stackPointer_370.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i33, i64 8
  store ptr %object.i, ptr %stackPointer_370.repack1, align 8, !noalias !0
  %returnAddress_pointer_372 = getelementptr i8, ptr %common.ret.op.i33, i64 16
  %sharer_pointer_373 = getelementptr i8, ptr %common.ret.op.i33, i64 24
  %eraser_pointer_374 = getelementptr i8, ptr %common.ret.op.i33, i64 32
  store ptr @returnAddress_302, ptr %returnAddress_pointer_372, align 8, !noalias !0
  store ptr @sharer_228, ptr %sharer_pointer_373, align 8, !noalias !0
  store ptr @eraser_232, ptr %eraser_pointer_374, align 8, !noalias !0
  %z.i6.i = icmp slt i64 %z.i, 1
  br i1 %z.i6.i, label %label_300.i, label %label_296.i

label_296.i:                                      ; preds = %stackAllocate.exit48, %label_296.i
  %acc_3_3_5_36_4253.tr8.i = phi %Pos [ %make_5404.i, %label_296.i ], [ zeroinitializer, %stackAllocate.exit48 ]
  %start_2_2_4_35_4220.tr7.i = phi i64 [ %z.i5.i, %label_296.i ], [ %z.i, %stackAllocate.exit48 ]
  %s.i.i = tail call %Pos @c_get_arg(i64 %start_2_2_4_35_4220.tr7.i)
  %z.i5.i = add nsw i64 %start_2_2_4_35_4220.tr7.i, -1
  %object.i.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i.i = getelementptr i8, ptr %object.i.i, i64 8
  store i64 0, ptr %object.i.i, align 4
  store ptr @eraser_179, ptr %objectEraser.i.i, align 8
  %environment.i.i = getelementptr i8, ptr %object.i.i, i64 16
  %pureApp_5401.elt.i = extractvalue %Pos %s.i.i, 0
  store i64 %pureApp_5401.elt.i, ptr %environment.i.i, align 8, !noalias !0
  %environment_290.repack1.i = getelementptr i8, ptr %object.i.i, i64 24
  %pureApp_5401.elt2.i = extractvalue %Pos %s.i.i, 1
  store ptr %pureApp_5401.elt2.i, ptr %environment_290.repack1.i, align 8, !noalias !0
  %acc_3_3_5_36_4253_pointer_294.i = getelementptr i8, ptr %object.i.i, i64 32
  %acc_3_3_5_36_4253.elt.i = extractvalue %Pos %acc_3_3_5_36_4253.tr8.i, 0
  store i64 %acc_3_3_5_36_4253.elt.i, ptr %acc_3_3_5_36_4253_pointer_294.i, align 8, !noalias !0
  %acc_3_3_5_36_4253_pointer_294.repack3.i = getelementptr i8, ptr %object.i.i, i64 40
  %acc_3_3_5_36_4253.elt4.i = extractvalue %Pos %acc_3_3_5_36_4253.tr8.i, 1
  store ptr %acc_3_3_5_36_4253.elt4.i, ptr %acc_3_3_5_36_4253_pointer_294.repack3.i, align 8, !noalias !0
  %make_5404.i = insertvalue %Pos { i64 1, ptr null }, ptr %object.i.i, 1
  %z.i.i = icmp ult i64 %start_2_2_4_35_4220.tr7.i, 2
  br i1 %z.i.i, label %label_300.i.loopexit, label %label_296.i

label_300.i.loopexit:                             ; preds = %label_296.i
  %stackPointer.i.i49.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i50.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %label_300.i

label_300.i:                                      ; preds = %label_300.i.loopexit, %stackAllocate.exit48
  %limit.i.i50 = phi ptr [ %limit.i.i5053, %stackAllocate.exit48 ], [ %limit.i.i50.pre, %label_300.i.loopexit ]
  %stackPointer.i.i49 = phi ptr [ %nextStackPointer.sink.i32, %stackAllocate.exit48 ], [ %stackPointer.i.i49.pre, %label_300.i.loopexit ]
  %acc_3_3_5_36_4253.tr.lcssa.i = phi %Pos [ zeroinitializer, %stackAllocate.exit48 ], [ %make_5404.i, %label_300.i.loopexit ]
  %isInside.i.i = icmp ule ptr %stackPointer.i.i49, %limit.i.i50
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i.i49, i64 -24
  store ptr %newStackPointer.i.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_297.i = load ptr, ptr %newStackPointer.i.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_297.i(%Pos %acc_3_3_5_36_4253.tr.lcssa.i, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_375(%Pos %v_r_2734_3545, ptr %stack) {
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
  %index_2107_pointer_378 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %index_2107 = load i64, ptr %index_2107_pointer_378, align 4, !noalias !0
  %Exception_2362.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2362.unpack5 = load ptr, ptr %Exception_2362.elt4, align 8, !noalias !0
  %tag_380 = extractvalue %Pos %v_r_2734_3545, 0
  switch i64 %tag_380, label %label_382 [
    i64 0, label %label_386
    i64 1, label %label_392
  ]

label_382:                                        ; preds = %entry
  ret void

label_386:                                        ; preds = %entry
  %isNull.i.i = icmp eq ptr %Exception_2362.unpack5, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %label_386
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

eraseNegative.exit:                               ; preds = %label_386, %decr.i.i, %free.i.i
  %x.i = tail call i64 @c_bytearray_character_at(%Pos %str_21063, i64 %index_2107)
  %stackPointer.i13 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i15 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i16 = icmp ule ptr %stackPointer.i13, %limit.i15
  tail call void @llvm.assume(i1 %isInside.i16)
  %newStackPointer.i17 = getelementptr i8, ptr %stackPointer.i13, i64 -24
  store ptr %newStackPointer.i17, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_383 = load ptr, ptr %newStackPointer.i17, align 8, !noalias !0
  musttail call tailcc void %returnAddress_383(i64 %x.i, ptr nonnull %stack)
  ret void

label_392:                                        ; preds = %entry
  %Exception_2362_pointer_379 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2362.unpack = load ptr, ptr %Exception_2362_pointer_379, align 8, !noalias !0
  %z.i = tail call %Pos @c_bytearray_show_Int(i64 %index_2107)
  %utf8StringLiteral_5342 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5342.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5342, %Pos %z.i)
  %utf8StringLiteral_5344 = tail call %Pos @c_bytearray_construct(i64 13, ptr nonnull @utf8StringLiteral_5344.lit)
  %spz.i18 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5344)
  %spz.i19 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i18, %Pos %str_21063)
  %utf8StringLiteral_5347 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5347.lit)
  %spz.i20 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i19, %Pos %utf8StringLiteral_5347)
  %functionPointer_391 = load ptr, ptr %Exception_2362.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_391(ptr %Exception_2362.unpack5, %Pos zeroinitializer, %Pos %spz.i20, ptr nonnull %stack)
  ret void
}

define void @sharer_396(ptr %stackPointer) {
entry:
  %str_2106_393.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_393.unpack2 = load ptr, ptr %str_2106_393.elt1, align 8, !noalias !0
  %Exception_2362_395.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_395.unpack5 = load ptr, ptr %Exception_2362_395.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_393.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_393.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2106_393.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_395.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_395.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2362_395.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_404(ptr %stackPointer) {
entry:
  %str_2106_401.elt1 = getelementptr i8, ptr %stackPointer, i64 -32
  %str_2106_401.unpack2 = load ptr, ptr %str_2106_401.elt1, align 8, !noalias !0
  %Exception_2362_403.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2362_403.unpack5 = load ptr, ptr %Exception_2362_403.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2106_401.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2106_401.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2106_401.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2106_401.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2106_401.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2106_401.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2362_403.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2362_403.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2362_403.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2362_403.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2362_403.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2362_403.unpack5)
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
  %stackPointer_409.repack1 = getelementptr inbounds i8, ptr %common.ret.op.i, i64 8
  store ptr %object.i, ptr %stackPointer_409.repack1, align 8, !noalias !0
  %index_2107_pointer_411 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store i64 %index_2107, ptr %index_2107_pointer_411, align 4, !noalias !0
  %Exception_2362_pointer_412 = getelementptr i8, ptr %common.ret.op.i, i64 24
  %Exception_2362.elt = extractvalue %Neg %Exception_2362, 0
  store ptr %Exception_2362.elt, ptr %Exception_2362_pointer_412, align 8, !noalias !0
  %Exception_2362_pointer_412.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 32
  %Exception_2362.elt4 = extractvalue %Neg %Exception_2362, 1
  store ptr %Exception_2362.elt4, ptr %Exception_2362_pointer_412.repack3, align 8, !noalias !0
  %returnAddress_pointer_413 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %sharer_pointer_414 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %eraser_pointer_415 = getelementptr i8, ptr %common.ret.op.i, i64 56
  store ptr @returnAddress_375, ptr %returnAddress_pointer_413, align 8, !noalias !0
  store ptr @sharer_396, ptr %sharer_pointer_414, align 8, !noalias !0
  store ptr @eraser_404, ptr %eraser_pointer_415, align 8, !noalias !0
  %switch.not.not = icmp sgt i64 %index_2107, -1
  br i1 %switch.not.not, label %label_422, label %label_427

label_422:                                        ; preds = %stackAllocate.exit
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
  %returnAddress_419 = load ptr, ptr %newStackPointer.i16, align 8, !noalias !0
  musttail call tailcc void %returnAddress_419(%Pos %adt_boolean.i12, ptr nonnull %stack)
  ret void

label_427:                                        ; preds = %stackAllocate.exit
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i7

next.i.i7:                                        ; preds = %label_427
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

erasePositive.exit:                               ; preds = %label_427, %decr.i.i, %free.i.i
  %stackPointer.i18 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i20 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i21 = icmp ule ptr %stackPointer.i18, %limit.i20
  tail call void @llvm.assume(i1 %isInside.i21)
  %newStackPointer.i22 = getelementptr i8, ptr %stackPointer.i18, i64 -24
  store ptr %newStackPointer.i22, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_424 = load ptr, ptr %newStackPointer.i22, align 8, !noalias !0
  musttail call tailcc void %returnAddress_424(%Pos { i64 1, ptr null }, ptr nonnull %stack)
  ret void
}

define tailcc void @returnAddress_428(%Pos %v_r_2652_3561, ptr %stack) {
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
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -56
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %tmp_5288 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %str_2061_pointer_431 = getelementptr i8, ptr %stackPointer.i, i64 -48
  %str_2061.unpack = load i64, ptr %str_2061_pointer_431, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %str_2061.unpack, 0
  %str_2061.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -40
  %str_2061.unpack2 = load ptr, ptr %str_2061.elt1, align 8, !noalias !0
  %str_20613 = insertvalue %Pos %0, ptr %str_2061.unpack2, 1
  %index_2146_pointer_432 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %index_2146 = load i64, ptr %index_2146_pointer_432, align 4, !noalias !0
  %acc_2147_pointer_433 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %acc_2147 = load i64, ptr %acc_2147_pointer_433, align 4, !noalias !0
  %Exception_2356_pointer_434 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2356.unpack = load ptr, ptr %Exception_2356_pointer_434, align 8, !noalias !0
  %Exception_2356.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2356.unpack5 = load ptr, ptr %Exception_2356.elt4, align 8, !noalias !0
  %tag_435 = extractvalue %Pos %v_r_2652_3561, 0
  %fields_436 = extractvalue %Pos %v_r_2652_3561, 1
  switch i64 %tag_435, label %common.ret [
    i64 1, label %label_460
    i64 0, label %label_467
  ]

common.ret:                                       ; preds = %entry
  ret void

label_448:                                        ; preds = %eraseObject.exit22
  %utf8StringLiteral_5298 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5298.lit)
  %spz.i = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5298, %Pos %str_20613)
  %utf8StringLiteral_5300 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5300.lit)
  %spz.i42 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i, %Pos %utf8StringLiteral_5300)
  %functionPointer_447 = load ptr, ptr %Exception_2356.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_447(ptr %Exception_2356.unpack5, %Pos zeroinitializer, %Pos %spz.i42, ptr nonnull %stack)
  ret void

label_457:                                        ; preds = %label_459
  %utf8StringLiteral_5305 = tail call %Pos @c_bytearray_construct(i64 21, ptr nonnull @utf8StringLiteral_5305.lit)
  %spz.i43 = tail call %Pos @c_bytearray_concatenate(%Pos %utf8StringLiteral_5305, %Pos %str_20613)
  %utf8StringLiteral_5307 = tail call %Pos @c_bytearray_construct(i64 1, ptr nonnull @utf8StringLiteral_5307.lit)
  %spz.i44 = tail call %Pos @c_bytearray_concatenate(%Pos %spz.i43, %Pos %utf8StringLiteral_5307)
  %functionPointer_456 = load ptr, ptr %Exception_2356.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_456(ptr %Exception_2356.unpack5, %Pos zeroinitializer, %Pos %spz.i44, ptr nonnull %stack)
  ret void

label_458:                                        ; preds = %label_459
  %1 = insertvalue %Neg poison, ptr %Exception_2356.unpack, 0
  %Exception_23566 = insertvalue %Neg %1, ptr %Exception_2356.unpack5, 1
  %z.i = add i64 %index_2146, 1
  %z.i45 = mul i64 %acc_2147, 10
  %z.i46 = sub i64 %z.i45, %tmp_5288
  %z.i47 = add i64 %z.i46, %v_coe_3468_3566.unpack
  musttail call tailcc void @go_2148(i64 %z.i, i64 %z.i47, i64 %tmp_5288, %Pos %str_20613, %Neg %Exception_23566, ptr nonnull %stack)
  ret void

label_459:                                        ; preds = %eraseObject.exit22
  %z.i48 = icmp ult i64 %v_coe_3468_3566.unpack, 58
  br i1 %z.i48, label %label_458, label %label_457

label_460:                                        ; preds = %entry
  %environment.i11 = getelementptr i8, ptr %fields_436, i64 16
  %v_coe_3468_3566.unpack = load i64, ptr %environment.i11, align 8, !noalias !0
  %v_coe_3468_3566.elt7 = getelementptr i8, ptr %fields_436, i64 24
  %v_coe_3468_3566.unpack8 = load ptr, ptr %v_coe_3468_3566.elt7, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %v_coe_3468_3566.unpack8, null
  br i1 %isNull.i.i, label %next.i13, label %next.i.i

next.i.i:                                         ; preds = %label_460
  %referenceCount.i.i = load i64, ptr %v_coe_3468_3566.unpack8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %v_coe_3468_3566.unpack8, align 4
  br label %next.i13

next.i13:                                         ; preds = %next.i.i, %label_460
  %referenceCount.i14 = load i64, ptr %fields_436, align 4
  %cond.i15 = icmp eq i64 %referenceCount.i14, 0
  br i1 %cond.i15, label %free.i18, label %decr.i16

decr.i16:                                         ; preds = %next.i13
  %referenceCount.1.i17 = add i64 %referenceCount.i14, -1
  store i64 %referenceCount.1.i17, ptr %fields_436, align 4
  br label %eraseObject.exit22

free.i18:                                         ; preds = %next.i13
  %objectEraser.i19 = getelementptr i8, ptr %fields_436, i64 8
  %eraser.i20 = load ptr, ptr %objectEraser.i19, align 8
  tail call void %eraser.i20(ptr nonnull %environment.i11)
  tail call void @free(ptr nonnull %fields_436)
  br label %eraseObject.exit22

eraseObject.exit22:                               ; preds = %decr.i16, %free.i18
  %z.i49 = icmp sgt i64 %v_coe_3468_3566.unpack, 47
  br i1 %z.i49, label %label_459, label %label_448

label_467:                                        ; preds = %entry
  %isNull.i = icmp eq ptr %fields_436, null
  br i1 %isNull.i, label %eraseObject.exit, label %next.i

next.i:                                           ; preds = %label_467
  %referenceCount.i = load i64, ptr %fields_436, align 4
  %cond.i = icmp eq i64 %referenceCount.i, 0
  br i1 %cond.i, label %free.i, label %decr.i

decr.i:                                           ; preds = %next.i
  %referenceCount.1.i = add i64 %referenceCount.i, -1
  store i64 %referenceCount.1.i, ptr %fields_436, align 4
  br label %eraseObject.exit

free.i:                                           ; preds = %next.i
  %objectEraser.i = getelementptr i8, ptr %fields_436, i64 8
  %eraser.i = load ptr, ptr %objectEraser.i, align 8
  %environment.i.i = getelementptr i8, ptr %fields_436, i64 16
  tail call void %eraser.i(ptr %environment.i.i)
  tail call void @free(ptr nonnull %fields_436)
  br label %eraseObject.exit

eraseObject.exit:                                 ; preds = %label_467, %decr.i, %free.i
  %isNull.i.i23 = icmp eq ptr %str_2061.unpack2, null
  br i1 %isNull.i.i23, label %erasePositive.exit, label %next.i.i24

next.i.i24:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i25 = load i64, ptr %str_2061.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i25, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i24
  %referenceCount.1.i.i26 = add i64 %referenceCount.i.i25, -1
  store i64 %referenceCount.1.i.i26, ptr %str_2061.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i24
  %objectEraser.i.i = getelementptr i8, ptr %str_2061.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2061.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2061.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %eraseObject.exit, %decr.i.i, %free.i.i
  %isNull.i.i27 = icmp eq ptr %Exception_2356.unpack5, null
  br i1 %isNull.i.i27, label %eraseNegative.exit, label %next.i.i28

next.i.i28:                                       ; preds = %erasePositive.exit
  %referenceCount.i.i29 = load i64, ptr %Exception_2356.unpack5, align 4
  %cond.i.i30 = icmp eq i64 %referenceCount.i.i29, 0
  br i1 %cond.i.i30, label %free.i.i33, label %decr.i.i31

decr.i.i31:                                       ; preds = %next.i.i28
  %referenceCount.1.i.i32 = add i64 %referenceCount.i.i29, -1
  store i64 %referenceCount.1.i.i32, ptr %Exception_2356.unpack5, align 4
  br label %eraseNegative.exit

free.i.i33:                                       ; preds = %next.i.i28
  %objectEraser.i.i34 = getelementptr i8, ptr %Exception_2356.unpack5, i64 8
  %eraser.i.i35 = load ptr, ptr %objectEraser.i.i34, align 8
  %environment.i.i.i36 = getelementptr i8, ptr %Exception_2356.unpack5, i64 16
  tail call void %eraser.i.i35(ptr %environment.i.i.i36)
  tail call void @free(ptr nonnull %Exception_2356.unpack5)
  br label %eraseNegative.exit

eraseNegative.exit:                               ; preds = %erasePositive.exit, %decr.i.i31, %free.i.i33
  %stackPointer.i53 = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i55 = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i56 = icmp ule ptr %stackPointer.i53, %limit.i55
  tail call void @llvm.assume(i1 %isInside.i56)
  %newStackPointer.i57 = getelementptr i8, ptr %stackPointer.i53, i64 -24
  store ptr %newStackPointer.i57, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_464 = load ptr, ptr %newStackPointer.i57, align 8, !noalias !0
  musttail call tailcc void %returnAddress_464(i64 %acc_2147, ptr nonnull %stack)
  ret void
}

define void @sharer_473(ptr %stackPointer) {
entry:
  %str_2061_469.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %str_2061_469.unpack2 = load ptr, ptr %str_2061_469.elt1, align 8, !noalias !0
  %Exception_2356_472.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2356_472.unpack5 = load ptr, ptr %Exception_2356_472.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2061_469.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2061_469.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2061_469.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2356_472.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2356_472.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2356_472.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -72
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_485(ptr %stackPointer) {
entry:
  %str_2061_481.elt1 = getelementptr i8, ptr %stackPointer, i64 -40
  %str_2061_481.unpack2 = load ptr, ptr %str_2061_481.elt1, align 8, !noalias !0
  %Exception_2356_484.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2356_484.unpack5 = load ptr, ptr %Exception_2356_484.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2061_481.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2061_481.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2061_481.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2061_481.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2061_481.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2061_481.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2356_484.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2356_484.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2356_484.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2356_484.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2356_484.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2356_484.unpack5)
  br label %eraseNegative.exit

eraseNegative.exit:                               ; preds = %erasePositive.exit, %decr.i.i11, %free.i.i13
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -80
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -64
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @returnAddress_502(%Pos %returned_5316, ptr nocapture %stack) {
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
  %returnAddress_504 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_504(%Pos %returned_5316, ptr %rest.i)
  ret void
}

define tailcc void @Exception_7_3739_clause_511(ptr %closure, %Pos %exc_8_3737, %Pos %msg_9_3743, ptr %stack) {
next.i:
  %environment.i5 = getelementptr i8, ptr %closure, i64 16
  %p_6_3740 = load ptr, ptr %environment.i5, align 8, !noalias !0
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
  %pair_514 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_6_3740)
  %k_11_3748 = extractvalue <{ ptr, ptr }> %pair_514, 0
  %referenceCount.i7 = load i64, ptr %k_11_3748, align 4
  %cond.i8 = icmp eq i64 %referenceCount.i7, 0
  br i1 %cond.i8, label %free.i11, label %decr.i9

decr.i9:                                          ; preds = %eraseObject.exit
  %referenceCount.1.i10 = add i64 %referenceCount.i7, -1
  store i64 %referenceCount.1.i10, ptr %k_11_3748, align 4
  br label %eraseResumption.exit

free.i11:                                         ; preds = %eraseObject.exit
  %stack_pointer.i = getelementptr i8, ptr %k_11_3748, i64 40
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
  %stack_515 = extractvalue <{ ptr, ptr }> %pair_514, 1
  %object.i = tail call dereferenceable_or_null(48) ptr @malloc(i64 48)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_179, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %exc_8_3737.elt = extractvalue %Pos %exc_8_3737, 0
  store i64 %exc_8_3737.elt, ptr %environment.i, align 8, !noalias !0
  %environment_517.repack1 = getelementptr i8, ptr %object.i, i64 24
  %exc_8_3737.elt2 = extractvalue %Pos %exc_8_3737, 1
  store ptr %exc_8_3737.elt2, ptr %environment_517.repack1, align 8, !noalias !0
  %msg_9_3743_pointer_521 = getelementptr i8, ptr %object.i, i64 32
  %msg_9_3743.elt = extractvalue %Pos %msg_9_3743, 0
  store i64 %msg_9_3743.elt, ptr %msg_9_3743_pointer_521, align 8, !noalias !0
  %msg_9_3743_pointer_521.repack3 = getelementptr i8, ptr %object.i, i64 40
  %msg_9_3743.elt4 = extractvalue %Pos %msg_9_3743, 1
  store ptr %msg_9_3743.elt4, ptr %msg_9_3743_pointer_521.repack3, align 8, !noalias !0
  %make_5317 = insertvalue %Pos zeroinitializer, ptr %object.i, 1
  %stackPointer_pointer.i14 = getelementptr i8, ptr %stack_515, i64 8
  %stackPointer.i15 = load ptr, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %limit_pointer.i = getelementptr i8, ptr %stack_515, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %stackPointer.i15, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i15, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i14, align 8, !alias.scope !0
  %returnAddress_523 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_523(%Pos %make_5317, ptr %stack_515)
  ret void
}

define tailcc void @returnAddress_532(i64 %v_coe_3467_6_3750, ptr %stack) {
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
  store ptr @eraser_360, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store i64 %v_coe_3467_6_3750, ptr %environment.i, align 8, !noalias !0
  %environment_534.repack1 = getelementptr i8, ptr %object.i, i64 24
  store ptr null, ptr %environment_534.repack1, align 8, !noalias !0
  %make_5319 = insertvalue %Pos { i64 1, ptr null }, ptr %object.i, 1
  %isInside.i7 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i7)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_538 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_538(%Pos %make_5319, ptr %stack)
  ret void
}

define tailcc void @go_2148(i64 %index_2146, i64 %acc_2147, i64 %tmp_5288, %Pos %str_2061, %Neg %Exception_2356, ptr %stack) local_unnamed_addr {
entry:
  %object.i5 = extractvalue %Pos %str_2061, 1
  %isNull.i.i = icmp eq ptr %object.i5, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %object.i5, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i5, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %currentStackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %nextStackPointer.i = getelementptr i8, ptr %currentStackPointer.i, i64 80
  %isInside.not.i = icmp ugt ptr %nextStackPointer.i, %limit.i
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
  %newStackPointer.i = getelementptr i8, ptr %newBase.i, i64 %size.i
  %newNextStackPointer.i = getelementptr i8, ptr %newStackPointer.i, i64 80
  store ptr %newBase.i, ptr %base_pointer.i, align 8, !alias.scope !0
  store ptr %newLimit.i, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit

stackAllocate.exit:                               ; preds = %sharePositive.exit, %realloc.i
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %nextStackPointer.i, %sharePositive.exit ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i, %realloc.i ], [ %currentStackPointer.i, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  store i64 %tmp_5288, ptr %common.ret.op.i, align 4, !noalias !0
  %str_2061_pointer_494 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %str_2061.elt = extractvalue %Pos %str_2061, 0
  store i64 %str_2061.elt, ptr %str_2061_pointer_494, align 8, !noalias !0
  %str_2061_pointer_494.repack1 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr %object.i5, ptr %str_2061_pointer_494.repack1, align 8, !noalias !0
  %index_2146_pointer_495 = getelementptr i8, ptr %common.ret.op.i, i64 24
  store i64 %index_2146, ptr %index_2146_pointer_495, align 4, !noalias !0
  %acc_2147_pointer_496 = getelementptr i8, ptr %common.ret.op.i, i64 32
  store i64 %acc_2147, ptr %acc_2147_pointer_496, align 4, !noalias !0
  %Exception_2356_pointer_497 = getelementptr i8, ptr %common.ret.op.i, i64 40
  %Exception_2356.elt = extractvalue %Neg %Exception_2356, 0
  store ptr %Exception_2356.elt, ptr %Exception_2356_pointer_497, align 8, !noalias !0
  %Exception_2356_pointer_497.repack3 = getelementptr i8, ptr %common.ret.op.i, i64 48
  %Exception_2356.elt4 = extractvalue %Neg %Exception_2356, 1
  store ptr %Exception_2356.elt4, ptr %Exception_2356_pointer_497.repack3, align 8, !noalias !0
  %returnAddress_pointer_498 = getelementptr i8, ptr %common.ret.op.i, i64 56
  %sharer_pointer_499 = getelementptr i8, ptr %common.ret.op.i, i64 64
  %eraser_pointer_500 = getelementptr i8, ptr %common.ret.op.i, i64 72
  store ptr @returnAddress_428, ptr %returnAddress_pointer_498, align 8, !noalias !0
  store ptr @sharer_473, ptr %sharer_pointer_499, align 8, !noalias !0
  store ptr @eraser_485, ptr %eraser_pointer_500, align 8, !noalias !0
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
  %nextStackPointer.i10 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i11 = icmp ugt ptr %nextStackPointer.i10, %limit.i.i
  br i1 %isInside.not.i11, label %realloc.i14, label %stackAllocate.exit28

realloc.i14:                                      ; preds = %stackAllocate.exit
  %newBase.i24 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i25 = getelementptr i8, ptr %newBase.i24, i64 32
  %newNextStackPointer.i27 = getelementptr i8, ptr %newBase.i24, i64 24
  store ptr %newBase.i24, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i25, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit28

stackAllocate.exit28:                             ; preds = %stackAllocate.exit, %realloc.i14
  %limit.i32 = phi ptr [ %newLimit.i25, %realloc.i14 ], [ %limit.i.i, %stackAllocate.exit ]
  %nextStackPointer.sink.i12 = phi ptr [ %newNextStackPointer.i27, %realloc.i14 ], [ %nextStackPointer.i10, %stackAllocate.exit ]
  %base.i39 = phi ptr [ %newBase.i24, %realloc.i14 ], [ %stackPointer.i.i, %stackAllocate.exit ]
  %sharer_pointer_509 = getelementptr i8, ptr %base.i39, i64 8
  %eraser_pointer_510 = getelementptr i8, ptr %base.i39, i64 16
  store ptr @returnAddress_502, ptr %base.i39, align 8, !noalias !0
  store ptr @sharer_130, ptr %sharer_pointer_509, align 8, !noalias !0
  store ptr @eraser_132, ptr %eraser_pointer_510, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(24) ptr @malloc(i64 24)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_150, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  store ptr %calloc.i.i, ptr %environment.i, align 8, !noalias !0
  %nextStackPointer.i33 = getelementptr i8, ptr %nextStackPointer.sink.i12, i64 24
  %isInside.not.i34 = icmp ugt ptr %nextStackPointer.i33, %limit.i32
  br i1 %isInside.not.i34, label %realloc.i37, label %stackAllocate.exit51

realloc.i37:                                      ; preds = %stackAllocate.exit28
  %intStackPointer.i40 = ptrtoint ptr %nextStackPointer.sink.i12 to i64
  %intBase.i41 = ptrtoint ptr %base.i39 to i64
  %size.i42 = sub i64 %intStackPointer.i40, %intBase.i41
  %nextSize.i43 = add i64 %size.i42, 24
  %leadingZeros.i.i44 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i43, i1 false)
  %numBits.i.i45 = sub nuw nsw i64 64, %leadingZeros.i.i44
  %result.i.i46 = shl nuw i64 1, %numBits.i.i45
  %newBase.i47 = tail call ptr @realloc(ptr nonnull %base.i39, i64 %result.i.i46)
  %newLimit.i48 = getelementptr i8, ptr %newBase.i47, i64 %result.i.i46
  %newStackPointer.i49 = getelementptr i8, ptr %newBase.i47, i64 %size.i42
  %newNextStackPointer.i50 = getelementptr i8, ptr %newStackPointer.i49, i64 24
  store ptr %newBase.i47, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i48, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit51

stackAllocate.exit51:                             ; preds = %stackAllocate.exit28, %realloc.i37
  %nextStackPointer.sink.i35 = phi ptr [ %newNextStackPointer.i50, %realloc.i37 ], [ %nextStackPointer.i33, %stackAllocate.exit28 ]
  %common.ret.op.i36 = phi ptr [ %newStackPointer.i49, %realloc.i37 ], [ %nextStackPointer.sink.i12, %stackAllocate.exit28 ]
  %Exception_7_3739 = insertvalue %Neg { ptr @vtable_526, ptr null }, ptr %object.i, 1
  store ptr %nextStackPointer.sink.i35, ptr %stack.repack1.i, align 8
  %sharer_pointer_543 = getelementptr i8, ptr %common.ret.op.i36, i64 8
  %eraser_pointer_544 = getelementptr i8, ptr %common.ret.op.i36, i64 16
  store ptr @returnAddress_532, ptr %common.ret.op.i36, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_543, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_544, align 8, !noalias !0
  musttail call tailcc void @charAt_2108(%Pos %str_2061, i64 %index_2146, %Neg %Exception_7_3739, ptr nonnull %stack.i)
  ret void
}

define tailcc void @returnAddress_545(%Pos %v_coe_3474_3572, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %unboxed.i = extractvalue %Pos %v_coe_3474_3572, 0
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_546 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_546(i64 %unboxed.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_554(%Pos %returned_5321, ptr nocapture %stack) {
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
  %returnAddress_556 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_556(%Pos %returned_5321, ptr %rest.i)
  ret void
}

define tailcc void @Exception_9_3810_clause_563(ptr %closure, %Pos %exception_10_5322, %Pos %msg_11_5323, ptr %stack) {
entry:
  %environment.i = getelementptr i8, ptr %closure, i64 16
  %p_8_3812 = load ptr, ptr %environment.i, align 8, !noalias !0
  %Exception_2356_pointer_566 = getelementptr i8, ptr %closure, i64 24
  %Exception_2356.unpack = load ptr, ptr %Exception_2356_pointer_566, align 8, !noalias !0
  %Exception_2356.elt1 = getelementptr i8, ptr %closure, i64 32
  %Exception_2356.unpack2 = load ptr, ptr %Exception_2356.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %Exception_2356.unpack2, null
  br i1 %isNull.i.i, label %next.i, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %Exception_2356.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %Exception_2356.unpack2, align 4
  br label %next.i

next.i:                                           ; preds = %next.i.i, %entry
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
  %object.i8 = extractvalue %Pos %exception_10_5322, 1
  %isNull.i.i9 = icmp eq ptr %object.i8, null
  br i1 %isNull.i.i9, label %erasePositive.exit19, label %next.i.i10

next.i.i10:                                       ; preds = %eraseObject.exit
  %referenceCount.i.i11 = load i64, ptr %object.i8, align 4
  %cond.i.i12 = icmp eq i64 %referenceCount.i.i11, 0
  br i1 %cond.i.i12, label %free.i.i15, label %decr.i.i13

decr.i.i13:                                       ; preds = %next.i.i10
  %referenceCount.1.i.i14 = add i64 %referenceCount.i.i11, -1
  store i64 %referenceCount.1.i.i14, ptr %object.i8, align 4
  br label %erasePositive.exit19

free.i.i15:                                       ; preds = %next.i.i10
  %objectEraser.i.i16 = getelementptr i8, ptr %object.i8, i64 8
  %eraser.i.i17 = load ptr, ptr %objectEraser.i.i16, align 8
  %environment.i.i.i18 = getelementptr i8, ptr %object.i8, i64 16
  tail call void %eraser.i.i17(ptr %environment.i.i.i18)
  tail call void @free(ptr nonnull %object.i8)
  br label %erasePositive.exit19

erasePositive.exit19:                             ; preds = %eraseObject.exit, %decr.i.i13, %free.i.i15
  %object.i = extractvalue %Pos %msg_11_5323, 1
  %isNull.i.i4 = icmp eq ptr %object.i, null
  br i1 %isNull.i.i4, label %erasePositive.exit, label %next.i.i5

next.i.i5:                                        ; preds = %erasePositive.exit19
  %referenceCount.i.i6 = load i64, ptr %object.i, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i6, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i5
  %referenceCount.1.i.i7 = add i64 %referenceCount.i.i6, -1
  store i64 %referenceCount.1.i.i7, ptr %object.i, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i5
  %objectEraser.i.i = getelementptr i8, ptr %object.i, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %object.i, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %object.i)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %erasePositive.exit19, %decr.i.i, %free.i.i
  %pair_567 = tail call <{ ptr, ptr }> @shift(ptr %stack, ptr %p_8_3812)
  %k_13_3815 = extractvalue <{ ptr, ptr }> %pair_567, 0
  %referenceCount.i20 = load i64, ptr %k_13_3815, align 4
  %cond.i21 = icmp eq i64 %referenceCount.i20, 0
  br i1 %cond.i21, label %free.i24, label %decr.i22

decr.i22:                                         ; preds = %erasePositive.exit
  %referenceCount.1.i23 = add i64 %referenceCount.i20, -1
  store i64 %referenceCount.1.i23, ptr %k_13_3815, align 4
  br label %eraseResumption.exit

free.i24:                                         ; preds = %erasePositive.exit
  %stack_pointer.i = getelementptr i8, ptr %k_13_3815, i64 40
  %stack.i = load ptr, ptr %stack_pointer.i, align 8
  store ptr null, ptr %stack_pointer.i, align 8
  br label %tailrecurse.i

tailrecurse.i:                                    ; preds = %erasePrompt.exit.i, %free.i24
  %stack.tr.i = phi ptr [ %stack.i, %free.i24 ], [ %rest.i, %erasePrompt.exit.i ]
  %stackPointer_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 8
  %prompt_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 32
  %rest_pointer.i = getelementptr i8, ptr %stack.tr.i, i64 40
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8
  %prompt.i = load ptr, ptr %prompt_pointer.i, align 8
  %rest.i = load ptr, ptr %rest_pointer.i, align 8
  %promptStack_pointer.i = getelementptr i8, ptr %prompt.i, i64 8
  %promptStack.i = load ptr, ptr %promptStack_pointer.i, align 8
  %isThisStack.i = icmp eq ptr %promptStack.i, %stack.tr.i
  br i1 %isThisStack.i, label %clearPrompt.i, label %free.i25

clearPrompt.i:                                    ; preds = %tailrecurse.i
  store ptr null, ptr %promptStack_pointer.i, align 8
  br label %free.i25

free.i25:                                         ; preds = %clearPrompt.i, %tailrecurse.i
  tail call void @free(ptr nonnull %stack.tr.i)
  %newStackPointer.i.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  %stackEraser.i.i = getelementptr i8, ptr %stackPointer.i, i64 -8
  %eraser.i.i26 = load ptr, ptr %stackEraser.i.i, align 8
  tail call void %eraser.i.i26(ptr %newStackPointer.i.i)
  %referenceCount.i.i27 = load i64, ptr %prompt.i, align 4
  %cond.i.i28 = icmp eq i64 %referenceCount.i.i27, 0
  br i1 %cond.i.i28, label %free.i.i30, label %decrement.i.i

decrement.i.i:                                    ; preds = %free.i25
  %newReferenceCount.i.i = add i64 %referenceCount.i.i27, -1
  store i64 %newReferenceCount.i.i, ptr %prompt.i, align 4
  br label %erasePrompt.exit.i

free.i.i30:                                       ; preds = %free.i25
  tail call void @free(ptr nonnull %prompt.i)
  br label %erasePrompt.exit.i

erasePrompt.exit.i:                               ; preds = %free.i.i30, %decrement.i.i
  %isNull.i29 = icmp eq ptr %rest.i, null
  br i1 %isNull.i29, label %eraseResumption.exit, label %tailrecurse.i

eraseResumption.exit:                             ; preds = %erasePrompt.exit.i, %decr.i22
  %stack_568 = extractvalue <{ ptr, ptr }> %pair_567, 1
  %utf8StringLiteral_5325 = tail call %Pos @c_bytearray_construct(i64 34, ptr nonnull @utf8StringLiteral_5325.lit)
  %functionPointer_573 = load ptr, ptr %Exception_2356.unpack, align 8, !noalias !0
  musttail call tailcc void %functionPointer_573(ptr %Exception_2356.unpack2, %Pos zeroinitializer, %Pos %utf8StringLiteral_5325, ptr %stack_568)
  ret void
}

define void @eraser_579(ptr nocapture readonly %environment) {
entry:
  %Exception_2356_578.elt1 = getelementptr i8, ptr %environment, i64 16
  %Exception_2356_578.unpack2 = load ptr, ptr %Exception_2356_578.elt1, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %Exception_2356_578.unpack2, null
  br i1 %isNull.i.i, label %eraseNegative.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %Exception_2356_578.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %Exception_2356_578.unpack2, align 4
  br label %eraseNegative.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %Exception_2356_578.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %Exception_2356_578.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %Exception_2356_578.unpack2)
  br label %eraseNegative.exit

eraseNegative.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  ret void
}

define tailcc void @returnAddress_590(i64 %v_coe_3472_22_3826, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %boxed1.i = insertvalue %Pos zeroinitializer, i64 %v_coe_3472_22_3826, 0
  %boxed2.i = insertvalue %Pos %boxed1.i, ptr null, 1
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_591 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_591(%Pos %boxed2.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_602(i64 %v_r_2666_1_9_20_3830, ptr %stack) {
entry:
  %stackPointer_pointer.i = getelementptr i8, ptr %stack, i64 8
  %stackPointer.i = load ptr, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %oldStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 24
  %limit_pointer.i = getelementptr i8, ptr %stack, i64 24
  %limit.i = load ptr, ptr %limit_pointer.i, align 8, !alias.scope !0
  %isInside.i = icmp ule ptr %oldStackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i)
  %z.i = sub i64 0, %v_r_2666_1_9_20_3830
  %isInside.i5 = icmp ule ptr %stackPointer.i, %limit.i
  tail call void @llvm.assume(i1 %isInside.i5)
  %newStackPointer.i = getelementptr i8, ptr %stackPointer.i, i64 -24
  store ptr %newStackPointer.i, ptr %stackPointer_pointer.i, align 8, !alias.scope !0
  %returnAddress_603 = load ptr, ptr %newStackPointer.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_603(i64 %z.i, ptr %stack)
  ret void
}

define tailcc void @returnAddress_585(i64 %v_r_2665_3_14_3838, ptr %stack) {
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
  %tmp_5288 = load i64, ptr %newStackPointer.i, align 4, !noalias !0
  %str_2061_pointer_588 = getelementptr i8, ptr %stackPointer.i, i64 -32
  %str_2061.unpack = load i64, ptr %str_2061_pointer_588, align 8, !noalias !0
  %0 = insertvalue %Pos poison, i64 %str_2061.unpack, 0
  %str_2061.elt1 = getelementptr i8, ptr %stackPointer.i, i64 -24
  %str_2061.unpack2 = load ptr, ptr %str_2061.elt1, align 8, !noalias !0
  %str_20613 = insertvalue %Pos %0, ptr %str_2061.unpack2, 1
  %Exception_2356_pointer_589 = getelementptr i8, ptr %stackPointer.i, i64 -16
  %Exception_2356.unpack = load ptr, ptr %Exception_2356_pointer_589, align 8, !noalias !0
  %1 = insertvalue %Neg poison, ptr %Exception_2356.unpack, 0
  %Exception_2356.elt4 = getelementptr i8, ptr %stackPointer.i, i64 -8
  %Exception_2356.unpack5 = load ptr, ptr %Exception_2356.elt4, align 8, !noalias !0
  %Exception_23566 = insertvalue %Neg %1, ptr %Exception_2356.unpack5, 1
  %z.i = icmp eq i64 %v_r_2665_3_14_3838, 45
  %isInside.not.i = icmp ugt ptr %Exception_2356_pointer_589, %limit.i
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
  %limit.i19 = phi ptr [ %newLimit.i, %realloc.i ], [ %limit.i, %entry ]
  %nextStackPointer.sink.i = phi ptr [ %newNextStackPointer.i, %realloc.i ], [ %Exception_2356_pointer_589, %entry ]
  %common.ret.op.i = phi ptr [ %newStackPointer.i15, %realloc.i ], [ %newStackPointer.i, %entry ]
  store ptr %nextStackPointer.sink.i, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_596 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_597 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_590, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_596, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_597, align 8, !noalias !0
  br i1 %z.i, label %label_610, label %label_601

label_601:                                        ; preds = %stackAllocate.exit
  musttail call tailcc void @go_2148(i64 0, i64 0, i64 %tmp_5288, %Pos %str_20613, %Neg %Exception_23566, ptr nonnull %stack)
  ret void

label_610:                                        ; preds = %stackAllocate.exit
  %nextStackPointer.i20 = getelementptr i8, ptr %nextStackPointer.sink.i, i64 24
  %isInside.not.i21 = icmp ugt ptr %nextStackPointer.i20, %limit.i19
  br i1 %isInside.not.i21, label %realloc.i24, label %stackAllocate.exit38

realloc.i24:                                      ; preds = %label_610
  %base_pointer.i25 = getelementptr i8, ptr %stack, i64 16
  %base.i26 = load ptr, ptr %base_pointer.i25, align 8, !alias.scope !0
  %intStackPointer.i27 = ptrtoint ptr %nextStackPointer.sink.i to i64
  %intBase.i28 = ptrtoint ptr %base.i26 to i64
  %size.i29 = sub i64 %intStackPointer.i27, %intBase.i28
  %nextSize.i30 = add i64 %size.i29, 24
  %leadingZeros.i.i31 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i30, i1 false)
  %numBits.i.i32 = sub nuw nsw i64 64, %leadingZeros.i.i31
  %result.i.i33 = shl nuw i64 1, %numBits.i.i32
  %newBase.i34 = tail call ptr @realloc(ptr %base.i26, i64 %result.i.i33)
  %newLimit.i35 = getelementptr i8, ptr %newBase.i34, i64 %result.i.i33
  %newStackPointer.i36 = getelementptr i8, ptr %newBase.i34, i64 %size.i29
  %newNextStackPointer.i37 = getelementptr i8, ptr %newStackPointer.i36, i64 24
  store ptr %newBase.i34, ptr %base_pointer.i25, align 8, !alias.scope !0
  store ptr %newLimit.i35, ptr %limit_pointer.i, align 8, !alias.scope !0
  br label %stackAllocate.exit38

stackAllocate.exit38:                             ; preds = %label_610, %realloc.i24
  %nextStackPointer.sink.i22 = phi ptr [ %newNextStackPointer.i37, %realloc.i24 ], [ %nextStackPointer.i20, %label_610 ]
  %common.ret.op.i23 = phi ptr [ %newStackPointer.i36, %realloc.i24 ], [ %nextStackPointer.sink.i, %label_610 ]
  store ptr %nextStackPointer.sink.i22, ptr %stackPointer_pointer.i, align 8
  %sharer_pointer_608 = getelementptr i8, ptr %common.ret.op.i23, i64 8
  %eraser_pointer_609 = getelementptr i8, ptr %common.ret.op.i23, i64 16
  store ptr @returnAddress_602, ptr %common.ret.op.i23, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_608, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_609, align 8, !noalias !0
  musttail call tailcc void @go_2148(i64 1, i64 0, i64 %tmp_5288, %Pos %str_20613, %Neg %Exception_23566, ptr nonnull %stack)
  ret void
}

define void @sharer_614(ptr %stackPointer) {
entry:
  %str_2061_612.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %str_2061_612.unpack2 = load ptr, ptr %str_2061_612.elt1, align 8, !noalias !0
  %Exception_2356_613.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2356_613.unpack5 = load ptr, ptr %Exception_2356_613.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2061_612.unpack2, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2061_612.unpack2, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %str_2061_612.unpack2, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %entry, %next.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2356_613.unpack5, null
  br i1 %isNull.i.i7, label %shareNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %sharePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2356_613.unpack5, align 4
  %referenceCount.1.i.i10 = add i64 %referenceCount.i.i9, 1
  store i64 %referenceCount.1.i.i10, ptr %Exception_2356_613.unpack5, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %sharePositive.exit, %next.i.i8
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackSharer.i = getelementptr i8, ptr %stackPointer, i64 -56
  %sharer.i = load ptr, ptr %stackSharer.i, align 8
  tail call void %sharer.i(ptr %newStackPointer.i)
  ret void
}

define void @eraser_622(ptr %stackPointer) {
entry:
  %str_2061_620.elt1 = getelementptr i8, ptr %stackPointer, i64 -24
  %str_2061_620.unpack2 = load ptr, ptr %str_2061_620.elt1, align 8, !noalias !0
  %Exception_2356_621.elt4 = getelementptr i8, ptr %stackPointer, i64 -8
  %Exception_2356_621.unpack5 = load ptr, ptr %Exception_2356_621.elt4, align 8, !noalias !0
  %isNull.i.i = icmp eq ptr %str_2061_620.unpack2, null
  br i1 %isNull.i.i, label %erasePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %entry
  %referenceCount.i.i = load i64, ptr %str_2061_620.unpack2, align 4
  %cond.i.i = icmp eq i64 %referenceCount.i.i, 0
  br i1 %cond.i.i, label %free.i.i, label %decr.i.i

decr.i.i:                                         ; preds = %next.i.i
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, -1
  store i64 %referenceCount.1.i.i, ptr %str_2061_620.unpack2, align 4
  br label %erasePositive.exit

free.i.i:                                         ; preds = %next.i.i
  %objectEraser.i.i = getelementptr i8, ptr %str_2061_620.unpack2, i64 8
  %eraser.i.i = load ptr, ptr %objectEraser.i.i, align 8
  %environment.i.i.i = getelementptr i8, ptr %str_2061_620.unpack2, i64 16
  tail call void %eraser.i.i(ptr %environment.i.i.i)
  tail call void @free(ptr nonnull %str_2061_620.unpack2)
  br label %erasePositive.exit

erasePositive.exit:                               ; preds = %entry, %decr.i.i, %free.i.i
  %isNull.i.i7 = icmp eq ptr %Exception_2356_621.unpack5, null
  br i1 %isNull.i.i7, label %eraseNegative.exit, label %next.i.i8

next.i.i8:                                        ; preds = %erasePositive.exit
  %referenceCount.i.i9 = load i64, ptr %Exception_2356_621.unpack5, align 4
  %cond.i.i10 = icmp eq i64 %referenceCount.i.i9, 0
  br i1 %cond.i.i10, label %free.i.i13, label %decr.i.i11

decr.i.i11:                                       ; preds = %next.i.i8
  %referenceCount.1.i.i12 = add i64 %referenceCount.i.i9, -1
  store i64 %referenceCount.1.i.i12, ptr %Exception_2356_621.unpack5, align 4
  br label %eraseNegative.exit

free.i.i13:                                       ; preds = %next.i.i8
  %objectEraser.i.i14 = getelementptr i8, ptr %Exception_2356_621.unpack5, i64 8
  %eraser.i.i15 = load ptr, ptr %objectEraser.i.i14, align 8
  %environment.i.i.i16 = getelementptr i8, ptr %Exception_2356_621.unpack5, i64 16
  tail call void %eraser.i.i15(ptr %environment.i.i.i16)
  tail call void @free(ptr nonnull %Exception_2356_621.unpack5)
  br label %eraseNegative.exit

eraseNegative.exit:                               ; preds = %erasePositive.exit, %decr.i.i11, %free.i.i13
  %newStackPointer.i = getelementptr i8, ptr %stackPointer, i64 -64
  %stackEraser.i = getelementptr i8, ptr %stackPointer, i64 -48
  %eraser.i = load ptr, ptr %stackEraser.i, align 8
  tail call void %eraser.i(ptr %newStackPointer.i)
  ret void
}

define tailcc void @toInt_2062(%Pos %str_2061, %Neg %Exception_2356, ptr %stack) local_unnamed_addr {
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
  %sharer_pointer_551 = getelementptr i8, ptr %common.ret.op.i, i64 8
  %eraser_pointer_552 = getelementptr i8, ptr %common.ret.op.i, i64 16
  store ptr @returnAddress_545, ptr %common.ret.op.i, align 8, !noalias !0
  store ptr @sharer_9, ptr %sharer_pointer_551, align 8, !noalias !0
  store ptr @eraser_11, ptr %eraser_pointer_552, align 8, !noalias !0
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
  %nextStackPointer.i18 = getelementptr i8, ptr %stackPointer.i.i, i64 24
  %isInside.not.i19 = icmp ugt ptr %nextStackPointer.i18, %limit.i.i
  br i1 %isInside.not.i19, label %realloc.i22, label %stackAllocate.exit36

realloc.i22:                                      ; preds = %stackAllocate.exit
  %newBase.i32 = tail call dereferenceable_or_null(32) ptr @realloc(ptr %stackPointer.i.i, i64 32)
  %newLimit.i33 = getelementptr i8, ptr %newBase.i32, i64 32
  %newNextStackPointer.i35 = getelementptr i8, ptr %newBase.i32, i64 24
  store ptr %newBase.i32, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i33, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit36

stackAllocate.exit36:                             ; preds = %stackAllocate.exit, %realloc.i22
  %nextStackPointer.sink.i20 = phi ptr [ %newNextStackPointer.i35, %realloc.i22 ], [ %nextStackPointer.i18, %stackAllocate.exit ]
  %common.ret.op.i21 = phi ptr [ %newBase.i32, %realloc.i22 ], [ %stackPointer.i.i, %stackAllocate.exit ]
  store ptr %nextStackPointer.sink.i20, ptr %stack.repack1.i, align 8
  %sharer_pointer_561 = getelementptr i8, ptr %common.ret.op.i21, i64 8
  %eraser_pointer_562 = getelementptr i8, ptr %common.ret.op.i21, i64 16
  store ptr @returnAddress_554, ptr %common.ret.op.i21, align 8, !noalias !0
  store ptr @sharer_130, ptr %sharer_pointer_561, align 8, !noalias !0
  store ptr @eraser_132, ptr %eraser_pointer_562, align 8, !noalias !0
  %object.i = tail call dereferenceable_or_null(40) ptr @malloc(i64 40)
  %objectEraser.i = getelementptr i8, ptr %object.i, i64 8
  store i64 0, ptr %object.i, align 4
  store ptr @eraser_579, ptr %objectEraser.i, align 8
  %environment.i = getelementptr i8, ptr %object.i, i64 16
  %object.i9 = extractvalue %Neg %Exception_2356, 1
  %isNull.i.i10 = icmp eq ptr %object.i9, null
  br i1 %isNull.i.i10, label %shareNegative.exit, label %next.i.i11

next.i.i11:                                       ; preds = %stackAllocate.exit36
  %referenceCount.i.i12 = load i64, ptr %object.i9, align 4
  %referenceCount.1.i.i13 = add i64 %referenceCount.i.i12, 1
  store i64 %referenceCount.1.i.i13, ptr %object.i9, align 4
  br label %shareNegative.exit

shareNegative.exit:                               ; preds = %stackAllocate.exit36, %next.i.i11
  store ptr %calloc.i.i, ptr %environment.i, align 8, !noalias !0
  %Exception_2356_pointer_583 = getelementptr i8, ptr %object.i, i64 24
  %Exception_2356.elt = extractvalue %Neg %Exception_2356, 0
  store ptr %Exception_2356.elt, ptr %Exception_2356_pointer_583, align 8, !noalias !0
  %Exception_2356_pointer_583.repack1 = getelementptr i8, ptr %object.i, i64 32
  store ptr %object.i9, ptr %Exception_2356_pointer_583.repack1, align 8, !noalias !0
  %object.i8 = extractvalue %Pos %str_2061, 1
  %isNull.i.i = icmp eq ptr %object.i8, null
  br i1 %isNull.i.i, label %sharePositive.exit, label %next.i.i

next.i.i:                                         ; preds = %shareNegative.exit
  %referenceCount.i.i = load i64, ptr %object.i8, align 4
  %referenceCount.1.i.i = add i64 %referenceCount.i.i, 1
  store i64 %referenceCount.1.i.i, ptr %object.i8, align 4
  br label %sharePositive.exit

sharePositive.exit:                               ; preds = %shareNegative.exit, %next.i.i
  %currentStackPointer.i39 = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i40 = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  %nextStackPointer.i41 = getelementptr i8, ptr %currentStackPointer.i39, i64 64
  %isInside.not.i42 = icmp ugt ptr %nextStackPointer.i41, %limit.i40
  br i1 %isInside.not.i42, label %realloc.i45, label %stackAllocate.exit59

realloc.i45:                                      ; preds = %sharePositive.exit
  %base.i47 = load ptr, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  %intStackPointer.i48 = ptrtoint ptr %currentStackPointer.i39 to i64
  %intBase.i49 = ptrtoint ptr %base.i47 to i64
  %size.i50 = sub i64 %intStackPointer.i48, %intBase.i49
  %nextSize.i51 = add i64 %size.i50, 64
  %leadingZeros.i.i52 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %nextSize.i51, i1 false)
  %numBits.i.i53 = sub nuw nsw i64 64, %leadingZeros.i.i52
  %result.i.i54 = shl nuw i64 1, %numBits.i.i53
  %newBase.i55 = tail call ptr @realloc(ptr %base.i47, i64 %result.i.i54)
  %newLimit.i56 = getelementptr i8, ptr %newBase.i55, i64 %result.i.i54
  %newStackPointer.i57 = getelementptr i8, ptr %newBase.i55, i64 %size.i50
  %newNextStackPointer.i58 = getelementptr i8, ptr %newStackPointer.i57, i64 64
  store ptr %newBase.i55, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i56, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit59

stackAllocate.exit59:                             ; preds = %sharePositive.exit, %realloc.i45
  %limit.i.i6064 = phi ptr [ %newLimit.i56, %realloc.i45 ], [ %limit.i40, %sharePositive.exit ]
  %nextStackPointer.sink.i43 = phi ptr [ %newNextStackPointer.i58, %realloc.i45 ], [ %nextStackPointer.i41, %sharePositive.exit ]
  %common.ret.op.i44 = phi ptr [ %newStackPointer.i57, %realloc.i45 ], [ %currentStackPointer.i39, %sharePositive.exit ]
  store ptr %nextStackPointer.sink.i43, ptr %stack.repack1.i, align 8
  store i64 48, ptr %common.ret.op.i44, align 4, !noalias !0
  %str_2061_pointer_629 = getelementptr i8, ptr %common.ret.op.i44, i64 8
  %str_2061.elt = extractvalue %Pos %str_2061, 0
  store i64 %str_2061.elt, ptr %str_2061_pointer_629, align 8, !noalias !0
  %str_2061_pointer_629.repack3 = getelementptr i8, ptr %common.ret.op.i44, i64 16
  store ptr %object.i8, ptr %str_2061_pointer_629.repack3, align 8, !noalias !0
  %Exception_2356_pointer_630 = getelementptr i8, ptr %common.ret.op.i44, i64 24
  store ptr %Exception_2356.elt, ptr %Exception_2356_pointer_630, align 8, !noalias !0
  %Exception_2356_pointer_630.repack6 = getelementptr i8, ptr %common.ret.op.i44, i64 32
  store ptr %object.i9, ptr %Exception_2356_pointer_630.repack6, align 8, !noalias !0
  %returnAddress_pointer_631 = getelementptr i8, ptr %common.ret.op.i44, i64 40
  %sharer_pointer_632 = getelementptr i8, ptr %common.ret.op.i44, i64 48
  %eraser_pointer_633 = getelementptr i8, ptr %common.ret.op.i44, i64 56
  store ptr @returnAddress_585, ptr %returnAddress_pointer_631, align 8, !noalias !0
  store ptr @sharer_614, ptr %sharer_pointer_632, align 8, !noalias !0
  store ptr @eraser_622, ptr %eraser_pointer_633, align 8, !noalias !0
  br i1 %isNull.i.i, label %sharePositive.exit.i, label %next.i.i.i

next.i.i.i:                                       ; preds = %stackAllocate.exit59
  %referenceCount.i.i.i = load i64, ptr %object.i8, align 4
  %referenceCount.1.i.i.i = add i64 %referenceCount.i.i.i, 1
  store i64 %referenceCount.1.i.i.i, ptr %object.i8, align 4
  %currentStackPointer.i.i.pre = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i.i60.pre = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %sharePositive.exit.i

sharePositive.exit.i:                             ; preds = %next.i.i.i, %stackAllocate.exit59
  %limit.i.i60 = phi ptr [ %limit.i.i60.pre, %next.i.i.i ], [ %limit.i.i6064, %stackAllocate.exit59 ]
  %currentStackPointer.i.i = phi ptr [ %currentStackPointer.i.i.pre, %next.i.i.i ], [ %nextStackPointer.sink.i43, %stackAllocate.exit59 ]
  %nextStackPointer.i.i = getelementptr i8, ptr %currentStackPointer.i.i, i64 64
  %isInside.not.i.i = icmp ugt ptr %nextStackPointer.i.i, %limit.i.i60
  br i1 %isInside.not.i.i, label %realloc.i.i, label %stackAllocate.exit.i

realloc.i.i:                                      ; preds = %sharePositive.exit.i
  %base.i.i = load ptr, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
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
  store ptr %newBase.i.i, ptr %stack.repack1.repack7.i, align 8, !alias.scope !0
  store ptr %newLimit.i.i, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  br label %stackAllocate.exit.i

stackAllocate.exit.i:                             ; preds = %realloc.i.i, %sharePositive.exit.i
  %nextStackPointer.sink.i.i = phi ptr [ %newNextStackPointer.i.i, %realloc.i.i ], [ %nextStackPointer.i.i, %sharePositive.exit.i ]
  %common.ret.op.i.i = phi ptr [ %newStackPointer.i.i, %realloc.i.i ], [ %currentStackPointer.i.i, %sharePositive.exit.i ]
  store ptr %nextStackPointer.sink.i.i, ptr %stack.repack1.i, align 8
  store i64 %str_2061.elt, ptr %common.ret.op.i.i, align 8, !noalias !0
  %stackPointer_409.repack1.i = getelementptr inbounds i8, ptr %common.ret.op.i.i, i64 8
  store ptr %object.i8, ptr %stackPointer_409.repack1.i, align 8, !noalias !0
  %index_2107_pointer_411.i = getelementptr i8, ptr %common.ret.op.i.i, i64 16
  store i64 0, ptr %index_2107_pointer_411.i, align 4, !noalias !0
  %Exception_2362_pointer_412.i = getelementptr i8, ptr %common.ret.op.i.i, i64 24
  store ptr @vtable_574, ptr %Exception_2362_pointer_412.i, align 8, !noalias !0
  %Exception_2362_pointer_412.repack3.i = getelementptr i8, ptr %common.ret.op.i.i, i64 32
  store ptr %object.i, ptr %Exception_2362_pointer_412.repack3.i, align 8, !noalias !0
  %returnAddress_pointer_413.i = getelementptr i8, ptr %common.ret.op.i.i, i64 40
  %sharer_pointer_414.i = getelementptr i8, ptr %common.ret.op.i.i, i64 48
  %eraser_pointer_415.i = getelementptr i8, ptr %common.ret.op.i.i, i64 56
  store ptr @returnAddress_375, ptr %returnAddress_pointer_413.i, align 8, !noalias !0
  store ptr @sharer_396, ptr %sharer_pointer_414.i, align 8, !noalias !0
  store ptr @eraser_404, ptr %eraser_pointer_415.i, align 8, !noalias !0
  %x.i.i = tail call i64 @c_bytearray_size(%Pos %str_2061)
  %z.i10.i = icmp slt i64 %x.i.i, 1
  %fat_z.i11.i = zext i1 %z.i10.i to i64
  %adt_boolean.i12.i = insertvalue %Pos zeroinitializer, i64 %fat_z.i11.i, 0
  %stackPointer.i.i61 = load ptr, ptr %stack.repack1.i, align 8, !alias.scope !0
  %limit.i15.i = load ptr, ptr %stack.repack1.repack9.i, align 8, !alias.scope !0
  %isInside.i.i = icmp ule ptr %stackPointer.i.i61, %limit.i15.i
  tail call void @llvm.assume(i1 %isInside.i.i)
  %newStackPointer.i16.i = getelementptr i8, ptr %stackPointer.i.i61, i64 -24
  store ptr %newStackPointer.i16.i, ptr %stack.repack1.i, align 8, !alias.scope !0
  %returnAddress_419.i = load ptr, ptr %newStackPointer.i16.i, align 8, !noalias !0
  musttail call tailcc void %returnAddress_419.i(%Pos %adt_boolean.i12.i, ptr nonnull %stack.i)
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
