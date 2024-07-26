
val source : string -> State.t
val repl   : in_channel -> State.t

val repl_node : in_channel Graph.Node.t

val exec : State.t -> Command.t -> State.t
