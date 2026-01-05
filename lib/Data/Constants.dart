import 'package:flutter/material.dart';

// const bool kDebugMode = true;
const String kVersionInfo = "V1.5.0";
const bool kIsDevEnv = true;
const String kHostURL = kIsDevEnv ? "http://14.225.192.248:8002" : "https://aiotech-api.io.vn";
const String kNameApp = "Mầm non Z121";
const String kAPIRegister = "register";
const String kAPIResetPass = "resetPassword";
const String kAPIRequestOTP = "otp/request";
const String kAPIRequestOTA = "updateOTA";
const String kAPILogin = "login";
const String kAPIUserInfo = "user/info";
const String kApiDeleteDevice = "deleteDevice";
const String kApiDeleteHome = "deleteHome";
const String kApiDeleteRoom = "deleteRoom";
const String kApiDeleteScene = "deleteScene";
const String kApiUpdateDevice = "updateDevice";
const String kApiMergeDevice = "mergeDevices";
const String kApiLinkDevice = "linkDevice";
const String kApiRunScene = "runScene";
const String kApiEnableDisableScene = "enableDisableScene";
const String kEmail = "email";
const String kUsername = "username";
const String kPhoneNum = "phoneNumber";
const String kPassWord = "password";
const String kOtpCode = "otpCode";
const String kUserName = "username";
const String kMqttHost = "mqttHost";
const String kMqttPassword = "mqttPassword";
const String kMqttPort = "mqttPort";
const String kUser = "user";
const String kId = "id";
const String kIds = "ids";
const String kUserId = "userId";
const String kHomes = "homes";
const String kName = "n";
const String kToken = "token";
const String kRefreshToken = "refreshToken";
const String kActive = "isActive";
const String kMergeDevices = "mDevices";
const String kFirmWares = "firmwares";
const String kMergeName = "mName";
const String kLinkDeviceRootId = "firstId";
const String kLinkElementRootId = "firstElement";
const String kLinkDeviceId = "secondId";
const String kLinkDevice = "linkDevice";
const String kLinkElementId = "secondElement";
const String kAPIUserHomeInfo = "userHomeInfo";
const String kAPIGetHomeDetail = "getHomeInfo";
const String kAPIGetListHome = "getListHomes";
const String kAPIGetSharedHomeDetail = "getSharedHomeInfo";
const String kAPICreateHome = "createHome";
const String kAPIAddDevice = "addDevice";
const String kAPIAddMember = "share/addMember";
const String kAPIRemoveMember = "share/removeMember";
const String kAPIGetMember = "share/getMembers";
const String kAPIGetRequest = "share/getRequests";
const String kAPIConfirmRequest = "share/confirmRequest";
const String kAPIRoomInfo = "createRoom";
const String kDevices = "devices";
const String kCreateScene = "createScene";
const String kUpdateOrders = "updateOrders";
const String kUpdateScene = "updateScene";
const String kUpdateHomeInfo = "updateHome";
const String kUpdateRoomInfo = "updateRoom";
const String kAPIDataInfo = "dataInfo";
const String kAPIGetLogInfo = "deviceLog";
const String kAPIGetNextAddress = "getAddress";
const String kAPIGateway = "gateway";
const String kAPIDevice = "deviceInfo";
const String kAPIName = "nameInfo";
const String kAPIDeviceGroupInfo = "deviceGroupInfo";
const String kParam = "param";
const String kListHomes = "listHomes";
const String kMessage = "message";
const String kMessageId = "m";
const String kCode = "code";
const String kError = "error";
const String kCauseId = "causeId";
const String kHomeID = "homeId";
const String kMemberID = "memberId";
const String kDeviceIDs = "deviceIds";
const String kRoomIDs = "roomIds";
const String kSceneIDs = "sceneIds";
const String kShareAccount = "sharedAccount";
const String kUserDetail = "userDetail";
const String kHomeDetail = "homeDetail";
const String kGateways = "gateways";
const String kDeviceUsers = "deviceUsers";
const String kNetKey = "netKey";
const String kAppKey = "appKey";
const String kVersion = "v";
const String kNetKeyIndex = "netkeyIndex";
const String kIvIndex = "ivIndex";
const String kDeviceKey = "deviceKey";
const String kIndexPing = "indexPing";
const String kAppKeyIndex = "appkeyIndex";
const String kIpWifi = "ipWifi";
const String kIpEthernet = "ipEthernet";
const String kMaxAddress = "maxAddress";
const String kTimeServer = "updateTime";
const String kTimeHC = "timehc";
const String kBuildTime = "buildTime";
const String kWifiName = "wifiName";
const String kIsMaster = "isMaster";
const String kStartTime = "start";
const String kEndTime = "end";
const String kPageNumber = "page";
const String kPageSize = "pageSize";
const String kRepeatTime = "repeat";
const String kAddress = "address";
const String kMac = "macAddress";
const String kTime = "time";
const String kSign = "si";
const String kSender = "sender";
const String kSenderId = "senderId";
const String kConfig = "cfg";
const String kOwner = "owner";
const String kType = "t";
const String kImageType = "typeImage";
const String kTypeAnimation = "typeAnimation";
const String kRoomInfo = "roomInfo";
const String kRooms = "rooms";
const String kShared = "shared";
const String kGroups = "groups";
const String kScenes = "scenes";
const String kDevice = "d";
const String kDb = "db";
const String kSSID = "ssid";
const String kIP = "ip";
const String kGroup = "group";
const String kScene = "scene";
const String kMobile = "mobile";
const String kHC = "hc";
const String kGroupId = "groupId";
const String kPos = "pos";
const String kColorOn = "colorOn";
const String kColorOff = "colorOff";
const String kNotify = "notify";
const String kGateway = "gateway";
const String kProductId = "pid";
const String kRoomId = "roomId";
const String kParentID = "parentId";
const String kState = "state";
const String kOrder = "order";
const String kHomeOrder = "homeOrder";
const String kRoomOrder = "roomOrder";
const String kDps = "dp";
const String kElementID = "e";
const String kDpValue = "v";
const String kDpId = "d";
const String kTimer = "timer";
const String kCountDownElement = "cnt";
// const String kDelay = "delay";
const String kIcon = "icon";
const String kIconColor = "iconColor";
const String kSceneType = "sceneType";
const String kInfo = "info";
const String kEntityID = "entityId";
const String kEntityType = "entityType";
const String kSubDevId = "subDevId";
const String kExp = "exp";
const String kDpOperator = "o";
const String kMatch = "triggerType";
const String kActions = "actions";
const String kConditions = "conditions";
const String kPreconditions = "precondition";

