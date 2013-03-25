<?

class Projects extends SciGit_Controller
{
	public function __construct() {
		parent::__construct();
    $this->load->model('tank_auth/user');
		$this->load->model('project');
		$this->load->model('change');
		$this->load->model('permission');
		$this->load->model('email_queue');
		$this->load->library('form_validation');
	}

	public function index() {
		redirect('projects/me');
	}

	public function me() {
		check_login();
    $user_id = get_user_id();
    $projects = $this->permission->get_user_accessible($user_id);
    $subscriptions = $this->permission->get_user_subscriptions($user_id);
    foreach ($projects as $project) {
      $project->subscribers = $this->user->get_by_project_membership($project->id, true);
    }
    foreach ($subscriptions as $subscription) {
      $subscription->subscribers = $this->user->get_by_project_membership($subscription->id, true);
    }
		$data = array(
      'page' => get_class(),
			'projects' => $projects,
			'subscriptions' => $subscriptions,
		);
		$this->twig->display('projects/index.twig', $data);
	}

  public function view($proj_id) {
		check_project_perms($proj_id);
    $data = array(
      'project' => $this->project->get($proj_id),
      'changes' => $this->change->get_by_project_latest($proj_id, 0, 15),
      'perms' => $this->user->get_by_project_accessible($proj_id, false),
			'admin' => $this->permission->is_admin(get_user_id(), $proj_id),
			'member' => $this->permission->is_member(get_user_id(), $proj_id),
			'subscribed' => $this->permission->is_subscribed(get_user_id(), $proj_id),
      'subscribers' => $this->user->get_by_project_membership($proj_id, true),
      'changes_num' => $this->change->get_by_project($proj_id, 0, true),
      'contributors' => $this->user->get_by_project_accessible($proj_id, false, true),
      'administrators' => $this->user->get_by_project_accessible($proj_id, true, true),
    );
    $this->twig->display('projects/view.twig', $data);
  }

  public function explore($page = 0) {
    $projects_per_page = 25;
    // XXX: SO BAD! In the future, we should stick these in a DB table so we
    // don't have to code push every time they change.
    $featured_project_ids = array();
    $projects = $this->project->get_by_popularity($projects_per_page, $page);

    foreach ($projects as $project) {
      $latest_change = $this->change->get_by_project_latest($project->id, 0, 1);
      if ($latest_change && $latest_change[0]) {
        $project->latest_change = $latest_change[0]->commit_ts;
      } else {
        // The project was just created and has no changes. Mark its creation
        // date instead.
        $project->latest_change = $project->created_ts;
      }

      $max_len = 256;
      if ($project->description && strlen($project->description) > $max_len) {
        $project->description = substr($project->description, 0, $max_len) . " ...";
      }
    }

    $featured_projects = array();
    foreach ($featured_project_ids as $featured_project_id) {
      array_push($featured_projects, $this->project->get($featured_project_id));
    }

    $data = array(
      'projects' => $projects,
      'featured_projects' => $featured_projects,
    );

    $this->twig->display('projects/explore.twig', $data);
  }

  public function create_ajax() {
    check_login();
    $this->form_validation->set_rules('name', 'name', 'required|callback_check_projname');
    $this->form_validation->set_rules('public', 'public', '');
    if ($this->form_validation->run()) {
      $name = $this->input->post('name');
      $public = $this->input->post('public');
      if (($project = $this->project->create(get_user_id(), $name, $public))) {
        echo json_encode(array(
          'error' => '0',
          'message' => 'Project created!',
          'proj_id' => $project['id'],
        ));
      } else {
        echo json_encode(array(
          'error' => '1',
          'message' => 'Database error, please try later.'
        ));
      }
    } else {
      echo json_encode(array(
        'error' => '2',
        'message' => 'That project name is taken; please pick another.'
      ));
    }
  }

  // XXX: Unused; should probably remove this.
	public function create() {
		check_login();
		$data = array('message' => '');
		if ($this->input->post('create_project')) {
			$this->form_validation->set_rules('name', 'name',
					'required|callback_check_projname');
			$this->form_validation->set_rules('public', 'public', '');
			if ($this->form_validation->run()) {
				$name = $this->input->post('name');
				$public = $this->input->post('public');
				if ($this->project->create(get_user_id(), $name, $public)) {
					redirect('projects/me');
				} else {
					$data['message'] = 'Database error.';
				}
			}
		}
    $data['page'] = get_class();
		$this->twig->display('projects/create.twig', $data);
	}

	public function changes($proj_id) {
		check_project_perms($proj_id);
		$data = array(
      'page' => get_class(),
			'project' => $this->project->get($proj_id),
			'changes' => $this->change->get_by_project($proj_id),
			'admin' => $this->permission->is_admin(get_user_id(), $proj_id),
			'subscribed' => $this->permission->is_member(get_user_id(), $proj_id),
		);
		$this->twig->display('projects/changes.twig', $data);
	}

