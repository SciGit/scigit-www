<?

class Public_key extends CI_Model
{
	public $table = 'user_pub_keys';

  public function get($id) {
    $this->db->where('id', $id);
    return $this->db->get($this->table)->result();
  }

	public function get_by_user($user_id, $include_autogenerated = true) {
		$this->db->where('user_id', $user_id);
    if (!$include_autogenerated) {
      $this->db->where('auto_generated', 0);
    }
		return $this->db->get($this->table)->result();
	}

	public function get_by_key($key) {
		$this->db->where('public_key', $key);
		return $this->db->get($this->table)->result();
	}

	public function create($user_id, $name, $public_key, $auto_generated = true) {
		$key = $this->parse_key($public_key);
		if (!$key) return null;

		$data = array(
			'user_id' => $user_id,
			'name' => $name,
			'key_type' => $key['key_type'],
      'auto_generated' => $auto_generated,
			'public_key' => $key['public_key'],
			'comment' => $key['comment'],
		);
		if (!$this->db->insert($this->table, $data)) return null;
		$data['id'] = $this->db->insert_id();
		try {
			$this->load->library('scigit_thrift');
			Scigit_thrift::addPublicKey($data['id'], $user_id, $public_key);
		} catch (Exception $e) {
			$this->db->where('id', $data['id']);
			$this->db->delete($this->table);
			log_message('error', 'create public_key: ' . $e->getMessage());
			return null;
		}
		return $data;
	}

  public function delete($id) {
    $key = $this->get($id);
    if ($key === null) return false;

    $this->db->where('id', $id);
    $this->db->delete($this->table);

    try {
      $this->load->library('scigit_thrift');
      Scigit_thrift::deletePublicKey($id, $key->user_id, $key->public_key);
    } catch (Exception $e) {
      log_message('error', 'delete public_key: ' . $e->getMessage);
      return false;
    }

    return true;
  }

	public function parse_key($key) {
		$parts = preg_split("/\\s+/", $key);
		// key type, base64 key, (optional) comment
		if (count($parts) < 2) return null;
		if ($parts[0] != 'ssh-rsa' && $parts[0] != 'ssh-dsa') return null;

		$bytes = base64_decode($parts[1]);
		if ($bytes === false) return null;

		$pos = 0;
		$len = strlen($bytes);
		$blocks = array();
		while ($pos < $len) {
			// each block starts with a 4 byte length header
			if ($pos + 4 > $len) return null;
			$hexval = '';
			for ($i = 0; $i < 4; $i++) {
				$hexval .= sprintf('%02x', ord($bytes[$pos+$i]));
			}
			list($runlen) = sscanf($hexval, '%x');
			if ($runlen < 0 || $runlen >= 512 || $pos + 4 + $runlen > $len) {
				return null;
			}
			$blocks[] = substr($bytes, $pos + 4, $runlen);
			$pos += 4 + $runlen;
		}

		// three blocks: key type, exponent, modulus
		if (count($blocks) != 3) return null;
		if ($blocks[0] != $parts[0]) return null;
		if (strlen($blocks[2]) < 200) return null;

		return array(
			'key_type' => $parts[0],
			'public_key' => $parts[1],
			'comment' => isset($parts[2]) ? $parts[2] : '',
		);
	}
}
