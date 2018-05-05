class Panel
  OFFSET = 2

  def initialize
  end

  def update
  end

  def draw(x, y)
    RoundRect.new(x+OFFSET, y+OFFSET, 30-OFFSET*2, 30-OFFSET*2, 4).draw([240, 240, 240])
  end

  def open
  end

  def set_flag
  end

  def flag?
  end
end

class Ground
  def initialize(width, height, x_offset = 0, y_offset = 0)
    @width = width
    @height = height
    @x_offset = x_offset
    @y_offset = y_offset
    @table = Array.new(width) { Array.new(height) }

    # init
    each do |x, y|
      @table[x][y] = Panel.new()
    end

    # set bomb

    # calc number
  end

  def each
    0.upto(@height-1) do |y|
      0.upto(@width-1) do |x|
        yield x, y
      end
    end
  end

  def panel(x, y)
    @table[x][y]
  end

  def update
    each do |x, y|
      panel(x, y).update
    end
  end

  def draw
    each do |x, y|
      panel(x, y).draw(@x_offset + x*30, @y_offset + y*30)
    end
  end
end

#---
Window.resize(270, 320, false)
Graphics.set_background([125, 183, 72])

font = Font.new(30)

ground = Ground.new(9, 9, 0, 50)

while System.update do
  ground.update
  ground.draw
end
