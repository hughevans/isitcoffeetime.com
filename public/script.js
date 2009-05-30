$(document).ready(function() {
  $('#byline a').click(function() {
    $('#yes').animate({marginTop:'-40px'});
    $('#byline').hide();
    $('#custom').slideDown('normal', function() {
      $('input#name').focus();
    });
    return false;
  });
  
  $('#custom form').submit(function() {
    $.ajax({
      type: "POST",
      url: this.action,
      dataType: "json",
      data: this.data,
      success: function(rsp)
      {
        location.href = '/' + rsp.team.name;
      },
      error: function(rsp,textStatus, errorThrown)
      {
      }
    });
    return false;
  });
  
});