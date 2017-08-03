class User  < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  store_accessor :json_store, :trello_token, :me_info, :trello_id
  HOST = "https://b3802de4.ngrok.io"
  WEBHOOK_URL = "#{HOST}/incoming_trello"
  
  def set_trello_webhook
    board_ids = me_info.idBoards
    board_ids.each do |board_id|
      curl("'https://api.trello.com/1/webhooks' -d 'idModel=#{board_id}' -d 'description=My Webhook' -d 'callbackURL=#{WEBHOOK_URL}'")
    end
  end

  def self.find_by_trello_id(tid)
    return User.where("(json_store ->> 'trello_id') = ?", tid).last
  end

  def delete_all_webhook
    webhooks = get_webhooks
    webhooks.each do |webhook|
      delete_webhook(webhook.id)
    end
  end

  def delete_webhook(webhook_id)
    curl(" -X DELETE 'https://api.trello.com/1/webhooks/#{webhook_id}'")
  end

    RubyPython.start
  def self.parse_sentence_for_time_from_sutime(s)
    sys = RubyPython.import("sys")
    sys.path.append('.')
    sutime = RubyPython.import("example")
    res = sutime.parse(s).rubify.parse_json
    # RubyPython.stop
    return res
  end

  def self.parse_sentence_for_time(s)
    
    from_sutime = parse_sentence_for_time_from_sutime(s)
    text = from_sutime.last.text rescue nil
    log(from_sutime)
    if text.blank?
      res = 0
    else
      res = Chronic.parse(text)
    end
    return res
  end

  def get_webhooks
    curl("https://api.trello.com/1/tokens/#{trello_token}/webhooks -G")
  end

  def self.get_trello_client(token)
    return Trello::Client.new(
      developer_public_key: ENV['TRELLO_APP_KEY'],
      member_token: token
    )
  end

  def self.create_user_from_trello_token(token)
    # trello_client = get_trello_client(token)
    u = User.new(trello_token: token)
    me_info = u.me
    u.email = me_info.email
    u.password = Random.rand(10**10)
    u.me_info = me_info
    u.trello_id = me_info.id
    u.save
  end

  def curl(s)
    User.curl("#{s}  -d 'token=#{self.trello_token}' -d 'key=#{ENV['TRELLO_APP_KEY']}'")
  end

  def self.curl(s)
    cmd = "curl #{s}"
    log cmd
    res = `#{cmd}`
    log res
    return res.parse_json
  end

  def me
    curl "https://api.trello.com/1/members/me -G"
  end

  def update_card(card_id, due: nil)
    d = ""
    if due
      d = d + "-d due=#{due}"
    end
    curl("'https://api.trello.com/1/cards/#{card_id}' #{d}")
  end

  def self.handle_webhook(data)
    action = data.action
    action_type = action.type
    if action_type == "createCard"
      text = action.data.card.name
      card_id = action.data.card.id
      time = parse_sentence_for_time(text)
      log(time)
      if time.is_a?(Time)
        log("time detected tile:#{time}")
        u 
        update_card(card_id, due: time.to_i)
      end
    end
  end

  def log(s)
    User.log(s)
  end

  def self.log(s)
    puts "="*50  
    puts s
    puts "="*50  
  end

end
