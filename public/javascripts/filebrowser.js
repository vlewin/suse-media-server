(function($){

  var methods = {
    init : function(data, parent) {

      var html = '<ul id="dirs" class="dirs child" data-parent ="' + parent + '">';
      
//      for(var i=0; i< data.length; i++) {
      for (dir in data) {
        console.log('DIRECTORY ' + dir)
        
        for (key in data[dir]) {
        
          if(key == "path") {
            console.log('PATH ' + key + ' ' + data[dir][key])
            html += '<li class="dir parent" data-parent ="' + key +'">' + dir + '</li>';
          }
          
          if(key == "children") {
            console.log('CHILDREN ' + key + ' ' + data[dir][key])
            html += '<li class="dir parent" data-parent ="' + key +'">' + dir + '</li>';
          }
          
        }
        
      }
      
       html += '</ul>';
       $('#directories').html(html).show();
      
//      var html = '<ul id="dirs" class="dirs child" data-parent ="' + parent + '">';

//      console.log(dirs.length);

//      for(var i=0; i< dirs.length; i++) {
//        var obj = dirs[i]
//        
//        if(typeof(dirs[i]) == "object") {
//          
//          for (key in obj) {
//            html += '<li class="dir parent" data-parent ="' + obj[key] +'">' + key + '</li>';
//          }
//        } else {

//          html += '<li class="dir">'; 
//          html += obj;
//          html += '<a href="#" class="share" data-path ="' + parent + obj + '">share this directory</a>';
//          html += '</li>';
//        }

//        html += '</ul>';
//        $('#directories').html(html).show();

//      }

    },
    
//    ONLY WORKS WITH --> get_dirs(dir)
//    init : function(data, parent) {

//      var dirs = data.dirs;
//      var html = '<ul id="dirs" class="dirs child" data-parent ="' + parent + '">';

//      console.log(dirs.length);

//      for(var i=0; i< dirs.length; i++) {
//        var obj = dirs[i]
//        
//        if(typeof(dirs[i]) == "object") {
//          
//          for (key in obj) {
//            html += '<li class="dir parent" data-parent ="' + obj[key] +'">' + key + '</li>';
//          }
//        } else {

//          html += '<li class="dir">'; 
//          html += obj;
//          html += '<a href="#" class="share" data-path ="' + parent + obj + '">share this directory</a>';
//          html += '</li>';
//        }

//        html += '</ul>';
//        $('#directories').html(html).show();

//      }

//    },

    ajax : function(dir) {
      console.log("AJAX " + dir);
      $.ajax({
        type        : "POST",
        url         : "/browser/get",
        data        : '{"dir":"' + dir + '"}',
        contentType : "application/json; charset=utf-8",
        dataType    : "json",
        success     : function( result ) {
          console.log(result);
          return methods.init(result, dir);
        }
      });
    },

    show : function( ) {
      $('#directories').show();
    },
    hide : function( ) { },
  };

  $.fn.directory = function(options){
    var opt = $.extend({
      parent: "/suse/vlewin/",
      height: "50px"
    }, options);

    var $this = $(this);

    return $this.each(function() {
      $this.css('height', opt.height);

      $(this).bind({
        click: function(evt){
          var result = methods.ajax(opt.parent);

          $('li.dir').live('click', function() {
            methods.ajax($('#dirs').attr('data-parent') + '/' + $(this).text());
          });
          
          $('a.share').live('click', function() {
            console.log($(this).attr('data-path'))
            $('#browser').val($(this).attr('data-path'));
            return false;
          });
        }

      });

    });
  };
})(jQuery);

