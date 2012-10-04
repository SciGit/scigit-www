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
	}

	function index()
	{
    $data['page'] = get_class();
		if (!$this->tank_auth->is_logged_in()) {
			$this->twig->display('index.twig', $data);
		} else {
      $user_id = $this->tank_auth->get_user_id();
			$data['user_id']	= $user_id;
			$data['username']	= $this->tank_auth->get_username();
      $projects = $this->project->get_user_membership($user_id);
      $activities = array();
      foreach ($projects as $project) {
        // XXX: Merge these into one because we have no struct that can be sent
        // to a view in this format. We should add a new struct that handles 
        // this data format.
        $changes = $this->change->get_by_project($project->id);
        foreach ($changes as $change) {
          $change->proj_name = $project->name;
        }
        $activities = array_merge($changes, $activities);
      }
      var_dump($activities);
      $data['activities'] = $activities;
			$this->twig->display('home.twig', $data);
		}
	}
}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */
