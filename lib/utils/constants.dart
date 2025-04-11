import 'dart:ui';

class Constants {
  static const clipBehaviour = Clip.hardEdge;

  // Corner Radius
  static const cornerRadiusLarge = 32.0;
  static const cornerRadiusMedium = 18.0;
  static const cornerRadiusSmall = 6.0;

  // Border width
  static const borderWidth = 3.0;

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
  static const String privacyPolicy = "privacyPolicy";
  static const String agreement = "agreement";
  static const String settings = "settings";
  static const String upgrade = "upgrade";
  static const String success = "success";
  static const String wishlist = "wishlist";

  // Error Messages
  static const String error = "error";

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
  static const String price = "price";

  static const String geminiPrompt = """
Analyze the given image and generate a list of clothing items based on the detected apparel. For each clothing item, provide structured details in JSON format as follows:

[
  {
    "name": "Casual T-Shirt",
    "color": "Blue",
    "colorHexCode": "#0000FF",
    "size": "M",
    "type": "T-Shirt",
    "material": "Cotton",
    "brand": "Nike",
    "model": "AirMax Tee",
    "price": "29.99"
  },
  {
    "name": "Denim Jeans",
    "color": "Black",
    "colorHexCode": "#000000",
    "size": "32",
    "type": "Jeans",
    "material": "Denim",
    "brand": "Levi's",
    "model": "511 Slim Fit",
    "price": "79.99"
  }
]

Price should be in USD and should be approximately price.
If property is unknown, use "unknown".
The response should only contain the JSON array without additional text.
""";

  static const String geminiOptionalPrompt = """
Analyze the given image. Return the result strictly in the following JSON format:

{
  "gender": "male" // or "female"
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

  // Number of Images for Google Search
  static const int numOfImgsFree = 1;
  static const int numOfImgsPlus = 2;
  static const int numOfImgsPro = 3;

  // Report
  static const String reports = "reports";
  static const String reportText = "reportText";
  static const String userId = "userId";
  static const String timestamp = "timestamp";

  // Report Numbers
  static const int maxReportLength = 500;
  static const int minReportLength = 10;
  static const int maxReportLine = 5;

  static const String agreementText = '''
Voux App Agreement

Effective Date: [Insert Date]

1. Introduction
Welcome to Voux! This Agreement outlines the terms and conditions governing your use of the Voux mobile application ("App"). By using the App, you agree to be bound by these terms. If you do not agree, please refrain from using the App.

2. User Responsibilities
- You must be at least 13 years old to use Voux.
- You agree not to misuse the App, including but not limited to unauthorized access, data scraping, or distributing harmful content.
- You are responsible for maintaining the confidentiality of your account information.

3. AI-Based Recommendations
Voux provides clothing recommendations using AI and image recognition technology. While we strive for accuracy, we do not guarantee the exact match or availability of suggested items.

4. Third-Party Links and Stores
The App may provide links to third-party websites and stores. We do not endorse or take responsibility for external sites, their content, or transactions.

5. Privacy & Data Collection
- Voux collects and processes personal data in accordance with our Privacy Policy.
- Images uploaded for analysis are processed for AI-based recommendations but are not stored permanently.

6. Intellectual Property
All content, trademarks, and services within Voux are owned by the App developers or licensors. You may not copy, distribute, or use the App’s content for commercial purposes without permission.

7. Limitation of Liability
Voux is provided "as is" without warranties of any kind. We are not liable for any direct, indirect, or consequential damages arising from your use of the App.

8. Changes to the Agreement
We may update this Agreement from time to time. Continued use of the App after updates constitutes acceptance of the revised terms.

9. Contact Information
For any questions regarding this Agreement, please contact us at [Insert Contact Email].

By using Voux, you acknowledge that you have read, understood, and agree to this Agreement.
''';

  static const String privacyPolicyText = '''
Voux App Privacy Policy

Effective Date: [Insert Date]

1. Introduction
Welcome to Voux! Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal data when you use our mobile application ("App").

2. Information We Collect
- **Personal Information:** When you create an account, we collect your name, email address, and other necessary details.
- **Image Data:** Uploaded images are used for AI-based analysis but are not stored permanently.
- **Usage Data:** We collect information about how you interact with the App, including features accessed and time spent.
- **Device Information:** We may collect information about your device, including model, operating system, and IP address.

3. How We Use Your Information
- To provide AI-powered clothing recommendations.
- To improve App functionality and user experience.
- To analyze trends and enhance security.
- To send important notifications related to your account and App updates.

4. Data Sharing & Third Parties
- We do **not** sell your personal data to third parties.
- We may share data with trusted service providers who assist in running the App (e.g., cloud storage, AI processing services).
- External links and third-party stores may have their own privacy policies. We are not responsible for their practices.

5. Data Security
We implement industry-standard security measures to protect your data. However, no method of transmission over the internet is 100% secure.

6. User Rights
- You have the right to access, update, or delete your personal data.
- You can opt out of certain data collection features in the settings.

7. Children’s Privacy
Voux is not intended for children under 13. We do not knowingly collect data from minors.

8. Changes to Privacy Policy
We may update this Privacy Policy periodically. Continued use of the App after changes signifies your acceptance of the revised terms.

9. Contact Information
For any questions about this Privacy Policy, please contact us at [Insert Contact Email].

By using Voux, you agree to this Privacy Policy.''';

}
