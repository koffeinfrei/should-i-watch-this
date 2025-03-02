# frozen_string_literal: true

lock "~> 3.19"

set :application, "should-i-watch-this"
set :repo_url, "git@github.com:koffeinfrei/should-i-watch-this.git"
set :repo_tree, "www"
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", ".bundle", "system"

set :keep_releases, 5
