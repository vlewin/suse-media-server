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
//              html += '<a href="#" class="share" data-path ="' + path +'">select</a>'
              html += '<a href="#" class="share" data-name="' + dir + '" data-path ="' + path +'">select</a>'
              html += '</li>';
            } else {
              html += '<li class="dir">';
              html += '<label>' + dir + '</label>';
              html += '<a href="#" class="share" data-name="' + dir + '" data-path ="' + path +'">select</a>'
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
    
    bind : function(target) {
      //PARENT CLICKED
      $('li.parent').live('click', function() {
        methods.ajax($(this).attr('data-child'));
      });

      //SHARE CLICKED          
      $('a.share').live('click', function() {
        var $selects = $("#new-container").find('a.select');
      
        var name = $(this).attr('data-name').toUpperCase();
        var value = $(this).attr('data-path');
      
        var $parent, $name, $path;
        
        $selects.each(function() {
          if($(this).hasClass('activeSelector')) {
            $parent = $(this).parent().parent();
            $name = $parent.find('span.name');
            
            if($parent.attr('id') == "custom-dir") {
              $name.html(name);
              $name.after('<input type="hidden" name="share[name]" id="share_name" value="' + name + '">');
            } else {
              $name.after('<input type="hidden" name="share[name]" id="share_name" value="' + $parent.attr('id') + '">');
            }
            
              
            
            $path = $parent.find('span.path');
            $path.html(value);
            $path.after('<input type="hidden" name="share[path]" id="share_path" value="' + value + '">');
          }
        });
        
        console.log("TODO: Do not forget to remove activeSelector class");
        
//        $('#browser').val($(this).attr('data-path'));
        methods.hide();
        return false;
      });
          
      //BACK
      $('a#back').live('click', function() {
        var back = $(this).attr('data-back');
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
    },
    

    show : function(html) {
      $('#modalshade').show();
      console.log("Show dialog")
      console.log($('#directories'))
      $('#directories').html(html);
      $('#dir-chooser').show();
    },
    
    hide : function( ) { 
      $('#modalshade').hide();
      $('#dir-chooser').hide();
    }
  };

  $.fn.dirchooser = function(options){
    
    var defaults = {
      parent: "/"
    }
    
    var opt = $.extend(defaults, options);
    var $this = $(this);
    
    
        
          
    return $(function() {
      console.log($this)
      console.log("INIT")
      //$this.after('<a class="select" href="#">select</a>')
      $this.html('<div id="controls"></div><div id="directories"></div>');
      
      $('a.select').live('click', function() {
        $(this).addClass('activeSelector');
        methods.ajax(opt.parent);
      });
      
      methods.bind();

      
      /*$('a.select').bind({
        click: function(evt){
          methods.ajax(opt.parent);
        }
      });*/
      
      
                
     


    });
  };
})(jQuery);

