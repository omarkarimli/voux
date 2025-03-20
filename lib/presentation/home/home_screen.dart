import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import '../detail/detail_screen.dart';
import '../detail/stacked_avatar_badge.dart';
import 'home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/${Constants.home}';

  void _showImageSourceSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      builder: (BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt_rounded),
                  title: Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet first

                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      BlocProvider.of<HomeBloc>(parentContext).add(AnalyzeImageEvent(pickedFile.path));
                    }
                  },
                ),
                Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outline.withAlpha(50)),
                ListTile(
                  leading: Icon(Icons.photo_rounded),
                  title: Text('Photos'),
                  onTap: () async {
                    Navigator.pop(context);

                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      BlocProvider.of<HomeBloc>(parentContext).add(AnalyzeImageEvent(pickedFile.path));
                    }
                  },
                ),
                SizedBox(height: 16)
              ],
            )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeSuccessState) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  imagePath: state.imagePath,
                  clothingItems: state.clothingItems,
                  gender: state.gender,
                  isChildOrNot: state.isChildOrNot,
                ),
              ),
            );
          } else if (state is HomeFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to analyze image: ${state.errorMessage}")),
            );
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
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                            SizedBox(height: 72),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(height: 1.4),
                                children: const [
                                  TextSpan(text: "Hello 👋 dear\n"),
                                  TextSpan(text: "I hope you are\n"),
                                  TextSpan(
                                      text: "doing well",
                                      style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                          TextSpan(text: "new style", style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Material(
                                      elevation: 1,
                                      shape: const CircleBorder(),
                                      color: Colors.transparent,
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                        child: IconButton(
                                          onPressed: () => _showImageSourceSheet(context),
                                          icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    spacing: 16,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          // Define what happens when the button is pressed
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                                            children: [
                                              TextSpan(
                                                text: "🚀 Unlock ",
                                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                                                children: [
                                                  TextSpan(text: "🏆  "),
                                                  TextSpan(text: "Remaining tasks "),
                                                  TextSpan(
                                                    text: "3/5",
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
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
                                                  onPressed: () {},
                                                  icon: Icon(Icons.arrow_outward_rounded, color: Theme.of(context).colorScheme.onSurface),
                                                ),
                                              )
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
                                                  Text("23 images", style: Theme.of(context).textTheme.headlineMedium),
                                                ],
                                              )
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state is HomeLoadingState) Center(child: const CircularProgressIndicator())
                  ],
                )
            );
          },
        ),
      ),
    );
  }
}
