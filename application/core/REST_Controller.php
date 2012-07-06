<?

class REST_Controller extends CI_Controller
{
	protected $http_method = null;
	protected $args = array();

	public function __construct() {
		parent::__construct();

		$method = $_SERVER['REQUEST_METHOD'];
		if ($method == 'PUT' || $method == 'DELETE') {
			parse_str(file_get_contents('php://input'), $this->args);
		} else if ($method == 'GET') {
			$this->args = $this->input->get();
		} else {
			$this->args = $this->input->post();
		}
		$this->http_method = $method;
	}

	public function _remap($method, $params = array()) {
		$new_method = $method . '_' . strtolower($this->http_method);
		if (method_exists($this, $new_method)) {
			call_user_func_array(array($this, $new_method), $params);
		} else {
			$this->error(404);
		}
	}

	public function get_arg($name) {
		if (isset($this->args[$name])) {
			return $this->args[$name];
		}
		return null;
	}

	public function set_status($code) {
		header('HTTP/1.1: ' . $code);
		header('Status: ' . $code);
	}

	public function response($data = array(), $code = 200) {
		$this->set_status($code);
		header('Content-Type: application/json');
		exit(json_encode($data));
	}

	public function error($code) {
		$this->set_status($code);
		header('Content-Type: application/json');
		exit();
	}
}
