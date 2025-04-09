import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:uuid/uuid.dart';
import 'package:voux/presentation/success/success_screen.dart';
import '../home/home_screen.dart';
import '../../models/subscription_payment_model.dart';
import '../../models/user_model.dart';
import '../../utils/extensions.dart';
import '../../models/plan_model.dart';
import '../../utils/constants.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  static const routeName = '/${Constants.upgrade}';

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  String? _currentPlanName;
  PlanModel? _selectedPlan;
  late InAppPurchase _inAppPurchase;

  List<PlanModel> plans = [
    PlanModel(name: Constants.proPlan, price: 29.99, features: ["Feature 1", "Feature 2", "Feature 3", "Feature 4", "Feature 5"], isCurrentPlan: false),
    PlanModel(name: Constants.plusPlan, price: 19.99, features: ["Feature 1", "Feature 2", "Feature 3", "Feature 4"], isCurrentPlan: false),
    PlanModel(name: Constants.freePlan, price: 0.00, features: ["Feature 1", "Feature 2", "Feature 3"], isCurrentPlan: false)
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Initialize in-app purchase
    _inAppPurchase = InAppPurchase.instance;

    // Listen to purchases globally
    _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdate);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPlanName == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
            child: CupertinoActivityIndicator(
                radius: 20.0,
                color: Theme.of(context).colorScheme.primary
            )
        )
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: MediaQuery.of(context).padding.top + 72,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to access',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: plans.length,
                          itemBuilder: (context, index) {
                            return _buildPlanCard(plans[index]);
                          },
                        ),
                        const SizedBox(height: 32)
                      ],
                    )
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface)
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlanCard(PlanModel plan) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: plan.name == _selectedPlan?.name
            ? BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(50), width: 3)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(Constants.cornerRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              plan.name.replaceAll(Constants.plan, "").trim().capitalizeFirst(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
                children: [
                  TextSpan(text: "\$${plan.price.toStringAsFixed(2)}"),
                  TextSpan(
                    text: " / month",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...plan.features.map(
                  (feature) => Text(
                "✓  $feature",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: plan.name == _selectedPlan?.name
                    ? null
                    : () => _showConfirmationDialog(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.cornerRadiusSmall),
                  ),
                ),
                child: plan.name == _selectedPlan?.name
                    ? Text(
                  "Current Plan",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(50),
                  ),
                )
                    : Text(
                  "Select",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _loadSettings() async {
    final user = await _getUserFromFirestore();

    if (!mounted) return; // Prevents setState() being called on disposed widget

    setState(() {
      _currentPlanName = user?.currentSubscriptionStatus ?? Constants.freePlan;
      _selectedPlan = plans.firstWhere((plan) => plan.name == _currentPlanName, orElse: () => plans[0]);

      plans = plans.map((plan) {
        return plan.copyWith(isCurrentPlan: plan.name == _currentPlanName);
      }).toList();
    });

    print("Current Plan Name: $_currentPlanName");
    print("Selected Plan: ${_selectedPlan?.name} ${_selectedPlan?.price}");
  }

  void _showConfirmationDialog(PlanModel plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Purchase"),
          content: Text("Are you sure you want to upgrade to ${plan.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _purchasePlan(plan);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _purchasePlan(PlanModel plan) async {
    final bool available = await _inAppPurchase.isAvailable();

    if (!available) {
      context.showCustomSnackBar(Constants.error, "In-app purchases are not available.");
      return;
    }

    // Replace with your actual subscription product IDs from Google Play and App Store
    final Set<String> kProductIds = {
      Constants.freePlan,
      Constants.plusPlan,
      Constants.proPlan
    };

    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(kProductIds);

    if (response.notFoundIDs.isNotEmpty) {
      context.showCustomSnackBar(Constants.error, "Subscription product not found.");
      return;
    }

    final ProductDetails? productDetails = response.productDetails.firstWhereOrNull((p) => p.id == plan.name);

    if (productDetails == null) {
      context.showCustomSnackBar(Constants.error, "Subscription plan ${plan.name} not found.");
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);

    // Listen to purchase updates
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) async {
      for (var purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {

          // Successful purchase
          await Future.wait([
            _inAppPurchase.completePurchase(purchaseDetails),
            _updateUserInFirestore(plan)
          ]);
        }
      }
    });
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        PlanModel? purchasedPlan = plans.firstWhereOrNull((plan) => plan.name == purchaseDetails.productID);
        if (purchasedPlan != null) {
          await _updateUserInFirestore(purchasedPlan);
          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
        }
      }
    }
  }

  Future<void> _updateUserInFirestore(PlanModel plan) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection(Constants.users).doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      // Fetch existing subscriptions list from Firestore
      final existingSubscriptions = (docSnapshot.data()?[Constants.subscriptions] as List<dynamic>?)
          ?.map((sub) => SubscriptionPaymentModel.fromMap(sub))
          .toList() ??
          [];

      // Create a new subscription
      Timestamp now = Timestamp.now();
      SubscriptionPaymentModel newSubscription = SubscriptionPaymentModel(
        id: Uuid().v4(),
        name: plan.name,
        purchaseTime: now,
        endTime: Timestamp.fromDate(now.toDate().add(Duration(days: 30))), // Add 30 days for the subscription period
      );

      // Add the new subscription to the existing subscriptions list
      existingSubscriptions.add(newSubscription);

      int newAnalysisLimit = (plan.name == Constants.proPlan)
          ? Constants.analysisLimitCountPro
          : (plan.name == Constants.plusPlan)
          ? Constants.analysisLimitCountPlus
          : Constants.analysisLimitCountFree;

      // Create an updated user object with the modified subscriptions list
      UserModel updatedUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? Constants.unknown,
        email: user.email ?? '',
        createdAt: docSnapshot.data()?[Constants.createdAt] ?? Timestamp.now(),
        currentSubscriptionStatus: plan.name,
        analysisLimit: newAnalysisLimit,
        currentAnalysisCount: 0,
        subscriptions: existingSubscriptions,
      );

      // Update the user document in Firestore with the updated subscriptions list
      await Future.wait([
        userDoc.update(updatedUser.toMap()),
      ]);

      setState(() {
        _currentPlanName = plan.name;
        _selectedPlan = plan;
        plans = plans.map((p) => p.copyWith(isCurrentPlan: p.name == plan.name)).toList();
      });

      context.showCustomSnackBar(Constants.success, "Successfully subscribed to ${plan.name}.");

      // Go Success and remove UpgradeScreen from the stack
      Navigator.pushNamedAndRemoveUntil(context, SuccessScreen.routeName, (route) => false);
    }
  }

  Future<UserModel?> _getUserFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null; // Return null if no user is signed in

    final userDoc = FirebaseFirestore.instance.collection(Constants.users).doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      return UserModel.fromFirestore(docSnapshot.data()!);
    }

    return null; // Return null if the document doesn't exist
  }
}
