import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analiz'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('sales_summary').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Herhangi bir satış yok.'),
            );
          }

          // Bugünün tarihini al
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          // Bugün yapılan toplam satış miktarını hesapla
          double totalSalesToday = 0.0;
          for (DocumentSnapshot document in snapshot.data!.docs) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Timestamp createdAt = data['createdAt'] as Timestamp;
            DateTime createdAtDateTime = createdAt.toDate();
            if (createdAtDateTime.year == today.year && createdAtDateTime.month == today.month && createdAtDateTime.day == today.day) {
              totalSalesToday += data['totalSales'];
            }
          }

          // sales_summary koleksiyonundaki tüm belgelerin totalSales alanlarını topla
          double totalSalesOverall = 0.0;
          for (DocumentSnapshot document in snapshot.data!.docs) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            totalSalesOverall += data['totalSales'];
          }

          // Grafik için örnek veri listesi
          List<double> sampleData = [10, 20, 15, 30, 25]; // Örnek olarak kullanılabilir, gerçek verilerinizi buraya ekleyin

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Text('Bugün Yapılan Satışlar'),
                  subtitle: Text('Toplam: $totalSalesToday'),
                ),
                ListTile(
                  title: Text('Toplam Satışlar'),
                  subtitle: Text('Toplam: $totalSalesOverall'),
                ),
                _buildLineChart(sampleData),
              ],
            ),
          );
        },
      ),
    );
  }

  LineChartData _createLineChartData(List<double> data) {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value);
          }).toList(),
          isCurved: true,
          colors: [Colors.blue],
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            return value.toString();
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            return value.toString();
          },
        ),
      ),
      gridData: FlGridData(show: true),
    );
  }

  Widget _buildLineChart(List<double> data) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: LineChart(_createLineChartData(data)),
    );
  }
}
