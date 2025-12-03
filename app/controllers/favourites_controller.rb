class FavouritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, except: [:index]
  
  def index
    @favourites = current_user.favourites.includes(property: :images_attachments)
                             .joins(:property)
                             .order(created_at: :desc)
    
    # Simple pagination without kaminari if not available
    @favourites = @favourites.limit(12).offset((params[:page].to_i - 1) * 12) if params[:page]
    
    @recent_searches = session[:recent_searches]&.last(5) || []
  end
  
  def create
    @favourite = current_user.favourites.build(property: @property)
    
    respond_to do |format|
      if @favourite.save
        format.html { redirect_back(fallback_location: @property, notice: 'Property added to favourites.') }
        format.json { render json: { status: 'success', message: 'Added to favourites', favourited: true } }
      else
        format.html { redirect_back(fallback_location: @property, alert: 'Unable to add to favourites.') }
        format.json { render json: { status: 'error', message: 'Unable to add to favourites' }, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @favourite = current_user.favourites.find_by(property: @property)
    
    respond_to do |format|
      if @favourite&.destroy
        format.html { redirect_back(fallback_location: @property, notice: 'Property removed from favourites.') }
        format.json { render json: { status: 'success', message: 'Removed from favourites', favourited: false } }
      else
        format.html { redirect_back(fallback_location: @property, alert: 'Unable to remove from favourites.') }
        format.json { render json: { status: 'error', message: 'Unable to remove from favourites' }, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def set_property
    @property = Property.find(params[:property_id])
  end
end