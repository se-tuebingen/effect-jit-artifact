@export("iseven") $iseven($y:int) {
    if0 $y:int jump $rett();
    let const $o:int <- 1;
    ($y:int) <- prim[infixSub(Int, Int): Int]($y:int, $o:int);
    let const $libname <- path"$0/libtest_lib.lib";
    push $iseven2($y:int);
    loadlib $libname:str
}
$iseven2($lib:ptr, $y:int) {
    calllib $lib:ptr [isodd] ($y:int)
}
$rett() {
    let const $t:int <- 1;
    return($t:int)
}
@export("$entrypoint") $main() {
    let const $arg:int <- 12;
    jump $iseven($arg:int)
}