$(document).ready(function() {
  $('#byline a').click(function() {
    $('#yes').animate({marginTop:'-40px'});
    $('#byline').hide();
    $('#custom').slideDown('normal', function() {
      $('input#name').focus();
    });
    return false;
  });
  
  $('input#name, input#twitter_account, select#time_zone').keyup(function(press) {
    // Don't check when tabbing into field or pressing shift
    if ((press.keyCode != 9) && (press.keyCode != 16)) {
      validateAttribute(this);
    }
  });
  
  $('select#time_zone').change(function () {
    validateAttribute(this);
  });
  
  $('select#time_zone').blur(function () {
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
          $('#custom #submit').effect('shake', { times:3, distance:8 }, 100);
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
          element.css({'border-color' : '#999', 'color' : '#000'});
        }
        else {
          element.css({'border-color' : 'red'});
          if(element.attr('tagName') != 'SELECT') {
            element.css({'color' : 'red'});
          }
        }
      }
    });
  };
});