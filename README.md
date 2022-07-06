# MetaU App Design Project - Trippy 

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)

## Overview
### Description
Trippy is a mobile iOS app that allows users to pin and save different types of locations around their city, generate personalized travel itineraries, and share their favorite sights with others. The goal is to become a one-stop shop for conceptualizing, planning, and carrying out local outings with friends. 

### App Evaluation
- **Category:** This app belongs to the Travel and Social categories.
- **Mobile:** Great in mobile form, as map features and real-time location updates are key for the app's features
- **Story:** Many of my friends and peers travel to new places often for school and internships, so this product would have a lot use for them.
- **Market:** The market for this app is extensive – while it might be most compelling for younger users with frequent outings, anyone with an interest in travel would have use for this app.
- **Habit:** Most users would only need the app a few times a month, but would likely be engaged in both consuming and creating.
- **Scope:** While a full app is beyond the scope of this program, it may be possible to implement basic features for one area (ie. downtown Seattle). 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can create an account and log in
* User can save and label locations
* User can search and view locations on a map
* User can organize locations into collections
* User can generate a basic route through locations
* User can view other users' saved locations
* User can view previously saved locations and collections

**Optional Nice-to-have Stories**

* More flexible itinerary planning
    * User can determine order of itinerary and make preferences for times of arrival
    * User can draw areas to avoid or go through throughout their itinerary
    * User can be given smart recommendations based on date of travel
* Social networking features
    * User can friend other users
    * User can view other user profiles
    * User can view recommended friends based on travel or location preferences
    * User can view other users by location
    * User can invite other users to go on trips
* Guides and user-generated content
    * User can view online travel guide information on local sights to see
    * User can view user-submitted travel guide information on local sights to see
    * User can submit reviews on locations they have been
    * User can participate in a forum for local sightseeers
* User can make reservations through the app (ie. via Yelp, OpenTable)

### 2. Screen Archetypes

* Login / Register Screen
   * User can create an account and log in
* Pin Map View
   * User can search and view locations on a map
* Pin Detail 
    * User can view basic information about a location
* Collection Detail
    * User can view basic information about a collection of locations
* Route Map View
    * User can generate a basic route through locations, ie. with Google Maps SDK
    * User can draw areas to avoid or go through throughout their itinerary
* Pin Creation
    * User can save locations
    * User can label locations 
    * User can organize locations into collections
* Home Stream
    * User can view previously saved locations
* Explore Stream
    * User can view other users' saved locations

### 3. Navigation (incomplete)

**Tab Navigation** (Tab to Screen)

* Home
* Travel
* Create
* Explore

**Flow Navigation** (Screen to Screen)

* Login
   * => Home
* Registration
   * => Home
* Home
    * => Home Stream
* Home Stream
    * => Pin Detail
    * => Collection Detail
* Explore
    * => Explore Stream
* Explore Stream
    * => Pin Detail
    * => Collection Detail
* Travel
    * => Pin Map View
* Pin Map View
    * => Pin Creation
* Pin Detail
    * => Route Map View
* Collection Detail
    * => Pin Detail
    * => Route Map View
* Create
    * => Pin Map View
* Pin Creation
    * => Pin Creation

### 4. Wireframes
![](https://i.imgur.com/SqnU0iO.jpg)
