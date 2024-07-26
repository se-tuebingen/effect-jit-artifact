import os
import uuid
import shutil
from runtool.util import tee, run
import runtool.config as cfg
from runtool.language import Language

class HeliumBackend(Language):
    def __init__(self, backend):
        self.lang_name = "helium"
        self.name = f"helium-{backend}"
        self.extension = "he"
        self.main_uppercase = False # TODO ?
        self.backend = backend

    def compile(self, path: str, name: str, jit_path: str = cfg.jit_path) -> list[str] | None:
        path = os.path.abspath(path)
        uniq_prefix = name + "_" + str(uuid.uuid4())
        if self.backend == "rpyeffect":
            h_result_path = "./helium/a.out"
            if os.path.exists(h_result_path):
                os.remove(h_result_path)
            h_proc = run(["bin/helium", "-rpycompile", path], cwd="./helium")
            h_output = tee(h_proc, "[blue]helium[/blue]| ")
            result_dir = os.path.abspath(f"./.helium-out/{uniq_prefix}/")
            os.makedirs(result_dir, exist_ok=True)
            h_new_result_path = os.path.join(result_dir, os.path.basename(path + ".mcore.json"))
            if os.path.exists(h_result_path): shutil.copy(h_result_path, h_new_result_path)
            if not os.path.exists(h_result_path):
                return None
            a_result_path = os.path.join(result_dir, os.path.basename(path + ".rpyeffect"))
            a_proc = run(["rpyeffect-asm/target/universal/stage/bin/rpyeffectasm", "--from", "mcore-json", h_new_result_path, a_result_path])
            a_output = tee(a_proc, "[purple]rpyasm[/purple]| ")
            if not os.path.exists(a_result_path): return None
            return [jit_path, a_result_path]
        return None