desc "Remove searches older than a week"
task :remove_old_advanced_searches => :environment do
  AdvancedSearch.delete_all ["created_at < ?", 1.week.ago]
end