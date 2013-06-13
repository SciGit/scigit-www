class User < ActiveRecord::Base
  delegate :can?, :cannot?, :to => :ability

  has_many :project, :through => :project_permission
  has_many :project, :through => :project_change

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :token_authenticatable
         #:confirmable,

  validates :fullname, :length => { :in => 6..20 }
  validates :organization, :length => { :maximum => 60 }
  validates :location, :length => { :maximum => 60 }
  validates :about, :length => { :maximum => 255 }

  def ability
    @ability ||= Ability.new(self)
  end

  def composite_fullname_email
    "#{self.fullname} <#{self.email}>"
  end
end
