# Autobase24

An iOS app that displays and saves your favorite cars. This is the Tech Challenge part of my application for Senior iOS Engineer (m/f) at [Scout24](http://www.scout24.com).

## Features
### Basic Features
**UI**
* List of cars: shows the following car properties: Price, Milage, Make, FuelType. Introduce a Pull-to-refresh mechanism for this list with an activity indicator. Each car on the list has a favorite [Switch](https://developer.apple.com/ios/human-interface-guidelines/ui-controls/switches/). When it's switched on, the car is added to the favorites list. When it's switched off, the car is removed from the favorites list.
* List of favorites: shows all the cars which are favorited. Each item on this list has a delete button. When the delete button is tapped, that car is removed from the favorites list. This should be reflected on the cars list.

**Networking**
* Data is fetched from: http://sumamo.de/iOS-TechChallange/api/index/make=all.json . Networking code is handled by the [Networking](https://github.com/3lvis/Networking) library.

**Data handling**
* Persistence layer is handled by Core Data, which is utilized by the favorites list. When the app terminates for any reason and is restarted, the favorites list maintains a consistent state. Handling Core Data is made easier by using [SyncDB](https://github.com/SyncDB/Sync).

**Multithreading**
* User interface is responsive and smooth at all times.

### Additional Features
**UI**
* All of the assets (labels, images) are displayed nicely (no cuts, same size). The app reflects an easy to use and consistent interface.
* 2

**Networking**
* 3

**Data Handling**
* Utilizes the make parameter of the datasource of the car list screen. It has 4 values: All, BMW, Audi, Mercedes-Benz. The app should pick cyclically one out of this 4 with every refresh
(http://sumamo.de/iOS-TechChallange/api/index/make=all|bmw|audi|mercedes-benz.json). Reflects the proper state for each car after the list is refreshed.
* Sorting: postprocesses the received list and sorts the vehicles by their FirstRegistration property. When it's tapped, it reverses the order of the list. Displays the FirstRegistration date of each vehicle in the list.
* Validation: postprocesses the recieved list and grays out all invalid vehicles. A vehicle is invalid when the AccidentFree property is false. Prevent users from adding an invalid car to the favorites list.

**Multithreading**
* Shows the first image of each vehicle. The image is downloaded in an asynchronous way.
* Shows the Address property of each vehicle, but with a 2 seconds delay. Uses the sleep() function (to simulate a heavy computing). The app is still responsive all the time.

**Architecture**
* 9
* 10

**Testing**
* 11

**UI Testing**
* 12

## Cloning
Clone the GitHub repository and open the project workspace `Autobase24.xcworkspace`.

```
$ git clone https://github.com/jovito-royeca/Autobase24.git
$ cd Autobase24
$ open Autobase24.xcworkspace
```

## Author
[Jovito Royeca](mailto:jovit.royeca@gmail.com)
