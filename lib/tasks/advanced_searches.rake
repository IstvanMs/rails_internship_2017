desc "Remove searches older than a week"
task :remove_old_searches => :environment do
  Search.delete_all ["created_at < ?", 1.week.ago]
end