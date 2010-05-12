require 'helper'

class OptionsHashTest < Test::Unit::TestCase
  include Plucky

  context "Plucky::OptionsHash" do
    should "delegate missing methods to the source hash" do
      hash = {:skip => 1, :limit => 1}
      options = OptionsHash.new(hash)
      options[:skip].should   == 1
      options[:limit].should  == 1
      options.keys.should     == [:limit, :skip]
    end

    context "#[]=" do
      should "convert order to sort" do
        options = OptionsHash.new(:order => :foo)
        options[:order].should be_nil
        options[:sort].should == [['foo', 1]]
      end

      should "convert select to fields" do
        options = OptionsHash.new(:select => 'foo')
        options[:select].should be_nil
        options[:fields].should == ['foo']
      end

      should "convert offset to skip" do
        options = OptionsHash.new(:offset => 1)
        options[:offset].should be_nil
        options[:skip].should == 1
      end

      context ":fields" do
        setup   { @options = OptionsHash.new }
        subject { @options }

        should "default to nil" do
          subject[:fields].should be_nil
        end

        should "be nil if empty string" do
          subject[:fields] = ''
          subject[:fields].should be_nil
        end

        should "be nil if empty array" do
          subject[:fields] = []
          subject[:fields].should be_nil
        end

        should "work with array" do
          subject[:fields] = %w[one two]
          subject[:fields].should == %w[one two]
        end

        should "flatten multi-dimensional array" do
          subject[:fields] = [[:one, :two]]
          subject[:fields].should == [:one, :two]
        end

        should "work with symbol" do
          subject[:fields] = :one
          subject[:fields].should == [:one]
        end

        should "work with array of symbols" do
          subject[:fields] = [:one, :two]
          subject[:fields].should == [:one, :two]
        end

        should "work with hash" do
          subject[:fields] = {:one => 1, :two => -1}
          subject[:fields].should == {:one => 1, :two => -1}
        end

        should "convert comma separated list to array" do
          subject[:fields] = 'one, two'
          subject[:fields].should == %w[one two]
        end

        should "convert select" do
          subject[:select] = 'one, two'
          subject[:select].should be_nil
          subject[:fields].should == %w[one two]
        end
      end

      context ":limit" do
        setup   { @options = OptionsHash.new }
        subject { @options }

        should "default to nil" do
          subject[:limit].should be_nil
        end

        should "use limit provided" do
          subject[:limit] = 1
          subject[:limit].should == 1
        end

        should "convert string to integer" do
          subject[:limit] = '1'
          subject[:limit].should == 1
        end
      end

      context ":skip" do
        setup   { @options = OptionsHash.new }
        subject { @options }

        should "default to nil" do
          subject[:skip].should be_nil
        end

        should "use limit provided" do
          subject[:skip] = 1
          subject[:skip].should == 1
        end

        should "convert string to integer" do
          subject[:skip] = '1'
          subject[:skip].should == 1
        end

        should "be set from offset" do
          subject[:offset] = '1'
          subject[:offset].should be_nil
          subject[:skip].should == 1
        end
      end

      context ":sort" do
        setup   { @options = OptionsHash.new }
        subject { @options }

        should "default to nil" do
          subject[:sort].should be_nil
        end

        should "work with natural order ascending" do
          subject[:sort] = {'$natural' => 1}
          subject[:sort].should == {'$natural' => 1}
        end

        should "work with natural order descending" do
          subject[:sort] = {'$natural' => -1}
          subject[:sort].should =={'$natural' => -1}
        end

        should "convert single ascending field (string)" do
          subject[:sort] = 'foo asc'
          subject[:sort].should == [['foo', 1]]

          subject[:sort] = 'foo ASC'
          subject[:sort].should == [['foo', 1]]
        end

        should "convert single descending field (string)" do
          subject[:sort] = 'foo desc'
          subject[:sort].should == [['foo', -1]]

          subject[:sort] = 'foo DESC'
          subject[:sort].should == [['foo', -1]]
        end

        should "convert multiple fields (string)" do
          subject[:sort] = 'foo desc, bar asc'
          subject[:sort].should == [['foo', -1], ['bar', 1]]
        end

        should "convert multiple fields and default no direction to ascending (string)" do
          subject[:sort] = 'foo desc, bar, baz'
          subject[:sort].should == [['foo', -1], ['bar', 1], ['baz', 1]]
        end

        should "convert symbol" do
          subject[:sort] = :name
          subject[:sort] = [['name', 1]]
        end

        should "convert operator" do
          subject[:sort] = :foo.desc
          subject[:sort].should == [['foo', -1]]
        end

        should "convert array of operators" do
          subject[:sort] = [:foo.desc, :bar.asc]
          subject[:sort].should == [['foo', -1], ['bar', 1]]
        end

        should "convert array of symbols" do
          subject[:sort] = [:first_name, :last_name]
          subject[:sort] = [['first_name', 1], ['last_name', 1]]
        end

        should "work with array of single array" do
          subject[:sort] = [['foo', -1]]
          subject[:sort].should == [['foo', -1]]
        end
        
        should "work with array of multiple arrays" do
          subject[:sort] = [['foo', -1], ['bar', 1]]
          subject[:sort].should == [['foo', -1], ['bar', 1]]
        end

        should "compact nil values in array" do
          subject[:sort] = [nil, :foo.desc]
          subject[:sort].should == [['foo', -1]]
        end

        should "convert array with mix of values" do
          subject[:sort] = [:foo.desc, 'bar']
          subject[:sort].should == [['foo', -1], ['bar', 1]]
        end

        should "convert id to _id" do
          subject[:sort] = [:id.asc]
          subject[:sort].should == [['_id', 1]]
        end

        should "convert string with $natural correctly" do
          subject[:sort] = '$natural desc'
          subject[:sort].should == [['$natural', -1]]
        end
      end
    end
  end
end