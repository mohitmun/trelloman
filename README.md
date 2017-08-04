## Inspiration
Initially I though of converting incoming gmail to Trello card depending on predefined rules (if mail received from particular address/person , if email contains few keywords). After little research, This solution already existed. IFTTT, Zapier already had recipe for it. Then It struck to me, what if we do it other way round.

This expands to many possibility. If you are able to classify intent behind card (like sending mail, creating PR on Github, research on any subject, booking Uber if any meeting or schedule etc etc etc) all this can be automated as most services has opened up APIs to third party through Oauth. Here classifying intent becomes important.

There are many tools to build conversational chatbots, tools like api.ai, wit.ai or AWS Lex, They identify intent behind users message and make it easier to act on it. What if we can use those tools to classify intent behind users Trello card and enhancing there workflow?

This idea is experimental. Right now it just understand 'send email' intent. it uses AWS Lex to classify intent (Lex is same engine which powers Alexa) and it uses Gmail API to send emails. As we add more services, it will be more effective and scope of automation widens

## What it does
Say you create card which has intent of sending mail, For Example: 'Send email to Mohit regarding issue', 'Follow up with aman tomorrow', 'mail assignments to professor' It recognize intent and adds attachment section where it give you form where you can quickly send mail to respected person. You will have to give access to your Gmail Account through Oauth to Trelloman
It open sourced so any one can spin up their own server ant start using it

## How we built it, Challenges faced and Learning

### Trello platform
I used trello web-hooks for receiving card info and client.js for building UI elements

### Intent Classification
using aws ruby client, Created Lex bot and all models were driven through data.yml

### Gmail API
Gmail API gives access to users data through Oauth2. Using that I send email through Trello platform

## What's next for Deadline
- Add more services like Github, Jira, Drive etc
- For current Gmail integration, identifying sender, body and subject in users card will be next step
