
<blockquote>
<strong>Would you rather Test-First or Debug-Later?</strong><br/>
Robert Martin
</blockquote>

### Motivation

*   I need to write logic and tests using same ink on same paper, meant they physically should be on same page - visual contact are very important to me.
*   I do not want to learn how to test. I simply want to ask Ruby: is foo == bar, or does foo respond to bar etc.
*   No monkey patching. I need tested objects and Ruby classes to stay pristine.
*   I need verbose, granular and manageable output.

### Implementation

**The Rule of Two Brackets**

Tested objects should always be placed inside brackets(round or curly ones).

    is(foo) == bar
    is(foo).eql? bar
    is(foo) > bar
    does(foo).include? bar
    are(foo).instance_of? bar
    does { foo.is_doing_something_risky }.raise_error?
    expect { foo.bar }.to_throw_symbol

Anything is done in natural, easy and rememberable way, without any object to be hacked.

### Getting Started

**Install**

    $ gem install spine

**Load**

    require 'spine'

**Use**

```ruby
class App

    def some_method
        'some text'
    end

    # writing tests
    Spine.vertebra 'GenericTest' do

        Should 'do a simple test' do

            body = App.new.some_method

            is(body) == 'some text'
            # - passed

            does(body) =~ /text/
            # - passed
        end
    end
end

# running tests
output = Spine.run
puts output.to_s
```

<img src="http://prestorb.org/spine/example.png">


# Tutorial

Tasks
---

Spine tasks can be defined anywhere in your code and executed anywhere too,
by calling `Spine.run('task name')`, or just `Spine.run` to execute all defined tasks.

#### Defining tasks:

    class TestedClass

        # define your methods

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

#### Running tasks:

    # run all tasks
    Spine.run

    # run tasks starting with "test"
    Spine.run /test/

    # run only "test_integers" task
    Spine.run :test_integers

To skip a task, set :skip option to true:

    Spine.task :some_task, skip: true do
        # some logic
    end

Specs
---

Each action can have multiple specs.
First argument is required and should contain spec name/description.
Consequent arguments are optional and may contain the action name or options hash.

    # action
    def details
      # some logic
    end

    ctrl.spec 'Testing links', :details do
      # some logic
    end

    ctrl.spec 'Testing banners', :details do
      # some logic
    end

To skip an spec, provide :skip option:

    ctrl.spec 'Skipping for now', skip: true do
      # code here will not be executed
    end

If second argument given, it is treated as action and browsers inside spec will make requests to given action:

    ctrl.spec 'Testing CRUD - edit', :edit do
      get 100 # will request /edit/100
    end

If no action given, browsers will make requests to :index action:

    ctrl.spec 'OverallTesting' do
      get # will request /index
    end

Scenarios
---

Scenarios are optional, however they are very useful when we need to split the spec into logical parts.

    ctrl.spec 'Testing theory of relativity' do

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

Scenarios uses capitalized names and should have a name/description passed as first argument.

As per specs, consequent arguments are optional and may contain the action name or options hash.

Supported scenarios:

*    `Given`
*    `When`
*    `Then`
*    `It`
*    `If`
*    `Let`
*    `Say`
*    `Assume`
*    `Suppose`
*    `And`
*    `But`
*    `Should`

Something missing? Please advise.

To skip a scenario, pass :skip option:

    ctrl.spec 'SomeSpec' do

      Given 'user clicked register', skip: true do
      end
    end

I action name given as first argument, browsers inside scenario will make requests to given action.

    ctrl.spec 'Buying Workflow', :buy do

      get 'Coolest-Product-Ever' # сделает запрос по адресу /buy/Coolest-Product-Ever

      # custom action for scenarios
      Suppose 'user choose to create a new account', :register do
        visit # will request /register
      end

    end

If no action given, browsers inside scenario will make requests to action inherited from spec or from parent scenario:

    ctrl.spec 'Buying Workflow', :buy do

      get 'Coolest-Product-Ever' # сделает запрос по адресу /buy/Coolest-Product-Ever

      # custom action for scenarios
      Suppose 'user choose to create a new account', :register do

        visit # will request /register

        When 'user click "Personal Account"' do
          visit 'personal-account' # сделает запрос по адресу /register/personal-account
        end

      end

      # this scenario using action set by spec
      If 'user has a coupon' do
        visit 'i-have-a-coupon' # сделает запрос по адресу /buy/i-have-a-coupon
      end

    end

Tests
---

