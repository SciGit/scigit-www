<?

class User_Seen extends CI_Model
{
  public $user_seen = 'user_seen';

  public function get($user_id, $key) {
		$this->db->where('user_id', $user_id);
    $this->db->where('key', $key);
		$r = $this->db->get($this->user_seen)->result();
		if (empty($r)) return null;
		return $r[0]->value;
  }

  public function set($user_id, $key, $value) {
    $data = array(
      'user_id' => $user_id,
      'key' => $key,
      'value' => $value,
    );

    if ($this->get($user_id, $key) !== null) {
      $this->db->where('user_id', $user_id);
      $this->db->where('key', $key);
      $this->db->update($this->user_seen, $data);
    } else {
      $this->db->insert($this->user_seen, $data);
    }
  }
}
