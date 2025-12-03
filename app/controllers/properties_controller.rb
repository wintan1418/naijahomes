class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_property, only: [:show]
  before_action :authorize_property_owner, only: [:edit, :update, :destroy]

  def index
    @properties = Property.available_only
                         .includes(:user, images_attachments: :blob)
                         .by_state(params[:state])
                         .by_city(params[:city])
                         .by_property_type(params[:property_type])
                         .price_between(params[:min_price], params[:max_price])
                         .by_bedrooms(params[:bedrooms])
                         .featured_first
                         .page(params[:page])
  end

  def show
    @lead = Lead.new
  end

  def new
    @property = current_user.properties.build
    authorize @property
  end

  def create
    @property = current_user.properties.build(property_params)
    authorize @property
    
    if @property.save
      redirect_to @property, notice: 'Property was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @property.update(property_params)
      redirect_to @property, notice: 'Property was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy
    redirect_to properties_path, notice: 'Property was successfully deleted.'
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def authorize_property_owner
    @property = current_user.properties.find(params[:id])
    authorize @property
  rescue ActiveRecord::RecordNotFound
    redirect_to properties_path, alert: 'Property not found.'
  end

  def property_params
    params.require(:property).permit(
      :title, :description, :price, :payment_frequency, :property_type,
      :bedrooms, :bathrooms, :toilets, :size, :state, :city, :lga, 
      :address, :latitude, :longitude, :status, :featured, images: []
    )
  end
end