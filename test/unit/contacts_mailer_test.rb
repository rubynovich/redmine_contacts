require File.expand_path('../../test_helper', __FILE__)  

class ContactsMailerTest < ActiveSupport::TestCase
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


  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/contacts_mailer'

  def setup
    RedmineContacts::TestCase.prepare
    
    ActionMailer::Base.deliveries.clear
    Setting.notified_events = Redmine::Notifiable.all.collect(&:name)
  end


  test "Should add contact note from to" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('new_note.eml').first
    assert_instance_of ContactNote, note
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from email", note.subject
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(1).id, note.source_id
  end

  test "Should add contact note from ID in to" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('new_note_by_id.eml').first
    assert_instance_of ContactNote, note
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from email", note.subject
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(1).id, note.source_id
  end

  test "Should add contact note from ID in cc" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('new_note_with_cc.eml').first
    assert_instance_of ContactNote, note
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from email by id in cc", note.subject
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(1).id, note.source_id
  end

  test "Should add deal note from ID in to" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('new_deal_note_by_id.eml').first
    assert_instance_of DealNote, note
    assert !note.new_record?
    note.reload
    assert_equal Deal, note.source.class
    assert_equal "New note from email", note.subject
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Deal.find(1).id, note.source_id
  end

  
  test "Should add contact note from forwarded" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('fwd_new_note_plain.eml').first
    assert_instance_of ContactNote, note
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from forwarded email", note.subject
    assert_match "From: \"Marat Aminov\" marat@mail.ru\n", note.content
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(2).id, note.source_id
  end

  test "Should add contact note from forwarded html" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    note = submit_email('fwd_new_note_html.eml').first
    assert_instance_of ContactNote, note
    assert !note.new_record?
    note.reload
    assert_equal Contact, note.source.class
    assert_equal "New note from forwarded html email", note.subject
    assert_match "From: Marat Aminov <marat@mail.com>\r\n", note.content
    assert_equal User.find_by_login('admin'), note.author
    assert_equal Contact.find(2).id, note.source_id
  end

  
  test "Should not add contact note from deny user to" do
    ActionMailer::Base.deliveries.clear
    # This email contains: 'Project: onlinestore'
    assert !submit_email('new_deny_note.eml')
    # assert note.is_a?(Note)
    # assert !note.new_record?
    # note.reload
    # assert_equal Contact, note.source.class
    # assert_equal "New note from email", note.subject
    # assert_equal User.find_by_login('admin'), note.author
    # assert_equal Contact.find(1).id, note.source_id
  end
  

  private

  def submit_email(filename, options={})
    raw = IO.read(File.join(FIXTURES_PATH, filename))
    ContactsMailer.receive(raw, options)
  end

end
