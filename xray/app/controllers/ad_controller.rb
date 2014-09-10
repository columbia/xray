class AdController < ApplicationController
  def self.get_ad_target(name_exp, url)
    name_ad = nil
    kw = nil
    id = nil
    Mongoid.with_tenant(name_exp) do
      ad_snaphsots = AdSnapshot.where(url: url)
      if ad_snaphsots.count > 0
        name_ad = ad_snaphsots.first.name
        ad = ad_snaphsots.first.ad
        id = ad.id
        targ = ad.targeting_items([:bool_behavior_new])
        if targ.count == 1
          e = targ.first
          email = Email.where(id: e).first
          kw = email.snapshots.first.subject
          relacc = ad.related_accounts
          relacc_with_e = relacc.select { |a| a.has_cluster?(email.id.to_s) }
          contexts = ad.snapshots.map { |s| s.context.subject }
          if relacc_with_e.count < 7 or contexts.count <= 20
            kw = nil
          end
        end
      end
    end
    return name_ad, id, kw
  end

  def self.get_email(exp_name, email_subject)
    re = RecurrentExp.where(base_name: exp_name).first
    Mongoid.with_tenant(re.last_exp_name) do
      {"subject" => email_subject,
        "text"   => Experiment.email_body_from_title(exp_name, email_subject),}
    end
  end

  def self.get_ads(name_exp, email_subject)
    re = RecurrentExp.where(base_name: name_exp).first
    re.experiments.map do |e|
      Mongoid.with_tenant(e.name) do
        begin
          email_id = EmailSnapshot.where(subject: email_subject).first.email.id.to_s
          Ad.where(targeting_email_id: email_id, strong_association: true).map do |ad|
            data = ad.targeting_data
            data["id"] = ad.id.to_s
            data["exp"] = e.name
            data["exp_date"] = Time.at(e.last_measurement).to_date.to_s
            data
          end
        rescue
          nil
        end
      end
    end.compact.reduce(&:+)
  end

  def self.get_list_kw(name_exp)
    rexp = RecurrentExp.where(base_name: name_exp).first
    ename = rexp.last_exp_name
    return [] unless ename
    Mongoid.with_tenant(ename) do
      Email.all.compact
      .select { |e| !e.garbage? }
      .select do |e|
        s = e.snapshots.first.subject
        s != "Disclaimer" &&
        s != "anorexia" &&
        s != "Malik Jackson" &&
        s != "black people" &&
        s != "Latino situation"
      end.uniq
      .map do |e|
        # eid = e.id.to_s
        s = e.snapshots.first.subject
        s_ = s.downcase
        {:subject => s,
         :text    => Experiment.email_body_from_title(name_exp, s),
         :display_subject => ("Race based content" if s_.include?("latino") || s_.include?("black") || s_.include?("african")),
         :display_text => ("(Click on the subject for exact content)" if s_.include?("latino") || s_.include?("black") || s_.include?("african")),
         :ad_number => rexp.ads_number_for_email(s),} end
    end
  end

  def self.get_info_exp(name_exp)
    if name_exp != ""
      data = Hash.new
      data["exp_description"] = RecurrentExp.func_on_recexp(name_exp,:display_name)
      data["exp_date"] = RecurrentExp.func_on_recexp(name_exp,:measurements_dates).uniq
      data["exp_accs"] = RecurrentExp.func_on_recexp(name_exp,:account_number)
      data["exp_email_accs"] = RecurrentExp.func_on_recexp(name_exp,:emails_in_n_accs)
      return data
    else
      return nil
    end
  end

  def self.get_nb_acc(exp)
    if !exp.empty?
      Mongoid.with_tenant(exp){Account.count}
    end
  end

  def self.get_list_exp
    Experiment.all.map{|exp| exp.name}.compact
  end

  def self.get_list_kw_exp
    tab = Hash.new
    RecurrentExp.each do |re|
      tab[re.display_name] = re.base_name
    end
    tab
  end

  def self.get_info_ad(name_exp, id)
    data = Hash.new
    Mongoid.with_tenant(name_exp) do
      ad = Ad.where(id: id)
      if ad.count == 1
        ad = ad.first
        ad_data = ad.targeting_data
        data["Text"] = ad_data["text"]
        data["Url"] = ad_data["url"]
        data["Email targeted"] = ad_data["targeted_subject"]
        data["#WithEmail / #Active"] = "#{ad_data["aa_with_email"]}/#{ad_data["active_accounts"]}"
        data["Behavioral score"] = ad_data["behavior_score"]
        data["#EmailContext / #Displays"] = "#{ad_data["context_email"]}/#{ad_data["context_tot"]}"
        data["Main account: #EmailContext / #Displays"] =
              "#{ad_data["context_master_email"]}/#{ad_data["context_master_tot"]}"
        data["Contextual score"] = ad_data["context_score"]
        data["Mix score"] = ad_data["mix_score"]
      else
        data["Error"] = "No ad selected."
      end
    end
    return data
  end
end
