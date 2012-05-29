
[![Build Status](https://secure.travis-ci.org/slivu/enter.png)](http://travis-ci.org/slivu/enter)

<blockquote>
<strong>"Would you rather Test-First or Debug-Later?"</strong>
</blockquote>
\- Robert Martin

<blockquote>
<strong>"Simplicity is the ultimate sophistication"</strong>
</blockquote>
\- Leonardo da Vinci

### Motivation

*   I do not want to learn how to test. I simply want to ask Ruby: is `foo == bar`, or does `foo` respond to `bar` etc.
*   No monkey patching. I need tested objects and Ruby classes to stay pristine.
*   Occasionally, i need to write code and run tests simultaneously, on same page, keeping the visual contact.
    I can later move tests to right place, but when writing code i need to have running tests nearby, cause switching files leads to attention disruption.
*   I need verbose, granular and manageable output.

### Getting Started

**Install**

    $ gem install enter

**Load**

    require 'enter'

**Use**

```ruby
class Controller

    # action
    def buy product
        # ...
    end

    # tests
    Enter.task :buy do

        product = Model::Product.first

        Suppose 'user clicked Buy button' do

            response = get("/buy/" << product.url)

            is?( response.status ) == 200

            Then 'user should see the order details' do

                does?( response.body ) =~ /order details/

                And 'invitation to use credit card' do

                    does?( response.body ) =~ /credit card/

                end
            end
        end
    end
end

# running tests
puts Enter.run
```

<hr/>

# Tutorial

Tasks
---

Enter tasks can be defined anywhere in your code and executed anywhere too,
by calling `Enter.run('task name')`,<br/>
or just `Enter.run` to run all defined tasks.

```ruby
# Defining tasks:

class TestedClass

    # define methods
    # ...

    Enter.task :test_integers do
        # test your methods
    end

    Enter.task :test_strings do
        # test your methods
    end

    Enter.task :yet_another_task do
        # test your methods
    end
end

# Running tasks:

# run all tasks
Enter.run

# run tasks starting with "test"
Enter.run /^test/

# run only "test_integers" task
Enter.run :test_integers
```

To skip a task, use :skip option.<br/>
If :skip is set to true, the task will always be skipped.

```ruby
Enter.task :some_task, :skip => true do
    # tests here will not run
end
```

If :skip is a proc, the task will be skipped only if proc returns a positive value.

```ruby
Enter.task :some_task, :skip => proc { RUBY_VERSION.to_f == 1.8 } do
    # tests here will not run
end
```

All arguments passed to tasks are available as block parameters.<br/>
Use convenient names to read them:

```ruby
Enter.task NewsController, NewsModel, :status => 1 do |controller, model, filter|
  item = model.find filter
  action = controller.http.route action
end
```

Tests
---

Defining a test is as easy as think about it.

```ruby
Enter.task do

    Test :Nr1 do
        # some logic and assertions
    end

    Test :Nr2 do
        # some logic and assertions
    end
end
```

Tests can be unlimitedly nested.

```ruby
Enter.task do

    Describe 'Testing theory of relativity' do

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

Tests uses capitalized names and should have a name/description passed as first argument.

Aliases:

`Test`, `Testing`, `Given`, `When`, `Then`, `It`, `If`, `Let`,
`Say`, `Assume`, `Suppose`, `And`, `Or`, `Nor`, `But`, `However`,
`Should`, `Describe`, `Spec`, `Context`

Something missing? Please advise.

To skip a test, set :skip option to true:

```ruby
Given 'user clicked register', :skip => true do
    # tests here will not run
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
**No more steroids! Ruby is powerful enough!**

Here is a live example:

app.rb

```ruby
require 'enter'

class SomeClass

  module TestingHelper

    def looks_like_a_duck? obj
      obj.to_s =~ /duck/i
    end

    def quacks? obj
      obj.to_s =~ /quack/i
    end
  end

  Enter.task 'SomeTask' do
  
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

puts Enter.run
```

Running in terminal:

    ruby app.rb

<img src="http://prestorb.org/enter/example-long.png">

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

Enter.task do

    include SomeModule

    is(10).between? 0, 100
    # - passed

    is(10).between? 1, 5
    # - failed

end
```

Also helpers can be defined directly inside tasks:


```ruby
Enter.task do

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
Enter.task do

  before do
    @page = Model::Page.new
  end

  after do
    @page.destroy
  end

  # all tests inside task will execute this hooks
end
```

Hooks declared inside a test/context will run only for tests inside given test/context:

```ruby
Enter.task do

    Spec 'SomeSpec' do

      before do
        @page = Model::Page.new
      end

      after do
        @page.destroy
      end

      # this hooks will be executed only by tests inside current context and ignored on tests outside it.
    end
end
```

Worth to note that in case of nested tests,
children will override variables set by parents:

```ruby
Enter.task do

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

Hooks can also be executed selectively or disabled at all for each task in part.

To disable all hooks, set :hooks option to `nil` or `false`:

```ruby
Enter.task self do

    before do
        @var, @val = 2.times.map { 5.times.map { ('a'..'z').to_a[rand(26)] }.join }
        o 'clearing cookies...'
        cookies.clear
    end

    Should 'fail - wrong path provided' do

        get '/set', @var, :value => @val, :path => '/blah'

        Should 'be persisted in jar', :hooks => nil do     # this test wont execute any hooks
            is { cookies[@var]['/blah'].value } == @val
        end
        However 'not disposed via HTTP', :hooks => nil do  # this test wont execute any hooks
            r = get '/get', @var
            refute(r.body) == @val
        end
    end
end
```

To execute only :before hooks, set :hooks option to :before.<br/>
And to execute only :after hooks, set :hooks option to :after.<br/>

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
    o.success 'account created!'
end
```


Deploy
---

First of all you have to install `enter`

    $ gem install enter

If you also need HTTP functionality please install enter-http gem.<br/>
It will let you use `get`, `post`, `visit` etc.<br/>
[More details on enter-http](https://github.com/slivu/enter-http)

Then simply require enter in your application and run defined tasks:

```ruby
require 'enter'

class App

  Enter.task do
      Spec 'SomeSpec' do
        # some logic
      end
  end
end

puts Enter.run
```

You can also run tasks separately:

```ruby
class News
    Enter.task News do
        # some logic
    end
end

module Forum

    class Members
        Enter.task Forum::Members do
            # some logic
        end
    end

    class Posts
        Enter.task Forum::Posts do
            # some logic
        end
    end
end

# testing News Controller
puts Enter.run News

# testing Forum Members
puts Enter.run Forum::Members

# testing Forum Posts
puts Enter.run Forum::Posts

# testing all Forum classes
puts Enter.run /^Forum/
```

Results can also be printed separately:

*   `passed?`     - returns true if all tests passed
*   `failed?`     - returns true if at least one test failed
*   `failed`      - failed tests amount
*   `failures`    - details about failed tests
*   `output`      - details about testing process
*   `summary`
*   `skipped_tasks`
*   `skipped_tests`
*   `exit code`    - 0 on success, 1 on failures

```ruby
tests = Enter.run

if tests.passed?
  puts tests.summary
else
  puts tests.output
  puts tests.failures
end

if tests.skipped_tests.size > 0
  puts tests.skipped_tests
end

if tests.skipped_tests.size > 0
  puts tests.skipped_tests
end
```
