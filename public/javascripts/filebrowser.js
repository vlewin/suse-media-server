(function($){

  var methods = {
    init : function( data ) {

      var dirs = data.dirs;
      var html = '<ul>';
      
      console.log(dirs.length);

      for(var i=0; i< dirs.length; i++) {

//        if(typeof(dirs[i]) == "object") {
//          var obj = dirs[i];
//          
//          html += '<ul>';
//          
//          for (key in obj) {
//            console.log("DIR " + key);
//            
//            html += '<li class="dir">' + key + '</li>';
//          
//            if(obj[key].length > 1) {
//              for(value in obj[key]) {
//                html += '<li class="subdir" data-subdir="' + obj[key][value] + '" >';
//                console.log(" SUBDIR " + obj[key][value])
//                html += obj[key][value];
//                html += '</li>';
//              }
//            }
//          }
//        } else {
        
          html += '<li class="dir">' + dirs[i] + '</li>';
          console.log('DIR ' + parseInt(i+1) + ': ' + dirs[i]);
        
//        }
        
        html += '</ul>';
        
   
        $('#directories').html(html).show();
        
      }  
      
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
          console.log(result);
          return methods.init(result);
        }
      });
    }, 
    
    show : function( ) {
      $('#directories').show();
    },
    hide : function( ) { },
  };

//  $.fn.directory = function(method, options){
  $.fn.directory = function(options){
    var opt = $.extend({
      parent: "/work",
      height: "50px"
    }, options);
 
    var $this = $(this);

    return $this.each(function() {
      $this.css('height', opt.height);
      
      $(this).bind({
        click: function(evt){
          args = ['Hello', 'world'];
          arg = {ddd:  "ddd"};

//          return methods.ajax(opt.parent);
          
          var result = methods.ajax(opt.parent);
          console.log(result);
          
          $('li.dir').live('click', function() {
            console.log($(this).text());
            methods.ajax($(this).text());
          });
        }
        
      });
      
      
    });
  };
})(jQuery);
