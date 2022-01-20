String host = '13.235.9.231:3000';
String prePath = "/api/v1";

//auth
String login_employeeWPassword = "http://" + host + prePath + '/auth/login_employeeWPassword';
String generate_loginOTP = "http://" + host + prePath + "/auth/generate_loginOTP";
String login_employeeWOTP = "http://" + host + prePath + "/auth/login_employeeWOTP";

//just gets
String get_work_history = "http://" + host + prePath + "/employee/user/get_work_history";
String get_profile = "http://" + host + prePath + "/employee/user/get_profile";
String get_aws_config = "http://" + host + prePath + "/utils/get-aws-config";
String get_schedule = "http://" + host + prePath + "/operation/schedule/get_schedule";
String get_all_service_list = "http://" + host + prePath + "/operation/service/get_all_service_list";
String get_monthly = "http://" + host + prePath + "/employee/attendance/get_monthly";

//process
String start_service = "http://" + host + prePath + "/operation/schedule_job/start_service";
String end_service = "http://" + host + prePath + "/operation/schedule_job/end_service";
String mark_present = "http://" + host + prePath + "/employee/attendance/mark_present";
String consumables_received = "http://" + host + prePath + "/operation/schedule/consumables_received";
String key_collected = "http://" + host + prePath + "/operation/schedule_job/key_collected";
String mark_eod = "http://" + host + prePath + "/operation/schedule/mark_eod";
String save_media = "http://" + host + prePath + "/operation/schedule_job/save_media";
String save_session_bulk = "http://" + host + prePath + "/operation/schedule_job/save_session_bulk";
