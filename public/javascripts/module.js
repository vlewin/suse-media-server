$(function () {
  //TODO: JUST FOR TEST -> REFACTORING
  $('#back').click(function(){
    if ($('#msettings').hasClass('new')) {
      $("div#newform").stop().animate({height: "-=300" }, 200, function() { });
      hideSave();
      return false;
    } else {
      shrink();
      hideSave();
      return false;
    }
  })
});

$(function () {
  $('a#settings').click(function() {
    $('div.actionscont').find('a').hide();
    showSettings();
    showSave();
  });

  $('a#close').click(function() {
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
  var width = $mcontent.width();


  var $toggles = $mform.find('div.line').find('span.ftoggle_container');
  $toggles.hide();

  $mform.height($mcontent.height());

  $('#msettings').fadeOut(50);
  showSave();

  $mcontent.stop().animate({width: "1px" }, 300, function() {
    $mcontent.hide();

    $mform.show().stop().animate({width: "99%" }, 500, function() {
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


  $mform.stop().animate({width: "1px" }, 500, function() {


    $mform.hide();
    $mcontent.show();

    $mcontent.stop().animate({width: "100%" }, 300, function() {
      $mcontent.stop();
    });
  });
}


//SAVE ACTION
//TODO: REFACTORING JUST FOR TEST!!!
$(function () {
  $('#submit').click(function() {

    if($("#msettings").hasClass('new')) {
      $("#toppanel").find('form').submit();
      $("#msettings").removeClass('new');
      console.log("SET NEW SHARE");
      hideSave();
    }

    else if($("#msettings").hasClass('hidden')) {
      $("#mform").find('form').submit();
      console.log("SET SHARE SETTINGS")

    } else {
      $("#msettings").find('form').submit();
      console.log("SET GLOBAL SETTINGS")
    }
  });
});

