import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/sys-config.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:date_field/date_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class AddPrice extends StatefulWidget {
  final String campaignId;
  final DateTime from;

  AddPrice({required this.campaignId, required this.from});
  @override
  _AddPriceState createState() => _AddPriceState();
}

class _AddPriceState extends State<AddPrice> {
  final formKey = GlobalKey<FormState>();
  final txtPrizeName = TextEditingController();
  final txtPrizeQuantity = TextEditingController();
  String prizeName = '',
      prizeQuantity = '',
      snackBarTxt = '',
      imagepath = '',
      warning = '',
      imageUrl = '';
  bool isEnabled = true;
  late File _img;
  late DateTime prizeExpiry, campaignFrom = widget.from;
  late IconData snackBarIcon;
  late Color snackBarIconColor;

  buttonStatus(status) {
    setState(() {
      isEnabled = status;
    });
  }

  Future chooseImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      await cropImage(_image.path);
    }
  }

  cropImage(filePath) async {
    File? croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3),
        androidUiSettings: AndroidUiSettings(lockAspectRatio: true));
    if (croppedImage != null) {
      setState(() {
        imagepath = croppedImage.path;
        warning = '';
      });
      _img = croppedImage;
    }
  }

  Future uploadImage() async {
    String fileName = imagepath.split('/').last;
    //Upload to Firebase
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child('retail_client/prize/$fileName')
        .putFile(_img);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadUrl;
    });
  }

  void addPrizeFunction(
      {@required prizeName, prizeQuantity, prizeExpiry, ctx}) async {
    final apiurl = SysConfig.apiUrl;

    final response = await http.post(
      Uri.parse('$apiurl/price'),
      body: {
        'campaign_id': widget.campaignId,
        'name': prizeName,
        'image': imageUrl,
        'count': prizeQuantity,
        'expiry': prizeExpiry,
      },
    );
    if (response.statusCode == 200) {
      final resp = json.decode(response.body);
      if (resp['status'] == 'Data inserted') {
        snackBarTxt = tr('prize_added');
        snackBarIcon = Icons.check_circle;
        snackBarIconColor = Colors.green;
        Navigator.pop(context);
      } else {
        snackBarTxt = tr('prize_faild');
        snackBarIcon = Icons.close;
        snackBarIconColor = Colors.red;
        buttonStatus(true);
      }
    } else {
      snackBarTxt = tr('wrong_msg');
      snackBarIcon = Icons.warning;
      snackBarIconColor = Colors.red;
      buttonStatus(true);
    }
    Loader.hide();
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Row(children: [
      Text(snackBarTxt),
      Icon(snackBarIcon, color: snackBarIconColor)
    ])));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent[700],
        title: Text(tr('appbar_prize_add')),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.deepPurpleAccent, width: 3)),
                    labelText: tr('label_prize_name'),
                    hintText: tr('hint_prize_name'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent[700]),
                  ),
                  onChanged: (value) {
                    this.prizeName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('validation_prize_name');
                    }
                    return null;
                  },
                  controller: txtPrizeName,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 20, bottom: 0),
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.deepPurpleAccent, width: 3)),
                    labelText: tr('label_prize_quantity'),
                    hintText: tr('hint_prize_quantity'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent[700]),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                  onChanged: (value) {
                    this.prizeQuantity = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('validation_prize_quantity');
                    }
                    return null;
                  },
                  controller: txtPrizeQuantity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 20, bottom: 0),
                child: DateTimeFormField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.deepPurpleAccent, width: 3)),
                    suffixIcon: Icon(Icons.event_note),
                    labelText: tr('label_prize_expiry'),
                    hintText: tr('hint_prize_expiry'),
                    labelStyle: TextStyle(color: Colors.deepPurpleAccent[700]),
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  validator: (value) {
                    if (value == null) {
                      return tr('validation_prize_expiry-1');
                    } else if (value.isBefore(campaignFrom)) {
                      return tr('validation_prize_expiry-2');
                    }
                    return null;
                  },
                  onDateSelected: (DateTime value) {
                    prizeExpiry = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 20, bottom: 0),
                child: Container(
                    width: 340,
                    height: 200,
                    padding: new EdgeInsets.all(5.0),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(width: .5)),
                        elevation: 5,
                        child: InkWell(
                          onTap: () async {
                            await chooseImage();
                          },
                          child: Center(
                            child: imagepath != ''
                                ? ListTile(
                                    title: CircleAvatar(
                                        radius: 70,
                                        backgroundColor: Colors.transparent,
                                        child: Image.file(
                                          File(imagepath),
                                          fit: BoxFit.cover,
                                        )),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                      ),
                                      child: Text(
                                        tr('selected_image'),
                                        style: TextStyle(fontSize: 14.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : ListTile(
                                    title: Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 70,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 20,
                                      ),
                                      child: Text(
                                        tr('select_image'),
                                        style: TextStyle(fontSize: 14.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                          ),
                        ))),
              ),
              Text(
                warning,
                style: TextStyle(color: Colors.red[400]),
              ),
              SizedBox(
                height: 60,
              ),
              Container(
                height: 40,
                width: 130,
                margin: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[700]!.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ]),
                child: FlatButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate() &&
                          imagepath != '' &&
                          isEnabled) {
                        buttonStatus(false);
                        Loader.show(context,
                            isAppbarOverlay: false,
                            progressIndicator: CircularProgressIndicator(
                              color: Colors.deepPurpleAccent[700],
                            ));
                        await uploadImage();
                        addPrizeFunction(
                            prizeName: this.prizeName,
                            prizeQuantity: this.prizeQuantity.toString(),
                            prizeExpiry: this.prizeExpiry.toString(),
                            ctx: this.context);
                      } else {
                        if (imagepath == '') {
                          setState(() {
                            warning = tr('validation_prize_image');
                          });
                        }
                      }
                    },
                    child: Row(children: [
                      Icon(
                        Icons.add,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        tr('label_add_prize'),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
