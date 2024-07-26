from rpyeffect.value import Value

class Symbol(Value):
    """named (exported) symbol in a program"""
    __immutable_fields__ = ['name', 'position']
    def __init__(self, name, position):
        self.name = name
        self.position = position

    def __repr__(self):
        return "<Symbol %s @ %s>" % (self.name, self.position)