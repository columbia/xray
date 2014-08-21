
class Ad < SnapshotCluster
  cluster_of :ad_snapshots
  has_context :email

  has_many :account_ads
  has_many :gmail_truths

  field :labeled
  field :in_master
  index({ labeled: 1 })
  index({ labeled: 1, in_master: 1 })
  index({ labeled: 1, _type: 1 })
  index({ labeled: 1, in_master: 1, _type: 1 })

  field :targeting_email_id
  field :strong_association, :default => false
  field :targeting_data
  index({ targeting_email_id: 1, strong_association: 1 })

  def self.compute_ad_data
    Ad.no_timeout.each { |ad| ad.compute_data }
  end

  def compute_data
    data = Hash.new
    data["text"] = self.snapshots.first.name
    data["url"] = self.snapshots.first.url

    bbn = self.targeting_items([:bool_behavior_new])
    bb  = self.targeting_items([:bool_behavior])
    mix = self.targeting_items([:context, :bool_behavior])
    bbn = [] if bbn.count > 1
    bb  = [] if bbn.count > 1
    mix = [] if bbn.count > 1

    targ = bbn | bb | mix
    self.strong_association = false
    if targ.count == 1
      eid = targ.first
      self.targeting_email_id = eid
      email = Email.where(id: eid).first
      subject = email.snapshots.first.subject
      relacc = self.related_accounts
      relacc_with_e = relacc.select { |a| a.has_cluster?(email.id.to_s) }
      contexts = self.snapshots.map { |s| s.context.subject }
      if relacc_with_e.count >= 6 and relacc.count <= relacc_with_e.count + 1
        self.strong_association = true
        exp = Experiment.current
        master = exp.master_account
        context_counts = contexts.reduce(Hash.new(0)) { |hash,subj| hash[subj] += 1; hash }
        m_contexts = self.snapshots.all.select { |s| s.account.id.to_s == master }
                                       .map { |s| s.context.subject }
        m_context_counts = m_contexts.reduce(Hash.new(0)) { |hash,subj| hash[subj] += 1; hash }
        context = self.get_scores(:context)[email.id.to_s]
        behavior = self.get_scores(:bool_behavior)[email.id.to_s]
        mix = (context + behavior).to_f / 2

        data["targeted_subject"] = subject
        data["mix_score"] = mix
        data["active_accounts"] = relacc.count
        data["aa_with_email"] = relacc_with_e.count
        data["behavior_score"] = behavior
        data["context_tot"] = contexts.count
        data["context_email"] = context_counts[subject]
        data["context_master_tot"] = m_contexts.count
        data["context_master_email"] = m_context_counts[subject]
        data["context_score"] = context
      end
    end
    self.targeting_data = data
    self.save
  end

  def has_truth?
    emails_n = Experiment.where( :name => Mongoid.tenant_name ).first.emails.count
    GmailTruth.where( :ad => self ).count >= emails_n
  end

  def to_label?
    self.seen_in_master? && !self.has_truth?
  end

  def targeting_truth
    GmailTruth.where( :ad => self, answer: "Yes" ).all.map { |t| t.get_email.id.to_s rescue nil }.compact.uniq
  end

  def self.pre_label
    tot_labeled = 0
    exp = Experiment.where( :name => Mongoid.tenant_name ).first
    emails = exp.emails
    self.in_master.each do |ad|
      next unless ad.to_label?
      targ = []
      ad.snapshots.each do |sn|
        targ = targ + emails.select { |e| e.first['keywords'].select { |kw| sn.name.downcase.include?(kw) }.count > 0 }
      end
      next unless targ.count > 0
      targ = targ.uniq.map { |e| e.first['subject'] }
      tot_labeled += 1
      ad.labeled = true
      ad.save
      emails.each_with_index do |e, i|
        GmailTruth.create({ :exp_email_id => i,
                            :exp_email    => e,
                            :answer       => targ.include?(e.first['subject']) ? 'Yes' : 'No',
                            :ad           => ad,
        })
      end
    end
    tot_labeled
  end

  # analysis "instanciation"
  targeted_by Email

  # parameters for fexp11
  # set_params :context, { :p => 0.5886093628762348,
  #                        :q => 0.046656567492838724,
  #                        :r => 0.10576599465435517, }
  # parameters for fexp21
  # set_params :context, { :p => 0.544963902667799,
                         # :q => 0.005844784831041431,
                         # :r => 0.009974560263823037, }
  # parameters for sexp2
  # set_params :context, { :p => 0.8946268656716416, :q => 0.005, :r => 0.02497810024847583, }
  # set_params :context, { :p => 0.37102599807619185, :q => 0.0006, :r => 0.004392822426621953, }
  # parameters for sexp4
  # set_params :context, { :p => 0.8921041734388563, :q => 0.0, :r => 0.026028083136413582, }
  # set_params :context, { :p => 0.3634138507017995, :q => 0.001, :r => 0.00633318678447126, }
  # parameters for sexp8
  # set_params :context, { :p => 0.7140415484182788, :q => 0.0035608648786089876, :r => 0.00938982276988097, }
  # set_params :context, { :p => 0.44680726505660795, :q => 0.00022786378708431214, :r => 0.0029328149802187843, }
  # parameters for sexp16
  # set_params :context, { :p => 0.763461208938781, :q => 0.0033736576180375013, :r => 0.010692008133903454, }
  # parameters for sexp32
  # set_params :context, { :p => 0.19986495390845796, :q => 1.0255085392803115e-05, :r => 0.000805940924089732, }
  # parameters for sexp64
  # set_params :context, { :p => 0.2145633265807903, :q => 1.1882765658226003e-05, :r => 0.000510775409361812, }
  # for cexp2t1
  # set_params :context, { :p => 0.1271913284886456, :q => 0.00047228414145287394, :r => 0.001711873502596595 }
  # for cexp2t2
  # set_params :context, { :p => 0.2148695490035347, :q => 0.0008578988832679802, :r => 0.002325205556331765 }
  # for cexp2t3
  # set_params :context, { :p => 0.23050116308897695, :q => 0.00020000471446269643, :r => 0.0049340326798989614 }
  set_params :context, { :p => 0.44680726505660795, :q => 0.00000786378708431214, :r => 0.0029328149802187843, }

  # parameters for fishy1
  # set_params :context, {:p=>0.3112593113052315, :q=>6.125294184396454e-05, :r=>0.0050397208311149825 }
  # parameters for fishy1r1
  # set_params :context, {:p=>0.2632031514031126, :q=>0.001092997310635848, :r=>0.004206559188794906}
  # parameters for fishy1r2
  # set_params :context, {:p=>0.33383243487215797, :q=>0.0005136990320305005, :r=>0.0037719894922552044}
  # parameters for fishy2
  # set_params :context, {:p=>0.11840764794850106, :q=>0.0023481038679715864, :r=>0.004509292324872822}
  # parameters for fishy2r1
  # set_params :context, {:p=>0.1680684829924382, :q=>0.005717746631519987, :r=>0.003184215872156013}
  # parameters for fishy2r3
  set_params :context, {:p => 0.13280670939822337, :q => 0.003536307216783638, :r => 0.005310332681592469}

  
  # set_params :behavior, { :p => 0.9, :q => 0.001, :r => 0.4 }
  # for fexp11
  # set_params :behavior, { :p => 0.018940951903738394, :q => 0.0006802290581868325, :r => 0.009900990099009915 }
  # for sexp2
  # set_params :behavior, { :p => 0.17127804416861414, :q => 0.0012557056587976052, :r => 0.1111111111111111 }
  # set_params :behavior, { :p => 0.17876178141201077, :q => 0.006716042465755651, :r => 0.11111111111111108 }
  # set_params :behavior, { :p => 0.17876178141201077, :q => 0.00, :r => 0.11111111111111108 }
  # for sexp4
  # set_params :behavior, { :p => 0.1418518121957588, :q => 0.00, :r => 0.09090909090909069 }
  # set_params :behavior, { :p => 0.1418518121957588, :q => 0.0011258284596369875, :r => 0.09090909090909069 }
  # set_params :behavior, { :p => 0.1418518121957588, :q => 0.00, :r => 0.09090909090909069 }
  # for sexp8
  # set_params :behavior, {:p=>0.08632113345350882, :q=>0.0012258568018596488, :r=>0.047619047619047686}
  # set_params :behavior, {:p => 0.0840145338091019, :q => 0.0013421915270289753, :r => 0.04761904761904779 }
  # set_params :behavior, {:p => 0.0840145338091019, :q => 0.00, :r => 0.04761904761904779 }
  # for sexp16
  # set_params :behavior, {:p => 0.0675715503570463, :q => 0.00024611465324382575, :r => 0.03846153846153852 }
  # set_params :behavior, {:p => 0.0675715503570463, :q => 0.0, :r => 0.03846153846153852 }
  # parameters for sexp32
  # set_params :behavior, { :p => 0.036826042346191176, :q => 0.0008692261730829297, :r => 0.019607843137254843, }
  # for cexp2t1
  # set_params :behavior, { :p => 0.04852973343866087, :q => 0.0040596268087352665, :r => 0.02777777777777774 }
  # for cexp2t2
  # set_params :behavior, { :p => 0.07788658944219427, :q => 0.0016898309410692063, :r => 0.04000000000000001 }
  # for cexp2t3
  # set_params :behavior, { :p => 0.07348260112438175, :q => 0.0007129344488628888, :r => 0.03846153846153848 }
  # set_params :behavior, {:p => 0.0675715503570463, :q => 0.0, :r => 0.03846153846153852 }
  # for fishy1
  set_params :behavior, {:p => 0.0675715503570463, :q => 0.00024611465324382575, :r => 0.03846153846153852 }

  # for fexp11
  # set_params :bool_behavior, { :p => 0.019287906244881078, :q => 0.0002624623547997546, :r => 0.009900990099009885 }
  # for sexp2
  # set_params :bool_behavior, { :p => 0.17708333333333334, :q => 0.0, :r => 0.11111111111111105 }
  # for sexp4
  # set_params :bool_behavior, { :p => 0.1411877394636014, :q => 0.0, :r => 0.09090909090909084 }
  # for sexp8
  # set_params :bool_behavior, { :p => 0.08443163393199649, :q => 0.0006134284735979652, :r => 0.04761904761904735 }
  # set_params :bool_behavior, { :p => 0.08443163393199649, :q => 0.00, :r => 0.04761904761904735 }
  # for sexp16
  # set_params :bool_behavior, { :p => 0.06583133940320847, :q => 0.0016538763609076112, :r => 0.03846153846153854 }
  # for sexp32
  # set_params :bool_behavior, { :p => 0.03688893862891717, :q => 0.000640650826712676, :r => 0.019607843137255 }
  # for sexp64
  # set_params :bool_behavior, { :p => 0.023286106529775485, :q => 0.0004538778518685613, :r => 0.012345679012345737 }
  # for cexp2t1
  # set_params :bool_behavior, { :p => 0.049883872545832236, :q => 0.002610562571075652, :r => 0.02777777777777784 }
  # for cexp2t2
  # set_params :bool_behavior, { :p => 0.07767728250275427, :q => 0.0017189861910221825, :r => 0.039999999999999925 }
  # for cexp2t3
  # set_params :bool_behavior, { :p => 0.07340726303883754, :q => 0.0005148916391519942, :r => 0.038461538461538505 }
  # set_params :bool_behavior, { :p => 0.0916666666666667, :q => 0.0, :r => 0.06666666666666682 }
  # set_params :bool_behavior, { :p => 0.0715823970037454, :q => 0.0, :r => 0.06666666666666682 }
  #
  # ytgm-2
  # set_params :bool_behavior, { :p => 0.07715608841382837, :q => 0.008146743675851088, :r => 0.04000000000000001 }
  # ytgm-2r1
  set_params :bool_behavior, { :p => 0.0748468073667682, :q => 0.000, :r => 0.03999999999999998}
  # for fishy1
  # set_params :bool_behavior, { :p => 0.3, :q => 0.001, :r => 0.04999999999999987 }
  # for fishy1r1
  # set_params :bool_behavior, {:p=>0.08687386555033626, :q=>0.0008297980520202742, :r=>0.050000000000000024}
  # for fishy1r2
  # set_params :bool_behavior, {:p=>0.08715147570519474, :q=>0.0011151923273135394, :r=>0.05000000000000007}
  # for fishy2
  # set_params :bool_behavior, {:p=>0.08345411928726831, :q=>0.002758052538754293, :r=>0.04999999999999995}
  # for fishy2r1
  # set_params :bool_behavior, {:p=>0.08127629945811765, :q=>0.0021173271173271172, :r=>0.05000000000000008}
  # for fishy2r3
  set_params :bool_behavior, {:p => 0.09580870197261784, :q => 0.0027341840863082697, :r => 0.05000000000000015}

  set_params  :bool_behavior_new, { :threshold               => 0.92,
                                    :min_active_accounts     => 3,
                                    :max_results_size        => 0,
                                    :check_combination       => true,
                                    :variable_threshold      => 0.0,
                                    :stand_out               => [0,0],
                                    :check_inactive_accounts => false}

end
