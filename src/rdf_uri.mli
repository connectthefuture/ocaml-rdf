(** URIs. *)

type uri

val string : uri -> string
val uri : string -> uri

val concat : uri -> string -> uri

