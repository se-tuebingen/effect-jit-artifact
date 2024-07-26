#ifndef PARSE_H_
#define PARSE_H_

#include "value.h"
#include "instruction_set.h"

namespace hvm {

Program Parse(std::string);

} // namespace hvm

#endif  // PARSE_H_