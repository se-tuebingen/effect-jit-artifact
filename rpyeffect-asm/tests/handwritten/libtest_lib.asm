@export("isodd") $isodd($x:int) {
    if0 $x:int jump $retf();
    let const $o:int <- 1;
    ($x:int) <- prim[infixSub(Int, Int): Int]($x:int, $o:int);
    let const $libname <- path"$0/libtest_main.exe";
    push $isodd2($x:int);
    loadlib $libname:str
}
$isodd2($lib:ptr, $x:int) {
    calllib $lib:ptr [iseven] ($x:int)
}
$retf() {
    let const $f:int <- 0;
    return($f:int)
}