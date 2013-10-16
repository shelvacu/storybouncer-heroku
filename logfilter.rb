#!/usr/bin/env ruby
def filter input
  input
end

while not (line = STDIN.gets).nil?
  filtered = filter(line)
  unless filtered.nil?
    puts filtered.to_s
  end
end
