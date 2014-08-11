# encoding: UTF-8
namespace :redmine do
  namespace :plugins do
    namespace :contacts do

        def update_one_phone(contact, some_phones, type)
            unless some_phones.blank?
                some_phones.sub!(/;\s+/, ", ")
                
                arr = some_phones.split(/,\s*\+*/)
                new_phones = ""
                arr.each do |phone|
                    old_phone = phone.dup

                    if phone.include?("Факс") || phone.include?("факс") || phone.include?("ФАКС")
                        contact.fax = contact.fax.blank? ? (" " + phone) : contact.fax + ", " + phone
                        next
                    end
                    phone.gsub!(/[^\+0-9\(\)\/]/, '')
                    phone.gsub!(/\+/, "+7") if phone.include?("+") && !phone.include?("+7") && !phone.include?("+8")
                    phone.insert(0, '+') if (phone[0] == "8") || (phone[0] == "7")
                    phone[1] = "7" if (phone[0] == "+")

                    phone.insert(0, '+7') if phone.start_with?("495", "499", "812", "(")
                    if phone.include?("+7") && phone[2] != "("
                        phone.gsub!(/\+7/, "+7 (")
                        phone.insert(7, ') ') if phone.size > 6
                    elsif phone.include?("+7")
                        phone.gsub!(/\(/, " (")
                        phone.gsub!(/\)/, ") ")
                    end                        
                    phone.insert(12, '-') if phone.size > 11
                    phone.insert(15, '-') if phone.size > 14

                    if phone.start_with?("+7 (915", "+7 (916", "+7 (910", "+7 (919", "+7 (985", 
                                         "+7 (903", "+7 (905", "+7 (909", "+7 (960",  "+7 (964",  "+7 (965", 
                                         "+7 (925", "+7 (926", "+7 (920") && (type == "phone")
                        contact.mobile_phone = contact.mobile_phone.blank? ? (" " + phone) : contact.mobile_phone + ", " + phone
                        next
                    end

                    if phone.start_with?("+7 (495", "+7 (499", "+7 (812") && (type == "mobile_phone")
                        contact.phone = contact.phone.blank? ? (" " + phone) : contact.phone + ", " + phone
                        next
                    end

                    new_phones << ", " unless new_phones.blank?
                    if phone.size == 18 
                        new_phones << phone
                    else
                        new_phones << old_phone
                    end

                end
                if type == "phone"  
                    contact.phone = new_phones                 
                else
                    contact.mobile_phone = new_phones                 
                end
            end
        end

        def concat_duplicates(some_phone)
            return false if some_phone.blank?
            arr = some_phone.split(/,\s+/).uniq
            new_phone = ""
            arr.each do |phone|
                new_phone << ", " unless new_phone.blank?
                new_phone << phone
            end
            new_phone
        end


        desc 'Update phone with template +7 (XXX) XXX-XX-XX in redmine_contacts'
        task :contacts_update_phone => :environment do
            Contact.all.each do |c|
                next if c.phone.blank? && c.mobile_phone.blank? && c.fax.blank?
                puts c.id.to_s+ "  phones:     _" + (c.phone.blank? ? "" : c.phone) + "_         _" + (c.mobile_phone.blank? ? "" : c.mobile_phone) + 
                        "_         _" + (c.fax.blank? ? "" : c.fax) + "_         _"
                update_one_phone(c, c.phone, "phone")
                update_one_phone(c, c.mobile_phone, "mobile_phone")

                c.mobile_phone = concat_duplicates(c.mobile_phone)
                c.phone = concat_duplicates(c.phone)

                #c.update_column(:phone, c.phone) # update_columns work only for Rails4+
                #c.update_column(:mobile_phone, c.mobile_phone)
                #c.update_column(:fax, c.fax)
                c.save!(:validate => false)


                puts c.id.to_s+ "  new_phones: _" + (c.phone.blank? ? "" : c.phone) + "_         _" + (c.mobile_phone.blank? ? "" : c.mobile_phone) + 
                        "_         _" + (c.fax.blank? ? "" : c.fax) + "_         _"

                puts "---------------------------------" 
                
            end
            Contact.where("(LENGTH(phone) < 5) AND (LENGTH(phone) > 0)").update_all(phone: nil)
            Contact.where("(LENGTH(mobile_phone) < 5) AND (LENGTH(phone) > 0)").update_all(mobile_phone: nil)
        end

    end
  end
end