class ContactsVcfController < ApplicationController
  unloadable
  
  require 'vpim/vcard'
  
  before_filter :find_project_by_project_id, :authorize
  
  def load   
    begin
      vcard = Vpim::Vcard.decode(params[:contact_vcf]).first  
      contact = {}
      contact[:first_name] = vcard.name.given
      contact[:middle_name] = vcard.name.additional
      contact[:last_name] = vcard.name.family
      contact[:phone] = vcard.telephones.join(', ')
      contact[:email] = vcard.emails.join(', ')
      contact[:website] = vcard.url.uri if vcard.url
      contact[:address] = vcard['ADR'].gsub('\\n', "\n") if vcard['ADR']
      contact[:birthday] = vcard.birthday
      contact[:background] = vcard.note
      contact[:company] = vcard.org.first if vcard.org
      contact[:job_title] = vcard.title
    
      respond_to do |format|
        format.html{  redirect_to :controller => "contacts", :action => "new", :project_id => @project, :contact => contact }
      end
                                                                                                
    rescue Exception => e
      flash[:error] = e.message
      respond_to do |format|
        format.html{  redirect_to :back }
      end
    end    
    
  end
end
