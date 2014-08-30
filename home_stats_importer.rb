require "pathname"
require "csv"

require "pry"
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'elasticsearch'
require 'ruby-progressbar'
require 'dotenv'
Dotenv.load

require_relative "./home_stats_mapping"

class HomeStatsImporter

  attr_reader :home_file, :wunderground_files, :elasticsearch, :index

  def initialize
    @home_file = Pathname('data/home_data.csv')
    @wunderground_files = Pathname.glob('data/wunderground/marseille_*.json')

    @index = "home_stats"

    @elasticsearch = Elasticsearch::Client.new({
      host: ENV.fetch('ELASTICSEARCH_HOST'),
      log: false,
      trace: false,
    })
  end

  def import_all
    import_home_stats
    import_weather_stats
  end

  def import_home_stats
    check_index(index)

    stats = parse_file(home_file)

    elasticsearch.bulk({
      body: stats.map { |stat|
        { index: {
          _index: index,
          _type: stat["type"],
          data: stat["data"]
        } }
      }
    })
  end

  def import_weather_stats
    $stdout.puts "Importing data"
    progress_bar = ProgressBar.create(:title => "fichiers", :format => '%a |%b%i| %c/%C %t', :total => wunderground_files.count)

    wunderground_files.reverse.each_entry do |wunderground_file|
      stats = parse_wunderground_file(wunderground_file)

      elasticsearch.bulk({
        body: stats.map { |stat|
          { index: {
            _index: index,
            _type: stat["type"],
            data: stat["data"]
          } }
        }
      })

      progress_bar.increment
    end
  end

  private

  def check_index(index_name)
    if ENV["REBUILD"] == "1" && index_exists?(index_name)
      delete_index(index_name)
      ENV["REBUILD"] = nil
    end
    create_index(index_name) unless index_exists?(index_name)
  end

  def index_exists?(index_name)
    elasticsearch.indices.exists({ index: index_name })
  end

  def delete_index(index_name)
    elasticsearch.indices.delete({ index: index_name })
  end

  def create_index(index_name)
    elasticsearch.indices.create({
      index: index_name,
      body: HOME_STATS_MAPPING
    })
  end

  def parse_file(file)
    stats = []

    CSV.foreach(file, :headers => true, :col_sep => ';') do |row|
      stats << {
        "type" => "water",
        "data" => {
          "date" => row[0],
          "value" => row[1]
        }
      }
      stats << {
        "type" => "electricity",
        "data" => {
          "date" => row[0],
          "kind" => "hc",
          "value" => row[2]
        }
      }
      stats << {
        "type" => "electricity",
        "data" => {
          "date" => row[0],
          "kind" => "hp",
          "value" => row[3]
        }
      }
    end

    stats
  end

  def parse_wunderground_file(file)
    stats = []

    json = JSON.load(file.read)
    json.fetch("history").fetch("dailysummary").each do |summary|
      begin
        date = format_from_wunderground_date(summary.fetch("date"))

        stats << {
          "type" => "temperature",
          "data" => {
            "date" => date.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "value" => summary.fetch("meantempm").to_f
          }
        }
        stats << {
          "type" => "humidity",
          "data" => {
            "date" => date.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "value" => summary.fetch("humidity").to_f
          }
        }
        stats << {
          "type" => "precipitation",
          "data" => {
            "date" => date.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "value" => summary.fetch("precipm").to_f
          }
        }
      rescue
        binding.pry
      end
    end

    stats
  end

  def format_from_wunderground_date(date)
    DateTime.civil(
      date.fetch("year").to_i,
      date.fetch("mon").to_i,
      date.fetch("mday").to_i,
      date.fetch("hour").to_i,
      date.fetch("min").to_i,
      0,
      0
    ).to_time.utc
  end

end

HomeStatsImporter.new.import_all