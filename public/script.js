$(document).ready(function() {
  $('#byline a').click(function() {
    $('#yes').animate({marginTop:'-40px'});
    $('#byline').hide();
    $('#custom').slideDown('normal', function() {
      $('input#name').focus();
    });
    return false;
  });
  
  $('input#name').change(function () {
    $.ajax({
      type: 'POST',
      url: '/teams?validate_only=true',
      dataType: 'json',
      data: $(this).serialize(),
      success: function(rsp) {
        if(rsp.no_errors) {
          alert('No Errors');
        }
        else {
          alert(rsp.errors.name[0]);
        };
      }
    });
  });
  
  $('#custom form').submit(function() {
    $.ajax({
      type: 'POST',
      url: this.action,
      dataType: 'json',
      data: $(this).serialize(),
      success: function(rsp) {
        if(rsp.success) {
          alert('Saved');
          location.href = '/' + rsp.team.name;
        }
        else {
          alert(rsp.errors.name);
        };
      }
    });
    return false;
  });
  
});