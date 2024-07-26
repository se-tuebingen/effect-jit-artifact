%token<string> LID UID TLID BTLID
%token<string> OP_0 OP_20 OP_30 OP_40 OP_50 OP_60 OP_70 OP_80 OP_90 OP_100
%token<string> OP_250
%token<int> NUM
%token<string> STR
%token<char> CHR
%token BR_OPN BR_CLS SBR_OPN SBR_CLS CBR_OPN CBR_CLS
%token ARROW ARROW2 BACKTICK BAR BTSTAR COLON COMMA DOT EQ SEMICOLON
%token SEMICOLON2 SLASH
%token UNDERSCORE
%token KW_AND KW_BEGIN KW_DATA KW_EFFECT KW_ELIF KW_ELSE KW_END KW_EXPORT
%token KW_EXTERN KW_FINALLY KW_FN KW_FORALL KW_HANDLE KW_HANDLER KW_IF
%token KW_IMPORT KW_IN KW_INCLUDE KW_LET KW_MATCH KW_MODULE KW_OF KW_OPEN
%token KW_REC KW_RETURN KW_SIG KW_SIGNATURE KW_STRUCT KW_THEN KW_THIS KW_TYPE
%token KW_VAL KW_WITH
%token UKW_EFFECT UKW_SIG UKW_TYPE
%token EOF

%type<Lang.Raw.file> file
%start file

%type<Lang.Raw.intf_file> intf_file
%start intf_file

%type<Lang.Raw.repl_cmd> repl_cmd
%start repl_cmd

%{

open Lang.Node
open Lang.Raw

let current_pos () =
  Utils.Position.of_pp
    (Parsing.symbol_start_pos ())
    (Parsing.symbol_end_pos ())

let make data =
  { meta = current_pos ()
  ; data = data
  }

%}

%%

file
: preamble_decl_list def_list EOF {
    { sf_pos      = current_pos ()
    ; sf_preamble = $1
    ; sf_defs     = $2
    }
  }
;

intf_file
: preamble_decl_list decl_list EOF {
    { if_pos      = current_pos ()
    ; if_preamble = $1
    ; if_decls    = $2
    }
  }
;

repl_cmd
: expr SEMICOLON2         { make (ReplExpr   $1) }
| def  SEMICOLON2         { make (ReplDef    $1) }
| KW_IMPORT id SEMICOLON2 { make (ReplImport $2) }
| EOF                     { make ReplExit        }
;

/* ========================================================================= */
/* preamble */

preamble_decl
: KW_IMPORT id                           { make (PDImport $2)  }
| KW_EXPORT KW_HANDLER KW_OF effect_expr { make (PDHandler $4) }
;

preamble_decl_list
: /* empty */                      { []       }
| preamble_decl preamble_decl_list { $1 :: $2 }
;

/* ========================================================================= */
/* identifiers */

id
: LID { $1 }
| UID { $1 }
;

lname
: KW_THIS              { make NameThis              }
| LID                  { make (NameLVar  $1)        }
| BR_OPN op BR_CLS     { make (NameOper  ($2).data) }
| BR_OPN op DOT BR_CLS { make (NameUOper ($2).data) }
;

name_no_sbr
: lname         { $1                 }
| BR_OPN BR_CLS { make NameUnit      }
| UID           { make (NameUVar $1) }
;

name
: name_no_sbr     { $1           }
| SBR_OPN SBR_CLS { make NameNil }
;

ctor_name_no_op
: BR_OPN BR_CLS    { make CNUnit }
| SBR_OPN SBR_CLS  { make CNNil  }
| UID              { make (CNName $1) }
;

ctor_name
: ctor_name_no_op  { $1 }
| BR_OPN op BR_CLS { make (CNOper ($2).data) }
;

str
: STR { make $1 }
;

name_list_1
: name { [ $1 ] }
| name name_list_1 { $1 :: $2 }
;

large_mod
: KW_TYPE   { () }
| KW_EFFECT { () }
| KW_MODULE { () }
;

/* ========================================================================= */
/* operators */

op_0
: OP_0      { make $1  }
| SEMICOLON { make ";" }
;

op_20
: OP_20 { make $1 }
;

op_30
: OP_30 { make $1  }
| COMMA { make "," }
;

op_40
: OP_40 { make $1 }
;

op_50
: OP_50 { make $1 }
;

op_60
: OP_60 { make $1  }
| EQ    { make "=" }
;

op_60_no_eq
: OP_60 { make $1 }
;

op_70
: OP_70 { make $1 }
;

op_80
: OP_80 { make $1 }
;

