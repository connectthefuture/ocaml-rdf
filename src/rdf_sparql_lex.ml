(*********************************************************************************)
(*                OCaml-RDF                                                      *)
(*                                                                               *)
(*    Copyright (C) 2012-2014 Institut National de Recherche en Informatique     *)
(*    et en Automatique. All rights reserved.                                    *)
(*                                                                               *)
(*    This program is free software; you can redistribute it and/or modify       *)
(*    it under the terms of the GNU Lesser General Public License version        *)
(*    3 as published by the Free Software Foundation.                            *)
(*                                                                               *)
(*    This program is distributed in the hope that it will be useful,            *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of             *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *)
(*    GNU General Public License for more details.                               *)
(*                                                                               *)
(*    You should have received a copy of the GNU General Public License          *)
(*    along with this program; if not, write to the Free Software                *)
(*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   *)
(*    02111-1307  USA                                                            *)
(*                                                                               *)
(*    Contact: Maxence.Guesdon@inria.fr                                          *)
(*                                                                               *)
(*********************************************************************************)

(** *)

open Rdf_sparql_types;;
open Rdf_sparql_parser;;

module L = Sedlexing.Utf8

let mk_loc lb =
  let start =
    { Lexing.pos_lnum = 0 ; pos_bol = 0 ; pos_cnum = Sedlexing.lexeme_start lb; pos_fname = "" }
  in
  let stop =
    { Lexing.pos_lnum = 0 ; pos_bol = 0 ; pos_cnum = Sedlexing.lexeme_end lb ; pos_fname = "" }
  in
  { Rdf_sparql_types.loc_start = start ; loc_end = stop }
;;

exception Found of int

let utf8_find_char str cp =
  let f () i = function
  | `Uchar codepoint when codepoint = cp -> raise (Found i)
  | _ -> ()
  in
  try Uutf.String.fold_utf_8 f () str; raise Not_found
  with Found pos -> pos
;;

let add_echar b = function
  | 'b' -> Buffer.add_char b '\b'
(*  | 'f' -> Buffer.add_char b '\f'*)
  | 'n' -> Buffer.add_char b '\n'
  | 'r' -> Buffer.add_char b '\r'
  | 't' -> Buffer.add_char b '\t'
  | '\\' -> Buffer.add_char b '\\'
  | '"' -> Buffer.add_char b '"'
  | '\'' -> Buffer.add_char b '\''
  | c -> Buffer.add_char b c
;;

let hex = [%sedlex.regexp? '0'..'9' | 'A'..'F' | 'a'..'f']
let codepoint_u = [%sedlex.regexp? "\\u", hex, hex, hex, hex]
let codepoint_U = [%sedlex.regexp? "\\U", hex, hex, hex, hex, hex, hex, hex, hex]
let codepoint_any = [%sedlex.regexp? 0x00..0x10FFFF]

let iriref = [%sedlex.regexp?
  '<', Star(Compl(Chars("<>\"{}|^`\\ ")|0x0000..0x0020)), '>']

let pn_chars_base = [%sedlex.regexp?
  'A'..'Z' | 'a'..'z' | 0x00C0..0x00D6 | 0x00D8..0x00F6 | 0x00F8..0x02FF | 0x0370..0x037D
  | 0x037F..0x1FFF | 0x200C..0x200D | 0x2070..0x218F | 0x2C00..0x2FEF | 0x3001..0xD7FF
  | 0xF900..0xFDCF | 0xFDF0..0xFFFD | 0x10000..0xEFFFF
  ]
let pn_chars_u = [%sedlex.regexp? pn_chars_base | '_']
let pn_chars = [%sedlex.regexp? pn_chars_u | '-' | '0'..'9'
  | 0x00B7 | 0x0300..0x036F | 0x203F..0x2040 ]
let pn_prefix = [%sedlex.regexp? pn_chars_base, Opt(Star(pn_chars|'.'), pn_chars)]
let pname_ns = [%sedlex.regexp? Opt(pn_prefix), ':']
let pn_local_esc = [%sedlex.regexp? '\\', ( '_' | '~' | '.' | '-' | '!' | '$' | '&' | "'" | '(' | ')' | '*' | '+' | ',' | ';' | '=' | '/' | '?' | '#' | '@' | '%' )]

