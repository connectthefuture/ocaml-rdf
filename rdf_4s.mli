(**
   {b Rdf 4Store -
   This Module implement the http binding of 4Store}
*)

(** {6 Bindings}
    In this document:
    [url] is the server's url (including the port)
    [query] is the SPARQL query
    [graph] is the name of the graph where the query is going to be executed.
    [graph] if is equal to [url] it is executed on the default graph
    [data_type] are set at "x-turtle" by default. *)

(** [get url ?default_graph_uri ?named_graph_uri query]
    [query] If you could like to select a named-graph, it has to be made in the query.
    This method allows: select/ask/describe query.*)
val get : string -> ?default_graph_uri:string list ->
  ?named_graph_uri:string list -> string ->
  Rdf_sparql_ms.mu list Rdf_sparql_http.result Lwt.t

(** [post_update url query]
    [query] If you would like to update a named-graph, it has to be made in the query.
    This method allows: update/insert/delete query. *)
val post_update : string -> string -> unit Rdf_sparql_http.result Lwt.t

(** [delete url graph]
    This method removes the entire [graph].*)
val delete : string -> string -> unit Rdf_sparql_http.result Lwt.t

(** [put url data ?data_type graph]
    This method allows to replace initial data from [graph] by [data].
    [data] is allowed as rdf-xml type.*)
val put : string -> string -> ?data_type:string -> string ->
  unit Rdf_sparql_http.result Lwt.t

(** [post_append url data ?data_type graph]
    This method allow to append [data] into [graph].
    [data] is allow as ttl type. *)
val post_append : string -> string -> ?data_type:string -> string ->
  unit Rdf_sparql_http.result Lwt.t
