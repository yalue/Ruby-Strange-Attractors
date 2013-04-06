require './attractor'
require './bitmap'

def get_arg_value(arg, args)
  i = args.index("-" + arg)
  return nil if (!i)
  return nil if (!args[i + 1])
  args[i + 1]
end

# Returns a hash of the arguments provided or nil if the arguments were not
# valid.
def get_args_hash(arguments)
  return nil if (ARGV.size < 2)
  to_return = {}
  to_return[:type] = ARGV[0]
  to_return[:output] = ARGV[1]
  to_return[:iterations] = get_arg_value("i", arguments)
  to_return[:x_res] = get_arg_value("x_res", arguments)
  to_return[:y_res] = get_arg_value("y_res", arguments)
  to_return[:a] = get_arg_value("a", arguments)
  to_return[:b] = get_arg_value("b", arguments)
  to_return[:c] = get_arg_value("c", arguments)
  to_return[:d] = get_arg_value("d", arguments)
end

usage_string = "Usage: ruby #{__FILE__} <type> <output file> [options]"
supported_types = {
  "pickover"=>Pickover,
  "hopalong"=>Hopalong
}

args = get_args_hash(ARGV)
if (!args)
  puts usage_string
  exit 1
end
if (!supported_types[args[:type]])
  puts usage_string
  exit 1
end

