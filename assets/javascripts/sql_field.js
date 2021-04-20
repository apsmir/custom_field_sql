function observeSqlField(fieldId, url, form_params, search_by_click, options) {
    $(document).ready(function() {
        $('#'+fieldId).autocomplete($.extend({
            source: function(request, response) {
                var url_obj = {
                    url: url,
                    dataType: "json",
                    data: {
                        term: request.term
                    },
                    success: function(data) {
                        response(data);
                    }
                }
                for(var key in form_params){
                    url_obj.data[key]=eval(obj[key]);
                }
                $.ajax(url_obj);
            },
            minLength: 2,
            position: {collision: "flipfit"},
            search: function(){$('#'+fieldId).addClass('ajax-loading');},
            response: function(){$('#'+fieldId).removeClass('ajax-loading');}
        }, options));
        $('#'+fieldId).addClass('autocomplete');
        if (search_by_click) {
            $('#' + fieldId).click(function () {
                $(this).autocomplete('search', 'data')
            });
            $('#' + fieldId).keydown(function(e) {
                if (e.altKey && e.keyCode == 40)
                    $(this).autocomplete('search', 'data')
            });

        }
    });
}
