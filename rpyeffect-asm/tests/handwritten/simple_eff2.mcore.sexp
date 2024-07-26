(define $n:int 42)

(prim ($r:unit) ("println(Int): Unit" 
  (handle Deep $eff (($op ($resume:(fun Effectful (int) int) $a:int)
      ($resume:top $a:int)))
   (handle Deep $other_eff (($other_op ($resume:(fun Effectful (int) int)) ($resume:top 12)))
    (op $eff ($op int $n:int) ($n1:int) $n1:int)))) 
  $r:unit)
