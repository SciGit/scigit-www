class Ability
  include CanCan::Ability

  def user_has_permission(user, project, minimum)
    permission = ProjectPermission.get_user_permission(user, project)
    return false if permission.nil?
    return true if permission.permission >= minimum
  end

  def initialize(user)
    user ||= User.new

    can :manage, Project, Project do |project|
      user_has_permission(user, project, 3)
    end

    can :update, Project, Project do |project|
      user_has_permission(user, project, 2)
    end

    can :read, Project, Project do |project|
      user_has_permission(user, project, 1)
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
