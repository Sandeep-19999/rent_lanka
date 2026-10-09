/// Opens a fresh source subscription for each listener, including after a tab
/// has been disposed. Cancellation releases that listener's Firestore source.
Stream<T> resubscribableStream<T>(Stream<T> Function() source) {
  return Stream<T>.multi((controller) {
    try {
      final subscription = source().listen(
        controller.addSync,
        onError: controller.addErrorSync,
        onDone: controller.closeSync,
      );
      controller.onCancel = subscription.cancel;
    } catch (error, stack) {
      controller.addErrorSync(error, stack);
      controller.closeSync();
    }
  }, isBroadcast: true);
}
