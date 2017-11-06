# ColaTTB

This gem scrapes the TTB COLA Registry (https://www.ttbonline.gov/colasonline/).  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cola_ttb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cola_ttb

## Usage

TODO: Write usage instructions here

## TODO
1. ~~Complete basic file setup~~
2. ~~Build scraper~~
  * ~~Build search and send request~~ (https://www.ttbonline.gov/colasonline/publicSearchColasBasic.do)
  * ~~Download search CSV~~
3. Handle downloaded CSVs
  * Parse CSV
  * Scrape each beverage information (https://www.ttbonline.gov/colasonline/viewColaDetails.do?action=publicFormDisplay&ttbid=17032001000566)
  * Build new CSV based on individual product scrapes
    * This will be final product ingested by Rails app

```ruby
@beer = Struct.new(brand_name: , fanciful_name: )
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zacscodingclub/cola_ttb.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Previous WIP to kind of "understand it"
```ruby

require 'mechanize'
URL_BASE = 'https://www.ttbonline.gov/colasonline'
# https://www.ttbonline.gov/colasonline/viewColaDetails.do?action=publicDisplaySearchBasic&ttbid=15344001000244
@agent = Mechanize.new do |agent|
  agent.user_agent = Mechanize::AGENT_ALIASES.keys.sample
end

@page = @agent.get "#{URL_BASE}/publicSearchColasBasicProcess.do"

@form = @page.form_with :name => 'searchCriteriaForm'

form_data = {
  'searchCriteria.dateCompletedFrom'     => '03/14/2017',  
  'searchCriteria.dateCompletedTo'       => '03/14/2017',
  'searchCriteria.productOrFancifulName' => '%',
  'searchCriteria.classTypeFrom'         => '901',
  'searchCriteria.classTypeTo'           => '956',
  'searchCriteria.originCode'            => '%'
}

@form['searchCriteria.dateCompletedFrom']     = form_data['searchCriteria.dateCompletedFrom']
@form['searchCriteria.dateCompletedTo']       = form_data['searchCriteria.dateCompletedTo']
@form['searchCriteria.productOrFancifulName'] = form_data['searchCriteria.productOrFancifulName']
@form['searchCriteria.classTypeFrom']         = form_data['searchCriteria.classTypeFrom']
@form['searchCriteria.classTypeTo']           = form_data['searchCriteria.classTypeTo']
@form['searchCriteria.originCode']            = form_data['searchCriteria.originCode']

@results_page = @form.submit

@file = @agent.get("#{URL_BASE}/publicSaveSearchResultsToFile.do?path=/publicSearchColasBasicProcess")
@file.save

30.upto(100) do |n|
  ColaTTB::Scraper.scrape_by_date(Date.today - n)
  sleep(rand(5))
end

file_lines = Dir["./tmp/*.csv"].map do |file|
  `wc -l "#{file}"`.strip.split(' ')[0].to_i
end

```
