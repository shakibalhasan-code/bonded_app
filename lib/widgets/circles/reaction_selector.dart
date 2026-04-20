import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReactionSelector extends StatefulWidget {
  final Function(String) onReactionSelected;

  const ReactionSelector({Key? key, required this.onReactionSelected}) : super(key: key);

  @override
  State<ReactionSelector> createState() => _ReactionSelectorState();
}

class _ReactionSelectorState extends State<ReactionSelector> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final List<Map<String, dynamic>> reactions = [
    {"type": "like", "emoji": "👍"},
    {"type": "love", "emoji": "❤️", "color": Colors.red},
    {"type": "care", "emoji": "🤗"},
    {"type": "haha", "emoji": "😆"},
    {"type": "wow", "emoji": "😮"},
    {"type": "sad", "emoji": "😢"},
    {"type": "angry", "emoji": "😡"},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
          children: reactions.asMap().entries.map((entry) {
            final index = entry.key;
            final reaction = entry.value;
            
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double delay = index * 0.1;
                final double curvedValue = Curves.elasticOut.transform(
                  (_controller.value - delay).clamp(0.0, 1.0),
                );
                
                return Transform.scale(
                  scale: curvedValue,
                  child: child,
                );
              },
              child: _ReactionItem(
                emoji: reaction["emoji"]!,
                color: reaction["color"],
                onTap: () => widget.onReactionSelected(reaction["type"]!),
              ),
            );
          }).toList(),
        ),
      ),
    ),
);
  }
}

class _ReactionItem extends StatefulWidget {
  final String emoji;
  final Color? color;
  final VoidCallback onTap;

  const _ReactionItem({Key? key, required this.emoji, this.color, required this.onTap}) : super(key: key);

  @override
  State<_ReactionItem> createState() => _ReactionItemState();
}

class _ReactionItemState extends State<_ReactionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanDown: (details) => setState(() => _isHovered = true),
      onPanEnd: (details) => setState(() => _isHovered = false),
      onPanCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        transform: _isHovered ? Matrix4.identity().scaled(1.3) : Matrix4.identity(),
        child: Text(
          widget.emoji,
          style: TextStyle(
            fontSize: 28.sp,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
