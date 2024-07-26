open Ocamlbuild_plugin
open Command

(* The order matters. We need shortes prefixes at the end *)
let rec nonempty_prefixes xs =
  match xs with
  | [] -> []
  | x :: xs ->
    List.fold_right (fun p ps -> (x :: p) :: ps) (nonempty_prefixes xs) [[x]]

let path_to_string path =
  List.fold_left
    (fun str dir -> str ^ "/" ^ dir)
    "src"
    path

let tag_of_path =
  List.fold_left
    (fun tag_name dir -> tag_name ^ "_" ^ dir)

let declare_dir path =
  let tag_name = tag_of_path "dir" path in
  flag ["ocaml";"compile";tag_name]
    (S (List.map
          (fun p -> S [ A "-I"; A (path_to_string p ^ "/") ])
          (nonempty_prefixes path)))

let declare_dep path =
  let tag_name = tag_of_path "dep" path in
  dep [tag_name] [path_to_string path ^ ".cmx"]

let _ = dispatch begin function
  | After_rules ->
    declare_dir ["Lang";"CoreCommon"];
    declare_dir ["Lang";"CorePriv"];
    declare_dir ["Lang";"ExplicitPriv"];
    declare_dir ["Lang";"UnifPriv"];
    declare_dep ["Lang";"Common"];
    declare_dep ["Lang";"CoreCommon"];
    declare_dep ["Lang";"Kind"];
    declare_dep ["Lang";"Node"];
    declare_dep ["Lang";"PrimCodes"];
    declare_dep ["Lang";"RichBaseType"]
  | _ -> ()
  end
