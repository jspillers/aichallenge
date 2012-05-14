$:.unshift File.dirname($0)

require 'rubygems'
require 'set'
require 'logger'

require 'lib/a_star'
require 'lib/ai'
require 'lib/square'
require 'lib/food'
require 'lib/ant'

ai=AI.new
AI.ai = ai

ai.setup do |ai|
  # your setup code here, if any
  @dirs = [:N,:E,:S,:W]
  AI.logger = Logger.new('ants.log')
end


ai.run do |ai|
  square = ai.game_map[35][10]

  #AI.logger.debug 'square: ' + square.to_a.inspect

  Ant.move_orders = []

  AI.logger.debug 'number of ants: ' + ai.my_ants.size.to_s
  AI.logger.debug 'number of enemy ants: ' + ai.enemy_ants.size.to_s
  AI.logger.debug 'food locations: ' + Food.foods.map(&:to_a).inspect
  AI.logger.debug 'food assignments: ' + Food.foods.map {|f| f.ant_en_route.ant_id if f.ant_en_route }.inspect

  ai.my_ants.each_with_index do |ant,i|
    #AI.logger.debug 'ant.has_path?: ' + ant.has_path?.to_s

    if !ant.has_path?

      #AI.logger.debug 'Food.unassigned_available? ' + Food.unassigned_available?.to_s
      if !Food.unassigned_foods?
        # wander if no food found
        ant.path = [ant.neighbor(@dirs[rand(0..3)])]
      else
        food_square = Food.nearest_unassigned_from(ant.square)

        #AI.logger.debug 'food square to_a: ' + food_square.to_a.inspect

        food_square.ant_en_route = ant
        ant.path = ant.set_path_to(food_square.square)

        #AI.logger.debug 'path: ' + ant.path.inspect
      end
    end

    ant.move_to_next_path_node
  end
end