For tests declaration, PrestoTest uses a single rule - "The Rule of Two Brackets".<br/>
This is the only rule you'll have to remember, cause anything after brackets is done in pure Ruby, without hacking objects.

The logic is extremely simple - tested object should be placed inside 2 brackets.<br/>
Let's say foo is tested object and bar is expected value.<br/>
According to rule of two brackets the test will look like this:

    is(foo) == bar

Simple? Huh?<br/>
Let's play a bit...

    is?(foo) > bar
    is(foo) >= bar
    is?(foo) < bar
    is(foo) <= bar
    does(foo) =~ bar
    is?(foo).instance_of? bar
    does?(foo).respond_to? bar
    # etc

Looks nice, really nice.<br/>
The main virtue - objects kept in pristine state!<br/>
And yes, it looks naturally.

Here is a live example:

app.rb

    require 'presto'
    require 'spine'

    class App
      include Presto::Api
      http.map

      ctrl.spec 'BasicTests' do

        def smells_like_a_pizza? obj
          obj.to_s =~ /#{Regexp.union 'pizza', 'olives', 'cheese'}/i
        end

        def contain_cheese? obj
          obj.to_s =~ /cheese/i
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

          bar = "I'm a pizza with olives and lot of cheese!'"
          does(bar).smells_like_a_pizza?
          does(bar).contain_cheese?

          foo = 1
          bar = [foo, 2, 3]
          is(bar.size) == 3
          does(bar).respond_to? :include?
          does(bar).include? foo

          does { throw :some, :test }.throw_symbol? :some, :test
          expect { something risky }.to_raise NoMethodError

        end

        Should 'fail' do
          foo, bar = 'some string', :some_symbol
          expect(foo) == bar
        end

        Should 'fail' do
          is('foo').martian?
        end

        Should 'fail' do
          does { 1+1 }.throw_symbol?
        end

        Should 'fail' do
          refute { something risky }.raise_error NoMethodError
        end

      end

      private

      def looks_like_a_duck? obj
        obj.to_s =~ /duck/i
      end

      def quacks? obj
        obj.to_s =~ /quack/i
      end

    end
    app = Presto::App.new
    app.specs.run
    puts app.specs.to_s

Running in terminal:

    ruby app.rb

<img src="http://prestorb.org/spine/basic-tests.png" alt="image"/>
<hr/>

Aliases:

*    `is`
*    `is?`
*    `are`
*    `are?`
*    `does`
*    `does?`
*    `expect`
*    `assert`

Something missing? Please advise.

Builtin Helpers
---

### raise_error

Works only with blocks.

If called without args, framework expecting the block will raise an error of any type:

    expect{ some bad code here }.to_raise_error
    # - passed

    expect{ 'some bad code here' }.to_raise_error
    # - failed

If called with a single arg and the arg is a Class, framework expecting the block will raise an error of given class:

    does{ some bad code here }.raise? NoMethodError
    # - passed
    does{ some bad code here }.raise? SomeCustomError
    # - failed

If called with a single arg and the arg is a string or regex, framework expecting the block will raise an error containing given text:

    does{ some bad code here }.raise? /bad code/
    # - passed
    does{ some bad code here }.raise? 'bad code'
    # - passed
    does{ some bad code here }.raise? 'blah'
    # - failed

If called with two args, a class and a string/regex, framework expecting the block will raise an error of Class type and also containing given text:

    does{ some bad code here }.raise? NoMethodError, /bad code/
    # - passed
    does{ some bad code here }.raise? SomeCustomError, /bad code/
    # - failed
    does{ some bad code here }.raise? NoMethodError, 'blah'
    # - failed

Aliases:

*   `raise?`
*   `raise_error?`
*   `to_raise`
*   `to_raise_error`

### throw_symbol

Works only with symbols.

If called without args, framework expecting the block will throw any symbol:

    expect{ throw :back_to_future }.throw_symbol
    # - passed
    expect{ throw :anywhere }.throw_symbol
    # - passed

If 1st arg given, framework expecting the block will throw the given symbol:

    does{ throw :begining_of_times }.throw_symbol? :begining_of_times
    # - passed
    does{ throw :begining_of_times }.throw_symbol? :far_far_away
    # - failed

If 2nd arg is also given, framework expecting the block will throw the given symbol and also will pass the given value:

    does{ throw :begining_of_times, 'N bc' }.throw_symbol? :begining_of_times, 'N bc'
    # - passed
    does{ throw :begining_of_times, 'N bc' }.throw_symbol? :begining_of_times, 'today'
    # - failed

