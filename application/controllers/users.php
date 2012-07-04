<?

class Users extends CI_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->library('form_validation');
		if (!is_logged_in()) {
			redirect('auth/login');
		}
	}

	public function index() {
		echo 'hi';
	}
}