let percent = [%sedlex.regexp? '%', hex, hex]
let plx = [%sedlex.regexp? percent | pn_local_esc]
let pn_local = [%sedlex.regexp? (pn_chars_u | ':' | '0'..'9' | plx ), Opt(Star(pn_chars | '.' | ':' | plx), (pn_chars | ':' | plx) )]
let pname_ln = [%sedlex.regexp? pname_ns, pn_local]
let blank_node_label = [%sedlex.regexp? "_:", ( pn_chars_u | '0'..'9' ), Opt(Star(pn_chars|'.'), pn_chars)]
let varname = [%sedlex.regexp? ( pn_chars_u | '0'..'9' ), Star( pn_chars_u | '0'..'9' | 0x00B7 | 0x0300..0x036F | 0x203F..0x2040 )]
let var1 = [%sedlex.regexp? '?', varname]
let var2 = [%sedlex.regexp? '$', varname]
let langtag = [%sedlex.regexp? '@', Plus('a'..'z'|'A'..'Z'), Star('-', Plus('a'..'z'|'A'..'Z'|'0'..'9'))]
let integer = [%sedlex.regexp? Plus('0'..'9')]
let decimal = [%sedlex.regexp? Star('0'..'9'), '.', Plus('0'..'9')]
let exponent = [%sedlex.regexp? ('e'|'E'), Opt('+'|'-'), Plus('0'..'9')]
let double = [%sedlex.regexp?
    (Plus('0'..'9'), '.', Star('0'..'9'), exponent)
  | ('.', Plus('0'..'9'), exponent)
  | (Plus('0'..'9'), exponent)]
let integer_positive = [%sedlex.regexp? '+',integer]
let decimal_positive = [%sedlex.regexp? '+',decimal]
let double_positive = [%sedlex.regexp? '+',double]
let integer_negative = [%sedlex.regexp? '-',integer]
let decimal_negative = [%sedlex.regexp? '-',decimal]
let double_negative = [%sedlex.regexp? '-',double]
let boolean = [%sedlex.regexp? "true" | "false"]
let echar = [%sedlex.regexp? 't'|'b'|'n'|'r'|'f'|'\\'|'"'|'\'']

let schar_quote = [%sedlex.regexp? Plus(Compl(0x27|0x5C|0xA|0xD))]
let schar_dquote = [%sedlex.regexp? Plus(Compl(0x22|0x5C|0xA|0xD))]

(*
let regexp string_literal1 = "'" ( ([^0x27 0x5C 0xA 0xD]) | echar )* "'"
let regexp string_literal2 = '"' ( ([^0x22 0x5C 0xA 0xD]) | echar )* '"'
let regexp string_literal_long1 = "'''" ( ( "'" | "''" )? ( [^'\'' '\\'] | echar ) )* "'''"
let regexp string_literal_long2 = "\"\"\"" ( ( '"' | "\"\"" )? ( [^'"' '\\'] | echar ) )* "\"\"\""
*)

let longstring_quote_delim = [%sedlex.regexp? 0x27, 0x27, 0x27]
let longstring_dquote_delim = [%sedlex.regexp? 0x22, 0x22, 0x22]

let ws = [%sedlex.regexp? 0x20 | 0x9 | 0xD | 0xA]
let nil = [%sedlex.regexp? '(', Star(ws), ')']
let anon = [%sedlex.regexp? '[', Star(ws), ']'];;

let lexpos = Rdf_ulex.upd

let invalid_char lexbuf =
  let msg = Printf.sprintf "Invalid character %s" (Sedlexing.Utf8.lexeme lexbuf) in
  failwith msg

let rec string_quote b pos lexbuf =
  match%sedlex lexbuf with
  | '\'' -> (lexpos pos lexbuf), String_literal (Buffer.contents b)
  | '\\', echar ->
      let s = L.lexeme lexbuf in
      (* unescape some characters *)
      add_echar b s.[0];
      string_quote b (lexpos pos lexbuf) lexbuf
  | schar_quote ->
      let s = L.lexeme lexbuf in
      Buffer.add_string b s ;
      string_quote b (lexpos pos lexbuf) lexbuf
  | eof ->
      failwith "Unterminated quoted string"
  | _ ->
      invalid_char lexbuf
;;

let rec string_dquote b pos lexbuf =
  match%sedlex lexbuf with
  | '"' ->
      let s = Buffer.contents b in
      ((lexpos pos lexbuf), String_literal s)
  | '\\', echar ->
      let s = L.lexeme lexbuf in
      (* unescape some characters *)
      add_echar b s.[0];
      string_dquote b (lexpos pos lexbuf) lexbuf
  | schar_dquote ->
      let s = L.lexeme lexbuf in
      Buffer.add_string b s ;
      string_dquote b (lexpos pos lexbuf) lexbuf
  | eof ->
      failwith "Unterminated double quoted string"
  | _ ->
      invalid_char lexbuf
