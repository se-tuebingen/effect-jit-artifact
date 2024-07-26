open TypingStructure

type t = subst

let empty =
  { sub_type = TypeSubst.empty
  ; sub_inst = EffInst.Map.empty
  }

let scope sub =
  { type_scope = TypeSubst.carrier sub.sub_type
  ; inst_scope = EffInst.Map.map (fun _ -> ()) sub.sub_inst
  }

let of_scope scope =
  { sub_type =
    TypeSubst.dmap { dmap_f = fun x _ -> Type.var x } scope.type_scope
  ; sub_inst = EffInst.Map.mapi (fun a () -> IEInstance a) scope.inst_scope
  }

let domain sub =
  { sub_type = TypeSubst.map { map_f = fun x _ -> Type.var x } sub.sub_type
  ; sub_inst = EffInst.Map.mapi (fun a _ -> IEInstance a) sub.sub_inst
  }

let rename_tvar x y =
  { sub_type = TypeSubst.singleton x (Type.var y)
  ; sub_inst = EffInst.Map.empty
  }

let rename_effinst a b =
  { sub_type = TypeSubst.empty
  ; sub_inst = EffInst.Map.singleton a (IEInstance b)
  }

let add_tvar sub x =
  { sub with
    sub_type = TypeSubst.add x (Type.var x) sub.sub_type
  }

let add_effinst sub a =
  { sub with
    sub_inst = EffInst.Map.add a (IEInstance a) sub.sub_inst
  }

let extend_t sub x tp =
  { sub with
    sub_type = TypeSubst.add x tp sub.sub_type
  }

let subst_bvars = Type.subst_bvars

let subst_binder bsubst subst_x (sub : subst) (b, x) =
  let (b, sub) = bsubst sub b in
  (b, subst_x sub x)

let subst_pair subst_a subst_b (sub : subst) (a, b) =
  (subst_a sub a, subst_b sub b)

let subst_list subst_x (sub : subst) xs =
  List.map (subst_x sub) xs

type 's fold_f = { fold_f : 'k. 's -> 'k tvar -> 'k typ -> 's }

let fold_types f s sub =
  TypeSubst.fold { fold_f = fun x tp s -> f.fold_f s x tp } sub.sub_type s

let fold_insts f s sub =
  EffInst.Map.fold (fun a b s -> f s a b) sub.sub_inst s
