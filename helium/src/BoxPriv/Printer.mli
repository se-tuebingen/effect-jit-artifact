
type t

val create : out_channel -> t
val print       : t -> Core.t -> unit
val print_no_nl : t -> Core.t -> unit
