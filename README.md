![Swifty Logo](https://raw.githubusercontent.com/Flipkart/GenericTrackingFramework/jazzy/GenericTrackingFramework.png)

# GenericTrackingFramework
**Generic Tracking Framework** written in Swift is a event based Swift-Protocol oriented Tracking Framework which processes UI events in background and sends data to consumers: 

* Track % visibility of each view and its content  
* Track duration of on screen time  
* Create recommendations out of the accumulated data
* Enable ads monetisation from the data

####Why View Tracking is required?
- Capture User interaction and view activities for:
- Crunching numbers for views/taps
- Identifying preferred products/verticals/categories
- Classifying his shopping habits
- Monetize from Ads

####Why is it different : 
- Processes view events on ***background thread*** 
- dynamic (allows ***dynamic plug-in/plug-out*** of consumers as per different rules)

## How does it work
![Swifty Logo](https://raw.githubusercontent.com/Flipkart/GenericTrackingFramework/jazzy/GenericTrackingFramework_Steps.png)

## Usage
Checkout the Demo project "TrackingDemo"

## API Documentation

Documentation is under progress and can be accessed GenericTrackingFramework is [available here.](https://flipkart.github.io/GenericTrackingFramework)

## Installation

### CocoaPods

To integrate GenericTrackingFramework into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'GenericTrackingFramework'
```

Then, run the following command:

```bash
$ pod install
```

## Requirements

- iOS 8.0+
- Swift 3

