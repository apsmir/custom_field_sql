Redmine::Plugin.register :custom_field_sql do
  name 'Redmine SQL Custom Field Label plugin'
  author 'Alexey Smirnov'
  description 'This is a plugin for Redmine which adds SQL type to Custom Fields'
  version '2.8'
  url 'https://github.com/apsmir/custom_field_sql'
end

require_dependency File.dirname(__FILE__) + '/lib/custom_sql_search_hook'
require_dependency File.dirname(__FILE__) + '/lib/custom_field_sql/custom_fields/formats/sql'

CustomField.safe_attributes(
  'sql',
  'form_params',
  'search_by_click',
  'db_config',
  'strict_selection',
  'strict_error_message',
  'default_value'
)
