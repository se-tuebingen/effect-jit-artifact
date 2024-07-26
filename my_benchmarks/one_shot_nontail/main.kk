module main

import std/os/env

effect func
  ctl func(): unit

noinline fun inner(): func unit
  func()

noinline fun after()
  ()

fun loop(n: int)
  if n > 0
    then
      inner()
      loop(n - 1)
    else
      ()

noinline fun outer(n: int)
  with handler
    return(x)    x
    ctl func()
      resume(())
      after()
  loop(n)

fun run(n: int)
  outer(n); 0

pub fun main()
  val n = get-args().head("").parse-int.default(5)
  val r = run(n)
  println(r)