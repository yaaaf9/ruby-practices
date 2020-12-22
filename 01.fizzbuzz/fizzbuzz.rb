#!/usr/bin/env ruby
x = 1

while x <= 100
  if x % 15 == 0
    puts "FizzBuzz"
  elsif x % 5 == 0
    puts "Buzz"
  elsif x % 3 == 0
    puts "Fizz"
  else
    puts x
  end
  x += 1
end
