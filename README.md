# Flame Menu

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/flame-menu?style=flat-square)](https://cirrus-ci.com/github/AlexWayfer/flame-menu)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/flame-menu/main.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/flame-menu)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/flame-menu.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/flame-menu)
[![Depfu](https://img.shields.io/depfu/AlexWayfer/flame-menu?style=flat-square)](https://depfu.com/repos/github/AlexWayfer/flame-menu)
[![Inline docs](https://inch-ci.org/github/AlexWayfer/flame-menu.svg?branch=main)](https://inch-ci.org/github/AlexWayfer/flame-menu)
[![License](https://img.shields.io/github/license/AlexWayfer/flame-menu.svg?style=flat-square)](LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/flame-menu.svg?style=flat-square)](https://rubygems.org/gems/flame-menu)

Navigation menu for Flame applications.

There are helper methods (like `@menu.current`),
but you have to write an HTML layout by yourself (as you want to).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flame-menu'
```

And then execute:

```shell
bundle install
```

Or install it yourself as:

```shell
gem install flame-menu
```

## Usage

```ruby
# controllers/site/_controller.rb

module MyApplication
  module Site
    class Controller < MyApplication::Controller
      include Flame::Menu

      ## Automatic look-up for controllers like `Site::AboutController`
      MENU_ITEMS = %i[
        index
        about
        faq
      ].freeze

      protected

      ## Must be defined, but can be simply `true` for public access
      def available?(controller = self.class)
        ## Example:

        # return false unless authenticated_account
        # return true if controller::PERMISSION.nil?
        #
        # authenticated_account.split(',').include? controller::PERMISSION.to_s
      end
    end
  end
end
```

```erb
<% if @menu %>
  <nav>
    <%
      @menu.current.ancestors.reverse.each do |parent|
        items = parent.available
        next if items.size < 2
    %>
      <% items.each do |item| %>
        <a
          href="<%= path_to item.controller %>"
          class="<%= 'selected' if item.current? %>"
        ><%=
          t.site.header.nav[parent.key][item.key]
        %></a>
      <% end %>
    <% end %>
  </nav>
<% end %>
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `toys rspec` to run the tests.

To install this gem onto your local machine, run `toys gem install`.

To release a new version, run `toys gem release %version%`.
See how it works [here](https://github.com/AlexWayfer/gem_toys#release).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/AlexWayfer/flame-menu).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
