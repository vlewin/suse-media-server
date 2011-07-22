$(function () {
//  var $mcontent = $("#mcontent");
//  var $links = $mcontent.find('div.link');


//BACK CLICKED
  $('#back').click(function(){
    //    $links.removeClass('active');
    shrink();
    hideSave();
    return false;
  })
  
  //LINK CLICKED
// $('div.link').click(function(){
  //    $links.removeClass('active');
//    expand($(this));
//  });
});

$(function () {
//  $('a.show_container').click(function() {
//    $('.hidden_container').show();
//  });
  $('a#settings').click(function() {
    $('div.actionscont').find('a').hide();
    $('div.msettings').toggle('show');
    showSave();
  });

  $('a#close').click(function() {
    $('div.msettings').toggle('hide');
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

//INIT FTOGGLES
function initSliders(color) {
  var $checkboxes = $('#mform').find('[type=checkbox].ftoggle');
  $checkboxes.slider({background:color});
}

//EXPAND DETAIL VIEW
function expand($link) {
  var $mcontent = $("#mcontent");
  var $mform = $("#mform");
  var width = $mcontent.width();
  

  var $toggles = $mform.find('div.line').find('span.ftoggle_container');
  
  $('div.msettings').hide();
  showSave();
  
//  $mcontent.find('div.link').hide();
  $mcontent.stop().animate({width: "1px" }, 300, function() {
    $mcontent.hide();
    //var $toggles = $mform.find('div.line').find('span.ftoggle_container');
    $toggles.hide();
  
    $mform.show().stop().animate({width: "99%" }, 500, function() {
//      $mform.stop().delay(200).animate({ width: "99%" }, 100);
      $toggles.show();
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
  
//  $mform.find('div.line').hide();
  
  $mform.stop().animate({width: "1px" }, 500, function() {
    
    
//    $mform.find('div.line').hide();
    $mform.hide(); $mcontent.show();
    
    $mcontent.stop().animate({width: "100%" }, 300, function() {
      $mcontent.stop();
    });
  });
}


//SAVE ACTION
$(function () {
  $('#submit').click(function() {
    console.log("SUBMIT FORM")
    $("#mcontent").find('form').submit();
//    shrink();
//    initSliders("orange")
  });
});
