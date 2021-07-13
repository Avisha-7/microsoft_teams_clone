class Utils {
  
  // get Username from the email used to sign in
  static String getUsername(String email) {
    return "live:${email.split('@')[0]}";
  }

  // get the initials from first and last name of the registered user
  static String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial + lastNameInitial;
  }
}
