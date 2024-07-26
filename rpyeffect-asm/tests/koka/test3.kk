type mypair
  MCons{ fst : string; snd : string }
  MCons2{ fst2 : int; snd2: int }

extern doprint(s : string) : ()
  vm "println(String): Unit"

extern doprinti(s: int) : ()
  vm "println(Int): Unit"

val lst = MCons2(4, 2)

fun printall(l: mypair)
  match l
    MCons(a, d) -> {doprint(a); doprint(d)}
    MCons2(a, d) -> {doprinti(a); doprinti(d)}

pub fun main()
  printall(lst)
