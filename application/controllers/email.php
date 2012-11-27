<? if (!defined('BASEPATH')) exit("No direct script access allowed");

class Email extends CI_Controller
{
  public function __construct() {
    parent::__construct();

    $this->input->is_cli_request()
      or show_404();

    $this->load->model('tank_auth/user');
    $this->load->model('email_queue');
    $this->load->model('project');
    $this->load->model('change');
    $this->load->model('permission');
  }

  public function index() {
    $this->process_change_emails();
    $this->process_register_emails();
    $this->process_invite_emails();
  }

  private function process_change_emails() {
    $email_queue = $this->email_queue->get();
    foreach ($email_queue as $email) {
      $change = $this->change->get($email->change_id);
      $members = $this->permission->get_by_project($change->proj_id);
      foreach ($members as $membership) {
        $user = $this->user->get_user_by_id($membership->user_id, true);
        if (!$user->disable_email) {
          email_project_update($change->id, $user);
        }
      }
    }
    $this->email_queue->clear();
  }

  private function process_register_emails() {
    $emails = $this->email_queue->get_user_emails();
    foreach ($emails as $email) {
      $user = $this->user->get_user_by_id($email->user_id, false);
      if ($user != NULL) {
        email_register($user);
      }
    }
    $this->email_queue->clear_user_emails();
  }

  private function process_invite_emails() {
    $emails = $this->email_queue->get_invite_emails();
    foreach ($emails as $email) {
      $from_user = $this->user->get_user_by_id($email->user_id, false);
      $to_user = $this->user->get_user_by_id($email->user_id2, false);
      $project = $this->project->get($email->proj_id);
      if ($user != NULL) {
        email_invite($from_user, $to_user, $project);
      }
    }
    $this->email_queue->clear_invite_emails();
  }
}
