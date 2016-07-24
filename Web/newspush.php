<?php

require('config.php');
require('database.php');

$ghazal_count = 200;


function select_field($sql) {
	$conn = connect();

	$stmt = $conn->prepare($sql);
	$ret_val = 0;
	if ($stmt) {
		$stmt->execute();
	    $stmt->bind_result($ret_val);
	 	if (!$stmt->fetch()) {
	        $ret_val = -1;
	    }

	    $stmt->close();

		if ($ret_val == -1)
			die("Could not get beit count!");
	} else {
		die($stmt->error);
	}

	return $ret_val;
}

function select_all($sql) {
	$conn = connect();

	$stmt = $conn->prepare($sql);
	$ret_val = 0;
	if ($stmt) {
		$stmt->execute();
		
	    $stmt->bind_result($ret_val);
		$meta = $stmt->result_metadata(); 
		
		while ($field = $meta->fetch_field()) 
	    { 
	        $params[] = &$row[$field->name]; 
	    } 

	    call_user_func_array(array($stmt, 'bind_result'), $params); 

	    while ($stmt->fetch()) { 
	        foreach($row as $key => $val) 
	        { 
	            $c[$key] = $val; 
	        } 
	        $result[] = $c; 
	    } 

	    $stmt->close();
	} else {
		die($stmt->error);
		
		return null;
	}

	return $result;
}

// $deviceToken example: 'bed4ab2501851eab5a1f63b4d057d04a0ffb0fbb5134eab15abd3c6619fb6b95';
function send_push_notification($deviceToken, $poem, $random_ghazal_id) {
	echo "Send push note for $deviceToken, num: $random_ghazal_id\n";
	// Put your device token here (without spaces):

	// Put your private key's passphrase here:
	$passphrase = '';

	$message = $poem;
	$url = "askhafez://ghazals/$random_ghazal_id";

	if (!$message || !$url)
	    exit('Example Usage: $php newspush.php \'Breaking News!\' \'https://raywenderlich.com\'' . "\n");

	////////////////////////////////////////////////////////////////////////////////

	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', '/home/ubuntu/askhafez/PushNote/AskHafezDistPushNote.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

	// Open a connection to the APNS server
	$fp = stream_socket_client(
	  'ssl://gateway.push.apple.com:2195', $err,
	  $errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

	if (!$fp)
	  exit("Failed to connect: $err $errstr" . PHP_EOL);

	echo 'Connected to APNS' . PHP_EOL;

	// Create the payload body
	$body['aps'] = array(
	  'alert' => $message,
	  'sound' => 'default',
	  'link_url' => $url,
	  );

	// Encode the payload as JSON
	$payload = json_encode($body);

	// Build the binary notification
	$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

	// Send it to the server
	$result = fwrite($fp, $msg, strlen($msg));

	if (!$result)
	  echo 'Message not delivered' . PHP_EOL;
	else
	  echo 'Message successfully delivered' . PHP_EOL;

	// Close the connection to the server
	fclose($fp);
}

$random_ghazal_id = mt_rand(0,($ghazal_count-1));
$beit_count = select_field("SELECT COUNT(id) FROM ghazals 
										WHERE ghazal_id = $random_ghazal_id 
											AND lang = 1 
											AND mod(id, 2) = 0 ");

$random_beit = mt_rand(0,($beit_count-1));

$first_beit_id = select_field("SELECT min(id) FROM ghazals 
										WHERE ghazal_id = $random_ghazal_id");

$fa_ghazal_1 = select_field("SELECT mesra FROM ghazals 
									WHERE id = $first_beit_id + (2 * $random_beit)");
$fa_ghazal_2 = select_field("SELECT mesra FROM ghazals 
									WHERE id = $first_beit_id + (2 * $random_beit) + 1");


print "ghazal_id: $random_ghazal_id, first_beit_id: $first_beit_id, beit_count: $beit_count\n";
print $fa_ghazal_1 . " " . $fa_ghazal_2;

$poem = $fa_ghazal_1 . "\n" . $fa_ghazal_2;

$result = select_all("SELECT token FROM user WHERE type = 'ios'");
foreach ($result as $user) {
	send_push_notification($user['token'], $poem, $random_ghazal_id);
}



