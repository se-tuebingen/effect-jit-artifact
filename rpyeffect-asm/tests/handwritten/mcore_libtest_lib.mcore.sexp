
(define $foo:(fun Pure (int) int) (lambda ($x:int)
  ("infixAdd(Int, Int): Int" $x:int 1))
  :export-as ("foo"))

("!undefined:is a library")