;;


let rec longstring_quote b pos lexbuf =
  match%sedlex lexbuf with
  | longstring_quote_delim ->
      let s = Buffer.contents b in
      ((lexpos pos lexbuf), String_literal s)
  | '\\', echar ->
      let s = L.lexeme lexbuf in
      (* unescape some characters *)
      add_echar b s.[0];
      longstring_quote b (lexpos pos lexbuf) lexbuf
  | ('\'' | Star(Compl('\'' | '\\') | '\n') ) ->
      let s = L.lexeme lexbuf in
      Buffer.add_string b s ;
      longstring_quote b (lexpos pos lexbuf) lexbuf
  | eof ->
      failwith "Unterminated long quoted string"
  | _ ->
      invalid_char lexbuf
;;


let rec longstring_dquote b pos lexbuf =
  match%sedlex lexbuf with
  | longstring_dquote_delim ->
      let s = Buffer.contents b in
      ((lexpos pos lexbuf), String_literal s)
  | '\\', echar ->
      let s = L.lexeme lexbuf in
      (* unescape some characters *)
      add_echar b s.[0];
      longstring_dquote b (lexpos pos lexbuf) lexbuf
  | ('"' | Star(Compl('"'|'\\') | '\n') ) ->
      let s = L.lexeme lexbuf in
      Buffer.add_string b s ;
      longstring_dquote b (lexpos pos lexbuf) lexbuf
  | eof ->
      failwith "Unterminated long double-quoted string"
  | _ ->
      invalid_char lexbuf
;;

