module effs1rep

effect amb {
  ctl flip() : bool
}
fun op(a: bool, b: bool): console bool {
  (a||b) && not(a&&b)
}
fun xor() : <console,amb> bool {
  val p = flip()
  val q = flip()
  //print(p)
  //print(q)
  //print((p,q))
  op(p,q)
}

val amb = handler {
  return(x){ [x] }
  ctl flip(){ 
   val xs = resume(False)
   val ys = resume(True) 
   xs ++ ys
  }
}

fun repeated(i : int, acc : list<bool>) : <div,console> list<bool> {
  if (i == 0) then acc else repeated(i - 1, amb(xor))
}

fun main() {
  repeated(2000, []).show.println
}
