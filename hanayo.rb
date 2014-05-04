# -*- coding: utf-8 -*-
require "open-uri"
require 'yaml'
require "bundler"
Bundler.require
require "RMagick"


#設定ファイルロード
begin
	settings = YAML::load(open("./hanayo.conf"))
rescue
	puts "[#{Time.now}]: [ERROR] config file load failed."
end
puts "[#{Time.now}]: config file loaded."
# Twiter関連モジュール準備
TweetStream.configure do |config|
	config.consumer_key			= settings["consumer_key"]
	config.consumer_secret		= settings["consumer_secret"]
	config.oauth_token			= settings["oauth_token"]
	config.oauth_token_secret	= settings["oauth_token_secret"]
	config.auth_method			= :oauth
end

@twitter = Twitter::REST::Client.new do |config|
	config.consumer_key			= settings["consumer_key"]
	config.consumer_secret		= settings["consumer_secret"]
	config.access_token			= settings["oauth_token"]
	config.access_token_secret	= settings["oauth_token_secret"]
end

def dot(status)
	begin
		url = status.user.profile_image_url.to_s.gsub("_normal","")
		filename = File.basename(url)
		# リプライしてきたユーザーのアイコン画像を保存
		open(filename, 'wb') do |output|
			open(url) do |data|
				output.write(data.read)
			end
		end
	
		# なんかいい感じにする
		puts "b"
		image = Magick::ImageList.new(filename)
		puts "a"
		hana = Magick::ImageList.new("./hanayo.png")
		p image
		image = image.resize(397.7 / image.rows).rotate(7.604)
		image = hana.composite(image, 350, 182, Magick::OverCompositeOp).composite(hana, 0, 0, Magick::OverCompositeOp)
		image.write("tmp.jpg")
		p image
		# 送りつける どうぞ！
		@twitter.update_with_media("@#{status.user.screen_name} どうぞ！", File.open("tmp.jpg"), :in_reply_to_status_id => status.id)
	rescue => exc
		p exc
	end
end

my_sn = @twitter.user.screen_name

client = TweetStream::Client.new
client.userstream do |status|
	if /^@#{my_sn}\s+クソコラ.*$/i =~ status.text
		print "dot - "
		puts status.user.screen_name
		dot(status)
	end
end
