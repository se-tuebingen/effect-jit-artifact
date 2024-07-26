
let enabled = ref false

let log_b modl boxes =
  if !enabled then begin
    Box.print_stderr (Box.tbox (
      Box.textfl "%.5f %s:" (Sys.time ()) modl
      @  Box.text_indent 2
      :: Lazy.force boxes))
  end
