(function($){

  var methods = {
    init : function(data, parent) {
      console.log(parent)

      var html = '<ul id="dirs" class="dirs child" data-parent ="' + parent + '">';
      var path = '';
      
      for (dir in data) {
        for (key in data[dir]) {
          
          if(key == "path") { path = data[dir][key]; } else {
          
            if(key == "children" && data[dir][key] == "yes") {
              html += '<li class="dir parent" data-child ="' + path +'">';
              html += '<label>' + dir + '</label>';
              html += '<a href="#" class="share" data-path ="' + path +'">select</a>'
              html += '</li>';
            } else {
              html += '<li class="dir">';
              html += '<label>' + dir + '</label>';
              html += '<a href="#" class="share" data-path ="' + path +'">select</a>'
              html += '</li>';
            }
          }
        }
      }
      
       html += '</ul>';
       
       $('#controls').html('<a id="back" href="#" data-back="' + parent +'"> back</a>' + parent + '<a id="close" href="#">close</a><div class="clear"></div>')
       methods.show(html);
    },
    
    ajax : function(dir) {
      console.log("AJAX " + dir);
      $.ajax({
        type        : "POST",
        url         : "/browser/get",
        data        : '{"dir":"' + dir + '"}',
        contentType : "application/json; charset=utf-8",
        dataType    : "json",
        success     : function( result ) {
          methods.init(result, dir);
        }
      });
    },

    show : function(html) {
      $('#modalshade').show();
      $('#directories').html(html);
      $('#dirwrap').show();
    },
    
    hide : function( ) { 
      $('#modalshade').hide();
      $('#dirwrap').hide();
    }
  };

  $.fn.directory = function(options){
    var opt = $.extend({
      parent: "/suse/vlewin/",
    }, options);

    var $this = $(this);

    return $this.each(function() {
      $this.after('<a id="select" href="#">select</a>')

      $('#select').bind({
        click: function(evt){
          var result = methods.ajax(opt.parent);

          $('li.parent').live('click', function() {
            methods.ajax($(this).attr('data-child'));
          });
          
          $('a.share').live('click', function() {
            $('#browser').val($(this).attr('data-path'));
            methods.hide();
            return false;
          });
          
          $('a#back').live('click', function() {
            var back = $(this).attr('data-back');
            
            console.log( back + ' p ' + opt.parent )
            
            
            //TODO: FIX if parent == back don't fire AJAX call
            
            if(back != opt.parent) {
              var tmp = back.split('/');
              back = tmp.splice(0, (tmp.length-1)).join('/');  
              methods.ajax(back);
            } else {
              console.log("HOME")
            }
            return false;
          });
          
          $('a#close').live('click', function() {
            methods.hide();
            return false;
          });
        }

      });

    });
  };
})(jQuery);

