<?

class Changes extends CI_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('project');
		$this->load->model('change');
		$this->load->model('permission');
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
			$file = $this->change->get_file($id, $path);
			if (strpos($file, '\0') === false) {
				$data['file'] = $file;
				$data['binary'] = false;
			} else {
				$data['binary'] = true;
			}
		} else {
			show_404();
		}
		$this->twig->display('changes/view.twig', $data);
	}

	public function raw($id, $path, $download = '') {
		$change = $this->change->get($id);
		if ($change == null) show_404();
		check_project_perms($change->proj_id);

		$path = urldecode($path);
		$type = $this->change->get_type($id, $path);
		if ($type != 'file') show_404();
		$file = $this->change->get_file($id, $path);

		header("Content-Type: text/plain");
		if ($download) {
			header("Content-Disposition: attachment; filename=".basename($path));
		}
		echo $file;
	}
}
