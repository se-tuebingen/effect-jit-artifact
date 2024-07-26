(define $eff:ptr (fresh-label))
(define $other_eff:ptr (fresh-label))
(define $n:int 42)

(prim ($r:unit) ("println(Int): Unit" 
  (dhandle Deep $eff:ptr (($op ($resume:(fun Effectful (top) top) $a:int)
      1))
      13)) 
  $r:unit)
