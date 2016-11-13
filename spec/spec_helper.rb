Bundler.setup
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "machi_koro"
# I can't figure out how to import these automatically :/
require_relative "../lib/machi_koro/db_access.rb"
require_relative "../lib/machi_koro/databank.rb"