class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.integer :user_id
      t.integer :feed_id
      t.timestamps
    end

    Admin.create(:user_id => 1,
                :feed_id => 1
    )
    Admin.create(:user_id => 4,
                :feed_id => 1
    )
    
  end

  def self.down
    drop_table :admins
  end
end
