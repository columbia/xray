class Experiment
  class AccountNumberError < RuntimeError; end
  class AccountCombinationError < RuntimeError; end

  include Mongoid::Document
  store_in database: ->{ self.database }

  field :name
  index({ name: 1 }, { :unique => true })
  field :type
  field :account_number  # uncludes +1 for the master
  field :e_perc_a  # puts each email in :e_perc_a * :account_number accounts
  field :emails  # an array of emails groupes in threads
  field :fill_up_emails, :default => []  # an array of emails sent to all accounts
  field :master_account  # string, id of the master account
  field :master_emails
  field :e_a_assignments
  field :measurements, :default => []
  field :has_master, :default => true
  field :analyzed, :default => false

  belongs_to :recurrent_exp
  index({ recurrent_exp: 1 })

  def self.current
    Experiment.where( :name => Mongoid.tenant_name ).first
  end

  # some caching for the computations
  class_attribute :exps_accs_emails_map
  def self.curr_accs_emails_map
    self.exps_accs_emails_map ||= {}
    name = self.current.name
    unless self.exps_accs_emails_map[name]
      self.exps_accs_emails_map[name] = {}
      Account.each do |a|
        emails_in = AccountEmail.where(account: a).uniq.map(&:email)
                                .select! {|em| em.cluster_targeting_id != "garbage"}
        self.exps_accs_emails_map[name] ||= []
        self.exps_accs_emails_map[name] [a.id] = emails_in
      end
    end
    return self.exps_accs_emails_map[name]
  end

  def self.duplicate_exp(name, new_name)
    exp = self.where( name: name ).first
    exp_attrs = exp.attributes
    exp_attrs['name'] = new_name
    self.create(Hash[exp_attrs])
    accs = Mongoid.with_tenant(name) do
      GoogleAccount.all.map { |a| Hash[a.attributes] }
    end
    Mongoid.with_tenant(new_name) do
      accs.each { |a| GoogleAccount.new(a).tap { |na| na.id = a['_id'] }.save }
    end
  end

  def self.email_body_from_title(exp, title)
    exp = Experiment.where(name: exp).first
    exp.emails.each do |e|
      if e.first['subject'] == title
        return e.map { |x| x["text"] }
      end
    end
    return nil
  end

  class_attribute :database
  def self.fixed_db(db_name)
    self.database = db_name.to_s
  end

  class_attribute :account_pool
  def self.accounts_from(db_name)
    self.account_pool = db_name.to_s
  end

  fixed_db :experiments
  accounts_from :google_pool

  def build_indexes
    Mongoid.create_db_indexes(self.name)
  end

  def self.build_indexes(exp_name)
    Mongoid.create_db_indexes(exp_name)
  end

  def master_account
    return nil unless has_master
    return super if super
    self.master_account = Mongoid.with_tenant(self.name) do
      GoogleAccount.first.id.to_s rescue nil
    end
  end

  def last_measurement
    self.measurements.map { |m| m["start"].to_i }.max
  end

  def all_reloads
    self.measurements.map { |m| m["reloads"] }.sum
  end

  def get_accounts
    n = Mongoid.with_tenant(self.name) { GoogleAccount.count }
    # if already enough accounts
    return if account_number <= n

    av = Mongoid.with_tenant(self.class.account_pool) do
      GoogleAccount.available_accounts.count
    end
    # if not enough accounts
    raise AccountNumberError if av < account_number - n

    accounts = Mongoid.with_tenant(self.class.account_pool) do
      GoogleAccount.available_accounts[0..account_number - n - 1]
    end
    accounts.each do |acc|
      acc = acc.attributes
      pool_id = acc.delete("_id")
      Mongoid.with_tenant(self.name) { GoogleAccount.create(acc) }
      Mongoid.with_tenant(self.class.account_pool) do
        acc = GoogleAccount.where( :id => pool_id).first
        acc.used ||= []
        acc.used.push(type)
        acc.save
      end
    end
  end

  def assign_emails
    self._assign_emails(:all)
  end

  def assign_emails_redundant_exp
    self._assign_emails([])
  end

  def _assign_emails(master_es = :all)
    self.emails ||= []
    self.e_a_assignments ||= {}

    # put everything in master
    if master_es == :all && has_master
      tmp_h = {}
      self.emails.flatten.each do |e|
        key = e['subject'].sub(/RE: /, '')
        e['subject'] = key
        (tmp_h[key] ||= []).push(e)
      end
      self.master_emails = tmp_h.values
    else
      self.master_emails = master_es
    end

    # do the random assignment
    combinations = []
    Mongoid.with_tenant(self.name) do
      nac = GoogleAccount.count
      accs = GoogleAccount.all.map(&:id).select { |i| i.to_s != self.master_account }
      self.emails.count.times do
        combinations.push(accs.sample((self.e_perc_a * nac).floor))
      end
    end
   raise AccountCombinationError if combinations.size < emails.size

    self.emails.each_with_index do |e, i|
      combinations.shift.each { |aid| (self.e_a_assignments[aid] ||= []).push(i) }
    end
  ensure
    self.save
  end

  def send_emails(async = false, check = true)
    to_send = []
    self.e_a_assignments.each do |a_id, threads|
      threads = threads.map { |t_id| self.emails[t_id] }
      threads += self.fill_up_emails
      to_send += self.format_emails(threads, a_id)
    end
    to_send += self.format_emails(self.master_emails + self.fill_up_emails, self.master_account) if has_master

    e_sender = EmailSender.new
    to_send.shuffle.each { |s| e_sender.send_thread(s[0], s[1], nil, async, check) }
  end

  def send_emails_from_acc(async = false)
    to_send = []
    self.e_a_assignments.each do |a_id, threads|
      threads = threads.map { |t_id| self.emails[t_id] }
      threads += self.fill_up_emails
      to_send += self.format_emails(threads, a_id)
    end
    to_send += self.format_emails(self.master_emails + self.fill_up_emails, self.master_account) if has_master

    e_sender = EmailSender.new
    to_send.shuffle.each { |s| e_sender.send_thread(s[0], e_sender.random_recipient, s[1], async, false) }
  end

  def format_emails(threads, a_id, flatten_all = false)
    dest = Mongoid.with_tenant(self.name) do
      g = GoogleAccount.where( id: a_id ).first
      { "email"  => g.gmail, "login"  => g.login, "passwd" => g.passwd }
    end
    if flatten_all
      threads = threads.map { |t| t.map { |e| [e] } }.reduce([]) { |sum, t| sum = sum + t }
    end
    threads.map { |t| [t, dest] }
  end

  def start_measurement(reloads, async = false, queue_name = :default)
    self.measurements.push :start => Time.now.utc, :reloads => reloads
    if async
      GmailScraper.scrap_accounts_async(self.name, reloads, queue_name)
    else
      GmailScraper.scrap_accounts(self.name, reloads)
    end
  ensure
    self.save
  end

  def self.prepare_data(exp_names, logging = false)
    exp_names.each do |exp_name|
      Mongoid.with_tenant(exp_name) do
        EmailSnapshot.map_emails_to_exp
        puts "maped" if logging
        Email.do_clustering
        puts "e clusterd" if logging
        Ad.do_clustering
        puts "a clusterd" if logging
        AdSnapshot.set_context_clusters
        puts "set context clstr" if logging
        Ad.set_master_items
        puts "set master_items" if logging
        # if you want to auto-learn the params
        Ad.compute_context_distrs
        puts "ctxt distr" if logging
        # Ad.compute_behavior_distrs
        # puts "bhvr distr" if logging
        Ad.compute_bool_behavior_distrs
        puts "b_bhvr distr" if logging
      end
    end
  end

  def self.analyse_exp(name)
    self.build_indexes(name)
    Experiment.prepare_data([name])
    # TODO compute and save params
    Mongoid.with_tenant(name) do
      Ad.recompute_scores([:bool_behavior, :context], false, false)
      Ad.compute_ad_data
    end
  end

  def self.reanalyse_all
    Experiment.each do |exp|
      Mongoid.with_tenant(exp.name) do
        Experiment.analyse_exp(exp.name)
      end
    end
  end

  def self.recompute_data_all
    Experiment.each do |exp|
      Mongoid.with_tenant(exp.name) do
        Ad.compute_ad_data
      end
    end
  end
end
