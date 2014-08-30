# Home Stats

I regularly check on my power and water consumption (every few days/weeks).
It gives me insight about the way I consume (costly) resources.

After a few years of plotting them in a spreadsheet, I've made the leap to [Elasticsearch](http://elasticsearch.org/overview/elasticsearch/) (for storage and query) and [Kibana](http://elasticsearch.org/overview/kibana/) (for visualization).

I've also added weather data from [Wunderground](http://wunderground.com).

Here is the result : ![HomeStats](http://jeremy.lecour.fr/tmp/home_stats.png)

# Usage

You need a **Ruby** executable (version 2.x should work, I use 2.1.2), a few gems (including [Bundler](http://bundler.io)).

````shell
gem install bundler
bundle install
````

The **.env** gem is used to pass environment variables to the script, like the Wunderground API key of the Elasticsearch host you want to use.
There is `.env.example` that you need to rename to `.env` and adapt.

## Download weather data

You have to provide date to the script :

`FROM=2014-08-27 TO=2014-08-28 bundle exec ruby download_wunderground.rb`

or 

`DATE=2014-08-28 bundle exec ruby download_wunderground.rb`

## Import home data

My own data is in the `data/home_data.csv` file (numbers are the derivative value since the previous one).

`bundle exec ruby home_stats_importer.rb`

You can rebuild the entire index structure like this :

`REBUILD=1 bundle exec ruby home_stats_importer.rb`

It will destroy the index and recreate it using the Elasticsearch mapping (configured in `home_stats_mapping.rb`).

## Visualization

You need to install Kibana and load the `home_stats.json` schema.