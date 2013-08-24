bpp
----
Bpp is a preprocessor for BASH. What this means is that it will generate a script readable by Bash. To cause the program to automatically execute the scripts, you can add the line system("bash ./"++outp), which will retain the file. This line was left out to make manual edits before running scripts.

What to use bpp for
--------------------
bpp is not a catch-all kind of preprocessor. It provides features specifically designed for directory layouts. If you want to make a script to package a program, or set up a user's home directory, or map out a project with templates, bpp is the program for you. If you will not be manipulating directories often, using plain BASH may be enough. At this time there is no frontend to append to be used with vanilla BASH, so the file features of bpp are not very portable.

How do I use bpp?
------------------
For the time being, a sample file, called sample.bpp is provided.
