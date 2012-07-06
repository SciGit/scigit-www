<?

class Auth extends REST_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('auth_token');
	}

	public function login_post() {
		$username = $this->get_arg('username');
		$password = $this->get_arg('password');
		if ($this->tank_auth->login($username, $password, 0, 1, 1)) {
			$user_id = $this->user->get_user_by_login($username)->id;
			if ($token = $this->auth_token->create($user_id)) {
				$this->response($token);
			} else {
				$this->error(500);
			}
		} else {
			$this->response($this->tank_auth->get_error_message(), 403);
		}
	}

	public function logout_post() {
		$username = $this->get_arg('username');
		$auth_token = $this->get_arg('auth_token');
		if ($user = $this->user->get_user_by_login($username)) {
			if ($this->auth_token->delete($user->id, $auth_token)) {
				$this->response();
			} else {
				$this->error(403);
			}
		} else {
			$this->error(400);
		}
	}
}
