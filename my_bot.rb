$:.unshift File.dirname($0)
require 'rubygems'
require 'ai'
require 'square'
require 'ant'
require 'logger'

ai=AI.new

ai.setup do |ai|
  # your setup code here, if any
  @dirs = [:N,:E,:S,:W]
  AI.logger = Logger.new('ants.log')
end


ai.run do |ai|
  square_orders = []

  dir = @dirs[rand(0..3)]
  ai.my_ants.first.order(dir,ai)

  #ai.my_ants.each do |ant|
  #  if ant.square.neighbor(dir, ai).passable? && !square_orders.include?(ant.square.neighbor(dir, ai))
  #    square_orders << ant.square.neighbor(dir, ai)
  #    ant.order(dir, ai)
  #  end
  #end

end
