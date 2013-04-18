require './bitmap'
require './drawing_canvas'

class Hopalong
  attr_accessor :a, :b, :c, :d
  def initialize
    @a = rand * 7.0
    @b = rand * 7.0
    @c = rand * 7.0
    @num_colors = 40
    set_iterations(600000)
    @canvas = DrawingCanvas.new(-300.0, 300.0, -300.0, 300.0, 800, 800)
  end

  # Changes the number of iterations to draw. Returns nil if invalid
  def set_iterations(i)
    return nil if (i <= 0)
    @iterations = i
    @num_colors = @iterations if (@num_colors >= @iterations)
  end

  # Sets the width and height of the output image, in pixels. Returns nil on
  # error.
  def set_output_dimensions(x, y)
    return nil if (x < 1)
    return nil if (y < 1)
    @canvas = DrawingCanvas.new(-300.0, 300.0, -300.0, 300.0, x, y)
  end

  # Returns the rendered canvas object
  def get_canvas
    @canvas
  end

  def draw
    x = 0.0
    y = 0.0
    x_new = 0.0
    y_new = 0.0
    1000.times do
      x_new = y - 1 - Math.sqrt((@b * x - 1 - @c).abs) * sign(x - 1)
      y_new = @a - x - 1
      x = x_new
      y = y_new
    end
    interval = @iterations / 80
    # Not RGB, just used to change colors after some iterations
    cur_color = 1
    color_update_iterations = @iterations / @num_colors
    print "          "
    80.times {print "-"}
    print "\nProgress: "
    @iterations.times do |i|
      x_new = y - 1 - Math.sqrt((@b * x - 1 - @c).abs) * sign(x - 1)
      y_new = @a - x - 1
      x = x_new
      y = y_new
      @canvas.set_point_exact(x, y, cur_color)
      cur_color += 1 if ((i % color_update_iterations) == 0)
      print "*" if ((i % interval) == 0)
    end
    puts ""
  end

  private
  # Returns -1.0 if less than 0, 1.0 if greater and 0.0 if equal to 0
  def sign(number)
    return 0.0 if (number == 0.0)
    return -1.0 if (number < 0.0)
    1.0
  end
end

class Pickover
  attr_accessor :a, :b, :c, :d
  def initialize
    @a = -1.5
    @b = 2.879789
    @c = 0.765145
    @d = 0.744728
    @iterations = 1000000
    @canvas = DrawingCanvas.new(-2.0, 2.0, -2.0, 2.0, 800, 800)
  end

  # Changes the number of iterations to draw. Returns nil if invalid
  def set_iterations(i)
    return nil if (i <= 0)
    @iterations = i
  end

  # Returns the rendered canvas object
  def get_canvas
    @canvas
  end

  # Sets the width and height of the output image, in pixels. Returns nil on
  # error.
  def set_output_dimensions(x, y)
    return nil if (x < 1)
    return nil if (y < 1)
    @canvas = DrawingCanvas.new(-2.0, 2.0, -2.0, 2.0, x, y)
  end

  def draw
    x = 0.1
    y = 0.1
    x_new = 0.0
    y_new = 0.0
    1000.times do
      x_new = Math.sin(y * @b) + @c * Math.sin(x * @b)
      y_new = Math.sin(x * @a) + @d * Math.sin(y * @a)
      x = x_new
      y = y_new
    end
    interval = @iterations / 80
    print "          "
    80.times {print "-"}
    print "\nProgress: "
    @iterations.times do |i|
      x_new = Math.sin(y * @b) + @c * Math.sin(x * @b)
      y_new = Math.sin(x * @a) + @d * Math.sin(y * @a)
      x = x_new
      y = y_new
      @canvas.draw_point(x, y)
      print "*" if ((i % interval) == 0)
    end
    puts ""
  end
end

# This attractor only populates the canvas with random points
class RandomAttractor
  attr_accessor :a, :b, :c, :d

  def initialize
    @iterations = 100000
    @canvas = DrawingCanvas.new(-2.0, 2.0, -2.0, 2.0, 800, 800)
  end

  def set_output_dimensions(x, y)
    return nil if (x < 1)
    return nil if (y < 1)
    @canvas = DrawingCanvas.new(-2.0, 2.0, -2.0, 2.0, x, y)
  end

  def draw
    puts "Drawing randomly..."
    @iterations.times do
      x = (rand * 4.0) - 2.0
      y = (rand * 4.0) - 2.0
      @canvas.draw_point(x, y)
    end
  end

  def get_canvas
    @canvas
  end

  def set_iterations(i)
    return nil if (i <= 0)
    @iterations = i
  end
end

