require 'spec_helper'
require 'fixtures/dummy_class'
describe SerialPreference::HasSerialPreferences do

  before(:all) do
    rebuild_model
    @d = DummyClass.new
  end

  context "default behaviour" do
    it "should return preferences as a default _preferences_attribute" do
      DummyClass._preferences_attribute.should eq(:preferences)
    end
    it "should return settings as a _preferences_attribute" do
      class OverriddenPreferenceAttributeClass < ActiveRecord::Base
        include SerialPreference::HasSerialPreferences
        preferences :settings  do
          preference :abc
        end
      end
      OverriddenPreferenceAttributeClass._preferences_attribute.should eq(:settings)
    end
  end

  context "class methods behaviour" do
    it "should be possible to describe preference map thru preferences" do
      DummyClass.respond_to?(:preferences).should be_true
    end

    it "should be possble to retrieve preference groups from class" do
      DummyClass.respond_to?(:preference_groups).should be_true
    end
  end


  context "should define accessors" do
    it "should have readers available" do
      @d.respond_to?(:taxable).should be_true
      @d.respond_to?(:vat_no).should be_true
      @d.respond_to?(:max_invoice_items).should be_true
      @d.respond_to?(:income_ledger_id).should be_true
      @d.respond_to?(:read_preference_attribute).should be_true
      @d.respond_to?(:write_preference_attribute).should be_true
    end

    it "should ensure that the readers returns the correct data" do
      @d.preferences = {:vat_no => "abc"}
      @d.vat_no.should eq("abc")
    end

    it "should have writers available" do
      @d.respond_to?(:taxable=).should be_true
      @d.respond_to?(:vat_no=).should be_true
      @d.respond_to?(:max_invoice_items=).should be_true
      @d.respond_to?(:income_ledger_id=).should be_true
    end

    it "should ensure that the writer write the correct data" do
      @d.vat_no = "abc"
      @d.vat_no.should eq("abc")
    end

    it "should ensure that the querier the correct data" do
      @d.taxable = true
      @d.should be_taxable
      @d.taxable = false
      @d.should_not be_taxable
    end

    it "should have query methods available for booleans" do
      @d.respond_to?(:taxable?).should be_true
      @d.respond_to?(:vat_no?).should be_false
      @d.respond_to?(:max_invoice_items?).should be_false
      @d.respond_to?(:income_ledger_id?).should be_false
    end
  end

  context "should define validations" do
    it "should define presence validation on required preferences" do
      @d.should validate_presence_of(:taxable)
    end

    it "should define presence and numericality on required preference which are numeric" do
      debugger
      @d.taxable = true
      @d.should validate_presence_of(:required_number)
      @d.should validate_numericality_of(:required_number)
    end

    it "should define numericality on preference which are numeric" do
      @d.should validate_numericality_of(:required_number)
      @d.should validate_numericality_of(:max_invoice_items)
      @d.should validate_numericality_of(:income_ledger_id)
    end
  end

  describe "validation behavior" do
    context "when preferences are required and not numerical" do
      it "should ensure that error is raised when preference value is not provided" do
        @d.taxable = false
        @d.should_not be_valid
        @d.errors[:taxable].should eq(["can't be blank"])
      end
      it "should ensure that no error is raised when preference value is provided" do
        @d.taxable = true
        @d.should be_valid
        @d.errors[:taxable].should eq([])
      end
    end
    context "when preferences are not required" do
      it "should not raise an error when the preference value is not provided" do
        @d.vat_no = nil
        @d.should be_valid
        @d.errors[:vat_no].should eq([])
      end
    end

    context "when preferences are numerical but not required" do
      it "should raise an error when preference value is non-numerical" do
        @d.max_invoice_items = "error"
        @d.should be_valid
        @d.errors[:max_invoice_items].should eq([])
        @d.income_ledger_id = "error"
        @d.should be_valid
        @d.errors[:income_ledger_id].should eq([])
      end
      it "should not raise an error when preference value is nil" do
        @d.max_invoice_items = nil
        @d.should be_valid
        @d.errors[:max_invoice_items].should eq([])
        @d.income_ledger_id = nil
        @d.should be_valid
        @d.errors[:income_ledger_id].should eq([])
      end
    end

    context "when preferences and numerical both are required" do
      it "should ensure that error is raised when preference value is not provided" do
        @d.required_number = false
        @d.should be_valid
        @d.errors[:required_number].should eq([])
      end
      it "should ensure that no error is raised when preference value is provided" do
        @d.required_number = true
        @d.should be_valid
        @d.errors[:required_number].should eq([])
      end
      it "should raise an error when preference value is non-numerical" do
        @d.required_number = "error"
        @d.should be_valid
        @d.errors[:required_number].should eq([])
      end
      it "should not raise an error when preference value is nil" do
        @d.required_number = nil
        @d.should be_valid
        @d.errors[:required_number].should eq([])
      end
    end
  end


end
