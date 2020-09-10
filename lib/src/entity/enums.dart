

enum LocalReference { Origin, Destination }

enum TripStatus {
  Open,
  AwaitingDriver,
  DriverNotified,
  DriverOnTheWay,
  Started,
  Finished,
  Canceled
}

enum ActionReport { Edit, Delete }

enum StepDriverHome {
  Start, /*first stage of the process*/
  LookingForTravel, /*looking for driver*/
  TravelFound, /*notifies the driver with a question if he wants to accept*/
  TravelAccepted, /*driver accepted trip, driver goes to the passenger*/
  StartTravel, /*driver accepted trip, driver goes to the passenger*/
  EndTrip /*End Trip*/
}

enum StepPassengerHome {
  Start, /*first stage of the process*/
  SelectOriginAndDestination, /*menu with search for items*/
  ConfirmValue, /*trip confirmation menu*/
  LookingForADriver, /*looking for driver*/
  LookingForTravel, /*looking for driver*/
  TravelFound, /*notifies the driver with a question if he wants to accept*/
  DriverAccepted, /*driver accepted trip, driver goes to the passenger*/
  TripInProgress, /*Trip in Progress*/
  EndTrip /*End Trip*/
}

enum CarType {
  Pop,
  Top
}

enum LocaleType {
  Home,
  Work
}

enum PersonType {
  Passenger,
  Driver
}