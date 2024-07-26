
let m_position = Flow.MetaKey.create "position"

let well_typed = Flow.Tag.create
  "well_typed"

let direct_style_unit = Flow.Tag.create
  "direct_style_unit"

let complete_program = Flow.Tag.create
  ~cmd_line_flag:  "-link"
  ~cmd_line_descr: " Link all units into a single program"
  "complete_program"

let unique_vars = Flow.Tag.create
  "unique_vars"

let unique_type_vars = Flow.Tag.create
  "unique_type_vars"

let eval = Flow.Tag.create
  ~cmd_line_flag:  "-eval"
  ~cmd_line_descr: " Run a program"
  "eval"

let error_report = Flow.Tag.create "error_report"
let pretty = Flow.Tag.create "pretty"

let box_node  = Flow.Node.create "Box"
let unit_node = Flow.Node.create "Unit"

let box_pretty_error =
  Flow.register_transform
    ~source: box_node
    ~target: unit_node
    ~name:   "stderr printer"
    ~preserves_tags: [ error_report ]
    (fun box _ ->
      Box.print_stderr box;
      Flow.return ())

let box_pretty_error_stdout =
  Flow.register_transform
    ~source: box_node
    ~target: unit_node
    ~name:   "stdout error printer"
    ~preserves_tags: [ error_report ]
    (fun box _ ->
      Box.print_stdout box;
      Flow.return ())

let box_pretty_printer =
  Flow.register_transform
    ~cmd_line_flag:  "-pretty"
    ~cmd_line_descr: " Pretty-print selected intermediate representation"
    ~source: box_node
    ~target: unit_node
    ~name:   "pretty-printer"
    ~requires_tags: [ pretty ]
    (fun box _ ->
      Box.print_stdout box;
      Flow.return ())
