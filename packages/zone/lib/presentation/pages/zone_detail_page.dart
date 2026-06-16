import 'dart:io';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';
import 'package:zone/presentation/bloc/zone_event.dart';
import 'package:zone/presentation/bloc/zone_state.dart';
import 'package:zone/presentation/widgets/zone_detail_card.dart';
import 'package:zone/zone.dart';

class ZoneDetailPage extends StatefulWidget {
  final int? zoneId;
  final String? zoneName;

  const ZoneDetailPage({super.key, this.zoneId, this.zoneName});

  @override
  State<ZoneDetailPage> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  Zone? _zoneFromState(ZoneState state) {
    if (state is! ZoneLoaded) return null;

    final zoneId = widget.zoneId;
    if (zoneId != null) {
      for (final zone in state.zones) {
        if (zone.id == zoneId) {
          return zone;
        }
      }
    }

    if (state.zones.isEmpty) return null;
    return state.zones.first;
  }

  @override
  void initState() {
    super.initState();
    final zoneId = widget.zoneId;
    stdout.writeln(
      'ZoneDetailPage initState: zoneId=$zoneId, zoneName=${widget.zoneName ?? zoneId?.toString() ?? ''}',
    );

    if (zoneId != null) {
      Future.microtask(() {
        context.read<ZoneBloc>().add(GetZoneDetailsEvent(zoneId: zoneId));
      });
    }
  }

  void _loadZoneDetails() {
    final zoneId = widget.zoneId;
    if (zoneId != null) {
      context.read<ZoneBloc>().add(GetZoneDetailsEvent(zoneId: zoneId));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildScaffold({required Widget body}) {
      return Scaffold(
        backgroundColor: WHColors.background,
        appBar: WHAppbar(
          title: 'Zone ${widget.zoneName ?? widget.zoneId?.toString() ?? ''}',
        ),
        body: Container(
          color: WHColors.background,
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                "All Zones > ${widget.zoneName ?? widget.zoneId?.toString() ?? ''}",
                style: WHTypography.caption,
              ),
              const SizedBox(height: 16),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<ZoneBloc, ZoneState>(
      builder: (context, state) {
        final zoneToDisplay = _zoneFromState(state);

        if (zoneToDisplay != null &&
            zoneToDisplay.shelves != null &&
            zoneToDisplay.shelves!.isNotEmpty) {
          return buildScaffold(
            body: WHRefresh(
              onRefresh: () async {
                _loadZoneDetails();
              },
              child: Column(
                children: [
                  ZoneDetailCard(zone: zoneToDisplay),
                  const SizedBox(height: 16),
                  Expanded(child: ZoneVisualizer(zone: zoneToDisplay)),
                ],
              ),
            ),
          );
        }

        if (state is ZoneLoading) {
          return buildScaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ZoneLoaded) {
          if (state.zones.isEmpty) {
            return buildScaffold(
              body: const Center(child: Text('Zone not found')),
            );
          }
          final zone = zoneToDisplay!;
          return buildScaffold(
            body: WHRefresh(
              onRefresh: () async {
                _loadZoneDetails();
              },
              child: Column(
                children: [
                  // WHSearch(hintText: 'Search Zone...'),
                  // const SizedBox(height: 16),
                  ZoneDetailCard(zone: zone),
                  const SizedBox(height: 16),
                  Expanded(child: ZoneVisualizer(zone: zone)),
                ],
              ),
            ),
          );
        } else if (state is ZoneError) {
          return buildScaffold(
            body: WHRefresh(
              onRefresh: () async {
                _loadZoneDetails();
              },
              child: Center(child: Text(state.message)),
            ),
          );
        }
        return buildScaffold(
          body: const Center(child: Text('No zone data available')),
        );
      },
    );
  }
}
