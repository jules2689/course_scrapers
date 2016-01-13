# Einstein

A collection of web scrapers for online courses. This gem is intended to be able to scrape hundreds of courses into one aggregated spot.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'einstein'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install einstein

## Usage

Under `lib/einstein` there are a series of scrapers. Each scraper can be called simply by running `Einstein::[SCRAPER_NAME].fetch`. This will return a hash with the following keys: 

  - course_title (title of the course)
  - course_code (the code of the course, if any)
  - level (the level at which this course is rated, if any))
  - link (link to the course)
  - description (description of the course)
  - image (a url for an image representing the course)
  - price (the price of the course. If none, then "free")
  - syllabus_link (a link to the syllabus for the course, if any
  - department (the department from which this is offered. TODO: map these to a number of sane values)
  - provider (from where did this course come? Harvard? MIT?)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jules2689/einstein. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

