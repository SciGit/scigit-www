<?

class Changes extends SciGit_Controller
{
	public function __construct() {
		parent::__construct();
		$this->load->model('project');
		$this->load->model('change');
		$this->load->model('permission');
		$this->load->library('form_validation');
		check_login();
	}

	public function view($id, $path = '') {
		$change = $this->change->get($id);
		if ($change == null) {
			show_404();
		}
		check_project_perms($change->proj_id);
		$path = urldecode($path);

		$data = array(
			'project' => $this->project->get($change->proj_id),
			'change' => $change,
			'path' => $path,
		);
		$type = $this->change->get_type($id, $path);
		if ($type == 'dir' || $path == '') {
			$data['listing'] = $this->change->get_listing($id, $path);
		} else if ($type == 'file') {
			$file = $this->change->get_file($id, $path);
			if (strpos($file, '\0') === false) {
				$data['file'] = $file;
				$data['binary'] = false;
			} else {
				$data['binary'] = true;
			}
		} else {
			show_404();
		}
		$this->twig->display('changes/view.twig', $data);
	}

	public function raw($id, $path, $download = '') {
		$change = $this->change->get($id);
		if ($change == null) show_404();
		check_project_perms($change->proj_id);

		$path = urldecode($path);
		$type = $this->change->get_type($id, $path);
		if ($type != 'file') show_404();
		$file = $this->change->get_file($id, $path);

		header("Content-Type: text/plain");
		if ($download) {
			header("Content-Disposition: attachment; filename=".basename($path));
		}
		echo $file;
	}

  public function diff_ajax() {
    $this->form_validation->set_rules('id', 'id', 'required');
    $this->form_validation->set_rules('path', 'path', '');

    if ($this->form_validation->run()) {
      $id = $this->input->post('id');
      $path = $this->input->post('path');

      $change = $this->change->get($id);
      if ($change == null) {
        echo json_encode(array(
          'error' => '1',
          'message' => 'Database error, please try later.',
        ));
        return;
      }
      check_project_perms($change->proj_id);

      $path = urldecode($path);
      $type = $this->change->get_type($id, $path);
      if (false && $type != 'file') {
        echo json_encode(array(
          'error' => '2',
          'message' => 'Invalid change id.',
        ));
        return;
      }
      $file = $this->change->get_file($id, $path);
      $diff = $this->change->get_diff_set($id, $path);

      if ($diff == null || $diff == "" || $diff == " " || empty($diff)) {
        $diff = <<<EOF
diff --git a/application/views/projects/changes.twig b/application/views/projects/changestwig
index 995a4b6..0d53ef6 100755
--- a/application/views/projects/changes.twig
+++ b/application/views/projects/changes.twig
@@ -5,6 +5,12 @@
 {% block content %}
 
 <script>
+  $(document).ready(function() {
+    $('.changes').click(function(e) {
+      e.preventDefault();
+    });
+  });
+
   function expandChanges(change) {
     var change_id = change.getAttribute('data-change_id');
     var td = $("[data-change_id='" + change_id + "']");
@@ -87,7 +93,7 @@
               </div>
               <div class="button">
                 <a href="#" onclick="expandChanges(this)" class="rawlink" data-change_id="{{ change.id }}" rel="tooltip" title="Expand differences">
-                  <i class="icon-plus-sign-alt icon-large"></i>
+                  <i class="changes icon-plus-sign-alt icon-large"></i>
                 </a>
               </div>
               <div class="button">
diff --git a/application/views/projects/changes.twig2 b/application/views/projects/changes.twig
index 995a4b6..0d53ef6 100755
--- a/application/views/projects/changes.twig
+++ b/application/views/projects/changes.twig
@@ -5,6 +5,12 @@
 {% block content %}
 
 <script>
+  $(document).ready(function() {
+    $('.changes').click(function(e) {
+      e.preventDefault();
+    });
+  });
+
   function expandChanges(change) {
     var change_id = change.getAttribute('data-change_id');
     var td = $("[data-change_id='" + change_id + "']");
@@ -87,7 +93,7 @@
               </div>
               <div class="button">
                 <a href="#" onclick="expandChanges(this)" class="rawlink" data-change_id="{{ change.id }}" rel="tooltip" title="Expand differences">
-                  <i class="icon-plus-sign-alt icon-large"></i>
+                  <i class="changes icon-plus-sign-alt icon-large"></i>
                 </a>
               </div>
               <div class="button">
diff --git a/file with spaces b/file with spaces
deleted file mode 100644
index 8d69e54..0000000
--- a/file with spaces  
+++ /dev/null
@@ -1 +0,0 @@
-file: file with spaces
diff --git a/application/controllers/testthing b/application/controllers/testthing
new file mode 100644
index 0000000..12892f5
--- /dev/null
+++ b/application/controllers/testthing
@@ -0,0 +1 @@
+oh
EOF;
      }

      echo json_encode(array(
        'error' => '0',
        'message' => $diff,
        'file' => $file,
        'commit_msg' => $change->commit_msg,
      ));
    } else {
      echo json_encode(array(
        'error' => '2',
        'message' => 'Invalid change id.',
      ));
      return;
    }
  }
}
