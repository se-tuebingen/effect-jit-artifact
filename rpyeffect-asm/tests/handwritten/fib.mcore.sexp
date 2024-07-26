(define $fib:(fun Pure (int) int) (lambda ($n:int)
   (prim ($gte:int) ("infixGte(Int, Int): Boolean" $n:int 2)
   (if0 $gte:int 
     $n:int
     (prim ($n1:int) ("infixAdd(Int, Int): Int" $n:int -1)
       (prim ($n2:int) ("infixAdd(Int, Int): Int" $n:int -2)
         (let ((define $fn1:int ($fib:(fun Pure (int) int) $n1:int)) (define $fn2:int ($fib:(fun Pure (int) int) $n2:int)))
           (prim ($r:int) ("infixAdd(Int, Int): Int" $fn1:int $fn2:int)
             $r:int))))))))

(prim () ("println(Int): Unit" ($fib:(fun Pure (int) int) 10)) (unit))
