<?

class Migration_Add_description_fields extends CI_Migration
{
	public function up()
	{
		$projects_add_columns = array(
      'description' => array('type' => 'VARCHAR', 'constraint' => 1024, 'null' => true),
    );
    $this->dbforge->add_column('projects', $projects_add_columns);

    $user_add_columns = array(
      'title' => array('type' => 'VARCHAR', 'constraint' => 255, 'null' => true),
      'location' => array('type' => 'VARCHAR', 'constraint' => 40, 'null' => true),
      'about' => array('type' => 'VARCHAR', 'constraint' => 255, 'null' => true),
      'private' => array('type' => 'TINYINT', 'constraint' => 1, 'null' => true),
      'disable_email' => array('type' => 'TINYINT', 'constraint' => 1, 'null' => true),
    );
    $this->dbforge->add_column('users', $user_add_columns);
	}

	public function down()
	{
    $projects_drop_columns = array(
      'description',
    );
    foreach ($projects_drop_columns as $projects_drop_column) {
      $this->dbforge->drop_column('projects', $projects_drop_column);
    }

    $users_drop_columns = array(
      'title',
      'location',
      'about',
      'private',
      'disable_email'
    );
    foreach ($users_drop_columns as $users_drop_column) {
      $this->dbforge->drop_column('users', $users_drop_column);
    }
	}
}
