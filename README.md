
<blockquote>
<strong>"Would you rather Test-First or Debug-Later?"</strong>
</blockquote>
\- Robert Martin

<blockquote>
<strong>"Simplicity is the ultimate sophistication"</strong>
</blockquote>
\- Leonardo da Vinci

### Motivation

*   I do not want to learn how to test. I simply want to ask Ruby: is foo == bar, or does foo respond to bar etc.
*   No monkey patching. I need tested objects and Ruby classes to stay pristine.
*   Occasionally, i need to write code and tests simultaneously, on same page, keeping the visual contact.
    I can later move tests to right place, but when writing code i need to have tests nearby, cause switching files leads to attention disruption.
*   I need verbose, granular and manageable output.

### Getting Started

**Install**

    $ gem install spine

**Load**

    require 'spine'

**Use**

```ruby
class Controller

    # writing action
    def buy product
        # render action
    end

    # writing tests
    Spine.task :buy do

        product = Model::Product.first

        Suppose 'user clicked Buy button' do

            response = get "/buy/#{ product.url }"

            is?( response.status ) == 200

            He 'should see the order details' do

                does?( response.body ) =~ /order details/

                And 'invitation to use credit card' do

                    does?( response.body ) =~ /credit card/

                end
            end
        end
    end
end

# running tests
puts Spine.run
```

<hr/>

# Tutorial

Tasks
---

Spine tasks can be defined anywhere in your code and executed anywhere too,
by calling `Spine.run('task name')`,<br/>
or just `Spine.run` to run all defined tasks.

```ruby
# Defining tasks:

class TestedClass

    # define methods

    Spine.task :test_integers do
        # test your methods
    end

    Spine.task :test_strings do
        # test your methods
    end

    Spine.task :yet_another_task do
        # test your methods
    end
end

# Running tasks:

# run all tasks
Spine.run

# run tasks starting with "test"
Spine.run /^test/

# run only "test_integers" task
Spine.run :test_integers
```

To skip a task, set :skip option to true:

```ruby
Spine.task :some_task, skip: true do
    # tests here will not be executed
end
```

All arguments passed to tasks are available as block parameters.<br/>
Use convenient names to read them:

```ruby
Spine.task NewsController, NewsModel, :status => 1 do |controller, model, filter|
  item = model.find filter
  action = controller.http.route action
end
```

Specs
---

Used when you need to define multiple tests within same context.

First argument is required and should contain spec name/description.<br/>
Second argument are optional and may contain a hash of options.

```ruby
Spine.task do

    Spec 'Testing links' do
      # some logic
    end

    Spec 'Testing banners' do
      # some logic
    end
end
```

Specs can be nested:

```ruby
Spec 'Testing links' do

  Spec 'outgoing links' do
    # some logic
  end

  Spec 'internal links' do
    # some logic
  end
end
```

Specs can be defined only inside tasks.

To skip a spec, set :skip option to true:

```ruby
Spec 'Skipping for now', skip: true do
  # tests here will not be executed
end
```

Tests
---

Defining a test is as easy as think about it.

Tests can be defined inside specs or directly inside tasks.

```ruby
Spine.task do

    Test :Nr1 do
        # some logic and assertions
    end

    Test :Nr2 do
        # some logic and assertions
    end
end
```

```ruby
Spine.task do

    Testing :UI do
        # some logic and assertions
    end
end
```

```ruby
Spine.task do

    Spec 'Testing theory of relativity' do

        Suppose "I'm Superman" do
            And "I can fly" do
                But "I can not pry" do
                    When "I'm landing" do
                        is("it real to keep my ass?").kind_of? Random
                    end
                end
            end
        end
    end
end
```

Tests uses capitalized names and should have a name/description passed as first argument.<br/>
As per specs, consequent arguments are optional and may contain a hash of options.

Aliases:

`Test`, `Testing`, `Given`, `When`, `Then`, `It`, `If`, `Let`,
`Say`, `Assume`, `Suppose`, `And`, `Or`, `Nor`, `But`, `However`, `Should`

Something missing? Please advise.

To skip a test, set :skip option to true:

```ruby
Given 'user clicked register', skip: true do
    # tests here will not be executed
end
```

Assertions
---

To define assertions you should remember a single rule - "**The Rule of Two Brackets**".

