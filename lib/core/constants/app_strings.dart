class AppStrings {
  AppStrings._();

  static const String appName = 'SmartQ Estates';
  static const String welcomeTitle = 'WELCOME HOME';
  static const String tagline = 'Your estate, in one place.';
  static const String welcomeDescription =
      'Manage visitors, services, maintenance, and payments seamlessly from one place.';
  static const String getStarted = 'GET STARTED';
  static const String continueText = 'CONTINUE';

  // Estate Selection
  static const String selectYourEstate = 'SELECT YOUR ESTATE';
  static const String selectEstateSubtitle =
      'Choose your residential community to access your estate portal.';
  static const String searchEstatePlaceholder = 'Search estate by name or code...';
  static const String noEstatesFound = 'No estates match your search';

  // Main navigation tabs
  static const String tabHome = 'HOME';
  static const String tabActivity = 'ACTIVITY';
  static const String tabAccount = 'ACCOUNT';

  // Home Screen (Phase 2)
  static const String greetingPrefix = 'GOOD MORNING';
  static const String defaultResidentName = 'JOSHUA';
  static const String primaryQuestion = 'WHAT DO YOU NEED?';

  // 4 Primary Actions
  static const String actionVisitors = 'VISITORS';
  static const String actionServices = 'SERVICES';
  static const String actionMaintenance = 'MAINTENANCE';
  static const String actionPayments = 'PAYMENTS';

  // Upcoming & Recent Activity Sections
  static const String sectionUpcoming = 'UPCOMING';
  static const String noUpcomingItems = 'NO UPCOMING ITEMS';
  static const String upcomingEmptySubtitle =
      'Scheduled visitors, deliveries, and service appointments will appear here.';

  static const String sectionRecentActivity = 'RECENT ACTIVITY';
  static const String noRecentActivity = 'NO RECENT ACTIVITY';
  static const String recentActivityEmptySubtitle =
      'Recent passes, service requests, and gate activity will show here.';

  // Placeholder destination copy for Home actions
  static const String visitorsComingSoon = 'Visitor features coming next.';
  static const String servicesComingSoon = 'Estate services features coming soon.';
  static const String maintenanceComingSoon = 'Maintenance requests features coming soon.';
  static const String paymentsComingSoon = 'Estate payments and dues features coming soon.';

  // Phase 3A - Visitors Home Screen
  static const String visitorsTitle = 'VISITORS';
  static const String visitorsSubtitle = 'MANAGE WHO COMES INTO YOUR ESTATE';

  static const String actionInviteSomeone = 'INVITE SOMEONE';
  static const String inviteSomeoneSubtitle = 'Create a pass for one visitor.';

  static const String actionCreateEvent = 'CREATE EVENT';
  static const String createEventSubtitle = 'Create access for multiple guests.';

  static const String noUpcomingVisitors = 'NO UPCOMING VISITORS';
  static const String upcomingVisitorsSubtitle = 'Visitors you invite will appear here.';

  static const String sectionRecent = 'RECENT';
  static const String noRecentVisits = 'NO RECENT VISITS';
  static const String recentVisitsSubtitle = 'Your visitor history will appear here.';

  // Phase 3B - Invite Someone Form
  static const String inviteSomeoneHeader = 'INVITE SOMEONE';
  static const String inviteSomeoneHeaderSubtitle = 'CREATE A VISITOR PASS';

  static const String sectionWhoIsComing = 'WHO IS COMING?';
  static const String labelFullName = 'FULL NAME';
  static const String placeholderFullName = "Visitor's name";

  static const String labelPhoneNumber = 'PHONE NUMBER';
  static const String placeholderPhoneNumber = "Visitor's phone number";

  static const String sectionWhenComing = 'WHEN ARE THEY COMING?';
  static const String labelDate = 'DATE';
  static const String labelArrivalTime = 'ARRIVAL TIME';

  static const String sectionVehicle = 'VEHICLE';
  static const String optionalBadge = 'OPTIONAL';
  static const String labelPlateNumber = 'PLATE NUMBER';
  static const String placeholderPlateNumber = 'Vehicle plate number';
  static const String labelVehicleDescription = 'VEHICLE DESCRIPTION';
  static const String placeholderVehicleDescription = 'e.g. Black Toyota Camry';

  static const String createPassAction = 'CREATE PASS';

  // Validation
  static const String errorFullNameRequired = "Please enter the visitor's full name";
  static const String errorPhoneRequired = "Please enter the visitor's phone number";
  static const String errorPhoneInvalid = 'Please enter a valid phone number';
  static const String errorDatePast = 'Arrival date cannot be in the past';

  // Phase 3C - Visitor Pass Screen
  static const String visitorPassHeader = 'VISITOR PASS';
  static const String visitorPassExpected = 'THIS PERSON IS EXPECTED';
  static const String labelVisitor = 'VISITOR';
  static const String labelArrival = 'ARRIVAL';
  static const String labelPass = 'PASS';
  static const String labelExpires = 'EXPIRES';
  static const String showCodeAtEntrance = 'SHOW THIS CODE AT THE ESTATE ENTRANCE';

  static const String sharePassAction = 'SHARE PASS';
  static const String cancelPassAction = 'CANCEL PASS';

  // Cancel dialog
  static const String cancelPassDialogTitle = 'CANCEL VISITOR PASS?';
  static const String cancelPassDialogContent =
      'This visitor will no longer be expected and the access code will be invalidated.';
  static const String keepPassAction = 'KEEP PASS';
  static const String confirmCancelAction = 'CANCEL PASS';

  // Phase 4A - Create Event Form
  static const String createEventHeader = 'CREATE EVENT';
  static const String createEventHeaderSubtitle = 'MAKE ACCESS EASY FOR YOUR GUESTS';

  static const String sectionWhatHosting = 'WHAT ARE YOU HOSTING?';
  static const String labelEventName = 'EVENT NAME';
  static const String placeholderEventName = "e.g. John's Birthday";

  static const String sectionWhenIsIt = 'WHEN IS IT?';
  static const String labelStartTime = 'START TIME';
  static const String labelEndTime = 'END TIME';

  static const String sectionHowManyGuests = 'HOW MANY GUESTS?';
  static const String labelExpectedGuests = 'EXPECTED GUESTS';
  static const String placeholderExpectedGuests = '1 – 500';

  static const String createEventAction = 'CREATE EVENT';

  // Phase 4A Validation
  static const String errorEventNameRequired = 'Please enter the event name';
  static const String errorEventDatePast = 'Event date cannot be in the past';
  static const String errorEndTimeInvalid = 'End time must be after start time';
  static const String errorGuestsInvalid = 'Expected guests must be between 1 and 500';

  // Phase 4A Confirmation
  static const String eventCreatedTitle = 'EVENT CREATED';
  static const String eventCreatedNotice = 'Event access will be available in the next step.';
  static const String labelGuests = 'GUESTS';
  static const String doneAction = 'DONE';

  // Phase 4B - Event Pass + QR Code
  static const String eventPassTitle = 'EVENT PASS';
  static const String labelEventCode = 'EVENT CODE';
  static const String eventCodeExplanation = 'Guests can use this code at the estate entrance.';
  static const String qrInstructionEvent = 'SHOW THIS CODE AT THE ESTATE ENTRANCE';
  static const String shareEventAction = 'SHARE EVENT';
  static const String cancelEventAction = 'CANCEL EVENT';
  static const String cancelEventDialogTitle = 'CANCEL EVENT?';
  static const String cancelEventDialogContent = 'Guests will no longer be expected for this event.';
  static const String keepEventAction = 'KEEP EVENT';

  // Phase 5A - Security Home
  static const String securityTitle = 'SECURITY';
  static const String verifyAccessAction = 'VERIFY ACCESS';
  static const String verifyAccessSubtitle = 'Scan a visitor or event pass.';
  static const String verifyAccessPlaceholderTitle = 'VERIFY ACCESS';
  static const String verifyAccessPlaceholderSubtitle = 'SCANNER & PASS VERIFICATION';
  static const String verifyAccessPlaceholderNotice =
      'QR scanning and access verification will be built in the next phase.';
  static const String sectionToday = 'TODAY';
  static const String labelSecurityVisitors = 'VISITORS';
  static const String labelSecurityEvents = 'EVENTS';
  static const String noActivityStatus = 'NO ACTIVITY';
  static const String recentActivitySubtitle = 'Access activity will appear here.';
  static const String tabSecurity = 'SECURITY';
  static const String tabSecurityAccount = 'ACCOUNT';
  static const String securityAccountTitle = 'SECURITY ACCOUNT';
  static const String securityAccountSubtitle = 'Officer profile and gate terminal';
  static const String switchSecurityPortal = 'Security Gate Terminal';

  // Phase 5B - Security QR Scanner & Decoded Result
  static const String verifyAccessSubtitleScanner = 'SCAN A VISITOR OR EVENT PASS';
  static const String scanQrCodeGuide = 'SCAN QR CODE';
  static const String scanQrCodeInstruction = 'Put the QR code inside this area.';
  static const String cameraAccessRequired = 'CAMERA ACCESS REQUIRED';
  static const String cameraAccessRequiredSubtitle =
      'Allow camera access to scan visitor and event passes.';
  static const String grantPermissionAction = 'GRANT PERMISSION';
  static const String cameraError = 'CAMERA ERROR';
  static const String cameraUnavailableSubtitle = 'Camera is unavailable on this device.';
  static const String qrCodeScannedTitle = 'QR CODE SCANNED';
  static const String scanReceivedNotice = 'SCAN RECEIVED';
  static const String unrecognizedQrTitle = 'UNRECOGNIZED QR';
  static const String unrecognizedQrSubtitle = 'This QR code is not a SmartQ access pass.';
  static const String scanAgainAction = 'SCAN AGAIN';
  static const String labelRawPayload = 'RAW DATA';
  static const String labelPassId = 'PASS IDENTIFIER';
  static const String labelPassType = 'PASS TYPE';
  static const String labelVerificationToken = 'SECURITY TOKEN';
  static const String pendingVerificationNotice =
      'Pass verification and access decision will occur in the next phase.';

  // Placeholders
  static const String homeToolsPlaceholder =
      'Your estate tools and passes will appear here.';
  static const String noActivityYet = 'NO ACTIVITY YET';
  static const String activityEmptySubtitle =
      'Your access logs, requests, and visitor entries will be tracked here.';
  static const String residentAccount = 'RESIDENT ACCOUNT';

  // Phase 5C — Access Result Screen
  static const String accessAllowed = 'ACCESS ALLOWED';
  static const String accessDenied = 'ACCESS DENIED';

  // Denied — specific reasons (displayed as secondary headline)
  static const String resultPassExpired = 'PASS EXPIRED';
  static const String resultPassCancelled = 'PASS CANCELLED';
  static const String resultPassInvalid = 'PASS COULD NOT BE VERIFIED';
  static const String resultUnrecognizedQr = 'UNRECOGNIZED QR CODE';

  // Denied — supporting body text
  static const String resultExpiredBody = 'This pass is no longer active.';
  static const String resultCancelledBody = 'This pass has been cancelled by the resident.';
  static const String resultInvalidBody = 'The pass is not recognized by this estate.';
  static const String resultUnrecognizedBody = 'This QR code is not a SmartQ access pass.';

  // Access Result — field labels (visitor)
  static const String labelVisitorSection = 'VISITOR';
  static const String labelEventSection = 'EVENT';
  static const String labelVehicleSection = 'VEHICLE';
  static const String labelAccessGranted = 'ACCESS GRANTED';
  static const String backToSecurityHome = 'BACK TO SECURITY HOME';

  // Phase 5D — Access Log + Check-In
  static const String allowEntryAction = 'ALLOW ENTRY';
  static const String allowEntrySubtitle = 'Record this person as entering the estate.';
  static const String allowEntryConfirmTitle = 'ALLOW ENTRY?';
  static const String allowEntryConfirmCancel = 'CANCEL';
  static const String entryRecordedTitle = 'ENTRY RECORDED';
  static const String labelEntry = 'ENTRY';
  static const String labelGate = 'GATE';
  static const String labelEventAccess = 'EVENT ACCESS';
  static const String checkedInSuffix = 'CHECKED IN';
  static const String accessEventsSuffix = 'ACCESS EVENTS';

  // Phase 6A — Resident Services Home
  static const String servicesTitle = 'SERVICES';
  static const String servicesSubtitle = 'GET THINGS DONE.';
  static const String servicesQuestion = 'WHAT DO YOU NEED?';
  static const String servicesQuestionSubtitle =
      "Choose a service and we'll take you through the next step.";

  static const String marketRunTitle = 'MARKET RUN';
  static const String marketRunSubtitle = 'Someone shops for you.';

  static const String groceriesTitle = 'GROCERIES';
  static const String groceriesSubtitle = 'Get everyday essentials delivered.';

  static const String gasTitle = 'GAS';
  static const String gasSubtitle = 'Request cooking gas delivery.';

  static const String petrolTitle = 'PETROL';
  static const String petrolSubtitle = 'Request fuel delivery.';

  static const String generatorTitle = 'GENERATOR';
  static const String generatorSubtitle = 'Get generator service.';

  static const String maintenanceTitle = 'MAINTENANCE';
  static const String maintenanceSubtitle = 'Get something fixed.';

  static const String servicePlaceholderNotice =
      'This service will be built in the next step.';

  // Phase 6B — Market Run Request
  static const String marketRunHeaderSubtitle = 'SOMEONE SHOPS FOR YOU.';
  static const String marketRunQuestion = 'WHAT DO YOU NEED?';
  static const String marketRunQuestionSubtitle =
      'List the things you want someone to buy for you.';
  static const String labelItems = 'ITEMS';
  static const String hintMarketRunItems =
      'e.g. Tomatoes, onions, chicken, rice and bottled water.';
  static const String timingHeading = 'WHEN DO YOU NEED IT?';
  static const String timingAsap = 'AS SOON AS POSSIBLE';
  static const String timingLaterToday = 'LATER TODAY';
  static const String timingSchedule = 'SCHEDULE';
  static const String labelDeliverTo = 'DELIVER TO';
  static const String myEstateAddress = 'MY ESTATE ADDRESS';
  static const String labelNotesOptional = 'NOTES (OPTIONAL)';
  static const String hintMarketRunNotes =
      'Anything else the shopper should know.';
  static const String actionRequestMarketRun = 'REQUEST MARKET RUN';
  static const String errorItemsRequired = 'Please tell us what you need.';
  static const String errorScheduledPast =
      'Scheduled time cannot be in the past.';
  static const String errorScheduledRequired =
      'Please select a date and time.';
  static const String requestReceivedTitle = 'REQUEST RECEIVED';
  static const String requestReceivedSubtitle =
      "We've received your market run request.";
  static const String labelWhatYouAskedFor = 'WHAT YOU ASKED FOR';
  static const String labelWhen = 'WHEN';
  static const String labelNotes = 'NOTES';

  // Phase 6C — Groceries Request
  static const String groceriesHeaderSubtitle =
      'GET EVERYDAY ESSENTIALS DELIVERED.';
  static const String groceriesQuestion = 'WHAT DO YOU NEED?';
  static const String groceriesQuestionSubtitle =
      'List the grocery items you want delivered to your home.';
  static const String hintGroceriesItems =
      'e.g. Bread, milk, eggs, cereal and cooking oil.';
  static const String hintGroceriesNotes =
      'Anything else the delivery person should know.';
  static const String actionRequestGroceries = 'REQUEST GROCERIES';
  static const String groceriesRequestReceivedSubtitle =
      "We've received your groceries request.";

  // Phase 6D — Gas Request
  static const String gasHeaderSubtitle = 'REQUEST COOKING GAS DELIVERY.';
  static const String gasQuestion = 'SELECT CYLINDER SIZE';
  static const String gasQuestionSubtitle =
      'Choose your cylinder size or enter a custom quantity.';
  static const String labelCylinderSize = 'CYLINDER SIZE';
  static const String labelCustomQuantity = 'CUSTOM QUANTITY';
  static const String hintCustomGasQuantity =
      'e.g. 2 x 12.5 KG, 25 KG or 50 KG';
  static const String hintGasNotes =
      'Anything else the delivery person should know.';
  static const String actionRequestGas = 'REQUEST GAS';
  static const String gasRequestReceivedSubtitle =
      "We've received your cooking gas request.";
  static const String errorGasQuantityRequired =
      'Please select or enter a cylinder quantity.';
  static const String labelQuantityRequested = 'QUANTITY';

  // Phase 6E — Petrol Request
  static const String petrolHeaderSubtitle = 'REQUEST FUEL DELIVERY.';
  static const String petrolQuestion = 'HOW MUCH FUEL DO YOU NEED?';
  static const String petrolQuestionSubtitle =
      'Select a quantity or enter a custom amount.';
  static const String labelFuelQuantity = 'FUEL QUANTITY';
  static const String labelCustomLiters = 'CUSTOM QUANTITY (LITERS)';
  static const String hintCustomPetrolQuantity = 'e.g. 25 or 50';
  static const String labelVehicleOptional = 'VEHICLE (OPTIONAL)';
  static const String hintVehicle =
      'e.g. Black Toyota Camry or Generator fuel tank';
  static const String hintPetrolNotes =
      'Anything else the delivery person should know.';
  static const String actionRequestPetrol = 'REQUEST PETROL';
  static const String petrolRequestReceivedSubtitle =
      "We've received your petrol delivery request.";
  static const String errorPetrolQuantityRequired =
      'Please select or enter a fuel quantity.';
  static const String labelVehicle = 'VEHICLE';

  // Phase 6F — Generator Request
  static const String generatorHeaderSubtitle = 'REQUEST GENERATOR SERVICE.';
  static const String generatorQuestion = 'WHAT NEEDS ATTENTION?';
  static const String generatorQuestionSubtitle =
      'Describe the issue or maintenance your generator needs.';
  static const String labelServiceDescription = 'SERVICE DESCRIPTION';
  static const String hintGeneratorServiceDescription =
      'e.g. Generator is smoking heavily, won’t start, or needs regular servicing and oil change...';
  static const String labelGeneratorModelOptional =
      'GENERATOR TYPE OR MODEL (OPTIONAL)';
  static const String hintGeneratorModel =
      'e.g. 5kVA Firman or 20kVA Mikano Soundproof Diesel';
  static const String hintGeneratorNotes =
      'Anything else the technician should know (e.g. key location, gate pass)...';
  static const String actionRequestGenerator = 'REQUEST GENERATOR SERVICE';
  static const String generatorRequestReceivedSubtitle =
      "We've received your generator service request.";
  static const String errorGeneratorDescriptionRequired =
      'Please describe the generator service needed.';
  static const String labelServiceDescriptionSummary = 'SERVICE DESCRIPTION';
  static const String labelGeneratorSummary = 'GENERATOR';

  // Phase 6G — Maintenance Request
  static const String maintenanceHeaderSubtitle =
      'REQUEST PROPERTY & HOME REPAIRS.';
  static const String maintenanceQuestion = 'WHAT NEEDS FIXING?';
  static const String maintenanceQuestionSubtitle =
      'Describe the issue or repair you need in your home.';
  static const String labelMaintenanceDescription = 'WHAT NEEDS ATTENTION';
  static const String hintMaintenanceDescription =
      'e.g. Leaking kitchen sink pipe, faulty bedroom socket, broken door lock...';
  static const String labelCategoryOptional = 'CATEGORY (OPTIONAL)';
  static const String hintCategory =
      'e.g. Plumbing, Electrical, Carpentry, AC';
  static const String hintMaintenanceNotes =
      'Any special access instructions (e.g. Key with security, call before entering)...';
  static const String actionRequestMaintenance = 'REQUEST MAINTENANCE';
  static const String maintenanceRequestReceivedSubtitle =
      "We've received your maintenance request.";
  static const String errorMaintenanceDescriptionRequired =
      'Please describe what needs fixing.';
  static const String labelCategorySummary = 'CATEGORY';
  static const String labelDescriptionSummary = 'WHAT NEEDS FIXING';
}

