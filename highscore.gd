extends Node

const MIN = "0-5"
const MED = "6-12"
const MAX = "13+"


var get_highscore_request = HTTPRequest
var put_highscore_request = HTTPRequest
var get_highscore_url: String			
var put_highscore_url: String
var secret: String

signal highscore_updated(highscore)


func _ready() -> void:	
	var credentials = JSON.parse_string(FileAccess.get_file_as_string('res://server/credentials.json'))
	secret = credentials['score-url-secret']
	get_highscore_url = credentials['score-url']
	put_highscore_url = credentials['score-url']
	
	get_highscore_request = HTTPRequest.new()
	add_child(get_highscore_request)
	get_highscore_request.request_completed.connect(_on_get_highscore_request_request_completed)
	
	put_highscore_request = HTTPRequest.new()
	add_child(put_highscore_request)
	put_highscore_request.request_completed.connect(_on_put_highscore_request_request_completed)


func receive_highscore() -> void:
	get_highscore_request.request(get_highscore_url)
	
	
func put_highscore(user_name: String, score: int, group: String) -> void:
	# create nonce for basic replay protection
	var crypto := Crypto.new()
	var nonce = crypto.generate_random_bytes(4).decode_u32(0)
	
	var headers: Array[String] = ["Content-Type: application/json"]
	var  http_data_json: Dictionary = {
		"secret_key": secret,
		"nonce": "%X" % [nonce],
		"score_data": {
			"name": user_name.substr(0, 30),
			"score": score,
			"group": group
		}
	}
	var http_data_string = encode(encrypt(JSON.stringify(http_data_json), secret))
	put_highscore_request.request(put_highscore_url,headers,HTTPClient.METHOD_PUT,http_data_string)


func encrypt(data: String, key: String) -> PackedByteArray:
	var key_buffer = key.to_utf8_buffer()
	var data_buffer = data.to_utf8_buffer()
	
	# weak, self-made encryption (to avoid interop problems with PHP)
	var crypt = PackedByteArray()
	for i in range(data_buffer.size()):
		crypt.append(data_buffer[i] ^ key_buffer[i % key_buffer.size()])

	return crypt
	
func encode(msg: PackedByteArray) -> String:
	return Marshalls.raw_to_base64(msg)

func _on_get_highscore_request_request_completed(_result, response_code, _headers, body) -> void:
	if response_code == 200:
		var response_text: String = body.get_string_from_utf8()
		var score_list: Array = JSON.parse_string(response_text)
		score_list.sort_custom(func(a, b): return a["score"] > b["score"])
		var highscore: Dictionary = {MIN: [], MED: [], MAX: []}
		for i in range(score_list.size()):
				highscore[score_list[i]["group"]].append(score_list[i])
		highscore_updated.emit(highscore)
		
	else:
		print("Request failed with response code:", response_code)



func _on_put_highscore_request_request_completed(_result, response_code, headers, body) -> void:
	if response_code in range(200, 300):
		print("Data has been PUT successfully.")
	else:
		print("Request failed with response code:", response_code)
		print("Request failed with response headers:", headers)
		print("Request failed with response body:", body.get_string_from_utf8())
