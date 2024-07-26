module main

effect ctl emit( i : int ) : ()
effect ctl pred( i : int ) : bool

fun unfaithful_sieve(start : int, end: int): <div,emit,pred,console> ()
    if (start >= end) then ()
    else
        if(pred(start)) {
            emit(start);
            with ctl pred(i)
                if(i % start == 0){
                    resume(False)
                } else { resume(pred(i)) }
            unfaithful_sieve(start+1, end)
        } else {
            unfaithful_sieve(start+1, end)
        }

fun summing(f : () -> <emit|e> ()): e int
    (handler
        return(_) 0
        ctl emit(i) { i + resume(())}
    ){
        f()
    }

val all = handler
    ctl pred(i) resume(True)

pub fun main()
    val r = {
      summing{
        with all
        sieve(2,2000)
      }
    }
    println(r)