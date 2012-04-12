
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

    class App

        def some_method
            'some text'
        end

        # writing tests
        Spine.vertebra 'GenericTest' do

            Should 'do a simple test' do
            
                text = App.new.some_method

                is(body) == 'some text'
                # - passed

                does(body) =~ /text/
                # - passed
            end
        end
    end

    # running tests
    tests = Spine.new
    tests.run
    puts tests.to_s
