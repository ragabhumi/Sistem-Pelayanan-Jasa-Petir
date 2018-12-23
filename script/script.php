<?php
    $tanggal= $_POST['tanggal'];
	$bujur= $_POST['bujur'];
	$lintang= $_POST['lintang'];
	$jam_awal= $_POST['jam_awal'];
	$jam_akhir= $_POST['jam_akhir'];
    $file = 'program.bat';
    // Open the file to get existing content
    $current = file_get_contents($file);
    // Append a new person to the file
    $current = "C:\Python27\python.exe konversi.py $tanggal $bujur $lintang $jam_awal $jam_akhir";
    // Write the contents back to the file
    file_put_contents($file, $current);
    exec("program.bat");
?>
