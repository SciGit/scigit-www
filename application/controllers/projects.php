<?

class Projects extends CI_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('project');
		$this->load->model('change');
		$this->load->library('form_validation');
		check_login();
	}

	public function index() {
		redirect('projects/me');
	}

	public function me() {
    $user_id = get_user_id();
		$data = array(
      'page' => get_class(),
			'projects' => $this->project->get_user_accessible($user_id),
			'subscriptions' => $this->project->get_user_membership($user_id),
		);
		$this->twig->display('projects/index.twig', $data);
	}

  public function view($proj_id) {
		check_project_perms($proj_id);
    $data = array(
      'project' => $this->project->get($proj_id),
      'changes' => $this->change->get_by_project_latest($proj_id, 0, 15),
      'perms' => $this->project->get_perms($proj_id),
			'admin' => $this->project->is_admin(get_user_id(), $proj_id),
			'subscribed' => $this->project->is_member(get_user_id(), $proj_id),
      'subscribers' => 0,
      'changes_num' => 0,
      'contributors' => 0,
      'administrators' => 0,
    );
    $this->twig->display('projects/view.twig', $data);
  }

  public function discover() {
    // drs: FIXME do something with this.
  }

	public function create() {
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
			'admin' => $this->project->is_admin(get_user_id(), $proj_id),
			'subscribed' => $this->project->is_member(get_user_id(), $proj_id),
		);
		$this->twig->display('projects/changes.twig', $data);
	}

	public function admin($proj_id) {
		check_project_admin($proj_id);
		$msg = '';
		if ($this->input->post('add_user')) {
			$this->form_validation->set_rules('username', 'Username',
				'required|callback_check_username');
			$this->form_validation->set_rules('write', 'Write', 'trim');
			$this->form_validation->set_rules('admin', 'Admin', 'trim');
			if ($this->form_validation->run()) {
				$username = $this->input->post('username');
				$user = $this->user->get_user_by_login($username);
				$write = $this->input->post('write') == '1';
				$admin = $this->input->post('admin') == '1';
				if ($this->project->set_user_perms(
							$user->id, $proj_id, $write, $admin)) {
					$msg = 'Success!';
				} else {
					$msg = 'Database error';
				}
			}
		} else if ($this->input->post('delete')) {
			$this->project->delete($proj_id);
			redirect('projects/me');
		}

		$data = array(
      'page' => get_class(),
			'project' => $this->project->get($proj_id),
			'perms' => $this->project->get_perms($proj_id),
			'message' => $msg,
		);
		$this->twig->display('projects/admin.twig', $data);
	}

	public function subscribe($proj_id) {
		check_project_perms($proj_id);
		$user_id = get_user_id();
		$project = $this->project->get($proj_id);
		if ($project->owner_id == $user_id) {
			show_error('Invalid request.');
		}
		if ($this->input->post('subscribe')) {
			if ($this->project->is_member($user_id, $proj_id)) {
				$this->project->delete_member($user_id, $proj_id);
			} else {
				$this->project->add_member($user_id, $proj_id);
			}
			redirect('/projects/' . $this->input->post('return_to') . '/' . $proj_id);
		}
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
