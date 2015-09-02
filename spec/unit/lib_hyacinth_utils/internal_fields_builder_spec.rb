require 'rails_helper'

RSpec.describe Hyacinth::Utils::InternalFieldsBuilder do

  def expect_internal_fields_instance_variables_are_all_empty_strings (arg_internal_field_builder)
    
    arg_internal_field_builder.internal_fields.each do |key, value|

      expect(value).to eq('')

    end
    
  end

  before(:context) do
    
  end

  before(:example) do
    
  end

  let(:internal_fields_builder) { Hyacinth::Utils::InternalFieldsBuilder.new }
  let(:sample_internal_fields_builder) {
    sample_internal_fields_builder = Hyacinth::Utils::InternalFieldsBuilder.new
    sample_internal_fields_builder.internal_fields["_pid"] = 'MyPid'
    sample_internal_fields_builder.internal_fields["_parent_pid"] = 'MyParentPid'
    sample_internal_fields_builder.internal_fields["_type"] = 'MyType'
    sample_internal_fields_builder.internal_fields["_identifier_for_import"] = 'MyIdentifierForImport'
    sample_internal_fields_builder.internal_fields["_parent_identifier_for_import"] = 'MyParentIdentifierForImport'
    sample_internal_fields_builder.internal_fields["_file_path"] = 'MyFilePath'
    sample_internal_fields_builder.internal_fields["_project"] = 'MyProject'
    sample_internal_fields_builder.internal_fields["_publish_target"] = 'MyPublishTarget'
    sample_internal_fields_builder
  }
  let!(:sample_internal_fields_as_json) {
    <<-END_OF_STRING
{
   "_pid":["MyPid"],
   "_parent_pid":["MyParentPid"],
   "_type":["MyType"],
   "_identifier_for_import":["MyIdentifierForImport"],
   "_parent_identifier_for_import":["MyParentIdentifierForImport"],
   "_file_path":["MyFilePath"],
   "_project":["MyProject"],
   "_publish_target":["MyPublishTarget"]
}
END_OF_STRING
  }
  # let(:title_as_hif_fixture) { JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/sample_title.json').read ) }
  # let(:title_as_csv_fixture) {fixture('lib/hyacinth/utils/csv_import_export/sample_title.csv').read }

  context "initialization" do

    it "create instance with no internal fields" do
      
      expect(internal_fields_builder.internal_fields).to eq({})

    end

  end

  context ".clear_all_data" do

    it "clears all the instance variables to empty strings" do

      sample_internal_fields_builder.clear_all_data

      expect_internal_fields_instance_variables_are_all_empty_strings sample_internal_fields_builder

    end

  end

  context ".process_header" do

    # Note: we may want to remove this check from the code once it has been debugged,
    # since the check for this assumption probably belongs in the calling code
    it "returns nil if the passed-in argument does not start with an underscore" do

      sample_header = "pid"
      result = internal_fields_builder.process_header(sample_header)
      expect(result).to eq(nil)

    end

    it "returns pid attribute setter when called with _pid as its argument" do

      sample_header = "_pid"
      result = internal_fields_builder.process_header(sample_header)
      expect(result.inspect).to eq('#<Method: Hyacinth::Utils::InternalFieldsBuilder#set__pid>')

    end

    it "returns publish_target attribute setter when called with _publish_target as its argument" do

      sample_header = "_publish_target"
      result = internal_fields_builder.process_header(sample_header)
      expect(result.inspect).to eq('#<Method: Hyacinth::Utils::InternalFieldsBuilder#set__publish_target>')

    end

  end

  context ".output_data_in_hif" do

    it "outputs all the instance variable values in a string in hif format" do
      
      # generated_output = '{' + sample_internal_fields_builder.output_data_in_hif + '}'
      generated_output = sample_internal_fields_builder.output_data_in_hif

      # puts generated_output
      # generate the hif format using JSON.parse
      internal_fields_as_hif_string = JSON.parse(sample_internal_fields_as_json)
      # puts internal_fields_as_hif_string

      expect(generated_output).to match("#{internal_fields_as_hif_string}")

    end

  end

end
