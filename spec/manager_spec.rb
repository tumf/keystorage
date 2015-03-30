require 'keystorage/manager'
describe Keystorage::Manager do
  before {
    @ks = Keystorage::Manager.new
  }
  subject { @ks.get("mygroup","key") }
  it {
    is_expected.to be ""
  }

end
  # ks = keystorage::Manager.new(:file =>"",:secret=> "P@ssword")
  # ks.get("mygroup","mykey") # => "mysecret"
