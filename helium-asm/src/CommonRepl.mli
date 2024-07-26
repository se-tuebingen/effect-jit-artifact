
type rollback = unit -> unit

type 'a result =
  { data     : 'a
  ; meta     : Flow.metadata
  ; rollback : rollback
  }

exception Error of Flow.state * rollback

(** run ask cont prompt prints prompt, then run ask, checking for {!Error}.
  if no error occur, continue using cont. *)
val run : (unit -> 'a) -> ('a -> 'b) -> Box.t -> 'b

val print_value : Box.t -> Box.t -> unit
