$:.unshift File.dirname($0)
require 'ants.rb'

ai=AI.new

ai.setup do |ai|
  # your setup code here, if any
end

ai.run do |ai|
  square_orders = []

  ai.my_ants.each do |ant|
    # try to go north, if possible; otherwise try east, south, west.
    [:N, :E, :S, :W].each do |dir|
      if ant.square.neighbor(dir).passable? && !square_orders.include?(ant.square.neighbor(dir))
        square_orders << ant.square.neighbor(dir)
        ant.order dir
        break
      end
    end
  end
end
