module SpecularTest
  class GlobalHooksTest < MiniTest::Unit::TestCase

    module SomeHelper
      def some_helper
        __method__
      end
    end

    def test_boot
      Spec.new __method__ do
        does(self).respond_to? :some_helper
        o some_helper
      end

      session = Specular.new do
        boot do
          include SomeHelper
        end
      end
      output = session.run __method__
      assert_match /some_helper/, output.to_s
    end

    def test_halt
      Spec.new __method__ do
        does(self).respond_to? :some_helper
        o some_helper
      end

      session = Specular.new do
        halt do
          $:.unshift '/blah!'
        end
      end
      session.run __method__
      assert_equal $:.shift, '/blah!'
    end

    def test_before
      spec = '%s#%s' % [self.class, __method__]
      Spec.new spec do
      end

      session = Specular.new do
        before do
          o 'GlobalBeforePassed'
        end
      end
      output = session.run spec
      assert_match /GlobalBeforePassed/, output.to_s
    end

    def test_after
      spec = '%s#%s' % [self.class, __method__]
      Spec.new spec do
      end

      session = Specular.new do
        before do
          o 'GlobalAfterPassed'
        end
      end
      output = session.run spec
      assert_match /GlobalAfterPassed/, output.to_s
    end

  end
end
