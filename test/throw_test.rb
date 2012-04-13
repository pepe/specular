module SpineTest
  class ThrowTest < MiniTest::Unit::TestCase

    def test
      msg = 'throw test passed'
      Spine.task __method__ do
        does { throw :something }.throw_symbol?
        passed? && o(msg)
      end
      assert_match /#{msg}/, Spine.run(__method__).output.to_s
    end

    def test_symbol
      msg = 'throw symbol test passed'
      Spine.task __method__ do
        does { throw :something }.throw_symbol? :something
        passed? && o(msg)
      end
      assert_match /#{msg}/, Spine.run(__method__).output.to_s
    end

    def test_symbol_and_value
      msg = 'throw symbol and value test passed'
      Spine.task __method__ do
        does { throw :something, 'some message' }.throw_symbol? :something, 'some message'
        passed? && o(msg)
      end
      assert_match /#{msg}/, Spine.run(__method__).output.to_s
    end

    def test_symbol_and_regex_value
      msg = 'throw symbol and value test passed'
      Spine.task __method__ do
        does { throw :something, 'some message' }.throw_symbol? :something, /some message/
        passed? && o(msg)
      end
      assert_match /#{msg}/, Spine.run(__method__).output.to_s
    end

  end
end
