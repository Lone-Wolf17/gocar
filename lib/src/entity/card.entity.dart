class Card {
  Card(
      {this.cardNumber = '',
      this.userName = '',
      this.expiryDate = '',
      this.expirationDate = '',
      this.securityCode = '',
      this.brand = ''});

  String cardNumber;
  String userName;
  String expiryDate;
  String expirationDate;
  String securityCode;
  String brand;

  Card.fromMap(Map<dynamic, dynamic> data)
      : cardNumber = data["cardNumber"],
        userName = data["userName"],
        expiryDate = data["expiryDate"],
        expirationDate = data["expiryDate"],
        securityCode = data["expiryDate"],
        brand = data["brand"];

  toJson() {
    return {
      "cardNumber": this.cardNumber,
      "userName": this.userName,
      "expiryDate": this.expiryDate,
      "expirationDate": this.expirationDate,
      "securityCode": this.securityCode,
      "brand": this.brand,
    };
  }
}
