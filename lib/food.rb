class Food

  attr_accessor :row, :col, :square, :ant_en_route

  def initialize(opts={})
    @square = opts[:square]
    @row = @square.row
    @col = @square.col
  end

  def to_a
    [@row, @col]
  end

  # this food was eaten
  def consumed!
    ant_en_route.path = [] if ant_en_route.is_a?(Ant)
    ant_en_route = nil
    GameMap.square_at(row, col).food = nil
  end

  # class methods

  # remove any food no longer present
  # add new food that appear
  def self.update_foods(food_locs)
    @foods = [] unless @foods.is_a?(Array)
    curr_foods = @foods.map(&:to_a)

    # create new foods for food locations that are reported
    # but have not had food objects created for them
    (food_locs - (curr_foods & food_locs)).each do |new_food_loc|
      square = GameMap.square_at(new_food_loc)
      food = Food.new(square: square)
      @foods << food
      square.food = food
    end

    # remove foods that exist already but are not reported (ie: eaten)
    (curr_foods - food_locs).each do |consumed_food|
      food = GameMap.square_at(consumed_food).food
      food.consumed!
      @foods.delete(food)
    end
  end

  # array of all food locations
  def self.foods
    @foods
  end

  # are there any food nodes that do not have an ant en route to them
  def self.unassigned_foods?
    !unassigned_foods.empty?
  end

  def self.unassigned_foods
    foods = @foods.select {|f| !f.ant_en_route.is_a?(Ant) }
    AI.logger.debug 'unassigned food locations: ' + foods.map(&:to_a).inspect
    AI.logger.debug 'all food locations: ' + @foods.map(&:to_a).inspect
    AI.logger.debug 'food and assigned ant: ' + @foods.map{|f| [f.to_a, f.ant_en_route] }.inspect
    AI.logger.debug '----------------' * 5

    foods
  end

  def self.nearest_unassigned_from(ant_square)
    return nil if @foods.empty?
    sorted_foods = unassigned_foods.sort_by do |a,b|
      a.square.guess_distance(ant_square) <=> a.square.guess_distance(ant_square)
    end

    sorted_foods.first
  end
end
