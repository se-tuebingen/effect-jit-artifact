import unicodedata
import rich, rich.table, rich.console

def remove_control_characters(s):
    return "".join(ch for ch in s if unicodedata.category(ch)[0]!="C" or ch in "\n\r")
def styled(str):
    cns = rich.console.Console()
    with cns.capture() as cpt:
        cns.print(str)
    cpt = cpt.get()
    if cpt[-1] == '\n': cpt = cpt[:-1]
    return cpt