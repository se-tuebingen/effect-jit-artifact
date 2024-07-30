import re
import shutil
import os
import uuid
from runtool.language import Language
from runtool.util import run, tee
from runtool.config import jit_path

class KokaBackend(Language):
    def __init__(self, backend):
        self.lang_name = "koka"
        self.name = f"koka-{backend}"
        self.extension = "kk"
        self.main_uppercase = False
        self.backend = backend

    def compile(self, path: str, name: str) -> list[str] | None:
        path = os.path.abspath(path)
        proch = run(["stack", "build"], cwd="./koka")
        outputh = tee(proch, "[blue]ghc [/blue]| ")
        proc = run(["stack", "exec", "koka", "--", f"--target={self.backend}", path], cwd="./koka")
        output = tee(proc, "[blue]comp[/blue]| ")
        c = output[-1]
        result_path, result = None, None
        for c in output:
            if re.match("[^A-Za-z]*created[^A-Za-z]*.*", c):
                result_path = os.path.abspath("./koka/" + c.split(":")[-1].lstrip().rstrip())
        if result_path is not None:
            uniq_prefix = name + "_" + str(uuid.uuid4())
            new_result_path = os.path.join(os.path.dirname(os.path.dirname(result_path)), 
                                           uniq_prefix + "_" + os.path.basename(os.path.dirname(result_path)), 
                                           os.path.basename(result_path))
            shutil.copytree(os.path.dirname(result_path), os.path.dirname(new_result_path))
            
            if self.backend == "vm":
                rpypath = re.sub("[.]mcore[.]json$", ".rpyeffect", new_result_path)
                result = [jit_path, rpypath] if os.path.exists(rpypath) else None
            elif self.backend == "js":
                result = ["node", new_result_path] if os.path.exists(new_result_path) else None
            elif self.backend == "c":
                result = [new_result_path] if os.path.exists(new_result_path) else None
        return result