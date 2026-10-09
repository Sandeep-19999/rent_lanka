import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../equipment/equipment_details_screen.dart';

/// Public listing information; account settings remain in the provider module.
class PublicProviderScreen extends StatelessWidget {
  final String providerId;

  const PublicProviderScreen({super.key, required this.providerId});

  String _text(Map<String, dynamic> data, String key) =>
      data[key]?.toString().trim() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment provider')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(providerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load provider information.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(
              child: Text('Provider information unavailable.'),
            );
          }
          final name = ['name', 'fullName', 'displayName']
              .map((key) => _text(data, key))
              .firstWhere(
                (value) => value.isNotEmpty,
                orElse: () => 'Equipment Provider',
              );
          final photo = _text(data, 'photoUrl');
          final location = _text(data, 'location');
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFFFE8D8),
                child: photo.isEmpty
                    ? const Icon(Icons.person_rounded, size: 40)
                    : ClipOval(
                        child: Image.network(
                          photo,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.person_rounded, size: 40),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(location, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 28),
              const Text(
                'Equipment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('equipment')
                    .where('providerId', isEqualTo: providerId)
                    .snapshots(),
                builder: (context, listings) {
                  if (listings.hasError) {
                    return const Text('Unable to load equipment.');
                  }
                  if (!listings.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (listings.data!.docs.isEmpty) {
                    return const Text('No equipment listed.');
                  }
                  return Column(
                    children: listings.data!.docs.map((doc) {
                      final equipment = {...doc.data(), 'id': doc.id};
                      final price = equipment['pricePerDay'];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.sports),
                          title: Text(_text(equipment, 'name')),
                          subtitle: price is num
                              ? Text('Rs. $price/day')
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  EquipmentDetailsScreen(equipment: equipment),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