The logic is extremely simple - **tested objects should be placed inside 2 brackets, round or curly**.<br/>

Everything after brackets is done in pure Ruby, without "wise" tricks and hacks.

No code is wiser than no code.

Let's suppose `foo` is tested object and `bar` is expected value.<br/>
According to rule of two brackets, the test will look like this:

    is?(foo) == bar

Simple? Huh?<br/>
Let's play a bit...

    is?(foo) > bar
    does?(foo) =~ bar
    are(foo).instance_of? bar
    does(foo).respond_to? bar
    # etc

Looks nice and grammatically correctly.

However, the main virtue is that tested objects are kept pristine!<br/>
They are just compared to expected value without being hacked and injected with various unneeded artifacts.<br/>
No more steroids! Ruby is powerful enough!

Here is a live example:

app.rb

```ruby
require 'spine'

class SomeClass

  module TestingHelper

    def looks_like_a_duck? obj
      obj.to_s =~ /duck/i
    end

    def quacks? obj
      obj.to_s =~ /quack/i
    end
  end

  Spine.task 'SomeTask' do
  
    Spec 'BasicTests' do

      include TestingHelper

      def smells_like_a_pizza? obj
        obj.to_s =~ /#{Regexp.union 'pizza', 'olives', 'cheese'}/i
      end

      def contain? food, ingredient
        food =~ /#{ingredient}/
      end

      Should 'pass' do

        foo, bar = 1, 1
        is(foo) == bar
        refute(foo) > bar

        foo, bar = 1, 2
        false?(foo) == bar
        is?(foo) <= bar

        foo, bar = 'foo'.freeze, 'bar'
        is(foo).frozen?
        refute(bar).frozen?

        foo = "Hi, I'm Duck the Greatest! Quack! Quack!"
        does(foo).looks_like_a_duck?
        does(foo).quacks?

        pizza = "I'm a pizza with olives and lot of cheese!'"
        does(pizza).smells_like_a_pizza?
        does(pizza).contain? 'olives'
        does(pizza).contain? 'cheese'

        foo = 1
        bar = [foo, 2, 3]
        is(bar.size) == 3
        does(bar).respond_to? :include?
        does(bar).include? foo

        does { throw :some, :test }.throw_symbol? :some, :test
        expect { something risky }.to_raise_error

      end

      Should 'fail' do
        foo, bar = 'some string', :some_symbol
        expect(foo) == bar
        is(1) == 1
      end

      Should 'fail' do
        does { 1+1 }.throw_symbol?
      end

      Should 'fail' do
        refute { something risky }.raise_error
      end

    end
  end
end

puts Spine.run
```

Running in terminal:

    ruby app.rb

<img src="http://prestorb.org/spine/example-long.png">

Aliases:

`is`,
`is?`,
`are`,
`are?`,
`does`,
`does?`,
`expect`,
`assert`,
`check`

Something missing? Please advise.

Builtin Helpers
---

### raise_error

Works only with blocks.

If called without args, framework expecting the block will raise an error of any type:

```ruby
expect{ some bad code here }.to_raise_error
# - passed

expect{ 'some bad code here' }.to_raise_error
# - failed
```

If called with a single arg and the arg is a Class, framework expecting the block will raise an error of given class:

```ruby
does{ some bad code here }.raise? NoMethodError
# - passed
does{ some bad code here }.raise? SomeCustomError
# - failed
```

If called with a single arg and the arg is a string or regex, framework expecting the block will raise an error containing given text:

```ruby
does{ some bad code here }.raise? /bad code/
# - passed
does{ some bad code here }.raise? 'bad code'
# - passed
does{ some bad code here }.raise? 'blah'
# - failed
```

If called with two args, a class and a string/regex, framework expecting the block will raise an error of Class type and also containing given text:

```ruby
does{ some bad code here }.raise? NoMethodError, /bad code/
# - passed
does{ some bad code here }.raise? SomeCustomError, /bad code/
# - failed
does{ some bad code here }.raise? NoMethodError, 'blah'
# - failed
```

Aliases:

`raise?`,
`raise_error?`,
`to_raise`,
`to_raise_error`

### throw_symbol

Works only with symbols.

If called without args, framework expecting the block will throw any symbol:

```ruby
expect{ throw :back_to_future }.throw_symbol
# - passed
expect{ throw :anywhere }.throw_symbol
# - passed
```

