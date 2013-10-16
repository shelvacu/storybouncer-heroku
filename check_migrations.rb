Sequel.extension :migration
error = true
while error
  begin
    Sequel::Migrator.check_current(DB, './migrations')
    error = false
  rescue Sequel::Migrator::NotCurrentError
    puts "Migration is not current"
    sleep(1)
  end
end
