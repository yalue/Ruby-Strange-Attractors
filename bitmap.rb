class Bitmap
  def initialize
    @pixel_array = nil
    @width = 0
    @height = 0
    @resolution = 2835
  end

  # Takes a 2-d rectangular array of 16-bit color values. Returns true on
  # success and false if the array had invalid dimensions.
  def set_pixel_array(array)
    return false if (array.size < 1)
    s = array[0].size
    return false if (s < 1)
    array.each {|r| return false if (r.size != s)}
    @width = s
    @height = array.size
    # Append a blank pixel to the end of each row to align each row to 32 bits
    array.size.times {|i| array[i] << 0} if ((@width % 2) != 0)
    @pixel_array = array
    true
  end

  # Sets the resolution in pixels per meter. Returns false if the given
  # resolution is invalid.
  def set_resolution(new_res)
    return false if (new_res < 0)
    return false if (new_res >= 0xffffffff)
    @resolution = new_res
    true
  end

  # Saves the image to the given filename, overwriting if a file already exists
  def save_file(filename)
    return nil if (@pixel_array == nil)
    f = File.open(filename, 'wb')
    f.write(format_file)
    f.close
  end

  # Takes a r, g and b color value between 0 and 31 and returns the 16bpp color
  def self.rgb_to_16bit(r, g, b)
    r &= 31
    g &= 31
    b &= 31
    (((r << 5) | g) << 5) | b
  end

  # Takes a rgb 16-bit value and returns an array: [r, g, b]
  def self.bits_to_rgb(n)
    n &= 0xffff
    r = (n >> 10) & 0x1f
    g = (n >> 5) & 0x1f
    b = n & 0x1f
    [r, g, b]
  end

  private
  # Returns a binary string of the formatted bitmap file data
  def format_file
    binary = bmp_header + dib_header
    @pixel_array.reverse.each {|row| binary << row.pack('S*')}
    binary
  end

  # Returns a formatted bitmap header
  def bmp_header
    bmp_header_size = 14
    dib_header_size = 40
    pixel_array_size = (@pixel_array[0].size * 2) * @height
    file_size = bmp_header_size + dib_header_size + pixel_array_size
    arr = "BM".unpack('S')
    arr += [file_size, 0, 0, bmp_header_size + dib_header_size]
    arr.pack("SLSSL")
  end

  # Returns a formatted DIB header
  def dib_header
    dib_header_size = 40
    coloring_planes = 1
    bits_per_pixel = 16
    pixel_array_compression = 0  # none
    pixel_array_size = (@pixel_array[0].size * 2) * @height
    arr = [dib_header_size, @width, @height, coloring_planes, bits_per_pixel]
    arr += [pixel_array_compression, pixel_array_size, @resolution]
    arr += [@resolution, 0, 0]
    arr.pack("LLlSSLLLLLL")
  end
end

