package rpyeffectasm.util
import scala.collection.mutable

trait Emit[-A] {
  def emit(a: A): Unit
  def emitAll(as: IterableOnce[A]): Unit = {
    for (a <- as) { emit(a) }
  }
}
object Emit {

  def collecting[A, R](body: Emit[A] ?=> R): (List[A], R) = {
    var current = new mutable.ListBuffer[A]()
    val handler = new Emit[A] {
      def emit(a: A) = current.addOne(a)
      override def emitAll(as: IterableOnce[A]) = current.addAll(as)
    }
    val res = body(using handler)
    (current.toList, res)
  }
  def collecting_[A](body: Emit[A] ?=> Unit): List[A] = {
    collecting[A, Unit](body) match {
      case (value, _) => value
    }
  }
  def collectingInto[R, A](buffer: mutable.ListBuffer[A])(body: Emit[A] ?=> R): R = {
    body(using new Emit[A] {
      override def emit(a: A): Unit = buffer.addOne(a)
    })
  }

  def collectingSet[A, R](body: Emit[A] ?=> R): (Set[A], R) = {
    var current = new mutable.HashSet[A]()
    val handler = new Emit[A] {
      def emit(a: A) = current.addOne(a)

      override def emitAll(as: IterableOnce[A]) = current.addAll(as)
    }
    val res = body(using handler)
    (current.toSet, res)
  }

  def collectingSet_[A](body: Emit[A] ?=> Unit): Set[A] = {
    collectingSet[A, Unit](body) match {
      case (value, _) => value
    }
  }

  def folding[A, B, R](init: B)(fn: (B, A) => B)(body: Emit[A] ?=> R): (B, R) = {
    var current = init
    val handler = new Emit[A] {
      def emit(a: A) = current = fn(current, a)
    }
    val res = body(using handler)
    (current, res)
  }
  def folding_[A, B](init: B)(fn: (B, A) => B)(body: Emit[A] ?=> Unit): B = {
    folding[A,B,Unit](init)(fn)(body) match {
      case (res, _) => res
    }
  }

  def withDebugPrint[A,R](body: Emit[A] ?=> R)(using outer: Emit[A]):R = {
    body(using new Emit[A] {
      override def emit(a: A): Unit = {
        println(s"Emitting ${a}")
        outer.emit(a)
      }
    })
  }

  def collectingLast[A,R](body: Emit[A] ?=> R): (Option[A],R) = {
    var l: Option[A] = None
    val r = body(using new Emit[A] {
      override def emit(a: A): Unit = {
        l = Some(a)
      }
    })
    (l,r)
  }

  def withOnEmit[A,R](onEmit: A => Unit)(body: Emit[A] ?=> R)(using outer: Emit[A]): R = {
    body(using new Emit[A] {
      override def emit(a: A): Unit = {
        onEmit(a); outer.emit(a)
      }
    })
  }

  def ignoring[A,R](body: Emit[A] ?=> R): R = {
    body(using new Emit[A] {
      override def emit(a: A): Unit = ()
    })
  }

  def withTransformer[A,B,R](transform: A => B)(body: Emit[A] ?=> R)(using outer: Emit[B]): R = {
    body(using new Emit[A] {
      override def emit(a: A): Unit = {
        outer.emit(transform(a))
      }
    })
  }

  def emit[A, B <: A](a: B)(using e: Emit[A]) = e.emit(a)
  def emitAll[A, B <: A](a: IterableOnce[B])(using e: Emit[A]) = e.emitAll(a)
}