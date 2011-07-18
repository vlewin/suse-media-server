<script>
      function setupLabel() {
      if ($('.label_check input').length) {
      $('.label_check').each(function(){
      $(this).removeClass('c_on');
      });
      $('.label_check input:checked').each(function(){
      $(this).parent('label').addClass('c_on');
      });
      };
      if ($('.label_radio input').length) {
      $('.label_radio').each(function(){
      $(this).removeClass('r_on');
      });
      $('.label_radio input:checked').each(function(){
      $(this).parent('label').addClass('r_on');
      });
      };
      };
      $(document).ready(function(){
      $('body').addClass('has-js');
      $('.label_check, .label_radio').click(function(){
      setupLabel();
      });
      setupLabel();
      });
    </script> 

    <script type="text/javascript" charset="utf-8">
      /*function setEqualHeight(columns) {  
        var tallestcolumn = 0;  
        columns.each(function() {  
         currentHeight = $(this).height();  
         if(currentHeight > tallestcolumn) {  
           tallestcolumn  = currentHeight;  
         }  
        });  
        columns.height(tallestcolumn);  
      }  
      $(document).ready(function() {  
       setEqualHeight($(".container  > div"));  
      }); */
      
      
      $(document).ready(function() { 
       
        console.log("ready")
        var $hosts = $('#form2');
        var $checkboxes = $('.checkbox');
        var $actionbar = $('#actionbar');
      
        var $add = $('#add');  
        var $edit = $('#edit');
        var $del = $("#del");
            
        var $submit = $("#submit");
        var $cancel = $("#cancel");

        
        $add.live('click', function() {
          $submit.text('Save').show();
          $cancel.show();
          
          $add.hide();
          $del.hide();
        });
        
        $edit.live('click', function() {
          var $fields = $('#text_fields');
          $fields.show();
          $edit.hide();
          $add.hide();
          $del.hide();
          $submit.text('Update').show();
          $cancel.show();
        });
        
        $('.host_link').live('click', function() {
          $edit.show();
          $cancel.show();
          $add.hide();
          $del.hide();
          $('div.host').hide();
          $actionbar.show();
          $(this).parent().show();
          
        });
        
        $('#submit').live('click', function() {
          var $fields = $('#text_fields');
          $fields.hide();
          $actionbar.show();

          if($(this).text() == "Update") {
            $('#form').submit();
            $('#flash').slideDown().delay(500);
            
            setTimeout(function() { $('#flash').effect("highlight", {color:'#fff'}, 200)}, 100);
            $('#counter').text(parseInt($('#counter').text()) + 1);
            $('#flash_message').html("<b style='color:#474747'>Host succsessfully updated!</b>");
            $('#action_messages').append('<div class="last"><label style="min-width:120px; display:inline-block;">Host update:</label><label style="min-width:140px; display:inline-block; font-weight:bold; color:green"> Host succsessfully updated!</label></div>');
            setTimeout(function() { $('#flash').delay(1000).slideUp()}, 2000);

          } else if ($(this).text() == "Delete") {
            $("#form2").submit();
            
            $('#flash').slideDown().delay(500);
            
            setTimeout(function() { $('#counter').effect("highlight", {color:'#FF8C00'}, 500)}, 500);
            $('#counter').text(parseInt($('#counter').text()) + 1);
            $('#flash_message').html("<b style='color:#474747'>Host succsessfully removed!</b>");
            $('#action_messages').append('<div class="last"><label style="min-width:120px; display:inline-block;">Host delete:</label><label style="min-width:140px; display:inline-block; font-weight:bold; color:green"> Host succsessfully removed!</label></div>');
            setTimeout(function() { $('#flash').delay(1000).slideUp()}, 2000);
          } else {
          
            $("#form3").submit();
            
            $('#flash').slideDown().delay(500);
            setTimeout(function() { $('#counter').effect("highlight", {color:'#FF8C00'}, 500)}, 500);
            $('#counter').text(parseInt($('#counter').text()) + 1);
            $('#flash_message').html("<b style='color:#474747'>Host succsessfully added!</b>");
            $('#action_messages').append('<div class="last"><label style="min-width:120px; display:inline-block;">Host create:</label><label style="min-width:140px; display:inline-block; font-weight:bold; color:green"> Host succsessfully added!</label></div>');
            setTimeout(function() { $('#flash').delay(1000).slideUp()}, 2000);
            
          }
          $('.checkbox').hide();
          $('div.host').show();
          
          $submit.hide();
          $cancel.hide();
          $add.show();
          $del.show();
          
          $('#form_container').html('<label class="h2 grey">Host details</label><br><label class="h4 grey">Click on host name for more details</label>');
         });
        
        $('#cancel').live('click', function() {
          var $fields = $('#text_fields');
          $fields.hide();
          
          $edit.hide();
          $submit.hide();
          $cancel.hide();
          $add.show();
          $del.show();
          
          $hosts.find('input[type="checkbox"]').hide();
          $('.checkbox').hide();
          $('div.host').show();
          
          $('#form_container').html('<label class="h2 grey">Host details</label><br><label class="h4 grey">Click on host name for more details</label>');
        });
        
        $('#del').live('click', function() {
          $('.checkbox').show();
          $add.hide();
          $del.hide();
          
          $submit.text("Delete").show();
          $cancel.show();
          
          $('#form_container').html('<label class="h2 grey">Host details</label><br><label class="h4 grey">Click on host name for more details</label>');
        });
        
        
        $('#slider').click(function(event){
          $('#slider').effect("highlight", {color:"#fff"}, 500);
          //setTimeout(function() { $('#flash').slideToggle()}, 200)
          if($('#messages').hasClass('visible')) {
            $('#details').show();
            $('#messages').removeClass('visible');
            $('#messages').slideUp();
            //$('#flash').delay(1000).slideUp();
          } else {
            $('#flash').slideToggle();            
          }
        });
        
        $('#details').click(function(event){
          $(this).hide();
          $('#flash').hide();
          $('#messages').addClass('visible').slideToggle()
        });
        
        
                  
      });
