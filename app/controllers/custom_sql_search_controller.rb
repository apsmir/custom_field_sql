class CustomSqlSearchController < ApplicationController

  unloadable

  #  before_action :find_project, :authorize
  before_action :find_custom_field

  def with_another_db(another_db_config)
    original_connection = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(another_db_config)
    yield
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
  end

  def search
    issue_id = params['issue_id']
    if issue_id.nil? || issue_id.empty?
      sql = @custom_field.sql.to_s.gsub('%id%', 'null')
    else
      sql = @custom_field.sql.to_s.gsub('%id%', issue_id)
    end
    sql_bind  = [sql]
    p = Hash[@custom_field.form_params.each_line.map {|str| str.split("=")}]
    p.each { |k,v| sql_bind.push(params[k])}

    if @custom_field.db_config.nil?
      @dataset  = CustomField.find_by_sql(sql_bind)
    else
      with_another_db(ActiveRecord::Base.configurations['mssqldb']) do
        # ActiveRecord::Base.connection.execute("SELECT 'Look ma, I have changed DB!';")
        @dataset  = CustomField.find_by_sql(sql_bind)
      end
    end

    render :layout => false
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_custom_field
    @custom_field = CustomField.find(params[:custom_field_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  end
