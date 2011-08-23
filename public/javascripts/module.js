//SHINE
$(document).ready(function() {
  $('#beta').hover(function(){
    $(this).find(".shine").css("background-position","-99px 0");
    $(this).find(".shine").animate({ backgroundPosition: '99px 0'},700);
  });

  setInterval(function() {
   $('#beta').find(".shine").css("background-position","-99px 0");
   $('#beta').find(".shine").animate({ backgroundPosition: '99px 0'},700);
  }, 10000);
});

$(function () {
  //NEW
//  $("#new").click().toggle(function() {
//    $("div#newform").stop().animate({height: "300px" }, 300, function() { 
//      $("div#newform").stop().animate({ height: "280px" }, 100);
//      
//      $(function () {
//        $('.socials').mobilyblocks({
//          direction: 'clockwise',
//          duration:300,
//          zIndex:500,
//          widthMultiplier:1.50
//        });
//      });
//    });
//    
//    showSave('form_new');
//    
//  }, function() {
//    console.log("NEW CLICKED")
//    $("div#newform").stop().animate({height: "-=280" }, 200, function() { /*callback*/ });
//  });
//  
//  //DELETE
//  $('#delete').live('click', function() {
//    var $values =  $('#shares').find('div.value');
//    var $placeholders =  $values.find('strong.remove-placeholder');
//    var $links = $values.find('a.remove-share');
//    
//    if ($placeholders.is(":visible")) {
//      $placeholders.hide();
//       $links.show();
//    } else {
//      $placeholders.show();
//      $links.hide();
//    }
//  });
//  
//  // SETTINGS
//  $('a#settings').click(function() {
//    $('div.actionscont').find('a').hide();
//    showSettings();
//    showSave('form_settings');
//  });

//  $('a#close').click(function() {
//    hideSettings();
//    hideSave();
//  });

//  // BACK
//  $('#back').click(function(){
//    form = $('#submit').data('form');
//    if(form == 'form_share') {
//      shrink();
//      hideSave();
//      return false;
//    } else if(form == 'form_new') {
//      $("div#newform").stop().animate({height: "-=300" }, 200);
//      hideSave();
//      return false;
//    } else {
//      return true;
//    }
//  });
//  
//  // SUBMIT/SAVE (TODO: JUST FOR TEST)
//  $('#submit').click(function() {
//    $('#'+$('#submit').data('form')).submit();
//    hideSave();
//  });
  
}); 

function showSave(form) {
  $('div.actionscont').find('a').hide();
  $submit = $('#submit')
  $submit.data('form', form);
  $submit.show().stop().delay(200).animate({ width: "100%" }, 100);
}

function hideSave() {
  $('#submit').stop().animate({ width: "0" }, 100);
  $('div.actionscont').find('a').show();
  $('#submit').data('form', '')
  $('#submit').hide();

}

//function hideSettings () {
//  $('#msettings').addClass('hidden').toggle(500);
//}

//function showSettings() {
//  $('#msettings').removeClass('hidden').toggle(500);
//}

//INIT FTOGGLES
function initSliders(color) {
  var $checkboxes = $('#mform').find('[type=checkbox].ftoggle');
  $checkboxes.slider({background:color});
}

//EXPAND DETAIL VIEW
//function expand() {
//  var $mcontent = $("#all-container");
//  var $mform = $("#mform");
//  var $links =  $('#shares').find('div.key');
//  
//  $('#msettings').hide();
//  
//  if($mform.height() != $mcontent.height()) {
//    console.log("BUG: ADAPT $MFORM HIGHT !!!");
//    $mform.height($mcontent.height());
//  }

//  setTimeout( function() {
//    console.log('hide links')
//    $links.hide();
//  }, 180);
//    
//  $mcontent.stop().animate({width: "0px" }, 300, function() {
//    var $lines =  $('#form_share').find('div.line');
//    $lines.hide();
//    $mcontent.hide();

//    setTimeout( function() {
//      $lines.show();
//    }, 180);

//    $mform.show().stop().animate({width: "99%" }, 300, function() {
//      showSave('form_share');
//      setTimeout( function() {
//         $mform.find('div.value img.wait').hide();
//         initSliders("orange");
//      }, 520);
//    });
//   });
//}

////SHRINK DETAIL VIEW
//function shrink() {
//  var $mcontent = $("#mcontent");
//  var $mform = $("#mform");

//  setTimeout( function() {
//    $('#mform').find('div.line').hide();
//  }, 180);
//  
//  $mform.stop().animate({width: "0px" }, 300, function() {
//    setTimeout( function() {
//      $('#shares').find('div.key').show();
//    }, 180);
//    
//    $mform.hide();
//    $mcontent.show().stop().animate({width: "100%" }, 300);
//  });
//}



