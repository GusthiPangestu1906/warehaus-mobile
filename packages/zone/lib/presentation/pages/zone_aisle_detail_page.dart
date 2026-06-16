import 'package:core_services/api/api_client.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/route_observer.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';
import 'package:zone/presentation/bloc/zone_event.dart';
import 'package:zone/presentation/bloc/zone_state.dart';
import 'package:zone/presentation/widgets/download_qr.dart';
import 'package:zone/presentation/widgets/zone_aisle_visualizer.dart';

class ZoneAisleDetailPage extends StatefulWidget {
  final String zoneId;
  final String zoneCode;
  final int aisleNumber;

  const ZoneAisleDetailPage({
    super.key,
    required this.zoneId,
    required this.zoneCode,
    required this.aisleNumber,
  });

  @override
  State<ZoneAisleDetailPage> createState() => _ZoneAisleDetailPageState();
}

class _ZoneAisleDetailPageState extends State<ZoneAisleDetailPage>
    with RouteAware {
  String get _downloadUrl {
    final zoneId = int.tryParse(widget.zoneId);
    if (zoneId == null) return '';

    return '/Zones/$zoneId/aisles/${widget.aisleNumber}/qrcodes/download';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAisleData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Dipanggil otomatis saat user kembali (pop) dari ShelfDetailPage.
  /// Ini menggantikan logika reload yang sebelumnya ada di dalam BlocBuilder
  /// (yang menyebabkan bug: ShelfDetailLoaded tidak di-handle → spinner abadi).
  @override
  void didPopNext() {
    _loadAisleData();
  }

  void _loadAisleData() {
    context.read<ZoneBloc>().add(
      GetZoneByAisleEvent(
        zoneId: widget.zoneId,
        aisleNumber: widget.aisleNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZoneBloc, ZoneState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: WHColors.background,
          appBar: WHAppbar(
            title:
                'Aisle ${widget.aisleNumber > 9 ? widget.aisleNumber : '0${widget.aisleNumber}'}',
          ),
          body: Container(
            color: WHColors.background,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  "All Zones > ${widget.zoneCode} > Aisle ${widget.aisleNumber > 9 ? widget.aisleNumber : '0${widget.aisleNumber}'}",
                  style: WHTypography.caption,
                ),
                const SizedBox(height: 16),
                if (_downloadUrl.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: DownloadQRButton(
                      url: _downloadUrl,
                      code:
                          'zone-${widget.zoneCode}-aisle-${widget.aisleNumber}',
                    ),
                  )
                else
                  const Text('QR download tidak tersedia untuk aisle ini'),
                const SizedBox(height: 16),
                Expanded(child: _buildContent(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(ZoneState state) {
    if (state is ZoneLoading) {
      return Center(child: CircularProgressIndicator(color: WHColors.primary));
    }

    if (state is ZoneLoaded) {
      if (state.zones.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No data found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAisleData,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      return WHRefresh(
        onRefresh: () async {
          _loadAisleData();
        },
        child: ZoneAisleVisualizer(zone: state.zones.first),
      );
    }

    if (state is ZoneError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAisleData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // State lain (ShelfDetailLoaded, ZoneInitial, dll):
    // Tampilkan loading — didPopNext() sudah trigger _loadAisleData()
    // sehingga state akan segera berubah ke ZoneLoading → ZoneLoaded.
    return Center(child: CircularProgressIndicator(color: WHColors.primary));
  }
}