class LogFetcher
  include Sidekiq::Worker
  require 'es-query'
  require 'dotenv'
  require 'pony'

  sidekiq_options :retry => false

  Dotenv.load("#{Rails.root}/.env")

  def perform(params={})
    params.merge!('file_name' => params[:metadata].nil? ? "#{jid}.log" : "#{jid}-#{params[:metadata]}.log")
    logger.info "JID #{jid} - TID #{Thread.current.object_id.to_s(36)} - Querying #{params['query']} and writing results to #{params['file_name']}"
    results = nil
    begin
      results = perform_query params
    rescue Exception => e
      logger.error "Error performing query -> #{e}"
    end

    begin

      request = update_active_record params,results

      url = "http://#{ENV['DOMAIN']}/requests/#{request.id}/download"

      logger.info "JID #{jid} - TID #{Thread.current.object_id.to_s(36)} - Query finished, found #{results.num_results} results.  Result can be found here #{url}"
      send_notification params['email'], "Log request #{jid} finished. - found #{results.num_results}} results.","Query finished, found #{results.num_results}} results.  Result can be found here #{url}"

    rescue Exception => e
      logger.error "Something bad happened -> #{e}"
    end

  end

  private

  def update_active_record(params,results)
    request = Request.find(params['id'])
    logger.info "Request.find(params['id']) => #{request.inspect}"

    request.update({
                     log: File.open("#{Rails.root}/public/requests/#{params['file_name']}"),
                     jid: jid,
                     results: results.num_results
    })

    if request.save
      logger.info "Updated record"
      return request
    else
      logger.error "Failed to update record"
      raise "Failed to update record"

    end

  end


  def perform_query(params={})
    logger.info "#{jid} - Query Starting"

    es_conf = {
      query: params['query'],
      start_date: params['start_time'],
      end_date: params['end_time'],
      output_file: "public/requests/#{params['file_name']}",
      index_prefixes: [ "logstash-", "logstash-cdr-", "logstash-haproxy-" ]
    }

    es_conn = Esquery.new(es_conf)

    loop do
      logger.debug "#{jid} - Query running"
      sleep 2
      break if es_conn.query_finished
    end

    logger.info "#{jid} - Query finished"
    es_conn
  end

  def send_notification(to,subject,body)

    Pony.mail(
      body:      body,
      to:        to,
      from:      'donotreply@tropo.com',
      headers:   { "x-tropo-type" =>"log request" },
      subject:   subject,
      html_body: body,
      via: :smtp,
      via_options: {
        address:              ENV['GMAIL_SERVER'],
        port:                 ENV['GMAIL_PORT'],
        enable_starttls_auto: true,
        user_name:            ENV['GMAIL_USERNAME'],
        password:             ENV['GMAIL_PASSWORD'],
        authentication:       :plain,
        domain:               "localhost.localdomain"
      }
    )
  end
end
