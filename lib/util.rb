# Utilities that helps with the theme
module Util
  def current_os
    `uname -s`
  end

  def darwin?
    current_os.chomp == 'Darwin'
  end

  def linux?
    current_os.chomp == 'Linux'
  end

  def clean_str(str)
    str.gsub(/\%f|%k|%F{\d+}|%K{\d+}/, '')
  end

  def fg_color(color)
    "%F{#{color}}"
  end

  def bg_color(color)
    "%K{#{color}}"
  end
end
