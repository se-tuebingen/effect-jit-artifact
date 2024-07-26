
type t =
  { req_by   : string list
  ; level    : Lang.Common.source_level
  ; cur_dir  : string
  ; cur_file : string
  ; src_dirs : string list
  ; lib_dirs : string list
  }

type 'a result =
| NotFound
| DependencyLoop of string list
| Found          of string * Lang.Common.source_level * 'a 
| FlowError      of Flow.state

let key = Flow.MetaKey.create "File Finder"

let promote_to_lib sl =
  match sl with
  | Lang.Common.SL_User -> Lang.Common.SL_Lib
  | _                   -> sl

let level ff = ff.level

let as_prelude ff = { ff with level = SL_Prelude }

let path_concat dir name =
  if dir = Filename.current_dir_name then name
  else Filename.concat dir name

let canonical_fname fname =
  if Filename.is_relative fname then
    path_concat (Filename.dirname fname) (Filename.basename fname)
  else fname

let default sl =
  { req_by   = [ canonical_fname (Settings.current_file_path ()) ]
  ; level    = sl
  ; cur_dir  = Filename.dirname (Settings.current_file_path ())
  ; cur_file = Settings.current_file_path ()
  ; src_dirs = if sl = SL_User then Settings.source_dirs () else []
  ; lib_dirs = Settings.lib_dirs ()
  }

let find_loop path req_by =
  let rec aux acc req_by =
    match req_by with
    | [] -> None
    | path' :: req_by ->
      if path = path' then Some (List.rev (path' :: acc))
      else aux (path' :: acc) req_by
  in aux [] req_by

let rec find_in_dir dir name ext =
  match ext with
  | [] -> None
  | e0 :: ext ->
    let path = path_concat dir (name ^ ".he") in
    if Sys.file_exists path && not (Sys.is_directory path) then
      Some path
    else find_in_dir dir name ext

let rec find_in_dirs dirs name ext =
  match dirs with
  | [] -> None
  | dir :: dirs ->
    begin match find_in_dir dir name ext with
    | Some path -> Some path
    | None -> find_in_dirs dirs name ext
    end

let find_extension ff name ext cont =
  match find_in_dir ff.cur_dir name ext with
  | Some path -> cont path ff.level
  | None ->
    begin match find_in_dirs ff.src_dirs name ext with
    | Some path -> cont path ff.level
    | None ->
      begin match find_in_dirs ff.lib_dirs name ext with
      | Some path -> cont path (promote_to_lib ff.level)
      | None -> NotFound
      end
    end

let tr_file ff node path sl =
  match find_loop path ff.req_by with
  | Some loop -> DependencyLoop loop
  | None ->
    let ff =
      { req_by   = path :: ff.req_by
      ; level    = sl
      ; cur_dir  = Filename.dirname path
      ; cur_file = path
      ; src_dirs = if sl = SL_User then ff.src_dirs else []
      ; lib_dirs = ff.lib_dirs
      } in
    let state = Flow.source path
      |> Flow.State.set_option key ff in
    begin try Found(path, sl, Flow.run_to_node state node) with
    | Flow.Error st -> FlowError st
    end

let find_corresponding_unif_sig ff =
  let path = ff.cur_file in
  let path = Filename.chop_suffix path (Filename.extension path) ^ ".she" in
  if Sys.file_exists path && not (Sys.is_directory path) then
    tr_file ff Lang.Unif.intf_flow_node path ff.level
  else
    NotFound

let find_unif_sig ff name =
  find_extension ff name [ ".he" ] (tr_file ff Lang.Unif.intf_flow_node)

let find_core_impl (im : Lang.Core.import) =
  match find_in_dir (Filename.dirname im.im_path) im.im_name [ ".he" ] with
  | Some path ->
    let state = Flow.source path
      |> Flow.State.set_option key 
        { (default im.im_level) with
          cur_file = im.im_path
        ; cur_dir  = Filename.dirname im.im_path
        } in
    Some(Flow.run_to_node state Lang.Core.flow_node)
  | None -> None
