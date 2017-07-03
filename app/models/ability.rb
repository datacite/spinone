class Ability
  include CanCan::Ability

  # To simplify, all admin permissions are linked to the Notification resource

  def initialize(user)
    user ||= User.new(:role => "anonymous") # Guest user

    if user.role == "staff_admin"
      can :manage, :all
    elsif user.role == "staff_user"
      can :read, :all
      can [:update, :show], User, :id => user.id
    elsif %w(member_admin member_user datacenter_admin datacenter_user user).include?(user.role )
      can [:read], User
      can [:update, :show], User, :id => user.id
    end
  end
end
