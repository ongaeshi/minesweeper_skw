$font = Font.new(18)

#---
class Panel
  OFFSET = 2
  SIZE = 30

  attr_reader :x, :y
  attr_accessor :number

  def initialize(x, y, xpos, ypos)
    @x = x
    @y = y
    @xpos = xpos
    @ypos = ypos
    @is_mine = false
    @is_open = false
  end

  def set_mine
    @is_mine = true
  end

  def mine?
    @is_mine
  end

  def mouse_over?(xpos, ypos)
    @xpos <= xpos && xpos <= @xpos + SIZE &&
    @ypos <= ypos && ypos <= @ypos + SIZE
  end

  def update
  end

  def draw
    xpos = @xpos+OFFSET
    ypos = @ypos+OFFSET
    width = SIZE-OFFSET*2
    height = SIZE-OFFSET*2
    round = 4

    if !@is_open
      RoundRect.new(xpos, ypos, width, height, round).draw([250, 250, 250])
    elsif @is_mine
      RoundRect.new(xpos, ypos, width, height, round).draw([255, 0, 255])
    else
      RoundRect.new(xpos, ypos, width, height, round).draw([50, 135, 44])
      if @number > 0
        $font[@number.to_s].draw_at(@xpos+SIZE/2, @ypos+SIZE/2, [255, 255, 255])
      end
    end
  end

  def open
    @is_open = true
  end

  def open?
    @is_open
  end

  def set_flag
  end

  def flag?
  end
end

class Ground
  BOMB = 10

  def initialize(width, height, x_offset = 0, y_offset = 0)
    @width = width
    @height = height
    @x_offset = x_offset
    @y_offset = y_offset
    @panels = []
    @table = Array.new(width) { Array.new(height) }

    init_panel
    set_mine
    @panels.each { |e| set_panel_number(e) }
  end

  def init_panel
    0.upto(@height-1) do |y|
      0.upto(@width-1) do |x|
        panel = Panel.new(
          x,
          y,
          @x_offset + x * Panel::SIZE,
          @y_offset + y * Panel::SIZE
        )

        @panels << panel
        @table[x][y] = panel
      end
    end
  end

  def set_mine
    bomb = 0
    while bomb < BOMB
      x = Math.random(@width)
      y = Math.random(@height)

      unless @table[x][y].mine?
        @table[x][y].set_mine
        bomb += 1
      end
    end
  end

  def each_surrounding_panels(pnl)
    x = pnl.x
    y = pnl.y

    pnl = get_panel(x - 1, y - 1)
    yield pnl if pnl

    pnl = get_panel(x, y - 1)
    yield pnl if pnl

    pnl = get_panel(x + 1, y - 1)
    yield pnl if pnl

    pnl = get_panel(x - 1, y)
    yield pnl if pnl

    pnl = get_panel(x + 1, y)
    yield pnl if pnl

    pnl = get_panel(x - 1, y + 1)
    yield pnl if pnl

    pnl = get_panel(x, y + 1)
    yield pnl if pnl

    pnl = get_panel(x + 1, y + 1)
    yield pnl if pnl
  end

  def set_panel_number(panel)
    return if panel.mine?

    num = 0
    each_surrounding_panels(panel) do |e|
      num += 1 if e.mine?
    end

    panel.number = num
  end

  def get_panel(x, y)
    return nil if x < 0 || x >= @width || y < 0 || y >= @height
    @table[x][y]
  end

  def update
    # open panel
    @panels.each do |e|
      if MouseL.down &&
         e.mouse_over?(Cursor.pos.x, Cursor.pos.y) &&
         !e.open?
        e.open
        open_arround_zero(e)
        break
      end
    end

    # update panel
    @panels.each { |e| e.update }
  end

  def open_arround_zero(panel)
    return if panel.number != 0

    each_surrounding_panels(panel) do |e|
      unless e.open?
        e.open
        open_arround_zero(e)
      end
    end
  end

  def draw
    @panels.each { |e| e.draw }
  end
end

#---
Window.resize(270, 320, false)
Graphics.set_background([125, 183, 72])

ground = Ground.new(9, 9, 0, 50)

while System.update do
  ground.update
  ground.draw

  # test
  ground = Ground.new(9, 9, 0, 50) if MouseR.down
end
