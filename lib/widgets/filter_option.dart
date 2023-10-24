import 'package:flutter/material.dart';

class FilterOption extends StatelessWidget {
  final String status;
  final int statusCount;
  final Function(String) onTap;

  const FilterOption({
    required this.status,
    required this.onTap,
    required this.statusCount,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor = Colors.black;
    Color? backgroundColortwo = Colors.black;
    if (status == 'all') {
      backgroundColor = Colors.brown;
      backgroundColortwo = Colors.brown[100];
    } else if (status == 'running') {
      backgroundColor = Colors.green;
      backgroundColortwo = Colors.green[200];
    } else if (status == 'stopped') {
      backgroundColor = Colors.red;
      backgroundColortwo = Colors.red[200];
    } else if (status == 'idle') {
      backgroundColor = Colors.orangeAccent;
      backgroundColortwo = Colors.orangeAccent[100];
    } else if (status == 'offline') {
      backgroundColor = Colors.blue;
      backgroundColortwo = Colors.blue[100];
    } else if (status == 'nodata') {
      backgroundColor = Colors.grey;
      backgroundColortwo = Colors.grey[300];
    } else if (status == 'expired') {
      backgroundColor = const Color.fromARGB(255, 138, 13, 4);
      backgroundColortwo = const Color.fromARGB(255, 241, 194, 191);
    }

    return Card(
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () => onTap(status),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: backgroundColortwo!,
                    width: 5.0,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Center(
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              statusCount.toString(),
              style: const TextStyle(fontSize: 8),
            ),
            Text(
              status,
              style: const TextStyle(fontSize: 8),
            )
          ],
        ),
      ),
    );
  }
}