const String kNotifyUpdateListDevices = "updateListDevice";
const String kNotifyUpdateListFavourist = "updateListFavourist";
const String kNotifyAddDevices = "addDevices";
const String kNotifyUpdateListSubDevices = "updateListSubDevice";
const String kNotifyUpdateListScenes = "updateListScene";
const String kNotifyUpdateListMembers = "updateListMembers";
const String kOnOffline = "onOffline";
const String kDefaultGW = "0a00";

const String kRoleSuperadmin = "superadmin";
const String kRoleAdmin      = "admin";
const String kRoleEnterprise = "enterprise";
const String kMealBreakfast  = "breakfast";
const String kMealLunch      = "lunch";
const String kMealDinner     = "dinner";
const String kStatusPending    = "pending";
const String kStatusAccepted   = "accepted";
const String kStatusRejected   = "rejected";

const int kEntityTypeDelay = 0;
const int kEntityTypeDevice = 1;
const int kEntityTypeTimer = 2;
const int kEntityTypeScene = 3;
const int kEntityTypeGroup = 4;

const int kStateOnline = 1;
const int kStateObjectErrorFull = 1;
const int kStateObjectSuccess = 0;
const int kStateObjectDeleteSuccess = -1;
const int kStateObjectAdd = -2;
const int kStateObjectDelete = -3;
const int kStateObjectUpdate = -4;
const int kStateObjectAddFailed = -6;
const int kOutOfSceneGroup = 5;
const int kTimeOutSceneGroup = 6;

