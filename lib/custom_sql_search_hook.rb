class CustomSqlSearchHookListener < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context={})
    html = "\n<!-- [custom field sql plugin] -->\n"
    html << javascript_include_tag("sql_field.js", plugin: "custom_field_sql")
    return html
  end

  def  view_issues_form_details_bottom(context={})
    html = ""
      context[:issue].available_custom_fields.each do |field|
        if field.is_a?(IssueCustomField)
          if field.field_format == 'sql_search'
              p = Hash[field.form_params.each_line.map {|str| str.split("=")}]
              html << "<script>\n"
              html << "//<![CDATA[\n"
              html << "observeSqlField(\'issue_custom_field_values_#{field.id}\', \'#{Redmine::Utils.relative_url_root}/custom_sql_search/search?project_id=#{context[:issue].project_id}&issue_id=#{context[:issue].id}&custom_field_id=#{field.id}\', JSON.parse(#{p.to_json.dump}), #{field.search_by_click}, #{field.strict_selection})\n"
              html << "//]]>\n"
              html << "</script>\n"
          end
        end
      end
    return html
  end
end
