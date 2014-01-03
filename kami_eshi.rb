# -*- coding: utf-8 -*-
require 'rubygems'
require "RMagick"
require "open-uri"
require "tweetstream"
require "twitter"

CONSUMER_KEY = ""
CONSUMER_SECRET = ""
OAUTH_TOKEN = ""
OAUTH_SECRET = ""

Twitter.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = OAUTH_TOKEN
  config.oauth_token_secret = OAUTH_SECRET
end
 
TweetStream.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = OAUTH_TOKEN
  config.oauth_token_secret = OAUTH_SECRET
  config.auth_method  = :oauth
end

def dot(status)
  url=status.profile_image_url.gsub("_normal","")
  filename=File.basename(url)
  
  # リプライしてきたユーザーのアイコン画像を保存
  open(filename, 'wb') do |output|
    open(url) do |data|
      output.write(data.read)
    end
  end
  
  # なんかいい感じにする
  image = Magick::ImageList.new(filename)
  image = image.sample(0.1)
  image = image.sample(10)
  image.write("tmp.jpg")
  
  # 送りつける どうぞ！
  Twitter.update_with_media("@#{status.user.screen_name} どうぞ！", File.open("tmp.jpg"), :in_reply_to_status_id => status.id)
end

my_sn = Twitter.user.screen_name

client = TweetStream::Client.new
client.userstream do |status|
  if /^@#{my_sn}\s+ドット絵.*$/i =~ status.text
    print "dot - "
    puts status.user.screen_name
    dot(status)
  end
end
