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

type yes = [ `Yes ]
type no  = [ `No ]

module type Rpc = sig
  module Request : Message
  module Response : Message
  val name : string
  type client_streaming
  type server_streaming
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
