class Chapters {
  List<String> links;
  String name;

  // constructor below to initialise with values when class is called
  Chapters({this.name, this.links});

  Chapters.fromJson(Map<String, dynamic> json) {
    if (json['Links'] != null) {
      links = json['Links'].cast<String>();
    }
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Links'] = this.links;
    data['Name'] = this.name;
    return data;
  }
}
