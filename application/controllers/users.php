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
      $changes = $this->change->get_by_user($id, 10);
      $fulltitle = format_user_fulltitle($user);

      $data = array(
        'user' => $user,
        'projects' => $projects,
        'changes' => $changes,
        'fulltitle' => $fulltitle,
      );

      $this->twig->display('users/profile.twig', $data);
    }
  }

	private function profile_me() {
		$message = '';
    $form_name = 'settings';
    if ($this->input->post('profile')) {
      $form_name = 'profile';
      $user = $this->user->get_user_by_id(get_user_id(), true);
      if ($this->input->post('email') !== $user->email) {
        $this->form_validation->set_rules('email', 'Email', 'required|valid_email|is_unique[users.email]');
      }
      $this->form_validation->set_rules('name', 'Name', 'max_length[80]');
      $this->form_validation->set_rules('about', 'About', 'max_length[1024]');
			if ($this->form_validation->run()) {

			}
		}

		$user = $this->user->get_user_by_id(get_user_id(), true);

		$data = array(
			'user' => $user,
      'message' => $message,
      'form_name' => $form_name,
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
