# rubik

A rubik's cube game for TI calculators

Original by Mikhail Lavrov: http://www.ticalc.org/archives/files/fileinfo/405/40505.html

## Controls
The arrow keys are used to rotate the cube so you can look at it from different angles. To actually move the cube's layers, you use the number pad: the keys 1-9 represent the front face of the cube, and pressing three of them in order rotates a layer of the cube (for example, 1-2-3 rotates the bottom row layer left; 2-5-8 rotates the middle column layer up; 8-9-6 rotates the front face clockwise). It's fairly intuitive if you think of the motion of twisting a physical cube.

You can also reset or quickly scramble the cube. Press MODE and the cube will be reset. Press XTθn and the cube will be scrambled - this beats randomly shuffling the cube around yourself.

Finally, press CLEAR to exit the program.

## Compiling

First, install the [KnightOS SDK](http://www.knightos.org/sdk).

    $ knightos init
    $ make
    $ make run # to test
    $ make package # to produce an installable package

## Installing

Use `make package` to get a package that you can install.
