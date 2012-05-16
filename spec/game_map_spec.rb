require 'spec_helper'

describe GameMap do
  before do
    bootstrap_game_map
  end

  it 'set the game_map' do
    GameMap.map_array.is_a?(Array)
  end

  it 'has 25 squares' do
    GameMap.squares.size.should == 25
  end

  describe '#square_at' do
    it 'should return a square object when passed two arguments' do
      GameMap.square_at(2,3).is_a?(Square).should be_true
    end

    it 'should return a square object when passed an array' do
      GameMap.square_at([2,3]).is_a?(Square).should be_true
    end

    it 'should return a square object with the correct location' do
      GameMap.square_at(2,3).to_a.should == [2,3]
    end
  end

  describe '#set_square_at' do
    before do
      @square = Square.new(water: false, food: false, hill: false, ant: nil, row: 3, col: 4)
    end

    it 'should set the square for a given location with an array for a location arguments' do
      GameMap.set_square_at([3,4], @square)
      GameMap.square_at(3,4).to_a.should == [3,4]
    end

    it 'should set the square for a given location with row, col arguments' do
      square = Square.new(water: false, food: false, hill: false, ant: nil, row: 3, col: 4)
      GameMap.set_square_at(3, 4, @square)
      GameMap.square_at(3,4).to_a.should == [3,4]
    end

    it 'should set the correct square' do
      GameMap.set_square_at(3, 4, @square)
      GameMap.square_at(3,4).should == @square
    end
  end
end
