#!/usr/bin/env ruby
require 'date'
require 'optparse'

opt = OptionParser.new
params = ARGV.getopts("y:m:")
year = (params["y"] || Date.today.year).to_i # -y 引数の指定があれば指定年、指定がなければ今年
month = (params["m"] || Date.today.mon).to_i # -m 引数の指定があれば指定月、指定がなければ今月
first_wday = Date.new(year, month, 1).wday # 曜日を数字で返す(日曜日が0)
lastday_date = Date.new(year, month, -1).day # 年月の最終日を返す
week = %w(日 月 火 水 木 金 土)

# カレンダーのヘッダーを表示する
puts " #{month}月 #{year}".center(20) # 年月を表示
puts week.join(" ") # 配列に格納した曜日を結合する
print "   " * first_wday # 月の1日目を曜日に合わせる

# カレンダーの日付を表示する
(1..lastday_date).each do |date|
  print date.to_s.rjust(2) + " "
  first_wday += 1
  if first_wday % 7 == 0
    print "\n"
  end
end

print "\n"
