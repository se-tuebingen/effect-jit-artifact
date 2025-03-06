import unicodedata
import rich, rich.table, rich.console
import os
import json
import subprocess
import sys

################################################################################
# Styling
################################################################################

def remove_control_characters(s):
    return "".join(ch for ch in s if unicodedata.category(ch)[0]!="C" or ch in "\n\r")
def styled(str):
    cns = rich.console.Console()
    with cns.capture() as cpt:
        cns.print(str)
    cpt = cpt.get()
    if cpt[-1] == '\n': cpt = cpt[:-1]
    return cpt


################################################################################
# Persistent state for run results
################################################################################

logdict = dict()
if os.path.exists("./.runlog.json"):
    with open("./.runlog.json") as f:
        logdict = json.load(f)
def store_logdict():
    global logdict
    print(f"STORING")
    with open("./.runlog.json", "w") as f:
        json.dump(logdict, f)
def log(*parts: str | None | list[str]):
    global logdict
    curd = logdict
    curp = parts
    while len(curp) > 2:
        if curp[0] not in curd or not isinstance(curd[curp[0]], dict):
            curd[curp[0]] = dict()
        curd = curd[curp[0]]
        curp = curp[1:]

    curd[curp[0]] = curp[1]


################################################################################
# Running subprocesses with output
################################################################################

def tee(proc: subprocess.Popen[str], prefix: str = "> ") -> list[str]:
    log = []
    os.set_blocking(proc.stdout.fileno(), False)
    os.set_blocking(proc.stderr.fileno(), False)
    while proc.poll() is None:
        text = proc.stdout.readline()
        while text != "":
            log.append(text)
            plaintext = remove_control_characters(text)
            if plaintext.lstrip().rstrip() != "":
                sys.stdout.write(styled(prefix) + plaintext)
            text = proc.stdout.readline()
        text = proc.stderr.readline()
        while text != "":
            log.append(text)
            plaintext = remove_control_characters(text)
            if plaintext.lstrip().rstrip() != "":
                sys.stderr.write(styled(prefix) + plaintext)
            text = proc.stderr.readline()
    return log
def tee_stderr(proc: subprocess.Popen[str], prefix: str = "> ") -> list[str]:
    log = []
    os.set_blocking(proc.stderr.fileno(), False)
    while proc.poll() is None:
        text = proc.stderr.readline()
        while text != "":
            log.append(text)
            plaintext = remove_control_characters(text)
            if plaintext.lstrip().rstrip() != "":
                sys.stderr.write(styled(prefix) + plaintext)
            text = proc.stderr.readline()
    return log

def shell_escape(arg):
    if any(c in arg for c in " \\"):
        return f"'{arg}'"
    return arg

def run(args: list[str], cwd=".", env=os.environ):
    rich.print(f"[red]RUNNING[/red] [grey50]{' '.join(map(shell_escape,args))}[/grey50]")
    return subprocess.Popen(args, env=env, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding='utf-8')
def run_to_file(args: list[str], out: str, cwd=".", env=os.environ):
    rich.print(f"[red]RUNNING[/red] [grey50]{' '.join(map(shell_escape,args))}[/grey50]")
    with open(out, "w") as f:
        return subprocess.Popen(args, env=env, cwd=cwd, stdout=f, stderr=subprocess.PIPE, encoding='utf-8')
def run_through_to_file(args: list[str], inputfile: str, out: str, cwd=".", env=os.environ):
    rich.print(f"[red]RUNNING[/red] [grey50]{' '.join(map(shell_escape,args))}[/grey50]")
    with open(inputfile, "r") as fi:
        with open(out, "w") as fo:
            return subprocess.Popen(args, env=env, cwd=cwd, stdin=fi, stdout=fo, stderr=subprocess.PIPE, encoding='utf-8')
