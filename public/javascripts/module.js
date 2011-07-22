$(function () {
  $('#back').click(function(){
    shrink();
    hideSave();
    return false;
  })
});

$(function () {
  $('a#settings').click(function() {
    $('div.actionscont').find('a').hide();
//    $('div.msettings').toggle('show');
    showSettings();
    showSave();
  });

  $('a#close').click(function() {
//    $('div.msettings').toggle('hide');
    hideSettings();
    hideSave();
  });
});


function showSave() {
  $('div.actionscont').find('a').hide();
  $('#submit').show();
  $('#submit').stop().delay(200).animate({ width: "100%" }, 100);
}

function hideSave() {
  $('#submit').stop().animate({ width: "0" }, 100);
  $('div.actionscont').find('a').show(); 
  $('#submit').hide();
  
}

function hideSettings () {
//  $('div.msettings').fadeOut();
  $('#msettings').addClass('hidden').toggle('hide');
}

function showSettings() {
  $('#msettings').removeClass('hidden').toggle('show');
//  $('div.msettings').fadeIn();
}

//INIT FTOGGLES
function initSliders(color) {
  var $checkboxes = $('#mform').find('[type=checkbox].ftoggle');
  $checkboxes.slider({background:color});
}

//EXPAND DETAIL VIEW
//function expand($link) {
function expand() {
  var $mcontent = $("#mcontent");
  var $mform = $("#mform");
  var width = $mcontent.width();
  

  var $toggles = $mform.find('div.line').find('span.ftoggle_container');
  $toggles.hide();

//  hideSettings();
  $('#msettings').fadeOut(50);
  showSave();
  
//  $mcontent.find('div.link').hide();
  $mcontent.stop().animate({width: "1px" }, 300, function() {
    $mcontent.hide();
    
    $mform.show().stop().animate({width: "99%" }, 500, function() {
//      $mform.stop().delay(200).animate({ width: "99%" }, 100);
//      $toggles.show();
    });

    $toggles.stop().delay(100).fadeIn(800);
  });
}

//SHRINK DETAIL VIEW
function shrink() {
  var $mcontent = $("#mcontent");
  var $mform = $("#mform");
  var width = $mcontent.width();

  var $toggles = $mform.find('div.line').find('span.ftoggle_container');
  $toggles.hide();
  
//  $mform.find('div.line').hide();
  
  $mform.stop().animate({width: "1px" }, 500, function() {
    
    
//    $mform.find('div.line').hide();
    $mform.hide(); 
    $mcontent.show();
    
    $mcontent.stop().animate({width: "100%" }, 300, function() {
      $mcontent.stop();
    });
  });
}


//SAVE ACTION
$(function () {
  $('#submit').click(function() {
    if($("#msettings").hasClass('hidden')) {
      $("#mform").find('form').submit();
      console.log("SET SHARE SETTINGS")
    } else {
      $("#msettings").find('form').submit();
      console.log("SET GLOBAL SETTINGS")
    }
  });
});
