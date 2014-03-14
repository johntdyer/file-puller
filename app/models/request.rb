class Request < ActiveRecord::Base
  validates_datetime :start_time
  validates_datetime :end_time

  mount_uploader :log, LogUploader

  after_commit :background, :on => :create


  def background
    end_time = self.end_time.to_s
    start_time = self.start_time.to_s
    r = {
      email:      self.email,
      start_time: DateTime.parse(start_time).getutc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
      end_time:   DateTime.parse(end_time).getutc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
      query:      self.query,
      metadata:   self.metadata,
      id:         self.id
    }

    Rails.logger.debug "===> #{r}"
    LogFetcher.perform_async(r)
  end
end
