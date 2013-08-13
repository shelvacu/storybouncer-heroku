Sequel.migration do
  up do
    alter_table(:users) do
      drop_column :subs
    end
  end
  
  down do
    alter_table(:users) do
      add_column :subs, Integer
    end
  end
end
