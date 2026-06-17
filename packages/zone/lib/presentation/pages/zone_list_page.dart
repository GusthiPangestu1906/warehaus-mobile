import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_state.dart';
import 'package:mobile/route_observer.dart';
import 'package:zone/domain/entities/zone.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';
import 'package:zone/presentation/bloc/zone_event.dart';
import 'package:zone/presentation/bloc/zone_state.dart';
import 'package:zone/presentation/pages/create_zone_page.dart';
import 'package:zone/presentation/pages/zone_detail_page.dart';
import 'package:zone/presentation/widgets/zone_card.dart';
import 'package:zone/presentation/widgets/zone_edit_dialog.dart';

class ZoneListPage extends StatefulWidget {
  const ZoneListPage({super.key});

  @override
  State<ZoneListPage> createState() => _ZoneListPageState();
}

class _ZoneListPageState extends State<ZoneListPage> with RouteAware {
  bool _hasShownSwipeHint = false;

  // FIX: Simpan zones terakhir yang berhasil di-load.
  // Digunakan agar saat ZoneLoading (proses delete/update/create),
  // list lama tetap tampil — bukan berubah ke loading spinner atau
  // pesan error — sehingga tidak ada "flash" di layar.
  List<Zone> _lastKnownZones = [];

  void _showSwipeHintIfNeeded() {
    if (!mounted || _hasShownSwipeHint) return;

    _hasShownSwipeHint = true;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Geser kartu zone ke kiri untuk melihat menu Edit dan Delete.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
  }

  Future<void> _showEditZoneDialog(Zone zone) async {
    final bloc = context.read<ZoneBloc>();

    String? toOptionalValue(String initial, String current) {
      if (initial == current) return null;
      return current;
    }

    int? toOptionalInt(int initial, int current) {
      if (initial == current) return null;
      return current;
    }

    final edited = await showZoneEditDialog(context, zone);

    // Tunggu hingga frame berikutnya selesai di-render agar dialog
    // widget sepenuhnya di-dispose dari tree sebelum BLoC emit state baru.
    // Ini mencegah assertion _dependents.isEmpty.
    await Future.delayed(Duration.zero);

    if (edited == null || !mounted) return;

    final zoneName = toOptionalValue(zone.zoneName, edited.zoneName);
    final categoryId = toOptionalInt(zone.categoryId, edited.categoryId);
    final description = toOptionalValue(zone.description, edited.description);

    if (zoneName == null && categoryId == null && description == null) return;

    bloc.add(
      UpdateZoneEvent(
        id: zone.id,
        zoneName: zoneName,
        categoryId: categoryId,
        description: description,
      ),
    );
  }

  Future<void> _confirmDeleteZone(Zone zone) async {
    final bloc = context.read<ZoneBloc>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WHColors.surface,
        title: const Text('Delete Zone', style: WHTypography.heading1),
        content: Text(
          'Delete zone "${zone.zoneName}"?',
          style: WHTypography.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: WHColors.grey3),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: WHColors.error2),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // FIX: Tunggu hingga frame selesai agar dialog fully disposed
    // sebelum BLoC emit ZoneLoading — mencegah _dependents.isEmpty
    // dan flash UI yang terjadi karena rebuild di tengah disposal.
    await Future.delayed(Duration.zero);

