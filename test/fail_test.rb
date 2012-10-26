module SpecularTest
  class FailTest < MiniTest::Unit::TestCase

    def test
      spec  = '%s.%s' % [self.class, __method__]
      error_I  = 'ExplicitlyFailed'
      error_II = 'ExplicitlyFailedInsideContext'
      refute_msg = 'ShouldNotArriveHere'
      Spec.new spec do
        Context do
          fail! error_II
        end

        fail error_I
        
        Context do
          o refute_msg
        end
      end
      output = Specular.run(spec).output.to_s
      assert_match /#{error_I}/, output
      assert_match /#{error_II}/, output
      refute_match /#{refute_msg}/, output
    end

  end
end
