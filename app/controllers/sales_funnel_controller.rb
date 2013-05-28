class SalesFunnelController < ApplicationController
  unloadable
  
  before_filter :find_optional_project
  
  helper :timelog
  helper :contacts
  helper :deals 
  include DealsHelper  

  def index                                                                                               
    @sales_funnel = []   
    retrieve_date_range(params[:period])

    @sales_funnel_total = DealProcess.status_funnel_data(nil, 
                        {:project_id => @project, 
                         :from => @from, :to => @to,
                         :assigned_to_id => params[:assigned_to_id],
                         :author_id => params[:author_id],
                         :category_id => params[:category_id]}
                      )

    deal_statuses.each do |status|
      @sales_funnel << [status, DealProcess.status_funnel_data(status, 
                        {:project_id => @project, 
                         :from => @from, :to => @to,
                         :assigned_to_id => params[:assigned_to_id],
                         :author_id => params[:author_id],
                         :category_id => params[:category_id]}
                      )]
    end
    
    respond_to do |format|
      format.html{ render( :partial => "sales_funnel", :layout => false) if request.xhr? }
      format.xml { render :xml => @sales_funnel}  
      format.json { render :text => @sales_funnel.to_json, :layout => false } 
    end
    
    
  end
end
