FactoryGirl.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }

    trait :with_subdomain do
      sequence(:related_subdomain) { |n| "subdomain_#{n}" }
      created_by_user true
    end
    trait :home do
      name 'home'
    end
  end

  factory :categorisation do
    after(:build) do |categorisation|
      categorisation.category ||= build(:category)
    end
  end

  factory :story do
    sequence(:title) { |n| "Title for story #{n}" }
    sequence(:body) { |n| "<body><p>Title for story #{n}</p></body>" }
    sequence(:excerpt) { |n| "Excerpt for story #{n}" }

    after(:build) do |story|
      story.categorisation ||= build(:categorisation, story: story)
    end
    trait :draft do
      published_at nil
    end
    trait :published do
      published_at { rand(1..100).days.ago }
    end

    factory :draft_story, traits: [:draft]
    factory :published_story, traits: [:published]
  end

  factory :template do
    sequence(:name) { |n| "Template #{n}" }

    trait :category_page do
      name 'Category Page'
    end
    factory :default_tag_page_template do
      name 'Default Tag Page'
    end
    factory :tag_page_template do
      name 'Tag Page'
    end
    trait :home_page do
      name 'Home Page'
    end
  end

  factory :tag, class: ActsAsTaggableOn::Tag do
    sequence(:name) { |n| "tag_#{n}" }
  end

  # basic page is a "regular_page"
  factory :page do
    sequence(:slug) { |n| "slug_#{n}" }
    sequence(:title) { |n| "Page title #{n}" }
    association :template, factory: [:template, :category_page]

    trait :slug_home do
      slug 'home'
    end

    factory :category_page do
      before(:create) do |page, _|
        page.template = Template.default_category_template ||
          create(:template, :category_page)
      end
    end
    factory :tag_page do
      before(:create) do |page, _|
        page.pageable = create(:tag)
        page.template = Template.tag_page_template ||
          create(:template, :tag_page)
      end
    end
    factory :default_tag_page do
      before(:create) do |page, _|
        page.template = Template.tag_page_template ||
          create(:default_tag_page_template)
      end
    end
  end
end
