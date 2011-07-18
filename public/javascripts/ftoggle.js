//  SLIDER
   
(function($){
  $.fn.extend({
    slider: function(options) {
      var defaults = {
        size: 120,
        background: "green",
        on: "Yes",
        off: "No",
        id: "toggle"
      }

      var options =  $.extend(defaults, options);

      return this.each(function() {
        var o = options;
        var $obj = $(this);
        
        console.log($obj)

        $obj.wrap('<span class="ftoggle_container">')
            .after($('<span id="' + o.id + '" class="ftoggle_box">'))
            .after($('<span class="ftoggle_label_right">' + o.off + '</span>'))
            .after($('<span class="ftoggle_label_left">' + o.on + '</span>'))

        var $parent = $obj.parent();
        var $box = $parent.css('text-align', 'left').find("span.ftoggle_box");
        
        $parent.width(o.size)

        if($obj.is(':checked')) {
          $parent.addClass(o.background);
          $box.css('left', (o.size/2)+'px');
        }

        $box.click(function() {
          if($obj.is(':checked')) {
            $(this).stop().animate({left: "-=" + o.size/2 }, 150, function() {
              $parent.removeClass(o.background);
              $obj.attr('checked', false);
            });
          } else {
            $(this).stop().animate({left: "+=" + o.size/2 }, 150, function() {
              $parent.addClass(o.background);
              $obj.attr('checked', true);
            });
          }
        });
      });
    }
  });
})(jQuery);


