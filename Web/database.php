<?php

function connect() {
	// Create connection
	$conn = new mysqli(constant("DB_SERVERNAME"), constant('DB_USERNAME'), DB_PASSWORD, DB_NAME);
	// Check connection
	if ($conn->connect_error) {
	    die("Connection failed: " . $conn->connect_error);
	} 

	$conn->set_charset("utf8");
	$conn->query("SET NAMES 'utf8'");	
	
	return $conn;
}

function disconnect($conn) {
	$conn->close();
}

function get_channel_local_addr($channel_id) {
	$conn = connect();
	$ret = null;
	
	if ($stmt = $conn->prepare("SELECT local_addr FROM channel WHERE id = ?")) {
	    $stmt->bind_param("s", $channel_id);
	    $stmt->execute();
	    $stmt->bind_result($local_addr);
	    $stmt->fetch();
	    $stmt->close();
	}

	return $local_addr;
}

function fetchAssocStatement($stmt)
{
    if($stmt->num_rows>0)
    {
        $result = array();
        $md = $stmt->result_metadata();
        $params = array();
        while($field = $md->fetch_field()) {
            $params[] = &$result[$field->name];
        }
        call_user_func_array(array($stmt, 'bind_result'), $params);
        if($stmt->fetch())
            return $result;
    }

    return null;
}

function get_channel($channel_id) {
	$conn = connect();
	$channel = array();
	
	if ($stmt = $conn->prepare("SELECT name, image_url, stream_url, local_addr, playlist FROM channel WHERE id = ?")) {
	    $stmt->bind_param("s", $channel_id);
	    $stmt->execute();
		$stmt->store_result();

		$channel = fetchAssocStatement($stmt);
	}

	return $channel;
}

function get_song_artist_image($filename) {
	$conn = connect();
	$sql = "SELECT a.image_url as artist_image 
			FROM song s INNER JOIN artist a on s.artist_id = a.id 
			WHERE s.filename = ?";

	$artist_image = null;
	if ($stmt = $conn->prepare($sql)) {
	    $stmt->bind_param("s", $filename);
	    $stmt->execute();
	    $stmt->bind_result($artist_image);
	    $stmt->fetch();
	    $stmt->close();
	}

	return $artist_image;
}

?>
