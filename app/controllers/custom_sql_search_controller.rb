class CustomSqlSearchController < ApplicationController

  unloadable

  #  before_action :find_project, :authorize
  before_action :find_custom_field

  def sqlserver_search(db_config, sql)
    c = ActiveRecord::Base.configurations[db_config]
    client = TinyTds::Client.new username: c['username'], password: c['password'], host: c['host'],  port: c['port'],  timeout: 60000, database: c['database']
    Rails.logger.info('TinyTds  sql ' + sql.to_s)
    result = client.execute(sql)
    dataset = []
    result.each do |row|
      dataset << row
    end
    dataset
  end

  def  with_another_database(config, sql)
    c = ActiveRecord::Base.configurations[config]
    if c['adapter'] == 'sqlserver'
      sqlserver_search(config, sql)
    else
      []
    end
  end

  def with_another_db(another_db_config)
    original_connection = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(another_db_config)
    yield
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
  end

  def search
    params['issue_id'] = 'null' if params['issue_id'].nil? || params['issue_id'].empty?
    params['project_id'] = 'null' if params['project_id'].nil? || params['project_id'].empty?
    #sql_bind  = [sql]
    #p = Hash[@custom_field.form_params.each_line.map {|str| str.split("=")}]
    #p.each { |k,v| sql_bind.push(params[k])}

    sql = @custom_field.sql % params

    if @custom_field.db_config.blank?
      @dataset  = CustomField.find_by_sql(sql)
    else
      @dataset = with_another_database(@custom_field.db_config, sql)
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
