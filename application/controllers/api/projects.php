<?

class Projects extends REST_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('project');
	}

	public function index_get() {
		$user = $this->authenticate();
		$this->response($this->project->get_by_user($user->id));
	}

	public function view_get() {
		$user = $this->authenticate();
		$id = $this->get_arg('proj_id');
		if (!$id) $this->error(400);

		if ($project = $this->project->get($id)) {
			if ($this->project->get_user_perms($user->id, $id)) {
				$this->response($project);
			} else {
				$this->error(403);
			}
		} else {
			$this->error(404);
		}
	}

	public function create_put() {
		$user = $this->authenticate();
		$name = $this->get_arg('name');
		if (!$name) $this->error(400);
		if ($p = $this->project->create($user->id, $name)) {
			$this->response($p);
		} else {
			$this->error(500);
		}
	}
}
