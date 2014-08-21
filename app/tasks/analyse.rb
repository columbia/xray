class Analyse
  def self.perform
    stats = Sidekiq::Stats.new
    qs = stats.queues
    RecurrentExp.each do |rec_exp|
      [1..rec_exp.last_iteration].each do |i|
        itr_name = "#{rec_exp.base_name}_itr#{i}"
        exp = Experiment.where(name: itr_name).first
        # already analysed or collections till running
        next if exp.analysed or qs[rec_exp.base_name] > 0

        AnalyseWorker.perform_async(itr_name)
        exp.analysed = true
        exp.save
      end
    end
  end
end
