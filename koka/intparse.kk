import std/os/env

pub fun main()
  val n = get-args().head("").parse-int(False).default(5)
  println(n)