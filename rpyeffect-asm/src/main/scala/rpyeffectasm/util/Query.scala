package rpyeffectasm.util

case class Query[T](base: T, combine: Iterable[T] => T)(fn: PartialFunction[Any, T]) {

  def apply(t: Any): T = t match {
    case t if fn.isDefinedAt(t) => fn(t)
    case x: Iterable[_] => combine(x.map(apply))
    case p: Product => combine(p.productIterator.map(apply).toList)
    case _ => base
  }

}
