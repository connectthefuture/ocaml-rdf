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

module OrderedString :
  sig type t = string val compare : String.t -> String.t -> int end
module SSet = Rdf_types.SSet
module SMap = Rdf_types.SMap
type loc =
  Rdf_loc.loc = {
  loc_start : Lexing.position;
  loc_end : Lexing.position;
}
type pname_ns = { pname_ns_loc : loc; pname_ns_name : string; }
type pname_local = { pname_local_loc : loc; pname_local_name : string; }
type var = { var_loc : loc; var_name : string; }
type iriref = { ir_loc : loc; ir_iri : Iri.reference; }
type prefixed_name = {
  pname_loc : loc;
  pname_ns : pname_ns;
  pname_local : pname_local option;
}
type iriloc = { iri_loc : loc; iri_iri : Iri.t; }
type iri = Iri of iriloc | Iriref of iriref | PrefixedName of prefixed_name
type prefix_decl = pname_ns * iriref
type query_prolog_decl = BaseDecl of iriref | PrefixDecl of prefix_decl
type query_prolog = query_prolog_decl list
type rdf_literal = {
  rdf_lit_loc : loc;
  rdf_lit : Rdf_term.literal;
  rdf_lit_type : iri option;
}
type data_block_value =
    DataBlockValueIri of iri
  | DataBlockValueRdf of rdf_literal
  | DataBlockValueNumeric of rdf_literal
  | DataBlockValueBoolean of rdf_literal
  | DataBlockValueUndef
type data_full_block_value = Nil | Value of data_block_value list
type inline_data_one_var = {
  idov_loc : loc;
  idov_var : var;
  idov_data : data_block_value list;
}
type inline_data_full = {
  idf_loc : loc;
  idf_vars : var list;
  idf_values : data_full_block_value list;
}
type datablock =
    InLineDataOneVar of inline_data_one_var
  | InLineDataFull of inline_data_full
type values_clause = datablock option
type path_mod = ModOptional | ModList | ModOneOrMore
type var_or_iri = VIVar of var | VIIri of iri
type blank_node = { bnode_loc : loc; bnode_label : string option; }
type select_clause_flag = Distinct | Reduced
type select_var = {
  sel_var_loc : loc;
  sel_var_expr : expression option;
  sel_var : var;
}
and select_vars = SelectAll | SelectVars of select_var list
and select_clause = {
  sel_flag : select_clause_flag option;
  sel_vars : select_vars;
}
and source_selector = iri
and dataset_clause =
    DefaultGraphClause of source_selector
  | NamedGraphClause of source_selector
and arg_list = {
  argl_loc : loc;
  argl_distinct : bool;
  argl : expression list;
}
and function_call = { func_loc : loc; func_iri : iri; func_args : arg_list; }
and binary_op =
    EPlus
  | EMinus
  | EMult
  | EDiv
  | EEqual
  | ENotEqual
  | ELt
  | EGt
  | ELte
  | EGte
  | EOr
  | EAnd
and expr =
    EVar of var
  | EIri of iri
  | EBin of expression * binary_op * expression
  | ENot of expression
  | EUMinus of expression
  | EBic of built_in_call
  | EFuncall of function_call
  | ELit of rdf_literal
  | ENumeric of rdf_literal
  | EBoolean of rdf_literal
  | EIn of expression * expression list
  | ENotIn of expression * expression list
and expression = { expr_loc : loc; expr : expr; }
and built_in_call =
    Bic_agg of aggregate
  | Bic_fun of string * expression list
  | Bic_BOUND of var
  | Bic_EXISTS of group_graph_pattern
  | Bic_NOTEXISTS of group_graph_pattern
and aggregate =
    Bic_COUNT of bool * expression option
  | Bic_SUM of bool * expression
  | Bic_MIN of bool * expression
  | Bic_MAX of bool * expression
  | Bic_AVG of bool * expression
  | Bic_SAMPLE of bool * expression
  | Bic_GROUP_CONCAT of bool * expression * string option
and group_var = {
  grpvar_loc : loc;
  grpvar_expr : expression option;
  grpvar : var option;
}
and group_condition =
    GroupBuiltInCall of built_in_call
  | GroupFunctionCall of function_call
  | GroupVar of group_var
and constraint_ =
    ConstrBuiltInCall of built_in_call
  | ConstrFunctionCall of function_call
  | ConstrExpr of expression
and having_condition = constraint_
and order_condition =
    OrderAsc of expression
  | OrderDesc of expression
  | OrderConstr of constraint_
  | OrderVar of var
