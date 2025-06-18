/*---------------------------------------------------------------------------
  Copyright 2020-2021, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

static kk_std_core_exn__error kk_os_read_text_file_error( kk_string_t path, kk_context_t* ctx ) {
  kk_string_t content;
  const int err = kk_os_read_text_file(path,&content,ctx);
  if (err != 0) return kk_error_from_errno(err,ctx);
           else return kk_error_ok(kk_string_box(content),ctx);
}

static kk_std_core_exn__error kk_os_write_text_file_error( kk_string_t path, kk_string_t content, kk_context_t* ctx ) {
  const int err = kk_os_write_text_file(path,content,ctx);
  if (err != 0) return kk_error_from_errno(err,ctx);
           else return kk_error_ok(kk_unit_box(kk_Unit),ctx);
}
