<?

class Changes extends CI_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('project');
		$this->load->model('change');
		check_login();
	}

	public function view($id, $path = '') {
		$change = $this->change->get($id);
		if ($change == null) {
			show_404();
		}
		check_project_perms($change->proj_id);
		$path = urldecode($path);

		$data = array(
			'project' => $this->project->get($change->proj_id),
			'change' => $change,
			'path' => $path,
		);
		$type = $this->change->get_type($id, $path);
		if ($type == 'dir' || $path == '') {
			$data['listing'] = $this->change->get_listing($id, $path);
		} else if ($type == 'file') {
			$data['file'] = $this->change->get_file($id, $path);
		} else {
			show_404();
		}
		$this->twig->display('changes/view.twig', $data);
	}
}
