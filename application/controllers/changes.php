<?

class Changes extends SciGit_Site_Controller
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
        $this->response(array('message' => 'Database error. Try again later.'), 500);
      }
      check_project_perms($change->proj_id);

      $path = urldecode($path);
      $type = $this->change->get_type($id, $path);
      if (false && $type != 'file') {
        $this->response(array('message' => 'Invalid change id.'), 404);
      }
      $file = $this->change->get_file($id, $path);
      $diff = $this->change->get_diff_set($id, $path);

      if (true || $diff == null || $diff == "" || $diff == " " || empty($diff)) {
        $diff1 =
<<<EOF
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
EOF;

        $diff2 =
<<<EOF
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
EOF;

        $diff3 =
<<<EOF
diff --git a/file with spaces b/file with spaces
deleted file mode 100644
index 8d69e54..0000000
--- a/file with spaces  
+++ /dev/null
@@ -1 +0,0 @@
-file: file with spaces
EOF;

        $diff4 =
<<<EOF
diff --git a/application/controllers/testthing b/application/controllers/testthing
new file mode 100644
index 0000000..12892f5
--- /dev/null
+++ b/application/controllers/testthing
@@ -0,0 +1 @@
+oh
EOF;

        $diff = array(
          array(
            'binary' => 'true',
            'path' => 'test.binary',
            'diff' => null,
          ),
          array(
            'path' => 'application/views/projects/changes.twig',
            'binary' => 'false',
            'diff' => $diff1,
          ),
          array(
            'binary' => 'true',
            'path' => 'document.docx',
            'diff' => null,
          ),
          array(
            'path' => 'application/views/projects/changes.twig2',
            'binary' => 'false',
            'diff' => $diff2,
          ),
          array(
            'path' => 'file with spaces',
            'binary' => 'false',
            'diff' => $diff3,
          ),
          array(
            'path' => 'application/controllers/testthing',
            'binary' => 'false',
            'diff' => $diff4,
          )
        );

        $diff1 = 
<<<EOF
diff --git a/Non-disclosure agreement.docx b/Non-disclosure agreement.docx
index 995a4b6..0d53ef6 100755
--- a/Non-disclosure agreement.docx
+++ b/Non-disclosure agreement.docx
@@ -1,1 +1,1 @@
-                                     <b>MUTUAL NON-DISCLOSURE AGREEMENT</b>
+                                             <b>NON-DISCLOSURE AGREEMENT</b>

 This Agreement is made and entered into as of the last date signed below (the “Effective Date”)
 by and between Triad Search Marketing, LLC (The Company); an Internet Marketing corporation
 having its principal place of business at 7680 Airline Road Greensboro, NC 27409 and John
 Smith Inc., a Silicon Valley corporation whose principal mailing address is 234 Fake Street,
 Waterloo, ON (the "Second Party").
 <a href="#">View more ...</a>
EOF;
        $diff = array(
          array(
            'path' => 'Non-disclosure agreement.docx',
            'binary' => 'true',
            'diff' => $diff1,
          ),
        );
      }

      $this->response(array(
        'message' => $diff,
        'file' => $file,
        'commit_msg' => $change->commit_msg,
      ), 200);
    } else {
      $this->response(array('message' => 'Invalid change id.'), 404);
    }
  }
}
