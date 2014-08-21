class ScrapingWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :scrape_any

  def perform(exp_name, account_id, iteration, to_reload = :all)
    Mongoid.with_tenant(exp_name) do
      account = GoogleAccount.where(:_id => account_id).first
      GmailScraper.new.scrap_account(account, iteration, to_reload)
    end
  end
end
