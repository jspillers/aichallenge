# base game controller
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

  attr_accessor :my_ants, :enemy_ants

  class << self
    attr_accessor :logger, :ai
  end

  # Initialize a new AI object. Arguments are streams this AI will read from and write to.
  def initialize(stdin=$stdin, stdout=$stdout)
    @stdin, @stdout = stdin, stdout
    @game_map = nil
    @turn_number = 0
    @did_setup = false
    @my_ants = []
    @enemy_ants = []
    @food_squares = []
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
        square.ant = nil
        square.hill = false
      end
    end

    foods = []
    ant_locations = {}

    until((rd = @stdin.gets.strip) == 'go')
      _, type, row, col, owner = *rd.match(/(w|f|h|a|d) (\d+) (\d+)(?: (\d+)|)/)
      row, col = row.to_i, col.to_i
      owner = owner.to_i if owner

      case type
      when 'w'
        @game_map[row][col].water = true
      when 'f'
        foods << [row, col]
      when 'h'
        @game_map[row][col].hill = owner
      when 'a'
        if owner == 0
          ant_locations.merge!("my_ant:#{row}-#{col}" => true)
        else
          ant_locations.merge!("enemy_ant:#{row}-#{col}" => true)
        end
      when 'd'
        if owner == 0
          ant_locations.merge!("my_ant:#{row}-#{col}" => false)
        else
          ant_locations.merge!("enemy_ant:#{row}-#{col}" => false)
        end
      when 'r'
        # pass
      else
        warn "unexpected: #{rd}"
      end
    end

    update_ants('my_ant', @my_ants, ant_locations)
    update_ants('enemy_ant', @enemy_ants, ant_locations)

    # any locations not previously used for updating must be newly spawned ants... add
    # them to the array of ant objects
    ant_locations.each do |k,v|
      location = k.split(":")[1].split('-')
      if k.match /^my_ant:/
        @my_ants << Ant.new(alive: true, owner: 0, square: @game_map[location[0].to_i][location[1].to_i])
      elsif k.match /^enemy_ant:/
        @enemy_ants << Ant.new(alive: true, owner: 1, square: @game_map[location[0].to_i][location[1].to_i])
      end
    end

    Food.update_foods(foods)

    ret
  end

  # loop through all ant objects and update their location and aliveness
  # remove from the ants array if not found in the new ant_locations hash
  def update_ants(key_prefix, collection, ant_locations)
    collection.each do |ant|
      if ant_locations.has_key?(ant.ant_id)
        # update the ants location
        ant.square = ant.expected_square

        # update alive or dead
        ant.alive = ant_locations[ant.ant_id]

        @game_map[ant.row][ant.col].ant = ant

        # update complete... remove from the hash of new locations
        ant_locations.delete(ant.ant_id)
      else
        # ant is no longer on the map... remove from array
        collection.delete(ant)

        # a dead ant is not able to get the food... unassign
        ant.path.last.food.ant_en_route = nil if ant.has_path? && ant.path.last.food?
      end
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
