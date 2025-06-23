import re
import shutil
import os
import uuid
from runtool.language import Language
from runtool.util import run, run_to_file, tee, tee_stderr
from runtool.config import Config

class Ocaml5Backend(Language):
    def __init__(self):
        self.lang_name = "ocaml5"
        self.name = f"ocaml5"
        self.extension = "5.ml"
        self.main_uppercase = False
        self.backend = ""

    def compile(self, path: str, name: str, jit_path: str = Config.jit_path) -> list[str] | None:
        path = os.path.abspath(path)
        fname = os.path.basename(path)
        if fname.endswith(".ml"):
            fname = fname[:-len(".ml")]
        if fname.endswith(".5.ml"):
            fname = fname[:-len(".5.ml")]
        uniq_prefix = name + "_" + str(uuid.uuid4())
        result_path = os.path.abspath(f"./.oldeff-out/{uniq_prefix}")
        os.makedirs(result_path, exist_ok=True)

        # Ocamlopt
        o_proc = run(["nix-shell", "-p", "ocaml-ng.ocamlPackages_5_2.ocaml", "--command", f"ocamlopt -O3 -o {result_path}/{fname} {path}"], cwd=result_path)
        o_output = tee(o_proc, "[blue]   opt[/blue]|")

        return [result_path + f"/{fname}"] if os.path.exists(result_path + f"/{fname}") else None