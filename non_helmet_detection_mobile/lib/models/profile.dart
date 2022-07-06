class Profile {
  int? uid;
  String? firstname;
  String? lastname;
  String? email;
  String? password;
  String? image_profile;

  Profile();

  Profile.fromJson(Map<String?, dynamic> json) {
    uid = json['id'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    email = json['email'];
    image_profile = json['image_profile'];
  }
}
