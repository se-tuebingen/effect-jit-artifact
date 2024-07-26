;; Converting from strings
(define $parseWithBase:(fun Pure (str int) ptr) (lambda ($s:str $base:int)
  (prim ($res:int $err:bool) ("read(String, Int): Int" $s:str $base:int)
    (switch $err:bool
      (true ;; OK
         (make $std/core/types/maybe $std/core/types/Just ($res:top)))
      (_ ;; couldnt parse
         (make $std/core/types/maybe $std/core/types/Nothing ()))))))
(define $xparseImpl:(fun Pure (str bool) ptr) (lambda ($s:str $hex:bool)
  (switch $hex:bool
    (false ;; parse
           ($parseWithBase:(fun Pure (str int) ptr) $s:str 0)
    )
    (_ ;; hexadecimal
       ($parseWithBase:(fun Pure (str int) ptr) $s:str 16)))))

(unit)