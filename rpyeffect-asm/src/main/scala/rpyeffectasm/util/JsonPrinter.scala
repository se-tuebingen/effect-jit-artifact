package rpyeffectasm
package util

trait JsonPrinter {
  // FIXME shims for not depending on kiama
  // --------------------------------------
  type Doc = String // FIXME for now
  type Document = Doc // FIXME for now
  def pretty(d: Doc): Document = d

  extension(d: Doc) {
    def <+>(o: Doc) = d ++ o
  }

  def braces(d: Doc): Doc = "{" ++ d ++ "}"
  def brackets(d: Doc): Doc = "[" ++ d ++ "]"
  def dquotes(d: Doc): Doc = "\"" ++ d ++ "\""
  def hsep(d: Iterable[Doc], s: Doc) = if d.isEmpty then "" else d.reduce { (x,y) => x ++ s ++ y }
  def vsep(d: Iterable[Doc], s: Doc) = if d.isEmpty then "" else d.reduce { (x,y) => x ++ s ++ "\n" ++ y }

  // Utilities for json
  // ------------------
  def jsonObject(fields: Map[String, Doc]): Doc = {
    braces(
      vsep(fields.map({case (k, v) => dquotes(k) <+> ":" <+> v}).toSeq, ","))
  }
  def jsonList(elems: List[Doc]): Doc = {
    brackets(
      vsep(elems, ","))
  }
  def jsonObjectSmall(fields: Map[String, Doc]): Doc = {
    braces(hsep(fields.map({case (k,v)=> dquotes(k) <+> ":" <+> v}).toSeq, ","))
  }
  def jsonListSmall(elems: List[Doc]): Doc = {
    brackets(hsep(elems, ","))
  }

  def jsonString(s: String): String = s"\"${util.escape(s)}\""
}
object JsonPrinter extends JsonPrinter