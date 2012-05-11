# Represents a single ant.
class Ant
  # Owner of this ant. If it's 0, it's your ant.
  attr_accessor :owner

  # Square this ant sits on.
  attr_accessor :square

  attr_accessor :alive, :ai, :position_history, :order_history

  def initialize(opts={})
    @alive  = opts[:alive]
    @owner  = opts[:owner]
    @square = opts[:square]
    @position_history = []
    @order_history = []
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

  # Order this ant to go in given direction. Equivalent to ai.order ant, direction.
  def order(direction, ai)
    @position_history << [@square.row, @square.col]
    @order_history << direction
    ai.order self, direction
  end

  # returns the map square object that this ant should now be at
  def expected_new_position(ai)
    return nil if position_history.empty? || order_history.empty?
    previous_pos = position_history.last
    square = ai.game_map[previous_pos[0]][previous_pos[1]]
    square.neighbor(order_history.last, ai)
  end
end
