require 'keystorage/manager'

def yaml name
  File.join(File.dirname(__FILE__),'files',"#{name}.yml")
end

describe Keystorage::Manager do
  let(:files){
    {
      "1"=>{"@"=>{"sig"=>"abc"}},
      "2"=>{"@"=>{"sig"=>"abc","token"=>"def"},"g1"=>{ "k1" => "abcdefg", "k2" =>"" },"g2"=>{}},
    }
  }
  before {  @manager = Keystorage::Manager.new }

  # public methods
  describe "#groups" do
    subject { @manager.groups }
    it "returns array of groups" do
      allow(@manager).to receive(:file)
                          .and_return(files["2"])
      is_expected.to eq ["g1","g2"]
    end
  end

  describe "#keys" do
    subject { @manager.keys("g1") }
    it "returns array of keys" do
      allow(@manager).to receive(:file)
                          .and_return(files["2"])

      is_expected.to eq ["k1","k2"]
    end
  end

  describe "#get" do
    subject { @manager.get("g1","k1") }
    before {
      allow(@manager).to receive(:file)
                          .and_return(files["2"])
    }
    context "has valid secret" do
      before {
        allow(@manager).to receive(:valid?)
                            .and_return(true)
      }
      it "returns value of the key in the group" do
        expect(@manager).to receive(:decode).with("abcdefg").once
        subject
      end
    end
    context "has no valid secret" do
      before {
        allow(@manager).to receive(:valid?)
                          .and_return(false) }
      it "raise Keystorage::SecretMissMatch" do
        expect { subject }.to raise_error(Keystorage::SecretMissMatch)
      end

    end
  end

  describe "#set" do
    before {
      allow(@manager).to receive(:file)
                          .and_return(files["2"])
    }

    context "group name '@'" do
      subject { @manager.set("@","k1","v1") }
      it "raise Keystorage::RejectGroupName" do
        expect { subject }.to raise_error(Keystorage::RejectGroupName)
      end
    end

    context "has valid secret" do
      subject { @manager.set("g1","k1","v1") }
      before {
        allow(@manager).to receive(:valid?)
                            .and_return(true)
      }
      it "sets the value to the key in the group" do
        FakeFS do
          subject
          expect(@manager.get('g1','k1')).to eq "v1"
        end
      end
    end

    context "has no valid secret" do
      subject { @manager.set("g1","k1","v1") }
      before {
        allow(@manager).to receive(:valid?)
                            .and_return(false)
      }
      it "raise Keystorage::SecretMissMatch" do
        expect { subject }.to raise_error(Keystorage::SecretMissMatch)
      end

    end
  end

  describe "#password" do
    let(:new_password) { "zxcvbnm" }
    subject { @manager.password(new_password) }

    context "file not found" do
      before {
        @manager = Keystorage::Manager.new( {:file=>"hoge",:secret=>"fuga"})
      }
      it "creates new keystorage file" do
        FakeFS do
          subject
          expect(File.exists?("hoge")).to eq true
          expect(@manager.send(:file).has_key?("@")).to eq true
        end
      end
    end

    context "has valid secret" do

      before {
        @manager = Keystorage::Manager.new( {:file=>"hoge",:secret=>"fuga"})
      }
      it "updates password to `new_password`" do
        FakeFS do
          @manager.set("a","b","c")
          subject
          expect { @manager.get("a","b") }.to raise_error(Keystorage::SecretMissMatch)
          @manager = Keystorage::Manager.new( {:file=>"hoge",:secret=>new_password})
          expect(@manager.get("a","b")).to eq "c"
        end
      end
    end

    context "has no valid secret" do
      before {
        allow(@manager).to receive(:valid?)
                            .and_return(false)
      }
      it "raise Keystorage::SecretMissMatch" do
        expect { subject }.to raise_error(Keystorage::SecretMissMatch)
      end

    end
  end

  describe "#exec" do
    let(:cmd) { ["ls","-a b"] }
    subject { @manager.exec(cmd) }

    context "has valid secret" do
      before {
        @manager = Keystorage::Manager.new( {:file=>"hoge",:secret=>"fuga"} )
        allow(@manager).to receive(:valid?)
                            .and_return(true)
      }
      it "execute command with env-vars" do
        FakeFS do
          @manager.set("a","b","c")
          @manager.set("a","b","d e f")
          @manager.set("x","y","z")

          expect(@manager).to receive(:system)
                             .with("a_b='d e f' x_y='z' ls -a b")
                            .and_return(true)
          subject
        end
      end
    end

    context "has no valid secret" do
      before {
        allow(@manager).to receive(:valid?)
                            .and_return(false)
      }
      it "raise Keystorage::SecretMissMatch" do
        expect { subject }.to raise_error(Keystorage::SecretMissMatch)
      end

    end
  end


  # private methods
  describe "#sign" do
    context "secret is nil" do
      it "raise NoSecret" do
        expect { @manager.send(:sign,"text",nil) }
          .to raise_error(Keystorage::NoSecret)
      end

    end
    context "secret is not nil" do
      subject { @manager.send(:sign,"text","p@ssw0rd") }
      it "returns sign" do
        allow(OpenSSL::HMAC).to receive(:hexdigest)
                                 .and_return("sample-sig")

        is_expected.to eq "sample-sig"
      end

    end
  end

  describe "#token" do
    subject { @manager.send(:token) }

    it "returns token" do
      allow(SecureRandom).to receive(:urlsafe_base64)
                              .and_return("sample-token")
      is_expected.to eq "sample-token"
    end

  end

  describe "#root" do
    context "file has '@' key" do
      let(:root) { {"test1"=>"test2"} }
      let(:data) { { "@" => root,"group1" => {"key1"=>"value1"} } }
      subject { @manager.send(:root) }

      it "returns Hash of root" do
        allow(@manager).to receive(:file)
                            .and_return(data)
        is_expected.to eq root
      end
    end
    context "file has no '@' key" do
      let(:data) { { "group1" => {"key1"=>"value1"} } }
      it "raise NoRootGroup" do
        allow(@manager).to receive(:file)
                            .and_return(data)

        expect { @manager.send(:root) }
          .to raise_error(Keystorage::NoRootGroup)
      end

    end
  end

  describe "#valid?" do
    context "file has no root" do
      subject { @manager.send(:valid?) }
      let(:data) { { "group1" => {"key1"=>"value1"} } }
      it "writes root and return true" do
        allow(@manager).to receive(:file)
                            .and_return(data)
        allow(@manager).to receive(:write)
                            .and_return(true)
        expect(@manager).to receive(:write)
        is_expected.to eq true
      end
    end
  end

  describe "#encode" do
    let(:str) { "test message" }
    let(:secret) { "s3cr3t" }
    subject { @manager.send(:encode,str,secret) }
    it "returns encoded string" do
      is_expected.to eq "a191a5111cfee36a94bba4dc0a17c31d"
    end
  end

  describe "#decode" do
    let(:str) { "test message" }
    let(:encoded) { "a191a5111cfee36a94bba4dc0a17c31d" }
    let(:secret) { "s3cr3t" }
    subject { @manager.send(:decode,encoded,secret) }
    it "returns decoded string" do
      is_expected.to eq str
    end
  end

  describe "#file" do
    subject { @manager.send(:file) }
    it "returns data from path" do
      allow(@manager).to receive(:path)
                          .and_return(yaml("1"))
      is_expected.to eq files["1"]
    end
  end

  describe "#write" do
    let(:data) { { :test => "rspec"} }
    subject { @manager.send(:write,data) }
    it "writes data to file" do
      FakeFS do
        expect { subject }.not_to raise_error
        expect(@manager.send(:file).has_key?(:test)).to eq true
      end
    end
  end

  describe "#path" do
    subject { @manager.send(:path) }
    let(:file_path) { "abcdefgh" }

    context "options[:path] is set" do
      before{
        allow(@manager).to receive(:options)
                           .and_return({:file =>file_path})
      }

      it "returns options[:path]" do
        is_expected.to eq file_path
      end
    end
    context "options[:path] is not set" do
      before {
        allow(@manager).to receive(:options)
                            .and_return({})
      }

      context "ENV KEYSTORAGE_FILE is set" do
        before{
          allow(ENV).to receive(:[])
                         .with('KEYSTORAGE_FILE')
                         .and_return(file_path)
        }
        it "returns KEYSTORAGE_FILE" do
          is_expected.to eq file_path
        end
      end

      context "ENV KEYSTORAGE_FILE is not set" do
        before{
          allow(ENV).to receive(:[])
                         .with('KEYSTORAGE_FILE')
                         .and_return(nil)
        }
        it "returns DEFAULT_FILE" do
          is_expected.to eq Keystorage::DEFAULT_FILE
        end
      end
    end

  end

  describe "#secret" do
    subject { @manager.send(:secret) }
    let(:password) { "abcedfg" }

    context "options[:secret] is set" do
      it "returns options[:secret]" do
        allow(@manager).to receive(:options)
                           .and_return({:secret =>password})
        is_expected.to eq password
      end
    end
    context "options[:secret] is not set" do
      before {
        allow(@manager).to receive(:options)
                            .and_return({})
      }
      context "ENV KEYSTORAGE_SECRET is set" do
        before {
          allow(ENV).to receive(:[])
                         .with('KEYSTORAGE_SECRET')
                         .and_return(password)
        }

        it "returns secret ENV[:secret]" do
          is_expected.to eq password
        end
      end
      context "ENV KEYSTORAGE_SECRET is not set" do
        before {
          allow(ENV).to receive(:[])
                         .with('KEYSTORAGE_SECRET')
                         .and_return(nil)
        }
        it "returns DEFAULT_SECRET" do
          is_expected.to eq Keystorage::DEFAULT_SECRET
        end
      end
    end

  end
end
