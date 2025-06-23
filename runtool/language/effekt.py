import os
import uuid
from runtool.language import Language
from runtool.config import Config
from runtool.util import run, tee
import re
import functools

class EffektBackend(Language):
    def __init__(self, backend):
        self.lang_name = "effekt"
        self.name = f"effekt-{backend}"
        self.extension = "effekt"
        self.main_uppercase = False
        self.backend = backend
    
    def setup(self) -> None:
        proc = run(["nix-shell", "--command", "cd effekt; sbt effektJVM/compile"], check=True)
        tee(proc, "[blue]sbt [/blue]|")
        procm = run(["nix-shell", "--command", "cd effekt-ml; sbt effektJVM/compile"], check=True)
        tee(procm, "[blue]sbt [/blue]|")

    @functools.cache
    def compile(self, path: str, name: str, jit_path: str = Config.jit_path) -> list[str] | None:
        path = os.path.abspath(path)
        fname = os.path.basename(path)
        if fname.endswith(".effekt"):
            fname = fname[:-len(".effekt")]
        uniq_prefix = name + "_" + str(uuid.uuid4())
        
        # Check if we specified additional options 
        with open(path, 'r') as file:
            first_line = file.readline().strip()
        pattern = re.compile(r'^// Effekt options:\s*([^\n\r]*)$')
        additional_opts = ""
        match = pattern.match(first_line)
        if match:
            additional_opts = f"{match.group(1)} "
            print(f"Additional Effekt options: {additional_opts}")

        if self.backend == "jit":
            result_path = os.path.abspath(f"./.effekt-out/{uniq_prefix}/")
            e_proc = run(["sbt", "project effektJVM", f"run {additional_opts}--backend jit --no-optimize -o {result_path} --compile {path}"], cwd="./effekt")
            e_output = tee(e_proc, "[blue]effekt[/blue]| ")
            a_proc = run(["rpyeffect-asm/target/universal/stage/bin/rpyeffectasm", result_path + f"/{fname}.mcore.json", result_path + f"/{fname}.rpyeffect"])
            a_output = tee(a_proc, "[purple]rpyasm[/purple]| ")
            rpypath = result_path + f"/{fname}.rpyeffect"
            return [jit_path, rpypath] if os.path.exists(rpypath) else None
        elif self.backend == "ml":
            result_path = os.path.abspath(f"./.effekt-out/{uniq_prefix}/")
            e_proc = run(["sbt", "project effektJVM", f"run {additional_opts}--backend {self.backend} -o {result_path} --build {path}"], cwd="./effekt-ml")
            e_output = tee(e_proc, "[blue]effekt[/blue]| ")
            exepath = f"{result_path}/mlton-main"
            return [exepath] if os.path.exists(exepath) else None
        else:
            result_path = os.path.abspath(f"./.effekt-out/{uniq_prefix}/")
            e_proc = run(["sbt", "project effektJVM", f"run {additional_opts}--backend {self.backend} -o {result_path} --build {path}"], cwd="./effekt")
            e_output = tee(e_proc, "[blue]effekt[/blue]| ")
            exepath = f"{result_path}/{fname}"
            return [exepath] if os.path.exists(exepath) else None