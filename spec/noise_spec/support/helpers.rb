module HelperMethods

  def expect_order_by(result, field)
    result.each_with_index do |model, index|
      if index < (@size - 1)
        next_model = @result[index + 1]
        expect(model.send(field)).to be > next_model.send(field)
      end
    end
  end

  # Put helper methods you need to be available in all acceptance specs here.
  def fixture_file(name)
    NoiseCore::Engine.root + "spec/fixtures/#{name}"
  end

  def login_as(username, role='reporter')
    page.set_rack_session(:user_id => username, :user_role => role)
  end

  def select_assert(elements_descriptor, *reg_exs)
    headers = page.all(elements_descriptor).map{|header| header.text}.flatten
    headers.select do |header|
      regexs.inject(true){ |bool, rx| %r!#{rx}!.match(header) && bool}
    end.count
  end

  # Preparation of the database for js (the database have to be prepared
  # in a different block because selenium and ActiveRecord do not share
  # the same thread
  # @return hash filled with Faker::Name.name
  def prepare_block
    category_name_1 = Faker::Name.name
    tag_name_1 = Faker::Name.name
    story_title_1 = Faker::Name.name
    area_name = Faker::Name.name
    block_name = Faker::Name.name

    category_1 = create_valid_category(name: category_name_1)
    tag_1 = create_valid_tag(name: tag_name_1)
    story_1 = create_published_story(title: story_title_1, category: category_1)
    ActsAsTaggableOn::Tagging.create(tag_id: tag_1.id, taggable_id: story_1.id, taggable_type: "Story", context: "tags")

    area = create_valid_shared_area(name: area_name)
    block = create_valid_block(name: block_name, sort_order: 'created_at ASC', content_type: "headlines")
    block.resume!
    area.blocks = [block]

    return {
      category_name_1: category_name_1,
      tag_name_1: tag_name_1,
      story_title_1: story_title_1,
      area_name: area_name,
      block_name: block_name
    }
  end
end

RSpec.configuration.include HelperMethods