and limit_offset_clause = {
  limoff_loc : loc;
  limoff_offset : int option;
  limoff_limit : int option;
}
and solution_modifier = {
  solmod_loc : loc;
  solmod_group : group_condition list;
  solmod_having : having_condition list;
  solmod_order : order_condition list option;
  solmod_limoff : limit_offset_clause option;
}
and bind = { bind_loc : loc; bind_expr : expression; bind_var : var; }
and service_graph_pattern = {
  servgp_loc : loc;
  servgp_silent : bool;
  servgp_name : var_or_iri;
  servgp_pat : group_graph_pattern;
}
and graph_graph_pattern = {
  graphgp_loc : loc;
  graphgp_name : var_or_iri;
  graphgp_pat : group_graph_pattern;
}
and graph_pattern_elt =
    Triples of triples_block
  | Union of group_graph_pattern list
  | Optional of group_graph_pattern
  | Minus of group_graph_pattern
  | GGP of graph_graph_pattern
  | Service of service_graph_pattern
  | Filter of constraint_
  | Bind of bind
  | InlineData of datablock
and graph_term =
    GraphTermIri of iri
  | GraphTermLit of rdf_literal
  | GraphTermNumeric of rdf_literal
  | GraphTermBoolean of rdf_literal
  | GraphTermBlank of blank_node
  | GraphTermNil
  | GraphTermNode of Rdf_term.term
and var_or_term = Var of var | GraphTerm of graph_term
and path_one_in_prop_set =
    PathOneInIri of iri
  | PathOneInA
  | PathOneInNotIri of iri
  | PathOneInNotA
and path_primary =
    PathIri of iri
  | PathA
  | PathNegPropSet of path_one_in_prop_set list
  | Path of path
and path_elt = {
  pelt_loc : loc;
  pelt_primary : path_primary;
  pelt_mod : path_mod option;
}
and path_elt_or_inverse = Elt of path_elt | Inv of path_elt
and path_sequence = path_elt_or_inverse list
and path = path_sequence list
and verb = VerbPath of path | VerbVar of var | VerbIri of iri | VerbA
and triples_node =
    TNodeCollection of graph_node list
  | TNodeBlank of prop_object_list list
and graph_node =
    GraphNodeVT of var_or_term
  | GraphNodeTriples of triples_node
and object_ = graph_node
and prop_object_list = {
  propol_loc : loc;
  propol_verb : verb;
  propol_objects : object_ list;
}
and triples_block = {
  triples_loc : loc;
  triples : triples_same_subject list;
}
and triples_same_subject =
    TriplesVar of var_or_term * prop_object_list list
  | TriplesNode of triples_node * prop_object_list list
and ggp_sub = { ggp_sub_loc : loc; ggp_sub_elts : graph_pattern_elt list; }
and group_graph_pattern = SubSelect of sub_select | GGPSub of ggp_sub
and sub_select = {
  subsel_loc : loc;
  subsel_select : select_clause;
  subsel_where : group_graph_pattern;
  subsel_modifier : solution_modifier;
  subsel_values : values_clause;
}
type select_query = {
  select_select : select_clause;
  select_dataset : dataset_clause list;
  select_where : group_graph_pattern;
  select_modifier : solution_modifier;
}
type triples_template = triples_same_subject list
type construct_template = triples_template
type construct_where =
    Constr_ggp of group_graph_pattern
  | Constr_template of triples_template
type construct_query = {
  constr_template : construct_template option;
  constr_dataset : dataset_clause list;
  constr_where : construct_where;
  constr_modifier : solution_modifier;
}
type describe_query = {
  desc_sel : var_or_iri list;
  desc_dataset : dataset_clause list;
  desc_where : group_graph_pattern option;
  desc_modifier : solution_modifier;
}
type ask_query = {
  ask_dataset : dataset_clause list;
  ask_where : group_graph_pattern;
  ask_modifier : solution_modifier;
}
type query_kind =
    Select of select_query
  | Construct of construct_query
  | Describe of describe_query
  | Ask of ask_query
type query = {
  q_prolog : query_prolog;
  q_kind : query_kind;
  q_values : values_clause;
}
module VarSet :
  sig
    type elt = var
    type t
    val empty : t
    val is_empty : t -> bool
    val mem : elt -> t -> bool
    val add : elt -> t -> t
    val singleton : elt -> t
    val remove : elt -> t -> t
    val union : t -> t -> t
    val inter : t -> t -> t
    val diff : t -> t -> t
    val compare : t -> t -> int
    val equal : t -> t -> bool
    val subset : t -> t -> bool
    val iter : (elt -> unit) -> t -> unit
    val fold : (elt -> 'a -> 'a) -> t -> 'a -> 'a
    val for_all : (elt -> bool) -> t -> bool
    val exists : (elt -> bool) -> t -> bool
    val filter : (elt -> bool) -> t -> t
    val partition : (elt -> bool) -> t -> t * t
    val cardinal : t -> int
    val elements : t -> elt list
    val min_elt : t -> elt
    val max_elt : t -> elt
    val choose : t -> elt
    val split : elt -> t -> t * bool * t
    val find : elt -> t -> elt
    val of_list : elt list -> t
  end
