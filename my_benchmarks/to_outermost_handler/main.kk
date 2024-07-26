module main

import std/os/env

effect state
  ctl get(): int
  ctl set(i : int): ()

effect yield
  ctl yield(i: int): unit

fun countdown()
  val i = get()
  if i == 0
    then i
    else
      set(i - 1)
      countdown()

fun pad(d : int, body : () -> <div|e> a) : <div|e> a
  if (d == 0) then body() else (
    shandler(-377, {
      mask<state>{ pad(d - 1, body) }
    })
  )

fun shandler(n: int, body : () -> <state|e> a) : e a
  var s := n
  with handler
    fun get() s
    fun set(i)
      s := i
  body()

fun run(n: int, d: int)
  shandler(n){ pad(d){ countdown() } }

pub fun main()
  val n = get-args().head("").parse-int.default(5)
  val d = get-args().tail.head("").parse-int.default(10)
  val r = run(n, d)
  println(r)
