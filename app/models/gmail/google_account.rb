class GoogleAccount < Account
  field :passwd
  field :gmail
  field :voice_number
  field :voice_verifs, default: 0
  field :email_verifs, default: 0
  field :emails_labeled
  field :phone
  field :gender
  field :first_name
  field :last_name
  field :email
  field :bd
  field :bm
  field :by

  field :checked, :default => false
  index({ login: 1 }, { :unique => true })

  def self.label_all_emails(exp_name)
    Mongoid.with_tenant(exp_name) do
      GoogleAccount.each_with_index { |acc, i| acc.label_emails(exp_name, i) }
    end
  end

  def related_email_subjects
    AccountEmail.where( account: self ).all.map { |ae| ae.email.snapshots.first.subject }
  end

  def label_emails(exp_name, index)
    return if self.emails_labeled

    puts "#{exp_name}: new account #{index}"
    imap = Gmail.connect!(self.login, self.passwd)
    emails = imap.inbox.all.map do |e|
      [e.gmsg_id.to_s(16), e.gthread_id.to_s(16), e.subject, e.body]
    end
    imap.logout
    emails.each do |email|
      cands = Experiment.where( name: exp_name ).first.emails.map.with_index do |e, i|
        #
        # TODO support experiment threads with multiple emails
        #
        e = e.first
        e['subject'] == email[2] && email[3].include?(e['text'] || e['html']) ? i : nil
      end.compact
      if cands.count == 1
        EmailSnapshot.where( account: self, e_id: email[0]).each do |e_sn|
          e_sn.exp_e_id = cands.first
          e_sn.save
        end
      end
    end
    self.emails_labeled = true
    self.save
  end

  def self.available_accounts
    GoogleAccount.where( "used" => nil )
  end
end
