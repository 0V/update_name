require "yaml"
require "twitter"
require "pp"

def update_profile_name(name,tweet,client)
  begin
    client.update_profile(:name => name)
    update_text = "@#{tweet.user.screen_name} #{name}にさせられました"
    client.update(update_text,:in_reply_to_status_id => tweet.id)
    puts update_text
  rescue Twitter::Error::Forbidden => e
#	update_text = "@#{tweet.user.screen_name} #{e.message}"
    update_text = "@#{tweet.user.screen_name} ごめんなさい… update_name できませんでした。こういう時は寝ましょう (¦3[＿＿]"
    client.update(update_text,:in_reply_to_status_id => tweet.id)
    puts update_text
  end
end


keys = YAML.load_file("./settings.yml")

client= Twitter::REST::Client.new do |config|
  config.consumer_key = keys["consumer_key"]
  config.consumer_secret = keys["consumer_secret"]
  config.access_token = keys["access_token"]
  config.access_token_secret = keys["access_token_secret"]
end

stream= Twitter::Streaming::Client.new do |config|
  config.consumer_key = keys["consumer_key"]
  config.consumer_secret = keys["consumer_secret"]
  config.access_token = keys["access_token"]
  config.access_token_secret = keys["access_token_secret"]
end

print "[INNER INFO] Getting user infomation -> "
profile = client.user
screen_name = profile.screen_name
puts "Completed"

match_str = /^(?!RT).*@#{screen_name}\supdate_name\s(.+?)$/iu
match_str2 = /^(?!RT)(.+)[（\(]\s*@#{screen_name}\s*[）\)].*$/iu
match_shinchoku = /^(?!RT).*(進捗|しんちょく)(ダメ|だめ)です.*$/iu

startup_message = "[INFO] update_name が起動したよ！ヾ(＞ヮ＜*) #{Time.now}"
puts startup_message
client.update(startup_message)

stream.user do |obj|
  case obj
  when Twitter::Tweet
    case obj.text
    when match_str
      update_profile_name($1,obj,client)
    when match_str2
      update_profile_name($1,obj,client)
    when match_shinchoku
      update_text = "@#{obj.user.screen_name} \n"
      update_text << <<-"EOS"
♪ヽ〇ﾉ♪ 進捗なーぅ！
　　 ）へ  
　  く 
EOS
      client.update(update_text,:in_reply_to_status_id => obj.id)
      puts update_text
    end
  when Twitter::Streaming::Event
  when Twitter::Streaming::StallWarning
    puts "StallWarning"
  end
end 