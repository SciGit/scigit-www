<?

class Migration_Add_proj_membership extends CI_Migration
{
	public function up()
	{
		$this->dbforge->add_field(array(
			'id' => array('type' => 'INT', 'auto_increment' => true),
			'user_id' => array('type' => 'INT', 'null' => false),
			'proj_id' => array('type' => 'INT', 'null' => false),
		));

		$this->dbforge->add_key('id', TRUE);
		$this->dbforge->add_key('user_id');
		$this->dbforge->add_key('proj_id');
		$this->dbforge->create_table('proj_membership');
	}

	public function down()
	{
		$this->dbforge->drop_table('proj_membership');
	}
}
