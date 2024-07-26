open TypingStructure

type t = effinst_expr

let instance a = IEInstance a
let implicit i = IEImplicit i

let rec view ie =
  match ie with
  | IEInstance a -> ie
  | IEImplicit i ->
    begin match World.get_effinst i with
    | None    -> ie
    | Some ie ->
      let ie = view ie in
      World.set_effinst i ie;
      ie
    end

let equal ie1 ie2 =
  match view ie1, view ie2 with
  | IEInstance a1, IEInstance a2 -> EffInst.equal a1 a2
  | IEImplicit i1, IEImplicit i2 -> Utils.UID.equal i1.iei_uid i2.iei_uid
  | IEInstance _,  IEImplicit _  -> false
  | IEImplicit _,  IEInstance _  -> false
