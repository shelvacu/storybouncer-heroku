if (url = ENV['JUSTONEDB_DBI_URL'])
  m = url.match(/:\/\/(?<user>\w+):(?<pass>\w+)@(?<else>.*)/)
  url = "jdbc:postgresql://#{m[:else]}?user=#{m[:user]}&password=#{m[:pass]}"
else
  url = "jdbc:postgresql://localhost/?user=postgres&password=inspirecreatelearn"
end
print url
