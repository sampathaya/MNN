$("form#new_user")&&$("form#new_user").validate({rules:{"user[email]":{required:!0,minlength:4},"user[password]":{required:!0,minlength:6},"user[password_confirmation]":{required:!0,minlength:6}},showErrors:function(e){$.each(this.errorList,function(e,t){$(t.element).parent().parent().addClass("error"),$(t.element).attr("rel","tooltip"),$(t.element).attr("title",t.message)}),$("[rel='tooltip']").tooltip({placement:"right",trigger:"hover"})}}),$("form#edit_user")&&$("form#edit_user").validate({rules:{"user[email]":{required:!0,minlength:4}},showErrors:function(e){$.each(this.errorList,function(e,t){$(t.element).parent().parent().addClass("error"),$(t.element).attr("rel","tooltip"),$(t.element).attr("title",t.message)}),$("[rel='tooltip']").tooltip({placement:"right",trigger:"hover"})}}),$("#user_password")&&$("#user_password").complexify({minimumChars:6,strengthScaleFactor:.6},function(e,t){e?$("#progress").css({width:t+"%"}).removeClass("progressbarInvalid").addClass("progressbarValid"):$("#progress").css({width:t+"%"}).removeClass("progressbarValid").addClass("progressbarInvalid"),$("#complexity").html(Math.round(t)+"%")});