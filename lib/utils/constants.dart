class Constants {
  // ❗ Don't hardcode API keys! Use environment variables or secure storage instead.
  static const String geminiApiKey = "AIzaSyBT3sZF3rFCY2HoIsQAfCN3SYaUs6rqCtY";
  static const String geminiModel = "gemini-1.5-flash";

  static const String imagePath = "imagePath";
  static const String responseText = "responseText";

  // Custom Search Engine API (CSE)
  static const String cseApiKey = "AIzaSyDmlzapaTiCmCQGhlobeHqjPGCE9UAdxKA";
  static const String cseId = "55f994cb2ea4442b2";

  static const String appName = "Voux";
  static const String splash = "splash";
  static const String onboarding = "onboarding";
  static const String home = "home";
  static const String detail = "detail";
  static const String auth = "auth";
  static const String settings = "settings";
  static const String upgrade = "upgrade";

  // Shared Preferences
  static const String isLoggedIn = "isLoggedIn";
  static const String isDarkMode = "isDarkMode";
  static const String canNoti = "canNoti";

  static const String plan = "Plan";

  // Gender
  static const String male = "male";
  static const String female = "female";

  // Analyze
  static const String unknown = "unknown";
  static const String forChildOrNot = "forChildOrNot";
  static const String gender = "gender";
  static const String items = "items";
  static const String size = "size";
  static const String color = "color";
  static const String material = "material";
  static const String brand = "brand";
  static const String model = "model";
  static const String type = "type";
  static const String name = "name";

  static const String geminiPrompt = """
Analyze the given image and generate a list of clothing items based on the detected apparel. For each clothing item, provide structured details in JSON format as follows:

[
  {
    "name": "Casual T-Shirt",
    "color": "Blue",
    "size": "M",
    "type": "T-Shirt",
    "material": "Cotton",
    "brand": "Nike",
    "model": "AirMax Tee"
  },
  {
    "name": "Denim Jeans",
    "color": "Black",
    "size": "32",
    "type": "Jeans",
    "material": "Denim",
    "brand": "Levi's",
    "model": "511 Slim Fit"
  }
]

Ensure that the clothing attributes are accurately inferred from the image, including color, size (if possible), type, material, brand (if recognizable), and model. The response should only contain the JSON array without additional text.
""";

  static const String geminiGenderPrompt = """
Analyze the given image and determine the gender of the person in the image. 

Return the result strictly in the following JSON format:

{
  "gender": "male" // or "female"
}

Ensure that the response contains only the JSON object without any additional text.
""";

  static const String geminiIsChildOrNotPrompt = """
Analyze the given image and determine if the person in the image is a child or an adult.

Return the result strictly in the following JSON format:

{
  "is_child": true // or false
}

Ensure that the response contains only the JSON object without any additional text.
""";

  // Firestore
  static const String users = "users";
  static const String id = "id";
  static const String uid = "uid";
  static const String email = "email";
  static const String currentSubscriptionStatus = "currentSubscriptionStatus";
  static const String purchaseTime = "purchaseTime";
  static const String endTime = "endTime";
  static const String createdAt = "createdAt";
  static const String subscriptions = "subscriptions";
  static const String analysisLimit = "analysisLimit";
  static const String currentAnalysisCount = "currentAnalysisCount";

  // Plans
  static const String currentPlan = "currentPlan";
  static const String freePlan = "freePlan";
  static const String plusPlan = "plusPlan";
  static const String proPlan = "proPlan";

  // Plan Numbers
  static const int analysisLimitCountFree = 10;
  static const int analysisLimitCountPlus = 50;
  static const int analysisLimitCountPro = 100;
}
