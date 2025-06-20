import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class BookTripScreen extends StatefulWidget {
  @override
  _BookTripScreenState createState() => _BookTripScreenState();
}

class _BookTripScreenState extends State<BookTripScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Trip> upcomingTrips = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchTripsFromFirestore();
  }

  Future<void> _fetchTripsFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('trips')
              .orderBy('startDate', descending: false)
              .get();

      List<Trip> trips = [];
      for (var doc in querySnapshot.docs) {
        trips.add(Trip.fromFirestore(doc));
      }

      setState(() {
        upcomingTrips = trips;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching trips: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load trips. Please try again.')),
      );
    }
  }

  List<Trip> get filteredTrips {
    return upcomingTrips.where((trip) {
      final matchesSearch =
          trip.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          trip.location.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'Special' && trip.isSpecialOffer);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Book Your Next Adventure'),

      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildFilters(),
                  _buildSpecialOffers(),
                  Expanded(child: _buildTripList()),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddTripDialog(),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedFilter,
              items:
                  ['All', 'Special'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Filter',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOffers() {
    final specialTrips =
        upcomingTrips.where((trip) => trip.isSpecialOffer).toList();

    if (specialTrips.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Special Offers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: specialTrips.length,
            itemBuilder: (context, index) {
              return _buildSpecialOfferCard(specialTrips[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialOfferCard(Trip trip) {
    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: trip.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      trip.location,
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${trip.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onPressed: () => _showTripDetails(trip),
                          child: Text('Book Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  'SPECIAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripList() {
    if (filteredTrips.isEmpty) {
      return Center(
        child: Text('No trips found', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: filteredTrips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(filteredTrips[index]);
      },
    );
  }

  Widget _buildTripCard(Trip trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => _showTripDetails(trip),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: trip.imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                if (trip.isSpecialOffer)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        'SPECIAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${trip.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    trip.location,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '${trip.rating} (${trip.reviewCount} reviews)',
                        style: TextStyle(fontSize: 14),
                      ),
                      Spacer(),
                      CircleAvatar(radius: 12, child: Text(trip.organizer[0])),
                      SizedBox(width: 8),
                      Text(trip.organizer, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () => _showTripDetails(trip),
                      child: Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripDetails(Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return TripDetailsBottomSheet(trip: trip);
      },
    );
  }

  void _showAddTripDialog() {
    final formKey = GlobalKey<FormState>();
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();
    TextEditingController organizerController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    bool isSpecialOffer = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Trip'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Trip Title*'),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(labelText: 'Location*'),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(labelText: 'Price*'),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: InputDecoration(labelText: 'Image URL'),
                      ),
                      TextFormField(
                        controller: organizerController,
                        decoration: InputDecoration(labelText: 'Organizer'),
                      ),
                      ListTile(
                        title: Text(
                          'Start Date: ${startDate != null ? DateFormat.yMd().format(startDate!) : "Not selected*"}',
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => startDate = date);
                          }
                        },
                      ),
                      ListTile(
                        title: Text(
                          'End Date: ${endDate != null ? DateFormat.yMd().format(endDate!) : "Not selected*"}',
                        ),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: startDate ?? DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => endDate = date);
                          }
                        },
                      ),
                      SwitchListTile(
                        title: Text('Special Offer'),
                        value: isSpecialOffer,
                        onChanged:
                            (value) => setState(() => isSpecialOffer = value),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text('Add Trip'),
                  onPressed: () async {
                    if (formKey.currentState!.validate() &&
                        startDate != null &&
                        endDate != null) {
                      await _addTripToFirestore(
                        title: titleController.text,
                        description: descriptionController.text,
                        location: locationController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        startDate: startDate!,
                        endDate: endDate!,
                        isSpecialOffer: isSpecialOffer,
                        imageUrl:
                            imageUrlController.text.isNotEmpty
                                ? imageUrlController.text
                                : 'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
                        organizer:
                            organizerController.text.isNotEmpty
                                ? organizerController.text
                                : 'RoamBot',
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all required fields'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addTripToFirestore({
    required String title,
    required String description,
    required String location,
    required double price,
    required DateTime startDate,
    required DateTime endDate,
    required String imageUrl,
    required String organizer,
    bool isSpecialOffer = false,
  }) async {
    try {
      await _firestore.collection('tours').add({
        'title': title,
        'description': description,
        'location': location,
        'price': price,
        'startDate': startDate,
        'endDate': endDate,
        'imageUrl': imageUrl,
        'organizer': organizer,
        'isSpecialOffer': isSpecialOffer,
        'rating': 4.5,
        'reviewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Trip added successfully!')));

      _fetchTripsFromFirestore();
    } catch (e) {
      print('Error adding trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add trip. Please try again.')),
      );
    }
  }
}

class TripDetailsBottomSheet extends StatelessWidget {
  final Trip trip;

  const TripDetailsBottomSheet({Key? key, required this.trip})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            trip.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            trip.location,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: CachedNetworkImage(
              imageUrl: trip.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                '${trip.rating} (${trip.reviewCount} reviews)',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Organized by ${trip.organizer}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'About this trip',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(trip.description, style: TextStyle(fontSize: 16)),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${trip.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking ${trip.title}')),
                  );
                },
                child: Text('Book Now', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class TripSearchDelegate extends SearchDelegate {
  final List<Trip> trips;

  TripSearchDelegate({required this.trips});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results =
        trips.where((trip) {
          return trip.title.toLowerCase().contains(query.toLowerCase()) ||
              trip.location.toLowerCase().contains(query.toLowerCase());
        }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              results[index].imageUrl,
            ),
          ),
          title: Text(results[index].title),
          subtitle: Text(results[index].location),
          onTap: () {
            close(context, null);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder:
                  (context) => TripDetailsBottomSheet(trip: results[index]),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        query.isEmpty
            ? trips
            : trips.where((trip) {
              return trip.title.toLowerCase().contains(query.toLowerCase()) ||
                  trip.location.toLowerCase().contains(query.toLowerCase());
            }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              suggestions[index].imageUrl,
            ),
          ),
          title: Text(suggestions[index].title),
          subtitle: Text(suggestions[index].location),
          onTap: () {
            query = suggestions[index].title;
            showResults(context);
          },
        );
      },
    );
  }
}

class Trip {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final double rating;
  final int reviewCount;
  final String location;
  final String organizer;
  final bool isSpecialOffer;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.organizer,
    required this.isSpecialOffer,
    required this.createdAt,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      title: data['title'] ?? 'Untitled Trip',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      price: (data['price'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 4.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      location: data['location'] ?? '',
      organizer: data['organizer'] ?? 'Unknown',
      isSpecialOffer: data['isSpecialOffer'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
