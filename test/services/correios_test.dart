import 'package:via_cep_flutter/enum.dart';
import 'package:via_cep_flutter/error.dart';
import 'package:via_cep_flutter/services/correios.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetchCorreiosService success', () async {
    final cep = await fetchCorreiosService('05653070');

    expect(cep.city, 'São Paulo');
    expect(cep.cep, '05653070');
    expect(cep.neighborhood, 'Jardim Leonor');
    expect(cep.state, 'SP');
    expect(cep.street, 'Praça Roberto Gomes Pedrosa');
  });

  test('fetchCorreiosService error', () async {
    try {
      await fetchCorreiosService('11111111');
    } catch (e) {
      if (e is ServiceError) {
        expect(e.message, 'CEP INVÁLIDO');
        expect(e.service, Service.Correios);
      }
    }
  });

  test('extractValuesFromSuccessResponse error', () {
    try {
      extractValuesFromSuccessResponse({});
    } catch (e) {
      if (e is ServiceError)
        expect(e.message, 'Não foi possível interpretar a resposta.');
    }
  });

  test('extractValuesFromSuccessResponse error', () {
    try {
      translateErrorMessage({});
    } catch (e) {
      if (e is ServiceError)
        expect(e.message, 'Erro ao se conectar com o serviço Correios');
    }
  });
}
