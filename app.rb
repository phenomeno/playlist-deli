require 'bundler/setup'
Bundler.require(:default)
require 'dotenv/load'

require 'rspotify/oauth'

require_relative 'config/init'
require_relative 'tasks/init'
