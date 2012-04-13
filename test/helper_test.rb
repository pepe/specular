module SpineTest
  class HelperTest < MiniTest::Unit::TestCase

    module HelperTestMixin
      def some_helper
        'include test passed'
      end
    end

    def test_include
      Spine.task __method__ do
        include HelperTestMixin
        o some_helper
      end
      assert_match /include test passed/, Spine.run(__method__).output.to_s
    end

    def test_def
      Spine.task __method__ do

        def another_helper
          'def test passed'
        end

        o another_helper
      end
      assert_match /def test passed/, Spine.run(__method__).output.to_s
    end

  end
end
