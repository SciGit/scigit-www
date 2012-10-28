<?

class Projects extends CI_Controller
{
	public function __construct() {
		parent::__construct();
    $this->load->model('tank_auth/user');
		$this->load->model('project');
		$this->load->model('change');
		$this->load->model('permission');
		$this->load->library('form_validation');
	}

	public function index() {
		redirect('projects/me');
	}

	public function me() {
		check_login();
    $user_id = get_user_id();
		$data = array(
      'page' => get_class(),
			'projects' => $this->permission->get_user_accessible($user_id),
			'subscriptions' => $this->permission->get_user_subscriptions($user_id),
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
      $form_name = 'users';
			$this->form_validation->set_rules('username', 'Username',
				'required|callback_check_username');
			$this->form_validation->set_rules('write', 'Write', 'trim');
			$this->form_validation->set_rules('admin', 'Admin', 'trim');
			if ($this->form_validation->run()) {
				$username = $this->input->post('username');
				$user = $this->user->get_user_by_login($username);
				$write = $this->input->post('write') == '1';
				$admin = $this->input->post('admin') == '1';
        $perms = Permission::READ;
        $perms |= $write ? Permission::WRITE : 0;
        $perms |= $admin ? Permission::ADMIN : 0;
				if ($this->permission->set_user_perms(
							$user->id, $proj_id, $perms)) {
					$msg = 'User added.';
          $success = true;
				} else {
					$msg = 'Database error';
				}
      } else {
        $msg = 'Must provide a valid username.';
      }
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

  public function publish($proj_id) {
    check_login();
    check_project_perms($proj_id);
    $this->twig->display('projects/publish.twig');
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
