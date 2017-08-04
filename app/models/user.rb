class User  < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  store_accessor :json_store, :trello_token, :me_info, :trello_id, :auto_update_card, :updatable_cards, :timezone_offset, :disabled, :gmail_auth, :refresh_token
  HOST = ENV['HOST']
  REDIRECT_URI = "#{ENV['HOST']}/oauth2callback"
  WEBHOOK_URL = "#{HOST}/incoming_trello"
  GMAIL_AUTH_URL = "https://accounts.google.com/o/oauth2/auth?scope=email+https://www.googleapis.com/auth/gmail.modify&response_type=code&access_type=offline&prompt=consent&client_id=#{ENV['GMAIL_CLIENT_ID']}&redirect_uri=#{REDIRECT_URI}"
  after_initialize :init

  def init
    self.updatable_cards = {} if self.updatable_cards.blank?
    self.timezone_offset = 0 if self.timezone_offset.blank?
  end

  def get_lex_intent(text)
    a = Aws::Lex::Client.new
    return a.post_text(input_text: text, bot_name: "Trelloman", bot_alias: "$LATEST", user_id: trello_id).intent_name
  end

  def send_email(params)
    draft_message = "To: "+params["to"]+"\r\n" +    "From: <"+email+">\r\n" +     "Subject: "+params["sub"]+"\r\n" +    "Content-Type: text/html; charset=UTF-8\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\n" +    params["body"]+"\r\n"
    print("=====")
    print(draft_message)
    print("=====")
    encodedMail = Base64.encode64(draft_message).gsub("+", "-").gsub("//", "_")
    url = "https://www.googleapis.com/gmail/v1/users/me/messages/send"
    res = User.curl("'#{url}' --data '#{{raw: encodedMail}.to_json}' -H 'Content-Type: application/json' -H 'Authorization: Bearer #{gmail_auth.access_token}'")
    return res
  end

  def get_access_token(code)
    # 4/DECnHiBAl9tIxWzgy5wEHvKO5zNO-0uEjgjMxE8hXvg#
    res = User.curl "https://www.googleapis.com/oauth2/v4/token -d 'code=#{code}' -d 'client_id=#{ENV['GMAIL_CLIENT_ID']}' -d 'client_secret=#{ENV['GMAIL_CLIENT_SECRET']}' -d 'redirect_uri=#{REDIRECT_URI}' -d 'grant_type=authorization_code'"
    self.gmail_auth = res
    self.refresh_token = res.refresh_token
    self.save
  end

  def refresh_access_token
    res = User.curl "https://www.googleapis.com/oauth2/v4/token -d 'refresh_token=#{refresh_token}' -d 'client_id=#{ENV['GMAIL_CLIENT_ID']}' -d 'client_secret=#{ENV['GMAIL_CLIENT_SECRET']}' -d 'grant_type=refresh_token'"
    self.gmail_auth = res
    self.save
  end
  
  def set_trello_webhook
    board_ids = me_info.idBoards
    board_ids.each do |board_id|
      curl("'https://api.trello.com/1/webhooks' -d 'idModel=#{board_id}' -d 'description=My Webhook' -d 'callbackURL=#{WEBHOOK_URL}'", spawn_p: true)
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
    User.curl "-G 'https://sutime.herokuapp.com' --data-urlencode 'q=#{s}' --data-urlencode 'callback_data=#{data.to_json}' --data-urlencode 'callback_url=#{HOST}/incoming_sutime'", spawn_p: true
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

  def self.create_user_from_trello_token(token, tz: nil)
    # trello_client = get_trello_client(token)
    u = User.find_by_trello_token(token) rescue nil
    if u.blank?
      u = User.new(trello_token: token)
      me_info = u.me
      existing_user = User.find_by(email: me_info.email)
      if existing_user
        u = existing_user
        u.trello_token = token
      end
      u.auto_update_card = true
      u.email = me_info.email
      u.password = Random.rand(10**10)
      u.me_info = me_info
      if tz
        u.timezone_offset = tz
      end
      u.trello_id = me_info.id
      u.save
      # u.set_trello_webhook
    end
    return u
  end

  def curl(s, spawn_p: false)
    User.curl("#{s}  -d 'token=#{self.trello_token}' -d 'key=#{ENV['TRELLO_APP_KEY']}'", spawn_p: spawn_p)
  end

  def self.curl(s, spawn_p: false)
    cmd = "curl #{s}"
    log cmd
    if spawn_p
      f = IO.popen(cmd)
      log("spawn_ping ....")
      res = "{}"
    else
      res = `#{cmd}`
    end
    log res
    return res.parse_json
  end

  def me
    curl "https://api.trello.com/1/members/me -G"
  end

  def update_card(card_id, due: nil)
    d = ""
    if due.is_a?(Fixnum)
      d = d + "-d due=#{due*1000}"
    else
      log("due not fixnum fucker")
    end
    curl("'https://api.trello.com/1/cards/#{card_id}' #{d} -X PUT")
  end

  def self.handle_webhook(data)
    action = data.action
    action_type = action.type
    u = User.find_by_trello_id(action.idMemberCreator) rescue nil
    #todo when card is updated again check for time
    if action_type == "createCard"
      text = action.data.card.name
      card_id = action.data.card.id
      # time = parse_sentence_for_time(text, card_id, action.idMemberCreator)
      intent = u.get_lex_intent(text)
      if intent == "TrellomanSendMailGmail"
        u.add_attachent_to_card(card_id, "Send Gmail", HOST + "/powerup/send_email")
      end

    elsif action_type == "disablePlugin"
      #todo handle disable enble
    end
  end

  def disable_user
    # delete_all_webhook
    # self.delete
    update_attributes(disabled: true)
  end

  def update_card_with_due_date(card_id, due)
    if auto_update_card
      update_card(card_id, due: due)
    else
      #todo add comment
      #click 'add due date to blah blah' to
      # add_comment_to_card(card_id, "Due date found as #{get_zoned_time_from_ts(due)}. Click 'Deadline' to set it")
      self.updatable_cards[card_id] = due
      self.save
    end
  end

  def add_comment_to_card(card_id, text)
    curl("'https://api.trello.com/1/cards/#{card_id}/actions/comments' -d 'text=#{text}'")
  end

  def add_attachent_to_card(card_id, name, url)
    curl("'https://api.trello.com/1/cards/#{card_id}/attachments' -d 'url=#{url}' -d 'name=#{name}'", spawn_p: true)
  end

  def card(card_id)
    curl("'https://api.trello.com/1/cards/#{card_id}' -G")
  end

  def get_zoned_time_from_ts(ts)
    mama = mama(ts)
    return Time.at(mama).to_s(:short)
  end

  def mama(i)
    res = i + (timezone_offset.to_i*60)
    return res
  end

  def authorized?
    me.is_a?(Hash)
  end

  def self.incoming_sutime(data)
    # {"callback_data": "{\"card_id\":\"5983549030925428df7e2c66\",\"user_id\":\"5719cbc5f47f4d7ff006e072\"}", "sutime_result": [{"start": 20, "end": 31, "text": "end of week", "type": "DURATION", "value": "P1W"}]}
    log(data)
    callback_data = data.callback_data.parse_json
    text = data.sutime_result.last.text rescue nil
    value = data.sutime_result.last.value rescue nil
    type = data.sutime_result.last.type rescue nil
    u = User.find_by_trello_id(callback_data.user_id)
    if value.blank?
      time = nil
    else
      # time = Chronic.parse(value)
      if type == "DURATION"
        duration_in_sec = ISO8601Parser.new(value).parse!
        time = Time.now.to_i + duration_in_sec
      else
        time = DateTime.parse(value)
        time = u.mama(time.to_i)
      end
    end
    if time
      u.update_card_with_due_date(callback_data.card_id, time)
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
