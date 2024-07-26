
let n = try int_of_string Sys.argv.(1) with _ -> 5
let d = try int_of_string Sys.argv.(2) with _ -> 10
let _ = Printf.printf "%d\n" (OcamlHeader.run (Generated.run n d))
