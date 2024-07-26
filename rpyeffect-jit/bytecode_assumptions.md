# Assumptions made about the bytecode

This is an incomplete documentation about some assumptions this interpreter makes about the bytecode

## Data
- The arguments of a match clause are exactly as many as there are fields in the Data object.
- The default clause does not take any arguments

## Argument passing
- Arguments for Invoke and Return are always already in registers 0..k.