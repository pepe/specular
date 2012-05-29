module EnterTest
  class SkipTest < MiniTest::Unit::TestCase

    def test_task
      Enter.task :skip_test_task_I, :skip => true do
        Spec 'should not be executed' do

          is(1) == 1

          Should 'not be executed' do
          end
        end
      end
      Enter.task :skip_test_task_conditional, :skip => proc { true } do
        is(11) == 1
      end
      Enter.task :skip_test_task_II do
        Spec 'someSpec' do
          Should 'be executed' do
            is(2) == 2
          end
        end
      end
      output = Enter.run(/skip_test_task/).to_s
      assert_match /Skipped Tasks.*skip_test_task_I at/m, output
      assert_match /Tasks\:\s+3 \(2 skipped\)$/, output
      assert_match /Tests\:\s+2$/, output
      assert_match /Assertions\:\s+|\[2$/, output
      assert_match /Should be executed/, output
      assert_match /is\(2\) == 2/, output
      refute_match /is\(1\) == 1/, output
      refute_match /is\(11\) == 1/, output
      refute_match /should not be executed/i, output
    end

    def test_test
      Enter.task __method__ do
        Context do
          Should 'be skipped', :skip => true do

            is(1) == 1

            Should 'not be executed' do
              Nor 'this one' do
              end
            end
          end
          Should 'run' do
            does?('run') =~ /r/
          end
        end
        Should 'be skipped conditionally', :skip => proc { true } do

          is(11) == 1

        end
        Should 'be executed' do
          And 'this as well' do
            is(2) == 2
          end
        end
      end
      output = Enter.run(__method__).to_s
      assert_match /Skipped Tests.*#{__method__}.*Should be skipped at/m, output
      assert_match /Tests\:\s+4 \(2 skipped\)/, output
      assert_match /Should be executed/, output
      assert_match /And this as well/, output
      assert_match /Assertions\:\s+|\[2$/, output
      assert_match /#{Regexp.escape "does?('run') =~ /r/"}/, output
      refute_match /is\(11\) == 1/, output
      refute_match /is\(1\) == 1/, output
      refute_match /Should not be executed/, output
      refute_match /Nor this one/, output
    end

  end
end
