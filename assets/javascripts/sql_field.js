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
                    error: function(request, status, error){
                        $('#'+fieldId).removeClass('ajax-loading');
                        console.log(request.responseText)
                        console.log(error)
                    },
                    success: function(data) { response(data); }
                }
                for(let key in form_params){
                    url_obj.data[key]=eval(form_params[key]);
                }
                $.ajax(url_obj);
            },
            minLength: 2,
            position: {collision: "flipfit"},
            search: function(){ $('#'+fieldId).addClass('ajax-loading'); },
            response: function(){ $('#'+fieldId).removeClass('ajax-loading'); },
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

function observeSqlMultiField(fieldId, url, form_params, options) {
    $(document).ready(function() {
        var $originalField = $('#' + fieldId);
        var selectedValues = options.selected_values || [];
        var tagsContainerId = fieldId + '_tags';

        // Парсим текущее значение поля как JSON
        var currentVal = $originalField.val();
        if (currentVal && currentVal.trim() !== '') {
            try {
                selectedValues = JSON.parse(currentVal);
            } catch(e) {
                selectedValues = [currentVal];
            }
        }

        // Создаём кнопку добавления (зелёный плюс)
        var addBtnId = fieldId + '_add_btn';
        var $addBtn = $('<span>', {
            id: addBtnId,
            class: 'icon icon-add sql-multi-add-btn',
            title: 'Добавить значение',
            style: 'display: none;'
        });

        // Оборачиваем поле + кнопку в flex-контейнер
        var $wrapper = $('<div>', { class: 'sql-multi-wrapper' });
        $originalField.wrap($wrapper);
        $wrapper = $originalField.parent();
        $wrapper.append($addBtn);

        // Контейнер тегов — после wrapper
        var $tagsContainer = $('<div>', {
            id: tagsContainerId,
            class: 'sql-multi-tags-container'
        });
        $wrapper.after($tagsContainer);

        // Функция рендера тегов
        function renderTags() {
            $tagsContainer.empty();
            selectedValues.forEach(function(value) {
                var $tag = $('<span>', { class: 'sql-multi-tag' });
                $tag.append(
                    $('<span>', { class: 'sql-multi-tag-text', text: value }),
                    $('<span>', {
                        class: 'sql-multi-tag-remove',
                        html: '&times;',
                        click: function() {
                            selectedValues = selectedValues.filter(function(v) { return v !== value; });
                            renderTags();
                        }
                    })
                );
                $tagsContainer.append($tag);
            });
        }

        // Обновление поля (вызывается перед submit)
        function updateField() {
            $originalField.val(JSON.stringify(selectedValues));
        }

        // Рендерим начальные теги и очищаем поле (теперь это поле поиска)
        renderTags();
        $originalField.val('');

        // Инициализируем autocomplete на оригинальном поле (как в observeSqlField)
        $originalField.autocomplete({
            source: function(request, response) {
                var term = request.term;
                var url_obj = {
                    url: url,
                    dataType: "json",
                    data: { term: term },
                    error: function(req, status, error) {
                        console.log(req.responseText);
                        console.log(error);
                    },
                    success: function(data) {
                        // Фильтруем уже выбранные значения
                        var filtered = data.filter(function(item) {
                            return selectedValues.indexOf(item.value) === -1;
                        });
                        response(filtered);
                        // Если strict_selection=0 и нет результатов — показываем кнопку добавления
                        if (options.strict_selection == '0' && filtered.length === 0 && term.length > 0) {
                            $addBtn.css('display', 'inline-block');
                        } else {
                            $addBtn.hide();
                        }
                    }
                };
                for (var key in form_params) {
                    if (form_params.hasOwnProperty(key)) {
                        url_obj.data[key] = eval(form_params[key]);
                    }
                }
                $.ajax(url_obj);
            },
            minLength: 2,
            position: { collision: "flipfit" },
            select: function(event, ui) {
                var value = ui.item.value;
                if (selectedValues.indexOf(value) === -1) {
                    selectedValues.push(value);
                    renderTags();
                }
                $originalField.val('');
                $addBtn.hide();
                return false;
            }
        });

        $originalField.addClass('autocomplete');

        // Кнопка добавления (зелёный плюс)
        $addBtn.click(function() {
            var value = $originalField.val().trim();
            if (value && selectedValues.indexOf(value) === -1) {
                selectedValues.push(value);
                renderTags();
            }
            $originalField.val('');
            $addBtn.hide();
        });

        // Скрываем кнопку добавления при пустом поле
        $originalField.on('input', function() {
            if ($(this).val().trim() === '') {
                $addBtn.hide();
            }
        });

        // Предотвращаем submit по Enter
        $originalField.keypress(function(e) {
            if (e.keyCode == 13) {
                e.preventDefault();
                if ($addBtn.is(':visible')) {
                    $addBtn.click();
                }
                return false;
            }
        });

        // При клике на поле, если search_by_click — показать все результаты
        if (options.search_by_click == '1') {
            $originalField.click(function() {
                $(this).autocomplete('search', '');
            });
        }

        // Перехватываем submit формы — записываем JSON в поле
        var $form = $originalField.closest('form');
        if ($form.length) {
            var formEl = $form[0];
            var origSubmit = HTMLFormElement.prototype.submit;
            formEl.submit = function() {
                updateField();
                return origSubmit.call(formEl);
            };
            $form.on('submit', function() {
                updateField();
            });
        }
    });
}
