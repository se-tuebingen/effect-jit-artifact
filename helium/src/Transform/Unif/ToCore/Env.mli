type t

val empty : Flow.metadata -> t

val add_tvar   : t -> 'k Lang.Unif.tvar -> t * 'k Lang.Core.tvar
val add_tvars  : t -> Lang.Unif.TVar.ex list -> t * Lang.Core.TVar.ex list
val add_tvars' : t -> Lang.Unif.TVar.ex list -> Lang.Core.TVar.ex list -> t

val add_effinst : t -> Lang.Unif.effinst -> t * Lang.Core.effinst

val add_var : t -> Lang.Unif.var -> Lang.Core.var -> t

val lookup_tvar : t -> 'k Lang.Unif.tvar -> 'k Lang.Core.tvar
val lookup_inst : t -> Lang.Unif.effinst -> Lang.Core.effinst
val lookup_var  : t -> Lang.Unif.var -> Lang.Core.var

val metadata    : t -> Flow.metadata
val update_meta : t -> Flow.metadata -> t
