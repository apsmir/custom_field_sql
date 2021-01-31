module CustomFieldSql
  module CustomFields
    module Formats

      class Sql < Redmine::FieldFormat::List
        add 'sql'
        field_attributes :sql
        self.form_partial = 'custom_fields/formats/sql'

        def possible_values_options(custom_field, object = nil)
          sql = custom_field.sql
          if object
            if object.id.nil?
              sql = sql.gsub('%id%', 'null')
            else
              sql = sql.gsub('%id%', object.id.to_s)
            end
          end
          result = ActiveRecord::Base.connection.select_all(sql)
          result.rows
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
