# MIPS Emulator

![Render](/render.PNG)

## About

In this app, I created a basic MIPS emulator package for developers interested in working with MIPS scripts within DragonRuby.

## Development

To work on this, I added three basic things: labels, functions, and variables.

### Labels

For labels, I simply stored all of the labels and line numbers in a hash called "state.method_hash". This generalization matches what happens within the memory of the computer as labels are merely memory addresses.

### Functions
For functions, I needed to check if a given function had been implemented yet. To do this, I created "state.function_hash" which will only denote if a function is present or not. This needs to be updated manually when adding more functions.

If a function is found to be implemented, add that function to the Ruby function created called "determine_function". Then, create that function and do whatever necessary operations you wish to do. For parameters, it's in the order that follows:

```
func    param1, param2
```
Note that param1 could be a register index or a variable. For complete implementation, both will need to be considered. Any flags that you wish to mark or check will need to be implemented per function.

### Variables

For variables, I created a "state.variable_hash", which is a hash that simply stores the values given in the input.txt file.

## DragonRuby

To create this game, I utilized the game engine DragonRuby. DragonRuby is an incredibly powerful game development engine that provides simplicity without taking away functionality. For more information, pleaes visit the following link:

https://dragonruby.itch.io/dragonruby-gtk

