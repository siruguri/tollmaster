module PhoneNumberManager
  def canonicalize_number(in_num)
    # Only use numbers; ignore leading 1 or 0; if there is a leading +, it's international.
    in_num = in_num.strip

    is_international = false
    if /^\+/.match in_num
      is_international = true
    end
    
    in_num.gsub! /[^0-9]/, ''
    in_num.gsub! /^[01]/, ''

    {is_international: is_international, number: in_num}
  end
end
