Redmine::Plugin.register :custom_field_sql do
  require 'custom_field_sql/custom_fields/formats/sql'
  require 'custom_sql_search_hook'
  name 'Redmine SQL Custom Field Label plugin'
  author 'Alexey Smirnov'
  description 'This is a plugin for Redmine which adds SQL type to Custom Fields'
  version '2.7'
  url 'https://github.com/apsmir/custom_field_sql'

end

CustomField.safe_attributes(
  'sql',
  'form_params',
  'search_by_click',
  'db_config',
  'strict_selection',
  'strict_error_message',
  'default_value'
)
