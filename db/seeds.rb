# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Change these values, especially everything after the two User instances.

admin_u = User.find_or_create_by(email: 'admin@me.com') do |u|
  u.password='admin123'
  u.admin=true
end

u2 = User.find_or_create_by(email: 'just_u@me.com') do |u|
  u.password='userme123'
  u.admin=false
end

ne_ents = [{title: 'Tasks', url: '/tasks'}, {title: 'Locations', url: '/locations'}, {title: 'Profiles', url: '/profiles'}]
ne_ents.each do |ent|
  n_rec = NavbarEntry.find_or_initialize_by(title: ent[:title])
  n_rec.url=ent[:url]
  n_rec.save
end

urg_c=Category.find_or_create_by(name: 'Urgent')
proc_c=Category.find_or_create_by(name: 'Procrastinate')

# Let's leave the tasks as created in duplicate if rake db:seed is re-run.
t=Task.create({title: "Wash clothes", due_date: Date.today + 1}})
t.owner = admin_u

t.categories << urg_c
t.save

t=Task.create({title: "Call mom"})
t.owner = u2
t.categories << proc_c
t.save
