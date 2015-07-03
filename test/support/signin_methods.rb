def devise_sign_in(u, scope = :user)
  @request.env["devise.mapping"] = Devise.mappings[scope]
  sign_in u
end

def devise_sign_out(u)
  sign_out u
end
