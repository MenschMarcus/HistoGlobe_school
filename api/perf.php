<?php
// measure timing of blocks of code
class PerfMon {
	private $meas;
	private $t;
	function __construct() {
		$this->meas = array();
		$this->meas['_total'] = 0;
		$this->t    = array();
		$this->t['_total'] = microtime(true);
	}
	function start($id) {
		$this->t[$id] = microtime(true);
	}	
	function stop($id) {
		$stop = microtime(true);
		if (isset($this->meas[$id])) {
			$this->meas[$id] += $stop - $this->t[$id];
		} else {
			$this->meas[$id] = $stop - $this->t[$id];
		}
	}
	function printout() {
		$stop = microtime(true);
		print '<pre>';
		$this->meas['_total'] += $stop - $this->t['_total'];
		print_r($this->meas);
	}
}
$_pf = new PerfMon();
