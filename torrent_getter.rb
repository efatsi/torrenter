require "selenium-webdriver"
require 'uri'
require 'redis'

uri    = URI.parse(ENV["LETITSNOW_REDIS_URL"])
$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

def download_torrent(torrent)
  puts "starting driver"
  driver = Selenium::WebDriver.for :chrome

  base_url = "http://kickass.to/usearch/"
  target   = base_url + URI.encode(torrent)

  driver.navigate.to target

  puts "downloading #{torrent} .torrent file"
  driver.execute_script('$($(".imagnet")[0]).siblings().last()[0].click()')
  sleep(5) #give torrent time to download

  puts "shutting down driver"
  driver.quit
end

while true do
  puts "pinging Redis..."

  if torrent = $redis.lpop("torrents")
    download_torrent(torrent)
  end

  sleep(60)
  # check redis for new torrent torrent names, download them
end


# Test this out maybe?
# with puts and connect it for a day
#
# $redis.subscribe('torrents') do |on|
#   on.message do |channel, torrent|
#     download_torrent(torrent)
#   end
# end
