class Mips
  attr_accessor :grid, :inputs, :state, :outputs, :gtk

  def tick
    defaults
    render
    calc
    process_inputs
  end

  def defaults
    state.num_registers  ||= 64   #32 integer and logic instructions and 32 floating point instructions
    state.registers      ||= Array.new(state.num_registers)
    state.register_hash  ||= Hash.new
    state.function_hash  ||= Hash.new
    state.register_names ||= ["zero", "at", "v", "a", "t", "s", "t", "k", "gp", "sp", "fp", "ra", "f"]
    state.register_count ||= [     1,    1,   2,   4,   8,   8,   2,   2,    1,    1,    1,    1,  32]
    state.current_line   ||= -1
    state.input          ||= gtk.read_file("app/input.txt").split("\r\n")
    state.output_state   ||= :none

    create_register_hash() if state.register_hash.length == 0
    create_function_hash() if state.function_hash.length == 0
    #process_function()     if state.current_line == -1
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
    state.function_hash["li"]   = 0
    state.function_hash["move"] = 0
  end

  def render
    #Render basic graphics
    outputs.borders << [ 50,  50, 500, 570]
    outputs.borders << [720,  50, 500, 250]
    outputs.borders << [720, 370, 500, 250]

    outputs.labels << [300, 667, "Registers", 5, 1]
    outputs.labels << [970, 667, "File", 5, 1]
    outputs.labels << [970, 345, "Console", 5, 1]

    #Render all the registers
    tempX = 67
    tempY = 607
    count = 0
    state.register_count.length.times do |n|
      state.register_count[n].times do |m|
        outputs.labels << [tempX, tempY, "$" + state.register_names[n] + m.to_s + ": " +
                                         state.registers[count].to_s, 1]
        count += 1
        tempY -= 35
        tempX += 125 if count % 16 == 0
        tempY =  607 if count % 16 == 0
      end
    end

    #Render the File Text
    start = state.current_line - 6
    tempX = 730
    tempY = 613
    increasingAlpha = 30
    7.times do |n|
      if start + n < state.input.length && start + n >= 0
        #puts(state.input[start + n] + " " + (start + n).to_s)
        outputs.labels << [tempX, tempY, state.input[start + n] + "", 1, 0, 0, 0, 0, increasingAlpha]
      end
      tempY -= 35
      increasingAlpha += 31
    end
  end

  def calc
    state.current_line = [state.current_line, state.input.length - 1].min

  end

  def process_inputs
    if inputs.keyboard.space && state.current_line + 1 != state.input.length
      process_function()
    end
  end

  def process_function
    if state.output_state != :end_of_file && state.output_state != :error
      state.current_line += 1
      state.current_line += 1 while state.input[state.current_line] == "" && state.input[state.current_line] == "\r\n"

      current_line = state.input[state.current_line].split(" ")

      if current_line == ""
        #Reached End of File
        state.output_state = :end_of_file
      else
        if state.function_hash.has_key?(current_line[0])
          #Execute said function
          determine_function(current_line[0], current_line[1].chop, current_line[2]) #chop removes the comma
        else
          #It's a variable
        end
      end
    end
  end

  def determine_function (func, param1, param2)
    li(param1, param2) if func == "li"
  end

  def li (var, integer)
    index = state.register_hash.fetch(var)
    state.registers[index] = integer
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
