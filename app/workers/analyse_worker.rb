class AnalyseWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 0
  sidekiq_options :queue => :analyse

  def perform(exp_name)
    Experiment.analyse_exp(exp_name)
  end
end
