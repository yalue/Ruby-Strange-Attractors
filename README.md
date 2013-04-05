Ruby-Strange-Attractors
=======================

A simple strange attractor renderer in Ruby
-------------------------------------------

For now, only Hopalong and Pickover attractors are implemented.

Usage: `ruby draw_attractor.rb <hopalong|pickover> <output image> [options]`
The output image will always be a bitmap.
Available options are:

 - `-x_res <the horizontal resolution of the image>`: The width, in pixels

 - `-y_res <the vertical resolution of the image>`: The height, in pixels

 - `-i <iterations>`: The number of iterations to draw

 - `-a <number>` `-b <number>` `-c <number>` `-d <number>`: Parameters to the
   particular attractor

