open Lang.Unif

let tr_program p =
  { if_import = List.map snd p.sf_import
  ; if_sig    =
    begin match p.sf_body with
    | UB_Direct body ->
      US_Direct
      { types    = body.types
      ; body_sig = body.body_sig
      }
    | UB_CPS body ->
      US_CPS
      { types    = body.types
      ; handle   = body.handle
      ; body_sig = body.body_sig
      }
    end
  }

let flow_tag =
  Flow.register_transform
    ~source: Lang.Unif.flow_node
    ~target: Lang.Unif.intf_flow_node
    ~name: "Unif --> Unif interface"
    ~preserves_tags: [ CommonTags.well_typed ]
    (fun p _ -> Flow.return (tr_program p))
