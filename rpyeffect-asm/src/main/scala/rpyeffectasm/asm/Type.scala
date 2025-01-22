package rpyeffectasm
package asm
import rpyeffectasm.common

case class FormatConst(fmt: String, value: String)
type LiteralType = Int | Double | Boolean | String | FormatConst