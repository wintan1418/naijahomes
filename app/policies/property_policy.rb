class PropertyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user&.can_manage_properties?
  end

  def new?
    create?
  end

  def update?
    user&.can_manage_properties? && (record.user == user || user.admin?)
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end
end