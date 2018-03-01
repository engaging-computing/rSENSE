class CreateSubscriberEmails < ActiveRecord::Migration
  def change
    create_table :subscriber_emails do |t|
      t.string :subject
      t.string :message

      t.timestamps
    end
  end
end
