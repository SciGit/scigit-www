addDefault = function(input, text){
  return $(input).each(function(){
    //Make sure we're dealing with text-based form fields
    if(input.type != 'text' && input.type != 'password' && input.type != 'textarea') {
      return;
    }

    $(input).css({'color': 'gray'});

    //Store field reference
    var fld_current=input;

    //Set value initially if none are specified
    if(input.value=='') {
      input.value=text;
    } else {
      //Other value exists - ignore
      return;
    }

    //Remove values on focus
    $(input).focus(function() {
      if(input.value==text || input.value=='') {
        input.value='';
      }
      $(input).css({'color': 'black'});
    });

    //Place values back on blur
    $(input).blur(function() {
      if(input.value==text || input.value=='') {
        input.value=text;
      }
      $(input).css({'color': 'gray'});
    });

    //Capture parent form submission
    //Remove field values that are still default
    $(input).parents("form").each(function() {
      //Bind parent form submit
      $(input).submit(function() {
        if(fld_current.value==text) {
          fld_current.value='';
        }
      });
    });
  });
};
