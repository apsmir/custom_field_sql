function observeSqlField(fieldId, url, form_params, options) {
    $(document).ready(function() {
        $('#'+fieldId).autocomplete($.extend({
            create: function( event, ui ) {
                this.store = [];
                this.store.push(this.value);
                let input = $(this, 'input');
                input.tooltip({
                    classes: {
                        "ui-tooltip": "ui-state-highlight"
                    }
                });
            },
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
                for(let key in form_params){
                    url_obj.data[key]=eval(form_params[key]);
                }
                $.ajax(url_obj);
            },
            minLength: 2,
            position: {collision: "flipfit"},
            search: function(){$('#'+fieldId).addClass('ajax-loading');},
            response: function(){$('#'+fieldId).removeClass('ajax-loading');},
            change: function( event, ui ) {
                if (options.strict_selection=='0' ) {
                    return;
                }
                var input = $(this, 'input');
                var value = input.val();
                if ( this.store.includes(value) ) {
                    return;
                }
                input.val( "" );
                input.attr( "title", value  + " \n " + options.strict_error_message);
                input.tooltip( "open" );
                setTimeout(() => {
                    input.tooltip( "close" ).attr( "title", "" );
                }, 2500)
            },
            select: function( event, ui ) {
                if (!this.store.includes(ui.item.value))
                    this.store.push(ui.item.value);
            }
        }, options));
        $('#'+fieldId).addClass('autocomplete');
        $('#' + fieldId).keypress(function (e) {
            if (e.keyCode == 13) return false;
        });
        if (options.search_by_click=='1') {
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
