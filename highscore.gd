extends Node

const MIN = "0-5"
const MED = "6-12"
const MAX = "13+"


var get_highscore_request: HTTPRequest
var put_highscore_request: HTTPRequest
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
	var crypto = Crypto.new()
	var nonce = crypto.generate_random_bytes(4).decode_u32(0)
	var iv = crypto.generate_random_bytes(16)
	
	var headers: Array[String] = ["Content-Type: application/json"]
	var score_data = {
			"name": user_name.substr(0, 30),
			"score": score,
			"group": group,
			"nonce": "%X" % [nonce]
		}
	
	var encrypted_score_data: PackedByteArray = encrypt(
			pkcs7_pad(JSON.stringify(score_data).to_utf8_buffer(), 16),
			secret.to_utf8_buffer(),
			iv
		)
		
	var data = {
		"cipher_text_b64": base64(encrypted_score_data),
		"iv_b64": base64(iv)
		}
	var data_string = JSON.stringify(data)
	
	put_highscore_request.request(put_highscore_url,headers,HTTPClient.METHOD_PUT,data_string)


func encrypt(data: PackedByteArray, key: PackedByteArray, iv: PackedByteArray) -> PackedByteArray:
	# Encrypt with AES-128-CBC
	var aes = AESContext.new()
	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)
	var encrypted = aes.update(data)
	aes.finish()
	return encrypted
	
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


func base64(data: PackedByteArray) -> String:
	return Marshalls.raw_to_base64(data)


func pkcs7_pad(data: PackedByteArray, block_size: int) -> PackedByteArray:
	var pad_length = block_size - (data.size() % block_size)
	data.resize(data.size() + pad_length)
	
	# Fill the padding with the pad_length value.
	for i in range(pad_length):
		data[- i - 1] = pad_length

	return data


func _on_put_highscore_request_request_completed(_result, response_code, headers, body) -> void:
	if response_code in range(200, 300):
		print("Data has been PUT successfully.")
		print(body.get_string_from_utf8())
	else:
		print("Request failed with response code:", response_code)
		print("Request failed with response headers:", headers)
		print("Request failed with response body:", body.get_string_from_utf8())
