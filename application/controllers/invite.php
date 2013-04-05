<?

class Invite extends SciGit_Site_Controller
{
  public function __construct() {
    parent::__construct();
    $this->load->model('project');
    $this->load->model('permission');
    $this->load->model('user_invite');
    $this->load->model('tank_auth/user');
  }

  public function register($hash) {
    $user_invite = $this->user_invite->get_by_hash($hash);
    if ($user_invite === null) {
      die("Invalid invitation. You may have already used this link.");
    }

    $this->session->set_userdata('invite_hash', $hash);

    redirect('auth/register');
  }
}
