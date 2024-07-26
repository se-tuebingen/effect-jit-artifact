# Helium Virtual Machine

## Building
Helium Virtual Machine requires CMake for building.
```bash
mkdir build
cd build
cmake ..
make
```

## Running

To run a program with HVM you need to compile it.
To do this run [helium](https://bitbucket.org/pl-uwr/helium/src/master/) with the -compile flag.

To execute a compiled program run:

```bash
./HeliumVirtualMachine filename
```