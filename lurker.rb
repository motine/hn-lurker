#!/usr/bin/env ruby

require 'thor'
require 'open-uri'
require 'json'
require 'celluloid/current'

TOP_STORY_URL = 'https://hacker-news.firebaseio.com/v0/topstories.json'

class DetailDownloader
  include Celluloid

  def download_and_save(item_id)
    puts "downloading #{item_id}..."
    s = rand()
    puts s
    sleep s
    puts item_id
  end
end

class Lurker < Thor
  desc "collect", "Collects the top news and saves them to the database."
  def collect
    top_story_body = nil
    # open(TOP_STORY_URL, "rb") do |file|
    #   top_story_body = file.read
    # end # let's not worrie about errors yet
    top_story_body = "[ 11168750, 11167262, 11166988, 11166772, 11166886, 11172886, 11167178, 11167914, 11166510, 11166705, 11167692, 11166849, 11166740, 11166477, 11166599, 11166578, 11166479, 11166498, 11166802, 11169301]"
    top_story_item_ids = JSON.parse(top_story_body)
    top_story_item_ids *= 2

    downloader_pool = DetailDownloader.pool(size: 20)
    futures = [] # spawn the the downloaders
    top_story_item_ids.each do |item_id|
      futures << downloader_pool.future.download_and_save(item_id)
    end
    
    # wait for completion of all downloaders
    futures.each(&:value)
  end
end

Lurker.start(ARGV)