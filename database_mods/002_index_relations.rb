Sequel.migration do
  up do
    alter_table(:subs) do
      add_primary_key [:book_id, :user_id]
      add_index [:book_id, :user_id]
    end
  end
  down do
    alter_table(:subs) do
      drop_primary_key [:book_id, :user_id]
      drop_index [:book_id, :user_id]
    end
  end
end
