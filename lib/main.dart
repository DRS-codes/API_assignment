import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model class for Agent Details
class AgentDetails {
  final String id;
  final String name;
  final String agentRate;

  AgentDetails({required this.id, required this.name, required this.agentRate});

  // Factory constructor to create an AgentDetails instance from JSON
  factory AgentDetails.fromJson(Map<String, dynamic> json) {
    final agentDetails = json['sectionData']['Agent Details'];
    return AgentDetails(
      id: json['_id'],
      name: agentDetails['name'],
      agentRate: agentDetails['agentrate'],
    );
  }
}

// Service class to fetch agent details from the API
class AgentDetailsService {
  final String apiUrl = 'https://crmapi.conscor.com/api/general/v1/mfind';
  final String apiKey = 'PLLW0s5A6Rk1aZeAmWr1';

  Future<List<AgentDetails>> fetchAgentDetails() async {
    // Define request body
    Map<String, dynamic> requestBody = {
      "dbName": "customize-5",
      "collectionName": "company_details",
      "query": {},
      "projection": {},
      "limit": 5,
      "skip": 0
    };

    // Make POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      // Parse the response body
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success']) {
        // Convert JSON to List of AgentDetails
        List<AgentDetails> agentDetailsList = (data['data'] as List)
            .map((item) => AgentDetails.fromJson(item))
            .toList();

        return agentDetailsList;
      } else {
        throw Exception('Failed to fetch data: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
}

// Main app widget
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agent Details App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AgentDetailsPage(),
    );
  }
}

// Agent Details Page to display the data
class AgentDetailsPage extends StatefulWidget {
  @override
  _AgentDetailsPageState createState() => _AgentDetailsPageState();
}

class _AgentDetailsPageState extends State<AgentDetailsPage> {
  late Future<List<AgentDetails>> futureAgentDetails;

  @override
  void initState() {
    super.initState();
    futureAgentDetails = AgentDetailsService().fetchAgentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agent Details'),
      ),
      body: Center(
        child: FutureBuilder<List<AgentDetails>>(
          future: futureAgentDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final agent = snapshot.data![index];
                  return ListTile(
                    title: Text(agent.name),
                    subtitle: Text('Rate: ${agent.agentRate}'),
                    trailing: Text('ID: ${agent.id}'),
                  );
                },
              );
            } else {
              return Text('No data available');
            }
          },
        ),
      ),
    );
  }
}
