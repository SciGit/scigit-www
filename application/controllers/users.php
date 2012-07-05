<?

class Users extends CI_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('public_key');
		$this->load->library('form_validation');
		if (!is_logged_in()) redirect('auth/login');
	}

	public function profile() {
		$message = '';
		if ($this->input->post('add_public_key')) {
			$this->form_validation->set_rules('name', 'Name', 'required');
			$this->form_validation->set_rules('public_key', 'Public Key',
				'required|max_length[511]|callback_check_public_key');
			if ($this->form_validation->run()) {
				if ($this->public_key->create(get_user_id(),
							$this->input->post('name'),
							$this->input->post('public_key'))) {
					$message = 'Success!';
				} else {
					$message = 'Database error';				
				}
			}
		}

		$user = $this->user->get_user_by_id(get_user_id(), true);
		$public_keys = $this->public_key->get_by_user(get_user_id());

		$data = array(
			'user' => $user,
			'public_keys' => $public_keys,
			'message' => $message,
		);
		$this->twig->display('users/profile.twig', $data);
	}

	public function check_public_key($key) {
		$data = $this->public_key->parse_key($key);
		if ($data == null) {
			$this->form_validation->set_message('check_public_key',
				'Not a valid SSH key.');
			return false;
		}
		if ($this->public_key->get_by_key($data['public_key'])) {
			$this->form_validation->set_message('check_public_key',
				'Public key already in use.');
			return false;
		}
		return true;
	}
}
