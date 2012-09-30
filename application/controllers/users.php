<?

class Users extends CI_Controller
{
	public function __construct() {
		parent::__construct();
    $this->load->model('project');
    $this->load->model('change');
		$this->load->model('public_key');
		$this->load->library('form_validation');
		check_login();
	}

  public function profile($id = null) {
    if ($id == null) {
      $this->profile_me();
    } else {
      $user = $this->user->get_user_by_id($id, true);
      $projects = $this->project->get_user_membership($id);
      foreach ($projects as $project) {
        $latest_change = $this->change->get_by_project_latest($project->id);
        if ($latest_change) {
          $project->latest_change = $latest_change->commit_ts;
        } else {
          // The project was just created and has no changes. Mark its creation
          // date instead.
          $project->latest_change = $project->created_ts;
        }
      }

      $data = array(
        'user' => $user,
        'projects' => $projects
      );

      $this->twig->display('users/profile.twig', $data);
    }
  }

	private function profile_me() {
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
		$this->twig->display('users/me.twig', $data);
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
