require 'rails_helper'

RSpec.describe 'Hyacinth::Utils::CsvImportExportUtilsUsingBuilders' do

  before(:context) do
    
  end

  before(:example) do
    
  end

  let(:sample_header_row) {
    array = %w(_pid _parent_pid _parent_pid _type _identifier_for_import _parent_identifier_for_import
              _parent_identifier_for_import _file_path _project _publish_target _publish_target
              title:title_non_sort_portion title:title_sort_portion
              name1:name_value name:name_value_uri name1:name_role:name_role_value name1:name_role:name_role_type)
    }
  let(:sample_header_row_one_name_one_name_role) {
    array = %w(name1:name_value name1:name_value_uri name1:name_role1:name_role_value name1:name_role1:name_role_type) 
    }
  let(:sample_header_row_one_name_two_name_roles) {
    array = %w(name1:name_value name1:name_value_uri name1:name_role1:name_role_value name1:name_role1:name_role_type
               name1:name_role2:name_role_value name1:name_role2:name_role_type )
    }
  let!(:sample_header_row_one_name_two_name_roles_with_data) {
    <<-END_OF_STRING
Name1 :name_value,Name1 :name_value_uri,name1:name_role1:name_role_value,name1:name_role1:name_role_type,name1:name_role2:name_role_value,name1:name_role2:name_role_type
name1:name_value,name1:name_value_uri,name1:name_role1:name_role_value,name1:name_role1:name_role_type,name1:name_role2:name_role_value,name1:name_role2:name_role_type
MyName1Value,MyName1ValueURI,MyName1NameRole1Value,MyName1NameRole1Type,MyName1NameRole2Value,MyName1NameRole2Type
END_OF_STRING
    }
  let!(:sample_header_row_internal_fields_and_one_name_two_name_roles_with_data) {
<<END_OF_STRING
PID,Project,Name1 :name_value,Name1 :name_value_uri,name1:name_role1:name_role_value,name1:name_role1:name_role_type,name1:name_role2:name_role_value,name1:name_role2:name_role_type
_pid,_project,name1:name_value,name1:name_value_uri,name1:name_role1:name_role_value,name1:name_role1:name_role_type,name1:name_role2:name_role_value,name1:name_role2:name_role_type
CUL:314159, MyCoolProject,MyName1Value,MyName1ValueURI,MyName1NameRole1Value,MyName1NameRole1Type,MyName1NameRole2Value,MyName1NameRole2Type
END_OF_STRING
    }
  let(:csv_import_export_using_builders_engine) { Hyacinth::Utils::CsvImportExportUtilsUsingBuilders.new }
  let(:digital_object_data_fixture) { JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/sample_record.json').read ) }
  let(:csv_fixture) {fixture('lib/hyacinth/utils/csv_import_export/sample_record.csv').read }
  let(:simplified_sample_record_title_name_csv_fixture) {
    fixture('lib/hyacinth/utils/csv_import_export/simplified_sample_record_title_name.csv').read }
  let(:hif_title_multi_name_multi_role) { 
    JSON.parse( fixture('lib/hyacinth/utils/csv_import_export/sample_record_title_multi_name_multi_role.json').read )
    }
  let(:csv_title_multi_name_multi_role) { 
    fixture('lib/hyacinth/utils/csv_import_export/sample_record_title_multi_name_multi_role.csv').read 
    }

  context "#process_header_row" do

    it "builds a name dynamic field group using headers for one name containing one name_role" do

      puts "builds a name dynamic field group using headers for one name containing one name_role"

      csv_import_export_using_builders_engine.process_header_row sample_header_row_one_name_one_name_role

      csv_import_export_using_builders_engine.inspect_top_level_fields

    end

    it "builds a name dynamic field group using headers for one name containing two name_roles" do

      puts "builds a name dynamic field group using headers for one name containing two name_roles"

      csv_import_export_using_builders_engine.process_header_row sample_header_row_one_name_two_name_roles

      csv_import_export_using_builders_engine.inspect_top_level_fields

    end

  end
  
  context "#csv_to_digital_object_data" do

    xit "converts properly" do
      
      digital_object_data = 
        csv_import_export_using_builders_engine.csv_to_digital_object_data(sample_header_row_one_name_two_name_roles_with_data.to_s)
      # expect(digital_object_data).to eq(digital_object_data_fixture)

      puts 'here is the result of inspect after calling #csv_to_digital_object_data'
      puts csv_import_export_using_builders_engine.top_level_field_groups["name1"].inspect

      puts 'here is the digital object data'
      puts digital_object_data

    end

    it "builds a name dynamic field group using headers for two internal fields, one name containing two name_roles" do

      digital_object_data = 
        csv_import_export_using_builders_engine.csv_to_digital_object_data(sample_header_row_internal_fields_and_one_name_two_name_roles_with_data.to_s)

      puts 'here is the result of inspect on internal fields after calling #csv_to_digital_object_data'
      puts csv_import_export_using_builders_engine.internal_fields.inspect

      puts 'here is the result of inspect on the dynamic fields after calling #csv_to_digital_object_data'
      puts csv_import_export_using_builders_engine.top_level_field_groups["name1"].inspect

      puts 'here is the digital object data'
      puts digital_object_data

    end


  end
  
  xcontext ".process_data_rows" do

    it "converts properly csv with single title and multi namea and multi roles" do

      puts "Here is the sample digital_object_data (fixture)"
      puts hif_title_multi_name_multi_role
      
      
      digital_object_data = csv_import_export_engine.csv_to_digital_object_data(csv_title_multi_name_multi_role)
      puts "Here is the generated digital_object_data"
      puts digital_object_data
      expect(digital_object_data).to eq("#{hif_title_multi_name_multi_role}")

    end

  end
  
  xcontext ".process_data_headers" do
    it "converts properly" do
      # puts sample_header_row.inspect
      csv_import_export_engine.process_header_row(sample_header_row)
      # puts csv_import_export_engine.column_to_attribute_map
      # expect(digital_object_data).to eq(digital_object_data_fixture)

    end
  end
  
  xcontext ".csv_to_digital_object_data" do
    it "converts properly" do
      
      digital_object_data = csv_import_export_engine.csv_to_digital_object_data(csv_fixture)
      expect(digital_object_data).to eq(digital_object_data_fixture)

    end
  end
  
  xcontext ".digital_object_data_to_csv" do

    it "converts properly" do
      
      expect(1).to eq(1)

    end

  end

end
