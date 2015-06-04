admin_u = User.find_or_create_by(email: 'admin@me.com')
admin_u.password='admin123'
admin_u.admin=true
admin_u.confirmed_at = Time.now.utc
admin_u.save

u = User.find_or_create_by(email: 'just_u@me.com')
u.password='userme123'
u.confirmed_at = Time.now.utc
u.admin=false
u.save

