open TypingStructure

module Order = struct
  type t = implicit_effinst

  let compare i1 i2 = Utils.UID.compare i1.iei_uid i2.iei_uid
end
include Order

let fresh s =
  { iei_uid = Utils.UID.fresh ()
  ; iei_sig = s
  }

let effsig i = i.iei_sig

let close i =
  assert (World.get_effinst i = None);
  let a = EffInst.fresh () in
  World.set_effinst i (IEInstance a);
  a

module Set = Set.Make(Order)
