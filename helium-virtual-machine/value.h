#ifndef VALUE_H_
#define VALUE_H_

#include <cstddef>
#include <cstdint>
#include <memory>
#include <string>
#include <variant>
#include <vector>
#include <any>
#include "persistent_data_structures/list.h"

namespace hvm {

using HeliumInt = std::int64_t;
using HeliumUnsignedInt = std::uint64_t;

struct Record;
struct Closure;
struct RecursiveBinding;
struct Resumption;
struct ReturnAddress;

using ExternValue = std::shared_ptr<std::any>;

using Value = std::variant<HeliumInt, std::string, Record,
  std::shared_ptr<Closure>, std::shared_ptr<RecursiveBinding>,
  std::shared_ptr<Resumption>, ExternValue>;

using Environment = list::List<Value>;
using ArgStack = std::vector<Value>;
using ReturnStack = list::List<ReturnAddress>;

struct ManagedObject {
  static std::vector<std::shared_ptr<Value[]>> garbage_shared_arrays;
  static std::vector<list::List<Value>> garbage_lists;
};

struct Record : ManagedObject {
  std::shared_ptr<Value[]> fields;

  friend bool operator==(const Record& l, const Record& r)
  {
      return l.fields.get() == r.fields.get();
  }

  Record() = default;
  Record(const std::shared_ptr<Value[]>& fields) :
    fields(fields) {}

  ~Record();
};

struct MetaStackFrame : ManagedObject {
  int label;
  Environment environment;
  ReturnStack return_stack;
  int handler_pointer;

  MetaStackFrame() = default;
  MetaStackFrame(const MetaStackFrame &) = default;
  MetaStackFrame(MetaStackFrame &&) = default;
  MetaStackFrame& operator=(const MetaStackFrame&) = default;
  MetaStackFrame& operator=(MetaStackFrame&&) = default;

  MetaStackFrame(int label, const Environment& environment,
    ReturnStack&& return_stack, int handler_pointer) :
      label(label),
      environment(environment),
      return_stack(std::move(return_stack)),
      handler_pointer(handler_pointer) {};

  ~MetaStackFrame();
};

using MetaStack = std::vector<MetaStackFrame>;

struct Closure : ManagedObject {
  size_t instruction_pointer;
  size_t arity;
  Environment environment;
  std::weak_ptr<RecursiveBinding> recursive_binding;

  Closure() = default;

  Closure (size_t instruction_pointer, const Environment& environment) :
    instruction_pointer(instruction_pointer), arity(1),
    environment(environment), recursive_binding() {};

  Closure (size_t instruction_pointer, Environment&& environment) :
    instruction_pointer(instruction_pointer), arity(1),
    environment(std::move(environment)), recursive_binding() {};

  Closure (size_t instruction_pointer, size_t arity, const Environment& environment) :
    instruction_pointer(instruction_pointer), arity(arity),
    environment(environment), recursive_binding() {};

  Closure (size_t instruction_pointer, size_t arity, const Environment& environment,
    const std::weak_ptr<RecursiveBinding>& recursive_binding) :
    instruction_pointer(instruction_pointer), arity(arity),
    environment(environment), recursive_binding(recursive_binding) {};

  ~Closure();
};

struct RecursiveBinding {
  size_t n;
  std::unique_ptr<Closure[]> bindings;

  RecursiveBinding(size_t n) : n(n) {
    bindings = std::unique_ptr<Closure[]> (new Closure[n]);
  }
};


struct Resumption : ManagedObject {
  int instruction_pointer;
  Environment environment;
  MetaStack reified_meta_stack;

  Resumption (const Resumption&) = default;
  Resumption (int instruction_pointer, const Environment& environment,
    MetaStack&& reified_meta_stack) :
      instruction_pointer(instruction_pointer), environment(environment),
      reified_meta_stack(std::move(reified_meta_stack)) {};

  ~Resumption();
};

struct ReturnAddress {
  size_t instruction_pointer;
  Environment environment;

  ReturnAddress(size_t instruction_pointer, const Environment& environment) :
    instruction_pointer(instruction_pointer), environment(environment) {}

  ReturnAddress(size_t instruction_pointer, Environment&& environment) :
    instruction_pointer(instruction_pointer), environment(std::move(environment)) {}
};

} // namespace hvm

#endif  // VALUE_H_