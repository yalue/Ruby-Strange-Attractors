require './bitmap'

# A canvas that the attractors are rendered onto.
class DrawingCanvas
  attr_accessor :max_x, :min_x, :max_y, :min_y, :x_res, :y_res
  attr_reader :canvas
  def initialize(min_x = -2.0, max_x = 2.0, min_y = -2.0, max_y = 2.0,
    x_res = 800, y_res = 800)
    @max_x = max_x
    @min_x = min_x
    @max_y = max_y
    @min_y = min_y
    @x_res = x_res.to_i
    @y_res = y_res.to_i
    @x_res = 1 if (@x_res <= 0)
    @y_res = 1 if (@y_res <= 0)
    @d_x = @x_res.to_f / (@max_x - @min_x)
    @d_y = @y_res.to_f / (@max_y - @min_y)
    @shift_x = -(@min_x * @d_x)
    @shift_y = -(@min_y * @d_y)
    @canvas = []
    @y_res.times do |i|
      @canvas << []
      @x_res.times do
        @canvas[i] << 0
      end
    end
  end

  # Increments the numeric value of the pixel at coordinate (x, y)
  def draw_point(x, y)
    i = translate_coordinate(x, y)
    return if (!i)
    @canvas[i[1]][i[0]] += 1
  end

  # Similar to draw_point, but sets the value of the pixel to the given number
  def set_point_exact(x, y, n)
    i = translate_coordinate(x, y)
    return if (!i)
    @canvas[i[1]][i[0]] = n
  end

  def get_bitmap
    @canvas
  end

  # Returns the bitmap colored using the given gradient. The gradient is an
  # array of format [[R, G, B], [...], [R, G, B]], where each R G and B is a
  # number ranging from 0 to 255
  def get_gradient_bitmap(gradient_array)
    to_return = get_normalized_array
    to_return.size.times do |i|
      to_return[i].size.times do |j|
        to_return[i][j] = get_gradient_color(gradient_array, to_return[i][j])
      end
    end
    to_return
  end

  # Returns an array of all coordinates normalized between 0 and 1, where 1 was
  # the highest-marked and 0 was the lowest.
  def get_normalized_array
    max = 0
    min = @canvas[0][0]
    normalized = []
    @y_res.times do |i|
      normalized << []
      @x_res.times do |j|
        max = @canvas[i][j] if (@canvas[i][j] > max)
        min = @canvas[i][j] if (@canvas[i][j] < min)
        normalized[i] << 0.0
      end
    end
    scale = 1.0 / (max.to_f - min.to_f)
    scale = 0.0 if (scale.nan?)
    @y_res.times do |i|
      @x_res.times do |j|
        normalized[i][j] = (@canvas[i][j] - min).to_f * scale
      end
    end
    normalized
  end

  private
  # Takes a gradient array and a number between 0.0 and 1.0 and returns the 16
  # bit RGB color from the gradient
  def get_gradient_color(gradient_array, number)
    return 0 if (gradient_array.size == 0)
    scale = 31.0 / 255.0
    float_index = number * gradient_array.size.to_f
    base_index = float_index.floor
    if (base_index >= (gradient_array.size - 1))
      c = gradient_array[-1]
      return Bitmap.rgb_to_16bit((c[0] * scale).round, (c[1] * scale).round,
        (c[2] * scale).round)
    end
    percent_diff = sqrt_scale(float_index - base_index.to_f)
    c_1 = gradient_array[base_index]
    c_2 = gradient_array[base_index + 1]
    c_new = [0, 0, 0]
    c_new[0] = ((c_2[0].to_f - c_1[0].to_f) * percent_diff) + c_1[0]
    c_new[1] = ((c_2[1].to_f - c_1[1].to_f) * percent_diff) + c_1[1]
    c_new[2] = ((c_2[2].to_f - c_1[2].to_f) * percent_diff) + c_1[2]
    Bitmap.rgb_to_16bit((c_new[0] * scale).round, (c_new[1] * scale).round,
      (c_new[2] * scale).round)
  end

  # Takes an (x, y) floating point coordinate and returns an [x, y] index into
  # the array of pixels. Returns nil if the coordinate is off the image.
  def translate_coordinate(x, y)
    index_x = ((x * @d_x) + @shift_x).round
    index_y = ((y * @d_y) + @shift_y).round
    index_x -= 1 if (index_x >= x_res)
    index_y -= 1 if (index_y >= y_res)
    return nil if (index_x >= x_res)
    return nil if (index_y >= y_res)
    return nil if (index_x < 0)
    return nil if (index_y < 0)
    [index_x, index_y]
  end

  def sqrt_scale(number)
    result = number ** 0.5
    return 0.0 if (result < 0.0)
    return 1.0 if (result > 1.0)
    result
  end
end

