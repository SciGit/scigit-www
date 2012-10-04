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

      if ($user->private) {
        $data = array(
          'user' => $user,
        );
        $this->twig->display('users/private.twig', $data);
      } else {
        $projects = $this->project->get_user_membership($id);
        foreach ($projects as $project) {
          $latest_change = $this->change->get_by_project_latest($project->id, 0, 1);
          if ($latest_change && $latest_change[0]) {
            $project->latest_change = $latest_change[0]->commit_ts;
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
  }

	private function profile_me() {
		$message = '';
    $form_name = 'settings';
    $id = get_user_id();

    if ($this->input->post('profile')) {
      $form_name = 'profile';
      $user = $this->user->get_user_by_id($id, true);
      if ($this->input->post('email') !== $user->email) {
        $this->form_validation->set_rules('email', 'Email', 'required|valid_email|is_unique[users.email]');
      }
      $this->form_validation->set_rules('name', 'Name', 'max_length[80]|xss_clean');
      $this->form_validation->set_rules('title', 'title', 'max_length[80]|xss_clean');
      $this->form_validation->set_rules('organization', 'organization', 'max_length[80]|xss_clean');
      $this->form_validation->set_rules('location', 'location', 'max_length[80]|xss_clean');
      $this->form_validation->set_rules('about', 'About', 'max_length[1024]|xss_clean');
			if ($this->form_validation->run()) {
        $this->user->set_user_profile_field(
          $id, 'fullname', $this->input->post('name'));
        $this->user->set_user_profile_field(
          $id, 'title', $this->input->post('title'));
        $this->user->set_user_profile_field(
          $id, 'organization', $this->input->post('organization'));
        $this->user->set_user_profile_field(
          $id, 'location', $this->input->post('location'));
        $this->user->set_user_profile_field(
          $id, 'email', $this->input->post('email'));
        $this->user->set_user_profile_field(
          $id, 'about', $this->input->post('about'));
        $message = "Profile saved";
			}
		} else if ($this->input->post('settings')) {
      $form_name = 'settings';
      $user = $this->user->get_user_by_id($id, true);
      // Form validation requires some rules to be set. We don't have any here,
      // so skip validation.
      //if ($this->form_validation->run())
      {
        $this->user->set_user_profile_field(
          $id, 'private', intval(!!$this->input->post('private')));
        $this->user->set_user_profile_field(
          $id, 'disable_email', intval(!$this->input->post('email_updates')));
        $message = "Settings saved";
      }
    } else if ($this->input->post('password')) {
      $form_name = 'password';
			$this->form_validation->set_rules('new_password', 'New Password', 'trim|required|xss_clean|min_length['.$this->config->item('password_min_length', 'tank_auth').']|max_length['.$this->config->item('password_max_length', 'tank_auth').']|alpha_dash');
			$this->form_validation->set_rules('confirm_new_password', 'Confirm Password', 'trim|required|xss_clean|matches[new_password]');
			$this->form_validation->set_rules('current_password', 'Current Password', 'trim|required|xss_clean|min_length['.$this->config->item('password_min_length', 'tank_auth').']|max_length['.$this->config->item('password_max_length', 'tank_auth').']|alpha_dash|callback_current_password');
      if ($this->form_validation->run()) {
        $this->tank_auth->change_password(
          $this->input->post('current_password'), $this->input->post('new_password'));
        $message = "Password saved";
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

  public function current_password($current_password) {
    // Change password to itself because we can't change it properly yet. This
    // will error if the current password was wrong, which is what we want.
    $this->tank_auth->change_password($current_password, $current_password);

    if ($this->tank_auth->get_error_message()) {
      $this->form_validation->set_message('current_password', 'Password does not match records.');
      return FALSE;
    }

    return TRUE;
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
