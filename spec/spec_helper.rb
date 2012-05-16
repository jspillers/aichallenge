$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..')

require 'rubygems'
require 'rspec'
require 'logger'
require 'set'

require 'lib/game_map'
require 'lib/game_controller'
require 'lib/ai'
require 'lib/a_star'
require 'lib/square'
require 'lib/food'
require 'lib/ant'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before :suite do
  end

  config.before(:each) do
  end

  config.after(:each) do
  end
end

# 5 x 5 map of blank land squares
def bootstrap_game_map
  map_array = []
  5.times do |row|
    squares = []
    5.times do |col|
      squares << Square.new({
        water: false, food: false, hill: false,
        ant: nil, row: row, col: col
      })
    end
    map_array << squares
  end

  GameMap.map_array = map_array
end
