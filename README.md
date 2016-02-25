# HackerNews Lurker

This project is mainly for myself, because I wanted to try out a few things together ([thor](http://whatisthor.com/), [couchDB](http://couchdb.apache.org/) and [celluloid](https://github.com/celluloid/celluloid/)).

## Idea

<!-- # For API see: https://github.com/HackerNews/API -->

## Get started

```bash
vagrant up # I have vbguest installed
vagrant ssh

cd /vagrant
./lurker.rb help
```

## Development

<!-- TODO notes about celloid -->
<!-- Threading is a good idea here. With a pool size of 35 the collection takes about 10 seconds. With no threading (sequential execution of each request), we take around 5 minutes. -->
<!-- # see http://www.rubydoc.info/github/couchrest/couchrest -->

Here some useful commands for accessing the database (run within vagrant box):

```bash
curl -sX GET http://127.0.0.1:5984/lurker | jq .
curl -sX GET http://127.0.0.1:5984/lurker/11169215 | jq . # get a specific item
curl -sX DELETE http://127.0.0.1:5984/lurker # remove/reset everything
curl -sX DELETE http://127.0.0.1:5984/lurker/11166417?rev=1-5b265a000f46be055057f84bfd1f6e3e # remove an individual item
```

### Data model

The data for 

```txt
{
  "_id": "...",         # the same as the hackernews item id
  "_rev": "...",
  "by": "author",       # copied from the hn item (once)
  "time": 1456361083,   # copied from the hn item (once)
  "title": "...",       # copied from the hn item (once)
  "type": "story",      # copied from the hn item (once)
  "url": "...",         # copied from the hn item (once)
  "moments": {          # time series data; there is a new entry for each call of collect
    "1234567890": {     # the key is the time stamp when the data was read (time of calling collect)
      "descendants": 6, # copied from the hn item
      "score": 14       # copied from the hn item
    },
    "1234567891": {
      "descendants": 6,
      "score": 20
    }
  }
}
```