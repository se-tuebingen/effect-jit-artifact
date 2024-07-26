extern doprint(s : string) : ()
  vm "println(String): Unit"
extern doadd(x: string, y: string) : string
  vm "infixConcat(String, String): String"

pub fun main()
  doprint(doadd("Hallo", " Welt!"))
  
