open Effect
open Effect.Deep

type _ Effect.t += Operator : int -> unit t

let rec loop i s =
  if i = 0
    then s
    else
      let _ = perform (Operator i) in
      loop (i - 1) s

let run n s =
  match_with (loop n) s 
  { retc = (fun x -> x);
    exnc = (fun e -> raise e);
    effc = fun (type a) (eff: a t) ->
      match eff with
      | (Operator x) -> Some(fun (k: (a,_) continuation) ->
          let y = continue k () in
          abs (x - (503 * y) + 37) mod 1009)
      | _ -> None
  }

let rec repeat n =
  let rec step l s =
    if l = 0
      then s
      else step (l - 1) (run n s) in
  step 1000 0

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = repeat n in
  Printf.printf "%d\n" r

let _ = main ()

