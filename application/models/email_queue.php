<?

class Email_Queue extends CI_Model
{
  public $email_table = 'email_queue';

  public function get() {
    
    return $this->db->get($this->email_table)->result();
  }
}
