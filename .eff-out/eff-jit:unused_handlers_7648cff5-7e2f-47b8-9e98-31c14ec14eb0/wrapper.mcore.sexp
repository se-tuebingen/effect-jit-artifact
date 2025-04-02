(letrec ((define $lib:ptr  (load-lib path"$0/main.rpyeffect"))
         (define $argc:int ("get_argc(): Int")))
  (switch $argc:int (2
      (letrec ((define $arg:str  ("get_arg(Int): String" 0))
               (define $n:int    ("read(String): Int" $arg:str))
               (define $argd:str ("get_arg(Int): String" 1))
               (define $d:int    ("read(String): Int" $argd:str))
               (define $res:int  ((call-lib $lib:ptr "run" ptr $n:int) $d:int)))
          ("println(Int): Unit" $res:int)))
    (1
      (letrec ((define $arg:str  ("get_arg(Int): String" 0))
               (define $n:int    ("read(String): Int" $arg:str))
               (define $res:int  ((call-lib $lib:ptr "run" ptr $n:int) 10)))
          ("println(Int): Unit" $res:int)))
    (0
      (letrec ((define $n:int    5)
               (define $res:int  ((call-lib $lib:ptr "run" ptr $n:int) 10)))
          ("println(Int): Unit" $res:int)))
    (_ ("panic(String): Bottom" "Expects exactly one argument."))))