PYTHON_FILES = $(shell find rpyeffect/ -type f -iname '*.py')
BENCHMARKS = $(patsubst test/%,results/%,$(filter-out test/shift_resume, $(filter-out %.args,$(wildcard test/*))))
OS = $(shell uname -s)
ARCH = $(shell uname -m)
ifeq (, $(shell which pypy))
$(info Note: Compiling using cpython, might be slower)
PYTHON = python2
else
PYTHON = pypy
endif

all: out/bin/$(ARCH)-$(OS)/rpyeffect-jit out/bin/$(ARCH)-$(OS)/rpyeffect-interpret out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-specialization out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-context out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-addcej out/bin/$(ARCH)-$(OS)/rpyeffect-jit-2-context out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-labelbydefsite out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-opt

.PHONY: benchmark all test jitlogs

test: $(PYTHON_FILES)
	pypy/pytest.py -s ./rpyeffect/test/test_interpreter.py
	pypy/pytest.py -s ./rpyeffect/test/test_jit.py

out/bin/$(ARCH)-$(OS)/rpyeffect-interpret: $(PYTHON_FILES)
	echo "Interpreter:"
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-interpret-$(ARCH)-$(OS) ./rpyeffect/main.py
	mv ./rpyeffect-interpret-$(ARCH)-$(OS) ./out/bin/$(ARCH)-$(OS)/rpyeffect-interpret
out/bin/$(ARCH)-$(OS)/rpyeffect-jit: $(PYTHON_FILES)
	echo "With all optimizations:"
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS) --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS) ./out/bin/$(ARCH)-$(OS)/rpyeffect-jit

# Various helpers for builds with config changes
out/bin/$(ARCH)-$(OS)/rpyeffect-jit-debug: $(PYTHON_FILES)
	echo "Debug build:"
	cp rpyeffect/config.py rpyeffect/config.py.bak
	sed -i 's/^debug *= *.*$$/debug = True/g' rpyeffect/config.py
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS)-debug --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS)-debug $@
	mv rpyeffect/config.py.bak rpyeffect/config.py
out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-specialization: $(PYTHON_FILES)
	echo "Without specialization:"
	cp rpyeffect/config.py rpyeffect/config.py.bak
	sed -i 's/^specialize_\([a-zA-Z]*\) *= *.*$$/specialize_\1 = 0, 0/g' rpyeffect/config.py
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS)-no-specialization --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS)-no-specialization $@
	mv rpyeffect/config.py.bak rpyeffect/config.py
out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-addcej: $(PYTHON_FILES)
	echo "Without addcej:"
	cp rpyeffect/config.py rpyeffect/config.py.bak
	sed -i 's/^additional_can_enter_jit_locations *= *.*$$/additional_can_enter_jit_locations = False/g' rpyeffect/config.py
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS)-no-addcej --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS)-no-addcej $@
	mv rpyeffect/config.py.bak rpyeffect/config.py
out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-context: $(PYTHON_FILES)
	echo "Without context:"
	cp rpyeffect/config.py rpyeffect/config.py.bak
	sed -i 's/^loop_context_depth *= *[0-9]*$$/loop_context_depth = 0/g' rpyeffect/config.py
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS)-no-context --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS)-no-context $@
	mv rpyeffect/config.py.bak rpyeffect/config.py
out/bin/$(ARCH)-$(OS)/rpyeffect-jit-2-context: $(PYTHON_FILES)
	echo "With more context:"
	cp rpyeffect/config.py rpyeffect/config.py.bak
	sed -i 's/^loop_context_depth *= *[0-9]*$$/loop_context_depth = 2/g' rpyeffect/config.py
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS)-2-context --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS)-2-context $@
	mv rpyeffect/config.py.bak rpyeffect/config.py
out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-addcej-no-context: $(PYTHON_FILES)
	echo "Without all optimizations:"
	cp rpyeffect/config.py rpyeffect/config.py.bak
	sed -i 's/^loop_context_depth *= *[0-9]*$$/loop_context_depth = 0/g' rpyeffect/config.py
	sed -i 's/^additional_can_enter_jit_locations *= *.*$$/additional_can_enter_jit_locations = False/g' rpyeffect/config.py
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS)-no-addcej-no-context --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS)-no-addcej-no-context $@
	mv rpyeffect/config.py.bak rpyeffect/config.py
out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-opt: $(PYTHON_FILES)
	echo "Without all optimizations:"
	cp rpyeffect/config.py rpyeffect/config.py.bak
	sed -i 's/^specialize_\([a-zA-Z]*\) *= *.*$$/specialize_\1 = 0, 0/g' rpyeffect/config.py
	sed -i 's/^loop_context_depth *= *[0-9]*$$/loop_context_depth = 0/g' rpyeffect/config.py
	sed -i 's/^additional_can_enter_jit_locations *= *.*$$/additional_can_enter_jit_locations = False/g' rpyeffect/config.py
	sed -i 's/^allocation_site_based_eq_label *= *True$$/allocation_site_based_eq_label = False/g' rpyeffect/config.py
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS)-no-specialization --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS)-no-specialization $@
	mv rpyeffect/config.py.bak rpyeffect/config.py
out/bin/$(ARCH)-$(OS)/rpyeffect-jit-no-labelbydefsite: $(PYTHON_FILES)
	echo "Without label by def site:"
	cp rpyeffect/config.py rpyeffect/config.py.bak
	sed -i 's/^allocation_site_based_eq_label *= *True$$/allocation_site_based_eq_label = False/g' rpyeffect/config.py
	mkdir -p out/bin/$(ARCH)-$(OS)
	$(PYTHON) pypy/rpython/bin/rpython --output=rpyeffect-jit-$(ARCH)-$(OS)-no-labelbydefsite --opt=jit ./rpyeffect/main.py
	mv ./rpyeffect-jit-$(ARCH)-$(OS)-no-labelbydefsite $@
	mv rpyeffect/config.py.bak rpyeffect/config.py


benchmark: benchmark_results.json
jitlogs: $(patsubst %, %.log, $(BENCHMARKS))

results/%.log results/%_jit.json results/%_nojit.json: test/% out/bin/$(ARCH)-$(OS)/rpyeffect-interpret out/bin/$(ARCH)-$(OS)/rpyeffect-jit
	./bin/benchmark.sh $*
benchmark_results.json: $(patsubst %, %_jit.json, $(BENCHMARKS)) $(patsubst %, %_nojit.json, $(BENCHMARKS))
	jq -s 'map(.[])' $^ > benchmark_results.json
