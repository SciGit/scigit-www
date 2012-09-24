<?

class Projects extends REST_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('project');
		$this->load->model('change');
	}

	public function index_get() {
		$user = $this->authenticate();
		$projects = $this->project->get_user_membership($user->id);
		// Get the last commit hash for each project.
		foreach ($projects as &$proj) {
			$change = $this->change->get_by_project($proj->id, 1);
			if (empty($change)) {
				$proj->last_commit_hash = '';
			} else {
				$proj->last_commit_hash = $change[0]->commit_hash;
			}
		}
		$this->response($projects);
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
