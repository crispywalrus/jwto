(* Fixtures *)

let (header_fixture:Jwt.header) =
	{alg = Jwt.HS256; typ = None}

let header_json =
	"{\"alg\":\"HS256\"}"

let payload_fixture =
	[
		("user", "sam");
	]

let secret =
	"abc"

let (unsigned_token_fixture:Jwt.unsigned_token) =
	{
		header = header_fixture;
		payload = payload_fixture;
	}

let (signed_token_fixture:Jwt.t) =
	{
		header = unsigned_token_fixture.header;
		payload = unsigned_token_fixture.payload;
		signature = Jwt.sign secret unsigned_token_fixture;
	}

let token =
	"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoic2FtIn0.S2j6W5w25AS0avioniNFIYJeeospOVyO5fqApYoUMho"

(* Test helpes *)

let compareT =
	Alcotest.testable
		Jwt.pp
		Jwt.eq

let resultT =
	Alcotest.result
		compareT
		Alcotest.string

(* Test encoding *)

let encode_header () =
	Alcotest.(check string)
		"It encodes"
		header_json
		(Jwt.header_to_string header_fixture)


let header_to_string = [
	"Encodes the header", `Quick, encode_header;
]

let empty_payload () =
	Alcotest.(check string)
		"empty" 
		"{}"
		(Jwt.payload_to_string [])


let with_payload () =
	Alcotest.(check string)
		"with payload" 
		"{\"hello\":\"word\"}"
		(Jwt.payload_to_string [( "hello", "word" )])

let payload_to_string = [
	"Empty payload", `Quick, empty_payload;
	"With payload", `Quick, with_payload;
]

let encode_test () =
	Alcotest.(check string)
		"encodes"
		token
		(Jwt.encode
			Jwt.HS256 
			secret 
			payload_fixture
		)

let encode = [
	"It encodes", `Quick, encode_test;
]

(* Test Decoding *)

let decode_test () =
	Alcotest.(check resultT)
		"decodes"
		(Ok signed_token_fixture)
		(Jwt.decode token)

let decode_fail_test () =
	Alcotest.(check resultT)
		"it fails to decode"
		(Error "Bad token")
		(Jwt.decode "Monkey")

let decode = [
	"It decodes", `Quick, decode_test;
	"It can fail to decode", `Quick, decode_fail_test;
]

let is_valid_true () =
	Alcotest.(check bool)
		"true"
		true
		(Jwt.is_valid secret signed_token_fixture)

let is_valid_false () =
	Alcotest.(check bool)
		"false"
		false
		(Jwt.is_valid "xyz" signed_token_fixture)

let is_valid = [
	"It returns true when valid", `Quick, is_valid_true;
	"It returns false when invalid", `Quick, is_valid_false;
]

let decode_and_verify_ok () =
	Alcotest.(check resultT)
		"decodes"
		(Ok signed_token_fixture)
		(Jwt.decode_and_verify secret token)

let decode_and_verify_err () =
	Alcotest.(check resultT)
		"decodes"
		(Error "Invalid token")
		(Jwt.decode_and_verify "xyz" token)

let decode_and_verify = [
	"It decodes when valid", `Quick, decode_and_verify_ok;
	"It doesn't decode when invalid", `Quick, decode_and_verify_err;
]

let () =
	Alcotest.run "JWT" [
		"Encode header", header_to_string;
		(* "Decode header", header_decode_tests; *)
		"Encode payload", payload_to_string;
		"Encode JWT", encode;
		"Decode token", decode;
		"Verify JWT", is_valid;
		"Decode and verify", decode_and_verify;
	]