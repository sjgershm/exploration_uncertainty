<?php
	$filename = $_POST['postfile'];
	$result = $_POST['postresult'];
    file_put_contents($filename,$result,FILE_APPEND);
?>