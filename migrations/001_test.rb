Sequel.migration do
  up do
    create_table(:test) do
      primary_key :id
    end
  end
  
  down do
    drop_table(:test)
  end
end
