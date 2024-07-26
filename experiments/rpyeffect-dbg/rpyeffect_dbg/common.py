from dataclasses import dataclass
from abc import ABC, abstractmethod
from enum import Enum

class Method(ABC):
    def __init__(self, tag):
        self.tag = tag
    @abstractmethod
    def tpe(self) -> "TMethod": ...

class Id: pass

@dataclass
class Name(Id):
    name: str

@dataclass
class Index(Id):
    idx: int

################################################################################
# Types
################################################################################

class Type: pass

class TBase(Type, Enum):
    UNIT = "unit"
    INT = "int"
    DOUBLE = "double"
    STRING = "str"

@dataclass
class TConstructor:
    tag: "Tag"
    fields: list[tuple[Id, Type]]

@dataclass
class TData(Type):
    type_tag: "Tag"
    constructors: list[TConstructor]

@dataclass
class TMethod:
    tag: "Tag"
    params: list[Type]
    returns: list[Type]

@dataclass
class TCodata(Type):
    type_tag: "Tag"
    methods: list[TMethod]

################################################################################
# Values
################################################################################

class Value(ABC):
    @abstractmethod
    def tpe(self) -> Type: ...

@dataclass
class _Tag(Value):
    name: str
Tag = _Tag
_tags: dict[str, _Tag] = dict()
def intern(name: str) -> Tag:
    if name not in _tags:
        _tags[name] = _Tag(name)
    return _tags[name]

@dataclass
class VUnit(Value):
    def tpe(self) -> Type:
        return TBase.UNIT

@dataclass
class VInt(Value):
    value: int
    def tpe(self) -> Type:
        return TBase.INT

@dataclass
class VDouble(Value):
    value: float
    def tpe(self) -> Type:
        return TBase.DOUBLE

@dataclass
class VString(Value):
    value: str
    def tpe(self) -> Type:
        return TBase.STRING

@dataclass
class VData(Value):
    type_tag: Tag
    tag: Tag
    fields: list[tuple[Id, Value]]

    def tpe(self) -> Type:
        return TData(self.type_tag, [TConstructor(self.tag, [(fn, fv.tpe()) for (fn, fv) in self.fields])])

@dataclass
class VCoData(Value):
    type_tag: Tag
    captured: "Environment"
    methods: list[Method]

    def tpe(self) -> Type:
        return TCodata(self.type_tag, [m.tpe() for m in self.methods])


################################################################################
# Environments
################################################################################

class Environment(ABC):
    @abstractmethod
    def lookup(self, name: Id, tpe: Type) -> Value: ...