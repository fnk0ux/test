<?php
// Define your functions
function sayHello() {
    echo "Hello!";
}

function sayBye() {
    echo "Goodbye!";
}

// Whitelist of allowed functions
$allowed = ['sayHello', 'sayBye'];

// Check if URL has ?func=...
if (isset($_GET['func']) && in_array($_GET['func'], $allowed)) {
    $func = $_GET['func'];
    $func(); // call the function
} else {
    echo "Function not allowed!";
}
?>
