module main

import std/os/env

fun run( n : int ) {
  return 0
}

pub fun main()
  val n = get-args().head("").parse-int.default(5)
  val r = run(n)
  println(r)
