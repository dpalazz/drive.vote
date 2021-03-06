
## Drive the Vote Simulator
The simulator can be used to create demos and validation scripts. It creates some drivers,
voters, and rides in a ride zone and then plays a series of events in a timeline.

Simulations are defined in YAML files in the folder data/simulations

The admin interface has a Simulations tab where you can select a simulation and start it.

### YAML Syntax
YAML has a pretty simple syntax for defining structured data. The top of simulation definition
file looks like this for example:

```
slug: "hqdemo"
name: "Brooklyn HQ Demo"
```

This defines two fields called ``slug`` and ``name`` and gives them each a value that is a string in 
quotation marks. Fields like this can be strings or numbers.

When you want a field to hold multiple items, each with their own fields, YAML relies on
indentation. You name the field with a colon, then on the next line you indent and use a ``-`` to
start the first sub item.

So for example, the definition file can have ``rides`` defined. It looks like this:

```
rides:
  -
    pickup_offset: "10 minutes"
    from_address: "624 Doby Avenue"
    ... more fields ...
  -
    pickup_offset: "30 minutes"
    from_address: "1415 Parker Street"
    ...more fields...
```

It is also possible to combine fields and values onto one line using curly braces:

```
rides:
  - { pickup_offset: "10 minutes", from_address: "624 Doby Avenue", ...}
```

YAML is finicky - the indentation has to be right. You can use http://www.yamllint.com/ to validate
your YAML file.

### Simulation Definition File
Here are the required fields for a simulation definition file:

```
slug: "an identifier with no spaces"
name: "human friendly name"
ride_zone:
  name: 'some name'
  slug: 'nospaces'
  zip: '32805'
  phone_number: '+15555550001'
  latitude: 28.533609
  longitude: -81.406011
  time_zone: 'America/New_York'
user_identifier: "a small string like (sim) or (demo) to identify users created by the sim"
```

The ride zone zip must be in one of the accepted swing states and the lat/long should be
accurate for the map to look correct.

The definition file can also define drivers, voters, and pre-existing rides.

#### Drivers
The only information needed about a driver is the series of events they will generate. Each
event has a timestamp, in seconds, from the start of the simulation. The simulator will perform
the event at approximately that time. 

The driver events are:
- move: requires ``lat`` and ``lng`` and updates the driver's location with those absolute values
- move_by: requires ``lat`` and ``lng`` and shifts the driver's location with those relative values
- accept_nearest_ride: accepts the nearest waiting ride
- pickup_ride: marks the active ride as picked up
- complete_ride: marks the active ride as complete

Here is a single driver that will just fire one event, to move to a specific location 30 
seconds into the simulation:

```
drivers:
  -
    events:
      - {at: 30, type: move, lat: 28.533, lng: -81.406 }
```

Events can also be specified with a relative time. Note the "+NN" is in seconds and must be a 
string in quotation marks.
```
drivers:
  -
    events:
      - {at: 60, type: move, lat: 28.533, lng: -81.406 }
      - {at: "+30", type: move_by, lat: 0.002, lng: 0}
      - {at: "+60", type: move_by, lat: 0, lng: .003 }
```

To script a large number of drivers doing exactly the same series of events, you can define
a group of drivers like this:

```
drivers:
  - count: 200
    time_jitter: 300
    loc_jitter: 0.060
    events:
      - {at: 4, type: move, lat: 28.541, lng: -81.412 }
      - {at: "+15", repeat_count: 30, repeat_time: 15, type: move_by, lat: 0.001, lng: 0.001 }
```

The first event **must** be of type move and specify `at`, `lat`, and `lng`

The `count` says how many drivers to create in total that will perform these events.

The `time_jitter` defines the splay in seconds for when the drivers will do their first event. So
in the example above, 200 drives will be created that randomly appear on the map starting
at 4 seconds extending to 4+300 seconds.

A random percentage of the  `loc_jitter` is added to both the `lat` and `lng` of the first move event
for each driver in the group. So drivers created will appear in the example above from
28.541 to 28.601 latitude.

#### Voters
As with drivers, the only information needed for each voter is their event stream.

The voter events are:
- sms: requires ``body`` and simulates the voter sending that text message to the system

There are some special values you can use for the sms event:
- body = ``<USERNAME>`` will substitute the sim-generated name for the voter into the body
- time_offset: "N minutes" instead of body will set the body to N minutes from now (useful to answer the 
"when do you want to be picked up question")

Here is a complete sample bot exchange:
```
voters:
  -
    events:
      - {at: 10, type: sms, body: "hi can i get a ride"}
      - {at: "+3", type: sms, body: "1"}
      - {at: "+3", type: sms, body: "<USERNAME>"}
      - {at: "+3", type: sms, body: "700 ohio avenue orlando"}
      - {at: "+3", type: sms, body: "yes"}
      - {at: "+3", type: sms, body: "3099 Orange Center Blvd, Orlando"}
      - {at: "+3", type: sms, body: "yes"}
      - {at: "+3", type: sms, time_offset: "15 minutes"}
      - {at: "+3", type: sms, body: "yes"}
      - {at: "+3", type: sms, body: "none"}
      - {at: "+3", type: sms, body: "none"}
```

#### Rides
Pre-existing rides can be created as scheduled at the start of the simulation.

Here are the fields that should be filled out for a scheduled ride:
```
rides:
  -
    pickup_offset: "10 minutes"
    from_address: "624 Doby Avenue"
    from_city: "orlando"
    from_latitude: 28.534
    from_longitude: -81.407
    additional_passengers: 0
    special_requests: none
```
