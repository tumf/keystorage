require 'helper'
require 'fileutils'

class TestKeystorage < Test::Unit::TestCase
  @@file = ".testkey"
  context "set / delete"  do
    setup do
      Keystorage.set("abc","def","ghi",@@file)
      Keystorage.set("abc","123","456",@@file)
    end
    teardown do
      FileUtils.rm(@@file)
    end

    should "file exists" do
      assert File.exists?(@@file)
    end

    should "exist def and 123" do
      assert_equal "ghi",Keystorage.get("abc","def",@@file)
      assert_equal "456",Keystorage.get("abc","123",@@file)
    end

    should "delete only def" do
      Keystorage.delete("abc","def",@@file)
      assert_equal "456",Keystorage.get("abc","123",@@file)
      assert_equal false,Keystorage.get("abc","def",@@file)
    end

    should "delete abc group" do
      Keystorage.delete("abc",nil,@@file)
      assert_equal false,Keystorage.get("abc","123",@@file)
      assert_equal false,Keystorage.get("abc","def",@@file)
    end
  end
end
