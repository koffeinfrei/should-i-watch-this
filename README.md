<h1 align="center">Should I Watch This?</h1>

<div align="center">

[![GitHub release](https://img.shields.io/github/v/release/koffeinfrei/should-i-watch-this.svg?style=flat-square)](https://github.com/koffeinfrei/should-i-watch-this/releases)
&nbsp;
[![Build Status](https://img.shields.io/github/workflow/status/koffeinfrei/should-i-watch-this/Crystal%20CI.svg?label=Crystal%20CI&style=flat-square)](https://github.com/koffeinfrei/should-i-watch-this/actions)
&nbsp;
![License](https://img.shields.io/github/license/koffeinfrei/should-i-watch-this.svg?style=flat-square)

</div>

> I watch a lot of movies. This is exactly what I was looking for.<br> -- myself

<br>

<div align="center">

This is a tool to ask the internet if it's worth watching a movie or show.

There are 3 versions to this:

[CLI](#1-cli)
&nbsp;·&nbsp;
[web application](#2-web-application-at-should-i-watch-thiscom)
&nbsp;·&nbsp;
[openfaas function](#3-openfaas-function)

</div>

<br>

### 1. CLI

![Demo](demo.gif)

### 2. Web application at should-i-watch-this.com

![website](screen.jpg)

### 3. OpenFaaS function

```bash
# basic example
curl -H 'X-Auth-Token: <your omdb token>' \
    https://faasd.koffeinfrei.org/function/should-i-watch-this \
    -d "the terminator"

# example with parameters
curl -H 'X-Auth-Token: <your omdb token>' \
    https://faasd.koffeinfrei.org/function/should-i-watch-this?show_links=true\&year=1984 \
    -d "the terminator"

# example with json response
curl -H 'X-Auth-Token: <your omdb token>' \
    -H "Accept: application/json" \
    https://faasd.koffeinfrei.org/function/should-i-watch-this?show_links=true\&year=1984 \
    -d "the terminator"
```

## About

It uses the [OMDb API](http://www.omdbapi.com) to get basic information about
the movie.

The ratings are fetched from the following sources:

- [IMDb](https://www.imdb.com)
- [Rotten Tomatoes](https://www.rottentomatoes.com)
- [Metacritic](https://www.metacritic.com)


## Usage

### CLI

 ```bash
 # search by title
 $ should-i-watch-this lookup "terminator 2"

 # search by imdb id
 $ should-i-watch-this lookup tt0103064
 ```

#### Install from snap

```bash
sudo snap install should-i-watch-this
```

#### Install from source

First you'll need to [install
Crystal](https://crystal-lang.org/reference/installation/).

 ```bash
 $ git clone git@github.com:koffeinfrei/should-i-watch-this.git
 $ cd should-i-watch-this/cli
 $ shards build --release
 $ cp bin/should-i-watch-this <some directory in your $PATH>
 ```

### Web application

1. Go to https://www.should-i-watch-this.com

2. Type the title or the IMDb id in the search box

3. Hit the search button.

### OpenFaaS function

1. Get an [OMDb API key](http://www.omdbapi.com/apikey.aspx) (one time)

2. Call the function

   There a some headers and query params to the function:

   - mandatory
     - header `X-Auth-Token`: the OMDb API key
   - optional
     - query param `show_links`: value "true" to include the source links
       in the response
     - query param `year`: the year of the movie

   ```bash
   # basic example
   curl -H 'X-Auth-Token: <your omdb token>' \
       https://faasd.koffeinfrei.org/function/should-i-watch-this \
       -d "the terminator"

   # example with parameters
   curl -H 'X-Auth-Token: <your omdb token>' \
       https://faasd.koffeinfrei.org/function/should-i-watch-this?show_links=true\&year=1984 \
       -d "the terminator"

   # example with json response
   curl -H 'X-Auth-Token: <your omdb token>' \
       -H "Accept: application/json" \
       https://faasd.koffeinfrei.org/function/should-i-watch-this?show_links=true\&year=1984 \
       -d "the terminator"
   ```

## Development

### CLI

```bash
$ cd cli
$ shards install

$ crystal run src/should-i-watch-this.cr -- lookup -l the terminator
```

### Web application

```bash
$ cd www
$ npm install
$ npm run dev
```

Navigate to [localhost:5000](http://localhost:5000).

### OpenFaaS function

#### Deployment

##### Preparation (one time)

```bash
$ cd cli
$ export OPENFAAS_URL=https://faasd.koffeinfrei.org
$ faas template store pull crystal-http --overwrite
```

##### Deploy

```bash
$ cd cli
$ faas-cli up --no-cache
```

## Contributing

1. Fork it (<https://github.com/koffeinfrei/should-i-watch-this/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Made with ☕️  by [Koffeinfrei](https://github.com/koffeinfrei)
