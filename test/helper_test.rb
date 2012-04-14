module SpineTest
  class HelperTest < MiniTest::Unit::TestCase

    module HelperTestMixin
      def some_helper
        'include test passed'
      end

      def looks_like_jack? person
        person =~ /Jack/
      end
    end

    def test_include
      Spine.task __method__ do

        include HelperTestMixin

        self.respond_to?(:some_helper) && o(some_helper)
        does('Captain Jack').looks_like_jack?
        passed? && o('looks_like_jack? passed')
      end
      output = Spine.run(__method__).output.to_s
      assert_match /include test passed/, output
      assert_match /looks_like_jack\? passed/, output
    end

    def test_def
      Spine.task __method__ do

        def another_helper
          'def test passed'
        end

        def contain? food, ingredient
          food =~ /#{ingredient}/
        end

        self.respond_to?(:another_helper) && o(another_helper)
        pizza = 'Big Pizza with Olives and lot of Cheese'
        does(pizza).contain? 'Olives'
        does(pizza).contain? 'Cheese'
        passed? && o('Oh, seems we got a delicious pizza!')
      end
      output = Spine.run(__method__).output.to_s
      assert_match /def test passed/, output
      assert_match /Oh\, seems we got a delicious pizza\!/, output
    end

  end
end
