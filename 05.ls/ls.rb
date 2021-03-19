# frozen_string_literal: true

# !/usr/bin/env ruby

require 'optparse'
require 'etc'

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

def main(options)
  # option -a の処理
  files = options.has?(:a) ? Dir.glob('*', File::FNM_DOTMATCH).sort : Dir.glob(['*']).sort

  # ファイル総数が0ならメソッドから抜ける
  return if files.count.zero?

  # option -r の処理
  files = files.reverse if options.has?(:r)

  # option -l または option無しの処理
  options.has?(:l) ? arrange_file(examine_file_attributes(files)) : pass_no_option(files)
end

# ファイルモードを変換する
def convert_to_filetype(filetype)
  { 'file' => '-',
    'directory' => 'd',
    'characterSpecial' => 'c',
    'blockSpecial' => 'b',
    'fifo' => 'p',
    'link' => 'l',
    'socket' => 's' }[filetype]
end

# ファイルのパーミッションを変換する
def convert_to_permission(mode)
  { '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx' }[mode]
end

# option -lがある場合、ファイルの各属性を配列に格納する
def examine_file_attributes(files)
  six_month = 60 * 60 * 24 * 30 * 6
  files.map do |file|
    stat = File::Stat.new(file)
    mode = stat.mode.to_s(8)
    block = stat.blocks
    data = []
    data << block
    data << convert_to_filetype(stat.ftype) + convert_to_permission(mode[-3]) + convert_to_permission(mode[-2]) + convert_to_permission(mode[-1])
    data << stat.nlink.to_s
    data << Etc.getpwuid(stat.uid).name.to_s
    data << Etc.getgrgid(stat.gid).name.to_s
    data << stat.size.to_s
    data << stat.mtime.strftime('%-m').to_s
    data << stat.mtime.strftime('%-e').to_s
    mtime = (Time.now - stat.mtime).abs < six_month ? stat.mtime.strftime('%H:%M') : stat.mtime.year.to_s
    data << mtime.to_s
    data << file
  end
end

# 要素の中で最も長い文字列を抽出する
def extract_longest_word(sentence)
  sentence.max_by(&:length)
end

# option -lがある場合、カラム幅を調整してファイルの各属性を表示する
def arrange_file(files)
  print "total #{files.transpose[0].sum}"
  print "\n"
  files.each do |file|
    print "#{file[1]} "
    print " #{' ' * ((extract_longest_word(files.transpose[2]).size - file[2].size))}#{file[2]}"
    print " #{' ' * ((extract_longest_word(files.transpose[3]).size - file[3].size))}#{file[3]}"
    print " #{' ' * ((extract_longest_word(files.transpose[4]).size - file[4].size))}#{file[4]}"
    print " #{' ' * ((extract_longest_word(files.transpose[5]).size - file[5].size))} #{file[5]}"
    print " #{' ' * ((extract_longest_word(files.transpose[6]).size - file[6].size))}#{file[6]}"
    print " #{' ' * ((extract_longest_word(files.transpose[7]).size - file[7].size))}#{file[7]}"
    print " #{' ' * ((extract_longest_word(files.transpose[8]).size - file[8].size))}#{file[8]}"
    print " #{file[9]}"
    print "\n"
  end
end

# カラム幅を調整し、ファイルを3列で表示させる
def pass_no_option(files)
  # ファイル総数が1の場合
  return puts files if files.count == 1

  # 1列に表示するファイル数を算出する
  file_count = (files.count % 3).zero? ? files.count / 3 : files.count / 3 + 1

  slice_file = files.each_slice(file_count).to_a

  slice_file.transpose.map do |file|
    print "#{file[0]}       #{' ' * (extract_longest_word(slice_file[0]).size - file[0].size)}"
    print "#{file[1]}       #{' ' * (extract_longest_word(slice_file[1]).size - file[1].size)}"
    print file[2].to_s
    puts "\n"
  end
end

main(CommandOption.new)
