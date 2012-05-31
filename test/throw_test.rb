module SpecularTest
  class ThrowTest < MiniTest::Unit::TestCase

    def test
      msg = 'throw test passed'
      Spec.new __method__ do
        does { throw :something }.throw_symbol?
        o msg
      end
      tests = Specular.run(__method__)
      assert_match /#{msg}/, tests.output.to_s
    end

    def test_symbol
      msg = 'throw symbol test passed'
      Spec.new __method__ do
        does { throw :something }.throw_symbol? :something
        o msg
      end
      assert_match /#{msg}/, Specular.run(__method__).output.to_s
    end

    def test_symbol_and_value
      msg = 'throw symbol and value test passed'
      Spec.new __method__ do
        does { throw :something, 'some message' }.throw_symbol? :something, 'some message'
        o msg
      end
      tests = Specular.run(__method__)
      puts tests.failures
      assert_match /#{msg}/, tests.output.to_s
    end

    def test_symbol_and_regex_value
      msg = 'throw symbol and value test passed'
      Spec.new __method__ do
        does { throw :something, 'some message' }.throw_symbol? :something, /some message/
        o msg
      end
      assert_match /#{msg}/, Specular.run(__method__).output.to_s
    end

  end
end