op_90
: OP_90 { make $1  }
| SLASH { make "/" }
;

op_100
: OP_100 { make $1 }
;

uop_150
: OP_80 { make $1 }
;

uop_250
: OP_250 { make $1 }
;

op
: op_0   { $1 }
| op_20  { $1 }
| op_30  { $1 }
| op_40  { $1 }
| op_50  { $1 }
| op_60  { $1 }
| op_70  { $1 }
| op_80  { $1 }
| op_90  { $1 }
| op_100 { $1 }
| OP_250 { make $1 }
;

/* ========================================================================= */
/* paths */

path
: name                            { make (PathName $1)     }
| BR_OPN expr_300 DOT name BR_CLS { make (PathSel($2, $4)) }
;

/* ========================================================================= */
/* patterns */

pattern
: pattern_0 { $1 }
;

pattern_no_eq
: pattern_0_no_eq { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_0
: pattern_10 op_0 pattern_0 { make (PBOp($1, $2, $3)) }
| pattern_10 { $1 }
;

pattern_0_no_eq
: pattern_10_no_eq op_0 pattern_0_no_eq { make (PBOp($1, $2, $3)) }
| pattern_10_no_eq { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_10 
: pattern_20 { $1 }
;

pattern_10_no_eq
: pattern_20_no_eq { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_20
: pattern_30 op_20 pattern_20 { make (PBOp($1, $2, $3)) }
| pattern_30 { $1 }
;

pattern_20_no_eq
: pattern_30_no_eq op_20 pattern_20_no_eq { make (PBOp($1, $2, $3)) }
| pattern_30_no_eq { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_30
: pattern_30 COLON expr_40    { make (PAnnot($1, $3))   }
| pattern_30 op_30 pattern_40 { make (PBOp($1, $2, $3)) }
| pattern_40 { $1 }
;

pattern_30_no_eq
: pattern_30_no_eq COLON expr_40_no_eq    { make (PAnnot($1, $3))   }
| pattern_30_no_eq op_30 pattern_40_no_eq { make (PBOp($1, $2, $3)) }
| pattern_40_no_eq { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_40
: pattern_50 op_40 pattern_40 { make (PBOp($1, $2, $3)) }
| pattern_50 { $1 }
;

pattern_40_no_eq
: pattern_50_no_eq op_40 pattern_40_no_eq { make (PBOp($1, $2, $3)) }
| pattern_50_no_eq { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_50
: pattern_60 op_50 pattern_50 { make (PBOp($1, $2, $3)) }
| pattern_60 { $1 }
;

pattern_50_no_eq
: pattern_60_no_eq op_50 pattern_50_no_eq { make (PBOp($1, $2, $3)) }
| pattern_60_no_eq { $1 }
;

pattern_list_comma_sep
: pattern_50 { [ $1 ] }
| pattern_50 COMMA pattern_list_comma_sep { $1 :: $3 }
;

/* ------------------------------------------------------------------------- */

pattern_60
: pattern_60 op_60 pattern_70 { make (PBOp($1, $2, $3)) }
| pattern_70 { $1 }
;

pattern_60_no_eq
: pattern_60_no_eq op_60_no_eq pattern_70 { make (PBOp($1, $2, $3)) }
| pattern_70 { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_70
: pattern_80 op_70 pattern_70 { make (PBOp($1, $2, $3)) }
| pattern_80 { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_80
: pattern_80 op_80 pattern_90 { make (PBOp($1, $2, $3)) }
| pattern_90 { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_90
: pattern_90 op_90 pattern_100 { make (PBOp($1, $2, $3)) }
| pattern_100 { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_100
: pattern_200 op_100 pattern_100 { make (PBOp($1, $2, $3)) }
| pattern_200 { $1 }
;

/* ------------------------------------------------------------------------- */

pattern_200
: pattern_simpl                  { $1 }
| ctor_path pattern_simpl_list_1 { make (PCtor($1, $2)) }
| large_mod name                 { make (PName $2)      }
;

/* ------------------------------------------------------------------------- */

ctor_path
: ctor_name_no_op         { make(CPName $1)      }
| path_expr DOT ctor_name { make(CPPath($1, $3)) }
;

/* ------------------------------------------------------------------------- */

pattern_simpl
: BR_OPN pattern BR_CLS                  { make ($2).data       }
| lname                                  { make (PName $1 )     }
| UNDERSCORE                             { make PWildcard       }
| SBR_OPN pattern_list_comma_sep SBR_CLS { make (PList $2)      }
| ctor_path                              { make (PCtor($1, [])) }
| CBR_OPN field_patterns CBR_CLS 
    { let (pats, closed) = $2 in make (PRecord(pats, closed)) }
;

pattern_simpl_list
: /* empty */                      { []       }
| pattern_simpl pattern_simpl_list { $1 :: $2 }
;

pattern_simpl_list_1
: pattern_simpl pattern_simpl_list { $1 :: $2 }
;

/* ========================================================================= */
/* field patterns */

field_pattern
: name EQ pattern_10               { make (FPatName($1, $3))    }
| path_expr DOT name EQ pattern_10 { make (FPatSel($1, $3, $5)) }
;

field_patterns
: UNDERSCORE    { ([], false)  }
| field_pattern { ([$1], true) }
| field_pattern SEMICOLON field_patterns
    { let (pats, closed) = $3 in ($1 :: pats, closed) }
;

/* ========================================================================= */
/* instance patterns */

inst_pattern
: inst_pattern COLON expr_40 { make (IPAnnot($1, $3)) }
| inst_pattern_simpl         { $1 }
;

inst_pattern_simpl
: BTLID                                              { make (IPVar $1)   }
| BACKTICK BR_OPN BR_CLS                             { make (IPTuple []) }
| BACKTICK BR_OPN inst_pattern_list_comma_sep BR_CLS { make (IPTuple $3) }
;

inst_pattern_list_comma_sep
: inst_pattern { [ $1 ] }
| inst_pattern COMMA inst_pattern_list_comma_sep { $1 :: $3 }
;

inst_pattern_simpl_list_1
: inst_pattern_simpl { [ $1 ] }
| inst_pattern_simpl inst_pattern_simpl_list_1 { $1 :: $2 }
;

/* ========================================================================= */
/* formal arguments */

farg
: pattern_simpl       { make (FArgPattern $1)      }
| inst_pattern_simpl  { make (FArgExplicitInst $1) }
| BR_OPN inst_pattern_simpl_list_1 COLON expr_40 BR_CLS
    { make (FArgExplicitInstAnnot($2, $4)) }
| CBR_OPN inst_pattern CBR_CLS { make (FArgImplicitInst $2) }
| CBR_OPN name_list_1 COLON expr_40 CBR_CLS
    { make (FArgImplicit($2, $4)) }
;

farg_list_1
: farg             { [ $1 ]   }
| farg farg_list_1 { $1 :: $2 }
;

/* ========================================================================= */
/* type formal arguments */

type_farg
: name               { make (FArgName $1)         }
| inst_pattern_simpl { make (FArgExplicitInst $1) }
| BR_OPN name_list_1 COLON expr_40 BR_CLS
    { make (FArgNamesAnnot($2, $4)) }
| BR_OPN inst_pattern_simpl_list_1 COLON expr_40 BR_CLS
    { make (FArgExplicitInstAnnot($2, $4)) }
| BR_OPN KW_VAL pattern BR_CLS { make (FArgPattern $3) }
| CBR_OPN inst_pattern CBR_CLS { make (FArgImplicitInst $2) }
| CBR_OPN name_list_1 COLON expr_40 CBR_CLS
    { make (FArgImplicit($2, $4)) }
;

type_farg_list
: /* empty */ { [] }
| type_farg type_farg_list { $1 :: $2 }
;

/* ========================================================================= */
/* arrow arguments */

safe_arrow_arg
: BR_OPN inst_pattern_simpl_list_1 COLON expr_40 BR_CLS
  { make (AAExplicitInstAnnot($2, $4)) }
| CBR_OPN inst_pattern CBR_CLS              { make (AAImplicitInst $2)  }
| CBR_OPN name_list_1 COLON expr_40 CBR_CLS { make (AAImplicit($2, $4)) }
;

forall_arg
: safe_arrow_arg { $1 }
| inst_pattern_simpl { make (AAExplicitInst $1) }
| BR_OPN name_list_1 COLON expr_40 BR_CLS
  { make (AANames($2, $4)) }
;

forall_arg_list_1
: forall_arg                   { [ $1 ]   }
| forall_arg forall_arg_list_1 { $1 :: $2 }
;

arrow_arg
: safe_arrow_arg              { [ $1 ]               }
| expr_50                     { [ make (AAType $1) ] }
| KW_FORALL forall_arg_list_1 { $2                   }

arrow_args
: arrow_arg                  { $1      }
| arrow_arg COMMA arrow_args { $1 @ $3 }
;

arrow_args_safe
: safe_arrow_arg                  { [ $1 ]               }
| expr_50                         { [ make (AAType $1) ] }
| safe_arrow_arg COMMA arrow_args { $1 :: $3             }
| KW_FORALL forall_arg_list_1     { $2                   }
| KW_FORALL forall_arg_list_1 COMMA arrow_args { $2 @ $4 }
;

arrow_args_safe_no_sbr
: safe_arrow_arg                  { [ $1 ]               }
| expr_50_no_sbr                  { [ make (AAType $1) ] }
| safe_arrow_arg COMMA arrow_args { $1 :: $3             }
| KW_FORALL forall_arg_list_1     { $2                   }
| KW_FORALL forall_arg_list_1 COMMA arrow_args { $2 @ $4 }
;

arrow_args_safe_no_eq
: safe_arrow_arg                  { [ $1 ]               }
| expr_50_no_eq                   { [ make (AAType $1) ] }
| safe_arrow_arg COMMA arrow_args { $1 :: $3             }
| KW_FORALL forall_arg_list_1     { $2                   }
| KW_FORALL forall_arg_list_1 COMMA arrow_args { $2 @ $4 }
;

arrow_args_safe_no_eq_sbr
: safe_arrow_arg                  { [ $1 ]               }
| expr_50_no_eq_sbr               { [ make (AAType $1) ] }
| safe_arrow_arg COMMA arrow_args { $1 :: $3             }
| KW_FORALL forall_arg_list_1     { $2                   }
| KW_FORALL forall_arg_list_1 COMMA arrow_args { $2 @ $4 }
;

/* ========================================================================= */
/* expressions */

expr
: expr_0 { $1 }
;

expr_no_sbr
: expr_0_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_0
: KW_FN farg_list_1 ARROW2 expr_0 { make (EFn($2, $4))      }
| def_list_1 KW_IN expr_0         { make (EDefs($1, $3))    }
| expr_10 op_0 expr_0             { make (EBOp($1, $2, $3)) }
| expr_10                         { $1 }
;

expr_0_no_sbr
: KW_FN farg_list_1 ARROW2 expr_0 { make (EFn($2, $4))      }
| def_list_1 KW_IN expr_0         { make (EDefs($1, $3))    }
| expr_10_no_sbr op_0 expr_0      { make (EBOp($1, $2, $3)) }
| expr_10_no_sbr                  { $1 }
;

/* ------------------------------------------------------------------------- */

expr_10 
: expr_10_main { $1 }
| expr_20      { $1 }
;

expr_10_no_sbr
: expr_10_main   { $1 }
| expr_20_no_sbr { $1 }
;

expr_10_main
: KW_IF expr KW_THEN expr_10 { make (EUIf($2, $4)) }
| KW_IF expr KW_THEN expr_10_with_else else_expr { make (EIf($2, $4, $5)) }
| KW_HANDLE handler_inst_opt expr KW_WITH expr_10
    { make (EHandleWith($2, $3, $5)) }
;

expr_10_with_else
: KW_IF expr KW_THEN expr_10_with_else else_expr_with_else
    { make (EIf($2, $4, $5)) }
| KW_HANDLE handler_inst_opt expr KW_WITH expr_10_with_else
    { make (EHandleWith($2, $3, $5)) }
| expr_20 { $1 }
;

else_expr
: KW_ELIF expr KW_THEN expr_10 { make (EUIf($2, $4)) }
| KW_ELIF expr KW_THEN expr_10_with_else else_expr { make (EIf($2, $4, $5)) }
| KW_ELSE expr_10 { $2 }
;

else_expr_with_else
: KW_ELIF expr KW_THEN expr_10_with_else else_expr_with_else
    { make (EIf($2, $4, $5)) }
| KW_ELSE expr_10_with_else { $2 }
;

handler_inst_opt
: /* empty */        { None    }
| inst_pattern KW_IN { Some $1 }
;

/* ------------------------------------------------------------------------- */

expr_20
: expr_30 op_20 expr_20 { make (EBOp($1, $2, $3)) }
| expr_30 { $1 }
;

expr_20_no_sbr
: expr_30_no_sbr op_20 expr_20 { make (EBOp($1, $2, $3)) }
| expr_30_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_30
: expr_30 COLON expr_40_no_sbr     { make (ETypeAnnot($1, $3))        }
| expr_30 COLON effect_row expr_40 { make (ETypeEffAnnot($1, $4, $3)) }
| expr_30 op_30 expr_40 { make (EBOp($1, $2, $3)) }
| expr_40 { $1 }
;

expr_30_no_sbr
: expr_30_no_sbr COLON expr_40_no_sbr     { make (ETypeAnnot($1, $3))        }
| expr_30_no_sbr COLON effect_row expr_40 { make (ETypeEffAnnot($1, $4, $3)) }
| expr_30_no_sbr op_30 expr_40 { make (EBOp($1, $2, $3)) }
| expr_40_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_40
: arrow_args_safe ARROW expr_40_no_sbr     { make (EArrowPure($1, $3))    }
| arrow_args_safe ARROW effect_row expr_40 { make (EArrowEff($1, $4, $3)) }
| KW_HANDLER KW_OF expr KW_IN eff_expr_50 ARROW2 eff_expr_40
  { let (eff1, tp1) = $5 in
    let (eff2, tp2) = $7 in
    make (EHandlerType($3, tp1, eff1, tp2, eff2)) }
| expr_50 op_40 expr_40 { make (EBOp($1, $2, $3)) }
| expr_50 { $1 }
;

expr_40_no_sbr
: arrow_args_safe_no_sbr ARROW expr_40_no_sbr    
  { make (EArrowPure($1, $3))    }
| arrow_args_safe_no_sbr ARROW effect_row expr_40
  { make (EArrowEff($1, $4, $3)) }
| KW_HANDLER KW_OF expr KW_IN eff_expr_50 ARROW2 eff_expr_40
  { let (eff1, tp1) = $5 in
    let (eff2, tp2) = $7 in
    make (EHandlerType($3, tp1, eff1, tp2, eff2)) }
| expr_50_no_sbr op_40 expr_40 { make (EBOp($1, $2, $3)) }
| expr_50_no_sbr { $1 }
;

expr_40_no_eq
: arrow_args_safe_no_eq ARROW expr_40_no_eq_sbr       
  { make (EArrowPure($1, $3))    }
| arrow_args_safe_no_eq ARROW effect_row expr_40_no_eq
  { make (EArrowEff($1, $4, $3)) }
| KW_HANDLER KW_OF expr KW_IN eff_expr_50 ARROW2 eff_expr_40_no_eq
  { let (eff1, tp1) = $5 in
    let (eff2, tp2) = $7 in
    make (EHandlerType($3, tp1, eff1, tp2, eff2)) }
| expr_50_no_eq op_40 expr_40_no_eq { make (EBOp($1, $2, $3)) }
| expr_50_no_eq { $1 }
;

expr_40_no_eq_sbr
: arrow_args_safe_no_eq_sbr ARROW expr_40_no_eq_sbr
  { make (EArrowPure($1, $3))    }
| arrow_args_safe_no_eq_sbr ARROW effect_row expr_40_no_eq 
  { make (EArrowEff($1, $4, $3)) }
| KW_HANDLER KW_OF expr KW_IN eff_expr_50 ARROW2 eff_expr_40_no_eq
  { let (eff1, tp1) = $5 in
    let (eff2, tp2) = $7 in
    make (EHandlerType($3, tp1, eff1, tp2, eff2)) }
| expr_50_no_eq_sbr op_40 expr_40_no_eq { make (EBOp($1, $2, $3)) }
| expr_50_no_eq_sbr { $1 }
;

eff_expr_40
: expr_40_no_sbr     { ([], $1) }
| effect_row expr_40 { ($1, $2) }
;

eff_expr_40_no_eq
: expr_40_no_eq_sbr        { ([], $1) }
| effect_row expr_40_no_eq { ($1, $2) }
;

/* ------------------------------------------------------------------------- */

expr_50
: expr_60 op_50 expr_50 { make (EBOp($1, $2, $3)) }
| expr_60 { $1 }
;

expr_50_no_sbr
: expr_60_no_sbr op_50 expr_50 { make (EBOp($1, $2, $3)) }
| expr_60_no_sbr { $1 }
;

expr_50_no_eq
: expr_60_no_eq op_50 expr_50_no_eq { make (EBOp($1, $2, $3)) }
| expr_60_no_eq { $1 }
;

expr_50_no_eq_sbr
: expr_60_no_eq_sbr op_50 expr_50_no_eq { make (EBOp($1, $2, $3)) }
| expr_60_no_eq_sbr { $1 }
;

eff_expr_50
: expr_50_no_sbr     { ([], $1) }
| effect_row expr_50 { ($1, $2) }
;

expr_list_comma_sep
: expr_50 { [ $1 ] }
| expr_50 COMMA expr_list_comma_sep { $1 :: $3 }
;

expr_or_inst_list_comma_sep
: expr_or_inst { [ $1 ] }
| expr_or_inst COMMA expr_or_inst_list_comma_sep { $1 :: $3 }
;

expr_or_inst
: expr_50 { $1 }
| iexpr   { make (EInst $1) }
;

/* ------------------------------------------------------------------------- */

expr_60
: expr_60 op_60 expr_70 { make (EBOp($1, $2, $3)) }
| expr_70 { $1 }
;

expr_60_no_sbr
: expr_60_no_sbr op_60 expr_70 { make (EBOp($1, $2, $3)) }
| expr_70_no_sbr { $1 }
;

expr_60_no_eq
: expr_60_no_eq op_60_no_eq expr_70 { make (EBOp($1, $2, $3)) }
| expr_70 { $1 }
;

expr_60_no_eq_sbr
: expr_60_no_eq_sbr op_60_no_eq expr_70 { make (EBOp($1, $2, $3)) }
| expr_70_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_70
: expr_80 op_70 expr_70 { make (EBOp($1, $2, $3)) }
| expr_80 { $1 }
;

expr_70_no_sbr
: expr_80_no_sbr op_70 expr_70 { make (EBOp($1, $2, $3)) }
| expr_80_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_80
: expr_80 op_80 expr_90 { make (EBOp($1, $2, $3)) }
| expr_90 { $1 }
;

expr_80_no_sbr
: expr_80_no_sbr op_80 expr_90 { make (EBOp($1, $2, $3)) }
| expr_90_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_90
: expr_90 op_90 expr_100   { make (EBOp($1, $2, $3))   }
| expr_100 BTSTAR sig_prod { make (ESigProd($1 :: $3)) }
| expr_100 { $1 }
;

expr_90_no_sbr
: expr_90_no_sbr op_90 expr_100   { make (EBOp($1, $2, $3))   }
| expr_100_no_sbr BTSTAR sig_prod { make (ESigProd($1 :: $3)) }
| expr_100_no_sbr { $1 }
;

sig_prod
: expr_100                 { [ $1 ]   }
| expr_100 BTSTAR sig_prod { $1 :: $3 }
;

/* ------------------------------------------------------------------------- */

expr_100
: expr_150 op_100 expr_100 { make (EBOp($1, $2, $3)) }
| expr_150 { $1 }
;

expr_100_no_sbr
: expr_150_no_sbr op_100 expr_100 { make (EBOp($1, $2, $3)) }
| expr_150_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_150
: uop_150 expr_150 { make (EUOp($1, $2)) }
| expr_200 { $1 }
;

expr_150_no_sbr
: uop_150 expr_150 { make (EUOp($1, $2)) }
| expr_200_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_200
: expr_200 expr_250              { make (EApp($1, $2))             }
| expr_200 iexpr                 { make (EInstApp($1, $2))         }
| expr_200 CBR_OPN iexpr CBR_CLS { make (EImplicitInstApp($1, $3)) }
| KW_EXTERN str                  { make (EExtern $2)               }
| KW_EFFECT effect_row           { make (EEffect $2)               }
| KW_EFFECT iexpr                { make (EInst   $2)               }
| KW_TYPE KW_OF expr_250         { make (ETypeOf $3)               }
| expr_250 { $1 }
;

expr_200_no_sbr
: expr_200_no_sbr expr_250              { make (EApp($1, $2))             }
| expr_200_no_sbr iexpr                 { make (EInstApp($1, $2))         }
| expr_200_no_sbr CBR_OPN iexpr CBR_CLS { make (EImplicitInstApp($1, $3)) }
| KW_EXTERN str                         { make (EExtern $2)               }
| KW_EFFECT effect_row                  { make (EEffect $2)               }
| KW_EFFECT iexpr                       { make (EInst   $2)               }
| KW_TYPE KW_OF expr_250                { make (ETypeOf $3)               }
| expr_250_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_250
: uop_250 expr_250 { make (EUOp($1, $2)) }
| expr_300 { $1 }
;

expr_250_no_sbr
: uop_250 expr_250 { make (EUOp($1, $2)) }
| expr_300_no_sbr { $1 }
;

/* ------------------------------------------------------------------------- */

expr_300
: expr_300 DOT path { make (ESelect($1, $3)) }
| expr_simpl { $1 }
;

expr_300_no_sbr
: expr_300_no_sbr DOT path { make (ESelect($1, $3)) }
| expr_simpl_no_sbr { $1 }
;

path_expr
: name               { make (EName $1)        }
| path_expr DOT path { make (ESelect($1, $3)) }
;

/* ------------------------------------------------------------------------- */

expr_simpl
: expr_simpl_no_sbr { $1 }
| SBR_OPN SBR_CLS   { make (EName (make NameNil)) }
| SBR_OPN expr_list_comma_sep SBR_CLS { make (EList $2) }
;

expr_simpl_no_sbr
: KW_BEGIN expr KW_END { make ($2).data     }
| BR_OPN expr BR_CLS   { make ($2).data     }
| name_no_sbr          { make (EName $1)    }
| TLID                 { make (ETypeVar $1) }
| UNDERSCORE           { make EPlaceholder  }
| UKW_TYPE             { make EKindType     }
| UKW_EFFECT           { make EKindEffect   }
| UKW_SIG              { make EKindEffsig   }
| NUM                  { make (ELit (LNum $1))    }
| STR                  { make (ELit (LString $1)) }
| CHR                  { make (ELit (LChar   $1)) }
| CBR_OPN field_def_list CBR_CLS { make (ERecord $2) }
| CBR_OPN expr_simpl KW_WITH field_def_list CBR_CLS
    { make (ERecordUpdate($2, $4)) }
| KW_HANDLE handler_inst_opt expr KW_WITH handler_list KW_END
    { make (EHandle($2, $3, $5)) }
| KW_HANDLER hexpr hstack                      { make (EHandler($2, $3)) }
| KW_MATCH expr KW_WITH clause_list_opt KW_END { make (EMatch($2, $4))   }
| KW_STRUCT def_list KW_END                    { make (EStruct $2)       }
| KW_SIG decl_list KW_END                      { make (ESig $2)          }
;

/* ------------------------------------------------------------------------- */

effect_row
: SBR_OPN SBR_CLS { [] }
| SBR_OPN expr_or_inst_list_comma_sep SBR_CLS { $2 }
;

effect_expr
: effect_row  { $1     }
| expr_no_sbr { [ $1 ] }
;

/* ========================================================================= */
/* record fields */

field_def
: name EQ expr_10               { make (FieldName($1, $3))    }
| path_expr DOT name EQ expr_10 { make (FieldSel($1, $3, $5)) }
;

field_def_list
: field_def { [ $1 ] }
| field_def SEMICOLON field_def_list { $1 :: $3 }
;

/* ========================================================================= */
/* handlers */

hexpr
: expr         { HEExpr $1    }
| handler_list { HEClauses $1 }
;

hstack
: KW_END { [] }
| KW_THEN inst_pattern_opt KW_WITH hexpr hstack { ($2, $4) :: $5 }
;

inst_pattern_opt
: /* empty */  { None    }
| inst_pattern { Some $1 }
;

/* ------------------------------------------------------------------------- */

resume_opt
: /* empty */   { None    }
| SLASH pattern { Some $2 }
;

handler
: op_path pattern_simpl_list_1 resume_opt ARROW2 expr
    { make (HOp($1, $2, $3, $5)) }
| KW_RETURN pattern ARROW2 expr  { make (HReturn($2, $4))  }
| KW_FINALLY pattern ARROW2 expr { make (HFinally($2, $4)) }
;

handler_list
: /* empty */ { [] }
| BAR handler handler_list { $2 :: $3 }
;

op_path
: name               { make (OPName $1)      }
| path_expr DOT name { make (OPPath($1, $3)) }
;

/* ========================================================================= */
/* clauses */

bar_opt
: /* empty */ { () }
| BAR         { () }
;

clause
: pattern ARROW2 expr { make (Clause($1, $3)) }
;

clause_list
: clause { [ $1 ] }
| clause BAR clause_list { $1 :: $3 }
;

clause_list_opt
: /* empty */         { [] }
| bar_opt clause_list { $2 }
;

/* ========================================================================= */
/* instance expressions */

iexpr
: BTLID                                       { make (IEVar $1)       }
| BACKTICK BR_OPN BR_CLS                      { make (IETuple [])     }
| BACKTICK BR_OPN iexpr_list_comma_sep BR_CLS { make (IETuple $3)     }
| iexpr DOT NUM                               { make (IEProj($1, $3)) }
;

iexpr_list_comma_sep
: iexpr                      { [ $1 ]   }
| iexpr iexpr_list_comma_sep { $1 :: $2 }
;

/* ========================================================================= */
/* recursive functions */

rec_fun
: name             EQ expr { make (RecVal($1, $3)) }
| name farg_list_1 EQ expr { make (RecFun($1, $2, $4)) }
;

rec_fun_list
: rec_fun                     { [ $1 ]   }
| rec_fun KW_AND rec_fun_list { $1 :: $3 }
;

/* ========================================================================= */
/* datatypes */

typedef
: KW_DATA name type_farg_list EQ ctor_decl_list
    { make (TDData($2, $3, $5)) }
| KW_DATA name type_farg_list EQ CBR_OPN field_decl_list CBR_CLS
    { make (TDRecord($2, $3, $6)) }
| KW_SIGNATURE name type_farg_list EQ op_decl_list
    { make (TDEffsig($2, $3, $5)) }
;

typedef_rec
: KW_DATA KW_REC name type_farg_list EQ ctor_decl_list
    { make (TDData($3, $4, $6)) }
| KW_DATA KW_REC name type_farg_list EQ CBR_OPN field_decl_list CBR_CLS
    { make (TDRecord($3, $4, $7)) }
| KW_SIGNATURE KW_REC name type_farg_list EQ op_decl_list
    { make (TDEffsig($3, $4, $6)) }
;

typedef_rec_list
: typedef_rec and_typedef_list { $1 :: $2 }
;

and_typedef_list
: /* empty */                     { [] }
| KW_AND typedef and_typedef_list { $2 :: $3 }
;

/* ------------------------------------------------------------------------- */

ctor_decl
: ctor_name { make (CtorDecl($1, [])) }
| ctor_name KW_OF arrow_args { make (CtorDecl($1, $3)) }
;

ctor_decl_list
: /* empty */              { [] }
| bar_opt ctor_decl_list_1 { $2 }
;

ctor_decl_list_1
: ctor_decl                      { [ $1 ]   }
| ctor_decl BAR ctor_decl_list_1 { $1 :: $3 }
;

/* ------------------------------------------------------------------------- */

field_decl
: name COLON expr_10 { make (FieldDecl($1, $3)) }
;

field_decl_list
: field_decl { [ $1 ] }
| field_decl SEMICOLON field_decl_list { $1 :: $3 }
;

/* ------------------------------------------------------------------------- */

op_decl
: name COLON arrow_args ARROW2 expr_10
    { make (OpDecl($1, $3, $5)) }
;

op_decl_list
: /* empty */            { [] }
| bar_opt op_decl_list_1 { $2 }
;

op_decl_list_1
: op_decl { [ $1 ] }
| op_decl BAR op_decl_list { $1 :: $3 }
;

/* ========================================================================= */
/* definitions */

def
: KW_LET pattern_no_eq EQ expr                 { make (DefLet($2, $4))      }
| KW_LET lname farg_list_1 EQ expr             { make (DefFun($2, $3, $5))  }
| KW_LET KW_REC rec_fun_list                   { make (DefLetRec $3)        }
| large_mod name_no_sbr type_farg_list EQ expr { make (DefType($2, $3, $5)) }
| large_mod name_no_sbr COLON expr             { make (DefAbsType($2, $4))  }
| typedef                                      { make (DefTypedef $1)       }
| typedef_rec_list                             { make (DefTypedefRec $1)    }
| KW_LET KW_HANDLE inst_pattern_opt KW_WITH handler_list KW_END
    { make (DefHandle($3, $5)) }
| KW_LET KW_HANDLE inst_pattern_opt KW_WITH expr_10
    { make (DefHandleWith($3, $5)) }
| KW_OPEN            expr_10 { make (DefOpen $2)        }
| KW_OPEN KW_TYPE    expr_10 { make (DefOpenType $3)    }
| KW_INCLUDE         expr_10 { make (DefInclude $2)     }
| KW_INCLUDE KW_TYPE expr_10 { make (DefIncludeType $3) }
;

def_list
: /* empty */  { [] }
| def_list_1 { $1 }
;

def_list_1
: def def_list { $1 :: $2 }
;

/* ========================================================================= */
/* declarations */

decl
: KW_VAL name COLON expr                       { make (DeclValSig($2, $4))   }
| large_mod name_no_sbr COLON expr             { make (DeclValSig($2, $4))   }
| large_mod name_no_sbr type_farg_list EQ expr { make (DeclType($2, $3, $5)) }
| typedef                                      { make (DeclTypedef $1)       }
| typedef_rec_list                             { make (DeclTypedefRec $1)    }
| KW_OPEN            expr_10                   { make (DeclOpen $2)          }
| KW_OPEN KW_TYPE    expr_10                   { make (DeclOpenType $3)      }
| KW_INCLUDE         expr_10                   { make (DeclInclude $2)       }
| KW_INCLUDE KW_TYPE expr_10                   { make (DeclIncludeType $3)   }
;

decl_list
: /* empty */ { [] }
| decl decl_list { $1 :: $2 }
;
