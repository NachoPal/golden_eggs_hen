require 'rufus-scheduler'
require 'rake'

Rails.application.load_tasks
# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton

unless defined?(Rails::Console)
  s.every '10s' do
    Rake::Task['get:markets_info'].execute
  end
end