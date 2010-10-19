# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_teladventure_session',
  :secret      => '65e640a7b0e865279f1103a385e60ecec1e4d8060f81c0d0ac1c6880e92e5807b47daee019ef4b30482b6690ac13413cfd9ba818a6bf6fe043b3020f7c50bffc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
