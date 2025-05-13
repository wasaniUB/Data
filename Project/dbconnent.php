<?php
// Database connection to PostgreSQL
$host = "localhost";
$port = "5432";
$dbname = "Project";  // Make sure the name is exactly as it appears in pgAdmin
$user = "postgres";
$password = "wsAniIT2008*";  // Your actual password

// Connection string
$conn_string = "host=$host port=$port dbname=$dbname user=$user password=$password";

// Create connection
$conn = pg_connect($conn_string);

// Check connection
if (!$conn) {
    echo "Error: Unable to connect to the database.<br>";
    echo "Details: " . pg_last_error();
} else {
    echo "Database connection established successfully.";
}
?>
