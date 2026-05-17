import 'dart:async';
import 'package:drip_core/drip_core.dart';
import 'drip_node.dart';

/// Adds scoped async helpers to [DripNode] subclasses.
///
/// [DripAsyncNode] is optional in the same way [DripNode] is optional: it is a
/// convenience layer, not a required architecture. It adds [runAsync] and
/// [watchStream] so a node can create [DripAsync] values that are automatically
/// registered with the node's [DripScope]. Use it when that lifecycle wiring is
/// helpful; write the same [DripAsync] pattern manually when a plain Dart class
/// or a widget-owned scope better fits your app.
///
/// ```dart
/// class Profile {
///   const Profile(this.name);
///   final String name;
/// }
///
/// class ProfileApi {
///   Future<Profile> fetchProfile() async {
///     final response = await http.get(Uri.parse('/profile'));
///     if (response.statusCode != 200) {
///       throw StateError('Profile request failed');
///     }
///     return Profile(response.body);
///   }
/// }
///
/// class ProfileNode extends DripNode with DripAsyncNode {
///   ProfileNode(this.api);
///
///   final ProfileApi api;
///   late final DripAsync<Profile> profile;
///
///   @override
///   void onInit() {
///     profile = runAsync(api.fetchProfile, debugName: 'profile');
///   }
///
///   void refresh() {
///     profile.run(api.fetchProfile);
///   }
/// }
///
/// DripAsyncBuilder<Profile>(
///   source: node.profile,
///   loading: (context, previous) {
///     return previous == null
///         ? const CircularProgressIndicator()
///         : Text('Refreshing ${previous.name}...');
///   },
///   error: (context, error, stackTrace, previous) {
///     return Text(previous == null
///         ? 'Failed to load profile'
///         : 'Failed to refresh ${previous.name}');
///   },
///   data: (context, value) => Text(value.name),
/// )
/// ```
mixin DripAsyncNode on DripNode {
  /// Executes a computation and returns a scoped [DripAsync] state.
  DripAsync<T> runAsync<T>(Future<T> Function() computation,
      {String? debugName}) {
    final state = DripAsync<T>(debugName: debugName, scope: scope);
    state.run(computation);
    return state;
  }

  /// Watches a stream and returns a scoped [DripAsync] state.
  DripAsync<T> watchStream<T>(Stream<T> stream, {String? debugName}) {
    return DripAsync.fromStream<T>(stream, scope: scope);
  }
}
