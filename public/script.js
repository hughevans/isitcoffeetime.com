$(document).ready(function() {
  $('#custom a').click(function() {
    $(this).parent().hide();
    $('#team').slideDown();
    return false;
  });
  
  $('#team form').submit(function() {
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