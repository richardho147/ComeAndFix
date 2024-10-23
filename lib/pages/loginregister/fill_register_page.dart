import 'dart:io';
import 'package:come_n_fix/components/services_edit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class FillRegisterPage extends StatefulWidget {
  const FillRegisterPage({super.key, required this.email});
  final String email;

  @override
  State<FillRegisterPage> createState() => _FillRegisterPageState();
}

class _FillRegisterPageState extends State<FillRegisterPage> {
  final phoneNumberController = TextEditingController();
  final genderController = TextEditingController();
  final descriptionController = TextEditingController();
  var _providerServices = [];
  String _identificationFile = "", _competencyFile = "", _BPJSFile = "" ;

  Future<void> vertificationNotice(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          "Thank you for registering, we'll verify your documentation and notify your email soon!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Ok', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Future<void> chooseServices(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 124, 102, 89),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          "Choose Services",
          style: TextStyle(color: Colors.white),
        ),
        content: ServicesEdit(
                onServiceSelected: (selectedServices) {
                  setState(() {
                    _providerServices = selectedServices;
                  });
                },
              ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back', style: TextStyle(color: Colors.white))),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(_providerServices);
                  if (_providerServices.isEmpty) {
                    setState(() {
                      _providerServices = [];
                    });
                  }
                },
                child: Text('Save', style: TextStyle(color: Colors.white))
              )
        ],
      ),
    );
  }
  
  Future<void> uploadFile(String type) async {
    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = basename(file.path);  // Get the file name

      // Create a storage reference
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('${widget.email}/$fileName');
      try {
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        print("File uploaded successfully! Download URL: $downloadUrl");
        setState(() {
          if(type == 'identification') _identificationFile = fileName;
          else if(type == 'competency') _competencyFile = fileName;
          else if(type == 'BPJS') _BPJSFile = fileName;
        });
      } catch (e) {
        print("Failed to upload file: $e");
      }
    } else {
      print("No file selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 10.0),
                  child: Text(
                    'Please fill the requirement below',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 1.0),
                  child: Text(
                    'Your Services',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () => chooseServices(context),
                    child: Container(
                        height: 47,
                        width: 400,
                       decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 72, 71, 76),
                          width: 1.5,
                        ),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4), 
                       ),
                       child: Padding(
                         padding: const EdgeInsets.all(10.0),
                         child: Text(
                          (_providerServices.isEmpty) ? 'Services' : _providerServices.join(', '),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                         ),
                       ),
                      ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 1.0),
                  child: Text(
                    'Identification Card (KTP)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
          
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () => uploadFile('identification'),
                    child: (_identificationFile != "") ? 
                    Container(
                        height: 47,
                        width: 400,
                       decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 72, 71, 76),
                          width: 1.5,
                        ),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4), 
                       ),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 10.0),
                         child: Row(
                           children: [
                             Text(
                              _identificationFile,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                             ),
                             Icon(
                              Icons.file_copy,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                           ],
                         ),
                       ),
                      )
                      :
                     Container(
                        height: 160,
                        width: 400,
                       decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 72, 71, 76),
                          width: 1.5,
                        ),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4), 
                       ),
                       child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                          Icon(
                              Icons.file_copy,
                              color: Colors.grey[500],
                              size: 50,
                            ),
                           Text(
                            'Click to Upload File',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                           ),
                         ],
                       ),
                      ),
                  ),
                ),
          
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 1.0),
                  child: Text(
                    'Competency Certification (LSP)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
          
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () => uploadFile('competency'),
                    child: (_competencyFile != "") ? 
                    Container(
                        height: 47,
                        width: 400,
                       decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 72, 71, 76),
                          width: 1.5,
                        ),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4), 
                       ),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 10.0),
                         child: Row(
                           children: [
                             Text(
                              _competencyFile,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                             ),
                             Icon(
                              Icons.file_copy,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                           ],
                         ),
                       ),
                      )
                      :
                     Container(
                        height: 160,
                        width: 400,
                       decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 72, 71, 76),
                          width: 1.5,
                        ),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4), 
                       ),
                       child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                          Icon(
                              Icons.file_copy,
                              color: Colors.grey[500],
                              size: 50,
                            ),
                           Text(
                            'Click to Upload File',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                           ),
                         ],
                       ),
                      ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 1.0),
                  child: Text(
                    'BPJS Card',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
          
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () => uploadFile('BPJS'),
                    child: (_BPJSFile != "") ? 
                    Container(
                        height: 47,
                        width: 400,
                       decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 72, 71, 76),
                          width: 1.5,
                        ),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4), 
                       ),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 10.0),
                         child: Row(
                           children: [
                             Text(
                              _BPJSFile,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                             ),
                             Icon(
                              Icons.file_copy,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                           ],
                         ),
                       ),
                      )
                      :
                     Container(
                        height: 160,
                        width: 400,
                       decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 72, 71, 76),
                          width: 1.5,
                        ),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4), 
                       ),
                       child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                          Icon(
                              Icons.file_copy,
                              color: Colors.grey[500],
                              size: 50,
                            ),
                           Text(
                            'Click to Upload File',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                           ),
                         ],
                       ),
                      ),
                  ),
                ),
          
                // errorMsg
                // Visibility(
                //   visible: showErrorMessage,
                //   child: Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 25.0),
                //     child: Align(
                //       alignment: Alignment.centerLeft,
                //       child: Text(
                //         errorMessage,
                //         style: TextStyle(color: Colors.red[700]),
                //       ),
                //     ),
                //   ),
                // ),
          
                SizedBox(
                  height: 20.0,
                ),
          
                // button
          
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: OutlinedButton(
                        onPressed: () async{
                          await vertificationNotice(context);
                          Navigator.pop(context, 
                             _providerServices
                          );
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            side: BorderSide(
                                width: 2.0,
                                color: Color.fromARGB(255, 72, 71, 76)),
                            backgroundColor: Color.fromARGB(255, 212, 190, 169),),),
                  ),
                ),

                SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}