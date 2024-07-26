(define $n:int 42)

(handle Deep $eff (($a:int $resume:top)
    ($resume:top $a:int))
  (op $eff ($n:int) ($n1:int) $n1:int))
