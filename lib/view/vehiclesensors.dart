import 'package:flutter/material.dart';

class VehicleSensorsData extends StatelessWidget {
  final List<dynamic> vehicleSensorsData;
  final String vehicleName;
  const VehicleSensorsData({
    super.key,
    required this.vehicleSensorsData,
    required this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Sensors',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Text(
            vehicleName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: vehicleSensorsData.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  vehicleSensorsData[index]['name'],
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Expanded(
                                  child: Text(
                                    vehicleSensorsData[index]['value'],
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    softWrap: true,
                                    maxLines: 8,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}
