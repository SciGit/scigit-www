<?

class Migration_Add_invite_to_scigit_queue extends CI_Migration
{
  public function up()
  {
    $fields = array(
      'id' => array(
        'type' => 'INT',
        'auto_increment' => true,
      ),

      'user_id' => array(
        'type' => 'INT',
        'null' => false,
      ),

      'proj_id' => array(
        'type' => 'INT',
        'null' => false,
      ),

      'to' => array(
        'type' => 'VARCHAR',
        'constraint' => '100',
        'null' => false,
      ),

      'permission' => array(
        'type' => 'INT',
        'null' => false,
      ),

      'hash' => array(
        'type' => 'VARCHAR',
        'constraint' => '64',
        'null' => false,
      ),
    );

    $this->dbforge->add_field($fields);
    $this->dbforge->add_key('id', true);
    $this->dbforge->add_key('user_id');
    $this->dbforge->add_key('proj_id');
    $this->dbforge->create_table('email_invite_to_scigit_queue');

    $fields = array(
      'id' => array(
        'type' => 'INT',
        'auto_increment' => true,
      ),

      'proj_id' => array(
        'type' => 'INT',
        'null' => false,
      ),

      'permission' => array(
        'type' => 'INT',
        'null' => false,
      ),

      'hash' => array(
        'type' => 'VARCHAR',
        'constraint' => '64',
        'null' => false,
      ),
    );

    $this->dbforge->add_field($fields);
    $this->dbforge->add_key('id', true);
    $this->dbforge->add_key('proj_id');
    $this->dbforge->create_table('user_invites');
  }

  public function down()
  {
    $this->dbforge->drop('email_invite_to_scigit_queue');
    $this->dbforge->drop('user_invites');
  }
}
