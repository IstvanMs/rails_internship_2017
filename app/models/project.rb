class Project < ApplicationRecord

	has_many :tasks, dependent: :destroy

	validates :title, presence: true,
                    length: { minimum: 5 }

end
