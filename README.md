# MachiKoro

Machi Koro is a game (published by Pandasaurus) based around rolling dice, earning money and purchasing cards with that money. It's fairly simple, which makes it a good coding project for a newbie Ruby programmer like myself.

This gem is intended to fully model the game. It is up to you to create a front end for it (or a view & controller if we're talking MVC, which is generally A Good Thing). However I will create a command line interface that will show off all the functionality, and let you play a game entirely via an interactive console.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'machi_koro'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install machi_koro

## Usage

There will eventually be 3 objects to play with.
Game - for if you want to play a game of Machi Koro
Databank - for browsing the database. Can be called directly - but Game will also call it.
Stats - in a later version, you will be able to look back at stats from older games.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/reedstonefood/machi_koro.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

