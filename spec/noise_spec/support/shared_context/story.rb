# Create a story context with all kind of stories for two users
RSpec.shared_context "all kinds of stories" do
  let(:user) { double('user', id: 'user') }
  let(:other_user) { double('user', id: 'other_user') }

  before(:each) do
    @size = 2 # number of stories by type
    @published_by_user =
      create_list :published_story, @size, creator: user.id
    @drafts_by_user =
      create_list :draft_story, @size, creator: user.id
    @published_by_other_user =
      create_list :published_story, @size, creator: other_user.id
    @drafts_by_other_user =
      create_list :draft_story, @size, creator: other_user.id
  end

  def all_drafts
    @drafts_by_user.to_a + @drafts_by_other_user.to_a
  end

  def all_published
    @published_by_user.to_a + @published_by_other_user.to_a
  end
end
