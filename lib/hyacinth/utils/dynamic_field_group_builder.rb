class Hyacinth::Utils::DynamicFieldGroupBuilder

  # fcd1, 08/27/15: NOTE: There is still questions about which format will work: repeatable dynamic field groups
  # have numbers appended to their names (name_role1, name_role2), or it is based on the order of columns in the
  # spreadsheet, so two repeated dynamic field groups would follow each other in the spreadsheet as far as the
  # column order is concerned
  # This design is going to try and keep the above variations enscapsulated within one method, the process_header
  # method, which for now will have two versions

  attr_accessor :name, :parent, :child_field_groups, :child_fields, :child_dynamic_field_groups_by_type

  # NOTE: may want to require a name at initialization, doesn't really make sense to create one without a name
  def initialize(name = '', parent = false)

    @parent = parent
    @name = name
    # child_fields will contain field_name, value pairs
    @child_fields = {}
    # child_field_groups will contain field_group_name, DynamicFieldGroupBuilder instance pairs
    @child_field_groups = {}
    # the following helps organize th  e DynamicFieldGroupBuilder instance by type of dymamic field group
    # which will helps us when we print out repeatable dynamic field groups
    @child_dynamic_field_groups_by_type = {}

  end

  def clear_all_data

    # can I use another iterator here, like a map type iterator
    @child_fields.each do |key, value|

      @child_fields[key] = ''

    end

    # can I use another iterator here, like a map type iterator
    @child_field_groups.each do |key, child_field_group|

      child_field_group.clear_all_data

    end

  end

  # This method creates a method to set the given child field, and returns this method
  def add_child_field(child_field_name)

    child_fields[child_field_name] = ''

    self.class.send :define_method, "set_#{child_field_name}" do |arg|

      child_fields[child_field_name] = arg

    end

    return method("set_#{child_field_name}")

  end

  def add_child_field_group(child_field_group_name)

   @children_dynamic_field_group_or_dynamic_field << child if child.present?

  end

  # fcd1, 08/25/15: This method will help to handle the format where the headers do not have numbers (i.e name_role1, name_role2)
  # so we need to figure out when to close out a dynamic field group and open up a new one of the same type. For example,
  # two name_roles for one name. One heruristic, assuming the column order is strict, is that if a field in a dynamic field group
  # already exists, then we need to create a new one.
  def field_exists?(header)
    
    first_field, rest_of_header = header.split(':',2)

    if first_field == header

      # we have a field name, i.e. a dynamic field
      return child_fields.has_key? first_field

    else

      # we have a field_group name, i.e. a dynamic field group
      # first, see if that dynamic field group already exists
      return false if !(child_field_groups.has_key?(first_field))

      # At this point, the field_group exists, but we don't know if the
      # specified child in that field group exists. So ask
      return child_field_groups[first_field].field_exists(rest_of_header)
      
    end

  end

  def empty?

  end

  # This method assumes that the repeatable fields have numbers
  # it returns a method that can be used to set the dynamic field
  # represented by the header
  def process_header(header)

    first_field, rest_of_header = header.split(':',2)

    if first_field == header

      # we have a field name, i.e. a dynamic field
      # puts "we got a field name: " + "#{first_field}"

      return add_child_field first_field

    else
      
      # error condition if there is nothing after the ':'
      return nil if rest_of_header == ''

      # puts "First part of header: " + "#{first_field}"
      # puts "Second part of header: " + "#{rest_of_header}"

      # we have a field_group name, i.e. a dynamic field group

      # puts "Here is the first_field: #{first_field}"
      dynamic_field_group_type = first_field.gsub(/\d*/,'')
      # puts "Here is the dynamic_field_group_type: #{dynamic_field_group_type}"
      @child_field_groups[first_field] ||= Hyacinth::Utils::DynamicFieldGroupBuilder.new first_field, self
      # @child_dynamic_field_groups_by_type[dynamic_field_group_type] = {first_field => @child_field_groups[first_field]}
      # @child_dynamic_field_groups_by_type[dynamic_field_group_type] = { first_field => @child_field_groups[first_field] }
      @child_dynamic_field_groups_by_type[dynamic_field_group_type] = 
        Hash.new unless child_dynamic_field_groups_by_type.has_key? dynamic_field_group_type
      @child_dynamic_field_groups_by_type[dynamic_field_group_type][first_field] = @child_field_groups[first_field]
      # @child_dynamic_field_groups_by_type[dynamic_field_group_type].store [first_field] = @child_field_groups[first_field]

      return @child_field_groups[first_field].process_header(rest_of_header)
    
    end

  end

  # This method assumes that the repeatable fields have numbers
  def process_header_old(header)

    first_field, rest_of_header = header.split(':',2)

    if first_field == header

      # we have a field name, i.e. a dynamic field
      # puts "we got a field name: " + "#{first_field}"

      return add_child_field first_field

    else
      
      # error condition if there is nothing after the ':'
      return nil if rest_of_header == ''

      # puts "First part of header: " + "#{first_field}"
      # puts "Second part of header: " + "#{rest_of_header}"

      # we have a field_group name, i.e. a dynamic field group

      # If the field group does not exist, create one
      @child_field_groups[first_field] ||= Hyacinth::Utils::DynamicFieldGroupBuilder.new first_field, self

      return @child_field_groups[first_field].process_header(rest_of_header)
    
    end

  end

  # fcd1, 08/26/15: Update: I believe this may be intractable, we need numbers for repeatable fields.
  # Also, this gives some guidance on which fields are repeatable
  def process_header_repeatable_field_names_do_not_have_numbers(header)

    child_field_group = nil

    first_field, rest_of_header = header.split(':',2)

    if first_field == header

      # we have a field name, i.e. a dynamic field
      # puts "we got a field name: " + "#{first_field}"

      return add_child_field first_field

    else
      
      # error condition if there is nothing after the ':'
      return nil if rest_of_header == ''

      # puts "First part of header: " + "#{first_field}"
      # puts "Second part of header: " + "#{rest_of_header}"

      # we have a field_group name, i.e. a dynamic field group

      # If the child field group does not exist, create one if needed.
      # first, see if there is even one already created
      if !( @child_field_groups.has_key? first_field )

        puts "Key: #{first_field} not found"

        child_field_group = Hyacinth::Utils::DynamicFieldGroupBuilder.new first_field, self
        @child_field_groups[first_field] = child_field_group

      else

        # even though we already have a DynamicFieldGroupBuilder created for this type of dynamic field group,
        # this may be a repeatable field, which means we need to create a new one if needed. The heuristic we use
        # here is that if we try to set a field that already exists, then this must be the next instance in a 
        # repeatable field group
        if (@child_field_groups[first_field].field_exists? rest_of_header)

          # field exists, so start a new dynamic field
          child_field_group = Hyacinth::Utils::DynamicFieldGroupBuilder.new first_field, self
          
        else

          # use existing one
          child_field_group = @child_field_groups[first_field]
          
        end

      end

      return @child_field_groups[first_field].process_header_repeatable_field_names_do_not_have_numbers(rest_of_header)
    
    end

  end

  def output_data_in_hif

    output_in_hif = '{'

    output_array = []

    @child_fields.each do |key, value|

      # output_array << '"name_type"=>"' + @type + '"' unless @type.blank?
      output_array << "\"#{key}\"=>\"#{value}\"" unless value.blank?

    end

    # output += '"name_type"=>"' + @type + '", '
    # output += '"name_usage_primary"=>"' + @usage_primary + '", '
    # output += '"name_value"=>"' + @value + '", '
    # output += '"name_value_uri"=>"' + @value_uri + '", '
    # output += '"name_authority"=>"' + @authority + '", '
    # output += '"name_authority_uri"=>"' + @authority_uri + '", '

    # puts "*************************************** below is the output from inspect roles *******************************"
    # puts @roles.inspect
    # puts "*************************************** above is the output from inspect roles *******************************"

    @child_dynamic_field_groups_by_type.each do |key, hash_of_dynamic_field_builders|

      dynamic_field_group_output_data_in_hif = "\"#{key}\"=>["
      dynamic_field_group_output_array = []

      hash_of_dynamic_field_builders.each do |key, dynamic_field_builder|
      
        # puts 'Here is the output of role.inspect'
        # puts role.inspect

        # puts role.output_data_in_hif
        # roles_output_data_in_hif += role.output_data_in_hif
        dynamic_field_group_output_array << dynamic_field_builder.output_data_in_hif

      end

      dynamic_field_group_output_data_in_hif += dynamic_field_group_output_array.to_sentence(two_words_connector: ', ', last_word_connector: ', ')
      dynamic_field_group_output_data_in_hif += ']'
      output_array << dynamic_field_group_output_data_in_hif
      
    end

    output_in_hif += output_array.to_sentence(two_words_connector: ', ', last_word_connector: ', ')
    output_in_hif += '}'

    # puts '*************** Here is the name output in hif ********************'
    # puts output_in_hif

    output_in_hif

  end

end
