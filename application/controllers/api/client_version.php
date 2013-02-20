<?

require APPPATH.'/core/SciGit_REST_Controller.php';

class Client_version extends SciGit_REST_Controller
{
	public function index_get() {
		$this->response(array('version' => '0.1.0.0'));
	}
}
