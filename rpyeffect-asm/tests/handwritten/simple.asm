@export("$entrypoint") $main() {
    let const $s:str <- "Hallo Welt!";
    ($tmp473:ptr) <- prim[println(String): Unit]($s:str);
    return($tmp473:$Unit($unit()))
}