let rec main pos lexbuf =
  match%sedlex lexbuf with
  | pname_ns ->
      let s = L.lexeme lexbuf in
      let t =
        { Rdf_sparql_types.pname_ns_loc = mk_loc lexbuf ;
          pname_ns_name = String.sub s 0 (String.length s - 1) ; (* remove final ':' *)
        }
      in
      (lexpos pos lexbuf), Pname_ns t

  | '*' -> (lexpos pos lexbuf), STAR
  | '(' -> (lexpos pos lexbuf), LPAR
  | ')' -> (lexpos pos lexbuf), RPAR
  | '{' -> (lexpos pos lexbuf), LBRACE
  | '}' -> (lexpos pos lexbuf), RBRACE
  | ',' -> (lexpos pos lexbuf), COMMA
  | '.' -> (lexpos pos lexbuf), DOT
  | 'a' -> (lexpos pos lexbuf), A
  | '|' -> (lexpos pos lexbuf), PIPE
  | "||" -> (lexpos pos lexbuf), PIPEPIPE
  | '/' -> (lexpos pos lexbuf), SLASH
  | '^' -> (lexpos pos lexbuf), HAT
  | "^^" -> (lexpos pos lexbuf), HATHAT
  | '!' -> (lexpos pos lexbuf), BANG
  | '?' -> (lexpos pos lexbuf), QM
  | '+' -> (lexpos pos lexbuf), PLUS
  | '[' -> (lexpos pos lexbuf), LBRACKET
  | ']' -> (lexpos pos lexbuf), RBRACKET
  | ';' -> (lexpos pos lexbuf), SEMICOLON
  | "&&" -> (lexpos pos lexbuf), AMPAMP
  | '=' -> (lexpos pos lexbuf), EQUAL
  | "!=" -> (lexpos pos lexbuf), NOTEQUAL
  | '<' -> (lexpos pos lexbuf), LT
  | '>' -> (lexpos pos lexbuf), GT
  | "<=" -> (lexpos pos lexbuf), LTE
  | ">=" -> (lexpos pos lexbuf), GTE

  | nil ->
      ((lexpos pos lexbuf), NIL)

  | ws ->
      main ((lexpos pos lexbuf)) lexbuf

  | langtag ->
      let s = L.lexeme lexbuf in
      let len = String.length s in
      (lexpos pos lexbuf), Langtag (String.sub s 1 (len - 1))

  | longstring_quote_delim ->
      (*prerr_endline "entering long quoted string";*)
      longstring_quote (Buffer.create 256) (lexpos pos lexbuf) lexbuf
  | longstring_dquote_delim ->
      (*prerr_endline "entering long dquoted string";*)
      longstring_dquote (Buffer.create 256) (lexpos pos lexbuf) lexbuf
  | '\'' ->
      (*prerr_endline "entering quoted string";*)
      string_quote (Buffer.create 256) (lexpos pos lexbuf) lexbuf
  | '"' ->
      (*prerr_endline "entering dquoted string";*)
      string_dquote (Buffer.create 256) (lexpos pos lexbuf) lexbuf

  | integer -> (lexpos pos lexbuf), Integer (L.lexeme lexbuf)
  | decimal -> (lexpos pos lexbuf), Decimal (L.lexeme lexbuf)
  | double -> (lexpos pos lexbuf), Double (L.lexeme lexbuf)
  | integer_positive -> (lexpos pos lexbuf), Integer_positive (L.lexeme lexbuf)
  | decimal_positive -> (lexpos pos lexbuf), Decimal_positive (L.lexeme lexbuf)
  | double_positive -> (lexpos pos lexbuf), Double_positive (L.lexeme lexbuf)
  | integer_negative -> (lexpos pos lexbuf), Integer_negative (L.lexeme lexbuf)
  | decimal_negative -> (lexpos pos lexbuf), Decimal_negative (L.lexeme lexbuf)
  | double_negative -> (lexpos pos lexbuf), Double_negative (L.lexeme lexbuf)

  | boolean -> (lexpos pos lexbuf), Boolean (L.lexeme lexbuf)

  | ('a'|'A'), ('b'|'B'), ('s'|'S')  -> (lexpos pos lexbuf), ABS
  | ('a'|'A'), ('s'|'S')  -> (lexpos pos lexbuf), AS
  | ('a'|'A'), ('s'|'S'), ('c'|'C')  -> (lexpos pos lexbuf), ASC
  | ('a'|'A'), ('s'|'S'), ('k'|'K')  -> (lexpos pos lexbuf), ASK
  | ('a'|'A'), ('v'|'V'), ('g'|'G')  -> (lexpos pos lexbuf), AVG
  | ('b'|'B'), ('a'|'A'), ('s'|'S'), ('e'|'E')  -> (lexpos pos lexbuf), BASE
  | ('b'|'B'), ('i'|'I'), ('n'|'N'), ('d'|'D')  -> (lexpos pos lexbuf), BIND

      (* support for old BINDINGS keywords, replaced by VALUES
 see change log at the end of http://www.w3.org/TR/sparql11-federated-query/
*)
| ('b'|'B'), ('i'|'I'), ('n'|'N'), ('d'|'D'), ('i'|'I'), ('n'|'N'), ('g'|'G'), ('s'|'S')  -> (lexpos pos lexbuf), VALUES

