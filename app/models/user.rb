class User  < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  store_accessor :json_store, :trello_token, :me_info, :trello_id, :auto_update_card, :updatable_cards
  HOST = ENV['HOST']
  WEBHOOK_URL = "#{HOST}/incoming_trello"
  after_initialize :init

  def init
    self.updatable_cards = {} if self.updatable_cards.blank?
  end
  
  def set_trello_webhook
    board_ids = me_info.idBoards
    board_ids.each do |board_id|
      curl("'https://api.trello.com/1/webhooks' -d 'idModel=#{board_id}' -d 'description=My Webhook' -d 'callbackURL=#{WEBHOOK_URL}'")
    end
  end

  def self.find_by_trello_id(tid)
    return User.where("(json_store ->> 'trello_id') = ?", tid).last
  end

  def self.find_by_trello_token(token)
    return User.where("(json_store ->> 'trello_token') = ?", token).last
  end

  def self.get_manifest
    File.read("manifest.json").parse_json
  end

  def self.download_jars
    `wget https://jar-download.com/zipTmp/5982a74223079/jar_files.zip`
    `mkdir jars`
    `unzip jar_files.zip -d jars`
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

    # RubyPython.start
  def self.parse_sentence_for_time_from_sutime(s, card_id, user_id)
    # sys = RubyPython.import("sys")
    # sys.path.append('.')
    # sutime = RubyPython.import("example")
    # res = `python example.py '#{s}'`.split("=====")[1].parse_json
    # RubyPython.stop
    #
    data = {card_id: card_id, user_id: user_id}
    User.curl "-G 'https://sutime.herokuapp.com' --data-urlencode 'q=#{s}' --data-urlencode 'callback_data=#{data.to_json}' --data-urlencode 'callback_url=#{HOST}/incoming_sutime'"
    # return res
  end

  def self.parse_sentence_for_time(s, card_id, trello_id)
    from_sutime = parse_sentence_for_time_from_sutime(s, card_id, trello_id)
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
    u = User.find_by_trello_token(token) rescue nil
    if u.blank?
      u = User.new(trello_token: token)
      me_info = u.me
      u.email = me_info.email
      u.password = Random.rand(10**10)
      u.me_info = me_info
      u.trello_id = me_info.id
      u.save
      u.set_trello_webhook
    end
    return u
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
    curl("'https://api.trello.com/1/cards/#{card_id}' #{d} -X PUT")
  end

  def self.handle_webhook(data)
    action = data.action
    action_type = action.type
    if action_type == "createCard"
      text = action.data.card.name
      card_id = action.data.card.id
      time = parse_sentence_for_time(text, card_id, action.idMemberCreator)
    end
  end

  def update_card_with_due_date(card_id, due)
    if auto_update_card
      update_card(card_id, due: due)
    else
      self.updatable_cards[card_id] = due
      self.save
    end
  end

  def self.incoming_sutime(data)
    # {"callback_data": "{\"card_id\":\"5983549030925428df7e2c66\",\"user_id\":\"5719cbc5f47f4d7ff006e072\"}", "sutime_result": [{"start": 20, "end": 31, "text": "end of week", "type": "DURATION", "value": "P1W"}]}
    log(data)
    callback_data = data.callback_data.parse_json
    text = data.sutime_result.last.text rescue nil
    if text.blank?
      time = nil
    else
      time = Chronic.parse(text)
    end
    if time
      u = User.find_by_trello_id(callback_data.user_id)
      u.update_card_with_due_date(callback_data.card_id, time.to_i*1000)
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
