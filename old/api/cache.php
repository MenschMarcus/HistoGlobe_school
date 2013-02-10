<?php

/**
* This function write into a file by using an exclusive lock mechanism
* @param filename : filename (can be with its path)
* @param content : the content to write in the file
* @return : true if everything is ok, or an error message if something went bad 
*/
function writeCache($fileName, $content)
{
	$directory = "../cache/";

	// make sure directory exists, ignore errors
	@mkdir($directory);
	@chgrp($directory, "histodev");
	
	$fileName = $directory . $fileName;
	
	// Create and open a new file
	$myFile = @fopen($fileName, "x+");
	
	// We check that the file is correclty opened
	if($myFile !==FALSE)
	{
		// In order to work safely we do an exclusive lock
		if (flock($myFile, LOCK_EX))
		{
			fwrite($myFile, gzencode($content,9));
			
			// Once the job is done we release the lock
			flock($myFile, LOCK_UN); 
		
			// We close the file only if we have opened it before.
			fclose($myFile);
			@chgrp($fileName, "histodev");
			
			return true;
		}
		else
		{
			return "Cannot get the lock on the file !";
		}
	}
	else
	{
		return "Cannot open the file : maybe you have a permission problem, contact your administrator";
	}
}


function getCache($fileName)
{
	$directory = "../cache/";

	$fileName = $directory . $fileName;
	
	$myFile = FALSE;
	// If the file exists
	if(file_exists($fileName))
	{
		// Open a file called in 'read' mode
		$myFile = fopen($fileName, "r");
	} else {
		return FALSE;
	}
	
	if($myFile !== FALSE)
	{
		if (flock($myFile, LOCK_EX))
		{
			$content = gzdecode(file_get_contents($fileName));


			// Once the job is done we release the lock
			flock($myFile, LOCK_UN); 
		
			// We close the file only if we have opened it before.
			fclose($myFile);
			return $content;
		}
		else
		{
			return "Cannot get the lock on the file !";
		}
	}
	else
	{
		return FALSE;
	}
}

/**
 * Return decompressed gzip string. This is needed because gzdecode is not yet implemented in PHP (?!)
 */
function gzdecode($data)
{
   return gzinflate(substr($data,10,-8));
} 