| ('b'|'B'), ('n'|'N'), ('o'|'O'), ('d'|'D'), ('e'|'E')  -> (lexpos pos lexbuf), BNODE
| ('b'|'B'), ('n'|'N'), ('o'|'O'), ('d'|'D'), ('e'|'E')  -> (lexpos pos lexbuf), BNODE
| ('b'|'B'), ('o'|'O'), ('u'|'U'), ('n'|'N'), ('d'|'D')  -> (lexpos pos lexbuf), BOUND
| ('b'|'B'), ('y'|'Y')  -> (lexpos pos lexbuf), BY
| ('c'|'C'), ('e'|'E'), ('i'|'I'), ('l'|'L')  -> (lexpos pos lexbuf), CEIL
| ('c'|'C'), ('o'|'O'), ('a'|'A'), ('l'|'L'), ('e'|'E'), ('s'|'S'), ('c'|'C'), ('e'|'E')  -> (lexpos pos lexbuf), COALESCE
| ('c'|'C'), ('o'|'O'), ('n'|'N'), ('c'|'C'), ('a'|'A'), ('t'|'T')  -> (lexpos pos lexbuf), CONCAT
| ('c'|'C'), ('o'|'O'), ('n'|'N'), ('s'|'S'), ('t'|'T'), ('r'|'R'), ('u'|'U'), ('c'|'C'), ('t'|'T')  -> (lexpos pos lexbuf), CONSTRUCT
| ('c'|'C'), ('o'|'O'), ('n'|'N'), ('t'|'T'), ('a'|'A'), ('i'|'I'), ('n'|'N'), ('s'|'S')  -> (lexpos pos lexbuf), CONTAINS
| ('c'|'C'), ('o'|'O'), ('u'|'U'), ('n'|'N'), ('t'|'T')  -> (lexpos pos lexbuf), COUNT
| ('d'|'D'), ('a'|'A'), ('t'|'T'), ('a'|'A'), ('t'|'T'), ('y'|'Y'), ('p'|'P'), ('e'|'E')  -> (lexpos pos lexbuf), DATATYPE
| ('d'|'D'), ('a'|'A'), ('y'|'Y')  -> (lexpos pos lexbuf), DAY
| ('d'|'D'), ('e'|'E'), ('s'|'S'), ('c'|'C')  -> (lexpos pos lexbuf), DESC
| ('d'|'D'), ('e'|'E'), ('s'|'S'), ('c'|'C'), ('r'|'R'), ('i'|'I'), ('b'|'B'), ('e'|'E')  -> (lexpos pos lexbuf), DESCRIBE
| ('d'|'D'), ('i'|'I'), ('s'|'S'), ('t'|'T'), ('i'|'I'), ('n'|'N'), ('c'|'C'), ('t'|'T')  -> (lexpos pos lexbuf), DISTINCT
| ('e'|'E'), ('n'|'N'), ('c'|'C'), ('o'|'O'), ('d'|'D'), ('e'|'E'), ('_'|'_'), ('f'|'F'), ('o'|'O'), ('r'|'R'), ('_'|'_'), ('u'|'U'), ('r'|'R'), ('i'|'I')  -> (lexpos pos lexbuf), ENCODE_FOR_URI
| ('e'|'E'), ('x'|'X'), ('i'|'I'), ('s'|'S'), ('t'|'T'), ('s'|'S')  -> (lexpos pos lexbuf), EXISTS
| ('f'|'F'), ('i'|'I'), ('l'|'L'), ('t'|'T'), ('e'|'E'), ('r'|'R')  -> (lexpos pos lexbuf), FILTER
| ('f'|'F'), ('l'|'L'), ('o'|'O'), ('o'|'O'), ('r'|'R')  -> (lexpos pos lexbuf), FLOOR
| ('f'|'F'), ('r'|'R'), ('o'|'O'), ('m'|'M')  -> (lexpos pos lexbuf), FROM
| ('g'|'G'), ('r'|'R'), ('a'|'A'), ('p'|'P'), ('h'|'H')  -> (lexpos pos lexbuf), GRAPH
| ('g'|'G'), ('r'|'R'), ('o'|'O'), ('u'|'U'), ('p'|'P')  -> (lexpos pos lexbuf), GROUP
| ('g'|'G'), ('r'|'R'), ('o'|'O'), ('u'|'U'), ('p'|'P'), ('_'|'_'), ('c'|'C'), ('o'|'O'), ('n'|'N'), ('c'|'C'), ('a'|'A'), ('t'|'T')  -> (lexpos pos lexbuf), GROUP_CONCAT
| ('h'|'H'), ('a'|'A'), ('v'|'V'), ('i'|'I'), ('n'|'N'), ('g'|'G')  -> (lexpos pos lexbuf), HAVING
| ('h'|'H'), ('o'|'O'), ('u'|'U'), ('r'|'R'), ('s'|'S')  -> (lexpos pos lexbuf), HOURS
| ('i'|'I'), ('f'|'F')  -> (lexpos pos lexbuf), IF
| ('i'|'I'), ('n'|'N') -> (lexpos pos lexbuf), IN
| ('i'|'I'), ('r'|'R'), ('i'|'I')  -> (lexpos pos lexbuf), IRI
| ('i'|'I'), ('s'|'S'), ('b'|'B'), ('l'|'L'), ('a'|'A'), ('n'|'N'), ('k'|'K')  -> (lexpos pos lexbuf), ISBLANK
| ('i'|'I'), ('s'|'S'), ('i'|'I'), ('r'|'R'), ('i'|'I')  -> (lexpos pos lexbuf), ISIRI
| ('i'|'I'), ('s'|'S'), ('l'|'L'), ('i'|'I'), ('t'|'T'), ('e'|'E'), ('r'|'R'), ('a'|'A'), ('l'|'L')  -> (lexpos pos lexbuf), ISLITERAL
| ('i'|'I'), ('s'|'S'), ('n'|'N'), ('u'|'U'), ('m'|'M'), ('e'|'E'), ('r'|'R'), ('i'|'I'), ('c'|'C')  -> (lexpos pos lexbuf), ISNUMERIC
| ('i'|'I'), ('s'|'S'), ('u'|'U'), ('r'|'R'), ('i'|'I')  -> (lexpos pos lexbuf), ISURI
| ('l'|'L'), ('a'|'A'), ('n'|'N'), ('g'|'G')  -> (lexpos pos lexbuf), LANG
| ('l'|'L'), ('a'|'A'), ('n'|'N'), ('g'|'G'), ('m'|'M'), ('a'|'A'), ('t'|'T'), ('c'|'C'), ('h'|'H'), ('e'|'E'), ('s'|'S')  -> (lexpos pos lexbuf), LANGMATCHES
| ('l'|'L'), ('c'|'C'), ('a'|'A'), ('s'|'S'), ('e'|'E')  -> (lexpos pos lexbuf), LCASE
| ('l'|'L'), ('i'|'I'), ('m'|'M'), ('i'|'I'), ('t'|'T')  -> (lexpos pos lexbuf), LIMIT
| ('m'|'M'), ('a'|'A'), ('x'|'X')  -> (lexpos pos lexbuf), MAX
| ('m'|'M'), ('d'|'D'), ('5'|'5')  -> (lexpos pos lexbuf), MD5
| ('m'|'M'), ('i'|'I'), ('n'|'N')  -> (lexpos pos lexbuf), MIN
| ('m'|'M'), ('i'|'I'), ('n'|'N'), ('u'|'U'), ('s'|'S')  -> (lexpos pos lexbuf), MINUS
| ('m'|'M'), ('i'|'I'), ('n'|'N'), ('u'|'U'), ('t'|'T'), ('e'|'E'), ('s'|'S')  -> (lexpos pos lexbuf), MINUTES
| ('m'|'M'), ('o'|'O'), ('n'|'N'), ('t'|'T'), ('h'|'H')  -> (lexpos pos lexbuf), MONTH
| ('n'|'N'), ('a'|'A'), ('m'|'M'), ('e'|'E'), ('d'|'D')  -> (lexpos pos lexbuf), NAMED
| ('n'|'N'), ('o'|'O'), ('t'|'T') -> (lexpos pos lexbuf), NOT
| ('n'|'N'), ('o'|'O'), ('w'|'W')  -> (lexpos pos lexbuf), NOW
| ('o'|'O'), ('f'|'F'), ('f'|'F'), ('s'|'S'), ('e'|'E'), ('t'|'T')  -> (lexpos pos lexbuf), OFFSET
| ('o'|'O'), ('p'|'P'), ('t'|'T'), ('i'|'I'), ('o'|'O'), ('n'|'N'), ('a'|'A'), ('l'|'L')  -> (lexpos pos lexbuf), OPTIONAL
| ('o'|'O'), ('r'|'R'), ('d'|'D'), ('e'|'E'), ('r'|'R')  -> (lexpos pos lexbuf), ORDER
| ('p'|'P'), ('r'|'R'), ('e'|'E'), ('f'|'F'), ('i'|'I'), ('x'|'X')  -> (lexpos pos lexbuf), PREFIX
| ('r'|'R'), ('a'|'A'), ('n'|'N'), ('d'|'D')  -> (lexpos pos lexbuf), RAND
| ('r'|'R'), ('e'|'E'), ('d'|'D'), ('u'|'U'), ('c'|'C'), ('e'|'E'), ('d'|'D')  -> (lexpos pos lexbuf), REDUCED
| ('r'|'R'), ('e'|'E'), ('g'|'G'), ('e'|'E'), ('x'|'X') -> (lexpos pos lexbuf), REGEX
| ('r'|'R'), ('e'|'E'), ('p'|'P'), ('l'|'L'), ('a'|'A'), ('c'|'C'), ('e'|'E')  -> (lexpos pos lexbuf), REPLACE
| ('r'|'R'), ('o'|'O'), ('u'|'U'), ('n'|'N'), ('d'|'D')  -> (lexpos pos lexbuf), ROUND
| ('s'|'S'), ('a'|'A'), ('m'|'M'), ('e'|'E'), ('t'|'T'), ('e'|'E'), ('r'|'R'), ('m'|'M')  -> (lexpos pos lexbuf), SAMETERM
| ('s'|'S'), ('a'|'A'), ('m'|'M'), ('p'|'P'), ('l'|'L'), ('e'|'E')  -> (lexpos pos lexbuf), SAMPLE
| ('s'|'S'), ('e'|'E'), ('c'|'C'), ('o'|'O'), ('n'|'N'), ('d'|'D'), ('s'|'S')  -> (lexpos pos lexbuf), SECONDS
| ('s'|'S'), ('e'|'E'), ('l'|'L'), ('e'|'E'), ('c'|'C'), ('t'|'T')  -> (lexpos pos lexbuf), SELECT
| ('s'|'S'), ('e'|'E'), ('p'|'P'), ('a'|'A'), ('r'|'R'), ('a'|'A'), ('t'|'T'), ('o'|'O'), ('r'|'R')  -> (lexpos pos lexbuf), SEPARATOR
| ('s'|'S'), ('e'|'E'), ('r'|'R'), ('v'|'V'), ('i'|'I'), ('c'|'C'), ('e'|'E')  -> (lexpos pos lexbuf), SERVICE
| ('s'|'S'), ('h'|'H'), ('a'|'A'), ('1'|'1')  -> (lexpos pos lexbuf), SHA1
| ('s'|'S'), ('h'|'H'), ('a'|'A'), ('2'|'2'), ('5'|'5'), ('6'|'6')  -> (lexpos pos lexbuf), SHA256
| ('s'|'S'), ('h'|'H'), ('a'|'A'), ('3'|'3'), ('8'|'8'), ('4'|'4')  -> (lexpos pos lexbuf), SHA384
| ('s'|'S'), ('h'|'H'), ('a'|'A'), ('5'|'5'), ('1'|'1'), ('2'|'2')  -> (lexpos pos lexbuf), SHA512
| ('s'|'S'), ('i'|'I'), ('l'|'L'), ('e'|'E'), ('n'|'N'), ('t'|'T')  -> (lexpos pos lexbuf), SILENT
| ('s'|'S'), ('t'|'T'), ('r'|'R')  -> (lexpos pos lexbuf), STR
| ('s'|'S'), ('t'|'T'), ('r'|'R'), ('a'|'A'), ('f'|'F'), ('t'|'T'), ('e'|'E'), ('r'|'R')  -> (lexpos pos lexbuf), STRAFTER
| ('s'|'S'), ('t'|'T'), ('r'|'R'), ('b'|'B'), ('e'|'E'), ('f'|'F'), ('o'|'O'), ('r'|'R'), ('e'|'E')  -> (lexpos pos lexbuf), STRBEFORE
| ('s'|'S'), ('t'|'T'), ('r'|'R'), ('d'|'D'), ('t'|'T')  -> (lexpos pos lexbuf), STRDT
| ('s'|'S'), ('t'|'T'), ('r'|'R'), ('e'|'E'), ('n'|'N'), ('d'|'D'), ('s'|'S')  -> (lexpos pos lexbuf), STRENDS
| ('s'|'S'), ('t'|'T'), ('r'|'R'), ('l'|'L'), ('a'|'A'), ('n'|'N'), ('g'|'G')  -> (lexpos pos lexbuf), STRLANG
| ('s'|'S'), ('t'|'T'), ('r'|'R'), ('l'|'L'), ('e'|'E'), ('n'|'N')  -> (lexpos pos lexbuf), STRLEN
| ('s'|'S'), ('t'|'T'), ('r'|'R'), ('s'|'S'), ('t'|'T'), ('a'|'A'), ('r'|'R'), ('t'|'T'), ('s'|'S')  -> (lexpos pos lexbuf), STRSTARTS
| ('s'|'S'), ('t'|'T'), ('r'|'R'), ('u'|'U'), ('u'|'U'), ('i'|'I'), ('d'|'D')  -> (lexpos pos lexbuf), STRUUID
| ('s'|'S'), ('u'|'U'), ('b'|'B'), ('s'|'S'), ('t'|'T'), ('r'|'R')  -> (lexpos pos lexbuf), SUBSTR
| ('s'|'S'), ('u'|'U'), ('m'|'M')  -> (lexpos pos lexbuf), SUM
| ('t'|'T'), ('i'|'I'), ('m'|'M'), ('e'|'E'), ('z'|'Z'), ('o'|'O'), ('n'|'N'), ('e'|'E')  -> (lexpos pos lexbuf), TIMEZONE
| ('t'|'T'), ('z'|'Z')  -> (lexpos pos lexbuf), TZ
| ('u'|'U'), ('c'|'C'), ('a'|'A'), ('s'|'S'), ('e'|'E')  -> (lexpos pos lexbuf), UCASE
| ('u'|'U'), ('n'|'N'), ('d'|'D'), ('e'|'E'), ('f'|'F')  -> (lexpos pos lexbuf), UNDEF
| ('u'|'U'), ('n'|'N'), ('i'|'I'), ('o'|'O'), ('n'|'N')  -> (lexpos pos lexbuf), UNION
| ('u'|'U'), ('r'|'R'), ('i'|'I')  -> (lexpos pos lexbuf), URI
| ('u'|'U'), ('u'|'U'), ('i'|'I'), ('d'|'D')  -> (lexpos pos lexbuf), UUID
| ('v'|'V'), ('a'|'A'), ('l'|'L'), ('u'|'U'), ('e'|'E'), ('s'|'S')  -> (lexpos pos lexbuf), VALUES
| ('w'|'W'), ('h'|'H'), ('e'|'E'), ('r'|'R'), ('e'|'E')  -> (lexpos pos lexbuf), WHERE
| ('y'|'Y'), ('e'|'E'), ('a'|'A'), ('r'|'R')  -> (lexpos pos lexbuf), YEAR