const int kStateAddDeviceScan = -3;
const int kStateAddDeviceAdd = -2;
const int kStateAddDeviceConfig = -1;
const int kStateAddDeviceSendBLEFailed = -4;
const int kStateAddDeviceFailed = -5;

const int kDpTurnOnOff = 1;
const int kDpLightMode = 2;
const int kDpLightScene = 3;
const int kDpLightColor = 4;
const int kDpLightColorRGB = 5;
const int kDpLightBright = 6;
const int kDpLightSaturation = 7;

const int kDpGateControl = 9; // Control gate or curtain (0:open, 1: stop, 2:close)

// Status dps
const int kDpBattery = 100; // Battery percent (0-100)
const int kDpGateMovingState = 101; // Gate moving state (0: not moving, 1: moving)
const int kDpGatePosition = 102; // Current position percent of gate or curtain (0-100)
const int kDpSensorSmoke = 103; // Smoke signal status (0: no smoke, 1: has smoke)
const int kDpSensorDoor = 104; // Door status (0: close, 1: open)
const int kDpSensorHang = 105; // Device hanging state (0: not hang, 1: hung)
const int kDpSensorTemp = 106; // Temperature (0-1000)
const int kDpSensorHumility = 107; // Humidity (0-100)
const int kDpSensorAirQuality = 108; // Air quality (0-1000)
const int kDpSensorHuman = 109; // PIR or presence sensor state (0: No person, 1: has a person)

const int kDpIRMemoryID = 20;
const int kDpIRNumberID = 21;
const int kDpIRButtonID = 22;
const int kDpIRTemp = 23;
const int kDpIRMode = 24;
const int kDpIRFan = 25;
const int kDpIRSwing = 26;
const int kDpIRVoiceID = 27;
const int kDpIRWakeUpID = 29;
const int kDpIRVolume = 30;
const int kDpIRIsConnectHC = 31;

// ENUM
const int kShareDevice = -2;
const int kManageDevice = -1;
const int kSceneTypeBLE = 0;
const int kSceneTypeHC = 1;
const int kSceneTypeDevice = 2;

// ENUM

enum TypeApiMethod {
  get,post,delete
}

enum SettingMode { normal, admin, agency }

enum TypeLogin { login, register, forgotPass }

enum ActionConditionType { unknown, action, condition, actionCondition }

enum ActionHomeType {studentProfile,mealFee,requestLeave,checkIn,checkOut,}

enum ActionSettingType {
  settingMode,
  logout,
  notify,
  instruct,
  log,
  deleteAccount,
  changeLanguage,
  changeOwner,
  shareDevice,
  controlBLE,
  removeSyncHomekit,
  quickControl,
  detailSetting,
  watchControl,
  turnPopupScene,
  turnOnVibrate,
  turnOnNotify,
  nameDisplay,
  changePass,
  manageHome
}

enum PermissionRequest {
  location,
  microphone,
  all,
}

enum DeviceType {
  unknown,
  lightNormal,
  fan,
  airConditional,
  television,
  lightRgb,
  switch1,
  switch2,
  switch3,
  switch4,
  curtain,
  camera,
  sensorDoor,
  sensorMove,
  smartIR,
  lightWhite,
  electricHeater,
  sdkAir,
  sdkTelevision,
  sdkFan,
  rollingDoor,
  sensorEnvironment,
  doubleCurtain,
  smartLock,
  remote,
  aptomatSmart,
  alarm,
  robot,
  gateway,
  sensorWater,
  sensorSmoke,
  smartPlug,
  scenaratButton,
  rollingCurtain,
  sdkSpeaker,
  sdkDVB,
  autoGateDoor,
  aptomatNormal,
  repeaterZigbee,
  autoGateDoor50,
  smartDoorBell,
  switchCurtain,
  switchRollingCurtain,
  sensorLifeBeing,
  switchPir,
  sensorMulti,
  switchScene_3
}

