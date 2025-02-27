# FORK

This addresses the following issues:

* Nothing happens when using Puma (or any other threaded server) https://github.com/indirect/rails-footnotes/issues/223
* Support for frozen string literals https://github.com/indirect/rails-footnotes/pull/299

To use this fork, add the following line to your `Gemfile`. We have no plans to release a gem file at this moment.

```
gem "rails-footnotes", :git => "https://github.com/threecolts/rails-footnotes.git"
```

# Rails 7 Footnotes

Rails footnotes displays footnotes in your application for easy debugging, such as sessions,
request parameters, cookies, filter chain, routes, queries, etc.

Even more, it contains links to open files directly in your editor including
your backtrace lines.

### Installation

1. Add to your `Gemfile` with `bundle add rails-footnotes`
2. Run `bundle install`
3. Generate the initializer with `bin/rails generate rails_footnotes:install`

This will create an initializer with default config and some examples.

### Hooks

You can run blocks before and after footnotes are evaluated.

```
Footnotes.setup do |config|
  config.before do |controller, filter|
    filter.notes = (controller.class.name =~ /Message/ && controller.action_name == 'index' ? [:assigns] : [])
  end

  config.before do |controller, filter|
    filter.notes |= [:params] if controller.class.name =~ /Profile/ && controller.action_name == 'edit'
  end
end
```

### Editor links

By default, files are linked to open in TextMate, but you can use any editor with a URL scheme. Here are some examples for other editors:

**MacVim**

In `config/initializers/rails-footnotes.rb` do:

    f.prefix = 'mvim://open?url=file://%s&line=%d&column=%d'

Here you need to choose a prefix compatible with your text editor. The %s is
replaced by the name of the file, the first %d is replaced by the line number and
the second %d is replaced by the column number.

Take note that the order in which the file name (%s), line number (%d) and column number (%d) appears is important.
We assume that they appear in that order. "foo://line=%d&file=%s" (%d precedes %s) would throw out an error.

**Sublime Text 3**

Install [subl](https://github.com/dhoulb/subl), then use:

    f.prefix = 'subl://open?url=file://%s&line=%d&column=%d'

**Use with Docker, Vagrant, or other virtual machines**

If you're running your app in a container or VM, you'll find that the edit links won't work because the paths point to the VM directory and not your native directory. To solve this, you can use a lambda for the prefix and modify the pathname accordingly.

For example,

    f.prefix = ->(*args) do
      filename = args[0].sub '/docker', '/Users/name/projects/myproject'
      "subl://open?url=file://#{filename}&line=#{args[1]}&column=#{args[2]}"
    end

replaces the VM directory /docker with the macOS directory containing the source code.

**Footnotes Display Options**

By default, footnotes are appended at the end of the page with default stylesheet. If you want
to change their position, you can define a div with id "footnotes_holder" or define your own stylesheet
by turning footnotes stylesheet off:

    f.no_style = true

You can also lock the footnotes to the top of the window, hidden by default, and accessible
via a small button fixed to the top-right of your browser:

    f.lock_top_right = true

To set the font-size for the footnotes:

    f.font_size = '13px'

Another option is to allow multiple notes to be opened at the same time:

    f.multiple_notes = true

Finally, you can control which notes you want to show. The default are:

    f.notes = [:session, :cookies, :params, :filters, :routes, :env, :queries, :log]

Setting <tt>f.notes = []</tt> will show none of the available notes, although the supporting CSS and JavaScript will still be included. To completely disable all rails-footnotes content on a page, include <tt>params[:footnotes] = 'false'</tt> in the request.

### Creating your own notes

Creating your notes to integrate with Footnotes is easy.

1. Create a Footnotes::Notes::YourExampleNote class
2. Implement the necessary methods (check abstract_note.rb[link:lib/rails-footnotes/abstract_note.rb] file in lib/rails-footnotes)
3. Append your example note in Footnotes::Filter.notes array (usually at the end of your environment file or in the initializer):

For example, to create a note that shows info about the user logged in your application you just have to do:

    module Footnotes
      module Notes
        class CurrentUserNote < AbstractNote
          # This method always receives a controller
          #
          def initialize(controller)
            @current_user = controller.instance_variable_get("@current_user")
          end

          # Returns the title that represents this note.
          #
          def title
            "Current user: #{@current_user.name}"
          end

          # This Note is only valid if we actually found an user
          # If it's not valid, it won't be displayed
          #
          def valid?
            @current_user
          end

          # The fieldset content
          #
          def content
            escape(@current_user.inspect)
          end
        end
      end
    end

Then put in your environment, add in your initializer:

    f.notes += [:current_user]

### Footnote position

By default the notes will be showed at the bottom of your page (appended just before `</body>`).
If you'd like the footnote, to be at a different place (perhaps for aesthetical reasons) you can edit one of your views and add:

    <div id="footnotes_holder"></div>

at an appropriate place, your notes will now appear inside div#footnotes_holder

### Bugs and Feedback

If you discover any bugs, please open an issue.
If you just want to give some positive feedback or drop a line, that's fine too!

