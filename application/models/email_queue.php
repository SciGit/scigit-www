<?

class Email_Queue extends CI_Model
{
  public $email_table = 'email_queue';
  public $email_user_table = 'email_user_queue';

  public function get() {
    return $this->db->get($this->email_table)->result();
  }

  public function get_user_emails() {
    return $this->db->get($this->email_user_table)->result();
  }

  public function clear() {
    return $this->db->empty_table($this->email_table);
  }

  public function clear_user_emails() {
    return $this->db->empty_table($this->email_user_table);
  }

  public function add_user_email($user_id) {
    $this->db->insert($this->email_user_table, array(
      'user_id' => $user_id,
    ));
  }
}
