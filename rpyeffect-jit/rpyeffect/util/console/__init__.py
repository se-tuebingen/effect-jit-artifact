def pad(text, width, left, right, prefer="left"):
    # type: (str, int, str, str, str) -> str
    """Pads text with left on the left and right on the right
                     
    If `len(left)+len(right)==1`, or `len(left)==len(right)==1` and `prefer` is `"left"/"right"`,
    the result will have exactly length `width`.
    The `prefer`red direction will be potentially padded once more.

    Args:
        text (str): Text to pad
        width (int): minimum length of result. 
        left (str): character(s) to add on the left
        right (str): character(s) to add on the right
        prefer (str, optional): Which side to prefer. One of "left"/"right"/"symmetric".

    Returns:
        str: padded text
    """
    while True:
        if visual_len(text) >= width:
            return text
        if len(left) == 0:
            return text + right * int((width - visual_len(text) + visual_len(right)-1) // visual_len(right))
        elif len(right) == 0:
            return left * int((width - visual_len(text) + visual_len(left)-1) // visual_len(left)) + text
        elif prefer == "left":
            text = left + text
            prefer = "right"
        elif prefer == "right":
            text = text + right
            prefer = "left"
        elif prefer == "symmetric":
            text = left + text + right
        else:
            assert(False)

def align_line(line, width, align="l", pad_with=" "):
    # type: (str, int, str, str) -> str
    """Aligns a single line to the left/right/center

    Args:
        line (str): _description_
        width (int): _description_
        align (str, optional): Alignment. One of "l"/"r"/"c", defaults to "l".

    Returns:
        str: _description_
    """
    if align == "l":
        return pad(line, width, "", pad_with)
    elif align == "r":
        return pad(line, width, pad_with, "")
    elif align == "c":
        return pad(line, width, pad_with, pad_with)
    else:
        assert(False)
 
def visual_len(text):
    # type: (str) -> int
    res = 0
    i = 0
    while i < len(text):
        if text[i] == "\033":
            while text[i] != "m" and i < len(text):
                i += 1
            i += 1
        else:
            i += 1
            res += 1
    return res
def width(text):
    # type: (str) -> int
    return max([visual_len(line) for line in text.split("\n")])
def height(text):
    # type: (str) -> int
    return text.count("\n")

def align(text, width, align="l", pad_with=" "):
    # type: (str, int, str, str) -> str
    lines = text.split("\n")
    return "\n".join([align_line(line, width, align, pad_with=pad_with) for line in lines])

def box(text, align_body="l", top=True, bot=True, 
        topleft=u"\u250c", topright=u"\u2510", 
        botleft=u"\u2514", botright=u"\u2518", 
        hor=u"\u2500", ver=u"\u2502", title=None, 
        align_title="c"):
    title = " " + title + " " if title is not None else ""
    lines = text.split("\n")
    w = max(width(text), visual_len(title))
    top_s = (topleft + align(title, w, align_title, pad_with=hor) + topright + "\n") if top else ""
    bot_s = "\n" + botleft + hor * w + botright if bot else ""
    content = "\n".join([ver + align_line(line, w, align_body) + ver for line in lines])
    return top_s + content + bot_s

def beside(left, right, align_l="l", align_r="l", align_v="t", sep=""):
    w_left = width(left)
    w_right = width(right)
    left_lines = align(left, w_left, align_l).split("\n")
    right_lines = align(right, w_right, align_r).split("\n")
    n_lines = max(len(left_lines), len(right_lines))

    res_lines = []
    for i in range(n_lines):
        # Adjust indices for vertical alignment
        if align_v == "b":
            i_l = len(left_lines) - n_lines + i
            i_r = len(right_lines) - n_lines + i
        elif align_v == "c":
            i_l = (len(left_lines) - n_lines) // 2 + i
            i_r = (len(right_lines) - n_lines) // 2 + i
        elif align_v == "t":
            i_l, i_r = i, i

        l = left_lines[i_l] if i_l >= 0 and i_l < len(left_lines) else " " * w_left
        r = right_lines[i_r] if i_r >= 0 and i_r < len(right_lines) else " " * w_right
        res_lines.append(l + sep + r)
    return "\n".join(res_lines)

def above(top, bottom, align_t="l", align_b="l", sep=""):
    w = max(width(top), width(bottom))
    sep = "\n" + ((w * sep + "\n") if sep != "" else "")
    return align(top, w, align_t) + sep + align(bottom, w, align_b)

def wrap(text, width=80, indent=0):
    lines = text.split('\n')
    res = []
    indent_str = " " * indent
    actual_width = width - indent
    for line in lines:
        if visual_len(line) > actual_width:
            rest = line
            while visual_len(rest) > actual_width:
                s = rest.rfind(" ",1,actual_width) # TODO try to use space chars
                if s == -1:
                    s = actual_width
                res.append(indent_str + rest[:s])
                rest = rest[s:]
            res.append(indent_str + rest)
        else:
            res.append(indent_str + line)
    return "\n".join(res)

def wrap_align(text, width=80, indent=0, alignment="l"):
    return align(wrap(text, width, indent), width, align=alignment)

def wrap_align_all(texts, max_width=80, indent=0, alignment="l"):
    w = 0
    for text in texts:
        cw = width(text)
        if cw > w:
            if cw > max_width:
                w = max_width
            else:
                w = cw
    return [wrap_align(text, w, indent=indent, alignment=alignment) for text in texts]