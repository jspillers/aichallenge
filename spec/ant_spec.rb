require 'spec_helper'

describe Ant do
  before do
    @square = Square.new(
      water: false,
      food: false,
      hill: false,
      ant: nil,
      row: 0,
      col: 0
    )

    @ant = Ant.new(square: @square, alive: true, owner: 1)
  end

  it 'makes a new ant' do
    @ant.is_a?(Ant).should be_true
  end

  describe 'ant_id' do
    it 'creates an id based on position'
    it 'creates correct id when order history is empty'
    it 'creates correct id when order history and position history are empty'
  end

  describe '' do

  end
end
