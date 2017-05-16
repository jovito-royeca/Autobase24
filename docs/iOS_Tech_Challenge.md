![AutoScout24 logo](https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/AutoScout24_logo.svg/200px-AutoScout24_logo.svg.png)
# Welcome to the iOS technical challenge of AutoScout24!

Please read through this readme ***carefully*** before you do anything!

**Before** you start to code, check if you have any questions (answered during normal office hours). After the answers, please send back your **planned goal** and **deadline** (a date, max 1 week).

## Requirements

- The solution needs to run on *at least* one device (can be a simulator as well) with at least one iOS version.
- Provide the solution by sharing a link to a Git repository. We're interested in how you approach the problem, so please use small commits with clear commit messages. 
- Provide a readme markdown document about your finished solution and a description about its running environment. Any additional documentation is welcomed!
- Make sure that the solution compiles and runs!



## The App

The challenge is to create an app which has a basic feature set that you can then extend with additional features.

Create a simple car app where the user can browse a list of cars and he can add to and remove from a favorites list.

### Basic feature set

**UI:**

Setup 2 screens with a tab bar. The first screen is the list of cars. Second screen is a favorite list. 

*List of cars:* Show the following car properties: Price, Milage, Make, FuelType. Introduce a Pull-to-refresh mechanism for this list with an activity indicator. Each car on the list has a favorite [Switch](https://developer.apple.com/ios/human-interface-guidelines/ui-controls/switches/). When it's switched on, the car is added to the favorites list. When it's switched off, the car is removed from the favorites list.

*List of favorites:* It shows all the cars which are favorited. Each item on this list has a delete button. When the delete button is tapped, that car is removed from the favorites list. This should be reflected on the cars list.

**Networking:**

Use the following network datasource to get the list of cars: http://sumamo.de/iOS-TechChallange/api/index/make=all.json

**Data handling:**

Add a persistence layer for the app, which should be utilized by the favorites list. When the app terminates for any reason and is restarted, the favorites list needs to maintain a consistent state.

**Multithreading:**

Implement all the features so that the user interface is responsive and smooth at all times.

###Additional feature set

Now it's up to you to decide how to improve the product. Choose up to three features from the twelve below. Pick what you like. Express your strengths! 

* (**UI**) Make sure that all of the assets (labels, images) are displayed nicely (no cuts, same size). The app should reflect an easy to use and consistent interface.

* (**UI**) Introduce floating bar on the bottom of the favorite list. It contains an input textfield and a "Calculate" button next to each other. The user can input a number here. When the user presses the "Calculate" button, the bar becomes green if the entered amount is equal or bigger than the sum of prices of the cars on the list. Otherwise it becomes red.

* (**Networking**) Make sure that each and every response of a request ignores locally or remotely cached data.

* (**Data handling**) Utilize the make parameter of the datasource of the car list screen. It can have 4 values: all, bmw, audi, mercedes-benz. The app should pick cyclically one out of this 4 with every refresh
(http://sumamo.de/iOS-TechChallange/api/index/make=[all | bmw | audi | mercedes-benz].json). Make sure, that the favorite [switches](https://developer.apple.com/ios/human-interface-guidelines/ui-controls/switches/). reflect the proper state for each car after the list is refreshed.

* (**Data handling**) Introduce a sorting feature. This feature postprocesses the received list and sorts the vehicles by their FirstRegistration property. When it's tapped, it reverses the order of the list. Display the FirstRegistration date of each vehicle in the list.

* (**Data handling**) Introduce a validation feature. This feature postprocesses the recieved list and grays out all invalid vehicles. A vehicle is invalid when the AccidentFree property is false. Prevent users from adding an invalid car to the favorites list.

* (**Multithreading**) Show the first image of each vehicle. Get the image in an asynchronous way.

* (**Multithreading**) Show the Address property of each vehicle, but with a 2 seconds delay. Use the sleep() function (to simulate a heavy computing). The app should be still responsive all the time.

* (**Architecture**) Introduce a tracking utility, which tracks all the user interaction (all of the touches). When the app goes to the background, it prints all the user interaction events on the console with meaningful names.

* (**Architecture**) Add a badge to the tab bar favorites list item. The badge should represent the number of vehicles that have been added to the favorites list since it was last viewed. When the user switches to the favorites list, the badge should disappear.

* (**Testing**) Introduce Unit tests

* (**Testing**) Introduce UI tests

---
#Have fun,  
AutoScout24 iOS Team

![AutoScout24 logo](https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/AutoScout24_logo.svg/200px-AutoScout24_logo.svg.png)
