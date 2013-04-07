if ((ARGV.size < 2) || !(ARGV[0] ~= /hopalong|pickover/i))
  puts "Usage: ruby draw_attractor.rb <attractor> <image name> [options]"
  exit 1
end