| var1 ->
  let s = L.lexeme lexbuf in
  let len = String.length s in
  (* remove beginning ? *)
  let label = String.sub s 1 (len - 1) in
  (lexpos pos lexbuf), Var1 label

| var2 ->
  let s = L.lexeme lexbuf in
  let len = String.length s in
  (* remove beginning $ *)
  let label = String.sub s 1 (len - 1) in
  (lexpos pos lexbuf), Var2 label

| blank_node_label ->
  let s = L.lexeme lexbuf in
  let len = String.length s in
  (* remove beginning _: *)
  let label = String.sub s 2 (len - 2) in
  (lexpos pos lexbuf), Blank_node_label label

| anon ->
  (lexpos pos lexbuf), ANON

| pname_ln ->
  let str = L.lexeme lexbuf in
  let p =
    try utf8_find_char str (Char.code ':')
    with Not_found -> assert false
  in
  let ns = L.sub_lexeme lexbuf 0 p in
  let ln =
    let len = String.length str in
    if len > p + 1 then
      L.sub_lexeme lexbuf (p+1) ((len - p) - 1)
    else
      ""
  in
  let loc = mk_loc lexbuf in
  let pl =
    match ln with
      "" -> None
    | _ ->
        Some { pname_local_loc = loc ; pname_local_name = ln }
  in
  (lexpos pos lexbuf,
   Pname_ln
    {
      pname_loc = loc ;
      pname_ns = { pname_ns_loc = loc ; pname_ns_name = ns } ;
      pname_local = pl ;
    }
  )

