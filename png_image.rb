require 'zlib'
require './bitmap'

class PNGImage
  def initialize
    @bitmap = Bitmap.new
    @rows = nil
    @comment = ""
  end

  # Takes a 2-D rectangular array of 16-bit color values. Returns true on
  # success and false if the array had invalid dimensions.
  def set_pixel_array(array)
    @bitmap.set_pixel_array(array)
    @rows = bitmap_to_truecolor
  end

  # Performs a single full-image AA pass. Basically blurs the whole thing.
  def antialias
    @bitmap.antialias
    @rows = bitmap_to_truecolor
  end

  # Sets a comment to include in a text chunk in the PNG
  def set_comment(comment)
    @comment = comment.to_s
  end

  # Saves the file with the given name. Overwrites if the file already exists.
  # Returns nil if no image data has been set yet.
  def save_file(filename)
    return nil if (!@rows)
    File.open(filename, 'wb') {|f| f.write(file_binary)}
  end

  private
  # Returns the formatted PNG binary, to be written to a file.
  def file_binary
    b = png_header
    b += ihdr_chunk
    b += idat_chunk
    b += text_chunk("Creation Time", Time.now.strftime("%d %B %Y %H:%M:%S %z"))
    b += text_chunk("Comment", @comment)
    b += iend_chunk
    b
  end

  # Returns the formatted PNG header as a binary string.
  def png_header
    [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a].pack("C*")
  end

  # Returns the formatted IHDR chunk for the image
  def ihdr_chunk
    width = @bitmap.width
    height = @bitmap.height
    # 8 bits per color, use true color (rather than indexed)
    bit_depth = 8
    color_type = 2
    compression_method = 0
    # 0 is the only method available.
    filter_method = 0
    # No interalcing
    interlace_method = 0
    chunk_data = [width, height, bit_depth, color_type, compression_method,
      filter_method, interlace_method].pack("L>L>CCCCC")
    generate_chunk("IHDR", chunk_data)
  end

  # Returns the formatted IDATA chunk for the image
  def idat_chunk
    data = ""
    @rows.size.times {|i| data << filter_line(i).pack("C*")}
    z = Zlib::Deflate.new(9, 12, Zlib::DEF_MEM_LEVEL)
    data = z.deflate(data, Zlib::FINISH)
    generate_chunk("IDAT", data)
  end

  # Retunrs the formatted IEND chunk for the image
  def iend_chunk
    generate_chunk("IEND", "")
  end

  # Returns a formatted text chunk for the image
  def text_chunk(name, text)
    generate_chunk("tEXt", name + "\0" + text)
  end

  # Returns a formatted PNG chunk containing the given binary data
  def generate_chunk(type, data)
    length = data.size
    # Ensure the type is 4 bytes long. Prepend lowercase letters if length < 4
    type = type.rjust(4, 'z')
    type = type.unpack("C*")[0..3].pack("C*")
    crc = Zlib::crc32(type + data)
    [length].pack("L>") + type + data + [crc].pack("L>")
  end

  # Converts a 16-bit bitmap object to an array of rows of bytes, where each
  # group of 3 bytes is a 24-bit RGB color.
  def bitmap_to_truecolor
    truecolor = []
    @bitmap.height.times do |i|
      truecolor << []
      @bitmap.width.times do |j|
        rgb = Bitmap.bits_to_rgb(@bitmap.pixel_array[i][j])
        truecolor[i] << color_5_to_8(rgb[0])
        truecolor[i] << color_5_to_8(rgb[1])
        truecolor[i] << color_5_to_8(rgb[2])
      end
    end
    truecolor
  end

  # Returns the filtered version of line i, prepended with the appropriate byte
  # indicating the filtering method. The 'best' filter is simply determined by
  # which method produces the smallest sum of all bytes in a line.
  def filter_line(i)
    best = no_filter(i)
    score = row_magnitude(best)
    possible = sub_filter(i)
    possible_score = row_magnitude(possible)
    if (possible_score < score)
      best = possible
      score = possible_score
    end
    possible = up_filter(i)
    possible_score = row_magnitude(possible)
    if (possible_score < score)
      best = possible
      score = possible_score
    end
    possible = average_filter(i)
    possible_score = row_magnitude(possible)
    if (possible_score < score)
      best = possible
      score = possible_score
    end
    possible = paeth_filter(i)
    possible_score = row_magnitude(possible)
    if (possible_score < score)
      best = possible
      score = possible_score
    end
    best
  end

  # Returns line i with the none filter applied
  def no_filter(i)
    [0] + @rows[i]
  end

  # Returns line i with the sub filter applied
  def sub_filter(i)
    filtered = [1]
    @rows[i].size.times do |j|
      if (j < 3)
        filtered << @rows[i][j]
        next
      end
      filtered << mod256_difference(@rows[i][j], @rows[i][j - 3])
    end
    filtered
  end

  # Returns line i with the up filter applied
  def up_filter(i)
    filtered = [2]
    return filtered + @rows[i] if (i == 0)
    @rows[i].size.times do |j|
      filtered << mod256_difference(@rows[i][j], @rows[i - 1][j])
    end
    filtered
  end

  # Returns line i with the average filter applied
  def average_filter(i)
    filtered = [3]
    @rows[i].size.times do |j|
      # a = the color to the left
      a = ((j - 3) < 0) ? 0 : @rows[i][j - 3]
      # b = the color above
      b = (i == 0) ? 0 : @rows[i - 1][j]
      filtered << mod256_difference(@rows[i][j], (a + b) / 2)
    end
    filtered
  end

  # Returns line i with the Paeth filter applied
  def paeth_filter(i)
    filtered = [4]
    @rows[i].size.times do |j|
      # a = color to the left
      a = ((j - 3) < 0) ? 0 : @rows[i][j - 3]
      # b = color above
      b = (i == 0) ? 0 : @rows[i - 1][j]
      # c = color above and to the left
      c = ((i == 0) || ((j - 3) < 0)) ? 0 : @rows[i - 1][j - 3]
      filtered << mod256_difference(@rows[i][j], paeth_predictor(a, b, c))
    end
    filtered
  end

  # The PaethPredictor function as defined in the PNG specification
  def paeth_predictor(a, b, c)
    p = a + b - c
    pa = (p - a).abs
    pb = (p - b).abs
    pc = (p - c).abs
    return a if ((pa <= pb) && (pa <= pc))
    return b if (pb <= pc)
    c
  end

  # Returns the difference between a and b as an unsigned integer mod 256
  def mod256_difference(a, b)
    return 0 if (a == b)
    return (256 - ((b - a) % 256)) if (b > a)
    (a - b) % 256
  end

  # Takes a filtered row, and computes the sum of the absolute value of all
  # bytes, treating each byte as a signed 8-bit integer.
  def row_magnitude(row)
    row[1..-1].pack("C*").unpack("c*").inject(0) {|res, e| res + e.abs}
  end

  # Takes a 5-bit color value (from 0 to 31) and returns the corresponding
  # color from 0 to 255.
  def color_5_to_8(color)
    return 0 if (color == 0)
    ((color + 1) * 8) - 1
  end
end

