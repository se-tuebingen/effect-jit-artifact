
val m_position : Utils.Position.t Flow.meta_key

val well_typed        : Flow.tag
val direct_style_unit : Flow.tag
val complete_program  : Flow.tag

val unique_vars      : Flow.tag
val unique_type_vars : Flow.tag

val error_report : Flow.tag
val pretty       : Flow.tag

val box_pretty_error        : Flow.tag
val box_pretty_error_stdout : Flow.tag
val box_pretty_printer      : Flow.tag

val eval : Flow.tag

val box_node  : Box.t Flow.node
val unit_node : unit Flow.node
