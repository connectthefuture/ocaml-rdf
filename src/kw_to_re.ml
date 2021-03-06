(*********************************************************************************)
(*                OCaml-RDF                                                      *)
(*                                                                               *)
(*    Copyright (C) 2012-2016 Institut National de Recherche en Informatique     *)
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

let print s =
  let len = String.length s in
  let b = Buffer.create 256 in
  for i = 0 to len - 1 do
    Printf.bprintf b "('%c'|'%c')%s "
      (Char.lowercase_ascii s.[i]) (Char.uppercase_ascii s.[i])
      (if i < len - 1 then "," else "")
  done;
  Printf.printf "| %s -> (lexpos pos lexbuf), %s\n"
    (Buffer.contents b) (String.uppercase_ascii s);;

let () =
  for i = 1 to Array.length Sys.argv - 1 do
    print Sys.argv.(i)
  done


