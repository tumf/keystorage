# coding: utf-8
require 'keystorage/cli'

describe Keystorage::CLI do
  subject { Keystorage::CLI.start(argv) }

  describe ".start" do
    context "unknown global-options are specified" do
      let(:argv) { ['--aaa=myfile','groups'] }
      it "puts options back of subcommand" do
        expect { subject }.to raise_error(OptionParser::InvalidOption)
      end
    end

    context "string-type global-options are specified" do
      let(:argv) { ['-f','myfile','groups'] }
      it "puts options back of subcommand" do
        expect(Thor).to receive(:start).with(['groups','--file=myfile'],{}).once
        subject
      end
    end

    context "boolean-type `-v` global-options are specified" do
      let(:argv) { ['-v','groups'] }
      it "puts options back of subcommand" do
        expect(Thor).to receive(:start).with(['groups','--verbose'],{}).once
        subject
      end
    end
    context "boolean-type `--no-verbose` global-options are specified" do
      let(:argv) { ['--no-verbose','groups'] }
      it "puts options back of subcommand" do
        expect { subject }.to raise_error(OptionParser::InvalidOption)
      end
    end
  end

  describe ".global_option" do
    it "adds to @global_options and call `class_option`" do
      expect(Keystorage::CLI).to receive(:class_option)
                                  .with(:test, :aliases =>"-t", :type => :boolean).once
      Keystorage::CLI.global_option(:test, :aliases =>"-t", :type => :boolean)
      expect(Keystorage::CLI.global_options.has_key?(:test)).to be true
    end
  end

  describe "#groups" do
    let(:argv) { ['groups'] }
    it "puts list of groups" do
      allow(Keystorage::Manager).to receive_message_chain('new.groups')
                                     .and_return( ["group1","group2","group3"] )
      expect(STDOUT).to receive(:puts).with("group1\ngroup2\ngroup3").once
      subject
    end
  end

  describe "#keys" do
    let(:argv) { ['keys','group1'] }
    it "puts keys in the group" do
      allow(Keystorage::Manager).to receive_message_chain('new.keys')
                                     .and_return( ["key1","key2","key3"] )

      expect(STDOUT).to receive(:puts).with("key1\nkey2\nkey3").once
      subject
    end
  end

  describe "#get" do
    let(:argv) { ['get','group1','key1'] }
    it "puts value of the key in the group" do
      allow(Keystorage::Manager).to receive_message_chain('new.get')
                                     .and_return( ["value"] )

      expect(STDOUT).to receive(:puts).with("value").once
      subject
    end
  end


  describe "#set" do
    let(:argv) { ['set','group1','key1','vaule'] }
    it "sets value of the key in the group" do
      allow(Keystorage::Manager).to receive_message_chain('new.set')
                                     .and_return("value")

      expect(STDOUT).to receive(:puts).with("value").once
      subject
    end
  end

  describe "#password" do
    let(:argv) { ['password','p@ssw0rd'] }
    it "updates secret of all keys in the file" do
      expect(Keystorage::Manager).to receive_message_chain('new.password')
                                      .with('p@ssw0rd')
      subject
    end
  end

  describe "#exec" do
    let(:argv) { ['exec','mycommand','arg1','arg2'] }
    it "updates secret of all keys in the file" do
      expect(Keystorage::Manager).to receive_message_chain('new.exec')
                                      .with(['mycommand','arg1','arg2'])
      subject
    end
  end

  describe "#version" do
    let(:argv) { ['version'] }
    let(:ver) {
      File.read(File.join(File.dirname(__FILE__),'..','..','VERSION')).chomp
    }
    it "shows version" do
      expect(STDOUT).to receive(:puts).with(ver).once
      subject
    end
  end

end
