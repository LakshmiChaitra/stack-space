part of 'app.dart';

class DeveloperScene extends StatelessWidget {
  final int completed, total;
  const DeveloperScene({
    super.key,
    required this.completed,
    required this.total,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 270,
    child: Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: DeveloperGridPainter(night: isNight(context)),
          ),
        ),
        Positioned(
          left: 4,
          right: 13,
          top: 22,
          child: Transform.rotate(
            angle: -.045,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xff282832),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xff53525e)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .15),
                    blurRadius: 25,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    color: const Color(0xff34343e),
                    child: Row(
                      children: [
                        ...const [
                          Color(0xffd5aaa4),
                          Color(0xffdfce9c),
                          Color(0xffa7c5af),
                        ].map(
                          (color) => Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'workspace.dart',
                          style: TextStyle(
                            color: Color(0xffb7b4c5),
                            fontSize: 9,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.code,
                          size: 13,
                          color: Color(0xffb7b4c5),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '// less chaos. more building.',
                          style: TextStyle(
                            color: Color(0xff8d9a94),
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'final sprint = Workspace(',
                          style: TextStyle(
                            color: Color(0xffd6c4ec),
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.8,
                          ),
                        ),
                        Text(
                          '  tasks: $total,\n  completed: $completed,',
                          style: const TextStyle(
                            color: Color(0xffacd5c4),
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.8,
                          ),
                        ),
                        const Text(
                          '  next: "build something great",',
                          style: TextStyle(
                            color: Color(0xffe1c7a4),
                            fontFamily: 'monospace',
                            fontSize: 10,
                            height: 1.8,
                          ),
                        ),
                        const Text(
                          ');',
                          style: TextStyle(
                            color: Color(0xffd6c4ec),
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 190,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: surface(context),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.data_usage_rounded,
                      color: readableAccent(context, violet),
                      size: 15,
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'SPRINT PROGRESS',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${total == 0 ? 0 : (completed / total * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$completed / $total done',
                      style: const TextStyle(color: muted, fontSize: 9),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    minHeight: 4,
                    color: readableAccent(context, violet),
                    backgroundColor: violet.withValues(alpha: .1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class DeveloperGridPainter extends CustomPainter {
  final bool night;
  DeveloperGridPainter({required this.night});
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = (night ? Colors.white : const Color(0xff5e746a)).withValues(
        alpha: .1,
      );
    for (double x = 5; x < size.width; x += 22) {
      for (double y = 0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), .8, grid);
      }
    }
    void cube(Offset c, double r, Color color) {
      final top = Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy - r * .45)
        ..lineTo(c.dx, c.dy)
        ..lineTo(c.dx - r, c.dy - r * .45)
        ..close();
      final left = Path()
        ..moveTo(c.dx - r, c.dy - r * .45)
        ..lineTo(c.dx, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy + r * .5)
        ..close();
      final right = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + r, c.dy - r * .45)
        ..lineTo(c.dx + r, c.dy + r * .5)
        ..lineTo(c.dx, c.dy + r)
        ..close();
      canvas.drawPath(top, Paint()..color = color);
      canvas.drawPath(
        left,
        Paint()..color = Color.lerp(color, const Color(0xff554c65), .15)!,
      );
      canvas.drawPath(
        right,
        Paint()..color = Color.lerp(color, const Color(0xff554c65), .32)!,
      );
    }

    cube(
      Offset(size.width * .12, size.height * .83),
      24,
      const Color(0xffb9c9c0),
    );
    cube(
      Offset(size.width * .21, size.height * .91),
      17,
      const Color(0xffcbbbdc),
    );
  }

  @override
  bool shouldRepaint(DeveloperGridPainter old) => old.night != night;
}
