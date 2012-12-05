<?php
	class FeatureCollection
	{
		private $features = array();
		private $extra = array();
		
		function add($featurestring) 
		{ 
			array_push($this->features,$featurestring);
		}
		function addExtra($key,$str) 
		{ 
			$this->extra[$key] = $str;
		}
		
		function makeFC()
		{
		    $extras = '';
		    if (count($this->extra)>0) {
		        foreach ($this->extra as $key => $val) {
		            $extras .= '"' . $key . '":' . $val . ',';
		        }
		    }
			return '{"type" : "FeatureCollection",'.
			    $extras.
				'"features":['.
					implode(",\n\n", $this->features) .
				']}';
		}
	}
	
