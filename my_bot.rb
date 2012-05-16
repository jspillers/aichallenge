$:.unshift File.dirname($0)

require 'rubygems'
require 'logger'
require 'set'

require 'lib/game_map'
require 'lib/game_controller'
require 'lib/ai'
require 'lib/a_star'
require 'lib/square'
require 'lib/food'
require 'lib/ant'

ai=AI.new
AI.ai = ai

ai.setup do |ai|
  # your setup code here, if any
end

ai.run do |ai|
  GameController.do_turn(ai)
end
