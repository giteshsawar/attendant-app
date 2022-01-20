class Profile {
  String id, empId, name, dp, designation, phone, joinDate;
  String salary, incentive, penalty, present, absent, earlyLate;
  String services, addons, adhocs;
  double rating;

  Profile({
    this.id,
    this.empId,
    this.name,
    this.dp,
    this.designation,
    this.phone,
    this.joinDate,
    this.rating,
    this.services,
    this.addons,
    this.adhocs,
    this.present,
    this.absent,
    this.earlyLate,
    this.salary,
    this.incentive,
    this.penalty,
  });
}

class Partner {
  String name, phone, dp, empId;
  Partner({this.name, this.phone, this.dp, this.empId});
}
