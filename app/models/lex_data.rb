class LexData
  @@data = HashWithIndifferentAccess.new(YAML.load_file("data.yml"))
  def self.get_bot
    intents = []
    get_intents.each do |i|
      intents << {
        'intent_name': i["name"],
        'intent_version': '$LATEST'
      }
    end
    result = @@data["bot"]
    result["intents"] = intents
    return result
  end

  def self.get_intents
    # with open("data.yml", 'r') as stream:
    items = @@data["intents"]
    items.each do |item|
      item["fulfillment_activity"] = {
        "type": "return_intent"
      }
    end
    return items
  end

  def self.get_slot_types
    return @@data["slot_types"]
  end
end