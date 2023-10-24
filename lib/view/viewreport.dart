import 'package:autotelematic_new_app/cubit/get_reports_cubit.dart';
import 'package:autotelematic_new_app/model/viewreportinitialdata.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewReportsScreen extends StatefulWidget {
  final ViewReportIntialData viewReportIntialData;
  const ViewReportsScreen({super.key, required this.viewReportIntialData});

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  @override
  void initState() {
    context
        .read<GetReportsCubit>()
        .fetchReportsfromAPI(widget.viewReportIntialData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GetReportsCubit, GetReportsState>(
        builder: (context, state) {
          if (state is GetReportsLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppTheme.loadingImage,
                  const SizedBox(
                    height: 5,
                  ),
                  const Text('Loading...')
                ],
              ),
            );
          }
          if (state is GetReportsError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is GetReportsLoadingComplete) {
            return Stack(children: [
              SfPdfViewer.network(
                state.getReportModel.url!,
                pageLayoutMode: PdfPageLayoutMode.continuous,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(
                        height: 150,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          heroTag: UniqueKey(),
                          mini: true,
                          child:
                              const Icon(Icons.download, color: Colors.black54),
                          onPressed: () {
                            CommonUtils.launchURLBrowser(
                                state.getReportModel.url!);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          heroTag: UniqueKey(),
                          mini: true,
                          child: const Icon(Icons.share, color: Colors.black54),
                          onPressed: () {
                            Share.share(state.getReportModel.url!);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(
                        height: 0,
                      ),
                    ],
                  ),
                ],
              ),
            ]);
          }
          return Container();
        },
      ),
    );
  }
}
