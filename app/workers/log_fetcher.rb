class LogFetcher
  include Sidekiq::Worker
  require 'es-query'
  require 'dotenv'
  require 'pony'

  sidekiq_options :retry => false

  Dotenv.load("#{Rails.root}/.env")

  def perform(params={})

    # Set some variables
    file_name = params[:metadata].nil? ? "#{jid}.log" : "#{jid}-#{params[:metadata]}.log"

    logger.info "JID #{jid} - TID #{Thread.current.object_id.to_s(36)} - Querying #{params[:query]} and writing results to #{file_name}"

    # Start Query
    begin
      es_conn = Esquery.new( params['query'], params['start_time'], params['end_time'], "public/requests/#{file_name}", {})
      es_conn.query_finished # returns boolean, true when query is complete
    rescue Exception => e
      logger.error "Something bad happened -> #{e}"
    end

    request = nil;
    begin
      request = Request.find(params['id'])
      logger.info "Request.find(params['id']) => #{request}"
      request.update(log: File.open("#{Rails.root}/public/requests/#{file_name}"),jid: jid)
      if request.save
        logger.info "Updated record"
      else
        logger.error "Failed to update record"
      end
    rescue Exception => e
      logger.error e
    end
    url = "http://localhost:3000/requests/#{request.id}/download"

    logger.info "JID #{jid} - TID #{Thread.current.object_id.to_s(36)} - Query finished, found #{es_conn.num_results} results.  Result can be found here #{url}" #{}" [#{file_name}]"
    send_notification params['email'], 'JID #{jid} - TID #{Thread.current.object_id.to_s(36)} - Query finished, found #{1} results.',"Query finished, found #{1} results.  Result can be found here #{url}" #Now writing results to disk [#{file_name}]"
  end

  private

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


require 'es-query'
jid = "testing123"
params = {
  metadata: "testing",
  start_time: "2014-03-14T00:00:00.000Z",
  end_time: "2014-03-14T04:00:00.000Z",
  query: 'tags:"sensu-status-warning"  AND NOT "ESHeap"'
}

file_name = "test.log"

es_conn = Esquery.new( params[:query], params[:start_time], params[:end_time], "public/requests/#{file_name}", {})


until es_conn.query_finished do
  print "."
end

puts "done -> #{es_conn.num_results}"
