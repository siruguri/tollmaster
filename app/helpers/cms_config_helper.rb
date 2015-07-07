module CmsConfigHelper
  def config_or_locale(sym, opts={})
    if c = CmsConfig.find_by_source_symbol(sym)
      if opts.empty?
        c.target_text
      else
        locale_interpolate(c.target_text, opts)
      end
    else
      I18n.t sym, opts
    end
  end

  def locale_interpolate(target_text, opts)
    opts.each do |k, v|      
      if /\%\{#{k.to_s}\}/.match target_text
        target_text.gsub! /\%\{#{k.to_s}\}/, v
      end
    end

    target_text
  end
end
