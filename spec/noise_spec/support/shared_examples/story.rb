[:updated_at, :published_at].each do |criteria|
  shared_examples_for "sorted list by #{criteria} in descending order" do
    it "returns items ordered by #{criteria} desc" do
      expect_order_by @result, criteria
    end
  end
end
