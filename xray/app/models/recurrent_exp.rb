class RecurrentExp
  include Mongoid::Document
  store_in database: ->{ self.database }

  field :base_name
  index({ base_name: 1 }, { :unique => true })
  field :display_name
  field :reloads, :default => 50
  field :last_iteration, :default => 0
  field :measurements, :default => []

  has_many :experiments

  class_attribute :database
  def self.fixed_db(db_name)
    self.database = db_name.to_s
  end
  fixed_db :experiments

  def self.func_on_recexp(exp_name, func_name)
    self.where(base_name: exp_name)
        .first.send(func_name)
  end

  def measurements_dates
    self.experiments.map(&:last_measurement)
        .sort.map { |d| Time.at(d).to_date.to_s }
  end

  def account_number
    self.experiments.first.account_number
  end

  def emails_in_n_accs
    e = self.experiments.first
    (e.account_number.to_f * e.e_perc_a).to_i
  end

  def last_exp_name
    self.experiments.map do |e|
      [e.name, e.last_measurement]
    end.sort_by(&:last).last.first
  end

  def ads_number_for_email(email_subject)
    self.experiments.map do |e|
      Mongoid.with_tenant(e.name) do
        begin
          eid = EmailSnapshot.where(subject: email_subject).first.email.id.to_s
          Ad.where(targeting_email_id: eid, strong_association: true).count
        rescue
          0
        end
      end
    end.sum
  end
end
