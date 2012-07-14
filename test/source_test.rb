module SpecularTest
  class SourceTest < MiniTest::Unit::TestCase

    def test
      spec = '%s.%s' % [self.class, __method__]

      Spec.new spec do

        def helper0 o
          is(1).helper1
        end

        def helper1 o
          is(1).helper2
        end

        def helper2 o
          is(1) == 2
        end

        is(1).helper0

      end
      output = Specular.run(spec).to_s
      file = File.basename(__FILE__)
      # Achtung! assertions depends on line position.
      # make sure to update array below if file updated.
      %w[21 10 14 18].each do |line|
        assert_match /#{Regexp.escape file}\:#{line}/, output
      end
    end


  end
end
