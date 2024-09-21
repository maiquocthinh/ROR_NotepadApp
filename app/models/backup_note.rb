class BackupNote < ApplicationRecord
  before_create :generate_id

  belongs_to :user,  optional: true

  private

  # Generates a unique random id
  def generate_id
    self.id = IdGenerator.generate_backup_note_id
    while BackupNote.exists?(id: self.id)
      self.id = IdGenerator.generate_backup_note_id
    end
  end
end
