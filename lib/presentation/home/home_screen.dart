import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voux/utils/extensions.dart';
import '../../models/user_model.dart';
import '../settings/settings_screen.dart';
import '../upgrade/upgrade_screen.dart';
import '../../utils/constants.dart';
import '../anim/anim_transition_route.dart';
import '../detail/detail_screen.dart';
import '../reusables/stacked_avatar_badge.dart';
import 'home_bloc.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/${Constants.home}';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User? user;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<HomeBloc>().add(FetchUserEvent(user!.uid)); // Fetch user data
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (user != null) {
      // Fetch user data again after coming back from another screen
      context.read<HomeBloc>().add(FetchUserEvent(user!.uid));
    }
  }

  @override
  void dispose() {
    super.dispose();
    context.read<HomeBloc>().close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeUserSuccessState) {
            // Assign the fetched user model
            userModel = state.user;
          }

          if (state is HomeSuccessState) {
            // Update user in Firestore if analysis is successful
            if (userModel != null) {
              FirebaseFirestore.instance
                  .collection(Constants.users)
                  .doc(user!.uid)
                  .update({
                Constants.currentAnalysisCount: userModel!.currentAnalysisCount + 1,
              });
            }

            // Navigate to DetailScreen
            Navigator.push(
              context,
              animTransitionRoute(
                DetailScreen(
                  imagePath: state.imagePath,
                  clothingItems: state.clothingItems,
                  gender: state.gender,
                  isChildOrNot: state.isChildOrNot,
                ),
              ),
            ).then((_) {
              // Refresh the user data after returning
              context.read<HomeBloc>().add(FetchUserEvent(user!.uid));
            });
          } else if (state is HomeFailureState) {
            context.showCustomSnackBar(Constants.error, "Error: ${state.errorMessage}");
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state is HomeLoadingState,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/abstract_1.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: MediaQuery.of(context).padding.top + 16,
                        bottom: 64,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Settings
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.onSurface),
                                onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                              ),
                            ),
                          ),
                          SizedBox(height: 72),
                          // Hello 👋 dear
                          FittedBox(
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(height: 1.4),
                                children: const [
                                  TextSpan(text: "Hello 👋 dear\n"),
                                  TextSpan(text: "I hope you are\n"),
                                  TextSpan(
                                      text: "doing well",
                                      style: TextStyle(fontWeight: FontWeight.w600)
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Let's find new style
                          Card(
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            clipBehavior: Clip.antiAlias,
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      children: const [
                                        TextSpan(text: "Let's find "),
                                        TextSpan(text: "new style", style: TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Material(
                                    elevation: 1,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                      child: IconButton(
                                        onPressed: () {
                                          if (userModel != null && userModel!.currentAnalysisCount < userModel!.analysisLimit) {
                                            _showImageSourceSheet(context);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("You have reached the limit. Upgrade to continue.")),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Unlock Premium & Explored
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 12,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, UpgradeScreen.routeName);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                        children: [
                                          TextSpan(
                                            text: "🚀 Unlock ",
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(text: "Premium"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Define what happens when the button is pressed
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                                            children: [
                                              TextSpan(text: "🏆  Explored ", style: const TextStyle(fontWeight: FontWeight.w600)),
                                              TextSpan(
                                                text: "${userModel?.currentAnalysisCount}/${userModel?.analysisLimit}"
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            clipBehavior: Clip.antiAlias,
                            elevation: 3,
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: -12,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/images/abstract_2.png',
                                    width: 192,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          StackedAvatarBadge(profileImage: "assets/images/woman_avatar.png", badgeImage: "assets/images/ai_search.png", badgeSize: 32),
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Theme.of(context).colorScheme.surface,
                                            child: IconButton(
                                              onPressed: () {
                                                Navigator.pushNamed(context, UpgradeScreen.routeName);
                                              },
                                              icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onSurface),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 22),
                                      Padding(
                                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Total explored", style: Theme.of(context).textTheme.bodyLarge),
                                            SizedBox(height: 4),
                                            Text("${userModel?.currentAnalysisCount} images", style: Theme.of(context).textTheme.headlineMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state is HomeLoadingState)
                    Center(
                      child: CupertinoActivityIndicator(
                          radius: 20.0,
                          color: Theme.of(context).colorScheme.primary
                      )
                    ),
                ],
              ),
            );
          },
        ),
      )
    );
  }

  void _showImageSourceSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 8,
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSurface),
                title: Text('Camera', style: Theme.of(context).textTheme.bodyLarge),
                onTap: () async {
                  Navigator.pop(context);

                  // Source camera
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    BlocProvider.of<HomeBloc>(parentContext).add(AnalyzeImageEvent(pickedFile.path));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo, color: Theme.of(context).colorScheme.onSurface),
                title: Text('Gallery', style: Theme.of(context).textTheme.bodyLarge),
                onTap: () async {
                  Navigator.pop(context);

                  // Source gallery
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    BlocProvider.of<HomeBloc>(parentContext).add(AnalyzeImageEvent(pickedFile.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

