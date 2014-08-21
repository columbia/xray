every 8.hours do
  runner "Collect.perform"
end

every :hour do
  runner "Analyse.perform"
end
