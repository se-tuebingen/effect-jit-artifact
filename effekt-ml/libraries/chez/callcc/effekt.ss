
; ;; EXAMPLE
; ; (handle ([Fail_22 (Fail_109 () resume_120 (Nil_74))])
; ;       (let ((tmp86_121 ((Fail_109  Fail_22))))
; ;         (Cons_73  tmp86_121  (Nil_74))))
; (define-syntax handle
;   (syntax-rules ()
;     [(_ ((cap1 (op1 (arg1 ...) k exp ...) ...) ...) body ...)
;      (let ([P (newPrompt)])
;         (pushPrompt P
;           (let ([cap1 (cap1 (define-effect-op P (arg1 ...) k exp ...) ...)] ...)
;             body ...)))]))

(define-syntax handle
  (syntax-rules ()
    [(_ ((cap1 (op1 (arg1 ...) k exp ...) ...) ...) body)
     (let ([P (newPrompt)])
        (pushPrompt P
          (body (cap1 (define-effect-op P (arg1 ...) k exp ...) ...) ...)))]))

(define-syntax define-effect-op
  (syntax-rules ()
    [(_ P (arg1 ...) k exp ...)
     (lambda (arg1 ...)
       (shift0-at P k exp ...))]))

; state(init) { cell => ... }
(define (state init body)
  (with-region (lambda (arena) (body (fresh arena init)))))

(define call/cc/base call/cc)
