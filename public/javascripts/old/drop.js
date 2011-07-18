jQuery(function($){
    $('span.drag').drag("start",function(ev, dd){
//      console.log('DRAG START')
      $( dd.available ).addClass('available');
      return $(this).clone().addClass('active').appendTo( document.body);
//      return $( this ).clone().addClass('drag-active').appendTo( document.body);
    })

  $('span.drag').drag(function( ev, dd ){
      $( dd.proxy ).css({
        top: dd.offsetY,
        left: dd.offsetX
      });
    })

   $('span.drag').drag("end",function( ev, dd ){
      $( dd.available ).removeClass('drop-available');
      
      if($(dd.drop).hasClass('drop')) {
        $(dd.proxy).css('color', '#626466').removeClass('drag-active').removeClass('drag');
      } else {
        $( dd.proxy ).remove();
      }
    });

  $('.drop')
    .live("drop",function( ev, dd ){
       $(ev.target).removeClass('drag').removeClass('active'); //user
       $(this).append(ev.target).effect("highlight", {color:'#AEE6A8'}, 400);
    })
});
