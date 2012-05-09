module SpineTest
  class HaltTest < MiniTest::Unit::TestCase

    def test_task
      task = '%s.%s' % [self.class, __method__]
      msg = '%sFAILED' % __method__
      Spine.task task do
        is(1) == 2
        o msg
      end
      refute_match /#{msg}/, Spine.run(task).output.to_s
    end

    def test_spec
      task = '%s.%s' % [self.class, __method__]
      assert_msg = 'this_should_run'
      refute_msg = 'this_should_be_skipped'
      Spine.task task do
        Spec :spec do
          is(1) == 2
          o refute_msg
        end
        o assert_msg
      end
      output = Spine.run(task).output.to_s
      assert_match /#{assert_msg}/, output
      refute_match /#{refute_msg}/, output
    end

    def test_test
      task = '%s.%s' % [self.class, __method__]
      assert_msg = 'this_should_run'
      refute_msg = 'this_should_be_skipped'
      Spine.task task do
        Spec :spec do
          Test :test do
            is(1) == 2
            o refute_msg
          end
          o assert_msg
        end
      end
      output = Spine.run(task).output.to_s
      assert_match /#{assert_msg}/, output
      refute_match /#{refute_msg}/, output
    end

  end
end
