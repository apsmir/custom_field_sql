/*
Path pattern: /issues/
Type: JavaScript
Parameter: customField - id custom field
*/
$(function() {
  var customField = 22;
  var target = $('#issue_custom_field_values_'+customField);
  if (target) {
    var s = target.find('option[value!=""]');
    if (s)
     s.first().prop('selected', true);
  }
 }
)