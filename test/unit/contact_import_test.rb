require File.expand_path('../../test_helper', __FILE__)  

class ContactImportTest < ActiveSupport::TestCase
  fixtures :projects  
  
  def test_open_correct_csv
    contact_import = ContactImport.new(
      :file => Rack::Test::UploadedFile.new(fixture_files_path + "correct.csv", 'text/comma-separated-values'),
      :project => Project.first,
      :quotes_type => '"'
      )
    assert_equal 4, contact_import.imported_instances.count, 'Should find 4 contacts in file'
    puts contact_import.errors.full_messages unless contact_import.valid?
    assert contact_import.save, 'Should save successfully'
  end

  def test_should_report_error_line
    contact_import = ContactImport.new(
      :file => Rack::Test::UploadedFile.new(fixture_files_path + "with_data_malformed.csv", 'text/comma-separated-values'),
      :project => Project.first,
      :quotes_type => '"'
      )
    assert !contact_import.save, 'Should not save with malformed date'
    assert_equal 1, contact_import.errors.count, 'Should have 1 error'
    assert contact_import.errors.first.last.include?("Error on line 1"), 'Should mention string number in error message'
  end

  def test_open_csv_with_custom_fields
    cf1 = ContactCustomField.create!(:name => 'License', :field_format => 'string')
    cf2 = ContactCustomField.create!(:name => 'Purchase date', :field_format => 'date')
    contact_import = ContactImport.new(
      :file => Rack::Test::UploadedFile.new(fixture_files_path + "contacts_cf.csv", 'text/comma-separated-values'),
      :project => Project.first,
      :quotes_type => '"'
      )
    assert_equal 1, contact_import.imported_instances.count, 'Should find 1 contact in file'
    assert contact_import.save, 'Should save successfully'
    assert_equal "12345", Contact.find_by_first_name('Monica').custom_field_value(cf1.id)
  end

end
