class ContactImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include CSVImportable

  attr_accessor :file, :project, :tag_list, :quotes_type

  def klass
    Contact
  end

  def build_from_fcsv_row(row)
    ret = Hash[row.to_hash.map{ |k,v| [k.underscore.gsub(' ','_'), force_utf8(v)] }].delete_if{ |k,v| !klass.column_names.include?(k) }
    ret[:birthday] = row['birthday'].to_date if row['birthday']
    ret[:tag_list] = [row['tags'], tag_list].join(',')
    ret
  end
end
