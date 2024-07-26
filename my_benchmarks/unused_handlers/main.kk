module main

import std/os/env

effect state
  fun get(): int
  fun set(i : int): ()

effect yield
  ctl yield(i: int): unit

fun countdown()
  val i = get()
  if i == 0
    then i
    else
      set(i - 1)
      countdown()

fun ignoreyield(body : () -> <yield|e> a) : e a
  with handler
    ctl yield(i) resume(())
  body()

fun handled(n : int, d : int) : <div, state> int
  if d == 0 
    then countdown()
    else
      fun body() : <yield, div, state> int
        handled(n, d - 1)
      ignoreyield(body)

fun run(n : int, d: int)
  var s := n
  with handler
    fun get() s
    fun set(i) s := i
  handled(n, d)

pub fun main()
  val n = get-args().head("").parse-int.default(5)
  val d = get-args().tail.head("").parse-int.default(10)
  val r = run(n, d)
  println(r)
