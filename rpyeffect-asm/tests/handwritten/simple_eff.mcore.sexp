(define $n:int 42)

(handle Deep $eff (($op ($resume:(fun Effectful (int) int) $a:int)
    ($resume:top $a:int)))
  (op $eff ($op int $n:int) ($n1:int) $n1:int))
