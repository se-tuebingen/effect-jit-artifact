$main() {
    push $#UID_1AE();
    $unit:$Unit($unit()) <- $Unit.$unit();
    push $#UID_1AD();
    $unit:$Unit($unit()) <- $Unit.$unit();
    $unit:$Unit($unit()) <- $Unit.$unit();
    $unit:$Unit($unit()) <- $Unit.$unit();
    $unit:$Unit($unit()) <- $Unit.$unit();
    $#UID_189 <- $tuple(4).$make($unit:$Unit($unit()), $unit:$Unit($unit()), $unit:$Unit($unit()), $unit:$Unit($unit()));
    $unit:$Unit($unit()) <- $Unit.$unit();
    push $#UID_1AC();
    $unit:$Unit($unit()) <- $Unit.$unit();
    $unit:$Unit($unit()) <- $Unit.$unit();
    $unit:$Unit($unit()) <- $Unit.$unit();
    $#UID_18A <- $tuple(3).$make($unit:$Unit($unit()), $unit:$Unit($unit()), $unit:$Unit($unit()));
    $unit:$Unit($unit()) <- $Unit.$unit();
    push $#UID_1AB();
    push $#UID_193();
    push $#UID_192();
    let const $#UID_190:int <- 10;
    jump $#UID_155($#UID_190:int)
}

$#UID_1AE() {
    return()
}

$#UID_1AD($#UID_16A) {
    return($#UID_16A)
}

$#UID_1AC($#UID_166) {
    return($#UID_166)
}

$#UID_155($#UID_18E) {
    jump $#UID_18F()
}

$#UID_18F($#UID_15A) {
    return($#UID_15A)
}

$#UID_1AB($#UID_160, $#UID_189, $#UID_18A) {
    $#UID_194 <- $#UID_189:$#UID_195.$make#2;
    $unit:$Unit($unit()) <- $Unit.$unit();
    $#UID_196 <- $#UID_189:$#UID_197.$make#3;
    $unit:$Unit($unit()) <- $Unit.$unit();
    $#UID_198 <- $#UID_18A:$#UID_199.$make#2;
    $unit:$Unit($unit()) <- $Unit.$unit();
    $#UID_19C <- $Fn() {
        $apply => $#UID_19B
    };
    $#UID_19F <- $Fn() {
        $apply => $#UID_19E
    };
    $#UID_1A2 <- $Fn() {
        $apply => $#UID_1A1
    };
    $#UID_1A5 <- $Fn() {
        $apply => $#UID_1A4
    };
    $#UID_1A7 <- $Fn() {
        $apply => $#UID_1A6
    };
    $#UID_1A9 <- $Fn() {
        $apply => $#UID_1A8
    };
    $#UID_1AA <- $tuple(15).$make($unit:$Unit($unit()), $#UID_189, $unit:$Unit($unit()), $unit:$Unit($unit()), $unit:$Unit($unit()), $#UID_18A, $unit:$Unit($unit()), $#UID_19C, $#UID_19F, $#UID_1A2, $unit:$Unit($unit()), $#UID_1A5, $#UID_1A7, $#UID_1A9, $#UID_160);
    return($#UID_1AA)
}

$#UID_19B($l:int, $l:int) {
    ($#UID_19A:int) <- prim[infixLt(Int, Int): Boolean]($l:int, $l:int);
    return($#UID_19A:int)
}

$#UID_19E($l:int, $l:int) {
    ($#UID_19D:int) <- prim[infixAdd(Int, Int): Int]($l:int, $l:int);
    return($#UID_19D:int)
}

$#UID_1A1($l:int, $l:int) {
    ($#UID_1A0:int) <- prim[infixSub(Int, Int): Int]($l:int, $l:int);
    return($#UID_1A0:int)
}

$#UID_1A4($int:int) {
    ($#UID_1A3:str) <- prim[show(Int): String]($int:int);
    return($#UID_1A3:str)
}

$#UID_1A6($what:str) {
    () <- prim[println(String): Unit]($what:str);
    $unit:$Unit($unit()) <- $Unit.$unit();
    return($unit:$Unit($unit()))
}

$#UID_1A8($type parameter:$Unit($unit()), $#UID_18C) {
    jump $#UID_155($#UID_18C)
}

$#UID_193($#UID_15F) {
    () <- prim[println(String): Unit]($#UID_15F);
    return()
}

$#UID_192($#UID_15E) {
    ($#UID_191:str) <- prim[show(Int): String]($#UID_15E);
    return($#UID_191:str)
}
