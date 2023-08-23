class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include PgSearch::Model, MetadataSetup

  ### before filters
  before_validation :set_code 

  ### scope
  scope :owned_by, ->(user) { where owner_id: user.id }
  scope :visible, -> { where is_active: true }

  ### full-text local search
  pg_search_scope :search_by_code, against: [:code, :created_by, :updated_by],
    associated_against: { name_translations: [:translation],
                         description_translations: [:translation]},
    using: { tsearch: { prefix: true, negation: true } }

  def self.search(criteria)
    if criteria.present?
      search_by_code(criteria)
    else
      # No query? Return all records, sorted by uuid.
      order( :updated_at )
    end
  end

  ### Public functions definitions
  def set_as_inactive(user)
    self.update_attributes(is_active: false, updated_by: user)
  end

  def set_as_active(user)
    self.update_attributes(is_active: true, updated_by: user)
  end

  ### format code with naming convention if the option is listed in parameter's scope
  def set_code
    puts "Set code for: #{ self.class.name }" 
    # Codes starting with _ wont be updated by naming convention
    if self.has_attribute?(:code) and !self.code.blank?
      if code[0] == '_'
        code
      else
        list_id = ParametersList.where("code=?", 'LIST_OF_OBJECT_TYPES').take!
        if object_type = Parameter.find_by("parameters_list_id=? AND code=?", list_id, self.class.name )
          prefix = object_type.property
          # Check if this object requires to apply a naming convention
          if object_type.scope&.include? 'naming' or self.code.blank?
            # Format the instance code
            if self.code.blank?
              self.code = (self.name["en"] || 'missing identifier').gsub(/[^0-9A-Za-z]/, '_')[0,32]
            else
              self.code = self.code.upcase.gsub(/[^0-9A-Za-z]/, '_')[0,32]
            end
            # Do not add prefix if it is already present
            if "#{self.code[0, prefix.length]}_" != "#{prefix}_"
              self.code = "#{prefix}_#{self.code}"[0,32]
            end
          end
        end
        set_sort_code
      end
    end
  end

  # Create sort code in order to sort lists properly when no sort code is specified
  def set_sort_code
    if self.has_attribute?(:code) and self.has_attribute?(:sort_code)
      if self.sort_code.blank?
        self.sort_code = self.code
      else
        if self.sort_code.to_f.to_s == self.sort_code.to_s || self.sort_code.to_i.to_s == self.sort_code.to_s # Number
          self.sort_code = self.sort_code.rjust(6, '0')
        end
      end
    end
  end

end
