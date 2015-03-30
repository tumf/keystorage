require 'keystorage/cli'
describe Keystorage::CLI do
  subject { Keystorage::CLI::new(['-f','test.yml']).options[:file] }
  it {
    is_expected.to be ''
  }
end
