module effs1

type mybool
  MyTrue(x : string)
  MyFals( x: string)

effect amb {
  ctl flip() : mybool
}

fun xor() : amb mybool {
  val p = flip()
  val q = flip()
  q
}

fun mybool/show( x: mybool ) : string
  match x
    MyTrue(_) -> "t"
    MyFals(_) -> "f"

val amb = handler {
  return(x){ x.mybool/show }
  ctl flip(){ resume(MyFals("")) ++ resume(MyTrue("")) }
}

fun main() {
  amb(xor).println
}
