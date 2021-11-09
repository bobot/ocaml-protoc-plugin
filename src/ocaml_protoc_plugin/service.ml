(** Service v1 *)
module type Message = sig
  type t
  val from_proto: Reader.t -> t Result.t
  val to_proto: t -> Writer.t
end

let make_client_functions (type req) (type rep)
    ((module Request : Message with type t = req),
     (module Response : Message with type t = rep)) =
  Request.to_proto, Response.from_proto

let make_service_functions (type req) (type rep)
    ((module Request : Message with type t = req),
    (module Response : Message with type t = rep)) =
  Request.from_proto, Response.to_proto


(** Services v2 *)
type yes = Yes_t
type no = Not_t
type 'a feature_availability =
  | Yes : yes feature_availability
  | No : no feature_availability
  (** Used to indicate that a service as some feature or not *)

module type Rpc = sig
  module Request : Message
  module Response : Message
  val name : string
  type client_streaming
  type server_streaming
  val client_streaming: client_streaming feature_availability
  val server_streaming: server_streaming feature_availability
end

type ('req,'rep,'cs,'ss) service =
    (module Rpc with type Request.t = 'req and type Response.t = 'rep and
      type client_streaming = 'cs and
      type server_streaming = 'ss)

let make_client_functions' (type req rep cs ss) (r:(req,rep,cs,ss) service) =
  let module R = (val r) in
  R.name, R.Request.to_proto, R.Response.from_proto

let make_service_functions' (type req rep cs ss) (r:(req,rep,cs,ss) service) =
  let module R = (val r) in
  R.name, R.Request.from_proto, R.Response.to_proto
