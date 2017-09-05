class Event < ApplicationRecord
	belongs_to :company

	def self.getEvents(st, et, company)
		@events = Hash.new
		for i in st..et
			startt = DateTime.parse(i.to_s + ' 00:00')
			@events[i.to_s] = {'events' => Event.where('start_time > ? and start_time < ? and company_id = ?', startt, startt.next_day, company.id).order(:start_time)}
		end
		return @events
	end
end
