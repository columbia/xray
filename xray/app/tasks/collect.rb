class Collect
  def self.perform
    RecurrentExp.each do |rec_exp|
      rec_exp.last_iteration += 1
      base = rec_exp.base_name
      itr_name = "#{rec_exp.base_name}_itr#{rec_exp.last_iteration}"
      Experiment.duplicate_exp(base, itr_name)
      exp = Experiment.where(name: itr_name).first
      exp.start_measurement(rec_exp.reloads, true, base)
      rec_exp.measurements.push :start => Time.now.utc, :reloads => rec_exp.reloads
      rec_exp.save
    end
  end
end
