(** This file provides pretty-printing functions for Unif types in Surface-like
 syntax. This is not trivial task, since representation of Unif types is
 different due to first class modules: in Surface there are no sharp
 distinction between types and expressions, while the Unif is stratified
 between kinds, type constructors and expressions. The most problematic are
 type variables: they are implicit, but can be reflected in Surface
 expressions of singleton type (...Wit or ...Def types in Unif). So to
 pretty-print type variable, printer at first search for variable of a type,
 that describes given type variable using appropriate singleton type. Such a
 variable may not exist, so then printer search for a structure with a field
 of desired type or structure type with a field of singleton type or a
 structure ... and so on. *)

type env = UnifPriv.Env.t

module Env = UnifPriv.Env

let pretty_type ?(toplevel=true) env prec tp =
  match Settings.get_type_printer () with
  | `Surface ->
    UnifPriv.Surface.pretty_type ~toplevel env prec tp
  | `Semantic ->
    failwith "Not implemented"
  | `SExpr ->
    Lang.Unif.Type.to_sexpr tp |> SExpr.pretty

let pretty_ex_type ?(toplevel=true) env prec extp =
  match Settings.get_type_printer () with
  | `Surface ->
    UnifPriv.Surface.pretty_ex_type ~toplevel env prec extp
  | `Semantic ->
    failwith "Not implemented"
  | `SExpr ->
    Lang.Unif.ExType.to_sexpr extp |> SExpr.pretty

let pretty_row env eff =
  match Settings.get_type_printer () with
  | `Surface ->
    UnifPriv.Surface.pretty_row env eff
  | `Semantic ->
    failwith "Not implemented"
  | `SExpr ->
    Lang.Unif.Type.to_sexpr eff |> SExpr.pretty
