require 'open-uri'
class SnapshotCluster
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :snapshots
  has_many :account_snapshot_clusters, dependent: :destroy

  field :distr, default: {}

  # for matching
  field :log_footprint
  field :matched
  field :match_group
  index({ match_group: 1 })

  class_attribute :context_klass
  def self.has_context(klass)
    self.context_klass = klass.to_s.classify.constantize
  end

  class_attribute :signature_klass
  def self.has_signature(klass)
    self.signature_klass = klass.to_s.classify.constantize
  end

  # creates and alias for the account  # in subclasses
  def self.inherited(c)
    super
    c.send(:define_method, "account_#{c.name.downcase.pluralize}") do
      self.account_snapshot_clusters
    end
  end

  class_attribute :snapshot_klass
  def self.cluster_of(items)
    self.snapshot_klass = items.to_s.classify.constantize
  end

  cluster_of :snapshots

  def create_relationship(account_ids)
    relation_klass = "Account#{self.class.name}".classify.constantize
    account_ids.each do |id|
      relation_klass.create(account_id: id, snapshot_cluster:self) if relation_klass.where(account_id: id, snapshot_cluster:self).count == 0
    end
  end

  # accounts this cluster is in
  def related_accounts
    self.class.related_accounts(self.id.to_s)
  end

  def self.related_accounts(cluster_id)
    AccountSnapshotCluster.where( snapshot_cluster_id: cluster_id ).all.map { |asc| asc.account }.uniq
  end

  def seen_in_master?
    exp = Experiment.where( :name => Mongoid.tenant_name ).first
    AccountSnapshotCluster.where( :snapshot_cluster_id => self.id, :account_id => exp.master_account ).count > 0
  end

  def self.in_master
    self.no_timeout.all.select { |x| x.seen_in_master? }
  end

  def self.set_master_items
    self.each do |item|
      if item.seen_in_master?
        item.in_master = true
        item.save
      end
    end
  end

  def self.do_clustering
    sigs_map = {}
    ads_map = {}

    snapshot_klass.no_timeout.each do |item|
      sigs = item.signatures.uniq
      sigs.each do |sig|
        sigs_map[sig] ||= Set.new
        ads_map[sig] ||= Set.new
        sigs_map[sig].merge(sigs)
        ads_map[sig].add(item.id)
      end
    end

    merged_map = sigs_map.keys.map do |sig|
      next unless sigs_map[sig]

      sigs = sig.to_a.to_set
      loop do
        old_sigs, sigs = sigs, sigs.reduce(Set.new) { |set, s| set.merge(sigs_map[s]) }
        break if old_sigs == sigs
      end

      sigs.reduce(Set.new) do |set, s|
        sigs_map[s] = nil
        set.merge(ads_map[s])
      end
    end.compact

    merged_map.each_with_index do |grouped_items, l|
      cluster = self.create
      grouped_items.each_with_index do |item_id, i|
        item = snapshot_klass.where(id: item_id).first
        if item.snapshot_cluster
          #
          # TODO preserve the ground truths
          #
          item.snapshot_cluster.destroy
        end
        item.snapshot_cluster = cluster
        cluster.create_relationship [item.account.id]
        item.save!
      end

      cluster.save!
    end
  end

  # analysis to "instanciate" in cluster classes see Ad for an example
  # change with great care and run tests
  #
  # types are "context" or "behavior"

  # the guess for targeting relations
  def targeting_items(types, tmp=false, accounts = :all)
    context_weight = (types.include?(:context) ? 1 : 0)
    behavior_weight = (types & [:behavior, :bool_behavior]).count > 0 ? 1 : 0 #SnapshotCluster.related_accounts(self).count : 0
    behavior_weight += (types & [:bool_behavior_new]).count > 0 ? 1 : 0 # change the weight of new behavioral targeting here
    tot_weight = context_weight + behavior_weight
    sc = types.map do |t|
      if (accounts == :all && t != :bool_behavior_new) || t == :context  # don't recompute for context, we always use master only
        [t, self.get_scores(t, tmp)]
      elsif accounts == :all && t == :bool_behavior_new
        [t, self.get_scores(t, tmp)]
      elsif accounts != :all && t == :bool_behavior_new
        [t, self.compute_scores_bool_behavior_new(tmp, accounts)]
      else
        [t, self.compute_scores(t, tmp, accounts)]
      end
    end.reduce(Hash.new(0)) do |glbl, s|
      weight = s.first == :context ? context_weight : behavior_weight
      s = s.last
      s.keys.each do |k|
        score = weight * s[k].to_f / tot_weight
        glbl[k] += score.nan? ? 0 : score
      end
      glbl
    end

    # void_score = sc.delete('')
    max_sc = sc.values.select { |n| !n.to_f.nan? }.max
    cands = sc.select do |id, score|
      !score.to_f.nan? && score >= max_sc * 0.9  && id != "" && id && id != "garbage"
    end

    return [] if cands.count > 2 # || void_score > 2 * max_sc
    cands.keys
  end



  field :scores, :default => {}
  field :tmp_scores, :default => {}

  @@score_types = [:context, :behavior, :bool_behavior, :bool_behavior_new]
  class << self
    attr_accessor :parameters  # parameters for targeting models
    attr_accessor :tmp_parameters  # parameters for targeting models
    attr_accessor :data_klass  # the related data class (eg would be email for ad)
  end

  def self.targeted_by(klass)
    self.data_klass = klass
  end

  def self.set_params(type, data, tmp = false)
    if tmp
      (self.tmp_parameters ||= {})[type] = data
    else
      (self.parameters ||= {})[type] = data
    end
  end

  def self.get_params(type, tmp = false)
    tmp ? (self.tmp_parameters ||= {})[type] : (self.parameters ||= {})[type]
  end

  def get_scores(type, tmp=false)
    res = tmp ? self.tmp_scores[type.to_s] : self.scores[type.to_s]
    res || (type == :bool_behavior_new ? self.compute_scores_bool_behavior_new(tmp, :all) : self.compute_scores(type, tmp))
  end

  #
  # compute the scores
  #

  # subclass that if you don't want some clusters to be counted as valid data
  # regarding targeting ; in that case return "garbage" instead
  #
  # eg in Email.rb
  def garbage?
    return self.cluster_targeting_id == "garbage"
  end

  def cluster_targeting_id
    self.id.to_s
  end

  def self.recompute_scores(types = @@score_types, tmp = false, master_only = true)
    # Compute list of emails in each account if type is :bool_behavior_new

    if !master_only
      self.all.no_timeout.each_with_index { |ad, i| print "\r> Item " + "#{i+1}".green; types.each do |t| 
          if t != :bool_behavior_new
            ad.compute_scores(t, tmp) 
          else
            ad.compute_scores_bool_behavior_new(tmp, :all)
          end
      end }
    else
      self.no_timeout.in_master.each_with_index { |ad, i| print "\r> Item " + "#{i+1}".green; types.each do |t| 
          if t != :bool_behavior_new
            ad.compute_scores(t, tmp)
          else
            ad.compute_scores_bool_behavior_new(tmp, :all)
          end
        end }
    end
    puts " Done!"
  end

  def compute_scores(type, tmp = false, accounts = :all)
    to_save = (accounts == :all)
    accounts = [Account.master_account] if type == :context && accounts == :all

    scores = self.class.data_klass.all.map do |e|
      tarid = e.cluster_targeting_id
      tarid != "garbage" ? [tarid, self.send("p_x_e_a_#{type}", e, tmp, accounts)] : nil
    end.compact.push([nil, self.send("p_x_void_a_#{type}", tmp, accounts)])  # for void email (ie not targeted)
    tot = scores.reduce(0) { |sum, e| sum + e[1] }
    sc = Hash[scores.map { |s| [s[0], s[1] / tot] }]
    if to_save
      tmp ? self.tmp_scores[type] = sc : self.scores[type] = sc
    else
      sc
    end
  ensure
    self.save if to_save
  end

  def compute_scores_bool_behavior_new(tmp = false, accounts = :all)
    to_save = (accounts == :all)
    params = self.class.get_params(:bool_behavior_new)

    active_accounts = ( accounts == :all ? self.related_accounts : self.related_accounts & accounts) # accounts that see the ad
    nb_active_accounts = active_accounts.count

    targeted_emails = []
    stop = false

    # Option 1
    if nb_active_accounts < params[:min_active_accounts]
      targeted_emails = []
      stop = true
    end

    emails_in_active_accounts = Hash.new(0)

    # Compute the core inputs
    if !stop
      active_accounts.each_with_index do |act_a, i|
        Experiment.curr_accs_emails_map[act_a.id].each do |em|
          emails_in_active_accounts[em.id.to_s] += 1 if em != nil
        end
      end
    end

    nb_active_accounts = nb_active_accounts.to_f
    max = emails_in_active_accounts.values.max
    if max == nil
      stop = true
    end

    # # compute the core inputs with threshold
    # # if params[:variable_threshold] == 0 && !stop
    # if variable_t == 0 && !stop
    #   emails_in_active_accounts.each do |em, times_in_accounts|
    #     if (times_in_accounts/nb_active_accounts >= params[:threshold])
    #       targeted_emails << em
    #     end
    #   end
    # elsif !stop
    #   # Option 2
    #   # threshold variable of the nb of active accounts
    #   if max/nb_active_accounts >= params[:threshold] - nb_active_accounts * variable_t#params[:variable_threshold]
    #     targeted_emails = emails_in_active_accounts.select {|em, nb| nb == max}.keys
    #   end
    # end

    if !stop
      emails_in_active_accounts.each do |em, times_in_accounts|
        # if max/nb_active_accounts >= params[:threshold] - nb_active_accounts * params[:variable_threshold]
        #   targeted_emails = emails_in_active_accounts.select {|em, nb| nb == max}.keys
        if times_in_accounts/nb_active_accounts >= params[:threshold] - nb_active_accounts * params[:variable_threshold]
          targeted_emails << em
        end
      end
    end


    # Option 3
    # Targeted email(s) should be standing out from the other emails
    if params[:stand_out] != [0,0] && !stop
      if emails_in_active_accounts.select{|em, nb| nb != max && nb >= max - params[:stand_out][0] - (params[:stand_out][1] > 0 ? nb_active_accounts.floor / params[:stand_out][1] : 0 ) }.count > 0
        targeted_emails = []
        stop = true
      end
    end

    # Temporary
    if params[:check_inactive_accounts]
      inactive_accounts = (accounts == :all ? Account.all.uniq : accounts) - active_accounts
      emails_in_inactive_accounts = Hash.new(0)
      inactive_accounts.each do |act_a|
        (Experiment.curr_accs_emails_map[act_a.id].map { |em| em.try(&:id).try(&:to_s) } & targeted_emails)
            .compact.each {|em| emails_in_inactive_accounts[em] += 1 }
      end

      min = emails_in_inactive_accounts.values.min

      if targeted_emails.select{|em| emails_in_inactive_accounts[em] == 0}.count > 0
        targeted_emails.select!{|em| emails_in_inactive_accounts[em] == 0}
      else
        targeted_emails.select!{|em| emails_in_inactive_accounts[em] == min}
      end
    end

    # Option 4
    # Checks if the combination of targeted emails are present in more than threshold of the accounts
    # returns [] if not
    if params[:max_results_size] > 0 && !stop
      if targeted_emails.count > params[:max_results_size]
        # Option 5
        if params[:check_inactive_accounts]
          inactive_accounts = (accounts == :all ? Account.all.uniq : accounts) - active_accounts
          emails_in_inactive_accounts = Hash.new(0)
          inactive_accounts.each do |act_a|
            (Experiment.curr_accs_emails_map[act_a.id].map { |em| em.try(&:id).try(&:to_s) } & targeted_emails)
                .compact.each {|em| emails_in_inactive_accounts[em] += 1 }
          end

          min = emails_in_inactive_accounts.values.min

          if targeted_emails.select{|em| emails_in_inactive_accounts[em] == 0}.count > 0
            targeted_emails.select!{|em| emails_in_inactive_accounts[em] == 0}
          else
            targeted_emails.select!{|em| emails_in_inactive_accounts[em] == min}
          end
        end

        if targeted_emails.count > params[:max_results_size]
          targeted_emails = []
          stop = true
        end
      end
    end

    # AND combination test
    if params[:check_combination] && targeted_emails.count > 1 && !stop
      times_targeted_emails_in_accounts = 0
      active_accounts.each do |act_a|
        if (Experiment.curr_accs_emails_map[act_a.id].map {|em| em.id.to_s if em != nil} & targeted_emails).count == targeted_emails.count
          times_targeted_emails_in_accounts += 1
        end
      end
      if times_targeted_emails_in_accounts/nb_active_accounts < params[:threshold] - nb_active_accounts * params[:variable_threshold]
        targeted_emails = []
      end
    end

    sc = Hash.new
    targeted_emails.each do |em|
      sc[em.to_s] = 1.0 / targeted_emails.count
    end

    if to_save
      tmp ? self.tmp_scores[:bool_behavior_new] = sc : self.scores[:bool_behavior_new] = sc
    else
      sc
    end
  ensure
    self.save if to_save
  end

  def p_x_e_a_context(data, tmp = false, accounts = :all)
    params = self.class.get_params(:context, tmp)
    if accounts == :all
      tot = self.snapshots.count
      data_tot = self.snapshots.where( context_cluster: data ).count
    else
      tot = accounts.reduce(0) { |sum, acc| sum += acc.snapshots.where( snapshot_cluster: self ).count }
      data_tot = accounts.reduce(0) { |sum, acc| sum += acc.snapshots.where( snapshot_cluster: self, context_cluster: data ).count }
    end
    tot, data_tot = 100, data_tot * 100.0 / tot if tot > 100
    params[:p] ** data_tot * params[:q] ** (tot - data_tot)
  end

  def p_x_void_a_context(tmp = false, accounts = :all)
    if accounts == :all
      tot = self.snapshots.count
    else
      tot = accounts.reduce(0) { |sum, acc| sum += acc.snapshots.where( snapshot_cluster: self ).count }
    end
    params = self.class.get_params(:context, tmp)
    params[:r] ** [tot, 100].min
  end

  def p_x_e_a_behavior(data, tmp = false, accounts = :all)
    params = self.class.get_params(:behavior, tmp)
    if accounts == :all
      tot = self.snapshots.count
    else
      tot = accounts.reduce(0) { |sum, acc| sum += acc.snapshots.where( snapshot_cluster: self ).count }
    end
    accounts_in = self.related_accounts
    accounts_in = accounts_in & accounts if accounts != :all
    a_e_in = accounts_in.select { |a| AccountSnapshotCluster.where( account: a, snapshot_cluster: data ).count > 0 }

    in_displays = a_e_in.map { |a| a.snapshots.where( snapshot_cluster: self ).count }.sum
    in_displays = in_displays == nil ? 0 : in_displays
    out_displays = tot - in_displays

    in_displays = in_displays.to_f * 100.0 / tot if tot > 100
    out_displays = out_displays.to_f * 100.0 / tot if tot > 100
    params[:p] ** in_displays * params[:q] ** out_displays
  end

  def p_x_void_a_behavior(tmp = false, accounts = :all)
    if accounts == :all
      tot = self.snapshots.count
    else
      tot = accounts.reduce(0) { |sum, acc| sum += acc.snapshots.where( snapshot_cluster: self ).count }
    end
    params = self.class.get_params(:behavior, tmp)
    params[:r] ** [tot, 100].min
  end

  def p_x_e_a_bool_behavior(data, tmp = false, accounts = :all)
    params = self.class.get_params(:bool_behavior, tmp)
    if accounts == :all
      account_ids = Account.all.map { |ac| ac.id.to_s }.uniq
    else
      account_ids = accounts.map { |ac| ac.id.to_s }.uniq
    end
    #binding.pry
    accounts_in = self.related_accounts.map { |ac| ac.id.to_s }.uniq
    accounts_in = accounts_in & account_ids if accounts != :all
    accounts_out = account_ids - accounts_in
    a_e_in = accounts_in.select { |a| AccountSnapshotCluster.where( account_id: a, snapshot_cluster: data).count > 0 }.count
    a_ne_in = accounts_in.count - a_e_in
    a_e_out = accounts_out.select { |a| AccountSnapshotCluster.where( account_id: a, snapshot_cluster: data).count > 0 }.count
    a_ne_out = accounts_out.count - a_e_out

    n = account_ids.count
    a_e_in, a_ne_in, a_e_out, a_ne_out = [a_e_in, a_ne_in, a_e_out, a_ne_out].each { |v| v * 100.0 / n } if n > 100
    p, q = params[:p], params[:q]
    p ** a_e_in * q ** a_ne_in * (1-p) ** a_e_out * (1-q) ** a_ne_out
  end

  def p_x_void_a_bool_behavior(tmp = false, accounts = :all)
    params = self.class.get_params(:bool_behavior, tmp)
    if accounts == :all
      tot = Account.count
      tot_in = self.related_accounts.count
    else
      tot = accounts.count
      tot_in = (self.related_accounts & accounts).count
    end
    tot_out = tot - tot_in
    tot_in, tot_out = tot_in * 100.0 / tot, tot_out * 100.0 / tot if tot > 100
    r = params[:r]
    r ** tot_in * (1-r) ** tot_out
  end

  #
  # try to guess the parameters for the model
  #

  # runs a loop to learn (unsupervise) the parameters of the model
  def self.recompute_all_params
    @@score_types.map { |t| self.compute_parameters(t) if t != :bool_behavior_new}  # map so that it prints
  end

  def self.compute_parameters(type)
    self.set_params(type, { :p => 0.7, :q => 0.01, :r => 0.2 }, true)
    # self.set_params(type, { :p => 0.3, :q => 0.001, :r => 0.002 }, true)
    loop do
      puts "start loop"
      self.recompute_scores([type], true, true)
      puts "compute distr"
      old_distr = self.get_params(type, true)
      new_distr = self.set_params(type, self.distribution(type, true), true)
      puts old_distr
      puts new_distr
      change = new_distr.keys.reduce(0) { |sum, k| sum += (old_distr[k] - new_distr[k]).abs }
      puts change
      break if change < 0.01
    end
    self.get_params(type, true)  # return params at the end
  end

  # call that before you compute parameters
  def self.compute_context_distrs
    self.no_timeout.in_master.each do |item|
      item.distr[:context.to_s] = Hash.new(0)
      item.class.context_klass.no_timeout.each do |ctxt|
        next if ctxt.cluster_targeting_id == 'garbage'
        # item.distr[:context.to_s][ctxt.id.to_s] = Snapshot.where( snapshot_cluster: item, context_cluster: ctxt ).count
        # only master for context?
        master = Account.master_account
        item.distr[:context.to_s][ctxt.id.to_s] = master.snapshots.where( snapshot_cluster: item, context_cluster: ctxt ).count
      end
      item.save
    end
  end
  def self.compute_behavior_distrs
    self.no_timeout.in_master.each do |item|
      item.distr[:behavior.to_s] = Hash.new(0)
      Account.no_timeout.each do |acc|
        item.distr[:behavior.to_s][acc.id.to_s] = Snapshot.where( account: acc, snapshot_cluster: item ).count
      end
      item.save
    end
  end
  def self.compute_bool_behavior_distrs
    self.no_timeout.in_master.each do |item|
      item.distr[:bool_behavior.to_s] = Hash.new(0)
      Account.no_timeout.each do |acc|
        item.distr[:bool_behavior.to_s][acc.id.to_s] = Snapshot.where( account: acc, snapshot_cluster: item ).count > 0 ? 1 : 0
      end
      item.save
    end
  end

  def self.compute_bool_behavior_new_distrs
    self.no_timeout.in_master.each do |item|
      item.distr[:bool_behavior_new.to_s] = Hash.new(0)
      Account.no_timeout.each do |acc|
        item.distr[:bool_behavior_new.to_s][acc.id.to_s] = Snapshot.where( account: acc, snapshot_cluster: item ).count > 0 ? 1 : 0
      end
      item.save
    end
  end

  def self.distribution(type, tmp = true)
    targ = untarg = 0

    self.no_timeout.in_master.map do |item|
      puts "new item"
      itm_targ = []
      case type
      when :context
        itm_targ = item.targeting_items([type], tmp)
        tot = tot_targ = tot_wrong_targ = item.snapshots.count
      when :behavior
        itm_targ = item.targeting_items([type], tmp).map { |t| SnapshotCluster.related_accounts(t) }
                       .flatten.map(&:id).map(&:to_s).uniq
        tot = tot_targ = tot_wrong_targ = item.snapshots.count
      when :bool_behavior
        itm_targ = item.targeting_items([type], tmp).map { |t| SnapshotCluster.related_accounts(t) }
                       .flatten.map(&:id).map(&:to_s).uniq
        # tot = GoogleAccount.count
        # tot_targ = itm_targ.count
        # tot_targ = SnapshotCluster.related_accounts(item).count
        # tot_wrong_targ = tot - tot_targ
        tot = tot_targ = tot_wrong_targ = SnapshotCluster.related_accounts(item).count
      when :bool_behavior_new
        itm_targ = item.targeting_items([type], tmp, :all)
                       .map { |t| SnapshotCluster.related_accounts(t) }
                       .flatten.map(&:id).map(&:to_s).uniq
        # tot = GoogleAccount.count
        # tot_targ = itm_targ.count
        # tot_targ = SnapshotCluster.related_accounts(item).count
        # tot_wrong_targ = tot - tot_targ
        tot = tot_targ = tot_wrong_targ = SnapshotCluster.related_accounts(item).count
      end


      if itm_targ.count > 0
        targ += 1
        # the [0] is a hack to avoid dividing by zero
        ps = itm_targ.map { |id| item.distr[type.to_s][id].to_f / tot_targ }
        ps = [0] if ps.count == 0
        qs = (item.distr[type.to_s].keys - itm_targ).map { |id| tot_wrong_targ == 0 ? 0 : item.distr[type.to_s][id].to_f / tot_wrong_targ }
        qs = [0] if qs.count == 0
        { :p => ps.sum.to_f / ps.size, :q => qs.sum.to_f / qs.size, :r => 0 }
      else
        untarg += 1
        rs = item.distr[type.to_s].values.map { |v| v.to_f / tot }
        rs = [0] if rs.count == 0
        { :p => 0, :q => 0, :r => rs.sum.to_f / rs.size }
      end
    end.reduce(Hash.new(0)) do |agg, vals|
      agg[:p] += targ > 0 ?  vals[:p] / targ : 0
      agg[:q] += targ > 0 ? vals[:q] / targ : 0
      agg[:r] += untarg > 0 ? vals[:r] / untarg : 0
      agg
    end
  end

  # matching
  def log_footprint
    return super if super
    log_footprint!
  end

  def log_footprint!
    self.log_footprint = Hash.new(0)
    self.class.signature_klass.each do |ad|
      ne = Snapshot.where( snapshot_cluster: ad, context_cluster: self ).count
      self.log_footprint[ad.id.to_s] = Math.log(ne + 1)
    end
  ensure
    self.save
  end

  def self.recompute_log_footprints
    self.no_timeout.each(&:log_footprint!)
  end
end
