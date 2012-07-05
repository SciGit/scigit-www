<?

class Projects extends CI_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('project');
		$this->load->library('form_validation');
		if (!is_logged_in()) redirect('auth/login');
	}

	public function index() {
		$data = array(
			'projects' => $this->project->get_for_user(get_user_id()),
		);
		$this->twig->display('projects/index.twig', $data);
	}

	public function admin($proj_id) {
		$this->check_admin($proj_id);

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

	private function check_admin($proj_id) {
		$perm = $this->project->get_user_perms(get_user_id(), $proj_id);
		if ($perm == null) {
			show_404();
		}
		if (!$perm->can_admin) {
			show_error('Insufficient privileges.', 403);
		}
	}
}
