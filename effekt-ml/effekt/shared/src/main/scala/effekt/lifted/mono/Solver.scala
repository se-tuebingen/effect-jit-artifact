package effekt
package lifted
package mono

import scala.collection.mutable
import effekt.context.Context

// {} <: _ <: { [<>], [<Try>] }
case class Bounds(lower: Set[Evidences], upper: Set[Evidences])

// TODO always add ?main <:< [<>]
//  we could also assume that all functions that do not have bounds, are bounded with [<>]

type Bisubstitution = Map[Evidences.FlowVar, Bounds]

private[mono]
class Node

type Equivalences = Map[FlowType.Function, Node]


case class Solver(
  constraints: List[Constraint],
  seen: Set[Constraint],
  subst: Bisubstitution,
  functions: Equivalences
) {
  def nodeFor(f: FlowType.Function): Node = functions.getOrElse(f, new Node)

  def unify(f1: FlowType.Function, f2: FlowType.Function): Equivalences =
    val rep1 = nodeFor(f1)
    val rep2 = nodeFor(f2)
    // replace all rep2 with rep1
    functions.view.mapValues(n => if n == rep2 then rep1 else n).toMap + (f1 -> rep1) + (f2 -> rep1)

  def step(): Solver = constraints match {
    case head :: tail if seen contains head => Solver(tail, seen, subst, functions)

    case Constraint.B(a, b) :: rest if a == b => Solver(rest, seen, subst, functions)
    case Constraint.E(a, b) :: rest if a == b => Solver(rest, seen, subst, functions)

    case Constraint.B(i1: FlowType.Interface, i2: FlowType.Interface) :: rest =>
      assert(i1.id == i2.id, s"The two interfaces are not the same! ${i1} and ${i2}")
      Solver(rest, seen, subst, functions)

    case (c @ Constraint.B(f1 @ FlowType.Function(ev1, _, _, bparams1, _), f2 @ FlowType.Function(ev2, _, _, bparams2, _))) :: rest =>
      val evidenceFlow = Constraint.E(ev1, ev2)
      val paramsFlow = bparams2.zip(bparams1).map { case (c2, c1) => Constraint.B(c2, c1) }
      Solver(evidenceFlow :: paramsFlow ++ rest, seen + c, subst, unify(f1, f2))

    case Constraint.E(Evidences.Concrete(evs1), Evidences.Concrete(evs2)) :: rest =>
      Solver(rest, seen, subst, functions)

    case (c @ Constraint.E(x: Evidences.FlowVar, y)) :: rest =>
      val xbounds = subst.getOrElse(x, Bounds(Set.empty, Set.empty))
      Solver(xbounds.lower.map(Constraint.E(_, y)).toList ++ rest, seen + c, subst + (x -> Bounds(xbounds.lower, xbounds.upper + y)), functions)

    case (c @ Constraint.E(x, y: Evidences.FlowVar)) :: rest =>
      val ybounds = subst.getOrElse(y, Bounds(Set.empty, Set.empty))
      Solver(ybounds.upper.map(Constraint.E(x, _)).toList ++ rest, seen + c, subst + (y -> Bounds(ybounds.lower + x, ybounds.upper)), functions)

    case c :: rest =>
      sys error s"Mismatch: ${c}"

    case Nil => this
  }
}

// by eta-reducing constraints, we can see that <α._0,α._1> = α (which is allowed in recursive functions;
//   only stackshape-polymorphic recursion is forbidden)
def etaReduce(ev: Evidences): Evidences = ev match {
  case x: Evidences.FlowVar => x
  case Evidences.Concrete(Ev(Lift.Var(x, 0) :: Nil) :: rest) if allEta(rest, x, 1) => x
  case _ => ev
}

def allEta(evs: List[Ev], variable: Evidences.FlowVar, index: Int): Boolean =
  evs match {
    case Nil => index == variable.arity
    case Ev(Lift.Var(`variable`, `index`) :: Nil) :: rest => allEta(rest, variable, index + 1)
    case _ => false
  }


def freeVars(b: Bounds): Set[Evidences.FlowVar] = b.upper.flatMap(freeVars) ++ b.lower.flatMap(freeVars)

def freeVars(l: Lift): Set[Evidences.FlowVar] = l match {
  case Lift.Var(x, selector) => Set(x)
  case _ => Set.empty
}

def freeVars(ev: Ev): Set[Evidences.FlowVar] = ev.lifts.toSet.flatMap(freeVars)
def freeVars(evs: Evidences): Set[Evidences.FlowVar] = evs match {
  case Evidences.Concrete(evs) => evs.toSet.flatMap(freeVars)
  case x : Evidences.FlowVar => Set(x)
}

def solve(cs: List[Constraint]): (Map[Evidences.FlowVar, Bounds], Equivalences) =
  var solver = Solver(cs, Set.empty, Map.empty, Map.empty)
  while (solver.constraints.nonEmpty) {
    solver = solver.step()
  }
  (solver.subst, solver.functions)


// A very naive implementation, that is quadratic in the number of unification variables
// it also does not detect "stack shape polymorphic recursion", which needs to be implemented separately.
def substitution(from: List[(Evidences.FlowVar, Bounds)]): Bisubstitution = from match {
  case (x, bounds) :: rest =>
    val subst = substitution(rest)
    val updatedBounds = Substitution(subst).substitute(bounds)
    substitute(x, updatedBounds, subst) + (x -> updatedBounds)
  case Nil => Map.empty
}

def substitute(x: Evidences.FlowVar, bounds: Bounds, into: Bisubstitution): Bisubstitution =
  into.map { case (y, ybounds) => y -> substitute(x, bounds, ybounds) }

