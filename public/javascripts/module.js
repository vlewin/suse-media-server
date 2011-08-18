$(function () {
  $('a#settings').click(function() {
    $('div.actionscont').find('a').hide();
    showSettings();
    showSave('form_settings');
  });

  $('a#close').click(function() {
    hideSettings();
    hideSave();
  });
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

function hideSettings () {
  $('#msettings').addClass('hidden').toggle(500);
}

function showSettings() {
  $('#msettings').removeClass('hidden').toggle(500);
}

//INIT FTOGGLES
function initSliders(color) {
  var $checkboxes = $('#mform').find('[type=checkbox].ftoggle');
  $checkboxes.slider({background:color});
}

//EXPAND DETAIL VIEW
function expand() {
  var $mcontent = $("#mcontent");
  var $mform = $("#mform");
  var $links =  $('#shares').find('div.key');
  
  $('#msettings').hide();
  
  if($mform.height() != $mcontent.height()) {
    console.log("BUG: ADAPT $MFORM HIGHT !!!");
    $mform.height($mcontent.height());
  }

  setTimeout( function() {
    console.log('hide links')
    $links.hide();
  }, 180);
    
  $mcontent.stop().animate({width: "0px" }, 300, function() {
    var $lines =  $('#form_share').find('div.line');
    $lines.hide();
    $mcontent.hide();

    setTimeout( function() {
      $lines.show();
    }, 180);

    $mform.show().stop().animate({width: "99%" }, 300, function() {
      showSave('form_share');
      setTimeout( function() {
         $mform.find('div.value img.wait').hide();
         initSliders("orange");
      }, 520);
    });
   });
}

//SHRINK DETAIL VIEW
function shrink() {
  var $mcontent = $("#mcontent");
  var $mform = $("#mform");

  setTimeout( function() {
    $('#mform').find('div.line').hide();
  }, 180);
  
  $mform.stop().animate({width: "0px" }, 300, function() {
    setTimeout( function() {
      $('#shares').find('div.key').show();
    }, 180);
    
    $mform.hide();
    $mcontent.show().stop().animate({width: "100%" }, 300);
  });
}

//SHOW FORM FOR NEW SHARES
$(document).ready(function() {
  $("#new").click().toggle(function() {
    $("div#newform").stop().animate({ height: "300px" }).animate({ height: "280px" }, "fast");
    showSave('form_new');
  }, function() {
    $("div#newform").stop().animate({height: "-=280" }, 200, function() { /*callback*/ });
  });
});


$(document).ready(function() {
  var $links =  $('#shares').find('div.link');
  var $actionlinks = $('a.actionlink');
  
  $actionlinks.unbind('click');
  $actionlinks.click(function(event) {
    console.log("CICKEDF");
    event.stopPropagation();
    event.preventDefault();
    return false;
  });
//  $("#delete").live('click', function() {
//    $links.each(function() {
//      console.log($(this));
//      $(this).removeClass('beforelink');
//      $(this).find('div.value').html('<input type="checkbox" class="delete" />')
//      
//      
//    });
//  });
  
  $("#delete").click().toggle(function() {
    
    console.log($(this).find('a.actionlink'))
    $links.each(function() {
      $(this).find('strong.remove-placeholder').hide();
      $(this).find('a.remove-share').show();
//      $(this).removeClass('beforelink');
//      $(this).find('div.value').html('<span class="delcont"><img src="../images/destroy.png"></span>')
    });
    
  }, function() {
    $links.each(function() {
      $(this).find('strong.remove-placeholder').show();
      $(this).find('a.remove-share').hide();
    });
  });

});

//BACK
$(function () {
  $('#back').click(function(){
    form = $('#submit').data('form');
    if(form == 'form_share') {
      shrink();
      hideSave();
      return false;
    } else if(form == 'form_new') {
      $("div#newform").stop().animate({height: "-=300" }, 200);
      hideSave();
      return false;
    } else {
      return true;
    }
  });
});

//SAVE ACTION
//TODO: REFACTORING JUST FOR TEST!!!
$(function () {
  $('#submit').click(function() {
    $('#'+$('#submit').data('form')).submit();
    hideSave();
  });
});

