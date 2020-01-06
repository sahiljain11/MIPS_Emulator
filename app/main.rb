class Mips
  attr_accessor :grid, :inputs, :state, :outputs

  def tick
    defaults
    render
    calc
    process_inputs
  end

  def defaults

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
