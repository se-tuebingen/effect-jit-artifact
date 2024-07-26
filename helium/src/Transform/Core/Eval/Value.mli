
type efftag

type value =
| VConst     of Lang.RichBaseType.lit
| VFn        of (value -> cont -> ans)
| VInstFun   of (efftag -> cont -> ans)
| VTypeFun   of (cont -> ans)
| VTuple     of value list
| VCtor      of value * int * value list
| VRecord    of value * value list
| VDataDef   of string list
| VRecordDef of string list
| VEffsigDef of string list
| VSeal      of Utils.Seal.seal

and cont = value -> ans

and ans =
| RValue     of value
| RPushFrame of cont * frame * ans
| RDoOp      of efftag * value * int * value list * cont * (frame * cont) list

and frame =
  { f_tag     : efftag
  ; f_handler : handler list
  ; f_return  : value -> cont -> ans
  }

and handler = value list -> value -> cont -> ans

val v_class : value Predef.Value.value_class

val fresh_efftag : unit -> efftag
val efftag_equal : efftag -> efftag -> bool

val pretty : value -> Box.t
