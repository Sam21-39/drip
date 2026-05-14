import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/frame_updater.dart';
import '../services/rebuild_tracker.dart';
import '../widgets/number_cube.dart';

class CubeState {
  final List<int> values;
  const CubeState(this.values);
}

class UpdateCubes {
  final List<int> values;
  const UpdateCubes(this.values);
}

class CubeBloc extends Bloc<UpdateCubes, CubeState> {
  CubeBloc() : super(CubeState(List<int>.filled(200, 0))) {
    on<UpdateCubes>((e, emit) => emit(CubeState(e.values)));
  }
}

class BlocBenchmark extends StatefulWidget {
  final bool isRunning;
  const BlocBenchmark({super.key, required this.isRunning});

  @override
  State<BlocBenchmark> createState() => _BlocBenchmarkState();
}

class _BlocBenchmarkState extends State<BlocBenchmark> {
  late CubeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CubeBloc();
    if (widget.isRunning) {
      _start();
    }
  }

  @override
  void didUpdateWidget(BlocBenchmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _start();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _stop();
    }
  }

  void _start() {
    FrameUpdater.instance
        .start((vals) => _bloc.add(UpdateCubes(List.from(vals))));
  }

  void _stop() {
    FrameUpdater.instance.stop();
  }

  @override
  void dispose() {
    _stop();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<CubeBloc, CubeState>(
        builder: (ctx, state) {
          RebuildTracker.instance.record();
          return GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: 200,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) {
              RebuildTracker.instance.record();
              return NumberCube(value: state.values[i], index: i);
            },
          );
        },
      ),
    );
  }
}
