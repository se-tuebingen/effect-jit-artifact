let id n = 0

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = id n in
  Printf.printf "%d\n" r

let _ = main ()
