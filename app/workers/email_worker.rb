class EmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 50
  sidekiq_options :queue => :email

  sidekiq_retry_in do |count|
    15 * (count + 1)
  end

  def perform(emails, dest, acc, async = false, check = true)
    EmailSender.new.send_thread(emails, dest, acc, async, check)
    sleep(900 + Random.rand(30))
  end
end
