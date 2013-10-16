Sequel.migration do
  up do
    drop_table(:test)
  end
  
  down do
    create_table(:test){}
  end
end
