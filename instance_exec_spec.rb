class HashDSL
  def self.run(&block)
    Runner.new.instance_exec(&block).__result__
  end

  class Runner
    def initialize
      @result = {}
    end

    def method_missing(name, *args, &block)
      @result[name.to_sym] = if block_given?
        Runner.new.instance_exec(&block).__result__
      else
        args.first
      end
      self
    end

    def __result__
      @result
    end
  end
end

describe HashDSL do
  it "allows for arbitrary keys and values" do
    result = HashDSL.run do
      key 15
      other "thing"
    end

    expect(result).to eq({ key: 15, other: "thing" })
  end

  it "allows for nesting of structures" do
    result = HashDSL.run do
      key do
        foo "one"
        bar true
      end
      other "thing"
    end

    expect(result).to eq({ key: { foo: "one", bar: true }, other: "thing" })
  end
end
