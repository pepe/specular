
### Specular

**Natural Unit Testing using Inline and/or Regular Specs**

[![Build Status](https://secure.travis-ci.org/slivu/specular.png)](http://travis-ci.org/slivu/specular)

<blockquote>
<strong>"Would you rather Test-First or Debug-Later?"</strong><br/>
Robert Martin
</blockquote>

<blockquote>
<strong>"Simplicity is the ultimate sophistication"</strong><br/>
Leonardo da Vinci
</blockquote>

### Highlights

*   Natural and Simple. No need to learn redundant techniques. Simply ask Ruby: is `foo == bar`
*   No monkey patching. Tested objects and Ruby classes kept pristine.
*   Inline Specs. Write specs anywhere, this wont affect your runtime in any way.
*   Verbose, granular and manageable output.

## Tutorial
[Specs](#specs) |
[Tests](#tests) |
[Assertions](#assertions) |
[Builtin Helpers](#builtin-helpers) |
[Custom Helpers](#custom-helpers) |
[Global Hooks](#global-hooks) |
[Local Hooks](#local-hooks) |
[Output](#output) |
[Deploy](#deploy)

### Getting Started

**Install**

    $ gem install specular

**Load**

```ruby
require 'specular'
```

**Use**

```ruby
class Controller

    # action
    def buy product
        # ...
    end

    # tests
    Spec.new :buy do

        product = Model::Product.first

        Suppose 'user clicked Buy button' do

            get("/buy/" << product.url)

            check( last_response.status ) == 200

            Then 'user should see the order details' do

                prove( response.body ) =~ /order details/

                And 'invitation to use credit card' do

                    does?( response.body ) =~ /credit card/

                end
            end
        end
    end
end

# running tests
puts Specular.run
```

<hr/>


Specs
---

**[ [top &uarr;](#tutorial) ]**

Specs can be defined anywhere in your code and executed anywhere too,
by calling `Specular.run('spec name')`,<br/>
or just `Specular.run` to run all defined specs.

```ruby
# Defining specs:

class TestedClass

    # define methods
    # ...

    Spec.new :test_integers do
        # test your methods
    end

    Spec.new :test_strings do
        # test your methods
    end

    Spec.new :yet_another_spec do
        # test your methods
    end
end

# Running specs:

# run all specs
Specular.run

# run specs starting with "test"
Specular.run /^test/

# run only "test_integers" spec
Specular.run :test_integers
```

To skip a spec, use :skip option.<br/>
If :skip is set to true, the spec will always be skipped.

```ruby
Spec.new :some_spec, :skip => true do
    # tests here will not run
end
```

If :skip is a proc, the spec will be skipped only if proc returns a positive value.

```ruby
Spec.new :some_spec, :skip => proc { RUBY_VERSION.to_f == 1.8 } do
    # tests here will not run for ruby1.8
end
```

All arguments passed to specs are available as block parameters.<br/>
Use convenient names to read them:

```ruby
Spec.new NewsController, NewsModel, :status => 1 do |controller, model, filter|
  item = model.find filter
  action = controller.http.route action
end
```

Tests
---

**[ [top &uarr;](#tutorial) ]**

Defining a test is as easy as thinking about it.

```ruby
Spec.new do

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
Spec.new do

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

<pre>
:Should, :Describe, :Context, :Ensure,
:Test, :Testing, :Set, :Setting,
:Given, :When, :Then,
:It, :He, :She,
:If, :Let, :Say, :Assume, :Suppose,
:And, :Or, :Nor, :But, :However
</pre>

Something missing? Please advise.

To skip a test, set :skip option to true:

```ruby
Given 'user clicked register', :skip => true do
    # tests here will not run
end
```

If :skip is a proc, the test will be skipped only if proc returns a positive value.

Assertions
---

**[ [top &uarr;](#tutorial) ]**

To define assertions you should remember a single rule - "**The Rule of Two Brackets**".

The logic is extremely simple - **tested objects should be placed inside 2 brackets, round or curly**.<br/>

Everything after brackets is done in pure Ruby, without "wise" tricks and hacks.

No code is wiser than no code.

Let's suppose `foo` is tested object and `bar` is expected value.<br/>
According to rule of two brackets, the test will look like this:

```ruby
is?(foo) == bar
```

Simple? Huh?<br/>
Let's play a bit...

```ruby
is?(foo) > bar
does?(foo) =~ bar
are(foo).instance_of? bar
does(foo).respond_to? bar
# etc
```

Looks nice and grammatically correctly.

However, the main virtue is that tested objects are kept pristine!<br/>
They are just compared to expected value without being hacked and injected with various unneeded artifacts.<br/>
**No more steroids! Ruby is powerful enough!**

Here is a live example:

app.rb

```ruby
require 'specular'

class SomeClass

  module TestingHelper

    def looks_like_a_duck? obj
      obj.to_s =~ /duck/i
    end

    def quacks? obj
      obj.to_s =~ /quack/i
    end
  end

  Spec.new 'SomeSpec' do
  
    Describe :BasicTests do

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

puts Specular.run
```

Running in terminal:

    ruby app.rb

<img src="https://github.com/slivu/specular/raw/master/example-long.png" />

Aliases:

<pre>
:is, :is?,
:are, :are?,
:does, :does?,
:expect, :assert, :check,
:assume, :await, :affirm,
:verify, :prove, :certify,
:test, :try,
:refute, :false?
</pre>

Something missing? Please advise.

Builtin Helpers
---

**[ [top &uarr;](#tutorial) ]**

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

**[ [top &uarr;](#tutorial) ]**

As simple as `include ModuleName`

**Worth to note** that helpers receive tested object as first argument!

The arguments you pass goes after tested object.

In example below, 2 arguments are passed, but the helper receives 3,
cause the first one is the tested object.

```ruby
module SomeHelper
    def between? val, min, max
        (min..max).include? val
    end
end

Spec.new do

    include SomeModule

    is(10).between? 0, 100
    # - passed

    is(10).between? 1, 5
    # - failed

end
```

Helpers can also be defined directly inside specs:

```ruby
Spec.new do

    def between? val, min, max
        (min..max).include? val
    end

    is(10).between? 0, 100
    # - passed

    is(10).between? 1, 5
    # - failed

end
```

```ruby
Spec.new App do

    def contain_suitable_headers? response, amount, *directives
      actual = response.headers.values_at('Cache-Control', 'Expires')
      expected = [
          RouterUtils.compile_cache_control(*directives << {:max_age => amount}),
          (Time.now + amount).httpdate
      ]
      is?(expected) == actual
    end

    get
    does(last_response).contain_suitable_headers? 100, :public

    get :private
    does(last_response).contain_suitable_headers? 600, :private, :must_revalidate
end
```

Global Hooks
---

**[ [top &uarr;](#tutorial) ]**

To execute some code inside class that will run specs, use `Specular#boot` and `Specular#halt`.

Pass any number of arguments to filter specs the hooks will be applied to.</br>
Specs can be filtered by name or by regex.

`Specular#boot` block will run at class level before specs starts.

`Specular#halt` block will run at class level after specs finished.

**Example:** load rack-test methods

```ruby
session = Specular.new
session.boot do
    include Rack::Test::Methods
end

puts session.run
```

**Example:** load rack-test methods only for App spec and specs containing Web

```ruby
session = Specular.new
session.boot :App, /Web/ do
    include Rack::Test::Methods
end

puts session.run
```


To run some code inside each spec instance, use `Specular#before` and `Specular#after`.

`Specular#before` will run just before spec starting.

`Specular#after` will run after spec finished.

**Example:**

```ruby
session = Specular.new do
    before do
        @some_var = 'some val'
    end
end

puts session.run
```

**Note:** All hooks will run unconditionally, even if there was failed tests.

Please note that parameters passed to spec are available for global/local hooks through arguments.

**Example:**

```ruby
class TestedApp
    # ...
end

Spec.new TestedApp do
    # ...
end

\# now, from another context that does not know about TestedApp class
session = Specular.new
session.boot do |app|
    puts app.name
    #=> TestedApp
end
```

Local Hooks
---

**[ [top &uarr;](#tutorial) ]**

`before` / `after` - executing code before/after each test.

Hooks defined at spec level will be executed by all tests inside spec:

```ruby
Spec.new do

  before do
    @page = Model::Page.new
  end

  after do
    @page.destroy
  end

  # all tests inside spec will execute this hooks
end
```

Hooks declared inside a test/context will run only for tests inside given test/context:

```ruby
Spec.new do

    Context :SomeSpec do

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
Spec.new do

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

Hooks can also be executed selectively or disabled at all for each spec in part.

To disable all hooks, set :hooks option to `nil` or `false`:

```ruby
Spec.new self do

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

**[ [top &uarr;](#tutorial) ]**

`o` method allow to print additional info during testing process.<br/>
`puts` & co. will print info somewhere on the fields too, however `o` will print the info in right place and optionally colorized.

```ruby
Context 'Creating new account' do

    data = {name: rand, email: rand}
    o 'sending request ...'

    result = post '/', data
    is?(result.body) == 'success'
    o.success 'account created!'
end
```


Deploy
---

**[ [top &uarr;](#tutorial) ]**

First of all you have to install `specular`

    $ gem install specular

If HTTP functionality needed you can install [Motor](https://github.com/slivu/motor) or rack-test.<br/>

Then simply require specular in your application and run defined specs:

```ruby
require 'specular'

class App

  Spec.new do
    # some tests/assertions
  end
end

puts Specular.run
```

You can also run specs separately:

```ruby
class News
    Spec.new News do
        # some logic
    end
end

module Forum

    class Members
        Spec.new Forum::Members do
            # some logic
        end
    end

    class Posts
        Spec.new Forum::Posts do
            # some logic
        end
    end
end

session = Specular.new

# testing News Controller
puts session.run News

# testing Forum Members
puts session.run Forum::Members

# testing Forum Posts
puts session.run Forum::Posts

# testing all Forum classes
puts session.run /^Forum/
```

Results can be printed separately either:

*   `passed?`     - returns true if all tests passed
*   `failed?`     - returns true if at least one test failed
*   `failed`      - failed tests amount
*   `failures`    - details about failed tests
*   `summary`
*   `skipped_specs`
*   `skipped_tests`
*   `output`       - all of the above
*   `exit code`    - 0 on success, 1 on failures

**Example:**

```ruby
tests = Specular.run

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
