class User < ActiveRecord::Base
  has_many :tweets
  has_secure_password
  validates_presence_of :username, :password_digest, :email

  def slug
    self.username.gsub(/\W/, '-').downcase
  end
  
  def self.find_by_slug(slug)
    self.all.find {|t| t.slug == slug}
  end
end