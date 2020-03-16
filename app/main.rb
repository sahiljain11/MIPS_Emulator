# All of the following code was based around the following article:
# https://minnie.tuhs.org/CompArch/Resources/mips_quick_tutorial.html

class Mips
  attr_accessor :grid, :inputs, :state, :outputs, :gtk

  def tick
    defaults
    render
    calc
    process_inputs
  end

  def defaults
    state.num_registers   ||= 64   #32 integer and logic instructions and 32 floating point instructions
    state.registers       ||= Array.new(state.num_registers)
    state.register_hash   ||= Hash.new
    state.function_hash   ||= Hash.new   #present for faster computation
    state.variable_hash   ||= Hash.new
    state.method_hash     ||= Hash.new   #present for user generated methods
    state.register_names  ||= ["zero", "at", "v", "a", "t", "s", "t", "k", "gp", "sp", "fp", "ra", "f"]
    state.register_count  ||= [     1,    1,   2,   4,   8,   8,   2,   2,    1,    1,    1,    1,  32]
    state.current_line    ||= -1
    state.input           ||= gtk.read_file("app/code.txt").split("\r\n")
    state.console_state   ||= :none
    state.register_state  ||= 1
    state.register_button ||= [500, 630, 50, 50]
    state.file_button     ||= [1170, 630, 50, 50]
    state.button_opacity  ||= [0, 0]

    create_register_hash() if state.register_hash.length == 0
    create_function_hash() if state.function_hash.length == 0
    create_method_hash()   if state.current_line == -1
    process_function()     if state.current_line == -1
  end

  def create_register_hash
    #create hash of all registers
    count = 0
    num_t = 0   #keeps track of number of t registers

    state.register_count.length.times do |n|
      state.register_count[n].times do |m|
        if state.register_names[n] != "t"
          state.register_hash["$" + state.register_names[n] + m.to_s] = count
        else
          state.register_hash["$t" + num_t.to_s] = count
          num_t += 1
        end
        count += 1
      end
    end
  end

  def create_function_hash
    #numbers aren't important here. adding to hash is important though
    #remember to implement these functions near the bottom of the code
    state.function_hash["li"]   = 0
    state.function_hash["move"] = 1
  end

  def create_method_hash
    #Go through entire text file. If there's a ".foo", add that method
    #and its line number to the hash (also technically just conduct a jump
    #command, but hash simplifies this
    (state.input.length).times do |n|
      line = state.input[n].split(" ")
      if (line.length == 1 && line[0][0] == '.')
        state.method_hash[line[0]] = n
      end
    end
  end

  def render
    #Render basic graphics
    outputs.borders << [ 50,  50, 500, 570]
    outputs.borders << [720,  50, 500, 250]
    outputs.borders << [720, 370, 500, 250]

    outputs.labels << [300, 667, "Registers", 5, 1]
    outputs.labels << [970, 667, "File", 5, 1]
    outputs.labels << [970, 345, "Console", 5, 1]

    #Create box for switching between terminals on the registers
    outputs.labels  << [527, 667, state.register_state.to_s, 5, 1]
    outputs.borders << state.register_button
    outputs.solids  << [state.register_button[0], state.register_button[1],
                        state.register_button[2], state.register_button[3],
                        40, 220, 240, state.button_opacity[0]]

    #Create box for reading a line
    outputs.labels  << [1196, 667, (state.current_line + 1).to_s, 5, 1]
    outputs.borders << state.file_button
    outputs.solids  << [state.file_button[0], state.file_button[1],
                        state.file_button[2], state.file_button[3],
                        255, 40, 240, state.button_opacity[1]]

    render_registers()
    render_file_text()
    render_console()
  end

  def render_registers
    #Render all the registers
    tempX = 67
    tempY = 607
    count = 0
    state.register_count.length.times do |n|
      state.register_count[n].times do |m|
        if ((state.registers.size / 2) * (state.register_state - 1) <= count &&
            count < (state.registers.size / 2) * state.register_state)
                outputs.labels << [tempX, tempY, "$" + state.register_names[n] + m.to_s + ": " +
                                                 state.registers[count].to_s, 1]
          tempY -= 35
          tempX += 250 if (count + 1) % (state.registers.size / 4) == 0
          tempY =  607 if (count + 1) % (state.registers.size / 4) == 0
        end
        count += 1
      end
    end
  end

  def render_file_text
    #Render the File Text
    start = state.current_line - 6
    tempX = 730
    tempY = 613
    increasingAlpha = 30
    7.times do |n|
      if start + n < state.input.length && start + n >= 0
        outputs.labels << [tempX, tempY, state.input[start + n] + "", 1, 0, 0, 0, 0, increasingAlpha]
      end
      tempY -= 35
      increasingAlpha += 31
    end
  end

  def render_console
    outputs.labels << [730, 285, "You have reached the end of the file.", 1, 0,  30, 70, 195, 255] if state.console_state == :end_of_file
    outputs.labels << [730, 285, "Error found.",                          1, 0, 192,  57,  43, 255] if state.console_state == :error
  end

  def calc

  end

  def process_inputs

    #Check for keyboard input in regards to reading a line
    if inputs.keyboard.space && state.current_line + 1 != state.input.length
      process_function()
      inputs.keyboard.clear
    end

    #Check for keyboard input for switching between register windows
    if inputs.keyboard.one && state.register_state == 2
      state.register_state = 1
      inputs.keyboard.clear
    elsif inputs.keyboard.two && state.register_state == 1
      state.register_state = 2
      inputs.keyboard.clear
    end

    #Check and adjust values for the register button
    if (inputs.mouse.position.x > state.register_button[0] && 
        inputs.mouse.position.x < state.register_button[0] + state.register_button[2] &&
        inputs.mouse.position.y > state.register_button[1] && 
        inputs.mouse.position.y < state.register_button[1] + state.register_button[3])

      state.button_opacity[0] = 255
      if inputs.mouse.click
        state.register_state = (state.register_state == 1) ? 2 : 1
        inputs.mouse.clear
      end
    else
      state.button_opacity[0] = 0
    end

    #Check and adjust values for the file button
    if (inputs.mouse.position.x > state.file_button[0] && 
        inputs.mouse.position.x < state.file_button[0] + state.file_button[2] &&
        inputs.mouse.position.y > state.file_button[1] &&
        inputs.mouse.position.y < state.file_button[1] + state.file_button[3])

      state.button_opacity[1] = 255
      if inputs.mouse.click
        process_function()
        inputs.mouse.clear
      end
    else
      state.button_opacity[1] = 0
    end

  end

  def process_function
    if state.console_state != :end_of_file && state.console_state != :error
      state.current_line += 1

      if state.current_line < state.input.length
        current_line = state.input[state.current_line].split(" ")
        
        if state.console_state != :end_of_file && state.console_state != :error
          if state.function_hash.has_key?(current_line[0])
            #Execute said function. chop removes the comma
            determine_function(current_line[0], current_line[1].chop, current_line[2])
          elsif is_variable?(current_line[0])
            #making a variable
            state.variable_hash[current_line[0][0, current_line[0].length - 1]] = current_line[2]
          elsif state.method_hash.has_key?(current_line[0])
            #skip! the hash already has the method in it, so ignore it
            #if a function calls this, it'll go here
          end
        end

        #Reached End of File
        state.console_state = :end_of_file if state.current_line >= state.input.length - 1
      end
      
    end
  end

  def is_variable?(var)
    return var[var.length - 1] == ':'
  end

  def determine_function (func, param1, param2)
    #call on the function given by what the file is asking to do
    #any flags that should be checked can be done below in the functions themselves
    li(param1, param2)   if func == "li"
    move(param1, param2) if func == "move"
  end

  def li (var, integer)
    state.registers[state.register_hash.fetch(var)] = integer
  end

  def move(var1, var2)
    hash_check1 = var1 if state.register_hash.key?(var1)

    hash_check2 = state.variable_hash.fetch(var2) if state.variable_hash.key?(var2)
    hash_check2 = state.registers[state.register_hash.fetch(var2)] if state.register_hash.key?(var2)

    if (hash_check1 == nil || hash_check2 == nil)
      state.console_state = :error
    else
      state.registers[state.register_hash.fetch(hash_check1)] = hash_check2
    end
  end
  
end

$mips = Mips.new

def tick args
  args.gtk.log_level = :off
  $mips.grid    = args.grid
  $mips.inputs  = args.inputs
  $mips.state   = args.state
  $mips.outputs = args.outputs
  $mips.gtk     = args.gtk
  $mips.tick
end
