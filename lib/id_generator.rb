require 'nanoid'

module IdGenerator
  def self.generate_user_id
    alphabet = '0123456789abcdefghijklmnopqrstuvwxyz'
    "u-#{Nanoid.generate(size: 10, alphabet: alphabet)}"
  end

  def self.generate_note_id
    alphabet = '0123456789abcdefghijklmnopqrstuvwxyz'
    "n-#{Nanoid.generate(size: 10, alphabet: alphabet)}"
  end

  def self.generate_backup_note_id
    alphabet = '0123456789abcdefghijklmnopqrstuvwxyz'
    "bk-#{Nanoid.generate(size: 10, alphabet: alphabet)}"
  end

  def self.generate_slug
    alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    return Nanoid.generate(size: 20, alphabet: alphabet)
  end
end
