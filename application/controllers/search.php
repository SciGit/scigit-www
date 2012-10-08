<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Search extends CI_Controller
{
	function __construct()
	{
		parent::__construct();
		$this->load->helper(array('form', 'url'));
		$this->load->library('form_validation');
    $this->load->model('project');
		$this->form_validation->set_error_delimiters('', '');
  }

  public function index()
  {
    $this->form_validation->set_rules('search', 'Search', 'xss_clean');

    if ($this->form_validation->run()) {
      $query = $this->input->post('search');

      $data = array(
        'results' => $this->project->search_by_name_and_desc($query),
      );

      $this->twig->display('search.twig', $data);
    }
  }
}
