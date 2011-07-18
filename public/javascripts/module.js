$(function () {
//  var $mcontent = $("#mcontent");
//  var $links = $mcontent.find('div.link');


//BACK CLICKED
  $('#back').click(function(){
    //    $links.removeClass('active');
    shrink();
    return false;
  })
  
  //LINK CLICKED
// $('div.link').click(function(){
  //    $links.removeClass('active');
//    expand($(this));
//  });
});

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
//  var height = $mcontent.height();
  

  var $toggles = $mform.find('div.line').find('span.ftoggle_container');
  
  console.log("EXPAND")
  

  
  $mcontent.stop().animate({width: "20%" }, 300, function() {
    $mform.css('border-left', '5px solid #eee').css('box-shadow', '-2px 0px 0px #888')
    //initSliders("orange");
//    $mform.height(height);
  
    var $toggles = $mform.find('div.line').find('span.ftoggle_container');
    console.log($toggles)
    console.log("HIDE")
    $toggles.hide();
  
    $mform.show().stop().animate({width: "76%" }, 500, function() {
      $mform.stop().delay(200).animate({ width: "72%" }, 100);
      $toggles.show();
//      $mform.find('div.line').find('span.ftoggle_container').show().delay(50);
    });
  });
}

//SHRINK DETAIL VIEW
function shrink() {
  var $mcontent = $("#mcontent");
  var $mform = $("#mform");
  var width = $mcontent.width();

  var $toggles = $mform.find('div.line').find('span.ftoggle_container');
  console.log("SHRINK")
  console.log($toggles)
  $toggles.hide();
  
//  $mform.find('div.line').hide();
  
  $mform.stop().animate({width: "1px" }, 500, function() {
    
    
//    $mform.find('div.line').hide();
    $mform.hide();
    
    $mcontent.stop().animate({width: "100%" }, 300, function() {
      $mcontent.stop();
    });
  });
}


//SAVE ACTION
$(function () {
  $('#submit').click(function() {
    console.log("CLICKED")
    $("#mform").find('form').submit();
//    shrink();
//    initSliders("orange")
  });
});
