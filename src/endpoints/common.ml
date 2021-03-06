open Meta_conv.Open
open Json_conv
open Tiny_json

let cal_format_iso8601 = "%Y-%m-%dT%H:%M:%S%z" 

let cal_format_us_date = "%m/%d/%Y"
 
let x_of_json converter ?trace j =
  let err type' = 
    let t = match trace with | Some t -> t | None -> [] in
    let msg = Printf.sprintf "Expected string, found %s" type' in
    `Error (Meta_conv.Error.Primitive_decoding_failure msg, j, t)
  in
  match j with 
  | Json.String s -> `Ok (converter s)
  | Json.Number _ -> err "number"
  | Json.Array _ -> err "array"
  | Json.Bool _ -> err "bool"
  | Json.Null -> err "null"
  | Json.Object o -> err "object"

type 'a decoder = ('a, Tiny_json.Json.t) Meta_conv.Types.Decoder.t

type calendar_iso8601 = CalendarLib.Calendar.t

let calendar_iso8601_of_json = 
  x_of_json (CalendarLib.Printer.Calendar.from_fstring cal_format_iso8601)
  
type calendar_us_date = CalendarLib.Calendar.t

let calendar_us_date_of_json = 
  x_of_json (CalendarLib.Printer.Calendar.from_fstring cal_format_us_date)

type uri = Uri.t

let uri_of_json = x_of_json Uri.of_string


module NumberRange = struct
  type t = {
    min            : int;
    max            : int;
  } with conv(of_json)
end


module type PagedResponse = sig
  
  type data
  
  type cursors = {
		after : string;
		before : string;
  }
  
  type page_navigation = {
    next : uri option;
    previous : uri option;
		cursors : cursors option;
  } 
  
  type t = { 
    data : data list; 
    paging : page_navigation option; 
  }
  
  val t_of_json : t decoder
  
end