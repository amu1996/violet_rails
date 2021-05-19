class User < ApplicationRecord
  include SimpleDiscussion::ForumUser
  # Include default devise modules. Others available are:
  #  and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  attr_accessor :canonical_subdomain

  before_destroy :ensure_final_user

  FULL_PERMISSIONS = {
    can_manage_web: true,
    can_manage_email: true,
    can_manage_users: true,
    can_manage_blog: true,
  }

  def name
    self.email
  end
  
  def subdomain
    Apartment::Tenant.current
  end

  def self.global_admins
    self.where(global_admin: true)
  end
  
  private


  def ensure_final_user
    if Rails.env != 'test'
      if User.all.size - 1 == 0
        throw :abort
      end 
    end
  end
end
