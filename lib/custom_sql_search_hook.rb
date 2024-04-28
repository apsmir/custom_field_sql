class CustomSqlSearchHook < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context={})
    html = "\n<!-- [custom field sql plugin] -->\n"
    html << stylesheet_link_tag("sql_search", plugin: "custom_field_sql")
    html << javascript_include_tag("sql_field.js", plugin: "custom_field_sql")
    return html
  end

  def  view_issues_form_details_bottom(context={})
    html = ""
      context[:issue].available_custom_fields.each do |field|
        if field.is_a?(IssueCustomField)
          if field.field_format == 'sql_search'
              p = Hash[field.form_params.each_line.map {|str| str.split("=")}]
              options =Hash[];
              options[:search_by_click] = field.search_by_click ||= 0;
              options[:strict_selection] = field.strict_selection ||= 0;
              options[:strict_error_message] = field.strict_error_message ||= 'it is not valid value';
              html << "<script>\n"
              html << "//<![CDATA[\n"
              html << "observeSqlField(\'issue_custom_field_values_#{field.id}\', \'#{Redmine::Utils.relative_url_root}/custom_sql_search/search?project_id=#{context[:issue].project_id}&issue_id=#{context[:issue].id}&custom_field_id=#{field.id}\', JSON.parse(#{p.to_json.dump}), JSON.parse(#{options.to_json.dump}))\n"
              html << "//]]>\n"
              html << "</script>\n"
          end
        end
      end
    return html
  end
end

module CustomFieldSqlCore
  module Models
    module CustomSqlValue
      def initialize(attributes=nil, *args)
        super
        if new_record? && custom_field && (customized_type.blank? || (customized && customized.new_record?)) &&
           (custom_field.format.instance_of? CustomFieldSql::CustomFields::Formats::SqlSearch)
          self.value = custom_field.format.select_default_value(custom_field, customized)
        end
      end
    end
  end
end

CustomValue.send(:prepend, CustomFieldSqlCore::Models::CustomSqlValue)