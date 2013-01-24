<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Search extends SciGit_Controller
{
	function __construct()
	{
		parent::__construct();
		$this->load->helper(array('form', 'url'));
		$this->load->library('form_validation');
    $this->load->model('project');
    $this->load->model('change');
		$this->form_validation->set_error_delimiters('', '');
  }

  public function index()
  {
    $this->form_validation->set_rules('search', 'Search', 'xss_clean|trim');

    if ($this->form_validation->run()) {
      $query = $this->input->post('search');

      $projects = $this->project->search_by_name_and_desc($query);

      $words = explode(' ', $query);
      foreach ($words as $word) {
        $projects += $this->project->search_by_name_and_desc($word);
      }

      foreach ($projects as $project) {
        $latest_change = $this->change->get_by_project_latest($project->id, 0, 1);
        if ($latest_change && $latest_change[0]) {
          $project->latest_change = $latest_change[0]->commit_ts;
        } else {
          // The project was just created and has no changes. Mark its creation
          // date instead.
          $project->latest_change = $project->created_ts;
        }

        $highlight_start = '<span style="color:#990000">';
        $highlight_end = '</span>';
        foreach ($words as $word) {
          $project->name = highlight_phrase($project->name, $word,
            $highlight_start, $highlight_end);
          $project->description = highlight_phrase($project->description, $word,
            $highlight_start, $highlight_end);
        }
      }

      $data = array(
        'results' => $projects,
      );

      $this->twig->display('search.twig', $data);
    }
  }
}
