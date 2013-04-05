<?php

class SciGit_Controller extends CI_Controller
{
	protected function set_status($code) {
		header('HTTP/1.1: ' . $code);
		header('Status: ' . $code);
	}

	protected function response($data = array(), $code = 200) {
		$this->set_status($code);
		header('Content-Type: application/json');
		exit(json_encode($data));
	}

	protected function error($code) {
		$this->set_status($code);
		header('Content-Type: application/json');
		exit();
	}
}
