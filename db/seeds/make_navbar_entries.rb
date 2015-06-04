admin = User.find_by_email 'admin@casemanager.com'

entries = [{title: 'Clients', url: '/clients', user_id: -1}, {title: 'Admin', url: '/admin_interface', user_id: admin.id}]
entries.each do |ent|
  ne = NavbarEntry.find_or_initialize_by(title: ent[:title])
  ne.url= ent[:url]
  ne.user_id = ent[:user_id]
  ne.save
end
