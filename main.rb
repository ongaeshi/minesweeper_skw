$font = Font.new(18)
$fontl = Font.new(22)
$flag = Texture.new(Emoji.new("🚩")).resize(22, 22)
$bomb = Texture.new(Emoji.new("💣")).resize(24, 24)
$heart = Texture.new(Emoji.new("♥️")).resize(18, 18)

FACE = {
  sunglasses: Texture.new(Emoji.new("😎")).resize(48, 48),
  sob: Texture.new(Emoji.new("😭")).resize(48, 48),
  blush: Texture.new(Emoji.new("😊")).resize(48, 48)
}

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
    @is_mine = @is_open = @is_flag = false
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
      if flag?
        $flag.draw_at(@xpos+SIZE/2, @ypos+SIZE/2, [255, 128, 128])
      end
    elsif @is_mine
      RoundRect.new(xpos, ypos, width, height, round).draw([255, 0, 255])
      $bomb.draw_at(@xpos+SIZE/2, @ypos+SIZE/2)
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

  def toggle_flag
    @is_flag ^= true
  end

  def flag?
    @is_flag
  end
end

class Ground
  def initialize(width, height, x_offset, y_offset, mine)
    @width = width
    @height = height
    @x_offset = x_offset
    @y_offset = y_offset
    @mine = mine
    @life = 3
    reset
  end

  def reset
    @game_over = false
    @panels = []
    @table = Array.new(@width) { Array.new(@height) }

    init_panel
    set_mine
    @panels.each { |e| set_panel_number(e) }
  end

  def continue
    if clear?
      @mine += 1
    else
      @life -= 1
      if @life == 0
        @mine = 1
        @life = 3
      end
    end

    reset
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
    mine = 0
    while mine < @mine
      x = Math.random(@width)
      y = Math.random(@height)

      unless @table[x][y].mine?
        @table[x][y].set_mine
        mine += 1
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
    if !@game_over && !clear?
      @panels.each do |e|
        if MouseL.down &&
           !e.open? &&
           !e.flag? &&
           e.mouse_over?(Cursor.pos.x, Cursor.pos.y)
          e.open
          if e.mine?
            @game_over = true
            @panels.each { |e| e.open if e.mine? }
          end
          open_arround_zero(e)
          break
        elsif MouseR.down &&
              !e.open? &&
              e.mouse_over?(Cursor.pos.x, Cursor.pos.y)
          e.toggle_flag
        end
      end
    end

    # update panel
    @panels.each { |e| e.update }
  end

  def clear?
    return false if @game_over
    open_num = @panels.find_all { |e| e.open? }.length
    open_num == @panels.length - @mine
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

  def flag_num
    @panels.find_all { |e| e.flag? }.length
  end

  def draw
    $fontl["💣#{@mine} 🚩#{flag_num}"].draw_at(55, 25, [0, 0, 0, 180])

    pos = 195
    0.upto(@life-1) do |e|
      $heart.draw_at(pos + e*25, 25)
    end

    kind = :sunglasses
    if @game_over
      kind = :sob
    elsif clear?
      kind = :blush
    end

    FACE[kind].draw_at(Window.width/2, 25)

    @panels.each { |e| e.draw }
  end
end

def make_ground(mine)
  Ground.new(9, 9, 0, 50, mine)
end

#---
Window.resize(270, 320, false)
Graphics.set_background([125, 183, 72])

mine = 1
ground = make_ground(mine)

while System.update do
  ground.update
  ground.draw

  # reset
  if MouseL.down &&
     115 < Cursor.pos.x && Cursor.pos.x < 155 &&
     5 < Cursor.pos.y && Cursor.pos.y < 45
    ground.continue
  end
end
