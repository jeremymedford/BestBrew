# BestBrew
Tilt Exercise

### Features

1. Location-aware mapview displays coffee shops near user's location when location services are enabled.
2. A search bar provides the ability to search for a location. Enabled whether or not location services are enable or not.
3. Each pin can be tapped to provide name and address for venue.
4. Annotation view can be tapped to display a details page with a list of tips provided by public Foursquare data.

### Design Decisions

1. I thought a lot about how and when to approach updating the user's location. I didn't think monitoring their location constantly was important enough to have CLLocationManager always updating, even while using the app. So, when a suitable location is returned, I stop updating locations. The user's location will update again when the view appears. Seemed like a worthwhile compromise for this app.

2. I didn't go too crazy with displaying error messages, but tried to handle general errors when making requests to the API. Some just fail silently, such as fetching Tips and a photo in the details view.

3. I could have gone on to do a few more things such as make another fetch to get complete venue information, but decided to keep it simple for now. The addition of the specific venue fetch would not be too much trouble, but ultimately deciding which information was relevant might require some more testing with actual users.

### Additional Notes

- No third party libraries used, but some code originating from Treehouse Swift Networking course provided a foundation that I built off
of to create the networking stack.
