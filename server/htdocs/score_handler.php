<?php
error_reporting(0);
// Define the file path for score storage
$score_file = 'score.json';
$credentials_file = '../credentials.json';
$nonces_file = '../nonces.bin';

// Ensure the score file exists and initialize it if it does not
if (!file_exists($score_file)) {
    file_put_contents($score_file, json_encode(["score" => []]));  // Initialize with an empty dictionary
}

// Ensure the credentials file exists and initialize it if it does not
if (!file_exists($credentials_file)) {
    die(__FILE__.__LINE__." credentials file does not exist");
}

$credentials = json_decode(file_get_contents($credentials_file), true);

if (json_last_error() !== JSON_ERROR_NONE
    || !isset($credentials['score-url-secret'])) {
    die(__FILE__.__LINE." credentials file is corrput.");
} else {
    $secret_key = $credentials['score-url-secret'];
}

// make score board accessible from other website, e.g. mirrors like itch.io or github
header("Access-Control-Allow-Origin: *");


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
            echo("\n$integer");
        }
    }
    if(!$value_present) {
        fwrite($file, pack('L',$value));
    }
    fclose($file);
    return !$value_present;
}

function decode_and_decrypt($input_data, $key) {
    $decoded = sodium_base642bin($input_data, SODIUM_BASE64_VARIANT_ORIGINAL);
    $decrypted = "";
    for ($i = 0; $i < strlen($decoded); $i++) {
            $dec = ord($decoded[$i]);
            $k = ord($key[$i%strlen($key)]);
            $m = $dec ^ $k;
            $c = chr($m);
            $decrypted .= $c;
    }
    return $decrypted;
}

// Handle GET requests
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Read the content of score.json
    $score_content = file_get_contents($score_file);

    // Set the response code to 200 and output the content
    http_response_code(200);
    header('Content-Type: application/json');
    echo $score_content;
    exit();
}

// Handle PUT requests
elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Get the raw data from the PUT request
    $input_data = file_get_contents('php://input');
    // decrypt it
    $decrypted = decode_and_decrypt($input_data, $secret_key);

    $json_data = json_decode($decrypted, true);


    // Check if JSON decoding was successful and "secret_key" matches
    if (json_last_error() === JSON_ERROR_NONE
        && check_and_write_nonce($nonces_file, $json_data)) {
        // Check if "score_data" exists in the received data and is a dictionary
        if (isset($json_data['score_data']) && is_array($json_data['score_data'])) {
            // Read the existing score data from file
            $current_score_data = json_decode(file_get_contents($score_file), true);
            $current_score = $current_score_data ?? [];

            // Merge the new score data with the existing score data
            $json_data["score_data"]["date"] = date("Y-m-d");
            $json_data["score_data"]["name"] = preg_replace('/[^\-\+\d\w ]/', '', $json_data["score_data"]["name"]);
            $updated_score = array_merge($current_score, [$json_data['score_data']]);

            // Write the updated score back to the file
            file_put_contents($score_file, json_encode($updated_score));

            // Respond with HTTP 202 Accepted
            http_response_code(202);
            echo json_encode(["message" => "Score updated successfully."]);
        } else {
            // Missing or invalid "score" field (not a dictionary)
            http_response_code(400);
            echo json_encode(["error" => "Invalid data."]);
        }
    } else {
        // Invalid secret key or JSON structure
        http_response_code(403);
        echo json_encode(["error" => "Unauthorized or missing data."]);
    }
    exit();
}

// Respond with 405 Method Not Allowed for unsupported methods
else {
    http_response_code(405);
    echo json_encode(["error" => "Not allowed."]);
    exit();
}
?>
