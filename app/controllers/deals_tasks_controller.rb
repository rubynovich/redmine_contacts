class DealsTasksController < ApplicationController
  unloadable    
  
  before_filter :find_project_by_project_id, :authorize
  before_filter :find_deal, :except => [:close]    
  before_filter :find_issue, :except => [:new]
  
  def new
    issue = Issue.new
    issue.subject = params[:task_subject]
    issue.project = @project
    issue.tracker_id = params[:task_tracker]
    issue.author = User.current
    issue.due_date = params[:due_date]
    issue.assigned_to_id = params[:assigned_to]
    issue.description = params[:task_description]
    issue.status = IssueStatus.default
    if issue.save
      flash[:notice] = l(:notice_successful_add)
      @deal.issues << issue
      @deal.save
      redirect_to :back
      return
    else
      redirect_to :back 
    end           
  end   
  
  
  def close
    @issue.status = IssueStatus.find(:first, :conditions =>  { :is_closed => true })    
    @issue.save
    respond_to do |format|
      format.js do 
        render :update do |page|  
            page["issue_#{params[:issue_id]}"].visual_effect :fade 
        end
      end     
      format.html {redirect_to :back }
    end
     
  end     
  
  private
  
  def find_deal 
    @deal = Deal.find(params[:deal_id]) 
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_issue
    @issue = Issue.find(params[:issue_id]) 
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def assigned_to_users
    user_values = []  
    project = @project
    user_values << ["<< #{l(:label_all)} >>", ""]
    user_values << ["<< #{l(:label_me)} >>", User.current.id] if User.current.logged?
    if project
      user_values += project.users.sort.collect{|s| [s.name, s.id.to_s] }
    else
      project_ids = Project.all(:conditions => Project.visible_condition(User.current)).collect(&:id)
      if project_ids.any?
        # members of the user's projects
        user_values += User.active.find(:all, :conditions => ["#{User.table_name}.id IN (SELECT DISTINCT user_id FROM members WHERE project_id IN (?))", project_ids]).sort.collect{|s| [s.name, s.id.to_s] }
      end
    end    
  end
  
  
end
