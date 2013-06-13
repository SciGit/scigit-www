require 'base64'
require 'scigit/thrift_client'

class UserPublicKey < ActiveRecord::Base
  validates :name, :presence => true
  validates :public_key, :uniqueness => true
  belongs_to :user

  after_create :notify_thrift_add

  def self.parse_key(key)
    parts = key.split
    if parts.length < 2 || ['ssh-rsa', 'ssh-dsa'].include?(key[0])
      return nil
    end

    raw = Base64.decode64(parts[1])
    pos = 0
    blocks = []
    while pos < raw.length
      # read 4 byte header (length of the next block)
      if pos + 4 > raw.length
        return nil
      end
      # order: MSB is first, read as unsigned 32-bit
      runlen = raw[pos, 4].unpack('N').first
      if runlen >= 512 || pos + 4 + runlen > raw.length
        return nil
      end
      blocks << raw[pos+4, runlen]
      pos += 4 + runlen
    end

    if blocks.length != 3 || blocks[0] != parts[0] || blocks[2].length < 200
      return nil
    end

    pkey = UserPublicKey.new
    pkey.key_type = parts[0]
    pkey.public_key = parts[1]
    pkey.comment = parts[2]
    return pkey
  end

  def disable!
    enabled = 0
    if save!
      begin
        SciGit::ThriftClient.new.deletePublicKey(id, user.id, public_key)
      rescue
        # Not a big deal if it doesn't work. Login is still disabled
      end
    end
  end

 private
  def notify_thrift_add
    begin
      SciGit::ThriftClient.new.addPublicKey(id, user.id, public_key)
    rescue
      return false
    end
  end
end
