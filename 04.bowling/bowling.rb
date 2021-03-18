#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []

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

frames = []
frames = shots.each_slice(2).to_a

point = 0

frames.each_with_index do |frame, i|
  point += \
    if i < 9
      # turkey or double strike
      if frame[0] == 10 && frames[i + 1][0] == 10
        10 + frames[i + 1][0] + frames[i + 2][0]
      elsif frame[0] == 10  # strike
        10 + frames[i + 1][0] + frames[i + 1][1]
      elsif frame.sum == 10 # spare
        10 + frames[i + 1][0]
      else
        frame.sum
      end
    else # 10 frame
      frame.sum
    end
end

p point
