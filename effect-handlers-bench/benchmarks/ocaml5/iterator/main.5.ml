open Effect
open Effect.Deep

type _ Effect.t += Emit : int -> unit t

let rec range l u =
  if (l > u)
    then ()
    else (
      perform (Emit l);
      range (l + 1) u)

let run n =
  let s = ref 0 in
  try_with
    (fun () -> 
      range 0 n;
      !s)
    ()
  { effc = fun (type a) (eff: a t) ->
    match eff with
    | (Emit e) -> Some(fun (k: (a,_) continuation) -> (s := !s + e ; continue k ()))
    | _ -> None
  }

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

