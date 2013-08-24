require 'local_sequel'
5.times do |i|
  User.create(user: "testuser-#{i}",
              pass: "",
              email: "user-#{i}",
              emailver: rand(2345678900000000000000000000000000000000).to_s,
              veri: true,
              hist: makearray)
end
