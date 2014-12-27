Ruby Strange Attractors
=======================

A simple strange attractor renderer in Ruby
-------------------------------------------

Renders strange attractors in pure ruby. Requires ruby 1.9.3 or higher (for
better zlib support).

Usage: `ruby draw_attractor.rb <type> <output image> [options]`.

Basic example: `ruby draw_attractor.rb pickover pickover.png`.

For now, the only available types are "hopalong" or "pickover".

Available options are:

 - `-x_res <the horizontal resolution of the image>`: The width, in pixels

 - `-y_res <the vertical resolution of the image>`: The height, in pixels

 - `-iterations <iterations>`: The number of iterations to draw

 - `-gradient <file name>`: The name of a file defining a color gradient. The
   file should contain any number of lines where each line has the format
   `R G B`, where R, G and B are 3 space-separated numbers between 0 and 255
   representing the intensity of the red, blue and green color values.

 - `-a <number>` `-b <number>` `-c <number>` `-d <number>`: Parameters to the
   particular attractor

 - `-antialias <true or false>`: Whether to antialias a resulting image.
   Defaults to 'false'. Works better for some types than others.

 - `-output_format <bitmap or png>`: Output is png by default, but this may be
   used to output a bitmap instead.
