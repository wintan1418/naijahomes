class FavouritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property
  
  def create
    @favourite = current_user.favourites.build(property: @property)
    
    if @favourite.save
      redirect_back(fallback_location: @property, notice: 'Property added to favourites.')
    else
      redirect_back(fallback_location: @property, alert: 'Unable to add to favourites.')
    end
  end
  
  def destroy
    @favourite = current_user.favourites.find_by(property: @property)
    
    if @favourite&.destroy
      redirect_back(fallback_location: @property, notice: 'Property removed from favourites.')
    else
      redirect_back(fallback_location: @property, alert: 'Unable to remove from favourites.')
    end
  end
  
  private
  
  def set_property
    @property = Property.find(params[:property_id])
  end
end