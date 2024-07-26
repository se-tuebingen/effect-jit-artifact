from rpyeffect.value import Value

class InternTable:
    def __init__(self):
        self.interned = {}

    def intern(self, str):
        # type: (str) -> InternedString
        if str not in self.interned:
            self.interned[str] = InternedString(str)
        return self.interned[str]
           
class InternedString(Value):
    _immutable_fields_ = ['str']
    def __init__(self, str):
        self.str = str

    def __repr__(self):
        return ("Interned(%s)" % self.str)