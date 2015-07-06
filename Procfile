web: bin/rails s
redis: redis-server
worker: bundle exec sidekiq -q sms_messages -q stripe_interactions -q mailers -q invoices
