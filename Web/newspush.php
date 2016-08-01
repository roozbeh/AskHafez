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

function create_payload($poem, $random_ghazal_id) {
	$message = $poem;
	$url = "askhafez://ghazals/$random_ghazal_id";

	// Create the payload body
	$body['aps'] = array(
	  'alert' => $message,
	  'sound' => 'default',
	  'link_url' => $url,
	  );
	
	return $body;
}

// $deviceToken example: 'bed4ab2501851eab5a1f63b4d057d04a0ffb0fbb5134eab15abd3c6619fb6b95';
function send_push_notification_ios($deviceToken, $body) {
	echo "Send push note for $deviceToken\n";
	// Put your device token here (without spaces):

	// Put your private key's passphrase here:
	$passphrase = '';

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

function send_push_notification_android($deviceToken, $data)
{
	$ids = array($deviceToken);
	
    // Insert real GCM API key from the Google APIs Console
    // https://code.google.com/apis/console/        
    $apiKey = 'AIzaSyDQdGPQTmAgO3uwda29Wwat1zU481XLPtQ';

    // Set POST request body
    $post = array(
                    'registration_ids'  => $ids,
                    'data'              => $data,
                 );

    // Set CURL request headers 
    $headers = array( 
                        'Authorization: key=' . $apiKey,
                        'Content-Type: application/json'
                    );

    // Initialize curl handle       
    $ch = curl_init();

    // Set URL to GCM push endpoint     
    curl_setopt($ch, CURLOPT_URL, 'https://gcm-http.googleapis.com/gcm/send');

    // Set request method to POST       
    curl_setopt($ch, CURLOPT_POST, true);

    // Set custom request headers       
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    // Get the response back as string instead of printing it       
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    // Set JSON post data
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($post));

    // Actually send the request    
    $result = curl_exec($ch);

    // Handle errors
    if (curl_errno($ch))
    {
        echo 'GCM error: ' . curl_error($ch);
		return false;
    }

    // Close curl handle
    curl_close($ch);

    $obj = json_decode($result);
    if ($obj && $obj->success) {
	  	echo "Message successfully delivered to $deviceToken" . PHP_EOL;
		return true;
    }

  	echo "Message not delivered to $deviceToken" . PHP_EOL;

    return false;
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

$payload = create_payload($poem, $random_ghazal_id);

$result = select_all("SELECT token FROM user WHERE type = 'ios'");
foreach ($result as $user) {
	send_push_notification_ios($user['token'], $payload);
}

$result = select_all("SELECT token FROM user WHERE type = 'android'");
foreach ($result as $user) {
	send_push_notification_android($user['token'], $payload);
}





