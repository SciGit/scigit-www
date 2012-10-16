<?

class Migration_Unify_membership_and_permissions extends CI_Migration
{
  // Properly defined in Permission model. Not sure how to load that model from
  // here.
  const SUBSCRIBER = 1;
  const READ = 2;
  const WRITE = 4;
  const ADMIN = 8;
  const OWNER = 16;

  public function up()
  {
    $this->dbforge->add_field(array(
      'id' => array('type' => 'INT', 'auto_increment' => true),
      'user_id' => array('type' => 'INT', 'null' => false),
      'proj_id' => array('type' => 'INT', 'null' => false),
      'permission' => array('type' => 'INT', 'null' => false),
    ));

    $this->dbforge->add_key('id', TRUE);
    $this->dbforge->add_key('user_id');
    $this->dbforge->add_key('proj_id');
    $this->dbforge->create_table('proj_permissions_temp');

    $projects = array(array());

    $query = "SELECT * FROM proj_permissions";
    $permissions = $this->db->query($query)->result();
    foreach ($permissions as $permission) {
      $projects[$permission->proj_id][$permission->user_id] |=
        self::READ;
      $projects[$permission->proj_id][$permission->user_id] |=
        $permission->can_admin ? self::ADMIN : 0;
      $projects[$permission->proj_id][$permission->user_id] |=
        $permission->can_write ? self::WRITE : 0;
    }

    $query = "SELECT * FROM proj_membership";
    $memberships = $this->db->query($query)->result();
    foreach ($memberships as $membership) {
      $projects[$membership->proj_id][$membership->user_id] |=
        self::SUBSCRIBER;
    }

    $query = "SELECT * FROM projects";
    $proj_models = $this->db->query($query)->result();
    foreach ($proj_models as $proj_model) {
      $projects[$proj_model->id][$proj_model->owner_id] |=
        self::OWNER;
    }

    foreach ($projects as $proj_id => $users) {
      foreach ($users as $user_id => $permission) {
        $query = "INSERT INTO proj_permissions_temp VALUES
          (null, $user_id, $proj_id, $permission)";
        $this->db->query($query);
        var_dump($this->db->last_query());
      }
    }

    $this->dbforge->drop_table('proj_permissions');
    $this->dbforge->drop_table('proj_membership');

    $this->dbforge->add_field(array(
      'id' => array('type' => 'INT', 'auto_increment' => true),
      'user_id' => array('type' => 'INT', 'null' => false),
      'proj_id' => array('type' => 'INT', 'null' => false),
      'permission' => array('type' => 'INT', 'null' => false),
    ));

    $this->dbforge->add_key('id', TRUE);
    $this->dbforge->add_key('user_id');
    $this->dbforge->add_key('proj_id');
    $this->dbforge->create_table('proj_permissions');

    $query = "INSERT INTO proj_permissions SELECT * FROM proj_permissions_temp";
    $this->db->query($query);

    $this->dbforge->drop_column('projects', 'owner_id');
  }

  public function down()
  {
    die('YOU SHALL NOT PASS!');
  }
}
