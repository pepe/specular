module SpecularTest
  class HooksTest < MiniTest::Unit::TestCase

    def test_hooks

      expectations = [:spec, :spec_1, :spec_1_context, :spec_1_1, :spec_2,
                      :ignore_all, :only_before, :only_after]
      expectations = Hash[expectations.zip expectations.map { 0 }]

      hooks = []
      Spec.new __method__ do

        before do
          hooks << :spec_A
        end
        after do
          hooks << :spec_Z
        end

        hooks = []
        Testing :spec do
          hooks == [:spec_A] && expectations[:spec] += 1
        end
        hooks == [:spec_A, :spec_Z] && expectations[:spec] += 1

        hooks = []
        Context :spec_1 do

          before do
            hooks << :spec_1_A
          end
          after do
            hooks << :spec_1_Z
          end

          hooks = []
          Testing :spec_1 do
            hooks == [:spec_A, :spec_1_A] && expectations[:spec_1] += 1
          end
          hooks == [:spec_A, :spec_1_A, :spec_Z, :spec_1_Z] && expectations[:spec_1] += 1

          hooks = []
          Context :spec_1_1 do

            before do
              hooks << :spec_1_1_A
            end
            after do
              hooks << :spec_1_1_Z
            end

            hooks = []
            Testing :spec_1_1 do
              hooks == [:spec_A, :spec_1_A, :spec_1_1_A] && expectations[:spec_1_1] += 1
            end
            hooks == [:spec_A, :spec_1_A, :spec_1_1_A, :spec_Z, :spec_1_Z, :spec_1_1_Z] && expectations[:spec_1_1] += 1

          end

          hooks = []
          Testing :spec_1_context do
            hooks == [:spec_A, :spec_1_A] && expectations[:spec_1_context] += 1
          end
          hooks == [:spec_A, :spec_1_A, :spec_Z, :spec_1_Z] && expectations[:spec_1_context] += 1

        end

        Context :spec_2 do

          before do
            hooks << :spec_2_A
          end
          after do
            hooks << :spec_2_Z
          end

          hooks = []
          Testing :spec_2 do
            hooks == [:spec_A, :spec_2_A] && expectations[:spec_2] += 1
          end
          hooks == [:spec_A, :spec_2_A, :spec_Z, :spec_2_Z] && expectations[:spec_2] += 1
        end

        hooks = []
        Context :ignore_all, :hooks => nil do
          hooks == [] && expectations[:ignore_all] += 1
        end
        hooks == [] && expectations[:ignore_all] += 1

        hooks = []
        Context :only_before, :hooks => :before do
          hooks == [:spec_A] && expectations[:only_before] += 1
        end
        hooks == [:spec_A] && expectations[:only_before] += 1

        hooks = []
        Context :only_after, :hooks => :after do
          hooks == [] && expectations[:only_after] += 1
        end
        hooks == [:spec_Z] && expectations[:only_after] += 1

      end
      output = Specular.run __method__
      puts output.failures if output.failed?
      expectations.each_pair do |expectation, value|
        assert_equal value, 2, 'expected %s to be 2 but it is %s' % [expectation, value.inspect]
      end
    end

  end
end
