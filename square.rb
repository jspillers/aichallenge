# Represent a single field of the map.
class Square
  # Ant which sits on this square, or nil. The ant may be dead.
  attr_accessor :ant

  # Which row this square belongs to.
  attr_accessor :row

  # Which column this square belongs to.
  attr_accessor :col

  attr_accessor :water, :food, :hill

  # water, food, hill, ant, row, col, ai
  def initialize(opts)
    @water = opts[:water]
    @food  = opts[:food]
    @hill  = opts[:hill]
    @ant   = opts[:ant]
    @row   = opts[:row]
    @col   = opts[:col]
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
    @food
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
  def neighbor(direction, ai)
    direction = direction.to_s.upcase.to_sym # canonical: :N, :E, :S, :W

    case direction
    when :N
      row, col = ai.normalize @row - 1, @col
    when :E
      row, col = ai.normalize @row, @col + 1
    when :S
      row, col = ai.normalize @row + 1, @col
    when :W
      row, col = ai.normalize @row, @col - 1
    else
      raise 'incorrect direction'
    end

    square = ai.game_map[row][col]
    puts square.class.to_s
    puts square.row.to_s
    puts square.col.to_s # replac ethis crap with a logger
  end

end
