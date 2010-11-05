#!/usr/bin/env ruby

$LOAD_PATH << 'lib'
require 'scratch'
require 'rubygems'
require 'benchmark'

include Benchmark
include Scratch
terp = Scratch::Scratch.new

tasks = [
"1",
"drop",
"1 2 3 45 678",
"pstack",
#'" ----------------------" print',
'" - dup" print',
"dup pstack",
#'" ----------------------" print',
'" - drop" print',
"drop pstack",
#'" ----------------------" print',
'" - swap" print',
"swap pstack",
#'" ----------------------" print',
'" - over" print',
"over pstack",
#'" ----------------------" print',
'" - rot" print',
"rot pstack",
#'" ----------------------" puts',
"10 pstack",
"1 2 3 print print print",
"2 2 + print",
"2 2 - print",
"4 2 / print",
"3 3 * 4 4 * + √ print",
"var a",
"var b",
"12 b store",
"10 a store",
"a fetch print",
"b fetch print",
"12 a store",
"a fetch print",
"b fetch print",
#"5 const Q",
#"Q print",
'" Hello World!" print',
'/* abc */ " Hello World!" print',
'/* abc */ b fetch print',
#'/* abc */ Q print',
'def hypot  dup * swap dup * + √  end',
'3 4 hypot puts',
'[ 1 2 3 ] puts',
'[ 1 2 3 [ 4 5 6 ] 7 ] puts',
'[ 1 2 3 [ 4 5 6 ] 7 ] 3 item puts',
'[ 1 2 3 ] 1 item puts',
'[ 1 " hello" print ] puts',
'[ 1 2 3 ] exec puts',
'[ 1 print ] 5 times',
'false [ 1 print ] is_true?',
'true [ 3 print ] is_true?',
'false [ 2 print ] is_false?',
'true [ 4 print ] is_false?',
'false [ 5 print ] is_false?',
'false [ 6 print ] is_false?',
'true [ 7 print ] is_false?',
'true [ 7 print ] [ 8 print ] if_else?',
'false [ 7 print ] [ 8 print ] if_else?',
'true false or [ 9 puts ] is_true?',
'true false and [ 10 puts ] is_true?',
'false not [ 11 puts ] is_true?',
'1 [ dup 3 > break? dup print 1 + ] loop'
]

bmbm 30 do |bm|
  tasks.each do |task|
    bm.report "terp.run '#{task}'" do
      terp.run task
    end
  end
end
