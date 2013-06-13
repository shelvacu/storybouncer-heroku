require './local_sequel'
DB.create_table :sessi do
  primary_key :id
  Time :usetime
  Integer :userid
  String :useragent
  String :ip
  String :data
  TrueClass :lock
end