Aliases:

*   `throw?`
*   `throw_symbol?`
*   `to_throw`
*   `to_throw_symbol`


Custom Helpers
---

Helpers can be defined inside specs and/or inside controllers.

Helpers defined inside controllers are available for all specs.
It is recommended to put them in private zone so they would not be accessible from web.

Helpers defined inside spec will be available only inside that spec.

    ctrl.spec "SomeSpec" do
      def looks_like_jack? obj
        obj =~ /jack/
      end

      does('Jack Daniels').looks_like_jack?
      # - passed
      does('Captain Jack').looks_like_jack?
      # - passed
      does('Britney Spears').looks_like_jack?
      # - failed
    end


Browsers
---

If a spec/scenario are tied to some action(through second argument),
browsers inside them will make requests to that action.<br/>
Otherwise they will make requests to :index action.

    class Members
      include Presto::Api
      http.map :members

      def login
        # some logic
      end

      ctrl.spec "Testing Login", :login do

        get # will request /members/login
      end
    end

Action arguments can be passed by browser without specifying action name:

    def edit id

    end

    ctrl.spec 'Testing CRUD / edit', :edit do

      get 10 # will request /edit/10
    end

    def menu position
    end

    ctrl.spec 'Testing Menus', :menu do

      get 'top' # will request /menu/top
    end

HTTP params also can be passed via browser as a hash:

    def menu position
    end

    ctrl.spec 'Testing Menus', :menu do

      get 'top', :color => 'red' # will request /menu/top?color=red
    end

**However!**, if first browser argument is a symbol, it is treated as action name and browser will request given action:

    def menu position
    end
    def banners position
    end

    ctrl.spec 'Testing Menus', :menu do

      get 'top'            # will request /menu/top
      get :banners, 'top'  # will request /banners/top
    end

**Even Better!**, if first browser argument is a controller, browser will request actions inside given controller.<br/>
Please note that in this case the second argument should be the action name and consequent args should be the action params and HTTP params(if any).

    class Index
      include Presto::Api
      http.map :cms

      def menu scope = nil
      end
    end
    class Forum
      include Presto::Api
      http.map :forum

      def index
      end

      ctrl.spec 'Top menu' do
        get Index, :menu, :forum # will request /cms/menu/forum
      end
    end

This will help to keep tests working even if controllers changes their URL.<br/>
In the example above, if Index will change URL from /cms to say /pages, tests will continue to work without any modifications.

Rack::Test browser
---

### Standard Requests - get, post, put, delete, options, head

    response = get
    # response.body will contain data returned by action
    # response.headers will contain headers

Also you can access response data by `browser`

        get
        # browser.last_response.body will contain data returned by action
        # browser.last_response.headers will will contain headers

Same for `post`

If you need methods from Rack::Test::Methods also use `browser` method.

    response = get
    browser.last_response.follow_redirect!

    browser.header "User-Agent", "Firefox"

    browser.set_cookie
    browser.clear_cookies

    # etc

This is done to be able to use more browsers at same time.

### Ajax Requests

Same as standard ones, just add xhr_ prefix

    xhr_get
    xhr_post

Output can be accessed as per standard requests.

### JSON Requests

If some action returns JSON, you do need to parse it manually - PrestoTest will do it automatically.<br/>
On JSON requests, `response` will get a new method - `json` obviously :),
so you'll can access JSON object via `response.json`:

    def create
      # some logic
      {status: 1, message: 'success'}.to_json
    end

    ctrl.spec 'Creating items', :create do

      response = get_json
      # response.body: '{"status":1,"message":"success"}' [String]
      # response.json: {"status"=>1, "message"=>"success"} [Hash]
    end

I you need to access an JSON action via Ajax, simply add xhr_ prefix:

    xhr_get_json
    xhr_post_json

Authorization
---

If some action requires authorization, use `authorize` before request:

    authorize 'admin', 'reallySecretPassword'
    get

If some action requires digest authorization, use `digest_authorize` before request:

    digest_authorize 'admin', 'reallySecretPassword'
    get

To reset the authorization, use `reset!` or `reset_session!`:

    authorize 'admin', 'reallySecretPassword'
    get # will use authorization

    reset!
    get # will NOT use authorization

Capybara browser
---

Capybara is an optional browser, thus it is not installed as a dependency.<br/>
So, before use, you'll have to install configure it.

To use it on all specs, enable it globally by passing :capybara option to #run method:

    app = Presto::App.new
    app.specs.run :capybara => true
    puts app.specs.to_s

