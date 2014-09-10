class EmailSnapshot < Snapshot
  field :e_id      # the email id in gmail
  field :t_id      # the thread id in gmail
  field :exp_e_id  # the email id in the experiment (the email index in emails)
                   # created from gmail_api.rb
  field :subject

  index({ e_id: 1 })
  index({ account: 1, e_id: 1 })
  index({ account: 1, subject: 1 })

  field :outsider, :default => false

  def signatures
    return super if super
    (self.exp_e_id || self.subject).to_s.to_a
  end

  # for the fancy one not with titles, see google_account
  def self.map_emails_to_exp
    emails = Experiment.where( :name => Mongoid.tenant_name ).first.emails
    emails.each_with_index do |email, i|
      email.each do |e|
        s = e['subject']
        EmailSnapshot.where( subject: s ).each do |sn|
          sn.exp_e_id = i
          sn.save
        end
      end
    end
    # Email.each do |email|
      # s = email.snapshots.first.subject
      # cand = emails.map.with_index { |e, i| i if e.first['subject'] == s }.compact
      # next unless cand.count > 0
      # email.snapshots.each { |sn| sn.exp_e_id = cand.first; sn.save }
    # end
  end
end
