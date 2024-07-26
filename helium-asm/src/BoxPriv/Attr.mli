
type color =
| Black
| Red
| Green
| Yellow
| Blue
| Magenta
| Cyan
| White

type base_attribute =
| BA_Bold
| BA_Underline
| BA_Blink
| BA_Negative
| BA_CrossedOut
| BA_FgColor of color
| BA_BgColor of color

type t =
| Const
| Oper
| Keyword
| Text
| Path
| Error
| Base of base_attribute
