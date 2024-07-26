(* Lang/Explicit.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
include Kind.Impl
include CoreCommon.CoreTypes.Impl
include CoreCommon.TypeDef.Impl
include CoreCommon.Unit.Impl
include ExplicitPriv.Syntax

module Coercion = ExplicitPriv.Coercion
module Pattern  = ExplicitPriv.Pattern

module SExprPrinter = struct
  include CoreCommon.SExprPrinter
end

let flow_node = Flow.Node.create
  ~cmd_line_flag: "-explicit"
  "Explicit"