const double kHeightButton = 50;
const double kRadiusIcon = 20;
const double kSizeTextHeader = 16;
const double kSizeTextTitle = 14;
const double kSizeTextNormal = 12;
const int kTimeOutHC = 300;
const Color kMainColor = Color(0xFFFF3352);
const Color kDisMainColor = Color(0xFF38bb7d);
const Color kBgGreyColor = Color(0xFFF5F5F5);
const Color kSelectedColor = Color(0xFF34C759);
const Color kSenorColor = Color(0xFFFFCC00);
const Color kNotiColor = Color(0xFFFE7484);
const List<Color> listColors = [Color(0xFF11998e), Color(0xFF38bb7d), Color(0xFFFFCC00), Color(0xFFFE7484)];
Color kBlackColor = Colors.black.withAlpha(128);
const EdgeInsets paddingAll = EdgeInsets.all(16);
const EdgeInsets paddingButton = EdgeInsets.all(8);

Color kOfflineColor = Colors.black.withOpacity(0.1);
Color kOnStateColor = Colors.red.withOpacity(0.86);
Color kOffStateColor = Colors.green.withOpacity(0.86);
Color kSubColor = kMainColor.withOpacity(0.1);
Color kBackgroundGreyColor = Colors.grey.withOpacity(0.1);
Color kOverlayColor = Colors.black.withOpacity(0.5);

Map<String, dynamic> kDefaultMapEmpty = {};

const List<List<Size>> listSizeLightDevices = [
  [
    Size(591, 827),
    Size(591, 827),
    Size(591, 591),
    Size(591, 591),
    Size(1181, 196),
    Size(850, 850),
    Size(850, 850),
    Size(1181, 1181),
    Size(1181, 1181),
    Size(591, 591),
    Size(520, 273),
    Size(520, 273),
    Size(500, 500),
    Size(355, 311),
    Size(157, 256),
    Size(156, 256),
    Size(256, 254),
    Size(331, 452),
    Size(331, 432),
    Size(181, 402),
    Size(181, 402),
    Size(550, 476),
    Size(550, 420),
    Size(372, 279),
    Size(384, 514),
    Size(384, 514),
    Size(265, 430),
    Size(265, 378),
    Size(188, 294),
    Size(188, 294),
    Size(420, 481),
    Size(413, 486),
    Size(456, 474),
    Size(465, 428)
  ],
  [Size(177, 171)],
  [Size(1600, 900)],
  [Size(1412, 1307)],
  [Size(2001, 2001)],
  [Size(257, 288), Size(193, 273), Size(508, 557), Size(265, 291), Size(454, 623), Size(1063, 1107)]
];
const List<List<int>> listScenesColor = [
  [10, 10],
  [800, 800],
  [1000, 1000],
  [10, 200]
];
const List<String> listDeviceNames = [
  "Không xác định",
  "Đèn",
  "Quạt",
  "Điều hoà",
  "TV",
  "Đèn đổi màu",
  "Mặt công tắc 1",
  "Mặt công tắc 2",
  "Mặt công tắc 3",
  "Mặt công tắc 4",
  "Rèm ngang",
  "Camera",
  "Cảm biến cửa",
  "Cảm biến chuyển động",
  "IR",
  "Đèn trắng",
  "Bình nóng lạnh",
  "Điều hoà",
  "TV",
  "Quạt điều khiển",
  "Cửa cuốn",
  "Cảm biến môi trường",
  "Rèm đôi",
  "Khoá cửa",
  "Remote",
  "Aptomat đo điện",
  "Báo động",
  "Robot hút bụi",
  "Gateway",
  "Cảm biến tràn nước",
  "Cảm biến khói",
  "Ổ cắm",
  "Công tắc kịch bản",
  "Rèm cuốn",
  "Loa",
  "Đầu kỹ thuật số",
  "Cửa cổng tự động",
  "Aptomat thường",
  "Kích sóng Zigbee",
  "Cửa cổng tự động mở 50",
  "Chuông cửa",
  "Rèm ngang",
  "Rèm cuốn",
  "Cảm biến hiện diện",
  "Công tắc cầu thang",
  "Module đa năng",
  "Kịch bản 3 nút"
];
const List<int> listDeviceIcons = [
  0,
  0,
  126,
  121,
  148,
  0,
  144,
  145,
  146,
  147,
  122,
  120,
  124,
  137,
  150,
  0,
  131,
  121,
  148,
  111,
  140,
  142,
  147,
  108,
  111,
  118,
  119,
  138,
  0,
  151,
  155,
  143,
  146,
  140,
  111,
  148,
  127,
  117,
  111,
  127,
  123,
  122,
  140,
  137,
  0,
  0,
  141
];
const List<IconData> listSceneIcons = [
  Icons.access_alarm,
  Icons.light_mode_outlined,
  Icons.dinner_dining_outlined,
  Icons.electric_bolt,
  Icons.home_outlined,
  Icons.output,
  Icons.night_shelter_outlined,
  Icons.movie_creation_outlined,
  Icons.music_note_outlined,
  Icons.menu_book,
  Icons.security,
  Icons.airplanemode_active,
  Icons.warning_amber,
  Icons.work_outline
];
const kButtonTextStyle = TextStyle(height: 1.3, fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold);

