class Landlord::LeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_landlord_or_agent
  before_action :set_lead, only: [:show, :update_status, :add_note]
  
  def index
    @leads = current_user.leads
                        .includes(:property, :lead_notes)
                        .by_status(params[:status])
                        .recent
                        .page(params[:page])
  end
  
  def show
    @lead_notes = @lead.lead_notes.includes(:user).order(created_at: :desc)
  end
  
  def update_status
    if @lead.update(status: params[:status])
      redirect_back(fallback_location: landlord_lead_path(@lead), 
                   notice: "Lead status updated to #{@lead.status.humanize}")
    else
      redirect_back(fallback_location: landlord_lead_path(@lead), 
                   alert: 'Unable to update lead status')
    end
  end
  
  def add_note
    @lead_note = @lead.lead_notes.build(note_params)
    @lead_note.user = current_user
    
    if @lead_note.save
      redirect_back(fallback_location: landlord_lead_path(@lead), 
                   notice: 'Note added successfully')
    else
      redirect_back(fallback_location: landlord_lead_path(@lead), 
                   alert: 'Unable to add note')
    end
  end
  
  private
  
  def set_lead
    @lead = current_user.leads.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to landlord_leads_path, alert: 'Lead not found.'
  end
  
  def ensure_landlord_or_agent
    unless current_user.landlord_or_agent? || current_user.admin?
      redirect_to root_path, alert: 'You are not authorized to access this page.'
    end
  end
  
  def note_params
    params.require(:lead_note).permit(:note)
  end
end