#ifndef EXTERN_CALL_H_
#define EXTERN_CALL_H_

#include "value.h"
#include <unordered_map>
#include <functional>

namespace hvm {

class Extern {
  Value args_;
  std::unordered_map<std::string,
                     const std::function<Value(const std::vector<Value>&)>> extern_function_table_;

public:
  Extern(int argc, char* argv[]);
  Value ExternCall(const std::string& name, const std::vector<Value>& args);

};

} // namespace hvm

#endif  // EXTERN_CALL_H_