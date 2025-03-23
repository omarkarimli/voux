import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voux/utils/extensions.dart';
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

  List<PlanModel> plans = [
    PlanModel(name: Constants.freePlan, price: 9.99, features: ["Feature 1", "Feature 2", "Feature 3"], isCurrentPlan: false),
    PlanModel(name: Constants.plusPlan, price: 19.99, features: ["Feature 1", "Feature 2", "Feature 3", "Feature 4"], isCurrentPlan: false),
    PlanModel(name: Constants.proPlan, price: 29.99, features: ["Feature 1", "Feature 2", "Feature 3", "Feature 4", "Feature 5"], isCurrentPlan: false),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPlanName = prefs.getString(Constants.currentPlan) ?? Constants.freePlan;
      _selectedPlan = plans.firstWhere((plan) => plan.name == _currentPlanName, orElse: () => plans[0]);

      // Set the isCurrentPlan flag for the selected plan
      plans = plans.map((plan) {
        return plan.copyWith(isCurrentPlan: plan.name == _currentPlanName);
      }).toList();

      print("Current Plan Name: $_currentPlanName");
      print("Selected Plan: ${_selectedPlan?.name} ${_selectedPlan?.price}");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPlanName == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Padding(
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
                const SizedBox(height: 12),
                Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        return _buildPlanCard(plans[index]);
                      },
                    )
                )
              ],
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

  Future<void> _savePlanPreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.currentPlan, value);
  }

  Widget _buildPlanCard(PlanModel plan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: plan.name == _selectedPlan?.name
            ? BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 2)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              plan.name.replaceAll(Constants.plan, "").trim().capitalizeFirst(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "\$${plan.price.toStringAsFixed(2)} / month",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),

            // Features
            ...plan.features.map((feature) => Text(
              "✓  $feature",
              style: Theme.of(context).textTheme.bodyMedium,
            )),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: plan.name == _selectedPlan?.name ? null : () async {
                  await _savePlanPreference(plan.name);
                  setState(() {
                    _currentPlanName = plan.name;
                    _selectedPlan = plan;
                    // Update the isCurrentPlan flag for all plans
                    plans = plans.map((p) => p.copyWith(isCurrentPlan: p.name == plan.name)).toList();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: plan.name == _selectedPlan?.name
                    ? Text(
                  "Current Plan",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
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
}
