import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Enerji Üretim Görünümü', theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: const Color(0xFFF0F8FF)), home: PlantStatusView());
  }
}

class PlantStatusView extends StatefulWidget {
  const PlantStatusView({super.key});

  @override
  PlantStatusViewState createState() => PlantStatusViewState();
}

class PlantStatusViewState extends State<PlantStatusView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enerji Üretim Santrali'), backgroundColor: Colors.green[700], elevation: 0),
      body: SingleChildScrollView(child: Column(children: [_buildStatusCard(), SizedBox(height: 20), _buildEnergyProductionAnimation(), SizedBox(height: 20), _buildStatsGrid()])),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Üretim Durumu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [Icon(Icons.check_circle, color: Colors.green, size: 16), SizedBox(width: 4), Text('Aktif', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold))],
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text('Günlük Üretim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              SizedBox(height: 8),
              Text('24.5 MWh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyProductionAnimation() {
    return Container(
      height: 300,
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: CustomPaint(painter: EnergyProductionPainter(_animation)),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text('Sistem İstatistikleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStatItem('Kapasite', '85%', Icons.battery_charging_full), _buildStatItem('Sıcaklık', '42°C', Icons.thermostat)]),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStatItem('Verimlilik', '78%', Icons.show_chart), _buildStatItem('Çalışma Süresi', '18s', Icons.timer)]),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue[700]),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
      ],
    );
  }
}

class EnergyProductionPainter extends CustomPainter {
  final Animation<double> animation;

  EnergyProductionPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final buildingWidth = size.width * 0.4;
    final buildingHeight = size.height * 0.6;
    final buildingLeft = (size.width - buildingWidth) / 2;
    final buildingTop = size.height * 0.1;

    // Binayı çiz
    final buildingPaint =
        Paint()
          ..color = Colors.grey[700]!
          ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(buildingLeft, buildingTop, buildingWidth, buildingHeight), buildingPaint);

    // Bina detayları
    final detailPaint =
        Paint()
          ..color = Colors.grey[800]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Bina çatısı
    final roofPath = Path();
    roofPath.moveTo(buildingLeft - 10, buildingTop);
    roofPath.lineTo(buildingLeft + buildingWidth / 2, buildingTop - 30);
    roofPath.lineTo(buildingLeft + buildingWidth + 10, buildingTop);
    roofPath.close();
    canvas.drawPath(roofPath, buildingPaint);
    canvas.drawPath(roofPath, detailPaint);

    // Pencere çiz
    final windowPaint =
        Paint()
          ..color = Colors.yellow[700]!
          ..style = PaintingStyle.fill;

    final windowWidth = buildingWidth * 0.2;
    final windowHeight = buildingHeight * 0.1;
    final windowSpacing = buildingHeight * 0.05;

    for (double i = 1; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(buildingLeft + buildingWidth * 0.2, buildingTop + windowSpacing * i + windowHeight * (i - 1), windowWidth, windowHeight), windowPaint);
    }

    // Kapı çiz
    final doorPaint =
        Paint()
          ..color = Colors.brown[700]!
          ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(buildingLeft + buildingWidth * 0.4, buildingTop + buildingHeight * 0.7, buildingWidth * 0.2, buildingHeight * 0.3), doorPaint);

    // Enerji kablosunu çiz
    final cablePaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final cableStartX = buildingLeft + buildingWidth;
    final cableStartY = buildingTop + buildingHeight * 0.5;
    final cableEndX = size.width * 0.9;
    final cableEndY = size.height * 0.3;

    final path = Path();
    path.moveTo(cableStartX, cableStartY);
    path.cubicTo(cableStartX + 50, cableStartY, cableEndX - 50, cableEndY, cableEndX, cableEndY);

    canvas.drawPath(path, cablePaint);

    // Enerji akışını çiz (animasyonlu)
    final energyPaint =
        Paint()
          ..color = Colors.blue[400]!
          ..style = PaintingStyle.fill;

    final progress = animation.value;
    final energyPath = Path();

    // Enerji parçacıklarını çiz
    for (double i = 0; i < 1; i += 0.1) {
      final t = (i + progress) % 1.0;
      final metric = path.computeMetrics().first;
      final offset = metric.getTangentForOffset(metric.length * t)?.position;

      if (offset != null) {
        // Enerji parçacıklarını daha belirgin hale getir
        canvas.drawCircle(offset, 7, energyPaint);
        canvas.drawCircle(
          offset,
          5,
          Paint()
            ..color = Colors.yellow
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Enerji alıcısını çiz (şehir veya ev)
    final receiverPaint =
        Paint()
          ..color = Colors.green[700]!
          ..style = PaintingStyle.fill;

    final housePath = Path();
    housePath.moveTo(cableEndX - 20, cableEndY);
    housePath.lineTo(cableEndX - 30, cableEndY - 15);
    housePath.lineTo(cableEndX - 10, cableEndY - 15);
    housePath.lineTo(cableEndX, cableEndY);
    housePath.close();

    canvas.drawPath(housePath, receiverPaint);
    canvas.drawRect(Rect.fromLTWH(cableEndX - 25, cableEndY, 10, 10), Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
