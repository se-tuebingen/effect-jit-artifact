module main

import std/os/env

effect exc
  ctl exc(): unit

noinline fun inner(): exc unit
  exc()

fun outer()
  with handler
    return(x)    x
    ctl exc()
      ()
  inner()

fun run(n: int)
  if n >= 0 
    then 
      outer()
      run(n - 1)
    else 0

pub fun main()
  val n = get-args().head("").parse-int.default(5)
  val r = run(n)
  println(r)