To use it only on some spec, pass it as option only for that spec:

    ctrl.spec 'SomeSpec', :some_action, :capybara => true do
      # some logic
    end

All about automated addressing is of course valid for `visit` method too:

    ctrl.spec 'SomeSpec', :some_action, :capybara => true do
      visit                        # will request /some_action
      visit 100                    # will request /some_action/100
      visit 100, :color => 'red'   # will request /some_action/100?color=red
    end
        </source>

Hooks
---

before/after - executing code before/after each test.

    ctrl.spec 'SomeSpec' do
      before do
        @page = Model::Page.new
      end

      after do
        @page.destroy
      end
    end

Hooks declared by spec will run for all tests on all scenarios inside spec.<br/>
And of course scenarios may have own hooks, which will be executed after spec hooks:

    ctrl.spec 'SomeSpec' do

      before do
        @page = Model::Page.new
      end

      after do
        @page.destroy
      end

      Should 'run a hook that will modify @page state' do
        before do
          @page.status = 1
        end
      end
    end

So, spec hooks are inherited by all scenarios.<br/>
However, scenario hooks are strictly personal and not inherited in any way, even by scenario children:

    ctrl.spec 'SomeSpec' do

      before do
        @page = Model::Page.new
      end

      after do
        @page.destroy
      end

      Should 'run a hook that will modify @page state' do

        before do
          @page.status = 1
        end
        # here tests will run top level hooks + scenario hooks

        Should 'run only spec hooks' do
          # here tests will run only top level hooks
        end

      end
    end
        </source>

Last test status
---

*   `passed?` - returns true if last test passed
*   `failed?` - returns true if last test failed

Example:

    ctrl.spec 'SomeSpec' do

      is(1) == 1
      passed? # true
      failed? # false

      is(1) == 0
      passed? # false
      failed? # true
    end

Output
---

`output` method allow to print additional info during testing process.<br/>
`puts` & co. will print info somewhere too, however `output` will print the info in right place and optionally colorized.

    ctrl.spec 'Creating new account', :register do

      data = {name: rand, email: rand}
      output 'sending request ...'

      result = post data
      is?(result.body) == 'success'

      if passed?
        output 'account created!', :green
      end
    end

Available colors:

*    red
*    green
*    yellow
*    blue
*    magenta
*    cyan
*    white

Errors
---

`error` allow to add additional details to error generated by last failed test.

    ctrl.spec 'Creating new account', :register do

      data = {name: rand, email: rand}
      result = post data
      is?(result.body) == 'success'
      if failed?
        error 'data provided: %s' % data
        error 'even more details'
        error 'and maybe some debugging'
        error 'etc...'
      end
      # will display standard error + manually added details

Deploy
---

First of all you have to install `spine`

    gem install spine

Then simply require it in your application:

    require 'presto'
    require 'spine'

    class App
      include Presto::Api
      http.map

      def index
        # some logic
      end

      ctrl.spec 'SomeSpec' do
        # some logic
      end
    end

    # testing app
    app = Presto::App.new
    app.specs.run
    if app.specs.passed?
      app.run
    else
      puts app.specs.to_s
    end

You can also test controllers/slices separately:

    class News
      include Presto::Api
      http.map :news

      ctrl.spec 'SomeSpec' do
        # some logic
      end
    end

    module Forum

      class Members
        include Presto::Api
        http.map :members

        ctrl.spec 'SomeSpec' do
          # some logic
        end
      end

      class Posts
        include Presto::Api
        http.map :posts

        ctrl.spec 'SomeSpec' do
          # some logic
        end
      end
    end

    # testing News Controller
    news_specs = Presto::App.mount(News).specs
    news_specs.run
    puts news_specs.to_s

    # testing Forum Slice
    forum_specs = Presto::App.mount(Forum).specs
    forum_specs.run
    puts forum_specs.to_s

Results can be printed separately too:

*    `passed?` - returns true if all tests passed
*    `output` - details about testing process
*    `skipped_specs`
*    `skipped_scenarios`
*    `failed_tests`
*    `summary`

Example:

    app = Presto::App.new
    specs = app.specs

    specs.run

    if specs.passed?
      puts specs.summary.to_s
    else
      puts specs.output.to_s
      puts specs.failed_tests.to_s
    end

    if specs.skipped_specs.size > 0
      puts specs.skipped_specs.to_s
    end

    if specs.skipped_scenarios.size > 0
      puts specs.skipped_scenarios.to_s
    end
