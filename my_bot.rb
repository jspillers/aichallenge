$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new

ai.setup do |ai|
  # your setup code here, if any
end

ai.run do |ai|
  square_orders = []

  puts ai.enemy_ants.inspect

  ai.my_ants.each do |ant|
    # try to go north, if possible; otherwise try east, south, west.
    [:N, :E, :S, :W].each do |dir|
      if ant.square.neighbor(dir, ai).passable? && !square_orders.include?(ant.square.neighbor(dir, ai))
        square_orders << ant.square.neighbor(dir, ai)
        ant.order(dir, ai)
        break
      end
    end
  end
end
