Redmine::Plugin.register :custom_field_sql do
  name 'Redmine SQL Custom Field Label plugin'
  author 'Alexey Smirnov'
  description 'This is a plugin for Redmine which adds SQL type to Custom Fields'
  version '1.0'
  url 'https://github.com'
  author_url 'https://github.com'

end

require_dependency 'custom_field_sql/custom_fields/formats/sql'

CustomField.safe_attributes(
  'sql'
)