var tagLog = "arat";

const String PRODUCT_LIGHT_RGB = "BLEARCD0221,BLEARCD0231";
const String PRODUCT_LIGHT_WHITE = "BLEARCD0201,BLEARCD0211";
const String PRODUCT_SWITCH_1 = "BLEARCD0101,BLEARCD0504,BLEARCD0111,00000001,00000005";
const String PRODUCT_SWITCH_2 = "BLEARCD0102,BLEARCD0112,BLEARCD0505,00000002,00000006";
const String PRODUCT_SWITCH_3 = "BLEARCD0103,BLEARCD0113,BLEARCD0506,00000003,00000007";
const String PRODUCT_SWITCH_2_PIR = "BLEARCD0151";
const String PRODUCT_SWITCH_4 = "BLEARCD0104,00000004,00000008";
const String PRODUCT_DOUBLE_CURTAIN = "BLEARCD0107";
const String PRODUCT_ROLLING_CURTAIN = "BLEARCD0121";
const String PRODUCT_CURTAIN = "BLEARCD0121,BLEARCD0501";
const String PRODUCT_SMART_IR = "WIFIARAC0301";
const String PRODUCT_SENSOR_DOOR = "BLEARCD0404";
const String PRODUCT_SENSOR_MOVE = "BLEARCD0402,BLEARCD0403";
const String PRODUCT_CAMERA = "BLEHGCH0101";
const String PRODUCT_AIRCONDITIONAL = "WIFIARAC0304,WIFIARAC0314,WIFIARAC0324";
const String PRODUCT_TV = "WIFIARAC0302,WIFIARAC0312";
const String PRODUCT_FAN = "WIFIARAC0303,WIFIARAC0313";
const String PRODUCT_ROLLING = "BLEARCD0131,BLEARCD0502";
const String PRODUCT_SENSOR_ENV = "BLEARCD0405";
const String PRODUCT_SMART_LOCK =
    "savpjtaek9dzzaie,9dpghf9dyny8wauq,1lwyew0ter9op6ar,xz46bzasg7uv8a01,1y5ccwwkraao6gsc,bljvjx2nsv02dhao,mgexxncmvikfxwpr,kpzxogftyxo5vnjj,u3c8ep3b1farvrad,nbncgju4wsaj1k3c,0waxzacfsinrk2f9,y5cqzem4b7kh1avd,7u5xxt6ab4h7bxxc,umca8uiv2203ua3k";
