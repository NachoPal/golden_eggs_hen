namespace :destroy do

  desc 'Destroy markets'
  task :markets => :environment do
    Market.destroy_all
    Currency.destroy_all
  end
end