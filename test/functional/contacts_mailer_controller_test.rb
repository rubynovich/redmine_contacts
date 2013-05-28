require File.expand_path('../../test_helper', __FILE__)

class ContactsMailerControllerTest < ActionController::TestCase
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
                             :tags,
                             :taggings,
                             :contacts_queries])    
  
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/contacts_mailer'
  
  def setup
    RedmineContacts::TestCase.prepare
    
    @controller = ContactsMailerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end
  
  def test_should_create_issue
    # Enable API and set a key
    Setting.mail_handler_api_enabled = 1
    Setting.mail_handler_api_key = 'secret'
    
    post :index, :key => 'secret', :email => IO.read(File.join(FIXTURES_PATH, 'fwd_new_note_plain.eml'))
    assert_response 201
  end
  
end
