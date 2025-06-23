from dataclasses import dataclass
from abc import ABC, abstractmethod

@dataclass
class Language(ABC):
    name: str
    lang_name: str
    extension: str
    main_uppercase: bool = False

    def setup(self) -> None:
        return None
    
    @abstractmethod
    def compile(self, path: str, name: str, **kwargs: any) -> list[str] | None: ...

    def __hash__(self):
        return hash(self.name)
