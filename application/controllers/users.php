<?

class Users extends SciGit_Controller
{
	public function __construct() {
		parent::__construct();
    $this->load->model('project');
    $this->load->model('change');
		$this->load->model('public_key');
		$this->load->model('permission');
		$this->load->model('user_seen');
		$this->load->library('form_validation');
	}

  public function profile($id = null) {
    if ($id == null) {
      $this->profile_me();
    } else {
      $user = $this->user->get_user_by_id($id, true);
      if (!$user) {
        $this->twig->display('users/profile-null.twig', null);
        return;
      }

      if ($user->private && $id != get_user_id()) {
        $data = array(
          'user' => $user,
        );
        $this->twig->display('users/private.twig', $data);
      } else {
        $projects = $this->permission->get_user_accessible($id, true);
        foreach ($projects as $project) {
          $latest_change = $this->change->get_by_project_latest($project->id, 0, 1);
          if ($latest_change && $latest_change[0]) {
            $project->latest_change = $latest_change[0]->commit_ts;
          } else {
            // The project was just created and has no changes. Mark its creation
            // date instead.
            $project->latest_change = $project->created_ts;
          }
          $num_changes = count($projects) > 1 ? 5 : 10;
          $project->my_changes =
            $this->change->get_by_project_latest($project->id, $user->id, $num_changes);
          $project->subscribers = $this->user->get_by_project_membership($project->id, true);
        }
        $fulltitle = format_user_fulltitle($user);

        usort($projects, "project_sort");

        $data = array(
          'user' => $user,
          'projects' => $projects,
          'fulltitle' => $fulltitle,
          'is_me' => $id == get_user_id(),
          'private' => $user->private,
        );

        $this->twig->display('users/profile.twig', $data);
      }
    }
  }

	private function profile_me() {
		check_login();
		$msg = '';
    $form_name = 'settings';
    $success = false;
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
        $msg = "Profile saved.";
        $success = true;
      } else {
        $msg = "There were problems with your profile data.";
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
        $msg = "Settings saved.";
        $success = true;
      }
    } else if ($this->input->post('password')) {
      $form_name = 'password';
			$this->form_validation->set_rules('new_password', 'New Password', 'trim|required|xss_clean|min_length['.$this->config->item('password_min_length', 'tank_auth').']|max_length['.$this->config->item('password_max_length', 'tank_auth').']');
			$this->form_validation->set_rules('confirm_new_password', 'Confirm Password', 'trim|required|xss_clean|matches[new_password]');
			$this->form_validation->set_rules('current_password', 'Current Password', 'trim|required|xss_clean|min_length['.$this->config->item('password_min_length', 'tank_auth').']|max_length['.$this->config->item('password_max_length', 'tank_auth').']|callback_current_password');
      if ($this->form_validation->run()) {
        $this->tank_auth->change_password(
          $this->input->post('current_password'), $this->input->post('new_password'));
        $msg = "Password saved.";
        $success = true;
      } else {
        $msg = "There were problems with your passwords.";
      }
    } else if ($this->input->post('advanced')) {
      $form_name = 'advanced';
    }

		$user = $this->user->get_user_by_id(get_user_id(), true);

    $ssh_keys = $this->public_key->get_by_user($id, false /** exclude autogenerated */);

		$data = array(
			'user' => $user,
      'message' => $msg,
      'form_name' => $form_name,
      'success' => $success,
      'ssh_keys' => $ssh_keys,
		);
		$this->twig->display('users/me.twig', $data);
	}

  public function autocomplete_ajax() {
    $username = trim($this->input->get('query'));
    $users = $this->user->get_user_by_username_partial($username, 5);

    $result = array('options' => array());
    foreach ($users as $user) {
      $result['options'][] = $user->username;
    }

    echo json_encode($result);
  }

  public function seen_tutorial_ajax() {
		check_login();
    $id = get_user_id();
    $this->user_seen->set($id, 'tutorials', 1);
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

    $user_id = get_user_id();
    $pk = $this->public_key->get_by_key($data['public_key']);
    if ($pk !== null && ($pk->user_id != $user_id || $pk->enabled)) {
			$this->form_validation->set_message('check_public_key',
				'Public key already in use.');
			return false;
		}
		return true;
	}

  public function pub_key_add_ajax() {
    check_login();

    $this->form_validation->set_rules('pub_key', 'Public Key', 'required|xss_clean|callback_check_public_key');
    $this->form_validation->set_rules('comment', 'Comment', 'max_length[255]|xss_clean');

    if (!$this->form_validation->run()) {
      die($this->json_encode_validation_errors(1));
    }

    $public_key_text = $this->input->post('pub_key');
    $comment = $this->input->post('comment');

    $data = $this->public_key->parse_key($public_key_text);
    $user_pub_key = $this->public_key->get_by_key($data['public_key']);
    if ($user_pub_key !== null) {
      $this->public_key->update($user_pub_key->id, $comment);
    } else {
      $user_pub_key = $this->public_key->create(get_user_id(), $comment, $public_key_text, false);
      if ($user_pub_key == null) {
        $this->form_validation->set_message('pub_key', 'Database error.');
        die($this->json_encode_validation_errors(2));
      }
    }

    die(json_encode(array(
      'error' => '0',
      'message' => 'Public key added. Refreshing.',
    )));
  }

  public function pub_key_delete_ajax($id) {
    check_login();

    $user_id = get_user_id();

    $pub_keys = $this->public_key->get_by_user($user_id);

    $found_key_on_user = false;
    foreach ($pub_keys as $pub_key) {
      if ($pub_key->id == $id) {
        $found_key_on_user = true;
      }
    }

    if (!$found_key_on_user) {
      die(json_encode(array(
        'error' => '2',
        'message' => 'This key is not yours.',
      )));
    }

    if ($this->public_key->delete($id) == false) {
      die(json_encode(array(
        'error' => '2',
        'message' => 'Database error.',
      )));
    }

    die(json_encode(array(
      'error' => '0',
      'message' => 'Public key deleted. Refreshing.',
    )));
  }
}

function project_sort($a, $b)
{
  return $a->latest_change < $b->latest_change;
}
