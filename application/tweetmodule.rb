#! /usr/bin ruby
#Connect to the 'results' mqtt topic on the mqtt hostname, read the json messages and tweet them
#Twitter credentials must be provided as environment variables

require "mqtt"
require "twitter"
load "result_message.rb"

#twitter config
@client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['twitter_consumer_key']
  config.consumer_secret     = ENV['twitter_consumer_secret']
  config.access_token        = ENV['twitter_access_token']
  config.access_token_secret = ENV['twitter_access_token_secret']
end

#tweet the result message
def tweet(result_message)
  tweet_string = result_message.message
  tweet_image = result_message.corresponding_image
  puts tweet_string
  @client.update_with_media(tweet_string,tweet_image)
end

#connect to the mqtt 'results topic' parse the result json messages and tweet them
MQTT::Client.connect('mqtt') do |c|
  puts "Connected to mqtt"
  c.get('results') do |topic,json_message|
    begin
      puts "#{topic}: #{json_message}"
      result_message = ResultMessage.new(json_message)
      tweet result_message
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
