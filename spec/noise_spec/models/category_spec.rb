require 'spec_helper'

describe Category do

  it "can have a parent" do
    @royalty = create_valid_category(name: "Royalty")
    @british = create_valid_category(name: "Great Britain")
    @british.parent = @royalty

    @british.should be_valid
    @british.parent.should == @royalty
  end

  it "can not be its own parent" do
    @royalty = create_valid_category(name: "Royalty")
    @royalty.parent = @royalty

    @royalty.should_not be_valid
    @royalty.should have(1).error_on(:parent_id)
  end

  describe "document_type" do

    it "can be nil" do
      category = Category.new name: "Some category", document_type: nil
      category.should be_valid
    end

    it "should be unique" do
      create_valid_category(name: "Magazine 1", document_type: "magazine")

      invalid_category = Category.new name: "Magazine 2", document_type: "magazine"

      invalid_category.should_not be_valid
      invalid_category.should have(1).error_on(:document_type)
    end

    it "should have two choices: magazine, biography" do
      Category.document_type_choices.collect(&:last).sort.should == ["biography", "magazine"]
    end

  end

  describe ".not_reserved" do
    it "does not include categories with a default document type" do
      c1 = create_valid_category name: "Category 1", document_type: nil

      c2 = create_valid_category name: "Magazines", document_type: "magazine"
      c3 = create_valid_category name: "Biographies", document_type: "biography"

      Category.not_reserved.should_not include(c2)
      Category.not_reserved.should_not include(c3)

      Category.not_reserved.should include(c1)

    end
  end
  describe "default related page on creation" do
    it "has a related page after created" do
      category = create_valid_category
      category.page.should_not be_nil
    end
  end

  describe "#as_json" do
    let(:category) { create_valid_category }
    let(:category_as_json) { category.as_json }

    it "exposes its id" do
      category_as_json[:id].should == category.id
    end

    it "exposes its name" do
      category_as_json[:name].should == category.name
    end

    it 'exposes its path_slug as name for special childs' do
      special_parent_category = create_valid_category(name: "Parent Category")
      special_children_category = create_valid_category(parent_id: special_parent_category.id,
                                                        name: "Children Category")
      special_children_category.should_receive(:created_by_user).any_number_of_times.and_return(true)

      special_children_category_as_json = special_children_category.as_json
      special_children_category_as_json[:name].should == special_children_category.path_slug
    end
    
    it "exposes its path_slug" do
      category_as_json[:path_slug].should == category.path_slug
    end

    it "exposes its name_slug" do
      category_as_json[:name_slug].should == category.name.parameterize
    end
  end

  describe "#path_slug" do
    let(:parent_category) { create_valid_category(name: "Parent Category") }
    let(:children_category) { create_valid_category(parent_id: parent_category.id, name: "Children Category") }

    it "is the parameterized name for root categories" do
      parent_category.path_slug.should == parent_category.name.parameterize
    end

    it "includes the parameterized name of the parent for children categories" do
      children_category.path_slug.should == File.join(
        parent_category.name.parameterize,
        children_category.name.parameterize)
    end

    it 'removes the related subdomain from the slug for special child categories' do
      rel_subdomain = 'rel_subdomain'
      special_parent_category = create_valid_category(name: "Parent #{rel_subdomain} Category",
                                                      related_subdomain: rel_subdomain)
      special_children_category = create_valid_category(parent_id: special_parent_category.id,
                                                        name: "Children Category")
      
      special_children_category.path_slug.should == 'parent-category/children-category'
    end
  end
end
