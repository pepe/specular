module SpineTest
  class HooksTest < MiniTest::Unit::TestCase

    def test_before

      expectations = [
          :task, :spec_1, :scenario_1, :scenario_1_1, :scenario_1_2, :scenario_2, :spec_2
      ]
      expectations = Hash[expectations.zip]

      hooks = []
      Spine.task __method__ do

        before do
          hooks << :task
        end

        hooks = []
        is(1) == 1
        hooks == [:task] && expectations[:task] = true

        spec :spec_1 do

          before do
            hooks << :spec_1
          end

          hooks = []
          is(1) == 1
          hooks == [:task, :spec_1] && expectations[:spec_1] = true

          Say :scenario_1 do

            before do
              hooks << :scenario_1
            end

            hooks = []
            is(1) == 1
            hooks == [:task, :spec_1, :scenario_1] && expectations[:scenario_1] = true

            Say :scenario_1_1 do
              before do
                hooks << :scenario_1_1
              end

              hooks = []
              is(1) == 1
              hooks == [:task, :spec_1, :scenario_1, :scenario_1_1] && expectations[:scenario_1_1] = true

            end

            Say :scenario_1_2 do

              hooks = []
              is(1) == 1
              hooks == [:task, :spec_1, :scenario_1] && expectations[:scenario_1_2] = true

            end

          end

          Say :scenario_2 do

            before do
              hooks << :scenario_2
            end

            hooks = []
            is(1) == 1
            hooks == [:task, :spec_1, :scenario_2] && expectations[:scenario_2] = true
          end
        end

        spec :spec_2 do
          before do
            hooks << :spec_2
          end

          hooks = []
          is(1) == 1
          hooks == [:task, :spec_2] && expectations[:spec_2] = true
        end

      end
      Spine.run __method__
      expectations.each_pair do |expectation, value|
        assert_equal value, true, 'expected %s to be true but it is %s' % [expectation, value.inspect]
      end
    end

  end
end
