module SpecularTest
  class HaltTest < MiniTest::Unit::TestCase

    def test_I
      spec = '%s.%s' % [self.class, __method__]
      msg = '%sFAILED' % __method__
      Spec.new spec do
        is(1) == 2
        o msg
      end
      refute_match /#{msg}/, Specular.run(spec).output.to_s
    end

    def test_II
      spec = '%s.%s' % [self.class, __method__]
      assert_msg = 'this_should_run'
      refute_msg = 'this_should_be_skipped'
      Spec.new spec do
        Context do
          is(1) == 2
          o refute_msg
        end
        o assert_msg
      end
      output = Specular.run(spec).output.to_s
      assert_match /#{assert_msg}/, output
      refute_match /#{refute_msg}/, output
    end

    def test_III
      spec = '%s.%s' % [self.class, __method__]
      assert_msg = 'this_should_run'
      refute_msg = 'this_should_be_skipped'
      Spec.new spec do
        Context do
          Test :test do
            is(1) == 2
            o refute_msg
          end
          o assert_msg
        end
      end
      output = Specular.run(spec).output.to_s
      assert_match /#{assert_msg}/, output
      refute_match /#{refute_msg}/, output
    end

  end
end
