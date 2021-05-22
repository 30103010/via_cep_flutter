///The class CEP is where everything is stored from
///the ViaCep website.
class Cep {
  const Cep(
    this._cep,
    this._state,
    this._city,
    this._street,
    this._neighborhood,
  );

  final String _cep;
  final String _state;
  final String _city;
  final String _street;
  final String _neighborhood;

  //getters

  String get cep => _cep;

  String get state => _state;

  String get city => _city;

  String get street => _street;

  String get neighborhood => _neighborhood;

  ///Function to map all variables into a json
  Map<String, dynamic> toJson() => {
        'cep': cep,
        'state': state,
        'city': city,
        'street': street,
        'neighborhood': neighborhood,
      };
}
