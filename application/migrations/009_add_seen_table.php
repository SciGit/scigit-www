<?

class Migration_Add_seen_table extends CI_Migration
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

      'key' => array(
        'type' => 'VARCHAR',
        'constraint' => 100,
        'null' => false,
      ),

      'value' => array(
        'type' => 'INT',
        'null' => false,
      ),
    );

    $this->dbforge->add_field($fields);
    $this->dbforge->add_key('id', true);
    $this->dbforge->add_key('user_id');
    $this->dbforge->add_key('key');
    $this->dbforge->create_table('user_seen');
  }

  public function down()
  {
    $this->dbforge->drop('user_seen');
  }
}
