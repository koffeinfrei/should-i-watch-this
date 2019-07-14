[![GitHub release](https://img.shields.io/github/release/koffeinfrei/should-i-watch-this.svg)](https://github.com/koffeinfrei/should-i-watch-this/releases)
[![Build Status](https://travis-ci.org/koffeinfrei/should-i-watch-this.svg?branch=master)](https://travis-ci.org/koffeinfrei/should-i-watch-this)
![License](https://img.shields.io/github/license/koffeinfrei/should-i-watch-this.svg)

# Should I watch this?

Simple CLI to ask the internet if it's worth watching this movie.

![Demo](demo.gif)

It uses the [OMDb API](http://www.omdbapi.com) to get basic information about
the movie.

The ratings are fetched from the following sources:

- [IMDb](https://www.imdb.com)
- [Rotten Tomatoes](https://www.rottentomatoes.com)
- [Metacritic](https://www.metacritic.com)

## Installation

### From source

First you'll need to [install Crystal](https://crystal-lang.org/reference/installation/).

```bash
$ git clone git@github.com:koffeinfrei/should-i-watch-this.git
$ cd should-i-watch-this
$ shards build --release
```

## Usage

```bash
$ bin/should-i-watch-this lookup "terminator 2"
```

## Development

```bash
$ git clone git@github.com:koffeinfrei/should-i-watch-this.git
$ shards install
```

## Contributing

1. Fork it (<https://github.com/koffeinfrei/should-i-watch-this/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Made with ☕️  by [Koffeinfrei](https://github.com/koffeinfrei)
