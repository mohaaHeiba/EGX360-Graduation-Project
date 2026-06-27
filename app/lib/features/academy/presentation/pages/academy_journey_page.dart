import 'dart:ui' as ui;
import 'package:egx/core/helper/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:egx/features/academy/presentation/controllers/academy_controller.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:get_storage/get_storage.dart';

class AcademyJourneyPage extends StatefulWidget {
  const AcademyJourneyPage({super.key});

  @override
  State<AcademyJourneyPage> createState() => _AcademyJourneyPageState();
}

class _AcademyJourneyPageState extends State<AcademyJourneyPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;
  final GlobalKey _academyStatsKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AcademyController>(
      builder: (controller) {
        final modules = controller.modules;
        final globalProgress = controller.globalProgress;

        // Layout Calculations
        final screenWidth = MediaQuery.of(context).size.width;
        double currentTop = 40.0;
        final List<_NodeUI> uiNodes = [];
        final List<Offset> nodeCenters = [];

        const double moduleSize = 100.0;
        const double lessonSize = 60.0; 
        const double verticalSpacing = 80.0; // REDUCED: Bring nodes closer together (140px total distance)
        const double nodeWidth = 160.0; // Guaranteed width for perfect curve alignment

        final double moduleLeft = (screenWidth / 2) - (nodeWidth / 2);
        final double lessonLeftPadding = 16.0; // INCREASED SPREAD: Pushed closer to edges

        bool isLeft = true;
        int globalLessonIndex = 0;

        for (var module in modules) {
          // Main Module Node
          uiNodes.add(_NodeUI(
            isModule: true,
            data: module,
            topOffset: currentTop,
            leftOffset: moduleLeft,
            size: moduleSize,
          ));
          nodeCenters.add(Offset(screenWidth / 2, currentTop + moduleSize / 2));
          currentTop += moduleSize + verticalSpacing;

          // Lesson Sub-Nodes
          for (var lesson in module.lessons) {
            // Organic Offset: Makes the zigzag feel like a natural map, not a robotic grid
            double organicOffset = (globalLessonIndex % 3 == 0) ? 28.0 : (globalLessonIndex % 2 == 0) ? 12.0 : -8.0;
            
            double baseLeft = isLeft ? lessonLeftPadding : (screenWidth - lessonLeftPadding - nodeWidth);
            double finalLeft = baseLeft + (isLeft ? organicOffset : -organicOffset);
            
            // Safety bounds to prevent screen clipping
            if (finalLeft < 4) finalLeft = 4.0;
            if (finalLeft + nodeWidth > screenWidth - 4) finalLeft = screenWidth - nodeWidth - 4.0;

            uiNodes.add(_NodeUI(
              isModule: false,
              data: lesson,
              topOffset: currentTop,
              leftOffset: finalLeft,
              size: lessonSize,
              parentColor: module.color,
            ));
            nodeCenters.add(Offset(finalLeft + (nodeWidth / 2), currentTop + lessonSize / 2));
            
            currentTop += lessonSize + verticalSpacing;
            isLeft = !isLeft; // Alternate sides
            globalLessonIndex++;
          }
        }

        final double totalHeight = currentTop + 80.0;

        // Auto-scroll to active lesson on first load
        if (!_hasScrolled && uiNodes.isNotEmpty) {
          double? targetOffset;
          for (var node in uiNodes) {
            if (!node.isModule) {
              final lesson = node.data as LessonData;
              if (!lesson.isLocked && lesson.progress < 1.0) {
                targetOffset = node.topOffset;
                break;
              }
            }
          }
          if (targetOffset != null) {
            _hasScrolled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                double scrollPosition = targetOffset! - (MediaQuery.of(context).size.height / 2) + 100;
                if (scrollPosition < 0) scrollPosition = 0;
                if (scrollPosition > _scrollController.position.maxScrollExtent) {
                  scrollPosition = _scrollController.position.maxScrollExtent;
                }
                
                _scrollController.animateTo(
                  scrollPosition,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                );
              }
            });
          }
        }

        return ShowCaseWidget(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bool hasSeenWalkthrough = GetStorage().read('hasSeenAcademyWalkthrough') ?? false;
              if (!hasSeenWalkthrough) {
                GetStorage().write('hasSeenAcademyWalkthrough', true);
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (context.mounted) {
                    ShowCaseWidget.of(context).startShowCase([
                      _academyStatsKey,
                    ]);
                  }
                });
              }
            });

            return Scaffold(
              backgroundColor: context.background, // Dynamic background
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: AppBar(
              toolbarHeight: 80,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leadingWidth: 80,
              leading: Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: context.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.onSurface.withOpacity(0.1),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: context.onSurface,
                      size: 18,
                    ),
                  ),
                ),
              ),
              centerTitle: false,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Academy",
                  style: TextStyle(
                    color: context.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 1,
                  ),
                ),
              ),
              actions: [
                Showcase(
                  key: _academyStatsKey,
                  description: "Learn & Earn. 🏆 Complete lessons to gain XP and maintain your daily learning streak!",
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.onSurface.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "${controller.streakCount.value}",
                        style: TextStyle(color: context.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.bolt, color: Colors.amber, size: 20),
                      const SizedBox(width: 2),
                      Text(
                        "${controller.xpCount.value} XP",
                        style: TextStyle(color: context.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (controller.showXpAnimation.value) ...[
                        const SizedBox(width: 4),
                        const Text(
                          "+50",
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              // Premium Purple Glow (بنفسجي)
              Positioned(
                right: -100,
                top: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purpleAccent.withOpacity(0.2), // INTENSIFIED
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.05), // Reduced opacity
                        blurRadius: 100, // Reduced blur
                        spreadRadius: 20, // Reduced spread
                      ),
                    ],
                  ),
                ),
              ),
              
              Column(
                children: [
                  // 4. Global Progress Bar (Restored without Showcase)
                  Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: context.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: globalProgress,
                        backgroundColor: context.onSurface.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(context.primary),
                      ),
                    ),
                  ),
                  
                  // Scrollable Journey Path
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // if (controller.getNextLesson() != null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 16, bottom: 24),
                          //     child: _buildResumeBanner(context, controller),
                          //   ),
                          SizedBox(
                            width: double.infinity,
                        height: totalHeight,
                        child: Stack(
                          children: [
                            // 5. Path Rendering Fix (Strictly at the bottom of the Stack)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _JourneyPathPainter(
                                  nodeCenters: nodeCenters,
                                  pathColor: context.onSurface.withOpacity(0.15),
                                ),
                              ),
                            ),
                            
                            // Nodes (Top Layer)
                            ...uiNodes.map((node) {
                              return Positioned(
                                top: node.topOffset,
                                left: node.leftOffset,
                                width: nodeWidth, // Explicit width matches painter math perfectly
                                child: node.isModule 
                                  ? _buildModuleNode(context, node.data as ModuleData, node.size)
                                  : _buildLessonNode(context, node.data as LessonData, node.size, node.parentColor!),
                              );
                            }),
                          ],
                        ),
                      ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ],
            ),
          );
        },
      );
    },
  );
}

  Widget _buildResumeBanner(BuildContext context, AcademyController controller) {
    final lesson = controller.getNextLesson()!;
    final color = controller.getModuleColorForLesson(lesson.id) ?? Colors.purpleAccent;

    return GestureDetector(
      onTap: () {
        Get.to(() => LessonDetailsPage(lesson: lesson, parentColor: color));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "RESUME LEARNING",
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.title,
                    style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }

  // Large Main Node UI
  Widget _buildModuleNode(BuildContext context, ModuleData module, double size) {
    final bool isLocked = module.lessons.isNotEmpty && module.lessons.first.isLocked;
    final Color activeColor = isLocked ? context.onSurface.withOpacity(0.3) : module.color;
    final Color borderColor = isLocked ? context.onSurface.withOpacity(0.1) : module.color;
    final IconData iconData = isLocked ? Icons.lock_rounded : module.icon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: context.surface, 
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2), 
            boxShadow: isLocked ? [] : [
              BoxShadow(
                color: module.color.withOpacity(0.3), 
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(iconData, size: 48, color: activeColor),
        ),
        const SizedBox(height: 12),
        // 2. Color Contrast & Typography
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: context.surface, 
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.background.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 0,
              )
            ]
          ),
          child: Column(
            children: [
              Text(
                module.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.onSurface, 
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                module.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isLocked ? context.onSurface.withOpacity(0.3) : context.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // 1. Node States (Crucial Gamification)
  Widget _buildLessonNode(BuildContext context, LessonData lesson, double size, Color parentColor) {
    final bool isCompleted = lesson.progress == 1.0;
    final bool isLocked = lesson.isLocked;
    final bool isActive = !isLocked && !isCompleted; 

    // Locked styling
    final Color innerColor = isLocked ? context.surface : context.surface;
    final Color borderColor = isLocked ? context.onSurface.withOpacity(0.2) : parentColor;
    final Color iconColor = isLocked ? context.onSurface.withOpacity(0.3) : parentColor;
    final IconData iconData = isLocked ? Icons.lock_rounded : lesson.icon;
    
    // Glow logic
    List<BoxShadow> shadows = [];
    if (isActive || isCompleted) {
      shadows = [
        BoxShadow(
          color: parentColor.withOpacity(0.3), 
          blurRadius: 8, 
          spreadRadius: 0, 
        ),
      ];
    }
    
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          Get.to(() => LessonDetailsPage(lesson: lesson, parentColor: parentColor));
        } else {
           Get.snackbar(
             "Lesson Locked", 
             "Complete previous lessons to unlock.",
             snackPosition: SnackPosition.BOTTOM,
             margin: const EdgeInsets.all(16),
           );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none, // Allow checkmark to sit on edge
            alignment: Alignment.center,
            children: [
              // Circular Progress Indicator
              if (isActive || isCompleted)
                SizedBox(
                  width: size + 8,
                  height: size + 8,
                  child: CircularProgressIndicator(
                    value: isCompleted ? 1.0 : lesson.progress,
                    strokeWidth: 2, // Smaller stroke width for success
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.amber : parentColor,
                    ),
                  ),
                ),
                
              // Inner Bubble
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: innerColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor, 
                    width: 2, // Less border
                  ),
                  boxShadow: shadows,
                ),
                child: Icon(
                  iconData,
                  size: 28,
                  color: iconColor,
                ),
              ),
              
              // Absolute positioned checkmark for Completed State
              if (isCompleted)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.background, width: 1.5), // Smaller border for success
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.white, weight: 800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: context.surface, 
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: context.background.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 0,
                )
              ]
            ),
            child: Text(
              lesson.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Internal UI layout model
class _NodeUI {
  final bool isModule;
  final dynamic data;
  final double topOffset;
  final double leftOffset;
  final double size;
  final Color? parentColor;

  _NodeUI({
    required this.isModule,
    required this.data,
    required this.topOffset,
    required this.leftOffset,
    required this.size,
    this.parentColor,
  });
}

// 5. Path Rendering Fix
class _JourneyPathPainter extends CustomPainter {
  final List<Offset> nodeCenters;
  final Color pathColor;

  _JourneyPathPainter({
    required this.nodeCenters,
    required this.pathColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCenters.length < 2) return;

    final paint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (int i = 0; i < nodeCenters.length - 1; i++) {
      final p1 = nodeCenters[i];
      final p2 = nodeCenters[i + 1];

      // Shift line start slightly lower (below text box) and end slightly higher (above next node)
      final startY = p1.dy + 50.0;
      final endY = p2.dy - 35.0;
      final verticalDist = endY - startY;
      
      // Move to the shifted start point instead of the exact center
      if (i == 0) {
        path.moveTo(p1.dx, startY);
      } else {
        path.lineTo(p1.dx, startY);
      }
      
      path.cubicTo(
        p1.dx, startY + (verticalDist / 2), 
        p2.dx, endY - (verticalDist / 2), 
        p2.dx, endY
      );
    }

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 14.0;
    const double dashSpace = 10.0;
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyPathPainter oldDelegate) {
    return oldDelegate.nodeCenters.length != nodeCenters.length;
  }
}

// Lesson Details Page
class LessonDetailsPage extends StatelessWidget {
  final LessonData lesson;
  final Color parentColor;

  const LessonDetailsPage({
    super.key,
    required this.lesson,
    required this.parentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 80,
          leading: Center(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: context.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.onSurface.withValues(alpha: 0.1),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: context.onSurface,
                  size: 18,
                ),
              ),
            ),
          ),
          title: Text(
            lesson.title,
            style: TextStyle(
              color: context.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Premium Purple Glow (بنفسجي)
          Positioned(
            right: -100,
            top: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.02), // Much less neon
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Overview",
                          style: TextStyle(
                            color: parentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (lesson.content.isNotEmpty)
                          ..._buildContentWithImage(lesson, context)
                        else
                          Text(
                            "Welcome to the ${lesson.title} lesson. Here you will learn everything you need to master this topic.",
                            style: TextStyle(
                              color: context.onSurface.withOpacity(0.9),
                              fontSize: 18,
                              height: 1.6,
                            ),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: parentColor,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Get.back(); // Pop the lesson page first
                              final controller = Get.find<AcademyController>();
                              controller.completeLesson(lesson.id); // Trigger logic & snackbar on parent page
                            },
                            child: const Text(
                              "Complete Lesson",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContentWithImage(LessonData lesson, BuildContext context) {
    final style = TextStyle(
      color: context.onSurface.withOpacity(0.9),
      fontSize: 18,
      height: 1.6,
    );

    if (!lesson.content.contains('[ 🖼️ IMAGE PLACEHOLDER ]')) {
      return [Text(lesson.content, style: style)];
    }

    final parts = lesson.content.split('[ 🖼️ IMAGE PLACEHOLDER ]');
    final widgets = <Widget>[];

    if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
      widgets.add(Text(parts[0].trim(), style: style));
    }

    if (lesson.imagePath != null) {
      widgets.add(const SizedBox(height: 24));
      widgets.add(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: parentColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              lesson.imagePath!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 24));
    } else {
      // Fallback if image isn't generated yet
      widgets.add(const SizedBox(height: 24));
      widgets.add(
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: context.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: parentColor.withOpacity(0.3)),
          ),
          child: Center(
            child: Icon(Icons.image_outlined, size: 48, color: parentColor.withOpacity(0.5)),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 24));
    }

    if (parts.length > 1 && parts[1].trim().isNotEmpty) {
      widgets.add(Text(parts[1].trim(), style: style));
    }

    return widgets;
  }
}
