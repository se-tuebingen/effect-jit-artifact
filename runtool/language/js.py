import os
import uuid
import shutil
from runtool.language import Language
from runtool.util import run, run_to_file, tee, tee_stderr
import runtool.config as cfg

class JSBackend(Language):
    def __init__(self, backend):
        self.lang_name = "js"
        self.name = f"js-{backend}"
        self.extension = "js"
        self.main_uppercase = False
        self.backend = backend

    def compile(self, path: str, name: str, jit_path: str = cfg.jit_path) -> list[str] | None:
        # TODO pre-run for caching or sth?
        if self.backend == "v8":
            return ["node", path]
        else:
            return None