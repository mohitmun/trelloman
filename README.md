## Inspiration
I haven't use Trello much in past and just stared using it few days back. I was working on power-up 'Trelloman' and added few tasks related to it. Most of them were 'Complete it by tomorrow', 'Do this in next two hours'. setting due date/ due time helps and I'm too lazy to set deadline for each card so I checked if there is any power-up that can recognize/parse/set due date. there wasn't. so build it 

## What it does
When you create any card with date/time/duration in it, Deadline power-up will recognize it and set due date for you without any manual intervention. There are two modes of operation. If you enable auto setting of due date, it will update due date immidiately after card is created. it its disabled you can quickly add recodgnised due date to board. I works seemless on any platform Trello supports.

![Deadline](https://github.com/mohitmun/deadline-powerup-trello/raw/deadline_new/deadline.gif)

## Features
- Support all platforms (Web, Android and iOS)
- Option to enable and disable auto assigning due-date
- Parses duration


## How we built it, Challenges faced and Learning

### Research
After I got idea I started searching for open sourced solutions to recognize and parse time in natural language. First I found 'chronic' ruby gem which parses natural time to formatted time.  but it didn't solve problem of recognizing time in given sentence. After little bit of research I found [SUTime](https://nlp.stanford.edu/software/sutime.shtml) which perfectly fits given usecase.

### Trello platform
I wanted to build something which works on all platforms. Natural way to achive this was webhook so looked up Trello documentation and viola! Deadline listens to your board for new card and pass its content to NLP component of app

### Challenges with Heroku
SUTime is written in java and main app is written rails. I couldn't find ruby bindings for SUTime and had very time for writing on my own. I looked up to python bindings and it worked. so now i was runnning python bindings of SUTime in ruby. Inception. I was working perfectly on local but when I deployed to heroku new problem started arising. 
  - Slug size exceeded 500 mb 
  - Boot time of SUTime was > 30s so heroku request timeouts
Challenge was how can I make it run on freetier on heroku so users can quickly deploy and start using it.

### Seperate Service for NLP
To above mentioned problem, best solution is runnig seperate service. slug size went down but timeout issue persisted. Solution? Background Jobs. I used [rq](https://github.com/nvie/rq/) for python and moved SUTime initilization to backound process. It worked.

### Duration and Timezone
due date can be absolute or relative. one might say in relative like 'complete task in 2 days', 'meeting after 5 hours', or in absolute 'Call at 5pm'. Luckily SUTime provides type where it mentions whether its duration or time. One of the challenge was get user's timezone, accoringly convert time to unix timestamp and provide it Trello api

## Accomplishments that I'm proud of
Running both services on freetier Heroku. Damn!

## What's next for Deadline
- When it comes to NLP, there are endless possibilies. One more use case I can think of is auto labeling cards, auto assignment to team members. It can really change the way large team does project management on Trello 
- Prompt user to set due date via attachment section rather than comments. seems intrusive
- Deploy to heroku button

### Known bugs
- Webhooks still active after disabling extension (do disablePlugin event workaround)
- process again after Updating card 