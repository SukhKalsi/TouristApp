# TouristApp

This app showcases Persistence and Core Data in iOS.
Using the Flickr API, the user has an entire map of the world at their disposal to 'pin' a location. Once a pin is set, this is stored (persisted) on the device using iOS Core Data framework.
When a user taps on a pin for the first time, the app will call the Flickr API to retrieve a set of images. These images are also stored within the device. The user has the ability to retrieve a new collection at any time by tapping the 'New Collection'.

## Setup

No setup is required other than having the latest version of XCode. The build is executed using XCode 7 - the latest being 7.3.1 using Swift 2.2.
You will most likey need to update the Flickr API key located within `Virtual Tourist/Flickr/FlickrConstants.swift`. Please go to Flickr live API interface here https://www.flickr.com/services/api/explore/flickr.photos.search

## Screenshots

![App main view](/virtual_tourist_demo/main.png?raw=true "App main view")
![Selecting pin loader](/virtual_tourist_demo/loading_pin.png?raw=true "Selecting pin loader")
![Lazy loading images](/virtual_tourist_demo/loading_images.png?raw=true "Lazy loading images")
![Loaded view](/virtual_tourist_demo/loaded.png?raw=true "Loaded view")
