class Environment
  def self.set(env_updates, &block)
    new(env_updates).run(&block)
  end

  def initialize(env_updates)
    @env_updates = env_updates
    @old_values = {}
  end

  def run(&block)
    begin
      cache_old_values
      assign_env
      block.call
    ensure
      reset_env
    end
  end

  private

  attr_reader :env_updates, :old_values

  def update_keys
    env_updates.keys.map(&:to_s)
  end

  def cache_old_values
    @old_values = update_keys.inject({}) do |acc, key|
      acc[key] = ENV[key]
      acc
    end
  end

  def assign_env
    env_updates.each do |k, v|
      ENV[k.to_s] = v
    end
  end

  def reset_env
    old_values.each do |k, v|
      ENV[k] = v
    end
  end
end

RSpec.describe Environment do
  it "modifies the ENV only when the block is run" do
    updated_env = nil
    Environment.set FOO: "bar" do
      updated_env = ENV["FOO"]
    end

    expect(updated_env).to eq "bar"
    expect(ENV["FOO"]).to be_nil
  end

  it "allows the ENV to be updated and rolled back" do
    updated_env = nil
    Environment.set FOO: "bar" do
      updated_env = ENV["FOO"]
      ENV["FOO"] = "baz"
      expect(ENV["FOO"]).to eq "baz"
    end

    expect(updated_env).to eq "bar"
    expect(ENV["FOO"]).to be_nil
  end

  it "handles exceptions in the block by rolling back appropriately" do
    updated_env = nil

    expect do
      Environment.set FOO: "bar" do
        updated_env = ENV["FOO"]
        raise "Danger, Will Robinson!"
      end
    end.to raise_error RuntimeError, "Danger, Will Robinson!"

    expect(updated_env).to eq "bar"
    expect(ENV["FOO"]).to be_nil
  end
end
