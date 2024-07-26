(let ()
  (define (get_1281 ref)
    (lambda (ev)
      (lambda (k1282)
        (k1282 (unbox ref)))))
  
  (define (put_1283 ref)
    (lambda (ev value)
      (lambda (k1284)
        (k1284 (set-box! ref  value)))))
  
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
  
  (define-record-type (Exception$Type139 Exception_139 Exception_139?)
    (fields [immutable raise_206 raise_206])
    (nongenerative Exception_139))
  
  (define (match-Exception_139 sc block)
    (block (raise_206 sc)))
  
  (define-record-type (RuntimeError$Type207 RuntimeError_207 RuntimeError_207?)
    (fields )
    (nongenerative RuntimeError_207))
  
  (define (match-RuntimeError_207 sc block)
    (block))
  
  (define-record-type (None$Type301 None_301 None_301?)
    (fields )
    (nongenerative None_301))
  
  (define (match-None_301 sc block)
    (block))
  
  (define-record-type (Some$Type302 Some_302 Some_302?)
    (fields [immutable value_304 value_304])
    (nongenerative Some_302))
  
  (define (match-Some_302 sc block)
    (block (value_304 sc)))
  
  (define-record-type (Nil$Type398 Nil_398 Nil_398?)
    (fields )
    (nongenerative Nil_398))
  
  (define (match-Nil_398 sc block)
    (block))
  
  (define-record-type (Cons$Type399 Cons_399 Cons_399?)
    (fields [immutable head$1_402 head$1_402]
            [immutable tail$1_403 tail$1_403])
    (nongenerative Cons_399))
  
  (define (match-Cons_399 sc block)
    (block (head$1_402 sc)  (tail$1_403 sc)))
  
  (define-record-type (Increment$Type604 Increment_604 Increment_604?)
    (fields [immutable increment_608 increment_608])
    (nongenerative Increment_604))
  
  (define (match-Increment_604 sc block)
    (block (increment_608 sc)))
  
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
  
  
  ;; EVIDENCE
  
  (define (here x) x)
  
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
  
  (define-syntax nested-helper
    (syntax-rules ()
      [(_ (ev) acc) (ev acc)]
      [(_ (ev1 ev2 ...) acc)
        (nested-helper (ev2 ...) (ev1 acc))]))
  
  (define-syntax nested
    (syntax-rules ()
      [(_ ev1 ...) (lambda (m) (nested-helper (ev1 ...) m))]))
  
  
  ;; HANDLING
  
  ; (define (reset m) (m (lambda (v) (lambda (k) (k v)))))
  
  (define-syntax reset
    (syntax-rules ()
      [(_ m)
       (m (lambda (v) (lambda (k) (k v))))]))
  
  ; ;; EXAMPLE
  ; ; (handle ([Fail_22 (Fail_109 () resume_120 (Nil_74))])
  ; ;       (let ((tmp86_121 ((Fail_109  Fail_22))))
  ; ;         (Cons_73  tmp86_121  (Nil_74))))
  
  
  (define-syntax define-effect-op
    (syntax-rules ()
      [(_ ev1 (arg1 ...) kid exp ...)
       (lambda (ev1 arg1 ...)
          ; we apply the outer evidence to the body of the operation
          (ev1 (lambda (resume)
            ; k itself also gets evidence!
            (let ([kid (lambda (ev v) (ev (resume v)))])
              exp ...))))]))
  
  
  ; capabilities first take evidence than require selection!
  (define-syntax handle
    (syntax-rules ()
      [(_ ((cap1 (op1 (arg1 ...) kid exp) ...) ...) body)
       (reset (body lift
         (cap1 (define-effect-op ev (arg1 ...) kid exp) ...) ...))]))
  
  
  (define-syntax shift
    (syntax-rules ()
      [(_ ev body)
       (ev body)]))
  
  ;; REGIONS
  
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
  
  (define length_533 (lambda (str)
    (string-length str)))
  
  (define repeat_537 (lambda (str n)
    (letrec ([repeat (lambda (n acc) (if (<= n 0) acc (repeat (- n 1) (string-append acc str))))]) (repeat n (list->string '())))))
  
  (define substring_540 (lambda (str from)
    (substring str from (string-length str))))
  
  (define unsafeToInt_544 (lambda (str)
    (string->number str)))
  
  (define cons_555 (lambda (el rest)
    (cons el rest)))
  
  (define nil_557 (lambda ()
    (list)))
  
  (define isEmpty_560 (lambda (l)
    (null? l)))
  
  (define head_563 (lambda (l)
    (car l)))
  
  (define tail_566 (lambda (l)
    (cdr l)))
  
  (define nativeArgs_597 (lambda ()
    (cdr (command-line))))
  
  (define locally_3 (lambda (ev917_917 ev918_918 f_1)
    (lambda (k1059)
      ((f_1 ev918_918) k1059))))
  
  (define PI_157 (_pi_62))
  
  (define raise_143 (lambda (ev919_919 ev920_920 msg_142 Exception$capability_921)
    (lambda (k1060)
      (((raise_206 Exception$capability_921) ev920_920  (RuntimeError_207)  msg_142) k1060))))
  
  (define panicOn_146 (lambda (ev923_923 ev924_924 prog_145)
    (lambda (k1061)
      (let ([Exception_1391062 (Exception_139 (lambda (ev925_925 exception_209 msg_210)
                                                (lambda (k1063)
                                                  ((ev925_925 (lambda (k1064)
                                                                (let ([resume_211 (lambda (ev1066 a1065)
                                                                (ev1066 (k1064 a1065)))])
                                                                  (lambda (k1067)
                                                                    (let ()
                                                                      (define tmp905_1068 (panic_137 msg_210))
                                                                      (k1067 tmp905_1068)))))) k1063))))])
        ((((lambda (ev926_926 Exception$capability_927)
          (lambda (k1069)
            ((prog_145 (nested ev926_926  ev924_924)  here  Exception$capability_927) k1069))) lift
                                                                                                Exception_1391062) (lambda (a1070)
                                                                                                                     (lambda (k21071)
                                                                                                                       (k21071 a1070)))) k1061)))))
  
  (define report_149 (lambda (ev928_928 ev929_929 prog_148)
    (lambda (k1072)
      (let ([Exception_1391073 (Exception_139 (lambda (ev930_930 exception_213 msg_214)
                                                (lambda (k1074)
                                                  ((ev930_930 (lambda (k1075)
                                                                (let ([resume_215 (lambda (ev1077 a1076)
                                                                (ev1077 (k1075 a1076)))])
                                                                  (lambda (k1078)
                                                                    (let ()
                                                                      (define tmp910_1079 (println_12 msg_214))
                                                                      (k1078 tmp910_1079)))))) k1074))))])
        ((((lambda (ev931_931 Exception$capability_932)
          (lambda (k1080)
            ((prog_148 (nested ev931_931  ev929_929)  here  Exception$capability_932) k1080))) lift
                                                                                                Exception_1391073) (lambda (a1081)
                                                                                                                     (lambda (k21082)
                                                                                                                       (k21082 a1081)))) k1072)))))
  
  (define ignoring_152 (lambda (ev933_933 ev934_934 prog_151)
    (lambda (k1083)
      (let ([Exception_1391084 (Exception_139 (lambda (ev935_935 exception_217 msg_218)
                                                (lambda (k1085)
                                                  ((ev935_935 (lambda (k1086)
                                                                (let ([resume_219 (lambda (ev1088 a1087)
                                                                (ev1088 (k1086 a1087)))])
                                                                  (lambda (k1089)
                                                                    (k1089 #f))))) k1085))))])
        ((((lambda (ev936_936 Exception$capability_937)
          (lambda (k1090)
            ((prog_151 (nested ev936_936  ev934_934)  here  Exception$capability_937) k1090))) lift
                                                                                                Exception_1391084) (lambda (a1091)
                                                                                                                     (lambda (k21092)
                                                                                                                       (k21092 a1091)))) k1083)))))
  
  (define isDefined_277 (lambda (ev938_938 self_276)
    (lambda (k1093)
      (define tmp859_1094 self_276)
      
      (define tmp860_939 (lambda (ev941_941)
        (lambda (k1095)
          (k1095 #f))))
      
      (define tmp861_940 (lambda (ev942_942 v_305)
        (lambda (k1096)
          (k1096 #t))))
      (cond 
        [(None_301? tmp859_1094) ((match-None_301 tmp859_1094
          (lambda ()
           (lambda (k1097)
             ((tmp860_939 here) k1097)))) k1093)]
        [(Some_302? tmp859_1094) ((match-Some_302 tmp859_1094
          (lambda (tmp862_1099)
           (lambda (k1098)
             ((tmp861_940 here  tmp862_1099) k1098)))) k1093)]))))
  
  (define isEmpty_280 (lambda (ev943_943 self_279)
    (lambda (k1100)
      (define tmp865_1101 ((isEmpty_280 ev943_943  self_279) (lambda (a1102) a1102)))
      (k1100 (not_100 tmp865_1101)))))
  
  (define orElse_284 (lambda (ev944_944 ev945_945 self_282 that_283)
    (lambda (k1103)
      (define tmp866_1104 self_282)
      
      (define tmp869_946 (lambda (ev948_948)
        (lambda (k1105)
          ((that_283 (nested ev948_948  ev945_945)) k1105))))
      
      (define tmp870_947 (lambda (ev949_949 v_306)
        (lambda (k1106)
          (k1106 (Some_302 v_306)))))
      (cond 
        [(None_301? tmp866_1104) ((match-None_301 tmp866_1104
          (lambda ()
           (lambda (k1107)
             ((tmp869_946 here) k1107)))) k1103)]
        [(Some_302? tmp866_1104) ((match-Some_302 tmp866_1104
          (lambda (tmp871_1109)
           (lambda (k1108)
             ((tmp870_947 here  tmp871_1109) k1108)))) k1103)]))))
  
  (define getOrElse_288 (lambda (ev950_950 ev951_951 self_286 that_287)
    (lambda (k1110)
      (define tmp874_1111 self_286)
      
      (define tmp877_952 (lambda (ev954_954)
        (lambda (k1112)
          ((that_287 (nested ev954_954  ev951_951)) k1112))))
      
      (define tmp878_953 (lambda (ev955_955 v_307)
        (lambda (k1113)
          (k1113 v_307))))
      (cond 
        [(None_301? tmp874_1111) ((match-None_301 tmp874_1111
          (lambda ()
           (lambda (k1114)
             ((tmp877_952 here) k1114)))) k1110)]
        [(Some_302? tmp874_1111) ((match-Some_302 tmp874_1111
          (lambda (tmp879_1116)
           (lambda (k1115)
             ((tmp878_953 here  tmp879_1116) k1115)))) k1110)]))))
  
  (define map_293 (lambda (ev956_956 ev957_957 self_291 f_292)
    (lambda (k1117)
      (define tmp882_1118 self_291)
      
      (define tmp883_958 (lambda (ev960_960)
        (lambda (k1119)
          (k1119 (None_301)))))
      
      (define tmp885_959 (lambda (ev961_961 v_308)
        (lambda (k1120)
          ((f_292 (nested ev961_961  ev957_957)  v_308) (lambda (a1121)
                                                          (let ([tmp884_1122 a1121])
                                                            (k1120 (Some_302 tmp884_1122))))))))
      (cond 
        [(None_301? tmp882_1118) ((match-None_301 tmp882_1118
          (lambda ()
           (lambda (k1123)
             ((tmp883_958 here) k1123)))) k1117)]
        [(Some_302? tmp882_1118) ((match-Some_302 tmp882_1118
          (lambda (tmp886_1125)
           (lambda (k1124)
             ((tmp885_959 here  tmp886_1125) k1124)))) k1117)]))))
  
  (define foreach_297 (lambda (ev962_962 ev963_963 self_295 f_296)
    (lambda (k1126)
      (define tmp889_1127 self_295)
      
      (define tmp890_964 (lambda (ev966_966)
        (lambda (k1128)
          (k1128 #f))))
      
      (define tmp893_965 (lambda (ev967_967 v_309)
        (lambda (k1129)
          ((f_296 (nested ev967_967  ev963_963)  v_309) k1129))))
      (cond 
        [(None_301? tmp889_1127) ((match-None_301 tmp889_1127
          (lambda ()
           (lambda (k1130)
             ((tmp890_964 here) k1130)))) k1126)]
        [(Some_302? tmp889_1127) ((match-Some_302 tmp889_1127
          (lambda (tmp894_1132)
           (lambda (k1131)
             ((tmp893_965 here  tmp894_1132) k1131)))) k1126)]))))
  
  (define undefinedToOption_300 (lambda (ev968_968 value_299)
    (lambda (k1133)
      (if (isUndefined_109 value_299)
        (k1133 (None_301))
        (k1133 (Some_302 value_299))))))
  
  (define map_359 (lambda (ev969_969 ev970_970 l_357 f_358)
    (lambda (k1134)
      (define tmp731_1135 l_357)
      
      (define tmp732_971 (lambda (ev973_973)
        (lambda (k1136)
          (k1136 (Nil_398)))))
      
      (define tmp737_972 (lambda (ev974_974 a_404 rest_405)
        (lambda (k1137)
          ((f_358 (nested ev974_974  ev970_970)  a_404) (lambda (a1138)
                                                          (let ([tmp733_1139 a1138])
                                                            ((map_359 (nested ev974_974  ev969_969)
                                                                       here
                                                                       rest_405
                                                                       (lambda (ev975_975 a_406)
                                                                        (lambda (k1140)
                                                                          ((f_358 (nested ev975_975
                                                                                   (nested ev974_974
                                                                                            ev970_970))
                                                                                   a_406) k1140)))) (lambda (a1141)
                                                                                                      (let ([tmp736_1142 a1141])
                                                                                                        (k1137 (Cons_399 tmp733_1139
                                                                                                                          tmp736_1142)))))))))))
      (cond 
        [(Nil_398? tmp731_1135) ((match-Nil_398 tmp731_1135
          (lambda ()
           (lambda (k1143)
             ((tmp732_971 here) k1143)))) k1134)]
        [(Cons_399? tmp731_1135) ((match-Cons_399 tmp731_1135
          (lambda (tmp738_741 tmp739_740)
           (lambda (k1144)
             ((tmp737_972 here  tmp738_741  tmp739_740) k1144)))) k1134)]))))
  
  (define foreach_363 (lambda (ev976_976 ev977_977 l_361 f_362)
    (lambda (k1145)
      (define tmp744_1146 l_361)
      
      (define tmp745_978 (lambda (ev980_980)
        (lambda (k1147)
          (k1147 #f))))
      
      (define tmp752_979 (lambda (ev981_981 a_407 rest_408)
        (lambda (k1148)
          ((f_362 (nested ev981_981  ev977_977)  a_407) (lambda (a1149)
                                                          (let ([__1150 a1149])
                                                            ((foreach_363 (nested ev981_981
                                                                           ev976_976)
                                                                           here
                                                                           rest_408
                                                                           (lambda (ev982_982 a_409)
                                                                            (lambda (k1151)
                                                                              ((f_362 (nested ev982_982
                                                                                       (nested ev981_981
                                                                                                ev977_977))
                                                                                       a_409) k1151)))) k1148)))))))
      (cond 
        [(Nil_398? tmp744_1146) ((match-Nil_398 tmp744_1146
          (lambda ()
           (lambda (k1152)
             ((tmp745_978 here) k1152)))) k1145)]
        [(Cons_399? tmp744_1146) ((match-Cons_399 tmp744_1146
          (lambda (tmp753_756 tmp754_755)
           (lambda (k1153)
             ((tmp752_979 here  tmp753_756  tmp754_755) k1153)))) k1145)]))))
  
  (define size_366 (lambda (ev983_983 l_365)
    (lambda (k1154)
      (define tmp759_1155 l_365)
      
      (define tmp760_984 (lambda (ev986_986)
        (lambda (k1156)
          (k1156 0))))
      
      (define tmp762_985 (lambda (ev987_987 rest_410)
        (lambda (k1157)
          (define tmp761_1158 ((size_366 (nested ev987_987  ev983_983)  rest_410) (lambda (a1159)
                                                                                    a1159)))
          (k1157 (infixAdd_19 1  tmp761_1158)))))
      (cond 
        [(Nil_398? tmp759_1155) ((match-Nil_398 tmp759_1155
          (lambda ()
           (lambda (k1160)
             ((tmp760_984 here) k1160)))) k1154)]
        [(Cons_399? tmp759_1155) ((match-Cons_399 tmp759_1155
          (lambda (tmp763_766 tmp764_765)
           (lambda (k1161)
             ((tmp762_985 here  tmp764_765) k1161)))) k1154)]))))
  
  (define reverse_369 (lambda (ev988_988 l_368)
    (lambda (k1162)
      (define reverseWith_413 (lambda (ev989_989 l_411 acc_412)
        (lambda (k1163)
          (define tmp769_1164 l_411)
          
          (define tmp770_990 (lambda (ev992_992)
            (lambda (k1165)
              (k1165 acc_412))))
          
          (define tmp773_991 (lambda (ev993_993 a_414 rest_415)
            (lambda (k1166)
              ((reverseWith_413 (nested ev993_993  ev989_989)  rest_415  (Cons_399 a_414  acc_412)) k1166))))
          (cond 
            [(Nil_398? tmp769_1164) ((match-Nil_398 tmp769_1164
              (lambda ()
               (lambda (k1167)
                 ((tmp770_990 here) k1167)))) k1163)]
            [(Cons_399? tmp769_1164) ((match-Cons_399 tmp769_1164
              (lambda (tmp774_777 tmp775_776)
               (lambda (k1168)
                 ((tmp773_991 here  tmp774_777  tmp775_776) k1168)))) k1163)]))))
      ((reverseWith_413 here  l_368  (Nil_398)) k1162))))
  
  (define reverseOnto_373 (lambda (ev994_994 l_371 other_372)
    (lambda (k1169)
      (define tmp782_1170 l_371)
      
      (define tmp783_995 (lambda (ev997_997)
        (lambda (k1171)
          (k1171 other_372))))
      
      (define tmp786_996 (lambda (ev998_998 a_416 rest_417)
        (lambda (k1172)
          ((reverseOnto_373 (nested ev998_998  ev994_994)  rest_417  (Cons_399 a_416  other_372)) k1172))))
      (cond 
        [(Nil_398? tmp782_1170) ((match-Nil_398 tmp782_1170
          (lambda ()
           (lambda (k1173)
             ((tmp783_995 here) k1173)))) k1169)]
        [(Cons_399? tmp782_1170) ((match-Cons_399 tmp782_1170
          (lambda (tmp787_790 tmp788_789)
           (lambda (k1174)
             ((tmp786_996 here  tmp787_790  tmp788_789) k1174)))) k1169)]))))
  
  (define append_377 (lambda (ev999_999 l_375 other_376)
    (lambda (k1175)
      (define tmp793_1176 ((reverse_369 ev999_999  l_375) (lambda (a1177) a1177)))
      ((reverseOnto_373 ev999_999  tmp793_1176  other_376) k1175))))
  
  (define take_381 (lambda (ev1000_1000 l_379 n_380)
    (lambda (k1178)
      (if (infixEq_70 n_380  0)
        (k1178 (Nil_398))
        (let ()
          (define tmp796_1179 l_379)
          
          (define tmp797_1001 (lambda (ev1003_1003)
            (lambda (k1180)
              (k1180 (Nil_398)))))
          
          (define tmp799_1002 (lambda (ev1004_1004 a_418 rest_419)
            (lambda (k1181)
              (define tmp798_1182 ((take_381 (nested ev1004_1004  ev1000_1000)
                                              rest_419
                                              (infixSub_28 n_380  1)) (lambda (a1183) a1183)))
              (k1181 (Cons_399 a_418  tmp798_1182)))))
          (cond 
            [(Nil_398? tmp796_1179) ((match-Nil_398 tmp796_1179
              (lambda ()
               (lambda (k1184)
                 ((tmp797_1001 here) k1184)))) k1178)]
            [(Cons_399? tmp796_1179) ((match-Cons_399 tmp796_1179
              (lambda (tmp800_803 tmp801_802)
               (lambda (k1185)
                 ((tmp799_1002 here  tmp800_803  tmp801_802) k1185)))) k1178)]))))))
  
  (define drop_385 (lambda (ev1005_1005 l_383 n_384)
    (lambda (k1186)
      (if (infixEq_70 n_384  0)
        (k1186 l_383)
        (let ()
          (define tmp808_1187 l_383)
          
          (define tmp809_1006 (lambda (ev1008_1008)
            (lambda (k1188)
              (k1188 (Nil_398)))))
          
          (define tmp812_1007 (lambda (ev1009_1009 a_420 rest_421)
            (lambda (k1189)
              ((drop_385 (nested ev1009_1009  ev1005_1005)  rest_421  (infixSub_28 n_384  1)) k1189))))
          (cond 
            [(Nil_398? tmp808_1187) ((match-Nil_398 tmp808_1187
              (lambda ()
               (lambda (k1190)
                 ((tmp809_1006 here) k1190)))) k1186)]
            [(Cons_399? tmp808_1187) ((match-Cons_399 tmp808_1187
              (lambda (tmp813_816 tmp814_815)
               (lambda (k1191)
                 ((tmp812_1007 here  tmp813_816  tmp814_815) k1191)))) k1186)]))))))
  
  (define isEmpty_388 (lambda (ev1010_1010 l_387)
    (lambda (k1192)
      (define tmp821_1193 l_387)
      
      (define tmp822_1011 (lambda (ev1013_1013)
        (lambda (k1194)
          (k1194 #t))))
      
      (define tmp823_1012 (lambda (ev1014_1014 a_422 rest_423)
        (lambda (k1195)
          (k1195 #f))))
      (cond 
        [(Nil_398? tmp821_1193) ((match-Nil_398 tmp821_1193
          (lambda ()
           (lambda (k1196)
             ((tmp822_1011 here) k1196)))) k1192)]
        [(Cons_399? tmp821_1193) ((match-Cons_399 tmp821_1193
          (lambda (tmp824_827 tmp825_826)
           (lambda (k1197)
             ((tmp823_1012 here  tmp824_827  tmp825_826) k1197)))) k1192)]))))
  
  (define head_391 (lambda (ev1015_1015 l_390)
    (lambda (k1198)
      (define tmp830_1199 l_390)
      
      (define tmp832_1016 (lambda (ev1018_1018)
        (lambda (k1200)
          (define tmp831_1201 (error_15 "Trying to get the head of an empty list"))
          (k1200 tmp831_1201))))
      
      (define tmp833_1017 (lambda (ev1019_1019 a_424 rest_425)
        (lambda (k1202)
          (k1202 a_424))))
      (cond 
        [(Nil_398? tmp830_1199) ((match-Nil_398 tmp830_1199
          (lambda ()
           (lambda (k1203)
             ((tmp832_1016 here) k1203)))) k1198)]
        [(Cons_399? tmp830_1199) ((match-Cons_399 tmp830_1199
          (lambda (tmp834_837 tmp835_836)
           (lambda (k1204)
             ((tmp833_1017 here  tmp834_837  tmp835_836) k1204)))) k1198)]))))
  
  (define tail_394 (lambda (ev1020_1020 l_393)
    (lambda (k1205)
      (define tmp840_1206 l_393)
      
      (define tmp842_1021 (lambda (ev1023_1023)
        (lambda (k1207)
          (define tmp841_1208 (error_15 "Trying to get the head of an empty list"))
          (k1207 tmp841_1208))))
      
      (define tmp843_1022 (lambda (ev1024_1024 a_426 rest_427)
        (lambda (k1209)
          (k1209 rest_427))))
      (cond 
        [(Nil_398? tmp840_1206) ((match-Nil_398 tmp840_1206
          (lambda ()
           (lambda (k1210)
             ((tmp842_1021 here) k1210)))) k1205)]
        [(Cons_399? tmp840_1206) ((match-Cons_399 tmp840_1206
          (lambda (tmp844_847 tmp845_846)
           (lambda (k1211)
             ((tmp843_1022 here  tmp844_847  tmp845_846) k1211)))) k1205)]))))
  
  (define headOption_397 (lambda (ev1025_1025 l_396)
    (lambda (k1212)
      (define tmp850_1213 l_396)
      
      (define tmp851_1026 (lambda (ev1028_1028)
        (lambda (k1214)
          (k1214 (None_301)))))
      
      (define tmp852_1027 (lambda (ev1029_1029 a_428 rest_429)
        (lambda (k1215)
          (k1215 (Some_302 a_428)))))
      (cond 
        [(Nil_398? tmp850_1213) ((match-Nil_398 tmp850_1213
          (lambda ()
           (lambda (k1216)
             ((tmp851_1026 here) k1216)))) k1212)]
        [(Cons_399? tmp850_1213) ((match-Cons_399 tmp850_1213
          (lambda (tmp853_856 tmp854_855)
           (lambda (k1217)
             ((tmp852_1027 here  tmp853_856  tmp854_855) k1217)))) k1212)]))))
  
  (define toInt_542 (lambda (ev1030_1030 str_541)
    (lambda (k1218)
      ((undefinedToOption_300 ev1030_1030  (unsafeToInt_544 str_541)) k1218))))
  
  (define toChez_569 (lambda (ev1031_1031 l_568)
    (lambda (k1219)
      (define tmp716_1220 l_568)
      
      (define tmp717_1032 (lambda (ev1034_1034)
        (lambda (k1221)
          (k1221 (nil_557)))))
      
      (define tmp719_1033 (lambda (ev1035_1035 a_573 rest_574)
        (lambda (k1222)
          (define tmp718_1223 ((toChez_569 (nested ev1035_1035  ev1031_1031)  rest_574) (lambda (a1224)
                                                                                          a1224)))
          (k1222 (cons_555 a_573  tmp718_1223)))))
      (cond 
        [(Nil_398? tmp716_1220) ((match-Nil_398 tmp716_1220
          (lambda ()
           (lambda (k1225)
             ((tmp717_1032 here) k1225)))) k1219)]
        [(Cons_399? tmp716_1220) ((match-Cons_399 tmp716_1220
          (lambda (tmp720_723 tmp721_722)
           (lambda (k1226)
             ((tmp719_1033 here  tmp720_723  tmp721_722) k1226)))) k1219)]))))
  
  (define fromChez_572 (lambda (ev1036_1036 l_571)
    (lambda (k1227)
      (if (isEmpty_560 l_571)
        (k1227 (Nil_398))
        (let ()
          (define tmp726_1228 ((fromChez_572 ev1036_1036  (tail_566 l_571)) (lambda (a1229) a1229)))
          (k1227 (Cons_399 (head_563 l_571)  tmp726_1228)))))))
  
  (define commandLineArgs_596 (lambda (ev1037_1037)
    (lambda (k1230)
      (define tmp713_1231 (nativeArgs_597))
      ((fromChez_572 ev1037_1037  tmp713_1231) k1230))))
  
  (define count_605 (lambda (ev1038_1038 n_603)
    (lambda (k1232)
      (define abs_610 (lambda (ev1039_1039 n_609)
        (lambda (k1233)
          (if (infixLt_77 n_609  0)
            (k1233 (infixSub_28 0  n_609))
            (k1233 n_609)))))
      
      (define op_613 (lambda (ev1040_1040 x_611 y_612)
        (lambda (k1234)
          (define tmp669_1235 ((abs_610 ev1040_1040
                                         (infixAdd_19 (infixSub_28 x_611  (infixMul_22 503  y_612))
                                         37)) (lambda (a1236) a1236)))
          (k1234 (mod_31 tmp669_1235  1009)))))
      
      (define step_616 (lambda (ev1041_1041 l_614 s_615)
        (lambda (k1237)
          (if (infixEq_70 l_614  0)
            (k1237 s_615)
            (let ([Increment_6041238 (Increment_604 (lambda (ev1042_1042 j_617)
                                                      (lambda (k1239)
                                                        ((ev1042_1042 (lambda (k1240)
                                                                        (let ([resume_618 (lambda (ev1242 a1241)
                                                                        (ev1242 (k1240 a1241)))])
                                                                          (lambda (k1243)
                                                                            (let ()
                                                                              (define tmp678_1244 ((resume_618 here
                                                                                                                #f) (lambda (a1245)
                                                                                                                      a1245)))
                                                                              ((op_613 ev1041_1041
                                                                                        j_617
                                                                                        tmp678_1244) k1243)))))) k1239))))])
              ((((lambda (ev1043_1043 Increment$capability_1044)
                (lambda (k1246)
                  (define looper_620 (lambda (ev1045_1045 ev1046_1046 i_619 Increment$capability_1047)
                    (lambda (k1247)
                      (if (infixEq_70 i_619  0)
                        (k1247 s_615)
                        (((increment_608 Increment$capability_1047) ev1046_1046  i_619) (lambda (a1248)
                                                                                          (let ([__1249 a1248])
                                                                                            ((looper_620 ev1045_1045
                                                                                                          ev1046_1046
                                                                                                          (infixSub_28 i_619
                                                                                                                        1)
                                                                                                          Increment$capability_1047) k1247))))))))
                  ((looper_620 here  here  n_603  Increment$capability_1044) k1246))) lift
                                                                                       Increment_6041238) (lambda (a1250)
                                                                                                            (lambda (k21251)
                                                                                                              (k21251 a1250)))) (lambda (a1252)
                                                                                                                                  (let ([tmp681_1253 a1252])
                                                                                                                                    ((step_616 ev1041_1041
                                                                                                                                                (infixSub_28 l_614
                                                                                                                                                              1)
                                                                                                                                                tmp681_1253) k1237)))))))))
      ((step_616 here  1000  0) k1232))))
  
  (define main_606 (lambda (ev1048_1048)
    (lambda (k1254)
      (define tmp688_1255 ((commandLineArgs_596 ev1048_1048) (lambda (a1256) a1256)))
      
      (define tmp689_1257 tmp688_1255)
      
      (define tmp692_1049 (lambda (ev1052_1052)
        (lambda (k1258)
          (define tmp690_1259 ((count_605 (nested ev1052_1052  ev1048_1048)  1000) (lambda (a1260)
                                                                                     a1260)))
          
          (define tmp691_1261 (println_12 tmp690_1259))
          (k1258 tmp691_1261))))
      
      (define tmp703_1050 (lambda (ev1053_1053 x_621)
        (lambda (k1262)
          (define tmp693_1263 ((toInt_542 (nested ev1053_1053  ev1048_1048)  x_621) (lambda (a1264)
                                                                                      a1264)))
          
          (define tmp694_1265 tmp693_1263)
          
          (define tmp697_1054 (lambda (ev1056_1056 i_622)
            (lambda (k1266)
              (define tmp695_1267 ((count_605 (nested ev1056_1056  (nested ev1053_1053  ev1048_1048))
                                               i_622) (lambda (a1268) a1268)))
              
              (define tmp696_1269 (println_12 tmp695_1267))
              (k1266 tmp696_1269))))
          
          (define tmp699_1055 (lambda (ev1057_1057)
            (lambda (k1270)
              (define tmp698_1271 (println_12 (infixConcat_6 (infixConcat_6 "Unexpected non-integer(s) '"
                                               (show_9 x_621))
                                               "'")))
              (k1270 tmp698_1271))))
          (cond 
            [(Some_302? tmp694_1265) ((match-Some_302 tmp694_1265
              (lambda (tmp700_1273)
               (lambda (k1272)
                 ((tmp697_1054 here  tmp700_1273) k1272)))) k1262)]
            [else ((tmp699_1055 here) k1262)]))))
      
      (define tmp706_1051 (lambda (ev1058_1058 other_623)
        (lambda (k1274)
          (define tmp704_1275 ((size_366 (nested ev1058_1058  ev1048_1048)  other_623) (lambda (a1276)
                                                                                         a1276)))
          
          (define tmp705_1277 (println_12 (infixConcat_6 (infixConcat_6 "Expects zero or one argument, not '"
                                           (show_9 tmp704_1275))
                                           "'")))
          (k1274 tmp705_1277))))
      (cond 
        [(Nil_398? tmp689_1257) ((match-Nil_398 tmp689_1257
          (lambda ()
           (lambda (k1278)
             ((tmp692_1049 here) k1278)))) k1254)]
        [(Cons_399? tmp689_1257) ((match-Cons_399 tmp689_1257
          (lambda (tmp707_710 tmp708_709)
           (lambda (k1279)
             (cond 
               [(Nil_398? tmp708_709) ((match-Nil_398 tmp708_709
                 (lambda ()
                  (lambda (k1280)
                    ((tmp703_1050 here  tmp707_710) k1280)))) k1279)]
               [else ((tmp706_1051 here  tmp689_1257) k1279)])))) k1254)]
        [else ((tmp706_1051 here  tmp689_1257) k1254)]))))
  ((main_606 (lambda (a) a)) (lambda (a) a)))