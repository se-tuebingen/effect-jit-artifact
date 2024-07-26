#include "extern_call.h"
#include "value.h"
#include <any>
#include <iostream>
#include <cstdio>
#include <string>

namespace hvm {

namespace {

Value Id(const std::vector<Value>& args) {
  return args[0];
}

Value helium_readInt([[maybe_unused]] const std::vector<Value>& args) {
  HeliumInt n;
  std::cin >> n;
  return n;
}

Value helium_readLine([[maybe_unused]] const std::vector<Value>& args) {
  std::string s;
  std::getline(std::cin, s);
  return s;
}

Value helium_printInt(const std::vector<Value>& args) {
  std::cout << std::get<HeliumInt>(args[0]) << "\n";
  return 0;
}

Value helium_printStr(const std::vector<Value>& args) {
  std::cout << std::get<std::string>(args[0]).c_str();
  return 0;
}

Value helium_stdin([[maybe_unused]] const std::vector<Value>& args) {
  return std::make_shared<std::any>(std::make_any<FILE*>(stdin));
}

Value helium_stdout([[maybe_unused]] const std::vector<Value>& args) {
  return std::make_shared<std::any>(std::make_any<FILE*>(stdout));
}

Value helium_stderr([[maybe_unused]] const std::vector<Value>& args) {
  return std::make_shared<std::any>(std::make_any<FILE*>(stderr));
}

Value helium_input(const std::vector<Value>& args) {
  HeliumInt n = std::get<HeliumInt>(args[0]);
  FILE* f = std::any_cast<FILE*>(*std::get<ExternValue>(args[1]));
  char buffer[n];
  std::fread(buffer, 1, n, f);
  return std::string(buffer);
}

Value helium_outputString(const std::vector<Value>& args) {
  std::string s = std::get<std::string>(args[0]);
  FILE* f = std::any_cast<FILE*>(*std::get<ExternValue>(args[1]));
  std::fputs(s.c_str(), f);
  return 0;
}

Value helium_openIn(const std::vector<Value>& args) {
  std::string filename = std::get<std::string>(args[0]);
  return std::make_shared<std::any>(std::make_any<FILE*>(std::fopen(filename.c_str(), "r")));
}


Value helium_openOut(const std::vector<Value>& args) {
  std::string filename = std::get<std::string>(args[0]);
  return std::make_shared<std::any>(std::make_any<FILE*>(std::fopen(filename.c_str(), "w")));
}

Value helium_close(const std::vector<Value>& args) {
  FILE* f = std::any_cast<FILE*>(*std::get<ExternValue>(args[0]));
  std::fclose(f);
  return 0;
}

Value helium_appendStr(const std::vector<Value>& args) {
  return std::get<std::string>(args[1]) + std::get<std::string>(args[0]);
}

Value helium_lengthStr(const std::vector<Value>& args) {
  return (HeliumInt)std::get<std::string>(args[0]).length();
}

Value helium_substringStr(const std::vector<Value>& args) {
  return std::get<std::string>(args[2]).substr(std::get<HeliumInt>(args[1]),
                                               std::get<HeliumInt>(args[0]));
}

Value helium_stringOfInt(const std::vector<Value>& args) {
  return std::to_string(std::get<HeliumInt>(args[0]));
}

Value helium_stringGet(const std::vector<Value>& args) {
  return (HeliumInt)std::get<std::string>(args[0])[std::get<HeliumInt>(args[1])];
}

Value helium_indexStr(const std::vector<Value>& args) {
  return (HeliumInt)std::get<std::string>(args[1])[std::get<HeliumInt>(args[0])];
}

Value helium_rawCompareStr(const std::vector<Value>& args) {
  return std::get<std::string>(args[1]).compare(std::get<std::string>(args[0]));
}

Value helium_stringRepeat(const std::vector<Value>& args) {
  return std::string(std::get<HeliumInt>(args[1]), (char)std::get<HeliumInt>(args[0]));
}

const std::function<Value(const std::vector<Value>&)> helium_getArgs(Value args_) {
  return [args_]([[maybe_unused]] const std::vector<Value>& args) { return args_; };
}

} // namespace

Extern::Extern(int argc, char* argv[]) {
  args_ = 0;

  for (int i = 1; i < argc; i++) {
    auto fields = std::shared_ptr<Value[]> (new Value[3]);
    fields[0] = 1;
    fields[1] = argv[i];
    fields[2] = args_;
    args_ = Record(fields);
  }

  std::unordered_map<std::string,
                     const std::function<Value(const std::vector<Value>&)>>
                     extern_function_table {
    { "helium_readInt", helium_readInt },
    { "helium_readLine", helium_readLine },
    { "helium_printInt", helium_printInt },
    { "helium_printStr", helium_printStr },
    { "helium_stdin", helium_stdin },
    { "helium_stdout", helium_stdout },
    { "helium_stderr", helium_stderr },
    { "helium_input", helium_input },
    { "helium_outputString", helium_outputString },
    { "helium_openIn", helium_openIn },
    { "helium_openOut", helium_openOut },
    { "helium_closeIn", helium_close },
    { "helium_closeOut", helium_close },
    { "helium_appendStr", helium_appendStr },
    { "helium_lengthStr", helium_lengthStr },
    { "helium_substringStr", helium_substringStr },
    { "helium_stringGet", helium_stringGet },
    { "helium_indexStr", helium_indexStr },
    { "helium_string_of_int", helium_stringOfInt },
    { "helium_rawCompareStr", helium_rawCompareStr },
    { "helium_stringRepeat", helium_stringRepeat },
    { "helium_charCode", Id },
    { "helium_charChr", Id },
    { "helium_getArgs", helium_getArgs(args_) }
  };

  extern_function_table_ = extern_function_table;
}


Value Extern::ExternCall(const std::string& name, const std::vector<Value>& args) {
  return extern_function_table_.at(name)(args);
};

} // namespace hvm