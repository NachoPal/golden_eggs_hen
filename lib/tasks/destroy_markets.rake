namespace :destroy do

  desc 'Destroy markets'
  task :markets => :environment do
    Market.destroy_all
  end
end