const String PRODUCT_REMOTE = "WIFIARAC0305,WIFIARAC0315";
const String PRODUCT_APTOMAT = "tl998i0qoddyufp5,syrn8n4e1jsrt7ru,llcobqwii9fc9y73,aynmagfq01aq70he,BLEARCD0601";
const String PRODUCT_ALARM = "9banba9gl2bm0u52,ycb5bynctn1clibx,hmwihz7cv14xuhdj,tlnaa0oo9o8rzgax";
const String PRODUCT_ROBOT =
    "zlxrskpxkuwxwjae,xvupws5l7u1lhnes,jd2hpvaijdpqr6nk,egjnybqi0m6umamk,ni9c3fn9spagiavt,5ajei2afwuyqfqs4,bvcx2bum8jsb4zra,qexns2fc14oqvy4s,91pqkkdieba3hd3q,mxo74s0uyx9zzdyl";
const String PRODUCT_GATE_WAY = "7zjewx91,egz7wwabtvauzccb,ohwalrf2,gzvra5f9z8qdfb1f,ap7gmhs21yelurbn,maqcxptkjbsu0adz";
const String PRODUCT_WATER = "lb1kmdfc";
const String PRODUCT_SMOKE = "BLEARCD0405";
const String PRODUCT_SMART_PLUG = "l9fqxqiijqolbtdu,rpvbmmhxjekuildw,00000009";
const String PRODUCT_SCENaratS_BUTTON = "ub7urdza";
const String PRODUCT_SPEAKER = "vnrlxgzz8hsbjp0o,g4epfqle2vmfaxb8";
const String PRODUCT_DVB = "hb4CGjpjH3hfWcEY,000000ey28";
const String PRODUCT_AUTO_GATE_DOOR = "BLEARCD0141,BLEARCD0503";
const String PRODUCT_APTOMAT_NORMAL = "lt8nxkaulzsxmj0u";
const String PRODUCT_REPEATER_ZIGBEE = "m0vaazab";
const String PRODUCT_AUTO_GATE_DOOR_50 = "BLEARCD0141,BLEARCD0503";
const String PRODUCT_SMART_DOOR_BELL = "svharw66thosbyvn,0knv5isuqihv4ok1";
const String PRODUCT_SENSOR_LIFE_BEING = "BLEARCD0401";
const String PRODUCT_SENSOR_MULTI = "BLEARCD0607";
const String PRODUCT_SCENE_3 = "BLEARCD0153";

enum TypeVisualDevice {
  unknown,
  icon,
  light,
  fan,
  tv,
  air,
  water,
  curtainGate,
}

enum MealStatus { pending, approved, rejected }

enum TypeRoom { unknown, floor, room, flat }

enum TypeSelectDP {
  action,
  condition,
  countDown,
  schedule,
  linkDevice,
  setting,
}

enum TypeAudio { wakeUp, takeAction, notFound }

enum StateSetUpCurtainGate { none, mask, corner }

enum TypeAnimation {
  scaleFull,
  scaleLeft,
  scaleRight,
  moveLeft,
  moveRight,
  moveUp,
  rotateLeft,
  rotateRight,
  rotateFull,
}

enum TypeHome { normal, demo, trial }

enum TypeAPI {
  unknown,
  addDevice,
  addIrDevice,
  deleteDevice,
  controlDevice,
  updateDevice,
  activeDevice,
  addGroup,
  controlGroup,
  setConfig,
  updateConfig,
  deleteGroup,
  updateGroup,
  addScene,
  controlScene,
  deleteScene,
  updateScene,
  addGateway,
  updateGateway,
  getHomeInfo,
  getLogInfo,
  addUserHome,
  getUserHome,
  addRoom,
  updateRoom,
  deleteRoom,
  addDeviceRoom,
  updateDeviceRoom,
  deleteDeviceRoom,
  irDetectRemote,
  irDetectRemoteFailed,
  irTrialControl,
  deleteHome,
  clearData,
  configAddWifi,
  updateHome,
  changeHome,
  addShare,
  updateShare,
  deleteShare,
  removeSyncHomekit,
  changeHomePhone,
  sendNotify,
  deleteAccount
}

