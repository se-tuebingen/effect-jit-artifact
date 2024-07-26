effect myraise
  ctl myraise( msg : string ) : a

extern doprint(s : string) : ()
  vm "println(String): Unit"

fun foo()
  myraise("Not implemented")

pub fun main()
  with handler
    ctl myraise(msg) doprint(msg)
  foo()