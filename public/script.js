$(document).ready(function() {
  $('#byline a').click(function() {
    $('#yes').animate({marginTop:'-40px'});
    $('#byline').hide();
    $('#custom').slideDown('normal', function() {
      $('input#name').focus();
    });
    return false;
  });
  
  $('input#name, input#twitter_account').keyup(function(press) {
    // Don't check when tabbing into field
    if (press.keyCode != 9) {
      validateAttribute(this);
    }
  });
  
  $('select#time_zone').click(function () {
    validateAttribute(this);
  });
  
  $('#custom form').submit(function() {
    $.ajax({
      type: 'POST',
      url: this.action,
      dataType: 'json',
      data: $(this).serialize(),
      success: function(rsp) {
        if(rsp.success) {
          location.href = '/' + rsp.team.name;
        }
        else {
          alert('Fix your form.');
        }
      }
    });
    return false;
  });
  
  function validateAttribute(e) {
    var element = $(e);
    $.ajax({
      type: 'POST',
      url: '/teams?validate=' + element.attr('id'),
      dataType: 'json',
      data: element.serialize(),
      success: function(rsp) {
        if(rsp.no_errors) {
          element.css('border-color', '#999');
        }
        else {
          element.css('border-color', 'red');
        }
      }
    });
  };
});