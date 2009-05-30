$(document).ready(function() {
  $('#byline a').click(function() {
    $('#yes').animate({marginTop:'-40px'}, function() {
      $(this).animate({opacity:0}, function() {
        $(this).html('custom').css('font-size', '112px').css('margin-top', '20px').animate({opacity:1});
      });
    });
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