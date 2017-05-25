# Cheesy Movies

> The hipster’s movie app!

## Features

- Shows recently-released movies that are not too popular.
- Search for unpopular movies by genre or release year.
- Movies are shown in the *cheesiness order* (i.e. lower-voted movies goes higher in the list).
- Play movie trailer (if available).
- Share the movie’s web page to social media, e-mail, or other apps.
- Supports the iPhone, iPad, and iPad Pro (also iPod touch too).

<img width="512" alt="Cheesy Movies Screenshot" src="https://cloud.githubusercontent.com/assets/176081/20036247/3f665436-a43e-11e6-965e-29764362bda5.png">

Get it [on the App Store](https://itunes.apple.com/app/cheesy-movies/id1109874238?mt=8&at=10lvzo&ct=cheesy_movies-github-readme).

## Requirements

 - iOS 9.3
 - Xcode 8.1
 - Internet connection

### Not mandatory but good to have
 - [Paw 2](https://itunes.apple.com/app/paw-http-rest-client/id584653203?mt=12&at=10lvzo&ct=chzmv)
 - [Affinity Designer](https://itunes.apple.com/app/affinity-designer/id824171161?mt=12&at=10lvzo&ct=chzmv)

## Getting started

1. Open workspace `BadFlix.xcworkspace` (**not** the project file since this relies on [Cocoapods](https://cocoapods.org)).
2. Press the Play button in Xcode to build and run for the Simulator.
3. Enjoy those cheesy movies!

### Folder Structure

- `BadFlix` – Main app sources.
- `doc/screenshots` – Screenshots taken from the iOS Simulator.
- `assets` – original files for the icon and button glyphs.
- `Pods` – Cocoapods-managed sources.

## Terms of Use

Copyright(C) 2016 [Sasmito Adibowo](http://cutecoder.org). Licensed under GPL v3 – see `LICENSE.md` for details.

If you are in a job interview and the company request you to do a *new unpaid project* as part of the hiring process, **feel free to plagiarize this project** — remove my name from the source files and submit them "as is" *without further modification*. For any other uses, the GPL license applies. Please send me a postcard if you get hired because of my work.

Why am I encouraging plagiarism? Mainly because I feel that companies that requests "free work" as part of an interview process are engaging in unethical behavior. They show a **lack of respect of your time** and devalue programmers in general. This practice has reduced the value of artists, musicians, designers, and now the same is coming to software engineers. I feel that it's about time we push back.

## Original Assignment Description


>Here we've giving you the opportunity to showcase your talents, both creative and technical, and have some fun! Everyone loves movies, and sometimes we even love BAD movies, "Snakes on a Plane" anyone? So, using the openly available APIs (OMDB, Rotten Tomatoes, etc), create an app that:
>
>- Allows the user to search by genre (action, romantic, etc) and year released
>- Based on the search criteria will return a sortable list of the 10 WORST movies: sortable by rating.
>- The user can then select a movie and the app will reveal more info about this cinematic travesty: plot, actors, etc
>
>Our objectives with this test are 4-fold: Evaluate your technical ability, problem solving approach, ability to deliver a user-friendly system, and how you work with version control systems. Rules of the evaluation: (serious stuff)
>
>- you have 48 hours to complete the test
>- Please create and upload this into a GitHub repository. Please use atomic commits so we can see the blocks of function created.
>- This app doesn't have to be perfect. There's not enough time to crush every bug. What more important it the main "happy path"
>
>This is an opportunity to show off; let's see you skills in using caches, animations, new features, you name it. Bonus points for embedding a trailer!

