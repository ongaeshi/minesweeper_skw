class Panel
  OFFSET = 2

  def initialize(x, y)
    @x = x
    @y = y
  end

  def update
  end

  def draw
    RoundRect.new(@x+OFFSET, @y+OFFSET, 30-OFFSET*2, 30-OFFSET*2, 4).draw([240, 240, 240])
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
    @panels = []
    @table = Array.new(width) { Array.new(height) }

    # init
    0.upto(height-1) do |y|
      0.upto(width-1) do |x|
        panel = Panel.new(
          x_offset + x * 30,
          y_offset + y * 30
        )

        @panels << panel
        @table[x][y] = panel
      end
    end

    # set bomb

    # calc number
  end

  def panel(x, y)
    @table[x][y]
  end

  def update
    @panels.each { |e| e.update }
  end

  def draw
    @panels.each { |e| e.draw }
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
