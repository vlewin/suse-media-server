(function($){

  var methods = {
    init : function( options ) {

      var json = jQuery.parseJSON(options);
      console.log( "*** RESTURNS ***" );
      console.log(options.parent)
      console.log( options.date );
      console.log( "***" );
       
      var obj = jQuery.parseJSON('{"color":["green", "red"], "date" : "2011-07-26T10:58:21+02:00"}');
      console.log( "*** TEST ***" );
      console.log( obj.color );
      console.log( obj.date );
      console.log( "***" );
      
    },
      
    ajax : function(options) {
      console.log("AJAX " + options);
      
      $.ajax({
        type        : "POST",
        url         : "/browser/get",
        data        : '{"Folder":"' + options + '"}',
        contentType : "application/json; charset=utf-8",
        dataType    : "json",
        success     : function( result ) {
          console.log(result);
//          return result;
          return methods.init(result);
        }
        
        
      });
    }, 
    
    show : function( ) {  },
    hide : function( ) { },
  };

//  $.fn.directory = function(method, options){
  $.fn.directory = function(options){
    var opt = $.extend({
      parent: "/work/",
      height: "50px"
    }, options);
 
    var $this = $(this);
    
//    $.ajax({
//        type        : "POST",
//        url         : "Webservices.asmx/GetControl",
//        data        : '{"Path":"' + path + '"}',
//        contentType : "application/json; charset=utf-8",
//        dataType    : "json",
//        success     : function( result ) {
//          obj.html( result.d );
//        }
//    });
    
    return $this.each(function() {
      $this.css('height', opt.height);
      console.log('PARENT ' + opt.parent);
      
      
      
      $(this).bind({
        click: function(evt){
          args = ['Hello', 'world'];
          arg = {ddd:  "ddd"};
//          return methods.init.apply( $this, Array.prototype.slice.call( args, 0 ));
          return methods.ajax('options');
          
          var result = methods.ajax('options');
          console.log(result)
        },

        mouseleave: function(){
          $("#tooltip").fadeOut(
            optionen.zeit,
            function(){
              $(this).remove();
            }
          );
        }
      });
      
      
    });
  };
})(jQuery);
