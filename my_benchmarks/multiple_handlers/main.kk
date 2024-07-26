module main

import std/os/env

effect fun emit(e : int) : ()

fun generator(n : int)
  fun go(i : int)
    if i > n
      then ()
      else
        emit(i)
        go(i + 1)
  go(0)

fun summing( action ) {
  var res : int := 0
  with {
    return(_) { res }
    fun emit(i) { res := (res + i) % 1009 }
  }
  action()
}

fun counting( action ) {
  var res : int := 0
  with {
    return(_) { res }
    fun emit(i) { res := (res + 1) % 1009 }
  }
  action()
}

fun sq_summing( action ) {
  var res : int := 0
  with {
    return(_) { res }
    fun emit(i) { res := (res + i * i) % 1009 }
  }
  action()
}

fun run( n : int ) {
  val sqs = sq_summing{ generator(n) }
  val s = summing{ generator(n) }
  val c = counting{ generator(n) }
  return sqs * 1009 + s * 103 + c
}

pub fun main()
  val n = get-args().head("").parse-int.default(5)
  val r = run(n)
  println(r)
