# Ants AI Challenge framework
# by Matma Rex (matma.rex@gmail.com)
# Released under CC-BY 3.0 license

# Represents a single ant.
class Ant
  # Owner of this ant. If it's 0, it's your ant.
  attr_accessor :owner

  # Square this ant sits on.
  attr_accessor :square

  attr_accessor :alive, :ai, :position_history, :order_history

  def expected_position
    @position_history.last
  end

  def initialize(opts={})
    @alive  = opts[:alive]
    @owner  = opts[:owner]
    @square = opts[:square]
    @position_history << [@square.row, @square.col]
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
    @positions << [@square.row, @square.col]
    @order_history << direction
    ai.order self, direction
  end
end

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

    return ai.game_map[row][col]
  end

end

class AI
  # GameMap, as an array of arrays.
  attr_accessor :game_map

  # Number of current turn. If it's 0, we're in setup turn. If it's :game_over, you don't need to give any orders; instead, you can find out the number of players and their scores in this game.
  attr_accessor :turn_number

  # Game settings. Integers.
  attr_accessor :loadtime, :turntime, :rows, :cols, :turns, :viewradius2, :attackradius2, :spawnradius2, :seed

  # Radii, unsquared. Floats.
  attr_accessor :viewradius, :attackradius, :spawnradius

  # Number of players. Available only after game's over.
  attr_accessor :players

  # Array of scores of players (you are player 0). Available only after game's over.
  attr_accessor :score

  attr_accessor :food, :my_ants, :enemy_ants

  # Initialize a new AI object. Arguments are streams this AI will read from and write to.
  def initialize(stdin=$stdin, stdout=$stdout)
    @stdin, @stdout = stdin, stdout
    @game_map = nil
    @turn_number = 0
    @did_setup = false
    @my_ants = []
  end

  # Returns a read-only hash of all settings.
  def settings
    {
      loadtime: @loadtime,
      turntime: @turntime,
      rows: @rows,
      cols: @cols,
      turns: @turns,
      viewradius2: @viewradius2,
      attackradius2: @attackradius2,
      spawnradius2: @spawnradius2,
      viewradius: @viewradius,
      attackradius: @attackradius,
      spawnradius: @spawnradius,
      seed: @seed
    }.freeze
  end

  # Zero-turn logic.
  def setup # :yields: self
    read_intro
    yield self

    @stdout.puts 'go'
    @stdout.flush

    @game_map = Array.new(@rows) {|row|
      Array.new(@cols) {|col|
        Square.new({
          water: false, food: false, hill: false,
          ant: nil, row: row, col: col
        })
      }
    }

    @did_setup = true
  end

  # Turn logic. If setup wasn't yet called, it will call it (and yield the block in it once).
  def run(&b) # :yields: self
    setup &b if !@did_setup

    over = false
    until over
      over = read_turn
      yield self

      @stdout.puts 'go'
      @stdout.flush
    end
  end

  # Internal; reads zero-turn input (game settings).
  def read_intro
    rd = @stdin.gets.strip
    warn "unexpected: #{rd}" unless rd == 'turn 0'

    until((rd = @stdin.gets.strip) == 'ready')
      _, name, value = *rd.match(/\A([a-z0-9]+) (\d+)\Z/)

      case name
      when 'loadtime'; @loadtime = value.to_i
      when 'turntime'; @turntime = value.to_i
      when 'rows'; @rows = value.to_i
      when 'cols'; @cols = value.to_i
      when 'turns'; @turns = value.to_i
      when 'viewradius2'; @viewradius2 = value.to_i
      when 'attackradius2'; @attackradius2 = value.to_i
      when 'spawnradius2'; @spawnradius2 = value.to_i
      when 'seed'; @seed = value.to_i
      else
        warn "unexpected: #{rd}"
      end
    end

    @viewradius   = Math.sqrt @viewradius2
    @attackradius = Math.sqrt @attackradius2
    @spawnradius  = Math.sqrt @spawnradius2
  end

  # Internal; reads turn input (game_map state).
  def read_turn
    ret = false
    rd = @stdin.gets.strip

    if rd == 'end'
      @turn_number = :game_over

      rd = @stdin.gets.strip
      _, players = *rd.match(/\Aplayers (\d+)\Z/)
      @players = players.to_i

      rd = @stdin.gets.strip
      _, score = *rd.match(/\Ascore (\d+(?: \d+)+)\Z/)
      @score = score.split(' ').map{|s| s.to_i}

      ret = true
    else
      _, num = *rd.match(/\Aturn (\d+)\Z/)
      @turn_number = num.to_i
    end

    # reset the game_map data
    @game_map.each do |row|
      row.each do |square|
        square.food = false
        square.ant = nil
        square.hill = false
      end
    end

    @enemy_ants = []
    @food = []

    until((rd = @stdin.gets.strip) == 'go')
      _, type, row, col, owner = *rd.match(/(w|f|h|a|d) (\d+) (\d+)(?: (\d+)|)/)
      row, col = row.to_i, col.to_i
      owner = owner.to_i if owner

      case type
      when 'w'
        @game_map[row][col].water = true
      when 'f'
        @game_map[row][col].food = true
        @food << [row, col]
      when 'h'
        @game_map[row][col].hill = owner
      when 'a'

        @game_map[row][col].ant = find_or_create_ant(@game_map[row][col])

        if owner == 0
          @my_ants << a
        else
          @enemy_ants << a
        end
      when 'd'
        d = Ant.new(alive: false, owner: owner, square: @game_map[row][col])
        @game_map[row][col].ant = d
      when 'r'
        # pass
      else
        warn "unexpected: #{rd}"
      end
    end

    ret
  end

  def update_or_create_ant(location)
    @my_ants.each do |ant|
      ant.position_history.last
      Ant.new(alive: true, owner: owner, square: @game_map[row][col])
    end
  end

  # call-seq:
  #   order(ant, direction)
  #   order(row, col, direction)
  #
  # Give orders to an ant, or to whatever happens to be in the given square (and it better be an ant).
  def order(a, b, c=nil)
    if !c # assume two-argument form: ant, direction
      ant, direction = a, b
      @stdout.puts "o #{ant.row} #{ant.col} #{direction.to_s.upcase}"
    else # assume three-argument form: row, col, direction
      row, col, direction = a, b, c
      @stdout.puts "o #{row} #{col} #{direction.to_s.upcase}"
    end
  end

  # If row or col are greater than or equal game_map width/height, makes them fit the game_map.
  #
  # Handles negative values correctly (it may return a negative value, but always one that is a correct index).
  #
  # Returns [row, col].
  def normalize(row, col)
    [row % @rows, col % @cols]
  end
end


