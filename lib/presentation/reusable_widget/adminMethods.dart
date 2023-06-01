import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:conduit_password_hash/conduit_password_hash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> generatePasswordHashAdmin(String mypass) async {
// Create PBKDF2NS instance using the SHA256 hash. The default is to use SHA1
  var generator = PBKDF2();
  var salt = generateAsBase64String(10);
  var hash = generator.generateKey(mypass, salt, 1000, 32);
  var encodedHash = base64.encode(hash);
  Map<String, dynamic> response = {'salt': salt, 'hash': encodedHash};
  
  return response;
}
