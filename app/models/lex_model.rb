class LexModel
  def self.setup_bot
    print("Setting up lex")
    print("Creating slot types")
    self.create_slot_types()
    print("Creating Intents")
    self.create_intents()
    print("Creating bot")
    self.create_bot()
  end

  @@client = Aws::LexModelBuildingService::Client.new
  def self.client
    return @@client
  end
  # def delete_bot(self):
  #   response = self.client.delete_bot(name="Dwight")
  #   return response
  # def delete_intent(self):
  #   self.delete_bot();
  #   for intent in data.get_intents():    
  #     response = self.client.delete_intent(name=intent['name'])
  #   return True
  def self.create_bot
    params = LexData.get_bot
    params["checksum"] = self.get_bot(params["name"])["checksum"] rescue nil
    response = @@client.put_bot(params)
    return response
  end

  def self.create_intents
    res = []
    LexData.get_intents.each do |intent|
      intent["checksum"] = self.get_intent(intent["name"])["checksum"] rescue nil
      response = @@client.put_intent(intent)
      res.append(response)
    end
    return res
  end

  def self.create_slot_types
    res = []
    LexData.get_slot_types.each do |slot_type|
      slot_type["checksum"] = self.get_slot_type(slot_type["name"])["checksum"] rescue nil
      response = @@client.put_slot_type(slot_type)
      res.append(response)
    end
    return res
  end
  # def get_bots(self):
  #   return self.client.get_bots()
  # # def set_up_bot():
  # #   pass

  def self.get_bot(name)
    return @@client.get_bot(name: name,version_or_alias: "$LATEST")
  end

  def self.get_intent(name)
    return @@client.get_intent(name: name, version: "$LATEST")
  end

  def self.get_slot_type(name)
    return @@client.get_slot_type(name: name, version: "$LATEST")
  end
end