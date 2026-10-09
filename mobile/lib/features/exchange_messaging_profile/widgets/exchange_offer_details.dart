import 'package:flutter/material.dart';

/// Optional offer information; older requests continue to use their summary.
class ExchangeOfferDetails extends StatelessWidget {
  final Map<String, dynamic> data;
  const ExchangeOfferDetails({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final description =
        data['offeredEquipmentDetails']?.toString().trim() ?? '';
    final image = data['offeredEquipmentImageUrl']?.toString().trim() ?? '';
    if (description.isEmpty && image.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                image,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const SizedBox(
                  height: 60,
                  child: Center(child: Text('Offer photo unavailable.')),
                ),
              ),
            ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
        ],
      ),
    );
  }
}
