<?php
error_reporting(E_ALL);
// Define the file path for score storage
$score_file = 'score.json';
$credentials_file = '../credentials.json';
$nonces_file = '../nonces.bin';


switch ($_SERVER['REQUEST_METHOD']) {
    case "GET":
        handle_get_request();
        break;
    case "OPTIONS":
        handle_options_request();
        break;
    case "PUT":
        handle_put_request();
        break;
    default:
        handle_not_allowed();
}

function handle_get_request() {
    global $score_file;
    ensure_score_file();

    // Read the content of score.json
    $score_content = file_get_contents($score_file);

    // Set the response code to 200 and output the content
    http_response_code(200);
    header('Content-Type: application/json');
    header("Access-Control-Allow-Origin: " . $_SERVER['HTTP_ORIGIN']);
    header("Access-Control-Allow-Methods: GET, PUT, OPTIONS");
    header("Access-Control-Allow-Headers: X-Requested-With, Content-Type");
    echo $score_content;
    exit();
}

function handle_options_request() {
    // Set the response code to 204
    http_response_code(204);
    header("Access-Control-Allow-Origin: " . $_SERVER['HTTP_ORIGIN']);
    header("Access-Control-Allow-Methods: GET, PUT, OPTIONS");
    header("Access-Control-Allow-Headers: X-Requested-With, Content-Type");
    header("Access-Control-Max-Age: 86400");
    exit();
}

function handle_put_request() {
    global $score_file, $nonces_file;

    // make score board accessible from other website, e.g. mirrors like itch.io or github
    header("Access-Control-Allow-Origin: " . $_SERVER['HTTP_ORIGIN']);

    $secret_key = load_secret_key();
    ensure_score_file();
    // Get the raw data from the PUT request
    $json_string = file_get_contents('php://input');
    // decrypt it
    $json = json_decode($json_string, true);
    $cipher_text_b64 = $json["cipher_text_b64"];
    $iv = base64_decode($json["iv_b64"]);
    $decrypted = openssl_decrypt(
        $cipher_text_b64,
        "aes-128-cbc",
        $secret_key,
        0, //OPENSSL_RAW_DATA,
        $iv
    );
    if($decrypted === false) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid data, decryption failed."]);
        die();
    }

    $json_data = json_decode($decrypted, true);

    echo "=======" . print_r($json_data, true) . "====" .PHP_EOL;

    // Check if JSON decoding was successful and "secret_key" matches
    if (json_last_error() === JSON_ERROR_NONE
        && check_and_write_nonce($nonces_file, $json_data)) {
        // Check if "score_data" exists in the received data and is a dictionary
        if (is_array($json_data) && isset($json_data['name']) && isset($json_data['score']) && isset($json_data['group'])) {
            // Read the existing score data from file
            $current_score_data = json_decode(file_get_contents($score_file), true);
            $current_score = $current_score_data ?? [];

            // Merge the new score data with the existing score data
            unset($json_data["nonce"]);
            $json_data["date"] = date("Y-m-d");
            $json_data["name"] = preg_replace('/\s+/', ' ', $json_data['name']);
            $json_data["name"] = preg_replace('/[\{\}\'\",\\:\[\]]/', '', $json_data["name"]);
            $updated_score = array_merge($current_score, [$json_data]);

            // Write the updated score back to the file
            file_put_contents($score_file, json_encode($updated_score));

            // Respond with HTTP 202 Accepted
            http_response_code(202);
            echo json_encode(["message" => "Score updated successfully."]);
        } else {
            // Missing or invalid "score" field (not a dictionary)
            http_response_code(400);
            echo json_encode(["error" => "Invalid data, fields missing."]);
        }
    } else {
        // Invalid secret key or JSON structure
        http_response_code(403);
        echo json_encode(["error" => "Unauthorized or missing data."]);
    }
    exit();
}

function handle_not_allowed() {
    http_response_code(405);
    echo json_encode(["error" => "Not allowed."]);
    exit();
}

function ensure_score_file() {
    global $score_file;
    // Ensure the score file exists and initialize it if it does not
    if (!file_exists($score_file)) {
        file_put_contents($score_file, json_encode(["score" => []]));  // Initialize with an empty dictionary
    }
}

function load_secret_key() {
    global $credentials_file;
    // Ensure the credentials file exists and initialize it if it does not
    if (!file_exists($credentials_file)) {
        die(__FILE__.__LINE__." credentials file does not exist");
    }
    $credentials = json_decode(file_get_contents($credentials_file), true);

    if (json_last_error() !== JSON_ERROR_NONE
        || !isset($credentials['score-url-secret'])) {
        die(__FILE__.__LINE." credentials file is corrput.");
    } else {
        return $credentials['score-url-secret'];
    }
}


function check_and_write_nonce($filename, $json_data) {
    if(!isset($json_data['nonce'])) {
        return false;
    }
    $value = hexdec($json_data['nonce']);
    $value_present = false;
    $file = fopen($filename, "a+");
    fseek($file, 0);
    while (!feof($file)) {
        $input = fread($file, 4);
        if($input) {
            $integer = unpack('L', $input)[1];
            if($integer == $value) {
                $value_present = true;
                break;
            }
        }
    }
    if(!$value_present) {
        fwrite($file, pack('L',$value));
    }
    fclose($file);
    return !$value_present;
}

?>
