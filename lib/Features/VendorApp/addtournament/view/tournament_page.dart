// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/Features/VendorApp/addtournament/view/tournamentfn.dart';

class TournamentPage extends StatefulWidget {
  const TournamentPage({super.key});

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tournamentNameController = TextEditingController();
  final TextEditingController _turfNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _turfentryfeeController = TextEditingController();
  final TextEditingController _turffirstController = TextEditingController();
  final TextEditingController _turfsecondController = TextEditingController();


  bool _isLoading = false;

  

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      _dateController.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Tournament'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               TextFormField(
                controller: _tournamentNameController,
                decoration: const InputDecoration(
                  labelText: 'Tournament Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter tournament name' : null,
              ),
               SizedBox(height: 16.h),
              TextFormField(
                controller: _turfNameController,
                decoration: const InputDecoration(
                  labelText: 'Turf Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter turf name' : null,
              ),
               SizedBox(height: 16.h),
              TextFormField(
                controller: _turfentryfeeController,
                decoration: const InputDecoration(
                  labelText: 'Ground Fee',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter Entry Fee' : null,
              ),
               SizedBox(height: 16.h),
               TextFormField(
                controller: _turffirstController,
                decoration: const InputDecoration(
                  labelText: 'First Prize',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter first prize' : null,
              ),
               SizedBox(height: 16.h),
               TextFormField(
                controller: _turfsecondController,
                decoration: const InputDecoration(
                  labelText: 'Second Prize',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter second prize' : null,
              ),
               SizedBox(height: 16.h),
              
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Tournament Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) => value!.isEmpty ? 'Select a date' : null,
              ),
               SizedBox(height: 16.h),
             
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed:() async{
                  await  addTournament(_turfNameController.text, _dateController.text,_tournamentNameController.text,_turfentryfeeController.text,_turffirstController.text,_turfsecondController.text);
                  Navigator.pop(context);
                  },
                  icon: _isLoading
                      ?  SizedBox(
                          height: 18.h,
                          width: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sports_soccer),
                  label: Text(_isLoading ? 'Adding...' : 'Add Tournament'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
