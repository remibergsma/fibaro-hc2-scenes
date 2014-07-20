<?php 
	if(isset($_GET['trigger']) && $_GET['trigger'] == 1) {
		error_reporting(E_ALL);
		if(isset($_GET['rings']) && $_GET['rings'] >=0 ) {
			$rings = $_GET['rings'];
		} else {
			$rings = 1;
		}

		for ($x=0; $x<$rings; $x++) {
		   exec('gpio write 7 0');
		   usleep(250000);
		   exec('gpio write 7 1');
		   usleep(150000);
		}
	}
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Doorbell</title>
	</head>
	<body>
    <a href='/?trigger=1'></a>
	</body>
</html>
