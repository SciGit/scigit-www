/* Author: SciGit team.
 * Random utility functions.
 * drs: XXX comment properly.
 */

function equalizeColumns() {
  $('.hero-unit').css({
      'min-height': $('.login-form').height() -
										parseInt($('.hero-unit').css('padding-top')) -
										parseInt($('.hero-unit').css('padding-bottom'))
  });
}
