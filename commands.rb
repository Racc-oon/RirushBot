require 'sucker_punch'
require './define'
require './beatmap_download'
require 'json'

class HelpCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
        :chat_id => payload['chat']['id'],
        :text => $help,
        :reply_to_message_id => payload['message_id']
    } unless mode
    if mode
      result = [
          {
            :type => 'article',
            :id => rand(10000000).to_s,
            :title => '#HELPME',
            :message_text => $help
          }
      ]
      res = $fd.post "/bot#{ENV['TOKEN']}/answerInlineQuery", {
          :inline_query_id => payload['id'],
          :results => result.to_json,
          :switch_pm_text => 'Go to PM'
      }
      puts res.body
    end
  end
end

class PingCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
        :chat_id => payload['chat']['id'],
        :text => 'Got ping. PONG!',
        :reply_to_message_id => payload['message_id']
    } unless mode
    if mode
      result = [
          {
              :type => 'article',
              :id => rand(10000000).to_s,
              :title => '#PINGME',
              :message_text => 'Pinged using inline mode. PONG!'
          }
      ]
      res = $fd.post "/bot#{ENV['TOKEN']}/answerInlineQuery", {
          :inline_query_id => payload['id'],
          :results => result.to_json,
          :switch_pm_text => 'Go to PM'
      }
      puts res.body
    end
  end
end

class OsuCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    BeatmapDownload.perform_async(/http(?:|s):\/\/osu.ppy.sh\/s\/(?<id>\d+)/i.match(args)['id'], payload['chat']['id'], payload['message_id']) if /http(?:|s):\/\/osu.ppy.sh\/s\/(?<id>\d+)/i.match(args)
  end
end

class UsersDumpCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    if payload['from']['id'] == 125836701
      users = $redis.get('users')
      $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
          :chat_id => payload['chat']['id'],
          :text => users,
          :reply_to_message_id => payload['message_id']
      } unless mode
      if mode
        result = [
            {
                :type => 'article',
                :id => rand(10000000).to_s,
                :title => '#DUMPME',
                :message_text => users
            }
        ]
        res = $fd.post "/bot#{ENV['TOKEN']}/answerInlineQuery", {
            :inline_query_id => payload['id'],
            :results => result.to_json,
            :switch_pm_text => 'Go to PM'
        }
        puts res.body
      end
    end
  end
end

class ChatsDumpCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    if payload['from']['id'] == 125836701
      chats = $redis.get('chats')
      $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
          :chat_id => payload['chat']['id'],
          :text => chats,
          :reply_to_message_id => payload['message_id']
      } unless mode
      if mode
        result = [
            {
                :type => 'article',
                :id => rand(10000000).to_s,
                :title => '#DUMPME',
                :message_text => chats
            }
        ]
        res = $fd.post "/bot#{ENV['TOKEN']}/answerInlineQuery", {
            :inline_query_id => payload['id'],
            :results => result.to_json,
            :switch_pm_text => 'Go to PM'
        }
        puts res.body
      end
    end
  end
end

class GetChatCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    if payload['from']['id'] == 125836701
      @chat = 'Error'
      @chat = $fd.post "/bot#{ENV['TOKEN']}/getChat", {
          :chat_id => args
      } if /\d+/i.match(args)
      $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
          :chat_id => payload['chat']['id'],
          :text => @chat.body,
          :reply_to_message_id => payload['message_id']
      } unless mode
      if mode
        result = [
            {
                :type => 'article',
                :id => rand(10000000).to_s,
                :title => '#GETME',
                :message_text => @chat.body
            }
        ]
        res = $fd.post "/bot#{ENV['TOKEN']}/answerInlineQuery", {
            :inline_query_id => payload['id'],
            :results => result.to_json,
            :switch_pm_text => 'Go to PM'
        }
        puts res.body
      end
    end
  end
end

class BroadcastCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    if payload['from']['id'] == 125836701
      chats = JSON.parse $redis.get('chats')
      for chat in chats
        $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
            :chat_id => chat,
            :text => args,
            :parse_mode => 'Markdown',
            :disable_notification => true
        } if args != ''
      end
      $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
          :chat_id => payload['chat']['id'],
          :text => 'Broadcasted!',
          :reply_to_message_id => payload['message_id']
      }
    end
  end
end

class DiceCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    unless mode
    $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
        :chat_id => payload['chat']['id'],
        :text => '*Dice* says: _NOPE_',
        :parse_mode => 'Markdown',
        :reply_to_message_id => payload['message_id']
    } unless (/(?<range>(|-)\d+)$/i =~ args) != nil
    range = Integer(/(?<range>(|-)\d+)$/i.match(args)['range'])
    if range > 1
      result = rand(range + 1)
      $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
          :chat_id => payload['chat']['id'],
          :text => "*Dice* says: _#{result}_",
          :parse_mode => 'Markdown',
          :reply_to_message_id => payload['message_id']
      }
    else
      $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
          :chat_id => payload['chat']['id'],
          :text => '*Dice* says: _fuck you_',
          :parse_mode => 'Markdown',
          :reply_to_message_id => payload['message_id']
      }
    end
    end
  end

end

class EchoCommand
  include SuckerPunch::Job

  def perform(args, payload, mode = false)
    $fd.post "/bot#{ENV['TOKEN']}/sendMessage", {
        :chat_id => payload['chat']['id'],
        :text => "*Bot* says: _#{args}_",
        :parse_mode => 'Markdown',
        :reply_to_message_id => payload['message_id']
    } if (args != '') & (!mode)
    if mode
      if mode
        result = [
            {
                :type => 'article',
                :id => rand(10000000).to_s,
                :title => '#ECHOME',
                :message_text => "*Bot* says trough inline: _#{args}_",
                :parse_mode => 'Markdown'
            }
        ]
        res = $fd.post "/bot#{ENV['TOKEN']}/answerInlineQuery", {
            :inline_query_id => payload['id'],
            :results => result.to_json,
            :switch_pm_text => 'Go to PM'
        }
        puts res.body
      end
    end
  end
end