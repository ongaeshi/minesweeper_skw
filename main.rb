Window.resize(270, 320, false)
font = Font.new(30)

Graphics.set_background([163, 176, 213])

r = Rect.new(0, 50, 270, 270)

while System.update do
  r.draw([111, 139, 216])
end
