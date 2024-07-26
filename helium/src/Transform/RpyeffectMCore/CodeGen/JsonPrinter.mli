type t
val str : string -> t
val int : int -> t
val list : t -> t
val obj : t -> t
val (=) : string -> t -> t
val nop : t
val (&) : t -> t -> t
val run : t -> string
val seq: t list -> t
val listof : ('a -> t) -> 'a list -> t
val singleline : t -> t