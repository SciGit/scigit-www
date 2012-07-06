<?

class Public_key extends CI_Model
{
	public $table = 'user_pub_keys';

	public function get_by_user($user_id) {
		$this->db->where('user_id', $user_id);
		return $this->db->get($this->table)->result();
	}

	public function get_by_key($key) {
		$this->db->where('public_key', $key);
		return $this->db->get($this->table)->result();
	}

	public function create($user_id, $name, $public_key) {
		$key = $this->parse_key($public_key);
		$data = array(
			'user_id' => $user_id,
			'name' => $name,
			'key_type' => $key['key_type'],
			'public_key' => $key['public_key'],
			'comment' => $key['comment'],
		);
		if (!$this->db->insert($this->table, $data)) return null;
		$data['id'] = $this->db->insert_id();
		update_repos();
		return $data;
	}

	public function parse_key($key) {
		$parts = preg_split("/\\s+/", $key);
		// key type, base64 key, (optional) comment
		if (count($parts) < 2) return null;
		if ($parts[0] != 'ssh-rsa' && $parts[0] != 'ssh-dsa') return null;

		$bytes = base64_decode($parts[1]);
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
