module CustomFieldSql
  module CustomFields
    module Formats

      class SqlSearch < Redmine::FieldFormat::LinkFormat
        add 'sql_search'
        field_attributes :sql, :form_params, :search_by_click, :db_config, :strict_selection, :strict_error_message, :multi_select
        self.form_partial = 'custom_fields/formats/sql'

        def select_default_value(custom_field, object = nil)
          return if custom_field.default_value.blank?
          params = {}
          if object && object.is_a?(Issue)
            params[:tracker_id] = object.tracker_id
            params[:project_id] = object.project_id
          end
          ActiveRecord::Base.connection.select_value(custom_field.default_value % params)
        end

        def formatted_value(view, custom_field, value, customized=nil, html=false)
          return '' if value.blank?
          if custom_field.multi_select.to_s == '1'
            begin
              JSON.parse(value).join(', ')
            rescue JSON::ParserError
              value
            end
          else
            value
          end
        end

        def multi_select?
          custom_field && custom_field.multi_select.to_s == '1'
        end
      end

      class Sql < Redmine::FieldFormat::List
        add 'sql'
        field_attributes :sql
        self.form_partial = 'custom_fields/formats/sql'

        def possible_values_options(custom_field, object = nil)
          sql = custom_field.sql
          if sql
            if object
              return [] unless (object.class.to_s + 'CustomField')==custom_field.class.to_s
              if object.id.nil?
                sql = sql.gsub('%id%', 'null')
              else
                sql = sql.gsub('%id%', object.id.to_s)
              end
            end
            result = ActiveRecord::Base.connection.select_all(sql)
            result.rows
          else
            []
          end
        end

        def group_statement(custom_field)
          order_statement(custom_field)
        end

        def validate_custom_field(custom_field)
          errors = []
          #errors << [:language, :blank] if custom_field.language.blank?
          errors
        end
      end

    end
  end
end
