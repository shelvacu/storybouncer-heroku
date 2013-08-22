echo "Running migrations"
bundle exec sequel -m database_mods/ "$(ruby database_url.rb)"
echo "Running setup_db.rb"
bundle exec ruby setup_db.rb
echo "DONE!"
