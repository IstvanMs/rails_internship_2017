class Message < ApplicationRecord
	validates :subject, :presence => true, :length => { :in => 1..30 }
	validates :content, :presence => true
	validates :recipient_id, :presence => true
	validates :sender_id, :presence => true
	validates :status, :presence => true
end
