open Effect
open Effect.Deep

type _ Effect.t += Prime : int -> bool t

let rec primes i n a =
  if (i >= n)
    then a
    else
      if perform (Prime i)
        then
          try_with
            (primes (i + 1) n) (a + i)
          { effc = fun (type a) (eff: a t) ->
            match eff with
            | (Prime e) -> Some(fun (k: (a,_) continuation) ->
              if (e mod i = 0)
                then continue k false
                else continue k (perform (Prime e)))
            | _ -> None
          }
        else
          primes (i + 1) n a

let run n =
  try_with (primes 2 n) 0
   { effc = fun (type a) (eff: a t) ->
      match eff with
      | (Prime e) -> Some(fun (k: (a,_) continuation) -> continue k true)
      | _ -> None
   }

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 10 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

