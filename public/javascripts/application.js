//DASHBOARD
$(document).ready(function() {
  $("div.panel_button").click(function(){
    $("div#panel").animate({ height: "80px" }).animate({ height: "52px" }, "fast");
//    $("img.dashboard_button").toggle();
    $("div.panel_button").toggle();
  });

  $("div#hide_button").click(function(){
    $("div#panel").animate({ height: "0px"}, "fast");
  });
});

//DASHBOARD
$(document).ready(function() {
  $("a#add").click().toggle(function() {
    console.log("TOGGLE")
//    $("div#panel").animate({height: 200}, 200, function() {
      $("div#newform").stop().animate({ height: "300px" }).animate({ height: "280px" }, "fast");
//    });
  }, function() {
    $("div#newform").stop().animate({height: "-=300" }, 200, function() {
//      $('#slider').css('background', '#888');
//      $('#status label').text("Disabled")
    });
  });

//  $("a#add").click(function(){
//    $("div#panel").animate({ height: "80px" }).animate({ height: "52px" }, "fast");
//    $(this).addClass('expanded');
//  });

//  $("div#hide_button").click(function(){
//    $("div#panel").animate({ height: "0px"}, "fast");
//  });
});

//END DASHBOARD

//SHINE EFFECT
$(document).ready(function() {
  $('#beta').hover(function(){
    $(this).find(".shine").css("background-position","-99px 0");
    $(this).find(".shine").animate({ backgroundPosition: '99px 0'},700);
  });

  setInterval(function() {
   $('#beta').find(".shine").css("background-position","-99px 0");
   $('#beta').find(".shine").animate({ backgroundPosition: '99px 0'},700);
  }, 5000);
});
//END SHINE EFFECT

$(document).ready(function() {
  $('li.grid_3').hover(function(){
    $(this).find("div.info_image_shine").css("background-position","-120px 0");
    $(this).find("div.info_image_shine").stop().animate({ backgroundPosition: '120px 0'},500);
  });

  $('.info_image').find("div.info_image_shine").css("background-position","-120px 0");
  $('.info_image').find("div.info_image_shine").animate({ backgroundPosition: '120px 0'},700);
});

$(document).ready(function() {
  $("#box").click().toggle(function() {
    $(this).animate({left: "+="+$(this).width() }, 200, function() {
      $('#slider').css('background', 'green');
      $('#status label').text("Enabled")
    });
  }, function() {
    $(this).animate({left: "-="+$(this).width() }, 200, function() {
      $('#slider').css('background', '#888');
      $('#status label').text("Disabled")
    });
  });
});

jQuery(document).ready(function() {
	$("a#ToogleSidebar").click().toggle(function() {
		$('#sidebar').animate({
			width: 'hide',
			opacity: 'hide'
		}, 'slow');
	}, function() {
		$('#sidebar').animate({
			width: 'show',
			opacity: 'show'
		}, 'fast');
	});
});


function slide() {
  $wait =  '<img src="/images/wait.gif" style="display:inline-block; text-align:center; vertical-align:middle; border-radius:100%; " alt="Expanded" border="0" />'
  $wait += '<label style="font-weight:bold; margin-left:5px; vertical-align:middle; font-size:20px; color:#666;"> Please wait ...<label>';
    $("#shares").hide();
    $("#share").stop().delay(200).show().html($wait).delay(200)

    $("#share").animate({height:'+225px'},{queue:false,duration:200});
    console.log($("#share").text());
    return false;
}

  function adaptHeight() {
    console.log("Set timout")
    $('#wait').fadeOut('fast');
    var height = $("#share").find('form').height();
    console.log(height)
    $('#create span').text('Update');
    $("#share").css('border', '0px solid red').stop().animate({height:'+'+height},{queue:false,duration:500});
  }

  $(document).ready(function(){
    var shares_h = $("#shares").height();
    var share_h = $("#share").height();
    var form_h = $('#form_for_share').height();


    $('#back').live('click', function() {

      if($(this).hasClass('back')) {
        $("#share").stop().animate({height:'-' + share_h },{queue:false,duration:300}).hide();
        $("#shares").show().animate({height:'+' +shares_h},{queue:false,duration:300});

        $(this).removeClass('back');
        $('#create span').text('Create share');
        return false;

      } else if($(this).hasClass('form')){

        $("#form_for_share").stop().animate({height:'-'+form_h },{queue:false,duration:300}).hide();
        $("#shares").stop().show().animate({height:'+' + shares_h},{queue:false,duration:300});

        return false;
      } else {
        window.location="/";
      }

    });

     $('#create').live('click', function() {
        if($('#create span').text() == 'Update') {
          console.log('highlight')
          $('#form').submit();
        } else {
          $("#form_for_share").show().stop().animate({height:'+' +shares_h},{queue:false,duration:300});
          $("#shares").stop().animate({height:'-' + share_h },{queue:false,duration:300}).hide();
          $('#back').addClass('form')

        }
    });

  });

