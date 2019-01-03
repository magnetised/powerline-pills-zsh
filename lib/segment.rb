class Segment
  attr_reader :background, :foreground, :text

  def initialize(background, text)
    @background = background
    @foreground = background.tr('K', 'F')
    @text = text
  end

  def join(prev, left, right)
    out =
      if prev.blank?
        # if prev is nil then we output the left with a fg of our fg
        foreground + left
      else
        # if prev is a segment then we output a right with foreground of the
        # prev.background and background our foreground
        prev.foreground + background + right
      end
    out + background + text
  end

  def blank?
    false
  end
end

class BlankSegment
  def join(prev, left, right)
    if prev.blank?
      # if prev is empty just return nothing
      '%k'
    else
      # return a right with a foreground of prev.background
      '%k' + prev.foreground + right
    end
  end

  def blank?
    true
  end
end
