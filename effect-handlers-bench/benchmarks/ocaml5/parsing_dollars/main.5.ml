open Effect
open Effect.Deep


type chr = int

type _ Effect.t += Read : unit -> chr t

type _ Effect.t += Emit : int -> unit t

exception Stop


let newline = 10
let is_newline c = c = 10
let dollar = 36
let is_dollar c = c = 36

let rec parse a =
  let c = perform (Read ()) in
  if (is_dollar c)
    then parse (a + 1)
    else if (is_newline c)
      then (perform (Emit a) ; parse 0)
      else raise Stop

let sum action =
  let s = ref  0 in
  try_with
    (fun () -> action () ; !s) ()
    { effc = fun (type a) (eff: a t) ->
       match eff with
       | (Emit e) -> Some(fun (k: (a, _) continuation) -> (s := !s + e ; continue k ()))
       | _ -> None
    }

let catch action =
  try
    action ()
  with
  | Stop -> ()

let feed n action =
  let i = ref 0 in
  let j = ref 0 in
  try_with
    action ()
    { effc = fun (type a) (eff: a t) ->
        match eff with
        | (Read ()) -> Some(fun (k: (a, _) continuation) ->
                if (!i > n)
                  then raise Stop
                  else if(!j = 0)
                    then (i := !i + 1 ; j := !i ; continue k newline)
                    else j := !j - 1 ; continue k dollar)
        | _ -> None
    }

let run n =
  sum (fun () -> catch (fun () -> feed n (fun () -> parse 0)))

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 10 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

