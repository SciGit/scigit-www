<?

class Legal extends SciGit_Site_Controller
{
  function __construct()
  {
    parent::__construct();
  }

  function index()
  {
    $this->twig->display('legal/index.twig');
  }

  function privacy_policy()
  {
    $this->twig->display('legal/privacy_policy.twig');
  }

  function user_agreement()
  {
    $this->twig->display('legal/user_agreement.twig');
  }

  function terms_and_conditions()
  {
    $this->twig->display('legal/terms_and_conditions.twig');
  }
}
