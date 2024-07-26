(let ()
  (define (get_568 ref)
    (lambda ()
      (unbox ref)))
  
  (define (put_567 ref)
    (lambda (value)
      (set-box! ref  value)))
  
  (define-record-type (Tuple2$Type158 Tuple2_158 Tuple2_158?)
    (fields [immutable first_161 first_161]
            [immutable second_162 second_162])
    (nongenerative Tuple2_158))
  
  (define (match-Tuple2_158 sc block)
    (block (first_161 sc)  (second_162 sc)))
  
  (define-record-type (Tuple3$Type163 Tuple3_163 Tuple3_163?)
    (fields [immutable first$1_167 first$1_167]
            [immutable second$1_168 second$1_168]
            [immutable third_169 third_169])
    (nongenerative Tuple3_163))
  
  (define (match-Tuple3_163 sc block)
    (block (first$1_167 sc)  (second$1_168 sc)  (third_169 sc)))
  
  (define-record-type (Tuple4$Type170 Tuple4_170 Tuple4_170?)
    (fields [immutable first$2_175 first$2_175]
            [immutable second$2_176 second$2_176]
            [immutable third$1_177 third$1_177]
            [immutable fourth_178 fourth_178])
    (nongenerative Tuple4_170))
  
  (define (match-Tuple4_170 sc block)
    (block (first$2_175 sc)  (second$2_176 sc)  (third$1_177 sc)  (fourth_178 sc)))
  
  (define-record-type (Tuple5$Type179 Tuple5_179 Tuple5_179?)
    (fields [immutable first$3_185 first$3_185]
            [immutable second$3_186 second$3_186]
            [immutable third$2_187 third$2_187]
            [immutable fourth$1_188 fourth$1_188]
            [immutable fifth_189 fifth_189])
    (nongenerative Tuple5_179))
  
  (define (match-Tuple5_179 sc block)
    (block (first$3_185 sc)  (second$3_186 sc)  (third$2_187 sc)  (fourth$1_188 sc)  (fifth_189 sc)))
  
  (define-record-type (Tuple6$Type190 Tuple6_190 Tuple6_190?)
    (fields [immutable first$4_197 first$4_197]
            [immutable second$4_198 second$4_198]
            [immutable third$3_199 third$3_199]
            [immutable fourth$2_200 fourth$2_200]
            [immutable fifth$1_201 fifth$1_201]
            [immutable sixth_202 sixth_202])
    (nongenerative Tuple6_190))
  
  (define (match-Tuple6_190 sc block)
    (block (first$4_197 sc)
            (second$4_198 sc)
            (third$3_199 sc)
            (fourth$2_200 sc)
            (fifth$1_201 sc)
            (sixth_202 sc)))
  
  (define-record-type (Exception$Type139 make-Exception_139 Exception_139?)
    (fields [immutable raise_206 raise_206])
    (nongenerative Exception_139))
  
  (define (match-Exception_139 sc block)
    (block (raise_206 sc)))
  
  (define-record-type (RuntimeError$Type207 RuntimeError_207 RuntimeError_207?)
    (fields )
    (nongenerative RuntimeError_207))
  
  (define (match-RuntimeError_207 sc block)
    (block))
  
  (define (show_impl obj)
    (cond
      [(number? obj) (show-number obj)]
      [(string? obj) obj]
      [(boolean? obj) (if obj "true" "false")]
      ; [(record? obj)
      ;   (let* ([rtd (record-rtd obj)]
      ;          [name (symbol->string (record-type-name rtd))])
      ;     ;; how can we show the fields?
      ;     (string-append name))]
      [(list? obj) (map show_impl obj)]
      [(record? obj) (show-record obj)]
      [else (generic-show obj)]))
  
  (define (generic-show obj)
    (define out (open-output-string))
    (write obj out)
    (get-output-string out))
  
  ; conform with the JS way of printing numbers
  (define (show-number n)
    (if (integer? n) (number->string (exact n)) (number->string n)))
  
  ; here we use eval to find the show function defined with the record...
  ; (define (show-record rec)
  ;   (let* ([rtd (record-rtd rec)]
  ;          [showName (string-append "show" (generic-show (record-type-name rtd)))]
  ;          [showFun (eval (string->symbol showName))])
  ;   (showFun rec)))
  
  ; we needed to add a unique id to the types in order to prevent duplicate definitions
  ; now for printing, we need to strip the unique id (starting with $) again.
  (define (strip-type-name tpe)
    (define out "")
    (define found #f)
    (for-each
      (lambda (el)
        (if (char=? el #\$) (set! found #t) #f)
        (if found #f (set! out (string-append out (string el)))))
      (string->list tpe))
    out)
  
  (define (show-record rec)
    (let* ([rtd (record-rtd rec)]
           [unique-tpe (generic-show (record-type-name rtd))]
           [tpe (strip-type-name unique-tpe)]
           [fields (record-type-field-names rtd)]
           [n (vector-length fields)])
       (define out (string-append tpe "("))
       (do ([i 0 (+ i 1)])
           ((= i n))
         (set! out (string-append out (show_impl ((record-accessor rtd i) rec))))
         (if (< i (- n 1)) (set! out (string-append out ", "))))
       (set! out (string-append out ")"))
       out))
  
  
  
  (define (println_impl obj)
    (display (show_impl obj))
    (newline))
  
  (define (equal_impl obj1 obj2)
    (equal? obj1 obj2))
  
  (define-syntax thunk
    (syntax-rules ()
      [(_ e ...) (lambda () e ...)]))
  
  ;; Benchmarking utils
  
  ; time in milliseconds
  (define (timed block)
    (let ([before (current-time)])
      (block)
      (let ([after (current-time)])
        (seconds (time-difference after before)))))
  
  (define (seconds diff)
    (+ (time-second diff) (/ (time-nanosecond diff) 1000000000.0)))
  
  (define (measure block warmup iterations)
    (define (run n)
      (if (<= n 0)
          '()
          (begin
            (collect)
            (cons (timed block) (run (- n 1))))))
    (begin
      (run warmup)
      (run iterations)))
  
  (define (hole)
    (raise
      (condition
        (make-error)
        (make-message-condition "not implemented"))))
  
  (define-syntax delayed
    (syntax-rules ()
      [(_ e ...)
        (lambda (k) (k
          (begin e ...)))]))
  
  (define (pure v)
    (lambda (k) (k v)))
  
  
  ; (then m a n) -> (lambda (k) (m (lambda (a) (n k))))
  (define-syntax then
    (syntax-rules ()
      [(_ m a f1 ...)
       (lambda (k) (m (lambda (a) ((let () f1 ...) k))))]))
  
  (define ($then m f)
    (lambda (k) (m (lambda (a) ((f a) k)))))
  
  (define (here x) x)
  
  ; (define (while cond exp)
  ;   ($then cond (lambda (c)
  ;     (if c ($then exp (lambda (_) (while cond exp))) (pure #f)))))
  
  (define-syntax while
    (syntax-rules ()
      [(_ c e)
       (let ([condition (lambda () c)])
         (letrec ([loop (lambda (u)
           ($then (condition) (lambda (condValue)
             (if condValue ($then e loop) (pure #f)))))])
           (loop #f)))]))
  
  ; (define-syntax lift
  ;   (syntax-rules ()
  ;     [(_ m)
  ;      (lambda (k1)
  ;        (lambda (k2)
  ;          (m (lambda (a) ((k1 a) k2)))))]))
  
  (define (lift m)
    (lambda (k1)
      (lambda (k2)
        (m (lambda (a) ((k1 a) k2))))))
  
  (define (id x) x)
  
  
  ; (define (reset m) (m (lambda (v) (lambda (k) (k v)))))
  
  (define-syntax reset
    (syntax-rules ()
      [(_ m)
       (m (lambda (v) (lambda (k) (k v))))]))
  
  (define (run m) (m id))
  
  
  
  ; ;; EXAMPLE
  ; ; (handle ([Fail_22 (Fail_109 () resume_120 (Nil_74))])
  ; ;       (let ((tmp86_121 ((Fail_109  Fail_22))))
  ; ;         (Cons_73  tmp86_121  (Nil_74))))
  
  
  ; capabilities first take evidence than require selection!
  (define-syntax handle
    (syntax-rules ()
      [(_ ((cap1 (op1 (arg1 ...) kid exp) ...) ...) body)
       (reset (body lift
         (cap1 (define-effect-op ev (arg1 ...) kid exp) ...) ...))]))
  
  
  (define-syntax define-effect-op
    (syntax-rules ()
      [(_ ev1 (arg1 ...) kid exp ...)
       (lambda (ev1 arg1 ...)
          ; we apply the outer evidence to the body of the operation
          (ev1 (lambda (resume)
            ; k itself also gets evidence!
            (let ([kid (lambda (ev v) (ev (resume v)))])
              exp ...))))]))
  
  
  (define (with-region body)
    (define arena (make-arena))
  
    (define (lift m) (lambda (k)
      ; on suspend
      (define fields (backup arena))
      (m (lambda (a)
        ; on resume
        (restore fields)
        (k a)))))
  
    (body lift arena))
  
  
  ; An Arena is a pointer to a list of cells
  (define (make-arena) (box '()))
  
  (define (fresh arena init)
    (let* ([cell (box init)]
           [cells (unbox arena)])
      (set-box! arena (cons cell cells))
      cell))
  
  ; Backup = List<(Cell, Value)>
  
  ; Arena -> Backup
  (define (backup arena)
    (let ([fields (unbox arena)])
      (map (lambda (cell) (cons cell (unbox cell))) fields)))
  
  ; Backup -> ()
  (define (restore data)
    (for-each (lambda (cell-data)
      (set-box! (car cell-data) (cdr cell-data)))
      data))
  
  (define-syntax nested-helper
    (syntax-rules ()
      [(_ (ev) acc) (ev acc)]
      [(_ (ev1 ev2 ...) acc)
        (nested-helper (ev2 ...) (ev1 acc))]))
  
  (define-syntax nested
    (syntax-rules ()
      [(_ ev1 ...) (lambda (m) (nested-helper (ev1 ...) m))]))
  
  ; should also work for handlers / capabilities
  (define (lift-block f ev)
    (lambda (ev2) (f (nested ev ev2))))
  
  ; Matcher = (SCRUTINEE, ANS -> () -> R, () -> R, (ANS -> () -> R) -> R) -> R
  
  (define done (lambda (matched) (matched)))
  
  (define (any m matched failed k)
    (k (matched m)))
  
  (define (ignore m matched failed k)
    (k matched))
  
  (define (literal l)
    (lambda (m matched failed k)
      (if (equal_impl m l)
          (k matched)
          (failed))))
  
  (define (bind p)
    (lambda (m matched failed k)
      (p m (matched m) failed k)))
  
  ;; for this record
  ; (define-record Pair (fst snd))
  
  ;; this is what we need to generate
  ; (define (match-Pair p1 p2)
  ;   (lambda (m matched failed k)
  ;     (if (Pair? m)
  ;       (p1 (Pair-fst m) matched failed (lambda (matched)
  ;         (p2 (Pair-snd m) matched failed k)))
  ;       (failed))))
  
  
  (define-syntax define-matcher
    (syntax-rules ()
      [(_ name pred ())
        (define (name)
          (lambda (sc matched failed k)
            (if (pred sc) (k matched) (failed))))]
      [(_ name pred ((p1 sel1) (p2 sel2) ...))
       (define (name p1 p2 ...)
         (lambda (m matched failed k)
               ;; has correct tag?
               (if (pred m)
                   (match-fields m matched failed k ([p1 sel1] [p2 sel2] ...))
                   (failed))))]))
  
  (define-syntax match-fields
    (syntax-rules ()
      [(_ m matched failed k ()) (k matched)]
      [(_ m matched failed k ([p1 sel1] [p2 sel2] ...))
       (p1 (sel1 m) matched failed (lambda (matched)
         (match-fields m matched failed k ([p2 sel2] ...))))]))
  
  
  ; forces the pattern match
  (define-syntax pattern-match
    (syntax-rules ()
      [(_ m ()) (raise "no patterns provided")]
      [(_ m ([p1 k1] [p2 k2]...))
        (p1 m k1 (lambda () (pattern-match m ([p2 k2] ...))) done)]))
  
  ;; Examples
  
  ; (define-matcher match-Pair2 Pair? ([p1 Pair-fst] [p2 Pair-snd]))
  
  ; (define (match sc p matched)
  ;   (p sc matched abort done))
  
  ; (display (match (make-Pair 1 2)
  ;   (match-Pair2 any any)
  ;   (lambda (x) (lambda (y) (lambda () (+ x y))))))
  
  ; (display (match 3
  ;   (match-Pair2 any any)
  ;   (lambda (x) (lambda (y) (lambda () (+ x y))))))
  
  ; (display (match (make-Pair 1 2)
  ;   (match-Pair2 any (match-Pair2 ignore any))
  ;   (lambda (x) (lambda (y) (lambda () (+ x y))))))
  
  ; (display (match (make-Pair 1 (make-Pair 2 3))
  ;   (match-Pair2 any (match-Pair2 ignore any))
  ;   (lambda (x) (lambda (y) (lambda () (+ x y))))))
  
  ; (display (match (make-Pair (make-Pair 1 2) (make-Pair 3 4))
  ;   (match-Pair (match-Pair ignore any) (match-Pair ignore any))
  ;   (lambda (x) (lambda (y) (lambda () (+ x y))))))
  
  ; (display (match (make-Pair (make-Pair 1 2) (make-Pair 10 15))
  ;   (match-Pair2 (match-Pair2 any ignore) (match-Pair2 ignore any))
  ;   (lambda (x) (lambda (y) (lambda () (+ x y))))))
  
  ; (display (match (make-Pair (make-Pair 1 2) (make-Pair 10 15))
  ;   (match-Pair2 (match-Pair2 any ignore) (match-Pair2 ignore any))
  ;   (lambda (x) (lambda (y) (lambda () (+ x y))))))
  
  ; (display (pattern-match (make-Pair 1 2)
  ;   ([(match-Pair2 (match-Pair2 any ignore) (match-Pair2 ignore any))
  ;       (lambda (x) (lambda (y) (lambda () (+ x y))))]
  ;    [any (lambda (x) (lambda () (Pair-snd x)))])))
  
  
  (define infixConcat_6 (lambda (s1 s2)
    (string-append s1 s2)))
  
  (define show_9 (lambda (value)
    (show_impl value)))
  
  (define println_12 (lambda (r)
    (println_impl r)))
  
  (define error_15 (lambda (msg)
    (raise msg)))
  
  (define random_16 (lambda ()
    (random 1.0)))
  
  (define infixAdd_19 (lambda (x y)
    (+ x y)))
  
  (define infixMul_22 (lambda (x y)
    (* x y)))
  
  (define infixDiv_25 (lambda (x y)
    (floor (/ x y))))
  
  (define infixSub_28 (lambda (x y)
    (- x y)))
  
  (define mod_31 (lambda (x y)
    (modulo x y)))
  
  (define infixAdd$1_34 (lambda (x y)
    (+ x y)))
  
  (define infixMul$1_37 (lambda (x y)
    (* x y)))
  
  (define infixDiv$1_40 (lambda (x y)
    (/ x y)))
  
  (define infixSub$1_43 (lambda (x y)
    (- x y)))
  
  (define cos_45 (lambda (x)
    (cos x)))
  
  (define sin_47 (lambda (x)
    (sin x)))
  
  (define atan_49 (lambda (x)
    (atan x)))
  
  (define tan_51 (lambda (x)
    (tan x)))
  
  (define sqrt_53 (lambda (x)
    (sqrt x)))
  
  (define square_55 (lambda (x)
    (* x x)))
  
  (define log_57 (lambda (x)
    (log x)))
  
  (define log1p_59 (lambda (x)
    (log (+ x 1))))
  
  (define exp_61 (lambda (x)
    (exp x)))
  
  (define _pi_62 (lambda ()
    (* 4 (atan 1))))
  
  (define toInt_64 (lambda (d)
    (round d)))
  
  (define toDouble_66 (lambda (d)
    d))
  
  (define infixEq_70 (lambda (x y)
    (equal_impl x y)))
  
  (define infixNeq_74 (lambda (x y)
    (not (equal_impl x y))))
  
  (define infixLt_77 (lambda (x y)
    (< x y)))
  
  (define infixLte_80 (lambda (x y)
    (<= x y)))
  
  (define infixGt_83 (lambda (x y)
    (> x y)))
  
  (define infixGte_86 (lambda (x y)
    (>= x y)))
  
  (define infixLt$1_89 (lambda (x y)
    (< x y)))
  
  (define infixLte$1_92 (lambda (x y)
    (<= x y)))
  
  (define infixGt$1_95 (lambda (x y)
    (> x y)))
  
  (define infixGte$1_98 (lambda (x y)
    (>= x y)))
  
  (define not_100 (lambda (b)
    (not b)))
  
  (define infixOr_103 (lambda (x y)
    (or x y)))
  
  (define infixAnd_106 (lambda (x y)
    (and x y)))
  
  (define isUndefined_109 (lambda (value)
    (eq? value #f)))
  
  (define panic_137 (lambda (msg)
    (raise msg)))
  
  (define measure_156 (lambda (warmup iterations block)
    (delayed (display (measure (lambda () (run ((block here)))) warmup iterations)))))
  
  (define locally_3 (lambda (ev768_768 ev769_769 f_1)
    (f_1 (nested ev769_769))))
  
  (define PI_157 (_pi_62))
  
  (define raise_143 (lambda (ev770_770 ev771_771 msg_142 Exception$capability_274)
    ((raise_206 Exception$capability_274) (nested ev771_771)  (RuntimeError_207)  msg_142)))
  
  (define panicOn_146 (lambda (ev773_773 ev774_774 prog_145)
    (handle ([make-Exception_139 (raise_206 (exception_209  msg_210) resume_211 
                                   (let ()
                                     (define tmp588_783 (panic_137 msg_210))
                                     (pure tmp588_783)))]) 
      (lambda (ev775_775 Exception$capability_273)
        (prog_145 (nested ev775_775  ev774_774)  here  Exception$capability_273)))))
  
  (define report_149 (lambda (ev776_776 ev777_777 prog_148)
    (handle ([make-Exception_139 (raise_206 (exception_213  msg_214) resume_215 
                                   (let ()
                                     (define tmp593_782 (println_12 msg_214))
                                     (pure tmp593_782)))]) 
      (lambda (ev778_778 Exception$capability_275)
        (prog_148 (nested ev778_778  ev777_777)  here  Exception$capability_275)))))
  
  (define ignoring_152 (lambda (ev779_779 ev780_780 prog_151)
    (handle ([make-Exception_139 (raise_206 (exception_217  msg_218) resume_219 
                                   (pure #f))]) 
      (lambda (ev781_781 Exception$capability_276)
        (prog_151 (nested ev781_781  ev780_780)  here  Exception$capability_276)))))
  
  (define-record-type (None$Type305 None_305 None_305?)
    (fields )
    (nongenerative None_305))
  
  (define (match-None_305 sc block)
    (block))
  
  (define-record-type (Some$Type306 Some_306 Some_306?)
    (fields [immutable value_308 value_308])
    (nongenerative Some_306))
  
  (define (match-Some_306 sc block)
    (block (value_308 sc)))
  
  (define isDefined_281 (lambda (ev784_784 self_280)
    (define tmp600_825 self_280)
    
    (define tmp601_785 (lambda (ev787_787)
      (pure #f)))
    
    (define tmp602_786 (lambda (ev788_788 v_309)
      (pure #t)))
    (cond 
      [(None_305? tmp600_825) (match-None_305 tmp600_825  (lambda () (tmp601_785 here)))]
      [(Some_306? tmp600_825) (match-Some_306 tmp600_825
        (lambda (tmp603_826)
         (tmp602_786 here  tmp603_826)))])))
  
  (define isEmpty_284 (lambda (ev789_789 self_283)
    (define tmp606_824 (run (isEmpty_284 (nested ev789_789)  self_283)))
    (pure (not_100 tmp606_824))))
  
  (define orElse_288 (lambda (ev790_790 ev791_791 self_286 that_287)
    (define tmp607_822 self_286)
    
    (define tmp610_792 (lambda (ev794_794)
      (that_287 (nested ev794_794  ev791_791))))
    
    (define tmp611_793 (lambda (ev795_795 v_310)
      (pure (Some_306 v_310))))
    (cond 
      [(None_305? tmp607_822) (match-None_305 tmp607_822  (lambda () (tmp610_792 here)))]
      [(Some_306? tmp607_822) (match-Some_306 tmp607_822
        (lambda (tmp612_823)
         (tmp611_793 here  tmp612_823)))])))
  
  (define getOrElse_292 (lambda (ev796_796 ev797_797 self_290 that_291)
    (define tmp615_820 self_290)
    
    (define tmp618_798 (lambda (ev800_800)
      (that_291 (nested ev800_800  ev797_797))))
    
    (define tmp619_799 (lambda (ev801_801 v_311)
      (pure v_311)))
    (cond 
      [(None_305? tmp615_820) (match-None_305 tmp615_820  (lambda () (tmp618_798 here)))]
      [(Some_306? tmp615_820) (match-Some_306 tmp615_820
        (lambda (tmp620_821)
         (tmp619_799 here  tmp620_821)))])))
  
  (define map_297 (lambda (ev802_802 ev803_803 self_295 f_296)
    (define tmp623_817 self_295)
    
    (define tmp624_804 (lambda (ev806_806)
      (pure (None_305))))
    
    (define tmp626_805 (lambda (ev807_807 v_312)
      ($then (f_296 (nested ev807_807  ev803_803)  v_312)
              (lambda (tmp625_819)
               (pure (Some_306 tmp625_819))))))
    (cond 
      [(None_305? tmp623_817) (match-None_305 tmp623_817  (lambda () (tmp624_804 here)))]
      [(Some_306? tmp623_817) (match-Some_306 tmp623_817
        (lambda (tmp627_818)
         (tmp626_805 here  tmp627_818)))])))
  
  (define foreach_301 (lambda (ev808_808 ev809_809 self_299 f_300)
    (define tmp630_815 self_299)
    
    (define tmp631_810 (lambda (ev812_812)
      (pure #f)))
    
    (define tmp634_811 (lambda (ev813_813 v_313)
      (f_300 (nested ev813_813  ev809_809)  v_313)))
    (cond 
      [(None_305? tmp630_815) (match-None_305 tmp630_815  (lambda () (tmp631_810 here)))]
      [(Some_306? tmp630_815) (match-Some_306 tmp630_815
        (lambda (tmp635_816)
         (tmp634_811 here  tmp635_816)))])))
  
  (define undefinedToOption_304 (lambda (ev814_814 value_303)
    (if (isUndefined_109 value_303)
      (pure (None_305))
      (pure (Some_306 value_303)))))
  
  (define-record-type (Nil$Type402 Nil_402 Nil_402?)
    (fields )
    (nongenerative Nil_402))
  
  (define (match-Nil_402 sc block)
    (block))
  
  (define-record-type (Cons$Type403 Cons_403 Cons_403?)
    (fields [immutable head$1_406 head$1_406]
            [immutable tail$1_407 tail$1_407])
    (nongenerative Cons_403))
  
  (define (match-Cons_403 sc block)
    (block (head$1_406 sc)  (tail$1_407 sc)))
  
  (define map_363 (lambda (ev827_827 ev828_828 l_361 f_362)
    (define tmp640_904 l_361)
    
    (define tmp641_829 (lambda (ev831_831)
      (pure (Nil_402))))
    
    (define tmp646_830 (lambda (ev832_832 a_408 rest_409)
      ($then (f_362 (nested ev832_832  ev828_828)  a_408)
              (lambda (tmp642_905)
               ($then (map_363 (nested ev832_832  ev827_827)
              here
              rest_409
              (lambda (ev833_833 a_410)
               (f_362 (nested ev833_833  ev832_832  ev828_828)  a_410)))
              (lambda (tmp645_906)
               (pure (Cons_403 tmp642_905  tmp645_906))))))))
    (cond 
      [(Nil_402? tmp640_904) (match-Nil_402 tmp640_904  (lambda () (tmp641_829 here)))]
      [(Cons_403? tmp640_904) (match-Cons_403 tmp640_904
        (lambda (tmp647_650 tmp648_649)
         (tmp646_830 here  tmp647_650  tmp648_649)))])))
  
  (define foreach_367 (lambda (ev834_834 ev835_835 l_365 f_366)
    (define tmp653_902 l_365)
    
    (define tmp654_836 (lambda (ev838_838)
      (pure #f)))
    
    (define tmp661_837 (lambda (ev839_839 a_411 rest_412)
      ($then (f_366 (nested ev839_839  ev835_835)  a_411)
              (lambda (__903)
               (foreach_367 (nested ev839_839  ev834_834)
              here
              rest_412
              (lambda (ev840_840 a_413)
               (f_366 (nested ev840_840  ev839_839  ev835_835)  a_413)))))))
    (cond 
      [(Nil_402? tmp653_902) (match-Nil_402 tmp653_902  (lambda () (tmp654_836 here)))]
      [(Cons_403? tmp653_902) (match-Cons_403 tmp653_902
        (lambda (tmp662_665 tmp663_664)
         (tmp661_837 here  tmp662_665  tmp663_664)))])))
  
  (define size_370 (lambda (ev841_841 l_369)
    (define tmp668_900 l_369)
    
    (define tmp669_842 (lambda (ev844_844)
      (pure 0)))
    
    (define tmp671_843 (lambda (ev845_845 rest_414)
      (define tmp670_901 (run (size_370 (nested ev845_845  ev841_841)  rest_414)))
      (pure (infixAdd_19 1  tmp670_901))))
    (cond 
      [(Nil_402? tmp668_900) (match-Nil_402 tmp668_900  (lambda () (tmp669_842 here)))]
      [(Cons_403? tmp668_900) (match-Cons_403 tmp668_900
        (lambda (tmp672_675 tmp673_674)
         (tmp671_843 here  tmp673_674)))])))
  
  (define reverse_373 (lambda (ev846_846 l_372)
    (define reverseWith_417 (lambda (ev847_847 l_415 acc_416)
      (define tmp678_899 l_415)
      
      (define tmp679_848 (lambda (ev850_850)
        (pure acc_416)))
      
      (define tmp682_849 (lambda (ev851_851 a_418 rest_419)
        (reverseWith_417 (nested ev851_851  ev847_847)  rest_419  (Cons_403 a_418  acc_416))))
      (cond 
        [(Nil_402? tmp678_899) (match-Nil_402 tmp678_899  (lambda () (tmp679_848 here)))]
        [(Cons_403? tmp678_899) (match-Cons_403 tmp678_899
          (lambda (tmp683_686 tmp684_685)
           (tmp682_849 here  tmp683_686  tmp684_685)))])))
    (reverseWith_417 here  l_372  (Nil_402))))
  
  (define reverseOnto_377 (lambda (ev852_852 l_375 other_376)
    (define tmp691_898 l_375)
    
    (define tmp692_853 (lambda (ev855_855)
      (pure other_376)))
    
    (define tmp695_854 (lambda (ev856_856 a_420 rest_421)
      (reverseOnto_377 (nested ev856_856  ev852_852)  rest_421  (Cons_403 a_420  other_376))))
    (cond 
      [(Nil_402? tmp691_898) (match-Nil_402 tmp691_898  (lambda () (tmp692_853 here)))]
      [(Cons_403? tmp691_898) (match-Cons_403 tmp691_898
        (lambda (tmp696_699 tmp697_698)
         (tmp695_854 here  tmp696_699  tmp697_698)))])))
  
  (define append_381 (lambda (ev857_857 l_379 other_380)
    (define tmp702_897 (run (reverse_373 (nested ev857_857)  l_379)))
    (reverseOnto_377 (nested ev857_857)  tmp702_897  other_380)))
  
  (define take_385 (lambda (ev858_858 l_383 n_384)
    (if (infixEq_70 n_384  0)
      (pure (Nil_402))
      (let ()
        (define tmp705_895 l_383)
        
        (define tmp706_859 (lambda (ev861_861)
          (pure (Nil_402))))
        
        (define tmp708_860 (lambda (ev862_862 a_422 rest_423)
          (define tmp707_896 (run (take_385 (nested ev862_862  ev858_858)
                                   rest_423
                                   (infixSub_28 n_384  1))))
          (pure (Cons_403 a_422  tmp707_896))))
        (cond 
          [(Nil_402? tmp705_895) (match-Nil_402 tmp705_895  (lambda () (tmp706_859 here)))]
          [(Cons_403? tmp705_895) (match-Cons_403 tmp705_895
            (lambda (tmp709_712 tmp710_711)
             (tmp708_860 here  tmp709_712  tmp710_711)))])))))
  
  (define drop_389 (lambda (ev863_863 l_387 n_388)
    (if (infixEq_70 n_388  0)
      (pure l_387)
      (let ()
        (define tmp717_894 l_387)
        
        (define tmp718_864 (lambda (ev866_866)
          (pure (Nil_402))))
        
        (define tmp721_865 (lambda (ev867_867 a_424 rest_425)
          (drop_389 (nested ev867_867  ev863_863)  rest_425  (infixSub_28 n_388  1))))
        (cond 
          [(Nil_402? tmp717_894) (match-Nil_402 tmp717_894  (lambda () (tmp718_864 here)))]
          [(Cons_403? tmp717_894) (match-Cons_403 tmp717_894
            (lambda (tmp722_725 tmp723_724)
             (tmp721_865 here  tmp722_725  tmp723_724)))])))))
  
  (define isEmpty_392 (lambda (ev868_868 l_391)
    (define tmp730_893 l_391)
    
    (define tmp731_869 (lambda (ev871_871)
      (pure #t)))
    
    (define tmp732_870 (lambda (ev872_872 a_426 rest_427)
      (pure #f)))
    (cond 
      [(Nil_402? tmp730_893) (match-Nil_402 tmp730_893  (lambda () (tmp731_869 here)))]
      [(Cons_403? tmp730_893) (match-Cons_403 tmp730_893
        (lambda (tmp733_736 tmp734_735)
         (tmp732_870 here  tmp733_736  tmp734_735)))])))
  
  (define head_395 (lambda (ev873_873 l_394)
    (define tmp739_891 l_394)
    
    (define tmp741_874 (lambda (ev876_876)
      (define tmp740_892 (error_15 "Trying to get the head of an empty list"))
      (pure tmp740_892)))
    
    (define tmp742_875 (lambda (ev877_877 a_428 rest_429)
      (pure a_428)))
    (cond 
      [(Nil_402? tmp739_891) (match-Nil_402 tmp739_891  (lambda () (tmp741_874 here)))]
      [(Cons_403? tmp739_891) (match-Cons_403 tmp739_891
        (lambda (tmp743_746 tmp744_745)
         (tmp742_875 here  tmp743_746  tmp744_745)))])))
  
  (define tail_398 (lambda (ev878_878 l_397)
    (define tmp749_889 l_397)
    
    (define tmp751_879 (lambda (ev881_881)
      (define tmp750_890 (error_15 "Trying to get the head of an empty list"))
      (pure tmp750_890)))
    
    (define tmp752_880 (lambda (ev882_882 a_430 rest_431)
      (pure rest_431)))
    (cond 
      [(Nil_402? tmp749_889) (match-Nil_402 tmp749_889  (lambda () (tmp751_879 here)))]
      [(Cons_403? tmp749_889) (match-Cons_403 tmp749_889
        (lambda (tmp753_756 tmp754_755)
         (tmp752_880 here  tmp753_756  tmp754_755)))])))
  
  (define headOption_401 (lambda (ev883_883 l_400)
    (define tmp759_888 l_400)
    
    (define tmp760_884 (lambda (ev886_886)
      (pure (None_305))))
    
    (define tmp761_885 (lambda (ev887_887 a_432 rest_433)
      (pure (Some_306 a_432))))
    (cond 
      [(Nil_402? tmp759_888) (match-Nil_402 tmp759_888  (lambda () (tmp760_884 here)))]
      [(Cons_403? tmp759_888) (match-Cons_403 tmp759_888
        (lambda (tmp762_765 tmp763_764)
         (tmp761_885 here  tmp762_765  tmp763_764)))])))
  
  (define-record-type (Foo$Type537 make-Foo_537 Foo_537?)
    (fields [immutable foo_540 foo_540])
    (nongenerative Foo_537))
  
  (define (match-Foo_537 sc block)
    (block (foo_540 sc)))
  
  (define-record-type (Bar$Type538 make-Bar_538 Bar_538?)
    (fields [immutable drink_541 drink_541])
    (nongenerative Bar_538))
  
  (define (match-Bar_538 sc block)
    (block (drink_541 sc)))
  
  (define main_539 (lambda (ev907_907)
    (handle ([make-Foo_537 (foo_540 () resume_542 
                             (let ()
                               (println_12 "Foo")
                               (resume_542 here  #f)))]) 
      (lambda (ev908_908 Foo$capability_909)
        ($then (handle ([make-Bar_538 (drink_541 () resume_543 
                 (let ()
                   (println_12 "Mate")
                   (resume_543 here  #f)))]) 
                 (lambda (ev910_910 Bar$capability_911)
                   ($then ((drink_541 Bar$capability_911) here)
                           (lambda (__915)
                            (pure (lambda (ev912_912 ev913_913 Foo$capability_914)
                            ((foo_540 Foo$capability_914) (nested ev913_913))))))))
                (lambda (tmp575_916)
                 (define f_544 tmp575_916)
                 (f_544 here  here  Foo$capability_909)))))))
  (run (main_539 here)))