#include "machine.h"
#include "parse.h"
#include "pretty_print.h"
#include <iostream>

int main(int argc, char* argv[])
{
  if (argc < 2) {
    std::cout << "Please provide a filename!" << std::endl;
    return 0;
  }

  auto program = hvm::Parse(argv[1]);

  if (program.size() != 0) {
    int exit_code = hvm::Execute(argc, argv, program);
    return exit_code;
  } else {
    std::cout << "File does not exists or it is empty!" << std::endl;
    return 0;
  }
}