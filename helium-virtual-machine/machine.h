#ifndef MACHINE_H_
#define MACHINE_H_

#include "value.h"
#include "instruction_set.h"
#include "persistent_data_structures/list.h"

namespace hvm {

using ExitCode = int;
using Result = std::variant<ExitCode, Value>;

Result Run(Program program);
Result Run(int argc, char* argv[], Program program);
ExitCode Execute(int argc, char* argv[], Program program);

} // namespace hvm

#endif  // MACHINE_H_