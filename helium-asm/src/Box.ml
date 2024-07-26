open BoxPriv
include Core

type color = Attr.color =
| Black
| Red
| Green
| Yellow
| Blue
| Magenta
| Cyan
| White

type base_attribute = Attr.base_attribute =
| BA_Bold
| BA_Underline
| BA_Blink
| BA_Negative
| BA_CrossedOut
| BA_FgColor of color
| BA_BgColor of color

type attr = Attr.t =
| Const
| Oper
| Keyword
| Text
| Path
| Error
| Base of base_attribute

let print_stdout box =
  Printer.print (Printer.create stdout) box

let print_stderr box =
  Printer.print (Printer.create stderr) box

let print_stdout_no_nl box =
  Printer.print_no_nl (Printer.create stdout) box

let print_stderr_no_nl box =
  Printer.print_no_nl (Printer.create stderr) box