	public function admin($proj_id) {
		check_login();
		check_project_admin($proj_id);
    $msg = '';
    $success = false;
    $form_name = 'users';
		if ($this->input->post('add_user')) {
      // XXX: not valid anymore
    } else if ($this->input->post('settings')) {
      $form_name = 'settings';
      $this->form_validation->set_rules('description', 'Description',
        'max_length[1024]|xss_clean');
      if ($this->form_validation->run()) {
        $this->project->set_public(
          $proj_id, !$this->input->post('private'));
        $this->project->set_description(
          $proj_id, $this->input->post('description'));
        $msg = 'Settings saved.';
        $success = true;
      } else {
        $msg = 'Description is invalid.';
      }
		} else if ($this->input->post('delete')) {
			$this->project->delete($proj_id);
			redirect('projects/me');
    }

		$data = array(
      'page' => get_class(),
			'project' => $this->project->get($proj_id),
			'perms' => $this->user->get_by_project_accessible($proj_id, false),
			'message' => $msg,
      'form_name' => $form_name,
      'success' => $success,
		);
		$this->twig->display('projects/admin.twig', $data);
	}

  public function subscribe_ajax() {
		check_login();
    $proj_id = $this->input->post('proj_id');
    if ($proj_id && is_numeric($proj_id)) {
      check_project_perms($proj_id);
      $user_id = get_user_id();
      $project = $this->project->get($proj_id);
      if ($this->permission->is_member($user_id, $proj_id)) {
        echo json_encode(array(
          'error' => '1'
        ));
      }

      if ($this->permission->is_subscribed($user_id, $proj_id)) {
        $this->permission->delete_permission($user_id, $proj_id);
      } else {
        $this->permission->add_permission($user_id, $proj_id, Permission::SUBSCRIBER);
      }

      echo json_encode(array(
        'error' => '0'
      ));
    } else {
      echo json_encode(array(
        'error' => '2'
      ));
    }
  }

	public function subscribe($proj_id) {
		check_login();
		check_project_perms($proj_id);
		$user_id = get_user_id();
		$project = $this->project->get($proj_id);
    if ($this->permission->is_member($user_id, $proj_id)) {
      show_error("Invalid request.");
    }
		if ($this->input->post('subscribe')) {
			if ($this->permission->is_subscribed($user_id, $proj_id)) {
				$this->permission->delete_permission($user_id, $proj_id);
			} else {
				$this->permission->add_permission($user_id, $proj_id, Permission::SUBSCRIBER);
			}
			redirect('/projects/' . $this->input->post('return_to') . '/' . $proj_id);
		}
	}

  public function add_member_ajax() {
		check_login();

    $this->form_validation->set_rules('username', 'Username',
      'callback_check_username|trim');
    $this->form_validation->set_rules('email', 'Email Address',
      'callback_check_email|trim');
    $this->form_validation->set_rules('permission', 'Permissions', 'trim|required');
    $this->form_validation->set_rules('proj_id', 'Project ID', 'trim|required');

    if (!$this->form_validation->run()) {
      die(json_encode(array(
        'error' => '2',
        'message' => 'temp',
      )));
    }

    $proj_id = $this->input->post('proj_id');
    if (!$proj_id || !is_numeric($proj_id)) {
      die(json_encode(array(
        'error' => '2',
        'message' => 'Invalid format of request.',
      )));
    }

    check_project_perms($proj_id);

    $username = $this->input->post('username');
    if ($username == null) {
      die(json_encode(array(
        'error' => '3',
        'message' => 'You must use a username for now.',
      )));
    }

    $user = $this->user->get_user_by_login($username);
    $subscriber = $this->input->post('permission') == '4';
    $reader = $this->input->post('permission') == '3';
    $write = $this->input->post('permission') == '2';
    $admin = $this->input->post('permission') == '1';

    $perms = Permission::NONE;
    if ($subscriber) {
      $perms = Permission::SUBSCRIBER;
    } else {
      // Reader is a permission given to admins and collaborators anyways.
      $perms = Permission::READ;
      $perms |= $write ? Permission::WRITE : 0;
      $perms |= $admin ? Permission::ADMIN : 0;
    }

    if ($this->permission->get_by_user_on_project($user->id, $proj_id) === null) {
      $this->email_queue->add_invite_email(get_user_id(), $user->id, $proj_id);
    }

    if (!$this->permission->set_user_perms(
          $user->id, $proj_id, $perms)) {
      die(json_encode(array(
        'error' => '1',
        'message' => 'Database error.',
      )));
    }

    die(json_encode(array(
      'error' => '0',
      'message' => 'Member added.',
    )));
  }

  public function publish($proj_id) {
    //check_login();
    //check_project_perms($proj_id);
    $this->twig->display('projects/publish.twig');
  }

  public function check_email($str) {
    return true;
  }

	public function check_username($str) {
		if ($this->user->get_user_by_login($str) === null) {
			$this->form_validation->set_message('check_username',
				'Must provide a valid username.');
			return false;
		}
		return true;
	}

	public function check_projname($str) {
		$str = trim($str);
		if (!preg_match('/^[a-zA-Z0-9 \-_]+$/', $str)) {
			$this->form_validation->set_message('check_projname',
				'Invalid project name. Only alphanumeric characters, '.
				'spaces, dashes, and underscores are permitted.');
			return false;
		}
		if ($this->project->get_by_name($str) !== null) {
			$this->form_validation->set_message('check_projname',
				'This project name is already taken.');
			return false;
		}
		return $str;
	}
}
