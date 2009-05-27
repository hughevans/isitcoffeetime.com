$(document).ready(function() {
  $('#custom a').click(function() {
    $(this).parent().hide();
    $('#team').slideDown();
    return false;
  });
});