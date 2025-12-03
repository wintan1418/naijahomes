class Landlord::LeadNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_landlord_or_agent
  before_action :set_lead
  
  def create
    @note = @lead.lead_notes.build(note_params)
    @note.user = current_user
    
    if @note.save
      # Create activity record
      @lead.lead_activities.create!(
        user: current_user,
        activity_type: :note_added,
        description: "Added note: #{@note.content.truncate(50)}",
        details: { note_id: @note.id }
      )
      
      respond_to do |format|
        format.json { render json: { status: 'success', note: format_note(@note) } }
        format.html { redirect_to landlord_lead_path(@lead), notice: 'Note added successfully.' }
      end
    else
      respond_to do |format|
        format.json { render json: { status: 'error', errors: @note.errors.full_messages } }
        format.html { redirect_to landlord_lead_path(@lead), alert: 'Failed to add note.' }
      end
    end
  end
  
  private
  
  def set_lead
    @lead = Lead.for_user(current_user).find(params[:lead_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to landlord_leads_path, alert: 'Lead not found.'
  end
  
  def note_params
    params.require(:lead_note).permit(:content, :note_type)
  end
  
  def format_note(note)
    {
      id: note.id,
      content: note.content,
      note_type: note.note_type&.humanize,
      user_name: note.user.name,
      created_at: note.created_at.strftime('%B %d, %Y at %I:%M %p')
    }
  end
  
  def ensure_landlord_or_agent
    unless current_user.can_manage_properties?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end