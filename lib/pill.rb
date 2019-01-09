require_relative 'segment'
require_relative 'util'

class Pill
  attr_accessor :background, :foreground, :foreground_icon,
                :icon, :foreground_text, :text

  def initialize(background, foreground_icon, icon, foreground_text = '',
                 text = '')
    @background = background
    @foreground = background.tr('K', 'F')
    @foreground_icon = foreground_icon
    @icon = icon
    @foreground_text = foreground_text
    @text = text
  end

  def segment
    bg = ' ' + @foreground_icon + @icon + ' '
    if text.empty?
      Segment.new(@background, bg)
    else
      Segment.new(@background, bg << @foreground_text + @text.to_s + ' ')
    end
  end
end

class OptionalPill < Pill
  include Util

  def initialize(active, config, text = '')
    @active = active
    @config = config
    @text = text.to_s
  end

  def segment
    if @active
      Segment.new(background_color, text)
    else
      nil
    end
  end

  def text
    icon_text = ' ' + icon_color + icon_char + ' '
    if @text.empty?
      icon_text
    else
      icon_text + color + @text.to_s + ' '
    end
  end

  def color
    fg_color(@config['color'])
  end

  def icon_char
    @config['icon']['char']
  end

  def icon_color
    fg_color(@config['icon']['color'])
  end

  def background_color
    bg_color(@config['background_color'])
  end
end
