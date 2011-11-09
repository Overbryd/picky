require 'spec_helper'

describe Picky::Backends::Redis::Basic do
  
  let(:client) { stub :client }
  
  context 'without options' do
    let(:index) { described_class.new client, :some_namespace }

    describe 'load, retrieve, backup, delete' do
      it 'is nothing they do (at least on the backend)' do
        index.should_receive(:client).never

        index.load
        index.retrieve
        index.backup
        index.delete
      end
    end

    describe 'empty' do
      it 'returns the container that is used for indexing' do
        index.empty.should == {}
      end
    end

    describe 'initial' do
      it 'is correct' do
        index.initial.class.should == described_class
      end
    end

    describe 'cache_small?' do
      context 'size 0' do
        before(:each) do
          index.stub! :size => 0
        end
        it 'is small' do
          index.cache_small?.should == true
        end
      end
      context 'size 1' do
        before(:each) do
          index.stub! :size => 1
        end
        it 'is not small' do
          index.cache_small?.should == false
        end
      end
    end

    describe 'cache_ok?' do
      context 'size 0' do
        before(:each) do
          index.stub! :size => 0
        end
        it 'is not ok' do
          index.cache_ok?.should == false
        end
      end
      context 'size 1' do
        before(:each) do
          index.stub! :size => 1
        end
        it 'is ok' do
          index.cache_ok?.should == true
        end
      end
    end

    describe "size" do
      it 'delegates to the backend' do
        client.should_receive(:dbsize).once.with

        index.size
      end
    end

    describe 'to_s' do
      it 'returns the cache path with the default file extension' do
        index.to_s.should == 'Picky::Backends::Redis::Basic(some_namespace:*)'
      end
    end
  end
  
  context 'with options' do
    let(:index) do
      described_class.new client,
                          :some_namespace,
                          empty: [],
                          initial: []
    end

    describe 'empty' do
      it 'returns the container that is used for indexing' do
        index.empty.should == []
      end
    end

    describe 'initial' do
      it 'is correct' do
        index.initial.class.should == Array
      end
    end
  end
  
end