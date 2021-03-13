#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
frames = []

scores.each do |s|
  case s
  when 'X' # strike
    shots << 10
    shots << 0
  when 'S'
    shots << 10
  else
    shots << s.to_i
  end
end

shots.each_slice(2) do |s|
  frames << s
end

point = 0
i = 0

while frames.length
  point += \
    if i < 9
      # turkey or double strike
      if frames[i][0] == 10 && frames[i + 1][0] == 10 && frames[i + 2][0] == 10 \
      || frames[i][0] == 10 && frames[i + 1][0] == 10
        10 + frames[i + 1][0] + frames[i + 2][0]
      elsif frames[i][0] == 10  # strike
        10 + frames[i + 1][0] + frames[i + 1][1]
      elsif frames[i].sum == 10 # spare
        10 + frames[i + 1][0]
      else
        frames[i].sum
      end
    else # 10 frame
      frames[i].sum
    end
  i += 1
  break if i == frames.length
end

p point