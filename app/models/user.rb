class User < ActiveRecord::Base
  devise :omniauthable, :omniauth_providers => [:cas, :github, :orcid, :jwt]

  validates :name, presence: true
  validates :uid, presence: true, uniqueness: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create(generate_user(auth))
  end

  def self.per_page
    15
  end

  # Helper method to check for admin user
  def is_admin?
    role == "admin"
  end

  # Helper method to check for admin or staff user
  def is_admin_or_staff?
    ["admin", "staff"].include?(role)
  end

  # Use different cache key for admin or staff user
  def cache_key
    is_admin_or_staff? ? "1" : "2"
  end

  def api_key
    authentication_token
  end

  def email_with_name
    if email && name != email
      "#{name} <#{email}>"
    else
      email
    end
  end

  protected

  # Don't require email, as we also use OAuth
  def email_required?
    false
  end

  def self.generate_user(auth)
    if User.count > 0 || Rails.env.test?
      authentication_token = auth.info.api_key || generate_authentication_token
      role = auth.info.role || "user"
    else
      # use admin role and specific token for first user
      authentication_token = ENV['API_KEY']
      role = "admin"
    end

    { email: auth.info.email,
      name: auth.info.name,
      authentication_token: authentication_token,
      role: role }
  end

  private

  def self.generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
