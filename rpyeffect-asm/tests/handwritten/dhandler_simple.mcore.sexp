(define $eff:ptr (fresh-label))
(define $other_eff:ptr (fresh-label))
(define $n:int 42)

(prim ($r:unit) ("println(Int): Unit" 
  (dhandle Deep $eff:ptr (($op ($resume:(fun Effectful (int) int) $a:int)
      ($resume:top $a:int)))
    (dhandle Deep $other_eff:ptr (($other_op ($resume2:(fun Effectful (int) int)) ($resume2:top 12)))
      (dop $eff:ptr ($op int $n:int) ($n1:int) $n1:int)))) 
  $r:unit)