If 1st arg given, framework expecting the block will throw the given symbol:

```ruby
does{ throw :begining_of_times }.throw_symbol? :begining_of_times
# - passed
does{ throw :begining_of_times }.throw_symbol? :far_far_away
# - failed
```

If 2nd arg is also given, framework expecting the block will throw the given symbol and also will pass the given value:

```ruby
does{ throw :begining_of_times, 'N bc' }.throw_symbol? :begining_of_times, 'N bc'
# - passed
does{ throw :begining_of_times, 'N bc' }.throw_symbol? :begining_of_times, 'today'
# - failed
```

Aliases:

`throw?`,
`throw_symbol?`,
`to_throw`,
`to_throw_symbol`

Custom Helpers
---

As simple as `include ModuleName`

```ruby
module SomeHelper
    def between? val, min, max
        (min..max).include? val
    end
end

Spine.task do

    include SomeModule

    is(10).between? 0, 100
    # - passed

    is(10).between? 1, 5
    # - failed

end
```

Also helpers can be declared directly inside tasks:


```ruby
Spine.task do

    def between? val, min, max
        (min..max).include? val
    end

    is(10).between? 0, 100
    # - passed

    is(10).between? 1, 5
    # - failed

end
```

Hooks
---

`before` / `after` - executing code before/after each test.

Hooks defined at task level will be executed by all tests inside task:

```ruby
Spine.task do

  before do
    @page = Model::Page.new
  end

  after do
    @page.destroy
  end

  # all tests inside task will execute this hooks
end
```

Hooks declared inside spec will run only for tests inside given spec:

```ruby
Spine.task do

    Spec 'SomeSpec' do

      before do
        @page = Model::Page.new
      end

      after do
        @page.destroy
      end

      # this hooks will be executed only by tests inside current spec and ignored on other specs.
    end
end
```

Hooks can not be be defined inside tests. That makes no sense.

Worth to note that in case of nested specs/tests,
children will override variables set by parents:

```ruby
Spine.task do

  before do
    @n = 0
  end

  Test :Nr1 do

    # @n is 0
    @n += 1 # @n is 1

    Test :Nr1_1 do
      # @n is 0
    end

    # @n is 0 cause it was override by Test Nr1_1
  end

end
```

Last test status
---

*   `passed?` - returns true if last test passed
*   `failed?` - returns true if last test failed

```ruby
is?(1) == 1
passed? # true
failed? # false

is?(1) == 0
passed? # false
failed? # true
```

Output
---

`o` method allow to print additional info during testing process.<br/>
`puts` & co. will print info somewhere on the fields too, however `o` will print the info in right place and optionally colorized.

```ruby
Spec 'Creating new account' do

  data = {name: rand, email: rand}
  o 'sending request ...'

  result = post '/', data
  is?(result.body) == 'success'

  if passed?
    o.success 'account created!'
  end

  if failed?
    o.error 'was unable to create account'
    o.warn 'sent data: %s' % data
  end
end
```


Deploy
---

First of all you have to install `spine`

    $ gem install spine

Then simply require it in your application and run defined tasks:

```ruby
require 'spine'

class App

  Spine.task do
      Spec 'SomeSpec' do
        # some logic
      end
  end
end

puts Spine.run
```

You can also run tasks separately:

```ruby
class News
    Spine.task News do
        # some logic
    end
end

module Forum

    class Members
        Spine.task Forum::Members do
            # some logic
        end
    end

    class Posts
        Spine.task Forum::Posts do
            # some logic
        end
    end
end

# testing News Controller
puts Spine.run News

# testing Forum Members
puts Spine.run Forum::Members

# testing Forum Posts
puts Spine.run Forum::Posts

# testing all Forum classes
puts Spine.run /^Forum/
```

Results can also be printed separately:

*    `passed?`  - returns true if all tests passed
*    `failures` - details about failed tests
*    `failed`   - failed tests amount
*    `output`   - details about testing process
*    `summary`
*    `skipped_tasks`
*    `skipped_specs`
*    `skipped_tests`

```ruby
specs = Spine.run

if specs.passed?
  puts specs.summary
else
  puts specs.output
  puts specs.failures
end

if specs.skipped_specs.size > 0
  puts specs.skipped_specs
end

if specs.skipped_tests.size > 0
  puts specs.skipped_tests
end
```
