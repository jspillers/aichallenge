# Represent a single field of the map.
class Square < AStarNode
  # Ant which sits on this square, or nil. The ant may be dead.
  attr_accessor :ant

  # Which row this square belongs to.
  attr_accessor :row

  # Which column this square belongs to.
  attr_accessor :col

  attr_accessor :water, :food, :hill

  # water, food, hill, ant, row, col
  def initialize(opts)
    @water = opts[:water]
    @food  = opts[:food]
    @hill  = opts[:hill]
    @ant   = opts[:ant]
    @row   = opts[:row]
    @col   = opts[:col]
  end

  def to_a
    [@row, @col]
  end

  # Returns true if this square is not water.
  def land?
    !@water
  end

  # Returns true if this square is water.
  def water?
    @water
  end

  # Returns true if this square contains food.
  def food?
    @food.is_a?(Food)
  end

  # Returns owner number if this square is a hill, false if not
  def hill?
    @hill
  end

  # Returns true if this square has an alive ant.
  def ant?
    @ant and @ant.alive?
  end

  # Square is passable if it's land, it doesn't contain alive ants, and it doesn't contain food.
  def passable?
    land? && !ant? && !food?
  end

  # Returns a square neighboring this one in given direction.
  def neighbor(direction)
    direction = direction.to_s.upcase.to_sym # canonical: :N, :E, :S, :W

    row, col = case direction
    when :N
      AI.ai.normalize @row - 1, @col
    when :E
      AI.ai.normalize @row, @col + 1
    when :S
      AI.ai.normalize @row + 1, @col
    when :W
      AI.ai.normalize @row, @col - 1
    else
      raise 'incorrect direction'
    end

    AI.ai.game_map[row][col]
  end

  def direction_of_adjacent(goal_square)

    case to_a
    when [goal_square.row - 1, goal_square.col]
      :S
    when [goal_square.row, goal_square.col + 1]
      :W
    when [goal_square.row + 1, goal_square.col]
      :N
    when [goal_square.row, goal_square.col - 1]
      :E
    else
      raise "goal square at #{goal_square.to_a} is not adjacent to #{to_a}"
    end
  end

  def neighbors
    sqrs = ['n','e','s','w'].map do |dir|
      square = neighbor(dir)
      square if square && square.land?
    end
    sqrs.compact
  end

  def guess_distance(goal_square)
    [(row - goal_square.row).abs, (col - goal_square.col).abs].max
  end

end
