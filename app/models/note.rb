class Note < ApplicationRecord

	  validates :text, presence: true,
                    length: { minimum: 6 }

end
