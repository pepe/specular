module SpecularTest
  class SkipTest < MiniTest::Unit::TestCase

    def test_spec
      Spec.new :skip_test_spec_I, :skip => true do
        Context 'should not be executed' do

          is(1) == 1

          Should 'not be executed' do
          end
        end
      end
      Spec.new :skip_test_spec_conditional, :skip => proc { true } do
        is(11) == 1
      end
      Spec.new :skip_test_spec_II do
        Context 'someSpec' do
          Should 'be executed' do
            is(2) == 2
          end
        end
      end
      output = Specular.run(/skip_test_spec/).to_s
      assert_match /Skipped Specs.*skip_test_spec_I at/m, output
      assert_match /Specs\:\s+3 \(2 skipped\)$/, output
      assert_match /Tests\:\s+2$/, output
      assert_match /Assertions\:\s+|\[2$/, output
      assert_match /Should be executed/, output
      assert_match /is\(2\) == 2/, output
      refute_match /is\(1\) == 1/, output
      refute_match /is\(11\) == 1/, output
      refute_match /should not be executed/i, output
    end

    def test_test
      Spec.new __method__ do
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
      output = Specular.run(__method__).to_s
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
