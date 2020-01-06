class Mips
  attr_accessor :grid, :inputs, :state, :outputs

  def tick
    defaults
    render
    calc
    process_inputs
  end

  def defaults
    state.num_registers ||= 64   #32 32-bit integer and logic instructions and 32-bit floating point instructions
    state.registers     ||= Array.new(state.num_registers)
    state.register_hash ||= Hash.new

    create_register_hash() if state.register_hash.length == 0
  end

  def create_register_hash
    #create hash of all registers
    register_names = ["zero", "at", "v", "a", "t", "s", "t", "k", "gp", "sp", "fp", "ra", "f"]
    register_count = [     1,    1,   2,   4,   8,   8,   2,   2,    1,    1,    1,    1,  32]
    count = 0
    num_t = 0   #keeps track of number of t registers

    register_count.length.times do |n|
      register_count[n].times do |m|
        if register_names[n] != "t"
          state.register_hash["$" + register_names[n] + m.to_s] = count
        else
          state.register_hash["$t" + num_t.to_s] = count
          num_t += 1
        end
        count += 1
      end
    end
  end

  def render

  end

  def calc

  end

  def process_inputs

  end
  
end

$mips = Mips.new

def tick args
    $mips.grid    = args.grid
    $mips.inputs  = args.inputs
    $mips.state   = args.state
    $mips.outputs = args.outputs
    $mips.tick
end
