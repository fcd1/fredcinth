class Hyacinth::Utils::CsvImportExportUtilsUsingBuilders

  attr_accessor :internal_fields, :top_level_field_groups, :column_to_field_map

  def initialize

    @internal_fields = Hyacinth::Utils::ImportExport::ImportExportInternalFields.new
    @top_level_field_groups = {}
    @column_to_field_map = []

    @hif = {}
    @current = nil


  end

  def inspect_top_level_fields

    puts 'About to inspect top level field groups ...'
    puts

    @top_level_field_groups.each do |key, value|

      puts 'Name of top level field ' + "#{key}"
      puts 'Result of inspect for associated builder '
      puts value.inspect
      puts

    end

  end

  def inspect_internal_fields

    puts 'About to inspect the iternal fields ...'
    puts

    @internal_fields.each do |key, value|

      puts 'Name of internal field ' + "#{key}"
      puts 'Value of internal field: ' + "#{value}"

    end

  end

  def inspect_column_to_field_map

    puts 'About to inspect column_to_field_map ...'
    puts

    @column_to_field_map.each_with_index do |value, index|

      puts "Method at index #{index} is:"
      puts value.inspect
      puts

    end

  end

  # method that parses thru the csv.
  # logic:
  #
  # first row in CSV is human-readable header, ignored.
  #
  # second row in CSV is hif headers. This row is passed to #process_header_row, which will parse each
  # header entry and setup the column to field mapping
  #
  # any other row is a data row. It will be passed to #process_data_row, which will make use of the
  # column to field mapping to populate the fields
  #
  # 
  def csv_to_digital_object_data(csv_data_string)
    
    puts 'Here is the string I got:'
    puts csv_data_string

    output_data_in_hif = ''

    line_counter = -1

    CSV.parse(csv_data_string) do |row|

      line_counter += 1

      # first line is human readable, so we ignore it
      if line_counter == 0
        next
      end

      # second line is the real header line, so store it as such
      if line_counter == 1 
        process_header_row(row)
        next

      end

      # handle all other lines
      process_data_row(row)

      # comment the following for now, this is the line that creates the output
      # output_data_in_hif += output_row_data_in_hif

    end
    
    return output_data_in_hif

  end

  # this method figures out the dynamic field contained in the csv
  # it also handles the internal fields, such as pid, etc.
  # NOTE: This method assumes that repeatable fields have number suffixes
  def process_header_row(headers)

    headers.each_with_index do |header, index|

      header.downcase!

      # ASSUMPTION: if there are multiple instances of a top-level field (for example, two names per row entry), then
      # the header entry for each instance will end with a unique number, for example name1:... and name2:...
      # ASSUMPTION: the internal fields will all start with an underscore(_)                                                                                                      
      case

        # Handles internal fields                                                                                                                                                   
      when header.match(/^_/)

        # got an internal field                                                                                                                                                   
        @column_to_field_map[index] = @internal_fields.process_header(header)

      else
        
        # We have a top-level dynamic field group
        top_level_field_group, rest_of_header = header.split(':',2)

        # we are looking at the raw header, which needs to contain at least one ':'
        # as well as something afterwards, for example "name:name_value"
        # error condition if there is nothing after the ':', or there is no ':'
        return nil if rest_of_header == ''
        
        # If the top level field group builder  for this top level firld group does not exist, create one
        @top_level_field_groups[top_level_field_group] ||= Hyacinth::Utils::DynamicFieldGroupBuilder.new top_level_field_group
        
        @column_to_field_map[index] = @top_level_field_groups[top_level_field_group].process_header rest_of_header

      end

    end

  end

  def process_data_row(row_of_data)

    # puts "@process_headers_results, as process_data_row sees it:"
    # puts @process_headers_results.inspect

    # first, clear the data from the previous row
    # First for the internal fields
    # in all of the ImportExport* instances representing the top-level dynamic fields
    @internal_fields.clear_all_data
    
    # Now clear data for top-level fields
    # puts 'top level fields:'
    # puts top_level_fields
    @top_level_field_groups.each do |key,top_level_field|
      
      # puts 'top level field:'
      # puts top_level_field
      top_level_field.clear_all_data

    end

    # puts 'column_to_field_map:'
    # puts column_to_field_map
      
    row_of_data.each_with_index do |cell_value, index|

      # puts "Index is #{index}"
      # puts "cell value is #{cell_value}"

      @column_to_field_map[index].call cell_value

    end

  end

  def output_row_data_in_hif

    row_data_in_hif = '{'

    # create hif output for internal fields
    row_data_in_hif << @internal_fields.output_data_in_hif

    row_data_in_hif << ', '

    # top-level fields
    row_data_in_hif << '"dynamic_field_data"=>{'
    # create hif output for each top-level field.
    
    # Title, non repeatable
    row_data_in_hif << '"title"=>['
    row_data_in_hif << @title_field.output_data_in_hif
    row_data_in_hif << '], '

    # Name, repeatable
    row_data_in_hif << '"name"=>[' unless @name_fields.empty?
    @name_fields.each_with_index do |name, index|

      row_data_in_hif << name.output_data_in_hif

      if index == @name_fields.length - 1
        row_data_in_hif << ']'
      else
        row_data_in_hif << ', '
      end

    end
    
    # close "dynamic_field_data" open curly
    row_data_in_hif << '}'
    
    # close top-most open curly
    row_data_in_hif << '}'
    
    # puts 'Here is the row_data_in_hif'
    # puts row_data_in_hif
    return row_data_in_hif

  end

  def digital_object_data_to_csv(digital_object_data)

    return ''

  end

  def output_data_in_hif_old_version

    digital_object_data_results = '{'

    # create hif output for internal fields
    digital_object_data_results << internal_fields.output_data_in_hif

    # top-level fields
    digital_object_data_results << '"dynamic_field_data\"=>{'
    # create hif output for each top-level field.
    @top_level_fields.each do |key, top_level_field|

      digital_object_data_results << top_level_field.output_data_in_hif

      # add a comma and space
      digital_object_data_results << ', '

    end

    digital_object_data_results << '}'
    
    return digital_object_data_results

  end

  # this method figures out the dynamic field contained in the csv
  # it also handles the internal fields, such as pid, etc.
  def process_header_row_orig(headers)

    headers.each_with_index do |header, index|

      header.downcase!

      # ASSUMPTION: if there are multiple instances of a top-level field (for example, two names per row entry), then
      # the header entry for each instance will end with a unique number, for example name1:... and name2:...
      # ASSUMPTION: the internal fields will all start with an underscore(_)
      case

      # Handles internal fields
      when header.match(/^_/)

        # got an internal field
        @column_to_field_map[index] = @internal_fields.process_header(header)

      # handles the title top-level dynamic field
      when header.match(/(^title\d*)/)

        # create an ImportExportTitle instance (if doesn't exist yet) to store data
        @top_level_fields[$1] = Hyacinth::Utils::ImportExport::ImportExportTitle.new unless @top_level_fields.has_key?($1)
        # @title_field = Hyacinth::Utils::ImportExport::ImportExportTitle.new unless @top_level_fields.has_key?($1)
        @title_field = @top_level_fields[$1]

        # send header to instance, which will return attribute
        @column_to_field_map[index] = @top_level_fields[$1].process_header(header)

      # handles the name top-level dynamic field
      when header.match(/(^name\d*)/)

        
        # create an ImportExportTitle instance (if doesn't exist yet) to store data
        #@top_level_fields[$1] = Hyacinth::Utils::ImportExport::ImportExportName.new unless @top_level_fields.has_key?($1)
        if !(@top_level_fields.has_key?($1))
          @top_level_fields[$1] = Hyacinth::Utils::ImportExport::ImportExportName.new
          @name_fields << @top_level_fields[$1]
        end

        # send header to instance, which will processing method
        @column_to_field_map[index] = @top_level_fields[$1].process_header(header)

      # get here only if encountered unexpected header.
      else

        # probably want to throw an exeption here
        # and/or capture the header and the data in an "other" hash for investigation/remediation later
        nil

      end

    end

    # for now, just return true
    true

  end

end
