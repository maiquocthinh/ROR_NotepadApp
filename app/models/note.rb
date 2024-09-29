class Note < ApplicationRecord
  before_create :set_defaults

  belongs_to :user,  optional: true

  validates :slug, uniqueness: true
  validates :external_slug, uniqueness: true

  private

  def set_defaults
    generate_id if self.id.blank?
    generate_slug if self.slug.blank?
    generate_external_slug if self.external_slug.blank?
    self.content = "" if self.content.blank?
  end


  def generate_id
    self.id = IdGenerator.generate_note_id
    while Note.exists?(id: self.id)
      self.id = IdGenerator.generate_note_id
    end
  end

  def generate_slug
    self.slug = IdGenerator.generate_slug
    while Note.exists?(slug: self.slug)
      self.slug = IdGenerator.generate_slug
    end
  end

  def generate_external_slug
    self.external_slug = IdGenerator.generate_slug
    while Note.exists?(external_slug: self.external_slug)
      self.external_slug = IdGenerator.generate_slug
    end
  end
end
