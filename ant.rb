# Represents a single ant.
class Ant
  # Owner of this ant. If it's 0, it's your ant.
  attr_accessor :owner

  # Square this ant sits on.
  attr_accessor :square

  attr_accessor :alive, :position_history, :order_history, :path

  def initialize(opts={})
    @alive  = opts[:alive]
    @owner  = opts[:owner]
    @square = opts[:square]

    @position_history = []
    @order_history    = []
    @path             = []
  end

  def self.ant_id(prefix, row, col)
    "#{prefix}:#{row}-#{col}"
  end

  class << self
    attr_accessor :move_orders
  end

  def ant_id
    row, col = if order_history.empty?
      @position_history.last
    else
      square = expected_square
      [square.row, square.col]
    end

    owner = mine? ? 'my_ant' : 'enemy_ant'
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
      previous_pos = position_history.last
      square = AI.ai.game_map[previous_pos[0]][previous_pos[1]]
      square.neighbor(order_history.last)
    end
  end

  def set_path_to(goal_square)
    calculated_path = square.calculate_path_to(goal_square)
    #AI.logger.debug 'calculated_path: ' + calculated_path[1].map{|s| s.to_a }.inspect
    #AI.logger.debug 'do i have a calculated_path? ' + (!calculated_path.nil? && !calculated_path[1].nil?).to_s
    #AI.logger.debug 'ant current square: ' + square.to_a.inspect

    if !calculated_path.nil? && !calculated_path[1].nil?
      AI.logger.debug 'first calculated_path matches ant current square: ' + (calculated_path[1].first.to_a == square.to_a).to_s

      calculated_path[1].shift if !calculated_path[1].empty? && calculated_path[1].first.to_a == square.to_a
      AI.logger.debug 'calculated_path after shift: ' + calculated_path[1].map{|s| s.to_a }.inspect
      @path = calculated_path[1]
    end
  end

  def has_path?
    @path.is_a?(Array) && !@path.empty?
  end

  def move_to_next_path_node
    if @path && !@path.empty? && @path[0].passable? && !Ant.move_orders.include?(@path[0])
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
