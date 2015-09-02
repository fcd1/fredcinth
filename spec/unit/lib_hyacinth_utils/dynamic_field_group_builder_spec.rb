require 'rails_helper'

RSpec.describe Hyacinth::Utils::DynamicFieldGroupBuilder do

  # This helper method checks to see if the passed-in dynamic_field_group_builder instance data
  # have been intialized/reset to the expected values -- note: assumes no arguments where supplie
  # when the DynamicFieldGroupBuilder instance was created
  def expect_new_dynamic_field_group_builder_instance_to_be_initialized (dynamic_field_group_builder)

    expect(dynamic_field_group_builder.name).to eq('')
    expect(dynamic_field_group_builder.parent).to eq(false)
    expect(dynamic_field_group_builder.child_fields).to eq({})
    expect(dynamic_field_group_builder.child_field_groups).to eq({})
    expect(dynamic_field_group_builder.child_dynamic_field_groups_by_type).to eq({})

  end

  before(:context) do
    
  end

  before(:example) do
    
  end

  let(:dynamic_field_group_builder) { Hyacinth::Utils::DynamicFieldGroupBuilder.new}

  let(:name_dfg_builder) { Hyacinth::Utils::DynamicFieldGroupBuilder.new "name"}

  let(:sample_name_dfg_in_hif) {
<<END_OF_STRING
{"name_role"=>[{"name_role_type"=>"MyName1NameRoleType", "name_role_value"=>"MyName1NameRoleValue"}, {"name_role_type"=>"MyName2NameRoleType", "name_role_value"=>"MyName2NameRoleValue"}]}
END_OF_STRING
    }

  context "initialization" do

    it "create instance with empty attributes" do

      expect_new_dynamic_field_group_builder_instance_to_be_initialized(dynamic_field_group_builder)
      
    end

  end

  # fcd1, 08/28/15: Cleaned up
  context "#add_child_field" do

    it "creates internal method to set given child field, and returns pointer to said method which can be used to set value of child field" do

      array_of_set_methods = []
      
      array_of_set_methods[0] = name_dfg_builder.add_child_field "name_type"
      array_of_set_methods[1] = name_dfg_builder.add_child_field "name_value"
      array_of_set_methods[2] = name_dfg_builder.add_child_field "name_value_uri"
      array_of_set_methods[3] = name_dfg_builder.add_child_field "name_authority"
      array_of_set_methods[4] = name_dfg_builder.add_child_field "name_authority_uri"


      array_of_set_methods[0].call "normal"
      array_of_set_methods[1].call "Smith, John"
      array_of_set_methods[2].call "Name Value URI for John Smith"
      array_of_set_methods[3].call "Name Authority for John Smith"
      array_of_set_methods[4].call "Name Authority URI for John Smith"

      expect(name_dfg_builder.child_fields["name_type"]).to eq("normal")
      expect(name_dfg_builder.child_fields["name_value"]).to eq("Smith, John")
      expect(name_dfg_builder.child_fields["name_value_uri"]).to eq("Name Value URI for John Smith")
      expect(name_dfg_builder.child_fields["name_authority"]).to eq("Name Authority for John Smith")
      expect(name_dfg_builder.child_fields["name_authority_uri"]).to eq("Name Authority URI for John Smith")

    end

  end

  context "#process_header_row" do

    it "processes a sample header with name, name_role" do

      array_of_set_methods = []
      
      # Remove top-level dynamic field group from header, since it has already been created
      array_of_set_methods[0] = name_dfg_builder.process_header "name_role1:name_role_type"
      array_of_set_methods[1] = name_dfg_builder.process_header "name_role1:name_role_value"
      array_of_set_methods[2] = name_dfg_builder.process_header "name_role2:name_role_type"
      array_of_set_methods[3] = name_dfg_builder.process_header "name_role2:name_role_value"
      
      array_of_set_methods[0].call "This is the role type for the first role"
      array_of_set_methods[1].call "This is the role value for the first role"
      array_of_set_methods[2].call "This is the role type for the second role"
      array_of_set_methods[3].call "This is the role value for the second role"

      expect(name_dfg_builder.child_field_groups["name_role1"].child_fields["name_role_type"]).to eq("This is the role type for the first role")
      expect(name_dfg_builder.child_field_groups["name_role1"].child_fields["name_role_value"]).to eq("This is the role value for the first role")
      expect(name_dfg_builder.child_field_groups["name_role2"].child_fields["name_role_type"]).to eq("This is the role type for the second role")
      expect(name_dfg_builder.child_field_groups["name_role2"].child_fields["name_role_value"]).to eq("This is the role value for the second role")

    end

  end

  context "#clear_all_data" do

    it "clears the data in a sample DynamicFieldGroupBuilder" do

      name_dfg_builder.process_header "name_role1:name_role_type"
      name_dfg_builder.process_header "name_role1:name_role_value"
      name_dfg_builder.process_header "name_role2:name_role_type"
      name_dfg_builder.process_header "name_role2:name_role_value"
      
      # populate sample data for each sample header
      name_dfg_builder.child_field_groups["name_role1"].child_fields["name_role_type"] = "MyName1NameRoleType"
      name_dfg_builder.child_field_groups["name_role1"].child_fields["name_role_value"] = "MyName1NameRoleValue"
      name_dfg_builder.child_field_groups["name_role2"].child_fields["name_role_type"] = "MyName2NameRoleType"
      name_dfg_builder.child_field_groups["name_role2"].child_fields["name_role_value"] = "MyName2NameRoleValue"

      name_dfg_builder.clear_all_data

      expect(name_dfg_builder.child_field_groups["name_role1"].child_fields["name_role_type"]).to eq('')
      expect(name_dfg_builder.child_field_groups["name_role1"].child_fields["name_role_value"]).to eq('')
      expect(name_dfg_builder.child_field_groups["name_role2"].child_fields["name_role_type"]).to eq('')
      expect(name_dfg_builder.child_field_groups["name_role2"].child_fields["name_role_value"]).to eq('')

    end

  end

  context "#output_data_in_hif" do

    it "prints the data in a sample DynamicFieldGroupBuilder" do

      # Remove top-level dynamic field group from header, since it has already been created
      name_dfg_builder.process_header "name_role1:name_role_type"
      name_dfg_builder.process_header "name_role1:name_role_value"
      name_dfg_builder.process_header "name_role2:name_role_type"
      name_dfg_builder.process_header "name_role2:name_role_value"
      
      # populate sample data for each sample header
      name_dfg_builder.child_field_groups["name_role1"].child_fields["name_role_type"] = "MyName1NameRoleType"
      name_dfg_builder.child_field_groups["name_role1"].child_fields["name_role_value"] = "MyName1NameRoleValue"
      name_dfg_builder.child_field_groups["name_role2"].child_fields["name_role_type"] = "MyName2NameRoleType"
      name_dfg_builder.child_field_groups["name_role2"].child_fields["name_role_value"] = "MyName2NameRoleValue"

      expect(name_dfg_builder.output_data_in_hif).to eq("#{sample_name_dfg_in_hif.chomp}")

    end

  end

end
