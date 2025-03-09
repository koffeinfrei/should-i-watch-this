# frozen_string_literal: true

server "should-i-watch-this-production", user: "deploy", roles: %w[web app db]

set :deploy_to, "/home/deploy/#{fetch(:application)}"
