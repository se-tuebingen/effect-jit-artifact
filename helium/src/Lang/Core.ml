(* Lang/Core.ml
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
include CorePriv.Syntax

module Syntax = CorePriv.SyntaxOps
module SExprPrinter = struct
  include CoreCommon.SExprPrinter
  include CorePriv.SExprPrinter
end

let flow_node = Flow.Node.create
  ~cmd_line_flag: "-core"
  "Core"

let _ : Flow.tag =
  Flow.register_transform
    ~provides_tags: [ CommonTags.pretty ]
    ~source: flow_node
    ~target: SExpr.flow_node
    ~name:   "Core --> SExpr (pretty printer)"
    (fun file _ -> Flow.return (CorePriv.SExprPrinter.tr_source_file file))

let print_expr e = Box.print_stdout (SExpr.pretty (CorePriv.SExprPrinter.tr_expr e))