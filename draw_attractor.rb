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
  return nil if (arguments.size < 2)
  to_return = {}
  to_return[:type] = ARGV[0]
  to_return[:output] = ARGV[1]
  to_return[:iterations] = get_arg_value("iterations", arguments)
  to_return[:x_res] = get_arg_value("x_res", arguments)
  to_return[:y_res] = get_arg_value("y_res", arguments)
  to_return[:a] = get_arg_value("a", arguments)
  to_return[:b] = get_arg_value("b", arguments)
  to_return[:c] = get_arg_value("c", arguments)
  to_return[:d] = get_arg_value("d", arguments)
  to_return[:gradient_file] = get_arg_value("gradient", arguments)
  to_return[:antialias] = get_arg_value("antialias", arguments)
  to_return
end

# Returns a gradient array, or nil if the filename was invalid.
def parse_gradient_file(filename)
  lines = nil
  begin
    File.open(filename, 'rb') {|f| lines = f.read.split(/\n+/)}
  rescue
    puts "Error opening file #{filename}."
    return nil
  end
  # Convert each line to an array of 3 integers, remove bad lines.
  lines.map! {|line| line.split(/\s+/).map! {|i| i.to_i}}
  lines.reject! {|a| a.size != 3}
  lines.reject! {|a| (a.max > 255) || (a.min < 0)}
  lines
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

gradient = nil
gradient = parse_gradient_file(args[:gradient_file]) if (args[:gradient_file])
gradient = [[0, 0, 0], [255, 255, 255]] if (!gradient)
x_res = 800
y_res = 800
x_res = args[:x_res].to_i if (args[:x_res])
y_res = args[:y_res].to_i if (args[:y_res])
a = supported_types[args[:type]].new
a.set_iterations(args[:iterations].to_i) if (args[:iterations])
a.a = args[:a].to_f if (args[:a])
a.b = args[:b].to_f if (args[:b])
a.c = args[:c].to_f if (args[:c])
a.d = args[:d].to_f if (args[:d])
a.set_output_dimensions(x_res, y_res)
a.draw
output = Bitmap.new
puts "Converting to bitmap..."
output.set_pixel_array(a.get_canvas.get_gradient_bitmap(gradient))
if (args[:antialias] =~ /true/i)
  puts "Antialiasing..."
  output.antialias
end
output.save_file(args[:output])

