class Landlord::PropertiesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_landlord_or_agent
  before_action :set_property, only: [:show, :edit, :update, :destroy]
  
  def index
    @properties = current_user.properties
                             .includes(:images_attachments, :leads)
                             .page(params[:page])
  end
  
  def show
    @recent_leads = @property.leads.recent.limit(10)
  end
  
  def new
    @property = current_user.properties.build
  end
  
  def create
    @property = current_user.properties.build(property_params)
    
    if @property.save
      redirect_to landlord_property_path(@property), notice: 'Property was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @property.update(property_params)
      redirect_to landlord_property_path(@property), notice: 'Property was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @property.destroy
    redirect_to landlord_properties_path, notice: 'Property was successfully deleted.'
  end
  
  private
  
  def set_property
    @property = current_user.properties.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to landlord_properties_path, alert: 'Property not found.'
  end
  
  def ensure_landlord_or_agent
    unless current_user.landlord_or_agent? || current_user.admin?
      redirect_to root_path, alert: 'You are not authorized to access this page.'
    end
  end
  
  def property_params
    params.require(:property).permit(
      :title, :description, :price, :payment_frequency, :property_type,
      :bedrooms, :bathrooms, :toilets, :size, :state, :city, :lga, 
      :address, :latitude, :longitude, :status, :featured, images: []
    )
  end
end