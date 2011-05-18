require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

describe "KPI::Entry" do
  it "should require exactly 2 arguments" do
    assert_raises(ArgumentError) { KPI::Entry.new }
    assert_raises(ArgumentError) { KPI::Entry.new "test" }
    assert_raises(ArgumentError) { KPI::Entry.new "test", 1, "aaa" }
  end

  describe "when title and value given" do
    before { @entry = KPI::Entry.new "name", "value" }
    
    it "returns name" do
      assert_equal("name", @entry.name)
    end
    
    it "returns value" do
      assert_equal("value", @entry.value)
    end
    
    it "returns nil as description" do
      assert_nil(@entry.description)
    end
    describe "when description given" do
      before { @entry = KPI::Entry.new "name", "value", :description => "desc" }
    
      it "returns description" do
        assert_equal("desc", @entry.description)
      end
    end
    
    describe "when unit given" do
      before { @entry = KPI::Entry.new "Income", 1294.23, :unit => "EUR" }
    
      it "returns description" do
        assert_equal("EUR", @entry.unit)
      end
    end
    
    describe "when entry is important" do
      before { @entry = KPI::Entry.new "Income", 1294.23, :important => true }
    
      it "returns true" do
        assert @entry.important
      end
    end
    
    describe :important? do
      describe "when entry is important" do
        before { @entry = KPI::Entry.new "Income", 1294.23, :important => true }

        it "returns true" do
          assert @entry.important?
        end
      end
      
      describe "when entry is not important" do
        before { @entry = KPI::Entry.new "Income", 1294.23 }

        it "returns false" do
          assert !@entry.important?
        end
      end
    end
  end
end