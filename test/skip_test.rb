module SpineTest
  class SkipTest < MiniTest::Unit::TestCase

    def test_task
      Spine.task :skip_test_task_I, :skip => true do
        Spec 'should not be executed' do

          is(1) == 1

          Should 'not be executed' do
          end
        end
      end
      Spine.task :skip_test_task_II do
        Spec 'someSpec' do
          Should 'be executed' do
            is(2) == 2
          end
        end
      end
      output = Spine.run(/skip_test_task/).to_s
      assert_match /Skipped Tasks.*skip_test_task_I at/m, output
      assert_match /Tasks\:\s+2 \(1 skipped\)$/, output
      assert_match /Specs\:\s+2$/, output
      assert_match /Tests\:\s+2$/, output
      assert_match /Assertions\:\s+|\[2$/, output
      assert_match /Should be executed/, output
      assert_match /is\(2\) == 2/, output
      refute_match /is\(1\) == 1/, output
      refute_match /should not be executed/i, output
    end

    def test_spec
      Spine.task __method__ do
        Spec :should_be_skipped, :skip => true do

          is(1) == 1

          Should 'not be executed' do
          end
        end
        Spec 'should be executed' do
          is(2) == 2
        end
      end
      output = Spine.run(__method__).to_s
      assert_match /Skipped Specs.*should_be_skipped at/m, output
      assert_match /Tasks\:\s+1$/, output
      assert_match /Specs\:\s+2 \(1 skipped\)$/, output
      assert_match /Tests\:\s+1$/, output
      assert_match /Assertions\:\s+|\[2$/, output
      assert_match /should be executed/, output
      assert_match /is\(2\) == 2/, output
      refute_match /is\(1\) == 1/, output
      refute_match /should not be executed/i, output
    end

    def test_test
      Spine.task __method__ do
        Should 'be skipped', :skip => true do

          is(1) == 1

          Should 'not be executed' do
            Nor 'this one' do
            end
          end
        end
        Should 'be executed' do
          And 'this as well' do
            is(2) == 2
          end
        end
      end
      output = Spine.run(__method__).to_s
      assert_match /Skipped Tests.*#{__method__}.*Should be skipped at/m, output
      assert_match /Tests\:\s+5 \(1 skipped\)/, output
      assert_match /Should be executed/, output
      assert_match /And this as well/, output
      assert_match /Assertions\:\s+|\[2$/, output
      refute_match /is\(1\) == 1/, output
      refute_match /Should not be executed/, output
      refute_match /Nor this one/, output
    end

  end
end
