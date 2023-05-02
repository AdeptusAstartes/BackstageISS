# ISS Tracker Demo

## Purpose
This demo project is intended to demonstrate my iOS coding style and architecture preferences.

## Building/Installation
This sample app has no third party dependencies so running it is as simple as cloning the repo and opening the project in Xcode 14.0 or greater.

### Run in Simulator
To run the app in the simulator simply compile to simulator.  You will need to simulate a location in the simulator for the app to run correctly.  With the simulator open simply select `Features > Location > Custom Location` in the menu bar and enter a lat/lon and then re-run the app.

### Run on Device
To run on device you will need to change the bundle id to match a bundle id that you have access to and for which you can create a valid provisioning profile.  Once that is done set the profiile, etc. in Xcode and compile to device.

## App Architecture
### General Approach/Comments
The approach I took here was to not cut corners and code this the way I would code any app.  So proper encapsulation, use of protocols, protocol implementations in extensions, etc.

Additionally, I added a few bells and whistles in an effort to make this somewhat visually appealing and interesting.  The user's current location as well as the current location of the ISS are displayed using `MapKit`.  Coordinates are converted to cities/state (or province)/country with all info displayed in a status area at the bottom of the screen. 

Basically what I'd like you to take away from this is to notice a certain level of polish and attention to detail even on a coding example such as this.

### MVC
The app is very much standard MVC.  I am not a fan of MMVM because in my opinion it creates quite a lot of overhead and inflexibility when building out view heirarchies.

### Nibs
The app does not use story boards because story boards are a huge mess and are only viable if you're making a toy app.  My preference is to use individual nibs with `UIViewController`s (and sometimes `UIView` nibs also) because I like to take advantage of autolayout and being able to lay things out visually.  So in my opinion this is the optimal way to harness the power of nibs without being limited by story boards.

### Managers
I like to break down the handling of discrete pieces of functionality into "manager" classes that encapsulate as much of the business logic as possible of said functionality.  These managers are often singletons that can be called from anywhere in the app (even concurrently) in a completely threadsafe manner.  No need for view controllers, etc. to manage instances of the managers for no reason.  The managers present in this code base can be found in the `Managers` folder.

