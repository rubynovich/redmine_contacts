require File.expand_path('../../test_helper', __FILE__)

class SalesFunnelControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

    ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', 
                            [:contacts,
                             :contacts_projects,
                             :contacts_issues,
                             :deals,
                             :deal_processes,
                             :notes])              

  def setup
    RedmineContacts::TestCase.prepare

    @request.env['HTTP_REFERER'] = '/'
  end
  
  def test_should_get_index
    @request.session[:user_id] = 1
    get :index
    assert_response :success
  end  
  
  def test_should_get_index_for_project
    @request.session[:user_id] = 1
    get :index, :project_id => 1
    assert_response :success
  end
  
end
