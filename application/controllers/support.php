<?

class Support extends SciGit_Site_Controller
{
  function __construct()
  {
    parent::__construct();
  }

  function index()
  {

  }

  function contact_us()
  {
    $this->twig->display('support/contact_us.twig');
  }

  function feedback_ajax()
  {
    check_login();
    $user = $this->user->get(get_user_by_id(), true);

    $this->form_validation->set_rules('subject', 'Subject', 'max_length[80]|xss_clean|required');
    $this->form_validation->set_rules('message', 'Message', 'max_length[10000]|xss_clean|required');

    if (!$this->form_validation->run()) {
      $this->response(array('errors' => $this->validation_errors()), 400);
    }

    $subject = $this->input->post('subject');
    $message = $this->input->post('message');

    $data = array(
      'email' => $user->email,
      'subject' => $subject,
      'message' => $message,
    );

    email_feedback($data);

    $this->response(array('message' => 'Feedback sent. Thanks!'), 200);
  }
}
