class Calculator
  def self.run(start:)
    yield Operations.new(start)
  end

  class Operations
    def initialize(num)
      @num = num
    end

    def add(v)
      @num += v
    end

    def multiply_by(v)
      @num = @num * v
    end

    def subtract(v)
      @num -= v
    end

    def clear
      @num = 0
    end
  end
end

describe Calculator do
  it "allows for addition" do
    result = Calculator.run(start: 5) do |c|
      c.add 5
      c.add 2
      c.add 10
    end

    expect(result).to eq 22
  end

  it "allows for other operations" do
    result = Calculator.run(start: 5) do |c|
      c.add 5
      c.multiply_by 2
      c.subtract 15
    end

    expect(result).to eq 5
  end

  it "allows for the value to be cleared" do
    result = Calculator.run(start: 5) do |c|
      c.clear
    end

    expect(result).to eq 0
  end
end
