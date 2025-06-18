/*---------------------------------------------------------------------------
  Copyright 2020-2021, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

static kk_std_core_types__tuple2 kk_timer_ticks_tuple(kk_context_t* ctx) {
  kk_duration_t d = kk_timer_ticks(ctx);
  // the conversion has about 15 digits of precision
  // we cannot do this more precisely as the api expects the fraction between 0.0 and 2.0 (for leap seconds).
  double secs = (double)d.seconds;
  double frac = (double)d.attoseconds * 1e-18;
  return kk_std_core_types__new_Tuple2( kk_double_box(secs,ctx), kk_double_box(frac,ctx), ctx );
}

static double kk_timer_dresolution(kk_context_t* ctx) {
  int64_t asecs = kk_timer_resolution(ctx);
  return (double)asecs * 1e-18;
}
