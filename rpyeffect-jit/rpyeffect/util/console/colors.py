import sys
from rpython.rlib import objectmodel
from rpython.rlib.jit import unroll_safe

class Color:
    def __init__(self, startcode, endcode = "\033[0m"):
        self.startcode = startcode
        self.endcode = endcode
    @unroll_safe
    @objectmodel.always_inline
    def wrap(self, text):
        lines = text.split("\n")
        return self.startcode + (self.endcode + "\n" + self.startcode).join(lines) + self.endcode
def _simple(code):
    return Color("\033[" + code + "m")

colors = {
    "black": _simple("0;30"),
    "red": _simple("0;31"),
    "green": _simple("0;32"),
    "brown": _simple("0;33"),
    "blue": _simple("0;34"),
    "purple": _simple("0;35"),
    "cyan": _simple("0;36"),
    "light_gray": _simple("0;37"),
    "dark_gray": _simple("1;30"),
    "light_red": _simple("1;31"),
    "light_green": _simple("1;32"),
    "yellow": _simple("1;33"),
    "light_blue": _simple("1;34"),
    "light_purple": _simple("1;35"),
    "light_cyan": _simple("1;36"),
    "light_white": _simple("1;37"),
    "bold": _simple("1"),
    "faint": _simple("2"),
    "italic": _simple("3"),
    "underline": _simple("4"),
    "blink": _simple("5"),
    "negative": _simple("7"),
    "crossed": _simple("9")
}

def _generate_color_wrap(target, name, color):
    @unroll_safe
    @objectmodel.always_inline
    def fn(t):
        return color.wrap(t)
    target[name] = fn

def _generate_color_wraps():
    caller = sys._getframe(1)
    target = caller.f_locals
    colors = target["colors"]
    
    for name, color in colors.items():
        _generate_color_wrap(target, name, color)

_generate_color_wraps()