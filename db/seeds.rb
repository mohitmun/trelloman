# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(email: "User1@user.com", password: "User1234")
topic1 = Topic.create(name: "Topic 1")
topic1.discussions.create(created_by: 1, name: "Discussion 1 about topic 1")
topic1.discussions.create(created_by: 1, name: "Discussion 2 about topic 1")
topic1.discussions.create(created_by: 1, name: "Discussion 3 about topic 1")

topic2 = Topic.create(name: "Topic 2")
topic2.discussions.create(created_by: 1, name: "Discussion 1 about topic 2")
topic2.discussions.create(created_by: 1, name: "Discussion 2 about topic 2")
topic2.discussions.create(created_by: 1, name: "Discussion 3 about topic 2")

topic3 = Topic.create(name: "Topic 3")
topic3.discussions.create(created_by: 1, name: "Discussion 1 about topic 1")
topic3.discussions.create(created_by: 1, name: "Discussion 2 about topic 2")
topic3.discussions.create(created_by: 1, name: "Discussion 3 about topic 3")