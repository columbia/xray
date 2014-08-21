class GmailTruth
  include Mongoid::Document
  include Mongoid::Timestamps

  paginates_per 20

  field :exp_email_id
  field :exp_email
  field :answer

  field :change_reason
  field :history
  field :change_time

  belongs_to :ad
  belongs_to :email
  field :email_checked, :default => false
  index({ ad: 1 })
  index({ email: 1 })
  index({ ad: 1, email: 1 })
  index({ ad: 1, answer: 1 })

  def get_email
    return self.email if self.email || email_checked
    puts "bla #{exp_email_id}"
    begin
      raise if exp_email_id == 9
      self.email = EmailSnapshot.where( exp_e_id: exp_email_id ).first.email
      self.save
    rescue
      puts "[EMAIL NOT FOUND] number: #{exp_email_id}"
      self.email_checked = true
      self.save
    end
    self.email
  end

  def signatures
    [ exp_email["subject"],
      exp_email["text"],
      ad.signatures,
    ].flatten
  end

  def self.port_truth(from_exp, to_exp)
    tot = 0
    to_emails = Experiment.where( :name => to_exp ).first.emails
    Mongoid.with_tenant(from_exp) do
      Ad.each do |from_ad|
        urls = from_ad.snapshots.map { |sn| sn.url }.uniq
        true_truth = GmailTruth.where( ad: from_ad, answer: 'Yes' ).all
        # next unless true_truth.count > 0
        true_truth = true_truth.map { |t| t.exp_email_id }
        Mongoid.with_tenant(to_exp) do
          urls.each do |url|
            to_ad = AdSnapshot.where( url: url ).first
            next unless to_ad && to_ad.ad.to_label?
            tot += 1
            to_ad = to_ad.ad
            to_emails.each_with_index do |e, i|
              GmailTruth.create({ :exp_email_id => i,
                                  :exp_email    => e,
                                  :answer       => true_truth.include?(i) ? 'Yes' : 'No',
                                  :ad           => to_ad,
              })
            end
            to_ad.labeled = true
            to_ad.save
          end
        end
      end
    end
    puts tot
  end

  def self.port_truth_matching(from_exp, to_exp)
    tot = 0
    to_emails = Experiment.where( :name => to_exp ).first.emails
    Mongoid.with_tenant(from_exp) do
      Ad.each do |from_ad|
        urls = from_ad.snapshots.map { |sn| sn.url }.uniq
        true_truth = GmailTruth.where( ad: from_ad, answer: 'Yes' ).all
        # next unless true_truth.count > 0
        true_truth = true_truth.map { |t| t.exp_email.map { |e| e['subject'] } }.flatten
        Mongoid.with_tenant(to_exp) do
          urls.each do |url|
            to_ad = AdSnapshot.where( url: url ).first
            next unless to_ad && to_ad.ad.to_label?
            tot += 1
            to_ad = to_ad.ad
            to_emails.each_with_index do |e, i|
              titles = e.map { |em| em['subject'] }
              GmailTruth.create({ :exp_email_id => i,
                                  :exp_email    => e,
                                  :answer       => (true_truth & titles).count > 0 ? 'Yes' : 'No',
                                  :ad           => to_ad,
              })
            end
            to_ad.labeled = true
            to_ad.save
          end
        end
      end
    end
    puts tot
  end
end
