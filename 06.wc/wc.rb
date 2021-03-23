# frozen_string_literal: true

# !/usr/bin/env ruby

require 'optparse'

class CommandOption
  def initialize
    @options = {}
    OptionParser.new do |o|
      o.on('-a') { |v| @options[:a] = v }
      o.on('-r') { |v| @options[:r] = v }
      o.on('-l') { |v| @options[:l] = v }
      o.parse!(ARGV)
    end
  end

  # 引数のオプションが含まれるか
  def has?(name)
    @options.include?(name)
  end
end

def main
  options = CommandOption.new

  # 指定ファイルがある場合の処理
  unless ARGV.empty?
    if options.has?(:l)
      display_lines(ARGV)
      display_lines_total(ARGV)
    else
      display_information(ARGV)
      display_information_total(ARGV)
    end
  end

  return unless ARGV.empty?

  # 標準入力があった場合の処理
  input = $stdin.read

  if options.has?(:l)
    display_lines_stdin(input)
  else
    display_stdin(input)
  end
end

# 指定ファイルの行数・単語数・バイト数を配列に格納
def store_information_to_array(data)
  data.map do |file|
    f = File.read(file)
    files = []
    files << count_lines(f)
    files << count_words(f)
    files << count_bytes(f)
  end
end

# 指定ファイルの行数・単語数・バイト数を表示する
def display_information(data)
  files = store_information_to_array(data)
  files.each_with_index do |f, i|
    lines = count_digits(f[0])
    words = count_digits(f[1])
    bytes = count_digits(f[2])
    print ' ' * lines + f[0].to_s
    print ' ' * words + f[1].to_s
    print ' ' * bytes + f[2].to_s
    print " #{ARGV[i]}"
    print "\n"
  end
end

# 指定ファイルの行数を表示する
def display_lines(data)
  files = store_information_to_array(data)
  files.each_with_index do |f, i|
    lines = count_digits(f[0])
    print ' ' * lines + f[0].to_s
    print " #{ARGV[i]}"
    print "\n"
  end
end

# 指定ファイルの行数・単語数・バイト数のTOTALを最終行に表示する
def display_information_total(data)
  return unless data.size >= 2

  files = store_information_to_array(data)
  total = count_total(files)
  lines = count_digits(total[0])
  words = count_digits(total[1])
  bytes = count_digits(total[2])
  print ' ' * lines + total[0].to_s
  print ' ' * words + total[1].to_s
  print ' ' * bytes + total[2].to_s
  print ' total'
  print "\n"
end

# 指定ファイルの行数のTOTALを最終行に表示する
def display_lines_total(data)
  return unless data.size >= 2

  files = store_information_to_array(data)
  total = count_total(files)
  lines = count_digits(total[0])
  print ' ' * lines + total[0].to_s
  print ' total'
  print "\n"
end

# 標準入力の行数・単語数・バイト数を表示する
def display_stdin(stdin)
  lines = count_digits(count_lines(stdin))
  words = count_digits(count_words(stdin))
  bytes = count_digits(count_bytes(stdin))
  print ' ' * lines + count_lines(stdin).to_s
  print ' ' * words + count_words(stdin).to_s
  print ' ' * bytes + count_bytes(stdin).to_s
  print "\n"
end

# 標準入力の行数を表示する
def display_lines_stdin(stdin)
  lines = count_digits(count_lines(stdin))
  print ' ' * lines + count_lines(stdin).to_s
  print "\n"
end

# 行数をカウントする
def count_lines(file)
  file.lines.count
end

# 単語数をカウントする
def count_words(file)
  file.split(/\s+/).size
end

# バイト数をカウントする
def count_bytes(file)
  file.bytesize
end

# 転置行列を行い各要素のTOTALを算出する
def count_total(data)
  data.transpose.map(&:sum)
end

# カラム調整のため、数値の桁数をカウントする
def count_digits(num)
  8 - (Math.log10(num.abs).to_i + 1)
end

main
