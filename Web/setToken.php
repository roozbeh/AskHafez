<?php

require('config.php');
require('database.php');

header('Content-Type: application/json');

if (!isset($_POST["token"]) || !isset($_POST["os"]) || !isset($_POST["uniq"])) {
	echo json_encode(array("success" => false, "msg" => "Not all params defined!"));
	return;
}

$conn = connect();

$stmt = $conn->prepare("SELECT id FROM user WHERE token = ?");
if ($stmt) {
	$stmt->bind_param("s", $_POST["token"]);
	$stmt->execute();
    $stmt->bind_result($count);
 	if (!$stmt->fetch()) {
        $count = 0;
    }

    $stmt->close();

	if ($count > 0) {
		echo json_encode(array("success" => false, "msg" => "already exists"));
		return;
	}
}

$sth = $conn->prepare("INSERT INTO user (uniq, type, token, created) VALUES (?, ?, ?, NOW())");
if ($sth) {
	$sth->bind_param("sss", $_POST["uniq"], $_POST["os"], $_POST["token"]);
	$sth->execute();
	$sth->close();

	echo json_encode(array("success" => true));
	return;
} else {
	error_log("Error: " . $conn->error ."\n");
}

echo json_encode(array("success" => false));
return;

?>