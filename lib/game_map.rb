class GameMap

  class << self
    attr_accessor :map_array
  end

  def self.square_at(*args)
    row, col = args[0].is_a?(Array) ? args[0] : [args[0], args[1]]
    @map_array[row.to_i][col.to_i]
  end

  def self.set_square_at(*args)
    row, col = args[0].is_a?(Array) ? args[0] : [args[0], args[1]]
    square = args.select {|a| a.is_a?(Square) }.first
    @map_array[row.to_i][col.to_i] = square
  end

  # return a flat array of all squares
  def self.squares
    @map_array.flatten
  end
end
