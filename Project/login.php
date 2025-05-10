

<?php
session_start();

// Database connection to PostgreSQL using pg_connect
$host = "localhost";
$port = "5432";
$dbname = "project_db";
$user = "postgres";
$password = "your_password";

// Create connection
$conn = pg_connect("host=$host port=$port dbname=$dbname user=$user password=$password");

// Check connection
if (!$conn) {
    die("Connection failed: " . pg_last_error());
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $user = $_POST['username'];
    $pass = $_POST['password'];

    // Query to check user credentials
    $query = "SELECT * FROM users WHERE username = $1 AND password = $2";
    $result = pg_query_params($conn, $query, array($user, $pass));

    if (pg_num_rows($result) > 0) {
        $_SESSION['username'] = $user;
        echo "Login successful!";
    } else {
        echo "Invalid username or password.";
    }
    pg_free_result($result);
}
pg_close($conn);
?>
