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
		$data = array(
			'projects' => $this->project->get_by_user(get_user_id()),
		);
		$this->twig->display('projects/index.twig', $data);
	}

	public function create() {
		if ($this->input->post('create_project')) {
			$this->form_validation->set_rules('name', 'Name',
					'required|alpha_dash|is_unique[projects.name]');
			if ($this->form_validation->run()) {
				if ($this->project->create(get_user_id(), $this->input->post('name'))) {
					redirect('projects');
				}
			}
		}
		$this->twig->display('projects/create.twig');
	}

	public function changes($proj_id) {
		check_project_perms($proj_id);
		$data = array(
			'project' => $this->project->get($proj_id),
			'changes' => $this->change->get_by_project($proj_id),
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
		}

		$data = array(
			'project' => $this->project->get($proj_id),
			'perms' => $this->project->get_perms($proj_id),
			'message' => $msg,
		);
		$this->twig->display('projects/admin.twig', $data);
	}

	public function check_username($str) {
		if ($this->user->get_user_by_login($str) === null) {
			$this->form_validation->set_message('check_username',
				'Must provide a valid username.');
			return false;
		}
		return true;
	}
}
