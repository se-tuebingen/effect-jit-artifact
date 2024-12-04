open Effect
open Effect.Deep

type _ Effect.t += Get: unit -> int t
type _ Effect.t += Set: int -> unit t

let rec countdown () =
  let i = perform (Get ()) in
  if (i = 0)
    then i
    else (
      perform (Set (i - 1));
      countdown ())

let run n =
  let s = ref (n : int) in
  try_with countdown ()
  { effc = fun (type a) (eff: a t) ->
    match eff with
    | Get () -> Some(fun (k: (a,_) continuation) -> continue k (!s))
    | Set i -> Some(fun (k: (a,_) continuation) -> s := i; continue k ())
    | _ -> None
  }

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()
