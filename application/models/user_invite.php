<?

class User_Invite extends CI_Model
{
  public $user_invite_table = 'user_invites';

  public function get() {
    return $this->db->get($this->user_invite_table)->result();
  }

  public function get_by_hash($hash) {
    $this->db->where('hash', $hash);
    $r = $this->db->get($this->user_invite_table)->result();
    if (empty($r)) return null;
    return $r[0];
  }

  public function create($from_user, $to_email, $proj_id, $permission) {
    $from_name = $from_user->fullname != null ? $from_user->fullname : $from_user->username;
    $hash = hash('sha256', '1a2a|' . $from_name . '|' . $to_email);

    $data = array(
      'proj_id' => $proj_id,
      'permission' => $permission,
      'hash' => $hash,
    );

    $this->db->insert($this->user_invite_table, $data);

    return $data;
  }

  public function delete($user_invite_id) {
    $this->db->where('id', $user_invite_id);
    $this->db->delete($this->user_invite_table);
    return true;
  }
}
