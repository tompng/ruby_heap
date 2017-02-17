unless ARGV.index('run')
  require "mkmf"
  create_makefile("ruby_heap")
  exec 'make && ruby test.rb run'
end
require './ruby_heap.bundle'
require './ruby_heap'
require 'benchmark'
rh=RHeap.new
ch=CExtHeap.new
bench = ->klass{
  h = klass.new
  tadd = Benchmark.measure{100000.times{h<<rand}}.real
  taddremove = Benchmark.measure{100000.times{h<<rand;h.deq}}.real
  tremove = Benchmark.measure{100000.times{h.deq}}.real
  nodes = 100000.times.map{h << rand}
  tupdate = Benchmark.measure{nodes.shuffle.each{|n|n.priority = rand}}.real
  p [klass.name, tadd, taddremove, tremove, tupdate]
}
[RHeap, CExtHeap].each &bench

arr=1000.times.map{rand}
rh=RHeap.new
ch=CExtHeap.new
rout, cout = [rh, ch].map do |heap|
  arr.take(80).each{|v|heap<<v}
  out = 50.times.map{heap.deq}
  arr.drop(80).each{|v|heap<<v}
  while val = heap.deq
    out << val
  end
  out
end
ans = arr.take(80).sort.take(50)+(arr.take(80).sort.drop(50)+arr.drop(80)).sort

def assert a, b
  puts "assert failed\n #{a}\n  #{b}" unless a==b
end

assert rout, ans
assert cout, ans

[RHeap, CExtHeap].each do |klass|
  h=klass.new
  p klass.name
  10.times.map{|i|2*i}.shuffle.map{|i|h.enq i.to_s, priority: i}
  assert 5.times.map{h.deq}, %w(0 2 4 6 8)
  10.times.map{|i|2*i+1}.shuffle.map{|i|h.enq i.to_s, priority: i}
  assert 15.times.map{h.deq}, %w(1 3 5 7 9 10 11 12 13 14 15 16 17 18 19)
  nodes = 13.times.map{|i|h.enq i, priority: 13*i%13}
  nodes.each{|n|n.priority = n.value}
  assert 13.times.map{h.deq}, 13.times.to_a
  assert h.empty?, true

  h = klass.new
  10.times{|i|h.enq i, priority: 0}
  arr = 10.times.map{h.deq}
  assert arr, arr.sort

  h = klass.new{|v|-v.to_i}
  h.push(*20.times.map(&:to_s).shuffle)
  assert h.empty?, false
  assert h.size, 20
  assert 10.times.map{h.deq}, (10...20).map(&:to_s).reverse
end
require 'pry'
binding.pry
