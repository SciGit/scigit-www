<?php

class REST_Controller extends CI_Controller
{
	protected $http_method = null;
	protected $args = array();

	public function __construct() {
		parent::__construct();

		$method = $_SERVER['REQUEST_METHOD'];
		if ($method == 'PUT' || $method == 'DELETE') {
			parse_str(file_get_contents('php://input'), $this->args);
			if ($this->input->get()) {
				$this->args = array_merge($this->args, $this->input->get());
			}
		} else if ($method == 'GET') {
			$this->args = $this->input->get();
		} else {
			if ($this->input->post()) {
				$this->args = $this->input->post();
			}
			if ($this->input->get()) {
				$this->args = array_merge($this->args, $this->input->get());
			}
		}
		$this->http_method = $method;

		$this->load->model('auth_token');
	}

	public function authenticate() {
		$username = $this->get_arg('username');
		$auth_token = $this->get_arg('auth_token');
		if (!$username || !$auth_token) {
			$this->error(400);
		}

		$user = $this->user->get_user_by_login($username);
		if (!$user) {
			$this->error(400);
		}

		if (!$this->auth_token->authenticate($user->id, $auth_token)) {
			$this->error(403);
		}
		return $user;
	}

	function _remap($method, $params = array()) {
		$new_method = $method . '_' . strtolower($this->http_method);
		if (method_exists($this, $new_method)) {
			call_user_func_array(array($this, $new_method), $params);
		} else {
			$this->error(404);
		}
	}

	protected function get_arg($name) {
		if (isset($this->args[$name])) {
			return $this->args[$name];
		}
		return null;
	}

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
