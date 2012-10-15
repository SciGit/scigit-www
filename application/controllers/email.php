<?

class Email extends CI_Controller
{
  public function __construct() {
    parent::__construct();
    $this->load->model('tank_auth/user');
    $this->load->model('email_queue');
    $this->load->model('project');
    $this->load->model('change');
    $this->load->model('membership');
  }

  public function index() {
    $email_queue = $this->email_queue->get();
    foreach ($email_queue as $email) {
      $change = $this->change->get($email->change_id);
      $members = $this->membership->get_by_project($change->proj_id, true);
      var_dump($members);
      foreach ($members as $membership) {
        $user = $this->user->get_user_by_id($membership->user_id, true);
        if (!$user->disable_email) {
          email_project_update($change->proj_id, $user);
        }
      }
    }
  }
}
