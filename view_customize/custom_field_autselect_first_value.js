/*
Path pattern: /issues/
Type: JavaScript
Parameter: customField - id custom field
*/
$(function() {
  ids = [22,23]
  ids.forEach((customField) => {
   var target = $('#issue_custom_field_values_'+customField);
   if ((target.length) && (!target.val())) {
     var s = target.find('option[value!=""]');
     if (s)
      s.first().prop('selected', true);
   }
  })
})