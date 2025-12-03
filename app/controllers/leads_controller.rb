class LeadsController < ApplicationController
  before_action :set_property
  
  def create
    @lead = @property.leads.build(lead_params)
    @lead.user = current_user if user_signed_in?
    
    if @lead.save
      # Notify property owner
      LeadMailer.new_lead_notification(@lead).deliver_later if defined?(LeadMailer)
      
      redirect_to @property, notice: 'Your enquiry has been sent successfully. The property owner will contact you soon.'
    else
      # Reload property show page with errors
      render 'properties/show', status: :unprocessable_entity
    end
  end
  
  private
  
  def set_property
    @property = Property.find(params[:property_id])
  end
  
  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :message)
  end
end