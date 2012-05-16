class GameController

  def self.dirs
    [:N,:E,:S,:W]
  end

  def self.do_turn(ai)
    square = GameMap.square_at([35,10])

    #AI.logger.debug 'square: ' + square.to_a.inspect

    Ant.move_orders = []

    #AI.logger.debug 'number of ants: ' + ai.my_ants.size.to_s
    #AI.logger.debug 'number of enemy ants: ' + ai.enemy_ants.size.to_s
    #AI.logger.debug 'food locations: ' + Food.foods.map(&:to_a).inspect
    #AI.logger.debug 'food assignments: ' + Food.foods.map {|f| f.ant_en_route.ant_id if f.ant_en_route }.inspect

    Ant.my_ants.first.state = 'gather'

    Ant.my_ants.each_with_index do |ant,i|
      #AI.logger.debug 'ant.has_path?: ' + ant.has_path?.to_s

      if !ant.has_path?

        #AI.logger.debug 'Food.unassigned_available? ' + Food.unassigned_available?.to_s
        if ant.state == 'gather' && Food.unassigned_foods?
          food_square = Food.nearest_unassigned_from(ant.square)

          #AI.logger.debug 'food square to_a: ' + food_square.to_a.inspect

          food_square.ant_en_route = ant
          ant.path = ant.set_path_to(food_square.square)

          #AI.logger.debug 'path: ' + ant.path.inspect
        else
          # wander if no food found
          ant.path = [ant.neighbor(dirs[rand(0..3)])]
        end
      end

      ant.move_to_next_path_node
    end

  end
end
