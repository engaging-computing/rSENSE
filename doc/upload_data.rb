#!/usr/bin/env ruby

URL = "http://rsense-dev.cs.uml.edu/api/v1/projects/488/jsonDataUpload"

req = {
  "email" => 'tyler.puleo22@gmail.com',
  "password" => '414991@Westland',
  "title" => "Boathouse App Tyler #{$$}",
  "data" => {
    '2219'=> [25,54,54,54,84,874,74,94,654,54,54,54],
    '2220'=> [25],
    '2221'=> [25],
    '2222'=> [25],
    '2223'=> [25],
    '2224'=> [25],
    '2225'=> [25]
  }
}

require 'httparty'
require 'json'



resp = HTTParty.post(
  URL,
  body: req.to_json,
  headers: {'Content-Type' => 'application/json'},
)

puts resp.inspect
