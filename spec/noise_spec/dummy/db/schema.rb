# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140902030405) do

  create_table "areas", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.boolean  "shared",                         :default => false
    t.boolean  "changed_since_last_publication", :default => true
  end

  create_table "block_containers", :force => true do |t|
    t.integer  "block_id"
    t.integer  "area_id"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "block_containers", ["area_id"], :name => "index_block_containers_on_area_id"
  add_index "block_containers", ["block_id"], :name => "index_block_containers_on_block_id"
  add_index "block_containers", ["position"], :name => "index_block_containers_on_position"

  create_table "blocks", :force => true do |t|
    t.string   "sort_order"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.integer  "position"
    t.integer  "headline_limit"
    t.text     "html_code"
    t.string   "status",         :limit => 25, :default => "suspended"
    t.string   "name"
    t.string   "content_type"
    t.string   "style_hint"
    t.boolean  "shared",                       :default => false
    t.boolean  "enabled",                      :default => true
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at",                                                                              :null => false
    t.datetime "updated_at",                                                                              :null => false
    t.integer  "area_id"
    t.boolean  "created_by_user",     :default => false
    t.string   "comments_status"
    t.string   "pageid"
    t.string   "pageid_name"
    t.string   "story_pageid"
    t.string   "story_pageid_name"
    t.string   "gallery_pageid"
    t.string   "gallery_pageid_name"
    t.string   "publicity_formats",   :default => "---\n- top_990x90:4874\n- robapaginas_300x250:4875\n"
    t.string   "document_type"
    t.string   "related_subdomain"
  end

  add_index "categories", ["document_type"], :name => "index_categories_on_document_type", :unique => true

  create_table "categorisations", :force => true do |t|
    t.integer  "category_id"
    t.integer  "story_id"
    t.boolean  "primary",     :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "categorisations", ["category_id"], :name => "index_categorisations_on_category_id"
  add_index "categorisations", ["story_id"], :name => "index_categorisations_on_story_id"

  create_table "containers", :force => true do |t|
    t.integer  "area_id"
    t.integer  "region_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "position"
  end

  create_table "crops", :force => true do |t|
    t.string   "usage"
    t.integer  "top"
    t.integer  "left"
    t.integer  "width"
    t.integer  "height"
    t.integer  "image_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "crops", ["image_id"], :name => "index_crops_on_image_id"

  create_table "editorial_versions", :force => true do |t|
    t.text     "title"
    t.text     "excerpt"
    t.text     "body"
    t.integer  "story_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "type_version"
    t.text     "subtitle"
  end

  create_table "headline_sources", :force => true do |t|
    t.integer  "block_id"
    t.integer  "sourceable_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "sourceable_type"
  end

  create_table "headlines", :force => true do |t|
    t.text     "title"
    t.text     "excerpt"
    t.integer  "container_id"
    t.integer  "story_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "url"
    t.integer  "position"
    t.boolean  "open_in_new_window"
    t.boolean  "linked",             :default => false
    t.string   "secondary_url"
    t.datetime "story_published_at"
    t.string   "container_type"
  end

  add_index "headlines", ["container_id"], :name => "index_headlines_on_headline_block_id"
  add_index "headlines", ["story_id"], :name => "index_headlines_on_story_id"

  create_table "images", :force => true do |t|
    t.text     "caption"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "attachable_id"
    t.string   "attachment_uid"
    t.string   "attachment_name"
    t.integer  "position"
    t.string   "attachable_type"
    t.text     "agency"
    t.text     "author"
    t.datetime "expires_at"
    t.text     "usage_rights"
  end

  create_table "pages", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.integer  "pageable_id"
    t.datetime "created_at",                                                                              :null => false
    t.datetime "updated_at",                                                                              :null => false
    t.string   "pageable_type"
    t.integer  "template_id"
    t.text     "excerpt"
    t.string   "pageid"
    t.string   "pageid_name"
    t.string   "story_pageid"
    t.string   "story_pageid_name"
    t.string   "gallery_pageid"
    t.string   "gallery_pageid_name"
    t.text     "publicity_formats",   :default => "---\n- top_990x90:4874\n- robapaginas_300x250:4875\n"
  end

  create_table "properties", :force => true do |t|
    t.text     "value"
    t.integer  "story_id"
    t.integer  "property_type_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "property_type_translations", :force => true do |t|
    t.integer  "property_type_id", :null => false
    t.string   "locale",           :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "name"
  end

  add_index "property_type_translations", ["locale"], :name => "index_property_type_translations_on_locale"
  add_index "property_type_translations", ["property_type_id"], :name => "index_property_type_translations_on_property_type_id"

  create_table "property_types", :force => true do |t|
    t.string   "story_type"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "data_type",  :default => "string"
    t.boolean  "searchable", :default => false
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.integer  "template_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "page_id"
  end

  create_table "related_stories", :force => true do |t|
    t.integer "story_id"
    t.integer "relatable_id"
    t.string  "relatable_type", :default => "Story"
    t.integer "position"
  end

  create_table "seo_elements", :force => true do |t|
    t.integer  "metadatable_id"
    t.text     "meta_title"
    t.text     "meta_description"
    t.text     "meta_keywords"
    t.text     "url_base"
    t.text     "redirection"
    t.text     "canonical"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "metadatable_type"
  end

  create_table "stories", :force => true do |t|
    t.text     "title"
    t.text     "excerpt"
    t.text     "body"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "story_type",          :default => "NewsStory"
    t.datetime "published_at"
    t.integer  "area_id"
    t.string   "title_slug"
    t.datetime "first_published_at"
    t.integer  "story_template_id"
    t.string   "slug"
    t.text     "subtitle"
    t.string   "comments_status"
    t.string   "pageid"
    t.string   "pageid_name"
    t.integer  "story_id"
    t.string   "gallery_pageid"
    t.string   "gallery_pageid_name"
    t.text     "publicity_formats"
    t.text     "image_agency"
    t.text     "image_author"
    t.datetime "image_expires_at"
    t.text     "image_usage_rights"
    t.string   "creator"
  end

  create_table "story_templates", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "filename"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tag_headlines", :force => true do |t|
    t.integer  "tagging_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "image_caption"
    t.integer  "story_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
