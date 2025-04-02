let n = try int_of_string Sys.argv.(1) with _ -> 5

let _ = Printf.printf "%i\n" (Generated.run n)