    if (shouldDelete == true && mounted) {
      bloc.add(DeleteZoneEvent(zone.id));
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ZoneBloc>().add(GetZonesEvent());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigationState = context.read<NavigationBloc>().state;
      if (navigationState.currentIndex == 3) {
        _showSwipeHintIfNeeded();
      }
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

  @override
  void didPopNext() {
    final navigationState = context.read<NavigationBloc>().state;
    if (navigationState.currentIndex == 3) {
      context.read<ZoneBloc>().add(GetZonesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) =>
          previous.currentIndex != current.currentIndex,
      listener: (context, state) {
        if (state.currentIndex == 3) {
          _showSwipeHintIfNeeded();
          context.read<ZoneBloc>().add(GetZonesEvent());
        }
      },
      child: BlocListener<ZoneBloc, ZoneState>(
        listenWhen: (previous, current) =>
            current is ZoneError || current is ZoneOperationSuccess,
        listener: (context, state) {
          // Hanya tampilkan snackbar jika halaman ini yang aktif (bukan create_zone di atas)
          if ((ModalRoute.of(context)?.isCurrent ?? false)) {
            if (state is ZoneError) {
              WHSnackBar.showError(context, state.message);
            } else if (state is ZoneOperationSuccess && state.message != null) {
              WHSnackBar.showSuccess(context, state.message!);
            }
          }
        },
        child: BlocBuilder<ZoneBloc, ZoneState>(
          // ZoneError TIDAK masuk buildWhen supaya list tidak blank saat error
          buildWhen: (previous, current) =>
              current is ZoneLoading ||
              current is ZoneLoaded ||
              current is ZoneOperationSuccess,
          builder: (context, state) {
            // FIX: Update _lastKnownZones setiap kali ada data zones yang valid.
            // Ini memastikan saat ZoneLoading dipicu oleh delete/update/create,
            // kita punya fallback data untuk tetap menampilkan list lama.
            if (state is ZoneLoaded) {
              _lastKnownZones = state.zones;
            } else if (state is ZoneOperationSuccess) {
              _lastKnownZones = state.zones;
            }

            // Resolve data efektif untuk rendering.
            // Saat ZoneLoading & sudah ada data sebelumnya → tampilkan list lama
            // + indikator loading tipis di atas, tanpa mengganti seluruh body.
            final bool isLoadingOverlay =
                state is ZoneLoading && _lastKnownZones.isNotEmpty;

            final List<Zone> zonesToRender = state is ZoneLoaded
                ? state.zones
                : state is ZoneOperationSuccess
                ? state.zones
                : _lastKnownZones;

            Widget buildScaffold({required Widget body}) {
              return Scaffold(
                backgroundColor: WHColors.background,
                appBar: WHAppbar(title: 'Zone Management'),
                body: Column(
                  children: [
                    // Indikator loading tipis di bawah AppBar.
                    // Muncul saat fetch berlangsung tapi list sudah ada,
                    // sehingga tidak ada flash/replace pada list.
                    if (isLoadingOverlay)
                      LinearProgressIndicator(
                        color: WHColors.primary,
                        backgroundColor: WHColors.primary.withOpacity(0.15),
                        minHeight: 3,
                      ),
                    Expanded(
                      child: Container(
                        color: WHColors.background,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Zone Hierarchy",
                                  style: WHTypography.heading1,
                                ),
                                Text(
                                  "Manage your warehouse zones efficiently",
                                  style: WHTypography.caption,
                                ),
                              ],
                            ),
                            Expanded(child: body),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  heroTag: 'zone-create-fab',
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await navigator.push(
                      PageRouteBuilder(
                        pageBuilder: (_, _, _) => const CreateZonePage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  backgroundColor: WHColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              );
            }

            if (state is ZoneLoading && _lastKnownZones.isEmpty) {
              // Hanya muncul saat pertama kali load (belum ada _lastKnownZones)
              return buildScaffold(
                body: Center(
                  child: CircularProgressIndicator(color: WHColors.primary),
                ),
              );
            } else if (zonesToRender.isNotEmpty) {
              return buildScaffold(
                body: WHRefresh(
                  onRefresh: () async {
                    context.read<ZoneBloc>().add(GetZonesEvent());
                  },
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          key: const PageStorageKey('zone_list_key'),
                          cacheExtent: 588,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: true,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemCount: zonesToRender.length,
                          itemBuilder: (context, index) {
                            return ZoneCard(
                              zone: zonesToRender[index],
                              onEdit: () =>
                                  _showEditZoneDialog(zonesToRender[index]),
                              onDelete: () =>
                                  _confirmDeleteZone(zonesToRender[index]),
                              onTap: () async {
                                final navigator = Navigator.of(context);
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => Center(
                                    child: CircularProgressIndicator(
                                      color: WHColors.primary,
                                    ),
                                  ),
                                );
                                final changed = await Navigator.of(context)
                                    .push<bool>(
                                      PageRouteBuilder(
                                        pageBuilder: (_, _, _) =>
                                            ZoneDetailPage(
                                              zoneId: zonesToRender[index].id,
                                              zoneName:
                                                  zonesToRender[index].zoneName,
                                            ),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                if (!mounted) {
                                  return;
                                }
                                if (navigator.canPop()) {
                                  navigator.pop();
                                }
                                if (changed == true) {
                                  context.read<ZoneBloc>().add(GetZonesEvent());
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is ZoneError) {
              return buildScaffold(
                body: Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else {
              return buildScaffold(
                body: const Center(child: Text('No zones available')),
              );
            }
          },
        ),
      ),
    );
  }
}
