module SpecularTest
  class RaiseTest < MiniTest::Unit::TestCase

    def test
      msg = 'raise test passed'
      Spec.new __method__ do
        does { some code }.raise_error?
        o msg
      end
      assert_match /#{msg}/, Specular.run(__method__).output.to_s
    end

    def test_type
      msg = 'raise NoMethodError test passed'
      Spec.new __method__ do
        does { raise NoMethodError }.raise_error? NoMethodError
        o msg
      end
      assert_match /#{msg}/, Specular.run(__method__).output.to_s
    end

    def test_match
      msg = 'raise match test passed'
      Spec.new __method__ do
        does { raise 'some error message' }.raise_error? /some error message/
        o msg
      end
      assert_match /#{msg}/, Specular.run(__method__).output.to_s
    end

    def test_type_and_match
      msg = 'raise type and match test passed'
      Spec.new __method__ do
        does { raise RuntimeError, 'some error message' }.raise_error? RuntimeError, /some error message/
        o msg
      end
      assert_match /#{msg}/, Specular.run(__method__).output.to_s
    end

  end
end
