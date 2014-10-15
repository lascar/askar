require 'spec_helper'

describe BlockContainer do

  before(:each) do
    @block = create_valid_block(shared: false)
  end

  describe "position" do

    it "sets its position to the maximum position + 1, when created" do
      @block1 = create_valid_block(shared: false)
      @block2 = create_valid_block(shared: false)

      @area = create_valid_area

      block_container1 = @block1.block_containers.create!(area_id: @area.id)
      block_container1.position.should == 1
      block_container2 = @block2.block_containers.create!(area_id: @area.id)
      block_container2.position.should == 2
    end

  end

  describe "#destroy" do

    before(:each) do
      @area = create_valid_area
      @block_container = @block.block_containers.create(area_id: @area.id)
    end

    context "for a shared block" do
      it "doesn't destroy the shared block" do
        shared_block = @block_container.block
        shared_block.update_attributes(shared: true)

        expect {
          @block_container.reload.destroy
        }.to change(Block, :count).by(0)
      end
    end

    context "for an exclusive block" do
      it "destroy the exlcusive block" do
        shared_block = @block_container.block
        shared_block.update_attributes(shared: false)

        expect {
          @block_container.reload.destroy
        }.to change(Block, :count).by(-1)
      end
    end

  end

end
