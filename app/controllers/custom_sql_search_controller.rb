class CustomSqlSearchController < ApplicationController
  # before_action :find_project, :authorize
  before_action :find_custom_field

  def sqlserver_search(c, sql)
    begin
      client = TinyTds::Client.new(username: c[:username], password: c[:password], host: c[:host], port: c[:port], timeout: 60000, database: c[:database])
      Rails.logger.info('TinyTds sql ' + sql.to_s)
      result = client.execute(sql)
      dataset = []
      result.each { |row| dataset << row }
      dataset
    rescue => e
      Rails.logger.error('TinyTds error ' + e.message)
      []
    end
  end

  def with_another_database(config, sql)
    c = ActiveRecord::Base.configurations.configs_for(env_name: config).first
    if c.adapter == 'sqlserver'
      sqlserver_search(c.configuration_hash, sql)
    else
      []
    end
  end

  def search
    params['issue_id'] ||= 'null'
    params['project_id'] ||= 'null'

    sql = @custom_field.sql % params.as_json.transform_keys(&:to_sym)

    @dataset = if @custom_field.db_config.blank?
                 ActiveRecord::Base.connection.select_all(sql)
               else
                 with_another_database(@custom_field.db_config, sql)
               end

    render json: @dataset.map { |record| {
      'value' => record['value'],
      'label' => "#{record['value'].to_s.truncate(60)} (#{record['label'].to_s.truncate(60)})"
    } }
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
