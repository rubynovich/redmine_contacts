
require File.expand_path('../../test_helper', __FILE__)

class ContactImportsControllerTest < ActionController::TestCase  
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
                             :notes,
                             :roles,
                             :enabled_modules,
                             :tags,
                             :taggings,
                             :contacts_queries])   


  def setup
    RedmineContacts::TestCase.prepare

    @controller = ContactImportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil  
  end

  test 'should open contact import form' do
    @request.session[:user_id] = 1
    get :new, :project_id => 1
    assert_response :success
    assert_select 'form.new_contact_import'
  end

  test 'should successfully import from CSV' do
    @request.session[:user_id] = 1
    assert_difference('Contact.count', 4, 'Should add 4 contacts to the database') do
      post :create, {
        :project_id => 1,
        :contact_import => { 
          :file => Rack::Test::UploadedFile.new(fixture_files_path + "correct.csv", 'text/comma-separated-values'),
          :quotes_type => '"'
        }
      }
      assert_redirected_to project_contacts_path(:project_id => Project.first.id)
    end
  end
end
