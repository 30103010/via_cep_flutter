import 'package:via_cep_flutter/via_cep_flutter.dart';

Future<void> main() async {
  final result = await readAddressByCep('31330-555');

  if (result.isEmpty) return;

  print(result['city']);
  print(result['cep']);
  print(result['neighborhood']);
  print(result['state']);
  print(result['street']);
}
