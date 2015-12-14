require './graber/process'

g = Graber::Process.new(ARGV[0], ARGV[1])
g.parse
g.download
