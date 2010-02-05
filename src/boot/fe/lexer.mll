

{
  open Parser;;
  open Common;;
  let bump_line p = { p with
              Lexing.pos_lnum = p.Lexing.pos_lnum + 1;
              Lexing.pos_bol = p.Lexing.pos_cnum }
  ;;

  let keyword_table = Hashtbl.create 100
  let _ =
    List.iter (fun (kwd, tok) -> Common.htab_put keyword_table kwd tok)
              [ ("crate", CRATE);
                ("mod", MOD);
                ("use", USE);

                ("native", NATIVE);
                ("syntax", SYNTAX);
                ("meta", META);

                ("if", IF);
                ("else", ELSE);
                ("while", WHILE);
                ("do", DO);
                ("alt", ALT);

                ("fail", FAIL);
                ("fini", FINI);

                ("type", TYPE);
                ("pred", PRED);
                ("check", CHECK);
                ("prove", PROVE);

                ("pure", PURE);
                ("mutable", MUTABLE);
                ("auto", AUTO);

                ("pub", PUB);

                ("let", LET);

                ("log", LOG);
                ("spawn", SPAWN);
		("thread", THREAD);
		("yield", YIELD);
		("join", JOIN);

                ("bool", BOOL);

                ("int", INT);

                ("char", CHAR);
                ("str", STR);

                ("rec", REC);
                ("tag", TAG);
                ("vec", VEC);
                ("any", ANY);

                ("port", PORT);
                ("chan", CHAN);

                ("proc", PROC);

                ("true", LIT_BOOL true);
                ("false", LIT_BOOL false);

                ("in", IN);

                ("bind", BIND);

                ("u8", MACH TY_u8);
                ("u16", MACH TY_u16);
                ("u32", MACH TY_u32);
                ("u64", MACH TY_u64);
                ("s8", MACH TY_s8);
                ("s16", MACH TY_s16);
                ("s32", MACH TY_s32);
                ("s64", MACH TY_s64);
                ("f32", MACH TY_f32);
                ("f64", MACH TY_f64)
              ]
;;
}

let bin = "0b" ['0' '1']['0' '1' '_']*
let hex = "0x" ['0'-'9' 'a'-'f' 'A'-'F']['0'-'9' 'a'-'f' 'A'-'F' '_']*
let dec = ['0'-'9']+
let exp = ['e''E']['-''+']? dec
let flo = (dec '.' dec (exp?)) | (dec exp)

let ws = [ ' ' '\t' '\r' ]

let id = ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule token = parse
  ws+                          { token lexbuf }
| '\n'                         { lexbuf.Lexing.lex_curr_p
                                     <- (bump_line lexbuf.Lexing.lex_curr_p);
                                 token lexbuf }
| "//" [^'\n']*                { token lexbuf }

| '+'                          { PLUS       }
| '-'                          { MINUS      }
| '*'                          { STAR       }
| '/'                          { SLASH      }
| '%'                          { PERCENT    }
| '='                          { EQ         }
| '<'                          { LT         }
| "<="                         { LE         }
| "=="                         { EQEQ       }
| "!="                         { NE         }
| ">="                         { GE         }
| '>'                          { GT         }
| '!'                          { NOT        }
| '&'                          { AND        }
| '|'                          { OR         }
| "<<"                         { LSL        }
| ">>"                         { LSR        }
| ">>>"                        { ASR        }
| '~'                          { TILDE      }
| '{'                          { LBRACE     }
| '_' (dec as n)               { IDX (int_of_string n) }
| '_'                          { UNDERSCORE }
| '}'                          { RBRACE     }

| "+="                         { OPEQ (PLUS) }
| "-="                         { OPEQ (MINUS) }
| "*="                         { OPEQ (STAR) }
| "/="                         { OPEQ (SLASH) }
| "%="                         { OPEQ (PERCENT) }
| "&="                         { OPEQ (AND) }
| "|="                         { OPEQ (OR)  }
| "<<="                        { OPEQ (LSL) }
| ">>="                        { OPEQ (LSR) }
| ">>>="                       { OPEQ (ASR) }

| '#'                          { POUND      }
| '@'                          { AT         }
| '^'                          { CARET      }
| '.'                          { DOT        }
| ','                          { COMMA      }
| ';'                          { SEMI       }
| ':'                          { COLON      }
| "<-"                         { LARROW     }
| "<|"                         { SEND       }
| "->"                         { RARROW     }
| '(' ws* ')'                  { NIL        }
| '('                          { LPAREN     }
| ')'                          { RPAREN     }
| '['                          { LBRACKET   }
| ']'                          { RBRACKET   }

| "fn"                         { FN None                }
| "fn?"                        { FN (Some Ast.PROTO_ques)   }
| "fn!"                        { FN (Some Ast.PROTO_bang)   }
| "fn*"                        { FN (Some Ast.PROTO_star)   }
| "fn+"                        { FN (Some Ast.PROTO_plus)   }

| "for"                        { FOR None               }
| "for?"                       { FOR (Some Ast.PROTO_ques)  }
| "for!"                       { FOR (Some Ast.PROTO_bang)  }
| "for*"                       { FOR (Some Ast.PROTO_star)  }
| "for+"                       { FOR (Some Ast.PROTO_plus)  }

| "ret"                        { RET None               }
| "ret?"                       { RET (Some Ast.PROTO_ques)  }
| "ret!"                       { RET (Some Ast.PROTO_bang)  }
| "ret*"                       { RET (Some Ast.PROTO_star)  }
| "ret+"                       { RET (Some Ast.PROTO_plus)  }

| "put"                        { PUT None               }
| "put?"                       { PUT (Some Ast.PROTO_ques)  }
| "put!"                       { PUT (Some Ast.PROTO_bang)  }
| "put*"                       { PUT (Some Ast.PROTO_star)  }
| "put+"                       { PUT (Some Ast.PROTO_plus)  }

| "be"                         { BE None               }
| "be?"                        { BE (Some Ast.PROTO_ques)  }
| "be!"                        { BE (Some Ast.PROTO_bang)  }
| "be*"                        { BE (Some Ast.PROTO_star)  }
| "be+"                        { BE (Some Ast.PROTO_plus)  }

| id as i
                               { try
                                     Hashtbl.find keyword_table i
                                 with
                                     Not_found -> IDENT (i)
                                           }

| bin as n                      { LIT_INT (Int64.of_string n, n)    }
| hex as n                      { LIT_INT (Int64.of_string n, n)    }
| dec as n                      { LIT_INT (Int64.of_string n, n)    }
| flo as n                      { LIT_FLO n                                                }
| (['"'] ([^'"']|"\\\"")* ['"'])  as s    { LIT_STR  (Scanf.sscanf s "%S" (fun x -> x))    }
| (['\''] [^'\'']         ['\'']) as c    { LIT_CHAR (Scanf.sscanf c "%C" (fun x -> x))    }
| "'\\''"                                 { LIT_CHAR ('\'')                                }

| eof                           { EOF        }
