import os
import uuid
import shutil
from runtool.language import Language
from runtool.util import run, run_to_file, tee, tee_stderr
import runtool.config as cfg

class OldEffBackend(Language):
    def __init__(self, backend):
        self.lang_name = "oldeff"
        self.name = f"oldeff-{backend}"
        self.extension = "eff"
        self.main_uppercase = False
        self.backend = backend

    def compile(self, path: str, name: str, jit_path: str = cfg.jit_path) -> list[str] | None:
        path = os.path.abspath(path)
        fname = os.path.basename(path)
        if fname.endswith(".eff"):
            fname = fname[:-len(".eff")]
        uniq_prefix = name + "_" + str(uuid.uuid4())
        result_path = os.path.abspath(f"./.oldeff-out/{uniq_prefix}")
        os.makedirs(result_path, exist_ok=True)

        ext = "out"
        if self.backend.endswith("ml"):
            ext = "ml"

        eff = os.path.abspath("./oldeff/eff.exe")

        e_proc = run_to_file([eff, "--no-stdlib", f"--compile-{self.backend}", os.path.basename(path)], result_path + f"/{fname}.{ext}", cwd=os.path.dirname(path))
        e_output = tee_stderr(e_proc, "[blue]oldeff[/blue]|")

        if self.backend == "plain-ocaml":
            # Put fixture in place
            shutil.copy("./oldeff/ocamlHeader/ocamlHeader.ml", os.path.join(result_path, "./OcamlHeader.ml"))
            shutil.copy(os.path.join(os.path.dirname(path), "./wrapper.ml"), os.path.join(result_path, "./wrapper.ml"))

            # Ocamlformat
            f_proc = run_to_file(["ocamlformat", result_path + f"/{fname}.{ext}", "--enable-outside-detected-project"], result_path + f"/generated.ml", cwd=result_path)
            f_output = tee_stderr(f_proc, "[blue]  fmt [/blue]|")

            # Ocamlopt
            o_proc = run(["ocamlopt", "-O3", "-o", result_path + f"/{fname}", "OcamlHeader.ml", "generated.ml", "wrapper.ml"], cwd=result_path)
            o_output = tee(o_proc, "[blue]   opt[/blue]|")

            return [result_path + f"/{fname}"] if os.path.exists(result_path + f"/{fname}") else None

        else:
            return None