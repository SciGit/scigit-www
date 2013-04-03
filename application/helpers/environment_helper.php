<?

define('SCIGIT_BASE_PATH_PRE', 'https://');
define('SCIGIT_BASE_PATH_PRE_GIT', 'ssh://git@');
define('SCIGIT_BASE_PATH_POST', 'scigit.com');

define('SCIGIT_DEVELOPMENT_PATH', SCIGIT_BASE_PATH_PRE + 'localhost');
define('SCIGIT_TESTING_PATH', SCIGIT_BASE_PATH_PRE . 'stage.' . SCIGIT_BASE_PATH_POST);
define('SCIGIT_PRODUCTION_PATH', SCIGIT_BASE_PATH_PRE . 'www.' . SCIGIT_BASE_PATH_POST);

define('SCIGIT_DEVELOPMENT_PATH_GIT', SCIGIT_BASE_PATH_PRE_GIT . 'localhost');
define('SCIGIT_TESTING_PATH_GIT', SCIGIT_BASE_PATH_PRE_GIT . 'stage.' . SCIGIT_BASE_PATH_POST);
define('SCIGIT_PRODUCTION_PATH_GIT', SCIGIT_BASE_PATH_PRE_GIT . 'www.' . SCIGIT_BASE_PATH_POST);

function get_hostname() {
  switch (ENVIRONMENT) {
    case 'development':
      return SCIGIT_DEVELOPMENT_PATH;
    case 'testing':
      return SCIGIT_TESTING_PATH;
    case 'production':
      return SCIGIT_PRODUCTION_PATH;
  }
}

function get_git_path() {
  switch (ENVIRONMENT) {
    case 'development':
      return SCIGIT_DEVELOPMENT_PATH_GIT;
    case 'testing':
      return SCIGIT_TESTING_PATH_GIT;
    case 'production':
      return SCIGIT_PRODUCTION_PATH_GIT;
  }
}

function is_ssl() {
  return isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off';
}
