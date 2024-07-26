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
      pad(){ countdown() }

fun pad( body : () -> <div|e> a) : <div|e> a
    shandler(-377, {
      mask<state>{ body() }
    })

fun shandler(n: int, body : () -> <state|e> a) : e a
  var s := n
  with handler
    fun get() s
    fun set(i)
      s := i
  body()

fun run(n: int)
  shandler(n){ countdown() }

pub fun main()
  val n = get-args().head("").parse-int.default(5)
  val r = run(n)
  println(r)
