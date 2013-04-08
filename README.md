Ruby-Strange-Attractors
=======================

A simple strange attractor renderer in Ruby
-------------------------------------------

Renders strange attractors in fully native ruby.

Usage: `ruby draw_attractor.rb <type> <output image> [options]`.
The output image will always be a bitmap.

For now, the only available types are "hopalong" or "pickover".

Available options are:

 - `-x_res <the horizontal resolution of the image>`: The width, in pixels

 - `-y_res <the vertical resolution of the image>`: The height, in pixels

 - `-i <iterations>`: The number of iterations to draw

 - `-gradient <file name>`: The name of a file defining a color gradient. The
   file should contain any number of lines of the format R G B, where R, G and
   B are numbers between 0 and 255 representing the intensity of the red, blue
   and green color values.

 - `-a <number>` `-b <number>` `-c <number>` `-d <number>`: Parameters to the
   particular attractor

 - `-antialias <true or false>`: Whether to antialias a resulting image.
   Defaults to 'false'. Works better for some types than others.

