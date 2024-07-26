# Notes on Rpyeffect-JIT
- promote evv on obj level in koka (shaves off ~1s for countdown, improves traces a lot)
  - global var needs some manual work (promote when reading)
  - fix global loop box ptr thingy
- future future: dynamic trmc


- TODO: Run fn with two different handler impls