module TurtleGraphics
  module Canvas
  end
end

class TurtleGraphics::Turtle
  attr_reader :drawboard

  def initialize(rows, columns)
    @row, @column             = 0, 0
    @direction                = [0, 1]
    @drawboard                = Array.new(rows) { Array.new(columns) { 0 } }
    @drawboard[@row][@column] = 1
  end

  def draw(style = self, &block)
    instance_eval &block
    style.generate(@drawboard)
  end

  def generate(drawboard)
    drawboard
  end

  def move()
    calculate_coordinates @row + @direction[0], @column + @direction[1]
    @drawboard[@row][@column] += 1
  end

  def turn_left()
    change_orientation(0, 1)
  end

  def turn_right()
    change_orientation(1, 0)
  end

  def spawn_at(row, column)
    @drawboard[0][0] -= 1
    calculate_coordinates(row, column)
    @drawboard[@row][@column] += 1
  end

  def look(direction)
    @direction = case direction
                   when :left  [ 0, -1]
                   when :right [ 0,  1]
                   when :up    [-1,  0]
                   when :down  [ 1,  0]
                 end
  end

  private

  def change_orientation(vertical, horizontal)
    if(@direction[vertical] != 0)
      @direction = @direction.reverse
    else
      @direction[vertical] = @direction[vertical] - @direction[horizontal]
      @direction[horizontal] = 0
    end
  end

  def calculate_coordinates(row, column)
    @row    = row    % @drawboard.size
    @column = column % @drawboard[0].size
  end
end

class TurtleGraphics::Canvas::ASCII
  attr_reader :symbols

  def initialize(symbols)
    @symbols = symbols
  end

  def generate(matrix)
    maximum_intensity = matrix.map(&:max).max
    coefficient = maximum_intensity.to_f / (@symbols.length - 1)
    matrix.map do |raw|
      raw.map do |pixel|
        @symbols[pixel / coefficient]
      end
    end
  end
end

class TurtleGraphics::Canvas::HTML
  attr_accessor :content
  def initialize(pixel_size)
    @content = "<!DOCTYPE html>\n<html>\n<head>\n  <title>Turtle graphics" +
      "</title>\n  <style>\n    table {\n      border-spacing: 0;\n    }\n" +
      "    tr {\n      padding: 0;\n    }\n    td {\n      width: " +
      "#{pixel_size}px;\n      height: #{pixel_size}px;\n      " +
      "background-color: black;\n      padding: 0;\n    }\n  " +
      "</style>\n</head>\n<body>\n  <table>\n"
  end

  def generate(matrix)
    maximum_intensity = matrix.map(&:max).max
    @content + matrix.map do |raw|
      "    <tr>\n" + raw.map do |pixel|
        "      <td style=\"opacity: " +
        "#{format('%.2f', pixel.to_f / maximum_intensity)}\"></td>\n"
      end.reduce(:+) + "    </tr>\n"
    end.reduce(:+) + "  </table>\n</body>\n</html>"
  end
end