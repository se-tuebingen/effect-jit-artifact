#include "value.h"

namespace hvm {

std::vector<std::shared_ptr<Value[]>> ManagedObject::garbage_shared_arrays;
std::vector<list::List<Value>> ManagedObject::garbage_lists;

Closure::~Closure() {
  garbage_lists.emplace_back(std::move(environment));
}

Record::~Record() {
  garbage_shared_arrays.emplace_back(std::move(fields));
}

MetaStackFrame::~MetaStackFrame() {
  garbage_lists.emplace_back(std::move(environment));
  // garbage_lists.emplace_back(std::move(return_stack));
}

Resumption::~Resumption() {
  garbage_lists.emplace_back(std::move(environment));
}

} // namespace hvm