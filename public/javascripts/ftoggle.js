//  SLIDER

(function($){
  $.fn.extend({
    toggle: function(options) {
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
        
        $obj.wrap('<span class="ftoggle_container">')
            .after($('<span id="' + o.id + '" class="ftoggle_box">'))
            .after($('<span class="ftoggle_label_right">' + o.off + '</span>'))
            .after($('<span class="ftoggle_label_left">' + o.on + '</span>'));
            
        var $parent = $obj.parent().parent();
        if($parent.hasClass('value')) {
          $parent.find('img.wait').hide();
        }

        var $parent = $obj.parent();
        var $box = $parent.css('text-align', 'left').find("span.ftoggle_box");

        $parent.hide().width(o.size).fadeIn('fast');

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

