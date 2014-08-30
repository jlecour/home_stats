HOME_STATS_MAPPING = {
  "settings" => {
    "number_of_replicas" => 1,
    "number_of_shards" => 1,
  },
  "mappings" => {
    "water" => {
      "properties" => {
        "date" => { "type" => "date", "format" => "YYYY-MM-dd" },
        "value" => { "type" => "float" },
      }
    },
    "electricity" => {
      "properties" => {
        "date" => { "type" => "date", "format" => "YYYY-MM-dd" },
        "kind" => { "type" => "string", "index" => "not_analyzed" },
        "value" => { "type" => "float" },
      }
    },
    "temperature" => {
      "properties" => {
        "date" => { "type" => "date" },
        "value" => { "type" => "float" },
      }
    },
    "humidity" => {
      "properties" => {
        "date" => { "type" => "date" },
        "value" => { "type" => "float" },
      }
    },
    "precipitation" => {
      "properties" => {
        "date" => { "type" => "date" },
        "value" => { "type" => "float" },
      }
    }
  }
}