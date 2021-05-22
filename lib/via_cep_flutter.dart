library cep_future;

import 'dart:async';

import 'package:via_cep_flutter/error.dart';
import 'package:via_cep_flutter/models/cep.dart';
import 'package:via_cep_flutter/services/correios.dart';
import 'package:via_cep_flutter/services/via_cep.dart';

const CEP_SIZE = 8;

Future<Cep> fetchCepFromServices(String cepWithLeftPad) async {
  final results = await Future.wait([
    fetchCorreiosService(cepWithLeftPad),
    fetchViaCepService(cepWithLeftPad)
  ]).catchError((e) async {
    if (e is SimpleError) {
      print('[ViaCepFlutter - SimpleError] ' + (e.message ?? ''));
    } else if (e is ServiceError) {
      print('[ViaCepFlutter - ServiceError] ' + (e.message ?? ''));
    }
  });

  return results[0];
}

void handleServicesError(Object aggregatedErrors) {
  print(aggregatedErrors.runtimeType);
  if (aggregatedErrors.runtimeType == ServiceError) {
    throw SimpleError('Todos os serviços de CEP retornaram erro.');
  }

  throw aggregatedErrors;
}

String removeSpecialCharacters(String cepRawValue) =>
    cepRawValue.replaceAll(RegExp(r'[^0-9]'), '');

String validateInputLength(String input) {
  if (input.length <= CEP_SIZE) return input;

  throw ArgumentError('CEP deve conter exatamente $CEP_SIZE caracteres.');
}

String leftPadWithZeros(String cep) {
  return ''.padLeft(CEP_SIZE - cep.length).replaceAll(' ', '0') + cep;
}

/// Ao receber um CEP, a função irá fazer o tratamento da [String]
///enviada, e então retornará um [Map<String,dynamic>] contendo
///informações do lugar com o CEP informado
///
///Obs: caso o CEP enviado seja inválido, o [Map] que será retornado
///estará vazio, logo, basta verificar se a estrutura está vazia
///(isEmpty), para saber se a operação foi um sucesso.
///
/// Eis a maneira como informações do CEP estão contidas dentro do mapa,
/// caso a operação seja um sucesso
///
/// **cep**: CEP enviado para a função
///
/// **state**: Iniciais do Estado,
///
/// **city**: Nome da Cidade,
///
/// **street**: Nome da rua/avenida por completo,
///
/// **neighborhood**: Bairro,
///
Future<Map<String, dynamic>> readAddressByCep(String cepRawValue) async {
  Map<String, dynamic> result = {};

  var cepStringTreated = removeSpecialCharacters(cepRawValue);

  try {
    cepStringTreated = validateInputLength(cepStringTreated);
    cepStringTreated = leftPadWithZeros(cepStringTreated);

    final cep = await fetchCepFromServices(cepStringTreated);

    result = cep.toJson();
  } catch (e) {
    print('Verifique se o CEP enviado está correto!');
  }

  return result;
}