def substitute(x: Evidences.FlowVar, bounds: Bounds, into: Bounds): Bounds =
  Bounds(substitute(x, bounds.lower, into.lower), substitute(x, bounds.upper, into.upper))

def substitute(x: Evidences.FlowVar, choices: Set[Evidences], into: Set[Evidences]): Set[Evidences] =
  into.flatMap(evs => substitute(x, choices, evs))

// [<>, <a1.0>] [a1 !-> { [<>], [<Try>] }]  =  [<>, <>],  [<>, <Try>]
def substitute(x: Evidences.FlowVar, choices: Set[Evidences], into: Evidences): Set[Evidences] = into match {
  case Evidences.Concrete(evs) => choices.map { c =>
    Evidences.Concrete(evs.map { ev => substituteSingleChoice(x, c, ev) })
  }
  case y : Evidences.FlowVar if x == y => choices
  case y : Evidences.FlowVar => Set(y)
}

// <Try, ?a.0>[?a !-> [<Try>, <>]]  = <Try, <Try>> = <Try, Try>
def substituteSingleChoice(x: Evidences.FlowVar, ev: Evidences, into: Ev): Ev =
  Ev(into.lifts.flatMap(l => substituteSingleChoice(x, ev, l)))

def substituteSingleChoice(x: Evidences.FlowVar, ev: Evidences, into: Lift): List[Lift] = into match {
  case Lift.Var(y, selector) if x == y => ev match {
    case Evidences.Concrete(evs) => evs(selector).lifts
    case z : Evidences.FlowVar => List(Lift.Var(z, selector))
  }
  case other => List(other)
}

// Parallel substitution
// TODO we probably do not need to substitute into the lower bounds, since we never use them.
class Substitution(subst: Bisubstitution) {

  def substitute(into: Bisubstitution): Bisubstitution =
    into.map { case (y, ybounds) => y -> substitute(ybounds) }

  def substitute(into: Bounds): Bounds =
    Bounds(substitute(into.lower, false), substitute(into.upper, true))

  def substitute(into: Set[Evidences], upper: Boolean): Set[Evidences] =
    into.flatMap(evs => substitute(evs, upper))

  // [<>, <a1.0>] [a1 !-> { [<>], [<Try>] }]  =  [<>, <>],  [<>, <Try>]
  def substitute(into: Evidences, upper: Boolean): Set[Evidences] = into match {
    case Evidences.Concrete(evs) =>
      val free = freeVars(into)
      val defined = free intersect subst.keySet
      var result = Set(evs)
      // now we have to apply all substitutions
      defined.foreach { x =>
        val bounds = if (upper) subst(x).upper else subst(x).lower
        result = for {
          choice <- bounds
          evs <- result
        } yield evs.map(ev => substituteSingleChoice(x, choice, ev))
      }
      result.map(Evidences.Concrete.apply)

    case y : Evidences.FlowVar if subst.isDefinedAt(y) =>
      if (upper) subst(y).upper else subst(y).lower
    case y : Evidences.FlowVar => Set(y)
  }
}


def isZero(evs: Evidences): Boolean = evs match {
  case Evidences.Concrete(evs) => evs.forall(ev => ev.lifts.isEmpty)
  case Evidences.FlowVar(id, arity,origin) => true
}

// post processing step: drop all bounds that still mention unification variables
// we drop all bindings for unification variables with empty bounds or ONLY zero evidence
def cleanup(subst: Bisubstitution): Bisubstitution = subst.map {
  case (x, Bounds(lower, upper)) =>
    x -> Bounds(lower.filter(e => freeVars(e).isEmpty), upper.filter(e => freeVars(e).isEmpty))
} filterNot {
  case (x, Bounds(lower, upper)) => lower.forall(isZero) && upper.forall(isZero)
}

def checkPolymorphicRecursion(subst: Bisubstitution)(using C: Context): Unit = subst foreach {
  case (x, Bounds(lower, upper)) => (lower ++ upper).foreach { bound =>
    import effekt.symbols.ErrorMessageInterpolator

    if refersNonTriviallyTo(bound, x) then
      C.abort(pp"Effect polymorphic recursion is not allowed. The following definition is effect polymorphic since unification variable ${x.show} occurs in instantiation ${bound.show}. All bounds: ${upper.map(_.show)}\n\n${x.origin}")
  }
}


// it is only problematic if the recursive call occurs under a handler (so a direct recursion is ok)
// we also need to allow something like ?a <: [<?a._0>, <>] (see test `features/adt.md`)
// so probably the only thing we want to rule out is to have ?a show up in a non-empty composition!
def refersNonTriviallyTo(bound: Evidences, variable: Evidences.FlowVar): Boolean = bound match {
  case Evidences.Concrete(evs) => evs.exists {
    case Ev(evs) =>
      // only variables are fine, e.g. <?a._1, ?b._2>
      // reasoning: all concrete bounds have already been propagated, dropping variables is thus fine.
      val onlyVariables = evs.forall(isVariable)

      // as soon as we have both variables and concrete bounds, this gives rise to infinite
      // effect polymorphic recursion.
      // e.g. <Try, ?a._1>
      val isMentioned = evs.flatMap(freeVars) contains variable

      isMentioned && !onlyVariables
  }
  case Evidences.FlowVar(id, arity, origin) => false
}

def isVariable(l: Lift): Boolean = l match {
  case Lift.Try() => false
  case Lift.Reg() => false
  case Lift.Var(x, selector) => true
}
