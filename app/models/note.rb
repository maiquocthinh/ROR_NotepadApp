class Note < ApplicationRecord
  before_create :generate_id

  belongs_to :user,  optional: true

  validates :slug, uniqueness: true
  validates :external_slug, uniqueness: true

  private

  # Generates a unique random id
  def generate_id
    self.id = IdGenerator.generate_note_id
    while Note.exists?(id: self.id)
      self.id = IdGenerator.generate_note_id
    end
  end
end
