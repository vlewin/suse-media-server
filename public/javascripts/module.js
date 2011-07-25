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
  $('#msettings').addClass('hidden').toggle('hide');
}

function showSettings() {
  $('#msettings').removeClass('hidden').toggle('show');
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
  var $msettings = $('#msettings');
  
  var width = $mcontent.width();
  var $toggles = $mform.find('div.line').find('span.ftoggle_container');
  
  $toggles.hide();
  $msettings.fadeOut(50);
  
  $mform.height($mcontent.height());
  
  $mcontent.stop().animate({width: "0px" }, 500, function() {
    $mcontent.hide();

    $mform.show().stop().animate({width: "99%" }, 500, function() {
      showSave('form_share');
      $toggles.stop().delay(200).fadeIn();
    });
   });
}

//SHRINK DETAIL VIEW
function shrink() {
  var $mcontent = $("#mcontent");
  var $mform = $("#mform");
  
  var width = $mcontent.width();
  var $toggles = $mform.find('div.line').find('span.ftoggle_container');
  
  $toggles.hide();

  $mform.stop().animate({width: "0px" }, 500, function() {
    $mform.hide();
    $mcontent.show().stop().animate({width: "100%" }, 500);
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

