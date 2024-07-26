open TypingStructure

type t = implicit_effinst

val fresh : effsig -> implicit_effinst

val effsig : implicit_effinst -> effsig

val close : implicit_effinst -> effinst

module Set : Set.S with type elt = t
