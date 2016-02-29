#!/usr/bin/env ruby

require 'thor'
require 'open-uri'
require 'json'
require 'celluloid/current'
require 'couchrest'
require 'webrick'

TOP_STORY_URL = 'https://hacker-news.firebaseio.com/v0/topstories.json'
ITEM_URL_PATTERN = 'https://hacker-news.firebaseio.com/v0/item/%i.json'
KEYS_TO_COPY_ONCE = [:by, :time, :title, :type, :url] # the keys which shall be copied over from the hn item when creating a new data base entry
KEYS_TO_COPY_REPEAT = [:score, :descendants] # the keys which shall be copied over each time collect is run
DOWNLOADER_POOL_SIZE = 35 # how many downloads shall be running at the same time

DB = CouchRest.new.database!('lurker')

class DetailDownloader
  include Celluloid

  # returns the hackernews item as a hash.
  # e.g. => {"by":"author","descendants":2,"id":12312313,"kids":[77777,88888],"score":1500,"time":1456319550,"title":"Super title","type":"story","url":"http://example.com"}
  def download(hn_id)
    url = ITEM_URL_PATTERN % [hn_id]
    open(url) do |file|
      return JSON.parse(file.read)
    end # let's not worrie about errors yet
  end

  # idea:
  # after downloading the item we try to load the item from the database (using the id).
  # if found, weupdate it with the new data.
  # if there is no such document yet, we create a new one with some initial data.
  # then we try again (start from loading the item from the db).
  # caution:
  # doing this "check", "change", "retry" is dangerous, because the underlying data may change between "check" and "change".
  # here the assumption is that each thread (`DetailDownloader`) works on distinct data.
  def save(hn_id, hn_item, timestamp)
    doc = DB.get(hn_id.to_s)
    # we have a pre-existing entry, so we update it
    moment_data = hn_item.select { |k,v| KEYS_TO_COPY_REPEAT.include?(k.to_sym) }
    doc['moments'][timestamp] = moment_data
    doc.save
  rescue RestClient::ResourceNotFound => e
    # we haven't created a document for this id yet, so let's do it
    new_db_item = hn_item.select { |k,v| KEYS_TO_COPY_ONCE.include?(k.to_sym) } # copy keys for new item
    new_db_item['_id'] = hn_id.to_s
    new_db_item['moments'] = {}
    DB.save_doc(new_db_item)
    retry
  end
  
  def download_and_save(job_number, hn_id, timestamp)
    puts "Processing number #{job_number}"
    hn_item = download(hn_id)
    save(hn_id, hn_item, timestamp)
  end
end

class Lurker < Thor
  desc "collect", "Collects the top news and saves them to the database."
  def collect
    top_story_body = nil
    open(TOP_STORY_URL) do |file|
      top_story_body = file.read
    end # let's not worry about errors yet
    top_story_item_ids = JSON.parse(top_story_body)

    timestamp = Time.new.to_i # have one timestamp for new entries
    downloader_pool = DetailDownloader.pool(size: DOWNLOADER_POOL_SIZE)
    futures = top_story_item_ids.collect.with_index do |item_id, i| # spawn the the downloaders
      downloader_pool.future.download_and_save(i, item_id, timestamp)
    end
    
    futures.each(&:value) # wait for completion of all downloaders
  end
  
  desc "server", "start a webserver at 8080"
  def server
    server = WEBrick::HTTPServer.new(:Port => 8080, :DocumentRoot => File.expand_path('../www', __FILE__))
    trap('INT') { server.shutdown }
    server.start
  end
end

Lurker.start(ARGV)