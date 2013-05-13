class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable
         #:confirmable,

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :fullname, :organization, :location, :about, :disable_email

  validates :fullname, :length => { :in => 6..20 }
  validates :organization, :length => { :maximum => 60 }
  validates :location, :length => { :maximum => 60 }
  validates :about, :length => { :maximum => 255 }
end
