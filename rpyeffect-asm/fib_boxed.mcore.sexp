(define $fib:(fun Pure (int) int) (lambda ($n:top)
   (prim ($gte:int) ("infixGte(Int, Int): Boolean" $n:int 2)
   (if0 $gte:int 
     $n:top
     (prim ($n1:int) ("infixAdd(Int, Int): Int" $n:int -1)
       (prim ($n2:int) ("infixAdd(Int, Int): Int" $n:int -2)
         (let ((define $fn1:top ($fib:(fun Pure (int) int) $n1:top)) (define $fn2:top ($fib:(fun Pure (int) int) $n2:top)))
           (prim ($r:int) ("infixAdd(Int, Int): Int" $fn1:int $fn2:int)
             $r:top))))))))

(let ((define $input:int 42)) ($fib:(fun Pure (int) int) $input:top))
