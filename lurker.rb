#!/usr/bin/env ruby

require 'thor'
require 'open-uri'
require 'json'

TOP_STORY_URL = 'https://hacker-news.firebaseio.com/v0/topstories.json'

class Lurker < Thor
  desc "collect", "Collects the top news and saves them to the database."
  def collect
    puts "Collect."
    open(TOP_STORY_URL, "rb") do |file|
      top_story_body = file.read
      p top_story_body
     end
  end
end

Lurker.start(ARGV)