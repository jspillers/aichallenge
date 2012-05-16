# Represents a single ant.
class Ant
  # Owner of this ant. If it's 0, it's your ant.
  attr_accessor :owner

  # Square this ant sits on.
  attr_accessor :square

  attr_accessor :alive, :position_history, :order_history, :path, :state

  class << self
    attr_accessor :my_ants, :enemy_ants
  end

  def self.ant_id(owner, row, col)
    "#{owner}:#{row}-#{col}"
  end

  def self.update_my_ants(ant_locations)
    @my_ants ||= []
    update_ants(@my_ants, ant_locations)
  end

  def self.update_enemy_ants(ant_locations)
    @enemy_ants ||= []
    update_ants(@enemy_ants, ant_locations)
  end

  # loop through all ant objects and update their location and aliveness
  # remove from the ants array if not found in the new ant_locations hash
  def self.update_ants(collection, ant_locations)
    collection.each do |ant|
      if ant_locations.has_key?(ant.ant_id)
        # update the ants location
        ant.square = ant.expected_square

        # update alive or dead
        ant.alive = ant_locations[ant.ant_id]

        # update the game_map square with reference to this ant
        GameMap.square_at(ant.row, ant.col).ant = ant

        # update complete... remove from the hash of new locations
        ant_locations.delete(ant.ant_id)
      else
        # ant is no longer on the map... remove from array
        collection.delete(ant)

        # a dead ant is not able to get the food... unassign
        ant.path.last.food.ant_en_route = nil if ant.has_path? && ant.path.last.food?
      end
    end

    # any locations not previously used for updating must be newly spawned ants... add
    # them to the array of ant objects
    ant_locations.each do |k,v|
      owner_and_location = k.split(':')
      owner, location = owner_and_location[0], owner_and_location[1].split('-')

      if owner && location
        ant = Ant.new(
          alive: true,
          owner: owner,
          square: GameMap.square_at(location)
        )
        ant.position_history = [[ant.row, ant.col]]
        collection << ant
      end
    end

  end

  class << self
    attr_accessor :move_orders
  end

  def initialize(opts={})
    @alive  = opts[:alive]
    @owner  = opts[:owner]
    @square = opts[:square]

    @position_history = []
    @order_history    = []
    @path             = []
  end

  def ant_id
    row, col = if order_history.empty?
      @position_history.last
    else
      square = expected_square
      [square.row, square.col]
    end

    self.class.ant_id(owner, row, col)
  end

  def neighbor(dir)
    square.neighbor(dir)
  end

  # True if ant is alive.
  def alive?
    @alive
  end

  # True if ant is not alive.
  def dead?
    !@alive
  end

  # Equivalent to ant.owner == 0.
  def mine?
    owner == 0
  end

  # Equivalent to ant.owner != 0.
  def enemy?
    owner != 0
  end

  # Returns the row of square this ant is standing at.
  def row
    @square.row
  end

  # Returns the column of square this ant is standing at.
  def col
    @square.col
  end

  # returns the map square object that this ant should now be at
  def expected_square
    return nil if position_history.empty?

    if order_history.empty?
      square
    else
      square = GameMap.square_at(position_history.last)
      square.neighbor(order_history.last) if square
    end
  end

  def set_path_to(goal_square)
    calculated_path = square.calculate_path_to(goal_square)
    AI.logger.debug 'calculated path: ' + calculated_path[1].map(&:to_a).inspect
    if !calculated_path.nil? && !calculated_path[1].nil?
      calculated_path[1].shift if !calculated_path[1].empty? && calculated_path[1].first.to_a == square.to_a
      @path = calculated_path[1]
    end
  end

  def has_path?
    @path.is_a?(Array) && !@path.empty?
  end

  def move_to_next_path_node
    if alive && has_path? && @path[0].passable? && !Ant.move_orders.include?(@path[0])
      move_target = @path.shift
      Ant.move_orders << move_target
      move_to(move_target)
    else
      @path = []
    end
  end

  def move_to(goal_square)
    dir = square.direction_of_adjacent(goal_square)
    order(dir)
  end

  # Order this ant to go in given direction. Equivalent to ai.order ant, direction.
  def order(direction)
    @position_history << [@square.row, @square.col]
    @order_history << direction
    AI.ai.order self, direction
  end

end
