(function($){

  var methods = {
    init : function(data, parent) {
      var html = '<ul id="dirs" class="dirs child" data-parent ="' + parent + '">';
      var path = '';

      for (dir in data) {
        for (key in data[dir]) {

          if(key == "path") { path = data[dir][key]; } else {

            if(key == "children" && data[dir][key] == "yes") {
              html += '<li class="dir parent" data-child ="' + path +'">';
              html += '<label>' + dir + '</label>';
              html += '<a href="#" class="dirlink" data-name="' + dir + '" data-path ="' + path +'">select</a>'
              html += '</li>';
            } else {
              html += '<li class="dir">';
              html += '<label>' + dir + '</label>';
              html += '<a href="#" class="dirlink" data-name="' + dir + '" data-path ="' + path +'">select</a>'
              html += '</li>';
            }
          }
        }
      }

       html += '</ul>';

       $('#controls').html('<a id="backDir" href="#" data-back="' + parent +'"> back</a>' + parent + '<a id="close" href="#">close</a><div class="clear"></div>')
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

    bind : function(root) {
      //PARENT CLICKED
      $('li.parent').live('click', function() {
        methods.ajax($(this).attr('data-child'));
      });

      //SHARE CLICKED
      $('a.dirlink').live('click', function() {
        var $selects = $("#new-container").find('a.selectDir');

        var dirname = $(this).attr('data-name').toUpperCase();
        var dirpath = $(this).attr('data-path');

        var $parent, $name, $path;

        $selects.each(function() {
          var $parent = $(this).parent().parent();
          var $sname = $parent.find('span.name');
          var $iname = $parent.find('#share_name');
          var $path = $parent.find('span.path');
          var $ipath = $parent.find('#share_path');

          if($parent.attr('id') == "custom-dir") {
            $sname.html(dirname);
            $iname.val(dirname);
          } else {
            $iname.val($parent.attr('id').toUpperCase());
          }

          $path.html(dirpath);
          $ipath.val(dirpath);
        });

        methods.hide();
        return false;
      });

      //BACK
      $('a#backDir').live('click', function() {
        var back = $(this).attr('data-back');
        if(back != parent) {
          var tmp = back.split('/');
          back = tmp.splice(0, (tmp.length-1)).join('/');
          methods.ajax(back);
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
      $('#directories').html(html);
      $('#dir-chooser').show();
    },

    hide : function( ) {
      $('#submitSelectDir').show();
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
      $this.html('<div id="controls"></div><div id="directories"></div>');

      $('a.selectDir').live('click', function() {
        methods.ajax(opt.parent);
      });

      methods.bind(opt.parent);





    });
  };
})(jQuery);

