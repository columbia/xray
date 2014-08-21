class GmailScraper
  def scrap_account(account, iteration, to_reload = :all)
    puts "START it: #{iteration} acc: #{account.id}"
    imap = Gmail.connect!(account.login, account.passwd)
    emails = imap.inbox.all.map do |e|
      e.mark(:read)
      if to_reload.to_s == "all" || to_reload.include?(e.subject)
        [e.gmsg_id.to_s(16), e.gthread_id.to_s(16), e.subject]
      else
        nil
      end
    end.compact
    imap.logout
    api = GmailAPI.new(account).login
    emails.each do |e|
      e_id = e[0]
      t_id = e[1]
      puts "NEW EMAIL it: #{iteration} e_id: #{e_id} t_id: #{t_id} acc: #{account.id}"
      email_snapshot = EmailSnapshot.create!({ :account   => account,
                                               :iteration => iteration,
                                               :e_id      => e_id,
                                               :t_id      => t_id,
                                               :subject   => e[2], })
      ads = api.get_ads_for(e_id)
      ads.each do |ad_sn|
        puts "NEW AD it: #{iteration} e_id: #{e_id} t_id: #{t_id} acc: #{account.id}"
        ad_sn.merge!({ :account   => account,
                       :iteration => iteration,
                       :context   => email_snapshot, })
        AdSnapshot.create!(ad_sn)
        puts "END NEW AD it: #{iteration} e_id: #{e_id} t_id: #{t_id} acc: #{account.id}"
      end
      # sleep 5 + Random.rand(10)
      puts "END NEW EMAIL count:#{ads.count} it: #{iteration} e_id: #{e_id} t_id: #{t_id} acc: #{account.id}"
    end
    puts "END it: #{iteration} acc: #{account.id}"
  end

  def self.scrap_accounts(exp_name, n)
    n.times do |i|
      Mongoid.with_tenant(exp_name) do
        GoogleAccount.each { |acc| self.new.scrap_account(acc, i) }
      end
    end
  end

  def self.scrap_accounts_async(exp_name, n, queue_name = :default)
    n.times do |i|
      self.scrap_once_async(exp_name, queue_name)
    end
  end

  def self.scrap_many_exps_async(exp_names, n, queue_name = :default)
    n.times do |i|
      exp_names.each do |exp_name|
        self.scrap_once_async(exp_name, i, queue_name)
      end
    end
  end

  def self.scrap_once_async(exp_name, i, queue_name = :default)
    Mongoid.with_tenant(exp_name) do
      GoogleAccount.each do |acc|
        if queue_name == :default
          ScrapingWorker.perform_async(exp_name, acc.id.to_s, i)
        else
          Sidekiq::Client.push({
            'class' => ScrapingWorker,
            'queue' => queue_name,
            'args'  => [exp_name, acc.id.to_s, i]
          })
        end
      end
    end
  end
end
