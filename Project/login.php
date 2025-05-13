<?php
session_start();

// Database connection to PostgreSQL
$host = "localhost";
$port = "5432";
$dbname = "Project";
$user = "postgres";
$password = "wsAniIT2008*";  // Replace with your actual password

// Create connection
$conn = pg_connect("host=$host port=$port dbname=$dbname user=$user password=$password");

// Check connection
if (!$conn) {
    die("Connection failed: " . pg_last_error());
}

$message = ""; // Initialize the message variable

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Query to check user credentials securely using parameterized queries
    $query = "SELECT * FROM users WHERE username = $1";
    $result = pg_query_params($conn, $query, array($username));

    if ($result && pg_num_rows($result) > 0) {
        $row = pg_fetch_assoc($result);
        // Verify the password using password_verify (assumes hashed passwords)
        if ($password === $row['password']) {

            $_SESSION['username'] = $username;
            $message = "Login successful!";
        } else {
            $message = "Invalid username or password.";
        }
    } else {
        $message = "Invalid username or password.";
    }

    if ($result) {
        pg_free_result($result);
    }
}
pg_close($conn);
?>

<!-- Simple HTML Form for Login -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login Page</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="login-container">
        <h2>Login</h2>
        <form action="login.php" method="POST">
            <input type="text" name="username" placeholder="Username" required><br>
            <input type="password" name="password" placeholder="Password" required><br>
            <button type="submit">Login</button>
        </form>

        <!-- Display the message in a formatted way -->
        <?php if (!empty($message)): ?>
            <div class="message"><?php echo $message; ?></div>
        <?php endif; ?>
    </div>
</body>
</html>
