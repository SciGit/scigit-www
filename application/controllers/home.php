<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Home extends CI_Controller
{
	function __construct()
	{
		parent::__construct();

		$this->load->helper('url');
		$this->load->library('tank_auth');
    $this->load->model('project');
    $this->load->model('change');
    $this->load->model('permission');
	}

	function index()
	{
		if (!$this->tank_auth->is_logged_in()) {
      $data['page'] = get_class();
			$this->twig->display('index.twig', $data);
		} else {
      $user_id = $this->tank_auth->get_user_id();
      $projects = $this->permission->get_user_membership($user_id);
      $activities = array();
      $projects_has_at_least_one_change = false;
      foreach ($projects as $project) {
        // XXX: Merge these into one because we have no struct that can be sent
        // to a view in this format. We should add a new struct that handles
        // this data format.
        $changes = $this->change->get_by_project($project->id);
        foreach ($changes as $change) {
          $change->proj_name = $project->name;
        }
        $activities = array_merge($changes, $activities);

        // Merge this object with its most recent changes done by this user.
        // Show more of them if this is the only project the user has.
        $num_changes = count($projects) > 1 ? 5 : 10;
        $project->my_changes =
          $this->change->get_by_project_latest($project->id, $user_id, $num_changes);

        // XXX: This is really bad and should not be done in a controller.
        // We check if there are any changes because we need to display your
        // recent activity and, if there is none, show them a message inviting
        // them to contribute. If we have social activity, we will be fooled
        // into thinking that there are active projects and not show this message.
        if (!!count($project->my_changes)) {
          $projects_has_at_least_one_change = true;
        }
      }
      $activities = array_slice($activities, 0, 10);
      $has_projects = !!count($this->permission->get_user_accessible($user_id));
      if (!$has_projects || !$projects_has_at_least_one_change) {
        $projects = array();
      }

      // Sort everything by most recent timestamp. Because of the way we're
      // smashing objects together without a clear structure to them, we have to
      // sort them afterwards rather than using something that'll do this for us.
      usort($activities, "activity_sort");
      usort($projects, "project_sort");

      $user = $this->user->get_user_by_id($user_id, true);
      $data = array(
        'page' => get_class(),
        'activities' => $activities,
        'projects' => $projects,
        'has_projects' => $has_projects,
        'activated' => $user->activated,
        'username' => $user->username,
        'user_id' => $user_id,
      );
			$this->twig->display('home.twig', $data);
		}
	}
}

function activity_sort($a, $b)
{
  return $a->commit_ts < $b->commit_ts;
}

function project_sort($a, $b)
{
  if (!$a->my_changes || !$a->my_changes[0]) return 1;
  if (!$b->my_changes || !$b->my_changes[0]) return 0;
  return $a->my_changes[0]->commit_ts < $b->my_changes[0]->commit_ts;
}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */
