require 'rails_helper'

RSpec.describe 'Hyacinth::Utils::CsvImportExportUtilsUsingBuilders' do

  before(:context) do

    @sample_header_row_as_array_one_name_one_name_role =
      %w(name1:name_value name1:name_value_uri name1:name_role1:name_role_value name1:name_role1:name_role_type) 

    @sample_header_row_as_array_one_name_two_name_roles = 
      %w(name1:name_value name1:name_value_uri name1:name_role1:name_role_value name1:name_role1:name_role_type
               name1:name_role2:name_role_value name1:name_role2:name_role_type )

    @sample_data_row_as_array_one_name_two_name_roles = 
      %w(MyName1Value MyName1ValueURI MyName1NameRole1Value MyName1NameRole1Type MyName1NameRole2Value MyName1NameRole2Type)

    @sample_header_row_as_array =
      %w(_pid _parent_pid _parent_pid _type _identifier_for_import _parent_identifier_for_import
         _parent_identifier_for_import _file_path _project _publish_target _publish_target
         title:title_non_sort_portion title:title_sort_portion
         name1:name_value name:name_value_uri name1:name_role:name_role_value name1:name_role:name_role_type)

    @csv_import_engine = Hyacinth::Utils::CsvImportExportUtilsUsingBuilders.new

    @sample_header_data_rows_internal_fields_and_one_name_two_name_roles =
<<END_OF_STRING
PID,Project,Name1 :name_value,Name1 :name_value_uri,name1:name_role1:name_role_value,name1:name_role1:name_role_type,name1:name_role2:name_role_value,name1:name_role2:name_role_type
_pid,_project,name1:name_value,name1:name_value_uri,name1:name_role1:name_role_value,name1:name_role1:name_role_type,name1:name_role2:name_role_value,name1:name_role2:name_role_type
CUL:314159, MyCoolProject,MyName1Value,MyName1ValueURI,MyName1NameRole1Value,MyName1NameRole1Type,MyName1NameRole2Value,MyName1NameRole2Type
END_OF_STRING


  end

  before(:example) do
    
  end

  let!(:sample_header_data_rows_one_name_two_name_roles) {
    <<-END_OF_STRING
Name1 :name_value,Name1 :name_value_uri,name1:name_role1:name_role_value,name1:name_role1:name_role_type,name1:name_role2:name_role_value,name1:name_role2:name_role_type
name1:name_value,name1:name_value_uri,name1:name_role1:name_role_value,name1:name_role1:name_role_type,name1:name_role2:name_role_value,name1:name_role2:name_role_type
MyName1Value,MyName1ValueURI,MyName1NameRole1Value,MyName1NameRole1Type,MyName1NameRole2Value,MyName1NameRole2Type
END_OF_STRING
    }

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

  describe "uses #process_header_row" do

    before(:context) do
      @csv_import_engine.process_header_row @sample_header_row_as_array_one_name_two_name_roles
      @name_builder = @csv_import_engine.top_level_dynamic_field_group_builders['name1']
      @name_role_builder_1 = @name_builder.child_field_groups['name_role1']
      @name_role_builder_2 = @name_builder.child_field_groups['name_role2']
    end

    context "with sample header (one name with two name roles) to build a DynamicFieldGroupBuilder (DFGB) for the name and two child DFGB, one for each of the two name roles." do

      before(:example) do

      end

      it "It has just one item in the top-level DFGB hash" do
        expect(@csv_import_engine.top_level_dynamic_field_group_builders.length).to eq(1)
      end

      it "The top-level DFGB is at hash key name1" do
        expect(@csv_import_engine.top_level_dynamic_field_group_builders).to have_key('name1')
      end

      it "The top-level DFGB is an instance of Hyacinth::Utils::DynamicFieldGroupBuilder" do
        expect(@csv_import_engine.top_level_dynamic_field_group_builders['name1']).to be_kind_of(Hyacinth::Utils::DynamicFieldGroupBuilder)
      end
      
      it "The top-level dynamic field group has two child fields" do
        expect(@name_builder.child_fields.length).to eq(2)
      end

      it "The top-level dynamic field group has a child field called name_value" do
        expect(@name_builder.child_fields).to have_key('name_value')
      end

      it "The top-level dynamic field group has a child field called name_value_uri" do
        expect(@name_builder.child_fields).to have_key('name_value_uri')
      end

      it "Top level DFG  should have two child field groups" do
        expect(@name_builder.child_field_groups.length).to eq(2)
      end

      it "Top level DFG  should have one child field group called name_role1" do
        expect(@name_builder.child_field_groups).to have_key('name_role1')
      end

      it "Top level DFG  should have one child field group of type DynamicFieldGroupBuilder" do
        expect(@name_builder.child_field_groups['name_role1']).to be_kind_of(Hyacinth::Utils::DynamicFieldGroupBuilder)
      end

      it "Child DFG should have two child field values" do
        expect(@name_role_builder_1.child_fields.length).to eq(2)
      end

      it "Child DFG should have one child field called name_role_value" do
        expect(@name_role_builder_1.child_fields).to have_key('name_role_value')
      end

      it "Child DFG should have one child field value called name_role_type" do
        expect(@name_role_builder_1.child_fields).to have_key('name_role_type')
      end

      it "Top level DFG  should have one child field group called name_role2" do
        expect(@name_builder.child_field_groups).to have_key('name_role2')
      end

      it "Top level DFG  should have one child field group of type DynamicFieldGroupBuilder" do
        expect(@name_builder.child_field_groups['name_role2']).to be_kind_of(Hyacinth::Utils::DynamicFieldGroupBuilder)
      end

      it "Child DFG should have two child field values" do
        expect(@name_role_builder_2.child_fields.length).to eq(2)
      end

      it "Child DFG should have one child field called name_role_value" do
        expect(@name_role_builder_2.child_fields).to have_key('name_role_value')
      end

      it "Child DFG should have one child field value called name_role_type" do
        expect(@name_role_builder_2.child_fields).to have_key('name_role_type')
      end

    end

  end

  # Remember that before processing a data row, you need to process the headers
  describe "uses #process_data_rows" do

    before(:context) do
      @csv_import_engine.process_header_row @sample_header_row_as_array_one_name_two_name_roles
      @csv_import_engine.process_data_row @sample_data_row_as_array_one_name_two_name_roles
      @name_builder = @csv_import_engine.top_level_dynamic_field_group_builders['name1']
      @name_role_builder_1 = @name_builder.child_field_groups['name_role1']
      @name_role_builder_2 = @name_builder.child_field_groups['name_role2']
    end

    before(:example) do


    end

    # Remove following, just here so I can see the expected values
    # array = %w(MyName1Value,MyName1ValueURI,MyName1NameRole1Value,MyName1NameRole1Type,MyName1NameRole2Value,MyName1NameRole2Type)

    context "with sample header (one name with two name roles) and data information to create DFGs and pouplated these DFGs with the supplied data." do

      it "Top level name DGF has the correct value for name_value" do
        expect(@name_builder.child_fields['name_value']).to eq('MyName1Value')
      end
      
      it "Top level name DGF has the correct value for name_value_uri" do
        expect(@name_builder.child_fields['name_value_uri']).to eq('MyName1ValueURI')
      end
      
      it "First child DFG has the correct alue for name_role_value" do
        expect(@name_role_builder_1.child_fields['name_role_value']).to eq('MyName1NameRole1Value')
      end
      
      it "First child DFG has the correct alue for name_role_type" do
        expect(@name_role_builder_1.child_fields['name_role_type']).to eq('MyName1NameRole1Type')
      end
      
      it "Second child DFG has the correct alue for name_role_value" do
        expect(@name_role_builder_2.child_fields['name_role_value']).to eq('MyName1NameRole2Value')
      end

      it "Second child DFG has the correct alue for name_role_type" do
        expect(@name_role_builder_2.child_fields['name_role_type']).to eq('MyName1NameRole2Type')
      end
      
    end

  end
  
  describe "uses #csv_to_digital_object_data" do

    before(:context) do
      @digital_object_data = 
        @csv_import_engine.csv_to_digital_object_data(@sample_header_data_rows_internal_fields_and_one_name_two_name_roles)
      @name_builder = @csv_import_engine.top_level_dynamic_field_group_builders['name1']
      @name_role_builder_1 = @name_builder.child_field_groups['name_role1']
      @name_role_builder_2 = @name_builder.child_field_groups['name_role2']
    end

    context "with sample CSV (header and data for one name contaning two name roles) to create and populate the DFGs correctly. Check structure and data of DFGs" do

      it "It has just one item in the top-level DFGB hash" do
        expect(@csv_import_engine.top_level_dynamic_field_group_builders.length).to eq(1)
      end

      it "The top-level DFGB is at hash key name1" do
        expect(@csv_import_engine.top_level_dynamic_field_group_builders).to have_key('name1')
      end

      it "The top-level DFGB is an instance of Hyacinth::Utils::DynamicFieldGroupBuilder" do
        expect(@csv_import_engine.top_level_dynamic_field_group_builders['name1']).to be_kind_of(Hyacinth::Utils::DynamicFieldGroupBuilder)
      end
      
      it "The top-level dynamic field group has two child fields" do
        expect(@name_builder.child_fields.length).to eq(2)
      end

      it "The top-level dynamic field group has a child field called name_value" do
        expect(@name_builder.child_fields).to have_key('name_value')
      end

      it "The top-level dynamic field group has a child field called name_value_uri" do
        expect(@name_builder.child_fields).to have_key('name_value_uri')
      end

      it "Top level DFG  should have two child field groups" do
        expect(@name_builder.child_field_groups.length).to eq(2)
      end

      it "Top level DFG  should have one child field group called name_role1" do
        expect(@name_builder.child_field_groups).to have_key('name_role1')
      end

      it "Top level DFG  should have one child field group of type DynamicFieldGroupBuilder" do
        expect(@name_builder.child_field_groups['name_role1']).to be_kind_of(Hyacinth::Utils::DynamicFieldGroupBuilder)
      end

      it "Child DFG should have two child field values" do
        expect(@name_role_builder_1.child_fields.length).to eq(2)
      end

      it "Child DFG should have one child field called name_role_value" do
        expect(@name_role_builder_1.child_fields).to have_key('name_role_value')
      end

      it "Child DFG should have one child field value called name_role_type" do
        expect(@name_role_builder_1.child_fields).to have_key('name_role_type')
      end

      it "Top level DFG  should have one child field group called name_role2" do
        expect(@name_builder.child_field_groups).to have_key('name_role2')
      end

      it "Top level DFG  should have one child field group of type DynamicFieldGroupBuilder" do
        expect(@name_builder.child_field_groups['name_role2']).to be_kind_of(Hyacinth::Utils::DynamicFieldGroupBuilder)
      end

      it "Child DFG should have two child field values" do
        expect(@name_role_builder_2.child_fields.length).to eq(2)
      end

      it "Child DFG should have one child field called name_role_value" do
        expect(@name_role_builder_2.child_fields).to have_key('name_role_value')
      end

      it "Child DFG should have one child field value called name_role_type" do
        expect(@name_role_builder_2.child_fields).to have_key('name_role_type')
      end

    end

  end
  
  xcontext ".csv_to_digital_object_data" do
    it "converts properly" do
      
      digital_object_data = csv_import_engine.csv_to_digital_object_data(csv_fixture)
      expect(digital_object_data).to eq(digital_object_data_fixture)

    end
  end
  
  xcontext ".digital_object_data_to_csv" do

    it "converts properly" do
      
      expect(1).to eq(1)

    end

  end

end
