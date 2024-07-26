#ifndef PRETTY_PRINT_H_
#define PRETTY_PRINT_H_

#include "value.h"
#include "instruction_set.h"

namespace hvm {

std::string PrettyPrintProgram(Program);
std::string PrettyPrintValue(Value);

} // namespace hvm

#endif  // PRETTY_PRINT_H_