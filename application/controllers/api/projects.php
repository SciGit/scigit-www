<?

class Projects extends SciGit_REST_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('project');
		$this->load->model('change');
		$this->load->model('permission');
	}

	public function index_get() {
		$user = $this->authenticate();
		$perms = $this->permission->get_user_membership($user->id);
		$projects = array();
		foreach ($perms as &$perm) {
			$proj = $this->project->get($perm->proj_id);
			// Get the last commit hash for each project.
			$hash = $this->change->get_last_commit_hash($proj->id);
			if ($hash === null) {
				$proj->last_commit_hash = '';
			} else {
				$proj->last_commit_hash = $hash;
			}

			// See if the user can write to it
			$proj->can_write = !!($perm->permission &
				(Permission::WRITE | Permission::ADMIN | Permission::OWNER));
			$projects[] = $proj;
		}
		$this->response($projects);
	}

	public function view_get() {
		$user = $this->authenticate();
		$id = $this->get_arg('proj_id');
		if (!$id) $this->error(400);

		if ($project = $this->project->get($id)) {
			if ($this->permission->get_by_user_on_project($user->id, $id)) {
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
