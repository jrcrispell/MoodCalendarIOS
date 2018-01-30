# iOS MOOD CALENDAR README #

### Explanation ###

* This is the iOS version of my final project for the Mobile Development degree at Full Sail. Mood Calendar is an app concept I came up, inspired by a Cognitive Behavioral Therapy technique for people with depression. You simply record what you do throughout the day, and how it affects your mood (with a 1-10 score).
* Not only does this give insight into how your habits affect your mood, but it's also a sort of work-out for your prefrontal cortex - the part of your brain that controls executive functions such as decision making, planning, and delay of gratification. By becoming more mindful you begin to consciously choose to spend your time in healthier ways, as opposed to just reactively binge watching Netflix because you feel like crap, and end up feeling worse because you feel like your day has been wasted.

### How do I get set up? ###

* I uploaded all of the podfiles to the repo (this was a class requirement), so simply cloning the repo and opening the workspace should be all you need to get started.
* Sample user: test@test.com, password: test123
* User for testing charts: charts@test.com, password: test123

### Features ###

* By default users are reminded every hour (at 5 after) to log an activity if one hasn't been recorded for the previous hour. This notification has several extra options if using force-touch, one of which is the Quicklog - a textfield that allows the user to a log an activity directly from the notification, without having to open the app.
* Click-drag resizing. Doing a long-press on the activity on the main calendar screen brings up resizing handles for quickly changing the duration of an activity without having to open the edit activity screen.
* Charts. This is a last minute feature and it still needs more work. It may crash if there are no data points available depending on the iOS version. This was added because I needed more features and I used a third party library. I'll most likely either remove it entirely or make a new one from scratch.
* Firebase is used for storage and user authentication.
