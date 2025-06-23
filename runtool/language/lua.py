import os
import uuid
import shutil
from os.path import dirname
from runtool.language import Language
from runtool.util import run, run_to_file, tee, tee_stderr
from runtool.config import Config

class LuaBackend(Language):
    def __init__(self, backend):
        self.lang_name = "lua"
        self.name = f"lua-{backend}"
        self.extension = "lua"
        self.main_uppercase = False
        self.backend = backend

    def compile(self, path: str, name: str, jit_path: str = Config.jit_path) -> list[str] | None:
        # TODO pre-run for caching or sth?
        path = os.path.relpath(path, os.getcwd())
        if self.backend == "lua":
            return ["lua", path];
        elif self.backend == "luajit":
            return ["luajit", path]
        else:
            return None