| iriref ->
  let s = L.lexeme lexbuf in
  let s = String.sub s 1 (String.length s - 2) in
  let iri = Iri.ref_of_string ~pos s in
  let loc = mk_loc lexbuf in
  (lexpos pos lexbuf), Iriref_ { ir_loc = loc ; ir_iri = iri}

| eof ->
    (lexpos pos lexbuf), EOF
| _ ->
  let s = L.lexeme lexbuf in
  let pos = lexpos pos lexbuf in
  let e = Failure (Printf.sprintf "Unexpected lexeme: %S" s) in
  raise (Rdf_ulex.Parse_error (e, pos))
;;

let int_of_hex c =
  match c with
  | '0'..'9' -> (Char.code c) - 48
  | 'a'..'f' -> (Char.code c) - 87
  | 'A'..'F' -> (Char.code c) - 55
  | _ -> failwith (Printf.sprintf "Invalid hex character %C" c)
;;

let rec codepoint b lexbuf =
  match%sedlex lexbuf with
  | codepoint_u
  | codepoint_U ->
    let lexeme = L.lexeme lexbuf in
      (* remove \u or \U from the beginning of the lexeme *)
      let hex = String.sub lexeme 2 (String.length lexeme - 2) in
      let cp = Int32.of_string ("0x"^hex) in
      Buffer.add_string b (Rdf_utf8.utf8_char_of_code cp);
      codepoint b lexbuf
  | codepoint_any ->
      let lexeme = L.lexeme lexbuf in
      Buffer.add_string b lexeme;
      codepoint b lexbuf
  | eof -> Buffer.contents b
  | _ ->
      invalid_char lexbuf
;;

let unescape_codepoints s =
  let lexbuf = L.from_string s in
  let b = Buffer.create 256 in
  codepoint b lexbuf
;;