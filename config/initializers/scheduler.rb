require 'rufus-scheduler'
require 'rake'

Rails.application.load_tasks

s = Rufus::Scheduler.singleton

unless defined?(Rails::Console)
  s.every '10s' do
    Rake::Task['buy:markets'].execute
    #Rake::Task['sell:markets'].execute
  end
end